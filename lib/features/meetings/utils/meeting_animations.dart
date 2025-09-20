// lib/features/meetings/utils/meeting_animations.dart

import 'package:flutter/material.dart';

/// 🎬 모임 기능을 위한 중앙집중식 애니메이션 유틸리티
///
/// 성능 최적화된 애니메이션 패턴으로 다음을 제공:
/// - 재사용 가능한 애니메이션 구성
/// - 메모리 효율적인 애니메이션 관리
/// - 일관된 애니메이션 UX
/// - 간소화된 API
class MeetingAnimations {
  // 🎯 성능 최적화된 표준 애니메이션 지속시간
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration standardDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);

  // ⚡ 성능 최적화된 Curves (GPU 친화적)
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;

  /// 🚀 표준 페이드 인 애니메이션
  static Animation<double> createFadeIn(
    AnimationController controller, {
    Duration? duration,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: fastOutSlowIn,
      ),
    );
  }

  /// 📱 표준 슬라이드 업 애니메이션
  static Animation<Offset> createSlideUp(
    AnimationController controller, {
    double begin = 0.3,
  }) {
    return Tween<Offset>(
      begin: Offset(0.0, begin),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: fastOutSlowIn,
      ),
    );
  }

  /// 🔄 표준 스케일 애니메이션
  static Animation<double> createScale(
    AnimationController controller, {
    double begin = 0.8,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: bounceOut,
      ),
    );
  }

  /// 🎊 성공 페이지용 스태거드 애니메이션 팩토리
  static List<Animation<double>> createSuccessAnimations(
    AnimationController controller,
  ) {
    return [
      // Scale animation (0-40%)
      Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.4, curve: bounceOut),
        ),
      ),
      // Fade animation (20-70%)
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.2, 0.7, curve: fastOutSlowIn),
        ),
      ),
      // Content slide (40-100%)
      Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.4, 1.0, curve: fastOutSlowIn),
        ),
      ),
    ];
  }
}

/// 🧩 재사용 가능한 애니메이션 믹스인
mixin MeetingAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _primaryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  /// 애니메이션 지속시간 (하위 클래스에서 오버라이드 가능)
  Duration get animationDuration => MeetingAnimations.standardDuration;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _primaryController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    _fadeAnimation = MeetingAnimations.createFadeIn(_primaryController);
    _slideAnimation = MeetingAnimations.createSlideUp(_primaryController);
    _scaleAnimation = MeetingAnimations.createScale(_primaryController);
  }

  void _startAnimations() {
    _primaryController.forward();
  }

  @override
  void dispose() {
    _primaryController.dispose();
    super.dispose();
  }

  // 보호된 접근자들
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;
  AnimationController get primaryController => _primaryController;
}

/// 🎨 애니메이션된 컨테이너 위젯 (성능 최적화됨)
class AnimatedMeetingCard extends StatelessWidget {
  final Widget child;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double>? scaleAnimation;

  const AnimatedMeetingCard({
    super.key,
    required this.child,
    required this.fadeAnimation,
    required this.slideAnimation,
    this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, _) {
        Widget result = FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );

        if (scaleAnimation != null) {
          result = ScaleTransition(
            scale: scaleAnimation!,
            child: result,
          );
        }

        return result;
      },
    );
  }
}
