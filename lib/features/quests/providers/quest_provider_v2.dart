import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

import '../models/quest_template_model.dart';
import '../models/quest_instance_model.dart';
import '../services/quest_generator_service.dart';
import '../services/quest_tracking_service.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/providers/global_point_provider.dart';
import '../../../shared/providers/global_sherpi_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/models/point_system_model.dart';
import '../../../core/constants/sherpi_dialogues.dart';

/// 새로운 퀘스트 시스템 Provider (V2)
/// quest.md 기반의 완전히 새로운 퀘스트 시스템
final questProviderV2 = StateNotifierProvider<QuestNotifierV2, AsyncValue<List<QuestInstance>>>((ref) {
  return QuestNotifierV2(ref);
});

class QuestNotifierV2 extends StateNotifier<AsyncValue<List<QuestInstance>>> {
  final Ref ref;
  List<QuestInstance> _allQuests = [];
  bool _isPremiumActive = false;
  
  // 추적용 데이터 캐시
  Map<String, dynamic> _lastTrackingData = {};
  
  // 보너스 수령 캐시
  Set<String> _claimedBonuses = {};

  QuestNotifierV2(this.ref) : super(const AsyncValue.loading()) {
    _loadQuests();
    _loadClaimedBonuses();
    
    // 글로벌 유저 데이터 변경 감지
    ref.listen(globalUserProvider, (previous, next) {
      _onGlobalUserDataChanged(next);
    });
  }

  /// 퀘스트 데이터 로드
  Future<void> _loadQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 임시: 퀘스트 클리어 기록 초기화 (개발용)
      await _clearDevelopmentData(prefs);
      
      // 프리미엄 상태 로드
      _isPremiumActive = prefs.getBool('premium_quest_active_v2') ?? false;
      
      // 퀘스트 생성 날짜 확인
      final lastDailyGenerated = prefs.getString('last_daily_generated_v2');
      final lastWeeklyGenerated = prefs.getString('last_weekly_generated_v2');
      final lastPremiumGenerated = prefs.getString('last_premium_generated_v2');
      
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      final thisWeekString = '${today.year}-${_getWeekOfYear(today)}';
      
      // 저장된 퀘스트 로드
      final savedQuests = prefs.getStringList('saved_quests_v2') ?? [];
      if (savedQuests.isNotEmpty) {
        _allQuests = savedQuests.map((questJson) => 
          QuestInstance.fromJson(jsonDecode(questJson))
        ).toList();
      } else {
        _allQuests = [];
      }
      
      // 새로운 퀘스트 생성 필요 여부 확인
      bool needsUpdate = false;
      
      // 일일 퀘스트 생성 (매일)
      if (lastDailyGenerated != todayString) {
        _generateDailyQuests();
        await prefs.setString('last_daily_generated_v2', todayString);
        needsUpdate = true;
      }
      
      // 주간 퀘스트 생성 (매주)
      if (lastWeeklyGenerated != thisWeekString) {
        _generateWeeklyQuests();
        await prefs.setString('last_weekly_generated_v2', thisWeekString);
        needsUpdate = true;
      }
      
      // 고급 퀘스트 생성 (매주, 프리미엄 유저만)
      if (_isPremiumActive && lastPremiumGenerated != thisWeekString) {
        _generatePremiumQuests();
        await prefs.setString('last_premium_generated_v2', thisWeekString);
        needsUpdate = true;
      }
      
      // 퀘스트가 하나도 없으면 강제로 생성
      if (_allQuests.isEmpty) {
        _generateAllQuests();
        needsUpdate = true;
      }
      
      // 글로벌 데이터와 동기화
      await _syncWithGlobalData();
      
      if (needsUpdate) {
        await _saveQuests();
      }
      
      state = AsyncValue.data(_allQuests);
      
      // 셰르피 환영 메시지
      _showWelcomeSherpi();
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 개발용 데이터 초기화
  Future<void> _clearDevelopmentData(SharedPreferences prefs) async {
    await prefs.remove('saved_quests_v2');
    await prefs.remove('daily_bonus_v2_${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}');
    await prefs.remove('weekly_bonus_v2_${DateTime.now().year}-${_getWeekOfYear(DateTime.now())}');
  }

  /// 모든 퀘스트 생성
  void _generateAllQuests() {
    _allQuests.clear();
    _generateDailyQuests();
    _generateWeeklyQuests();
    if (_isPremiumActive) {
      _generatePremiumQuests();
    }
  }

  /// 일일 퀘스트 생성
  void _generateDailyQuests() {
    // 기존 일일 퀘스트 제거
    _allQuests.removeWhere((quest) => quest.type == QuestTypeV2.daily);
    
    // 새로운 일일 퀘스트 생성 (5개)
    final dailyQuests = QuestGeneratorService.generateDailyQuests();
    _allQuests.addAll(dailyQuests);
    
  }

  /// 주간 퀘스트 생성
  void _generateWeeklyQuests() {
    // 기존 주간 퀘스트 제거
    _allQuests.removeWhere((quest) => quest.type == QuestTypeV2.weekly);
    
    // 새로운 주간 퀘스트 생성 (5개)
    final weeklyQuests = QuestGeneratorService.generateWeeklyQuests();
    _allQuests.addAll(weeklyQuests);
    
  }

  /// 고급 퀘스트 생성
  void _generatePremiumQuests() {
    if (!_isPremiumActive) return;
    
    // 기존 고급 퀘스트 제거
    _allQuests.removeWhere((quest) => quest.type == QuestTypeV2.premium);
    
    // 새로운 고급 퀘스트 생성 (3개)
    final premiumQuests = QuestGeneratorService.generatePremiumQuests();
    _allQuests.addAll(premiumQuests);
    
  }

  /// 글로벌 데이터와 동기화
  Future<void> _syncWithGlobalData() async {
    final globalUser = ref.read(globalUserProvider);
    final pointData = ref.read(globalPointProvider);
    
    // 일일 및 주간 포인트 획득량 계산
    final dailyPointsEarned = _calculateDailyPointsEarned(pointData.transactions);
    final weeklyPointsEarned = _calculateWeeklyPointsEarned(pointData.transactions);
    
    final trackingData = QuestTrackingService.convertGlobalUserToTrackingData(
      globalUser,
      dailyPointsEarned: dailyPointsEarned,
      weeklyPointsEarned: weeklyPointsEarned,
    );
    
    // 주간 데이터 추가
    final weeklyData = await QuestTrackingService.calculateWeeklyData(globalUser);
    trackingData.addAll(weeklyData);
    
    // 탭 방문 정보 추가
    final lastVisitedTab = await QuestTrackingService.getLastVisitedTab();
    if (lastVisitedTab != null) {
      trackingData['visitedTab'] = lastVisitedTab;
    }
    
    _lastTrackingData = trackingData;
    
    // 모든 퀘스트의 진행률 업데이트
    bool anyUpdated = false;
    for (int i = 0; i < _allQuests.length; i++) {
      final quest = _allQuests[i];
      final updatedQuest = QuestTrackingService.updateQuestProgress(quest, trackingData);
      
      if (updatedQuest != null) {
        _allQuests[i] = updatedQuest;
        anyUpdated = true;
      }
    }
    
    if (anyUpdated) {
      await _saveQuests();
      state = AsyncValue.data(_allQuests);
    }
  }

  /// 글로벌 유저 데이터 변경 시 호출
  void _onGlobalUserDataChanged(GlobalUser globalUser) {
    final pointData = ref.read(globalPointProvider);
    
    // 일일 및 주간 포인트 획득량 계산
    final dailyPointsEarned = _calculateDailyPointsEarned(pointData.transactions);
    final weeklyPointsEarned = _calculateWeeklyPointsEarned(pointData.transactions);
    
    final trackingData = QuestTrackingService.convertGlobalUserToTrackingData(
      globalUser,
      dailyPointsEarned: dailyPointsEarned,
      weeklyPointsEarned: weeklyPointsEarned,
    );
    
    // 변경된 데이터만 체크
    bool hasChanges = false;
    for (final key in trackingData.keys) {
      if (_lastTrackingData[key] != trackingData[key]) {
        hasChanges = true;
        break;
      }
    }
    
    if (hasChanges) {
      _lastTrackingData = trackingData;
      _syncWithGlobalData();
    }
  }

  /// 탭 방문 기록 및 퀘스트 업데이트
  Future<void> recordTabVisit(String tabName) async {
    await QuestTrackingService.recordTabVisit(tabName);
    
    // 탭 방문 퀘스트가 있는지 확인하고 업데이트
    final trackingData = Map<String, dynamic>.from(_lastTrackingData);
    trackingData['visitedTab'] = tabName;
    
    bool anyUpdated = false;
    for (int i = 0; i < _allQuests.length; i++) {
      final quest = _allQuests[i];
      if (quest.trackingCondition.type == QuestTrackingType.tabVisit) {
        final updatedQuest = QuestTrackingService.updateQuestProgress(quest, trackingData);
        
        if (updatedQuest != null) {
          _allQuests[i] = updatedQuest;
          anyUpdated = true;
        }
      }
    }
    
    if (anyUpdated) {
      await _saveQuests();
      state = AsyncValue.data(_allQuests);
    }
  }

  /// 보상 수령
  Future<void> claimReward(String questInstanceId) async {
    final questIndex = _allQuests.indexWhere((q) => q.instanceId == questInstanceId);
    if (questIndex == -1) return;
    
    final quest = _allQuests[questIndex];
    if (!quest.canClaim) return;
    
    // 글로벌 시스템을 통한 보상 지급
    final userNotifier = ref.read(globalUserProvider.notifier);
    final pointNotifier = ref.read(globalPointProvider.notifier);
    
    // 경험치 지급
    userNotifier.addExperience(quest.rewards.experience);
    
    // 포인트 지급 (있는 경우)
    if (quest.rewards.points > 0) {
      pointNotifier.addPoints(
        quest.rewards.points.toInt(), 
        '${quest.type.displayName} 퀘스트 완료: ${quest.title}',
      );
    }
    
    // 능력치 증가 (확률적)
    bool statGranted = false;
    if (quest.rewards.statChance > 0) {
      final random = math.Random();
      if (random.nextDouble() < quest.rewards.statChance) {
        _updateGlobalStat(quest.rewards.statType, quest.rewards.statIncrease);
        statGranted = true;
      }
    }
    
    // 퀘스트 상태 업데이트
    _allQuests[questIndex] = quest.copyWith(
      status: QuestStatus.claimed,
      claimedAt: DateTime.now(),
      statGranted: statGranted,
    );
    
    // 전체 완료 보너스 확인
    await _checkCompletionBonus();
    
    await _saveQuests();
    state = AsyncValue.data(_allQuests);
    
    // 셰르피 보상 메시지
    ref.read(sherpiProvider.notifier).showMessage(
      context: SherpiContext.questComplete,
      emotion: SherpiEmotion.cheering,
      userContext: {
        'questTitle': quest.title,
        'experience': quest.rewards.experience.toInt(),
        'points': quest.rewards.points.toInt(),
        'statGranted': statGranted,
        'statType': statGranted ? quest.rewards.statType : null,
        'statIncrease': statGranted ? quest.rewards.statIncrease : null,
      },
    );
  }

  /// 글로벌 능력치 업데이트
  void _updateGlobalStat(String statType, double increase) {
    try {
      final userNotifier = ref.read(globalUserProvider.notifier);
      
      switch (statType) {
        case 'stamina':
          userNotifier.increaseStats(deltaStamina: increase);
          break;
        case 'knowledge':
          userNotifier.increaseStats(deltaKnowledge: increase);
          break;
        case 'technique':
          userNotifier.increaseStats(deltaTechnique: increase);
          break;
        case 'sociality':
          userNotifier.increaseStats(deltaSociality: increase);
          break;
        case 'willpower':
          userNotifier.increaseStats(deltaWillpower: increase);
          break;
      }
    } catch (e) {
    }
  }

  /// 전체 완료 보너스 확인
  Future<void> _checkCompletionBonus() async {
    final pointNotifier = ref.read(globalPointProvider.notifier);
    final userNotifier = ref.read(globalUserProvider.notifier);
    
    // 일일 퀘스트 전체 완료 보너스
    if (QuestGeneratorService.areAllDailyQuestsCompleted(_allQuests) && 
        !await _isBonusAlreadyClaimed('daily_bonus_v2_today')) {
      
      userNotifier.addExperience(QuestCompletionBonus.dailyBonus.experienceBonus);
      pointNotifier.addPoints(
        QuestCompletionBonus.dailyBonus.pointsBonus.toInt(), 
        QuestCompletionBonus.dailyBonus.description,
      );
      await _markBonusAsClaimed('daily_bonus_v2_today');
      
      // 셰르피 특별 메시지
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.achievement,
        emotion: SherpiEmotion.celebrating,
        userContext: {
          'achievement': '일일 퀘스트 전체 완료',
          'bonus': QuestCompletionBonus.dailyBonus.pointsBonus.toInt(),
          'xpBonus': QuestCompletionBonus.dailyBonus.experienceBonus.toInt(),
        },
      );
    }
    
    // 주간 퀘스트 전체 완료 보너스
    if (QuestGeneratorService.areAllWeeklyQuestsCompleted(_allQuests) && 
        !await _isBonusAlreadyClaimed('weekly_bonus_v2_this_week')) {
      
      userNotifier.addExperience(QuestCompletionBonus.weeklyBonus.experienceBonus);
      pointNotifier.addPoints(
        QuestCompletionBonus.weeklyBonus.pointsBonus.toInt(), 
        QuestCompletionBonus.weeklyBonus.description,
      );
      await _markBonusAsClaimed('weekly_bonus_v2_this_week');
      
      // 셰르피 특별 메시지
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.achievement,
        emotion: SherpiEmotion.celebrating,
        userContext: {
          'achievement': '주간 퀘스트 전체 완료',
          'bonus': QuestCompletionBonus.weeklyBonus.pointsBonus.toInt(),
          'xpBonus': QuestCompletionBonus.weeklyBonus.experienceBonus.toInt(),
        },
      );
    }
  }

  /// 셰르피 환영 메시지
  void _showWelcomeSherpi() {
    final hour = DateTime.now().hour;
    final completableCount = _allQuests.where((q) => q.canComplete).length;
    final claimableCount = _allQuests.where((q) => q.canClaim).length;
    
    SherpiContext context;
    if (claimableCount > 0) {
      context = SherpiContext.questComplete;
    } else if (completableCount > 0) {
      context = SherpiContext.encouragement;
    } else if (hour < 12) {
      context = SherpiContext.dailyGreeting;
    } else {
      context = SherpiContext.guidance;
    }
    
    ref.read(sherpiProvider.notifier).showMessage(
      context: context,
      emotion: SherpiEmotion.cheering,
      userContext: {
        'completableQuests': completableCount,
        'claimableQuests': claimableCount,
      },
    );
  }

  /// 퀘스트 데이터 저장
  Future<void> _saveQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questJsonList = _allQuests.map((quest) => 
        jsonEncode(quest.toJson())
      ).toList();
      await prefs.setStringList('saved_quests_v2', questJsonList);
    } catch (e) {
    }
  }

  /// 보너스 수령 여부 확인
  Future<bool> _isBonusAlreadyClaimed(String bonusKey) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    
    String key;
    switch (bonusKey) {
      case 'daily_bonus_v2_today':
        key = 'daily_bonus_v2_${today.year}-${today.month}-${today.day}';
        break;
      case 'weekly_bonus_v2_this_week':
        key = 'weekly_bonus_v2_${today.year}-${_getWeekOfYear(today)}';
        break;
      default:
        key = bonusKey;
    }
    
    return prefs.getBool(key) ?? false;
  }

  /// 보너스 수령 표시
  Future<void> _markBonusAsClaimed(String bonusKey) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    
    String key;
    switch (bonusKey) {
      case 'daily_bonus_v2_today':
        key = 'daily_bonus_v2_${today.year}-${today.month}-${today.day}';
        break;
      case 'weekly_bonus_v2_this_week':
        key = 'weekly_bonus_v2_${today.year}-${_getWeekOfYear(today)}';
        break;
      default:
        key = bonusKey;
    }
    
    await prefs.setBool(key, true);
  }

  /// 주차 계산
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
  
  /// 수령한 보너스 캐시 로드
  Future<void> _loadClaimedBonuses() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    
    // 일일 보너스 확인
    final dailyKey = 'daily_bonus_v2_${today.year}-${today.month}-${today.day}';
    if (prefs.getBool(dailyKey) == true) {
      _claimedBonuses.add('daily_bonus_v2_today');
    }
    
    // 주간 보너스 확인
    final weeklyKey = 'weekly_bonus_v2_${today.year}-${_getWeekOfYear(today)}';
    if (prefs.getBool(weeklyKey) == true) {
      _claimedBonuses.add('weekly_bonus_v2_today');
    }
  }

  /// 프리미엄 활성화
  Future<void> activatePremium() async {
    final pointNotifier = ref.read(globalPointProvider.notifier);
    
    // 포인트 차감 (2000P)
    if (ref.read(globalPointProvider).totalPoints >= 2000) {
      pointNotifier.spendPoints(2000, '프리미엄 퀘스트팩 구매');
      
      _isPremiumActive = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('premium_quest_active_v2', true);
      
      // 프리미엄 퀘스트 즉시 생성
      _generatePremiumQuests();
      await _saveQuests();
      state = AsyncValue.data(_allQuests);
      
      // 셰르피 축하 메시지
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.specialEvent,
        emotion: SherpiEmotion.celebrating,
        userContext: {
          'premiumType': '프리미엄 퀘스트팩',
        },
      );
    } else {
      // 포인트 부족 시 셰르피 안내 메시지
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.guidance,
        emotion: SherpiEmotion.worried,
        userContext: {
          'needPoints': 2000,
          'actionType': '프리미엄 퀘스트팩 구매',
        },
      );
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadQuests();
  }

  /// 퀘스트 통계
  QuestGenerationStats get stats {
    return QuestGeneratorService.getGenerationStats(_allQuests);
  }

  /// 완료 가능한 퀘스트 수
  int get completableQuestsCount {
    return _allQuests.where((q) => q.canComplete).length;
  }

  /// 보상 수령 가능한 퀘스트 수
  int get claimableRewardsCount {
    return _allQuests.where((q) => q.canClaim).length;
  }

  /// 일일 퀘스트 전체 완료 여부
  bool get isDailyAllCompleted {
    return QuestGeneratorService.areAllDailyQuestsCompleted(_allQuests);
  }

  /// 주간 퀘스트 전체 완료 여부
  bool get isWeeklyAllCompleted {
    return QuestGeneratorService.areAllWeeklyQuestsCompleted(_allQuests);
  }

  /// 프리미엄 활성화 여부
  bool get isPremiumActive => _isPremiumActive;
  
  /// 보너스 수령 여부 확인 (public)
  bool isBonusAlreadyClaimed(String bonusKey) {
    // 동기적으로 확인할 수 있도록 캐시된 값 사용
    return _claimedBonuses.contains(bonusKey);
  }
  
  /// 보너스 수령 표시 (public)
  Future<void> markBonusAsClaimed(String bonusKey) async {
    await _markBonusAsClaimed(bonusKey);
    _claimedBonuses.add(bonusKey);
  }
  
  /// 일일 포인트 획득량 계산
  int _calculateDailyPointsEarned(List<PointTransaction> transactions) {
    final today = DateTime.now();
    return transactions
        .where((tx) => 
          tx.isEarned &&
          tx.createdAt.year == today.year &&
          tx.createdAt.month == today.month &&
          tx.createdAt.day == today.day)
        .fold(0, (sum, tx) => sum + tx.amount);
  }
  
  /// 주간 포인트 획득량 계산
  int _calculateWeeklyPointsEarned(List<PointTransaction> transactions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    return transactions
        .where((tx) => 
          tx.isEarned &&
          tx.createdAt.isAfter(weekStart.subtract(Duration(days: 1))) &&
          tx.createdAt.isBefore(weekEnd.add(Duration(days: 1))))
        .fold(0, (sum, tx) => sum + tx.amount);
  }
}

/// 퀘스트 유형별 Provider들
final dailyQuestsProviderV2 = Provider<List<QuestInstance>>((ref) {
  final questsAsync = ref.watch(questProviderV2);
  return questsAsync.when(
    data: (quests) => quests.where((q) => q.type == QuestTypeV2.daily).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final weeklyQuestsProviderV2 = Provider<List<QuestInstance>>((ref) {
  final questsAsync = ref.watch(questProviderV2);
  return questsAsync.when(
    data: (quests) => quests.where((q) => q.type == QuestTypeV2.weekly).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final premiumQuestsProviderV2 = Provider<List<QuestInstance>>((ref) {
  final questsAsync = ref.watch(questProviderV2);
  return questsAsync.when(
    data: (quests) => quests.where((q) => q.type == QuestTypeV2.premium).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final questProgressProviderV2 = Provider<QuestProgressV2>((ref) {
  final questsAsync = ref.watch(questProviderV2);
  
  return questsAsync.when(
    data: (quests) {
      final total = quests.length;
      final inProgress = quests.where((q) => q.isInProgress).length;
      final completed = quests.where((q) => q.isCompleted).length;
      final claimable = quests.where((q) => q.canClaim).length;
      
      final today = DateTime.now();
      final todayCompleted = quests.where((q) => 
        q.status == QuestStatus.claimed && 
        q.claimedAt != null &&
        q.claimedAt!.year == today.year &&
        q.claimedAt!.month == today.month &&
        q.claimedAt!.day == today.day
      ).length;
      
      return QuestProgressV2(
        totalQuests: total,
        inProgressQuests: inProgress,
        completedQuests: completed,
        claimableQuests: claimable,
        todayCompletedQuests: todayCompleted,
        overallProgress: total > 0 ? completed / total : 0.0,
        dailyAllCompleted: QuestGeneratorService.areAllDailyQuestsCompleted(quests),
        weeklyAllCompleted: QuestGeneratorService.areAllWeeklyQuestsCompleted(quests),
      );
    },
    loading: () => const QuestProgressV2(),
    error: (_, __) => const QuestProgressV2(),
  );
});