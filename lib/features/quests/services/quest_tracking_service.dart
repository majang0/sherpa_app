import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quest_template_model.dart';
import '../models/quest_instance_model.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/providers/global_point_provider.dart';

/// 퀘스트 추적 서비스
/// 글로벌 데이터와 연동하여 퀘스트 진행률을 실시간으로 업데이트합니다.
class QuestTrackingService {
  
  /// 퀘스트 진행률 업데이트
  static QuestInstance? updateQuestProgress(
    QuestInstance quest, 
    Map<String, dynamic> globalData,
  ) {
    final condition = quest.trackingCondition;
    
    switch (condition.type) {
      case QuestTrackingType.appLaunch:
        return _updateAppLaunchQuest(quest, globalData);
        
      case QuestTrackingType.steps:
        return _updateStepsQuest(quest, globalData);
        
      case QuestTrackingType.tabVisit:
        return _updateTabVisitQuest(quest, globalData);
        
      case QuestTrackingType.globalData:
        return _updateGlobalDataQuest(quest, globalData);
        
      case QuestTrackingType.weeklyAccumulation:
        return _updateWeeklyAccumulationQuest(quest, globalData);
        
      case QuestTrackingType.multipleConditions:
        return _updateMultipleConditionsQuest(quest, globalData);
        
      default:
        return null;
    }
  }

  /// 앱 실행 퀘스트 업데이트
  static QuestInstance? _updateAppLaunchQuest(
    QuestInstance quest, 
    Map<String, dynamic> globalData,
  ) {
    if (quest.status == QuestStatus.inProgress && 
        globalData['appLaunched'] == true) {
      return quest.copyWith(
        status: QuestStatus.completed,
        currentProgress: 1,
        completedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 걸음수 퀘스트 업데이트
  static QuestInstance? _updateStepsQuest(
    QuestInstance quest, 
    Map<String, dynamic> globalData,
  ) {
    final targetSteps = quest.trackingCondition.parameters['target'] as int;
    final currentSteps = globalData['todaySteps'] as int? ?? 0;
    
    if (quest.status == QuestStatus.inProgress) {
      final newProgress = currentSteps.clamp(0, targetSteps);
      
      if (newProgress != quest.currentProgress) {
        final isCompleted = newProgress >= targetSteps;
        
        return quest.copyWith(
          currentProgress: newProgress,
          status: isCompleted ? QuestStatus.completed : QuestStatus.inProgress,
          completedAt: isCompleted ? DateTime.now() : null,
        );
      }
    }
    return null;
  }

  /// 탭 방문 퀘스트 업데이트
  static QuestInstance? _updateTabVisitQuest(
    QuestInstance quest, 
    Map<String, dynamic> globalData,
  ) {
    final targetTab = quest.trackingCondition.parameters['tab'] as String;
    final visitedTab = globalData['visitedTab'] as String?;
    
    if (quest.status == QuestStatus.inProgress && 
        visitedTab == targetTab) {
      return quest.copyWith(
        status: QuestStatus.completed,
        currentProgress: 1,
        completedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 글로벌 데이터 퀘스트 업데이트
  static QuestInstance? _updateGlobalDataQuest(
    QuestInstance quest, 
    Map<String, dynamic> globalData,
  ) {
    final dataPath = quest.trackingCondition.parameters['path'] as String;
    final targetValue = quest.trackingCondition.parameters['target'];
    
    final currentValue = _getValueFromPath(globalData, dataPath);
    
    if (quest.status == QuestStatus.inProgress && currentValue != null) {
      bool isCompleted = false;
      int newProgress = quest.currentProgress;
      
      // 타겟 값에 따른 완료 조건 확인
      if (targetValue is bool) {
        isCompleted = currentValue == targetValue;
        newProgress = isCompleted ? 1 : 0;
      } else if (targetValue is num && currentValue is num) {
        newProgress = currentValue.toInt().clamp(0, targetValue.toInt());
        isCompleted = currentValue >= targetValue;
      } else {
        isCompleted = currentValue.toString() == targetValue.toString();
        newProgress = isCompleted ? 1 : 0;
      }
      
      if (newProgress != quest.currentProgress || isCompleted) {
        return quest.copyWith(
          currentProgress: newProgress,
          status: isCompleted ? QuestStatus.completed : QuestStatus.inProgress,
          completedAt: isCompleted ? DateTime.now() : null,
        );
      }
    }
    return null;
  }

  /// 주간 누적 퀘스트 업데이트
  static QuestInstance? _updateWeeklyAccumulationQuest(
    QuestInstance quest, 
    Map<String, dynamic> globalData,
  ) {
    final dataType = quest.trackingCondition.parameters['dataType'] as String;
    final targetValue = quest.trackingCondition.parameters['target'];
    
    final currentValue = globalData['weekly_$dataType'] as num? ?? 0;
    
    if (quest.status == QuestStatus.inProgress) {
      final newProgress = currentValue.toInt().clamp(0, targetValue as int);
      final isCompleted = currentValue >= targetValue;
      
      if (newProgress != quest.currentProgress || isCompleted) {
        return quest.copyWith(
          currentProgress: newProgress,
          status: isCompleted ? QuestStatus.completed : QuestStatus.inProgress,
          completedAt: isCompleted ? DateTime.now() : null,
        );
      }
    }
    return null;
  }

  /// 복합 조건 퀘스트 업데이트
  static QuestInstance? _updateMultipleConditionsQuest(
    QuestInstance quest, 
    Map<String, dynamic> globalData,
  ) {
    final conditions = quest.trackingCondition.parameters['conditions'] as List<String>;
    
    if (quest.status == QuestStatus.inProgress) {
      bool allConditionsMet = true;
      int completedConditions = 0;
      
      for (final condition in conditions) {
        final parts = condition.split(':');
        if (parts.length != 2) continue;
        
        final dataKey = parts[0];
        final targetValue = int.tryParse(parts[1]) ?? 0;
        final currentValue = globalData[dataKey] as int? ?? 0;
        
        if (currentValue >= targetValue) {
          completedConditions++;
        } else {
          allConditionsMet = false;
        }
      }
      
      final newProgress = completedConditions;
      
      if (newProgress != quest.currentProgress || allConditionsMet) {
        return quest.copyWith(
          currentProgress: newProgress,
          status: allConditionsMet ? QuestStatus.completed : QuestStatus.inProgress,
          completedAt: allConditionsMet ? DateTime.now() : null,
        );
      }
    }
    return null;
  }

  /// 경로에서 값 가져오기
  static dynamic _getValueFromPath(Map<String, dynamic> data, String path) {
    final parts = path.split('.');
    dynamic current = data;
    
    for (final part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    
    return current;
  }

  /// 글로벌 사용자 데이터를 퀘스트 추적용 맵으로 변환
  static Map<String, dynamic> convertGlobalUserToTrackingData(
    GlobalUser globalUser, {
    int? dailyPointsEarned,
    int? weeklyPointsEarned,
  }) {
    final dailyRecords = globalUser.dailyRecords;
    
    // 실제 데이터 계산
    final todayExerciseMinutes = _calculateTodayExerciseMinutes(dailyRecords);
    final todayMovieLogs = _calculateTodayMovieLogs(dailyRecords);
    final todayMovieReviews = _calculateTodayMovieReviews(dailyRecords);
    final todayMeetingLogs = _calculateTodayMeetingLogs(dailyRecords);
    final todayReadingPages = _calculateTodayReadingPages(dailyRecords);
    final todayClimbingSuccess = _checkTodayClimbingSuccess(dailyRecords);
    
    // 주간 데이터 계산
    final weeklyMovieLogs = _calculateWeeklyMovieLogs(dailyRecords);
    final weeklyReadingPages = _calculateWeeklyReadingPages(dailyRecords);
    final weeklyExerciseDays = _calculateWeeklyExerciseDays(dailyRecords);
    final weeklyDifferentMeetingCategories = _calculateWeeklyDifferentMeetingCategories(dailyRecords);
    final weeklyDifferentMountains = _calculateWeeklyDifferentMountains(dailyRecords);
    
    return {
      // 기본 데이터
      'appLaunched': true,
      'todaySteps': dailyRecords.todaySteps,
      'todayFocusMinutes': dailyRecords.todayFocusMinutes,
      
      // 일일 기록 관련
      'dailyRecords.todaySteps': dailyRecords.todaySteps,
      'dailyRecords.todayFocusMinutes': dailyRecords.todayFocusMinutes,
      'dailyRecords.todayExerciseMinutes': todayExerciseMinutes,
      'allDailyActivitiesCompleted': _areAllDailyActivitiesCompleted(dailyRecords),
      
      // 일일 목표 관련
      'dailyGoals.exercise.completed': _isGoalCompleted(dailyRecords.dailyGoals, 'exercise'),
      'dailyGoals.reading.completed': _isGoalCompleted(dailyRecords.dailyGoals, 'reading'),
      'dailyGoals.diary.completed': _isGoalCompleted(dailyRecords.dailyGoals, 'diary'),
      'dailyGoals.focus.completed': _isGoalCompleted(dailyRecords.dailyGoals, 'focus'),
      
      // 주간 누적 데이터 (실제 계산)
      'weekly_steps': _calculateWeeklySteps(dailyRecords),
      'weekly_focusMinutes': _calculateWeeklyFocusMinutes(dailyRecords),
      'weekly_exerciseRecords': weeklyExerciseDays,
      'weekly_readingRecords': _calculateWeeklyReadingDays(dailyRecords),
      'weekly_diaryRecords': _calculateWeeklyDiaryDays(dailyRecords),
      'weekly_appLaunches': _calculateWeeklyAppLaunches(),
      'weekly_climbingCompletions': _calculateWeeklyClimbingCompletions(dailyRecords),
      'weekly_pointsEarned': weeklyPointsEarned ?? 0,
      'weekly_readingPages': weeklyReadingPages,
      'weekly_movieLogs': weeklyMovieLogs,
      'weekly_differentMeetingCategories': weeklyDifferentMeetingCategories,
      'weekly_differentMountains': weeklyDifferentMountains,
      
      // 포인트 관련
      'dailyPointsEarned': dailyPointsEarned ?? 0,
      
      // 등반 관련
      'ClimbingRecord.isSuccess': todayClimbingSuccess,
      
      // 모임/소셜 관련
      'MeetingReview': dailyRecords.meetingLogs.where((log) => log.note != null && log.note!.isNotEmpty).length,
      'MeetingLog': todayMeetingLogs,
      'meetingReviews': dailyRecords.meetingLogs.where((log) => log.note != null && log.note!.isNotEmpty).length,
      'weekly_meetingLogs': _calculateWeeklyMeetingLogs(dailyRecords),
      'weekly_meetingReviews': _calculateWeeklyMeetingReviews(dailyRecords),
      
      // 독서/영화 관련
      'ReadingLog.pages': todayReadingPages,
      'MovieLog': todayMovieLogs,
      'movieLogs': todayMovieLogs,
      'movieReviews': todayMovieReviews,
      'readingPages': todayReadingPages,
      'culturalRecords': todayMovieLogs + (todayReadingPages > 0 ? 1 : 0), // 영화 + 독서
      
      // 뱃지 관련
      'badgeEquipped': globalUser.equippedBadgeIds.length,
      
      // 복합 조건용 데이터
      'exerciseMinutes': todayExerciseMinutes,
      'differentExerciseTypes': _calculateDifferentExerciseTypes(dailyRecords),
      'differentMountains': weeklyDifferentMountains,
      'differentMeetingCategories': weeklyDifferentMeetingCategories,
      'meetingLogs': _calculateWeeklyMeetingLogs(dailyRecords),
      '연속등반성공': _calculateConsecutiveClimbingSuccess(dailyRecords),
      '연속일일퀘스트완료': 0, // TODO: 퀘스트 완료 연속일 계산
      'perfectDays': _calculatePerfectDays(dailyRecords),
      'allActivitiesDays': _calculateAllActivitiesDays(dailyRecords),
      'challengeRecords': dailyRecords.challengeRecords.length,
      'differentMeetings': weeklyDifferentMeetingCategories,
      '모임주최성공': 0, // TODO: 주최한 모임 계산
      '30일챌린지첫주': 0, // TODO: 30일 챌린지 관련
      '모든카테고리퀘스트완료': 0, // TODO: 퀘스트 완료 관련
      '모든주간퀘스트완료': 0, // TODO: 주간 퀘스트 완료 관련
    };
  }

  /// 다른 운동 종류 수 계산 (오늘)
  static int _calculateDifferentExerciseTypes(DailyRecordData dailyRecords) {
    final today = DateTime.now();
    final exerciseTypes = <String>{};
    
    for (final log in dailyRecords.exerciseLogs) {
      if (log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day) {
        exerciseTypes.add(log.exerciseType);
      }
    }
    return exerciseTypes.length;
  }

  /// 연속 등반 성공일 계산
  static int _calculateConsecutiveClimbingSuccess(DailyRecordData dailyRecords) {
    // 가장 최근부터 연속으로 성공한 일수 계산
    final sortedLogs = dailyRecords.climbingLogs
        .where((log) => log.isSuccess)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    
    if (sortedLogs.isEmpty) return 0;
    
    int consecutiveDays = 1;
    for (int i = 1; i < sortedLogs.length; i++) {
      final current = sortedLogs[i];
      final previous = sortedLogs[i - 1];
      final dayDiff = previous.startTime.difference(current.startTime).inDays;
      
      if (dayDiff == 1) {
        consecutiveDays++;
      } else {
        break;
      }
    }
    return consecutiveDays;
  }

  /// 완벽한 하루 일수 계산 (모든 목표 달성한 날)
  static int _calculatePerfectDays(DailyRecordData dailyRecords) {
    // 지난 7일간 모든 목표를 달성한 날의 수
    int perfectDays = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final checkDate = now.subtract(Duration(days: i));
      bool hasDiary = dailyRecords.diaryLogs.any((log) =>
          log.date.year == checkDate.year &&
          log.date.month == checkDate.month &&
          log.date.day == checkDate.day);
      
      bool hasExercise = dailyRecords.exerciseLogs.any((log) =>
          log.date.year == checkDate.year &&
          log.date.month == checkDate.month &&
          log.date.day == checkDate.day);
      
      bool hasReading = dailyRecords.readingLogs.any((log) =>
          log.date.year == checkDate.year &&
          log.date.month == checkDate.month &&
          log.date.day == checkDate.day);
      
      if (hasDiary && hasExercise && hasReading) {
        perfectDays++;
      }
    }
    return perfectDays;
  }

  /// 모든 활동 완료한 날 수 계산
  static int _calculateAllActivitiesDays(DailyRecordData dailyRecords) {
    // perfectDays와 동일한 로직
    return _calculatePerfectDays(dailyRecords);
  }

  /// 모든 일일 활동 완료 확인
  static bool _areAllDailyActivitiesCompleted(DailyRecordData dailyRecords) {
    final goals = dailyRecords.dailyGoals;
    return _isGoalCompleted(goals, 'exercise') &&
           _isGoalCompleted(goals, 'reading') &&
           _isGoalCompleted(goals, 'diary');
  }

  /// 특정 목표 완료 확인
  static bool _isGoalCompleted(List<DailyGoal> goals, String goalId) {
    try {
      return goals.any((goal) => goal.id == goalId && goal.isCompleted);
    } catch (e) {
      return false;
    }
  }

  /// 탭 방문 기록
  static Future<void> recordTabVisit(String tabName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_visited_tab', tabName);
    await prefs.setInt('last_visit_time', DateTime.now().millisecondsSinceEpoch);
  }

  /// 마지막 방문 탭 가져오기
  static Future<String?> getLastVisitedTab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_visited_tab');
  }

  /// 오늘 방문한 탭인지 확인
  static Future<bool> isTabVisitedToday(String tabName) async {
    final prefs = await SharedPreferences.getInstance();
    final lastTab = prefs.getString('last_visited_tab');
    final lastVisitTime = prefs.getInt('last_visit_time');
    
    if (lastTab != tabName || lastVisitTime == null) return false;
    
    final lastVisit = DateTime.fromMillisecondsSinceEpoch(lastVisitTime);
    final today = DateTime.now();
    
    return lastVisit.year == today.year &&
           lastVisit.month == today.month &&
           lastVisit.day == today.day;
  }

  /// 오늘의 운동 시간 계산
  static int _calculateTodayExerciseMinutes(DailyRecordData dailyRecords) {
    final today = DateTime.now();
    return dailyRecords.exerciseLogs
        .where((log) => 
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day)
        .fold(0, (total, log) => total + log.durationMinutes);
  }

  /// 오늘의 영화 감상 수 계산
  static int _calculateTodayMovieLogs(DailyRecordData dailyRecords) {
    final today = DateTime.now();
    return dailyRecords.movieLogs
        .where((log) => 
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day)
        .length;
  }

  /// 오늘의 영화 리뷰 수 계산 (리뷰가 있는 영화)
  static int _calculateTodayMovieReviews(DailyRecordData dailyRecords) {
    final today = DateTime.now();
    return dailyRecords.movieLogs
        .where((log) => 
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day &&
          log.review != null && log.review!.isNotEmpty)
        .length;
  }

  /// 오늘의 모임 참여 수 계산
  static int _calculateTodayMeetingLogs(DailyRecordData dailyRecords) {
    final today = DateTime.now();
    return dailyRecords.meetingLogs
        .where((log) => 
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day)
        .length;
  }

  /// 오늘의 독서 페이지 수 계산
  static int _calculateTodayReadingPages(DailyRecordData dailyRecords) {
    final today = DateTime.now();
    return dailyRecords.readingLogs
        .where((log) => 
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day)
        .fold(0, (total, log) => total + log.pages);
  }

  /// 등반 성공 여부 확인 (오늘)
  static bool _checkTodayClimbingSuccess(DailyRecordData dailyRecords) {
    final today = DateTime.now();
    return dailyRecords.climbingLogs
        .where((log) => 
          log.startTime.year == today.year &&
          log.startTime.month == today.month &&
          log.startTime.day == today.day)
        .any((log) => log.isSuccess);
  }

  /// 이번 주 영화 감상 수 계산
  static int _calculateWeeklyMovieLogs(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    return dailyRecords.movieLogs
        .where((log) => log.date.isAfter(weekStart.subtract(Duration(days: 1))) && 
                        log.date.isBefore(weekEnd.add(Duration(days: 1))))
        .length;
  }

  /// 이번 주 독서 페이지 수 계산
  static int _calculateWeeklyReadingPages(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    return dailyRecords.readingLogs
        .where((log) => log.date.isAfter(weekStart.subtract(Duration(days: 1))) && 
                        log.date.isBefore(weekEnd.add(Duration(days: 1))))
        .fold(0, (total, log) => total + log.pages);
  }

  /// 이번 주 운동 일수 계산
  static int _calculateWeeklyExerciseDays(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    final exerciseDays = <String>{};
    for (final log in dailyRecords.exerciseLogs) {
      if (log.date.isAfter(weekStart.subtract(Duration(days: 1))) && 
          log.date.isBefore(weekEnd.add(Duration(days: 1)))) {
        final dayKey = '${log.date.year}-${log.date.month}-${log.date.day}';
        exerciseDays.add(dayKey);
      }
    }
    return exerciseDays.length;
  }

  /// 이번 주 모임 참여 수 계산
  static int _calculateWeeklyMeetingLogs(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    return dailyRecords.meetingLogs
        .where((log) => 
          log.date.isAfter(weekStart.subtract(Duration(days: 1))) && 
          log.date.isBefore(weekEnd.add(Duration(days: 1))))
        .length;
  }

  /// 이번 주 다른 모임 카테고리 수 계산
  static int _calculateWeeklyDifferentMeetingCategories(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    final categories = <String>{};
    for (final log in dailyRecords.meetingLogs) {
      if (log.date.isAfter(weekStart.subtract(Duration(days: 1))) && 
          log.date.isBefore(weekEnd.add(Duration(days: 1)))) {
        categories.add(log.category);
      }
    }
    return categories.length;
  }

  /// 이번 주 다른 산 등반 수 계산
  static int _calculateWeeklyDifferentMountains(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    final mountains = <String>{};
    for (final log in dailyRecords.climbingLogs) {
      if (log.startTime.isAfter(weekStart.subtract(Duration(days: 1))) && 
          log.startTime.isBefore(weekEnd.add(Duration(days: 1)))) {
        mountains.add(log.mountainName);
      }
    }
    return mountains.length;
  }

  /// 주간 데이터 계산 (실제 지난 7일간의 데이터)
  static Future<Map<String, dynamic>> calculateWeeklyData(GlobalUser globalUser) async {
    final dailyRecords = globalUser.dailyRecords;
    
    // 실제 주간 데이터 계산
    final weeklySteps = _calculateWeeklySteps(dailyRecords);
    final weeklyFocusMinutes = _calculateWeeklyFocusMinutes(dailyRecords);
    final weeklyExerciseDays = _calculateWeeklyExerciseDays(dailyRecords);
    final weeklyReadingDays = _calculateWeeklyReadingDays(dailyRecords);
    final weeklyDiaryDays = _calculateWeeklyDiaryDays(dailyRecords);
    final weeklyAppLaunches = _calculateWeeklyAppLaunches();
    final weeklyClimbingCompletions = _calculateWeeklyClimbingCompletions(dailyRecords);
    
    return {
      'weekly_steps': weeklySteps,
      'weekly_focusMinutes': weeklyFocusMinutes,
      'weekly_exerciseRecords': weeklyExerciseDays,
      'weekly_readingRecords': weeklyReadingDays,
      'weekly_diaryRecords': weeklyDiaryDays,
      'weekly_appLaunches': weeklyAppLaunches,
      'weekly_climbingCompletions': weeklyClimbingCompletions,
    };
  }

  /// 주간 걸음 수 계산 (실제 7일간 합계)
  static int _calculateWeeklySteps(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    // 주간 걸음 수는 현재 todaySteps만 있으므로 임시로 오늘 기준으로 계산
    // 실제로는 각 날짜별 걸음 수 기록이 필요함
    return dailyRecords.todaySteps * 7; // TODO: 실제 일별 걸음 수 데이터 필요
  }
  
  /// 주간 집중 시간 계산
  static int _calculateWeeklyFocusMinutes(DailyRecordData dailyRecords) {
    // 현재 DailyRecordData에는 focusLogs가 없으므로 todayFocusMinutes를 기반으로 추정
    // TODO: 실제 집중 기록 로그가 추가되면 수정 필요
    return dailyRecords.todayFocusMinutes * 7; // 임시로 오늘 * 7일
  }
  
  /// 주간 독서 일수 계산
  static int _calculateWeeklyReadingDays(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    final readingDays = <String>{};
    for (final log in dailyRecords.readingLogs) {
      if (log.date.isAfter(weekStart.subtract(Duration(days: 1))) && 
          log.date.isBefore(weekEnd.add(Duration(days: 1)))) {
        final dayKey = '${log.date.year}-${log.date.month}-${log.date.day}';
        readingDays.add(dayKey);
      }
    }
    return readingDays.length;
  }
  
  /// 주간 일기 일수 계산
  static int _calculateWeeklyDiaryDays(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    final diaryDays = <String>{};
    for (final log in dailyRecords.diaryLogs) {
      if (log.date.isAfter(weekStart.subtract(Duration(days: 1))) && 
          log.date.isBefore(weekEnd.add(Duration(days: 1)))) {
        final dayKey = '${log.date.year}-${log.date.month}-${log.date.day}';
        diaryDays.add(dayKey);
      }
    }
    return diaryDays.length;
  }
  
  /// 주간 앱 실행 횟수 계산
  static int _calculateWeeklyAppLaunches() {
    // 앱 실행 횟수는 별도 추적이 필요하므로 임시로 7일로 설정
    // TODO: 실제 앱 실행 횟수 추적 로직 필요
    return 7;
  }
  
  /// 주간 등반 완료 횟수 계산
  static int _calculateWeeklyClimbingCompletions(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    return dailyRecords.climbingLogs
        .where((log) => 
          log.isSuccess &&
          log.startTime.isAfter(weekStart.subtract(Duration(days: 1))) && 
          log.startTime.isBefore(weekEnd.add(Duration(days: 1))))
        .length;
  }

  /// 주간 모임 후기 작성 수 계산
  static int _calculateWeeklyMeetingReviews(DailyRecordData dailyRecords) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    return dailyRecords.meetingLogs
        .where((log) => 
          log.note != null && 
          log.note!.isNotEmpty &&
          log.date.isAfter(weekStart.subtract(Duration(days: 1))) && 
          log.date.isBefore(weekEnd.add(Duration(days: 1))))
        .length;
  }

}