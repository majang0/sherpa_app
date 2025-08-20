// lib/features/home/presentation/widgets/personalized_growth_dashboard_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Core
import '../../../../core/theme/modern_colors.dart';

// Shared Providers
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';

// Core Constants
import '../../../../core/constants/sherpi_emotions.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

// Shared Utils
import '../../../../shared/utils/haptic_feedback_manager.dart';

// Shared Models
import '../../../../shared/models/global_user_model.dart';

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

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
          // 🎨 다층 그림자 효과 (Ambient + Direct Shadow)
          boxShadow: [
            BoxShadow(
              color: ModernColors.modernPrimary.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: ModernColors.modernPrimary.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
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
        ),
      ),
    );
  }

  // 🎨 깔끔한 2줄 구조 헤더 - 시각적 요소와 텍스트 분리
  Widget _buildIntegratedHeaderSection(GlobalUser user, List<DailyGoal> dailyGoals) {
    final records = user.dailyRecords;
    
    // 실제 5개 목표 기준으로 계산
    final allGoals = ['steps', 'focus', 'reading', 'exercise', 'diary'];
    int completedCount = 0;
    
    for (final goalId in allGoals) {
      if (_checkGoalCompletion(goalId, records)) {
        completedCount++;
      }
    }
    
    final totalCount = allGoals.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isAllCompleted = completedCount == totalCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: ModernColors.backgroundElevated,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎯 첫 번째 줄: 시각적 요소들 (셰르피 + 프로그레스바 + 원형)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 셰르피 (고정 크기)
              _buildCompactSherpiSection(),
              const SizedBox(width: 16),
              
              // 프로그레스바 (전체 너비 활용)
              Expanded(
                child: _buildProgressBarOnly(progress, isAllCompleted),
              ),
              const SizedBox(width: 16),
              
              // 원형 진행률 (고정 크기)
              _buildCircularProgressOnly(progress, isAllCompleted),
            ],
          ),
          
          const SizedBox(height: 14), // 줄 간 간격
          
          // 🎯 두 번째 줄: 텍스트들 (격려 메시지 + 상태 텍스트)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 왼쪽: 격려 메시지
              Expanded(
                child: Text(
                  _getDynamicMessage(completedCount, totalCount, isAllCompleted),
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.modernText,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // 오른쪽: 상태 텍스트
              Text(
                isAllCompleted 
                    ? '🎉 모든 목표 완성!' 
                    : '$completedCount/$totalCount 목표 진행중',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isAllCompleted 
                      ? ModernColors.streakGold 
                      : ModernColors.modernTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎯 진행 상황에 따른 동적 격려 메시지 생성
  String _getDynamicMessage(int completedCount, int totalCount, bool isAllCompleted) {
    if (isAllCompleted) {
      return '완벽해요! 🎉'; // 모든 목표 완성
    } else if (completedCount == 0) {
      return '오늘도 화이팅이에요!'; // 아직 시작 전
    } else if (completedCount <= 2) {
      return '좋은 시작이에요!'; // 1-2개 완료
    } else {
      return '거의 다 왔어요!'; // 3-4개 완료
    }
  }

  // 🎨 프로그레스바만 (첫 번째 줄용)
  Widget _buildProgressBarOnly(double progress, bool isAllCompleted) {
    return Container(
      height: 7,
      decoration: BoxDecoration(
        color: ModernColors.softCloud,
        borderRadius: BorderRadius.circular(3.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: isAllCompleted 
                ? ModernColors.streakGold
                : ModernColors.modernPrimary,
            borderRadius: BorderRadius.circular(3.5),
            boxShadow: [
              BoxShadow(
                color: (isAllCompleted 
                    ? ModernColors.streakGold 
                    : ModernColors.modernPrimary).withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 원형 진행률 표시기만 (첫 번째 줄용)
  Widget _buildCircularProgressOnly(double progress, bool isAllCompleted) {
    return Container(
      width: 57,
      height: 57,
      decoration: BoxDecoration(
        // 🏆 완성시 강렬한 황금색 배경, 미완성시 깔끔한 단색
        color: isAllCompleted 
            ? ModernColors.streakGold  // 진한 황금색 단색 배경
            : ModernColors.backgroundElevated,
        shape: BoxShape.circle,
        // 🌟 완성시 극적인 황금 그림자 효과
        boxShadow: isAllCompleted
            ? [
                // 외곽 강한 황금 글로우
                BoxShadow(
                  color: ModernColors.streakGold.withOpacity(0.6),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                // 내부 선명한 그림자
                BoxShadow(
                  color: ModernColors.streakGold.withOpacity(0.8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
                // 미묘한 하이라이트 효과
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, -1),
                ),
              ]
            : ModernColors.getElevationShadow(2),
      ),
      child: Center(
        child: Text(
          '${(progress * 100).round()}%',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            // 🏆 완성시 순백색 텍스트로 최대 가독성, 미완성시 블루
            color: isAllCompleted 
                ? Colors.white  // 강렬한 황금 배경에 선명한 흰색
                : ModernColors.modernPrimary,
            height: 1,
            // 🌟 완성시 텍스트 그림자로 더욱 선명하게
            shadows: isAllCompleted
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                    Shadow(
                      color: ModernColors.streakGold.withOpacity(0.5),
                      offset: const Offset(0, 0),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  // 컴팩트한 셰르피 섹션
  Widget _buildCompactSherpiSection() {
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
          color: ModernColors.backgroundSubtle,
          shape: BoxShape.circle,
          // 🎨 브랜드 컬러 그림자 (따뜻한 느낌)
          boxShadow: [
            BoxShadow(
              color: ModernColors.dayCompleted.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: ModernColors.dayCompleted.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
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

  // 목표 그리드 - 1x5 가로 레이아웃으로 변경
  Widget _buildGoalsGrid(List<DailyGoal> dailyGoals) {
    final user = ref.watch(globalUserProvider);
    final records = user.dailyRecords;
    
    // 5개 목표: 걸음수, 집중, 독서, 운동, 일기
    final allGoals = ['steps', 'focus', 'reading', 'exercise', 'diary'];
    
    // 완료된 목표 개수 계산 (simple_today_growth_widget 방식)
    int completedCount = 0;
    final today = DateTime.now();
    
    for (final goalId in allGoals) {
      if (_checkGoalCompletion(goalId, records)) {
        completedCount++;
      }
    }
    
    final totalGoals = allGoals.length;
    final isAllCompleted = completedCount == totalGoals;
    final canClaimReward = isAllCompleted && !user.dailyRecords.isAllGoalsRewardClaimed;
    final isRewardClaimed = user.dailyRecords.isAllGoalsRewardClaimed;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // 🎨 완전히 새로운 인라인 보상 레이아웃 - 한 줄에 모든 것 배치
          _buildInlineRewardSection(
            canClaimReward: canClaimReward,
            isRewardClaimed: isRewardClaimed,
            completedCount: completedCount,
            totalGoals: totalGoals,
          ),
          const SizedBox(height: 10), // 12 → 10으로 축소
          
          // 목표들을 1x5 행으로 배치 (완전한 크기 일관성 보장)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 균등 분배로 크기 통일
              children: allGoals.map((goalId) {
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
        ],
      ),
    );
  }

  // 🎨 완전히 새로운 인라인 보상 섹션 - 프라이머리 배경 디자인
  Widget _buildInlineRewardSection({
    required bool canClaimReward,
    required bool isRewardClaimed,
    required int completedCount,
    required int totalGoals,
  }) {
    // 상태 결정: 완료 > 활성 > 비활성
    String buttonText;
    Color buttonBackgroundColor;
    Color buttonForegroundColor;
    bool canClick;

    if (isRewardClaimed) {
      // 보상 완료 상태 - 깔끔한 성공 상태
      buttonText = '완료';
      buttonBackgroundColor = Colors.white.withOpacity(0.9);
      buttonForegroundColor = ModernColors.modernPrimary;
      canClick = false;
    } else if (canClaimReward) {
      // 보상 받을 수 있는 상태 - 강렬한 액션 버튼
      buttonText = '받기';
      buttonBackgroundColor = Colors.white;
      buttonForegroundColor = ModernColors.modernPrimary;
      canClick = true;
    } else {
      // 아직 목표 미달성 상태 - 은은한 비활성 상태
      buttonText = '받기';
      buttonBackgroundColor = Colors.white.withOpacity(0.3);
      buttonForegroundColor = Colors.white.withOpacity(0.7);
      canClick = false;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // 🔵 강렬한 프라이머리 배경으로 시선 집중
        color: ModernColors.modernPrimary,
        borderRadius: BorderRadius.circular(14),
        // 🌟 프라이머리 색상 기반 깊이감 있는 그림자
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: ModernColors.modernPrimary.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // 🏆 트로피 아이콘 - 흰색 배경에 프라이머리 아이콘
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              // 🌟 은은한 내부 그림자로 깊이감
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              color: ModernColors.modernPrimary,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          
          // 📝 보상 타이틀 - 깨끗한 흰색 텍스트
          Text(
            '완료 보상',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.1,
              // 🎨 텍스트 그림자로 선명함 향상
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // 🎁 보상 배지들 - 투명 흰색 배경으로 조화
          _buildMiniRewardBadge('✨', '200XP'),
          const SizedBox(width: 6),
          _buildMiniRewardBadge('💰', '50P'),
          const SizedBox(width: 6),
          _buildMiniRewardBadge('🔥', '0.1'),
          
          // 🔄 공간 확보
          const Spacer(),
          
          // 🎯 보상받기 버튼 - 깨끗한 흰색 대비
          Container(
            height: 32, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // 🌟 버튼 자체에 그림자 효과
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: canClick ? () {
                HapticFeedbackManager.heavyImpact();
                
                // 보상 받기 실행
                ref.read(globalUserProvider.notifier).claimAllGoalsReward();
                
                // 셰르피 반응
                ref.read(sherpiProvider.notifier).showInstantMessage(
                  context: SherpiContext.questComplete,
                  customDialogue: '🎉 모든 목표를 달성했어요! 멋져요!',
                  emotion: SherpiEmotion.cheering,
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                foregroundColor: buttonForegroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  // 테두리 제거로 더 깔끔하게
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
                minimumSize: Size.zero,
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 미니 보상 배지 (프라이머리 배경용 - 반투명 흰색)
  Widget _buildMiniRewardBadge(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        // 🤍 반투명 흰색 배경으로 프라이머리와 조화
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        // 🌟 미묘한 흰색 테두리로 정의감 추가
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 9,
              // 🎨 이모지에 흰색 그림자로 가독성 향상
              shadows: [
                Shadow(
                  color: Colors.white,
                  offset: Offset(0, 0),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.05,
              // 🎨 텍스트 그림자로 선명함 보장
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 0.5),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  // 컴팩트 목표 카드 (1x5 레이아웃용) - 프라이머리 통일 디자인
  Widget _buildCompactGoalCard(String goalId, DailyRecordData records, bool isCompleted) {
    final goalData = _getGoalData(goalId);
    final functionColor = ModernColors.getFunctionColor(goalId);
    
    return GestureDetector(
      onTap: () {
        if (!isCompleted) {
          _navigateToRecordScreen(goalId);
        }
        HapticFeedbackManager.lightImpact();
      },
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
                  color: functionColor.withOpacity(0.15), // 🎨 기능별 색상으로 테두리
                  width: 0.8,
                )
              : null,
          // 🎨 완료/미완료 상태별 차별화된 그림자
          boxShadow: isCompleted
              ? [
                  // 완료 상태: 프라이머리 기반 강렬한 그림자
                  BoxShadow(
                    color: ModernColors.modernPrimary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: ModernColors.modernPrimary.withOpacity(0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [
                  // 미완료 상태: 기능별 색상 기반 은은한 그림자
                  BoxShadow(
                    color: functionColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: functionColor.withOpacity(0.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
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
                  // 🎨 완료: 흰색 배경 / 미완료: 기능별 색상 배경
                  color: isCompleted 
                      ? Colors.white.withOpacity(0.9)
                      : functionColor.withOpacity(0.12),
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
                            // 🎨 기능별 색상 기반 이모지 그림자
                            shadows: [
                              Shadow(
                                color: functionColor.withOpacity(0.15),
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
                    fontSize: 9,
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
      ),
    );
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


  // 목표별 기록 화면으로 이동
  void _navigateToRecordScreen(String goalId) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
      arguments: {
        'tabIndex': 2,    // 퀘스트 탭
        'subTabIndex': 1, // 기록 서브탭
      },
    );
  }

  // 목표 완료 상태 확인
  bool _checkGoalCompletion(String goalId, DailyRecordData records) {
    final today = DateTime.now();
    
    switch (goalId) {
      case 'steps':
        return records.todaySteps >= 6000;
      case 'focus':
        return records.todayFocusMinutes >= 30;
      case 'reading':
        return records.readingLogs.any((log) => 
          _isSameDay(log.date, today) && log.pages >= 1);
      case 'exercise':
        return records.exerciseLogs.any((log) =>
            _isSameDay(log.date, today));
      case 'diary':
        return records.diaryLogs.any((log) =>
            _isSameDay(log.date, today));
      default:
        return false;
    }
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
    // 실제 데이터 기반으로 연속 달성일 계산
    final actualConsecutiveDays = _calculateActualConsecutiveDays(user);
    final displayConsecutiveDays = actualConsecutiveDays > 0 ? actualConsecutiveDays : user.dailyRecords.consecutiveDays;
    
    // 이번 주 날짜별 목표 달성 상태 계산
    final weeklyCompletionStatus = _calculateWeeklyCompletionStatus(user);
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // 🎨 명확한 경계를 위한 개선된 그림자
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: ModernColors.modernPrimary.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
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
              final index = entry.key;
              final isCompleted = entry.value;
              final isToday = _isToday(index);
              
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
                  color: !isCompleted
                      ? (isToday 
                          ? ModernColors.modernPrimary.withOpacity(0.1)
                          : ModernColors.gray100)
                      : null,
                  border: isToday && !isCompleted
                      ? Border.all(
                          color: ModernColors.modernPrimary.withOpacity(0.3),
                          width: 2,
                        )
                      : null,
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
                      : (isToday && !isCompleted
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ModernColors.modernPrimary.withOpacity(0.6),
                                // 🎨 현재 날짜 표시 그림자
                                boxShadow: [
                                  BoxShadow(
                                    color: ModernColors.modernPrimary.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            )
                          : null),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  
  // 특정 날짜의 목표 달성 여부 확인
  bool _checkGoalCompletionForDate(String goalId, DailyRecordData records, DateTime date) {
    switch (goalId) {
      case 'steps':
        // 걸음수는 현재 데이터에서 오늘 것만 확인 가능 (과거 데이터 제한적)
        return _isSameDay(date, DateTime.now()) ? records.todaySteps >= 6000 : false;
      case 'focus':
        return _isSameDay(date, DateTime.now()) ? records.todayFocusMinutes >= 30 : false;
      case 'reading':
        return records.readingLogs.any((log) => 
          _isSameDay(log.date, date) && log.pages >= 1);
      case 'exercise':
        return records.exerciseLogs.any((log) =>
            _isSameDay(log.date, date));
      case 'diary':
        return records.diaryLogs.any((log) =>
            _isSameDay(log.date, date));
      default:
        return false;
    }
  }

  // 날짜 비교 헬퍼 메서드
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 이번 주 각 날짜별 목표 달성 상태 계산 (월-일)
  List<bool> _calculateWeeklyCompletionStatus(GlobalUser user) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // 월요일 시작
    final allGoals = ['steps', 'focus', 'reading', 'exercise', 'diary'];
    
    List<bool> weeklyStatus = [];
    
    // 월요일부터 일요일까지 7일 계산
    for (int i = 0; i < 7; i++) {
      final checkDate = startOfWeek.add(Duration(days: i));
      
      // 오늘보다 미래 날짜는 미완료로 처리
      if (checkDate.isAfter(now)) {
        weeklyStatus.add(false);
        continue;
      }
      
      // 해당 날짜에 모든 목표를 달성했는지 확인
      bool allGoalsCompleted = true;
      for (final goalId in allGoals) {
        if (!_checkGoalCompletionForDate(goalId, user.dailyRecords, checkDate)) {
          allGoalsCompleted = false;
          break;
        }
      }
      
      weeklyStatus.add(allGoalsCompleted);
    }
    
    return weeklyStatus;
  }
  
  // 실제 연속 달성일 계산 (샘플 데이터 기반)
  int _calculateActualConsecutiveDays(GlobalUser user) {
    final now = DateTime.now();
    final records = user.dailyRecords;
    final allGoals = ['steps', 'focus', 'reading', 'exercise', 'diary'];
    int consecutiveDays = 0;
    
    // 어제부터 거꾸로 확인
    for (int i = 1; i <= 30; i++) {
      final checkDate = now.subtract(Duration(days: i));
      
      // 해당 날짜에 모든 목표를 달성했는지 확인
      bool allGoalsCompleted = true;
      for (final goalId in allGoals) {
        if (!_checkGoalCompletionForDate(goalId, records, checkDate)) {
          allGoalsCompleted = false;
          break;
        }
      }
      
      if (allGoalsCompleted) {
        consecutiveDays++;
      } else {
        break; // 연속 달성이 끊어진 지점
      }
    }
    
    return consecutiveDays;
  }
  
  // 주어진 인덱스(0=월요일, 6=일요일)가 오늘인지 확인
  bool _isToday(int weekdayIndex) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1=월요일, 7=일요일
    return weekdayIndex == (todayWeekday - 1); // 0-based 인덱스로 변환
  }

}