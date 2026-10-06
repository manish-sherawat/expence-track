import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../../design_system/tokens/tokens.dart';

enum FunnyCharacterType {
  vault,
  coolCoin,
  smartBudget,
  curiousPiggy,
  partyCelebration,
}

/// A minimal, funny, and good-looking vector illustration widget built
/// entirely from scratch using Flutter CustomPainter.
/// Zero Material, zero Cupertino, zero external assets required.
class FunnyMinimalIllustration extends StatefulWidget {
  const FunnyMinimalIllustration({
    super.key,
    required this.type,
    this.size = 180,
  });

  final FunnyCharacterType type;
  final double size;

  @override
  State<FunnyMinimalIllustration> createState() => _FunnyMinimalIllustrationState();
}

class _FunnyMinimalIllustrationState extends State<FunnyMinimalIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isDark = theme.colors.isDark;
    if (theme.reduceMotion && _controller.isAnimating) {
      _controller.stop();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _FunnyIllustrationPainter(
            type: widget.type,
            progress: _controller.value,
            isDark: isDark,
            colors: theme.colors,
          ),
        );
      },
    );
  }
}

class _FunnyIllustrationPainter extends CustomPainter {
  _FunnyIllustrationPainter({
    required this.type,
    required this.progress,
    required this.isDark,
    required this.colors,
  });

  final FunnyCharacterType type;
  final double progress;
  final bool isDark;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case FunnyCharacterType.vault:
        _paintFunnyVault(canvas, size);
        break;
      case FunnyCharacterType.coolCoin:
        _paintCoolCoin(canvas, size);
        break;
      case FunnyCharacterType.smartBudget:
        _paintSmartBudget(canvas, size);
        break;
      case FunnyCharacterType.curiousPiggy:
        _paintCuriousPiggy(canvas, size);
        break;
      case FunnyCharacterType.partyCelebration:
        _paintPartyCelebration(canvas, size);
        break;
    }
  }

  /// 1. Funny Vault: A cute little safe with big expressive eyes, a dial nose,
  /// and a coin balancing like a stylish beret.
  void _paintFunnyVault(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bob = math.sin(progress * math.pi) * 4;

    // Soft ground shadow
    final shadowPaint = Paint()
      ..color = (isDark ? const Color(0xFF000000) : const Color(0xFF94A3B8)).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 54), width: 90 + bob * 2, height: 16),
      shadowPaint,
    );

    // Vault Body (squircle)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + bob), width: 96, height: 90),
      const Radius.circular(24),
    );
    final bodyPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2430) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bodyRect, bodyPaint);

    final borderPaint = Paint()
      ..color = colors.accent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(bodyRect, borderPaint);

    // Little Coin Beret (tilted playfully on head)
    canvas.save();
    canvas.translate(cx + 24, cy - 42 + bob);
    canvas.rotate(0.35 + math.sin(progress * math.pi) * 0.08);
    final coinPaint = Paint()..color = const Color(0xFFFFC107);
    canvas.drawCircle(Offset.zero, 16, coinPaint);
    final coinRim = Paint()
      ..color = const Color(0xFFFFA000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset.zero, 16, coinRim);
    // Coin shine dot
    final shinePaint = Paint()..color = const Color(0xFFFFF9C4);
    canvas.drawCircle(const Offset(-5, -5), 3.5, shinePaint);
    canvas.restore();

    // Vault Door Inner Circle
    final doorPaint = Paint()
      ..color = isDark ? const Color(0xFF131822) : const Color(0xFFF1F5F9);
    canvas.drawCircle(Offset(cx, cy + bob), 32, doorPaint);

    // Big Cute Eyes
    final eyeWhite = Paint()..color = const Color(0xFFFFFFFF);
    final eyePupil = Paint()..color = const Color(0xFF0F172A);
    final eyeGlint = Paint()..color = const Color(0xFFFFFFFF);

    // Left eye (winks occasionally when progress > 0.8)
    final isWinking = progress > 0.82;
    if (isWinking) {
      final winkPaint = Paint()
        ..color = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3;
      final winkPath = Path()
        ..moveTo(cx - 20, cy + bob - 6)
        ..quadraticBezierTo(cx - 14, cy + bob - 12, cx - 8, cy + bob - 6);
      canvas.drawPath(winkPath, winkPaint);
    } else {
      canvas.drawCircle(Offset(cx - 14, cy + bob - 6), 7, eyeWhite);
      canvas.drawCircle(Offset(cx - 13, cy + bob - 6), 4.5, eyePupil);
      canvas.drawCircle(Offset(cx - 15, cy + bob - 8), 2, eyeGlint);
    }

    // Right eye (big happy anime spark)
    canvas.drawCircle(Offset(cx + 14, cy + bob - 6), 7, eyeWhite);
    canvas.drawCircle(Offset(cx + 15, cy + bob - 6), 4.5, eyePupil);
    canvas.drawCircle(Offset(cx + 13, cy + bob - 8), 2, eyeGlint);

    // Cute Cheeks (blush)
    final blushPaint = Paint()..color = const Color(0xFFFF5252).withValues(alpha: 0.35);
    canvas.drawCircle(Offset(cx - 22, cy + bob + 4), 5, blushPaint);
    canvas.drawCircle(Offset(cx + 22, cy + bob + 4), 5, blushPaint);

    // Safe Dial "Nose" & Smile
    final dialPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy + bob + 10), 6, dialPaint);

    // Happy little mouth
    final mouthPaint = Paint()
      ..color = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;
    final mouthPath = Path()
      ..moveTo(cx - 6, cy + bob + 20)
      ..quadraticBezierTo(cx, cy + bob + 26, cx + 6, cy + bob + 20);
    canvas.drawPath(mouthPath, mouthPaint);

    // Tiny Stubby Legs
    final legPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2430) : const Color(0xFFCBD5E1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 24, cy + 46 + bob), width: 14, height: 10),
        const Radius.circular(5),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 24, cy + 46 + bob), width: 14, height: 10),
        const Radius.circular(5),
      ),
      legPaint,
    );
  }

  /// 2. Cool Coin: A minimal gold coin wearing stylish dark sunglasses,
  /// giving a thumbs up or smiling proudly!
  void _paintCoolCoin(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final floatY = math.sin(progress * math.pi) * 6;

    // Ground Shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 54), width: 70 - floatY, height: 14),
      shadowPaint,
    );

    // Golden Coin Body
    final coinPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawCircle(Offset(cx, cy + floatY), 46, coinPaint);

    // Inner rim
    final rimPaint = Paint()
      ..color = const Color(0xFFFF8F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(cx, cy + floatY), 40, rimPaint);

    // Sparkle star on top-left of coin
    _drawSparkle(canvas, Offset(cx - 32, cy - 28 + floatY), 7, const Color(0xFFFFF9C4));

    // Cool Black Sunglasses (classic pixel/wayfarer minimal shape)
    final glassesPaint = Paint()..color = const Color(0xFF0A0E17);
    // Left lens
    final leftLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 18, cy - 6 + floatY), width: 28, height: 18),
      const Radius.circular(5),
    );
    // Right lens
    final rightLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 18, cy - 6 + floatY), width: 28, height: 18),
      const Radius.circular(5),
    );
    canvas.drawRRect(leftLens, glassesPaint);
    canvas.drawRRect(rightLens, glassesPaint);

    // Sunglasses bridge
    final bridgePaint = Paint()
      ..color = const Color(0xFF0A0E17)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx - 6, cy - 8 + floatY),
      Offset(cx + 6, cy - 8 + floatY),
      bridgePaint,
    );

    // Sunglasses white lens glare reflections (slanted lines)
    final glarePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 24, cy - 12 + floatY),
      Offset(cx - 16, cy + floatY),
      glarePaint,
    );
    canvas.drawLine(
      Offset(cx + 12, cy - 12 + floatY),
      Offset(cx + 20, cy + floatY),
      glarePaint,
    );

    // Confident Smirk Mouth
    final smirkPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    final smirkPath = Path()
      ..moveTo(cx - 10, cy + 16 + floatY)
      ..quadraticBezierTo(cx + 6, cy + 24 + floatY, cx + 16, cy + 12 + floatY);
    canvas.drawPath(smirkPath, smirkPaint);
  }

  /// 3. Smart Budget: A clean minimal calculator/dashboard pad with a friendly smile,
  /// happily showing a green arrow going up!
  void _paintSmartBudget(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final tilt = math.sin(progress * math.pi) * 0.05;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(tilt);

    // Pad body
    final padRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 88, height: 104),
      const Radius.circular(20),
    );
    final padPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2638) : const Color(0xFFF8FAFC);
    canvas.drawRRect(padRect, padPaint);

    final padBorder = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(padRect, padBorder);

    // Pad Screen / Eyes area
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -22), width: 70, height: 36),
      const Radius.circular(12),
    );
    final screenPaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0);
    canvas.drawRRect(screenRect, screenPaint);

    // Cute Eyes in the screen
    final eyePaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(const Offset(-14, -22), 5, eyePaint);
    canvas.drawCircle(const Offset(14, -22), 5, eyePaint);

    // Happy open mouth
    final mouthPaint = Paint()
      ..color = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final mouthPath = Path()
      ..arcTo(
        Rect.fromCenter(center: const Offset(0, 4), width: 16, height: 12),
        0,
        math.pi,
        true,
      );
    canvas.drawPath(mouthPath, mouthPaint);

    // Glowing green upward trend arrow on bottom
    final arrowPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;
    final arrowPath = Path()
      ..moveTo(-22, 28)
      ..lineTo(-8, 20)
      ..lineTo(6, 26)
      ..lineTo(22, 14);
    canvas.drawPath(arrowPath, arrowPaint);

    // Arrow tip
    final tipPath = Path()
      ..moveTo(14, 14)
      ..lineTo(22, 14)
      ..lineTo(22, 22);
    canvas.drawPath(tipPath, arrowPaint);

    canvas.restore();
  }

  /// 4. Curious Piggy: Minimal cute pink piggy bank with round eyes.
  void _paintCuriousPiggy(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final wobbly = math.sin(progress * math.pi) * 3;

    // Body
    final piggyBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + wobbly), width: 92, height: 76),
      const Radius.circular(32),
    );
    final bodyPaint = Paint()..color = const Color(0xFFFF80AB);
    canvas.drawRRect(piggyBody, bodyPaint);

    // Coin slot on top
    final slotPaint = Paint()
      ..color = const Color(0xFFC51162)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 12, cy - 38 + wobbly), Offset(cx + 12, cy - 38 + wobbly), slotPaint);

    // Golden coin entering slot
    final coinPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 48 + wobbly * 1.5), width: 20, height: 10),
      coinPaint,
    );

    // Snout
    final snout = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 26, cy + 4 + wobbly), width: 24, height: 18),
      const Radius.circular(8),
    );
    final snoutPaint = Paint()..color = const Color(0xFFFF4081);
    canvas.drawRRect(snout, snoutPaint);
    // Nostrils
    final nostrilPaint = Paint()..color = const Color(0xFF880E4F);
    canvas.drawCircle(Offset(cx + 22, cy + 4 + wobbly), 2.5, nostrilPaint);
    canvas.drawCircle(Offset(cx + 30, cy + 4 + wobbly), 2.5, nostrilPaint);

    // Big curious eyes
    final eyePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawCircle(Offset(cx - 2, cy - 6 + wobbly), 5.5, eyePaint);
    final glint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(cx - 4, cy - 8 + wobbly), 2, glint);

    // Tiny ear
    final earPath = Path()
      ..moveTo(cx - 18, cy - 36 + wobbly)
      ..lineTo(cx - 26, cy - 50 + wobbly)
      ..lineTo(cx - 6, cy - 36 + wobbly)
      ..close();
    canvas.drawPath(earPath, Paint()..color = const Color(0xFFFF4081));
  }

  /// 5. Party Celebration: Cute vault character wearing a party cone hat,
  /// happily smiling with confetti floating around.
  void _paintPartyCelebration(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final jump = -math.sin(progress * math.pi) * 8;

    // First paint base vault character
    _paintFunnyVault(canvas, size);

    // Party Cone Hat
    final hatPath = Path()
      ..moveTo(cx - 18, cy - 42 + jump)
      ..lineTo(cx, cy - 76 + jump)
      ..lineTo(cx + 18, cy - 42 + jump)
      ..close();
    final hatPaint = Paint()..color = const Color(0xFFFF3D00);
    canvas.drawPath(hatPath, hatPaint);

    // Hat stripes
    final stripePaint = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(Offset(cx - 9, cy - 54 + jump), Offset(cx + 9, cy - 54 + jump), stripePaint);
    canvas.drawLine(Offset(cx - 5, cy - 64 + jump), Offset(cx + 5, cy - 64 + jump), stripePaint);

    // Hat pom-pom on top
    canvas.drawCircle(Offset(cx, cy - 78 + jump), 4.5, Paint()..color = const Color(0xFFFFEB3B));

    // Floating party sparkles
    _drawSparkle(canvas, Offset(cx - 48, cy - 30 + jump), 6, const Color(0xFFFFD600));
    _drawSparkle(canvas, Offset(cx + 48, cy - 35 + jump), 7, const Color(0xFF00E676));
    _drawSparkle(canvas, Offset(cx - 40, cy + 20 + jump), 5, const Color(0xFF2979FF));
    _drawSparkle(canvas, Offset(cx + 42, cy + 18 + jump), 6, const Color(0xFFFF1744));
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FunnyIllustrationPainter oldDelegate) => true;
}
