import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

class FriendsActivityFeedWidget extends ConsumerStatefulWidget {
  const FriendsActivityFeedWidget({super.key});

  @override
  ConsumerState<FriendsActivityFeedWidget> createState() =>
      _FriendsActivityFeedWidgetState();
}

class _FriendsActivityFeedWidgetState
    extends ConsumerState<FriendsActivityFeedWidget>
    with TickerProviderStateMixin {
  late AnimationController _feedController;
  late Animation<double> _feedAnimation;
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  // 실시간 업데이트를 위한 타이머
  bool _showNewActivityIndicator = false;

  final List<FriendActivity> _activities = [
    FriendActivity(
      id: '1',
      friendName: '김도현',
      friendAvatar: '👨‍💻',
      activityType: ActivityType.meetingJoined,
      content: 'Flutter 스터디 모임에 참여했어요!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      likes: 5,
      isLiked: false,
      meetingTitle: 'Flutter 스터디',
      category: '스터디',
      isVerified: true,
    ),
    FriendActivity(
      id: '2',
      friendName: '이서연',
      friendAvatar: '👩‍🎨',
      activityType: ActivityType.levelUp,
      content: 'Level 15에 도달했어요! 🎉',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      likes: 12,
      isLiked: true,
      category: '성장',
      hasNewComments: true,
      commentCount: 3,
    ),
    FriendActivity(
      id: '3',
      friendName: '박준영',
      friendAvatar: '👨‍🏫',
      activityType: ActivityType.questCompleted,
      content: '새벽 러닝 퀘스트를 완료했어요! 💪',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 8,
      isLiked: false,
      category: '운동',
      challengeLevel: 'Hard',
    ),
    FriendActivity(
      id: '4',
      friendName: '최민지',
      friendAvatar: '👩‍💼',
      activityType: ActivityType.meetingCreated,
      content: '독서 토론 모임을 만들었어요! 함께해요 📚',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      likes: 15,
      isLiked: true,
      meetingTitle: '독서 토론 모임',
      category: '독서',
      participantCount: 8,
      maxParticipants: 12,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _feedController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _feedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedController, curve: Curves.easeOutExpo),
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    _feedController.forward();

    // 새 활동 알림 시뮬레이션
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNewActivityIndicator = true;
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showNewActivityIndicator = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _feedController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _feedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: const Offset(0, 0),
          child: Opacity(
            opacity: _feedAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  if (_showNewActivityIndicator) _buildNewActivityIndicator(),
                  _buildActivityFeed(),
                  _buildViewAllButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      child: Row(
        children: [
          // 아이콘 컨테이너 - 그라데이션 배경
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.primary.withValues(alpha: 0.1),
                  ModernColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                '👥',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 타이틀 섹션
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '친구들의 활동',
                      style: GoogleFonts.notoSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (_showNewActivityIndicator) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: ModernColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '함께 성장하는 친구들의 소식',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // 액션 버튼들
          Row(
            children: [
              // 알림 설정 버튼
              GestureDetector(
                onTap: () {
                  HapticFeedbackManager.lightImpact();
                  _toggleNotifications();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ModernColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: ModernColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 새로고침 버튼
              GestureDetector(
                onTap: () {
                  HapticFeedbackManager.lightImpact();
                  _refreshFeed();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ModernColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: ModernColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 새로운 활동 알림 인디케이터
  Widget _buildNewActivityIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.primary.withValues(alpha: 0.08),
                  ModernColors.primary.withValues(alpha: 0.04),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: ModernColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '새로운 활동이 있습니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '지금 보기',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: ModernColors.primary.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityFeed() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: _activities.take(3).map((activity) {
          final index = _activities.indexOf(activity);
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 150)),
            curve: Curves.easeOutQuart,
            builder: (context, animationValue, child) {
              return Transform.translate(
                offset: const Offset(0, 0),
                child: Opacity(
                  opacity: animationValue,
                  child: _buildModernActivityItem(
                      activity, index == _activities.take(3).length - 1),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  // 모던한 스타일의 활동 아이템
  Widget _buildModernActivityItem(FriendActivity activity, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메인 활동 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: ModernColors.primary.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 헤더
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 아바타
                    Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getActivityColor(activity.activityType)
                                    .withValues(alpha: 0.2),
                                _getActivityColor(activity.activityType)
                                    .withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              activity.friendAvatar,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        // 인증 배지
                        if (activity.isVerified ?? false)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: ModernColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // 사용자 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                activity.friendName,
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ModernColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // 활동 타입 라벨
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      _getActivityColor(activity.activityType)
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getActivityTypeText(activity.activityType),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: _getActivityColor(
                                        activity.activityType),
                                  ),
                                ),
                              ),
                              // 난이도 표시 (퀘스트의 경우)
                              if (activity.challengeLevel != null) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ModernColors.warning
                                            .withValues(alpha: 0.2),
                                        ModernColors.warning
                                            .withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 10,
                                        color: ModernColors.warning,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        activity.challengeLevel!,
                                        style: GoogleFonts.notoSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: ModernColors.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getTimeAgo(activity.timestamp),
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              color: ModernColors.textTertiary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 더보기 메뉴
                    GestureDetector(
                      onTap: () => _showMoreOptions(activity),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.more_horiz,
                          color: ModernColors.textTertiary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 콘텐츠
                Text(
                  activity.content,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: ModernColors.textPrimary,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                // 모임 정보 카드 (있는 경우)
                if (activity.meetingTitle != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ModernColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ModernColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            color: ModernColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.meetingTitle!,
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ModernColors.textPrimary,
                                ),
                              ),
                              if (activity.participantCount != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people_outline,
                                      size: 12,
                                      color: ModernColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${activity.participantCount}/${activity.maxParticipants ?? 20}명',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 11,
                                        color: ModernColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ModernColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            activity.category,
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: ModernColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // 인터랙션 영역
                Row(
                  children: [
                    // 좋아요 버튼
                    GestureDetector(
                      onTap: () => _toggleLike(activity),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: activity.isLiked
                              ? ModernColors.error.withValues(alpha: 0.1)
                              : ModernColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _heartAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: activity.isLiked
                                      ? _heartAnimation.value
                                      : 1.0,
                                  child: Icon(
                                    activity.isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_outline_rounded,
                                    color: activity.isLiked
                                        ? ModernColors.error
                                        : ModernColors.textSecondary,
                                    size: 16,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${activity.likes}',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: activity.isLiked
                                    ? ModernColors.error
                                    : ModernColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 댓글 버튼
                    GestureDetector(
                      onTap: () => _showComments(activity),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: ModernColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: ModernColors.textSecondary,
                              size: 16,
                            ),
                            if (activity.commentCount != null &&
                                activity.commentCount! > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${activity.commentCount}',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: ModernColors.textSecondary,
                                ),
                              ),
                            ],
                            // 새 댓글 알림
                            if (activity.hasNewComments ?? false) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: ModernColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // 공유 버튼
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _shareActivity(activity),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: ModernColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          color: ModernColors.textSecondary,
                          size: 16,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 참여하기 버튼 (모임의 경우)
                    if (activity.meetingTitle != null)
                      GestureDetector(
                        onTap: () => _joinMeeting(activity),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ModernColors.primary,
                                ModernColors.primary.withValues(alpha: 0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    ModernColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '참여하기',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
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

  Widget _buildViewAllButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: () {
          HapticFeedbackManager.lightImpact();
          _showAllActivities();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: ModernColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '모든 활동 보기',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: ModernColors.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.meetingJoined:
        return ModernColors.meeting;
      case ActivityType.levelUp:
        return ModernColors.modernAccent;
      case ActivityType.questCompleted:
        return ModernColors.success;
      case ActivityType.meetingCreated:
        return ModernColors.warning;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.meetingJoined:
        return Icons.group_add;
      case ActivityType.levelUp:
        return Icons.trending_up;
      case ActivityType.questCompleted:
        return Icons.check_circle;
      case ActivityType.meetingCreated:
        return Icons.add_circle;
    }
  }

  String _getActivityTypeText(ActivityType type) {
    switch (type) {
      case ActivityType.meetingJoined:
        return '모임 참여';
      case ActivityType.levelUp:
        return '레벨업';
      case ActivityType.questCompleted:
        return '퀘스트 완료';
      case ActivityType.meetingCreated:
        return '모임 생성';
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  void _toggleLike(FriendActivity activity) {
    HapticFeedbackManager.lightImpact();

    // 하트 애니메이션 실행
    _heartController.forward().then((_) {
      _heartController.reverse();
    });

    setState(() {
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = _activities[index].copyWith(
          isLiked: !_activities[index].isLiked,
          likes: _activities[index].isLiked
              ? _activities[index].likes - 1
              : _activities[index].likes + 1,
        );
      }
    });
  }

  void _showComments(FriendActivity activity) {
    HapticFeedbackManager.lightImpact();
    // 댓글 화면으로 이동 또는 모달 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.chat_bubble_outline,
                    color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 10),
            Text('${activity.friendName}님의 활동에 댓글을 남겨보세요!'),
          ],
        ),
        backgroundColor: ModernColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareActivity(FriendActivity activity) {
    HapticFeedbackManager.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.share_outlined, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('친구의 활동을 공유합니다'),
          ],
        ),
        backgroundColor: ModernColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions(FriendActivity activity) {
    HapticFeedbackManager.lightImpact();
    // 더보기 옵션 메뉴 표시
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_outlined,
                  color: ModernColors.primary),
              title: Text('${activity.friendName}님 팔로우'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined,
                  color: ModernColors.primary),
              title: const Text('활동 알림 받기'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.block_outlined, color: ModernColors.error),
              title: const Text('숨기기'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleNotifications() {
    HapticFeedbackManager.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('알림 설정이 변경되었습니다'),
          ],
        ),
        backgroundColor: ModernColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _joinMeeting(FriendActivity activity) {
    HapticFeedbackManager.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.1)
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.group_add, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text('${activity.meetingTitle}에 참여 신청했습니다!')),
          ],
        ),
        backgroundColor: ModernColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: '취소',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _refreshFeed() {
    setState(() {
      _showNewActivityIndicator = false;
    });

    // 새로고침 애니메이션
    _feedController.reset();
    _feedController.forward();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text('최신 활동을 불러오는 중...'),
          ],
        ),
        backgroundColor: ModernColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );

    // 실제 데이터 새로고침 시뮬레이션
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('친구들의 최신 활동을 불러왔습니다!'),
              ],
            ),
            backgroundColor: ModernColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showAllActivities() {
    // 전체 활동 피드로 이동
    HapticFeedbackManager.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('친구들의 모든 활동 페이지로 이동합니다'),
        backgroundColor: ModernColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    // Navigator.pushNamed(context, '/friends_feed'); // 실제 라우팅 구현 시 활성화
  }
}

// 친구 활동 데이터 모델
enum ActivityType {
  meetingJoined,
  levelUp,
  questCompleted,
  meetingCreated,
}

class FriendActivity {
  final String id;
  final String friendName;
  final String friendAvatar;
  final ActivityType activityType;
  final String content;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;
  final String? meetingTitle;
  final String category;
  final bool? isVerified;
  final bool? hasNewComments;
  final int? commentCount;
  final String? challengeLevel;
  final int? participantCount;
  final int? maxParticipants;

  FriendActivity({
    required this.id,
    required this.friendName,
    required this.friendAvatar,
    required this.activityType,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.isLiked,
    this.meetingTitle,
    required this.category,
    this.isVerified,
    this.hasNewComments,
    this.commentCount,
    this.challengeLevel,
    this.participantCount,
    this.maxParticipants,
  });

  FriendActivity copyWith({
    String? id,
    String? friendName,
    String? friendAvatar,
    ActivityType? activityType,
    String? content,
    DateTime? timestamp,
    int? likes,
    bool? isLiked,
    String? meetingTitle,
    String? category,
    bool? isVerified,
    bool? hasNewComments,
    int? commentCount,
    String? challengeLevel,
    int? participantCount,
    int? maxParticipants,
  }) {
    return FriendActivity(
      id: id ?? this.id,
      friendName: friendName ?? this.friendName,
      friendAvatar: friendAvatar ?? this.friendAvatar,
      activityType: activityType ?? this.activityType,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      meetingTitle: meetingTitle ?? this.meetingTitle,
      category: category ?? this.category,
      isVerified: isVerified ?? this.isVerified,
      hasNewComments: hasNewComments ?? this.hasNewComments,
      commentCount: commentCount ?? this.commentCount,
      challengeLevel: challengeLevel ?? this.challengeLevel,
      participantCount: participantCount ?? this.participantCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
    );
  }
}
