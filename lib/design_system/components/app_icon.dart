import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../tokens/tokens.dart';

/// Enum of all outline vector icons used across the Salary Tracker app.
/// Completely independent of Material/Cupertino icon fonts.
enum AppIconType {
  search,
  bell,
  sparkle,
  arrowLeft,
  arrowRight,
  arrowUp,
  arrowDown,
  moreDots,
  chevronRight,
  chevronDown,
  chevronUp,
  home,
  chart,
  plus,
  wallet,
  user,
  trendUp,
  trendDown,
  check,
  close,
  food,
  rent,
  transport,
  shopping,
  receipt,
  shield,
}

/// Custom vector outline icon component rendered via CustomPainter.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.type, {
    super.key,
    this.size = 20.0,
    this.color,
    this.strokeWidth = 1.75,
  });

  const AppIcon.named({
    super.key,
    required this.type,
    this.size = 20.0,
    this.color,
    this.strokeWidth = 1.75,
  });

  final AppIconType type;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.colors.textPrimary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AppIconPainter(
          type: type,
          color: resolvedColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  const _AppIconPainter({
    required this.type,
    required this.color,
    required this.strokeWidth,
  });

  final AppIconType type;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case AppIconType.search:
        // Circle + handle
        final radius = w * 0.32;
        final center = Offset(w * 0.42, h * 0.42);
        canvas.drawCircle(center, radius, strokePaint);
        canvas.drawLine(
          Offset(center.dx + radius * 0.7, center.dy + radius * 0.7),
          Offset(w * 0.88, h * 0.88),
          strokePaint,
        );
        break;

      case AppIconType.bell:
        final path = Path()
          ..moveTo(w * 0.5, h * 0.15)
          ..cubicTo(w * 0.3, h * 0.15, w * 0.25, h * 0.45, w * 0.2, h * 0.65)
          ..lineTo(w * 0.8, h * 0.65)
          ..cubicTo(w * 0.75, h * 0.45, w * 0.7, h * 0.15, w * 0.5, h * 0.15)
          ..close();
        canvas.drawPath(path, strokePaint);
        // Clapper
        canvas.drawArc(
          Rect.fromCenter(center: Offset(w * 0.5, h * 0.75), width: w * 0.22, height: h * 0.22),
          0,
          math.pi,
          false,
          strokePaint,
        );
        // Top loop
        canvas.drawCircle(Offset(w * 0.5, h * 0.12), w * 0.04, strokePaint);
        break;

      case AppIconType.sparkle:
        // 4-pointed diamond star
        final path = Path()
          ..moveTo(w * 0.5, 0)
          ..quadraticBezierTo(w * 0.5, h * 0.5, w, h * 0.5)
          ..quadraticBezierTo(w * 0.5, h * 0.5, w * 0.5, h)
          ..quadraticBezierTo(w * 0.5, h * 0.5, 0, h * 0.5)
          ..quadraticBezierTo(w * 0.5, h * 0.5, w * 0.5, 0)
          ..close();
        canvas.drawPath(path, fillPaint);
        break;

      case AppIconType.arrowLeft:
        final path = Path()
          ..moveTo(w * 0.62, h * 0.22)
          ..lineTo(w * 0.35, h * 0.5)
          ..lineTo(w * 0.62, h * 0.78);
        canvas.drawPath(path, strokePaint);
        canvas.drawLine(Offset(w * 0.35, h * 0.5), Offset(w * 0.78, h * 0.5), strokePaint);
        break;

      case AppIconType.arrowRight:
        final path = Path()
          ..moveTo(w * 0.38, h * 0.22)
          ..lineTo(w * 0.65, h * 0.5)
          ..lineTo(w * 0.38, h * 0.78);
        canvas.drawPath(path, strokePaint);
        canvas.drawLine(Offset(w * 0.65, h * 0.5), Offset(w * 0.22, h * 0.5), strokePaint);
        break;

      case AppIconType.arrowUp:
        final path = Path()
          ..moveTo(w * 0.22, h * 0.62)
          ..lineTo(w * 0.5, h * 0.35)
          ..lineTo(w * 0.78, h * 0.62);
        canvas.drawPath(path, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.35), Offset(w * 0.5, h * 0.78), strokePaint);
        break;

      case AppIconType.arrowDown:
        final path = Path()
          ..moveTo(w * 0.22, h * 0.38)
          ..lineTo(w * 0.5, h * 0.65)
          ..lineTo(w * 0.78, h * 0.38);
        canvas.drawPath(path, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.65), Offset(w * 0.5, h * 0.22), strokePaint);
        break;

      case AppIconType.moreDots:
        final r = strokeWidth * 0.8;
        canvas.drawCircle(Offset(w * 0.25, h * 0.5), r, fillPaint);
        canvas.drawCircle(Offset(w * 0.50, h * 0.5), r, fillPaint);
        canvas.drawCircle(Offset(w * 0.75, h * 0.5), r, fillPaint);
        break;

      case AppIconType.chevronRight:
        final path = Path()
          ..moveTo(w * 0.38, h * 0.25)
          ..lineTo(w * 0.65, h * 0.5)
          ..lineTo(w * 0.38, h * 0.75);
        canvas.drawPath(path, strokePaint);
        break;

      case AppIconType.chevronDown:
        final path = Path()
          ..moveTo(w * 0.25, h * 0.38)
          ..lineTo(w * 0.5, h * 0.65)
          ..lineTo(w * 0.75, h * 0.38);
        canvas.drawPath(path, strokePaint);
        break;

      case AppIconType.chevronUp:
        final path = Path()
          ..moveTo(w * 0.25, h * 0.65)
          ..lineTo(w * 0.5, h * 0.38)
          ..lineTo(w * 0.75, h * 0.65);
        canvas.drawPath(path, strokePaint);
        break;

      case AppIconType.receipt:
        // Paper sheet outline with jagged bottom
        final path = Path()
          ..moveTo(w * 0.22, h * 0.15)
          ..lineTo(w * 0.78, h * 0.15)
          ..lineTo(w * 0.78, h * 0.85)
          ..lineTo(w * 0.68, h * 0.78)
          ..lineTo(w * 0.58, h * 0.85)
          ..lineTo(w * 0.48, h * 0.78)
          ..lineTo(w * 0.38, h * 0.85)
          ..lineTo(w * 0.28, h * 0.78)
          ..lineTo(w * 0.22, h * 0.85)
          ..close();
        canvas.drawPath(path, strokePaint);
        canvas.drawLine(Offset(w * 0.32, h * 0.32), Offset(w * 0.68, h * 0.32), strokePaint);
        canvas.drawLine(Offset(w * 0.32, h * 0.46), Offset(w * 0.68, h * 0.46), strokePaint);
        canvas.drawLine(Offset(w * 0.32, h * 0.60), Offset(w * 0.54, h * 0.60), strokePaint);
        break;

      case AppIconType.home:
        final path = Path()
          ..moveTo(w * 0.15, h * 0.45)
          ..lineTo(w * 0.5, h * 0.15)
          ..lineTo(w * 0.85, h * 0.45)
          ..lineTo(w * 0.85, h * 0.85)
          ..lineTo(w * 0.15, h * 0.85)
          ..close();
        canvas.drawPath(path, strokePaint);
        // Arched Door
        final doorPath = Path()
          ..moveTo(w * 0.38, h * 0.85)
          ..lineTo(w * 0.38, h * 0.58)
          ..arcToPoint(
            Offset(w * 0.62, h * 0.58),
            radius: Radius.circular(w * 0.12),
          )
          ..lineTo(w * 0.62, h * 0.85);
        canvas.drawPath(doorPath, strokePaint);
        break;

      case AppIconType.chart:
        // Bar chart / insights icon
        canvas.drawLine(Offset(w * 0.25, h * 0.85), Offset(w * 0.25, h * 0.55), strokePaint);
        canvas.drawLine(Offset(w * 0.50, h * 0.85), Offset(w * 0.50, h * 0.30), strokePaint);
        canvas.drawLine(Offset(w * 0.75, h * 0.85), Offset(w * 0.75, h * 0.45), strokePaint);
        canvas.drawLine(Offset(w * 0.15, h * 0.85), Offset(w * 0.85, h * 0.85), strokePaint);
        break;

      case AppIconType.plus:
        canvas.drawLine(Offset(w * 0.5, h * 0.2), Offset(w * 0.5, h * 0.8), strokePaint);
        canvas.drawLine(Offset(w * 0.2, h * 0.5), Offset(w * 0.8, h * 0.5), strokePaint);
        break;

      case AppIconType.wallet:
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.15, h * 0.25, w * 0.7, h * 0.55),
          const Radius.circular(4),
        );
        canvas.drawRRect(rect, strokePaint);
        // Flap
        canvas.drawLine(Offset(w * 0.15, h * 0.42), Offset(w * 0.85, h * 0.42), strokePaint);
        canvas.drawCircle(Offset(w * 0.65, h * 0.55), strokeWidth * 0.8, fillPaint);
        break;

      case AppIconType.user:
        // Head
        canvas.drawCircle(Offset(w * 0.5, h * 0.35), w * 0.2, strokePaint);
        // Shoulders
        final path = Path()
          ..moveTo(w * 0.18, h * 0.82)
          ..cubicTo(w * 0.22, h * 0.65, w * 0.78, h * 0.65, w * 0.82, h * 0.82);
        canvas.drawPath(path, strokePaint);
        break;

      case AppIconType.trendUp:
        final path = Path()
          ..moveTo(w * 0.18, h * 0.78)
          ..lineTo(w * 0.48, h * 0.48)
          ..lineTo(w * 0.65, h * 0.62)
          ..lineTo(w * 0.85, h * 0.30);
        canvas.drawPath(path, strokePaint);
        // Arrow head
        canvas.drawLine(Offset(w * 0.85, h * 0.30), Offset(w * 0.68, h * 0.30), strokePaint);
        canvas.drawLine(Offset(w * 0.85, h * 0.30), Offset(w * 0.85, h * 0.47), strokePaint);
        break;

      case AppIconType.trendDown:
        final path = Path()
          ..moveTo(w * 0.18, h * 0.30)
          ..lineTo(w * 0.48, h * 0.60)
          ..lineTo(w * 0.65, h * 0.46)
          ..lineTo(w * 0.85, h * 0.78);
        canvas.drawPath(path, strokePaint);
        // Arrow head
        canvas.drawLine(Offset(w * 0.85, h * 0.78), Offset(w * 0.68, h * 0.78), strokePaint);
        canvas.drawLine(Offset(w * 0.85, h * 0.78), Offset(w * 0.85, h * 0.61), strokePaint);
        break;

      case AppIconType.check:
        final path = Path()
          ..moveTo(w * 0.2, h * 0.5)
          ..lineTo(w * 0.42, h * 0.72)
          ..lineTo(w * 0.82, h * 0.28);
        canvas.drawPath(path, strokePaint);
        break;

      case AppIconType.close:
        canvas.drawLine(Offset(w * 0.25, h * 0.25), Offset(w * 0.75, h * 0.75), strokePaint);
        canvas.drawLine(Offset(w * 0.75, h * 0.25), Offset(w * 0.25, h * 0.75), strokePaint);
        break;

      case AppIconType.food:
        // Bowl outline
        final path = Path()
          ..moveTo(w * 0.15, h * 0.45)
          ..quadraticBezierTo(w * 0.5, h * 0.85, w * 0.85, h * 0.45)
          ..close();
        canvas.drawPath(path, strokePaint);
        // Steam / chopsticks
        canvas.drawLine(Offset(w * 0.35, h * 0.35), Offset(w * 0.35, h * 0.22), strokePaint);
        canvas.drawLine(Offset(w * 0.50, h * 0.35), Offset(w * 0.50, h * 0.18), strokePaint);
        canvas.drawLine(Offset(w * 0.65, h * 0.35), Offset(w * 0.65, h * 0.22), strokePaint);
        break;

      case AppIconType.rent:
        // House with roof
        final path = Path()
          ..moveTo(w * 0.15, h * 0.45)
          ..lineTo(w * 0.5, h * 0.18)
          ..lineTo(w * 0.85, h * 0.45)
          ..lineTo(w * 0.80, h * 0.82)
          ..lineTo(w * 0.20, h * 0.82)
          ..close();
        canvas.drawPath(path, strokePaint);
        break;

      case AppIconType.transport:
        // Car outline
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.15, h * 0.42, w * 0.7, h * 0.32),
          const Radius.circular(4),
        );
        canvas.drawRRect(rect, strokePaint);
        // Wheels
        canvas.drawCircle(Offset(w * 0.32, h * 0.76), w * 0.1, strokePaint);
        canvas.drawCircle(Offset(w * 0.68, h * 0.76), w * 0.1, strokePaint);
        // Top cabin
        final cabin = Path()
          ..moveTo(w * 0.28, h * 0.42)
          ..lineTo(w * 0.38, h * 0.22)
          ..lineTo(w * 0.62, h * 0.22)
          ..lineTo(w * 0.72, h * 0.42);
        canvas.drawPath(cabin, strokePaint);
        break;

      case AppIconType.shopping:
        // Cart
        final path = Path()
          ..moveTo(w * 0.15, h * 0.25)
          ..lineTo(w * 0.28, h * 0.25)
          ..lineTo(w * 0.42, h * 0.65)
          ..lineTo(w * 0.78, h * 0.65)
          ..lineTo(w * 0.85, h * 0.35)
          ..lineTo(w * 0.32, h * 0.35);
        canvas.drawPath(path, strokePaint);
        canvas.drawCircle(Offset(w * 0.44, h * 0.78), strokeWidth * 1.2, fillPaint);
        canvas.drawCircle(Offset(w * 0.74, h * 0.78), strokeWidth * 1.2, fillPaint);
        break;

      case AppIconType.shield:
        final path = Path()
          ..moveTo(w * 0.5, h * 0.15)
          ..lineTo(w * 0.82, h * 0.28)
          ..cubicTo(w * 0.82, h * 0.62, w * 0.5, h * 0.86, w * 0.5, h * 0.86)
          ..cubicTo(w * 0.5, h * 0.86, w * 0.18, h * 0.62, w * 0.18, h * 0.28)
          ..close();
        canvas.drawPath(path, strokePaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _AppIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
