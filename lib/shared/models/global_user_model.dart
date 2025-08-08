// lib/shared/models/global_user_model.dart

import 'package:flutter/material.dart';

class GlobalUser {
  final String id;
  final String name;
  final int level;
  final double experience;
  final GlobalStats stats;
  final List<String> equippedBadgeIds;
  final List<String> ownedBadgeIds;
  final DailyRecordData dailyRecords;
  final ClimbingSession? currentClimbingSession;
  final UserPlanningData? planningData;

  const GlobalUser({
    required this.id,
    required this.name,
    required this.level,
    required this.experience,
    required this.stats,
    required this.equippedBadgeIds,
    required this.ownedBadgeIds,
    required this.dailyRecords,
    this.currentClimbingSession,
    this.planningData,
  });

  String get title {
    if (level < 10) return "초보 등반가";
    if (level < 20) return "숙련된 등반가";
    if (level < 30) return "전문 산악인";
    return "셰르파";
  }

  GlobalUser copyWith({
    String? id,
    String? name,
    int? level,
    double? experience,
    GlobalStats? stats,
    List<String>? equippedBadgeIds,
    List<String>? ownedBadgeIds,
    DailyRecordData? dailyRecords,
    ClimbingSession? currentClimbingSession,
    UserPlanningData? planningData,
  }) {
    return GlobalUser(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      stats: stats ?? this.stats,
      equippedBadgeIds: equippedBadgeIds ?? this.equippedBadgeIds,
      ownedBadgeIds: ownedBadgeIds ?? this.ownedBadgeIds,
      dailyRecords: dailyRecords ?? this.dailyRecords,
      currentClimbingSession: currentClimbingSession ?? this.currentClimbingSession,
      planningData: planningData ?? this.planningData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'experience': experience,
      'stats': stats.toJson(),
      'equippedBadgeIds': equippedBadgeIds,
      'ownedBadgeIds': ownedBadgeIds,
      'dailyRecords': dailyRecords.toJson(),
      'currentClimbingSession': currentClimbingSession?.toJson(),
      'planningData': planningData?.toJson(),
    };
  }

  factory GlobalUser.fromJson(Map<String, dynamic> json) {
    return GlobalUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? 1,
      experience: (json['experience'] ?? 0).toDouble(),
      stats: GlobalStats.fromJson(json['stats'] ?? {}),
      equippedBadgeIds: List<String>.from(json['equippedBadgeIds'] ?? []),
      ownedBadgeIds: List<String>.from(json['ownedBadgeIds'] ?? []),
      dailyRecords: DailyRecordData.fromJson(json['dailyRecords'] ?? {}),
      currentClimbingSession: json['currentClimbingSession'] != null
          ? ClimbingSession.fromJson(json['currentClimbingSession'])
          : null,
      planningData: json['planningData'] != null
          ? UserPlanningData.fromJson(json['planningData'])
          : null,
    );
  }
}

class GlobalStats {
  final double stamina;
  final double knowledge;
  final double technique;
  final double sociality;
  final double willpower;

  const GlobalStats({
    required this.stamina,
    required this.knowledge,
    required this.technique,
    required this.sociality,
    required this.willpower,
  });

  GlobalStats copyWith({
    double? stamina,
    double? knowledge,
    double? technique,
    double? sociality,
    double? willpower,
  }) {
    return GlobalStats(
      stamina: stamina ?? this.stamina,
      knowledge: knowledge ?? this.knowledge,
      technique: technique ?? this.technique,
      sociality: sociality ?? this.sociality,
      willpower: willpower ?? this.willpower,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stamina': stamina,
      'knowledge': knowledge,
      'technique': technique,
      'sociality': sociality,
      'willpower': willpower,
    };
  }

  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(
      stamina: (json['stamina'] ?? 0).toDouble(),
      knowledge: (json['knowledge'] ?? 0).toDouble(),
      technique: (json['technique'] ?? 0).toDouble(),
      sociality: (json['sociality'] ?? 0).toDouble(),
      willpower: (json['willpower'] ?? 0).toDouble(),
    );
  }
}

// ==================== 일일 기록 데이터 ====================

/// 모든 일일 기록을 통합 관리하는 데이터 클래스
class DailyRecordData {
  final int todaySteps;
  final int todayFocusMinutes;
  final List<MeetingLog> meetingLogs;
  final List<ReadingLog> readingLogs;
  final List<ExerciseLog> exerciseLogs;
  final List<DiaryLog> diaryLogs;
  final List<MovieLog> movieLogs;
  final List<DailyGoal> dailyGoals;
  final List<ClimbingRecord> climbingLogs;
  final List<ChallengeRecord> challengeRecords; // ✅ 참린지 기록 추가
  final int consecutiveDays;
  final DateTime lastActiveDate;
  final bool isAllGoalsCompleted;
  final bool isAllGoalsRewardClaimed;

  const DailyRecordData({
    required this.todaySteps,
    required this.todayFocusMinutes,
    required this.meetingLogs,
    required this.readingLogs,
    required this.exerciseLogs,
    required this.diaryLogs,
    required this.movieLogs,
    required this.dailyGoals,
    required this.climbingLogs,
    required this.challengeRecords, // ✅ 참린지 기록 추가
    required this.consecutiveDays,
    required this.lastActiveDate,
    this.isAllGoalsCompleted = false,
    this.isAllGoalsRewardClaimed = false,
  });

  /// 초기 상태 생성
  static DailyRecordData get initial => DailyRecordData(
    todaySteps: 0,
    todayFocusMinutes: 0,
    meetingLogs: [],
    readingLogs: [],
    exerciseLogs: [],
    diaryLogs: [],
    movieLogs: [],
    dailyGoals: DailyGoal.createDefaultGoals(),
    climbingLogs: [],
    challengeRecords: [], // ✅ 빈 참린지 기록 초기화
    consecutiveDays: 0,
    lastActiveDate: DateTime.now(),
  );

  /// 오늘의 목표 완료률 계산
  double get todayCompletionRate {
    if (dailyGoals.isEmpty) return 0.0;
    final completedCount = dailyGoals.where((goal) => goal.isCompleted).length;
    return completedCount / dailyGoals.length;
  }

  /// 오늘 완료된 목표 수
  int get todayCompletedGoalsCount {
    return dailyGoals.where((goal) => goal.isCompleted).length;
  }

  /// 오늘의 독서 페이지 수
  int get todayReadingPages {
    final today = DateTime.now();
    return readingLogs
        .where((log) => _isSameDay(log.date, today))
        .fold(0, (sum, log) => sum + log.pages);
  }

  /// 총 걸음수 (최근 30일)
  int get totalSteps {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    // 실제로는 매일의 걸음수 데이터를 저장해야 하지만, 임시로 계산
    return todaySteps * 30;
  }

  /// 총 독서 페이지 수
  int get totalReadingPages {
    return readingLogs.fold(0, (sum, log) => sum + log.pages);
  }

  /// 총 모임 참여 수
  int get totalMeetings {
    return meetingLogs.length;
  }

  /// 총 운동 시간 (분)
  int get totalExerciseMinutes {
    return exerciseLogs.fold(0, (sum, log) => sum + log.durationMinutes);
  }

  /// 총 등반 횟수
  int get totalClimbings {
    return climbingLogs.length;
  }

  /// 등반 성공 횟수
  int get successfulClimbings {
    return climbingLogs.where((log) => log.isSuccess).length;
  }

  /// 등반 성공률
  double get climbingSuccessRate {
    if (climbingLogs.isEmpty) return 0.0;
    return successfulClimbings / climbingLogs.length;
  }

  /// 오늘의 등반 기록
  List<ClimbingRecord> get todayClimbingLogs {
    final today = DateTime.now();
    return climbingLogs.where((log) => _isSameDay(log.startTime, today)).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DailyRecordData copyWith({
    int? todaySteps,
    int? todayFocusMinutes,
    List<MeetingLog>? meetingLogs,
    List<ReadingLog>? readingLogs,
    List<ExerciseLog>? exerciseLogs,
    List<DiaryLog>? diaryLogs,
    List<MovieLog>? movieLogs,
    List<DailyGoal>? dailyGoals,
    List<ClimbingRecord>? climbingLogs,
    List<ChallengeRecord>? challengeRecords, // ✅ 참린지 기록 추가
    int? consecutiveDays,
    DateTime? lastActiveDate,
    bool? isAllGoalsCompleted,
    bool? isAllGoalsRewardClaimed,
  }) {
    return DailyRecordData(
      todaySteps: todaySteps ?? this.todaySteps,
      todayFocusMinutes: todayFocusMinutes ?? this.todayFocusMinutes,
      meetingLogs: meetingLogs ?? this.meetingLogs,
      readingLogs: readingLogs ?? this.readingLogs,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      diaryLogs: diaryLogs ?? this.diaryLogs,
      movieLogs: movieLogs ?? this.movieLogs,
      dailyGoals: dailyGoals ?? this.dailyGoals,
      climbingLogs: climbingLogs ?? this.climbingLogs,
      challengeRecords: challengeRecords ?? this.challengeRecords, // ✅ 참린지 기록 추가
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      isAllGoalsCompleted: isAllGoalsCompleted ?? this.isAllGoalsCompleted,
      isAllGoalsRewardClaimed: isAllGoalsRewardClaimed ?? this.isAllGoalsRewardClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todaySteps': todaySteps,
      'todayFocusMinutes': todayFocusMinutes,
      'meetingLogs': meetingLogs.map((log) => log.toJson()).toList(),
      'readingLogs': readingLogs.map((log) => log.toJson()).toList(),
      'exerciseLogs': exerciseLogs.map((log) => log.toJson()).toList(),
      'diaryLogs': diaryLogs.map((log) => log.toJson()).toList(),
      'movieLogs': movieLogs.map((log) => log.toJson()).toList(),
      'dailyGoals': dailyGoals.map((goal) => goal.toJson()).toList(),
      'climbingLogs': climbingLogs.map((log) => log.toJson()).toList(),
      'challengeRecords': challengeRecords.map((record) => record.toJson()).toList(), // ✅ 참린지 기록 추가
      'consecutiveDays': consecutiveDays,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'isAllGoalsCompleted': isAllGoalsCompleted,
      'isAllGoalsRewardClaimed': isAllGoalsRewardClaimed,
    };
  }

  factory DailyRecordData.fromJson(Map<String, dynamic> json) {
    return DailyRecordData(
      todaySteps: json['todaySteps'] ?? 0,
      todayFocusMinutes: json['todayFocusMinutes'] ?? 0,
      meetingLogs: (json['meetingLogs'] as List?)
          ?.map((item) => MeetingLog.fromJson(item))
          .toList() ?? [],
      readingLogs: (json['readingLogs'] as List?)
          ?.map((item) => ReadingLog.fromJson(item))
          .toList() ?? [],
      exerciseLogs: (json['exerciseLogs'] as List?)
          ?.map((item) => ExerciseLog.fromJson(item))
          .toList() ?? [],
      diaryLogs: (json['diaryLogs'] as List?)
          ?.map((item) => DiaryLog.fromJson(item))
          .toList() ?? [],
      movieLogs: (json['movieLogs'] as List?)
          ?.map((item) => MovieLog.fromJson(item))
          .toList() ?? [],
      dailyGoals: (json['dailyGoals'] as List?)
          ?.map((item) => DailyGoal.fromJson(item))
          .toList() ?? DailyGoal.createDefaultGoals(),
      climbingLogs: (json['climbingLogs'] as List?)
          ?.map((item) => ClimbingRecord.fromJson(item))
          .toList() ?? [],
      challengeRecords: (json['challengeRecords'] as List?) // ✅ 참린지 기록 추가
          ?.map((item) => ChallengeRecord.fromJson(item))
          .toList() ?? [],
      consecutiveDays: json['consecutiveDays'] ?? 0,
      lastActiveDate: DateTime.tryParse(json['lastActiveDate'] ?? '') ?? DateTime.now(),
      isAllGoalsCompleted: json['isAllGoalsCompleted'] ?? false,
      isAllGoalsRewardClaimed: json['isAllGoalsRewardClaimed'] ?? false,
    );
  }
}

// ==================== 개별 기록 모델들 ====================

/// 모임 기록
class MeetingLog {
  final String id;
  final DateTime date;
  final String meetingName;
  final String category;
  final double satisfaction;
  final String mood;
  final String? note;
  final bool isShared;

  const MeetingLog({
    required this.id,
    required this.date,
    required this.meetingName,
    required this.category,
    required this.satisfaction,
    required this.mood,
    this.note,
    this.isShared = false,
  });

  /// 모임 이름을 짧게 축약
  String get shortName {
    if (meetingName.length <= 6) return meetingName;
    return '${meetingName.substring(0, 6)}...';
  }

  /// 만족도에 따른 색상
  Color get satisfactionColor {
    if (satisfaction >= 4.0) return const Color(0xFF10B981); // 초록
    if (satisfaction >= 3.0) return const Color(0xFFF59E0B); // 노랑
    return const Color(0xFFEF4444); // 빨강
  }

  String get categoryIcon {
    switch (category) {
      case '스터디': return '📚';
      case '운동': return '💪';
      case '독서': return '📖';
      case '취미': return '🎨';
      case '네트워킹': return '🤝';
      default: return '👥';
    }
  }

  String get moodIcon {
    switch (mood) {
      case 'very_happy': return '😄';
      case 'happy': return '😊';
      case 'good': return '🙂';
      case 'normal': return '😐';
      case 'tired': return '😴';
      case 'stressed': return '😰';
      default: return '😊';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'meetingName': meetingName,
      'category': category,
      'satisfaction': satisfaction,
      'mood': mood,
      'note': note,
      'isShared': isShared,
    };
  }

  factory MeetingLog.fromJson(Map<String, dynamic> json) {
    return MeetingLog(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      meetingName: json['meetingName'] ?? '',
      category: json['category'] ?? '',
      satisfaction: (json['satisfaction'] ?? 0).toDouble(),
      mood: json['mood'] ?? 'happy',
      note: json['note'],
      isShared: json['isShared'] ?? false,
    );
  }
}

/// 독서 기록
class ReadingLog {
  final String id;
  final DateTime date;
  final String bookTitle;
  final String author;
  final int pages;
  final String? note;
  final double? rating;
  final String category;
  final String? mood;
  final bool isShared;

  const ReadingLog({
    required this.id,
    required this.date,
    required this.bookTitle,
    required this.author,
    required this.pages,
    this.note,
    this.rating,
    required this.category,
    this.mood,
    this.isShared = false,
  });

  /// 제목을 5글자로 축약
  String get shortTitle {
    if (bookTitle.length <= 5) return bookTitle;
    return '${bookTitle.substring(0, 5)}...';
  }

  /// 분야별 색상
  Color get categoryColor {
    switch (category) {
      case '소설': return const Color(0xFF6366F1);
      case '자기계발': return const Color(0xFF10B981);
      case '경영': return const Color(0xFFF59E0B);
      case '비즈니스': return const Color(0xFFF59E0B); // 경영과 동일하게 처리
      case '역사': return const Color(0xFFEF4444);
      case '과학': return const Color(0xFF8B5CF6);
      case '예술': return const Color(0xFFEC4899);
      case '철학': return const Color(0xFF3B82F6);
      case '종교': return const Color(0xFF059669);
      case '요리': return const Color(0xFFF97316);
      case '여행': return const Color(0xFF06B6D4);
      case 'IT': return const Color(0xFF3B82F6);
      case '에세이': return const Color(0xFFF59E0B);
      default: return const Color(0xFF6B7280);
    }
  }

  /// 분야별 이모지
  String get categoryEmoji {
    switch (category) {
      case '소설': return '📚';
      case '자기계발': return '💡';
      case '경영': return '💼';
      case '비즈니스': return '💼'; // 경영과 동일하게 처리
      case '역사': return '📜';
      case '과학': return '🔬';
      case '예술': return '🎨';
      case '철학': return '🤔';
      case '종교': return '🙏';
      case '요리': return '👨‍🍳';
      case '여행': return '✈️';
      case 'IT': return '💻';
      case '에세이': return '✍️';
      default: return '📖';
    }
  }

  /// 기분별 이모지
  String get moodEmoji {
    switch (mood) {
      case 'happy': return '😊';
      case 'excited': return '🤗';
      case 'thoughtful': return '🤔';
      case 'moved': return '🥺';
      case 'surprised': return '😮';
      case 'calm': return '😌';
      default: return '😊';
    }
  }

  /// 기분별 텍스트
  String get moodText {
    switch (mood) {
      case 'happy': return '기뻤어요';
      case 'excited': return '설렜어요';
      case 'thoughtful': return '생각이 많아졌어요';
      case 'moved': return '감동적이었어요';
      case 'surprised': return '놀라웠어요';
      case 'calm': return '편안했어요';
      default: return '기뻤어요';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'bookTitle': bookTitle,
      'author': author,
      'pages': pages,
      'note': note,
      'rating': rating,
      'category': category,
      'mood': mood,
      'isShared': isShared,
    };
  }

  factory ReadingLog.fromJson(Map<String, dynamic> json) {
    return ReadingLog(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      bookTitle: json['bookTitle'] ?? '',
      author: json['author'] ?? '',
      pages: json['pages'] ?? 0,
      note: json['note'],
      rating: json['rating']?.toDouble(),
      category: json['category'] ?? '기타',
      mood: json['mood'],
      isShared: json['isShared'] ?? false,
    );
  }
}

/// 운동 기록
class ExerciseLog {
  final String id;
  final DateTime date;
  final String exerciseType;
  final int durationMinutes;
  final String intensity;
  final String? note;
  final String? imageUrl;
  final bool isShared;

  const ExerciseLog({
    required this.id,
    required this.date,
    required this.exerciseType,
    required this.durationMinutes,
    required this.intensity,
    this.note,
    this.imageUrl,
    this.isShared = false,
  });

  /// 첨부 사진이 있는지 확인
  bool get hasPhoto => imageUrl != null && imageUrl!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exerciseType': exerciseType,
      'durationMinutes': durationMinutes,
      'intensity': intensity,
      'note': note,
      'imageUrl': imageUrl,
      'isShared': isShared,
    };
  }

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      exerciseType: json['exerciseType'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      intensity: json['intensity'] ?? 'medium',
      note: json['note'],
      imageUrl: json['imageUrl'],
      isShared: json['isShared'] ?? false,
    );
  }
}

/// 일기 기록 (개선된 버전)
class DiaryLog {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final String mood;
  final String? imageUrl;
  final String? musicUrl;
  final String? videoUrl;
  final bool isShared;

  const DiaryLog({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.mood,
    this.imageUrl,
    this.musicUrl,
    this.videoUrl,
    this.isShared = false,
  });

  /// 기분 이모지 가져오기
  String get moodEmoji {
    switch (mood) {
      case 'very_happy': return '😄';
      case 'happy': return '😊';
      case 'good': return '🙂';
      case 'normal': return '😐';
      case 'tired': return '😴';
      case 'sad': return '😢';
      case 'angry': return '😠';
      case 'excited': return '🤩';
      case 'grateful': return '🥰';
      case 'anxious': return '😰';
      case 'confused': return '😵';
      default: return '😊';
    }
  }

  /// 기분 텍스트 가져오기
  String get moodText {
    switch (mood) {
      case 'very_happy': return '매우 기쁨';
      case 'happy': return '기쁨';
      case 'good': return '좋음';
      case 'normal': return '보통';
      case 'tired': return '피곤';
      case 'sad': return '슬픔';
      case 'angry': return '화남';
      case 'excited': return '신남';
      case 'grateful': return '감사';
      case 'anxious': return '불안';
      case 'confused': return '혼란';
      default: return '보통';
    }
  }

  /// 첨부 파일이 있는지 확인
  bool get hasAttachments {
    return imageUrl != null || musicUrl != null || videoUrl != null;
  }

  DiaryLog copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    String? mood,
    String? imageUrl,
    String? musicUrl,
    String? videoUrl,
    bool? isShared,
  }) {
    return DiaryLog(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      imageUrl: imageUrl ?? this.imageUrl,
      musicUrl: musicUrl ?? this.musicUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isShared: isShared ?? this.isShared,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'mood': mood,
      'imageUrl': imageUrl,
      'musicUrl': musicUrl,
      'videoUrl': videoUrl,
      'isShared': isShared,
    };
  }

  factory DiaryLog.fromJson(Map<String, dynamic> json) {
    return DiaryLog(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      mood: json['mood'] ?? 'normal',
      imageUrl: json['imageUrl'],
      musicUrl: json['musicUrl'],
      videoUrl: json['videoUrl'],
      isShared: json['isShared'] ?? false,
    );
  }
}

/// 영화 기록
class MovieLog {
  final String id;
  final DateTime date;
  final String movieTitle;
  final String director;
  final String genre;
  final double rating;
  final String? review;
  final String? imageUrl;
  final bool isShared;
  final int watchTimeMinutes;

  const MovieLog({
    required this.id,
    required this.date,
    required this.movieTitle,
    required this.director,
    required this.genre,
    required this.rating,
    this.review,
    this.imageUrl,
    this.isShared = false,
    required this.watchTimeMinutes,
  });

  /// 장르별 이모지
  String get genreEmoji {
    switch (genre.toLowerCase()) {
      case '액션': return '🎬';
      case '코미디': return '😂';
      case '로맨스': return '💕';
      case '스릴러': return '😱';
      case 'sf': return '🚀';
      case '드라마': return '🎭';
      case '판타지': return '🧙‍♂️';
      case '애니메이션': return '🎨';
      case '다큐멘터리': return '📽️';
      case '공포': return '👻';
      default: return '🎬';
    }
  }

  /// 별점 텍스트
  String get ratingText {
    return '⭐ ${rating.toStringAsFixed(1)}';
  }

  /// 시청 시간 텍스트
  String get watchTimeText {
    final hours = watchTimeMinutes ~/ 60;
    final minutes = watchTimeMinutes % 60;
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  MovieLog copyWith({
    String? id,
    DateTime? date,
    String? movieTitle,
    String? director,
    String? genre,
    double? rating,
    String? review,
    String? imageUrl,
    bool? isShared,
    int? watchTimeMinutes,
  }) {
    return MovieLog(
      id: id ?? this.id,
      date: date ?? this.date,
      movieTitle: movieTitle ?? this.movieTitle,
      director: director ?? this.director,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      imageUrl: imageUrl ?? this.imageUrl,
      isShared: isShared ?? this.isShared,
      watchTimeMinutes: watchTimeMinutes ?? this.watchTimeMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'movieTitle': movieTitle,
      'director': director,
      'genre': genre,
      'rating': rating,
      'review': review,
      'imageUrl': imageUrl,
      'isShared': isShared,
      'watchTimeMinutes': watchTimeMinutes,
    };
  }

  factory MovieLog.fromJson(Map<String, dynamic> json) {
    return MovieLog(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      movieTitle: json['movieTitle'] ?? '',
      director: json['director'] ?? '',
      genre: json['genre'] ?? '드라마',
      rating: (json['rating'] ?? 0.0).toDouble(),
      review: json['review'],
      imageUrl: json['imageUrl'],
      isShared: json['isShared'] ?? false,
      watchTimeMinutes: json['watchTimeMinutes'] ?? 120,
    );
  }
}

/// 일일 목표
class DailyGoal {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isCompleted;
  final DateTime? completedAt;

  const DailyGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    this.completedAt,
  });

  /// 기본 일일 목표 생성
  static List<DailyGoal> createDefaultGoals() {
    return [
      DailyGoal(
        id: 'steps',
        title: '6000걸음 걷기',
        description: '오늘 6000걸음을 완주하세요',
        icon: '👟',
        isCompleted: false,
      ),
      DailyGoal(
        id: 'diary',
        title: '일기 작성',
        description: '오늘의 하루를 기록해보세요',
        icon: '📝',
        isCompleted: false,
      ),
      DailyGoal(
        id: 'exercise',
        title: '운동 기록 작성',
        description: '운동 활동을 기록하세요',
        icon: '💪',
        isCompleted: false,
      ),
      DailyGoal(
        id: 'focus',
        title: '30분 몰입',
        description: '집중 시간을 30분 유지하세요',
        icon: '⏰',
        isCompleted: false,
      ),
      DailyGoal(
        id: 'reading',
        title: '한페이지 이상 독서',
        description: '책을 읽고 기록하세요',
        icon: '📚',
        isCompleted: false,
      ),
    ];
  }

  DailyGoal copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return DailyGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    return DailyGoal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }
}

// ==================== 등반 시스템 모델들 ====================

/// 현재 등반 세션 상태
class ClimbingSession {
  final String id;
  final int mountainId;
  final String mountainName;
  final DateTime startTime;
  final double durationHours;
  final double successProbability;
  final bool isActive;
  final ClimbingSessionStatus status;
  final double userPower;
  final double mountainPower;
  final Map<String, dynamic>? metadata;

  const ClimbingSession({
    required this.id,
    required this.mountainId,
    required this.mountainName,
    required this.startTime,
    required this.durationHours,
    required this.successProbability,
    required this.isActive,
    required this.status,
    required this.userPower,
    required this.mountainPower,
    this.metadata,
  });

  /// 등반 예상 완료 시간
  DateTime get expectedEndTime {
    return startTime.add(Duration(milliseconds: (durationHours * 3600 * 1000).round()));
  }

  /// 등반 진행률 (0.0 ~ 1.0)
  double get progress {
    if (!isActive) return status == ClimbingSessionStatus.completed ? 1.0 : 0.0;

    final now = DateTime.now();
    final totalDuration = expectedEndTime.difference(startTime);
    final elapsed = now.difference(startTime);

    if (elapsed.isNegative) return 0.0;
    if (elapsed >= totalDuration) return 1.0;

    return elapsed.inMilliseconds / totalDuration.inMilliseconds;
  }

  /// 등반 남은 시간
  Duration get remainingTime {
    if (!isActive) return Duration.zero;

    final now = DateTime.now();
    final remaining = expectedEndTime.difference(now);

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 등반이 완료되었는지 확인
  bool get isCompleted {
    return status == ClimbingSessionStatus.completed ||
        status == ClimbingSessionStatus.failed;
  }

  ClimbingSession copyWith({
    String? id,
    int? mountainId,
    String? mountainName,
    DateTime? startTime,
    double? durationHours,
    double? successProbability,
    bool? isActive,
    ClimbingSessionStatus? status,
    double? userPower,
    double? mountainPower,
    Map<String, dynamic>? metadata,
  }) {
    return ClimbingSession(
      id: id ?? this.id,
      mountainId: mountainId ?? this.mountainId,
      mountainName: mountainName ?? this.mountainName,
      startTime: startTime ?? this.startTime,
      durationHours: durationHours ?? this.durationHours,
      successProbability: successProbability ?? this.successProbability,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      userPower: userPower ?? this.userPower,
      mountainPower: mountainPower ?? this.mountainPower,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mountainId': mountainId,
      'mountainName': mountainName,
      'startTime': startTime.toIso8601String(),
      'durationHours': durationHours,
      'successProbability': successProbability,
      'isActive': isActive,
      'status': status.name,
      'userPower': userPower,
      'mountainPower': mountainPower,
      'metadata': metadata,
    };
  }

  factory ClimbingSession.fromJson(Map<String, dynamic> json) {
    return ClimbingSession(
      id: json['id'] ?? '',
      mountainId: json['mountainId'] ?? 0,
      mountainName: json['mountainName'] ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      durationHours: (json['durationHours'] ?? 0).toDouble(),
      successProbability: (json['successProbability'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
      status: ClimbingSessionStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => ClimbingSessionStatus.pending,
      ),
      userPower: (json['userPower'] ?? 0).toDouble(),
      mountainPower: (json['mountainPower'] ?? 0).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// 등반 세션 상태
enum ClimbingSessionStatus {
  pending,    // 대기 중
  active,     // 등반 중
  completed,  // 성공 완료
  failed,     // 실패
  cancelled,  // 취소됨
}

/// 등반 완료 기록
class ClimbingRecord {
  final String id;
  final int mountainId;
  final String mountainName;
  final String region;
  final int difficulty;
  final DateTime startTime;
  final DateTime endTime;
  final double durationHours;
  final bool isSuccess;
  final double userPower;
  final double mountainPower;
  final double successProbability;
  final ClimbingRewards rewards;
  final String? failureReason;
  final Map<String, dynamic>? metadata;

  const ClimbingRecord({
    required this.id,
    required this.mountainId,
    required this.mountainName,
    required this.region,
    required this.difficulty,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.isSuccess,
    required this.userPower,
    required this.mountainPower,
    required this.successProbability,
    required this.rewards,
    this.failureReason,
    this.metadata,
  });

  /// 등반 결과 아이콘
  String get resultIcon {
    return isSuccess ? '🎉' : '💪';
  }

  /// 등반 결과 메시지
  String get resultMessage {
    return isSuccess ? '등반 성공!' : (failureReason ?? '아쉽지만 실패했습니다');
  }

  /// 난이도 색상
  Color get difficultyColor {
    if (difficulty >= 100) return const Color(0xFFDC2626); // 빨강 (신들의 산맥)
    if (difficulty >= 50) return const Color(0xFFEA580C); // 주황 (세계의 정상)
    if (difficulty >= 10) return const Color(0xFFFBBF24); // 노랑 (아시아의 지붕)
    return const Color(0xFF10B981); // 초록 (초심자/한국의 명산)
  }

  /// 등반 시간 (시:분 형식)
  String get formattedDuration {
    final hours = durationHours.floor();
    final minutes = ((durationHours - hours) * 60).round();

    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${(durationHours * 60).round()}분';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mountainId': mountainId,
      'mountainName': mountainName,
      'region': region,
      'difficulty': difficulty,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationHours': durationHours,
      'isSuccess': isSuccess,
      'userPower': userPower,
      'mountainPower': mountainPower,
      'successProbability': successProbability,
      'rewards': rewards.toJson(),
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  factory ClimbingRecord.fromJson(Map<String, dynamic> json) {
    return ClimbingRecord(
      id: json['id'] ?? '',
      mountainId: json['mountainId'] ?? 0,
      mountainName: json['mountainName'] ?? '',
      region: json['region'] ?? '',
      difficulty: json['difficulty'] ?? 0,
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      durationHours: (json['durationHours'] ?? 0).toDouble(),
      isSuccess: json['isSuccess'] ?? false,
      userPower: (json['userPower'] ?? 0).toDouble(),
      mountainPower: (json['mountainPower'] ?? 0).toDouble(),
      successProbability: (json['successProbability'] ?? 0).toDouble(),
      rewards: ClimbingRewards.fromJson(json['rewards'] ?? {}),
      failureReason: json['failureReason'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// 등반 보상
class ClimbingRewards {
  final double experience;
  final int points;
  final Map<String, double> statIncreases;
  final List<String> newBadgeIds;
  final String? specialReward;

  const ClimbingRewards({
    required this.experience,
    required this.points,
    required this.statIncreases,
    required this.newBadgeIds,
    this.specialReward,
  });

  /// 보상이 있는지 확인
  bool get hasRewards {
    return experience > 0 ||
        points > 0 ||
        statIncreases.isNotEmpty ||
        newBadgeIds.isNotEmpty ||
        specialReward != null;
  }

  /// 보상 요약 텍스트
  String get summaryText {
    final parts = <String>[];

    if (experience > 0) parts.add('경험치 +${experience.toInt()}');
    if (points > 0) parts.add('포인트 +$points');
    if (statIncreases.isNotEmpty) {
      final statTexts = statIncreases.entries.map((e) => '${_getStatName(e.key)} +${e.value.toStringAsFixed(1)}').toList();
      parts.addAll(statTexts);
    }
    if (newBadgeIds.isNotEmpty) parts.add('새 뱃지 ${newBadgeIds.length}개');
    if (specialReward != null) parts.add(specialReward!);

    return parts.join(', ');
  }

  String _getStatName(String statKey) {
    switch (statKey) {
      case 'stamina': return '체력';
      case 'knowledge': return '지식';
      case 'technique': return '기술';
      case 'sociality': return '사교성';
      case 'willpower': return '의지';
      default: return statKey;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'experience': experience,
      'points': points,
      'statIncreases': statIncreases,
      'newBadgeIds': newBadgeIds,
      'specialReward': specialReward,
    };
  }

  factory ClimbingRewards.fromJson(Map<String, dynamic> json) {
    return ClimbingRewards(
      experience: (json['experience'] ?? 0).toDouble(),
      points: json['points'] ?? 0,
      statIncreases: Map<String, double>.from(json['statIncreases'] ?? {}),
      newBadgeIds: List<String>.from(json['newBadgeIds'] ?? []),
      specialReward: json['specialReward'],
    );
  }
}

/// 등반 통계 (계산된 값)
class ClimbingStatistics {
  final int totalAttempts;
  final int successfulAttempts;
  final double successRate;
  final double totalExperience;
  final int totalPoints;
  final Map<String, int> regionProgress;
  final ClimbingRecord? lastRecord;
  final ClimbingRecord? bestRecord;
  final int currentStreak;

  const ClimbingStatistics({
    required this.totalAttempts,
    required this.successfulAttempts,
    required this.successRate,
    required this.totalExperience,
    required this.totalPoints,
    required this.regionProgress,
    this.lastRecord,
    this.bestRecord,
    required this.currentStreak,
  });

  /// 통계 생성 (등반 기록들로부터 계산)
  factory ClimbingStatistics.fromRecords(List<ClimbingRecord> records) {
    if (records.isEmpty) {
      return const ClimbingStatistics(
        totalAttempts: 0,
        successfulAttempts: 0,
        successRate: 0.0,
        totalExperience: 0.0,
        totalPoints: 0,
        regionProgress: {},
        currentStreak: 0,
      );
    }

    final totalAttempts = records.length;
    final successfulAttempts = records.where((r) => r.isSuccess).length;
    final successRate = successfulAttempts / totalAttempts;

    final totalExperience = records.fold<double>(0, (sum, r) => sum + r.rewards.experience);
    final totalPoints = records.fold<int>(0, (sum, r) => sum + r.rewards.points);

    // 지역별 진행도
    final regionProgress = <String, int>{};
    for (final record in records) {
      if (record.isSuccess) {
        regionProgress[record.region] = (regionProgress[record.region] ?? 0) + 1;
      }
    }

    // 최근 기록과 최고 기록
    final sortedRecords = List<ClimbingRecord>.from(records)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final lastRecord = sortedRecords.first;
    final bestRecord = records.where((r) => r.isSuccess)
        .fold<ClimbingRecord?>(null, (best, current) {
      if (best == null) return current;
      return current.difficulty > best.difficulty ? current : best;
    });

    // 현재 연속 성공 횟수
    int currentStreak = 0;
    for (final record in sortedRecords) {
      if (record.isSuccess) {
        currentStreak++;
      } else {
        break;
      }
    }

    return ClimbingStatistics(
      totalAttempts: totalAttempts,
      successfulAttempts: successfulAttempts,
      successRate: successRate,
      totalExperience: totalExperience,
      totalPoints: totalPoints,
      regionProgress: regionProgress,
      lastRecord: lastRecord,
      bestRecord: bestRecord,
      currentStreak: currentStreak,
    );
  }
}

// ==================== 참린지 시스템 모델들 ====================

/// 참린지 참여 기록
class ChallengeRecord {
  final String id;
  final String challengeId;
  final String challengeTitle;
  final String category;
  final int duration; // 일 수
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCompleted;
  final int progressDays; // 진행한 일 수
  final double completionRate; // 완료율
  final ChallengeRewards rewards;
  final Map<String, dynamic>? metadata;

  const ChallengeRecord({
    required this.id,
    required this.challengeId,
    required this.challengeTitle,
    required this.category,
    required this.duration,
    required this.startDate,
    this.endDate,
    required this.isCompleted,
    required this.progressDays,
    required this.completionRate,
    required this.rewards,
    this.metadata,
  });

  /// 참린지 상태 아이콘
  String get statusIcon {
    if (isCompleted) return '🏆';
    if (completionRate >= 0.8) return '🔥';
    if (completionRate >= 0.5) return '💪';
    return '🌱';
  }

  /// 참린지 상태 메시지
  String get statusMessage {
    if (isCompleted) return '참린지 완주!';
    return '진행 중... ${progressDays}/${duration}일';
  }

  /// 카테고리에 따른 색상
  Color get categoryColor {
    switch (category) {
      case 'fitness': return const Color(0xFFEF4444); // 빨강
      case 'study': return const Color(0xFF3B82F6); // 파랑
      case 'habit': return const Color(0xFF10B981); // 초록
      case 'mindfulness': return const Color(0xFF8B5CF6); // 보라
      case 'creativity': return const Color(0xFFF59E0B); // 노랑
      default: return const Color(0xFF6B7280); // 회색
    }
  }

  /// 참린지 기간 형식
  String get formattedDuration {
    if (duration >= 30) {
      return '${(duration / 30).round()}개월';
    } else {
      return '${duration}일';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeId': challengeId,
      'challengeTitle': challengeTitle,
      'category': category,
      'duration': duration,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'progressDays': progressDays,
      'completionRate': completionRate,
      'rewards': rewards.toJson(),
      'metadata': metadata,
    };
  }

  factory ChallengeRecord.fromJson(Map<String, dynamic> json) {
    return ChallengeRecord(
      id: json['id'] ?? '',
      challengeId: json['challengeId'] ?? '',
      challengeTitle: json['challengeTitle'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? 0,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      progressDays: json['progressDays'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
      rewards: ChallengeRewards.fromJson(json['rewards'] ?? {}),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// 참린지 보상
class ChallengeRewards {
  final double experience;
  final int points;
  final Map<String, double> statIncreases;
  final List<String> newBadgeIds;
  final String? specialReward;

  const ChallengeRewards({
    required this.experience,
    required this.points,
    required this.statIncreases,
    required this.newBadgeIds,
    this.specialReward,
  });

  /// 보상이 있는지 확인
  bool get hasRewards {
    return experience > 0 ||
        points > 0 ||
        statIncreases.isNotEmpty ||
        newBadgeIds.isNotEmpty ||
        specialReward != null;
  }

  /// 보상 요약 텍스트
  String get summaryText {
    final parts = <String>[];

    if (experience > 0) parts.add('경험치 +${experience.toInt()}');
    if (points > 0) parts.add('포인트 +$points');
    if (statIncreases.isNotEmpty) {
      final statTexts = statIncreases.entries.map((e) => '${_getStatName(e.key)} +${e.value.toStringAsFixed(1)}').toList();
      parts.addAll(statTexts);
    }
    if (newBadgeIds.isNotEmpty) parts.add('새 배지 ${newBadgeIds.length}개');
    if (specialReward != null) parts.add(specialReward!);

    return parts.join(', ');
  }

  String _getStatName(String statKey) {
    switch (statKey) {
      case 'stamina': return '체력';
      case 'knowledge': return '지식';
      case 'technique': return '기술';
      case 'sociality': return '사교성';
      case 'willpower': return '의지';
      default: return statKey;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'experience': experience,
      'points': points,
      'statIncreases': statIncreases,
      'newBadgeIds': newBadgeIds,
      'specialReward': specialReward,
    };
  }

  factory ChallengeRewards.fromJson(Map<String, dynamic> json) {
    return ChallengeRewards(
      experience: (json['experience'] ?? 0).toDouble(),
      points: json['points'] ?? 0,
      statIncreases: Map<String, double>.from(json['statIncreases'] ?? {}),
      newBadgeIds: List<String>.from(json['newBadgeIds'] ?? []),
      specialReward: json['specialReward'],
    );
  }
}

/// 사용자 계획 데이터
class UserPlanningData {
  final List<UserGoal> goals;
  final List<UserGoal> completedGoals;
  final DateTime? lastPlanningDate;
  final int totalGoalsCreated;
  final int totalGoalsCompleted;
  final Map<String, int> categoryStats;

  const UserPlanningData({
    required this.goals,
    required this.completedGoals,
    this.lastPlanningDate,
    required this.totalGoalsCreated,
    required this.totalGoalsCompleted,
    required this.categoryStats,
  });

  /// 활성 목표 수
  int get activeGoalsCount => goals.where((g) => g.isActive).length;

  /// 전체 달성률
  double get overallCompletionRate {
    if (totalGoalsCreated == 0) return 0.0;
    return (totalGoalsCompleted / totalGoalsCreated) * 100;
  }

  UserPlanningData copyWith({
    List<UserGoal>? goals,
    List<UserGoal>? completedGoals,
    DateTime? lastPlanningDate,
    int? totalGoalsCreated,
    int? totalGoalsCompleted,
    Map<String, int>? categoryStats,
  }) {
    return UserPlanningData(
      goals: goals ?? this.goals,
      completedGoals: completedGoals ?? this.completedGoals,
      lastPlanningDate: lastPlanningDate ?? this.lastPlanningDate,
      totalGoalsCreated: totalGoalsCreated ?? this.totalGoalsCreated,
      totalGoalsCompleted: totalGoalsCompleted ?? this.totalGoalsCompleted,
      categoryStats: categoryStats ?? this.categoryStats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goals': goals.map((g) => g.toJson()).toList(),
      'completedGoals': completedGoals.map((g) => g.toJson()).toList(),
      'lastPlanningDate': lastPlanningDate?.toIso8601String(),
      'totalGoalsCreated': totalGoalsCreated,
      'totalGoalsCompleted': totalGoalsCompleted,
      'categoryStats': categoryStats,
    };
  }

  factory UserPlanningData.fromJson(Map<String, dynamic> json) {
    return UserPlanningData(
      goals: (json['goals'] as List<dynamic>?)
          ?.map((g) => UserGoal.fromJson(g))
          .toList() ?? [],
      completedGoals: (json['completedGoals'] as List<dynamic>?)
          ?.map((g) => UserGoal.fromJson(g))
          .toList() ?? [],
      lastPlanningDate: json['lastPlanningDate'] != null
          ? DateTime.parse(json['lastPlanningDate'])
          : null,
      totalGoalsCreated: json['totalGoalsCreated'] ?? 0,
      totalGoalsCompleted: json['totalGoalsCompleted'] ?? 0,
      categoryStats: Map<String, int>.from(json['categoryStats'] ?? {}),
    );
  }

  /// 빈 계획 데이터 생성
  factory UserPlanningData.empty() {
    return const UserPlanningData(
      goals: [],
      completedGoals: [],
      totalGoalsCreated: 0,
      totalGoalsCompleted: 0,
      categoryStats: {},
    );
  }
}

/// 사용자 목표
class UserGoal {
  final String id;
  final String title;
  final String? description;
  final String category;
  final int duration; // 일 단위
  final String? schedule;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double progress;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const UserGoal({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.duration,
    this.schedule,
    required this.createdAt,
    this.completedAt,
    required this.progress,
    required this.isActive,
    this.metadata,
  });

  /// 남은 일수 계산
  int get daysRemaining {
    if (!isActive) return 0;
    final elapsed = DateTime.now().difference(createdAt).inDays;
    final remaining = duration - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  /// 진행률 계산 (시간 기반)
  double get timeBasedProgress {
    if (!isActive) return 0.0;
    final elapsed = DateTime.now().difference(createdAt).inDays;
    if (elapsed >= duration) return 100.0;
    return (elapsed / duration) * 100;
  }

  UserGoal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? duration,
    String? schedule,
    DateTime? createdAt,
    DateTime? completedAt,
    double? progress,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return UserGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'schedule': schedule,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'growth',
      duration: json['duration'] ?? 7,
      schedule: json['schedule'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      progress: (json['progress'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }
}