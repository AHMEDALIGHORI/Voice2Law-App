import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/contact_links.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'find_lawyers_screen.dart';

/// Full profile of a lawyer (mobile addition to the website's lawyer cards).
class LawyerDetailScreen extends StatelessWidget {
  const LawyerDetailScreen({super.key, required this.lawyer});

  final Lawyer lawyer;

  @override
  Widget build(BuildContext context) {
    final Uri? callUri = ContactLinks.tel(lawyer.phoneNumber);
    final Uri? whatsappUri = ContactLinks.whatsapp(lawyer.whatsapp);
    final Uri? emailUri = ContactLinks.mailto(lawyer.email);
    return Scaffold(
      appBar: AppBar(title: const Text('Lawyer Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: <Widget>[
          Center(
            child: Hero(
              tag: 'lawyer-avatar-${lawyer.id}',
              child: LawyerAvatar(lawyer: lawyer, radius: 56),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'lawyer-name-${lawyer.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        lawyer.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
                ),
                if (lawyer.verified) ...<Widget>[
                  const SizedBox(width: 8),
                  const Icon(Icons.verified, color: AppColors.emerald),
                ],
              ],
            ),
          ),
          if (lawyer.nameUrdu.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Center(child: UrduText(lawyer.nameUrdu, size: 18)),
          ],
          const SizedBox(height: 14),
          Center(child: StatusChip(label: lawyer.availability)),
          const SizedBox(height: 20),
          BrandCard(
            child: Column(
              children: <Widget>[
                _Row(
                  icon: Icons.star,
                  label: 'Rating',
                  value:
                      '${lawyer.rating.toStringAsFixed(1)} (${lawyer.reviewCount} reviews)',
                ),
                _Row(
                  icon: Icons.work_outline,
                  label: 'Experience',
                  value: '${lawyer.experience} years',
                ),
                _Row(
                  icon: Icons.account_balance_outlined,
                  label: 'Court',
                  value: lawyer.courtLocation,
                ),
                _Row(
                  icon: Icons.location_city,
                  label: 'City',
                  value: lawyer.city,
                ),
                _Row(
                  icon: Icons.translate,
                  label: 'Languages',
                  value: lawyer.languages.join(', '),
                ),
                if (lawyer.barCouncilNo.isNotEmpty)
                  _Row(
                    icon: Icons.badge_outlined,
                    label: 'Bar Council No.',
                    value: lawyer.barCouncilNo,
                  ),
                _Row(
                  icon: Icons.call,
                  label: 'Phone',
                  value: lawyer.phoneNumber,
                ),
                if (lawyer.email.isNotEmpty)
                  _Row(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    value: lawyer.email,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          BrandCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Areas of Expertise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lawyer.expertise
                      .map(
                        (String area) => Chip(
                          label: Text(area),
                          backgroundColor: AppColors.lightGreen,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          BrandButton(
            label: callUri == null
                ? 'Call unavailable'
                : 'Call ${lawyer.phoneNumber}',
            icon: Icons.call,
            onPressed: callUri == null ? null : () => launchUrl(callUri),
          ),
          const SizedBox(height: 12),
          BrandButton(
            label: 'Message on WhatsApp',
            icon: Icons.chat,
            kind: ButtonStyleKind.gold,
            onPressed: whatsappUri == null
                ? null
                : () => launchUrl(
                    whatsappUri,
                    mode: LaunchMode.externalApplication,
                  ),
          ),
          if (emailUri != null) ...<Widget>[
            const SizedBox(height: 12),
            BrandButton(
              label: 'Send an email',
              icon: Icons.mail_outline,
              kind: ButtonStyleKind.outline,
              onPressed: () => launchUrl(emailUri),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'Contacting a lawyer through Voice2Law does not create an attorney-client '
            'relationship. Always verify the bar council number before hiring.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.emerald),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.darkGreen),
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
