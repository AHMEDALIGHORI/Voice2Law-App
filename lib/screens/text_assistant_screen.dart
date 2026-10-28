import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_scope.dart';
import '../core/conversation_store.dart';
import '../core/language_helper.dart';
import '../services/speech_service.dart';
import '../data/content_data.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/local_legal_brain.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_composer.dart';
import '../widgets/legal_ux_components.dart';
import '../widgets/staggered_entrance.dart';

/// Full screen text assistant upgraded with Dual-Perspective legal reasoning
/// and Google-grade procedural UX components.
class TextAssistantScreen extends StatefulWidget {
  const TextAssistantScreen({super.key});

  @override
  State<TextAssistantScreen> createState() => _TextAssistantScreenState();
}

class _TextAssistantScreenState extends State<TextAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late ConversationStore _conversation;
  List<ChatMessage> get _messages => _conversation.messages;
  int _requestId = 0;
  SpeechService? _speech;
  bool _offlineSession = false;
  String _offlineStatus = '';

  String get _lang =>
      LanguageHelper.resolve(AppScope.of(context).config.languagePreference);
  bool get _isRtl => LanguageHelper.isRtl(_lang);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _conversation = AppScope.of(context).conversation;
    _speech = AppScope.of(context).speech;
  }

  void _clearConversation() {
    _requestId++;
    AppScope.of(context).clearPrivateSession();
    setState(() {
      _isTyping = false;
    });
  }

  bool _isTyping = false;

  @override
  void dispose() {
    _requestId++;
    _speech?.stopSpeaking();
    _speech?.onError = null;
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final String question = _controller.text.trim();
    if (question.isEmpty || _isTyping) return;

    final AppServices services = AppScope.of(context);
    final requestId = ++_requestId;
    final epoch = _conversation.epoch;
    final history = List<ChatMessage>.of(_messages);
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'u-${DateTime.now().microsecondsSinceEpoch}',
          isUser: true,
          text: question,
        ),
      );
      _isTyping = true;
    });
    _controller.clear();
    _scrollToEnd();

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
        answer = await services.api.askText(
          question: question,
          history: history,
        );
      }
    } on ApiException {
      if (!mounted || epoch != _conversation.epoch || requestId != _requestId) {
        return;
      }
      answer = await LocalLegalBrain.answerWithCorpus(question);
    } catch (_) {
      if (!mounted || epoch != _conversation.epoch || requestId != _requestId) {
        return;
      }
      answer = await LocalLegalBrain.answerWithCorpus(question);
    }

    if (!mounted || epoch != _conversation.epoch || requestId != _requestId) {
      return;
    }
    setState(() {
      _offlineSession = answer.offline;
      _offlineStatus = AppScope.of(context).multiProviderAi.lastStatus ?? '';
      _isTyping = false;
      _messages.add(
        ChatMessage(
          id: 'b-${DateTime.now().microsecondsSinceEpoch}',
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
    });
  }

  Future<void> _speak(String text) async {
    final services = AppScope.of(context);
    final speech = services.speech;
    speech.onError = (message) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    };
    // Resolve the correct TTS locale for the active language.
    final String langCode = LanguageHelper.resolve(
      services.config.languagePreference,
    );
    final String ttsLocale = LanguageHelper.ttsLocaleFor(
      langCode,
      speech.urduVoiceLocale,
    );
    await speech.speak(text, locale: ttsLocale);
  }

  @override
  Widget build(BuildContext context) {
    final AppServices services = AppScope.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _header(context),
            if (_offlineSession)
              OfflineBanner(
                isUrdu: _isRtl,
                statusCode: _offlineStatus.isNotEmpty ? _offlineStatus : null,
              ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                itemCount:
                    _messages.length +
                    (_isTyping || _messages.length == 1 ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == _messages.length) {
                    return _isTyping
                        ? const _TypingBubble()
                        : _quickQuestions();
                  }
                  final ChatMessage message = _messages[index];
                  return StaggeredEntrance(
                    duration: const Duration(milliseconds: 320),
                    slideOffset: message.isUser
                        ? const Offset(0.08, 0.0)
                        : const Offset(-0.08, 0.0),
                    child: _MessageBubble(
                      message: message,
                      speakEnabled: services.config.ttsEnabled,
                      onSpeak: _speak,
                    ),
                  );
                },
              ),
            ),
            _composer(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final services = AppScope.of(context);
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientGreen),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  switch (_lang) {
                    'ur' => 'ٹیکسٹ اسسٹنٹ',
                    'pa' => 'ٹیکسٹ اسسٹنٹ',
                    'sd' => 'متن جو مددگار',
                    'ps' => 'د متن مرستیال',
                    _ => 'Text Assistant',
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
                    'ur' => 'اردو و انگریزی · نجی سیشن',
                    'pa' => 'پنجابی و انگریزی · نجی سیشن',
                    'sd' => 'سنڌي ۽ انگريزي · نجي جلسو',
                    'ps' => 'پښتو او انګلیسي · خصوصي جلسه',
                    _ => 'English & Urdu · private session',
                  },
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          // Language switcher — clamp its text scale so the compact header
          // keeps fitting at 2x accessibility scaling; the answer text still
          // scales normally.
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: LanguageSwitcherChip(
              current: services.config.languagePreference,
              light: true,
              onChanged: (String lang) async {
                await services.config.update(languagePreference: lang);
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Quick exit to calculator',
            icon: const Icon(
              Icons.shield_outlined,
              color: AppColors.white,
              size: 24,
            ),
            onPressed: () => DiscreetModeDialog.triggerPanicExit(context),
          ),
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: _clearConversation,
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _quickQuestions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Quick questions:',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ContentData.quickQuestions.map((String question) {
              return ActionChip(
                label: Text(question, style: const TextStyle(fontSize: 12)),
                backgroundColor: AppColors.lightGreen,
                side: BorderSide(
                  color: AppColors.emerald.withValues(alpha: 0.3),
                ),
                onPressed: () {
                  _controller.text = question;
                  _send();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _composer() => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.3,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassComposer(
            controller: _controller,
            onSend: _send,
            isBusy: _isTyping,
            hintText: 'Ask in English or Urdu',
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'General information · verify current law',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Upgraded Chat bubble supporting Dual-Perspective Toggle:
/// - "Simple Citizen View" (عام فہم)
/// - "Court / Statutory View" (عدالتی حوالہ)
/// plus Roadmap and Document Checklist widgets.
class _MessageBubble extends StatefulWidget {
  const _MessageBubble({
    required this.message,
    required this.speakEnabled,
    required this.onSpeak,
  });
  final ChatMessage message;
  final bool speakEnabled;
  final void Function(String) onSpeak;
  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _court = false;
  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final c = Theme.of(context).colorScheme;
    final String english = _court && m.courtModeAnswer.isNotEmpty
        ? m.courtModeAnswer
        : m.text;
    final String urdu = _court && m.courtModeAnswerUrdu.isNotEmpty
        ? m.courtModeAnswerUrdu
        : m.answerUrdu;
    // Pick the display text from the active language using LanguageHelper.
    final String activeLang = LanguageHelper.resolve(
      AppScope.of(context).config.languagePreference,
    );
    final String text = LanguageHelper.answerFor(
      langCode: activeLang,
      english: english,
      urdu: urdu,
      punjabi: m.answerPunjabi,
      sindhi: m.answerSindhi,
      pashto: m.answerPashto,
    );
    final LangMeta langMeta = LanguageHelper.metaFor(activeLang);
    Widget details(
      String title,
      Widget child, {
      bool initiallyExpanded = false,
    }) => Theme(
      data: AppTheme.light(),
      child: Card(
        margin: const EdgeInsets.only(top: 10),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          childrenPadding: const EdgeInsets.all(8),
          children: [child],
        ),
      ),
    );
    return Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: m.isUser ? const Color(0xFF053425) : c.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: m.isUser ? Colors.transparent : c.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!m.isUser && m.id != 'greeting') ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    avatar: Icon(
                      m.offline
                          ? Icons.offline_bolt_outlined
                          : Icons.auto_awesome_outlined,
                      size: 16,
                    ),
                    label: Text(
                      m.offline ? 'Offline library' : 'AI answer',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (m.courtModeAnswer.isNotEmpty)
                    ChoiceChip(
                      label: Text(
                        _court
                            ? (langMeta.rtl ? 'شہری کا خلاصہ' : 'Citizen view')
                            : (langMeta.rtl ? 'وکیل کا تجزیہ' : 'Lawyer view'),
                      ),
                      selected: _court,
                      onSelected: (v) => setState(() => _court = v),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (langMeta.rtl && text.isNotEmpty)
              Directionality(
                textDirection: TextDirection.rtl,
                child: SelectableText(
                  text,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.9,
                    fontFamily: langMeta.fontFamily,
                    color: m.isUser ? Colors.white : c.onSurface,
                  ),
                ),
              )
            else
              SelectableText(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: m.isUser ? Colors.white : c.onSurface,
                ),
              ),
            if (!m.isUser && m.id != 'greeting') ...[
              if (m.urgencyLevel != 'normal')
                LegalTriageBanner(
                  urgency: m.urgencyLevel,
                  isUrdu: langMeta.rtl,
                ),
              if (m.roadmap.isNotEmpty)
                details(
                  langMeta.rtl ? 'اگلا عملی قدم' : 'Your next practical steps',
                  ProceduralRoadmapWidget(
                    steps: m.roadmap,
                    isUrdu: langMeta.rtl,
                  ),
                  initiallyExpanded: true,
                ),
              if (m.documents.isNotEmpty)
                details(
                  'Document checklist',
                  DocumentChecklistWidget(
                    documents: m.documents,
                    isUrdu: langMeta.rtl,
                  ),
                ),
              if (m.statutes.isNotEmpty)
                details(
                  langMeta.rtl
                      ? 'قانونی ثبوت اور اصل حوالہ'
                      : 'Legal evidence and source text',
                  StatutoryCitationsCard(
                    statutes: m.statutes,
                    isUrdu: langMeta.rtl,
                  ),
                  initiallyExpanded: true,
                ),
              const SizedBox(height: 10),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    m.category,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  IconButton(
                    tooltip: 'Copy answer',
                    icon: const Icon(Icons.copy_outlined, size: 19),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Answer copied')),
                        );
                      }
                    },
                  ),
                  if (widget.speakEnabled)
                    IconButton(
                      tooltip: 'Read displayed answer aloud',
                      icon: const Icon(Icons.volume_up_outlined),
                      onPressed: () => widget.onSpeak(text),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: AppColors.gradientEmeraldToDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: AppColors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.darkGreen.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(3, (int index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) {
                    final double offset =
                        ((_controller.value + index * 0.25) % 1.0) * 2 - 1;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(
                          alpha: 0.35 + (1 - offset.abs()) * 0.65,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
