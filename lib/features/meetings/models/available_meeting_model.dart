// lib/features/meetings/models/available_meeting_model.dart

import 'package:flutter/material.dart';

/// 모임 카테고리
enum MeetingCategory {
  study('스터디', '📚', Color(0xFF3B82F6)),
  exercise('운동', '💪', Color(0xFF10B981)),
  hobby('취미', '🎨', Color(0xFFEF4444)),
  culture('문화', '🎭', Color(0xFF8B5CF6)),
  networking('네트워킹', '🤝', Color(0xFFF59E0B)),
  reading('독서', '📖', Color(0xFF06B6D4));

  const MeetingCategory(this.displayName, this.emoji, this.color);
  final String displayName;
  final String emoji;
  final Color color;
}

/// 모임 유형 (포인트 시스템과 연동)
enum MeetingType {
  free('무료 모임', 1000),    // 참여 수수료 1000P
  paid('유료 모임', 0);       // 5% 수수료

  const MeetingType(this.displayName, this.baseFee);
  final String displayName;
  final int baseFee;
}

/// 모임 범위
enum MeetingScope {
  public('전체 공개'),
  university('우리 학교');

  const MeetingScope(this.displayName);
  final String displayName;
}

/// 참여 가능한 모임 데이터 (MeetingLog와 분리)
class AvailableMeeting {
  final String id;
  final String title;
  final String description;
  final MeetingCategory category;
  final MeetingType type;
  final MeetingScope scope;
  final DateTime dateTime;
  final String location;
  final String detailedLocation;
  final int maxParticipants;
  final int currentParticipants;
  final double? price; // 유료 모임의 경우
  final String hostName;
  final String hostId;
  final String? universityName;
  final bool isRecurring;
  final List<String> tags;
  final List<String> requirements;

  const AvailableMeeting({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.scope,
    required this.dateTime,
    required this.location,
    required this.detailedLocation,
    required this.maxParticipants,
    required this.currentParticipants,
    this.price,
    required this.hostName,
    required this.hostId,
    this.universityName,
    this.isRecurring = false,
    this.tags = const [],
    this.requirements = const [],
  });

  /// copyWith 메서드 추가
  AvailableMeeting copyWith({
    String? id,
    String? title,
    String? description,
    MeetingCategory? category,
    MeetingType? type,
    MeetingScope? scope,
    DateTime? dateTime,
    String? location,
    String? detailedLocation,
    int? maxParticipants,
    int? currentParticipants,
    double? price,
    String? hostName,
    String? hostId,
    String? universityName,
    bool? isRecurring,
    List<String>? tags,
    List<String>? requirements,
  }) {
    return AvailableMeeting(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      scope: scope ?? this.scope,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      detailedLocation: detailedLocation ?? this.detailedLocation,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      price: price ?? this.price,
      hostName: hostName ?? this.hostName,
      hostId: hostId ?? this.hostId,
      universityName: universityName ?? this.universityName,
      isRecurring: isRecurring ?? this.isRecurring,
      tags: tags ?? this.tags,
      requirements: requirements ?? this.requirements,
    );
  }

  /// 참여 수수료 계산 (globalPointProvider와 연동)
  double get participationFee {
    switch (type) {
      case MeetingType.free:
        return 1000.0; // 무료 모임 수수료
      case MeetingType.paid:
        return (price ?? 0) * 0.05; // 유료 모임 5% 수수료
    }
  }

  /// 참여 보상 계산 (globalPointProvider와 연동)
  double get participationReward {
    return 100.0; // 기본 참여 보상
  }

  /// 경험치 보상 계산
  double get experienceReward {
    double baseXp = 50.0;

    // 카테고리별 추가 경험치
    switch (category) {
      case MeetingCategory.study:
      case MeetingCategory.reading:
        baseXp += 20.0;
        break;
      case MeetingCategory.exercise:
        baseXp += 15.0;
        break;
      case MeetingCategory.networking:
        baseXp += 25.0;
        break;
      default:
        baseXp += 10.0;
    }

    // 유료 모임 추가 경험치
    if (type == MeetingType.paid) {
      baseXp += 30.0;
    }

    return baseXp;
  }

  /// 능력치 보상 계산
  Map<String, double> get statRewards {
    switch (category) {
      case MeetingCategory.exercise:
        return {'stamina': 0.3, 'willpower': 0.1};
      case MeetingCategory.study:
        return {'knowledge': 0.3, 'technique': 0.1};
      case MeetingCategory.reading:
        return {'knowledge': 0.4};
      case MeetingCategory.networking:
        return {'sociality': 0.4, 'technique': 0.1};
      case MeetingCategory.hobby:
        return {'technique': 0.2, 'willpower': 0.1};
      case MeetingCategory.culture:
        return {'sociality': 0.2, 'willpower': 0.2};
      default:
        return {'sociality': 0.2};
    }
  }

  /// 참여율 계산
  double get participationRate {
    if (maxParticipants == 0) return 0.0;
    return currentParticipants / maxParticipants;
  }

  /// 참여 가능 여부
  bool get canJoin => currentParticipants < maxParticipants && dateTime.isAfter(DateTime.now());

  /// 진행 시간까지 남은 시간
  Duration get timeUntilStart => dateTime.difference(DateTime.now());

  /// 모임 상태
  String get status {
    final now = DateTime.now();
    if (dateTime.isBefore(now)) return '완료';
    if (timeUntilStart.inHours < 24) return '임박';
    return '모집중';
  }

  Color get statusColor {
    switch (status) {
      case '완료': return const Color(0xFF6B7280);
      case '임박': return const Color(0xFFF59E0B);
      case '모집중': return const Color(0xFF10B981);
      default: return const Color(0xFF6B7280);
    }
  }

  /// 짧은 제목 (UI용)
  String get shortTitle {
    if (title.length <= 10) return title;
    return '${title.substring(0, 10)}...';
  }

  /// 날짜 포맷 (UI용)
  String get formattedDate {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dateTime.weekday - 1];
    return '${dateTime.month}/${dateTime.day}($weekday) ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'type': type.name,
      'scope': scope.name,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'detailedLocation': detailedLocation,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'price': price,
      'hostName': hostName,
      'hostId': hostId,
      'universityName': universityName,
      'isRecurring': isRecurring,
      'tags': tags,
      'requirements': requirements,
    };
  }

  factory AvailableMeeting.fromJson(Map<String, dynamic> json) {
    return AvailableMeeting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: MeetingCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MeetingCategory.study,
      ),
      type: MeetingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MeetingType.free,
      ),
      scope: MeetingScope.values.firstWhere(
        (e) => e.name == json['scope'],
        orElse: () => MeetingScope.public,
      ),
      dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
      location: json['location'] ?? '',
      detailedLocation: json['detailedLocation'] ?? '',
      maxParticipants: json['maxParticipants'] ?? 10,
      currentParticipants: json['currentParticipants'] ?? 0,
      price: json['price']?.toDouble(),
      hostName: json['hostName'] ?? '',
      hostId: json['hostId'] ?? '',
      universityName: json['universityName'],
      isRecurring: json['isRecurring'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
    );
  }
}
