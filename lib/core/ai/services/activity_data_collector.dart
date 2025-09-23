import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/global_point_provider.dart';
import 'package:sherpa_app/shared/providers/global_user_provider.dart';
import 'package:sherpa_app/shared/models/point_system_model.dart';
import 'package:sherpa_app/features/quests/models/quest_instance_model.dart';
import 'package:sherpa_app/features/quests/providers/quest_provider_v2.dart';

/// 🎯 Phase 2: 활동별 상세 데이터 수집 시스템
///
/// 각 활동 유형별로 풍부한 컨텍스트 데이터를 수집하여
/// AI가 더 개인화되고 적절한 응답을 생성할 수 있도록 지원합니다.
class ActivityDataCollector {
  final Ref _ref;

  ActivityDataCollector(this._ref);

  /// 🏃 운동 활동 상세 데이터 수집
  Map<String, dynamic> collectExerciseData({
    required String exerciseType,
    required int durationMinutes,
    required String intensity,
    Map<String, dynamic>? additionalData,
  }) {
    final user = _ref.read(globalUserProvider);
    final todayExercises = user.dailyRecords.exerciseLogs;
    final allTimeExercises = _getAllTimeExerciseData(user);

    // 운동 타입별 누적 데이터
    final exerciseTypeStats = _getExerciseTypeStats(todayExercises);

    // 시간대별 운동 패턴
    final timePattern = _getExerciseTimePattern(todayExercises);

    // 강도별 분포
    final intensityDistribution = _getIntensityDistribution(todayExercises);

    // 개인 기록 체크
    final isNewRecord = _checkPersonalRecord(
      exerciseType: exerciseType,
      duration: durationMinutes,
      allTimeData: allTimeExercises,
    );

    // 연속 운동 일수
    final streak = _calculateDetailedStreak(user, 'exercise');

    return {
      // 현재 운동 세션 정보
      'currentSession': {
        'type': exerciseType,
        'duration': durationMinutes,
        'intensity': intensity,
        'timestamp': DateTime.now().toIso8601String(),
        'calories': _estimateCalories(exerciseType, durationMinutes, intensity),
      },

      // 오늘의 운동 통계
      'todayStats': {
        'totalSessions': todayExercises.length + 1,
        'totalMinutes': todayExercises.fold<int>(
                0, (sum, log) => sum + log.durationMinutes) +
            durationMinutes,
        'exerciseTypes': {...exerciseTypeStats.keys, exerciseType}.toList(),
        'averageIntensity':
            _calculateAverageIntensityScore(todayExercises, intensity),
        'timePattern': timePattern,
        'intensityDistribution': intensityDistribution,
      },

      // 주간/월간 통계
      'historicalStats': {
        'weeklyMinutes': _getWeeklyExerciseMinutes(user),
        'monthlyMinutes': _getMonthlyExerciseMinutes(user),
        'favoriteExerciseType': _getFavoriteExerciseType(allTimeExercises),
        'preferredTimeSlot': _getPreferredExerciseTime(allTimeExercises),
        'consistencyScore': _calculateConsistencyScore(user, 'exercise'),
      },

      // 성취 및 기록
      'achievements': {
        'isPersonalBest': isNewRecord,
        'currentStreak': streak['current'],
        'longestStreak': streak['longest'],
        'totalExerciseDays': allTimeExercises['totalDays'],
        'milestones': _getExerciseMilestones(user),
      },

      // 동기부여 지표
      'motivation': {
        'recentTrend': _getActivityTrend(user, 'exercise'),
        'goalProgress': _getGoalProgress(user, 'exercise'),
        'comparisonToAverage':
            _compareToUserAverage(user, 'exercise', durationMinutes),
      },

      // 추가 컨텍스트
      ...additionalData ?? {},
    };
  }

  /// 📚 학습 활동 상세 데이터 수집
  Map<String, dynamic> collectStudyData({
    required String bookTitle,
    required int pages,
    double? rating,
    String? genre,
    Map<String, dynamic>? additionalData,
  }) {
    final user = _ref.read(globalUserProvider);
    final todayReading = user.dailyRecords.readingLogs;
    final allTimeReading = _getAllTimeReadingData(user);

    // 장르별 선호도 분석
    final genrePreferences = _analyzeGenrePreferences(allTimeReading);

    // 독서 속도 및 패턴
    final readingSpeed = _calculateReadingSpeed(todayReading, pages);

    // 평점 분포
    final ratingDistribution = _getRatingDistribution(allTimeReading);

    return {
      // 현재 독서 세션
      'currentSession': {
        'bookTitle': bookTitle,
        'pages': pages,
        'rating': rating,
        'genre': genre ?? '기타',
        'timestamp': DateTime.now().toIso8601String(),
        'estimatedReadingTime': _estimateReadingTime(pages),
      },

      // 오늘의 독서 통계
      'todayStats': {
        'totalBooks': todayReading.length + 1,
        'totalPages':
            todayReading.fold<int>(0, (sum, log) => sum + log.pages) + pages,
        'bookTitles': [...todayReading.map((r) => r.bookTitle), bookTitle],
        'averageRating': _calculateNewAverageRating(todayReading, rating),
        'readingSpeed': readingSpeed,
      },

      // 독서 습관 분석
      'readingHabits': {
        'weeklyPages': _getWeeklyReadingPages(user),
        'monthlyBooks': _getMonthlyBookCount(user),
        'favoriteGenre': genrePreferences['favorite'],
        'genreDistribution': genrePreferences['distribution'],
        'preferredReadingTime': _getPreferredReadingTime(allTimeReading),
        'averageBookRating': ratingDistribution['average'],
      },

      // 성취 및 진도
      'achievements': {
        'currentStreak': _calculateDetailedStreak(user, 'reading')['current'],
        'totalBooksRead': allTimeReading['totalBooks'],
        'totalPagesRead': allTimeReading['totalPages'],
        'readingLevel': _calculateReadingLevel(allTimeReading),
        'milestones': _getReadingMilestones(user),
      },

      // 추천 및 인사이트
      'insights': {
        'readingTrend': _getActivityTrend(user, 'reading'),
        'completionRate': _getBookCompletionRate(user),
        'diversityScore': _calculateReadingDiversityScore(genrePreferences),
      },

      ...additionalData ?? {},
    };
  }

  /// 📝 일기 작성 상세 데이터 수집
  Map<String, dynamic> collectDiaryData({
    required String mood,
    required String content,
    List<String>? tags,
    Map<String, dynamic>? additionalData,
  }) {
    final user = _ref.read(globalUserProvider);
    final allTimeDiary = _getAllTimeDiaryData(user);

    // 감정 패턴 분석
    final moodPatterns = _analyzeMoodPatterns(allTimeDiary);

    // 작성 시간 패턴
    final writingTimePattern = _getWritingTimePattern(allTimeDiary);

    // 키워드 분석
    final keywords = _extractKeywords(content);

    return {
      // 현재 일기 세션
      'currentEntry': {
        'mood': mood,
        'contentLength': content.length,
        'keywords': keywords,
        'tags': tags ?? [],
        'timestamp': DateTime.now().toIso8601String(),
        'dayOfWeek': DateTime.now().weekday,
      },

      // 감정 통계
      'moodStats': {
        'todayMood': mood,
        'weeklyMoodTrend': moodPatterns['weeklyTrend'],
        'dominantMood': moodPatterns['dominant'],
        'moodVariability': moodPatterns['variability'],
        'positivityScore': _calculatePositivityScore(mood, moodPatterns),
      },

      // 작성 습관
      'writingHabits': {
        'currentStreak': _calculateDetailedStreak(user, 'diary')['current'],
        'totalEntries': allTimeDiary['totalEntries'],
        'averageLength': allTimeDiary['averageLength'],
        'preferredWritingTime': writingTimePattern['preferred'],
        'consistency': _calculateConsistencyScore(user, 'diary'),
      },

      // 성장 지표
      'growthMetrics': {
        'emotionalAwareness': _calculateEmotionalAwarenessScore(moodPatterns),
        'expressiveness': _calculateExpressivenessScore(content, allTimeDiary),
        'reflectionDepth': _analyzeReflectionDepth(content),
      },

      ...additionalData ?? {},
    };
  }

  /// 🎯 퀘스트 완료 상세 데이터 수집
  Map<String, dynamic> collectQuestData({
    required String questName,
    required String questType,
    required int rewardPoints,
    required String difficulty,
    Map<String, dynamic>? additionalData,
  }) {
    final quests = _ref.read(questProviderV2);
    final points = _ref.read(globalPointProvider);

    return quests.when(
      data: (questList) {
        final completedQuests =
            questList.where((q) => q.status == QuestStatus.completed).toList();
        final todayCompleted = _getTodayCompletedQuests(questList);

        return {
          // 현재 퀘스트 정보
          'currentQuest': {
            'name': questName,
            'type': questType,
            'difficulty': difficulty,
            'rewardPoints': rewardPoints,
            'completionTime': DateTime.now().toIso8601String(),
          },

          // 퀘스트 진행 상황
          'progressStats': {
            'todayCompleted': todayCompleted.length + 1,
            'weeklyCompleted': _getWeeklyCompletedQuests(completedQuests),
            'totalCompleted': completedQuests.length + 1,
            'completionRate': _calculateQuestCompletionRate(questList),
            'averageDifficulty': _getAverageQuestDifficulty(completedQuests),
          },

          // 보상 및 포인트
          'rewards': {
            'pointsEarned': rewardPoints,
            'totalPointsToday':
                _getTodayEarnedPoints(points.transactions) + rewardPoints,
            'weeklyPoints': _getWeeklyEarnedPoints(points.transactions),
            'pointsRank': _getPointsRank(points.totalPoints + rewardPoints),
          },

          // 퀘스트 타입별 분석
          'questTypeAnalysis': {
            'favoriteType': _getFavoriteQuestType(completedQuests),
            'typeDistribution': _getQuestTypeDistribution(completedQuests),
            'successRateByType': _getSuccessRateByType(questList),
          },

          ...additionalData ?? {},
        };
      },
      loading: () =>
          _getDefaultQuestData(questName, questType, rewardPoints, difficulty),
      error: (_, __) =>
          _getDefaultQuestData(questName, questType, rewardPoints, difficulty),
    );
  }

  /// 🏔️ 등반 활동 상세 데이터 수집
  Map<String, dynamic> collectClimbingData({
    required String mountainName,
    required double progress,
    required bool isSuccess,
    Map<String, dynamic>? additionalData,
  }) {
    final user = _ref.read(globalUserProvider);

    return {
      // 현재 등반 세션
      'currentClimb': {
        'mountain': mountainName,
        'progress': progress,
        'success': isSuccess,
        'timestamp': DateTime.now().toIso8601String(),
        'difficulty': _getMountainDifficulty(mountainName),
      },

      // 등반 통계
      'climbingStats': {
        'totalMountainsClimbed': _getTotalMountainsClimbed(user),
        'successRate': _getClimbingSuccessRate(user),
        'averageProgress': _getAverageClimbingProgress(user),
        'currentAltitude': _getCurrentAltitude(user),
      },

      // 도전 과제
      'challenges': {
        'nextMountain': _getNextMountain(mountainName),
        'remainingChallenges': _getRemainingChallenges(user),
        'hardestConquered': _getHardestMountainConquered(user),
      },

      ...additionalData ?? {},
    };
  }

  /// 👥 모임 참여 상세 데이터 수집
  Map<String, dynamic> collectMeetingData({
    required String meetingTitle,
    required String meetingType,
    required int participants,
    Map<String, dynamic>? additionalData,
  }) {
    final user = _ref.read(globalUserProvider);
    final meetings = user.dailyRecords.meetingLogs;

    return {
      // 현재 모임 정보
      'currentMeeting': {
        'title': meetingTitle,
        'type': meetingType,
        'participants': participants,
        'timestamp': DateTime.now().toIso8601String(),
      },

      // 소셜 활동 통계
      'socialStats': {
        'todayMeetings': meetings.length + 1,
        'weeklyMeetings': _getWeeklyMeetings(user),
        'totalMeetings': _getTotalMeetings(user),
        'favoriteType': _getFavoriteMeetingType(meetings),
        'socialScore': _calculateSocialScore(user),
      },

      // 네트워킹 지표
      'networking': {
        'totalConnections': _estimateTotalConnections(meetings, participants),
        'diversityScore': _calculateMeetingDiversityScore(meetings),
        'consistency': _calculateConsistencyScore(user, 'meeting'),
      },

      ...additionalData ?? {},
    };
  }

  // ========== Helper Methods ==========

  Map<String, dynamic> _getAllTimeExerciseData(GlobalUser user) {
    // 실제 구현에서는 전체 운동 기록을 분석
    return {
      'totalDays': 30,
      'totalSessions': 45,
      'totalMinutes': 1350,
    };
  }

  Map<String, dynamic> _getAllTimeReadingData(GlobalUser user) {
    return {
      'totalBooks': 12,
      'totalPages': 3600,
      'averageRating': 4.2,
    };
  }

  Map<String, dynamic> _getAllTimeDiaryData(GlobalUser user) {
    return {
      'totalEntries': 25,
      'averageLength': 250,
      'moodHistory': ['happy', 'calm', 'excited'],
    };
  }

  Map<String, int> _getExerciseTypeStats(List<ExerciseLog> exercises) {
    final stats = <String, int>{};
    for (final exercise in exercises) {
      stats[exercise.exerciseType] = (stats[exercise.exerciseType] ?? 0) + 1;
    }
    return stats;
  }

  String _getExerciseTimePattern(List<ExerciseLog> exercises) {
    if (exercises.isEmpty) return 'unknown';

    final hours = exercises.map((e) => e.date.hour).toList();
    final morningCount = hours.where((h) => h >= 5 && h < 12).length;
    final afternoonCount = hours.where((h) => h >= 12 && h < 18).length;
    final eveningCount = hours.where((h) => h >= 18 && h < 24).length;

    if (morningCount > afternoonCount && morningCount > eveningCount) {
      return 'morning_person';
    } else if (eveningCount > morningCount && eveningCount > afternoonCount) {
      return 'evening_person';
    } else {
      return 'flexible';
    }
  }

  Map<String, int> _getIntensityDistribution(List<ExerciseLog> exercises) {
    final distribution = {'low': 0, 'medium': 0, 'high': 0};
    for (final exercise in exercises) {
      distribution[exercise.intensity.toLowerCase()] =
          (distribution[exercise.intensity.toLowerCase()] ?? 0) + 1;
    }
    return distribution;
  }

  bool _checkPersonalRecord(
      {required String exerciseType,
      required int duration,
      required Map<String, dynamic> allTimeData}) {
    // 실제 구현에서는 과거 기록과 비교
    return duration > 45; // 예시: 45분 이상이면 개인 기록
  }

  Map<String, int> _calculateDetailedStreak(
      GlobalUser user, String activityType) {
    // 실제 구현에서는 연속 일수 계산
    return {
      'current': 3,
      'longest': 7,
    };
  }

  int _estimateCalories(String exerciseType, int minutes, String intensity) {
    // 운동 타입과 강도에 따른 칼로리 계산
    final baseCalories = {
      'running': 10,
      'walking': 4,
      'cycling': 8,
      'swimming': 11,
      'yoga': 3,
      'weights': 6,
    };

    final intensityMultiplier = {
      'low': 0.8,
      'medium': 1.0,
      'high': 1.3,
    };

    final base = baseCalories[exerciseType.toLowerCase()] ?? 5;
    final multiplier = intensityMultiplier[intensity.toLowerCase()] ?? 1.0;

    return (base * minutes * multiplier).round();
  }

  double _calculateAverageIntensityScore(
      List<ExerciseLog> exercises, String currentIntensity) {
    if (exercises.isEmpty) {
      return _intensityToScore(currentIntensity);
    }

    double totalScore = exercises.fold(
        0.0, (sum, log) => sum + _intensityToScore(log.intensity));
    totalScore += _intensityToScore(currentIntensity);

    return totalScore / (exercises.length + 1);
  }

  double _intensityToScore(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return 1.0;
      case 'medium':
        return 2.0;
      case 'high':
        return 3.0;
      default:
        return 2.0;
    }
  }

  // 추가 헬퍼 메서드들...
  int _getWeeklyExerciseMinutes(GlobalUser user) => 180;
  int _getMonthlyExerciseMinutes(GlobalUser user) => 720;
  String _getFavoriteExerciseType(Map<String, dynamic> data) => 'running';
  String _getPreferredExerciseTime(Map<String, dynamic> data) => 'morning';
  double _calculateConsistencyScore(GlobalUser user, String activity) => 0.75;
  List<String> _getExerciseMilestones(GlobalUser user) => ['첫 운동', '7일 연속'];
  String _getActivityTrend(GlobalUser user, String activity) => 'improving';
  double _getGoalProgress(GlobalUser user, String activity) => 0.65;
  String _compareToUserAverage(GlobalUser user, String activity, int value) =>
      'above_average';

  int _getWeeklyReadingPages(GlobalUser user) => 140;
  int _getMonthlyBookCount(GlobalUser user) => 3;
  Map<String, dynamic> _analyzeGenrePreferences(Map<String, dynamic> data) => {
        'favorite': 'fiction',
        'distribution': {'fiction': 40, 'non-fiction': 30, 'self-help': 30},
      };
  double _calculateReadingSpeed(List<ReadingLog> logs, int currentPages) =>
      30.0; // pages per hour
  Map<String, dynamic> _getRatingDistribution(Map<String, dynamic> data) => {
        'average': 4.2,
        'distribution': {5: 3, 4: 5, 3: 2},
      };
  String _getPreferredReadingTime(Map<String, dynamic> data) => 'evening';
  double _calculateNewAverageRating(List<ReadingLog> logs, double? rating) {
    if (rating == null) return 0.0;

    final existingRatings =
        logs.where((l) => l.rating != null).map((l) => l.rating!).toList();
    if (existingRatings.isEmpty) return rating;

    final sum = existingRatings.reduce((a, b) => a + b) + rating;
    return sum / (existingRatings.length + 1);
  }

  int _estimateReadingTime(int pages) =>
      (pages * 2).round(); // 2 minutes per page
  int _calculateReadingLevel(Map<String, dynamic> data) => 5;
  List<String> _getReadingMilestones(GlobalUser user) => ['첫 책 완독', '10권 달성'];
  double _getBookCompletionRate(GlobalUser user) => 0.8;
  double _calculateReadingDiversityScore(Map<String, dynamic> preferences) =>
      0.7;

  Map<String, dynamic> _analyzeMoodPatterns(Map<String, dynamic> data) => {
        'weeklyTrend': 'stable',
        'dominant': 'happy',
        'variability': 0.3,
      };
  Map<String, dynamic> _getWritingTimePattern(Map<String, dynamic> data) => {
        'preferred': 'night',
        'consistency': 0.8,
      };
  List<String> _extractKeywords(String content) {
    // 간단한 키워드 추출 (실제로는 더 복잡한 NLP 사용)
    final words = content.split(' ');
    return words.where((w) => w.length > 4).take(5).toList();
  }

  double _calculatePositivityScore(String mood, Map<String, dynamic> patterns) {
    final positiveModds = ['happy', 'excited', 'grateful', 'proud'];
    return positiveModds.contains(mood.toLowerCase()) ? 0.8 : 0.4;
  }

  double _calculateEmotionalAwarenessScore(Map<String, dynamic> patterns) =>
      0.75;
  double _calculateExpressivenessScore(
          String content, Map<String, dynamic> data) =>
      content.length > 200 ? 0.8 : 0.5;
  double _analyzeReflectionDepth(String content) =>
      content.length > 300 ? 0.9 : 0.6;

  List<QuestInstance> _getTodayCompletedQuests(List<QuestInstance> quests) {
    final today = DateTime.now();
    return quests
        .where((q) =>
            q.status == QuestStatus.completed &&
            q.completedAt != null &&
            _isSameDay(q.completedAt!, today))
        .toList();
  }

  int _getWeeklyCompletedQuests(List<QuestInstance> quests) =>
      quests.where((q) => q.status == QuestStatus.completed).length;

  double _calculateQuestCompletionRate(List<QuestInstance> quests) {
    if (quests.isEmpty) return 0.0;
    final completed =
        quests.where((q) => q.status == QuestStatus.completed).length;
    return completed / quests.length;
  }

  String _getAverageQuestDifficulty(List<QuestInstance> quests) => 'medium';
  String _getFavoriteQuestType(List<QuestInstance> quests) => 'daily';
  Map<String, int> _getQuestTypeDistribution(List<QuestInstance> quests) => {
        'daily': 15,
        'weekly': 3,
        'special': 2,
      };
  Map<String, double> _getSuccessRateByType(List<QuestInstance> quests) => {
        'daily': 0.9,
        'weekly': 0.7,
        'special': 0.5,
      };

  Map<String, dynamic> _getDefaultQuestData(
      String questName, String questType, int rewardPoints, String difficulty) {
    return {
      'currentQuest': {
        'name': questName,
        'type': questType,
        'difficulty': difficulty,
        'rewardPoints': rewardPoints,
      },
      'progressStats': {
        'todayCompleted': 1,
        'weeklyCompleted': 5,
        'totalCompleted': 20,
      },
    };
  }

  // 추가 헬퍼 메서드들
  int _getTodayEarnedPoints(List<PointTransaction> transactions) {
    final today = DateTime.now();
    return transactions
        .where((t) => t.isEarned && _isSameDay(t.createdAt, today))
        .fold<int>(0, (sum, t) => sum + t.amount.toInt());
  }

  int _getWeeklyEarnedPoints(List<PointTransaction> transactions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return transactions
        .where((t) => t.isEarned && t.createdAt.isAfter(weekStart))
        .fold<int>(0, (sum, t) => sum + t.amount.toInt());
  }

  String _getPointsRank(int points) {
    if (points < 1000) return 'Bronze';
    if (points < 5000) return 'Silver';
    if (points < 10000) return 'Gold';
    if (points < 50000) return 'Platinum';
    return 'Diamond';
  }

  // 산 관련 메서드
  String _getMountainDifficulty(String mountainName) => 'intermediate';
  int _getTotalMountainsClimbed(GlobalUser user) => 3;
  double _getClimbingSuccessRate(GlobalUser user) => 0.75;
  double _getAverageClimbingProgress(GlobalUser user) => 0.65;
  double _getCurrentAltitude(GlobalUser user) => 1500.0;
  String _getNextMountain(String currentMountain) => '설악산';
  int _getRemainingChallenges(GlobalUser user) => 7;
  String _getHardestMountainConquered(GlobalUser user) => '한라산';

  // 모임 관련 메서드
  int _getWeeklyMeetings(GlobalUser user) => 2;
  int _getTotalMeetings(GlobalUser user) => 15;
  String _getFavoriteMeetingType(List<MeetingLog> meetings) => 'study';
  double _calculateSocialScore(GlobalUser user) => 0.8;
  int _estimateTotalConnections(
          List<MeetingLog> meetings, int currentParticipants) =>
      meetings.length * 5 + currentParticipants;
  double _calculateMeetingDiversityScore(List<MeetingLog> meetings) => 0.6;

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
