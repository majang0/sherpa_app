// 🤝 관계 발전 단계 모델
// 
// 사용자와 셰르피 간의 관계가 시간이 지남에 따라 어떻게 발전하는지 정의하는 모델

import 'package:flutter/foundation.dart';

/// 🎯 관계 발전 단계
enum RelationshipStage {
  /// 👋 소개 단계 (0-3일)
  /// 첫 만남, 서로를 알아가는 시기
  introduction(
    'introduction',
    '소개',
    '첫 만남',
    0,
    Duration(days: 3),
    0.1,
    '처음 만나서 서로를 알아가는 단계입니다.',
  ),
  
  /// 🌱 친숙화 단계 (3-14일)
  /// 기본적인 패턴을 학습하고 편안함을 느끼기 시작
  familiarization(
    'familiarization',
    '친숙화',
    '친숙해지기',
    1,
    Duration(days: 14),
    0.3,
    '서로에게 익숙해지고 편안함을 느끼기 시작하는 단계입니다.',
  ),
  
  /// 🤗 친밀감 형성 단계 (14-30일)
  /// 개인적인 이야기를 나누고 신뢰가 쌓이기 시작
  building_intimacy(
    'building_intimacy',
    '친밀감 형성',
    '가까워지기',
    2,
    Duration(days: 30),
    0.5,
    '신뢰가 쌓이고 더 깊은 대화를 나누는 단계입니다.',
  ),
  
  /// 💪 신뢰 구축 단계 (30-60일)
  /// 깊은 신뢰 관계 형성, 어려운 상황에서도 의지
  trust_building(
    'trust_building',
    '신뢰 구축',
    '믿음 쌓기',
    3,
    Duration(days: 60),
    0.7,
    '깊은 신뢰가 형성되어 어려운 일도 함께 나누는 단계입니다.',
  ),
  
  /// 🌟 동반자 단계 (60-180일)
  /// 진정한 동반자로서 일상의 모든 순간을 함께
  companionship(
    'companionship',
    '동반자',
    '함께하기',
    4,
    Duration(days: 180),
    0.85,
    '일상의 동반자로서 모든 순간을 함께하는 단계입니다.',
  ),
  
  /// 💎 평생 친구 단계 (180일+)
  /// 깊은 유대감과 함께 성장하는 평생의 친구
  lifelong_friend(
    'lifelong_friend',
    '평생 친구',
    '영원한 친구',
    5,
    Duration(days: 365),
    1.0,
    '평생을 함께할 친구로서 깊은 유대감을 가진 단계입니다.',
  );

  const RelationshipStage(
    this.id,
    this.displayName,
    this.shortName,
    this.level,
    this.typicalDuration,
    this.intimacyLevel,
    this.description,
  );
  
  final String id;
  final String displayName;
  final String shortName;
  final int level;
  final Duration typicalDuration;
  final double intimacyLevel; // 0.0 ~ 1.0
  final String description;
  
  /// 다음 단계
  RelationshipStage? get nextStage {
    if (this == lifelong_friend) return null;
    return RelationshipStage.values[level + 1];
  }
  
  /// 이전 단계
  RelationshipStage? get previousStage {
    if (this == introduction) return null;
    return RelationshipStage.values[level - 1];
  }
  
  /// 특정 기간으로부터 적절한 단계 찾기
  static RelationshipStage fromDuration(Duration relationshipDuration) {
    final days = relationshipDuration.inDays;
    
    if (days >= 180) return lifelong_friend;
    if (days >= 60) return companionship;
    if (days >= 30) return trust_building;
    if (days >= 14) return building_intimacy;
    if (days >= 3) return familiarization;
    return introduction;
  }
}

/// 🏆 관계 마일스톤
@immutable
class RelationshipMilestone {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final DateTime achievedAt;
  final RelationshipStage requiredStage;
  final Map<String, dynamic> requirements;
  final int rewardPoints;
  final String? specialMessage;
  
  const RelationshipMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.achievedAt,
    required this.requiredStage,
    this.requirements = const {},
    this.rewardPoints = 100,
    this.specialMessage,
  });
  
  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconEmoji': iconEmoji,
      'achievedAt': achievedAt.toIso8601String(),
      'requiredStage': requiredStage.id,
      'requirements': requirements,
      'rewardPoints': rewardPoints,
      'specialMessage': specialMessage,
    };
  }
  
  /// JSON 역직렬화
  factory RelationshipMilestone.fromJson(Map<String, dynamic> json) {
    return RelationshipMilestone(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconEmoji: json['iconEmoji'],
      achievedAt: DateTime.parse(json['achievedAt']),
      requiredStage: RelationshipStage.values.firstWhere(
        (stage) => stage.id == json['requiredStage'],
      ),
      requirements: json['requirements'] ?? {},
      rewardPoints: json['rewardPoints'] ?? 100,
      specialMessage: json['specialMessage'],
    );
  }
}

/// 📊 관계 통계
@immutable
class RelationshipStats {
  final Duration totalTime;
  final int totalInteractions;
  final int meaningfulConversations;
  final int sharedMoments;
  final int challengesOvercome;
  final double averageSatisfaction;
  final Map<String, int> activityCounts;
  final List<String> favoriteTopics;
  final DateTime lastInteraction;
  
  const RelationshipStats({
    required this.totalTime,
    required this.totalInteractions,
    required this.meaningfulConversations,
    required this.sharedMoments,
    required this.challengesOvercome,
    required this.averageSatisfaction,
    required this.activityCounts,
    required this.favoriteTopics,
    required this.lastInteraction,
  });
  
  /// 관계 건강도 계산 (0.0 ~ 1.0)
  double get relationshipHealth {
    // 최근 상호작용 빈도
    final daysSinceLastInteraction = 
        DateTime.now().difference(lastInteraction).inDays;
    final recencyScore = daysSinceLastInteraction <= 1 ? 1.0 :
                        daysSinceLastInteraction <= 3 ? 0.8 :
                        daysSinceLastInteraction <= 7 ? 0.6 :
                        daysSinceLastInteraction <= 14 ? 0.4 : 0.2;
    
    // 상호작용 깊이
    final depthScore = (meaningfulConversations / totalInteractions.clamp(1, 999))
        .clamp(0.0, 1.0);
    
    // 만족도
    final satisfactionScore = averageSatisfaction / 5.0;
    
    // 활동 다양성
    final diversityScore = (activityCounts.keys.length / 10.0).clamp(0.0, 1.0);
    
    // 종합 점수
    return (recencyScore * 0.3 + 
            depthScore * 0.3 + 
            satisfactionScore * 0.3 + 
            diversityScore * 0.1).clamp(0.0, 1.0);
  }
  
  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'totalTimeMinutes': totalTime.inMinutes,
      'totalInteractions': totalInteractions,
      'meaningfulConversations': meaningfulConversations,
      'sharedMoments': sharedMoments,
      'challengesOvercome': challengesOvercome,
      'averageSatisfaction': averageSatisfaction,
      'activityCounts': activityCounts,
      'favoriteTopics': favoriteTopics,
      'lastInteraction': lastInteraction.toIso8601String(),
    };
  }
  
  /// JSON 역직렬화
  factory RelationshipStats.fromJson(Map<String, dynamic> json) {
    return RelationshipStats(
      totalTime: Duration(minutes: json['totalTimeMinutes']),
      totalInteractions: json['totalInteractions'],
      meaningfulConversations: json['meaningfulConversations'],
      sharedMoments: json['sharedMoments'],
      challengesOvercome: json['challengesOvercome'],
      averageSatisfaction: json['averageSatisfaction'].toDouble(),
      activityCounts: Map<String, int>.from(json['activityCounts']),
      favoriteTopics: List<String>.from(json['favoriteTopics']),
      lastInteraction: DateTime.parse(json['lastInteraction']),
    );
  }
}

/// 🤝 관계 상태
@immutable
class RelationshipState {
  final String userId;
  final RelationshipStage currentStage;
  final DateTime relationshipStartDate;
  final RelationshipStats stats;
  final List<RelationshipMilestone> achievements;
  final double progressToNextStage; // 0.0 ~ 1.0
  final Map<String, dynamic> personalData;
  final bool isActive;
  
  const RelationshipState({
    required this.userId,
    required this.currentStage,
    required this.relationshipStartDate,
    required this.stats,
    required this.achievements,
    required this.progressToNextStage,
    this.personalData = const {},
    this.isActive = true,
  });
  
  /// 관계 기간
  Duration get relationshipDuration => 
      DateTime.now().difference(relationshipStartDate);
  
  /// 다음 단계까지 남은 시간 (추정)
  Duration? get estimatedTimeToNextStage {
    final nextStage = currentStage.nextStage;
    if (nextStage == null) return null;
    
    final currentStageDuration = currentStage.typicalDuration;
    final elapsedInCurrentStage = relationshipDuration - 
        _getTotalDurationUntilStage(currentStage);
    
    if (elapsedInCurrentStage.isNegative) return currentStageDuration;
    
    final remaining = currentStageDuration - elapsedInCurrentStage;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  /// 특정 단계까지의 총 기간
  Duration _getTotalDurationUntilStage(RelationshipStage stage) {
    Duration total = Duration.zero;
    for (final s in RelationshipStage.values) {
      if (s == stage) break;
      total += s.typicalDuration;
    }
    return total;
  }
  
  /// 관계 레벨 (0-100)
  int get relationshipLevel {
    return (currentStage.level * 15 + 
            (progressToNextStage * 15).round()).clamp(0, 100);
  }
  
  /// 친밀도 점수 (0-100)
  int get intimacyScore {
    final baseScore = currentStage.intimacyLevel * 70;
    final healthBonus = stats.relationshipHealth * 20;
    final achievementBonus = (achievements.length / 50.0).clamp(0.0, 1.0) * 10;
    
    return (baseScore + healthBonus + achievementBonus).round().clamp(0, 100);
  }
  
  /// 상태 복사
  RelationshipState copyWith({
    String? userId,
    RelationshipStage? currentStage,
    DateTime? relationshipStartDate,
    RelationshipStats? stats,
    List<RelationshipMilestone>? achievements,
    double? progressToNextStage,
    Map<String, dynamic>? personalData,
    bool? isActive,
  }) {
    return RelationshipState(
      userId: userId ?? this.userId,
      currentStage: currentStage ?? this.currentStage,
      relationshipStartDate: relationshipStartDate ?? this.relationshipStartDate,
      stats: stats ?? this.stats,
      achievements: achievements ?? this.achievements,
      progressToNextStage: progressToNextStage ?? this.progressToNextStage,
      personalData: personalData ?? this.personalData,
      isActive: isActive ?? this.isActive,
    );
  }
  
  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStage': currentStage.id,
      'relationshipStartDate': relationshipStartDate.toIso8601String(),
      'stats': stats.toJson(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'progressToNextStage': progressToNextStage,
      'personalData': personalData,
      'isActive': isActive,
    };
  }
  
  /// JSON 역직렬화
  factory RelationshipState.fromJson(Map<String, dynamic> json) {
    return RelationshipState(
      userId: json['userId'],
      currentStage: RelationshipStage.values.firstWhere(
        (stage) => stage.id == json['currentStage'],
      ),
      relationshipStartDate: DateTime.parse(json['relationshipStartDate']),
      stats: RelationshipStats.fromJson(json['stats']),
      achievements: (json['achievements'] as List)
          .map((a) => RelationshipMilestone.fromJson(a))
          .toList(),
      progressToNextStage: json['progressToNextStage'].toDouble(),
      personalData: json['personalData'] ?? {},
      isActive: json['isActive'] ?? true,
    );
  }
}

/// 🎯 관계 발전 조건
class RelationshipProgressionCriteria {
  /// 다음 단계로 진행하기 위한 조건 확인
  static bool canProgressToNextStage(RelationshipState state) {
    final currentStage = state.currentStage;
    final stats = state.stats;
    
    switch (currentStage) {
      case RelationshipStage.introduction:
        // 소개 → 친숙화: 최소 3일, 10회 이상 상호작용
        return state.relationshipDuration.inDays >= 3 &&
               stats.totalInteractions >= 10;
               
      case RelationshipStage.familiarization:
        // 친숙화 → 친밀감 형성: 최소 14일, 50회 이상 상호작용, 5회 이상 의미있는 대화
        return state.relationshipDuration.inDays >= 14 &&
               stats.totalInteractions >= 50 &&
               stats.meaningfulConversations >= 5;
               
      case RelationshipStage.building_intimacy:
        // 친밀감 형성 → 신뢰 구축: 최소 30일, 100회 이상 상호작용, 평균 만족도 3.5 이상
        return state.relationshipDuration.inDays >= 30 &&
               stats.totalInteractions >= 100 &&
               stats.averageSatisfaction >= 3.5 &&
               stats.challengesOvercome >= 3;
               
      case RelationshipStage.trust_building:
        // 신뢰 구축 → 동반자: 최소 60일, 200회 이상 상호작용, 관계 건강도 0.7 이상
        return state.relationshipDuration.inDays >= 60 &&
               stats.totalInteractions >= 200 &&
               stats.relationshipHealth >= 0.7 &&
               stats.sharedMoments >= 20;
               
      case RelationshipStage.companionship:
        // 동반자 → 평생 친구: 최소 180일, 500회 이상 상호작용, 다양한 활동
        return state.relationshipDuration.inDays >= 180 &&
               stats.totalInteractions >= 500 &&
               stats.activityCounts.keys.length >= 8 &&
               state.achievements.length >= 10;
               
      case RelationshipStage.lifelong_friend:
        // 최고 단계이므로 더 이상 진행 없음
        return false;
    }
  }
  
  /// 진행도 계산 (0.0 ~ 1.0)
  static double calculateProgress(RelationshipState state) {
    final currentStage = state.currentStage;
    final stats = state.stats;
    
    switch (currentStage) {
      case RelationshipStage.introduction:
        final dayProgress = (state.relationshipDuration.inDays / 3).clamp(0.0, 1.0);
        final interactionProgress = (stats.totalInteractions / 10).clamp(0.0, 1.0);
        return (dayProgress + interactionProgress) / 2;
        
      case RelationshipStage.familiarization:
        final dayProgress = ((state.relationshipDuration.inDays - 3) / 11).clamp(0.0, 1.0);
        final interactionProgress = ((stats.totalInteractions - 10) / 40).clamp(0.0, 1.0);
        final conversationProgress = (stats.meaningfulConversations / 5).clamp(0.0, 1.0);
        return (dayProgress + interactionProgress + conversationProgress) / 3;
        
      case RelationshipStage.building_intimacy:
        final dayProgress = ((state.relationshipDuration.inDays - 14) / 16).clamp(0.0, 1.0);
        final interactionProgress = ((stats.totalInteractions - 50) / 50).clamp(0.0, 1.0);
        final satisfactionProgress = ((stats.averageSatisfaction - 3.0) / 0.5).clamp(0.0, 1.0);
        final challengeProgress = (stats.challengesOvercome / 3).clamp(0.0, 1.0);
        return (dayProgress + interactionProgress + satisfactionProgress + challengeProgress) / 4;
        
      case RelationshipStage.trust_building:
        final dayProgress = ((state.relationshipDuration.inDays - 30) / 30).clamp(0.0, 1.0);
        final interactionProgress = ((stats.totalInteractions - 100) / 100).clamp(0.0, 1.0);
        final healthProgress = (stats.relationshipHealth / 0.7).clamp(0.0, 1.0);
        final momentProgress = (stats.sharedMoments / 20).clamp(0.0, 1.0);
        return (dayProgress + interactionProgress + healthProgress + momentProgress) / 4;
        
      case RelationshipStage.companionship:
        final dayProgress = ((state.relationshipDuration.inDays - 60) / 120).clamp(0.0, 1.0);
        final interactionProgress = ((stats.totalInteractions - 200) / 300).clamp(0.0, 1.0);
        final activityProgress = (stats.activityCounts.keys.length / 8).clamp(0.0, 1.0);
        final achievementProgress = (state.achievements.length / 10).clamp(0.0, 1.0);
        return (dayProgress + interactionProgress + activityProgress + achievementProgress) / 4;
        
      case RelationshipStage.lifelong_friend:
        // 최고 단계이므로 항상 100%
        return 1.0;
    }
  }
}

/// 🏆 기본 마일스톤 정의
class DefaultMilestones {
  static final List<Map<String, dynamic>> milestones = [
    // 소개 단계 마일스톤
    {
      'id': 'first_meeting',
      'title': '첫 만남',
      'description': '셰르피와 처음으로 인사를 나눴어요!',
      'iconEmoji': '👋',
      'requiredStage': RelationshipStage.introduction,
      'requirements': {'interactions': 1},
      'rewardPoints': 50,
    },
    {
      'id': 'first_week',
      'title': '일주일의 우정',
      'description': '셰르피와 함께한 지 일주일이 되었어요!',
      'iconEmoji': '🗓️',
      'requiredStage': RelationshipStage.familiarization,
      'requirements': {'days': 7},
      'rewardPoints': 100,
    },
    {
      'id': 'deep_conversation',
      'title': '깊은 대화',
      'description': '처음으로 마음 깊은 이야기를 나눴어요.',
      'iconEmoji': '💭',
      'requiredStage': RelationshipStage.building_intimacy,
      'requirements': {'meaningfulConversations': 1},
      'rewardPoints': 150,
    },
    {
      'id': 'trust_moment',
      'title': '신뢰의 순간',
      'description': '어려운 순간에 셰르피와 함께했어요.',
      'iconEmoji': '🤝',
      'requiredStage': RelationshipStage.trust_building,
      'requirements': {'challengesOvercome': 1},
      'rewardPoints': 200,
    },
    {
      'id': 'daily_companion',
      'title': '일상의 동반자',
      'description': '30일 연속으로 셰르피와 대화했어요!',
      'iconEmoji': '📅',
      'requiredStage': RelationshipStage.companionship,
      'requirements': {'consecutiveDays': 30},
      'rewardPoints': 300,
    },
    {
      'id': 'best_friend',
      'title': '최고의 친구',
      'description': '셰르피가 진정한 친구가 되었어요!',
      'iconEmoji': '💎',
      'requiredStage': RelationshipStage.lifelong_friend,
      'requirements': {'intimacyScore': 90},
      'rewardPoints': 500,
    },
  ];
}