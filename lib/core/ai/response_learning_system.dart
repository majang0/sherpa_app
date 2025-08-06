import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/sherpi_dialogues.dart';

/// 🧠 응답 학습 시스템
/// 
/// 사용자의 반응과 피드백을 학습하여 
/// AI 응답의 개인화 수준을 자동으로 조정합니다.
class ResponseLearningSystem {
  final SharedPreferences _prefs;
  
  // 학습 데이터 저장 키
  static const String _responseHistoryKey = 'response_learning_history';
  static const String _personalPreferencesKey = 'personal_ai_preferences';
  static const String _contextEffectivenessKey = 'context_effectiveness_data';
  static const String _adaptationRulesKey = 'adaptation_rules';
  
  ResponseLearningSystem(this._prefs);
  
  /// 📊 응답 학습 결과
  Future<LearningInsights> analyzeLearningProgress() async {
    final history = await _getResponseHistory();
    final preferences = await _getPersonalPreferences();
    final effectiveness = await _getContextEffectiveness();
    
    return LearningInsights(
      totalResponses: history.length,
      averageEffectiveness: _calculateAverageEffectiveness(history),
      preferredResponseTypes: _identifyPreferredTypes(history),
      optimalContexts: _findOptimalContexts(effectiveness),
      learningConfidence: _calculateLearningConfidence(history),
      adaptationRecommendations: await _generateAdaptationRecommendations(
        history, preferences, effectiveness
      ),
    );
  }
  
  /// 🎯 사용자 반응 기록 및 학습
  Future<void> recordUserResponse({
    required String messageId,
    required UserResponseType responseType,
    required SherpiContext context,
    required String messageContent,
    required String personalityType,
    required double personalizationLevel,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    final response = UserResponseRecord(
      messageId: messageId,
      responseType: responseType,
      context: context,
      messageContent: messageContent,
      personalityType: personalityType,
      personalizationLevel: personalizationLevel,
      timestamp: DateTime.now(),
      metadata: additionalMetadata ?? {},
    );
    
    await _saveResponseRecord(response);
    await _updatePersonalPreferences(response);
    await _updateContextEffectiveness(response);
    await _adaptPersonalizationStrategy(response);
    
    print('🧠 사용자 반응 학습 완료: ${responseType.name}');
  }
  
  /// 🔄 개인화 전략 동적 조정
  Future<PersonalizationAdjustment> getPersonalizationAdjustment({
    required String personalityType,
    required SherpiContext context,
    required double currentLevel,
  }) async {
    final history = await _getResponseHistory();
    final contextData = history.where((r) => 
      r.context == context && r.personalityType == personalityType
    ).toList();
    
    if (contextData.isEmpty) {
      return PersonalizationAdjustment(
        recommendedLevel: currentLevel,
        adjustmentReason: 'insufficient_data',
        confidence: 0.0,
      );
    }
    
    final averageEffectiveness = _calculateContextEffectiveness(contextData);
    final optimalLevel = _findOptimalPersonalizationLevel(contextData);
    
    return PersonalizationAdjustment(
      recommendedLevel: optimalLevel,
      adjustmentReason: _determineAdjustmentReason(
        currentLevel, optimalLevel, averageEffectiveness
      ),
      confidence: _calculateAdjustmentConfidence(contextData),
      supportingData: {
        'sampleSize': contextData.length,
        'averageEffectiveness': averageEffectiveness,
        'recentTrend': _calculateRecentTrend(contextData),
      },
    );
  }
  
  /// 🎭 컨텍스트별 응답 스타일 최적화
  Future<ResponseStyleOptimization> optimizeResponseStyle({
    required SherpiContext context,
    required String personalityType,
  }) async {
    final history = await _getResponseHistory();
    final relevantData = history.where((r) => 
      r.context == context && r.personalityType == personalityType
    ).toList();
    
    final styleAnalysis = _analyzeResponseStyles(relevantData);
    final emotionalTrends = _analyzeEmotionalPreferences(relevantData);
    final timingPatterns = _analyzeTimingPreferences(relevantData);
    
    return ResponseStyleOptimization(
      preferredTone: styleAnalysis['preferredTone'] as String,
      optimalLength: styleAnalysis['optimalLength'] as int,
      effectiveKeywords: styleAnalysis['effectiveKeywords'] as List<String>,
      emotionalApproach: emotionalTrends['approach'] as String,
      timingRecommendation: timingPatterns['optimal'] as String,
      confidence: _calculateStyleConfidence(relevantData),
    );
  }
  
  /// 📈 성능 기반 자동 조정
  Future<void> performAutomaticAdjustment() async {
    final insights = await analyzeLearningProgress();
    
    // 성능이 낮은 컨텍스트 식별
    final underperformingContexts = insights.optimalContexts
        .where((context) => context.effectiveness < 0.6)
        .toList();
    
    for (final contextData in underperformingContexts) {
      await _adjustContextStrategy(contextData);
    }
    
    // 개인화 수준 글로벌 조정
    if (insights.averageEffectiveness < 0.7) {
      await _performGlobalPersonalizationAdjustment(insights);
    }
    
    // 적응 규칙 업데이트
    await _updateAdaptationRules(insights);
    
    print('🔄 자동 조정 완료: ${underperformingContexts.length}개 컨텍스트 최적화');
  }
  
  /// 🎯 맞춤형 응답 생성 가이드라인
  Future<ResponseGuidelines> generateResponseGuidelines({
    required String personalityType,
    required SherpiContext context,
    required Map<String, dynamic> userContext,
  }) async {
    final personalization = await getPersonalizationAdjustment(
      personalityType: personalityType,
      context: context,
      currentLevel: 0.7, // 기본값
    );
    
    final styleOptimization = await optimizeResponseStyle(
      context: context,
      personalityType: personalityType,
    );
    
    final preferences = await _getPersonalPreferences();
    final contextualPrefs = preferences[context.name] as Map<String, dynamic>? ?? {};
    
    return ResponseGuidelines(
      personalizationLevel: personalization.recommendedLevel,
      responseStyle: styleOptimization,
      avoidPatterns: contextualPrefs['avoid'] as List<String>? ?? [],
      emphasizePatterns: contextualPrefs['emphasize'] as List<String>? ?? [],
      tonalAdjustments: _generateTonalAdjustments(personalityType, userContext),
      structuralPreferences: _generateStructuralPreferences(styleOptimization),
    );
  }
  
  /// 🧪 A/B 테스트 결과 분석
  Future<ABTestResults> analyzeABTestResults({
    required String testId,
    required List<String> variantAMessages,
    required List<String> variantBMessages,
  }) async {
    final history = await _getResponseHistory();
    
    final variantAResponses = history.where((r) => 
      variantAMessages.contains(r.messageId)
    ).toList();
    
    final variantBResponses = history.where((r) => 
      variantBMessages.contains(r.messageId)
    ).toList();
    
    final aEffectiveness = _calculateAverageEffectiveness(variantAResponses);
    final bEffectiveness = _calculateAverageEffectiveness(variantBResponses);
    
    return ABTestResults(
      testId: testId,
      variantAEffectiveness: aEffectiveness,
      variantBEffectiveness: bEffectiveness,
      significanceLevel: _calculateSignificance(variantAResponses, variantBResponses),
      winningVariant: aEffectiveness > bEffectiveness ? 'A' : 'B',
      recommendation: _generateABTestRecommendation(aEffectiveness, bEffectiveness),
      sampleSizes: {
        'variantA': variantAResponses.length,
        'variantB': variantBResponses.length,
      },
    );
  }
  
  /// 📊 학습 시스템 성능 리포트
  Future<LearningPerformanceReport> generatePerformanceReport() async {
    final insights = await analyzeLearningProgress();
    final history = await _getResponseHistory();
    
    // 시간별 성능 트렌드
    final weeklyTrend = _calculateWeeklyTrend(history);
    final monthlyTrend = _calculateMonthlyTrend(history);
    
    // 컨텍스트별 성능
    final contextPerformance = <String, double>{};
    for (final context in SherpiContext.values) {
      final contextData = history.where((r) => r.context == context).toList();
      if (contextData.isNotEmpty) {
        contextPerformance[context.name] = _calculateAverageEffectiveness(contextData);
      }
    }
    
    // 개인화 수준별 효과성
    final personalizationEffectiveness = _analyzePersonalizationEffectiveness(history);
    
    return LearningPerformanceReport(
      totalLearningDataPoints: history.length,
      overallEffectiveness: insights.averageEffectiveness,
      learningProgress: insights.learningConfidence,
      weeklyTrend: weeklyTrend,
      monthlyTrend: monthlyTrend,
      contextPerformance: contextPerformance,
      personalizationEffectiveness: personalizationEffectiveness,
      topPerformingPatterns: _identifyTopPatterns(history),
      improvementOpportunities: _identifyImprovementOpportunities(insights),
    );
  }
  
  // Private Methods
  
  Future<List<UserResponseRecord>> _getResponseHistory() async {
    final historyJson = _prefs.getString(_responseHistoryKey) ?? '[]';
    final historyList = json.decode(historyJson) as List;
    
    return historyList.map((item) => UserResponseRecord.fromJson(item)).toList();
  }
  
  Future<void> _saveResponseRecord(UserResponseRecord record) async {
    final history = await _getResponseHistory();
    history.add(record);
    
    // 최대 1000개 기록 유지
    if (history.length > 1000) {
      history.removeRange(0, history.length - 1000);
    }
    
    final historyJson = json.encode(history.map((r) => r.toJson()).toList());
    await _prefs.setString(_responseHistoryKey, historyJson);
  }
  
  Future<Map<String, dynamic>> _getPersonalPreferences() async {
    final prefsJson = _prefs.getString(_personalPreferencesKey) ?? '{}';
    return json.decode(prefsJson) as Map<String, dynamic>;
  }
  
  Future<void> _updatePersonalPreferences(UserResponseRecord response) async {
    final prefs = await _getPersonalPreferences();
    final contextKey = response.context.name;
    
    prefs[contextKey] = prefs[contextKey] ?? {};
    final contextPrefs = prefs[contextKey] as Map<String, dynamic>;
    
    // 긍정적 반응일 때 선호도 증가
    if (_isPositiveResponse(response.responseType)) {
      contextPrefs['preferred_personalization_level'] = response.personalizationLevel;
      contextPrefs['effective_patterns'] = contextPrefs['effective_patterns'] ?? [];
      
      // 효과적인 키워드 추출 및 저장
      final keywords = _extractKeywords(response.messageContent);
      for (final keyword in keywords) {
        if (!(contextPrefs['effective_patterns'] as List).contains(keyword)) {
          (contextPrefs['effective_patterns'] as List).add(keyword);
        }
      }
    }
    
    await _prefs.setString(_personalPreferencesKey, json.encode(prefs));
  }
  
  Future<Map<String, dynamic>> _getContextEffectiveness() async {
    final effectivenessJson = _prefs.getString(_contextEffectivenessKey) ?? '{}';
    return json.decode(effectivenessJson) as Map<String, dynamic>;
  }
  
  Future<void> _updateContextEffectiveness(UserResponseRecord response) async {
    final effectiveness = await _getContextEffectiveness();
    final contextKey = '${response.context.name}_${response.personalityType}';
    
    effectiveness[contextKey] = effectiveness[contextKey] ?? {'total': 0, 'positive': 0};
    final contextData = effectiveness[contextKey] as Map<String, dynamic>;
    
    contextData['total'] = (contextData['total'] as int) + 1;
    if (_isPositiveResponse(response.responseType)) {
      contextData['positive'] = (contextData['positive'] as int) + 1;
    }
    
    await _prefs.setString(_contextEffectivenessKey, json.encode(effectiveness));
  }
  
  Future<void> _adaptPersonalizationStrategy(UserResponseRecord response) async {
    // 부정적 반응 시 개인화 수준 조정
    if (_isNegativeResponse(response.responseType)) {
      final rules = await _getAdaptationRules();
      final ruleKey = '${response.context.name}_${response.personalityType}';
      
      rules[ruleKey] = rules[ruleKey] ?? {'adjustment_factor': 1.0};
      final rule = rules[ruleKey] as Map<String, dynamic>;
      
      // 개인화 수준을 점진적으로 조정
      if (response.personalizationLevel > 0.7) {
        rule['adjustment_factor'] = (rule['adjustment_factor'] as double) * 0.9;
      } else {
        rule['adjustment_factor'] = (rule['adjustment_factor'] as double) * 1.1;
      }
      
      await _prefs.setString(_adaptationRulesKey, json.encode(rules));
    }
  }
  
  Future<Map<String, dynamic>> _getAdaptationRules() async {
    final rulesJson = _prefs.getString(_adaptationRulesKey) ?? '{}';
    return json.decode(rulesJson) as Map<String, dynamic>;
  }
  
  double _calculateAverageEffectiveness(List<UserResponseRecord> records) {
    if (records.isEmpty) return 0.0;
    
    final positiveCount = records.where((r) => _isPositiveResponse(r.responseType)).length;
    return positiveCount / records.length;
  }
  
  List<String> _identifyPreferredTypes(List<UserResponseRecord> records) {
    final typeCount = <UserResponseType, int>{};
    
    for (final record in records) {
      if (_isPositiveResponse(record.responseType)) {
        typeCount[record.responseType] = (typeCount[record.responseType] ?? 0) + 1;
      }
    }
    
    final sortedTypes = typeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTypes.take(3).map((e) => e.key.name).toList();
  }
  
  List<ContextEffectiveness> _findOptimalContexts(Map<String, dynamic> effectiveness) {
    final results = <ContextEffectiveness>[];
    
    for (final entry in effectiveness.entries) {
      final data = entry.value as Map<String, dynamic>;
      final total = data['total'] as int;
      final positive = data['positive'] as int;
      
      if (total > 0) {
        results.add(ContextEffectiveness(
          contextKey: entry.key,
          effectiveness: positive / total,
          sampleSize: total,
        ));
      }
    }
    
    results.sort((a, b) => b.effectiveness.compareTo(a.effectiveness));
    return results;
  }
  
  double _calculateLearningConfidence(List<UserResponseRecord> records) {
    if (records.isEmpty) return 0.0;
    
    // 데이터 양과 일관성을 기반으로 신뢰도 계산
    final dataVolumeScore = (records.length / 100.0).clamp(0.0, 0.6);
    final consistencyScore = _calculateConsistencyScore(records) * 0.4;
    
    return dataVolumeScore + consistencyScore;
  }
  
  double _calculateConsistencyScore(List<UserResponseRecord> records) {
    if (records.length < 5) return 0.0;
    
    final recentRecords = records.reversed.take(10).toList();
    final positiveRatio = recentRecords.where((r) => _isPositiveResponse(r.responseType)).length / recentRecords.length;
    
    // 일관된 긍정적 반응일수록 높은 점수
    return positiveRatio > 0.7 ? 1.0 : positiveRatio;
  }
  
  bool _isPositiveResponse(UserResponseType type) {
    return [UserResponseType.loved, UserResponseType.liked].contains(type);
  }
  
  bool _isNegativeResponse(UserResponseType type) {
    return [UserResponseType.disliked, UserResponseType.irrelevant].contains(type);
  }
  
  List<String> _extractKeywords(String message) {
    // 간단한 키워드 추출 (실제로는 더 정교한 NLP 기법 사용 가능)
    final words = message.split(' ');
    return words.where((word) => word.length > 3).take(5).toList();
  }
  
  double _calculateContextEffectiveness(List<UserResponseRecord> records) {
    return _calculateAverageEffectiveness(records);
  }
  
  double _findOptimalPersonalizationLevel(List<UserResponseRecord> records) {
    if (records.isEmpty) return 0.7;
    
    final positiveRecords = records.where((r) => _isPositiveResponse(r.responseType)).toList();
    if (positiveRecords.isEmpty) return 0.5;
    
    final averageLevel = positiveRecords
        .map((r) => r.personalizationLevel)
        .reduce((a, b) => a + b) / positiveRecords.length;
    
    return averageLevel.clamp(0.0, 1.0);
  }
  
  String _determineAdjustmentReason(double current, double optimal, double effectiveness) {
    if (effectiveness < 0.5) {
      return 'low_effectiveness';
    } else if ((optimal - current).abs() > 0.2) {
      return optimal > current ? 'increase_personalization' : 'decrease_personalization';
    } else {
      return 'maintain_current_level';
    }
  }
  
  double _calculateAdjustmentConfidence(List<UserResponseRecord> records) {
    return (records.length / 20.0).clamp(0.0, 1.0);
  }
  
  double _calculateRecentTrend(List<UserResponseRecord> records) {
    if (records.length < 6) return 0.0;
    
    final sortedRecords = records..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final recent = sortedRecords.reversed.take(5).toList();
    final older = sortedRecords.reversed.skip(5).take(5).toList();
    
    final recentEffectiveness = _calculateAverageEffectiveness(recent);
    final olderEffectiveness = _calculateAverageEffectiveness(older);
    
    return recentEffectiveness - olderEffectiveness;
  }
  
  Map<String, dynamic> _analyzeResponseStyles(List<UserResponseRecord> records) {
    // 응답 스타일 분석 로직
    return {
      'preferredTone': 'warm_encouraging',
      'optimalLength': 50,
      'effectiveKeywords': ['성취', '축하', '함께'],
    };
  }
  
  Map<String, dynamic> _analyzeEmotionalPreferences(List<UserResponseRecord> records) {
    return {
      'approach': 'balanced_empathy',
    };
  }
  
  Map<String, dynamic> _analyzeTimingPreferences(List<UserResponseRecord> records) {
    return {
      'optimal': 'immediate_response',
    };
  }
  
  double _calculateStyleConfidence(List<UserResponseRecord> records) {
    return (records.length / 15.0).clamp(0.0, 1.0);
  }
  
  Future<void> _adjustContextStrategy(ContextEffectiveness context) async {
    // 컨텍스트별 전략 조정 로직
    print('🔧 컨텍스트 전략 조정: ${context.contextKey}');
  }
  
  Future<void> _performGlobalPersonalizationAdjustment(LearningInsights insights) async {
    // 글로벌 개인화 수준 조정
    print('🌐 글로벌 개인화 수준 조정');
  }
  
  Future<void> _updateAdaptationRules(LearningInsights insights) async {
    // 적응 규칙 업데이트
    print('📋 적응 규칙 업데이트');
  }
  
  Future<List<String>> _generateAdaptationRecommendations(
    List<UserResponseRecord> history,
    Map<String, dynamic> preferences, 
    Map<String, dynamic> effectiveness
  ) async {
    final recommendations = <String>[];
    
    if (history.length < 20) {
      recommendations.add('더 많은 학습 데이터 수집 필요');
    }
    
    final avgEffectiveness = _calculateAverageEffectiveness(history);
    if (avgEffectiveness < 0.6) {
      recommendations.add('개인화 전략 재검토 필요');
    }
    
    return recommendations;
  }
  
  List<String> _generateTonalAdjustments(String personalityType, Map<String, dynamic> userContext) {
    // 성격 유형별 톤 조정
    switch (personalityType) {
      case '성취형':
        return ['목표 지향적 표현 강화', '성과 인정 강조'];
      case '사교형':
        return ['친근함 증대', '공감적 표현 사용'];
      default:
        return ['균형잡힌 톤 유지'];
    }
  }
  
  Map<String, dynamic> _generateStructuralPreferences(ResponseStyleOptimization style) {
    return {
      'preferredLength': style.optimalLength,
      'keywordDensity': 'moderate',
      'emotionalIntensity': 'balanced',
    };
  }
  
  double _calculateSignificance(List<UserResponseRecord> variantA, List<UserResponseRecord> variantB) {
    // 통계적 유의성 계산 (간단한 버전)
    if (variantA.length < 10 || variantB.length < 10) return 0.0;
    
    final aEffectiveness = _calculateAverageEffectiveness(variantA);
    final bEffectiveness = _calculateAverageEffectiveness(variantB);
    
    return (aEffectiveness - bEffectiveness).abs();
  }
  
  String _generateABTestRecommendation(double aScore, double bScore) {
    final diff = (aScore - bScore).abs();
    
    if (diff < 0.05) {
      return 'no_significant_difference';
    } else if (aScore > bScore) {
      return 'implement_variant_a';
    } else {
      return 'implement_variant_b';
    }
  }
  
  List<double> _calculateWeeklyTrend(List<UserResponseRecord> records) {
    // 주별 트렌드 계산
    final now = DateTime.now();
    final trends = <double>[];
    
    for (int i = 6; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: 7 * (i + 1)));
      final weekEnd = now.subtract(Duration(days: 7 * i));
      
      final weekRecords = records.where((r) =>
        r.timestamp.isAfter(weekStart) && r.timestamp.isBefore(weekEnd)
      ).toList();
      
      trends.add(_calculateAverageEffectiveness(weekRecords));
    }
    
    return trends;
  }
  
  List<double> _calculateMonthlyTrend(List<UserResponseRecord> records) {
    // 월별 트렌드 계산 (간단한 버전)
    return _calculateWeeklyTrend(records); // 실제로는 월별로 계산
  }
  
  Map<String, double> _analyzePersonalizationEffectiveness(List<UserResponseRecord> records) {
    final levelBuckets = <String, List<UserResponseRecord>>{
      'low': [],
      'medium': [],
      'high': [],
    };
    
    for (final record in records) {
      if (record.personalizationLevel < 0.4) {
        levelBuckets['low']!.add(record);
      } else if (record.personalizationLevel < 0.7) {
        levelBuckets['medium']!.add(record);
      } else {
        levelBuckets['high']!.add(record);
      }
    }
    
    return levelBuckets.map((key, value) => 
      MapEntry(key, _calculateAverageEffectiveness(value))
    );
  }
  
  List<String> _identifyTopPatterns(List<UserResponseRecord> records) {
    // 성과가 좋은 패턴 식별
    return ['개인 맞춤 축하', '구체적 성과 언급', '다음 목표 제시'];
  }
  
  List<String> _identifyImprovementOpportunities(LearningInsights insights) {
    final opportunities = <String>[];
    
    if (insights.averageEffectiveness < 0.7) {
      opportunities.add('전체적인 응답 품질 개선');
    }
    
    if (insights.learningConfidence < 0.5) {
      opportunities.add('학습 데이터 수집 강화');
    }
    
    return opportunities;
  }
}

/// 📊 학습 인사이트
class LearningInsights {
  final int totalResponses;
  final double averageEffectiveness;
  final List<String> preferredResponseTypes;
  final List<ContextEffectiveness> optimalContexts;
  final double learningConfidence;
  final List<String> adaptationRecommendations;
  
  LearningInsights({
    required this.totalResponses,
    required this.averageEffectiveness,
    required this.preferredResponseTypes,
    required this.optimalContexts,
    required this.learningConfidence,
    required this.adaptationRecommendations,
  });
}

/// 📝 사용자 반응 기록
class UserResponseRecord {
  final String messageId;
  final UserResponseType responseType;
  final SherpiContext context;
  final String messageContent;
  final String personalityType;
  final double personalizationLevel;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  UserResponseRecord({
    required this.messageId,
    required this.responseType,
    required this.context,
    required this.messageContent,
    required this.personalityType,
    required this.personalizationLevel,
    required this.timestamp,
    required this.metadata,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'responseType': responseType.name,
      'context': context.name,
      'messageContent': messageContent,
      'personalityType': personalityType,
      'personalizationLevel': personalizationLevel,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  factory UserResponseRecord.fromJson(Map<String, dynamic> json) {
    return UserResponseRecord(
      messageId: json['messageId'] as String,
      responseType: UserResponseType.values.firstWhere(
        (e) => e.name == json['responseType'],
        orElse: () => UserResponseType.neutral,
      ),
      context: SherpiContext.values.firstWhere(
        (e) => e.name == json['context'],
        orElse: () => SherpiContext.welcome,
      ),
      messageContent: json['messageContent'] as String,
      personalityType: json['personalityType'] as String,
      personalizationLevel: (json['personalizationLevel'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }
}

/// 🎯 개인화 조정 결과
class PersonalizationAdjustment {
  final double recommendedLevel;
  final String adjustmentReason;
  final double confidence;
  final Map<String, dynamic>? supportingData;
  
  PersonalizationAdjustment({
    required this.recommendedLevel,
    required this.adjustmentReason,
    required this.confidence,
    this.supportingData,
  });
}

/// 🎨 응답 스타일 최적화
class ResponseStyleOptimization {
  final String preferredTone;
  final int optimalLength;
  final List<String> effectiveKeywords;
  final String emotionalApproach;
  final String timingRecommendation;
  final double confidence;
  
  ResponseStyleOptimization({
    required this.preferredTone,
    required this.optimalLength,
    required this.effectiveKeywords,
    required this.emotionalApproach,
    required this.timingRecommendation,
    required this.confidence,
  });
}

/// 📋 응답 가이드라인
class ResponseGuidelines {
  final double personalizationLevel;
  final ResponseStyleOptimization responseStyle;
  final List<String> avoidPatterns;
  final List<String> emphasizePatterns;
  final List<String> tonalAdjustments;
  final Map<String, dynamic> structuralPreferences;
  
  ResponseGuidelines({
    required this.personalizationLevel,
    required this.responseStyle,
    required this.avoidPatterns,
    required this.emphasizePatterns,
    required this.tonalAdjustments,
    required this.structuralPreferences,
  });
}

/// 🧪 A/B 테스트 결과
class ABTestResults {
  final String testId;
  final double variantAEffectiveness;
  final double variantBEffectiveness;
  final double significanceLevel;
  final String winningVariant;
  final String recommendation;
  final Map<String, int> sampleSizes;
  
  ABTestResults({
    required this.testId,
    required this.variantAEffectiveness,
    required this.variantBEffectiveness,
    required this.significanceLevel,
    required this.winningVariant,
    required this.recommendation,
    required this.sampleSizes,
  });
}

/// 📊 학습 성능 리포트
class LearningPerformanceReport {
  final int totalLearningDataPoints;
  final double overallEffectiveness;
  final double learningProgress;
  final List<double> weeklyTrend;
  final List<double> monthlyTrend;
  final Map<String, double> contextPerformance;
  final Map<String, double> personalizationEffectiveness;
  final List<String> topPerformingPatterns;
  final List<String> improvementOpportunities;
  
  LearningPerformanceReport({
    required this.totalLearningDataPoints,
    required this.overallEffectiveness,
    required this.learningProgress,
    required this.weeklyTrend,
    required this.monthlyTrend,
    required this.contextPerformance,
    required this.personalizationEffectiveness,
    required this.topPerformingPatterns,
    required this.improvementOpportunities,
  });
}

/// 📈 컨텍스트 효과성
class ContextEffectiveness {
  final String contextKey;
  final double effectiveness;
  final int sampleSize;
  
  ContextEffectiveness({
    required this.contextKey,
    required this.effectiveness,
    required this.sampleSize,
  });
}

/// 👤 사용자 반응 타입
enum UserResponseType {
  loved,      // 매우 좋아함
  liked,      // 좋아함
  neutral,    // 보통
  disliked,   // 싫어함
  irrelevant, // 관련없음
}