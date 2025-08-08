import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';

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
        model: 'gemini-2.0-flash-exp', // Latest available model
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          maxOutputTokens: 300,  // 짧은 응답으로 제한
        ),
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
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final responseText = response.text;
      
      if (responseText != null && responseText.isNotEmpty) {
        final processedResponse = _processSimpleResponse(responseText);
        print('✅ Gemini 응답 생성 완료: ${processedResponse.length > 30 ? processedResponse.substring(0, 30) : processedResponse}...');
        return processedResponse;
      } else {
        print('⚠️ Gemini 응답이 비어있습니다. 폴백 사용.');
        return await _fallbackSource.getDialogue(context, userContext, gameContext);
      }
      
    } catch (e) {
      print('❌ Gemini API 에러: $e');
      return await _fallbackSource.getDialogue(context, userContext, gameContext);
    }
  }
  
  /// 🎯 단순화된 프롬프트 생성
  String _buildSimplePrompt(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    final personalityType = gameContext?['personalityType'] ?? '균형형';
    final userName = gameContext?['userPreferredName'] ?? '친구';
    
    return '''당신은 '셰르피'입니다. 사용자의 성장을 함께하는 AI 동반자입니다.
    
사용자 정보:
- 이름: $userName
- 성격 유형: $personalityType
- 상황: ${context.name}

다음 지침을 따라주세요:
1. 따뜻하고 친근한 톤으로 대화하세요
2. 2-3문장으로 간결하게 답변하세요  
3. 이모지는 1-2개만 사용하세요
4. 사용자를 격려하고 동기부여하세요

한국어로 응답해주세요.''';
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