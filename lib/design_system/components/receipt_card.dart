import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'amount_text.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Single item line on a receipt.
class ReceiptLineItem {
  final String name;
  final int quantity;
  final int priceCents;

  const ReceiptLineItem({
    required this.name,
    this.quantity = 1,
    required this.priceCents,
  });
}

/// Perspective-tilted thumbnail of a paper receipt with dashed lines.
class ReceiptThumb extends StatelessWidget {
  final VoidCallback? onTap;

  const ReceiptThumb({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;

    final card = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002) // Perspective
        ..rotateZ(-0.06), // Tilted angle
      child: Container(
        width: 72,
        height: 96,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.borderSubtle, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: colors.shadowColor.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(2, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header icon
            Center(
              child: AppIcon(
                AppIconType.receipt,
                size: 16,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            // Mini simulated lines
            Container(height: 3, width: 44, color: colors.borderSubtle),
            const SizedBox(height: 4),
            Container(height: 3, width: 32, color: colors.borderSubtle),
            const SizedBox(height: 4),
            Container(height: 3, width: 50, color: colors.borderSubtle),
            const Spacer(),
            // Perforation dashed line
            CustomPaint(
              size: const Size(double.infinity, 2),
              painter: _DashedLinePainter(colors.borderSubtle),
            ),
            const SizedBox(height: 4),
            Container(height: 4, width: 36, color: colors.primaryInk),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Pressable(onTap: onTap, child: card);
    }
    return card;
  }
}

/// Full detailed receipt card with itemized breakdown and zigzag perforated bottom edge.
class ReceiptCard extends StatelessWidget {
  final String merchantName;
  final String dateString;
  final List<ReceiptLineItem> items;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;

  const ReceiptCard({
    super.key,
    required this.merchantName,
    required this.dateString,
    required this.items,
    required this.subtotalCents,
    required this.taxCents,
    required this.totalCents,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Receipt Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AppIcon(
                            AppIconType.receipt,
                            size: 22,
                            color: colors.primaryInk,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        merchantName,
                        style: text.title3.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateString,
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                // Perforated separator
                CustomPaint(
                  size: const Size(double.infinity, 2),
                  painter: _DashedLinePainter(colors.borderSubtle),
                ),
                const SizedBox(height: AppSpacing.s16),

                // Itemized lines
                for (final item in items) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity > 1 ? '${item.quantity}x ' : ''}${item.name}',
                          style: text.subheadline.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      AmountText(
                        amountMinor: item.priceCents,
                        size: AmountTextSize.row,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                ],

                const SizedBox(height: AppSpacing.s8),
                CustomPaint(
                  size: const Size(double.infinity, 2),
                  painter: _DashedLinePainter(colors.borderSubtle),
                ),
                const SizedBox(height: AppSpacing.s12),

                // Subtotal & Tax
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: text.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    AmountText(
                      amountMinor: subtotalCents,
                      size: AmountTextSize.row,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Tax',
                      style: text.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    AmountText(
                      amountMinor: taxCents,
                      size: AmountTextSize.row,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: text.headline.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AmountText(
                      amountMinor: totalCents,
                      size: AmountTextSize.stat,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Zigzag perforated bottom edge
          CustomPaint(
            size: const Size(double.infinity, 12),
            painter: _ZigzagEdgePainter(colors.surface),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(math.min(startX + dashWidth, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color;
}

class _ZigzagEdgePainter extends CustomPainter {
  final Color color;

  const _ZigzagEdgePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const toothWidth = 10.0;
    final teethCount = (size.width / toothWidth).ceil();

    path.moveTo(0, 0);
    for (int i = 0; i < teethCount; i++) {
      final x1 = i * toothWidth + (toothWidth / 2);
      final y1 = size.height;
      final x2 = (i + 1) * toothWidth;
      const y2 = 0.0;

      path.lineTo(x1, y1);
      path.lineTo(x2, y2);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ZigzagEdgePainter oldDelegate) =>
      color != oldDelegate.color;
}
