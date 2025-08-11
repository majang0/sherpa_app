// lib/features/daily_record/widgets/simple_today_growth_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/record_colors.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import '../../../shared/providers/global_user_provider.dart';
import 'daily_quest_widget.dart';

class SimpleTodayGrowthWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<SimpleTodayGrowthWidget> createState() => _SimpleTodayGrowthWidgetState();
}

class _SimpleTodayGrowthWidgetState extends ConsumerState<SimpleTodayGrowthWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  bool _showGoalsBottomSheet = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final todayRecord = ref.watch(todayRecordProvider);
    
    return _buildEnhancedHeader(context, ref, todayRecord, user);
  }

  Widget _buildEnhancedHeader(BuildContext context, WidgetRef ref, dynamic todayRecord, dynamic user) {
    // daily_quest_widget.dart 방식으로 실제 데이터 기반 완료 상태 계산
    final records = user.dailyRecords;
    final today = DateTime.now();
    
    // 실제 달성된 목표 수 계산
    int actuallyCompletedCount = 0;
    if (records.todaySteps >= 6000) actuallyCompletedCount++;
    if (records.todayFocusMinutes >= 30) actuallyCompletedCount++;
    if (records.readingLogs.any((log) => _isSameDay(log.date, today) && log.pages >= 1)) actuallyCompletedCount++;
    if (records.diaryLogs.any((log) => _isSameDay(log.date, today))) actuallyCompletedCount++;
    if (records.exerciseLogs.any((log) => _isSameDay(log.date, today))) actuallyCompletedCount++;
    
    final totalGoals = 5;
    final completionRate = actuallyCompletedCount / totalGoals;
    final completedCount = actuallyCompletedCount;
    final isAllCompleted = actuallyCompletedCount == totalGoals;
    final canClaimReward = isAllCompleted && !user.dailyRecords.isAllGoalsRewardClaimed;
    
    // 디버깅용 로그 (Simple Today Growth Widget - completed: $actuallyCompletedCount/$totalGoals)

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RecordColors.textLight.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📋 1. 헤더 제목 섹션
          _buildHeaderTitle(),
          const SizedBox(height: 32),
          
          // 📊 2. 핵심 성과 섹션 (기존 + 목표 현황)
          _buildKeyMetrics(todayRecord, completedCount, isAllCompleted),
          const SizedBox(height: 28),
          
          // 📈 3. 목표 진행률 섹션
          _buildProgressOverview(context, completionRate, completedCount, isAllCompleted),
          const SizedBox(height: 24),
          
          // 🎁 4. 액션 버튼 섹션 (통합)
          _buildActionSection(context, ref, isAllCompleted, canClaimReward, user),
        ],
      ),
    );
  }

  // 📋 1. 헤더 제목 섹션 (미니멀 디자인)
  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 성장 브리핑',
          style: GoogleFonts.notoSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: RecordColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

      ],
    );
  }

  // 📊 2. 핵심 성과 섹션 (실제 데이터 기반 완료 상태 확인)
  Widget _buildKeyMetrics(dynamic todayRecord, int completedCount, bool isAllCompleted) {
    final user = ref.watch(globalUserProvider);
    final records = user.dailyRecords;
    final today = DateTime.now();
    
    // daily_quest_widget.dart 방식으로 실제 데이터 기반 완료 상태 확인
    final stepsGoalCompleted = records.todaySteps >= 6000;
    final focusGoalCompleted = records.todayFocusMinutes >= 30;
    final readingGoalCompleted = records.readingLogs.any((log) => 
      _isSameDay(log.date, today) && log.pages >= 1);
    
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            icon: '👟',
            label: '걸음수',
            value: '${_formatStepCount(todayRecord.stepCount)}',
            target: '6,000',
            isAchieved: stepsGoalCompleted,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildMetricItem(
            icon: '⏰',
            label: '집중 시간',
            value: '${todayRecord.focusMinutes}분',
            target: '30분',
            isAchieved: focusGoalCompleted,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildMetricItem(
            icon: '📚',
            label: '독서',
            value: '${todayRecord.readingPages}페이지',
            target: '1페이지',
            isAchieved: readingGoalCompleted,
          ),
        ),
      ],
    );
  }

  // 개별 지표 항목 (기존)
  Widget _buildMetricItem({
    required String icon,
    required String label,
    required String value,
    required String target,
    required bool isAchieved,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isAchieved ? RecordColors.success : RecordColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: RecordColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '목표: $target',
          style: GoogleFonts.notoSans(
            fontSize: 10,
            color: RecordColors.textLight,
          ),
        ),
      ],
    );
  }


  // 📈 3. 목표 진행률 섹션 (향상된 디자인)
  Widget _buildProgressOverview(BuildContext context, double completionRate, int completedCount, bool isAllCompleted) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 진행률 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '목표 진행률',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
                Text(
                  '${(completionRate * 100).round()}%',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isAllCompleted ? RecordColors.success : RecordColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 진행률 바
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: RecordColors.textLight.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: completionRate * _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isAllCompleted 
                          ? LinearGradient(
                              colors: [RecordColors.success, RecordColors.success.withOpacity(0.8)],
                            )
                          : RecordColors.primaryGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // 진행률 텍스트

            
            // 보상 정보 표시 (목표 달성 시)
            if (isAllCompleted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      RecordColors.success.withOpacity(0.1),
                      RecordColors.success.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: RecordColors.success.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: RecordColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '보상: ✨200XP + 💰50P + 🔥+0.1',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: RecordColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // 🎁 4. 액션 섹션 (통합 버튼)
  Widget _buildActionSection(BuildContext context, WidgetRef ref, bool isAllCompleted, bool canClaimReward, dynamic user) {
    if (isAllCompleted && canClaimReward) {
      return _buildClaimRewardButton(context, ref, user);
    } else if (isAllCompleted && !canClaimReward) {
      return _buildRewardCompleted();
    } else {
      return _buildViewGoalsButton();
    }
  }

  // 목표 확인 버튼 (펄스 애니메이션)
  Widget _buildViewGoalsButton() {
    return Column(
      children: [
        // 보상 정보 미리보기
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                RecordColors.primary.withOpacity(0.1),
                RecordColors.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: RecordColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: RecordColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '모든 목표 달성 시 보상',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: RecordColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '✨200XP + 💰50P + 🔥+0.1',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RecordColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // 목표 확인 버튼
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showGoalsBottomSheetModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RecordColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flag_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '오늘의 목표 확인하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 보상 받기 버튼 (NEW 배지 포함)
  Widget _buildClaimRewardButton(BuildContext context, WidgetRef ref, dynamic user) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedbackManager.heavyImpact();
          
          // 보상 받기 실행
          ref.read(globalUserProvider.notifier).claimAllGoalsReward();
          
          // 성공 피드백
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 보상을 받았습니다! ✨200XP + 💰50P + 🔥+0.1 의지력',
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: RecordColors.success,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: RecordColors.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.redeem, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체 완료 보상 받기',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '✨200 💰50 🔥0.1',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'NEW',
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 보상 수령 완료
  Widget _buildRewardCompleted() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: RecordColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RecordColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: RecordColors.success,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '오늘의 보상을 모두 받았습니다',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: RecordColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // 모달 시트 표시
  void _showGoalsBottomSheetModal() {
    if (_showGoalsBottomSheet) return;

    setState(() => _showGoalsBottomSheet = true);
    HapticFeedbackManager.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGoalsBottomSheet(),
    ).whenComplete(() {
      setState(() => _showGoalsBottomSheet = false);
    });
  }

  Widget _buildGoalsBottomSheet() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: DailyQuestWidget(),
    );
  }

  // 걸음수 포맷팅 헬퍼 메서드
  String _formatStepCount(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}K';
    }
    return steps.toString();
  }
  
  // 날짜 비교 헬퍼 메서드 (daily_quest_widget.dart와 동일)
  bool _isSameDay(DateTime date, DateTime today) {
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }
}