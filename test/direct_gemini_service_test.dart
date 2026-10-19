import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:voice2law_app/core/app_config.dart';
import 'package:voice2law_app/models/models.dart';
import 'package:voice2law_app/services/direct_gemini_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AppConfig.instance.load();
  });
  test('cloud is opt-in and never sends a request when disabled', () async {
    var called = false;
    final service = DirectGeminiService(
      AppConfig.instance,
      client: MockClient((_) async {
        called = true;
        return http.Response('', 500);
      }),
    );
    final answer = await service.askLegalQuestion('divorce');
    expect(answer.offline, isTrue);
    expect(called, isFalse);
  });
  test(
    'cloud sends bounded context, a separate system instruction, and a header key',
    () async {
      final config = AppConfig.instance;
      await config.update(geminiApiKey: 'test-only-key', cloudEnabled: true);
      final service = DirectGeminiService(
        config,
        client: MockClient((request) async {
          expect(request.url.queryParameters.containsKey('key'), isFalse);
          expect(request.headers['x-goog-api-key'], 'test-only-key');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['systemInstruction'], isNotNull);
          expect((body['contents'] as List).length, 7);
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'text': jsonEncode({
                          'answer':
                              'This is a test answer grounded in provided reference material.',
                          'answerUrdu': 'یہ ایک آزمائشی جواب ہے۔',
                          'statutes': [
                            {
                              'actName': 'Invented Act',
                              'section': '999',
                              'citation': 'Fake precedent',
                            },
                          ],
                          'roadmap': [
                            {'title': 'Review documents', 'stepNumber': 1},
                          ],
                        }),
                      },
                    ],
                  },
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final answer = await service.askLegalQuestion(
        'divorce',
        history: List.generate(
          10,
          (i) => ChatMessage(id: '$i', isUser: i.isEven, text: 'Prior turn $i'),
        ),
      );
      expect(answer.offline, isFalse);
      expect(answer.confidence, 0);
      expect(answer.roadmap, hasLength(1));
      expect(answer.statutes.any((s) => s.actName == 'Invented Act'), isFalse);
    },
  );
  test('cloud failures return an explicitly offline answer', () async {
    await AppConfig.instance.update(
      geminiApiKey: 'test-only-key',
      cloudEnabled: true,
    );
    var requests = 0;
    final service = DirectGeminiService(
      AppConfig.instance,
      client: MockClient((_) async {
        requests++;
        return http.Response('', 503);
      }),
    );
    final answer = await service.askLegalQuestion('divorce');
    expect(requests, 2);
    expect(answer.offline, isTrue);
  });
  test('empty question never calls the cloud', () async {
    final answer = await DirectGeminiService(
      AppConfig.instance,
    ).askLegalQuestion(' ');
    expect(answer.offline, isTrue);
  });
}
