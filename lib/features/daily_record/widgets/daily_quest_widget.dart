// lib/features/daily_record/widgets/daily_quest_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_colors.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import '../presentation/screens/diary_write_edit_screen.dart';

class DailyQuestWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<DailyQuestWidget> createState() => _DailyQuestWidgetState();
}

class _DailyQuestWidgetState extends ConsumerState<DailyQuestWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            // ✅ 스크롤 가능한 몽체로 수정
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildQuestList(),
                    _buildCompleteAllButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: ModernColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: ModernColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flag_outlined,
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
                      '오늘의 목표',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '성장을 위한 5가지 일일 목표',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: ModernColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: ModernColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestList() {
    // ✅ 글로벌 Provider에서 일일 목표 가져오기
    final user = ref.watch(globalUserProvider);
    final goals = user.dailyRecords.dailyGoals;

    // ✅ 목표 상태를 실제 데이터와 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalUserProvider.notifier).syncDailyGoalsWithData();
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: goals.map((goal) => _buildQuestItem(goal)).toList(),
      ),
    );
  }

  // ✨ 실제 데이터 기반 목표 달성 여부 계산
  bool _isGoalAchieved(String goalId, dynamic user) {
    final records = user.dailyRecords;
    final today = DateTime.now();
    
    switch (goalId) {
      case 'steps':
        return records.todaySteps >= 6000;
      case 'focus':
        return records.todayFocusMinutes >= 30;
      case 'reading':
        return records.readingLogs.any((log) => 
          _isToday(log.date, today) && log.pages >= 1);
      case 'diary':
        return records.diaryLogs.any((log) => 
          _isToday(log.date, today));
      case 'exercise':
        return records.exerciseLogs.any((log) => 
          _isToday(log.date, today));
      default:
        return false;
    }
  }
  
  // 날짜 비교 헬퍼 메서드
  bool _isToday(DateTime date, DateTime today) {
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }
  
  // ✨ 실제 달성 수치 반환
  String _getAchievementStatus(String goalId, dynamic user) {
    final records = user.dailyRecords;
    final today = DateTime.now();
    
    switch (goalId) {
      case 'steps':
        return '${records.todaySteps.toStringAsFixed(0)} / 6,000걸음';
      case 'focus':
        return '${records.todayFocusMinutes}분 / 30분';
      case 'reading':
        final todayPages = records.readingLogs
          .where((log) => _isToday(log.date, today))
          .fold(0, (sum, log) => sum + log.pages);
        return '$todayPages페이지 / 1페이지';
      case 'diary':
        final hasDiary = records.diaryLogs.any((log) => _isToday(log.date, today));
        return hasDiary ? '완료' : '미작성';
      case 'exercise':
        final hasExercise = records.exerciseLogs.any((log) => _isToday(log.date, today));
        return hasExercise ? '완료' : '미기록';
      default:
        return '미완료';
    }
  }

  Widget _buildQuestItem(DailyGoal goal) {
    // ✨ 실제 데이터로 목표 달성 여부 확인
    final user = ref.watch(globalUserProvider);
    final isActuallyAchieved = _isGoalAchieved(goal.id, user);
    final achievementStatus = _getAchievementStatus(goal.id, user);
    
    // ✅ 목표 상태와 실제 데이터가 다르면 로그 출력
    if (goal.isCompleted != isActuallyAchieved) {
      print('⚠️ 목표 상태 불일치 - ${goal.id}: isCompleted=${goal.isCompleted}, actuallyAchieved=${isActuallyAchieved}');
    }
    
    // 실제 데이터 기반으로 표시 (더 정확함)
    final shouldShowAsCompleted = isActuallyAchieved;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: shouldShowAsCompleted 
            ? ModernColors.success.withOpacity(0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: shouldShowAsCompleted
              ? ModernColors.success.withOpacity(0.3)
              : ModernColors.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: shouldShowAsCompleted 
              ? null 
              : () => _handleGoalTap(goal.id),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: shouldShowAsCompleted
                        ? ModernColors.success
                        : ModernColors.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: shouldShowAsCompleted
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          )
                        : Text(
                            goal.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // 텍스트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: shouldShowAsCompleted
                              ? ModernColors.success
                              : ModernColors.textPrimary,
                          decoration: shouldShowAsCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // ✨ 실제 달성 상태 표시
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: shouldShowAsCompleted
                              ? ModernColors.success.withOpacity(0.15)
                              : ModernColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          achievementStatus,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: shouldShowAsCompleted
                                ? ModernColors.success
                                : ModernColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        shouldShowAsCompleted 
                            ? _getCompletionMessage(goal.id)
                            : goal.description,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: shouldShowAsCompleted 
                              ? ModernColors.success.withOpacity(0.8)
                              : ModernColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                      if (!shouldShowAsCompleted) ...[
                        const SizedBox(height: 8),
                        Text(
                          '클릭하여 ${_getActionText(goal.id)}',
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            color: ModernColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 완료 상태 아이콘
                if (shouldShowAsCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ModernColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: ModernColors.success,
                      size: 20,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: ModernColors.primary,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteAllButton() {
    // ✨ 실제 데이터 기반 진행률 계산
    final user = ref.watch(globalUserProvider);
    final goals = user.dailyRecords.dailyGoals;
    
    // 실제 달성된 목표 수 계산
    int actuallyCompletedCount = 0;
    for (final goal in goals) {
      if (_isGoalAchieved(goal.id, user)) {
        actuallyCompletedCount++;
      }
    }
    
    final totalCount = goals.length;
    final allActuallyCompleted = actuallyCompletedCount == totalCount;
    final completionRate = actuallyCompletedCount / totalCount;
    
    // 보상 수령 상태 확인
    final isRewardClaimed = user.dailyRecords.isAllGoalsRewardClaimed;
    
    // ✅ 실제 달성 상태와 목표 상태가 다르면 로그 출력
    final storedCompletedCount = goals.where((g) => g.isCompleted).length;
    if (storedCompletedCount != actuallyCompletedCount) {
      print('⚠️ 전체 목표 진행률 불일치 - stored: $storedCompletedCount, actual: $actuallyCompletedCount');
    }

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 진행률 표시
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: allActuallyCompleted
                  ? ModernColors.success.withOpacity(0.08)
                  : ModernColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: allActuallyCompleted
                    ? ModernColors.success.withOpacity(0.3)
                    : ModernColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      allActuallyCompleted ? Icons.celebration : Icons.emoji_events,
                      color: allActuallyCompleted 
                          ? ModernColors.success 
                          : ModernColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        allActuallyCompleted ? '🎉 모든 목표 달성!' : '목표 진행률',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: allActuallyCompleted
                              ? ModernColors.success
                              : ModernColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: allActuallyCompleted
                            ? ModernColors.success
                            : ModernColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$actuallyCompletedCount/$totalCount',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 진행률 바
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: ModernColors.textTertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        width: MediaQuery.of(context).size.width * completionRate * 0.75, // 여백 고려
                        decoration: BoxDecoration(
                          color: allActuallyCompleted ? ModernColors.success : ModernColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  allActuallyCompleted 
                      ? '모든 목표를 달성했어요! 대단해요!'
                      : '${(completionRate * 100).round()}% 달성 • 남은 목표 ${totalCount - actuallyCompletedCount}개',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: allActuallyCompleted ? ModernColors.success : ModernColors.textSecondary,
                    fontWeight: allActuallyCompleted ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (allActuallyCompleted && !isRewardClaimed) ...[
                  // 보상 정보 표시
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ModernColors.success.withOpacity(0.1),
                          ModernColors.success.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ModernColors.success.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🎉 완주 보상',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRewardItem('✨', '200XP'),
                            _buildRewardItem('💰', '50P'),
                            _buildRewardItem('🔥', '+0.1 의지력'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 보상 받기 버튼
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // ✨ 실제 보상 수령 로직
                        HapticFeedbackManager.heavyImpact();
                        ref.read(globalUserProvider.notifier).claimAllGoalsReward();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🎉 모든 목표 달성 보상을 받았어요! ✨200XP + 💰50P + 🔥+0.1',
                              style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: ModernColors.success,
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                        
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernColors.success,
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
                          const Icon(Icons.redeem, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '보상 받기',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (allActuallyCompleted && isRewardClaimed) ...[
                  // 이미 보상을 받은 경우
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: ModernColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ModernColors.success.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: ModernColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '보상을 모두 받았습니다',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // 목표가 아직 완료되지 않은 경우 - 보상 정보 표시
                  const SizedBox(height: 16),
                  Text(
                    '전체 완료 시 보상',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '✨ 200XP  +  💰 50P  +  🔥 +0.1 의지력',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 목표 클릭 시 처리 (화면 이동 또는 팝업)
  void _handleGoalTap(String goalId) {
    HapticFeedbackManager.mediumImpact();
    
    switch (goalId) {
      case 'steps':
        _showInfoPopup(
          icon: '👟',
          title: '걸음수 목표',
          message: '하루 6,000걸음을 걸어보세요!\n산책이나 일상 활동을 통해 달성할 수 있어요.',
          actionText: '확인',
        );
        break;
      case 'focus':
        _showInfoPopup(
          icon: '⏰',
          title: '집중 시간 목표',
          message: '하루 30분 이상 집중해보세요!\n다양한 학습이나 작업에 집중해보세요.',
          actionText: '확인',
        );
        break;
      case 'diary':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryWriteEditScreen(),
          ),
        );
        break;
      case 'exercise':
        Navigator.pushNamed(context, '/exercise_record');
        break;
      case 'reading':
        Navigator.pushNamed(context, '/reading_record');
        break;
      default:
        // 기존 수동 완료 방식 (더 이상 사용하지 않음)
        break;
    }
  }

  /// 정보 팝업 표시 (걸음수, 집중시간)
  void _showInfoPopup({
    required String icon,
    required String title,
    required String message,
    required String actionText,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: ModernColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionText,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 목표별 완료 메시지
  String _getCompletionMessage(String goalId) {
    switch (goalId) {
      case 'steps':
        return '오늘 걸음수 목표를 달성했어요! 훌륭해요! 🎉';
      case 'focus':
        return '오늘 집중 시간 목표를 달성했어요! 대단해요! 🎯';
      case 'diary':
        return '오늘 일기를 작성했어요! 하루를 기록했네요! 📝';
      case 'exercise':
        return '오늘 운동을 기록했어요! 건강하게 살아가세요! 💪';
      case 'reading':
        return '오늘 독서를 기록했어요! 지식이 늘었네요! 📚';
      default:
        return '목표를 달성했어요! 잘했어요! 🎆';
    }
  }

  /// 목표별 액션 텍스트
  String _getActionText(String goalId) {
    switch (goalId) {
      case 'steps':
        return '걸음수 확인하기';
      case 'focus':
        return '집중시간 확인하기';
      case 'diary':
        return '일기 작성하기';
      case 'exercise':
        return '운동 기록하기';
      case 'reading':
        return '독서 기록하기';
      default:
        return '목표 완료하기';
    }
  }

  /// 보상 아이템 위젯
  Widget _buildRewardItem(String icon, String text) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: ModernColors.success.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ModernColors.success,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 기존 수동 완료 메서드는 실제 데이터 기반으로 대체됨

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
