// lib/features/daily_record/presentation/screens/exercise_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/record_colors.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/widgets/sherpa_button.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/utils/calorie_calculator.dart';

class ExerciseDashboardScreen extends ConsumerStatefulWidget {
  const ExerciseDashboardScreen({super.key});

  @override
  ConsumerState<ExerciseDashboardScreen> createState() => _ExerciseDashboardScreenState();
}

class _ExerciseDashboardScreenState extends ConsumerState<ExerciseDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalUser = ref.watch(globalUserProvider);
    final exerciseLogs = globalUser.dailyRecords.exerciseLogs;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: SherpaCleanAppBar(
        title: '운동 대시보드',
        backgroundColor: const Color(0xFFF8FAFC),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.pushNamed(context, '/exercise_analytics'),
            tooltip: '상세 분석',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 요약 통계 카드들
              _buildSummaryStats(exerciseLogs).animate().slide(duration: 600.ms, delay: 100.ms),
              
              const SizedBox(height: 24),
              
              // 운동 타입별 분포 차트
              _buildExerciseTypeChart(exerciseLogs).animate().slide(duration: 600.ms, delay: 200.ms),
              
              const SizedBox(height: 24),
              
              // Smart Insights
              _buildSmartInsights(exerciseLogs).animate().slide(duration: 600.ms, delay: 300.ms),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActions().animate().slide(duration: 600.ms, delay: 400.ms),
              
              const SizedBox(height: 24),
              
              // 최근 운동 기록
              _buildRecentExercises(exerciseLogs).animate().slide(duration: 600.ms, delay: 500.ms),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStats(List<ExerciseLog> exerciseLogs) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    
    // 이번 주 운동 통계
    final thisWeekExercises = exerciseLogs.where((log) => 
      log.date.isAfter(weekStart.subtract(const Duration(days: 1)))
    ).toList();
    
    // 이번 달 운동 통계
    final thisMonthExercises = exerciseLogs.where((log) => 
      log.date.isAfter(monthStart.subtract(const Duration(days: 1)))
    ).toList();
    
    final weeklyMinutes = thisWeekExercises.fold<int>(0, (sum, log) => sum + log.durationMinutes);
    final monthlyCount = thisMonthExercises.length;
    final avgDuration = exerciseLogs.isNotEmpty 
        ? exerciseLogs.fold<int>(0, (sum, log) => sum + log.durationMinutes) ~/ exerciseLogs.length
        : 0;
    
    // 개인 기록 계산
    final longestSession = exerciseLogs.isNotEmpty 
        ? exerciseLogs.map((e) => e.durationMinutes).reduce((a, b) => a > b ? a : b)
        : 0;
    final totalCalories = _calculateTotalCalories(exerciseLogs);
    final currentStreak = _calculateCurrentStreak(exerciseLogs);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '나의 운동 현황',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
              if (currentStreak > 0) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [RecordColors.success, RecordColors.success.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currentStreak}일 연속',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 주요 통계 (2x2 그리드)
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  '이번 주 운동',
                  '${weeklyMinutes}분',
                  '목표: 300분',
                  Icons.timer_outlined,
                  RecordColors.primary,
                  weeklyMinutes / 300.0, // 주간 목표 300분 가정
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedStatCard(
                  '이번 달 운동',
                  '${monthlyCount}회',
                  '목표: 12회',
                  Icons.fitness_center,
                  RecordColors.secondary,
                  monthlyCount / 12.0, // 월간 목표 12회 가정
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  '개인 최고기록',
                  '${longestSession}분',
                  '최장 운동시간',
                  Icons.emoji_events,
                  RecordColors.warning,
                  null, // 프로그레스 바 없음
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedStatCard(
                  '총 소모 칼로리',
                  '${totalCalories}kcal',
                  '${exerciseLogs.length}회 운동',
                  Icons.local_fire_department,
                  RecordColors.error,
                  null, // 프로그레스 바 없음
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard(
    String title, 
    String value, 
    String subtitle, 
    IconData icon, 
    Color color,
    double? progressValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              if (progressValue != null && progressValue > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: progressValue >= 1.0 ? RecordColors.success : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(progressValue.clamp(0.0, 1.0) * 100).toInt()}%',
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: progressValue >= 1.0 ? Colors.white : color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: RecordColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: RecordColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: RecordColors.textSecondary,
            ),
          ),
          
          // Progress bar if progress value is provided
          if (progressValue != null) ...[
            const SizedBox(height: 8),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressValue.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: progressValue >= 1.0 ? RecordColors.success : color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseTypeChart(List<ExerciseLog> exerciseLogs) {
    if (exerciseLogs.isEmpty) {
      return _buildEmptyChart();
    }

    // 운동 타입별 횟수 계산
    final typeCountMap = <String, int>{};
    for (final log in exerciseLogs) {
      typeCountMap[log.exerciseType] = (typeCountMap[log.exerciseType] ?? 0) + 1;
    }

    final sortedEntries = typeCountMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: RecordColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart_outline,
                  color: RecordColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 타입별 분포',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // 파이차트
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _buildPieChartSections(sortedEntries),
                    ),
                  ),
                ),
                
                // 범례
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sortedEntries.take(5).map((entry) {
                      final color = _getExerciseColor(entry.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${entry.key} (${entry.value})',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: RecordColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: RecordColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '운동 기록이 없습니다',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: RecordColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 운동을 기록해보세요!',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: RecordColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<MapEntry<String, int>> entries) {
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    
    return entries.take(5).map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        color: _getExerciseColor(entry.key),
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildSmartInsights(List<ExerciseLog> exerciseLogs) {
    if (exerciseLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    final insights = _generateInsights(exerciseLogs);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: RecordColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: RecordColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '스마트 인사이트',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 인사이트 카드들
          ...insights.map((insight) => _buildInsightItem(
            insight['icon'] as IconData,
            insight['title'] as String,
            insight['description'] as String,
            insight['color'] as Color,
          )),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: RecordColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: RecordColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: RecordColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '빠른 실행',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: SherpaButton(
                  text: '운동 기록하기',
                  onPressed: () {
                    HapticFeedbackManager.lightImpact();
                    Navigator.pushNamed(
                      context, 
                      '/daily_record',
                    );
                  },
                  backgroundColor: RecordColors.primary,
                  height: 48,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SherpaButton(
                  text: '상세 분석',
                  onPressed: () {
                    HapticFeedbackManager.lightImpact();
                    Navigator.pushNamed(context, '/exercise_analytics');
                  },
                  backgroundColor: RecordColors.secondary,
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExercises(List<ExerciseLog> exerciseLogs) {
    final recentExercises = exerciseLogs.take(5).toList();
    
    if (recentExercises.isEmpty) {
      return _buildEmptyRecentExercises();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                '최근 운동 기록',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 전체 운동 기록 화면으로 이동
                },
                child: Text(
                  '전체보기',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: RecordColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...recentExercises.map((exercise) => _buildExerciseItem(exercise)),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(ExerciseLog exercise) {
    final exerciseColor = _getExerciseColor(exercise.exerciseType);
    final exerciseEmoji = _getExerciseEmoji(exercise.exerciseType);
    final calories = CalorieCalculator.calculateCalories(
      exerciseType: exercise.exerciseType,
      durationMinutes: exercise.durationMinutes,
      intensity: exercise.intensity,
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedbackManager.lightImpact();
          Navigator.pushNamed(
            context,
            '/exercise_detail',
            arguments: exercise,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Exercise icon with gradient background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      exerciseColor.withOpacity(0.2),
                      exerciseColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  exerciseEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              
              // Exercise details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          exercise.exerciseType,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: RecordColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: exerciseColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${calories}kcal',
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: exerciseColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: RecordColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.durationMinutes}분',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: RecordColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          _getIntensityIcon(exercise.intensity),
                          size: 14,
                          color: _getIntensityColor(exercise.intensity),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getIntensityLabel(exercise.intensity),
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getIntensityColor(exercise.intensity),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(exercise.date),
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: RecordColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedbackManager.lightImpact();
                        Navigator.pushNamed(
                          context,
                          '/exercise_edit',
                          arguments: exercise,
                        );
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: RecordColors.textSecondary,
                      ),
                      tooltip: '수정',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: RecordColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRecentExercises() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: RecordColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '최근 운동 기록이 없습니다',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: RecordColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 운동을 기록해보세요!',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: RecordColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for calculations and insights
  int _calculateTotalCalories(List<ExerciseLog> exerciseLogs) {
    return exerciseLogs.fold<int>(0, (sum, log) {
      final calories = CalorieCalculator.calculateCalories(
        exerciseType: log.exerciseType,
        durationMinutes: log.durationMinutes,
        intensity: log.intensity,
      );
      return sum + calories;
    });
  }


  int _calculateCurrentStreak(List<ExerciseLog> exerciseLogs) {
    if (exerciseLogs.isEmpty) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sortedLogs = exerciseLogs
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    
    if (sortedLogs.isEmpty) return 0;
    
    int streak = 0;
    DateTime checkDate = today;
    
    for (final logDate in sortedLogs) {
      if (logDate.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (logDate.isBefore(checkDate)) {
        break;
      }
    }
    
    return streak;
  }

  List<Map<String, dynamic>> _generateInsights(List<ExerciseLog> exerciseLogs) {
    final insights = <Map<String, dynamic>>[];
    
    if (exerciseLogs.isEmpty) return insights;
    
    // 가장 좋아하는 운동 타입
    final typeCountMap = <String, int>{};
    for (final log in exerciseLogs) {
      typeCountMap[log.exerciseType] = (typeCountMap[log.exerciseType] ?? 0) + 1;
    }
    
    if (typeCountMap.isNotEmpty) {
      final favoriteType = typeCountMap.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add({
        'icon': Icons.favorite,
        'title': '선호 운동',
        'description': '${favoriteType.key}을(를) 가장 많이 하셨네요! (${favoriteType.value}회)',
        'color': RecordColors.secondary,
      });
    }
    
    // 가장 활동적인 요일
    final weekdayCountMap = <int, int>{};
    for (final log in exerciseLogs) {
      final weekday = log.date.weekday;
      weekdayCountMap[weekday] = (weekdayCountMap[weekday] ?? 0) + 1;
    }
    
    if (weekdayCountMap.isNotEmpty) {
      final mostActiveWeekday = weekdayCountMap.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      final weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
      
      insights.add({
        'icon': Icons.calendar_today,
        'title': '활동적인 요일',
        'description': '${weekdayNames[mostActiveWeekday.key - 1]}요일에 가장 활발하게 운동하세요!',
        'color': RecordColors.primary,
      });
    }
    
    // 평균 운동 시간 분석
    final avgDuration = exerciseLogs.fold<int>(0, (sum, log) => sum + log.durationMinutes) / exerciseLogs.length;
    if (avgDuration > 45) {
      insights.add({
        'icon': Icons.trending_up,
        'title': '지속력 최고',
        'description': '평균 ${avgDuration.round()}분 운동! 꾸준함이 최고의 무기입니다.',
        'color': RecordColors.success,
      });
    } else if (avgDuration < 20) {
      insights.add({
        'icon': Icons.access_time,
        'title': '운동 시간 늘리기',
        'description': '조금씩 운동 시간을 늘려보세요. 현재 평균 ${avgDuration.round()}분이에요.',
        'color': RecordColors.warning,
      });
    }
    
    // 최근 일주일 운동 빈도
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentExercises = exerciseLogs.where((log) => log.date.isAfter(weekAgo)).length;
    
    if (recentExercises >= 5) {
      insights.add({
        'icon': Icons.emoji_events,
        'title': '일주일 챔피언',
        'description': '이번 주 ${recentExercises}회 운동! 정말 대단해요! 🏆',
        'color': RecordColors.warning,
      });
    } else if (recentExercises >= 3) {
      insights.add({
        'icon': Icons.thumb_up,
        'title': '좋은 페이스',
        'description': '이번 주 ${recentExercises}회 운동 중이에요. 계속 화이팅!',
        'color': RecordColors.info,
      });
    }
    
    return insights;
  }

  Color _getExerciseColor(String exerciseType) {
    switch (exerciseType) {
      case '걷기':
      case '등산':
      case '러닝':
      case '수영':
      case '자전거':
        return const Color(0xFF059669);
      case '요가':
      case '클라이밍':
      case '필라테스':
        return const Color(0xFF8B5CF6);
      case '헬스':
        return const Color(0xFF1F2937);
      case '골프':
      case '배드민턴':
      case '테니스':
        return const Color(0xFFFBBF24);
      case '농구':
      case '축구':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF97316);
    }
  }

  String _getExerciseEmoji(String exerciseType) {
    switch (exerciseType) {
      case '러닝':
        return '🏃';
      case '클라이밍':
        return '🧗';
      case '등산':
        return '🥾';
      case '헬스':
        return '🏋️';
      case '배드민턴':
        return '🏸';
      case '수영':
        return '🏊';
      case '자전거':
        return '🚴';
      case '요가':
        return '🧘';
      case '골프':
        return '⛳';
      case '축구':
        return '⚽';
      case '농구':
        return '🏀';
      case '테니스':
        return '🎾';
      default:
        return '💪';
    }
  }

  String _getIntensityLabel(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '낮음':
        return '편안함';
      case 'medium':
      case '보통':
        return '적당함';
      case 'high':
      case '높음':
        return '힘듬';
      case 'very_high':
      case '매우높음':
        return '매우 힘듬';
      default:
        return intensity;
    }
  }

  IconData _getIntensityIcon(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '낮음':
        return Icons.spa;
      case 'medium':
      case '보통':
        return Icons.directions_walk;
      case 'high':
      case '높음':
        return Icons.directions_run;
      case 'very_high':
      case '매우높음':
        return Icons.whatshot;
      default:
        return Icons.directions_walk;
    }
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '낮음':
        return const Color(0xFF10B981);
      case 'medium':
      case '보통':
        return const Color(0xFFF59E0B);
      case 'high':
      case '높음':
        return const Color(0xFFEF4444);
      case 'very_high':
      case '매우높음':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '${difference}일 전';
    } else {
      final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
      final weekday = weekdays[date.weekday % 7];
      return '${date.month}/${date.day} ($weekday)';
    }
  }
}