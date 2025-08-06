// lib/features/daily_record/services/sample_data_generator.dart

import 'dart:math' as math;
import '../../../shared/models/global_user_model.dart';
import '../../../shared/providers/global_user_provider.dart';

/// 14일간 샘플 데이터 생성 서비스
/// 앱 초기 사용자에게 풍부한 예시 데이터를 제공
class SampleDataGenerator {
  static final _random = math.Random();

  /// 14일간의 완전한 샘플 데이터 생성
  static DailyRecordData generateSampleData() {
    final now = DateTime.now();
    final sampleLogs = _generateSampleLogs(now);
    
    final meetingCount = (sampleLogs['meetings'] as List<MeetingLog>).length;
    
    final result = DailyRecordData(
      todaySteps: _generateTodaySteps(),
      todayFocusMinutes: _generateTodayFocus(),
      meetingLogs: sampleLogs['meetings'] as List<MeetingLog>,
      readingLogs: sampleLogs['readings'] as List<ReadingLog>,
      exerciseLogs: sampleLogs['exercises'] as List<ExerciseLog>,
      diaryLogs: sampleLogs['diaries'] as List<DiaryLog>,
      movieLogs: sampleLogs['movies'] as List<MovieLog>,
      dailyGoals: _generateTodayGoals(),
      climbingLogs: [], // 등반 기록 추가 (빈 리스트),
      challengeRecords: [],
      consecutiveDays: _generateConsecutiveDays(),
      lastActiveDate: now,
      isAllGoalsCompleted: false,
      isAllGoalsRewardClaimed: false,
    );
    
    return result;
  }

  /// 오늘의 걸음수 생성 (4000~15000 사이)
  static int _generateTodaySteps() {
    return 4000 + _random.nextInt(11001);
  }

  /// 오늘의 집중 시간 생성 (20~150분)
  static int _generateTodayFocus() {
    return 20 + _random.nextInt(131);
  }

  /// 연속 달성일 생성 (3~12일)
  static int _generateConsecutiveDays() {
    return 3 + _random.nextInt(10);
  }

  /// 오늘의 목표 생성 (일부 완료된 상태)
  static List<DailyGoal> _generateTodayGoals() {
    final defaultGoals = DailyGoal.createDefaultGoals();
    final completedCount = 2 + _random.nextInt(3); // 2~4개 완료
    
    for (int i = 0; i < completedCount; i++) {
      if (i < defaultGoals.length) {
        defaultGoals[i] = defaultGoals[i].copyWith(
          isCompleted: true,
          completedAt: DateTime.now().subtract(Duration(hours: _random.nextInt(12))),
        );
      }
    }
    
    return defaultGoals;
  }

  /// 60일간의 모든 활동 로그 생성
  static Map<String, List> _generateSampleLogs(DateTime now) {
    final meetings = <MeetingLog>[];
    final readings = <ReadingLog>[];
    final exercises = <ExerciseLog>[];
    final diaries = <DiaryLog>[];
    final movies = <MovieLog>[];

    for (int i = 0; i < 60; i++) {
      final date = now.subtract(Duration(days: i));
      
      // 모임 생성 - 더 다양한 패턴으로 생성
      final meetingCount = _getMeetingCountForDay(i);
      for (int j = 0; j < meetingCount; j++) {
        final meeting = _generateMeetingLog(date, j);
        meetings.add(meeting);
      }
      
      if (_random.nextDouble() < 0.6) {
        readings.add(_generateReadingLog(date));
      }
      
      // 운동 데이터 대폭 증가 - 거의 매일 1-3개의 운동 기록
      final exerciseCount = _getExerciseCountForDay(i);
      for (int k = 0; k < exerciseCount; k++) {
        exercises.add(_generateExerciseLog(date, k));
      }
      
      if (_random.nextDouble() < 0.4) {
        diaries.add(_generateDiaryLog(date));
      }
      
      if (_random.nextDouble() < 0.3) {
        movies.add(_generateMovieLog(date));
      }
    }

    
    return {
      'meetings': meetings,
      'readings': readings,
      'exercises': exercises,
      'diaries': diaries,
      'movies': movies,
    };
  }

  /// 날짜별 모임 개수 결정 (더 현실적인 패턴)
  static int _getMeetingCountForDay(int dayIndex) {
    // 특정 날짜에 여러 모임이 있도록 설정
    if (dayIndex == 1) return 3; // 어제 - 바쁜 하루
    if (dayIndex == 4) return 2; // 4일 전 - 모임 많은 날
    if (dayIndex == 7) return 2; // 1주일 전 - 주말 모임들
    if (dayIndex == 10) return 4; // 10일 전 - 매우 바쁜 하루
    
    // 나머지 날짜는 70% 확률로 0-1개
    if (_random.nextDouble() < 0.7) {
      return _random.nextDouble() < 0.8 ? 1 : 2; // 80% 확률로 1개, 20% 확률로 2개
    }
    return 0;
  }

  /// 모임 로그 생성
  static MeetingLog _generateMeetingLog(DateTime date, int index) {
    final meetingData = [
      {'name': '프론트엔드 스터디', 'category': '스터디'},
      {'name': '독서 모임', 'category': '독서'},
      {'name': '영어 회화 클럽', 'category': '스터디'},
      {'name': '헬스 운동 모임', 'category': '운동'},
      {'name': '창업 동아리', 'category': '네트워킹'},
      {'name': '디자인 워크숍', 'category': '취미'},
      {'name': '토론 모임', 'category': '스터디'},
      {'name': '코딩 부트캠프', 'category': '스터디'},
      {'name': '마케팅 세미나', 'category': '업무'},
      {'name': 'UX/UI 스터디', 'category': '스터디'},
      {'name': '사진 동호회', 'category': '취미'},
      {'name': '요리 클래스', 'category': '취미'},
      {'name': '등산 모임', 'category': '운동'},
      {'name': '북 클럽', 'category': '독서'},
      {'name': '친목 모임', 'category': '친목'},
      {'name': '봉사 활동', 'category': '봉사'},
      {'name': '종교 모임', 'category': '종교'},
      {'name': '네트워킹 파티', 'category': '네트워킹'},
      {'name': '스타트업 밋업', 'category': '네트워킹'},
      {'name': '요가 클래스', 'category': '운동'},
    ];
    
    final moods = ['very_happy', 'happy', 'good', 'normal'];
    
    final selectedMeeting = meetingData[_random.nextInt(meetingData.length)];
    
    return MeetingLog(
      id: 'meeting_${date.millisecondsSinceEpoch}_$index',
      date: date.add(Duration(hours: 9 + index * 2)), // 시간대 분산
      meetingName: selectedMeeting['name']!,
      category: selectedMeeting['category']!,
      satisfaction: 2.5 + _random.nextDouble() * 2.5, // 2.5~5.0
      mood: moods[_random.nextInt(moods.length)],
      note: _random.nextDouble() < 0.4 ? _generateMeetingNote() : null,
      isShared: _random.nextBool(),
    );
  }

  /// 독서 로그 생성
  static ReadingLog _generateReadingLog(DateTime date) {
    final books = [
      {'title': '아토믹 해빗', 'author': '제임스 클리어'},
      {'title': '사피엔스', 'author': '유발 하라리'},
      {'title': '데일 카네기 인간관계론', 'author': '데일 카네기'},
      {'title': '부의 시나리오', 'author': '박종훈'},
      {'title': '하루 3분 네트워크 교실', 'author': '망리사 유지'},
      {'title': '클린 코드', 'author': '로버트 마틴'},
      {'title': '리팩토링', 'author': '마틴 파울러'},
      {'title': '이펙티브 자바', 'author': '조슈아 블로크'},
      {'title': '대화의 기술', 'author': '라이언 김'},
      {'title': '습관의 재발견', 'author': '찰스 두히그'}
    ];
    
    final book = books[_random.nextInt(books.length)];
    final pages = 1 + _random.nextInt(50); // 1~50페이지
    
    final moods = ['happy', 'excited', 'thoughtful', 'moved', 'surprised', 'calm'];
    
    return ReadingLog(
      id: 'reading_${date.millisecondsSinceEpoch}',
      date: date,
      bookTitle: book['title']!,
      author: book['author']!,
      category: _getBookCategory(book['title']!),
      pages: pages,
      rating: 3.0 + _random.nextDouble() * 2.0, // 3.0~5.0
      mood: _random.nextDouble() < 0.7 ? moods[_random.nextInt(moods.length)] : null,
      note: _random.nextDouble() < 0.4 ? _generateReadingNote() : null,
    );
  }

  /// 날짜별 운동 개수 결정 (거의 매일 1-3개 운동)
  static int _getExerciseCountForDay(int dayIndex) {
    // 특정 날짜에 더 많은 운동이 있도록 설정
    if (dayIndex == 0) return 2; // 오늘 - 활발한 운동
    if (dayIndex == 2) return 3; // 2일 전 - 매우 활발한 날
    if (dayIndex == 5) return 3; // 5일 전 - 주말 운동
    if (dayIndex == 8) return 4; // 8일 전 - 최대 운동량
    if (dayIndex == 12) return 3; // 12일 전 - 활발한 운동
    if (dayIndex == 15) return 2; // 15일 전 - 중간 운동량
    if (dayIndex == 20) return 4; // 20일 전 - 최대 운동량
    if (dayIndex == 25) return 3; // 25일 전 - 활발한 운동
    if (dayIndex == 30) return 3; // 30일 전 - 월 중간 활발
    if (dayIndex == 35) return 2; // 35일 전 - 중간 운동량
    if (dayIndex == 40) return 4; // 40일 전 - 최대 운동량
    if (dayIndex == 45) return 3; // 45일 전 - 활발한 운동
    if (dayIndex == 50) return 2; // 50일 전 - 중간 운동량
    if (dayIndex == 55) return 3; // 55일 전 - 활발한 운동
    
    // 나머지 날짜는 90% 확률로 1-2개 운동
    if (_random.nextDouble() < 0.9) {
      return _random.nextDouble() < 0.7 ? 1 : 2; // 70% 확률로 1개, 30% 확률로 2개
    }
    return 0; // 10% 확률로 휴식일
  }

  /// 운동 로그 생성 (5개 주요 운동 타입 위주)
  static ExerciseLog _generateExerciseLog(DateTime date, int index) {
    // 5개 주요 운동 타입 (70% 확률)
    final primaryExerciseTypes = ['러닝', '클라이밍', '등산', '헬스', '배드민턴'];
    
    // 기타 운동 타입 (30% 확률)
    final secondaryExerciseTypes = [
      '걷기', '자전거', '수영', '요가', '필라테스', '테니스', '축구', '농구'
    ];
    
    final intensities = ['light', 'moderate', 'vigorous'];
    
    // 70% 확률로 주요 운동, 30% 확률로 기타 운동
    final exerciseType = _random.nextDouble() < 0.7 
        ? primaryExerciseTypes[_random.nextInt(primaryExerciseTypes.length)]
        : secondaryExerciseTypes[_random.nextInt(secondaryExerciseTypes.length)];
    
    // 운동 타입별 적절한 시간 설정
    int duration;
    String intensity;
    
    switch (exerciseType) {
      case '러닝':
        duration = 30 + _random.nextInt(61); // 30~90분
        intensity = ['moderate', 'vigorous'][_random.nextInt(2)];
        break;
      case '클라이밍':
        duration = 60 + _random.nextInt(61); // 60~120분
        intensity = ['moderate', 'vigorous'][_random.nextInt(2)];
        break;
      case '등산':
        duration = 120 + _random.nextInt(181); // 120~300분
        intensity = ['moderate', 'vigorous'][_random.nextInt(2)];
        break;
      case '헬스':
        duration = 45 + _random.nextInt(76); // 45~120분
        intensity = ['moderate', 'vigorous'][_random.nextInt(2)];
        break;
      case '배드민턴':
        duration = 60 + _random.nextInt(61); // 60~120분
        intensity = ['moderate', 'vigorous'][_random.nextInt(2)];
        break;
      case '걷기':
        duration = 20 + _random.nextInt(41); // 20~60분
        intensity = ['light', 'moderate'][_random.nextInt(2)];
        break;
      case '요가':
        duration = 45 + _random.nextInt(46); // 45~90분
        intensity = ['light', 'moderate'][_random.nextInt(2)];
        break;
      default:
        duration = 30 + _random.nextInt(91); // 30~120분
        intensity = intensities[_random.nextInt(intensities.length)];
    }
    
    return ExerciseLog(
      id: 'exercise_${date.millisecondsSinceEpoch}_$index',
      date: date.add(Duration(hours: 6 + index * 2)), // 시간대 분산
      exerciseType: exerciseType,
      durationMinutes: duration,
      intensity: intensity,
      note: _random.nextDouble() < 0.4 ? _generateExerciseNote() : null,
    );
  }

  /// 일기 로그 생성
  static DiaryLog _generateDiaryLog(DateTime date) {
    final titles = [
      '오늘의 성찰', '새로운 도전', '감사한 하루', '배움의 시간',
      '작은 성취감', '힐링 타임', '계획과 실행', '소중한 만남',
      '성장하는 하루', '평범한 일상', '의미 있는 시간', '새로운 시작'
    ];
    
    final moods = ['very_happy', 'happy', 'good', 'normal', 'thoughtful'];
    
    return DiaryLog(
      id: 'diary_${date.millisecondsSinceEpoch}',
      date: date,
      title: titles[_random.nextInt(titles.length)],
      content: _generateDiaryContent(),
      mood: moods[_random.nextInt(moods.length)],
    );
  }

  /// 모임 후기 생성
  static String _generateMeetingNote() {
    final notes = [
      '새로운 것을 많이 배웠습니다. 다음에도 참여하고 싶어요!',
      '좋은 사람들과 유익한 시간을 보냈습니다.',
      '생각보다 더 재미있었어요. 추천합니다!',
      '전문성을 키울 수 있는 좋은 기회였습니다.',
      '네트워킹도 하고 지식도 쌓는 일석이조의 시간!',
      '준비가 철저해서 만족스러웠습니다.',
    ];
    return notes[_random.nextInt(notes.length)];
  }

  /// 독서 후기 생성
  static String _generateReadingNote() {
    final notes = [
      '실무에 바로 적용할 수 있는 유용한 내용이었습니다.',
      '새로운 관점을 제시해주는 흥미로운 책이네요.',
      '이해하기 쉽게 잘 쓰여진 책입니다.',
      '삶에 도움이 되는 인사이트를 얻었습니다.',
      '계속 읽어가고 싶은 좋은 책입니다.',
      '추천하고 싶은 책이에요!',
    ];
    return notes[_random.nextInt(notes.length)];
  }

  /// 운동 후기 생성 (운동 타입별 특화)
  static String _generateExerciseNote() {
    final generalNotes = [
      '오늘도 목표했던 운동을 완수했습니다!',
      '점점 체력이 늘고 있는 것 같아요.',
      '힘들었지만 뿌듯한 운동이었습니다.',
      '스트레스가 많이 풀렸어요.',
      '꾸준히 하다 보니 습관이 되었네요.',
      '건강해지는 느낌이 좋습니다.',
    ];
    
    final specificNotes = [
      '새로운 기록을 달성했어요!',
      '컨디션이 정말 좋았습니다.',
      '운동 후 개운함이 최고네요.',
      '목표치를 넘어서 뿌듯해요.',
      '동료들과 함께해서 더 즐거웠어요.',
      '기술적으로 많이 발전한 것 같아요.',
      '날씨가 좋아서 운동하기 최적이었어요.',
      '집중력이 평소보다 좋았습니다.',
      '근력이 많이 늘었음을 느껴요.',
      '지구력 향상을 실감하고 있어요.',
    ];
    
    final allNotes = [...generalNotes, ...specificNotes];
    return allNotes[_random.nextInt(allNotes.length)];
  }

  /// 일기 내용 생성
  static String _generateDiaryContent() {
    final contents = [
      '오늘은 새로운 것을 배우는 하루였다. 조금씩이지만 성장하고 있다는 느낌이 든다.',
      '작은 목표들을 하나씩 달성해가는 재미가 있다. 꾸준함의 힘을 느낀다.',
      '사람들과의 소중한 만남이 있었다. 좋은 에너지를 많이 받았다.',
      '계획했던 일들을 차근차근 해나가고 있다. 체계적으로 생활하니 만족스럽다.',
      '힘든 하루였지만 그만큼 배운 것도 많다. 내일은 더 잘할 수 있을 것 같다.',
      '평범한 일상 속에서도 감사할 일들을 찾아보려 노력했다.',
      '새로운 도전을 시작했다. 설레기도 하고 두렵기도 하지만 해볼 만하다.',
      '꾸준히 해온 것들의 결과가 조금씩 보이기 시작한다. 뿌듯하다.',
    ];
    return contents[_random.nextInt(contents.length)];
  }

  /// 영화 로그 생성
  static MovieLog _generateMovieLog(DateTime date) {
    final movies = [
      {'title': '기생충', 'director': '봉준호', 'genre': '드라마'},
      {'title': '어벤져스: 엔드게임', 'director': '루소 형제', 'genre': '액션'},
      {'title': '인터스텔라', 'director': '크리스토퍼 놀란', 'genre': 'SF'},
      {'title': '라라랜드', 'director': '데미언 셔젤', 'genre': '로맨스'},
      {'title': '토이 스토리 4', 'director': '조시 쿨리', 'genre': '애니메이션'},
      {'title': '조커', 'director': '토드 필립스', 'genre': '스릴러'},
      {'title': '겨울왕국 2', 'director': '크리스 벅', 'genre': '애니메이션'},
      {'title': '1917', 'director': '샘 멘데스', 'genre': '드라마'},
    ];
    
    final movie = movies[_random.nextInt(movies.length)];
    final watchTime = 90 + _random.nextInt(60); // 90-150분
    
    return MovieLog(
      id: 'movie_${date.millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      date: date.subtract(Duration(hours: _random.nextInt(24))),
      movieTitle: movie['title']!,
      director: movie['director']!,
      genre: movie['genre']!,
      rating: 3.0 + (_random.nextDouble() * 2), // 3.0-5.0
      review: _generateMovieReview(),
      watchTimeMinutes: watchTime,
      isShared: _random.nextBool(),
    );
  }

  /// 영화 후기 생성
  static String _generateMovieReview() {
    final reviews = [
      '정말 인상 깊은 영화였습니다. 여운이 오래 남네요.',
      '배우들의 연기가 훌륭했어요. 몰입감이 대단했습니다.',
      '스토리가 탄탄하고 메시지가 명확한 좋은 작품이었어요.',
      '영상미가 정말 아름다웠습니다. 시각적 즐거움이 컸어요.',
      '생각해볼 거리를 많이 주는 의미 있는 영화였습니다.',
      '재미있게 봤어요. 시간 가는 줄 몰랐습니다.',
      '감동적인 스토리였어요. 마음이 따뜻해졌습니다.',
      '액션 시퀀스가 정말 박진감 넘쳤어요. 스릴 넘치는 영화!',
    ];
    return reviews[_random.nextInt(reviews.length)];
  }

  /// 책 제목에 따른 카테고리 반환
  static String _getBookCategory(String title) {
    if (title.contains('해빗') || title.contains('습관') || title.contains('인간관계')) {
      return '자기계발';
    } else if (title.contains('사피엔스')) {
      return '역사';
    } else if (title.contains('네트워크') || title.contains('코드') || title.contains('자바')) {
      return 'IT';
    } else if (title.contains('대화') || title.contains('기술')) {
      return '커뮤니케이션';
    } else {
      return '일반';
    }
  }

  /// 14일간 걸음수 데이터 생성 (기존 stepHistory Provider용)
  static List<DailyStepData> generate14DaysStepData() {
    final stepHistory = <DailyStepData>[];
    final now = DateTime.now();
    
    // 다양한 패턴의 걸음수 생성 (4000~15000 범위)
    final stepPatterns = [
      4200, 8800, 12200, 9100, 6500, 14900, 11500, // 첫째 주
      5800, 10500, 13200, 12100, 7200, 11800, 9900, // 둘째 주
    ];
    
    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      int steps;
      
      if (i == 0) {
        // 오늘은 현재 진행 중인 걸음수
        steps = _generateTodaySteps();
      } else {
        // 기존 패턴 사용하되 약간의 랜덤성 추가
        final baseSteps = stepPatterns[13 - i];
        final variation = _random.nextInt(2000) - 1000; // ±1000 변동
        steps = (baseSteps + variation).clamp(4000, 15000);
      }
      
      stepHistory.add(DailyStepData(
        date: date,
        steps: steps,
        goal: 6000,
      ));
    }
    
    return stepHistory;
  }
}
