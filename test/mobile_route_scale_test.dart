import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice2law_app/app.dart';
import 'package:voice2law_app/core/app_config.dart';
import 'package:voice2law_app/core/app_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AppConfig.instance.load();
  });

  const List<String> routes = <String>[
    '/ask',
    '/find-lawyers',
    '/lawyer',
    '/legal-topics',
    '/search',
    '/about',
    '/how-it-works',
    '/contact',
    '/settings',
    '/statute-library',
    '/ai-tools',
    '/doc-generator',
    '/doc-scanner',
    '/deadline-calc',
    '/case-intake',
    '/case-prediction',
    '/rights-checker',
    '/smart-reminders',
    '/precedent-search',
    '/term-explainer',
    '/statute-ai-search',
    '/emergency-sos',
    '/scam-detector',
    '/mediation',
    '/document-explainer',
    '/rights-scenarios',
    '/admin-login',
    '/adminvoice2law001',
  ];

  for (final double scale in <double>[1.0, 2.0]) {
    for (final String route in routes) {
      testWidgets('route $route fits at ${scale}x text', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(Voice2LawApp(services: AppServices()));
        await tester.pump(const Duration(seconds: 1));
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        nav.pushNamed(route);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      });
    }
  }
}
