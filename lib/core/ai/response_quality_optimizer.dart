import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/user_memory_service.dart';
import 'package:sherpa_app/core/ai/personalized_sherpi_manager.dart';

/// 📊 응답 품질 최적화 시스템
/// 
/// 메시지 효과성을 추적하고 개인화 수준을 동적으로 조정하여 
/// 사용자 만족도를 지속적으로 향상시킵니다.
class ResponseQualityOptimizer {
  final SharedPreferences _prefs;
  final UserMemoryService _memoryService;
  
  // 최적화 관련 저장 키
  static const String _keyQualityMetrics = 'sherpi_quality_metrics';
  static const String _keyOptimizationSettings = 'sherpi_optimization_settings';
  static const String _keyABTestResults = 'sherpi_ab_test_results';
  static const String _keyPerformanceHistory = 'sherpi_performance_history';
  
  // 캐시
  QualityMetrics? _cachedMetrics;
  OptimizationSettings? _cachedSettings;
  Map<String, ABTestResult>? _cachedABTests;
  
  // 실시간 품질 추적
  final Map<String, List<double>> _realtimeScores = {};
  final Map<String, DateTime> _lastOptimizationTime = {};
  
  ResponseQualityOptimizer(this._prefs, this._memoryService) {
    _loadOptimizationData();
  }
  
  /// 데이터 로드
  Future<void> _loadOptimizationData() async {
    try {
      // 품질 메트릭 로드
      final metricsJson = _prefs.getString(_keyQualityMetrics);
      if (metricsJson != null) {
        _cachedMetrics = QualityMetrics.fromJson(jsonDecode(metricsJson));
      } else {
        _cachedMetrics = QualityMetrics.createDefault();
      }
      
      // 최적화 설정 로드
      final settingsJson = _prefs.getString(_keyOptimizationSettings);
      if (settingsJson != null) {
        _cachedSettings = OptimizationSettings.fromJson(jsonDecode(settingsJson));
      } else {
        _cachedSettings = OptimizationSettings.createDefault();
      }
      
      // A/B 테스트 결과 로드
      final abTestsJson = _prefs.getString(_keyABTestResults);
      if (abTestsJson != null) {
        final Map<String, dynamic> testsData = jsonDecode(abTestsJson);
        _cachedABTests = {};
        testsData.forEach((key, value) {
          _cachedABTests![key] = ABTestResult.fromJson(value);
        });
      } else {
        _cachedABTests = {};
      }
      
      print('📊 응답 품질 최적화 시스템 초기화 완료');
    } catch (e) {
      print('📊 최적화 데이터 로드 실패: $e');
      _initializeDefaults();
    }
  }
  
  /// 기본값 초기화
  void _initializeDefaults() {
    _cachedMetrics = QualityMetrics.createDefault();
    _cachedSettings = OptimizationSettings.createDefault();
    _cachedABTests = {};
  }
  
  /// 📈 메시지 품질 추적
  Future<void> trackMessageQuality({
    required String messageId,
    required SherpiContext context,
    required String messageContent,
    required String messageSource,
    required UserFeedbackType? feedback,
    required Duration responseTime,
    required Map<String, dynamic> personalizationData,
    Map<String, dynamic>? additionalMetrics,
  }) async {
    try {
      // 품질 점수 계산
      final qualityScore = await _calculateQualityScore(
        context: context,
        messageContent: messageContent,
        messageSource: messageSource,
        feedback: feedback,
        responseTime: responseTime,
        personalizationData: personalizationData,
        additionalMetrics: additionalMetrics,
      );
      
      // 메트릭 업데이트
      await _updateQualityMetrics(
        context: context,
        messageSource: messageSource,
        qualityScore: qualityScore,
        feedback: feedback,
        responseTime: responseTime,
        personalizationLevel: personalizationData['level'] as String? ?? 'medium',
      );
      
      // 실시간 점수 추적
      _trackRealtimeScore(context, qualityScore);
      
      // 최적화 트리거 확인
      await _checkOptimizationTriggers(context, messageSource);
      
      print('📈 메시지 품질 추적 완료: ${qualityScore.overallScore.toStringAsFixed(2)}');
      
    } catch (e) {
      print('📈 메시지 품질 추적 실패: $e');
    }
  }
  
  /// 🎯 개인화 수준 최적화
  Future<PersonalizationLevel> optimizePersonalizationLevel({
    required SherpiContext context,
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
    String? personalityType,
  }) async {
    try {
      // 현재 컨텍스트의 성과 분석
      final contextPerformance = await _analyzeContextPerformance(context);
      
      // 사용자 개인화 선호도 분석
      final userPreferences = await _analyzeUserPersonalizationPreference(personalityType);
      
      // 리소스 고려사항 (성능 vs 품질)
      final resourceBalance = _calculateResourceBalance();
      
      // 최적 개인화 수준 결정
      final optimizedLevel = _determineOptimalPersonalizationLevel(
        contextPerformance: contextPerformance,
        userPreferences: userPreferences,
        resourceBalance: resourceBalance,
        context: context,
      );
      
      // A/B 테스트 적용 (필요한 경우)
      final finalLevel = await _applyABTestIfNeeded(optimizedLevel, context);
      
      print('🎯 개인화 수준 최적화: $context → $finalLevel');
      return finalLevel;
      
    } catch (e) {
      print('🎯 개인화 수준 최적화 실패: $e');
      return PersonalizationLevel.medium; // 안전한 기본값
    }
  }
  
  /// 🔄 A/B 테스트 실행
  Future<ABTestResult> runABTest({
    required String testName,
    required SherpiContext context,
    required Map<String, dynamic> variantA,
    required Map<String, dynamic> variantB,
    required int targetSampleSize,
    Duration? testDuration,
  }) async {
    try {
      final testId = '${testName}_${context.name}_${DateTime.now().millisecondsSinceEpoch}';
      
      final abTest = ABTestResult(
        testId: testId,
        testName: testName,
        context: context,
        variantA: variantA,
        variantB: variantB,
        startTime: DateTime.now(),
        targetSampleSize: targetSampleSize,
        testDuration: testDuration ?? const Duration(days: 7),
        resultsA: ABTestMetrics.createEmpty(),
        resultsB: ABTestMetrics.createEmpty(),
        status: ABTestStatus.running,
        currentSampleSize: 0,
        statisticalSignificance: 0.0,
        winningVariant: null,
      );
      
      // 테스트 저장
      _cachedABTests![testId] = abTest;
      await _saveABTestResults();
      
      print('🔄 A/B 테스트 시작: $testName');
      return abTest;
      
    } catch (e) {
      print('🔄 A/B 테스트 실행 실패: $e');
      rethrow;
    }
  }
  
  /// 📊 성과 분석 및 인사이트 생성
  Future<Map<String, dynamic>> generatePerformanceInsights() async {
    try {
      final insights = <String, dynamic>{};
      
      // 전체 품질 트렌드 분석
      final qualityTrend = await _analyzeQualityTrend();
      insights['qualityTrend'] = qualityTrend;
      
      // 컨텍스트별 성과 분석
      final contextPerformance = await _analyzeAllContextsPerformance();
      insights['contextPerformance'] = contextPerformance;
      
      // 개인화 효과성 분석
      final personalizationEffectiveness = await _analyzePersonalizationEffectiveness();
      insights['personalizationEffectiveness'] = personalizationEffectiveness;
      
      // 메시지 소스 비교 분석
      final sourceComparison = await _analyzeMessageSourcePerformance();
      insights['sourceComparison'] = sourceComparison;
      
      // 최적화 권장사항 생성
      final recommendations = await _generateOptimizationRecommendations();
      insights['recommendations'] = recommendations;
      
      // A/B 테스트 결과 요약
      final abTestSummary = _summarizeABTestResults();
      insights['abTestResults'] = abTestSummary;
      
      return insights;
      
    } catch (e) {
      print('📊 성과 분석 실패: $e');
      return {};
    }
  }
  
  /// 🎛️ 최적화 설정 조정
  Future<void> updateOptimizationSettings({
    double? qualityThreshold,
    int? minSampleSize,
    Duration? optimizationInterval,
    bool? enableABTesting,
    double? personalizationAggressiveness,
    Map<String, double>? contextWeights,
  }) async {
    try {
      final currentSettings = _cachedSettings!;
      
      final updatedSettings = OptimizationSettings(
        qualityThreshold: qualityThreshold ?? currentSettings.qualityThreshold,
        minSampleSize: minSampleSize ?? currentSettings.minSampleSize,
        optimizationInterval: optimizationInterval ?? currentSettings.optimizationInterval,
        enableABTesting: enableABTesting ?? currentSettings.enableABTesting,
        personalizationAggressiveness: personalizationAggressiveness ?? currentSettings.personalizationAggressiveness,
        contextWeights: contextWeights ?? currentSettings.contextWeights,
        enableRealtimeOptimization: currentSettings.enableRealtimeOptimization,
        qualityDecayFactor: currentSettings.qualityDecayFactor,
        lastUpdated: DateTime.now(),
      );
      
      _cachedSettings = updatedSettings;
      await _saveOptimizationSettings();
      
      print('🎛️ 최적화 설정 업데이트 완료');
      
    } catch (e) {
      print('🎛️ 최적화 설정 업데이트 실패: $e');
    }
  }
  
  /// 🧹 데이터 정리 및 최적화
  Future<void> cleanupAndOptimize() async {
    try {
      // 오래된 메트릭 데이터 정리
      await _cleanupOldMetrics();
      
      // 완료된 A/B 테스트 결과 아카이빙
      await _archiveCompletedABTests();
      
      // 실시간 점수 캐시 정리
      _cleanupRealtimeScores();
      
      // 메모리 서비스와 동기화
      await _syncWithMemoryService();
      
      print('🧹 데이터 정리 및 최적화 완료');
      
    } catch (e) {
      print('🧹 데이터 정리 실패: $e');
    }
  }
  
  // ==================== Private 메서드들 ====================
  
  /// 품질 점수 계산
  Future<QualityScore> _calculateQualityScore({
    required SherpiContext context,
    required String messageContent,
    required String messageSource,
    required UserFeedbackType? feedback,
    required Duration responseTime,
    required Map<String, dynamic> personalizationData,
    Map<String, dynamic>? additionalMetrics,
  }) async {
    // 사용자 피드백 점수 (40%)
    final feedbackScore = _calculateFeedbackScore(feedback);
    
    // 응답 시간 점수 (20%)
    final speedScore = _calculateSpeedScore(responseTime);
    
    // 개인화 관련성 점수 (25%)
    final personalizationScore = _calculatePersonalizationScore(personalizationData);
    
    // 컨텍스트 적합성 점수 (15%)
    final contextScore = await _calculateContextRelevanceScore(context, messageContent);
    
    // 가중 평균으로 종합 점수 계산
    final overallScore = (feedbackScore * 0.4) + 
                        (speedScore * 0.2) + 
                        (personalizationScore * 0.25) + 
                        (contextScore * 0.15);
    
    return QualityScore(
      feedbackScore: feedbackScore,
      speedScore: speedScore,
      personalizationScore: personalizationScore,
      contextRelevanceScore: contextScore,
      overallScore: overallScore,
      timestamp: DateTime.now(),
      metadata: {
        'messageSource': messageSource,
        'context': context.name,
        'messageLength': messageContent.length,
        'personalizationLevel': personalizationData['level'],
        ...?additionalMetrics,
      },
    );
  }
  
  /// 피드백 점수 계산
  double _calculateFeedbackScore(UserFeedbackType? feedback) {
    if (feedback == null) return 0.5; // 중립
    
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
  
  /// 응답 속도 점수 계산
  double _calculateSpeedScore(Duration responseTime) {
    final milliseconds = responseTime.inMilliseconds;
    
    if (milliseconds <= 500) {
      return 1.0; // 매우 빠름
    } else if (milliseconds <= 1000) {
      return 0.9; // 빠름
    } else if (milliseconds <= 2000) {
      return 0.7; // 적당함
    } else if (milliseconds <= 5000) {
      return 0.5; // 느림
    } else {
      return 0.2; // 매우 느림
    }
  }
  
  /// 개인화 점수 계산
  double _calculatePersonalizationScore(Map<String, dynamic> personalizationData) {
    final level = personalizationData['level'] as String? ?? 'low';
    final personalityType = personalizationData['personalityType'] as String?;
    final contextualRelevance = personalizationData['contextualRelevance'] as double? ?? 0.5;
    
    double baseScore;
    switch (level) {
      case 'high':
        baseScore = 1.0;
        break;
      case 'medium':
        baseScore = 0.7;
        break;
      case 'low':
        baseScore = 0.4;
        break;
      default:
        baseScore = 0.5;
    }
    
    // 성격 타입 매칭 보너스
    if (personalityType != null && personalityType != 'unknown') {
      baseScore += 0.1;
    }
    
    // 컨텍스트 관련성 반영
    final finalScore = (baseScore * 0.7) + (contextualRelevance * 0.3);
    
    return finalScore.clamp(0.0, 1.0);
  }
  
  /// 컨텍스트 관련성 점수 계산
  Future<double> _calculateContextRelevanceScore(SherpiContext context, String messageContent) async {
    // 컨텍스트별 키워드 매칭
    final contextKeywords = _getContextKeywords(context);
    final messageWords = messageContent.toLowerCase().split(' ');
    
    int matchCount = 0;
    for (final keyword in contextKeywords) {
      if (messageWords.any((word) => word.contains(keyword))) {
        matchCount++;
      }
    }
    
    final keywordScore = matchCount / contextKeywords.length.clamp(1, 10);
    
    // 메시지 길이 적절성 (컨텍스트별)
    final lengthScore = _calculateContextualLengthScore(context, messageContent.length);
    
    return ((keywordScore * 0.6) + (lengthScore * 0.4)).clamp(0.0, 1.0);
  }
  
  /// 컨텍스트별 키워드 반환
  List<String> _getContextKeywords(SherpiContext context) {
    switch (context) {
      case SherpiContext.welcome:
        return ['환영', '시작', '함께', '반가워'];
      case SherpiContext.levelUp:
        return ['축하', '레벨업', '성장', '발전'];
      case SherpiContext.encouragement:
        return ['격려', '힘내', '할수있어', '응원'];
      case SherpiContext.exerciseComplete:
        return ['운동', '완료', '건강', '체력'];
      case SherpiContext.studyComplete:
        return ['공부', '학습', '지식', '성장'];
      default:
        return ['좋아', '잘했어', '함께', '우리'];
    }
  }
  
  /// 컨텍스트별 메시지 길이 점수
  double _calculateContextualLengthScore(SherpiContext context, int messageLength) {
    Map<SherpiContext, Map<String, int>> optimalLengths = {
      SherpiContext.welcome: {'min': 20, 'max': 60},
      SherpiContext.levelUp: {'min': 30, 'max': 80},
      SherpiContext.encouragement: {'min': 25, 'max': 70},
      SherpiContext.exerciseComplete: {'min': 15, 'max': 50},
    };
    
    final range = optimalLengths[context] ?? {'min': 20, 'max': 60};
    final minLength = range['min']!;
    final maxLength = range['max']!;
    
    if (messageLength >= minLength && messageLength <= maxLength) {
      return 1.0;
    } else if (messageLength < minLength) {
      return (messageLength / minLength).clamp(0.3, 1.0);
    } else {
      return (maxLength / messageLength).clamp(0.3, 1.0);
    }
  }
  
  /// 품질 메트릭 업데이트
  Future<void> _updateQualityMetrics({
    required SherpiContext context,
    required String messageSource,
    required QualityScore qualityScore,
    UserFeedbackType? feedback,
    required Duration responseTime,
    required String personalizationLevel,
  }) async {
    final metrics = _cachedMetrics!;
    
    // 전체 메트릭 업데이트
    metrics.totalMessages += 1;
    metrics.totalQualityScore = ((metrics.totalQualityScore * (metrics.totalMessages - 1)) + 
                                qualityScore.overallScore) / metrics.totalMessages;
    
    // 컨텍스트별 메트릭 업데이트
    final contextKey = context.name;
    if (!metrics.contextMetrics.containsKey(contextKey)) {
      metrics.contextMetrics[contextKey] = ContextMetrics.createEmpty();
    }
    
    final contextMetrics = metrics.contextMetrics[contextKey]!;
    contextMetrics.messageCount += 1;
    contextMetrics.averageQualityScore = ((contextMetrics.averageQualityScore * (contextMetrics.messageCount - 1)) + 
                                         qualityScore.overallScore) / contextMetrics.messageCount;
    contextMetrics.averageResponseTime = Duration(milliseconds: 
      ((contextMetrics.averageResponseTime.inMilliseconds * (contextMetrics.messageCount - 1)) + 
       responseTime.inMilliseconds) ~/ contextMetrics.messageCount);
    
    if (feedback != null) {
      contextMetrics.feedbackCounts[feedback] = (contextMetrics.feedbackCounts[feedback] ?? 0) + 1;
    }
    
    // 메시지 소스별 메트릭 업데이트
    if (!metrics.sourceMetrics.containsKey(messageSource)) {
      metrics.sourceMetrics[messageSource] = SourceMetrics.createEmpty();
    }
    
    final sourceMetrics = metrics.sourceMetrics[messageSource]!;
    sourceMetrics.messageCount += 1;
    sourceMetrics.averageQualityScore = ((sourceMetrics.averageQualityScore * (sourceMetrics.messageCount - 1)) + 
                                        qualityScore.overallScore) / sourceMetrics.messageCount;
    
    // 개인화 수준별 메트릭 업데이트
    if (!metrics.personalizationMetrics.containsKey(personalizationLevel)) {
      metrics.personalizationMetrics[personalizationLevel] = PersonalizationMetrics.createEmpty();
    }
    
    final personalizationMetrics = metrics.personalizationMetrics[personalizationLevel]!;
    personalizationMetrics.messageCount += 1;
    personalizationMetrics.averageQualityScore = ((personalizationMetrics.averageQualityScore * (personalizationMetrics.messageCount - 1)) + 
                                                  qualityScore.overallScore) / personalizationMetrics.messageCount;
    
    metrics.lastUpdated = DateTime.now();
    
    // 저장
    await _saveQualityMetrics();
  }
  
  /// 실시간 점수 추적
  void _trackRealtimeScore(SherpiContext context, QualityScore qualityScore) {
    final key = context.name;
    
    if (!_realtimeScores.containsKey(key)) {
      _realtimeScores[key] = [];
    }
    
    _realtimeScores[key]!.add(qualityScore.overallScore);
    
    // 최근 20개 점수만 유지
    if (_realtimeScores[key]!.length > 20) {
      _realtimeScores[key]!.removeAt(0);
    }
  }
  
  /// 최적화 트리거 확인
  Future<void> _checkOptimizationTriggers(SherpiContext context, String messageSource) async {
    final settings = _cachedSettings!;
    final now = DateTime.now();
    
    // 최적화 간격 확인
    final lastOptimization = _lastOptimizationTime[context.name];
    if (lastOptimization != null && 
        now.difference(lastOptimization) < settings.optimizationInterval) {
      return;
    }
    
    // 최소 샘플 크기 확인
    final contextMetrics = _cachedMetrics!.contextMetrics[context.name];
    if (contextMetrics == null || contextMetrics.messageCount < settings.minSampleSize) {
      return;
    }
    
    // 품질 임계값 확인
    if (contextMetrics.averageQualityScore < settings.qualityThreshold) {
      // 최적화 실행
      await _executeOptimization(context, messageSource);
      _lastOptimizationTime[context.name] = now;
    }
  }
  
  /// 최적화 실행
  Future<void> _executeOptimization(SherpiContext context, String messageSource) async {
    try {
      print('🔧 최적화 실행: ${context.name}');
      
      // 성과가 낮은 원인 분석
      final analysisResult = await _analyzePerformanceIssues(context, messageSource);
      
      // 최적화 전략 결정
      final strategy = _determineOptimizationStrategy(analysisResult);
      
      // 설정 조정
      await _applyOptimizationStrategy(strategy, context);
      
      print('🔧 최적화 완료: ${context.name} → ${strategy.name}');
      
    } catch (e) {
      print('🔧 최적화 실행 실패: $e');
    }
  }
  
  /// 컨텍스트 성과 분석
  Future<ContextPerformanceAnalysis> _analyzeContextPerformance(SherpiContext context) async {
    final contextMetrics = _cachedMetrics!.contextMetrics[context.name];
    
    if (contextMetrics == null) {
      return ContextPerformanceAnalysis(
        averageQuality: 0.5,
        trend: PerformanceTrend.stable,
        recommendation: PersonalizationLevel.medium,
        confidence: 0.0,
      );
    }
    
    // 최근 성과 트렌드 분석
    final realtimeScores = _realtimeScores[context.name] ?? [];
    final trend = _calculateTrend(realtimeScores);
    
    // 추천 개인화 수준 결정
    final recommendation = _recommendPersonalizationLevel(contextMetrics.averageQualityScore);
    
    // 신뢰도 계산
    final confidence = _calculateConfidence(contextMetrics.messageCount);
    
    return ContextPerformanceAnalysis(
      averageQuality: contextMetrics.averageQualityScore,
      trend: trend,
      recommendation: recommendation,
      confidence: confidence,
    );
  }
  
  /// 트렌드 계산
  PerformanceTrend _calculateTrend(List<double> scores) {
    if (scores.length < 5) return PerformanceTrend.stable;
    
    final recent = scores.sublist(scores.length - 5);
    final earlier = scores.sublist(math.max(0, scores.length - 10), scores.length - 5);
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final earlierAvg = earlier.isNotEmpty ? earlier.reduce((a, b) => a + b) / earlier.length : recentAvg;
    
    final diff = recentAvg - earlierAvg;
    
    if (diff > 0.1) return PerformanceTrend.improving;
    if (diff < -0.1) return PerformanceTrend.declining;
    return PerformanceTrend.stable;
  }
  
  /// 개인화 수준 추천
  PersonalizationLevel _recommendPersonalizationLevel(double averageQuality) {
    if (averageQuality >= 0.8) {
      return PersonalizationLevel.high;
    } else if (averageQuality >= 0.6) {
      return PersonalizationLevel.medium;
    } else {
      return PersonalizationLevel.low;
    }
  }
  
  /// 신뢰도 계산
  double _calculateConfidence(int sampleSize) {
    return (sampleSize / 100.0).clamp(0.0, 1.0);
  }
  
  // 추가 분석 및 저장 메서드들...
  
  /// 저장 메서드들
  Future<void> _saveQualityMetrics() async {
    try {
      final json = jsonEncode(_cachedMetrics!.toJson());
      await _prefs.setString(_keyQualityMetrics, json);
    } catch (e) {
      print('📊 품질 메트릭 저장 실패: $e');
    }
  }
  
  Future<void> _saveOptimizationSettings() async {
    try {
      final json = jsonEncode(_cachedSettings!.toJson());
      await _prefs.setString(_keyOptimizationSettings, json);
    } catch (e) {
      print('🎛️ 최적화 설정 저장 실패: $e');
    }
  }
  
  Future<void> _saveABTestResults() async {
    try {
      final Map<String, dynamic> testsData = {};
      _cachedABTests!.forEach((key, value) {
        testsData[key] = value.toJson();
      });
      
      final json = jsonEncode(testsData);
      await _prefs.setString(_keyABTestResults, json);
    } catch (e) {
      print('🔄 A/B 테스트 결과 저장 실패: $e');
    }
  }
  
  // 정리 및 기타 메서드들은 구현 생략 (실제 앱에서는 필요에 따라 구현)
  Future<void> _cleanupOldMetrics() async {}
  Future<void> _archiveCompletedABTests() async {}
  void _cleanupRealtimeScores() {}
  Future<void> _syncWithMemoryService() async {}
  
  // 분석 메서드들 (간단화된 버전)
  Future<Map<String, dynamic>> _analyzeQualityTrend() async => {};
  Future<Map<String, dynamic>> _analyzeAllContextsPerformance() async => {};
  Future<Map<String, dynamic>> _analyzePersonalizationEffectiveness() async => {};
  Future<Map<String, dynamic>> _analyzeMessageSourcePerformance() async => {};
  Future<List<String>> _generateOptimizationRecommendations() async => [];
  Map<String, dynamic> _summarizeABTestResults() => {};
  
  Future<UserPersonalizationPreference> _analyzeUserPersonalizationPreference(String? personalityType) async {
    return UserPersonalizationPreference(preferredLevel: PersonalizationLevel.medium, confidence: 0.5);
  }
  
  double _calculateResourceBalance() => 0.7;
  
  PersonalizationLevel _determineOptimalPersonalizationLevel({
    required ContextPerformanceAnalysis contextPerformance,
    required UserPersonalizationPreference userPreferences,
    required double resourceBalance,
    required SherpiContext context,
  }) {
    return contextPerformance.recommendation;
  }
  
  Future<PersonalizationLevel> _applyABTestIfNeeded(PersonalizationLevel optimizedLevel, SherpiContext context) async {
    return optimizedLevel;
  }
  
  Future<PerformanceIssueAnalysis> _analyzePerformanceIssues(SherpiContext context, String messageSource) async {
    return PerformanceIssueAnalysis(issues: [], primaryIssue: 'low_engagement');
  }
  
  OptimizationStrategy _determineOptimizationStrategy(PerformanceIssueAnalysis analysis) {
    return OptimizationStrategy(name: 'increase_personalization', adjustments: {});
  }
  
  Future<void> _applyOptimizationStrategy(OptimizationStrategy strategy, SherpiContext context) async {}
}

// ==================== 데이터 모델들 ====================

/// 📊 품질 점수
class QualityScore {
  final double feedbackScore;
  final double speedScore;
  final double personalizationScore;
  final double contextRelevanceScore;
  final double overallScore;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  QualityScore({
    required this.feedbackScore,
    required this.speedScore,
    required this.personalizationScore,
    required this.contextRelevanceScore,
    required this.overallScore,
    required this.timestamp,
    required this.metadata,
  });
}

/// 📈 품질 메트릭
class QualityMetrics {
  int totalMessages;
  double totalQualityScore;
  Map<String, ContextMetrics> contextMetrics;
  Map<String, SourceMetrics> sourceMetrics;
  Map<String, PersonalizationMetrics> personalizationMetrics;
  DateTime lastUpdated;
  
  QualityMetrics({
    required this.totalMessages,
    required this.totalQualityScore,
    required this.contextMetrics,
    required this.sourceMetrics,
    required this.personalizationMetrics,
    required this.lastUpdated,
  });
  
  static QualityMetrics createDefault() {
    return QualityMetrics(
      totalMessages: 0,
      totalQualityScore: 0.0,
      contextMetrics: {},
      sourceMetrics: {},
      personalizationMetrics: {},
      lastUpdated: DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalMessages': totalMessages,
      'totalQualityScore': totalQualityScore,
      'contextMetrics': contextMetrics.map((k, v) => MapEntry(k, v.toJson())),
      'sourceMetrics': sourceMetrics.map((k, v) => MapEntry(k, v.toJson())),
      'personalizationMetrics': personalizationMetrics.map((k, v) => MapEntry(k, v.toJson())),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      totalMessages: json['totalMessages'],
      totalQualityScore: json['totalQualityScore'].toDouble(),
      contextMetrics: Map<String, ContextMetrics>.from(
        json['contextMetrics'].map((k, v) => MapEntry(k, ContextMetrics.fromJson(v)))
      ),
      sourceMetrics: Map<String, SourceMetrics>.from(
        json['sourceMetrics'].map((k, v) => MapEntry(k, SourceMetrics.fromJson(v)))
      ),
      personalizationMetrics: Map<String, PersonalizationMetrics>.from(
        json['personalizationMetrics'].map((k, v) => MapEntry(k, PersonalizationMetrics.fromJson(v)))
      ),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

/// 📋 컨텍스트 메트릭
class ContextMetrics {
  int messageCount;
  double averageQualityScore;
  Duration averageResponseTime;
  Map<UserFeedbackType, int> feedbackCounts;
  
  ContextMetrics({
    required this.messageCount,
    required this.averageQualityScore,
    required this.averageResponseTime,
    required this.feedbackCounts,
  });
  
  static ContextMetrics createEmpty() {
    return ContextMetrics(
      messageCount: 0,
      averageQualityScore: 0.0,
      averageResponseTime: Duration.zero,
      feedbackCounts: {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'messageCount': messageCount,
      'averageQualityScore': averageQualityScore,
      'averageResponseTime': averageResponseTime.inMilliseconds,
      'feedbackCounts': feedbackCounts.map((k, v) => MapEntry(k.name, v)),
    };
  }
  
  factory ContextMetrics.fromJson(Map<String, dynamic> json) {
    return ContextMetrics(
      messageCount: json['messageCount'],
      averageQualityScore: json['averageQualityScore'].toDouble(),
      averageResponseTime: Duration(milliseconds: json['averageResponseTime']),
      feedbackCounts: Map<UserFeedbackType, int>.from(
        json['feedbackCounts'].map((k, v) => MapEntry(
          UserFeedbackType.values.firstWhere((e) => e.name == k), v
        ))
      ),
    );
  }
}

/// 🔄 A/B 테스트 결과
class ABTestResult {
  final String testId;
  final String testName;
  final SherpiContext context;
  final Map<String, dynamic> variantA;
  final Map<String, dynamic> variantB;
  final DateTime startTime;
  final int targetSampleSize;
  final Duration testDuration;
  ABTestMetrics resultsA;
  ABTestMetrics resultsB;
  ABTestStatus status;
  int currentSampleSize;
  double statisticalSignificance;
  String? winningVariant;
  
  ABTestResult({
    required this.testId,
    required this.testName,
    required this.context,
    required this.variantA,
    required this.variantB,
    required this.startTime,
    required this.targetSampleSize,
    required this.testDuration,
    required this.resultsA,
    required this.resultsB,
    required this.status,
    required this.currentSampleSize,
    required this.statisticalSignificance,
    this.winningVariant,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testName': testName,
      'context': context.name,
      'variantA': variantA,
      'variantB': variantB,
      'startTime': startTime.toIso8601String(),
      'targetSampleSize': targetSampleSize,
      'testDuration': testDuration.inMilliseconds,
      'resultsA': resultsA.toJson(),
      'resultsB': resultsB.toJson(),
      'status': status.name,
      'currentSampleSize': currentSampleSize,
      'statisticalSignificance': statisticalSignificance,
      'winningVariant': winningVariant,
    };
  }
  
  factory ABTestResult.fromJson(Map<String, dynamic> json) {
    return ABTestResult(
      testId: json['testId'],
      testName: json['testName'],
      context: SherpiContext.values.firstWhere((e) => e.name == json['context']),
      variantA: json['variantA'],
      variantB: json['variantB'],
      startTime: DateTime.parse(json['startTime']),
      targetSampleSize: json['targetSampleSize'],
      testDuration: Duration(milliseconds: json['testDuration']),
      resultsA: ABTestMetrics.fromJson(json['resultsA']),
      resultsB: ABTestMetrics.fromJson(json['resultsB']),
      status: ABTestStatus.values.firstWhere((e) => e.name == json['status']),
      currentSampleSize: json['currentSampleSize'],
      statisticalSignificance: json['statisticalSignificance'].toDouble(),
      winningVariant: json['winningVariant'],
    );
  }
}

// 기타 필요한 열거형과 클래스들
enum ABTestStatus { running, completed, paused, cancelled }
enum PerformanceTrend { improving, stable, declining }

class SourceMetrics {
  int messageCount;
  double averageQualityScore;
  
  SourceMetrics({required this.messageCount, required this.averageQualityScore});
  
  static SourceMetrics createEmpty() => SourceMetrics(messageCount: 0, averageQualityScore: 0.0);
  
  Map<String, dynamic> toJson() => {'messageCount': messageCount, 'averageQualityScore': averageQualityScore};
  factory SourceMetrics.fromJson(Map<String, dynamic> json) => 
    SourceMetrics(messageCount: json['messageCount'], averageQualityScore: json['averageQualityScore'].toDouble());
}

class PersonalizationMetrics {
  int messageCount;
  double averageQualityScore;
  
  PersonalizationMetrics({required this.messageCount, required this.averageQualityScore});
  
  static PersonalizationMetrics createEmpty() => PersonalizationMetrics(messageCount: 0, averageQualityScore: 0.0);
  
  Map<String, dynamic> toJson() => {'messageCount': messageCount, 'averageQualityScore': averageQualityScore};
  factory PersonalizationMetrics.fromJson(Map<String, dynamic> json) => 
    PersonalizationMetrics(messageCount: json['messageCount'], averageQualityScore: json['averageQualityScore'].toDouble());
}

class ABTestMetrics {
  int sampleSize;
  double averageQualityScore;
  Map<UserFeedbackType, int> feedbackCounts;
  
  ABTestMetrics({required this.sampleSize, required this.averageQualityScore, required this.feedbackCounts});
  
  static ABTestMetrics createEmpty() => ABTestMetrics(sampleSize: 0, averageQualityScore: 0.0, feedbackCounts: {});
  
  Map<String, dynamic> toJson() => {
    'sampleSize': sampleSize, 
    'averageQualityScore': averageQualityScore,
    'feedbackCounts': feedbackCounts.map((k, v) => MapEntry(k.name, v))
  };
  
  factory ABTestMetrics.fromJson(Map<String, dynamic> json) => ABTestMetrics(
    sampleSize: json['sampleSize'], 
    averageQualityScore: json['averageQualityScore'].toDouble(),
    feedbackCounts: Map<UserFeedbackType, int>.from(
      json['feedbackCounts'].map((k, v) => MapEntry(
        UserFeedbackType.values.firstWhere((e) => e.name == k), v
      ))
    )
  );
}

class OptimizationSettings {
  final double qualityThreshold;
  final int minSampleSize;
  final Duration optimizationInterval;
  final bool enableABTesting;
  final double personalizationAggressiveness;
  final Map<String, double> contextWeights;
  final bool enableRealtimeOptimization;
  final double qualityDecayFactor;
  final DateTime lastUpdated;
  
  OptimizationSettings({
    required this.qualityThreshold,
    required this.minSampleSize,
    required this.optimizationInterval,
    required this.enableABTesting,
    required this.personalizationAggressiveness,
    required this.contextWeights,
    required this.enableRealtimeOptimization,
    required this.qualityDecayFactor,
    required this.lastUpdated,
  });
  
  static OptimizationSettings createDefault() {
    return OptimizationSettings(
      qualityThreshold: 0.6,
      minSampleSize: 10,
      optimizationInterval: const Duration(hours: 6),
      enableABTesting: true,
      personalizationAggressiveness: 0.7,
      contextWeights: {},
      enableRealtimeOptimization: true,
      qualityDecayFactor: 0.95,
      lastUpdated: DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'qualityThreshold': qualityThreshold,
      'minSampleSize': minSampleSize,
      'optimizationInterval': optimizationInterval.inMilliseconds,
      'enableABTesting': enableABTesting,
      'personalizationAggressiveness': personalizationAggressiveness,
      'contextWeights': contextWeights,
      'enableRealtimeOptimization': enableRealtimeOptimization,
      'qualityDecayFactor': qualityDecayFactor,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  factory OptimizationSettings.fromJson(Map<String, dynamic> json) {
    return OptimizationSettings(
      qualityThreshold: json['qualityThreshold'].toDouble(),
      minSampleSize: json['minSampleSize'],
      optimizationInterval: Duration(milliseconds: json['optimizationInterval']),
      enableABTesting: json['enableABTesting'],
      personalizationAggressiveness: json['personalizationAggressiveness'].toDouble(),
      contextWeights: Map<String, double>.from(json['contextWeights']),
      enableRealtimeOptimization: json['enableRealtimeOptimization'],
      qualityDecayFactor: json['qualityDecayFactor'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

// 분석 관련 클래스들 (간단화된 버전)
class ContextPerformanceAnalysis {
  final double averageQuality;
  final PerformanceTrend trend;
  final PersonalizationLevel recommendation;
  final double confidence;
  
  ContextPerformanceAnalysis({
    required this.averageQuality,
    required this.trend,
    required this.recommendation,
    required this.confidence,
  });
}

class UserPersonalizationPreference {
  final PersonalizationLevel preferredLevel;
  final double confidence;
  
  UserPersonalizationPreference({required this.preferredLevel, required this.confidence});
}

class PerformanceIssueAnalysis {
  final List<String> issues;
  final String primaryIssue;
  
  PerformanceIssueAnalysis({required this.issues, required this.primaryIssue});
}

class OptimizationStrategy {
  final String name;
  final Map<String, dynamic> adjustments;
  
  OptimizationStrategy({required this.name, required this.adjustments});
}