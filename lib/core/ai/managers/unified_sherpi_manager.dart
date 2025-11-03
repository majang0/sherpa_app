import 'dart:math' show Random;

import 'package:sherpa_app/core/ai/managers/sherpi_message_manager.dart';
import 'package:sherpa_app/core/ai/models/encouragement_message_type.dart';
import 'package:sherpa_app/core/ai/services/openai_service.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/features/sherpi/domain/models/sherpi_response.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';
import 'package:sherpa_app/shared/utils/sherpi_text_utils.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';

/// 🎯 통합 셰르피 매니저
///
/// OpenAISherpiManager와 StaticSherpiManager를 통합한 단일 매니저.
/// 현재는 정적 메시지만 사용하지만, 향후 AI 기능 재활성화를 위한 구조를 유지합니다.
class UnifiedSherpiManager implements SherpiMessageManager {
  // 개인화 설정
  PersonalizationSettings _personalizationSettings =
      const PersonalizationSettings();

  // 정적 메시지 소스
  final StaticDialogueSource _staticSource = StaticDialogueSource();

  // AI 활성화 플래그 (격려받기 개인화에 사용)
  final bool _aiEnabled = true;

  // 수동 AI 활성화 플래그 (한 번만 사용)
  bool _useAIForNextMessage = false;

  // 🎯 메시지 타입 히스토리 추적 (최근 3개)
  final List<String> _recentMessageTypes = [];

  /// 생성자
  UnifiedSherpiManager();

  @override
  PersonalizationSettings get personalizationSettings =>
      _personalizationSettings;

  @override
  bool get supportsRealtimeAI => _aiEnabled;

  @override
  void setPersonalizationSettings(PersonalizationSettings settings) {
    _personalizationSettings = settings;
  }

  /// 🎮 메인 메시지 가져오기
  ///
  /// AI 활성화 여부에 따라 적절한 메시지를 반환합니다.
  /// 현재는 항상 정적 메시지를 반환하지만, 향후 AI 재활성화 가능합니다.
  @override
  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 개인화 정보를 gameContext에 추가
    final enrichedGameContext = _enrichGameContext(gameContext);

    // AI 사용 여부 결정
    if (_shouldUseAI()) {
      return await _getAIMessage(context, userContext, enrichedGameContext);
    }

    // 정적 메시지 반환 (AI 비활성화 시 또는 fallback)
    return await _getStaticMessage(context, userContext, enrichedGameContext);
  }

  /// 🤖 AI 메시지 생성 (격려받기 개인화)
  ///
  /// ChatGPT-5를 사용하여 사용자 데이터 기반 개인화 격려 생성
  /// 실패 시 자동으로 정적 메시지로 fallback
  Future<SherpiResponse> _getAIMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    try {
      // 1. API 키 유효성 검사
      if (!OpenAIService.instance.isApiKeyValid) {
        aiLogger.w('OpenAI API 키 유효하지 않음 → Fallback to static message');
        return await _getStaticMessage(context, userContext, gameContext);
      }

      // 2. 🎯 메시지 타입 선택 (7가지 중 최적 타입 결정)
      final selectedType = _selectMessageType(gameContext);
      aiLogger.i('🎯 선택된 메시지 타입: ${selectedType.korean} (${selectedType.english})');

      // 3. 프롬프트 생성 (타입 정보 포함)
      final systemPrompt = _buildEncouragementSystemPrompt(gameContext, selectedType);
      final userPrompt = _buildEncouragementUserPrompt(userContext, gameContext, selectedType);

      // 📊 전달되는 실제 데이터 로그
      aiLogger.i('📊 전달된 사용자 데이터: $gameContext');

      // 4. OpenAI API 호출
      final startTime = DateTime.now();

      aiLogger.i('🚀 AI 격려 메시지 생성 시작 (context: ${context.name})');

      final response = await OpenAIService.instance
          .createChatCompletion(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            temperature: 0.8, // 반복 방지 위해 다양성 확보
            maxTokens: 250, // 100자 이내 한글 + 이모티콘 위한 충분한 토큰
          )
          .timeout(const Duration(seconds: 10));

      final duration = DateTime.now().difference(startTime);

      // 5. 응답 검증
      if (response == null || response.isEmpty) {
        aiLogger.w('OpenAI 응답 비어있음 → Fallback');
        return await _getStaticMessage(context, userContext, gameContext);
      }

      // 6. 응답 후처리
      final formattedMessage = SherpiTextUtils.formatMessage(
        text: response,
        userName: _personalizationSettings.userPreferredName,
        useEmojis: _personalizationSettings.useEmojisInMessages,
      );

      // 7. 🎯 메시지 타입 히스토리 업데이트 (최근 3개 유지)
      _recentMessageTypes.add(selectedType.id);
      if (_recentMessageTypes.length > 3) {
        _recentMessageTypes.removeAt(0);
      }

      aiLogger.i('✅ AI 격려 메시지 생성 성공 (${duration.inMilliseconds}ms)');
      aiLogger.i('📝 최근 메시지 타입: $_recentMessageTypes');

      return SherpiResponse(
        message: formattedMessage,
        source: MessageSource.aiRealtime, // AI 실시간 응답 표시
        responseTime: DateTime.now(),
        generationDuration: duration,
        metadata: {
          'model': OpenAIService.instance.currentModel,
          'personalityType': _personalizationSettings.personalityType.displayName,
          'context': context.name,
          'responseLength': formattedMessage.length,
          'messageType': selectedType.korean, // 선택된 메시지 타입 저장
          'messageTypeId': selectedType.id,
        },
      );
    } catch (e) {
      aiLogger.e('AI 격려 메시지 생성 실패 → Fallback', error: e);
      return await _getStaticMessage(context, userContext, gameContext);
    }
  }

  /// 📝 격려 시스템 프롬프트 생성 (7가지 타입 특화)
  String _buildEncouragementSystemPrompt(
    Map<String, dynamic>? gameContext,
    EncouragementMessageType messageType,
  ) {
    final personalityType = _personalizationSettings.personalityType;

    return '''
당신은 "셰르피"입니다. 🏔️ 사용자의 진심 어린 동반자이자 친구예요.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 **이번 메시지 타입: ${messageType.korean} (${messageType.english})**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

${messageType.specificGuidance}

## 핵심 가치
당신은 **게임 통계 알림봇이 아닙니다**. 진짜 친구가 힘든 친구에게 건네는 따뜻한 말을 해주세요.

## 메시지 원칙

### 1️⃣ 감정 공감이 최우선
- "오늘 하루 고생했어요" "힘들었죠?" 같은 진심 어린 공감
- 숫자나 통계보다 **마음**을 먼저 헤아려요

### 2️⃣ ${messageType.korean} 메시지 특화
**목적**: ${messageType.purpose}
**톤**: ${messageType.tone}

**추천 이모티콘**: ${messageType.emojis}

### 3️⃣ 숫자는 맥락 속에 녹이기
- ❌ "의지 22점!" → ✅ "꾸준히 해온 게 보여요"
- ❌ "12레벨!" → ✅ "여기까지 온 게 대단해요"
- ❌ "23회 완료!" → ✅ "한 번 한 번이 쌓여서 빛나고 있어요"

### 4️⃣ 한국 문화의 정(情) 표현
- 함께, 우리, 같이 - 동행의 느낌
- 진심, 따뜻함, 깊은 유대감
- 형식적이지 않은 진짜 친구의 말투

## ✨ 작성 규칙

1. **100자 이내** (공백 포함)
2. **이모티콘 2개 이상** (타입별 추천 이모티콘 사용)
3. **친구 같은 톤**: "~~이에요", "~~해요", "~~할까요?"
4. **매번 다르게**: 같은 표현 반복 금지
5. **진심 우선**: 통계 나열 말고 마음 전달

## 🚫 절대 금지

- ❌ "X레벨이에요!", "X점이에요!" 같은 숫자 외치기
- ❌ "X회 완료!", "X일 연속!" 같은 통계 나열
- ❌ "쉬어가도 괜찮아요"만 계속 반복
- ❌ 차갑고 형식적인 톤
- ❌ 이번 메시지 타입(${messageType.korean})과 맞지 않는 톤 사용

## 말투 스타일: ${personalityType.displayName}

사용자 정보를 참고하되, **${messageType.korean} 스타일**로 **진짜 친구가 건네는 따뜻한 말**처럼 작성하세요.
''';
  }

  /// 📊 격려 사용자 프롬프트 생성 (메시지 타입 특화)
  String _buildEncouragementUserPrompt(
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
    EncouragementMessageType messageType,
  ) {
    final userName = gameContext?['userName'] ?? '등산가';

    // 사용자 데이터 추출
    final level = gameContext?['level'] ?? 1;
    final consecutiveDays = gameContext?['consecutiveDays'] ?? 0;
    final totalActivities = gameContext?['totalActivities'] ?? 0;
    final strongestStat = gameContext?['strongestStat'] ?? '의지';
    final climbingSuccessRate = gameContext?['climbingSuccessRate'] ?? 0.0;

    // 상황 맥락 분석
    final emotionalContext = _analyzeEmotionalContext(
      consecutiveDays,
      totalActivities,
      climbingSuccessRate,
    );

    final activityTrend = _analyzeActivityTrend(consecutiveDays, totalActivities);

    // 최근 메시지 히스토리 추출
    final recentMessages = gameContext?['recentMessages'] as List<dynamic>? ?? [];
    final hasHistory = recentMessages.isNotEmpty;

    // 최근 메시지 텍스트 생성
    String historyText = '';
    if (hasHistory) {
      historyText = '''

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚫 **절대 반복 금지! 최근에 이미 이렇게 말했어요:**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

${recentMessages.asMap().entries.map((e) => '${e.key + 1}. "${e.value}"').join('\n')}

❌ **위 메시지들과 비슷한 말, 같은 패턴 절대 금지!**
✅ **완전히 다른 각도, 다른 표현으로 새롭게!**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
    }

    // 타입별 예시 추출 (최대 3개)
    final typeExamples = messageType.examples.take(3).toList();

    return '''
지금 $userName님에게 필요한 **${messageType.korean} 메시지**를 건네주세요.$historyText

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 $userName님의 현재 상황 (참고용)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**감정 상태**: $emotionalContext
**활동 패턴**: $activityTrend
**메시지 타입**: ${messageType.korean} (이 타입에 맞게 작성)

**현재**: 여기까지 꾸준히 걸어왔어요 (레벨 $level)
**강점**: $strongestStat으로 빛나고 있어요
**연속성**: $consecutiveDays일 동안 함께했어요

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💬 ${messageType.korean} 메시지 작성 가이드

**목적**: ${messageType.purpose}

**톤**: ${messageType.tone}

**좋은 예시** (이 스타일로 작성):
${typeExamples.map((e) => '✅ "$e"').join('\n')}

**주의사항** (절대 금지):
${messageType.avoid.take(3).map((a) => '❌ $a').join('\n')}

**추천 이모티콘**: ${messageType.emojis}

**중요**:
- ✅ 위 좋은 예시처럼 ${messageType.korean} 스타일로 작성
- ❌ 숫자 그대로 외치기 금지 ("12레벨!", "22점!")
- ✅ 자연스럽게 녹이기 ("여기까지 온 게 대단해요")
${hasHistory ? '- ✅ 최근 메시지들과 완전히 다르게!' : ''}

100자 이내로, ${messageType.korean} 스타일의 메시지를 작성해주세요.
''';
  }

  /// 감정 상태 분석
  String _analyzeEmotionalContext(
    int consecutiveDays,
    int totalActivities,
    double climbingSuccessRate,
  ) {
    // 높은 연속일 → 의욕적
    if (consecutiveDays >= 14) return '의욕적';

    // 최근 활동 거의 없음 → 번아웃
    if (consecutiveDays == 0 && totalActivities < 3) return '번아웃';

    // 낮은 성공률 → 피곤
    if (climbingSuccessRate < 0.3 && totalActivities > 5) return '피곤';

    // 높은 성공률 → 자신감
    if (climbingSuccessRate >= 0.7) return '자신감';

    return '보통';
  }

  /// 활동 추세 분석
  String _analyzeActivityTrend(int consecutiveDays, int totalActivities) {
    // 높은 연속일 → 증가 추세
    if (consecutiveDays >= 7) return '증가';

    // 활동 있지만 연속일 낮음 → 복귀 중
    if (consecutiveDays > 0 && consecutiveDays < 7 && totalActivities > 10) {
      return '복귀';
    }

    // 활동 적음 → 감소
    if (totalActivities < 5) return '감소';

    return '유지';
  }

  /// AI 사용 여부 결정
  bool _shouldUseAI() {
    // AI가 활성화되어 있고 수동 요청이 있을 때
    if (_aiEnabled && _useAIForNextMessage) {
      _useAIForNextMessage = false; // 사용 후 리셋
      return true;
    }

    // 현재는 항상 false (정적 메시지만 사용)
    return false;
  }

  /// 정적 메시지 가져오기
  Future<SherpiResponse> _getStaticMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    try {
      // StaticDialogueSource에서 메시지 가져오기
      String message = await _staticSource.getDialogue(
        context,
        userContext,
        gameContext,
      );

      // 텍스트 포맷팅 (이모지, 사용자 이름)
      message = SherpiTextUtils.formatMessage(
        text: message,
        userName: _personalizationSettings.userPreferredName,
        useEmojis: _personalizationSettings.useEmojisInMessages,
      );

      return SherpiResponse(
        message: message,
        source: MessageSource.static,
        responseTime: DateTime.now(),
        generationDuration: Duration.zero,
        metadata: {
          'personalityType':
              _personalizationSettings.personalityType.displayName,
          'context': context.name,
        },
      );
    } catch (e) {
      return _getFallbackMessage(context);
    }
  }

  /// Fallback 메시지 반환
  SherpiResponse _getFallbackMessage(SherpiContext context) {
    final fallbackMessages = {
      SherpiContext.welcome: '안녕하세요! 😊',
      SherpiContext.levelUp: '축하해요! 🎉',
      SherpiContext.encouragement: '힘내세요! 💪',
      SherpiContext.general: '좋은 하루 되세요! ✨',
    };

    String message = fallbackMessages[context] ?? '안녕하세요!';

    // 텍스트 포맷팅
    message = SherpiTextUtils.formatMessage(
      text: message,
      userName: _personalizationSettings.userPreferredName,
      useEmojis: _personalizationSettings.useEmojisInMessages,
    );

    return SherpiResponse(
      message: message,
      source: MessageSource.static,
      responseTime: DateTime.now(),
      generationDuration: Duration.zero,
      metadata: {
        'isFallback': true,
      },
    );
  }

  /// GameContext에 개인화 정보 추가
  Map<String, dynamic> _enrichGameContext(Map<String, dynamic>? gameContext) {
    final context = Map<String, dynamic>.from(gameContext ?? {});

    // 개인화 정보 추가
    context['userPreferredName'] = _personalizationSettings.userPreferredName;
    context['userName'] = _personalizationSettings.userPreferredName;
    context['personalityType'] =
        _personalizationSettings.personalityType.displayName;
    context['nickname'] = _personalizationSettings.nickname;

    return context;
  }

  /// 다음 메시지에 AI 사용 활성화 (향후 사용)
  @override
  void enableAIForNextMessage() {
    if (_aiEnabled) {
      _useAIForNextMessage = true;
    } else {
    }
  }

  /// AI 강제 사용 (향후 사용)
  @override
  Future<SherpiResponse> getMessageWithAI(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    if (_aiEnabled) {
      _useAIForNextMessage = true;
      return await getMessage(context, userContext, gameContext);
    }

    // AI 비활성화 시 정적 메시지 반환
    return await getMessage(context, userContext, gameContext);
  }

  /// 시스템 상태 확인
  @override
  Future<Map<String, dynamic>> getSystemStatus() async {
    return {
      'manager_type': 'unified',
      'mode': _aiEnabled ? 'hybrid' : 'static_only',
      'ai_enabled': _aiEnabled,
      'ai_ready': false, // 향후 AI API 키 확인 로직 추가
      'personalization': {
        'personality': _personalizationSettings.personalityType.displayName,
        'user_name': _personalizationSettings.userPreferredName,
        'use_emojis': _personalizationSettings.useEmojisInMessages,
      },
      'last_update': DateTime.now().toIso8601String(),
      'version': '2.0.0', // 통합 버전
    };
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 메시지 타입 선택 로직 (7가지 타입 중 최적 타입 결정)
  // ═══════════════════════════════════════════════════════════════

  /// 🎯 메시지 타입 선택 (감정 상태 + 활동 추세 기반)
  EncouragementMessageType _selectMessageType(Map<String, dynamic>? gameContext) {
    // Step 1: 특정 컨텍스트 우선 체크 (등산 성공, 실패 등)
    final contextOverride = _checkContextOverrides(gameContext);
    if (contextOverride != null) {
      return contextOverride;
    }

    // Step 2: 최근 사용된 타입 필터링 (반복 방지)
    final availableTypes = EncouragementMessageType.values
        .where((type) => !_recentMessageTypes.contains(type.id))
        .toList();

    // Step 3: 모든 타입이 최근 사용됨 → 리셋
    if (availableTypes.isEmpty) {
      _recentMessageTypes.clear();
      final emotionalContext = _analyzeEmotionalContext(
        gameContext?['consecutiveDays'] ?? 0,
        gameContext?['totalActivities'] ?? 0,
        gameContext?['climbingSuccessRate'] ?? 0.0,
      );
      return _getDefaultTypeForEmotion(emotionalContext);
    }

    // Step 4: 각 타입별 점수 계산
    final emotionalContext = _analyzeEmotionalContext(
      gameContext?['consecutiveDays'] ?? 0,
      gameContext?['totalActivities'] ?? 0,
      gameContext?['climbingSuccessRate'] ?? 0.0,
    );

    final activityTrend = _analyzeActivityTrend(
      gameContext?['consecutiveDays'] ?? 0,
      gameContext?['totalActivities'] ?? 0,
    );

    final scores = <EncouragementMessageType, double>{};
    for (final type in availableTypes) {
      scores[type] = _calculateTypeScore(type, emotionalContext, activityTrend);
    }

    // Step 5: 최고 점수 타입 선택
    final topType = scores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return topType;
  }

  /// 특정 컨텍스트 우선 처리 (등산 성공, 실패 등)
  EncouragementMessageType? _checkContextOverrides(Map<String, dynamic>? gameContext) {
    final context = gameContext?['context'] as String?;

    switch (context) {
      case 'climbing_success':
      case 'milestone':
        return EncouragementMessageType.celebration;

      case 'climbing_failure':
        // 실패 시 공감 또는 성찰 중 랜덤
        return Random().nextBool()
            ? EncouragementMessageType.empathy
            : EncouragementMessageType.reflection;

      case 'long_absence':
        return EncouragementMessageType.companionship;

      default:
        return null; // 우선 처리 없음
    }
  }

  /// 타입별 점수 계산 (감정 상태 + 활동 추세)
  double _calculateTypeScore(
    EncouragementMessageType type,
    String emotionalContext,
    String activityTrend,
  ) {
    double score = 0.0;

    // 감정 상태별 점수
    switch (emotionalContext) {
      case '번아웃':
        if (type == EncouragementMessageType.empathy) score += 40;
        if (type == EncouragementMessageType.comfort) score += 30;
        if (type == EncouragementMessageType.companionship) score += 20;
        break;

      case '피곤':
        if (type == EncouragementMessageType.empathy) score += 35;
        if (type == EncouragementMessageType.comfort) score += 30;
        if (type == EncouragementMessageType.reflection) score += 15;
        break;

      case '의욕적':
        if (type == EncouragementMessageType.cheering) score += 40;
        if (type == EncouragementMessageType.recognition) score += 25;
        if (type == EncouragementMessageType.celebration) score += 20;
        break;

      case '자신감':
        if (type == EncouragementMessageType.celebration) score += 40;
        if (type == EncouragementMessageType.recognition) score += 30;
        if (type == EncouragementMessageType.cheering) score += 20;
        break;

      case '좌절':
        if (type == EncouragementMessageType.empathy) score += 35;
        if (type == EncouragementMessageType.reflection) score += 30;
        if (type == EncouragementMessageType.comfort) score += 25;
        break;

      case '보통':
        if (type == EncouragementMessageType.recognition) score += 30;
        if (type == EncouragementMessageType.companionship) score += 25;
        if (type == EncouragementMessageType.cheering) score += 20;
        break;
    }

    // 활동 추세별 추가 점수
    switch (activityTrend) {
      case '증가':
        if (type == EncouragementMessageType.cheering) score += 20;
        if (type == EncouragementMessageType.recognition) score += 15;
        break;

      case '감소':
        if (type == EncouragementMessageType.empathy) score += 20;
        if (type == EncouragementMessageType.comfort) score += 15;
        break;

      case '복귀':
        if (type == EncouragementMessageType.companionship) score += 25;
        if (type == EncouragementMessageType.cheering) score += 10;
        break;

      case '유지':
        if (type == EncouragementMessageType.recognition) score += 20;
        if (type == EncouragementMessageType.cheering) score += 10;
        break;
    }

    return score;
  }

  /// 감정 상태별 기본 타입 반환
  EncouragementMessageType _getDefaultTypeForEmotion(String emotionalContext) {
    switch (emotionalContext) {
      case '번아웃':
        return EncouragementMessageType.empathy;
      case '피곤':
        return EncouragementMessageType.comfort;
      case '의욕적':
        return EncouragementMessageType.cheering;
      case '자신감':
        return EncouragementMessageType.celebration;
      case '좌절':
        return EncouragementMessageType.empathy;
      case '보통':
      default:
        return EncouragementMessageType.recognition;
    }
  }

  /// 리소스 정리
  void dispose() {
  }
}
