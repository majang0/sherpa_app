// lib/features/daily_record/widgets/focus_time_analysis_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../constants/record_colors.dart';
import '../presentation/screens/focus_timer_record_screen.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';

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
  
  
  // Define the 3-level color system
  static const Color _levelOneColor = Colors.grey;
  static const Color _levelTwoColor = Color(0xFF2E5BFF);
  static const Color _levelThreeColor = Color(0xFFFFB000); // Use same color as bar chart
  
  // Light versions for backgrounds
  static const Color _levelTwoLight = Color(0xFFF0F4FF);
  static const Color _levelThreeLight = Color(0xFFFFF9E6);
  
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMinimalHeader(),
              const SizedBox(height: 36),
              _buildCombinedFocusSection(todayFocusMinutes),
              const SizedBox(height: 40),
              _buildFocusBarChart(todayFocusMinutes),
              const SizedBox(height: 32),
              _buildActionButton(),
            ],
          ),
        ),
      ),
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
    // Calculate progress for different stages
    final double stageOneProgress = (todayMinutes / 30).clamp(0.0, 1.0);
    final double stageTwoProgress = ((todayMinutes - 30) / 90).clamp(0.0, 1.0);
    final bool isStageThree = todayMinutes >= 120;
    
    // Calculate overall progress (0-1) for circular indicator
    final double overallProgress = (todayMinutes / 120).clamp(0.0, 1.0);
    
    // Determine current level
    final String levelText;
    final String goalText;
    final Color currentColor;
    final LinearGradient currentGradient;
    
    if (todayMinutes < 30) {
      levelText = 'Level 1: 시작';
      goalText = '30분 목표';
      currentColor = Color.lerp(_levelOneColor, _levelTwoColor, stageOneProgress)!;
      currentGradient = LinearGradient(
        colors: [
          Color.lerp(_levelOneColor, _levelTwoColor, stageOneProgress)!,
          Color.lerp(_levelOneColor, _levelTwoColor, stageOneProgress)!.withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (todayMinutes < 120) {
      levelText = 'Level 2: 성공';
      goalText = '2시간 목표';
      currentColor = Color.lerp(_levelTwoColor, _levelThreeColor, stageTwoProgress)!;
      currentGradient = LinearGradient(
        colors: [
          Color.lerp(_levelTwoColor, _levelThreeColor, stageTwoProgress)!,
          Color.lerp(_levelTwoColor, _levelThreeColor, stageTwoProgress)!.withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      levelText = 'Level 3: 초월';
      goalText = '목표 초과 달성!';
      currentColor = _levelThreeColor;
      currentGradient = LinearGradient(
        colors: [_levelThreeColor, _levelThreeColor.withOpacity(0.7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [currentColor.withOpacity(0.1), currentColor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: currentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              children: [
                // Circular Gauge
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _gaugeAnimation,
                      builder: (context, child) {
                        return SizedBox(
                          width: 160,
                          height: 160,
                          child: CustomPaint(
                            painter: FocusCircularProgressPainter(
                              minutes: todayMinutes,
                              animationValue: _gaugeAnimation.value,
                              strokeWidth: 16,
                              levelOneColor: _levelOneColor,
                              levelTwoColor: _levelTwoColor,
                              levelThreeColor: _levelThreeColor,
                            ),
                          ),
                        );
                      },
                    ),
                    // Center content
                    AnimatedScale(
                      scale: isStageThree ? _pulseAnimation.value : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(todayMinutes),
                            style: GoogleFonts.notoSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: currentColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: currentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              levelText,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: currentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goalText,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        ),
        
        // Achievement message below the circular gauge (for stage 3)
        if (isStageThree)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AnimatedScale(
              scale: _pulseAnimation.value,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_levelThreeColor.withOpacity(0.2), _levelThreeColor.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _levelThreeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '✨',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        '훌륭해요! 깊은 몰입을 달성했습니다',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _levelThreeColor,
                        ),
                        textAlign: TextAlign.center,
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
        const SizedBox(height: 20),
        Container(
          height: 200,
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

  // Show statistics modal
  void _showStatisticsModal() {
    final user = ref.read(globalUserProvider);
    final todayMinutes = user.dailyRecords.todayFocusMinutes;
    
    // Calculate current color for today's data
    final double stageOneProgress = (todayMinutes / 30).clamp(0.0, 1.0);
    final double stageTwoProgress = ((todayMinutes - 30) / 90).clamp(0.0, 1.0);
    final Color currentColor;
    
    if (todayMinutes < 30) {
      currentColor = Color.lerp(_levelOneColor, _levelTwoColor, stageOneProgress)!;
    } else if (todayMinutes < 120) {
      currentColor = Color.lerp(_levelTwoColor, _levelThreeColor, stageTwoProgress)!;
    } else {
      currentColor = _levelThreeColor;
    }

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

// Clean and smooth circular progress painter with two-stage progression
// Simple and clean dual-stage circular progress painter
class FocusCircularProgressPainter extends CustomPainter {
  final int minutes;
  final double animationValue;
  final double strokeWidth;
  final Color levelOneColor;
  final Color levelTwoColor;
  final Color levelThreeColor;

  FocusCircularProgressPainter({
    required this.minutes,
    required this.animationValue,
    required this.strokeWidth,
    required this.levelOneColor,
    required this.levelTwoColor,
    required this.levelThreeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final animatedMinutes = minutes * animationValue;

    // ═══════════════════════════════════════════════════════════════
    // BACKGROUND CIRCLE - 전체 배경 원
    // ═══════════════════════════════════════════════════════════════
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (animatedMinutes <= 0) return;

    // ═══════════════════════════════════════════════════════════════
    // STAGE 1: 0-30분 (회색 → 파란색) - 전체 원 사용
    // ═══════════════════════════════════════════════════════════════
    if (animatedMinutes <= 30) {
      // Stage 1 진행률 (0-30분을 0-1로 정규화)
      final stage1Progress = (animatedMinutes / 30).clamp(0.0, 1.0);
      final stage1Angle = 2 * math.pi * stage1Progress;

      // 그라데이션 설정 - 회색에서 파란색으로
      final stage1Gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + stage1Angle,
        colors: [
          levelOneColor,
          Color.lerp(levelOneColor, levelTwoColor, stage1Progress * 0.5)!,
          Color.lerp(levelOneColor, levelTwoColor, stage1Progress)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final stage1Paint = Paint()
        ..shader = stage1Gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Stage 1 호 그리기
      canvas.drawArc(
        rect,
        -math.pi / 2,
        stage1Angle,
        false,
        stage1Paint,
      );

      // 진행 중 광채 효과
      if (stage1Progress > 0) {
        final glowPaint = Paint()
          ..color = Color.lerp(levelOneColor, levelTwoColor, stage1Progress)!.withOpacity(0.2)
          ..strokeWidth = strokeWidth * 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawArc(
          rect,
          -math.pi / 2,
          stage1Angle,
          false,
          glowPaint,
        );
      }
    }

    // ═══════════════════════════════════════════════════════════════
    // STAGE 2: 30분 이상 - Stage 1 완성 + Stage 2 오버레이
    // ═══════════════════════════════════════════════════════════════
    if (animatedMinutes > 30) {
      // 1. 먼저 Stage 1을 100% 완성된 상태로 그리기 (파란색 전체 원)
      final fullStage1Gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi),
        colors: [
          levelTwoColor.withOpacity(0.8),
          levelTwoColor,
          levelTwoColor.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final fullStage1Paint = Paint()
        ..shader = fullStage1Gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, fullStage1Paint);

      // 2. Stage 2 진행률 계산 (30-120분을 0-1로 정규화)
      final stage2Progress = ((animatedMinutes - 30) / 90).clamp(0.0, 1.0);
      final stage2Angle = 2 * math.pi * stage2Progress;

      // 3. Stage 2 오버레이 (파란색 → 금색)
      final stage2Gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + stage2Angle,
        colors: [
          levelTwoColor,
          Color.lerp(levelTwoColor, levelThreeColor, stage2Progress * 0.5)!,
          Color.lerp(levelTwoColor, levelThreeColor, stage2Progress)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final stage2Paint = Paint()
        ..shader = stage2Gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Stage 2 호 그리기 (오버레이)
      canvas.drawArc(
        rect,
        -math.pi / 2,
        stage2Angle,
        false,
        stage2Paint,
      );

      // Stage 2 광채 효과
      if (stage2Progress > 0) {
        final glowPaint = Paint()
          ..color = Color.lerp(levelTwoColor, levelThreeColor, stage2Progress)!.withOpacity(0.3)
          ..strokeWidth = strokeWidth * 1.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);

        canvas.drawArc(
          rect,
          -math.pi / 2,
          stage2Angle,
          false,
          glowPaint,
        );
      }

      // 120분 달성 시 특별 효과
      if (animatedMinutes >= 120) {
        // 전체 원에 황금빛 광채
        final achievementPaint = Paint()
          ..color = levelThreeColor.withOpacity(0.15)
          ..strokeWidth = strokeWidth * 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

        canvas.drawCircle(center, radius, achievementPaint);

        // 반짝이는 효과
        for (int i = 0; i < 8; i++) {
          final angle = (2 * math.pi / 8) * i + (animationValue * math.pi);
          final starRadius = radius + 12;
          final starPoint = Offset(
            center.dx + starRadius * math.cos(angle),
            center.dy + starRadius * math.sin(angle),
          );

          final starOpacity = 0.5 + 0.5 * math.sin(animationValue * 6 + i);
          canvas.drawCircle(
            starPoint,
            2.5,
            Paint()
              ..color = levelThreeColor.withOpacity(starOpacity)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          );
        }
      }
    }

    // ═══════════════════════════════════════════════════════════════
    // PROGRESS INDICATOR - 현재 진행 지점 표시
    // ═══════════════════════════════════════════════════════════════
    if (animatedMinutes > 0) {
      // 현재 각도 계산
      final currentAngle = animatedMinutes <= 30
          ? -math.pi / 2 + (2 * math.pi * (animatedMinutes / 30))
          : -math.pi / 2 + (2 * math.pi * ((animatedMinutes - 30) / 90));

      final currentPoint = Offset(
        center.dx + radius * math.cos(currentAngle),
        center.dy + radius * math.sin(currentAngle),
      );

      // 현재 색상
      final currentColor = animatedMinutes <= 30
          ? Color.lerp(levelOneColor, levelTwoColor, animatedMinutes / 30)!
          : Color.lerp(levelTwoColor, levelThreeColor, (animatedMinutes - 30) / 90)!;

      // 펄스 효과
      final pulseRadius = 6 + 2 * math.sin(animationValue * 4 * math.pi);

      // 외부 광채
      canvas.drawCircle(
        currentPoint,
        pulseRadius,
        Paint()
          ..color = currentColor.withOpacity(0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // 내부 점
      canvas.drawCircle(
        currentPoint,
        4,
        Paint()
          ..color = currentColor
          ..style = PaintingStyle.fill,
      );

      // 중심 흰색 점
      canvas.drawCircle(
        currentPoint,
        1.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! FocusCircularProgressPainter) return true;
    return oldDelegate.minutes != minutes ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.levelOneColor != levelOneColor ||
        oldDelegate.levelTwoColor != levelTwoColor ||
        oldDelegate.levelThreeColor != levelThreeColor;
  }
}