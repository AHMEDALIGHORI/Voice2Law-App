import 'package:flutter/material.dart';

import '../../data/fallback_data.dart';
import '../../theme/app_theme.dart';
import '../brand.dart';
import '../info_card.dart';

/// `About.tsx` – problem / solution / scope / technologies.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.offWhite,
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 32),
      child: Column(
        children: <Widget>[
          const SectionHeader(
            title: 'About Voice2Law',
            subtitle:
                'Bridging the gap between legal knowledge and Urdu-speaking citizens through AI innovation',
          ),
          const SizedBox(height: 24),
          for (final InfoCardData card in FallbackData.aboutCards) ...<Widget>[
            InfoCardTile(data: card, showTopAccent: true),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

/// `HowItWorks.tsx` – the four step pipeline.
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 32),
      child: Column(
        children: <Widget>[
          const SectionHeader(
            title: 'How It Works',
            titleUrdu: 'یہ کیسے کام کرتا ہے',
            subtitle: 'Four simple steps to access legal information in Urdu',
          ),
          const SizedBox(height: 24),
          for (
            int index = 0;
            index < FallbackData.howItWorksSteps.length;
            index++
          ) ...<Widget>[
            _StepRow(
              data: FallbackData.howItWorksSteps[index],
              isLast: index == FallbackData.howItWorksSteps.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

/// A single numbered step with the connector line used on desktop.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.data, required this.isLast});

  final InfoCardData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color accent = Color(data.accent);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 46,
            child: Column(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[accent, Color(data.accentEnd)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    data.badge,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: accent.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.darkGreen.withValues(alpha: 0.10),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.darkGreen.withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(data.icon, color: accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  UrduText(data.titleUrdu, size: 15, color: AppColors.goldText),
                  const SizedBox(height: 8),
                  Text(
                    data.description,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: AppColors.darkGreen.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `Features.tsx` – dark gradient section.
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.gradientGreen),
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 34),
      child: Column(
        children: <Widget>[
          const SectionHeader(
            title: 'Powerful Features',
            titleUrdu: 'طاقتور خصوصیات',
            subtitle: 'Everything you need to access legal information in Urdu',
            onDark: true,
          ),
          const SizedBox(height: 24),
          for (final InfoCardData feature in FallbackData.features) ...<Widget>[
            InfoCardTile(data: feature, onDark: true),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.20),
              ),
            ),
            child: Text(
              'Criminal Law Basics also covered • Designed for the Pakistani Legal System',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.9),
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `TechStack.tsx` – technology grid plus the small badges.
class TechStackSection extends StatelessWidget {
  const TechStackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.offWhite,
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 32),
      child: Column(
        children: <Widget>[
          const SectionHeader(
            title: 'Technology Stack',
            titleUrdu: 'ٹیکنالوجی اسٹیک',
            subtitle:
                'Built with cutting-edge technologies for optimal performance',
          ),
          const SizedBox(height: 24),
          for (final InfoCardData item in FallbackData.techStack) ...<Widget>[
            InfoCardTile(data: item),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 4),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: FallbackData.techBadges
                .map(
                  (String badge) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.darkGreen.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// `Team.tsx` – supervisor card and student cards with the bundled photos.
class TeamSection extends StatelessWidget {
  const TeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TeamMemberData supervisor = FallbackData.supervisor;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 32),
      child: Column(
        children: <Widget>[
          const SectionHeader(
            title: 'FYP Team',
            titleUrdu: 'ٹیم',
            subtitle: 'Final Year Project • Computer Science',
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.gradientGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 3),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  supervisor.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  supervisor.rollNo,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  supervisor.role,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
                Text(
                  supervisor.specialty,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final TeamMemberData member in FallbackData.team) ...<Widget>[
            _MemberCard(member: member),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final TeamMemberData member;

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      padding: const EdgeInsets.all(22),
      borderColor: AppColors.emerald.withValues(alpha: 0.35),
      gradient: AppColors.gradientGreen,
      child: Column(
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 3),
              image: DecorationImage(
                image: AssetImage(member.imageAsset),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
            ),
            child: Text(
              member.role,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.goldLight,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.rollNo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.white.withValues(alpha: 0.20)),
          const SizedBox(height: 8),
          Text(
            member.specialty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// `SDGMapping.tsx` – UN sustainable development goal cards.
class SdgSection extends StatelessWidget {
  const SdgSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientPage),
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 34),
      child: Column(
        children: <Widget>[
          const SectionHeader(
            title: 'UN SDG Alignment',
            titleUrdu: 'اقوام متحدہ کے پائیدار ترقی کے اہداف',
            subtitle: 'Contributing to global sustainable development goals',
          ),
          const SizedBox(height: 24),
          for (final InfoCardData goal in FallbackData.sdgGoals) ...<Widget>[
            InfoCardTile(data: goal),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.emerald.withValues(alpha: 0.25),
              ),
            ),
            child: const Text(
              'Voice2Law is committed to making a positive impact on society '
              'through technology and innovation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
