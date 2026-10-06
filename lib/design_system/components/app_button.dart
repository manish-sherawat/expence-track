import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../tokens/tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Button visual variants.
enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
}

/// Button size tiers.
enum AppButtonSize {
  compact,
  regular,
  large,
}

/// Primary action button built on Pressable without Material dependencies.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.enabled = true,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final AppIconType? leadingIcon;
  final AppIconType? trailingIcon;
  final bool isLoading;
  final bool enabled;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    Color bg;
    Color fg;
    Color? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = colors.ink;
        fg = colors.bg;
        border = null;
        break;
      case AppButtonVariant.secondary:
        bg = colors.surface;
        fg = colors.textPrimary;
        border = colors.border;
        break;
      case AppButtonVariant.ghost:
        bg = const Color(0x00000000);
        fg = colors.textPrimary;
        border = null;
        break;
      case AppButtonVariant.destructive:
        bg = colors.negative;
        fg = const Color(0xFFFFFFFF);
        border = null;
        break;
    }

    double height;
    EdgeInsets padding;
    TextStyle labelStyle;
    double iconSize;

    switch (size) {
      case AppButtonSize.compact:
        height = 36.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.s12);
        labelStyle = text.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );
        iconSize = 16.0;
        break;
      case AppButtonSize.regular:
        height = 48.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.s20);
        labelStyle = text.body.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );
        iconSize = 18.0;
        break;
      case AppButtonSize.large:
        height = 54.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.s24);
        labelStyle = text.rowTitle.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );
        iconSize = 20.0;
        break;
    }

    final content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLoading) ...[
          _CustomLoadingSpinner(size: iconSize, color: fg),
          const SizedBox(width: AppSpacing.s8),
        ] else if (leadingIcon != null) ...[
          AppIcon(leadingIcon!, size: iconSize, color: fg),
          const SizedBox(width: AppSpacing.s8),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: labelStyle,
              maxLines: 1,
            ),
          ),
        ),
        if (!isLoading && trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.s8),
          AppIcon(trailingIcon!, size: iconSize, color: fg),
        ],
      ],
    );

    return Pressable(
      onPressed: (!isLoading && enabled) ? onPressed : null,
      enabled: enabled && !isLoading,
      child: Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.pill,
          border: border != null ? Border.all(color: border, width: 1.0) : null,
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}

/// Custom continuous rotating spinner built with AnimatedBuilder.
class _CustomLoadingSpinner extends StatefulWidget {
  const _CustomLoadingSpinner({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  State<_CustomLoadingSpinner> createState() => _CustomLoadingSpinnerState();
}

class _CustomLoadingSpinnerState extends State<_CustomLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _SpinnerPainter(color: widget.color),
            ),
          ),
        );
      },
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.14;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Track
    canvas.drawCircle(center, radius, paint);

    // Active spinning arc
    final activePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 1.2,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) =>
      oldDelegate.color != color;
}
