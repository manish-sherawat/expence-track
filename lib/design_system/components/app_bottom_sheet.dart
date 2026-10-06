import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'glass_surface.dart';

/// Custom bottom sheet container with drag handle and spring dismissal.
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final bool isGlass;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.isGlass = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? child,
    WidgetBuilder? builder,
    String? title,
    bool isGlass = false,
  }) {
    return showAppBottomSheet<T>(
      context: context,
      isGlass: isGlass,
      builder: (ctx) {
        final contentWidget = child ?? (builder != null ? builder(ctx) : const SizedBox.shrink());
        if (title != null) {
          final theme = AppTheme.of(ctx);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s20,
                  vertical: AppSpacing.s8,
                ),
                child: Text(
                  title,
                  style: theme.text.title3.copyWith(
                    color: theme.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              contentWidget,
            ],
          );
        }
        return contentWidget;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;

    final sheetContent = Container(
      decoration: BoxDecoration(
        color: isGlass ? null : colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppShadows.cardHover,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle pill
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.borderSubtle,
              borderRadius: AppRadii.fullPill,
            ),
          ),
          // Content
          Flexible(child: child),
        ],
      ),
    );

    if (isGlass) {
      return GlassSurface(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: sheetContent,
      );
    }

    return sheetContent;
  }
}

/// Zero-Material bottom sheet route launcher.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isGlass = false,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: const Color(0x66000000),
      transitionDuration: AppMotion.durationNormal,
      reverseTransitionDuration: AppMotion.durationFast,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: AppMotion.springBouncy,
            )),
            child: AppBottomSheet(
              isGlass: isGlass,
              child: builder(context),
            ),
          ),
        );
      },
    ),
  );
}
