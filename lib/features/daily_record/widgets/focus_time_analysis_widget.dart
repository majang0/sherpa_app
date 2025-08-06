// lib/features/daily_record/widgets/focus_time_analysis_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../presentation/screens/focus_timer_record_screen.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';

// ═══════════════════════════════════════════════════════════════
// 🎯 SIMPLE FOCUS SYSTEM - 30분 목표 기반 단순 시스템
// ═══════════════════════════════════════════════════════════════

class FocusTimeAnalysisWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<FocusTimeAnalysisWidget> createState() => _FocusTimeAnalysisWidgetState();
}

class _FocusTimeAnalysisWidgetState extends ConsumerState<FocusTimeAnalysisWidget>
    with TickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late AnimationController _fadeController;
  late AnimationController _gaugeAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _chartAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _gaugeAnimation;
  late Animation<double> _pulseAnimation;
  
  
  // Simple focus colors
  static const Color _levelOneColor = Color(0xFF9E9E9E);
  static const Color _levelTwoColor = Color(0xFF2E5BFF);
  static const Color _levelThreeColor = Color(0xFFFFB000);
  
  @override
  void initState() {
    super.initState();

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _gaugeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _gaugeAnimation = CurvedAnimation(
      parent: _gaugeAnimationController,
      curve: Curves.easeOutBack,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _gaugeAnimationController.forward();
      _chartAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _fadeController.dispose();
    _gaugeAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final todayFocusMinutes = user.dailyRecords.todayFocusMinutes;

    return LayoutBuilder(
      builder: (context, constraints) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight * 0.9, // 화면 높이의 90%로 제한
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMinimalHeader(),
                    const SizedBox(height: 16),
                    _buildCombinedFocusSection(todayFocusMinutes),
                    const SizedBox(height: 20),
                    _buildFocusBarChart(todayFocusMinutes),
                    const SizedBox(height: 16),
                    _buildActionButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_levelTwoColor.withOpacity(0.1), _levelTwoColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.timer_outlined,
                color: _levelTwoColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '몰입하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '깊은 집중의 시간을 기록합니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Statistics toggle button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedbackManager.lightImpact();
              _showStatisticsModal();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: Colors.grey[700],
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedFocusSection(int todayMinutes) {
    // Simple color based on 30-minute goal
    final currentColor = _getCurrentColor(todayMinutes);

    return Container(
      constraints: BoxConstraints(
        maxHeight: 400, // 전체 섹션 높이 제한
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              currentColor.withOpacity(0.12), 
              currentColor.withOpacity(0.04)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: currentColor.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: currentColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple focus header - 30분 목표 기반
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Focus icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              currentColor.withOpacity(0.2),
                              currentColor.withOpacity(0.05),
                            ],
                            radius: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: currentColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.psychology_outlined,
                          color: currentColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '집중 목표',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey[900],
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: currentColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '30분',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: currentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '하루 30분 깊은 집중이 목표입니다',
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Simple progress indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        currentColor.withOpacity(0.15),
                        currentColor.withOpacity(0.08),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: currentColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: currentColor.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getGoalProgressText(todayMinutes),
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: currentColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${todayMinutes}/30분',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Circular Gauge with bulletproof constraints
            Container(
              width: 180,
              height: 180,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Background circle (failsafe rendering)
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 4,
                      ),
                    ),
                  ),
                  
                  // Simple focus progress with absolute positioning
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _gaugeAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: SimpleFocusProgressPainter(
                            minutes: todayMinutes,
                            animationValue: _gaugeAnimation.value,
                            pulseValue: _pulseAnimation.value,
                            strokeWidth: 16,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Perfect center content with proper alignment
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getCurrentColor(todayMinutes).withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Current time display
                            Text(
                              _formatTimeSimple(todayMinutes),
                              style: GoogleFonts.notoSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: _getCurrentColor(todayMinutes),
                                letterSpacing: -0.8,
                                height: 0.9,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Goal-based progress text
                            Text(
                              _getGoalProgressText(todayMinutes),
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _getCurrentColor(todayMinutes),
                                letterSpacing: -0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 2),
                            
                            // Next milestone or achievement
                            Text(
                              _getStatusMessage(todayMinutes),
                              style: GoogleFonts.notoSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                letterSpacing: -0.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String percentile,
    required Color levelColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: levelColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: levelColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  percentile,
                  style: GoogleFonts.notoSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: levelColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusBarChart(int todayFocusMinutes) {
    final focusData = _generateFocusHistory();
    final maxValue = focusData.reduce(math.max).toDouble() * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '14일간 몰입 패턴',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildLegendItem('기본', _levelOneColor),
            const SizedBox(width: 16),
            _buildLegendItem('목표달성', _levelTwoColor),
            const SizedBox(width: 16),
            _buildLegendItem('초월', _levelThreeColor),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 150,
            child: AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey[900],
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final minutes = focusData[groupIndex];
                        final isToday = groupIndex == focusData.length - 1;
                        final daysAgo = 13 - groupIndex;
                        final dateText = isToday ? '오늘' : '${daysAgo}일 전';
                        final level = _getFocusLevel(minutes);
                        
                        return BarTooltipItem(
                          '$dateText\n${_formatTime(minutes)}\n$level',
                          GoogleFonts.notoSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index % 2 != 0) return const SizedBox.shrink();
                          
                          final daysAgo = 13 - index;
                          final text = daysAgo == 0 ? '오늘' : '${daysAgo}';
                          
                          return Text(
                            text,
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 30,
                    getDrawingHorizontalLine: (value) {
                      if (value == 30) {
                        return FlLine(
                          color: _levelTwoColor.withOpacity(0.3),
                          strokeWidth: 1.5,
                          dashArray: [5, 3],
                        );
                      } else if (value == 120) {
                        return FlLine(
                          color: _levelThreeColor.withOpacity(0.3),
                          strokeWidth: 1.5,
                          dashArray: [5, 3],
                        );
                      }
                      return FlLine(
                        color: Colors.grey[200]!,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: focusData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value;
                    final isToday = index == focusData.length - 1;
                    final animatedValue = value * _chartAnimation.value;
                    final barColor = _getLevelColor(value);
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: animatedValue.toDouble(),
                          gradient: LinearGradient(
                            colors: [
                              barColor,
                              barColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: 16,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxValue,
                            color: Colors.grey[50],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedbackManager.mediumImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FocusTimerRecordScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _levelTwoColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              '몰입 시작하기',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getFocusLevel(int minutes) {
    if (minutes >= 120) return 'Level 3: 초월';
    if (minutes >= 30) return 'Level 2: 성공';
    return 'Level 1: 시작';
  }

  Color _getLevelColor(int minutes) {
    if (minutes >= 120) return _levelThreeColor;
    if (minutes >= 30) return _levelTwoColor;
    return _levelOneColor;
  }

  String _calculatePercentile(int minutes) {
    if (minutes >= 120) return '상위 5%';
    if (minutes >= 90) return '상위 10%';
    if (minutes >= 60) return '상위 20%';
    if (minutes >= 30) return '상위 35%';
    return '상위 50%';
  }

  String _calculateDailyAverage() {
    final focusData = _generateFocusHistory();
    final avgMinutes = focusData.fold<int>(0, (sum, minutes) => sum + minutes) / focusData.length;
    return _formatTime(avgMinutes.round());
  }

  String _calculateTotalTime() {
    final focusData = _generateFocusHistory();
    final totalMinutes = focusData.fold<int>(0, (sum, minutes) => sum + minutes);
    return _formatTime(totalMinutes);
  }

  // Fixed sample data that doesn't change on every rebuild
  static final List<int> _fixedFocusHistory = [
    15, 30, 45, 25, 135, 35, 90, 20, 150, 40, 55, 30, 125
  ];

  List<int> _generateFocusHistory() {
    final user = ref.read(globalUserProvider);
    final todayMinutes = user.dailyRecords.todayFocusMinutes;

    // Use fixed sample data for consistency
    List<int> history = List.from(_fixedFocusHistory);
    history.add(todayMinutes); // Add today's actual data
    return history;
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}시간 ${mins}분';
    }
    return '${mins}분';
  }


  // 부드러운 전환을 위한 곡선 함수
  double _easeCurve(double t) {
    return t * t * (3.0 - 2.0 * t); // 스무스스텝 곡선
  }

  // ═══════════════════════════════════════════════════════════════
  // SIMPLE 30-MINUTE GOAL SYSTEM - Clean & User-Friendly
  // ═══════════════════════════════════════════════════════════════
  
  // Color constants - Grey → Blue → Gold transition
  static const Color _greyColor = Color(0xFF9E9E9E);
  static const Color _blueColor = Color(0xFF2E5BFF);  
  static const Color _goldColor = Color(0xFFFFB000);
  
  // Get current color based on smooth transition
  Color _getCurrentColor(int minutes) {
    if (minutes <= 30) {
      // 0-30분: Grey → Blue
      final progress = (minutes / 30.0).clamp(0.0, 1.0);
      final smoothProgress = _easeCurve(progress);
      return Color.lerp(_greyColor, _blueColor, smoothProgress)!;
    } else {
      // 30-120분: Blue → Gold  
      final overProgress = ((minutes - 30) / 90.0).clamp(0.0, 1.0);
      final smoothProgress = _easeCurve(overProgress);
      return Color.lerp(_blueColor, _goldColor, smoothProgress)!;
    }
  }
  
  // Get simple time format for center display
  String _formatTimeSimple(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return mins == 0 ? '${hours}h' : '${hours}h ${mins}m';
    }
    return '${mins}분';
  }
  
  // Get goal-based progress text (30분 = 100%)
  String _getGoalProgressText(int minutes) {
    if (minutes < 30) {
      final progress = ((minutes / 30.0) * 100).round();
      return '$progress% 진행';
    } else {
      return '목표 달성!';
    }
  }
  
  // Get status message for motivation
  String _getStatusMessage(int minutes) {
    if (minutes < 30) {
      final remaining = 30 - minutes;
      return '목표까지 ${remaining}분';
    } else if (minutes < 120) {
      final over = minutes - 30;
      return '초과달성 +${over}분';
    } else {
      final over = minutes - 30;
      return '대단해요! +${over}분';
    }
  }


  // Show statistics modal
  void _showStatisticsModal() {
    final user = ref.read(globalUserProvider);
    final todayMinutes = user.dailyRecords.todayFocusMinutes;
    
    // Calculate current color for today's data using simple function
    final Color currentColor = _getCurrentColor(todayMinutes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_levelTwoColor.withOpacity(0.1), _levelTwoColor.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: _levelTwoColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '몰입 상세 통계',
                          style: GoogleFonts.notoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '14일간의 몰입 패턴 분석',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Statistics content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildStatItem(
                      icon: Icons.today,
                      label: '오늘의 몰입',
                      value: _formatTime(todayMinutes),
                      percentile: _calculatePercentile(todayMinutes),
                      levelColor: currentColor,
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      icon: Icons.trending_up,
                      label: '일평균 몰입',
                      value: _calculateDailyAverage(),
                      percentile: '상위 25%',
                      levelColor: _levelTwoColor,
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      icon: Icons.calendar_month,
                      label: '총 몰입시간',
                      value: _calculateTotalTime(),
                      percentile: '상위 18%',
                      levelColor: _levelTwoColor,
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      label: '최고 기록',
                      value: _calculateBestRecord(),
                      percentile: '개인 최고',
                      levelColor: _levelThreeColor,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateBestRecord() {
    final focusData = _generateFocusHistory();
    final maxMinutes = focusData.reduce((a, b) => a > b ? a : b);
    return _formatTime(maxMinutes);
  }
}

// ═══════════════════════════════════════════════════════════════
// 🎯 SIMPLE FOCUS PROGRESS PAINTER
// 30분 목표 기반 단순한 원형 진행 시스템 - 사용자 친화적 설계
// ═══════════════════════════════════════════════════════════════

class SimpleFocusProgressPainter extends CustomPainter {
  final int minutes;
  final double animationValue;
  final double pulseValue;
  final double strokeWidth;

  // Simple color constants
  static const Color _greyColor = Color(0xFF9E9E9E);   // Starting grey
  static const Color _blueColor = Color(0xFF2E5BFF);   // 30-minute goal
  static const Color _goldColor = Color(0xFFFFB000);   // Bonus achievement

  SimpleFocusProgressPainter({
    required this.minutes,
    required this.animationValue,
    required this.pulseValue,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    _drawBackground(canvas, center, radius);
    _drawProgress(canvas, rect, center, radius);
    _drawGoalMarker(canvas, center, radius);
    _drawProgressPointer(canvas, center, radius);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    // Light background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = strokeWidth * 0.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
  }

  void _drawProgress(Canvas canvas, Rect rect, Offset center, double radius) {
    final animatedMinutes = minutes * animationValue;
    if (animatedMinutes <= 0) return;

    // Calculate progress (30분 = 100% of primary goal)
    final progressRatio = (animatedMinutes / 30.0).clamp(0.0, 1.0);
    final progressAngle = 2 * math.pi * progressRatio;

    // Get current color based on time
    final currentColor = _getCurrentProgressColor(animatedMinutes.round());

    // Main progress arc
    final progressPaint = Paint()
      ..color = currentColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, progressAngle, false, progressPaint);

    // Add glow effect for better visibility
    if (progressRatio > 0.05) {
      final glowPaint = Paint()
        ..color = currentColor.withOpacity(0.3)
        ..strokeWidth = strokeWidth * 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(rect, -math.pi / 2, progressAngle, false, glowPaint);
    }

    // Extra achievement arc (over 30 minutes)
    if (animatedMinutes > 30) {
      _drawBonusArc(canvas, rect, animatedMinutes);
    }
  }

  void _drawBonusArc(Canvas canvas, Rect rect, double animatedMinutes) {
    // Show bonus progress as outer ring
    final bonusProgress = ((animatedMinutes - 30) / 90.0).clamp(0.0, 1.0);
    final bonusAngle = 2 * math.pi * bonusProgress;
    
    final bonusColor = Color.lerp(_blueColor, _goldColor, bonusProgress)!;
    final outerRadius = rect.width / 2 + strokeWidth * 0.7;
    final outerRect = Rect.fromCircle(
      center: rect.center, 
      radius: outerRadius
    );

    final bonusPaint = Paint()
      ..color = bonusColor.withOpacity(0.7)
      ..strokeWidth = strokeWidth * 0.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(outerRect, -math.pi / 2, bonusAngle, false, bonusPaint);
  }

  void _drawGoalMarker(Canvas canvas, Offset center, double radius) {
    // 30-minute goal marker at the top
    final goalAngle = -math.pi / 2 + (2 * math.pi * 1.0); // Full circle = 30min goal
    final markerPoint = Offset(
      center.dx + radius * math.cos(goalAngle),
      center.dy + radius * math.sin(goalAngle),
    );

    // Goal marker
    canvas.drawCircle(
      markerPoint,
      strokeWidth * 0.25,
      Paint()
        ..color = _blueColor
        ..style = PaintingStyle.fill,
    );
  }

  void _drawProgressPointer(Canvas canvas, Offset center, double radius) {
    final animatedMinutes = minutes * animationValue;
    if (animatedMinutes <= 0) return;

    final progressRatio = (animatedMinutes / 30.0).clamp(0.0, 1.0);
    final currentAngle = -math.pi / 2 + (2 * math.pi * progressRatio);
    final pointerPoint = Offset(
      center.dx + radius * math.cos(currentAngle),
      center.dy + radius * math.sin(currentAngle),
    );

    final currentColor = _getCurrentProgressColor(animatedMinutes.round());
    final pulseRadius = 6 + 2 * math.sin(pulseValue * 3);

    // Pulsing glow
    canvas.drawCircle(
      pointerPoint,
      pulseRadius,
      Paint()
        ..color = currentColor.withOpacity(0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Main pointer
    canvas.drawCircle(
      pointerPoint,
      4,
      Paint()
        ..color = currentColor
        ..style = PaintingStyle.fill,
    );

    // White center highlight
    canvas.drawCircle(
      pointerPoint,
      1.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  // Simple color calculation - Grey → Blue → Gold
  Color _getCurrentProgressColor(int minutes) {
    if (minutes <= 30) {
      // 0-30분: Grey → Blue
      final progress = (minutes / 30.0).clamp(0.0, 1.0);
      final smoothProgress = _easeCurve(progress);
      return Color.lerp(_greyColor, _blueColor, smoothProgress)!;
    } else {
      // 30분 이후: Blue → Gold
      final overProgress = ((minutes - 30) / 90.0).clamp(0.0, 1.0);
      final smoothProgress = _easeCurve(overProgress);
      return Color.lerp(_blueColor, _goldColor, smoothProgress)!;
    }
  }

  // Smooth easing curve
  double _easeCurve(double t) {
    return t * t * (3.0 - 2.0 * t);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! SimpleFocusProgressPainter) return true;
    return oldDelegate.minutes != minutes ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}