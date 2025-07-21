import 'package:flutter/material.dart';

class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String category; // 'growth', 'community', 'streak', 'milestone'
  final int requiredValue;
  final String requiredType; // 'xp', 'days', 'quests', 'meetings'
  final DateTime? unlockedAt;
  final bool isUnlocked;
  final int currentProgress;
  final String rarity; // 'common', 'rare', 'epic', 'legendary'

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.requiredValue,
    required this.requiredType,
    this.unlockedAt,
    required this.isUnlocked,
    required this.currentProgress,
    required this.rarity,
  });

  double get progressPercentage => (currentProgress / requiredValue).clamp(0.0, 1.0);

  bool get isNearCompletion => progressPercentage >= 0.8;

  Color get rarityColor {
    switch (rarity) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  AchievementBadge copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    String? category,
    int? requiredValue,
    String? requiredType,
    DateTime? unlockedAt,
    bool? isUnlocked,
    int? currentProgress,
    String? rarity,
  }) {
    return AchievementBadge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      requiredValue: requiredValue ?? this.requiredValue,
      requiredType: requiredType ?? this.requiredType,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentProgress: currentProgress ?? this.currentProgress,
      rarity: rarity ?? this.rarity,
    );
  }
}

class GrowthFeedback {
  final String message;
  final String type; // 'encouragement', 'achievement', 'suggestion', 'milestone'
  final String emoji;
  final Color color;
  final DateTime timestamp;

  const GrowthFeedback({
    required this.message,
    required this.type,
    required this.emoji,
    required this.color,
    required this.timestamp,
  });
}
