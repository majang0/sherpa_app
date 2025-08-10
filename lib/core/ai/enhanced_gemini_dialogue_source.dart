import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/activity_prompt_templates.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';

/// 🧠 단순화된 Gemini AI 대화 소스
/// 
/// Smart Sherpi Manager에 최적화된 간단하고 효율적인 AI 대화 생성기
class EnhancedGeminiDialogueSource implements SherpiDialogueSource {
  late final GenerativeModel _model;
  final StaticDialogueSource _fallbackSource = StaticDialogueSource();
  
  /// 단순화된 Gemini 모델 초기화
  EnhancedGeminiDialogueSource() {
    try {
      final apiKey = ApiConfig.finalApiKey;
      print('🧠 단순 Gemini 모델 초기화 중...');
      
      _model = GenerativeModel(
        model: ApiConfig.geminiModel, // 설정 파일에서 모델 가져오기
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          maxOutputTokens: 1000,  // 충분한 토큰 수
          topK: 40,
          topP: 0.95,
        ),
        // Safety settings to avoid blocking
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        ],
      );
      
      print('✅ 단순 Gemini 모델 초기화 완료!');
    } catch (e) {
      print('❌ Gemini 모델 초기화 실패: $e');
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
      if (!ApiConfig.isApiKeyValid) {
        print('⚠️ API 키가 유효하지 않습니다. 정적 대화를 사용합니다.');
        return await _fallbackSource.getDialogue(context, userContext, gameContext);
      }
      
      print('🧠 Gemini AI 응답 생성 중... Context: ${context.name}');
      
      // 단순화된 프롬프트 생성
      final prompt = _buildSimplePrompt(context, userContext, gameContext);
      
      // Chat 세션 방식으로 변경하여 role 에러 해결
      try {
        // 방법 1: Chat 세션 사용
        final chat = _model.startChat(history: []);
        final response = await chat.sendMessage(Content.text(prompt));
        
        // 안전한 텍스트 추출
        String? responseText;
        
        if (response.text != null && response.text!.isNotEmpty) {
          responseText = response.text!;
        } else {
          // 대안 방법: candidates에서 직접 추출
          if (response.candidates.isNotEmpty) {
            final candidate = response.candidates.first;
            if (candidate.content.parts.isNotEmpty) {
              for (final part in candidate.content.parts) {
                if (part is TextPart && part.text.isNotEmpty) {
                  responseText = part.text;
                  break;
                }
              }
            }
          }
        }
        
        if (responseText != null && responseText.isNotEmpty) {
          final processedResponse = _processSimpleResponse(responseText);
          print('✅ Gemini 응답 생성 완료: ${processedResponse.length > 30 ? processedResponse.substring(0, 30) : processedResponse}...');
          return processedResponse;
        } else {
          print('⚠️ Gemini 응답이 비어있습니다. 폴백 사용.');
          return await _fallbackSource.getDialogue(context, userContext, gameContext);
        }
      } catch (chatError) {
        // Chat 방식 실패 시 일반 방식으로 재시도
        print('⚠️ Chat 세션 실패, 일반 방식으로 재시도: $chatError');
        
        try {
          // 방법 2: Content list 직접 전달
          final contents = [
            Content('user', [TextPart(prompt)])
          ];
          final response = await _model.generateContent(contents);
          
          if (response.text != null && response.text!.isNotEmpty) {
            final processedResponse = _processSimpleResponse(response.text!);
            print('✅ Gemini 응답 생성 완료 (대체 방식)');
            return processedResponse;
          }
        } catch (e) {
          print('⚠️ 대체 방식도 실패: $e');
        }
        
        print('⚠️ 모든 방식 실패. 폴백 사용.');
        return await _fallbackSource.getDialogue(context, userContext, gameContext);
      }
      
    } catch (e) {
      print('❌ Gemini API 에러: $e');
      // 더 자세한 에러 정보 출력
      if (e.toString().contains('FormatException') || 
          e.toString().contains('Unhandled format')) {
        print('💡 이것은 SDK 호환성 문제일 수 있습니다. 폴백으로 전환합니다.');
      }
      return await _fallbackSource.getDialogue(context, userContext, gameContext);
    }
  }
  
  /// 🎯 Phase 2: 활동별 전문 프롬프트 생성
  String _buildSimplePrompt(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    // 성격 타입 파싱
    final personalityTypeStr = gameContext?['personalityType'] ?? '균형형';
    final personality = _parsePersonalityType(personalityTypeStr);
    
    // 활동별 데이터가 있는지 확인
    final activityData = userContext?['activityData'] as Map<String, dynamic>?;
    
    // 🎯 Phase 2: 활동별 전문 프롬프트 사용
    if (activityData != null) {
      switch (context) {
        case SherpiContext.exerciseComplete:
          return ActivityPromptTemplates.generateExercisePrompt(
            activityData: activityData,
            userContext: userContext ?? {},
            gameContext: gameContext ?? {},
            personality: personality,
          );
          
        case SherpiContext.studyComplete:
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
  
  /// 📝 단순한 응답 후처리
  String _processSimpleResponse(String rawResponse) {
    String processed = rawResponse.trim();
    
    // 길이 제한 (150자로 제한)
    if (processed.length > 150) {
      processed = '${processed.substring(0, 147)}...';
    }
    
    // 부적절한 표현 필터링
    final prohibitedPhrases = [
      '당신은 게으러', '노력이 부족', '실패할 거', '어려울 것 같', '포기하',
      '별로야', '그럴 줄 알았어', '역시 안 되네', '무리였어'
    ];
    
    for (final phrase in prohibitedPhrases) {
      if (processed.contains(phrase)) {
        return '우리 함께 차근차근 해나가요! 😊';
      }
    }
    
    return processed;
  }
}