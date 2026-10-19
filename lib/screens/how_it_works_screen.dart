import 'package:flutter/material.dart';

import '../data/fallback_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/brand.dart';
import '../widgets/info_card.dart';
import '../widgets/sections/home_sections.dart';

/// `HowItWorksPage.tsx` – the four steps, the AI features, security notes and
/// the technology stack.
class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  static const List<InfoCardData> _aiFeatures = <InfoCardData>[
    InfoCardData(
      icon: Icons.mic,
      title: 'Voice Recognition',
      titleUrdu: 'آواز کی شناخت',
      description:
          'Advanced speech-to-text powered by Whisper AI converts your Urdu speech into text with high accuracy.',
    ),
    InfoCardData(
      icon: Icons.psychology,
      title: 'Natural Language Processing',
      titleUrdu: 'قدرتی زبان کی پروسیسنگ',
      description:
          'AI understands context, intent, and nuances of your legal questions in both Urdu and English.',
      accent: 0xFFC5A253,
      accentEnd: 0xFFD4B76E,
    ),
    InfoCardData(
      icon: Icons.storage,
      title: 'Legal Knowledge Base',
      titleUrdu: 'قانونی معلوماتی ذخیرہ',
      description:
          'Comprehensive database of Pakistani laws, ordinances, and legal precedents updated regularly.',
    ),
    InfoCardData(
      icon: Icons.forum,
      title: 'Intelligent Responses',
      titleUrdu: 'ذہین جوابات',
      description:
          'AI generates clear, accurate responses in simple language with relevant legal references.',
      accent: 0xFFC5A253,
      accentEnd: 0xFFD4B76E,
    ),
  ];

  static const List<InfoCardData> _security = <InfoCardData>[
    InfoCardData(
      icon: Icons.shield_outlined,
      title: 'Privacy Protected',
      description:
          'Your questions and conversations stay on your device unless the API is configured.',
    ),
    InfoCardData(
      icon: Icons.bolt,
      title: 'Fast Processing',
      description:
          'Get instant responses within seconds using optimized AI algorithms.',
      accent: 0xFFC5A253,
      accentEnd: 0xFFD4B76E,
    ),
    InfoCardData(
      icon: Icons.verified_outlined,
      title: 'Verified Information',
      description:
          'All legal information is cross-verified with official sources.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'How It Works',
      titleUrdu: 'یہ کیسے کام کرتا ہے',
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(gradient: AppColors.gradientPage),
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
            child: Column(
              children: <Widget>[
                const BrandPill(
                  label: 'The Technology Behind Voice2Law',
                  icon: Icons.bolt,
                ),
                const SizedBox(height: 16),
                const Text(
                  'How It Works',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 10),
                const UrduText('یہ کیسے کام کرتا ہے', size: 18),
                const SizedBox(height: 12),
                Text(
                  'Voice2Law combines cutting-edge AI technology with comprehensive legal '
                  'knowledge to deliver instant, accurate legal information in your language.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.darkGreen.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
          const HowItWorksSection(),
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
            child: const SectionHeader(
              title: 'Powerful AI Features',
              titleUrdu: 'طاقتور AI خصوصیات',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: <Widget>[
                for (final InfoCardData feature in _aiFeatures) ...<Widget>[
                  InfoCardTile(data: feature),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
            child: const SectionHeader(
              title: 'Security & Privacy',
              titleUrdu: 'سیکیورٹی اور پرائیویسی',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: <Widget>[
                for (final InfoCardData item in _security) ...<Widget>[
                  InfoCardTile(data: item),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          const TechStackSection(),
          const AppFooter(),
        ],
      ),
    );
  }
}
