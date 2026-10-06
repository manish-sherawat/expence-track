import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/seed/mockup_seed_data.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../domain/models/budget.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/money.dart';
import '../../../providers/finance_providers.dart';

/// Full-screen list of all budget categories with progress bars, limits, and percentages.
///
/// Strictly ZERO Material / ZERO Cupertino.
class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? MockupSeedData.categories;

    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final budgets = budgetsAsync.value ?? MockupSeedData.budgets;

    final totalExpensesAsync = ref.watch(financialSummaryStreamProvider);
    final totalSpentMinor = totalExpensesAsync.value?.totalExpenses.cents ?? 321800;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleIconButton(
                          icon: AppIconType.arrowLeft,
                          semanticLabel: 'Back',
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Categories',
                                style: text.title2.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'April 2026 Budget Breakdown',
                                style: text.caption.copyWith(
                                  color: colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: AppRadii.fullPill,
                    ),
                    child: Text(
                      '${categories.length} Total',
                      style: text.caption.copyWith(
                        color: colors.primaryInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Summary glass card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: GlassSurface(
                padding: const EdgeInsets.all(AppSpacing.s16),
                borderRadius: AppRadii.card,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL MONTHLY EXPENSES',
                            style: text.overline.copyWith(
                              color: colors.textSecondary,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: AmountText(
                              amountMinor: totalSpentMinor,
                              size: AmountTextSize.title,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Pressable(
                      onTap: () => context.push('/insight'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.primaryInk,
                          borderRadius: AppRadii.fullPill,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Insights',
                              style: text.caption.copyWith(
                                color: colors.surface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AppIcon(AppIconType.chevronRight, size: 12, color: colors.surface),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            // Categories list
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.s8,
                ),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s10),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final budget = _findBudget(budgets, cat.id);
                  return _buildCategoryCard(cat, budget, colors, text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    Category cat,
    Budget? budget,
    AppColors colors,
    AppTypography text,
  ) {
    final limit = budget?.limitAmount ?? cat.budgetMonthly ?? const Money(50000);
    final spent = budget?.spentAmount ?? const Money(15000);
    final ratio = limit.cents > 0 ? (spent.cents / limit.cents).clamp(0.0, 1.5) : 0.0;
    final isOver = ratio > 1.0;
    final percent = (ratio * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: colors.borderSubtle, width: 0.5),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: AppIcon(
                        _categoryIcon(cat.iconKey),
                        size: 18,
                        color: colors.primaryInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: text.subheadline.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Limit: ${limit.format()}',
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    spent.format(),
                    style: text.subheadline.copyWith(
                      color: isOver ? colors.accent : colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  StatusPill(
                    label: isOver ? 'Over' : '$percent%',
                    isPositive: !isOver,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          ProgressBar(
            progress: ratio.clamp(0.0, 1.0),
            color: isOver ? colors.accent : colors.positive,
          ),
        ],
      ),
    );
  }

  Budget? _findBudget(List<Budget> budgets, String categoryId) {
    for (final b in budgets) {
      if (b.categoryId == categoryId) return b;
    }
    return null;
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
}
