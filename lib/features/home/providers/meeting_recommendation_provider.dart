import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../models/meeting_recommendation_model.dart';
import '../../../shared/providers/global_meeting_provider.dart';
import '../../../shared/providers/global_challenge_provider.dart';
import '../models/growth_synergy_model.dart' hide MeetingCategory; // MeetingCategory 충돌 방지
import '../../meetings/models/available_meeting_model.dart';
import '../../meetings/models/available_challenge_model.dart';
import '../../../shared/providers/global_user_provider.dart';

// 통합된 추천 데이터 상태
class MeetingRecommendationState {
  final List<AvailableMeeting> allMeetings;
  final List<AvailableChallenge> allChallenges;
  final List<AvailableMeeting> universityMeetings;
  final List<AvailableChallenge> universityChallenges;
  final String? selectedFilter;
  final bool isLoading;
  final String? error;

  MeetingRecommendationState({
    required this.allMeetings,
    required this.allChallenges,
    required this.universityMeetings,
    required this.universityChallenges,
    this.selectedFilter = 'all',
    this.isLoading = false,
    this.error,
  });

  factory MeetingRecommendationState.initial() {
    return MeetingRecommendationState(
      allMeetings: [],
      allChallenges: [],
      universityMeetings: [],
      universityChallenges: [],
      selectedFilter: 'all',
      isLoading: true,
    );
  }

  MeetingRecommendationState copyWith({
    List<AvailableMeeting>? allMeetings,
    List<AvailableChallenge>? allChallenges,
    List<AvailableMeeting>? universityMeetings,
    List<AvailableChallenge>? universityChallenges,
    String? selectedFilter,
    bool? isLoading,
    String? error,
  }) {
    return MeetingRecommendationState(
      allMeetings: allMeetings ?? this.allMeetings,
      allChallenges: allChallenges ?? this.allChallenges,
      universityMeetings: universityMeetings ?? this.universityMeetings,
      universityChallenges: universityChallenges ?? this.universityChallenges,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MeetingRecommendationNotifier extends StateNotifier<MeetingRecommendationState> {
  final Ref ref;
  
  MeetingRecommendationNotifier(this.ref) : super(MeetingRecommendationState.initial()) {
    loadRecommendedData();
  }

  Future<void> loadRecommendedData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(milliseconds: 800)); // 네트워크 시뮬레이션

      // available_meeting_provider와 challenge_provider에서 실제 데이터 가져오기
      final allMeetings = ref.read(globalRecommendedMeetingsProvider);
      final allChallenges = ref.read(globalRecommendedChallengesProvider);
      
      // 대학별 필터링 (영남이공대학교 예시)
      final universityMeetings = ref.read(globalAvailableMeetingsProvider)
          .where((m) => m.universityName == '영남이공대학교')
          .toList();
      final universityChallenges = ref.read(globalAvailableChallengesProvider)
          .where((c) => c.universityName == '영남이공대학교')
          .toList();

      state = state.copyWith(
        allMeetings: allMeetings,
        allChallenges: allChallenges,
        universityMeetings: universityMeetings,
        universityChallenges: universityChallenges,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  // 현재 필터에 따른 데이터 반환
  List<dynamic> getFilteredData() {
    switch (state.selectedFilter) {
      case 'university':
        return [...state.universityMeetings, ...state.universityChallenges];
      case 'challenge':
        return state.allChallenges;
      case 'all':
      default:
        // 모임과 챌린지를 섞어서 반환
        final mixed = <dynamic>[];
        mixed.addAll(state.allMeetings.take(2));
        mixed.addAll(state.allChallenges.take(1));
        mixed.addAll(state.allMeetings.skip(2).take(1));
        mixed.addAll(state.allChallenges.skip(1).take(1));
        return mixed;
    }
  }

  Future<void> refresh() async {
    await loadRecommendedData();
  }
}

// Provider 정의
final meetingRecommendationProvider = StateNotifierProvider<MeetingRecommendationNotifier, MeetingRecommendationState>(
  (ref) => MeetingRecommendationNotifier(ref),
);

// 필터링된 데이터 Provider
final filteredRecommendationsProvider = Provider<List<dynamic>>((ref) {
  final state = ref.watch(meetingRecommendationProvider);
  final notifier = ref.read(meetingRecommendationProvider.notifier);
  
  // state가 로딩 중이거나 에러가 있으면 빈 리스트 반환
  if (state.isLoading || state.error != null) {
    return [];
  }
  
  return notifier.getFilteredData();
});
