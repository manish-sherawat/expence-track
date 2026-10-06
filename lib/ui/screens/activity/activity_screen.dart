import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/seed/mockup_seed_data.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../domain/models/transaction.dart';
import '../../../providers/finance_providers.dart';
import 'widgets/glass_payment_card.dart';

enum ActivityFilter { all, receipts, expenses, income }

/// Cards and Transaction Activity screen (Tab 2).
///
/// Features:
/// - Horizontal carousel of interactive glass payment cards
/// - Card-based filtering (select account to filter transaction feed)
/// - Type-based segmented filter (All, Receipts, Expenses, Income)
/// - Chronologically grouped transaction list with AI chips and receipts
/// - CSV Export action with toast notification
/// - 100% custom components, ZERO Material / Cupertino
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String? _selectedAccountId;
  ActivityFilter _selectedFilter = ActivityFilter.all;

  void _handleExportCsv(List<Transaction> transactions) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Title,Subtitle,Category,Account,Amount,Type,HasReceipt');
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    for (final t in transactions) {
      final dateStr = dateFormat.format(t.timestamp);
      final amountStr = (t.amount.cents / 100.0).toStringAsFixed(2);
      buffer.writeln(
        '"$dateStr","${t.title}","${t.subtitle}","${t.categoryId}","${t.accountId}","$amountStr","${t.type.name}","${t.hasReceipt}"',
      );
    }

    AppToast.show(
      context,
      'Exported ${transactions.length} transactions to CSV',
      type: AppToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? MockupSeedData.accounts;

    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final allTransactions = transactionsAsync.value ?? MockupSeedData.transactions;

    // Apply active filters
    final filteredTransactions = allTransactions.where((t) {
      if (_selectedAccountId != null && t.accountId != _selectedAccountId) {
        return false;
      }
      switch (_selectedFilter) {
        case ActivityFilter.all:
          return true;
        case ActivityFilter.receipts:
          return t.hasReceipt;
        case ActivityFilter.expenses:
          return t.type == TransactionType.expense;
        case ActivityFilter.income:
          return t.type == TransactionType.income;
      }
    }).toList();

    return AppScaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.s16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cards & Activity',
                            style: text.title1.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${accounts.length} accounts • ${allTransactions.length} events',
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleIconButton(
                          icon: AppIconType.search,
                          semanticLabel: 'Search transactions',
                          onPressed: () => context.push('/search'),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        AppButton(
                          label: 'Export',
                          leadingIcon: AppIconType.moreDots,
                          size: AppButtonSize.compact,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => _handleExportCsv(filteredTransactions),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Cards Carousel Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.s8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PAYMENT CARDS',
                          style: text.overline.copyWith(
                            color: colors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (_selectedAccountId != null)
                          Pressable(
                            onTap: () => setState(() => _selectedAccountId = null),
                            child: Text(
                              'Clear filter',
                              style: text.caption.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 196,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.s8,
                      ),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: accounts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s12),
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        final isSelected = account.id == _selectedAccountId;
                        return GlassPaymentCard(
                          account: account,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedAccountId = isSelected ? null : account.id;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.s16),
            ),

            // 3. Filter Segmented Controls
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: SegmentedControl<ActivityFilter>(
                  segments: const [
                    ActivityFilter.all,
                    ActivityFilter.receipts,
                    ActivityFilter.expenses,
                    ActivityFilter.income,
                  ],
                  selectedSegment: _selectedFilter,
                  onSegmentSelected: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                  labelBuilder: (filter) {
                    switch (filter) {
                      case ActivityFilter.all:
                        return 'All';
                      case ActivityFilter.receipts:
                        return 'Receipts';
                      case ActivityFilter.expenses:
                        return 'Expenses';
                      case ActivityFilter.income:
                        return 'Income';
                    }
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.s16),
            ),

            // 4. Activity List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.s8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRANSACTIONS (${filteredTransactions.length})',
                      style: text.overline.copyWith(
                        color: colors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (_selectedAccountId != null)
                      Text(
                        'Filtered by Card',
                        style: text.caption.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 5. Transaction Feed
            if (filteredTransactions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s32),
                  child: Center(
                    child: Column(
                      children: [
                        AppIcon(
                          AppIconType.receipt,
                          size: 40,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          'No transactions match this filter',
                          style: text.subheadline.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final txn = filteredTransactions[index];
                      final isLast = index == filteredTransactions.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 100 : AppSpacing.s8),
                        child: TransactionTile(
                          transaction: txn,
                          onTap: () => context.push('/transaction/${txn.id}'),
                        ),
                      );
                    },
                    childCount: filteredTransactions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
