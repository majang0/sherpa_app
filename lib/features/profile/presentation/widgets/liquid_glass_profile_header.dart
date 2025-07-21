import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/models/user_level_progress.dart';
import '../../../../core/constants/app_colors.dart';
import 'profile_avatar_widget.dart';

class LiquidGlassProfileHeader extends ConsumerWidget {
  const LiquidGlassProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    final userTitle = ref.watch(globalUserTitleProvider);
    final pointData = ref.watch(globalPointProvider);
    final userProgress = ref.watch(userLevelProgressProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A).withValues(alpha: 0.1), // Navy Blue
            Color(0xFFEFF6FF).withValues(alpha: 0.3), // Light Sky Blue
            Colors.white,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 프로필 아바타
            Hero(
              tag: 'profile_avatar',
              child: ProfileAvatarWidget(
                user: user,
                size: 100,
                showLevelBadge: true,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 사용자 이름
            Text(
              user.name,
              style: GoogleFonts.notoSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A8A), // Navy Blue
                letterSpacing: -0.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 칭호와 레벨 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userTitle.title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Lv.${user.level}',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ✅ 경험치 바 (개선된 위치 - 사용자 정보 바로 아래)
            Container(
              width: 240, // 더 넓게 조정
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF3B82F6).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EXP',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${userProgress.currentLevelExp}/${userProgress.requiredExpForNextLevel}',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: userProgress.progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF3B82F6).withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '다음 레벨까지 ${userProgress.requiredExpForNextLevel - userProgress.currentLevelExp} XP',
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 소개말
            Text(
              '매일 1% 성장하며 인생의 주인공이 되어가는 중 🎬\n오늘보다 나은 내일을 위해!',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Color(0xFF475569), // Dark Slate Gray
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ✅ 팔로우/팔로워와 포인트 정보 (4개 통계)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialStat('팔로잉', '${_calculateFollowing(user)}', Color(0xFF3B82F6)),
                _buildSocialStat('팔로워', '${_calculateFollowers(user)}', Color(0xFF10B981)),
                _buildSocialStat('포인트', '${_formatPoints(pointData.totalPoints)}', Color(0xFFF59E0B)),
                _buildSocialStat('연속접속', '${user.dailyRecords.consecutiveDays}일', Color(0xFF8B5CF6)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // ✅ 현재 상태 태그들 (더 다양하게)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildInterestChip('러닝', Color(0xFF10B981)),
                _buildInterestChip('독서', Color(0xFFF59E0B)),
                _buildInterestChip('영화', Color(0xFF8B5CF6)),
                _buildInterestChip('클라이밍', Color(0xFF3B82F6)),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialStat(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ✅ 팔로잉 수 계산 (사용자 레벨과 활동량 기반으로 시뮬레이션)
  int _calculateFollowing(GlobalUser user) {
    // 레벨과 모임 참여 수에 따른 팔로잉 수 시뮬레이션
    final baseFollowing = user.level * 2;
    final meetingBonus = user.dailyRecords.meetingLogs.length;
    return (baseFollowing + meetingBonus).clamp(5, 150);
  }

  // ✅ 팔로워 수 계산 (사용자 레벨과 연속 접속일 기반으로 시뮬레이션)
  int _calculateFollowers(GlobalUser user) {
    // 레벨과 연속 접속일에 따른 팔로워 수 시뮬레이션
    final baseFollowers = user.level * 3;
    final streakBonus = user.dailyRecords.consecutiveDays * 2;
    final activityBonus = user.dailyRecords.climbingLogs.length;
    return (baseFollowers + streakBonus + activityBonus).clamp(3, 200);
  }

  // ✅ 포인트 포맷팅 (1000 이상은 K 단위로)
  String _formatPoints(int points) {
    if (points >= 10000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    } else if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }

  // ✅ 사용자 레벨에 따른 등급 표시
  String _getUserLevel(int level) {
    if (level >= 50) return '마스터';
    if (level >= 30) return '전문가';
    if (level >= 20) return '숙련자';
    if (level >= 10) return '중급자';
    return '초보자';
  }
}
