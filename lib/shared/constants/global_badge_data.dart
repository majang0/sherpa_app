// lib/shared/constants/global_badge_data.dart

import '../models/global_badge_model.dart';

class GlobalBadgeData {
  static final Map<String, GlobalBadge> allBadges = {
    // 일반 등급 뱃지 (Common)
    'common_luck': GlobalBadge(
      id: 'common_luck',
      name: '초심자의 행운',
      description: '등반 성공률 +3% 증가',
      tier: GlobalBadgeTier.common,
      effectType: 'success_rate_bonus',
      effectValue: 3.0,
      iconEmoji: '🍀',
      iconCodePoint: 0xe7e9,
    ),
    'common_stamina': GlobalBadge(
      id: 'common_stamina',
      name: '꾸준함의 증표',
      description: '획득 경험치 +10% 증가',
      tier: GlobalBadgeTier.common,
      effectType: 'exp_bonus',
      effectValue: 10.0,
      iconEmoji: '💪',
      iconCodePoint: 0xe7e9,
    ),
    'common_explorer': GlobalBadge(
      id: 'common_explorer',
      name: '탐험가의 발걸음',
      description: '기본 등반력 +5% 증가',
      tier: GlobalBadgeTier.common,
      effectType: 'CLIMBING_POWER_MULTIPLY',
      effectValue: 5.0,
      iconEmoji: '🧭',
      iconCodePoint: 0xe7e9,
    ),

    // 희귀 등급 뱃지 (Rare)
    'rare_knowledge': GlobalBadge(
      id: 'rare_knowledge',
      name: '지식의 탐구자',
      description: '등반 성공 시 15% 확률로 숨겨진 보상 발견',
      tier: GlobalBadgeTier.rare,
      effectType: 'hidden_treasures',
      effectValue: 15.0,
      iconEmoji: '📚',
      iconCodePoint: 0xe7e9,
    ),
    'rare_mountain': GlobalBadge(
      id: 'rare_mountain',
      name: '고산 전문가',
      description: 'Lv.50 이상 산에서 등반력 +15% 증가',
      tier: GlobalBadgeTier.rare,
      effectType: 'high_mountain_power',
      effectValue: 15.0,
      iconEmoji: '⛰️',
      iconCodePoint: 0xe7e9,
    ),
    'rare_clover': GlobalBadge(
      id: 'rare_clover',
      name: '행운의 클로버',
      description: '등반 성공 시 20% 확률로 포인트 2배 획득',
      tier: GlobalBadgeTier.rare,
      effectType: 'double_rewards',
      effectValue: 20.0,
      iconEmoji: '🍀',
      iconCodePoint: 0xe7e9,
    ),

    // 영웅 등급 뱃지 (Epic)
    'epic_golden': GlobalBadge(
      id: 'epic_golden',
      name: '황금 피켈',
      description: '획득 포인트 +15% 증가',
      tier: GlobalBadgeTier.epic,
      effectType: 'point_bonus',
      effectValue: 15.0,
      iconEmoji: '⛏️',
      iconCodePoint: 0xe7e9,
    ),
    'epic_will': GlobalBadge(
      id: 'epic_will',
      name: '굳건한 의지',
      description: '등반 성공률 +8% 증가',
      tier: GlobalBadgeTier.epic,
      effectType: 'success_rate_bonus',
      effectValue: 8.0,
      iconEmoji: '🛡️',
      iconCodePoint: 0xe7e9,
    ),
    'epic_time': GlobalBadge(
      id: 'epic_time',
      name: '시간 마술사',
      description: '등반 시간 20% 단축',
      tier: GlobalBadgeTier.epic,
      effectType: 'climbing_time_reduction',
      effectValue: 20.0,
      iconEmoji: '⏰',
      iconCodePoint: 0xe7e9,
    ),

    // 전설 등급 뱃지 (Legendary)
    'legendary_ancestor': GlobalBadge(
      id: 'legendary_ancestor',
      name: '선조의 가호',
      description: '1일 1회 등반 즉시 완료 + 보상 2배',
      tier: GlobalBadgeTier.legendary,
      effectType: 'instant_complete',
      effectValue: 1.0,
      iconEmoji: '👑',
      iconCodePoint: 0xe7e9,
    ),

    // 레벨업 기념 뱃지
    'level_10_adept': GlobalBadge(
      id: 'level_10_adept',
      name: '숙련된 등반가',
      description: '레벨 10 달성 기념 뱃지',
      tier: GlobalBadgeTier.rare,
      effectType: 'level_achievement',
      effectValue: 0.0,
      iconEmoji: '🥉',
      iconCodePoint: 0xe7e9,
    ),
    'level_20_expert': GlobalBadge(
      id: 'level_20_expert',
      name: '전문 산악인',
      description: '레벨 20 달성 기념 뱃지',
      tier: GlobalBadgeTier.epic,
      effectType: 'level_achievement',
      effectValue: 0.0,
      iconEmoji: '🥈',
      iconCodePoint: 0xe7e9,
    ),
    'level_30_sherpa': GlobalBadge(
      id: 'level_30_sherpa',
      name: '셰르파',
      description: '레벨 30 달성 기념 뱃지',
      tier: GlobalBadgeTier.legendary,
      effectType: 'level_achievement',
      effectValue: 0.0,
      iconEmoji: '🥇',
      iconCodePoint: 0xe7e9,
    ),
  };

  /// ID로 뱃지 찾기
  static GlobalBadge? getBadgeById(String id) {
    return allBadges[id];
  }

  /// 등급별 뱃지 목록
  static List<GlobalBadge> getBadgesByTier(GlobalBadgeTier tier) {
    return allBadges.values.where((badge) => badge.tier == tier).toList();
  }

  /// 효과 타입별 뱃지 목록
  static List<GlobalBadge> getBadgesByEffectType(String effectType) {
    return allBadges.values
        .where((badge) => badge.effectType == effectType)
        .toList();
  }

  /// 모든 뱃지 목록
  static List<GlobalBadge> getAllBadges() {
    return allBadges.values.toList();
  }

  /// 레벨 달성 뱃지 목록
  static List<GlobalBadge> getLevelAchievementBadges() {
    return allBadges.values
        .where((badge) => badge.effectType == 'level_achievement')
        .toList();
  }
}
