import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/emotion_analysis_model.dart';
import '../services/emotion_analysis_service.dart';
import '../../../core/constants/sherpi_dialogues.dart';

/// 🎭 감정 분석 상태
class EmotionAnalysisState {
  final EmotionAnalysisResult? currentAnalysis;
  final List<EmotionAnalysisResult> recentAnalyses;
  final List<SherpiEmotion> recentSherpiResponses;
  final double emotionalSyncScore;
  final EmotionalSyncLevel syncLevel;
  final bool isAnalyzing;

  const EmotionAnalysisState({
    this.currentAnalysis,
    this.recentAnalyses = const [],
    this.recentSherpiResponses = const [],
    this.emotionalSyncScore = 0.0,
    this.syncLevel = EmotionalSyncLevel.none,
    this.isAnalyzing = false,
  });

  EmotionAnalysisState copyWith({
    EmotionAnalysisResult? currentAnalysis,
    List<EmotionAnalysisResult>? recentAnalyses,
    List<SherpiEmotion>? recentSherpiResponses,
    double? emotionalSyncScore,
    EmotionalSyncLevel? syncLevel,
    bool? isAnalyzing,
  }) {
    return EmotionAnalysisState(
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      recentAnalyses: recentAnalyses ?? this.recentAnalyses,
      recentSherpiResponses: recentSherpiResponses ?? this.recentSherpiResponses,
      emotionalSyncScore: emotionalSyncScore ?? this.emotionalSyncScore,
      syncLevel: syncLevel ?? this.syncLevel,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }
}

/// 🧠 감정 분석 노티파이어
class EmotionAnalysisNotifier extends StateNotifier<EmotionAnalysisState> {
  final EmotionAnalysisService _analysisService = EmotionAnalysisService();
  final SharedPreferences _prefs;
  
  static const String _recentAnalysesKey = 'recent_emotion_analyses';
  static const String _recentResponsesKey = 'recent_sherpi_responses';
  static const String _syncScoreKey = 'emotional_sync_score';
  static const int _maxHistoryLength = 20; // 최근 20개 분석 결과 저장

  EmotionAnalysisNotifier(this._prefs) : super(const EmotionAnalysisState()) {
    _loadSavedData();
  }

  /// 💾 저장된 데이터 로드
  Future<void> _loadSavedData() async {
    try {
      // 최근 분석 결과 로드
      final analysesJson = _prefs.getString(_recentAnalysesKey);
      List<EmotionAnalysisResult> recentAnalyses = [];
      if (analysesJson != null) {
        final analysesList = jsonDecode(analysesJson) as List;
        recentAnalyses = analysesList
            .map((json) => EmotionAnalysisResult.fromJson(json))
            .toList();
      }

      // 최근 Sherpi 응답 로드
      final responsesJson = _prefs.getString(_recentResponsesKey);
      List<SherpiEmotion> recentResponses = [];
      if (responsesJson != null) {
        final responsesList = jsonDecode(responsesJson) as List;
        recentResponses = responsesList
            .map((name) => SherpiEmotion.values
                .firstWhere((e) => e.name == name, orElse: () => SherpiEmotion.defaults))
            .toList();
      }

      // 감정 동기화 점수 로드
      final syncScore = _prefs.getDouble(_syncScoreKey) ?? 0.0;
      final syncLevel = EmotionalSyncLevelExtension.fromValue(syncScore);

      state = state.copyWith(
        recentAnalyses: recentAnalyses,
        recentSherpiResponses: recentResponses,
        emotionalSyncScore: syncScore,
        syncLevel: syncLevel,
        currentAnalysis: recentAnalyses.isNotEmpty ? recentAnalyses.first : null,
      );
    } catch (e) {
      print('🎭 감정 분석 데이터 로드 실패: $e');
    }
  }

  /// 💾 데이터 저장
  Future<void> _saveData() async {
    try {
      // 최근 분석 결과 저장
      final analysesJson = jsonEncode(
        state.recentAnalyses.map((analysis) => analysis.toJson()).toList()
      );
      await _prefs.setString(_recentAnalysesKey, analysesJson);

      // 최근 Sherpi 응답 저장
      final responsesJson = jsonEncode(
        state.recentSherpiResponses.map((emotion) => emotion.name).toList()
      );
      await _prefs.setString(_recentResponsesKey, responsesJson);

      // 감정 동기화 점수 저장
      await _prefs.setDouble(_syncScoreKey, state.emotionalSyncScore);
    } catch (e) {
      print('🎭 감정 분석 데이터 저장 실패: $e');
    }
  }

  /// 🎭 사용자 감정 분석 실행
  Future<EmotionAnalysisResult> analyzeUserEmotion({
    required String activityType,
    required bool isSuccess,
    required int consecutiveDays,
    Map<String, dynamic>? performanceData,
    List<String>? recentActivities,
  }) async {
    state = state.copyWith(isAnalyzing: true);

    try {
      final now = DateTime.now();
      final context = EmotionAnalysisContext(
        activityType: activityType,
        isSuccess: isSuccess,
        consecutiveDays: consecutiveDays,
        timeOfDay: now.hour,
        dayOfWeek: now.weekday,
        performanceData: performanceData ?? {},
        recentActivities: recentActivities ?? [],
      );

      final analysis = _analysisService.analyzeUserEmotion(context);

      // 분석 결과를 히스토리에 추가
      final updatedAnalyses = [analysis, ...state.recentAnalyses]
          .take(_maxHistoryLength)
          .toList();

      state = state.copyWith(
        currentAnalysis: analysis,
        recentAnalyses: updatedAnalyses,
        isAnalyzing: false,
      );

      await _saveData();
      return analysis;
    } catch (e) {
      print('🎭 감정 분석 실패: $e');
      state = state.copyWith(isAnalyzing: false);
      rethrow;
    }
  }

  /// 💖 Sherpi 응답 기록 및 동기화 점수 업데이트
  void recordSherpiResponse(SherpiEmotion emotion) {
    final updatedResponses = [emotion, ...state.recentSherpiResponses]
        .take(_maxHistoryLength)
        .toList();

    // 감정 동기화 점수 계산
    final syncScore = _analysisService.calculateEmotionalSync(
      state.recentAnalyses,
      updatedResponses,
    );

    final syncLevel = _analysisService.getEmotionalSyncLevel(syncScore);

    state = state.copyWith(
      recentSherpiResponses: updatedResponses,
      emotionalSyncScore: syncScore,
      syncLevel: syncLevel,
    );

    _saveData();
  }

  /// 🎯 권장 Sherpi 감정 가져오기
  SherpiEmotion getRecommendedSherpiEmotion() {
    if (state.currentAnalysis == null) {
      return SherpiEmotion.defaults;
    }

    return _analysisService.recommendSherpiEmotion(
      state.currentAnalysis!.primaryEmotion
    );
  }

  /// 📊 감정 분석 컨텍스트 생성 (활동 완료 시 사용)
  EmotionAnalysisContext createContextFromActivity({
    required String activityType,
    required bool isSuccess,
    required Map<String, dynamic> userData,
  }) {
    final now = DateTime.now();
    
    // 사용자 데이터에서 연속 일수 추출
    int consecutiveDays = 0;
    switch (activityType) {
      case 'exercise':
        consecutiveDays = userData['연속_운동일'] as int? ?? 0;
        break;
      case 'study':
      case 'reading':
        consecutiveDays = userData['연속_독서일'] as int? ?? 0;
        break;
      default:
        consecutiveDays = userData['연속_접속일'] as int? ?? 0;
    }

    // 최근 활동 목록 생성
    final recentActivities = state.recentAnalyses
        .take(5)
        .map((analysis) => analysis.analysisContext['activityType'] as String? ?? '')
        .where((activity) => activity.isNotEmpty)
        .toList();

    return EmotionAnalysisContext(
      activityType: activityType,
      isSuccess: isSuccess,
      consecutiveDays: consecutiveDays,
      timeOfDay: now.hour,
      dayOfWeek: now.weekday,
      performanceData: userData,
      recentActivities: recentActivities,
    );
  }

  /// 🧹 오래된 데이터 정리
  void cleanOldData() {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    
    final filteredAnalyses = state.recentAnalyses
        .where((analysis) => analysis.analyzedAt.isAfter(cutoffDate))
        .toList();

    if (filteredAnalyses.length != state.recentAnalyses.length) {
      final filteredResponses = state.recentSherpiResponses
          .take(filteredAnalyses.length)
          .toList();

      state = state.copyWith(
        recentAnalyses: filteredAnalyses,
        recentSherpiResponses: filteredResponses,
      );

      _saveData();
    }
  }

  /// 📈 감정 분석 통계 가져오기
  Map<String, dynamic> getEmotionStatistics() {
    if (state.recentAnalyses.isEmpty) {
      return {
        'total_analyses': 0,
        'dominant_emotion': 'neutral',
        'emotion_distribution': <String, int>{},
        'sync_trend': 'stable',
      };
    }

    // 감정 분포 계산
    final emotionCounts = <UserEmotionState, int>{};
    for (final analysis in state.recentAnalyses) {
      emotionCounts[analysis.primaryEmotion] = 
          (emotionCounts[analysis.primaryEmotion] ?? 0) + 1;
    }

    final dominantEmotion = emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // 동기화 추세 계산
    String syncTrend = 'stable';
    if (state.recentAnalyses.length >= 5) {
      final recent5 = state.recentAnalyses.take(5).toList();
      final older5 = state.recentAnalyses.skip(5).take(5).toList();
      
      if (recent5.isNotEmpty && older5.isNotEmpty) {
        final recentAvgConfidence = recent5
            .map((a) => a.confidence)
            .reduce((a, b) => a + b) / recent5.length;
        final olderAvgConfidence = older5
            .map((a) => a.confidence)
            .reduce((a, b) => a + b) / older5.length;
        
        if (recentAvgConfidence > olderAvgConfidence + 0.1) {
          syncTrend = 'improving';
        } else if (recentAvgConfidence < olderAvgConfidence - 0.1) {
          syncTrend = 'declining';
        }
      }
    }

    return {
      'total_analyses': state.recentAnalyses.length,
      'dominant_emotion': dominantEmotion.name,
      'emotion_distribution': emotionCounts.map((key, value) => 
          MapEntry(key.name, value)),
      'sync_trend': syncTrend,
      'current_sync_level': state.syncLevel.name,
      'sync_score': state.emotionalSyncScore,
    };
  }
}

/// 🎭 감정 분석 프로바이더
final emotionAnalysisProvider = StateNotifierProvider<EmotionAnalysisNotifier, EmotionAnalysisState>((ref) {
  throw UnimplementedError();
});

/// 🎯 현재 사용자 감정 프로바이더
final currentUserEmotionProvider = Provider<UserEmotionState?>((ref) {
  final state = ref.watch(emotionAnalysisProvider);
  return state.currentAnalysis?.primaryEmotion;
});

/// 💖 감정 동기화 수준 프로바이더
final emotionalSyncLevelProvider = Provider<EmotionalSyncLevel>((ref) {
  final state = ref.watch(emotionAnalysisProvider);
  return state.syncLevel;
});

/// 🎭 권장 Sherpi 감정 프로바이더
final recommendedSherpiEmotionProvider = Provider<SherpiEmotion>((ref) {
  final state = ref.watch(emotionAnalysisProvider);
  final notifier = ref.read(emotionAnalysisProvider.notifier);
  return notifier.getRecommendedSherpiEmotion();
});

/// 📊 감정 분석 통계 프로바이더
final emotionStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(emotionAnalysisProvider);
  final notifier = ref.read(emotionAnalysisProvider.notifier);
  return notifier.getEmotionStatistics();
});