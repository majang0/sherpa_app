import 'package:uuid/uuid.dart';

/// 동료 평가 모델
///
/// 모임 참석자들이 서로 평가할 수 있는 기능.
/// 별점(1-5)과 선택적 코멘트를 포함합니다.
///
/// **포인트 보상**: 평가 완료 시 100 Point 지급
/// **저장 방식**: SharedPreferences ('peer_reviews' 키)
class PeerReview {
  final String id;
  final String meetingId; // MeetingLog.id 참조
  final String reviewerId; // 평가자 ID
  final String revieweeId; // 피평가자 ID
  final double rating; // 1.0 ~ 5.0
  final String? comment; // 선택적 코멘트 (최대 200자)
  final DateTime createdAt;

  const PeerReview({
    required this.id,
    required this.meetingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  /// Factory: 새 평가 생성
  factory PeerReview.create({
    required String meetingId,
    required String reviewerId,
    required String revieweeId,
    required double rating,
    String? comment,
  }) {
    return PeerReview(
      id: const Uuid().v4(),
      meetingId: meetingId,
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      rating: rating.clamp(1.0, 5.0), // 1.0~5.0 범위 강제
      comment: comment?.trim(),
      createdAt: DateTime.now(),
    );
  }

  /// 별점을 정수로 반환 (UI 표시용)
  int get ratingInt => rating.round();

  /// 코멘트 미리보기 (50자 제한)
  String get commentPreview {
    if (comment == null || comment!.isEmpty) return '';
    if (comment!.length <= 50) return comment!;
    return '${comment!.substring(0, 50)}...';
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON 역직렬화
  factory PeerReview.fromJson(Map<String, dynamic> json) {
    return PeerReview(
      id: json['id'] as String? ?? '',
      meetingId: json['meetingId'] as String? ?? '',
      reviewerId: json['reviewerId'] as String? ?? '',
      revieweeId: json['revieweeId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 3.0,
      comment: json['comment'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// 복사본 생성
  PeerReview copyWith({
    String? id,
    String? meetingId,
    String? reviewerId,
    String? revieweeId,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return PeerReview(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeerReview && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
