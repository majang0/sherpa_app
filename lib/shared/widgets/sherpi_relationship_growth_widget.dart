import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/sherpi/relationship/providers/relationship_provider.dart';
import '../models/sherpi_relationship_model.dart';
import '../../core/theme/modern_colors.dart';

/// Week 3: 관계 성장 시각화 위젯 - 2025 Premium Design
///
/// 사용자와 셰르피의 관계 레벨, 성장 진행도,
/// 감정 동기화 수준을 Glass Morphism 디자인으로 시각화합니다.
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
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: ModernColors.premiumShadow(
            primaryColor: _getRelationshipColor(relationship.intimacyLevel),
            lightColor: _getRelationshipColor(relationship.intimacyLevel)
                .withValues(alpha: 0.5),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
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
            ),
          ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.1, end: 0, duration: 600.ms);
  }

  /// 🎨 관계 레벨 헤더 - Premium Badge Design
  Widget _buildRelationshipHeader(SherpiRelationship relationship) {
    final personalization = relationship.personalizationSettings;
    final relationshipColor = _getRelationshipColor(relationship.intimacyLevel);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Premium level badge with solid color
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: relationshipColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: ModernColors.premiumShadow(
                      primaryColor: relationshipColor,
                      lightColor: relationshipColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: ModernColors.surface,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Lv.${relationship.intimacyLevel}',
                        style: GoogleFonts.notoSans(
                          color: ModernColors.surface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(duration: 1500.ms, delay: 1000.ms),
                const SizedBox(width: 10),
                Text(
                  relationship.relationshipTitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${personalization.userNickname}와 ${personalization.sherpiNickname}',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
        // 감정 동기화 아이콘
        _buildEmotionalSyncIcon(relationship.emotionalSync),
      ],
    );
  }

  /// 💙 친밀도 진행도 바 - Glass Morphism with Responsive Design
  Widget _buildIntimacyProgressBar(SherpiRelationship relationship) {
    final progress = _calculateLevelProgress(relationship);
    final nextLevel =
        relationship.intimacyLevel < 10 ? relationship.intimacyLevel + 1 : 10;
    final relationshipColor = _getRelationshipColor(relationship.intimacyLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernColors.softShadow(
          primaryColor: relationshipColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 정보 바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 현재 레벨 배지 - 2025 Filled Style
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: relationshipColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: ModernColors.softShadow(
                    primaryColor: relationshipColor,
                  ),
                ),
                child: Text(
                  'Lv.${relationship.intimacyLevel}',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.surface,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              // 중앙 - 다음 레벨까지 남은 횟수 (가장 강조) - 2025 Bold Style
              if (relationship.intimacyLevel < 10) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        relationshipColor,
                        relationshipColor.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: ModernColors.premiumShadow(
                      primaryColor: relationshipColor,
                      lightColor: relationshipColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: ModernColors.surface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${relationship.interactionsToNextLevel}회 남음',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ModernColors.surface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: ModernColors.reward,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: ModernColors.rewardShadow(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: ModernColors.surface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '최고 레벨!',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ModernColors.surface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 진행률 퍼센트
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 🔧 반응형 진행도 바 (FIXED OVERFLOW)
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 10,
                decoration: BoxDecoration(
                  color: ModernColors.gray100,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Stack(
                  children: [
                    // Solid color progress fill
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                      height: 10,
                      decoration: BoxDecoration(
                        color: relationshipColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: relationshipColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // 하단 상세 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재: ${relationship.totalInteractions}회',
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textTertiary,
                ),
              ),
              if (relationship.intimacyLevel < 10)
                Text(
                  '목표: ${(relationship.intimacyLevel + 1) * 100}회 (Lv.$nextLevel)',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textTertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.08, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  /// 💗 감정 동기화 게이지 - Modern Circular Indicator
  Widget _buildEmotionalSyncGauge(SherpiRelationship relationship) {
    final emotionColor = _getEmotionalSyncColor(relationship.emotionalSync);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernColors.softShadow(
          primaryColor: emotionColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '감정 동기화',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: emotionColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: emotionColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  relationship.emotionalSyncDescription,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.surface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Modern circular indicator
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    backgroundColor: ModernColors.gray100,
                    valueColor: AlwaysStoppedAnimation(
                      ModernColors.gray100,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),

                // Progress circle
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: relationship.emotionalSync,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(emotionColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),

                // Bold Filled Circle - 2025 Emotional Design
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: emotionColor,
                    boxShadow: [
                      BoxShadow(
                        color: emotionColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${(relationship.emotionalSync * 100).toInt()}%',
                      style: GoogleFonts.notoSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: ModernColors.surface,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 2000.ms,
                          color: ModernColors.surface.withValues(alpha: 0.5),
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

  /// 💖 감정 동기화 아이콘 - Premium Pulsing Design
  Widget _buildEmotionalSyncIcon(double sync) {
    IconData icon;
    Color color;

    if (sync >= 0.8) {
      icon = Icons.favorite;
      color = ModernColors.thoughtBright;
    } else if (sync >= 0.6) {
      icon = Icons.favorite;
      color = ModernColors.thoughtMedium;
    } else if (sync >= 0.4) {
      icon = Icons.favorite_border;
      color = ModernColors.calmMedium;
    } else {
      icon = Icons.favorite_border;
      color = ModernColors.gray400;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  /// 📊 상세 통계 섹션
  Widget _buildDetailedStats(SherpiRelationship relationship) {
    final daysSinceMeeting =
        DateTime.now().difference(relationship.firstMeetingDate).inDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ModernColors.gray200.withValues(alpha: 0.5),
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
            ModernColors.primary,
          ),
          const Divider(height: 16),
          _buildStatRow(
            '총 상호작용',
            '${relationship.totalInteractions}회',
            Icons.chat_bubble_outline,
            ModernColors.success,
          ),
          const Divider(height: 16),
          _buildStatRow(
            '연속 대화',
            '${relationship.consecutiveDays}일',
            Icons.local_fire_department,
            ModernColors.warning,
          ),
          const Divider(height: 16),
          _buildStatRow(
            '특별한 순간',
            '${relationship.specialMoments.length}개',
            Icons.star,
            ModernColors.accent,
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
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 📈 상호작용 히스토리 차트
  Widget _buildInteractionChart(SherpiRelationship relationship) {
    // 최근 7일간의 상호작용 데이터를 가상으로 생성
    final List<FlSpot> spots = List.generate(7, (index) {
      // 실제로는 날짜별 상호작용 데이터를 사용
      final value = 5.0 + (index * 2) + (index % 2 * 3);
      return FlSpot(index.toDouble(), value);
    });

    final relationshipColor = _getRelationshipColor(relationship.intimacyLevel);

    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ModernColors.gray200.withValues(alpha: 0.5),
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
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: relationshipColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: ModernColors.surface,
                          strokeWidth: 2,
                          strokeColor: relationshipColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: relationshipColor.withValues(alpha: 0.1),
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

  /// 🧮 레벨 진행도 계산
  double _calculateLevelProgress(SherpiRelationship relationship) {
    if (relationship.intimacyLevel >= 10) return 1.0;

    final currentLevelRequirement = relationship.intimacyLevel * 100;
    final nextLevelRequirement = (relationship.intimacyLevel + 1) * 100;
    final currentProgress =
        relationship.totalInteractions - currentLevelRequirement;
    final totalRequired = nextLevelRequirement - currentLevelRequirement;

    return (currentProgress / totalRequired).clamp(0.0, 1.0);
  }

  /// 🎨 관계 레벨별 색상 (ModernColors only)
  Color _getRelationshipColor(int level) {
    if (level >= 9) return const Color(0xFF9C27B0); // Purple
    if (level >= 7) return ModernColors.accent; // Indigo
    if (level >= 5) return ModernColors.primary; // Blue
    if (level >= 3) return ModernColors.success; // Green
    return ModernColors.meeting; // Cyan
  }

  /// 💙 감정 동기화 레벨별 색상 (ModernColors emotion system)
  Color _getEmotionalSyncColor(double sync) {
    if (sync >= 0.8) return ModernColors.thoughtBright; // High sync
    if (sync >= 0.6) return ModernColors.thoughtMedium;
    if (sync >= 0.4) return ModernColors.calmMedium;
    if (sync >= 0.2) return ModernColors.joyMedium;
    return ModernColors.gray400; // Low sync
  }
}
