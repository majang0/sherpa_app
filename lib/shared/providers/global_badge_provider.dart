// lib/shared/providers/global_badge_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/global_badge_model.dart';
import '../constants/global_badge_data.dart';
import 'global_user_provider.dart';

/// 사용자가 장착한 뱃지 목록 Provider
final globalEquippedBadgesProvider = Provider<List<GlobalBadge>>((ref) {
  final user = ref.watch(globalUserProvider);
  return user.equippedBadgeIds
      .map((id) => GlobalBadgeData.getBadgeById(id))
      .where((badge) => badge != null)
      .cast<GlobalBadge>()
      .toList();
});

/// 사용자가 소유한 뱃지 목록 Provider
final globalOwnedBadgesProvider = Provider<List<GlobalBadge>>((ref) {
  final user = ref.watch(globalUserProvider);
  return user.ownedBadgeIds
      .map((id) => GlobalBadgeData.getBadgeById(id))
      .where((badge) => badge != null)
      .cast<GlobalBadge>()
      .toList();
});

/// 모든 뱃지 목록 Provider
final globalAllBadgesProvider = Provider<List<GlobalBadge>>((ref) {
  return GlobalBadgeData.getAllBadges();
});

/// 장착 가능한 뱃지 슬롯 수 Provider
final globalBadgeSlotCountProvider = Provider<int>((ref) {
  final user = ref.watch(globalUserProvider);
  final level = user.level;

  if (level < 10) return 1;
  if (level < 20) return 2;
  if (level < 30) return 3;
  return 4;
});

/// 뱃지 효과 총합 Provider
final globalBadgeEffectsProvider = Provider<Map<String, double>>((ref) {
  final equippedBadges = ref.watch(globalEquippedBadgesProvider);
  final Map<String, double> effects = {};

  for (final badge in equippedBadges) {
    effects[badge.effectType] = (effects[badge.effectType] ?? 0) + badge.effectValue;
  }

  return effects;
});
