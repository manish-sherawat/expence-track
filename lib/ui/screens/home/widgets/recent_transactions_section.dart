import 'package:flutter/widgets.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/transaction.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    this.onSeeAllTap,
    this.onTransactionTap,
  });

  final List<Transaction> transactions;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Transaction>? onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    // Group transactions by Today, Yesterday, Earlier
    final today = DateTime(2026, 4, 14); // Target mockup reference day
    final yesterday = DateTime(2026, 4, 13);

    final todayTxns = <Transaction>[];
    final yesterdayTxns = <Transaction>[];
    final earlierTxns = <Transaction>[];

    for (final t in transactions) {
      final tDate = DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);
      if (tDate.isAtSameMomentAs(today)) {
        todayTxns.add(t);
      } else if (tDate.isAtSameMomentAs(yesterday)) {
        yesterdayTxns.add(t);
      } else {
        earlierTxns.add(t);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: text.headline.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              if (onSeeAllTap != null)
                Pressable(
                  onPressed: onSeeAllTap,
                  child: Text(
                    'See all',
                    style: text.caption.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),

        // Today Group
        if (todayTxns.isNotEmpty) ...[
          _buildDateHeader(context, 'Today'),
          ...todayTxns.map((t) => _buildTile(context, t)),
        ],

        // Yesterday Group
        if (yesterdayTxns.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s12),
          _buildDateHeader(context, 'Yesterday'),
          ...yesterdayTxns.map((t) => _buildTile(context, t)),
        ],

        // Earlier Group
        if (earlierTxns.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s12),
          _buildDateHeader(context, 'Earlier this month'),
          ...earlierTxns.take(5).map((t) => _buildTile(context, t)),
        ],
      ],
    );
  }

  Widget _buildDateHeader(BuildContext context, String title) {
    final colors = context.colors;
    final text = context.text;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.s6,
      ),
      child: Text(
        title,
        style: text.caption.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, Transaction t) {
    AppIconType icon;
    switch (t.categoryId) {
      case 'cat_food':
        icon = AppIconType.food;
        break;
      case 'cat_transport':
        icon = AppIconType.transport;
        break;
      case 'cat_shopping':
        icon = AppIconType.shopping;
        break;
      case 'cat_rent':
        icon = AppIconType.rent;
        break;
      case 'cat_salary':
        icon = AppIconType.wallet;
        break;
      default:
        icon = t.isIncome ? AppIconType.wallet : AppIconType.shopping;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 3,
      ),
      child: TransactionTile(
        title: t.title,
        subtitle: t.subtitle,
        amountCents: t.amount.cents,
        isIncome: t.isIncome,
        icon: icon,
        aiChipLabel: t.aiSuggestedCategory,
        onTap: onTransactionTap != null ? () => onTransactionTap!(t) : null,
      ),
    );
  }
}
