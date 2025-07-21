// lib/shared/providers/global_challenge_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../features/meetings/models/available_challenge_model.dart';
import '../models/global_user_model.dart';
import 'global_user_provider.dart';
import 'global_point_provider.dart';
import 'global_sherpi_provider.dart';
import 'global_badge_provider.dart';
import '../../core/constants/sherpi_dialogues.dart';

/// 🌍 글로벌 챌린지 관리 Provider
/// 모든 챌린지 관련 데이터와 로직을 중앙에서 관리
final globalChallengeProvider = StateNotifierProvider<GlobalChallengeNotifier, GlobalChallengeState>((ref) {
  return GlobalChallengeNotifier(ref);
});

/// 글로벌 챌린지 상태
class GlobalChallengeState {
  final List<AvailableChallenge> availableChallenges;
  final List<AvailableChallenge> myJoinedChallenges;
  final List<AvailableChallenge> completedChallenges;
  final bool isLoading;
  final String? errorMessage;

  const GlobalChallengeState({
    this.availableChallenges = const [],
    this.myJoinedChallenges = const [],
    this.completedChallenges = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GlobalChallengeState copyWith({
    List<AvailableChallenge>? availableChallenges,
    List<AvailableChallenge>? myJoinedChallenges,
    List<AvailableChallenge>? completedChallenges,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GlobalChallengeState(
      availableChallenges: availableChallenges ?? this.availableChallenges,
      myJoinedChallenges: myJoinedChallenges ?? this.myJoinedChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 글로벌 챌린지 관리 Notifier
class GlobalChallengeNotifier extends StateNotifier<GlobalChallengeState> {
  final Ref ref;

  GlobalChallengeNotifier(this.ref) : super(const GlobalChallengeState()) {
    _loadInitialData();
  }

  /// 초기 데이터 로드
  void _loadInitialData() {
    state = state.copyWith(isLoading: true);
    _loadMockChallenges();
    state = state.copyWith(isLoading: false);
  }

  /// 모크 챌린지 데이터 로드
  void _loadMockChallenges() {
    final now = DateTime.now();
    
    final challenges = [
      AvailableChallenge(
        id: 'challenge_1',
        title: '7일 운동 챌린지',
        description: '일주일 동안 매일 30분 이상 운동하기',
        category: '건강',
        categoryType: ChallengeCategory.fitness,
        difficulty: 2,
        durationDays: 7,
        maxParticipants: 100,
        currentParticipants: 73,
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 8)),
        requirements: ['매일 30분 이상 운동', '운동 기록 인증'],
        rewards: {'points': 500, 'experience': 200, 'badge': 'health_warrior'},
      ),
      AvailableChallenge(
        id: 'challenge_2',
        title: '독서 마라톤',
        description: '한 달 동안 5권 이상 책 읽기',
        category: '학습',
        categoryType: ChallengeCategory.study,
        difficulty: 3,
        durationDays: 30,
        maxParticipants: 50,
        currentParticipants: 28,
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 32)),
        requirements: ['책 5권 이상 읽기', '독서록 작성', '토론 참여'],
        rewards: {'points': 1000, 'experience': 500, 'badge': 'book_master'},
      ),
      AvailableChallenge(
        id: 'challenge_3',
        title: '새벽 기상 습관',
        description: '21일 동안 오전 6시 기상 인증하기',
        category: '습관',
        categoryType: ChallengeCategory.habit,
        difficulty: 4,
        durationDays: 21,
        maxParticipants: 200,
        currentParticipants: 156,
        startDate: now,
        endDate: now.add(const Duration(days: 21)),
        requirements: ['매일 오전 6시 기상', '기상 인증 사진'],
        rewards: {'points': 800, 'experience': 300, 'badge': 'early_bird'},
      ),
      AvailableChallenge(
        id: 'challenge_4',
        title: '명상 입문',
        description: '14일 동안 매일 10분 명상하기',
        category: '마음챙김',
        categoryType: ChallengeCategory.mindfulness,
        difficulty: 1,
        durationDays: 14,
        maxParticipants: 80,
        currentParticipants: 45,
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 17)),
        requirements: ['매일 10분 명상', '명상 일지 작성'],
        rewards: {'points': 400, 'experience': 150, 'badge': 'zen_master'},
      ),
      AvailableChallenge(
        id: 'challenge_5',
        title: '소셜 미디어 디톡스',
        description: '7일 동안 SNS 사용하지 않기',
        category: '라이프스타일',
        categoryType: ChallengeCategory.lifestyle,
        difficulty: 3,
        durationDays: 7,
        maxParticipants: 60,
        currentParticipants: 42,
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 8)),
        requirements: ['SNS 앱 삭제', '대체 활동 실천'],
        rewards: {'points': 600, 'experience': 250, 'badge': 'digital_detox'},
      ),
    ];

    state = state.copyWith(availableChallenges: challenges);
  }

  /// 챌린지 참여 (완전한 글로벌 연동)
  Future<bool> joinChallenge(AvailableChallenge challenge) async {
    try {
      // 1. 참여 가능성 체크
      if (!challenge.canJoin) {
        ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.encouragement,
          customDialogue: '이미 마감되었거나 참여할 수 없는 챌린지예요! 😅',
          emotion: SherpiEmotion.thinking,
        );
        return false;
      }

      // 2. 참여비 차감
      final pointNotifier = ref.read(globalPointProvider.notifier);
      final fee = challenge.participationFee;

      if (fee > 0) {
        final success = pointNotifier.spendPoints(
          fee,
          '챌린지 참여비: ${challenge.title}',
        );

        if (!success) {
          final currentPoints = ref.read(globalTotalPointsProvider);
          ref.read(sherpiProvider.notifier).showInstantMessage(
            context: SherpiContext.encouragement,
            customDialogue: '포인트가 부족해요! 현재 ${currentPoints}P 보유중입니다. ${fee}P가 필요해요.',
            emotion: SherpiEmotion.thinking,
          );
          return false;
        }
      }

      // 3. 챌린지 참여 처리
      final updatedChallenges = state.availableChallenges.map((c) {
        if (c.id == challenge.id) {
          return c.copyWith(
            currentParticipants: c.currentParticipants + 1,
          );
        }
        return c;
      }).toList();

      // 4. 내 참여 챌린지에 추가
      final updatedJoinedChallenges = [...state.myJoinedChallenges, challenge];

      state = state.copyWith(
        availableChallenges: updatedChallenges,
        myJoinedChallenges: updatedJoinedChallenges,
      );

      // 5. 글로벌 사용자 데이터에 기록
      final userNotifier = ref.read(globalUserProvider.notifier);
      userNotifier.addExperience(25.0); // 참여 보너스

      // 6. 카테고리별 능력치 증가
      switch (challenge.categoryType) {
        case ChallengeCategory.fitness:
          userNotifier.increaseStats(deltaStamina: 0.1);
          break;
        case ChallengeCategory.study:
          userNotifier.increaseStats(deltaKnowledge: 0.1);
          break;
        case ChallengeCategory.habit:
          userNotifier.increaseStats(deltaWillpower: 0.2);
          break;
        case ChallengeCategory.mindfulness:
          userNotifier.increaseStats(deltaWillpower: 0.1, deltaSociality: 0.1);
          break;
        case ChallengeCategory.lifestyle:
          userNotifier.increaseStats(deltaTechnique: 0.1);
          break;
      }

      // 7. 성공 피드백
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.levelUp,
        customDialogue: '🎉 "${challenge.title}" 챌린지 참여 완료!\n참여 보너스 경험치 +25를 획득했어요!',
        emotion: SherpiEmotion.celebrating,
      );

      return true;
    } catch (e) {
      print('챌린지 참여 실패: $e');
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.encouragement,
        customDialogue: '챌린지 참여 중 오류가 발생했어요. 다시 시도해주세요! 😅',
        emotion: SherpiEmotion.thinking,
      );
      return false;
    }
  }

  /// 챌린지 완료 처리 (전체 보상 지급)
  Future<bool> completeChallenge(AvailableChallenge challenge) async {
    try {
      // 1. 완료 처리
      final updatedJoinedChallenges = state.myJoinedChallenges
          .where((c) => c.id != challenge.id)
          .toList();
      
      final updatedCompletedChallenges = [...state.completedChallenges, challenge];

      state = state.copyWith(
        myJoinedChallenges: updatedJoinedChallenges,
        completedChallenges: updatedCompletedChallenges,
      );

      // 2. 글로벌 보상 지급
      final userNotifier = ref.read(globalUserProvider.notifier);
      final pointNotifier = ref.read(globalPointProvider.notifier);

      // 경험치 보상
      if (challenge.experienceReward > 0) {
        userNotifier.addExperience(challenge.experienceReward.toDouble());
      }

      // 포인트 보상
      if (challenge.completionReward > 0) {
        pointNotifier.addPoints(
          challenge.completionReward,
          '챌린지 완료 보상: ${challenge.title}',
        );
      }

      // 배지 보상 (있는 경우)
      final badgeId = challenge.rewards['badge'] as String?;
      if (badgeId != null) {
        userNotifier.addBadge(badgeId);
      }

      // 3. 대량 능력치 보상
      final finalStatBonus = challenge.difficulty * 0.1; // 난이도별 추가 보상
      switch (challenge.categoryType) {
        case ChallengeCategory.fitness:
          userNotifier.increaseStats(
            deltaStamina: finalStatBonus,
            deltaWillpower: finalStatBonus * 0.5,
          );
          break;
        case ChallengeCategory.study:
          userNotifier.increaseStats(
            deltaKnowledge: finalStatBonus,
            deltaTechnique: finalStatBonus * 0.5,
          );
          break;
        case ChallengeCategory.habit:
          userNotifier.increaseStats(
            deltaWillpower: finalStatBonus,
            deltaSociality: finalStatBonus * 0.3,
          );
          break;
        case ChallengeCategory.mindfulness:
          userNotifier.increaseStats(
            deltaWillpower: finalStatBonus * 0.7,
            deltaSociality: finalStatBonus * 0.7,
          );
          break;
        case ChallengeCategory.lifestyle:
          userNotifier.increaseStats(
            deltaTechnique: finalStatBonus,
            deltaWillpower: finalStatBonus * 0.3,
          );
          break;
      }

      // 4. 완료 피드백
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.levelUp,
        customDialogue: '🏆 "${challenge.title}" 챌린지 완료!\n경험치 +${challenge.experienceReward}, 포인트 +${challenge.completionReward}',
        emotion: SherpiEmotion.celebrating,
      );

      return true;
    } catch (e) {
      print('챌린지 완료 처리 실패: $e');
      return false;
    }
  }

  /// 챌린지 포기
  void quitChallenge(AvailableChallenge challenge) {
    final updatedJoinedChallenges = state.myJoinedChallenges
        .where((c) => c.id != challenge.id)
        .toList();

    // 참여자 수 감소
    final updatedChallenges = state.availableChallenges.map((c) {
      if (c.id == challenge.id) {
        return c.copyWith(
          currentParticipants: (c.currentParticipants - 1).clamp(0, c.maxParticipants),
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      availableChallenges: updatedChallenges,
      myJoinedChallenges: updatedJoinedChallenges,
    );

    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '다음에는 꼭 완주해보세요! 포기하지 않는 것이 중요해요! 💪',
      emotion: SherpiEmotion.thinking,
    );
  }

  /// 카테고리별 챌린지 필터링
  List<AvailableChallenge> getChallengesByCategory(ChallengeCategory? category) {
    if (category == null) return state.availableChallenges;
    return state.availableChallenges.where((challenge) => challenge.categoryType == category).toList();
  }

  /// 난이도별 챌린지 필터링
  List<AvailableChallenge> getChallengesByDifficulty(int? difficulty) {
    if (difficulty == null) return state.availableChallenges;
    return state.availableChallenges.where((challenge) => challenge.difficulty == difficulty).toList();
  }

  /// 참여 가능한 챌린지만 필터링
  List<AvailableChallenge> get availableChallenges {
    return state.availableChallenges.where((challenge) => challenge.canJoin).toList();
  }

  /// 인기 챌린지 (참여자가 많은 순)
  List<AvailableChallenge> get popularChallenges {
    final sortedChallenges = List<AvailableChallenge>.from(state.availableChallenges);
    sortedChallenges.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
    return sortedChallenges.take(5).toList();
  }

  /// 추천 챌린지 (사용자 능력치 기반)
  List<AvailableChallenge> getRecommendedChallenges() {
    final user = ref.read(globalUserProvider);
    final stats = user.stats;

    final sortedChallenges = List<AvailableChallenge>.from(availableChallenges);

    // 가장 낮은 능력치를 개선할 수 있는 챌린지 추천
    if (stats.willpower <= stats.stamina && stats.willpower <= stats.knowledge && stats.willpower <= stats.technique) {
      // 의지력이 낮으면 습관/마음챙김 챌린지 추천
      sortedChallenges.sort((a, b) {
        final aIsWillpower = a.categoryType == ChallengeCategory.habit || a.categoryType == ChallengeCategory.mindfulness;
        final bIsWillpower = b.categoryType == ChallengeCategory.habit || b.categoryType == ChallengeCategory.mindfulness;
        if (aIsWillpower && !bIsWillpower) return -1;
        if (!aIsWillpower && bIsWillpower) return 1;
        return 0;
      });
    } else if (stats.stamina <= stats.knowledge && stats.stamina <= stats.technique) {
      // 체력이 낮으면 건강 챌린지 추천
      sortedChallenges.sort((a, b) {
        if (a.categoryType == ChallengeCategory.fitness && b.categoryType != ChallengeCategory.fitness) return -1;
        if (a.categoryType != ChallengeCategory.fitness && b.categoryType == ChallengeCategory.fitness) return 1;
        return 0;
      });
    } else if (stats.knowledge <= stats.technique) {
      // 지식이 낮으면 학습 챌린지 추천
      sortedChallenges.sort((a, b) {
        if (a.categoryType == ChallengeCategory.study && b.categoryType != ChallengeCategory.study) return -1;
        if (a.categoryType != ChallengeCategory.study && b.categoryType == ChallengeCategory.study) return 1;
        return 0;
      });
    } else {
      // 기술이 낮으면 라이프스타일 챌린지 추천
      sortedChallenges.sort((a, b) {
        if (a.categoryType == ChallengeCategory.lifestyle && b.categoryType != ChallengeCategory.lifestyle) return -1;
        if (a.categoryType != ChallengeCategory.lifestyle && b.categoryType == ChallengeCategory.lifestyle) return 1;
        return 0;
      });
    }

    return sortedChallenges.take(3).toList();
  }

  /// 시작 예정 챌린지 (24시간 이내)
  List<AvailableChallenge> get upcomingChallenges {
    final now = DateTime.now();
    return state.availableChallenges.where((challenge) =>
      challenge.canJoin &&
      challenge.startDate.difference(now).inHours <= 24 &&
      challenge.startDate.isAfter(now)
    ).toList();
  }

  /// 데이터 새로고침
  void refresh() {
    _loadInitialData();
  }
}

// ==================== UI용 Provider들 ====================

/// 카테고리별 챌린지 Provider
final globalChallengesByCategoryProvider = Provider.family<List<AvailableChallenge>, ChallengeCategory?>((ref, category) {
  final notifier = ref.read(globalChallengeProvider.notifier);
  return notifier.getChallengesByCategory(category);
});

/// 난이도별 챌린지 Provider
final globalChallengesByDifficultyProvider = Provider.family<List<AvailableChallenge>, int?>((ref, difficulty) {
  final notifier = ref.read(globalChallengeProvider.notifier);
  return notifier.getChallengesByDifficulty(difficulty);
});

/// 참여 가능한 챌린지 Provider
final globalAvailableChallengesProvider = Provider<List<AvailableChallenge>>((ref) {
  final notifier = ref.read(globalChallengeProvider.notifier);
  return notifier.availableChallenges;
});

/// 인기 챌린지 Provider
final globalPopularChallengesProvider = Provider<List<AvailableChallenge>>((ref) {
  final notifier = ref.read(globalChallengeProvider.notifier);
  return notifier.popularChallenges;
});

/// 추천 챌린지 Provider
final globalRecommendedChallengesProvider = Provider<List<AvailableChallenge>>((ref) {
  final notifier = ref.read(globalChallengeProvider.notifier);
  return notifier.getRecommendedChallenges();
});

/// 시작 예정 챌린지 Provider
final globalUpcomingChallengesProvider = Provider<List<AvailableChallenge>>((ref) {
  final notifier = ref.read(globalChallengeProvider.notifier);
  return notifier.upcomingChallenges;
});

/// 내 참여 챌린지 Provider
final globalMyJoinedChallengesProvider = Provider<List<AvailableChallenge>>((ref) {
  final state = ref.watch(globalChallengeProvider);
  return state.myJoinedChallenges;
});

/// 내 완료 챌린지 Provider
final globalMyCompletedChallengesProvider = Provider<List<AvailableChallenge>>((ref) {
  final state = ref.watch(globalChallengeProvider);
  return state.completedChallenges;
});

/// 챌린지 통계 Provider
final globalChallengeStatsProvider = Provider<GlobalChallengeStats>((ref) {
  final state = ref.watch(globalChallengeProvider);
  final joinedCount = state.myJoinedChallenges.length;
  final completedCount = state.completedChallenges.length;
  final completionRate = joinedCount > 0 ? (completedCount / (joinedCount + completedCount)) : 0.0;

  // 카테고리별 완료 횟수
  final categoryStats = <ChallengeCategory, int>{};
  for (final challenge in state.completedChallenges) {
    categoryStats[challenge.categoryType] = (categoryStats[challenge.categoryType] ?? 0) + 1;
  }

  return GlobalChallengeStats(
    totalJoined: joinedCount + completedCount,
    currentlyJoined: joinedCount,
    totalCompleted: completedCount,
    completionRate: completionRate,
    categoryStats: categoryStats,
  );
});

/// 글로벌 챌린지 통계 데이터 클래스
class GlobalChallengeStats {
  final int totalJoined;
  final int currentlyJoined;
  final int totalCompleted;
  final double completionRate;
  final Map<ChallengeCategory, int> categoryStats;

  const GlobalChallengeStats({
    required this.totalJoined,
    required this.currentlyJoined,
    required this.totalCompleted,
    required this.completionRate,
    required this.categoryStats,
  });

  ChallengeCategory? get favoriteCategory {
    if (categoryStats.isEmpty) return null;

    final sorted = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  String get completionGrade {
    if (completionRate >= 0.9) return 'S';
    if (completionRate >= 0.8) return 'A';
    if (completionRate >= 0.7) return 'B';
    if (completionRate >= 0.6) return 'C';
    return 'D';
  }
}