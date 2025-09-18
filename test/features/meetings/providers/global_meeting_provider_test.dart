import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/shared/providers/global_meeting_provider.dart';
import 'package:sherpa_app/shared/providers/global_user_provider.dart';
import 'package:sherpa_app/shared/providers/global_point_provider.dart';
import 'package:sherpa_app/features/meetings/models/available_meeting_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GlobalMeetingProvider joinMeeting', () {
    test('successful join updates state and user data', () async {
      final container = ProviderContainer();
      final notifier = container.read(globalMeetingProvider.notifier);
      final initialMeeting = notifier.state.availableMeetings.first;

      final logsBefore =
          container.read(globalUserProvider).dailyRecords.meetingLogs.length;
      final pointsBefore = container.read(globalPointProvider).totalPoints;

      final result = await notifier.joinMeeting(initialMeeting);

      expect(result, isTrue);

      final updatedState = container.read(globalMeetingProvider);
      final updatedMeeting = updatedState.availableMeetings
          .firstWhere((meeting) => meeting.id == initialMeeting.id);

      expect(updatedMeeting.currentParticipants,
          initialMeeting.currentParticipants + 1);
      expect(
          updatedState.myJoinedMeetings.any((m) => m.id == initialMeeting.id),
          isTrue);

      final logsAfter =
          container.read(globalUserProvider).dailyRecords.meetingLogs.length;
      expect(logsAfter, logsBefore + 1);

      final remainingPoints = container.read(globalPointProvider).totalPoints;
      expect(
        remainingPoints,
        pointsBefore - initialMeeting.participationFee.toInt(),
      );
    });

    test('joinMeeting returns false when points are insufficient', () async {
      final container = ProviderContainer();
      final pointNotifier = container.read(globalPointProvider.notifier);
      pointNotifier.state = pointNotifier.state.copyWith(totalPoints: 100);

      final notifier = container.read(globalMeetingProvider.notifier);
      final meeting = notifier.state.availableMeetings.first;
      final logsBefore =
          container.read(globalUserProvider).dailyRecords.meetingLogs.length;

      final result = await notifier.joinMeeting(meeting);

      expect(result, isFalse);

      final updatedState = container.read(globalMeetingProvider);
      expect(updatedState.myJoinedMeetings, isEmpty);
      final logsAfter =
          container.read(globalUserProvider).dailyRecords.meetingLogs.length;
      expect(logsAfter, logsBefore);
    });
  });

  group('GlobalMeetingProvider getRecommendedMeetings', () {
    test('prefers exercise/outdoor meetings when stamina is highest', () {
      final container = ProviderContainer();
      final userNotifier = container.read(globalUserProvider.notifier);
      userNotifier.state = userNotifier.state.copyWith(
        stats: userNotifier.state.stats.copyWith(
          stamina: 8,
          knowledge: 3,
          technique: 2,
          sociality: 1,
          willpower: 1,
        ),
      );

      final notifier = container.read(globalMeetingProvider.notifier);
      notifier.state = GlobalMeetingState(
        availableMeetings: [
          _meeting(id: 'study', category: MeetingCategory.study),
          _meeting(id: 'exercise', category: MeetingCategory.exercise),
          _meeting(id: 'culture', category: MeetingCategory.culture),
          _meeting(id: 'outdoor', category: MeetingCategory.outdoor),
        ],
        myJoinedMeetings: const [],
      );

      final recommendations = notifier.getRecommendedMeetings();

      expect(recommendations.map((m) => m.id).toList(),
          equals(['exercise', 'outdoor', 'study']));
    });

    test('prefers study/reading when knowledge is highest', () {
      final container = ProviderContainer();
      final userNotifier = container.read(globalUserProvider.notifier);
      userNotifier.state = userNotifier.state.copyWith(
        stats: userNotifier.state.stats.copyWith(
          stamina: 2,
          knowledge: 7,
          technique: 3,
          sociality: 1,
          willpower: 1,
        ),
      );

      final notifier = container.read(globalMeetingProvider.notifier);
      notifier.state = GlobalMeetingState(
        availableMeetings: [
          _meeting(id: 'networking', category: MeetingCategory.networking),
          _meeting(id: 'reading', category: MeetingCategory.reading),
          _meeting(id: 'study', category: MeetingCategory.study),
          _meeting(id: 'outdoor', category: MeetingCategory.outdoor),
        ],
        myJoinedMeetings: const [],
      );

      final recommendations = notifier.getRecommendedMeetings();

      expect(recommendations.map((m) => m.id).toList(),
          equals(['reading', 'study', 'networking']));
    });
  });
}

AvailableMeeting _meeting({
  required String id,
  required MeetingCategory category,
}) {
  return AvailableMeeting(
    id: id,
    title: '테스트 모임 $id',
    description: '설명',
    category: category,
    type: MeetingType.free,
    scope: MeetingScope.public,
    dateTime: DateTime.now().add(const Duration(days: 1)),
    location: '온라인',
    detailedLocation: 'Zoom',
    maxParticipants: 10,
    currentParticipants: 4,
    hostName: '테스트',
    hostId: 'host',
  );
}
