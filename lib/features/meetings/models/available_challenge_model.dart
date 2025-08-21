import 'package:flutter/material.dart';

/// 챌린지 카테고리 열거형
enum ChallengeCategory {
  fitness('건강', Color(0xFF10B981)),
  study('학습', Color(0xFF3B82F6)),
  habit('습관', Color(0xFF8B5CF6)),
  mindfulness('마음챙김', Color(0xFFF59E0B)),
  lifestyle('라이프스타일', Color(0xFFEF4444));

  const ChallengeCategory(this.displayName, this.color);
  
  final String displayName;
  final Color color;
}

/// 챌린지 난이도 열거형
enum ChallengeDifficulty {
  beginner(1, '초급', '🔰', Color(0xFF10B981)),
  intermediate(2, '중급', '⭐', Color(0xFFF59E0B)),
  advanced(3, '고급', '🔥', Color(0xFFEF4444)),
  expert(4, '전문가', '💎', Color(0xFF8B5CF6)),
  master(5, '마스터', '👑', Color(0xFF6366F1));

  const ChallengeDifficulty(this.level, this.displayName, this.emoji, this.color);
  
  final int level;
  final String displayName;
  final String emoji;
  final Color color;
}

/// 챌린지 스코프 열거형
enum ChallengeScope {
  personal('개인', '👤'),
  team('팀', '👥'),
  university('대학', '🏫'),
  global('전체', '🌍');

  const ChallengeScope(this.displayName, this.emoji);
  
  final String displayName;
  final String emoji;
}

/// String 확장 메서드들
extension StringExtensions on String {
  /// 색상 가져오기
  Color get color {
    switch (this.toLowerCase()) {
      case 'fitness':
      case '건강':
        return const Color(0xFF10B981);
      case 'study':
      case '학습':
        return const Color(0xFF3B82F6);
      case 'habit':
      case '습관':
        return const Color(0xFF8B5CF6);
      case 'mindfulness':
      case '마음챙김':
        return const Color(0xFFF59E0B);
      case 'lifestyle':
      case '라이프스타일':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// 이모지 가져오기
  String get emoji {
    switch (this.toLowerCase()) {
      case 'fitness':
      case '건강':
        return '💪';
      case 'study':
      case '학습':
        return '📚';
      case 'habit':
      case '습관':
        return '⚡';
      case 'mindfulness':
      case '마음챙김':
        return '🧘';
      case 'lifestyle':
      case '라이프스타일':
        return '✨';
      default:
        return '🎯';
    }
  }

  /// 표시 이름 가져오기
  String get displayName {
    switch (this.toLowerCase()) {
      case 'fitness':
        return '건강';
      case 'study':
        return '학습';
      case 'habit':
        return '습관';
      case 'mindfulness':
        return '마음챙김';
      case 'lifestyle':
        return '라이프스타일';
      default:
        return this;
    }
  }
}

/// int 확장 메서드들
extension IntExtensions on int {
  /// 난이도 이모지 가져오기
  String get emoji {
    switch (this) {
      case 1:
        return '🔰';
      case 2:
        return '⭐';
      case 3:
        return '🔥';
      case 4:
        return '💎';
      case 5:
        return '👑';
      default:
        return '🎯';
    }
  }

  /// 난이도 표시 이름 가져오기
  String get displayName {
    switch (this) {
      case 1:
        return '초급';
      case 2:
        return '중급';
      case 3:
        return '고급';
      case 4:
        return '전문가';
      case 5:
        return '마스터';
      default:
        return '알 수 없음';
    }
  }
}

/// 사용 가능한 챌린지 모델
class AvailableChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final ChallengeCategory categoryType;
  final int difficulty; // 1-5
  final int durationDays; // days
  final int maxParticipants;
  final int currentParticipants;
  final DateTime startDate;
  final DateTime endDate;
  final bool isJoined;
  final Color categoryColor;
  final IconData categoryIcon;
  final List<String> requirements;
  final Map<String, dynamic> rewards;

  AvailableChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryType,
    required this.difficulty,
    required this.durationDays,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.startDate,
    required this.endDate,
    this.isJoined = false,
    Color? categoryColor,
    this.categoryIcon = Icons.emoji_events,
    this.requirements = const [],
    this.rewards = const {},
  }) : categoryColor = categoryColor ?? categoryType.color;

  /// 참여 가능 여부
  bool get canJoin {
    return !isJoined && 
           currentParticipants < maxParticipants && 
           DateTime.now().isBefore(startDate);
  }

  /// 진행 중인지 여부
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// 완료되었는지 여부
  bool get isCompleted {
    return DateTime.now().isAfter(endDate);
  }

  /// 참여율 계산
  double get participationRate {
    if (maxParticipants == 0) return 0.0;
    return currentParticipants / maxParticipants;
  }

  /// 대학명 (임시 속성)
  String get universityName => '셰르파 대학'; // 임시값

  /// 포맷된 기간
  String get formattedDuration => '${durationDays}일';

  /// 포맷된 날짜 범위
  String get formattedDateRange {
    final startStr = '${startDate.month}/${startDate.day}';
    final endStr = '${endDate.month}/${endDate.day}';
    return '$startStr - $endStr';
  }

  /// 일일 목표 (임시 속성)
  List<String> get dailyGoals => ['목표 1', '목표 2']; // 임시값

  /// 경험치 보상
  int get experienceReward => difficulty * 100;

  /// 완료 보상
  int get completionReward => difficulty * 50;

  /// 참여비
  int get participationFee => 0; // 기본값

  /// 스코프 (임시 속성)
  String get scope => 'university'; // 임시값

  /// 상태 색상
  Color get statusColor {
    if (isCompleted) return Colors.grey;
    if (isActive) return Colors.green;
    return categoryColor;
  }

  /// 상태
  String get status {
    if (isCompleted) return '완료';
    if (isActive) return '진행중';
    if (canJoin) return '참여가능';
    return '마감';
  }

  /// 기간 텍스트
  String get durationText => '${durationDays}일간';

  AvailableChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    ChallengeCategory? categoryType,
    int? difficulty,
    int? durationDays,
    int? maxParticipants,
    int? currentParticipants,
    DateTime? startDate,
    DateTime? endDate,
    bool? isJoined,
    Color? categoryColor,
    IconData? categoryIcon,
    List<String>? requirements,
    Map<String, dynamic>? rewards,
  }) {
    return AvailableChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryType: categoryType ?? this.categoryType,
      difficulty: difficulty ?? this.difficulty,
      durationDays: durationDays ?? this.durationDays,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isJoined: isJoined ?? this.isJoined,
      categoryColor: categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      requirements: requirements ?? this.requirements,
      rewards: rewards ?? this.rewards,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'categoryType': categoryType.name,
    'difficulty': difficulty,
    'durationDays': durationDays,
    'maxParticipants': maxParticipants,
    'currentParticipants': currentParticipants,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isJoined': isJoined,
    'requirements': requirements,
    'rewards': rewards,
  };

  factory AvailableChallenge.fromJson(Map<String, dynamic> json) {
    return AvailableChallenge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      categoryType: ChallengeCategory.values.firstWhere(
        (c) => c.name == json['categoryType'],
        orElse: () => ChallengeCategory.lifestyle,
      ),
      difficulty: json['difficulty'] ?? 1,
      durationDays: json['durationDays'] ?? json['duration'] ?? 7,
      maxParticipants: json['maxParticipants'] ?? 100,
      currentParticipants: json['currentParticipants'] ?? 0,
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(Duration(days: 7)).toIso8601String()),
      isJoined: json['isJoined'] ?? false,
      requirements: List<String>.from(json['requirements'] ?? []),
      rewards: Map<String, dynamic>.from(json['rewards'] ?? {}),
    );
  }
}