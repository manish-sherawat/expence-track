import 'dart:ui';

/// Design tokens for colors based on the Salary Tracker UI specification.
class AppColors {
  const AppColors({
    required this.bg,
    required this.screenBase,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.positive,
    required this.negative,
    required this.link,
    required this.info,
    required this.infoTint,
    required this.accent,
    required this.accentTint,
    required this.positiveTint,
    required this.ink,
    required this.glassBg,
    required this.glassBorder,
    required this.isDark,
  });

  final Color bg;
  final Color screenBase;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color positive;
  final Color negative;
  final Color link;
  final Color info;
  final Color infoTint;
  final Color accent;
  final Color accentTint;
  final Color positiveTint;
  final Color ink;
  final Color glassBg;
  final Color glassBorder;
  final bool isDark;

  /// Default Light Theme colors (exact values from blueprint Section 4.2).
  static const light = AppColors(
    bg: Color(0xFFFFFFFF),
    screenBase: Color(0xFFFCFCFC),
    surface: Color(0xFFF7F7F8),
    surfaceRaised: Color(0xFFFFFFFF),
    border: Color(0xFFECECEE),
    textPrimary: Color(0xFF111113),
    textSecondary: Color(0xFF8B8B90),
    textTertiary: Color(0xFFB4B4B9),
    positive: Color(0xFF12A038),
    negative: Color(0xFFE11D2A),
    link: Color(0xFF0B8FE0),
    info: Color(0xFF0B8FE0),
    infoTint: Color(0xFFE6F4FD),
    accent: Color(0xFFF26A1B),
    accentTint: Color(0xFFFFEFE6),
    positiveTint: Color(0xFFE3F6E8),
    ink: Color(0xFF1C1C1E),
    glassBg: Color(0x8CFFFFFF), // ~55% white
    glassBorder: Color(0x99FFFFFF), // ~60% white
    isDark: false,
  );

  /// Dark Theme colors (mirror tokens).
  static const dark = AppColors(
    bg: Color(0xFF0F0F11),
    screenBase: Color(0xFF09090A),
    surface: Color(0xFF1C1C1E),
    surfaceRaised: Color(0xFF28282B),
    border: Color(0xFF2E2E32),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFF9898A0),
    textTertiary: Color(0xFF636366),
    positive: Color(0xFF30D158),
    negative: Color(0xFFFF453A),
    link: Color(0xFF409CFF),
    info: Color(0xFF409CFF),
    infoTint: Color(0xFF162D4A),
    accent: Color(0xFFFF7A2F),
    accentTint: Color(0xFF381F13),
    positiveTint: Color(0xFF13381B),
    ink: Color(0xFFFFFFFF),
    glassBg: Color(0x731C1C1E),
    glassBorder: Color(0x40FFFFFF),
    isDark: true,
  );
}
