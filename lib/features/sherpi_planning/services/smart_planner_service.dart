import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../shared/models/global_user_model.dart';
import '../../sherpi_analysis/services/user_data_analyzer.dart';

/// 계획 결과 모델
class PlanningResult {
  final PersonalizedGoals personalizedGoals;
  final WeeklySchedule weeklySchedule;
  final ImprovementPlan improvementPlan;
  final List<SmartGoal> smartGoals;
  final PlanningInsights insights;
  final DateTime createdAt;

  const PlanningResult({
    required this.personalizedGoals,
    required this.weeklySchedule,
    required this.improvementPlan,
    required this.smartGoals,
    required this.insights,
    required this.createdAt,
  });
}

/// 개인화된 목표
class PersonalizedGoals {
  final List<GoalCategory> categories;
  final Map<String, List<SpecificGoal>> goalsByCategory;
  final int totalGoals;
  final String focusArea;
  final double difficultyLevel;

  const PersonalizedGoals({
    required this.categories,
    required this.goalsByCategory,
    required this.totalGoals,
    required this.focusArea,
    required this.difficultyLevel,
  });
}

/// 목표 카테고리
class GoalCategory {
  final String name;
  final String icon;
  final Color color;
  final double priority;
  final int goalCount;

  const GoalCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.priority,
    required this.goalCount,
  });
}

/// 구체적인 목표
class SpecificGoal {
  final String id;
  final String title;
  final String description;
  final String category;
  final int targetValue;
  final String unit;
  final GoalDifficulty difficulty;
  final int estimatedDays;
  final List<String> milestones;
  final String motivation;

  const SpecificGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
    required this.unit,
    required this.difficulty,
    required this.estimatedDays,
    required this.milestones,
    required this.motivation,
  });
}

enum GoalDifficulty {
  easy,     // 쉬움
  moderate, // 보통
  hard,     // 어려움
  expert,   // 전문가
}

/// 주간 일정
class WeeklySchedule {
  final Map<int, List<ScheduledActivity>> dailySchedule;
  final List<OptimalTimeSlot> optimalTimes;
  final int totalActivities;
  final double balanceScore;

  const WeeklySchedule({
    required this.dailySchedule,
    required this.optimalTimes,
    required this.totalActivities,
    required this.balanceScore,
  });
}

/// 예정된 활동
class ScheduledActivity {
  final String title;
  final String category;
  final TimeRange timeRange;
  final int duration; // minutes
  final String description;
  final GoalDifficulty intensity;
  final bool isFlexible;

  const ScheduledActivity({
    required this.title,
    required this.category,
    required this.timeRange,
    required this.duration,
    required this.description,
    required this.intensity,
    required this.isFlexible,
  });
}

/// 시간 범위
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({
    required this.start,
    required this.end,
  });
}

/// 최적 시간대
class OptimalTimeSlot {
  final String activity;
  final TimeRange timeRange;
  final double confidenceScore;
  final String reason;

  const OptimalTimeSlot({
    required this.activity,
    required this.timeRange,
    required this.confidenceScore,
    required this.reason,
  });
}

/// 개선 계획
class ImprovementPlan {
  final List<ImprovementArea> areas;
  final Map<String, List<ActionStep>> actionSteps;
  final int planDuration; // days
  final List<Milestone> milestones;

  const ImprovementPlan({
    required this.areas,
    required this.actionSteps,
    required this.planDuration,
    required this.milestones,
  });
}

/// 개선 영역
class ImprovementArea {
  final String name;
  final double currentScore;
  final double targetScore;
  final String description;
  final IconData icon;
  final Color color;
  final int priority;

  const ImprovementArea({
    required this.name,
    required this.currentScore,
    required this.targetScore,
    required this.description,
    required this.icon,
    required this.color,
    required this.priority,
  });
}

/// 액션 스텝
class ActionStep {
  final String title;
  final String description;
  final int weekNumber;
  final bool isCompleted;
  final DateTime? dueDate;
  final String category;

  const ActionStep({
    required this.title,
    required this.description,
    required this.weekNumber,
    required this.isCompleted,
    this.dueDate,
    required this.category,
  });
}

/// 마일스톤
class Milestone {
  final String title;
  final String description;
  final DateTime targetDate;
  final List<String> requirements;
  final double progress;

  const Milestone({
    required this.title,
    required this.description,
    required this.targetDate,
    required this.requirements,
    required this.progress,
  });
}

/// SMART 목표
class SmartGoal {
  final String title;
  final String specific;      // S: Specific
  final String measurable;    // M: Measurable
  final String achievable;    // A: Achievable
  final String relevant;      // R: Relevant
  final String timeBound;     // T: Time-bound
  final String category;
  final GoalDifficulty difficulty;

  const SmartGoal({
    required this.title,
    required this.specific,
    required this.measurable,
    required this.achievable,
    required this.relevant,
    required this.timeBound,
    required this.category,
    required this.difficulty,
  });
}

/// 계획 인사이트
class PlanningInsights {
  final String primaryFocus;
  final List<String> strengths;
  final List<String> challenges;
  final List<PlanningTip> tips;
  final double successProbability;

  const PlanningInsights({
    required this.primaryFocus,
    required this.strengths,
    required this.challenges,
    required this.tips,
    required this.successProbability,
  });
}

/// 계획 팁
class PlanningTip {
  final String title;
  final String description;
  final IconData icon;
  final TipType type;

  const PlanningTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
  });
}

enum TipType {
  motivation,  // 동기부여
  strategy,    // 전략
  habit,       // 습관
  balance,     // 균형
}

/// 스마트 플래너 서비스
class SmartPlannerService {
  
  /// 개인화된 계획 생성
  static PlanningResult createPersonalizedPlan(
    GlobalUser user,
    AnalysisResult? analysisResult,
  ) {
    final now = DateTime.now();
    
    // 각 구성 요소 생성
    final personalizedGoals = _generatePersonalizedGoals(user, analysisResult);
    final weeklySchedule = _createWeeklySchedule(user, analysisResult);
    final improvementPlan = _createImprovementPlan(user, analysisResult);
    final smartGoals = _generateSmartGoals(user, analysisResult);
    final insights = _generatePlanningInsights(user, analysisResult);
    
    return PlanningResult(
      personalizedGoals: personalizedGoals,
      weeklySchedule: weeklySchedule,
      improvementPlan: improvementPlan,
      smartGoals: smartGoals,
      insights: insights,
      createdAt: now,
    );
  }
  
  /// 개인화된 목표 생성
  static PersonalizedGoals _generatePersonalizedGoals(
    GlobalUser user,
    AnalysisResult? analysis,
  ) {
    // 목표 카테고리 정의
    final categories = [
      GoalCategory(
        name: '운동',
        icon: '💪',
        color: Colors.blue,
        priority: _calculateCategoryPriority('운동', user, analysis),
        goalCount: _calculateGoalCount('운동', user, analysis),
      ),
      GoalCategory(
        name: '독서',
        icon: '📚',
        color: Colors.green,
        priority: _calculateCategoryPriority('독서', user, analysis),
        goalCount: _calculateGoalCount('독서', user, analysis),
      ),
      GoalCategory(
        name: '일기',
        icon: '📝',
        color: Colors.purple,
        priority: _calculateCategoryPriority('일기', user, analysis),
        goalCount: _calculateGoalCount('일기', user, analysis),
      ),
      GoalCategory(
        name: '사회활동',
        icon: '🤝',
        color: Colors.orange,
        priority: _calculateCategoryPriority('사회활동', user, analysis),
        goalCount: _calculateGoalCount('사회활동', user, analysis),
      ),
    ];
    
    // 카테고리별 구체적인 목표 생성
    final goalsByCategory = <String, List<SpecificGoal>>{};
    
    for (final category in categories) {
      goalsByCategory[category.name] = _generateCategoryGoals(
        category.name,
        category.goalCount,
        user,
        analysis,
      );
    }
    
    // 전체 목표 수 계산
    final totalGoals = goalsByCategory.values
        .fold(0, (sum, goals) => sum + goals.length);
    
    // 주요 집중 영역 결정
    final focusArea = categories
        .reduce((a, b) => a.priority > b.priority ? a : b)
        .name;
    
    // 난이도 레벨 계산
    final difficultyLevel = _calculateDifficultyLevel(user, analysis);
    
    return PersonalizedGoals(
      categories: categories,
      goalsByCategory: goalsByCategory,
      totalGoals: totalGoals,
      focusArea: focusArea,
      difficultyLevel: difficultyLevel,
    );
  }
  
  /// 주간 일정 생성
  static WeeklySchedule _createWeeklySchedule(
    GlobalUser user,
    AnalysisResult? analysis,
  ) {
    // 사용자의 활동 패턴 분석
    final patterns = analysis?.activityPatterns;
    
    // 요일별 일정 생성
    final dailySchedule = <int, List<ScheduledActivity>>{};
    
    for (int day = 1; day <= 7; day++) {
      dailySchedule[day] = _generateDailyActivities(day, user, patterns);
    }
    
    // 최적 시간대 추천
    final optimalTimes = _generateOptimalTimeSlots(user, patterns);
    
    // 총 활동 수 계산
    final totalActivities = dailySchedule.values
        .fold(0, (sum, activities) => sum + activities.length);
    
    // 균형 점수 계산
    final balanceScore = _calculateScheduleBalance(dailySchedule);
    
    return WeeklySchedule(
      dailySchedule: dailySchedule,
      optimalTimes: optimalTimes,
      totalActivities: totalActivities,
      balanceScore: balanceScore,
    );
  }
  
  /// 개선 계획 생성
  static ImprovementPlan _createImprovementPlan(
    GlobalUser user,
    AnalysisResult? analysis,
  ) {
    // 개선이 필요한 영역 식별
    final areas = _identifyImprovementAreas(user, analysis);
    
    // 영역별 액션 스텝 생성
    final actionSteps = <String, List<ActionStep>>{};
    
    for (final area in areas) {
      actionSteps[area.name] = _generateActionSteps(area, user);
    }
    
    // 계획 기간 결정
    final planDuration = _calculatePlanDuration(areas);
    
    // 마일스톤 생성
    final milestones = _generateMilestones(areas, planDuration);
    
    return ImprovementPlan(
      areas: areas,
      actionSteps: actionSteps,
      planDuration: planDuration,
      milestones: milestones,
    );
  }
  
  /// SMART 목표 생성
  static List<SmartGoal> _generateSmartGoals(
    GlobalUser user,
    AnalysisResult? analysis,
  ) {
    final smartGoals = <SmartGoal>[];
    
    // 운동 SMART 목표
    smartGoals.add(SmartGoal(
      title: '주 3회 운동하기',
      specific: '헬스장에서 근력 운동과 유산소 운동을 병행',
      measurable: '주 3회, 회당 1시간',
      achievable: '현재 주 1회 → 점진적으로 주 3회까지 증가',
      relevant: '체력 향상과 건강한 라이프스타일을 위해 필요',
      timeBound: '4주 내에 달성',
      category: '운동',
      difficulty: GoalDifficulty.moderate,
    ));
    
    // 독서 SMART 목표
    smartGoals.add(SmartGoal(
      title: '월 2권 독서하기',
      specific: '자기계발서와 소설을 번갈아가며 읽기',
      measurable: '월 2권, 총 24권/년',
      achievable: '현재 독서 패턴을 고려하여 실현 가능한 목표',
      relevant: '지식 확장과 사고력 향상을 위해 중요',
      timeBound: '매월 마지막 주까지',
      category: '독서',
      difficulty: GoalDifficulty.easy,
    ));
    
    // 사회활동 SMART 목표
    if (user.dailyRecords.meetingLogs.length < 5) {
      smartGoals.add(SmartGoal(
        title: '월 2회 새로운 모임 참여',
        specific: '관심 분야의 스터디나 취미 모임에 참여',
        measurable: '월 2회 이상, 다양한 카테고리',
        achievable: '온라인과 오프라인 모임을 활용하여 실현 가능',
        relevant: '네트워킹과 새로운 경험을 통한 성장',
        timeBound: '매월 둘째 주와 넷째 주',
        category: '사회활동',
        difficulty: GoalDifficulty.moderate,
      ));
    }
    
    return smartGoals;
  }
  
  /// 계획 인사이트 생성
  static PlanningInsights _generatePlanningInsights(
    GlobalUser user,
    AnalysisResult? analysis,
  ) {
    // 주요 집중 영역 결정
    final primaryFocus = _determinePrimaryFocus(user, analysis);
    
    // 강점 분석
    final strengths = _identifyStrengths(user, analysis);
    
    // 도전 과제 식별
    final challenges = _identifyChallenges(user, analysis);
    
    // 실용적인 팁 생성
    final tips = _generatePlanningTips(user, analysis);
    
    // 성공 확률 계산
    final successProbability = _calculateSuccessProbability(user, analysis);
    
    return PlanningInsights(
      primaryFocus: primaryFocus,
      strengths: strengths,
      challenges: challenges,
      tips: tips,
      successProbability: successProbability,
    );
  }
  
  // === 헬퍼 메서드들 ===
  
  static double _calculateCategoryPriority(
    String category,
    GlobalUser user,
    AnalysisResult? analysis,
  ) {
    if (analysis == null) return 0.5;
    
    final frequency = analysis.activityPatterns.activityFrequency[category] ?? 0;
    final performance = analysis.performanceMetrics.categoryPerformance[category] ?? 50.0;
    
    // 빈도가 낮고 성과가 낮으면 우선순위가 높음
    return math.max(0.1, 1.0 - (frequency / 30 * 0.6 + performance / 100 * 0.4));
  }
  
  static int _calculateGoalCount(
    String category,
    GlobalUser user,
    AnalysisResult? analysis,
  ) {
    final priority = _calculateCategoryPriority(category, user, analysis);
    
    if (priority > 0.8) return 3;
    if (priority > 0.6) return 2;
    return 1;
  }
  
  static List<SpecificGoal> _generateCategoryGoals(
    String category,
    int count,
    GlobalUser user,
    AnalysisResult? analysis,
  ) {
    final goals = <SpecificGoal>[];
    
    switch (category) {
      case '운동':
        goals.addAll([
          SpecificGoal(
            id: 'exercise_1',
            title: '주 3회 운동하기',
            description: '근력 운동과 유산소 운동을 병행하여 체력 향상',
            category: category,
            targetValue: 3,
            unit: '회/주',
            difficulty: GoalDifficulty.moderate,
            estimatedDays: 28,
            milestones: ['1주차: 주 1회', '2주차: 주 2회', '3주차: 주 3회 달성'],
            motivation: '건강한 몸과 마음을 위해',
          ),
          if (count > 1) SpecificGoal(
            id: 'exercise_2',
            title: '하루 8000걸음 걷기',
            description: '일상 속에서 더 많이 움직이기',
            category: category,
            targetValue: 8000,
            unit: '걸음/일',
            difficulty: GoalDifficulty.easy,
            estimatedDays: 21,
            milestones: ['1주차: 6000걸음', '2주차: 7000걸음', '3주차: 8000걸음'],
            motivation: '활력 넘치는 하루를 위해',
          ),
        ]);
        break;
        
      case '독서':
        goals.addAll([
          SpecificGoal(
            id: 'reading_1',
            title: '월 2권 독서하기',
            description: '다양한 장르의 책을 통해 지식과 상상력 확장',
            category: category,
            targetValue: 2,
            unit: '권/월',
            difficulty: GoalDifficulty.easy,
            estimatedDays: 30,
            milestones: ['1주차: 책 선정', '2주차: 1권 완독', '4주차: 2권 완독'],
            motivation: '지식 확장과 사고력 향상을 위해',
          ),
          if (count > 1) SpecificGoal(
            id: 'reading_2',
            title: '독서 감상문 작성하기',
            description: '읽은 책에 대한 생각과 느낌을 기록',
            category: category,
            targetValue: 1,
            unit: '편/책',
            difficulty: GoalDifficulty.moderate,
            estimatedDays: 30,
            milestones: ['책 완독 후 즉시 작성', '핵심 내용 정리', '개인적 감상 추가'],
            motivation: '깊이 있는 사고와 표현력 향상을 위해',
          ),
        ]);
        break;
        
      case '일기':
        goals.addAll([
          SpecificGoal(
            id: 'diary_1',
            title: '주 5회 일기 쓰기',
            description: '하루의 경험과 감정을 솔직하게 기록',
            category: category,
            targetValue: 5,
            unit: '회/주',
            difficulty: GoalDifficulty.moderate,
            estimatedDays: 21,
            milestones: ['1주차: 3회', '2주차: 4회', '3주차: 5회 달성'],
            motivation: '자기 성찰과 감정 정리를 위해',
          ),
        ]);
        break;
        
      case '사회활동':
        goals.addAll([
          SpecificGoal(
            id: 'social_1',
            title: '월 2회 새로운 모임 참여',
            description: '관심 분야의 스터디나 취미 모임에 참여',
            category: category,
            targetValue: 2,
            unit: '회/월',
            difficulty: GoalDifficulty.moderate,
            estimatedDays: 30,
            milestones: ['1주차: 모임 찾기', '2주차: 첫 참여', '4주차: 두 번째 참여'],
            motivation: '새로운 인연과 경험을 위해',
          ),
        ]);
        break;
    }
    
    return goals.take(count).toList();
  }
  
  static double _calculateDifficultyLevel(GlobalUser user, AnalysisResult? analysis) {
    // 사용자의 현재 성과와 경험을 기반으로 난이도 계산
    final performance = analysis?.performanceMetrics.goalCompletionRate ?? 50.0;
    final level = user.level;
    
    // 레벨과 성과를 종합하여 0.3-0.8 범위의 난이도 결정
    return 0.3 + (math.min(level, 20) / 20 * 0.3) + (performance / 100 * 0.2);
  }
  
  static List<ScheduledActivity> _generateDailyActivities(
    int weekday,
    GlobalUser user,
    ActivityPatterns? patterns,
  ) {
    final activities = <ScheduledActivity>[];
    
    // 요일별 기본 활동 스케줄
    switch (weekday) {
      case 1: // 월요일
        activities.addAll([
          ScheduledActivity(
            title: '주간 계획 수립',
            category: '계획',
            timeRange: TimeRange(
              start: const TimeOfDay(hour: 7, minute: 0),
              end: const TimeOfDay(hour: 7, minute: 30),
            ),
            duration: 30,
            description: '이번 주의 목표와 일정을 정리',
            intensity: GoalDifficulty.easy,
            isFlexible: true,
          ),
          ScheduledActivity(
            title: '운동',
            category: '운동',
            timeRange: TimeRange(
              start: const TimeOfDay(hour: 19, minute: 0),
              end: const TimeOfDay(hour: 20, minute: 0),
            ),
            duration: 60,
            description: '헬스장에서 근력 운동',
            intensity: GoalDifficulty.moderate,
            isFlexible: false,
          ),
        ]);
        break;
        
      case 3: // 수요일
        activities.addAll([
          ScheduledActivity(
            title: '독서',
            category: '독서',
            timeRange: TimeRange(
              start: const TimeOfDay(hour: 21, minute: 0),
              end: const TimeOfDay(hour: 22, minute: 0),
            ),
            duration: 60,
            description: '선택한 책 읽기',
            intensity: GoalDifficulty.easy,
            isFlexible: true,
          ),
        ]);
        break;
        
      case 5: // 금요일
        activities.addAll([
          ScheduledActivity(
            title: '운동',
            category: '운동',
            timeRange: TimeRange(
              start: const TimeOfDay(hour: 18, minute: 30),
              end: const TimeOfDay(hour: 19, minute: 30),
            ),
            duration: 60,
            description: '유산소 운동과 스트레칭',
            intensity: GoalDifficulty.moderate,
            isFlexible: false,
          ),
          ScheduledActivity(
            title: '일기 쓰기',
            category: '일기',
            timeRange: TimeRange(
              start: const TimeOfDay(hour: 22, minute: 0),
              end: const TimeOfDay(hour: 22, minute: 30),
            ),
            duration: 30,
            description: '오늘 하루의 경험과 감정 기록',
            intensity: GoalDifficulty.easy,
            isFlexible: true,
          ),
        ]);
        break;
        
      case 6: // 토요일
        activities.addAll([
          ScheduledActivity(
            title: '새로운 모임 참여',
            category: '사회활동',
            timeRange: TimeRange(
              start: const TimeOfDay(hour: 14, minute: 0),
              end: const TimeOfDay(hour: 17, minute: 0),
            ),
            duration: 180,
            description: '관심 분야 모임이나 스터디 참여',
            intensity: GoalDifficulty.moderate,
            isFlexible: false,
          ),
        ]);
        break;
        
      case 7: // 일요일
        activities.addAll([
          ScheduledActivity(
            title: '주간 회고',
            category: '계획',
            timeRange: TimeRange(
              start: const TimeOfDay(hour: 20, minute: 0),
              end: const TimeOfDay(hour: 20, minute: 30),
            ),
            duration: 30,
            description: '이번 주 성과를 돌아보고 다음 주 준비',
            intensity: GoalDifficulty.easy,
            isFlexible: true,
          ),
        ]);
        break;
    }
    
    return activities;
  }
  
  static List<OptimalTimeSlot> _generateOptimalTimeSlots(
    GlobalUser user,
    ActivityPatterns? patterns,
  ) {
    final timeSlots = <OptimalTimeSlot>[];
    
    // 기본 최적 시간대 (분석 결과가 없는 경우)
    timeSlots.addAll([
      OptimalTimeSlot(
        activity: '운동',
        timeRange: TimeRange(
          start: const TimeOfDay(hour: 18, minute: 0),
          end: const TimeOfDay(hour: 20, minute: 0),
        ),
        confidenceScore: 0.85,
        reason: '대부분의 사람들이 저녁 시간에 운동할 때 집중력이 높습니다',
      ),
      OptimalTimeSlot(
        activity: '독서',
        timeRange: TimeRange(
          start: const TimeOfDay(hour: 21, minute: 0),
          end: const TimeOfDay(hour: 23, minute: 0),
        ),
        confidenceScore: 0.8,
        reason: '하루를 마무리하며 조용히 독서하기 좋은 시간입니다',
      ),
      OptimalTimeSlot(
        activity: '일기',
        timeRange: TimeRange(
          start: const TimeOfDay(hour: 22, minute: 0),
          end: const TimeOfDay(hour: 23, minute: 0),
        ),
        confidenceScore: 0.9,
        reason: '하루의 경험을 정리하기에 가장 적절한 시간입니다',
      ),
    ]);
    
    return timeSlots;
  }
  
  static double _calculateScheduleBalance(Map<int, List<ScheduledActivity>> schedule) {
    // 요일별 활동 분포의 균형을 계산
    final dailyCounts = schedule.values.map((activities) => activities.length).toList();
    final mean = dailyCounts.fold(0, (sum, count) => sum + count) / dailyCounts.length;
    final variance = dailyCounts.fold(0.0, (sum, count) => sum + math.pow(count - mean, 2)) / dailyCounts.length;
    
    // 분산이 낮을수록 균형이 좋음 (0-100 스케일로 변환)
    return math.max(0, 100 - (variance * 20));
  }
  
  static List<ImprovementArea> _identifyImprovementAreas(
    GlobalUser user,
    AnalysisResult? analysis,
  ) {
    final areas = <ImprovementArea>[];
    
    // 스탯 기반 개선 영역 식별
    final stats = user.stats;
    
    if (stats.stamina < 70) {
      areas.add(ImprovementArea(
        name: '체력',
        currentScore: stats.stamina,
        targetScore: 85.0,
        description: '규칙적인 운동과 충분한 휴식으로 체력을 향상시키세요',
        icon: Icons.fitness_center,
        color: Colors.blue,
        priority: 1,
      ));
    }
    
    if (stats.knowledge < 70) {
      areas.add(ImprovementArea(
        name: '지식',
        currentScore: stats.knowledge,
        targetScore: 85.0,
        description: '꾸준한 학습과 독서로 지식을 확장하세요',
        icon: Icons.school,
        color: Colors.green,
        priority: 2,
      ));
    }
    
    if (stats.sociality < 70) {
      areas.add(ImprovementArea(
        name: '사회성',
        currentScore: stats.sociality,
        targetScore: 85.0,
        description: '다양한 사람들과의 만남을 통해 사회성을 기르세요',
        icon: Icons.people,
        color: Colors.orange,
        priority: 3,
      ));
    }
    
    return areas;
  }
  
  static List<ActionStep> _generateActionSteps(ImprovementArea area, GlobalUser user) {
    final steps = <ActionStep>[];
    
    switch (area.name) {
      case '체력':
        steps.addAll([
          ActionStep(
            title: '운동 계획 수립',
            description: '주 3회 운동 스케줄을 구체적으로 계획합니다',
            weekNumber: 1,
            isCompleted: false,
            dueDate: DateTime.now().add(const Duration(days: 7)),
            category: '준비',
          ),
          ActionStep(
            title: '운동 습관 형성',
            description: '계획한 운동을 꾸준히 실행합니다',
            weekNumber: 2,
            isCompleted: false,
            dueDate: DateTime.now().add(const Duration(days: 14)),
            category: '실행',
          ),
          ActionStep(
            title: '진전 상황 점검',
            description: '체력 향상 정도를 측정하고 계획을 조정합니다',
            weekNumber: 4,
            isCompleted: false,
            dueDate: DateTime.now().add(const Duration(days: 28)),
            category: '평가',
          ),
        ]);
        break;
        
      case '지식':
        steps.addAll([
          ActionStep(
            title: '학습 목표 설정',
            description: '관심 분야의 구체적인 학습 목표를 설정합니다',
            weekNumber: 1,
            isCompleted: false,
            category: '준비',
          ),
          ActionStep(
            title: '독서 계획 실행',
            description: '월 2권 독서 목표를 달성합니다',
            weekNumber: 2,
            isCompleted: false,
            category: '실행',
          ),
        ]);
        break;
        
      case '사회성':
        steps.addAll([
          ActionStep(
            title: '모임 찾기',
            description: '관심 있는 모임이나 커뮤니티를 찾습니다',
            weekNumber: 1,
            isCompleted: false,
            category: '준비',
          ),
          ActionStep(
            title: '적극적인 참여',
            description: '모임에 적극적으로 참여하고 새로운 인연을 만듭니다',
            weekNumber: 2,
            isCompleted: false,
            category: '실행',
          ),
        ]);
        break;
    }
    
    return steps;
  }
  
  static int _calculatePlanDuration(List<ImprovementArea> areas) {
    // 개선 영역의 수와 중요도에 따라 계획 기간 결정
    return math.max(30, areas.length * 14); // 최소 30일, 영역당 2주 추가
  }
  
  static List<Milestone> _generateMilestones(List<ImprovementArea> areas, int duration) {
    final milestones = <Milestone>[];
    final now = DateTime.now();
    
    // 전체 기간을 4분할하여 마일스톤 설정
    for (int i = 1; i <= 4; i++) {
      milestones.add(Milestone(
        title: '${i}단계 목표 달성',
        description: '설정한 목표의 ${i * 25}%를 달성하세요',
        targetDate: now.add(Duration(days: (duration * i ~/ 4))),
        requirements: areas.map((area) => '${area.name} 개선').toList(),
        progress: 0.0,
      ));
    }
    
    return milestones;
  }
  
  static String _determinePrimaryFocus(GlobalUser user, AnalysisResult? analysis) {
    if (analysis != null) {
      final patterns = analysis.activityPatterns;
      final leastActive = patterns.activityFrequency.entries
          .reduce((a, b) => a.value < b.value ? a : b);
      return leastActive.key;
    }
    
    // 기본값
    return '운동';
  }
  
  static List<String> _identifyStrengths(GlobalUser user, AnalysisResult? analysis) {
    final strengths = <String>[];
    
    if (user.level > 10) {
      strengths.add('꾸준한 성장 마인드셋을 가지고 계시네요');
    }
    
    if (analysis != null && analysis.activityPatterns.currentStreak > 3) {
      strengths.add('${analysis.activityPatterns.currentStreak}일 연속 활동 중으로 훌륭한 consistency를 보이고 있습니다');
    }
    
    if (analysis != null && analysis.performanceMetrics.goalCompletionRate > 70) {
      strengths.add('목표 달성률이 ${analysis.performanceMetrics.goalCompletionRate.toInt()}%로 매우 우수합니다');
    }
    
    return strengths.isNotEmpty ? strengths : ['새로운 시작을 위한 의지가 돋보입니다'];
  }
  
  static List<String> _identifyChallenges(GlobalUser user, AnalysisResult? analysis) {
    final challenges = <String>[];
    
    if (analysis != null) {
      final patterns = analysis.activityPatterns;
      if (patterns.consistencyScore < 60) {
        challenges.add('꾸준함을 유지하는 것이 가장 큰 도전 과제입니다');
      }
      
      final leastActive = patterns.activityFrequency.entries
          .reduce((a, b) => a.value < b.value ? a : b);
      if (leastActive.value < 3) {
        challenges.add('${leastActive.key} 활동을 더 자주 하는 것이 필요합니다');
      }
    }
    
    return challenges.isNotEmpty ? challenges : ['새로운 습관을 형성하는 것이 주요 과제입니다'];
  }
  
  static List<PlanningTip> _generatePlanningTips(GlobalUser user, AnalysisResult? analysis) {
    return [
      PlanningTip(
        title: '작은 습관부터 시작하세요',
        description: '큰 목표도 작은 습관의 누적입니다. 하루 15분부터 시작해보세요.',
        icon: Icons.psychology,
        type: TipType.habit,
      ),
      PlanningTip(
        title: '목표를 구체적으로 설정하세요',
        description: 'SMART 원칙을 따라 측정 가능하고 달성 가능한 목표를 설정하세요.',
        icon: Icons.track_changes,
        type: TipType.strategy,
      ),
      PlanningTip(
        title: '균형 잡힌 계획을 세우세요',
        description: '한 영역에만 집중하지 말고 다양한 활동을 골고루 포함시키세요.',
        icon: Icons.balance,
        type: TipType.balance,
      ),
      PlanningTip(
        title: '진전 상황을 정기적으로 점검하세요',
        description: '주간 단위로 목표 달성 상황을 점검하고 필요시 계획을 조정하세요.',
        icon: Icons.track_changes,
        type: TipType.strategy,
      ),
    ];
  }
  
  static double _calculateSuccessProbability(GlobalUser user, AnalysisResult? analysis) {
    double probability = 0.5; // 기본 확률 50%
    
    // 레벨이 높을수록 성공 확률 증가
    probability += math.min(user.level / 30, 0.2);
    
    // 분석 결과가 있으면 과거 성과 반영
    if (analysis != null) {
      final completionRate = analysis.performanceMetrics.goalCompletionRate;
      probability += (completionRate / 100) * 0.3;
      
      final consistency = analysis.activityPatterns.consistencyScore;
      probability += (consistency / 100) * 0.2;
    }
    
    return math.min(probability, 0.95); // 최대 95%
  }
}