import 'package:flutter/widgets.dart';

/// Motion, animation curves, and spring parameters.
class AppMotion {
  const AppMotion._();

  // Durations
  static const Duration pressDuration = Duration(milliseconds: 90);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration chartDraw = Duration(milliseconds: 700);
  static const Duration countUp = Duration(milliseconds: 600);
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration durationFast = quick;
  static const Duration durationNormal = normal;

  // Press feedback
  static const double pressScale = 0.97;
  static const double pressOpacity = 0.85;

  // Curves
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve springBouncy = Curves.easeOutBack;
  static const Curve springGentle = Curves.easeOutCubic;

  // Springs (mass 1, stiffness 320, damping 28)
  static const SpringDescription spring = SpringDescription(
    mass: 1.0,
    stiffness: 320.0,
    damping: 28.0,
  );
}
