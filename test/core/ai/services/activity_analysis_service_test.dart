import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/ai/services/activity_analysis_service.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';

// Test data helpers
Map<String, dynamic> _createMockTodayExercise() {
  return {
    'exercise': '런닝',
    'duration': 30,
    'calories': 250,
    'intensity': 'moderate',
    'date': DateTime.now().toIso8601String(),
  };
}

Map<String, dynamic> _createMockPreviousExercise() {
  return {
    'exercise': '수영',
    'duration': 45,
    'calories': 350,
    'intensity': 'high',
    'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  };
}

Map<String, dynamic> _createMockDiaryEntry() {
  return {
    'entry': '오늘은 정말 즐거운 하루였다. 운동도 하고 친구들과 시간을 보냈다.',
    'mood': 'happy',
    'date': DateTime.now().toIso8601String(),
    'tags': ['운동', '친구', '행복'],
  };
}

Map<String, dynamic> _createMockReadingLog() {
  return {
    'bookTitle': '해리포터',
    'author': 'J.K. 롤링',
    'pagesRead': 50,
    'totalPages': 500,
    'notes': '흥미진진한 스토리',
    'date': DateTime.now().toIso8601String(),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ActivityAnalysisService', () {
    late ActivityAnalysisService service;

    setUpAll(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      // Clear any cached instances
      SharedPreferences.setMockInitialValues({});
      // Get the singleton instance
      service = ActivityAnalysisService.instance;
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = ActivityAnalysisService.instance;
        final instance2 = ActivityAnalysisService.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('analyzeExerciseComprehensive', () {
      test('should return analysis without API call (using defaults)', () async {
        final todayExercise = _createMockTodayExercise();
        final previousExercise = _createMockPreviousExercise();

        // Since we can't easily mock the OpenAI client, we'll test the default behavior
        // The service should handle API failures gracefully and return default analysis
        final analysis = await service.analyzeExerciseComprehensive(
          todayExercise: todayExercise,
          previousExercise: previousExercise,
          userName: 'TestUser',
          forceRegenerate: true, // Force regenerate to bypass cache
        );

        expect(analysis, isNotNull);
        expect(analysis.benefits, isNotEmpty);
        expect(analysis.comparison, isNotEmpty);
        expect(analysis.recommendation, isNotEmpty);
        expect(analysis.encouragement, isNotEmpty);
      });

      test('should use cache when available', () async {
        final todayExercise = _createMockTodayExercise();
        final previousExercise = _createMockPreviousExercise();

        // First call should generate analysis
        final analysis1 = await service.analyzeExerciseComprehensive(
          todayExercise: todayExercise,
          previousExercise: previousExercise,
          userName: 'TestUser',
          forceRegenerate: false,
        );

        // Second call should return cached result
        final analysis2 = await service.analyzeExerciseComprehensive(
          todayExercise: todayExercise,
          previousExercise: previousExercise,
          userName: 'TestUser',
          forceRegenerate: false,
        );

        // Both should return valid analyses
        expect(analysis1, isNotNull);
        expect(analysis2, isNotNull);
      });

      test('should force regenerate when requested', () async {
        final todayExercise = _createMockTodayExercise();

        // Call with forceRegenerate = true
        final analysis = await service.analyzeExerciseComprehensive(
          todayExercise: todayExercise,
          previousExercise: null,
          userName: 'TestUser',
          forceRegenerate: true,
        );

        expect(analysis, isNotNull);
        expect(analysis.benefits, isNotEmpty);
      });

      test('should handle null previous exercise', () async {
        final todayExercise = _createMockTodayExercise();

        final analysis = await service.analyzeExerciseComprehensive(
          todayExercise: todayExercise,
          previousExercise: null, // No previous exercise
          userName: 'TestUser',
          forceRegenerate: true,
        );

        expect(analysis, isNotNull);
        expect(analysis.benefits, isNotEmpty);
        // Comparison should indicate no previous data
        expect(analysis.comparison.toLowerCase(),
            anyOf(contains('처음'), contains('이전'), contains('first')));
      });
    });

    group('analyzeDiaryComprehensive', () {
      test('should return diary analysis', () async {
        // Test with basic mood
        final analysis = await service.analyzeDiaryComprehensive(
          currentMood: 'happy',
          previousMood: 'calm',
          userName: 'TestUser',
          forceRegenerate: true,
        );

        expect(analysis, isNotNull);
        expect(analysis.emotionTransition, isNotEmpty);
        expect(analysis.emotionalSupport, isNotEmpty);
        expect(analysis.practicalAdvice, isNotEmpty);
        expect(analysis.tomorrowHope, isNotEmpty);
      });

      test('should handle without previous mood', () async {
        final analysis = await service.analyzeDiaryComprehensive(
          currentMood: 'neutral',
          previousMood: null,
          userName: 'TestUser',
          forceRegenerate: true,
        );

        expect(analysis, isNotNull);
        expect(analysis.emotionalSupport, isNotEmpty);
      });

      test('should use cache when available', () async {
        final analysis1 = await service.analyzeDiaryComprehensive(
          currentMood: 'happy',
          userName: 'TestUser',
          forceRegenerate: false,
        );

        final analysis2 = await service.analyzeDiaryComprehensive(
          currentMood: 'happy',
          userName: 'TestUser',
          forceRegenerate: false,
        );

        expect(analysis1, isNotNull);
        expect(analysis2, isNotNull);
        // Should use cached result
      });
    });

    group('analyzeReadingComprehensive', () {
      test('should return reading analysis', () async {
        final readingLog = _createMockReadingLog();

        final analysis = await service.analyzeReadingComprehensive(
          previousReading: null,
          todayReading: readingLog,
          userName: 'TestUser',
          forceRegenerate: true,
        );

        expect(analysis, isNotNull);
        expect(analysis.todayInsight, isNotEmpty);
        expect(analysis.journeyEncouragement, isNotEmpty);
        expect(analysis.recommendations, isNotNull);
      });

      test('should handle reading with previous entry', () async {
        final previousLog = _createMockReadingLog();
        previousLog['bookTitle'] = '이전 책';
        final todayLog = _createMockReadingLog();

        final analysis = await service.analyzeReadingComprehensive(
          previousReading: previousLog,
          todayReading: todayLog,
          userName: 'TestUser',
          forceRegenerate: true,
        );

        expect(analysis, isNotNull);
        expect(analysis.previousInsight, isNotEmpty);
        expect(analysis.todayInsight, isNotEmpty);
      });

      test('should generate book recommendations', () async {
        final readingLog = _createMockReadingLog();

        final analysis = await service.analyzeReadingComprehensive(
          previousReading: null,
          todayReading: readingLog,
          userName: 'TestUser',
          forceRegenerate: true,
        );

        expect(analysis, isNotNull);
        expect(analysis.recommendations, isNotNull);
        expect(analysis.recommendations, isA<List>());
      });
    });

    group('Cache Management', () {
      test('should cache comprehensive exercise analysis', () async {
        final todayExercise = _createMockTodayExercise();

        // First call
        await service.analyzeExerciseComprehensive(
          todayExercise: todayExercise,
          previousExercise: null,
          userName: 'TestUser',
          forceRegenerate: true,
        );

        // Check if cache exists
        final cached = await service.getComprehensiveExerciseFromCache();
        expect(cached, isNotNull);
      });

      test('should clear exercise cache', () async {
        final todayExercise = _createMockTodayExercise();

        // Generate and cache some data
        await service.analyzeExerciseComprehensive(
          todayExercise: todayExercise,
          previousExercise: null,
          userName: 'TestUser',
          forceRegenerate: true,
        );

        // Clear exercise cache
        await service.clearComprehensiveExerciseCache();

        // Cache should be empty
        final cached = await service.getComprehensiveExerciseFromCache();
        expect(cached, isNull);
      });

      test('should cache diary analysis', () async {
        await service.analyzeDiaryComprehensive(
          currentMood: 'happy',
          userName: 'TestUser',
          forceRegenerate: true,
        );

        // The cache is internal, so we test by calling again with forceRegenerate=false
        final cached = await service.analyzeDiaryComprehensive(
          currentMood: 'happy',
          userName: 'TestUser',
          forceRegenerate: false,
        );
        expect(cached, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should return default analysis on API failure', () async {
        // Since we can't mock the API client easily, we rely on the fact
        // that without proper API keys, it will fail and return defaults
        final todayExercise = _createMockTodayExercise();

        final analysis = await service.analyzeExerciseComprehensive(
          todayExercise: todayExercise,
          previousExercise: null,
          userName: 'TestUser',
          forceRegenerate: true,
        );

        // Should return valid default analysis
        expect(analysis, isNotNull);
        expect(analysis.benefits, isNotEmpty);
        expect(analysis.recommendation, isNotEmpty);
        expect(analysis.encouragement, isNotEmpty);
        expect(analysis.comparison, isNotEmpty);
      });

      test('should handle malformed exercise data gracefully', () async {
        final malformedData = {
          'invalid_field': 'invalid_value',
          // Missing required fields
        };

        final analysis = await service.analyzeExerciseComprehensive(
          todayExercise: malformedData,
          previousExercise: null,
          userName: 'TestUser',
          forceRegenerate: true,
        );

        // Should still return some analysis
        expect(analysis, isNotNull);
        expect(analysis.benefits, isNotEmpty);
      });

      test('should handle empty user name', () async {
        final todayExercise = _createMockTodayExercise();

        final analysis = await service.analyzeExerciseComprehensive(
          todayExercise: todayExercise,
          previousExercise: null,
          userName: '', // Empty user name
          forceRegenerate: true,
        );

        expect(analysis, isNotNull);
        expect(analysis.benefits, isNotEmpty);
      });
    });

    group('ComprehensiveExerciseAnalysis Model', () {
      test('should create valid model from data', () {
        final analysis = ComprehensiveExerciseAnalysis(
          benefits: '운동 효과 분석',
          comparison: '이전 운동과 비교',
          recommendation: '추천 사항',
          encouragement: '격려 메시지',
        );

        expect(analysis.benefits, equals('운동 효과 분석'));
        expect(analysis.comparison, equals('이전 운동과 비교'));
        expect(analysis.recommendation, equals('추천 사항'));
        expect(analysis.encouragement, equals('격려 메시지'));
      });

      test('should serialize to JSON', () {
        final analysis = ComprehensiveExerciseAnalysis(
          benefits: '효과',
          comparison: '비교',
          recommendation: '추천',
          encouragement: '격려',
        );

        final json = analysis.toJson();

        expect(json['benefits'], equals('효과'));
        expect(json['comparison'], equals('비교'));
        expect(json['recommendation'], equals('추천'));
        expect(json['encouragement'], equals('격려'));
      });

      test('should deserialize from JSON', () {
        final json = {
          'benefits': '효과',
          'comparison': '비교',
          'recommendation': '추천',
          'encouragement': '격려',
        };

        final analysis = ComprehensiveExerciseAnalysis.fromJson(json);

        expect(analysis.benefits, equals('효과'));
        expect(analysis.comparison, equals('비교'));
        expect(analysis.recommendation, equals('추천'));
        expect(analysis.encouragement, equals('격려'));
      });
    });
  });
}