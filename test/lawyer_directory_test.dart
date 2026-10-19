import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice2law_app/core/app_config.dart';
import 'package:voice2law_app/core/app_scope.dart';
import 'package:voice2law_app/screens/find_lawyers_screen.dart';
import 'package:voice2law_app/data/content_data.dart';
import 'package:voice2law_app/services/lawyer_directory_service.dart';

const String _randomuserPayload = '''
{
  "results": [
    {
      "login": {"uuid": "test-uuid-1"},
      "name": {"first": "Ayesha", "last": "Khan"},
      "id": {"value": "123"},
      "location": {"city": "Lahore"}
    },
    {
      "login": {"uuid": "test-uuid-2"},
      "name": {"first": "Bilal", "last": "Ahmed"},
      "id": {"value": "124"},
      "location": {"city": "Karachi"}
    }
  ]
}
''';

http.Response _jsonResponse(String body) => http.Response.bytes(
  utf8.encode(body),
  200,
  headers: <String, String>{
    'content-type': 'application/json; charset=utf-8',
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AppConfig.instance.load();
  });

  group('LawyerDirectoryService', () {
    test('maps randomuser.me profiles to demo Lawyer cards', () async {
      final service = LawyerDirectoryService(
        client: MockClient((_) async => _jsonResponse(_randomuserPayload)),
      );
      final lawyers = await service.fetchDemoLawyers();

      expect(lawyers, hasLength(2));
      expect(lawyers[0].id, 'test-uuid-1');
      expect(lawyers[0].name, 'Ayesha Khan');
      expect(lawyers[1].id, 'test-uuid-2');
      expect(lawyers[1].name, 'Bilal Ahmed');

      for (final lawyer in lawyers) {
        expect(ContentData.cities, contains(lawyer.city));
        expect(lawyer.courtLocation, isNotEmpty);
        for (final area in lawyer.expertise) {
          expect(ContentData.expertiseAreas, contains(area));
        }
        expect(lawyer.rating, inInclusiveRange(3.6, 4.9));
        expect(lawyer.experience, inInclusiveRange(2, 28));
        expect(lawyer.languages, containsAll(<String>['Urdu', 'English']));

        // No real photos, contact details or bar council numbers.
        expect(lawyer.image, isEmpty);
        expect(lawyer.phoneNumber, isEmpty);
        expect(lawyer.whatsapp, isEmpty);
        expect(lawyer.email, isEmpty);
        expect(lawyer.barCouncilNo, isEmpty);
        expect(lawyer.verified, isFalse);
      }

      // Mapping is deterministic: the same UUID yields the same profile.
      final again = await service.fetchDemoLawyers();
      expect(again[0].city, lawyers[0].city);
      expect(again[0].expertise, lawyers[0].expertise);
    });

    test('throws a friendly exception on HTTP failure', () async {
      final service = LawyerDirectoryService(
        client: MockClient((_) async => http.Response('boom', 500)),
      );
      await expectLater(
        service.fetchDemoLawyers(),
        throwsA(isA<Exception>()),
      );
    });

    test('throws a friendly exception on transport failure', () async {
      final service = LawyerDirectoryService(
        client: MockClient((_) async => throw Exception('offline')),
      );
      await expectLater(
        service.fetchDemoLawyers(),
        throwsA(isA<Exception>()),
      );
    });
  });

  testWidgets('find lawyers screen shows demo profiles with an honest label',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final directory = LawyerDirectoryService(
      client: MockClient((_) async => _jsonResponse(_randomuserPayload)),
    );
    await tester.pumpWidget(
      AppScope(
        services: AppServices(lawyerDirectory: directory),
        child: const MaterialApp(
          home: Scaffold(body: FindLawyersScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Demo directory'), findsOneWidget);
    expect(find.text('Ayesha Khan', skipOffstage: false), findsOneWidget);
    expect(find.textContaining('2 demo profiles'), findsOneWidget);

    // Call/WhatsApp actions are present but disabled for demo profiles.
    final callButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.call).first,
        matching: find.byType(IconButton),
      ),
    );
    final whatsappButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.chat).first,
        matching: find.byType(IconButton),
      ),
    );
    expect(callButton.onPressed, isNull);
    expect(whatsappButton.onPressed, isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
