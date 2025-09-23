import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

// 모델 imports
import '../models/climbing_models.dart';
import '../models/mountain.dart';
import '../../features/climbing/models/badge.dart';

// 글로벌 Provider imports
import 'global_user_provider.dart';
import 'global_point_provider.dart';
import 'global_game_provider.dart';
import 'global_user_title_provider.dart';

// 상수 imports
import '../../core/constants/mountain_data.dart';

/// 글로벌 등반 시스템 Provider
final globalClimbingProvider =
    StateNotifierProvider<GlobalClimbingNotifier, ClimbingState>((ref) {
  return GlobalClimbingNotifier(ref);
});

class GlobalClimbingNotifier extends StateNotifier<ClimbingState> {
  final Ref ref;

  GlobalClimbingNotifier(this.ref) : super(ClimbingState.initial) {
    _loadClimbingData();
  }

  /// SharedPreferences에서 등반 데이터 로드
  Future<void> _loadClimbingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final climbingJson = prefs.getString('global_climbing_data');
      if (climbingJson != null) {
        final climbingData = jsonDecode(climbingJson);
        state = ClimbingState.fromJson(climbingData);

        // 기존 등반 세션 상태 체크 및 업데이트
        _updateClimbingSessionStatus();
      }
    } catch (e) {
      LoggerService.instance.d('Failed to load climbing data: $e');
    }
  }

  /// SharedPreferences에 등반 데이터 저장
  Future<void> _saveClimbingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('global_climbing_data', jsonEncode(state.toJson()));
    } catch (e) {
      LoggerService.instance.d('Failed to save climbing data: $e');
    }
  }

  /// 등반 시작
  void startClimbing({
    required int mountainId,
    required String mountainName,
    required String region,
    required int difficulty,
    required double durationHours,
    required double mountainPower,
  }) {
    // 이미 등반 중이면 시작 불가
    if (state.isCurrentlyClimbing) {
      LoggerService.instance.d('이미 등반 중입니다.');
      return;
    }

    // 사용자 등반력 계산
    final gameSystem = ref.read(globalGameProvider);
    final user = ref.read(globalUserProvider);
    final userPower = _calculateUserClimbingPower();

    // 성공 확률 계산
    final equippedBadges = _getEquippedBadges();
    final successProbability = gameSystem.calculateSuccessProbability(
      userPower: userPower,
      mountainPower: mountainPower,
      willpower: user.stats.willpower,
      equippedBadges: equippedBadges,
    );

    // 등반 세션 생성
    final session = ClimbingSession(
      id: 'climbing_${DateTime.now().millisecondsSinceEpoch}',
      mountainId: mountainId,
      mountainName: mountainName,
      startTime: DateTime.now(),
      durationHours: durationHours,
      successProbability: successProbability,
      isActive: true,
      status: ClimbingSessionStatus.active,
      userPower: userPower,
      mountainPower: mountainPower,
      metadata: {
        'region': region,
        'difficulty': difficulty,
      },
    );

    // 상태 업데이트
    state = state.copyWith(
      currentSession: session,
      lastUpdated: DateTime.now(),
    );

    _saveClimbingData();

    // 등반 시작 시에는 셰르피 메시지 없음

    LoggerService.instance
        .d('등반 시작: $mountainName (예상 소요 시간: ${durationHours}h)');
  }

  /// 등반 완료 (수동 또는 자동)
  void completeClimbing({
    bool? forceResult, // true: 강제 성공, false: 강제 실패, null: 확률에 따라
  }) {
    final session = state.currentSession;
    if (session == null || !session.isActive) {
      LoggerService.instance.d('등반 중인 세션이 없습니다.');
      return;
    }

    final now = DateTime.now();
    final actualDuration =
        now.difference(session.startTime).inMilliseconds / (1000 * 3600); // 시간

    // 성공/실패 결정
    bool isSuccess;
    if (forceResult != null) {
      isSuccess = forceResult;
    } else {
      isSuccess = math.Random().nextDouble() < session.successProbability;
    }

    // 보상 계산
    final gameSystem = ref.read(globalGameProvider);
    final difficulty = session.metadata?['difficulty'] ?? 1;
    final region = session.metadata?['region'] ?? '미알';

    final rewards = _calculateClimbingRewards(
      gameSystem: gameSystem,
      difficulty: difficulty,
      durationHours: actualDuration,
      isSuccess: isSuccess,
    );

    // 등반 기록 생성
    final record = ClimbingRecord(
      id: session.id,
      mountainId: session.mountainId,
      mountainName: session.mountainName,
      region: region,
      difficulty: difficulty,
      startTime: session.startTime,
      endTime: now,
      durationHours: actualDuration,
      isSuccess: isSuccess,
      userPower: session.userPower,
      mountainPower: session.mountainPower,
      successProbability: session.successProbability,
      rewards: rewards,
    );

    // 등반 기록 추가 및 통계 업데이트
    final updatedHistory = [...state.history, record];
    final updatedStatistics = ClimbingStatistics.fromRecords(updatedHistory);

    // 등반 세션 종료
    state = state.copyWith(
      history: updatedHistory,
      statistics: updatedStatistics,
      currentSession: session.copyWith(
        isActive: false,
        status: isSuccess
            ? ClimbingSessionStatus.completed
            : ClimbingSessionStatus.failed,
      ),
      lastUpdated: now,
    );

    // 보상 지급 (다른 글로벌 시스템들과 연동)
    if (rewards.hasRewards) {
      _distributeRewards(rewards, isSuccess, session.mountainName, record);
    }

    // 등반 성공 시 셰르피 메시지는 handleActivityCompletion에서 처리하므로 여기서는 제거

    _saveClimbingData();
    LoggerService.instance
        .d('등반 완료: ${session.mountainName} - ${isSuccess ? "성공" : "실패"}');
  }

  /// 등반 취소
  void cancelClimbing() {
    final session = state.currentSession;
    if (session == null || !session.isActive) {
      return;
    }

    state = state.copyWith(
      currentSession: session.copyWith(
        isActive: false,
        status: ClimbingSessionStatus.cancelled,
      ),
      lastUpdated: DateTime.now(),
    );

    _saveClimbingData();

    // 등반 취소 시에는 셰르피 메시지 없음
  }

  /// 등반 세션 상태 업데이트 (주기적 호출)
  void _updateClimbingSessionStatus() {
    final session = state.currentSession;
    if (session == null || !session.isActive) {
      return;
    }

    final progress = session.progress;

    // 등반이 완료 시간에 도달한 경우 자동 완료
    if (progress >= 1.0) {
      completeClimbing(); // 확률에 따라 자동 결정
    }
  }

  /// 보상 분배 (다른 글로벌 시스템들과 연동)
  void _distributeRewards(
    ClimbingRewards rewards,
    bool isSuccess,
    String mountainName,
    ClimbingRecord record,
  ) {
    // 경험치 지급
    if (rewards.experience > 0) {
      ref.read(globalUserProvider.notifier).addExperience(rewards.experience);
    }

    // 포인트 지급
    if (rewards.points > 0) {
      ref.read(globalPointProvider.notifier).addPoints(
            rewards.points,
            '등반 성공: $mountainName',
          );
    }

    // 능력치 증가
    if (rewards.statIncreases.isNotEmpty) {
      ref.read(globalUserProvider.notifier).increaseStats(
            deltaStamina: rewards.statIncreases['stamina'] ?? 0,
            deltaKnowledge: rewards.statIncreases['knowledge'] ?? 0,
            deltaTechnique: rewards.statIncreases['technique'] ?? 0,
            deltaSociality: rewards.statIncreases['sociality'] ?? 0,
            deltaWillpower: rewards.statIncreases['willpower'] ?? 0,
          );
    }

    // 새 뱃지 획득
    for (final badgeId in rewards.newBadgeIds) {
      ref.read(globalUserProvider.notifier).addBadge(badgeId);
    }
  }

  /// 등반 보상 계산
  ClimbingRewards _calculateClimbingRewards({
    required gameSystem,
    required int difficulty,
    required double durationHours,
    required bool isSuccess,
  }) {
    double experience = 0;
    int points = 0;
    Map<String, double> statIncreases = {};
    List<String> newBadgeIds = [];
    String? specialReward;

    if (isSuccess) {
      // 성공 시 보상
      experience = gameSystem.calculateSuccessXp(difficulty, durationHours);
      points =
          gameSystem.calculateSuccessPoints(difficulty, durationHours).toInt();

      // 난이도에 따른 능력치 증가
      if (difficulty >= 100) {
        statIncreases = {'stamina': 0.5, 'technique': 0.3, 'willpower': 0.2};
      } else if (difficulty >= 50) {
        statIncreases = {'stamina': 0.3, 'technique': 0.2, 'willpower': 0.1};
      } else {
        statIncreases = {'stamina': 0.2, 'technique': 0.1};
      }

      // 특별한 산 등반 시 뱃지 획득 기회
      if (difficulty == 200) {
        // 에베레스트
        newBadgeIds.add('legendary_everest_conqueror');
        specialReward = '전설의 에베레스트 정복자 뱃지 획득!';
      } else if (difficulty >= 100) {
        if (math.Random().nextDouble() < 0.1) {
          // 10% 확률
          newBadgeIds.add('epic_mountain_king');
        }
      }
    } else {
      // 실패 시 보상
      experience = gameSystem.calculateFailureXp(difficulty, durationHours);
      points = 0;
      statIncreases = {'willpower': 0.1}; // 실패해도 의지 증가
    }

    return ClimbingRewards(
      experience: experience,
      points: points,
      statIncreases: statIncreases,
      newBadgeIds: newBadgeIds,
      specialReward: specialReward,
    );
  }

  /// 사용자 등반력 계산
  double _calculateUserClimbingPower() {
    final user = ref.read(globalUserProvider);
    final titleBonus = ref.read(globalUserTitleProvider).bonus;
    final gameSystem = ref.read(globalGameProvider);
    final equippedBadges = _getEquippedBadges();

    return gameSystem.calculateFinalClimbingPower(
      level: user.level,
      titleBonus: titleBonus,
      stamina: user.stats.stamina,
      knowledge: user.stats.knowledge,
      technique: user.stats.technique,
      equippedBadges: equippedBadges,
    );
  }

  /// 장착 뱃지 리스트 가져오기
  List<Badge> _getEquippedBadges() {
    final user = ref.read(globalUserProvider);
    final gameSystem = ref.read(globalGameProvider);

    return user.equippedBadgeIds
        .map((id) => gameSystem.allBadges.firstWhere(
              (badge) => badge.id == id,
              orElse: () => gameSystem.allBadges.first,
            ))
        .toList();
  }

  /// 등반 기록 조회
  List<ClimbingRecord> getClimbingHistory({int? limit}) {
    final sortedLogs = List<ClimbingRecord>.from(state.history)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return limit != null ? sortedLogs.take(limit).toList() : sortedLogs;
  }

  /// 등반 통계 조회
  ClimbingStatistics getClimbingStatistics() {
    return state.statistics;
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    // 현재 등반 세션 상태 업데이트
    _updateClimbingSessionStatus();

    // 필요 시 추가 새로고침 로직
  }

  /// 등반 상태 강제 업데이트 (디버그용)
  void forceUpdateSession() {
    _updateClimbingSessionStatus();
  }
}

// ==================== UI용 Provider들 ====================

/// 현재 등반 세션 Provider
final currentClimbingSessionProvider = Provider<ClimbingSession?>((ref) {
  return ref
      .watch(globalClimbingProvider.select((state) => state.currentSession));
});

/// 등반 중 상태 Provider
final isCurrentlyClimbingProvider = Provider<bool>((ref) {
  return ref.watch(
      globalClimbingProvider.select((state) => state.isCurrentlyClimbing));
});

/// 등반 진행률 Provider
final climbingProgressProvider = Provider<double>((ref) {
  return ref
      .watch(globalClimbingProvider.select((state) => state.currentProgress));
});

/// 등반 남은 시간 Provider
final climbingRemainingTimeProvider = Provider<Duration>((ref) {
  return ref.watch(
      globalClimbingProvider.select((state) => state.currentRemainingTime));
});

/// 등반 기록 Provider
final climbingHistoryProvider = Provider<List<ClimbingRecord>>((ref) {
  return ref.watch(globalClimbingProvider.select((state) => state.history));
});

/// 등반 통계 Provider
final climbingStatisticsProvider = Provider<ClimbingStatistics>((ref) {
  return ref.watch(globalClimbingProvider.select((state) => state.statistics));
});

/// 오늘의 등반 기록 Provider
final todayClimbingRecordsProvider = Provider<List<ClimbingRecord>>((ref) {
  return ref
      .watch(globalClimbingProvider.select((state) => state.todayRecords));
});

/// 사용자 등반력 Provider
final userClimbingPowerProvider = Provider<double>((ref) {
  final climbingNotifier = ref.read(globalClimbingProvider.notifier);
  return climbingNotifier._calculateUserClimbingPower();
});

/// 레벨별 추천 산 Provider
final recommendedMountainsProvider = Provider<List<Mountain>>((ref) {
  final user = ref.watch(globalUserProvider);
  final userPower = ref.watch(userClimbingPowerProvider);

  return MountainData.getRecommendedMountains(user.level, userPower);
});

/// 산 성공 확률 계산 Provider
final mountainSuccessProbabilityProvider =
    Provider.family<double, Mountain>((ref, mountain) {
  final user = ref.watch(globalUserProvider);
  final gameSystem = ref.watch(globalGameProvider);
  final userPower = ref.watch(userClimbingPowerProvider);

  // 장착 뱃지 가져오기
  final climbingNotifier = ref.read(globalClimbingProvider.notifier);
  final equippedBadges = climbingNotifier._getEquippedBadges();

  return gameSystem.calculateSuccessProbability(
    userPower: userPower,
    mountainPower: mountain.requiredPower,
    willpower: user.stats.willpower,
    equippedBadges: equippedBadges,
  );
});

/// 등반 가능한 산 목록 Provider (등반력 기준 필터링)
final availableMountainsProvider = Provider<List<Mountain>>((ref) {
  final userPower = ref.watch(userClimbingPowerProvider);
  final allMountains = MountainData.allMountains;

  // 사용자 등반력의 0.5배 ~ 2배 범위의 산들만 표시
  return allMountains.where((mountain) {
    final powerRatio = userPower / mountain.requiredPower;
    return powerRatio >= 0.3 && powerRatio <= 3.0;
  }).toList();
});

/// 등반 세션 남은 시간 텍스트 Provider
final climbingTimeRemainingTextProvider = Provider<String>((ref) {
  final remainingTime = ref.watch(climbingRemainingTimeProvider);

  if (remainingTime == Duration.zero) {
    return '등반 완료';
  }

  final hours = remainingTime.inHours;
  final minutes = remainingTime.inMinutes % 60;

  if (hours > 0) {
    return '$hours시간 $minutes분 남음';
  } else {
    return '$minutes분 남음';
  }
});

/// 오늘의 등반 성취 Provider
final todayClimbingAchievementProvider = Provider<Map<String, dynamic>>((ref) {
  final todayRecords = ref.watch(todayClimbingRecordsProvider);

  final totalAttempts = todayRecords.length;
  final successCount = todayRecords.where((r) => r.isSuccess).length;
  final totalExperience = todayRecords.fold<double>(
    0.0,
    (sum, r) => sum + r.rewards.experience,
  );
  final totalPoints = todayRecords.fold<int>(
    0,
    (sum, r) => sum + r.rewards.points,
  );

  return {
    'totalAttempts': totalAttempts,
    'successCount': successCount,
    'successRate': totalAttempts > 0 ? successCount / totalAttempts : 0.0,
    'totalExperience': totalExperience,
    'totalPoints': totalPoints,
  };
});
