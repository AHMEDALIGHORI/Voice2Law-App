import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_config.dart';
import 'core/app_scope.dart';
import 'core/auth_controller.dart';
import 'services/api_service.dart';
import 'services/speech_service.dart';
import 'services/statute_corpus.dart';

/// Voice2Law mobile entry point.
///
/// Mirrors the bootstrap of the website: configuration is loaded first
/// (the mobile equivalent of the Vite `.env` values), then the admin session is
/// restored, then the app starts.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppConfig config = AppConfig.instance;
  await config.load();

  final ApiService api = ApiService(config);
  final AuthController auth = AuthController(api);
  await auth.restore();

  // Warm up the bundled statute corpus (hybrid-RAG layer) so the first
  // question never waits on the 3 MB parse.
  StatuteCorpus.preload();

  runApp(
    Voice2LawApp(
      services: AppServices(
        config: config,
        api: api,
        auth: auth,
        speech: SpeechService(),
      ),
    ),
  );
}
