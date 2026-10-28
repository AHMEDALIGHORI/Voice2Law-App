import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_scope.dart';
import '../core/contact_links.dart';
import '../data/content_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/brand.dart';

/// `ContactPage.tsx` – contact cards, message form (`POST /contact`) and FAQs.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _message = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await AppScope.of(context).api.submitContact(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        subject: _subject.text.trim(),
        message: _message.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
      _formKey.currentState?.reset();
      _message.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Contact',
      titleUrdu: 'ہم سے رابطہ کریں',
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(gradient: AppColors.gradientPage),
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
            child: Column(
              children: <Widget>[
                const BrandPill(
                  label: 'Get in Touch',
                  icon: Icons.support_agent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contact Us',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 10),
                const UrduText('ہم سے رابطہ کریں', size: 18),
                const SizedBox(height: 12),
                Text(
                  'Have questions, feedback, or need support? Reach out through any of '
                  'the following channels.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.darkGreen.withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: 22),
                _contactRow(
                  icon: Icons.mail_outline,
                  title: 'Email',
                  value: ContentData.contactEmail,
                  accent: AppColors.emerald,
                ),
                const SizedBox(height: 12),
                _contactRow(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: ContentData.contactPhone,
                  accent: AppColors.gold,
                ),
                const SizedBox(height: 12),
                _contactRow(
                  icon: Icons.location_on_outlined,
                  title: 'Office',
                  value: ContentData.contactAddress,
                  accent: AppColors.emerald,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: BrandCard(
              child: Form(key: _formKey, child: _form()),
            ),
          ),
          const _FaqList(),
        ],
      ),
    );
  }

  /// Contact form body.
  Widget _form() {
    String? required(String? value) => (value == null || value.trim().isEmpty)
        ? 'This field is required'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Send us a message',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Full name'),
          validator: required,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (String? value) {
            final String email = value?.trim() ?? '';
            if (email.isEmpty) return 'Please enter your email';
            if (!email.contains('@')) return 'Enter a valid email address';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone (optional)'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _subject,
          decoration: const InputDecoration(labelText: 'Subject'),
          validator: required,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _message,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Message'),
          validator: required,
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(
                Icons.error_outline,
                size: 18,
                color: AppColors.danger,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (_sent) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.emerald,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Thanks! Your message was received.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.emeraldDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        BrandButton(
          label: 'Send message',
          icon: Icons.send,
          busy: _sending,
          onPressed: _submit,
        ),
      ],
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
  }) {
    return BrandCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        final Uri? uri = icon == Icons.mail_outline
            ? ContactLinks.mailto(value)
            : icon == Icons.phone_outlined
            ? ContactLinks.tel(value)
            : null;
        if (uri != null) launchUrl(uri);
      },
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[accent, AppColors.darkGreen],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGreen.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// FAQ list shown under the contact form.
class _FaqList extends StatelessWidget {
  const _FaqList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 26, 20, 0),
          child: SectionHeader(title: 'Frequently Asked Questions'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: <Widget>[
              for (final FaqData faq in ContentData.faqs) ...<Widget>[
                BrandCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        faq.question,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      UrduText(
                        faq.questionUrdu,
                        size: 14,
                        color: AppColors.goldText,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        faq.answer,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.55,
                          color: AppColors.darkGreen.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
        const AppFooter(),
      ],
    );
  }
}
