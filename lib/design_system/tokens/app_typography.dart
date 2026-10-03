import 'package:flutter/widgets.dart';
import 'app_colors.dart';

/// Typography tokens based on Inter geometric grotesque styling.
class AppTypography {
  const AppTypography({
    required this.displayAmount,
    required this.titleAmount,
    required this.statAmount,
    required this.screenTitle,
    required this.sectionTitle,
    required this.greetingName,
    required this.body,
    required this.rowTitle,
    required this.label,
    required this.caption,
    required this.overline,
  });

  static const String fontFamily = 'Inter';

  final TextStyle displayAmount;
  final TextStyle titleAmount;
  final TextStyle statAmount;
  final TextStyle screenTitle;
  final TextStyle sectionTitle;
  final TextStyle greetingName;
  final TextStyle body;
  final TextStyle rowTitle;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle overline;

  factory AppTypography.fromColors(AppColors colors) {
    return AppTypography(
      displayAmount: TextStyle(
        fontFamily: fontFamily,
        fontSize: 44,
        fontWeight: FontWeight.w500,
        height: 1.1,
        letterSpacing: -1.0,
        color: colors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleAmount: TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: FontWeight.w500,
        height: 1.15,
        color: colors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      statAmount: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: colors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      screenTitle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: colors.textPrimary,
      ),
      sectionTitle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: colors.textPrimary,
      ),
      greetingName: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: colors.textPrimary,
      ),
      body: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: colors.textPrimary,
      ),
      rowTitle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: colors.textPrimary,
      ),
      label: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: colors.textSecondary,
      ),
      caption: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: colors.textSecondary,
      ),
      overline: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: 0.4,
        color: colors.textSecondary,
      ),
    );
  }
}
