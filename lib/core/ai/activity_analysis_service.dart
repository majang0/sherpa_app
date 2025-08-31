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
  
  /// 🏃 운동 분석
  Future<String> analyzeExercise({
    required Map<String, dynamic> todayExercise,
    Map<String, dynamic>? previousExercise,
    required String userName,
  }) async {
    try {
      // 에뮬레이터에서 네트워크 문제가 있을 경우 기본 메시지 사용
      if (Platform.isAndroid) {
        // 간단한 연결 테스트
        try {
          await http.head(Uri.parse('https://api.openai.com')).timeout(
            const Duration(seconds: 2),
          );
        } catch (e) {
          final defaultMsg = _getDefaultExerciseAnalysis(todayExercise, userName);
          await _saveToCache('exercise_analysis', defaultMsg, todayExercise);
          return defaultMsg;
        }
      }
      
      final prompt = AnalysisPromptTemplates.generateExerciseAnalysisPrompt(
        todayExercise: todayExercise,
        previousExercise: previousExercise,
        userName: userName,
      );
      
      final response = await _callOpenAI(prompt);
      
      // 캐시에 저장
      await _saveToCache('exercise_analysis', response, todayExercise);
      
      return response;
    } catch (e) {
      final defaultMsg = _getDefaultExerciseAnalysis(todayExercise, userName);
      await _saveToCache('exercise_analysis', defaultMsg, todayExercise);
      return defaultMsg;
    }
  }
  
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
3. 친근하고 따뜻한 친구처럼, 함께 운동하는 느낌으로
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
- 친근하고 따뜻한 운동 친구처럼 말해요
- "우와!", "진짜", "완전" 같은 자연스러운 감탄사 사용
- 정말 옆에서 같이 운동하면서 대화하는 것처럼 표현
- 함께 땀 흘리고, 함께 숨 쉬고, 함께 힘내는 친구
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
  
  /// 📚 독서 분석
  Future<String> analyzeReading({
    required Map<String, dynamic> todayReading,
    Map<String, dynamic>? previousReading,
    required String userName,
  }) async {
    try {
      final prompt = AnalysisPromptTemplates.generateReadingAnalysisPrompt(
        todayReading: todayReading,
        previousReading: previousReading,
        userName: userName,
      );
      
      final response = await _callOpenAI(prompt);
      
      // 캐시에 저장
      await _saveToCache('reading_analysis', response, todayReading);
      
      return response;
    } catch (e) {
      return _getDefaultReadingAnalysis(todayReading, userName);
    }
  }
  
  /// 📝 일기 분석
  Future<String> analyzeDiary({
    required Map<String, dynamic> todayDiary,
    Map<String, dynamic>? previousDiary,
    required String userName,
  }) async {
    try {
      final prompt = AnalysisPromptTemplates.generateDiaryAnalysisPrompt(
        todayDiary: todayDiary,
        previousDiary: previousDiary,
        userName: userName,
      );
      
      final response = await _callOpenAI(prompt);
      
      // 캐시에 저장
      await _saveToCache('diary_analysis', response, todayDiary);
      
      return response;
    } catch (e) {
      return _getDefaultDiaryAnalysis(todayDiary, userName);
    }
  }
  
  /// 🌟 종합 요약 분석
  Future<String> generateSummaryAnalysis({
    required Map<String, dynamic> todayExercise,
    required Map<String, dynamic> todayReading,
    required Map<String, dynamic> todayDiary,
    required String userName,
  }) async {
    try {
      final prompt = AnalysisPromptTemplates.generateSummaryAnalysisPrompt(
        todayExercise: todayExercise,
        todayReading: todayReading,
        todayDiary: todayDiary,
        userName: userName,
      );
      
      // 종합 분석은 더 긴 응답이 필요하므로 직접 처리
      final response = await _callOpenAIForSummary(prompt);
      
      // 캐시에 저장
      await _saveToCache('summary_analysis', response, {
        'exercise': todayExercise,
        'reading': todayReading,
        'diary': todayDiary,
      });
      
      return response;
    } catch (e) {
      return _getDefaultSummaryAnalysis(todayExercise, todayReading, todayDiary, userName);
    }
  }
  
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
              - 항상 친근하고 다정한 말투 사용
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
  
  /// 종합 분석용 OpenAI 호출 (글자 수 제한 없음)
  Future<String> _callOpenAIForSummary(String prompt) async {
    try {
      final client = OpenAIClient(
        apiKey: ApiConfig.openAIApiKey,
        baseUrl: 'https://api.openai.com/v1',
      );
      
      final chatCompletion = await client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-5-chat-latest'),
          messages: [
            ChatCompletionMessage.system(
              content: '당신은 셰르피입니다. 사용자의 하루 활동을 종합적으로 분석하고 깊이 있는 통찰을 제공하는 AI 동반자입니다.',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(prompt),
            ),
          ],
          temperature: 0.8,
          maxTokens: 500,  // 종합 분석은 충분히 긴 응답 허용
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('API 호출 타임아웃'),
      );
      
      final responseText = chatCompletion.choices.firstOrNull?.message.content;
      
      if (responseText != null && responseText.isNotEmpty) {
        // 종합 분석은 마크다운만 제거하고 글자 수 제한 없음
        return _processResponseForSummary(responseText);
      }
      
      throw Exception('Empty response from OpenAI');
    } catch (e) {
      rethrow;
    }
  }
  
  /// 종합 분석용 응답 후처리 (글자 수 제한 없음)
  String _processResponseForSummary(String rawResponse) {
    String processed = rawResponse.trim();
    
    // 마크다운 제거
    processed = processed.replaceAllMapped(
      RegExp(r'\*\*([^\*]+)\*\*'), 
      (match) => match.group(1) ?? ''
    );
    processed = processed.replaceAllMapped(
      RegExp(r'\*([^\*]+)\*'), 
      (match) => match.group(1) ?? ''
    );
    processed = processed.replaceAllMapped(
      RegExp(r'__([^_]+)__'), 
      (match) => match.group(1) ?? ''
    );
    processed = processed.replaceAllMapped(
      RegExp(r'_([^_]+)_'), 
      (match) => match.group(1) ?? ''
    );
    processed = processed.replaceAll(RegExp(r'#{1,6}\s+'), '');
    processed = processed.replaceAll(RegExp(r'^[\-\*]\s+', multiLine: true), '');
    
    // 종합 분석은 글자 수 제한 없음
    return processed;
  }
  
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
  
  /// 캐시에 저장
  Future<void> _saveToCache(String key, String content, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // DateTime 객체를 문자열로 변환하는 헬퍼 함수
      Map<String, dynamic> sanitizeData(Map<String, dynamic> input) {
        final sanitized = <String, dynamic>{};
        input.forEach((key, value) {
          if (value is DateTime) {
            sanitized[key] = value.toIso8601String();
          } else if (value is Map<String, dynamic>) {
            sanitized[key] = sanitizeData(value);
          } else if (value is List) {
            sanitized[key] = value.map((item) {
              if (item is DateTime) {
                return item.toIso8601String();
              } else if (item is Map<String, dynamic>) {
                return sanitizeData(item);
              }
              return item;
            }).toList();
          } else {
            sanitized[key] = value;
          }
        });
        return sanitized;
      }
      
      final cacheData = {
        'content': content,
        'data': sanitizeData(data),  // DateTime 객체를 안전하게 변환
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final dateKey = _getTodayDateKey();
      final fullKey = 'analysis_${dateKey}_$key';
      
      await prefs.setString(fullKey, jsonEncode(cacheData));
    } catch (e) {
    }
  }
  
  /// 캐시에서 읽기
  Future<String?> getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      final fullKey = 'analysis_${dateKey}_$key';
      
      final cached = prefs.getString(fullKey);
      if (cached != null) {
        final cacheData = jsonDecode(cached);
        return cacheData['content'] as String;
      }
    } catch (e) {
    }
    return null;
  }
  
  /// 오늘 날짜 키 생성
  String _getTodayDateKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
  }
  
  /// 오늘의 캐시 클리어
  Future<void> clearTodayCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      
      // 오늘의 모든 분석 캐시 삭제
      final keys = ['exercise_analysis', 'reading_analysis', 'diary_analysis', 'summary_analysis'];
      for (final key in keys) {
        final fullKey = 'analysis_${dateKey}_$key';
        await prefs.remove(fullKey);
      }
      
      // 종합 운동 분석 캐시도 삭제
      final comprehensiveKey = 'comprehensive_exercise_${dateKey}';
      await prefs.remove(comprehensiveKey);
    } catch (e) {
    }
  }
  
  /// 모든 분석이 완료되었는지 확인
  Future<bool> areAllAnalysesComplete() async {
    final exerciseAnalysis = await getFromCache('exercise_analysis');
    final readingAnalysis = await getFromCache('reading_analysis');
    final diaryAnalysis = await getFromCache('diary_analysis');
    final summaryAnalysis = await getFromCache('summary_analysis');
    
    return exerciseAnalysis != null && 
           readingAnalysis != null && 
           diaryAnalysis != null &&
           summaryAnalysis != null;
  }
  
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
  
  /// 오늘의 모든 분석 결과 가져오기
  Future<TodayAnalysisData?> getTodayAnalyses() async {
    final exerciseAnalysis = await getFromCache('exercise_analysis');
    final readingAnalysis = await getFromCache('reading_analysis');
    final diaryAnalysis = await getFromCache('diary_analysis');
    final summaryAnalysis = await getFromCache('summary_analysis');
    
    if (exerciseAnalysis != null && 
        readingAnalysis != null && 
        diaryAnalysis != null &&
        summaryAnalysis != null) {
      return TodayAnalysisData(
        exerciseAnalysis: exerciseAnalysis,
        readingAnalysis: readingAnalysis,
        diaryAnalysis: diaryAnalysis,
        summaryAnalysis: summaryAnalysis,
        createdAt: DateTime.now(),
      );
    }
    
    return null;
  }
  
  // 기본 분석 메시지 (API 실패 시 사용)
  String _getDefaultExerciseAnalysis(Map<String, dynamic> data, String userName) {
    final type = data['type'] ?? '운동';
    final duration = data['duration'] ?? 0;
    final calories = data['calories'] ?? 0;
    
    return '''오늘 $type을(를) ${duration}분 동안 하셨네요! 
${calories}kcal를 소모하셨어요! 💪
꾸준한 운동이 $userName님을 더 건강하게 만들고 있어요.
오늘도 수고 많으셨어요!''';
  }
  
  String _getDefaultReadingAnalysis(Map<String, dynamic> data, String userName) {
    final title = data['title'] ?? '책';
    final pages = data['pages'] ?? 0;
    final category = data['category'] ?? '독서';
    
    return '''『$title』을(를) ${pages}페이지 읽으셨군요! 📚
$category 분야의 지식을 쌓는 유익한 시간이 되셨길 바라요.
$userName님의 꾸준한 독서 습관이 정말 멋져요!''';
  }
  
  String _getDefaultDiaryAnalysis(Map<String, dynamic> data, String userName) {
    final mood = data['mood'] ?? '평온한';
    
    return '''오늘 $userName님의 기분이 $mood 상태시군요! 
하루를 기록하는 습관이 $userName님의 성장에 큰 도움이 될 거예요.
셰르피가 늘 곁에서 응원할게요! 💝''';
  }
  
  String _getDefaultSummaryAnalysis(
    Map<String, dynamic> exercise,
    Map<String, dynamic> reading,
    Map<String, dynamic> diary,
    String userName,
  ) {
    final exerciseType = exercise['type'] ?? '운동';
    final readingCategory = reading['category'] ?? '독서';
    final mood = diary['mood'] ?? '평온한';
    
    return '''오늘 $exerciseType, $readingCategory 독서, 그리고 $mood 감정을 기록하셨네요! 🌟

몸과 마음, 지성을 모두 돌보는 $userName님의 균형잡힌 하루가 정말 인상적이에요.
이런 꾸준한 노력이 모여 더 나은 내일을 만들어갈 거예요.
$userName님과 함께하는 매일이 셰르피에게도 큰 기쁨이에요. 
오늘도 정말 수고 많으셨어요! 💪📚💝''';
  }
}

/// 오늘의 분석 데이터 모델
class TodayAnalysisData {
  final String exerciseAnalysis;
  final String readingAnalysis;
  final String diaryAnalysis;
  final String summaryAnalysis;
  final DateTime createdAt;
  
  TodayAnalysisData({
    required this.exerciseAnalysis,
    required this.readingAnalysis,
    required this.diaryAnalysis,
    required this.summaryAnalysis,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'exerciseAnalysis': exerciseAnalysis,
    'readingAnalysis': readingAnalysis,
    'diaryAnalysis': diaryAnalysis,
    'summaryAnalysis': summaryAnalysis,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory TodayAnalysisData.fromJson(Map<String, dynamic> json) {
    return TodayAnalysisData(
      exerciseAnalysis: json['exerciseAnalysis'] as String,
      readingAnalysis: json['readingAnalysis'] as String,
      diaryAnalysis: json['diaryAnalysis'] as String,
      summaryAnalysis: json['summaryAnalysis'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

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