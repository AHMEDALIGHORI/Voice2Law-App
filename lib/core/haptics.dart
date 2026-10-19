import 'package:flutter/services.dart';

/// A haptic feedback vocabulary service for the app.
class AppHaptics {
  /// Private constructor to prevent instantiation.
  AppHaptics._();

  /// Haptic feedback for a standard button tap.
  static Future<void> buttonTap() async {
    await HapticFeedback.lightImpact();
  }

  /// Haptic feedback for when the microphone is activated.
  static Future<void> micActivated() async {
    await HapticFeedback.heavyImpact();
  }

  /// Haptic feedback for when speech is detected.
  static Future<void> speechDetected() async {
    await HapticFeedback.selectionClick();
  }

  /// Haptic feedback for when an answer is received.
  static Future<void> answerReceived() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Haptic feedback for the panic exit action.
  static Future<void> panicExit() async {
    await HapticFeedback.vibrate();
  }

  /// Haptic feedback for switching tabs.
  static Future<void> tabSwitch() async {
    await HapticFeedback.selectionClick();
  }

  /// Haptic feedback for applying a filter.
  static Future<void> filterApplied() async {
    await HapticFeedback.lightImpact();
  }

  /// Haptic feedback for a successful action.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }
}
