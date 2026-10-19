import 'package:flutter/widgets.dart';

import '../services/api_service.dart';
import '../services/direct_gemini_service.dart';
import '../services/groq_service.dart';
import '../services/seena_service.dart';
import '../services/multi_provider_ai_service.dart';
import '../services/speech_service.dart';
import '../services/local_language_service.dart';
import '../services/ai_features_service.dart';
import '../services/lawyer_directory_service.dart';
import 'app_config.dart';
import 'conversation_store.dart';
import 'auth_controller.dart';

/// Bundle of the long lived objects the whole app shares.
class AppServices {
  AppServices({
    AppConfig? config,
    ApiService? api,
    AuthController? auth,
    SpeechService? speech,
    DirectGeminiService? gemini,
    GroqService? groq,
    SeenaService? seena,
    MultiProviderAiService? multiProviderAi,
    LocalLanguageService? localLanguages,
    AiFeaturesService? aiFeatures,
    LawyerDirectoryService? lawyerDirectory,
  }) : config = config ?? AppConfig.instance,
       api = api ?? ApiService(config ?? AppConfig.instance),
       auth =
           auth ??
           AuthController(api ?? ApiService(config ?? AppConfig.instance)),
       speech = speech ?? SpeechService(),
       gemini = gemini ?? DirectGeminiService(config ?? AppConfig.instance),
       groq = groq ?? GroqService(config ?? AppConfig.instance),
       seena = seena ?? SeenaService(config ?? AppConfig.instance),
       localLanguages =
           localLanguages ?? LocalLanguageService(config ?? AppConfig.instance),
       aiFeatures =
           aiFeatures ?? AiFeaturesService(config ?? AppConfig.instance),
        lawyerDirectory = lawyerDirectory ?? LawyerDirectoryService() {
    this.multiProviderAi =
        multiProviderAi ??
        MultiProviderAiService(
          this.config,
          gemini: this.gemini,
          groq: this.groq,
          seena: this.seena,
        );
  }

  final ConversationStore conversation = ConversationStore();
  Future<void> clearPrivateSession() async {
    conversation.clear();
    gemini.cancelPending();
    groq.cancelPending();
    seena.cancelPending();
    api.cancelPending();
    await localLanguages.cancelPending();
    await speech.silence();
  }

  final AppConfig config;
  final ApiService api;
  final AuthController auth;
  final SpeechService speech;
  final DirectGeminiService gemini;
  final GroqService groq;
  final SeenaService seena;
  late final MultiProviderAiService multiProviderAi;
  final LocalLanguageService localLanguages;
  final AiFeaturesService aiFeatures;
  final LawyerDirectoryService lawyerDirectory;
}

/// Provides [AppServices] to the widget tree (`AppScope.of(context)`).
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final AppScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope.of() called outside of an AppScope.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.services != services;
}
