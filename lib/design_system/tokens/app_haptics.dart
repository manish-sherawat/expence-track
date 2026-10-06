import 'package:flutter/services.dart';

enum AppHapticType {
  light,
  medium,
  heavy,
  selection,
}

/// Cross-platform haptic feedback helper using services.dart.
/// Safely degrades on unsupported platforms.
class AppHaptics {
  const AppHaptics._();

  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static Future<void> perform(AppHapticType type) async {
    switch (type) {
      case AppHapticType.light:
        return lightImpact();
      case AppHapticType.medium:
        return mediumImpact();
      case AppHapticType.heavy:
        return heavyImpact();
      case AppHapticType.selection:
        return selectionClick();
    }
  }
}
