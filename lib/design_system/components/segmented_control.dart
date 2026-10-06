import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'pressable.dart';

/// iOS/macOS inspired segmented control with a sliding white thumb,
/// spring physics, and zero Material/Cupertino dependencies.
class SegmentedControl<T> extends StatefulWidget {
  final List<T> segments;
  final T selectedSegment;
  final ValueChanged<T> onSegmentSelected;
  final String Function(T item) labelBuilder;

  const SegmentedControl({
    super.key,
    required this.segments,
    required this.selectedSegment,
    required this.onSegmentSelected,
    required this.labelBuilder,
  });

  @override
  State<SegmentedControl<T>> createState() => _SegmentedControlState<T>();
}

class _SegmentedControlState<T> extends State<SegmentedControl<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _thumbPositionAnimation;
  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();
    final initialIdx = widget.segments.indexOf(widget.selectedSegment);
    _prevIndex = initialIdx >= 0 ? initialIdx : 0;
    _animController = AnimationController(
      vsync: this,
      duration: AppMotion.durationNormal,
    );
    _thumbPositionAnimation =
        Tween<double>(
          begin: _prevIndex.toDouble(),
          end: _prevIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: AppMotion.springBouncy,
          ),
        );
  }

  @override
  void didUpdateWidget(SegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIdx = widget.segments.indexOf(widget.selectedSegment);
    if (newIdx >= 0 && newIdx != _prevIndex) {
      _thumbPositionAnimation =
          Tween<double>(
            begin: _prevIndex.toDouble(),
            end: newIdx.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _animController,
              curve: AppMotion.springBouncy,
            ),
          );
      _prevIndex = newIdx;
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final text = theme.text;
    final total = widget.segments.length;

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: AppRadii.fullPill,
        border: Border.all(color: colors.borderSubtle, width: 0.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final segmentWidth = totalWidth / total;
          final thumbWidth = segmentWidth;
          const thumbHeight = 32.0;

          return Stack(
            children: [
              // Sliding white thumb
              AnimatedBuilder(
                animation: _thumbPositionAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: _thumbPositionAnimation.value * segmentWidth,
                    top: 0,
                    width: thumbWidth,
                    height: thumbHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadii.fullPill,
                        boxShadow: AppShadows.segmentedThumb,
                      ),
                    ),
                  );
                },
              ),

              // Segment labels
              Row(
                children: [
                  for (int i = 0; i < total; i++)
                    Expanded(
                      child: Pressable(
                        onTap: () {
                          widget.onSegmentSelected(widget.segments[i]);
                        },
                        hapticType: AppHapticType.selection,
                        child: Container(
                          height: thumbHeight,
                          alignment: Alignment.center,
                          color: const Color(
                            0x00000000,
                          ), // transparent hit target
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.labelBuilder(widget.segments[i]),
                                style: text.caption.copyWith(
                                  color:
                                      widget.segments[i] == widget.selectedSegment
                                      ? colors.primaryInk
                                      : colors.textSecondary,
                                  fontWeight:
                                      widget.segments[i] == widget.selectedSegment
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
