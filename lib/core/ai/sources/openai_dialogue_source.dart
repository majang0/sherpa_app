import 'dart:async';
import 'dart:io';
import 'package:openai_dart/openai_dart.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/activity_prompt_templates.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';

/// 🧠 OpenAI GPT-5 대화 소스
/// 
/// Smart Sherpi Manager에 최적화된 OpenAI GPT-5 대화 생성기
class OpenAIDialogueSource implements SherpiDialogueSource {
  late final OpenAIClient _client;
  final StaticDialogueSource _fallbackSource = StaticDialogueSource();
  
  /// OpenAI GPT-5 모델 초기화
  OpenAIDialogueSource() {
    try {
      final apiKey = ApiConfig.openAIApiKey;
      
      _client = OpenAIClient(
        apiKey: apiKey,
        // GPT-5 모델 사용
        baseUrl: 'https://api.openai.com/v1',
      );
      
      print('🤖 OpenAI GPT-5 클라이언트 초기화 성공');
    } catch (e) {
      print('❌ OpenAI 클라이언트 초기화 실패: $e');
      rethrow;
    }
  }
  
  @override
  Future<String> getDialogue(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    try {
      // API 키 유효성 검사
      if (!ApiConfig.isOpenAIApiKeyValid) {
        print('⚠️ OpenAI API 키가 유효하지 않음, 정적 메시지 사용');
        return await _fallbackSource.getDialogue(context, userContext, gameContext);
      }
      
      // 프롬프트 생성
      final prompt = _buildPrompt(context, userContext, gameContext);
      
      try {
        // GPT-5 모델을 사용하여 대화 생성
        final chatCompletion = await _client.createChatCompletion(
          request: CreateChatCompletionRequest(
            model: ChatCompletionModel.modelId('gpt-5-chat-latest'), // GPT-5 사용
            messages: [
              ChatCompletionMessage.system(
                content: '당신은 셰르피입니다. 사용자의 성장을 함께하는 친근하고 따뜻한 AI 동반자입니다.',
              ),
              ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(prompt),
              ),
            ],
            temperature: 0.8,
            maxTokens: 150,
            topP: 0.95,
            frequencyPenalty: 0.0,
            presencePenalty: 0.0,
          ),
        );
        
        // 응답 추출
        final responseText = chatCompletion.choices.firstOrNull?.message.content;
        
        if (responseText != null && responseText.isNotEmpty) {
          final processedResponse = _processResponse(responseText);
          print('✅ OpenAI GPT-5 응답 생성 성공');
          return processedResponse;
        } else {
          print('⚠️ OpenAI 응답이 비어있음, 정적 메시지 사용');
          return await _fallbackSource.getDialogue(context, userContext, gameContext);
        }
      } catch (apiError) {
        print('❌ OpenAI API 호출 실패: $apiError');
        
        // API 오류 상세 정보 출력
        if (apiError is HttpException) {
          print('  - HTTP 오류: ${apiError.message}');
        } else if (apiError.toString().contains('statusCode')) {
          print('  - API 오류: $apiError');
        }
        
        return await _fallbackSource.getDialogue(context, userContext, gameContext);
      }
    } catch (e) {
      print('❌ OpenAI 대화 생성 중 오류: $e');
      return await _fallbackSource.getDialogue(context, userContext, gameContext);
    }
  }
  
  /// 🎯 활동별 전문 프롬프트 생성
  String _buildPrompt(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    // 성격 타입 파싱
    final personalityTypeStr = gameContext?['personalityType'] ?? '균형형';
    final personality = _parsePersonalityType(personalityTypeStr);
    
    // 활동별 데이터가 있는지 확인
    final activityData = userContext?['activityData'] as Map<String, dynamic>?;
    
    // 🎯 활동별 전문 프롬프트 사용
    if (activityData != null) {
      switch (context) {
        case SherpiContext.exerciseComplete:
          return ActivityPromptTemplates.generateExercisePrompt(
            activityData: activityData,
            userContext: userContext ?? {},
            gameContext: gameContext ?? {},
            personality: personality,
          );
          
        case SherpiContext.readingComplete:
          return ActivityPromptTemplates.generateStudyPrompt(
            activityData: activityData,
            userContext: userContext ?? {},
            gameContext: gameContext ?? {},
            personality: personality,
          );
          
        case SherpiContext.diaryWritten:
          return ActivityPromptTemplates.generateDiaryPrompt(
            activityData: activityData,
            userContext: userContext ?? {},
            gameContext: gameContext ?? {},
            personality: personality,
          );
          
        case SherpiContext.questComplete:
          return ActivityPromptTemplates.generateQuestPrompt(
            activityData: activityData,
            userContext: userContext ?? {},
            gameContext: gameContext ?? {},
            personality: personality,
          );
          
        case SherpiContext.climbingSuccess:
          final isSuccess = activityData['isSuccess'] ?? false;
          return ActivityPromptTemplates.generateClimbingPrompt(
            activityData: activityData,
            userContext: userContext ?? {},
            gameContext: gameContext ?? {},
            personality: personality,
            isSuccess: isSuccess,
          );
          
        case SherpiContext.meetingJoined:
          return ActivityPromptTemplates.generateMeetingPrompt(
            activityData: activityData,
            userContext: userContext ?? {},
            gameContext: gameContext ?? {},
            personality: personality,
          );
          
        default:
          // 활동별 프롬프트가 없는 경우 기본 프롬프트 사용
          break;
      }
    }
    
    // 기본 프롬프트 (활동별 데이터가 없는 경우)
    final userName = gameContext?['userPreferredName'] ?? '친구';
    
    return '''당신은 '셰르피'입니다. $userName님의 성장을 함께하는 AI 동반자입니다.
    
사용자 정보:
- 이름: $userName
- 성격 유형: $personalityTypeStr
- 상황: ${context.name}

다음 지침을 따라주세요:
1. $userName님을 이름으로 부르며 따뜻하고 친근하게 대화하세요
2. 2-3문장으로 간결하게 답변하세요  
3. 이모지는 1-2개만 사용하세요
4. $userName님을 격려하고 동기부여하세요

한국어로 응답해주세요.''';
  }
  
  /// 성격 타입 문자열을 enum으로 변환
  SherpiPersonalityType _parsePersonalityType(String typeStr) {
    switch (typeStr) {
      case '활발형':
      case 'energetic':
        return SherpiPersonalityType.energetic;
      case '차분형':
      case 'calm':
        return SherpiPersonalityType.calm;
      case '유머형':
      case 'humorous':
        return SherpiPersonalityType.humorous;
      case '진지형':
      case 'serious':
        return SherpiPersonalityType.serious;
      default:
        return SherpiPersonalityType.balanced;
    }
  }
  
  /// 📝 응답 후처리
  String _processResponse(String rawResponse) {
    String processed = rawResponse.trim();
    
    // 길이 제한 (150자로 제한)
    if (processed.length > 150) {
      processed = '${processed.substring(0, 147)}...';
    }
    
    // 부적절한 표현 필터링
    final prohibitedPhrases = [
      '당신은 게을러', '노력이 부족', '실패할 거', '어려울 것 같', '포기하',
      '별로야', '그럴 줄 알았어', '역시 안 되네', '무리였어'
    ];
    
    for (final phrase in prohibitedPhrases) {
      if (processed.contains(phrase)) {
        return '우리 함께 차근차근 해나가요! 😊';
      }
    }
    
    return processed;
  }
  
  /// 리소스 정리
  void dispose() {
    // OpenAI 클라이언트는 특별한 정리가 필요 없음
    print('🔄 OpenAI 클라이언트 정리 완료');
  }
}