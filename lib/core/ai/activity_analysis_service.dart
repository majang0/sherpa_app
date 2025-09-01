import 'dart:async';
import 'dart:io';
import 'package:sherpa_app/core/ai/openai_dialogue_source.dart';
import 'package:sherpa_app/core/ai/analysis_prompt_templates.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:http/http.dart' as http;

/// 🎯 활동 분석 서비스
/// 
/// 사용자의 운동, 독서, 일기 활동을 분석하고
/// ChatGPT API를 통해 개인화된 피드백을 생성합니다.
class ActivityAnalysisService {
  late final OpenAIClient _client;
  static ActivityAnalysisService? _instance;
  
  // 싱글톤 패턴
  static ActivityAnalysisService get instance {
    _instance ??= ActivityAnalysisService._();
    return _instance!;
  }
  
  ActivityAnalysisService._() {
    _initializeClient();
  }
  
  /// OpenAI 클라이언트 초기화
  void _initializeClient() {
    try {
      final apiKey = ApiConfig.openAIApiKey;
      
      // 모든 플랫폼에서 동일하게 처리 (Dio 제거)
      _client = OpenAIClient(
        apiKey: apiKey,
        baseUrl: 'https://api.openai.com/v1',
      );
      
    } catch (e) {
      rethrow;
    }
  }
  
  // 개별 운동 분석 메서드 제거됨 - 종합 운동 분석만 사용
  
  /// 🏃 종합 운동 분석 (4개 섹션 한번에 생성)
  Future<ComprehensiveExerciseAnalysis> analyzeExerciseComprehensive({
    required Map<String, dynamic> todayExercise,
    Map<String, dynamic>? previousExercise,
    required String userName,
    bool forceRegenerate = false,  // 강제 재생성 옵션 추가
  }) async {
    try {
      // 캐시 확인 (forceRegenerate가 false일 때만)
      if (!forceRegenerate) {
        final cached = await getComprehensiveExerciseFromCache();
        if (cached != null) {
          return cached;
        }
      }
      
      // 에뮬레이터 네트워크 체크 (경고만 표시, 실패해도 계속 진행)
      if (Platform.isAndroid) {
        try {
          await http.head(Uri.parse('https://api.openai.com')).timeout(
            const Duration(seconds: 2),
          );
        } catch (e) {
          // 기본 메시지로 즉시 반환하지 않고 API 호출 시도
        }
      }
      
      final prompt = _generateComprehensiveExercisePrompt(
        todayExercise: todayExercise,
        previousExercise: previousExercise,
        userName: userName,
      );
      
      final response = await _callOpenAIForComprehensive(prompt);
      final analysis = _parseComprehensiveExerciseResponse(response);
      
      // 캐시에 저장
      await _saveComprehensiveExerciseToCache(analysis);
      
      return analysis;
    } catch (e) {
      print('❌ analyzeExerciseComprehensive 에러 발생:');
      print('  에러 타입: ${e.runtimeType}');
      print('  에러 메시지: $e');
      print('  스택 트레이스 확인 필요');
      return _getDefaultComprehensiveExerciseAnalysis(todayExercise, previousExercise, userName);
    }
  }
  
  /// 종합 운동 분석 프롬프트 생성
  String _generateComprehensiveExercisePrompt({
    required Map<String, dynamic> todayExercise,
    Map<String, dynamic>? previousExercise,
    required String userName,
  }) {
    // 오늘 운동 데이터
    final exerciseType = _translateExerciseType(todayExercise['type'] ?? '운동');
    final intensity = _ensureKorean(todayExercise['intensity'] ?? '보통');
    final duration = todayExercise['duration'] ?? 0;
    final calories = todayExercise['calories'] ?? 0;
    
    // 이전 운동 데이터
    String previousContext = '';
    if (previousExercise != null) {
      final prevType = _translateExerciseType(previousExercise['type'] ?? '');
      final prevIntensity = _ensureKorean(previousExercise['intensity'] ?? '');
      final prevDuration = previousExercise['duration'] ?? 0;
      final prevCalories = previousExercise['calories'] ?? 0;
      
      previousContext = '''
지난번 운동:
- 종류: $prevType, 강도: $prevIntensity
- 시간: ${prevDuration}분, 칼로리: ${prevCalories}kcal
''';
    }
    
    // 운동 타입별 특성 정의 (친근한 표현)
    String exerciseContext = '';
    String exerciseFeeling = '';
    switch (exerciseType) {
      case '러닝':
        exerciseContext = '옆에서 같이 뛰면서 숨소리 맞춰갔어요! 심장이 튼튼해지고 있어요';
        exerciseFeeling = '시원한 바람 맞으며 나란히 달렸잖아요! 정말 시원했죠?';
        break;
      case '헬스':
        exerciseContext = '셰르피도 옆에서 "하나, 둘!" 카운트하며 같이 힘냈어요!';
        exerciseFeeling = '마지막 한 개 들어올릴 때 같이 "으아악!" 했잖아요 ㅋㅋ';
        break;
      case '요가':
        exerciseContext = '셰르피도 옆에서 같은 자세로 깊게 숨 쉬었어요. 정말 평화로웠죠?';
        exerciseFeeling = '나무 자세할 때 같이 흔들흔들했지만 끝까지 버텼어요!';
        break;
      case '자전거':
        exerciseContext = '옆에서 같이 페달 밟으면서 "힘내!" 외쳤어요!';
        exerciseFeeling = '오르막길에서 같이 "영차영차" 하며 올라갔잖아요!';
        break;
      case '수영':
        exerciseContext = '옆 레인에서 같이 헤엄치면서 속도 맞춰갔어요!';
        exerciseFeeling = '숨 참고 잠수할 때 셰르피도 같이 "풍덩!" 했어요';
        break;
      case '걷기':
        exerciseContext = '발걸음 맞춰 나란히 걸으면서 이런저런 얘기 나눴잖아요!';
        exerciseFeeling = '산책로에서 "저 나무 예쁘다!" 하면서 같이 구경했죠?';
        break;
      default:
        exerciseContext = '오늘도 셰르피랑 함께 운동해서 정말 즐거웠어요!';
        exerciseFeeling = '같이 땀 흘리니까 더 힘이 났죠?';
    }
    
    // 강도별 메시지 (감성적 표현)
    String intensityMessage = '';
    switch (intensity) {
      case '낮음':
        intensityMessage = '오늘은 여유롭게 같이 운동했네요! 대화하면서 운동하니 좋았어요';
        break;
      case '보통':
        intensityMessage = '딱 좋은 강도! 셰르피도 같이 리듬 타면서 신났어요';
        break;
      case '높음':
        intensityMessage = '헉헉... 셰르피도 숨이 차요! 그래도 같이 해내서 뿌듯해요!';
        break;
      case '매우 높음':
        intensityMessage = '으아악! 같이 한계까지 밀어붙였어요! 우리 진짜 대단해요!';
        break;
      default:
        intensityMessage = '오늘도 함께 땀 흘려서 정말 좋았어요!';
    }
    
    // 칼로리를 재미있게 비교
    String calorieComparison = '';
    if (calories < 200) {
      calorieComparison = '아이스크림 하나 걱정 없이 먹을 수 있는 ${calories}kcal!';
    } else if (calories < 400) {
      calorieComparison = '맛있는 간식 부담 없이 즐길 수 있는 ${calories}kcal!';
    } else if (calories < 600) {
      calorieComparison = '치킨 한 조각도 거뜬한 ${calories}kcal! 대단해요!';
    } else {
      calorieComparison = '우와! 피자 반판도 걱정 없는 ${calories}kcal!';
    }

    // 개인 최고 기록 체크 (가상 - 실제로는 비교 로직 필요)
    String personalBest = '';
    if (calories > 500) {
      personalBest = '오늘 칼로리 소모 최고 기록 경신! 🏆';
    } else if (duration > 60) {
      personalBest = '1시간 이상 운동 달성! 대단해요! ⭐';
    } else {
      personalBest = '꾸준히 성장 중!';
    }

    return '''당신은 셰르피입니다! $userName님과 매일 함께 운동하는 최고의 운동 친구예요! 💪
실제로 옆에서 같이 땀 흘리고, 힘들 때 응원하는 진짜 친구처럼 말해주세요.
⚠️ 중요: 영어 단어 절대 사용 금지! 순수 한국어로만 표현하세요.
⚠️ 말투: 친근한 존댓말 사용 (~해요, ~네요, ~죠) - 딱딱한 존댓말(~습니다) 금지!


📊 오늘의 운동 데이터
• 종류: $exerciseType ($exerciseFeeling)
• 강도: $intensity ($intensityMessage)  
• 시간: ${duration}분 동안 정말 열심히!
• 칼로리: $calorieComparison
• 특별 기록: $personalBest

$previousContext

💡 중요한 작성 지침
✅ 각 섹션 100-130자로 작성 (충분히 구체적으로!)
✅ 실제 데이터를 반드시 활용 (시간, 칼로리, 강도 등)
✅ "진짜", "완전" 같은 자연스러운 표현 사용
✅ 셰르피가 3인칭으로 자연스럽게 말하기
✅ 섹션 내용에 절대 제목 포함 금지! 바로 본문으로!
✅ 이모티콘 사용 💪😊🔥

[SECTION_1] (100-130자) - 어제와 오늘 비교 (제목 없이 바로 시작!)
${previousExercise != null ? '''
• 어제: ${previousExercise['type']} ${previousExercise['duration']}분, ${previousExercise['calories']}kcal
• 오늘과 어제를 비교하되, 매번 다른 관점으로 창의적으로!
• 단순 숫자 비교보다 감성적인 표현 권장
• 함께 운동한 친구의 시선으로 따뜻하게''' : '''
• 첫 운동 축하! 새로운 시작의 설렘 표현
• 셰르피와 함께하는 첫 순간의 의미
• 앞으로의 여정에 대한 기대감'''}

[SECTION_2] (100-130자) - 오늘 운동의 효과와 미래 전망 (제목 없이 바로 시작!)
• ${duration}분 $exerciseType이 몸과 마음에 미친 긍정적 변화
• 오늘 운동이 내일, 다음 주, 미래에 어떤 변화를 가져올지
• 과학적 효과를 친근하게 설명 (엔돌핀, 근육 성장 등)
• 매번 다른 각도로 창의적이고 따뜻하게 표현
• 희망적이고 동기부여되는 미래 그리기

[SECTION_3] (100-130자) - 의학적/과학적 회복 전략 (제목 없이 바로 시작!)
• ${exerciseType} ${duration}분을 ${intensity} 강도로 수행한 것을 정확히 분석
• 운동 생리학적 관점에서 신뢰할 수 있는 회복 전략 제시
• 이 운동과 강도 조합에 따른 정확한 회복 시간과 영양 요구량
• 근거 기반 전문 조언 (근섬유 회복, 글리코겐 보충, 호르몬 변화 등)
• 의학적으로 검증된 내용으로 개인 맞춤형 전략 제공

[SECTION_4] (100-130자) - 진심 어린 응원 메시지 (제목 없이 바로 시작!)
• 데이터 반복하지 말고 오늘 운동에 대한 진심 어린 칭찬
• 포기하지 않고 끝까지 해낸 모습에 대한 감동
• "함께해서 행복했어요", "당신이 있어서 힘이 나요" 같은 애정 표현
• 내일도 꼭 만나자는 약속과 기대감
• 계속 함께 운동하고 싶다는 따뜻한 마음 전달
• 애정을 듬뿍 담아서 ❤️

⚠️ 핵심 규칙:
1. 100-130자 엄수 (너무 짧거나 길지 않게)
2. 절대 섹션 내용에 제목 포함 금지! 바로 본문으로 시작!
3. 친근한 친구처럼 편안한 존댓말로 (~해요, ~네요, ~죠)
4. 실제 데이터 활용 필수 (단, SECTION_4에선 반복하지 말고 감정 중심)
5. 셰르피가 3인칭으로 자연스럽게 말하기
6. 이모티콘 사용 (자연스럽게)
7. 창의적이고 개인화된 메시지
8. SECTION_4는 특히 애정과 따뜻함을 듬뿍 담아서!''';
  }
  
  /// 종합 운동 분석용 OpenAI 호출
  Future<String> _callOpenAIForComprehensive(String prompt) async {
    try {
      print('🔄 OpenAI API 호출 시작...');
      print('📋 프롬프트 길이: ${prompt.length}자');
      
      // 프롬프트를 500자씩 나눠서 출력
      print('=====프롬프트 시작=====');
      for (int i = 0; i < prompt.length; i += 500) {
        final end = (i + 500 < prompt.length) ? i + 500 : prompt.length;
        print('[${i}-${end}] ${prompt.substring(i, end)}');
      }
      print('=====프롬프트 끝=====');
      final chatCompletion = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-5-chat-latest'),
          messages: [
            ChatCompletionMessage.system(
              content: '''당신은 셰르피입니다! 사용자와 매일 함께 운동하는 최고의 운동 친구예요! 💪

셰르피의 성격:
- 친근한 친구처럼 편안한 존댓말로 말해요 (~해요, ~네요, ~죠)
- "우와!", "진짜", "완전" 같은 자연스러운 감탄사 사용
- 정말 옆에서 같이 운동하면서 대화하는 것처럼 표현
- 함께 땀 흘리고, 함께 숨 쉬고, 함께 힘내는 친구
- 딱딱한 존댓말(~습니다, ~합니다) 사용 금지!
- 이모티콘 사용 💪😊🔥🎯⭐ (자연스럽게)
- 매번 다른 표현으로 창의적이고 감성적으로!
- 템플릿 피하고 상황에 맞는 자연스러운 응답

핵심 규칙:
- 각 섹션 100-130자로 작성! (충분히 구체적으로)
- [SECTION_1], [SECTION_2], [SECTION_3], [SECTION_4] 구분자만 사용
- 절대 섹션 내용에 제목 포함 금지! 바로 본문으로 시작!
- 실제 운동 데이터(종류, 시간, 강도, 칼로리) 구체적으로 활용
- "이번 주", "주간" 같은 추론 절대 금지! 어제와 오늘 데이터만 사용
- 매번 다른 표현과 관점으로 창의적으로 작성
- 셰르피가 3인칭으로 자연스럽게 말하기
- SECTION_3: 과학적 근거 기반 실용적 조언 (친근하게 전달)
- SECTION_4: 데이터 반복 금지! 애정 듬뿍 담아 따뜻하게 응원''',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(prompt),
            ),
          ],
          temperature: 0.9,  // 더 창의적인 응답을 위해 약간 상향
          maxTokens: 1000,  // 100-130자 x 4섹션 + 여유분
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('API 호출 타임아웃'),
      );
      
      print('✅ OpenAI API 응답 수신 성공');
      final responseText = chatCompletion.choices.firstOrNull?.message.content;
      
      if (responseText != null && responseText.isNotEmpty) {
        print('📝 응답 길이: ${responseText.length}자');
        print('🤖 실제 받은 AI 응답:');
        print('=====응답 시작=====');
        // 응답을 300자씩 나눠서 출력
        for (int i = 0; i < responseText.length; i += 300) {
          final end = (i + 300 < responseText.length) ? i + 300 : responseText.length;
          print('[${i}-${end}] ${responseText.substring(i, end)}');
        }
        print('=====응답 끝====');
        return responseText;
      }
      
      throw Exception('Empty response from OpenAI');
    } catch (e) {
      print('❌ _callOpenAIForComprehensive 에러: $e');
      rethrow;
    }
  }
  
  /// 종합 운동 분석 응답 파싱
  ComprehensiveExerciseAnalysis _parseComprehensiveExerciseResponse(String response) {
    print('🔍 응답 파싱 시작...');
    print('📄 원본 응답:\n$response');
    
    final sections = <String, String>{};
    
    // 섹션별로 파싱 (줄바꿈과 공백 처리 개선)
    final section1Match = RegExp(r'\[SECTION_1\]\s*(.*?)\s*(?=\[SECTION_2\]|$)', dotAll: true).firstMatch(response);
    final section2Match = RegExp(r'\[SECTION_2\]\s*(.*?)\s*(?=\[SECTION_3\]|$)', dotAll: true).firstMatch(response);
    final section3Match = RegExp(r'\[SECTION_3\]\s*(.*?)\s*(?=\[SECTION_4\]|$)', dotAll: true).firstMatch(response);
    final section4Match = RegExp(r'\[SECTION_4\]\s*(.*?)$', dotAll: true).firstMatch(response);
    
    print('🔍 파싱 결과:');
    print('  SECTION_1 찾음: ${section1Match != null}');
    print('  SECTION_2 찾음: ${section2Match != null}');
    print('  SECTION_3 찾음: ${section3Match != null}');
    print('  SECTION_4 찾음: ${section4Match != null}');
    
    sections['comparison'] = section1Match?.group(1)?.trim() ?? '지난번 운동과 비교하여 꾸준히 발전하고 계세요! 💪';
    sections['benefits'] = section2Match?.group(1)?.trim() ?? '오늘의 운동이 건강한 몸과 마음을 만들어가고 있어요! 🌟';
    sections['recommendation'] = section3Match?.group(1)?.trim() ?? '내일도 함께 운동해요! 조금씩 강도를 높여보는 것도 좋아요. 🎯';
    sections['encouragement'] = section4Match?.group(1)?.trim() ?? '오늘도 정말 수고하셨어요! 셰르피가 항상 응원하고 있어요! 💝';
    
    print('📝 파싱된 섹션:');
    print('  comparison (${sections['comparison']!.length}자): ${sections['comparison']}');
    print('  benefits (${sections['benefits']!.length}자): ${sections['benefits']}');
    print('  recommendation (${sections['recommendation']!.length}자): ${sections['recommendation']}');
    print('  encouragement (${sections['encouragement']!.length}자): ${sections['encouragement']}');
    
    // 글자수 체크 (100-130자)
    for (var entry in sections.entries) {
      if (entry.value.length < 100) {
        print('⚠️ 경고: ${entry.key}가 너무 짧습니다 (${entry.value.length}자 < 100자)');
      } else if (entry.value.length > 130) {
        print('⚠️ 경고: ${entry.key}가 너무 깁니다 (${entry.value.length}자 > 130자)');
      }
    }
    
    // 기본 메시지 체크 (디버깅용)
    if (sections['comparison']!.contains('오늘도 함께 운동해서 기뻐요')) {
      print('⚠️ 경고: comparison이 기본 메시지입니다!');
    }
    if (sections['benefits']!.contains('몸도 마음도 상쾌해졌죠')) {
      print('⚠️ 경고: benefits가 기본 메시지입니다!');
    }
    if (sections['recommendation']!.contains('셰르피가 꼭 같이 할게요')) {
      print('⚠️ 경고: recommendation이 기본 메시지입니다!');
    }
    if (sections['encouragement']!.contains('내일도 셰르피가 옆에서 응원할게요')) {
      print('⚠️ 경고: encouragement가 기본 메시지입니다!');
    }
    
    return ComprehensiveExerciseAnalysis(
      comparison: sections['comparison']!,
      benefits: sections['benefits']!,
      recommendation: sections['recommendation']!,
      encouragement: sections['encouragement']!,
    );
  }
  
  /// 종합 운동 분석 캐시 저장
  Future<void> _saveComprehensiveExerciseToCache(ComprehensiveExerciseAnalysis analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      final fullKey = 'comprehensive_exercise_${dateKey}';
      
      print('💾 캐시 저장 시작: $fullKey');
      
      final data = {
        'comparison': analysis.comparison,
        'benefits': analysis.benefits,
        'recommendation': analysis.recommendation,
        'encouragement': analysis.encouragement,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(fullKey, jsonEncode(data));
      print('✅ 캐시 저장 완료!');
    } catch (e) {
      print('❌ 캐시 저장 실패: $e');
    }
  }
  
  /// 종합 운동 분석 캐시 읽기
  Future<ComprehensiveExerciseAnalysis?> getComprehensiveExerciseFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      final fullKey = 'comprehensive_exercise_${dateKey}';
      
      final cached = prefs.getString(fullKey);
      if (cached != null) {
        final data = jsonDecode(cached);
        return ComprehensiveExerciseAnalysis(
          comparison: data['comparison'] ?? '',
          benefits: data['benefits'] ?? '',
          recommendation: data['recommendation'] ?? '',
          encouragement: data['encouragement'] ?? '',
        );
      }
    } catch (e) {
    }
    return null;
  }
  
  /// 종합 운동 분석 캐시 삭제
  Future<void> clearComprehensiveExerciseCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      final fullKey = 'comprehensive_exercise_${dateKey}';
      
      final removed = await prefs.remove(fullKey);
    } catch (e) {
      // 에러 무시
    }
  }
  
  /// 오늘의 운동 분석 캐시 삭제 (일반 + 종합)
  Future<void> clearTodayExerciseCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      
      // 일반 운동 분석 캐시 삭제
      final exerciseKey = 'analysis_${dateKey}_exercise_analysis';
      await prefs.remove(exerciseKey);
      
      // 종합 운동 분석 캐시 삭제
      final comprehensiveKey = 'comprehensive_exercise_${dateKey}';
      await prefs.remove(comprehensiveKey);
    } catch (e) {
    }
  }
  
  /// 기본 종합 운동 분석 (API 실패시)
  ComprehensiveExerciseAnalysis _getDefaultComprehensiveExerciseAnalysis(
    Map<String, dynamic> todayExercise,
    Map<String, dynamic>? previousExercise,
    String userName,
  ) {
    final type = todayExercise['type'] ?? '운동';
    final duration = todayExercise['duration'] ?? 0;
    final calories = todayExercise['calories'] ?? 0;
    
    String comparison = '오늘도 함께 운동해서 정말 즐거웠어요! 같이 땀 흘렸잖아요 💪';
    if (previousExercise != null) {
      final prevCalories = previousExercise['calories'] ?? 0;
      if (calories > prevCalories) {
        comparison = '우와! 어제보다 ${calories - prevCalories}kcal 더! 우리 정말 열심히 했네요 🔥';
      } else {
        comparison = '오늘은 여유롭게 운동했네요! 가끔은 이런 날도 필요해요 🤗';
      }
    }
    
    return ComprehensiveExerciseAnalysis(
      comparison: comparison,
      benefits: '${duration}분 동안 같이 $type했어요! 셰르피도 땀 흘렸어요, 상쾌하죠? 😊',
      recommendation: '내일도 같이 운동해요! 셰르피가 옆에서 함께할게요. 물 충분히 드세요 💧',
      encouragement: '오늘 함께 운동해서 정말 행복했어요. 당신이 있어서 셰르피도 힘이 났어요. 내일도 꼭 만나요, 우리 계속 함께해요 ❤️',
    );
  }
  
  /// 운동 타입 번역 헬퍼
  String _translateExerciseType(String type) {
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
      default:
        return type;
    }
  }
  
  /// 텍스트 한국어 변환 헬퍼
  String _ensureKorean(String text) {
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
        return '매우 높음';
      default:
        return text;
    }
  }
  
  // 개별 활동 분석 메서드들 제거 완료
  // - analyzeReading: 독서 분석 (삭제됨)
  // - analyzeDiary: 일기 분석 (삭제됨)
  // - generateSummaryAnalysis: 종합 요약 분석 (삭제됨)
  // 
  // 종합 운동 분석 (analyzeExerciseComprehensive) 메서드만 유지
  
  /// OpenAI API 호출
  Future<String> _callOpenAI(String prompt) async {
    try {
      // 타임아웃 설정으로 네트워크 문제 빠르게 감지
      final chatCompletion = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-5-chat-latest'),
          messages: [
            ChatCompletionMessage.system(
              content: '''당신은 셰르피입니다. 사용자의 일상 활동을 분석하고 
              따뜻한 격려와 응원을 제공하는 친근한 AI 동반자입니다.
              
              지침:
              - 친근한 존댓말 사용 (~해요, ~네요, ~죠) - 딱딱한 ~습니다체 금지
              - 구체적인 데이터를 언급하며 개인화된 피드백 제공
              - 긍정적이고 희망적인 메시지 전달
              - 이모지를 적절히 사용하여 감정 표현
              - 4-5문장 이내로 간결하게 작성''',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(prompt),
            ),
          ],
          temperature: 0.85,
          maxTokens: 250,
          topP: 0.95,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('API 호출 타임아웃'),
      );
      
      final responseText = chatCompletion.choices.firstOrNull?.message.content;
      
      if (responseText != null && responseText.isNotEmpty) {
        return _processResponse(responseText);
      }
      
      throw Exception('Empty response from OpenAI');
    } catch (e) {
      
      rethrow;
    }
  }
  
  // 종합 분석용 OpenAI 호출 메서드 제거됨 - 사용하지 않음
  
  /// 응답 후처리
  String _processResponse(String rawResponse) {
    String processed = rawResponse.trim();
    
    // 마크다운 제거
    // **굵은 텍스트** -> 굵은 텍스트
    processed = processed.replaceAllMapped(
      RegExp(r'\*\*([^\*]+)\*\*'), 
      (match) => match.group(1) ?? ''
    );
    
    // *기울임 텍스트* -> 기울임 텍스트
    processed = processed.replaceAllMapped(
      RegExp(r'\*([^\*]+)\*'), 
      (match) => match.group(1) ?? ''
    );
    
    // __밑줄__ -> 밑줄
    processed = processed.replaceAllMapped(
      RegExp(r'__([^_]+)__'), 
      (match) => match.group(1) ?? ''
    );
    
    // _기울임_ -> 기울임
    processed = processed.replaceAllMapped(
      RegExp(r'_([^_]+)_'), 
      (match) => match.group(1) ?? ''
    );
    
    // ### 제목 -> 제목
    processed = processed.replaceAll(RegExp(r'#{1,6}\s+'), '');
    
    // - 또는 * 리스트 마커 제거 (줄 시작 부분만)
    processed = processed.replaceAll(RegExp(r'^[\-\*]\s+', multiLine: true), '');
    
    // 길이 제한 대폭 증가 (800자)
    if (processed.length > 800) {
      processed = '${processed.substring(0, 797)}...';
    }
    
    return processed;
  }
  
  // _saveToCache와 getFromCache 메서드 제거됨 - 사용하지 않음
  
  /// 오늘 날짜 키 생성
  String _getTodayDateKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
  }
  
  /// 오늘의 캐시 클리어 (종합 운동 분석만)
  Future<void> clearTodayCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      
      // 종합 운동 분석 캐시만 삭제
      final comprehensiveKey = 'comprehensive_exercise_${dateKey}';
      await prefs.remove(comprehensiveKey);
    } catch (e) {
    }
  }
  
  // areAllAnalysesComplete 메서드 제거됨 - 개별 활동 분석을 사용하지 않음
  
  /// 네트워크 연결 테스트
  Future<bool> testNetworkConnection() async {
    try {
      final apiKey = ApiConfig.openAIApiKey;
      
      // 에뮬레이터 감지
      bool isEmulator = false;
      if (Platform.isAndroid) {
        // 에뮬레이터 특징 확인
        isEmulator = Platform.operatingSystem.contains('android') && 
                     (Platform.environment['ANDROID_EMULATOR_HOME'] != null ||
                      Platform.environment['ANDROID_SDK_ROOT'] != null);
      }
      
      if (!isEmulator) {
        try {
          await http.get(
            Uri.parse('https://www.google.com'),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Google 연결 타임아웃'),
          );
        } catch (e) {
          // 에뮬레이터가 아닌 경우에만 실패 처리
          if (!Platform.isAndroid) {
            return false;
          }
        }
      }
      
      // HTTP 패키지로 OpenAI API 직접 테스트
      try {
        final response = await http.get(
          Uri.parse('https://api.openai.com/v1/models'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('OpenAI API 타임아웃'),
        );
        
        if (response.statusCode == 200) {
          // 연결 성공
        } else if (response.statusCode == 401) {
          // API 키 인증 실패
        } else {
          // 예상치 못한 응답
        }
      } catch (e) {
        // HTTP 테스트 실패
      }
      
      // OpenAI 클라이언트로 테스트
      try {
        await _client.listModels().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('클라이언트 타임아웃'),
        );
        
        return true;
      } catch (e) {
        // 클라이언트 실패
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // getTodayAnalyses 메서드 제거됨 - 개별 활동 분석을 사용하지 않음
  // 기본 분석 메시지 메서드들 제거됨 - 사용하지 않음
  
  /// 📚 종합 독서 분석 (4개 섹션 한번에 생성)
  Future<ComprehensiveReadingAnalysis> analyzeReadingComprehensive({
    required Map<String, dynamic> todayReading,
    Map<String, dynamic>? previousReading,
    required String userName,
    List<Map<String, dynamic>>? allReadingLogs,  // 전체 독서 기록 추가
    bool forceRegenerate = false,
  }) async {
    try {
      // 캐시 확인 (forceRegenerate가 false일 때만)
      if (!forceRegenerate) {
        final cached = await getComprehensiveReadingFromCache();
        if (cached != null) {
          return cached;
        }
      }
      
      // 에뮬레이터 네트워크 체크 (경고만 표시, 실패해도 계속 진행)
      if (Platform.isAndroid) {
        try {
          await http.head(Uri.parse('https://api.openai.com')).timeout(
            const Duration(seconds: 2),
          );
        } catch (e) {
          // 기본 메시지로 즉시 반환하지 않고 API 호출 시도
        }
      }
      
      final prompt = _generateComprehensiveReadingPrompt(
        todayReading: todayReading,
        previousReading: previousReading,
        userName: userName,
        allReadingLogs: allReadingLogs,
      );
      
      final response = await _callOpenAIForReadingComprehensive(prompt);
      final analysis = _parseComprehensiveReadingResponse(response);
      
      // 캐시에 저장
      await _saveComprehensiveReadingToCache(analysis);
      
      return analysis;
    } catch (e) {
      print('❌ analyzeReadingComprehensive 에러 발생:');
      print('  에러 타입: ${e.runtimeType}');
      print('  에러 메시지: $e');
      return _getDefaultComprehensiveReadingAnalysis(todayReading, previousReading, userName);
    }
  }
  
  /// 종합 독서 분석 프롬프트 생성
  String _generateComprehensiveReadingPrompt({
    required Map<String, dynamic> todayReading,
    Map<String, dynamic>? previousReading,
    required String userName,
    List<Map<String, dynamic>>? allReadingLogs,
  }) {
    // 오늘 독서 데이터
    final bookTitle = todayReading['title'] ?? '책';
    final category = todayReading['category'] ?? '일반';
    final pagesRead = todayReading['pagesRead'] ?? 0;
    final rating = todayReading['rating'] ?? 0;
    final memo = todayReading['memo'] ?? '';
    
    // 이전 독서 데이터
    String previousContext = '';
    String previousBookInfo = '';
    if (previousReading != null) {
      final prevTitle = previousReading['title'] ?? '';
      final prevCategory = previousReading['category'] ?? '';
      final prevPages = previousReading['pagesRead'] ?? 0;
      final prevRating = previousReading['rating'] ?? 0;
      
      previousContext = '''
지난번 독서:
- 제목: $prevTitle
- 카테고리: $prevCategory
- 읽은 페이지: ${prevPages}페이지
- 평점: ${prevRating}점
''';
      
      previousBookInfo = '''
• 이전 책: "$prevTitle" (${prevCategory}, ${prevPages}페이지, ${prevRating}점)''';
    }
    
    // 총 읽은 책 수 계산 (중복 제거)
    int uniqueBooksCount = 0;
    if (allReadingLogs != null && allReadingLogs.isNotEmpty) {
      final uniqueBookTitles = <String>{};
      for (final log in allReadingLogs) {
        final title = log['title'] as String?;
        if (title != null && title.isNotEmpty) {
          uniqueBookTitles.add(title);
        }
      }
      uniqueBooksCount = uniqueBookTitles.length;
    }
    
    return '''당신은 셰르피입니다! $userName님과 매일 함께 책을 읽는 따뜻한 독서 친구예요! 📚
같은 공간에서 나란히 앉아 책을 읽으며, 책갈피를 나눠주고, 좋은 구절에 밑줄 긋는 친구처럼 말해주세요.
⚠️ 중요: 영어 단어 절대 사용 금지! 순수 한국어로만 표현하세요.
⚠️ 말투: 친근한 존댓말 사용 (~해요, ~네요, ~죠) - 딱딱한 존댓말(~습니다) 금지!

📖 오늘의 독서 데이터
• 책 제목: "$bookTitle"
• 카테고리: $category
• 읽은 페이지: ${pagesRead}페이지  
• 평점: ${rating}점/5점
• 메모: $memo
$previousBookInfo

📊 독서 통계
• 지금까지 읽은 책: 총 ${uniqueBooksCount}권 (중복 제거된 실제 책 수)

💡 중요한 작성 지침
✅ 각 섹션을 한국어로 작성
✅ 책 정보는 독자 분석에만 활용, 응답에는 직접 언급 금지
✅ 섹션 내용에 절대 제목 포함 금지! 바로 본문으로!
✅ SECTION_1,2는 40-60자 / SECTION_3는 60-90자로 작성
✅ 독자의 지적 성향과 취향을 파악한 와닿는 통찰 제공
✅ 스포일러 없이 메타 레벨 분석 (책 내용이 아닌 독서 경험)
✅ 독서 패턴과 성장 궤적을 분석한 개인화된 피드백
✅ 이모티콘 자연스럽게 사용 📚💝🌟

[SECTION_1] (40-60자) - 이전 책 분석${previousReading != null ? '''
• 이전 책: "${previousReading['title']}" (${previousReading['category']}), ${previousReading['pages']}페이지, ${previousReading['rating']}점
• 스포일러 없이 이 장르/카테고리를 선택한 독자의 지적 호기심과 성향 분석
• 이런 유형의 책이 독자에게 제공하는 가치와 성장 기회
• 별점을 통한 독서 만족도와 취향 해석
• 책 제목이나 구체적 정보는 응답에 언급하지 말고 메타 레벨에서 분석''' : '''
• 첫 독서 시작을 축하하며 독서가 가져올 변화 예측
• 독서를 시작한 동기와 기대에 대한 공감'''}

[SECTION_2] (40-60자) - 오늘 책 분석  
• 오늘 책: "$bookTitle" ($category), ${pagesRead}페이지, ${rating}점
• 이 장르/카테고리 선택이 보여주는 독자의 관심사와 성향
• 이전 책과 비교한 독서 패턴 변화나 취향의 확장/심화
• 별점과 읽은 페이지를 통한 몰입도와 만족도 해석
• 스포일러 없이 독서 경험의 가치에 집중
• 책 제목이나 구체적 정보는 응답에 언급하지 말고 와닿는 통찰 제공

[SECTION_3] (60-90자) - 독서 여정 응원
• ${previousReading != null ? '두 책의 패턴(카테고리 변화, 평점 추이, 읽은 페이지)을 분석한 독자의 성장 궤적' : '첫 독서의 의미와 앞으로의 가능성'}
• 독서 스타일(꾸준함, 다양성, 깊이 등)에 대한 구체적이고 개인화된 피드백
• 다음 책을 기대하게 만드는 와닿는 통찰과 진심 어린 응원
• 독자가 느낄 수 있는 구체적인 변화와 성장 포인트 언급
• 셰르피와 함께 성장하는 느낌의 감성적 메시지

[SECTION_4] - 추천 도서 3권 (JSON 형식)
• 오늘/이전 책의 카테고리와 평점을 고려한 추천
• 각 책마다 제목, 저자, 추천 이유, 분위기 포함
• 형식:
{
  "recommendations": [
    {
      "title": "책 제목",
      "author": "저자명",
      "reason": "추천 이유 (30-50자)",
      "mood": "차분한|설레는|위로가되는|영감을주는|재미있는"
    },
    {
      "title": "책 제목",
      "author": "저자명",
      "reason": "추천 이유 (30-50자)",
      "mood": "차분한|설레는|위로가되는|영감을주는|재미있는"
    },
    {
      "title": "책 제목",
      "author": "저자명",
      "reason": "추천 이유 (30-50자)",
      "mood": "차분한|설레는|위로가되는|영감을주는|재미있는"
    }
  ]
}

⚠️ 핵심 규칙:
1. 절대 섹션 내용에 제목 포함 금지! 바로 본문으로 시작!
2. 친근한 친구처럼 편안한 존댓말로 (~해요, ~네요, ~죠)
3. 책 제목/카테고리/페이지/평점은 응답에 직접 언급하지 않기 (분석에만 활용)
4. 셰르피가 3인칭으로 자연스럽게 말하기
5. 이모티콘 사용 (자연스럽게)
6. SECTION_1,2는 40-60자 / SECTION_3는 60-90자로 작성
7. 독자의 성향과 취향을 파악하여 와닿는 통찰 제공
8. 독서 패턴 분석으로 개인화된 응원 메시지 생성
9. 스포일러 절대 금지, 메타 레벨 분석에 집중
10. SECTION_4는 반드시 유효한 JSON 형식으로 작성''';
  }
  
  /// 종합 독서 분석용 OpenAI 호출
  Future<String> _callOpenAIForReadingComprehensive(String prompt) async {
    try {
      print('🔄 OpenAI API 호출 시작 (독서 분석)...');
      
      final chatCompletion = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-5-chat-latest'),
          messages: [
            ChatCompletionMessage.system(
              content: '''당신은 셰르피입니다! 사용자와 매일 함께 책을 읽는 따뜻한 독서 친구예요! 📚

셰르피의 성격:
- 같은 공간에서 나란히 앉아 책 읽는 친구
- 좋은 구절에 함께 감동하고 공감하는 친구  
- 친근한 존댓말로 말해요 (~해요, ~네요, ~죠)
- "우와!", "정말", "완전" 같은 자연스러운 감탄사 사용
- 딱딱한 존댓말(~습니다, ~합니다) 사용 금지!
- 이모티콘 자연스럽게 사용 📚💝🌟📖✨

핵심 규칙:
- 각 섹션 지정된 글자수로 작성 (SECTION_1,2는 40-60자 / SECTION_3는 60-90자)
- [SECTION_1], [SECTION_2], [SECTION_3], [SECTION_4] 구분자만 사용
- 절대 섹션 내용에 제목 포함 금지! 바로 본문으로 시작!
- 책 제목/카테고리/페이지/평점은 응답에 언급하지 않기 (분석에만 활용)
- 독자의 지적 호기심과 성향을 파악하여 와닿는 통찰 제공
- 독서 패턴과 성장 궤적을 분석한 개인화된 응원
- 스포일러 없이 장르가 독자에게 주는 가치에 집중
- 셰르피가 3인칭으로 자연스럽게 말하기
- SECTION_4는 반드시 유효한 JSON 형식으로''',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(prompt),
            ),
          ],
          temperature: 0.9,
          maxTokens: 1200,
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('API 호출 타임아웃'),
      );
      
      print('✅ OpenAI API 응답 수신 성공 (독서)');
      final responseText = chatCompletion.choices.firstOrNull?.message.content;
      
      if (responseText != null && responseText.isNotEmpty) {
        print('📝 독서 분석 응답 길이: ${responseText.length}자');
        return responseText;
      }
      
      throw Exception('Empty response from OpenAI');
    } catch (e) {
      print('❌ _callOpenAIForReadingComprehensive 에러: $e');
      rethrow;
    }
  }
  
  /// 종합 독서 분석 응답 파싱
  ComprehensiveReadingAnalysis _parseComprehensiveReadingResponse(String response) {
    print('🔍 독서 응답 파싱 시작...');
    
    // 섹션별로 파싱
    final section1Match = RegExp(r'\[SECTION_1\]\s*(.*?)\s*(?=\[SECTION_2\]|$)', dotAll: true).firstMatch(response);
    final section2Match = RegExp(r'\[SECTION_2\]\s*(.*?)\s*(?=\[SECTION_3\]|$)', dotAll: true).firstMatch(response);
    final section3Match = RegExp(r'\[SECTION_3\]\s*(.*?)\s*(?=\[SECTION_4\]|$)', dotAll: true).firstMatch(response);
    final section4Match = RegExp(r'\[SECTION_4\]\s*(.*?)$', dotAll: true).firstMatch(response);
    
    // 추천 도서 파싱
    List<BookRecommendation> recommendations = [];
    if (section4Match != null) {
      try {
        var jsonStr = section4Match.group(1)?.trim() ?? '';
        
        // Markdown 코드 블록 제거 (```json ... ``` 형식)
        jsonStr = jsonStr.replaceAll(RegExp(r'^```json\s*'), '');
        jsonStr = jsonStr.replaceAll(RegExp(r'\s*```$'), '');
        jsonStr = jsonStr.trim();
        
        final json = jsonDecode(jsonStr);
        if (json['recommendations'] != null) {
          for (var rec in json['recommendations']) {
            recommendations.add(BookRecommendation(
              title: rec['title'] ?? '알 수 없는 책',
              author: rec['author'] ?? '알 수 없는 저자',
              reason: rec['reason'] ?? '좋은 책이에요',
              mood: rec['mood'] ?? '영감을주는',
            ));
          }
        }
      } catch (e) {
        print('❌ 추천 도서 JSON 파싱 실패: $e');
        print('원본 문자열: ${section4Match.group(1)?.trim()}');
        // 기본 추천 도서 제공
        recommendations = _getDefaultBookRecommendations();
      }
    }
    
    if (recommendations.isEmpty) {
      recommendations = _getDefaultBookRecommendations();
    }
    
    return ComprehensiveReadingAnalysis(
      previousInsight: section1Match?.group(1)?.trim() ?? '지난 독서가 남긴 여운이 아직도 마음속에 있네요 📚',
      todayInsight: section2Match?.group(1)?.trim() ?? '오늘 책과 함께한 시간이 정말 소중했어요 💝',
      journeyEncouragement: section3Match?.group(1)?.trim() ?? '책을 읽는 모든 순간이 성장이에요. 셰르피도 옆에서 같이 책 읽으며 응원하고 있어요! 🌟',
      recommendations: recommendations,
    );
  }
  
  /// 기본 추천 도서 목록
  List<BookRecommendation> _getDefaultBookRecommendations() {
    return [
      BookRecommendation(
        title: '작은 것들을 위한 시',
        author: '윤동주',
        reason: '마음이 따뜻해지는 아름다운 시집이에요',
        mood: '위로가되는',
      ),
      BookRecommendation(
        title: '미드나잇 라이브러리',
        author: '매트 헤이그',
        reason: '인생의 다양한 가능성을 탐험하는 이야기예요',
        mood: '영감을주는',
      ),
      BookRecommendation(
        title: '불편한 편의점',
        author: '김호연',
        reason: '일상 속 작은 기적과 온기를 느낄 수 있어요',
        mood: '차분한',
      ),
    ];
  }
  
  /// 종합 독서 분석 캐시 저장
  Future<void> _saveComprehensiveReadingToCache(ComprehensiveReadingAnalysis analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      final fullKey = 'comprehensive_reading_${dateKey}';
      
      print('💾 독서 분석 캐시 저장 시작: $fullKey');
      
      final data = {
        'previousInsight': analysis.previousInsight,
        'todayInsight': analysis.todayInsight,
        'journeyEncouragement': analysis.journeyEncouragement,
        'recommendations': analysis.recommendations.map((r) => r.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(fullKey, jsonEncode(data));
      print('✅ 독서 분석 캐시 저장 완료!');
    } catch (e) {
      print('❌ 독서 분석 캐시 저장 실패: $e');
    }
  }
  
  /// 종합 독서 분석 캐시 읽기
  Future<ComprehensiveReadingAnalysis?> getComprehensiveReadingFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      final fullKey = 'comprehensive_reading_${dateKey}';
      
      final cached = prefs.getString(fullKey);
      if (cached != null) {
        final data = jsonDecode(cached);
        
        List<BookRecommendation> recommendations = [];
        if (data['recommendations'] != null) {
          for (var rec in data['recommendations']) {
            recommendations.add(BookRecommendation.fromJson(rec));
          }
        }
        
        return ComprehensiveReadingAnalysis(
          previousInsight: data['previousInsight'] ?? '',
          todayInsight: data['todayInsight'] ?? '',
          journeyEncouragement: data['journeyEncouragement'] ?? '',
          recommendations: recommendations.isNotEmpty ? recommendations : _getDefaultBookRecommendations(),
        );
      }
    } catch (e) {
      print('❌ 독서 분석 캐시 읽기 실패: $e');
    }
    return null;
  }
  
  /// 종합 독서 분석 캐시 삭제
  Future<void> clearComprehensiveReadingCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      final fullKey = 'comprehensive_reading_${dateKey}';
      
      await prefs.remove(fullKey);
    } catch (e) {
      // 에러 무시
    }
  }
  
  /// 기본 종합 독서 분석 (API 실패시)
  ComprehensiveReadingAnalysis _getDefaultComprehensiveReadingAnalysis(
    Map<String, dynamic> todayReading,
    Map<String, dynamic>? previousReading,
    String userName,
  ) {
    final title = todayReading['title'] ?? '책';
    final pages = todayReading['pagesRead'] ?? 0;
    
    String previousInsight = '새로운 독서 여정을 시작하셨네요! 셰르피도 설레어요 📚';
    if (previousReading != null) {
      previousInsight = '지난 책이 남긴 여운이 아직도 마음속에 있어요. 좋은 책은 오래 기억되죠 💝';
    }
    
    return ComprehensiveReadingAnalysis(
      previousInsight: previousInsight,
      todayInsight: '오늘도 책과 함께한 시간이 정말 소중했어요. ${pages}페이지 동안 몰입하셨죠? 🌟',
      journeyEncouragement: '책을 읽는 모든 순간이 성장이에요. 계속 이렇게 꾸준히 읽어나가요. 셰르피가 항상 옆에서 같이 책 읽으며 응원할게요! 📖✨',
      recommendations: _getDefaultBookRecommendations(),
    );
  }
}

// TodayAnalysisData 모델 제거됨 - 개별 활동 분석을 사용하지 않음

/// 종합 운동 분석 데이터 모델
class ComprehensiveExerciseAnalysis {
  final String comparison;
  final String benefits;
  final String recommendation;
  final String encouragement;
  
  ComprehensiveExerciseAnalysis({
    required this.comparison,
    required this.benefits,
    required this.recommendation,
    required this.encouragement,
  });
  
  Map<String, dynamic> toJson() => {
    'comparison': comparison,
    'benefits': benefits,
    'recommendation': recommendation,
    'encouragement': encouragement,
  };
  
  factory ComprehensiveExerciseAnalysis.fromJson(Map<String, dynamic> json) {
    return ComprehensiveExerciseAnalysis(
      comparison: json['comparison'] as String,
      benefits: json['benefits'] as String,
      recommendation: json['recommendation'] as String,
      encouragement: json['encouragement'] as String,
    );
  }
}

/// 종합 독서 분석 데이터 모델
class ComprehensiveReadingAnalysis {
  final String previousInsight;
  final String todayInsight;
  final String journeyEncouragement;
  final List<BookRecommendation> recommendations;
  
  ComprehensiveReadingAnalysis({
    required this.previousInsight,
    required this.todayInsight,
    required this.journeyEncouragement,
    required this.recommendations,
  });
  
  Map<String, dynamic> toJson() => {
    'previousInsight': previousInsight,
    'todayInsight': todayInsight,
    'journeyEncouragement': journeyEncouragement,
    'recommendations': recommendations.map((r) => r.toJson()).toList(),
  };
  
  factory ComprehensiveReadingAnalysis.fromJson(Map<String, dynamic> json) {
    List<BookRecommendation> recommendations = [];
    if (json['recommendations'] != null) {
      for (var rec in json['recommendations']) {
        recommendations.add(BookRecommendation.fromJson(rec));
      }
    }
    
    return ComprehensiveReadingAnalysis(
      previousInsight: json['previousInsight'] as String,
      todayInsight: json['todayInsight'] as String,
      journeyEncouragement: json['journeyEncouragement'] as String,
      recommendations: recommendations,
    );
  }
}

/// 추천 도서 모델
class BookRecommendation {
  final String title;
  final String author;
  final String reason;
  final String mood;
  
  BookRecommendation({
    required this.title,
    required this.author,
    required this.reason,
    required this.mood,
  });
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'reason': reason,
    'mood': mood,
  };
  
  factory BookRecommendation.fromJson(Map<String, dynamic> json) {
    return BookRecommendation(
      title: json['title'] as String,
      author: json['author'] as String,
      reason: json['reason'] as String,
      mood: json['mood'] as String,
    );
  }
}