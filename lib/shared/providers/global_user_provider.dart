import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../models/global_user_model.dart';
import '../../features/daily_record/services/sample_data_generator.dart';
import '../../features/daily_record/models/detailed_exercise_models.dart' as detailed;
import '../models/user_level_progress.dart';
import '../models/point_system_model.dart';
import '../models/global_badge_model.dart';
import '../../core/constants/game_constants.dart';
import 'global_point_provider.dart';
import 'global_sherpi_provider.dart';
import 'global_game_provider.dart';
import 'global_badge_provider.dart'; // 뱃지 Provider 추가
import '../../core/constants/sherpi_dialogues.dart';
import '../../features/quests/providers/quest_provider_v2.dart';

/// 글로벌 사용자 데이터 관리 Provider (완전 독립형)
final globalUserProvider = StateNotifierProvider<GlobalUserNotifier, GlobalUser>((ref) {
  final notifier = GlobalUserNotifier(ref);
  // 샘플 데이터 테스트를 위해 자동 초기화 비활성화
  // notifier._initializeAndClearData();
  return notifier;
});

class GlobalUserNotifier extends StateNotifier<GlobalUser> {
  final Ref ref;

  GlobalUserNotifier(this.ref) : super(_createInitialUser());

  Future<void> _initializeAndClearData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 초기화 후, 현재 상태(초기값)를 저장하여 일관성을 유지합니다.
      await _saveUserData();

    } catch (e) {
    }
  }

  /// 60일간 샘플 일일 기록 생성 (SampleDataGenerator 사용)
  static DailyRecordData _createSampleDailyRecords() {
    // SampleDataGenerator를 사용하여 풍부한 샘플 데이터 생성
    return SampleDataGenerator.generateSampleData();
  }

  /// 기존 독서 전용 샘플 데이터 생성 (백업용)
  static DailyRecordData _createBasicSampleDailyRecords() {
    final now = DateTime.now();
    final sampleReadingLogs = <ReadingLog>[];

    // 14일간 독서 기록 샘플 데이터
    final sampleBooks = [
      {'title': '원칙', 'author': '게리 콜러', 'pages': 25, 'rating': 4.5, 'category': '자기계발'},
      {'title': '아토믹 해빗', 'author': '제임스 클리어', 'pages': 32, 'rating': 5.0, 'category': '자기계발'},
      {'title': '사피엔스', 'author': '유발 하라리', 'pages': 28, 'rating': 4.0, 'category': '역사'},
      {'title': '코스모스', 'author': '칼 세이건', 'pages': 22, 'rating': 4.5, 'category': '과학'},
      {'title': '데일 카네기 인간관계론', 'author': '데일 카네기', 'pages': 35, 'rating': 4.0, 'category': '자기계발'},
      {'title': '부의 추월차선', 'author': 'MJ 드마코', 'pages': 40, 'rating': 4.5, 'category': '경영'},
      {'title': '완벽한 공부법', 'author': '고영성', 'pages': 18, 'rating': 3.5, 'category': '자기계발'},
      {'title': '미드나잇 라이브러리', 'author': '매트 헤이그', 'pages': 45, 'rating': 5.0, 'category': '소설'},
      {'title': '넛지', 'author': '리처드 탈러', 'pages': 30, 'rating': 4.0, 'category': '경영'},
      {'title': '생각, 빠르고 느리게', 'author': '대니얼 카너먼', 'pages': 26, 'rating': 4.5, 'category': '과학'},
    ];

    // 14일간 모임 기록 샘플 데이터

    // 14일간 데이터 생성
    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // 독서 기록 (70% 확률로 생성)
      if (math.Random().nextDouble() < 0.7 && sampleBooks.isNotEmpty) {
        final bookIndex = math.Random().nextInt(sampleBooks.length);
        final book = sampleBooks[bookIndex];

        final moods = ['happy', 'excited', 'thoughtful', 'moved', 'surprised', 'calm'];
        sampleReadingLogs.add(ReadingLog(
          id: 'reading_${date.millisecondsSinceEpoch}',
          date: date,
          bookTitle: book['title'] as String,
          author: book['author'] as String,
          pages: book['pages'] as int,
          rating: book['rating'] as double,
          category: book['category'] as String,
          mood: math.Random().nextDouble() < 0.7 ? moods[math.Random().nextInt(moods.length)] : null,
          note: _getRandomReadingNote(),
          isShared: math.Random().nextBool(),
        ));
      }
    }

    return DailyRecordData(
      todaySteps: 7850, // ✅ 6000걸음 달성 (자동 완료)
      todayFocusMinutes: 45, // ✅ 30분 달성 (자동 완료)
      meetingLogs: [], // Meeting logs are now managed by GlobalMeetingProvider
      readingLogs: sampleReadingLogs, // ✅ 오늘 독서 기록 있음 (자동 완룈)
      exerciseLogs: [],
      diaryLogs: [],
      movieLogs: [],
      dailyGoals: DailyGoal.createDefaultGoals(),
      climbingLogs: [],
      challengeRecords: [],
      consecutiveDays: 5,
      lastActiveDate: now,
    );
  }

  /// 랜덤 독서 노트 생성
  static String? _getRandomReadingNote() {
    final notes = [
      '새로운 관점을 얻을 수 있었어요',
      '실생활에 바로 적용해볼 만한 내용이었습니다',
      '생각보다 어려웠지만 유익했어요',
      '저자의 경험담이 인상깊었습니다',
      '다음에 또 읽어보고 싶은 책이에요',
      null, null, // 30% 확률로 노트 없음
    ];
    return notes[math.Random().nextInt(notes.length)];
  }


  /// 초기 사용자 데이터 생성 (12레벨, 적정 경험치)
  static GlobalUser _createInitialUser() {
    // 11레벨까지의 총 경험치 계산
    final level11TotalXp = GameConstants.getTotalXpForLevel(11);
    // 12레벨에서 30% 진행된 상태
    final level12RequiredXp = GameConstants.getRequiredXpForLevel(12);
    final currentXp = level11TotalXp + (level12RequiredXp * 0.3);

    final user = GlobalUser(
      id: 'user_001',
      name: '박지호',
      level: 12,
      experience: currentXp,
      // ✅ 능력치 0-10 범위로 복원
      stats: GlobalStats(
        stamina: 8.5,    // 체력 8.5
        knowledge: 6.2,  // 지식 6.2
        technique: 4.3,  // 기술 4.3
        sociality: 7.1,  // 사교성 7.1
        willpower: 20,  // 의지 20 (원래대로 복원)
      ),
      equippedBadgeIds: [
        'epic_will',         // 굳건한 의지 (성공률 +8%)
        'common_explorer',   // 탐험가의 발걸음 (기본 등반력 +5%)
      ],
      ownedBadgeIds: [
        'epic_will',         // 굳건한 의지 (성공률 +8%)
        'common_luck',       // 초심자의 행운 (성공률 +3%)
        'common_explorer',   // 탐험가의 발걸음 (기본 등반력 +5%)
        'common_stamina',    // 꾸준함의 증표 (경험치 +10%)
      ],
      dailyRecords: _createSampleDailyRecords(),
    );
    return user;
  }

  /// SharedPreferences에 사용자 데이터 저장
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('global_user_data', jsonEncode(state.toJson()));
    } catch (e) {
    }
  }

  /// 경험치 추가 및 레벨업 처리
  void addExperience(double xp) {
    final oldLevel = state.level;
    final newExp = state.experience + xp;
    var newLevel = state.level;

    // 레벨업 확인
    while (true) {
      final totalXpForCurrentLevel = GameConstants.getTotalXpForLevel(newLevel);
      if (newExp < totalXpForCurrentLevel) break;
      newLevel++;
    }

    state = state.copyWith(
      experience: newExp,
      level: newLevel,
    );

    if (newLevel > oldLevel) {
      // 레벨업 보상 지급
      _handleLevelUp(oldLevel, newLevel);
    }

    _saveUserData();
  }

  /// 레벨업 처리 및 보상
  void _handleLevelUp(int oldLevel, int newLevel) {
    // 통합된 포인트 시스템으로 레벨업 보너스 지급
    ref.read(globalPointProvider.notifier).onLevelUp(newLevel);

    // 셰르피 축하 메시지
    ref.read(sherpiProvider.notifier).showMessage(
      context: SherpiContext.levelUp,
      emotion: SherpiEmotion.celebrating,
      userContext: {
        'newLevel': newLevel,
        'oldLevel': oldLevel,
      },
    );
  }

  /// 능력치 업데이트
  void updateStats({
    double? stamina,
    double? knowledge,
    double? technique,
    double? sociality,
    double? willpower,
  }) {
    final newStats = state.stats.copyWith(
      stamina: stamina,
      knowledge: knowledge,
      technique: technique,
      sociality: sociality,
      willpower: willpower,
    );

    state = state.copyWith(stats: newStats);
    _saveUserData();
  }

  /// 능력치 증가 (활동 완료 시)
  void increaseStats({
    double deltaStamina = 0,
    double deltaKnowledge = 0,
    double deltaTechnique = 0,
    double deltaSociality = 0,
    double deltaWillpower = 0,
  }) {
    final currentStats = state.stats;

    updateStats(
      stamina: math.min(100.0, currentStats.stamina + deltaStamina),
      knowledge: math.min(100.0, currentStats.knowledge + deltaKnowledge),
      technique: math.min(100.0, currentStats.technique + deltaTechnique),
      sociality: math.min(100.0, currentStats.sociality + deltaSociality),
      willpower: math.min(100.0, currentStats.willpower + deltaWillpower),
    );
  }

  /// 뱃지 장착
  void equipBadge(String badgeId) {
    if (!state.equippedBadgeIds.contains(badgeId) &&
        state.ownedBadgeIds.contains(badgeId)) {
      state = state.copyWith(
        equippedBadgeIds: [...state.equippedBadgeIds, badgeId],
      );
      _saveUserData();
    }
  }

  /// 뱃지 해제
  void unequipBadge(String badgeId) {
    state = state.copyWith(
      equippedBadgeIds: state.equippedBadgeIds.where((id) => id != badgeId).toList(),
    );
    _saveUserData();
  }

  /// 뱃지 추가
  void addBadge(String badgeId) {
    if (!state.ownedBadgeIds.contains(badgeId)) {
      state = state.copyWith(
        ownedBadgeIds: [...state.ownedBadgeIds, badgeId],
      );
      _saveUserData();
    }
  }

  // ==================== 등반 시스템 관리 ====================

  /// 등반 시작
  void startClimbing({
    required int mountainId,
    required String mountainName,
    required String region,
    required int difficulty,
    required double durationHours,
    required double mountainPower,
    double? originalDuration,
  }) {
    // 이미 등반 중이면 시작 불가
    if (state.currentClimbingSession?.isActive == true) {
      return;
    }

    // 장착된 뱃지 가져오기 (실제 뱃지 적용)
    final equippedBadges = _getEquippedBadges();

    // 사용자 등반력 계산 (산 레벨 정보 포함)
    final gameSystem = ref.read(globalGameProvider);
    final userPower = gameSystem.calculateFinalClimbingPower(
      level: state.level,
      titleBonus: gameSystem.getTitleBonus(state.level),
      stamina: state.stats.stamina,
      knowledge: state.stats.knowledge,
      technique: state.stats.technique,
      equippedBadges: equippedBadges,

    );

    // ⏰ 사교성에 따른 등반 시간 계산
    final adjustedDuration = GameConstants.calculateAdjustedClimbingTime(
      durationHours,
      state.stats.sociality,
    );

    // 성공 확률 계산 (실제 뱃지 효과 적용)
    final successProbability = gameSystem.calculateSuccessProbability(
      userPower: userPower,
      mountainPower: mountainPower,
      willpower: state.stats.willpower,
      equippedBadges: equippedBadges,
    );

    // 등반 세션 생성 (조정된 시간으로)
    final session = ClimbingSession(
      id: 'climbing_${DateTime.now().millisecondsSinceEpoch}',
      mountainId: mountainId,
      mountainName: mountainName,
      startTime: DateTime.now(),
      durationHours: adjustedDuration, // ✅ 뱃지 효과 적용된 시간
      successProbability: successProbability,
      isActive: true,
      status: ClimbingSessionStatus.active,
      userPower: userPower,
      mountainPower: mountainPower,
      metadata: {
        'region': region,
        'difficulty': difficulty,
        'originalDuration': originalDuration ?? durationHours, // 원래 시간 저장
        'timeReduction': durationHours > adjustedDuration ? ((durationHours - adjustedDuration) / durationHours * 100).toStringAsFixed(1) : '0',
      },
    );

    state = state.copyWith(currentClimbingSession: session);
    _saveUserData();

    // 🎯 뱃지 효과 피드백 메시지
    String feedbackMessage = '$mountainName 등반을 시작했어요! 성공 확률: ${(successProbability * 100).toStringAsFixed(1)}%';

    // 시간 단축 효과가 있다면 추가 메시지
    if (adjustedDuration < durationHours) {
      final reductionPercent = ((durationHours - adjustedDuration) / durationHours * 100).round();
      feedbackMessage += '\n⚡ 시간 마술사 효과로 등반 시간 ${reductionPercent}% 단축!';
    }

    feedbackMessage += ' 🏔️';

    // 셰르피 메시지
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.general,
      customDialogue: feedbackMessage,
      emotion: SherpiEmotion.cheering,
    );

  }

  /// 등반 완료 (수동 또는 자동)
  void completeClimbing({
    bool? forceResult, // true: 강제 성공, false: 강제 실패, null: 확률에 따라
  }) {
    final session = state.currentClimbingSession;
    if (session == null || !session.isActive) {
      return;
    }

    final now = DateTime.now();
    final actualDuration = now.difference(session.startTime).inMilliseconds / (1000 * 3600);

    final originalDuration = session.metadata?['originalDuration'] as double? ?? session.durationHours;

    // 성공/실패 결정
    bool isSuccess;
    if (forceResult != null) {
      isSuccess = forceResult;
    } else {
      isSuccess = math.Random().nextDouble() < session.successProbability;
    }

    // 보상 계산
    final gameSystem = ref.read(globalGameProvider);
    final difficulty = session.metadata?['difficulty'] ?? 1;
    final region = session.metadata?['region'] ?? '미알';


    final rewards = _calculateClimbingRewards(
      gameSystem: gameSystem,
      difficulty: difficulty,
      durationHours: originalDuration,  // 원래 시간 사용
      isSuccess: isSuccess,
    );

    // 등반 기록 생성
    final record = ClimbingRecord(
      id: session.id,
      mountainId: session.mountainId,
      mountainName: session.mountainName,
      region: region,
      difficulty: difficulty,
      startTime: session.startTime,
      endTime: now,
      durationHours: actualDuration,
      isSuccess: isSuccess,
      userPower: session.userPower,
      mountainPower: session.mountainPower,
      successProbability: session.successProbability,
      rewards: rewards,
      failureReason: isSuccess ? null : _getRandomFailureReason(),
    );

    // 등반 기록 추가
    final updatedClimbingLogs = [
      ...state.dailyRecords.climbingLogs,
      record,
    ];

    final updatedRecords = state.dailyRecords.copyWith(
      climbingLogs: updatedClimbingLogs,
    );

    // 등반 세션 종료
    state = state.copyWith(
      dailyRecords: updatedRecords,
      currentClimbingSession: session.copyWith(
        isActive: false,
        status: isSuccess ? ClimbingSessionStatus.completed : ClimbingSessionStatus.failed,
      ),
    );

    // 보상 지급
    if (rewards.hasRewards) {
      handleActivityCompletion(
        activityType: 'climbing',
        xp: rewards.experience,
        points: rewards.points,
        statIncreases: rewards.statIncreases,
        message: isSuccess
            ? '등반 성공! ${session.mountainName} 정방 🎉'
            : '등반 실패했지만 경험을 얻었어요 💪',
        additionalData: {
          'mountainId': session.mountainId,
          'difficulty': difficulty,
          'isSuccess': isSuccess,
        },
      );

      // 새 뱃지 획듰 처리
      for (final badgeId in rewards.newBadgeIds) {
        addBadge(badgeId);
      }
    }

    // 셀르피 결과 메시지
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.general,
      customDialogue: record.resultMessage + '\n' + rewards.summaryText,
      emotion: isSuccess ? SherpiEmotion.celebrating : SherpiEmotion.encouraging,
    );

    _saveUserData();
  }

  /// 등반 취소
  void cancelClimbing() {
    final session = state.currentClimbingSession;
    if (session == null || !session.isActive) {
      return;
    }

    state = state.copyWith(
      currentClimbingSession: session.copyWith(
        isActive: false,
        status: ClimbingSessionStatus.cancelled,
      ),
    );

    _saveUserData();

    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.general,
      customDialogue: '등반을 취소했어요. 다음에 다시 도전해보세요! 🙌',
      emotion: SherpiEmotion.encouraging,
    );
  }

  /// 등반 세션 상태 업데이트 (주기적 호출)
  void _updateClimbingSessionStatus() {
    final session = state.currentClimbingSession;
    if (session == null || !session.isActive) {
      return;
    }

    final now = DateTime.now();
    final progress = session.progress;

    // 등반이 완료 시간에 도달한 경우 자동 완료
    if (progress >= 1.0) {
      completeClimbing(); // 확률에 따라 자동 결정
    }
  }

  /// 등반 보상 계산 (뱃지 효과 적용)
  ClimbingRewards _calculateClimbingRewards({
    required gameSystem,
    required int difficulty,
    required double durationHours,
    required bool isSuccess,

  }) {


    double experience = 0;
    int points = 0;
    Map<String, double> statIncreases = {};
    List<String> newBadgeIds = [];
    String? specialReward;

    // 장착된 뱃지 가져오기
    final equippedBadges = _getEquippedBadges();

    if (isSuccess) {
      // 성공 시 보상
      experience = gameSystem.calculateSuccessXp(difficulty, durationHours);
      points = gameSystem.calculateSuccessPoints(difficulty, durationHours).toInt();

      // 🎲 숨겨진 보상 발견 확률 체크
      final hiddenChance = GameConstants.calculateHiddenTreasureChance(
        difficulty,
        state.level,
        equippedBadges,
      );
      if (math.Random().nextDouble() < hiddenChance) {
        points = (points * 1.5).round(); // 포인트 50% 추가
        specialReward = '🎁 숨겨진 보상 발견! 포인트 +50%';
      }

      // 난이도에 따른 능력치 증가
      if (difficulty >= 100) {
        statIncreases = {};
      } else if (difficulty >= 50) {
        statIncreases = {};
      } else {
        statIncreases = {};
      }

      // 특별한 산 등반 시 뱃지 획득 기회
      if (difficulty == 200) { // 에베레스트
        newBadgeIds.add('legendary_everest_conqueror');
        specialReward = '전설의 에베레스트 정복자 뱃지 획득!';
      } else if (difficulty >= 100) {
        if (math.Random().nextDouble() < 0.1) {
          newBadgeIds.add('epic_mountain_king');
        }
      }
    } else {
      // 실패 시 보상
      experience = gameSystem.calculateFailureXp(difficulty, durationHours);
      points = 0;
      statIncreases = {};
    }

    return ClimbingRewards(
      experience: experience,
      points: points,
      statIncreases: statIncreases,
      newBadgeIds: newBadgeIds,
      specialReward: specialReward,
    );
  }

  /// 장착 뱃지 리스트 가져오기 (실제 뱃지 데이터 반환)
  List<GlobalBadge> _getEquippedBadges() {
    final allBadges = ref.read(globalAllBadgesProvider);
    return state.equippedBadgeIds
        .map((id) => allBadges.firstWhere(
          (badge) => badge.id == id,
      orElse: () => allBadges.first, // 기본값으로 첫 번째 뱃지 반환
    ))
        .toList();
  }

  /// 랜덤 실패 사유 생성
  String _getRandomFailureReason() {
    final gameSystem = ref.read(globalGameProvider);
    return gameSystem.getRandomFailureMessage();
  }

  /// 등반 기록 조회
  List<ClimbingRecord> getClimbingHistory({int? limit}) {
    final logs = state.dailyRecords.climbingLogs;
    final sortedLogs = List<ClimbingRecord>.from(logs)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return limit != null ? sortedLogs.take(limit).toList() : sortedLogs;
  }

  /// 등반 통계 조회
  ClimbingStatistics getClimbingStatistics() {
    return ClimbingStatistics.fromRecords(state.dailyRecords.climbingLogs);
  }

  /// 현재 등반 상태 확인
  bool get isCurrentlyClimbing {
    return state.currentClimbingSession?.isActive == true;
  }

  /// 현재 등반 진행률
  double get currentClimbingProgress {
    final session = state.currentClimbingSession;
    if (session == null || !session.isActive) return 0.0;
    return session.progress;
  }

  /// 현재 등반 남은 시간
  Duration get currentClimbingRemainingTime {
    final session = state.currentClimbingSession;
    if (session == null || !session.isActive) return Duration.zero;
    return session.remainingTime;
  }

  // ==================== 일일 기록 관리 ====================

  /// 걸음수 업데이트
  void updateSteps(int steps) {
    final updatedRecords = state.dailyRecords.copyWith(
      todaySteps: steps,
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // 히스토리에 저장
    _saveDailySteps(DateTime.now(), steps);

    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();

    // 🔄 퀘스트 시스템과 연동
    _notifyQuestSystem('steps', {'steps': steps});

    _saveUserData();
  }

  /// 집중 시간 업데이트
  void updateFocusTime(int minutes) {
    final currentFocusMinutes = state.dailyRecords.todayFocusMinutes;
    final updatedRecords = state.dailyRecords.copyWith(
      todayFocusMinutes: currentFocusMinutes + minutes,
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();

    // 🔄 퀘스트 시스템과 연동 - 집중 시간 추가와 총 시간 모두 전달
    _notifyQuestSystem('focus', {
      'minutes': minutes,
      'totalMinutes': currentFocusMinutes + minutes,
      'dailyRecords.todayFocusMinutes': currentFocusMinutes + minutes,
    });

    _saveUserData();
  }

  /// 모임 기록 추가
  void addMeetingLog(MeetingLog meetingLog) {
    final updatedRecords = state.dailyRecords.copyWith(
      meetingLogs: [...state.dailyRecords.meetingLogs, meetingLog],
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // 보상 지급
    _handleActivityCompletion(
      activityType: 'meeting',
      xp: 50.0,
      points: 100,
      statIncreases: {'sociality': 0.2},
      message: '모임 참여 완료! 🤝',
    );

    _saveUserData();
  }

  /// 독서 기록 추가
  void addReadingLog(ReadingLog readingLog) {
    final updatedRecords = state.dailyRecords.copyWith(
      readingLogs: [...state.dailyRecords.readingLogs, readingLog],
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();

    // 보상 지급
    _handleActivityCompletion(
      activityType: 'reading',
      xp: 30.0 + (readingLog.pages * 2.0),
      points: 0, // 독서는 포인트 없음
      statIncreases: {'knowledge': 0.1 + (readingLog.pages * 0.01)},
      message: '독서 기록 완료! 📚 ${readingLog.pages}페이지',
    );

    // 🔄 퀘스트 시스템과 연동
    _notifyQuestSystem('reading', {'pages': readingLog.pages});

    _saveUserData();
  }

  /// 독서 기록 수정
  void updateReadingLog(ReadingLog updatedLog) {
    final currentLogs = state.dailyRecords.readingLogs;
    final updatedLogs = currentLogs.map((log) => 
      log.id == updatedLog.id ? updatedLog : log
    ).toList();

    final updatedRecords = state.dailyRecords.copyWith(
      readingLogs: updatedLogs,
    );

    state = state.copyWith(dailyRecords: updatedRecords);
    
    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();
    
    _saveUserData();
  }

  /// 운동 기록 추가
  void addExerciseLog(ExerciseLog exerciseLog) {
    final updatedRecords = state.dailyRecords.copyWith(
      exerciseLogs: [...state.dailyRecords.exerciseLogs, exerciseLog],
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();

    // 보상 지급
    _handleActivityCompletion(
      activityType: 'exercise',
      xp: 40.0 + (exerciseLog.durationMinutes * 0.5),
      points: 0, // 운동은 포인트 없음
      statIncreases: {'stamina': 0.2 + (exerciseLog.durationMinutes * 0.005)},
      message: '운동 기록 완료! 💪 ${exerciseLog.durationMinutes}분',
    );

    // 🔄 퀘스트 시스템과 연동
    _notifyQuestSystem('exercise', {'duration': exerciseLog.durationMinutes});

    _saveUserData();
  }

  /// 상세 운동 기록 추가 (새로운 상세 기록 시스템)
  void addDetailedExerciseRecord(detailed.DetailedExerciseRecord record) {
    // 기존 ExerciseLog도 동시에 추가하여 호환성 유지
    final basicExerciseLog = ExerciseLog(
      id: record.id,
      date: record.date,
      exerciseType: record.exerciseType,
      durationMinutes: record.durationMinutes,
      intensity: 'moderate', // 기본값
      note: record.note,
    );

    // 상세 기록을 SharedPreferences에 저장
    _saveDetailedExerciseRecord(record);

    // 기존 시스템과 연동
    addExerciseLog(basicExerciseLog);
  }

  /// 상세 운동 기록을 SharedPreferences에 저장
  Future<void> _saveDetailedExerciseRecord(detailed.DetailedExerciseRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'detailed_exercise_records';
      
      // 기존 기록들 불러오기
      final existingRecordsJson = prefs.getStringList(key) ?? [];
      final existingRecords = existingRecordsJson.map((json) => 
        Map<String, dynamic>.from(jsonDecode(json))
      ).toList();
      
      // 새 기록 추가
      existingRecords.add(record.toJson());
      
      // 최신 순으로 정렬 (최근 100개만 유지)
      existingRecords.sort((a, b) => 
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']))
      );
      
      if (existingRecords.length > 100) {
        existingRecords.removeRange(100, existingRecords.length);
      }
      
      // 저장
      final updatedRecordsJson = existingRecords.map((record) => 
        jsonEncode(record)
      ).toList();
      
      await prefs.setStringList(key, updatedRecordsJson);
    } catch (e) {
    }
  }

  /// 상세 운동 기록들 불러오기
  Future<List<detailed.DetailedExerciseRecord>> getDetailedExerciseRecords({
    String? exerciseType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'detailed_exercise_records';
      
      final recordsJson = prefs.getStringList(key) ?? [];
      final records = <detailed.DetailedExerciseRecord>[];
      
      for (final json in recordsJson) {
        try {
          final recordData = Map<String, dynamic>.from(jsonDecode(json));
          final recordDate = DateTime.parse(recordData['date']);
          
          // 필터링
          if (exerciseType != null && recordData['exerciseType'] != exerciseType) {
            continue;
          }
          
          if (fromDate != null && recordDate.isBefore(fromDate)) {
            continue;
          }
          
          if (toDate != null && recordDate.isAfter(toDate)) {
            continue;
          }
          
          // 운동 타입에 맞는 모델로 변환
          final type = recordData['exerciseType'] as String;
          detailed.DetailedExerciseRecord record;
          
          switch (type) {
            case '러닝':
              record = detailed.RunningRecord.fromJson(recordData);
              break;
            case '클라이밍':
              record = detailed.ClimbingRecord.fromJson(recordData);
              break;
            case '등산':
              record = detailed.HikingRecord.fromJson(recordData);
              break;
            case '헬스':
              record = detailed.GymRecord.fromJson(recordData);
              break;
            case '배드민턴':
              record = detailed.BadmintonRecord.fromJson(recordData);
              break;
            default:
              // 기본 구현 (향후 확장 가능)
              continue;
          }
          
          records.add(record);
        } catch (e) {
          continue;
        }
      }
      
      return records;
    } catch (e) {
      return [];
    }
  }

  /// 일기 기록 추가
  void addDiaryLog(DiaryLog diaryLog) {
    final updatedRecords = state.dailyRecords.copyWith(
      diaryLogs: [...state.dailyRecords.diaryLogs, diaryLog],
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();

    // 보상 지급
    _handleActivityCompletion(
      activityType: 'diary',
      xp: 25.0,
      points: 0, // 일기는 포인트 없음
      statIncreases: {'willpower': 0.1},
      message: '일기 작성 완료! 📝',
    );

    // 🔄 퀘스트 시스템과 연동
    _notifyQuestSystem('diary', {});

    _saveUserData();
  }

  /// 일기 기록 수정
  void updateDiaryLog(DiaryLog updatedLog) {
    final currentLogs = state.dailyRecords.diaryLogs;
    final updatedLogs = currentLogs.map((log) => 
      log.id == updatedLog.id ? updatedLog : log
    ).toList();

    final updatedRecords = state.dailyRecords.copyWith(
      diaryLogs: updatedLogs,
    );

    state = state.copyWith(dailyRecords: updatedRecords);
    
    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();
    
    _saveUserData();
  }

  /// 영화 기록 추가
  void addMovieLog(MovieLog movieLog) {
    final updatedRecords = state.dailyRecords.copyWith(
      movieLogs: [...state.dailyRecords.movieLogs, movieLog],
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // 보상 지급
    _handleActivityCompletion(
      activityType: 'movie',
      xp: 20.0 + (movieLog.watchTimeMinutes * 0.1),
      points: 0, // 영화는 포인트 없음
      statIncreases: {'knowledge': 0.05, 'willpower': 0.05},
      message: '영화 감상 완료! 🎬 ${movieLog.movieTitle}',
    );

    // 🔄 퀘스트 시스템과 연동
    _notifyQuestSystem('movie', {'title': movieLog.movieTitle, 'duration': movieLog.watchTimeMinutes});

    _saveUserData();
  }

  /// 일일 목표 완료 (실제 데이터 기반 자동 완료)
  void completeDailyGoal(String goalId) {
    // ✅ 실제 데이터 기반으로 완료 조건 검사
    if (!_checkGoalCompletionCondition(goalId)) {
      // 완료 조건을 만족하지 않으면 안내 메시지 표시
      _showGoalConditionMessage(goalId);
      return;
    }

    final updatedGoals = state.dailyRecords.dailyGoals.map((goal) {
      if (goal.id == goalId && !goal.isCompleted) {
        return goal.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return goal;
    }).toList();

    final updatedRecords = state.dailyRecords.copyWith(
      dailyGoals: updatedGoals,
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // 🔄 퀘스트 시스템에 일일 목표 완료 알림
    _notifyQuestSystem('daily_goal_completed', {'goalId': goalId});

    // 퀘스트 시스템에 즉시 동기화 (중복 수행 방지)
    _syncQuestWithGoalCompletion(goalId);

    // 전체 목표 완료 확인
    _checkAllGoalsCompleted(updatedGoals);

    _saveUserData();
  }

  /// 일일 목표 상태를 실제 데이터와 강제 동기화
  void syncDailyGoalsWithData() {
    _updateGoalStatusBasedOnActivity();
  }

  /// 목표 완료 조건 검사 (실제 데이터 기반)
  bool _checkGoalCompletionCondition(String goalId) {
    final records = state.dailyRecords;
    final today = DateTime.now();

    switch (goalId) {
      case 'steps':
      // 6000걸음 이상인지 검사
        return records.todaySteps >= 6000;

      case 'focus':
      // 30분 이상 집중했는지 검사
        return records.todayFocusMinutes >= 30;

      case 'diary':
      // 오늘 일기를 작성했는지 검사
        return records.diaryLogs.any((diary) => _isSameDay(diary.date, today));

      case 'exercise':
      // 오늘 운동 기록을 작성했는지 검사
        return records.exerciseLogs.any((exercise) => _isSameDay(exercise.date, today));

      case 'reading':
      // 오늘 독서 기록을 작성했는지 검사 (최소 1페이지)
        return records.readingLogs.any((reading) =>
        _isSameDay(reading.date, today) && reading.pages >= 1);

      default:
        return false;
    }
  }

  /// 목표 조건 미달성 시 안내 메시지
  void _showGoalConditionMessage(String goalId) {
    String message;

    switch (goalId) {
      case 'steps':
        final currentSteps = state.dailyRecords.todaySteps;
        final remaining = 6000 - currentSteps;
        message = '아직 ${remaining}걸음이 더 필요해요! 현재: ${currentSteps}걸음 👟';
        break;
      case 'focus':
        final currentMinutes = state.dailyRecords.todayFocusMinutes;
        final remaining = 30 - currentMinutes;
        message = '아직 ${remaining}분 더 집중해주세요! 현재: ${currentMinutes}분 ⏰';
        break;
      case 'diary':
        message = '오늘의 일기를 먼저 작성해주세요! 📝';
        break;
      case 'exercise':
        message = '오늘의 운동 기록을 먼저 작성해주세요! 💪';
        break;
      case 'reading':
        message = '오늘의 독서 기록을 먼저 작성해주세요! 📚';
        break;
      default:
        message = '먼저 해당 활동을 완료해주세요!';
    }

    // 셰르피 메시지로 안내
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: message,
      emotion: SherpiEmotion.encouraging,
    );
  }

  /// 실시간 목표 상태 업데이트 (활동 완료 시 자동 호출)
  void _updateGoalStatusBasedOnActivity() {
    final goals = state.dailyRecords.dailyGoals;
    bool hasUpdates = false;
    final completedGoals = <String>[];

    final updatedGoals = goals.map((goal) {
      if (!goal.isCompleted && _checkGoalCompletionCondition(goal.id)) {
        hasUpdates = true;
        completedGoals.add(goal.id);
        return goal.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return goal;
    }).toList();

    if (hasUpdates) {
      final updatedRecords = state.dailyRecords.copyWith(
        dailyGoals: updatedGoals,
      );

      state = state.copyWith(dailyRecords: updatedRecords);
      _checkAllGoalsCompleted(updatedGoals);
      _saveUserData();

      // 완료된 목표들을 퀘스트 시스템에 알림
      for (final goalId in completedGoals) {
        _notifyQuestSystem('daily_goal_completed', {'goalId': goalId});
      }

      // 자동 완료 알림
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.levelUp,
        customDialogue: '🎉 목표가 자동으로 완료되었어요!',
        emotion: SherpiEmotion.celebrating,
      );
    }
  }

  /// 모든 목표 완료 확인 및 보상
  void _checkAllGoalsCompleted(List<DailyGoal> goals) {
    final allCompleted = goals.every((goal) => goal.isCompleted);

    if (allCompleted && !state.dailyRecords.isAllGoalsRewardClaimed) {
      // 전체 완료 보상 준비 (아직 지급 안함)
      final updatedRecords = state.dailyRecords.copyWith(
        isAllGoalsCompleted: true,
      );

      state = state.copyWith(dailyRecords: updatedRecords);
      _saveUserData();
    }
  }

  /// 전체 목표 완료 보상 수령 (버튼 클릭 시)
  void claimAllGoalsReward() {
    final records = state.dailyRecords;

    // 이미 보상을 받았거나 모든 목표가 완료되지 않았다면 리턴
    if (records.isAllGoalsRewardClaimed || !records.isAllGoalsCompleted) {
      return;
    }

    // 통합된 포인트 시스템으로 일일 목표 완료 보너스 직접 지급
    ref.read(globalPointProvider.notifier).onDailyGoalAllClear();

    // 보상 지급 (XP와 능력치만)
    handleActivityCompletion(
      activityType: 'all_goals_reward',
      xp: 200.0,
      points: 0, // 포인트는 위에서 직접 지급
      statIncreases: {'willpower': 0.1},
      message: '🎉 모든 일일 목표 완료 보상! 대단해요!',
    );

    // 보상 수령 상태로 변경
    final updatedRecords = records.copyWith(
      isAllGoalsRewardClaimed: true,
    );

    state = state.copyWith(dailyRecords: updatedRecords);
    _saveUserData();
  }

  /// 통합 활동 완료 보상 처리 (모든 앱 활동에서 사용)
  void handleActivityCompletion({
    required String activityType,
    required double xp,
    required int points,
    required Map<String, double> statIncreases,
    required String message,
    Map<String, dynamic>? additionalData,
  }) {
    // 경험치 지급
    if (xp > 0) {
      addExperience(xp);
    }

    // 포인트 지급 (통합된 시스템 사용)
    if (points > 0) {
      // 활동 유형에 따른 세분화된 포인트 지급
      final pointSource = _getPointSourceFromActivity(activityType, additionalData);
      if (pointSource != null) {
        ref.read(globalPointProvider.notifier).earnPoints(
          points,
          pointSource,
          message,
        );
      } else {
        // 기본 포인트 지급 (레거시 호환)
        ref.read(globalPointProvider.notifier).addPoints(
          points,
          '활동 완료: $activityType',
        );
      }
    }

    // 능력치 증가
    if (statIncreases.isNotEmpty) {
      increaseStats(
        deltaStamina: statIncreases['stamina'] ?? 0,
        deltaKnowledge: statIncreases['knowledge'] ?? 0,
        deltaTechnique: statIncreases['technique'] ?? 0,
        deltaSociality: statIncreases['sociality'] ?? 0,
        deltaWillpower: statIncreases['willpower'] ?? 0,
      );
    }

    // 셰르피 피드백
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: message,
      emotion: SherpiEmotion.cheering,
    );
    
    // 🔄 퀘스트 시스템에 활동 알림
    _notifyQuestSystem(activityType, additionalData ?? {});

  }

  /// 활동 유형에서 포인트 소스로 매핑
  PointSource? _getPointSourceFromActivity(String activityType, Map<String, dynamic>? additionalData) {
    switch (activityType) {
      case 'meeting':
      case 'meeting_participant':
        return PointSource.meetingAttend;
      case 'meeting_host':
        return PointSource.meetingHost;
      case 'quest_easy':
      case 'quest_medium':
      case 'quest_hard':
        return PointSource.dailyQuestAd; // 임시로 일일 퀘스트로 매핑
      case 'all_goals_reward':
        return PointSource.dailyGoalAd;
      case 'challenge':
        return PointSource.streakBonus; // 임시로 연속 보너스로 매핑
      default:
        return null; // 기본 addPoints 사용
    }
  }

  /// 퀘스트 완료 보상
  void completeQuest({
    required String questId,
    required String questType,
    required String difficulty,
  }) {
    double xp = 0;
    int points = 0;
    Map<String, double> statIncreases = {};

    // 난이도별 보상 계산
    switch (difficulty) {
      case 'easy':
        xp = 50;
        points = 0;
        statIncreases = {'technique': 0.1};
        break;
      case 'medium':
        xp = 100;
        points = 0;
        statIncreases = {'technique': 0.2, 'willpower': 0.1};
        break;
      case 'hard':
        xp = 200;
        points = 100;
        statIncreases = {'technique': 0.3, 'willpower': 0.2};
        break;
    }

    handleActivityCompletion(
      activityType: 'quest_$difficulty',
      xp: xp,
      points: points,
      statIncreases: statIncreases,
      message: '퀘스트 완료! 🎯 계속 도전해보세요!',
      additionalData: {'questId': questId, 'questType': questType},
    );
  }

  /// 모임 참여 보상
  void completeMeeting({
    required String meetingId,
    required String meetingType,
    required bool isHost,
  }) {
    double xp = 80;
    Map<String, double> statIncreases = {
      'sociality': 0.3,
      'willpower': 0.1,
    };

    // 호스팅 보너스
    if (isHost) {
      xp += 50;
      statIncreases['sociality'] = (statIncreases['sociality'] ?? 0) + 0.2;

      // 통합된 포인트 시스템으로 호스팅 보너스 직접 지급
      ref.read(globalPointProvider.notifier).onMeetingHost();
    } else {
      // 통합된 포인트 시스템으로 참석 보너스 직접 지급
      ref.read(globalPointProvider.notifier).onMeetingAttend();
    }

    handleActivityCompletion(
      activityType: isHost ? 'meeting_host' : 'meeting_participant',
      xp: xp,
      points: 0, // 포인트는 위에서 직접 지급
      statIncreases: statIncreases,
      message: isHost ? '모임 호스팅 완료! 🎉 멋진 리더십이에요!' : '모임 참여 완료! 🤝 소중한 경험이었어요!',
      additionalData: {'meetingId': meetingId, 'meetingType': meetingType},
    );
  }

  /// 챌린지 완료 보상
  void completeChallenge({
    required String challengeId,
    required String challengeType,
    required int duration, // 일 수
  }) {
    double xp = duration * 20; // 일 수에 비례
    int points = duration * 10;
    Map<String, double> statIncreases = {
      'willpower': duration * 0.05,
      'technique': duration * 0.03,
    };

    handleActivityCompletion(
      activityType: 'challenge',
      xp: xp,
      points: points,
      statIncreases: statIncreases,
      message: '챌린지 완료! 🏆 ${duration}일간의 노력이 결실을 맺었어요!',
      additionalData: {'challengeId': challengeId, 'duration': duration},
    );
  }

  /// 레거시 메서드 (기존 호환성 유지)
  void _handleActivityCompletion({
    required String activityType,
    required double xp,
    required int points,
    required Map<String, double> statIncreases,
    required String message,
  }) {
    handleActivityCompletion(
      activityType: activityType,
      xp: xp,
      points: points,
      statIncreases: statIncreases,
      message: message,
    );
  }

  /// 🔄 퀘스트 시스템에 활동 알림 (최적화된 연동)
  void _notifyQuestSystem(String activityType, Map<String, dynamic> data) {
    try {
      // 비동기로 퀘스트 시스템 업데이트 (UI 블로킹 방지)
      Future.microtask(() {
        // V2에서는 자동 동기화되므로 수동 동기화 불필요
        // ref.read(questProviderV2.notifier).onGlobalActivityUpdate(activityType, data);
      });

      // 디버그 로그
    } catch (e) {
      // 오류가 발생해도 다른 시스템에는 영향 없도록 처리
    }
  }

  /// 퀘스트와 일일 목표 동기화 (즉시 실행)
  void _syncQuestWithGoalCompletion(String goalId) {
    try {
      // 목표 완료와 연결된 퀘스트를 즉시 동기화
      Future.microtask(() {
        // V2에서는 자동 동기화되므로 수동 동기화 불필요
        // ref.read(questProviderV2.notifier).onDailyGoalCompleted(goalId);
      });
    } catch (e) {
    }
  }

  /// 연속 접속일 업데이트
  void updateConsecutiveDays() {
    final today = DateTime.now();
    final lastActive = state.dailyRecords.lastActiveDate;

    int newConsecutiveDays;

    // 어제였다면 연속일 증가
    if (_isYesterday(lastActive, today)) {
      newConsecutiveDays = state.dailyRecords.consecutiveDays + 1;
    }
    // 오늘이라면 연속일 유지
    else if (_isToday(lastActive, today)) {
      newConsecutiveDays = state.dailyRecords.consecutiveDays;
    }
    // 그 외는 연속일 리셋
    else {
      newConsecutiveDays = 1;
    }

    final updatedRecords = state.dailyRecords.copyWith(
      consecutiveDays: newConsecutiveDays,
      lastActiveDate: today,
    );

    state = state.copyWith(dailyRecords: updatedRecords);
    _saveUserData();
  }

  bool _isToday(DateTime date, DateTime today) {
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isYesterday(DateTime date, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// 같은 날짜인지 확인 (목표 완료 조건 검사용)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    // 연속 접속일 업데이트
    updateConsecutiveDays();

    // 현재 등반 세션 상태 업데이트
    _updateClimbingSessionStatus();

    // 필요 시 추가 새로고침 로직
  }

  // ==================== 걸음수 히스토리 관리 ====================

  /// 일일 걸음수 데이터 저장
  Future<void> _saveDailySteps(DateTime date, int steps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await prefs.setInt('daily_steps_$dateKey', steps);
    } catch (e) {
    }
  }

  /// 14일간 걸음수 데이터 조회
  Future<List<DailyStepData>> get14DaysStepHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final stepHistory = <DailyStepData>[];

      // 2주치 샘플 데이터 (다양한 패턴으로 구성)
      final sampleSteps = [
        4200, 5800, 7200, 6100, 4500, 8900, 7500, // 첫째 주
        3800, 6500, 9200, 8100, 5200, 7800, 6900, // 둘째 주
      ];

      for (int i = 13; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        int steps;
        if (i == 0) {
          // 오늘은 현재 걸음수 사용
          steps = state.dailyRecords.todaySteps;
        } else {
          // 기존 저장된 데이터 확인
          steps = prefs.getInt('daily_steps_$dateKey') ?? 0;

          // 데이터가 없으면 샘플 데이터 사용
          if (steps == 0) {
            steps = sampleSteps[13 - i]; // 인덱스 매핑
            await prefs.setInt('daily_steps_$dateKey', steps); // 저장
          }
        }

        stepHistory.add(DailyStepData(
          date: date,
          steps: steps,
          goal: 6000,
        ));
      }

      return stepHistory;
    } catch (e) {
      return [];
    }
  }

}

// ==================== UI용 Provider들 ====================

/// UI용 경험치 진행 상태 Provider
final userLevelProgressProvider = Provider<UserLevelProgress>((ref) {
  final user = ref.watch(globalUserProvider);

  final totalExp = user.experience;
  final level = user.level;

  final totalExpForPreviousLevels = GameConstants.getTotalXpForLevel(level - 1);
  final currentLevelExp = totalExp - totalExpForPreviousLevels;
  final requiredExpForNextLevel = GameConstants.getRequiredXpForLevel(level);

  final progress = (requiredExpForNextLevel > 0)
      ? (currentLevelExp / requiredExpForNextLevel).clamp(0.0, 1.0)
      : 0.0;

  return UserLevelProgress(
    currentLevelExp: currentLevelExp.toInt(),
    requiredExpForNextLevel: requiredExpForNextLevel.toInt(),
    progress: progress,
  );
});

/// 오늘의 기록 Provider
final todayRecordProvider = Provider<TodayRecord>((ref) {
  final user = ref.watch(globalUserProvider);
  final records = user.dailyRecords;

  return TodayRecord(
    stepCount: records.todaySteps,
    focusMinutes: records.todayFocusMinutes,
    readingPages: records.todayReadingPages,
    completedGoalsCount: records.todayCompletedGoalsCount,
    completionRate: records.todayCompletionRate,
  );
});

/// 기록 통계 Provider
final recordStatisticsProvider = Provider<RecordStatistics>((ref) {
  final user = ref.watch(globalUserProvider);
  final records = user.dailyRecords;

  return RecordStatistics(
    streakDays: records.consecutiveDays,
    totalSteps: records.totalSteps,
    totalReadingPages: records.totalReadingPages,
    totalMeetings: records.totalMeetings,
    totalFocusMinutes: records.todayFocusMinutes, // 임시로 오늘의 집중시간 사용
  );
});

/// 월별 모임 기록 Provider
final meetingCalendarProvider = Provider.family<List<MeetingLog>, DateTime>((ref, month) {
  final user = ref.watch(globalUserProvider);
  final meetings = user.dailyRecords.meetingLogs;

  return meetings.where((meeting) {
    return meeting.date.year == month.year &&
        meeting.date.month == month.month;
  }).toList();
});

/// 월별 독서 기록 Provider
final readingCalendarProvider = Provider.family<List<ReadingLog>, DateTime>((ref, month) {
  final user = ref.watch(globalUserProvider);
  final readings = user.dailyRecords.readingLogs;

  return readings.where((reading) {
    return reading.date.year == month.year &&
        reading.date.month == month.month;
  }).toList();
});

/// 14일간 걸음수 히스토리 Provider
final stepHistoryProvider = FutureProvider<List<DailyStepData>>((ref) async {
  final userNotifier = ref.read(globalUserProvider.notifier);
  return await userNotifier.get14DaysStepHistory();
});

/// 걸음수 통계 Provider
final stepStatisticsProvider = FutureProvider<StepStatistics>((ref) async {
  try {
    final stepHistory = await ref.watch(stepHistoryProvider.future);

    if (stepHistory.isEmpty) {
      return const StepStatistics(
        weeklyAverage: 0,
        monthlyAverage: 0,
        totalSteps: 0,
        maxSteps: 0,
        avgSteps: 0,
        goalAchievedDays: 0,
        totalDays: 0,
        goalAchievementRate: 0,
      );
    }

    // 최근 7일 평균 (오늘 포함)
    final recent7Days = stepHistory.length >= 7
        ? stepHistory.sublist(stepHistory.length - 7)
        : stepHistory;
    final weeklyAverage = recent7Days.isNotEmpty
        ? recent7Days.map((d) => d.steps).reduce((a, b) => a + b) / recent7Days.length
        : 0.0;

    // 14일 전체 평균
    final avgSteps = stepHistory.map((d) => d.steps).reduce((a, b) => a + b) / stepHistory.length;

    // 14일 총 걸음수
    final totalSteps = stepHistory.map((d) => d.steps).reduce((a, b) => a + b);

    // 최고 걸음수
    final maxSteps = stepHistory.map((d) => d.steps).reduce((a, b) => a > b ? a : b);

    // 목표 달성일
    final goalAchievedDays = stepHistory.where((d) => d.isGoalAchieved).length;
    final totalDays = stepHistory.length;
    final goalAchievementRate = totalDays > 0 ? goalAchievedDays / totalDays : 0.0;

    return StepStatistics(
      weeklyAverage: weeklyAverage,
      monthlyAverage: avgSteps, // 14일 평균으로 대체
      totalSteps: totalSteps,
      maxSteps: maxSteps,
      avgSteps: avgSteps,
      goalAchievedDays: goalAchievedDays,
      totalDays: totalDays,
      goalAchievementRate: goalAchievementRate,
    );
  } catch (e) {
    return const StepStatistics(
      weeklyAverage: 0,
      monthlyAverage: 0,
      totalSteps: 0,
      maxSteps: 0,
      avgSteps: 0,
      goalAchievedDays: 0,
      totalDays: 0,
      goalAchievementRate: 0,
    );
  }
});

// ==================== 임시 모델들 (daily_record_screen.dart 호환용) ====================

class TodayRecord {
  final int stepCount;
  final int focusMinutes;
  final int readingPages;
  final int completedGoalsCount;
  final double completionRate;

  const TodayRecord({
    required this.stepCount,
    required this.focusMinutes,
    required this.readingPages,
    required this.completedGoalsCount,
    required this.completionRate,
  });
}

class RecordStatistics {
  final int streakDays;
  final int totalSteps;
  final int totalReadingPages;
  final int totalMeetings;
  final int totalFocusMinutes;

  const RecordStatistics({
    required this.streakDays,
    required this.totalSteps,
    required this.totalReadingPages,
    required this.totalMeetings,
    required this.totalFocusMinutes,
  });
}

/// 일일 걸음수 데이터 모델
class DailyStepData {
  final DateTime date;
  final int steps;
  final int goal;

  const DailyStepData({
    required this.date,
    required this.steps,
    required this.goal,
  });

  double get achievementRate => (steps / goal).clamp(0.0, 1.0);
  bool get isGoalAchieved => steps >= goal;
  int get calories => (steps * 0.04).round();
  double get distance => (steps * 0.0008); // km 단위

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'goal': goal,
    };
  }

  factory DailyStepData.fromJson(Map<String, dynamic> json) {
    return DailyStepData(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      steps: json['steps'] ?? 0,
      goal: json['goal'] ?? 6000,
    );
  }
}

/// 걸음수 통계 모델
class StepStatistics {
  final double weeklyAverage;
  final double monthlyAverage;
  final int totalSteps;
  final int maxSteps;
  final double avgSteps;
  final int goalAchievedDays;
  final int totalDays;
  final double goalAchievementRate;

  const StepStatistics({
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.totalSteps,
    required this.maxSteps,
    required this.avgSteps,
    required this.goalAchievedDays,
    required this.totalDays,
    required this.goalAchievementRate,
  });
}

// ==================== 등반 관련 Provider들 ====================

/// 현재 등반 세션 Provider
final currentClimbingSessionProvider = Provider<ClimbingSession?>((ref) {
  final user = ref.watch(globalUserProvider);
  return user.currentClimbingSession;
});

/// 등반 중 상태 Provider
final isCurrentlyClimbingProvider = Provider<bool>((ref) {
  final user = ref.watch(globalUserProvider);
  return user.currentClimbingSession?.isActive == true;
});

/// 등반 진행률 Provider
final climbingProgressProvider = Provider<double>((ref) {
  final session = ref.watch(currentClimbingSessionProvider);
  if (session == null || !session.isActive) return 0.0;
  return session.progress;
});

/// 등반 남은 시간 Provider
final climbingRemainingTimeProvider = Provider<Duration>((ref) {
  final session = ref.watch(currentClimbingSessionProvider);
  if (session == null || !session.isActive) return Duration.zero;
  return session.remainingTime;
});

/// 등반 기록 Provider
final climbingHistoryProvider = Provider<List<ClimbingRecord>>((ref) {
  final user = ref.watch(globalUserProvider);
  final logs = user.dailyRecords.climbingLogs;
  final sortedLogs = List<ClimbingRecord>.from(logs)
    ..sort((a, b) => b.startTime.compareTo(a.startTime));
  return sortedLogs;
});

/// 등반 통계 Provider
final climbingStatisticsProvider = Provider<ClimbingStatistics>((ref) {
  final user = ref.watch(globalUserProvider);
  return ClimbingStatistics.fromRecords(user.dailyRecords.climbingLogs);
});

/// 오늘의 등반 기록 Provider
final todayClimbingRecordsProvider = Provider<List<ClimbingRecord>>((ref) {
  final user = ref.watch(globalUserProvider);
  return user.dailyRecords.todayClimbingLogs;
});

/// 사용자 등반력 Provider (실제 뱃지 효과 적용)
final userClimbingPowerProvider = Provider<double>((ref) {
  final user = ref.watch(globalUserProvider);
  final gameSystem = ref.watch(globalGameProvider);
  final equippedBadges = ref.watch(globalEquippedBadgesProvider); // ✅ 실제 뱃지 사용

  return gameSystem.calculateFinalClimbingPower(
    level: user.level,
    titleBonus: gameSystem.getTitleBonus(user.level),
    stamina: user.stats.stamina,
    knowledge: user.stats.knowledge,
    technique: user.stats.technique,
    equippedBadges: equippedBadges, // ✅ 실제 뱃지 전달
// 기본값 (UI 표시용)
  );
});

/// 레벨별 추천 산 Provider
final recommendedMountainsProvider = Provider<List<dynamic>>((ref) {
  final user = ref.watch(globalUserProvider);
  final userPower = ref.watch(userClimbingPowerProvider);
  final gameSystem = ref.watch(globalGameProvider);

  return gameSystem.getRecommendedMountains(user.level, userPower);
});

/// 산 성공 확률 계산 Provider (실제 뱃지 효과 적용)
final mountainSuccessProbabilityProvider = Provider.family<double, dynamic>((ref, mountain) {
  final user = ref.watch(globalUserProvider);
  final gameSystem = ref.watch(globalGameProvider);
  final equippedBadges = ref.watch(globalEquippedBadgesProvider); // ✅ 실제 뱃지 사용

  // 산 레벨에 따른 등반력 계산 (고산 전문가 뱃지 고려)
  final userPower = gameSystem.calculateFinalClimbingPower(
    level: user.level,
    titleBonus: gameSystem.getTitleBonus(user.level),
    stamina: user.stats.stamina,
    knowledge: user.stats.knowledge,
    technique: user.stats.technique,
    equippedBadges: equippedBadges,

  );

  return gameSystem.calculateSuccessProbability(
    userPower: userPower,
    mountainPower: mountain.requiredPower,
    willpower: user.stats.willpower,
    equippedBadges: equippedBadges, // ✅ 실제 뱃지 전달
  );
});