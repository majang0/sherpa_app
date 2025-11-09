import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:sherpa_app/features/goals/models/goal_model.dart';

/// 목표 Provider
///
/// 사용자가 설정한 목표를 관리합니다.
/// SharedPreferences를 통해 데이터를 저장/로드합니다.
final goalProvider =
    StateNotifierProvider<GoalNotifier, List<GoalModel>>((ref) {
  return GoalNotifier();
});

class GoalNotifier extends StateNotifier<List<GoalModel>> {
  static const String _storageKey = 'goals_list';
  static const String _previousGoalsKey = 'previous_goals_list';

  GoalNotifier() : super([]) {
    _loadGoals();
  }

  /// 목표 로드 (SharedPreferences)
  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final goals = jsonList
            .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // 현재 목표만 필터링 (완료되지 않은 것들)
        state = goals.where((goal) => goal.completedAt == null).toList()
          ..sort((a, b) => a.date.compareTo(b.date)); // 날짜순 정렬
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
    const uuid = Uuid();
    final now = DateTime.now();

    // ==================== 이전 목표 (완료된 목표) ====================
    final previousGoals = [
      // 1. [대회] 2025.09.05 전국 AI활용 아이디어 경진대회 대상 / 미달성
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.competition,
        date: DateTime(2025, 9, 5),
        name: '전국 AI활용 아이디어 경진대회 대상',
        targetValue: '대상',
        isAchieved: false,
        achievementRate: 0.8, // 최우수상 달성 (80%)
        achievementDetails: '최우수상',
        reasonForResult:
            '두루뭉실한 내용 전달, 내용에 대한 이해도 부족 (질문에 취약함)',
        createdAt: DateTime(2025, 8, 1),
        completedAt: DateTime(2025, 9, 5),
      ),
      // 2. [대회] 2025.10.02 교내 창의적 종합설계 경진대회 대상 / 달성
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.competition,
        date: DateTime(2025, 10, 2),
        name: '교내 창의적 종합설계 경진대회 대상',
        targetValue: '대상',
        isAchieved: true,
        achievementRate: 1.0,
        achievementDetails: '축하드려요',
        reasonForResult:
            '아이템이 해당 대회에 강함, 발표와 질문에 대한 대비 완료',
        createdAt: DateTime(2025, 9, 1),
        completedAt: DateTime(2025, 10, 2),
      ),
      // 3. [대회] 2025.10.15 미래융합형 소프트웨어 콘텐츠 경진대회 예선 통과 / 미달성
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.competition,
        date: DateTime(2025, 10, 15),
        name: '미래융합형 소프트웨어 콘텐츠 경진대회 예선 통과',
        targetValue: '예선 통과',
        isAchieved: false,
        achievementRate: 0.0,
        achievementDetails: '예선 탈락',
        reasonForResult: '서류를 GPT로 돌려서 너무 성의 없이 작성함',
        createdAt: DateTime(2025, 9, 15),
        completedAt: DateTime(2025, 10, 15),
      ),
      // 4. [대회] 2025.11.07 컨소시엄 창의적 종합설계 경진대회 대상 / 달성
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.competition,
        date: DateTime(2025, 11, 7),
        name: '컨소시엄 창의적 종합설계 경진대회 대상',
        targetValue: '대상',
        isAchieved: true,
        achievementRate: 1.0,
        achievementDetails: '축하드려요',
        reasonForResult:
            '컨설팅을 통해 과제보고서 작성에 신경을 많이 씀, AI 가점항목을 보고 AI 활용 방안에 대해 고민을 많이 함, 높은 시장성과 현실적인 접근방식에서 이점',
        createdAt: DateTime(2025, 10, 1),
        completedAt: DateTime(2025, 11, 7),
      ),
      // 5. [운동] 2025.11.08 해남땅끝마라톤 하프 1시간 40분 / 미달성
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.exercise,
        date: DateTime(2025, 11, 8),
        name: '해남땅끝마라톤 하프 1시간 40분',
        targetValue: '1시간 40분',
        isAchieved: false,
        achievementRate: 0.97, // 1시간 42분 43초 (약 97%)
        achievementDetails: '1시간 42분 43초',
        reasonForResult:
            '반환 코스 절반이 오르막길, 경진대회 준비로 인한 러닝 훈련 부족, 4시간 장거리 이동과 2일 연속 3시간 수면에 따른 피로감, 당일 아침 포만감에 8KM 지점까지 속이 계속 안좋았음',
        createdAt: DateTime(2025, 10, 8),
        completedAt: DateTime(2025, 11, 8),
      ),
    ];

    // 이전 목표 저장
    await _savePreviousGoals(previousGoals);

    // ==================== 현재 목표 (진행 중인 목표) ====================
    final currentGoals = [
      // 1. [대회] 2025.11.25 전국 창의적 종합설계 경진대회 대상
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.competition,
        date: DateTime(2025, 11, 25),
        name: '전국 창의적 종합설계 경진대회 대상',
        targetValue: '대상',
        createdAt: now,
      ),
      // 2. [대회] 2025.11.27 전국 FLOW 창업 경진대회 대상
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.competition,
        date: DateTime(2025, 11, 27),
        name: '전국 FLOW 창업 경진대회 대상',
        targetValue: '대상',
        createdAt: now,
      ),
      // 3. [운동] 2025.12.06 서울한강마라톤 하프 1시간 38분
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.exercise,
        date: DateTime(2025, 12, 6),
        name: '서울한강마라톤 하프 1시간 38분',
        targetValue: '1시간 38분',
        createdAt: now,
      ),
      // 4. [운동] 2026.01.04 두류마라톤 10km 42분
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.exercise,
        date: DateTime(2026, 1, 4),
        name: '두류마라톤 10km 42분',
        targetValue: '42분',
        createdAt: now,
      ),
      // 5. [운동] 2026.02.01 카가와 마루가메 마라톤 하프 1시간 35분
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.exercise,
        date: DateTime(2026, 2, 1),
        name: '카가와 마루가메 마라톤 하프 1시간 35분',
        targetValue: '1시간 35분',
        createdAt: now,
      ),
      // 6. [운동] 2026.02.22 대구마라톤 풀코스 3시간 30분
      GoalModel(
        id: uuid.v4(),
        category: GoalCategory.exercise,
        date: DateTime(2026, 2, 22),
        name: '대구마라톤 풀코스 3시간 30분',
        targetValue: '3시간 30분',
        createdAt: now,
      ),
    ];

    // 현재 목표 저장
    state = currentGoals..sort((a, b) => a.date.compareTo(b.date));
    await _saveGoals();
  }

  /// 목표 저장 (SharedPreferences)
  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        state.map((goal) => goal.toJson()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      // 저장 실패 처리 (에러 로깅 추가 가능)
    }
  }

  /// 이전 목표 저장 (완료된 목표들)
  Future<void> _savePreviousGoals(List<GoalModel> previousGoals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        previousGoals.map((goal) => goal.toJson()).toList(),
      );
      await prefs.setString(_previousGoalsKey, jsonString);
    } catch (e) {
      // 저장 실패 처리
    }
  }

  /// 이전 목표 로드
  Future<List<GoalModel>> loadPreviousGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_previousGoalsKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // 최신순 정렬
      }
    } catch (e) {
      // 로드 실패
    }
    return [];
  }

  /// 목표 추가
  Future<void> addGoal(GoalModel goal) async {
    state = [...state, goal]..sort((a, b) => a.date.compareTo(b.date));
    await _saveGoals();
  }

  /// 목표 업데이트
  Future<void> updateGoal(String id, GoalModel updatedGoal) async {
    state = state.map((goal) {
      if (goal.id == id) {
        return updatedGoal;
      }
      return goal;
    }).toList();
    await _saveGoals();
  }

  /// 목표 삭제
  Future<void> deleteGoal(String id) async {
    state = state.where((goal) => goal.id != id).toList();
    await _saveGoals();
  }

  /// 목표 완료 처리 (달성/미달성)
  Future<void> completeGoal({
    required String id,
    required bool isAchieved,
    required double achievementRate,
    String? achievementDetails,
    String? reasonForResult,
  }) async {
    final now = DateTime.now();

    // 현재 목표에서 찾기
    final goalToComplete = state.firstWhere((goal) => goal.id == id);

    // 완료 상태로 업데이트
    final completedGoal = goalToComplete.copyWith(
      isAchieved: isAchieved,
      achievementRate: achievementRate,
      achievementDetails: achievementDetails,
      reasonForResult: reasonForResult,
      completedAt: now,
    );

    // 현재 목표에서 제거
    state = state.where((goal) => goal.id != id).toList();
    await _saveGoals();

    // 이전 목표에 추가
    final previousGoals = await loadPreviousGoals();
    await _savePreviousGoals([completedGoal, ...previousGoals]);
  }

  /// 새 목표 생성 헬퍼
  static GoalModel createNewGoal({
    required String category,
    required DateTime date,
    required String name,
    required String targetValue,
  }) {
    const uuid = Uuid();
    return GoalModel(
      id: uuid.v4(),
      category: category,
      date: date,
      name: name,
      targetValue: targetValue,
      createdAt: DateTime.now(),
    );
  }

  /// 리프레시 (재로드)
  Future<void> refresh() async {
    await _loadGoals();
  }
}

/// 활성 목표 카테고리 Provider
/// AI 분석 화면에서 사용 (현재 활성화된 목표의 카테고리만 선택 가능)
final activeGoalCategoriesProvider = Provider<List<String>>((ref) {
  final goals = ref.watch(goalProvider);
  final categories = goals.map((goal) => goal.category).toSet().toList();
  return categories..sort();
});
