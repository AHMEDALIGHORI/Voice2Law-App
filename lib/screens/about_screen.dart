import 'package:flutter/material.dart';

import '../data/fallback_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/brand.dart';
import '../widgets/info_card.dart';
import '../widgets/sections/home_sections.dart';

/// `AboutPage.tsx` – mission, vision, values, stats, about and team sections.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<InfoCardData> _values = <InfoCardData>[
    InfoCardData(
      icon: Icons.favorite_outline,
      title: 'Accessibility',
      titleUrdu: 'رسائی',
      description:
          'Making legal information accessible to every Pakistani in their native language.',
    ),
    InfoCardData(
      icon: Icons.workspace_premium_outlined,
      title: 'Accuracy',
      titleUrdu: 'درستگی',
      description:
          'Providing accurate legal information based on Pakistani law and regulations.',
      accent: 0xFFC5A253,
      accentEnd: 0xFFD4B76E,
    ),
    InfoCardData(
      icon: Icons.people_outline,
      title: 'Empowerment',
      titleUrdu: 'بااختیار بنانا',
      description:
          'Empowering citizens with knowledge of their legal rights and obligations.',
    ),
    InfoCardData(
      icon: Icons.bolt,
      title: 'Innovation',
      titleUrdu: 'جدت',
      description:
          'Using cutting-edge AI technology to bridge the legal information gap.',
      accent: 0xFFC5A253,
      accentEnd: 0xFFD4B76E,
    ),
  ];

  static const List<List<String>> _stats = <List<String>>[
    <String>['10,000+', 'Legal Topics Covered', 'قانونی موضوعات'],
    <String>['24/7', 'Always Available', 'ہمیشہ دستیاب'],
    <String>['2', 'Languages Supported', 'زبانیں'],
    <String>['99%', 'Accuracy Rate', 'درستگی کی شرح'],
  ];

  /// Mission / vision style card used twice on the page.
  Widget _block({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String titleUrdu,
    required String body,
  }) {
    return BrandCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          UrduText(titleUrdu, size: 16, color: AppColors.goldText),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: AppColors.darkGreen.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'About',
      titleUrdu: 'تعارف',
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(gradient: AppColors.gradientPage),
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
            child: Column(
              children: <Widget>[
                const BrandPill(
                  label: 'About Voice2Law',
                  icon: Icons.track_changes,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bridging the Legal Knowledge Gap',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                const UrduText('قانونی معلومات کو سب تک پہنچانا', size: 18),
                const SizedBox(height: 12),
                Text(
                  "Voice2Law is Pakistan's first AI-powered legal information assistant that "
                  'provides instant access to legal knowledge in Urdu, making justice accessible '
                  'to everyone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.darkGreen.withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    for (int index = 0; index < _stats.length; index++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _StatCard(
                            number: _stats[index][0],
                            label: _stats[index][1],
                            labelUrdu: _stats[index][2],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: <Widget>[
                _block(
                  icon: Icons.track_changes,
                  iconColor: AppColors.emerald,
                  title: 'Our Mission',
                  titleUrdu: 'ہمارا مقصد',
                  body:
                      'To democratize access to legal information in Pakistan by providing '
                      'instant, accurate and easy-to-understand legal guidance in Urdu. We '
                      'believe that every citizen has the right to understand their legal rights.',
                ),
                const SizedBox(height: 16),
                _block(
                  icon: Icons.visibility_outlined,
                  iconColor: AppColors.goldText,
                  title: 'Our Vision',
                  titleUrdu: 'ہمارا نظارہ',
                  body:
                      'A Pakistan where every citizen, regardless of language, literacy or '
                      'income, can access reliable legal information and make informed '
                      'decisions with confidence.',
                ),
              ],
            ),
          ),
          const AboutSection(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 26, 20, 0),
            child: SectionHeader(title: 'Our Values'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: <Widget>[
                for (final InfoCardData value in _values) ...<Widget>[
                  InfoCardTile(data: value),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          const TeamSection(),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.number,
    required this.label,
    required this.labelUrdu,
  });

  final String number;
  final String label;
  final String labelUrdu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            number,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.emerald,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.3,
              color: AppColors.darkGreen.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 2),
          UrduText(labelUrdu, size: 10.5, color: AppColors.goldText),
        ],
      ),
    );
  }
}
