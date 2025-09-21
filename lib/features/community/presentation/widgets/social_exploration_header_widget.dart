import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';

/// 📱 소셜 탐험 헤더 위젯
/// RPG 게임의 '모험가 상태 정보' 컨셉으로 설계
class SocialExplorationHeaderWidget extends ConsumerWidget {
  // ✅ ConsumerWidget 사용
  final bool isChallenge;

  const SocialExplorationHeaderWidget({
    super.key,
    required this.isChallenge,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ ref 매개변수 추가
    final user = ref.watch(globalUserProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 사용자 아바타
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0] : 'U',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 사용자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lv.${user.level} ${user.title}',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // 상태 아이콘
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isChallenge ? Icons.emoji_events : Icons.groups,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 탐험 정보
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.social_distance,
                  label: '사교성',
                  value: '${user.stats.sociality.toStringAsFixed(1)}',
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.psychology,
                  label: '의지력',
                  value: '${user.stats.willpower.toStringAsFixed(1)}',
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 탐험 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              isChallenge
                  ? '🏆 새로운 도전을 통해 성장해보세요!'
                  : '🤝 새로운 모험가들과 함께 여정을 시작하세요!',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
