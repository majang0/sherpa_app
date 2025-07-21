import '../models/quest_template_model.dart';

/// quest.md 파일의 모든 퀘스트를 정의하는 템플릿 데이터
class QuestTemplatesData {
  
  /// 일일 퀘스트 - 쉬움 난이도
  static final List<QuestTemplate> dailyEasyQuests = [
    QuestTemplate(
      id: 'D_E_01',
      title: '출석 체크',
      description: '오늘도 셰르파에 접속해주세요!',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.willpower,
      dailyDifficulty: QuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.appLaunch(),
    ),
    
    QuestTemplate(
      id: 'D_E_02',
      title: '걸음수 3000보 달성',
      description: '건강한 하루를 위해 3000보를 걸어보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.stamina,
      dailyDifficulty: QuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.steps(3000),
      targetProgress: 3000,
    ),
    
    QuestTemplate(
      id: 'D_E_03',
      title: '프로필 확인하기',
      description: '내 성장 현황을 확인해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.willpower,
      dailyDifficulty: QuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.tabVisit('프로필'),
    ),
    
    QuestTemplate(
      id: 'D_E_04',
      title: '레벨업 현황 확인',
      description: '내 산 등반 진행상황을 확인해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.willpower,
      dailyDifficulty: QuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.tabVisit('레벨업'),
    ),
    
    QuestTemplate(
      id: 'D_E_05',
      title: '모임 둘러보기',
      description: '오늘의 추천 모임을 확인해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.sociality,
      dailyDifficulty: QuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.tabVisit('모임'),
    ),
    
    QuestTemplate(
      id: 'D_E_06',
      title: '포인트 확인하기',
      description: '내 포인트 잔액을 확인해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.technique,
      dailyDifficulty: QuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.tabVisit('포인트샵'),
    ),
    
    QuestTemplate(
      id: 'D_E_07',
      title: '챌린지 둘러보기',
      description: '진행 중인 챌린지들을 확인해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.sociality,
      dailyDifficulty: QuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.tabVisit('챌린지'),
    ),
  ];

  /// 일일 퀘스트 - 보통 난이도
  static final List<QuestTemplate> dailyMediumQuests = [
    QuestTemplate(
      id: 'D_M_01',
      title: '등반 성공하기',
      description: '오늘 도전한 산을 성공적으로 등반해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.technique,
      dailyDifficulty: QuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.globalData('ClimbingRecord.isSuccess', true),
    ),
    
    QuestTemplate(
      id: 'D_M_02',
      title: '모임 후기 작성하기',
      description: '참여한 모임의 후기를 남겨보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.sociality,
      dailyDifficulty: QuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.globalData('MeetingReview', 1),
    ),
    
    QuestTemplate(
      id: 'D_M_03',
      title: '6000걸음 달성하기',
      description: '건강한 하루를 위해 걸어보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.stamina,
      dailyDifficulty: QuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.steps(6000),
      targetProgress: 6000,
    ),
    
    QuestTemplate(
      id: 'D_M_04',
      title: '뱃지 1개 장착하기',
      description: '전략적으로 뱃지를 선택해 장착해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.technique,
      dailyDifficulty: QuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.globalData('badgeEquipped', 1),
    ),
  ];

  /// 일일 퀘스트 - 어려움 난이도
  static final List<QuestTemplate> dailyHardQuests = [
    QuestTemplate(
      id: 'D_H_01',
      title: '30분 몰입 타이머',
      description: '집중해서 30분간 몰입해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.willpower,
      dailyDifficulty: QuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.globalData('todayFocusMinutes', 30),
      targetProgress: 30,
    ),
    
    QuestTemplate(
      id: 'D_H_02',
      title: '10000걸음 달성하기',
      description: '오늘은 1만보에 도전해보세요!',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.stamina,
      dailyDifficulty: QuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.steps(10000),
      targetProgress: 10000,
    ),
    
    QuestTemplate(
      id: 'D_H_03',
      title: '모든 일일 활동 완료',
      description: '운동, 독서, 일기를 모두 완료해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.willpower,
      dailyDifficulty: QuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.globalData('allDailyActivitiesCompleted', true),
    ),
    
    QuestTemplate(
      id: 'D_H_04',
      title: '포인트 100P 이상 획득',
      description: '활발한 활동으로 많은 포인트를 모아보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.technique,
      dailyDifficulty: QuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.globalData('dailyPointsEarned', 100),
      targetProgress: 100,
    ),
    
    QuestTemplate(
      id: 'D_H_05',
      title: '독서 30페이지 이상',
      description: '집중해서 30페이지 이상 읽어보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.knowledge,
      dailyDifficulty: QuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.globalData('ReadingLog.pages', 30),
      targetProgress: 30,
    ),
    
    QuestTemplate(
      id: 'D_H_06',
      title: '영화 감상 기록',
      description: '영화를 보고 느낀 점을 기록해보세요',
      type: QuestTypeV2.daily,
      category: QuestCategoryV2.knowledge,
      dailyDifficulty: QuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.globalData('MovieLog', 1),
    ),
  ];

  /// 주간 퀘스트 - 쉬움 난이도
  static final List<QuestTemplate> weeklyEasyQuests = [
    QuestTemplate(
      id: 'W_E_01',
      title: '주 3회 앱 접속',
      description: '일주일에 3번 이상 셰르파를 방문해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.willpower,
      weeklyDifficulty: WeeklyQuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('appLaunches', 3),
      targetProgress: 3,
    ),
    
    QuestTemplate(
      id: 'W_E_02',
      title: '총 20000걸음 달성',
      description: '일주일 동안 총 2만보를 걸어보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.stamina,
      weeklyDifficulty: WeeklyQuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('steps', 20000),
      targetProgress: 20000,
    ),
    
    QuestTemplate(
      id: 'W_E_03',
      title: '주 2회 운동 기록',
      description: '일주일에 2번 이상 운동을 기록해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.stamina,
      weeklyDifficulty: WeeklyQuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('exerciseRecords', 2),
      targetProgress: 2,
    ),
    
    QuestTemplate(
      id: 'W_E_04',
      title: '등반 5회 이상 완료하기',
      description: '이번주 등반하기 기능 5회 이상 완료',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.technique,
      weeklyDifficulty: WeeklyQuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('climbingCompletions', 5),
      targetProgress: 5,
    ),
    
    QuestTemplate(
      id: 'W_E_05',
      title: '주 3회 독서 기록',
      description: '일주일에 3번 이상 독서를 기록해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.knowledge,
      weeklyDifficulty: WeeklyQuestDifficultyV2.easy,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('readingRecords', 3),
      targetProgress: 3,
    ),
  ];

  /// 주간 퀘스트 - 보통 난이도
  static final List<QuestTemplate> weeklyMediumQuests = [
    QuestTemplate(
      id: 'W_M_01',
      title: '주 5회 일기 작성',
      description: '일주일에 5번 이상 일기를 써보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.willpower,
      weeklyDifficulty: WeeklyQuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('diaryRecords', 5),
      targetProgress: 5,
    ),
    
    QuestTemplate(
      id: 'W_M_02',
      title: '영화 2편 기록',
      description: '주말에 본 영화를 기록해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.knowledge,
      weeklyDifficulty: WeeklyQuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('movieLogs', 2),
      targetProgress: 2,
    ),
    
    QuestTemplate(
      id: 'W_M_03',
      title: '총 50000걸음 달성',
      description: '일주일 동안 총 5만보를 걸어보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.stamina,
      weeklyDifficulty: WeeklyQuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('steps', 50000),
      targetProgress: 50000,
    ),
    
    QuestTemplate(
      id: 'W_M_04',
      title: '총 180분 몰입',
      description: '일주일 동안 총 3시간 몰입해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.willpower,
      weeklyDifficulty: WeeklyQuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('focusMinutes', 180),
      targetProgress: 180,
    ),
    
    QuestTemplate(
      id: 'W_M_05',
      title: '모임 1회 참여',
      description: '이번 주에 모임에 참여해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.sociality,
      weeklyDifficulty: WeeklyQuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('meetingLogs', 1),
      targetProgress: 1,
    ),
    
    QuestTemplate(
      id: 'W_M_06',
      title: '포인트 500P 모으기',
      description: '활발한 활동으로 500포인트를 모아보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.technique,
      weeklyDifficulty: WeeklyQuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('pointsEarned', 500),
      targetProgress: 500,
    ),
    
    QuestTemplate(
      id: 'W_M_07',
      title: '주 5회 영화/독서 기록',
      description: '문화생활을 즐기고 기록해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.knowledge,
      weeklyDifficulty: WeeklyQuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('culturalRecords', 5),
      targetProgress: 5,
    ),
    
    QuestTemplate(
      id: 'W_M_08',
      title: '모임 후기 작성',
      description: '참여한 모임의 후기를 작성해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.sociality,
      weeklyDifficulty: WeeklyQuestDifficultyV2.medium,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('meetingReviews', 1),
      targetProgress: 1,
    ),
  ];

  /// 주간 퀘스트 - 어려움 난이도
  static final List<QuestTemplate> weeklyHardQuests = [
    QuestTemplate(
      id: 'W_H_01',
      title: '매일 완벽한 하루',
      description: '5일 이상 모든 일일 활동을 완료해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.willpower,
      weeklyDifficulty: WeeklyQuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('perfectDays', 5),
      targetProgress: 5,
    ),
    
    QuestTemplate(
      id: 'W_H_02',
      title: '총 100000걸음 달성',
      description: '일주일 동안 총 10만보를 걸어보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.stamina,
      weeklyDifficulty: WeeklyQuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('steps', 100000),
      targetProgress: 100000,
    ),
    
    QuestTemplate(
      id: 'W_H_03',
      title: '모든 활동 마스터',
      description: '운동, 독서, 일기, 몰입을 매일 완료해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.willpower,
      weeklyDifficulty: WeeklyQuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('allActivitiesDays', 7),
      targetProgress: 7,
    ),
    
    QuestTemplate(
      id: 'W_H_04',
      title: '챌린지 참여하기',
      description: '새로운 챌린지에 참여해보세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.sociality,
      weeklyDifficulty: WeeklyQuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('challengeRecords', 1),
      targetProgress: 1,
    ),
    
    QuestTemplate(
      id: 'W_H_05',
      title: '2개 모임 동시 참여',
      description: '서로 다른 2개의 모임에 적극 참여하세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.sociality,
      weeklyDifficulty: WeeklyQuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('differentMeetings', 2),
      targetProgress: 2,
    ),
    
    QuestTemplate(
      id: 'W_H_06',
      title: '주간 포인트 1000P 획득',
      description: '활발한 활동으로 1000포인트를 획득하세요',
      type: QuestTypeV2.weekly,
      category: QuestCategoryV2.technique,
      weeklyDifficulty: WeeklyQuestDifficultyV2.hard,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('pointsEarned', 1000),
      targetProgress: 1000,
    ),
  ];

  /// 고급 퀘스트 - 레어 난이도
  static final List<QuestTemplate> premiumRareQuests = [
    QuestTemplate(
      id: 'P_R_01',
      title: '산악 마스터',
      description: '한 주에 서로 다른 난이도의 산 3개를 등반완료하세요',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.technique,
      rarity: QuestRarityV2.rare,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('differentMountains', 3),
      targetProgress: 3,
    ),
    
    QuestTemplate(
      id: 'P_R_02',
      title: '독서왕',
      description: '일주일 동안 총 100페이지 이상 읽고 기록하세요',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.knowledge,
      rarity: QuestRarityV2.rare,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('readingPages', 100),
      targetProgress: 100,
    ),
    
    QuestTemplate(
      id: 'P_R_03',
      title: '소셜 네트워커',
      description: '3개의 서로 다른 모임에 참여하세요',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.sociality,
      rarity: QuestRarityV2.rare,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('differentMeetingCategories', 3),
      targetProgress: 3,
    ),
    
    QuestTemplate(
      id: 'P_R_04',
      title: '지식의 탐구자',
      description: '독서 200페이지 + 영화 2편 기록',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.knowledge,
      rarity: QuestRarityV2.rare,
      trackingCondition: QuestTrackingConditionHelper.multipleConditions(['readingPages:200', 'movieLogs:2']),
      targetProgress: 1,
    ),
  ];

  /// 고급 퀘스트 - 에픽 난이도
  static final List<QuestTemplate> premiumEpicQuests = [
    QuestTemplate(
      id: 'P_E_01',
      title: '연속 등반 챔피언',
      description: '7일 연속 등반에 성공하세요',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.willpower,
      rarity: QuestRarityV2.epic,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('연속등반성공', 7),
      targetProgress: 7,
    ),
    
    QuestTemplate(
      id: 'P_E_02',
      title: '완벽한 일주일',
      description: '모든 일일 퀘스트를 7일 연속 완료하세요',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.willpower,
      rarity: QuestRarityV2.epic,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('연속일일퀘스트완료', 7),
      targetProgress: 7,
    ),
    
    QuestTemplate(
      id: 'P_E_03',
      title: '운동 전문가',
      description: '3가지 다른 운동을 기록하고 총 300분 이상 운동하세요',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.stamina,
      rarity: QuestRarityV2.epic,
      trackingCondition: QuestTrackingConditionHelper.multipleConditions(['differentExerciseTypes:3', 'exerciseMinutes:300']),
      targetProgress: 1,
    ),
    
    QuestTemplate(
      id: 'P_E_04',
      title: '주간퀘스트 전체 클리어',
      description: '이번 주 모든 주간 퀘스트를 완료하세요',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.willpower,
      rarity: QuestRarityV2.epic,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('모든주간퀘스트완료', 1),
      targetProgress: 1,
    ),
  ];

  /// 고급 퀘스트 - 전설 난이도
  static final List<QuestTemplate> premiumLegendaryQuests = [
    QuestTemplate(
      id: 'P_L_01',
      title: '커뮤니티 리더',
      description: '모임을 호스팅하고 2명 이상의 참가자를 모으세요',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.sociality,
      rarity: QuestRarityV2.legendary,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('모임주최성공', 1),
      targetProgress: 1,
    ),
    
    QuestTemplate(
      id: 'P_L_02',
      title: '궁극의 도전',
      description: '30일 챌린지를 시작하고 첫 주를 완벽하게 완료하세요',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.willpower,
      rarity: QuestRarityV2.legendary,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('30일챌린지첫주', 1),
      targetProgress: 1,
    ),
    
    QuestTemplate(
      id: 'P_L_03',
      title: '올라운드 플레이어',
      description: '모든 카테고리(체력/지식/기술/사교성/의지력)에서 각 1개 이상 퀘스트 완료',
      type: QuestTypeV2.premium,
      category: QuestCategoryV2.technique,
      rarity: QuestRarityV2.legendary,
      trackingCondition: QuestTrackingCondition.weeklyAccumulation('모든카테고리퀘스트완료', 1),
      targetProgress: 1,
    ),
  ];

  /// 모든 퀘스트 템플릿 가져오기
  static List<QuestTemplate> getAllTemplates() {
    return [
      ...dailyEasyQuests,
      ...dailyMediumQuests,
      ...dailyHardQuests,
      ...weeklyEasyQuests,
      ...weeklyMediumQuests,
      ...weeklyHardQuests,
      ...premiumRareQuests,
      ...premiumEpicQuests,
      ...premiumLegendaryQuests,
    ];
  }

  /// 퀘스트 유형별 템플릿 가져오기
  static List<QuestTemplate> getTemplatesByType(QuestTypeV2 type) {
    return getAllTemplates().where((template) => template.type == type).toList();
  }

  /// 일일 퀘스트 템플릿 가져오기
  static List<QuestTemplate> getDailyTemplates() {
    return [
      ...dailyEasyQuests,
      ...dailyMediumQuests,
      ...dailyHardQuests,
    ];
  }

  /// 주간 퀘스트 템플릿 가져오기
  static List<QuestTemplate> getWeeklyTemplates() {
    return [
      ...weeklyEasyQuests,
      ...weeklyMediumQuests,
      ...weeklyHardQuests,
    ];
  }

  /// 고급 퀘스트 템플릿 가져오기
  static List<QuestTemplate> getPremiumTemplates() {
    return [
      ...premiumRareQuests,
      ...premiumEpicQuests,
      ...premiumLegendaryQuests,
    ];
  }

  /// ID로 템플릿 찾기
  static QuestTemplate? getTemplateById(String id) {
    try {
      return getAllTemplates().firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// 복합 조건 처리를 위한 헬퍼 클래스
class QuestTrackingConditionHelper {
  static QuestTrackingCondition multipleConditions(List<String> conditions) {
    return QuestTrackingCondition(
      type: QuestTrackingType.multipleConditions,
      parameters: {'conditions': conditions},
      description: '복합 조건: ${conditions.join(', ')}',
    );
  }
}