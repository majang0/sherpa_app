import 'package:flutter/foundation.dart';

/// 등반 세션 상태
enum ClimbingSessionStatus {
  active,      // 등반 중
  completed,   // 성공 완료
  failed,      // 실패 완료
  cancelled,   // 취소됨
}

/// 등반 세션 정보
@immutable
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

  /// 등반 진행률 (0.0 ~ 1.0)
  double get progress {
    if (!isActive) return 1.0;
    
    final now = DateTime.now();
    final elapsed = now.difference(startTime).inMilliseconds / (1000 * 3600); // 시간 단위
    return (elapsed / durationHours).clamp(0.0, 1.0);
  }

  /// 남은 시간
  Duration get remainingTime {
    if (!isActive) return Duration.zero;
    
    final now = DateTime.now();
    final elapsed = now.difference(startTime);
    final totalDuration = Duration(milliseconds: (durationHours * 3600 * 1000).round());
    final remaining = totalDuration - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 예상 완료 시간
  DateTime get expectedEndTime {
    return startTime.add(Duration(milliseconds: (durationHours * 3600 * 1000).round()));
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
        orElse: () => ClimbingSessionStatus.cancelled,
      ),
      userPower: (json['userPower'] ?? 0).toDouble(),
      mountainPower: (json['mountainPower'] ?? 0).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// 등반 보상 정보
@immutable
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

  bool get hasRewards => experience > 0 || points > 0 || statIncreases.isNotEmpty;

  String get summaryText {
    final parts = <String>[];
    
    if (experience > 0) {
      parts.add('경험치 +${experience.toStringAsFixed(1)}');
    }
    
    if (points > 0) {
      parts.add('포인트 +$points');
    }
    
    if (statIncreases.isNotEmpty) {
      final statText = statIncreases.entries
          .map((e) => '${_getStatName(e.key)} +${e.value.toStringAsFixed(1)}')
          .join(', ');
      parts.add(statText);
    }
    
    if (newBadgeIds.isNotEmpty) {
      parts.add('새 뱃지 ${newBadgeIds.length}개');
    }
    
    return parts.join(', ');
  }

  String _getStatName(String key) {
    switch (key) {
      case 'stamina': return '체력';
      case 'knowledge': return '지식';
      case 'technique': return '기술';
      case 'sociality': return '사교성';
      case 'willpower': return '의지';
      default: return key;
    }
  }

  ClimbingRewards copyWith({
    double? experience,
    int? points,
    Map<String, double>? statIncreases,
    List<String>? newBadgeIds,
    String? specialReward,
  }) {
    return ClimbingRewards(
      experience: experience ?? this.experience,
      points: points ?? this.points,
      statIncreases: statIncreases ?? this.statIncreases,
      newBadgeIds: newBadgeIds ?? this.newBadgeIds,
      specialReward: specialReward ?? this.specialReward,
    );
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

/// 등반 기록
@immutable
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
  });

  /// 등반 결과 메시지
  String get resultMessage {
    if (isSuccess) {
      return '🎉 $mountainName 등반 성공!';
    } else {
      return '💪 $mountainName 등반 실패 (다음에 다시 도전!)';
    }
  }

  /// 등반 소요 시간 (실제)
  Duration get actualDuration => endTime.difference(startTime);

  /// 등반 효율성 (예상 시간 대비 실제 시간)
  double get efficiency {
    final expectedMs = durationHours * 3600 * 1000;
    final actualMs = actualDuration.inMilliseconds;
    return expectedMs / actualMs;
  }

  ClimbingRecord copyWith({
    String? id,
    int? mountainId,
    String? mountainName,
    String? region,
    int? difficulty,
    DateTime? startTime,
    DateTime? endTime,
    double? durationHours,
    bool? isSuccess,
    double? userPower,
    double? mountainPower,
    double? successProbability,
    ClimbingRewards? rewards,
    String? failureReason,
  }) {
    return ClimbingRecord(
      id: id ?? this.id,
      mountainId: mountainId ?? this.mountainId,
      mountainName: mountainName ?? this.mountainName,
      region: region ?? this.region,
      difficulty: difficulty ?? this.difficulty,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      isSuccess: isSuccess ?? this.isSuccess,
      userPower: userPower ?? this.userPower,
      mountainPower: mountainPower ?? this.mountainPower,
      successProbability: successProbability ?? this.successProbability,
      rewards: rewards ?? this.rewards,
      failureReason: failureReason ?? this.failureReason,
    );
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
    );
  }
}

/// 등반 통계
@immutable
class ClimbingStatistics {
  final int totalAttempts;
  final int successfulClimbs;
  final int failedClimbs;
  final double totalExperience;
  final int totalPoints;
  final double totalClimbingHours;
  final int highestDifficulty;
  final double averageSuccessRate;

  const ClimbingStatistics({
    required this.totalAttempts,
    required this.successfulClimbs,
    required this.failedClimbs,
    required this.totalExperience,
    required this.totalPoints,
    required this.totalClimbingHours,
    required this.highestDifficulty,
    required this.averageSuccessRate,
  });

  /// 성공률
  double get successRate {
    if (totalAttempts == 0) return 0.0;
    return successfulClimbs / totalAttempts;
  }

  /// 시간당 평균 경험치
  double get experiencePerHour {
    if (totalClimbingHours == 0) return 0.0;
    return totalExperience / totalClimbingHours;
  }

  /// 시간당 평균 포인트
  double get pointsPerHour {
    if (totalClimbingHours == 0) return 0.0;
    return totalPoints / totalClimbingHours;
  }

  /// 기록으로부터 통계 생성
  factory ClimbingStatistics.fromRecords(List<ClimbingRecord> records) {
    if (records.isEmpty) {
      return const ClimbingStatistics(
        totalAttempts: 0,
        successfulClimbs: 0,
        failedClimbs: 0,
        totalExperience: 0.0,
        totalPoints: 0,
        totalClimbingHours: 0.0,
        highestDifficulty: 0,
        averageSuccessRate: 0.0,
      );
    }

    final totalAttempts = records.length;
    final successfulClimbs = records.where((r) => r.isSuccess).length;
    final failedClimbs = totalAttempts - successfulClimbs;
    
    final totalExperience = records.fold<double>(
      0.0, 
      (sum, r) => sum + r.rewards.experience,
    );
    
    final totalPoints = records.fold<int>(
      0, 
      (sum, r) => sum + r.rewards.points,
    );
    
    final totalClimbingHours = records.fold<double>(
      0.0, 
      (sum, r) => sum + r.durationHours,
    );
    
    final highestDifficulty = records.isEmpty 
        ? 0 
        : records.map((r) => r.difficulty).reduce((a, b) => a > b ? a : b);
    
    final averageSuccessRate = records.isEmpty 
        ? 0.0 
        : records.map((r) => r.successProbability).reduce((a, b) => a + b) / records.length;

    return ClimbingStatistics(
      totalAttempts: totalAttempts,
      successfulClimbs: successfulClimbs,
      failedClimbs: failedClimbs,
      totalExperience: totalExperience,
      totalPoints: totalPoints,
      totalClimbingHours: totalClimbingHours,
      highestDifficulty: highestDifficulty,
      averageSuccessRate: averageSuccessRate,
    );
  }

  ClimbingStatistics copyWith({
    int? totalAttempts,
    int? successfulClimbs,
    int? failedClimbs,
    double? totalExperience,
    int? totalPoints,
    double? totalClimbingHours,
    int? highestDifficulty,
    double? averageSuccessRate,
  }) {
    return ClimbingStatistics(
      totalAttempts: totalAttempts ?? this.totalAttempts,
      successfulClimbs: successfulClimbs ?? this.successfulClimbs,
      failedClimbs: failedClimbs ?? this.failedClimbs,
      totalExperience: totalExperience ?? this.totalExperience,
      totalPoints: totalPoints ?? this.totalPoints,
      totalClimbingHours: totalClimbingHours ?? this.totalClimbingHours,
      highestDifficulty: highestDifficulty ?? this.highestDifficulty,
      averageSuccessRate: averageSuccessRate ?? this.averageSuccessRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAttempts': totalAttempts,
      'successfulClimbs': successfulClimbs,
      'failedClimbs': failedClimbs,
      'totalExperience': totalExperience,
      'totalPoints': totalPoints,
      'totalClimbingHours': totalClimbingHours,
      'highestDifficulty': highestDifficulty,
      'averageSuccessRate': averageSuccessRate,
    };
  }

  factory ClimbingStatistics.fromJson(Map<String, dynamic> json) {
    return ClimbingStatistics(
      totalAttempts: json['totalAttempts'] ?? 0,
      successfulClimbs: json['successfulClimbs'] ?? 0,
      failedClimbs: json['failedClimbs'] ?? 0,
      totalExperience: (json['totalExperience'] ?? 0).toDouble(),
      totalPoints: json['totalPoints'] ?? 0,
      totalClimbingHours: (json['totalClimbingHours'] ?? 0).toDouble(),
      highestDifficulty: json['highestDifficulty'] ?? 0,
      averageSuccessRate: (json['averageSuccessRate'] ?? 0).toDouble(),
    );
  }
}

/// 등반 상태 통합 모델
@immutable
class ClimbingState {
  final ClimbingSession? currentSession;
  final List<ClimbingRecord> history;
  final ClimbingStatistics statistics;
  final DateTime lastUpdated;

  const ClimbingState({
    this.currentSession,
    required this.history,
    required this.statistics,
    required this.lastUpdated,
  });

  /// 초기 상태
  static ClimbingState get initial => ClimbingState(
    currentSession: null,
    history: [],
    statistics: const ClimbingStatistics(
      totalAttempts: 0,
      successfulClimbs: 0,
      failedClimbs: 0,
      totalExperience: 0.0,
      totalPoints: 0,
      totalClimbingHours: 0.0,
      highestDifficulty: 0,
      averageSuccessRate: 0.0,
    ),
    lastUpdated: DateTime.now(),
  );

  /// 현재 등반 중인지 확인
  bool get isCurrentlyClimbing => currentSession?.isActive == true;

  /// 현재 등반 진행률
  double get currentProgress => currentSession?.progress ?? 0.0;

  /// 현재 등반 남은 시간
  Duration get currentRemainingTime => currentSession?.remainingTime ?? Duration.zero;

  /// 오늘의 등반 기록
  List<ClimbingRecord> get todayRecords {
    final today = DateTime.now();
    return history.where((record) {
      return record.startTime.year == today.year &&
             record.startTime.month == today.month &&
             record.startTime.day == today.day;
    }).toList();
  }

  /// 최근 기록 (제한된 개수)
  List<ClimbingRecord> getRecentHistory({int limit = 10}) {
    final sortedHistory = List<ClimbingRecord>.from(history)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return sortedHistory.take(limit).toList();
  }

  ClimbingState copyWith({
    ClimbingSession? currentSession,
    List<ClimbingRecord>? history,
    ClimbingStatistics? statistics,
    DateTime? lastUpdated,
  }) {
    return ClimbingState(
      currentSession: currentSession ?? this.currentSession,
      history: history ?? this.history,
      statistics: statistics ?? this.statistics,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentSession': currentSession?.toJson(),
      'history': history.map((r) => r.toJson()).toList(),
      'statistics': statistics.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ClimbingState.fromJson(Map<String, dynamic> json) {
    return ClimbingState(
      currentSession: json['currentSession'] != null 
          ? ClimbingSession.fromJson(json['currentSession'])
          : null,
      history: (json['history'] as List?)
          ?.map((r) => ClimbingRecord.fromJson(r))
          .toList() ?? [],
      statistics: ClimbingStatistics.fromJson(json['statistics'] ?? {}),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }
}
