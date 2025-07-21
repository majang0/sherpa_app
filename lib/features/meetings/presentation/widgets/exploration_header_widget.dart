import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/providers/global_meeting_provider.dart';

/// 🎮 탐험 헤더 위젯 - 게임화된 참여 유도 대시보드
/// RPG 게임의 '모험가 상태 정보' + '길드 게시판 안내' 컨셉
class ExplorationHeaderWidget extends ConsumerWidget {
  final bool isChallenge;
  final GlobalUser user;

  const ExplorationHeaderWidget({
    super.key,
    required this.isChallenge,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingStats = ref.watch(globalMeetingStatsProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🎯 상단: 레벨 & 칭호 영역
          _buildTopSection(),
          
          // 📊 하단: 통계 영역
          _buildStatsSection(meetingStats),
        ],
      ),
    );
  }



  /// 🎯 상단 영역 - 레벨 & 칭호
  Widget _buildTopSection() {
    final progress = user.experience / 1000; // 임시 계산
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isChallenge 
            ? LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.08),
                  AppColors.accent.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // 레벨 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Lv.${user.level}',
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isChallenge ? AppColors.accent : AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isChallenge 
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isChallenge 
                              ? AppColors.accent.withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        user.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isChallenge ? AppColors.accent : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getWelcomeMessage(),
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          
          // 경험치 원형 프로그레스
          Container(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress % 1.0,
                    backgroundColor: (isChallenge ? AppColors.accent : AppColors.primary).withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isChallenge ? AppColors.accent : AppColors.primary,
                    ),
                    strokeWidth: 6,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '경험치',
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${((progress % 1.0) * 100).toInt()}%',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isChallenge ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 통계 영역
  Widget _buildStatsSection(GlobalMeetingStats meetingStats) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (isChallenge) ..._buildChallengeStats(meetingStats)
          else ..._buildMeetingStats(meetingStats),
        ],
      ),
    );
  }

  /// 🤝 모임 통계
  List<Widget> _buildMeetingStats(GlobalMeetingStats meetingStats) {
    return [
      Expanded(
        child: _buildModernStatCard(
          icon: Icons.people_rounded,
          iconColor: AppColors.primary,
          label: '참가 모임',
          value: '${meetingStats.totalParticipated}',
          unit: '회',
          backgroundColor: AppColors.primary.withValues(alpha: 0.05),
          borderColor: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildModernStatCard(
          icon: Icons.forum_rounded,
          iconColor: AppColors.accent,
          label: '사교성',
          value: '${user.stats.sociality.toStringAsFixed(1)}',
          unit: '',
          backgroundColor: AppColors.accent.withValues(alpha: 0.05),
          borderColor: AppColors.accent.withValues(alpha: 0.15),
          isStatValue: true,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildModernStatCard(
          icon: Icons.star_rounded,
          iconColor: AppColors.warning,
          label: '만족도',
          value: meetingStats.satisfactionGrade,
          unit: '',
          backgroundColor: AppColors.warning.withValues(alpha: 0.05),
          borderColor: AppColors.warning.withValues(alpha: 0.15),
        ),
      ),
    ];
  }

  /// 🏆 챌린지 통계
  List<Widget> _buildChallengeStats(GlobalMeetingStats meetingStats) {
    return [
      Expanded(
        child: _buildModernStatCard(
          icon: Icons.emoji_events_rounded,
          iconColor: AppColors.warning,
          label: '완료',
          value: '${meetingStats.totalParticipated}', // TODO: 실제 챌린지 완료 수
          unit: '개',
          backgroundColor: AppColors.warning.withValues(alpha: 0.05),
          borderColor: AppColors.warning.withValues(alpha: 0.15),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildModernStatCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.error,
          label: '의지력',
          value: '${user.stats.willpower.toStringAsFixed(1)}',
          unit: '',
          backgroundColor: AppColors.error.withValues(alpha: 0.05),
          borderColor: AppColors.error.withValues(alpha: 0.15),
          isStatValue: true,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildModernStatCard(
          icon: Icons.flash_on_rounded,
          iconColor: AppColors.accent,
          label: '연속',
          value: '${user.dailyRecords.consecutiveDays}',
          unit: '일',
          backgroundColor: AppColors.accent.withValues(alpha: 0.05),
          borderColor: AppColors.accent.withValues(alpha: 0.15),
        ),
      ),
    ];
  }

  /// 📈 모던한 통계 카드
  Widget _buildModernStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    required Color backgroundColor,
    required Color borderColor,
    bool isStatValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const Spacer(),
              if (unit.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    unit,
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: isStatValue ? 24 : 28,
              fontWeight: FontWeight.w900,
              color: iconColor,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }



  /// 💬 환영 메시지 생성 (이름 제거)
  String _getWelcomeMessage() {
    if (isChallenge) {
      final messages = [
        '새로운 챌린지로 의지력을 시험해보세요!',
        '오늘도 도전할 준비가 되셨나요?',
        '더 강한 자신을 만나는 여정이 시작됩니다!',
      ];
      
      // 의지력 수치에 따른 메시지 선택
      final willpower = user.stats.willpower;
      if (willpower >= 8.0) {
        return messages[2]; // 높은 의지력
      } else if (willpower >= 5.0) {
        return messages[1]; // 중간 의지력
      } else {
        return messages[0]; // 낮은 의지력
      }
    } else {
      final messages = [
        '모임에 참여하여 사교성을 향상시켜보세요!',
        '새로운 인연과 경험이 기다리고 있어요!',
        '함께하는 모험이 가장 즐거운 경험입니다!',
      ];
      
      // 사교성 수치에 따른 메시지 선택
      final sociality = user.stats.sociality;
      if (sociality >= 8.0) {
        return messages[2]; // 높은 사교성
      } else if (sociality >= 5.0) {
        return messages[1]; // 중간 사교성
      } else {
        return messages[0]; // 낮은 사교성
      }
    }
  }
}
