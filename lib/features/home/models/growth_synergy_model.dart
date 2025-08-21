import 'package:flutter/material.dart';

// ============================================================================
// ENUMS - 모든 열거형 정의
// ============================================================================

enum GrowthGoalType {
  networking,
  leadership,
  communication,
  creativity,
  health,
  learning,
  productivity,
  emotional
}

enum SkillCategory {
  softSkills,
  hardSkills,
  socialSkills,
  leadershipSkills,
  creativeSkills
}

enum QuestType {
  personal,
  meeting,
  group,
  challenge,
  university,
  department,
  career
}


enum MeetingCategory {
  networking,
  study,
  exercise,
  social,
  career,
  hobby,        // ✅ 추가
  culture,      // ✅ 추가
  volunteer     // ✅ 추가
}


// ============================================================================
// BASIC MODELS - 기본 모델들
// ============================================================================

/// 성장 지표를 나타내는 모델
class GrowthMetric {
  final String id;
  final String name;
  final SkillCategory category;
  final double currentLevel;
  final double previousLevel;
  final double targetLevel;
  final DateTime lastUpdated;
  final List<double> weeklyProgress;
  final Map<String, double> meetingContributions;

  const GrowthMetric({
    required this.id,
    required this.name,
    required this.category,
    required this.currentLevel,
    required this.previousLevel,
    required this.targetLevel,
    required this.lastUpdated,
    required this.weeklyProgress,
    required this.meetingContributions,
  });

  double get progressRate => targetLevel > previousLevel
      ? (currentLevel - previousLevel) / (targetLevel - previousLevel)
      : 0.0;

  double get weeklyGrowth => weeklyProgress.isNotEmpty ?
  weeklyProgress.last - (weeklyProgress.length > 1 ? weeklyProgress[weeklyProgress.length - 2] : 0) : 0;

  GrowthMetric copyWith({
    String? id,
    String? name,
    SkillCategory? category,
    double? currentLevel,
    double? previousLevel,
    double? targetLevel,
    DateTime? lastUpdated,
    List<double>? weeklyProgress,
    Map<String, double>? meetingContributions,
  }) {
    return GrowthMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentLevel: currentLevel ?? this.currentLevel,
      previousLevel: previousLevel ?? this.previousLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      meetingContributions: meetingContributions ?? this.meetingContributions,
    );
  }
}

/// 개인 성장 목표 모델
class PersonalGrowthGoal {
  final String id;
  final String title;
  final String description;
  final GrowthGoalType type;
  final double currentProgress;
  final double targetValue;
  final DateTime deadline;
  final List<String> relatedMeetingIds;
  final Map<String, double> skillImpacts;
  final bool isCompleted;

  const PersonalGrowthGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.currentProgress,
    required this.targetValue,
    required this.deadline,
    required this.relatedMeetingIds,
    required this.skillImpacts,
    this.isCompleted = false,
  });

  double get progressPercentage => targetValue > 0
      ? (currentProgress / targetValue * 100).clamp(0, 100)
      : 0.0;

  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  PersonalGrowthGoal copyWith({
    String? id,
    String? title,
    String? description,
    GrowthGoalType? type,
    double? currentProgress,
    double? targetValue,
    DateTime? deadline,
    List<String>? relatedMeetingIds,
    Map<String, double>? skillImpacts,
    bool? isCompleted,
  }) {
    return PersonalGrowthGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      currentProgress: currentProgress ?? this.currentProgress,
      targetValue: targetValue ?? this.targetValue,
      deadline: deadline ?? this.deadline,
      relatedMeetingIds: relatedMeetingIds ?? this.relatedMeetingIds,
      skillImpacts: skillImpacts ?? this.skillImpacts,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// 친구 성장 비교 모델
class FriendGrowthComparison {
  final String friendId;
  final String friendName;
  final String friendAvatar;
  final int currentLevel;
  final int currentStreak;
  final int meetingParticipations;
  final double weeklyGrowthRate;
  final List<String> recentAchievements;
  final bool isOnline;

  const FriendGrowthComparison({
    required this.friendId,
    required this.friendName,
    required this.friendAvatar,
    required this.currentLevel,
    required this.currentStreak,
    required this.meetingParticipations,
    required this.weeklyGrowthRate,
    required this.recentAchievements,
    this.isOnline = false,
  });

  int get totalScore => currentLevel * 10 + currentStreak * 5 + meetingParticipations * 3;
}

/// 주간 성장 하이라이트 모델
class WeeklyGrowthHighlight {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final double improvementRate;
  final List<String> contributingMeetings;
  final Map<String, dynamic> metrics;
  final DateTime achievedAt;

  const WeeklyGrowthHighlight({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.improvementRate,
    required this.contributingMeetings,
    required this.metrics,
    required this.achievedAt,
  });
}

// ============================================================================
// UNIVERSITY MODELS - 대학 관련 모델들
// ============================================================================

/// 대학 정보 모델
class UniversityInfo {
  final String universityId;
  final String universityName;
  final String department;
  final String studentId;
  final String grade;
  final bool isVerified;
  final DateTime enrollmentYear;
  final String campusLocation;

  const UniversityInfo({
    required this.universityId,
    required this.universityName,
    required this.department,
    required this.studentId,
    required this.grade,
    required this.isVerified,
    required this.enrollmentYear,
    required this.campusLocation,
  });

  UniversityInfo copyWith({
    String? universityId,
    String? universityName,
    String? department,
    String? studentId,
    String? grade,
    bool? isVerified,
    DateTime? enrollmentYear,
    String? campusLocation,
  }) {
    return UniversityInfo(
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      department: department ?? this.department,
      studentId: studentId ?? this.studentId,
      grade: grade ?? this.grade,
      isVerified: isVerified ?? this.isVerified,
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
      campusLocation: campusLocation ?? this.campusLocation,
    );
  }

  factory UniversityInfo.empty() {
    return UniversityInfo(
      universityId: '',
      universityName: '',
      department: '',
      studentId: '',
      grade: '',
      isVerified: false,
      enrollmentYear: DateTime.now(),
      campusLocation: '',
    );
  }
}

/// 대학 길드 모델
class UniversityGuild {
  final String guildId;
  final String universityId;
  final String universityName;
  final int guildLevel;
  final int totalMembers;
  final int activeMembers;
  final int nationalRanking;
  final double weeklyProgress;
  final List<String> recentAchievements;
  final Map<String, int> departmentCounts;
  final DateTime lastUpdated;
  final double totalScore;
  final double weeklyScore;
  final List<String> onlineMembers;
  final List<GuildCompetition> activeCompetitions;
  final Map<String, dynamic> guildSettings;

  const UniversityGuild({
    required this.guildId,
    required this.universityId,
    required this.universityName,
    required this.guildLevel,
    required this.totalMembers,
    required this.activeMembers,
    required this.nationalRanking,
    required this.weeklyProgress,
    required this.recentAchievements,
    required this.departmentCounts,
    required this.lastUpdated,
    required this.totalScore,
    required this.weeklyScore,
    required this.onlineMembers,
    required this.activeCompetitions,
    required this.guildSettings,
  });

  double get activityRate => totalMembers > 0 ? (activeMembers / totalMembers * 100) : 0.0;
  int get onlineMemberCount => onlineMembers.length;
  bool get hasActiveCompetition => activeCompetitions.any((comp) => comp.isActive);

  UniversityGuild copyWith({
    String? guildId,
    String? universityId,
    String? universityName,
    int? guildLevel,
    int? totalMembers,
    int? activeMembers,
    int? nationalRanking,
    double? weeklyProgress,
    List<String>? recentAchievements,
    Map<String, int>? departmentCounts,
    DateTime? lastUpdated,
    double? totalScore,
    double? weeklyScore,
    List<String>? onlineMembers,
    List<GuildCompetition>? activeCompetitions,
    Map<String, dynamic>? guildSettings,
  }) {
    return UniversityGuild(
      guildId: guildId ?? this.guildId,
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      guildLevel: guildLevel ?? this.guildLevel,
      totalMembers: totalMembers ?? this.totalMembers,
      activeMembers: activeMembers ?? this.activeMembers,
      nationalRanking: nationalRanking ?? this.nationalRanking,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      recentAchievements: recentAchievements ?? this.recentAchievements,
      departmentCounts: departmentCounts ?? this.departmentCounts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalScore: totalScore ?? this.totalScore,
      weeklyScore: weeklyScore ?? this.weeklyScore,
      onlineMembers: onlineMembers ?? this.onlineMembers,
      activeCompetitions: activeCompetitions ?? this.activeCompetitions,
      guildSettings: guildSettings ?? this.guildSettings,
    );
  }
}

/// 대학 길드 멤버 모델
class UniversityGuildMember {
  final String memberId;
  final String memberName;
  final String memberAvatar;
  final UniversityInfo universityInfo;
  final String guildRole;
  final int guildContributionScore;
  final int departmentRanking;
  final List<String> mentorshipConnections;
  final int currentLevel;
  final int currentStreak;
  final int meetingParticipations;
  final double weeklyGrowthRate;
  final List<String> recentAchievements;
  final bool isOnline;
  final DateTime lastActive;

  const UniversityGuildMember({
    required this.memberId,
    required this.memberName,
    required this.memberAvatar,
    required this.universityInfo,
    required this.guildRole,
    required this.guildContributionScore,
    required this.departmentRanking,
    required this.mentorshipConnections,
    required this.currentLevel,
    required this.currentStreak,
    required this.meetingParticipations,
    required this.weeklyGrowthRate,
    required this.recentAchievements,
    required this.isOnline,
    required this.lastActive,
  });

  String get roleDisplayName {
    switch (guildRole) {
      case 'leader':
        return '길드장';
      case 'mentor':
        return '멘토';
      case 'senior':
        return '선배';
      case 'junior':
        return '후배';
      default:
        return '멤버';
    }
  }

  Color get roleColor {
    switch (guildRole) {
      case 'leader':
        return Colors.amber;
      case 'mentor':
        return Colors.purple;
      case 'senior':
        return Colors.blue;
      case 'junior':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  int get totalScore => currentLevel * 10 + currentStreak * 5 + meetingParticipations * 3;
}

// ============================================================================
// CAMPUS MODELS - 캠퍼스 관련 모델들
// ============================================================================

/// 캠퍼스 위치 정보 모델
class CampusLocation {
  final String locationId;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String buildingCode;
  final String floor;
  final int capacity;
  final List<String> facilities;
  final bool isAvailable;
  final Map<String, dynamic> operatingHours;

  const CampusLocation({
    required this.locationId,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.buildingCode,
    required this.floor,
    required this.capacity,
    required this.facilities,
    required this.isAvailable,
    required this.operatingHours,
  });

  String get fullAddress => '$buildingCode $floor $name';
  bool get hasWifi => facilities.contains('wifi');
  bool get hasProjector => facilities.contains('projector');
  bool get hasWhiteboard => facilities.contains('whiteboard');
}

/// 캠퍼스 건물 정보 모델
class CampusBuilding {
  final String buildingId;
  final String buildingName;
  final String buildingCode;
  final double latitude;
  final double longitude;
  final List<CampusLocation> locations;
  final String buildingType;
  final Map<String, dynamic> buildingInfo;

  const CampusBuilding({
    required this.buildingId,
    required this.buildingName,
    required this.buildingCode,
    required this.latitude,
    required this.longitude,
    required this.locations,
    required this.buildingType,
    required this.buildingInfo,
  });

  int get totalCapacity => locations.fold(0, (sum, location) => sum + location.capacity);
  int get availableLocations => locations.where((location) => location.isAvailable).length;
}

/// 캠퍼스 이벤트 모델
class CampusEvent {
  final String eventId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final CampusLocation location;
  final String eventType;
  final List<String> organizers;
  final int maxParticipants;
  final int currentParticipants;
  final bool isPublic;
  final Map<String, dynamic> eventDetails;

  const CampusEvent({
    required this.eventId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.eventType,
    required this.organizers,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.isPublic,
    required this.eventDetails,
  });

  bool get isFull => currentParticipants >= maxParticipants;
  Duration get timeUntilStart => startTime.difference(DateTime.now());
  bool get isOngoing => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);

  // 🎓 isToday getter 추가 (에러 해결)
  bool get isToday =>
      DateTime.now().day == startTime.day &&
          DateTime.now().month == startTime.month &&
          DateTime.now().year == startTime.year;

  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get hasEnded => DateTime.now().isAfter(endTime);
}

/// 학사 일정 모델
class AcademicSchedule {
  final String scheduleId;
  final String title;
  final String description;
  final DateTime date;
  final String scheduleType;
  final String department;
  final bool isImportant;
  final Map<String, dynamic> additionalInfo;

  const AcademicSchedule({
    required this.scheduleId,
    required this.title,
    required this.description,
    required this.date,
    required this.scheduleType,
    required this.department,
    required this.isImportant,
    required this.additionalInfo,
  });

  Duration get timeUntilDate => date.difference(DateTime.now());
  bool get isToday => DateTime.now().day == date.day &&
      DateTime.now().month == date.month &&
      DateTime.now().year == date.year;
  bool get isThisWeek => timeUntilDate.inDays <= 7 && timeUntilDate.inDays >= 0;
}

// ============================================================================
// GUILD COMPETITION MODELS - 길드 대항전 모델들
// ============================================================================

/// 길드 랭킹 모델
class GuildRanking {
  final String guildId;
  final String universityName;
  final int currentRank;
  final int previousRank;
  final double totalScore;
  final double weeklyScore;
  final int totalMembers;
  final int activeMembers;
  final List<String> recentAchievements;
  final DateTime lastUpdated;

  const GuildRanking({
    required this.guildId,
    required this.universityName,
    required this.currentRank,
    required this.previousRank,
    required this.totalScore,
    required this.weeklyScore,
    required this.totalMembers,
    required this.activeMembers,
    required this.recentAchievements,
    required this.lastUpdated,
  });

  int get rankChange => previousRank - currentRank;
  bool get isRankUp => rankChange > 0;
  bool get isRankDown => rankChange < 0;

  String get rankChangeText {
    if (rankChange > 0) return '↗️ +$rankChange';
    if (rankChange < 0) return '↘️ ${rankChange.abs()}';
    return '➡️ 0';
  }

  Color get rankChangeColor {
    if (rankChange > 0) return Colors.green;
    if (rankChange < 0) return Colors.red;
    return Colors.grey;
  }

  GuildRanking copyWith({
    String? guildId,
    String? universityName,
    int? currentRank,
    int? previousRank,
    double? totalScore,
    double? weeklyScore,
    int? totalMembers,
    int? activeMembers,
    List<String>? recentAchievements,
    DateTime? lastUpdated,
  }) {
    return GuildRanking(
      guildId: guildId ?? this.guildId,
      universityName: universityName ?? this.universityName,
      currentRank: currentRank ?? this.currentRank,
      previousRank: previousRank ?? this.previousRank,
      totalScore: totalScore ?? this.totalScore,
      weeklyScore: weeklyScore ?? this.weeklyScore,
      totalMembers: totalMembers ?? this.totalMembers,
      activeMembers: activeMembers ?? this.activeMembers,
      recentAchievements: recentAchievements ?? this.recentAchievements,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// 길드 대항전 모델
class GuildCompetition {
  final String competitionId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participatingGuilds;
  final Map<String, double> guildScores;
  final String competitionType;
  final Map<String, dynamic> rewards;
  final bool isActive;

  const GuildCompetition({
    required this.competitionId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.participatingGuilds,
    required this.guildScores,
    required this.competitionType,
    required this.rewards,
    required this.isActive,
  });

  Duration get timeRemaining => endDate.difference(DateTime.now());
  bool get isEnded => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  double get progressPercentage {
    if (isUpcoming) return 0.0;
    if (isEnded) return 100.0;

    final total = endDate.difference(startDate).inMilliseconds;
    final elapsed = DateTime.now().difference(startDate).inMilliseconds;
    return (elapsed / total * 100).clamp(0, 100);
  }

  List<MapEntry<String, double>> get sortedGuildScores {
    final entries = guildScores.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
}

// ============================================================================
// AI RECOMMENDATION MODELS - AI 추천 모델들
// ============================================================================

/// AI 추천 점수 모델
class MeetingRecommendationScore {
  final String meetingId;
  final double personalGrowthScore;
  final double socialSynergyScore;
  final double skillMatchScore;
  final double timingScore;
  final double universityMatchScore;
  final double overallScore;
  final Map<String, double> expectedGrowthImpacts;
  final List<String> reasoningFactors;

  const MeetingRecommendationScore({
    required this.meetingId,
    required this.personalGrowthScore,
    required this.socialSynergyScore,
    required this.skillMatchScore,
    required this.timingScore,
    required this.universityMatchScore,
    required this.overallScore,
    required this.expectedGrowthImpacts,
    required this.reasoningFactors,
  });

  String get recommendationLevel {
    if (overallScore >= 0.9) return '강력 추천';
    if (overallScore >= 0.7) return '추천';
    if (overallScore >= 0.5) return '고려해볼만함';
    return '관심 있다면';
  }

  Color get recommendationColor {
    if (overallScore >= 0.9) return const Color(0xFF4CAF50);
    if (overallScore >= 0.7) return const Color(0xFF2196F3);
    if (overallScore >= 0.5) return const Color(0xFFFF9800);
    return const Color(0xFF9E9E9E);
  }
}

// ============================================================================
// MAIN STATE MODEL - 메인 상태 모델
// ============================================================================

/// 성장 시너지 상태 모델 (메인)
class GrowthSynergyState {
  final List<GrowthMetric> growthMetrics;
  final List<PersonalGrowthGoal> personalGoals;
  final List<FriendGrowthComparison> friendComparisons;
  final List<WeeklyGrowthHighlight> weeklyHighlights;
  final Map<String, double> meetingImpactScores;
  final double overallSynergyScore;

  // 대학 관련 필드들
  final UniversityInfo? myUniversityInfo;
  final UniversityGuild? myGuild;
  final List<UniversityGuildMember> guildMembers;
  final int myGuildRanking;
  final double guildSynergyScore;
  final List<UniversityGuild> rivalGuilds;

  // Phase 2 관련 필드들
  final List<GuildRanking> guildRankings;
  final List<GuildCompetition> activeCompetitions;
  final List<CampusBuilding> campusBuildings;
  final List<CampusEvent> campusEvents;
  final List<AcademicSchedule> academicSchedules;
  final CampusLocation? currentLocation;

  final bool isLoading;
  final String? error;

  const GrowthSynergyState({
    required this.growthMetrics,
    required this.personalGoals,
    required this.friendComparisons,
    required this.weeklyHighlights,
    required this.meetingImpactScores,
    required this.overallSynergyScore,
    this.myUniversityInfo,
    this.myGuild,
    required this.guildMembers,
    required this.myGuildRanking,
    required this.guildSynergyScore,
    required this.rivalGuilds,
    required this.guildRankings,
    required this.activeCompetitions,
    required this.campusBuildings,
    required this.campusEvents,
    required this.academicSchedules,
    this.currentLocation,
    this.isLoading = false,
    this.error,
  });

  // 편의 getter들
  GuildRanking? get myGuildRanking_obj =>
      guildRankings.where((ranking) => ranking.guildId == myGuild?.guildId).firstOrNull;

  List<GuildCompetition> get myActiveCompetitions =>
      activeCompetitions.where((comp) =>
          comp.participatingGuilds.contains(myGuild?.guildId)).toList();

  List<CampusEvent> get todayEvents =>
      campusEvents.where((event) => event.isToday).toList();

  GrowthSynergyState copyWith({
    List<GrowthMetric>? growthMetrics,
    List<PersonalGrowthGoal>? personalGoals,
    List<FriendGrowthComparison>? friendComparisons,
    List<WeeklyGrowthHighlight>? weeklyHighlights,
    Map<String, double>? meetingImpactScores,
    double? overallSynergyScore,
    UniversityInfo? myUniversityInfo,
    UniversityGuild? myGuild,
    List<UniversityGuildMember>? guildMembers,
    int? myGuildRanking,
    double? guildSynergyScore,
    List<UniversityGuild>? rivalGuilds,
    List<GuildRanking>? guildRankings,
    List<GuildCompetition>? activeCompetitions,
    List<CampusBuilding>? campusBuildings,
    List<CampusEvent>? campusEvents,
    List<AcademicSchedule>? academicSchedules,
    CampusLocation? currentLocation,
    bool? isLoading,
    String? error,
  }) {
    return GrowthSynergyState(
      growthMetrics: growthMetrics ?? this.growthMetrics,
      personalGoals: personalGoals ?? this.personalGoals,
      friendComparisons: friendComparisons ?? this.friendComparisons,
      weeklyHighlights: weeklyHighlights ?? this.weeklyHighlights,
      meetingImpactScores: meetingImpactScores ?? this.meetingImpactScores,
      overallSynergyScore: overallSynergyScore ?? this.overallSynergyScore,
      myUniversityInfo: myUniversityInfo ?? this.myUniversityInfo,
      myGuild: myGuild ?? this.myGuild,
      guildMembers: guildMembers ?? this.guildMembers,
      myGuildRanking: myGuildRanking ?? this.myGuildRanking,
      guildSynergyScore: guildSynergyScore ?? this.guildSynergyScore,
      rivalGuilds: rivalGuilds ?? this.rivalGuilds,
      guildRankings: guildRankings ?? this.guildRankings,
      activeCompetitions: activeCompetitions ?? this.activeCompetitions,
      campusBuildings: campusBuildings ?? this.campusBuildings,
      campusEvents: campusEvents ?? this.campusEvents,
      academicSchedules: academicSchedules ?? this.academicSchedules,
      currentLocation: currentLocation ?? this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory GrowthSynergyState.initial() {
    return const GrowthSynergyState(
      growthMetrics: [],
      personalGoals: [],
      friendComparisons: [],
      weeklyHighlights: [],
      meetingImpactScores: {},
      overallSynergyScore: 0.0,
      myUniversityInfo: null,
      myGuild: null,
      guildMembers: [],
      myGuildRanking: 0,
      guildSynergyScore: 0.0,
      rivalGuilds: [],
      guildRankings: [],
      activeCompetitions: [],
      campusBuildings: [],
      campusEvents: [],
      academicSchedules: [],
      currentLocation: null,
      isLoading: false,
    );
  }
}
