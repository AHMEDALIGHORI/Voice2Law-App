import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_footer.dart';
import '../widgets/brand.dart';
import '../widgets/staggered_entrance.dart';
import 'text_assistant_screen.dart';
import 'voice_assistant_screen.dart';

/// `AskQuestionPage.tsx` – choose between the voice and the text assistant.
class AskQuestionScreen extends StatelessWidget {
  const AskQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientPage),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        children: <Widget>[
          const StaggeredEntrance(
            index: 0,
            child: BrandPill(
              label: 'AI-Powered Legal Assistant',
              icon: Icons.auto_awesome,
            ),
          ),
          const SizedBox(height: 16),
          const StaggeredEntrance(
            index: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ask Your Legal Question',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10),
                UrduText(
                  'اپنا قانونی سوال پوچھیں',
                  size: 19,
                  align: TextAlign.left,
                ),
                SizedBox(height: 12),
                Text(
                  'Choose your preferred method to ask questions about Pakistani law. '
                  'Get instant answers in Urdu or English.',
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.6,
                    color: Color(0xAE0B3D2E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          StaggeredEntrance(
            index: 2,
            child: _MethodCard(
              icon: Icons.mic,
              title: 'Voice Input',
              titleUrdu: 'آواز میں اپنا سوال پوچھیں',
              description:
                  'Simply speak your question in Urdu or English. Voice2Law transcribes it and provides accurate '
                  'legal information instantly.',
              accent: AppColors.emerald,
              buttonLabel: 'Start Voice Assistant',
              buttonKind: ButtonStyleKind.primary,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (BuildContext context) =>
                      const VoiceAssistantScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          StaggeredEntrance(
            index: 3,
            child: _MethodCard(
              icon: Icons.description_outlined,
              title: 'Text Input',
              titleUrdu: 'تحریری سوال',
              description:
                  'Type your question and get a structured answer with the relevant law section, always available '
                  'even without a microphone.',
              accent: AppColors.gold,
              buttonLabel: 'Start Text Assistant',
              buttonKind: ButtonStyleKind.gold,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (BuildContext context) =>
                      const TextAssistantScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const StaggeredEntrance(index: 4, child: _HelpCard()),
          const SizedBox(height: 20),
          // AI Tools nudge
          StaggeredEntrance(
            index: 5,
            child: BrandCard(
              borderColor: AppColors.emerald.withValues(alpha: 0.3),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppColors.emerald, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '13 AI Legal Tools',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        Text(
                          'Document drafts, scam detection, rights checker & more',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (ctx) => TextButton(
                      onPressed: () => Navigator.of(ctx).pushNamed('/ai-tools'),
                      child: const Text('Explore'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.titleUrdu,
    required this.description,
    required this.accent,
    required this.buttonLabel,
    required this.buttonKind,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String titleUrdu;
  final String description;
  final Color accent;
  final String buttonLabel;
  final ButtonStyleKind buttonKind;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      onTap: onPressed,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[accent, AppColors.darkGreen],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.white, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          UrduText(titleUrdu, size: 16, color: AppColors.goldText),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.darkGreen.withValues(alpha: 0.70),
            ),
          ),
          const SizedBox(height: 18),
          BrandButton(
            label: buttonLabel,
            icon: icon,
            kind: buttonKind,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard();

  static const List<String> _points = <String>[
    'Instant Responses',
    'Bilingual Support',
    'Accurate Information',
    '24/7 Available',
  ];

  static const List<String> _details = <String>[
    'Get immediate answers to your legal questions without waiting.',
    'Ask questions in Urdu or English, get answers in your language.',
    'Based on Pakistani law and legal precedents.',
    'Access legal information anytime, anywhere.',
  ];

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.forum, color: AppColors.emerald, size: 24),
              SizedBox(width: 10),
              Text(
                'How It Helps You',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (int index = 0; index < _points.length; index++) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 15,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _points[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _details[index],
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (index != _points.length - 1) const SizedBox(height: 16),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Important: This service provides general legal information, not legal advice. '
              'For specific legal matters, please consult a qualified lawyer.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.darkGreen.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
