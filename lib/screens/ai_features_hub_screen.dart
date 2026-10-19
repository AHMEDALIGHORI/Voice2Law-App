import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../core/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/legal_ux_components.dart';

/// Hub screen showing all AI-powered features as a grid of cards.
class AiFeaturesHubScreen extends StatelessWidget {
  const AiFeaturesHubScreen({super.key});

  static const List<_FeatureCard> _features = <_FeatureCard>[
    _FeatureCard(
      icon: Icons.photo_camera_outlined,
      title: 'Snap & Explain',
      titleUrdu: 'تصویر سے وضاحت',
      subtitle: 'Photo of a legal document → plain explanation',
      route: AppRoutes.documentExplainer,
      color: Color(0xFF6A1B9A),
    ),
    _FeatureCard(
      icon: Icons.verified_user_outlined,
      title: 'My Rights',
      titleUrdu: 'میرے حقوق',
      subtitle: 'Offline quick rights cards for common situations',
      route: AppRoutes.rightsScenarios,
      color: Color(0xFF1B5E20),
    ),
    _FeatureCard(
      icon: Icons.description_outlined,
      title: 'Document Generator',
      titleUrdu: 'قانونی دستاویز ساز',
      subtitle: 'Drafts legal documents ready to file',
      route: AppRoutes.docGenerator,
      color: Color(0xFF1565C0),
    ),
    _FeatureCard(
      icon: Icons.document_scanner_outlined,
      title: 'Document Explainer',
      titleUrdu: 'دستاویز کا آسان بیان',
      subtitle: 'Paste any legal document & understand it',
      route: AppRoutes.docScanner,
      color: Color(0xFF6A1B9A),
    ),
    _FeatureCard(
      icon: Icons.timer_outlined,
      title: 'Deadline Calculator',
      titleUrdu: 'قانونی مدت حساب',
      subtitle: 'Calculates limitation periods automatically',
      route: AppRoutes.deadlineCalc,
      color: Color(0xFFC62828),
    ),
    _FeatureCard(
      icon: Icons.chat_bubble_outline,
      title: 'Case Intake',
      titleUrdu: 'مقدمہ کی تفصیل',
      subtitle: 'AI asks follow-up questions for full facts',
      route: AppRoutes.caseIntake,
      color: Color(0xFF00695C),
    ),
    _FeatureCard(
      icon: Icons.analytics_outlined,
      title: 'Case Prediction',
      titleUrdu: 'مقدمہ نتیجہ',
      subtitle: 'Estimates likely case outcomes',
      route: AppRoutes.casePrediction,
      color: Color(0xFFE65100),
    ),
    _FeatureCard(
      icon: Icons.verified_user_outlined,
      title: 'Rights Checker',
      titleUrdu: 'حقوق جانچ',
      subtitle: 'Lists your rights and which apply',
      route: AppRoutes.rightsChecker,
      color: Color(0xFF1B5E20),
    ),
    _FeatureCard(
      icon: Icons.notifications_active_outlined,
      title: 'Smart Reminders',
      titleUrdu: 'ذہین یاد دہانی',
      subtitle: 'Legal timeline with action deadlines',
      route: AppRoutes.smartReminders,
      color: Color(0xFF4A148C),
    ),
    _FeatureCard(
      icon: Icons.gavel,
      title: 'Precedent Search',
      titleUrdu: 'عدالتی نظیر',
      subtitle: 'Finds relevant Pakistani case law',
      route: AppRoutes.precedentSearch,
      color: Color(0xFF880E4F),
    ),
    _FeatureCard(
      icon: Icons.help_outline,
      title: 'Term Explainer',
      titleUrdu: 'قانونی اصطلاح',
      subtitle: 'Explains any legal term in plain language',
      route: AppRoutes.termExplainer,
      color: Color(0xFF0277BD),
    ),
    _FeatureCard(
      icon: Icons.search,
      title: 'Statute AI Search',
      titleUrdu: 'قانون تلاش',
      subtitle: 'Natural language search across statutes',
      route: AppRoutes.statuteAiSearch,
      color: Color(0xFF37474F),
    ),
    _FeatureCard(
      icon: Icons.emergency_outlined,
      title: 'Emergency SOS',
      titleUrdu: 'فوری قانونی مدد',
      subtitle: 'Immediate steps for urgent situations',
      route: AppRoutes.emergencySos,
      color: Color(0xFFB71C1C),
    ),
    _FeatureCard(
      icon: Icons.warning_amber_outlined,
      title: 'Scam Detector',
      titleUrdu: 'دھوکہ پکڑیں',
      subtitle: 'Detects legal scams and fraud patterns',
      route: AppRoutes.scamDetector,
      color: Color(0xFFE65100),
    ),
    _FeatureCard(
      icon: Icons.handshake_outlined,
      title: 'Mediation',
      titleUrdu: 'صلح و ثالثی',
      subtitle: 'Suggests alternatives to going to court',
      route: AppRoutes.mediation,
      color: Color(0xFF00838F),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // The tiles stack a title, subtitle and Urdu label under an icon. A fixed
    // square aspect ratio clips them as soon as accessibility text grows, so
    // give each tile a height that follows the active text scale.
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    final double tileHeight =
        184 + (textScale - 1).clamp(0.0, 2.0) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('AI Legal Tools'),
            UrduText(
              'قانونی ذہانت',
              size: 11,
              color: AppColors.gold,
              height: 1.4,
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: LanguageSwitcherChip(
              current: AppScope.of(context).config.languagePreference,
              light: true,
              onChanged: (String lang) async {
                await AppScope.of(
                  context,
                ).config.update(languagePreference: lang);
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          // Cloud status banner
          _cloudStatusBanner(context),
          const SizedBox(height: 18),
          Text(
            '15 AI-powered tools for Pakistani law',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'My Rights and statute search work offline · Other tools need cloud AI',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: tileHeight,
            ),
            itemCount: _features.length,
            itemBuilder: (BuildContext context, int index) {
              return _FeatureTile(feature: _features[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _cloudStatusBanner(BuildContext context) {
    final config = AppScope.of(context).config;
    final bool cloud = config.cloudEnabled;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cloud
            ? AppColors.emerald.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cloud
              ? AppColors.emerald.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            cloud ? Icons.cloud_done_outlined : Icons.cloud_off,
            color: cloud ? AppColors.emerald : AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cloud
                  ? 'Cloud AI active — all 15 tools fully powered'
                  : 'Cloud AI off — basic offline answers only. Enable in Settings.',
              style: TextStyle(
                fontSize: 12.5,
                color: cloud ? AppColors.emeraldText : const Color(0xFF9A4708),
              ),
            ),
          ),
          if (!cloud)
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
              child: const Text('Enable'),
            ),
        ],
      ),
    );
  }
}

class _FeatureCard {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.titleUrdu,
    required this.subtitle,
    required this.route,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String titleUrdu;
  final String subtitle;
  final String route;
  final Color color;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final _FeatureCard feature;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(feature.route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: feature.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: feature.color.withValues(alpha: 0.18),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: feature.color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(feature.icon, color: feature.color, size: 22),
            ),
            const Spacer(),
            Text(
              feature.title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              feature.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            UrduText(
              feature.titleUrdu,
              size: 11,
              color: AppColors.goldText,
              height: 1.6,
            ),
          ],
        ),
      ),
    );
  }
}
