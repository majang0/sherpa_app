import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ 글로벌 데이터 시스템 Import
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/sherpa_card.dart';
import 'profile_avatar_widget.dart';
import 'level_badge_widget.dart';

class ProfileHeaderWidget extends ConsumerWidget {
  final bool isCompact;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;

  const ProfileHeaderWidget({
    super.key,
    this.isCompact = false,
    this.onProfileTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ 글로벌 데이터 시스템에서 사용자 데이터 가져오기
    final user = ref.watch(globalUserProvider);
    final userTitle = ref.watch(globalUserTitleProvider);

    if (isCompact) {
      return _buildCompactHeader(user, userTitle);
    }

    return _buildFullHeader(user, userTitle);
  }

  Widget _buildCompactHeader(GlobalUser user, UserTitle userTitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ProfileAvatarWidget(
            user: user, // ✅ GlobalUser 사용
            size: 40,
            onTap: onProfileTap,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name, // ✅ GlobalUser.name 사용
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                LevelBadgeWidget(
                  user: user, // ✅ GlobalUser 사용
                  isCompact: true,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(
              Icons.settings,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullHeader(GlobalUser user, UserTitle userTitle) {
    return SherpaCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ProfileAvatarWidget(
                  user: user, // ✅ GlobalUser 사용
                  size: 80,
                  onTap: onProfileTap,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name, // ✅ GlobalUser.name 사용
                              style: GoogleFonts.notoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: onSettingsTap,
                            icon: const Icon(
                              Icons.settings,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userTitle.title, // ✅ 실제 칭호 데이터 사용
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      LevelBadgeWidget(user: user), // ✅ GlobalUser 사용
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 성장 통계
            _buildGrowthStats(user),

            const SizedBox(height: 12),

            // 뱃지 컬렉션
            if (user.ownedBadgeIds.isNotEmpty) _buildBadgeCollection(user),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthStats(GlobalUser user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '총 XP',
            '${user.experience.toInt()}', // ✅ 실제 경험치 데이터
            Icons.star,
            AppColors.warning,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            '연속 접속',
            '${user.dailyRecords.consecutiveDays}일', // ✅ 실제 연속 접속일 데이터
            Icons.calendar_today,
            AppColors.primary,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            '보유 뱃지',
            '${user.ownedBadgeIds.length}개', // ✅ 실제 뱃지 개수
            Icons.emoji_events,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCollection(GlobalUser user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 보유 뱃지',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // ✅ 실제 뱃지 ID들을 표시 (추후 뱃지 마스터 데이터와 연동 가능)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: user.ownedBadgeIds
                .take(5)
                .map(
                  (badgeId) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      '🏆', // 추후 실제 뱃지 이모지로 대체 가능
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
                .toList(),
          ),
          if (user.ownedBadgeIds.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '외 ${user.ownedBadgeIds.length - 5}개',
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
