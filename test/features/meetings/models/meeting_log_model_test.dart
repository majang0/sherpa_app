import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherpa_app/features/meetings/models/meeting_log_model.dart';
import 'package:sherpa_app/features/meetings/models/available_meeting_model.dart';

void main() {
  group('MeetingLog', () {
    final baseLog = MeetingLog(
      id: 'log_1',
      date: DateTime.utc(2025, 1, 1, 10),
      meetingName: '주말 러닝 모임',
      category: MeetingCategory.exercise.displayName,
      satisfaction: 4.5,
      mood: 'happy',
      note: '테스트 노트',
      isShared: true,
    );

    test('toJson / fromJson round-trip preserves data', () {
      final json = baseLog.toJson();
      final restored = MeetingLog.fromJson(json);

      expect(restored.id, baseLog.id);
      expect(restored.date.toIso8601String(), baseLog.date.toIso8601String());
      expect(restored.meetingName, baseLog.meetingName);
      expect(restored.category, baseLog.category);
      expect(restored.satisfaction, baseLog.satisfaction);
      expect(restored.mood, baseLog.mood);
      expect(restored.note, baseLog.note);
      expect(restored.isShared, baseLog.isShared);
    });

    test('fromJson applies defensive defaults when fields missing', () {
      final restored = MeetingLog.fromJson({});

      expect(restored.id, isEmpty);
      expect(restored.meetingName, isEmpty);
      expect(restored.category, isEmpty);
      expect(restored.satisfaction, 0);
      expect(restored.mood, 'happy');
      expect(restored.note, isNull);
      expect(restored.isShared, isFalse);
    });

    test('shortName truncates names longer than six characters', () {
      final expectedShort = '${baseLog.meetingName.substring(0, 6)}...';
      expect(baseLog.shortName, expectedShort);
      final shortLog = MeetingLog(
        id: 'short',
        date: DateTime(2025, 1, 1),
        meetingName: '독서모임',
        category: '독서',
        satisfaction: 3.0,
        mood: 'good',
      );
      expect(shortLog.shortName, '독서모임');
    });

    test('satisfactionColor reflects score thresholds', () {
      expect(baseLog.satisfactionColor, const Color(0xFF10B981));

      final medium = MeetingLog(
        id: 'medium',
        date: baseLog.date,
        meetingName: baseLog.meetingName,
        category: baseLog.category,
        satisfaction: 3.2,
        mood: baseLog.mood,
      );
      expect(medium.satisfactionColor, const Color(0xFFF59E0B));

      final low = MeetingLog(
        id: 'low',
        date: baseLog.date,
        meetingName: baseLog.meetingName,
        category: baseLog.category,
        satisfaction: 2.5,
        mood: baseLog.mood,
      );
      expect(low.satisfactionColor, const Color(0xFFEF4444));
    });

    test('moodIcon returns appropriate emoji', () {
      expect(baseLog.moodIcon, '😊');
      final tiredLog = MeetingLog(
        id: 'tired',
        date: baseLog.date,
        meetingName: baseLog.meetingName,
        category: baseLog.category,
        satisfaction: baseLog.satisfaction,
        mood: 'tired',
      );
      expect(tiredLog.moodIcon, '😴');

      final unknownMoodLog = MeetingLog(
        id: 'unknown',
        date: baseLog.date,
        meetingName: baseLog.meetingName,
        category: baseLog.category,
        satisfaction: baseLog.satisfaction,
        mood: 'unknown',
      );
      expect(unknownMoodLog.moodIcon, '😊');
    });

    test('categoryIcon pulls emoji from centralized categories', () {
      expect(baseLog.categoryIcon, '🏃');
    });
  });
}
