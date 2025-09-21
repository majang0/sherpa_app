// 📊 행동 패턴 기반 감정 추론 시스템
//
// 사용자의 앱 내 행동 패턴을 분석하여 감정 상태를 추론하는 시스템

import 'dart:math';
import '../models/emotion_state_model.dart';

/// 🎯 행동 패턴 데이터
class BehaviorPattern {
  final String userId;
  final DateTime timestamp;
  final String
      activityType; // 'exercise', 'reading', 'diary', 'quest', 'meeting'
  final Duration duration;
  final Map<String, dynamic> activityData;
  final String? mood; // 사용자가 직접 입력한 기분 (있는 경우)
  final double? satisfactionScore; // 만족도 점수 (1-5)

  const BehaviorPattern({
    required this.userId,
    required this.timestamp,
    required this.activityType,
    required this.duration,
    required this.activityData,
    this.mood,
    this.satisfactionScore,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'activityType': activityType,
      'duration': duration.inMinutes,
      'activityData': activityData,
      'mood': mood,
      'satisfactionScore': satisfactionScore,
    };
  }

  /// JSON 역직렬화
  factory BehaviorPattern.fromJson(Map<String, dynamic> json) {
    return BehaviorPattern(
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      activityType: json['activityType'],
      duration: Duration(minutes: json['duration']),
      activityData: json['activityData'] ?? {},
      mood: json['mood'],
      satisfactionScore: json['satisfactionScore']?.toDouble(),
    );
  }
}

/// 📈 행동 패턴 기반 감정 분석기
class BehaviorEmotionAnalyzer {
  static const int _minimumPatternsRequired = 3;
  static const int _analysisWindowDays = 7;

  /// 🎯 메인 분석 함수
  ///
  /// 최근 행동 패턴들을 분석하여 현재 감정 상태를 추론
  static EmotionSnapshot? analyzeBehaviorPatterns(
    List<BehaviorPattern> recentPatterns, {
    Map<String, dynamic> context = const {},
    String? trigger,
  }) {
    if (recentPatterns.length < _minimumPatternsRequired) {
      return null; // 분석하기에 데이터가 부족
    }

    // 최근 일주일 내 패턴만 사용
    final cutoffDate =
        DateTime.now().subtract(const Duration(days: _analysisWindowDays));
    final relevantPatterns =
        recentPatterns.where((p) => p.timestamp.isAfter(cutoffDate)).toList();

    if (relevantPatterns.length < _minimumPatternsRequired) {
      return null;
    }

    // 다양한 행동 지표 분석
    final activityAnalysis = _analyzeActivityPatterns(relevantPatterns);
    final moodAnalysis = _analyzeMoodPatterns(relevantPatterns);
    final timeAnalysis = _analyzeTimePatterns(relevantPatterns);
    final consistencyAnalysis = _analyzeConsistencyPatterns(relevantPatterns);

    // 감정 점수 계산
    final emotionScores = _calculateEmotionScoresFromBehavior(
      activityAnalysis,
      moodAnalysis,
      timeAnalysis,
      consistencyAnalysis,
    );

    // 주요 감정 선택
    final dominantEmotion = _selectDominantEmotionFromBehavior(emotionScores);

    // 강도 계산
    final intensity = _calculateIntensityFromBehavior(
      emotionScores,
      activityAnalysis,
      consistencyAnalysis,
    );

    // 신뢰도 계산
    final confidence = _calculateConfidenceFromBehavior(
      relevantPatterns.length,
      emotionScores,
      consistencyAnalysis,
    );

    return EmotionSnapshot(
      type: dominantEmotion,
      intensity: intensity,
      confidence: confidence,
      source: EmotionSource.behaviorPattern,
      timestamp: DateTime.now(),
      context: {
        ...context,
        'patterns_analyzed': relevantPatterns.length,
        'analysis_window_days': _analysisWindowDays,
        'activity_analysis': activityAnalysis,
        'mood_analysis': moodAnalysis,
        'time_analysis': timeAnalysis,
        'consistency_analysis': consistencyAnalysis,
        'emotion_scores': emotionScores.map((k, v) => MapEntry(k.id, v)),
      },
      trigger: trigger,
      note: '행동 패턴 분석 기반 감정 추론',
    );
  }

  /// 🏃 활동 패턴 분석
  static Map<String, dynamic> _analyzeActivityPatterns(
      List<BehaviorPattern> patterns) {
    final activityCounts = <String, int>{};
    final activityDurations = <String, Duration>{};
    final activitySatisfactions = <String, List<double>>{};

    for (final pattern in patterns) {
      final type = pattern.activityType;

      // 활동 빈도
      activityCounts[type] = (activityCounts[type] ?? 0) + 1;

      // 활동 시간
      activityDurations[type] = Duration(
        minutes: (activityDurations[type]?.inMinutes ?? 0) +
            pattern.duration.inMinutes,
      );

      // 만족도 수집
      if (pattern.satisfactionScore != null) {
        activitySatisfactions[type] = (activitySatisfactions[type] ?? [])
          ..add(pattern.satisfactionScore!);
      }
    }

    // 평균 만족도 계산
    final avgSatisfactions = <String, double>{};
    for (final entry in activitySatisfactions.entries) {
      if (entry.value.isNotEmpty) {
        avgSatisfactions[entry.key] =
            entry.value.reduce((a, b) => a + b) / entry.value.length;
      }
    }

    return {
      'activity_counts': activityCounts,
      'activity_durations':
          activityDurations.map((k, v) => MapEntry(k, v.inMinutes)),
      'avg_satisfactions': avgSatisfactions,
      'total_activities': patterns.length,
      'unique_activities': activityCounts.keys.length,
      'most_frequent_activity': activityCounts.entries
          .fold<MapEntry<String, int>?>(
              null,
              (prev, curr) =>
                  prev == null || curr.value > prev.value ? curr : prev)
          ?.key,
    };
  }

  /// 😊 기분 패턴 분석
  static Map<String, dynamic> _analyzeMoodPatterns(
      List<BehaviorPattern> patterns) {
    final explicitMoods =
        patterns.where((p) => p.mood != null).map((p) => p.mood!).toList();

    final satisfactionScores = patterns
        .where((p) => p.satisfactionScore != null)
        .map((p) => p.satisfactionScore!)
        .toList();

    // 명시적 기분 분포
    final moodCounts = <String, int>{};
    for (final mood in explicitMoods) {
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }

    // 만족도 통계
    double avgSatisfaction = 0.0;
    double satisfactionVariance = 0.0;

    if (satisfactionScores.isNotEmpty) {
      avgSatisfaction = satisfactionScores.reduce((a, b) => a + b) /
          satisfactionScores.length;

      if (satisfactionScores.length > 1) {
        final squaredDiffs = satisfactionScores
            .map((score) => pow(score - avgSatisfaction, 2))
            .toList();
        satisfactionVariance =
            squaredDiffs.reduce((a, b) => a + b) / satisfactionScores.length;
      }
    }

    return {
      'explicit_moods': moodCounts,
      'mood_entries_count': explicitMoods.length,
      'avg_satisfaction': avgSatisfaction,
      'satisfaction_variance': satisfactionVariance,
      'satisfaction_trend': _calculateSatisfactionTrend(patterns),
      'dominant_mood': moodCounts.entries
          .fold<MapEntry<String, int>?>(
              null,
              (prev, curr) =>
                  prev == null || curr.value > prev.value ? curr : prev)
          ?.key,
    };
  }

  /// ⏰ 시간 패턴 분석
  static Map<String, dynamic> _analyzeTimePatterns(
      List<BehaviorPattern> patterns) {
    final hourCounts = <int, int>{};
    final dayOfWeekCounts = <int, int>{};
    final sessionDurations = <Duration>[];

    for (final pattern in patterns) {
      final hour = pattern.timestamp.hour;
      final dayOfWeek = pattern.timestamp.weekday;

      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      dayOfWeekCounts[dayOfWeek] = (dayOfWeekCounts[dayOfWeek] ?? 0) + 1;
      sessionDurations.add(pattern.duration);
    }

    // 활동 시간대 분석
    String preferredTimeSlot = 'unknown';
    final morningCount = [6, 7, 8, 9, 10, 11]
        .fold(0, (sum, hour) => sum + (hourCounts[hour] ?? 0));
    final afternoonCount = [12, 13, 14, 15, 16, 17]
        .fold(0, (sum, hour) => sum + (hourCounts[hour] ?? 0));
    final eveningCount = [18, 19, 20, 21, 22, 23]
        .fold(0, (sum, hour) => sum + (hourCounts[hour] ?? 0));
    final nightCount = [0, 1, 2, 3, 4, 5]
        .fold(0, (sum, hour) => sum + (hourCounts[hour] ?? 0));

    final maxCount =
        [morningCount, afternoonCount, eveningCount, nightCount].fold(0, max);
    if (maxCount == morningCount) {
      preferredTimeSlot = 'morning';
    } else if (maxCount == afternoonCount)
      preferredTimeSlot = 'afternoon';
    else if (maxCount == eveningCount)
      preferredTimeSlot = 'evening';
    else if (maxCount == nightCount) preferredTimeSlot = 'night';

    // 세션 시간 통계
    double avgSessionMinutes = 0.0;
    if (sessionDurations.isNotEmpty) {
      avgSessionMinutes =
          sessionDurations.map((d) => d.inMinutes).reduce((a, b) => a + b) /
              sessionDurations.length;
    }

    return {
      'hour_distribution': hourCounts,
      'day_of_week_distribution': dayOfWeekCounts,
      'preferred_time_slot': preferredTimeSlot,
      'avg_session_minutes': avgSessionMinutes,
      'total_active_hours': hourCounts.keys.length,
      'most_active_hour': hourCounts.entries
          .fold<MapEntry<int, int>?>(
              null,
              (prev, curr) =>
                  prev == null || curr.value > prev.value ? curr : prev)
          ?.key,
      'most_active_day': dayOfWeekCounts.entries
          .fold<MapEntry<int, int>?>(
              null,
              (prev, curr) =>
                  prev == null || curr.value > prev.value ? curr : prev)
          ?.key,
    };
  }

  /// 📊 일관성 패턴 분석
  static Map<String, dynamic> _analyzeConsistencyPatterns(
      List<BehaviorPattern> patterns) {
    if (patterns.length < 2) {
      return {
        'consistency_score': 0.0,
        'activity_variety': 0.0,
        'temporal_regularity': 0.0,
        'engagement_stability': 0.0,
      };
    }

    // 활동 다양성 (Shannon entropy 기반)
    final activityCounts = <String, int>{};
    for (final pattern in patterns) {
      activityCounts[pattern.activityType] =
          (activityCounts[pattern.activityType] ?? 0) + 1;
    }

    double activityVariety = 0.0;
    final totalActivities = patterns.length;
    for (final count in activityCounts.values) {
      final probability = count / totalActivities;
      activityVariety -= probability * log(probability) / ln2;
    }
    activityVariety =
        activityVariety / log(activityCounts.keys.length) / ln2; // 정규화

    // 시간적 규칙성 (활동 간격의 일관성)
    final intervals = <Duration>[];
    for (int i = 1; i < patterns.length; i++) {
      intervals
          .add(patterns[i].timestamp.difference(patterns[i - 1].timestamp));
    }

    double temporalRegularity = 0.0;
    if (intervals.isNotEmpty) {
      final avgInterval =
          intervals.map((d) => d.inMinutes).reduce((a, b) => a + b) /
              intervals.length;

      final variance = intervals
              .map((d) => pow(d.inMinutes - avgInterval, 2))
              .reduce((a, b) => a + b) /
          intervals.length;

      temporalRegularity =
          1.0 / (1.0 + sqrt(variance) / avgInterval); // 변동 계수의 역수
    }

    // 참여도 안정성 (세션 시간의 일관성)
    final durations = patterns.map((p) => p.duration.inMinutes).toList();
    double engagementStability = 0.0;

    if (durations.length > 1) {
      final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
      final durationVariance = durations
              .map((d) => pow(d - avgDuration, 2))
              .reduce((a, b) => a + b) /
          durations.length;

      engagementStability = 1.0 / (1.0 + sqrt(durationVariance) / avgDuration);
    }

    // 전체 일관성 점수
    final consistencyScore =
        (activityVariety + temporalRegularity + engagementStability) / 3.0;

    return {
      'consistency_score': consistencyScore.clamp(0.0, 1.0),
      'activity_variety': activityVariety.clamp(0.0, 1.0),
      'temporal_regularity': temporalRegularity.clamp(0.0, 1.0),
      'engagement_stability': engagementStability.clamp(0.0, 1.0),
    };
  }

  /// 📈 만족도 트렌드 계산
  static String _calculateSatisfactionTrend(List<BehaviorPattern> patterns) {
    final satisfactionData = patterns
        .where((p) => p.satisfactionScore != null)
        .map((p) => {
              'timestamp': p.timestamp,
              'score': p.satisfactionScore!,
            })
        .toList()
      ..sort((a, b) =>
          (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime));

    if (satisfactionData.length < 3) return 'insufficient_data';

    // 선형 회귀로 트렌드 계산
    final n = satisfactionData.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble(); // 시간 인덱스
      final y = satisfactionData[i]['score'] as double;

      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

    if (slope > 0.1) return 'improving';
    if (slope < -0.1) return 'declining';
    return 'stable';
  }

  /// 🎯 행동 기반 감정 점수 계산
  static Map<EmotionType, double> _calculateEmotionScoresFromBehavior(
    Map<String, dynamic> activityAnalysis,
    Map<String, dynamic> moodAnalysis,
    Map<String, dynamic> timeAnalysis,
    Map<String, dynamic> consistencyAnalysis,
  ) {
    final scores = <EmotionType, double>{};

    // 모든 감정 타입 초기화
    for (final emotionType in EmotionType.values) {
      scores[emotionType] = 0.0;
    }

    // 활동 빈도와 다양성 기반 점수
    final totalActivities = activityAnalysis['total_activities'] as int;
    final uniqueActivities = activityAnalysis['unique_activities'] as int;
    final avgSatisfaction = moodAnalysis['avg_satisfaction'] as double;
    final consistencyScore = consistencyAnalysis['consistency_score'] as double;
    final satisfactionTrend = moodAnalysis['satisfaction_trend'] as String;

    // 활동량 기반 감정 추론
    if (totalActivities > 10) {
      // 활발한 활동
      scores[EmotionType.joy] = scores[EmotionType.joy]! + 2.0;
      scores[EmotionType.satisfaction] =
          scores[EmotionType.satisfaction]! + 1.5;
      scores[EmotionType.focused] = scores[EmotionType.focused]! + 1.0;
    } else if (totalActivities < 3) {
      // 저조한 활동
      scores[EmotionType.sadness] = scores[EmotionType.sadness]! + 1.5;
      scores[EmotionType.tired] = scores[EmotionType.tired]! + 2.0;
      scores[EmotionType.bored] = scores[EmotionType.bored]! + 1.0;
    }

    // 활동 다양성 기반 감정 추론
    if (uniqueActivities > 3) {
      // 다양한 활동
      scores[EmotionType.curious] = scores[EmotionType.curious]! + 1.5;
      scores[EmotionType.excitement] = scores[EmotionType.excitement]! + 1.0;
    } else if (uniqueActivities == 1) {
      // 단조로운 활동
      scores[EmotionType.bored] = scores[EmotionType.bored]! + 1.0;
      scores[EmotionType.focused] =
          scores[EmotionType.focused]! + 0.5; // 집중일 수도
    }

    // 만족도 기반 감정 추론
    if (avgSatisfaction > 4.0) {
      // 높은 만족도
      scores[EmotionType.joy] = scores[EmotionType.joy]! + 3.0;
      scores[EmotionType.satisfaction] =
          scores[EmotionType.satisfaction]! + 2.5;
      scores[EmotionType.pride] = scores[EmotionType.pride]! + 1.5;
    } else if (avgSatisfaction < 2.5) {
      // 낮은 만족도
      scores[EmotionType.disappointment] =
          scores[EmotionType.disappointment]! + 2.0;
      scores[EmotionType.frustration] = scores[EmotionType.frustration]! + 1.5;
      scores[EmotionType.sadness] = scores[EmotionType.sadness]! + 1.0;
    }

    // 만족도 트렌드 기반 감정 추론
    switch (satisfactionTrend) {
      case 'improving':
        scores[EmotionType.hope] = scores[EmotionType.hope]! + 2.0;
        scores[EmotionType.pride] = scores[EmotionType.pride]! + 1.5;
        scores[EmotionType.excitement] = scores[EmotionType.excitement]! + 1.0;
        break;
      case 'declining':
        scores[EmotionType.disappointment] =
            scores[EmotionType.disappointment]! + 2.0;
        scores[EmotionType.anxiety] = scores[EmotionType.anxiety]! + 1.5;
        scores[EmotionType.frustration] =
            scores[EmotionType.frustration]! + 1.0;
        break;
      case 'stable':
        scores[EmotionType.satisfaction] =
            scores[EmotionType.satisfaction]! + 1.0;
        scores[EmotionType.calm] = scores[EmotionType.calm]! + 1.5;
        break;
    }

    // 일관성 기반 감정 추론
    if (consistencyScore > 0.7) {
      // 높은 일관성
      scores[EmotionType.calm] = scores[EmotionType.calm]! + 1.5;
      scores[EmotionType.focused] = scores[EmotionType.focused]! + 1.0;
      scores[EmotionType.satisfaction] =
          scores[EmotionType.satisfaction]! + 0.5;
    } else if (consistencyScore < 0.3) {
      // 낮은 일관성
      scores[EmotionType.conflicted] = scores[EmotionType.conflicted]! + 1.5;
      scores[EmotionType.overwhelmed] = scores[EmotionType.overwhelmed]! + 1.0;
      scores[EmotionType.anxiety] = scores[EmotionType.anxiety]! + 0.5;
    }

    // 시간 패턴 기반 감정 추론
    final preferredTimeSlot = timeAnalysis['preferred_time_slot'] as String;
    switch (preferredTimeSlot) {
      case 'morning':
        scores[EmotionType.focused] = scores[EmotionType.focused]! + 1.0;
        scores[EmotionType.hope] = scores[EmotionType.hope]! + 0.5;
        break;
      case 'night':
        scores[EmotionType.tired] = scores[EmotionType.tired]! + 1.0;
        scores[EmotionType.calm] = scores[EmotionType.calm]! + 0.5;
        break;
    }

    // 명시적 기분 데이터 활용
    final dominantMood = moodAnalysis['dominant_mood'] as String?;
    if (dominantMood != null) {
      _applyExplicitMoodToScores(scores, dominantMood);
    }

    return scores;
  }

  /// 😊 명시적 기분 데이터를 점수에 반영
  static void _applyExplicitMoodToScores(
      Map<EmotionType, double> scores, String mood) {
    // Sherpa 앱의 기분 상태와 감정 타입 매핑
    switch (mood) {
      case 'very_happy':
        scores[EmotionType.joy] = scores[EmotionType.joy]! + 4.0;
        scores[EmotionType.excitement] = scores[EmotionType.excitement]! + 2.0;
        break;
      case 'happy':
        scores[EmotionType.joy] = scores[EmotionType.joy]! + 3.0;
        scores[EmotionType.satisfaction] =
            scores[EmotionType.satisfaction]! + 1.5;
        break;
      case 'good':
        scores[EmotionType.satisfaction] =
            scores[EmotionType.satisfaction]! + 2.5;
        scores[EmotionType.calm] = scores[EmotionType.calm]! + 1.0;
        break;
      case 'normal':
        scores[EmotionType.calm] = scores[EmotionType.calm]! + 2.0;
        break;
      case 'tired':
        scores[EmotionType.tired] = scores[EmotionType.tired]! + 3.0;
        scores[EmotionType.stress] = scores[EmotionType.stress]! + 1.0;
        break;
      case 'stressed':
        scores[EmotionType.stress] = scores[EmotionType.stress]! + 3.5;
        scores[EmotionType.anxiety] = scores[EmotionType.anxiety]! + 2.0;
        scores[EmotionType.overwhelmed] =
            scores[EmotionType.overwhelmed]! + 1.5;
        break;
    }
  }

  /// 🎯 행동 기반 주요 감정 선택
  static EmotionType _selectDominantEmotionFromBehavior(
      Map<EmotionType, double> scores) {
    final maxScore = scores.values.fold(0.0, (a, b) => a > b ? a : b);

    if (maxScore < 1.0) {
      return EmotionType.neutral; // 점수가 너무 낮으면 중립
    }

    final topEmotions = scores.entries
        .where((entry) => entry.value == maxScore)
        .map((entry) => entry.key)
        .toList();

    // 동점일 경우 카테고리 우선순위로 결정
    if (topEmotions.length > 1) {
      // 긍정 > 중립 > 부정 > 복합 순서로 우선순위
      final positiveEmotions = topEmotions
          .where((e) => e.category == EmotionCategory.positive)
          .toList();
      if (positiveEmotions.isNotEmpty) return positiveEmotions.first;

      final neutralEmotions = topEmotions
          .where((e) => e.category == EmotionCategory.neutral)
          .toList();
      if (neutralEmotions.isNotEmpty) return neutralEmotions.first;

      final negativeEmotions = topEmotions
          .where((e) => e.category == EmotionCategory.negative)
          .toList();
      if (negativeEmotions.isNotEmpty) return negativeEmotions.first;
    }

    return topEmotions.first;
  }

  /// 💪 행동 기반 강도 계산
  static EmotionIntensity _calculateIntensityFromBehavior(
    Map<EmotionType, double> emotionScores,
    Map<String, dynamic> activityAnalysis,
    Map<String, dynamic> consistencyAnalysis,
  ) {
    final maxScore = emotionScores.values.fold(0.0, (a, b) => a > b ? a : b);
    final totalActivities = activityAnalysis['total_activities'] as int;
    final consistencyScore = consistencyAnalysis['consistency_score'] as double;

    // 기본 강도 (최대 점수 기반)
    double intensity = (maxScore / 10.0).clamp(0.0, 1.0);

    // 활동량 보정 (활동이 많을수록 강도 증가)
    if (totalActivities > 15) {
      intensity += 0.3;
    } else if (totalActivities > 8) {
      intensity += 0.1;
    }

    // 일관성 보정 (극단적인 일관성은 강도 증가)
    if (consistencyScore > 0.8 || consistencyScore < 0.2) {
      intensity += 0.2;
    }

    return EmotionIntensity.fromValue(intensity.clamp(0.0, 1.0));
  }

  /// 📈 행동 기반 신뢰도 계산
  static EmotionConfidence _calculateConfidenceFromBehavior(
    int patternCount,
    Map<EmotionType, double> emotionScores,
    Map<String, dynamic> consistencyAnalysis,
  ) {
    final maxScore = emotionScores.values.fold(0.0, (a, b) => a > b ? a : b);
    final totalScore = emotionScores.values.fold(0.0, (a, b) => a + b);
    final consistencyScore = consistencyAnalysis['consistency_score'] as double;

    // 기본 신뢰도 (점수 집중도)
    double confidence = totalScore > 0 ? maxScore / totalScore : 0.0;

    // 데이터량 보정 (더 많은 패턴일수록 신뢰도 증가)
    final dataBonus = (patternCount / 20.0).clamp(0.0, 0.3);
    confidence += dataBonus;

    // 일관성 보정 (일관성이 높을수록 신뢰도 증가)
    confidence += consistencyScore * 0.2;

    // 점수 강도 보정 (강한 신호일수록 신뢰도 증가)
    if (maxScore > 5.0) {
      confidence += 0.2;
    } else if (maxScore > 3.0) {
      confidence += 0.1;
    }

    return EmotionConfidence.fromValue(confidence.clamp(0.0, 1.0));
  }

  /// 📊 행동 패턴 요약 분석
  static Map<String, dynamic> getBehaviorAnalysisSummary(
      List<BehaviorPattern> patterns) {
    final snapshot = analyzeBehaviorPatterns(patterns);

    if (snapshot == null) {
      return {
        'status': 'insufficient_data',
        'patterns_count': patterns.length,
        'minimum_required': _minimumPatternsRequired,
      };
    }

    return {
      'status': 'success',
      'emotion_analysis': {
        'type': snapshot.type.id,
        'display_name': snapshot.type.displayName,
        'category': snapshot.type.category.id,
        'intensity': snapshot.intensity.id,
        'confidence': snapshot.confidence.id,
        'emoji': snapshot.type.emoji,
      },
      'behavior_insights': snapshot.context,
      'analysis_metadata': {
        'patterns_analyzed': patterns.length,
        'analysis_window': _analysisWindowDays,
        'timestamp': snapshot.timestamp.toIso8601String(),
      },
    };
  }
}
