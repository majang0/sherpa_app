import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/ai/sources/openai_dialogue_source.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/models/point_system_model.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_point_provider.dart';
import 'user_data_analyzer.dart';

/// 🤖 AI 기반 인사이트 생성기
///
/// OpenAI GPT-5를 활용하여 사용자의 데이터를 분석하고
/// 개인화된 인사이트와 추천사항을 생성합니다.
/// 분석 시 30포인트가 필요합니다.
class AiInsightGenerator {
  late final OpenAIDialogueSource _openAISource;
  static const int ANALYSIS_COST = 30; // 분석 비용: 30포인트

  final Ref? _ref; // Riverpod ref for accessing providers

  AiInsightGenerator({Ref? ref}) : _ref = ref {
    try {
      _openAISource = OpenAIDialogueSource();
      LoggerService.instance.i('✅ OpenAI GPT-5 인사이트 생성기 초기화 완료');
    } catch (e) {
      LoggerService.instance.d('❌ OpenAI 인사이트 생성기 초기화 실패: $e');
      rethrow;
    }
  }

  /// 포인트 확인 메서드
  bool _hasEnoughPoints() {
    if (_ref == null) return false;
    final pointState = _ref!.read(globalPointProvider);
    return pointState.totalPoints >= ANALYSIS_COST;
  }

  /// 포인트 차감 메서드
  Future<bool> _deductPoints() async {
    if (_ref == null) return false;
    try {
      final result =
          _ref!.read(globalPointProvider.notifier).spendPointsDetailed(
                ANALYSIS_COST,
                PointSpendType.analysisReport,
                'AI 분석 사용료',
              );
      if (result) {
        LoggerService.instance.i('✅ 분석 포인트 차감 성공: ${ANALYSIS_COST}P');
      } else {
        LoggerService.instance.d('❌ 분석 포인트 차감 실패: 포인트 부족');
      }
      return result;
    } catch (e) {
      LoggerService.instance.d('❌ 포인트 차감 중 오류: $e');
      return false;
    }
  }

  Future<void> _refundPoints(String reason) async {
    if (_ref == null) return;
    try {
      _ref!
          .read(globalPointProvider.notifier)
          .refundPoints(ANALYSIS_COST, reason);
    } catch (e) {
      LoggerService.instance.w('⚠️ 포인트 환불 중 오류: $e');
    }
  }

  /// 📊 AI 기반 인사이트 생성
  Future<List<Insight>> generateAIInsights(
    GlobalUser user,
    AnalysisResult analysisResult,
  ) async {
    bool deducted = false;
    if (_ref != null) {
      if (!_hasEnoughPoints()) {
        throw InsufficientPointsException(
            '포인트 부족: 분석을 위해서는 $ANALYSIS_COST포인트가 필요합니다.');
      }
      deducted = await _deductPoints();
      if (!deducted) {
        throw InsufficientPointsException('포인트 차감에 실패했습니다.');
      }
    }

    try {
      // AI 인사이트 생성 시작

      // 사용자 데이터 요약 생성
      final userSummary = _buildUserDataSummary(user, analysisResult);

      // OpenAI GPT-5로 인사이트 요청
      final aiResponse = await _openAISource.getDialogue(
        SherpiContext.general, // 일반적인 컨텍스트 사용
        {
          'task': 'analyze_insights',
          'user_summary': userSummary,
        },
        {
          'analysis_type': 'deep_insights',
          'generate_recommendations': true,
        },
      );

      // AI 응답을 파싱하여 인사이트 생성
      final aiInsights = _parseAIInsights(aiResponse);

      // 기존 인사이트와 AI 인사이트 결합
      final combinedInsights = [...analysisResult.insights, ...aiInsights];

      // 중요도 순으로 정렬하고 최대 8개만 반환
      combinedInsights.sort((a, b) => b.importance.compareTo(a.importance));

      // AI 인사이트 생성 완료
      return combinedInsights.take(8).toList();
    } catch (e) {
      if (deducted) {
        await _refundPoints('AI 인사이트 생성 실패');
      }
      // AI 인사이트 생성 실패
      // 실패 시 기본 인사이트 반환
      return analysisResult.insights;
    }
  }

  /// 📝 AI 기반 추천사항 생성
  Future<List<Recommendation>> generateAIRecommendations(
    GlobalUser user,
    AnalysisResult analysisResult,
  ) async {
    bool deducted = false;
    if (_ref != null) {
      if (!_hasEnoughPoints()) {
        throw InsufficientPointsException(
            '포인트 부족: 분석을 위해서는 $ANALYSIS_COST포인트가 필요합니다.');
      }
      deducted = await _deductPoints();
      if (!deducted) {
        throw InsufficientPointsException('포인트 차감에 실패했습니다.');
      }
    }

    try {
      // AI 추천사항 생성 시작

      // 사용자 데이터와 현재 성과 요약
      final performanceSummary = _buildPerformanceSummary(user, analysisResult);

      // OpenAI GPT-5로 개인화된 추천사항 요청
      final aiResponse = await _openAISource.getDialogue(
        SherpiContext.guidance,
        {
          'task': 'generate_recommendations',
          'performance_summary': performanceSummary,
          'current_level': user.level,
          'user_name': user.name,
        },
        {
          'recommendation_type': 'personalized_growth',
          'focus_areas': _getWeakAreas(analysisResult),
          'strength_areas': _getStrongAreas(analysisResult),
        },
      );

      // AI 응답을 파싱하여 추천사항 생성
      final aiRecommendations = _parseAIRecommendations(aiResponse);

      // 기존 추천사항과 결합
      final combinedRecommendations = [
        ...analysisResult.recommendations,
        ...aiRecommendations
      ];

      // 우선순위 순으로 정렬하고 최대 6개만 반환
      combinedRecommendations.sort((a, b) => b.priority.compareTo(a.priority));

      // AI 추천사항 생성 완료
      return combinedRecommendations.take(6).toList();
    } catch (e) {
      if (deducted) {
        await _refundPoints('AI 추천 생성 실패');
      }
      // AI 추천사항 생성 실패
      // 실패 시 기본 추천사항 반환
      return analysisResult.recommendations;
    }
  }

  /// 📈 스마트 성장 계획 생성
  Future<String> generateSmartGrowthPlan(
    GlobalUser user,
    AnalysisResult analysisResult,
  ) async {
    bool deducted = false;
    if (_ref != null) {
      if (!_hasEnoughPoints()) {
        throw InsufficientPointsException(
            '포인트 부족: 분석을 위해서는 $ANALYSIS_COST포인트가 필요합니다.');
      }
      deducted = await _deductPoints();
      if (!deducted) {
        throw InsufficientPointsException('포인트 차감에 실패했습니다.');
      }
    }

    try {
      // 스마트 성장 계획 생성 시작

      // 성장 계획을 위한 종합적인 데이터 준비
      final growthContext = _buildGrowthContext(user, analysisResult);

      // OpenAI GPT-5로 개인화된 성장 계획 요청
      final aiResponse = await _openAISource.getDialogue(
        SherpiContext.guidance,
        {
          'task': 'create_growth_plan',
          'growth_context': growthContext,
          'target_timeframe': '4주',
        },
        {
          'plan_type': 'comprehensive_growth',
          'user_level': user.level,
          'personality_preference': 'balanced', // 추후 개인화 설정 연동 가능
        },
      );

      // 스마트 성장 계획 생성 완료
      return _processGrowthPlan(aiResponse);
    } catch (e) {
      if (deducted) {
        await _refundPoints('AI 성장 계획 생성 실패');
      }
      // 스마트 성장 계획 생성 실패
      // 실패 시 기본 계획 반환
      return _getDefaultGrowthPlan(user, analysisResult);
    }
  }

  // === 프라이빗 헬퍼 메서드들 ===

  /// 사용자 데이터 요약 생성
  String _buildUserDataSummary(GlobalUser user, AnalysisResult analysisResult) {
    final patterns = analysisResult.activityPatterns;
    final mood = analysisResult.moodAnalysis;
    final metrics = analysisResult.performanceMetrics;

    return '''
사용자: ${user.name} (레벨 ${user.level})
활동 패턴: ${patterns.mostActiveDay} ${patterns.mostActiveTime}에 주로 활동
일관성 점수: ${patterns.consistencyScore.toStringAsFixed(1)}%
연속 활동: 현재 ${patterns.currentStreak}일, 최대 ${patterns.longestStreak}일
주요 기분: ${mood.dominantMood}
기분 안정성: ${mood.moodStability.toStringAsFixed(1)}%
목표 달성률: ${metrics.goalCompletionRate.toStringAsFixed(1)}%
총 활동 수: ${metrics.totalActivities}개
평균 만족도: ${metrics.averageSatisfaction.toStringAsFixed(1)}점
''';
  }

  /// 성과 요약 생성
  String _buildPerformanceSummary(
      GlobalUser user, AnalysisResult analysisResult) {
    final metrics = analysisResult.performanceMetrics;
    final bestCategory = metrics.categoryPerformance.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final worstCategory = metrics.categoryPerformance.entries
        .reduce((a, b) => a.value < b.value ? a : b);

    return '''
현재 성과 요약:
- 가장 잘하는 영역: ${bestCategory.key} (${bestCategory.value.toStringAsFixed(1)}%)
- 개선이 필요한 영역: ${worstCategory.key} (${worstCategory.value.toStringAsFixed(1)}%)
- 전체 진행도: ${metrics.overallProgress.toStringAsFixed(1)}%
- 최근 활동 만족도: ${metrics.averageSatisfaction.toStringAsFixed(1)}/5.0
''';
  }

  /// 성장 컨텍스트 생성
  String _buildGrowthContext(GlobalUser user, AnalysisResult analysisResult) {
    return '''
${_buildUserDataSummary(user, analysisResult)}

현재 강점:
${_getStrongAreas(analysisResult).map((area) => '- $area').join('\n')}

개선 기회:
${_getWeakAreas(analysisResult).map((area) => '- $area').join('\n')}

최근 성취:
- 레벨 ${user.level} 달성
- ${analysisResult.performanceMetrics.totalActivities}개 활동 완료
''';
  }

  /// 강점 영역 추출
  List<String> _getStrongAreas(AnalysisResult result) {
    final strongAreas = <String>[];

    if (result.activityPatterns.consistencyScore > 70) {
      strongAreas.add('꾸준한 활동 습관');
    }

    if (result.moodAnalysis.moodStability > 70) {
      strongAreas.add('안정적인 감정 관리');
    }

    if (result.performanceMetrics.goalCompletionRate > 80) {
      strongAreas.add('높은 목표 달성률');
    }

    final bestCategory = result.performanceMetrics.categoryPerformance.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    if (bestCategory.value > 70) {
      strongAreas.add('${bestCategory.key} 분야 우수성');
    }

    return strongAreas.isEmpty ? ['성장 잠재력'] : strongAreas;
  }

  /// 약점 영역 추출
  List<String> _getWeakAreas(AnalysisResult result) {
    final weakAreas = <String>[];

    if (result.activityPatterns.consistencyScore < 50) {
      weakAreas.add('활동 일관성 부족');
    }

    if (result.moodAnalysis.moodStability < 50) {
      weakAreas.add('기분 변동성');
    }

    if (result.performanceMetrics.goalCompletionRate < 60) {
      weakAreas.add('목표 달성률 개선 필요');
    }

    final worstCategory = result.performanceMetrics.categoryPerformance.entries
        .reduce((a, b) => a.value < b.value ? a : b);
    if (worstCategory.value < 30) {
      weakAreas.add('${worstCategory.key} 분야 강화 필요');
    }

    return weakAreas.isEmpty ? ['균형적 성장 기회'] : weakAreas;
  }

  /// AI 응답에서 인사이트 파싱
  List<Insight> _parseAIInsights(String aiResponse) {
    final insights = <Insight>[];

    try {
      // 간단한 파싱 로직 (실제로는 더 정교한 파싱 필요)
      final lines = aiResponse.split('\n');

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        if (line.contains('강점') || line.contains('우수')) {
          insights.add(Insight(
            title: 'AI 발견 강점',
            description: line.trim(),
            type: InsightType.strength,
            importance: 0.8,
            icon: Icons.star,
          ));
        } else if (line.contains('기회') || line.contains('개선')) {
          insights.add(Insight(
            title: 'AI 개선 기회',
            description: line.trim(),
            type: InsightType.opportunity,
            importance: 0.7,
            icon: Icons.trending_up,
          ));
        } else if (line.contains('패턴') || line.contains('경향')) {
          insights.add(Insight(
            title: 'AI 패턴 분석',
            description: line.trim(),
            type: InsightType.trend,
            importance: 0.6,
            icon: Icons.analytics,
          ));
        }

        // 최대 3개의 AI 인사이트만 추가
        if (insights.length >= 3) break;
      }
    } catch (e) {
      // AI 인사이트 파싱 오류
    }

    return insights;
  }

  /// AI 응답에서 추천사항 파싱
  List<Recommendation> _parseAIRecommendations(String aiResponse) {
    final recommendations = <Recommendation>[];

    try {
      final lines = aiResponse.split('\n');

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        if (line.contains('추천') || line.contains('제안')) {
          recommendations.add(Recommendation(
            title: 'AI 맞춤 추천',
            description: line.trim(),
            actionText: '실행하기',
            type: RecommendationType.improvement,
            priority: 4,
            icon: Icons.auto_awesome,
          ));
        } else if (line.contains('목표') || line.contains('계획')) {
          recommendations.add(Recommendation(
            title: 'AI 목표 제안',
            description: line.trim(),
            actionText: '목표 설정',
            type: RecommendationType.goal,
            priority: 5,
            icon: Icons.flag,
          ));
        }

        // 최대 2개의 AI 추천사항만 추가
        if (recommendations.length >= 2) break;
      }
    } catch (e) {
      // AI 추천사항 파싱 오류
    }

    return recommendations;
  }

  /// 성장 계획 후처리
  String _processGrowthPlan(String aiResponse) {
    // AI 응답을 정리하고 포맷팅
    String processed = aiResponse.trim();

    // 불필요한 접두사/접미사 제거
    processed = processed.replaceAll(
        RegExp(r'^(안녕하세요|안녕|네,?\s*)', caseSensitive: false), '');
    processed = processed.replaceAll(
        RegExp(r'(감사합니다|고맙습니다)\.?\s*$', caseSensitive: false), '');

    // 길이 제한 (1000자)
    if (processed.length > 1000) {
      processed = '${processed.substring(0, 1000)}...';
    }

    return processed.isEmpty ? _getDefaultGrowthPlan(null, null) : processed;
  }

  /// 기본 성장 계획
  String _getDefaultGrowthPlan(GlobalUser? user, AnalysisResult? result) {
    return '''
🌱 4주 성장 계획

📅 1주차: 기초 다지기
- 매일 한 가지 활동씩 꾸준히 실행하기
- 활동 후 간단한 기록 남기기
- 개인 목표 설정하고 계획 세우기

📅 2주차: 패턴 형성
- 최적의 활동 시간대 찾기
- 활동 종류 다양화하기
- 주간 리뷰 및 조정

📅 3주차: 강화 및 확장
- 도전적인 목표 설정하기
- 새로운 활동 분야 탐험
- 동기부여 시스템 구축

📅 4주차: 정착 및 평가
- 지속 가능한 루틴 완성
- 성과 평가 및 축하
- 다음 단계 계획 수립

💡 성공 팁: 작은 목표부터 시작하여 점진적으로 확장하세요!
''';
  }
}

/// AI 분석 결과 클래스
class AiAnalysisResult {
  final List<Insight> insights;
  final List<Recommendation> recommendations;
  final String growthPlan;
  final int pointsUsed;
  final DateTime analysisTime;

  AiAnalysisResult({
    required this.insights,
    required this.recommendations,
    required this.growthPlan,
    required this.pointsUsed,
    required this.analysisTime,
  });
}

/// 포인트 부족 예외
class InsufficientPointsException implements Exception {
  final String message;

  InsufficientPointsException(this.message);

  @override
  String toString() => 'InsufficientPointsException: $message';
}
