import '../core/app_config.dart';
import '../core/app_scope.dart';
import '../models/models.dart';
import 'direct_gemini_service.dart';
import 'groq_service.dart';
import 'local_legal_brain.dart';
import 'seena_service.dart';

/// Unified AI service that routes requests to the currently selected provider
/// (Gemini, Groq, or Seena). All providers share the same [AiAnswer] return
/// type and fall back to [LocalLegalBrain] when offline or misconfigured.
class MultiProviderAiService {
  MultiProviderAiService(this._config, {this.gemini, this.groq, this.seena});

  final AppConfig _config;
  final DirectGeminiService? gemini;
  final GroqService? groq;
  final SeenaService? seena;

  /// Creates a service backed by [AppScope] services.
  factory MultiProviderAiService.fromScope(AppServices services) =>
      MultiProviderAiService(
        services.config,
        gemini: services.gemini,
        groq: GroqService(services.config),
        seena: SeenaService(services.config),
      );

  /// The currently selected provider name: 'gemini' | 'groq' | 'seena'.
  String get selectedProvider => _config.selectedAiProvider;

  /// Last recorded status for the active provider.
  String? get lastStatus {
    switch (_config.selectedAiProvider) {
      case 'groq':
        return groq?.lastGroqStatus;
      case 'seena':
        return seena?.lastSeenaStatus;
      case 'gemini':
      default:
        return gemini?.lastGeminiStatus;
    }
  }

  /// True when the active provider is in offline/fallback mode.
  bool get isOfflineMode {
    switch (_config.selectedAiProvider) {
      case 'groq':
        return groq?.isOfflineMode ?? true;
      case 'seena':
        return seena?.isOfflineMode ?? true;
      case 'gemini':
      default:
        return gemini?.isOfflineMode ?? true;
    }
  }

  /// True when the active provider has a configured API key and cloud is enabled.
  bool get hasActiveKey => _config.hasActiveAiKey && _config.cloudEnabled;

  /// Cancels all pending requests across all providers.
  void cancelPending() {
    gemini?.cancelPending();
    groq?.cancelPending();
    seena?.cancelPending();
  }

  /// Asks the active AI provider for legal guidance on [question].
  /// Falls back to the other configured cloud provider when the selected one
  /// is rate-limited or unavailable, then to [LocalLegalBrain].
  Future<AiAnswer> askLegalQuestion(
    String question, {
    List<ChatMessage> history = const [],
    String outputLanguage = 'en',
  }) async {
    if (!_config.cloudEnabled || !_config.hasActiveAiKey) {
      return LocalLegalBrain.answerWithCorpus(question);
    }

    final AiAnswer primary = await _askProvider(
      _config.selectedAiProvider,
      question,
      history: history,
      outputLanguage: outputLanguage,
    );
    if (!primary.offline) return primary;

    for (final String provider in <String>['gemini', 'groq', 'seena']) {
      if (provider == _config.selectedAiProvider) continue;
      if (!_hasCloudKey(provider)) continue;
      final AiAnswer fallback = await _askProvider(
        provider,
        question,
        history: history,
        outputLanguage: outputLanguage,
      );
      if (!fallback.offline) return fallback;
    }

    return primary;
  }

  bool _hasCloudKey(String provider) {
    switch (provider) {
      case 'groq':
        return _config.groqApiKey.trim().isNotEmpty;
      case 'seena':
        return _config.seenaApiKey.trim().isNotEmpty &&
            _config.seenaBaseUrl.trim().isNotEmpty &&
            AppConfig.isAllowedRemoteUrl(_config.seenaBaseUrl);
      case 'gemini':
      default:
        return _config.geminiApiKey.trim().isNotEmpty;
    }
  }

  Future<AiAnswer> _askProvider(
    String provider,
    String question, {
    required List<ChatMessage> history,
    required String outputLanguage,
  }) async {
    switch (provider) {
      case 'groq':
        if (groq != null) {
          return groq!.askLegalQuestion(
            question,
            history: history,
            outputLanguage: outputLanguage,
          );
        }
        break;
      case 'seena':
        if (seena != null) {
          return seena!.askLegalQuestion(
            question,
            history: history,
            outputLanguage: outputLanguage,
          );
        }
        break;
      case 'gemini':
      default:
        if (gemini != null) {
          return gemini!.askLegalQuestion(
            question,
            history: history,
            outputLanguage: outputLanguage,
          );
        }
        break;
    }
    return LocalLegalBrain.answerWithCorpus(question);
  }
}
