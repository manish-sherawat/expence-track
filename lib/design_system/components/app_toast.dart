import 'dart:async';
import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'app_icon.dart';

/// Floating toast banner with icon and message.
class AppToastWidget extends StatelessWidget {
  final String message;
  final AppIconType? icon;
  final Color? iconColor;

  const AppToastWidget({
    super.key,
    required this.message,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = context.text;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colors.primaryInk,
        borderRadius: AppRadii.fullPill,
        boxShadow: AppShadows.cardHover,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(
              icon!,
              size: 16,
              color: iconColor ?? colors.surface,
            ),
            const SizedBox(width: AppSpacing.s8),
          ],
          Flexible(
            child: Text(
              message,
              style: text.subheadline.copyWith(
                color: colors.surface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Global helper to display toast notification over the root overlay.
void showAppToast(
  BuildContext context, {
  required String message,
  AppIconType? icon,
  Color? iconColor,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: Center(
          child: AppToastWidget(
            message: message,
            icon: icon,
            iconColor: iconColor,
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  Timer(duration, () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}

/// Semantic style types for AppToast.
enum AppToastType {
  info,
  success,
  warning,
  error,
  neutral,
}

/// Static utility for showing quick toasts.
class AppToast {
  const AppToast._();

  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppIconType? icon;
    Color? iconColor;

    switch (type) {
      case AppToastType.success:
        icon = AppIconType.check;
        iconColor = const Color(0xFF10B981);
        break;
      case AppToastType.error:
        icon = AppIconType.close;
        iconColor = const Color(0xFFEF4444);
        break;
      case AppToastType.warning:
        icon = AppIconType.sparkle;
        iconColor = const Color(0xFFF59E0B);
        break;
      case AppToastType.info:
      case AppToastType.neutral:
        icon = AppIconType.sparkle;
        break;
    }

    showAppToast(
      context,
      message: message,
      icon: icon,
      iconColor: iconColor,
      duration: duration,
    );
  }
}
