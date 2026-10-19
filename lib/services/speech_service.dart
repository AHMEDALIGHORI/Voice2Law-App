import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps the device microphone (speech_to_text) and the device voice
/// (flutter_tts) that power the Voice2Law voice assistant.
///
/// The website simulated recording + transcription (`VoiceBot.tsx` used random
/// waveform levels and a fixed transcript). The mobile app performs real
/// speech recognition, and degrades to a typed transcript when the device has
/// no speech-recognition service (common on emulators / desktop browsers).
class SpeechService {
  SpeechService();

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechAvailable = false;
  bool _ttsReady = false;
  String? _ttsLocale;
  String? _urduLocale;
  bool _micPermissionGranted = true;
  int _activityEpoch = 0;

  bool get speechAvailable => _speechAvailable;
  bool get isListening => _speech.isListening;
  bool get ttsReady => _ttsReady;
  String? get ttsLocale => _ttsLocale;

  /// Locale of an installed Urdu voice, if the device has one.
  String? get urduVoiceLocale => _urduLocale;

  /// False when Android denied (or never granted) RECORD_AUDIO. The UI uses
  /// this to explain why the mic is dead and to point at the typed fallback.
  bool get micPermissionGranted => _micPermissionGranted;

  void Function(String message)? onError;

  /// Prepares both engines. Returns true when the microphone recogniser is
  /// usable; the caller should then show the manual transcript fallback when
  /// this returns false.
  Future<bool> init() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (SpeechRecognitionError error) =>
            onError?.call(_friendlyError(error)),
        onStatus: (String status) {
          if (status == 'done' || status == 'notListening') {
            // The OS closed the recogniser on its own (silence timeout).
            _onAutoStop?.call();
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }

    // `initialize` triggers the Android runtime prompt for RECORD_AUDIO. If the
    // user declined, the recogniser initialises but stays silent - detect that
    // so the screen can explain the problem instead of showing a dead mic.
    {
      try {
        _micPermissionGranted = await _speech.hasPermission;
      } catch (_) {
        _micPermissionGranted = true; // not Android; nothing to check
      }
    }

    await _initTts();
    return _speechAvailable && _micPermissionGranted;
  }

  /// Turns raw plugin errors into something a non-technical user can act on.
  /// (speech_to_text 7.x exposes only `errorMsg` + `permanent`, so the message
  /// text is the signal we have to work with.)
  String _friendlyError(SpeechRecognitionError error) {
    final String raw = error.errorMsg;
    final String low = raw.toLowerCase();
    if (low.contains('permission') ||
        low.contains('denied') ||
        low.contains('record_audio')) {
      return 'Microphone permission is off. Allow it in Settings > Apps > '
          'Voice2Law > Permissions, or type your question below.';
    }
    if (low.contains('network') || low.contains('internet')) {
      return 'Speech recognition needs internet on this device. Check your '
          'connection, or type your question below.';
    }
    if (low.contains('no_match') ||
        low.contains('no match') ||
        low.contains('not recognized')) {
      return 'No speech was recognised. Tap the mic and speak a little closer '
          'to the phone, or type your question below.';
    }
    if (low.contains('no speech') || low.contains('no activity')) {
      return 'No speech-recognition app is installed. Install Google app or '
          '"Speech Recognition & Synthesis", or type your question below.';
    }
    return raw.isEmpty
        ? 'Speech recognition error. You can type your question below.'
        : raw;
  }

  Future<void> _initTts() async {
    try {
      _urduLocale = await _findUrduLocale();
      if (kIsWeb) {
        await _tts.setLanguage('en-US');
        _ttsLocale = 'en-US';
      } else {
        // Prefer Urdu output, exactly like the website promises ("answers in
        // Urdu or English"). Most phones ship an Urdu voice; when they do not
        // we fall back to English pronunciation.
        _ttsLocale = _urduLocale ?? 'en-US';
        await _tts.setLanguage(_ttsLocale!);
        await _trySelectVoice(_ttsLocale!);
      }
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
    }
  }

  /// Finds an Urdu voice across the locale spellings different engines use.
  Future<String?> _findUrduLocale() async {
    for (final String candidate in <String>['ur-PK', 'ur', 'ur-IN']) {
      try {
        final dynamic available = await _tts.isLanguageAvailable(candidate);
        if (available == true || available == 1) return candidate;
      } catch (_) {
        // Engine does not answer availability for this tag.
      }
    }
    return null;
  }

  /// Some Android engines ignore `setLanguage` for less common locales and
  /// only actually switch when an explicit voice is selected.
  Future<void> _trySelectVoice(String locale) async {
    try {
      final dynamic voices = await _tts.getVoices;
      if (voices is! List) return;
      final String lang = locale.split('-').first.toLowerCase();
      for (final dynamic voice in voices) {
        if (voice is! Map) continue;
        final Map<String, String> flat = <String, String>{
          for (final MapEntry<dynamic, dynamic> entry in voice.entries)
            entry.key.toString(): entry.value.toString(),
        };
        final String? voiceLocale = flat['locale'] ?? flat['language'];
        if (voiceLocale != null && voiceLocale.toLowerCase().startsWith(lang)) {
          await _tts.setVoice(flat);
          return;
        }
      }
    } catch (_) {
      // Voice selection is best-effort.
    }
  }

  void Function()? _onAutoStop;

  /// Lists the locales the OS recogniser can handle (used by Settings).
  Future<List<String>> locales() async {
    try {
      final List<LocaleName> names = await _speech.locales();
      return names.map((LocaleName name) => name.localeId).toList()..sort();
    } catch (_) {
      return <String>[];
    }
  }

  /// Starts streaming recognition. [onPartial] fires for live captions,
  /// [onSoundLevel] receives a 0..1 loudness value for the waveform bars and
  /// [onDone] is called when the OS stops listening by itself.
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(double level)? onSoundLevel,
    void Function()? onDone,
    String? localeId,
  }) async {
    _onAutoStop = onDone;
    if (!_speechAvailable) {
      onError?.call('Speech recognition is not available on this device.');
      onDone?.call();
      return;
    }
    try {
      // Validate that the requested locale is actually supported by the
      // device before passing it to the engine. If not, fall back to null
      // (device default) so recognition still works.
      String? resolvedLocale = localeId;
      if (resolvedLocale != null) {
        try {
          final List<LocaleName> available = await _speech.locales();
          final Set<String> known = <String>{
            for (final LocaleName n in available)
              n.localeId,
          };
          // Try exact match and also try with '-' vs '_' variants.
          final String alt =
              resolvedLocale.replaceAll('_', '-');
          if (!known.contains(resolvedLocale) &&
              !known.contains(alt)) {
            // Locale not supported — let the device pick its own.
            debugPrint(
              '[SpeechService] Locale "$resolvedLocale" not available on '
              'this device, falling back to default.',
            );
            resolvedLocale = null;
          }
        } catch (_) {
          // Can't enumerate locales — try the requested one anyway.
        }
      }

      await _speech.listen(
        onResult: (SpeechRecognitionResult result) =>
            onResult(result.recognizedWords, result.finalResult),
        onSoundLevelChange: (double level) {
          // speech_to_text reports roughly -2..10 dB.
          final double normalised = ((level + 2) / 12).clamp(0.0, 1.0);
          onSoundLevel?.call(normalised);
        },
        listenOptions: SpeechListenOptions(
          localeId: resolvedLocale,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
      );
    } catch (error) {
      onError?.call('Could not start the microphone: $error');
      onDone?.call();
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speech.isListening) await _speech.stop();
    } catch (_) {
      // Recognition already stopped.
    }
  }

  Future<void> cancelListening() async {
    try {
      if (_speech.isListening) await _speech.cancel();
    } catch (_) {
      // Recognition already stopped.
    }
  }

  /// Reads a legal answer out loud. The speaking language is chosen from the
  /// [locale] argument or auto-detected from the script of [text]. When the
  /// device lacks a voice for the requested language, the method attempts
  /// the best available fallback rather than silently failing.
  Future<void> speak(String text, {String? locale}) async {
    final activityEpoch = _activityEpoch;
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;
    try {
      if (!_ttsReady) await _initTts();

      // Determine the target locale.
      final String requested = locale ?? _localeForText(trimmed);

      // Check if the requested locale is available. If not, try fallbacks
      // rather than blocking entirely.
      String target = requested;
      bool localeAvailable = await _isLocaleAvailable(target);

      if (!localeAvailable) {
        // Try Urdu voice as fallback for any Arabic-script text.
        if (_urduLocale != null) {
          target = _urduLocale!;
          localeAvailable = await _isLocaleAvailable(target);
        }
        // If Urdu isn't available either, try English.
        if (!localeAvailable) {
          target = 'en-US';
          localeAvailable = await _isLocaleAvailable(target);
        }
        // If nothing is available, inform the user.
        if (!localeAvailable) {
          onError?.call(
            'No text-to-speech voice is installed for this language. '
            'Install a TTS voice in your device Settings, or read the '
            'answer on screen.',
          );
          return;
        }
      }

      await _tts.setLanguage(target);
      await _trySelectVoice(target);
      if (activityEpoch != _activityEpoch) return;
      await _tts.speak(trimmed);
    } catch (error) {
      onError?.call('Text-to-speech failed: $error');
    }
  }

  /// Checks whether the TTS engine has a voice for [locale].
  Future<bool> _isLocaleAvailable(String locale) async {
    try {
      final dynamic available = await _tts.isLanguageAvailable(locale);
      return available == true || available == 1;
    } catch (_) {
      return false;
    }
  }

  /// Picks the best voice for a text: Urdu script -> Urdu voice when present.
  String _localeForText(String text) {
    final bool hasUrduScript = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    if (hasUrduScript && _urduLocale != null) return _urduLocale!;
    return hasUrduScript ? (_urduLocale ?? 'ur-PK') : 'en-US';
  }

  Future<void> stopSpeaking() async {
    _activityEpoch++;
    try {
      await _tts.stop();
    } catch (_) {
      // Nothing was speaking.
    }
  }

  Future<void> silence() async {
    _activityEpoch++;
    _onAutoStop = null;
    onError = null;
    await Future.wait([cancelListening(), stopSpeaking()]);
  }

  Future<void> dispose() async {
    await cancelListening();
    await stopSpeaking();
    // This instance is a shared singleton owned by [AppServices], so a screen
    // must not hard-dispose it. When a screen does release it (or when the app
    // tears down), drop the screen-bound callbacks first — otherwise a late
    // speech error or auto-stop would fire on an already-disposed State and
    // crash with "setState() called after dispose()".
    onError = null;
    _onAutoStop = null;
  }
}
