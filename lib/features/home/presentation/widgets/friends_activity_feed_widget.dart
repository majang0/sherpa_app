import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

class FriendsActivityFeedWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<FriendsActivityFeedWidget> createState() => _FriendsActivityFeedWidgetState();
}

class _FriendsActivityFeedWidgetState extends ConsumerState<FriendsActivityFeedWidget>
    with TickerProviderStateMixin {
  late AnimationController _feedController;
  late Animation<double> _feedAnimation;

  final List<FriendActivity> _activities = [
    FriendActivity(
      id: '1',
      friendName: '김친구',
      friendAvatar: '👨‍💻',
      activityType: ActivityType.meetingJoined,
      content: 'Flutter 스터디 모임에 참여했어요!',
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      likes: 5,
      isLiked: false,
      meetingTitle: 'Flutter 스터디',
      category: '스터디',
    ),
    FriendActivity(
      id: '2',
      friendName: '이동료',
      friendAvatar: '👩‍🎨',
      activityType: ActivityType.levelUp,
      content: 'Level 15에 도달했어요! 🎉',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      likes: 12,
      isLiked: true,
      category: '성장',
    ),
    FriendActivity(
      id: '3',
      friendName: '박동기',
      friendAvatar: '👨‍🏫',
      activityType: ActivityType.questCompleted,
      content: '새벽 러닝 퀘스트를 완료했어요! 💪',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      likes: 8,
      isLiked: false,
      category: '운동',
    ),
    FriendActivity(
      id: '4',
      friendName: '최성장',
      friendAvatar: '👩‍💼',
      activityType: ActivityType.meetingCreated,
      content: '독서 토론 모임을 만들었어요! 함께해요 📚',
      timestamp: DateTime.now().subtract(Duration(hours: 3)),
      likes: 15,
      isLiked: true,
      meetingTitle: '독서 토론 모임',
      category: '스터디',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _feedController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _feedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedController, curve: Curves.easeOutCubic),
    );

    _feedController.forward();
  }

  @override
  void dispose() {
    _feedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _feedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _feedAnimation.value)),
          child: Opacity(
            opacity: _feedAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF8A80),
                    const Color(0xFFFF7043),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8A80).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildActivityFeed(),
                    const SizedBox(height: 12),
                    _buildViewAllButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('👥', style: TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '친구들의 활동',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                '함께 성장하는 친구들의 소식',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedbackManager.lightImpact();
            _refreshFeed();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityFeed() {
    return Column(
      children: _activities.take(3).map((activity) =>
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (_activities.indexOf(activity) * 100)),
            curve: Curves.easeOutBack,
            builder: (context, animationValue, child) {
              return Transform.translate(
                offset: Offset(30 * (1 - animationValue), 0),
                child: Opacity(
                  opacity: animationValue,
                  child: _buildActivityItem(activity),
                ),
              );
            },
          )
      ).toList(),
    );
  }

  Widget _buildActivityItem(FriendActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 친구 아바타
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(activity.friendAvatar, style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),

              // 친구 정보
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
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getActivityColor(activity.activityType).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getActivityTypeText(activity.activityType),
                            style: GoogleFonts.notoSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _getTimeAgo(activity.timestamp),
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // 활동 아이콘
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getActivityColor(activity.activityType).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActivityIcon(activity.activityType),
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 활동 내용
          Text(
            activity.content,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),

          // 모임 정보 (있는 경우)
          if (activity.meetingTitle != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.group, color: Colors.white.withValues(alpha: 0.8), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      activity.meetingTitle!,
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  Text(
                    activity.category,
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 인터랙션 버튼들
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(activity),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: activity.isLiked
                        ? Colors.red.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        activity.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: activity.isLiked ? Colors.red[300] : Colors.white.withValues(alpha: 0.8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.likes}',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: activity.isLiked ? Colors.red[300] : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              GestureDetector(
                onTap: () => _showComments(activity),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '댓글',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              if (activity.meetingTitle != null)
                GestureDetector(
                  onTap: () => _joinMeeting(activity),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '참여하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF8A80),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        _showAllActivities();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.expand_more, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              '모든 활동 보기',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.meetingJoined:
        return Colors.blue;
      case ActivityType.levelUp:
        return Colors.purple;
      case ActivityType.questCompleted:
        return Colors.green;
      case ActivityType.meetingCreated:
        return Colors.orange;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${activity.friendName}님의 활동에 댓글을 남겨보세요!'),
        backgroundColor: const Color(0xFFFF8A80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _joinMeeting(FriendActivity activity) {
    HapticFeedbackManager.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.group_add, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('${activity.meetingTitle}에 참여 신청했습니다!')),
          ],
        ),
        backgroundColor: const Color(0xFFFF8A80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _refreshFeed() {
    // 피드 새로고침 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            const SizedBox(width: 8),
            Text('친구들의 최신 활동을 불러왔습니다!'),
          ],
        ),
        backgroundColor: const Color(0xFFFF8A80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAllActivities() {
    // 전체 활동 피드로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('친구들의 모든 활동을 확인해보세요!'),
        backgroundColor: const Color(0xFFFF8A80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
    );
  }
}
