// All 13 AI feature screens as thin wrappers around AiFeatureScreen.
//
// Each screen is just a few lines: title, icon, hint, and the generator
// function from AiFeaturesService.

import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'ai_feature_screen.dart';

// Re-export the hub so app.dart only needs one import.
export 'ai_features_hub_screen.dart';

// ── Feature 1: Document Generator ─────────────────────────────────────────

class DocGeneratorScreen extends StatelessWidget {
  const DocGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Document Generator',
      titleUrdu: 'قانونی دستاویز ساز',
      subtitle: 'Drafts legal documents ready to file',
      icon: Icons.description_outlined,
      inputHint:
          'Describe what you need:\n'
          'e.g. "I need a divorce notice to send to Union Council, '
          'my wife left 6 months ago"',
      buttonLabel: 'Generate Document',
      maxLines: 5,
      generator: ai.generateDocument,
    );
  }
}

// ── Feature 2: Document Explainer ─────────────────────────────────────────

class DocScannerScreen extends StatelessWidget {
  const DocScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Document Explainer',
      titleUrdu: 'دستاویز کا آسان بیان',
      subtitle: 'Paste any legal document & understand it',
      icon: Icons.document_scanner_outlined,
      inputHint:
          'Paste the text of your legal document here\n'
          '(court order, FIR, legal notice, etc.)',
      buttonLabel: 'Explain Document',
      maxLines: 8,
      generator: ai.explainDocument,
    );
  }
}

// ── Feature 3: Deadline Calculator ─────────────────────────────────────────

class DeadlineCalcScreen extends StatelessWidget {
  const DeadlineCalcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Deadline Calculator',
      titleUrdu: 'قانونی مدت حساب',
      subtitle: 'Calculates limitation periods automatically',
      icon: Icons.timer_outlined,
      inputHint:
          'Describe your situation with dates:\n'
          'e.g. "Court ordered eviction on 15 March 2026, how long do I have to appeal?"',
      buttonLabel: 'Calculate Deadlines',
      maxLines: 5,
      generator: ai.calculateDeadlines,
    );
  }
}

// ── Feature 4: Case Intake ─────────────────────────────────────────────────

/// A message in the case intake conversation.
class _IntakeMessage {
  const _IntakeMessage({required this.isUser, required this.text});
  final bool isUser;
  final String text;
}

class CaseIntakeScreen extends StatefulWidget {
  const CaseIntakeScreen({super.key});

  @override
  State<CaseIntakeScreen> createState() => _CaseIntakeScreenState();
}

class _CaseIntakeScreenState extends State<CaseIntakeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_IntakeMessage> _messages = <_IntakeMessage>[];
  String _context = '';
  bool _isLoading = false;

  @override
  void dispose() {
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

  Future<void> _send([String? prefilled]) async {
    final String input = (prefilled ?? _controller.text).trim();
    if (input.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_IntakeMessage(isUser: true, text: input));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToEnd();

    // Build cumulative context for the AI
    _context = _context.isEmpty
        ? input
        : '$_context\n\nUser: $input';

    try {
      final result =
          await AppScope.of(context).aiFeatures.continueIntake(_context);
      if (!mounted) return;
      _context = '$_context\n\nAssistant: ${result.content}';
      setState(() {
        _messages.add(_IntakeMessage(isUser: false, text: result.content));
        _isLoading = false;
      });
      _scrollToEnd();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(const _IntakeMessage(
          isUser: false,
          text: 'Something went wrong. Please try again.',
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _header(context),
            Expanded(
              child: _messages.isEmpty && !_isLoading
                  ? _introView()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (BuildContext ctx, int i) {
                        if (i == _messages.length) return _typingIndicator();
                        final _IntakeMessage msg = _messages[i];
                        return _bubble(msg, scheme);
                      },
                    ),
            ),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientGreen),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.chat_bubble_outline, color: AppColors.gold, size: 22),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Case Intake',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'AI asks follow-up questions to build your case file',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          // Clear button
          if (true)
            IconButton(
              tooltip: 'Start over',
              icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
              onPressed: () => setState(() {
                _messages.clear();
                _context = '';
                _isLoading = false;
              }),
            ),
        ],
      ),
    );
  }

  Widget _introView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      children: <Widget>[
        BrandCard(
          borderColor: AppColors.emerald.withValues(alpha: 0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Describe your legal situation to start',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The AI will ask follow-up questions one at a time to gather '
                'all the facts, then produce a complete case summary with the '
                'legal issues and recommended actions.',
                style: TextStyle(fontSize: 13.5, height: 1.6, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              const Text(
                'Quick start:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _quickChip('Divorce / Khula', 'I want to file for khula from my husband'),
                  _quickChip('Property dispute', 'My neighbour encroached on my land'),
                  _quickChip('Bail / arrest', 'My brother was arrested and I need bail information'),
                  _quickChip('FIR complaint', 'I want to file an FIR but the police are refusing'),
                  _quickChip('Inheritance', 'My father passed away and the brothers are not giving my share'),
                  _quickChip('Cybercrime', 'Someone hacked my bank account and transferred money'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickChip(String label, String query) => ActionChip(
    label: Text(label, style: const TextStyle(fontSize: 12.5)),
    backgroundColor: AppColors.lightGreen,
    onPressed: () => _send(query),
  );

  Widget _bubble(_IntakeMessage msg, ColorScheme scheme) {
    final bool isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.darkGreen
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser
              ? null
              : Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
        ),
        child: SelectableText(
          msg.text,
          style: TextStyle(
            fontSize: 14.5,
            height: 1.65,
            color: isUser ? Colors.white : scheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 10),
            Text(
              'Thinking...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkGreen.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppColors.darkGreen.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your answer or describe your situation...',
                isDense: true,
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.send, size: 20),
            onPressed: _isLoading ? null : _send,
          ),
        ],
      ),
    );
  }
}

// ── Feature 5: Case Prediction ─────────────────────────────────────────────

class CasePredictionScreen extends StatelessWidget {
  const CasePredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Case Prediction',
      titleUrdu: 'مقدمہ نتیجہ',
      subtitle: 'Estimates likely case outcomes',
      icon: Icons.analytics_outlined,
      inputHint:
          'Describe your case facts in detail:\n'
          'e.g. "Wife filed khula after 3 years of separation, '
          'no children, husband refuses to give divorce"',
      buttonLabel: 'Predict Outcome',
      maxLines: 6,
      generator: ai.predictOutcome,
    );
  }
}

// ── Feature 6: Rights Checker ──────────────────────────────────────────────

class RightsCheckerScreen extends StatelessWidget {
  const RightsCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Rights Checker',
      titleUrdu: 'حقوق جانچ',
      subtitle: 'Lists your rights and which apply',
      icon: Icons.verified_user_outlined,
      inputHint:
          'Describe your situation:\n'
          'e.g. "I was arrested without being told the reason, '
          'no FIR was filed for 24 hours"',
      buttonLabel: 'Check My Rights',
      maxLines: 5,
      generator: ai.checkRights,
    );
  }
}

// ── Feature 7: Smart Reminders ────────────────────────────────────────────

class SmartRemindersScreen extends StatelessWidget {
  const SmartRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Smart Reminders',
      titleUrdu: 'ذہین یاد دہانی',
      subtitle: 'Legal timeline with action deadlines',
      icon: Icons.notifications_active_outlined,
      inputHint:
          'Where are you in your legal process?\n'
          'e.g. "Filed divorce petition 2 weeks ago at Family Court Lahore, '
          'waiting for Arbitration Council notice"',
      buttonLabel: 'Generate Timeline',
      maxLines: 5,
      generator: ai.generateReminders,
    );
  }
}

// ── Feature 8: Precedent Search ────────────────────────────────────────────

class PrecedentSearchScreen extends StatelessWidget {
  const PrecedentSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Precedent Search',
      titleUrdu: 'عدالتی نظیر',
      subtitle: 'Finds relevant Pakistani case law',
      icon: Icons.gavel,
      inputHint:
          'Describe what kind of cases you\'re looking for:\n'
          'e.g. "Cases where khula was granted when husband was absent"',
      buttonLabel: 'Find Precedents',
      maxLines: 4,
      generator: ai.searchPrecedents,
    );
  }
}

// ── Feature 9: Term Explainer ──────────────────────────────────────────────

class TermExplainerScreen extends StatelessWidget {
  const TermExplainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Term Explainer',
      titleUrdu: 'قانونی اصطلاح',
      subtitle: 'Explains any legal term in plain language',
      icon: Icons.help_outline,
      inputHint:
          'Type a legal term:\n'
          'e.g. "Khula", "Dower", "Limitation Period", "FIR"',
      buttonLabel: 'Explain Term',
      maxLines: 2,
      generator: ai.explainTerm,
    );
  }
}

// ── Feature 10: Statute AI Search ──────────────────────────────────────────

class StatuteAiSearchScreen extends StatelessWidget {
  const StatuteAiSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Statute AI Search',
      titleUrdu: 'قانون تلاش',
      subtitle: 'Natural language search across statutes',
      icon: Icons.search,
      inputHint:
          'Ask in plain language:\n'
          'e.g. "What is the punishment for online harassment?"',
      buttonLabel: 'Search Statutes',
      maxLines: 3,
      generator: ai.searchStatutes,
    );
  }
}

// ── Feature 11: Emergency SOS ──────────────────────────────────────────────

class EmergencySosScreen extends StatelessWidget {
  const EmergencySosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Emergency Legal SOS',
      titleUrdu: 'فوری قانونی مدد',
      subtitle: 'Immediate steps for urgent situations',
      icon: Icons.emergency_outlined,
      inputHint:
          'What is your emergency?\n'
          'e.g. "Police are at my door without a warrant", '
          '"My husband is threatening me"',
      buttonLabel: 'GET HELP NOW',
      maxLines: 4,
      generator: ai.emergencySos,
    );
  }
}

// ── Feature 12: Scam Detector ──────────────────────────────────────────────

class ScamDetectorScreen extends StatelessWidget {
  const ScamDetectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Scam Detector',
      titleUrdu: 'دھوکہ پکڑیں',
      subtitle: 'Detects legal scams and fraud patterns',
      icon: Icons.warning_amber_outlined,
      inputHint:
          'Describe the situation you suspect might be a scam:\n'
          'e.g. "Someone is asking for money to withdraw an FIR, '
          'claiming to be a police officer"',
      buttonLabel: 'Analyze for Scams',
      maxLines: 5,
      generator: ai.detectScam,
    );
  }
}

// ── Feature 13: Mediation Suggestion ──────────────────────────────────────

class MediationScreen extends StatelessWidget {
  const MediationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AppScope.of(context).aiFeatures;
    return AiFeatureScreen(
      title: 'Mediation Advisor',
      titleUrdu: 'صلح و ثالثی',
      subtitle: 'Suggests alternatives to going to court',
      icon: Icons.handshake_outlined,
      inputHint:
          'Describe your dispute:\n'
          'e.g. "Dispute with my landlord about rent increase, '
          'he wants to evict me"',
      buttonLabel: 'Suggest Alternatives',
      maxLines: 5,
      generator: ai.suggestMediation,
    );
  }
}
