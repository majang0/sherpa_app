import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/behavior_pattern_analyzer.dart';
import 'package:sherpa_app/core/ai/user_memory_service.dart';
import 'package:sherpa_app/core/ai/user_profile_analyzer.dart';

/// 🎯 선제적 지원 엔진
/// 
/// 사용자의 행동 패턴과 상황을 분석하여 
/// 문제가 발생하기 전에 맞춤형 조언과 지원을 제공합니다.
class ProactiveSupportEngine {
  final SharedPreferences _prefs;
  final BehaviorPatternAnalyzer _behaviorAnalyzer;
  final UserProfileAnalyzer _profileAnalyzer;
  final UserMemoryService _memoryService;
  
  // 캐시된 지원 계획
  ProactiveSupportPlan? _currentSupportPlan;
  DateTime? _lastPlanUpdate;
  
  // 지원 실행 타이머
  Timer? _supportTimer;
  
  // 지원 기록
  final List<ProactiveSupportAction> _executedActions = [];
  static const int _maxActionHistory = 100;
  
  // 설정
  static const Duration _planUpdateInterval = Duration(hours: 12);
  static const Duration _supportCheckInterval = Duration(minutes: 30);
  
  ProactiveSupportEngine(this._prefs)
      : _behaviorAnalyzer = BehaviorPatternAnalyzer(_prefs),
        _profileAnalyzer = UserProfileAnalyzer(_prefs),
        _memoryService = UserMemoryService(_prefs) {
    _initializeProactiveSupport();
  }
  
  /// 선제적 지원 시스템 초기화
  Future<void> _initializeProactiveSupport() async {
    try {
      // 기존 계획 로드
      await _loadExistingSupportPlan();
      
      // 지원 계획 생성 (필요시)
      await _updateSupportPlanIfNeeded();
      
      // 정기적 지원 체크 시작
      _startPeriodicSupportCheck();
      
      print('🎯 선제적 지원 엔진 초기화 완료');
    } catch (e) {
      // 🎯 선제적 지원 엔진 초기화 실패: $e
    }
  }
  
  /// 🧠 종합 지원 계획 생성
  Future<ProactiveSupportPlan> generateSupportPlan() async {
    try {
      // 🧠 선제적 지원 계획 생성 시작
      
      // 행동 패턴 분석
      final behaviorAnalysis = await _behaviorAnalyzer.analyzeBehaviorPatterns();
      
      // 사용자 프로필 분석
      final userProfile = await _profileAnalyzer.analyzeUserProfile(
        userContext: {},
        gameContext: {},
      );
      
      // 메모리 서비스에서 학습 데이터 가져오기
      final learningInsights = await _memoryService.generatePersonalizationInsights();
      
      // 위험 요소 식별
      final riskFactors = await _identifyRiskFactors(behaviorAnalysis, userProfile);
      
      // 기회 요소 식별
      final opportunities = await _identifyOpportunities(behaviorAnalysis, userProfile);
      
      // 맞춤형 지원 전략 생성
      final supportStrategies = await _generateSupportStrategies(
        behaviorAnalysis, 
        userProfile, 
        riskFactors, 
        opportunities
      );
      
      // 실행 계획 수립
      final actionPlan = await _createActionPlan(supportStrategies, behaviorAnalysis);
      
      // 성공 지표 정의
      final successMetrics = _defineSuccessMetrics(userProfile, behaviorAnalysis);
      
      final supportPlan = ProactiveSupportPlan(
        planId: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 7)),
        behaviorAnalysis: behaviorAnalysis,
        userProfile: userProfile,
        riskFactors: riskFactors,
        opportunities: opportunities,
        supportStrategies: supportStrategies,
        actionPlan: actionPlan,
        successMetrics: successMetrics,
        learningInsights: learningInsights,
        confidenceScore: _calculatePlanConfidence(behaviorAnalysis, userProfile),
      );
      
      // 계획 저장
      await _saveSupportPlan(supportPlan);
      
      print('🧠 선제적 지원 계획 생성 완료 - 신뢰도: ${(supportPlan.confidenceScore * 100).toInt()}%');
      
      return supportPlan;
      
    } catch (e) {
      // 🧠 지원 계획 생성 실패: $e
      return _createFallbackSupportPlan();
    }
  }
  
  /// ⚠️ 위험 요소 식별
  Future<List<RiskFactor>> _identifyRiskFactors(
    BehaviorAnalysisResult behaviorAnalysis,
    UserPersonalizationProfile userProfile,
  ) async {
    final riskFactors = <RiskFactor>[];
    
    // 기존 위험 요소에서 추가
    riskFactors.addAll(behaviorAnalysis.riskFactors);
    
    // 추가 위험 요소 분석
    
    // 1. 동기 부여 감소 위험
    if (userProfile.motivationTriggers.length < 2) {
      riskFactors.add(RiskFactor(
        type: 'motivation_decline',
        severity: 'medium',
        description: '동기 부여 요소가 부족하여 지속성 저하 위험',
        recommendations: [
          '새로운 동기 부여 요소 탐색',
          '성취감을 느낄 수 있는 작은 목표 설정',
          '사회적 지원 체계 구축'
        ],
      ));
    }
    
    // 2. 사회적 고립 위험
    final socialPatterns = userProfile.activityPatterns['socialActivity'] as bool? ?? false;
    if (!socialPatterns) {
      riskFactors.add(RiskFactor(
        type: 'social_isolation',
        severity: 'low',
        description: '사회적 활동 부족으로 인한 고립 위험',
        recommendations: [
          '커뮤니티 활동 참여 권장',
          '온라인 그룹 활동 제안',
          '친구와의 활동 계획 수립'
        ],
      ));
    }
    
    // 3. 목표 불명확성 위험
    if (userProfile.strugglingAreas.contains('goal_clarity')) {
      riskFactors.add(RiskFactor(
        type: 'unclear_goals',
        severity: 'medium',
        description: '목표가 불분명하여 방향성 상실 위험',
        recommendations: [
          'SMART 목표 설정 방법 안내',
          '단계별 목표 분해 지원',
          '정기적인 목표 검토 일정 제안'
        ],
      ));
    }
    
    // 4. 완벽주의 위험
    if (userProfile.primaryPersonalityType == '성취형' && 
        behaviorAnalysis.successPatterns.overallSuccessRate < 0.6) {
      riskFactors.add(RiskFactor(
        type: 'perfectionism_paralysis',
        severity: 'high',
        description: '완벽주의 성향으로 인한 실행 저해 위험',
        recommendations: [
          '완료보다는 진전에 집중하기',
          '80% 규칙 적용하기',
          '실패를 학습 기회로 재정의하기'
        ],
      ));
    }
    
    return riskFactors;
  }
  
  /// 🌟 기회 요소 식별
  Future<List<OpportunityFactor>> _identifyOpportunities(
    BehaviorAnalysisResult behaviorAnalysis,
    UserPersonalizationProfile userProfile,
  ) async {
    final opportunities = <OpportunityFactor>[];
    
    // 1. 최적 시간대 활용 기회
    if (behaviorAnalysis.timingPatterns.peakActivityHours.isNotEmpty) {
      final peakHours = behaviorAnalysis.timingPatterns.peakActivityHours;
      opportunities.add(OpportunityFactor(
        type: 'optimal_timing',
        potential: 'high',
        description: '최적 활동 시간대(${peakHours.join(', ')}시) 활용 가능',
        actionPlan: [
          '중요한 활동을 최적 시간대로 이동',
          '피크 시간 전후 준비 시간 확보',
          '최적 시간대 알림 설정'
        ],
        expectedImpact: 0.25, // 25% 성과 향상 예상
      ));
    }
    
    // 2. 성공 패턴 강화 기회
    if (behaviorAnalysis.successPatterns.successTriggers.isNotEmpty) {
      opportunities.add(OpportunityFactor(
        type: 'success_amplification',
        potential: 'high',
        description: '기존 성공 패턴을 다른 영역으로 확장 가능',
        actionPlan: [
          '성공 요소를 새로운 활동에 적용',
          '성공 패턴을 의식적으로 반복',
          '성공 경험을 기록하고 분석하기'
        ],
        expectedImpact: 0.30,
      ));
    }
    
    // 3. 성격 타입 최적화 기회
    switch (userProfile.primaryPersonalityType) {
      case '성취형':
        opportunities.add(OpportunityFactor(
          type: 'achievement_optimization',
          potential: 'high',
          description: '성취 지향성을 활용한 목표 달성 시스템 구축',
          actionPlan: [
            '구체적이고 측정 가능한 목표 설정',
            '진척도 시각화 도구 활용',
            '성취 단계별 보상 시스템'
          ],
          expectedImpact: 0.35,
        ));
        break;
      case '탐험형':
        opportunities.add(OpportunityFactor(
          type: 'exploration_enhancement',
          potential: 'medium',
          description: '호기심과 탐험욕을 활용한 다양성 증진',
          actionPlan: [
            '새로운 활동과 도전 제안',
            '다양한 접근 방식 실험',
            '변화와 혁신 요소 도입'
          ],
          expectedImpact: 0.20,
        ));
        break;
      case '지식형':
        opportunities.add(OpportunityFactor(
          type: 'learning_acceleration',
          potential: 'high',
          description: '학습 욕구를 활용한 체계적 성장',
          actionPlan: [
            '심화 학습 경로 제공',
            '지식 공유 기회 창출',
            '전문성 개발 로드맵 수립'
          ],
          expectedImpact: 0.28,
        ));
        break;
      case '사교형':
        opportunities.add(OpportunityFactor(
          type: 'social_leverage',
          potential: 'medium',
          description: '사회적 상호작용을 통한 동기 부여 강화',
          actionPlan: [
            '커뮤니티 활동 참여 확대',
            '협력 기반 목표 설정',
            '사회적 책무성 활용'
          ],
          expectedImpact: 0.22,
        ));
        break;
      case '균형형':
        opportunities.add(OpportunityFactor(
          type: 'stability_optimization',
          potential: 'medium',
          description: '안정성과 일관성을 바탕으로 한 지속적 성장',
          actionPlan: [
            '단계적이고 점진적인 목표 설정',
            '루틴과 습관 기반 시스템',
            '장기적 관점의 계획 수립'
          ],
          expectedImpact: 0.18,
        ));
        break;
    }
    
    // 4. 데이터 리치니스 기회
    if (userProfile.dataRichness > 0.7) {
      opportunities.add(OpportunityFactor(
        type: 'data_driven_optimization',
        potential: 'high',
        description: '풍부한 데이터를 활용한 정밀 개인화',
        actionPlan: [
          '상세 패턴 분석 기반 최적화',
          '예측 모델 활용 선제적 조치',
          '개인화 수준 극대화'
        ],
        expectedImpact: 0.20,
      ));
    }
    
    return opportunities;
  }
  
  /// 🎯 맞춤형 지원 전략 생성
  Future<List<SupportStrategy>> _generateSupportStrategies(
    BehaviorAnalysisResult behaviorAnalysis,
    UserPersonalizationProfile userProfile,
    List<RiskFactor> riskFactors,
    List<OpportunityFactor> opportunities,
  ) async {
    final strategies = <SupportStrategy>[];
    
    // 1. 위험 완화 전략
    for (final risk in riskFactors) {
      strategies.add(SupportStrategy(
        id: 'risk_mitigation_${risk.type}',
        type: 'risk_mitigation',
        priority: _getRiskPriority(risk.severity),
        title: '${risk.description} 완화',
        description: risk.recommendations.join(', '),
        targetRiskFactor: risk,
        interventions: risk.recommendations.map((rec) => 
          SupportIntervention(
            type: 'guidance',
            trigger: 'schedule_based',
            content: rec,
            timing: _calculateOptimalInterventionTiming(risk.type, behaviorAnalysis),
            frequency: _determineInterventionFrequency(risk.severity),
          )
        ).toList(),
        successCriteria: _defineSupportSuccessCriteria(risk.type),
        expectedOutcome: '위험 요소 ${risk.severity} 수준 감소',
      ));
    }
    
    // 2. 기회 활용 전략
    for (final opportunity in opportunities) {
      strategies.add(SupportStrategy(
        id: 'opportunity_${opportunity.type}',
        type: 'opportunity_enhancement',
        priority: _getOpportunityPriority(opportunity.potential),
        title: '${opportunity.description} 활용',
        description: opportunity.actionPlan.join(', '),
        targetOpportunity: opportunity,
        interventions: opportunity.actionPlan.map((action) =>
          SupportIntervention(
            type: 'suggestion',
            trigger: 'optimal_timing',
            content: action,
            timing: _calculateOptimalInterventionTiming(opportunity.type, behaviorAnalysis),
            frequency: 'weekly',
          )
        ).toList(),
        successCriteria: _defineSupportSuccessCriteria(opportunity.type),
        expectedOutcome: '${(opportunity.expectedImpact * 100).toInt()}% 성과 향상',
      ));
    }
    
    // 3. 개인화 맞춤 전략
    final personalizedStrategy = await _generatePersonalizedStrategy(userProfile, behaviorAnalysis);
    if (personalizedStrategy != null) {
      strategies.add(personalizedStrategy);
    }
    
    // 4. 예방적 지원 전략
    final preventiveStrategy = await _generatePreventiveStrategy(behaviorAnalysis);
    if (preventiveStrategy != null) {
      strategies.add(preventiveStrategy);
    }
    
    // 우선순위 순으로 정렬
    strategies.sort((a, b) => a.priority.compareTo(b.priority));
    
    return strategies;
  }
  
  /// 📅 실행 계획 수립
  Future<ActionPlan> _createActionPlan(
    List<SupportStrategy> supportStrategies,
    BehaviorAnalysisResult behaviorAnalysis,
  ) async {
    final actions = <ProactiveSupportAction>[];
    
    // 전략별 구체적 액션 생성
    for (final strategy in supportStrategies) {
      for (final intervention in strategy.interventions) {
        final action = ProactiveSupportAction(
          id: '${strategy.id}_${DateTime.now().millisecondsSinceEpoch}',
          strategyId: strategy.id,
          type: intervention.type,
          title: _generateActionTitle(strategy, intervention),
          content: intervention.content,
          scheduledTime: _calculateScheduledTime(intervention, behaviorAnalysis),
          priority: strategy.priority,
          context: SherpiContext.encouragement, // 기본값, 상황에 따라 조정
          personalizedMessage: await _generatePersonalizedMessage(strategy, intervention),
          successCriteria: strategy.successCriteria,
          isExecuted: false,
          createdAt: DateTime.now(),
        );
        
        actions.add(action);
      }
    }
    
    // 시간순으로 정렬
    actions.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    
    return ActionPlan(
      planId: DateTime.now().millisecondsSinceEpoch.toString(),
      actions: actions,
      totalActions: actions.length,
      highPriorityActions: actions.where((a) => a.priority <= 2).length,
      estimatedDuration: const Duration(days: 7),
      adaptationRules: _defineAdaptationRules(),
    );
  }
  
  /// 🎯 선제적 지원 실행
  Future<void> executeProactiveSupport() async {
    try {
      if (_currentSupportPlan == null) {
        await _updateSupportPlanIfNeeded();
        if (_currentSupportPlan == null) return;
      }
      
      final now = DateTime.now();
      final pendingActions = _currentSupportPlan!.actionPlan.actions
          .where((action) => 
            !action.isExecuted && 
            action.scheduledTime.isBefore(now.add(const Duration(minutes: 5)))
          )
          .toList();
      
      for (final action in pendingActions) {
        await _executeAction(action);
      }
      
      // 🎯 선제적 지원 실행 완료: ${pendingActions.length}개 액션
      
    } catch (e) {
      // 🎯 선제적 지원 실행 실패: $e
    }
  }
  
  /// 🚀 개별 액션 실행
  Future<void> _executeAction(ProactiveSupportAction action) async {
    try {
      // 실행 조건 확인
      if (!await _validateActionExecution(action)) {
        // 🚀 액션 실행 조건 불충족: ${action.id}
        return;
      }
      
      // 액션 타입에 따른 실행
      switch (action.type) {
        case 'notification':
          await _sendProactiveNotification(action);
          break;
        case 'guidance':
          await _provideGuidance(action);
          break;
        case 'suggestion':
          await _makeSuggestion(action);
          break;
        case 'reminder':
          await _sendReminder(action);
          break;
        case 'encouragement':
          await _provideEncouragement(action);
          break;
        default:
          await _executeGenericAction(action);
      }
      
      // 실행 기록
      action.isExecuted = true;
      action.executedAt = DateTime.now();
      _executedActions.insert(0, action);
      
      // 기록 크기 제한
      if (_executedActions.length > _maxActionHistory) {
        _executedActions.removeLast();
      }
      
      // 성과 추적
      await _trackActionPerformance(action);
      
      // 🚀 액션 실행 완료: ${action.title}
      
    } catch (e) {
      // 🚀 액션 실행 실패: ${action.id} - $e
    }
  }
  
  /// 📊 지원 효과성 분석
  Future<SupportEffectivenessReport> analyzeSupportEffectiveness() async {
    try {
      final executedActions = _executedActions.take(50).toList();
      
      if (executedActions.isEmpty) {
        return SupportEffectivenessReport(
          reportId: DateTime.now().millisecondsSinceEpoch.toString(),
          generatedAt: DateTime.now(),
          totalActionsExecuted: 0,
          averageEffectiveness: 0.0,
          categoryBreakdown: {},
          insights: ['아직 충분한 데이터가 없습니다'],
          recommendations: ['지속적인 시스템 사용을 권장합니다'],
        );
      }
      
      // 카테고리별 분석
      final categoryBreakdown = <String, double>{};
      final actionsByType = <String, List<ProactiveSupportAction>>{};
      
      for (final action in executedActions) {
        actionsByType.putIfAbsent(action.type, () => []).add(action);
      }
      
      for (final entry in actionsByType.entries) {
        final type = entry.key;
        final actions = entry.value;
        final effectiveness = actions
            .map((a) => a.effectivenessScore ?? 0.5)
            .reduce((a, b) => a + b) / actions.length;
        categoryBreakdown[type] = effectiveness;
      }
      
      // 전체 효과성
      final overallEffectiveness = categoryBreakdown.values.isEmpty
          ? 0.0
          : categoryBreakdown.values.reduce((a, b) => a + b) / categoryBreakdown.length;
      
      // 인사이트 생성
      final insights = _generateEffectivenessInsights(executedActions, categoryBreakdown);
      
      // 개선 권장사항
      final recommendations = _generateEffectivenessRecommendations(categoryBreakdown, overallEffectiveness);
      
      return SupportEffectivenessReport(
        reportId: DateTime.now().millisecondsSinceEpoch.toString(),
        generatedAt: DateTime.now(),
        totalActionsExecuted: executedActions.length,
        averageEffectiveness: overallEffectiveness,
        categoryBreakdown: categoryBreakdown,
        insights: insights,
        recommendations: recommendations,
      );
      
    } catch (e) {
      // 📊 지원 효과성 분석 실패: $e
      return SupportEffectivenessReport(
        reportId: 'error',
        generatedAt: DateTime.now(),
        totalActionsExecuted: 0,
        averageEffectiveness: 0.0,
        categoryBreakdown: {},
        insights: ['분석 중 오류 발생'],
        recommendations: ['시스템 재시작 권장'],
      );
    }
  }
  
  /// 🎯 맞춤형 조언 생성
  Future<List<PersonalizedAdvice>> generatePersonalizedAdvice({
    required SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  }) async {
    try {
      final advice = <PersonalizedAdvice>[];
      
      // 현재 지원 계획에서 관련 조언 추출
      if (_currentSupportPlan != null) {
        final relevantStrategies = _currentSupportPlan!.supportStrategies
            .where((strategy) => _isStrategyRelevant(strategy, context))
            .toList();
        
        for (final strategy in relevantStrategies) {
          final personalizedAdvice = PersonalizedAdvice(
            id: '${strategy.id}_advice',
            category: strategy.type,
            priority: strategy.priority,
            title: strategy.title,
            content: strategy.description,
            context: context,
            personalizationLevel: 'high',
            confidence: _currentSupportPlan!.confidenceScore,
            expiresAt: DateTime.now().add(const Duration(hours: 6)),
            actionable: true,
            source: 'proactive_support_engine',
          );
          
          advice.add(personalizedAdvice);
        }
      }
      
      // 상황별 즉시 조언 생성
      final contextualAdvice = await _generateContextualAdvice(context, userContext, gameContext);
      advice.addAll(contextualAdvice);
      
      // 우선순위와 관련성 순으로 정렬
      advice.sort((a, b) {
        final priorityComparison = a.priority.compareTo(b.priority);
        if (priorityComparison != 0) return priorityComparison;
        return b.confidence.compareTo(a.confidence);
      });
      
      return advice.take(5).toList(); // 최대 5개
      
    } catch (e) {
      // 🎯 맞춤형 조언 생성 실패: $e
      return [];
    }
  }
  
  /// 🔄 지원 계획 적응 및 업데이트
  Future<void> adaptSupportPlan({
    required String actionId,
    required double effectivenessScore,
    Map<String, dynamic>? userFeedback,
  }) async {
    try {
      if (_currentSupportPlan == null) return;
      
      // 액션 효과성 기록
      final action = _executedActions.firstWhere(
        (a) => a.id == actionId,
        orElse: () => throw Exception('Action not found'),
      );
      
      action.effectivenessScore = effectivenessScore;
      action.userFeedback = userFeedback;
      
      // 적응 규칙 적용
      await _applyAdaptationRules(action, effectivenessScore);
      
      // 학습 데이터 업데이트
      await _updateLearningData(action, effectivenessScore, userFeedback);
      
      // 🔄 지원 계획 적응 완료: $actionId
      
    } catch (e) {
      // 🔄 지원 계획 적응 실패: $e
    }
  }
  
  /// 🧹 정리 및 최적화
  Future<void> cleanup() async {
    try {
      _supportTimer?.cancel();
      
      // 만료된 계획 정리
      if (_currentSupportPlan != null && 
          DateTime.now().isAfter(_currentSupportPlan!.validUntil)) {
        _currentSupportPlan = null;
        _lastPlanUpdate = null;
      }
      
      // 오래된 실행 기록 정리
      final cutoffTime = DateTime.now().subtract(const Duration(days: 30));
      _executedActions.removeWhere((action) => 
        action.executedAt != null && action.executedAt!.isBefore(cutoffTime));
      
      // 🧹 선제적 지원 엔진 정리 완료
      
    } catch (e) {
      // 🧹 선제적 지원 엔진 정리 실패: $e
    }
  }
  
  // ==================== 헬퍼 메서드들 ====================
  
  /// 기존 지원 계획 로드
  Future<void> _loadExistingSupportPlan() async {
    try {
      final planJson = _prefs.getString('proactive_support_plan');
      if (planJson != null) {
        final planData = json.decode(planJson);
        final plan = ProactiveSupportPlan.fromJson(planData);
        
        // 유효한 계획인지 확인
        if (DateTime.now().isBefore(plan.validUntil)) {
          _currentSupportPlan = plan;
          _lastPlanUpdate = plan.createdAt;
        }
      }
    } catch (e) {
      // 기존 지원 계획 로드 실패: $e
    }
  }
  
  /// 지원 계획 저장
  Future<void> _saveSupportPlan(ProactiveSupportPlan plan) async {
    try {
      final planJson = json.encode(plan.toJson());
      await _prefs.setString('proactive_support_plan', planJson);
      _currentSupportPlan = plan;
      _lastPlanUpdate = plan.createdAt;
    } catch (e) {
      // 지원 계획 저장 실패: $e
    }
  }
  
  /// 지원 계획 업데이트 필요 여부 확인
  Future<void> _updateSupportPlanIfNeeded() async {
    final now = DateTime.now();
    
    if (_currentSupportPlan == null ||
        _lastPlanUpdate == null ||
        now.difference(_lastPlanUpdate!).compareTo(_planUpdateInterval) > 0 ||
        now.isAfter(_currentSupportPlan!.validUntil)) {
      
      await generateSupportPlan();
    }
  }
  
  /// 정기적 지원 체크 시작
  void _startPeriodicSupportCheck() {
    _supportTimer?.cancel();
    _supportTimer = Timer.periodic(_supportCheckInterval, (timer) {
      executeProactiveSupport();
    });
  }
  
  /// 계획 신뢰도 계산
  double _calculatePlanConfidence(
    BehaviorAnalysisResult behaviorAnalysis,
    UserPersonalizationProfile userProfile,
  ) {
    double confidence = 0.0;
    
    // 행동 분석 신뢰도
    confidence += behaviorAnalysis.confidenceScore * 0.4;
    
    // 데이터 리치니스
    confidence += userProfile.dataRichness * 0.3;
    
    // 패턴 일관성
    confidence += behaviorAnalysis.timingPatterns.consistencyScore * 0.2;
    
    // 성공률
    if (behaviorAnalysis.successPatterns.overallSuccessRate > 0.5) {
      confidence += 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }
  
  /// 폴백 지원 계획 생성
  ProactiveSupportPlan _createFallbackSupportPlan() {
    return ProactiveSupportPlan(
      planId: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 1)),
      behaviorAnalysis: null,
      userProfile: null,
      riskFactors: [],
      opportunities: [],
      supportStrategies: [
        SupportStrategy(
          id: 'basic_encouragement',
          type: 'encouragement',
          priority: 3,
          title: '기본 격려 지원',
          description: '규칙적인 격려 메시지 제공',
          interventions: [
            SupportIntervention(
              type: 'encouragement',
              trigger: 'schedule_based',
              content: '오늘도 좋은 하루 보내세요! 작은 진전도 큰 성취입니다.',
              timing: DateTime.now().add(const Duration(hours: 2)),
              frequency: 'daily',
            ),
          ],
          successCriteria: ['사용자 참여도 유지'],
          expectedOutcome: '기본적인 동기 부여 제공',
        ),
      ],
      actionPlan: ActionPlan(
        planId: 'fallback_actions',
        actions: [],
        totalActions: 0,
        highPriorityActions: 0,
        estimatedDuration: const Duration(days: 1),
        adaptationRules: {},
      ),
      successMetrics: {
        'user_engagement': 0.5,
        'activity_completion': 0.3,
      },
      learningInsights: {},
      confidenceScore: 0.3,
    );
  }
  
  int _getRiskPriority(String severity) {
    switch (severity) {
      case 'high': return 1;
      case 'medium': return 2;
      case 'low': return 3;
      default: return 3;
    }
  }
  
  int _getOpportunityPriority(String potential) {
    switch (potential) {
      case 'high': return 1;
      case 'medium': return 2;
      case 'low': return 3;
      default: return 3;
    }
  }
  
  DateTime _calculateOptimalInterventionTiming(String type, BehaviorAnalysisResult behaviorAnalysis) {
    final now = DateTime.now();
    
    // 성공적인 시간대 활용
    if (behaviorAnalysis.timingPatterns.successfulHours.isNotEmpty) {
      final optimalHour = behaviorAnalysis.timingPatterns.successfulHours.first;
      return DateTime(now.year, now.month, now.day + 1, optimalHour);
    }
    
    // 기본값: 2시간 후
    return now.add(const Duration(hours: 2));
  }
  
  String _determineInterventionFrequency(String severity) {
    switch (severity) {
      case 'high': return 'daily';
      case 'medium': return 'every_2_days';
      case 'low': return 'weekly';
      default: return 'weekly';
    }
  }
  
  List<String> _defineSupportSuccessCriteria(String type) {
    switch (type) {
      case 'motivation_decline':
        return ['동기 부여 지표 개선', '활동 참여율 증가'];
      case 'social_isolation':
        return ['사회적 활동 증가', '커뮤니티 참여'];
      case 'unclear_goals':
        return ['구체적 목표 설정', '진척도 측정 가능'];
      case 'perfectionism_paralysis':
        return ['완료율 개선', '시작률 증가'];
      default:
        return ['일반적 개선', '사용자 만족도 향상'];
    }
  }
  
  Future<SupportStrategy?> _generatePersonalizedStrategy(
    UserPersonalizationProfile userProfile,
    BehaviorAnalysisResult behaviorAnalysis,
  ) async {
    // 개인화된 전략 로직 구현
    return null; // 현재는 기본 구현
  }
  
  Future<SupportStrategy?> _generatePreventiveStrategy(
    BehaviorAnalysisResult behaviorAnalysis,
  ) async {
    // 예방적 전략 로직 구현
    return null; // 현재는 기본 구현
  }
  
  String _generateActionTitle(SupportStrategy strategy, SupportIntervention intervention) {
    return '${strategy.title}: ${intervention.type}';
  }
  
  DateTime _calculateScheduledTime(SupportIntervention intervention, BehaviorAnalysisResult behaviorAnalysis) {
    if (intervention.timing != null) {
      return intervention.timing!;
    }
    
    // 기본값: 30분 후
    return DateTime.now().add(const Duration(minutes: 30));
  }
  
  Future<String> _generatePersonalizedMessage(SupportStrategy strategy, SupportIntervention intervention) async {
    return intervention.content; // 기본 구현
  }
  
  Map<String, dynamic> _defineAdaptationRules() {
    return {
      'effectiveness_threshold': 0.6,
      'adaptation_sensitivity': 0.2,
      'learning_rate': 0.1,
    };
  }
  
  Future<bool> _validateActionExecution(ProactiveSupportAction action) async {
    // 실행 조건 검증 로직
    return true; // 기본값
  }
  
  Future<void> _sendProactiveNotification(ProactiveSupportAction action) async {
    // 📱 알림 전송: ${action.title}
  }
  
  Future<void> _provideGuidance(ProactiveSupportAction action) async {
    // 🧭 가이드 제공: ${action.content}
  }
  
  Future<void> _makeSuggestion(ProactiveSupportAction action) async {
    // 💡 제안 전달: ${action.content}
  }
  
  Future<void> _sendReminder(ProactiveSupportAction action) async {
    // ⏰ 리마인더: ${action.content}
  }
  
  Future<void> _provideEncouragement(ProactiveSupportAction action) async {
    // 🎉 격려 메시지: ${action.content}
  }
  
  Future<void> _executeGenericAction(ProactiveSupportAction action) async {
    // ⚙️ 일반 액션 실행: ${action.title}
  }
  
  Future<void> _trackActionPerformance(ProactiveSupportAction action) async {
    // 성과 추적 로직
  }
  
  List<String> _generateEffectivenessInsights(
    List<ProactiveSupportAction> actions,
    Map<String, double> categoryBreakdown,
  ) {
    final insights = <String>[];
    
    if (categoryBreakdown.isNotEmpty) {
      final bestCategory = categoryBreakdown.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add('${bestCategory.key} 유형의 지원이 가장 효과적입니다');
    }
    
    return insights;
  }
  
  List<String> _generateEffectivenessRecommendations(
    Map<String, double> categoryBreakdown,
    double overallEffectiveness,
  ) {
    final recommendations = <String>[];
    
    if (overallEffectiveness < 0.5) {
      recommendations.add('지원 전략을 재검토하고 개선이 필요합니다');
    }
    
    return recommendations;
  }
  
  bool _isStrategyRelevant(SupportStrategy strategy, SherpiContext context) {
    // 전략 관련성 판단 로직
    return true; // 기본값
  }
  
  Future<List<PersonalizedAdvice>> _generateContextualAdvice(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 상황별 조언 생성 로직
    return []; // 기본 구현
  }
  
  Future<void> _applyAdaptationRules(ProactiveSupportAction action, double effectivenessScore) async {
    // 적응 규칙 적용 로직
  }
  
  Future<void> _updateLearningData(
    ProactiveSupportAction action,
    double effectivenessScore,
    Map<String, dynamic>? userFeedback,
  ) async {
    // 학습 데이터 업데이트 로직
  }
  
  /// 성공 지표 정의
  Map<String, double> _defineSuccessMetrics(
    UserPersonalizationProfile userProfile,
    BehaviorAnalysisResult behaviorAnalysis,
  ) {
    return {
      'user_engagement': 0.7,
      'activity_completion': behaviorAnalysis.successPatterns.overallSuccessRate + 0.1,
      'motivation_level': 0.6,
      'system_usage': 0.8,
    };
  }
}

// Data Models

class ProactiveSupportPlan {
  final String planId;
  final DateTime createdAt;
  final DateTime validUntil;
  final BehaviorAnalysisResult? behaviorAnalysis;
  final UserPersonalizationProfile? userProfile;
  final List<RiskFactor> riskFactors;
  final List<OpportunityFactor> opportunities;
  final List<SupportStrategy> supportStrategies;
  final ActionPlan actionPlan;
  final Map<String, double> successMetrics;
  final Map<String, dynamic> learningInsights;
  final double confidenceScore;
  
  ProactiveSupportPlan({
    required this.planId,
    required this.createdAt,
    required this.validUntil,
    required this.behaviorAnalysis,
    required this.userProfile,
    required this.riskFactors,
    required this.opportunities,
    required this.supportStrategies,
    required this.actionPlan,
    required this.successMetrics,
    required this.learningInsights,
    required this.confidenceScore,
  });
  
  Map<String, dynamic> toJson() => {
    'planId': planId,
    'createdAt': createdAt.toIso8601String(),
    'validUntil': validUntil.toIso8601String(),
    'riskFactors': riskFactors.map((r) => {
      'type': r.type,
      'severity': r.severity,
      'description': r.description,
      'recommendations': r.recommendations,
    }).toList(),
    'opportunities': opportunities.map((o) => {
      'type': o.type,
      'potential': o.potential,
      'description': o.description,
      'expectedImpact': o.expectedImpact,
    }).toList(),
    'supportStrategies': supportStrategies.map((s) => {
      'id': s.id,
      'type': s.type,
      'priority': s.priority,
      'title': s.title,
      'description': s.description,
    }).toList(),
    'successMetrics': successMetrics,
    'learningInsights': learningInsights,
    'confidenceScore': confidenceScore,
  };
  
  factory ProactiveSupportPlan.fromJson(Map<String, dynamic> json) {
    return ProactiveSupportPlan(
      planId: json['planId'],
      createdAt: DateTime.parse(json['createdAt']),
      validUntil: DateTime.parse(json['validUntil']),
      behaviorAnalysis: null, // 단순화
      userProfile: null, // 단순화
      riskFactors: [], // 단순화
      opportunities: [], // 단순화
      supportStrategies: [], // 단순화
      actionPlan: ActionPlan(
        planId: json['planId'],
        actions: [],
        totalActions: 0,
        highPriorityActions: 0,
        estimatedDuration: const Duration(days: 7),
        adaptationRules: {},
      ),
      successMetrics: Map<String, double>.from(json['successMetrics'] ?? {}),
      learningInsights: Map<String, dynamic>.from(json['learningInsights'] ?? {}),
      confidenceScore: json['confidenceScore']?.toDouble() ?? 0.0,
    );
  }
}

class OpportunityFactor {
  final String type;
  final String potential;
  final String description;
  final List<String> actionPlan;
  final double expectedImpact;
  
  OpportunityFactor({
    required this.type,
    required this.potential,
    required this.description,
    required this.actionPlan,
    required this.expectedImpact,
  });
}

class SupportStrategy {
  final String id;
  final String type;
  final int priority;
  final String title;
  final String description;
  final RiskFactor? targetRiskFactor;
  final OpportunityFactor? targetOpportunity;
  final List<SupportIntervention> interventions;
  final List<String> successCriteria;
  final String expectedOutcome;
  
  SupportStrategy({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    this.targetRiskFactor,
    this.targetOpportunity,
    required this.interventions,
    required this.successCriteria,
    required this.expectedOutcome,
  });
}

class SupportIntervention {
  final String type;
  final String trigger;
  final String content;
  final DateTime? timing;
  final String frequency;
  
  SupportIntervention({
    required this.type,
    required this.trigger,
    required this.content,
    this.timing,
    required this.frequency,
  });
}

class ActionPlan {
  final String planId;
  final List<ProactiveSupportAction> actions;
  final int totalActions;
  final int highPriorityActions;
  final Duration estimatedDuration;
  final Map<String, dynamic> adaptationRules;
  
  ActionPlan({
    required this.planId,
    required this.actions,
    required this.totalActions,
    required this.highPriorityActions,
    required this.estimatedDuration,
    required this.adaptationRules,
  });
}

class ProactiveSupportAction {
  final String id;
  final String strategyId;
  final String type;
  final String title;
  final String content;
  final DateTime scheduledTime;
  final int priority;
  final SherpiContext context;
  final String personalizedMessage;
  final List<String> successCriteria;
  final DateTime createdAt;
  
  bool isExecuted;
  DateTime? executedAt;
  double? effectivenessScore;
  Map<String, dynamic>? userFeedback;
  
  ProactiveSupportAction({
    required this.id,
    required this.strategyId,
    required this.type,
    required this.title,
    required this.content,
    required this.scheduledTime,
    required this.priority,
    required this.context,
    required this.personalizedMessage,
    required this.successCriteria,
    required this.createdAt,
    this.isExecuted = false,
    this.executedAt,
    this.effectivenessScore,
    this.userFeedback,
  });
}

class SupportEffectivenessReport {
  final String reportId;
  final DateTime generatedAt;
  final int totalActionsExecuted;
  final double averageEffectiveness;
  final Map<String, double> categoryBreakdown;
  final List<String> insights;
  final List<String> recommendations;
  
  SupportEffectivenessReport({
    required this.reportId,
    required this.generatedAt,
    required this.totalActionsExecuted,
    required this.averageEffectiveness,
    required this.categoryBreakdown,
    required this.insights,
    required this.recommendations,
  });
}

class PersonalizedAdvice {
  final String id;
  final String category;
  final int priority;
  final String title;
  final String content;
  final SherpiContext context;
  final String personalizationLevel;
  final double confidence;
  final DateTime expiresAt;
  final bool actionable;
  final String source;
  
  PersonalizedAdvice({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.content,
    required this.context,
    required this.personalizationLevel,
    required this.confidence,
    required this.expiresAt,
    required this.actionable,
    required this.source,
  });
}