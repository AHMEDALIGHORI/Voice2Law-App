import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_scope.dart';
import '../core/language_helper.dart';
import '../services/ai_features_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/legal_ux_components.dart';

/// A reusable screen template for AI-powered features.
///
/// Features a text input area, a "Generate" button, and a results display
/// with copy and TTS support. All 13 AI features use this same scaffold.
class AiFeatureScreen extends StatefulWidget {
  const AiFeatureScreen({
    super.key,
    required this.title,
    required this.titleUrdu,
    required this.subtitle,
    required this.icon,
    required this.inputHint,
    required this.buttonLabel,
    required this.generator,
    this.maxLines = 4,
    this.prefilledQuery,
  });

  final String title;
  final String titleUrdu;
  final String subtitle;
  final IconData icon;
  final String inputHint;
  final String buttonLabel;
  final int maxLines;
  final String? prefilledQuery;

  /// Called when the user taps the generate button. Returns the AI result.
  final Future<AiFeatureResult> Function(String input) generator;

  @override
  State<AiFeatureScreen> createState() => _AiFeatureScreenState();
}

class _AiFeatureScreenState extends State<AiFeatureScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  AiFeatureResult? _result;
  String _lastStatus = '';

  String get _lang =>
      LanguageHelper.resolve(AppScope.of(context).config.languagePreference);
  bool get _isRtl => LanguageHelper.isRtl(_lang);

  @override
  void initState() {
    super.initState();
    if (widget.prefilledQuery != null) {
      _controller.text = widget.prefilledQuery!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final String input = _controller.text.trim();
    if (input.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final AiFeatureResult result = await widget.generator(input);
      if (!mounted) return;
      final status = AppScope.of(context).aiFeatures.lastStatus ?? '';
      setState(() {
        _result = result;
        _lastStatus = status;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _result = const AiFeatureResult(
          success: false,
          content: 'Something went wrong. Please try again.',
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Keep the header usable at large accessibility text sizes instead of
    // letting the language chip squeeze the title into a tall, wrapping strip.
    final bool compact = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final Widget titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(widget.icon, color: AppColors.gold, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
    final Widget languageSwitcher = MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: LanguageSwitcherChip(
        current: AppScope.of(context).config.languagePreference,
        light: true,
        onChanged: (String lang) async {
          await AppScope.of(context).config.update(languagePreference: lang);
          if (mounted) setState(() {});
        },
      ),
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.gradientGreen,
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
              child: compact
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(context).maybePop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.white,
                              ),
                              tooltip: 'Back',
                            ),
                            const SizedBox(width: 4),
                            Expanded(child: titleBlock),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: languageSwitcher,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.white,
                          ),
                          tooltip: 'Back',
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: titleBlock),
                        languageSwitcher,
                      ],
                    ),
            ),
            // Offline banner
            if (_result != null && _result!.offline)
              OfflineBanner(
                isUrdu: _isRtl,
                statusCode: _lastStatus.isNotEmpty ? _lastStatus : null,
              ),
            // Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: <Widget>[
                  // Urdu subtitle
                  if (widget.titleUrdu.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: UrduText(
                        widget.titleUrdu,
                        size: 16,
                        color: scheme.primary,
                      ),
                    ),
                  // Input card
                  BrandCard(
                    borderColor: AppColors.emerald.withValues(alpha: 0.25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          controller: _controller,
                          maxLines: widget.maxLines,
                          decoration: InputDecoration(
                            hintText: widget.inputHint,
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BrandButton(
                          label: widget.buttonLabel,
                          icon: Icons.auto_awesome,
                          busy: _isLoading,
                          onPressed: _generate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Loading indicator
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            CircularProgressIndicator(strokeWidth: 3),
                            SizedBox(height: 12),
                            Text(
                              'Generating...',
                              style: TextStyle(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Result
                  if (_result != null && !_isLoading) _resultCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard() {
    final r = _result!;
    final scheme = Theme.of(context).colorScheme;
    return BrandCard(
      borderColor: r.success
          ? AppColors.emerald.withValues(alpha: 0.3)
          : AppColors.warning.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                r.success ? Icons.check_circle : Icons.error_outline,
                color: r.success ? AppColors.emerald : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                r.success ? 'Result' : 'Notice',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: r.success ? AppColors.emerald : AppColors.warning,
                ),
              ),
              const Spacer(),
              // Copy button
              IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy_outlined, size: 19),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(ClipboardData(text: r.content));
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
              // TTS button
              if (r.success && AppScope.of(context).config.ttsEnabled)
                IconButton(
                  tooltip: 'Read aloud',
                  icon: const Icon(Icons.volume_up_outlined, size: 19),
                  onPressed: () async {
                    final speech = AppScope.of(context).speech;
                    final urduVoice = speech.urduVoiceLocale;
                    final lang = _lang;
                    final locale = LanguageHelper.ttsLocaleFor(lang, urduVoice);
                    await speech.speak(r.content, locale: locale);
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            r.content,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.7,
              color: scheme.onSurface,
            ),
          ),
          if (r.success) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'General information · verify with a licensed lawyer',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
