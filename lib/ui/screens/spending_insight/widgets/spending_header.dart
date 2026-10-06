import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

enum SpendingTimeframe {
  week,
  month,
  year,
}

/// Header for Spending Insight Screen (Screen 3).
///
/// Features:
/// - Screen title "Spending Insights"
/// - Month/Year Dropdown Pill ("April 2026")
/// - Segmented Control (Week / Month / Year)
class SpendingHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final SpendingTimeframe selectedTimeframe;
  final ValueChanged<SpendingTimeframe> onTimeframeChanged;

  const SpendingHeader({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.selectedTimeframe,
    required this.onTimeframeChanged,
  });

  String _formatMonthYear(DateTime dt) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${monthNames[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;
    final colors = theme.colors;

    final monthOptions = [
      DateTime(2026, 3),
      DateTime(2026, 4),
      DateTime(2026, 5),
    ];

    final dropdownItems = monthOptions.map((dt) {
      return DropdownItem<DateTime>(
        value: dt,
        label: _formatMonthYear(dt),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s12),

          // Title & Month Dropdown Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Spending Insights',
                  style: text.title1.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),

              // Dropdown Pill for Month ("April 2026")
              DropdownPill<DateTime>(
                selectedValue: selectedMonth,
                items: dropdownItems,
                onSelected: onMonthChanged,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s16),

          // Custom Segmented Control (Week / Month / Year)
          SegmentedControl<SpendingTimeframe>(
            segments: SpendingTimeframe.values,
            selectedSegment: selectedTimeframe,
            onSegmentSelected: onTimeframeChanged,
            labelBuilder: (timeframe) {
              switch (timeframe) {
                case SpendingTimeframe.week:
                  return 'Week';
                case SpendingTimeframe.month:
                  return 'Month';
                case SpendingTimeframe.year:
                  return 'Year';
              }
            },
          ),
        ],
      ),
    );
  }
}
