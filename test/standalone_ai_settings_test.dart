import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice2law_app/core/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AppConfig.instance.load();
  });
  test('default installation has no credential and cloud is off', () {
    expect(AppConfig.instance.geminiApiKey, isEmpty);
    expect(AppConfig.instance.apiToken, isEmpty);
    expect(AppConfig.instance.cloudEnabled, isFalse);
  });
  test('credentials persist securely, not in SharedPreferences', () async {
    final config = AppConfig.instance;
    await config.update(
      geminiApiKey: 'test-key',
      apiToken: 'test-token',
      cloudEnabled: true,
    );
    await config.load();
    expect(config.geminiApiKey, 'test-key');
    expect(config.apiToken, 'test-token');
    expect(config.cloudEnabled, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('gemini_api_key'), isFalse);
    expect(prefs.containsKey('api_token'), isFalse);
  });
  test('legacy plaintext credentials are removed and not reused', () async {
    SharedPreferences.setMockInitialValues({
      'gemini_api_key': 'legacy-key',
      'api_token': 'legacy-token',
    });
    await AppConfig.instance.load();
    expect(AppConfig.instance.geminiApiKey, isEmpty);
    expect(AppConfig.instance.apiToken, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('gemini_api_key'), isFalse);
  });
  test(
    'reset clears credentials, consent and session but preserves lockout',
    () async {
      final config = AppConfig.instance;
      await config.update(geminiApiKey: 'test-key', cloudEnabled: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('admin_locked_until', 123);
      await config.reset();
      await config.load();
      expect(config.geminiApiKey, isEmpty);
      expect(config.cloudEnabled, isFalse);
      expect(prefs.getInt('admin_locked_until'), 123);
    },
  );
  test('server URL rejects embedded credentials', () async {
    expect(
      () => AppConfig.instance.update(
        apiBaseUrl: 'https://user:password@example.org/api',
      ),
      throwsFormatException,
    );
  });

  test('Seena base URL is validated and normalised', () async {
    final config = AppConfig.instance;
    await expectLater(
      config.update(seenaBaseUrl: 'ftp://example.org'),
      throwsFormatException,
    );
    await expectLater(
      config.update(seenaBaseUrl: 'https://user:pass@example.org'),
      throwsFormatException,
    );
    await config.update(seenaBaseUrl: 'https://api.seena.example/');
    expect(config.seenaBaseUrl, 'https://api.seena.example');
    await config.update(seenaBaseUrl: '');
    expect(config.seenaBaseUrl, isEmpty);
  });

  test('a rejected endpoint does not persist earlier fields', () async {
    final config = AppConfig.instance;
    await expectLater(
      config.update(
        userName: 'Should Not Persist',
        apiBaseUrl: 'https://user:password@example.org/api',
      ),
      throwsFormatException,
    );
    expect(config.userName, 'Anonymous');
  });
}
