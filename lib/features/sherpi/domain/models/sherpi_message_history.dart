import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';

/// 📝 셰르피 메시지 히스토리 모델
class SherpiMessageHistory {
  final String id;
  final SherpiEmotion emotion;
  final String message;
  final SherpiContext context;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  SherpiMessageHistory({
    required this.id,
    required this.emotion,
    required this.message,
    required this.context,
    required this.timestamp,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  /// JSON으로부터 생성
  factory SherpiMessageHistory.fromJson(Map<String, dynamic> json) {
    return SherpiMessageHistory(
      id: json['id'] as String,
      emotion: SherpiEmotion.values.firstWhere(
        (e) => e.name == json['emotion'],
        orElse: () => SherpiEmotion.defaults,
      ),
      message: json['message'] as String,
      context: SherpiContext.values.firstWhere(
        (c) => c.name == json['context'],
        orElse: () => SherpiContext.general,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emotion': emotion.name,
      'message': message,
      'context': context.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}
