import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/routes.dart';
import '../data/content_data.dart';
import '../theme/app_theme.dart';
import 'brand.dart';

/// Mobile translation of `src/components/Footer.tsx`: brand block, quick links,
/// contact details, the legal notice and the copyright row.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientGreen),
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientEmeraldToDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.balance,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Voice2Law',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  UrduText(
                    'قانونی معلومات کا اردو اسسٹنٹ',
                    size: 12,
                    color: AppColors.gold,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Empowering Urdu-speaking citizens with accessible legal information through AI-powered '
            'voice and text assistance. Making Pakistani law understandable for everyone.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.82),
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              _social(
                Icons.facebook,
                () => _open(context, 'https://facebook.com'),
              ),
              const SizedBox(width: 12),
              _social(
                Icons.alternate_email,
                () => _open(context, 'https://twitter.com'),
              ),
              const SizedBox(width: 12),
              _social(Icons.code, () => _open(context, 'https://github.com')),
            ],
          ),
          const SizedBox(height: 24),
          // Quick links – same anchors used by the website footer.
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: <Widget>[
              _link(context, 'About Project', AppRoutes.about),
              _link(context, 'Features', AppRoutes.home),
              _link(context, 'Technology', AppRoutes.home),
              _link(context, 'Team', AppRoutes.home),
              _link(context, 'Legal Topics', AppRoutes.legalTopics),
              _link(context, 'Find Lawyers', AppRoutes.findLawyers),
              _link(context, 'Contact', AppRoutes.contact),
              _link(context, 'Settings', AppRoutes.settings),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Contact',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _contactRow(
            Icons.mail_outline,
            ContentData.footerEmail,
            () => _open(context, 'mailto:${ContentData.footerEmail}'),
          ),
          _contactRow(
            Icons.phone_outlined,
            ContentData.footerPhone,
            () => _open(context, 'tel:+923001234567'),
          ),
          _contactRow(
            Icons.location_on_outlined,
            ContentData.footerAddress,
            null,
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(Icons.error_outline, color: AppColors.gold, size: 19),
                    SizedBox(width: 8),
                    Text(
                      'Important Legal Notice',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Voice2Law provides legal information summaries and educational content only. '
                  'This is not legal advice. For specific legal matters, please consult a qualified '
                  'lawyer. We do not create attorney-client relationships through this service.',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.92),
                    fontSize: 12.5,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                UrduText(
                  'Voice2Law صرف قانونی معلومات فراہم کرتا ہے، قانونی مشورہ نہیں۔ اپنے مخصوص معاملات کے لیے کسی وکیل سے رابطہ کریں۔',
                  size: 12.5,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          Text(
            '© 2024 Voice2Law. Final Year Project. All rights reserved.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              _link(context, 'Privacy Policy', AppRoutes.about),
              const SizedBox(width: 18),
              _link(context, 'Terms of Use', AppRoutes.about),
            ],
          ),
        ],
      ),
    );
  }

  Widget _social(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 19),
      ),
    );
  }

  Widget _link(BuildContext context, String label, String route) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.white, fontSize: 13.5),
      ),
    );
  }

  Widget _contactRow(IconData icon, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppColors.emerald, size: 18),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
