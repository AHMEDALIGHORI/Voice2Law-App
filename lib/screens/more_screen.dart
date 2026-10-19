import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../core/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_footer.dart';
import '../widgets/brand.dart';

/// "More" tab – everything that does not deserve its own bottom-nav slot.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppServices services = AppScope.of(context);
    final String apiBase = services.config.apiBaseUrl;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(gradient: AppColors.gradientGreen),
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'More',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              UrduText('مزید صفحات', size: 16, color: AppColors.goldText),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            children: <Widget>[
              _tile(context, Icons.auto_awesome_outlined, 'AI Legal Tools', 'قانونی ذہانت', AppRoutes.aiFeaturesHub),
              _tile(context, Icons.search, 'Search', 'تلاش', AppRoutes.search),
              _tile(
                context,
                Icons.info_outline,
                'About',
                'تعارف',
                AppRoutes.about,
              ),
              _tile(
                context,
                Icons.auto_awesome_outlined,
                'How It Works',
                'طریقۂ کار',
                AppRoutes.howItWorks,
              ),
              _tile(
                context,
                Icons.support_agent,
                'Contact',
                'رابطہ',
                AppRoutes.contact,
              ),
              _tile(
                context,
                Icons.settings_outlined,
                'Settings',
                'سیٹنگز',
                AppRoutes.settings,
              ),
              _tile(
                context,
                Icons.shield_outlined,
                'Admin Login',
                'ایڈمن لاگ اِن',
                AppRoutes.adminLogin,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: BrandCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'App Information',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 12),
                _info('Version', '1.0.0 (1)'),
                _info('Backend', apiBase),
                _info(
                  'Admin token',
                  services.config.apiToken.isEmpty ? 'not set' : 'configured',
                ),
                _info('Mic language', services.config.sttLocale),
                _info('Read aloud', services.config.ttsEnabled ? 'on' : 'off'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const AppFooter(),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    String labelUrdu,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BrandCard(
        padding: const EdgeInsets.all(14),
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.darkGreen, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  UrduText(labelUrdu, size: 13, color: AppColors.goldText),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: AppColors.emerald,
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
