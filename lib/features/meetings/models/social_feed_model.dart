// lib/features/meetings/models/social_feed_model.dart

import 'package:flutter/material.dart';

/// 🔥 소셜 피드 활동 타입
enum SocialFeedType {
  meetingCreated('meeting_created', '새 모임 생성', Icons.add_circle_rounded, Color(0xFF10B981)),
  meetingJoined('meeting_joined', '모임 참가', Icons.person_add_rounded, Color(0xFF3B82F6)),
  meetingStarted('meeting_started', '모임 시작', Icons.play_circle_rounded, Color(0xFFF59E0B)),
  meetingCompleted('meeting_completed', '모임 완료', Icons.check_circle_rounded, Color(0xFF10B981)),
  levelUp('level_up', '레벨업', Icons.trending_up_rounded, Color(0xFF8B5CF6)),
  badgeEarned('badge_earned', '뱃지 획득', Icons.emoji_events_rounded, Color(0xFFEF4444)),
  friendJoined('friend_joined', '친구 참가', Icons.group_add_rounded, Color(0xFF06B6D4)),
  streakAchieved('streak_achieved', '연속 달성', Icons.local_fire_department_rounded, Color(0xFFFF6B6B));

  const SocialFeedType(this.value, this.displayName, this.icon, this.color);
  
  final String value;
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 📊 소셜 피드 아이템 모델
class SocialFeedItem {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final int userLevel;
  final SocialFeedType feedType;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final List<String> likedUsers;
  final List<SocialFeedComment> comments;
  final String? relatedMeetingId;
  final String? relatedImageUrl;
  final bool isRecentActivity; // 30분 이내 활동

  const SocialFeedItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.userLevel,
    required this.feedType,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
    this.likedUsers = const [],
    this.comments = const [],
    this.relatedMeetingId,
    this.relatedImageUrl,
    required this.isRecentActivity,
  });

  /// ⏰ 상대 시간 포맷 (한국형)
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.month}월 ${timestamp.day}일';
    }
  }

  /// 👍 좋아요 수
  int get likeCount => likedUsers.length;

  /// 💬 댓글 수
  int get commentCount => comments.length;

  /// ✨ 활동성 점수 (최신성 + 인기도)
  double get activityScore {
    final recencyScore = isRecentActivity ? 1.0 : 0.5;
    final popularityScore = (likeCount * 0.3) + (commentCount * 0.7);
    return recencyScore + (popularityScore * 0.1);
  }
}

/// 💬 피드 댓글 모델
class SocialFeedComment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final List<String> likedUsers;

  const SocialFeedComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    this.likedUsers = const [],
  });

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간';
    } else {
      return '${difference.inDays}일';
    }
  }

  int get likeCount => likedUsers.length;
}

/// 🔄 실시간 피드 필터
enum SocialFeedFilter {
  all('전체', '모든 활동', Icons.dashboard_rounded),
  friends('친구', '친구 활동만', Icons.people_rounded),
  meetings('모임', '모임 관련', Icons.groups_rounded),
  achievements('성취', '레벨업 & 뱃지', Icons.emoji_events_rounded),
  recent('최신', '30분 이내', Icons.schedule_rounded);

  const SocialFeedFilter(this.displayName, this.description, this.icon);
  
  final String displayName;
  final String description;
  final IconData icon;
}

/// 📈 실시간 피드 통계
class SocialFeedStats {
  final int totalActivities;
  final int todayActivities;
  final int friendsOnline;
  final int activeMeetings;
  final Map<SocialFeedType, int> activityCounts;

  const SocialFeedStats({
    required this.totalActivities,
    required this.todayActivities,
    required this.friendsOnline,
    required this.activeMeetings,
    required this.activityCounts,
  });
}

/// 🎯 샘플 데이터 생성기
class SocialFeedDataGenerator {
  static List<SocialFeedItem> generateSampleFeeds() {
    final now = DateTime.now();
    
    return [
      SocialFeedItem(
        id: 'feed_001',
        userId: 'user_kim',
        userName: '등반왕김철수',
        userAvatar: 'assets/images/avatars/user_1.png',
        userLevel: 23,
        feedType: SocialFeedType.meetingCreated,
        title: '주말 한강 러닝 모임 개설',
        description: '상쾌한 아침 공기와 함께 한강에서 러닝해요! 초보자도 환영 🏃‍♂️',
        timestamp: now.subtract(const Duration(minutes: 15)),
        likedUsers: ['user_123', 'user_456', 'user_789'],
        comments: [
          SocialFeedComment(
            id: 'comment_001',
            userId: 'user_lee',
            userName: '산악왕이영희',
            userAvatar: 'assets/images/avatars/user_2.png',
            content: '저도 참여하고 싶어요!',
            timestamp: now.subtract(const Duration(minutes: 10)),
          ),
        ],
        relatedMeetingId: 'meeting_001',
        isRecentActivity: true,
      ),
      
      SocialFeedItem(
        id: 'feed_002',
        userId: 'user_park',
        userName: '독서광박민수',
        userAvatar: 'assets/images/avatars/user_3.png',
        userLevel: 19,
        feedType: SocialFeedType.levelUp,
        title: '레벨 19 달성! 🎉',
        description: '꾸준한 독서 모임 참여로 지식 레벨이 올랐어요!',
        timestamp: now.subtract(const Duration(hours: 2)),
        likedUsers: ['user_111', 'user_222', 'user_333', 'user_444'],
        metadata: {
          'previousLevel': 18,
          'newLevel': 19,
          'statsIncreased': {'knowledge': 5.2, 'willpower': 2.1},
        },
        isRecentActivity: false,
      ),
      
      SocialFeedItem(
        id: 'feed_003',
        userId: 'user_choi',
        userName: '요가마스터최수지',
        userAvatar: 'assets/images/avatars/user_4.png',
        userLevel: 31,
        feedType: SocialFeedType.meetingCompleted,
        title: '새벽 요가 모임 완료',
        description: '오늘도 건강한 하루의 시작! 함께해주신 분들 감사해요 🧘‍♀️',
        timestamp: now.subtract(const Duration(hours: 5)),
        likedUsers: ['user_555', 'user_666'],
        comments: [
          SocialFeedComment(
            id: 'comment_002',
            userId: 'user_jung',
            userName: '힐링왕정하나',
            userAvatar: 'assets/images/avatars/user_5.png',
            content: '오늘 수업도 너무 좋았어요! 내일도 참여할게요',
            timestamp: now.subtract(const Duration(hours: 4, minutes: 30)),
          ),
        ],
        relatedMeetingId: 'meeting_002',
        metadata: {
          'participants': 8,
          'duration': 90,
          'satisfaction': 4.8,
        },
        isRecentActivity: false,
      ),
    ];
  }
}