// 📈 성장 스토리 및 마일스톤 추적 서비스
// 
// 사용자의 성장 여정을 추적하고 의미있는 마일스톤을 관리하는 서비스

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/relationship_stage_model.dart';
import '../models/shared_memory_model.dart';
import '../services/memory_management_service.dart';

/// 📖 성장 스토리 항목
class GrowthStoryItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String category; // 'achievement', 'milestone', 'challenge', 'learning'
  final Map<String, dynamic> data;
  final String iconEmoji;
  final double significanceScore; // 0.0 ~ 1.0
  final List<String> tags;
  final String? associatedMemoryId;
  
  const GrowthStoryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    this.data = const {},
    required this.iconEmoji,
    required this.significanceScore,
    this.tags = const [],
    this.associatedMemoryId,
  });
  
  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'data': data,
      'iconEmoji': iconEmoji,
      'significanceScore': significanceScore,
      'tags': tags,
      'associatedMemoryId': associatedMemoryId,
    };
  }
  
  /// JSON 역직렬화
  factory GrowthStoryItem.fromJson(Map<String, dynamic> json) {
    return GrowthStoryItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      category: json['category'],
      data: json['data'] ?? {},
      iconEmoji: json['iconEmoji'],
      significanceScore: json['significanceScore'].toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      associatedMemoryId: json['associatedMemoryId'],
    );
  }
}

/// 📊 성장 통계
class GrowthStats {
  final int totalStoryItems;
  final int achievementCount;
  final int milestoneCount;
  final int challengeCount;
  final int learningCount;
  final double averageSignificance;
  final Duration totalGrowthPeriod;
  final List<String> topCategories;
  final Map<String, int> monthlyGrowth;
  final List<GrowthStoryItem> recentHighlights;
  
  const GrowthStats({
    required this.totalStoryItems,
    required this.achievementCount,
    required this.milestoneCount,
    required this.challengeCount,
    required this.learningCount,
    required this.averageSignificance,
    required this.totalGrowthPeriod,
    required this.topCategories,
    required this.monthlyGrowth,
    required this.recentHighlights,
  });
}

/// 🎯 마일스톤 추적기
class MilestoneTracker {
  final String id;
  final String name;
  final String description;
  final String category;
  final Map<String, dynamic> criteria; // 달성 조건
  final bool isAchieved;
  final DateTime? achievedAt;
  final double progress; // 0.0 ~ 1.0
  final String iconEmoji;
  final int rewardPoints;
  final String? specialMessage;
  
  const MilestoneTracker({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.criteria = const {},
    this.isAchieved = false,
    this.achievedAt,
    this.progress = 0.0,
    required this.iconEmoji,
    this.rewardPoints = 100,
    this.specialMessage,
  });
  
  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'criteria': criteria,
      'isAchieved': isAchieved,
      'achievedAt': achievedAt?.toIso8601String(),
      'progress': progress,
      'iconEmoji': iconEmoji,
      'rewardPoints': rewardPoints,
      'specialMessage': specialMessage,
    };
  }
  
  /// JSON 역직렬화
  factory MilestoneTracker.fromJson(Map<String, dynamic> json) {
    return MilestoneTracker(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      criteria: json['criteria'] ?? {},
      isAchieved: json['isAchieved'] ?? false,
      achievedAt: json['achievedAt'] != null 
          ? DateTime.parse(json['achievedAt'])
          : null,
      progress: json['progress']?.toDouble() ?? 0.0,
      iconEmoji: json['iconEmoji'],
      rewardPoints: json['rewardPoints'] ?? 100,
      specialMessage: json['specialMessage'],
    );
  }
  
  /// 달성 마킹
  MilestoneTracker markAsAchieved() {
    return MilestoneTracker(
      id: id,
      name: name,
      description: description,
      category: category,
      criteria: criteria,
      isAchieved: true,
      achievedAt: DateTime.now(),
      progress: 1.0,
      iconEmoji: iconEmoji,
      rewardPoints: rewardPoints,
      specialMessage: specialMessage,
    );
  }
  
  /// 진행률 업데이트
  MilestoneTracker updateProgress(double newProgress) {
    return MilestoneTracker(
      id: id,
      name: name,
      description: description,
      category: category,
      criteria: criteria,
      isAchieved: newProgress >= 1.0,
      achievedAt: newProgress >= 1.0 ? DateTime.now() : achievedAt,
      progress: newProgress.clamp(0.0, 1.0),
      iconEmoji: iconEmoji,
      rewardPoints: rewardPoints,
      specialMessage: specialMessage,
    );
  }
}

/// 📈 성장 스토리 서비스
class GrowthStoryService {
  static const String _prefsKeyStory = 'growth_story_items';
  static const String _prefsKeyMilestones = 'milestone_trackers';
  static const String _prefsKeyStats = 'growth_stats';
  static const int _maxStoryItems = 500;
  
  /// 📚 성장 스토리 로드
  static Future<List<GrowthStoryItem>> loadGrowthStory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storyJson = prefs.getString(_prefsKeyStory);
      
      if (storyJson == null) return [];
      
      final storyList = json.decode(storyJson) as List;
      return storyList
          .map((data) => GrowthStoryItem.fromJson(data))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('성장 스토리 로드 오류: $e');
      return [];
    }
  }
  
  /// ✍️ 성장 스토리 항목 추가
  static Future<void> addGrowthStoryItem(GrowthStoryItem item) async {
    try {
      final storyItems = await loadGrowthStory();
      
      // 중복 확인
      final existingIndex = storyItems.indexWhere((s) => s.id == item.id);
      if (existingIndex != -1) {
        storyItems[existingIndex] = item;
      } else {
        storyItems.insert(0, item);
      }
      
      // 크기 관리
      if (storyItems.length > _maxStoryItems) {
        // 중요도가 낮고 오래된 항목부터 삭제
        storyItems.sort((a, b) {
          final scoreA = a.significanceScore * 
              (1.0 - (DateTime.now().difference(a.timestamp).inDays / 365.0));
          final scoreB = b.significanceScore * 
              (1.0 - (DateTime.now().difference(b.timestamp).inDays / 365.0));
          return scoreB.compareTo(scoreA);
        });
        storyItems.removeRange(_maxStoryItems, storyItems.length);
      }
      
      // 저장
      final prefs = await SharedPreferences.getInstance();
      final storyJson = storyItems.map((s) => s.toJson()).toList();
      await prefs.setString(_prefsKeyStory, json.encode(storyJson));
      
      // 관련 추억 생성
      await _createMemoryFromStoryItem(item);
      
    } catch (e) {
      print('성장 스토리 항목 추가 오류: $e');
    }
  }
  
  /// 🎯 마일스톤 추적기 로드
  static Future<List<MilestoneTracker>> loadMilestoneTrackers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final milestonesJson = prefs.getString(_prefsKeyMilestones);
      
      if (milestonesJson == null) {
        // 기본 마일스톤들 생성
        return _createDefaultMilestones();
      }
      
      final milestonesList = json.decode(milestonesJson) as List;
      return milestonesList
          .map((data) => MilestoneTracker.fromJson(data))
          .toList();
    } catch (e) {
      print('마일스톤 로드 오류: $e');
      return [];
    }
  }
  
  /// 💾 마일스톤 추적기 저장
  static Future<void> saveMilestoneTrackers(List<MilestoneTracker> trackers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trackersJson = trackers.map((t) => t.toJson()).toList();
      await prefs.setString(_prefsKeyMilestones, json.encode(trackersJson));
    } catch (e) {
      print('마일스톤 저장 오류: $e');
    }
  }
  
  /// 🎯 마일스톤 진행률 업데이트
  static Future<void> updateMilestoneProgress({
    required String milestoneId,
    required Map<String, dynamic> progressData,
  }) async {
    try {
      final trackers = await loadMilestoneTrackers();
      final trackerIndex = trackers.indexWhere((t) => t.id == milestoneId);
      
      if (trackerIndex == -1) return;
      
      final tracker = trackers[trackerIndex];
      final newProgress = _calculateMilestoneProgress(tracker, progressData);
      
      final updatedTracker = tracker.updateProgress(newProgress);
      trackers[trackerIndex] = updatedTracker;
      
      await saveMilestoneTrackers(trackers);
      
      // 마일스톤 달성 시 스토리 항목 추가
      if (updatedTracker.isAchieved && !tracker.isAchieved) {
        await _onMilestoneAchieved(updatedTracker);
      }
      
    } catch (e) {
      print('마일스톤 진행률 업데이트 오류: $e');
    }
  }
  
  /// 📊 성장 통계 계산
  static Future<GrowthStats> calculateGrowthStats() async {
    try {
      final storyItems = await loadGrowthStory();
      
      if (storyItems.isEmpty) {
        return const GrowthStats(
          totalStoryItems: 0,
          achievementCount: 0,
          milestoneCount: 0,
          challengeCount: 0,
          learningCount: 0,
          averageSignificance: 0.0,
          totalGrowthPeriod: Duration.zero,
          topCategories: [],
          monthlyGrowth: {},
          recentHighlights: [],
        );
      }
      
      // 카테고리별 카운트
      final categoryCount = <String, int>{};
      double totalSignificance = 0.0;
      
      for (final item in storyItems) {
        categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
        totalSignificance += item.significanceScore;
      }
      
      // 월별 성장 데이터
      final monthlyGrowth = <String, int>{};
      for (final item in storyItems) {
        final monthKey = '${item.timestamp.year}-${item.timestamp.month.toString().padLeft(2, '0')}';
        monthlyGrowth[monthKey] = (monthlyGrowth[monthKey] ?? 0) + 1;
      }
      
      // 최근 하이라이트 (높은 중요도)
      final recentHighlights = storyItems
          .where((item) => item.significanceScore >= 0.7)
          .take(5)
          .toList();
      
      // 상위 카테고리
      final topCategories = categoryCount.entries
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final totalGrowthPeriod = storyItems.isNotEmpty
          ? DateTime.now().difference(storyItems.last.timestamp)
          : Duration.zero;
      
      return GrowthStats(
        totalStoryItems: storyItems.length,
        achievementCount: categoryCount['achievement'] ?? 0,
        milestoneCount: categoryCount['milestone'] ?? 0,
        challengeCount: categoryCount['challenge'] ?? 0,
        learningCount: categoryCount['learning'] ?? 0,
        averageSignificance: totalSignificance / storyItems.length,
        totalGrowthPeriod: totalGrowthPeriod,
        topCategories: topCategories.map((e) => e.key).take(3).toList(),
        monthlyGrowth: monthlyGrowth,
        recentHighlights: recentHighlights,
      );
    } catch (e) {
      print('성장 통계 계산 오류: $e');
      return const GrowthStats(
        totalStoryItems: 0,
        achievementCount: 0,
        milestoneCount: 0,
        challengeCount: 0,
        learningCount: 0,
        averageSignificance: 0.0,
        totalGrowthPeriod: Duration.zero,
        topCategories: [],
        monthlyGrowth: {},
        recentHighlights: [],
      );
    }
  }
  
  /// 🎯 활동별 성장 스토리 항목 생성
  static Future<void> createStoryFromActivity({
    required String activityType,
    required Map<String, dynamic> activityData,
    String? userName,
  }) async {
    try {
      final storyItem = _generateStoryItemFromActivity(
        activityType: activityType,
        activityData: activityData,
        userName: userName,
      );
      
      if (storyItem != null) {
        await addGrowthStoryItem(storyItem);
        
        // 마일스톤 진행률 업데이트
        await updateMilestoneProgress(
          milestoneId: 'milestone_${activityType}',
          progressData: activityData,
        );
      }
    } catch (e) {
      print('활동 기반 스토리 생성 오류: $e');
    }
  }
  
  /// 🏆 성취 기반 스토리 항목 생성
  static Future<void> createStoryFromAchievement({
    required String achievementType,
    required Map<String, dynamic> achievementData,
    String? userName,
  }) async {
    try {
      final storyItem = GrowthStoryItem(
        id: 'story_achievement_${DateTime.now().millisecondsSinceEpoch}',
        title: _getAchievementTitle(achievementType, achievementData),
        description: _getAchievementDescription(achievementType, achievementData, userName),
        timestamp: DateTime.now(),
        category: 'achievement',
        data: achievementData,
        iconEmoji: _getAchievementEmoji(achievementType),
        significanceScore: _calculateAchievementSignificance(achievementType, achievementData),
        tags: ['achievement', achievementType, ..._getAchievementTags(achievementType)],
      );
      
      await addGrowthStoryItem(storyItem);
    } catch (e) {
      print('성취 기반 스토리 생성 오류: $e');
    }
  }
  
  /// 📈 기본 마일스톤 생성
  static List<MilestoneTracker> _createDefaultMilestones() {
    return [
      // 첫 주 마일스톤
      MilestoneTracker(
        id: 'milestone_first_week',
        name: '첫 일주일',
        description: '셰르피와 함께한 첫 일주일을 완성하세요!',
        category: 'relationship',
        criteria: {'days': 7, 'interactions': 5},
        iconEmoji: '📅',
        rewardPoints: 100,
        specialMessage: '첫 일주일을 함께해주셔서 감사해요! 🎉',
      ),
      
      // 운동 마일스톤
      MilestoneTracker(
        id: 'milestone_exercise_champion',
        name: '운동 챔피언',
        description: '30일 동안 총 20시간 이상 운동하세요!',
        category: 'exercise',
        criteria: {'total_hours': 20, 'period_days': 30},
        iconEmoji: '💪',
        rewardPoints: 300,
        specialMessage: '운동 챔피언이 되셨네요! 정말 대단해요! 💪',
      ),
      
      // 독서 마일스톤
      MilestoneTracker(
        id: 'milestone_bookworm',
        name: '독서광',
        description: '한 달 동안 3권 이상의 책을 읽으세요!',
        category: 'reading',
        criteria: {'books_count': 3, 'period_days': 30},
        iconEmoji: '📚',
        rewardPoints: 250,
        specialMessage: '독서를 사랑하는 마음이 정말 아름다워요! 📚',
      ),
      
      // 일기 마일스톤
      MilestoneTracker(
        id: 'milestone_reflection_master',
        name: '성찰의 달인',
        description: '20일 연속으로 일기를 작성하세요!',
        category: 'diary',
        criteria: {'consecutive_days': 20},
        iconEmoji: '📖',
        rewardPoints: 200,
        specialMessage: '자기 성찰의 힘을 기르셨네요! ✨',
      ),
      
      // 관계 발전 마일스톤
      MilestoneTracker(
        id: 'milestone_best_friend',
        name: '최고의 친구',
        description: '셰르피와 평생 친구 단계에 도달하세요!',
        category: 'relationship',
        criteria: {'relationship_stage': 'lifelong_friend'},
        iconEmoji: '💎',
        rewardPoints: 500,
        specialMessage: '우리는 이제 평생 친구예요! 💖',
      ),
      
      // 학습 마일스톤
      MilestoneTracker(
        id: 'milestone_curious_mind',
        name: '호기심 많은 마음',
        description: '10가지 이상의 다른 주제에 대해 대화하세요!',
        category: 'learning',
        criteria: {'conversation_topics': 10},
        iconEmoji: '🧠',
        rewardPoints: 150,
        specialMessage: '호기심이 많은 당신이 정말 멋져요! 🌟',
      ),
    ];
  }
  
  /// 📊 마일스톤 진행률 계산
  static double _calculateMilestoneProgress(
    MilestoneTracker tracker,
    Map<String, dynamic> progressData,
  ) {
    switch (tracker.category) {
      case 'relationship':
        if (tracker.criteria.containsKey('days')) {
          final targetDays = tracker.criteria['days'] as int;
          final currentDays = progressData['relationship_days'] as int? ?? 0;
          return (currentDays / targetDays).clamp(0.0, 1.0);
        }
        if (tracker.criteria.containsKey('relationship_stage')) {
          final targetStage = tracker.criteria['relationship_stage'] as String;
          final currentStage = progressData['current_stage'] as String? ?? 'introduction';
          return targetStage == currentStage ? 1.0 : 0.0;
        }
        break;
        
      case 'exercise':
        if (tracker.criteria.containsKey('total_hours')) {
          final targetHours = tracker.criteria['total_hours'] as int;
          final currentHours = progressData['total_exercise_hours'] as double? ?? 0.0;
          return (currentHours / targetHours).clamp(0.0, 1.0);
        }
        break;
        
      case 'reading':
        if (tracker.criteria.containsKey('books_count')) {
          final targetBooks = tracker.criteria['books_count'] as int;
          final currentBooks = progressData['completed_books'] as int? ?? 0;
          return (currentBooks / targetBooks).clamp(0.0, 1.0);
        }
        break;
        
      case 'diary':
        if (tracker.criteria.containsKey('consecutive_days')) {
          final targetDays = tracker.criteria['consecutive_days'] as int;
          final currentDays = progressData['consecutive_diary_days'] as int? ?? 0;
          return (currentDays / targetDays).clamp(0.0, 1.0);
        }
        break;
        
      case 'learning':
        if (tracker.criteria.containsKey('conversation_topics')) {
          final targetTopics = tracker.criteria['conversation_topics'] as int;
          final currentTopics = progressData['unique_topics_count'] as int? ?? 0;
          return (currentTopics / targetTopics).clamp(0.0, 1.0);
        }
        break;
    }
    
    return tracker.progress;
  }
  
  /// 🎉 마일스톤 달성 시 처리
  static Future<void> _onMilestoneAchieved(MilestoneTracker milestone) async {
    // 성장 스토리에 마일스톤 달성 추가
    final storyItem = GrowthStoryItem(
      id: 'story_milestone_${milestone.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: '🏆 ${milestone.name} 달성!',
      description: milestone.specialMessage ?? '${milestone.name} 마일스톤을 달성했어요!',
      timestamp: DateTime.now(),
      category: 'milestone',
      data: milestone.toJson(),
      iconEmoji: milestone.iconEmoji,
      significanceScore: 0.8,
      tags: ['milestone', milestone.category, 'achievement'],
    );
    
    await addGrowthStoryItem(storyItem);
    
    // 추억 생성
    await _createMemoryFromMilestone(milestone);
  }
  
  /// 💭 스토리 항목에서 추억 생성
  static Future<void> _createMemoryFromStoryItem(GrowthStoryItem item) async {
    if (item.significanceScore < 0.6) return; // 중요하지 않은 항목은 추억으로 만들지 않음
    
    SharedMemory? memory;
    
    switch (item.category) {
      case 'achievement':
        memory = MemoryTemplate.createAchievementMemory(
          title: item.title,
          achievement: item.description,
          context: item.data,
          tags: item.tags,
        );
        break;
        
      case 'milestone':
        memory = MemoryTemplate.createCelebrationMemory(
          title: item.title,
          celebration: item.description,
          context: item.data,
          tags: item.tags,
        );
        break;
        
      case 'challenge':
        memory = MemoryTemplate.createChallengeMemory(
          title: item.title,
          challenge: '어려운 상황',
          outcome: item.description,
          context: item.data,
          tags: item.tags,
        );
        break;
        
      case 'learning':
        memory = SharedMemory(
          id: 'memory_learning_${DateTime.now().millisecondsSinceEpoch}',
          title: item.title,
          content: item.description,
          category: MemoryCategory.learning,
          importance: MemoryImportance.meaningful,
          createdAt: item.timestamp,
          context: item.data,
          tags: item.tags,
        );
        break;
    }
    
    if (memory != null) {
      await MemoryManagementService.saveMemory(memory);
    }
  }
  
  /// 🎯 마일스톤에서 추억 생성
  static Future<void> _createMemoryFromMilestone(MilestoneTracker milestone) async {
    final memory = SharedMemory(
      id: 'memory_milestone_${milestone.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: '🏆 ${milestone.name} 달성!',
      content: milestone.specialMessage ?? '${milestone.name} 마일스톤을 달성했어요! 정말 자랑스러워요. 🌟',
      category: MemoryCategory.milestone,
      importance: MemoryImportance.important,
      createdAt: DateTime.now(),
      context: milestone.toJson(),
      tags: ['milestone', milestone.category, 'celebration'],
      emotionalContext: {
        'emotion': 'pride',
        'intensity': 0.9,
      },
    );
    
    await MemoryManagementService.saveMemory(memory);
  }
  
  /// 🎯 활동에서 스토리 항목 생성
  static GrowthStoryItem? _generateStoryItemFromActivity({
    required String activityType,
    required Map<String, dynamic> activityData,
    String? userName,
  }) {
    // 중요한 활동들만 스토리로 만들기
    if (!_isSignificantActivity(activityType, activityData)) {
      return null;
    }
    
    final String title;
    final String description;
    final String iconEmoji;
    final double significance;
    final List<String> tags;
    
    switch (activityType) {
      case 'exercise':
        final duration = activityData['duration'] as int? ?? 0;
        final type = activityData['type'] as String? ?? '운동';
        title = '${type} 완료!';
        description = '${duration}분간 ${type}을(를) 완료했어요! 건강한 하루네요.';
        iconEmoji = '💪';
        significance = duration >= 60 ? 0.7 : 0.5;
        tags = ['exercise', 'health'];
        break;
        
      case 'reading':
        final pages = activityData['pages'] as int? ?? 0;
        title = '독서 완료!';
        description = '${pages}페이지를 읽었어요! 지식이 쌓여가네요.';
        iconEmoji = '📚';
        significance = pages >= 50 ? 0.6 : 0.4;
        tags = ['reading', 'learning'];
        break;
        
      default:
        return null;
    }
    
    return GrowthStoryItem(
      id: 'story_activity_${activityType}_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      timestamp: DateTime.now(),
      category: 'achievement',
      data: activityData,
      iconEmoji: iconEmoji,
      significanceScore: significance,
      tags: tags,
    );
  }
  
  /// 🎯 중요한 활동인지 판단
  static bool _isSignificantActivity(String activityType, Map<String, dynamic> data) {
    switch (activityType) {
      case 'exercise':
        return (data['duration'] as int? ?? 0) >= 30;
      case 'reading':
        return (data['pages'] as int? ?? 0) >= 10;
      case 'diary':
        return true; // 일기는 항상 의미있음
      default:
        return false;
    }
  }
  
  /// 🏆 성취 제목 생성
  static String _getAchievementTitle(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'level_up':
        return '레벨 ${data['level']} 달성!';
      case 'streak':
        return '${data['days']}일 연속 달성!';
      case 'perfect_score':
        return '완벽한 점수 달성!';
      default:
        return '새로운 성취!';
    }
  }
  
  /// 📝 성취 설명 생성
  static String _getAchievementDescription(String type, Map<String, dynamic> data, String? userName) {
    final name = userName ?? '당신';
    switch (type) {
      case 'level_up':
        return '${name}이 레벨 ${data['level']}에 도달했어요! 꾸준한 노력의 결과네요.';
      case 'streak':
        return '${name}이 ${data['days']}일 연속으로 목표를 달성했어요! 정말 대단해요.';
      case 'perfect_score':
        return '${name}이 완벽한 점수를 받았어요! 최고의 성과네요.';
      default:
        return '${name}이 새로운 성취를 이뤘어요!';
    }
  }
  
  /// 😊 성취 이모지 가져오기
  static String _getAchievementEmoji(String type) {
    switch (type) {
      case 'level_up':
        return '🆙';
      case 'streak':
        return '🔥';
      case 'perfect_score':
        return '💯';
      default:
        return '🏆';
    }
  }
  
  /// 📊 성취 중요도 계산
  static double _calculateAchievementSignificance(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'level_up':
        final level = data['level'] as int? ?? 1;
        return (0.5 + (level * 0.1)).clamp(0.0, 1.0);
      case 'streak':
        final days = data['days'] as int? ?? 1;
        return (0.3 + (days * 0.02)).clamp(0.0, 1.0);
      case 'perfect_score':
        return 0.8;
      default:
        return 0.5;
    }
  }
  
  /// 🏷️ 성취 태그 가져오기
  static List<String> _getAchievementTags(String type) {
    switch (type) {
      case 'level_up':
        return ['level', 'progress'];
      case 'streak':
        return ['streak', 'consistency'];
      case 'perfect_score':
        return ['perfect', 'excellence'];
      default:
        return ['achievement'];
    }
  }
  
  /// 🔄 모든 데이터 초기화
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyStory);
    await prefs.remove(_prefsKeyMilestones);
    await prefs.remove(_prefsKeyStats);
  }
}