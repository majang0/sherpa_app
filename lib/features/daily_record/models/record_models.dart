import 'package:flutter/foundation.dart';

/// 걸음수 데이터 모델
class StepData {
  final DateTime date;
  final int stepCount;
  final int target;

  const StepData({
    required this.date,
    required this.stepCount,
    required this.target,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'stepCount': stepCount,
    'target': target,
  };

  factory StepData.fromJson(Map<String, dynamic> json) => StepData(
    date: DateTime.parse(json['date']),
    stepCount: json['stepCount'] ?? 0,
    target: json['target'] ?? 6000,
  );
}


/// 모임 기록 모델
class MeetingLog {
  final DateTime date;
  final String meetingName;
  final String category;
  final double satisfaction;
  final String mood;
  final String? note;

  const MeetingLog({
    required this.date,
    required this.meetingName,
    required this.category,
    required this.satisfaction,
    required this.mood,
    this.note,
  });

  /// 카테고리별 아이콘
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

  /// 기분별 아이콘
  String get moodIcon {
    switch (mood) {
      case 'very_happy': return '😄';
      case 'happy': return '😊';
      case 'good': return '🙂';
      case 'normal': return '😐';
      case 'tired': return '😪';
      case 'stressed': return '😤';
      default: return '😊';
    }
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'meetingName': meetingName,
    'category': category,
    'satisfaction': satisfaction,
    'mood': mood,
    'note': note,
  };

  factory MeetingLog.fromJson(Map<String, dynamic> json) => MeetingLog(
    date: DateTime.parse(json['date']),
    meetingName: json['meetingName'] ?? '',
    category: json['category'] ?? '스터디',
    satisfaction: (json['satisfaction'] ?? 4.0).toDouble(),
    mood: json['mood'] ?? 'happy',
    note: json['note'],
  );
}


/// 일일 목표 모델
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory DailyGoal.fromJson(Map<String, dynamic> json) => DailyGoal(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    icon: json['icon'] ?? '📝',
    isCompleted: json['isCompleted'] ?? false,
    completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'])
        : null,
  );
}

/// 기록 상태 모델
@immutable
class RecordState {
  final List<MeetingLog> meetingLogs;
  final List<DailyGoal> dailyGoals;
  final bool isLoading;
  final String? error;

  const RecordState({
    required this.meetingLogs,
    required this.dailyGoals,
    required this.isLoading,
    this.error,
  });

  RecordState copyWith({
    List<MeetingLog>? meetingLogs,
    List<DailyGoal>? dailyGoals,
    bool? isLoading,
    String? error,
  }) {
    return RecordState(
      meetingLogs: meetingLogs ?? this.meetingLogs,
      dailyGoals: dailyGoals ?? this.dailyGoals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory RecordState.initial() => const RecordState(
    meetingLogs: [],
    dailyGoals: [],
    isLoading: false,
  );
}

/// 오늘의 기록 모델
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

  factory TodayRecord.empty() => const TodayRecord(
    stepCount: 0,
    focusMinutes: 0,
    readingPages: 0,
    completedGoalsCount: 0,
    completionRate: 0.0,
  );
}

/// 기록 통계 모델
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

  factory RecordStatistics.empty() => const RecordStatistics(
    streakDays: 0,
    totalSteps: 0,
    totalReadingPages: 0,
    totalMeetings: 0,
    totalFocusMinutes: 0,
  );
}
