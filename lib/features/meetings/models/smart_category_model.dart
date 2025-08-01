// lib/features/meetings/models/smart_category_model.dart

import 'package:flutter/material.dart';
import 'available_meeting_model.dart';

/// 🧠 스마트 카테고리 시스템
/// 4개 메인 카테고리로 모임 탐색 최적화
enum SmartCategory {
  all('전체', '🌟', Color(0xFF6366F1), '모든 모임을 한눈에'),
  activity('액티비티', '💪', Color(0xFF10B981), '몸과 마음을 움직이는'),
  culture('문화', '🎭', Color(0xFFEC4899), '문화와 예술을 즐기는'),
  study('스터디', '📚', Color(0xFF3B82F6), '함께 배우고 성장하는'),
  social('소셜/네트워킹', '🤝', Color(0xFFF59E0B), '사람들과 소통하는');

  const SmartCategory(this.displayName, this.emoji, this.color, this.description);
  
  final String displayName;
  final String emoji;
  final Color color;
  final String description;

  /// 서브 카테고리 매핑 (7개 카테고리 시스템에 맞춤)
  List<MeetingCategory> get subCategories {
    switch (this) {
      case SmartCategory.all:
        return MeetingCategory.values;
      case SmartCategory.activity:
        return [MeetingCategory.exercise, MeetingCategory.outdoor];
      case SmartCategory.culture:
        return [MeetingCategory.culture];
      case SmartCategory.study:
        return [MeetingCategory.study, MeetingCategory.reading];
      case SmartCategory.social:
        return [MeetingCategory.networking];
    }
  }

  /// 카테고리별 추천 메시지 (셰르파 AI용)
  String get aiRecommendationMessage {
    switch (this) {
      case SmartCategory.all:
        return '다양한 모임들이 기다리고 있어요! 어떤 모험을 시작해볼까요? 🎯';
      case SmartCategory.activity:
        return '몸을 움직이면 마음도 건강해져요! 체력 up, 기분 up! 💪';
      case SmartCategory.culture:
        return '문화와 예술로 새로운 영감을 얻어보세요! 감성을 충전할 시간이에요 🎭';
      case SmartCategory.study:
        return '새로운 지식은 새로운 세계의 문을 열어줘요! 함께 배워봐요 📖';
      case SmartCategory.social:
        return '좋은 사람들과의 만남이 인생을 풍요롭게 만들어요! 🌟';
    }
  }

  /// 카테고리별 빈 상태 메시지
  String get emptyStateMessage {
    switch (this) {
      case SmartCategory.all:
        return '아직 등록된 모임이 없어요\n첫 번째 모임을 만들어보세요!';
      case SmartCategory.activity:
        return '액티비티 모임이 곧 올라올 예정이에요\n운동이나 아웃도어 모임을 직접 만들어보는 건 어떨까요?';
      case SmartCategory.culture:
        return '문화 모임이 준비 중이에요\n영화, 전시, 공연 감상 모임을 만들어보세요!';
      case SmartCategory.study:
        return '스터디 모임이 준비 중이에요\n함께 공부할 친구들을 모집해보세요!';
      case SmartCategory.social:
        return '소셜 모임이 곧 시작될 거예요\n새로운 만남의 기회를 만들어보세요!';
    }
  }

  /// 카테고리별 권장 태그
  List<String> get recommendedTags {
    switch (this) {
      case SmartCategory.all:
        return ['전체', '추천', '인기', '신규', '마감임박'];
      case SmartCategory.activity:
        return ['운동', '스포츠', '헬스', '요가', '등산', '캠핑', '하이킹', '아웃도어'];
      case SmartCategory.culture:
        return ['문화', '영화', '뮤지컬', '전시', '공연', '콘서트', '갤러리', '예술'];
      case SmartCategory.study:
        return ['스터디', '공부', '독서', '책', '토론', '세미나', '자격증', '학습'];
      case SmartCategory.social:
        return ['네트워킹', '친목', '파티', '만남', '소셜', '교류', '사교', '인맥'];
    }
  }

  /// 사용자 능력치 기반 추천 점수 계산
  double getRecommendationScore(Map<String, double> userStats) {
    final stamina = userStats['stamina'] ?? 0.0;
    final knowledge = userStats['knowledge'] ?? 0.0;
    final technique = userStats['technique'] ?? 0.0;
    final sociality = userStats['sociality'] ?? 0.0;
    final willpower = userStats['willpower'] ?? 0.0;

    switch (this) {
      case SmartCategory.all:
        return (stamina + knowledge + technique + sociality + willpower) / 5;
      case SmartCategory.activity:
        return (stamina * 0.4) + (willpower * 0.3) + (technique * 0.2) + (sociality * 0.1);
      case SmartCategory.culture:
        return (knowledge * 0.3) + (sociality * 0.3) + (technique * 0.2) + (willpower * 0.2);
      case SmartCategory.study:
        return (knowledge * 0.4) + (technique * 0.3) + (willpower * 0.2) + (stamina * 0.1);
      case SmartCategory.social:
        return (sociality * 0.5) + (willpower * 0.2) + (knowledge * 0.2) + (technique * 0.1);
    }
  }
}

/// 🎯 스마트 카테고리 필터링 로직
class SmartCategoryFilter {
  /// 스마트 카테고리로 모임 필터링
  static List<AvailableMeeting> filterMeetings(
    List<AvailableMeeting> meetings,
    SmartCategory smartCategory,
  ) {
    if (smartCategory == SmartCategory.all) {
      return meetings;
    }

    final subCategories = smartCategory.subCategories;
    return meetings.where((meeting) => 
      subCategories.contains(meeting.category)
    ).toList();
  }

  /// AI 추천 기반 모임 정렬 (사용자 능력치 고려)
  static List<AvailableMeeting> sortByRecommendation(
    List<AvailableMeeting> meetings,
    SmartCategory smartCategory,
    Map<String, double> userStats,
  ) {
    final sortedMeetings = List<AvailableMeeting>.from(meetings);
    final categoryScore = smartCategory.getRecommendationScore(userStats);

    sortedMeetings.sort((a, b) {
      // 1. 카테고리 매치 점수
      final aIsMatch = smartCategory.subCategories.contains(a.category);
      final bIsMatch = smartCategory.subCategories.contains(b.category);
      
      if (aIsMatch && !bIsMatch) return -1;
      if (!aIsMatch && bIsMatch) return 1;

      // 2. 참여 가능성 (날짜, 정원)
      final aCanJoin = a.canJoin ? 1 : 0;
      final bCanJoin = b.canJoin ? 1 : 0;
      final joinComparison = bCanJoin.compareTo(aCanJoin);
      if (joinComparison != 0) return joinComparison;

      // 3. 인기도 (참여자 비율)
      final aPopularity = a.participationRate;
      final bPopularity = b.participationRate;
      final popularityComparison = bPopularity.compareTo(aPopularity);
      if (popularityComparison != 0) return popularityComparison;

      // 4. 시간 근접성 (가까운 미래 우선)
      final now = DateTime.now();
      final aDiff = a.dateTime.difference(now).abs().inHours;
      final bDiff = b.dateTime.difference(now).abs().inHours;
      
      return aDiff.compareTo(bDiff);
    });

    return sortedMeetings;
  }

  /// 카테고리별 모임 개수 카운팅
  static Map<SmartCategory, int> countMeetingsByCategory(List<AvailableMeeting> meetings) {
    final counts = <SmartCategory, int>{};
    
    for (final category in SmartCategory.values) {
      final filteredMeetings = filterMeetings(meetings, category);
      counts[category] = filteredMeetings.length;
    }
    
    return counts;
  }

  /// 추천 우선순위 카테고리 결정
  static SmartCategory getRecommendedCategory(Map<String, double> userStats) {
    double maxScore = 0.0;
    SmartCategory recommendedCategory = SmartCategory.all;

    for (final category in SmartCategory.values) {
      if (category == SmartCategory.all) continue;
      
      final score = category.getRecommendationScore(userStats);
      if (score > maxScore) {
        maxScore = score;
        recommendedCategory = category;
      }
    }

    return recommendedCategory;
  }
}

/// 📊 카테고리 통계 데이터
class SmartCategoryStats {
  final SmartCategory category;
  final int totalMeetings;
  final int availableMeetings;
  final int participatingCount;
  final double averageRating;
  final List<String> popularTags;

  const SmartCategoryStats({
    required this.category,
    required this.totalMeetings,
    required this.availableMeetings,
    required this.participatingCount,
    required this.averageRating,
    required this.popularTags,
  });

  /// 참여율 계산
  double get participationRate {
    if (totalMeetings == 0) return 0.0;
    return participatingCount / totalMeetings;
  }

  /// 카테고리 활성도 점수
  double get activityScore {
    return (availableMeetings * 0.4) + 
           (participationRate * 0.3) + 
           (averageRating * 0.2) + 
           (popularTags.length * 0.1);
  }
}