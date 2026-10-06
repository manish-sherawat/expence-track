import 'package:flutter/widgets.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
    this.greeting = 'Welcome Back,',
    this.onSearchTap,
    this.onNotificationsTap,
    this.hasUnreadNotifications = true,
  });

  final String userName;
  final String greeting;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting & User Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: text.title2.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          // Action Buttons: Search & Bell
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleIconButton(
                icon: AppIconType.search,
                onPressed: onSearchTap,
              ),
              const SizedBox(width: AppSpacing.s8),
              CircleIconButton(
                icon: AppIconType.bell,
                hasBadge: hasUnreadNotifications,
                onPressed: onNotificationsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
