import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';

/// Custom animated 6pt progress bar with rounded ends and spring animation.
class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final bool animate;

  const ProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 6.0,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final clampedProgress = progress.clamp(0.0, 1.0);

    final trackColor = backgroundColor ?? colors.surfaceVariant;
    final fillColor = color ?? colors.primaryInk;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: AppRadii.fullPill,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final targetWidth = constraints.maxWidth * clampedProgress;

          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: animate ? AppMotion.durationNormal : Duration.zero,
              curve: AppMotion.springGentle,
              width: targetWidth,
              height: height,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: AppRadii.fullPill,
              ),
            ),
          );
        },
      ),
    );
  }
}
