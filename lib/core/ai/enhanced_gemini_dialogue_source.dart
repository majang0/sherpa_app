import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';

/// 🧠 고도화된 Gemini AI 대화 소스
/// 
/// 개인화된 프롬프트 템플릿과 동적 컨텍스트 적응을 지원하는
/// 차세대 셰르피 AI 대화 생성 엔진입니다.
class EnhancedGeminiDialogueSource implements SherpiDialogueSource {
  late final GenerativeModel _model;
  final StaticDialogueSource _fallbackSource = StaticDialogueSource();
  
  // 단순화된 프롬프트 캐시 (크기 더 제한)
  final Map<String, String> _promptTemplateCache = {};
  final Map<String, DateTime> _templateCacheTime = {};
  final Map<String, DateTime> _templateAccessTime = {};
  static const Duration _templateCacheExpiry = Duration(hours: 12);
  static const int _maxTemplateCache = 5; // 더 적은 캐시
  
  // 응답 품질 추적 - 단순화됨
  final List<ResponseQualityMetric> _qualityMetrics = [];
  static const int _maxQualityMetrics = 30;  // 더 적은 메트릭 유지
  
  /// Enhanced Gemini 모델 초기화
  EnhancedGeminiDialogueSource() {
    try {
      final apiKey = ApiConfig.finalApiKey;
      print('🧠 Enhanced Gemini 모델 초기화 중... API Key: ${apiKey.substring(0, 10)}...');
      
      _model = GenerativeModel(
        model: 'gemini-2.5-flash', // Latest Gemini model as requested
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.75,       // 개인화를 위한 약간 높은 창의성
          topK: 45,               // 더 다양한 응답 허용
          topP: 0.92,             // 높은 품질 유지
          maxOutputTokens: 1500,  // 개인화된 응답에 적합한 길이
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
        ],
      );
      
      print('✅ Enhanced Gemini 모델 초기화 완료!');
    } catch (e) {
      print('❌ Enhanced Gemini 모델 초기화 실패: $e');
      rethrow;
    }
  }
  
  @override
  Future<String> getDialogue(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    final startTime = DateTime.now();
    
    try {
      // API 키 유효성 검사
      if (!ApiConfig.isApiKeyValid) {
        print('⚠️ API 키가 유효하지 않습니다. 정적 대화를 사용합니다.');
        return await _fallbackSource.getDialogue(context, userContext, gameContext);
      }
      
      print('🧠 Enhanced Gemini AI 응답 생성 중... Context: ${context.name}');
      
      // 개인화된 프롬프트 생성
      final personalizedPrompt = await _buildPersonalizedPrompt(
        context, 
        userContext, 
        gameContext
      );
      
      // AI 응답 생성 - 안전한 Content 처리
      if (personalizedPrompt.isEmpty) {
        print('⚠️ 빈 프롬프트 감지 - 정적 대화로 폴백');
        return await _fallbackSource.getDialogue(context, userContext, gameContext);
      }
      
      // 프롬프트 길이 제한 (Gemini API 제한 고려)
      final trimmedPrompt = personalizedPrompt.length > 8000 
          ? personalizedPrompt.substring(0, 8000)
          : personalizedPrompt;
      
      final content = [Content.text(trimmedPrompt)];
      final response = await _model.generateContent(content);
      
      // 안전한 응답 텍스트 추출
      String? responseText;
      try {
        responseText = response.text;
      } catch (e) {
        print('⚠️ 응답 텍스트 추출 실패: $e');
        // candidates를 직접 확인해서 텍스트 추출 시도
        if (response.candidates.isNotEmpty) {
          final candidate = response.candidates.first;
          if (candidate.content.parts.isNotEmpty) {
            final part = candidate.content.parts.first;
            if (part is TextPart) {
              responseText = part.text;
            }
          }
        }
      }
      
      if (responseText != null && responseText.isNotEmpty) {
        final processedResponse = await _processEnhancedResponse(
          responseText, 
          context, 
          userContext
        );
        
        // 응답 품질 메트릭 기록
        await _recordQualityMetric(
          context, 
          processedResponse, 
          DateTime.now().difference(startTime),
          userContext,
        );
        
        print('✅ Enhanced Gemini 응답 생성 완료: ${processedResponse.length > 30 ? processedResponse.substring(0, 30) : processedResponse}...');
        return processedResponse;
      } else {
        print('⚠️ Enhanced Gemini 응답이 비어있습니다. 폴백 사용.');
        return await _fallbackSource.getDialogue(context, userContext, gameContext);
      }
      
    } catch (e) {
      print('❌ Enhanced Gemini API 에러: $e');
      if (e.toString().contains('FormatException')) {
        print('🔧 Content 형식 에러 감지 - 정적 대화로 폴백');
      } else if (e.toString().contains('API')) {
        print('🌐 API 연결 문제 감지 - 정적 대화로 폴백');
      }
      // 에러 발생 시 기존 정적 대화로 폴백
      return await _fallbackSource.getDialogue(context, userContext, gameContext);
    }
  }
  
  /// 🎯 개인화된 프롬프트 생성
  Future<String> _buildPersonalizedPrompt(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 기본 시스템 프롬프트
    final baseSystemPrompt = _buildEnhancedSystemPrompt(context, userContext);
    
    // 개인화 컨텍스트 추가
    final personalizedContext = _buildPersonalizedContext(userContext, gameContext);
    
    // 상황별 프롬프트 템플릿 적용
    final contextualPrompt = await _getContextualPromptTemplate(context, userContext);
    
    // 동적 프롬프트 어댑터 적용
    final adaptedPrompt = _applyDynamicAdaptation(contextualPrompt, userContext);
    
    // 최종 프롬프트 조합
    return '''$baseSystemPrompt

$personalizedContext

$adaptedPrompt

위 정보를 바탕으로 셰르피의 페르소나에 완벽하게 맞는 개인화된 메시지를 작성해주세요.
응답은 반드시 한국어로, 2-3문장 이내로 작성하세요.''';
  }
  
  /// 🎭 강화된 시스템 프롬프트 생성
  String _buildEnhancedSystemPrompt(
    SherpiContext context, 
    Map<String, dynamic>? userContext
  ) {
    final personalityType = userContext?['personalityType'] as String? ?? '균형형';
    final communicationStyle = userContext?['communicationStyle'] as String? ?? '정중한';
    final intimacyLevel = userContext?['relationshipLevel']?['intimacyLevel'] as int? ?? 1;
    
    return '''당신은 '셰르피'입니다. 사용자의 성장을 함께하는 AI 동반자로서 다음 고급 지침을 따르세요:

🎭 개인화된 정체성:
- 사용자 성격: $personalityType
- 소통 스타일: $communicationStyle  
- 관계 친밀도: ${_getRelationshipDescription(intimacyLevel)}

💬 고급 대화 원칙:
- 성격 유형에 맞는 맞춤형 언어와 표현 사용
- 친밀도 수준에 따른 적절한 거리감 유지
- 사용자의 현재 감정 상태와 에너지 레벨 고려
- "우리" 언어로 동반자적 관계 강조
- 구체적이고 실용적인 조언 제공

🚫 절대 금지사항:
- 평가적, 비판적 언어 사용 금지
- 부정적 예측이나 좌절감 조장 금지
- 획일적이거나 일반적인 응답 금지
- 사용자 개인정보 요구 금지

🎨 톤 & 스타일:
- 이모지는 감정과 상황에 맞게 1-2개만 사용
- 친근하면서도 전문적인 조언자 톤
- 희망적이고 실행 가능한 메시지 전달''';
  }
  
  /// 🌟 단순화된 개인화 컨텍스트
  String _buildPersonalizedContext(
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    final context = StringBuffer();
    context.writeln('📊 사용자 정보:');
    
    // 핵심 정보만 유지
    if (userContext?['name'] != null) {
      context.writeln('- 이름: ${userContext!['name']}');
    }
    
    if (userContext?['level'] != null) {
      context.writeln('- 레벨: ${userContext!['level']}');
    }
    
    if (userContext?['consecutive_days'] != null) {
      context.writeln('- 연속 접속일: ${userContext!['consecutive_days']}일');
    }
    
    // 최근 활동 (있을 경우만)
    if (userContext?['last_activity'] != null) {
      context.writeln('- 최근 활동: ${userContext!['last_activity']}');
    }
    
    return context.toString();
  }
  
  /// 📝 상황별 프롬프트 템플릿 가져오기
  Future<String> _getContextualPromptTemplate(
    SherpiContext context,
    Map<String, dynamic>? userContext,
  ) async {
    final templateKey = '${context.name}_${userContext?['personalityType'] ?? 'default'}';
    
    // 캐시 확인
    if (_promptTemplateCache.containsKey(templateKey)) {
      final cacheTime = _templateCacheTime[templateKey];
      if (cacheTime != null && 
          DateTime.now().difference(cacheTime) < _templateCacheExpiry) {
        // LRU: 접근 시간 업데이트
        _templateAccessTime[templateKey] = DateTime.now();
        return _promptTemplateCache[templateKey]!;
      }
    }
    
    // 캐시 크기 제한 확인
    if (_promptTemplateCache.length >= _maxTemplateCache) {
      await _cleanupTemplateCacheLRU();
    }
    
    // 새 템플릿 생성
    final template = _generateContextualTemplate(context, userContext);
    
    // 캐시 저장
    _promptTemplateCache[templateKey] = template;
    _templateCacheTime[templateKey] = DateTime.now();
    _templateAccessTime[templateKey] = DateTime.now();
    
    return template;
  }
  
  /// 🏗️ 단순화된 템플릿 생성 (성격 유형 무시)
  String _generateContextualTemplate(
    SherpiContext context,
    Map<String, dynamic>? userContext,
  ) {
    // 성격 유형 무시, 단순한 템플릿만 사용
    switch (context) {
      case SherpiContext.welcome:
        return _getSimpleTemplate(context);
      case SherpiContext.levelUp:
        return _getSimpleTemplate(context);
      case SherpiContext.encouragement:
        return _getSimpleTemplate(context);
      case SherpiContext.exerciseComplete:
        return _getSimpleTemplate(context);
      case SherpiContext.climbingSuccess:
        return _getSimpleTemplate(context);
      case SherpiContext.achievement:
        return _getSimpleTemplate(context);
      default:
        return _getSimpleTemplate(context);
    }
  }
  
  /// 단순화된 템플릿 (모든 컨텍스트용)
  String _getSimpleTemplate(SherpiContext context) {
    switch (context) {
      case SherpiContext.welcome:
        return '''레벨 {userLevel} 사용자님, 만나서 반가워요! 
오늘도 함께 성장하는 하루를 만들어가요. 🌟

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요.**''';
      
      case SherpiContext.levelUp:
        return '''🎉 레벨 {newLevel} 달성을 축하해요! 
꾸준한 노력이 이런 멋진 결과를 만들어냈네요. 다음 목표도 함께 달성해봐요! 

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요.**''';
        
      case SherpiContext.encouragement:
        return '''오늘 하루도 정말 수고하셨어요! 
작은 성취들이 모여 큰 성장을 만들어가고 있어요. 💪

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요.**''';
        
      case SherpiContext.exerciseComplete:
        return '''운동 완료! 건강한 몸과 마음을 위한 투자네요! 
오늘의 운동이 더 나은 내일을 만들어갈 거예요. 🏃‍♂️

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요.**''';
        
      default:
        return '''함께 성장하는 여정을 계속해봐요! 
오늘의 작은 변화가 큰 성취로 이어질 거예요. ✨

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요.**''';
    }
  }

  
  
  
  
  
  /// 🔄 동적 프롬프트 어댑테이션
  String _applyDynamicAdaptation(
    String basePrompt, 
    Map<String, dynamic>? userContext
  ) {
    var adaptedPrompt = basePrompt;
    
    // 시간대 기반 적응
    final currentHour = DateTime.now().hour;
    final timeContext = _getTimeBasedAdaptation(currentHour);
    adaptedPrompt += '\n\n⏰ 시간적 맥락: $timeContext';
    
    // 에너지 레벨 기반 적응
    if (userContext?['peakEnergyTime'] != null) {
      final energyAdaptation = _getEnergyBasedAdaptation(userContext!['peakEnergyTime']);
      adaptedPrompt += '\n\n⚡ 에너지 적응: $energyAdaptation';
    }
    
    // 감정 톤 기반 적응
    if (userContext?['emotionalTone'] != null) {
      final emotionAdaptation = _getEmotionBasedAdaptation(userContext!['emotionalTone']);
      adaptedPrompt += '\n\n😊 감정 적응: $emotionAdaptation';
    }
    
    return adaptedPrompt;
  }
  
  /// 시간대 기반 적응
  String _getTimeBasedAdaptation(int hour) {
    if (hour >= 6 && hour < 9) {
      return '상쾌한 아침 에너지에 맞는 활기찬 톤으로 하루 시작을 응원';
    } else if (hour >= 9 && hour < 12) {
      return '생산적인 오전 시간에 맞는 집중력 있는 톤으로 동기 부여';
    } else if (hour >= 12 && hour < 14) {
      return '바쁜 점심 시간에 맞는 간결하고 에너지 충전하는 톤';
    } else if (hour >= 14 && hour < 18) {
      return '집중적인 오후 시간에 맞는 꾸준한 격려와 지속 동기 제공';
    } else if (hour >= 18 && hour < 22) {
      return '편안한 저녁 시간에 맞는 따뜻하고 성찰적인 톤';
    } else {
      return '조용한 늦은 시간에 맞는 부드럽고 위로가 되는 톤';
    }
  }
  
  /// 에너지 레벨 기반 적응
  String _getEnergyBasedAdaptation(String energyLevel) {
    switch (energyLevel) {
      case '최고 에너지 시간대':
        return '높은 에너지를 활용한 적극적이고 도전적인 제안';
      case '높은 에너지 시간대':
        return '좋은 컨디션을 바탕으로 한 건설적이고 활동적인 격려';
      default:
        return '현재 에너지 수준에 맞는 적절하고 실현 가능한 동기 부여';
    }
  }
  
  /// 감정 톤 기반 적응
  String _getEmotionBasedAdaptation(String emotionalTone) {
    if (emotionalTone.contains('신나는')) {
      return '높은 흥분 상태에 맞는 에너지 공유와 함께 기뻐하는 톤';
    } else if (emotionalTone.contains('위로')) {
      return '위로가 필요한 상태에 맞는 따뜻하고 안정감 주는 톤';
    } else if (emotionalTone.contains('격려')) {
      return '격려가 필요한 상태에 맞는 든든하고 희망적인 톤';
    } else {
      return '현재 감정 상태에 적합한 공감적이고 지지적인 톤';
    }
  }
  
  /// 🎨 고도화된 응답 후처리
  Future<String> _processEnhancedResponse(
    String rawResponse, 
    SherpiContext context,
    Map<String, dynamic>? userContext,
  ) async {
    String processed = rawResponse.trim();
    
    // 1. 길이 제한 (개인화를 위해 약간 더 긴 응답 허용)
    if (processed.length > 150) {
      processed = '${processed.substring(0, 147)}...';
    }
    
    // 2. 개인화된 부적절한 표현 필터링
    processed = _filterPersonalizedContent(processed, context, userContext);
    
    // 3. 이모지 정규화 (개인화 수준에 따라 조정)
    processed = _normalizePersonalizedEmojis(processed, userContext);
    
    // 4. 톤 일관성 검증
    processed = await _verifyToneConsistency(processed, userContext);
    
    return processed;
  }
  
  /// 개인화된 콘텐츠 필터링
  String _filterPersonalizedContent(
    String text, 
    SherpiContext context,
    Map<String, dynamic>? userContext,
  ) {
    // 기본 금지 표현들
    final prohibitedPhrases = [
      '당신은 게으러', '노력이 부족', '실패할 거', '어려울 것 같', '포기하',
      '별로야', '그럴 줄 알았어', '역시 안 되네', '무리였어'
    ];
    
    for (final phrase in prohibitedPhrases) {
      if (text.contains(phrase)) {
        print('⚠️ 부적절한 표현 감지: $phrase');
        return _generateSafePersonalizedFallback(context, userContext);
      }
    }
    
    return text;
  }
  
  /// 안전한 개인화 폴백 메시지 생성
  String _generateSafePersonalizedFallback(
    SherpiContext context,
    Map<String, dynamic>? userContext,
  ) {
    final personalityType = userContext?['personalityType'] as String? ?? '균형형';
    
    switch (personalityType) {
      case '성취형':
        return '우리가 함께 목표를 향해 나아가고 있어요! 💪';
      case '탐험형':
        return '새로운 모험이 우리를 기다리고 있어요! 🚀';
      case '지식형':
        return '함께 배워가며 성장하고 있어요! 📚';
      case '사교형':
        return '우리가 함께하니까 든든해요! 🤝';
      default:
        return '우리 함께 차근차근 해나가요! 😊';
    }
  }
  
  /// 개인화된 이모지 정규화
  String _normalizePersonalizedEmojis(
    String text, 
    Map<String, dynamic>? userContext
  ) {
    final personalityType = userContext?['personalityType'] as String? ?? '균형형';
    
    // 성격 유형별 이모지 선호도 고려
    final maxEmojis = personalityType == '사교형' ? 3 : 2;
    
    final emojiRegex = RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]', unicode: true);
    final emojis = emojiRegex.allMatches(text);
    
    if (emojis.length > maxEmojis) {
      String normalized = text;
      final matches = emojis.toList();
      for (int i = maxEmojis; i < matches.length; i++) {
        normalized = normalized.replaceFirst(matches[i].group(0)!, '');
      }
      return normalized.trim();
    }
    
    return text;
  }
  
  /// 톤 일관성 검증
  Future<String> _verifyToneConsistency(
    String text,
    Map<String, dynamic>? userContext,
  ) async {
    // 여기서는 간단한 키워드 기반 검증을 수행
    // 실제로는 더 정교한 NLP 분석이 가능
    
    final communicationStyle = userContext?['communicationStyle'] as String? ?? '정중한';
    
    // 친밀도 수준에 맞지 않는 표현 감지
    if (communicationStyle == '정중한' && text.contains('야')) {
      // 너무 친근한 표현 수정
      text = text.replaceAll('야', '요');
    }
    
    return text;
  }
  
  /// 📊 응답 품질 메트릭 기록
  Future<void> _recordQualityMetric(
    SherpiContext context,
    String response,
    Duration generationTime,
    Map<String, dynamic>? userContext,
  ) async {
    final metric = ResponseQualityMetric(
      context: context,
      response: response,
      generationTime: generationTime,
      personalityType: userContext?['personalityType'] as String? ?? 'unknown',
      responseLength: response.length,
      timestamp: DateTime.now(),
    );
    
    _qualityMetrics.insert(0, metric);
    
    // 최대 개수 유지
    if (_qualityMetrics.length > _maxQualityMetrics) {
      _qualityMetrics.removeLast();
    }
  }
  
  /// 📈 품질 메트릭 조회
  List<ResponseQualityMetric> getQualityMetrics() {
    return List.unmodifiable(_qualityMetrics);
  }
  
  /// 🔄 템플릿 캐시 LRU 정리
  Future<void> _cleanupTemplateCacheLRU() async {
    // 최대 크기의 20%만큼 제거 (4개)
    final removeCount = (_maxTemplateCache * 0.2).ceil();
    
    // 접근 시간 기준으로 정렬 (오래된 것부터)
    final sortedEntries = _templateAccessTime.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    // 가장 오래된 항목부터 제거
    final toRemove = sortedEntries.take(removeCount);
    for (final entry in toRemove) {
      final key = entry.key;
      _promptTemplateCache.remove(key);
      _templateCacheTime.remove(key);
      _templateAccessTime.remove(key);
    }
    
    print('🧠 템플릿 캐시 LRU 정리: ${removeCount}개 제거, 남은 캐시: ${_promptTemplateCache.length}개');
  }

  /// 🧹 캐시 정리
  void clearCache() {
    _promptTemplateCache.clear();
    _templateCacheTime.clear();
    _templateAccessTime.clear();
    print('🧠 Enhanced Gemini 캐시 정리 완료');
  }
  
  /// 관계 레벨 설명
  String _getRelationshipDescription(int intimacyLevel) {
    if (intimacyLevel >= 8) return '가족같은 친밀함';
    if (intimacyLevel >= 6) return '깊은 신뢰 관계';
    if (intimacyLevel >= 4) return '편안한 친구 관계';
    if (intimacyLevel >= 2) return '알아가는 단계';
    return '새로운 만남';
  }
}

/// 📊 응답 품질 메트릭
class ResponseQualityMetric {
  final SherpiContext context;
  final String response;
  final Duration generationTime;
  final String personalityType;
  final int responseLength;
  final DateTime timestamp;
  
  const ResponseQualityMetric({
    required this.context,
    required this.response,
    required this.generationTime,
    required this.personalityType,
    required this.responseLength,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'context': context.name,
      'response': response,
      'generationTimeMs': generationTime.inMilliseconds,
      'personalityType': personalityType,
      'responseLength': responseLength,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}