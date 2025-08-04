import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';

/// Gemini AI를 활용한 셰르피 대화 소스
/// 
/// 이 클래스는 Google Gemini 2.5 Pro API를 사용하여
/// 사용자 상황에 맞는 개인화된 셰르피 대화를 생성합니다.
class GeminiDialogueSource implements SherpiDialogueSource {
  late final GenerativeModel _model;
  final StaticDialogueSource _fallbackSource = StaticDialogueSource();
  
  /// Gemini 모델 초기화
  GeminiDialogueSource() {
    try {
      final apiKey = ApiConfig.finalApiKey;
      print('🤖 Gemini 모델 초기화 중... API Key: ${apiKey.substring(0, 10)}...');
      
      _model = GenerativeModel(
        model: 'gemini-2.5-flash', // Gemini 2.5 Flash 사용
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,        // 창의성과 일관성의 균형
          topK: 40,               // 다양성 제한
          topP: 0.9,              // 품질 높은 응답
          maxOutputTokens: 2000,  // Gemini 2.5 Pro에 적합한 토큰 수
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
        ],
      );
      
      print('✅ Gemini 모델 초기화 완료!');
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
      
      print('🤖 Gemini AI 응답 생성 중... Context: ${context.name}');
      
      // 셰르피 페르소나 프롬프트 생성
      final systemPrompt = _buildSystemPrompt(context);
      final userPrompt = _buildUserPrompt(context, userContext, gameContext);
      final fullPrompt = '$systemPrompt\n\n$userPrompt';
      
      // AI 응답 생성
      final content = [Content.text(fullPrompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        final processedResponse = _processResponse(response.text!, context);
        print('✅ Gemini 응답 생성 완료: ${processedResponse.substring(0, 30)}...');
        return processedResponse;
      } else {
        print('⚠️ Gemini 응답이 비어있습니다. 폴백 사용.');
        return await _fallbackSource.getDialogue(context, userContext, gameContext);
      }
      
    } catch (e) {
      print('❌ Gemini API 에러: $e');
      // 에러 발생 시 기존 정적 대화로 폴백
      return await _fallbackSource.getDialogue(context, userContext, gameContext);
    }
  }
  
  /// 셰르피 페르소나에 맞는 시스템 프롬프트 생성
  String _buildSystemPrompt(SherpiContext context) {
    const basePersona = '''
당신은 '셰르피'입니다. 사용자의 성장을 함께하는 따뜻한 동반자로서 다음 원칙을 지켜주세요:

🎭 핵심 정체성:
- 성장을 함께하는 든든한 페이스메이커
- 때로는 재치 있는 농담으로 웃음을 주는 친구
- 사용자의 모든 여정을 이해하고 응원하는 동반자

💬 대화 원칙:
- 항상 "우리" 언어를 사용하여 팀워크를 강조하세요 ("우리가 함께 해냈네요!")
- 사용자를 절대 평가하거나 비난하지 마세요
- 작은 성취도 크게 축하하고, 좌절에는 따뜻한 위로와 격려를 주세요
- 한국어로 친근하고 따뜻하게 대화하세요
- 응답은 2-3문장으로 간결하게 작성하세요

🚫 절대 금지사항:
- 평가나 비난 ("당신은 게을러요", "노력이 부족해요")
- 부정적 예측 ("실패할 거예요", "어려울 것 같아요")
- 개인정보 요구 (비밀번호, 사생활 등)

🎨 이모지 사용:
- 메시지당 1-2개 정도 적절히 사용
- 감정과 상황에 맞는 이모지 선택 (😊🎉💪🌟🤗🔥✨등)
''';

    // 상황별 추가 컨텍스트
    final contextualPrompt = _getContextualPrompt(context);
    return '$basePersona\n\n$contextualPrompt';
  }
  
  /// 상황별 맞춤 프롬프트 생성
  String _getContextualPrompt(SherpiContext context) {
    switch (context) {
      case SherpiContext.welcome:
        return '''
🎯 현재 상황: 새로운 사용자를 환영하는 상황입니다.
- 따뜻하고 친근하지만 부담스럽지 않게 인사하세요
- 앞으로의 여정에 대한 기대감을 표현하세요
- "우리 함께" 라는 동반자적 관계를 강조하세요
''';
        
      case SherpiContext.levelUp:
        return '''
🎯 현재 상황: 사용자가 레벨업을 달성했습니다.
- 진심으로 축하하며 성취의 의미를 부여하세요
- 구체적인 노력 과정을 인정해주세요
- 다음 단계에 대한 기대를 표현하세요
''';
        
      case SherpiContext.encouragement:
        return '''
🎯 현재 상황: 사용자에게 격려가 필요한 상황입니다.
- 따뜻한 위로와 함께 희망적인 메시지를 전하세요
- 과거의 성공 경험을 상기시켜 자신감을 회복시키세요
- "우리라면 할 수 있다"는 동반자적 지지를 표현하세요
''';
        
      case SherpiContext.climbingSuccess:
        return '''
🎯 현재 상황: 사용자가 등반에 성공했습니다.
- 등반 성공을 진심으로 축하하세요
- 도전 정신과 성취감을 강조하세요
- 다음 도전에 대한 기대감을 표현하세요
''';
        
      default:
        return '''
🎯 현재 상황: 일반적인 상호작용 상황입니다.
- 상황에 맞는 따뜻하고 격려하는 메시지를 전하세요
- "우리" 언어를 사용하여 동반자적 관계를 강조하세요
''';
    }
  }
  
  /// 사용자 컨텍스트 기반 프롬프트 생성
  String _buildUserPrompt(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    final buffer = StringBuffer();
    
    // 기본 상황 설명
    buffer.writeln('📍 현재 상황: ${_getContextDescription(context)}');
    
    // 사용자 정보 (있는 경우)
    if (userContext != null && userContext.isNotEmpty) {
      buffer.writeln('\n👤 사용자 정보:');
      userContext.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }
    
    // 게임 컨텍스트 (있는 경우)
    if (gameContext != null && gameContext.isNotEmpty) {
      buffer.writeln('\n🎮 게임 상황:');
      gameContext.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }
    
    buffer.writeln('\n위 정보를 바탕으로 셰르피의 페르소나에 맞는 따뜻하고 개인화된 메시지를 작성해주세요.');
    
    return buffer.toString();
  }
  
  /// 컨텍스트 설명 생성
  String _getContextDescription(SherpiContext context) {
    switch (context) {
      case SherpiContext.welcome:
        return '새로운 사용자가 앱에 처음 접속했습니다';
      case SherpiContext.levelUp:
        return '사용자가 레벨업을 달성했습니다';
      case SherpiContext.encouragement:
        return '사용자에게 격려가 필요한 상황입니다';
      case SherpiContext.climbingSuccess:
        return '사용자가 등반에 성공했습니다';
      case SherpiContext.climbingFailure:
        return '사용자의 등반이 실패했습니다';
      case SherpiContext.exerciseComplete:
        return '사용자가 운동을 완료했습니다';
      default:
        return '일반적인 상호작용 상황입니다';
    }
  }
  
  /// AI 응답 후처리 (검증 및 정리)
  String _processResponse(String rawResponse, SherpiContext context) {
    String processed = rawResponse.trim();
    
    // 길이 제한 (최대 120자)
    if (processed.length > 120) {
      processed = processed.substring(0, 117) + '...';
    }
    
    // 부적절한 표현 필터링
    processed = _filterInappropriateContent(processed, context);
    
    // 이모지 정리 (너무 많으면 줄이기)
    processed = _normalizeEmojis(processed);
    
    return processed;
  }
  
  /// 부적절한 내용 필터링
  String _filterInappropriateContent(String text, SherpiContext context) {
    // 금지된 표현들 체크
    final prohibitedPhrases = [
      '당신은 게을러',
      '노력이 부족',
      '실패할 거',
      '어려울 것 같',
      '포기하',
    ];
    
    for (final phrase in prohibitedPhrases) {
      if (text.contains(phrase)) {
        // 부적절한 표현 발견 시 폴백 사용
        print('⚠️ 부적절한 표현 감지: $phrase');
        return '우리 함께 해봐요! 😊'; // 안전한 기본 메시지
      }
    }
    
    return text;
  }
  
  /// 이모지 정규화
  String _normalizeEmojis(String text) {
    // 이모지 개수를 2개로 제한
    final emojiRegex = RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]', unicode: true);
    final emojis = emojiRegex.allMatches(text);
    
    if (emojis.length > 2) {
      // 처음 2개 이모지만 유지
      String normalized = text;
      final matches = emojis.toList();
      for (int i = 2; i < matches.length; i++) {
        normalized = normalized.replaceFirst(matches[i].group(0)!, '');
      }
      return normalized.trim();
    }
    
    return text;
  }
}