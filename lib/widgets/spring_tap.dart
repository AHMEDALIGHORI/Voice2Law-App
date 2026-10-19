import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that adds a spring-physics scaling effect when tapped.
class SpringTap extends StatefulWidget {
  /// The child widget to display.
  final Widget child;

  /// The callback to invoke when tapped.
  final VoidCallback? onTap;

  /// Whether the tap effect and callback are enabled.
  final bool enabled;

  /// Creates a SpringTap widget.
  const SpringTap({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<SpringTap> createState() => _SpringTapState();
}

class _SpringTapState extends State<SpringTap> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _isPressed = false;
    });
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: _isPressed
            ? const Duration(milliseconds: 80)
            : const Duration(milliseconds: 200),
        curve: _isPressed ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}
