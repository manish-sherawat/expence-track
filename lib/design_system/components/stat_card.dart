import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'amount_text.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Trend pill showing percentage and direction (up/down arrow).
class TrendBadge extends StatelessWidget {
  final double percentage;
  final bool isPositiveGood;

  const TrendBadge({
    super.key,
    required this.percentage,
    this.isPositiveGood = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final isUp = percentage >= 0;
    // For income/savings, up is good (green). For expenses, up is bad (red).
    final isGood = isPositiveGood ? isUp : !isUp;

    final bgColor = isGood ? colors.positiveTint : colors.accentTint;
    final fgColor = isGood ? colors.positive : colors.accent;
    final iconType = isUp ? AppIconType.arrowUp : AppIconType.arrowDown;
    final formatted = '${isUp ? '+' : ''}${percentage.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.fullPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(iconType, size: 11, color: fgColor),
          const SizedBox(width: 3),
          Text(
            formatted,
            style: text.caption.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 2x2 grid metric card with title, amount, trend badge, and optional icon.
class StatCard extends StatelessWidget {
  final String title;
  final int amountCents;
  final AppIconType? icon;
  final double? trendPercentage;
  final String? trendContext;
  final bool isPositiveGood;
  final AmountSignStyle? signStyle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.amountCents,
    this.icon,
    this.trendPercentage,
    this.trendContext,
    this.isPositiveGood = true,
    this.signStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final cardContent = Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: colors.borderSubtle, width: 0.5),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Icon + Title
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      icon!,
                      size: 16,
                      color: colors.primaryInk,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),

          // Display Amount
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AmountText(
              amountMinor: amountCents,
              size: AmountTextSize.stat,
              signStyle: signStyle,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),

          // Trend & Context footer
          if (trendPercentage != null || trendContext != null)
            Row(
              children: [
                if (trendPercentage != null) ...[
                  Flexible(
                    flex: trendContext != null ? 0 : 1,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: TrendBadge(
                        percentage: trendPercentage!,
                        isPositiveGood: isPositiveGood,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s6),
                ],
                if (trendContext != null)
                  Expanded(
                    child: Text(
                      trendContext!,
                      style: text.caption.copyWith(
                        color: colors.textTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );

    if (onTap != null) {
      return Pressable(onTap: onTap, child: cardContent);
    }
    return cardContent;
  }
}
