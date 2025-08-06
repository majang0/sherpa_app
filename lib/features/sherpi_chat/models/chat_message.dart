import 'package:sherpa_app/core/constants/sherpi_emotions.dart';

/// 💬 채팅 메시지 모델
/// 
/// 셰르피와 사용자 간의 대화를 표현하는 기본 데이터 구조
class ChatMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final SherpiEmotion? emotion; // 셰르피 메시지일 때만 사용
  final MessageType type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.emotion,
    this.type = MessageType.text,
    this.metadata,
  });

  /// JSON 변환을 위한 생성자
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      emotion: json['emotion'] != null
          ? SherpiEmotion.values.firstWhere(
              (e) => e.name == json['emotion'],
              orElse: () => SherpiEmotion.defaults,
            )
          : null,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'emotion': emotion?.name,
      'type': type.name,
      'metadata': metadata,
    };
  }

  /// 복사본 생성
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    SherpiEmotion? emotion,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      emotion: emotion ?? this.emotion,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 셰르피 메시지인지 확인
  bool get isSherpiMessage => sender == MessageSender.sherpi;

  /// 사용자 메시지인지 확인
  bool get isUserMessage => sender == MessageSender.user;

  /// 특별한 메시지 타입인지 확인 (축하, 격려 등)
  bool get isSpecialMessage => type != MessageType.text;
}

/// 📨 메시지 발신자
enum MessageSender {
  user,    // 사용자
  sherpi,  // 셰르피
}

/// 🎭 메시지 타입
enum MessageType {
  text,           // 일반 텍스트
  celebration,    // 축하 메시지
  encouragement,  // 격려 메시지
  suggestion,     // 제안/조언
  question,       // 질문
  milestone,      // 마일스톤 달성
  memory,         // 기억/회상
  system,         // 시스템 메시지
}

/// 💡 메시지 타입별 유틸리티
extension MessageTypeExtension on MessageType {
  /// 메시지 타입에 맞는 아이콘
  String get icon {
    switch (this) {
      case MessageType.celebration:
        return '🎉';
      case MessageType.encouragement:
        return '💪';
      case MessageType.suggestion:
        return '💡';
      case MessageType.question:
        return '❓';
      case MessageType.milestone:
        return '🏆';
      case MessageType.memory:
        return '💭';
      case MessageType.system:
        return 'ℹ️';
      case MessageType.text:
      default:
        return '💬';
    }
  }

  /// 메시지 타입 설명
  String get description {
    switch (this) {
      case MessageType.celebration:
        return '축하 메시지';
      case MessageType.encouragement:
        return '격려 메시지';
      case MessageType.suggestion:
        return '제안 및 조언';
      case MessageType.question:
        return '질문';
      case MessageType.milestone:
        return '마일스톤 달성';
      case MessageType.memory:
        return '기억과 회상';
      case MessageType.system:
        return '시스템 알림';
      case MessageType.text:
      default:
        return '일반 대화';
    }
  }
}