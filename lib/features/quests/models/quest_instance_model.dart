import 'package:flutter/material.dart';
import 'quest_template_model.dart';

/// 퀘스트 상태
enum QuestStatus {
  notStarted('시작 전', Color(0xFF9CA3AF)),
  inProgress('진행 중', Color(0xFF3B82F6)),
  completed('완료', Color(0xFF10B981)),
  claimed('보상 수령', Color(0xFF6B7280));

  const QuestStatus(this.displayName, this.color);
  final String displayName;
  final Color color;
}

/// 실제 퀘스트 인스턴스 (템플릿 + 진행 상태)
/// 사용자가 실제로 수행하는 퀘스트 객체
class QuestInstance {
  final String instanceId;                    // 인스턴스 고유 ID
  final QuestTemplate template;               // 퀘스트 템플릿
  final QuestStatus status;                   // 현재 상태
  final int currentProgress;                  // 현재 진행도
  final DateTime? completedAt;                // 완료 시간
  final DateTime? claimedAt;                  // 보상 수령 시간
  final DateTime createdAt;                   // 생성 시간
  final bool? statGranted;                    // 능력치가 실제로 지급되었는지
  final Map<String, dynamic> trackingData;   // 추적 데이터

  const QuestInstance({
    required this.instanceId,
    required this.template,
    this.status = QuestStatus.notStarted,
    this.currentProgress = 0,
    this.completedAt,
    this.claimedAt,
    required this.createdAt,
    this.statGranted,
    this.trackingData = const {},
  });

  /// 템플릿에서 인스턴스 생성
  factory QuestInstance.fromTemplate(QuestTemplate template) {
    final now = DateTime.now();
    return QuestInstance(
      instanceId: '${template.id}_${now.millisecondsSinceEpoch}',
      template: template,
      status: QuestStatus.inProgress, // 새 시스템에서는 바로 진행 중으로 시작
      createdAt: now,
    );
  }

  /// 편의 메서드들
  String get id => template.id;
  String get title => template.title;
  String get description => template.description;
  QuestTypeV2 get type => template.type;
  QuestCategoryV2 get category => template.category;
  QuestRewardsV2 get rewards => template.rewards;
  int get targetProgress => template.targetProgress;
  QuestTrackingCondition get trackingCondition => template.trackingCondition;
  Color get difficultyColor => template.difficultyColor;
  String get difficultyName => template.difficultyName;

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progressRatio {
    if (targetProgress <= 0) return 0.0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  /// 완료 가능 여부
  bool get canComplete {
    return status == QuestStatus.inProgress && currentProgress >= targetProgress;
  }

  /// 보상 수령 가능 여부
  bool get canClaim {
    return status == QuestStatus.completed;
  }

  /// 진행 중인지 여부
  bool get isInProgress {
    return status == QuestStatus.inProgress;
  }

  /// 완료되었는지 여부 (보상 수령 포함)
  bool get isCompleted {
    return status == QuestStatus.completed || status == QuestStatus.claimed;
  }

  /// 희귀도 색상 (템플릿에서 가져옴)
  Color get rarityColor => difficultyColor;

  /// 희귀도 이름 (템플릿에서 가져옴)
  String get rarityName => difficultyName;

  /// 카테고리 이모티콘
  String get categoryEmoji => category.emoji;

  /// 진행도가 변경되었는지 확인
  bool shouldUpdateProgress(Map<String, dynamic> globalData) {
    switch (trackingCondition.type) {
      case QuestTrackingType.steps:
        final targetSteps = trackingCondition.parameters['target'] as int;
        final currentSteps = globalData['todaySteps'] as int? ?? 0;
        return currentSteps != currentProgress && currentSteps >= targetSteps;
        
      case QuestTrackingType.globalData:
        final dataPath = trackingCondition.parameters['path'] as String;
        final targetValue = trackingCondition.parameters['target'];
        final currentValue = _getValueFromPath(globalData, dataPath);
        return currentValue != currentProgress && 
               _compareValues(currentValue, targetValue) >= 0;
        
      case QuestTrackingType.weeklyAccumulation:
        final dataType = trackingCondition.parameters['dataType'] as String;
        final targetValue = trackingCondition.parameters['target'];
        final currentValue = globalData['weekly_$dataType'] ?? 0;
        return currentValue != currentProgress && currentValue >= targetValue;
        
      case QuestTrackingType.appLaunch:
        return status == QuestStatus.notStarted && 
               globalData['appLaunched'] == true;
        
      case QuestTrackingType.tabVisit:
        final targetTab = trackingCondition.parameters['tab'] as String;
        final visitedTab = globalData['visitedTab'] as String?;
        return visitedTab == targetTab && status != QuestStatus.completed;
        
      default:
        return false;
    }
  }

  /// 경로에서 값 가져오기
  dynamic _getValueFromPath(Map<String, dynamic> data, String path) {
    final parts = path.split('.');
    dynamic current = data;
    
    for (final part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    
    return current;
  }

  /// 값 비교
  int _compareValues(dynamic a, dynamic b) {
    if (a == null || b == null) return -1;
    
    if (a is num && b is num) {
      return a.compareTo(b);
    } else if (a is bool && b is bool) {
      return a == b ? 0 : -1;
    } else {
      return a.toString().compareTo(b.toString());
    }
  }

  QuestInstance copyWith({
    String? instanceId,
    QuestTemplate? template,
    QuestStatus? status,
    int? currentProgress,
    DateTime? completedAt,
    DateTime? claimedAt,
    DateTime? createdAt,
    bool? statGranted,
    Map<String, dynamic>? trackingData,
  }) {
    return QuestInstance(
      instanceId: instanceId ?? this.instanceId,
      template: template ?? this.template,
      status: status ?? this.status,
      currentProgress: currentProgress ?? this.currentProgress,
      completedAt: completedAt ?? this.completedAt,
      claimedAt: claimedAt ?? this.claimedAt,
      createdAt: createdAt ?? this.createdAt,
      statGranted: statGranted ?? this.statGranted,
      trackingData: trackingData ?? this.trackingData,
    );
  }

  Map<String, dynamic> toJson() => {
    'instanceId': instanceId,
    'template': template.toJson(),
    'status': status.name,
    'currentProgress': currentProgress,
    'completedAt': completedAt?.toIso8601String(),
    'claimedAt': claimedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'statGranted': statGranted,
    'trackingData': trackingData,
  };

  factory QuestInstance.fromJson(Map<String, dynamic> json) => QuestInstance(
    instanceId: json['instanceId'] ?? '',
    template: QuestTemplate.fromJson(json['template'] ?? {}),
    status: QuestStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => QuestStatus.notStarted,
    ),
    currentProgress: json['currentProgress'] ?? 0,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'])
        : null,
    claimedAt: json['claimedAt'] != null
        ? DateTime.parse(json['claimedAt'])
        : null,
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    statGranted: json['statGranted'],
    trackingData: json['trackingData'] ?? {},
  );
}

/// 퀘스트 진행 요약 정보 (새 시스템)
class QuestProgressV2 {
  final int totalQuests;
  final int inProgressQuests;
  final int completedQuests;
  final int claimableQuests;
  final int todayCompletedQuests;
  final double overallProgress;
  final bool dailyAllCompleted;
  final bool weeklyAllCompleted;

  const QuestProgressV2({
    this.totalQuests = 0,
    this.inProgressQuests = 0,
    this.completedQuests = 0,
    this.claimableQuests = 0,
    this.todayCompletedQuests = 0,
    this.overallProgress = 0.0,
    this.dailyAllCompleted = false,
    this.weeklyAllCompleted = false,
  });

  /// 완료 가능한 퀘스트 수
  int get completableQuests => inProgressQuests;

  /// 전체 완료 여부 체크
  bool get isAllDailyQuestsCompleted => dailyAllCompleted;
  bool get isAllWeeklyQuestsCompleted => weeklyAllCompleted;
}

/// 퀘스트 완료 보너스 정보
class QuestCompletionBonus {
  final QuestTypeV2 questType;
  final double experienceBonus;
  final double pointsBonus;
  final String description;

  const QuestCompletionBonus({
    required this.questType,
    required this.experienceBonus,
    required this.pointsBonus,
    required this.description,
  });

  /// 일일 퀘스트 전체 완료 보너스
  static const QuestCompletionBonus dailyBonus = QuestCompletionBonus(
    questType: QuestTypeV2.daily,
    experienceBonus: 100.0,
    pointsBonus: 50.0,
    description: '일일 퀘스트 전체 완료 보너스',
  );

  /// 주간 퀘스트 전체 완료 보너스
  static const QuestCompletionBonus weeklyBonus = QuestCompletionBonus(
    questType: QuestTypeV2.weekly,
    experienceBonus: 300.0,
    pointsBonus: 100.0,
    description: '주간 퀘스트 전체 완료 보너스',
  );
}