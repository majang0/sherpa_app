// 💭 공유 메모리 Provider
//
// 사용자와 셰르피 간의 추억을 관리하는 상태 관리 Provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shared_memory_model.dart';
import '../services/memory_management_service.dart';

/// 📊 메모리 상태 관리
class MemoryState {
  final List<SharedMemory> memories;
  final List<MemoryCollection> collections;
  final SharedMemory? selectedMemory;
  final MemorySearchFilter currentFilter;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> statistics;

  const MemoryState({
    this.memories = const [],
    this.collections = const [],
    this.selectedMemory,
    this.currentFilter = const MemorySearchFilter(),
    this.isLoading = false,
    this.error,
    this.statistics = const {},
  });

  MemoryState copyWith({
    List<SharedMemory>? memories,
    List<MemoryCollection>? collections,
    SharedMemory? selectedMemory,
    MemorySearchFilter? currentFilter,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
  }) {
    return MemoryState(
      memories: memories ?? this.memories,
      collections: collections ?? this.collections,
      selectedMemory: selectedMemory ?? this.selectedMemory,
      currentFilter: currentFilter ?? this.currentFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }

  /// 필터링된 추억들
  List<SharedMemory> get filteredMemories {
    if (currentFilter.isEmpty) return memories;

    return memories.where((memory) {
      // 비공개 추억 필터링
      if (memory.isPrivate && !currentFilter.includePrivate) return false;

      // 키워드 검색
      if (currentFilter.keyword != null && currentFilter.keyword!.isNotEmpty) {
        final keyword = currentFilter.keyword!.toLowerCase();
        final matchesTitle = memory.title.toLowerCase().contains(keyword);
        final matchesContent = memory.content.toLowerCase().contains(keyword);
        final matchesTags =
            memory.tags.any((tag) => tag.toLowerCase().contains(keyword));

        if (!matchesTitle && !matchesContent && !matchesTags) return false;
      }

      // 카테고리 필터
      if (currentFilter.categories != null &&
          currentFilter.categories!.isNotEmpty) {
        if (!currentFilter.categories!.contains(memory.category)) return false;
      }

      // 중요도 필터
      if (currentFilter.importanceLevels != null &&
          currentFilter.importanceLevels!.isNotEmpty) {
        if (!currentFilter.importanceLevels!.contains(memory.importance))
          return false;
      }

      // 날짜 범위 필터
      if (currentFilter.startDate != null) {
        if (memory.createdAt.isBefore(currentFilter.startDate!)) return false;
      }
      if (currentFilter.endDate != null) {
        if (memory.createdAt.isAfter(currentFilter.endDate!)) return false;
      }

      // 태그 필터
      if (currentFilter.tags != null && currentFilter.tags!.isNotEmpty) {
        final hasMatchingTag =
            currentFilter.tags!.any((tag) => memory.tags.contains(tag));
        if (!hasMatchingTag) return false;
      }

      return true;
    }).toList();
  }

  /// 카테고리별 추억 개수
  Map<MemoryCategory, int> get memoriesByCategory {
    final counts = <MemoryCategory, int>{};
    for (final memory in memories) {
      counts[memory.category] = (counts[memory.category] ?? 0) + 1;
    }
    return counts;
  }

  /// 중요도별 추억 개수
  Map<MemoryImportance, int> get memoriesByImportance {
    final counts = <MemoryImportance, int>{};
    for (final memory in memories) {
      counts[memory.importance] = (counts[memory.importance] ?? 0) + 1;
    }
    return counts;
  }

  /// 최근 추억들 (7일 이내)
  List<SharedMemory> get recentMemories {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return memories.where((m) => m.createdAt.isAfter(oneWeekAgo)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 중요한 추억들
  List<SharedMemory> get importantMemories {
    return memories.where((m) => m.importance.level >= 4).toList()
      ..sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
  }
}

/// 💭 메모리 상태 관리자
class MemoryNotifier extends StateNotifier<MemoryState> {
  MemoryNotifier() : super(const MemoryState()) {
    loadMemories();
  }

  /// 📱 추억 로드
  Future<void> loadMemories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final memories = await MemoryManagementService.loadAllMemories();
      final collections = await MemoryManagementService.loadCollections();
      final statistics = await MemoryManagementService.getMemoryStatistics();

      state = state.copyWith(
        memories: memories,
        collections: collections,
        statistics: statistics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '추억을 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 💭 새 추억 생성
  Future<void> createMemory(SharedMemory memory) async {
    try {
      await MemoryManagementService.saveMemory(memory);

      // 상태 업데이트
      final updatedMemories = [memory, ...state.memories];
      state = state.copyWith(memories: updatedMemories);

      // 통계 업데이트
      await _updateStatistics();
    } catch (e) {
      state = state.copyWith(
        error: '추억 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 📖 추억 참조 (읽기)
  Future<SharedMemory?> referenceMemory(String memoryId) async {
    try {
      final referencedMemory =
          await MemoryManagementService.referenceMemory(memoryId);

      if (referencedMemory != null) {
        // 메모리 리스트에서 업데이트
        final updatedMemories = state.memories
            .map((m) => m.id == memoryId ? referencedMemory : m)
            .toList();

        state = state.copyWith(
          memories: updatedMemories,
          selectedMemory: referencedMemory,
        );
      }

      return referencedMemory;
    } catch (e) {
      state = state.copyWith(
        error: '추억 참조 중 오류가 발생했습니다: $e',
      );
      return null;
    }
  }

  /// 🔍 추억 검색
  Future<void> searchMemories(MemorySearchFilter filter) async {
    state = state.copyWith(
      currentFilter: filter,
      isLoading: true,
      error: null,
    );

    try {
      final searchResults =
          await MemoryManagementService.searchMemories(filter);
      state = state.copyWith(
        memories: searchResults,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '추억 검색 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 🏆 최근 추억 가져오기
  Future<void> loadRecentMemories({int count = 10}) async {
    try {
      final recentMemories = await MemoryManagementService.getRecentMemories(
        count: count,
      );

      state = state.copyWith(memories: recentMemories);
    } catch (e) {
      state = state.copyWith(
        error: '최근 추억 로드 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 💎 중요한 추억 가져오기
  Future<void> loadImportantMemories({int minImportanceLevel = 3}) async {
    try {
      final importantMemories =
          await MemoryManagementService.getImportantMemories(
        minImportanceLevel: minImportanceLevel,
      );

      state = state.copyWith(memories: importantMemories);
    } catch (e) {
      state = state.copyWith(
        error: '중요한 추억 로드 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 🎭 카테고리별 추억 가져오기
  Future<void> loadMemoriesByCategory(MemoryCategory category) async {
    try {
      final categoryMemories =
          await MemoryManagementService.getMemoriesByCategory(
        category,
      );

      state = state.copyWith(memories: categoryMemories);
    } catch (e) {
      state = state.copyWith(
        error: '카테고리별 추억 로드 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 🌟 관련 추억 가져오기
  Future<List<SharedMemory>> getRelatedMemories(
    SharedMemory baseMemory, {
    int maxCount = 5,
  }) async {
    try {
      return await MemoryManagementService.getRelatedMemories(
        baseMemory: baseMemory,
        maxCount: maxCount,
      );
    } catch (e) {
      state = state.copyWith(
        error: '관련 추억 로드 중 오류가 발생했습니다: $e',
      );
      return [];
    }
  }

  /// 🎯 트리거 기반 추억 가져오기
  Future<List<SharedMemory>> getMemoriesByTrigger({
    required String triggerType,
    required Map<String, dynamic> triggerData,
  }) async {
    try {
      return await MemoryManagementService.getMemoriesByTrigger(
        triggerType: triggerType,
        triggerData: triggerData,
      );
    } catch (e) {
      state = state.copyWith(
        error: '트리거 기반 추억 로드 중 오류가 발생했습니다: $e',
      );
      return [];
    }
  }

  /// 📚 컬렉션 생성
  Future<void> createCollection(MemoryCollection collection) async {
    try {
      await MemoryManagementService.saveCollection(collection);

      final updatedCollections = [...state.collections, collection];
      state = state.copyWith(collections: updatedCollections);
    } catch (e) {
      state = state.copyWith(
        error: '컬렉션 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 📚 컬렉션에 추억 추가
  Future<void> addMemoryToCollection(
    String collectionId,
    String memoryId,
  ) async {
    try {
      final collection = state.collections.firstWhere(
        (c) => c.id == collectionId,
      );

      final updatedCollection = collection.addMemory(memoryId);
      await MemoryManagementService.saveCollection(updatedCollection);

      final updatedCollections = state.collections
          .map((c) => c.id == collectionId ? updatedCollection : c)
          .toList();

      state = state.copyWith(collections: updatedCollections);
    } catch (e) {
      state = state.copyWith(
        error: '컬렉션에 추억 추가 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 📚 컬렉션에서 추억 제거
  Future<void> removeMemoryFromCollection(
    String collectionId,
    String memoryId,
  ) async {
    try {
      final collection = state.collections.firstWhere(
        (c) => c.id == collectionId,
      );

      final updatedCollection = collection.removeMemory(memoryId);
      await MemoryManagementService.saveCollection(updatedCollection);

      final updatedCollections = state.collections
          .map((c) => c.id == collectionId ? updatedCollection : c)
          .toList();

      state = state.copyWith(collections: updatedCollections);
    } catch (e) {
      state = state.copyWith(
        error: '컬렉션에서 추억 제거 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 🗑️ 추억 삭제
  Future<void> deleteMemory(String memoryId) async {
    try {
      await MemoryManagementService.deleteMemory(memoryId);

      final updatedMemories =
          state.memories.where((m) => m.id != memoryId).toList();

      state = state.copyWith(memories: updatedMemories);
      await _updateStatistics();
    } catch (e) {
      state = state.copyWith(
        error: '추억 삭제 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 🎯 추억 선택
  void selectMemory(SharedMemory? memory) {
    state = state.copyWith(selectedMemory: memory);
  }

  /// 🔍 필터 업데이트
  void updateFilter(MemorySearchFilter filter) {
    state = state.copyWith(currentFilter: filter);
  }

  /// 🔄 필터 초기화
  void clearFilter() {
    state = state.copyWith(
      currentFilter: const MemorySearchFilter(),
    );
    loadMemories(); // 전체 추억 다시 로드
  }

  /// ⚠️ 에러 지우기
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 📊 통계 업데이트
  Future<void> _updateStatistics() async {
    try {
      final statistics = await MemoryManagementService.getMemoryStatistics();
      state = state.copyWith(statistics: statistics);
    } catch (e) {
      // 통계 업데이트 실패는 치명적이지 않으므로 조용히 처리
      print('통계 업데이트 오류: $e');
    }
  }

  /// 🔄 모든 데이터 초기화
  Future<void> clearAllMemories() async {
    try {
      await MemoryManagementService.clearAllMemories();
      state = const MemoryState();
    } catch (e) {
      state = state.copyWith(
        error: '데이터 초기화 중 오류가 발생했습니다: $e',
      );
    }
  }
}

/// 💭 메모리 Provider
final memoryProvider =
    StateNotifierProvider<MemoryNotifier, MemoryState>((ref) {
  return MemoryNotifier();
});

/// 🎯 선택된 추억 Provider
final selectedMemoryProvider = Provider<SharedMemory?>((ref) {
  return ref.watch(memoryProvider).selectedMemory;
});

/// 🔍 필터링된 추억 목록 Provider
final filteredMemoriesProvider = Provider<List<SharedMemory>>((ref) {
  return ref.watch(memoryProvider).filteredMemories;
});

/// 🏆 최근 추억 Provider
final recentMemoriesProvider = Provider<List<SharedMemory>>((ref) {
  return ref.watch(memoryProvider).recentMemories;
});

/// 💎 중요한 추억 Provider
final importantMemoriesProvider = Provider<List<SharedMemory>>((ref) {
  return ref.watch(memoryProvider).importantMemories;
});

/// 📊 추억 통계 Provider
final memoryStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(memoryProvider).statistics;
});

/// 🎭 카테고리별 추억 개수 Provider
final memoriesByCategoryProvider = Provider<Map<MemoryCategory, int>>((ref) {
  return ref.watch(memoryProvider).memoriesByCategory;
});

/// 🌟 중요도별 추억 개수 Provider
final memoriesByImportanceProvider =
    Provider<Map<MemoryImportance, int>>((ref) {
  return ref.watch(memoryProvider).memoriesByImportance;
});

/// 📚 컬렉션 목록 Provider
final memoryCollectionsProvider = Provider<List<MemoryCollection>>((ref) {
  return ref.watch(memoryProvider).collections;
});

/// 🔍 현재 검색 필터 Provider
final currentMemoryFilterProvider = Provider<MemorySearchFilter>((ref) {
  return ref.watch(memoryProvider).currentFilter;
});

/// ⚠️ 메모리 에러 Provider
final memoryErrorProvider = Provider<String?>((ref) {
  return ref.watch(memoryProvider).error;
});

/// 🔄 메모리 로딩 상태 Provider
final memoryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(memoryProvider).isLoading;
});
