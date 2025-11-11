/// SharedPreferences 저장 키 상수
///
/// 중앙 집중식 저장 키 관리 (Magic String 제거)
class StorageKeys {
  // 방어적 프로그래밍: 생성자 private으로 설정 (인스턴스 생성 방지)
  StorageKeys._();

  // ==================== 목표 시스템 ====================
  /// 현재 목표 리스트
  static const String goalsList = 'goals_list';

  /// 이전 목표 리스트 (완료된 목표들)
  static const String previousGoalsList = 'previous_goals_list';

  /// 대표 목표 ID
  static const String representativeGoalId = 'representative_goal_id';

  // ==================== 루틴 시스템 ====================
  /// 루틴 리스트
  static const String routinesList = 'routines_list';

  /// 이전 루틴 리스트
  static const String previousRoutinesList = 'previous_routines_list';

  // ==================== 퀘스트 시스템 ====================
  /// 저장된 퀘스트 (v2)
  static const String savedQuestsV2 = 'saved_quests_v2';

  /// 프리미엄 퀘스트 활성화 여부 (v2)
  static const String premiumQuestActiveV2 = 'premium_quest_active_v2';

  /// 마지막 일일 퀘스트 생성 날짜 (v2)
  static const String lastDailyGeneratedV2 = 'last_daily_generated_v2';

  /// 마지막 주간 퀘스트 생성 날짜 (v2)
  static const String lastWeeklyGeneratedV2 = 'last_weekly_generated_v2';

  // ==================== 사용자 데이터 ====================
  /// 사용자 정보
  static const String userInfo = 'user_info';

  /// 포인트 정보
  static const String pointInfo = 'point_info';

  /// 사용자 칭호 정보
  static const String userTitleInfo = 'user_title_info';

  // ==================== 활동 기록 ====================
  /// 일일 기록 리스트
  static const String dailyRecordsList = 'daily_records_list';

  /// 운동 기록 리스트
  static const String exerciseRecordsList = 'exercise_records_list';

  /// 독서 기록 리스트
  static const String readingRecordsList = 'reading_records_list';

  /// 일기 기록 리스트
  static const String diaryRecordsList = 'diary_records_list';

  /// 집중 기록 리스트
  static const String focusRecordsList = 'focus_records_list';

  // ==================== 미팅 시스템 ====================
  /// 미팅 참가 신청 리스트
  static const String meetingApplicationsList = 'meeting_applications_list';

  /// 참가한 미팅 로그 리스트
  static const String meetingLogsList = 'meeting_logs_list';

  /// 호스트로 주최한 미팅 리스트
  static const String hostedMeetingsList = 'hosted_meetings_list';

  // ==================== 게임 데이터 ====================
  /// 게임 상태 정보
  static const String gameState = 'game_state';

  /// 배지 인벤토리
  static const String badgeInventory = 'badge_inventory';

  /// 장착 중인 배지
  static const String equippedBadges = 'equipped_badges';

  // ==================== 온보딩 & 설정 ====================
  /// 온보딩 완료 여부
  static const String onboardingCompleted = 'onboarding_completed';

  /// 앱 설정
  static const String appSettings = 'app_settings';

  /// 푸시 알림 설정
  static const String notificationSettings = 'notification_settings';
}
