import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/account.dart';

/// Glass payment card widget mimicking Apple Wallet / premium fintech card aesthetics.
///
/// Features:
/// - Distinct color gradient per card type (Checking vs Savings)
/// - Integrated EMV chip vector graphic
/// - Masked number (•••• 4829)
/// - Tabular currency display with large integer and subtle cents
/// - Zero Material / Zero Cupertino imports
class GlassPaymentCard extends StatelessWidget {
  final Account account;
  final bool isSelected;
  final VoidCallback? onTap;

  const GlassPaymentCard({
    super.key,
    required this.account,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;

    final isSavings = account.type == AccountType.savings;

    // Distinct premium gradient for each account
    final gradientColors = isSavings
        ? [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ]
        : [
            const Color(0xFF111827),
            const Color(0xFF1F2937),
          ];

    final accentTint = isSavings ? const Color(0xFF38BDF8) : const Color(0xFFF97316);

    return Pressable(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 180,
        padding: const EdgeInsets.all(AppSpacing.s20),
        decoration: BoxDecoration(
          borderRadius: AppRadii.cardLarge,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(
            color: isSelected
                ? accentTint.withValues(alpha: 0.8)
                : const Color(0xFFFFFFFF).withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row: Institution + Chip + Brand
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.institution.toUpperCase(),
                        style: text.overline.copyWith(
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.name,
                        style: text.subheadline.copyWith(
                          color: const Color(0xFFF8FAFC),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                // EMV Chip Graphic
                _buildEmvChip(accentTint),
              ],
            ),

            // Middle: Balance display
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABLE BALANCE',
                  style: text.overline.copyWith(
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AmountText(
                    amountMinor: account.balance.cents,
                    size: AmountTextSize.title,
                    overrideColor: const Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),

            // Bottom row: Masked card number & Network
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '•••• ${account.lastFour}',
                    style: text.caption.copyWith(
                      color: const Color(0xFFE2E8F0),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                    borderRadius: AppRadii.fullPill,
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    isSavings ? 'MASTERCARD' : 'VISA',
                    style: text.caption.copyWith(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmvChip(Color accent) {
    return Container(
      width: 32,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFE5C158).withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: const Color(0xFFE5C158).withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
