// lib/features/activities_exercise/presentation/widgets/exercise_analytics_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';

class ExerciseAnalyticsDashboard extends ConsumerStatefulWidget {
  final String? focusExerciseType; // 특정 운동 타입에 집중할 경우
  final DateTimeRange? dateRange; // 분석 기간 설정

  const ExerciseAnalyticsDashboard({
    super.key,
    this.focusExerciseType,
    this.dateRange,
  });

  @override
  ConsumerState<ExerciseAnalyticsDashboard> createState() =>
      _ExerciseAnalyticsDashboardState();
}

class _ExerciseAnalyticsDashboardState
    extends ConsumerState<ExerciseAnalyticsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 분석 필터 상태
  String _selectedPeriod = '30일'; // 7일, 30일, 90일, 전체
  String _selectedMetric = '시간'; // 시간, 횟수, 강도
  bool _showTrends = true;

  // 차트 데이터 캐시
  List<FlSpot>? _cachedTrendData;
  Map<String, double>? _cachedTypeDistribution;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    final exerciseLogs =
        _getFilteredExercises(globalUser.dailyRecords.exerciseLogs);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 분석 컨트롤 패널
            _buildAnalyticsControls()
                .animate()
                .slide(duration: 600.ms, delay: 100.ms),

            const SizedBox(height: 24),

            // 핵심 지표 카드들
            _buildKeyMetrics(exerciseLogs)
                .animate()
                .slide(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 24),

            // 트렌드 차트
            if (_showTrends)
              _buildTrendChart(exerciseLogs)
                  .animate()
                  .slide(duration: 600.ms, delay: 300.ms),

            const SizedBox(height: 24),

            // 운동 타입별 심화 분석
            _buildExerciseTypeAnalysis(exerciseLogs)
                .animate()
                .slide(duration: 600.ms, delay: 400.ms),

            const SizedBox(height: 24),

            // 성과 분석 및 목표 추천
            _buildPerformanceInsights(exerciseLogs)
                .animate()
                .slide(duration: 600.ms, delay: 500.ms),

            const SizedBox(height: 24),

            // 주간/월간 비교 분석
            _buildComparativeAnalysis(exerciseLogs)
                .animate()
                .slide(duration: 600.ms, delay: 600.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: ModernColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '분석 설정',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 기간 선택
          Row(
            children: [
              Text(
                '기간: ',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              ..._buildPeriodChips(),
            ],
          ),

          const SizedBox(height: 12),

          // 지표 선택 및 트렌드 토글
          Row(
            children: [
              Text(
                '지표: ',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              ..._buildMetricChips(),
              const Spacer(),
              Row(
                children: [
                  Text(
                    '트렌드',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _showTrends,
                    onChanged: (value) {
                      HapticFeedbackManager.lightImpact();
                      setState(() {
                        _showTrends = value;
                        _cachedTrendData = null; // 캐시 무효화
                      });
                    },
                    activeColor: ModernColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPeriodChips() {
    final periods = ['7일', '30일', '90일', '전체'];
    return periods.map((period) {
      final isSelected = _selectedPeriod == period;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(
            period,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : ModernColors.textSecondary,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              HapticFeedbackManager.lightImpact();
              setState(() {
                _selectedPeriod = period;
                _cachedTrendData = null; // 캐시 무효화
              });
            }
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: ModernColors.primary,
          checkmarkColor: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildMetricChips() {
    final metrics = ['시간', '횟수', '강도'];
    return metrics.map((metric) {
      final isSelected = _selectedMetric == metric;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(
            metric,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : ModernColors.textSecondary,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              HapticFeedbackManager.lightImpact();
              setState(() {
                _selectedMetric = metric;
                _cachedTrendData = null; // 캐시 무효화
              });
            }
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: ModernColors.secondary,
          checkmarkColor: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildKeyMetrics(List<ExerciseLog> exercises) {
    final stats = _calculateKeyStats(exercises);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '핵심 지표',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 2x2 그리드로 핵심 지표 표시
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '총 운동 시간',
                  '${stats['totalMinutes']}분',
                  '${stats['avgMinutesPerDay']?.toStringAsFixed(1)}분/일',
                  Icons.timer_outlined,
                  ModernColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  '운동 횟수',
                  '${stats['totalCount']}회',
                  '주 ${stats['weeklyAverage']?.toStringAsFixed(1)}회',
                  Icons.fitness_center,
                  ModernColors.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '평균 강도',
                  _getIntensityLabel(stats['avgIntensity'] ?? 'medium'),
                  '최근 $_selectedPeriod',
                  Icons.trending_up,
                  ModernColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  '연속 기록',
                  '${stats['streak']}일',
                  '최대 ${stats['maxStreak']}일',
                  Icons.local_fire_department,
                  ModernColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
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
              color: ModernColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<ExerciseLog> exercises) {
    final trendData = _getTrendData(exercises);

    if (trendData.isEmpty) {
      return _buildEmptyChart('트렌드 데이터가 없습니다');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: ModernColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: ModernColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$_selectedMetric 트렌드 ($_selectedPeriod)',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: ModernColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: trendData.length > 10
                          ? (trendData.length / 5).ceilToDouble()
                          : null,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < trendData.length) {
                          return Text(
                            _formatTrendLabel(index),
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              color: ModernColors.textSecondary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trendData,
                    isCurved: true,
                    color: ModernColors.primary,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: ModernColors.primary.withValues(alpha: 0.1),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: ModernColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
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

  Widget _buildExerciseTypeAnalysis(List<ExerciseLog> exercises) {
    final typeStats = _getExerciseTypeStats(exercises);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: ModernColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: ModernColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 타입별 분석',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 타입별 상세 통계
          ...typeStats.entries.take(5).map((entry) {
            final stats = entry.value;
            return _buildTypeStatsRow(
              entry.key,
              stats['count'] as int,
              stats['totalMinutes'] as int,
              stats['avgIntensity'] as String,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTypeStatsRow(
      String exerciseType, int count, int totalMinutes, String avgIntensity) {
    final color = _getExerciseColor(exerciseType);
    final emoji = _getExerciseEmoji(exerciseType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count회 • $totalMinutes분 • ${_getIntensityLabel(avgIntensity)}',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${((count / _getTotalExerciseCount()) * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInsights(List<ExerciseLog> exercises) {
    final insights = _generateInsights(exercises);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: ModernColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights_outlined,
                  color: ModernColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI 성과 분석',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 인사이트 카드들
          ...insights.map((insight) => _buildInsightCard(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            insight['color'].withValues(alpha: 0.1),
            insight['color'].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight['color'].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insight['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insight['icon'],
              color: insight['color'],
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'],
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['description'],
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
    );
  }

  Widget _buildComparativeAnalysis(List<ExerciseLog> exercises) {
    final comparison = _getComparativeStats(exercises);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: ModernColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.compare_arrows,
                  color: ModernColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '기간별 비교',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 이번 주 vs 지난 주
          _buildComparisonRow(
            '이번 주',
            '${comparison['thisWeek']['count']}회 • ${comparison['thisWeek']['minutes']}분',
            '지난 주',
            '${comparison['lastWeek']['count']}회 • ${comparison['lastWeek']['minutes']}분',
            comparison['weeklyChange'] as double,
          ),

          const SizedBox(height: 16),

          // 이번 달 vs 지난 달
          _buildComparisonRow(
            '이번 달',
            '${comparison['thisMonth']['count']}회 • ${comparison['thisMonth']['minutes']}분',
            '지난 달',
            '${comparison['lastMonth']['count']}회 • ${comparison['lastMonth']['minutes']}분',
            comparison['monthlyChange'] as double,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String period1, String stats1, String period2,
      String stats2, double change) {
    final isPositive = change >= 0;
    final changeColor = isPositive ? ModernColors.success : ModernColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period1,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                    Text(
                      stats1,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: ModernColors.textSecondary,
                size: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      period2,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                    Text(
                      stats2,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: changeColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.show_chart,
            size: 64,
            color: ModernColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // 데이터 처리 및 계산 메서드들
  List<ExerciseLog> _getFilteredExercises(List<ExerciseLog> allExercises) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case '7일':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '30일':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case '90일':
        startDate = now.subtract(const Duration(days: 90));
        break;
      default: // '전체'
        return widget.focusExerciseType != null
            ? allExercises
                .where((e) => e.exerciseType == widget.focusExerciseType)
                .toList()
            : allExercises;
    }

    var filtered = allExercises
        .where((exercise) => exercise.date.isAfter(startDate))
        .toList();

    if (widget.focusExerciseType != null) {
      filtered = filtered
          .where((e) => e.exerciseType == widget.focusExerciseType)
          .toList();
    }

    return filtered;
  }

  Map<String, dynamic> _calculateKeyStats(List<ExerciseLog> exercises) {
    if (exercises.isEmpty) {
      return {
        'totalMinutes': 0,
        'totalCount': 0,
        'avgMinutesPerDay': 0.0,
        'weeklyAverage': 0.0,
        'avgIntensity': 'medium',
        'streak': 0,
        'maxStreak': 0,
      };
    }

    final totalMinutes =
        exercises.fold<int>(0, (sum, e) => sum + e.durationMinutes);
    final totalCount = exercises.length;
    final daysDifference = _getDaysDifference();
    final avgMinutesPerDay =
        daysDifference > 0 ? totalMinutes / daysDifference : 0.0;
    final weeklyAverage =
        daysDifference > 0 ? (totalCount * 7) / daysDifference : 0.0;

    // 평균 강도 계산
    final intensityScores =
        exercises.map((e) => _getIntensityScore(e.intensity)).toList();
    final avgIntensityScore =
        intensityScores.fold<double>(0, (sum, score) => sum + score) /
            intensityScores.length;
    final avgIntensity = _getIntensityFromScore(avgIntensityScore);

    // 연속 기록 계산
    final streakData = _calculateStreak(exercises);

    return {
      'totalMinutes': totalMinutes,
      'totalCount': totalCount,
      'avgMinutesPerDay': avgMinutesPerDay,
      'weeklyAverage': weeklyAverage,
      'avgIntensity': avgIntensity,
      'streak': streakData['current'] ?? 0,
      'maxStreak': streakData['max'] ?? 0,
    };
  }

  List<FlSpot> _getTrendData(List<ExerciseLog> exercises) {
    if (_cachedTrendData != null) return _cachedTrendData!;

    if (exercises.isEmpty) return [];

    // 날짜별로 그룹화
    final dateGroups = <DateTime, List<ExerciseLog>>{};
    for (final exercise in exercises) {
      final date =
          DateTime(exercise.date.year, exercise.date.month, exercise.date.day);
      dateGroups.putIfAbsent(date, () => []).add(exercise);
    }

    // 날짜 순 정렬
    final sortedDates = dateGroups.keys.toList()..sort();

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final dayExercises = dateGroups[date]!;

      double value;
      switch (_selectedMetric) {
        case '시간':
          value = dayExercises
              .fold<int>(0, (sum, e) => sum + e.durationMinutes)
              .toDouble();
          break;
        case '횟수':
          value = dayExercises.length.toDouble();
          break;
        case '강도':
          value = dayExercises
                  .map((e) => _getIntensityScore(e.intensity))
                  .fold<double>(0, (sum, score) => sum + score) /
              dayExercises.length;
          break;
        default:
          value = 0;
      }

      spots.add(FlSpot(i.toDouble(), value));
    }

    _cachedTrendData = spots;
    return spots;
  }

  Map<String, Map<String, dynamic>> _getExerciseTypeStats(
      List<ExerciseLog> exercises) {
    final typeStats = <String, Map<String, dynamic>>{};

    for (final exercise in exercises) {
      final type = exercise.exerciseType;

      if (!typeStats.containsKey(type)) {
        typeStats[type] = {
          'count': 0,
          'totalMinutes': 0,
          'intensityScores': <double>[],
        };
      }

      typeStats[type]!['count'] = (typeStats[type]!['count'] as int) + 1;
      typeStats[type]!['totalMinutes'] =
          (typeStats[type]!['totalMinutes'] as int) + exercise.durationMinutes;
      (typeStats[type]!['intensityScores'] as List<double>)
          .add(_getIntensityScore(exercise.intensity));
    }

    // 평균 강도 계산
    for (final type in typeStats.keys) {
      final scores = typeStats[type]!['intensityScores'] as List<double>;
      final avgScore =
          scores.fold<double>(0, (sum, score) => sum + score) / scores.length;
      typeStats[type]!['avgIntensity'] = _getIntensityFromScore(avgScore);
    }

    return typeStats;
  }

  List<Map<String, dynamic>> _generateInsights(List<ExerciseLog> exercises) {
    final insights = <Map<String, dynamic>>[];

    if (exercises.isEmpty) {
      insights.add({
        'title': '운동을 시작해보세요!',
        'description': '첫 운동 기록을 남겨 개인화된 분석을 받아보세요.',
        'icon': Icons.play_arrow,
        'color': ModernColors.primary,
      });
      return insights;
    }

    final stats = _calculateKeyStats(exercises);
    final typeStats = _getExerciseTypeStats(exercises);

    // 가장 많이 한 운동
    final mostFrequentType = typeStats.entries
        .reduce((a, b) =>
            (a.value['count'] as int) > (b.value['count'] as int) ? a : b)
        .key;

    insights.add({
      'title': '선호 운동: $mostFrequentType',
      'description': '가장 자주 하는 운동입니다. 다양한 운동도 시도해보세요!',
      'icon': Icons.favorite,
      'color': ModernColors.secondary,
    });

    // 연속 기록 분석
    if ((stats['streak'] as int) >= 3) {
      insights.add({
        'title': '훌륭한 연속 기록!',
        'description': '${stats['streak']}일 연속으로 운동하고 있습니다. 계속 유지하세요!',
        'icon': Icons.local_fire_department,
        'color': ModernColors.success,
      });
    }

    // 운동 시간 분석
    final avgMinutes = stats['avgMinutesPerDay'] as double;
    if (avgMinutes >= 30) {
      insights.add({
        'title': '충분한 운동량',
        'description': 'WHO 권장 운동량을 충족하고 있습니다!',
        'icon': Icons.thumb_up,
        'color': ModernColors.success,
      });
    } else if (avgMinutes > 0) {
      insights.add({
        'title': '운동 시간 늘리기',
        'description':
            '일일 평균 ${avgMinutes.toStringAsFixed(1)}분입니다. 30분을 목표로 해보세요!',
        'icon': Icons.trending_up,
        'color': ModernColors.warning,
      });
    }

    return insights;
  }

  Map<String, dynamic> _getComparativeStats(List<ExerciseLog> exercises) {
    final now = DateTime.now();

    // 이번 주 vs 지난 주
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final thisWeekExercises = exercises
        .where((e) =>
            e.date.isAfter(thisWeekStart.subtract(const Duration(days: 1))))
        .toList();
    final lastWeekExercises = exercises
        .where((e) =>
            e.date.isAfter(lastWeekStart.subtract(const Duration(days: 1))) &&
            e.date.isBefore(thisWeekStart))
        .toList();

    // 이번 달 vs 지난 달
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);

    final thisMonthExercises = exercises
        .where((e) =>
            e.date.isAfter(thisMonthStart.subtract(const Duration(days: 1))))
        .toList();
    final lastMonthExercises = exercises
        .where((e) =>
            e.date.isAfter(lastMonthStart.subtract(const Duration(days: 1))) &&
            e.date.isBefore(thisMonthStart))
        .toList();

    final thisWeekMinutes =
        thisWeekExercises.fold<int>(0, (sum, e) => sum + e.durationMinutes);
    final lastWeekMinutes =
        lastWeekExercises.fold<int>(0, (sum, e) => sum + e.durationMinutes);
    final thisMonthMinutes =
        thisMonthExercises.fold<int>(0, (sum, e) => sum + e.durationMinutes);
    final lastMonthMinutes =
        lastMonthExercises.fold<int>(0, (sum, e) => sum + e.durationMinutes);

    final weeklyChange = lastWeekMinutes > 0
        ? ((thisWeekMinutes - lastWeekMinutes) / lastWeekMinutes) * 100
        : 0.0;
    final monthlyChange = lastMonthMinutes > 0
        ? ((thisMonthMinutes - lastMonthMinutes) / lastMonthMinutes) * 100
        : 0.0;

    return {
      'thisWeek': {
        'count': thisWeekExercises.length,
        'minutes': thisWeekMinutes
      },
      'lastWeek': {
        'count': lastWeekExercises.length,
        'minutes': lastWeekMinutes
      },
      'thisMonth': {
        'count': thisMonthExercises.length,
        'minutes': thisMonthMinutes
      },
      'lastMonth': {
        'count': lastMonthExercises.length,
        'minutes': lastMonthMinutes
      },
      'weeklyChange': weeklyChange,
      'monthlyChange': monthlyChange,
    };
  }

  // 유틸리티 메서드들
  int _getDaysDifference() {
    switch (_selectedPeriod) {
      case '7일':
        return 7;
      case '30일':
        return 30;
      case '90일':
        return 90;
      default:
        return 365; // 전체
    }
  }

  double _getIntensityScore(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '낮음':
        return 1.0;
      case 'medium':
      case '보통':
        return 2.0;
      case 'high':
      case '높음':
        return 3.0;
      case 'very_high':
      case '매우높음':
        return 4.0;
      default:
        return 2.0;
    }
  }

  String _getIntensityFromScore(double score) {
    if (score <= 1.5) return 'low';
    if (score <= 2.5) return 'medium';
    if (score <= 3.5) return 'high';
    return 'very_high';
  }

  Map<String, int> _calculateStreak(List<ExerciseLog> exercises) {
    if (exercises.isEmpty) return {'current': 0, 'max': 0};

    // 날짜별로 정렬
    final exerciseDates = exercises
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort();

    int currentStreak = 0;
    int maxStreak = 0;
    int tempStreak = 1;

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // 현재 연속 기록 계산
    if (exerciseDates.isNotEmpty) {
      final lastExerciseDate = exerciseDates.last;
      if (_isSameDay(lastExerciseDate, today) ||
          _isSameDay(lastExerciseDate, yesterday)) {
        currentStreak = 1;
        for (int i = exerciseDates.length - 2; i >= 0; i--) {
          final currentDate = exerciseDates[i];
          final nextDate = exerciseDates[i + 1];
          if (nextDate.difference(currentDate).inDays == 1) {
            currentStreak++;
          } else {
            break;
          }
        }
      }
    }

    // 최대 연속 기록 계산
    for (int i = 1; i < exerciseDates.length; i++) {
      final prevDate = exerciseDates[i - 1];
      final currentDate = exerciseDates[i];

      if (currentDate.difference(prevDate).inDays == 1) {
        tempStreak++;
      } else {
        maxStreak = maxStreak > tempStreak ? maxStreak : tempStreak;
        tempStreak = 1;
      }
    }
    maxStreak = maxStreak > tempStreak ? maxStreak : tempStreak;

    return {'current': currentStreak, 'max': maxStreak};
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int _getTotalExerciseCount() {
    final globalUser = ref.read(globalUserProvider);
    return globalUser.dailyRecords.exerciseLogs.length;
  }

  String _formatTrendLabel(int index) {
    final now = DateTime.now();
    final date = now.subtract(Duration(days: index));
    return '${date.month}/${date.day}';
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
}
