// lib/features/daily_record/widgets/exercise_summary_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../core/theme/modern_colors.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import 'exercise_full_view_widget.dart';

class ExerciseSummaryWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExerciseSummaryWidget> createState() =>
      _ExerciseSummaryWidgetState();
}

class _ExerciseSummaryWidgetState extends ConsumerState<ExerciseSummaryWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _donutController;
  late Animation<double> _donutAnimation;

  // 히트맵 월 선택을 위한 상태 변수
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _donutController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _donutAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _donutController,
      curve: Curves.easeOutBack,
    ));

    Future.delayed(const Duration(milliseconds: 1200), () {
      _slideController.forward();
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      _donutController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _donutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final exerciseLogs = user.dailyRecords.exerciseLogs;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ModernColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF97316).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: const Color(0xFFF97316),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '운동 분석',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        Text(
                          '나의 운동 패턴과 선호 운동을 확인하세요',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 추가/분석 버튼
                  Row(
                    children: [
                      // 5개 이상일 때 대시보드 버튼 표시
                      if (exerciseLogs.length >= 5)
                        GestureDetector(
                          onTap: () {
                            HapticFeedbackManager.mediumImpact();
                            Navigator.pushNamed(context, '/exercise_dashboard');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF059669),
                                  const Color(0xFF047857)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF059669).withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.dashboard_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      if (exerciseLogs.length >= 5) const SizedBox(width: 8),

                      // 운동 추가 버튼
                      GestureDetector(
                        onTap: () {
                          HapticFeedbackManager.mediumImpact();
                          Navigator.pushNamed(
                            context,
                            '/exercise_selection',
                            arguments: DateTime.now(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF97316),
                                const Color(0xFFEA580C)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 최고 운동 (Top Exercise)
              if (exerciseLogs.isNotEmpty) _buildTopExercise(exerciseLogs),

              const SizedBox(height: 20),

              // 주간 운동 캘린더
              _buildWeeklyCalendar(exerciseLogs),

              const SizedBox(height: 16),

              // 전체 운동 보기 버튼
              _buildFullViewButton(),

              const SizedBox(height: 20),

              // 운동 분석 대시보드
              if (exerciseLogs.isNotEmpty)
                _buildExerciseAnalytics(exerciseLogs)
              else
                _buildEmptyState(),

              const SizedBox(height: 24),

              // 운동 기록 작성하기 버튼
              _buildAddExerciseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopExercise(List<ExerciseLog> exerciseLogs) {
    // 운동 유형별 총 시간 계산
    final exerciseMap = <String, int>{};
    for (final log in exerciseLogs) {
      exerciseMap[log.exerciseType] =
          (exerciseMap[log.exerciseType] ?? 0) + log.durationMinutes;
    }

    if (exerciseMap.isEmpty) return const SizedBox.shrink();

    // 가장 많이 한 운동 찾기
    final topExercise =
        exerciseMap.entries.reduce((a, b) => a.value > b.value ? a : b);
    final topExerciseCount =
        exerciseLogs.where((log) => log.exerciseType == topExercise.key).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF97316).withOpacity(0.15),
            const Color(0xFFEA580C).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF97316).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 메달 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFBBF24).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🏆',
                  style: const TextStyle(fontSize: 24),
                ),
                Text(
                  'TOP',
                  style: GoogleFonts.notoSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 운동 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getExerciseEmoji(topExercise.key),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topExercise.key,
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많이 한 운동',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF97316),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTopExerciseStat('${topExercise.value}분', '총 시간'),
                    const SizedBox(width: 16),
                    _buildTopExerciseStat('${topExerciseCount}회', '횟수'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopExerciseStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // 주간 운동 캘린더
  Widget _buildWeeklyCalendar(List<ExerciseLog> exerciseLogs) {
    final now = DateTime.now();
    final weekDays =
        List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 운동 현황',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map((day) => _buildWeeklyDay(day, exerciseLogs))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDay(DateTime day, List<ExerciseLog> exerciseLogs) {
    final dayExercises =
        exerciseLogs.where((log) => _isSameDay(log.date, day)).toList();
    final isToday = _isSameDay(day, DateTime.now());
    final weekdayName = ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];
    final hasExercises = dayExercises.isNotEmpty;

    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        _showDateExerciseModal(day, dayExercises);
      },
      child: Container(
        width: 40,
        height: 60,
        decoration: BoxDecoration(
          color:
              isToday ? const Color(0xFFF97316).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? const Color(0xFFF97316)
                : ModernColors.textTertiary.withOpacity(0.2),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekdayName,
              style: GoogleFonts.notoSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.day}',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? const Color(0xFFF97316)
                    : ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            if (hasExercises) ...[
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${dayExercises.length}',
                    style: GoogleFonts.notoSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ModernColors.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 전체 운동 보기 버튼
  Widget _buildFullViewButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        onPressed: () {
          HapticFeedbackManager.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseFullViewWidget(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF97316),
          side: BorderSide(
            color: const Color(0xFFF97316).withOpacity(0.3),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_view_month,
              color: const Color(0xFFF97316),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '전체 운동 보기',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF97316),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseAnalytics(List<ExerciseLog> exerciseLogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 14일 막대 차트
        _buildWeeklyBarChart(exerciseLogs),
        const SizedBox(height: 20),

        // 5회 이상 운동 시 월간 히트맵
        if (exerciseLogs.length >= 5) ...[
          _buildMonthlyHeatmap(exerciseLogs),
          const SizedBox(height: 20),
        ],

        // 기본 운동 유형별 분석
        _buildExerciseTypeAnalysis(exerciseLogs),
      ],
    );
  }

  Widget _buildTodayStatItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseTypeItem(
      String type, String emoji, int count, int totalMinutes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 운동 이모지
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF97316).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 운동 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${count}회 • ${totalMinutes}분',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 강도 표시 (간단한 막대 그래프)
          Container(
            width: 60,
            height: 8,
            decoration: BoxDecoration(
              color: ModernColors.textTertiary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (totalMinutes / 120).clamp(0.1, 1.0), // 최대 120분 기준
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFF97316), const Color(0xFFEA580C)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypeAnalysis(List<ExerciseLog> exerciseLogs) {
    // 운동 유형별 통계 계산
    final exerciseStats = <String, Map<String, dynamic>>{};

    for (final log in exerciseLogs) {
      if (!exerciseStats.containsKey(log.exerciseType)) {
        exerciseStats[log.exerciseType] = {
          'count': 0,
          'totalMinutes': 0,
          'emoji': _getExerciseEmoji(log.exerciseType),
        };
      }
      exerciseStats[log.exerciseType]!['count']++;
      exerciseStats[log.exerciseType]!['totalMinutes'] += log.durationMinutes;
    }

    // 총 시간 기준으로 정렬
    final sortedExercises = exerciseStats.entries.toList()
      ..sort(
          (a, b) => b.value['totalMinutes'].compareTo(a.value['totalMinutes']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운동 유형별 분석',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...sortedExercises.take(5).map((entry) => _buildExerciseTypeItem(
              entry.key,
              entry.value['emoji'],
              entry.value['count'],
              entry.value['totalMinutes'],
            )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '💪',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            '아직 운동 기록이 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '오늘부터 운동 습관을 시작해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ModernColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // 날짜별 운동 모달
  void _showDateExerciseModal(DateTime date, List<ExerciseLog> dayExercises) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: ModernColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF97316),
                            const Color(0xFFEA580C)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.month}월 ${date.day}일',
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          if (dayExercises.isNotEmpty)
                            Text(
                              '${dayExercises.length}개의 운동 기록',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: ModernColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 운동 기록이 있는 경우
              if (dayExercises.isNotEmpty) ...[
                if (dayExercises.length == 1) ...[
                  _buildSingleExercisePreview(dayExercises.first),
                ] else ...[
                  _buildMultipleExercisesList(dayExercises),
                ],
              ] else ...[
                // 운동 기록이 없는 경우
                _buildEmptyDayContent(date),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 단일 운동 프리뷰
  Widget _buildSingleExercisePreview(ExerciseLog exercise) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF97316).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getExerciseEmoji(exercise.exerciseType),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseType,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${exercise.durationMinutes}분',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(exercise.durationMinutes / 60).toStringAsFixed(1)}h',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF97316),
                    ),
                  ),
                ],
              ),
              if (exercise.note != null) ...[
                const SizedBox(height: 16),
                Text(
                  exercise.note!,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textPrimary,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // 액션 버튼들
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  // 상세 보기 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to exercise detail screen
                        Navigator.pushNamed(
                          context,
                          '/exercise_detail',
                          arguments: exercise,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF97316),
                        side: BorderSide(
                            color: const Color(0xFFF97316), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '상세 보기',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 수정하기 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to exercise edit screen
                        Navigator.pushNamed(
                          context,
                          '/exercise_edit',
                          arguments: exercise,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '수정하기',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 운동 기록 추가하기 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/exercise_selection',
                      arguments: exercise.date,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF97316),
                    side: BorderSide(
                      color: const Color(0xFFF97316).withOpacity(0.3),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '운동 기록 추가하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 여러 운동 목록
  Widget _buildMultipleExercisesList(List<ExerciseLog> exercises) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ModernColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ModernColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _getExerciseEmoji(exercise.exerciseType),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.exerciseType,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${exercise.durationMinutes}분',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ModernColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: ModernColors.textTertiary,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to exercise detail screen
                        Navigator.pushNamed(
                          context,
                          '/exercise_detail',
                          arguments: exercise,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // 운동 기록 추가하기 버튼
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/exercise_selection',
                  arguments: exercises.first.date,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '운동 기록 추가하기',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 빈 날짜 콘텐츠
  Widget _buildEmptyDayContent(DateTime date) {
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final isPast = date.isBefore(now.subtract(const Duration(days: 1)));
    final isFuture = date.isAfter(now);

    // 날짜별 맞춤 메시지 생성
    String emoji;
    String title;
    String subtitle;
    List<String> suggestions;

    if (isToday) {
      emoji = '💪';
      title = '오늘의 운동을 시작해보세요';
      subtitle = '건강한 하루를 위한 첫 걸음을 내딛어보세요';
      suggestions = [
        '가벼운 산책부터 시작해보세요',
        '홈트레이닝으로 근력 운동을',
        '요가로 몸과 마음을 이완시켜보세요',
        '오늘의 목표를 정해보세요'
      ];
    } else if (isPast) {
      emoji = '📝';
      title = '${date.month}월 ${date.day}일의 운동 기록';
      subtitle = '지난 운동을 기록하고 나의 성장을 확인해보세요';
      suggestions = [
        '어떤 운동을 했나요?',
        '운동 시간은 얼마나 되었나요?',
        '운동 후 기분은 어땠나요?',
        '목표는 달성했나요?'
      ];
    } else {
      emoji = '🎯';
      title = '운동 계획 세우기';
      subtitle = '미리 운동 계획을 세워두면 실천하기 쉬워요';
      suggestions = [
        '어떤 운동을 할 예정인가요?',
        '목표 시간을 정해보세요',
        '운동 파트너가 있나요?',
        '준비물을 체크해보세요'
      ];
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 메인 콘텐츠 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF97316).withOpacity(0.05),
                  const Color(0xFFEA580C).withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF97316).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 이모지와 제목
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 제안 사항들
          ...suggestions
              .map((suggestion) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ModernColors.textTertiary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ModernColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),

          const SizedBox(height: 24),

          // 운동 기록 작성하기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/exercise_selection',
                  arguments: date,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '운동 기록 작성하기',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 운동 기록 작성하기 버튼
  Widget _buildAddExerciseButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedbackManager.mediumImpact();
          Navigator.pushNamed(
            context,
            '/exercise_selection',
            arguments: DateTime.now(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97316),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: const Color(0xFFF97316).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '운동 기록 작성하기',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 같은 날짜인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 14일 막대 차트 구현
  Widget _buildWeeklyBarChart(List<ExerciseLog> exerciseLogs) {
    final now = DateTime.now();
    final days =
        List.generate(14, (index) => now.subtract(Duration(days: 13 - index)));

    // 최대 운동 시간 계산 (차트 스케일링용)
    int maxMinutes = 120; // 기본 최소값
    for (final day in days) {
      final dayMinutes = exerciseLogs
          .where((log) => _isSameDay(log.date, day))
          .fold(0, (sum, log) => sum + log.durationMinutes);
      if (dayMinutes > maxMinutes) {
        maxMinutes = dayMinutes;
      }
    }
    // 차트 높이를 위한 적절한 스케일 설정 (10분 단위로 올림)
    maxMinutes = ((maxMinutes + 9) ~/ 10) * 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: const Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '최근 14일 운동 현황',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    Text(
                      '막대를 길게 눌러 정확한 시간 확인',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 색상 레전드
          Row(
            children: [
              _buildLegendItem('회색', '30분 미만', Colors.grey),
              const SizedBox(width: 16),
              _buildLegendItem('파랑', '30-120분', const Color(0xFF3B82F6)),
              const SizedBox(width: 16),
              _buildLegendItem('금색', '120분 이상', const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 20),

          // 막대 차트
          Container(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final dayMinutes = exerciseLogs
                    .where((log) => _isSameDay(log.date, day))
                    .fold(0, (sum, log) => sum + log.durationMinutes);

                return Expanded(
                  child: Tooltip(
                    message: dayMinutes > 0
                        ? '${day.month}월 ${day.day}일: ${dayMinutes}분 운동'
                        : '',
                    preferBelow: false,
                    verticalOffset: 20,
                    decoration: BoxDecoration(
                      color: dayMinutes > 0
                          ? _getBarColor(dayMinutes)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    waitDuration: const Duration(milliseconds: 250),
                    showDuration: const Duration(seconds: 2),
                    child: GestureDetector(
                      onTap: () {
                        if (dayMinutes > 0) {
                          HapticFeedbackManager.lightImpact();
                          // 간단한 정보 표시
                          final exercisesForDay = exerciseLogs
                              .where((log) => _isSameDay(log.date, day))
                              .toList();
                          _showDateExerciseModal(day, exercisesForDay);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // 막대
                            Container(
                              width: double.infinity,
                              height: dayMinutes > 0
                                  ? math.max(
                                      4,
                                      (dayMinutes / maxMinutes * 140)
                                          .clamp(4, 140))
                                  : 2,
                              decoration: BoxDecoration(
                                color: dayMinutes > 0
                                    ? _getBarColor(dayMinutes)
                                    : ModernColors.textTertiary
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 날짜
                            Text(
                              '${day.day}',
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _isSameDay(day, now)
                                    ? const Color(0xFFF97316)
                                    : ModernColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String color, String description, Color dotColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          description,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getBarColor(int minutes) {
    if (minutes < 30) {
      return Colors.grey;
    } else if (minutes <= 120) {
      return const Color(0xFF3B82F6);
    } else {
      return const Color(0xFFF59E0B);
    }
  }

  // 월간 히트맵 구현 (5회 이상일 때)
  Widget _buildMonthlyHeatmap(List<ExerciseLog> exerciseLogs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFF7C3AED).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (제목과 설명만)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_view_month,
                  color: const Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '월간 운동 히트맵',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '한 달간 운동 패턴을 한눈에 확인하세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 월 네비게이션 (별도 영역)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // 이전 달 버튼
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMonth = DateTime(
                              _selectedMonth.year, _selectedMonth.month - 1);
                        });
                        HapticFeedbackManager.lightImpact();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: const Color(0xFF8B5CF6),
                          size: 24,
                        ),
                      ),
                    ),

                    // 중앙 월 표시
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_selectedMonth.year}년',
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: ModernColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${_selectedMonth.month}월',
                              style: GoogleFonts.notoSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 다음 달 버튼
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMonth = DateTime(
                              _selectedMonth.year, _selectedMonth.month + 1);
                        });
                        HapticFeedbackManager.lightImpact();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: const Color(0xFF8B5CF6),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 오늘 바로가기 버튼
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMonth = DateTime.now();
                    });
                    HapticFeedbackManager.lightImpact();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.today,
                          color: const Color(0xFF8B5CF6),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '오늘로 이동',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 히트맵 그리드
          _buildHeatmapGrid(exerciseLogs),

          const SizedBox(height: 20),

          // 색상 설명 (개선된 버전)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운동 시간에 따른 색상 표시',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildColorLegendItem(
                      const Color(0xFFE5E7EB),
                      '없음',
                      Colors.black54,
                    ),
                    _buildColorLegendItem(
                      const Color(0xFF8B5CF6).withOpacity(0.3),
                      '적음',
                      Colors.white,
                    ),
                    _buildColorLegendItem(
                      const Color(0xFF8B5CF6).withOpacity(0.6),
                      '보통',
                      Colors.white,
                    ),
                    _buildColorLegendItem(
                      const Color(0xFF8B5CF6),
                      '많음',
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(List<ExerciseLog> exerciseLogs) {
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final days = List.generate(
      endOfMonth.day,
      (index) => DateTime(_selectedMonth.year, _selectedMonth.month, index + 1),
    );

    return Column(
      children: [
        // 요일 헤더
        Row(
          children: ['월', '화', '수', '목', '금', '토', '일']
              .map((day) => Expanded(
                    child: Text(
                      day,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),

        // 주별 그리드
        ...List.generate(6, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayOffset = weekIndex * 7 + dayIndex;
                final adjustedDayOffset =
                    dayOffset - (startOfMonth.weekday - 1);

                if (adjustedDayOffset < 0 ||
                    adjustedDayOffset >= endOfMonth.day) {
                  return const Expanded(child: SizedBox());
                }

                final date = DateTime(_selectedMonth.year, _selectedMonth.month,
                    adjustedDayOffset + 1);
                final dayExercises = exerciseLogs
                    .where((log) => _isSameDay(log.date, date))
                    .toList();

                final isToday = _isSameDay(date, DateTime.now());

                return Expanded(
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(dayExercises.length),
                      borderRadius: BorderRadius.circular(6),
                      border: isToday
                          ? Border.all(
                              color: const Color(0xFF8B5CF6),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w600,
                          color: dayExercises.isNotEmpty
                              ? Colors.white
                              : ModernColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Color _getHeatmapColor(int exerciseCount) {
    if (exerciseCount == 0) {
      return ModernColors.borderLight;
    } else if (exerciseCount == 1) {
      return const Color(0xFF8B5CF6).withOpacity(0.3);
    } else if (exerciseCount == 2) {
      return const Color(0xFF8B5CF6).withOpacity(0.6);
    } else {
      return const Color(0xFF8B5CF6);
    }
  }

  Widget _buildColorLegendItem(Color color, String label, Color textColor) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getExerciseEmoji(String exerciseType) {
    switch (exerciseType) {
      case '러닝':
        return '🏃';
      case '걷기':
        return '🚶';
      case '자전거':
        return '🚴';
      case '수영':
        return '🏊';
      case '요가':
        return '🧘';
      case '헬스':
        return '🏋️';
      case '필라테스':
        return '🤸';
      case '테니스':
        return '🎾';
      case '축구':
        return '⚽';
      case '농구':
        return '🏀';
      case '클라이밍':
        return '🧗';
      case '등산':
        return '🥾';
      case '배드민턴':
        return '🏸';
      case '골프':
        return '⛳';
      default:
        return '💪';
    }
  }
}

// 도넛 차트 페인터
class DonutChartPainter extends CustomPainter {
  final double progress;
  final int minutes;

  DonutChartPainter({
    required this.progress,
    required this.minutes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = ModernColors.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행 원
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: progress >= 1.0
            ? [const Color(0xFF059669), const Color(0xFF047857)]
            : [const Color(0xFFF97316), const Color(0xFFEA580C)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // 중앙 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${minutes}',
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: progress >= 1.0
                  ? const Color(0xFF059669)
                  : const Color(0xFFF97316),
            ),
          ),
          TextSpan(
            text: '분',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
