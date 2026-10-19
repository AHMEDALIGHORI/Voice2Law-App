import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice2law_app/app.dart';
import 'package:voice2law_app/core/app_scope.dart';
import 'package:voice2law_app/core/app_config.dart';
import 'package:voice2law_app/models/models.dart';
import 'package:voice2law_app/services/speech_service.dart';
import 'package:voice2law_app/widgets/legal_ux_components.dart';
import 'package:voice2law_app/screens/calculator_camo_screen.dart';

class FakeSpeech extends SpeechService {
  bool stopped = false;
  @override
  Future<void> silence() async {
    stopped = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AppConfig.instance.load();
  });
  for (final scale in [1.0, 2.0]) {
    testWidgets('mobile home fits 390px at text scale $scale', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(Voice2LawApp(services: AppServices()));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
  for (final scale in [1.0, 2.0]) {
    testWidgets('text answer remains readable at mobile scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(Voice2LawApp(services: AppServices()));
      await tester.pump(const Duration(seconds: 1));
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.pushNamed('/text');
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.byType(TextField).first,
        'What are tenant rights?',
      );
      await tester.tap(find.byTooltip('Send question'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Offline library'), 160,
        scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first,
      );
      expect(find.text('Offline library'), findsWidgets);
      expect(find.textContaining('% confidence'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }

  for (final scale in [1.0, 2.0]) {
    testWidgets('voice assistant fits 390px at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(Voice2LawApp(services: AppServices()));
      await tester.pump(const Duration(seconds: 1));
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.pushNamed('/voice');
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);

      // Tests have no microphone, so the manual text fallback is available.
      // Submit a question to exercise the answer card at the current scale.
      final Finder manualField = find.byType(TextField);
      if (manualField.evaluate().isNotEmpty) {
        await tester.enterText(manualField.first, 'What are tenant rights?');
        await tester.tap(find.text('Send as voice query'));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }

  testWidgets(
    'quick exit clears conversation, stops audio and removes prior route',
    (tester) async {
      final speech = FakeSpeech();
      final services = AppServices(speech: speech);
      services.conversation.messages.add(
        ChatMessage(id: 'private', isUser: true, text: 'Sensitive question'),
      );
      await tester.pumpWidget(
        AppScope(
          services: services,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => DiscreetModeDialog.triggerPanicExit(context),
                  child: const Text('Exit now'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Exit now'));
      await tester.pumpAndSettle();
      expect(speech.stopped, isTrue);
      expect(
        services.conversation.messages.any((m) => m.id == 'private'),
        isFalse,
      );
      expect(find.byType(CalculatorCamoScreen), findsOneWidget);
      expect(find.text('Exit now'), findsNothing);
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      expect(nav.canPop(), isFalse);
    },
  );
}
