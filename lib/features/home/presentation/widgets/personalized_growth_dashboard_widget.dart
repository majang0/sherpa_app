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
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: ModernColors.softGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: ModernColors.getElevationShadow(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntegratedHeaderSection(user, dailyGoals),
            const SizedBox(height: 12),
            _buildGoalsGrid(dailyGoals),
            const SizedBox(height: 12),
            // 새로운 스트릭 & 주간 현황 섹션
            _buildStreakAndWeeklySection(user),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: ModernColors.dreamyGradient,
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
                  fontSize: 22,
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
                            gradient: isAllCompleted 
                                ? ModernColors.rewardGradient
                                : ModernColors.primaryGradient,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: (isAllCompleted 
                                    ? ModernColors.reward 
                                    : ModernColors.modernPrimary).withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
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
                            ? ModernColors.reward 
                            : ModernColors.modernText,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 오른쪽: 진행률 백분율 표시 (진행률 바와 시각적으로 정렬)
              Transform.translate(
                offset: const Offset(0, -8), // 위로 8픽셀 이동하여 진행률 바와 시각적 균형 맞춤
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isAllCompleted 
                          ? ModernColors.reward.withOpacity(0.3) 
                          : ModernColors.modernPrimary.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 4,
                        offset: const Offset(0, -1),
                      ),
                      BoxShadow(
                        color: ModernColors.shadowBase.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                                ? ModernColors.reward 
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
      child: Container(
        width: 58,
        height: 58,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: ModernColors.warmGradient,
          shape: BoxShape.circle,
          boxShadow: ModernColors.getElevationShadow(1),
        ),
        child: Center(
          child: Transform.scale(
            scale: 1.6,
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
    
    return Column(
      children: [
        // 전체 완료 보상 표시 (항상 표시)
        _buildRewardInfoCard(),
        const SizedBox(height: 12),
          
        // 1x5 가로 목표 레이아웃
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: ModernColors.dreamyGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: ModernColors.getElevationShadow(1),
            ),
            child: Column(
              children: [
                // 목표들을 1x5 행으로 배치
                Row(
                  children: allGoals.map((goalId) {
                    final isCompleted = _checkGoalCompletion(goalId, records);
                    final index = allGoals.indexOf(goalId);
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < allGoals.length - 1 ? 8 : 0,
                        ),
                        child: _buildCompactGoalCard(goalId, records, isCompleted),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 14),
                
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
        ),
      ],
    );
  }

  // 보상 정보 카드 (전체 완료시에만 표시)
  Widget _buildRewardInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ModernColors.warmGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernColors.getElevationShadow(2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ModernColors.modernSuccess,
              shape: BoxShape.circle,
              boxShadow: ModernColors.getElevationShadow(1),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '전체 완료 보상',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.modernText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '✨200XP + 💰50P + 🔥+0.1 의지력',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.modernTextSecondary,
                  ),
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
      // 보상 완료 상태
      buttonText = '보상 완료';
      backgroundColor = ModernColors.modernSuccess;
      foregroundColor = Colors.white;
      emoji = '✅';
      canClick = false;
    } else if (isActive) {
      // 보상 받을 수 있는 상태
      buttonText = '보상 받기';
      backgroundColor = ModernColors.reward;
      foregroundColor = Colors.white;
      emoji = '🎁';
      canClick = true;
    } else {
      // 아직 목표 미달성 상태
      buttonText = '보상 받기';
      backgroundColor = ModernColors.inactive;
      foregroundColor = ModernColors.inactiveText;
      emoji = '';
      canClick = false;
    }

    return Container(
      width: double.infinity,
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: canClick ? 2 : 0,
          shadowColor: canClick 
              ? backgroundColor.withOpacity(0.3) 
              : Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            canClick 
                ? Colors.white.withOpacity(0.2)
                : ModernColors.inactiveText.withOpacity(0.1),
          ),
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
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isCompleted 
              ? ModernColors.modernSuccess.withOpacity(0.08)
              : ModernColors.softPearl,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: ModernColors.modernSuccess.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: functionColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? ModernColors.modernSuccess 
                      : functionColor.withOpacity(0.15),
                  shape: BoxShape.circle,
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
                          style: const TextStyle(fontSize: 14),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              // 텍스트
              Text(
                goalData['title'] ?? '목표',
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isCompleted 
                      ? ModernColors.modernSuccess 
                      : ModernColors.modernText,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 목표 데이터 반환
  Map<String, String> _getGoalData(String goalId) {
    switch (goalId) {
      case 'steps':
        return {'icon': '👟', 'title': '걸음수'};
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernColors.getElevationShadow(1),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 - 연속 달성 텍스트
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 18,
                color: ModernColors.modernPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                '$displayConsecutiveDays일 연속 달성',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.modernText,
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
              
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                      ? ModernColors.modernPrimary
                      : (isToday 
                          ? ModernColors.modernPrimary.withOpacity(0.1)
                          : ModernColors.gray100),
                  border: isToday && !isCompleted
                      ? Border.all(
                          color: ModernColors.modernPrimary.withOpacity(0.3),
                          width: 2,
                        )
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