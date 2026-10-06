import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// 44pt circular header button with raised surface, hairline border,
/// subtle shadow, and optional notification badge dot.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    VoidCallback? onTap,
    this.hasBadge = false,
    this.badgeColor,
    this.iconColor,
    this.size = AppSpacing.minTouchTarget,
    this.iconSize = 20.0,
    this.semanticLabel,
  }) : _onTap = onTap ?? onPressed;

  final AppIconType icon;
  final VoidCallback? onPressed;
  final VoidCallback? _onTap;
  VoidCallback? get effectiveOnPressed => onPressed ?? _onTap;
  final bool hasBadge;
  final Color? badgeColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedIconColor = iconColor ?? colors.textPrimary;
    final resolvedBadgeColor = badgeColor ?? colors.negative;

    return SizedBox(
      width: size,
      height: size,
      child: Pressable(
        onPressed: effectiveOnPressed,
        semanticLabel: semanticLabel,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            shape: BoxShape.circle,
            border: Border.all(color: colors.border, width: 1.0),
            boxShadow: AppShadows.circleButton,
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AppIcon(icon, size: iconSize, color: resolvedIconColor),
              if (hasBadge)
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: resolvedBadgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
