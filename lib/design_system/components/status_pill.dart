import 'package:flutter/widgets.dart';
import '../tokens/tokens.dart';

/// Status state for budget tracking: Over or Under budget.
enum BudgetStatus {
  over,
  under,
}

/// Compact status pill indicating budget status ("Over" or "Under").
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.status,
    this.customLabel,
  });

  factory StatusPill.over({Key? key, String? label}) =>
      StatusPill(key: key, status: BudgetStatus.over, customLabel: label);

  factory StatusPill.under({Key? key, String? label}) =>
      StatusPill(key: key, status: BudgetStatus.under, customLabel: label);

  final BudgetStatus status;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    final isOver = status == BudgetStatus.over;
    final bg = isOver ? colors.accentTint : colors.positiveTint;
    final fg = isOver ? colors.accent : colors.positive;
    final defaultLabel = isOver ? 'Over' : 'Under';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: 3.0,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.pill,
      ),
      child: Text(
        customLabel ?? defaultLabel,
        style: text.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 11.0,
          height: 1.1,
        ),
      ),
    );
  }
}
