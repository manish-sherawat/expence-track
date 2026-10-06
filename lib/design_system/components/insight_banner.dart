import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Tap-friendly AI Insight card with ink sparkle avatar and 2-line preview.
class InsightBanner extends StatelessWidget {
  final String headline;
  final String subheadline;
  final VoidCallback? onTap;

  const InsightBanner({
    super.key,
    required this.headline,
    required this.subheadline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: colors.borderSubtle,
          width: 0.5,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          // 40pt ink circle with gold sparkle icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primaryInk,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppIcon(
                AppIconType.sparkle,
                size: 20,
                color: Color(0xFFFFD700), // Gold sparkle
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),

          // 2-line headline & subheadline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headline,
                  style: text.subheadline.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subheadline,
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),

          // Trailing chevron
          AppIcon(
            AppIconType.chevronRight,
            size: 16,
            color: colors.textTertiary,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Pressable(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
