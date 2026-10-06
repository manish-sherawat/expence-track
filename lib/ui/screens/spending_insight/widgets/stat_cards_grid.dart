import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/financial_summary.dart';

/// 2x2 Grid of Key Financial Metric Cards for Screen 3.
///
/// Metrics:
/// 1. Total Spent: $3,218.00 (-4.2% MoM)
/// 2. Daily Average: $107.26 / day
/// 3. Biggest Category: Rent (37% • $1,200.00)
/// 4. AI Saving Found: +$420.00 (+12.4%)
class StatCardsGrid extends StatelessWidget {
  final FinancialSummary summary;

  const StatCardsGrid({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final biggestCatLabel =
        '${summary.topCategoryName} (${summary.topCategoryPercentage.toStringAsFixed(0)}%)';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        children: [
          // Row 1: Total Spent & Daily Average
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Spent',
                  amountCents: summary.totalExpenses.cents,
                  icon: AppIconType.wallet,
                  trendPercentage: summary.monthOverMonthExpenseChange,
                  // For expenses, a reduction (negative) is good (green badge)
                  isPositiveGood: false,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: StatCard(
                  title: 'Daily Average',
                  amountCents: summary.dailyAverageExpense.cents,
                  icon: AppIconType.chart,
                  trendContext: 'Avg / day (30d)',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s12),

          // Row 2: Biggest Category & AI Saving Found
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Biggest Category',
                  amountCents: summary.topCategorySpend.cents,
                  icon: AppIconType.rent,
                  trendContext: biggestCatLabel,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: StatCard(
                  title: 'AI Saving Found',
                  amountCents: summary.projectedSavings.cents,
                  icon: AppIconType.sparkle,
                  signStyle: AmountSignStyle.signedWithColor,
                  trendPercentage: 12.4,
                  isPositiveGood: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
