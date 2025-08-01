// lib/features/meetings/models/meeting_achievement_model.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 🎖️ 모임 관련 업적 시스템
/// 장기적인 목표와 마일스톤을 게이미피케이션으로 표현
enum MeetingAchievementType {
  // 🎯 참여 관련 업적
  socialNewbie('소셜 새내기', '첫 10개 모임 참여', '모임의 즐거움을 발견했어요!',
    Icons.celebration_rounded, AppColors.success, 10, AchievementCategory.participation),
  socialExplorer('소셜 탐험가', '50개 모임 참여', '다양한 모임을 경험하고 있어요!',
    Icons.explore_rounded, AppColors.info, 50, AchievementCategory.participation),
  socialMaster('소셜 마스터', '100개 모임 참여', '모임 참여의 달인이 되었어요!',
    Icons.stars_rounded, AppColors.primary, 100, AchievementCategory.participation),
  socialLegend('소셜 레전드', '250개 모임 참여', '전설적인 모임 참여자예요!',
    Icons.workspace_premium_rounded, AppColors.warning, 250, AchievementCategory.participation),
  
  // 🏗️ 주최 관련 업적  
  hostingStart('주최의 시작', '첫 5개 모임 주최', '주최자의 길을 걷기 시작했어요!',
    Icons.event_available_rounded, AppColors.success, 5, AchievementCategory.hosting),
  hostingExpert('주최 전문가', '25개 모임 주최', '모임 주최의 전문가가 되었어요!',
    Icons.event_seat_rounded, AppColors.info, 25, AchievementCategory.hosting),
  hostingGuru('주최 구루', '50개 모임 주최', '모임 주최의 구루 레벨이에요!',
    Icons.event_note_rounded, AppColors.primary, 50, AchievementCategory.hosting),
  hostingLegend('주최 레전드', '100개 모임 주최', '전설적인 모임 주최자예요!',
    Icons.military_tech_rounded, AppColors.warning, 100, AchievementCategory.hosting),
    
  // 🤝 네트워킹 관련 업적
  networkingStarter('네트워킹 시작', '10명과 친구 연결', '네트워킹의 첫걸음을 떼었어요!',
    Icons.group_add_rounded, AppColors.success, 10, AchievementCategory.networking),
  networkingPro('네트워킹 프로', '50명과 친구 연결', '네트워킹의 프로가 되었어요!',
    Icons.groups_rounded, AppColors.info, 50, AchievementCategory.networking),
  networkingMaster('네트워킹 마스터', '100명과 친구 연결', '네트워킹의 마스터예요!',
    Icons.hub_rounded, AppColors.primary, 100, AchievementCategory.networking),
  networkingInfluencer('네트워킹 인플루언서', '200명과 친구 연결', '진정한 네트워킹 인플루언서예요!',
    Icons.campaign_rounded, AppColors.warning, 200, AchievementCategory.networking),
    
  // ⭐ 특별 업적
  diversityExplorer('다양성 탐험가', '모든 카테고리 경험', '모든 종류의 모임을 경험했어요!',
    Icons.diversity_3_rounded, AppColors.secondary, 6, AchievementCategory.special),
  consistentAttendee('꾸준한 참여자', '6개월 연속 참여', '꾸준함의 진정한 의미를 보여줬어요!',
    Icons.event_repeat_rounded, AppColors.info, 6, AchievementCategory.special),
  earlyBirdChampion('얼리버드 챔피언', '50번 일찍 도착', '시간 약속을 지키는 모범생이에요!',
    Icons.schedule_rounded, AppColors.success, 50, AchievementCategory.special),
  reviewMaster('리뷰 마스터', '100개 리뷰 작성', '모임 후기 작성의 달인이에요!',
    Icons.rate_review_rounded, AppColors.primary, 100, AchievementCategory.special),
  socialImpactMaker('소셜 임팩트 메이커', '평점 4.8 이상 유지', '모든 사람에게 긍정적 영향을 주고 있어요!',
    Icons.favorite_rounded, AppColors.error, 48, AchievementCategory.special), // 4.8 * 10
    
  // 🏆 마스터 업적
  meetingGrandMaster('모임 그랜드마스터', '모든 기본 업적 달성', '모임의 모든 영역을 마스터했어요!',
    Icons.emoji_events_rounded, AppColors.warning, 1, AchievementCategory.master),
  communityBuilder('커뮤니티 빌더', '정기 모임 5개 운영', '진정한 커뮤니티를 만들어가고 있어요!',
    Icons.foundation_rounded, AppColors.primary, 5, AchievementCategory.master),
  socialInfluencer('소셜 인플루언서', '100명 초대 성공', '다른 사람들에게 모임의 즐거움을 전파했어요!',
    Icons.share_rounded, AppColors.secondary, 100, AchievementCategory.master);

  const MeetingAchievementType(
    this.displayName,
    this.shortDescription,
    this.completionMessage,
    this.icon,
    this.color,
    this.targetValue,
    this.category,
  );

  final String displayName;
  final String shortDescription;
  final String completionMessage;
  final IconData icon;
  final Color color;
  final int targetValue;
  final AchievementCategory category;
}

/// 📊 업적 카테고리
enum AchievementCategory {
  participation('참여', Icons.people_rounded, AppColors.primary),
  hosting('주최', Icons.event_rounded, AppColors.secondary),
  networking('네트워킹', Icons.hub_rounded, AppColors.info),
  special('특별', Icons.star_rounded, AppColors.warning),
  master('마스터', Icons.emoji_events_rounded, AppColors.error);

  const AchievementCategory(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 🎖️ 업적 조건 및 진행 상황
class MeetingAchievementCondition {
  final MeetingAchievementType achievementType;
  final int currentProgress;
  final int targetProgress;
  final bool isCompleted;
  final DateTime? completedAt;
  final double difficultyMultiplier;
  final Map<String, dynamic> metadata;

  const MeetingAchievementCondition({
    required this.achievementType,
    required this.currentProgress,
    required this.targetProgress,
    required this.isCompleted,
    this.completedAt,
    this.difficultyMultiplier = 1.0,
    this.metadata = const {},
  });

  /// 진행률 (0.0 - 1.0)
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

  /// 난이도 레벨 (1-5)
  int get difficultyLevel {
    if (difficultyMultiplier <= 1.0) return 1;
    if (difficultyMultiplier <= 2.0) return 2;
    if (difficultyMultiplier <= 3.0) return 3;
    if (difficultyMultiplier <= 4.0) return 4;
    return 5;
  }

  /// 업적 점수 계산
  int get achievementScore {
    final baseScore = targetProgress * 10;
    final difficultyBonus = (difficultyMultiplier * baseScore * 0.5).toInt();
    final categoryBonus = _getCategoryBonus();
    return baseScore + difficultyBonus + categoryBonus;
  }

  int _getCategoryBonus() {
    switch (achievementType.category) {
      case AchievementCategory.participation: return 50;
      case AchievementCategory.hosting: return 100;
      case AchievementCategory.networking: return 75;
      case AchievementCategory.special: return 150;
      case AchievementCategory.master: return 300;
    }
  }

  MeetingAchievementCondition copyWith({
    MeetingAchievementType? achievementType,
    int? currentProgress,
    int? targetProgress,
    bool? isCompleted,
    DateTime? completedAt,
    double? difficultyMultiplier,
    Map<String, dynamic>? metadata,
  }) {
    return MeetingAchievementCondition(
      achievementType: achievementType ?? this.achievementType,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      difficultyMultiplier: difficultyMultiplier ?? this.difficultyMultiplier,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 🏭 업적 조건 생성 팩토리
class MeetingAchievementFactory {
  /// 사용자 통계 기반 업적 조건 생성
  static List<MeetingAchievementCondition> generateAchievementConditions({
    required int totalMeetingsJoined,
    required int totalMeetingsHosted,
    required int friendsCount,
    required int categoriesExperienced,
    required int consecutiveMonthsParticipation,
    required int earlyArrivals,
    required int reviewsWritten,
    required double averageRating,
    required bool hasCompletedAllBasicAchievements,
    required int regularMeetingsHosted,
    required int successfulInvitations,
    required Set<String> completedAchievements,
  }) {
    final List<MeetingAchievementCondition> conditions = [];

    // 참여 관련 업적
    conditions.addAll([
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.socialNewbie,
        currentProgress: totalMeetingsJoined,
        targetProgress: 10,
        isCompleted: completedAchievements.contains('socialNewbie'),
        completedAt: completedAchievements.contains('socialNewbie')
            ? DateTime.now().subtract(const Duration(days: 60))
            : null,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.socialExplorer,
        currentProgress: totalMeetingsJoined,
        targetProgress: 50,
        isCompleted: completedAchievements.contains('socialExplorer'),
        difficultyMultiplier: 1.5,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.socialMaster,
        currentProgress: totalMeetingsJoined,
        targetProgress: 100,
        isCompleted: completedAchievements.contains('socialMaster'),
        difficultyMultiplier: 2.0,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.socialLegend,
        currentProgress: totalMeetingsJoined,
        targetProgress: 250,
        isCompleted: completedAchievements.contains('socialLegend'),
        difficultyMultiplier: 3.0,
      ),
    ]);

    // 주최 관련 업적
    conditions.addAll([
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.hostingStart,
        currentProgress: totalMeetingsHosted,
        targetProgress: 5,
        isCompleted: completedAchievements.contains('hostingStart'),
        difficultyMultiplier: 1.2,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.hostingExpert,
        currentProgress: totalMeetingsHosted,
        targetProgress: 25,
        isCompleted: completedAchievements.contains('hostingExpert'),
        difficultyMultiplier: 2.0,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.hostingGuru,
        currentProgress: totalMeetingsHosted,
        targetProgress: 50,
        isCompleted: completedAchievements.contains('hostingGuru'),
        difficultyMultiplier: 2.5,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.hostingLegend,
        currentProgress: totalMeetingsHosted,
        targetProgress: 100,
        isCompleted: completedAchievements.contains('hostingLegend'),
        difficultyMultiplier: 3.5,
      ),
    ]);

    // 네트워킹 관련 업적
    conditions.addAll([
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.networkingStarter,
        currentProgress: friendsCount,
        targetProgress: 10,
        isCompleted: completedAchievements.contains('networkingStarter'),
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.networkingPro,
        currentProgress: friendsCount,
        targetProgress: 50,
        isCompleted: completedAchievements.contains('networkingPro'),
        difficultyMultiplier: 1.5,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.networkingMaster,
        currentProgress: friendsCount,
        targetProgress: 100,
        isCompleted: completedAchievements.contains('networkingMaster'),
        difficultyMultiplier: 2.0,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.networkingInfluencer,
        currentProgress: friendsCount,
        targetProgress: 200,
        isCompleted: completedAchievements.contains('networkingInfluencer'),
        difficultyMultiplier: 3.0,
      ),
    ]);

    // 특별 업적
    conditions.addAll([
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.diversityExplorer,
        currentProgress: categoriesExperienced,
        targetProgress: 6,
        isCompleted: completedAchievements.contains('diversityExplorer'),
        difficultyMultiplier: 1.8,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.consistentAttendee,
        currentProgress: consecutiveMonthsParticipation,
        targetProgress: 6,
        isCompleted: completedAchievements.contains('consistentAttendee'),
        difficultyMultiplier: 2.2,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.earlyBirdChampion,
        currentProgress: earlyArrivals,
        targetProgress: 50,
        isCompleted: completedAchievements.contains('earlyBirdChampion'),
        difficultyMultiplier: 1.5,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.reviewMaster,
        currentProgress: reviewsWritten,
        targetProgress: 100,
        isCompleted: completedAchievements.contains('reviewMaster'),
        difficultyMultiplier: 1.3,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.socialImpactMaker,
        currentProgress: (averageRating * 10).toInt(),
        targetProgress: 48, // 4.8 * 10
        isCompleted: completedAchievements.contains('socialImpactMaker'),
        difficultyMultiplier: 2.5,
      ),
    ]);

    // 마스터 업적
    conditions.addAll([
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.meetingGrandMaster,
        currentProgress: hasCompletedAllBasicAchievements ? 1 : 0,
        targetProgress: 1,
        isCompleted: completedAchievements.contains('meetingGrandMaster'),
        difficultyMultiplier: 4.0,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.communityBuilder,
        currentProgress: regularMeetingsHosted,
        targetProgress: 5,
        isCompleted: completedAchievements.contains('communityBuilder'),
        difficultyMultiplier: 3.5,
      ),
      MeetingAchievementCondition(
        achievementType: MeetingAchievementType.socialInfluencer,
        currentProgress: successfulInvitations,
        targetProgress: 100,
        isCompleted: completedAchievements.contains('socialInfluencer'),
        difficultyMultiplier: 4.0,
      ),
    ]);

    return conditions;
  }

  /// 샘플 업적 조건 생성 (개발/테스트용)
  static List<MeetingAchievementCondition> generateSampleAchievementConditions() {
    final Set<String> sampleCompletedAchievements = {
      'socialNewbie',
      'hostingStart',
      'networkingStarter',
    };

    return generateAchievementConditions(
      totalMeetingsJoined: 35,
      totalMeetingsHosted: 8,
      friendsCount: 25,
      categoriesExperienced: 4,
      consecutiveMonthsParticipation: 3,
      earlyArrivals: 20,
      reviewsWritten: 28,
      averageRating: 4.6,
      hasCompletedAllBasicAchievements: false,
      regularMeetingsHosted: 2,
      successfulInvitations: 15,
      completedAchievements: sampleCompletedAchievements,
    );
  }
}

/// 📊 업적 시스템 통계
class MeetingAchievementStats {
  final int totalAchievements;
  final int completedAchievements;
  final int totalScore;
  final Map<AchievementCategory, int> categoryProgress;
  final Map<AchievementCategory, int> categoryTotals;
  final double overallCompletionRate;
  final MeetingAchievementType? nextAchievementToComplete;
  final int currentTier; // 1: 브론즈, 2: 실버, 3: 골드, 4: 플래티넘, 5: 다이아몬드

  const MeetingAchievementStats({
    required this.totalAchievements,
    required this.completedAchievements,
    required this.totalScore,
    required this.categoryProgress,
    required this.categoryTotals,
    required this.overallCompletionRate,
    this.nextAchievementToComplete,
    required this.currentTier,
  });

  /// 업적 조건 목록으로부터 통계 생성
  static MeetingAchievementStats fromConditions(List<MeetingAchievementCondition> conditions) {
    final completed = conditions.where((c) => c.isCompleted).toList();
    final total = conditions.length;
    
    // 카테고리별 통계
    final Map<AchievementCategory, int> categoryProgress = {};
    final Map<AchievementCategory, int> categoryTotals = {};
    
    for (final category in AchievementCategory.values) {
      final categoryConditions = conditions.where((c) => 
        c.achievementType.category == category).toList();
      final categoryCompleted = categoryConditions.where((c) => 
        c.isCompleted).length;
      
      categoryProgress[category] = categoryCompleted;
      categoryTotals[category] = categoryConditions.length;
    }
    
    // 총 점수 계산
    final totalScore = completed.fold<int>(0, (sum, condition) => 
      sum + condition.achievementScore);
    
    // 다음 달성 예정 업적
    final nextAchievement = conditions
        .where((c) => !c.isCompleted && c.progressPercentage > 0.5)
        .fold<MeetingAchievementCondition?>(null, (prev, current) {
          if (prev == null) return current;
          return current.progressPercentage > prev.progressPercentage ? current : prev;
        })?.achievementType;
    
    // 현재 티어 계산
    final currentTier = _calculateTier(totalScore, completed.length);
    
    return MeetingAchievementStats(
      totalAchievements: total,
      completedAchievements: completed.length,
      totalScore: totalScore,
      categoryProgress: categoryProgress,
      categoryTotals: categoryTotals,
      overallCompletionRate: total > 0 ? completed.length / total : 0.0,
      nextAchievementToComplete: nextAchievement,
      currentTier: currentTier,
    );
  }
  
  static int _calculateTier(int totalScore, int completedCount) {
    if (totalScore >= 10000 && completedCount >= 15) return 5; // 다이아몬드
    if (totalScore >= 5000 && completedCount >= 10) return 4;  // 플래티넘
    if (totalScore >= 2000 && completedCount >= 6) return 3;   // 골드
    if (totalScore >= 500 && completedCount >= 3) return 2;    // 실버
    return 1; // 브론즈
  }
  
  /// 티어 이름
  String get tierName {
    switch (currentTier) {
      case 1: return '브론즈';
      case 2: return '실버';
      case 3: return '골드';
      case 4: return '플래티넘';
      case 5: return '다이아몬드';
      default: return '브론즈';
    }
  }
  
  /// 티어 색상
  Color get tierColor {
    switch (currentTier) {
      case 1: return const Color(0xFFCD7F32); // 브론즈
      case 2: return const Color(0xFFC0C0C0); // 실버
      case 3: return const Color(0xFFFFD700); // 골드
      case 4: return const Color(0xFFE5E4E2); // 플래티넘
      case 5: return const Color(0xFFB9F2FF); // 다이아몬드
      default: return const Color(0xFFCD7F32);
    }
  }
}