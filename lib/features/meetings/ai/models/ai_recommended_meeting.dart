/// AI 추천 모임 모델
/// AI가 추천한 모임과 추천 이유, 매칭 점수 등을 포함하는 데이터 모델
library;

import 'package:sherpa_app/features/meetings/models/available_meeting_model.dart';

/// AI가 추천한 모임 정보
class AIRecommendedMeeting {
  /// 추천된 모임
  final AvailableMeeting meeting;

  /// 매칭 점수 (0.0 ~ 1.0)
  final double matchScore;

  /// AI가 생성한 추천 이유
  final String reason;

  /// 핵심 매칭 포인트들
  final List<String> keyPoints;

  /// 추천 우선순위 (1이 가장 높음)
  final int priority;

  /// 추천 생성 시간
  final DateTime createdAt;

  const AIRecommendedMeeting({
    required this.meeting,
    required this.matchScore,
    required this.reason,
    required this.keyPoints,
    required this.priority,
    required this.createdAt,
  });

  /// JSON 파싱을 위한 팩토리 메서드
  factory AIRecommendedMeeting.fromJson(
      Map<String, dynamic> json, AvailableMeeting meeting) {
    return AIRecommendedMeeting(
      meeting: meeting,
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
      keyPoints: (json['keyPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      priority: json['priority'] as int? ?? 0,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'meetingId': meeting.id,
      'matchScore': matchScore,
      'reason': reason,
      'keyPoints': keyPoints,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 매칭 점수를 퍼센트로 변환
  int get matchPercentage => (matchScore * 100).round();

  /// 매칭 레벨 계산
  String get matchLevel {
    if (matchScore >= 0.9) return '완벽한 매칭';
    if (matchScore >= 0.8) return '매우 좋은 매칭';
    if (matchScore >= 0.7) return '좋은 매칭';
    if (matchScore >= 0.6) return '적절한 매칭';
    return '일반 매칭';
  }
}
