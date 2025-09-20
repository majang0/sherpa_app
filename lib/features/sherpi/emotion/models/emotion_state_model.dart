// 🎭 사용자 감정 상태 모델
//
// 사용자의 감정 상태를 종합적으로 추적하고 분석하기 위한 데이터 모델

import 'package:flutter/foundation.dart';

/// 📊 감정 상태 분류 시스템
enum EmotionCategory {
  /// 😊 긍정적 감정들
  positive('positive', '긍정', '😊'),

  /// 😢 부정적 감정들
  negative('negative', '부정', '😢'),

  /// 😐 중립적 감정들
  neutral('neutral', '중립', '😐'),

  /// 🤔 복합적/혼재된 감정들
  mixed('mixed', '복합', '🤔'),

  /// ❓ 불분명한 상태
  unknown('unknown', '불분명', '❓');

  const EmotionCategory(this.id, this.displayName, this.emoji);

  final String id;
  final String displayName;
  final String emoji;
}

/// 🎯 구체적 감정 타입 (세분화된 감정 분류)
enum EmotionType {
  // 긍정적 감정들
  joy('joy', '기쁨', EmotionCategory.positive, 0.8, '🥳'),
  excitement('excitement', '흥분', EmotionCategory.positive, 0.9, '🤩'),
  satisfaction('satisfaction', '만족', EmotionCategory.positive, 0.7, '😌'),
  pride('pride', '자부심', EmotionCategory.positive, 0.8, '😎'),
  gratitude('gratitude', '감사', EmotionCategory.positive, 0.6, '🙏'),
  hope('hope', '희망', EmotionCategory.positive, 0.7, '✨'),
  love('love', '애정', EmotionCategory.positive, 0.8, '💖'),

  // 부정적 감정들
  sadness('sadness', '슬픔', EmotionCategory.negative, -0.7, '😢'),
  anger('anger', '분노', EmotionCategory.negative, -0.9, '😠'),
  frustration('frustration', '좌절', EmotionCategory.negative, -0.8, '😤'),
  anxiety('anxiety', '불안', EmotionCategory.negative, -0.6, '😰'),
  disappointment('disappointment', '실망', EmotionCategory.negative, -0.7, '😞'),
  guilt('guilt', '죄책감', EmotionCategory.negative, -0.5, '😔'),
  loneliness('loneliness', '외로움', EmotionCategory.negative, -0.6, '😭'),
  stress('stress', '스트레스', EmotionCategory.negative, -0.8, '😵'),

  // 중립적 감정들
  neutral('neutral', '중립', EmotionCategory.neutral, 0.0, '😐'),
  calm('calm', '평온', EmotionCategory.neutral, 0.0, '😌'),
  focused('focused', '집중', EmotionCategory.neutral, 0.2, '🧘'),
  tired('tired', '피곤', EmotionCategory.neutral, -0.2, '😴'),
  bored('bored', '지루함', EmotionCategory.neutral, -0.1, '😑'),
  curious('curious', '호기심', EmotionCategory.neutral, 0.3, '🤔'),

  // 복합적 감정들
  bittersweet('bittersweet', '씁쓸함', EmotionCategory.mixed, 0.0, '😅'),
  overwhelmed('overwhelmed', '압도됨', EmotionCategory.mixed, -0.3, '🤯'),
  conflicted('conflicted', '갈등', EmotionCategory.mixed, -0.2, '😵‍💫'),

  // 불분명한 상태
  confused('confused', '혼란', EmotionCategory.unknown, 0.0, '😕'),
  numb('numb', '무감각', EmotionCategory.unknown, 0.0, '😶');

  const EmotionType(
      this.id, this.displayName, this.category, this.valence, this.emoji);

  final String id;
  final String displayName;
  final EmotionCategory category;
  final double valence; // -1.0 (매우 부정) ~ 1.0 (매우 긍정)
  final String emoji;

  /// 감정의 강도 레벨 (절댓값 기준)
  double get intensity => valence.abs();

  /// 긍정적 감정인지 확인
  bool get isPositive => valence > 0.3;

  /// 부정적 감정인지 확인
  bool get isNegative => valence < -0.3;

  /// 중립적 감정인지 확인
  bool get isNeutral => valence.abs() <= 0.3;
}

/// 🎭 감정 강도 레벨
enum EmotionIntensity {
  veryLow('very_low', '매우 낮음', 0.1),
  low('low', '낮음', 0.3),
  moderate('moderate', '보통', 0.5),
  high('high', '높음', 0.7),
  veryHigh('very_high', '매우 높음', 0.9);

  const EmotionIntensity(this.id, this.displayName, this.value);

  final String id;
  final String displayName;
  final double value;

  /// 레벨 (1-5 정수 스케일)
  int get level => (value * 5).round().clamp(1, 5);

  /// 강도 값을 EmotionIntensity로 변환
  static EmotionIntensity fromValue(double value) {
    if (value <= 0.2) return veryLow;
    if (value <= 0.4) return low;
    if (value <= 0.6) return moderate;
    if (value <= 0.8) return high;
    return veryHigh;
  }
}

/// 📈 감정 신뢰도 (분석 결과의 확실성)
enum EmotionConfidence {
  veryLow('very_low', '매우 낮음', 0.2),
  low('low', '낮음', 0.4),
  moderate('moderate', '보통', 0.6),
  high('high', '높음', 0.8),
  veryHigh('very_high', '매우 높음', 0.95);

  const EmotionConfidence(this.id, this.displayName, this.value);

  final String id;
  final String displayName;
  final double value;

  /// 레벨 (1-5 정수 스케일)
  int get level => (value * 5).round().clamp(1, 5);

  /// 신뢰도 값을 EmotionConfidence로 변환
  static EmotionConfidence fromValue(double value) {
    if (value <= 0.3) return veryLow;
    if (value <= 0.5) return low;
    if (value <= 0.7) return moderate;
    if (value <= 0.85) return high;
    return veryHigh;
  }
}

/// 🔍 감정 분석 소스 (어디서 추론되었는지)
enum EmotionSource {
  textAnalysis('text_analysis', '텍스트 분석', '📝'),
  behaviorPattern('behavior_pattern', '행동 패턴', '📊'),
  activityContext('activity_context', '활동 맥락', '🎯'),
  userExplicit('user_explicit', '사용자 직접 입력', '👤'),
  aiInference('ai_inference', 'AI 추론', '🤖'),
  historicalPattern('historical_pattern', '과거 패턴', '📈'),
  combinedAnalysis('combined_analysis', '종합 분석', '🔬');

  const EmotionSource(this.id, this.displayName, this.icon);

  final String id;
  final String displayName;
  final String icon;
}

/// 🎭 단일 감정 상태 스냅샷
@immutable
class EmotionSnapshot {
  final EmotionType type;
  final EmotionIntensity intensity;
  final EmotionConfidence confidence;
  final EmotionSource source;
  final DateTime timestamp;
  final Map<String, dynamic> context;
  final String? trigger; // 감정 유발 요인
  final String? note; // 추가 메모

  const EmotionSnapshot({
    required this.type,
    required this.intensity,
    required this.confidence,
    required this.source,
    required this.timestamp,
    this.context = const {},
    this.trigger,
    this.note,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'type': type.id,
      'intensity': intensity.id,
      'confidence': confidence.id,
      'source': source.id,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'trigger': trigger,
      'note': note,
    };
  }

  /// JSON 역직렬화
  factory EmotionSnapshot.fromJson(Map<String, dynamic> json) {
    return EmotionSnapshot(
      type: EmotionType.values.firstWhere((e) => e.id == json['type']),
      intensity:
          EmotionIntensity.values.firstWhere((e) => e.id == json['intensity']),
      confidence: EmotionConfidence.values
          .firstWhere((e) => e.id == json['confidence']),
      source: EmotionSource.values.firstWhere((e) => e.id == json['source']),
      timestamp: DateTime.parse(json['timestamp']),
      context: json['context'] ?? {},
      trigger: json['trigger'],
      note: json['note'],
    );
  }

  /// 감정 점수 (valence * intensity * confidence)
  double get emotionScore => type.valence * intensity.value * confidence.value;

  /// 감정이 충분히 신뢰할 만한가?
  bool get isReliable => confidence.value >= 0.6;

  /// 감정이 강한가?
  bool get isIntense => intensity.value >= 0.7;

  /// 복사본 생성
  EmotionSnapshot copyWith({
    EmotionType? type,
    EmotionIntensity? intensity,
    EmotionConfidence? confidence,
    EmotionSource? source,
    DateTime? timestamp,
    Map<String, dynamic>? context,
    String? trigger,
    String? note,
  }) {
    return EmotionSnapshot(
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
      trigger: trigger ?? this.trigger,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmotionSnapshot &&
        other.type == type &&
        other.intensity == intensity &&
        other.confidence == confidence &&
        other.source == source &&
        other.timestamp == timestamp &&
        mapEquals(other.context, context) &&
        other.trigger == trigger &&
        other.note == note;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        intensity.hashCode ^
        confidence.hashCode ^
        source.hashCode ^
        timestamp.hashCode ^
        context.hashCode ^
        trigger.hashCode ^
        note.hashCode;
  }

  @override
  String toString() {
    return 'EmotionSnapshot(type: ${type.displayName}, intensity: ${intensity.displayName}, confidence: ${confidence.displayName}, source: ${source.displayName})';
  }
}

/// 📊 감정 상태 통계
@immutable
class EmotionStats {
  final double averageValence; // 평균 감정가
  final double averageIntensity; // 평균 강도
  final double averageConfidence; // 평균 신뢰도
  final EmotionType dominantEmotion; // 주요 감정
  final Map<EmotionCategory, int> categoryDistribution; // 카테고리별 분포
  final Map<EmotionType, int> typeDistribution; // 타입별 분포
  final int totalSnapshots; // 총 스냅샷 수
  final Duration timeSpan; // 분석 기간

  const EmotionStats({
    required this.averageValence,
    required this.averageIntensity,
    required this.averageConfidence,
    required this.dominantEmotion,
    required this.categoryDistribution,
    required this.typeDistribution,
    required this.totalSnapshots,
    required this.timeSpan,
  });

  /// 전반적인 감정 상태 (긍정/부정/중립)
  EmotionCategory get overallMood {
    if (averageValence > 0.2) return EmotionCategory.positive;
    if (averageValence < -0.2) return EmotionCategory.negative;
    return EmotionCategory.neutral;
  }

  /// 감정 안정성 (변동폭이 작을수록 높음)
  double get emotionalStability {
    // 통계가 충분하지 않으면 중간값 반환
    if (totalSnapshots < 5) return 0.5;

    // 감정 분포의 균등성을 기준으로 안정성 계산
    final maxCategory =
        categoryDistribution.values.fold(0, (a, b) => a > b ? a : b);
    final evenness = 1.0 - (maxCategory / totalSnapshots);
    return evenness.clamp(0.0, 1.0);
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'averageValence': averageValence,
      'averageIntensity': averageIntensity,
      'averageConfidence': averageConfidence,
      'dominantEmotion': dominantEmotion.id,
      'categoryDistribution':
          categoryDistribution.map((k, v) => MapEntry(k.id, v)),
      'typeDistribution': typeDistribution.map((k, v) => MapEntry(k.id, v)),
      'totalSnapshots': totalSnapshots,
      'timeSpanMinutes': timeSpan.inMinutes,
    };
  }

  /// JSON 역직렬화
  factory EmotionStats.fromJson(Map<String, dynamic> json) {
    return EmotionStats(
      averageValence: json['averageValence'].toDouble(),
      averageIntensity: json['averageIntensity'].toDouble(),
      averageConfidence: json['averageConfidence'].toDouble(),
      dominantEmotion:
          EmotionType.values.firstWhere((e) => e.id == json['dominantEmotion']),
      categoryDistribution: (json['categoryDistribution']
              as Map<String, dynamic>)
          .map((k, v) => MapEntry(
              EmotionCategory.values.firstWhere((e) => e.id == k), v as int)),
      typeDistribution: (json['typeDistribution'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(
              EmotionType.values.firstWhere((e) => e.id == k), v as int)),
      totalSnapshots: json['totalSnapshots'],
      timeSpan: Duration(minutes: json['timeSpanMinutes']),
    );
  }

  @override
  String toString() {
    return 'EmotionStats(dominant: ${dominantEmotion.displayName}, avgValence: ${averageValence.toStringAsFixed(2)}, stability: ${emotionalStability.toStringAsFixed(2)})';
  }
}

/// 📈 감정 상태 히스토리
@immutable
class EmotionHistory {
  final List<EmotionSnapshot> snapshots;
  final DateTime startTime;
  final DateTime endTime;

  const EmotionHistory({
    required this.snapshots,
    required this.startTime,
    required this.endTime,
  });

  /// 최신 감정 상태
  EmotionSnapshot? get latestEmotion =>
      snapshots.isNotEmpty ? snapshots.last : null;

  /// 히스토리 기간
  Duration get duration => endTime.difference(startTime);

  /// 신뢰할 만한 스냅샷들만 필터링
  List<EmotionSnapshot> get reliableSnapshots =>
      snapshots.where((s) => s.isReliable).toList();

  /// 특정 기간의 스냅샷들 필터링
  List<EmotionSnapshot> getSnapshotsInRange(DateTime start, DateTime end) {
    return snapshots
        .where((s) => s.timestamp.isAfter(start) && s.timestamp.isBefore(end))
        .toList();
  }

  /// 특정 감정 타입의 스냅샷들 필터링
  List<EmotionSnapshot> getSnapshotsByType(EmotionType type) {
    return snapshots.where((s) => s.type == type).toList();
  }

  /// 감정 통계 계산
  EmotionStats calculateStats() {
    if (snapshots.isEmpty) {
      return EmotionStats(
        averageValence: 0.0,
        averageIntensity: 0.0,
        averageConfidence: 0.0,
        dominantEmotion: EmotionType.neutral,
        categoryDistribution: {},
        typeDistribution: {},
        totalSnapshots: 0,
        timeSpan: Duration.zero,
      );
    }

    final reliableSnaps = reliableSnapshots;
    if (reliableSnaps.isEmpty) {
      return EmotionStats(
        averageValence: 0.0,
        averageIntensity: 0.0,
        averageConfidence: 0.0,
        dominantEmotion: EmotionType.confused,
        categoryDistribution: {},
        typeDistribution: {},
        totalSnapshots: snapshots.length,
        timeSpan: duration,
      );
    }

    // 평균 계산
    final avgValence =
        reliableSnaps.map((s) => s.type.valence).reduce((a, b) => a + b) /
            reliableSnaps.length;

    final avgIntensity =
        reliableSnaps.map((s) => s.intensity.value).reduce((a, b) => a + b) /
            reliableSnaps.length;

    final avgConfidence =
        reliableSnaps.map((s) => s.confidence.value).reduce((a, b) => a + b) /
            reliableSnaps.length;

    // 분포 계산
    final categoryDist = <EmotionCategory, int>{};
    final typeDist = <EmotionType, int>{};

    for (final snap in reliableSnaps) {
      categoryDist[snap.type.category] =
          (categoryDist[snap.type.category] ?? 0) + 1;
      typeDist[snap.type] = (typeDist[snap.type] ?? 0) + 1;
    }

    // 주요 감정 찾기
    final dominantType =
        typeDist.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return EmotionStats(
      averageValence: avgValence,
      averageIntensity: avgIntensity,
      averageConfidence: avgConfidence,
      dominantEmotion: dominantType,
      categoryDistribution: categoryDist,
      typeDistribution: typeDist,
      totalSnapshots: reliableSnaps.length,
      timeSpan: duration,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'snapshots': snapshots.map((s) => s.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  /// JSON 역직렬화
  factory EmotionHistory.fromJson(Map<String, dynamic> json) {
    return EmotionHistory(
      snapshots: (json['snapshots'] as List)
          .map((s) => EmotionSnapshot.fromJson(s))
          .toList(),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }

  @override
  String toString() {
    return 'EmotionHistory(${snapshots.length} snapshots, ${duration.inMinutes}분간)';
  }
}

/// 🎯 감정 상태 목표/임계값 설정
@immutable
class EmotionGoals {
  final double targetValence; // 목표 감정가 (-1.0 ~ 1.0)
  final double minValence; // 최소 허용 감정가
  final double maxIntensity; // 최대 감정 강도 (스트레스 관리)
  final double targetStability; // 목표 감정 안정성
  final Map<EmotionType, int> maxFrequency; // 특정 감정의 최대 빈도

  const EmotionGoals({
    this.targetValence = 0.3, // 약간 긍정적
    this.minValence = -0.5, // 적당한 부정까지 허용
    this.maxIntensity = 0.8, // 매우 높은 강도는 제한
    this.targetStability = 0.7, // 높은 안정성 목표
    this.maxFrequency = const {},
  });

  /// 목표 달성 여부 확인
  bool isGoalMet(EmotionStats stats) {
    return stats.averageValence >= minValence &&
        stats.averageIntensity <= maxIntensity &&
        stats.emotionalStability >= targetStability * 0.8; // 80% 달성으로 완화
  }

  /// 목표와의 차이점 분석
  Map<String, double> analyzeGaps(EmotionStats stats) {
    return {
      'valence_gap': (targetValence - stats.averageValence).clamp(-2.0, 2.0),
      'intensity_gap': (stats.averageIntensity - maxIntensity).clamp(-2.0, 2.0),
      'stability_gap':
          (targetStability - stats.emotionalStability).clamp(-2.0, 2.0),
    };
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'targetValence': targetValence,
      'minValence': minValence,
      'maxIntensity': maxIntensity,
      'targetStability': targetStability,
      'maxFrequency': maxFrequency.map((k, v) => MapEntry(k.id, v)),
    };
  }

  /// JSON 역직렬화
  factory EmotionGoals.fromJson(Map<String, dynamic> json) {
    return EmotionGoals(
      targetValence: json['targetValence']?.toDouble() ?? 0.3,
      minValence: json['minValence']?.toDouble() ?? -0.5,
      maxIntensity: json['maxIntensity']?.toDouble() ?? 0.8,
      targetStability: json['targetStability']?.toDouble() ?? 0.7,
      maxFrequency: (json['maxFrequency'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(
                  EmotionType.values.firstWhere((e) => e.id == k), v as int)) ??
          {},
    );
  }
}
