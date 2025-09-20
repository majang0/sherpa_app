import 'package:flutter/foundation.dart';

/// 🎭 사용자 감정 분석 결과
@immutable
class EmotionAnalysisResult {
  final UserEmotionState primaryEmotion;
  final double confidence;
  final Map<UserEmotionState, double> emotionScores;
  final DateTime analyzedAt;
  final Map<String, dynamic> analysisContext;

  const EmotionAnalysisResult({
    required this.primaryEmotion,
    required this.confidence,
    required this.emotionScores,
    required this.analyzedAt,
    required this.analysisContext,
  });

  EmotionAnalysisResult copyWith({
    UserEmotionState? primaryEmotion,
    double? confidence,
    Map<UserEmotionState, double>? emotionScores,
    DateTime? analyzedAt,
    Map<String, dynamic>? analysisContext,
  }) {
    return EmotionAnalysisResult(
      primaryEmotion: primaryEmotion ?? this.primaryEmotion,
      confidence: confidence ?? this.confidence,
      emotionScores: emotionScores ?? this.emotionScores,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      analysisContext: analysisContext ?? this.analysisContext,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryEmotion': primaryEmotion.name,
      'confidence': confidence,
      'emotionScores':
          emotionScores.map((key, value) => MapEntry(key.name, value)),
      'analyzedAt': analyzedAt.toIso8601String(),
      'analysisContext': analysisContext,
    };
  }

  factory EmotionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return EmotionAnalysisResult(
      primaryEmotion: UserEmotionState.values.firstWhere(
        (e) => e.name == json['primaryEmotion'],
        orElse: () => UserEmotionState.neutral,
      ),
      confidence: json['confidence']?.toDouble() ?? 0.0,
      emotionScores: (json['emotionScores'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(
                UserEmotionState.values.firstWhere(
                  (e) => e.name == key,
                  orElse: () => UserEmotionState.neutral,
                ),
                value?.toDouble() ?? 0.0,
              )),
      analyzedAt: DateTime.parse(json['analyzedAt']),
      analysisContext: json['analysisContext'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// 👤 사용자 감정 상태
enum UserEmotionState {
  /// 😊 긍정적인 감정 - 성과 달성, 목표 완수 시
  positive,

  /// 😔 부정적인 감정 - 실패, 좌절 시
  negative,

  /// 😐 중립적인 감정 - 평상시
  neutral,

  /// 💪 동기부여된 상태 - 새로운 도전, 계획 세울 때
  motivated,

  /// 😴 피곤한 상태 - 장시간 활동 후, 늦은 시간
  tired,

  /// 🎉 흥분된 상태 - 큰 성취, 특별한 순간
  excited,

  /// 😰 스트레스 상태 - 연속 실패, 압박감
  stressed,

  /// 🤔 고민하는 상태 - 결정이 필요한 순간
  contemplative,
}

/// 🎭 감정 분석 컨텍스트
@immutable
class EmotionAnalysisContext {
  final String activityType;
  final bool isSuccess;
  final int consecutiveDays;
  final int timeOfDay; // 0-23 시간
  final int dayOfWeek; // 1-7 (월-일)
  final Map<String, dynamic> performanceData;
  final List<String> recentActivities;

  const EmotionAnalysisContext({
    required this.activityType,
    required this.isSuccess,
    required this.consecutiveDays,
    required this.timeOfDay,
    required this.dayOfWeek,
    required this.performanceData,
    required this.recentActivities,
  });

  Map<String, dynamic> toJson() {
    return {
      'activityType': activityType,
      'isSuccess': isSuccess,
      'consecutiveDays': consecutiveDays,
      'timeOfDay': timeOfDay,
      'dayOfWeek': dayOfWeek,
      'performanceData': performanceData,
      'recentActivities': recentActivities,
    };
  }

  factory EmotionAnalysisContext.fromJson(Map<String, dynamic> json) {
    return EmotionAnalysisContext(
      activityType: json['activityType'] ?? '',
      isSuccess: json['isSuccess'] ?? false,
      consecutiveDays: json['consecutiveDays'] ?? 0,
      timeOfDay: json['timeOfDay'] ?? 0,
      dayOfWeek: json['dayOfWeek'] ?? 1,
      performanceData: json['performanceData'] as Map<String, dynamic>? ?? {},
      recentActivities: List<String>.from(json['recentActivities'] ?? []),
    );
  }
}

/// 🎯 감정 동기화 레벨
enum EmotionalSyncLevel {
  /// 💔 동기화 안됨 (0.0 - 0.2)
  none,

  /// 😐 기본 동기화 (0.2 - 0.4)
  basic,

  /// 😊 좋은 동기화 (0.4 - 0.6)
  good,

  /// 💖 강한 동기화 (0.6 - 0.8)
  strong,

  /// 💕 완벽한 동기화 (0.8 - 1.0)
  perfect,
}

extension EmotionalSyncLevelExtension on EmotionalSyncLevel {
  String get description {
    switch (this) {
      case EmotionalSyncLevel.none:
        return '아직 어색해요';
      case EmotionalSyncLevel.basic:
        return '조금씩 알아가요';
      case EmotionalSyncLevel.good:
        return '마음이 통해요';
      case EmotionalSyncLevel.strong:
        return '깊이 이해해요';
      case EmotionalSyncLevel.perfect:
        return '하나가 된 느낌';
    }
  }

  String get emoji {
    switch (this) {
      case EmotionalSyncLevel.none:
        return '😐';
      case EmotionalSyncLevel.basic:
        return '🙂';
      case EmotionalSyncLevel.good:
        return '😊';
      case EmotionalSyncLevel.strong:
        return '💖';
      case EmotionalSyncLevel.perfect:
        return '💕';
    }
  }

  static EmotionalSyncLevel fromValue(double value) {
    if (value >= 0.8) return EmotionalSyncLevel.perfect;
    if (value >= 0.6) return EmotionalSyncLevel.strong;
    if (value >= 0.4) return EmotionalSyncLevel.good;
    if (value >= 0.2) return EmotionalSyncLevel.basic;
    return EmotionalSyncLevel.none;
  }
}
