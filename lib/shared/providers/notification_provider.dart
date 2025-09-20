import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';

// 알림 상태 관리 Provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationItem>>((ref) {
  return NotificationNotifier();
});

// 읽지 않은 알림 개수 Provider
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.where((n) => !n.isRead).length;
});

// 알림 상태 관리 클래스
class NotificationNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationNotifier() : super([]) {
    _loadNotifications();
  }

  // 유틸리티 메서드: 고유 ID 생성
  String _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // 유틸리티 메서드: 보상 텍스트 생성
  String _generateRewardText({int? xp, int? points}) {
    final rewards = <String>[];
    if (xp != null && xp > 0) rewards.add('${xp} XP');
    if (points != null && points > 0) rewards.add('${points}P');
    return rewards.isNotEmpty ? rewards.join(' + ') : '';
  }

  // SharedPreferences에서 알림 로드
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');

      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        state = decoded.map((json) => NotificationItem.fromJson(json)).toList();
      } else {
        // 초기 샘플 알림 생성 (개발용)
        _createInitialNotifications();
      }
    } catch (e) {
      print('알림 로드 실패: $e');
      state = [];
    }
  }

  // SharedPreferences에 알림 저장
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson =
          jsonEncode(state.map((n) => n.toJson()).toList());
      await prefs.setString('notifications', notificationsJson);
    } catch (e) {
      print('알림 저장 실패: $e');
    }
  }

  // 초기 샘플 알림 생성
  void _createInitialNotifications() {
    state = [
      NotificationItem(
        id: _generateNotificationId(),
        type: NotificationType.goalComplete,
        title: '오늘의 목표 달성! 🎉',
        message: '운동 30분 목표를 완료했습니다',
        detail: '오늘 설정한 운동 목표를 모두 달성했습니다. 100 포인트를 획득했습니다!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        metadata: {'points': 100, 'goal': '운동 30분'},
      ),
      NotificationItem(
        id: (DateTime.now().millisecondsSinceEpoch - 1).toString(),
        type: NotificationType.dailyQuestReward,
        title: '일일 퀘스트 완료! 📦',
        message: '보상 상자를 획득했습니다',
        detail: '일일 퀘스트를 모두 완료하여 보상 상자를 획득했습니다. 지금 열어보세요!',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        metadata: {'questName': '하루 3번 운동하기', 'reward': 'bronze_chest'},
      ),
      NotificationItem(
        id: (DateTime.now().millisecondsSinceEpoch - 2).toString(),
        type: NotificationType.firstClimb,
        title: '첫 등반 성공! 🏔️',
        message: '오늘의 첫 등반을 시작했습니다',
        detail: '한라산 등반을 시작했습니다. 정상까지 화이팅!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: {'mountain': '한라산', 'altitude': 1950},
      ),
    ];
    _saveNotifications();
  }

  // 알림 추가
  void addNotification(NotificationItem notification) {
    state = [notification, ...state];
    _saveNotifications();
  }

  // 알림 읽음 처리
  void markAsRead(String notificationId) {
    state = state.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
    _saveNotifications();
  }

  // 읽은 알림 제거
  void removeReadNotifications() {
    state = state.where((n) => !n.isRead).toList();
    _saveNotifications();
  }

  // 특정 알림 제거
  void removeNotification(String notificationId) {
    state = state.where((n) => n.id != notificationId).toList();
    _saveNotifications();
  }

  // 모든 알림 읽음 처리
  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
    _saveNotifications();
  }

  // 모든 알림 삭제
  void clearAll() {
    state = [];
    _saveNotifications();
  }

  // 특정 이벤트에 대한 알림 생성 헬퍼 메서드들

  // 오늘의 목표 완료 알림
  void notifyGoalComplete(String goalName, {int? xp, int? points}) {
    final rewardText = _generateRewardText(xp: xp, points: points);
    final displayReward = rewardText.isNotEmpty ? rewardText : '보상';

    addNotification(NotificationItem(
      id: _generateNotificationId(),
      type: NotificationType.goalComplete,
      title: '오늘의 목표 달성! 🎉',
      message: '$goalName 목표를 완료했습니다 ($displayReward)',
      detail: '축하합니다! "$goalName" 목표를 성공적으로 달성했습니다. $displayReward를 획득했습니다!',
      createdAt: DateTime.now(),
      metadata: {'goalName': goalName, 'xp': xp, 'points': points},
    ));
  }

  // 일일 퀘스트 보상 알림
  void notifyDailyQuestReward(String questName, {int? xp, int? points}) {
    final rewardText = _generateRewardText(xp: xp, points: points);
    final displayReward = rewardText.isNotEmpty ? rewardText : '보상 상자';

    addNotification(NotificationItem(
      id: _generateNotificationId(),
      type: NotificationType.dailyQuestReward,
      title: '일일 퀘스트 마스터! 📦',
      message: '일일 퀘스트 보상 획득 ($displayReward)',
      detail: '"$questName"를 달성했습니다! $displayReward를 획득했습니다.',
      createdAt: DateTime.now(),
      metadata: {'questName': questName, 'xp': xp, 'points': points},
    ));
  }

  // 주간 퀘스트 보상 알림
  void notifyWeeklyQuestReward(String questName, {int? xp, int? points}) {
    final rewardText = _generateRewardText(xp: xp, points: points);
    final displayReward = rewardText.isNotEmpty ? rewardText : '특별 보상';

    addNotification(NotificationItem(
      id: _generateNotificationId(),
      type: NotificationType.weeklyQuestReward,
      title: '주간 퀘스트 레전드! 🏆',
      message: '주간 퀘스트 보상 획득 ($displayReward)',
      detail: '"$questName"를 달성했습니다! $displayReward가 지급되었습니다.',
      createdAt: DateTime.now(),
      metadata: {'questName': questName, 'xp': xp, 'points': points},
    ));
  }

  // 첫 등반 성공 알림
  void notifyFirstClimb(String mountainName, {int? xp, int? points}) {
    final rewardText = _generateRewardText(xp: xp, points: points);
    final rewardDisplay = rewardText.isNotEmpty ? ' ($rewardText)' : '';

    addNotification(NotificationItem(
      id: _generateNotificationId(),
      type: NotificationType.firstClimb,
      title: '오늘의 첫 등반 성공! 🏔️',
      message: '$mountainName 정복$rewardDisplay',
      detail:
          '오늘의 첫 등반을 성공적으로 완료했습니다! $mountainName 정상 도달${rewardText.isNotEmpty ? '로 $rewardText를 획득했습니다' : ''}!',
      createdAt: DateTime.now(),
      metadata: {'mountain': mountainName, 'xp': xp, 'points': points},
    ));
  }

  // 모임 참가 완료 알림
  void notifyMeetingComplete(String meetingName, int participants, {int? fee}) {
    final feeText = fee != null ? ' (${fee}P 결제 완료)' : '';
    addNotification(NotificationItem(
      id: _generateNotificationId(),
      type: NotificationType.meetingComplete,
      title: '모임 참가 완료! 👥',
      message: '$meetingName 모임에 참가했습니다$feeText',
      detail:
          '"$meetingName" 모임에 성공적으로 참가했습니다. 총 $participants명이 함께했습니다!${fee != null ? ' 참가비 ${fee}P가 결제되었습니다.' : ''}',
      createdAt: DateTime.now(),
      metadata: {
        'meetingName': meetingName,
        'participants': participants,
        'fee': fee
      },
    ));
  }

  // 프로필 업데이트 알림
  void notifyProfileUpdate(ProfileUpdateType updateType,
      {String? oldValue, String? newValue}) {
    final String title;
    final String message;
    final String detail;

    switch (updateType) {
      case ProfileUpdateType.photo:
        title = '프로필 사진 변경 완료! 📸';
        message = '프로필 사진이 업데이트되었습니다';
        detail = '새로운 프로필 사진이 성공적으로 적용되었습니다.';
        break;
      case ProfileUpdateType.nickname:
        title = '닉네임 변경 완료! ✏️';
        message = '닉네임이 "$newValue"로 변경되었습니다';
        detail = '닉네임이 "${oldValue ?? '이전 닉네임'}"에서 "$newValue"로 변경되었습니다.';
        break;
    }

    addNotification(NotificationItem(
      id: _generateNotificationId(),
      type: NotificationType.profileUpdate,
      title: title,
      message: message,
      detail: detail,
      createdAt: DateTime.now(),
      profileUpdateType: updateType,
      metadata: {'oldValue': oldValue, 'newValue': newValue},
    ));
  }
}
