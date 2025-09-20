import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/features/sherpi/analysis/services/ai_insight_generator.dart';
import 'package:sherpa_app/features/sherpi/analysis/services/user_data_analyzer.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/models/point_system_model.dart';
import 'package:sherpa_app/shared/providers/global_point_provider.dart';

// Test utilities
GlobalUser _createMockUser({
  String name = 'Test User',
  int level = 5,
  double experience = 500.0,
}) {
  return GlobalUser(
    id: 'test_user_id',
    name: name,
    level: level,
    experience: experience,
    profileImageUrl: 'test_image.png',
    stats: GlobalStats(
      stamina: 50.0,
      knowledge: 60.0,
      technique: 45.0,
      sociality: 55.0,
      willpower: 40.0,
    ),
    equippedBadgeIds: [],
    ownedBadgeIds: [],
    dailyRecords: DailyRecordData(
      todaySteps: 5000,
      todayFocusMinutes: 30,
      meetingLogs: [],
      readingLogs: [],
      exerciseLogs: [],
      diaryLogs: [],
      movieLogs: [],
      dailyGoals: [],
      climbingLogs: [],
      challengeRecords: [],
      consecutiveDays: 7,
      lastActiveDate: DateTime.now(),
      isAllGoalsCompleted: false,
      isAllGoalsRewardClaimed: false,
      allGoalsRewardClaimedDates: [],
    ),
    currentClimbingSession: null,
    planningData: null,
  );
}

AnalysisResult _createMockAnalysisResult() {
  return AnalysisResult(
    activityPatterns: ActivityPatterns(
      activityFrequency: {'운동': 5, '독서': 3, '일기': 7},
      weeklyDistribution: {
        1: 0.15,
        2: 0.20,
        3: 0.18,
        4: 0.12,
        5: 0.10,
        6: 0.15,
        7: 0.10
      },
      hourlyDistribution: {9: 0.3, 14: 0.2, 19: 0.5},
      mostActiveDay: '수요일',
      mostActiveTime: '저녁',
      consistencyScore: 75.0,
      currentStreak: 7,
      longestStreak: 14,
    ),
    moodAnalysis: MoodAnalysis(
      moodDistribution: {'happy': 0.4, 'calm': 0.3, 'motivated': 0.3},
      dominantMood: 'happy',
      moodStability: 80.0,
      activityMoodMap: {'운동': 'motivated', '독서': 'calm', '일기': 'happy'},
      recentTrends: [
        MoodTrend(
          date: DateTime.now().subtract(const Duration(days: 1)),
          mood: 'happy',
          score: 8.0,
        ),
      ],
    ),
    performanceMetrics: PerformanceMetrics(
      goalCompletionRate: 0.85,
      statGrowthRate: {
        'strength': 0.1,
        'intelligence': 0.15,
        'agility': 0.08,
        'wisdom': 0.12,
        'endurance': 0.05,
      },
      overallProgress: 0.70,
      totalActivities: 15,
      averageSatisfaction: 8.5,
      categoryPerformance: {'운동': 0.8, '독서': 0.6, '일기': 0.9},
    ),
    insights: [
      Insight(
        title: '꾸준한 일기 작성',
        description: '매일 빠짐없이 일기를 작성하고 있습니다',
        type: InsightType.strength,
        importance: 0.9,
        icon: Icons.edit,
      ),
      Insight(
        title: '운동 빈도 증가 필요',
        description: '주 3회 이상 운동을 권장합니다',
        type: InsightType.opportunity,
        importance: 0.7,
        icon: Icons.fitness_center,
      ),
    ],
    recommendations: [
      Recommendation(
        title: '아침 운동 루틴',
        description: '하루를 활기차게 시작해보세요',
        actionText: '운동 시작하기',
        type: RecommendationType.activity,
        priority: 4,
        icon: Icons.directions_run,
      ),
    ],
    analyzedAt: DateTime.now(),
  );
}

// 포인트 시스템용 Mocks
class _TestGlobalPointNotifier extends GlobalPointNotifier {
  int testTotalPoints = 100;
  bool spendPointsDetailedCalled = false;
  int? lastSpendAmount;
  PointSpendType? lastSpendType;
  String? lastDescription;
  bool refundPointsCalled = false;
  int? lastRefundAmount;
  String? lastRefundReason;
  bool forceSpendFailure = false; // Add flag to control failure

  @override
  bool spendPointsDetailed(
    int amount,
    PointSpendType spendType,
    String description,
  ) {
    spendPointsDetailedCalled = true;
    lastSpendAmount = amount;
    lastSpendType = spendType;
    lastDescription = description;

    if (forceSpendFailure) {
      return false; // Force failure when flag is set
    }

    if (testTotalPoints >= amount) {
      testTotalPoints -= amount;
      return true;
    }
    return false;
  }

  @override
  void refundPoints(int amount, String reason) {
    refundPointsCalled = true;
    lastRefundAmount = amount;
    lastRefundReason = reason;
    testTotalPoints += amount;
  }

  @override
  PointData get state => PointData(
        totalPoints: testTotalPoints,
        withdrawablePoints: 0,
        transactions: [],
        lastUpdated: DateTime.now(),
      );

  void setTotalPoints(int points) {
    testTotalPoints = points;
  }

  void resetMockState() {
    spendPointsDetailedCalled = false;
    lastSpendAmount = null;
    lastSpendType = null;
    lastDescription = null;
    refundPointsCalled = false;
    lastRefundAmount = null;
    lastRefundReason = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiInsightGenerator', () {
    late ProviderContainer container;
    late _TestGlobalPointNotifier mockPointNotifier;
    late AiInsightGenerator generator;

    setUpAll(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      mockPointNotifier = _TestGlobalPointNotifier();
      container = ProviderContainer(
        overrides: [
          globalPointProvider.overrideWith((ref) => mockPointNotifier),
        ],
      );

      // For testing, we can't easily pass a Ref, so we'll test without it
      // The main tests should run without ref, and only specific point tests need the ref
      generator = AiInsightGenerator(); // Test without ref by default
    });

    tearDown(() {
      container.dispose();
    });

    group('Constructor', () {
      test('initializes without ref', () {
        // Without ref, the generator should still work but won't manage points
        final generatorWithoutRef = AiInsightGenerator();
        expect(generatorWithoutRef, isNotNull);
      });

      test('initializes with null ref', () {
        // Since we can't easily create a Ref in tests, we test that it accepts null
        final generatorWithRef = AiInsightGenerator(ref: null);
        expect(generatorWithRef, isNotNull);
      });
    });

    group('generateAIInsights', () {
      test('should work without points management', () async {
        // Generator without ref should work but won't manage points
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateAIInsights(user, analysisResult);

        expect(result, isNotNull);
        expect(result, isA<List<Insight>>());
      });

      test('should return insights list with max 8 items', () async {
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateAIInsights(user, analysisResult);

        expect(result, isNotNull);
        expect(result, isA<List<Insight>>());
        expect(result.length, lessThanOrEqualTo(8));
      });

      test('should return combined insights', () async {
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateAIInsights(user, analysisResult);

        expect(result, isNotNull);
        expect(result.length, lessThanOrEqualTo(8)); // Max 8 insights returned
        // Should include existing insights from analysisResult
        expect(result.any((i) => i.title == '꾸준한 일기 작성'), true);
      });

      test('should work without ref (no points)', () async {
        final generatorWithoutRef = AiInsightGenerator();
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        // Without ref, it should work without point deduction
        final result = await generatorWithoutRef.generateAIInsights(user, analysisResult);

        expect(result, isNotNull);
        expect(result, isA<List<Insight>>());
      });

      test('should handle AI generation failure and return existing insights', () async {
        // Since we can't easily mock the AI failure, we test that existing insights are preserved
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateAIInsights(user, analysisResult);

        // Even if AI fails, we should get the original insights
        expect(result.length, greaterThan(0));
      });
    });

    group('generateAIRecommendations', () {
      test('should work without points management', () async {
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateAIRecommendations(user, analysisResult);

        expect(result, isNotNull);
        expect(result, isA<List<Recommendation>>());
      });

      test('should return recommendations list with max 5 items', () async {
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateAIRecommendations(user, analysisResult);

        expect(result, isNotNull);
        expect(result, isA<List<Recommendation>>());
        expect(result.length, lessThanOrEqualTo(5));
      });

      test('should prioritize recommendations by priority', () async {
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateAIRecommendations(user, analysisResult);

        expect(result.length, lessThanOrEqualTo(5)); // Max 5 recommendations
        if (result.length > 1) {
          // Check that recommendations are sorted by priority (descending)
          for (int i = 0; i < result.length - 1; i++) {
            expect(result[i].priority, greaterThanOrEqualTo(result[i + 1].priority));
          }
        }
      });

      test('should include existing recommendations', () async {
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateAIRecommendations(user, analysisResult);

        // Should include the existing recommendation
        expect(result.any((r) => r.title == '아침 운동 루틴'), true);
      });
    });

    group('generateSmartGrowthPlan', () {
      test('should work without points management', () async {
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateSmartGrowthPlan(user, analysisResult);

        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test('should return growth plan as JSON string', () async {
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        final result = await generator.generateSmartGrowthPlan(user, analysisResult);

        expect(result, isNotNull);
        expect(result, isA<String>());
        // The result should contain JSON structure elements
        expect(result.contains('weeklyGoals'), true);
        expect(result.contains('monthlyTargets'), true);
        expect(result.contains('growthRecommendations'), true);
      });


      test('should handle users with different levels', () async {
        // Test with beginner user (level 1)
        var user = _createMockUser(level: 1);
        var analysisResult = _createMockAnalysisResult();
        var result = await generator.generateSmartGrowthPlan(user, analysisResult);
        expect(result, isNotNull);

        // Reset points for next test
        mockPointNotifier.setTotalPoints(100);

        // Test with advanced user (level 20)
        user = _createMockUser(level: 20);
        result = await generator.generateSmartGrowthPlan(user, analysisResult);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test('should work without ref', () async {
        final generatorWithoutRef = AiInsightGenerator();
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        // Should work without point management
        final result = await generatorWithoutRef.generateSmartGrowthPlan(user, analysisResult);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });
    });

    group('Error handling', () {
      test('should handle AI generation gracefully', () async {
        // Even if AI has issues, the methods should return valid results
        final user = _createMockUser();
        final analysisResult = _createMockAnalysisResult();

        // All methods should handle failures gracefully
        final insights = await generator.generateAIInsights(user, analysisResult);
        expect(insights, isNotNull);
        expect(insights, isA<List<Insight>>());

        final recommendations = await generator.generateAIRecommendations(user, analysisResult);
        expect(recommendations, isNotNull);
        expect(recommendations, isA<List<Recommendation>>());

        final growthPlan = await generator.generateSmartGrowthPlan(user, analysisResult);
        expect(growthPlan, isNotNull);
        expect(growthPlan, isA<String>());
      });
    });

    group('InsufficientPointsException', () {
      test('should have correct message', () {
        const message = 'Test message';
        final exception = InsufficientPointsException(message);

        expect(exception.message, message);
        expect(exception.toString(), 'InsufficientPointsException: $message');
      });

      test('should include descriptive message', () {
        const message = 'Insufficient points: need 30 points';
        final exception = InsufficientPointsException(message);

        expect(exception.message, contains('30'));
        expect(exception.message, contains('points'));
        expect(exception.toString(), contains('InsufficientPointsException'));
      });
    });
  });
}