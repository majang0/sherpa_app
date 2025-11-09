import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/models/global_user_model.dart';

/// Hero Header Widget
///
/// 사용자 환영 + 핵심 통계 미리보기
/// 2025 Material Design 3 trends: Glass morphism, generous spacing, quick stats
class HeroHeaderWidget extends StatelessWidget {
  final GlobalUser user;
  final int activeGoalsCount;
  final int completedRoutines;
  final int totalRoutines;
  final double completionRate;

  const HeroHeaderWidget({
    super.key,
    required this.user,
    required this.activeGoalsCount,
    required this.completedRoutines,
    required this.totalRoutines,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.primary.withValues(alpha: 0.05),
            ModernColors.background,
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 1. User Greeting with Avatar
          Row(
            children: [
              // Glass morphism avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ModernColors.quest,
                      ModernColors.questLight,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.quest.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: ModernColors.questLight.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              // User name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.name}님, 안녕하세요!',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘도 목표를 향해 나아가요',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Quick Stats Preview (3 cards in row)
          Row(
            children: [
              _buildQuickStatCard(
                icon: Icons.flag_outlined,
                label: '활성 목표',
                value: '$activeGoalsCount개',
                color: ModernColors.quest,
              ),
              const SizedBox(width: 12),
              _buildQuickStatCard(
                icon: Icons.repeat_outlined,
                label: '오늘 루틴',
                value: '$completedRoutines/$totalRoutines',
                color: ModernColors.meeting,
              ),
              const SizedBox(width: 12),
              _buildQuickStatCard(
                icon: Icons.emoji_events_outlined,
                label: '달성률',
                value: '${(completionRate * 100).toInt()}%',
                color: ModernColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick Stat Card Helper
  Widget _buildQuickStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
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
