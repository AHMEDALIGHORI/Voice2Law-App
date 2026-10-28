import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:voice2law_app/core/app_config.dart';
import 'package:voice2law_app/core/auth_controller.dart';
import 'package:voice2law_app/core/contact_links.dart';
import 'package:voice2law_app/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AppConfig.instance.load();
    await AppConfig.instance.update(
      apiBaseUrl: 'https://test.invalid/api',
      apiToken: 'test-token',
      cloudEnabled: true,
    );
  });
  ApiService apiWithRole(String role) => ApiService(
    AppConfig.instance,
    MockClient(
      (_) async => http.Response(
        jsonEncode({
          'user': {'id': 'one', 'email': 'test@example.org', 'role': role},
        }),
        200,
      ),
    ),
  );
  test('non-admin profile cannot log in or restore as admin', () async {
    final auth = AuthController(apiWithRole('user'));
    expect(await auth.login('', ''), isFalse);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'admin_session_started',
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setString('admin_session_email', 'forged@example.org');
    await auth.restore();
    expect(auth.isAuthenticated, isFalse);
    expect(auth.isAdmin, isFalse);
    auth.dispose();
  });
  test(
    'valid role expires after thirty minutes while the app stays open',
    () async {
      var now = DateTime(2026, 10, 16);
      final auth = AuthController(apiWithRole('admin'), now: () => now);
      expect(await auth.login('', ''), isTrue);
      now = now.add(const Duration(minutes: 31));
      expect(auth.isAdmin, isFalse);
      auth.dispose();
    },
  );
  test(
    'five failures lock out and the lock expires after fifteen minutes',
    () async {
      var now = DateTime(2026, 10, 16);
      final auth = AuthController(apiWithRole('user'), now: () => now);
      for (var i = 0; i < 5; i++) {
        expect(await auth.login('', ''), isFalse);
      }
      expect(auth.isLocked, isTrue);
      now = now.add(const Duration(minutes: 16));
      expect(auth.isLocked, isFalse);
      await auth.login('', '');
      expect(auth.failedAttempts, 1);
      auth.dispose();
    },
  );
  test('network failures cannot lock the admin out', () async {
    final api = ApiService(
      AppConfig.instance,
      MockClient((_) async => throw http.ClientException('offline')),
    );
    final auth = AuthController(api);
    for (var i = 0; i < 7; i++) {
      expect(await auth.login('', ''), isFalse);
    }
    expect(auth.failedAttempts, 0);
    expect(auth.isLocked, isFalse);
    expect(auth.error, contains('Cannot reach the server'));
    auth.dispose();
  });
  test('restoration revalidates server identity', () async {
    var calls = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'admin_session_started',
      DateTime.now().millisecondsSinceEpoch,
    );
    final api = ApiService(
      AppConfig.instance,
      MockClient((_) async {
        calls++;
        return http.Response('', 403);
      }),
    );
    final auth = AuthController(api);
    await auth.restore();
    expect(calls, 1);
    expect(auth.isAdmin, isFalse);
    auth.dispose();
  });
  test(
    'voice payload retains rich fields while supplying missing transcript',
    () async {
      final api = ApiService(
        AppConfig.instance,
        MockClient(
          (_) async => http.Response(
            jsonEncode({
              'answer': 'Answer',
              'offline': true,
              'courtModeAnswer': 'Court analysis',
              'urgencyLevel': 'urgent',
              'empatheticOpening': 'Opening',
              'suggestedEmergencyHelpline': 'server value',
              'roadmap': [
                {'title': 'Step'},
              ],
              'documents': [
                {'name': 'Document'},
              ],
              'statutes': [
                {'actName': 'Act', 'section': '7'},
              ],
            }),
            200,
          ),
        ),
      );
      final answer = await api.askVoice(transcript: 'Captured words');
      expect(answer.transcript, 'Captured words');
      expect(answer.courtModeAnswer, 'Court analysis');
      expect(answer.urgencyLevel, 'urgent');
      expect(answer.empatheticOpening, 'Opening');
      expect(answer.suggestedEmergencyHelpline, 'server value');
      expect(answer.roadmap, hasLength(1));
      expect(answer.documents, hasLength(1));
      expect(answer.statutes, hasLength(1));
      expect(answer.offline, isTrue);
    },
  );
  test('contact links reject injected URI payloads', () {
    expect(ContactLinks.tel('123'), isNull);
    expect(
      ContactLinks.tel('0300-1234567;foo'),
      Uri(scheme: 'tel', path: '03001234567'),
    );
    expect(ContactLinks.mailto('a@b.c?bcc=attacker@evil.com'), isNull);
    expect(ContactLinks.mailto('not-an-email'), isNull);
    expect(
      ContactLinks.whatsapp('+92 300 1234567'),
      Uri.parse('https://wa.me/923001234567'),
    );
  });
}
