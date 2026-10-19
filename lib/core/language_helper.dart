import 'dart:ui' show Locale, PlatformDispatcher;

import 'app_config.dart';

/// Metadata for one supported UI language.
class LangMeta {
  const LangMeta({
    required this.code,
    required this.label,
    required this.nativeLabel,
    required this.bcp47Stt,
    required this.bcp47Tts,
    required this.rtl,
    required this.fontFamily,
  });

  /// Short code stored in [AppConfig.languagePreference]: 'en','ur','pa','sd','ps'.
  final String code;

  /// English display name.
  final String label;

  /// Native script name shown in the language switcher.
  final String nativeLabel;

  /// BCP-47 tag tried with the device STT engine.
  final String bcp47Stt;

  /// BCP-47 tag tried with the device TTS engine.
  final String bcp47Tts;

  /// Whether this language uses right-to-left layout.
  final bool rtl;

  /// Flutter font family name for this script (must match pubspec.yaml).
  /// Null means use the system default.
  final String? fontFamily;
}

/// All languages supported by Voice2Law, in display order.
const List<LangMeta> kSupportedLanguages = <LangMeta>[
  LangMeta(
    code: 'en',
    label: 'English',
    nativeLabel: 'English',
    bcp47Stt: 'en-US',
    bcp47Tts: 'en-US',
    rtl: false,
    fontFamily: null,
  ),
  LangMeta(
    code: 'ur',
    label: 'Urdu',
    nativeLabel: 'اردو',
    bcp47Stt: 'ur-PK',
    bcp47Tts: 'ur-PK',
    rtl: true,
    fontFamily: 'NotoNastaliqUrdu',
  ),
  LangMeta(
    code: 'pa',
    label: 'Punjabi',
    nativeLabel: 'پنجابی',
    bcp47Stt: 'pa-PK',
    bcp47Tts: 'pa-PK',
    rtl: true,
    fontFamily: 'NotoNastaliqUrdu', // Shahmukhi uses same Nastaliq font
  ),
  LangMeta(
    code: 'sd',
    label: 'Sindhi',
    nativeLabel: 'سنڌي',
    bcp47Stt: 'sd-PK',
    bcp47Tts: 'sd-PK',
    rtl: true,
    fontFamily: 'NotoNastaliqUrdu',
  ),
  LangMeta(
    code: 'ps',
    label: 'Pashto',
    nativeLabel: 'پښتو',
    bcp47Stt: 'ps-PK',
    bcp47Tts: 'ps-PK',
    rtl: true,
    fontFamily: 'NotoNastaliqUrdu',
  ),
];

/// Resolves effective UI language and provides locale helpers for all
/// Pakistani languages supported by Voice2Law.
class LanguageHelper {
  const LanguageHelper._();

  // ── Lookup helpers ───────────────────────────────────────────────────────

  /// Returns the [LangMeta] for [code], or English if not found.
  static LangMeta metaFor(String code) =>
      kSupportedLanguages.firstWhere(
        (LangMeta m) => m.code == code,
        orElse: () => kSupportedLanguages.first,
      );

  // ── Resolution ───────────────────────────────────────────────────────────

  /// Resolves a preference string to a definite language code.
  ///
  /// [preference] may be `'en'`, `'ur'`, `'pa'`, `'sd'`, `'ps'`, or `'auto'`.
  /// When `'auto'` the device locale list is inspected; the first BCP-47
  /// language tag that matches a supported language wins, otherwise `'en'`.
  static String resolve(String preference) {
    if (preference != 'auto') {
      if (kSupportedLanguages.any((LangMeta m) => m.code == preference)) {
        return preference;
      }
      return 'en';
    }
    // 'auto' — check device locales in order.
    for (final Locale locale in PlatformDispatcher.instance.locales) {
      final String tag = locale.languageCode.toLowerCase();
      for (final LangMeta meta in kSupportedLanguages) {
        if (meta.code == tag) return meta.code;
      }
    }
    return 'en';
  }

  /// Convenience — returns `true` when the resolved language uses RTL layout.
  static bool isRtl(String preference) => metaFor(resolve(preference)).rtl;

  /// Convenience — returns `true` when [config.languagePreference] resolves
  /// to Urdu.
  static bool isUrdu(AppConfig config) =>
      resolve(config.languagePreference) == 'ur';

  /// Convenience — returns `true` when the resolved language is NOT English.
  static bool isRegional(String preference) =>
      resolve(preference) != 'en';

  // ── Locale strings ───────────────────────────────────────────────────────

  /// BCP-47 locale for STT, respecting any explicit setting in [configSttLocale].
  ///
  /// If [configSttLocale] is `'auto'` the locale is derived from [langCode].
  /// An explicit value (e.g. `'ur_PK'`) always wins.
  static String sttLocaleFor(String langCode, String configSttLocale) {
    if (configSttLocale != 'auto') return configSttLocale;
    return metaFor(langCode).bcp47Stt;
  }

  /// BCP-47 locale for TTS.
  ///
  /// When [langCode] is `'ur'` and the device has a detected Urdu voice at
  /// [urduVoiceLocale], that specific tag is preferred over the default.
  /// For other regional languages we use the canonical tag from [LangMeta]
  /// and rely on device best-effort.
  static String ttsLocaleFor(String langCode, String? urduVoiceLocale) {
    if (langCode == 'ur') return urduVoiceLocale ?? 'ur-PK';
    return metaFor(langCode).bcp47Tts;
  }

  // ── Answer field selection ───────────────────────────────────────────────

  /// Picks the correct localised answer text from [answer] for [langCode].
  ///
  /// Falls back to English if the regional field is empty.
  static String answerFor({
    required String langCode,
    required String english,
    required String urdu,
    required String punjabi,
    required String sindhi,
    required String pashto,
  }) {
    switch (langCode) {
      case 'ur':
        return urdu.isNotEmpty ? urdu : english;
      case 'pa':
        return punjabi.isNotEmpty ? punjabi : english;
      case 'sd':
        return sindhi.isNotEmpty ? sindhi : english;
      case 'ps':
        return pashto.isNotEmpty ? pashto : english;
      default:
        return english;
    }
  }
}
