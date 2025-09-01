/// 사용자 활동 패턴 분석 모델
/// 사용자의 운동, 독서, 모임, 영화 활동 패턴을 구조화하여 저장

/// 사용자 활동 패턴 분석 결과
class UserActivityPattern {
  /// 사용자 이름
  final String userName;
  
  /// 사용자 레벨
  final int userLevel;
  
  /// 시간대별 활동 패턴
  final Map<String, List<String>> timePatterns;
  
  /// 운동 패턴
  final ExercisePattern exercisePattern;
  
  /// 독서 패턴
  final ReadingPattern readingPattern;
  
  /// 모임 참여 패턴
  final MeetingPattern meetingPattern;
  
  /// 영화 시청 패턴
  final MoviePattern moviePattern;
  
  /// 사용자 성장 지표
  final UserGrowthStats growthStats;
  
  /// 주요 관심사 키워드
  final List<String> interests;
  
  /// 선호 장소들
  final List<String> preferredLocations;
  
  /// 분석 기간
  final DateTimeRange analysisPeriod;

  const UserActivityPattern({
    required this.userName,
    required this.userLevel,
    required this.timePatterns,
    required this.exercisePattern,
    required this.readingPattern,
    required this.meetingPattern,
    required this.moviePattern,
    required this.growthStats,
    required this.interests,
    required this.preferredLocations,
    required this.analysisPeriod,
  });

  /// 활동 요약 텍스트 생성
  String get activitySummary {
    final activities = <String>[];
    
    if (exercisePattern.frequency > 0) {
      activities.add('운동 주 ${exercisePattern.frequency}회');
    }
    if (readingPattern.booksPerWeek > 0) {
      activities.add('독서 주 ${readingPattern.booksPerWeek.toStringAsFixed(1)}권');
    }
    if (meetingPattern.averagePerWeek > 0) {
      activities.add('모임 주 ${meetingPattern.averagePerWeek.toStringAsFixed(1)}회');
    }
    if (moviePattern.moviesPerWeek > 0) {
      activities.add('영화 주 ${moviePattern.moviesPerWeek.toStringAsFixed(1)}편');
    }
    
    return activities.join(', ');
  }
}

/// 운동 패턴 분석
class ExercisePattern {
  /// 주요 운동 종류들
  final List<String> mainTypes;
  
  /// 주간 운동 횟수
  final int frequency;
  
  /// 선호 시간대
  final List<String> preferredTimes;
  
  /// 평균 운동 시간 (분)
  final int averageDuration;
  
  /// 평균 강도 (1-5)
  final double averageIntensity;
  
  /// 최근 운동 장소들 (추론)
  final List<String> locations;

  const ExercisePattern({
    required this.mainTypes,
    required this.frequency,
    required this.preferredTimes,
    required this.averageDuration,
    required this.averageIntensity,
    required this.locations,
  });
  
  /// 패턴 설명 생성
  String get description {
    if (frequency == 0) return '운동 기록 없음';
    
    final timeStr = preferredTimes.isNotEmpty ? preferredTimes.first : '다양한 시간';
    final typeStr = mainTypes.isNotEmpty ? mainTypes.first : '다양한 운동';
    
    return '주 $frequency회 $timeStr에 $typeStr';
  }
}

/// 독서 패턴 분석
class ReadingPattern {
  /// 주요 카테고리들
  final List<String> mainCategories;
  
  /// 주간 독서량
  final double booksPerWeek;
  
  /// 선호 독서 시간대
  final List<String> preferredTimes;
  
  /// 평균 평점
  final double averageRating;
  
  /// 최근 완독한 책들
  final List<String> recentBooks;

  const ReadingPattern({
    required this.mainCategories,
    required this.booksPerWeek,
    required this.preferredTimes,
    required this.averageRating,
    required this.recentBooks,
  });
  
  /// 패턴 설명 생성
  String get description {
    if (booksPerWeek == 0) return '독서 기록 없음';
    
    final categoryStr = mainCategories.isNotEmpty ? mainCategories.join(', ') : '다양한 장르';
    return '$categoryStr 분야 주 ${booksPerWeek.toStringAsFixed(1)}권';
  }
}

/// 모임 참여 패턴 분석
class MeetingPattern {
  /// 선호 카테고리들
  final List<String> preferredCategories;
  
  /// 주간 평균 참여 횟수
  final double averagePerWeek;
  
  /// 평균 만족도 (1-5)
  final double averageSatisfaction;
  
  /// 최근 참여 모임들
  final List<String> recentMeetings;
  
  /// 선호 모임 시간대
  final List<String> preferredTimes;

  const MeetingPattern({
    required this.preferredCategories,
    required this.averagePerWeek,
    required this.averageSatisfaction,
    required this.recentMeetings,
    required this.preferredTimes,
  });
  
  /// 패턴 설명 생성
  String get description {
    if (averagePerWeek == 0) return '모임 참여 없음';
    
    final categoryStr = preferredCategories.isNotEmpty ? 
      preferredCategories.first : '다양한 모임';
    return '$categoryStr 중심 주 ${averagePerWeek.toStringAsFixed(1)}회';
  }
}

/// 영화 시청 패턴 분석
class MoviePattern {
  /// 선호 장르들
  final List<String> preferredGenres;
  
  /// 주간 평균 시청 편수
  final double moviesPerWeek;
  
  /// 선호 시청 시간대
  final List<String> preferredTimes;
  
  /// 평균 평점
  final double averageRating;
  
  /// 최근 시청 영화들
  final List<String> recentMovies;

  const MoviePattern({
    required this.preferredGenres,
    required this.moviesPerWeek,
    required this.preferredTimes,
    required this.averageRating,
    required this.recentMovies,
  });
  
  /// 패턴 설명 생성
  String get description {
    if (moviesPerWeek == 0) return '영화 시청 없음';
    
    final genreStr = preferredGenres.isNotEmpty ? 
      preferredGenres.join(', ') : '다양한 장르';
    return '$genreStr 주 ${moviesPerWeek.toStringAsFixed(1)}편';
  }
}

/// 사용자 성장 지표
class UserGrowthStats {
  final int stamina;      // 스태미나
  final int knowledge;     // 지식
  final int technique;     // 기술력
  final int sociality;     // 사교성
  final int willpower;     // 의지력

  const UserGrowthStats({
    required this.stamina,
    required this.knowledge,
    required this.technique,
    required this.sociality,
    required this.willpower,
  });
  
  /// 총합 계산
  int get total => stamina + knowledge + technique + sociality + willpower;
  
  /// 주요 강점 파악
  String get mainStrength {
    final stats = {
      '체력': stamina,
      '지식': knowledge,
      '기술': technique,
      '사교성': sociality,
      '의지력': willpower,
    };
    
    final sorted = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }
}

/// 날짜 범위
class DateTimeRange {
  final DateTime start;
  final DateTime end;
  
  const DateTimeRange({
    required this.start,
    required this.end,
  });
  
  /// 기간 일수 계산
  int get days => end.difference(start).inDays;
}