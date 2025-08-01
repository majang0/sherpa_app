// lib/features/meetings/models/meeting_badge_model.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 🏆 모임 관련 뱃지 시스템
/// 사용자의 모임 참여도와 기여도를 게임화 요소로 표현
enum MeetingBadgeType {
  // 🎯 참여 관련 뱃지
  firstMeeting('첫 모임 참여', '첫 번째 모임에 참여했어요', 
    Icons.celebration_rounded, AppColors.warning, 1),
  socialButterfly('사교나비', '이번 달 5개 이상 모임에 참여했어요', 
    Icons.flutter_dash_rounded, AppColors.secondary, 2),
  meetingMaster('모임 마스터', '총 50개 모임에 참여했어요', 
    Icons.stars_rounded, AppColors.primary, 3),
  
  // 🏗️ 호스팅 관련 뱃지
  firstHost('첫 모임 개최', '첫 번째 모임을 성공적으로 개최했어요', 
    Icons.event_available_rounded, AppColors.success, 2),
  popularHost('인기 호스트', '평균 참여율 80% 이상을 달성했어요', 
    Icons.trending_up_rounded, AppColors.warning, 3),
  superHost('슈퍼 호스트', '총 20개 모임을 성공적으로 개최했어요', 
    Icons.military_tech_rounded, AppColors.error, 4),
  
  // 🤝 소셜 관련 뱃지
  friendMaker('친구 제조기', '모임에서 10명 이상과 친구가 되었어요', 
    Icons.group_add_rounded, AppColors.info, 2),
  networking('네트워킹 프로', '3개 이상 다른 카테고리 모임에 참여했어요', 
    Icons.hub_rounded, AppColors.primary, 2),
  socialImpact('소셜 임팩트', '리뷰 평점 평균 4.5 이상을 유지하고 있어요', 
    Icons.thumb_up_rounded, AppColors.success, 3),
  
  // ⭐ 특별 업적 뱃지
  earlyBird('얼리버드', '모임 시작 10분 전에 항상 도착해요', 
    Icons.access_time_rounded, AppColors.warning, 2),
  streakWarrior('연속 참여자', '한 달 동안 매주 모임에 참여했어요', 
    Icons.local_fire_department_rounded, AppColors.error, 3),
  communityBuilder('커뮤니티 빌더', '자신이 만든 모임이 정기 모임으로 발전했어요', 
    Icons.foundation_rounded, AppColors.primary, 4),
  
  // 🎖️ 레어 뱃지
  legendary('레전드', '모든 카테고리에서 최소 5개 모임에 참여했어요', 
    Icons.workspace_premium_rounded, AppColors.error, 5),
  ambassador('셰르파 대사', '신규 유저 20명을 모임에 초대했어요', 
    Icons.card_membership_rounded, AppColors.warning, 5);

  const MeetingBadgeType(
    this.displayName,
    this.description,
    this.icon,
    this.color,
    this.rarity,
  );

  final String displayName;
  final String description;
  final IconData icon;
  final Color color;
  final int rarity; // 1: 일반, 2: 레어, 3: 에픽, 4: 레전드, 5: 미스틱
}

/// 📊 뱃지 달성 조건 및 통계 클래스
class MeetingBadgeCondition {
  final MeetingBadgeType badgeType;
  final Map<String, dynamic> requirements;
  final int currentProgress;
  final int targetProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const MeetingBadgeCondition({
    required this.badgeType,
    required this.requirements,
    required this.currentProgress,
    required this.targetProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  /// 진행률 계산 (0.0 - 1.0)
  double get progressPercentage {
    if (targetProgress == 0) return 0.0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  /// 진행률 텍스트
  String get progressText {
    return '$currentProgress / $targetProgress';
  }

  /// 완료까지 남은 개수
  int get remainingCount {
    return (targetProgress - currentProgress).clamp(0, targetProgress);
  }

  MeetingBadgeCondition copyWith({
    MeetingBadgeType? badgeType,
    Map<String, dynamic>? requirements,
    int? currentProgress,
    int? targetProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return MeetingBadgeCondition(
      badgeType: badgeType ?? this.badgeType,
      requirements: requirements ?? this.requirements,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

/// 🎯 뱃지 달성 조건 생성 팩토리
class MeetingBadgeFactory {
  /// 사용자 통계 기반 뱃지 조건 생성
  static List<MeetingBadgeCondition> generateBadgeConditions({
    required int totalMeetingsJoined,
    required int totalMeetingsHosted,
    required int thisMonthMeetings,
    required int friendsCount,
    required int differentCategoriesJoined,
    required double averageRating,
    required int earlyArrivals,
    required int weeklyStreak,
    required bool hasRegularMeeting,
    required int referralsCount,
    required Set<String> unlockedBadges,
  }) {
    final List<MeetingBadgeCondition> conditions = [];

    // 참여 관련 뱃지
    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.firstMeeting,
      requirements: {'meetings_joined': 1},
      currentProgress: totalMeetingsJoined,
      targetProgress: 1,
      isUnlocked: unlockedBadges.contains('firstMeeting'),
      unlockedAt: unlockedBadges.contains('firstMeeting') 
        ? DateTime.now().subtract(const Duration(days: 30)) 
        : null,
    ));

    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.socialButterfly,
      requirements: {'monthly_meetings': 5},
      currentProgress: thisMonthMeetings,
      targetProgress: 5,
      isUnlocked: unlockedBadges.contains('socialButterfly'),
      unlockedAt: unlockedBadges.contains('socialButterfly') 
        ? DateTime.now().subtract(const Duration(days: 7)) 
        : null,
    ));

    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.meetingMaster,
      requirements: {'total_meetings': 50},
      currentProgress: totalMeetingsJoined,
      targetProgress: 50,
      isUnlocked: unlockedBadges.contains('meetingMaster'),
    ));

    // 호스팅 관련 뱃지
    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.firstHost,
      requirements: {'meetings_hosted': 1},
      currentProgress: totalMeetingsHosted,
      targetProgress: 1,
      isUnlocked: unlockedBadges.contains('firstHost'),
    ));

    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.superHost,
      requirements: {'meetings_hosted': 20},
      currentProgress: totalMeetingsHosted,
      targetProgress: 20,
      isUnlocked: unlockedBadges.contains('superHost'),
    ));

    // 소셜 관련 뱃지
    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.friendMaker,
      requirements: {'friends_made': 10},
      currentProgress: friendsCount,
      targetProgress: 10,
      isUnlocked: unlockedBadges.contains('friendMaker'),
    ));

    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.networking,
      requirements: {'categories_joined': 3},
      currentProgress: differentCategoriesJoined,
      targetProgress: 3,
      isUnlocked: unlockedBadges.contains('networking'),
    ));

    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.socialImpact,
      requirements: {'average_rating': 4.5},
      currentProgress: (averageRating * 10).toInt(),
      targetProgress: 45, // 4.5 * 10
      isUnlocked: unlockedBadges.contains('socialImpact'),
    ));

    // 특별 업적 뱃지
    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.earlyBird,
      requirements: {'early_arrivals': 10},
      currentProgress: earlyArrivals,
      targetProgress: 10,
      isUnlocked: unlockedBadges.contains('earlyBird'),
    ));

    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.streakWarrior,
      requirements: {'weekly_streak': 4},
      currentProgress: weeklyStreak,
      targetProgress: 4,
      isUnlocked: unlockedBadges.contains('streakWarrior'),
    ));

    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.communityBuilder,
      requirements: {'regular_meeting': true},
      currentProgress: hasRegularMeeting ? 1 : 0,
      targetProgress: 1,
      isUnlocked: unlockedBadges.contains('communityBuilder'),
    ));

    // 레어 뱃지
    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.legendary,
      requirements: {
        'categories_5_each': true,
        'total_meetings': 25,
      },
      currentProgress: differentCategoriesJoined >= 5 && totalMeetingsJoined >= 25 ? 1 : 0,
      targetProgress: 1,
      isUnlocked: unlockedBadges.contains('legendary'),
    ));

    conditions.add(MeetingBadgeCondition(
      badgeType: MeetingBadgeType.ambassador,
      requirements: {'referrals': 20},
      currentProgress: referralsCount,
      targetProgress: 20,
      isUnlocked: unlockedBadges.contains('ambassador'),
    ));

    return conditions;
  }

  /// 샘플 뱃지 조건 생성 (개발/테스트용)
  static List<MeetingBadgeCondition> generateSampleBadgeConditions() {
    final Set<String> sampleUnlockedBadges = {
      'firstMeeting',
      'socialButterfly', 
      'firstHost',
      'friendMaker',
    };

    return generateBadgeConditions(
      totalMeetingsJoined: 15,
      totalMeetingsHosted: 3,
      thisMonthMeetings: 6,
      friendsCount: 12,
      differentCategoriesJoined: 4,
      averageRating: 4.7,
      earlyArrivals: 8,
      weeklyStreak: 3,
      hasRegularMeeting: false,
      referralsCount: 5,
      unlockedBadges: sampleUnlockedBadges,
    );
  }
}

/// 🏆 뱃지 시스템 통계
class MeetingBadgeStats {
  final int totalBadges;
  final int unlockedBadges;
  final int rarityCount1; // 일반
  final int rarityCount2; // 레어
  final int rarityCount3; // 에픽
  final int rarityCount4; // 레전드
  final int rarityCount5; // 미스틱
  final double completionPercentage;
  final MeetingBadgeType? nextBadgeToUnlock;
  final int badgeScore; // 뱃지 가중 점수

  const MeetingBadgeStats({
    required this.totalBadges,
    required this.unlockedBadges,
    required this.rarityCount1,
    required this.rarityCount2,
    required this.rarityCount3,
    required this.rarityCount4,
    required this.rarityCount5,
    required this.completionPercentage,
    this.nextBadgeToUnlock,
    required this.badgeScore,
  });

  /// 뱃지 조건 목록으로부터 통계 생성
  static MeetingBadgeStats fromConditions(List<MeetingBadgeCondition> conditions) {
    final unlocked = conditions.where((c) => c.isUnlocked).toList();
    final total = conditions.length;
    
    // 레어도별 개수 계산
    int rarity1 = 0, rarity2 = 0, rarity3 = 0, rarity4 = 0, rarity5 = 0;
    int totalScore = 0;
    
    for (final condition in unlocked) {
      final rarity = condition.badgeType.rarity;
      switch (rarity) {
        case 1: rarity1++; totalScore += 10; break;
        case 2: rarity2++; totalScore += 25; break;
        case 3: rarity3++; totalScore += 50; break;
        case 4: rarity4++; totalScore += 100; break;
        case 5: rarity5++; totalScore += 200; break;
      }
    }

    // 다음에 달성할 수 있는 뱃지 찾기
    final nextBadge = conditions
        .where((c) => !c.isUnlocked && c.progressPercentage > 0.7)
        .fold<MeetingBadgeCondition?>(null, (prev, current) {
          if (prev == null) return current;
          return current.progressPercentage > prev.progressPercentage ? current : prev;
        })?.badgeType;

    return MeetingBadgeStats(
      totalBadges: total,
      unlockedBadges: unlocked.length,
      rarityCount1: rarity1,
      rarityCount2: rarity2,
      rarityCount3: rarity3,
      rarityCount4: rarity4,
      rarityCount5: rarity5,
      completionPercentage: total > 0 ? unlocked.length / total : 0.0,
      nextBadgeToUnlock: nextBadge,
      badgeScore: totalScore,
    );
  }
}