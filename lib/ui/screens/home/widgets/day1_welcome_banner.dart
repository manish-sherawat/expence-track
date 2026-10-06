import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/components/app_icon.dart';
import '../../../../design_system/components/glass_surface.dart';
import '../../../../design_system/components/pressable.dart';
import '../../../../design_system/tokens/tokens.dart';

class Day1WelcomeBanner extends StatelessWidget {
  const Day1WelcomeBanner({
    super.key,
    required this.onDismiss,
    this.onAddTransaction,
    this.onScanReceipt,
  });

  final VoidCallback onDismiss;
  final VoidCallback? onAddTransaction;
  final VoidCallback? onScanReceipt;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s8,
      ),
      child: GlassSurface(
        padding: const EdgeInsets.all(AppSpacing.s16),
        borderRadius: AppRadii.card,
        borderColor: colors.accent.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: AppRadii.borderFull,
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(AppIconType.sparkle, size: 18, color: colors.accent),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    'Welcome Aboard!',
                    style: text.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Pressable(
                  onPressed: onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s4),
                    child: AppIcon(AppIconType.close, size: 16, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Your daily safe-to-spend allowance is active. Log your first expense or scan a paper receipt to see your live forecasts.',
              style: text.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Pressable(
                  onPressed: () => context.push('/onboarding'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.12),
                      borderRadius: AppRadii.borderFull,
                      border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(AppIconType.sparkle, size: 12, color: colors.accent),
                        const SizedBox(width: AppSpacing.s6),
                        Text(
                          'Replay Onboarding Tour',
                          style: text.caption.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
}
