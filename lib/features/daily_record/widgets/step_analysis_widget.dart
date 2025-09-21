// lib/features/daily_record/widgets/step_analysis_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/modern_colors.dart';
import '../../../shared/providers/global_user_provider.dart';

class StepAnalysisWidget extends ConsumerWidget {
  const StepAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    final stepData = user.dailyRecords;
    final stepHistoryAsync = ref.watch(stepHistoryProvider);
    final stepStatsAsync = ref.watch(stepStatisticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인 카드: 걸음수 분석 헤더 + 오늘의 걸음수 + 랭킹
        _buildMainCard(stepData, stepStatsAsync),
        const SizedBox(height: 16),

        // 트렌드 카드: 14일 흐름 그래프
        _buildTrendCard(stepHistoryAsync),
        const SizedBox(height: 16),

        // 통계 카드: 요약 정보
        _buildStatsCard(stepStatsAsync),
      ],
    );
  }

  /// 메인 카드: 걸음수 분석 헤더 + 오늘의 걸음수 + 랭킹
  Widget _buildMainCard(
      dynamic stepData, AsyncValue<StepStatistics> stepStatsAsync) {
    const target = 6000;
    final currentSteps = (stepData.todaySteps as num).toInt();
    final progress = (currentSteps / target).clamp(0.0, 1.0);
    final isCompleted = currentSteps >= target;
    final remainingSteps = isCompleted ? 0 : target - currentSteps;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 걸음수 분석 제목 + 랭킹
          Row(
            children: [
              const Icon(
                Icons.directions_walk,
                color: ModernColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '걸음수 분석',
                          style: GoogleFonts.notoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        stepStatsAsync.when(
                          data: (stats) => _buildRankingBadge(stats.totalSteps),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 오늘의 걸음수 섹션
          Row(
            children: [
              // 왼쪽: 걸음수 정보
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 오늘 라벨
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ModernColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '오늘',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 현재 걸음수 (가장 중요한 정보)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatStepsExact(currentSteps),
                          style: GoogleFonts.notoSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: ModernColors.textPrimary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '걸음',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: ModernColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 목표 정보
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? ModernColors.success
                                : ModernColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isCompleted
                                ? '목표 달성 완료! 축하해요 🎉'
                                : '목표까지 ${_formatStepsExact(remainingSteps)} 남았어요',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isCompleted
                                  ? ModernColors.success
                                  : ModernColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // 오른쪽: 원형 진행률 그래프
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    // 배경 원
                    const SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: ModernColors.borderLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ModernColors.borderLight,
                        ),
                      ),
                    ),
                    // 진행률 원
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted
                              ? ModernColors.success
                              : ModernColors.primary,
                        ),
                      ),
                    ),
                    // 중앙 텍스트
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(progress * 100).round()}%',
                              style: GoogleFonts.notoSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isCompleted
                                    ? ModernColors.success
                                    : ModernColors.primary,
                              ),
                            ),
                            Text(
                              '달성',
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                color: ModernColors.textSecondary,
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
          ),
        ],
      ),
    );
  }

  /// 14일 트렌드 카드 (흐름 그래프)
  Widget _buildTrendCard(AsyncValue<List<DailyStepData>> stepHistoryAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: ModernColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '14일 활동 흐름',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          stepHistoryAsync.when(
            data: (stepHistory) => _buildLineChart(stepHistory),
            loading: () => const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ModernColors.primary),
                ),
              ),
            ),
            error: (error, stack) => SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  '데이터를 불러올 수 없습니다',
                  style: GoogleFonts.notoSans(
                    color: ModernColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 흐름 그래프 (Line Chart)
  Widget _buildLineChart(List<DailyStepData> stepHistory) {
    if (stepHistory.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: GoogleFonts.notoSans(
              color: ModernColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final maxSteps =
        stepHistory.map((d) => d.steps).reduce((a, b) => a > b ? a : b);
    final minSteps =
        stepHistory.map((d) => d.steps).reduce((a, b) => a < b ? a : b);
    const goal = 6000;

    // 차트 데이터 생성
    final spots = stepHistory.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final steps = entry.value.steps.toDouble();
      return FlSpot(index, steps);
    }).toList();

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: goal.toDouble(),
            getDrawingHorizontalLine: (value) {
              if (value == goal.toDouble()) {
                return FlLine(
                  color: Colors.amber.shade600,
                  strokeWidth: 2,
                  dashArray: [6, 4],
                );
              }
              return const FlLine(
                color: ModernColors.borderLight,
                strokeWidth: 0.5,
              );
            },
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= stepHistory.length) {
                    return const SizedBox();
                  }

                  final data = stepHistory[index];
                  final isToday = index == stepHistory.length - 1;
                  final showLabel = isToday || index % 7 == 0;

                  if (!showLabel) return const SizedBox();

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      isToday ? '오늘' : '${data.date.month}/${data.date.day}',
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        color: isToday
                            ? ModernColors.primary
                            : ModernColors.textSecondary,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (stepHistory.length - 1).toDouble(),
          minY: (minSteps * 0.8).clamp(0, double.infinity),
          maxY: (maxSteps * 1.2).clamp(goal.toDouble() * 1.2, double.infinity),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: ModernColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final isToday = index == stepHistory.length - 1;
                  final steps = spot.y.toInt();
                  final isGoalAchieved = steps >= goal;

                  return FlDotCirclePainter(
                    radius: isToday ? 5 : 3,
                    color: isToday
                        ? ModernColors.primary
                        : isGoalAchieved
                            ? ModernColors.success
                            : ModernColors.textTertiary,
                    strokeWidth: isToday ? 2 : 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: ModernColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: ModernColors.textPrimary.withValues(alpha: 0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final steps = spot.y.toInt();
                  final date = stepHistory[index].date;
                  final isToday = index == stepHistory.length - 1;
                  final dateText = isToday ? '오늘' : '${date.month}/${date.day}';

                  return LineTooltipItem(
                    '$dateText\n${_formatStepsExact(steps)} 걸음',
                    GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 통계 요약 카드
  Widget _buildStatsCard(AsyncValue<StepStatistics> stepStatsAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: ModernColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '통계 요약',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          stepStatsAsync.when(
            data: (stats) => _buildStatsGrid(stats),
            loading: () => const SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ModernColors.primary),
                ),
              ),
            ),
            error: (error, stack) => SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  '통계를 불러올 수 없습니다',
                  style: GoogleFonts.notoSans(
                    color: ModernColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 그리드
  Widget _buildStatsGrid(StepStatistics stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '주간 발걸음',
            _formatStepsExact((stats.weeklyAverage * 7).round()),
            ModernColors.primary,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatItem(
            '최고 발걸음',
            _formatStepsExact(stats.maxSteps),
            ModernColors.success,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatItem(
            '전체 발걸음',
            _formatStepsWithK(stats.totalSteps),
            ModernColors.accent,
          ),
        ),
      ],
    );
  }

  /// 개별 통계 아이템
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: ModernColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 랭킹 배지 위젯
  Widget _buildRankingBadge(int totalSteps) {
    final ranking = _calculateRanking(totalSteps);
    final rankingText = '상위 $ranking%';

    Color badgeColor;
    if (ranking <= 10) {
      badgeColor = ModernColors.success;
    } else if (ranking <= 30) {
      badgeColor = ModernColors.primary;
    } else if (ranking <= 50) {
      badgeColor = ModernColors.accent;
    } else {
      badgeColor = ModernColors.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            rankingText,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 전체 발걸음 기준 랭킹 계산 (예시 로직)
  int _calculateRanking(int totalSteps) {
    // 실제로는 서버에서 전체 사용자 데이터를 기반으로 계산해야 하지만,
    // 현재는 샘플 로직으로 구현
    if (totalSteps >= 500000) return 5; // 50만보 이상: 상위 5%
    if (totalSteps >= 300000) return 15; // 30만보 이상: 상위 15%
    if (totalSteps >= 200000) return 25; // 20만보 이상: 상위 25%
    if (totalSteps >= 100000) return 40; // 10만보 이상: 상위 40%
    if (totalSteps >= 50000) return 60; // 5만보 이상: 상위 60%
    if (totalSteps >= 20000) return 75; // 2만보 이상: 상위 75%
    return 90; // 그 외: 상위 90%
  }

  /// ✅ 정확한 걸음수 표시 (콤마 포함)
  String _formatStepsExact(int steps) {
    return NumberFormat('#,###').format(steps);
  }

  /// K단위로 걸음수 표시 (예: 123,456 → 123.5K)
  String _formatStepsWithK(int steps) {
    if (steps >= 1000) {
      final kSteps = steps / 1000;
      if (kSteps >= 100) {
        return '${kSteps.round()}K';
      } else {
        return '${kSteps.toStringAsFixed(1)}K';
      }
    }
    return steps.toString();
  }
}
