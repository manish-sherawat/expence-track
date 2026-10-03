import 'package:flutter/widgets.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Custom theme data containing color and typography tokens.
/// Does NOT rely on Material ThemeData or CupertinoThemeData.
class AppThemeData {
  const AppThemeData({
    required this.colors,
    required this.typography,
    this.reduceTransparency = false,
    this.reduceMotion = false,
  });

  final AppColors colors;
  final AppTypography typography;
  final bool reduceTransparency;
  final bool reduceMotion;

  factory AppThemeData.light({
    bool reduceTransparency = false,
    bool reduceMotion = false,
  }) {
    const colors = AppColors.light;
    return AppThemeData(
      colors: colors,
      typography: AppTypography.fromColors(colors),
      reduceTransparency: reduceTransparency,
      reduceMotion: reduceMotion,
    );
  }

  factory AppThemeData.dark({
    bool reduceTransparency = false,
    bool reduceMotion = false,
  }) {
    const colors = AppColors.dark;
    return AppThemeData(
      colors: colors,
      typography: AppTypography.fromColors(colors),
      reduceTransparency: reduceTransparency,
      reduceMotion: reduceMotion,
    );
  }

  AppThemeData copyWith({
    AppColors? colors,
    AppTypography? typography,
    bool? reduceTransparency,
    bool? reduceMotion,
  }) {
    return AppThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeData &&
          runtimeType == other.runtimeType &&
          colors == other.colors &&
          reduceTransparency == other.reduceTransparency &&
          reduceMotion == other.reduceMotion;

  @override
  int get hashCode => Object.hash(colors, reduceTransparency, reduceMotion);
}

/// InheritedWidget providing custom AppTheme data down the widget tree.
class AppTheme extends InheritedWidget {
  const AppTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final AppThemeData data;

  static AppThemeData of(BuildContext context) {
    final AppTheme? theme =
        context.dependOnInheritedWidgetOfExactType<AppTheme>();
    return theme?.data ?? AppThemeData.light();
  }

  static AppThemeData? maybeOf(BuildContext context) {
    final AppTheme? theme =
        context.dependOnInheritedWidgetOfExactType<AppTheme>();
    return theme?.data;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) {
    return data != oldWidget.data;
  }
}

/// Convenience extensions on BuildContext.
extension AppThemeContext on BuildContext {
  AppThemeData get theme => AppTheme.of(this);
  AppColors get colors => theme.colors;
  AppTypography get text => theme.typography;
  bool get isDark => theme.colors.isDark;
}
