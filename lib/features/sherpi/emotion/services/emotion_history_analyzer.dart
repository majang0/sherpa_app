// 📈 감정 상태 히스토리 및 트렌드 분석 시스템
//
// 사용자의 감정 변화 패턴을 추적하고 트렌드를 분석하여
// 장기적인 감정 건강 관리를 지원하는 시스템

import 'dart:math';
import '../models/emotion_state_model.dart';

/// 📊 감정 트렌드 분석 결과
class EmotionTrendAnalysis {
  final String trendId;
  final DateTime analysisDate;
  final Duration analyzedPeriod;
  final List<EmotionSnapshot> rawData;
  final EmotionStats overallStats;
  final Map<String, dynamic> trendIndicators;
  final List<EmotionPattern> identifiedPatterns;
  final Map<String, dynamic> insights;
  final List<String> recommendations;
  final double emotionalWellbeingScore; // 0.0 ~ 1.0

  const EmotionTrendAnalysis({
    required this.trendId,
    required this.analysisDate,
    required this.analyzedPeriod,
    required this.rawData,
    required this.overallStats,
    required this.trendIndicators,
    required this.identifiedPatterns,
    required this.insights,
    required this.recommendations,
    required this.emotionalWellbeingScore,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'trendId': trendId,
      'analysisDate': analysisDate.toIso8601String(),
      'analyzedPeriodDays': analyzedPeriod.inDays,
      'rawDataCount': rawData.length,
      'overallStats': overallStats.toJson(),
      'trendIndicators': trendIndicators,
      'identifiedPatterns': identifiedPatterns.map((p) => p.toJson()).toList(),
      'insights': insights,
      'recommendations': recommendations,
      'emotionalWellbeingScore': emotionalWellbeingScore,
    };
  }

  /// 전반적인 감정 건강 상태
  String get wellbeingLevel {
    if (emotionalWellbeingScore >= 0.8) return 'excellent';
    if (emotionalWellbeingScore >= 0.7) return 'good';
    if (emotionalWellbeingScore >= 0.6) return 'fair';
    if (emotionalWellbeingScore >= 0.4) return 'concerning';
    return 'needs_attention';
  }

  /// 주요 트렌드 요약
  String get trendSummary {
    final direction = trendIndicators['overall_direction'] as String;
    final stability = trendIndicators['stability_trend'] as String;

    switch (direction) {
      case 'improving':
        return '감정 상태가 전반적으로 개선되고 있습니다 📈';
      case 'declining':
        return '감정 상태에 주의가 필요합니다 📉';
      case 'stable':
        return stability == 'stable'
            ? '안정적인 감정 상태를 유지하고 있습니다 📊'
            : '감정 기복이 있지만 전반적으로는 안정적입니다 🌊';
      default:
        return '감정 패턴을 분석 중입니다 🔍';
    }
  }
}

/// 🔍 감정 패턴
class EmotionPattern {
  final String patternId;
  final String patternType; // 'daily', 'weekly', 'trigger-based', 'cyclical'
  final String description;
  final List<EmotionSnapshot> supportingData;
  final double confidence; // 패턴의 신뢰도
  final Map<String, dynamic> patternDetails;
  final DateTime firstObserved;
  final DateTime lastObserved;
  final int occurrenceCount;

  const EmotionPattern({
    required this.patternId,
    required this.patternType,
    required this.description,
    required this.supportingData,
    required this.confidence,
    required this.patternDetails,
    required this.firstObserved,
    required this.lastObserved,
    required this.occurrenceCount,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'patternId': patternId,
      'patternType': patternType,
      'description': description,
      'supportingDataCount': supportingData.length,
      'confidence': confidence,
      'patternDetails': patternDetails,
      'firstObserved': firstObserved.toIso8601String(),
      'lastObserved': lastObserved.toIso8601String(),
      'occurrenceCount': occurrenceCount,
    };
  }

  /// 패턴의 유의성 (높을수록 중요)
  double get significance {
    return (confidence * 0.6) + (min(occurrenceCount / 10.0, 1.0) * 0.4);
  }

  /// 패턴이 현재도 유효한지
  bool get isCurrentlyActive {
    final daysSinceLastObservation =
        DateTime.now().difference(lastObserved).inDays;

    switch (patternType) {
      case 'daily':
        return daysSinceLastObservation <= 2;
      case 'weekly':
        return daysSinceLastObservation <= 10;
      default:
        return daysSinceLastObservation <= 7;
    }
  }
}

/// 📈 감정 히스토리 분석기
class EmotionHistoryAnalyzer {
  static const int _minimumDataPoints = 10;
  static const int _defaultAnalysisDays = 30;
  static const double _trendSignificanceThreshold = 0.15;
  static const double _patternConfidenceThreshold = 0.6;

  /// 🎯 메인 트렌드 분석 함수
  ///
  /// 감정 히스토리를 종합적으로 분석하여 트렌드와 패턴을 도출
  static EmotionTrendAnalysis? analyzeTrends(
    List<EmotionSnapshot> emotionHistory, {
    int analysisDays = _defaultAnalysisDays,
    DateTime? analysisDate,
  }) {
    if (emotionHistory.length < _minimumDataPoints) {
      return null; // 분석하기에 데이터가 부족
    }

    final endDate = analysisDate ?? DateTime.now();
    final startDate = endDate.subtract(Duration(days: analysisDays));

    // 분석 기간 내 데이터 필터링
    final relevantData = emotionHistory
        .where((snapshot) =>
            snapshot.timestamp.isAfter(startDate) &&
            snapshot.timestamp.isBefore(endDate))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (relevantData.length < _minimumDataPoints) {
      return null;
    }

    // 기본 통계 계산
    final history = EmotionHistory(
      snapshots: relevantData,
      startTime: startDate,
      endTime: endDate,
    );
    final overallStats = history.calculateStats();

    // 트렌드 지표 분석
    final trendIndicators = _analyzeTrendIndicators(relevantData);

    // 패턴 식별
    final patterns = _identifyPatterns(relevantData);

    // 인사이트 생성
    final insights = _generateInsights(
        relevantData, overallStats, trendIndicators, patterns);

    // 추천사항 생성
    final recommendations =
        _generateRecommendations(overallStats, trendIndicators, patterns);

    // 감정 웰빙 점수 계산
    final wellbeingScore =
        _calculateWellbeingScore(overallStats, trendIndicators, patterns);

    return EmotionTrendAnalysis(
      trendId: 'trend_${DateTime.now().millisecondsSinceEpoch}',
      analysisDate: endDate,
      analyzedPeriod: Duration(days: analysisDays),
      rawData: relevantData,
      overallStats: overallStats,
      trendIndicators: trendIndicators,
      identifiedPatterns: patterns,
      insights: insights,
      recommendations: recommendations,
      emotionalWellbeingScore: wellbeingScore,
    );
  }

  /// 📊 트렌드 지표 분석
  static Map<String, dynamic> _analyzeTrendIndicators(
      List<EmotionSnapshot> data) {
    if (data.length < 3) {
      return {
        'overall_direction': 'insufficient_data',
        'valence_trend': 0.0,
        'intensity_trend': 0.0,
        'stability_trend': 'unknown',
        'confidence_trend': 0.0,
      };
    }

    // 시간순 정렬 확인
    data.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 감정가 트렌드 (선형 회귀)
    final valenceTrend = _calculateLinearTrend(
      data.map((s) => s.type.valence).toList(),
    );

    // 강도 트렌드
    final intensityTrend = _calculateLinearTrend(
      data.map((s) => s.intensity.value).toList(),
    );

    // 신뢰도 트렌드
    final confidenceTrend = _calculateLinearTrend(
      data.map((s) => s.confidence.value).toList(),
    );

    // 안정성 트렌드 (이동 평균의 분산 변화)
    final stabilityTrend = _analyzeStabilityTrend(data);

    // 전반적 방향성 결정
    String overallDirection = 'stable';
    if (valenceTrend.abs() > _trendSignificanceThreshold) {
      overallDirection = valenceTrend > 0 ? 'improving' : 'declining';
    }

    // 감정 다양성 변화
    final diversityTrend = _analyzeDiversityTrend(data);

    // 극값 발생 빈도
    final extremeEmotionFrequency = _analyzeExtremeEmotions(data);

    return {
      'overall_direction': overallDirection,
      'valence_trend': valenceTrend,
      'intensity_trend': intensityTrend,
      'stability_trend': stabilityTrend,
      'confidence_trend': confidenceTrend,
      'diversity_trend': diversityTrend,
      'extreme_emotion_frequency': extremeEmotionFrequency,
      'trend_strength': valenceTrend.abs(),
      'is_significant_trend': valenceTrend.abs() > _trendSignificanceThreshold,
    };
  }

  /// 📈 선형 트렌드 계산 (기울기)
  static double _calculateLinearTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    final n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = values[i];

      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    if (n * sumX2 - sumX * sumX == 0) return 0.0;

    return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  }

  /// 🌊 안정성 트렌드 분석
  static String _analyzeStabilityTrend(List<EmotionSnapshot> data) {
    if (data.length < 6) return 'insufficient_data';

    // 전반부와 후반부의 분산 비교
    final midPoint = data.length ~/ 2;
    final firstHalf = data.take(midPoint).toList();
    final secondHalf = data.skip(midPoint).toList();

    final firstHalfVariance = _calculateValenceVariance(firstHalf);
    final secondHalfVariance = _calculateValenceVariance(secondHalf);

    final varianceRatio =
        secondHalfVariance / (firstHalfVariance + 0.01); // 0으로 나누기 방지

    if (varianceRatio > 1.3) return 'becoming_unstable';
    if (varianceRatio < 0.7) return 'becoming_stable';
    return 'stable';
  }

  /// 📊 감정가 분산 계산
  static double _calculateValenceVariance(List<EmotionSnapshot> snapshots) {
    if (snapshots.isEmpty) return 0.0;

    final valences = snapshots.map((s) => s.type.valence).toList();
    final mean = valences.reduce((a, b) => a + b) / valences.length;

    final sumSquaredDiffs =
        valences.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b);

    return sumSquaredDiffs / valences.length;
  }

  /// 🌈 감정 다양성 트렌드 분석
  static String _analyzeDiversityTrend(List<EmotionSnapshot> data) {
    if (data.length < 10) return 'insufficient_data';

    final midPoint = data.length ~/ 2;
    final firstHalf = data.take(midPoint).toList();
    final secondHalf = data.skip(midPoint).toList();

    final firstHalfDiversity = _calculateEmotionDiversity(firstHalf);
    final secondHalfDiversity = _calculateEmotionDiversity(secondHalf);

    final diversityRatio = secondHalfDiversity / (firstHalfDiversity + 0.01);

    if (diversityRatio > 1.2) return 'increasing_diversity';
    if (diversityRatio < 0.8) return 'decreasing_diversity';
    return 'stable_diversity';
  }

  /// 🌈 감정 다양성 계산 (Shannon Entropy)
  static double _calculateEmotionDiversity(List<EmotionSnapshot> snapshots) {
    if (snapshots.isEmpty) return 0.0;

    final emotionCounts = <EmotionType, int>{};
    for (final snapshot in snapshots) {
      emotionCounts[snapshot.type] = (emotionCounts[snapshot.type] ?? 0) + 1;
    }

    final total = snapshots.length;
    double entropy = 0.0;

    for (final count in emotionCounts.values) {
      final probability = count / total;
      entropy -= probability * log(probability) / ln2;
    }

    return entropy;
  }

  /// ⚡ 극값 감정 분석
  static Map<String, dynamic> _analyzeExtremeEmotions(
      List<EmotionSnapshot> data) {
    int extremePositiveCount = 0;
    int extremeNegativeCount = 0;
    int highIntensityCount = 0;

    for (final snapshot in data) {
      if (snapshot.type.valence > 0.7) extremePositiveCount++;
      if (snapshot.type.valence < -0.7) extremeNegativeCount++;
      if (snapshot.intensity.value > 0.8) highIntensityCount++;
    }

    final total = data.length;

    return {
      'extreme_positive_rate': extremePositiveCount / total,
      'extreme_negative_rate': extremeNegativeCount / total,
      'high_intensity_rate': highIntensityCount / total,
      'extreme_emotion_balance':
          (extremePositiveCount - extremeNegativeCount) / total,
    };
  }

  /// 🔍 패턴 식별
  static List<EmotionPattern> _identifyPatterns(List<EmotionSnapshot> data) {
    final patterns = <EmotionPattern>[];

    // 일일 패턴 분석
    patterns.addAll(_identifyDailyPatterns(data));

    // 주간 패턴 분석
    patterns.addAll(_identifyWeeklyPatterns(data));

    // 트리거 기반 패턴 분석
    patterns.addAll(_identifyTriggerPatterns(data));

    // 주기적 패턴 분석
    patterns.addAll(_identifyCyclicalPatterns(data));

    // 신뢰도 기준으로 필터링
    return patterns
        .where((pattern) => pattern.confidence >= _patternConfidenceThreshold)
        .toList()
      ..sort((a, b) => b.significance.compareTo(a.significance));
  }

  /// 📅 일일 패턴 식별
  static List<EmotionPattern> _identifyDailyPatterns(
      List<EmotionSnapshot> data) {
    final patterns = <EmotionPattern>[];

    // 시간대별 감정 분포
    final hourlyEmotions = <int, List<EmotionSnapshot>>{};
    for (final snapshot in data) {
      final hour = snapshot.timestamp.hour;
      hourlyEmotions[hour] = (hourlyEmotions[hour] ?? [])..add(snapshot);
    }

    // 아침/오후/저녁/밤 패턴 분석
    final timeSlots = {
      'morning': [6, 7, 8, 9, 10, 11],
      'afternoon': [12, 13, 14, 15, 16, 17],
      'evening': [18, 19, 20, 21, 22],
      'night': [23, 0, 1, 2, 3, 4, 5],
    };

    for (final entry in timeSlots.entries) {
      final slotName = entry.key;
      final hours = entry.value;

      final slotEmotions = hours
          .expand((hour) => hourlyEmotions[hour] ?? <EmotionSnapshot>[])
          .toList();

      if (slotEmotions.length >= 5) {
        final dominantEmotion = _findDominantEmotion(slotEmotions);
        final avgValence =
            slotEmotions.map((s) => s.type.valence).reduce((a, b) => a + b) /
                slotEmotions.length;

        // 패턴 신뢰도 계산
        final confidence =
            _calculatePatternConfidence(slotEmotions, dominantEmotion);

        if (confidence >= _patternConfidenceThreshold) {
          patterns.add(EmotionPattern(
            patternId: 'daily_${slotName}_${dominantEmotion.id}',
            patternType: 'daily',
            description:
                '$slotName 시간대에 주로 ${dominantEmotion.displayName} 감정을 경험',
            supportingData: slotEmotions,
            confidence: confidence,
            patternDetails: {
              'time_slot': slotName,
              'dominant_emotion': dominantEmotion.id,
              'average_valence': avgValence,
              'hours': hours,
            },
            firstObserved: slotEmotions.first.timestamp,
            lastObserved: slotEmotions.last.timestamp,
            occurrenceCount: slotEmotions.length,
          ));
        }
      }
    }

    return patterns;
  }

  /// 📅 주간 패턴 식별
  static List<EmotionPattern> _identifyWeeklyPatterns(
      List<EmotionSnapshot> data) {
    final patterns = <EmotionPattern>[];

    // 요일별 감정 분포
    final weekdayEmotions = <int, List<EmotionSnapshot>>{};
    for (final snapshot in data) {
      final weekday = snapshot.timestamp.weekday; // 1=월요일, 7=일요일
      weekdayEmotions[weekday] = (weekdayEmotions[weekday] ?? [])
        ..add(snapshot);
    }

    final weekdayNames = {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };

    for (final entry in weekdayEmotions.entries) {
      final weekday = entry.key;
      final emotions = entry.value;

      if (emotions.length >= 3) {
        final dominantEmotion = _findDominantEmotion(emotions);
        final avgValence =
            emotions.map((s) => s.type.valence).reduce((a, b) => a + b) /
                emotions.length;

        final confidence =
            _calculatePatternConfidence(emotions, dominantEmotion);

        if (confidence >= _patternConfidenceThreshold) {
          patterns.add(EmotionPattern(
            patternId: 'weekly_${weekdayNames[weekday]}_${dominantEmotion.id}',
            patternType: 'weekly',
            description:
                '${weekdayNames[weekday]}에 주로 ${dominantEmotion.displayName} 감정을 경험',
            supportingData: emotions,
            confidence: confidence,
            patternDetails: {
              'weekday': weekday,
              'weekday_name': weekdayNames[weekday],
              'dominant_emotion': dominantEmotion.id,
              'average_valence': avgValence,
            },
            firstObserved: emotions.first.timestamp,
            lastObserved: emotions.last.timestamp,
            occurrenceCount: emotions.length,
          ));
        }
      }
    }

    return patterns;
  }

  /// 🎯 트리거 기반 패턴 식별
  static List<EmotionPattern> _identifyTriggerPatterns(
      List<EmotionSnapshot> data) {
    final patterns = <EmotionPattern>[];

    // 트리거별 감정 그룹화
    final triggerGroups = <String, List<EmotionSnapshot>>{};
    for (final snapshot in data) {
      final trigger = snapshot.trigger ?? 'unknown';
      if (trigger != 'unknown' && trigger.isNotEmpty) {
        triggerGroups[trigger] = (triggerGroups[trigger] ?? [])..add(snapshot);
      }
    }

    for (final entry in triggerGroups.entries) {
      final trigger = entry.key;
      final emotions = entry.value;

      if (emotions.length >= 3) {
        final dominantEmotion = _findDominantEmotion(emotions);
        final confidence =
            _calculatePatternConfidence(emotions, dominantEmotion);

        if (confidence >= _patternConfidenceThreshold) {
          patterns.add(EmotionPattern(
            patternId: 'trigger_${trigger.hashCode}_${dominantEmotion.id}',
            patternType: 'trigger-based',
            description:
                '$trigger 상황에서 주로 ${dominantEmotion.displayName} 감정을 경험',
            supportingData: emotions,
            confidence: confidence,
            patternDetails: {
              'trigger': trigger,
              'dominant_emotion': dominantEmotion.id,
              'trigger_frequency': emotions.length,
            },
            firstObserved: emotions.first.timestamp,
            lastObserved: emotions.last.timestamp,
            occurrenceCount: emotions.length,
          ));
        }
      }
    }

    return patterns;
  }

  /// 🔄 주기적 패턴 식별 (간단한 구현)
  static List<EmotionPattern> _identifyCyclicalPatterns(
      List<EmotionSnapshot> data) {
    final patterns = <EmotionPattern>[];

    // 감정가의 주기성 분석 (매우 기본적인 구현)
    if (data.length >= 14) {
      final valences = data.map((s) => s.type.valence).toList();

      // 7일 주기 패턴 확인
      final weeklyCorrelation = _calculatePeriodCorrelation(valences, 7);
      if (weeklyCorrelation > 0.3) {
        patterns.add(EmotionPattern(
          patternId: 'cyclical_weekly_valence',
          patternType: 'cyclical',
          description: '감정 상태가 약 7일 주기로 반복되는 패턴',
          supportingData: data,
          confidence: weeklyCorrelation,
          patternDetails: {
            'period': 7,
            'correlation': weeklyCorrelation,
            'pattern_type': 'valence_cycle',
          },
          firstObserved: data.first.timestamp,
          lastObserved: data.last.timestamp,
          occurrenceCount: data.length ~/ 7,
        ));
      }
    }

    return patterns;
  }

  /// 📊 주기 상관관계 계산
  static double _calculatePeriodCorrelation(List<double> values, int period) {
    if (values.length < period * 2) return 0.0;

    final firstCycle = values.take(period).toList();
    final secondCycle = values.skip(period).take(period).toList();

    if (firstCycle.length != secondCycle.length) return 0.0;

    // 피어슨 상관계수 계산
    final n = firstCycle.length;
    final mean1 = firstCycle.reduce((a, b) => a + b) / n;
    final mean2 = secondCycle.reduce((a, b) => a + b) / n;

    double numerator = 0.0;
    double sum1 = 0.0;
    double sum2 = 0.0;

    for (int i = 0; i < n; i++) {
      final diff1 = firstCycle[i] - mean1;
      final diff2 = secondCycle[i] - mean2;

      numerator += diff1 * diff2;
      sum1 += diff1 * diff1;
      sum2 += diff2 * diff2;
    }

    final denominator = sqrt(sum1 * sum2);
    if (denominator == 0) return 0.0;

    return (numerator / denominator).abs();
  }

  /// 🎯 주요 감정 찾기
  static EmotionType _findDominantEmotion(List<EmotionSnapshot> snapshots) {
    final emotionCounts = <EmotionType, int>{};

    for (final snapshot in snapshots) {
      emotionCounts[snapshot.type] = (emotionCounts[snapshot.type] ?? 0) + 1;
    }

    return emotionCounts.entries
        .fold<MapEntry<EmotionType, int>?>(
            null,
            (prev, curr) =>
                prev == null || curr.value > prev.value ? curr : prev)!
        .key;
  }

  /// 📈 패턴 신뢰도 계산
  static double _calculatePatternConfidence(
    List<EmotionSnapshot> snapshots,
    EmotionType dominantEmotion,
  ) {
    if (snapshots.isEmpty) return 0.0;

    final dominantCount =
        snapshots.where((s) => s.type == dominantEmotion).length;

    final dominanceRatio = dominantCount / snapshots.length;

    // 신뢰도 계산: 지배적 비율 + 데이터 품질 보너스
    double confidence = dominanceRatio;

    // 충분한 데이터가 있으면 보너스
    if (snapshots.length >= 5) confidence += 0.1;
    if (snapshots.length >= 10) confidence += 0.1;

    // 높은 신뢰도의 스냅샷이 많으면 보너스
    final avgConfidence =
        snapshots.map((s) => s.confidence.value).reduce((a, b) => a + b) /
            snapshots.length;

    confidence += avgConfidence * 0.2;

    return confidence.clamp(0.0, 1.0);
  }

  /// 💡 인사이트 생성
  static Map<String, dynamic> _generateInsights(
    List<EmotionSnapshot> data,
    EmotionStats stats,
    Map<String, dynamic> trends,
    List<EmotionPattern> patterns,
  ) {
    final insights = <String, dynamic>{};

    // 전반적인 감정 상태 인사이트
    insights['overall_mood'] = {
      'category': stats.overallMood.displayName,
      'description':
          _getMoodDescription(stats.overallMood, stats.averageValence),
      'stability': stats.emotionalStability,
    };

    // 트렌드 인사이트
    final trendDirection = trends['overall_direction'] as String;
    insights['trend_insight'] = {
      'direction': trendDirection,
      'description': _getTrendDescription(trendDirection, trends),
      'strength': trends['trend_strength'],
    };

    // 패턴 인사이트
    insights['pattern_insights'] = patterns
        .take(3)
        .map((pattern) => {
              'type': pattern.patternType,
              'description': pattern.description,
              'significance': pattern.significance,
              'is_active': pattern.isCurrentlyActive,
            })
        .toList();

    // 감정 다양성 인사이트
    insights['diversity_insight'] = {
      'emotion_variety': stats.typeDistribution.keys.length,
      'dominant_category': stats.overallMood.displayName,
      'balance_score': _calculateEmotionBalance(stats),
    };

    // 강도 인사이트
    insights['intensity_insight'] = {
      'average_intensity': stats.averageIntensity,
      'intensity_level': _getIntensityLevel(stats.averageIntensity),
      'extreme_emotions': trends['extreme_emotion_frequency'],
    };

    return insights;
  }

  /// 😊 기분 설명 생성
  static String _getMoodDescription(EmotionCategory mood, double avgValence) {
    switch (mood) {
      case EmotionCategory.positive:
        if (avgValence > 0.5) {
          return '매우 긍정적이고 활기찬 감정 상태를 유지하고 있습니다';
        } else {
          return '전반적으로 긍정적인 마음가짐을 보이고 있습니다';
        }
      case EmotionCategory.negative:
        if (avgValence < -0.5) {
          return '힘든 감정들을 많이 경험하고 있어 관심과 관리가 필요합니다';
        } else {
          return '약간의 부정적 감정들이 있지만 관리 가능한 수준입니다';
        }
      case EmotionCategory.neutral:
        return '안정적이고 균형잡힌 감정 상태를 유지하고 있습니다';
      default:
        return '다양한 감정들을 경험하며 복합적인 상태입니다';
    }
  }

  /// 📈 트렌드 설명 생성
  static String _getTrendDescription(
      String direction, Map<String, dynamic> trends) {
    final strength = trends['trend_strength'] as double;

    switch (direction) {
      case 'improving':
        return strength > 0.3
            ? '감정 상태가 뚜렷하게 개선되고 있습니다'
            : '감정 상태가 조금씩 나아지고 있습니다';
      case 'declining':
        return strength > 0.3
            ? '감정 상태가 우려스러운 수준으로 악화되고 있습니다'
            : '감정 상태에 약간의 주의가 필요합니다';
      case 'stable':
        return '일정한 수준의 감정 상태를 유지하고 있습니다';
      default:
        return '감정 변화 패턴이 불분명합니다';
    }
  }

  /// ⚖️ 감정 균형 점수 계산
  static double _calculateEmotionBalance(EmotionStats stats) {
    final positiveRatio =
        (stats.categoryDistribution[EmotionCategory.positive] ?? 0) /
            stats.totalSnapshots;
    final negativeRatio =
        (stats.categoryDistribution[EmotionCategory.negative] ?? 0) /
            stats.totalSnapshots;

    // 균형점은 60% 긍정, 40% 기타가 이상적
    const idealPositiveRatio = 0.6;
    const idealNegativeRatio = 0.25;

    final positiveBalance = 1.0 - (positiveRatio - idealPositiveRatio).abs();
    final negativeBalance = 1.0 - (negativeRatio - idealNegativeRatio).abs();

    return ((positiveBalance + negativeBalance) / 2.0).clamp(0.0, 1.0);
  }

  /// 💪 강도 레벨 설명
  static String _getIntensityLevel(double avgIntensity) {
    if (avgIntensity > 0.8) return 'very_high';
    if (avgIntensity > 0.6) return 'high';
    if (avgIntensity > 0.4) return 'moderate';
    if (avgIntensity > 0.2) return 'low';
    return 'very_low';
  }

  /// 💡 추천사항 생성
  static List<String> _generateRecommendations(
    EmotionStats stats,
    Map<String, dynamic> trends,
    List<EmotionPattern> patterns,
  ) {
    final recommendations = <String>[];

    // 트렌드 기반 추천
    final trendDirection = trends['overall_direction'] as String;
    switch (trendDirection) {
      case 'declining':
        recommendations.add('감정 상태 개선을 위해 규칙적인 운동이나 명상을 시도해보세요');
        recommendations.add('스트레스 요인을 파악하고 관리 방법을 찾아보세요');
        break;
      case 'improving':
        recommendations.add('현재의 긍정적인 변화를 유지할 수 있는 활동들을 계속해보세요');
        break;
    }

    // 감정 균형 기반 추천
    final emotionBalance = _calculateEmotionBalance(stats);
    if (emotionBalance < 0.6) {
      recommendations.add('다양한 활동을 통해 감정의 균형을 맞춰보세요');
    }

    // 안정성 기반 추천
    if (stats.emotionalStability < 0.5) {
      recommendations.add('일정한 루틴을 만들어 감정의 안정성을 높여보세요');
      recommendations.add('갑작스러운 감정 변화의 원인을 일기로 기록해보세요');
    }

    // 패턴 기반 추천
    for (final pattern in patterns.take(2)) {
      if (pattern.patternType == 'trigger-based') {
        recommendations
            .add('${pattern.patternDetails['trigger']} 상황에서의 대처 방법을 미리 준비해보세요');
      } else if (pattern.patternType == 'daily') {
        final timeSlot = pattern.patternDetails['time_slot'] as String;
        recommendations.add('$timeSlot 시간대의 감정 패턴을 활용한 활동 계획을 세워보세요');
      }
    }

    // 강도 기반 추천
    if (stats.averageIntensity > 0.8) {
      recommendations.add('감정 강도가 높으니 이완 기법이나 호흡법을 연습해보세요');
    } else if (stats.averageIntensity < 0.3) {
      recommendations.add('활력을 높일 수 있는 새로운 도전이나 목표를 설정해보세요');
    }

    return recommendations.take(5).toList(); // 최대 5개 추천
  }

  /// 🌟 웰빙 점수 계산
  static double _calculateWellbeingScore(
    EmotionStats stats,
    Map<String, dynamic> trends,
    List<EmotionPattern> patterns,
  ) {
    double score = 0.0;

    // 감정가 점수 (40% 가중치)
    final valenceScore = (stats.averageValence + 1.0) / 2.0; // -1~1을 0~1로 변환
    score += valenceScore * 0.4;

    // 안정성 점수 (25% 가중치)
    score += stats.emotionalStability * 0.25;

    // 트렌드 점수 (20% 가중치)
    final trendDirection = trends['overall_direction'] as String;
    double trendScore = 0.5; // 기본값
    switch (trendDirection) {
      case 'improving':
        trendScore = 0.8;
        break;
      case 'declining':
        trendScore = 0.2;
        break;
      case 'stable':
        trendScore = 0.6;
        break;
    }
    score += trendScore * 0.2;

    // 균형 점수 (15% 가중치)
    final balanceScore = _calculateEmotionBalance(stats);
    score += balanceScore * 0.15;

    return score.clamp(0.0, 1.0);
  }

  /// 📊 요약 분석 (간단한 버전)
  static Map<String, dynamic> getQuickAnalysisSummary(
      List<EmotionSnapshot> data) {
    final analysis = analyzeTrends(data, analysisDays: 7);

    if (analysis == null) {
      return {
        'status': 'insufficient_data',
        'data_points': data.length,
        'minimum_required': _minimumDataPoints,
      };
    }

    return {
      'status': 'success',
      'wellbeing_score': analysis.emotionalWellbeingScore,
      'wellbeing_level': analysis.wellbeingLevel,
      'trend_summary': analysis.trendSummary,
      'dominant_emotion': analysis.overallStats.dominantEmotion.displayName,
      'emotion_stability': analysis.overallStats.emotionalStability,
      'key_patterns': analysis.identifiedPatterns
          .take(2)
          .map((p) => {
                'type': p.patternType,
                'description': p.description,
                'confidence': p.confidence,
              })
          .toList(),
      'top_recommendations': analysis.recommendations.take(3),
      'analysis_date': analysis.analysisDate.toIso8601String(),
    };
  }
}
