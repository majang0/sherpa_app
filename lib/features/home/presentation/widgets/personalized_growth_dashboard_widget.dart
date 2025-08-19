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
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: ModernColors.modernSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ModernColors.modernText.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernHeader(user),
            _buildProgressSection(dailyGoals),
            _buildGoalsGrid(dailyGoals),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 헤더 섹션 - 원래 디자인 복구 (셰르피 포함)
  Widget _buildModernHeader(GlobalUser user) {
    final currentTitle = ref.watch(globalUserTitleProvider);
    final levelProgress = ref.watch(userLevelProgressProvider);
    final totalPoints = ref.watch(globalTotalPointsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.modernPrimary,
            ModernColors.modernPrimary.withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 레벨 & 이름 행
                Row(
                  children: [
                    // 레벨 배치
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                              'Lv',
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: ModernColors.modernPrimary.withOpacity(0.8),
                                height: 1,
                              ),
                            ),
                            Text(
                              '${user.level}',
                              style: GoogleFonts.notoSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: ModernColors.modernPrimary,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 사용자 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ModernColors.modernSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentTitle.icon,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currentTitle.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ModernColors.modernPrimary,
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
                const SizedBox(height: 16),
                // 경험치 바
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '다음 레벨까지',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${levelProgress.currentLevelExp}/${levelProgress.requiredExpForNextLevel} XP',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: levelProgress.progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 하단 스탯
                Row(
                  children: [
                    Flexible(
                      child: _buildHeaderStat(
                        icon: Icons.local_fire_department,
                        label: '연속',
                        value: '${user.dailyRecords.consecutiveDays}일',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildHeaderStat(
                        icon: Icons.monetization_on,
                        label: '포인트',
                        value: '$totalPoints P',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildHeaderStat(
                        icon: Icons.emoji_events,
                        label: '배치',
                        value: '${user.ownedBadgeIds.length}개',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 오른쪽: 셰르피
          _buildSherpiSection(levelProgress.progress),
        ],
      ),
    );
  }

  // 헤더 스탯 위젯
  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: ModernColors.modernPrimary.withOpacity(0.8),
            size: 14,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    color: ModernColors.modernTextSecondary,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.modernText,
                      height: 1,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 셰르피 섹션
  Widget _buildSherpiSection(double progress) {
    return GestureDetector(
      onTap: () {
        ref.read(sherpiProvider.notifier).showMessage(
          context: SherpiContext.encouragement,
          emotion: SherpiEmotion.cheering,
        );
        HapticFeedbackManager.lightImpact();
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ModernColors.modernPrimary.withOpacity(0.05),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Transform.scale(
                  scale: 2.2,
                  child: Image.asset(
                    SherpiEmotion.cheering.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getSherpiMessage(progress),
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: ModernColors.modernPrimary,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 셰르피 메시지
  String _getSherpiMessage(double progress) {
    if (progress < 0.25) {
      return "천천히\n올라가요!";
    } else if (progress < 0.5) {
      return "좋은\n속도예요!";
    } else if (progress < 0.75) {
      return "멋진\n성장이에요!";
    } else if (progress < 0.9) {
      return "거의\n다 왔어요!";
    } else {
      return "축하해요\n레벨업!";
    }
  }

  // 진행률 섹션
  Widget _buildProgressSection(List<DailyGoal> dailyGoals) {
    final user = ref.watch(globalUserProvider);
    final records = user.dailyRecords;
    
    int completedCount = 0;
    for (final goal in dailyGoals) {
      if (_checkGoalCompletion(goal.id, records)) {
        completedCount++;
      }
    }
    
    final totalCount = dailyGoals.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.modernBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernText.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 목표',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.modernText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progress >= 1.0 
                      ? ModernColors.modernSuccess 
                      : ModernColors.modernPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$completedCount/$totalCount',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: progress >= 1.0 
                        ? Colors.white 
                        : ModernColors.modernPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 진행률 바
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: ModernColors.modernBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: progress >= 1.0 
                      ? ModernColors.modernSuccess 
                      : ModernColors.modernPrimary,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: (progress >= 1.0 
                          ? ModernColors.modernSuccess 
                          : ModernColors.modernPrimary).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            progress >= 1.0 
                ? '🎉 모든 목표를 달성했어요!' 
                : '남은 목표 ${totalCount - completedCount}개',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: progress >= 1.0 
                  ? ModernColors.modernSuccess 
                  : ModernColors.modernTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 목표 그리드
  Widget _buildGoalsGrid(List<DailyGoal> dailyGoals) {
    final user = ref.watch(globalUserProvider);
    final records = user.dailyRecords;
    
    // 걸음수를 제외한 나머지 목표들
    final gridGoals = dailyGoals.where((goal) => goal.id != 'steps').toList();
    
    return Column(
      children: [
        // 걸음수 카드 (가로형)
        _buildStepsCard(records),
        const SizedBox(height: 12),
        
        // 나머지 목표들 2x2 그리드
        if (gridGoals.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: gridGoals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(gridGoals[index], records);
              },
            ),
          ),
      ],
    );
  }

  // 걸음수 카드
  Widget _buildStepsCard(DailyRecordData records) {
    final todaySteps = records.todaySteps;
    final progress = (todaySteps / 6000).clamp(0.0, 1.0);
    final isCompleted = todaySteps >= 6000;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted 
            ? ModernColors.modernSuccess.withOpacity(0.08)
            : ModernColors.modernSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted 
              ? ModernColors.modernSuccess.withOpacity(0.2)
              : ModernColors.modernBackground,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernText.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? ModernColors.modernSuccess 
                  : ModernColors.modernPrimary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (isCompleted 
                      ? ModernColors.modernSuccess 
                      : ModernColors.modernPrimary).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_walk,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '걸음수',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCompleted 
                            ? ModernColors.modernSuccess 
                            : ModernColors.modernText,
                      ),
                    ),
                    Text(
                      '$todaySteps / 6,000',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCompleted 
                            ? ModernColors.modernSuccess 
                            : ModernColors.modernTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: ModernColors.modernBackground,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? ModernColors.modernSuccess 
                            : ModernColors.modernPrimary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (isCompleted)
            Container(
              margin: const EdgeInsets.only(left: 12),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ModernColors.modernSuccess,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.modernSuccess.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  // 개별 목표 카드 (그리드용)
  Widget _buildGoalCard(DailyGoal goal, DailyRecordData records) {
    final isCompleted = _checkGoalCompletion(goal.id, records);
    final functionColor = ModernColors.getFunctionColor(goal.id);
    
    return GestureDetector(
      onTap: () {
        if (!isCompleted) {
          _navigateToRecordScreen(goal.id);
        }
        HapticFeedbackManager.lightImpact();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted 
              ? ModernColors.modernSuccess.withOpacity(0.08)
              : ModernColors.modernSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted 
                ? ModernColors.modernSuccess.withOpacity(0.2)
                : functionColor.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ModernColors.modernText.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? ModernColors.modernSuccess 
                          : functionColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted 
                              ? ModernColors.modernSuccess 
                              : functionColor).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        goal.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ModernColors.modernSuccess,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ModernColors.modernSuccess.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
              ),
              
              const Spacer(),
              
              Text(
                goal.title,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted 
                      ? ModernColors.modernSuccess 
                      : ModernColors.modernText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                _getGoalStatusText(goal.id, records),
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: isCompleted 
                      ? ModernColors.modernSuccess.withOpacity(0.8)
                      : ModernColors.modernTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
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

  // 날짜 비교 헬퍼 메서드
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 목표별 상태 텍스트 반환
  String _getGoalStatusText(String goalId, DailyRecordData records) {
    switch (goalId) {
      case 'steps':
        if (records.todaySteps >= 6000) {
          return '완료! ${records.todaySteps}걸음';
        }
        return '${records.todaySteps}/6000 걸음';

      case 'focus':
        if (records.todayFocusMinutes >= 30) {
          return '완료! ${records.todayFocusMinutes}분 집중';
        }
        return '${records.todayFocusMinutes}/30분';

      case 'reading':
        if (records.todayReadingPages > 0) {
          return '완료! ${records.todayReadingPages}페이지 읽음';
        }
        return '오늘의 독서를 기록하세요';

      case 'exercise':
        final todayExercise = records.exerciseLogs
            .where((log) => _isSameDay(log.date, DateTime.now()))
            .toList();
        if (todayExercise.isNotEmpty) {
          final totalMinutes = todayExercise.fold(0,
                  (sum, log) => sum + log.durationMinutes);
          return '완료! ${totalMinutes}분 운동';
        }
        return '운동을 기록하세요';

      case 'diary':
        final todayDiary = records.diaryLogs
            .where((log) => _isSameDay(log.date, DateTime.now()))
            .toList();
        if (todayDiary.isNotEmpty) {
          return '완료! 일기 작성함';
        }
        return '오늘의 일기를 작성하세요';

      default:
        return '시작하세요';
    }
  }
}