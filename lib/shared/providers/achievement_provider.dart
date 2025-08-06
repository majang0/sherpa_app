import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement_model.dart';
import '../../core/constants/app_colors.dart';

class AchievementNotifier extends StateNotifier<List<AchievementBadge>> {
  AchievementNotifier() : super(_getInitialAchievements());

  static List<AchievementBadge> _getInitialAchievements() {
    return [
      AchievementBadge(
        id: 'first_level',
        title: '첫 걸음',
        description: '첫 레벨 달성',
        emoji: '🌱',
        category: 'growth',
        requiredValue: 1,
        requiredType: 'level',
        isUnlocked: true,
        currentProgress: 1,
        rarity: 'common',
        unlockedAt: DateTime.now().subtract(Duration(days: 30)),
      ),
      AchievementBadge(
        id: 'xp_1000',
        title: 'XP 마스터',
        description: '1000 XP 달성',
        emoji: '⭐',
        category: 'growth',
        requiredValue: 1000,
        requiredType: 'xp',
        isUnlocked: true,
        currentProgress: 1000,
        rarity: 'rare',
        unlockedAt: DateTime.now().subtract(Duration(days: 15)),
      ),
      AchievementBadge(
        id: 'streak_7',
        title: '일주일 연속',
        description: '7일 연속 활동',
        emoji: '🔥',
        category: 'streak',
        requiredValue: 7,
        requiredType: 'days',
        isUnlocked: true,
        currentProgress: 7,
        rarity: 'epic',
        unlockedAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      AchievementBadge(
        id: 'community_10',
        title: '커뮤니티 활동가',
        description: '10회 모임 참여',
        emoji: '🤝',
        category: 'community',
        requiredValue: 10,
        requiredType: 'meetings',
        isUnlocked: false,
        currentProgress: 7,
        rarity: 'rare',
      ),
      AchievementBadge(
        id: 'level_10',
        title: '성장의 달인',
        description: '레벨 10 달성',
        emoji: '🏆',
        category: 'growth',
        requiredValue: 10,
        requiredType: 'level',
        isUnlocked: false,
        currentProgress: 8,
        rarity: 'epic',
      ),
      AchievementBadge(
        id: 'quest_50',
        title: '퀘스트 마스터',
        description: '50개 퀘스트 완료',
        emoji: '⚔️',
        category: 'growth',
        requiredValue: 50,
        requiredType: 'quests',
        isUnlocked: false,
        currentProgress: 32,
        rarity: 'legendary',
      ),
    ];
  }

  void updateProgress(String achievementId, int newProgress) {
    state = state.map((achievement) {
      if (achievement.id == achievementId) {
        final updated = achievement.copyWith(currentProgress: newProgress);

        // 달성 조건 확인
        if (!updated.isUnlocked && updated.currentProgress >= updated.requiredValue) {
          return updated.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
        }
        return updated;
      }
      return achievement;
    }).toList();
  }

  void unlockAchievement(String achievementId) {
    state = state.map((achievement) {
      if (achievement.id == achievementId && !achievement.isUnlocked) {
        return achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          currentProgress: achievement.requiredValue,
        );
      }
      return achievement;
    }).toList();
  }

  List<AchievementBadge> get unlockedAchievements =>
      state.where((achievement) => achievement.isUnlocked).toList();

  List<AchievementBadge> get nearCompletionAchievements =>
      state.where((achievement) => !achievement.isUnlocked && achievement.isNearCompletion).toList();

  List<GrowthFeedback> generateGrowthFeedback() {
    final feedbacks = <GrowthFeedback>[];

    // 최근 달성한 배지
    final recentAchievements = unlockedAchievements
        .where((a) => a.unlockedAt != null &&
        DateTime.now().difference(a.unlockedAt!).inDays <= 7)
        .toList();

    for (final achievement in recentAchievements) {
      feedbacks.add(GrowthFeedback(
        message: '🎉 "${achievement.title}" 배지를 획득했습니다!',
        type: 'achievement',
        emoji: achievement.emoji,
        color: AppColors.success,
        timestamp: achievement.unlockedAt!,
      ));
    }

    // 완료 임박 배지
    for (final achievement in nearCompletionAchievements) {
      feedbacks.add(GrowthFeedback(
        message: '${achievement.emoji} "${achievement.title}" 달성까지 ${achievement.requiredValue - achievement.currentProgress}개 남았어요!',
        type: 'encouragement',
        emoji: '💪',
        color: AppColors.warning,
        timestamp: DateTime.now(),
      ));
    }

    return feedbacks..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}

final achievementProvider = StateNotifierProvider<AchievementNotifier, List<AchievementBadge>>(
      (ref) => AchievementNotifier(),
);

final growthFeedbackProvider = Provider<List<GrowthFeedback>>((ref) {
  final achievements = ref.watch(achievementProvider.notifier);
  return achievements.generateGrowthFeedback();
});
