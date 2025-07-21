import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🎊 성공 컨페티 애니메이션 위젯
class SuccessConfettiWidget extends StatelessWidget {
  final AnimationController controller;
  final List<Color> colors;

  const SuccessConfettiWidget({
    super.key,
    required this.controller,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            animation: controller,
            colors: colors,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;
  final List<ConfettiParticle> particles;

  ConfettiPainter({
    required this.animation,
    required this.colors,
  }) : particles = List.generate(50, (index) => ConfettiParticle(colors));

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(animation.value, size);
      particle.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ConfettiParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double rotation;
  late double rotationSpeed;
  late Color color;
  late double size;
  late double opacity;

  ConfettiParticle(List<Color> colors) {
    reset(colors);
  }

  void reset(List<Color> colors) {
    x = math.Random().nextDouble();
    y = -0.1;
    vx = (math.Random().nextDouble() - 0.5) * 0.02;
    vy = math.Random().nextDouble() * 0.02 + 0.01;
    rotation = math.Random().nextDouble() * math.pi * 2;
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.2;
    color = colors[math.Random().nextInt(colors.length)];
    size = math.Random().nextDouble() * 8 + 4;
    opacity = math.Random().nextDouble() * 0.8 + 0.2;
  }

  void update(double time, Size size) {
    if (y > 1.2) {
      reset([color]); // 같은 색상으로 리셋
    }
    
    x += vx;
    y += vy;
    rotation += rotationSpeed;
    
    // 좌우 경계 처리
    if (x < -0.1 || x > 1.1) {
      vx *= -1;
    }
  }

  void paint(Canvas canvas) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(x * 400, y * 800); // 화면 크기에 맞게 조정
    canvas.rotate(rotation);
    
    // 다양한 모양의 컨페티
    final random = math.Random().nextInt(3);
    switch (random) {
      case 0: // 원형
        canvas.drawCircle(Offset.zero, size / 2, paint);
        break;
      case 1: // 사각형
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: size, height: size),
          paint,
        );
        break;
      case 2: // 삼각형
        final path = Path();
        path.moveTo(0, -size / 2);
        path.lineTo(-size / 2, size / 2);
        path.lineTo(size / 2, size / 2);
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
    
    canvas.restore();
  }
}
