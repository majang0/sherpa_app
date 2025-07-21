// lib/features/daily_record/presentation/screens/exercise_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Constants
import '../../../../core/constants/app_colors.dart';
import '../../constants/record_colors.dart' as RC;

// Providers
import '../../../../shared/providers/global_user_provider.dart';

// Models
import '../../../../shared/models/global_user_model.dart';

// Widgets
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

class ExerciseDashboardScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExerciseDashboardScreen> createState() => _ExerciseDashboardScreenState();
}

class _ExerciseDashboardScreenState extends ConsumerState<ExerciseDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final exerciseLogs = user.dailyRecords.exerciseLogs;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: SherpaCleanAppBar(
        title: '운동 대시보드',
        backgroundColor: const Color(0xFFF8FAFC),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: exerciseLogs.length >= 5
              ? _buildDashboardContent(exerciseLogs)
              : _buildInsufficientDataState(),
        ),
      ),
    );
  }

  Widget _buildInsufficientDataState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF059669).withOpacity(0.2),
                    const Color(0xFF047857).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 40,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '아직 분석할 데이터가 부족해요',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: RC.RecordColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '운동 기록이 5회 이상 쌓이면\n상세한 분석을 제공합니다',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: RC.RecordColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedbackManager.mediumImpact();
                Navigator.pushNamed(
                  context,
                  '/exercise_selection',
                  arguments: DateTime.now(),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                '운동 기록하기',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(List<ExerciseLog> exerciseLogs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 대시보드 헤더
          _buildDashboardHeader(exerciseLogs),
          
          const SizedBox(height: 24),
          
          // 오늘 운동 진행률 카드
          _buildTodayProgressCard(exerciseLogs),
          
          const SizedBox(height: 24),
          
          // 운동별 상세 KPI
          _buildExerciseKPIDashboard(exerciseLogs),
          
          const SizedBox(height: 24),
          
          // 운동 성과 요약
          _buildPerformanceSummary(exerciseLogs),
          
          const SizedBox(height: 24),
          
          // 추천 및 인사이트
          _buildInsightsCard(exerciseLogs),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(List<ExerciseLog> exerciseLogs) {
    final totalMinutes = exerciseLogs.fold(0, (sum, log) => sum + log.durationMinutes);
    final totalSessions = exerciseLogs.length;
    final averageMinutes = totalSessions > 0 ? (totalMinutes / totalSessions).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF059669),
            const Color(0xFF047857),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '운동 분석 대시보드',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '나만의 운동 패턴을 분석해보세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 주요 지표 카드들
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '총 운동시간',
                  '${totalMinutes}분',
                  Icons.timer,
                  Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '운동 횟수',
                  '${totalSessions}회',
                  Icons.fitness_center,
                  Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '평균 시간',
                  '${averageMinutes}분',
                  Icons.trending_up,
                  Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgressCard(List<ExerciseLog> exerciseLogs) {
    final today = DateTime.now();
    final todayExercises = exerciseLogs.where((log) => _isSameDay(log.date, today)).toList();
    final todayMinutes = todayExercises.fold(0, (sum, log) => sum + log.durationMinutes);
    final progress = (todayMinutes / 30).clamp(0.0, 2.0);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.today,
                  color: Color(0xFFF97316),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 운동 진행률',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: RC.RecordColors.textPrimary,
                      ),
                    ),
                    Text(
                      '30분 목표 기준',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: RC.RecordColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              // 도넛 차트
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    progress: progress,
                    minutes: todayMinutes,
                  ),
                ),
              ),
              
              const SizedBox(width: 24),
              
              // 운동 목록
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (todayExercises.isEmpty)
                      Text(
                        '아직 오늘 운동을 하지 않았어요.\n운동을 시작해보세요!',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: RC.RecordColors.textSecondary,
                          height: 1.4,
                        ),
                      )
                    else
                      ...todayExercises.map((exercise) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getExerciseColor(exercise.exerciseType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _getExerciseEmoji(exercise.exerciseType),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                exercise.exerciseType,
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: RC.RecordColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${exercise.durationMinutes}분',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getExerciseColor(exercise.exerciseType),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 운동별 상세 KPI 대시보드 (기존 _buildExerciseKPIDashboard 내용을 가져와서 스타일 개선)
  Widget _buildExerciseKPIDashboard(List<ExerciseLog> exerciseLogs) {
    final exerciseStats = <String, Map<String, dynamic>>{};
    
    for (final log in exerciseLogs) {
      final type = log.exerciseType;
      if (!exerciseStats.containsKey(type)) {
        exerciseStats[type] = {
          'totalMinutes': 0,
          'sessions': 0,
          'maxDuration': 0,
          'logs': <ExerciseLog>[],
        };
      }
      
      exerciseStats[type]!['totalMinutes'] += log.durationMinutes;
      exerciseStats[type]!['sessions'] += 1;
      exerciseStats[type]!['maxDuration'] = math.max(
        exerciseStats[type]!['maxDuration'] as int,
        log.durationMinutes,
      );
      exerciseStats[type]!['logs'].add(log);
    }
    
    // 5회 이상 한 운동만 필터링
    final qualifiedExercises = exerciseStats.entries
        .where((entry) => entry.value['sessions'] >= 5)
        .toList();
        
    if (qualifiedExercises.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운동별 상세 분석',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: RC.RecordColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...qualifiedExercises.map((entry) {
          final exerciseType = entry.key;
          final stats = entry.value;
          final avgDuration = (stats['totalMinutes'] / stats['sessions']).round();
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getExerciseColor(exerciseType).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getExerciseColor(exerciseType).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 운동 헤더
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getExerciseColor(exerciseType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _getExerciseEmoji(exerciseType),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exerciseType,
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: RC.RecordColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${stats['sessions']}회 기록',
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              color: RC.RecordColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // KPI 카드들
                Row(
                  children: [
                    Expanded(
                      child: _buildKPICard(
                        '총 시간',
                        '${stats['totalMinutes']}분',
                        Icons.timer,
                        _getExerciseColor(exerciseType),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKPICard(
                        '평균 시간',
                        '${avgDuration}분',
                        Icons.trending_up,
                        _getExerciseColor(exerciseType),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKPICard(
                        '최고 기록',
                        '${stats['maxDuration']}분',
                        Icons.emoji_events,
                        _getExerciseColor(exerciseType),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: RC.RecordColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: RC.RecordColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary(List<ExerciseLog> exerciseLogs) {
    final last7Days = exerciseLogs.where((log) => 
        DateTime.now().difference(log.date).inDays <= 7).toList();
    final last30Days = exerciseLogs.where((log) => 
        DateTime.now().difference(log.date).inDays <= 30).toList();
        
    final weeklyMinutes = last7Days.fold(0, (sum, log) => sum + log.durationMinutes);
    final monthlyMinutes = last30Days.fold(0, (sum, log) => sum + log.durationMinutes);
    
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assessment,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '성과 요약',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RC.RecordColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  '이번 주',
                  '${weeklyMinutes}분',
                  '${last7Days.length}회 운동',
                  const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  '이번 달',
                  '${monthlyMinutes}분',
                  '${last30Days.length}회 운동',
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String period, String time, String frequency, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: RC.RecordColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            frequency,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: RC.RecordColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(List<ExerciseLog> exerciseLogs) {
    final favoriteExercise = _getFavoriteExercise(exerciseLogs);
    final consistency = _getConsistencyScore(exerciseLogs);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insights,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '인사이트 & 추천',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RC.RecordColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildInsightItem(
            '가장 좋아하는 운동',
            '$favoriteExercise ${_getExerciseEmoji(favoriteExercise)}',
            Icons.favorite,
            const Color(0xFFEF4444),
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightItem(
            '운동 일관성',
            '${consistency}% - ${_getConsistencyMessage(consistency)}',
            Icons.trending_up,
            consistency >= 70 ? const Color(0xFF059669) : const Color(0xFFF59E0B),
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightItem(
            '추천 목표',
            '주 3회 이상 꾸준히 운동하기',
            Icons.flag,
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: RC.RecordColors.textSecondary,
                  ),
                ),
                Text(
                  content,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: RC.RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 헬퍼 메서드들
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getFavoriteExercise(List<ExerciseLog> exerciseLogs) {
    final exerciseCount = <String, int>{};
    for (final log in exerciseLogs) {
      exerciseCount[log.exerciseType] = (exerciseCount[log.exerciseType] ?? 0) + 1;
    }
    
    if (exerciseCount.isEmpty) return '없음';
    
    return exerciseCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  int _getConsistencyScore(List<ExerciseLog> exerciseLogs) {
    if (exerciseLogs.isEmpty) return 0;
    
    final last30Days = DateTime.now().subtract(const Duration(days: 30));
    final recentLogs = exerciseLogs.where((log) => log.date.isAfter(last30Days)).toList();
    
    if (recentLogs.isEmpty) return 0;
    
    final uniqueDays = recentLogs.map((log) => 
        '${log.date.year}-${log.date.month}-${log.date.day}').toSet().length;
    
    return ((uniqueDays / 30) * 100).round();
  }

  String _getConsistencyMessage(int score) {
    if (score >= 80) return '매우 우수해요!';
    if (score >= 60) return '꾸준해요!';
    if (score >= 40) return '보통이에요';
    if (score >= 20) return '조금 더 노력해요';
    return '시작이 반이에요!';
  }

  Color _getExerciseColor(String exerciseType) {
    switch (exerciseType) {
      case '러닝':
      case '자전거':
      case '수영':
      case '등산':
      case '걷기':
        return const Color(0xFF059669); // 초록
      case '클라이밍':
      case '필라테스':
      case '요가':
        return const Color(0xFF8B5CF6); // 보라
      case '헬스':
        return const Color(0xFF1F2937); // 검정
      case '테니스':
      case '배드민턴':
      case '골프':
        return const Color(0xFFFBBF24); // 노랑
      case '축구':
      case '농구':
        return const Color(0xFFEF4444); // 빨강
      default:
        return const Color(0xFFF97316); // 주황 (기본)
    }
  }

  String _getExerciseEmoji(String exerciseType) {
    switch (exerciseType) {
      case '러닝': return '🏃‍♂️';
      case '자전거': return '🚴‍♂️';
      case '수영': return '🏊‍♂️';
      case '등산': return '🥾';
      case '걷기': return '🚶‍♂️';
      case '클라이밍': return '🧗‍♂️';
      case '필라테스': return '🤸‍♀️';
      case '요가': return '🧘‍♀️';
      case '헬스': return '💪';
      case '테니스': return '🎾';
      case '배드민턴': return '🏸';
      case '골프': return '⛳';
      case '축구': return '⚽';
      case '농구': return '🏀';
      default: return '🏃‍♂️';
    }
  }
}

// 도넛 차트 페인터 (기존 코드 재사용)
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
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 진행 원
    final progressPaint = Paint()
      ..color = progress >= 1.0 
          ? const Color(0xFF059669)
          : const Color(0xFFF97316)
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
            text: '$minutes',
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
              color: RC.RecordColors.textSecondary,
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