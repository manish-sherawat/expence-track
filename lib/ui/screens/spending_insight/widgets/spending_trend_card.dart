import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

enum TrendMetricType {
  expenses,
  income,
}

/// Spending Trend Card featuring custom monotone Bézier AreaLineChart and scrub interaction.
class SpendingTrendCard extends StatefulWidget {
  final List<ChartDataPoint> dataPoints;
  final TrendMetricType selectedMetric;
  final ValueChanged<TrendMetricType> onMetricChanged;

  const SpendingTrendCard({
    super.key,
    required this.dataPoints,
    required this.selectedMetric,
    required this.onMetricChanged,
  });

  @override
  State<SpendingTrendCard> createState() => _SpendingTrendCardState();
}

class _SpendingTrendCardState extends State<SpendingTrendCard> {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;
    final colors = theme.colors;

    const dropdownItems = [
      DropdownItem<TrendMetricType>(
        value: TrendMetricType.expenses,
        label: 'Expenses',
        icon: AppIconType.wallet,
      ),
      DropdownItem<TrendMetricType>(
        value: TrendMetricType.income,
        label: 'Income',
        icon: AppIconType.chart,
      ),
    ];

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
            // Header Row: "Spending Trend" + Dropdown Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending Trend',
                        style: text.title3.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'April 1 - April 30, 2026',
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                DropdownPill<TrendMetricType>(
                  selectedValue: widget.selectedMetric,
                  items: dropdownItems,
                  onSelected: widget.onMetricChanged,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s20),

            // Monotone Cubic Bézier Area Line Chart
            AreaLineChart(
              data: widget.dataPoints,
              height: 200,
              lineColor: colors.accent,
              fillColor: colors.accent.withValues(alpha: 0.25),
              showGrid: true,
              interactive: true,
            ),
          ],
        ),
      ),
    );
  }
}
