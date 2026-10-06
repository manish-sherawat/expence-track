import 'package:flutter/widgets.dart';
import '../../../../design_system/tokens/tokens.dart';

/// Animated neon scanning laser overlay for receipt OCR processing.
///
/// Strictly ZERO Material / ZERO Cupertino imports.
class ScanningLaserOverlay extends StatefulWidget {
  final bool isScanning;
  final Widget child;

  const ScanningLaserOverlay({
    super.key,
    required this.isScanning,
    required this.child,
  });

  @override
  State<ScanningLaserOverlay> createState() => _ScanningLaserOverlayState();
}

class _ScanningLaserOverlayState extends State<ScanningLaserOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isScanning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScanningLaserOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final laserColor = theme.colors.positive;

    return Stack(
      children: [
        widget.child,
        if (widget.isScanning)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LaserPainter(
                    progress: _controller.value,
                    laserColor: laserColor,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _LaserPainter extends CustomPainter {
  final double progress;
  final Color laserColor;

  _LaserPainter({
    required this.progress,
    required this.laserColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;

    // Soft gradient glow
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          laserColor.withValues(alpha: 0.0),
          laserColor.withValues(alpha: 0.25),
          laserColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 24, size.width, 48));

    canvas.drawRect(Rect.fromLTWH(0, y - 24, size.width, 48), glowPaint);

    // Sharp bright laser core line
    final linePaint = Paint()
      ..color = laserColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(_LaserPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.laserColor != laserColor;
  }
}
