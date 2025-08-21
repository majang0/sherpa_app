import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../models/meeting_recommendation_model.dart' hide MeetingCategory;
import '../../providers/meeting_recommendation_provider.dart';
import '../../../meetings/models/available_meeting_model.dart';
import '../../../meetings/models/available_challenge_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../meetings/presentation/screens/meeting_detail_screen.dart';
import '../../../meetings/presentation/screens/meeting_application_screen.dart';

class SmartMeetingRecommendationWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<SmartMeetingRecommendationWidget> createState() =>
      _SmartMeetingRecommendationWidgetState();
}

class _SmartMeetingRecommendationWidgetState
    extends ConsumerState<SmartMeetingRecommendationWidget>
    with TickerProviderStateMixin {
  late AnimationController _aiIconController;
  late AnimationController _shimmerController;
  final Map<String, bool> _itemJoined = {};

  @override
  void initState() {
    super.initState();
    _aiIconController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _aiIconController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onJoinTap(dynamic item) {
    HapticFeedbackManager.mediumImpact();

    if (item is AvailableMeeting) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MeetingApplicationScreen(meeting: item),
        ),
      );
    } else if (item is AvailableChallenge) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('챌린지 참여 신청이 완료되었어요!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() {
        _itemJoined[item.id] = true;
      });
    }
  }

  void _onMeetingCardTap(AvailableMeeting meeting) {
    HapticFeedbackManager.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingDetailScreen(meeting: meeting),
      ),
    );
  }

  void _navigateToMeetingsTab() {
    HapticFeedbackManager.lightImpact();
    // 모임 탭(인덱스 3)으로 이동하도록 수정
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
          (route) => false,
      arguments: 3, // 모임 탭 인덱스로 변경
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meetingRecommendationProvider);
    final filteredData = ref.watch(filteredRecommendationsProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primaryLight.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _buildAIHeader(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildUniversityFilterTabs(state.selectedFilter ?? 'all'),
          ),
          const SizedBox(height: 20),
          if (state.isLoading)
            _buildAILoadingWidget()
          else if (state.error != null)
            _buildErrorWidget(state.error!)
          else
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildRecommendationList(filteredData),
            ),
        ],
      ),
    );
  }

  Widget _buildAIHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _aiIconController,
          builder: (context, child) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primarySoft,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  transform: GradientRotation(_aiIconController.value * 2 * math.pi),
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 맞춤 추천',
                style: GoogleFonts.notoSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '당신의 성장을 위한 완벽한 매칭',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _navigateToMeetingsTab,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dividerLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체보기',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityFilterTabs(String selectedFilter) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildFilterTab('전체', 'all', selectedFilter)),
          Expanded(child: _buildFilterTab('우리 대학', 'university', selectedFilter)),
          Expanded(child: _buildFilterTab('챌린지', 'challenge', selectedFilter)),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String filterType, String selectedFilter) {
    final isSelected = selectedFilter == filterType;
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.selection();
        ref.read(meetingRecommendationProvider.notifier).setFilter(filterType);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationList(List<dynamic> items) {
    if (items.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              '추천할 모임이나 챌린지가 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Padding(
          padding: EdgeInsets.only(bottom: index < items.length - 1 ? 16.0 : 0),
          child: item is AvailableMeeting
              ? _buildMeetingCard(item)
              : _buildChallengeCard(item as AvailableChallenge),
        );
      }).toList(),
    );
  }

  Widget _buildMeetingCard(AvailableMeeting meeting) {
    final isJoined = _itemJoined[meeting.id] ?? false;

    return GestureDetector(
      onTap: () => _onMeetingCardTap(meeting),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.dividerLight.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: meeting.category.color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 영역
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    meeting.category.color.withOpacity(0.05),
                    meeting.category.color.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          meeting.category.color.withOpacity(0.15),
                          meeting.category.color.withOpacity(0.25),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        meeting.category.emoji,
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: meeting.category.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                meeting.category.displayName,
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: meeting.category.color,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (meeting.universityName != null && meeting.universityName!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 11,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        meeting.universityName!,
                                        style: GoogleFonts.notoSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                          letterSpacing: -0.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meeting.title,
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 정보 영역
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    meeting.formattedDate,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.location_on_rounded,
                    meeting.location,
                    iconColor: AppColors.error,
                  ),
                  const SizedBox(height: 16),

                  // 참가자 및 보상 정보
                  Row(
                    children: [
                      _buildParticipantInfo(meeting.currentParticipants, meeting.maxParticipants),
                      const Spacer(),
                      _buildRewardBadge(meeting.experienceReward, meeting.participationReward),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 참여 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isJoined ? null : () => _onMeetingCardTap(meeting),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isJoined
                            ? AppColors.dividerLight
                            : meeting.category.color,
                        foregroundColor: isJoined
                            ? AppColors.textSecondary
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isJoined ? Icons.check_circle : Icons.add_circle,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isJoined ? "참여 완료" : "참여하기",
                            style: GoogleFonts.notoSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(AvailableChallenge challenge) {
    final isJoined = _itemJoined[challenge.id] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warningLight.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.warningBackground.withOpacity(0.5),
                  AppColors.warningBackground.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.warning.withOpacity(0.15),
                        AppColors.warning.withOpacity(0.25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      challenge.category.emoji,
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.warning,
                                  AppColors.warningLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '챌린지',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildDifficultyBadge(challenge.difficulty),
                          if (challenge.universityName != null && challenge.universityName!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 11,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      challenge.universityName!,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                        letterSpacing: -0.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 정보 영역
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.timer_outlined,
                  challenge.formattedDuration,
                  iconColor: AppColors.warning,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.date_range_rounded,
                  challenge.formattedDateRange,
                  iconColor: AppColors.primary,
                ),
                if (challenge.dailyGoals.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.flag_rounded,
                    challenge.dailyGoals.first,
                    iconColor: AppColors.success,
                  ),
                ],
                const SizedBox(height: 16),

                // 참가자 및 보상 정보
                Row(
                  children: [
                    _buildParticipantInfo(challenge.currentParticipants, challenge.maxParticipants),
                    const Spacer(),
                    _buildChallengeRewardBadge(challenge.experienceReward, challenge.completionReward),
                  ],
                ),

                const SizedBox(height: 16),

                // 참여 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isJoined ? null : () => _onJoinTap(challenge),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isJoined
                          ? AppColors.dividerLight
                          : AppColors.warning,
                      foregroundColor: isJoined
                          ? AppColors.textSecondary
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isJoined ? Icons.check_circle : Icons.local_fire_department,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isJoined ? "도전 중" : "도전하기",
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
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

  Widget _buildDifficultyBadge(int difficulty) {
    final colors = {
      1: {'bg': Colors.green.shade50, 'text': Colors.green.shade700},
      2: {'bg': Colors.orange.shade50, 'text': Colors.orange.shade700},
      3: {'bg': Colors.red.shade50, 'text': Colors.red.shade700},
    };

    final colorSet = colors[difficulty] ?? colors[1]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorSet['bg'],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorSet['text']!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        difficulty.displayName,
        style: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colorSet['text'],
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.textSecondary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor ?? AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantInfo(int current, int max) {
    final avatars = ['👨‍💻', '👩‍💼', '🧑‍🎨'];
    return Row(
      children: [
        SizedBox(
          width: 72,
          height: 28,
          child: Stack(
            children: avatars.asMap().entries.map((entry) {
              return Positioned(
                left: entry.key * 20.0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      entry.value,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$current/$max',
          style: GoogleFonts.notoSans(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ✅ double 타입으로 매개변수 수정
  Widget _buildRewardBadge(double xp, double points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            AppColors.secondaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
          const SizedBox(width: 4),
          Text(
            '+${xp.toInt()} XP',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.warning,
              letterSpacing: -0.2,
            ),
          ),
          if (points > 0) ...[
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 12,
              color: AppColors.divider,
            ),
            const SizedBox(width: 8),
            Icon(Icons.toll_rounded, color: AppColors.point, size: 16),
            const SizedBox(width: 4),
            Text(
              '+${points.toInt()}P',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.point,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ double 타입으로 매개변수 수정
  Widget _buildChallengeRewardBadge(int xp, int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warningBackground,
            AppColors.warningLight.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
          const SizedBox(width: 4),
          Text(
            '+${xp.toInt()} XP',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.warning,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 12,
            color: AppColors.warning.withOpacity(0.3),
          ),
          const SizedBox(width: 8),
          Icon(Icons.emoji_events_rounded, color: AppColors.error, size: 16),
          const SizedBox(width: 4),
          Text(
            '+${points.toInt()}P',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAILoadingWidget() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                        AppColors.primary,
                      ],
                      stops: [
                        _shimmerController.value - 0.3,
                        _shimmerController.value,
                        _shimmerController.value + 0.3,
                      ],
                    ).createShader(bounds);
                  },
                  child: Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'AI가 최적의 활동을 분석 중...',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.errorBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '데이터를 불러올 수 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(meetingRecommendationProvider.notifier).refresh();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '다시 시도',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}