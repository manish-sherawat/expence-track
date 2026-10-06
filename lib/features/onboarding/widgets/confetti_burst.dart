import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, required this.child});
  final Widget child;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    for (int i = 0; i < 45; i++) {
      _particles.add(_Particle(_random));
    }
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
        return CustomPaint(
          foregroundPainter: _ConfettiPainter(
            progress: _controller.value,
            particles: _particles,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _Particle {
  _Particle(math.Random random)
      : color = _colors[random.nextInt(_colors.length)],
        angle = random.nextDouble() * 2 * math.pi,
        velocity = 120 + random.nextDouble() * 260,
        size = 5 + random.nextDouble() * 5,
        rotation = random.nextDouble() * 4 * math.pi;

  static const _colors = [
    Color(0xFF2B7FFF),
    Color(0xFF00D26A),
    Color(0xFFFFB800),
    Color(0xFFFF4864),
    Color(0xFF8B5CF6),
  ];

  final Color color;
  final double angle;
  final double velocity;
  final double size;
  final double rotation;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.particles});
  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;
    final center = Offset(size.width / 2, size.height * 0.35);
    final paint = Paint()..style = PaintingStyle.fill;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final distance = p.velocity * progress;
      final x = center.dx + math.cos(p.angle) * distance;
      final y = center.dy + math.sin(p.angle) * distance + (progress * progress * 150);

      paint.color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation * progress);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
