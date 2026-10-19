import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/fallback_data.dart';
import '../../theme/app_theme.dart';
import '../brand.dart';
import '../spring_tap.dart';
import '../wave_clipper.dart';

/// `Hero.tsx` – the landing block: headline, live waveform, Urdu word orbit and
/// the two call-to-action buttons that open the voice / text assistants.
///
/// Now features an organic curved bottom edge via [WaveSection] and
/// interactive orbit topic chips via [onTopicTap].
class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onVoice,
    required this.onText,
    this.onSearch,
    this.onTopicTap,
  });

  final VoidCallback onVoice;
  final VoidCallback onText;
  final VoidCallback? onSearch;

  /// Called when one of the orbiting Urdu topic chips is tapped.
  /// Receives the topic's English label (e.g. "Family Law").
  final void Function(String topic)? onTopicTap;

  @override
  Widget build(BuildContext context) {
    return WaveSection(
      waveHeight: 36,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.gradientGreen),
        // Extra bottom padding to account for the wave clip area
        padding: const EdgeInsets.fromLTRB(20, 34, 20, 76),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const BrandPill(
              label: 'AI-Powered Legal Assistant',
              icon: Icons.auto_awesome,
              onDark: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Voice2Law',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 46,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            const UrduText(
              'قانونی معلومات کا اردو اسسٹنٹ',
              size: 21,
              color: Colors.white,
            ),
            const SizedBox(height: 14),
            Text(
              FallbackData.heroSubtitle,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.88),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            const _Waveform(),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: BrandButton(
                    label: 'Ask by Voice',
                    icon: Icons.mic,
                    kind: ButtonStyleKind.gold,
                    onPressed: onVoice,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BrandButton(
                    label: 'Ask by Text',
                    icon: Icons.description_outlined,
                    kind: ButtonStyleKind.light,
                    onPressed: onText,
                  ),
                ),
              ],
            ),
            if (onSearch != null) ...<Widget>[
              const SizedBox(height: 12),
              BrandButton(
                label: 'Search legal information',
                icon: Icons.search,
                kind: ButtonStyleKind.outline,
                onPressed: onSearch,
              ),
            ],
            const SizedBox(height: 28),
            _UrduOrbit(onTopicTap: onTopicTap),
          ],
        ),
      ),
    );
  }
}

/// Animated voice bars (the website used a static CSS waveform animation).
class _Waveform extends StatefulWidget {
  const _Waveform();

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List<Widget>.generate(28, (int index) {
              final double phase = (_controller.value + index / 28) % 1.0;
              final double wave = math.sin(phase * math.pi * 2);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Container(
                    height: 10 + (wave + 1) * 20,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(
                        alpha: 0.45 + wave * 0.35,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// The five floating Urdu words orbiting the scale icon.
class _UrduOrbit extends StatefulWidget {
  const _UrduOrbit({this.onTopicTap});

  final void Function(String topic)? onTopicTap;

  @override
  State<_UrduOrbit> createState() => _UrduOrbitState();
}

class _UrduOrbitState extends State<_UrduOrbit>
    with SingleTickerProviderStateMixin {
  // Angles match Hero.tsx: top, upper right, lower right, lower left, upper left.
  static const List<double> _angles = <double>[-90, -18, 54, 126, 198];
  static const double _radius = 100;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: 1 + _controller.value * 0.06,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.balance,
                  color: AppColors.emerald,
                  size: 56,
                ),
              ),
            ),
            for (
              int index = 0;
              index < FallbackData.heroOrbitWords.length;
              index++
            )
              _orbitLabel(FallbackData.heroOrbitWords[index], index),
          ],
        ),
      ),
    );
  }

  Widget _orbitLabel(InfoCardData data, int index) {
    final double radians = _angles[index] * math.pi / 180;
    final double dx = math.cos(radians) * _radius;
    final double dy = math.sin(radians) * _radius;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        // Gentle float, phase shifted per word (like `animate-float`).
        final double phase = (_controller.value + index * 0.2) % 1.0;
        final double lift = math.sin(phase * math.pi * 2) * 5;
        return Transform.translate(offset: Offset(dx, dy + lift), child: child);
      },
      child: SpringTap(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTopicTap?.call(data.title);
        },
        child: Container(
          width: 96,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(data.accent), width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: UrduText(data.title, size: 16, color: AppColors.darkGreen),
        ),
      ),
    );
  }
}
