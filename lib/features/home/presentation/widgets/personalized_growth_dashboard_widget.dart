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

  // 통합된 헤더 + 진행률 섹션 - "오늘의 성장"과 진행률을 하나로 통합
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
          // 첫 번째 행: 셰르피와 타이틀
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 왼쪽: 셰르피
              _buildCompactSherpiSection(),
              const SizedBox(width: 12),
              // 오른쪽: 오늘의 성장 타이틀
              Text(
                '오늘의 성장',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ModernColors.modernText,
                  height: 1.2,
                ),
              ),
              // 나머지 공간
              const Spacer(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 두 번째 행: 진행률 정보
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 왼쪽: 진행률 바와 상태 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 진행률 바
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: ModernColors.softCloud,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isAllCompleted 
                                ? ModernColors.dayCompleted
                                : ModernColors.modernPrimary,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: (isAllCompleted 
                                    ? ModernColors.dayCompleted 
                                    : ModernColors.modernPrimary).withOpacity(0.3),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 상태 텍스트
                    Text(
                      isAllCompleted 
                          ? '🎉 모든 목표 완성!' 
                          : '$completedCount/$totalCount 목표 진행중',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isAllCompleted 
                            ? ModernColors.dayCompleted 
                            : ModernColors.modernText,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 오른쪽: 진행률 백분율 표시 (진행률 바와 시각적으로 정렬)
              Transform.translate(
                offset: const Offset(0, -15), // 위로 15픽셀 이동하여 진행률 바와 시각적 균형 맞춤
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isAllCompleted 
                        ? ModernColors.softDew 
                        : ModernColors.backgroundElevated,
                    shape: BoxShape.circle,
                    boxShadow: ModernColors.getElevationShadow(2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isAllCompleted 
                                ? ModernColors.dayCompleted 
                                : ModernColors.modernPrimary,
                            height: 1,
                          ),
                        ),
                        if (isAllCompleted)
                          const Text(
                            '✨',
                            style: TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      child: Container(
        padding: const EdgeInsets.all(12), // 14 → 12로 더 컴팩트하게
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18), // 20 → 18로 약간 축소
          // 🎨 셰르파 블루 감성 - 통일된 그림자
          boxShadow: [
            BoxShadow(
              color: ModernColors.modernPrimary.withOpacity(0.06),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: ModernColors.modernPrimary.withOpacity(0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // 🎨 세련된 인라인 보상 정보 (블루 감성)
            _buildCompactRewardInfo(),
            const SizedBox(height: 10), // 12 → 10으로 축소
            
            // 목표들을 1x5 행으로 배치 (완전한 크기 일관성 보장)
            Row(
              children: allGoals.map((goalId) {
                final isCompleted = _checkGoalCompletion(goalId, records);
                final index = allGoals.indexOf(goalId);
                return Expanded(
                  flex: 1, // 모든 카드에 동일한 flex 비율 명시적 적용
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < allGoals.length - 1 ? 8 : 0,
                    ),
                    child: _buildCompactGoalCard(goalId, records, isCompleted),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 10), // 12 → 10으로 축소
            
            // 보상받기 버튼 (상태별: 비활성/활성/완료)
            _buildClaimRewardButton(
              isActive: canClaimReward,
              isCompleted: isRewardClaimed,
              completedCount: completedCount,
              totalGoals: totalGoals,
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 세련된 인라인 보상 정보 (블루 감성 + 미니멀 디자인)
  Widget _buildCompactRewardInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        // 🔵 셰르파 블루 감성 - 부드러운 블루 배경
        color: ModernColors.modernPrimary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.modernPrimary.withOpacity(0.12),
          width: 0.5,
        ),
        // 🎨 미묘한 그림자로 깊이감 조성
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🏆 미니 트로피 아이콘 (24x24로 축소)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.modernPrimary,
                  ModernColors.modernPrimary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernColors.modernPrimary.withOpacity(0.2),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          
          // 📝 보상 텍스트 (인라인)
          Text(
            '전체 완료 보상',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ModernColors.modernText,
              letterSpacing: -0.1,
            ),
          ),
          
          const Spacer(),
          
          // 🎁 미니 보상 배지들 (우측 정렬)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMiniRewardBadge('✨', '200XP'),
              const SizedBox(width: 4),
              _buildMiniRewardBadge('💰', '50P'),
              const SizedBox(width: 4),
              _buildMiniRewardBadge('🔥', '0.1'),
            ],
          ),
        ],
      ),
    );
  }

  // 🎨 미니 보상 배지 (인라인용 - 블루 감성)
  Widget _buildMiniRewardBadge(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        // 🔵 셰르파 블루 감성 - 더 진한 블루로 배지 효과
        color: ModernColors.modernPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ModernColors.modernPrimary.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 9),
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: ModernColors.modernPrimary,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }

  // 보상 아이템 위젯 (기존 - 호환성 유지)
  Widget _buildRewardItem(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        // 🎨 명확한 경계를 위한 더 진한 배경색 (opacity 30% 이상)
        color: ModernColors.dayCompleted.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ModernColors.dayCompleted.withOpacity(0.2),
          width: 0.5,
        ),
        // 🎨 선명한 그림자 (blur 값 감소)
        boxShadow: [
          BoxShadow(
            color: ModernColors.dayCompleted.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 12,
              // 🎨 텍스트 그림자로 이모지 강조
              shadows: [
                Shadow(
                  color: Colors.black12,
                  offset: Offset(0, 0.5),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ModernColors.dayCompleted,
              letterSpacing: -0.1,
              // 🎨 텍스트 그림자로 가독성 향상
              shadows: [
                Shadow(
                  color: ModernColors.dayCompleted.withOpacity(0.1),
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
  
  // 3가지 상태 보상 버튼 (비활성/활성/완료)
  Widget _buildClaimRewardButton({
    required bool isActive,
    required bool isCompleted,
    required int completedCount,
    required int totalGoals,
  }) {
    // 상태 결정: 완료 > 활성 > 비활성
    String buttonText;
    Color backgroundColor;
    Color foregroundColor;
    String emoji;
    bool canClick;

    if (isCompleted) {
      // 보상 완료 상태 - 🔵 셰르파 블루 감성
      buttonText = '보상 완료';
      backgroundColor = ModernColors.modernPrimary;
      foregroundColor = Colors.white;
      emoji = '✅';
      canClick = false;
    } else if (isActive) {
      // 보상 받을 수 있는 상태 - 🎁 액티브 블루 그라데이션
      buttonText = '보상 받기';
      backgroundColor = ModernColors.modernPrimary;
      foregroundColor = Colors.white;
      emoji = '🎁';
      canClick = true;
    } else {
      // 아직 목표 미달성 상태 - 🔘 미묘한 블루 톤
      buttonText = '보상 받기';
      backgroundColor = ModernColors.modernPrimary.withOpacity(0.1);
      foregroundColor = ModernColors.modernPrimary.withOpacity(0.6);
      emoji = '';
      canClick = false;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // 14 → 12로 일관성 유지
        border: Border.all(
          color: backgroundColor.withOpacity(0.3), // 더 미묘한 경계선
          width: 0.5,
        ),
        // 🎨 셰르파 블루 감성 그림자
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withOpacity(0.08),
            blurRadius: 4,
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
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          // 🎨 슬림화: 16 → 12로 높이 25% 축소
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 14 → 12로 더 미묘하게
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            canClick 
                ? Colors.white.withOpacity(0.12) // 더 미묘한 터치 효과
                : Colors.transparent,
          ),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (emoji.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ],
            if (!isCompleted && !isActive) ...[
              const SizedBox(width: 8),
              Text(
                '($completedCount/$totalGoals)',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.inactiveText.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 컴팩트 목표 카드 (1x5 레이아웃용)
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
          color: isCompleted 
              ? ModernColors.modernPrimary.withOpacity(0.08) // 🔵 블루 감성으로 변경
              : Colors.white,
          borderRadius: BorderRadius.circular(14), // 16 → 14로 일관성 유지
          border: !isCompleted
              ? Border.all(
                  color: Colors.black.withOpacity(0.08),
                  width: 0.5,
                )
              : null,
          // 🎨 블루 감성 그림자 효과
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: ModernColors.modernPrimary.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: ModernColors.modernPrimary.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: functionColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: functionColor.withOpacity(0.05),
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
              // 아이콘
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  // 🎨 완료 상태에 따른 블루 그라데이션 적용
                  gradient: isCompleted 
                      ? LinearGradient(
                          colors: [
                            ModernColors.modernPrimary,
                            ModernColors.modernPrimary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !isCompleted ? functionColor.withOpacity(0.12) : null,
                  shape: BoxShape.circle,
                  // 🎨 아이콘 컨테이너 그림자
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: ModernColors.modernPrimary.withOpacity(0.15), // 🔵 블루 감성
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : Text(
                          goalData['icon'] ?? '🎯',
                          style: const TextStyle(
                            fontSize: 14,
                            // 🎨 이모지 그림자 효과
                            shadows: [
                              Shadow(
                                color: Colors.black12,
                                offset: Offset(0, 0.5),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              // 텍스트 (크기 일관성을 위한 고정 컨테이너)
              SizedBox(
                height: 12, // 텍스트 영역 고정 높이
                child: Center(
                  child: Text(
                    goalData['title'] ?? '목표',
                    style: GoogleFonts.notoSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isCompleted 
                          ? ModernColors.modernPrimary // 🔵 블루 감성 통일
                          : ModernColors.modernText,
                      // 🎨 텍스트 그림자로 가독성 향상
                      shadows: [
                        Shadow(
                          color: (isCompleted 
                              ? ModernColors.modernPrimary 
                              : ModernColors.modernText).withOpacity(0.1),
                          offset: const Offset(0, 0.5),
                          blurRadius: 1,
                        ),
                      ],
                      // 텍스트 기준선 고정으로 정확한 중앙 정렬
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip, // ellipsis 대신 clip으로 정확한 크기 보장
                  ),
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