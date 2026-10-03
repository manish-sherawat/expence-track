import 'package:flutter/widgets.dart';
import '../tokens/tokens.dart';

/// Custom root scaffold replacing Material Scaffold.
/// Manages safe areas, background surfaces, fixed top bar,
/// body, and floating bottom navigation overlay.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.topBar,
    this.floatingBottomBar,
    this.backgroundColor,
    this.useSafeAreaTop = true,
    this.useSafeAreaBottom = true,
  });

  final Widget body;
  final Widget? topBar;
  final Widget? floatingBottomBar;
  final Color? backgroundColor;
  final bool useSafeAreaTop;
  final bool useSafeAreaBottom;

  /// Standard bottom padding for scrollable views to scroll completely
  /// clear of the floating frosted nav bar.
  static const double bottomNavScrollPadding = 120.0;
  static const double floatingNavHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedBg = backgroundColor ?? colors.screenBase;

    Widget content = body;

    if (topBar != null) {
      content = Column(
        children: [
          topBar!,
          Expanded(child: content),
        ],
      );
    }

    if (useSafeAreaTop || useSafeAreaBottom) {
      content = SafeArea(
        top: useSafeAreaTop,
        bottom: useSafeAreaBottom,
        child: content,
      );
    }

    return Container(
      color: resolvedBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main screen content scrolling under the floating nav
          content,

          // Floating bottom nav bar slot
          if (floatingBottomBar != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: floatingBottomBar!,
              ),
            ),
        ],
      ),
    );
  }
}
