import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Tactile numeric keypad for fast monetary amount input.
///
/// Layout:
/// 1  2  3
/// 4  5  6
/// 7  8  9
/// .  0  ⌫
///
/// Zero Material / Zero Cupertino.
class AmountKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDecimalPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onLongPressBackspace;

  const AmountKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDecimalPressed,
    required this.onBackspacePressed,
    this.onLongPressBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3'], colors, text),
          const SizedBox(height: AppSpacing.s12),
          _buildRow(['4', '5', '6'], colors, text),
          const SizedBox(height: AppSpacing.s12),
          _buildRow(['7', '8', '9'], colors, text),
          const SizedBox(height: AppSpacing.s12),
          _buildBottomRow(colors, text),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits, AppColors colors, AppTypography text) {
    return Row(
      children: digits.map((digit) {
        return Expanded(
          child: _buildKey(
            child: Text(
              digit,
              style: text.title1.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => onDigitPressed(digit),
            colors: colors,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow(AppColors colors, AppTypography text) {
    return Row(
      children: [
        // Decimal key
        Expanded(
          child: _buildKey(
            child: Text(
              '.',
              style: text.title1.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: onDecimalPressed,
            colors: colors,
          ),
        ),
        // Zero key
        Expanded(
          child: _buildKey(
            child: Text(
              '0',
              style: text.title1.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => onDigitPressed('0'),
            colors: colors,
          ),
        ),
        // Backspace key
        Expanded(
          child: _buildKey(
            child: Center(
              child: AppIcon(
                AppIconType.arrowLeft,
                size: 24,
                color: colors.textPrimary,
              ),
            ),
            onTap: onBackspacePressed,
            onLongPress: onLongPressBackspace,
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _buildKey({
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    required AppColors colors,
  }) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Pressable(
        onTap: onTap,
        onLongPress: onLongPress,
        hapticType: AppHapticType.light,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: AppRadii.card,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
