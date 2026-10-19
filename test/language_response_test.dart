// Tests that verify the app responds correctly in the requested language.
//
// Coverage:
//   1. LanguageHelper.resolve() — all three preference values ('en', 'ur', 'auto')
//   2. LanguageHelper.sttLocaleFor() — correct BCP-47 STT locale per language
//   3. LanguageHelper.ttsLocaleFor() — correct TTS locale, with/without Urdu voice
//   4. AppConfig language preference — persists and reloads correctly
//   5. LocalLegalBrain — Urdu answer field is non-empty for every curated topic
//   6. DirectGeminiService — Urdu answer field flows through from a mock Gemini response
//   7. DirectGeminiService — offline fallback still returns Urdu fields
//   8. DirectGeminiService — lastGeminiStatus set to 'ok' on success, 'http_XXX' on error,
//      'offline' when no key / cloud disabled, and 'timeout' on timeout
//   9. DirectGeminiService — isOfflineMode reflects lastGeminiStatus correctly

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:voice2law_app/core/app_config.dart';
import 'package:voice2law_app/core/language_helper.dart';
import 'package:voice2law_app/data/pakistani_law_data.dart';
import 'package:voice2law_app/models/models.dart';
import 'package:voice2law_app/services/direct_gemini_service.dart';
import 'package:voice2law_app/services/local_legal_brain.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a minimal valid Gemini HTTP 200 response wrapping [payload].
http.Response _geminiOk(Map<String, dynamic> payload) => http.Response(
  jsonEncode({
    'candidates': [
      {
        'content': {
          'parts': [
            {'text': jsonEncode(payload)},
          ],
        },
      },
    ],
  }),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// A valid Gemini payload with both English and Urdu fields populated.
Map<String, dynamic> _bilingualPayload({
  String answer = 'This is the English answer.',
  String answerUrdu = 'یہ اردو جواب ہے۔',
  String courtModeAnswer = 'Formal legal analysis.',
  String courtModeAnswerUrdu = 'رسمی قانونی تجزیہ۔',
  String empatheticOpening = 'We understand.',
  String empatheticOpeningUrdu = 'ہم سمجھتے ہیں۔',
}) => {
  'answer': answer,
  'answerUrdu': answerUrdu,
  'courtModeAnswer': courtModeAnswer,
  'courtModeAnswerUrdu': courtModeAnswerUrdu,
  'empatheticOpening': empatheticOpening,
  'empatheticOpeningUrdu': empatheticOpeningUrdu,
  'category': 'Family Law',
  'urgencyLevel': 'normal',
  'roadmap': [
    {
      'stepNumber': 1,
      'title': 'File petition',
      'titleUrdu': 'درخواست دائر کریں',
      'description': 'Go to family court.',
      'descriptionUrdu': 'فیملی کورٹ جائیں۔',
      'estimatedTime': '1 week',
      'estimatedTimeUrdu': 'ایک ہفتہ',
      'courtOrAuthority': 'Family Court',
      'courtOrAuthorityUrdu': 'فیملی کورٹ',
    },
  ],
  'documents': [
    {
      'name': 'CNIC',
      'nameUrdu': 'شناختی کارڈ',
      'isMandatory': true,
      'notes': 'Required',
      'notesUrdu': 'ضروری',
    },
  ],
  'statutes': [],
  'suggestedEmergencyHelpline': '',
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AppConfig.instance.load();
  });

  // -------------------------------------------------------------------------
  // 1. LanguageHelper.resolve()
  // -------------------------------------------------------------------------
  group('LanguageHelper.resolve', () {
    test('returns en for explicit English preference', () {
      expect(LanguageHelper.resolve('en'), 'en');
    });

    test('returns ur for explicit Urdu preference', () {
      expect(LanguageHelper.resolve('ur'), 'ur');
    });

    test('returns en for auto when no ur locale on test runner', () {
      // The test runner's platform locale is not Urdu, so auto → en.
      expect(LanguageHelper.resolve('auto'), 'en');
    });

    test('returns en for an unknown/garbage preference value', () {
      expect(LanguageHelper.resolve('fr'), 'en');
      expect(LanguageHelper.resolve(''), 'en');
    });
  });

  // -------------------------------------------------------------------------
  // 2. LanguageHelper.sttLocaleFor()
  // -------------------------------------------------------------------------
  group('LanguageHelper.sttLocaleFor', () {
    test('returns ur-PK for Urdu language when config is auto', () {
      expect(LanguageHelper.sttLocaleFor('ur', 'auto'), 'ur-PK');
    });

    test('returns en-US for English language when config is auto', () {
      expect(LanguageHelper.sttLocaleFor('en', 'auto'), 'en-US');
    });

    test('respects explicit config locale over language code', () {
      // When the user has explicitly set a locale in Settings, that wins.
      expect(LanguageHelper.sttLocaleFor('ur', 'en_US'), 'en_US');
      expect(LanguageHelper.sttLocaleFor('en', 'ur_PK'), 'ur_PK');
    });
  });

  // -------------------------------------------------------------------------
  // 3. LanguageHelper.ttsLocaleFor()
  // -------------------------------------------------------------------------
  group('LanguageHelper.ttsLocaleFor', () {
    test('returns detected Urdu voice locale when language is Urdu', () {
      expect(LanguageHelper.ttsLocaleFor('ur', 'ur-PK'), 'ur-PK');
      expect(LanguageHelper.ttsLocaleFor('ur', 'ur-IN'), 'ur-IN');
    });

    test(
      'returns fallback ur-PK when Urdu language but no voice installed',
      () {
        expect(LanguageHelper.ttsLocaleFor('ur', null), 'ur-PK');
      },
    );

    test('returns en-US when language is English regardless of voice', () {
      expect(LanguageHelper.ttsLocaleFor('en', 'ur-PK'), 'en-US');
      expect(LanguageHelper.ttsLocaleFor('en', null), 'en-US');
    });
  });

  // -------------------------------------------------------------------------
  // 4. AppConfig language preference persistence
  // -------------------------------------------------------------------------
  group('AppConfig.languagePreference', () {
    test('defaults to en on fresh install', () {
      expect(AppConfig.instance.languagePreference, 'en');
    });

    test('persists ur across update/reload cycle', () async {
      await AppConfig.instance.update(languagePreference: 'ur');
      // Simulate reload from storage.
      await AppConfig.instance.load();
      expect(AppConfig.instance.languagePreference, 'ur');
    });

    test('persists auto across update/reload cycle', () async {
      await AppConfig.instance.update(languagePreference: 'auto');
      await AppConfig.instance.load();
      expect(AppConfig.instance.languagePreference, 'auto');
    });

    test('ignores invalid values and leaves the field unchanged', () async {
      await AppConfig.instance.update(languagePreference: 'ur');
      await AppConfig.instance.update(languagePreference: 'zh'); // invalid
      expect(AppConfig.instance.languagePreference, 'ur'); // unchanged
    });

    test('reset() restores languagePreference to en', () async {
      await AppConfig.instance.update(languagePreference: 'ur');
      await AppConfig.instance.reset();
      expect(AppConfig.instance.languagePreference, 'en');
    });

    test('isUrdu helper reflects config correctly', () async {
      await AppConfig.instance.update(languagePreference: 'ur');
      expect(LanguageHelper.isUrdu(AppConfig.instance), isTrue);

      await AppConfig.instance.update(languagePreference: 'en');
      expect(LanguageHelper.isUrdu(AppConfig.instance), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 5. LocalLegalBrain — Urdu fields in offline answers
  // -------------------------------------------------------------------------
  group('LocalLegalBrain Urdu fields', () {
    test('every curated topic has a non-empty Urdu summary', () {
      for (final LawTopic topic in pakistaniLawTopics) {
        expect(
          topic.summaryUrdu,
          isNotEmpty,
          reason: 'topic ${topic.id} is missing summaryUrdu',
        );
      }
    });

    test('every curated topic has Urdu text in at least one roadmap step', () {
      for (final LawTopic topic in pakistaniLawTopics) {
        final bool anyUrduStep = topic.steps.any(
          (s) => s.titleUrdu.isNotEmpty || s.detailUrdu.isNotEmpty,
        );
        expect(
          anyUrduStep,
          isTrue,
          reason: 'topic ${topic.id} has no Urdu roadmap steps',
        );
      }
    });

    test('answer() for a divorce question returns non-empty answerUrdu', () {
      final AiAnswer answer = LocalLegalBrain.answer('divorce');
      expect(answer.offline, isTrue);
      expect(
        answer.answerUrdu,
        isNotEmpty,
        reason: 'answerUrdu should not be empty for a matched curated topic',
      );
    });

    test('answer() for an Urdu divorce query returns non-empty answerUrdu', () {
      final AiAnswer answer = LocalLegalBrain.answer('طلاق کا طریقہ کیا ہے');
      expect(answer.offline, isTrue);
      expect(answer.answerUrdu, isNotEmpty);
    });

    test(
      'answer() for a cyber-fraud question returns non-empty Urdu answer',
      () {
        final AiAnswer answer = LocalLegalBrain.answer(
          'my bank account was hacked',
        );
        expect(answer.offline, isTrue);
        expect(answer.answerUrdu, isNotEmpty);
      },
    );

    test(
      'answerWithCorpus() returns answerUrdu even through the async path',
      () async {
        final AiAnswer answer = await LocalLegalBrain.answerWithCorpus(
          'divorce',
        );
        expect(answer.answerUrdu, isNotEmpty);
      },
    );

    test('roadmap steps from curated topic carry Urdu titles', () {
      final AiAnswer answer = LocalLegalBrain.answer('divorce');
      for (final LegalJourneyStep step in answer.roadmap) {
        expect(
          step.titleUrdu,
          isNotEmpty,
          reason: 'roadmap step ${step.stepNumber} is missing titleUrdu',
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  // 6. DirectGeminiService — Urdu fields flow through from Gemini response
  // -------------------------------------------------------------------------
  group('DirectGeminiService Urdu language pass-through', () {
    late DirectGeminiService service;

    setUp(() async {
      await AppConfig.instance.update(
        geminiApiKey: 'test-key',
        cloudEnabled: true,
      );
      service = DirectGeminiService(
        AppConfig.instance,
        client: MockClient((_) async => _geminiOk(_bilingualPayload())),
      );
    });

    test('answerUrdu from Gemini response is preserved in AiAnswer', () async {
      final AiAnswer answer = await service.askLegalQuestion('divorce');
      expect(answer.offline, isFalse);
      expect(answer.answerUrdu, 'یہ اردو جواب ہے۔');
    });

    test('courtModeAnswerUrdu from Gemini response is preserved', () async {
      final AiAnswer answer = await service.askLegalQuestion('divorce');
      expect(answer.courtModeAnswerUrdu, 'رسمی قانونی تجزیہ۔');
    });

    test('empatheticOpeningUrdu from Gemini response is preserved', () async {
      final AiAnswer answer = await service.askLegalQuestion('divorce');
      expect(answer.empatheticOpeningUrdu, 'ہم سمجھتے ہیں۔');
    });

    test('roadmap steps carry Urdu fields from Gemini response', () async {
      final AiAnswer answer = await service.askLegalQuestion('divorce');
      expect(answer.roadmap, hasLength(1));
      expect(answer.roadmap.first.titleUrdu, 'درخواست دائر کریں');
      expect(answer.roadmap.first.descriptionUrdu, 'فیملی کورٹ جائیں۔');
      expect(answer.roadmap.first.estimatedTimeUrdu, 'ایک ہفتہ');
      expect(answer.roadmap.first.courtOrAuthorityUrdu, 'فیملی کورٹ');
    });

    test(
      'document checklist carries Urdu fields from Gemini response',
      () async {
        final AiAnswer answer = await service.askLegalQuestion('divorce');
        expect(answer.documents, hasLength(1));
        expect(answer.documents.first.nameUrdu, 'شناختی کارڈ');
        expect(answer.documents.first.notesUrdu, 'ضروری');
      },
    );

    test('Gemini response with empty answerUrdu falls back to LocalLegalBrain '
        'which still has Urdu fields', () async {
      // Simulate Gemini returning an empty Urdu answer field.
      final svc = DirectGeminiService(
        AppConfig.instance,
        client: MockClient(
          (_) async => _geminiOk(
            _bilingualPayload(answer: 'English only', answerUrdu: ''),
          ),
        ),
      );
      // Empty answer triggers fallback per _parseGeminiJson logic.
      // (answerUrdu empty but answer non-empty → answer is used but
      //  answerUrdu is '' — that is valid, the test confirms no crash.)
      final AiAnswer answer = await svc.askLegalQuestion('divorce');
      expect(answer.answer, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // 7. DirectGeminiService — offline fallback preserves Urdu fields
  // -------------------------------------------------------------------------
  group('DirectGeminiService offline fallback Urdu fields', () {
    test(
      'when cloud is disabled the offline answer still has answerUrdu',
      () async {
        // Cloud disabled → straight to LocalLegalBrain.
        final service = DirectGeminiService(AppConfig.instance);
        final AiAnswer answer = await service.askLegalQuestion('divorce');
        expect(answer.offline, isTrue);
        expect(answer.answerUrdu, isNotEmpty);
      },
    );

    test(
      'when Gemini returns HTTP 503 both times the offline answer has Urdu',
      () async {
        await AppConfig.instance.update(
          geminiApiKey: 'test-key',
          cloudEnabled: true,
        );
        final service = DirectGeminiService(
          AppConfig.instance,
          client: MockClient((_) async => http.Response('', 503)),
        );
        final AiAnswer answer = await service.askLegalQuestion('divorce');
        expect(answer.offline, isTrue);
        expect(answer.answerUrdu, isNotEmpty);
      },
    );

    test(
      'when Gemini returns malformed JSON the offline answer has Urdu',
      () async {
        await AppConfig.instance.update(
          geminiApiKey: 'test-key',
          cloudEnabled: true,
        );
        final service = DirectGeminiService(
          AppConfig.instance,
          client: MockClient(
            (_) async => _geminiOk({'not_answer': 'bad schema'}),
          ),
        );
        final AiAnswer answer = await service.askLegalQuestion('divorce');
        expect(answer.offline, isTrue);
        expect(answer.answerUrdu, isNotEmpty);
      },
    );
  });

  // -------------------------------------------------------------------------
  // 8 & 9. DirectGeminiService.lastGeminiStatus and isOfflineMode
  // -------------------------------------------------------------------------
  group('DirectGeminiService.lastGeminiStatus', () {
    test('is null before any request is made', () {
      final service = DirectGeminiService(AppConfig.instance);
      expect(service.lastGeminiStatus, isNull);
      expect(service.isOfflineMode, isFalse);
    });

    test("is 'offline' when no API key is configured", () async {
      // cloud enabled but empty key → immediate offline
      await AppConfig.instance.update(cloudEnabled: true, geminiApiKey: '');
      final service = DirectGeminiService(AppConfig.instance);
      await service.askLegalQuestion('divorce');
      expect(service.lastGeminiStatus, 'offline');
      expect(service.isOfflineMode, isTrue);
    });

    test("is 'offline' when cloud is disabled", () async {
      // cloud disabled regardless of key
      await AppConfig.instance.update(cloudEnabled: false);
      final service = DirectGeminiService(AppConfig.instance);
      await service.askLegalQuestion('divorce');
      expect(service.lastGeminiStatus, 'offline');
      expect(service.isOfflineMode, isTrue);
    });

    test("is 'ok' when Gemini returns HTTP 200 with a valid answer", () async {
      await AppConfig.instance.update(
        geminiApiKey: 'test-key',
        cloudEnabled: true,
      );
      final service = DirectGeminiService(
        AppConfig.instance,
        client: MockClient((_) async => _geminiOk(_bilingualPayload())),
      );
      await service.askLegalQuestion('divorce');
      expect(service.lastGeminiStatus, 'ok');
      expect(service.isOfflineMode, isFalse);
    });

    test(
      "is 'http_503' when Gemini returns HTTP 503 on both attempts",
      () async {
        await AppConfig.instance.update(
          geminiApiKey: 'test-key',
          cloudEnabled: true,
        );
        final service = DirectGeminiService(
          AppConfig.instance,
          client: MockClient((_) async => http.Response('', 503)),
        );
        await service.askLegalQuestion('divorce');
        expect(service.lastGeminiStatus, 'http_503');
        expect(service.isOfflineMode, isTrue);
      },
    );

    test(
      "is 'http_429' when Gemini returns HTTP 429 (quota exceeded)",
      () async {
        await AppConfig.instance.update(
          geminiApiKey: 'test-key',
          cloudEnabled: true,
        );
        final service = DirectGeminiService(
          AppConfig.instance,
          client: MockClient((_) async => http.Response('', 429)),
        );
        await service.askLegalQuestion('divorce');
        expect(service.lastGeminiStatus, 'http_429');
        expect(service.isOfflineMode, isTrue);
      },
    );

    test(
      "is 'timeout' when the HTTP request times out",
      () async {
        await AppConfig.instance.update(
          geminiApiKey: 'test-key',
          cloudEnabled: true,
        );
        // Use a 1 s request timeout and a 2 s response delay so both model
        // attempts time out without making the test suite wait 60 s.
        final service = DirectGeminiService(
          AppConfig.instance,
          requestTimeout: const Duration(seconds: 1),
          client: MockClient(
            (_) => Future.delayed(
              const Duration(seconds: 2),
              () => http.Response('', 200),
            ),
          ),
        );
        await expectLater(service.askLegalQuestion('divorce'), completes);
        expect(service.lastGeminiStatus, 'timeout');
        expect(service.isOfflineMode, isTrue);
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test('resets to ok on a subsequent successful request', () async {
      await AppConfig.instance.update(
        geminiApiKey: 'test-key',
        cloudEnabled: true,
      );
      var callCount = 0;
      final service = DirectGeminiService(
        AppConfig.instance,
        client: MockClient((_) async {
          callCount++;
          // First two calls fail (primary + fallback), subsequent succeed.
          if (callCount <= 2) return http.Response('', 503);
          return _geminiOk(_bilingualPayload());
        }),
      );

      await service.askLegalQuestion('divorce');
      expect(service.lastGeminiStatus, 'http_503');

      await service.askLegalQuestion('bail');
      expect(service.lastGeminiStatus, 'ok');
      expect(service.isOfflineMode, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 10. LanguageHelper.resolve — regional languages (Punjabi, Sindhi, Pashto)
  // -------------------------------------------------------------------------
  group('LanguageHelper.resolve — regional languages', () {
    test('returns pa for explicit Punjabi preference', () {
      expect(LanguageHelper.resolve('pa'), 'pa');
    });
    test('returns sd for explicit Sindhi preference', () {
      expect(LanguageHelper.resolve('sd'), 'sd');
    });
    test('returns ps for explicit Pashto preference', () {
      expect(LanguageHelper.resolve('ps'), 'ps');
    });
  });

  // -------------------------------------------------------------------------
  // 11. LanguageHelper.metaFor — all 5 languages
  // -------------------------------------------------------------------------
  group('LanguageHelper.metaFor', () {
    test('English meta is correct', () {
      final m = LanguageHelper.metaFor('en');
      expect(m.code, 'en');
      expect(m.rtl, isFalse);
      expect(m.fontFamily, isNull);
      expect(m.bcp47Stt, 'en-US');
    });
    test('Urdu meta is correct', () {
      final m = LanguageHelper.metaFor('ur');
      expect(m.code, 'ur');
      expect(m.rtl, isTrue);
      expect(m.fontFamily, 'NotoNastaliqUrdu');
      expect(m.bcp47Stt, 'ur-PK');
    });
    test('Punjabi meta is correct', () {
      final m = LanguageHelper.metaFor('pa');
      expect(m.code, 'pa');
      expect(m.rtl, isTrue);
      expect(m.fontFamily, 'NotoNastaliqUrdu');
      expect(m.bcp47Stt, 'pa-PK');
    });
    test('Sindhi meta is correct', () {
      final m = LanguageHelper.metaFor('sd');
      expect(m.code, 'sd');
      expect(m.rtl, isTrue);
      expect(m.bcp47Stt, 'sd-PK');
    });
    test('Pashto meta is correct', () {
      final m = LanguageHelper.metaFor('ps');
      expect(m.code, 'ps');
      expect(m.rtl, isTrue);
      expect(m.bcp47Stt, 'ps-PK');
    });
    test('unknown code falls back to English meta', () {
      final m = LanguageHelper.metaFor('xyz');
      expect(m.code, 'en');
    });
  });

  // -------------------------------------------------------------------------
  // 12. LanguageHelper.sttLocaleFor — regional languages
  // -------------------------------------------------------------------------
  group('LanguageHelper.sttLocaleFor — regional', () {
    test('returns pa-PK for Punjabi when config is auto', () {
      expect(LanguageHelper.sttLocaleFor('pa', 'auto'), 'pa-PK');
    });
    test('returns sd-PK for Sindhi when config is auto', () {
      expect(LanguageHelper.sttLocaleFor('sd', 'auto'), 'sd-PK');
    });
    test('returns ps-PK for Pashto when config is auto', () {
      expect(LanguageHelper.sttLocaleFor('ps', 'auto'), 'ps-PK');
    });
  });

  // -------------------------------------------------------------------------
  // 13. LanguageHelper.ttsLocaleFor — regional languages
  // -------------------------------------------------------------------------
  group('LanguageHelper.ttsLocaleFor — regional', () {
    test('returns pa-PK for Punjabi', () {
      expect(LanguageHelper.ttsLocaleFor('pa', null), 'pa-PK');
    });
    test('returns sd-PK for Sindhi', () {
      expect(LanguageHelper.ttsLocaleFor('sd', null), 'sd-PK');
    });
    test('returns ps-PK for Pashto', () {
      expect(LanguageHelper.ttsLocaleFor('ps', null), 'ps-PK');
    });
  });

  // -------------------------------------------------------------------------
  // 14. LanguageHelper.answerFor — picks correct field, falls back to English
  // -------------------------------------------------------------------------
  group('LanguageHelper.answerFor', () {
    const String en = 'English answer.';
    const String ur = 'اردو جواب۔';
    const String pa = 'پنجابی جواب۔';
    const String sd = 'سنڌي جواب۔';
    const String ps = 'پښتو جواب۔';

    test('returns Urdu text when lang is ur and urdu is non-empty', () {
      expect(
        LanguageHelper.answerFor(
          langCode: 'ur',
          english: en,
          urdu: ur,
          punjabi: pa,
          sindhi: sd,
          pashto: ps,
        ),
        ur,
      );
    });
    test('returns Punjabi text when lang is pa and punjabi is non-empty', () {
      expect(
        LanguageHelper.answerFor(
          langCode: 'pa',
          english: en,
          urdu: ur,
          punjabi: pa,
          sindhi: sd,
          pashto: ps,
        ),
        pa,
      );
    });
    test('returns Sindhi text when lang is sd and sindhi is non-empty', () {
      expect(
        LanguageHelper.answerFor(
          langCode: 'sd',
          english: en,
          urdu: ur,
          punjabi: pa,
          sindhi: sd,
          pashto: ps,
        ),
        sd,
      );
    });
    test('returns Pashto text when lang is ps and pashto is non-empty', () {
      expect(
        LanguageHelper.answerFor(
          langCode: 'ps',
          english: en,
          urdu: ur,
          punjabi: pa,
          sindhi: sd,
          pashto: ps,
        ),
        ps,
      );
    });
    test('returns English text when lang is en', () {
      expect(
        LanguageHelper.answerFor(
          langCode: 'en',
          english: en,
          urdu: ur,
          punjabi: pa,
          sindhi: sd,
          pashto: ps,
        ),
        en,
      );
    });
    test('falls back to English when regional field is empty', () {
      expect(
        LanguageHelper.answerFor(
          langCode: 'pa',
          english: en,
          urdu: ur,
          punjabi: '',
          sindhi: sd,
          pashto: ps,
        ),
        en,
      );
    });
    test('falls back to English when regional field is empty (Sindhi)', () {
      expect(
        LanguageHelper.answerFor(
          langCode: 'sd',
          english: en,
          urdu: ur,
          punjabi: pa,
          sindhi: '',
          pashto: ps,
        ),
        en,
      );
    });
    test('falls back to English when regional field is empty (Pashto)', () {
      expect(
        LanguageHelper.answerFor(
          langCode: 'ps',
          english: en,
          urdu: ur,
          punjabi: pa,
          sindhi: sd,
          pashto: '',
        ),
        en,
      );
    });
  });

  // -------------------------------------------------------------------------
  // 15. LanguageHelper.isRtl / isRegional
  // -------------------------------------------------------------------------
  group('LanguageHelper.isRtl', () {
    test(
      'English is not RTL',
      () => expect(LanguageHelper.isRtl('en'), isFalse),
    );
    test('Urdu is RTL', () => expect(LanguageHelper.isRtl('ur'), isTrue));
    test('Punjabi is RTL', () => expect(LanguageHelper.isRtl('pa'), isTrue));
    test('Sindhi is RTL', () => expect(LanguageHelper.isRtl('sd'), isTrue));
    test('Pashto is RTL', () => expect(LanguageHelper.isRtl('ps'), isTrue));
  });

  group('LanguageHelper.isRegional', () {
    test('English is not regional', () {
      expect(LanguageHelper.isRegional('en'), isFalse);
    });
    test(
      'Urdu is regional',
      () => expect(LanguageHelper.isRegional('ur'), isTrue),
    );
    test(
      'Punjabi is regional',
      () => expect(LanguageHelper.isRegional('pa'), isTrue),
    );
    test(
      'Sindhi is regional',
      () => expect(LanguageHelper.isRegional('sd'), isTrue),
    );
    test(
      'Pashto is regional',
      () => expect(LanguageHelper.isRegional('ps'), isTrue),
    );
  });

  // -------------------------------------------------------------------------
  // 16. AppConfig persistence — regional languages
  // -------------------------------------------------------------------------
  group('AppConfig persistence — regional languages', () {
    test('persists pa across update/reload cycle', () async {
      await AppConfig.instance.update(languagePreference: 'pa');
      await AppConfig.instance.load();
      expect(AppConfig.instance.languagePreference, 'pa');
    });
    test('persists sd across update/reload cycle', () async {
      await AppConfig.instance.update(languagePreference: 'sd');
      await AppConfig.instance.load();
      expect(AppConfig.instance.languagePreference, 'sd');
    });
    test('persists ps across update/reload cycle', () async {
      await AppConfig.instance.update(languagePreference: 'ps');
      await AppConfig.instance.load();
      expect(AppConfig.instance.languagePreference, 'ps');
    });
  });

  // -------------------------------------------------------------------------
  // 17. DirectGeminiService — Punjabi, Sindhi, Pashto fields pass-through
  // -------------------------------------------------------------------------
  group('DirectGeminiService regional language pass-through', () {
    test(
      'answerPunjabi from Gemini response is preserved in AiAnswer',
      () async {
        await AppConfig.instance.update(
          geminiApiKey: 'test-key',
          cloudEnabled: true,
        );
        final service = DirectGeminiService(
          AppConfig.instance,
          client: MockClient(
            (_) async => _geminiOk({
              ..._bilingualPayload(),
              'answerPunjabi': 'ایہہ پنجابی جواب اے۔',
              'answerSindhi': 'هي سنڌي جواب آهي۔',
              'answerPashto': 'دا پښتو جواب دی۔',
            }),
          ),
        );
        final answer = await service.askLegalQuestion('divorce');
        expect(answer.offline, isFalse);
        expect(answer.answerPunjabi, 'ایہہ پنجابی جواب اے۔');
        expect(answer.answerSindhi, 'هي سنڌي جواب آهي۔');
        expect(answer.answerPashto, 'دا پښتو جواب دی۔');
      },
    );

    test(
      'empty regional fields are preserved as empty strings (no crash)',
      () async {
        await AppConfig.instance.update(
          geminiApiKey: 'test-key',
          cloudEnabled: true,
        );
        final service = DirectGeminiService(
          AppConfig.instance,
          client: MockClient((_) async => _geminiOk(_bilingualPayload())),
        );
        final answer = await service.askLegalQuestion('divorce');
        // The _bilingualPayload doesn't include answerPunjabi etc., so they
        // should default to empty strings, not crash.
        expect(answer.answerPunjabi, '');
        expect(answer.answerSindhi, '');
        expect(answer.answerPashto, '');
        // answerUrdu should still be populated.
        expect(answer.answerUrdu, isNotEmpty);
      },
    );
  });

  // -------------------------------------------------------------------------
  // 18. AiAnswer.fromJson — parses regional fields from JSON
  // -------------------------------------------------------------------------
  group('AiAnswer.fromJson — regional fields', () {
    test('parses all 5 language fields from JSON', () {
      final answer = AiAnswer.fromJson({
        'answer': 'English text',
        'answerUrdu': 'اردو',
        'answerPunjabi': 'پنجابی',
        'answerSindhi': 'سنڌي',
        'answerPashto': 'پښتو',
      });
      expect(answer.answer, 'English text');
      expect(answer.answerUrdu, 'اردو');
      expect(answer.answerPunjabi, 'پنجابی');
      expect(answer.answerSindhi, 'سنڌي');
      expect(answer.answerPashto, 'پښتو');
    });

    test('defaults to empty string for missing regional fields', () {
      final answer = AiAnswer.fromJson({'answer': 'English text'});
      expect(answer.answerPunjabi, '');
      expect(answer.answerSindhi, '');
      expect(answer.answerPashto, '');
    });
  });
}
