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
import '../utils/calorie_calculator.dart';
import 'global_sherpi_provider.dart';
import '../../core/constants/sherpi_dialogues.dart';
import '../../core/constants/game_constants.dart';
import 'global_point_provider.dart';
import 'global_game_provider.dart';
import 'global_badge_provider.dart'; // 뱃지 Provider 추가
import '../../features/quests/providers/quest_provider_v2.dart'; // 퀘스트 Provider 추가
import 'notification_provider.dart'; // 알림 Provider 추가
import '../../core/ai/activity_analysis_service.dart'; // 활동 분석 서비스 추가

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

    // 샘플 목표 데이터 생성 (3개)
    final now = DateTime.now();
    final sampleGoals = [
      UserGoal(
        id: 'goal_001',
        title: '매일 일기 작성',
        description: '하루를 되돌아보며 감사 일기를 작성하기',
        category: 'habit',
        duration: 30, // 30일
        createdAt: now.subtract(const Duration(days: 7)),
        progress: 23.3, // 7일 진행 (23.3%)
        isActive: true,
      ),
      UserGoal(
        id: 'goal_002',
        title: '주 3회 달리기',
        description: '5km 달리기를 주 3회 이상 완주하기',
        category: 'health',
        duration: 60, // 60일
        createdAt: now.subtract(const Duration(days: 14)),
        progress: 35.0, // 14일 진행, 여러 번 달림
        isActive: true,
      ),
      UserGoal(
        id: 'goal_003',
        title: '오전 7시 기상',
        description: '매일 아침 7시에 일어나는 습관 만들기',
        category: 'habit',
        duration: 21, // 21일 (습관 형성)
        createdAt: now.subtract(const Duration(days: 10)),
        progress: 47.6, // 10일 진행 (47.6%)
        isActive: true,
      ),
    ];

    final user = GlobalUser(
      id: 'user_001',
      name: '박지호',
      profileImageUrl: null,
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
      planningData: UserPlanningData(
        goals: sampleGoals,
        completedGoals: [],
        totalGoalsCreated: 3,
        totalGoalsCompleted: 0,
        categoryStats: {
          'health': 1,
          'habit': 2,
        },
      ),
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

    // 🚫 레벨업 셰르피 메시지는 _triggerSherpiReaction에서 처리됨
    // 직접 호출하면 중복 메시지 발생 가능
    // ref.read(sherpiProvider.notifier).showMessage(
    //   context: SherpiContext.levelUp,
    //   emotion: SherpiEmotion.cheering,
    //   userContext: {
    //     'newLevel': newLevel,
    //     'oldLevel': oldLevel,
    //   },
    // );
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
  
  /// 사용자 이름 업데이트
  void updateUserName(String newName) {
    if (newName.trim().isNotEmpty) {
      state = state.copyWith(name: newName.trim());
      _saveUserData();
    }
  }
  
  /// 프로필 이미지 업데이트
  void updateProfileImage(String? imageUrl) {
    // null을 빈 문자열로 변환하여 copyWith가 확실히 값을 업데이트하도록 함
    state = state.copyWith(profileImageUrl: imageUrl ?? '');
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

    // 등반 시작 시에는 셰르피 메시지 없음

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
      failureReason: null,
    );

    // 오늘의 첫 등반 성공인지 확인 (새 기록 추가 전에 확인)
    if (isSuccess) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // 오늘의 등반 기록 중 성공한 기록이 있는지 확인 (현재 state 기준)
      final todaySuccessfulClimbs = state.dailyRecords.climbingLogs.where((log) {
        return log.startTime.isAfter(todayStart) && 
               log.isSuccess;
      }).toList();
      
      // 현재 등반이 오늘의 첫 성공이면 알림 생성
      if (todaySuccessfulClimbs.isEmpty) {
        ref.read(notificationProvider.notifier).notifyFirstClimb(
          session.mountainName,
          xp: rewards.experience.toInt(),  // 실제 경험치
          points: rewards.points,  // 실제 포인트
        );
      }
    }

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

    // 🎯 퀘스트 시스템 즉시 업데이트 (등반 성공하기 퀘스트 처리)
    // 등반 완료 후 바로 퀘스트 진행률을 체크하도록 트리거
    print('⛰️ [GlobalUser] 등반 완료: ${session.mountainName}');
    print('⛰️ [GlobalUser] 등반 성공 여부: $isSuccess');
    print('⛰️ [GlobalUser] 등반 기록 추가됨 - 총 ${updatedClimbingLogs.length}개 기록');
    
    // 데이터 저장을 먼저 완료
    _saveUserData();
    
    // 등반 성공 시 퀘스트 시스템 업데이트
    if (isSuccess) {
      print('✅ [GlobalUser] 등반 성공! 퀘스트 시스템 업데이트 요청');
      // 퀘스트 시스템에 등반 성공을 알림 - state가 완전히 업데이트된 후 실행
      Future.microtask(() async {
        // state 업데이트가 완전히 적용되도록 더 긴 지연 시간 적용
        await Future.delayed(const Duration(seconds: 1));
        print('🔄 [GlobalUser] 퀘스트 시스템 동기화 시작');
        
        // 현재 상태를 직접 체크
        final currentUser = ref.read(globalUserProvider);
        final todayClimbingSuccess = currentUser.dailyRecords.climbingLogs
            .where((log) {
              final today = DateTime.now();
              return log.startTime.year == today.year &&
                     log.startTime.month == today.month &&
                     log.startTime.day == today.day &&
                     log.isSuccess;
            }).isNotEmpty;
        
        print('🔍 [GlobalUser] 오늘 등반 성공 기록 확인: $todayClimbingSuccess');
        
        // 퀘스트 동기화
        await ref.read(questProviderV2.notifier).syncWithGlobalData();
        print('✅ [GlobalUser] 퀘스트 시스템 동기화 완료');
      });
    }
    
    // 셀르피 결과 메시지
    // 성공 시에는 성공 메시지를 직접 표시, 실패 시에는 sherpi_dialogues에서 랜덤 선택
    if (isSuccess) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.climbingSuccess,
        customDialogue: '등반 성공!\n' + rewards.summaryText,
        emotion: SherpiEmotion.cheering,
      );
    } else {
      // 실패 시: sherpi_dialogues.dart의 메시지 중 랜덤 선택 + 보상 요약
      final failureMessages = sherpiDialogues[SherpiContext.climbingFailure] ?? [];
      final randomMessage = failureMessages.isNotEmpty 
          ? failureMessages[math.Random().nextInt(failureMessages.length)]
          : '아쉽지만 실패했습니다';
      
      // 보상 요약이 있을 때만 추가
      final summaryText = rewards.summaryText;
      final messageToShow = summaryText.isNotEmpty 
          ? randomMessage + '\n' + summaryText
          : randomMessage;
      
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.climbingFailure,
        customDialogue: messageToShow,
        emotion: SherpiEmotion.happy,
      );
    }
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
      // 실패 시 보상 (성공 시의 25%)
      // playerLevel을 전달하지 않으면 레벨 1로 계산되어 경험치가 너무 작아짐
      final failXp = GameConstants.calculateFailureXp(
        difficulty, 
        durationHours, 
        playerLevel: state.level,
      );
      
      experience = failXp;
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

  /// 걸음수 업데이트 (자동 달성 지표 - 셰르피 메시지 없음)
  void updateSteps(int steps) {
    final updatedRecords = state.dailyRecords.copyWith(
      todaySteps: steps,
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // 히스토리에 저장
    _saveDailySteps(DateTime.now(), steps);

    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();

    // 🚫 자동 달성 지표이므로 퀘스트 시스템 연동 제거 (셰르피 메시지 방지)
    // _notifyQuestSystem('steps', {'steps': steps});

    _saveUserData();
  }

  /// 집중 시간 업데이트 (중간 업데이트는 조용히 처리)
  void updateFocusTime(int minutes) {
    final currentFocusMinutes = state.dailyRecords.todayFocusMinutes;
    final updatedRecords = state.dailyRecords.copyWith(
      todayFocusMinutes: currentFocusMinutes + minutes,
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();

    // 🚫 집중 시간 중간 업데이트는 조용히 처리 (완료시에만 메시지)
    // _notifyQuestSystem('focus', {
    //   'minutes': minutes,
    //   'totalMinutes': currentFocusMinutes + minutes,
    //   'dailyRecords.todayFocusMinutes': currentFocusMinutes + minutes,
    // });

    _saveUserData();
  }

  /// 모임 기록 추가
  void addMeetingLog(MeetingLog meetingLog) {
    final updatedRecords = state.dailyRecords.copyWith(
      meetingLogs: [...state.dailyRecords.meetingLogs, meetingLog],
    );

    state = state.copyWith(dailyRecords: updatedRecords);

    // 기록 작성 자체로는 보상 없음 - 퀘스트/목표 달성 시에만 보상

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

    // 🎯 셰르피 메시지만 표시 (보상 없음)
    _triggerSherpiReaction(
      'reading',
      '독서 기록 완료! 📚',
      0.0,  // 경험치 없음
      0,    // 포인트 없음
      {
        'bookTitle': readingLog.bookTitle,
        'pages': readingLog.pages,
        'rating': readingLog.rating,
        'category': readingLog.category,  // 카테고리 정보 추가
      },
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

    // 칼로리 계산 (기존 로직 활용)
    final calories = CalorieCalculator.calculateCalories(
      exerciseType: exerciseLog.exerciseType,
      durationMinutes: exerciseLog.durationMinutes,
      intensity: exerciseLog.intensity,
    );

    // 🎯 셰르피 메시지 표시 (보상 없음) - handleActivityCompletion이 주석 처리되어 여기서 직접 호출
    _triggerSherpiReaction(
      'exercise',
      '운동 기록 완료! 💪',
      0.0,  // 경험치 없음
      0,    // 포인트 없음
      {
        'exerciseType': exerciseLog.exerciseType,
        'duration': exerciseLog.durationMinutes,
        'difficulty': exerciseLog.intensity,  // difficulty로 전달 (intensity -> difficulty 매핑)
        'calories': calories,  // 계산된 칼로리 정보
        'intensity': exerciseLog.intensity,  // 원본 intensity도 유지
      },
    );

    // 🔄 퀘스트 시스템과 연동
    _notifyQuestSystem('exercise', {'duration': exerciseLog.durationMinutes});

    _saveUserData();
  }

  /// 운동 기록 수정
  Future<void> updateExerciseRecord(ExerciseLog updatedLog) async {
    final currentLogs = state.dailyRecords.exerciseLogs;
    final updatedLogs = currentLogs.map((log) => 
      log.id == updatedLog.id ? updatedLog : log
    ).toList();

    final updatedRecords = state.dailyRecords.copyWith(
      exerciseLogs: updatedLogs,
    );

    state = state.copyWith(dailyRecords: updatedRecords);
    
    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();
    
    _saveUserData();
  }

  /// 운동 기록 삭제
  Future<void> deleteExerciseRecord(String exerciseId) async {
    final currentLogs = state.dailyRecords.exerciseLogs;
    final updatedLogs = currentLogs.where((log) => log.id != exerciseId).toList();

    final updatedRecords = state.dailyRecords.copyWith(
      exerciseLogs: updatedLogs,
    );

    state = state.copyWith(dailyRecords: updatedRecords);
    
    // ✅ 실시간 목표 상태 업데이트
    _updateGoalStatusBasedOnActivity();
    
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

    // 🎯 셰르피 메시지만 표시 (보상 없음)
    _triggerSherpiReaction(
      'diary',
      '일기 작성 완료! 📝',
      0.0,  // 경험치 없음
      0,    // 포인트 없음
      {
        'mood': diaryLog.mood,
        'content': diaryLog.content,
      },
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

    // 기록 작성 자체로는 보상 없음 - 퀘스트/목표 달성 시에만 보상

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
      emotion: SherpiEmotion.happy,
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

      // 자동 완료 알림 제거 - 개별 목표별로 정해진 메시지가 있음
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
    final today = DateTime.now();

    // 이미 보상을 받았다면 리턴
    if (records.isAllGoalsRewardClaimed) {
      return;
    }

    // 실제 데이터 기반으로 목표 완료 상태 확인
    int actuallyCompletedCount = 0;
    if (records.todaySteps >= 6000) actuallyCompletedCount++;
    if (records.todayFocusMinutes >= 30) actuallyCompletedCount++;
    if (records.readingLogs.any((log) => 
      log.date.year == today.year && 
      log.date.month == today.month && 
      log.date.day == today.day && 
      log.pages >= 1)) actuallyCompletedCount++;
    if (records.diaryLogs.any((log) => 
      log.date.year == today.year && 
      log.date.month == today.month && 
      log.date.day == today.day)) actuallyCompletedCount++;
    if (records.exerciseLogs.any((log) => 
      log.date.year == today.year && 
      log.date.month == today.month && 
      log.date.day == today.day)) actuallyCompletedCount++;
    
    // 모든 목표(5개)가 완료되지 않았다면 리턴
    if (actuallyCompletedCount < 5) {
      return;
    }

    // 통합된 포인트 시스템으로 일일 목표 완료 보너스 직접 지급
    final bonusPoints = ref.read(globalPointProvider.notifier).onDailyGoalAllClear();

    // ✅ 먼저 보상 수령 상태로 변경 및 오늘 날짜를 전체 클리어 보상 받은 날짜 리스트에 추가
    final updatedClaimedDates = [...records.allGoalsRewardClaimedDates];
    final todayDate = DateTime(today.year, today.month, today.day); // 시간 정보 제거한 날짜만
    
    // 중복 방지: 이미 오늘 날짜가 있는지 확인
    if (!updatedClaimedDates.any((date) => 
        date.year == todayDate.year && 
        date.month == todayDate.month && 
        date.day == todayDate.day)) {
      updatedClaimedDates.add(todayDate);
    }
    
    final updatedRecords = records.copyWith(
      isAllGoalsCompleted: true,  // 실제 데이터 기반으로 확인했으므로 true로 설정
      isAllGoalsRewardClaimed: true,
      allGoalsRewardClaimedDates: updatedClaimedDates, // ✅ 보상 받은 날짜 리스트 업데이트
    );

    state = state.copyWith(dailyRecords: updatedRecords);
    _saveUserData();

    // 오늘의 목표 완료 알림 생성
    ref.read(notificationProvider.notifier).notifyGoalComplete(
      '오늘의 목표 전체 완료',
      xp: 200,  // 실제 XP 보상
      points: bonusPoints,  // 실제 포인트 보상 (50P)
    );

    // 달성한 목표 리스트 구성
    final completedGoals = updatedRecords.dailyGoals.where((g) => g.isCompleted).toList();
    final goalDetails = {
      'totalGoals': completedGoals.length,
      'goalList': completedGoals.map((g) => g.title).toList(),
      'bonusPoints': bonusPoints,
      'consecutiveDays': updatedRecords.consecutiveDays,
    };

    // 보상 지급 (XP와 능력치만) - 상태 업데이트 후에 호출
    handleActivityCompletion(
      activityType: 'all_goals_reward',
      xp: 200.0,
      points: 0, // 포인트는 위에서 직접 지급
      statIncreases: {'willpower': 0.1},
      message: '🎉 모든 일일 목표 완료 보상! 대단해요!',
      additionalData: goalDetails, // 목표 상세 정보 전달
    );
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

    // 🎭 활동 유형별 셰르피 반응 (climbing은 provider에서 직접 처리함)
    if (activityType != 'climbing') {
      _triggerSherpiReaction(activityType, message, xp, points, additionalData);
    }
    
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
  /// DEPRECATED: 이중 호출 방지를 위해 제거됨
  /// 모든 코드에서 handleActivityCompletion을 직접 호출하도록 변경
  void _handleActivityCompletion({
    required String activityType,
    required double xp,
    required int points,
    required Map<String, double> statIncreases,
    required String message,
  }) {
    // 이중 호출 방지: 더 이상 handleActivityCompletion을 호출하지 않음
    // 대신 각 활동별로 직접 handleActivityCompletion을 호출하도록 수정 필요
    // _handleActivityCompletion은 deprecated됨. handleActivityCompletion을 직접 사용하세요.
  }

  /// 🔄 퀘스트 시스템에 활동 알림 (최적화된 연동)
  void _notifyQuestSystem(String activityType, Map<String, dynamic> data) {
    try {
      // 비동기로 퀘스트 시스템 업데이트 (UI 블로킹 방지)
      Future.microtask(() async {
        // 즉시 퀘스트 시스템 동기화 실행
        await ref.read(questProviderV2.notifier).syncWithGlobalData();
      });
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

  /// 🎭 활동 유형별 셰르피 반응 트리거 (Phase 2: 빠른 응답 자동 표시 포함)
  void _triggerSherpiReaction(
    String activityType, 
    String message, 
    double xp, 
    int points, 
    Map<String, dynamic>? additionalData,
  ) {
    SherpiContext context;
    SherpiEmotion? emotion;
    String? customMessage;

    // 활동 유형별 셰르피 반응 설정
    switch (activityType) {
      // 📚 독서 완료
      case 'reading':
        context = SherpiContext.readingComplete;
        emotion = SherpiEmotion.thinking;  // 독서는 thinking 감정이 적절
        break;
        
      // 💪 운동 완료
      case 'exercise':
        context = SherpiContext.exerciseComplete;
        emotion = SherpiEmotion.surprised;
        break;
        
      // 📝 일기 작성
      case 'diary':
        context = SherpiContext.diaryWritten;
        emotion = SherpiEmotion.guiding;  // 일기 작성 시 guiding 감정
        break;
        
      // 🎯 퀘스트 완료 (단순 탭 방문 퀘스트 제외)
      case String() when activityType.startsWith('quest_'):
        // 탭 방문이나 단순 조회 퀘스트는 셰르피 메시지 없음
        final questType = additionalData?['questType'] as String? ?? '';
        final questDescription = additionalData?['description'] as String? ?? '';
        
        if (questType.contains('tabVisit') || 
            questDescription.contains('확인') || 
            questDescription.contains('둘러보기') ||
            questDescription.contains('현황') ||
            questDescription.contains('진행상황')) {
          // 단순 조회/방문 퀘스트는 조용히 처리
          return; // 셰르피 메시지 없이 종료
        }
        
        context = SherpiContext.questComplete;
        emotion = SherpiEmotion.cheering;
        break;
        
      // 🏔️ 등반 관련 - 더 이상 사용하지 않음 (GlobalClimbingProvider에서 직접 처리)
      case 'climbing':
        // climbing은 handleActivityCompletion에서 제외되므로 이 코드는 실행되지 않음
        return;
        
      // 🤝 모임 관련
      case 'meeting_host':
      case 'meeting_participant':
      case 'meeting_review':
        context = SherpiContext.meetingJoined;
        emotion = SherpiEmotion.happy;
        // 모임 후기 작성인 경우 특별 메시지
        if (activityType == 'meeting_review') {
          customMessage = '모임 후기 작성 완료! ⭐ 소중한 경험을 공유해주셔서 감사해요!';
        }
        break;
        
      // 🏆 챌린지 및 특별 성취
      case 'challenge':
        context = SherpiContext.achievement;
        emotion = SherpiEmotion.special;
        break;
        
      // 🎊 일일 목표 전체 달성 - 가장 특별한 성취!
      case 'all_goals_reward':
        context = SherpiContext.allGoalsComplete;
        emotion = SherpiEmotion.special;
        break;
        
      // 🎉 높은 경험치 획득 (레벨업이 아닌 경우) - 메시지 비활성화
      case String() when xp >= 100:
        // achievement 메시지가 나오지 않도록 기본 격려로 변경
        context = SherpiContext.encouragement;
        emotion = SherpiEmotion.cheering;
        customMessage = '대단해요! 🎉 ${xp.toInt()} 경험치를 획득했어요!';
        break;
        
      // 🌟 높은 포인트 획득 - 메시지 비활성화  
      case String() when points >= 100:
        // achievement 메시지가 나오지 않도록 기본 격려로 변경
        context = SherpiContext.encouragement;
        emotion = SherpiEmotion.special;
        customMessage = '대박 포인트 획득! ✨ ${points}P를 얻었어요!';
        break;
        
      // 기본 격려
      default:
        context = SherpiContext.encouragement;
        emotion = SherpiEmotion.cheering;
    }

    // 레벨업 감지 제거 - addExperience에서 이미 처리함
    // 레벨업 메시지는 _handleLevelUp에서 직접 처리되므로 여기서는 불필요

    // 🎯 Phase 2: 활동별 상세 데이터 준비
    final enrichedUserContext = <String, dynamic>{
      'activityType': activityType,
      'xp': xp.toInt(),
      'points': points,
      'level': state.level,
    };
    
    // 활동별 추가 데이터 포함
    if (additionalData != null) {
      enrichedUserContext.addAll(additionalData);
    }
    
    // 활동 유형별 특별 데이터 추가
    switch (activityType) {
      case 'exercise':
        enrichedUserContext['exerciseType'] = additionalData?['exerciseType'] ?? 'general';
        enrichedUserContext['duration'] = additionalData?['duration'] ?? 30;
        enrichedUserContext['difficulty'] = additionalData?['difficulty'] ?? 'moderate';
        enrichedUserContext['calories'] = additionalData?['calories'] ?? 0;
        print('[DEBUG] Exercise data in handleActivityCompletion:');
        print('  exerciseType: ${enrichedUserContext['exerciseType']}');
        print('  duration: ${enrichedUserContext['duration']}');
        print('  difficulty: ${enrichedUserContext['difficulty']}');
        print('  calories: ${enrichedUserContext['calories']}');
        break;
      case 'reading':
        enrichedUserContext['bookTitle'] = additionalData?['bookTitle'] ?? 'Unknown Book';
        enrichedUserContext['pages'] = additionalData?['pages'] ?? 10;
        enrichedUserContext['rating'] = additionalData?['rating'];
        enrichedUserContext['category'] = additionalData?['category'] ?? '기타';  // 카테고리 추가
        break;
      case 'diary':
        enrichedUserContext['mood'] = additionalData?['mood'] ?? 'normal';
        enrichedUserContext['content'] = additionalData?['content'] ?? '';
        break;
      case String() when activityType.startsWith('quest_'):
        enrichedUserContext['questName'] = additionalData?['questName'] ?? 'Quest';
        enrichedUserContext['questType'] = additionalData?['questType'] ?? 'daily';
        enrichedUserContext['difficulty'] = additionalData?['difficulty'] ?? 'normal';
        enrichedUserContext['rewardPoints'] = points;
        break;
    }
    
    // 🎯 백그라운드 활동 분석 생성 (운동, 독서, 일기)
    _triggerBackgroundAnalysis(activityType, enrichedUserContext);
    
    // 셰르피 메시지 표시 + 빠른 응답 자동 트리거
    Future.delayed(const Duration(milliseconds: 500), () {
      // all_goals_reward는 특별 처리 - 정적 메시지 사용
      if (activityType == 'all_goals_reward') {
        // sherpi_dialogues에서 정적 메시지 직접 가져오기
        const allGoalsMessage = '''🎊 축하드려요! 오늘의 모든 목표를 완벽하게 달성하셨네요! 🏆

✅ 6000걸음 걷기 완료
✅ 일기 작성 완료
✅ 운동 기록 완료
✅ 독서 1페이지 이상 완료
✅ 몰입 시간 달성

🎁 보상: 200 경험치 + 보너스 포인트 + 의지력 0.1 증가!

정말 대단한 하루였어요! 이런 꾸준함이 큰 변화를 만들어냅니다! 💪✨''';
        
        ref.read(sherpiProvider.notifier).showInstantMessage(
          context: context,  // SherpiContext.allGoalsComplete
          customDialogue: allGoalsMessage,
          emotion: emotion,  // SherpiEmotion.special
          duration: const Duration(seconds: 8),
        );
      } else if (customMessage != null) {
        // 레벨업이나 특별 상황: 커스텀 메시지 표시
        ref.read(sherpiProvider.notifier).showInstantMessage(
          context: context,
          customDialogue: customMessage!,
          emotion: emotion,
          duration: const Duration(seconds: 5),
        );
      } else {
        // 일반 활동 완료: Phase 2 강화된 데이터로 AI 메시지 표시
        ref.read(sherpiProvider.notifier).showMessage(
          context: context,
          emotion: emotion,
          duration: const Duration(seconds: 4),
          userContext: enrichedUserContext,
          gameContext: {
            'consecutiveDays': state.dailyRecords.consecutiveDays,
            'totalActivities': _getTotalActivitiesCount(),
            'currentStreak': _getCurrentStreak(),
          },
        );
      }

    });
  }





  /// 총 활동 수 계산
  int _getTotalActivitiesCount() {
    final records = state.dailyRecords;
    return records.exerciseLogs.length + 
           records.readingLogs.length + 
           records.diaryLogs.length + 
           records.climbingLogs.length +
           records.meetingLogs.length;
  }

  /// 현재 연속 기록 계산
  int _getCurrentStreak() {
    return state.dailyRecords.consecutiveDays;
  }

  /// 백그라운드 활동 분석 트리거
  Future<void> _triggerBackgroundAnalysis(String activityType, Map<String, dynamic> userContext) async {
    // 운동, 독서, 일기 활동에 대해서만 분석 생성
    if (!['exercise', 'reading', 'diary'].contains(activityType)) {
      return;
    }

    try {
      final analysisService = ActivityAnalysisService.instance;
      final userName = state.name;
      final records = state.dailyRecords;
      final today = DateTime.now();
      
      // 오늘의 활동 데이터 찾기
      ExerciseLog? todayExercise;
      ReadingLog? todayReading;
      DiaryLog? todayDiary;
      
      // 오늘 운동 기록 찾기
      for (final log in records.exerciseLogs) {
        if (_isSameDay(log.date, today)) {
          todayExercise = log;
          break;
        }
      }
      
      // 오늘 독서 기록 찾기
      for (final log in records.readingLogs) {
        if (_isSameDay(log.date, today)) {
          todayReading = log;
          break;
        }
      }
      
      // 오늘 일기 기록 찾기
      for (final log in records.diaryLogs) {
        if (_isSameDay(log.date, today)) {
          todayDiary = log;
          break;
        }
      }
      
      // 각 활동 타입에 따라 분석 생성 (백그라운드)
      switch (activityType) {
        case 'exercise':
          if (todayExercise != null) {
            // 이전 운동 기록 찾기 (최근 7일 이내)
            final previousExercise = _findPreviousActivity('exercise');
            
            // caloriesBurned 계산 (임시 - 실제로는 다른 곳에서 계산됨)
            final calories = _calculateCalories(
              todayExercise.durationMinutes, 
              todayExercise.intensity
            );
            
            final exerciseData = {
              'type': todayExercise.exerciseType,
              'duration': todayExercise.durationMinutes,
              'intensity': todayExercise.intensity,
              'calories': calories,
            };
            
            // 백그라운드에서 분석 생성
            // 0. 기존 운동 분석 캐시 삭제 (새로운 기록이므로)
            await analysisService.clearTodayExerciseCache();
            
            // 종합 운동 분석 생성 (운동 완료 시점에 미리 생성)
            // await를 사용하여 API 응답을 기다림
            try {
              final analysis = await analysisService.analyzeExerciseComprehensive(
                todayExercise: exerciseData,
                previousExercise: previousExercise,
                userName: userName,
                forceRegenerate: true,  // 강제로 새로 생성 (캐시 무시)
              );
              
              // 🔍 디버그: 캐시 저장 확인
              print('===== 운동 분석 캐시 저장 완료 =====');
              print('📊 섹션 1 - 비교: ${analysis.comparison}');
              print('📊 섹션 2 - 효과: ${analysis.benefits}');
              print('📊 섹션 3 - 추천: ${analysis.recommendation}');
              print('📊 섹션 4 - 응원: ${analysis.encouragement}');
              print('=====================================');
            } catch (e) {
              print('❌ 운동 분석 생성 실패: $e');
            }
          }
          break;
          
        case 'reading':
          if (todayReading != null) {
            // 이전 독서 기록 찾기 (최근 7일 이내)
            final previousReading = _findPreviousActivity('reading');
            
            final readingData = {
              'title': todayReading.bookTitle,
              'category': todayReading.category,
              'pagesRead': todayReading.pages,
              'rating': todayReading.rating ?? 0,
              'memo': todayReading.note ?? '',
            };
            
            // 백그라운드에서 분석 생성
            // 종합 독서 분석 생성 (독서 완료 시점에 미리 생성)
            // forceRegenerate: true가 캐시를 무시하고 새로 생성하므로 별도 캐시 삭제 불필요
            
            // 전체 독서 기록을 Map 형태로 변환
            final allReadingLogs = state.dailyRecords.readingLogs.map((log) => {
              'title': log.bookTitle,
              'category': log.category,
              'pagesRead': log.pages,
              'rating': log.rating,
              'date': log.date.toIso8601String(),
            }).toList();
            
            try {
              final analysis = await analysisService.analyzeReadingComprehensive(
                todayReading: readingData,
                previousReading: previousReading,
                userName: userName,
                allReadingLogs: allReadingLogs,  // 전체 독서 기록 전달
                forceRegenerate: true,  // 강제로 새로 생성 (캐시 무시)
              );
              
              // 🔍 디버그: 캐시 저장 확인
              print('===== 독서 분석 캐시 저장 완료 =====');
              print('📊 섹션 1 - 이전 책 인사이트: ${analysis.previousInsight}');
              print('📊 섹션 2 - 오늘 책 인사이트: ${analysis.todayInsight}');
              print('📊 섹션 3 - 여정 응원: ${analysis.journeyEncouragement}');
              print('📊 섹션 4 - 추천 도서: ${analysis.recommendations.length}권');
              print('=====================================');
            } catch (e) {
              print('❌ 독서 분석 생성 실패: $e');
            }
          }
          break;
          
        case 'diary':
          if (todayDiary != null) {
            // 이전 일기 감정 찾기 (최근 7일 이내)
            final previousDiary = _findPreviousDiary();
            
            // 최근 7일간 감정 기록 수집 (List<String> 형태로)
            final recentMoodHistory = <String>[];
            final today = DateTime.now();
            for (int i = 0; i < 7; i++) {
              final targetDate = today.subtract(Duration(days: i));
              final diary = state.dailyRecords.diaryLogs.where((log) {
                return _isSameDay(log.date, targetDate);
              }).firstOrNull;
              
              if (diary != null) {
                recentMoodHistory.add(diary.mood);
              }
            }
            
            // 백그라운드에서 분석 생성
            // 캐시 삭제 후 새로 생성
            await analysisService.clearComprehensiveDiaryCache();
            
            try {
              final analysis = await analysisService.analyzeDiaryComprehensive(
                currentMood: todayDiary.mood,
                previousMood: previousDiary?.mood,
                userName: userName,
                recentMoodHistory: recentMoodHistory,
                forceRegenerate: true,  // 강제로 새로 생성 (캐시 무시)
              );
              
              // 🔍 디버그: 캐시 저장 확인
              print('===== 일기 분석 캐시 저장 완료 =====');
              print('📊 섹션 1 - 감정 전환: ${analysis.emotionTransition}');
              print('📊 섹션 2 - 감정적 지지: ${analysis.emotionalSupport}');
              print('📊 섹션 3 - 실질적 조언: ${analysis.practicalAdvice}');
              print('📊 섹션 4 - 내일의 희망: ${analysis.tomorrowHope}');
              print('=====================================');
            } catch (e) {
              print('❌ 일기 분석 생성 실패: $e');
            }
          }
          break;
      }
      
      // 종합 AI 분석 제거됨 - 리소스 최적화
      
    } catch (e) {
      print('❌ 백그라운드 분석 트리거 실패: $e');
    }
  }
  
  /// 칼로리 계산 헬퍼 메서드
  int _calculateCalories(int durationMinutes, String intensity) {
    // 강도별 분당 칼로리 소모량
    final caloriesPerMinute = switch (intensity) {
      '낮음' => 3,
      '중간' => 5,
      '높음' => 8,
      _ => 5,
    };
    return durationMinutes * caloriesPerMinute;
  }

  /// 이전 활동 기록 찾기 (최근 7일 이내)
  Map<String, dynamic>? _findPreviousActivity(String activityType) {
    final records = state.dailyRecords;
    final today = DateTime.now();
    
    switch (activityType) {
      case 'exercise':
        // 최근 7일 이내의 운동 기록 찾기
        for (int i = 1; i <= 7; i++) {
          final targetDate = today.subtract(Duration(days: i));
          final log = records.exerciseLogs.where((log) {
            return _isSameDay(log.date, targetDate);
          }).firstOrNull;
          
          if (log != null) {
            final calories = _calculateCalories(
              log.durationMinutes, 
              log.intensity
            );
            
            return {
              'type': log.exerciseType,
              'duration': log.durationMinutes,
              'intensity': log.intensity,
              'calories': calories,
              'date': log.date.toIso8601String(),
            };
          }
        }
        break;
        
      case 'reading':
        // 최근 7일 이내의 독서 기록 찾기
        for (int i = 1; i <= 7; i++) {
          final targetDate = today.subtract(Duration(days: i));
          final log = records.readingLogs.where((log) {
            return _isSameDay(log.date, targetDate);
          }).firstOrNull;
          
          if (log != null) {
            return {
              'title': log.bookTitle,
              'pages': log.pages,
              'category': log.category,
              'rating': log.rating,
              'date': log.date.toIso8601String(),
            };
          }
        }
        break;
        
      case 'diary':
        // 최근 7일 이내의 일기 기록 찾기
        for (int i = 1; i <= 7; i++) {
          final targetDate = today.subtract(Duration(days: i));
          final log = records.diaryLogs.where((log) {
            return _isSameDay(log.date, targetDate);
          }).firstOrNull;
          
          if (log != null) {
            return {
              'mood': log.mood,
              'content': log.content,
              'date': log.date.toIso8601String(),
            };
          }
        }
        break;
    }
    
    return null;
  }

  /// 이전 일기 찾기 (최근 7일 이내)
  DiaryLog? _findPreviousDiary() {
    final records = state.dailyRecords;
    final today = DateTime.now();
    
    // 오늘을 제외하고 최근 7일 이내의 일기 찾기
    for (int i = 1; i <= 7; i++) {
      final targetDate = today.subtract(Duration(days: i));
      final diary = records.diaryLogs.where((log) {
        return _isSameDay(log.date, targetDate);
      }).firstOrNull;
      
      if (diary != null) {
        return diary;
      }
    }
    
    return null;
  }
  
  /// 최근 감정 히스토리 가져오기
  Map<String, int> _getRecentMoodHistory(int days) {
    final records = state.dailyRecords;
    final today = DateTime.now();
    final moodCount = <String, int>{};
    
    // 오늘을 포함하여 최근 N일간의 감정 수집
    for (int i = 0; i < days; i++) {
      final targetDate = today.subtract(Duration(days: i));
      final diary = records.diaryLogs.where((log) {
        return _isSameDay(log.date, targetDate);
      }).firstOrNull;
      
      if (diary != null) {
        moodCount[diary.mood] = (moodCount[diary.mood] ?? 0) + 1;
      }
    }
    
    return moodCount;
  }

  // ==================== 계획 관리 시스템 ====================

  /// 계획 데이터 초기화 또는 가져오기
  UserPlanningData get planningData {
    return state.planningData ?? UserPlanningData.empty();
  }

  /// 새로운 목표 저장 (기존 목표 유지하면서 추가)
  void saveGoals(List<Map<String, dynamic>> rawGoals) {
    final currentPlanningData = planningData;
    
    // Map을 UserGoal로 변환
    final newGoals = rawGoals.map((goalMap) => UserGoal(
      id: goalMap['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: goalMap['title'] ?? '',
      description: goalMap['description'],
      category: goalMap['category'] ?? 'growth',
      duration: goalMap['duration'] ?? 7,
      schedule: goalMap['schedule'],
      createdAt: goalMap['createdAt'] ?? DateTime.now(),
      progress: (goalMap['progress'] ?? 0).toDouble(),
      isActive: goalMap['isActive'] ?? true,
      metadata: goalMap['metadata'],
    )).toList();
    
    // 기존 목표와 새 목표를 합침
    final allGoals = [...currentPlanningData.goals, ...newGoals];

    // 카테고리별 통계 업데이트
    final updatedCategoryStats = Map<String, int>.from(currentPlanningData.categoryStats);
    for (final goal in newGoals) {
      updatedCategoryStats[goal.category] = (updatedCategoryStats[goal.category] ?? 0) + 1;
    }

    // 새로운 계획 데이터 생성
    final updatedPlanningData = currentPlanningData.copyWith(
      goals: allGoals,
      lastPlanningDate: DateTime.now(),
      totalGoalsCreated: currentPlanningData.totalGoalsCreated + newGoals.length,
      categoryStats: updatedCategoryStats,
    );

    // 상태 업데이트
    state = state.copyWith(planningData: updatedPlanningData);
    _saveUserData();

    // 계획 저장 시 셰르피 반응
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.general,
      customDialogue: '${newGoals.length}개의 새로운 목표가 설정되었어요! 함께 달성해봐요! 💪',
      emotion: SherpiEmotion.cheering,
    );
  }

  /// 목표 진행률 업데이트
  void updateGoalProgress(String goalId, double progress) {
    final currentPlanningData = planningData;
    
    final updatedGoals = currentPlanningData.goals.map((goal) {
      if (goal.id == goalId) {
        final updatedGoal = goal.copyWith(progress: progress);
        
        // 100% 달성 시 완료 처리
        if (progress >= 100.0) {
          return _completeGoal(updatedGoal);
        }
        
        return updatedGoal;
      }
      return goal;
    }).toList();

    final updatedPlanningData = currentPlanningData.copyWith(goals: updatedGoals);
    state = state.copyWith(planningData: updatedPlanningData);
    _saveUserData();
  }

  /// 목표 완료 처리 (내부 메서드)
  UserGoal _completeGoal(UserGoal goal) {
    final currentPlanningData = planningData;
    
    // 완료된 목표로 이동
    final completedGoal = goal.copyWith(
      completedAt: DateTime.now(),
      progress: 100.0,
      isActive: false,
    );

    // 활성 목표에서 제거하고 완료 목표에 추가
    final updatedGoals = currentPlanningData.goals.where((g) => g.id != goal.id).toList();
    final updatedCompletedGoals = [...currentPlanningData.completedGoals, completedGoal];

    // 전체 통계 업데이트
    final updatedPlanningData = currentPlanningData.copyWith(
      goals: updatedGoals,
      completedGoals: updatedCompletedGoals,
      totalGoalsCompleted: currentPlanningData.totalGoalsCompleted + 1,
    );

    state = state.copyWith(planningData: updatedPlanningData);
    _saveUserData();

    // 목표 완료 보상
    addExperience(100);
    ref.read(globalPointProvider.notifier).earnPoints(
      500,
      PointSource.goalCompletion,
      '목표 달성: ${goal.title}',
    );
    
    // 셰르피 축하 메시지
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.general,
      customDialogue: '목표를 달성하셨네요! 정말 대단해요! 🎉',
      emotion: SherpiEmotion.special,
    );

    return completedGoal;
  }

  /// 목표 삭제
  void deleteGoal(String goalId) {
    final currentPlanningData = planningData;
    
    final updatedGoals = currentPlanningData.goals.where((g) => g.id != goalId).toList();
    final updatedPlanningData = currentPlanningData.copyWith(goals: updatedGoals);
    
    state = state.copyWith(planningData: updatedPlanningData);
    _saveUserData();
  }

  /// 목표 수정
  void updateGoal(String goalId, Map<String, dynamic> updates) {
    final currentPlanningData = planningData;
    
    final updatedGoals = currentPlanningData.goals.map((goal) {
      if (goal.id == goalId) {
        return goal.copyWith(
          title: updates['title'] ?? goal.title,
          description: updates['description'] ?? goal.description,
          category: updates['category'] ?? goal.category,
          duration: updates['duration'] ?? goal.duration,
          schedule: updates['schedule'] ?? goal.schedule,
          isActive: updates['isActive'] ?? goal.isActive,
          metadata: updates['metadata'] ?? goal.metadata,
        );
      }
      return goal;
    }).toList();

    final updatedPlanningData = currentPlanningData.copyWith(goals: updatedGoals);
    state = state.copyWith(planningData: updatedPlanningData);
    _saveUserData();
  }

  /// 목표 일시정지/재개
  void toggleGoalStatus(String goalId) {
    final currentPlanningData = planningData;
    
    final updatedGoals = currentPlanningData.goals.map((goal) {
      if (goal.id == goalId) {
        return goal.copyWith(isActive: !goal.isActive);
      }
      return goal;
    }).toList();

    final updatedPlanningData = currentPlanningData.copyWith(goals: updatedGoals);
    state = state.copyWith(planningData: updatedPlanningData);
    _saveUserData();
  }

  /// 모든 활성 목표 가져오기
  List<UserGoal> getActiveGoals() {
    return planningData.goals.where((g) => g.isActive).toList();
  }

  /// 카테고리별 목표 가져오기
  List<UserGoal> getGoalsByCategory(String category) {
    return planningData.goals.where((g) => g.category == category).toList();
  }

  /// 기한 임박 목표 가져오기 (3일 이내)
  List<UserGoal> getUpcomingDeadlines() {
    return planningData.goals.where((g) => g.isActive && g.daysRemaining <= 3).toList();
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