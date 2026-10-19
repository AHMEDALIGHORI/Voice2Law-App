import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice2law_app/app.dart';
import 'package:voice2law_app/core/app_config.dart';
import 'package:voice2law_app/core/app_scope.dart';
import 'package:voice2law_app/screens/document_explainer_screen.dart';
import 'package:voice2law_app/screens/rights_scenarios_screen.dart';
import 'package:voice2law_app/services/ai_features_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AppConfig.instance.load();
  });

  Future<void> pumpApp(WidgetTester tester, {double scale = 1.0}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(Voice2LawApp(services: AppServices()));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> openRoute(WidgetTester tester, String route) async {
    final NavigatorState nav = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    nav.pushNamed(route);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  Finder scrollableIn(Type screenType) => find
      .descendant(
        of: find.byType(screenType),
        matching: find.byType(Scrollable),
      )
      .first;

  testWidgets('home surfaces Snap & Explain and My Rights', (tester) async {
    await pumpApp(tester);
    await tester.scrollUntilVisible(
      find.text('Snap & Explain'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Snap & Explain'), findsOneWidget);
    expect(find.text('My Rights'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final double scale in <double>[1.0, 2.0]) {
    testWidgets('My Rights renders offline at text scale $scale', (
      tester,
    ) async {
      await pumpApp(tester, scale: scale);
      await openRoute(tester, '/rights-scenarios');

      expect(find.byType(RightsScenariosScreen), findsOneWidget);
      expect(find.text('Choose your situation'), findsOneWidget);
      expect(find.text('Stopped by Police'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // The first card is open, so offline rights are visible immediately.
      expect(find.textContaining('Article 10'), findsWidgets);

      final Finder list = scrollableIn(RightsScenariosScreen);

      // Another card can be expanded and shows its own offline guidance.
      await tester.scrollUntilVisible(
        find.text('Landlord Eviction Notice'),
        250,
        scrollable: list,
      );
      await tester.ensureVisible(find.text('Landlord Eviction Notice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Landlord Eviction Notice'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Rent Controller'), findsWidgets);
      expect(tester.takeException(), isNull);

      // The rest of the situations are present in the offline dataset.
      await tester.scrollUntilVisible(
        find.text('Workplace Harassment'),
        250,
        scrollable: list,
      );
      expect(find.text('Workplace Harassment'), findsOneWidget);

      // Tapping the first card collapses it again.
      await tester.scrollUntilVisible(
        find.text('Stopped by Police'),
        -250,
        scrollable: list,
      );
      await tester.ensureVisible(find.text('Stopped by Police'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stopped by Police'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Article 10'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final double scale in <double>[1.0, 2.0]) {
    testWidgets('Snap & Explain renders at text scale $scale', (tester) async {
      await pumpApp(tester, scale: scale);
      await openRoute(tester, '/document-explainer');

      expect(find.byType(DocumentExplainerScreen), findsOneWidget);
      expect(find.text('Snap & Explain'), findsWidgets);
      expect(find.text('Choose photo'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Explain document'),
        250,
        scrollable: scrollableIn(DocumentExplainerScreen),
      );
      await tester.ensureVisible(find.text('Explain document'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Empty submission produces a friendly validation message, not a crash.
      await tester.tap(find.text('Explain document'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.textContaining('Add a photo of the document'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });
  }

  test('vision explainer refuses to send without cloud AI enabled', () async {
    final AiFeaturesService service = AiFeaturesService(AppConfig.instance);
    final AiFeatureResult result = await service.explainDocumentImage(
      Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xE0]),
    );
    expect(result.success, isFalse);
    expect(result.offline, isTrue);
    expect(result.content, contains('Cloud AI is not enabled'));
  });

  test('vision explainer sends the image inline to Gemini', () async {
    await AppConfig.instance.update(
      cloudEnabled: true,
      geminiApiKey: 'test-key',
      selectedAiProvider: 'gemini',
    );
    addTearDown(() async {
      await AppConfig.instance.update(
        cloudEnabled: false,
        geminiApiKey: '',
        selectedAiProvider: 'gemini',
      );
    });

    late Map<String, dynamic> sentBody;
    final MockClient client = MockClient((http.Request request) async {
      sentBody = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode(<String, dynamic>{
          'candidates': <dynamic>[
            <String, dynamic>{
              'content': <String, dynamic>{
                'parts': <dynamic>[
                  <String, dynamic>{'text': 'This is a rent notice.'},
                ],
              },
            },
          ],
        }),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });

    final AiFeaturesService service = AiFeaturesService(
      AppConfig.instance,
      client: client,
    );
    final AiFeatureResult result = await service.explainDocumentImage(
      Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xE0]),
      mimeType: 'image/jpeg',
    );

    expect(result.success, isTrue);
    expect(result.content, 'This is a rent notice.');

    final List<dynamic> parts =
        (sentBody['contents'] as List<dynamic>).first['parts'] as List<dynamic>;
    expect(parts.length, 2);
    final Map<String, dynamic> inline =
        parts[1]['inlineData'] as Map<String, dynamic>;
    expect(inline['mimeType'], 'image/jpeg');
    expect((inline['data'] as String).isNotEmpty, isTrue);
  });

  test('vision explainer ignores Gemini thinking parts', () async {
    await AppConfig.instance.update(
      cloudEnabled: true,
      geminiApiKey: 'test-key',
      selectedAiProvider: 'gemini',
    );
    addTearDown(() async {
      await AppConfig.instance.update(
        cloudEnabled: false,
        geminiApiKey: '',
        selectedAiProvider: 'gemini',
      );
    });

    final MockClient client = MockClient((http.Request request) async {
      return http.Response(
        jsonEncode(<String, dynamic>{
          'candidates': <dynamic>[
            <String, dynamic>{
              'content': <String, dynamic>{
                'parts': <dynamic>[
                  <String, dynamic>{
                    'text': 'internal reasoning that must not be shown',
                    'thought': true,
                  },
                  <String, dynamic>{'text': 'Visible answer.'},
                ],
              },
            },
          ],
        }),
        200,
      );
    });

    final AiFeatureResult result = await AiFeaturesService(
      AppConfig.instance,
      client: client,
    ).explainDocumentImage(Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xE0]));

    expect(result.success, isTrue);
    expect(result.content, 'Visible answer.');
    expect(result.content, isNot(contains('internal reasoning')));
  });

  test(
    'vision explainer asks for Gemini when another provider is selected',
    () async {
      await AppConfig.instance.update(
        cloudEnabled: true,
        groqApiKey: 'test-groq-key',
        selectedAiProvider: 'groq',
      );
      addTearDown(() async {
        await AppConfig.instance.update(
          cloudEnabled: false,
          groqApiKey: '',
          selectedAiProvider: 'gemini',
        );
      });

      final AiFeaturesService service = AiFeaturesService(AppConfig.instance);
      final AiFeatureResult result = await service.explainDocumentImage(
        Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xE0]),
      );

      expect(result.success, isFalse);
      expect(result.content, contains('Gemini'));
    },
  );
}
