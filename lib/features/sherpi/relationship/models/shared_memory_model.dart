// 💭 공유 메모리 및 추억 시스템 모델
// 
// 사용자와 셰르피가 함께 만들어가는 추억과 공유 경험을 저장하고 관리하는 모델

import 'package:flutter/foundation.dart';

/// 🎭 추억의 카테고리
enum MemoryCategory {
  achievement('achievement', '성취', '🏆', '함께 이룬 성과들'),
  celebration('celebration', '축하', '🎉', '기쁜 순간들'),
  challenge('challenge', '도전', '💪', '함께 극복한 어려움들'),
  learning('learning', '학습', '📚', '함께 배운 것들'),
  emotion('emotion', '감정', '💖', '특별한 감정의 순간들'),
  milestone('milestone', '이정표', '🚩', '중요한 순간들'),
  daily('daily', '일상', '☀️', '소중한 일상의 순간들'),
  special('special', '특별', '✨', '잊을 수 없는 순간들');

  const MemoryCategory(this.id, this.displayName, this.emoji, this.description);
  
  final String id;
  final String displayName;
  final String emoji;
  final String description;
}

/// 🌟 추억의 중요도
enum MemoryImportance {
  trivial('trivial', '사소한', 1, 0.2),
  normal('normal', '일반적인', 2, 0.5),
  meaningful('meaningful', '의미있는', 3, 0.7),
  important('important', '중요한', 4, 0.85),
  unforgettable('unforgettable', '잊을 수 없는', 5, 1.0);

  const MemoryImportance(this.id, this.displayName, this.level, this.weight);
  
  final String id;
  final String displayName;
  final int level;
  final double weight; // 검색/표시 시 가중치
}

/// 💭 공유 메모리
@immutable
class SharedMemory {
  final String id;
  final String title;
  final String content;
  final MemoryCategory category;
  final MemoryImportance importance;
  final DateTime createdAt;
  final DateTime? lastReferencedAt;
  final int referenceCount;
  final Map<String, dynamic> context;
  final List<String> tags;
  final String? imageUrl;
  final String? associatedActivityId;
  final Map<String, dynamic> emotionalContext;
  final bool isPrivate; // 사용자가 비공개로 설정한 추억
  
  const SharedMemory({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.importance,
    required this.createdAt,
    this.lastReferencedAt,
    this.referenceCount = 0,
    this.context = const {},
    this.tags = const [],
    this.imageUrl,
    this.associatedActivityId,
    this.emotionalContext = const {},
    this.isPrivate = false,
  });
  
  /// 추억의 나이 (일 단위)
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  
  /// 추억의 신선도 (최근일수록 높음)
  double get freshness {
    final daysSinceCreated = ageInDays;
    if (daysSinceCreated == 0) return 1.0;
    return (1.0 / (1.0 + daysSinceCreated * 0.01)).clamp(0.0, 1.0);
  }
  
  /// 추억의 관련성 점수 (참조 빈도와 중요도 기반)
  double get relevanceScore {
    final referenceFactor = (referenceCount / 10.0).clamp(0.0, 1.0);
    final importanceFactor = importance.weight;
    final freshnessFactor = freshness;
    
    return (referenceFactor * 0.3 + 
            importanceFactor * 0.5 + 
            freshnessFactor * 0.2).clamp(0.0, 1.0);
  }
  
  /// 추억 업데이트 (참조 시)
  SharedMemory referenced() {
    return copyWith(
      lastReferencedAt: DateTime.now(),
      referenceCount: referenceCount + 1,
    );
  }
  
  /// 복사본 생성
  SharedMemory copyWith({
    String? id,
    String? title,
    String? content,
    MemoryCategory? category,
    MemoryImportance? importance,
    DateTime? createdAt,
    DateTime? lastReferencedAt,
    int? referenceCount,
    Map<String, dynamic>? context,
    List<String>? tags,
    String? imageUrl,
    String? associatedActivityId,
    Map<String, dynamic>? emotionalContext,
    bool? isPrivate,
  }) {
    return SharedMemory(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      createdAt: createdAt ?? this.createdAt,
      lastReferencedAt: lastReferencedAt ?? this.lastReferencedAt,
      referenceCount: referenceCount ?? this.referenceCount,
      context: context ?? this.context,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      associatedActivityId: associatedActivityId ?? this.associatedActivityId,
      emotionalContext: emotionalContext ?? this.emotionalContext,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
  
  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.id,
      'importance': importance.id,
      'createdAt': createdAt.toIso8601String(),
      'lastReferencedAt': lastReferencedAt?.toIso8601String(),
      'referenceCount': referenceCount,
      'context': context,
      'tags': tags,
      'imageUrl': imageUrl,
      'associatedActivityId': associatedActivityId,
      'emotionalContext': emotionalContext,
      'isPrivate': isPrivate,
    };
  }
  
  /// JSON 역직렬화
  factory SharedMemory.fromJson(Map<String, dynamic> json) {
    return SharedMemory(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: MemoryCategory.values.firstWhere(
        (c) => c.id == json['category'],
      ),
      importance: MemoryImportance.values.firstWhere(
        (i) => i.id == json['importance'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      lastReferencedAt: json['lastReferencedAt'] != null 
          ? DateTime.parse(json['lastReferencedAt']) 
          : null,
      referenceCount: json['referenceCount'] ?? 0,
      context: json['context'] ?? {},
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      associatedActivityId: json['associatedActivityId'],
      emotionalContext: json['emotionalContext'] ?? {},
      isPrivate: json['isPrivate'] ?? false,
    );
  }
}

/// 📸 추억 스냅샷 (특정 순간의 기록)
@immutable
class MemorySnapshot {
  final String id;
  final DateTime timestamp;
  final String description;
  final Map<String, dynamic> contextData;
  final String? imageData; // Base64 인코딩된 이미지
  final String mood;
  final double satisfactionScore;
  
  const MemorySnapshot({
    required this.id,
    required this.timestamp,
    required this.description,
    required this.contextData,
    this.imageData,
    required this.mood,
    required this.satisfactionScore,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'contextData': contextData,
      'imageData': imageData,
      'mood': mood,
      'satisfactionScore': satisfactionScore,
    };
  }
  
  factory MemorySnapshot.fromJson(Map<String, dynamic> json) {
    return MemorySnapshot(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      contextData: json['contextData'] ?? {},
      imageData: json['imageData'],
      mood: json['mood'],
      satisfactionScore: json['satisfactionScore'].toDouble(),
    );
  }
}

/// 📚 추억 컬렉션
@immutable
class MemoryCollection {
  final String id;
  final String name;
  final String description;
  final List<String> memoryIds; // SharedMemory ID 리스트
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final String coverImageUrl;
  final Map<String, dynamic> metadata;
  
  const MemoryCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.memoryIds,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.coverImageUrl,
    this.metadata = const {},
  });
  
  /// 컬렉션에 추억 추가
  MemoryCollection addMemory(String memoryId) {
    if (memoryIds.contains(memoryId)) return this;
    
    return copyWith(
      memoryIds: [...memoryIds, memoryId],
      lastUpdatedAt: DateTime.now(),
    );
  }
  
  /// 컬렉션에서 추억 제거
  MemoryCollection removeMemory(String memoryId) {
    return copyWith(
      memoryIds: memoryIds.where((id) => id != memoryId).toList(),
      lastUpdatedAt: DateTime.now(),
    );
  }
  
  MemoryCollection copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? memoryIds,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    String? coverImageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return MemoryCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memoryIds: memoryIds ?? this.memoryIds,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memoryIds': memoryIds,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'coverImageUrl': coverImageUrl,
      'metadata': metadata,
    };
  }
  
  factory MemoryCollection.fromJson(Map<String, dynamic> json) {
    return MemoryCollection(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      memoryIds: List<String>.from(json['memoryIds']),
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
      coverImageUrl: json['coverImageUrl'],
      metadata: json['metadata'] ?? {},
    );
  }
}

/// 🎯 추억 검색 필터
@immutable
class MemorySearchFilter {
  final String? keyword;
  final List<MemoryCategory>? categories;
  final List<MemoryImportance>? importanceLevels;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? tags;
  final bool includePrivate;
  final SortBy sortBy;
  final bool ascending;
  
  const MemorySearchFilter({
    this.keyword,
    this.categories,
    this.importanceLevels,
    this.startDate,
    this.endDate,
    this.tags,
    this.includePrivate = false,
    this.sortBy = SortBy.relevance,
    this.ascending = false,
  });
  
  /// 빈 필터인지 확인
  bool get isEmpty =>
      keyword == null &&
      categories == null &&
      importanceLevels == null &&
      startDate == null &&
      endDate == null &&
      tags == null;
}

/// 📊 정렬 기준
enum SortBy {
  relevance('relevance', '관련성'),
  createdAt('createdAt', '생성일'),
  importance('importance', '중요도'),
  referenceCount('referenceCount', '참조 횟수'),
  freshness('freshness', '최신순');

  const SortBy(this.id, this.displayName);
  
  final String id;
  final String displayName;
}

/// 🧠 추억 연상 트리거
@immutable
class MemoryTrigger {
  final String id;
  final String triggerType; // 'keyword', 'emotion', 'context', 'time'
  final Map<String, dynamic> triggerData;
  final List<String> associatedMemoryIds;
  final double triggerStrength; // 0.0 ~ 1.0
  
  const MemoryTrigger({
    required this.id,
    required this.triggerType,
    required this.triggerData,
    required this.associatedMemoryIds,
    required this.triggerStrength,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'triggerType': triggerType,
      'triggerData': triggerData,
      'associatedMemoryIds': associatedMemoryIds,
      'triggerStrength': triggerStrength,
    };
  }
  
  factory MemoryTrigger.fromJson(Map<String, dynamic> json) {
    return MemoryTrigger(
      id: json['id'],
      triggerType: json['triggerType'],
      triggerData: json['triggerData'] ?? {},
      associatedMemoryIds: List<String>.from(json['associatedMemoryIds']),
      triggerStrength: json['triggerStrength'].toDouble(),
    );
  }
}

/// 💡 추억 템플릿 (자동 생성용)
class MemoryTemplate {
  static SharedMemory createAchievementMemory({
    required String title,
    required String achievement,
    required Map<String, dynamic> context,
    List<String>? tags,
  }) {
    return SharedMemory(
      id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: '오늘 ${achievement}을(를) 달성했어요! 정말 자랑스러워요. 🎉',
      category: MemoryCategory.achievement,
      importance: MemoryImportance.meaningful,
      createdAt: DateTime.now(),
      context: context,
      tags: tags ?? ['achievement', 'proud'],
      emotionalContext: {
        'emotion': 'pride',
        'intensity': 0.8,
      },
    );
  }
  
  static SharedMemory createCelebrationMemory({
    required String title,
    required String celebration,
    required Map<String, dynamic> context,
    List<String>? tags,
  }) {
    return SharedMemory(
      id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: celebration,
      category: MemoryCategory.celebration,
      importance: MemoryImportance.important,
      createdAt: DateTime.now(),
      context: context,
      tags: tags ?? ['celebration', 'happy'],
      emotionalContext: {
        'emotion': 'joy',
        'intensity': 0.9,
      },
    );
  }
  
  static SharedMemory createChallengeMemory({
    required String title,
    required String challenge,
    required String outcome,
    required Map<String, dynamic> context,
    List<String>? tags,
  }) {
    return SharedMemory(
      id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: '${challenge}라는 어려움을 만났지만, ${outcome}. 함께 극복해서 더욱 뿌듯해요!',
      category: MemoryCategory.challenge,
      importance: MemoryImportance.meaningful,
      createdAt: DateTime.now(),
      context: context,
      tags: tags ?? ['challenge', 'overcome', 'growth'],
      emotionalContext: {
        'emotion': 'resilience',
        'intensity': 0.7,
      },
    );
  }
  
  static SharedMemory createDailyMemory({
    required String title,
    required String moment,
    required Map<String, dynamic> context,
    List<String>? tags,
  }) {
    return SharedMemory(
      id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: moment,
      category: MemoryCategory.daily,
      importance: MemoryImportance.normal,
      createdAt: DateTime.now(),
      context: context,
      tags: tags ?? ['daily', 'routine'],
      emotionalContext: {
        'emotion': 'content',
        'intensity': 0.5,
      },
    );
  }
}