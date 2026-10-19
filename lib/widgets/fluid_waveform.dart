import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A fluid, multi-harmonic Bezier audio visualizer widget.
///
/// Unlike standard blocky bar equalizers, this painter renders multiple
/// overlapping sinusoidal Bezier waves with brand gradients, glow effects,
/// and reactive amplitude mapped to the microphone's live decibel input.
class FluidWaveform extends StatefulWidget {
  const FluidWaveform({
    super.key,
    required this.isRecording,
    this.soundLevel = 0.15,
    this.height = 110,
    this.colorScheme = WaveformColorScheme.brand,
  });

  /// Whether voice capture is actively listening.
  final bool isRecording;

  /// Normalized sound level (0.0 to 1.0).
  final double soundLevel;

  /// Height of the waveform canvas.
  final double height;

  /// Color palette for the rendering waves.
  final WaveformColorScheme colorScheme;

  @override
  State<FluidWaveform> createState() => _FluidWaveformState();
}

enum WaveformColorScheme { brand, gold, emerald }

class _FluidWaveformState extends State<FluidWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _FluidWaveformPainter(
            phase: _controller.value * 2 * math.pi,
            soundLevel: widget.soundLevel,
            isRecording: widget.isRecording,
            colorScheme: widget.colorScheme,
          ),
        );
      },
    );
  }
}

class _FluidWaveformPainter extends CustomPainter {
  _FluidWaveformPainter({
    required this.phase,
    required this.soundLevel,
    required this.isRecording,
    required this.colorScheme,
  });

  final double phase;
  final double soundLevel;
  final bool isRecording;
  final WaveformColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final double midY = size.height / 2;
    final double baseAmp = isRecording
        ? (12.0 + soundLevel * (size.height * 0.42))
        : 8.0;

    // Draw 3 layers of harmonic waves with phase shifts & variable opacity
    _drawWave(
      canvas: canvas,
      size: size,
      midY: midY,
      amplitude: baseAmp * 1.0,
      frequency: 2.2,
      phaseOffset: phase,
      strokeWidth: 3.2,
      opacity: isRecording ? 0.90 : 0.45,
      layerIndex: 0,
    );

    _drawWave(
      canvas: canvas,
      size: size,
      midY: midY,
      amplitude: baseAmp * 0.72,
      frequency: 3.1,
      phaseOffset: phase * 1.35 + 1.2,
      strokeWidth: 2.2,
      opacity: isRecording ? 0.65 : 0.30,
      layerIndex: 1,
    );

    _drawWave(
      canvas: canvas,
      size: size,
      midY: midY,
      amplitude: baseAmp * 0.45,
      frequency: 1.6,
      phaseOffset: phase * 0.75 + 2.5,
      strokeWidth: 1.6,
      opacity: isRecording ? 0.45 : 0.20,
      layerIndex: 2,
    );
  }

  void _drawWave({
    required Canvas canvas,
    required Size size,
    required double midY,
    required double amplitude,
    required double frequency,
    required double phaseOffset,
    required double strokeWidth,
    required double opacity,
    required int layerIndex,
  }) {
    final Path path = Path();
    final double step = 4.0;
    bool isFirst = true;

    for (double x = 0; x <= size.width; x += step) {
      // Gaussian bell envelope to taper the wave towards the left and right edges
      final double normX = (x / size.width) * 2.0 - 1.0; // -1.0 to 1.0
      final double envelope = math.exp(-3.5 * normX * normX);

      final double y =
          midY +
          math.sin((x / size.width) * frequency * 2 * math.pi + phaseOffset) *
              amplitude *
              envelope;

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }

    final Color primaryColor = colorScheme == WaveformColorScheme.gold
        ? AppColors.gold
        : (isRecording ? AppColors.emerald : AppColors.darkGreen);
    final Color secondaryColor = isRecording
        ? AppColors.gold
        : AppColors.emerald;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: <Color>[
          primaryColor.withValues(alpha: opacity * 0.2),
          secondaryColor.withValues(alpha: opacity),
          primaryColor.withValues(alpha: opacity),
          secondaryColor.withValues(alpha: opacity * 0.2),
        ],
        stops: const <double>[0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FluidWaveformPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.soundLevel != soundLevel ||
        oldDelegate.isRecording != isRecording;
  }
}
