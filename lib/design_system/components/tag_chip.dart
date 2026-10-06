import 'package:flutter/widgets.dart';
import '../tokens/tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Semantic variants for TagChip styling.
enum TagChipVariant {
  neutral,
  info,
  warning,
  positive,
  ai,
}

/// Pill chip component for categories and AI sparkle indicators.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.variant = TagChipVariant.neutral,
    this.hasSparkle = false,
    this.leading,
    this.onTap,
  });

  /// Factory for the AI-categorization sparkle chip (e.g. "✦ Food", "✦ Shopping").
  factory TagChip.ai({
    Key? key,
    required String label,
    VoidCallback? onTap,
  }) {
    return TagChip(
      key: key,
      label: label,
      variant: TagChipVariant.info,
      hasSparkle: true,
      onTap: onTap,
    );
  }

  final String label;
  final TagChipVariant variant;
  final bool hasSparkle;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    Color bg;
    Color fg;
    Color? border;

    switch (variant) {
      case TagChipVariant.neutral:
        bg = colors.surface;
        fg = colors.textSecondary;
        border = colors.border;
        break;
      case TagChipVariant.ai:
      case TagChipVariant.info:
        bg = colors.infoTint;
        fg = colors.info;
        border = null;
        break;
      case TagChipVariant.warning:
        bg = colors.accentTint;
        fg = colors.accent;
        border = null;
        break;
      case TagChipVariant.positive:
        bg = colors.positiveTint;
        fg = colors.positive;
        border = null;
        break;
    }

    final showSparkle = hasSparkle || variant == TagChipVariant.ai;

    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.pill,
        border: border != null ? Border.all(color: border, width: 1.0) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showSparkle) ...[
            AppIcon(
              AppIconType.sparkle,
              size: 11.0,
              color: fg,
            ),
            const SizedBox(width: AppSpacing.s4),
          ] else if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.s4),
          ],
          Text(
            label,
            style: text.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Pressable(
        onPressed: onTap,
        child: content,
      );
    }

    return content;
  }
}
