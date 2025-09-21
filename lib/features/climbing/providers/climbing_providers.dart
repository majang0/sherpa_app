// features/climbing/providers/climbing_providers.dart
// 글로벌 시스템으로 마이그레이션된 호환성 파일

import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🔄 글로벌 시스템 import
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/providers/global_badge_provider.dart';
import '../../../shared/models/global_badge_model.dart';

// 🔄 기존 코드 호환성을 위한 Provider 별칭

/// 사용자 등반력 Provider (글로벌 시스템 연결)
final climbingPowerProvider = Provider<double>((ref) {
  return ref.watch(userClimbingPowerProvider);
});

/// 장착 뱃지 목록 Provider (글로벌 시스템 연결)
final equippedBadgesProvider = Provider<List<GlobalBadge>>((ref) {
  return ref.watch(globalEquippedBadgesProvider);
});

/// 소유 뱃지 목록 Provider (글로벌 시스템 연결)
final ownedBadgesProvider = Provider<List<GlobalBadge>>((ref) {
  return ref.watch(globalOwnedBadgesProvider);
});

/// 모든 뱃지 목록 Provider (글로벌 시스템 연결)
final allBadgesProvider = Provider<List<GlobalBadge>>((ref) {
  return ref.watch(globalAllBadgesProvider);
});

/// 뱃지 슬롯 수 Provider (글로벌 시스템 연결)
final badgeSlotCountProvider = Provider<int>((ref) {
  return ref.watch(globalBadgeSlotCountProvider);
});

/// 현재 등반 중 상태 Provider (글로벌 시스템 연결)
final isClimbingProvider = Provider<bool>((ref) {
  return ref.watch(isCurrentlyClimbingProvider);
});

/// 등반 진행률 Provider (글로벌 시스템 연결)
final climbingProgressProvider = Provider<double>((ref) {
  final session = ref.watch(currentClimbingSessionProvider);
  if (session == null || !session.isActive) return 0.0;
  return session.progress;
});

/// 등반 기록 Provider (글로벌 시스템 연결)
final climbingHistoryProvider = Provider((ref) {
  final user = ref.watch(globalUserProvider);
  final logs = user.dailyRecords.climbingLogs;
  final sortedLogs = List.from(logs)
    ..sort((a, b) => b.startTime.compareTo(a.startTime));
  return sortedLogs;
});

/// 등반 통계 Provider (글로벌 시스템 연결)
final climbingStatsProvider = Provider((ref) {
  return ref.watch(climbingStatisticsProvider);
});

// 🎯 레거시 호환성: 기존 climbing 관련 Provider들을 글로벌 시스템으로 연결
// 이제 모든 등반 로직은 global_user_provider.dart에서 관리됩니다.
