import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔍 행동 패턴 분석기
/// 
/// 사용자의 활동 패턴, 타이밍, 성공률을 분석하여
/// 최적의 동기 부여 시점과 접근 전략을 예측합니다.
class BehaviorPatternAnalyzer {
  final SharedPreferences _prefs;
  
  // 캐시된 분석 결과
  BehaviorAnalysisResult? _cachedAnalysis;
  DateTime? _lastAnalysisTime;
  
  // 분석 갱신 주기 (6시간)
  static const Duration _analysisUpdateInterval = Duration(hours: 6);
  
  BehaviorPatternAnalyzer(this._prefs);
  
  /// 🧠 종합 행동 패턴 분석
  Future<BehaviorAnalysisResult> analyzeBehaviorPatterns() async {
    try {
      // 캐시된 분석이 유효한지 확인
      if (_cachedAnalysis != null && 
          _lastAnalysisTime != null &&
          DateTime.now().difference(_lastAnalysisTime!) < _analysisUpdateInterval) {
        // 🔍 캐시된 행동 패턴 분석 결과 반환
        return _cachedAnalysis!;
      }
      
      // 🔍 새로운 행동 패턴 분석 시작
      
      // 활동 이력 데이터 수집
      final activityHistory = await _collectActivityHistory();
      final timingPatterns = await _analyzeTimingPatterns(activityHistory);
      final successPatterns = await _analyzeSuccessPatterns(activityHistory);
      final motivationTriggers = await _identifyMotivationTriggers();
      final engagementCycles = await _analyzeEngagementCycles(activityHistory);
      final riskFactors = await _identifyRiskFactors(activityHistory);
      
      // 예측 모델 생성
      final predictions = await _generateBehaviorPredictions(
        timingPatterns, 
        successPatterns, 
        motivationTriggers,
        engagementCycles
      );
      
      // 최적화 전략 수립
      final optimizationStrategies = await _developOptimizationStrategies(
        timingPatterns,
        successPatterns,
        riskFactors
      );
      
      final analysisResult = BehaviorAnalysisResult(
        timingPatterns: timingPatterns,
        successPatterns: successPatterns,
        motivationTriggers: motivationTriggers,
        engagementCycles: engagementCycles,
        riskFactors: riskFactors,
        predictions: predictions,
        optimizationStrategies: optimizationStrategies,
        analysisTimestamp: DateTime.now(),
        dataQuality: _calculateDataQuality(activityHistory),
        confidenceScore: _calculateConfidenceScore(activityHistory),
      );
      
      // 결과 캐싱
      _cachedAnalysis = analysisResult;
      _lastAnalysisTime = DateTime.now();
      
      // 분석 결과 저장
      await _saveAnalysisResult(analysisResult);
      
      print('🔍 행동 패턴 분석 완료 - 신뢰도: ${(analysisResult.confidenceScore * 100).toInt()}%');
      
      return analysisResult;
      
    } catch (e) {
      // 🔍 행동 패턴 분석 실패: $e
      return _createFallbackAnalysis();
    }
  }
  
  /// 📊 활동 이력 데이터 수집
  Future<List<ActivityRecord>> _collectActivityHistory() async {
    final activities = <ActivityRecord>[];
    
    try {
      // 최근 30일간의 활동 데이터 수집
      final now = DateTime.now();
      
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        // 운동 데이터
        final exerciseData = _prefs.getString('daily_exercise_$dateKey');
        if (exerciseData != null) {
          final exerciseMap = json.decode(exerciseData) as Map<String, dynamic>;
          activities.add(ActivityRecord(
            type: 'exercise',
            timestamp: date,
            success: exerciseMap['completed'] as bool? ?? false,
            intensity: exerciseMap['intensity'] as double? ?? 0.5,
            duration: exerciseMap['duration'] as int? ?? 0,
            metadata: exerciseMap,
          ));
        }
        
        // 독서 데이터
        final readingData = _prefs.getString('daily_reading_$dateKey');
        if (readingData != null) {
          final readingMap = json.decode(readingData) as Map<String, dynamic>;
          activities.add(ActivityRecord(
            type: 'reading',
            timestamp: date,
            success: readingMap['completed'] as bool? ?? false,
            intensity: (readingMap['pages'] as int? ?? 0) / 50.0, // 페이지당 강도 계산
            duration: readingMap['minutes'] as int? ?? 0,
            metadata: readingMap,
          ));
        }
        
        // 다이어리 데이터
        final diaryData = _prefs.getString('daily_diary_$dateKey');
        if (diaryData != null) {
          final diaryMap = json.decode(diaryData) as Map<String, dynamic>;
          activities.add(ActivityRecord(
            type: 'diary',
            timestamp: date,
            success: diaryMap['completed'] as bool? ?? false,
            intensity: 0.7, // 다이어리는 고정 강도
            duration: (diaryMap['content'] as String? ?? '').length ~/ 10, // 글자 수 기반 시간 추정
            metadata: diaryMap,
          ));
        }
        
        // 퀘스트 완료 데이터
        final questData = _prefs.getString('daily_quests_$dateKey');
        if (questData != null) {
          final questMap = json.decode(questData) as Map<String, dynamic>;
          final completedQuests = questMap['completed'] as List<dynamic>? ?? [];
          if (completedQuests.isNotEmpty) {
            activities.add(ActivityRecord(
              type: 'quest',
              timestamp: date,
              success: true,
              intensity: completedQuests.length / 5.0, // 완료한 퀘스트 수 기반
              duration: completedQuests.length * 10, // 퀘스트당 10분 추정
              metadata: questMap,
            ));
          }
        }
      }
      
      // 📊 ${activities.length}개의 활동 기록 수집 완료
      return activities;
      
    } catch (e) {
      // 📊 활동 이력 수집 실패: $e
      return [];
    }
  }
  
  /// ⏰ 타이밍 패턴 분석
  Future<TimingPatterns> _analyzeTimingPatterns(List<ActivityRecord> activities) async {
    final hourlyActivity = <int, List<ActivityRecord>>{};
    final dailyActivity = <int, List<ActivityRecord>>{};
    final weeklyActivity = <int, List<ActivityRecord>>{};
    
    // 시간대별, 요일별, 주별 활동 분류
    for (final activity in activities) {
      final hour = activity.timestamp.hour;
      final weekday = activity.timestamp.weekday;
      final weekOfMonth = (activity.timestamp.day - 1) ~/ 7 + 1;
      
      hourlyActivity.putIfAbsent(hour, () => []).add(activity);
      dailyActivity.putIfAbsent(weekday, () => []).add(activity);
      weeklyActivity.putIfAbsent(weekOfMonth, () => []).add(activity);
    }
    
    // 최적 시간대 계산
    List<int> peakHours = _findPeakActivityHours(hourlyActivity);
    List<int> peakDays = _findPeakActivityDays(dailyActivity);
    
    // 성공률이 높은 시간대
    List<int> successfulHours = _findSuccessfulHours(hourlyActivity);
    
    // 일관성 점수 계산
    double consistencyScore = _calculateConsistencyScore(activities);
    
    return TimingPatterns(
      peakActivityHours: peakHours,
      peakActivityDays: peakDays,
      successfulHours: successfulHours,
      consistencyScore: consistencyScore,
      averageSessionLength: _calculateAverageSessionLength(activities),
      preferredTimeSlots: _identifyPreferredTimeSlots(hourlyActivity),
      activityRhythm: _analyzeActivityRhythm(activities),
    );
  }
  
  /// 🏆 성공 패턴 분석
  Future<SuccessPatterns> _analyzeSuccessPatterns(List<ActivityRecord> activities) async {
    final successfulActivities = activities.where((a) => a.success).toList();
    final failedActivities = activities.where((a) => !a.success).toList();
    
    // 성공 요인 분석
    final successFactors = <String, double>{};
    
    // 시간대별 성공률
    final hourlySuccess = <int, double>{};
    for (int hour = 0; hour < 24; hour++) {
      final hourActivities = activities.where((a) => a.timestamp.hour == hour).toList();
      if (hourActivities.isNotEmpty) {
        final successCount = hourActivities.where((a) => a.success).length;
        hourlySuccess[hour] = successCount / hourActivities.length;
      }
    }
    
    // 강도별 성공률
    final intensitySuccess = <String, double>{};
    final lowIntensity = activities.where((a) => a.intensity <= 0.3).toList();
    final mediumIntensity = activities.where((a) => a.intensity > 0.3 && a.intensity <= 0.7).toList();
    final highIntensity = activities.where((a) => a.intensity > 0.7).toList();
    
    if (lowIntensity.isNotEmpty) {
      intensitySuccess['low'] = lowIntensity.where((a) => a.success).length / lowIntensity.length;
    }
    if (mediumIntensity.isNotEmpty) {
      intensitySuccess['medium'] = mediumIntensity.where((a) => a.success).length / mediumIntensity.length;
    }
    if (highIntensity.isNotEmpty) {
      intensitySuccess['high'] = highIntensity.where((a) => a.success).length / highIntensity.length;
    }
    
    // 연속성 패턴 분석
    final streakAnalysis = _analyzeStreakPatterns(activities);
    
    return SuccessPatterns(
      overallSuccessRate: activities.isEmpty ? 0.0 : successfulActivities.length / activities.length,
      hourlySuccessRates: hourlySuccess,
      intensitySuccessRates: intensitySuccess,
      streakPatterns: streakAnalysis,
      criticalFailurePoints: _identifyCriticalFailurePoints(failedActivities),
      successTriggers: _identifySuccessTriggers(successfulActivities),
      optimalConditions: _identifyOptimalConditions(successfulActivities),
    );
  }
  
  /// 🎯 동기 부여 트리거 식별
  Future<List<MotivationTrigger>> _identifyMotivationTriggers() async {
    final triggers = <MotivationTrigger>[];
    
    try {
      // Sherpi 상호작용 이력에서 효과적인 트리거 분석
      final interactionHistory = _prefs.getStringList('sherpi_interaction_history') ?? [];
      
      // 시간대별 반응성
      final timeBasedTriggers = _analyzeTimeBasedMotivation();
      triggers.addAll(timeBasedTriggers);
      
      // 컨텍스트별 반응성
      final contextTriggers = _analyzeContextBasedMotivation();
      triggers.addAll(contextTriggers);
      
      // 감정 상태별 효과적인 접근
      final emotionalTriggers = _analyzeEmotionalTriggers();
      triggers.addAll(emotionalTriggers);
      
      // 사회적 동기 요소
      final socialTriggers = _analyzeSocialMotivation();
      triggers.addAll(socialTriggers);
      
      // 🎯 ${triggers.length}개의 동기 부여 트리거 식별
      return triggers;
      
    } catch (e) {
      // 🎯 동기 부여 트리거 분석 실패: $e
      return [];
    }
  }
  
  /// 📈 참여도 주기 분석
  Future<EngagementCycles> _analyzeEngagementCycles(List<ActivityRecord> activities) async {
    // 주간 참여도 패턴
    final weeklyEngagement = _calculateWeeklyEngagement(activities);
    
    // 월간 참여도 트렌드
    final monthlyTrend = _calculateMonthlyTrend(activities);
    
    // 피로도 패턴 (연속 활동 후 활동 감소)
    final fatiguePatterns = _analyzeFatiguePatterns(activities);
    
    // 회복 패턴 (휴식 후 활동 증가)
    final recoveryPatterns = _analyzeRecoveryPatterns(activities);
    
    return EngagementCycles(
      weeklyEngagementPattern: weeklyEngagement,
      monthlyTrend: monthlyTrend,
      fatigueIndicators: fatiguePatterns,
      recoveryIndicators: recoveryPatterns,
      optimalRestPeriods: _identifyOptimalRestPeriods(activities),
      burnoutRiskLevel: _calculateBurnoutRisk(activities),
    );
  }
  
  /// ⚠️ 위험 요소 식별
  Future<List<RiskFactor>> _identifyRiskFactors(List<ActivityRecord> activities) async {
    final riskFactors = <RiskFactor>[];
    
    // 활동 감소 트렌드
    if (_isActivityDecreasing(activities)) {
      riskFactors.add(RiskFactor(
        type: 'declining_activity',
        severity: 'medium',
        description: '최근 활동량이 감소하는 추세',
        recommendations: ['가벼운 활동부터 다시 시작', '목표를 조정하여 부담 완화'],
      ));
    }
    
    // 연속 실패 패턴
    final consecutiveFailures = _countConsecutiveFailures(activities);
    if (consecutiveFailures >= 3) {
      riskFactors.add(RiskFactor(
        type: 'consecutive_failures',
        severity: consecutiveFailures >= 5 ? 'high' : 'medium',
        description: '$consecutiveFailures일 연속 목표 미달성',
        recommendations: ['목표 난이도 조정', '작은 성공 경험 만들기', '동기 부여 전략 변경'],
      ));
    }
    
    // 비일관적 패턴
    final consistencyScore = _calculateConsistencyScore(activities);
    if (consistencyScore < 0.3) {
      riskFactors.add(RiskFactor(
        type: 'inconsistent_pattern',
        severity: 'low',
        description: '활동 패턴이 불규칙함',
        recommendations: ['규칙적인 루틴 만들기', '간단한 습관부터 시작'],
      ));
    }
    
    // 번아웃 위험
    final burnoutRisk = _calculateBurnoutRisk(activities);
    if (burnoutRisk > 0.7) {
      riskFactors.add(RiskFactor(
        type: 'burnout_risk',
        severity: 'high',
        description: '과도한 활동으로 인한 번아웃 위험',
        recommendations: ['충분한 휴식 시간 확보', '활동 강도 조절', '스트레스 관리'],
      ));
    }
    
    return riskFactors;
  }
  
  /// 🔮 행동 예측 생성
  Future<BehaviorPredictions> _generateBehaviorPredictions(
    TimingPatterns timingPatterns,
    SuccessPatterns successPatterns,
    List<MotivationTrigger> motivationTriggers,
    EngagementCycles engagementCycles,
  ) async {
    final now = DateTime.now();
    
    // 오늘의 최적 활동 시간 예측
    final todayOptimalTimes = _predictTodayOptimalTimes(timingPatterns, now);
    
    // 이번 주 성공 가능성 예측
    final weeklySuccessPrediction = _predictWeeklySuccess(successPatterns, engagementCycles);
    
    // 동기 부여 필요 시점 예측
    final motivationNeeds = _predictMotivationNeeds(motivationTriggers, engagementCycles);
    
    // 위험 시간대 예측
    final riskPeriods = _predictRiskPeriods(successPatterns, engagementCycles);
    
    return BehaviorPredictions(
      todayOptimalTimes: todayOptimalTimes,
      weeklySuccessPrediction: weeklySuccessPrediction,
      motivationNeeds: motivationNeeds,
      riskPeriods: riskPeriods,
      recommendedActions: _generateRecommendedActions(timingPatterns, successPatterns),
      confidenceLevel: _calculatePredictionConfidence(timingPatterns, successPatterns),
    );
  }
  
  /// 🎯 최적화 전략 수립
  Future<OptimizationStrategies> _developOptimizationStrategies(
    TimingPatterns timingPatterns,
    SuccessPatterns successPatterns,
    List<RiskFactor> riskFactors,
  ) async {
    final strategies = <String, dynamic>{};
    
    // 타이밍 최적화
    if (timingPatterns.peakActivityHours.isNotEmpty) {
      strategies['timing'] = {
        'strategy': 'peak_time_focus',
        'description': '최고 활동 시간대(${timingPatterns.peakActivityHours.join(', ')}시)에 중요한 활동 집중',
        'implementation': '알림 시간을 피크 시간대로 조정',
      };
    }
    
    // 성공률 개선
    final bestSuccessRate = successPatterns.hourlySuccessRates.values.isEmpty 
        ? 0.0 
        : successPatterns.hourlySuccessRates.values.reduce((a, b) => a > b ? a : b);
    
    if (bestSuccessRate > 0.7) {
      final bestHour = successPatterns.hourlySuccessRates.entries
          .where((e) => e.value == bestSuccessRate)
          .first
          .key;
      
      strategies['success_optimization'] = {
        'strategy': 'golden_hour_utilization',
        'description': '${bestHour}시의 높은 성공률(${(bestSuccessRate * 100).toInt()}%) 활용',
        'implementation': '핵심 활동을 해당 시간대로 이동',
      };
    }
    
    // 위험 요소 완화
    for (final risk in riskFactors) {
      strategies['risk_mitigation_${risk.type}'] = {
        'strategy': 'risk_prevention',
        'description': risk.description,
        'implementation': risk.recommendations.join(', '),
        'priority': risk.severity,
      };
    }
    
    // 동기 부여 강화
    strategies['motivation_enhancement'] = {
      'strategy': 'personalized_motivation',
      'description': '개인화된 동기 부여 전략 적용',
      'implementation': 'AI 기반 맞춤형 격려 메시지 및 타이밍 조정',
    };
    
    return OptimizationStrategies(
      strategies: strategies,
      priorityOrder: _calculateStrategyPriority(strategies),
      implementationPlan: _createImplementationPlan(strategies),
      expectedOutcomes: _predictStrategyOutcomes(strategies, successPatterns),
    );
  }
  
  /// 🎯 오늘의 최적 활동 시간 예측
  Future<List<OptimalTime>> predictTodayOptimalTimes() async {
    final analysis = await analyzeBehaviorPatterns();
    return analysis.predictions.todayOptimalTimes;
  }
  
  /// 🔮 동기 부여 필요 시점 예측
  Future<List<MotivationNeed>> predictMotivationNeeds() async {
    final analysis = await analyzeBehaviorPatterns();
    return analysis.predictions.motivationNeeds;
  }
  
  /// ⚠️ 위험 시간대 예측
  Future<List<RiskPeriod>> predictRiskPeriods() async {
    final analysis = await analyzeBehaviorPatterns();
    return analysis.predictions.riskPeriods;
  }
  
  /// 📊 실시간 행동 패턴 업데이트
  Future<void> updateBehaviorPattern(ActivityRecord newActivity) async {
    try {
      // 실시간 활동 데이터 저장
      final realtimeKey = 'realtime_activities';
      final existingData = _prefs.getStringList(realtimeKey) ?? [];
      
      // 새 활동 추가
      existingData.insert(0, json.encode(newActivity.toJson()));
      
      // 최대 100개까지만 보관
      if (existingData.length > 100) {
        existingData.removeLast();
      }
      
      await _prefs.setStringList(realtimeKey, existingData);
      
      // 캐시 무효화 (다음 분석 시 새 데이터 반영)
      _cachedAnalysis = null;
      _lastAnalysisTime = null;
      
      // 📊 실시간 행동 패턴 업데이트: ${newActivity.type}
      
    } catch (e) {
      // 📊 실시간 행동 패턴 업데이트 실패: $e
    }
  }
  
  /// 🧹 분석 데이터 정리
  Future<void> cleanupAnalysisData() async {
    try {
      // 30일 이상 된 데이터 정리
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      
      // 실시간 활동 데이터 정리
      final realtimeActivities = _prefs.getStringList('realtime_activities') ?? [];
      final filteredActivities = realtimeActivities.where((activityJson) {
        try {
          final activity = json.decode(activityJson) as Map<String, dynamic>;
          final timestamp = DateTime.parse(activity['timestamp']);
          return timestamp.isAfter(cutoffDate);
        } catch (e) {
          return false; // 파싱 실패한 데이터는 제거
        }
      }).toList();
      
      await _prefs.setStringList('realtime_activities', filteredActivities);
      
      // 🧹 ${realtimeActivities.length - filteredActivities.length}개의 오래된 분석 데이터 정리
      
    } catch (e) {
      // 🧹 분석 데이터 정리 실패: $e
    }
  }
  
  // Helper methods
  
  List<int> _findPeakActivityHours(Map<int, List<ActivityRecord>> hourlyActivity) {
    final hourCounts = hourlyActivity.map((hour, activities) => MapEntry(hour, activities.length));
    final sortedHours = hourCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedHours.take(3).map((e) => e.key).toList();
  }
  
  List<int> _findPeakActivityDays(Map<int, List<ActivityRecord>> dailyActivity) {
    final dayCounts = dailyActivity.map((day, activities) => MapEntry(day, activities.length));
    final sortedDays = dayCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedDays.take(3).map((e) => e.key).toList();
  }
  
  List<int> _findSuccessfulHours(Map<int, List<ActivityRecord>> hourlyActivity) {
    final successRates = <int, double>{};
    
    hourlyActivity.forEach((hour, activities) {
      if (activities.isNotEmpty) {
        final successCount = activities.where((a) => a.success).length;
        successRates[hour] = successCount / activities.length;
      }
    });
    
    final sortedHours = successRates.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedHours.where((e) => e.value > 0.7).take(5).map((e) => e.key).toList();
  }
  
  double _calculateConsistencyScore(List<ActivityRecord> activities) {
    if (activities.isEmpty) return 0.0;
    
    // 일별 활동 수 계산
    final dailyActivityCounts = <String, int>{};
    for (final activity in activities) {
      final dateKey = '${activity.timestamp.year}-${activity.timestamp.month}-${activity.timestamp.day}';
      dailyActivityCounts[dateKey] = (dailyActivityCounts[dateKey] ?? 0) + 1;
    }
    
    if (dailyActivityCounts.isEmpty) return 0.0;
    
    // 표준편차 계산으로 일관성 측정
    final counts = dailyActivityCounts.values.toList();
    final mean = counts.reduce((a, b) => a + b) / counts.length;
    final variance = counts.map((count) => (count - mean) * (count - mean)).reduce((a, b) => a + b) / counts.length;
    final standardDeviation = variance == 0 ? 0 : 1 / (1 + variance); // 낮은 분산 = 높은 일관성
    
    return standardDeviation.clamp(0.0, 1.0).toDouble();
  }
  
  int _calculateAverageSessionLength(List<ActivityRecord> activities) {
    if (activities.isEmpty) return 0;
    final totalDuration = activities.map((a) => a.duration).reduce((a, b) => a + b);
    return totalDuration ~/ activities.length;
  }
  
  List<TimeSlot> _identifyPreferredTimeSlots(Map<int, List<ActivityRecord>> hourlyActivity) {
    final timeSlots = <TimeSlot>[];
    
    // 3시간 단위로 슬롯 분석
    for (int start = 0; start < 24; start += 3) {
      final end = (start + 3).clamp(0, 24);
      final slotActivities = <ActivityRecord>[];
      
      for (int hour = start; hour < end; hour++) {
        slotActivities.addAll(hourlyActivity[hour] ?? []);
      }
      
      if (slotActivities.isNotEmpty) {
        final successRate = slotActivities.where((a) => a.success).length / slotActivities.length;
        final averageIntensity = slotActivities.map((a) => a.intensity).reduce((a, b) => a + b) / slotActivities.length;
        
        timeSlots.add(TimeSlot(
          startHour: start,
          endHour: end,
          activityCount: slotActivities.length,
          successRate: successRate,
          averageIntensity: averageIntensity,
        ));
      }
    }
    
    // 성공률과 활동량 기준으로 정렬
    timeSlots.sort((a, b) => (b.successRate * b.activityCount).compareTo(a.successRate * a.activityCount));
    
    return timeSlots.take(3).toList();
  }
  
  ActivityRhythm _analyzeActivityRhythm(List<ActivityRecord> activities) {
    if (activities.isEmpty) {
      return ActivityRhythm(pattern: 'irregular', confidence: 0.0);
    }
    
    // 요일별 활동 분석
    final weekdayActivity = <int, int>{};
    for (final activity in activities) {
      final weekday = activity.timestamp.weekday;
      weekdayActivity[weekday] = (weekdayActivity[weekday] ?? 0) + 1;
    }
    
    // 패턴 식별
    final weekdayCount = weekdayActivity.values.where((count) => count > 0).length;
    final weekendCount = [DateTime.saturday, DateTime.sunday].map((day) => weekdayActivity[day] ?? 0).reduce((a, b) => a + b);
    final weekdayTotal = [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday].map((day) => weekdayActivity[day] ?? 0).reduce((a, b) => a + b);
    
    String pattern;
    double confidence;
    
    if (weekendCount > weekdayTotal * 1.5) {
      pattern = 'weekend_focused';
      confidence = 0.8;
    } else if (weekdayTotal > weekendCount * 2) {
      pattern = 'weekday_focused';
      confidence = 0.8;
    } else if (weekdayCount >= 5) {
      pattern = 'consistent_daily';
      confidence = 0.9;
    } else {
      pattern = 'irregular';
      confidence = 0.3;
    }
    
    return ActivityRhythm(pattern: pattern, confidence: confidence);
  }
  
  Map<String, dynamic> _analyzeStreakPatterns(List<ActivityRecord> activities) {
    if (activities.isEmpty) return {};
    
    // 날짜별로 정렬
    final sortedActivities = activities.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    int currentStreak = 0;
    int maxStreak = 0;
    int totalStreaks = 0;
    DateTime? lastDate;
    
    for (final activity in sortedActivities) {
      if (activity.success) {
        final activityDate = DateTime(activity.timestamp.year, activity.timestamp.month, activity.timestamp.day);
        
        if (lastDate == null || activityDate.difference(lastDate).inDays == 1) {
          currentStreak++;
          maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        } else if (activityDate.difference(lastDate!).inDays > 1) {
          if (currentStreak > 0) totalStreaks++;
          currentStreak = 1;
        }
        
        lastDate = activityDate;
      } else {
        if (currentStreak > 0) totalStreaks++;
        currentStreak = 0;
      }
    }
    
    if (currentStreak > 0) totalStreaks++;
    
    return {
      'maxStreak': maxStreak,
      'currentStreak': currentStreak,
      'totalStreaks': totalStreaks,
      'averageStreak': totalStreaks > 0 ? (sortedActivities.where((a) => a.success).length / totalStreaks) : 0,
    };
  }
  
  List<String> _identifyCriticalFailurePoints(List<ActivityRecord> failedActivities) {
    final failurePoints = <String>[];
    
    // 시간대별 실패 분석
    final failureHours = <int, int>{};
    for (final activity in failedActivities) {
      final hour = activity.timestamp.hour;
      failureHours[hour] = (failureHours[hour] ?? 0) + 1;
    }
    
    final sortedFailures = failureHours.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedFailures.isNotEmpty) {
      final topFailureHour = sortedFailures.first;
      if (topFailureHour.value >= 3) {
        failurePoints.add('${topFailureHour.key}시대에 실패율 높음');
      }
    }
    
    // 요일별 실패 분석
    final failureDays = <int, int>{};
    for (final activity in failedActivities) {
      final weekday = activity.timestamp.weekday;
      failureDays[weekday] = (failureDays[weekday] ?? 0) + 1;
    }
    
    final weekdayNames = ['', '월', '화', '수', '목', '금', '토', '일'];
    final sortedDayFailures = failureDays.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedDayFailures.isNotEmpty) {
      final topFailureDay = sortedDayFailures.first;
      if (topFailureDay.value >= 2) {
        failurePoints.add('${weekdayNames[topFailureDay.key]}요일에 실패율 높음');
      }
    }
    
    return failurePoints;
  }
  
  List<String> _identifySuccessTriggers(List<ActivityRecord> successfulActivities) {
    final triggers = <String>[];
    
    // 성공한 활동의 특성 분석
    if (successfulActivities.isNotEmpty) {
      final averageIntensity = successfulActivities.map((a) => a.intensity).reduce((a, b) => a + b) / successfulActivities.length;
      
      if (averageIntensity > 0.7) {
        triggers.add('높은 강도 활동에서 성공률 높음');
      } else if (averageIntensity < 0.3) {
        triggers.add('낮은 강도 활동에서 성공률 높음');
      } else {
        triggers.add('적당한 강도 활동에서 성공률 높음');
      }
      
      // 시간대 분석
      final successHours = <int, int>{};
      for (final activity in successfulActivities) {
        final hour = activity.timestamp.hour;
        successHours[hour] = (successHours[hour] ?? 0) + 1;
      }
      
      final sortedSuccessHours = successHours.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      if (sortedSuccessHours.isNotEmpty) {
        final topSuccessHour = sortedSuccessHours.first;
        triggers.add('${topSuccessHour.key}시대에 성공 집중');
      }
    }
    
    return triggers;
  }
  
  Map<String, dynamic> _identifyOptimalConditions(List<ActivityRecord> successfulActivities) {
    if (successfulActivities.isEmpty) return {};
    
    // 최적 조건 분석
    final optimalIntensity = successfulActivities.map((a) => a.intensity).reduce((a, b) => a + b) / successfulActivities.length;
    final optimalDuration = successfulActivities.map((a) => a.duration).reduce((a, b) => a + b) ~/ successfulActivities.length;
    
    // 성공률이 높은 시간대
    final hourCounts = <int, int>{};
    for (final activity in successfulActivities) {
      hourCounts[activity.timestamp.hour] = (hourCounts[activity.timestamp.hour] ?? 0) + 1;
    }
    
    final bestHours = hourCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'optimalIntensity': optimalIntensity,
      'optimalDuration': optimalDuration,
      'bestHours': bestHours.take(3).map((e) => e.key).toList(),
      'totalSuccessfulSessions': successfulActivities.length,
    };
  }
  
  List<MotivationTrigger> _analyzeTimeBasedMotivation() {
    final triggers = <MotivationTrigger>[];
    
    // 저장된 사용자 응답 패턴 분석
    final responseHistory = _prefs.getStringList('motivation_responses') ?? [];
    
    // 시간대별 반응성 분석
    final morningResponses = responseHistory.where((r) => r.contains('morning')).length;
    final eveningResponses = responseHistory.where((r) => r.contains('evening')).length;
    
    if (morningResponses > eveningResponses) {
      triggers.add(MotivationTrigger(
        type: 'time_based',
        condition: 'morning_motivation',
        effectiveness: morningResponses / (responseHistory.length.clamp(1, double.infinity)),
        description: '아침 시간대에 동기 부여 효과 높음',
        suggestedTiming: '07:00-09:00',
      ));
    } else if (eveningResponses > morningResponses) {
      triggers.add(MotivationTrigger(
        type: 'time_based',
        condition: 'evening_motivation',
        effectiveness: eveningResponses / (responseHistory.length.clamp(1, double.infinity)),
        description: '저녁 시간대에 동기 부여 효과 높음',
        suggestedTiming: '19:00-21:00',
      ));
    }
    
    return triggers;
  }
  
  List<MotivationTrigger> _analyzeContextBasedMotivation() {
    final triggers = <MotivationTrigger>[];
    
    // 컨텍스트별 효과성 분석
    final contextEffectiveness = <String, double>{
      'achievement': 0.8, // 성취 상황에서 높은 효과
      'encouragement': 0.7, // 격려가 필요한 상황
      'celebration': 0.9, // 축하 상황에서 최고 효과
      'guidance': 0.6, // 안내가 필요한 상황
    };
    
    contextEffectiveness.forEach((context, effectiveness) {
      if (effectiveness > 0.7) {
        triggers.add(MotivationTrigger(
          type: 'context_based',
          condition: context,
          effectiveness: effectiveness,
          description: '$context 상황에서 높은 동기 부여 효과',
          suggestedTiming: 'context_dependent',
        ));
      }
    });
    
    return triggers;
  }
  
  List<MotivationTrigger> _analyzeEmotionalTriggers() {
    final triggers = <MotivationTrigger>[];
    
    // 감정 상태별 효과적인 접근법
    final emotionalStrategies = <String, double>{
      'excited': 0.9,
      'motivated': 0.8,
      'neutral': 0.6,
      'tired': 0.7,
      'stressed': 0.5,
    };
    
    emotionalStrategies.forEach((emotion, effectiveness) {
      if (effectiveness > 0.6) {
        triggers.add(MotivationTrigger(
          type: 'emotional',
          condition: emotion,
          effectiveness: effectiveness,
          description: '$emotion 상태에서 맞춤형 접근 필요',
          suggestedTiming: 'emotion_dependent',
        ));
      }
    });
    
    return triggers;
  }
  
  List<MotivationTrigger> _analyzeSocialMotivation() {
    final triggers = <MotivationTrigger>[];
    
    // 사회적 동기 요소 분석
    final socialFactors = _prefs.getStringList('social_motivation_factors') ?? [];
    
    if (socialFactors.contains('community_support')) {
      triggers.add(MotivationTrigger(
        type: 'social',
        condition: 'community_support',
        effectiveness: 0.8,
        description: '커뮤니티 지원을 통한 동기 부여 효과',
        suggestedTiming: 'social_active_hours',
      ));
    }
    
    if (socialFactors.contains('friendly_competition')) {
      triggers.add(MotivationTrigger(
        type: 'social',
        condition: 'friendly_competition',
        effectiveness: 0.7,
        description: '친근한 경쟁을 통한 동기 부여',
        suggestedTiming: 'peak_social_hours',
      ));
    }
    
    return triggers;
  }
  
  Map<String, double> _calculateWeeklyEngagement(List<ActivityRecord> activities) {
    final weeklyEngagement = <String, double>{};
    
    // 주별 참여도 계산
    final now = DateTime.now();
    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weekKey = 'week_${4 - i}';
      
      final weekActivities = activities.where((a) => 
        a.timestamp.isAfter(weekStart) && a.timestamp.isBefore(weekEnd)
      ).toList();
      
      if (weekActivities.isNotEmpty) {
        final engagement = weekActivities.where((a) => a.success).length / weekActivities.length;
        weeklyEngagement[weekKey] = engagement;
      } else {
        weeklyEngagement[weekKey] = 0.0;
      }
    }
    
    return weeklyEngagement;
  }
  
  Map<String, double> _calculateMonthlyTrend(List<ActivityRecord> activities) {
    final monthlyTrend = <String, double>{};
    
    // 월별 트렌드 계산
    final now = DateTime.now();
    for (int i = 0; i < 3; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
      
      final monthActivities = activities.where((a) => 
        a.timestamp.year == monthDate.year && a.timestamp.month == monthDate.month
      ).toList();
      
      if (monthActivities.isNotEmpty) {
        final trend = monthActivities.where((a) => a.success).length / monthActivities.length;
        monthlyTrend[monthKey] = trend;
      } else {
        monthlyTrend[monthKey] = 0.0;
      }
    }
    
    return monthlyTrend;
  }
  
  List<String> _analyzeFatiguePatterns(List<ActivityRecord> activities) {
    final patterns = <String>[];
    
    // 연속 활동 후 성과 감소 패턴 분석
    var consecutiveDays = 0;
    var fatigueCount = 0;
    
    final sortedActivities = activities.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    for (int i = 0; i < sortedActivities.length - 1; i++) {
      final current = sortedActivities[i];
      final next = sortedActivities[i + 1];
      
      if (current.success && next.timestamp.difference(current.timestamp).inDays == 1) {
        consecutiveDays++;
      } else {
        if (consecutiveDays >= 5 && !next.success) {
          fatigueCount++;
        }
        consecutiveDays = 0;
      }
    }
    
    if (fatigueCount > 0) {
      patterns.add('연속 활동 후 피로감으로 인한 성과 감소 경향');
    }
    
    // 주말 피로 패턴
    final weekendFailures = activities.where((a) => 
      (a.timestamp.weekday == DateTime.saturday || a.timestamp.weekday == DateTime.sunday) && !a.success
    ).length;
    
    final weekendTotal = activities.where((a) => 
      a.timestamp.weekday == DateTime.saturday || a.timestamp.weekday == DateTime.sunday
    ).length;
    
    if (weekendTotal > 0 && weekendFailures / weekendTotal > 0.6) {
      patterns.add('주말에 활동 성과 저하 경향');
    }
    
    return patterns;
  }
  
  List<String> _analyzeRecoveryPatterns(List<ActivityRecord> activities) {
    final patterns = <String>[];
    
    // 휴식 후 회복 패턴 분석
    var recoveryCount = 0;
    final sortedActivities = activities.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    for (int i = 1; i < sortedActivities.length; i++) {
      final current = sortedActivities[i];
      final previous = sortedActivities[i - 1];
      
      // 하루 이상 휴식 후 성공적인 활동
      if (!previous.success && 
          current.success && 
          current.timestamp.difference(previous.timestamp).inDays >= 2) {
        recoveryCount++;
      }
    }
    
    if (recoveryCount > 0) {
      patterns.add('휴식 후 활동 성과 회복 패턴 확인');
    }
    
    // 주중 회복 패턴
    final weekdayRecoveries = activities.where((a) => 
      a.timestamp.weekday >= DateTime.monday && 
      a.timestamp.weekday <= DateTime.friday && 
      a.success
    ).length;
    
    final weekdayTotal = activities.where((a) => 
      a.timestamp.weekday >= DateTime.monday && a.timestamp.weekday <= DateTime.friday
    ).length;
    
    if (weekdayTotal > 0 && weekdayRecoveries / weekdayTotal > 0.7) {
      patterns.add('주중에 활동 회복력 강함');
    }
    
    return patterns;
  }
  
  List<int> _identifyOptimalRestPeriods(List<ActivityRecord> activities) {
    final restPeriods = <int>[];
    
    // 성공적인 활동 전후의 휴식 패턴 분석
    final sortedActivities = activities.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final restDurations = <int>[];
    
    for (int i = 1; i < sortedActivities.length; i++) {
      final current = sortedActivities[i];
      final previous = sortedActivities[i - 1];
      
      if (current.success && previous.success) {
        final restDays = current.timestamp.difference(previous.timestamp).inDays - 1;
        if (restDays > 0) {
          restDurations.add(restDays);
        }
      }
    }
    
    if (restDurations.isNotEmpty) {
      // 가장 빈번한 휴식 기간들
      final restFrequency = <int, int>{};
      for (final duration in restDurations) {
        restFrequency[duration] = (restFrequency[duration] ?? 0) + 1;
      }
      
      final sortedRest = restFrequency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      restPeriods.addAll(sortedRest.take(3).map((e) => e.key));
    }
    
    return restPeriods;
  }
  
  double _calculateBurnoutRisk(List<ActivityRecord> activities) {
    if (activities.isEmpty) return 0.0;
    
    // 최근 7일간의 활동 강도 분석
    final recentDate = DateTime.now().subtract(const Duration(days: 7));
    final recentActivities = activities.where((a) => a.timestamp.isAfter(recentDate)).toList();
    
    if (recentActivities.isEmpty) return 0.0;
    
    // 위험 요소들
    double riskScore = 0.0;
    
    // 1. 높은 활동 강도
    final averageIntensity = recentActivities.map((a) => a.intensity).reduce((a, b) => a + b) / recentActivities.length;
    if (averageIntensity > 0.8) riskScore += 0.3;
    
    // 2. 연속 활동일 수
    final consecutiveDays = _countConsecutiveDays(recentActivities);
    if (consecutiveDays > 5) riskScore += 0.3;
    
    // 3. 성공률 감소 추세
    if (recentActivities.length >= 5) {
      final firstHalf = recentActivities.take(recentActivities.length ~/ 2).toList();
      final secondHalf = recentActivities.skip(recentActivities.length ~/ 2).toList();
      
      final firstSuccessRate = firstHalf.where((a) => a.success).length / firstHalf.length;
      final secondSuccessRate = secondHalf.where((a) => a.success).length / secondHalf.length;
      
      if (firstSuccessRate > secondSuccessRate + 0.2) riskScore += 0.2;
    }
    
    // 4. 활동 지속 시간 증가
    final averageDuration = recentActivities.map((a) => a.duration).reduce((a, b) => a + b) / recentActivities.length;
    if (averageDuration > 120) riskScore += 0.2; // 2시간 이상
    
    return riskScore.clamp(0.0, 1.0);
  }
  
  bool _isActivityDecreasing(List<ActivityRecord> activities) {
    if (activities.length < 14) return false;
    
    final sortedActivities = activities.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // 최근 7일과 이전 7일 비교
    final recentWeek = sortedActivities.where((a) => 
      DateTime.now().difference(a.timestamp).inDays <= 7
    ).length;
    
    final previousWeek = sortedActivities.where((a) => 
      DateTime.now().difference(a.timestamp).inDays > 7 && 
      DateTime.now().difference(a.timestamp).inDays <= 14
    ).length;
    
    return recentWeek < previousWeek * 0.7; // 30% 이상 감소
  }
  
  int _countConsecutiveFailures(List<ActivityRecord> activities) {
    final sortedActivities = activities.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    int consecutiveFailures = 0;
    for (final activity in sortedActivities) {
      if (!activity.success) {
        consecutiveFailures++;
      } else {
        break;
      }
    }
    
    return consecutiveFailures;
  }
  
  int _countConsecutiveDays(List<ActivityRecord> activities) {
    if (activities.isEmpty) return 0;
    
    final sortedActivities = activities.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    int consecutiveDays = 0;
    DateTime? lastDate;
    
    for (final activity in sortedActivities) {
      final activityDate = DateTime(activity.timestamp.year, activity.timestamp.month, activity.timestamp.day);
      
      if (lastDate == null) {
        consecutiveDays = 1;
        lastDate = activityDate;
      } else if (lastDate.difference(activityDate).inDays == 1) {
        consecutiveDays++;
        lastDate = activityDate;
      } else {
        break;
      }
    }
    
    return consecutiveDays;
  }
  
  List<OptimalTime> _predictTodayOptimalTimes(TimingPatterns timingPatterns, DateTime today) {
    final optimalTimes = <OptimalTime>[];
    
    // 성공적인 시간대 기반 예측
    for (final hour in timingPatterns.successfulHours) {
      final confidence = timingPatterns.peakActivityHours.contains(hour) ? 0.9 : 0.7;
      
      optimalTimes.add(OptimalTime(
        startTime: DateTime(today.year, today.month, today.day, hour),
        endTime: DateTime(today.year, today.month, today.day, hour + 1),
        confidence: confidence,
        activityType: 'any',
        reason: '과거 성공 패턴 기반',
      ));
    }
    
    // 시간대별 선호도 반영
    for (final timeSlot in timingPatterns.preferredTimeSlots) {
      if (timeSlot.successRate > 0.7) {
        optimalTimes.add(OptimalTime(
          startTime: DateTime(today.year, today.month, today.day, timeSlot.startHour),
          endTime: DateTime(today.year, today.month, today.day, timeSlot.endHour),
          confidence: timeSlot.successRate,
          activityType: 'focused',
          reason: '높은 성공률 시간대',
        ));
      }
    }
    
    // 중복 제거 및 정렬
    optimalTimes.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return optimalTimes.take(5).toList();
  }
  
  Map<String, double> _predictWeeklySuccess(SuccessPatterns successPatterns, EngagementCycles engagementCycles) {
    final predictions = <String, double>{};
    
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final overallSuccess = successPatterns.overallSuccessRate;
    
    // 주간 참여도 패턴 반영
    final weeklyPattern = engagementCycles.weeklyEngagementPattern;
    
    for (int i = 0; i < 7; i++) {
      final dayName = weekdays[i];
      final weekday = i + 1;
      
      // 기본 성공률에서 시작
      double prediction = overallSuccess;
      
      // 시간대별 성공률 반영
      final daySuccessRate = successPatterns.hourlySuccessRates.entries
          .where((entry) => entry.key >= 8 && entry.key <= 20) // 주요 활동 시간대
          .map((entry) => entry.value)
          .fold(0.0, (a, b) => a + b) / 
          successPatterns.hourlySuccessRates.length.clamp(1, double.infinity);
      
      prediction = (prediction + daySuccessRate) / 2;
      
      // 주간 패턴 반영
      if (weeklyPattern.isNotEmpty) {
        final patternKey = 'week_1'; // 가장 최근 주
        final weeklyEngagement = weeklyPattern[patternKey] ?? 0.5;
        prediction = (prediction + weeklyEngagement) / 2;
      }
      
      predictions[dayName] = prediction.clamp(0.0, 1.0);
    }
    
    return predictions;
  }
  
  List<MotivationNeed> _predictMotivationNeeds(List<MotivationTrigger> motivationTriggers, EngagementCycles engagementCycles) {
    final needs = <MotivationNeed>[];
    
    // 번아웃 위험 시기 예측
    if (engagementCycles.burnoutRiskLevel > 0.6) {
      needs.add(MotivationNeed(
        timePoint: DateTime.now().add(const Duration(days: 1)),
        intensity: 'high',
        type: 'recovery_motivation',
        message: '휴식과 회복을 위한 부드러운 격려 필요',
        priority: 1,
      ));
    }
    
    // 주간 시작 동기 부여
    final nextMonday = DateTime.now().add(Duration(days: 8 - DateTime.now().weekday));
    needs.add(MotivationNeed(
      timePoint: nextMonday,
      intensity: 'medium',
      type: 'weekly_kickstart',
      message: '새로운 주의 시작을 위한 동기 부여',
      priority: 2,
    ));
    
    // 효과적인 시간대 기반 동기 부여
    for (final trigger in motivationTriggers) {
      if (trigger.effectiveness > 0.8) {
        DateTime nextTriggerTime;
        
        if (trigger.suggestedTiming.contains(':')) {
          final timeParts = trigger.suggestedTiming.split('-');
          final startTime = timeParts.first.split(':');
          final hour = int.parse(startTime.first);
          
          nextTriggerTime = DateTime.now().add(const Duration(days: 1)).copyWith(
            hour: hour,
            minute: int.parse(startTime.last),
            second: 0,
            millisecond: 0,
          );
        } else {
          nextTriggerTime = DateTime.now().add(const Duration(hours: 2));
        }
        
        needs.add(MotivationNeed(
          timePoint: nextTriggerTime,
          intensity: 'medium',
          type: trigger.type,
          message: trigger.description,
          priority: 3,
        ));
      }
    }
    
    // 우선순위와 시간 순으로 정렬
    needs.sort((a, b) {
      final priorityComparison = a.priority.compareTo(b.priority);
      if (priorityComparison != 0) return priorityComparison;
      return a.timePoint.compareTo(b.timePoint);
    });
    
    return needs.take(5).toList();
  }
  
  List<RiskPeriod> _predictRiskPeriods(SuccessPatterns successPatterns, EngagementCycles engagementCycles) {
    final riskPeriods = <RiskPeriod>[];
    
    // 낮은 성공률 시간대
    successPatterns.hourlySuccessRates.forEach((hour, successRate) {
      if (successRate < 0.3) {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final riskTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour);
        
        riskPeriods.add(RiskPeriod(
          startTime: riskTime,
          endTime: riskTime.add(const Duration(hours: 1)),
          riskLevel: 'medium',
          type: 'low_success_rate',
          description: '${hour}시대 성공률 낮음 (${(successRate * 100).toInt()}%)',
          preventionStrategy: '이 시간대는 가벼운 활동이나 휴식 권장',
        ));
      }
    });
    
    // 피로도 위험 기간
    if (engagementCycles.burnoutRiskLevel > 0.7) {
      final riskStart = DateTime.now();
      final riskEnd = riskStart.add(const Duration(days: 3));
      
      riskPeriods.add(RiskPeriod(
        startTime: riskStart,
        endTime: riskEnd,
        riskLevel: 'high',
        type: 'burnout_risk',
        description: '높은 번아웃 위험 기간',
        preventionStrategy: '충분한 휴식과 강도 조절 필요',
      ));
    }
    
    // 주말 위험 (만약 주말 성공률이 낮다면)
    final weekendActivities = successPatterns.hourlySuccessRates.entries
        .where((entry) => entry.key >= 10 && entry.key <= 16) // 주말 주요 시간
        .toList();
    
    if (weekendActivities.isNotEmpty) {
      final weekendSuccessRate = weekendActivities
          .map((entry) => entry.value)
          .reduce((a, b) => a + b) / weekendActivities.length;
      
      if (weekendSuccessRate < 0.4) {
        final nextSaturday = DateTime.now().add(Duration(days: 6 - DateTime.now().weekday));
        
        riskPeriods.add(RiskPeriod(
          startTime: nextSaturday,
          endTime: nextSaturday.add(const Duration(days: 2)),
          riskLevel: 'medium',
          type: 'weekend_decline',
          description: '주말 활동 성과 저하 위험',
          preventionStrategy: '주말 전용 가벼운 활동 계획 수립',
        ));
      }
    }
    
    // 위험도 순으로 정렬
    riskPeriods.sort((a, b) {
      final levelPriority = {'high': 3, 'medium': 2, 'low': 1};
      return (levelPriority[b.riskLevel] ?? 0).compareTo(levelPriority[a.riskLevel] ?? 0);
    });
    
    return riskPeriods.take(3).toList();
  }
  
  List<String> _generateRecommendedActions(TimingPatterns timingPatterns, SuccessPatterns successPatterns) {
    final actions = <String>[];
    
    // 최적 시간대 활용
    if (timingPatterns.peakActivityHours.isNotEmpty) {
      final peakHours = timingPatterns.peakActivityHours.join(', ');
      actions.add('${peakHours}시에 중요한 활동 집중');
    }
    
    // 성공률 개선
    if (successPatterns.overallSuccessRate < 0.7) {
      actions.add('활동 강도를 조절하여 성공률 개선');
    }
    
    // 일관성 향상
    if (timingPatterns.consistencyScore < 0.5) {
      actions.add('규칙적인 활동 패턴 만들기');
    }
    
    // 최적 조건 활용
    if (successPatterns.optimalConditions.isNotEmpty) {
      final optimalIntensity = successPatterns.optimalConditions['optimalIntensity'] as double?;
      if (optimalIntensity != null) {
        if (optimalIntensity > 0.7) {
          actions.add('높은 강도 활동으로 더 큰 성과 달성');
        } else {
          actions.add('적당한 강도로 꾸준한 진행');
        }
      }
    }
    
    return actions.take(5).toList();
  }
  
  double _calculatePredictionConfidence(TimingPatterns timingPatterns, SuccessPatterns successPatterns) {
    double confidence = 0.0;
    
    // 데이터 양 기반 신뢰도
    final hasEnoughData = timingPatterns.peakActivityHours.isNotEmpty && 
                         successPatterns.hourlySuccessRates.length >= 5;
    if (hasEnoughData) confidence += 0.3;
    
    // 일관성 기반 신뢰도
    confidence += timingPatterns.consistencyScore * 0.3;
    
    // 성공률 기반 신뢰도
    if (successPatterns.overallSuccessRate > 0.5) confidence += 0.2;
    
    // 패턴 명확성 기반 신뢰도
    if (timingPatterns.activityRhythm.confidence > 0.7) confidence += 0.2;
    
    return confidence.clamp(0.0, 1.0);
  }
  
  List<String> _calculateStrategyPriority(Map<String, dynamic> strategies) {
    final priorities = <String>[];
    
    // 위험 완화가 최우선
    final riskStrategies = strategies.keys.where((key) => key.contains('risk_mitigation')).toList();
    riskStrategies.sort((a, b) {
      final aSeverity = strategies[a]['priority'] as String? ?? 'low';
      final bSeverity = strategies[b]['priority'] as String? ?? 'low';
      final severityOrder = {'high': 3, 'medium': 2, 'low': 1};
      return (severityOrder[bSeverity] ?? 0).compareTo(severityOrder[aSeverity] ?? 0);
    });
    priorities.addAll(riskStrategies);
    
    // 성공 최적화
    if (strategies.containsKey('success_optimization')) {
      priorities.add('success_optimization');
    }
    
    // 타이밍 최적화
    if (strategies.containsKey('timing')) {
      priorities.add('timing');
    }
    
    // 동기 부여 강화
    if (strategies.containsKey('motivation_enhancement')) {
      priorities.add('motivation_enhancement');
    }
    
    return priorities;
  }
  
  Map<String, List<String>> _createImplementationPlan(Map<String, dynamic> strategies) {
    final plan = <String, List<String>>{};
    
    plan['immediate'] = []; // 즉시 실행
    plan['short_term'] = []; // 1주일 이내
    plan['long_term'] = []; // 1개월 이내
    
    strategies.forEach((key, strategy) {
      final description = strategy['implementation'] as String? ?? '';
      
      if (key.contains('risk_mitigation')) {
        plan['immediate']!.add(description);
      } else if (key.contains('success_optimization') || key.contains('timing')) {
        plan['short_term']!.add(description);
      } else {
        plan['long_term']!.add(description);
      }
    });
    
    return plan;
  }
  
  Map<String, double> _predictStrategyOutcomes(Map<String, dynamic> strategies, SuccessPatterns successPatterns) {
    final outcomes = <String, double>{};
    
    // 현재 성공률 기준으로 예상 개선치 계산
    final currentSuccessRate = successPatterns.overallSuccessRate;
    
    if (strategies.containsKey('success_optimization')) {
      outcomes['success_rate_improvement'] = (currentSuccessRate + 0.2).clamp(0.0, 1.0);
    }
    
    if (strategies.containsKey('timing')) {
      outcomes['efficiency_improvement'] = 0.15; // 15% 효율성 개선 예상
    }
    
    if (strategies.containsKey('motivation_enhancement')) {
      outcomes['engagement_improvement'] = 0.25; // 25% 참여도 개선 예상
    }
    
    // 위험 완화 효과
    final riskMitigationCount = strategies.keys.where((k) => k.contains('risk_mitigation')).length;
    if (riskMitigationCount > 0) {
      outcomes['risk_reduction'] = (riskMitigationCount * 0.3).clamp(0.0, 1.0);
    }
    
    return outcomes;
  }
  
  double _calculateDataQuality(List<ActivityRecord> activities) {
    if (activities.isEmpty) return 0.0;
    
    double quality = 0.0;
    
    // 데이터 양 (30일 기준)
    final dataRichness = (activities.length / 30.0).clamp(0.0, 1.0);
    quality += dataRichness * 0.4;
    
    // 데이터 다양성 (활동 타입 수)
    final activityTypes = activities.map((a) => a.type).toSet().length;
    final diversity = (activityTypes / 4.0).clamp(0.0, 1.0); // 최대 4개 타입
    quality += diversity * 0.3;
    
    // 데이터 신선도 (최근 7일 활동 비율)
    final recentActivities = activities.where((a) => 
      DateTime.now().difference(a.timestamp).inDays <= 7
    ).length;
    final freshness = (recentActivities / activities.length.clamp(1, double.infinity)).clamp(0.0, 1.0);
    quality += freshness * 0.3;
    
    return quality.clamp(0.0, 1.0);
  }
  
  double _calculateConfidenceScore(List<ActivityRecord> activities) {
    if (activities.isEmpty) return 0.0;
    
    double confidence = 0.0;
    
    // 충분한 데이터량
    if (activities.length >= 20) confidence += 0.3;
    else if (activities.length >= 10) confidence += 0.2;
    else confidence += 0.1;
    
    // 일관된 패턴
    final consistencyScore = _calculateConsistencyScore(activities);
    confidence += consistencyScore * 0.3;
    
    // 성공적인 활동 비율
    final successRate = activities.where((a) => a.success).length / activities.length;
    if (successRate > 0.3) confidence += 0.2;
    
    // 다양한 시간대 데이터
    final uniqueHours = activities.map((a) => a.timestamp.hour).toSet().length;
    if (uniqueHours >= 8) confidence += 0.2;
    else if (uniqueHours >= 5) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }
  
  BehaviorAnalysisResult _createFallbackAnalysis() {
    return BehaviorAnalysisResult(
      timingPatterns: TimingPatterns(
        peakActivityHours: [9, 14, 20],
        peakActivityDays: [1, 2, 3, 4, 5],
        successfulHours: [9, 10, 14, 20],
        consistencyScore: 0.3,
        averageSessionLength: 30,
        preferredTimeSlots: [],
        activityRhythm: ActivityRhythm(pattern: 'irregular', confidence: 0.3),
      ),
      successPatterns: SuccessPatterns(
        overallSuccessRate: 0.5,
        hourlySuccessRates: {},
        intensitySuccessRates: {},
        streakPatterns: {},
        criticalFailurePoints: [],
        successTriggers: [],
        optimalConditions: {},
      ),
      motivationTriggers: [],
      engagementCycles: EngagementCycles(
        weeklyEngagementPattern: {},
        monthlyTrend: {},
        fatigueIndicators: [],
        recoveryIndicators: [],
        optimalRestPeriods: [],
        burnoutRiskLevel: 0.3,
      ),
      riskFactors: [],
      predictions: BehaviorPredictions(
        todayOptimalTimes: [],
        weeklySuccessPrediction: {},
        motivationNeeds: [],
        riskPeriods: [],
        recommendedActions: ['규칙적인 활동 패턴 만들기'],
        confidenceLevel: 0.3,
      ),
      optimizationStrategies: OptimizationStrategies(
        strategies: {},
        priorityOrder: [],
        implementationPlan: {},
        expectedOutcomes: {},
      ),
      analysisTimestamp: DateTime.now(),
      dataQuality: 0.3,
      confidenceScore: 0.3,
    );
  }
  
  Future<void> _saveAnalysisResult(BehaviorAnalysisResult result) async {
    try {
      final resultJson = result.toJson();
      await _prefs.setString('behavior_analysis_result', json.encode(resultJson));
      await _prefs.setString('behavior_analysis_timestamp', result.analysisTimestamp.toIso8601String());
      
      // 🔍 행동 패턴 분석 결과 저장 완료
    } catch (e) {
      // 🔍 분석 결과 저장 실패: $e
    }
  }
}

// Data Models

class ActivityRecord {
  final String type;
  final DateTime timestamp;
  final bool success;
  final double intensity;
  final int duration;
  final Map<String, dynamic> metadata;
  
  ActivityRecord({
    required this.type,
    required this.timestamp,
    required this.success,
    required this.intensity,
    required this.duration,
    required this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    'success': success,
    'intensity': intensity,
    'duration': duration,
    'metadata': metadata,
  };
}

class TimingPatterns {
  final List<int> peakActivityHours;
  final List<int> peakActivityDays;
  final List<int> successfulHours;
  final double consistencyScore;
  final int averageSessionLength;
  final List<TimeSlot> preferredTimeSlots;
  final ActivityRhythm activityRhythm;
  
  TimingPatterns({
    required this.peakActivityHours,
    required this.peakActivityDays,
    required this.successfulHours,
    required this.consistencyScore,
    required this.averageSessionLength,
    required this.preferredTimeSlots,
    required this.activityRhythm,
  });
}

class TimeSlot {
  final int startHour;
  final int endHour;
  final int activityCount;
  final double successRate;
  final double averageIntensity;
  
  TimeSlot({
    required this.startHour,
    required this.endHour,
    required this.activityCount,
    required this.successRate,
    required this.averageIntensity,
  });
}

class ActivityRhythm {
  final String pattern;
  final double confidence;
  
  ActivityRhythm({
    required this.pattern,
    required this.confidence,
  });
}

class SuccessPatterns {
  final double overallSuccessRate;
  final Map<int, double> hourlySuccessRates;
  final Map<String, double> intensitySuccessRates;
  final Map<String, dynamic> streakPatterns;
  final List<String> criticalFailurePoints;
  final List<String> successTriggers;
  final Map<String, dynamic> optimalConditions;
  
  SuccessPatterns({
    required this.overallSuccessRate,
    required this.hourlySuccessRates,
    required this.intensitySuccessRates,
    required this.streakPatterns,
    required this.criticalFailurePoints,
    required this.successTriggers,
    required this.optimalConditions,
  });
}

class MotivationTrigger {
  final String type;
  final String condition;
  final double effectiveness;
  final String description;
  final String suggestedTiming;
  
  MotivationTrigger({
    required this.type,
    required this.condition,
    required this.effectiveness,
    required this.description,
    required this.suggestedTiming,
  });
}

class EngagementCycles {
  final Map<String, double> weeklyEngagementPattern;
  final Map<String, double> monthlyTrend;
  final List<String> fatigueIndicators;
  final List<String> recoveryIndicators;
  final List<int> optimalRestPeriods;
  final double burnoutRiskLevel;
  
  EngagementCycles({
    required this.weeklyEngagementPattern,
    required this.monthlyTrend,
    required this.fatigueIndicators,
    required this.recoveryIndicators,
    required this.optimalRestPeriods,
    required this.burnoutRiskLevel,
  });
}

class RiskFactor {
  final String type;
  final String severity;
  final String description;
  final List<String> recommendations;
  
  RiskFactor({
    required this.type,
    required this.severity,
    required this.description,
    required this.recommendations,
  });
}

class BehaviorPredictions {
  final List<OptimalTime> todayOptimalTimes;
  final Map<String, double> weeklySuccessPrediction;
  final List<MotivationNeed> motivationNeeds;
  final List<RiskPeriod> riskPeriods;
  final List<String> recommendedActions;
  final double confidenceLevel;
  
  BehaviorPredictions({
    required this.todayOptimalTimes,
    required this.weeklySuccessPrediction,
    required this.motivationNeeds,
    required this.riskPeriods,
    required this.recommendedActions,
    required this.confidenceLevel,
  });
}

class OptimalTime {
  final DateTime startTime;
  final DateTime endTime;
  final double confidence;
  final String activityType;
  final String reason;
  
  OptimalTime({
    required this.startTime,
    required this.endTime,
    required this.confidence,
    required this.activityType,
    required this.reason,
  });
}

class MotivationNeed {
  final DateTime timePoint;
  final String intensity;
  final String type;
  final String message;
  final int priority;
  
  MotivationNeed({
    required this.timePoint,
    required this.intensity,
    required this.type,
    required this.message,
    required this.priority,
  });
}

class RiskPeriod {
  final DateTime startTime;
  final DateTime endTime;
  final String riskLevel;
  final String type;
  final String description;
  final String preventionStrategy;
  
  RiskPeriod({
    required this.startTime,
    required this.endTime,
    required this.riskLevel,
    required this.type,
    required this.description,
    required this.preventionStrategy,
  });
}

class OptimizationStrategies {
  final Map<String, dynamic> strategies;
  final List<String> priorityOrder;
  final Map<String, List<String>> implementationPlan;
  final Map<String, double> expectedOutcomes;
  
  OptimizationStrategies({
    required this.strategies,
    required this.priorityOrder,
    required this.implementationPlan,
    required this.expectedOutcomes,
  });
}

class BehaviorAnalysisResult {
  final TimingPatterns timingPatterns;
  final SuccessPatterns successPatterns;
  final List<MotivationTrigger> motivationTriggers;
  final EngagementCycles engagementCycles;
  final List<RiskFactor> riskFactors;
  final BehaviorPredictions predictions;
  final OptimizationStrategies optimizationStrategies;
  final DateTime analysisTimestamp;
  final double dataQuality;
  final double confidenceScore;
  
  BehaviorAnalysisResult({
    required this.timingPatterns,
    required this.successPatterns,
    required this.motivationTriggers,
    required this.engagementCycles,
    required this.riskFactors,
    required this.predictions,
    required this.optimizationStrategies,
    required this.analysisTimestamp,
    required this.dataQuality,
    required this.confidenceScore,
  });
  
  Map<String, dynamic> toJson() => {
    'analysisTimestamp': analysisTimestamp.toIso8601String(),
    'dataQuality': dataQuality,
    'confidenceScore': confidenceScore,
    'timingPatterns': {
      'peakActivityHours': timingPatterns.peakActivityHours,
      'peakActivityDays': timingPatterns.peakActivityDays,
      'successfulHours': timingPatterns.successfulHours,
      'consistencyScore': timingPatterns.consistencyScore,
      'averageSessionLength': timingPatterns.averageSessionLength,
    },
    'successPatterns': {
      'overallSuccessRate': successPatterns.overallSuccessRate,
      'hourlySuccessRates': successPatterns.hourlySuccessRates,
      'intensitySuccessRates': successPatterns.intensitySuccessRates,
      'streakPatterns': successPatterns.streakPatterns,
    },
    'predictions': {
      'confidenceLevel': predictions.confidenceLevel,
      'recommendedActions': predictions.recommendedActions,
    },
    'riskFactors': riskFactors.map((r) => {
      'type': r.type,
      'severity': r.severity,
      'description': r.description,
    }).toList(),
  };
}