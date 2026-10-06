import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'pressable.dart';

/// Custom toggle switch with spring slide animation and zero Material/Cupertino widgets.
class AppToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _thumbPositionAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppMotion.durationNormal,
    );
    _thumbPositionAnimation = Tween<double>(
      begin: widget.value ? 1.0 : 0.0,
      end: widget.value ? 1.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: AppMotion.springBouncy,
    ));
  }

  @override
  void didUpdateWidget(AppToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _thumbPositionAnimation = Tween<double>(
        begin: oldWidget.value ? 1.0 : 0.0,
        end: widget.value ? 1.0 : 0.0,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: AppMotion.springBouncy,
      ));
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

    const trackWidth = 50.0;
    const trackHeight = 30.0;
    const thumbSize = 26.0;
    const maxSlide = trackWidth - thumbSize - 4.0; // 2px margin on both sides

    return Pressable(
      onTap: widget.enabled
          ? () {
              widget.onChanged(!widget.value);
            }
          : null,
      hapticType: AppHapticType.selection,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final t = _thumbPositionAnimation.value;
          final trackColor = Color.lerp(
            colors.borderSubtle,
            colors.primaryInk,
            t,
          )!;

          return Container(
            width: trackWidth,
            height: trackHeight,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: AppRadii.fullPill,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: t * maxSlide,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadowColor.withValues(alpha: 0.16),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Custom zero-Material checkbox.
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;

    return Pressable(
      onTap: enabled ? () => onChanged(!value) : null,
      hapticType: AppHapticType.selection,
      child: AnimatedContainer(
        duration: AppMotion.durationFast,
        curve: AppMotion.springGentle,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: value ? colors.primaryInk : colors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? colors.primaryInk : colors.borderSubtle,
            width: 1.5,
          ),
        ),
        child: value
            ? Center(
                child: CustomPaint(
                  size: const Size(12, 10),
                  painter: _CheckmarkPainter(colors.surface),
                ),
              )
            : null,
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final Color color;

  const _CheckmarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.42, size.height * 0.85)
      ..lineTo(size.width * 0.9, size.height * 0.15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Custom zero-Material radio button.
class AppRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final bool enabled;

  const AppRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final isSelected = value == groupValue;

    return Pressable(
      onTap: enabled ? () => onChanged(value) : null,
      hapticType: AppHapticType.selection,
      child: AnimatedContainer(
        duration: AppMotion.durationFast,
        curve: AppMotion.springGentle,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
          border: Border.all(
            color: isSelected ? colors.primaryInk : colors.borderSubtle,
            width: isSelected ? 6.5 : 1.5,
          ),
        ),
      ),
    );
  }
}
