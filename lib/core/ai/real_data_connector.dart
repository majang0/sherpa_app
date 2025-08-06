import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/shared/providers/global_user_provider.dart';
import 'package:sherpa_app/shared/providers/global_point_provider.dart';
import 'package:sherpa_app/features/quests/providers/quest_provider_v2.dart';
import 'package:sherpa_app/shared/providers/global_game_provider.dart';
import 'package:sherpa_app/shared/providers/global_user_title_provider.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/models/point_system_model.dart';
import 'package:sherpa_app/features/quests/models/quest_instance_model.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';

/// 🔌 실제 사용자 데이터 연결 서비스
/// 
/// 앱의 실제 데이터를 AI 시스템에 연결합니다.
class RealDataConnector {
  final Ref _ref;
  
  RealDataConnector(this._ref);
  
  /// 📊 실제 사용자 컨텍스트 생성
  Map<String, dynamic> buildRealUserContext({
    required SherpiContext context,
    Map<String, dynamic>? additionalData,
  }) {
    final user = _ref.read(globalUserProvider);
    final dailyRecord = user.dailyRecords;
    
    // 기본 사용자 정보
    final userContext = <String, dynamic>{
      // 사용자 기본 정보
      'userId': user.id,
      'userName': user.name,
      'userLevel': user.level,
      'totalXP': user.experience.toInt(),
      
      // 스탯 정보
      'stamina': user.stats.stamina,
      'knowledge': user.stats.knowledge,
      'technique': user.stats.technique,
      'sociality': user.stats.sociality,
      'willpower': user.stats.willpower,
      
      // 오늘의 활동 기록
      'todayExerciseMinutes': dailyRecord.exerciseLogs.fold<int>(
        0, (sum, log) => sum + log.durationMinutes
      ),
      'todayReadingPages': dailyRecord.readingLogs.fold<int>(
        0, (sum, log) => sum + log.pages
      ),
      'todayDiaryWritten': dailyRecord.diaryLogs.isNotEmpty,
      'todayMeetingsJoined': dailyRecord.meetingLogs.length,
      
      // 연속 기록
      'currentStreak': user.dailyRecords.consecutiveDays,
      'longestStreak': user.dailyRecords.consecutiveDays, // longestStreak가 없으므로 consecutiveDays 사용
      
      // 시간 정보
      'currentHour': DateTime.now().hour,
      'dayOfWeek': DateTime.now().weekday,
      
      // 최근 활동 패턴 (최근 7일)
      'recentActivityPattern': _getRecentActivityPattern(user),
      
      // 선호 활동 타입
      'preferredActivities': _getPreferredActivities(user),
      
      // 성취 상태
      'totalBadges': user.ownedBadgeIds.length,
      'recentAchievements': _getRecentAchievements(user),
    };
    
    // 컨텍스트별 추가 데이터
    switch (context) {
      case SherpiContext.exerciseComplete:
        userContext.addAll(_getExerciseContextData(user, additionalData));
        break;
      case SherpiContext.studyComplete:
        userContext.addAll(_getStudyContextData(user, additionalData));
        break;
      case SherpiContext.questComplete:
        userContext.addAll(_getQuestContextData(additionalData));
        break;
      case SherpiContext.levelUp:
        userContext.addAll(_getLevelUpContextData(user));
        break;
      case SherpiContext.dailyGreeting:
        userContext.addAll(_getTimeBasedContextData(user));
        break;
      default:
        break;
    }
    
    // 추가 데이터 병합
    if (additionalData != null) {
      userContext.addAll(additionalData);
    }
    
    return userContext;
  }
  
  /// 🎮 실제 게임 컨텍스트 생성
  Map<String, dynamic> buildRealGameContext() {
    final user = _ref.read(globalUserProvider);
    final points = _ref.read(globalPointProvider);
    final quests = _ref.read(questProviderV2);
    final game = _ref.read(globalGameProvider);
    final titles = _ref.read(globalUserTitleProvider);
    // Relationship provider는 옵셔널로 처리
    // final relationship = _ref.read(sherpiRelationshipProvider);
    
    return {
      // 게임 진행 상태
      'currentMountain': '시작 전', // game 모델 구조 확인 후 수정
      'mountainProgress': 0.0,
      'nextMountain': '없음',
      'totalMountainsClimbed': 0,
      
      // 포인트 및 경제
      'currentPoints': points.totalPoints,
      'todayEarnedPoints': _getTodayEarnedPoints(points.transactions),
      'weeklyEarnedPoints': _getWeeklyEarnedPoints(points.transactions),
      'pointsRank': _getPointsRank(points.totalPoints),
      
      // 퀘스트 상태 (AsyncValue 처리)
      'activeQuests': quests.when(
        data: (questList) => questList.where((q) => !q.isCompleted).length,
        loading: () => 0,
        error: (_, __) => 0,
      ),
      'completedQuests': quests.when(
        data: (questList) => questList.where((q) => q.isCompleted).length,
        loading: () => 0,
        error: (_, __) => 0,
      ),
      'dailyQuestProgress': 0, // 계산 로직 필요
      'weeklyQuestProgress': 0, // 계산 로직 필요
      
      // 타이틀 및 업적 (UserTitle 모델 기반)
      'currentTitle': titles.title,
      'unlockedTitles': 1, // 현재 1개만 있음
      'nextTitleProgress': 0.0, // 다음 타이틀까지 진행도
      
      // 셰르피 관계 (기본값으로 설정)
      'sherpiIntimacy': 1,
      'sherpiTrustLevel': 1,
      'totalInteractions': 0,
      'lastInteractionDaysAgo': 0,
      
      // 게임 메타 정보
      'totalPlayDays': 1, // createdAt 필드가 없으므로 기본값
      'averageDailyXP': user.experience,
      'completionRate': _calculateCompletionRate(user),
    };
  }
  
  /// 📈 최근 활동 패턴 분석
  Map<String, dynamic> _getRecentActivityPattern(GlobalUser user) {
    // DailyRecordData는 단일 객체이므로 리스트가 아님
    final dailyRecord = user.dailyRecords;
    
    // 활동 시간대 분석
    final exerciseTimes = <int>[];
    final studyTimes = <int>[];
    
    for (final log in dailyRecord.exerciseLogs) {
      exerciseTimes.add(log.date.hour);
    }
    for (final log in dailyRecord.readingLogs) {
      studyTimes.add(log.date.hour);
    }
    
    if (exerciseTimes.isEmpty && studyTimes.isEmpty) {
      return {
        'hasData': false,
        'pattern': 'no_data',
      };
    }
    
    return {
      'hasData': true,
      'pattern': _determineActivityPattern(exerciseTimes, studyTimes),
      'mostActiveHour': _getMostFrequentHour(exerciseTimes + studyTimes),
      'exerciseFrequency': exerciseTimes.length / 7,
      'studyFrequency': studyTimes.length / 7,
      'consistency': _calculateConsistency(dailyRecord),
    };
  }
  
  /// 🎯 선호 활동 분석
  List<String> _getPreferredActivities(GlobalUser user) {
    final activities = <String, int>{};
    final dailyRecord = user.dailyRecords;
    
    if (dailyRecord.exerciseLogs.isNotEmpty) {
      activities['exercise'] = dailyRecord.exerciseLogs.length;
    }
    if (dailyRecord.readingLogs.isNotEmpty) {
      activities['reading'] = dailyRecord.readingLogs.length;
    }
    if (dailyRecord.diaryLogs.isNotEmpty) {
      activities['diary'] = dailyRecord.diaryLogs.length;
    }
    if (dailyRecord.meetingLogs.isNotEmpty) {
      activities['meeting'] = dailyRecord.meetingLogs.length;
    }
    
    final sorted = activities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(3).map((e) => e.key).toList();
  }
  
  /// 🏆 최근 성취 목록
  List<Map<String, dynamic>> _getRecentAchievements(GlobalUser user) {
    // 최근 획득한 배지 3개 (ID만 있으므로 간단하게 처리)
    return user.ownedBadgeIds.take(3).map((badgeId) => {
      'type': 'badge',
      'name': badgeId,
      'earnedAt': DateTime.now().toIso8601String(), // 임시
    }).toList();
  }
  
  /// 🏃 운동 컨텍스트 데이터
  Map<String, dynamic> _getExerciseContextData(
    GlobalUser user, 
    Map<String, dynamic>? additionalData
  ) {
    final todayExercises = user.dailyRecords.exerciseLogs;
    
    return {
      'todayExerciseCount': todayExercises.length,
      'totalExerciseMinutes': todayExercises.fold<int>(
        0, (sum, log) => sum + log.durationMinutes
      ),
      'exerciseTypes': todayExercises.map((e) => e.exerciseType).toSet().toList(),
      'averageIntensity': todayExercises.isEmpty ? 0 : 
          _calculateAverageIntensity(todayExercises),
      'isPersonalBest': additionalData?['personalBest'] ?? false,
      'exerciseStreak': _calculateExerciseStreak(user),
    };
  }
  
  /// 📚 학습 컨텍스트 데이터
  Map<String, dynamic> _getStudyContextData(
    GlobalUser user,
    Map<String, dynamic>? additionalData
  ) {
    final todayReading = user.dailyRecords.readingLogs;
    
    return {
      'todayBooksRead': todayReading.length,
      'totalPagesRead': todayReading.fold<int>(
        0, (sum, log) => sum + log.pages
      ),
      'bookTitles': todayReading.map((r) => r.bookTitle).toList(),
      'averageRating': todayReading.where((r) => r.rating != null).isEmpty ? 0 :
          todayReading.where((r) => r.rating != null)
              .map((r) => r.rating!)
              .reduce((a, b) => a + b) / 
          todayReading.where((r) => r.rating != null).length,
      'readingStreak': _calculateReadingStreak(user),
    };
  }
  
  /// 🎯 퀘스트 컨텍스트 데이터
  Map<String, dynamic> _getQuestContextData(Map<String, dynamic>? additionalData) {
    final quests = _ref.read(questProviderV2);
    
    return {
      'questName': additionalData?['questName'] ?? '퀘스트',
      'questDifficulty': additionalData?['difficulty'] ?? 'normal',
      'rewardPoints': additionalData?['rewardPoints'] ?? 0,
      'questsCompletedToday': quests.when(
        data: (questList) => _getTodayCompletedQuests(questList),
        loading: () => 0,
        error: (_, __) => 0,
      ),
      'nextQuestAvailable': quests.when(
        data: (questList) => questList.any((q) => !q.isCompleted),
        loading: () => false,
        error: (_, __) => false,
      ),
    };
  }
  
  /// ⬆️ 레벨업 컨텍스트 데이터
  Map<String, dynamic> _getLevelUpContextData(GlobalUser user) {
    return {
      'newLevel': user.level,
      'previousLevel': user.level - 1,
      'totalXP': user.experience.toInt(),
      'nextLevelXP': _getNextLevelXP(user.level),
      'unlockedFeatures': _getUnlockedFeatures(user.level),
      'newBadgesAvailable': _getAvailableBadges(user),
    };
  }
  
  /// ⏰ 시간 기반 컨텍스트 데이터
  Map<String, dynamic> _getTimeBasedContextData(GlobalUser user) {
    final now = DateTime.now();
    final todayRecord = user.dailyRecords;
    
    return {
      'timeOfDay': _getTimeOfDay(now.hour),
      'isWeekend': now.weekday >= 6,
      'todayProgress': {
        'exercise': todayRecord?.exerciseLogs.isNotEmpty ?? false,
        'reading': todayRecord?.readingLogs.isNotEmpty ?? false,
        'diary': todayRecord.diaryLogs.isNotEmpty,
      },
      'energyLevel': _estimateEnergyLevel(now.hour, todayRecord),
      'suggestedActivity': _suggestActivity(now.hour, todayRecord),
    };
  }
  
  // Helper methods
  
  String _determineActivityPattern(List<int> exerciseTimes, List<int> studyTimes) {
    if (exerciseTimes.isEmpty && studyTimes.isEmpty) return 'inactive';
    
    final allTimes = [...exerciseTimes, ...studyTimes];
    final morningCount = allTimes.where((h) => h >= 5 && h < 12).length;
    final afternoonCount = allTimes.where((h) => h >= 12 && h < 18).length;
    final eveningCount = allTimes.where((h) => h >= 18 && h < 24).length;
    
    if (morningCount > afternoonCount && morningCount > eveningCount) {
      return 'morning_person';
    } else if (eveningCount > morningCount && eveningCount > afternoonCount) {
      return 'night_owl';
    } else {
      return 'balanced';
    }
  }
  
  int _getMostFrequentHour(List<int> hours) {
    if (hours.isEmpty) return 9; // 기본값
    
    final frequency = <int, int>{};
    for (final hour in hours) {
      frequency[hour] = (frequency[hour] ?? 0) + 1;
    }
    
    return frequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  double _calculateConsistency(DailyRecordData record) {
    // 오늘의 활동 완료율로 계산
    int activeActivities = 0;
    int totalActivities = 4; // exercise, reading, diary, meetings
    
    if (record.exerciseLogs.isNotEmpty) activeActivities++;
    if (record.readingLogs.isNotEmpty) activeActivities++;
    if (record.diaryLogs.isNotEmpty) activeActivities++;
    if (record.meetingLogs.isNotEmpty) activeActivities++;
    
    return activeActivities / totalActivities;
  }
  
  int _calculateExerciseStreak(GlobalUser user) {
    // 현재 일일 기록으로 간단하게 계산
    return user.dailyRecords.exerciseLogs.isNotEmpty ? 1 : 0;
  }
  
  int _calculateReadingStreak(GlobalUser user) {
    // 현재 일일 기록으로 간단하게 계산
    return user.dailyRecords.readingLogs.isNotEmpty ? 1 : 0;
  }
  
  String _getPointsRank(int points) {
    if (points < 1000) return 'Bronze';
    if (points < 5000) return 'Silver';
    if (points < 10000) return 'Gold';
    if (points < 50000) return 'Platinum';
    return 'Diamond';
  }
  
  double _calculateCompletionRate(GlobalUser user) {
    // 총 플레이 일수는 1일로 가정 (createdAt 필드가 없음)
    final totalDays = 1;
    
    // 오늘 하루의 활동 완료 여부로 계산
    final hasActivity = user.dailyRecords.exerciseLogs.isNotEmpty || 
        user.dailyRecords.readingLogs.isNotEmpty || 
        user.dailyRecords.diaryLogs.isNotEmpty;
    final activeDays = hasActivity ? 1 : 0;
    
    return (activeDays / totalDays).clamp(0.0, 1.0);
  }
  
  int _getNextLevelXP(int currentLevel) {
    return currentLevel * 500 + 1000;
  }
  
  List<String> _getUnlockedFeatures(int level) {
    final features = <String>[];
    
    if (level % 5 == 0) features.add('새로운 산 개방');
    if (level % 10 == 0) features.add('프리미엄 퀘스트');
    if (level >= 20) features.add('길드 시스템');
    if (level >= 30) features.add('멘토링 시스템');
    
    return features;
  }
  
  int _getAvailableBadges(GlobalUser user) {
    // 획득 가능한 배지 수 계산 (임시)
    return 3;
  }
  
  String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }
  
  String _estimateEnergyLevel(int hour, DailyRecordData? todayRecord) {
    final activityCount = (todayRecord?.exerciseLogs.length ?? 0) +
                         (todayRecord?.readingLogs.length ?? 0);
    
    if (activityCount >= 3) return 'low';
    if (activityCount >= 1) return 'medium';
    if (hour >= 6 && hour <= 10) return 'high';
    if (hour >= 20) return 'low';
    return 'medium';
  }
  
  String _suggestActivity(int hour, DailyRecordData? todayRecord) {
    final hasExercised = todayRecord?.exerciseLogs.isNotEmpty ?? false;
    final hasRead = todayRecord?.readingLogs.isNotEmpty ?? false;
    final hasWrittenDiary = todayRecord?.diaryLogs.isNotEmpty ?? false;
    
    if (!hasExercised && hour < 20) return 'exercise';
    if (!hasRead && hour < 22) return 'reading';
    if (!hasWrittenDiary && hour >= 20) return 'diary';
    
    return 'rest';
  }
  
  // 헬퍼 메서드들
  
  /// 오늘 획득한 포인트 계산
  int _getTodayEarnedPoints(List<PointTransaction> transactions) {
    final today = DateTime.now();
    return transactions
        .where((t) => t.isEarned && _isSameDay(t.createdAt, today))
        .fold<int>(0, (sum, t) => sum + t.amount);
  }
  
  /// 이번 주 획득한 포인트 계산
  int _getWeeklyEarnedPoints(List<PointTransaction> transactions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return transactions
        .where((t) => t.isEarned && t.createdAt.isAfter(weekStart))
        .fold<int>(0, (sum, t) => sum + t.amount);
  }
  
  /// 오늘 완료한 퀘스트 수 계산
  int _getTodayCompletedQuests(List<QuestInstance> quests) {
    final today = DateTime.now();
    return quests
        .where((q) => q.isCompleted && q.completedAt != null && 
               _isSameDay(q.completedAt!, today))
        .length;
  }
  
  /// 운동 강도 평균 계산
  double _calculateAverageIntensity(List<ExerciseLog> exercises) {
    if (exercises.isEmpty) return 0.0;
    
    // 강도를 숫자로 변환 (low: 1, medium: 2, high: 3)
    final intensityValues = exercises.map((e) {
      switch (e.intensity.toLowerCase()) {
        case 'low': return 1.0;
        case 'medium': return 2.0;
        case 'high': return 3.0;
        default: return 2.0;
      }
    }).toList();
    
    return intensityValues.reduce((a, b) => a + b) / intensityValues.length;
  }
  
  /// 같은 날인지 확인하는 헬퍼
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}