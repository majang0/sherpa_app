import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/shared/providers/global_meeting_provider.dart';
import 'package:sherpa_app/shared/providers/global_user_provider.dart';
import 'package:sherpa_app/features/meetings/models/available_meeting_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('meeting creation → join → review flow updates state consistently',
      () async {
    final container = ProviderContainer();
    final notifier = container.read(globalMeetingProvider.notifier);

    final newMeeting = AvailableMeeting(
      id: 'integration_meeting',
      title: '통합 테스트 모임',
      description: '플로우 검증을 위한 모임',
      category: MeetingCategory.study,
      type: MeetingType.free,
      scope: MeetingScope.public,
      dateTime: DateTime.now().add(const Duration(days: 2)),
      location: '온라인',
      detailedLocation: 'Google Meet',
      maxParticipants: 15,
      currentParticipants: 5,
      tags: const ['통합테스트'],
      requirements: const ['편안한 복장'],
      preparationItems: const ['노트북'],
      hostName: '테스트 호스트',
      hostId: 'host_integration',
    );

    final added = await notifier.addMeeting(newMeeting);
    expect(added, isTrue);

    final afterCreation = container.read(globalMeetingProvider);
    expect(afterCreation.availableMeetings.first.id, 'integration_meeting');

    final joinResult = await notifier.joinMeeting(newMeeting);
    expect(joinResult, isTrue);

    final afterJoin = container.read(globalMeetingProvider);
    expect(
        afterJoin.myJoinedMeetings.any((m) => m.id == newMeeting.id), isTrue);

    notifier.completeMeetingReview(
      meetingId: newMeeting.id,
      satisfaction: 4.0,
      mood: 'happy',
      note: '아주 유익한 모임이었어요',
    );

    final userState = container.read(globalUserProvider);
    expect(userState.dailyRecords.meetingLogs, isNotEmpty);
    final latestLog = userState.dailyRecords.meetingLogs.last;
    expect(latestLog.meetingName, newMeeting.title);
    expect(latestLog.mood, '😊');
  });
}
