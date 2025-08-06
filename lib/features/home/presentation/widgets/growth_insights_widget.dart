import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Core
import '../../../../core/constants/app_colors.dart';

// Shared Providers
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_game_provider.dart';

// Shared Models
import '../../../../shared/models/global_user_model.dart';

class GrowthInsightsWidget extends ConsumerStatefulWidget {
  const GrowthInsightsWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<GrowthInsightsWidget> createState() =>
      _GrowthInsightsWidgetState();
}

class _GrowthInsightsWidgetState extends ConsumerState<GrowthInsightsWidget>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _numberController;
  late Animation<double> _chartAnimation;
  late Animation<double> _numberAnimation;

  @override
  void initState() {
    super.initState();

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _numberController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );

    _numberAnimation = CurvedAnimation(
      parent: _numberController,
      curve: Curves.easeOutCubic,
    );

    _chartController.forward();
    _numberController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final userPower = ref.watch(userClimbingPowerProvider);
    final totalPoints = ref.watch(globalTotalPointsProvider);
    final climbingStats = ref.watch(climbingStatisticsProvider);
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '성장 인사이트',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '최근 7일',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                // 왼쪽: 원형 차트
                Expanded(
                  flex: 4,
                  child: _buildRadialChart(user),
                ),
                const SizedBox(width: 20),
                // 오른쪽: 통계 리스트
                Expanded(
                  flex: 5,
                  child: _buildStatsList(user, userPower, totalPoints, climbingStats),
                ),
              ],
            ),
          ),
          
          // 하단 인사이트
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insights,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getInsightMessage(user, climbingStats),
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadialChart(GlobalUser user) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: RadialChartPainter(
              stats: user.stats,
              animation: _chartAnimation.value,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '종합',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _numberAnimation,
                    builder: (context, child) {
                      final avgStat = (user.stats.stamina + 
                                      user.stats.knowledge + 
                                      user.stats.technique + 
                                      user.stats.sociality + 
                                      user.stats.willpower) / 5;
                      return Text(
                        '${(avgStat * _numberAnimation.value).toStringAsFixed(1)}',
                        style: GoogleFonts.notoSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  Text(
                    '평균 능력치',
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsList(GlobalUser user, double userPower, int totalPoints, ClimbingStatistics stats) {
    return Column(
      children: [
        _buildStatItem(
          icon: Icons.flash_on,
          label: '등반력',
          value: userPower.toStringAsFixed(0),
          trend: '+${(userPower * 0.12).toStringAsFixed(0)}',
          trendPositive: true,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildStatItem(
          icon: Icons.trending_up,
          label: '성공률',
          value: '${(stats.successRate * 100).toStringAsFixed(0)}%',
          trend: stats.successRate > 0.7 ? '우수' : '양호',
          trendPositive: stats.successRate > 0.5,
          color: AppColors.success,
        ),
        const SizedBox(height: 12),
        _buildStatItem(
          icon: Icons.emoji_events,
          label: '총 경험치',
          value: '${(user.experience / 1000).toStringAsFixed(1)}K',
          trend: '레벨 ${user.level}',
          trendPositive: true,
          color: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String trend,
    required bool trendPositive,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _numberAnimation,
      builder: (context, child) {
        return Row(
          children: [
            Container(
              width: 36,
              height: 36,
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
                    label,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (trendPositive ? AppColors.success : AppColors.error)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trend,
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: trendPositive ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getInsightMessage(GlobalUser user, ClimbingStatistics stats) {
    if (stats.currentStreak > 3) {
      return '${stats.currentStreak}일 연속 등반 중! 꾸준한 성장이 인상적이에요.';
    } else if (stats.successRate > 0.8) {
      return '성공률이 매우 높아요! 더 어려운 산에 도전해보세요.';
    } else if (user.stats.stamina > user.stats.knowledge && user.stats.stamina > user.stats.technique) {
      return '체력이 뛰어나네요! 운동 관련 퀘스트를 더 해보세요.';
    } else if (user.stats.knowledge > user.stats.stamina && user.stats.knowledge > user.stats.technique) {
      return '지식이 풍부하시네요! 독서 모임에 참여해보세요.';
    } else {
      return '균형잡힌 성장을 하고 계세요! 계속 이대로 가세요.';
    }
  }
}

// 원형 차트 페인터
class RadialChartPainter extends CustomPainter {
  final GlobalStats stats;
  final double animation;

  RadialChartPainter({
    required this.stats,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 능력치별 아크
    final statData = [
      {'value': stats.stamina, 'color': AppColors.exercise},
      {'value': stats.knowledge, 'color': AppColors.reading},
      {'value': stats.technique, 'color': AppColors.primary},
      {'value': stats.sociality, 'color': AppColors.meeting},
      {'value': stats.willpower, 'color': AppColors.warning},
    ];

    double startAngle = -math.pi / 2;
    const double maxValue = 100.0;
    const double totalAngle = 2 * math.pi;
    const double sectionAngle = totalAngle / 5;

    for (int i = 0; i < statData.length; i++) {
      final data = statData[i];
      final value = (data['value'] as double) / maxValue;
      final sweepAngle = sectionAngle * 0.8 * value * animation;

      final paint = Paint()
        ..color = data['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sectionAngle;
    }
  }

  @override
  bool shouldRepaint(RadialChartPainter oldDelegate) => true;
}
