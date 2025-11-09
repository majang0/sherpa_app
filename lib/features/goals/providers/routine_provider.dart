import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/routine_model.dart';

/// 루틴 Provider
///
/// 사용자가 설정한 루틴을 관리합니다.
/// SharedPreferences를 통해 데이터를 저장/로드합니다.
final routineProvider =
    StateNotifierProvider<RoutineNotifier, List<RoutineModel>>((ref) {
  return RoutineNotifier();
});

class RoutineNotifier extends StateNotifier<List<RoutineModel>> {
  static const String _storageKey = 'routines_list';
  static const String _previousRoutinesKey = 'previous_routines_list';

  RoutineNotifier() : super([]) {
    _loadRoutines();
  }

  /// 루틴 로드 (SharedPreferences)
  Future<void> _loadRoutines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final routines = jsonList
            .map((json) => RoutineModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // 활성 루틴만 필터링 (finishedAt이 null인 것들)
        state = routines.where((routine) => routine.finishedAt == null).toList()
          ..sort(_compareRoutines); // 우선순위 정렬
      } else {
        // 데이터가 없으면 샘플 데이터 초기화
        await _initializeSampleData();
      }
    } catch (e) {
      // 로드 실패 시 빈 리스트 유지
      state = [];
    }
  }

  /// AI goal.txt 기반 샘플 데이터 초기화
  Future<void> _initializeSampleData() async {
    final uuid = const Uuid();
    final now = DateTime.now();

    // ==================== 이전 루틴 (완료된 루틴) ====================
    final previousRoutines = [
      // 1. [문화] 주 1회 독서 한 권 완독하기 / 2025.08.10~2025.10.12 / 미완주
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.culture,
        frequency: '주1회',
        name: '주 1회 독서 한 권 완독하기',
        timePreference: '아무때나',
        weekdays: const [],
        period: '언제까지',
        endDate: DateTime(2025, 10, 12),
        checkHistory: _generateCheckHistory(
          startDate: DateTime(2025, 8, 10),
          endDate: DateTime(2025, 10, 12),
          frequency: '주1회',
          completionRate: 0.75, // 미완주 (75%)
        ),
        completionRate: 0.75,
        isCompleted: false,
        createdAt: DateTime(2025, 8, 10),
        finishedAt: DateTime(2025, 10, 12),
      ),
      // 2. [운동] 매주 월요일 등산하기 / 2025.09.01~2025.10.25 / 100% / 완주
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.exercise,
        frequency: '매주',
        name: '매주 월요일 등산하기',
        timePreference: '아무때나',
        weekdays: const ['월'],
        period: '언제까지',
        endDate: DateTime(2025, 10, 25),
        checkHistory: _generateCheckHistory(
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2025, 10, 25),
          frequency: '매주',
          weekdays: const ['월'],
          completionRate: 1.0, // 완주 (100%)
        ),
        completionRate: 1.0,
        isCompleted: true,
        createdAt: DateTime(2025, 9, 1),
        finishedAt: DateTime(2025, 10, 25),
      ),
    ];

    // 이전 루틴 저장
    await _savePreviousRoutines(previousRoutines);

    // ==================== 현재 루틴 (진행 중인 루틴) ====================
    final currentRoutines = [
      // 1. [운동] 매주 화 수 금 오전 7시 러닝
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.exercise,
        frequency: '매주',
        name: '매주 화 수 금 오전 7시 러닝',
        timePreference: '시간 설정',
        specificTime: DateTime(now.year, now.month, now.day, 7, 0),
        weekdays: const ['화', '수', '금'],
        period: '계속',
        endDate: null,
        checkHistory: _generateRecentCheckHistory(
          daysBack: 30,
          frequency: '매주',
          weekdays: const ['화', '수', '금'],
          completionRate: 0.85,
        ),
        completionRate: 0.85,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      // 2. [건강] 매일 영양제 먹기
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.health,
        frequency: '매일',
        name: '매일 영양제 먹기',
        timePreference: '아무때나',
        weekdays: const [],
        period: '계속',
        endDate: null,
        checkHistory: _generateRecentCheckHistory(
          daysBack: 30,
          frequency: '매일',
          completionRate: 0.95,
        ),
        completionRate: 0.95,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      // 3. [학습] 매일 앱 개발 30분
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.study,
        frequency: '매일',
        name: '매일 앱 개발 30분',
        timePreference: '아무때나',
        weekdays: const [],
        period: '계속',
        endDate: null,
        checkHistory: _generateRecentCheckHistory(
          daysBack: 30,
          frequency: '매일',
          completionRate: 0.80,
        ),
        completionRate: 0.80,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      // 4. [건강] 매일 자기 전 스트레칭, 명상
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.health,
        frequency: '매일',
        name: '매일 자기 전 스트레칭, 명상',
        timePreference: '자기 전',
        weekdays: const [],
        period: '계속',
        endDate: null,
        checkHistory: _generateRecentCheckHistory(
          daysBack: 30,
          frequency: '매일',
          completionRate: 0.90,
        ),
        completionRate: 0.90,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      // 5. [기타] 주 1회 사람 만나 대화하기
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.etc,
        frequency: '주1회',
        name: '주 1회 사람 만나 대화하기',
        timePreference: '아무때나',
        weekdays: const [],
        period: '계속',
        endDate: null,
        checkHistory: _generateRecentCheckHistory(
          daysBack: 30,
          frequency: '주1회',
          completionRate: 1.0,
        ),
        completionRate: 1.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      // 6. [운동] 월 1회 러닝 마일리지 150KM 이상
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.exercise,
        frequency: '월1회',
        name: '월 1회 러닝 마일리지 150KM 이상',
        timePreference: '아무때나',
        weekdays: const [],
        period: '계속',
        endDate: null,
        checkHistory: const [], // 월 1회는 최근 체크 없음 (예정)
        completionRate: 0.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      // 7. [문화] 월 1회 영화 시청
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.culture,
        frequency: '월1회',
        name: '월 1회 영화 시청',
        timePreference: '아무때나',
        weekdays: const [],
        period: '계속',
        endDate: null,
        checkHistory: _generateRecentCheckHistory(
          daysBack: 30,
          frequency: '월1회',
          completionRate: 1.0,
        ),
        completionRate: 1.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      // 8. [문화] 월 1회 독서 한 권 완독하기
      RoutineModel(
        id: uuid.v4(),
        category: RoutineCategory.culture,
        frequency: '월1회',
        name: '월 1회 독서 한 권 완독하기',
        timePreference: '아무때나',
        weekdays: const [],
        period: '계속',
        endDate: null,
        checkHistory: const [], // 월 1회는 최근 체크 없음 (예정)
        completionRate: 0.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];

    // 현재 루틴 저장
    state = currentRoutines..sort(_compareRoutines);
    await _saveRoutines();
  }

  /// 체크 히스토리 생성 (특정 기간)
  List<String> _generateCheckHistory({
    required DateTime startDate,
    required DateTime endDate,
    required String frequency,
    List<String> weekdays = const [],
    required double completionRate,
  }) {
    final checkDates = <String>[];
    final totalDays = endDate.difference(startDate).inDays + 1;

    if (frequency == '매일') {
      // 매일: completionRate에 따라 랜덤하게 날짜 선택
      for (var i = 0; i < totalDays; i++) {
        final date = startDate.add(Duration(days: i));
        if (_shouldCheck(completionRate)) {
          checkDates.add(date.toIso8601String().split('T')[0]);
        }
      }
    } else if (frequency.startsWith('주') && frequency.contains('회')) {
      // 주N회: completionRate에 따라 랜덤하게 날짜 선택
      final weeks = (totalDays / 7).ceil();
      final timesPerWeek =
          int.tryParse(frequency.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      final expectedChecks = weeks * timesPerWeek;
      final actualChecks = (expectedChecks * completionRate).round();

      for (var i = 0; i < actualChecks && i < totalDays; i++) {
        final randomDay = startDate.add(Duration(
          days: (i * 7 + (i % timesPerWeek) * 2),
        ));
        if (randomDay.isBefore(endDate) || randomDay.isAtSameMomentAs(endDate)) {
          checkDates.add(randomDay.toIso8601String().split('T')[0]);
        }
      }
    } else if (frequency == '매주' && weekdays.isNotEmpty) {
      // 매주 [요일]: 해당 요일만 체크
      final weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
      for (var i = 0; i < totalDays; i++) {
        final date = startDate.add(Duration(days: i));
        final weekdayName = weekdayNames[date.weekday - 1];
        if (weekdays.contains(weekdayName) && _shouldCheck(completionRate)) {
          checkDates.add(date.toIso8601String().split('T')[0]);
        }
      }
    } else if (frequency.startsWith('월') && frequency.contains('회')) {
      // 월N회: completionRate에 따라 랜덤하게 날짜 선택
      final months = (totalDays / 30).ceil();
      final timesPerMonth =
          int.tryParse(frequency.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      final expectedChecks = months * timesPerMonth;
      final actualChecks = (expectedChecks * completionRate).round();

      for (var i = 0; i < actualChecks && i < totalDays; i++) {
        final randomDay = startDate.add(Duration(
          days: (i * 15 + (i % timesPerMonth) * 5),
        ));
        if (randomDay.isBefore(endDate) || randomDay.isAtSameMomentAs(endDate)) {
          checkDates.add(randomDay.toIso8601String().split('T')[0]);
        }
      }
    }

    return checkDates;
  }

  /// 최근 체크 히스토리 생성 (현재 진행 중인 루틴용)
  List<String> _generateRecentCheckHistory({
    required int daysBack,
    required String frequency,
    List<String> weekdays = const [],
    required double completionRate,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysBack));

    return _generateCheckHistory(
      startDate: startDate,
      endDate: now,
      frequency: frequency,
      weekdays: weekdays,
      completionRate: completionRate,
    );
  }

  /// completionRate에 따라 체크 여부 결정 (확률적)
  bool _shouldCheck(double completionRate) {
    final random = DateTime.now().microsecondsSinceEpoch % 100;
    return random < (completionRate * 100);
  }

  /// 루틴 저장 (SharedPreferences)
  Future<void> _saveRoutines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        state.map((routine) => routine.toJson()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      // 저장 실패 처리
    }
  }

  /// 이전 루틴 저장 (완료된 루틴들)
  Future<void> _savePreviousRoutines(
      List<RoutineModel> previousRoutines) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        previousRoutines.map((routine) => routine.toJson()).toList(),
      );
      await prefs.setString(_previousRoutinesKey, jsonString);
    } catch (e) {
      // 저장 실패 처리
    }
  }

  /// 이전 루틴 로드
  Future<List<RoutineModel>> loadPreviousRoutines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_previousRoutinesKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((json) => RoutineModel.fromJson(json as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => (b.finishedAt ?? DateTime.now())
              .compareTo(a.finishedAt ?? DateTime.now())); // 최신순
      }
    } catch (e) {
      // 로드 실패
    }
    return [];
  }

  /// 루틴 추가
  Future<void> addRoutine(RoutineModel routine) async {
    state = [...state, routine]..sort(_compareRoutines);
    await _saveRoutines();
  }

  /// 루틴 업데이트
  Future<void> updateRoutine(String id, RoutineModel updatedRoutine) async {
    state = state.map((routine) {
      if (routine.id == id) {
        return updatedRoutine;
      }
      return routine;
    }).toList()
      ..sort(_compareRoutines);
    await _saveRoutines();
  }

  /// 루틴 삭제 (현재 루틴에서 제거 → 이전 루틴으로 이동)
  Future<void> deleteRoutine(String id) async {
    final routineToDelete = state.firstWhere((routine) => routine.id == id);

    // 현재 루틴에서 제거
    state = state.where((routine) => routine.id != id).toList();
    await _saveRoutines();

    // 이전 루틴에 추가
    final deletedRoutine = routineToDelete.copyWith(
      finishedAt: DateTime.now(),
    );
    final previousRoutines = await loadPreviousRoutines();
    await _savePreviousRoutines([deletedRoutine, ...previousRoutines]);
  }

  /// 루틴 체크 (오늘 완료 표시)
  Future<void> checkRoutine(String id) async {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0]; // YYYY-MM-DD

    state = state.map((routine) {
      if (routine.id == id && !routine.checkHistory.contains(today)) {
        final updatedHistory = [...routine.checkHistory, today];
        final completionRate = _calculateCompletionRate(
          routine.copyWith(checkHistory: updatedHistory),
        );

        return routine.copyWith(
          checkHistory: updatedHistory,
          completionRate: completionRate,
        );
      }
      return routine;
    }).toList()
      ..sort(_compareRoutines);

    await _saveRoutines();
  }

  /// 루틴 체크 취소 (오늘 완료 취소)
  Future<void> uncheckRoutine(String id) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    state = state.map((routine) {
      if (routine.id == id && routine.checkHistory.contains(today)) {
        final updatedHistory =
            routine.checkHistory.where((date) => date != today).toList();
        final completionRate = _calculateCompletionRate(
          routine.copyWith(checkHistory: updatedHistory),
        );

        return routine.copyWith(
          checkHistory: updatedHistory,
          completionRate: completionRate,
        );
      }
      return routine;
    }).toList()
      ..sort(_compareRoutines);

    await _saveRoutines();
  }

  /// 루틴 완주 처리 (기간 종료 + 목표 달성률 100%)
  Future<void> completeRoutine(String id) async {
    final routineToComplete = state.firstWhere((routine) => routine.id == id);

    // 완주 상태로 업데이트
    final completedRoutine = routineToComplete.copyWith(
      isCompleted: true,
      completionRate: 1.0,
      finishedAt: DateTime.now(),
    );

    // 현재 루틴에서 제거
    state = state.where((routine) => routine.id != id).toList();
    await _saveRoutines();

    // 이전 루틴에 추가
    final previousRoutines = await loadPreviousRoutines();
    await _savePreviousRoutines([completedRoutine, ...previousRoutines]);
  }

  /// 완료율 계산
  double _calculateCompletionRate(RoutineModel routine) {
    if (routine.createdAt == null) return 0.0;

    final now = DateTime.now();
    final startDate = routine.createdAt!;
    final daysPassed = now.difference(startDate).inDays + 1;

    if (daysPassed <= 0) return 0.0;

    // 주기별 예상 체크 횟수 계산
    int expectedChecks = 0;

    if (routine.frequency == '매일') {
      expectedChecks = daysPassed;
    } else if (routine.frequency.startsWith('주') &&
        routine.frequency.contains('회')) {
      final weeksCount = (daysPassed / 7).floor();
      final timesPerWeek =
          int.tryParse(routine.frequency.replaceAll(RegExp(r'[^0-9]'), '')) ??
              1;
      expectedChecks = weeksCount * timesPerWeek;
    } else if (routine.frequency.startsWith('매주')) {
      final weekdaysCount = routine.weekdays.length;
      final weeksCount = (daysPassed / 7).floor();
      expectedChecks = weeksCount * weekdaysCount;
    } else if (routine.frequency.startsWith('월') &&
        routine.frequency.contains('회')) {
      final monthsCount = (daysPassed / 30).floor();
      final timesPerMonth =
          int.tryParse(routine.frequency.replaceAll(RegExp(r'[^0-9]'), '')) ??
              1;
      expectedChecks = monthsCount * timesPerMonth;
    }

    if (expectedChecks == 0) return 0.0;

    final actualChecks = routine.checkHistory.length;
    final rate = actualChecks / expectedChecks;

    return rate > 1.0 ? 1.0 : rate; // 최대 100%
  }

  /// 루틴 정렬 비교 함수
  /// 우선순위: 체크 여부 → 주기 → 시간
  int _compareRoutines(RoutineModel a, RoutineModel b) {
    // 1. 체크 여부 (체크 안 된 것이 우선)
    final aChecked = a.isCheckedToday();
    final bChecked = b.isCheckedToday();
    if (aChecked != bChecked) {
      return aChecked ? 1 : -1; // 체크 안 된 것이 위로
    }

    // 2. 주기 우선순위
    if (a.frequencyPriority != b.frequencyPriority) {
      return a.frequencyPriority.compareTo(b.frequencyPriority);
    }

    // 3. 시간 우선순위
    return a.timePriority.compareTo(b.timePriority);
  }

  /// 새 루틴 생성 헬퍼
  static RoutineModel createNewRoutine({
    required String category,
    required String frequency,
    required String name,
    String? timePreference,
    DateTime? specificTime,
    List<String>? weekdays,
    String? period,
    DateTime? endDate,
  }) {
    const uuid = Uuid();
    return RoutineModel(
      id: uuid.v4(),
      category: category,
      frequency: frequency,
      name: name,
      timePreference: timePreference,
      specificTime: specificTime,
      weekdays: weekdays ?? [],
      period: period,
      endDate: endDate,
      createdAt: DateTime.now(),
    );
  }

  /// 리프레시 (재로드)
  Future<void> refresh() async {
    await _loadRoutines();
  }
}

/// 오늘 체크리스트 Provider
/// 오늘 표시되어야 하는 루틴만 필터링 + 정렬
final todayRoutinesProvider = Provider<List<RoutineModel>>((ref) {
  final routines = ref.watch(routineProvider);
  return routines.where((routine) => routine.shouldShowToday()).toList();
});

/// 오늘 완료한 루틴 개수 Provider
final todayCompletedCountProvider = Provider<int>((ref) {
  final todayRoutines = ref.watch(todayRoutinesProvider);
  return todayRoutines.where((routine) => routine.isCheckedToday()).length;
});

/// 오늘 루틴 완료율 Provider (0.0 ~ 1.0)
final todayCompletionRateProvider = Provider<double>((ref) {
  final todayRoutines = ref.watch(todayRoutinesProvider);
  if (todayRoutines.isEmpty) return 0.0;

  final completedCount = ref.watch(todayCompletedCountProvider);
  return completedCount / todayRoutines.length;
});
