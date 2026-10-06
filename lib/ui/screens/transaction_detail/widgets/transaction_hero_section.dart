import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/category.dart';
import '../../../../domain/models/transaction.dart';

/// Top hero section for Transaction Detail (Screen 2).
///
/// Features:
/// - Merchant name title (32pt bold)
/// - Large signed display amount (e.g. -$32.91)
/// - Date, time, card metadata line (e.g. "April 14, 2026 • 2:45 PM • Visa •••• 4829")
/// - Category pill & AI sparkle chip
class TransactionHeroSection extends StatelessWidget {
  final Transaction transaction;
  final Category? category;

  const TransactionHeroSection({
    super.key,
    required this.transaction,
    this.category,
  });

  String _formatMetaLine(DateTime dt, String? cardLastFour) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final dateStr = dateFormat.format(dt);
    final timeStr = timeFormat.format(dt);
    final cardStr = cardLastFour != null ? 'Visa •••• $cardLastFour' : 'Primary Account';
    return '$dateStr • $timeStr • $cardStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;
    final colors = theme.colors;

    final metaLine = _formatMetaLine(transaction.timestamp, transaction.cardLastFour);
    final categoryName = category?.name ?? transaction.aiSuggestedCategory ?? 'Groceries';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s8),

            // Merchant Name
            Text(
              transaction.title,
              style: text.title1.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.s12),

            // Signed Display Amount (-$32.91)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AmountText(
                amountMinor: transaction.amount.cents,
                size: AmountTextSize.display,
                isSigned: true,
                signStyle: AmountSignStyle.signedWithColor,
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            // Meta line: "April 14, 2026 • 2:45 PM • Visa •••• 4829"
            Text(
              metaLine,
              style: text.caption.copyWith(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.s16),

            // Chips Row: Category + AI Sparkle Chip + Status
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                // Category Chip
                TagChip(
                  label: categoryName,
                  variant: TagChipVariant.neutral,
                ),

                // AI Categorized Sparkle Chip
                if (transaction.aiSuggestedCategory != null || transaction.aiConfirmed)
                  const TagChip(
                    label: 'AI Categorized ✦',
                    variant: TagChipVariant.ai,
                  ),

                // Status Pill
                const TagChip(
                  label: 'Cleared',
                  variant: TagChipVariant.positive,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
