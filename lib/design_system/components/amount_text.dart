import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../tokens/tokens.dart';

/// Predefined size tiers for AmountText.
enum AmountTextSize {
  /// 44pt whole amount, 28pt cents
  display,
  /// 34pt whole amount, 22pt cents
  title,
  /// 24pt whole amount, 16pt cents
  stat,
  /// 15pt whole amount, 12pt cents
  row,
}

/// Signed presentation styles for currency amounts.
enum AmountSignStyle {
  /// Displays "+" for positive, "-" for negative, formatted with semantic color
  signedWithColor,
  /// Displays "-" for negative, nothing for positive, colored
  negativeColorOnly,
  /// Standard textPrimary color regardless of sign
  neutral,
}

/// Custom typography widget rendering currency with large dollars and smaller,
/// lighter cents using tabular figures.
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    int? amountMinor,
    int? cents,
    this.currencySymbol = r'$',
    this.size = AmountTextSize.display,
    AmountSignStyle? signStyle,
    bool isSigned = false,
    bool isPositive = false,
    this.overrideColor,
    this.showCents = true,
    this.style,
    this.centsStyle,
  })  : amountMinor = amountMinor ?? (cents != null ? (isSigned && !isPositive ? -cents : cents) : 0),
        signStyle = signStyle ??
            (isSigned
                ? (isPositive ? AmountSignStyle.signedWithColor : AmountSignStyle.negativeColorOnly)
                : AmountSignStyle.neutral);

  /// Amount in integer minor units (cents, e.g. 1289290 = $12,892.90).
  final int amountMinor;
  final String currencySymbol;
  final AmountTextSize size;
  final AmountSignStyle signStyle;
  final Color? overrideColor;
  final bool showCents;
  final TextStyle? style;
  final TextStyle? centsStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final isNegative = amountMinor < 0;
    final isPositive = amountMinor > 0;
    final absAmountMinor = amountMinor.abs();

    final wholeAmount = absAmountMinor ~/ 100;
    final cents = absAmountMinor % 100;

    final formatter = NumberFormat('#,##0');
    final formattedWhole = formatter.format(wholeAmount);
    final formattedCents = '.${cents.toString().padLeft(2, '0')}';

    // Determine sign prefix
    String signPrefix = '';
    if (isNegative) {
      signPrefix = '-';
    } else if (isPositive && signStyle == AmountSignStyle.signedWithColor) {
      signPrefix = '+';
    }

    // Determine text colors
    Color resolvedColor;
    if (overrideColor != null) {
      resolvedColor = overrideColor!;
    } else {
      switch (signStyle) {
        case AmountSignStyle.signedWithColor:
          resolvedColor = isNegative
              ? colors.negative
              : (isPositive ? colors.positive : colors.textPrimary);
          break;
        case AmountSignStyle.negativeColorOnly:
          resolvedColor = isNegative ? colors.negative : colors.textPrimary;
          break;
        case AmountSignStyle.neutral:
          resolvedColor = colors.textPrimary;
          break;
      }
    }

    // Determine font sizes based on tier
    double wholeSize;
    double centsSize;
    const weight = FontWeight.w500;
    double letterSpacing = 0.0;

    switch (size) {
      case AmountTextSize.display:
        wholeSize = 44.0;
        centsSize = 28.0;
        letterSpacing = -1.0;
        break;
      case AmountTextSize.title:
        wholeSize = 34.0;
        centsSize = 22.0;
        break;
      case AmountTextSize.stat:
        wholeSize = 24.0;
        centsSize = 16.0;
        break;
      case AmountTextSize.row:
        wholeSize = 15.0;
        centsSize = 12.0;
        break;
    }

    final wholeStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: wholeSize,
      fontWeight: weight,
      color: resolvedColor,
      letterSpacing: letterSpacing,
      height: 1.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final centsStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: centsSize,
      fontWeight: weight,
      color: (overrideColor != null || signStyle != AmountSignStyle.neutral)
          ? resolvedColor.withValues(alpha: 0.85)
          : colors.textSecondary,
      letterSpacing: letterSpacing,
      height: 1.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final resolvedWholeStyle = style != null ? wholeStyle.merge(style) : wholeStyle;
    final resolvedCentsStyle = this.centsStyle != null ? centsStyle.merge(this.centsStyle) : centsStyle;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$signPrefix$currencySymbol$formattedWhole',
            style: resolvedWholeStyle,
          ),
          if (showCents)
            TextSpan(
              text: formattedCents,
              style: resolvedCentsStyle,
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
