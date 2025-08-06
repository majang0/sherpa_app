import '../models/quest_template_model.dart';
import '../models/quest_instance_model.dart';

/// 퀘스트 조건을 사용자 친화적인 텍스트로 변환하는 유틸리티
class QuestConditionFormatter {
  
  /// 퀘스트 추적 조건을 사용자 친화적인 텍스트로 변환
  static String formatTrackingCondition(QuestTrackingCondition condition) {
    // 먼저 description이 이미 자연어인지 확인하고 그대로 사용
    final description = condition.description;
    
    // 포맷팅 필요 여부 확인
    
    // 기술적인 표현이 포함된 경우만 변환
    if (_needsFormatting(description)) {
      // 타입별 처리보다는 description 자체를 우선적으로 포맷팅
      String formatted = _formatGenericDescription(description);
      
      // 여전히 기술적이라면 타입별 처리
      if (_needsFormatting(formatted)) {
        switch (condition.type) {
          case QuestTrackingType.appLaunch:
            formatted = '앱 실행 시 자동 완료';
            break;
            
          case QuestTrackingType.steps:
            final target = condition.parameters['target'] as int;
            formatted = '${_formatNumber(target)}보 걷기';
            break;
            
          case QuestTrackingType.tabVisit:
            final tab = condition.parameters['tab'] as String;
            formatted = '$tab 탭 방문하기';
            break;
            
          case QuestTrackingType.globalData:
            formatted = _formatGlobalDataCondition(condition);
            break;
            
          case QuestTrackingType.weeklyAccumulation:
            formatted = _formatWeeklyCondition(condition);
            break;
            
          case QuestTrackingType.multipleConditions:
            formatted = _formatMultipleConditions(condition);
            break;
            
          default:
            // formatted는 이미 _formatGenericDescription 결과
            break;
        }
      }
      
      return formatted;
    }
    
    return description;
  }

  /// 포맷팅이 필요한지 확인
  static bool _needsFormatting(String description) {
    final lowerDesc = description.toLowerCase();
    
    // 주간/이번 주 패턴 체크
    bool hasWeeklyPattern = (description.contains('이번 주') || description.contains('주간')) && 
                           (description.contains('달성') || description.contains('이상'));
    
    // 조건 달성 패턴 체크
    bool hasConditionPattern = description.contains('조건 달성:') ||
                              description.contains('>=') ||
                              description.contains('<=');
    
    // 기술적 용어들 체크 (대소문자 무시) - 기존 용어들
    bool hasBasicTechnicalTerms = lowerDesc.contains('movielog') ||
                                 lowerDesc.contains('movielogs') ||
                                 lowerDesc.contains('moviereview') ||
                                 lowerDesc.contains('meetinglog') ||
                                 lowerDesc.contains('meetinglogs') ||
                                 lowerDesc.contains('meetingreview') ||
                                 lowerDesc.contains('meetingreviews') ||
                                 lowerDesc.contains('readingpages') ||
                                 lowerDesc.contains('readinglog') ||
                                 lowerDesc.contains('readinglogs') ||
                                 lowerDesc.contains('exerciselog') ||
                                 lowerDesc.contains('exerciselogs') ||
                                 lowerDesc.contains('differentmountains') ||
                                 lowerDesc.contains('differentmeetingcategory') ||
                                 lowerDesc.contains('differentmeetingcategories') ||
                                 lowerDesc.contains('exerciseminutes') ||
                                 lowerDesc.contains('focusminutes') ||
                                 lowerDesc.contains('climbingcompletions') ||
                                 lowerDesc.contains('exerciserecords') ||
                                 lowerDesc.contains('readingrecords') ||
                                 lowerDesc.contains('diaryrecords') ||
                                 lowerDesc.contains('applaunches') ||
                                 lowerDesc.contains('pointsearned') ||
                                 lowerDesc.contains('badgeequipped') ||
                                 lowerDesc.contains('culturalrecords');
    
    // 프리미엄 퀘스트용 복합 조건 용어들 체크
    bool hasPremiumTechnicalTerms = lowerDesc.contains('consecutiveclimbingsuccess') ||
                                   lowerDesc.contains('consecutivedailyquestcompletion') ||
                                   lowerDesc.contains('meetinghostingwithparticipants') ||
                                   lowerDesc.contains('differentexercisetypes') ||
                                   lowerDesc.contains('differentmeetings') ||
                                   lowerDesc.contains('perfectdays') ||
                                   lowerDesc.contains('allactivitiesdays') ||
                                   lowerDesc.contains('challengerecords') ||
                                   lowerDesc.contains('30daychallengefirstweek') ||
                                   lowerDesc.contains('allcategoryquestscompleted') ||
                                   lowerDesc.contains('allweeklyquestscompleted') ||
                                   lowerDesc.contains('weeklyreadinpages') ||
                                   lowerDesc.contains('weeklymovielogs') ||
                                   lowerDesc.contains('weeklymeetingreviews') ||
                                   lowerDesc.contains('weeklydifferentmeetingcategories') ||
                                   lowerDesc.contains('weeklydifferentmountains');
    
    return hasWeeklyPattern || hasConditionPattern || hasBasicTechnicalTerms || hasPremiumTechnicalTerms;
  }

  /// 일반적인 description 포맷팅
  static String _formatGenericDescription(String description) {
    String formatted = description;
    
    // 0. 가장 직접적인 패턴 먼저 처리 ("주간 meetingLog 1 달성" 같은 케이스)
    formatted = _handleDirectPatterns(formatted);
    
    // 1. "이번 주 XXX 숫자 달성/이상" 패턴 처리
    if (formatted.contains('이번 주')) {
      formatted = _formatWeeklyPatterns(formatted);
    }
    
    // 2. "조건 달성:" 패턴 처리
    if (formatted.contains('조건 달성:')) {
      formatted = _formatConditionPatterns(formatted);
    }
    
    // 3. "복합 조건:" 패턴 처리
    if (formatted.contains('복합 조건:')) {
      formatted = _formatMultipleConditionPatterns(formatted);
    }
    
    // 4. 기타 기술적 용어들 변환
    formatted = _formatTechnicalTerms(formatted);
    
    return formatted;
  }
  
  /// 가장 직접적인 패턴들을 먼저 처리
  static String _handleDirectPatterns(String text) {
    String formatted = text;
    
    // 정확한 패턴 매칭으로 가장 문제가 되는 케이스들 처리
    final directMappings = [
      // "주간 [term] [number] 달성" 패턴 (단수형)
      {'pattern': RegExp(r'주간 meetingLog (\d+) 달성'), 'format': (String num) => '이번 주 모임 ${num}회 참여하기'},
      {'pattern': RegExp(r'주간 movieLog (\d+) 달성'), 'format': (String num) => '이번 주 영화 ${num}편 감상하기'},
      {'pattern': RegExp(r'주간 readingPages (\d+) 달성'), 'format': (String num) => '이번 주 총 ${num}페이지 읽기'},
      {'pattern': RegExp(r'주간 differentMountains (\d+) 달성'), 'format': (String num) => '이번 주 ${num}개 다른 산 등반하기'},
      {'pattern': RegExp(r'주간 differentMeetingCategory (\d+) 이상'), 'format': (String num) => '이번 주 ${num}가지 다른 모임 참여하기'},
      {'pattern': RegExp(r'주간 meetingReviews (\d+) 달성'), 'format': (String num) => '이번 주 모임 후기 ${num}개 작성하기'},
      
      // "주간 [term] [number] 달성" 패턴 (복수형) - 핵심 수정사항
      {'pattern': RegExp(r'주간 meetingLogs (\d+) 달성'), 'format': (String num) => '이번 주 모임 ${num}회 참여하기'},
      {'pattern': RegExp(r'주간 movieLogs (\d+) 달성'), 'format': (String num) => '이번 주 영화 ${num}편 감상하기'},
      {'pattern': RegExp(r'주간 readingLogs (\d+) 달성'), 'format': (String num) => '이번 주 독서 ${num}회 하기'},
      {'pattern': RegExp(r'주간 exerciseLogs (\d+) 달성'), 'format': (String num) => '이번 주 운동 ${num}회 하기'},
      
      // "이번 주 [term] [number] 달성" 패턴 (혹시 놓친 것들)
      {'pattern': RegExp(r'이번 주 meetingLog (\d+) 달성'), 'format': (String num) => '이번 주 모임 ${num}회 참여하기'},
      {'pattern': RegExp(r'이번 주 meetingLogs (\d+) 달성'), 'format': (String num) => '이번 주 모임 ${num}회 참여하기'},
      {'pattern': RegExp(r'이번 주 movieLog (\d+) 달성'), 'format': (String num) => '이번 주 영화 ${num}편 감상하기'},
      {'pattern': RegExp(r'이번 주 movieLogs (\d+) 달성'), 'format': (String num) => '이번 주 영화 ${num}편 감상하기'},
    ];
    
    for (final mapping in directMappings) {
      final pattern = mapping['pattern'] as RegExp;
      final formatter = mapping['format'] as String Function(String);
      
      formatted = formatted.replaceAllMapped(pattern, (match) {
        final number = match.group(1) ?? '1';
        return formatter(number);
      });
    }
    
    return formatted;
  }
  
  /// 주간 패턴 포맷팅
  static String _formatWeeklyPatterns(String text) {
    String formatted = text;
    
    // 패턴 1: "이번 주 [기술용어] [숫자] 달성"
    final weeklyPattern1 = RegExp(r'이번 주 (\w+) (\d+)\s*(달성|이상)');
    formatted = formatted.replaceAllMapped(weeklyPattern1, (match) {
      final term = match.group(1) ?? '';
      final number = match.group(2) ?? '0';
      return _convertWeeklyTerm(term, number);
    });
    
    // 패턴 2: "이번 주 [기술용어] [숫자]회 달성"  
    final weeklyPattern2 = RegExp(r'이번 주 (\w+) (\d+)회\s*(달성|이상)');
    formatted = formatted.replaceAllMapped(weeklyPattern2, (match) {
      final term = match.group(1) ?? '';
      final number = match.group(2) ?? '0';
      return _convertWeeklyTerm(term, number);
    });
    
    // 패턴 3: "주간 [기술용어] [숫자] 달성"
    final weeklyPattern3 = RegExp(r'주간 (\w+) (\d+)\s*(달성|이상)');
    formatted = formatted.replaceAllMapped(weeklyPattern3, (match) {
      final term = match.group(1) ?? '';
      final number = match.group(2) ?? '0';
      return _convertWeeklyTerm(term, number);
    });
    
    return formatted;
  }
  
  /// 주간 용어 변환 헬퍼 메서드
  static String _convertWeeklyTerm(String term, String number) {
    switch (term.toLowerCase()) {
      case 'readingpages':
        return '이번 주 총 ${number}페이지 읽기';
      case 'differentmeetingcategory':
      case 'differentmeetingcategories':
        return '이번 주 ${number}가지 다른 모임 참여하기';
      case 'differentmountains':
        return '이번 주 ${number}개 다른 산 등반하기';
      case 'movielogs':
        return '이번 주 영화 ${number}편 감상하기';
      case 'meetingreviews':
        return '이번 주 모임 후기 ${number}개 작성하기';
      case 'meetinglog':
      case 'meetinglogs':
        return number == '1' ? '이번 주 모임 참여하기' : '이번 주 모임 ${number}회 참여하기';
      case 'movielog':
      case 'movielogs':
        return number == '1' ? '이번 주 영화 감상하기' : '이번 주 영화 ${number}편 감상하기';
      case 'exerciseminutes':
        return '이번 주 총 ${number}분 운동하기';
      case 'focusminutes':
        return '이번 주 총 ${number}분 집중하기';
      case 'climbingcompletions':
        return '이번 주 ${number}번 등반 완료하기';
      case 'exerciserecords':
        return '이번 주 ${number}일 운동하기';
      case 'readingrecords':
        return '이번 주 ${number}일 독서하기';
      case 'diaryrecords':
        return '이번 주 ${number}일 일기 쓰기';
      case 'applaunches':
        return '이번 주 ${number}일 앱 사용하기';
      case 'pointsearned':
        return '이번 주 총 ${number}포인트 획득하기';
      case 'steps':
        return '이번 주 총 ${_formatNumber(int.parse(number))}보 걷기';
      
      // 프리미엄 퀘스트용 추가 용어들
      case 'culturalrecords':
        return '이번 주 문화 활동 ${number}회 기록하기';
      case 'challengerecords':
        return '이번 주 챌린지 ${number}회 참여하기';
      case 'consecutiveclimbingsuccess':
        return '${number}일 연속 등반 성공하기';
      case 'consecutivedailyquestcompletion':
        return '${number}일 연속 일일 퀘스트 완료하기';
      case 'meetinghostingwithparticipants':
        return '참여자가 있는 모임 ${number}회 주최하기';
      case 'differentexercisetypes':
        return '이번 주 ${number}가지 다른 운동하기';
      case 'differentmeetings':
        return '이번 주 ${number}개 다른 모임 참여하기';
      case 'perfectdays':
        return '${number}일간 완벽한 하루 만들기';
      case 'allactivitiesdays':
        return '${number}일간 모든 활동 완료하기';
      
      default:
        return '이번 주 ${term} ${number}회 달성';
    }
  }
  
  /// 조건 달성 패턴 포맷팅
  static String _formatConditionPatterns(String text) {
    String formatted = text;
    
    // "조건 달성: [Activity] >=[숫자]" 패턴을 정규식으로 처리
    final conditionPattern = RegExp(r'조건 달성:\s*(\w+)\s*(>=|<=|==)\s*(\d+)');
    
    formatted = formatted.replaceAllMapped(conditionPattern, (match) {
      final activity = match.group(1) ?? '';
      final operator = match.group(2) ?? '';
      final number = match.group(3) ?? '1';
      
      String operatorText;
      switch (operator) {
        case '>=':
          operatorText = '이상';
          break;
        case '<=':
          operatorText = '이하';
          break;
        case '==':
          operatorText = '정확히';
          break;
        default:
          operatorText = '이상';
      }
      
      String activityText;
      switch (activity) {
        case 'MovieLog':
          activityText = number == '1' ? '영화 감상하기' : '영화 ${number}편 감상하기';
          break;
        case 'MovieReview':
          activityText = number == '1' ? '영화 리뷰 작성하기' : '영화 리뷰 ${number}개 작성하기';
          break;
        case 'MeetingLog':
          activityText = number == '1' ? '모임 참여하기' : '모임 ${number}회 참여하기';
          break;
        case 'MeetingReview':
          activityText = number == '1' ? '모임 후기 작성하기' : '모임 후기 ${number}개 작성하기';
          break;
        case 'ReadingLog':
          activityText = number == '1' ? '독서하기' : '독서 ${number}회 하기';
          break;
        case 'ExerciseLog':
          activityText = number == '1' ? '운동하기' : '운동 ${number}회 하기';
          break;
        case 'DiaryLog':
          activityText = number == '1' ? '일기 쓰기' : '일기 ${number}회 쓰기';
          break;
        case 'FocusLog':
          activityText = number == '1' ? '집중하기' : '집중 ${number}회 하기';
          break;
        case 'ClimbingRecord':
          activityText = number == '1' ? '등반하기' : '등반 ${number}회 하기';
          break;
        default:
          activityText = '${activity} ${number}회';
      }
      
      return activityText;
    });
    
    // 남은 단순한 패턴들도 처리
    formatted = formatted
        .replaceAll('조건 달성: ', '')
        .replaceAll('MovieLog', '영화 감상')
        .replaceAll('MovieReview', '영화 리뷰 작성')
        .replaceAll('MeetingLog', '모임 참여')
        .replaceAll('MeetingReview', '모임 후기 작성')
        .replaceAll('ReadingLog', '독서')
        .replaceAll('ExerciseLog', '운동')
        .replaceAll('DiaryLog', '일기')
        .replaceAll('FocusLog', '집중')
        .replaceAll('ClimbingRecord', '등반');
    
    return formatted;
  }
  
  /// 기술적 용어들 변환
  static String _formatTechnicalTerms(String text) {
    String formatted = text;
    
    // 1단계: 주간/이번 주가 없는 기본 패턴 처리 ("주간 meetingLog 1 달성")
    final basicWeeklyPattern = RegExp(r'주간 (\w+) (\d+)\s*(달성|이상)');
    formatted = formatted.replaceAllMapped(basicWeeklyPattern, (match) {
      final term = match.group(1) ?? '';
      final number = match.group(2) ?? '0';
      return _convertWeeklyTerm(term, number);
    });
    
    // 2단계: 기술적 용어들을 대소문자 구분 없이 변환
    final techTermReplacements = [
      // 기본 활동 관련 용어들 (단수/복수 모두 처리)
      {'pattern': RegExp(r'\bmeetingLogs?\b', caseSensitive: false), 'replacement': '모임 참여'},
      {'pattern': RegExp(r'\bmovieLogs?\b', caseSensitive: false), 'replacement': '영화 감상'},
      {'pattern': RegExp(r'\bmeetingReviews?\b', caseSensitive: false), 'replacement': '모임 후기'},
      {'pattern': RegExp(r'\bmovieReviews?\b', caseSensitive: false), 'replacement': '영화 리뷰'},
      {'pattern': RegExp(r'\breadingLogs?\b', caseSensitive: false), 'replacement': '독서'},
      {'pattern': RegExp(r'\bexerciseLogs?\b', caseSensitive: false), 'replacement': '운동'},
      {'pattern': RegExp(r'\breadingPages\b', caseSensitive: false), 'replacement': '독서 페이지'},
      {'pattern': RegExp(r'\bdifferentMountains\b', caseSensitive: false), 'replacement': '다른 산'},
      {'pattern': RegExp(r'\bdifferentMeetingCategories?\b', caseSensitive: false), 'replacement': '다른 모임'},
      {'pattern': RegExp(r'\bexerciseMinutes\b', caseSensitive: false), 'replacement': '운동 시간'},
      {'pattern': RegExp(r'\bfocusMinutes\b', caseSensitive: false), 'replacement': '집중 시간'},
      {'pattern': RegExp(r'\bclimbingCompletions\b', caseSensitive: false), 'replacement': '등반 완료'},
      {'pattern': RegExp(r'\bexerciseRecords\b', caseSensitive: false), 'replacement': '운동 일수'},
      {'pattern': RegExp(r'\breadingRecords\b', caseSensitive: false), 'replacement': '독서 일수'},
      {'pattern': RegExp(r'\bdiaryRecords\b', caseSensitive: false), 'replacement': '일기 일수'},
      {'pattern': RegExp(r'\bappLaunches\b', caseSensitive: false), 'replacement': '앱 사용 일수'},
      {'pattern': RegExp(r'\bpointsEarned\b', caseSensitive: false), 'replacement': '포인트 획득'},
      {'pattern': RegExp(r'\bbadgeEquipped\b', caseSensitive: false), 'replacement': '뱃지 장착'},
      {'pattern': RegExp(r'\bculturalRecords\b', caseSensitive: false), 'replacement': '문화 활동'},
      
      // 프리미엄 퀘스트용 복합 조건 용어들
      {'pattern': RegExp(r'\b연속등반성공\b', caseSensitive: false), 'replacement': '연속 등반 성공'},
      {'pattern': RegExp(r'\b연속일일퀘스트완료\b', caseSensitive: false), 'replacement': '연속 일일 퀘스트 완료'},
      {'pattern': RegExp(r'\b모임주최성공\b', caseSensitive: false), 'replacement': '참여자가 있는 모임 주최'},
      {'pattern': RegExp(r'\bdifferentExerciseTypes\b', caseSensitive: false), 'replacement': '다른 운동 종류'},
      {'pattern': RegExp(r'\bdifferentMeetings\b', caseSensitive: false), 'replacement': '다른 모임'},
      {'pattern': RegExp(r'\bperfectDays\b', caseSensitive: false), 'replacement': '완벽한 하루'},
      {'pattern': RegExp(r'\ballActivitiesDays\b', caseSensitive: false), 'replacement': '모든 활동 완료일'},
      {'pattern': RegExp(r'\bchallengeRecords\b', caseSensitive: false), 'replacement': '챌린지 참여'},
      {'pattern': RegExp(r'\b30일챌린지첫주\b', caseSensitive: false), 'replacement': '30일 챌린지 첫 주 완료'},
      {'pattern': RegExp(r'\b모든카테고리퀘스트완료\b', caseSensitive: false), 'replacement': '모든 카테고리 퀘스트 완료'},
      {'pattern': RegExp(r'\b모든주간퀘스트완료\b', caseSensitive: false), 'replacement': '모든 주간 퀘스트 완료'},
      
      // 추가 패턴들
      {'pattern': RegExp(r'\bweeklyReadingPages\b', caseSensitive: false), 'replacement': '주간 독서 페이지'},
      {'pattern': RegExp(r'\bweeklyMovieLogs\b', caseSensitive: false), 'replacement': '주간 영화 감상'},
      {'pattern': RegExp(r'\bweeklyMeetingReviews\b', caseSensitive: false), 'replacement': '주간 모임 후기'},
      {'pattern': RegExp(r'\bweeklyDifferentMeetingCategories\b', caseSensitive: false), 'replacement': '주간 다른 모임 카테고리'},
      {'pattern': RegExp(r'\bweeklyDifferentMountains\b', caseSensitive: false), 'replacement': '주간 다른 산'},
    ];
    
    for (final replacement in techTermReplacements) {
      formatted = formatted.replaceAll(replacement['pattern'] as RegExp, replacement['replacement'] as String);
    }
    
    // 3단계: 남은 단순한 패턴들
    final simpleReplacements = {
      'ReadingLog': '독서',
      'ExerciseLog': '운동', 
      'DiaryLog': '일기',
      'FocusLog': '집중',
      'ClimbingRecord': '등반',
    };
    
    for (final entry in simpleReplacements.entries) {
      formatted = formatted.replaceAll(RegExp(entry.key, caseSensitive: false), entry.value);
    }
    
    return formatted;
  }
  
  /// 복합 조건 패턴 포맷팅 ("복합 조건: key:value, key:value" 형태)
  static String _formatMultipleConditionPatterns(String text) {
    String formatted = text;
    
    // "복합 조건: " 제거
    formatted = formatted.replaceAll('복합 조건: ', '');
    
    // 각 조건들을 분리하여 처리
    final conditions = formatted.split(', ');
    final formattedConditions = conditions.map((condition) {
      final parts = condition.split(':');
      if (parts.length != 2) return condition;
      
      final key = parts[0].trim();
      final value = parts[1].trim();
      
      switch (key) {
        case 'readingPages':
          return '${_formatNumber(int.tryParse(value) ?? 0)}페이지 읽기';
        case 'movieLogs':
          return '영화 ${value}편 감상하기';
        case 'exerciseMinutes':
          return '${value}분 운동하기';
        case 'differentExerciseTypes':
          return '${value}가지 다른 운동하기';
        case 'differentMountains':
          return '${value}개 다른 산 등반하기';
        case 'differentMeetingCategories':
          return '${value}가지 다른 모임 참여하기';
        case '연속등반성공':
          return '${value}일 연속 등반 성공하기';
        case '연속일일퀘스트완료':
          return '${value}일 연속 일일 퀘스트 완료하기';
        case 'perfectDays':
          return '${value}일간 완벽한 하루 만들기';
        case 'allActivitiesDays':
          return '${value}일간 모든 활동 완료하기';
        case 'challengeRecords':
          return '챌린지 ${value}회 참여하기';
        case 'differentMeetings':
          return '${value}개 다른 모임 참여하기';
        case '모임주최성공':
          return '참여자가 있는 모임 ${value}회 주최하기';
        case 'culturalRecords':
          return '문화 활동 ${value}회 기록하기';
        case 'meetingLogs':
          return '모임 ${value}회 참여하기';
        case 'focusMinutes':
          return '${value}분 집중하기';
        case 'steps':
          return '${_formatNumber(int.tryParse(value) ?? 0)}보 걷기';
        default:
          return '${key} ${value}회 달성';
      }
    }).toList();
    
    // 조건들을 자연스럽게 연결
    if (formattedConditions.length == 1) {
      return formattedConditions.first;
    } else if (formattedConditions.length == 2) {
      return '${formattedConditions[0]}와 ${formattedConditions[1]}';
    } else {
      final last = formattedConditions.removeLast();
      return '${formattedConditions.join(', ')}와 $last';
    }
  }
  
  /// 글로벌 데이터 조건 포맷팅
  static String _formatGlobalDataCondition(QuestTrackingCondition condition) {
    final path = condition.parameters['path'] as String;
    final target = condition.parameters['target'];
    
    switch (path) {
      case 'dailyRecords.todaySteps':
        return '오늘 ${_formatNumber(target)}보 걷기';
      case 'dailyRecords.todayFocusMinutes':
        return '오늘 ${target}분 집중하기';
      case 'dailyRecords.todayExerciseMinutes':
        return '오늘 ${target}분 운동하기';
      case 'allDailyActivitiesCompleted':
        return '모든 일일 활동 완료하기';
      case 'dailyGoals.exercise.completed':
        return '운동 목표 달성하기';
      case 'dailyGoals.reading.completed':
        return '독서 목표 달성하기';
      case 'dailyGoals.diary.completed':
        return '일기 목표 달성하기';
      case 'dailyGoals.focus.completed':
        return '집중 목표 달성하기';
      case 'ClimbingRecord.isSuccess':
        return '등반 성공하기';
      case 'ReadingLog.pages':
        return '${target}페이지 읽기';
      case 'dailyPointsEarned':
        return '하루에 ${target}포인트 획득하기';
      case 'badgeEquipped':
        return '뱃지 장착하기';
      case 'MovieLog':
        return target == 1 ? '영화 감상하기' : '영화 ${target}편 감상하기';
      case 'MovieReview':
        return target == 1 ? '영화 리뷰 작성하기' : '영화 리뷰 ${target}개 작성하기';
      case 'MeetingReview':
        return target == 1 ? '모임 후기 작성하기' : '모임 후기 ${target}개 작성하기';
      case 'MeetingLog':
        return target == 1 ? '모임 참여하기' : '모임 ${target}회 참여하기';
      case 'readingPages':
        return '총 ${target}페이지 읽기';
      case 'movieLogs':
        return '영화 ${target}편 감상하기';
      case 'culturalRecords':
        return '문화 활동 ${target}회 기록하기';
      case 'meetingReviews':
        return '모임 후기 ${target}개 작성하기';
      case 'differentMeetingCategories':
        return '${target}가지 다른 모임 참여하기';
      case 'differentMountains':
        return '${target}개 다른 산 등반하기';
      
      // 추가 globalData 경로들
      case 'exerciseMinutes':
        return '${target}분 운동하기';
      case 'focusMinutes':
        return '${target}분 집중하기';
      case 'steps':
        return '${_formatNumber(target)}보 걷기';
      case 'meetingLogs':
        return target == 1 ? '모임 참여하기' : '모임 ${target}회 참여하기';
      case '연속등반성공':
        return '${target}일 연속 등반 성공하기';
      case '연속일일퀘스트완료':
        return '${target}일 연속 일일 퀘스트 완료하기';
      case '모임주최성공':
        return '참여자가 있는 모임 ${target}회 주최하기';
      case 'differentExerciseTypes':
        return '${target}가지 다른 운동하기';
      case 'perfectDays':
        return '${target}일간 완벽한 하루 만들기';
      case 'allActivitiesDays':
        return '${target}일간 모든 활동 완료하기';
      case 'challengeRecords':
        return '챌린지 ${target}회 참여하기';
      case 'differentMeetings':
        return '${target}개 다른 모임 참여하기';
      case '30일챌린지첫주':
        return '30일 챌린지 첫 주 완료하기';
      case '모든카테고리퀘스트완료':
        return '모든 카테고리 퀘스트 완료하기';
      case '모든주간퀘스트완료':
        return '모든 주간 퀘스트 완료하기';
      
      default:
        // 기본적으로 "조건 달성:" 형태를 자연어로 변환
        if (condition.description.contains('조건 달성:')) {
          final cleanDesc = condition.description
              .replaceAll('조건 달성: ', '')
              .replaceAll(' >=', ' 이상')
              .replaceAll(' <=', ' 이하')
              .replaceAll(' ==', ' 정확히')
              .replaceAll('true', '성공')
              .replaceAll('false', '실패');
          
          // 기술적 용어들을 자연어로 변환
          String naturalDesc = cleanDesc;
          naturalDesc = naturalDesc.replaceAll('MovieLog', '영화 감상');
          naturalDesc = naturalDesc.replaceAll('MovieReview', '영화 리뷰 작성');
          naturalDesc = naturalDesc.replaceAll('MeetingReview', '모임 후기 작성');
          naturalDesc = naturalDesc.replaceAll('MeetingLog', '모임 참여');
          naturalDesc = naturalDesc.replaceAll('ClimbingRecord.isSuccess', '등반 성공');
          naturalDesc = naturalDesc.replaceAll('ReadingLog.pages', '독서 페이지');
          naturalDesc = naturalDesc.replaceAll('dailyRecords.todayFocusMinutes', '오늘 집중 시간');
          naturalDesc = naturalDesc.replaceAll('dailyRecords.todaySteps', '오늘 걸음수');
          naturalDesc = naturalDesc.replaceAll('dailyRecords.todayExerciseMinutes', '오늘 운동 시간');
          naturalDesc = naturalDesc.replaceAll('allDailyActivitiesCompleted', '모든 일일 활동 완료');
          naturalDesc = naturalDesc.replaceAll('dailyPointsEarned', '오늘 포인트 획득');
          naturalDesc = naturalDesc.replaceAll('badgeEquipped', '뱃지 장착');
          naturalDesc = naturalDesc.replaceAll('culturalRecords', '문화 활동');
          
          return naturalDesc;
        }
        return condition.description;
    }
  }
  
  /// 주간 누적 조건 포맷팅
  static String _formatWeeklyCondition(QuestTrackingCondition condition) {
    final dataType = condition.parameters['dataType'] as String;
    final target = condition.parameters['target'];
    
    switch (dataType) {
      case 'steps':
        return '이번 주 총 ${_formatNumber(target)}보 걷기';
      case 'focusMinutes':
        return '이번 주 총 ${target}분 집중하기';
      case 'exerciseRecords':
        return '이번 주 ${target}일 운동하기';
      case 'readingRecords':
        return '이번 주 ${target}일 독서하기';
      case 'readingPages':
        return '이번 주 총 ${target}페이지 읽기';
      case 'diaryRecords':
        return '이번 주 ${target}일 일기 쓰기';
      case 'appLaunches':
        return '이번 주 ${target}일 앱 사용하기';
      case 'climbingCompletions':
        return '이번 주 ${target}번 등반 완료하기';
      case 'pointsEarned':
        return '이번 주 총 ${target}포인트 획득하기';
      case 'differentMeetingCategories':
        return '이번 주 ${target}가지 다른 모임 참여하기';
      case 'differentMountains':
        return '이번 주 ${target}개 다른 산 등반하기';
      case 'movieLogs':
        return '이번 주 영화 ${target}편 감상하기';
      case 'movieReviews':
        return '이번 주 영화 리뷰 ${target}개 작성하기';
      
      // 프리미엄 퀘스트용 추가 케이스들
      case 'meetingLogs':
        return '이번 주 모임 ${target}회 참여하기';
      case 'culturalRecords':
        return '이번 주 문화 활동 ${target}회 기록하기';
      case 'challengeRecords':
        return '이번 주 챌린지 ${target}회 참여하기';
      case 'exerciseMinutes':
        return '이번 주 총 ${target}분 운동하기';
      case 'differentExerciseTypes':
        return '이번 주 ${target}가지 다른 운동하기';
      case 'differentMeetings':
        return '이번 주 ${target}개 다른 모임 참여하기';
      case 'meetingReviews':
        return '이번 주 모임 후기 ${target}개 작성하기';
      
      default:
        return '이번 주 ${dataType} ${target}회 달성';
    }
  }
  
  /// 복합 조건 포맷팅
  static String _formatMultipleConditions(QuestTrackingCondition condition) {
    final conditions = condition.parameters['conditions'] as List<String>;
    final formattedConditions = conditions.map((cond) {
      final parts = cond.split(':');
      if (parts.length != 2) return cond;
      
      final key = parts[0];
      final value = int.tryParse(parts[1]) ?? 0;
      
      switch (key) {
        case 'readingPages':
          return '${_formatNumber(value)}페이지 읽기';
        case 'movieLogs':
          return '영화 ${value}편 감상하기';
        case 'exerciseMinutes':
          return '${value}분 운동하기';
        case 'differentExerciseTypes':
          return '${value}가지 다른 운동하기';
        case 'differentMountains':
          return '${value}개 다른 산 등반하기';
        case 'differentMeetingCategories':
          return '${value}가지 다른 모임 참여하기';
        case '연속등반성공':
          return '${value}일 연속 등반 성공하기';
        case '연속일일퀘스트완료':
          return '${value}일 연속 일일 퀘스트 완료하기';
        case 'perfectDays':
          return '${value}일간 완벽한 하루 만들기';
        case 'allActivitiesDays':
          return '${value}일간 모든 활동 완료하기';
        case 'challengeRecords':
          return '챌린지 ${value}회 참여하기';
        case 'differentMeetings':
          return '${value}개 다른 모임 참여하기';
        case '모임주최성공':
          return '참여자가 있는 모임 ${value}회 주최하기';
        case '30일챌린지첫주':
          return '30일 챌린지 첫 주 완료하기';
        case '모든카테고리퀘스트완료':
          return '모든 카테고리 퀘스트 완료하기';
        case '모든주간퀘스트완료':
          return '모든 주간 퀘스트 완료하기';
        case 'weeklyReadingPages':
          return '이번 주 ${_formatNumber(value)}페이지 읽기';
        case 'weeklyMovieLogs':
          return '이번 주 영화 ${value}편 감상하기';
        case 'weeklyMeetingReviews':
          return '이번 주 모임 후기 ${value}개 작성하기';
        case 'weeklyDifferentMeetingCategories':
          return '이번 주 ${value}가지 다른 모임 참여하기';
        case 'weeklyDifferentMountains':
          return '이번 주 ${value}개 다른 산 등반하기';
        
        // 프리미엄 퀘스트 복합 조건들
        case '연속등반성공':
          return '${value}일 연속 등반 성공하기';
        case '연속일일퀘스트완료':
          return '${value}일 연속 일일 퀘스트 완료하기';
        case '모임주최성공':
          return '참여자가 있는 모임 ${value}회 주최하기';
        case 'differentExerciseTypes':
          return '${value}가지 다른 운동하기';
        case 'perfectDays':
          return '${value}일간 완벽한 하루 만들기';
        case 'allActivitiesDays':
          return '${value}일간 모든 활동 완료하기';
        case 'challengeRecords':
          return '챌린지 ${value}회 참여하기';
        case 'culturalRecords':
          return '문화 활동 ${value}회 기록하기';
        case 'differentMeetings':
          return '${value}개 다른 모임 참여하기';
        case '30일챌린지첫주':
          return '30일 챌린지 첫 주 완료하기';
        case '모든카테고리퀘스트완료':
          return '모든 카테고리 퀘스트 완료하기';
        case '모든주간퀘스트완료':
          return '모든 주간 퀘스트 완료하기';
        case 'weeklyMeetingLogs':
          return '이번 주 모임 ${value}회 참여하기';
        case 'weeklyCulturalRecords':
          return '이번 주 문화 활동 ${value}회 기록하기';
        
        default:
          return '$key ${value}회 달성하기';
      }
    }).toList();
    
    if (formattedConditions.length == 1) {
      return formattedConditions.first;
    } else if (formattedConditions.length == 2) {
      return '${formattedConditions[0]}와 ${formattedConditions[1]}';
    } else {
      final last = formattedConditions.removeLast();
      return '${formattedConditions.join(', ')}와 $last';
    }
  }
  
  /// 숫자를 천 단위로 포맷팅
  static String _formatNumber(dynamic number) {
    if (number == null) return '0';
    
    final num = number is String ? int.tryParse(number) ?? 0 : number as int;
    
    if (num >= 10000) {
      if (num % 10000 == 0) {
        return '${num ~/ 10000}만';
      } else if (num % 1000 == 0) {
        return '${num ~/ 1000}천';
      }
    } else if (num >= 1000) {
      if (num % 1000 == 0) {
        return '${num ~/ 1000}천';
      }
    }
    
    // 천 단위 콤마 추가
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
  
  /// 진행률 텍스트 생성
  static String formatProgress(QuestInstance quest) {
    if (quest.targetProgress == 1) {
      return quest.status == QuestStatus.completed || quest.status == QuestStatus.claimed 
          ? '완료' 
          : '진행 중';
    }
    
    return '${quest.currentProgress} / ${quest.targetProgress}';
  }
  
  /// 퀘스트 상태에 따른 설명 텍스트
  static String getStatusDescription(QuestInstance quest) {
    switch (quest.status) {
      case QuestStatus.notStarted:
        return '조건을 만족하면 자동으로 시작됩니다';
      case QuestStatus.inProgress:
        if (quest.canComplete) {
          return '완료 조건을 달성했습니다!';
        } else {
          return '진행 중입니다';
        }
      case QuestStatus.completed:
        return '보상을 받을 수 있습니다';
      case QuestStatus.claimed:
        return '완료되었습니다';
      default:
        return '';
    }
  }
}