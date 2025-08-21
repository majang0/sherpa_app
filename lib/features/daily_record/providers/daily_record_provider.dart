import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';

// 일일 기록은 글로벌 사용자 데이터에서 직접 관리됩니다.
// 이 파일의 모든 providers는 globalUserProvider에서 데이터를 가져와 제공합니다.

// 걸음수 업데이트 함수
final updateStepsProvider = Provider<void Function(int steps)>((ref) {
  return (int steps) {
    ref.read(globalUserProvider.notifier).updateSteps(steps);
  };
});

// 집중 시간 업데이트 함수
final updateFocusTimeProvider = Provider<void Function(int minutes)>((ref) {
  return (int minutes) {
    ref.read(globalUserProvider.notifier).updateFocusTime(minutes);
  };
});

// 독서 기록 추가 함수
final addReadingLogProvider = Provider<void Function(ReadingLog log)>((ref) {
  return (ReadingLog log) {
    ref.read(globalUserProvider.notifier).addReadingLog(log);
  };
});

// 모임 기록 추가 함수
final addMeetingLogProvider = Provider<void Function(MeetingLog log)>((ref) {
  return (MeetingLog log) {
    ref.read(globalUserProvider.notifier).addMeetingLog(log);
  };
});

// 운동 기록 추가 함수
final addExerciseLogProvider = Provider<void Function(ExerciseLog log)>((ref) {
  return (ExerciseLog log) {
    ref.read(globalUserProvider.notifier).addExerciseLog(log);
  };
});

// 일기 기록 추가 함수
final addDiaryLogProvider = Provider<void Function(DiaryLog log)>((ref) {
  return (DiaryLog log) {
    ref.read(globalUserProvider.notifier).addDiaryLog(log);
  };
});

// 영화 기록 추가 함수
final addMovieLogProvider = Provider<void Function(MovieLog log)>((ref) {
  return (MovieLog log) {
    ref.read(globalUserProvider.notifier).addMovieLog(log);
  };
});

// 일일 목표 완료 함수
final completeDailyGoalProvider = Provider<void Function(String goalId)>((ref) {
  return (String goalId) {
    ref.read(globalUserProvider.notifier).completeDailyGoal(goalId);
  };
});