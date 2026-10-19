import 'package:flutter/material.dart';
import '../core/haptics.dart';
import '../theme/app_theme.dart';
import 'brand.dart';
import 'fluid_waveform.dart';
import 'spring_tap.dart';

/// Floating Voice Island widget inspired by Google Gemini Live and Dynamic Island.
///
/// Docks persistently above the screen content, morphing dynamically between:
/// - [VoiceIslandState.idle]: Compact pill inviting voice interaction.
/// - [VoiceIslandState.listening]: Expands into real-time fluid waveform with live decibel response.
/// - [VoiceIslandState.processing]: Sleek loader with orbiting AI reasoning dots.
/// - [VoiceIslandState.speaking]: Audio playback controller for reading legal advice aloud.
enum VoiceIslandState { idle, listening, processing, speaking }

class AliveVoiceIsland extends StatelessWidget {
  const AliveVoiceIsland({
    super.key,
    required this.state,
    required this.onMicTap,
    this.soundLevel = 0.15,
    this.isTtsSpeaking = false,
    this.onTtsToggle,
    this.statusText,
  });

  final VoiceIslandState state;
  final VoidCallback onMicTap;
  final double soundLevel;
  final bool isTtsSpeaking;
  final VoidCallback? onTtsToggle;
  final String? statusText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        // The island is a compact control, so keep its labels legible without
        // letting accessibility scaling turn the fixed-height pill into a
        // multi-line block. Its height grows to fit the clamped content.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            constraints: BoxConstraints(
              minHeight: state == VoiceIslandState.listening ? 84 : 64,
            ),
            decoration: BoxDecoration(
              color: state == VoiceIslandState.listening
                  ? AppColors.darkGreen
                  : AppColors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: state == VoiceIslandState.listening
                    ? AppColors.emerald.withValues(alpha: 0.6)
                    : AppColors.darkGreen.withValues(alpha: 0.12),
                width: 1.5,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color:
                      (state == VoiceIslandState.listening
                              ? AppColors.emerald
                              : AppColors.darkGreen)
                          .withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: _buildIslandContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIslandContent(BuildContext context) {
    switch (state) {
      case VoiceIslandState.listening:
        return _buildListeningContent();
      case VoiceIslandState.processing:
        return _buildProcessingContent();
      case VoiceIslandState.speaking:
        return _buildSpeakingContent();
      case VoiceIslandState.idle:
        return _buildIdleContent();
    }
  }

  Widget _buildIdleContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: <Widget>[
          SpringTap(
            onTap: () {
              AppHaptics.micActivated();
              onMicTap();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: AppColors.gradientEmeraldToDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: AppColors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  statusText ?? 'Tap to speak your legal query',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const UrduText(
                  'بول کر قانونی سوال پوچھیں',
                  size: 12,
                  height: 1.4,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.auto_awesome, size: 14, color: AppColors.emerald),
                SizedBox(width: 4),
                Text(
                  'Urdu/Eng',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emeraldDeep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Listening...',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const UrduText(
                      'سن رہا ہے...',
                      size: 11,
                      color: AppColors.gold,
                      height: 1.2,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 38,
                  child: FluidWaveform(
                    isRecording: true,
                    soundLevel: soundLevel,
                    height: 38,
                    colorScheme: WaveformColorScheme.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SpringTap(
            onTap: () {
              AppHaptics.buttonTap();
              onMicTap();
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stop_rounded,
                color: AppColors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingContent() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
            ),
          ),
          SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Analyzing legal precedent & PPC...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              UrduText(
                'قانونی تجزیہ جاری ہے...',
                size: 11,
                color: AppColors.goldText,
                height: 1.3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakingContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: <Widget>[
          SpringTap(
            onTap: () {
              AppHaptics.buttonTap();
              onTtsToggle?.call();
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.gradientGold,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTtsSpeaking ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Reading answer aloud (Urdu/English)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                UrduText(
                  'آواز میں سنیں',
                  size: 11,
                  color: AppColors.emeraldDeep,
                  height: 1.2,
                ),
              ],
            ),
          ),
          SpringTap(
            onTap: () {
              AppHaptics.micActivated();
              onMicTap();
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: AppColors.darkGreen,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
