import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/modern_colors.dart';

/// Statistics Overview Widget
///
/// 2025 Material Design 3: Clean data visualization with filled card
/// NO gradients, solid colors, single shadow
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF), // Light blue tint (solid)
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '목표 진행 현황',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Progress indicators (Grid)
          Row(
            children: [
              _buildProgressStat(
                icon: Icons.check_circle_outline,
                label: '달성',
                value: achievedCount,
                total: totalCount,
                color: ModernColors.success,
              ),
              const SizedBox(width: 12),
              _buildProgressStat(
                icon: Icons.pending_outlined,
                label: '진행중',
                value: inProgressCount,
                total: totalCount,
                color: ModernColors.climbing,
              ),
              const SizedBox(width: 12),
              _buildProgressStat(
                icon: Icons.upcoming_outlined,
                label: '예정',
                value: upcomingCount,
                total: totalCount,
                color: ModernColors.meeting,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress bar section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '전체 달성률',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: achievementRate,
                        minHeight: 8,
                        backgroundColor: Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ModernColors.climbing,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(achievementRate * 100).toInt()}%',
                style: GoogleFonts.notoSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.climbing,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Progress Stat Item - 2025 Material Design 3
  /// Clean, minimal design with solid colors
  Widget _buildProgressStat({
    required IconData icon,
    required String label,
    required int value,
    required int total,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
