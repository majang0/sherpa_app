/// 🎯 활동 분석 프롬프트 템플릿
/// 
/// 운동, 독서, 일기 활동에 대한 구체적이고 감성적인 분석 프롬프트를 생성합니다.
/// 셰르피의 따뜻하고 친근한 성격을 반영하여 사용자에게 힘이 되는 메시지를 전달합니다.
class AnalysisPromptTemplates {
  
  /// 🏃 운동 분석 프롬프트 생성
  static String generateExerciseAnalysisPrompt({
    required Map<String, dynamic> todayExercise,
    Map<String, dynamic>? previousExercise,
    required String userName,
  }) {
    // 오늘 운동 데이터 추출
    final exerciseType = todayExercise['type'] ?? '운동';
    final intensity = todayExercise['intensity'] ?? '보통';
    final duration = todayExercise['duration'] ?? 0;
    final calories = todayExercise['calories'] ?? 0;
    final steps = todayExercise['steps'] ?? 0;
    
    // 이전 운동 데이터 추출 (있는 경우)
    String previousContext = '';
    if (previousExercise != null) {
      final prevType = previousExercise['type'] ?? '';
      final prevCalories = previousExercise['calories'] ?? 0;
      final prevDuration = previousExercise['duration'] ?? 0;
      
      previousContext = '''
이전 운동 정보:
- 운동 종류: $prevType
- 소모 칼로리: ${prevCalories}kcal
- 운동 시간: ${prevDuration}분

오늘과 이전 운동을 비교해서:
- 칼로리가 더 많이 소모되었다면 칭찬과 격려
- 칼로리가 적게 소모되었다면 따뜻한 위로와 응원
- 운동 종류가 바뀌었다면 새로운 도전에 대한 격려
''';
    }
    
    return '''$userName님의 오늘 운동 활동을 분석해주세요.

오늘 운동 정보:
- 운동 종류: $exerciseType
- 운동 강도: $intensity
- 운동 시간: ${duration}분
- 소모 칼로리: ${calories}kcal
${steps > 0 ? '- 걸음 수: $steps보' : ''}

$previousContext

분석 지침:
1. 운동 종류, 강도, 시간을 구체적으로 언급하며 시작
2. 소모 칼로리를 강조하며 성취감 부여
3. 이전 운동과 비교 (데이터가 있는 경우):
   - 칼로리 소모가 증가했다면: "와! 지난번보다 XXkcal 더 소모하셨네요! 정말 대단해요!"
   - 칼로리 소모가 감소했다면: "지난번보다 조금 적게 소모하셨지만, 꾸준함이 더 중요해요! 운동은 급할수록 천천히!"
4. 운동의 긍정적 효과 언급 (건강, 활력, 스트레스 해소 등)
5. 따뜻한 격려와 응원으로 마무리
6. 적절한 이모지 사용 (💪, 🏃, 🔥, ⚡, 🎯 등)

톤: 친근하고 격려하는 친구처럼, 구체적인 데이터를 언급하며 개인화된 피드백
길이: 4-5문장''';
  }
  
  /// 📚 독서 분석 프롬프트 생성
  static String generateReadingAnalysisPrompt({
    required Map<String, dynamic> todayReading,
    Map<String, dynamic>? previousReading,
    required String userName,
  }) {
    // 오늘 독서 데이터 추출
    final bookTitle = todayReading['title'] ?? '책';
    final category = todayReading['category'] ?? '일반';
    final pagesRead = todayReading['pages'] ?? 0;
    final totalPages = todayReading['totalPages'] ?? 0;
    final rating = todayReading['rating'] ?? 0;
    
    // 카테고리별 맞춤 메시지
    final categoryInsights = _getCategoryInsight(category);
    
    // 이전 독서 데이터 추출 (있는 경우)
    String previousContext = '';
    if (previousReading != null) {
      final prevCategory = previousReading['category'] ?? '';
      final prevTitle = previousReading['title'] ?? '';
      final prevCategoryInsight = _getCategoryInsight(prevCategory);
      
      previousContext = '''
이전 독서 정보:
- 책 제목: $prevTitle  
- 카테고리: $prevCategory

지난번 읽은 $prevCategory 책과 관련해서:
$prevCategoryInsight
자연스럽게 이전 독서 경험을 언급하며 연결해주세요.
''';
    }
    
    return '''$userName님의 오늘 독서 활동을 분석해주세요.

오늘 독서 정보:
- 책 제목: 『$bookTitle』
- 카테고리: $category
- 읽은 페이지: ${pagesRead}페이지
${totalPages > 0 ? '- 전체 페이지: ${totalPages}페이지' : ''}
${rating > 0 ? '- 평점: ${rating}점' : ''}

오늘 읽은 책 카테고리 ($category)와 관련된 통찰:
$categoryInsights

$previousContext

분석 지침:
1. 책 제목과 읽은 페이지를 구체적으로 언급하며 시작
2. 카테고리와 관련된 지식 습득의 가치 강조
3. 이전 독서와 연결 (데이터가 있는 경우):
   - "지난번에는 $prevCategory 책을 읽으셨는데, 어떠셨나요?"
   - 이전 카테고리와 관련된 실생활 적용이나 감상 물어보기
4. 독서의 긍정적 효과 언급 (지식 확장, 사고력 향상, 정서적 안정 등)
5. 부담 없고 친근한 격려로 마무리
6. 적절한 이모지 사용 (📚, 📖, 🌟, 💡, 🎯 등)

톤: 지적 호기심을 자극하면서도 부담스럽지 않은 친구처럼
길이: 4-5문장''';
  }
  
  /// 📝 일기 분석 프롬프트 생성
  static String generateDiaryAnalysisPrompt({
    required Map<String, dynamic> todayDiary,
    Map<String, dynamic>? previousDiary,
    required String userName,
  }) {
    // 오늘 일기 데이터 추출
    final mood = todayDiary['mood'] ?? '평온한';
    final moodEmoji = todayDiary['moodEmoji'] ?? '';
    final content = todayDiary['content'] ?? '';
    final keywords = todayDiary['keywords'] ?? [];
    
    // 감정별 맞춤 응답
    final moodResponse = _getMoodResponse(mood);
    
    // 이전 일기 데이터 추출 (있는 경우)
    String previousContext = '';
    if (previousDiary != null) {
      final prevMood = previousDiary['mood'] ?? '';
      final prevMoodEmoji = previousDiary['moodEmoji'] ?? '';
      
      previousContext = '''
이전 일기 정보:
- 감정: $prevMood $prevMoodEmoji

감정 변화에 대한 자연스러운 연결:
- 이전 감정($prevMood)과 오늘 감정($mood)을 비교
- 감정이 좋아졌다면 축하와 기쁨 표현
- 감정이 나빠졌다면 따뜻한 위로와 공감
- 비슷한 감정이라면 꾸준함에 대한 격려
''';
    }
    
    return '''$userName님의 오늘 일기와 감정을 분석해주세요.

오늘 일기 정보:
- 감정 상태: $mood $moodEmoji
- 주요 키워드: ${keywords.isNotEmpty ? keywords.join(', ') : '일상, 성장'}
${content.isNotEmpty ? '- 일기 내용 요약: ${content.length > 100 ? content.substring(0, 100) : content}' : ''}

감정별 맞춤 응답 가이드:
$moodResponse

$previousContext

분석 지침:
1. $userName님의 이름을 부르며 오늘 감정 상태 언급
2. 감정에 깊이 공감하는 메시지 전달
3. 이전 감정과 비교 (데이터가 있는 경우):
   - "지난번엔 $prevMood 감정이셨는데, 오늘은 $mood이시군요!"
   - 감정 변화에 대한 자연스러운 코멘트
4. 일기 쓰기 습관의 가치 강조 (자기 성찰, 감정 정리, 성장 기록)
5. 셰르피가 늘 곁에 있다는 따뜻한 메시지로 마무리
6. 적절한 이모지 사용 (💝, 🤗, 🌈, ✨, 🌸 등)

톤: 깊이 공감하고 따뜻하게 위로하는 가장 친한 친구처럼
길이: 4-5문장''';
  }
  
  /// 🌟 종합 요약 분석 프롬프트 생성
  static String generateSummaryAnalysisPrompt({
    required Map<String, dynamic> todayExercise,
    required Map<String, dynamic> todayReading,
    required Map<String, dynamic> todayDiary,
    required String userName,
  }) {
    // 각 활동 데이터 추출
    final exerciseType = todayExercise['type'] ?? '운동';
    final exerciseDuration = todayExercise['duration'] ?? 0;
    final exerciseCalories = todayExercise['calories'] ?? 0;
    
    final bookCategory = todayReading['category'] ?? '독서';
    final pagesRead = todayReading['pages'] ?? 0;
    final bookTitle = todayReading['title'] ?? '';
    
    final mood = todayDiary['mood'] ?? '평온한';
    final moodEmoji = todayDiary['moodEmoji'] ?? '';
    
    // 활동 간 시너지 찾기
    final synergy = _findActivitySynergy(exerciseType, bookCategory, mood);
    
    return '''$userName님의 오늘 하루 전체 활동을 종합적으로 분석하고 깊이 있는 통찰을 제공해주세요.

오늘의 활동 요약:
🏃 운동: $exerciseType ${exerciseDuration}분 (${exerciseCalories}kcal 소모)
📚 독서: 『$bookTitle』 ($bookCategory) ${pagesRead}페이지
📝 일기: $mood 감정 $moodEmoji

활동 간 시너지와 연관성:
$synergy

분석 지침:
1. 세 가지 활동을 하나의 스토리로 연결
   예시: "오늘 $exerciseType을(를) ${exerciseDuration}분, $bookCategory 책을 ${pagesRead}페이지, 그리고 '$mood' 감정을 기록하셨네요."

2. 각 활동이 서로에게 미치는 긍정적 영향 분석:
   - 운동이 독서 집중력에 미치는 영향
   - 독서가 감정 상태에 미치는 영향
   - 감정이 운동 의욕에 미치는 영향

3. 활동들의 깊은 의미와 가치 부여:
   - "$exerciseType을 하며 다져진 [구체적 가치: 끈기, 도전정신, 건강 등]"
   - "$bookCategory 책을 읽으며 쌓은 [구체적 가치: 지혜, 통찰, 교양 등]"
   - "$mood 감정이 주는 [구체적 가치: 자기이해, 성찰, 성장 등]"

4. 미래 지향적 메시지:
   - 오늘의 활동이 내일에 미칠 긍정적 영향
   - 지속적인 성장에 대한 기대와 응원

5. 셰르피의 진심 어린 감동과 응원:
   - "$userName님과 함께하는 것에 대한 기쁨"
   - "앞으로도 늘 곁에서 응원하겠다"는 약속

6. 풍부한 이모지로 감정 표현 (🌟, 💪, 📚, 💝, 🎯, ✨ 등)

톤: 깊이 있고 통찰력 있으면서도 따뜻하고 감동적인 멘토이자 친구처럼
길이: 5-7문장 (종합 분석이므로 조금 더 길게)''';
  }
  
  /// 카테고리별 통찰 메시지
  static String _getCategoryInsight(String category) {
    final insights = {
      '심리학': '사람의 마음을 이해하는 것은 자신과 타인을 더 깊이 이해하는 첫걸음이에요. 오늘 읽은 내용이 일상에서 사람들과의 관계를 더 풍요롭게 만들어줄 거예요.',
      '인문학': '인문학은 삶의 본질을 탐구하는 학문이에요. 오늘 읽은 내용이 삶을 바라보는 새로운 관점을 선물해줄 거예요.',
      '자기계발': '더 나은 자신을 만들어가는 여정이 멋져요! 오늘 읽은 내용을 하나씩 실천해보면 놀라운 변화를 경험하실 거예요.',
      '소설': '상상력의 세계로 떠나는 여행은 언제나 특별해요. 주인공의 이야기가 어떤 감동과 영감을 주었나요?',
      '과학': '세상의 원리를 탐구하는 호기심이 대단해요! 과학적 사고가 일상의 문제 해결에도 큰 도움이 될 거예요.',
      '역사': '과거를 통해 현재를 이해하고 미래를 준비하는 지혜를 얻으셨네요. 역사의 교훈이 오늘을 살아가는 힘이 되길 바라요.',
      '경제/경영': '경제적 사고와 경영 마인드는 삶을 더 풍요롭게 만들어줘요. 오늘 배운 내용이 실제 의사결정에 도움이 되길 바라요.',
      '예술': '예술은 삶을 더 아름답고 풍성하게 만들어줘요. 오늘 읽은 내용이 일상에서 아름다움을 발견하는 눈을 선물해줄 거예요.',
      '철학': '삶의 의미를 탐구하는 철학적 사고가 인상적이에요. 깊은 사유가 더 단단한 내면을 만들어줄 거예요.',
      'IT/기술': '기술의 발전을 이해하는 것은 미래를 준비하는 일이에요. 오늘 배운 지식이 디지털 시대를 살아가는 힘이 될 거예요.',
    };
    
    return insights[category] ?? '새로운 지식을 탐구하는 모습이 정말 멋져요. 꾸준한 독서가 더 넓은 세상을 보는 창이 되어줄 거예요.';
  }
  
  /// 감정별 응답 가이드
  static String _getMoodResponse(String mood) {
    final responses = {
      '행복해요': '행복한 하루를 보내셨다니 정말 기뻐요! 그 긍정적인 에너지가 주변까지 밝게 만들 거예요.',
      '기뻐요': '기쁜 일이 있으셨군요! 그 기쁨을 마음껏 누리세요. 좋은 일들이 계속 이어지길 바라요.',
      '설레요': '설레는 마음은 새로운 시작의 신호예요! 그 설렘이 멋진 결과로 이어지길 응원해요.',
      '평온해요': '평온한 마음 상태가 참 좋아 보여요. 이런 안정감이 든든한 기반이 되어줄 거예요.',
      '보통이에요': '무난한 하루도 충분히 의미 있어요. 평범한 일상 속에서도 작은 행복을 찾아보세요.',
      '피곤해요': '피곤한 하루였군요. 충분한 휴식을 취하시고, 내일은 더 활력 넘치는 하루가 되길 바라요.',
      '우울해요': '우울한 감정도 자연스러운 거예요. 이런 날도 있는 거죠. 셰르피가 곁에서 따뜻하게 응원할게요.',
      '불안해요': '불안한 마음이 드시는군요. 깊은 숨을 쉬고, 한 걸음씩 나아가면 괜찮을 거예요.',
      '화나요': '화가 나는 일이 있으셨군요. 그 감정을 인정하고 표현하는 것도 중요해요. 곧 마음이 편안해지길 바라요.',
      '스트레스받아요': '스트레스가 많으신가 봐요. 잠시 쉬어가도 괜찮아요. 당신의 건강이 가장 중요해요.',
    };
    
    return responses[mood] ?? '오늘의 감정을 기록해주셔서 감사해요. 어떤 감정이든 소중한 당신의 일부예요.';
  }
  
  /// 활동 간 시너지 분석
  static String _findActivitySynergy(String exerciseType, String bookCategory, String mood) {
    // 운동과 기분의 관계
    String exerciseMoodSynergy = '';
    if (mood.contains('행복') || mood.contains('기쁨') || mood.contains('설레')) {
      exerciseMoodSynergy = '운동으로 인한 엔돌핀이 긍정적인 감정을 더욱 증폭시켰을 거예요.';
    } else if (mood.contains('피곤') || mood.contains('스트레스')) {
      exerciseMoodSynergy = '운동이 스트레스 해소에 도움이 되었을 거예요.';
    } else {
      exerciseMoodSynergy = '운동이 감정 조절에 긍정적인 영향을 주었을 거예요.';
    }
    
    // 독서와 기분의 관계
    String readingMoodSynergy = '';
    if (bookCategory == '자기계발' && mood.contains('설레')) {
      readingMoodSynergy = '자기계발서가 새로운 도전에 대한 설렘을 더해주었네요.';
    } else if (bookCategory == '소설' && (mood.contains('평온') || mood.contains('행복'))) {
      readingMoodSynergy = '소설 속 이야기가 마음에 평화와 즐거움을 선물했네요.';
    } else if (bookCategory == '심리학' && mood.contains('우울')) {
      readingMoodSynergy = '심리학 책이 자신의 감정을 이해하는 데 도움이 되었을 거예요.';
    } else {
      readingMoodSynergy = '독서가 감정을 차분하게 정리하는 시간이 되었을 거예요.';
    }
    
    return '''
- $exerciseMoodSynergy
- $readingMoodSynergy
- 운동, 독서, 감정 기록이 조화롭게 어우러져 균형잡힌 하루를 만들었어요.
- 몸(운동), 마음(독서), 감정(일기)을 모두 돌보는 통합적인 자기 관리가 인상적이에요.''';
  }
}