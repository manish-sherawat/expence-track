import 'package:flutter/widgets.dart';
import '../tokens/tokens.dart';

/// Custom pressable primitive replacing Material InkWell.
/// Provides smooth scale (0.97) and opacity (0.85) feedback over 90ms ease-out,
/// with haptics and web cursor handling.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    VoidCallback? onPressed,
    VoidCallback? onTap,
    this.onLongPress,
    this.enabled = true,
    this.enableHaptic = true,
    this.hapticType,
    this.scaleDown = AppMotion.pressScale,
    this.opacityDown = AppMotion.pressOpacity,
    this.duration = AppMotion.pressDuration,
    this.semanticLabel,
    this.behavior = HitTestBehavior.opaque,
  }) : onPressed = onPressed ?? onTap;

  final Widget child;
  final VoidCallback? onPressed;
  VoidCallback? get onTap => onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool enableHaptic;
  final AppHapticType? hapticType;
  final double scaleDown;
  final double opacityDown;
  final Duration duration;
  final String? semanticLabel;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _isPressed = false;

  bool get _isInteractive => widget.enabled && (widget.onPressed != null || widget.onLongPress != null);

  void _handleTapDown(TapDownDetails details) {
    if (!_isInteractive) return;
    setState(() => _isPressed = true);
    if (widget.enableHaptic) {
      if (widget.hapticType != null) {
        AppHaptics.perform(widget.hapticType!);
      } else {
        AppHaptics.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isInteractive) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!_isInteractive) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.maybeOf(context);
    final reduceMotion = theme?.reduceMotion ?? false;

    final targetScale = (!reduceMotion && _isPressed) ? widget.scaleDown : 1.0;
    final targetOpacity = _isPressed ? widget.opacityDown : (widget.enabled ? 1.0 : 0.45);

    final content = AnimatedScale(
      scale: targetScale,
      duration: reduceMotion ? Duration.zero : widget.duration,
      curve: AppMotion.easeOut,
      child: AnimatedOpacity(
        opacity: targetOpacity,
        duration: reduceMotion ? Duration.zero : widget.duration,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );

    return Semantics(
      button: true,
      enabled: _isInteractive,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: _isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: widget.behavior,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _isInteractive ? widget.onPressed : null,
          onLongPress: _isInteractive ? widget.onLongPress : null,
          child: content,
        ),
      ),
    );
  }
}
