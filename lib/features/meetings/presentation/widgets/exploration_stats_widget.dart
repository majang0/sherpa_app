import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_meeting_provider.dart';

/// 📊 탐험 통계 위젯
/// 사용자의 모임/챌린지 관련 통계를 게임화된 형태로 표시
class ExplorationStatsWidget extends ConsumerWidget {
  final bool isChallenge;

  const ExplorationStatsWidget({
    super.key,
    required this.isChallenge,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    final meetingStats = ref.watch(globalMeetingStatsProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            isChallenge ? '🏆 내 챌린지 기록' : '🤝 내 모임 기록',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 통계 그리드
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: isChallenge ? '🏅' : '👥',
                  label: isChallenge ? '완료' : '참가',
                  value: '${meetingStats.totalParticipated}',
                  unit: isChallenge ? '개' : '회',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: isChallenge ? '🔥' : '💬',
                  label: isChallenge ? '의지력' : '사교성',
                  value: isChallenge 
                      ? user.stats.willpower.toStringAsFixed(1)
                      : user.stats.sociality.toStringAsFixed(1),
                  unit: '',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: isChallenge ? '⚡' : '⭐',
                  label: isChallenge ? '연속' : '만족도',
                  value: isChallenge 
                      ? '${user.dailyRecords.consecutiveDays}'
                      : meetingStats.satisfactionGrade,
                  unit: isChallenge ? '일' : '',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
