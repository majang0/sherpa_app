// 📈 성장 스토리 및 마일스톤 Provider
//
// 사용자의 성장 여정과 마일스톤을 추적하는 상태 관리 Provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:sherpa_app/features/sherpi/intelligence/services/relationship/growth_story_service.dart';

/// 📊 성장 스토리 상태
class GrowthStoryState {
  final List<GrowthStoryItem> storyItems;
  final List<MilestoneTracker> milestoneTrackers;
  final GrowthStats? stats;
  final GrowthStoryItem? selectedStoryItem;
  final MilestoneTracker? selectedMilestone;
  final bool isLoading;
  final String? error;
  final String
      activeFilter; // 'all', 'achievements', 'milestones', 'challenges', 'learning'

  const GrowthStoryState({
    this.storyItems = const [],
    this.milestoneTrackers = const [],
    this.stats,
    this.selectedStoryItem,
    this.selectedMilestone,
    this.isLoading = false,
    this.error,
    this.activeFilter = 'all',
  });

  GrowthStoryState copyWith({
    List<GrowthStoryItem>? storyItems,
    List<MilestoneTracker>? milestoneTrackers,
    GrowthStats? stats,
    GrowthStoryItem? selectedStoryItem,
    MilestoneTracker? selectedMilestone,
    bool? isLoading,
    String? error,
    String? activeFilter,
  }) {
    return GrowthStoryState(
      storyItems: storyItems ?? this.storyItems,
      milestoneTrackers: milestoneTrackers ?? this.milestoneTrackers,
      stats: stats ?? this.stats,
      selectedStoryItem: selectedStoryItem ?? this.selectedStoryItem,
      selectedMilestone: selectedMilestone ?? this.selectedMilestone,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  /// 필터링된 스토리 항목들
  List<GrowthStoryItem> get filteredStoryItems {
    switch (activeFilter) {
      case 'achievements':
        return storyItems
            .where((item) => item.category == 'achievement')
            .toList();
      case 'milestones':
        return storyItems
            .where((item) => item.category == 'milestone')
            .toList();
      case 'challenges':
        return storyItems
            .where((item) => item.category == 'challenge')
            .toList();
      case 'learning':
        return storyItems.where((item) => item.category == 'learning').toList();
      default:
        return storyItems;
    }
  }

  /// 완료된 마일스톤들
  List<MilestoneTracker> get completedMilestones {
    return milestoneTrackers
        .where((m) => m.isAchieved && m.achievedAt != null)
        .toList()
      ..sort((a, b) => b.achievedAt!.compareTo(a.achievedAt!));
  }

  /// 진행 중인 마일스톤들
  List<MilestoneTracker> get activeMilestones {
    return milestoneTrackers
        .where((m) => !m.isAchieved && m.progress > 0.0)
        .toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));
  }

  /// 대기 중인 마일스톤들
  List<MilestoneTracker> get pendingMilestones {
    return milestoneTrackers
        .where((m) => !m.isAchieved && m.progress == 0.0)
        .toList();
  }

  /// 최근 하이라이트 (높은 중요도)
  List<GrowthStoryItem> get recentHighlights {
    return storyItems
        .where((item) => item.significanceScore >= 0.7)
        .take(5)
        .toList();
  }

  /// 카테고리별 스토리 개수
  Map<String, int> get storyCountByCategory {
    final counts = <String, int>{};
    for (final item in storyItems) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    return counts;
  }

  /// 이번 달 성장 항목 수
  int get thisMonthGrowthCount {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);

    return storyItems
        .where((item) => item.timestamp.isAfter(thisMonthStart))
        .length;
  }

  /// 전체 마일스톤 달성률
  double get overallMilestoneProgress {
    if (milestoneTrackers.isEmpty) return 0.0;

    final totalProgress = milestoneTrackers.fold<double>(
        0.0, (sum, tracker) => sum + tracker.progress);

    return totalProgress / milestoneTrackers.length;
  }
}

/// 📈 성장 스토리 관리자
class GrowthStoryNotifier extends StateNotifier<GrowthStoryState> {
  GrowthStoryNotifier() : super(const GrowthStoryState()) {
    loadGrowthData();
  }

  /// 📱 성장 데이터 로드
  Future<void> loadGrowthData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final storyItems = await GrowthStoryService.loadGrowthStory();
      final milestoneTrackers =
          await GrowthStoryService.loadMilestoneTrackers();
      final stats = await GrowthStoryService.calculateGrowthStats();

      state = state.copyWith(
        storyItems: storyItems,
        milestoneTrackers: milestoneTrackers,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '성장 데이터를 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// ✍️ 새 스토리 항목 추가
  Future<void> addStoryItem(GrowthStoryItem item) async {
    try {
      await GrowthStoryService.addGrowthStoryItem(item);

      // 상태 업데이트
      final updatedStoryItems = [item, ...state.storyItems];
      state = state.copyWith(storyItems: updatedStoryItems);

      // 통계 업데이트
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        error: '스토리 항목 추가 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 🎯 마일스톤 진행률 업데이트
  Future<void> updateMilestoneProgress({
    required String milestoneId,
    required Map<String, dynamic> progressData,
  }) async {
    try {
      await GrowthStoryService.updateMilestoneProgress(
        milestoneId: milestoneId,
        progressData: progressData,
      );

      // 마일스톤 상태 다시 로드
      final updatedTrackers = await GrowthStoryService.loadMilestoneTrackers();
      state = state.copyWith(milestoneTrackers: updatedTrackers);

      // 통계 업데이트
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        error: '마일스톤 업데이트 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 🏆 활동에서 스토리 생성
  Future<void> createStoryFromActivity({
    required String activityType,
    required Map<String, dynamic> activityData,
    String? userName,
  }) async {
    try {
      await GrowthStoryService.createStoryFromActivity(
        activityType: activityType,
        activityData: activityData,
        userName: userName,
      );

      // 데이터 다시 로드
      await loadGrowthData();
    } catch (e) {
      state = state.copyWith(
        error: '활동 기반 스토리 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 🎯 성취에서 스토리 생성
  Future<void> createStoryFromAchievement({
    required String achievementType,
    required Map<String, dynamic> achievementData,
    String? userName,
  }) async {
    try {
      await GrowthStoryService.createStoryFromAchievement(
        achievementType: achievementType,
        achievementData: achievementData,
        userName: userName,
      );

      // 데이터 다시 로드
      await loadGrowthData();
    } catch (e) {
      state = state.copyWith(
        error: '성취 기반 스토리 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 🔍 필터 변경
  void setActiveFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  /// 🎯 스토리 항목 선택
  void selectStoryItem(GrowthStoryItem? item) {
    state = state.copyWith(selectedStoryItem: item);
  }

  /// 🏆 마일스톤 선택
  void selectMilestone(MilestoneTracker? milestone) {
    state = state.copyWith(selectedMilestone: milestone);
  }

  /// ⚠️ 에러 지우기
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 📊 통계 업데이트
  Future<void> _updateStats() async {
    try {
      final stats = await GrowthStoryService.calculateGrowthStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      // 통계 업데이트 실패는 치명적이지 않으므로 조용히 처리
    }
  }

  /// 🔄 모든 데이터 초기화
  Future<void> clearAllData() async {
    try {
      await GrowthStoryService.clearAllData();
      state = const GrowthStoryState();
    } catch (e) {
      state = state.copyWith(
        error: '데이터 초기화 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 📈 특정 기간의 성장 데이터 가져오기
  List<GrowthStoryItem> getStoryItemsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return state.storyItems
        .where((item) =>
            item.timestamp.isAfter(startDate) &&
            item.timestamp.isBefore(endDate))
        .toList();
  }

  /// 🎯 카테고리별 스토리 항목 가져오기
  List<GrowthStoryItem> getStoryItemsByCategory(String category) {
    return state.storyItems.where((item) => item.category == category).toList();
  }

  /// 🌟 높은 중요도 스토리 항목 가져오기
  List<GrowthStoryItem> getHighSignificanceStoryItems({double minScore = 0.7}) {
    return state.storyItems
        .where((item) => item.significanceScore >= minScore)
        .toList();
  }

  /// 📊 월별 성장 데이터 가져오기
  Map<String, int> getMonthlyGrowthData({int months = 12}) {
    final now = DateTime.now();
    final result = <String, int>{};

    for (int i = 0; i < months; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      final count = state.storyItems
          .where((item) =>
              item.timestamp.year == date.year &&
              item.timestamp.month == date.month)
          .length;

      result[monthKey] = count;
    }

    return result;
  }

  /// 🎯 마일스톤 완료 시 호출
  Future<void> onMilestoneCompleted(MilestoneTracker milestone) async {
    // 마일스톤 완료 스토리 항목 생성
    final storyItem = GrowthStoryItem(
      id: 'story_milestone_completed_${milestone.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: '🏆 ${milestone.name} 완료!',
      description: milestone.specialMessage ?? '${milestone.name} 마일스톤을 완료했어요!',
      timestamp: DateTime.now(),
      category: 'milestone',
      data: milestone.toJson(),
      iconEmoji: milestone.iconEmoji,
      significanceScore: 0.9,
      tags: ['milestone', 'completed', milestone.category],
    );

    await addStoryItem(storyItem);
  }

  /// 📈 성장 추세 분석
  Map<String, dynamic> analyzeGrowthTrend({int days = 30}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final recentItems = state.storyItems
        .where((item) => item.timestamp.isAfter(startDate))
        .toList();

    if (recentItems.isEmpty) {
      return {
        'trend': 'no_data',
        'message': '데이터가 충분하지 않습니다.',
        'items_count': 0,
        'average_significance': 0.0,
      };
    }

    final averageSignificance = recentItems.fold<double>(
            0.0, (sum, item) => sum + item.significanceScore) /
        recentItems.length;

    final trend = averageSignificance >= 0.7
        ? 'excellent'
        : averageSignificance >= 0.5
            ? 'good'
            : averageSignificance >= 0.3
                ? 'moderate'
                : 'needs_improvement';

    final message = _getTrendMessage(trend, recentItems.length);

    return {
      'trend': trend,
      'message': message,
      'items_count': recentItems.length,
      'average_significance': averageSignificance,
      'category_breakdown': _getCategoryBreakdown(recentItems),
    };
  }

  /// 📝 추세 메시지 생성
  String _getTrendMessage(String trend, int itemsCount) {
    switch (trend) {
      case 'excellent':
        return '최근 $itemsCount개의 성장 항목이 기록되었고, 모두 높은 의미를 가지고 있어요! 정말 잘하고 있어요! 🌟';
      case 'good':
        return '최근 $itemsCount개의 성장 항목이 기록되었어요. 꾸준히 성장하고 있는 모습이 보기 좋아요! 👏';
      case 'moderate':
        return '최근 $itemsCount개의 성장 항목이 있어요. 조금 더 의미있는 활동을 늘려보면 어떨까요? 💪';
      case 'needs_improvement':
        return '최근 성장 기록이 있지만 더 의미있는 활동이 필요해 보여요. 함께 더 나은 방향을 찾아봐요! 🤗';
      default:
        return '성장 데이터를 분석할 수 없어요.';
    }
  }

  /// 📊 카테고리별 분석
  Map<String, int> _getCategoryBreakdown(List<GrowthStoryItem> items) {
    final breakdown = <String, int>{};
    for (final item in items) {
      breakdown[item.category] = (breakdown[item.category] ?? 0) + 1;
    }
    return breakdown;
  }
}

/// 📈 성장 스토리 Provider
final growthStoryProvider =
    StateNotifierProvider<GrowthStoryNotifier, GrowthStoryState>((ref) {
  return GrowthStoryNotifier();
});

/// 🎯 선택된 스토리 항목 Provider
final selectedStoryItemProvider = Provider<GrowthStoryItem?>((ref) {
  return ref.watch(growthStoryProvider).selectedStoryItem;
});

/// 🏆 선택된 마일스톤 Provider
final selectedMilestoneProvider = Provider<MilestoneTracker?>((ref) {
  return ref.watch(growthStoryProvider).selectedMilestone;
});

/// 🔍 필터링된 스토리 항목 Provider
final filteredStoryItemsProvider = Provider<List<GrowthStoryItem>>((ref) {
  return ref.watch(growthStoryProvider).filteredStoryItems;
});

/// 🏆 완료된 마일스톤 Provider
final completedMilestonesProvider = Provider<List<MilestoneTracker>>((ref) {
  return ref.watch(growthStoryProvider).completedMilestones;
});

/// 🎯 진행 중인 마일스톤 Provider
final activeMilestonesProvider = Provider<List<MilestoneTracker>>((ref) {
  return ref.watch(growthStoryProvider).activeMilestones;
});

/// 📊 성장 통계 Provider
final growthStatsProvider = Provider<GrowthStats?>((ref) {
  return ref.watch(growthStoryProvider).stats;
});

/// 🌟 최근 하이라이트 Provider
final recentHighlightsProvider = Provider<List<GrowthStoryItem>>((ref) {
  return ref.watch(growthStoryProvider).recentHighlights;
});

/// 📈 이번 달 성장 개수 Provider
final thisMonthGrowthCountProvider = Provider<int>((ref) {
  return ref.watch(growthStoryProvider).thisMonthGrowthCount;
});

/// 🎯 전체 마일스톤 진행률 Provider
final overallMilestoneProgressProvider = Provider<double>((ref) {
  return ref.watch(growthStoryProvider).overallMilestoneProgress;
});

/// 📊 카테고리별 스토리 개수 Provider
final storyCountByCategoryProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(growthStoryProvider).storyCountByCategory;
});

/// ⚠️ 성장 스토리 에러 Provider
final growthStoryErrorProvider = Provider<String?>((ref) {
  return ref.watch(growthStoryProvider).error;
});

/// 🔄 성장 스토리 로딩 상태 Provider
final growthStoryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(growthStoryProvider).isLoading;
});
