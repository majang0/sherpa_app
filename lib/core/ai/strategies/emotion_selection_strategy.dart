// lib/core/ai/strategies/emotion_selection_strategy.dart

import 'dart:math' show Random;
import 'package:sherpa_app/core/ai/models/encouragement_message_type.dart';

/// 🎯 감정 선택 전략 (Strategy Pattern)
///
/// 감정 선택 로직을 중앙화하여 코드 중복 제거 및 유지보수성 향상
///
/// **사용처**:
/// - UnifiedSherpiManager (격려 메시지 타입 선택)
/// - GlobalSherpiProvider (감정 상태 결정)
/// - EmotionAnalysisService (감정 추천)
///
/// **개선 효과**:
/// - 감정 선택 로직 통합 (3개 파일 → 1개 파일)
/// - 테스트 가능성 향상
/// - 알고리즘 변경 시 한 곳만 수정
class EmotionSelectionStrategy {
  // 🎯 최근 메시지 타입 히스토리 (최근 3개)
  final List<String> _recentMessageTypes;

  EmotionSelectionStrategy([List<String>? initialHistory])
      : _recentMessageTypes = initialHistory ?? [];

  /// 🎯 메시지 타입 선택 (감정 상태 + 활동 추세 기반)
  ///
  /// Returns: 최적의 EncouragementMessageType
  EncouragementMessageType selectMessageType({
    required Map<String, dynamic>? gameContext,
  }) {
    // Step 1: 특정 컨텍스트 우선 체크 (등산 성공, 실패 등)
    final contextOverride = _checkContextOverrides(gameContext);
    if (contextOverride != null) {
      return contextOverride;
    }

    // Step 2: 최근 사용된 타입 필터링 (반복 방지)
    final availableTypes = EncouragementMessageType.values
        .where((type) => !_recentMessageTypes.contains(type.id))
        .toList();

    // Step 3: 모든 타입이 최근 사용됨 → 리셋
    if (availableTypes.isEmpty) {
      _recentMessageTypes.clear();
      final emotionalContext = _analyzeEmotionalContext(
        gameContext?['consecutiveDays'] ?? 0,
        gameContext?['totalActivities'] ?? 0,
        gameContext?['climbingSuccessRate'] ?? 0.0,
      );
      return _getDefaultTypeForEmotion(emotionalContext);
    }

    // Step 4: 각 타입별 점수 계산
    final emotionalContext = _analyzeEmotionalContext(
      gameContext?['consecutiveDays'] ?? 0,
      gameContext?['totalActivities'] ?? 0,
      gameContext?['climbingSuccessRate'] ?? 0.0,
    );

    final activityTrend = _analyzeActivityTrend(
      gameContext?['consecutiveDays'] ?? 0,
      gameContext?['totalActivities'] ?? 0,
    );

    final scores = <EncouragementMessageType, double>{};
    for (final type in availableTypes) {
      scores[type] = _calculateTypeScore(type, emotionalContext, activityTrend);
    }

    // Step 5: 최고 점수 타입 선택
    final topType = scores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return topType;
  }

  /// 📋 선택 결과 기록 (히스토리 업데이트)
  ///
  /// 반복 방지를 위해 선택된 타입을 히스토리에 추가
  void recordSelection(EncouragementMessageType selectedType) {
    _recentMessageTypes.add(selectedType.id);
    if (_recentMessageTypes.length > 3) {
      _recentMessageTypes.removeAt(0);
    }
  }

  /// 🔄 히스토리 초기화
  void clearHistory() {
    _recentMessageTypes.clear();
  }

  /// 📊 현재 히스토리 조회
  List<String> get recentMessageTypes => List.unmodifiable(_recentMessageTypes);

  // ═══════════════════════════════════════════════════════════════
  // Private Helper Methods
  // ═══════════════════════════════════════════════════════════════

  /// 특정 컨텍스트 우선 처리 (등산 성공, 실패 등)
  EncouragementMessageType? _checkContextOverrides(
      Map<String, dynamic>? gameContext) {
    final context = gameContext?['context'] as String?;

    switch (context) {
      case 'climbing_success':
      case 'milestone':
        return EncouragementMessageType.celebration;

      case 'climbing_failure':
        // 실패 시 공감 또는 성찰 중 랜덤
        return Random().nextBool()
            ? EncouragementMessageType.empathy
            : EncouragementMessageType.reflection;

      case 'long_absence':
        return EncouragementMessageType.companionship;

      default:
        return null; // 우선 처리 없음
    }
  }

  /// 감정 상태 분석
  String _analyzeEmotionalContext(
    int consecutiveDays,
    int totalActivities,
    double climbingSuccessRate,
  ) {
    // 높은 연속일 → 의욕적
    if (consecutiveDays >= 14) return '의욕적';

    // 최근 활동 거의 없음 → 번아웃
    if (consecutiveDays == 0 && totalActivities < 3) return '번아웃';

    // 낮은 성공률 → 피곤
    if (climbingSuccessRate < 0.3 && totalActivities > 5) return '피곤';

    // 높은 성공률 → 자신감
    if (climbingSuccessRate >= 0.7) return '자신감';

    return '보통';
  }

  /// 활동 추세 분석
  String _analyzeActivityTrend(int consecutiveDays, int totalActivities) {
    // 높은 연속일 → 증가 추세
    if (consecutiveDays >= 7) return '증가';

    // 활동 있지만 연속일 낮음 → 복귀 중
    if (consecutiveDays > 0 && consecutiveDays < 7 && totalActivities > 10) {
      return '복귀';
    }

    // 활동 적음 → 감소
    if (totalActivities < 5) return '감소';

    return '유지';
  }

  /// 타입별 점수 계산 (감정 상태 + 활동 추세)
  double _calculateTypeScore(
    EncouragementMessageType type,
    String emotionalContext,
    String activityTrend,
  ) {
    double score = 0.0;

    // 감정 상태별 점수
    switch (emotionalContext) {
      case '번아웃':
        if (type == EncouragementMessageType.empathy) score += 40;
        if (type == EncouragementMessageType.comfort) score += 30;
        if (type == EncouragementMessageType.companionship) score += 20;
        break;

      case '피곤':
        if (type == EncouragementMessageType.empathy) score += 35;
        if (type == EncouragementMessageType.comfort) score += 30;
        if (type == EncouragementMessageType.reflection) score += 15;
        break;

      case '의욕적':
        if (type == EncouragementMessageType.cheering) score += 40;
        if (type == EncouragementMessageType.recognition) score += 25;
        if (type == EncouragementMessageType.celebration) score += 20;
        break;

      case '자신감':
        if (type == EncouragementMessageType.celebration) score += 40;
        if (type == EncouragementMessageType.recognition) score += 30;
        if (type == EncouragementMessageType.cheering) score += 20;
        break;

      case '좌절':
        if (type == EncouragementMessageType.empathy) score += 35;
        if (type == EncouragementMessageType.reflection) score += 30;
        if (type == EncouragementMessageType.comfort) score += 25;
        break;

      case '보통':
        if (type == EncouragementMessageType.recognition) score += 30;
        if (type == EncouragementMessageType.companionship) score += 25;
        if (type == EncouragementMessageType.cheering) score += 20;
        break;
    }

    // 활동 추세별 추가 점수
    switch (activityTrend) {
      case '증가':
        if (type == EncouragementMessageType.cheering) score += 20;
        if (type == EncouragementMessageType.recognition) score += 15;
        break;

      case '감소':
        if (type == EncouragementMessageType.empathy) score += 20;
        if (type == EncouragementMessageType.comfort) score += 15;
        break;

      case '복귀':
        if (type == EncouragementMessageType.companionship) score += 25;
        if (type == EncouragementMessageType.cheering) score += 10;
        break;

      case '유지':
        if (type == EncouragementMessageType.recognition) score += 20;
        if (type == EncouragementMessageType.cheering) score += 10;
        break;
    }

    return score;
  }

  /// 감정 상태별 기본 타입 반환
  EncouragementMessageType _getDefaultTypeForEmotion(String emotionalContext) {
    switch (emotionalContext) {
      case '번아웃':
        return EncouragementMessageType.empathy;
      case '피곤':
        return EncouragementMessageType.comfort;
      case '의욕적':
        return EncouragementMessageType.cheering;
      case '자신감':
        return EncouragementMessageType.celebration;
      case '좌절':
        return EncouragementMessageType.empathy;
      case '보통':
      default:
        return EncouragementMessageType.recognition;
    }
  }
}
