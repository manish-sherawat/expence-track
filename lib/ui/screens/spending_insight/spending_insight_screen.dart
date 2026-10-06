import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/seed/mockup_seed_data.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../domain/models/budget.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/financial_summary.dart';
import '../../../domain/models/transaction.dart';
import '../../../providers/finance_providers.dart';
import 'widgets/budget_edit_bottom_sheet.dart';
import 'widgets/budget_vs_actual_card.dart';
import 'widgets/spending_header.dart';
import 'widgets/spending_trend_card.dart';
import 'widgets/stat_cards_grid.dart';

/// Screen 3: Spending Insight Screen.
///
/// Features:
/// - Screen header with month/year dropdown pill ("April 2026")
/// - Segmented Control (Week / Month / Year)
/// - 2x2 Stat Cards (Total Spent, Daily Average, Biggest Category, AI Saving Found)
/// - Spending Trend Card with smooth orange AreaLineChart, X/Y axes, scrub tooltip
/// - Budget vs Actual Card (Food Over, Transport Under, Shopping Over, animated progress bars)
/// - Budget edit bottom sheet
/// - 100% custom, zero Material/Cupertino
class SpendingInsightScreen extends ConsumerStatefulWidget {
  const SpendingInsightScreen({super.key});

  @override
  ConsumerState<SpendingInsightScreen> createState() => _SpendingInsightScreenState();
}

class _SpendingInsightScreenState extends ConsumerState<SpendingInsightScreen> {
  SpendingTimeframe _timeframe = SpendingTimeframe.month;
  TrendMetricType _metricType = TrendMetricType.expenses;

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(financialSummaryFutureProvider);
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final txnsAsync = ref.watch(monthlyTransactionsStreamProvider);

    // Fallbacks from seed data matching mockup
    final FinancialSummary summary = summaryAsync.value ?? MockupSeedData.summary;
    final List<Budget> budgets = (budgetsAsync.value != null && budgetsAsync.value!.isNotEmpty)
        ? budgetsAsync.value!
        : MockupSeedData.budgets;
    final List<Category> categories = (categoriesAsync.value != null && categoriesAsync.value!.isNotEmpty)
        ? categoriesAsync.value!
        : MockupSeedData.categories;
    final List<Transaction> transactions = (txnsAsync.value != null && txnsAsync.value!.isNotEmpty)
        ? txnsAsync.value!
        : MockupSeedData.transactions;

    // Build budget vs actual items
    final budgetItems = _buildBudgetItems(budgets, categories, transactions);

    // Build trend chart data points
    final chartData = _buildChartData(
      summary: summary,
      metric: _metricType,
      transactions: transactions,
      timeframe: _timeframe,
      selectedMonth: selectedMonth,
    );

    return AppScaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            bottom: 120, // Clear floating FrostedNavBar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header (Title, Month Dropdown Pill, Segmented Control)
              SpendingHeader(
                selectedMonth: selectedMonth,
                onMonthChanged: (newMonth) {
                  ref.read(selectedMonthProvider.notifier).state = newMonth;
                },
                selectedTimeframe: _timeframe,
                onTimeframeChanged: (newTf) {
                  setState(() => _timeframe = newTf);
                },
              ),

              const SizedBox(height: AppSpacing.s20),

              // 2. 2x2 Stat Cards Grid
              StatCardsGrid(summary: summary),

              const SizedBox(height: AppSpacing.s20),

              // 3. Spending Trend Card with AreaLineChart
              SpendingTrendCard(
                dataPoints: chartData,
                selectedMetric: _metricType,
                onMetricChanged: (newMetric) {
                  setState(() => _metricType = newMetric);
                },
              ),

              const SizedBox(height: AppSpacing.s20),

              // 4. Budget vs Actual Card
              BudgetVsActualCard(
                items: budgetItems,
                onEdit: () {
                  BudgetEditBottomSheet.show(
                    context,
                    budgets: budgets,
                    onSave: (updatedBudgets) async {
                      final repo = ref.read(financeRepositoryProvider);
                      for (final b in updatedBudgets) {
                        await repo.updateBudget(b);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BudgetVsActualItem> _buildBudgetItems(
    List<Budget> budgets,
    List<Category> categories,
    List<Transaction> transactions,
  ) {
    if (budgets.isEmpty) return const [];

    final categoryMap = {for (final c in categories) c.id: c};
    final categorySpent = <String, int>{};

    for (final t in transactions) {
      if (t.type == TransactionType.expense || t.amount.cents < 0) {
        categorySpent[t.categoryId] = (categorySpent[t.categoryId] ?? 0) + t.amount.cents.abs();
      }
    }

    final items = <BudgetVsActualItem>[];
    for (final b in budgets) {
      final cat = categoryMap[b.categoryId];
      final name = cat?.name ?? _fallbackCategoryName(b.categoryId);
      final icon = cat != null ? _categoryIcon(cat.iconKey) : _fallbackCategoryIcon(b.categoryId);
      final spent = transactions.isNotEmpty ? (categorySpent[b.categoryId] ?? b.spentAmount.cents) : b.spentAmount.cents;
      final limit = b.limitAmount.cents;

      items.add(
        BudgetVsActualItem(
          categoryName: name,
          icon: icon,
          spentCents: spent,
          limitCents: limit,
          isOver: spent > limit,
        ),
      );
    }

    return items;
  }

  String _fallbackCategoryName(String id) {
    switch (id) {
      case MockupSeedData.catFood:
        return 'Food';
      case MockupSeedData.catTransport:
        return 'Transport';
      case MockupSeedData.catShopping:
        return 'Shopping';
      case MockupSeedData.catRent:
        return 'Rent';
      default:
        return 'General';
    }
  }

  AppIconType _fallbackCategoryIcon(String id) {
    switch (id) {
      case MockupSeedData.catFood:
        return AppIconType.food;
      case MockupSeedData.catTransport:
        return AppIconType.transport;
      case MockupSeedData.catShopping:
        return AppIconType.shopping;
      case MockupSeedData.catRent:
        return AppIconType.rent;
      default:
        return AppIconType.receipt;
    }
  }

  AppIconType _categoryIcon(String key) {
    switch (key) {
      case 'food':
        return AppIconType.food;
      case 'rent':
        return AppIconType.rent;
      case 'transport':
        return AppIconType.transport;
      case 'shopping':
        return AppIconType.shopping;
      case 'salary':
      case 'wallet':
        return AppIconType.wallet;
      case 'savings':
      case 'chart':
        return AppIconType.chart;
      default:
        return AppIconType.receipt;
    }
  }

  List<ChartDataPoint> _buildChartData({
    required FinancialSummary summary,
    required TrendMetricType metric,
    required List<Transaction> transactions,
    required SpendingTimeframe timeframe,
    required DateTime selectedMonth,
  }) {
    final dateFormat = DateFormat('MMM d');
    final isIncome = metric == TrendMetricType.income;

    // Filter relevant transactions
    final relevantTxns = transactions.where((t) {
      if (isIncome) {
        return t.type == TransactionType.income && t.amount.cents > 0;
      } else {
        return t.type == TransactionType.expense || t.amount.cents < 0;
      }
    }).toList();

    relevantTxns.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (relevantTxns.isEmpty) {
      final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
      return [
        ChartDataPoint(
          label: dateFormat.format(DateTime(selectedMonth.year, selectedMonth.month, 1)),
          valueCents: 0,
          date: DateTime(selectedMonth.year, selectedMonth.month, 1),
        ),
        ChartDataPoint(
          label: dateFormat.format(DateTime(selectedMonth.year, selectedMonth.month, daysInMonth)),
          valueCents: 0,
          date: DateTime(selectedMonth.year, selectedMonth.month, daysInMonth),
        ),
      ];
    }

    int cumulativeCents = 0;
    final points = <ChartDataPoint>[];

    // Starting baseline point
    final firstTxn = relevantTxns.first;
    points.add(
      ChartDataPoint(
        label: dateFormat.format(DateTime(firstTxn.timestamp.year, firstTxn.timestamp.month, 1)),
        valueCents: 0,
        date: DateTime(firstTxn.timestamp.year, firstTxn.timestamp.month, 1),
      ),
    );

    for (final t in relevantTxns) {
      cumulativeCents += t.amount.cents.abs();
      points.add(
        ChartDataPoint(
          label: dateFormat.format(t.timestamp),
          valueCents: cumulativeCents,
          date: t.timestamp,
        ),
      );
    }

    // Deduplicate same-day points if too dense, keeping the latest cumulative point
    final Map<String, ChartDataPoint> uniqueByDay = {};
    for (final p in points) {
      uniqueByDay[p.label] = p;
    }

    final result = uniqueByDay.values.toList();
    result.sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));

    // AreaLineChart requires at least 2 points
    if (result.length < 2) {
      final lastDate = result.first.date ?? DateTime.now();
      result.add(
        ChartDataPoint(
          label: dateFormat.format(lastDate.add(const Duration(days: 1))),
          valueCents: result.first.valueCents,
          date: lastDate.add(const Duration(days: 1)),
        ),
      );
    }

    return result;
  }
}
