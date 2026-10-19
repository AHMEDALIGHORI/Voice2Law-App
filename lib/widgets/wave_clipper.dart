import 'package:flutter/material.dart';

/// A [CustomClipper] that cuts a smooth organic wave at the bottom of a
/// container, creating a flowing visual transition between sections.
///
/// Used primarily at the bottom of the hero section to replace the abrupt
/// flat edge with a premium curved boundary.
class WaveSectionClipper extends CustomClipper<Path> {
  const WaveSectionClipper({this.waveHeight = 40});

  /// The vertical amplitude of the wave curve in logical pixels.
  final double waveHeight;

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - waveHeight);

    // First curve: rises up
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - waveHeight * 0.5,
    );

    // Second curve: dips down then rises
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - waveHeight,
      size.width,
      size.height - waveHeight * 0.25,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant WaveSectionClipper oldClipper) =>
      waveHeight != oldClipper.waveHeight;
}

/// A [CustomClipper] that creates a gentle concave (inward) curve at the top
/// of a section, designed to visually receive the outgoing wave from the
/// section above.
class InwardWaveClipper extends CustomClipper<Path> {
  const InwardWaveClipper({this.depth = 20});

  final double depth;

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.moveTo(0, depth);
    path.quadraticBezierTo(size.width * 0.5, -depth, size.width, depth);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant InwardWaveClipper oldClipper) =>
      depth != oldClipper.depth;
}

/// Convenience widget that applies [WaveSectionClipper] to its child and adds
/// extra bottom padding so the wave doesn't clip content.
class WaveSection extends StatelessWidget {
  const WaveSection({super.key, required this.child, this.waveHeight = 40});

  final Widget child;
  final double waveHeight;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveSectionClipper(waveHeight: waveHeight),
      child: child,
    );
  }
}
