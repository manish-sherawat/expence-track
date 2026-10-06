import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/seed/mockup_seed_data.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../domain/models/transaction.dart';
import '../../../providers/finance_providers.dart';

enum TxnListFilter { all, expenses, income }

/// Comprehensive full-screen list of all transactions with type filtering and date grouping.
///
/// Strictly ZERO Material / ZERO Cupertino.
class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  ConsumerState<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends ConsumerState<TransactionsListScreen> {
  TxnListFilter _filter = TxnListFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final allTransactions = transactionsAsync.value ?? MockupSeedData.transactions;

    final filtered = allTransactions.where((t) {
      switch (_filter) {
        case TxnListFilter.all:
          return true;
        case TxnListFilter.expenses:
          return t.type == TransactionType.expense;
        case TxnListFilter.income:
          return t.type == TransactionType.income;
      }
    }).toList();

    final grouped = _groupByDate(filtered);

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
                                'All Transactions',
                                style: text.title2.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${filtered.length} total entries',
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
                  CircleIconButton(
                    icon: AppIconType.search,
                    semanticLabel: 'Search',
                    onPressed: () => context.push('/search'),
                  ),
                ],
              ),
            ),

            // Segmented switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: SegmentedControl<TxnListFilter>(
                segments: const [
                  TxnListFilter.all,
                  TxnListFilter.expenses,
                  TxnListFilter.income,
                ],
                selectedSegment: _filter,
                onSegmentSelected: (f) => setState(() => _filter = f),
                labelBuilder: (f) {
                  switch (f) {
                    case TxnListFilter.all:
                      return 'All';
                    case TxnListFilter.expenses:
                      return 'Expenses';
                    case TxnListFilter.income:
                      return 'Income';
                  }
                },
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            // Grouped transaction list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions found for this filter',
                        style: text.subheadline.copyWith(color: colors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.s8,
                      ),
                      itemCount: grouped.length,
                      itemBuilder: (context, groupIndex) {
                        final group = grouped[groupIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                              child: Text(
                                group.dateLabel.toUpperCase(),
                                style: text.overline.copyWith(
                                  color: colors.textSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            ...group.items.map((txn) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                                child: TransactionTile(
                                  transaction: txn,
                                  onTap: () => context.push('/transaction/${txn.id}'),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DateGroup> _groupByDate(List<Transaction> items) {
    final map = <String, List<Transaction>>{};
    final now = DateTime(2026, 4, 4);

    for (final txn in items) {
      final diff = now.difference(DateTime(txn.timestamp.year, txn.timestamp.month, txn.timestamp.day)).inDays;
      String label;
      if (diff == 0) {
        label = 'Today';
      } else if (diff == 1) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMMM d, yyyy').format(txn.timestamp);
      }
      map.putIfAbsent(label, () => []).add(txn);
    }

    return map.entries.map((e) => _DateGroup(dateLabel: e.key, items: e.value)).toList();
  }
}

class _DateGroup {
  final String dateLabel;
  final List<Transaction> items;

  _DateGroup({required this.dateLabel, required this.items});
}
