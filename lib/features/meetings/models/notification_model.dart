// lib/features/meetings/models/notification_model.dart

import 'package:flutter/material.dart';

/// 🔔 알림 타입 - 한국형 모임 앱에 최적화된 알림 분류
enum NotificationType {
  meetingInvite('meeting_invite', '모임 초대', Icons.mail_rounded, Color(0xFF3B82F6), NotificationPriority.high),
  meetingReminder('meeting_reminder', '모임 알림', Icons.schedule_rounded, Color(0xFFF59E0B), NotificationPriority.high),
  meetingStarted('meeting_started', '모임 시작', Icons.play_circle_rounded, Color(0xFF10B981), NotificationPriority.high),
  meetingCanceled('meeting_canceled', '모임 취소', Icons.cancel_rounded, Color(0xFFEF4444), NotificationPriority.high),
  friendJoined('friend_joined', '친구 참가', Icons.person_add_rounded, Color(0xFF06B6D4), NotificationPriority.medium),
  levelUp('level_up', '레벨업', Icons.trending_up_rounded, Color(0xFF8B5CF6), NotificationPriority.medium),
  badgeEarned('badge_earned', '뱃지 획득', Icons.emoji_events_rounded, Color(0xFFEF4444), NotificationPriority.medium),
  socialActivity('social_activity', '소셜 활동', Icons.favorite_rounded, Color(0xFFEC4899), NotificationPriority.low),
  systemUpdate('system_update', '시스템 공지', Icons.info_rounded, Color(0xFF6B7280), NotificationPriority.low),
  sherpiMessage('sherpi_message', '셰르피 메시지', Icons.smart_toy_rounded, Color(0xFF10B981), NotificationPriority.medium);

  const NotificationType(this.value, this.displayName, this.icon, this.color, this.priority);
  
  final String value;
  final String displayName;
  final IconData icon;
  final Color color;
  final NotificationPriority priority;
}

/// 📶 알림 우선순위
enum NotificationPriority {
  low('낮음', 1),
  medium('보통', 2), 
  high('높음', 3),
  urgent('긴급', 4);

  const NotificationPriority(this.displayName, this.level);
  
  final String displayName;
  final int level;
}

/// 🔔 알림 아이템 모델
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final bool isPinned;
  final Map<String, dynamic> actionData;
  final String? relatedUserId;
  final String? relatedMeetingId;
  final Duration? expiresIn;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
    this.isPinned = false,
    this.actionData = const {},
    this.relatedUserId,
    this.relatedMeetingId,
    this.expiresIn,
  });

  /// ⏰ 상대 시간 포맷
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

  /// ⚡ 알림 시급성 점수
  double get urgencyScore {
    final priorityScore = type.priority.level * 0.25;
    final timeScore = _calculateTimeScore();
    final actionScore = actionData.isNotEmpty ? 0.2 : 0.0;
    
    return priorityScore + timeScore + actionScore;
  }

  double _calculateTimeScore() {
    final hoursSinceCreated = DateTime.now().difference(timestamp).inHours;
    if (hoursSinceCreated < 1) return 0.3;
    if (hoursSinceCreated < 6) return 0.2;
    if (hoursSinceCreated < 24) return 0.1;
    return 0.0;
  }

  /// 🎯 알림 만료 여부
  bool get isExpired {
    if (expiresIn == null) return false;
    return DateTime.now().isAfter(timestamp.add(expiresIn!));
  }

  /// 🔄 복사본 생성 (상태 변경용)
  NotificationItem copyWith({
    bool? isRead,
    bool? isPinned,
    Map<String, dynamic>? actionData,
  }) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      message: message,
      imageUrl: imageUrl,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isPinned: isPinned ?? this.isPinned,
      actionData: actionData ?? this.actionData,
      relatedUserId: relatedUserId,
      relatedMeetingId: relatedMeetingId,
      expiresIn: expiresIn,
    );
  }
}

/// 🎯 알림 필터
enum NotificationFilter {
  all('전체', '모든 알림', Icons.all_inclusive_rounded),
  unread('읽지 않음', '읽지 않은 알림만', Icons.mark_email_unread_rounded),
  meetings('모임', '모임 관련 알림', Icons.groups_rounded),
  social('소셜', '친구 및 소셜 활동', Icons.people_rounded),
  achievements('성취', '레벨업 및 뱃지', Icons.emoji_events_rounded),
  system('시스템', '공지 및 업데이트', Icons.settings_rounded);

  const NotificationFilter(this.displayName, this.description, this.icon);
  
  final String displayName;
  final String description;
  final IconData icon;
}

/// 📊 알림 통계
class NotificationStats {
  final int totalCount;
  final int unreadCount;
  final int todayCount;
  final Map<NotificationType, int> typeCounts;
  final Map<NotificationPriority, int> priorityCounts;

  const NotificationStats({
    required this.totalCount,
    required this.unreadCount,
    required this.todayCount,
    required this.typeCounts,
    required this.priorityCounts,
  });

  /// 📊 읽지 않은 비율
  double get unreadRatio => totalCount > 0 ? unreadCount / totalCount : 0.0;

  /// 🔥 중요한 알림 수
  int get importantCount => 
    (priorityCounts[NotificationPriority.high] ?? 0) +
    (priorityCounts[NotificationPriority.urgent] ?? 0);
}

/// 🎮 알림 액션 타입
enum NotificationActionType {
  join('참여하기'),
  view('보기'),
  accept('수락'),
  decline('거절'),
  remind('나중에 알림'),
  share('공유'),
  dismiss('무시');

  const NotificationActionType(this.displayName);
  final String displayName;
}

/// 🎯 알림 액션
class NotificationAction {
  final NotificationActionType type;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const NotificationAction({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// 🎲 샘플 알림 데이터 생성기
class NotificationDataGenerator {
  static List<NotificationItem> generateSampleNotifications() {
    final now = DateTime.now();
    
    return [
      NotificationItem(
        id: 'notif_001',
        type: NotificationType.meetingReminder,
        title: '모임 시작 30분 전 알림',
        message: '주말 한강 러닝 모임이 30분 후에 시작됩니다. 준비하세요! 🏃‍♂️',
        timestamp: now.subtract(const Duration(minutes: 5)),
        relatedMeetingId: 'meeting_001',
        actionData: {
          'meetingTitle': '주말 한강 러닝 모임',
          'startTime': now.add(const Duration(minutes: 25)).toIso8601String(),
          'location': '한강공원 뚝섬유원지',
        },
        expiresIn: const Duration(hours: 2),
      ),
      
      NotificationItem(
        id: 'notif_002',
        type: NotificationType.friendJoined,
        title: '친구가 모임에 참여했어요',
        message: '산악왕이영희님이 "새벽 요가 모임"에 참여했습니다.',
        imageUrl: 'assets/images/avatars/user_2.png',
        timestamp: now.subtract(const Duration(hours: 1)),
        relatedUserId: 'user_lee',
        relatedMeetingId: 'meeting_002',
        actionData: {
          'friendName': '산악왕이영희',
          'meetingTitle': '새벽 요가 모임',
        },
      ),
      
      NotificationItem(
        id: 'notif_003',
        type: NotificationType.levelUp,
        title: '축하합니다! 레벨업 달성! 🎉',
        message: '꾸준한 활동으로 레벨 24에 도달했습니다. 새로운 뱃지를 확인해보세요!',
        timestamp: now.subtract(const Duration(hours: 3)),
        actionData: {
          'previousLevel': 23,
          'newLevel': 24,
          'newBadges': ['연속 참여자', '사교성 마스터'],
          'statsIncreased': {'stamina': 3.2, 'sociality': 4.1},
        },
      ),
      
      NotificationItem(
        id: 'notif_004',
        type: NotificationType.meetingInvite,
        title: '새로운 모임 초대',
        message: '등반왕김철수님이 "북한산 등반 모임"에 초대했습니다.',
        imageUrl: 'assets/images/avatars/user_1.png',
        timestamp: now.subtract(const Duration(hours: 5)),
        relatedUserId: 'user_kim',
        relatedMeetingId: 'meeting_003',
        actionData: {
          'inviterName': '등반왕김철수',
          'meetingTitle': '북한산 등반 모임',
          'meetingDate': now.add(const Duration(days: 3)).toIso8601String(),
        },
        expiresIn: const Duration(days: 7),
      ),
      
      NotificationItem(
        id: 'notif_005',
        type: NotificationType.socialActivity,
        title: '내 모임에 좋아요 +5',
        message: '내가 만든 "독서 토론 모임"에 새로운 좋아요가 달렸어요.',
        timestamp: now.subtract(const Duration(days: 1)),
        relatedMeetingId: 'meeting_004',
        actionData: {
          'meetingTitle': '독서 토론 모임',
          'likeCount': 12,
          'newLikers': ['독서광박민수', '힐링왕정하나'],
        },
      ),
      
      NotificationItem(
        id: 'notif_006',
        type: NotificationType.sherpiMessage,
        title: '셰르피의 응원 메시지',
        message: '와! 이번 주 모임 참여 3회 달성이에요! 정말 열심히 하고 계시네요 💪',
        timestamp: now.subtract(const Duration(days: 2)),
        actionData: {
          'weeklyGoal': 3,
          'currentProgress': 3,
          'encouragementType': 'weekly_achievement',
        },
        isPinned: true,
      ),
    ];
  }
  
  /// 📊 알림 통계 생성
  static NotificationStats generateStats(List<NotificationItem> notifications) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final todayCount = notifications.where((n) => 
      DateTime.now().difference(n.timestamp).inHours < 24
    ).length;
    
    final typeCounts = <NotificationType, int>{};
    final priorityCounts = <NotificationPriority, int>{};
    
    for (final notification in notifications) {
      typeCounts[notification.type] = (typeCounts[notification.type] ?? 0) + 1;
      priorityCounts[notification.type.priority] = 
        (priorityCounts[notification.type.priority] ?? 0) + 1;
    }
    
    return NotificationStats(
      totalCount: notifications.length,
      unreadCount: unreadCount,
      todayCount: todayCount,
      typeCounts: typeCounts,
      priorityCounts: priorityCounts,
    );
  }
}

/// ⚙️ 알림 설정
class NotificationSettings {
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final bool enableMeetingReminders;
  final bool enableSocialNotifications;
  final bool enableSystemNotifications;
  final Map<NotificationType, bool> typeSettings;
  final int quietHoursStart; // 24시간 형식
  final int quietHoursEnd;   // 24시간 형식

  const NotificationSettings({
    this.enablePushNotifications = true,
    this.enableEmailNotifications = false,
    this.enableMeetingReminders = true,
    this.enableSocialNotifications = true,
    this.enableSystemNotifications = true,
    this.typeSettings = const {},
    this.quietHoursStart = 22,
    this.quietHoursEnd = 8,
  });

  /// 🔕 조용한 시간 여부 확인
  bool get isQuietTime {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    if (quietHoursStart <= quietHoursEnd) {
      // 같은 날 내 조용한 시간 (예: 22시-8시)
      return currentHour >= quietHoursStart && currentHour < quietHoursEnd;
    } else {
      // 자정을 넘나드는 조용한 시간 (예: 22시-다음날 8시)
      return currentHour >= quietHoursStart || currentHour < quietHoursEnd;
    }
  }

  /// 🔔 특정 타입 알림 허용 여부
  bool isTypeEnabled(NotificationType type) {
    return typeSettings[type] ?? true;
  }
}