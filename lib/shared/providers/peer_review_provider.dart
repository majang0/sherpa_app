import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/main.dart';
import 'package:sherpa_app/shared/models/peer_review_model.dart';
import 'package:sherpa_app/shared/providers/global_point_provider.dart';
import 'package:sherpa_app/shared/providers/global_user_provider.dart';
import 'package:sherpa_app/shared/models/point_system_model.dart';

/// 동료 평가 Provider
///
/// **초기화 순서**: Level 2 (globalUserProvider 이후)
/// **의존성**: globalUserProvider, globalPointProvider
final peerReviewProvider =
    StateNotifierProvider<PeerReviewNotifier, List<PeerReview>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PeerReviewNotifier(prefs, ref);
});

class PeerReviewNotifier extends StateNotifier<List<PeerReview>> {
  final SharedPreferences _prefs;
  final Ref _ref;
  static const String _storageKey = 'peer_reviews';

  PeerReviewNotifier(this._prefs, this._ref) : super([]) {
    _loadReviews();
  }

  /// 평가 목록 로드
  Future<void> _loadReviews() async {
    try {
      final String? jsonString = _prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        state = [];
        return;
      }

      final List<dynamic> jsonList = jsonDecode(jsonString) as List;
      state = jsonList
          .map((json) => PeerReview.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ PeerReview 로드 실패: $e');
      state = [];
    }
  }

  /// 평가 목록 저장
  Future<void> _saveReviews() async {
    try {
      final jsonList = state.map((review) => review.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('❌ PeerReview 저장 실패: $e');
    }
  }

  /// 새 평가 추가
  ///
  /// **포인트 보상**: 100 Point 자동 지급
  /// **중복 방지**: 동일한 (meetingId, reviewerId, revieweeId) 조합은 1회만 허용
  Future<bool> addReview({
    required String meetingId,
    required String revieweeId,
    required double rating,
    String? comment,
  }) async {
    try {
      // 현재 사용자 ID 가져오기
      final currentUser = _ref.read(globalUserProvider);
      final reviewerId = currentUser.id;

      // 중복 확인
      final isDuplicate = state.any((review) =>
          review.meetingId == meetingId &&
          review.reviewerId == reviewerId &&
          review.revieweeId == revieweeId);

      if (isDuplicate) {
        print('⚠️ 이미 평가를 완료했습니다.');
        return false;
      }

      // 새 평가 생성
      final newReview = PeerReview.create(
        meetingId: meetingId,
        reviewerId: reviewerId,
        revieweeId: revieweeId,
        rating: rating,
        comment: comment,
      );

      // 상태 업데이트
      state = [...state, newReview];
      await _saveReviews();

      // ✅ 포인트 보상 지급 (100 Point)
      _ref
          .read(globalPointProvider.notifier)
          .addPoints(100, '동료 평가 완료');

      print('✅ 동료 평가 완료: ${newReview.id}');
      print('💰 +100 Point 지급');

      return true;
    } catch (e) {
      print('❌ 평가 추가 실패: $e');
      return false;
    }
  }

  /// 특정 모임의 내가 작성한 평가 목록
  List<PeerReview> getMyReviewsForMeeting(String meetingId) {
    final currentUser = _ref.read(globalUserProvider);
    return state
        .where((review) =>
            review.meetingId == meetingId &&
            review.reviewerId == currentUser.id)
        .toList();
  }

  /// 특정 모임에서 내가 받은 평가 목록
  List<PeerReview> getReviewsReceivedForMeeting(String meetingId) {
    final currentUser = _ref.read(globalUserProvider);
    return state
        .where((review) =>
            review.meetingId == meetingId &&
            review.revieweeId == currentUser.id)
        .toList();
  }

  /// 특정 사용자가 받은 평균 별점
  double getAverageRating(String userId) {
    final reviews =
        state.where((review) => review.revieweeId == userId).toList();

    if (reviews.isEmpty) return 0.0;

    final totalRating = reviews.fold<double>(
      0.0,
      (sum, review) => sum + review.rating,
    );

    return totalRating / reviews.length;
  }

  /// 특정 모임에 참여한 사용자 중 아직 평가하지 않은 사용자 목록
  ///
  /// 실제 구현에서는 MeetingLog의 참석자 목록을 가져와야 합니다.
  /// 여기서는 간단한 예시입니다.
  List<String> getUnreviewedParticipants(
      String meetingId, List<String> participantIds) {
    final currentUser = _ref.read(globalUserProvider);
    final reviewedIds = state
        .where((review) =>
            review.meetingId == meetingId &&
            review.reviewerId == currentUser.id)
        .map((review) => review.revieweeId)
        .toSet();

    return participantIds
        .where((id) => id != currentUser.id && !reviewedIds.contains(id))
        .toList();
  }

  /// 모든 평가 삭제 (디버그용)
  Future<void> clearAllReviews() async {
    state = [];
    await _prefs.remove(_storageKey);
    print('🗑️ 모든 평가 삭제 완료');
  }
}
