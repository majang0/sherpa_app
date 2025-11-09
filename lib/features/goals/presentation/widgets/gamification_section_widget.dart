import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';

/// Gamification Section Widget
///
/// 루틴 스트릭과 게임화 요소 (AI goal.txt 요구사항)
/// 2025 Material Design 3: Fire streaks, golden shadows, progress visualization
class GamificationSectionWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int averageStreak;
  final double progressToNextLevel;
  final int daysToNextLevel;

  const GamificationSectionWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageStreak,
    required this.progressToNextLevel,
    required this.daysToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.joyBright.withValues(alpha: 0.1),
            ModernColors.calmBright.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ModernColors.joyBright.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department,
                  color: ModernColors.climbing, size: 28),
              const SizedBox(width: 12),
              Text(
                '연속 달성 스트릭',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _buildStreakBadge(
                days: currentStreak,
                label: '이번 주',
                color: ModernColors.calmBright,
              ),
              const SizedBox(width: 12),
              _buildStreakBadge(
                days: longestStreak,
                label: '최장 기록',
                color: ModernColors.climbing,
              ),
              const SizedBox(width: 12),
              _buildStreakBadge(
                days: averageStreak,
                label: '평균',
                color: ModernColors.meeting,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressToNextLevel,
              minHeight: 12,
              backgroundColor: ModernColors.gray200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(ModernColors.climbing),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '다음 레벨까지 $daysToNextLevel일 남았어요!',
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

  Widget _buildStreakBadge({
    required int days,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$days일',
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
                fontSize: 11,
                color: ModernColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
