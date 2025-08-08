/// 계획 시스템 상수 정의
/// 하드코딩된 값들을 중앙 관리하여 유지보수성 향상
class PlanningConstants {
  // === 계획 기간 ===
  static const int shortTermDays = 7; // 단기 계획 기간
  static const int midTermDays = 30; // 중기 계획 기간
  static const int longTermDays = 90; // 장기 계획 기간
  
  // === 목표 설정 기준 ===
  static const int dailyGoalCount = 3; // 일일 목표 개수
  static const int weeklyGoalCount = 5; // 주간 목표 개수
  static const int monthlyGoalCount = 3; // 월간 목표 개수
  
  // === SMART 목표 기준 ===
  static const double specificityThreshold = 0.8; // 구체성 기준
  static const double measurabilityThreshold = 0.7; // 측정가능성 기준
  static const double achievabilityThreshold = 0.75; // 달성가능성 기준
  static const double relevanceThreshold = 0.8; // 관련성 기준
  
  // === 우선순위 레벨 ===
  static const int priorityUrgent = 5;
  static const int priorityHigh = 4;
  static const int priorityMedium = 3;
  static const int priorityLow = 2;
  static const int priorityOptional = 1;
  
  // === 활동 추천 기준 ===
  static const int minActivityFrequency = 3; // 최소 활동 빈도
  static const int recommendedActivityTime = 30; // 권장 활동 시간 (분)
  static const double improvementTargetRate = 0.1; // 개선 목표율 (10%)
  
  // === 진행 상태 메시지 ===
  static final Map<double, String> progressMessages = {
    0.2: '사용자 데이터 분석 중...',
    0.4: '목표 설정 중...',
    0.6: '일정 계획 중...',
    0.8: '개선 방안 도출 중...',
    0.95: '인사이트 생성 중...',
    1.0: '계획 완성!',
  };
  
  // === 목표 카테고리 ===
  static const Map<String, String> goalCategories = {
    'health': '건강',
    'growth': '성장',
    'relationship': '관계',
    'productivity': '생산성',
    'hobby': '취미',
    'learning': '학습',
  };
  
  // === 추천 템플릿 ===
  static const Map<String, String> planTemplates = {
    'daily_routine': '매일 {time}에 {activity}하기',
    'weekly_challenge': '이번 주 {count}회 {activity} 도전',
    'improvement_goal': '{metric}을 {target}% 향상시키기',
    'habit_formation': '{activity}를 습관으로 만들기',
    'skill_development': '{skill} 능력 개발하기',
  };
  
  // === 애니메이션 지속 시간 (밀리초) ===
  static const int animationDurationShort = 300;
  static const int animationDurationMedium = 500;
  static const int animationDurationLong = 800;
  static const int animationDelayBetweenSteps = 1200;
}

/// 목표 타입 열거형
enum GoalType {
  daily,
  weekly,
  monthly,
  custom,
}

/// 목표 상태 열거형
enum GoalStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}