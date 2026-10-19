import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A widget that applies a shimmering gradient effect to its child.
///
/// Useful for creating skeleton loading states to replace standard progress indicators.
class ShimmerEffect extends StatefulWidget {
  /// The widget over which the shimmer effect will be applied.
  final Widget child;

  /// The base color of the shimmer. Defaults to [AppColors.lightGreen].
  final Color? baseColor;

  /// The highlight color of the shimmer. Defaults to a lighter shade of lightGreen.
  final Color? highlightColor;

  /// Creates a [ShimmerEffect].
  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppColors.lightGreen;
    final highlight = widget.highlightColor ?? const Color(0xFFF5FBF7);

    return ClipRRect(
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(_animation.value, 0.0),
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      base.withValues(alpha: 0.0),
                      highlight,
                      base.withValues(alpha: 0.0),
                    ],
                    stops: const [0.1, 0.5, 0.9],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple rounded rectangle placeholder for shimmer effects.
class ShimmerBox extends StatelessWidget {
  /// The width of the placeholder.
  final double? width;

  /// The height of the placeholder.
  final double? height;

  /// The border radius of the placeholder. Defaults to 8.0.
  final double borderRadius;

  /// The shape of the placeholder. Defaults to [BoxShape.rectangle].
  final BoxShape shape;

  /// Creates a [ShimmerBox].
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
        shape: shape,
      ),
    );
  }
}

/// A skeleton loader mimicking the layout of a lawyer card.
class LawyerCardShimmer extends StatelessWidget {
  /// Creates a [LawyerCardShimmer].
  const LawyerCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ShimmerEffect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(
                  width: 60.0,
                  height: 60.0,
                  shape: BoxShape.circle,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      const ShimmerBox(width: 150.0, height: 16.0),
                      const SizedBox(height: 8.0),
                      const ShimmerBox(width: 100.0, height: 14.0),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: const [
                ShimmerBox(width: 60.0, height: 24.0, borderRadius: 12.0),
                SizedBox(width: 8.0),
                ShimmerBox(width: 80.0, height: 24.0, borderRadius: 12.0),
                SizedBox(width: 8.0),
                ShimmerBox(width: 70.0, height: 24.0, borderRadius: 12.0),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerBox(width: 120.0, height: 14.0),
                Row(
                  children: const [
                    ShimmerBox(
                      width: 32.0,
                      height: 32.0,
                      shape: BoxShape.circle,
                    ),
                    SizedBox(width: 8.0),
                    ShimmerBox(
                      width: 32.0,
                      height: 32.0,
                      shape: BoxShape.circle,
                    ),
                    SizedBox(width: 8.0),
                    ShimmerBox(
                      width: 32.0,
                      height: 32.0,
                      shape: BoxShape.circle,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of skeleton loaders mimicking a list of lawyer cards.
class LawyerListShimmer extends StatelessWidget {
  /// The number of skeleton cards to display. Defaults to 4.
  final int itemCount;

  /// Creates a [LawyerListShimmer].
  const LawyerListShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 16.0),
            child: const LawyerCardShimmer(),
          ),
        ),
      ),
    );
  }
}
