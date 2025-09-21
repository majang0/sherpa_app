import 'package:flutter/foundation.dart';

/// 🤝 셰르피와의 관계 모델
///
/// 사용자와 셰르피 간의 친밀도, 상호작용 기록, 성장 과정을 추적합니다.
@immutable
class SherpiRelationship {
  final int intimacyLevel; // 친밀도 레벨 (1-10)
  final int totalInteractions; // 총 상호작용 횟수
  final int consecutiveDays; // 연속 대화 일수
  final DateTime firstMeetingDate; // 첫 만남 날짜
  final DateTime lastInteractionDate; // 마지막 상호작용 날짜
  final Map<String, int> interactionTypes; // 상호작용 유형별 횟수
  final List<SpecialMoment> specialMoments; // 특별한 순간들
  final PersonalityInsights personalityInsights; // 성격 인사이트
  final PersonalizationSettings personalizationSettings; // 개인화 설정 (Phase 2)
  final double emotionalSync; // 감정 동기화 수준 (0.0-1.0)

  const SherpiRelationship({
    this.intimacyLevel = 1,
    this.totalInteractions = 0,
    this.consecutiveDays = 0,
    required this.firstMeetingDate,
    required this.lastInteractionDate,
    this.interactionTypes = const {},
    this.specialMoments = const [],
    this.personalityInsights = const PersonalityInsights(),
    this.personalizationSettings = const PersonalizationSettings(),
    this.emotionalSync = 0.0,
  });

  /// 친밀도 레벨 계산 (경험치 기반)
  static int calculateIntimacyLevel(
      int totalInteractions, int consecutiveDays) {
    // 기본 점수: 상호작용 횟수
    double score = totalInteractions * 0.1;

    // 연속 일수 보너스
    if (consecutiveDays >= 30) {
      score += 3.0;
    } else if (consecutiveDays >= 14)
      score += 2.0;
    else if (consecutiveDays >= 7) score += 1.0;

    // 레벨 계산 (최대 10)
    return (score / 10).clamp(1, 10).toInt();
  }

  /// 친밀도 레벨별 호칭
  String get relationshipTitle {
    switch (intimacyLevel) {
      case 1:
        return "새로운 친구";
      case 2:
        return "등산 동료";
      case 3:
        return "믿음직한 파트너";
      case 4:
        return "든든한 동반자";
      case 5:
        return "특별한 친구";
      case 6:
        return "소중한 동료";
      case 7:
        return "베스트 파트너";
      case 8:
        return "영혼의 동반자";
      case 9:
        return "평생 친구";
      case 10:
        return "운명의 셰르파";
      default:
        return "친구";
    }
  }

  /// 다음 레벨까지 필요한 상호작용 횟수
  int get interactionsToNextLevel {
    if (intimacyLevel >= 10) return 0;
    final nextLevelRequirement = (intimacyLevel + 1) * 100;
    final remainingInteractions = nextLevelRequirement - totalInteractions;
    return remainingInteractions > 0 ? remainingInteractions : 0;
  }

  /// 감정 동기화 수준 설명
  String get emotionalSyncDescription {
    if (emotionalSync >= 0.8) return "완벽한 호흡";
    if (emotionalSync >= 0.6) return "깊은 이해";
    if (emotionalSync >= 0.4) return "따뜻한 공감";
    if (emotionalSync >= 0.2) return "점점 가까워지는 중";
    return "서로 알아가는 중";
  }

  SherpiRelationship copyWith({
    int? intimacyLevel,
    int? totalInteractions,
    int? consecutiveDays,
    DateTime? firstMeetingDate,
    DateTime? lastInteractionDate,
    Map<String, int>? interactionTypes,
    List<SpecialMoment>? specialMoments,
    PersonalityInsights? personalityInsights,
    PersonalizationSettings? personalizationSettings,
    double? emotionalSync,
  }) {
    return SherpiRelationship(
      intimacyLevel: intimacyLevel ?? this.intimacyLevel,
      totalInteractions: totalInteractions ?? this.totalInteractions,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      firstMeetingDate: firstMeetingDate ?? this.firstMeetingDate,
      lastInteractionDate: lastInteractionDate ?? this.lastInteractionDate,
      interactionTypes: interactionTypes ?? this.interactionTypes,
      specialMoments: specialMoments ?? this.specialMoments,
      personalityInsights: personalityInsights ?? this.personalityInsights,
      personalizationSettings:
          personalizationSettings ?? this.personalizationSettings,
      emotionalSync: emotionalSync ?? this.emotionalSync,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intimacyLevel': intimacyLevel,
      'totalInteractions': totalInteractions,
      'consecutiveDays': consecutiveDays,
      'firstMeetingDate': firstMeetingDate.toIso8601String(),
      'lastInteractionDate': lastInteractionDate.toIso8601String(),
      'interactionTypes': interactionTypes,
      'specialMoments': specialMoments.map((m) => m.toJson()).toList(),
      'personalityInsights': personalityInsights.toJson(),
      'personalizationSettings': personalizationSettings.toJson(),
      'emotionalSync': emotionalSync,
    };
  }

  factory SherpiRelationship.fromJson(Map<String, dynamic> json) {
    return SherpiRelationship(
      intimacyLevel: json['intimacyLevel'] ?? 1,
      totalInteractions: json['totalInteractions'] ?? 0,
      consecutiveDays: json['consecutiveDays'] ?? 0,
      firstMeetingDate: DateTime.parse(
          json['firstMeetingDate'] ?? DateTime.now().toIso8601String()),
      lastInteractionDate: DateTime.parse(
          json['lastInteractionDate'] ?? DateTime.now().toIso8601String()),
      interactionTypes: Map<String, int>.from(json['interactionTypes'] ?? {}),
      specialMoments: (json['specialMoments'] as List? ?? [])
          .map((m) => SpecialMoment.fromJson(m))
          .toList(),
      personalityInsights:
          PersonalityInsights.fromJson(json['personalityInsights'] ?? {}),
      personalizationSettings: PersonalizationSettings.fromJson(
          json['personalizationSettings'] ?? {}),
      emotionalSync: (json['emotionalSync'] ?? 0.0).toDouble(),
    );
  }
}

/// 🎨 개인화 설정 (Phase 2 - Week 1)
/// 사용자가 직접 설정하는 셰르피 성격과 상호작용 방식
@immutable
class PersonalizationSettings {
  final SherpiPersonalityType personalityType; // 성격 유형
  final String nickname; // 사용자가 정한 셰르피 호칭
  final String userPreferredName; // 셰르피가 사용자를 부르는 이름
  final MessageFrequency messageFrequency; // 메시지 빈도 설정
  final bool useEmojisInMessages; // 메시지에 이모지 사용 여부
  final bool enablePersonalizedTone; // 개인화된 톤 사용 여부

  const PersonalizationSettings({
    this.personalityType = SherpiPersonalityType.balanced,
    this.nickname = '셰르피',
    this.userPreferredName = '친구',
    this.messageFrequency = MessageFrequency.normal,
    this.useEmojisInMessages = true,
    this.enablePersonalizedTone = true,
  });

  /// 성격 유형별 메시지 톤 가이드
  String get personalityToneGuide {
    switch (personalityType) {
      case SherpiPersonalityType.energetic:
        return "활발하고 열정적인 톤. 감탄사를 많이 사용하고 에너지 넘치는 표현 선호";
      case SherpiPersonalityType.calm:
        return "차분하고 안정감 있는 톤. 부드러운 표현과 신중한 조언을 제공";
      case SherpiPersonalityType.humorous:
        return "유머러스하고 재치있는 톤. 적절한 농담과 가벼운 말장난으로 분위기를 밝게";
      case SherpiPersonalityType.serious:
        return "진지하고 체계적인 톤. 명확한 정보 전달과 구체적인 조언에 중점";
      case SherpiPersonalityType.balanced:
        return "균형잡힌 톤. 상황에 맞게 활발함과 차분함을 적절히 조절";
    }
  }

  /// 사용자 닉네임 (userPreferredName의 별칭)
  String get userNickname => userPreferredName;

  /// 셰르피 닉네임 (nickname의 별칭)
  String get sherpiNickname => nickname;

  /// 메시지 빈도별 AI 사용률 조정 계수
  double get messageFrequencyMultiplier {
    switch (messageFrequency) {
      case MessageFrequency.minimal:
        return 0.3; // 30% 빈도
      case MessageFrequency.low:
        return 0.6; // 60% 빈도
      case MessageFrequency.normal:
        return 1.0; // 100% 기본 빈도
      case MessageFrequency.high:
        return 1.4; // 140% 빈도
      case MessageFrequency.maximum:
        return 2.0; // 200% 빈도
    }
  }

  PersonalizationSettings copyWith({
    SherpiPersonalityType? personalityType,
    String? nickname,
    String? userPreferredName,
    MessageFrequency? messageFrequency,
    bool? useEmojisInMessages,
    bool? enablePersonalizedTone,
  }) {
    return PersonalizationSettings(
      personalityType: personalityType ?? this.personalityType,
      nickname: nickname ?? this.nickname,
      userPreferredName: userPreferredName ?? this.userPreferredName,
      messageFrequency: messageFrequency ?? this.messageFrequency,
      useEmojisInMessages: useEmojisInMessages ?? this.useEmojisInMessages,
      enablePersonalizedTone:
          enablePersonalizedTone ?? this.enablePersonalizedTone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personalityType': personalityType.name,
      'nickname': nickname,
      'userPreferredName': userPreferredName,
      'messageFrequency': messageFrequency.name,
      'useEmojisInMessages': useEmojisInMessages,
      'enablePersonalizedTone': enablePersonalizedTone,
    };
  }

  factory PersonalizationSettings.fromJson(Map<String, dynamic> json) {
    return PersonalizationSettings(
      personalityType: SherpiPersonalityType.values.firstWhere(
        (e) => e.name == json['personalityType'],
        orElse: () => SherpiPersonalityType.balanced,
      ),
      nickname: json['nickname'] ?? '셰르피',
      userPreferredName: json['userPreferredName'] ?? '친구',
      messageFrequency: MessageFrequency.values.firstWhere(
        (e) => e.name == json['messageFrequency'],
        orElse: () => MessageFrequency.normal,
      ),
      useEmojisInMessages: json['useEmojisInMessages'] ?? true,
      enablePersonalizedTone: json['enablePersonalizedTone'] ?? true,
    );
  }
}

/// 🎭 셰르피 성격 유형 (사용자 설정 가능)
enum SherpiPersonalityType {
  /// ⚡ 활발하고 에너지 넘치는 성격
  energetic('활발형', '에너지 넘치고 열정적인 셰르피! 항상 응원하고 함께 기뻐해요!'),

  /// 🧘 차분하고 안정감 있는 성격
  calm('차분형', '차분하고 신중한 셰르피. 깊이 있는 조언과 안정감을 드려요.'),

  /// 😄 유머러스하고 재치있는 성격
  humorous('유머형', '재치 넘치는 셰르피! 적절한 농담으로 분위기를 밝게 만들어요.'),

  /// 🎯 진지하고 체계적인 성격
  serious('진지형', '체계적이고 목표 지향적인 셰르피. 구체적이고 실용적인 도움을 드려요.'),

  /// ⚖️ 균형잡힌 성격 (기본값)
  balanced('균형형', '상황에 맞게 적절한 반응을 보이는 셰르피. 모든 상황에 잘 어울려요.');

  const SherpiPersonalityType(this.displayName, this.description);

  final String displayName;
  final String description;

  /// 한국어 이름 (displayName의 별칭)
  String get koreanName => displayName;
}

/// 📊 메시지 빈도 설정
enum MessageFrequency {
  /// 🔕 최소한의 메시지만 (중요한 순간만)
  minimal('최소', '꼭 필요한 순간에만'),

  /// 🔔 적은 빈도 (주요 성취 시)
  low('적음', '주요 성취 순간에'),

  /// 🔔 일반 빈도 (기본값)
  normal('보통', '적당한 빈도로'),

  /// 🔔 많은 빈도 (자주 격려)
  high('많음', '자주 격려하며'),

  /// 🔔 최대 빈도 (모든 순간)
  maximum('최대', '모든 순간을 함께');

  const MessageFrequency(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// 🌟 특별한 순간 기록
@immutable
class SpecialMoment {
  final String id;
  final DateTime timestamp;
  final String type; // first_climb, level_milestone, streak_achievement 등
  final String title;
  final String description;
  final Map<String, dynamic> metadata;

  const SpecialMoment({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    required this.description,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'title': title,
      'description': description,
      'metadata': metadata,
    };
  }

  factory SpecialMoment.fromJson(Map<String, dynamic> json) {
    return SpecialMoment(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      title: json['title'],
      description: json['description'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

/// 🧠 성격 인사이트
@immutable
class PersonalityInsights {
  final double motivationStyle; // 0: 외적 동기 ~ 1: 내적 동기
  final double activityPreference; // 0: 정적 활동 ~ 1: 동적 활동
  final double socialTendency; // 0: 개인 중심 ~ 1: 사회적
  final double goalOrientation; // 0: 과정 중심 ~ 1: 결과 중심
  final double stressResponse; // 0: 회피형 ~ 1: 대응형

  const PersonalityInsights({
    this.motivationStyle = 0.5,
    this.activityPreference = 0.5,
    this.socialTendency = 0.5,
    this.goalOrientation = 0.5,
    this.stressResponse = 0.5,
  });

  /// 주요 성격 유형 판단
  String get primaryPersonalityType {
    final Map<String, double> scores = {
      '성취형': goalOrientation * 0.6 + motivationStyle * 0.4,
      '탐험형': activityPreference * 0.6 + (1 - goalOrientation) * 0.4,
      '사교형': socialTendency * 0.8 + motivationStyle * 0.2,
      '성장형': motivationStyle * 0.5 + stressResponse * 0.5,
    };

    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  PersonalityInsights updateFromInteraction({
    required String interactionType,
    required Map<String, dynamic> context,
  }) {
    // 상호작용 유형에 따른 성격 지표 업데이트 로직
    double newMotivation = motivationStyle;
    double newActivity = activityPreference;
    double newSocial = socialTendency;
    double newGoal = goalOrientation;
    double newStress = stressResponse;

    // 예시: 운동 완료 시 동적 활동 선호도 증가
    if (interactionType == 'exercise_complete') {
      newActivity = (activityPreference + 0.02).clamp(0.0, 1.0);
    }
    // 모임 참여 시 사회적 경향 증가
    else if (interactionType == 'meeting_joined') {
      newSocial = (socialTendency + 0.03).clamp(0.0, 1.0);
    }

    return PersonalityInsights(
      motivationStyle: newMotivation,
      activityPreference: newActivity,
      socialTendency: newSocial,
      goalOrientation: newGoal,
      stressResponse: newStress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'motivationStyle': motivationStyle,
      'activityPreference': activityPreference,
      'socialTendency': socialTendency,
      'goalOrientation': goalOrientation,
      'stressResponse': stressResponse,
    };
  }

  factory PersonalityInsights.fromJson(Map<String, dynamic> json) {
    return PersonalityInsights(
      motivationStyle: (json['motivationStyle'] ?? 0.5).toDouble(),
      activityPreference: (json['activityPreference'] ?? 0.5).toDouble(),
      socialTendency: (json['socialTendency'] ?? 0.5).toDouble(),
      goalOrientation: (json['goalOrientation'] ?? 0.5).toDouble(),
      stressResponse: (json['stressResponse'] ?? 0.5).toDouble(),
    );
  }
}
