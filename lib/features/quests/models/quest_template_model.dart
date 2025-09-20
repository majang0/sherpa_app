import 'package:flutter/material.dart';

/// 퀘스트 템플릿 모델 - quest.md 기반 고정 퀘스트 시스템
///
/// 이 파일은 quest.md에 정의된 모든 퀘스트 템플릿을 관리합니다.

/// 퀘스트 추적 방법 타입
enum QuestTrackingType {
  appLaunch, // 앱 실행 시 자동 완료
  steps, // 걸음수 기반 추적
  tabVisit, // 특정 탭 방문
  globalData, // 글로벌 데이터 기반 추적
  userAction, // 사용자 액션 기반
  weeklyAccumulation, // 주간 누적 기반
  dailyCompletion, // 일일 완료 기반
  multipleConditions, // 복합 조건
}

/// 퀘스트 유형 (새로운 시스템)
enum QuestTypeV2 {
  daily('일일', Icons.today, Color(0xFF3B82F6)),
  weekly('주간', Icons.date_range, Color(0xFF8B5CF6)),
  premium('고급', Icons.star, Color(0xFFFFB800));

  const QuestTypeV2(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 퀘스트 난이도 (일일/주간용)
enum QuestDifficultyV2 {
  easy('쉬움', Color(0xFF10B981), 0.0, 20.0, 0.0), // XP: 20, Point: 0, 확률: 0%
  medium('보통', Color(0xFFF59E0B), 0.3, 30.0, 0.0), // XP: 30, Point: 0, 확률: 30%
  hard('어려움', Color(0xFFEF4444), 0.5, 50.0, 0.0); // XP: 50, Point: 0, 확률: 50%

  const QuestDifficultyV2(this.displayName, this.color, this.statChance,
      this.baseXP, this.basePoints);
  final String displayName;
  final Color color;
  final double statChance; // 능력치 증가 확률
  final double baseXP; // 기본 경험치
  final double basePoints; // 기본 포인트
}

/// 퀘스트 희귀도 (고급 퀘스트용)
enum QuestRarityV2 {
  rare('레어', Color(0xFF3B82F6), 100.0, 100.0,
      0.7), // XP: 100, Point: 100, 확률: 70%
  epic('에픽', Color(0xFF8B5CF6), 150.0, 200.0,
      1.0), // XP: 150, Point: 200, 확률: 100%
  legendary('전설', Color(0xFFFFB800), 200.0, 300.0,
      1.0); // XP: 200, Point: 300, 확률: 100%

  const QuestRarityV2(this.displayName, this.color, this.baseXP,
      this.basePoints, this.statChance);
  final String displayName;
  final Color color;
  final double baseXP;
  final double basePoints;
  final double statChance;
}

/// 주간 퀘스트 난이도별 보상 (quest.md 기준)
enum WeeklyQuestDifficultyV2 {
  easy('쉬움', Color(0xFF10B981), 0.3, 30.0, 0.0), // XP: 30, Point: 0, 확률: 30%
  medium('보통', Color(0xFFF59E0B), 0.5, 50.0, 0.0), // XP: 50, Point: 0, 확률: 50%
  hard('어려움', Color(0xFFEF4444), 0.7, 80.0, 50.0); // XP: 80, Point: 50, 확률: 70%

  const WeeklyQuestDifficultyV2(this.displayName, this.color, this.statChance,
      this.baseXP, this.basePoints);
  final String displayName;
  final Color color;
  final double statChance;
  final double baseXP;
  final double basePoints;
}

/// 퀘스트 카테고리 (능력치와 연결)
enum QuestCategoryV2 {
  stamina('체력', Icons.fitness_center, 'stamina', '💪'),
  knowledge('지식', Icons.book, 'knowledge', '🧠'),
  technique('기술', Icons.build, 'technique', '🛠️'),
  sociality('사교성', Icons.people, 'sociality', '🤝'),
  willpower('의지력', Icons.psychology, 'willpower', '🔥');

  const QuestCategoryV2(this.displayName, this.icon, this.statType, this.emoji);
  final String displayName;
  final IconData icon;
  final String statType;
  final String emoji;
}

/// 퀘스트 추적 조건
class QuestTrackingCondition {
  final QuestTrackingType type;
  final Map<String, dynamic> parameters;
  final String description;

  const QuestTrackingCondition({
    required this.type,
    required this.parameters,
    required this.description,
  });

  /// 걸음수 기반 조건
  factory QuestTrackingCondition.steps(int targetSteps) {
    return QuestTrackingCondition(
      type: QuestTrackingType.steps,
      parameters: {'target': targetSteps},
      description: '걸음수 $targetSteps보 달성',
    );
  }

  /// 앱 실행 조건
  factory QuestTrackingCondition.appLaunch() {
    return const QuestTrackingCondition(
      type: QuestTrackingType.appLaunch,
      parameters: {},
      description: '앱 실행 시 자동 완료',
    );
  }

  /// 탭 방문 조건
  factory QuestTrackingCondition.tabVisit(String tabName) {
    return QuestTrackingCondition(
      type: QuestTrackingType.tabVisit,
      parameters: {'tab': tabName},
      description: '$tabName 탭 방문',
    );
  }

  /// 글로벌 데이터 조건
  factory QuestTrackingCondition.globalData(
      String dataPath, dynamic targetValue) {
    return QuestTrackingCondition(
      type: QuestTrackingType.globalData,
      parameters: {'path': dataPath, 'target': targetValue},
      description: '조건 달성: $dataPath >= $targetValue',
    );
  }

  /// 주간 누적 조건
  factory QuestTrackingCondition.weeklyAccumulation(
      String dataType, dynamic targetValue) {
    return QuestTrackingCondition(
      type: QuestTrackingType.weeklyAccumulation,
      parameters: {'dataType': dataType, 'target': targetValue},
      description: '주간 $dataType $targetValue 달성',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'parameters': parameters,
        'description': description,
      };

  factory QuestTrackingCondition.fromJson(Map<String, dynamic> json) =>
      QuestTrackingCondition(
        type:
            QuestTrackingType.values.firstWhere((e) => e.name == json['type']),
        parameters: json['parameters'] ?? {},
        description: json['description'] ?? '',
      );
}

/// 퀘스트 템플릿 (고정된 퀘스트 정보)
class QuestTemplate {
  final String id; // 고유 ID (예: D_E_01, W_M_05, P_R_02)
  final String title; // 퀘스트 제목
  final String description; // 퀘스트 설명
  final QuestTypeV2 type; // 퀘스트 유형
  final QuestCategoryV2 category; // 카테고리
  final QuestDifficultyV2? dailyDifficulty; // 일일 퀘스트 난이도
  final WeeklyQuestDifficultyV2? weeklyDifficulty; // 주간 퀘스트 난이도
  final QuestRarityV2? rarity; // 고급 퀘스트 희귀도
  final QuestTrackingCondition trackingCondition; // 추적 조건
  final int targetProgress; // 목표 진행도 (기본값 1)

  const QuestTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.dailyDifficulty,
    this.weeklyDifficulty,
    this.rarity,
    required this.trackingCondition,
    this.targetProgress = 1,
  });

  /// 보상 정보 계산
  QuestRewardsV2 get rewards {
    if (type == QuestTypeV2.daily && dailyDifficulty != null) {
      return QuestRewardsV2(
        experience: dailyDifficulty!.baseXP,
        points: dailyDifficulty!.basePoints,
        statType: category.statType,
        statIncrease: 0.1,
        statChance: dailyDifficulty!.statChance,
      );
    } else if (type == QuestTypeV2.weekly && weeklyDifficulty != null) {
      return QuestRewardsV2(
        experience: weeklyDifficulty!.baseXP,
        points: weeklyDifficulty!.basePoints,
        statType: category.statType,
        statIncrease: 0.1,
        statChance: weeklyDifficulty!.statChance,
      );
    } else if (type == QuestTypeV2.premium && rarity != null) {
      return QuestRewardsV2(
        experience: rarity!.baseXP,
        points: rarity!.basePoints,
        statType: category.statType,
        statIncrease: rarity == QuestRarityV2.legendary ? 0.2 : 0.1,
        statChance: rarity!.statChance,
      );
    }

    // 기본값
    return const QuestRewardsV2(
      experience: 10.0,
      points: 0.0,
      statType: 'technique',
      statIncrease: 0.1,
      statChance: 0.0,
    );
  }

  /// 난이도 색상
  Color get difficultyColor {
    if (dailyDifficulty != null) return dailyDifficulty!.color;
    if (weeklyDifficulty != null) return weeklyDifficulty!.color;
    if (rarity != null) return rarity!.color;
    return Colors.grey;
  }

  /// 난이도 이름
  String get difficultyName {
    if (dailyDifficulty != null) return dailyDifficulty!.displayName;
    if (weeklyDifficulty != null) return weeklyDifficulty!.displayName;
    if (rarity != null) return rarity!.displayName;
    return '일반';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'category': category.name,
        'dailyDifficulty': dailyDifficulty?.name,
        'weeklyDifficulty': weeklyDifficulty?.name,
        'rarity': rarity?.name,
        'trackingCondition': trackingCondition.toJson(),
        'targetProgress': targetProgress,
      };

  factory QuestTemplate.fromJson(Map<String, dynamic> json) => QuestTemplate(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        type: QuestTypeV2.values.firstWhere((e) => e.name == json['type'],
            orElse: () => QuestTypeV2.daily),
        category: QuestCategoryV2.values.firstWhere(
            (e) => e.name == json['category'],
            orElse: () => QuestCategoryV2.technique),
        dailyDifficulty: json['dailyDifficulty'] != null
            ? QuestDifficultyV2.values.firstWhere(
                (e) => e.name == json['dailyDifficulty'],
                orElse: () => QuestDifficultyV2.easy)
            : null,
        weeklyDifficulty: json['weeklyDifficulty'] != null
            ? WeeklyQuestDifficultyV2.values.firstWhere(
                (e) => e.name == json['weeklyDifficulty'],
                orElse: () => WeeklyQuestDifficultyV2.easy)
            : null,
        rarity: json['rarity'] != null
            ? QuestRarityV2.values.firstWhere((e) => e.name == json['rarity'],
                orElse: () => QuestRarityV2.rare)
            : null,
        trackingCondition:
            QuestTrackingCondition.fromJson(json['trackingCondition'] ?? {}),
        targetProgress: json['targetProgress'] ?? 1,
      );
}

/// 새로운 퀘스트 보상 모델
class QuestRewardsV2 {
  final double experience;
  final double points;
  final String statType;
  final double statIncrease;
  final double statChance;
  final bool hasSpecialReward;

  const QuestRewardsV2({
    required this.experience,
    this.points = 0.0,
    required this.statType,
    this.statIncrease = 0.1,
    this.statChance = 0.0,
    this.hasSpecialReward = false,
  });

  Map<String, dynamic> toJson() => {
        'experience': experience,
        'points': points,
        'statType': statType,
        'statIncrease': statIncrease,
        'statChance': statChance,
        'hasSpecialReward': hasSpecialReward,
      };

  factory QuestRewardsV2.fromJson(Map<String, dynamic> json) => QuestRewardsV2(
        experience: json['experience']?.toDouble() ?? 0.0,
        points: json['points']?.toDouble() ?? 0.0,
        statType: json['statType'] ?? 'technique',
        statIncrease: json['statIncrease']?.toDouble() ?? 0.1,
        statChance: json['statChance']?.toDouble() ?? 0.0,
        hasSpecialReward: json['hasSpecialReward'] ?? false,
      );
}
