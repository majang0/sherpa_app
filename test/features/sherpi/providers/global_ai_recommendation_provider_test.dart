import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/features/meetings/ai/meeting_recommendation_ai.dart';
import 'package:sherpa_app/features/meetings/ai/models/ai_recommended_meeting.dart';
import 'package:sherpa_app/features/meetings/models/available_meeting_model.dart';
import 'package:sherpa_app/features/sherpi/domain/services/sherpi_insight_repository.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/global_ai_recommendation_provider.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';

class _FakeMeetingRecommendationAI extends MeetingRecommendationAI {
  int callCount = 0;
  Future<List<AIRecommendedMeeting>> Function({
    required GlobalUser user,
    required List<AvailableMeeting> availableMeetings,
    bool useCache,
    bool forceRefresh,
  })? onCall;

  @override
  Future<void> initialize() async {}

  @override
  Future<List<AIRecommendedMeeting>> getAIRecommendations({
    required GlobalUser user,
    required List<AvailableMeeting> availableMeetings,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    callCount++;
    if (onCall != null) {
      return onCall!(
        user: user,
        availableMeetings: availableMeetings,
        useCache: useCache,
        forceRefresh: forceRefresh,
      );
    }
    return const [];
  }
}

class _FakeSherpiInsightRepository implements SherpiInsightRepository {
  _FakeSherpiInsightRepository(this._insights);

  final SherpiInsights _insights;

  @override
  SherpiInsights collectInsights() => _insights;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _FakeMeetingRecommendationAI fakeAI;
  late GlobalUser testUser;
  late List<AvailableMeeting> availableMeetings;

  setUp(() {
    fakeAI = _FakeMeetingRecommendationAI();
    final sherpiInsights = SherpiInsights(
      personalityType: SherpiPersonalityType.balanced,
      sherpiNickname: '셰르피',
      userPreferredName: '연우',
      intimacyLevel: 3,
      emotionalSyncScore: 0.7,
      recentSherpiEmotion: SherpiEmotion.happy,
      recentSherpiContext: SherpiContext.general,
      lastSherpiMessage: '계속 응원할게요!',
    );

    container = ProviderContainer(
      overrides: [
        globalAIRecommendationProvider.overrideWith((ref) {
          return GlobalAIRecommendationNotifier(
            ref,
            aiEngine: fakeAI,
          );
        }),
        sherpiInsightRepositoryProvider.overrideWith((ref) {
          return _FakeSherpiInsightRepository(sherpiInsights);
        }),
      ],
    );

    testUser = GlobalUser(
      id: 'user-1',
      name: '테스터',
      level: 12,
      experience: 1234,
      stats: const GlobalStats(
        stamina: 4,
        knowledge: 2,
        technique: 3,
        sociality: 5,
        willpower: 4,
      ),
      equippedBadgeIds: const [],
      ownedBadgeIds: const [],
      dailyRecords: DailyRecordData.initial,
      currentClimbingSession: null,
      planningData: null,
    );

    final baseMeeting = AvailableMeeting(
      id: 'meeting-1',
      title: '새벽 러닝 챌린지',
      description: '주 3회 러닝 모임',
      category: MeetingCategory.exercise,
      type: MeetingType.free,
      scope: MeetingScope.public,
      dateTime: DateTime.now().add(const Duration(days: 1)),
      location: '한강 공원',
      detailedLocation: '잠실나루역 4번 출구',
      maxParticipants: 12,
      currentParticipants: 4,
      hostName: '호스트',
      hostId: 'host-1',
      tags: const ['러닝', '모닝루틴'],
      requirements: const ['운동화'],
      preparationItems: const ['물병'],
      imageFileNames: const [],
    );

    availableMeetings = [baseMeeting];
  });

  tearDown(() {
    container.dispose();
  });

  test('generateRecommendations populates state with AI results', () async {
    final recommendation = AIRecommendedMeeting(
      meeting: availableMeetings.first,
      matchScore: 0.92,
      reason: '러닝을 자주 기록했어요',
      keyPoints: const ['러닝 습관', '새벽 활동'],
      priority: 1,
      createdAt: DateTime.now(),
    );

    fakeAI.onCall = ({
      required GlobalUser user,
      required List<AvailableMeeting> availableMeetings,
      bool useCache = true,
      bool forceRefresh = false,
    }) async {
      expect(user.id, testUser.id);
      expect(availableMeetings, isNotEmpty);
      return [recommendation];
    };

    final notifier =
        container.read(globalAIRecommendationProvider.notifier);
    await notifier.generateRecommendations(
      user: testUser,
      availableMeetings: availableMeetings,
    );

    final state = container.read(globalAIRecommendationProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.recommendations, hasLength(1));
    expect(state.recommendations.first.meeting.id, 'meeting-1');
    expect(state.lastUpdated, isNotNull);
    expect(fakeAI.callCount, 1);
  });

  test('generateRecommendations returns error when meetings empty', () async {
    final notifier =
        container.read(globalAIRecommendationProvider.notifier);

    await notifier.generateRecommendations(
      user: testUser,
      availableMeetings: const [],
    );

    final state = container.read(globalAIRecommendationProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, isNotNull);
    expect(state.recommendations, isEmpty);
    expect(fakeAI.callCount, 0);
  });

  test('generateRecommendations reuses cached state when valid', () async {
    fakeAI.onCall = ({
      required GlobalUser user,
      required List<AvailableMeeting> availableMeetings,
      bool useCache = true,
      bool forceRefresh = false,
    }) async {
      return [
        AIRecommendedMeeting(
          meeting: availableMeetings.first,
          matchScore: 0.85,
          reason: '기초 체력 수치가 높습니다',
          keyPoints: const ['체력', '꾸준함'],
          priority: 1,
          createdAt: DateTime.now(),
        ),
      ];
    };

    final notifier =
        container.read(globalAIRecommendationProvider.notifier);

    await notifier.generateRecommendations(
      user: testUser,
      availableMeetings: availableMeetings,
    );
    expect(fakeAI.callCount, 1);

    await notifier.generateRecommendations(
      user: testUser,
      availableMeetings: availableMeetings,
    );

    expect(fakeAI.callCount, 1, reason: 'should reuse cached recommendations');
    final state = container.read(globalAIRecommendationProvider);
    expect(state.recommendations, hasLength(1));
    expect(state.isCacheValid, isTrue);
  });
}
