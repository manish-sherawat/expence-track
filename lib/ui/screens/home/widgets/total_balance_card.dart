import 'package:flutter/widgets.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/money.dart';

class TotalBalanceCard extends StatelessWidget {
  const TotalBalanceCard({
    super.key,
    required this.totalBalance,
    required this.income,
    required this.expenses,
    required this.saved,
    this.onTap,
  });

  final Money totalBalance;
  final Money income;
  final Money expenses;
  final Money saved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Pressable(
        onPressed: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.card,
            border: Border.all(
              color: colors.borderSubtle,
              width: 0.5,
            ),
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL BALANCE',
                    style: text.caption.copyWith(
                      color: colors.textSecondary,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colors.positive,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Live',
                        style: text.caption.copyWith(
                          color: colors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),

              // Large Main Amount
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AmountText(
                  amountMinor: totalBalance.cents,
                  size: AmountTextSize.display,
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // Divider
              Container(
                height: 0.5,
                color: colors.borderSubtle,
              ),

              const SizedBox(height: AppSpacing.s16),

              // 3-Column Stats Row: Income, Expenses, Saved
              Row(
                children: [
                  // Income
                  Expanded(
                    child: _StatColumn(
                      label: 'Income',
                      amountMinor: income.cents,
                      signStyle: AmountSignStyle.signedWithColor,
                    ),
                  ),

                  // Divider
                  Container(
                    width: 0.5,
                    height: 36,
                    color: colors.borderSubtle,
                  ),

                  // Expenses
                  Expanded(
                    child: _StatColumn(
                      label: 'Expenses',
                      amountMinor: -expenses.cents.abs(),
                      signStyle: AmountSignStyle.signedWithColor,
                    ),
                  ),

                  // Divider
                  Container(
                    width: 0.5,
                    height: 36,
                    color: colors.borderSubtle,
                  ),

                  // Saved
                  Expanded(
                    child: _StatColumn(
                      label: 'Saved',
                      amountMinor: saved.cents,
                      signStyle: AmountSignStyle.neutral,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.amountMinor,
    this.signStyle = AmountSignStyle.neutral,
  });

  final String label;
  final int amountMinor;
  final AmountSignStyle signStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AmountText(
              amountMinor: amountMinor,
              size: AmountTextSize.stat,
              signStyle: signStyle,
            ),
          ),
        ],
      ),
    );
  }
}
