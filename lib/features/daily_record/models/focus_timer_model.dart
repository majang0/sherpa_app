enum FocusTimerState {
  idle,      // 대기 중
  running,   // 실행 중
  paused,    // 일시정지
  completed, // 완료
  cancelled, // 취소됨
}

class FocusTimerData {
  final int totalMinutes;
  final int remainingSeconds;
  final FocusTimerState state;
  final DateTime? startTime;
  final DateTime? endTime;
  final int xpEarned;
  final String sessionId;

  const FocusTimerData({
    required this.totalMinutes,
    required this.remainingSeconds,
    required this.state,
    this.startTime,
    this.endTime,
    required this.xpEarned,
    required this.sessionId,
  });

  // 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    final totalSeconds = totalMinutes * 60;
    if (totalSeconds == 0) return 0.0;
    return ((totalSeconds - remainingSeconds) / totalSeconds).clamp(0.0, 1.0);
  }

  // 완료된 시간 (분)
  int get completedMinutes {
    final totalSeconds = totalMinutes * 60;
    final completedSeconds = totalSeconds - remainingSeconds;
    return (completedSeconds / 60).floor();
  }

  // 남은 시간을 MM:SS 형식으로 반환
  String get formattedTime {
    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 목표 달성 여부 (30분 이상)
  bool get isGoalAchieved => completedMinutes >= 30;

  // XP 계산
  static int calculateXP(int completedMinutes) {
    if (completedMinutes < 10) return 0;
    if (completedMinutes < 30) return completedMinutes * 2; // 2XP per minute
    if (completedMinutes < 60) return 60 + (completedMinutes - 30) * 3; // 3XP per minute after 30min
    return 150 + (completedMinutes - 60) * 5; // 5XP per minute after 1hour
  }

  FocusTimerData copyWith({
    int? totalMinutes,
    int? remainingSeconds,
    FocusTimerState? state,
    DateTime? startTime,
    DateTime? endTime,
    int? xpEarned,
    String? sessionId,
  }) {
    return FocusTimerData(
      totalMinutes: totalMinutes ?? this.totalMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      state: state ?? this.state,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      xpEarned: xpEarned ?? this.xpEarned,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMinutes': totalMinutes,
      'remainingSeconds': remainingSeconds,
      'state': state.name,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'xpEarned': xpEarned,
      'sessionId': sessionId,
    };
  }

  factory FocusTimerData.fromJson(Map<String, dynamic> json) {
    return FocusTimerData(
      totalMinutes: json['totalMinutes'] ?? 30,
      remainingSeconds: json['remainingSeconds'] ?? 1800,
      state: FocusTimerState.values.firstWhere(
            (e) => e.name == json['state'],
        orElse: () => FocusTimerState.idle,
      ),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null,
      xpEarned: json['xpEarned'] ?? 0,
      sessionId: json['sessionId'] ?? '',
    );
  }
}
