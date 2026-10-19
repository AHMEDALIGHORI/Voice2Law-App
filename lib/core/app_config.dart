import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'credential_store.dart';

/// Runtime application configuration.
///
/// Everything here mirrors a `VITE_*` value from the website `.env` file:
/// the web build reads `VITE_API_BASE_URL`, the mobile build lets the user
/// change the same value from the in-app Settings screen (and remembers it).
class AppConfig extends ChangeNotifier {
  AppConfig._();

  static final AppConfig instance = AppConfig._();

  static const String _kApiBaseUrl = 'api_base_url';
  static const String _kApiToken = 'api_token';
  static const String _kUserName = 'user_name';
  static const String _kUserEmail = 'user_email';
  static const String _kTtsEnabled = 'tts_enabled';
  static const String _kSttLocale = 'stt_locale';
  static const String _kAdminName = 'admin_name';
  static const String _kGeminiApiKey = 'gemini_api_key';
  static const String _kGroqApiKey = 'groq_api_key';
  static const String _kSeenaApiKey = 'seena_api_key';
  static const String _kSeenaBaseUrl = 'seena_base_url';
  static const String _kSelectedAiProvider = 'selected_ai_provider';
  static const String _kDirectAiEnabled = 'direct_ai_enabled';
  static const String _kLanguagePreference = 'language_preference';

  /// Default REST base URL.
  ///
  /// Android emulators cannot reach the host machine through `localhost`,
  /// they need the special loopback address `10.0.2.2` (the web app just
  /// defaults to `/api`). On a real phone set this to your PC LAN IP, e.g.
  /// `http://192.168.1.20:5000/api`, inside the app Settings screen.
  static const String defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String defaultGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
  );
  static const String defaultGroqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
  );
  static const String defaultSeenaApiKey = String.fromEnvironment(
    'SEENA_API_KEY',
  );
  static const String defaultSeenaBaseUrl = String.fromEnvironment(
    'SEENA_BASE_URL',
  );

  /// True when the build was compiled with at least one demo key.
  static bool get hasBuiltInAiKey =>
      defaultGeminiApiKey.isNotEmpty ||
      defaultGroqApiKey.isNotEmpty ||
      defaultSeenaApiKey.isNotEmpty;

  /// Provider used for a fresh install / demo build.
  static String get defaultAiProvider {
    if (defaultGeminiApiKey.isNotEmpty) return 'gemini';
    if (defaultGroqApiKey.isNotEmpty) return 'groq';
    return 'gemini';
  }

  final CredentialStore _credentials = CredentialStore();
  bool cloudEnabled = false;
  bool localLanguagesEnabled = false;
  String localLanguageUrl = '';
  String localLanguageKey = '';

  String apiBaseUrl = defaultApiBaseUrl;
  String apiToken = '';
  String userName = 'Anonymous';
  String userEmail = 'anonymous@voice2law.local';
  bool ttsEnabled = false;
  String sttLocale = 'auto';
  String adminName = 'Voice2Law Admin';
  String geminiApiKey = defaultGeminiApiKey;
  String groqApiKey = defaultGroqApiKey;
  String seenaApiKey = defaultSeenaApiKey;
  String seenaBaseUrl = defaultSeenaBaseUrl;

  /// Selected AI provider: 'gemini' | 'groq' | 'seena'.
  String selectedAiProvider = defaultAiProvider;
  bool directAiEnabled = true;

  /// UI language: `'en'` (English), `'ur'` (Urdu), or `'auto'` (device locale).
  /// Defaults to `'en'` if unset or unreadable.
  String languagePreference = 'en';

  /// Returns the API key for the currently selected provider.
  String get activeAiApiKey {
    switch (selectedAiProvider) {
      case 'groq':
        return groqApiKey;
      case 'seena':
        return seenaApiKey;
      case 'gemini':
      default:
        return geminiApiKey;
    }
  }

  /// Returns true when the selected provider has a non-empty API key.
  bool get hasActiveAiKey => activeAiApiKey.trim().isNotEmpty;

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    apiBaseUrl = prefs.getString(_kApiBaseUrl) ?? defaultApiBaseUrl;
    // Discard legacy plaintext credentials rather than retaining the bundled key.
    await prefs.remove(_kApiToken);
    await prefs.remove(_kGeminiApiKey);
    apiToken = await _credentials.read(_kApiToken) ?? '';
    cloudEnabled = prefs.getBool('cloud_enabled') ?? hasBuiltInAiKey;
    localLanguagesEnabled = prefs.getBool('local_languages_enabled') ?? false;
    localLanguageUrl = prefs.getString('local_language_url') ?? '';
    localLanguageKey = await _credentials.read('local_language_key') ?? '';
    userName = prefs.getString(_kUserName) ?? 'Anonymous';
    userEmail = prefs.getString(_kUserEmail) ?? 'anonymous@voice2law.local';
    ttsEnabled = prefs.getBool(_kTtsEnabled) ?? false;
    sttLocale = prefs.getString(_kSttLocale) ?? 'auto';
    adminName = prefs.getString(_kAdminName) ?? 'Voice2Law Admin';
    geminiApiKey =
        await _credentials.read(_kGeminiApiKey) ?? defaultGeminiApiKey;
    groqApiKey = await _credentials.read(_kGroqApiKey) ?? defaultGroqApiKey;
    seenaApiKey = await _credentials.read(_kSeenaApiKey) ?? defaultSeenaApiKey;
    seenaBaseUrl = prefs.getString(_kSeenaBaseUrl) ?? defaultSeenaBaseUrl;
    selectedAiProvider =
        prefs.getString(_kSelectedAiProvider) ?? defaultAiProvider;
    directAiEnabled = prefs.getBool(_kDirectAiEnabled) ?? true;
    languagePreference = prefs.getString(_kLanguagePreference) ?? 'en';
    notifyListeners();
  }

  Future<void> update({
    String? apiBaseUrl,
    String? apiToken,
    String? userName,
    String? userEmail,
    bool? ttsEnabled,
    String? sttLocale,
    String? adminName,
    String? geminiApiKey,
    String? groqApiKey,
    String? seenaApiKey,
    String? seenaBaseUrl,
    String? selectedAiProvider,
    bool? directAiEnabled,
    bool? cloudEnabled,
    String? languagePreference,
    bool? localLanguagesEnabled,
    String? localLanguageUrl,
    String? localLanguageKey,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (localLanguagesEnabled != null) {
      this.localLanguagesEnabled = localLanguagesEnabled;
      await prefs.setBool('local_languages_enabled', localLanguagesEnabled);
    }
    if (localLanguageUrl != null) {
      this.localLanguageUrl = localLanguageUrl.trim();
      await prefs.setString('local_language_url', this.localLanguageUrl);
    }
    if (localLanguageKey != null) {
      this.localLanguageKey = localLanguageKey.trim();
      await _credentials.write('local_language_key', this.localLanguageKey);
    }
    if (apiBaseUrl != null) {
      this.apiBaseUrl = _normalise(apiBaseUrl);
      await prefs.setString(_kApiBaseUrl, this.apiBaseUrl);
    }
    if (apiToken != null) {
      this.apiToken = apiToken.trim();
      await _credentials.write(_kApiToken, this.apiToken);
    }
    if (userName != null) {
      this.userName = userName.trim().isEmpty ? 'Anonymous' : userName.trim();
      await prefs.setString(_kUserName, this.userName);
    }
    if (userEmail != null) {
      this.userEmail = userEmail.trim();
      await prefs.setString(_kUserEmail, this.userEmail);
    }
    if (ttsEnabled != null) {
      this.ttsEnabled = ttsEnabled;
      await prefs.setBool(_kTtsEnabled, ttsEnabled);
    }
    if (sttLocale != null) {
      this.sttLocale = sttLocale;
      await prefs.setString(_kSttLocale, sttLocale);
    }
    if (adminName != null) {
      this.adminName = adminName.trim().isEmpty
          ? 'Voice2Law Admin'
          : adminName.trim();
      await prefs.setString(_kAdminName, this.adminName);
    }
    if (geminiApiKey != null) {
      this.geminiApiKey = geminiApiKey.trim();
      await _credentials.write(_kGeminiApiKey, this.geminiApiKey);
    }
    if (groqApiKey != null) {
      this.groqApiKey = groqApiKey.trim();
      await _credentials.write(_kGroqApiKey, this.groqApiKey);
    }
    if (seenaApiKey != null) {
      this.seenaApiKey = seenaApiKey.trim();
      await _credentials.write(_kSeenaApiKey, this.seenaApiKey);
    }
    if (seenaBaseUrl != null) {
      this.seenaBaseUrl = seenaBaseUrl.trim();
      await prefs.setString(_kSeenaBaseUrl, this.seenaBaseUrl);
    }
    if (selectedAiProvider != null) {
      final String provider = selectedAiProvider.trim();
      if (<String>['gemini', 'groq', 'seena'].contains(provider)) {
        this.selectedAiProvider = provider;
        await prefs.setString(_kSelectedAiProvider, provider);
      }
    }
    if (cloudEnabled != null) {
      this.cloudEnabled = cloudEnabled;
      await prefs.setBool('cloud_enabled', cloudEnabled);
    }
    if (directAiEnabled != null) {
      this.directAiEnabled = directAiEnabled;
      await prefs.setBool(_kDirectAiEnabled, directAiEnabled);
    }
    if (languagePreference != null) {
      final String lp = languagePreference.trim();
      if (<String>['en', 'ur', 'pa', 'sd', 'ps', 'auto'].contains(lp)) {
        this.languagePreference = lp;
        await prefs.setString(_kLanguagePreference, lp);
      }
    }
    notifyListeners();
  }

  Future<void> reset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (final key in [
      _kApiBaseUrl,
      _kApiToken,
      _kGeminiApiKey,
      _kGroqApiKey,
      _kSeenaApiKey,
      _kUserName,
      _kUserEmail,
      _kTtsEnabled,
      _kSttLocale,
      _kAdminName,
      _kDirectAiEnabled,
      _kLanguagePreference,
      'cloud_enabled',
      'local_languages_enabled',
      'local_language_url',
      _kSeenaBaseUrl,
      _kSelectedAiProvider,
      'admin_session_started',
      'admin_session_email',
      'admin_session_name',
    ]) {
      await prefs.remove(key);
    }
    await _credentials.delete(_kApiToken);
    await _credentials.delete(_kGeminiApiKey);
    await _credentials.delete(_kGroqApiKey);
    await _credentials.delete(_kSeenaApiKey);
    await _credentials.delete('local_language_key');
    localLanguagesEnabled = false;
    localLanguageUrl = '';
    localLanguageKey = '';
    seenaBaseUrl = defaultSeenaBaseUrl;
    cloudEnabled = false;
    apiBaseUrl = defaultApiBaseUrl;
    apiToken = '';
    userName = 'Anonymous';
    userEmail = 'anonymous@voice2law.local';
    ttsEnabled = false;
    sttLocale = 'auto';
    adminName = 'Voice2Law Admin';
    geminiApiKey = defaultGeminiApiKey;
    groqApiKey = defaultGroqApiKey;
    seenaApiKey = defaultSeenaApiKey;
    selectedAiProvider = defaultAiProvider;
    directAiEnabled = true;
    languagePreference = 'en';
    notifyListeners();
  }

  static String _normalise(String value) {
    String url = value.trim();
    if (url.isEmpty) return defaultApiBaseUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.scheme != 'https' && !(kDebugMode && uri.scheme == 'http'))) {
      throw const FormatException(
        'Enter a valid HTTPS server URL without credentials or query parameters.',
      );
    }
    return url;
  }
}
