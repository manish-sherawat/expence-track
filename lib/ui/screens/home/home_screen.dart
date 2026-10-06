import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../data/seed/mockup_seed_data.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/transaction.dart';
import '../../../features/onboarding/providers/onboarding_provider.dart';
import '../../../providers/finance_providers.dart';
import 'widgets/category_spending_carousel.dart';
import 'widgets/day1_welcome_banner.dart';
import 'widgets/greeting_header.dart';
import 'widgets/recent_transactions_section.dart';
import 'widgets/total_balance_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stream & Future values from Riverpod
    final balanceAsync = ref.watch(totalBalanceStreamProvider);
    final summaryAsync = ref.watch(financialSummaryFutureProvider);
    final insightsAsync = ref.watch(insightsStreamProvider);
    final recentTxnsAsync = ref.watch(recentTransactionsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final userName = ref.watch(userNameProvider).value ?? 'Jacob Simmons';

    // Default fallback values matching mockup
    final totalBalance = balanceAsync.value ?? MockupSeedData.totalBalance;
    final income = summaryAsync.value?.totalIncome ?? MockupSeedData.summary.totalIncome;
    final expenses = summaryAsync.value?.totalExpenses ?? MockupSeedData.summary.totalExpenses;
    final saved = summaryAsync.value?.totalSaved ?? MockupSeedData.summary.totalSaved;

    // Insights
    final activeInsight = (insightsAsync.value != null && insightsAsync.value!.isNotEmpty)
        ? insightsAsync.value!.first
        : MockupSeedData.insights.first;

    // Recent Transactions
    final transactions = (recentTxnsAsync.value != null && recentTxnsAsync.value!.isNotEmpty)
        ? recentTxnsAsync.value!
        : MockupSeedData.transactions;

    // Categories with live spending amounts & percentages
    final categories = (categoriesAsync.value != null && categoriesAsync.value!.isNotEmpty)
        ? categoriesAsync.value!
        : MockupSeedData.categories;
    final categoryItems = _buildCategorySpendingItems(
      categories: categories,
      totalExpensesCents: expenses.cents,
      transactions: transactions,
    );

    return AppScaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          top: AppSpacing.s8,
          bottom: 110, // Generous clearance for floating FrostedNavBar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Greeting Header
            GreetingHeader(
              userName: userName,
              greeting: 'Welcome Back,',
              onSearchTap: () => context.push('/search'),
              onNotificationsTap: () => context.push('/notifications'),
              hasUnreadNotifications: true,
            ),

            // Optional Day-1 Contextual Welcome Guide
            if (!(ref.watch(day1BannerDismissedStateProvider) ||
                (ref.watch(day1BannerDismissedProvider).value ?? false)))
              Day1WelcomeBanner(
                onDismiss: () async {
                  ref.read(day1BannerDismissedStateProvider.notifier).state = true;
                  final repo = ref.read(financeRepositoryProvider);
                  await repo.setAppSetting('day1_banner_dismissed', 'true');
                },
              ),

            const SizedBox(height: AppSpacing.s8),

            // 2. Total Balance Card
            TotalBalanceCard(
              totalBalance: totalBalance,
              income: income,
              expenses: expenses,
              saved: saved,
              onTap: () => context.push('/insight'),
            ),

            const SizedBox(height: AppSpacing.s16),

            // 3. AI Insight Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: InsightBanner(
                headline: activeInsight.description,
                subheadline: 'Based on current velocity • ${activeInsight.actionLabel}',
                onTap: () => context.push(activeInsight.routePath),
              ),
            ),

            const SizedBox(height: AppSpacing.s24),

            // 4. Spending by Category Carousel
            CategorySpendingCarousel(
              items: categoryItems,
              onSeeAllTap: () => context.push('/categories'),
              onCategoryTap: (cat) => context.push('/insight'),
            ),

            const SizedBox(height: AppSpacing.s24),

            // 5. Recent Transactions
            RecentTransactionsSection(
              transactions: transactions,
              onSeeAllTap: () => context.push('/transactions'),
              onTransactionTap: (txn) => context.push('/transaction/${txn.id}'),
            ),
          ],
        ),
      ),
    );
  }

  List<CategorySpendingItem> _buildCategorySpendingItems({
    required List<Category> categories,
    required int totalExpensesCents,
    required List<Transaction> transactions,
  }) {
    if (categories.isEmpty) return const [];

    final categoryTotals = <String, int>{};
    for (final t in transactions) {
      if (t.type == TransactionType.expense || t.amount.cents < 0) {
        categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + t.amount.cents.abs();
      }
    }

    final items = <CategorySpendingItem>[];
    for (final cat in categories) {
      final spent = categoryTotals[cat.id] ?? 0;
      final pct = totalExpensesCents > 0
          ? (spent / totalExpensesCents)
          : (spent > 0 ? 1.0 : 0.0);
      items.add(
        CategorySpendingItem(
          category: cat,
          amountCents: spent,
          percentage: double.parse(pct.toStringAsFixed(2)),
          icon: _categoryIcon(cat.iconKey),
        ),
      );
    }

    // Sort descending by amount spent
    items.sort((a, b) => b.amountCents.compareTo(a.amountCents));
    return items;
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
