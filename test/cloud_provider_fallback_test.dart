import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice2law_app/core/app_config.dart';
import 'package:voice2law_app/services/ai_features_service.dart';
import 'package:voice2law_app/services/direct_gemini_service.dart';
import 'package:voice2law_app/services/groq_service.dart';
import 'package:voice2law_app/services/multi_provider_ai_service.dart';

String _geminiBody(String text) => jsonEncode(<String, dynamic>{
  'candidates': <dynamic>[
    <String, dynamic>{
      'content': <String, dynamic>{
        'parts': <dynamic>[
          <String, dynamic>{'text': text},
        ],
      },
    },
  ],
});

String _answerJson({required String answer}) => jsonEncode(<String, dynamic>{
  'answer': answer,
  'answerUrdu': 'اردو جواب',
  'category': 'Property Law',
  'confidence': 0.8,
  'status': 'completed',
  'transcript': 'tenant rights',
});

String _groqBody(String text) => jsonEncode(<String, dynamic>{
  'choices': <dynamic>[
    <String, dynamic>{
      'message': <String, dynamic>{'content': text},
    },
  ],
});

http.Response _jsonResponse(String body) => http.Response.bytes(
  utf8.encode(body),
  200,
  headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AppConfig.instance.reset();
    await AppConfig.instance.load();
  });

  test(
    'text assistant falls back to Groq when Gemini is rate-limited',
    () async {
      final AppConfig config = AppConfig.instance;
      await config.update(
        geminiApiKey: 'gemini-test',
        groqApiKey: 'groq-test',
        selectedAiProvider: 'gemini',
        cloudEnabled: true,
      );

      final MultiProviderAiService service = MultiProviderAiService(
        config,
        gemini: DirectGeminiService(
          config,
          client: MockClient((_) async => http.Response('', 429)),
        ),
        groq: GroqService(
          config,
          client: MockClient(
            (_) async => _jsonResponse(
              _groqBody(_answerJson(answer: 'Groq fallback answer')),
            ),
          ),
        ),
      );

      final answer = await service.askLegalQuestion('tenant rights');
      expect(answer.offline, isFalse);
      expect(answer.answer, 'Groq fallback answer');
      expect(answer.answerUrdu, 'اردو جواب');
    },
  );

  test('AI tools fall back to Groq when Gemini is rate-limited', () async {
    final AppConfig config = AppConfig.instance;
    await config.update(
      geminiApiKey: 'gemini-test',
      groqApiKey: 'groq-test',
      selectedAiProvider: 'gemini',
      cloudEnabled: true,
    );

    final AiFeaturesService service = AiFeaturesService(
      config,
      client: MockClient((http.Request request) async {
        if (request.url.host == 'generativelanguage.googleapis.com') {
          return http.Response('', 429);
        }
        return _jsonResponse(_groqBody('Groq feature answer'));
      }),
    );

    final result = await service.explainTerm('Nafaqa');
    expect(result.success, isTrue);
    expect(result.offline, isFalse);
    expect(result.content, 'Groq feature answer');
    expect(service.lastStatus, 'ok');
  });

  test('Gemini is still used when it succeeds', () async {
    final AppConfig config = AppConfig.instance;
    await config.update(
      geminiApiKey: 'gemini-test',
      groqApiKey: 'groq-test',
      selectedAiProvider: 'gemini',
      cloudEnabled: true,
    );

    final MultiProviderAiService service = MultiProviderAiService(
      config,
      gemini: DirectGeminiService(
        config,
        client: MockClient(
          (_) async =>
              _jsonResponse(_geminiBody(_answerJson(answer: 'Gemini answer'))),
        ),
      ),
      groq: GroqService(
        config,
        client: MockClient((_) async {
          fail('Groq should not be called when Gemini succeeds');
        }),
      ),
    );

    final answer = await service.askLegalQuestion('tenant rights');
    expect(answer.offline, isFalse);
    expect(answer.answer, 'Gemini answer');
  });

  test(
    'Groq UTF-8 answers decode correctly without a charset header',
    () async {
      final AppConfig config = AppConfig.instance;
      await config.update(
        groqApiKey: 'groq-test',
        selectedAiProvider: 'groq',
        cloudEnabled: true,
      );

      final GroqService service = GroqService(
        config,
        client: MockClient(
          (_) async => http.Response.bytes(
            utf8.encode(_groqBody(_answerJson(answer: 'English answer'))),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          ),
        ),
      );

      final answer = await service.askLegalQuestion('tenant rights');
      expect(answer.offline, isFalse);
      expect(answer.answer, 'English answer');
      expect(answer.answerUrdu, 'اردو جواب');
    },
  );
}
