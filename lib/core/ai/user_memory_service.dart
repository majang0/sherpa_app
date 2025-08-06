import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/personalized_sherpi_manager.dart';

/// 🧠 사용자 메모리 서비스
/// 
/// 사용자의 성공 패턴을 학습하고 선호도를 저장하여 
/// 더욱 정확하고 효과적인 개인화된 AI 응답을 제공합니다.
class UserMemoryService {
  final SharedPreferences _prefs;
  
  // 저장 키 상수
  static const String _keySuccessPatterns = 'sherpi_success_patterns';
  static const String _keyUserPreferences = 'sherpi_user_preferences';
  static const String _keyMessageEffectiveness = 'sherpi_message_effectiveness';
  static const String _keyInteractionHistory = 'sherpi_interaction_history';
  static const String _keyPersonalityInsights = 'sherpi_personality_insights';
  static const String _keyContextualPreferences = 'sherpi_contextual_preferences';
  
  // 메모리 캐시
  Map<String, UserSuccessPattern>? _cachedSuccessPatterns;
  UserPreferences? _cachedPreferences;
  Map<String, MessageEffectiveness>? _cachedEffectiveness;
  List<InteractionMemory>? _cachedInteractions;
  PersonalityInsights? _cachedPersonalityInsights;
  Map<String, ContextualPreference>? _cachedContextualPreferences;
  
  UserMemoryService(this._prefs);
  
  /// 🎯 성공 패턴 학습 및 저장
  Future<void> recordSuccessPattern({
    required SherpiContext context,
    required String activityType,
    required Map<String, dynamic> conditions,
    required bool wasSuccessful,
    required Map<String, dynamic> userResponse,
    String? messageContent,
    UserFeedbackType? feedback,
  }) async {
    try {
      final patterns = await getSuccessPatterns();
      final patternKey = '${context.name}_$activityType';
      
      // 기존 패턴 가져오기 또는 새로 생성
      var pattern = patterns[patternKey] ?? UserSuccessPattern(
        contextType: context,
        activityType: activityType,
        successfulConditions: {},
        failureConditions: {},
        totalAttempts: 0,
        successfulAttempts: 0,
        lastUpdated: DateTime.now(),
        confidenceScore: 0.0,
        effectiveMessageTypes: {},
        preferredTones: {},
      );
      
      // 패턴 업데이트
      pattern = pattern.copyWith(
        totalAttempts: pattern.totalAttempts + 1,
        successfulAttempts: wasSuccessful 
            ? pattern.successfulAttempts + 1 
            : pattern.successfulAttempts,
        lastUpdated: DateTime.now(),
      );
      
      // 조건 분석 및 저장
      if (wasSuccessful) {
        pattern = _updateSuccessfulConditions(pattern, conditions);
        if (messageContent != null && feedback != null) {
          pattern = _updateEffectiveMessages(pattern, messageContent, feedback);
        }
      } else {
        pattern = _updateFailureConditions(pattern, conditions);
      }
      
      // 신뢰도 점수 계산
      pattern = _calculateConfidenceScore(pattern);
      
      // 저장
      patterns[patternKey] = pattern;
      await _saveSuccessPatterns(patterns);
      
      print('🧠 성공 패턴 학습: $patternKey (성공률: ${(pattern.successRate * 100).toInt()}%)');
      
    } catch (e) {
      print('🧠 성공 패턴 기록 실패: $e');
    }
  }
  
  /// 💡 사용자 선호도 학습
  Future<void> recordUserPreference({
    required String preferenceType, // 'tone', 'length', 'timing', 'emoji_usage'
    required String value,
    required SherpiContext context,
    required UserFeedbackType feedback,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final preferences = await getUserPreferences();
      
      // 선호도 점수 계산 (피드백 기반)
      double score = _calculatePreferenceScore(feedback);
      
      // 컨텍스트별 선호도 업데이트
      final contextKey = context.name;
      final contextPrefs = preferences.contextualPreferences[contextKey] ?? {};
      final typePrefs = contextPrefs[preferenceType] ?? <String, double>{};
      
      // 기존 점수와 새 점수의 가중 평균 계산
      final existingScore = typePrefs[value] ?? 0.0;
      final existingCount = preferences.interactionCounts[contextKey]?[preferenceType]?[value] ?? 0;
      final newScore = (existingScore * existingCount + score) / (existingCount + 1);
      
      typePrefs[value] = newScore;
      contextPrefs[preferenceType] = typePrefs;
      preferences.contextualPreferences[contextKey] = contextPrefs;
      
      // 상호작용 카운트 업데이트
      preferences.interactionCounts[contextKey] ??= {};
      preferences.interactionCounts[contextKey]![preferenceType] ??= {};
      preferences.interactionCounts[contextKey]![preferenceType]![value] = existingCount + 1;
      
      // 전체 선호도 업데이트
      preferences.overallPreferences[preferenceType] ??= {};
      final overallExisting = preferences.overallPreferences[preferenceType]![value] ?? 0.0;
      final overallCount = preferences.totalInteractions[preferenceType]?[value] ?? 0;
      preferences.overallPreferences[preferenceType]![value] = 
          (overallExisting * overallCount + score) / (overallCount + 1);
      
      preferences.totalInteractions[preferenceType] ??= {};
      preferences.totalInteractions[preferenceType]![value] = overallCount + 1;
      
      preferences.lastUpdated = DateTime.now();
      
      await _saveUserPreferences(preferences);
      
      print('💡 사용자 선호도 학습: $preferenceType=$value (점수: ${newScore.toStringAsFixed(2)})');
      
    } catch (e) {
      print('💡 사용자 선호도 기록 실패: $e');
    }
  }
  
  /// 📊 메시지 효과성 추적
  Future<void> recordMessageEffectiveness({
    required String messageId,
    required SherpiContext context,
    required String messageContent,
    required String messageSource, // 'static', 'cached_ai', 'realtime_ai'
    required UserFeedbackType feedback,
    required Duration responseTime,
    Map<String, dynamic>? personalizationData,
  }) async {
    try {
      final effectiveness = await getMessageEffectiveness();
      
      final record = MessageEffectiveness(
        messageId: messageId,
        context: context,
        messageContent: messageContent,
        messageSource: messageSource,
        feedback: feedback,
        responseTime: responseTime,
        timestamp: DateTime.now(),
        personalizationLevel: personalizationData?['level'] as String? ?? 'low',
        personalityType: personalizationData?['personalityType'] as String?,
        effectivenessScore: _calculateEffectivenessScore(feedback, responseTime),
        userEngagement: _calculateEngagementScore(feedback),
        contextualRelevance: personalizationData?['contextualRelevance'] as double? ?? 0.5,
      );
      
      effectiveness[messageId] = record;
      
      // 최대 1000개 기록 유지
      if (effectiveness.length > 1000) {
        final oldestKey = effectiveness.keys
            .reduce((a, b) => effectiveness[a]!.timestamp.isBefore(effectiveness[b]!.timestamp) ? a : b);
        effectiveness.remove(oldestKey);
      }
      
      await _saveMessageEffectiveness(effectiveness);
      
      print('📊 메시지 효과성 기록: ${record.effectivenessScore.toStringAsFixed(2)} (${feedback.name})');
      
    } catch (e) {
      print('📊 메시지 효과성 기록 실패: $e');
    }
  }
  
  /// 🔍 최적의 조건 예측
  Future<Map<String, dynamic>> predictOptimalConditions({
    required SherpiContext context,
    required String activityType,
    required Map<String, dynamic> currentConditions,
  }) async {
    try {
      final patterns = await getSuccessPatterns();
      final patternKey = '${context.name}_$activityType';
      final pattern = patterns[patternKey];
      
      if (pattern == null || pattern.confidenceScore < 0.3) {
        return {'confidence': 0.0, 'recommendations': <String>[]};
      }
      
      final recommendations = <String>[];
      double totalConfidence = pattern.confidenceScore;
      
      // 성공 조건 분석
      pattern.successfulConditions.forEach((key, conditions) {
        conditions.forEach((condition, frequency) {
          if (frequency > pattern.totalAttempts * 0.6) { // 60% 이상 성공률
            recommendations.add('$key: $condition 조건이 효과적입니다');
          }
        });
      });
      
      // 실패 조건 회피 제안
      pattern.failureConditions.forEach((key, conditions) {
        conditions.forEach((condition, frequency) {
          if (frequency > pattern.totalAttempts * 0.4) { // 40% 이상 실패율
            if (currentConditions[key] == condition) {
              recommendations.add('$key: $condition 조건은 피하는 것이 좋습니다');
              totalConfidence *= 0.8; // 현재 조건이 위험하면 신뢰도 감소
            }
          }
        });
      });
      
      // 효과적인 메시지 타입 추천
      if (pattern.effectiveMessageTypes.isNotEmpty) {
        final bestMessageType = pattern.effectiveMessageTypes.entries
            .reduce((a, b) => a.value > b.value ? a : b);
        recommendations.add('메시지 타입: ${bestMessageType.key}가 가장 효과적입니다');
      }
      
      return {
        'confidence': totalConfidence,
        'recommendations': recommendations,
        'successRate': pattern.successRate,
        'optimalConditions': _extractOptimalConditions(pattern),
      };
      
    } catch (e) {
      print('🔍 최적 조건 예측 실패: $e');
      return {'confidence': 0.0, 'recommendations': <String>[]};
    }
  }
  
  /// 💎 개인화 인사이트 생성
  Future<Map<String, dynamic>> generatePersonalizationInsights() async {
    try {
      final preferences = await getUserPreferences();
      final patterns = await getSuccessPatterns();
      final effectiveness = await getMessageEffectiveness();
      
      // 성격 특성 분석
      final personalityTraits = _analyzePersonalityTraits(preferences, patterns);
      
      // 최적 타이밍 분석
      final optimalTimings = _analyzeOptimalTimings(patterns);
      
      // 선호 커뮤니케이션 스타일
      final preferredStyles = _analyzePreferredStyles(preferences, effectiveness);
      
      // 동기부여 패턴 분석
      final motivationPatterns = _analyzeMotivationPatterns(patterns, effectiveness);
      
      // 종합 인사이트
      final insights = PersonalityInsights(
        dominantPersonalityTraits: personalityTraits,
        optimalInteractionTimings: optimalTimings,
        preferredCommunicationStyles: preferredStyles,
        effectiveMotivationTriggers: motivationPatterns,
        overallEngagementScore: _calculateOverallEngagement(effectiveness),
        personalityConfidence: _calculatePersonalityConfidence(preferences, patterns),
        lastAnalyzed: DateTime.now(),
        dataRichness: _calculateDataRichness(preferences, patterns, effectiveness),
        improvementSuggestions: _generateImprovementSuggestions(preferences, patterns, effectiveness),
      );
      
      // 캐시 및 저장
      _cachedPersonalityInsights = insights;
      await _savePersonalityInsights(insights);
      
      return insights.toJson();
      
    } catch (e) {
      print('💎 개인화 인사이트 생성 실패: $e');
      return {};
    }
  }
  
  /// 📈 상호작용 기록 저장
  Future<void> recordInteraction({
    required SherpiContext context,
    required String messageContent,
    required String messageSource,
    required Duration responseTime,
    UserFeedbackType? feedback,
    Map<String, dynamic>? contextData,
  }) async {
    try {
      final interactions = await getInteractionHistory();
      
      final interaction = InteractionMemory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        context: context,
        messageContent: messageContent,
        messageSource: messageSource,
        responseTime: responseTime,
        feedback: feedback,
        timestamp: DateTime.now(),
        contextData: contextData ?? {},
        userSatisfaction: feedback != null ? _calculateSatisfactionScore(feedback) : null,
        sessionId: _getCurrentSessionId(),
      );
      
      interactions.add(interaction);
      
      // 최대 500개 상호작용 유지
      if (interactions.length > 500) {
        interactions.removeAt(0);
      }
      
      await _saveInteractionHistory(interactions);
      
      print('📈 상호작용 기록 저장: ${context.name}');
      
    } catch (e) {
      print('📈 상호작용 기록 실패: $e');
    }
  }
  
  /// 🎯 컨텍스트별 선호도 분석
  Future<ContextualPreference?> getContextualPreference(SherpiContext context) async {
    try {
      final preferences = await getContextualPreferences();
      return preferences[context.name];
    } catch (e) {
      print('🎯 컨텍스트별 선호도 조회 실패: $e');
      return null;
    }
  }
  
  /// 📊 학습 통계 조회
  Future<Map<String, dynamic>> getLearningStatistics() async {
    try {
      final patterns = await getSuccessPatterns();
      final preferences = await getUserPreferences();
      final effectiveness = await getMessageEffectiveness();
      final interactions = await getInteractionHistory();
      
      // 기본 통계
      final totalPatterns = patterns.length;
      final totalInteractions = interactions.length;
      final averageSuccessRate = patterns.values.isEmpty ? 0.0 :
          patterns.values.map((p) => p.successRate).reduce((a, b) => a + b) / patterns.length;
      
      // 효과성 통계
      final effectivenessValues = effectiveness.values.toList();
      final averageEffectiveness = effectivenessValues.isEmpty ? 0.0 :
          effectivenessValues.map((e) => e.effectivenessScore).reduce((a, b) => a + b) / effectivenessValues.length;
      
      // 최근 성과 (지난 7일)
      final recentInteractions = interactions.where(
        (i) => i.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).toList();
      
      final recentSatisfaction = recentInteractions.where((i) => i.userSatisfaction != null).toList();
      final averageRecentSatisfaction = recentSatisfaction.isEmpty ? 0.0 :
          recentSatisfaction.map((i) => i.userSatisfaction!).reduce((a, b) => a + b) / recentSatisfaction.length;
      
      return {
        'totalPatterns': totalPatterns,
        'totalInteractions': totalInteractions,
        'averageSuccessRate': averageSuccessRate,
        'averageEffectiveness': averageEffectiveness,
        'recentInteractionsCount': recentInteractions.length,
        'averageRecentSatisfaction': averageRecentSatisfaction,
        'dataRichness': _calculateDataRichness(preferences, patterns, effectiveness),
        'learningProgress': _calculateLearningProgress(patterns, effectiveness),
        'topSuccessfulContexts': _getTopSuccessfulContexts(patterns),
        'preferredMessageSources': _getPreferredMessageSources(effectiveness),
        'personalityConfidence': _calculatePersonalityConfidence(preferences, patterns),
      };
      
    } catch (e) {
      print('📊 학습 통계 조회 실패: $e');
      return {};
    }
  }
  
  // ==================== Getter 메서드들 ====================
  
  Future<Map<String, UserSuccessPattern>> getSuccessPatterns() async {
    if (_cachedSuccessPatterns != null) return _cachedSuccessPatterns!;
    
    try {
      final jsonString = _prefs.getString(_keySuccessPatterns);
      if (jsonString == null) return {};
      
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final patterns = <String, UserSuccessPattern>{};
      
      jsonData.forEach((key, value) {
        patterns[key] = UserSuccessPattern.fromJson(value);
      });
      
      _cachedSuccessPatterns = patterns;
      return patterns;
    } catch (e) {
      print('🧠 성공 패턴 로드 실패: $e');
      return {};
    }
  }
  
  Future<UserPreferences> getUserPreferences() async {
    if (_cachedPreferences != null) return _cachedPreferences!;
    
    try {
      final jsonString = _prefs.getString(_keyUserPreferences);
      if (jsonString == null) {
        final defaultPrefs = UserPreferences.createDefault();
        _cachedPreferences = defaultPrefs;
        return defaultPrefs;
      }
      
      final preferences = UserPreferences.fromJson(jsonDecode(jsonString));
      _cachedPreferences = preferences;
      return preferences;
    } catch (e) {
      print('💡 사용자 선호도 로드 실패: $e');
      final defaultPrefs = UserPreferences.createDefault();
      _cachedPreferences = defaultPrefs;
      return defaultPrefs;
    }
  }
  
  Future<Map<String, MessageEffectiveness>> getMessageEffectiveness() async {
    if (_cachedEffectiveness != null) return _cachedEffectiveness!;
    
    try {
      final jsonString = _prefs.getString(_keyMessageEffectiveness);
      if (jsonString == null) return {};
      
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final effectiveness = <String, MessageEffectiveness>{};
      
      jsonData.forEach((key, value) {
        effectiveness[key] = MessageEffectiveness.fromJson(value);
      });
      
      _cachedEffectiveness = effectiveness;
      return effectiveness;
    } catch (e) {
      print('📊 메시지 효과성 로드 실패: $e');
      return {};
    }
  }
  
  Future<List<InteractionMemory>> getInteractionHistory() async {
    if (_cachedInteractions != null) return _cachedInteractions!;
    
    try {
      final jsonString = _prefs.getString(_keyInteractionHistory);
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final interactions = jsonList.map((json) => InteractionMemory.fromJson(json)).toList();
      
      _cachedInteractions = interactions;
      return interactions;
    } catch (e) {
      print('📈 상호작용 기록 로드 실패: $e');
      return [];
    }
  }
  
  Future<Map<String, ContextualPreference>> getContextualPreferences() async {
    if (_cachedContextualPreferences != null) return _cachedContextualPreferences!;
    
    try {
      final jsonString = _prefs.getString(_keyContextualPreferences);
      if (jsonString == null) return {};
      
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final preferences = <String, ContextualPreference>{};
      
      jsonData.forEach((key, value) {
        preferences[key] = ContextualPreference.fromJson(value);
      });
      
      _cachedContextualPreferences = preferences;
      return preferences;
    } catch (e) {
      print('🎯 컨텍스트별 선호도 로드 실패: $e');
      return {};
    }
  }
  
  // ==================== Private 헬퍼 메서드들 ====================
  
  UserSuccessPattern _updateSuccessfulConditions(UserSuccessPattern pattern, Map<String, dynamic> conditions) {
    final successfulConditions = Map<String, Map<String, int>>.from(pattern.successfulConditions);
    
    conditions.forEach((key, value) {
      final valueStr = value.toString();
      successfulConditions[key] ??= {};
      successfulConditions[key]![valueStr] = (successfulConditions[key]![valueStr] ?? 0) + 1;
    });
    
    return pattern.copyWith(successfulConditions: successfulConditions);
  }
  
  UserSuccessPattern _updateFailureConditions(UserSuccessPattern pattern, Map<String, dynamic> conditions) {
    final failureConditions = Map<String, Map<String, int>>.from(pattern.failureConditions);
    
    conditions.forEach((key, value) {
      final valueStr = value.toString();
      failureConditions[key] ??= {};
      failureConditions[key]![valueStr] = (failureConditions[key]![valueStr] ?? 0) + 1;
    });
    
    return pattern.copyWith(failureConditions: failureConditions);
  }
  
  UserSuccessPattern _updateEffectiveMessages(UserSuccessPattern pattern, String messageContent, UserFeedbackType feedback) {
    final effectiveMessages = Map<String, double>.from(pattern.effectiveMessageTypes);
    final messageType = _classifyMessageType(messageContent);
    final score = _calculatePreferenceScore(feedback);
    
    effectiveMessages[messageType] = (effectiveMessages[messageType] ?? 0.0) + score;
    
    return pattern.copyWith(effectiveMessageTypes: effectiveMessages);
  }
  
  UserSuccessPattern _calculateConfidenceScore(UserSuccessPattern pattern) {
    if (pattern.totalAttempts < 3) {
      return pattern.copyWith(confidenceScore: 0.0);
    }
    
    final baseConfidence = pattern.successRate;
    final dataConfidence = (pattern.totalAttempts / 50.0).clamp(0.0, 1.0); // 50번 시도 시 100% 데이터 신뢰도
    final overallConfidence = (baseConfidence * 0.7 + dataConfidence * 0.3);
    
    return pattern.copyWith(confidenceScore: overallConfidence);
  }
  
  double _calculatePreferenceScore(UserFeedbackType feedback) {
    switch (feedback) {
      case UserFeedbackType.loved:
        return 1.0;
      case UserFeedbackType.liked:
        return 0.7;
      case UserFeedbackType.neutral:
        return 0.4;
      case UserFeedbackType.disliked:
        return 0.1;
      case UserFeedbackType.irrelevant:
        return 0.0;
    }
  }
  
  double _calculateEffectivenessScore(UserFeedbackType feedback, Duration responseTime) {
    final feedbackScore = _calculatePreferenceScore(feedback);
    final timeScore = responseTime.inMilliseconds < 2000 ? 1.0 : 
                     responseTime.inMilliseconds < 5000 ? 0.8 : 0.5;
    
    return feedbackScore * 0.8 + timeScore * 0.2;
  }
  
  double _calculateEngagementScore(UserFeedbackType feedback) {
    switch (feedback) {
      case UserFeedbackType.loved:
        return 1.0;
      case UserFeedbackType.liked:
        return 0.8;
      case UserFeedbackType.neutral:
        return 0.5;
      case UserFeedbackType.disliked:
        return 0.2;
      case UserFeedbackType.irrelevant:
        return 0.0;
    }
  }
  
  double _calculateSatisfactionScore(UserFeedbackType feedback) {
    return _calculatePreferenceScore(feedback);
  }
  
  String _classifyMessageType(String messageContent) {
    if (messageContent.contains('축하') || messageContent.contains('🎉')) return 'celebration';
    if (messageContent.contains('격려') || messageContent.contains('💪')) return 'encouragement';
    if (messageContent.contains('조언') || messageContent.contains('💡')) return 'advice';
    if (messageContent.contains('공감') || messageContent.contains('❤️')) return 'empathy';
    return 'general';
  }
  
  Map<String, dynamic> _extractOptimalConditions(UserSuccessPattern pattern) {
    final optimal = <String, dynamic>{};
    
    pattern.successfulConditions.forEach((key, conditions) {
      if (conditions.isNotEmpty) {
        final bestCondition = conditions.entries
            .reduce((a, b) => a.value > b.value ? a : b);
        if (bestCondition.value > pattern.totalAttempts * 0.6) {
          optimal[key] = bestCondition.key;
        }
      }
    });
    
    return optimal;
  }
  
  String _getCurrentSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  // 분석 메서드들
  List<String> _analyzePersonalityTraits(UserPreferences preferences, Map<String, UserSuccessPattern> patterns) {
    final traits = <String>[];
    
    // 톤 선호도 분석
    final tonePrefs = preferences.overallPreferences['tone'];
    if (tonePrefs != null) {
      final dominantTone = tonePrefs.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (dominantTone.value > 0.6) {
        traits.add('선호 톤: ${dominantTone.key}');
      }
    }
    
    // 성공 패턴 기반 특성
    final avgSuccessRate = patterns.values.isEmpty ? 0.0 :
        patterns.values.map((p) => p.successRate).reduce((a, b) => a + b) / patterns.length;
    
    if (avgSuccessRate > 0.8) traits.add('높은 성취 지향');
    if (avgSuccessRate > 0.6) traits.add('꾸준한 실행력');
    
    return traits;
  }
  
  List<String> _analyzeOptimalTimings(Map<String, UserSuccessPattern> patterns) {
    // 시간대별 성공률 분석 (실제 구현에서는 더 정교한 분석 필요)
    return ['오전 시간대 활동 선호', '주중 높은 성과'];
  }
  
  List<String> _analyzePreferredStyles(UserPreferences preferences, Map<String, MessageEffectiveness> effectiveness) {
    final styles = <String>[];
    
    // 길이 선호도
    final lengthPrefs = preferences.overallPreferences['length'];
    if (lengthPrefs != null) {
      final preferred = lengthPrefs.entries.reduce((a, b) => a.value > b.value ? a : b);
      styles.add('선호 메시지 길이: ${preferred.key}');
    }
    
    return styles;
  }
  
  List<String> _analyzeMotivationPatterns(Map<String, UserSuccessPattern> patterns, Map<String, MessageEffectiveness> effectiveness) {
    return ['성취 기반 동기부여', '격려 메시지 효과적'];
  }
  
  double _calculateOverallEngagement(Map<String, MessageEffectiveness> effectiveness) {
    if (effectiveness.isEmpty) return 0.0;
    
    final engagementScores = effectiveness.values.map((e) => e.userEngagement).toList();
    return engagementScores.reduce((a, b) => a + b) / engagementScores.length;
  }
  
  double _calculatePersonalityConfidence(UserPreferences preferences, Map<String, UserSuccessPattern> patterns) {
    final totalInteractions = preferences.totalInteractions.values
        .expand((typeMap) => typeMap.values)
        .fold(0, (sum, count) => sum + count);
    
    // 상호작용이 많을수록 신뢰도 증가
    return (totalInteractions / 100.0).clamp(0.0, 1.0);
  }
  
  double _calculateDataRichness(UserPreferences preferences, Map<String, UserSuccessPattern> patterns, Map<String, MessageEffectiveness> effectiveness) {
    final prefScore = preferences.totalInteractions.isNotEmpty ? 0.33 : 0.0;
    final patternScore = patterns.isNotEmpty ? 0.33 : 0.0;
    final effectScore = effectiveness.isNotEmpty ? 0.34 : 0.0;
    
    return prefScore + patternScore + effectScore;
  }
  
  double _calculateLearningProgress(Map<String, UserSuccessPattern> patterns, Map<String, MessageEffectiveness> effectiveness) {
    if (patterns.isEmpty && effectiveness.isEmpty) return 0.0;
    
    final avgConfidence = patterns.values.isEmpty ? 0.0 :
        patterns.values.map((p) => p.confidenceScore).reduce((a, b) => a + b) / patterns.length;
    
    final avgEffectiveness = effectiveness.values.isEmpty ? 0.0 :
        effectiveness.values.map((e) => e.effectivenessScore).reduce((a, b) => a + b) / effectiveness.length;
    
    return (avgConfidence + avgEffectiveness) / 2;
  }
  
  List<String> _getTopSuccessfulContexts(Map<String, UserSuccessPattern> patterns) {
    return patterns.entries
        .where((entry) => entry.value.successRate > 0.7)
        .map((entry) => entry.key)
        .take(3)
        .toList();
  }
  
  Map<String, int> _getPreferredMessageSources(Map<String, MessageEffectiveness> effectiveness) {
    final sourceCounts = <String, int>{};
    
    effectiveness.values.forEach((eff) {
      if (eff.effectivenessScore > 0.7) {
        sourceCounts[eff.messageSource] = (sourceCounts[eff.messageSource] ?? 0) + 1;
      }
    });
    
    return sourceCounts;
  }
  
  List<String> _generateImprovementSuggestions(UserPreferences preferences, Map<String, UserSuccessPattern> patterns, Map<String, MessageEffectiveness> effectiveness) {
    final suggestions = <String>[];
    
    // 낮은 성공률 패턴에 대한 제안
    patterns.values.where((p) => p.successRate < 0.5).forEach((pattern) {
      suggestions.add('${pattern.activityType} 활동의 성공 조건을 재검토해보세요');
    });
    
    // 효과성이 낮은 메시지 타입에 대한 제안
    final lowEffective = effectiveness.values.where((e) => e.effectivenessScore < 0.4).toList();
    if (lowEffective.length > effectiveness.length * 0.3) {
      suggestions.add('메시지 개인화 수준을 높여보세요');
    }
    
    return suggestions;
  }
  
  // ==================== 저장 메서드들 ====================
  
  Future<void> _saveSuccessPatterns(Map<String, UserSuccessPattern> patterns) async {
    try {
      final jsonData = <String, dynamic>{};
      patterns.forEach((key, pattern) {
        jsonData[key] = pattern.toJson();
      });
      
      await _prefs.setString(_keySuccessPatterns, jsonEncode(jsonData));
      _cachedSuccessPatterns = patterns;
    } catch (e) {
      print('🧠 성공 패턴 저장 실패: $e');
    }
  }
  
  Future<void> _saveUserPreferences(UserPreferences preferences) async {
    try {
      await _prefs.setString(_keyUserPreferences, jsonEncode(preferences.toJson()));
      _cachedPreferences = preferences;
    } catch (e) {
      print('💡 사용자 선호도 저장 실패: $e');
    }
  }
  
  Future<void> _saveMessageEffectiveness(Map<String, MessageEffectiveness> effectiveness) async {
    try {
      final jsonData = <String, dynamic>{};
      effectiveness.forEach((key, eff) {
        jsonData[key] = eff.toJson();
      });
      
      await _prefs.setString(_keyMessageEffectiveness, jsonEncode(jsonData));
      _cachedEffectiveness = effectiveness;
    } catch (e) {
      print('📊 메시지 효과성 저장 실패: $e');
    }
  }
  
  Future<void> _saveInteractionHistory(List<InteractionMemory> interactions) async {
    try {
      final jsonList = interactions.map((interaction) => interaction.toJson()).toList();
      await _prefs.setString(_keyInteractionHistory, jsonEncode(jsonList));
      _cachedInteractions = interactions;
    } catch (e) {
      print('📈 상호작용 기록 저장 실패: $e');
    }
  }
  
  Future<void> _savePersonalityInsights(PersonalityInsights insights) async {
    try {
      await _prefs.setString(_keyPersonalityInsights, jsonEncode(insights.toJson()));
      _cachedPersonalityInsights = insights;
    } catch (e) {
      print('💎 개인화 인사이트 저장 실패: $e');
    }
  }
  
  /// 🗑️ 캐시 초기화
  void clearCache() {
    _cachedSuccessPatterns = null;
    _cachedPreferences = null;
    _cachedEffectiveness = null;
    _cachedInteractions = null;
    _cachedPersonalityInsights = null;
    _cachedContextualPreferences = null;
  }
  
  /// 🧹 모든 데이터 초기화 (개발용)
  Future<void> clearAllData() async {
    try {
      await _prefs.remove(_keySuccessPatterns);
      await _prefs.remove(_keyUserPreferences);
      await _prefs.remove(_keyMessageEffectiveness);
      await _prefs.remove(_keyInteractionHistory);
      await _prefs.remove(_keyPersonalityInsights);
      await _prefs.remove(_keyContextualPreferences);
      clearCache();
      print('🧹 모든 사용자 메모리 데이터 초기화 완료');
    } catch (e) {
      print('🧹 데이터 초기화 실패: $e');
    }
  }
}

// ==================== 데이터 모델들 ====================

/// 🎯 사용자 성공 패턴
class UserSuccessPattern {
  final SherpiContext contextType;
  final String activityType;
  final Map<String, Map<String, int>> successfulConditions;
  final Map<String, Map<String, int>> failureConditions;
  final int totalAttempts;
  final int successfulAttempts;
  final DateTime lastUpdated;
  final double confidenceScore;
  final Map<String, double> effectiveMessageTypes;
  final Map<String, double> preferredTones;
  
  UserSuccessPattern({
    required this.contextType,
    required this.activityType,
    required this.successfulConditions,
    required this.failureConditions,
    required this.totalAttempts,
    required this.successfulAttempts,
    required this.lastUpdated,
    required this.confidenceScore,
    required this.effectiveMessageTypes,
    required this.preferredTones,
  });
  
  double get successRate => totalAttempts > 0 ? successfulAttempts / totalAttempts : 0.0;
  
  UserSuccessPattern copyWith({
    SherpiContext? contextType,
    String? activityType,
    Map<String, Map<String, int>>? successfulConditions,
    Map<String, Map<String, int>>? failureConditions,
    int? totalAttempts,
    int? successfulAttempts,
    DateTime? lastUpdated,
    double? confidenceScore,
    Map<String, double>? effectiveMessageTypes,
    Map<String, double>? preferredTones,
  }) {
    return UserSuccessPattern(
      contextType: contextType ?? this.contextType,
      activityType: activityType ?? this.activityType,
      successfulConditions: successfulConditions ?? this.successfulConditions,
      failureConditions: failureConditions ?? this.failureConditions,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      successfulAttempts: successfulAttempts ?? this.successfulAttempts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      effectiveMessageTypes: effectiveMessageTypes ?? this.effectiveMessageTypes,
      preferredTones: preferredTones ?? this.preferredTones,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'contextType': contextType.name,
      'activityType': activityType,
      'successfulConditions': successfulConditions,
      'failureConditions': failureConditions,
      'totalAttempts': totalAttempts,
      'successfulAttempts': successfulAttempts,
      'lastUpdated': lastUpdated.toIso8601String(),
      'confidenceScore': confidenceScore,
      'effectiveMessageTypes': effectiveMessageTypes,
      'preferredTones': preferredTones,
    };
  }
  
  factory UserSuccessPattern.fromJson(Map<String, dynamic> json) {
    return UserSuccessPattern(
      contextType: SherpiContext.values.firstWhere(
        (e) => e.name == json['contextType'],
        orElse: () => SherpiContext.welcome,
      ),
      activityType: json['activityType'],
      successfulConditions: Map<String, Map<String, int>>.from(
        json['successfulConditions'].map((k, v) => MapEntry(k, Map<String, int>.from(v)))
      ),
      failureConditions: Map<String, Map<String, int>>.from(
        json['failureConditions'].map((k, v) => MapEntry(k, Map<String, int>.from(v)))
      ),
      totalAttempts: json['totalAttempts'],
      successfulAttempts: json['successfulAttempts'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      confidenceScore: json['confidenceScore'].toDouble(),
      effectiveMessageTypes: Map<String, double>.from(json['effectiveMessageTypes']),
      preferredTones: Map<String, double>.from(json['preferredTones']),
    );
  }
}

/// 💡 사용자 선호도
class UserPreferences {
  final Map<String, Map<String, Map<String, double>>> contextualPreferences;
  final Map<String, Map<String, double>> overallPreferences;
  final Map<String, Map<String, Map<String, int>>> interactionCounts;
  final Map<String, Map<String, int>> totalInteractions;
  DateTime lastUpdated;
  
  UserPreferences({
    required this.contextualPreferences,
    required this.overallPreferences,
    required this.interactionCounts,
    required this.totalInteractions,
    required this.lastUpdated,
  });
  
  factory UserPreferences.createDefault() {
    return UserPreferences(
      contextualPreferences: {},
      overallPreferences: {},
      interactionCounts: {},
      totalInteractions: {},
      lastUpdated: DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'contextualPreferences': contextualPreferences,
      'overallPreferences': overallPreferences,
      'interactionCounts': interactionCounts,
      'totalInteractions': totalInteractions,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      contextualPreferences: Map<String, Map<String, Map<String, double>>>.from(
        json['contextualPreferences'].map((k, v) => MapEntry(k, Map<String, Map<String, double>>.from(
          v.map((k2, v2) => MapEntry(k2, Map<String, double>.from(v2)))
        )))
      ),
      overallPreferences: Map<String, Map<String, double>>.from(
        json['overallPreferences'].map((k, v) => MapEntry(k, Map<String, double>.from(v)))
      ),
      interactionCounts: Map<String, Map<String, Map<String, int>>>.from(
        json['interactionCounts'].map((k, v) => MapEntry(k, Map<String, Map<String, int>>.from(
          v.map((k2, v2) => MapEntry(k2, Map<String, int>.from(v2)))
        )))
      ),
      totalInteractions: Map<String, Map<String, int>>.from(
        json['totalInteractions'].map((k, v) => MapEntry(k, Map<String, int>.from(v)))
      ),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

/// 📊 메시지 효과성
class MessageEffectiveness {
  final String messageId;
  final SherpiContext context;
  final String messageContent;
  final String messageSource;
  final UserFeedbackType feedback;
  final Duration responseTime;
  final DateTime timestamp;
  final String personalizationLevel;
  final String? personalityType;
  final double effectivenessScore;
  final double userEngagement;
  final double contextualRelevance;
  
  MessageEffectiveness({
    required this.messageId,
    required this.context,
    required this.messageContent,
    required this.messageSource,
    required this.feedback,
    required this.responseTime,
    required this.timestamp,
    required this.personalizationLevel,
    this.personalityType,
    required this.effectivenessScore,
    required this.userEngagement,
    required this.contextualRelevance,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'context': context.name,
      'messageContent': messageContent,
      'messageSource': messageSource,
      'feedback': feedback.name,
      'responseTime': responseTime.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'personalizationLevel': personalizationLevel,
      'personalityType': personalityType,
      'effectivenessScore': effectivenessScore,
      'userEngagement': userEngagement,
      'contextualRelevance': contextualRelevance,
    };
  }
  
  factory MessageEffectiveness.fromJson(Map<String, dynamic> json) {
    return MessageEffectiveness(
      messageId: json['messageId'],
      context: SherpiContext.values.firstWhere(
        (e) => e.name == json['context'],
        orElse: () => SherpiContext.welcome,
      ),
      messageContent: json['messageContent'],
      messageSource: json['messageSource'],
      feedback: UserFeedbackType.values.firstWhere(
        (e) => e.name == json['feedback'],
        orElse: () => UserFeedbackType.neutral,
      ),
      responseTime: Duration(milliseconds: json['responseTime']),
      timestamp: DateTime.parse(json['timestamp']),
      personalizationLevel: json['personalizationLevel'],
      personalityType: json['personalityType'],
      effectivenessScore: json['effectivenessScore'].toDouble(),
      userEngagement: json['userEngagement'].toDouble(),
      contextualRelevance: json['contextualRelevance'].toDouble(),
    );
  }
}

/// 📈 상호작용 기록
class InteractionMemory {
  final String id;
  final SherpiContext context;
  final String messageContent;
  final String messageSource;
  final Duration responseTime;
  final UserFeedbackType? feedback;
  final DateTime timestamp;
  final Map<String, dynamic> contextData;
  final double? userSatisfaction;
  final String sessionId;
  
  InteractionMemory({
    required this.id,
    required this.context,
    required this.messageContent,
    required this.messageSource,
    required this.responseTime,
    this.feedback,
    required this.timestamp,
    required this.contextData,
    this.userSatisfaction,
    required this.sessionId,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'context': context.name,
      'messageContent': messageContent,
      'messageSource': messageSource,
      'responseTime': responseTime.inMilliseconds,
      'feedback': feedback?.name,
      'timestamp': timestamp.toIso8601String(),
      'contextData': contextData,
      'userSatisfaction': userSatisfaction,
      'sessionId': sessionId,
    };
  }
  
  factory InteractionMemory.fromJson(Map<String, dynamic> json) {
    return InteractionMemory(
      id: json['id'],
      context: SherpiContext.values.firstWhere(
        (e) => e.name == json['context'],
        orElse: () => SherpiContext.welcome,
      ),
      messageContent: json['messageContent'],
      messageSource: json['messageSource'],
      responseTime: Duration(milliseconds: json['responseTime']),
      feedback: json['feedback'] != null
          ? UserFeedbackType.values.firstWhere(
              (e) => e.name == json['feedback'],
              orElse: () => UserFeedbackType.neutral,
            )
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      contextData: Map<String, dynamic>.from(json['contextData']),
      userSatisfaction: json['userSatisfaction']?.toDouble(),
      sessionId: json['sessionId'],
    );
  }
}

/// 💎 개인화 인사이트
class PersonalityInsights {
  final List<String> dominantPersonalityTraits;
  final List<String> optimalInteractionTimings;
  final List<String> preferredCommunicationStyles;
  final List<String> effectiveMotivationTriggers;
  final double overallEngagementScore;
  final double personalityConfidence;
  final DateTime lastAnalyzed;
  final double dataRichness;
  final List<String> improvementSuggestions;
  
  PersonalityInsights({
    required this.dominantPersonalityTraits,
    required this.optimalInteractionTimings,
    required this.preferredCommunicationStyles,
    required this.effectiveMotivationTriggers,
    required this.overallEngagementScore,
    required this.personalityConfidence,
    required this.lastAnalyzed,
    required this.dataRichness,
    required this.improvementSuggestions,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'dominantPersonalityTraits': dominantPersonalityTraits,
      'optimalInteractionTimings': optimalInteractionTimings,
      'preferredCommunicationStyles': preferredCommunicationStyles,
      'effectiveMotivationTriggers': effectiveMotivationTriggers,
      'overallEngagementScore': overallEngagementScore,
      'personalityConfidence': personalityConfidence,
      'lastAnalyzed': lastAnalyzed.toIso8601String(),
      'dataRichness': dataRichness,
      'improvementSuggestions': improvementSuggestions,
    };
  }
  
  factory PersonalityInsights.fromJson(Map<String, dynamic> json) {
    return PersonalityInsights(
      dominantPersonalityTraits: List<String>.from(json['dominantPersonalityTraits']),
      optimalInteractionTimings: List<String>.from(json['optimalInteractionTimings']),
      preferredCommunicationStyles: List<String>.from(json['preferredCommunicationStyles']),
      effectiveMotivationTriggers: List<String>.from(json['effectiveMotivationTriggers']),
      overallEngagementScore: json['overallEngagementScore'].toDouble(),
      personalityConfidence: json['personalityConfidence'].toDouble(),
      lastAnalyzed: DateTime.parse(json['lastAnalyzed']),
      dataRichness: json['dataRichness'].toDouble(),
      improvementSuggestions: List<String>.from(json['improvementSuggestions']),
    );
  }
}

/// 🎯 컨텍스트별 선호도
class ContextualPreference {
  final SherpiContext context;
  final Map<String, double> tonePreferences;
  final Map<String, double> lengthPreferences;
  final Map<String, double> timingPreferences;
  final double averageSatisfaction;
  final int totalInteractions;
  final DateTime lastUpdated;
  
  ContextualPreference({
    required this.context,
    required this.tonePreferences,
    required this.lengthPreferences,
    required this.timingPreferences,
    required this.averageSatisfaction,
    required this.totalInteractions,
    required this.lastUpdated,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'context': context.name,
      'tonePreferences': tonePreferences,
      'lengthPreferences': lengthPreferences,
      'timingPreferences': timingPreferences,
      'averageSatisfaction': averageSatisfaction,
      'totalInteractions': totalInteractions,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  factory ContextualPreference.fromJson(Map<String, dynamic> json) {
    return ContextualPreference(
      context: SherpiContext.values.firstWhere(
        (e) => e.name == json['context'],
        orElse: () => SherpiContext.welcome,
      ),
      tonePreferences: Map<String, double>.from(json['tonePreferences']),
      lengthPreferences: Map<String, double>.from(json['lengthPreferences']),
      timingPreferences: Map<String, double>.from(json['timingPreferences']),
      averageSatisfaction: json['averageSatisfaction'].toDouble(),
      totalInteractions: json['totalInteractions'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}