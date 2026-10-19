import 'dart:async';

import 'package:flutter/material.dart';

/// Wraps any widget to animate it onto the screen with a smooth staggered
/// fade-and-slide motion using spring physics.
///
/// Designed to give mobile screens a choreographed entrance (Apple / OneUI style).
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 650),
    this.slideOffset = const Offset(0.0, 0.25),
  });

  /// The child widget to reveal.
  final Widget child;

  /// Stagger sequence index (used to calculate delay: index * 90ms).
  final int index;

  /// Additional fixed delay before animation triggers.
  final Duration delay;

  /// Total duration of the entrance motion.
  final Duration duration;

  /// Initial slide offset before arriving at [Offset.zero].
  final Offset slideOffset;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _entranceTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    final int calculatedDelayMs =
        widget.delay.inMilliseconds + (widget.index * 85);
    // Use a cancellable Timer (not Future.delayed) so the pending callback is
    // torn down in dispose(), preventing "A Timer is still pending" test
    // failures and avoiding work after the widget leaves the tree.
    _entranceTimer = Timer(Duration(milliseconds: calculatedDelayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
