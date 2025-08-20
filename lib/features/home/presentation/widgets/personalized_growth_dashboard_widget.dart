// lib/features/home/presentation/widgets/personalized_growth_dashboard_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../core/theme/modern_colors.dart';

// Shared Providers
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';

// Core Constants
import '../../../../core/constants/sherpi_dialogues.dart';

// Shared Utils
import '../../../../shared/utils/haptic_feedback_manager.dart';

// Shared Models
import '../../../../shared/models/global_user_model.dart';

// Home Widgets - 보상 모달
import 'all_goals_reward_modal.dart';

// Home Widgets

/// 상수 정의
class _Constants {
  static const List<String> goalIds = ['steps', 'focus', 'reading', 'exercise', 'diary'];
  static const Duration animationDuration = Duration(milliseconds: 800);
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  
  // 공통 패딩/마진
  static const double cardPadding = 8.0;
  static const double sectionSpacing = 8.0;
  static const double headerPadding = 20.0;
  
  // 목표 임계값
  static const int stepsGoal = 6000;
  static const int focusMinutesGoal = 30;
  static const int readingPagesGoal = 1;
}


class PersonalizedGrowthDashboardWidget extends ConsumerStatefulWidget {
  const PersonalizedGrowthDashboardWidget({super.key});

  @override
  ConsumerState<PersonalizedGrowthDashboardWidget> createState() =>
      _PersonalizedGrowthDashboardWidgetState();
}

class _PersonalizedGrowthDashboardWidgetState
    extends ConsumerState<PersonalizedGrowthDashboardWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // 🎉 축하 화면 표시 상태
  bool _showCelebrationView = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: _Constants.animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  // 🎉 축하 화면 표시 조건 확인 (상태 변경 없이 계산만)
  bool _shouldShowCelebrationView(GlobalUser user) {
    final allGoalsCompleted = _checkAllGoalsCompleted();
    final rewardClaimed = user.dailyRecords.isAllGoalsRewardClaimed;
    
    // 모든 목표 완료 + 보상 받기 완료 = 축하 화면 표시
    return allGoalsCompleted && rewardClaimed;
  }
  

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final dailyGoals = user.dailyRecords.dailyGoals;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(24),
          // 🎨 다층 그림자 효과 최적화
          boxShadow: ModernColors.softShadow(primaryColor: ModernColors.modernPrimary),
        ),
        child: _shouldShowCelebrationView(user)
            ? _buildCelebrationView(user)
            : _buildNormalView(user, dailyGoals),
      ),
    );
  }

  // 🎉 축하 화면 (보상 받기 완료 후)
  Widget _buildCelebrationView(GlobalUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🎊 축하 헤더 섹션
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          decoration: BoxDecoration(
            // 🎨 깔끔한 화이트 배경으로 명확한 계층 구조
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            // 🌟 부드러운 그림자로 카드 느낌 강화
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // 🏆 대형 셰르피 (생동감 있는 세련된 모드)
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // 🎨 깔끔한 흰색 배경으로 통일감
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    // 🌟 브랜드 컬러 테두리로 포인트 강조
                    color: ModernColors.modernPrimary.withOpacity(0.2),
                    width: 3,
                  ),
                  boxShadow: [
                    // 🎭 다층 그림자로 깊이감과 생동감
                    BoxShadow(
                      color: ModernColors.modernPrimary.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: ModernColors.modernPrimary.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.scale(
                    scale: 1.8,
                    child: Image.asset(
                      SherpiEmotion.special.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 🎊 브랜드 컬러로 강조된 축하 메시지 (RichText 복원)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '🎉 ',
                      style: GoogleFonts.notoSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: '완벽해요!',
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.modernPrimary, // 브랜드 컬러로 강조
                        letterSpacing: -0.3,
                        shadows: [
                          Shadow(
                            color: ModernColors.modernPrimary.withOpacity(0.15),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${user.name}님',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.modernPrimary, // 이름을 브랜드 컬러로
                        letterSpacing: -0.1,
                        shadows: [
                          Shadow(
                            color: ModernColors.modernPrimary.withOpacity(0.1),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    TextSpan(
                      text: ', 수고 많으셨어요!\n오늘의 목표를 모두 달성했어요!',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B), // 부드러운 그레이
                        height: 1.5,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 🔥 연속 달성 카드만 유지
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: _buildStreakCard(user),
        ),
      ],
    );
  }

  // 📊 일반 화면 (기존 레이아웃)
  Widget _buildNormalView(GlobalUser user, List<DailyGoal> dailyGoals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntegratedHeaderSection(user, dailyGoals),
        const SizedBox(height: 8), // 10 → 8로 더 타이트하게
        _buildGoalsGrid(dailyGoals),
        const SizedBox(height: 8), // 10 → 8로 더 타이트하게
        // 새로운 스트릭 & 주간 현황 섹션
        _buildStreakAndWeeklySection(user),
        const SizedBox(height: 10), // 12 → 10으로 축소
      ],
    );
  }

  // 🌟 히어로 헤더 - 임팩트 있는 개인화된 진행률 표시
  Widget _buildIntegratedHeaderSection(GlobalUser user, List<DailyGoal> dailyGoals) {
    final records = user.dailyRecords;
    
    // 목표 완료 상태 계산
    final completedCount = _getCompletedGoalsCount(records);
    final totalCount = _Constants.goalIds.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isAllCompleted = completedCount == totalCount;
    
    // 🎁 보상받기 가능 상태 확인 (황금빛 테마 적용용)
    final canClaimReward = isAllCompleted && !user.dailyRecords.isAllGoalsRewardClaimed;

    return Container(
      padding: const EdgeInsets.fromLTRB(_Constants.headerPadding, 24, _Constants.headerPadding, 24),
      decoration: BoxDecoration(
        // 🎨 조건부 그라데이션 - 보상받기 가능 시 황금빛 테마
        gradient: canClaimReward 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ModernColors.rewardGradient1,       // 황금 그라데이션 시작 (#FFD700)
                ModernColors.rewardGradient2,       // 황금 그라데이션 끝 (#FFA500)
              ],
              stops: const [0.0, 1.0],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ModernColors.modernPrimary,         // 메인 브랜드 색상
                ModernColors.primaryLight,          // 조화로운 밝은 톤
              ],
              stops: const [0.0, 1.0],
            ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        // 🌟 조건부 그림자 시스템 최적화
        boxShadow: canClaimReward
          ? ModernColors.rewardShadow()
          : ModernColors.premiumShadow(
              primaryColor: ModernColors.modernPrimary,
              lightColor: ModernColors.primaryLight,
            ),
      ),
      child: Column(
        children: [
          // 🌅 개인화된 인사말 중앙정렬 + 셰르피 텍스트 왼쪽 붙임
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 셰르피 (원래 크기로)
                _buildCompactSherpiSection(canClaimReward),
                const SizedBox(width: 8),
                // 인사말 - 보상받기 가능 시 칭찬 메시지로 변경
                Text(
                  _getGreetingMessage(canClaimReward),
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                    shadows: [
                      // 🌟 텍스트 가독성을 위한 부드러운 그림자
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 🎯 중앙 대형 진행률 표시
          _buildHeroCircularProgress(progress, isAllCompleted, completedCount, totalCount),
        ],
      ),
    );
  }

  // 🌅 조건부 인사말 - 보상받기 가능 시 칭찬 메시지
  String _getGreetingMessage(bool canClaimReward) {
    if (canClaimReward) {
      // 🎉 모든 목표 완료 시 칭찬 메시지들
      final praiseMessages = [
        '완벽해요! 🌟',
        '대단하시네요! ✨', 
        '최고예요! 🏆',
        '멋져요! 🎉',
        '훌륭해요! 💫',
      ];
      
      // 시간대별로 다른 칭찬 메시지 선택
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 12) {
        return praiseMessages[0]; // 아침: 완벽해요!
      } else if (hour >= 12 && hour < 17) {
        return praiseMessages[1]; // 오후: 대단하시네요!
      } else if (hour >= 17 && hour < 21) {
        return praiseMessages[2]; // 저녁: 최고예요!
      } else {
        return praiseMessages[3]; // 밤: 멋져요!
      }
    } else {
      // 🌅 일반 시간대별 인사말
      return _getTimeBasedGreeting();
    }
  }
  
  // 🌅 시간대별 개인화된 인사말 (일반 상황용)
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return '좋은 아침이에요! ☀️';
    } else if (hour >= 12 && hour < 17) {
      return '좋은 오후예요! 🌤️';
    } else if (hour >= 17 && hour < 21) {
      return '좋은 저녁이에요! 🌅';
    } else {
      return '수고하셨어요! 🌙';
    }
  }

  // 🎯 히어로 스타일 대형 원형 진행률
  Widget _buildHeroCircularProgress(double progress, bool isAllCompleted, int completedCount, int totalCount) {
    return Column(
      children: [
        // 대형 원형 진행률 표시
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 🏆 완성시 황금색, 미완성시 화이트 배경
            color: isAllCompleted 
                ? ModernColors.streakGold  
                : Colors.white,
            // 🌟 그라데이션 헤더와 조화로운 진화된 그림자 시스템
            boxShadow: isAllCompleted
                ? [
                    // 황금 글로우 효과 - 완성 시
                    BoxShadow(
                      color: ModernColors.streakGold.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: ModernColors.streakGold.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    // 그라데이션 조화 그림자
                    BoxShadow(
                      color: ModernColors.primaryLight.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    // 🎨 그라데이션과 조화로운 프리미엄 그림자 시스템
                    BoxShadow(
                      color: ModernColors.modernPrimary.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: ModernColors.primaryLight.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 진행률 퍼센트
                Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.notoSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isAllCompleted 
                        ? Colors.white
                        : ModernColors.modernPrimary,
                    height: 1,
                    shadows: isAllCompleted
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                // 진행률 레이블
                Text(
                  '완료',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isAllCompleted 
                        ? Colors.white.withOpacity(0.9)
                        : ModernColors.modernTextSecondary,
                    shadows: isAllCompleted
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 동적 완료 개수 표시
        Text(
          isAllCompleted 
              ? '🎉 모든 목표 완성!'
              : '오늘의 목표 ${totalCount}개 중 ${completedCount}개 완료!',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500, 
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }




  // 컴팩트한 셰르피 섹션 (조건부 스타일링)
  Widget _buildCompactSherpiSection(bool canClaimReward) {
    return GestureDetector(
      onTap: () {
        ref.read(sherpiProvider.notifier).showMessage(
          context: SherpiContext.encouragement,
          emotion: SherpiEmotion.cheering,
        );
        HapticFeedbackManager.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          // 🎨 조건부 배경색 - 보상받기 가능 시 황금빛 틴트
          color: canClaimReward 
              ? Colors.white.withOpacity(0.98) // 보상받기 상태에서 더 선명한 배경
              : Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          // 🌟 조건부 그림자 시스템 - 황금빛 테마와 조화
          boxShadow: canClaimReward
              ? [
                  // 황금빛 테마 그림자
                  BoxShadow(
                    color: ModernColors.rewardGradient1.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: ModernColors.rewardGradient2.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ]
              : [
                  // 일반 테마 그림자
                  BoxShadow(
                    color: ModernColors.primaryLight.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
          // 🌈 조건부 테두리 - 황금빛 테마와 조화
          border: Border.all(
            color: canClaimReward 
                ? ModernColors.rewardGradient1.withOpacity(0.3) // 황금빛 테두리
                : Colors.white.withOpacity(0.9),
            width: 2.0,
          ),
        ),
        child: Center(
          child: Transform.scale(
            scale: 1.4,
            child: Image.asset(
              SherpiEmotion.cheering.imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }


  // 진행률 섹션은 통합된 헤더로 이동됨

  // 목표 그리드 - 1x5 가로 레이아웃으로 변경 (프로바이더 최적화)
  Widget _buildGoalsGrid(List<DailyGoal> dailyGoals) {
    final records = ref.watch(globalUserProvider.select((user) => user.dailyRecords));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // 🎨 완료 보상 카드 (받기 버튼 제거된 버전)
          _buildRewardDisplayCard(),
          const SizedBox(height: 10),
          
          // 목표들을 1x5 행으로 배치 (완전한 크기 일관성 보장)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 균등 분배로 크기 통일
              children: _Constants.goalIds.map((goalId) {
                final isCompleted = _checkGoalCompletion(goalId, records);
                return Flexible(
                  flex: 1, // 모든 카드에 동일한 flex 비율
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2), // 균등한 간격
                    child: _buildCompactGoalCard(goalId, records, isCompleted),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // 🚫 보상받기 버튼 제거됨 - 독립 위젯으로 분리
        ],
      ),
    );
  }

  // 🎨 조건부 보상 카드/버튼 (모든 목표 완료 시 황금빛 버튼으로 변환) - 프로바이더 최적화
  Widget _buildRewardDisplayCard() {
    final isAllGoalsRewardClaimed = ref.watch(globalUserProvider.select((user) => user.dailyRecords.isAllGoalsRewardClaimed));
    final canClaimReward = _checkAllGoalsCompleted() && !isAllGoalsRewardClaimed;
    
    Widget cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 클릭 가능할 때 더 넓게
      decoration: BoxDecoration(
        // 🏆 모든 퀘스트 완료 시 황금빛, 일반 시에는 프라이머리
        color: canClaimReward ? ModernColors.streakGold : ModernColors.modernPrimary,
        borderRadius: BorderRadius.circular(12),
        // 🌟 그라데이션 헤더와 조화로운 고급 그림자 시스템
        boxShadow: canClaimReward 
          ? [
              // 황금빛 보상 버튼 - 임팩트 있는 프리미엄 그림자
              BoxShadow(
                color: ModernColors.streakGold.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: ModernColors.primaryLight.withOpacity(0.12),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ]
          : [
              // 일반 카드 - 그라데이션과 조화로운 은은한 그림자
              BoxShadow(
                color: ModernColors.modernPrimary.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: ModernColors.primaryLight.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
        mainAxisSize: MainAxisSize.min, // 최소 크기로 축소
        children: [
          // 🏆 동적 아이콘 (보상 버튼일 때 더 크고 강렬하게)
          Container(
            width: canClaimReward ? 24 : 20,
            height: canClaimReward ? 24 : 20,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: canClaimReward 
                ? [
                    // 보상 버튼 상태일 때 더 강한 그림자
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
            ),
            child: Icon(
              canClaimReward ? Icons.card_giftcard : Icons.emoji_events,
              color: canClaimReward ? ModernColors.streakGold : ModernColors.modernPrimary,
              size: canClaimReward ? 16 : 12,
            ),
          ),
          const SizedBox(width: 8),
          
          // 📝 동적 텍스트 (보상 버튼일 때 "보상 받기"로 변경)
          Text(
            canClaimReward ? '🎉 보상 받기' : '전체 완료 시 보상',
            style: GoogleFonts.notoSans(
              fontSize: canClaimReward ? 14 : 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.1,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          
          // 🎁 조건부 컨텐츠 (보상 버튼일 때는 배지 숨김)
          if (canClaimReward) ...[
            const SizedBox(width: 8),
            // 보상 버튼 상태에서는 화살표 아이콘 표시
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 14,
            ),
          ],
        ],
      ),
    );
    
    // 🎁 보상 카드/버튼 반환 (애니메이션 및 상태 관리)
    if (canClaimReward) {
      return GestureDetector(
        onTap: () {
          print('🎁 황금빛 보상 버튼 클릭됨 - 모든 목표 완료');
          HapticFeedbackManager.lightImpact();
          
          // 🎊 먼저 보상 처리를 실행
          _handleRewardClaim();
          
          // 🎉 그 다음에 축하 알림 모달 표시
          _showCompletionModal();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          transform: Matrix4.identity()..scale(1.02), // 살짝 확대
          child: Container(
            decoration: BoxDecoration(
              // 🌟 그라데이션과 조화로운 프리미엄 외부 글로우 효과
              boxShadow: [
                BoxShadow(
                  color: ModernColors.streakGold.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: ModernColors.primaryLight.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: 1,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: cardContent,
          ),
        ),
      );
    } else {
      // 🎨 일반 상태에서는 정적 카드로 표시
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: cardContent,
      );
    }
  }

  // 🚫 _buildClaimRewardButton 제거됨 - 독립 위젯으로 분리


  

  // 컴팩트 목표 카드 (1x5 레이아웃용) - 프라이머리 통일 디자인
  Widget _buildCompactGoalCard(String goalId, DailyRecordData records, bool isCompleted) {
    final goalData = _getGoalData(goalId);
    
    // 🛡️ 보상받기 상태 확인 (프로바이더 최적화)
    final isAllGoalsRewardClaimed = ref.read(globalUserProvider.select((user) => user.dailyRecords.isAllGoalsRewardClaimed));
    final canClaimReward = _checkAllGoalsCompleted() && !isAllGoalsRewardClaimed;
    final shouldDisable = canClaimReward || isAllGoalsRewardClaimed;
    
    return GestureDetector(
      onTap: () {
        // 🛡️ 보상받기 상태일 때는 목표 버튼 비활성화 (이미 계산된 값 사용)
        if (shouldDisable) {
          HapticFeedbackManager.lightImpact();
          return; // 🚫 네비게이션 실행하지 않음
        }
        
        if (!isCompleted) {
          _navigateToRecordScreen(goalId);
        }
        HapticFeedbackManager.lightImpact();
      },
      child: Opacity(
        // 🎨 보상받기 상태일 때 시각적 비활성화
        opacity: shouldDisable ? 0.5 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 64,
          decoration: BoxDecoration(
          // 🔵 완료 상태: 강렬한 프라이머리 배경으로 통일
          color: isCompleted 
              ? ModernColors.modernPrimary
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: !isCompleted
              ? Border.all(
                  color: ModernColors.modernPrimary.withOpacity(0.15), // 🎨 통일된 프라이머리 색상으로 테두리
                  width: 0.8,
                )
              : null,
          // 🎨 그라데이션 헤더와 조화로운 완성도 높은 그림자 시스템
          boxShadow: isCompleted
              ? [
                  // 완료 상태: 그라데이션과 조화로운 멀티 레이어 그림자
                  BoxShadow(
                    color: ModernColors.modernPrimary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: ModernColors.primaryLight.withOpacity(0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ]
              : [
                  // 미완료 상태: 서틀하면서도 세련된 그림자
                  BoxShadow(
                    color: ModernColors.modernPrimary.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: ModernColors.primaryLight.withOpacity(0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 - 완료/미완료 상태별 차별화
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  // 🎨 완료: 흰색 배경 / 미완료: 통일된 프라이머리 색상 배경
                  color: isCompleted 
                      ? Colors.white.withOpacity(0.9)
                      : ModernColors.modernPrimary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  // 🎨 완료 상태에만 그림자 적용
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: ModernColors.modernPrimary, // 🔵 프라이머리 체크마크
                          size: 16,
                        )
                      : Text(
                          goalData['icon'] ?? '🎯',
                          style: TextStyle(
                            fontSize: 14,
                            // 🎨 통일된 프라이머리 색상 기반 이모지 그림자
                            shadows: [
                              Shadow(
                                color: ModernColors.modernPrimary.withOpacity(0.15),
                                offset: const Offset(0, 0.5),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              // 텍스트 - 완료/미완료 상태별 색상 차별화 (크기 일관성 보장)
              Container(
                height: 12, // 고정 높이로 완벽한 크기 일관성 보장
                width: double.infinity, // 가로 폭 완전 통일
                alignment: Alignment.center, // 중앙 정렬 강제
                child: Text(
                  goalData['title'] ?? '목표',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    // 🎨 완료: 흰색 텍스트 / 미완료: 프라이머리 통일
                    color: isCompleted 
                        ? Colors.white
                        : ModernColors.modernPrimary,
                    // 🎨 완료 상태에 텍스트 그림자로 가독성 보장
                    shadows: isCompleted
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 0.5),
                              blurRadius: 1,
                            ),
                          ]
                        : [
                            Shadow(
                              color: ModernColors.modernPrimary.withOpacity(0.1),
                              offset: const Offset(0, 0.5),
                              blurRadius: 1,
                            ),
                          ],
                    height: 1.0,
                    letterSpacing: -0.1, // 문자 간격 통일로 렌더링 일관성 보장
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        ),
      ), // AnimatedContainer close
    ), // Opacity close
  ); // GestureDetector close
  }
  
  // 목표 데이터 반환 (UI 일관성을 위해 모든 제목을 2글자로 통일)
  Map<String, String> _getGoalData(String goalId) {
    switch (goalId) {
      case 'steps':
        return {'icon': '👟', 'title': '걸음'};  // 3글자 → 2글자로 단축
      case 'focus':
        return {'icon': '⏰', 'title': '집중'};
      case 'reading':
        return {'icon': '📚', 'title': '독서'};
      case 'exercise':
        return {'icon': '💪', 'title': '운동'};
      case 'diary':
        return {'icon': '📝', 'title': '일기'};
      default:
        return {'icon': '🎯', 'title': '목표'};
    }
  }


  // 모든 목표 완료 확인 헬퍼 메서드
  bool _checkAllGoalsCompleted() {
    final user = ref.read(globalUserProvider);
    final records = user.dailyRecords;
    return _getCompletedGoalsCount(records) == _Constants.goalIds.length;
  }
  
  // 완료된 목표 개수 계산 (중복 로직 통합)
  int _getCompletedGoalsCount(DailyRecordData records) {
    int completedCount = 0;
    for (final goalId in _Constants.goalIds) {
      if (_checkGoalCompletion(goalId, records)) {
        completedCount++;
      }
    }
    return completedCount;
  }

  // 목표별 기록 화면으로 이동 (각 액션카드별로 다른 화면 이동)
  void _navigateToRecordScreen(String goalId) {
    switch (goalId) {
      case 'steps':
        // 걸음 -> 기록탭으로 이동 (기존 동작 유지)
        Navigator.of(context).pushNamed(
          '/',
          arguments: {
            'tabIndex': 2,    // 퀘스트 탭
            'subTabIndex': 1, // 기록 서브탭
          },
        );
        break;
        
      case 'focus':
        // 집중 -> 몰입 시간 선택창 띄우기 (집중 타이머 화면)
        Navigator.of(context).pushNamed('/focus_timer_record');
        break;
        
      case 'reading':
        // 독서 -> 독서 기록 작성창 띄우기
        Navigator.of(context).pushNamed('/reading_record');
        break;
        
      case 'exercise':
        // 운동 -> 운동 기록 선택창 띄우기
        Navigator.of(context).pushNamed('/exercise_record');
        break;
        
      case 'diary':
        // 일기 -> 일기 기록 작성창 띄우기
        Navigator.of(context).pushNamed('/diary_record');
        break;
        
      default:
        // 기본값으로 기록탭으로 이동
        Navigator.of(context).pushNamed(
          '/',
          arguments: {
            'tabIndex': 2,
            'subTabIndex': 1,
          },
        );
        break;
    }
  }

  // 목표 완료 상태 확인 (상수 적용)
  bool _checkGoalCompletion(String goalId, DailyRecordData records) {
    final today = DateTime.now();
    
    switch (goalId) {
      case 'steps':
        return records.todaySteps >= _Constants.stepsGoal;
      case 'focus':
        return records.todayFocusMinutes >= _Constants.focusMinutesGoal;
      case 'reading':
        return records.readingLogs.any((log) => 
          _isSameDay(log.date, today) && 
          log.pages >= _Constants.readingPagesGoal);
      case 'exercise':
        return records.exerciseLogs.any((log) => _isSameDay(log.date, today));
      case 'diary':
        return records.diaryLogs.any((log) => _isSameDay(log.date, today));
      default:
        return false;
    }
  }
  
  // 날짜 비교 헬퍼 메서드 (중복 제거)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  // 스트릭 섹션 (단일 카드로 변경)
  Widget _buildStreakAndWeeklySection(GlobalUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: _buildStreakCard(user), // 스트릭 카드만 유지
    );
  }
  
  // 연속 클리어 스트릭 카드 (이미지 기반 깔끔한 주간 디자인)
  Widget _buildStreakCard(GlobalUser user) {
    // 실제 보상 받은 날짜 기반으로 연속 달성일 계산
    final actualConsecutiveDays = _calculateActualConsecutiveDays(user);
    final displayConsecutiveDays = actualConsecutiveDays; // 실제 보상 데이터만 사용
    
    // 이번 주 날짜별 목표 달성 상태 계산
    final weeklyCompletionStatus = _calculateWeeklyCompletionStatus(user);
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // 🎨 그라데이션 헤더와 조화로운 프리미엄 그림자 시스템
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: ModernColors.primaryLight.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 - 연속 달성 텍스트
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ModernColors.modernPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  size: 18,
                  color: ModernColors.modernPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$displayConsecutiveDays일 연속 달성',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.modernText,
                  // 🎨 텍스트 그림자로 강조
                  shadows: [
                    Shadow(
                      color: ModernColors.modernText.withOpacity(0.1),
                      offset: const Offset(0, 0.5),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 요일 라벨
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.modernTextSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          
          // 완료 상태 원형 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weeklyCompletionStatus.asMap().entries.map((entry) {
              final isCompleted = entry.value;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // 🎨 완료 상태에 따른 그라데이션 적용
                  gradient: isCompleted 
                      ? LinearGradient(
                          colors: [
                            ModernColors.modernPrimary,
                            ModernColors.modernPrimary.withOpacity(0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !isCompleted ? ModernColors.gray100 : null,
                  // 🎨 완료된 날짜에 그림자 효과
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: ModernColors.modernPrimary.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  

  // 이번 주 각 날짜별 목표 달성 상태 계산 (월-일)
  List<bool> _calculateWeeklyCompletionStatus(GlobalUser user) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // 월요일 시작
    
    List<bool> weeklyStatus = [];
    
    // 월요일부터 일요일까지 7일 계산
    for (int i = 0; i < 7; i++) {
      final checkDate = startOfWeek.add(Duration(days: i));
      
      // 오늘보다 미래 날짜는 미완료로 처리
      if (checkDate.isAfter(now)) {
        weeklyStatus.add(false);
        continue;
      }
      
      // 해당 날짜에 전체 클리어 보상을 받았는지 확인
      weeklyStatus.add(_checkAllGoalsRewardClaimedForDate(user.dailyRecords, checkDate));
    }
    
    return weeklyStatus;
  }

  // 특정 날짜에 전체 클리어 보상을 받았는지 확인
  bool _checkAllGoalsRewardClaimedForDate(DailyRecordData records, DateTime checkDate) {
    // ✅ 실제 보상 받은 날짜 리스트를 확인
    return records.allGoalsRewardClaimedDates.any((claimedDate) => 
      claimedDate.year == checkDate.year && 
      claimedDate.month == checkDate.month && 
      claimedDate.day == checkDate.day);
  }
  
  // 실제 연속 달성일 계산 (보상 받은 날짜 기반)
  int _calculateActualConsecutiveDays(GlobalUser user) {
    final records = user.dailyRecords;
    final claimedDates = records.allGoalsRewardClaimedDates;
    
    // 보상 받은 날짜가 없으면 0 반환
    if (claimedDates.isEmpty) {
      return 0;
    }
    
    // 날짜를 정렬 (최신 날짜부터)
    final sortedDates = [...claimedDates];
    sortedDates.sort((a, b) => b.compareTo(a)); // 내림차순 정렬
    
    int consecutiveDays = 0;
    DateTime? previousDate;
    
    for (final claimedDate in sortedDates) {
      // 첫 번째 날짜인 경우
      if (previousDate == null) {
        consecutiveDays = 1;
        previousDate = claimedDate;
        continue;
      }
      
      // 이전 날짜와 정확히 하루 차이인지 확인
      final daysDifference = previousDate.difference(claimedDate).inDays;
      
      if (daysDifference == 1) {
        // 연속된 날짜
        consecutiveDays++;
        previousDate = claimedDate;
      } else {
        // 연속이 끊어짐
        break;
      }
    }
    
    return consecutiveDays;
  }
  

  // 🎉 완료 축하 알림 모달 표시 (보상은 이미 처리됨)
  void _showCompletionModal() {
    final user = ref.read(globalUserProvider);
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return AllGoalsRewardModal(
            userName: user.name,
            onClose: () {
              Navigator.pop(context);
            },
            // 🔄 보상은 이미 처리되었으므로 onRewardClaimed 콜백 제거
            onRewardClaimed: null, // 단순 알림 용도로 변경
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        opaque: false,
        barrierColor: Colors.transparent,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // 🎊 실제 보상 처리
  void _handleRewardClaim() {
    // 보상 받기 실행
    ref.read(globalUserProvider.notifier).claimAllGoalsReward();
    
    // 셰르피 반응
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.questComplete,
      customDialogue: '🎉 모든 목표를 달성했어요! 멋져요!',
      emotion: SherpiEmotion.cheering,
    );
  }

}