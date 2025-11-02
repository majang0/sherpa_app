import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import '../models/chat_message.dart';
import '../models/conversation_state.dart';

// Core
import '../../../../core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/managers/unified_sherpi_manager.dart';
import 'package:sherpa_app/shared/providers/level_3_ai/global_sherpi_provider.dart';

// Emotion Recognition Integration
import '../../emotion/providers/emotion_state_provider.dart';
import '../../emotion/models/emotion_state_model.dart';
import '../../emotion/services/behavior_emotion_analyzer.dart';

// Personalization Integration (removed)

/// 💬 개인화 기능이 통합된 채팅 대화 관리 프로바이더
///
/// 기존 ChatConversationProvider에 개인화 시스템을 통합하여
/// 사용자별 맞춤형 응답과 학습 기능을 제공합니다.
class EnhancedChatConversationNotifier
    extends StateNotifier<ConversationState> {
  final UnifiedSherpiManager _smartManager = UnifiedSherpiManager();
  final Ref _ref;
  Timer? _typingTimer;

  EnhancedChatConversationNotifier(this._ref) : super(_createInitialState()) {
    // 개인화 통합 서비스 초기화
    _initializePersonalizationIntegration();
  }

  /// 초기 대화 상태 생성
  static ConversationState _createInitialState() {
    return ConversationState(
      sessionId: _generateSessionId(),
      startTime: DateTime.now(),
      currentEmotion: SherpiEmotion.happy,
      context: ConversationContext.general,
    );
  }

  /// 세션 ID 생성
  static String _generateSessionId() {
    final now = DateTime.now();
    final random = Random();
    return '${now.millisecondsSinceEpoch}_${random.nextInt(9999)}';
  }

  /// 🔗 개인화 통합 초기화
  void _initializePersonalizationIntegration() {
    // ChatIntegrationService가 자동으로 메시지 분석을 시작함
    // 별도 초기화 불필요 (프로바이더에서 자동 실행됨)
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  /// 💭 새 대화 세션 시작
  void startNewConversation({
    ConversationContext? context,
    Map<String, dynamic>? metadata,
  }) {
    state = ConversationState(
      sessionId: _generateSessionId(),
      startTime: DateTime.now(),
      context: context ?? ConversationContext.general,
      currentEmotion: context?.defaultEmotion ?? SherpiEmotion.happy,
      sessionMetadata: metadata ?? {},
    );

    // 환영 메시지 생성
    _addWelcomeMessage(context ?? ConversationContext.general);
  }

  /// 👋 환영 메시지 자동 추가
  Future<void> _addWelcomeMessage(ConversationContext context) async {
    final welcomeMessage = ChatMessage(
      id: _generateMessageId(),
      content: _getDefaultWelcomeMessage(context),
      sender: MessageSender.sherpi,
      timestamp: DateTime.now(),
      emotion: context.defaultEmotion,
      type: MessageType.text,
      metadata: {
        'is_welcome': true,
        'context': context.name,
      },
    );

    state = state.addMessage(welcomeMessage);
  }

  /// 🎯 기본 환영 메시지 가져오기
  String _getDefaultWelcomeMessage(ConversationContext context) {
    return switch (context) {
      ConversationContext.celebration => '축하해요! 🎉 이 기쁜 순간을 함께 나눠주세요!',
      ConversationContext.encouragement => '힘들어 보이시네요. 제가 옆에 있어요 💙',
      ConversationContext.guidance => '어떤 도움이 필요하신지 자세히 알려주세요 🤔',
      ConversationContext.reflection => '오늘 하루는 어땠나요? 함께 돌아봐요 ✨',
      ConversationContext.planning => '새로운 계획을 세워볼까요? 🎯',
      ConversationContext.crisis => '괜찮아요, 함께 해결해봐요 🤗',
      ConversationContext.milestone => '정말 특별한 순간이네요! 🏆',
      ConversationContext.casual => '편하게 이야기해요! 😄',
      ConversationContext.deep => '마음 깊은 이야기를 나눠볼까요? 💭',
      _ => '안녕하세요! 무엇을 도와드릴까요? 😊',
    };
  }

  /// 📨 메시지 ID 생성
  String _generateMessageId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
  }

  /// 📝 사용자 메시지 전송 (개인화 및 감정 인식 통합)
  Future<void> sendUserMessage(String content, {MessageType? type}) async {
    if (content.trim().isEmpty) return;

    // 사용자 메시지 추가
    final userMessage = ChatMessage(
      id: _generateMessageId(),
      content: content.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      type: type ?? MessageType.text,
    );

    state = state.addMessage(userMessage);

    // 감정 분석 트리거
    await _analyzeUserEmotion(userMessage);

    // 셰르피 응답 생성
    await _generateSherpiResponse(userMessage);
  }

  /// 🤖 셰르피 응답 생성
  Future<void> _generateSherpiResponse(ChatMessage userMessage) async {
    try {
      // 타이핑 표시 시작
      _showTypingIndicator();

      // 1. 대화 컨텍스트 분석
      final conversationContext =
          _analyzeConversationContext(userMessage.content);

      // 2. 기본 사용자 컨텍스트 구성
      final userContext = _buildUserContext(userMessage);

      // 3. 게임 컨텍스트 구성
      final gameContext = _buildGameContext();

      // 4. 컨텍스트 구성
      Map<String, dynamic> enhancedContext = {...userContext};

      // 5. 감정 기반 응답 향상
      final emotionState = _ref.read(emotionStateProvider);
      String emotionEnhancedResponse = '';
      Map<String, dynamic> emotionMetadata = {};

      if (emotionState.currentEmotion != null) {
        // 감정 적응형 응답 생성
        final adaptiveResponse =
            _ref.read(emotionStateProvider.notifier).generateAdaptiveResponse(
          conversationContext: {
            'conversation_type': conversationContext.name,
            'message_count': state.messageCount,
            'session_duration': state.duration.inMinutes,
          },
          customTrigger: userMessage.content,
        );

        // 감정 컨텍스트를 AI 응답에 추가
        enhancedContext['user_emotion'] =
            emotionState.currentEmotion!.type.displayName;
        enhancedContext['emotion_intensity'] =
            emotionState.currentEmotion!.intensity.displayName;
        enhancedContext['emotion_adaptive_hint'] = adaptiveResponse['message'];

        emotionMetadata =
            adaptiveResponse['adaptation_metadata'] as Map<String, dynamic>;
      }

      // 6. AI 응답 생성 (개인화 및 감정 컨텍스트 포함)
      final sherpiResponse = await _smartManager.getMessage(
        _mapToSherpiContext(conversationContext),
        enhancedContext,
        gameContext,
      );

      // 7. 타이핑 표시 제거
      _hideTypingIndicator();

      // 8. 감정 기반 셰르피 감정 선택 개선
      final selectedEmotion = emotionState.currentEmotion != null
          ? _selectEmotionBasedOnUserEmotion(
              emotionState.currentEmotion!, conversationContext)
          : _selectEmotionForResponse(
              conversationContext, sherpiResponse.message);

      // 9. 셰르피 메시지 추가
      final sherpiMessage = ChatMessage(
        id: _generateMessageId(),
        content: sherpiResponse.message,
        sender: MessageSender.sherpi,
        timestamp: DateTime.now(),
        emotion: selectedEmotion,
        type:
            _determineMessageType(conversationContext, sherpiResponse.message),
        metadata: {
          'response_source': sherpiResponse.source.name,
          'generation_duration_ms':
              sherpiResponse.generationDuration?.inMilliseconds,
          'conversation_context': conversationContext.name,
          'user_emotion': emotionState.currentEmotion?.type.id,
          'emotion_adaptation': emotionMetadata,
        },
      );

      state = state.addMessage(sherpiMessage);

      // 8. 글로벌 셰르피 상태 업데이트
      _ref
          .read(sherpiProvider.notifier)
          .changeEmotion(sherpiMessage.emotion ?? SherpiEmotion.happy);
    } catch (e) {
      LoggerService.instance.d('❌ 셰르피 응답 생성 실패: $e');
      _addErrorMessage();
    }
  }

  /// ⌨️ 타이핑 표시
  void _showTypingIndicator() {
    final typingMessage = ChatMessage(
      id: 'typing_${DateTime.now().millisecondsSinceEpoch}',
      content: '...',
      sender: MessageSender.sherpi,
      timestamp: DateTime.now(),
      type: MessageType.system,
      metadata: {'is_typing': true},
    );

    state = state.addMessage(typingMessage);
  }

  /// 🚫 타이핑 표시 제거
  void _hideTypingIndicator() {
    final messages =
        state.messages.where((m) => m.metadata?['is_typing'] != true).toList();

    state = state.updateMessages(messages);
  }

  /// 🔍 대화 컨텍스트 분석 (기존과 동일)
  ConversationContext _analyzeConversationContext(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains(RegExp(r'축하|기뻐|성공|달성|완료'))) {
      return ConversationContext.celebration;
    }
    if (message.contains(RegExp(r'힘들|어렵|포기|우울|스트레스'))) {
      return ConversationContext.encouragement;
    }
    if (message.contains(RegExp(r'어떻게|방법|도움|가이드'))) {
      return ConversationContext.guidance;
    }
    if (message.contains(RegExp(r'돌아보|회고|생각해|반성'))) {
      return ConversationContext.reflection;
    }
    if (message.contains(RegExp(r'계획|목표|미래|준비'))) {
      return ConversationContext.planning;
    }
    if (message.contains(RegExp(r'위기|문제|곤란|절망'))) {
      return ConversationContext.crisis;
    }

    return ConversationContext.general;
  }

  /// 🎯 SherpiContext로 매핑 (기존과 동일)
  SherpiContext _mapToSherpiContext(ConversationContext conversationContext) {
    return switch (conversationContext) {
      ConversationContext.celebration => SherpiContext.achievement,
      ConversationContext.encouragement => SherpiContext.encouragement,
      ConversationContext.guidance => SherpiContext.guidance,
      ConversationContext.planning => SherpiContext.general,
      ConversationContext.crisis => SherpiContext.encouragement,
      ConversationContext.milestone => SherpiContext.milestone,
      _ => SherpiContext.general,
    };
  }

  /// 👤 사용자 컨텍스트 구성
  Map<String, dynamic> _buildUserContext(ChatMessage userMessage) {
    return {
      '최근_메시지': userMessage.content,
      '대화_횟수': state.messageCount,
      '대화_시작시간': state.startTime.toIso8601String(),
      '대화_지속시간': state.duration.inMinutes,
      '사용자_메시지_수': state.messages.where((m) => m.isUserMessage).length,
      'AI_응답_수': state.messages.where((m) => m.isSherpiMessage).length,
    };
  }

  /// 🎮 게임 컨텍스트 구성 (기존과 동일)
  Map<String, dynamic> _buildGameContext() {
    return {
      '현재_대화상황': state.context.description,
      '셰르피_감정': state.currentEmotion.name,
      '세션_지속시간': '${state.duration.inMinutes}분',
    };
  }

  /// 😊 응답에 맞는 감정 선택 (기존과 동일)
  SherpiEmotion _selectEmotionForResponse(
      ConversationContext context, String response) {
    final responseText = response.toLowerCase();

    if (responseText.contains(RegExp(r'축하|대단|멋져|훌륭'))) {
      return SherpiEmotion.cheering;
    }
    if (responseText.contains(RegExp(r'놀라|와|정말|헉'))) {
      return SherpiEmotion.surprised;
    }
    if (responseText.contains(RegExp(r'생각|분석|고민'))) {
      return SherpiEmotion.thinking;
    }
    if (responseText.contains(RegExp(r'괜찮|힘내|위로'))) {
      return SherpiEmotion.sad;
    }

    return context.defaultEmotion;
  }

  /// 📝 메시지 타입 결정 (기존과 동일)
  MessageType _determineMessageType(
      ConversationContext context, String response) {
    final responseText = response.toLowerCase();

    if (responseText.contains(RegExp(r'축하|대단|성취'))) {
      return MessageType.celebration;
    }
    if (responseText.contains(RegExp(r'힘내|괜찮|위로'))) {
      return MessageType.encouragement;
    }
    if (responseText.contains(RegExp(r'제안|추천|해보세요|어떨까'))) {
      return MessageType.suggestion;
    }
    if (responseText.contains(RegExp(r'\?|궁금|어떤'))) {
      return MessageType.question;
    }

    return MessageType.text;
  }

  /// ❌ 오류 메시지 추가 (기존과 동일)
  void _addErrorMessage() {
    final errorMessage = ChatMessage(
      id: _generateMessageId(),
      content: '죄송해요, 지금은 응답하기 어려워요. 잠시 후 다시 시도해주세요! 😅',
      sender: MessageSender.sherpi,
      timestamp: DateTime.now(),
      emotion: SherpiEmotion.sad,
      type: MessageType.system,
      metadata: {'is_error': true},
    );

    state = state.addMessage(errorMessage);
  }

  /// 👍 메시지에 피드백 추가
  Future<void> addMessageFeedback({
    required String messageId,
    required double rating,
    String? comment,
  }) async {
    // 피드백 수집 (현재는 로그만 기록)
    LoggerService.instance.d('피드백 수집: $messageId - 평점: $rating, 코멘트: $comment');
  }

  /// 📊 개인화 통계 조회
  dynamic getPersonalizationStats() {
    return null; // 개인화 시스템 비활성화
  }

  /// 💡 대화 개선 추천
  dynamic getConversationRecommendations() {
    return null; // 개인화 시스템 비활성화
  }

  // 기존 메서드들 (saveConversation, loadConversation, endConversation 등)은 동일하게 유지
  /// 💾 대화 저장
  Future<void> saveConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationJson = jsonEncode(state.toJson());
      await prefs.setString(
          'sherpi_conversation_${state.sessionId}', conversationJson);

      final sessionList =
          prefs.getStringList('sherpi_conversation_sessions') ?? [];
      if (!sessionList.contains(state.sessionId)) {
        sessionList.add(state.sessionId);
        await prefs.setStringList('sherpi_conversation_sessions', sessionList);
      }
    } catch (e) {
      LoggerService.instance.d('❌ 대화 저장 실패: $e');
    }
  }

  /// 📂 대화 불러오기
  Future<void> loadConversation(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationJson =
          prefs.getString('sherpi_conversation_$sessionId');

      if (conversationJson != null) {
        final conversationData =
            jsonDecode(conversationJson) as Map<String, dynamic>;
        state = ConversationState.fromJson(conversationData);
      }
    } catch (e) {
      LoggerService.instance.d('❌ 대화 불러오기 실패: $e');
    }
  }

  /// 🔄 대화 종료
  void endConversation() {
    state = state.endConversation();
    saveConversation();
  }

  /// ⏸️ 대화 일시정지
  void pauseConversation() {
    state = state.pauseConversation();
    saveConversation();
  }

  /// 🎭 사용자 감정 분석
  Future<void> _analyzeUserEmotion(ChatMessage userMessage) async {
    try {
      // 텍스트 기반 감정 분석
      await _ref.read(emotionStateProvider.notifier).analyzeTextEmotion(
            userMessage.content,
            context: {
              'conversation_context': state.context.name,
              'session_id': state.sessionId,
              'message_count': state.messageCount,
            },
            trigger: 'chat_message',
          );

      // 행동 패턴 기반 감정 분석 (대화 기록이 충분한 경우)
      if (state.messages.length >= 5) {
        final recentBehaviors = _extractRecentBehaviorPatterns();
        if (recentBehaviors.isNotEmpty) {
          await _ref.read(emotionStateProvider.notifier).analyzeBehaviorEmotion(
            recentBehaviors,
            context: {
              'conversation_context': state.context.name,
              'session_duration': state.duration.inMinutes,
            },
          );
        }
      }
    } catch (e) {
      LoggerService.instance.d('감정 분석 실패: $e');
    }
  }

  /// 📊 최근 행동 패턴 추출
  List<BehaviorPattern> _extractRecentBehaviorPatterns() {
    final patterns = <BehaviorPattern>[];

    // 대화 기록에서 행동 패턴 추출
    final userMessages = state.messages
        .where((m) => m.isUserMessage)
        .toList()
        .reversed
        .take(10)
        .toList();

    for (final message in userMessages) {
      patterns.add(BehaviorPattern(
        userId: 'current_user', // TODO: 실제 사용자 ID 사용
        timestamp: message.timestamp,
        activityType: 'chat',
        duration: const Duration(minutes: 2), // 추정치
        activityData: {
          'message_type': message.type.name,
          'message_length': message.content.length,
          'context': state.context.name,
        },
        mood: _inferMoodFromMessage(message.content),
      ));
    }

    return patterns;
  }

  /// 😊 메시지에서 기분 추론
  String? _inferMoodFromMessage(String content) {
    final message = content.toLowerCase();

    if (message.contains(RegExp(r'기뻐|행복|좋아|최고'))) return 'happy';
    if (message.contains(RegExp(r'힘들|어려|우울|스트레스'))) return 'stressed';
    if (message.contains(RegExp(r'피곤|지쳐|졸려'))) return 'tired';
    if (message.contains(RegExp(r'화나|짜증|싫어'))) return 'angry';
    if (message.contains(RegExp(r'평온|차분|괜찮'))) return 'calm';

    return null;
  }

  /// 🎭 사용자 감정에 기반한 셰르피 감정 선택
  SherpiEmotion _selectEmotionBasedOnUserEmotion(
    EmotionSnapshot userEmotion,
    ConversationContext context,
  ) {
    // 사용자 감정에 공감하는 셰르피 감정 매핑
    switch (userEmotion.type.category) {
      case EmotionCategory.positive:
        // 긍정적 감정에는 함께 기뻐하기
        if (userEmotion.type == EmotionType.joy ||
            userEmotion.type == EmotionType.excitement) {
          return SherpiEmotion.cheering;
        }
        if (userEmotion.type == EmotionType.pride) {
          return SherpiEmotion.special;
        }
        return SherpiEmotion.happy;

      case EmotionCategory.negative:
        // 부정적 감정에는 공감과 위로
        if (userEmotion.type == EmotionType.sadness ||
            userEmotion.type == EmotionType.disappointment) {
          return SherpiEmotion.sad;
        }
        if (userEmotion.type == EmotionType.anxiety ||
            userEmotion.type == EmotionType.stress) {
          return SherpiEmotion.guiding;
        }
        if (userEmotion.type == EmotionType.anger) {
          return SherpiEmotion.thinking; // 차분하게 대응
        }
        return SherpiEmotion.guiding;

      case EmotionCategory.neutral:
        // 중립적 감정에는 상황에 맞게
        if (userEmotion.type == EmotionType.focused) {
          return SherpiEmotion.thinking;
        }
        if (userEmotion.type == EmotionType.tired) {
          return SherpiEmotion.guiding;
        }
        if (userEmotion.type == EmotionType.curious) {
          return SherpiEmotion.thinking;
        }
        return SherpiEmotion.defaults;

      case EmotionCategory.mixed:
      case EmotionCategory.unknown:
        // 복합적이거나 불분명한 감정에는 기본 대응
        return context.defaultEmotion;
    }
  }

  /// ▶️ 대화 재개
  void resumeConversation() {
    state = state.resumeConversation();
  }

  /// 🗑️ 메시지 삭제
  void deleteMessage(String messageId) {
    final updatedMessages =
        state.messages.where((m) => m.id != messageId).toList();
    state = state.updateMessages(updatedMessages);
  }

  /// 📊 대화 통계 (감정 정보 포함)
  Map<String, dynamic> getConversationStats() {
    final emotionState = _ref.read(emotionStateProvider);

    final baseStats = {
      'total_messages': state.messageCount,
      'user_messages': state.messages.where((m) => m.isUserMessage).length,
      'sherpi_messages': state.messages.where((m) => m.isSherpiMessage).length,
      'duration_minutes': state.duration.inMinutes,
      'session_id': state.sessionId,
      'start_time': state.startTime.toIso8601String(),
      'context': state.context.name,
      'current_emotion': state.currentEmotion.name,
    };

    // 감정 정보 추가
    if (emotionState.currentEmotion != null) {
      baseStats.addAll({
        'emotion_recognition_active': true,
        'current_user_emotion': emotionState.currentEmotion!.type.displayName,
        'emotion_intensity': emotionState.currentEmotion!.intensity.displayName,
        'emotion_confidence':
            emotionState.currentEmotion!.confidence.displayName,
        'emotional_wellbeing_score': emotionState.emotionalWellbeingScore,
        'emotional_stability': emotionState.emotionalStability,
      });
    }

    return baseStats;
  }
}

/// 개인화 통합 채팅 프로바이더
final enhancedChatConversationProvider =
    StateNotifierProvider<EnhancedChatConversationNotifier, ConversationState>(
        (ref) {
  // Chat integration service removed

  return EnhancedChatConversationNotifier(ref);
});

/// 편의 프로바이더들 (개인화 정보 포함)
final enhancedActiveConversationProvider = Provider<bool>((ref) {
  return ref.watch(
      enhancedChatConversationProvider.select((state) => state.isActive));
});

final enhancedConversationMessagesProvider = Provider<List<ChatMessage>>((ref) {
  return ref.watch(
      enhancedChatConversationProvider.select((state) => state.messages));
});

final enhancedLastSherpiMessageProvider = Provider<ChatMessage?>((ref) {
  return ref.watch(enhancedChatConversationProvider
      .select((state) => state.lastSherpiMessage));
});

final enhancedConversationStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(enhancedChatConversationProvider.notifier);
  return notifier.getConversationStats();
});

/// 🎭 감정 상태와 연동된 대화 분석 프로바이더
final conversationAnalysisProvider = Provider<Map<String, dynamic>>((ref) {
  final conversationState = ref.watch(enhancedChatConversationProvider);
  final emotionState = ref.watch(emotionStateProvider);

  return {
    'conversation_active': conversationState.isActive,
    'message_count': conversationState.messageCount,
    'session_duration': conversationState.duration.inMinutes,
    'emotion_recognition_active': emotionState.currentEmotion != null,
    'current_emotion': emotionState.currentEmotion?.type.displayName,
    'emotional_wellbeing': emotionState.emotionalWellbeingScore,
    'emotion_patterns':
        emotionState.activePatterns.map((p) => p.patternType).toList(),
    'last_update': DateTime.now().toIso8601String(),
  };
});

/// 🎭 감정 기반 대화 추천 프로바이더
final emotionBasedConversationRecommendationProvider =
    Provider<List<String>>((ref) {
  final emotionState = ref.watch(emotionStateProvider);
  final recommendations = <String>[];

  if (emotionState.currentEmotion == null) return recommendations;

  final emotionCategory = emotionState.currentEmotion!.type.category;
  final wellbeingScore = emotionState.emotionalWellbeingScore;

  // 감정 카테고리별 추천
  switch (emotionCategory) {
    case EmotionCategory.negative:
      recommendations.addAll([
        '격려가 필요하신가요? 힘든 일이 있으셨다면 함께 이야기해봐요.',
        '운동이나 명상으로 기분 전환을 해보는 건 어떨까요?',
        '작은 성취라도 축하해보세요. 긍정적인 변화를 만들 수 있어요.',
      ]);
      break;
    case EmotionCategory.positive:
      recommendations.addAll([
        '기쁜 일을 함께 축하해요! 이 감정을 일기로 기록해두면 어떨까요?',
        '좋은 기분을 유지하기 위해 감사한 일들을 생각해보세요.',
        '이 에너지로 새로운 목표에 도전해보는 건 어떨까요?',
      ]);
      break;
    case EmotionCategory.neutral:
      recommendations.addAll([
        '오늘의 목표를 설정해보는 건 어떨까요?',
        '새로운 활동에 도전해서 활력을 불어넣어보세요.',
        '친구나 가족과 소통하며 에너지를 충전해보세요.',
      ]);
      break;
    default:
      break;
  }

  // 웰빙 점수가 낮은 경우 추가 추천
  if (wellbeingScore < 0.5) {
    recommendations.add('감정 상태가 걱정되시나요? 전문가와 상담하는 것도 도움이 될 수 있어요.');
  }

  return recommendations.take(3).toList();
});
