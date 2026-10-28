import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_scope.dart';
import '../core/language_helper.dart';
import '../data/content_data.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/local_legal_brain.dart';
import '../services/local_language_service.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../widgets/alive_voice_island.dart';
import '../widgets/brand.dart';
import '../widgets/fluid_waveform.dart';
import '../widgets/legal_ux_components.dart';

/// Mobile upgrade of Voice Assistant with Dual-Perspective views,
/// Procedural Roadmap timelines, and Document Checklists.
class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final TextEditingController _manualController = TextEditingController();
  static const int _barCount = 30;

  SpeechService? _speech;
  AppConfig? _config;
  ApiService? _api;

  List<double> _levels = List<double>.filled(_barCount, 0.15);
  bool _speechReady = false;
  bool _isRecording = false;
  bool _micPressed = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _usedOfflineFallback = false;
  String _offlineStatus = '';
  String _transcript = '';

  // Dual-perspective legal answer state
  AiAnswer? _aiAnswer;
  bool _isCourtMode = false;

  // Resolved language code — reads directly from config so it always reflects
  // the current preference even after the user changes it via the chip.
  String get _lang =>
      LanguageHelper.resolve(AppScope.of(context).config.languagePreference);
  bool get _isRtl => LanguageHelper.isRtl(_lang);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_speech != null) return;
    final AppServices services = AppScope.of(context);
    _speech = services.speech;
    _config = services.config;
    _api = services.api;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialiseSpeech());
  }

  @override
  void dispose() {
    _manualController.dispose();
    // `_speech` is the SHARED [SpeechService] singleton owned by
    // [AppServices], not a per-screen instance — so it must never be
    // hard-disposed here. Disposing it tears down the recogniser and TTS for
    // the whole app, and its leftover screen-bound callbacks would then fire on
    // this already-disposed State ("setState() called after dispose()"). This
    // is a transient full-screen dialog that is pushed/popped many times, so we
    // only stop activity and detach the callbacks this screen installed.
    final SpeechService? speech = _speech;
    speech?.onError = null;
    speech?.cancelListening();
    speech?.stopSpeaking();
    super.dispose();
  }

  Future<void> _initialiseSpeech() async {
    final SpeechService speech = _speech!;
    speech.onError = (String message) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    };
    final bool ready = await speech.init();
    if (!mounted) return;
    setState(() => _speechReady = ready);
    if (ready) return;

    // A dead mic on a real phone is almost always one of three things. Say which
    // one, and always point at the typed fallback so the app stays usable.
    final String reason = !speech.micPermissionGranted
        ? 'Microphone permission is off. Turn it on in Settings > Apps > '
              'Voice2Law > Permissions.'
        : 'No speech-recognition engine was found on this phone. Installing '
              'Google app or "Speech Recognition & Synthesis" restores voice input.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$reason You can type your question below instead.'),
        duration: const Duration(seconds: 7),
      ),
    );
  }

  void _pushLevel(double level) {
    if (!mounted) return;
    setState(() {
      _levels = <double>[..._levels.skip(1), level.clamp(0.06, 1.0)];
    });
  }

  Future<void> _startRecording() async {
    final SpeechService speech = _speech!;
    await speech.stopSpeaking();
    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _isSpeaking = false;
      _transcript = '';
      _aiAnswer = null;
      _usedOfflineFallback = false;
      _levels = List<double>.filled(_barCount, 0.15);
    });

    final String locale = _config?.sttLocale ?? 'en_US';
    await speech.startListening(
      localeId: locale == 'auto'
          ? LanguageHelper.sttLocaleFor(_lang, 'auto').replaceAll('-', '_')
          : locale,
      onResult: (String text, bool isFinal) {
        if (!mounted) return;
        setState(() => _transcript = text);
      },
      onSoundLevel: _pushLevel,
      onDone: () {
        if (!mounted || !_isRecording) return;
        _stopRecording();
      },
    );
  }

  Future<void> _stopRecording() async {
    final SpeechService speech = _speech!;
    setState(() => _isRecording = false);
    await speech.stopListening();

    final String question = _transcript.trim();
    if (question.isEmpty) {
      if (!mounted) return;
      setState(() => _levels = List<double>.filled(_barCount, 0.15));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No speech detected. Try again or type your question below.',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    await _submitTranscript(question);
  }

  Future<void> _submitTranscript(String question) async {
    if (_isProcessing || !mounted || question.trim().isEmpty) return;
    final SpeechService speech = _speech!;
    final ApiService api = _api!;
    final AppServices services = AppScope.of(context);
    final epoch = services.conversation.epoch;
    // Snapshot the shared conversation before adding this turn so the AI can
    // resolve follow-ups such as "what if I don't have a lawyer?".
    final List<ChatMessage> history = List<ChatMessage>.of(
      services.conversation.messages,
    );
    await speech.stopListening();
    if (!mounted || epoch != services.conversation.epoch) return;
    setState(() {
      _isProcessing = true;
      _isRecording = false;
      _transcript = question;
      _levels = List<double>.filled(_barCount, 0.15);
    });

    AiAnswer answer;
    try {
      if (!services.config.cloudEnabled) {
        answer = await LocalLegalBrain.answerWithCorpus(question);
      } else if (services.config.directAiEnabled) {
        answer = await services.multiProviderAi.askLegalQuestion(
          question,
          history: history,
          outputLanguage: _lang,
        );
      } else {
        answer = await api.askVoice(
          transcript: question,
          outputLanguage: _lang,
        );
      }
    } on ApiException {
      if (!mounted || epoch != services.conversation.epoch) return;
      answer = await LocalLegalBrain.answerWithCorpus(question);
    } catch (_) {
      if (!mounted || epoch != services.conversation.epoch) return;
      answer = await LocalLegalBrain.answerWithCorpus(question);
    }

    answer = await _completeSelectedLanguage(answer, services);
    if (!mounted || epoch != services.conversation.epoch) return;
    // Record both turns in the shared, memory-only conversation store so
    // follow-up voice questions carry context. Quick exit clears this.
    services.conversation.messages
      ..add(
        ChatMessage(
          id: 'vu-${DateTime.now().microsecondsSinceEpoch}',
          isUser: true,
          text: question,
        ),
      )
      ..add(
        ChatMessage(
          id: 'va-${DateTime.now().microsecondsSinceEpoch}',
          isUser: false,
          text: answer.answer,
          answerUrdu: answer.answerUrdu,
          answerPunjabi: answer.answerPunjabi,
          answerSindhi: answer.answerSindhi,
          answerPashto: answer.answerPashto,
          category: answer.category,
          confidence: answer.confidence,
          offline: answer.offline,
          empatheticOpening: answer.empatheticOpening,
          empatheticOpeningUrdu: answer.empatheticOpeningUrdu,
          courtModeAnswer: answer.courtModeAnswer,
          courtModeAnswerUrdu: answer.courtModeAnswerUrdu,
          urgencyLevel: answer.urgencyLevel,
          roadmap: answer.roadmap,
          documents: answer.documents,
          statutes: answer.statutes,
          suggestedEmergencyHelpline: answer.suggestedEmergencyHelpline,
        ),
      );
    setState(() {
      _usedOfflineFallback = answer.offline;
      _offlineStatus = AppScope.of(context).multiProviderAi.lastStatus ?? '';
      _isProcessing = false;
      _aiAnswer = answer;
      if (answer.transcript.isNotEmpty) _transcript = answer.transcript;
    });

    if (_config?.ttsEnabled ?? false) {
      await _toggleSpeak();
    }
  }

  Future<AiAnswer> _completeSelectedLanguage(
    AiAnswer answer,
    AppServices services,
  ) async {
    if (_lang == 'en') return answer;
    final bool missing = switch (_lang) {
      'ur' => answer.answerUrdu.trim().isEmpty,
      'pa' => answer.answerPunjabi.trim().isEmpty,
      'sd' => answer.answerSindhi.trim().isEmpty,
      'ps' => answer.answerPashto.trim().isEmpty,
      _ => false,
    };
    if (!missing || !services.config.localLanguagesEnabled) return answer;

    try {
      final String translated = await services.localLanguages.translate(
        answer.answer,
        source: 'en',
        target: _lang,
      );
      final String translatedCourt = answer.courtModeAnswer.trim().isEmpty
          ? ''
          : await services.localLanguages.translate(
              answer.courtModeAnswer,
              source: 'en',
              target: _lang,
            );
      return switch (_lang) {
        'ur' => answer.copyWith(
          answerUrdu: translated,
          courtModeAnswerUrdu: translatedCourt,
        ),
        'pa' => answer.copyWith(answerPunjabi: translated),
        'sd' => answer.copyWith(answerSindhi: translated),
        'ps' => answer.copyWith(answerPashto: translated),
        _ => answer,
      };
    } on LocalLanguageException {
      return answer;
    } on FormatException {
      return answer;
    }
  }

  Future<void> _toggleSpeak() async {
    final SpeechService speech = _speech!;
    if (_isSpeaking) {
      await speech.stopSpeaking();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }

    final AiAnswer? ans = _aiAnswer;
    if (ans == null) return;

    // Pick the text based on court mode + language preference
    final String engText = _isCourtMode && ans.courtModeAnswer.isNotEmpty
        ? ans.courtModeAnswer
        : ans.answer;
    final String urText = _isCourtMode && ans.courtModeAnswerUrdu.isNotEmpty
        ? ans.courtModeAnswerUrdu
        : ans.answerUrdu;
    final String text = LanguageHelper.answerFor(
      langCode: _lang,
      english: engText,
      urdu: urText,
      punjabi: ans.answerPunjabi,
      sindhi: ans.answerSindhi,
      pashto: ans.answerPashto,
    );
    if (text.isEmpty) return;

    // Resolve TTS locale from language preference
    final String ttsLocale = LanguageHelper.ttsLocaleFor(
      _lang,
      speech.urduVoiceLocale,
    );

    setState(() => _isSpeaking = true);
    await speech.speak(text, locale: ttsLocale);
    if (mounted) setState(() => _isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    VoiceIslandState islandState = VoiceIslandState.idle;
    if (_isRecording) {
      islandState = VoiceIslandState.listening;
    } else if (_isProcessing) {
      islandState = VoiceIslandState.processing;
    } else if (_isSpeaking) {
      islandState = VoiceIslandState.speaking;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: <Widget>[
                  _voicePanel(),
                  if (_transcript.isNotEmpty) _transcriptCard(),
                  if (_isProcessing) _processingRow(),
                  if (_aiAnswer != null) _responseCard(),
                  _manualEntry(),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tip: Switch the recognition language in Settings (Urdu ur_PK or English en_US).',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AliveVoiceIsland(
              state: islandState,
              onMicTap: () {
                if (!_speechReady) return;
                if (_isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              soundLevel: _levels.isNotEmpty ? _levels.last : 0.15,
              isTtsSpeaking: _isSpeaking,
              onTtsToggle: _toggleSpeak,
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final services = AppScope.of(context);
    // At large accessibility text sizes a single row cannot hold the title,
    // language chip and actions without squeezing the title to zero width.
    final bool compact = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    final Widget backButton = IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.arrow_back, color: AppColors.white),
      tooltip: 'Back',
    );
    final Widget title = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          switch (_lang) {
            'ur' => 'وائس اسسٹنٹ',
            'pa' => 'وائس اسسٹنٹ',
            'sd' => 'صوتي مددگار',
            'ps' => 'د غږ مرستیال',
            _ => 'Voice Assistant',
          },
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          switch (_lang) {
            'ur' => 'دوہری نقطہ نظر صوتی پہچان',
            'pa' => 'دوہری نظریہ آواز پچھان',
            'sd' => 'ٻٽي نظريي صوتي سڃاڻپ',
            'ps' => 'دوه اړخیز د غږ پیژندنه',
            _ => 'Dual-Mode Voice Recognition',
          },
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
    final Widget languageSwitcher = MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: LanguageSwitcherChip(
        current: services.config.languagePreference,
        light: true,
        onChanged: (String lang) async {
          await services.config.update(languagePreference: lang);
          if (mounted) setState(() {});
        },
      ),
    );
    final Widget quickExit = IconButton(
      tooltip: 'Quick exit to calculator',
      icon: const Icon(Icons.shield_outlined, color: AppColors.white, size: 24),
      onPressed: () => DiscreetModeDialog.triggerPanicExit(context),
    );
    final Widget micBadge = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.mic, color: AppColors.white, size: 20),
    );

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientGreen),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
      child: compact
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    backButton,
                    const SizedBox(width: 4),
                    Expanded(child: title),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: languageSwitcher,
                      ),
                    ),
                    quickExit,
                    micBadge,
                  ],
                ),
              ],
            )
          : Row(
              children: <Widget>[
                backButton,
                const SizedBox(width: 4),
                Expanded(child: title),
                languageSwitcher,
                const SizedBox(width: 6),
                quickExit,
                micBadge,
              ],
            ),
    );
  }

  Widget _voicePanel() {
    return BrandCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.emerald.withValues(alpha: 0.25),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 90,
            child: FluidWaveform(
              isRecording: _isRecording,
              soundLevel: _levels.isNotEmpty ? _levels.last : 0.15,
              height: 90,
            ),
          ),
          const SizedBox(height: 14),
          _micButton(),
          const SizedBox(height: 16),
          Text(
            !_speechReady
                ? 'Microphone recognition is unavailable on this device'
                : _isRecording
                ? 'Recording... Tap to stop'
                : _isProcessing
                ? 'Processing...'
                : 'Tap the microphone and speak your question',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen.withValues(alpha: 0.75),
            ),
          ),
          if (_usedOfflineFallback)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: OfflineBanner(
                isUrdu: _isRtl,
                statusCode: _offlineStatus.isNotEmpty ? _offlineStatus : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _micButton() {
    if (_isProcessing) {
      return const SizedBox(
        width: 96,
        height: 96,
        child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
      );
    }

    return Semantics(
      button: true,
      label: _isRecording ? 'Stop recording' : 'Start voice recording',
      child: GestureDetector(
        onTap: !_speechReady
            ? null
            : (_isRecording ? _stopRecording : _startRecording),
        onTapDown: (_) => setState(() => _micPressed = true),
        onTapUp: (_) => setState(() => _micPressed = false),
        onTapCancel: () => setState(() => _micPressed = false),
        child: AnimatedOpacity(
          opacity: _speechReady ? 1 : 0.45,
          duration: const Duration(milliseconds: 250),
          child: AnimatedScale(
            scale: _micPressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: _isRecording ? null : AppColors.gradientEmeraldToDark,
                color: _isRecording ? AppColors.danger : null,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: (_isRecording ? AppColors.danger : AppColors.emerald)
                        .withValues(alpha: 0.45),
                    blurRadius: _isRecording ? 26 : 16,
                    spreadRadius: _isRecording ? 4 : 0,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.mic_off : Icons.mic,
                color: AppColors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _transcriptHasUrdu =>
      _transcript.runes.any((int rune) => rune >= 0x0600 && rune <= 0x06FF);

  Widget _transcriptCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: BrandCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(
                  Icons.record_voice_over_outlined,
                  size: 19,
                  color: AppColors.darkGreen,
                ),
                SizedBox(width: 8),
                Text(
                  'Your Question',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.offWhite,
                border: Border(
                  left: BorderSide(color: AppColors.emerald, width: 4),
                ),
              ),
              child: Text(
                _transcript,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
            if (_transcriptHasUrdu)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: UrduText(_transcript, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _processingRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          SizedBox(width: 12),
          Text(
            'Analyzing your legal query...',
            style: TextStyle(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _responseCard() {
    final AiAnswer ans = _aiAnswer!;
    final String activeEnglish = _isCourtMode && ans.courtModeAnswer.isNotEmpty
        ? ans.courtModeAnswer
        : ans.answer;
    final String activeUrduText =
        _isCourtMode && ans.courtModeAnswerUrdu.isNotEmpty
        ? ans.courtModeAnswerUrdu
        : ans.answerUrdu;
    final String activeText = LanguageHelper.answerFor(
      langCode: _lang,
      english: activeEnglish,
      urdu: activeUrduText,
      punjabi: ans.answerPunjabi,
      sindhi: ans.answerSindhi,
      pashto: ans.answerPashto,
    );
    final String activeUrdu = activeUrduText;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.gradientGreen,
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.darkGreen.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header row with voice indicator
            Row(
              children: <Widget>[
                const Icon(Icons.balance, size: 20, color: AppColors.gold),
                const SizedBox(width: 8),
                const Text(
                  'Legal Guidance',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (ans.category.isNotEmpty) StatusChip(label: ans.category),
              ],
            ),
            const SizedBox(height: 12),

            // Empathetic Opening Banner
            if (ans.empatheticOpening.isNotEmpty) ...<Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ans.empatheticOpening,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                    if (ans.empatheticOpeningUrdu.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      UrduText(
                        ans.empatheticOpeningUrdu,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ],
                    if (ans.suggestedEmergencyHelpline.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.phone_in_talk,
                            size: 13,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Helpline: ${ans.suggestedEmergencyHelpline}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Dual-Perspective Mode Toggle
            if (ans.courtModeAnswer.isNotEmpty) ...<Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => setState(() => _isCourtMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: !_isCourtMode
                              ? AppColors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Simple Citizen (عام فہم)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: !_isCourtMode
                                ? AppColors.darkGreen
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isCourtMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isCourtMode
                              ? AppColors.gold
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Court / Lawyer Mode (عدالتی)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _isCourtMode
                                ? AppColors.darkGreen
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Main Text Answer
            Directionality(
              textDirection: LanguageHelper.isRtl(_lang)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Text(
                activeText,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14.5,
                  height: LanguageHelper.isRtl(_lang) ? 2.0 : 1.7,
                  fontFamily: LanguageHelper.metaFor(_lang).fontFamily,
                ),
              ),
            ),
            // Only show secondary Urdu belt when language is English
            if (!LanguageHelper.isRtl(_lang) &&
                activeUrdu.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Divider(color: AppColors.white.withValues(alpha: 0.25)),
              const SizedBox(height: 10),
              UrduText(activeUrdu, size: 15.5, color: AppColors.white),
            ],

            // Procedural Roadmap Timeline
            if (ans.roadmap.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ProceduralRoadmapWidget(
                  steps: ans.roadmap,
                  isUrdu: _isRtl,
                ),
              ),

            // Document Readiness Checklist
            if (ans.documents.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: DocumentChecklistWidget(
                  documents: ans.documents,
                  isUrdu: _isRtl,
                ),
              ),

            // Statutory Citations Card
            if (ans.statutes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: StatutoryCitationsCard(
                  statutes: ans.statutes,
                  isUrdu: _isRtl,
                ),
              ),

            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                const Flexible(
                  child: Text(
                    'General information · verify sources',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
                const Spacer(),
                if (_config?.ttsEnabled ?? false)
                  OutlinedButton.icon(
                    onPressed: _toggleSpeak,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: BorderSide(
                        color: AppColors.white.withValues(alpha: 0.6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    icon: Icon(
                      _isSpeaking
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      size: 18,
                    ),
                    label: Text(
                      _isSpeaking ? 'Stop' : 'Read aloud',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.white.withValues(alpha: 0.25)),
            const SizedBox(height: 8),
            Text(
              ContentData.voiceDisclaimer,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.8),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _manualEntry() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: BrandCard(
        borderColor: AppColors.gold.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.keyboard_alt_outlined,
                  size: 19,
                  color: AppColors.goldText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _speechReady
                        ? 'Or type your question'
                        : 'Type your question instead',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _manualController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. divorce ka tareeqa kya hai?',
              ),
            ),
            const SizedBox(height: 12),
            BrandButton(
              label: 'Send as voice query',
              icon: Icons.send,
              onPressed: () {
                final String text = _manualController.text.trim();
                if (text.isEmpty) return;
                _manualController.clear();
                _submitTranscript(text);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'On-device speech recognition + Voice2Law Dual AI pipeline',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _speechReady ? AppColors.emerald : AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _speechReady ? 'Mic ready' : 'Mic unavailable',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
