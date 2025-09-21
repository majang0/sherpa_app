// lib/features/home/presentation/widgets/all_goals_reward_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Core
import '../../../../core/theme/modern_colors.dart';

// Shared Utils
import '../../../../shared/utils/haptic_feedback_manager.dart';

/// 모든 일일 목표 달성 보상 모달 위젯
/// 프론트엔드 디자인 전문가 관점에서 특별한 성취에 맞는 임팩트 있는 디자인
class AllGoalsRewardModal extends ConsumerStatefulWidget {
  final String userName;
  final VoidCallback onClose;
  final VoidCallback? onRewardClaimed;

  const AllGoalsRewardModal({
    super.key,
    required this.userName,
    required this.onClose,
    this.onRewardClaimed,
  });

  @override
  ConsumerState<AllGoalsRewardModal> createState() =>
      _AllGoalsRewardModalState();
}

class _AllGoalsRewardModalState extends ConsumerState<AllGoalsRewardModal>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러들
  late AnimationController _overlayController;
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _rewardController;

  // 애니메이션들
  late Animation<double> _overlayAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _rewardFadeAnimation;

  final List<_GoldParticle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateGoldParticles();
    _startSequentialAnimation();
  }

  void _setupAnimations() {
    // 배경 오버레이 애니메이션
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _overlayAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeOut),
    );

    // 메인 카드 애니메이션
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // 파티클 애니메이션
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    // 보상 배지 애니메이션 (지연 등장)
    _rewardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rewardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rewardController, curve: Curves.easeOut),
    );
  }

  void _startSequentialAnimation() async {
    // 1단계: 배경 오버레이
    _overlayController.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    // 2단계: 파티클 효과 시작
    _particleController.repeat();
    await Future.delayed(const Duration(milliseconds: 100));

    // 3단계: 메인 카드 등장
    _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // 4단계: 보상 배지들 등장
    _rewardController.forward();

    // 햅틱 피드백
    HapticFeedbackManager.heavyImpact();
  }

  void _generateGoldParticles() {
    _particles.clear();

    // 🎨 브랜드 컬러 기반 파티클들
    final brandColors = [
      ModernColors.modernPrimary,
      ModernColors.secondary,
      ModernColors.modernPrimary.withValues(alpha: 0.8),
      ModernColors.modernAccent, // 보라색 악센트
      const Color(0xFF3B82F6), // 블루 악센트
    ];

    // 🌟 적절한 개수로 조정 (너무 많으면 어지러움)
    for (int i = 0; i < 30; i++) {
      _particles.add(_GoldParticle(
        x: (_random.nextDouble() - 0.5) * 2.5,
        y: (_random.nextDouble() - 0.5) * 2.5,
        size: _random.nextDouble() * 5 + 2, // 크기 약간 줄임
        color: brandColors[_random.nextInt(brandColors.length)],
        velocity: _random.nextDouble() * 1.2 + 0.6, // 속도 약간 줄임
        angle: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 3, // 회전 속도 줄임
      ));
    }
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _mainController.dispose();
    _particleController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  void _closeModal() {
    // 역순으로 애니메이션 종료
    _rewardController.reverse();
    _particleController.stop();
    _mainController.reverse().then((_) {
      _overlayController.reverse().then((_) {
        widget.onClose();
      });
    });
  }

  // 보상 받기 기능은 더 이상 필요없음 - 이미 받았으므로

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 배경 오버레이
          AnimatedBuilder(
            animation: _overlayAnimation,
            builder: (context, child) {
              return GestureDetector(
                onTap: _closeModal,
                child: Container(
                  color: Colors.black.withValues(alpha: _overlayAnimation.value),
                ),
              );
            },
          ),

          // 황금 파티클 효과
          ..._buildGoldParticles(),

          // 메인 보상 카드
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_mainController, _rewardController]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: GestureDetector(
                        onTap: _closeModal, // 카드 클릭시에도 닫기
                        child: _buildRewardCard(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGoldParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleAnimation,
        builder: (context, child) {
          final progress = _particleAnimation.value;
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          final x =
              screenWidth / 2 + particle.x * 250 * progress * particle.velocity;
          final y = screenHeight / 2 +
              particle.y * 250 * progress * particle.velocity +
              (progress * progress * 150); // 중력 효과

          final opacity = math.max(0.0, 0.9 - progress);
          final rotation =
              particle.angle + progress * particle.rotationSpeed * math.pi;

          return Positioned(
            left: x,
            top: y,
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  color: particle.color.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: particle.color.withValues(alpha: opacity * 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildRewardCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        // 🎨 깔끔한 화이트 배경
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        // 🌟 은은한 단일 그림자로 깊이감 표현
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🏆 메인 트로피 아이콘
          _buildMainTrophy(),

          const SizedBox(height: 24),

          // 🎉 축하 메시지
          _buildCongratulationMessage(),

          const SizedBox(height: 32),

          // 🎁 보상 섹션
          FadeTransition(
            opacity: _rewardFadeAnimation,
            child: _buildRewardSection(),
          ),

          const SizedBox(height: 24),

          // 🎉 완료 안내 메시지
          FadeTransition(
            opacity: _rewardFadeAnimation,
            child: _buildCompletionMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTrophy() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        // 🎨 깔끔한 브랜드 컬러 배경
        color: ModernColors.modernPrimary,
        shape: BoxShape.circle,
        // 🌟 은은한 그림자로 깊이감만 표현
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Icon(
        Icons.emoji_events,
        color: Colors.white,
        size: 56,
        shadows: [
          Shadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCongratulationMessage() {
    return Column(
      children: [
        Text(
          '🎉 완벽한 성취! 🎉',
          style: GoogleFonts.notoSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: ModernColors.modernPrimary,
            shadows: [
              Shadow(
                color: ModernColors.modernPrimary.withValues(alpha: 0.15),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '${widget.userName}님!\n오늘의 모든 목표를 달성했어요!',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ModernColors.modernText,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRewardSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // 🎨 깔끔한 은은한 배경색
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernColors.modernPrimary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '획득한 보상',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.modernText,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRewardBadge(
                  '200XP', Icons.auto_awesome, ModernColors.modernPrimary),
              _buildRewardBadge(
                  '50P', Icons.monetization_on, ModernColors.modernPrimary),
              _buildFireRewardBadge('0.1 의지', '🔥'), // 불 이모지 사용
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // 🎨 단일 은은한 그림자로 깔끔하게
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 의지 전용 배지 (이모지 사용)
  Widget _buildFireRewardBadge(String text, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // 🎨 단일 은은한 그림자로 깔끔하게
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24), // 🔥 이모지
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF5722), // 불색 텍스트
            ),
          ),
        ],
      ),
    );
  }

  // 🎉 완료 안내 메시지 - 버튼 대신 깔끔한 마무리
  Widget _buildCompletionMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: ModernColors.modernPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.modernPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: ModernColors.modernPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '보상이 지급되었습니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.modernPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 황금 파티클 데이터 클래스
class _GoldParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double velocity;
  final double angle;
  final double rotationSpeed;

  _GoldParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
    required this.angle,
    required this.rotationSpeed,
  });
}
