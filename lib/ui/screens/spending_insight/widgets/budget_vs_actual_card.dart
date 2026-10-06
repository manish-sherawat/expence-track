import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

/// Item data model for budget vs actual comparison row.
class BudgetVsActualItem {
  final String categoryName;
  final AppIconType icon;
  final int spentCents;
  final int limitCents;
  final bool isOver;

  const BudgetVsActualItem({
    required this.categoryName,
    required this.icon,
    required this.spentCents,
    required this.limitCents,
    required this.isOver,
  });

  double get ratio => limitCents > 0 ? (spentCents / limitCents) : 0.0;
}

/// Budget vs Actual breakdown card with animated progress bars and status pills.
class BudgetVsActualCard extends StatelessWidget {
  final List<BudgetVsActualItem> items;
  final VoidCallback onEdit;

  const BudgetVsActualCard({
    super.key,
    required this.items,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;
    final colors = theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadii.card,
          border: Border.all(color: colors.borderSubtle, width: 0.5),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: "Budget vs Actual" + Edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Budget vs Actual',
                    style: text.title3.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Pressable(
                  onTap: onEdit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Edit Budgets',
                      style: text.subheadline.copyWith(
                        color: colors.primaryInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s16),

            // Category rows
            for (int i = 0; i < items.length; i++) ...[
              _buildCategoryRow(context, items[i]),
              if (i < items.length - 1)
                const SizedBox(height: AppSpacing.s16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, BudgetVsActualItem item) {
    final theme = AppTheme.of(context);
    final text = theme.text;
    final colors = theme.colors;

    final spentFormatted = _formatCurrency(item.spentCents);
    final limitFormatted = _formatCurrency(item.limitCents);
    final progressColor = item.isOver ? colors.accent : colors.positive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Icon + Name + Status Pill
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppIcon(
                        item.icon,
                        size: 14,
                        color: colors.primaryInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Flexible(
                    child: Text(
                      item.categoryName,
                      style: text.subheadline.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  item.isOver
                      ? StatusPill.over()
                      : StatusPill.under(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),

            // Right: "$850 / $700"
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: RichText(
                text: TextSpan(
                  style: text.caption.copyWith(
                    fontFamily: 'Inter',
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  children: [
                    TextSpan(
                      text: spentFormatted,
                      style: TextStyle(
                        color: item.isOver ? colors.accent : colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' / $limitFormatted',
                      style: TextStyle(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.s8),

        // Animated Progress Bar
        ProgressBar(
          progress: item.ratio,
          color: progressColor,
          backgroundColor: colors.surfaceVariant,
          height: 6,
        ),
      ],
    );
  }

  String _formatCurrency(int cents) {
    final whole = (cents.abs() ~/ 100).toString();
    final sign = cents < 0 ? '-' : '';
    return '$sign\$$whole';
  }
}
