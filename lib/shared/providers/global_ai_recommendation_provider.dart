import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/features/meetings/ai/meeting_recommendation_ai.dart';
import 'package:sherpa_app/features/meetings/ai/models/ai_recommended_meeting.dart';
import 'package:sherpa_app/features/meetings/models/available_meeting_model.dart';
import 'package:sherpa_app/features/sherpi/domain/services/sherpi_insight_repository.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';

class AIRecommendationState {
  final bool isLoading;
  final List<AIRecommendedMeeting> recommendations;
  final String? error;
  final DateTime? lastUpdated;

  const AIRecommendationState({
    this.isLoading = false,
    this.recommendations = const [],
    this.error,
    this.lastUpdated,
  });

  AIRecommendationState copyWith({
    bool? isLoading,
    List<AIRecommendedMeeting>? recommendations,
    String? error,
    DateTime? lastUpdated,
  }) {
    return AIRecommendationState(
      isLoading: isLoading ?? this.isLoading,
      recommendations: recommendations ?? this.recommendations,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get isCacheValid {
    if (lastUpdated == null) return false;
    return DateTime.now().difference(lastUpdated!).inMinutes < 30;
  }
}

class GlobalAIRecommendationNotifier
    extends StateNotifier<AIRecommendationState> {
  GlobalAIRecommendationNotifier(
    this._ref, {
    MeetingRecommendationAI? aiEngine,
  })  : _aiEngine = aiEngine ?? MeetingRecommendationAI(),
        super(const AIRecommendationState()) {
    _initialize();
  }

  final Ref _ref;
  final MeetingRecommendationAI _aiEngine;

  Future<void> _initialize() async {
    await _aiEngine.initialize();
  }

  Future<void> generateRecommendations({
    required GlobalUser user,
    required List<AvailableMeeting> availableMeetings,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.isCacheValid &&
        state.recommendations.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (availableMeetings.isEmpty) {
        throw Exception('참여 가능한 모임이 없습니다');
      }

      final insights =
          _ref.read(sherpiInsightRepositoryProvider).collectInsights();

      final recommendations = await _aiEngine.getAIRecommendations(
        user: user,
        availableMeetings: availableMeetings,
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (recommendations.isEmpty) {
        throw Exception('추천할 모임을 찾을 수 없습니다');
      }

      state = state.copyWith(
        isLoading: false,
        recommendations: recommendations,
        lastUpdated: DateTime.now(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  List<AIRecommendedMeeting> getRecommendationsByCategory(
      MeetingCategory category) {
    if (category == MeetingCategory.all) {
      return state.recommendations;
    }
    return state.recommendations
        .where((recommendation) => recommendation.meeting.category == category)
        .toList();
  }

  List<AIRecommendedMeeting> getTopRecommendations(int count) {
    return state.recommendations.take(count).toList();
  }

  void reset() {
    state = const AIRecommendationState();
  }
}

final globalAIRecommendationProvider = StateNotifierProvider<
    GlobalAIRecommendationNotifier, AIRecommendationState>((ref) {
  return GlobalAIRecommendationNotifier(ref);
});

final globalAIRecommendationsProvider =
    Provider<List<AIRecommendedMeeting>>((ref) {
  return ref.watch(globalAIRecommendationProvider).recommendations;
});

final globalAIRecommendationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(globalAIRecommendationProvider).isLoading;
});

final globalAIRecommendationErrorProvider = Provider<String?>((ref) {
  return ref.watch(globalAIRecommendationProvider).error;
});
