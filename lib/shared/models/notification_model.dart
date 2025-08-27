import 'package:flutter/material.dart';

// 알림 타입 enum
enum NotificationType {
  goalComplete,      // 오늘의 목표 완료
  dailyQuestReward,  // 일일 퀘스트 보상
  weeklyQuestReward, // 주간 퀘스트 보상
  firstClimb,        // 오늘의 첫 등반
  meetingComplete,   // 모임 참가 완료
  profileUpdate,     // 프로필 업데이트
}

// 프로필 업데이트 타입
enum ProfileUpdateType {
  photo,    // 사진 변경
  nickname, // 닉네임 변경
}

// 알림 모델
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? detail;  // 상세 내용
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata; // 추가 데이터 (퀘스트 이름, 모임 이름 등)
  final ProfileUpdateType? profileUpdateType; // 프로필 업데이트인 경우 타입

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.detail,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
    this.profileUpdateType,
  });

  // copyWith 메서드
  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? detail,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
    ProfileUpdateType? profileUpdateType,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      detail: detail ?? this.detail,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      profileUpdateType: profileUpdateType ?? this.profileUpdateType,
    );
  }

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'message': message,
      'detail': detail,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'metadata': metadata,
      'profileUpdateType': profileUpdateType?.toString(),
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      type: _parseNotificationType(json['type']),
      title: json['title'],
      message: json['message'],
      detail: json['detail'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      metadata: json['metadata'],
      profileUpdateType: json['profileUpdateType'] != null 
          ? _parseProfileUpdateType(json['profileUpdateType'])
          : null,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.toString() == type,
      orElse: () => NotificationType.goalComplete,
    );
  }

  static ProfileUpdateType? _parseProfileUpdateType(String? type) {
    if (type == null) return null;
    return ProfileUpdateType.values.firstWhere(
      (e) => e.toString() == type,
      orElse: () => ProfileUpdateType.photo,
    );
  }
}

// 알림 타입별 아이콘과 색상 헬퍼
extension NotificationTypeExtension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.goalComplete:
        return Icons.flag_rounded;
      case NotificationType.dailyQuestReward:
        return Icons.card_giftcard_rounded;
      case NotificationType.weeklyQuestReward:
        return Icons.workspace_premium_rounded;
      case NotificationType.firstClimb:
        return Icons.terrain_rounded;
      case NotificationType.meetingComplete:
        return Icons.group_rounded;
      case NotificationType.profileUpdate:
        return Icons.account_circle_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.goalComplete:
        return const Color(0xFF10B981); // success green
      case NotificationType.dailyQuestReward:
        return const Color(0xFF3B82F6); // primary blue
      case NotificationType.weeklyQuestReward:
        return const Color(0xFF8B5CF6); // purple
      case NotificationType.firstClimb:
        return const Color(0xFFF59E0B); // warning amber
      case NotificationType.meetingComplete:
        return const Color(0xFF06B6D4); // cyan
      case NotificationType.profileUpdate:
        return const Color(0xFF6366F1); // indigo
    }
  }
}