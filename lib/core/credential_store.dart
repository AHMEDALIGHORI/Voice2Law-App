import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mobile credentials use Keychain/Keystore; browser credentials are session-only.
class CredentialStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final Map<String, String> _webSession = <String, String>{};
  Future<String?> read(String key) async =>
      kIsWeb ? _webSession[key] : _storage.read(key: key);
  Future<void> write(String key, String value) async {
    if (kIsWeb) {
      _webSession[key] = value;
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  Future<void> delete(String key) async {
    if (kIsWeb) {
      _webSession.remove(key);
    } else {
      await _storage.delete(key: key);
    }
  }
}
