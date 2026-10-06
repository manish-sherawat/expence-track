import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/merchant.dart';
import '../../../../domain/models/transaction.dart';

/// Merchant Information and Recent Visits Section for Transaction Detail (Screen 2).
class MerchantInfoSection extends StatelessWidget {
  final Merchant merchant;
  final List<Transaction> similarTransactions;
  final ValueChanged<Transaction>? onTransactionTap;

  const MerchantInfoSection({
    super.key,
    required this.merchant,
    this.similarTransactions = const [],
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;
    final colors = theme.colors;

    final miniTxnCards = similarTransactions.map((tx) {
      final dateStr = '${_shortMonth(tx.timestamp.month)} ${tx.timestamp.day}';
      return MiniTxnCard(
        dateString: dateStr,
        title: tx.title,
        amountCents: tx.amount.cents,
        onTap: () => onTransactionTap?.call(tx),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Merchant Details',
            style: text.title3.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSpacing.s12),

          // Merchant Card
          MerchantCard(
            name: merchant.name,
            category: merchant.category,
            totalSpentCents: merchant.totalSpent.cents,
            visitCount: merchant.visitCount,
            icon: _iconForCategory(merchant.iconKey),
            recentTransactions: miniTxnCards,
          ),

          if (merchant.address != null || merchant.phone != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.card,
                border: Border.all(color: colors.borderSubtle, width: 0.5),
              ),
              child: Column(
                children: [
                  if (merchant.address != null)
                    Row(
                      children: [
                        AppIcon(
                          AppIconType.search,
                          size: 16,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Expanded(
                          child: Text(
                            merchant.address!,
                            style: text.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (merchant.address != null && merchant.phone != null)
                    const SizedBox(height: AppSpacing.s8),
                  if (merchant.phone != null)
                    Row(
                      children: [
                        AppIcon(
                          AppIconType.bell,
                          size: 16,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Expanded(
                          child: Text(
                            merchant.phone!,
                            style: text.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  AppIconType _iconForCategory(String? key) {
    switch (key?.toLowerCase()) {
      case 'food':
        return AppIconType.food;
      case 'rent':
        return AppIconType.rent;
      case 'transport':
        return AppIconType.transport;
      case 'shopping':
        return AppIconType.shopping;
      case 'wallet':
        return AppIconType.wallet;
      default:
        return AppIconType.shopping;
    }
  }

  String _shortMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
