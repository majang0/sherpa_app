import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/sherpi/relationship/providers/relationship_provider.dart';
import '../models/sherpi_relationship_model.dart';

/// Week 3: 관계 성장 시각화 위젯
///
/// 사용자와 셰르피의 관계 레벨, 성장 진행도,
/// 감정 동기화 수준을 시각적으로 표현합니다.
class SherpiRelationshipGrowthWidget extends ConsumerStatefulWidget {
  final bool showFullStats;
  final VoidCallback? onTap;

  const SherpiRelationshipGrowthWidget({
    super.key,
    this.showFullStats = false,
    this.onTap,
  });

  @override
  ConsumerState<SherpiRelationshipGrowthWidget> createState() =>
      _SherpiRelationshipGrowthWidgetState();
}

class _SherpiRelationshipGrowthWidgetState
    extends ConsumerState<SherpiRelationshipGrowthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relationship = ref.watch(relationshipProvider);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getRelationshipColor(relationship.intimacyLevel)
                  .withOpacity(0.1),
              _getRelationshipColor(relationship.intimacyLevel)
                  .withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getRelationshipColor(relationship.intimacyLevel)
                .withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 관계 레벨 헤더
            _buildRelationshipHeader(relationship),
            const SizedBox(height: 20),

            // 친밀도 진행도 바
            _buildIntimacyProgressBar(relationship),
            const SizedBox(height: 16),

            // 감정 동기화 게이지
            _buildEmotionalSyncGauge(relationship),

            if (widget.showFullStats) ...[
              const SizedBox(height: 20),
              // 상세 통계
              _buildDetailedStats(relationship),
              const SizedBox(height: 16),
              // 상호작용 히스토리 차트
              _buildInteractionChart(relationship),
            ],
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.1, end: 0, duration: 600.ms),
    );
  }

  Widget _buildRelationshipHeader(SherpiRelationship relationship) {
    final personalization = relationship.personalizationSettings;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 레벨 배지
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRelationshipColor(relationship.intimacyLevel),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getRelationshipColor(relationship.intimacyLevel)
                            .withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lv.${relationship.intimacyLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms)
                    .then()
                    .shimmer(duration: 1500.ms, delay: 1000.ms),
                const SizedBox(width: 8),
                Text(
                  relationship.relationshipTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getRelationshipColor(relationship.intimacyLevel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${personalization.userNickname}와 ${personalization.sherpiNickname}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        // 감정 동기화 아이콘
        _buildEmotionalSyncIcon(relationship.emotionalSync),
      ],
    );
  }

  Widget _buildIntimacyProgressBar(SherpiRelationship relationship) {
    final progress = _calculateLevelProgress(relationship);
    final nextLevel =
        relationship.intimacyLevel < 10 ? relationship.intimacyLevel + 1 : 10;
    final levelColor = _getRelationshipColor(relationship.intimacyLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 정보 바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 현재 레벨 배지
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: levelColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Lv.${relationship.intimacyLevel}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: levelColor,
                  ),
                ),
              ),

              // 중앙 - 다음 레벨까지 남은 횟수 (가장 강조)
              if (relationship.intimacyLevel < 10) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        levelColor.withOpacity(0.15),
                        levelColor.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: levelColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: levelColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${relationship.interactionsToNextLevel}회 남음',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: levelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.15),
                        Colors.orange.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '최고 레벨!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 진행률 퍼센트
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 진행도 바 (깔끔한 디자인)
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  width: MediaQuery.of(context).size.width * progress,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        levelColor,
                        levelColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 하단 상세 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재: ${relationship.totalInteractions}회',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
              if (relationship.intimacyLevel < 10)
                Text(
                  '목표: ${(relationship.intimacyLevel + 1) * 100}회 (Lv.$nextLevel)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms);
  }

  Widget _buildEmotionalSyncGauge(SherpiRelationship relationship) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '감정 동기화',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              relationship.emotionalSyncDescription,
              style: TextStyle(
                fontSize: 12,
                color: _getEmotionalSyncColor(relationship.emotionalSync),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 반원 게이지 배경
              CustomPaint(
                size: const Size(200, 100),
                painter: _EmotionalSyncGaugePainter(
                  value: relationship.emotionalSync,
                  color: _getEmotionalSyncColor(relationship.emotionalSync),
                ),
              ),
              // 중앙 수치
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    '${(relationship.emotionalSync * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getEmotionalSyncColor(relationship.emotionalSync),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                          duration: 2000.ms,
                          color: Colors.white.withOpacity(0.3)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalSyncIcon(double sync) {
    IconData icon;
    Color color;

    if (sync >= 0.8) {
      icon = Icons.favorite;
      color = Colors.red;
    } else if (sync >= 0.6) {
      icon = Icons.favorite;
      color = Colors.pink;
    } else if (sync >= 0.4) {
      icon = Icons.favorite_border;
      color = Colors.pink[300]!;
    } else {
      icon = Icons.favorite_border;
      color = Colors.grey;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        );
      },
    );
  }

  Widget _buildDetailedStats(SherpiRelationship relationship) {
    final daysSinceMeeting =
        DateTime.now().difference(relationship.firstMeetingDate).inDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(
            '함께한 시간',
            '$daysSinceMeeting일',
            Icons.calendar_today,
            Colors.blue,
          ),
          const Divider(height: 16),
          _buildStatRow(
            '총 상호작용',
            '${relationship.totalInteractions}회',
            Icons.chat_bubble_outline,
            Colors.green,
          ),
          const Divider(height: 16),
          _buildStatRow(
            '연속 대화',
            '${relationship.consecutiveDays}일',
            Icons.local_fire_department,
            Colors.orange,
          ),
          const Divider(height: 16),
          _buildStatRow(
            '특별한 순간',
            '${relationship.specialMoments.length}개',
            Icons.star,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionChart(SherpiRelationship relationship) {
    // 최근 7일간의 상호작용 데이터를 가상으로 생성
    final List<FlSpot> spots = List.generate(7, (index) {
      // 실제로는 날짜별 상호작용 데이터를 사용
      final value = 5.0 + (index * 2) + (index % 2 * 3);
      return FlSpot(index.toDouble(), value);
    });

    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최근 7일 상호작용',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _getRelationshipColor(relationship.intimacyLevel),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor:
                              _getRelationshipColor(relationship.intimacyLevel),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _getRelationshipColor(relationship.intimacyLevel)
                          .withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateLevelProgress(SherpiRelationship relationship) {
    if (relationship.intimacyLevel >= 10) return 1.0;

    final currentLevelRequirement = relationship.intimacyLevel * 100;
    final nextLevelRequirement = (relationship.intimacyLevel + 1) * 100;
    final currentProgress =
        relationship.totalInteractions - currentLevelRequirement;
    final totalRequired = nextLevelRequirement - currentLevelRequirement;

    return (currentProgress / totalRequired).clamp(0.0, 1.0);
  }

  Color _getRelationshipColor(int level) {
    if (level >= 9) return Colors.purple;
    if (level >= 7) return Colors.indigo;
    if (level >= 5) return Colors.blue;
    if (level >= 3) return Colors.green;
    return Colors.teal;
  }

  Color _getEmotionalSyncColor(double sync) {
    if (sync >= 0.8) return Colors.red;
    if (sync >= 0.6) return Colors.pink;
    if (sync >= 0.4) return Colors.orange;
    if (sync >= 0.2) return Colors.amber;
    return Colors.grey;
  }
}

// 감정 동기화 게이지 페인터
class _EmotionalSyncGaugePainter extends CustomPainter {
  final double value;
  final Color color;

  _EmotionalSyncGaugePainter({
    required this.value,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // 배경 아크
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      3.14159,
      3.14159,
      false,
      backgroundPaint,
    );

    // 진행도 아크
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      3.14159,
      3.14159 * value,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
