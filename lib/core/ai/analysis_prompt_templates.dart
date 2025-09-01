/// 🎯 활동 분석 프롬프트 템플릿
/// 
/// 운동 활동에 대한 구체적이고 감성적인 분석 프롬프트를 생성합니다.
/// 셰르피의 따뜻하고 친근한 성격을 반영하여 사용자에게 힘이 되는 메시지를 전달합니다.
class AnalysisPromptTemplates {
  
  /// 🏃 운동 분석 프롬프트 생성
  static String generateExerciseAnalysisPrompt({
    required Map<String, dynamic> todayExercise,
    Map<String, dynamic>? previousExercise,
    required String userName,
  }) {
    // 오늘 운동 데이터 추출
    final exerciseType = _translateExerciseType(todayExercise['type'] ?? '운동');
    final intensity = _ensureKorean(todayExercise['intensity'] ?? '보통');
    final duration = todayExercise['duration'] ?? 0;
    final calories = todayExercise['calories'] ?? 0;
    final steps = todayExercise['steps'] ?? 0;
    
    // 이전 운동 데이터 추출 (있는 경우)
    String previousContext = '';
    if (previousExercise != null) {
      final prevType = _translateExerciseType(previousExercise['type'] ?? '');
      final prevIntensity = _ensureKorean(previousExercise['intensity'] ?? '');
      final prevCalories = previousExercise['calories'] ?? 0;
      final prevDuration = previousExercise['duration'] ?? 0;
      
      previousContext = '''
이전 운동 정보:
- 운동 종류: $prevType
- 운동 강도: $prevIntensity
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
   - 중요: 이전 기록을 언급할 때는 "어제"가 아닌 "지난번"이라고 표현
4. 운동의 긍정적 효과 언급 (건강, 활력, 스트레스 해소 등)
5. 따뜻한 격려와 응원으로 마무리
6. 적절한 이모지 사용 (💪, 🏃, 🔥, ⚡, 🎯 등)

톤: 친근하고 격려하는 친구처럼, 구체적인 데이터를 언급하며 개인화된 피드백
길이: 4-5문장''';
  }
  
  /// 운동 타입 번역
  static String _translateExerciseType(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return '러닝';
      case 'walking':
        return '걷기';
      case 'cycling':
        return '자전거';
      case 'swimming':
        return '수영';
      case 'yoga':
        return '요가';
      case 'gym':
        return '헬스';
      case 'hiking':
        return '하이킹';
      default:
        return type;
    }
  }
  
  /// 영어를 한국어로 확실히 변환
  static String _ensureKorean(String text) {
    // 강도 번역
    switch (text.toLowerCase()) {
      case 'low':
        return '낮음';
      case 'medium':
      case 'moderate':
        return '보통';
      case 'high':
        return '높음';
      case 'very_high':
      case 'very high':
      case 'veryhigh':
        return '매우 높음';
      // 감정 번역
      case 'excited':
        return '설레요';
      case 'happy':
        return '행복해요';
      case 'peaceful':
        return '평온해요';
      case 'normal':
        return '보통이에요';
      case 'tired':
        return '피곤해요';
      case 'sad':
        return '우울해요';
      case 'anxious':
        return '불안해요';
      case 'angry':
        return '화나요';
      case 'stressed':
        return '스트레스받아요';
      default:
        return text;
    }
  }
}