import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/modern_colors.dart';

/// Statistics Overview Widget
///
/// 목표 진행 현황을 시각화: 달성/진행/예정 통계
/// 2025 Material Design 3: Data visualization, color-coded progress
class StatisticsOverviewWidget extends StatelessWidget {
  final int achievedCount;
  final int inProgressCount;
  final int upcomingCount;
  final int totalCount;

  const StatisticsOverviewWidget({
    super.key,
    required this.achievedCount,
    required this.inProgressCount,
    required this.upcomingCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final achievementRate = totalCount > 0 ? achievedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.quest.withValues(alpha: 0.1),
            ModernColors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernColors.quest.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '목표 진행 현황',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ModernColors.quest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '이번 달',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.quest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress indicators
          Row(
            children: [
              _buildProgressStat(
                icon: Icons.sports_score,
                label: '달성',
                value: '$achievedCount',
                total: '$totalCount',
                color: ModernColors.success,
              ),
              const SizedBox(width: 16),
              _buildProgressStat(
                icon: Icons.schedule,
                label: '진행중',
                value: '$inProgressCount',
                total: '$totalCount',
                color: ModernColors.exercise,
              ),
              const SizedBox(width: 16),
              _buildProgressStat(
                icon: Icons.upcoming_outlined,
                label: '예정',
                value: '$upcomingCount',
                total: '$totalCount',
                color: ModernColors.meeting,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: achievementRate,
              minHeight: 8,
              backgroundColor: ModernColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(ModernColors.quest),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '전체 달성률 ${(achievementRate * 100).toInt()}%',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat({
    required IconData icon,
    required String label,
    required String value,
    required String total,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: '/$total',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
