import 'package:flutter/widgets.dart';
import '../../../design_system/components/app_icon.dart';
import '../../../design_system/components/pressable.dart';
import '../../../design_system/tokens/tokens.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
    this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        children: [
          if (currentStep > 0 && onBack != null) ...[
            Pressable(
              onPressed: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadii.borderFull,
                  border: Border.all(color: colors.border),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  AppIconType.arrowLeft,
                  size: 16,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
          ] else ...[
            const SizedBox(width: 36, height: 36),
            const SizedBox(width: AppSpacing.s12),
          ],
          Expanded(
            child: Row(
              children: List.generate(totalSteps, (index) {
                final isCompleted = index <= currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: index < totalSteps - 1 ? AppSpacing.s6 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? colors.accent
                          : colors.border.withValues(alpha: 0.35),
                      borderRadius: AppRadii.borderFull,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 36 + AppSpacing.s12), // Visual balance for back button
        ],
      ),
    );
  }
}
