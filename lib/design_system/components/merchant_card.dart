import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'amount_text.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Compact card showing a single transaction in a merchant's history.
class MiniTxnCard extends StatelessWidget {
  final String dateString;
  final String title;
  final int amountCents;
  final VoidCallback? onTap;

  const MiniTxnCard({
    super.key,
    required this.dateString,
    required this.title,
    required this.amountCents,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    final content = Container(
      width: 140,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: colors.borderSubtle,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateString,
            style: text.caption.copyWith(
              color: colors.textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            title,
            style: text.caption.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.s8),
          AmountText(
            cents: amountCents,
            style: text.subheadline.copyWith(
              fontWeight: FontWeight.w700,
            ),
            centsStyle: text.caption.copyWith(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Pressable(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

/// Detailed merchant card with avatar, name, category, monthly visit counter,
/// total spent, and horizontal list of mini transaction cards.
class MerchantCard extends StatelessWidget {
  final String name;
  final String category;
  final int totalSpentCents;
  final int visitCount;
  final AppIconType icon;
  final List<MiniTxnCard> recentTransactions;
  final VoidCallback? onTap;

  const MerchantCard({
    super.key,
    required this.name,
    required this.category,
    required this.totalSpentCents,
    required this.visitCount,
    this.icon = AppIconType.shopping,
    this.recentTransactions = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: colors.borderSubtle,
          width: 0.5,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: Avatar, Name & Category, Total spend
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                    icon,
                    size: 22,
                    color: colors.primaryInk,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: text.headline.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$category • $visitCount visits this month',
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
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: AmountText(
                  cents: totalSpentCents,
                  style: text.title3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  centsStyle: text.caption,
                ),
              ),
            ],
          ),

          // Horizontal recent transactions if available
          if (recentTransactions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Recent Visits',
              style: text.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (int i = 0; i < recentTransactions.length; i++) ...[
                    recentTransactions[i],
                    if (i < recentTransactions.length - 1)
                      const SizedBox(width: AppSpacing.s8),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
