/// 분석 시스템 상수 정의
/// 하드코딩된 값들을 중앙 관리하여 유지보수성 향상
class AnalysisConstants {
  // === 기간 관련 상수 ===
  static const int analysisDataPeriodDays = 30; // 분석 기간 (일)
  static const int weekDays = 7; // 일주일
  static const int streakTargetDays = 7; // 연속 기록 목표 일수

  // === 임계값 및 기준치 ===
  static const int minimumActivityCount = 5; // 최소 활동 횟수
  static const double moodStabilityThreshold = 70.0; // 기분 안정성 기준 (%)
  static const double highGoalCompletionRate = 90.0; // 높은 목표 달성률 (%)
  static const double consistencyScoreMax = 100.0; // 일관성 점수 최대값

  // === 성과 지표 가중치 ===
  static const double activityWeightFactor = 0.3; // 활동 빈도 가중치
  static const double consistencyWeightFactor = 0.3; // 일관성 가중치
  static const double goalWeightFactor = 0.2; // 목표 달성 가중치
  static const double streakWeightFactor = 0.2; // 연속 기록 가중치

  // === 분석 진행 단계별 진행률 ===
  static const double progressDataValidation = 0.2; // 데이터 검증 (20%)
  static const double progressActivityAnalysis = 0.4; // 활동 패턴 분석 (40%)
  static const double progressMoodAnalysis = 0.6; // 기분 패턴 분석 (60%)
  static const double progressMetricsCalculation = 0.8; // 성과 지표 계산 (80%)
  static const double progressInsightGeneration = 0.95; // 인사이트 생성 (95%)
  static const double progressComplete = 1.0; // 완료 (100%)

  // === 우선순위 레벨 ===
  static const int priorityLow = 1;
  static const int priorityMedium = 3;
  static const int priorityHigh = 4;
  static const int priorityCritical = 5;

  // === 요일 이름 ===
  static const Map<int, String> weekdayNames = {
    1: '월요일',
    2: '화요일',
    3: '수요일',
    4: '목요일',
    5: '금요일',
    6: '토요일',
    7: '일요일',
  };

  // === 시간대 구분 ===
  static const Map<String, List<int>> timePeriods = {
    '새벽': [0, 1, 2, 3, 4, 5],
    '아침': [6, 7, 8, 9, 10, 11],
    '오후': [12, 13, 14, 15, 16, 17],
    '저녁': [18, 19, 20, 21, 22, 23],
  };

  // === 활동 타입 ===
  static const Map<String, String> activityTypes = {
    'exercise': '운동',
    'reading': '독서',
    'diary': '일기',
    'meeting': '모임',
  };

  // === 추천 메시지 템플릿 ===
  static const Map<String, String> recommendationTemplates = {
    'increase_activity': '이번 주에 {activity} 활동을 2회 이상 해보는 것은 어떨까요?',
    'streak_challenge': '현재 {days}일 연속 기록 중! 7일 연속 달성에 도전해보세요.',
    'optimize_time': '{time}에 가장 활발하시네요. 이 시간대에 중요한 활동을 배치해보세요.',
    'improve_mood': '규칙적인 운동과 충분한 휴식으로 기분의 안정성을 높여보세요.',
    'set_higher_goal': '현재 목표를 잘 달성하고 계세요! 조금 더 도전적인 목표를 설정해보는 건 어떨까요?',
  };

  // === 애니메이션 지속 시간 (밀리초) ===
  static const int animationDurationShort = 300;
  static const int animationDurationMedium = 500;
  static const int animationDurationLong = 800;
  static const int animationDelayBetweenSteps = 1200;

  // === 차트 설정 ===
  static const double chartBarWidth = 8.0;
  static const double chartBorderRadius = 4.0;
  static const double chartMaxY = 10.0;
  static const int chartGridLineInterval = 2;
}

/// 분석 타입 열거형
enum AnalysisType {
  pattern,
  mood,
  performance,
  insight,
}

/// 추천 타입 열거형 (이미 user_data_analyzer.dart에 정의되어 있으면 제거)
enum RecommendationType {
  activity,
  improvement,
  goal,
  balance,
  challenge,
}
