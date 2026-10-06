import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'amount_text.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Compact vertical card representing a spending category for horizontal carousels.
///
/// Displays:
/// - Category icon inside circular plate
/// - Category name
/// - Total spent in tabular figures
/// - Relative percentage of total budget
class CategoryCard extends StatelessWidget {
  final String title;
  final int amountCents;
  final double percentage; // e.g. 37.0 for 37%
  final AppIconType icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.amountCents,
    required this.percentage,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    final circleBg = iconBackgroundColor ?? colors.surfaceVariant;
    final circleFg = iconColor ?? colors.primaryInk;

    final textScaler = MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;
    final cardWidth = (104.0 * textScaler.scale(1.0)).clamp(104.0, 140.0);

    final content = Container(
      width: cardWidth,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: colors.borderSubtle,
          width: 0.5,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular icon plate
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                icon,
                size: 18,
                color: circleFg,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),

          // Title
          Text(
            title,
            style: text.subheadline.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.s4),

          // Amount
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AmountText(
              cents: amountCents,
              size: AmountTextSize.row,
              style: text.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              centsStyle: text.caption.copyWith(
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),

          // Percentage badge
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${percentage.toStringAsFixed(0)}% of total',
              style: text.caption.copyWith(
                color: colors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Pressable(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
