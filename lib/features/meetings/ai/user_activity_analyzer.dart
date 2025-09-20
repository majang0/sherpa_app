/// 사용자 활동 패턴 분석기
/// 운동, 독서, 모임, 영화 등의 활동 데이터를 분석하여 패턴을 추출

import 'dart:math';
import '../../../../shared/models/global_user_model.dart';
import '../models/available_meeting_model.dart';
import 'models/user_activity_pattern.dart';

class UserActivityAnalyzer {
  /// 분석 기간 (기본 2주)
  static const int _analysisWindowDays = 14;

  /// 시간대 구분
  static const Map<String, List<int>> _timePeriods = {
    '새벽': [0, 1, 2, 3, 4, 5], // 00:00 - 05:59
    '아침': [6, 7, 8, 9, 10, 11], // 06:00 - 11:59
    '오후': [12, 13, 14, 15, 16, 17], // 12:00 - 17:59
    '저녁': [18, 19, 20, 21], // 18:00 - 21:59
    '밤': [22, 23], // 22:00 - 23:59
  };

  /// 사용자 활동 패턴 분석
  UserActivityPattern analyzeUserActivity(GlobalUser user) {
    final now = DateTime.now();
    final analysisStart = now.subtract(Duration(days: _analysisWindowDays));

    // 각 활동 타입별 패턴 분석
    final exercisePattern = _analyzeExercisePattern(user, analysisStart);
    final readingPattern = _analyzeReadingPattern(user, analysisStart);
    final meetingPattern = _analyzeMeetingPattern(user, analysisStart);
    final moviePattern = _analyzeMoviePattern(user, analysisStart);

    // 시간대별 활동 패턴 추출
    final timePatterns = _extractTimePatterns(user, analysisStart);

    // 관심사 키워드 추출
    final interests = _extractInterests(
      exercisePattern,
      readingPattern,
      meetingPattern,
      moviePattern,
    );

    // 선호 장소 추출
    final preferredLocations = _extractPreferredLocations(user, analysisStart);

    // 성장 지표 가져오기
    final growthStats = UserGrowthStats(
      stamina: user.stats.stamina.toInt(),
      knowledge: user.stats.knowledge.toInt(),
      technique: user.stats.technique.toInt(),
      sociality: user.stats.sociality.toInt(),
      willpower: user.stats.willpower.toInt(),
    );

    return UserActivityPattern(
      userName: user.name,
      userLevel: user.level,
      timePatterns: timePatterns,
      exercisePattern: exercisePattern,
      readingPattern: readingPattern,
      meetingPattern: meetingPattern,
      moviePattern: moviePattern,
      growthStats: growthStats,
      interests: interests,
      preferredLocations: preferredLocations,
      analysisPeriod: DateTimeRange(start: analysisStart, end: now),
    );
  }

  /// 운동 패턴 분석
  ExercisePattern _analyzeExercisePattern(GlobalUser user, DateTime start) {
    final recentExercises = user.dailyRecords.exerciseLogs
        .where((log) => log.date.isAfter(start))
        .toList();

    if (recentExercises.isEmpty) {
      return const ExercisePattern(
        mainTypes: [],
        frequency: 0,
        preferredTimes: [],
        averageDuration: 0,
        averageIntensity: 0,
        locations: [],
      );
    }

    // 운동 종류별 빈도 계산
    final typeFrequency = <String, int>{};
    for (var exercise in recentExercises) {
      typeFrequency[exercise.exerciseType] =
          (typeFrequency[exercise.exerciseType] ?? 0) + 1;
    }

    // 상위 3개 운동 종류
    final mainTypes = typeFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 시간대별 분석
    final timeFrequency = <String, int>{};
    for (var exercise in recentExercises) {
      final hour = exercise.date.hour;
      final period = _getTimePeriod(hour);
      timeFrequency[period] = (timeFrequency[period] ?? 0) + 1;
    }

    final preferredTimes = timeFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 평균 계산
    final totalDuration = recentExercises.fold<int>(
      0,
      (sum, e) => sum + e.durationMinutes,
    );
    final totalIntensity = recentExercises.fold<double>(
      0.0,
      (sum, e) => sum + _getIntensityValue(e.intensity),
    );

    // 장소 추론 (운동 종류에서 추론)
    final locations =
        _inferExerciseLocations(mainTypes.take(3).map((e) => e.key).toList());

    // 주간 횟수 계산
    final weeks = _analysisWindowDays / 7;
    final frequency = (recentExercises.length / weeks).round();

    return ExercisePattern(
      mainTypes: mainTypes.take(3).map((e) => e.key).toList(),
      frequency: frequency,
      preferredTimes: preferredTimes.take(2).map((e) => e.key).toList(),
      averageDuration:
          recentExercises.isEmpty ? 0 : totalDuration ~/ recentExercises.length,
      averageIntensity:
          recentExercises.isEmpty ? 0 : totalIntensity / recentExercises.length,
      locations: locations,
    );
  }

  /// 독서 패턴 분석
  ReadingPattern _analyzeReadingPattern(GlobalUser user, DateTime start) {
    final recentReadings = user.dailyRecords.readingLogs
        .where((log) => log.date.isAfter(start))
        .toList();

    if (recentReadings.isEmpty) {
      return const ReadingPattern(
        mainCategories: [],
        booksPerWeek: 0,
        preferredTimes: [],
        averageRating: 0,
        recentBooks: [],
      );
    }

    // 카테고리별 빈도
    final categoryFrequency = <String, int>{};
    for (var reading in recentReadings) {
      categoryFrequency[reading.category] =
          (categoryFrequency[reading.category] ?? 0) + 1;
    }

    final mainCategories = categoryFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 시간대 분석 (날짜 기반으로 추론)
    final timeFrequency = <String, int>{};
    for (var reading in recentReadings) {
      // 독서는 주로 저녁이나 밤에 한다고 가정
      final hour = reading.date.hour;
      final period = hour >= 20
          ? '밤'
          : hour >= 18
              ? '저녁'
              : '오후';
      timeFrequency[period] = (timeFrequency[period] ?? 0) + 1;
    }

    // 평균 평점 계산
    final ratings = recentReadings
        .where((r) => r.rating != null)
        .map((r) => r.rating!.toDouble())
        .toList();

    final averageRating = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;

    // 최근 책들
    final recentBooks = recentReadings.take(5).map((r) => r.bookTitle).toList();

    // 주간 독서량
    final weeks = _analysisWindowDays / 7;
    final booksPerWeek = recentReadings.length / weeks;

    return ReadingPattern(
      mainCategories: mainCategories.take(3).map((e) => e.key).toList(),
      booksPerWeek: booksPerWeek,
      preferredTimes: () {
        final entries = timeFrequency.entries.toList();
        entries.sort((a, b) => b.value.compareTo(a.value));
        return entries.take(2).map((e) => e.key).toList();
      }(),
      averageRating: averageRating,
      recentBooks: recentBooks,
    );
  }

  /// 모임 참여 패턴 분석
  MeetingPattern _analyzeMeetingPattern(GlobalUser user, DateTime start) {
    final recentMeetings = user.dailyRecords.meetingLogs
        .where((log) => log.date.isAfter(start))
        .toList();

    if (recentMeetings.isEmpty) {
      return const MeetingPattern(
        preferredCategories: [],
        averagePerWeek: 0,
        averageSatisfaction: 0,
        recentMeetings: [],
        preferredTimes: [],
      );
    }

    // 카테고리별 빈도
    final categoryFrequency = <String, int>{};
    for (var meeting in recentMeetings) {
      categoryFrequency[meeting.category] =
          (categoryFrequency[meeting.category] ?? 0) + 1;
    }

    final preferredCategories = () {
      final entries = categoryFrequency.entries.toList();
      entries.sort((a, b) => b.value.compareTo(a.value));
      return entries.take(3).map((e) => e.key).toList();
    }();

    // 평균 만족도
    final totalSatisfaction = recentMeetings.fold(
      0.0,
      (sum, m) => sum + m.satisfaction,
    );
    final averageSatisfaction = totalSatisfaction / recentMeetings.length;

    // 최근 모임들
    final recentMeetingTitles =
        recentMeetings.take(5).map((m) => m.meetingName).toList();

    // 시간대 분석
    final timeFrequency = <String, int>{};
    for (var meeting in recentMeetings) {
      final hour = meeting.date.hour;
      final period = _getTimePeriod(hour);
      timeFrequency[period] = (timeFrequency[period] ?? 0) + 1;
    }

    final preferredTimes = () {
      final entries = timeFrequency.entries.toList();
      entries.sort((a, b) => b.value.compareTo(a.value));
      return entries.take(2).map((e) => e.key).toList();
    }();

    // 주간 평균
    final weeks = _analysisWindowDays / 7;
    final averagePerWeek = recentMeetings.length / weeks;

    return MeetingPattern(
      preferredCategories: preferredCategories,
      averagePerWeek: averagePerWeek,
      averageSatisfaction: averageSatisfaction,
      recentMeetings: recentMeetingTitles,
      preferredTimes: preferredTimes,
    );
  }

  /// 영화 시청 패턴 분석
  MoviePattern _analyzeMoviePattern(GlobalUser user, DateTime start) {
    final recentMovies = user.dailyRecords.movieLogs
        .where((log) => log.date.isAfter(start))
        .toList();

    if (recentMovies.isEmpty) {
      return const MoviePattern(
        preferredGenres: [],
        moviesPerWeek: 0,
        preferredTimes: [],
        averageRating: 0,
        recentMovies: [],
      );
    }

    // 장르별 빈도
    final genreFrequency = <String, int>{};
    for (var movie in recentMovies) {
      genreFrequency[movie.genre] = (genreFrequency[movie.genre] ?? 0) + 1;
    }

    final preferredGenres = () {
      final entries = genreFrequency.entries.toList();
      entries.sort((a, b) => b.value.compareTo(a.value));
      return entries.take(3).map((e) => e.key).toList();
    }();

    // 평균 평점
    final ratings = recentMovies
        .where((m) => m.rating != null)
        .map((m) => m.rating!.toDouble())
        .toList();

    final averageRating = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;

    // 최근 영화들
    final recentMovieTitles =
        recentMovies.take(5).map((m) => m.movieTitle).toList();

    // 시간대 분석 (주로 저녁/밤 시청 가정)
    final preferredTimes = ['저녁', '밤'];

    // 주간 평균
    final weeks = _analysisWindowDays / 7;
    final moviesPerWeek = recentMovies.length / weeks;

    return MoviePattern(
      preferredGenres: preferredGenres,
      moviesPerWeek: moviesPerWeek,
      preferredTimes: preferredTimes,
      averageRating: averageRating,
      recentMovies: recentMovieTitles,
    );
  }

  /// 시간대별 활동 패턴 추출
  Map<String, List<String>> _extractTimePatterns(
      GlobalUser user, DateTime start) {
    final patterns = <String, List<String>>{};

    // 운동 시간대
    final exerciseTimes = user.dailyRecords.exerciseLogs
        .where((log) => log.date.isAfter(start))
        .map((log) => _getTimePeriod(log.date.hour))
        .toList();

    // 독서 시간대 (주로 저녁/밤)
    final readingTimes = user.dailyRecords.readingLogs
        .where((log) => log.date.isAfter(start))
        .map((_) => Random().nextBool() ? '저녁' : '밤')
        .toList();

    // 각 시간대별로 활동 집계
    for (var period in _timePeriods.keys) {
      final activities = <String>[];

      if (exerciseTimes.where((t) => t == period).length > 2) {
        activities.add('운동');
      }
      if (readingTimes.where((t) => t == period).length > 2) {
        activities.add('독서');
      }

      if (activities.isNotEmpty) {
        patterns[period] = activities;
      }
    }

    return patterns;
  }

  /// 관심사 키워드 추출
  List<String> _extractInterests(
    ExercisePattern exercise,
    ReadingPattern reading,
    MeetingPattern meeting,
    MoviePattern movie,
  ) {
    final interests = <String>{};

    // 운동 관심사
    interests.addAll(exercise.mainTypes);

    // 독서 카테고리
    for (var category in reading.mainCategories) {
      interests.add(category);
      // 카테고리 관련 키워드 추가
      interests.addAll(_getRelatedKeywords(category));
    }

    // 모임 카테고리
    for (var category in meeting.preferredCategories) {
      interests.add(category);
    }

    // 영화 장르
    for (var genre in movie.preferredGenres) {
      interests.add(genre);
    }

    return interests.toList()..take(10); // 최대 10개
  }

  /// 선호 장소 추출
  List<String> _extractPreferredLocations(GlobalUser user, DateTime start) {
    final locations = <String>[];

    // 운동 장소 추론
    final exercises = user.dailyRecords.exerciseLogs
        .where((log) => log.date.isAfter(start))
        .toList();

    for (var exercise in exercises) {
      final inferredLocations =
          _inferLocationFromExercise(exercise.exerciseType);
      locations.addAll(inferredLocations);
    }

    // 중복 제거 및 빈도순 정렬
    final locationFrequency = <String, int>{};
    for (var location in locations) {
      locationFrequency[location] = (locationFrequency[location] ?? 0) + 1;
    }

    final sortedLocations = locationFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedLocations.take(5).map((e) => e.key).toList();
  }

  /// 시간대 구분 헬퍼
  String _getTimePeriod(int hour) {
    for (var entry in _timePeriods.entries) {
      if (entry.value.contains(hour)) {
        return entry.key;
      }
    }
    return '기타';
  }

  /// 운동 종류에서 장소 추론
  List<String> _inferExerciseLocations(List<String> exerciseTypes) {
    final locations = <String>[];

    for (var type in exerciseTypes) {
      final lowerType = type.toLowerCase();

      if (lowerType.contains('러닝') ||
          lowerType.contains('달리기') ||
          lowerType.contains('조깅')) {
        locations.addAll(['한강', '신천', '양재천', '공원']);
      } else if (lowerType.contains('헬스') || lowerType.contains('웨이트')) {
        locations.addAll(['헬스장', '피트니스센터']);
      } else if (lowerType.contains('요가') || lowerType.contains('필라테스')) {
        locations.addAll(['요가원', '필라테스센터']);
      } else if (lowerType.contains('수영')) {
        locations.addAll(['수영장', '스포츠센터']);
      } else if (lowerType.contains('등산') || lowerType.contains('하이킹')) {
        locations.addAll(['남산', '북한산', '관악산']);
      } else if (lowerType.contains('자전거') || lowerType.contains('사이클')) {
        locations.addAll(['한강', '자전거도로']);
      }
    }

    return locations.toSet().toList(); // 중복 제거
  }

  /// 단일 운동에서 장소 추론
  List<String> _inferLocationFromExercise(String exerciseType) {
    final lowerType = exerciseType.toLowerCase();

    if (lowerType.contains('러닝') || lowerType.contains('달리기')) {
      return ['신천', '한강'];
    } else if (lowerType.contains('헬스') || lowerType.contains('웨이트')) {
      return ['헬스장'];
    } else if (lowerType.contains('요가')) {
      return ['요가원'];
    } else if (lowerType.contains('수영')) {
      return ['수영장'];
    }

    return [];
  }

  /// 카테고리 관련 키워드 추출
  List<String> _getRelatedKeywords(String category) {
    switch (category) {
      case '자기계발':
        return ['성장', '목표', '습관'];
      case '경영':
      case '비즈니스':
        return ['리더십', '전략', '창업'];
      case 'IT':
      case '과학':
        return ['기술', '프로그래밍', '혁신'];
      case '소설':
      case '에세이':
        return ['문학', '감성', '스토리'];
      case '예술':
      case '철학':
        return ['문화', '사상', '창의성'];
      case '역사':
        return ['과거', '전통', '문화'];
      case '여행':
        return ['모험', '탐험', '문화체험'];
      default:
        return [];
    }
  }

  /// 강도 문자열을 숫자값으로 변환
  double _getIntensityValue(String intensity) {
    switch (intensity) {
      case '낮음':
        return 1.0;
      case '보통':
        return 2.0;
      case '높음':
        return 3.0;
      case '매우 높음':
        return 4.0;
      default:
        return 2.0; // 기본값은 보통
    }
  }

  /// 모임 카테고리 매칭 점수 계산
  double calculateCategoryMatchScore(
    UserActivityPattern pattern,
    MeetingCategory meetingCategory,
  ) {
    double score = 0.0;

    // 운동 모임과 운동 패턴 매칭
    if (meetingCategory == MeetingCategory.exercise &&
        pattern.exercisePattern.frequency > 0) {
      score += 0.3 * min(pattern.exercisePattern.frequency / 5, 1.0);
    }

    // 독서 모임과 독서 패턴 매칭
    if (meetingCategory == MeetingCategory.reading &&
        pattern.readingPattern.booksPerWeek > 0) {
      score += 0.3 * min(pattern.readingPattern.booksPerWeek / 3, 1.0);
    }

    // 네트워킹과 사교성 매칭
    if (meetingCategory == MeetingCategory.networking) {
      score += 0.2 * (pattern.growthStats.sociality / 100);
    }

    // 스터디와 지식 매칭
    if (meetingCategory == MeetingCategory.study) {
      score += 0.2 * (pattern.growthStats.knowledge / 100);
    }

    // 문화와 독서/영화 패턴 매칭
    if (meetingCategory == MeetingCategory.culture) {
      final culturalActivity = pattern.readingPattern.booksPerWeek +
          pattern.moviePattern.moviesPerWeek;
      score += 0.3 * min(culturalActivity / 5, 1.0);
    }

    // 아웃도어와 운동 패턴 매칭
    if (meetingCategory == MeetingCategory.outdoor) {
      final outdoorTypes = pattern.exercisePattern.mainTypes
          .where(
              (t) => t.contains('등산') || t.contains('러닝') || t.contains('자전거'))
          .length;
      if (outdoorTypes > 0) {
        score += 0.3;
      }
    }

    // 기존 모임 참여 이력 반영
    if (pattern.meetingPattern.preferredCategories
        .contains(meetingCategory.displayName)) {
      score += 0.2;
    }

    return min(score, 1.0);
  }
}
