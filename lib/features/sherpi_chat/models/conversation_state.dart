import 'package:sherpa_app/features/sherpi_chat/models/chat_message.dart';
import 'package:sherpa_app/core/constants/sherpi_emotions.dart';

/// 🗣️ 대화 상태 모델
/// 
/// 현재 진행 중인 셰르피와의 대화 세션을 관리합니다.
class ConversationState {
  final String sessionId;
  final List<ChatMessage> messages;
  final ConversationStatus status;
  final SherpiEmotion currentEmotion;
  final DateTime startTime;
  final DateTime? endTime;
  final ConversationContext context;
  final Map<String, dynamic> sessionMetadata;

  const ConversationState({
    required this.sessionId,
    this.messages = const [],
    this.status = ConversationStatus.active,
    this.currentEmotion = SherpiEmotion.happy,
    required this.startTime,
    this.endTime,
    this.context = ConversationContext.general,
    this.sessionMetadata = const {},
  });

  /// 복사본 생성
  ConversationState copyWith({
    String? sessionId,
    List<ChatMessage>? messages,
    ConversationStatus? status,
    SherpiEmotion? currentEmotion,
    DateTime? startTime,
    DateTime? endTime,
    ConversationContext? context,
    Map<String, dynamic>? sessionMetadata,
  }) {
    return ConversationState(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      status: status ?? this.status,
      currentEmotion: currentEmotion ?? this.currentEmotion,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      context: context ?? this.context,
      sessionMetadata: sessionMetadata ?? this.sessionMetadata,
    );
  }

  /// 새 메시지 추가
  ConversationState addMessage(ChatMessage message) {
    final updatedMessages = [...messages, message];
    return copyWith(
      messages: updatedMessages,
      currentEmotion: message.emotion ?? currentEmotion,
    );
  }

  /// 메시지 목록 업데이트
  ConversationState updateMessages(List<ChatMessage> newMessages) {
    return copyWith(messages: newMessages);
  }

  /// 대화 종료
  ConversationState endConversation() {
    return copyWith(
      status: ConversationStatus.ended,
      endTime: DateTime.now(),
    );
  }

  /// 대화 일시정지
  ConversationState pauseConversation() {
    return copyWith(status: ConversationStatus.paused);
  }

  /// 대화 재개
  ConversationState resumeConversation() {
    return copyWith(status: ConversationStatus.active);
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'status': status.name,
      'currentEmotion': currentEmotion.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'context': context.name,
      'sessionMetadata': sessionMetadata,
    };
  }

  /// JSON에서 생성
  factory ConversationState.fromJson(Map<String, dynamic> json) {
    return ConversationState(
      sessionId: json['sessionId'] as String,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
      status: ConversationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ConversationStatus.active,
      ),
      currentEmotion: SherpiEmotion.values.firstWhere(
        (e) => e.name == json['currentEmotion'],
        orElse: () => SherpiEmotion.happy,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      context: ConversationContext.values.firstWhere(
        (c) => c.name == json['context'],
        orElse: () => ConversationContext.general,
      ),
      sessionMetadata: json['sessionMetadata'] as Map<String, dynamic>? ?? {},
    );
  }

  // Getters
  bool get isActive => status == ConversationStatus.active;
  bool get isEnded => status == ConversationStatus.ended;
  bool get isPaused => status == ConversationStatus.paused;
  bool get hasMessages => messages.isNotEmpty;
  int get messageCount => messages.length;
  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;
  ChatMessage? get lastSherpiMessage => 
    messages.where((m) => m.isSherpiMessage).isNotEmpty 
        ? messages.where((m) => m.isSherpiMessage).last 
        : null;
  ChatMessage? get lastUserMessage => 
    messages.where((m) => m.isUserMessage).isNotEmpty 
        ? messages.where((m) => m.isUserMessage).last 
        : null;
  
  /// 대화 지속 시간
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// 대화 요약 생성
  String get summary {
    if (messages.isEmpty) return '대화가 시작되지 않았습니다.';
    
    final userMessageCount = messages.where((m) => m.isUserMessage).length;
    final sherpiMessageCount = messages.where((m) => m.isSherpiMessage).length;
    
    return '총 ${messageCount}개 메시지 (사용자: $userMessageCount, 셰르피: $sherpiMessageCount)';
  }
}

/// 🔄 대화 진행 상태
enum ConversationStatus {
  active,   // 활성화 (진행 중)
  paused,   // 일시정지
  ended,    // 종료
  archived, // 보관됨
}

/// 🎯 대화 맥락/상황
enum ConversationContext {
  general,        // 일반 대화
  celebration,    // 축하 상황
  encouragement,  // 격려 필요
  guidance,       // 조언/가이드
  reflection,     // 회고/돌아보기
  planning,       // 계획 세우기
  crisis,         // 위기/어려운 상황
  milestone,      // 마일스톤 달성
  casual,         // 일상 대화
  deep,           // 깊은 대화
}

/// 💡 대화 맥락별 유틸리티
extension ConversationContextExtension on ConversationContext {
  /// 맥락에 맞는 기본 셰르피 감정
  SherpiEmotion get defaultEmotion {
    switch (this) {
      case ConversationContext.celebration:
        return SherpiEmotion.cheering;
      case ConversationContext.encouragement:
        return SherpiEmotion.sad; // 위로하는 표정
      case ConversationContext.guidance:
        return SherpiEmotion.guiding;
      case ConversationContext.reflection:
        return SherpiEmotion.thinking;
      case ConversationContext.planning:
        return SherpiEmotion.thinking;
      case ConversationContext.crisis:
        return SherpiEmotion.sad;
      case ConversationContext.milestone:
        return SherpiEmotion.special;
      case ConversationContext.deep:
        return SherpiEmotion.thinking;
      case ConversationContext.casual:
      case ConversationContext.general:
      default:
        return SherpiEmotion.happy;
    }
  }

  /// 맥락 설명
  String get description {
    switch (this) {
      case ConversationContext.celebration:
        return '축하하는 순간';
      case ConversationContext.encouragement:
        return '격려가 필요한 상황';
      case ConversationContext.guidance:
        return '조언과 가이드';
      case ConversationContext.reflection:
        return '돌아보고 회고하기';
      case ConversationContext.planning:
        return '계획 세우기';
      case ConversationContext.crisis:
        return '어려운 상황';
      case ConversationContext.milestone:
        return '마일스톤 달성';
      case ConversationContext.deep:
        return '깊은 대화';
      case ConversationContext.casual:
        return '일상 대화';
      case ConversationContext.general:
      default:
        return '일반 대화';
    }
  }
}