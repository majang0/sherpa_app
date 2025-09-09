import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../shared/models/global_user_model.dart';
import '../constants/analysis_constants.dart';

/// 사용자 데이터 분석 결과 모델
class AnalysisResult {
  final ActivityPatterns activityPatterns;
  final MoodAnalysis moodAnalysis;
  final PerformanceMetrics performanceMetrics;
  final List<Insight> insights;
  final List<Recommendation> recommendations;
  final DateTime analyzedAt;

  const AnalysisResult({
    required this.activityPatterns,
    required this.moodAnalysis,
    required this.performanceMetrics,
    required this.insights,
    required this.recommendations,
    required this.analyzedAt,
  });
}

/// 활동 패턴 분석 결과
class ActivityPatterns {
  final Map<String, int> activityFrequency;      // 활동별 빈도
  final Map<int, double> weeklyDistribution;    // 요일별 활동 분포
  final Map<int, double> hourlyDistribution;    // 시간대별 활동 분포
  final String mostActiveDay;                    // 가장 활발한 요일
  final String mostActiveTime;                   // 가장 활발한 시간대
  final double consistencyScore;                 // 일관성 점수 (0-100)
  final int currentStreak;                       // 현재 연속 일수
  final int longestStreak;                       // 최장 연속 일수

  const ActivityPatterns({
    required this.activityFrequency,
    required this.weeklyDistribution,
    required this.hourlyDistribution,
    required this.mostActiveDay,
    required this.mostActiveTime,
    required this.consistencyScore,
    required this.currentStreak,
    required this.longestStreak,
  });
}

/// 기분 분석 결과
class MoodAnalysis {
  final Map<String, double> moodDistribution;    // 기분별 분포
  final String dominantMood;                     // 주요 기분
  final double moodStability;                    // 기분 안정성 점수
  final Map<String, String> activityMoodMap;     // 활동별 주요 기분
  final List<MoodTrend> recentTrends;           // 최근 기분 트렌드

  const MoodAnalysis({
    required this.moodDistribution,
    required this.dominantMood,
    required this.moodStability,
    required this.activityMoodMap,
    required this.recentTrends,
  });
}

/// 기분 트렌드
class MoodTrend {
  final DateTime date;
  final String mood;
  final double score;

  const MoodTrend({
    required this.date,
    required this.mood,
    required this.score,
  });
}

/// 성과 지표
class PerformanceMetrics {
  final double goalCompletionRate;              // 목표 달성률
  final Map<String, double> statGrowthRate;     // 스탯별 성장률
  final double overallProgress;                 // 전체 진행도
  final int totalActivities;                    // 총 활동 수
  final double averageSatisfaction;             // 평균 만족도
  final Map<String, double> categoryPerformance; // 카테고리별 성과

  const PerformanceMetrics({
    required this.goalCompletionRate,
    required this.statGrowthRate,
    required this.overallProgress,
    required this.totalActivities,
    required this.averageSatisfaction,
    required this.categoryPerformance,
  });
}

/// 인사이트
class Insight {
  final String title;
  final String description;
  final InsightType type;
  final double importance; // 0-1
  final IconData icon;

  const Insight({
    required this.title,
    required this.description,
    required this.type,
    required this.importance,
    required this.icon,
  });
}

enum InsightType {
  strength,    // 강점
  weakness,    // 약점
  opportunity, // 기회
  trend,       // 트렌드
  achievement, // 성취
}

/// 추천사항
class Recommendation {
  final String title;
  final String description;
  final String actionText;
  final RecommendationType type;
  final int priority; // 1-5
  final IconData icon;

  const Recommendation({
    required this.title,
    required this.description,
    required this.actionText,
    required this.type,
    required this.priority,
    required this.icon,
  });
}

enum RecommendationType {
  goal,        // 목표 설정
  activity,    // 활동 추천
  improvement, // 개선 사항
  challenge,   // 도전 과제
  balance,     // 균형 조정
}

/// 사용자 데이터 분석 서비스
class UserDataAnalyzer {
  
  /// 전체 분석 수행
  static AnalysisResult analyzeUserData(GlobalUser user) {
    try {
      final now = DateTime.now();
      // 각 부분별 분석 수행
      final activityPatterns = _analyzeActivityPatterns(user);
      final moodAnalysis = _analyzeMoodPatterns(user);
      final performanceMetrics = _analyzePerformance(user);
      final insights = _generateInsights(user, activityPatterns, moodAnalysis, performanceMetrics);
      final recommendations = _generateRecommendations(user, activityPatterns, moodAnalysis, performanceMetrics);
      
      return AnalysisResult(
        activityPatterns: activityPatterns,
        moodAnalysis: moodAnalysis,
        performanceMetrics: performanceMetrics,
        insights: insights,
        recommendations: recommendations,
        analyzedAt: now,
      );
    } catch (e, stackTrace) {
      // 분석 중 오류 발생 시 기본 결과 반환
      // 분석 오류 시 기본 결과 반환
      return _createDefaultAnalysisResult(user, DateTime.now());
    }
  }
  
  /// 활동 패턴 분석
  static ActivityPatterns _analyzeActivityPatterns(GlobalUser user) {
    final records = user.dailyRecords;
    
    // 활동별 빈도 계산
    final activityFrequency = <String, int>{
      '운동': records.exerciseLogs.length,
      '독서': records.readingLogs.length,
      '일기': records.diaryLogs.length,
      '모임': records.meetingLogs.length,
    };
    
    // 요일별 분포 계산
    final weeklyDistribution = <int, double>{};
    final hourlyDistribution = <int, double>{};
    
    // 모든 활동의 날짜/시간 수집
    final allDates = <DateTime>[];
    allDates.addAll(records.exerciseLogs.map((e) => e.date));
    allDates.addAll(records.readingLogs.map((e) => e.date));
    allDates.addAll(records.diaryLogs.map((e) => e.date));
    allDates.addAll(records.meetingLogs.map((e) => e.date));
    
    // 요일별 분포 계산 (1=월요일, 7=일요일)
    for (int i = 1; i <= 7; i++) {
      final count = allDates.where((date) => date.weekday == i).length;
      weeklyDistribution[i] = allDates.isEmpty ? 0.0 : (count / allDates.length) * 100;
    }
    
    // 시간대별 분포 계산
    for (int i = 0; i < 24; i++) {
      final count = allDates.where((date) => date.hour == i).length;
      hourlyDistribution[i] = allDates.isEmpty ? 0.0 : (count / allDates.length) * 100;
    }
    
    // 가장 활발한 요일 찾기
    String mostActiveDay = '월요일';
    double maxDayActivity = 0.0;
    weeklyDistribution.forEach((day, percentage) {
      if (percentage > maxDayActivity) {
        maxDayActivity = percentage;
        mostActiveDay = _getDayName(day);
      }
    });
    
    // 가장 활발한 시간대 찾기
    String mostActiveTime = '오전';
    double morningActivity = 0.0;
    double afternoonActivity = 0.0;
    double eveningActivity = 0.0;
    
    hourlyDistribution.forEach((hour, percentage) {
      if (hour >= 6 && hour < 12) morningActivity += percentage;
      else if (hour >= 12 && hour < 18) afternoonActivity += percentage;
      else if (hour >= 18 && hour < 24) eveningActivity += percentage;
    });
    
    if (afternoonActivity > morningActivity && afternoonActivity > eveningActivity) {
      mostActiveTime = '오후';
    } else if (eveningActivity > morningActivity && eveningActivity > afternoonActivity) {
      mostActiveTime = '저녁';
    }
    
    // 일관성 점수 계산
    final consistencyScore = _calculateConsistencyScore(allDates);
    
    // 연속 일수 계산
    final streaks = _calculateStreaks(allDates);
    
    return ActivityPatterns(
      activityFrequency: activityFrequency,
      weeklyDistribution: weeklyDistribution,
      hourlyDistribution: hourlyDistribution,
      mostActiveDay: mostActiveDay,
      mostActiveTime: mostActiveTime,
      consistencyScore: consistencyScore,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
    );
  }
  
  /// 기분 패턴 분석
  static MoodAnalysis _analyzeMoodPatterns(GlobalUser user) {
    final records = user.dailyRecords;
    final moodCounts = <String, int>{};
    final activityMoods = <String, List<String>>{};
    
    // 일기의 기분 수집
    for (final diary in records.diaryLogs) {
      moodCounts[diary.mood] = (moodCounts[diary.mood] ?? 0) + 1;
      activityMoods.putIfAbsent('일기', () => []).add(diary.mood);
    }
    
    // 모임의 기분 수집
    for (final meeting in records.meetingLogs) {
      moodCounts[meeting.mood] = (moodCounts[meeting.mood] ?? 0) + 1;
      activityMoods.putIfAbsent('모임', () => []).add(meeting.mood);
    }
    
    // 독서의 기분 수집 (있는 경우)
    for (final reading in records.readingLogs) {
      if (reading.mood != null) {
        moodCounts[reading.mood!] = (moodCounts[reading.mood!] ?? 0) + 1;
        activityMoods.putIfAbsent('독서', () => []).add(reading.mood!);
      }
    }
    
    // 기분 분포 계산
    final totalMoods = moodCounts.values.fold(0, (sum, count) => sum + count);
    final moodDistribution = <String, double>{};
    moodCounts.forEach((mood, count) {
      moodDistribution[mood] = totalMoods > 0 ? (count / totalMoods) * 100 : 0.0;
    });
    
    // 주요 기분 찾기
    String dominantMood = 'happy';
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMood = mood;
      }
    });
    
    // 활동별 주요 기분 매핑
    final activityMoodMap = <String, String>{};
    activityMoods.forEach((activity, moods) {
      if (moods.isNotEmpty) {
        final moodCount = <String, int>{};
        for (final mood in moods) {
          moodCount[mood] = (moodCount[mood] ?? 0) + 1;
        }
        
        String dominantActivityMood = moods.first;
        int maxActivityCount = 0;
        moodCount.forEach((mood, count) {
          if (count > maxActivityCount) {
            maxActivityCount = count;
            dominantActivityMood = mood;
          }
        });
        activityMoodMap[activity] = dominantActivityMood;
      }
    });
    
    // 기분 안정성 점수 계산
    final moodStability = _calculateMoodStability(moodDistribution);
    
    // 최근 기분 트렌드
    final recentTrends = _getRecentMoodTrends(records);
    
    return MoodAnalysis(
      moodDistribution: moodDistribution,
      dominantMood: dominantMood,
      moodStability: moodStability,
      activityMoodMap: activityMoodMap,
      recentTrends: recentTrends,
    );
  }
  
  /// 성과 분석
  static PerformanceMetrics _analyzePerformance(GlobalUser user) {
    final records = user.dailyRecords;
    
    // 목표 달성률
    final goalCompletionRate = records.todayCompletionRate * 100;
    
    // 스탯 성장률 계산 (임시로 랜덤 값 사용)
    final statGrowthRate = <String, double>{
      '체력': 15.5,
      '지식': 22.3,
      '기술': 18.7,
      '사회성': 25.1,
      '의지력': 20.4,
    };
    
    // 전체 진행도
    final overallProgress = user.level * 10.0 + (user.experience / 100);
    
    // 총 활동 수
    final totalActivities = records.exerciseLogs.length +
        records.readingLogs.length +
        records.diaryLogs.length +
        records.meetingLogs.length;
    
    // 평균 만족도 계산
    double totalSatisfaction = 0.0;
    int satisfactionCount = 0;
    
    for (final meeting in records.meetingLogs) {
      totalSatisfaction += meeting.satisfaction;
      satisfactionCount++;
    }
    
    for (final reading in records.readingLogs) {
      if (reading.rating != null) {
        totalSatisfaction += reading.rating!;
        satisfactionCount++;
      }
    }
    
    final averageSatisfaction = satisfactionCount > 0 
        ? totalSatisfaction / satisfactionCount 
        : 0.0;
    
    // 카테고리별 성과
    final categoryPerformance = <String, double>{
      '운동': _calculateCategoryScore(records.exerciseLogs.length, 30),
      '독서': _calculateCategoryScore(records.readingLogs.length, 20),
      '일기': _calculateCategoryScore(records.diaryLogs.length, 30),
      '모임': _calculateCategoryScore(records.meetingLogs.length, 10),
    };
    
    return PerformanceMetrics(
      goalCompletionRate: goalCompletionRate,
      statGrowthRate: statGrowthRate,
      overallProgress: overallProgress,
      totalActivities: totalActivities,
      averageSatisfaction: averageSatisfaction,
      categoryPerformance: categoryPerformance,
    );
  }
  
  /// 인사이트 생성
  static List<Insight> _generateInsights(
    GlobalUser user,
    ActivityPatterns patterns,
    MoodAnalysis mood,
    PerformanceMetrics metrics,
  ) {
    final insights = <Insight>[];
    
    // 강점 인사이트
    if (patterns.consistencyScore > 70) {
      insights.add(Insight(
        title: '꾸준한 활동 습관',
        description: '${patterns.currentStreak}일 연속으로 활동을 기록하고 있어요! 일관성 점수가 ${patterns.consistencyScore.toStringAsFixed(0)}%로 매우 우수합니다.',
        type: InsightType.strength,
        importance: 0.9,
        icon: Icons.trending_up,
      ));
    }
    
    // 기분 관련 인사이트
    if (mood.dominantMood == 'happy' || mood.dominantMood == 'very_happy') {
      insights.add(Insight(
        title: '긍정적인 마인드셋',
        description: '대부분의 활동에서 행복한 기분을 유지하고 있어요. 이는 목표 달성에 큰 도움이 됩니다.',
        type: InsightType.strength,
        importance: 0.8,
        icon: Icons.sentiment_very_satisfied,
      ));
    }
    
    // 활동 패턴 인사이트
    final mostActiveActivity = patterns.activityFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    insights.add(Insight(
      title: '${mostActiveActivity.key} 활동 선호',
      description: '${mostActiveActivity.key} 활동을 ${mostActiveActivity.value}회로 가장 많이 하셨네요. ${patterns.mostActiveTime}에 주로 활동하시는 패턴이 보입니다.',
      type: InsightType.trend,
      importance: 0.7,
      icon: Icons.insights,
    ));
    
    // 개선 기회 인사이트
    final leastActiveActivity = patterns.activityFrequency.entries
        .reduce((a, b) => a.value < b.value ? a : b);
    
    if (leastActiveActivity.value < 5) {
      insights.add(Insight(
        title: '${leastActiveActivity.key} 활동 강화 기회',
        description: '${leastActiveActivity.key} 활동이 상대적으로 적어요. 이 영역을 강화하면 더욱 균형잡힌 성장이 가능합니다.',
        type: InsightType.opportunity,
        importance: 0.6,
        icon: Icons.lightbulb,
      ));
    }
    
    // 성과 관련 인사이트
    if (metrics.goalCompletionRate > 80) {
      insights.add(Insight(
        title: '높은 목표 달성률',
        description: '목표 달성률이 ${metrics.goalCompletionRate.toStringAsFixed(0)}%로 매우 우수합니다! 계속 이 페이스를 유지해보세요.',
        type: InsightType.achievement,
        importance: 0.85,
        icon: Icons.emoji_events,
      ));
    }
    
    // 정렬 (중요도 순)
    insights.sort((a, b) => b.importance.compareTo(a.importance));
    
    return insights;
  }
  
  /// 추천사항 생성
  static List<Recommendation> _generateRecommendations(
    GlobalUser user,
    ActivityPatterns patterns,
    MoodAnalysis mood,
    PerformanceMetrics metrics,
  ) {
    final recommendations = <Recommendation>[];
    
    // 활동 균형 추천
    final leastActiveActivity = patterns.activityFrequency.entries
        .reduce((a, b) => a.value < b.value ? a : b);
    
    if (leastActiveActivity.value < AnalysisConstants.minimumActivityCount) {
      recommendations.add(Recommendation(
        title: '${leastActiveActivity.key} 활동 늘리기',
        description: '이번 주에 ${leastActiveActivity.key} 활동을 2회 이상 해보는 것은 어떨까요?',
        actionText: '목표 설정하기',
        type: RecommendationType.balance,
        priority: AnalysisConstants.priorityHigh,
        icon: Icons.balance,
      ));
    }
    
    // 연속 기록 도전
    if (patterns.currentStreak > 0 && patterns.currentStreak < AnalysisConstants.streakTargetDays) {
      recommendations.add(Recommendation(
        title: '${AnalysisConstants.streakTargetDays}일 연속 도전',
        description: '현재 ${patterns.currentStreak}일 연속 기록 중! ${AnalysisConstants.streakTargetDays}일 연속 달성에 도전해보세요.',
        actionText: '도전하기',
        type: RecommendationType.challenge,
        priority: AnalysisConstants.priorityCritical,
        icon: Icons.local_fire_department,
      ));
    }
    
    // 시간대 최적화 추천
    recommendations.add(Recommendation(
      title: '${patterns.mostActiveTime} 활동 강화',
      description: '${patterns.mostActiveTime}에 가장 활발하시네요. 이 시간대에 중요한 활동을 배치해보세요.',
      actionText: '일정 조정',
      type: RecommendationType.improvement,
      priority: AnalysisConstants.priorityMedium,
      icon: Icons.schedule,
    ));
    
    // 기분 개선 추천
    if (mood.moodStability < AnalysisConstants.moodStabilityThreshold) {
      recommendations.add(Recommendation(
        title: '기분 안정성 향상',
        description: '규칙적인 운동과 충분한 휴식으로 기분의 안정성을 높여보세요.',
        actionText: '운동 계획 세우기',
        type: RecommendationType.activity,
        priority: AnalysisConstants.priorityHigh,
        icon: Icons.self_improvement,
      ));
    }
    
    // 새로운 목표 추천
    if (metrics.goalCompletionRate > AnalysisConstants.highGoalCompletionRate) {
      recommendations.add(Recommendation(
        title: '더 높은 목표 설정',
        description: '현재 목표를 잘 달성하고 계세요! 조금 더 도전적인 목표를 설정해보는 건 어떨까요?',
        actionText: '새 목표 만들기',
        type: RecommendationType.goal,
        priority: AnalysisConstants.priorityMedium,
        icon: Icons.rocket_launch,
      ));
    }
    
    // 우선순위 순으로 정렬
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    
    return recommendations;
  }
  
  // === 헬퍼 메서드들 ===
  
  static String _getDayName(int weekday) {
    return AnalysisConstants.weekdayNames[weekday] ?? '월요일';
  }
  
  static double _calculateConsistencyScore(List<DateTime> dates) {
    if (dates.isEmpty) return 0.0;
    
    // 날짜별로 정렬
    dates.sort();
    
    // 최근 30일 기준으로 계산
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentDates = dates.where((date) => date.isAfter(thirtyDaysAgo)).toList();
    
    if (recentDates.isEmpty) return 0.0;
    
    // 30일 중 활동한 날 비율
    final uniqueDays = recentDates.map((date) => 
        DateTime(date.year, date.month, date.day)).toSet();
    
    return math.min((uniqueDays.length / 30) * 100, 100.0);
  }
  
  static Map<String, int> _calculateStreaks(List<DateTime> dates) {
    if (dates.isEmpty) return {'current': 0, 'longest': 0};
    
    // 날짜별로 정렬
    final uniqueDates = dates.map((date) => 
        DateTime(date.year, date.month, date.day)).toSet().toList();
    uniqueDates.sort();
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    
    for (int i = 1; i < uniqueDates.length; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
      
      if (diff == 1) {
        tempStreak++;
      } else {
        longestStreak = math.max(longestStreak, tempStreak);
        tempStreak = 1;
      }
    }
    
    longestStreak = math.max(longestStreak, tempStreak);
    
    // 현재 연속 일수 계산
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (uniqueDates.isNotEmpty) {
      final lastDate = uniqueDates.last;
      if (lastDate == todayDate || 
          lastDate == todayDate.subtract(const Duration(days: 1))) {
        currentStreak = tempStreak;
      }
    }
    
    return {'current': currentStreak, 'longest': longestStreak};
  }
  
  static double _calculateMoodStability(Map<String, double> distribution) {
    if (distribution.isEmpty) return 0.0;
    
    // 기분 분포의 표준편차를 기반으로 안정성 계산
    final mean = distribution.values.fold(0.0, (sum, val) => sum + val) / distribution.length;
    double variance = 0.0;
    
    for (final value in distribution.values) {
      variance += math.pow(value - mean, 2);
    }
    
    final standardDeviation = math.sqrt(variance / distribution.length);
    
    // 표준편차가 낮을수록 안정성이 높음 (0-100 스케일로 변환)
    return math.max(0, 100 - (standardDeviation * 2));
  }
  
  static List<MoodTrend> _getRecentMoodTrends(DailyRecordData records) {
    final trends = <MoodTrend>[];
    final allMoods = <DateTime, String>{};
    
    // 모든 기분 데이터 수집
    for (final diary in records.diaryLogs) {
      allMoods[diary.date] = diary.mood;
    }
    
    for (final meeting in records.meetingLogs) {
      allMoods[meeting.date] = meeting.mood;
    }
    
    // 최근 7일 트렌드
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      
      if (allMoods.containsKey(dateKey)) {
        trends.add(MoodTrend(
          date: dateKey,
          mood: allMoods[dateKey]!,
          score: _getMoodScore(allMoods[dateKey]!),
        ));
      }
    }
    
    return trends;
  }
  
  static double _getMoodScore(String mood) {
    switch (mood) {
      case 'very_happy': return 5.0;
      case 'happy': return 4.0;
      case 'good': return 3.5;
      case 'normal': return 3.0;
      case 'tired': return 2.0;
      case 'stressed': return 1.0;
      default: return 3.0;
    }
  }
  
  static double _calculateCategoryScore(int count, int target) {
    return math.min((count / target) * 100, 100.0);
  }
  
  /// 기본 분석 결과 생성 (오류 발생 시 사용)
  static AnalysisResult _createDefaultAnalysisResult(GlobalUser user, DateTime now) {
    return AnalysisResult(
      activityPatterns: ActivityPatterns(
        activityFrequency: {'운동': 0, '독서': 0, '일기': 0, '모임': 0},
        weeklyDistribution: {for (int i = 1; i <= 7; i++) i: 0.0},
        hourlyDistribution: {for (int i = 0; i < 24; i++) i: 0.0},
        mostActiveDay: '월요일',
        mostActiveTime: '오전',
        consistencyScore: 0.0,
        currentStreak: 0,
        longestStreak: 0,
      ),
      moodAnalysis: MoodAnalysis(
        moodDistribution: {'normal': 100.0},
        dominantMood: 'normal',
        moodStability: 50.0,
        activityMoodMap: {},
        recentTrends: [],
      ),
      performanceMetrics: PerformanceMetrics(
        goalCompletionRate: 0.0,
        statGrowthRate: {'체력': 0.0, '지식': 0.0, '기술': 0.0, '사회성': 0.0, '의지력': 0.0},
        overallProgress: user.level.toDouble(),
        totalActivities: 0,
        averageSatisfaction: 0.0,
        categoryPerformance: {'운동': 0.0, '독서': 0.0, '일기': 0.0, '모임': 0.0},
      ),
      insights: [
        Insight(
          title: '새로운 시작',
          description: '아직 충분한 데이터가 없지만, 지금부터 시작해보세요! 작은 활동부터 기록해나가면 멋진 성장 패턴을 만들 수 있어요.',
          type: InsightType.opportunity,
          importance: 0.8,
          icon: Icons.star,
        ),
      ],
      recommendations: [
        Recommendation(
          title: '첫 활동 시작하기',
          description: '오늘부터 하나씩 활동을 기록해보세요. 운동, 독서, 일기 중 어떤 것부터 시작할까요?',
          actionText: '활동 기록하기',
          type: RecommendationType.activity,
          priority: 5,
          icon: Icons.play_arrow,
        ),
      ],
      analyzedAt: now,
    );
  }
}