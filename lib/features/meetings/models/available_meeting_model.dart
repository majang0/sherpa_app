// lib/features/meetings/models/available_meeting_model.dart

import 'package:flutter/material.dart';
import '../../../core/constants/meeting_categories.dart';

/// 🏷️ 모임 카테고리 (🎯 중앙집중식 카테고리 시스템 연동)
///
/// 중앙집중식 MeetingCategories와 완전 통합된 enum 시스템
/// 모든 UI 데이터(색상, 아이콘, 그라데이션)는 중앙에서 가져옴
enum MeetingCategory {
  all('all'),
  exercise('exercise'),
  study('study'),
  reading('reading'),
  networking('networking'),
  culture('culture'),
  outdoor('outdoor');

  final String englishName;
  const MeetingCategory(this.englishName);

  /// 🎨 중앙집중식 시스템에서 displayName 가져오기
  String get displayName => MeetingCategories.enumToDisplayName(englishName);

  /// 🎭 중앙집중식 시스템에서 emoji 가져오기
  String get emoji => MeetingCategories.getEmoji(displayName);

  /// 🌈 중앙집중식 시스템에서 color 가져오기
  Color get color => MeetingCategories.getColor(displayName);

  /// 🎨 중앙집중식 시스템에서 gradient 가져오기
  List<Color> get gradient => MeetingCategories.getGradient(displayName);
}

/// 모임 유형 (포인트 시스템과 연동)
enum MeetingType {
  free('무료 모임', 1000), // 참여 수수료 1000P
  paid('유료 모임', 0); // 5% 수수료

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
  final List<String> preparationItems;
  final List<String> imageFileNames; // 저장된 이미지 파일명들

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
    this.preparationItems = const [],
    this.imageFileNames = const [],
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
    List<String>? preparationItems,
    List<String>? imageFileNames,
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
      preparationItems: preparationItems ?? this.preparationItems,
      imageFileNames: imageFileNames ?? this.imageFileNames,
    );
  }

  /// 참여 수수료 계산 (globalPointProvider와 연동)
  double get participationFee {
    switch (type) {
      case MeetingType.free:
        return 1000.0; // 무료 모임 수수료
      case MeetingType.paid:
        return price ?? 0; // 유료 모임 전체 가격 지불
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
      case MeetingCategory.all:
        baseXp += 10.0;
        break;
      case MeetingCategory.exercise:
        baseXp += 20.0;
        break;
      case MeetingCategory.study:
        baseXp += 25.0;
        break;
      case MeetingCategory.reading:
        baseXp += 25.0;
        break;
      case MeetingCategory.networking:
        baseXp += 20.0;
        break;
      case MeetingCategory.culture:
        baseXp += 15.0;
        break;
      case MeetingCategory.outdoor:
        baseXp += 20.0;
        break;
    }

    // 유료 모임 추가 경험치
    if (type == MeetingType.paid) {
      baseXp += 30.0;
    }

    return baseXp;
  }

  /// 능력치 보상 계산
  /// 🔥 모든 모임은 반드시 사교성 능력치를 제공합니다
  Map<String, double> get statRewards {
    switch (category) {
      case MeetingCategory.all:
        return {'sociality': 0.2};
      case MeetingCategory.exercise:
        return {'stamina': 0.3, 'sociality': 0.2};
      case MeetingCategory.study:
        return {'knowledge': 0.3, 'sociality': 0.2};
      case MeetingCategory.reading:
        return {'knowledge': 0.3, 'sociality': 0.2};
      case MeetingCategory.networking:
        return {'sociality': 0.5};
      case MeetingCategory.culture:
        return {'knowledge': 0.2, 'sociality': 0.3};
      case MeetingCategory.outdoor:
        return {'stamina': 0.3, 'sociality': 0.2};
    }
  }

  /// 참여율 계산
  double get participationRate {
    if (maxParticipants == 0) return 0.0;
    return currentParticipants / maxParticipants;
  }

  /// 참여 가능 여부
  bool get canJoin =>
      currentParticipants < maxParticipants && dateTime.isAfter(DateTime.now());

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
      case '완료':
        return const Color(0xFF6B7280);
      case '임박':
        return const Color(0xFFF59E0B);
      case '모집중':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// 짧은 제목 (UI용)
  String get shortTitle {
    if (title.length <= 10) return title;
    return '${title.substring(0, 10)}...';
  }

  /// 이미지가 있는지 확인
  bool get hasImages => imageFileNames.isNotEmpty;

  /// 첫 번째 이미지 파일명 (썸네일용)
  String? get firstImageFileName =>
      imageFileNames.isNotEmpty ? imageFileNames.first : null;

  /// 날짜 포맷 (한국어 UI용)
  String get formattedDate {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dateTime.weekday - 1];

    // 오늘/내일/모레 표시
    final daysDiff = DateTime(dateTime.year, dateTime.month, dateTime.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    String datePrefix;
    if (daysDiff == 0) {
      datePrefix = '오늘';
    } else if (daysDiff == 1) {
      datePrefix = '내일';
    } else if (daysDiff == 2) {
      datePrefix = '모레';
    } else {
      datePrefix = '${dateTime.month}월 ${dateTime.day}일';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$datePrefix($weekday) $timeStr';
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
      'preparationItems': preparationItems,
      'imageFileNames': imageFileNames,
    };
  }

  factory AvailableMeeting.fromJson(Map<String, dynamic> json) {
    return AvailableMeeting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: MeetingCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MeetingCategory.all,
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
      preparationItems: List<String>.from(json['preparationItems'] ?? []),
      imageFileNames: List<String>.from(json['imageFileNames'] ?? []),
    );
  }
}
