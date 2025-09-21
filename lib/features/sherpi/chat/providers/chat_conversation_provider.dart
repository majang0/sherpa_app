import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'dart:convert';

// Models
import '../models/chat_message.dart';
import '../models/conversation_state.dart';

// Core
import '../../../../core/constants/sherpi_emotions.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/managers/openai_sherpi_manager.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';

/// 💬 채팅 대화 관리 프로바이더
///
/// 셰르피와의 실시간 대화를 관리하고 메시지 히스토리를 보관합니다.
class ChatConversationNotifier extends StateNotifier<ConversationState> {
  final OpenAISherpiManager _smartManager = OpenAISherpiManager();
  final Ref _ref;
  Timer? _typingTimer;

  ChatConversationNotifier(this._ref) : super(_createInitialState());

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

    // 첫 인사 메시지 자동 생성
    _addWelcomeMessage(context ?? ConversationContext.general);
  }

  /// 👋 환영 메시지 자동 추가
  void _addWelcomeMessage(ConversationContext context) {
    final welcomeMessages = {
      ConversationContext.general: '안녕하세요! 무엇을 도와드릴까요? 😊',
      ConversationContext.celebration: '축하해요! 🎉 이 기쁜 순간을 함께 나눠주세요!',
      ConversationContext.encouragement: '힘들어 보이시네요. 제가 옆에 있어요 💙',
      ConversationContext.guidance: '어떤 도움이 필요하신지 자세히 알려주세요 🤔',
      ConversationContext.reflection: '오늘 하루는 어땠나요? 함께 돌아봐요 ✨',
      ConversationContext.planning: '새로운 계획을 세워볼까요? 🎯',
      ConversationContext.crisis: '괜찮아요, 함께 해결해봐요 🤗',
      ConversationContext.milestone: '정말 특별한 순간이네요! 🏆',
      ConversationContext.casual: '편하게 이야기해요! 😄',
      ConversationContext.deep: '마음 깊은 이야기를 나눠볼까요? 💭',
    };

    final welcomeMessage = ChatMessage(
      id: _generateMessageId(),
      content: welcomeMessages[context] ??
          welcomeMessages[ConversationContext.general]!,
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

  /// 📨 메시지 ID 생성
  String _generateMessageId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
  }

  /// 📝 사용자 메시지 전송
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

    // 셰르피 응답 생성 (타이핑 효과와 함께)
    await _generateSherpiResponse(userMessage);
  }

  /// 🤖 셰르피 응답 생성
  Future<void> _generateSherpiResponse(ChatMessage userMessage) async {
    try {
      // 타이핑 표시 시작
      _showTypingIndicator();

      // 대화 컨텍스트 분석
      final conversationContext =
          _analyzeConversationContext(userMessage.content);

      // 사용자 컨텍스트 구성
      final userContext = _buildUserContext(userMessage);

      // 게임 컨텍스트 구성 (기존 시스템과 연동)
      final gameContext = _buildGameContext();

      // AI 응답 생성
      final sherpiResponse = await _smartManager.getMessage(
        _mapToSherpiContext(conversationContext),
        userContext,
        gameContext,
      );

      // 타이핑 표시 제거
      _hideTypingIndicator();

      // 셰르피 메시지 추가
      final sherpiMessage = ChatMessage(
        id: _generateMessageId(),
        content: sherpiResponse.message,
        sender: MessageSender.sherpi,
        timestamp: DateTime.now(),
        emotion: _selectEmotionForResponse(
            conversationContext, sherpiResponse.message),
        type:
            _determineMessageType(conversationContext, sherpiResponse.message),
        metadata: {
          'response_source': sherpiResponse.source.name,
          'generation_duration_ms':
              sherpiResponse.generationDuration?.inMilliseconds,
          'conversation_context': conversationContext.name,
        },
      );

      state = state.addMessage(sherpiMessage);

      // 글로벌 셰르피 상태도 업데이트
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
    // 타이핑 메시지 임시 추가 (실제 구현에서는 UI에서 별도 처리)
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

  /// 🔍 대화 컨텍스트 분석
  ConversationContext _analyzeConversationContext(String userMessage) {
    final message = userMessage.toLowerCase();

    // 키워드 기반 컨텍스트 분석
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

  /// 🎯 SherpiContext로 매핑
  SherpiContext _mapToSherpiContext(ConversationContext conversationContext) {
    switch (conversationContext) {
      case ConversationContext.celebration:
        return SherpiContext.achievement;
      case ConversationContext.encouragement:
        return SherpiContext.encouragement;
      case ConversationContext.guidance:
        return SherpiContext.guidance;
      case ConversationContext.planning:
        return SherpiContext.general;
      case ConversationContext.crisis:
        return SherpiContext.encouragement;
      case ConversationContext.milestone:
        return SherpiContext.milestone;
      default:
        return SherpiContext.general;
    }
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

  /// 🎮 게임 컨텍스트 구성
  Map<String, dynamic> _buildGameContext() {
    // 기존 글로벌 프로바이더에서 데이터 가져오기
    // TODO: 실제 게임 데이터와 연동
    return {
      '현재_대화상황': state.context.description,
      '셰르피_감정': state.currentEmotion.name,
      '세션_지속시간': '${state.duration.inMinutes}분',
    };
  }

  /// 😊 응답에 맞는 감정 선택
  SherpiEmotion _selectEmotionForResponse(
      ConversationContext context, String response) {
    // 응답 내용 분석
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

    // 컨텍스트 기본 감정
    return context.defaultEmotion;
  }

  /// 📝 메시지 타입 결정
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

  /// ❌ 오류 메시지 추가
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

  /// 💾 대화 저장
  Future<void> saveConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationJson = jsonEncode(state.toJson());
      await prefs.setString(
          'sherpi_conversation_${state.sessionId}', conversationJson);

      // 세션 목록에도 추가
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

  /// 📊 대화 통계
  Map<String, dynamic> getConversationStats() {
    return {
      'total_messages': state.messageCount,
      'user_messages': state.messages.where((m) => m.isUserMessage).length,
      'sherpi_messages': state.messages.where((m) => m.isSherpiMessage).length,
      'duration_minutes': state.duration.inMinutes,
      'session_id': state.sessionId,
      'start_time': state.startTime.toIso8601String(),
      'context': state.context.name,
      'current_emotion': state.currentEmotion.name,
    };
  }
}

/// 프로바이더 정의
final chatConversationProvider =
    StateNotifierProvider<ChatConversationNotifier, ConversationState>((ref) {
  return ChatConversationNotifier(ref);
});

/// 편의 프로바이더들
final activeConversationProvider = Provider<bool>((ref) {
  return ref.watch(chatConversationProvider.select((state) => state.isActive));
});

final conversationMessagesProvider = Provider<List<ChatMessage>>((ref) {
  return ref.watch(chatConversationProvider.select((state) => state.messages));
});

final lastSherpiMessageProvider = Provider<ChatMessage?>((ref) {
  return ref.watch(
      chatConversationProvider.select((state) => state.lastSherpiMessage));
});

final conversationStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(chatConversationProvider.notifier);
  return notifier.getConversationStats();
});
