import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'app_icon.dart';
import 'glass_surface.dart';
import 'pressable.dart';

/// Item definition for [FrostedNavBar].
class FrostedNavBarItem {
  final AppIconType icon;
  final String label;

  const FrostedNavBarItem({required this.icon, required this.label});
}

/// Floating frosted glass navigation bar.
///
/// Implements:
/// - 64pt height pill floating above safe bottom
/// - 5 icon slots (4 navigation tabs + 1 center action button)
/// - Spring-animated sliding active bubble behind the selected tab
/// - Center "+" ink button that triggers a distinct callback
/// - Full zero-Material implementation with GlassSurface
class FrostedNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onCenterAction;
  final List<FrostedNavBarItem> leftItems;
  final List<FrostedNavBarItem> rightItems;

  const FrostedNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onCenterAction,
    this.leftItems = const [
      FrostedNavBarItem(icon: AppIconType.home, label: 'Home'),
      FrostedNavBarItem(icon: AppIconType.chart, label: 'Insights'),
    ],
    this.rightItems = const [
      FrostedNavBarItem(icon: AppIconType.receipt, label: 'Activity'),
      FrostedNavBarItem(icon: AppIconType.user, label: 'Profile'),
    ],
  });

  @override
  State<FrostedNavBar> createState() => _FrostedNavBarState();
}

class _FrostedNavBarState extends State<FrostedNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _bubbleController;
  late Animation<double> _bubblePositionAnimation;
  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.selectedIndex;
    _bubbleController = AnimationController(
      vsync: this,
      duration: AppMotion.durationNormal,
    );
    _bubblePositionAnimation =
        Tween<double>(
          begin: _mapIndexToSlot(widget.selectedIndex),
          end: _mapIndexToSlot(widget.selectedIndex),
        ).animate(
          CurvedAnimation(
            parent: _bubbleController,
            curve: AppMotion.springBouncy,
          ),
        );
  }

  @override
  void didUpdateWidget(FrostedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      final fromSlot = _mapIndexToSlot(_prevIndex);
      final toSlot = _mapIndexToSlot(widget.selectedIndex);
      _prevIndex = widget.selectedIndex;

      _bubblePositionAnimation = Tween<double>(begin: fromSlot, end: toSlot)
          .animate(
            CurvedAnimation(
              parent: _bubbleController,
              curve: AppMotion.springBouncy,
            ),
          );
      _bubbleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  // Maps logical 0, 1, 2, 3 index to physical slots 0, 1, 3, 4 (slot 2 is center action)
  double _mapIndexToSlot(int index) {
    if (index < 2) return index.toDouble();
    return (index + 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final totalSlots = widget.leftItems.length + 1 + widget.rightItems.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final barWidth = (maxWidth - AppSpacing.s32).clamp(280.0, 390.0);
        final innerWidth = barWidth - 2.0;
        final slotWidth = innerWidth / totalSlots;
        const barHeight = 64.0;
        const bubbleSize = 44.0;

        return Center(
          child: Container(
            width: barWidth,
            height: barHeight,
            decoration: const BoxDecoration(
              borderRadius: AppRadii.fullPill,
              boxShadow: AppShadows.nav,
            ),
            child: GlassSurface(
              borderRadius: AppRadii.fullPill,
              blurSigma: 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Spring-animated sliding active bubble
                  AnimatedBuilder(
                    animation: _bubblePositionAnimation,
                    builder: (context, child) {
                      final currentSlot = _bubblePositionAnimation.value;
                      final leftOffset =
                          (currentSlot * slotWidth) +
                          (slotWidth - bubbleSize) / 2;

                      return Positioned(
                        left: leftOffset,
                        child: Container(
                          width: bubbleSize,
                          height: bubbleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.surface.withValues(alpha: 0.85),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadowColor.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Navigation items row
                  Row(
                    children: [
                      // Left items
                      for (int i = 0; i < widget.leftItems.length; i++)
                        Expanded(
                          child: _buildNavItem(
                            index: i,
                            item: widget.leftItems[i],
                            isSelected: widget.selectedIndex == i,
                            colors: colors,
                          ),
                        ),

                      // Center "+" Action Button
                      Expanded(
                        child: Center(
                          child: Pressable(
                            onTap: widget.onCenterAction,
                            hapticType: AppHapticType.medium,
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primaryInk,
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primaryInk.withValues(
                                      alpha: 0.28,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AppIcon(
                                  AppIconType.plus,
                                  size: 20,
                                  color: colors.surface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Right items
                      for (int i = 0; i < widget.rightItems.length; i++)
                        Expanded(
                          child: _buildNavItem(
                            index: widget.leftItems.length + i,
                            item: widget.rightItems[i],
                            isSelected:
                                widget.selectedIndex ==
                                (widget.leftItems.length + i),
                            colors: colors,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required FrostedNavBarItem item,
    required bool isSelected,
    required AppColors colors,
  }) {
    return SizedBox(
      height: 64,
      child: Pressable(
        onTap: () => widget.onItemSelected(index),
        hapticType: AppHapticType.selection,
        child: Center(
          child: AppIcon(
            item.icon,
            size: 22,
            color: isSelected ? colors.primaryInk : colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
