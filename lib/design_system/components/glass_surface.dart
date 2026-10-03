import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../tokens/tokens.dart';

/// Frosted glass container built on BackdropFilter + ClipRRect + hairline border.
/// Features an automatic solid fallback when reduceTransparency is enabled,
/// and is isolated with RepaintBoundary for optimal rendering performance.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = AppRadii.border20,
    this.blurSigma = 20.0,
    this.tintColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.boxShadow = const [],
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow> boxShadow;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final reduceTransparency = theme.reduceTransparency;

    final resolvedTint = tintColor ?? colors.glassBg;
    final resolvedBorder = borderColor ?? colors.glassBorder;

    if (reduceTransparency) {
      // Solid surface fallback for reduced transparency or lower-end devices
      return RepaintBoundary(
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: borderRadius,
            border: Border.all(color: colors.border, width: borderWidth),
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      );
    }

    return RepaintBoundary(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: boxShadow,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: clipBehavior,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: resolvedTint,
                borderRadius: borderRadius,
                border: Border.all(
                  color: resolvedBorder,
                  width: borderWidth,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
