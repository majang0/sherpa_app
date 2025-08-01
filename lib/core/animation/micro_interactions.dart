// lib/core/animation/micro_interactions.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors_2025.dart';

/// 2025 마이크로 인터랙션 애니메이션 시스템
/// 사용자와의 감정적 연결을 위한 정교한 애니메이션 패턴
class MicroInteractions {
  
  // ==================== 애니메이션 지속시간 상수 ====================
  
  static const Duration ultraFast = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);

  // ==================== 이징 커브 ====================
  
  static const Curve easeOutQuart = Cubic(0.25, 1, 0.5, 1);
  static const Curve easeInOutCubic = Cubic(0.65, 0, 0.35, 1);
  static const Curve bounceOut = Cubic(0.68, -0.55, 0.265, 1.55);
  static const Curve softBounce = Cubic(0.34, 1.56, 0.64, 1);
  static const Curve easeOutBack = Cubic(0.34, 1.56, 0.64, 1);
  static const Curve easeInOutSine = Cubic(0.37, 0, 0.63, 1);
  static const Curve elasticOut = Cubic(0.7, -0.4, 0.4, 1.4);

  // ==================== 기본 애니메이션 빌더들 ====================

  /// 탭 반응 애니메이션 (스케일 + 그림자)
  static Widget tapResponse({
    required Widget child,
    VoidCallback? onTap,
    double scaleDownTo = 0.95,
    Duration duration = fast,
    bool enableHaptic = true,
    HapticFeedbackType hapticType = HapticFeedbackType.light,
  }) {
    return TapResponseWidget(
      onTap: onTap,
      scaleDownTo: scaleDownTo,
      duration: duration,
      enableHaptic: enableHaptic,
      hapticType: hapticType,
      child: child,
    );
  }

  /// 호버 효과 애니메이션 (엘리베이션 + 스케일)
  static Widget hoverEffect({
    required Widget child,
    double scaleUpTo = 1.02,
    double elevationIncrease = 4,
    Duration duration = normal,
    Curve curve = easeOutQuart,
  }) {
    return HoverEffectWidget(
      scaleUpTo: scaleUpTo,
      elevationIncrease: elevationIncrease,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 로딩 펄스 애니메이션
  static Widget loadingPulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1200),
    double minOpacity = 0.6,
    double maxOpacity = 1.0,
  }) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(
          duration: duration,
          begin: minOpacity,
          end: maxOpacity,
          curve: Curves.easeInOut,
        );
  }

  /// 성공 체크마크 애니메이션
  static Widget successCheckmark({
    double size = 24,
    Color color = Colors.green,
    Duration duration = medium,
  }) {
    return SuccessCheckmarkWidget(
      size: size,
      color: color,
      duration: duration,
    );
  }

  /// 오류 X 마크 애니메이션
  static Widget errorXMark({
    double size = 24,
    Color color = Colors.red,
    Duration duration = medium,
  }) {
    return ErrorXMarkWidget(
      size: size,
      color: color,
      duration: duration,
    );
  }

  /// 진입 애니메이션 (슬라이드 + 페이드)
  static Widget slideInFade({
    required Widget child,
    SlideDirection direction = SlideDirection.bottom,
    Duration duration = medium,
    Curve curve = easeOutQuart,
    double distance = 20,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.top:
        begin = Offset(0, -distance);
        break;
      case SlideDirection.bottom:
        begin = Offset(0, distance);
        break;
      case SlideDirection.left:
        begin = Offset(-distance, 0);
        break;
      case SlideDirection.right:
        begin = Offset(distance, 0);
        break;
    }

    return child
        .animate()
        .slideX(
          begin: begin.dx / 100,
          duration: duration,
          curve: curve,
        )
        .slideY(
          begin: begin.dy / 100,
          duration: duration,
          curve: curve,
        )
        .fade(
          duration: duration,
          curve: curve,
        );
  }

  /// 스케일 바운스 애니메이션
  static Widget scaleBounce({
    required Widget child,
    Duration duration = medium,
    double bounceTo = 1.1,
    bool autoPlay = true,
  }) {
    return child
        .animate(
          autoPlay: autoPlay,
          onComplete: (controller) => controller.reset(),
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: Offset(bounceTo, bounceTo),
          duration: duration * 0.6,
          curve: bounceOut,
        )
        .then()
        .scale(
          begin: Offset(bounceTo, bounceTo),
          end: const Offset(1.0, 1.0),
          duration: duration * 0.4,
          curve: easeInOutCubic,
        );
  }

  /// 셰이크 애니메이션 (오류 피드백용)
  static Widget shake({
    required Widget child,
    double intensity = 5,
    Duration duration = const Duration(milliseconds: 600),
    bool autoPlay = true,
  }) {
    return child
        .animate(autoPlay: autoPlay)
        .shakeX(
          duration: duration,
          amount: intensity,
          curve: Curves.elasticIn,
        );
  }

  /// 플립 애니메이션 (상태 전환용)
  static Widget flip({
    required Widget child,
    Duration duration = medium,
    Axis direction = Axis.horizontal,
    bool autoPlay = false,
  }) {
    return child
        .animate(autoPlay: autoPlay)
        .flip(
          duration: duration,
          direction: direction,
          curve: easeInOutCubic,
        );
  }

  // ==================== 복합 애니메이션 패턴 ====================

  /// 카드 등장 애니메이션 (스케일 + 페이드 + 슬라이드)
  static Widget cardEntrance({
    required Widget child,
    Duration duration = medium,
    double delay = 0,
  }) {
    return child
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: duration,
          curve: bounceOut,
          delay: Duration(milliseconds: (delay * 1000).round()),
        )
        .fade(
          duration: duration,
          curve: easeOutQuart,
        )
        .animate(
          delay: Duration(milliseconds: (delay * 1000).round()),
        )
        .slideY(
          begin: 0.1,
          duration: duration,
          curve: easeOutQuart,
          delay: Duration(milliseconds: (delay * 1000).round()),
        );
  }

  /// 버튼 프레스 애니메이션 (스케일 + 글로우)
  static Widget buttonPress({
    required Widget child,
    VoidCallback? onPressed,
    Color? glowColor,
    bool isPressed = false,
  }) {
    return ButtonPressWidget(
      onPressed: onPressed,
      glowColor: glowColor ?? AppColors2025.primary,
      isPressed: isPressed,
      child: child,
    );
  }

  /// 리스트 아이템 스태거 애니메이션
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration duration = normal,
    Duration staggerDelay = const Duration(milliseconds: 50),
    SlideDirection direction = SlideDirection.bottom,
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      
      return slideInFade(
        child: child,
        direction: direction,
        duration: duration,
      ).animate(
        delay: staggerDelay * index,
      );
    }).toList();
  }

  // ==================== 특수 효과 ====================

  /// 파티클 버스트 효과
  static Widget particleBurst({
    required Widget child,
    VoidCallback? onTrigger,
    Color particleColor = Colors.blue,
    int particleCount = 12,
  }) {
    return ParticleBurstWidget(
      onTrigger: onTrigger,
      particleColor: particleColor,
      particleCount: particleCount,
      child: child,
    );
  }

  /// 리플 효과 (Material Design 스타일)
  static Widget rippleEffect({
    required Widget child,
    VoidCallback? onTap,
    Color? rippleColor,
    BorderRadius? borderRadius,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: rippleColor ?? AppColors2025.primary.withOpacity(0.1),
        highlightColor: rippleColor ?? AppColors2025.primary.withOpacity(0.05),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  /// 모달 등장/퇴장 애니메이션
  static Widget modalTransition({
    required Widget child,
    bool isVisible = true,
    Duration duration = medium,
  }) {
    return AnimatedScale(
      scale: isVisible ? 1.0 : 0.8,
      duration: duration,
      curve: bounceOut,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: duration,
        curve: easeOutQuart,
        child: child,
      ),
    );
  }
}

// ==================== 열거형 정의 ====================

enum SlideDirection { top, bottom, left, right }
enum HapticFeedbackType { 
  light,
  medium,
  heavy,
  selection;
}

/// 햅틱 피드백 트리거 헬퍼 함수
void _triggerHapticFeedback(HapticFeedbackType type) {
  switch (type) {
    case HapticFeedbackType.light:
      HapticFeedback.lightImpact();
      break;
    case HapticFeedbackType.medium:
      HapticFeedback.mediumImpact();
      break;
    case HapticFeedbackType.heavy:
      HapticFeedback.heavyImpact();
      break;
    case HapticFeedbackType.selection:
      HapticFeedback.selectionClick();
      break;
  }
}

// ==================== 커스텀 위젯들 ====================

/// 탭 반응 위젯
class TapResponseWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDownTo;
  final Duration duration;
  final bool enableHaptic;
  final HapticFeedbackType hapticType;

  const TapResponseWidget({
    Key? key,
    required this.child,
    this.onTap,
    this.scaleDownTo = 0.95,
    this.duration = MicroInteractions.fast,
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
  }) : super(key: key);

  @override
  State<TapResponseWidget> createState() => _TapResponseWidgetState();
}

class _TapResponseWidgetState extends State<TapResponseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDownTo,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MicroInteractions.easeOutQuart,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        if (widget.enableHaptic) {
          _triggerHapticFeedback(widget.hapticType);
        }
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 호버 효과 위젯
class HoverEffectWidget extends StatefulWidget {
  final Widget child;
  final double scaleUpTo;
  final double elevationIncrease;
  final Duration duration;
  final Curve curve;

  const HoverEffectWidget({
    Key? key,
    required this.child,
    this.scaleUpTo = 1.02,
    this.elevationIncrease = 4,
    this.duration = MicroInteractions.normal,
    this.curve = MicroInteractions.easeOutQuart,
  }) : super(key: key);

  @override
  State<HoverEffectWidget> createState() => _HoverEffectWidgetState();
}

class _HoverEffectWidgetState extends State<HoverEffectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleUpTo,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: widget.duration,
              decoration: BoxDecoration(
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors2025.shadowMedium,
                          blurRadius: 8 + widget.elevationIncrease,
                          offset: Offset(0, 4 + widget.elevationIncrease / 2),
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 성공 체크마크 위젯
class SuccessCheckmarkWidget extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const SuccessCheckmarkWidget({
    Key? key,
    this.size = 24,
    this.color = Colors.green,
    this.duration = MicroInteractions.medium,
  }) : super(key: key);

  @override
  State<SuccessCheckmarkWidget> createState() => _SuccessCheckmarkWidgetState();
}

class _SuccessCheckmarkWidgetState extends State<SuccessCheckmarkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MicroInteractions.bounceOut,
    ));
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _checkAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: CheckmarkPainter(
            progress: _checkAnimation.value,
            color: widget.color,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 오류 X 마크 위젯
class ErrorXMarkWidget extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const ErrorXMarkWidget({
    Key? key,
    this.size = 24,
    this.color = Colors.red,
    this.duration = MicroInteractions.medium,
  }) : super(key: key);

  @override
  State<ErrorXMarkWidget> createState() => _ErrorXMarkWidgetState();
}

class _ErrorXMarkWidgetState extends State<ErrorXMarkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _xAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MicroInteractions.easeOutQuart,
    ));
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _xAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: XMarkPainter(
            progress: _xAnimation.value,
            color: widget.color,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 버튼 프레스 위젯
class ButtonPressWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color glowColor;
  final bool isPressed;

  const ButtonPressWidget({
    Key? key,
    required this.child,
    this.onPressed,
    required this.glowColor,
    this.isPressed = false,
  }) : super(key: key);

  @override
  State<ButtonPressWidget> createState() => _ButtonPressWidgetState();
}

class _ButtonPressWidgetState extends State<ButtonPressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MicroInteractions.easeOutQuart,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: widget.glowColor.withOpacity(0.3 * _glowAnimation.value),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                    ]
                  : null,
            ),
            child: Transform.scale(
              scale: _isPressed ? 0.98 : 1.0,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 파티클 버스트 위젯
class ParticleBurstWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTrigger;
  final Color particleColor;
  final int particleCount;

  const ParticleBurstWidget({
    Key? key,
    required this.child,
    this.onTrigger,
    this.particleColor = Colors.blue,
    this.particleCount = 12,
  }) : super(key: key);

  @override
  State<ParticleBurstWidget> createState() => _ParticleBurstWidgetState();
}

class _ParticleBurstWidgetState extends State<ParticleBurstWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showParticles = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _triggerBurst() {
    setState(() => _showParticles = true);
    _controller.forward().then((_) {
      setState(() => _showParticles = false);
      _controller.reset();
    });
    widget.onTrigger?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerBurst,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_showParticles)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(100, 100),
                  painter: ParticleBurstPainter(
                    progress: _controller.value,
                    particleColor: widget.particleColor,
                    particleCount: widget.particleCount,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ==================== 커스텀 페인터들 ====================

/// 체크마크 페인터
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final checkSize = size.width * 0.6;
    
    // 체크마크 경로 정의
    final start = Offset(center.dx - checkSize * 0.3, center.dy);
    final middle = Offset(center.dx - checkSize * 0.1, center.dy + checkSize * 0.2);
    final end = Offset(center.dx + checkSize * 0.3, center.dy - checkSize * 0.2);

    if (progress <= 0.5) {
      // 첫 번째 라인 (왼쪽에서 중간까지)
      final t = progress * 2;
      path.moveTo(start.dx, start.dy);
      path.lineTo(
        start.dx + (middle.dx - start.dx) * t,
        start.dy + (middle.dy - start.dy) * t,
      );
    } else {
      // 첫 번째 라인 완성 후 두 번째 라인
      path.moveTo(start.dx, start.dy);
      path.lineTo(middle.dx, middle.dy);
      
      final t = (progress - 0.5) * 2;
      path.lineTo(
        middle.dx + (end.dx - middle.dx) * t,
        middle.dy + (end.dy - middle.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// X 마크 페인터
class XMarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  XMarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final xSize = size.width * 0.6;
    
    if (progress <= 0.5) {
      // 첫 번째 라인 (왼쪽 위에서 오른쪽 아래)
      final t = progress * 2;
      final start = Offset(center.dx - xSize * 0.3, center.dy - xSize * 0.3);
      final end = Offset(center.dx + xSize * 0.3, center.dy + xSize * 0.3);
      
      canvas.drawLine(
        start,
        Offset(
          start.dx + (end.dx - start.dx) * t,
          start.dy + (end.dy - start.dy) * t,
        ),
        paint,
      );
    } else {
      // 첫 번째 라인 완성 후 두 번째 라인
      canvas.drawLine(
        Offset(center.dx - xSize * 0.3, center.dy - xSize * 0.3),
        Offset(center.dx + xSize * 0.3, center.dy + xSize * 0.3),
        paint,
      );
      
      final t = (progress - 0.5) * 2;
      final start = Offset(center.dx + xSize * 0.3, center.dy - xSize * 0.3);
      final end = Offset(center.dx - xSize * 0.3, center.dy + xSize * 0.3);
      
      canvas.drawLine(
        start,
        Offset(
          start.dx + (end.dx - start.dx) * t,
          start.dy + (end.dy - start.dy) * t,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(XMarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// 파티클 버스트 페인터
class ParticleBurstPainter extends CustomPainter {
  final double progress;
  final Color particleColor;
  final int particleCount;

  ParticleBurstPainter({
    required this.progress,
    required this.particleColor,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = particleColor;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * 3.14159;
      final distance = maxRadius * progress;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      
      final particleX = center.dx + distance * 0.7 * progress * progress;
      final particleY = center.dy + distance * 0.7 * progress * progress;
      
      paint.color = particleColor.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(
          center.dx + distance * progress * progress,
          center.dy + distance * progress * progress,
        ),
        3 * (1 - progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}