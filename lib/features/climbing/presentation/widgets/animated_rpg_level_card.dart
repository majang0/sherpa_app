// lib/features/home/presentation/widgets/animated_rpg_level_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../core/constants/sherpi_emotions.dart';
import '../../../../core/constants/game_constants.dart';

// Shared Providers
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/providers/global_game_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_badge_provider.dart';

// Shared Widgets
import '../../../../shared/widgets/sherpa_card.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

class AnimatedRPGLevelCard extends ConsumerStatefulWidget {
  const AnimatedRPGLevelCard({Key? key}) : super(key: key);

  @override
  ConsumerState<AnimatedRPGLevelCard> createState() => _AnimatedRPGLevelCardState();
}

class _AnimatedRPGLevelCardState extends ConsumerState<AnimatedRPGLevelCard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _sherpiController;
  late AnimationController _progressController;
  late AnimationController _levelPulseController;
  late AnimationController _mountainFloatController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _sherpiAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _levelPulseAnimation;
  late Animation<double> _mountainFloatAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _sherpiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _levelPulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _mountainFloatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _sherpiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sherpiController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _levelPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _levelPulseController,
      curve: Curves.easeInOut,
    ));

    _mountainFloatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mountainFloatController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _progressController.forward();
    _sherpiController.repeat(reverse: true);
    _levelPulseController.repeat(reverse: true);
    _mountainFloatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _sherpiController.dispose();
    _progressController.dispose();
    _levelPulseController.dispose();
    _mountainFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final progress = ref.watch(userLevelProgressProvider);
    final title = ref.watch(globalUserTitleProvider);
    final userPower = ref.watch(userClimbingPowerProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            // 깔끔한 단색 배경에 미세한 등반 테마 추가
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // 주요 그림자
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              // 미세한 내부 그림자 효과
              BoxShadow(
                color: AppColors.textLight.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 상단 액센트 - 산 실루엣 느낌
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: CustomPaint(
                    painter: MountainSilhouettePainter(
                      color: AppColors.primary.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
              // 메인 콘텐츠
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMainContent(user, title, progress),
                  _buildDivider(),
                  _buildClimbingStatsSection(user, userPower),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(dynamic user, dynamic title, dynamic progress) {
    final displayProgress = progress.progress;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 레벨 & 진행 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 레벨 & 칭호 섹션
                Row(
                  children: [
                    // 레벨 원형 뱃지 - 산 느낌 추가
                    AnimatedBuilder(
                      animation: _levelPulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _levelPulseAnimation.value,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 산 아이콘 배경
                                Icon(
                                  Icons.terrain,
                                  color: Colors.white.withOpacity(0.2),
                                  size: 28,
                                ),
                                // 레벨 숫자
                                Text(
                                  '${user.level}',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 칭호 태그 - 등반 테마
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title.icon,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  title.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 경험치 진행바 섹션
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '다음 정상까지',
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${progress.currentLevelExp} / ${progress.requiredExpForNextLevel} XP',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 등반 진행바
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.dividerLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              widthFactor: displayProgress * _progressAnimation.value,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryLight,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress.progress * 100).toInt()}% 등반 완료',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        if (progress.progress > 0.8)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🏔️ 정상이 눈앞에!',
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // 오른쪽: 셰르피 등반 가이드 카드
          _buildClimbingSherpiCard(progress.progress),
        ],
      ),
    );
  }

  Widget _buildClimbingSherpiCard(double progress) {
    return AnimatedBuilder(
      animation: _sherpiAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // 셰르피 메시지 제거 - 등반 성공시에만 메시지 표시
            HapticFeedbackManager.lightImpact();
          },
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.primaryLight.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 등반 가이드 셰르피
                Transform.translate(
                  offset: Offset(0, math.sin(_sherpiAnimation.value * math.pi * 2) * 2),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 산 배경
                        AnimatedBuilder(
                          animation: _mountainFloatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -2 + _mountainFloatAnimation.value * 2),
                              child: Icon(
                                Icons.terrain,
                                color: AppColors.primary.withOpacity(0.2),
                                size: 35,
                              ),
                            );
                          },
                        ),
                        // 셰르피 이미지
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Transform.scale(
                            scale: 2,
                            child: Image.asset(
                              SherpiEmotion.guiding.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getClimbingMessage(progress),
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.divider.withOpacity(0),
            AppColors.divider,
            AppColors.divider.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildClimbingStatsSection(dynamic user, double userPower) {
    final equippedBadges = ref.watch(globalEquippedBadgesProvider);
    final gameSystem = ref.watch(globalGameProvider);

    // GameConstants를 사용한 정확한 계산

    // 1. 등반력 보너스 계산 (뱃지 효과만)
    double powerBonus = 0;
    for (final badge in equippedBadges) {
      if (badge.effectType == 'CLIMBING_POWER_MULTIPLY') {
        powerBonus += badge.effectValue;
      }
    }

    // 2. 시간 단축 계산
    // 사교성에 의한 시간 단축 (1%당 0.2% 감소)
    double socialityTimeReduction = user.stats.sociality * 0.2; // 1%당 0.2%
    socialityTimeReduction = math.min(socialityTimeReduction, 10.0); // 최대 10%

    // 뱃지에 의한 시간 단축
    double badgeTimeReduction = 0;
    for (final badge in equippedBadges) {
      // badge_management_widget에서 사용하는 타입 참고
      if (badge.effectType == 'climbing_time_reduction' ||
          badge.effectType == 'CLIMBING_TIME_REDUCE' ||
          badge.effectType == 'TIME_REDUCE' ||
          badge.effectType == 'time_reduce') {
        badgeTimeReduction += badge.effectValue;
      }
    }

    double totalTimeReduction = socialityTimeReduction + badgeTimeReduction;
    totalTimeReduction = math.min(totalTimeReduction, 30.0); // 최대 30% 제한

    // 3. 성공률 증가 계산
    // 의지 보정치: (의지 × 0.1)
    double willpowerBonus = user.stats.willpower * 0.1; // 의지 1당 0.1% 증가

    // 뱃지 성공률 보너스 (badge_management_widget의 타입 참고)
    double badgeSuccessBonus = 0;
    for (final badge in equippedBadges) {
      // 다양한 형태의 성공률 효과 타입 체크
      if (badge.effectType == 'success_rate' ||
          badge.effectType == 'success_rate_bonus' ||
          badge.effectType == 'SUCCESS_RATE' ||
          badge.effectType == 'CLIMBING_SUCCESS_RATE' ||
          badge.effectType == 'SUCCESS_BONUS' ||
          badge.effectType == 'success_bonus') {
        badgeSuccessBonus += badge.effectValue;
      }
    }

    double totalSuccessBonus = willpowerBonus + badgeSuccessBonus;

    // 디버그 출력 (개발 중에만 사용)
    print('=== 등반 능력 계산 디버그 ===');
    print('사용자 스탯 - 사교성: ${user.stats.sociality}, 의지: ${user.stats.willpower}');
    print('장착된 뱃지 수: ${equippedBadges.length}');
    for (final badge in equippedBadges) {
      print('- ${badge.name}: ${badge.effectType} = ${badge.effectValue}%');
    }
    print('계산 결과:');
    print('- 등반력 보너스: $powerBonus%');
    print('- 시간 단축 (사교성): $socialityTimeReduction%');
    print('- 시간 단축 (뱃지): $badgeTimeReduction%');
    print('- 성공률 (의지): $willpowerBonus%');
    print('- 성공률 (뱃지): $badgeSuccessBonus%');

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Row(
            children: [
              Icon(
                Icons.hiking,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '등반 능력 현황',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 3가지 등반 지표
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildClimbingStatItem(
                icon: Icons.trending_up,
                value: powerBonus > 0 ? '+${powerBonus.toStringAsFixed(0)}%' : '0%',
                label: '등반력 강화',
                color: AppColors.primary,
                description: powerBonus > 0 ? '뱃지 효과' : '효과 없음',
              ),
              _buildClimbingStatItem(
                icon: Icons.speed,
                value: totalTimeReduction > 0 ? '-${totalTimeReduction.toStringAsFixed(1)}%' : '0%',
                label: '소요시간 감소',
                color: AppColors.success,
                description: _getTimeReductionDescription(socialityTimeReduction, badgeTimeReduction),
              ),
              _buildClimbingStatItem(
                icon: Icons.check_circle,
                value: totalSuccessBonus > 0 ? '+${totalSuccessBonus.toStringAsFixed(1)}%' : '0%',
                label: '성공률 증가',
                color: AppColors.warning,
                description: _getSuccessRateDescription(willpowerBonus, badgeSuccessBonus),
              ),
            ],
          ),
        ],
      ),
    );
  }

// 시간 단축 설명 생성
  String _getTimeReductionDescription(double socialityReduction, double badgeReduction) {
    if (socialityReduction > 0 && badgeReduction > 0) {
      return '사교성 ${socialityReduction.toStringAsFixed(1)}% + 뱃지 ${badgeReduction.toStringAsFixed(0)}%';
    } else if (socialityReduction > 0) {
      return '사교성 ${socialityReduction.toStringAsFixed(1)}%';
    } else if (badgeReduction > 0) {
      return '뱃지 ${badgeReduction.toStringAsFixed(0)}%';
    } else {
      return '효과 없음';
    }
  }

// 성공률 증가 설명 생성
  String _getSuccessRateDescription(double willpowerBonus, double badgeBonus) {
    if (willpowerBonus > 0 && badgeBonus > 0) {
      return '의지 ${willpowerBonus.toStringAsFixed(1)}% + 뱃지 ${badgeBonus.toStringAsFixed(0)}%';
    } else if (willpowerBonus > 0) {
      return '의지 ${willpowerBonus.toStringAsFixed(1)}%';
    } else if (badgeBonus > 0) {
      return '뱃지 ${badgeBonus.toStringAsFixed(0)}%';
    } else {
      return '효과 없음';
    }
  }

  Widget _buildClimbingStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required String description,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }


  String _getClimbingMessage(double progress) {
    if (progress < 0.25) {
      return "등반\n시작해요!";
    } else if (progress < 0.5) {
      return "순조롭게\n올라가는 중!";
    } else if (progress < 0.75) {
      return "중턱을\n넘었어요!";
    } else if (progress < 0.9) {
      return "정상이\n보여요!";
    } else {
      return "곧 정상\n도착!";
    }
  }
}

// 산 실루엣 페인터
class MountainSilhouettePainter extends CustomPainter {
  final Color color;

  MountainSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.4);
    path.lineTo(size.width * 0.5, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}