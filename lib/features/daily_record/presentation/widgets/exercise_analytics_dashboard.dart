// lib/features/daily_record/presentation/widgets/exercise_analytics_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/record_colors.dart';
import '../../models/detailed_exercise_models.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

class ExerciseAnalyticsDashboard extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExerciseAnalyticsDashboard> createState() => _ExerciseAnalyticsDashboardState();
}

class _ExerciseAnalyticsDashboardState extends ConsumerState<ExerciseAnalyticsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<DetailedExerciseRecord> _records = [];
  bool _isLoading = true;
  String _selectedPeriod = '1개월';
  
  final List<String> _periods = ['1주일', '1개월', '3개월', '6개월'];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _loadExerciseRecords();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadExerciseRecords() async {
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      DateTime fromDate;
      
      switch (_selectedPeriod) {
        case '1주일':
          fromDate = now.subtract(const Duration(days: 7));
          break;
        case '1개월':
          fromDate = now.subtract(const Duration(days: 30));
          break;
        case '3개월':
          fromDate = now.subtract(const Duration(days: 90));
          break;
        case '6개월':
          fromDate = now.subtract(const Duration(days: 180));
          break;
        default:
          fromDate = now.subtract(const Duration(days: 30));
      }
      
      final records = await ref.read(globalUserProvider.notifier).getDetailedExerciseRecords(
        fromDate: fromDate,
        toDate: now,
      );
      
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading exercise records: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: SherpaCleanAppBar(
        title: '운동 분석',
        backgroundColor: const Color(0xFFF8FAFC),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildPeriodSelector(),
                        const SizedBox(height: 24),
                        _buildExerciseTypeDistribution(),
                        const SizedBox(height: 24),
                        _buildWeeklyVolumeChart(),
                        const SizedBox(height: 24),
                        _buildExerciseFrequencyHeatmap(),
                        const SizedBox(height: 24),
                        _buildExerciseStats(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: RecordColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '운동 기록이 5개 이상 있어야\n분석 차트를 볼 수 있어요',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: RecordColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '더 많은 운동을 기록해보세요! 💪',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: RecordColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  setState(() => _selectedPeriod = period);
                  _loadExerciseRecords();
                  HapticFeedbackManager.lightImpact();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : RecordColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseTypeDistribution() {
    if (_records.length < 5) return const SizedBox();

    // 운동 종목별 개수 집계
    final Map<String, int> exerciseCount = {};
    for (final record in _records) {
      exerciseCount[record.exerciseType] = (exerciseCount[record.exerciseType] ?? 0) + 1;
    }

    final List<PieChartSectionData> sections = [];
    final colors = [
      const Color(0xFF10B981), // 러닝
      const Color(0xFF8B5CF6), // 클라이밍
      const Color(0xFF059669), // 등산
      const Color(0xFFEF4444), // 헬스
      const Color(0xFF3B82F6), // 배드민턴
      const Color(0xFFF97316), // 기타
    ];

    int colorIndex = 0;
    for (final entry in exerciseCount.entries) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: entry.value.toDouble(),
          title: '${entry.value}회',
          titleStyle: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          radius: 60,
        ),
      );
      colorIndex++;
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: const Color(0xFFF97316),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 종목별 분포',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              // 도넛 차트
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (event is FlTapUpEvent) {
                            HapticFeedbackManager.lightImpact();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // 범례
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exerciseCount.entries.map((entry) {
                    final color = colors[exerciseCount.keys.toList().indexOf(entry.key) % colors.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: RecordColors.textPrimary,
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
        ],
      ),
    );
  }

  Widget _buildWeeklyVolumeChart() {
    if (_records.length < 5) return const SizedBox();

    // 주간 운동량 데이터 생성
    final Map<String, double> weeklyVolume = {};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.month}/${date.day}';
      weeklyVolume[key] = 0;
    }

    for (final record in _records) {
      final key = '${record.date.month}/${record.date.day}';
      if (weeklyVolume.containsKey(key)) {
        weeklyVolume[key] = weeklyVolume[key]! + record.durationMinutes;
      }
    }

    final List<BarChartGroupData> barGroups = [];
    int index = 0;
    for (final entry in weeklyVolume.entries) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value / 60, // 시간 단위로 변환
              color: const Color(0xFFF97316),
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      index++;
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: const Color(0xFFF97316),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '주간 운동량',
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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: weeklyVolume.values.isEmpty ? 5 : (weeklyVolume.values.reduce((a, b) => a > b ? a : b) / 60 * 1.2),
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = weeklyVolume.keys.toList();
                        if (value.toInt() < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              keys[value.toInt()],
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: RecordColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: RecordColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: RecordColors.textLight.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    if (event is FlTapUpEvent) {
                      HapticFeedbackManager.lightImpact();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseFrequencyHeatmap() {
    if (_records.length < 5) return const SizedBox();

    // 간단한 히트맵 (주간 운동 빈도)
    final now = DateTime.now();
    final List<List<int>> heatmapData = [];
    
    // 4주 x 7일 히트맵
    for (int week = 0; week < 4; week++) {
      final weekData = <int>[];
      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: (3 - week) * 7 + (6 - day)));
        final dayRecords = _records.where((record) => 
          record.date.year == date.year &&
          record.date.month == date.month &&
          record.date.day == date.day
        ).length;
        weekData.add(dayRecords);
      }
      heatmapData.add(weekData);
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_view_week,
                  color: const Color(0xFFF97316),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 빈도',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Column(
            children: heatmapData.map((week) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: week.map((dayCount) {
                    final intensity = dayCount > 0 ? (dayCount / 3).clamp(0.2, 1.0) : 0.0;
                    return Expanded(
                      child: Container(
                        height: 30,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: intensity > 0 
                              ? const Color(0xFFF97316).withOpacity(intensity)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            dayCount > 0 ? dayCount.toString() : '',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: intensity > 0.5 ? Colors.white : RecordColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
              return Expanded(
                child: Text(
                  day,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: RecordColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStats() {
    if (_records.isEmpty) return const SizedBox();

    final totalWorkouts = _records.length;
    final totalDuration = _records.fold(0, (sum, record) => sum + record.durationMinutes);
    final averageDuration = totalDuration / totalWorkouts;
    final mostFrequentExercise = _getMostFrequentExercise();

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics,
                  color: const Color(0xFFF97316),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 통계',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              _buildStatItem(
                icon: Icons.fitness_center,
                title: '총 운동 횟수',
                value: '${totalWorkouts}회',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                icon: Icons.timer,
                title: '총 운동 시간',
                value: '${(totalDuration / 60).toInt()}시간',
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildStatItem(
                icon: Icons.trending_up,
                title: '평균 운동 시간',
                value: '${averageDuration.toInt()}분',
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                icon: Icons.star,
                title: '가장 많이 한 운동',
                value: mostFrequentExercise,
                color: const Color(0xFFF97316),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: RecordColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMostFrequentExercise() {
    if (_records.isEmpty) return '-';
    
    final Map<String, int> exerciseCount = {};
    for (final record in _records) {
      exerciseCount[record.exerciseType] = (exerciseCount[record.exerciseType] ?? 0) + 1;
    }
    
    String mostFrequent = '-';
    int maxCount = 0;
    
    for (final entry in exerciseCount.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostFrequent = entry.key;
      }
    }
    
    return mostFrequent;
  }
}