import 'dart:io';
import 'package:flutter/widgets.dart';
import '../../../design_system/components/amount_text.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/app_icon.dart';
import '../../../design_system/components/pressable.dart';
import '../../../design_system/components/status_pill.dart';
import '../../../design_system/components/tag_chip.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../domain/services/i_ai_service.dart';
import 'widgets/scanning_laser_overlay.dart';

/// Zero-Material post-crop receipt review screen.
///
/// Features:
/// - Interactive pinch-to-zoom & pan image viewer
/// - Animated neon laser scan-line overlay
/// - Live OCR parsed fields (merchant, total, taxes, line items)
/// - One-tap confirm / retake actions
class ReceiptScannerReviewScreen extends StatefulWidget {
  final String imagePath;
  final ReceiptScanResult? initialResult;
  final bool isProcessing;
  final VoidCallback? onRetake;
  final ValueChanged<ReceiptScanResult>? onConfirm;

  const ReceiptScannerReviewScreen({
    super.key,
    required this.imagePath,
    this.initialResult,
    this.isProcessing = false,
    this.onRetake,
    this.onConfirm,
  });

  @override
  State<ReceiptScannerReviewScreen> createState() => _ReceiptScannerReviewScreenState();
}

class _ReceiptScannerReviewScreenState extends State<ReceiptScannerReviewScreen> {
  late ReceiptScanResult? _result;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
  }

  @override
  void didUpdateWidget(ReceiptScannerReviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialResult != oldWidget.initialResult) {
      setState(() => _result = widget.initialResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    final merchantName = _result?.merchantName.isNotEmpty == true
        ? _result!.merchantName
        : 'Scanning Receipt...';

    final totalCents = _result?.total.cents ?? 0;
    final subtotalCents = _result?.subtotal.cents ?? 0;
    final taxCents = _result?.tax.cents ?? 0;
    final itemsCount = _result?.items.length ?? 0;

    return Container(
      color: colors.bg,
      child: SafeArea(
        child: Column(
          children: [
            // Custom Zero-Material Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                children: [
                  Pressable(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      alignment: Alignment.center,
                      child: AppIcon(
                        AppIconType.arrowLeft,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      'Review Receipt Scan',
                      style: text.title3.copyWith(color: colors.textPrimary),
                    ),
                  ),
                  StatusPill(
                    label: widget.isProcessing ? 'Scanning...' : 'OCR Verified',
                    isPositive: !widget.isProcessing,
                  ),
                ],
              ),
            ),

            // Zoomable Receipt Viewport with Laser Overlay
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: AppRadii.cardLarge,
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ScanningLaserOverlay(
                    isScanning: widget.isProcessing,
                    child: Center(
                      child: InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 3.5,
                        child: _buildReceiptImage(colors),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            // Bottom Structured Data Card & Actions
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                0,
                AppSpacing.s16,
                AppSpacing.s16,
              ),
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.cardLarge,
                border: Border.all(color: colors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: colors.primaryInk.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              merchantName,
                              style: text.bodyLarge.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              'Auto-extracted from receipt text',
                              style: text.caption.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AmountText(
                        cents: totalCents,
                        size: AmountTextSize.stat,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s12),

                  // Metadata Badges (Tax, Subtotal, Items)
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      TagChip(
                        label: '$itemsCount Items',
                        variant: TagChipVariant.neutral,
                      ),
                      if (taxCents > 0)
                        TagChip(
                          label: 'Tax: \$${(taxCents / 100.0).toStringAsFixed(2)}',
                          variant: TagChipVariant.neutral,
                        ),
                      if (subtotalCents > 0)
                        TagChip(
                          label: 'Subtotal: \$${(subtotalCents / 100.0).toStringAsFixed(2)}',
                          variant: TagChipVariant.neutral,
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Retake',
                          variant: AppButtonVariant.secondary,
                          onPressed: widget.onRetake ?? () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: 'Confirm & Use',
                          variant: AppButtonVariant.primary,
                          onPressed: () {
                            if (_result != null) {
                              widget.onConfirm?.call(_result!);
                              Navigator.of(context).pop(_result);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptImage(AppColors colors) {
    if (widget.imagePath.isNotEmpty) {
      final file = File(widget.imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
        );
      }
    }

    // Fallback visually pleasant mock canvas when no physical camera image exists
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(AppIconType.receipt, size: 48, color: colors.positive),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Paper Receipt Scan',
            style: context.text.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            'Perspective-aligned and cropped',
            style: context.text.caption.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
