import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart'
    hide ReceiptLineItem;
import '../../../../design_system/components/receipt_card.dart' as rc;
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/receipt.dart';
import 'receipt_viewer_modal.dart';

/// AI Receipt Scan Card Section for Transaction Detail (Screen 2).
///
/// Features:
/// - Sparkle badge & header
/// - Perspective receipt thumbnail
/// - Itemized receipt breakdown with zigzag perforated edge
/// - Actions to inspect fullscreen or re-scan
class AiReceiptSection extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback? onRescan;

  const AiReceiptSection({
    super.key,
    required this.receipt,
    this.onRescan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;
    final colors = theme.colors;

    final receiptCardItems = receipt.items.map((item) {
      return rc.ReceiptLineItem(
        name: item.name,
        quantity: item.quantity,
        priceCents: item.price.cents,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row with AI Sparkle & Thumbnail
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.primaryInk,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppIcon(
                          AppIconType.sparkle,
                          size: 16,
                          color: colors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Flexible(
                      child: Text(
                        'AI Receipt Scan',
                        style: text.title3.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    TagChip(
                      label: '${receipt.items.length} Items • Verified',
                      variant: TagChipVariant.ai,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),

              // Interactive tilted paper thumb
              ReceiptThumb(
                onTap: () => ReceiptViewerModal.show(context, receipt),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s16),

          // The Detailed Itemized Receipt Card
          ReceiptCard(
            merchantName: receipt.merchantName,
            dateString: 'April 14, 2026 • 2:45 PM',
            items: receiptCardItems,
            subtotalCents: receipt.subtotal.cents,
            taxCents: receipt.tax.cents,
            totalCents: receipt.total.cents,
          ),

          const SizedBox(height: AppSpacing.s12),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'View Fullscreen',
                  leadingIcon: AppIconType.receipt,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => ReceiptViewerModal.show(context, receipt),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              AppButton(
                label: 'Re-scan',
                leadingIcon: AppIconType.sparkle,
                variant: AppButtonVariant.ghost,
                onPressed: onRescan,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
