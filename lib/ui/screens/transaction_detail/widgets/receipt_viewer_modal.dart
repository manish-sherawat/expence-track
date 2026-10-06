import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/receipt.dart';

/// Fullscreen interactive receipt viewer modal with pinch-zoom and pan.
///
/// 100% Zero Material/Cupertino. Uses `InteractiveViewer` from `widgets.dart`.
class ReceiptViewerModal extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onClose;

  const ReceiptViewerModal({
    super.key,
    required this.receipt,
    required this.onClose,
  });

  static Future<void> show(BuildContext context, Receipt receipt) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: const Color(0xCC000000),
        pageBuilder: (context, anim, secAnim) {
          return FadeTransition(
            opacity: anim,
            child: ReceiptViewerModal(
              receipt: receipt,
              onClose: () => Navigator.of(context).pop(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;

    return AppScaffold(
      backgroundColor: const Color(0xEE0B0C0E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Modal Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleIconButton(
                    icon: AppIconType.close,
                    semanticLabel: 'Close viewer',
                    onTap: onClose,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                      child: Column(
                        children: [
                          Text(
                            'Original Receipt',
                            style: text.headline.copyWith(
                              color: const Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pinch to zoom • Pan to inspect',
                            style: text.caption.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  CircleIconButton(
                    icon: AppIconType.receipt,
                    semanticLabel: 'Receipt options',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Zoomable receipt area
            Expanded(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 3.5,
                clipBehavior: Clip.none,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    child: Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAF9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x88000000),
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppSpacing.s24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  receipt.merchantName.toUpperCase(),
                                  style: text.headline.copyWith(
                                    color: const Color(0xFF1F2937),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'STORE #10429 • NEW YORK, NY',
                                  style: text.caption.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  'TEL: (212) 759-8457',
                                  style: text.caption.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.s16),
                          _buildDashedLine(),
                          const SizedBox(height: AppSpacing.s16),

                          // Line items
                          for (final item in receipt.items) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x  ${item.name.toUpperCase()}',
                                    style: text.subheadline.copyWith(
                                      color: const Color(0xFF1F2937),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                Text(
                                  item.price.formatted,
                                  style: text.subheadline.copyWith(
                                    color: const Color(0xFF1F2937),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s8),
                          ],

                          const SizedBox(height: AppSpacing.s12),
                          _buildDashedLine(),
                          const SizedBox(height: AppSpacing.s12),

                          // Subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SUBTOTAL',
                                style: text.caption.copyWith(
                                  color: const Color(0xFF4B5563),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                receipt.subtotal.formatted,
                                style: text.caption.copyWith(
                                  color: const Color(0xFF1F2937),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Tax
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TAX 8.00%',
                                style: text.caption.copyWith(
                                  color: const Color(0xFF4B5563),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                receipt.tax.formatted,
                                style: text.caption.copyWith(
                                  color: const Color(0xFF1F2937),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL',
                                style: text.title3.copyWith(
                                  color: const Color(0xFF111827),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                receipt.total.formatted,
                                style: text.title3.copyWith(
                                  color: const Color(0xFF111827),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.s20),
                          _buildDashedLine(),
                          const SizedBox(height: AppSpacing.s16),

                          // Barcode simulation
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  height: 44,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '||||| |||| || ||||||| ||| ||||',
                                      style: text.bodyMedium.copyWith(
                                        color: const Color(0xFF374151),
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'AUTH 839201 • VISA 4829',
                                  style: text.caption.copyWith(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 10,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Actions Bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Done',
                      variant: AppButtonVariant.primary,
                      onPressed: onClose,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) {
            return Container(
              width: dashWidth,
              height: 1,
              color: const Color(0xFFD1D5DB),
            );
          }),
        );
      },
    );
  }
}
