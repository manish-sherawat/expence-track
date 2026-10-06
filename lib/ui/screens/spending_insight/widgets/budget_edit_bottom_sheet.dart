import 'package:flutter/widgets.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../domain/models/budget.dart';
import '../../../../domain/models/money.dart';

/// Modal bottom sheet for updating category budget limits.
class BudgetEditBottomSheet extends StatefulWidget {
  final List<Budget> budgets;
  final ValueChanged<List<Budget>> onSave;

  const BudgetEditBottomSheet({
    super.key,
    required this.budgets,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Budget> budgets,
    required ValueChanged<List<Budget>> onSave,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      builder: (ctx) => BudgetEditBottomSheet(
        budgets: budgets,
        onSave: onSave,
      ),
    );
  }

  @override
  State<BudgetEditBottomSheet> createState() => _BudgetEditBottomSheetState();
}

class _BudgetEditBottomSheetState extends State<BudgetEditBottomSheet> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final budget in widget.budgets) {
      _controllers[budget.id] = TextEditingController(
        text: (budget.limitAmount.cents ~/ 100).toString(),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleSave() {
    final updatedList = <Budget>[];
    for (final budget in widget.budgets) {
      final ctrl = _controllers[budget.id];
      final text = ctrl?.text.trim() ?? '';
      final dollars = int.tryParse(text) ?? (budget.limitAmount.cents ~/ 100);
      updatedList.add(
        budget.copyWith(
          limitAmount: Money(dollars * 100),
        ),
      );
    }
    widget.onSave(updatedList);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final text = theme.text;
    final colors = theme.colors;

    return AppBottomSheet(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.s8,
          AppSpacing.screenHorizontal,
          AppSpacing.s32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Center(
              child: Text(
                'Edit Monthly Budgets',
                style: text.title2.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Center(
              child: Text(
                'Set spending targets for April 2026',
                style: text.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s20),

            // Budget Input Fields (Scrollable on small screens and when keyboard appears)
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final budget in widget.budgets)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                        child: AppTextField(
                          controller: _controllers[budget.id],
                          label: '${budget.categoryId.replaceFirst('cat_', '').toUpperCase()} Monthly Budget (\$)',
                          placeholder: '700',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: AppButton(
                    label: 'Save Changes',
                    variant: AppButtonVariant.primary,
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
