// 🎭 감정 상태 추적 Provider
//
// 사용자의 감정 상태를 종합적으로 추적하고 관리하는 중앙 제어 시스템

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/emotion_state_model.dart';
import '../services/text_emotion_analyzer.dart';
import '../services/behavior_emotion_analyzer.dart';
import '../services/emotion_adaptive_response_system.dart';
import '../services/emotion_history_analyzer.dart';

/// 📊 감정 상태 관리 상태
class EmotionStateManagement {
  final EmotionSnapshot? currentEmotion;
  final EmotionHistory emotionHistory;
  final EmotionTrendAnalysis? latestTrendAnalysis;
  final List<EmotionPattern> activePatterns;
  final EmotionGoals emotionGoals;
  final Map<String, dynamic> userContext;
  final DateTime lastUpdated;
  final bool isAnalyzing;

  const EmotionStateManagement({
    this.currentEmotion,
    required this.emotionHistory,
    this.latestTrendAnalysis,
    this.activePatterns = const [],
    required this.emotionGoals,
    this.userContext = const {},
    required this.lastUpdated,
    this.isAnalyzing = false,
  });

  /// 상태 복사
  EmotionStateManagement copyWith({
    EmotionSnapshot? currentEmotion,
    EmotionHistory? emotionHistory,
    EmotionTrendAnalysis? latestTrendAnalysis,
    List<EmotionPattern>? activePatterns,
    EmotionGoals? emotionGoals,
    Map<String, dynamic>? userContext,
    DateTime? lastUpdated,
    bool? isAnalyzing,
  }) {
    return EmotionStateManagement(
      currentEmotion: currentEmotion ?? this.currentEmotion,
      emotionHistory: emotionHistory ?? this.emotionHistory,
      latestTrendAnalysis: latestTrendAnalysis ?? this.latestTrendAnalysis,
      activePatterns: activePatterns ?? this.activePatterns,
      emotionGoals: emotionGoals ?? this.emotionGoals,
      userContext: userContext ?? this.userContext,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }

  /// 현재 감정 건강 점수
  double get emotionalWellbeingScore {
    return latestTrendAnalysis?.emotionalWellbeingScore ?? 0.7;
  }

  /// 감정 안정성
  double get emotionalStability {
    final stats = emotionHistory.calculateStats();
    return stats.emotionalStability;
  }

  /// 최근 감정 카테고리
  EmotionCategory get currentMoodCategory {
    return currentEmotion?.type.category ?? EmotionCategory.neutral;
  }
}

/// 🎭 감정 상태 추적 Provider
class EmotionStateNotifier extends StateNotifier<EmotionStateManagement> {
  final Ref ref;
  static const String _prefsKeyHistory = 'emotion_history';
  static const String _prefsKeyGoals = 'emotion_goals';
  static const String _prefsKeyPatterns = 'emotion_patterns';
  static const String _prefsKeyContext = 'emotion_user_context';

  EmotionStateNotifier(this.ref)
      : super(
          EmotionStateManagement(
            emotionHistory: EmotionHistory(
              snapshots: [],
              startTime: DateTime.now().subtract(const Duration(days: 30)),
              endTime: DateTime.now(),
            ),
            emotionGoals: const EmotionGoals(),
            lastUpdated: DateTime.now(),
          ),
        ) {
    _loadState();
  }

  /// 📱 상태 로드
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 히스토리 로드
      final historyJson = prefs.getString(_prefsKeyHistory);
      if (historyJson != null) {
        final historyData = json.decode(historyJson);
        final history = EmotionHistory.fromJson(historyData);

        state = state.copyWith(
          emotionHistory: history,
          currentEmotion: history.latestEmotion,
        );
      }

      // 목표 로드
      final goalsJson = prefs.getString(_prefsKeyGoals);
      if (goalsJson != null) {
        final goalsData = json.decode(goalsJson);
        final goals = EmotionGoals.fromJson(goalsData);
        state = state.copyWith(emotionGoals: goals);
      }

      // 사용자 컨텍스트 로드
      final contextJson = prefs.getString(_prefsKeyContext);
      if (contextJson != null) {
        final contextData = json.decode(contextJson);
        state = state.copyWith(userContext: contextData);
      }

      // 패턴 로드 및 트렌드 분석
      await _performTrendAnalysis();
    } catch (e) {
      print('감정 상태 로드 오류: $e');
    }
  }

  /// 💾 상태 저장
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 히스토리 저장
      await prefs.setString(
        _prefsKeyHistory,
        json.encode(state.emotionHistory.toJson()),
      );

      // 목표 저장
      await prefs.setString(
        _prefsKeyGoals,
        json.encode(state.emotionGoals.toJson()),
      );

      // 사용자 컨텍스트 저장
      await prefs.setString(
        _prefsKeyContext,
        json.encode(state.userContext),
      );
    } catch (e) {
      print('감정 상태 저장 오류: $e');
    }
  }

  /// 📝 텍스트 기반 감정 분석
  Future<void> analyzeTextEmotion(
    String text, {
    Map<String, dynamic> context = const {},
    String? trigger,
  }) async {
    state = state.copyWith(isAnalyzing: true);

    try {
      // 텍스트 감정 분석
      final snapshot = TextEmotionAnalyzer.analyzeText(
        text,
        context: context,
        trigger: trigger,
      );

      // 신뢰도가 충분한 경우에만 업데이트
      if (snapshot.isReliable) {
        await _addEmotionSnapshot(snapshot);
      }

      // 다중 감정 분석 (보조)
      final multipleEmotions = TextEmotionAnalyzer.analyzeMultipleEmotions(
        text,
        context: context,
        trigger: trigger,
      );

      // 보조 감정들도 컨텍스트에 저장
      if (multipleEmotions.isNotEmpty) {
        final emotionContext =
            state.userContext['emotion_context'] as Map<String, dynamic>? ?? {};
        emotionContext['secondary_emotions'] = multipleEmotions
            .map((e) => {
                  'type': e.type.id,
                  'intensity': e.intensity.id,
                  'confidence': e.confidence.id,
                })
            .toList();

        state = state.copyWith(
          userContext: {
            ...state.userContext,
            'emotion_context': emotionContext,
          },
        );
      }
    } finally {
      state = state.copyWith(isAnalyzing: false);
    }
  }

  /// 🏃 행동 패턴 기반 감정 분석
  Future<void> analyzeBehaviorEmotion(
    List<BehaviorPattern> recentPatterns, {
    Map<String, dynamic> context = const {},
    String? trigger,
  }) async {
    state = state.copyWith(isAnalyzing: true);

    try {
      final snapshot = BehaviorEmotionAnalyzer.analyzeBehaviorPatterns(
        recentPatterns,
        context: context,
        trigger: trigger,
      );

      if (snapshot != null && snapshot.isReliable) {
        await _addEmotionSnapshot(snapshot);
      }
    } finally {
      state = state.copyWith(isAnalyzing: false);
    }
  }

  /// 🎯 감정 스냅샷 추가
  Future<void> _addEmotionSnapshot(EmotionSnapshot snapshot) async {
    // 히스토리에 추가
    final updatedSnapshots = [...state.emotionHistory.snapshots, snapshot];
    final updatedHistory = EmotionHistory(
      snapshots: updatedSnapshots,
      startTime: state.emotionHistory.startTime,
      endTime: DateTime.now(),
    );

    state = state.copyWith(
      currentEmotion: snapshot,
      emotionHistory: updatedHistory,
      lastUpdated: DateTime.now(),
    );

    // 히스토리 크기 관리 (최대 1000개 유지)
    if (updatedSnapshots.length > 1000) {
      final trimmedSnapshots =
          updatedSnapshots.skip(updatedSnapshots.length - 1000).toList();
      state = state.copyWith(
        emotionHistory: EmotionHistory(
          snapshots: trimmedSnapshots,
          startTime: trimmedSnapshots.first.timestamp,
          endTime: DateTime.now(),
        ),
      );
    }

    await _saveState();

    // 목표 달성 확인
    _checkGoalAchievement();

    // 주기적 트렌드 분석 (10개 스냅샷마다)
    if (state.emotionHistory.snapshots.length % 10 == 0) {
      await _performTrendAnalysis();
    }
  }

  /// 📊 트렌드 분석 수행
  Future<void> _performTrendAnalysis() async {
    final analysis = EmotionHistoryAnalyzer.analyzeTrends(
      state.emotionHistory.snapshots,
      analysisDays: 7,
    );

    if (analysis != null) {
      // 활성 패턴 업데이트
      final activePatterns = analysis.identifiedPatterns
          .where((p) => p.isCurrentlyActive)
          .toList();

      state = state.copyWith(
        latestTrendAnalysis: analysis,
        activePatterns: activePatterns,
      );

      // 중요한 인사이트가 있으면 사용자에게 알림
      if (analysis.emotionalWellbeingScore < 0.4) {
        _notifyLowWellbeingScore();
      }
    }
  }

  /// 🎯 목표 달성 확인
  void _checkGoalAchievement() {
    final stats = state.emotionHistory.calculateStats();
    final isGoalMet = state.emotionGoals.isGoalMet(stats);

    if (isGoalMet) {
      // 목표 달성 알림
      _notifyGoalAchievement();
    }
  }

  /// 🔔 낮은 웰빙 점수 알림
  void _notifyLowWellbeingScore() {
    // TODO: 실제 알림 시스템과 연동
    print('⚠️ 감정 웰빙 점수가 낮습니다. 관리가 필요합니다.');
  }

  /// 🎉 목표 달성 알림
  void _notifyGoalAchievement() {
    // TODO: 실제 알림 시스템과 연동
    print('🎉 감정 목표를 달성했습니다!');
  }

  /// 🎯 감정 목표 설정
  Future<void> updateEmotionGoals(EmotionGoals newGoals) async {
    state = state.copyWith(emotionGoals: newGoals);
    await _saveState();
  }

  /// 👤 사용자 컨텍스트 업데이트
  Future<void> updateUserContext(Map<String, dynamic> updates) async {
    state = state.copyWith(
      userContext: {
        ...state.userContext,
        ...updates,
      },
    );
    await _saveState();
  }

  /// 🎭 적응형 응답 생성
  Map<String, dynamic> generateAdaptiveResponse({
    Map<String, dynamic> conversationContext = const {},
    String? customTrigger,
  }) {
    if (state.currentEmotion == null) {
      return EmotionAdaptiveResponseSystem.generateEmotionAdaptiveResponse(
        EmotionSnapshot(
          type: EmotionType.neutral,
          intensity: EmotionIntensity.moderate,
          confidence: EmotionConfidence.moderate,
          source: EmotionSource.aiInference,
          timestamp: DateTime.now(),
        ),
        userContext: state.userContext,
        conversationContext: conversationContext,
        userName: state.userContext['user_name'] as String?,
        customTrigger: customTrigger,
      );
    }

    // 다중 감정이 있는 경우
    final secondaryEmotions =
        state.userContext['emotion_context']?['secondary_emotions'] as List?;
    if (secondaryEmotions != null && secondaryEmotions.isNotEmpty) {
      final emotionSnapshots = [state.currentEmotion!];

      // 보조 감정들을 스냅샷으로 변환
      for (final emotion in secondaryEmotions.take(2)) {
        emotionSnapshots.add(EmotionSnapshot(
          type: EmotionType.values.firstWhere((e) => e.id == emotion['type']),
          intensity: EmotionIntensity.values
              .firstWhere((e) => e.id == emotion['intensity']),
          confidence: EmotionConfidence.values
              .firstWhere((e) => e.id == emotion['confidence']),
          source: EmotionSource.textAnalysis,
          timestamp: DateTime.now(),
        ));
      }

      return EmotionAdaptiveResponseSystem.generateMultiEmotionResponse(
        emotionSnapshots,
        userContext: state.userContext,
        conversationContext: conversationContext,
        userName: state.userContext['user_name'] as String?,
      );
    }

    // 단일 감정 응답
    return EmotionAdaptiveResponseSystem.generateEmotionAdaptiveResponse(
      state.currentEmotion!,
      userContext: state.userContext,
      conversationContext: conversationContext,
      userName: state.userContext['user_name'] as String?,
      customTrigger: customTrigger,
    );
  }

  /// 📊 빠른 분석 요약
  Map<String, dynamic> getQuickAnalysisSummary() {
    return EmotionHistoryAnalyzer.getQuickAnalysisSummary(
      state.emotionHistory.snapshots,
    );
  }

  /// 🔄 상태 초기화
  Future<void> resetEmotionState() async {
    state = EmotionStateManagement(
      emotionHistory: EmotionHistory(
        snapshots: [],
        startTime: DateTime.now().subtract(const Duration(days: 30)),
        endTime: DateTime.now(),
      ),
      emotionGoals: const EmotionGoals(),
      lastUpdated: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyHistory);
    await prefs.remove(_prefsKeyGoals);
    await prefs.remove(_prefsKeyPatterns);
    await prefs.remove(_prefsKeyContext);
  }

  /// 🎯 활동 완료 시 감정 추론
  Future<void> inferEmotionFromActivity({
    required String activityType,
    required Map<String, dynamic> activityData,
    String? mood,
    double? satisfactionScore,
  }) async {
    // 행동 패턴 생성
    final behaviorPattern = BehaviorPattern(
      userId: state.userContext['user_id'] as String? ?? 'default',
      timestamp: DateTime.now(),
      activityType: activityType,
      duration: Duration(minutes: activityData['duration'] ?? 30),
      activityData: activityData,
      mood: mood,
      satisfactionScore: satisfactionScore,
    );

    // 최근 행동 패턴들 수집 (메모리에서 또는 별도 저장소에서)
    final recentPatterns = [behaviorPattern]; // TODO: 실제로는 최근 패턴들을 가져와야 함

    // 행동 기반 감정 분석
    await analyzeBehaviorEmotion(recentPatterns);
  }

  /// 📈 감정 트렌드 보고서 생성
  Map<String, dynamic> generateEmotionReport({int days = 7}) {
    final analysis = EmotionHistoryAnalyzer.analyzeTrends(
      state.emotionHistory.snapshots,
      analysisDays: days,
    );

    if (analysis == null) {
      return {
        'status': 'insufficient_data',
        'message': '충분한 데이터가 없어 보고서를 생성할 수 없습니다.',
      };
    }

    return {
      'status': 'success',
      'period': days,
      'wellbeing_score': analysis.emotionalWellbeingScore,
      'wellbeing_level': analysis.wellbeingLevel,
      'trend_summary': analysis.trendSummary,
      'stats': {
        'dominant_emotion': analysis.overallStats.dominantEmotion.displayName,
        'average_valence': analysis.overallStats.averageValence,
        'emotional_stability': analysis.overallStats.emotionalStability,
        'total_snapshots': analysis.overallStats.totalSnapshots,
      },
      'key_patterns': analysis.identifiedPatterns
          .take(3)
          .map((p) => {
                'type': p.patternType,
                'description': p.description,
                'significance': p.significance,
                'is_active': p.isCurrentlyActive,
              })
          .toList(),
      'insights': analysis.insights,
      'recommendations': analysis.recommendations,
      'goals': {
        'target_valence': state.emotionGoals.targetValence,
        'current_achievement':
            state.emotionGoals.isGoalMet(analysis.overallStats),
      },
    };
  }
}

/// 🎭 감정 상태 Provider
final emotionStateProvider =
    StateNotifierProvider<EmotionStateNotifier, EmotionStateManagement>((ref) {
  return EmotionStateNotifier(ref);
});

/// 📊 현재 감정 Provider
final currentEmotionProvider = Provider<EmotionSnapshot?>((ref) {
  return ref.watch(emotionStateProvider).currentEmotion;
});

/// 📈 감정 웰빙 점수 Provider
final emotionalWellbeingScoreProvider = Provider<double>((ref) {
  return ref.watch(emotionStateProvider).emotionalWellbeingScore;
});

/// 🎯 감정 목표 달성 여부 Provider
final emotionGoalAchievedProvider = Provider<bool>((ref) {
  final state = ref.watch(emotionStateProvider);
  final stats = state.emotionHistory.calculateStats();
  return state.emotionGoals.isGoalMet(stats);
});

/// 📊 활성 감정 패턴 Provider
final activeEmotionPatternsProvider = Provider<List<EmotionPattern>>((ref) {
  return ref.watch(emotionStateProvider).activePatterns;
});
