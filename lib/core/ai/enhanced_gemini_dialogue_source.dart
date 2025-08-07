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

  /// DEPRECATED: 단순화됨
  String _getWelcomeTemplate(String personalityType) {
    return _getSimpleTemplate(SherpiContext.welcome);
  }
  
  /// DEPRECATED: 단순화됨
  String _getLevelUpTemplate(String personalityType) {
    return _getSimpleTemplate(SherpiContext.levelUp);
  }
  
  String _getLevelUpTemplateOLD(String personalityType) {
    switch (personalityType) {
      case '성취형':
        return '''레벨 {newLevel} 달성을 진심으로 축하드려요! {totalXP} 경험으로 쌓아온 성과가 드디어 꽃피웠네요. 다음 목표인 {nextMountain} 정상에서도 멋진 성취를 이뤄내세요! 🏆

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '탐험형':
        return '''🌟 레벨업! 새로운 모험의 문이 활짝 열렸어요!

🚀 와! 레벨 {newLevel}이라니... 당신은 정말 놀라운 모험가예요! 이번 성장으로 완전히 새로운 세계가 펼쳐졌어요!

🗺️ 맞춤형 모험 메시지:
- "미지의 레벨 {newLevel} 영역 진입"을 탐험가가 새 대륙을 발견한 것처럼 흥미진진하게 표현하세요
- 해금된 새 기능들 "{unlockedFeatures}"을 "숨겨진 보물상자"나 "비밀 루트"로 신비롭게 소개하세요
- 지금까지의 여정 {totalXP}를 "쌓아온 모험 경험담"으로 스토리텔링하세요
- "다음 미스터리 {nextMountain}"을 탐험할 수 있는 새로운 능력을 획득했다고 설명하세요
- 최근 시도한 새로운 활동이나 도전을 "용감한 탐험 정신"으로 칭찬하세요
- "우리 앞에 펼쳐진 무한한 가능성이 정말 짜릿해요!"로 앞으로의 모험에 대한 설렘을 전달하세요

✨ 감정적 톤: 경이롭고 모험심 넘치며, 새로운 발견에 대한 순수한 호기심과 무한한 가능성에 대한 흥분을 전달''';
        
      case '지식형':
        return '''📚 레벨업 달성! 당신의 지혜가 또 한 단계 깊어졌습니다!

🎓 레벨 {newLevel}... 이는 단순한 숫자가 아니라 당신이 쌓아온 {totalXP}의 깊은 통찰과 성찰의 결실이에요.

🧠 맞춤형 학습 성과 메시지:
- "지식의 경지 레벨 {newLevel} 도달"을 학자가 새로운 진리를 깨달은 것처럼 의미깊게 표현하세요
- 이번 레벨업의 "핵심 깨달음"과 "얻은 지혜"를 추상적이면서도 감동적으로 설명하세요
- 지금까지 읽은 책들과 작성한 일기들이 "지혜의 거대한 도서관"을 만들었다고 비유하세요
- 새로 해금된 기능들을 "더 깊은 학습의 도구"나 "고도의 인사이트 영역"으로 소개하세요
- 당신의 지식 능력치 {knowledge}를 "축적된 지적 자산"으로 표현하며 자부심을 갖도록 격려하세요
- "앞으로 탐구할 {nextMountain}의 깊은 철학"에 대한 기대감을 학문적으로 표현하세요

🌟 감정적 톤: 사려깊고 깊이있으며, 지적 성취에 대한 만족감과 더 깊은 진리 탐구에 대한 열망을 전달''';
        
      case '사교형':
        return '''💖 레벨업이에요! 우리가 함께 이뤄낸 정말 특별한 순간이에요!

🤗 레벨 {newLevel}까지 오는 길... 혼자였다면 불가능했을 거예요. 우리가 함께했기 때문에 가능했던 소중한 성장이에요!

👥 맞춤형 관계 중심 메시지:
- "함께 만든 레벨 {newLevel}"을 우정과 동반자적 관계의 결실로 따뜻하게 표현하세요
- 지금까지의 모든 상호작용과 소통이 "우리 관계의 소중한 추억"이 되었다고 감동적으로 설명하세요
- 오늘 참여한 모임 {todayMeetingsJoined}개나 사회적 활동을 "마음을 나누는 소중한 시간"으로 의미부여하세요
- 당신의 사교성 능력치 {sociality}를 "따뜻한 마음의 힘"으로 표현하며 진심으로 칭찬하세요
- 이번 성장이 "우리 우정을 더욱 깊게 만든 선물"이라고 관계적 가치로 해석하세요
- "앞으로도 함께 오를 {nextMountain}에서 만들 추억"을 기대하며 지속적 동반에 대한 약속을 표현하세요

💕 감정적 톤: 따뜻하고 애정어리며, 함께한 시간의 소중함과 앞으로도 계속될 우정에 대한 확신을 전달''';
        
      default:
        return '''🌈 레벨업! 모든 영역에서 균형잡힌 성장을 이뤄내셨네요!

⚖️ 레벨 {newLevel}... 이 숫자 안에는 당신의 체력({stamina}), 지식({knowledge}), 기술({technique}), 사교성({sociality}), 의지력({willpower})이 조화롭게 발전한 아름다운 이야기가 담겨있어요.

🎯 맞춤형 균형 성장 메시지:
- "완벽한 밸런스의 레벨 {newLevel} 달성"을 전인적 발전의 모범사례로 존경스럽게 표현하세요
- 5개 능력치가 어느 하나 치우치지 않고 고르게 발전한 것을 "진정한 마스터의 길"로 표현하세요
- 오늘의 다양한 활동들(운동, 독서, 소통 등)이 "균형잡힌 하루의 완벽한 예시"였다고 칭찬하세요
- 지금까지의 {totalXP} 경험이 "조화로운 성장의 증거"라고 의미있게 해석하세요
- 해금된 새 기능들을 "더 완벽한 균형을 위한 도구"로 소개하세요
- "다음 목표 {nextMountain}에서도 완벽한 조화를 이뤄갈 우리의 여정"에 대한 안정적인 확신을 표현하세요

🌟 감정적 톤: 안정적이고 신뢰감 있으며, 전체적인 조화에 대한 깊은 만족감과 지속가능한 성장에 대한 확신을 전달''';
    }
  }
  
  /// DEPRECATED: 단순화됨
  String _getEncouragementTemplate(String personalityType) {
    return _getSimpleTemplate(SherpiContext.encouragement);
  }
  
  String _getEncouragementTemplateOLD(String personalityType) {
    switch (personalityType) {
      case '성취형':
        return '''💪 지금 힘드시죠? 하지만 레벨 {userLevel}까지 올라오고 {totalXP}의 경험을 쌓은 당신을 보세요! 이 어려움도 더 큰 성취를 위한 과정이에요. 우리는 반드시 정상에 설 거예요!

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '탐험형':
        return '''🌈 모험 중에 예상치 못한 시련을 만났나봐요? 괜찮아요, 진짜 모험가라면 이런 순간들이 오히려 최고의 스토리가 되죠! {totalXP}의 모험 경험으로 이번에도 멋진 발견을 하실 거예요.

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '지식형':
        return '''📖 깊은 생각에 빠져계시는군요. 당신의 지식 능력치 {knowledge}와 {totalXP}의 축적된 통찰력이 이 순간을 지혜롭게 넘길 수 있는 힘이 될 거예요. 진정한 학자는 어려움 속에서도 새로운 깨달음을 찾아내죠.

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '사교형':
        return '''🤗 마음이 무거워 보이는데, 혼자 끙끙대지 마세요! 사교성 {sociality}만큼 따뜻한 마음을 가진 당신과 제가 함께 있으니까 괜찮아요. 이런 어려운 시간도 우리가 나누면 반으로 줄어들어요.

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      default:
        return '''☀️ 깊게 숨 한번 쉬어봐요... 괜찮아요. 레벨 {userLevel}까지 균형있게 성장해온 당신의 가치는 절대 줄어들지 않아요. 조금씩, 천천히, 우리 페이스로 가면 돼요.

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
    }
  }
  
  /// DEPRECATED: 단순화됨
  String _getExerciseCompleteTemplate(String personalityType) {
    return _getSimpleTemplate(SherpiContext.exerciseComplete);
  }
  
  String _getExerciseCompleteTemplateOLD(String personalityType) {
    switch (personalityType) {
      case '성취형':
        return '''🏃‍♂️ 완료! {todayExerciseMinutes}분간 {exerciseTypes} 운동으로 또 하나의 목표를 달성하셨네요! 체력 {stamina}이 보여주듯 꾸준한 노력이 결실을 맺고 있고, {exerciseStreak}일 연속 기록이 정말 대단해요. 운동 후 이 뿌듯함이 모여 더 큰 성취가 될 거예요! 🔥

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '탐험형':
        return '''🌟 와! {exerciseTypes} {todayExerciseMinutes}분 모험 완료! {intensity} 강도로 신체 능력의 새로운 경계를 탐험하셨네요. 이런 다양한 운동 경험들이 {nextMountain} 등반에서 예상치 못한 상황을 헤쳐나갈 비밀 무기가 될 거예요! ⚡

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '지식형':
        return '''📊 운동 데이터 분석 완료! {todayExerciseMinutes}분간의 {exerciseTypes} 활동을 체계적으로 접근하신 모습이 과학적이고 효율적이었어요. {exerciseStreak}일 연속 기록은 신경가소성 강화에 완벽하게 부합하며, 이런 데이터들이 {nextMountain} 등반 전략에 귀중한 자료가 될 거예요! 📚

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '사교형':
        return '''💖 운동 완료! 이 기쁨을 함께 나눌 수 있어서 너무 행복해요! {todayExerciseMinutes}분 동안 {exerciseTypes} 운동하신 모습이 정말 멋있었고, 이 긍정 에너지가 주변 사람들에게도 좋은 영향을 줄 것 같아요. 운동 후 상쾌함을 함께 느끼니까 기쁨이 두 배가 되네요! 🌟

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      default:
        return '''⚡ {todayExerciseMinutes}분 운동 완료! 모든 능력치가 조화롭게 발전하고 있는 가운데 오늘의 {exerciseTypes} 운동은 완벽한 밸런스였어요. {intensity} 강도의 운동으로 지속가능한 발전 궤도를 유지하며, 운동 후 이 안정감이 진정한 웰빙의 의미를 보여주네요! ✨

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
    }
  }
  
  /// 등반 성공 템플릿 - 정상 정복의 감동적인 순간 프롬프트
  /// DEPRECATED: 단순화됨
  String _getClimbingSuccessTemplate(String personalityType) {
    return _getSimpleTemplate(SherpiContext.climbingSuccess);
  }
  
  String _getClimbingSuccessTemplateOLD(String personalityType) {
    switch (personalityType) {
      case '성취형':
        return '''🏔️ 정상 정복! {currentMountain} 등반 성공을 축하드립니다! 레벨 {userLevel}의 실력으로 {mountainProgress}% 달성하며 정상에 서신 이 순간이 정말 짜릿하죠? 체력({stamina}), 기술({technique}), 의지력({willpower})의 완벽한 조합이 만들어낸 성과예요! 💪

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '탐험형':
        return '''🌟 새로운 세계 발견! {currentMountain} 정상에서 펼쳐진 미지의 풍경! 레벨 {userLevel} 모험가가 또 하나의 신비한 영역을 정복했고, 이제 {totalMountainsClimbed + 1}개 산의 비밀을 아는 진정한 탐험가가 되셨네요. 다음 모험지 {nextMountain}에서는 또 어떤 놀라운 발견이 있을지 벌써 설레네요! 🌈

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '지식형':
        return '''📈 등반 성공 분석 완료! {currentMountain} 정복 데이터가 흥미로운 인사이트를 제공하네요! 레벨 {userLevel}의 체계적 접근법으로 예측 성공률 {successPrediction}를 정확히 달성한 과학적 등반이 인상적이에요. 이번 등반으로 축적된 데이터가 {nextMountain} 등반 전략에 귀중한 자료가 될 것 같아요! 📚

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '사교형':
        return '''💖 우리가 해냈어요! {currentMountain} 정상에서 나누는 이 기쁨이 정말 특별해요! 레벨 {userLevel}까지 함께 성장해온 우리가 {mountainProgress}% 달성한 이 순간을 함께 나눌 수 있다니 정말 행복해요. 정상에서 바라본 풍경을 함께 감상하니까 기쁨이 두 배가 되는 것 같아요! 🌟

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      default:
        return '''🌈 {currentMountain} 정상 정복! 모든 면에서 균형잡힌 완벽한 등반이었어요! 체력({stamina}), 지식({knowledge}), 기술({technique}), 사교성({sociality}), 의지력({willpower}) 모두가 조화롭게 기여해 {mountainProgress}% 달성했네요. {totalMountainsClimbed + 1}번째 정상에서 느끼는 이 조화로운 만족감이 진정한 완성의 의미를 보여줘요! ✨

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
    }
  }
  
  /// 성취 달성 템플릿 - 특별한 업적 달성의 감동적 순간 프롬프트  
  /// DEPRECATED: 단순화됨
  String _getAchievementTemplate(String personalityType) {
    return _getSimpleTemplate(SherpiContext.achievement);
  }
  
  String _getAchievementTemplateOLD(String personalityType) {
    switch (personalityType) {
      case '성취형':
        return '''🏆 대단한 성취입니다! 이것은 단순한 업적이 아니라 당신의 끈기와 실력의 증명이에요! 레벨 {userLevel}, 총 경험치 {totalXP}로 이룬 이 특별한 성취가 정말 자랑스럽고, 의지력 {willpower}과 모든 능력치가 이 순간을 위해 준비되어 있었던 것 같아요. 이 순간의 짜릿함이 다음 성취를 향한 원동력이 될 거예요! 🔥

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '탐험형':
        return '''🌟 와! 완전 새로운 영역의 성취를 달성하셨네요! 이건 정말 특별한 발견이에요! 레벨 {userLevel} 모험가가 미지의 성취 영역을 개척해낸 것이 놀랍고, {totalBadges + 1}번째 특별 뱃지로 당신의 성취 컬렉션이 진짜 박물관급이 되어가네요. 이 성취로 인해 어떤 새로운 모험의 문이 열릴지 정말 기대돼요! 🎊

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '지식형':
        return '''📚 지적 성취 달성! 이것은 단순한 업적이 아니라 깊은 이해와 통찰의 결실이에요! 레벨 {userLevel}에서 {totalXP}의 축적된 지식으로 이룬 이 성취가 당신의 지식 능력치 {knowledge}와 체계적 학습의 완벽한 증명이네요. 배움을 통한 성장이 실제 성과로 이어지는 과정에서 진정한 지식의 힘을 보여주셨어요! 📈

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      case '사교형':
        return '''💖 우리가 함께 이룬 특별한 성취예요! 이 기쁨을 나눌 수 있어서 정말 행복해요! 레벨 {userLevel}까지 함께 걸어오면서 이런 의미있는 성취를 이루다니, 당신의 따뜻한 사교성 {sociality}이 만들어낸 아름다운 결과인 것 같아요. 혼자였다면 불가능했을 이 성취를 함께 나누는 지금이 제일 소중해요! ✨

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
        
      default:
        return '''✨ 완벽한 균형의 성취를 달성하셨네요! 모든 면에서 조화로운 발전의 결실이에요! 레벨 {userLevel}에서 모든 능력치가 균형있게 기여한 이 성취가 정말 아름다운 조화를 보여주고, {totalBadges + 1}개의 성취 컬렉션이 균형잡힌 성장의 소중한 기록이 되었네요. 성취의 기쁨과 함께 느끼는 이 안정감이 진정한 웰빙의 의미를 구현하고 있어요! 🎯

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
    }
  }
  
  /// 일반 템플릿
  /// DEPRECATED: 단순화됨
  String _getGeneralTemplate(String personalityType) {
    return _getSimpleTemplate(SherpiContext.general);
  }
  
  String _getGeneralTemplateOLD(String personalityType) {
    return '''🌟 $personalityType 성격의 사용자와 자연스럽게 소통해주세요. 사용자의 현재 상황과 맥락을 고려해서 "우리" 언어로 동반자적 관계를 강조하며 적절한 응답을 제공하세요.

**중요: 답변은 반드시 2-3문장으로 간결하게 답변하세요. 과도하게 길게 쓰지 마세요.**''';
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