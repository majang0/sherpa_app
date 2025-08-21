// 💭 공유 메모리 관리 서비스
// 
// 사용자와 셰르피 간의 추억을 관리하고 검색하는 서비스

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shared_memory_model.dart';

/// 📚 메모리 관리 서비스
class MemoryManagementService {
  static const String _prefsKeyMemories = 'sherpi_shared_memories';
  static const String _prefsKeyCollections = 'sherpi_memory_collections';
  static const String _prefsKeyTriggers = 'sherpi_memory_triggers';
  static const int _maxMemories = 1000;
  static const int _recentMemoriesCount = 10;
  
  /// 📖 모든 추억 로드
  static Future<List<SharedMemory>> loadAllMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getString(_prefsKeyMemories);
      
      if (memoriesJson == null) return [];
      
      final memoriesList = json.decode(memoriesJson) as List;
      return memoriesList
          .map((data) => SharedMemory.fromJson(data))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('추억 로드 오류: $e');
      return [];
    }
  }
  
  /// 💾 추억 저장
  static Future<void> saveMemory(SharedMemory memory) async {
    try {
      final memories = await loadAllMemories();
      
      // 중복 체크
      final existingIndex = memories.indexWhere((m) => m.id == memory.id);
      if (existingIndex != -1) {
        memories[existingIndex] = memory;
      } else {
        memories.insert(0, memory);
      }
      
      // 메모리 크기 관리
      if (memories.length > _maxMemories) {
        // 중요도가 낮고 오래된 추억부터 삭제
        memories.sort((a, b) {
          final scoreA = a.relevanceScore * (a.isPrivate ? 2.0 : 1.0);
          final scoreB = b.relevanceScore * (b.isPrivate ? 2.0 : 1.0);
          return scoreB.compareTo(scoreA);
        });
        memories.removeRange(_maxMemories, memories.length);
      }
      
      // 저장
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = memories.map((m) => m.toJson()).toList();
      await prefs.setString(_prefsKeyMemories, json.encode(memoriesJson));
      
      // 트리거 업데이트
      await _updateMemoryTriggers(memory);
    } catch (e) {
      print('추억 저장 오류: $e');
    }
  }
  
  /// 🔍 추억 검색
  static Future<List<SharedMemory>> searchMemories(
    MemorySearchFilter filter,
  ) async {
    final allMemories = await loadAllMemories();
    
    return allMemories.where((memory) {
      // 비공개 추억 필터링
      if (memory.isPrivate && !filter.includePrivate) return false;
      
      // 키워드 검색
      if (filter.keyword != null && filter.keyword!.isNotEmpty) {
        final keyword = filter.keyword!.toLowerCase();
        final matchesTitle = memory.title.toLowerCase().contains(keyword);
        final matchesContent = memory.content.toLowerCase().contains(keyword);
        final matchesTags = memory.tags.any((tag) => 
            tag.toLowerCase().contains(keyword));
        
        if (!matchesTitle && !matchesContent && !matchesTags) return false;
      }
      
      // 카테고리 필터
      if (filter.categories != null && filter.categories!.isNotEmpty) {
        if (!filter.categories!.contains(memory.category)) return false;
      }
      
      // 중요도 필터
      if (filter.importanceLevels != null && filter.importanceLevels!.isNotEmpty) {
        if (!filter.importanceLevels!.contains(memory.importance)) return false;
      }
      
      // 날짜 범위 필터
      if (filter.startDate != null) {
        if (memory.createdAt.isBefore(filter.startDate!)) return false;
      }
      if (filter.endDate != null) {
        if (memory.createdAt.isAfter(filter.endDate!)) return false;
      }
      
      // 태그 필터
      if (filter.tags != null && filter.tags!.isNotEmpty) {
        final hasMatchingTag = filter.tags!.any((tag) => 
            memory.tags.contains(tag));
        if (!hasMatchingTag) return false;
      }
      
      return true;
    }).toList()
      ..sort((a, b) {
        // 정렬 적용
        switch (filter.sortBy) {
          case SortBy.relevance:
            return filter.ascending 
                ? a.relevanceScore.compareTo(b.relevanceScore)
                : b.relevanceScore.compareTo(a.relevanceScore);
          case SortBy.createdAt:
            return filter.ascending
                ? a.createdAt.compareTo(b.createdAt)
                : b.createdAt.compareTo(a.createdAt);
          case SortBy.importance:
            return filter.ascending
                ? a.importance.level.compareTo(b.importance.level)
                : b.importance.level.compareTo(a.importance.level);
          case SortBy.referenceCount:
            return filter.ascending
                ? a.referenceCount.compareTo(b.referenceCount)
                : b.referenceCount.compareTo(a.referenceCount);
          case SortBy.freshness:
            return filter.ascending
                ? a.freshness.compareTo(b.freshness)
                : b.freshness.compareTo(a.freshness);
        }
      });
  }
  
  /// 🎯 추억 참조 (읽기)
  static Future<SharedMemory?> referenceMemory(String memoryId) async {
    final memories = await loadAllMemories();
    final memoryIndex = memories.indexWhere((m) => m.id == memoryId);
    
    if (memoryIndex == -1) return null;
    
    final updatedMemory = memories[memoryIndex].referenced();
    memories[memoryIndex] = updatedMemory;
    
    // 저장
    final prefs = await SharedPreferences.getInstance();
    final memoriesJson = memories.map((m) => m.toJson()).toList();
    await prefs.setString(_prefsKeyMemories, json.encode(memoriesJson));
    
    return updatedMemory;
  }
  
  /// 🏆 최근 추억 가져오기
  static Future<List<SharedMemory>> getRecentMemories({
    int count = _recentMemoriesCount,
  }) async {
    final memories = await loadAllMemories();
    return memories.take(count).toList();
  }
  
  /// 💎 중요한 추억 가져오기
  static Future<List<SharedMemory>> getImportantMemories({
    int minImportanceLevel = 3,
  }) async {
    final memories = await loadAllMemories();
    return memories
        .where((m) => m.importance.level >= minImportanceLevel)
        .toList();
  }
  
  /// 🎭 카테고리별 추억 가져오기
  static Future<List<SharedMemory>> getMemoriesByCategory(
    MemoryCategory category,
  ) async {
    final memories = await loadAllMemories();
    return memories.where((m) => m.category == category).toList();
  }
  
  /// 🌟 관련 추억 추천
  static Future<List<SharedMemory>> getRelatedMemories({
    required SharedMemory baseMemory,
    int maxCount = 5,
  }) async {
    final allMemories = await loadAllMemories();
    
    // 자기 자신 제외
    final otherMemories = allMemories
        .where((m) => m.id != baseMemory.id)
        .toList();
    
    // 관련성 점수 계산
    final scoredMemories = otherMemories.map((memory) {
      double score = 0.0;
      
      // 같은 카테고리
      if (memory.category == baseMemory.category) score += 0.3;
      
      // 비슷한 시기 (7일 이내)
      final daysDiff = memory.createdAt
          .difference(baseMemory.createdAt)
          .inDays
          .abs();
      if (daysDiff <= 7) score += 0.2 * (1 - daysDiff / 7);
      
      // 공통 태그
      final commonTags = memory.tags
          .where((tag) => baseMemory.tags.contains(tag))
          .length;
      if (commonTags > 0) score += 0.3 * (commonTags / memory.tags.length);
      
      // 비슷한 중요도
      final importanceDiff = (memory.importance.level - 
          baseMemory.importance.level).abs();
      if (importanceDiff <= 1) score += 0.2 * (1 - importanceDiff / 4);
      
      return MapEntry(memory, score);
    })
    .where((entry) => entry.value > 0.2) // 최소 관련성 점수
    .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return scoredMemories
        .take(maxCount)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// 📚 메모리 컬렉션 관리
  static Future<List<MemoryCollection>> loadCollections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final collectionsJson = prefs.getString(_prefsKeyCollections);
      
      if (collectionsJson == null) return [];
      
      final collectionsList = json.decode(collectionsJson) as List;
      return collectionsList
          .map((data) => MemoryCollection.fromJson(data))
          .toList();
    } catch (e) {
      print('컬렉션 로드 오류: $e');
      return [];
    }
  }
  
  /// 💾 컬렉션 저장
  static Future<void> saveCollection(MemoryCollection collection) async {
    try {
      final collections = await loadCollections();
      
      final existingIndex = collections.indexWhere((c) => c.id == collection.id);
      if (existingIndex != -1) {
        collections[existingIndex] = collection;
      } else {
        collections.add(collection);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final collectionsJson = collections.map((c) => c.toJson()).toList();
      await prefs.setString(_prefsKeyCollections, json.encode(collectionsJson));
    } catch (e) {
      print('컬렉션 저장 오류: $e');
    }
  }
  
  /// 🧠 메모리 트리거 업데이트
  static Future<void> _updateMemoryTriggers(SharedMemory memory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final triggersJson = prefs.getString(_prefsKeyTriggers);
      
      final triggers = triggersJson != null 
          ? (json.decode(triggersJson) as List)
              .map((data) => MemoryTrigger.fromJson(data))
              .toList()
          : <MemoryTrigger>[];
      
      // 키워드 트리거 생성
      for (final tag in memory.tags) {
        final existingTrigger = triggers.firstWhere(
          (t) => t.triggerType == 'keyword' && 
                 t.triggerData['keyword'] == tag,
          orElse: () => MemoryTrigger(
            id: 'trigger_keyword_$tag',
            triggerType: 'keyword',
            triggerData: {'keyword': tag},
            associatedMemoryIds: [],
            triggerStrength: 0.5,
          ),
        );
        
        if (!existingTrigger.associatedMemoryIds.contains(memory.id)) {
          final updatedTrigger = MemoryTrigger(
            id: existingTrigger.id,
            triggerType: existingTrigger.triggerType,
            triggerData: existingTrigger.triggerData,
            associatedMemoryIds: [...existingTrigger.associatedMemoryIds, memory.id],
            triggerStrength: (existingTrigger.associatedMemoryIds.length + 1) / 10,
          );
          
          final index = triggers.indexWhere((t) => t.id == updatedTrigger.id);
          if (index != -1) {
            triggers[index] = updatedTrigger;
          } else {
            triggers.add(updatedTrigger);
          }
        }
      }
      
      // 감정 트리거 생성
      final emotionType = memory.emotionalContext['emotion'] as String?;
      if (emotionType != null) {
        final emotionTrigger = triggers.firstWhere(
          (t) => t.triggerType == 'emotion' && 
                 t.triggerData['emotion'] == emotionType,
          orElse: () => MemoryTrigger(
            id: 'trigger_emotion_$emotionType',
            triggerType: 'emotion',
            triggerData: {'emotion': emotionType},
            associatedMemoryIds: [],
            triggerStrength: 0.7,
          ),
        );
        
        if (!emotionTrigger.associatedMemoryIds.contains(memory.id)) {
          final updatedTrigger = MemoryTrigger(
            id: emotionTrigger.id,
            triggerType: emotionTrigger.triggerType,
            triggerData: emotionTrigger.triggerData,
            associatedMemoryIds: [...emotionTrigger.associatedMemoryIds, memory.id],
            triggerStrength: 0.7 + (emotionTrigger.associatedMemoryIds.length * 0.05),
          );
          
          final index = triggers.indexWhere((t) => t.id == updatedTrigger.id);
          if (index != -1) {
            triggers[index] = updatedTrigger;
          } else {
            triggers.add(updatedTrigger);
          }
        }
      }
      
      // 저장
      final triggersData = triggers.map((t) => t.toJson()).toList();
      await prefs.setString(_prefsKeyTriggers, json.encode(triggersData));
    } catch (e) {
      print('트리거 업데이트 오류: $e');
    }
  }
  
  /// 🎯 트리거 기반 추억 가져오기
  static Future<List<SharedMemory>> getMemoriesByTrigger({
    required String triggerType,
    required Map<String, dynamic> triggerData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final triggersJson = prefs.getString(_prefsKeyTriggers);
      
      if (triggersJson == null) return [];
      
      final triggers = (json.decode(triggersJson) as List)
          .map((data) => MemoryTrigger.fromJson(data))
          .toList();
      
      // 매칭되는 트리거 찾기
      final matchingTriggers = triggers.where((t) {
        if (t.triggerType != triggerType) return false;
        
        // 트리거 데이터 매칭
        for (final key in triggerData.keys) {
          if (t.triggerData[key] != triggerData[key]) return false;
        }
        
        return true;
      }).toList()
        ..sort((a, b) => b.triggerStrength.compareTo(a.triggerStrength));
      
      if (matchingTriggers.isEmpty) return [];
      
      // 연관된 추억들 가져오기
      final allMemories = await loadAllMemories();
      final memoryIds = matchingTriggers
          .expand((t) => t.associatedMemoryIds)
          .toSet()
          .toList();
      
      return allMemories
          .where((m) => memoryIds.contains(m.id))
          .toList()
        ..sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    } catch (e) {
      print('트리거 기반 추억 로드 오류: $e');
      return [];
    }
  }
  
  /// 🗑️ 추억 삭제
  static Future<void> deleteMemory(String memoryId) async {
    try {
      final memories = await loadAllMemories();
      memories.removeWhere((m) => m.id == memoryId);
      
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = memories.map((m) => m.toJson()).toList();
      await prefs.setString(_prefsKeyMemories, json.encode(memoriesJson));
      
      // 컬렉션에서도 제거
      final collections = await loadCollections();
      for (final collection in collections) {
        if (collection.memoryIds.contains(memoryId)) {
          final updatedCollection = collection.removeMemory(memoryId);
          await saveCollection(updatedCollection);
        }
      }
    } catch (e) {
      print('추억 삭제 오류: $e');
    }
  }
  
  /// 📊 메모리 통계
  static Future<Map<String, dynamic>> getMemoryStatistics() async {
    final memories = await loadAllMemories();
    
    if (memories.isEmpty) {
      return {
        'totalMemories': 0,
        'categoryCounts': {},
        'importanceCounts': {},
        'averageReferenceCount': 0.0,
        'oldestMemory': null,
        'newestMemory': null,
        'mostReferencedMemory': null,
      };
    }
    
    // 카테고리별 카운트
    final categoryCounts = <MemoryCategory, int>{};
    for (final memory in memories) {
      categoryCounts[memory.category] = (categoryCounts[memory.category] ?? 0) + 1;
    }
    
    // 중요도별 카운트
    final importanceCounts = <MemoryImportance, int>{};
    for (final memory in memories) {
      importanceCounts[memory.importance] = 
          (importanceCounts[memory.importance] ?? 0) + 1;
    }
    
    // 평균 참조 횟수
    final totalReferences = memories.fold<int>(
      0, (sum, memory) => sum + memory.referenceCount);
    final averageReferenceCount = totalReferences / memories.length;
    
    // 가장 많이 참조된 추억
    final mostReferencedMemory = memories
        .reduce((a, b) => a.referenceCount > b.referenceCount ? a : b);
    
    return {
      'totalMemories': memories.length,
      'categoryCounts': categoryCounts.map((k, v) => MapEntry(k.id, v)),
      'importanceCounts': importanceCounts.map((k, v) => MapEntry(k.id, v)),
      'averageReferenceCount': averageReferenceCount,
      'oldestMemory': memories.last.toJson(),
      'newestMemory': memories.first.toJson(),
      'mostReferencedMemory': mostReferencedMemory.toJson(),
    };
  }
  
  /// 🔄 모든 데이터 초기화
  static Future<void> clearAllMemories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyMemories);
    await prefs.remove(_prefsKeyCollections);
    await prefs.remove(_prefsKeyTriggers);
  }
}