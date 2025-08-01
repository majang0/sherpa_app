// lib/features/daily_record/models/detailed_exercise_models.dart

import 'package:flutter/material.dart';

/// 운동 기록 베이스 클래스
abstract class DetailedExerciseRecord {
  final String id;
  final DateTime date;
  final String exerciseType;
  final int durationMinutes;
  final String? note;
  final String? mood;
  final bool isShared;
  final String? imageUrl;

  const DetailedExerciseRecord({
    required this.id,
    required this.date,
    required this.exerciseType,
    required this.durationMinutes,
    this.note,
    this.mood,
    this.isShared = false,
    this.imageUrl,
  });

  /// 사진이 있는지 확인하는 헬퍼 메서드
  bool get hasPhoto => imageUrl != null && imageUrl!.isNotEmpty;

  Map<String, dynamic> toJson();
  static DetailedExerciseRecord fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('각 운동별 클래스에서 구현해야 합니다.');
  }
}

/// 러닝 기록 모델
class RunningRecord extends DetailedExerciseRecord {
  final String location;
  final double distanceKm;
  final DifficultyLevel difficulty;
  final double averagePace; // 분/km
  final String? route;
  final int? elevationGain;

  const RunningRecord({
    required super.id,
    required super.date,
    required super.durationMinutes,
    required this.location,
    required this.distanceKm,
    required this.difficulty,
    required this.averagePace,
    this.route,
    this.elevationGain,
    super.note,
    super.mood,
    super.isShared = false,
    super.imageUrl,
  }) : super(exerciseType: '러닝');

  double get averageSpeed => 60 / averagePace; // km/h
  String get paceText => '${averagePace.toInt()}\'${((averagePace - averagePace.toInt()) * 60).toInt()}\"';
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exerciseType': exerciseType,
      'durationMinutes': durationMinutes,
      'location': location,
      'distanceKm': distanceKm,
      'difficulty': difficulty.name,
      'averagePace': averagePace,
      'route': route,
      'elevationGain': elevationGain,
      'note': note,
      'mood': mood,
      'isShared': isShared,
      'imageUrl': imageUrl,
    };
  }

  static RunningRecord fromJson(Map<String, dynamic> json) {
    return RunningRecord(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] ?? 0,
      location: json['location'] ?? '',
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.moderate,
      ),
      averagePace: (json['averagePace'] ?? 0).toDouble(),
      route: json['route'],
      elevationGain: json['elevationGain'],
      note: json['note'],
      mood: json['mood'],
      isShared: json['isShared'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }
}

/// 클라이밍 기록 모델
class ClimbingRecord extends DetailedExerciseRecord {
  final ClimbingType climbingType;
  final String location;
  final List<ClimbingRoute> routes;
  final DifficultyLevel difficulty;
  final String? partner;
  final String? equipment;

  const ClimbingRecord({
    required super.id,
    required super.date,
    required super.durationMinutes,
    required this.climbingType,
    required this.location,
    required this.routes,
    required this.difficulty,
    this.partner,
    this.equipment,
    super.note,
    super.mood,
    super.isShared = false,
    super.imageUrl,
  }) : super(exerciseType: '클라이밍');

  int get totalRoutes => routes.length;
  int get completedRoutes => routes.where((r) => r.isCompleted).length;
  double get completionRate => totalRoutes > 0 ? completedRoutes / totalRoutes : 0.0;
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exerciseType': exerciseType,
      'durationMinutes': durationMinutes,
      'climbingType': climbingType.name,
      'location': location,
      'routes': routes.map((r) => r.toJson()).toList(),
      'difficulty': difficulty.name,
      'partner': partner,
      'equipment': equipment,
      'note': note,
      'mood': mood,
      'isShared': isShared,
      'imageUrl': imageUrl,
    };
  }

  static ClimbingRecord fromJson(Map<String, dynamic> json) {
    return ClimbingRecord(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] ?? 0,
      climbingType: ClimbingType.values.firstWhere(
        (t) => t.name == json['climbingType'],
        orElse: () => ClimbingType.indoor,
      ),
      location: json['location'] ?? '',
      routes: (json['routes'] as List<dynamic>? ?? [])
          .map((r) => ClimbingRoute.fromJson(r))
          .toList(),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.moderate,
      ),
      partner: json['partner'],
      equipment: json['equipment'],
      note: json['note'],
      mood: json['mood'],
      isShared: json['isShared'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }
}

/// 등산 기록 모델
class HikingRecord extends DetailedExerciseRecord {
  final String mountain;
  final String trail;
  final double elevationGain;
  final double distanceKm;
  final DifficultyLevel difficulty;
  final String? weather;
  final String? companions;

  const HikingRecord({
    required super.id,
    required super.date,
    required super.durationMinutes,
    required this.mountain,
    required this.trail,
    required this.elevationGain,
    required this.distanceKm,
    required this.difficulty,
    this.weather,
    this.companions,
    super.note,
    super.mood,
    super.isShared = false,
    super.imageUrl,
  }) : super(exerciseType: '등산');

  double get averageSpeed => distanceKm / (durationMinutes / 60); // km/h
  String get elevationText => '${elevationGain.toInt()}m';
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exerciseType': exerciseType,
      'durationMinutes': durationMinutes,
      'mountain': mountain,
      'trail': trail,
      'elevationGain': elevationGain,
      'distanceKm': distanceKm,
      'difficulty': difficulty.name,
      'weather': weather,
      'companions': companions,
      'note': note,
      'mood': mood,
      'isShared': isShared,
      'imageUrl': imageUrl,
    };
  }

  static HikingRecord fromJson(Map<String, dynamic> json) {
    return HikingRecord(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] ?? 0,
      mountain: json['mountain'] ?? '',
      trail: json['trail'] ?? '',
      elevationGain: (json['elevationGain'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.moderate,
      ),
      weather: json['weather'],
      companions: json['companions'],
      note: json['note'],
      mood: json['mood'],
      isShared: json['isShared'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }
}

/// 헬스 기록 모델
class GymRecord extends DetailedExerciseRecord {
  final String gymName;
  final List<GymExercise> exercises;
  final DifficultyLevel difficulty;
  final String? targetMuscle;
  final String? trainer;

  const GymRecord({
    required super.id,
    required super.date,
    required super.durationMinutes,
    required this.gymName,
    required this.exercises,
    required this.difficulty,
    this.targetMuscle,
    this.trainer,
    super.note,
    super.mood,
    super.isShared = false,
    super.imageUrl,
  }) : super(exerciseType: '헬스');

  int get totalExercises => exercises.length;
  double get totalWeight => exercises.fold(0, (sum, ex) => sum + ex.totalWeight);
  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets.length);
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exerciseType': exerciseType,
      'durationMinutes': durationMinutes,
      'gymName': gymName,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'difficulty': difficulty.name,
      'targetMuscle': targetMuscle,
      'trainer': trainer,
      'note': note,
      'mood': mood,
      'isShared': isShared,
      'imageUrl': imageUrl,
    };
  }

  static GymRecord fromJson(Map<String, dynamic> json) {
    return GymRecord(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] ?? 0,
      gymName: json['gymName'] ?? '',
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => GymExercise.fromJson(e))
          .toList(),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.moderate,
      ),
      targetMuscle: json['targetMuscle'],
      trainer: json['trainer'],
      note: json['note'],
      mood: json['mood'],
      isShared: json['isShared'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }
}

/// 배드민턴 기록 모델
class BadmintonRecord extends DetailedExerciseRecord {
  final String location;
  final String? opponent;
  final List<BadmintonMatch> matches;
  final DifficultyLevel difficulty;
  final String? courtType;
  final String? playStyle;

  const BadmintonRecord({
    required super.id,
    required super.date,
    required super.durationMinutes,
    required this.location,
    this.opponent,
    required this.matches,
    required this.difficulty,
    this.courtType,
    this.playStyle,
    super.note,
    super.mood,
    super.isShared = false,
    super.imageUrl,
  }) : super(exerciseType: '배드민턴');

  int get totalMatches => matches.length;
  int get wonMatches => matches.where((m) => m.isWon).length;
  double get winRate => totalMatches > 0 ? wonMatches / totalMatches : 0.0;
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exerciseType': exerciseType,
      'durationMinutes': durationMinutes,
      'location': location,
      'opponent': opponent,
      'matches': matches.map((m) => m.toJson()).toList(),
      'difficulty': difficulty.name,
      'courtType': courtType,
      'playStyle': playStyle,
      'note': note,
      'mood': mood,
      'isShared': isShared,
      'imageUrl': imageUrl,
    };
  }

  static BadmintonRecord fromJson(Map<String, dynamic> json) {
    return BadmintonRecord(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] ?? 0,
      location: json['location'] ?? '',
      opponent: json['opponent'],
      matches: (json['matches'] as List<dynamic>? ?? [])
          .map((m) => BadmintonMatch.fromJson(m))
          .toList(),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.moderate,
      ),
      courtType: json['courtType'],
      playStyle: json['playStyle'],
      note: json['note'],
      mood: json['mood'],
      isShared: json['isShared'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }
}

// ==================== 보조 모델들 ====================

/// 체감 난이도 열거형
enum DifficultyLevel {
  easy('편안함', Color(0xFF60A5FA)),     // 라이트 블루
  moderate('적당함', Color(0xFF3B82F6)), // 미디엄 블루
  hard('힘듬', Color(0xFF2563EB)),       // 딥 블루
  veryHard('매우 힘듬', Color(0xFF1D4ED8)); // 인텐스 블루

  const DifficultyLevel(this.label, this.color);
  
  final String label;
  final Color color;
}

/// 클라이밍 타입
enum ClimbingType {
  indoor('실내'),
  outdoor('야외'),
  bouldering('볼더링'),
  sport('스포츠'),
  traditional('전통');

  const ClimbingType(this.label);
  
  final String label;
}

/// 클라이밍 루트 모델
class ClimbingRoute {
  final String name;
  final String grade;
  final bool isCompleted;
  final int attempts;

  const ClimbingRoute({
    required this.name,
    required this.grade,
    required this.isCompleted,
    required this.attempts,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grade': grade,
      'isCompleted': isCompleted,
      'attempts': attempts,
    };
  }

  static ClimbingRoute fromJson(Map<String, dynamic> json) {
    return ClimbingRoute(
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      attempts: json['attempts'] ?? 0,
    );
  }
}

/// 헬스 운동 모델
class GymExercise {
  final String name;
  final List<GymSet> sets;
  final String? equipmentType;

  const GymExercise({
    required this.name,
    required this.sets,
    this.equipmentType,
  });

  double get totalWeight => sets.fold(0, (sum, set) => sum + (set.weight * set.reps));
  int get totalReps => sets.fold(0, (sum, set) => sum + set.reps);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((s) => s.toJson()).toList(),
      'equipmentType': equipmentType,
    };
  }

  static GymExercise fromJson(Map<String, dynamic> json) {
    return GymExercise(
      name: json['name'] ?? '',
      sets: (json['sets'] as List<dynamic>? ?? [])
          .map((s) => GymSet.fromJson(s))
          .toList(),
      equipmentType: json['equipmentType'],
    );
  }
}

/// 헬스 세트 모델
class GymSet {
  final double weight;
  final int reps;
  final int restSeconds;

  const GymSet({
    required this.weight,
    required this.reps,
    required this.restSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'reps': reps,
      'restSeconds': restSeconds,
    };
  }

  static GymSet fromJson(Map<String, dynamic> json) {
    return GymSet(
      weight: (json['weight'] ?? 0).toDouble(),
      reps: json['reps'] ?? 0,
      restSeconds: json['restSeconds'] ?? 0,
    );
  }
}

/// 배드민턴 경기 모델
class BadmintonMatch {
  final int myScore;
  final int opponentScore;
  final bool isWon;
  final int durationMinutes;

  const BadmintonMatch({
    required this.myScore,
    required this.opponentScore,
    required this.isWon,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'myScore': myScore,
      'opponentScore': opponentScore,
      'isWon': isWon,
      'durationMinutes': durationMinutes,
    };
  }

  static BadmintonMatch fromJson(Map<String, dynamic> json) {
    return BadmintonMatch(
      myScore: json['myScore'] ?? 0,
      opponentScore: json['opponentScore'] ?? 0,
      isWon: json['isWon'] ?? false,
      durationMinutes: json['durationMinutes'] ?? 0,
    );
  }
}

/// 운동 기분 열거형
enum ExerciseMood {
  veryHappy('매우 좋음', '😄'),
  happy('좋음', '😊'),
  good('괜찮음', '🙂'),
  normal('보통', '😐'),
  tired('피곤함', '😴'),
  exhausted('지침', '😵');

  const ExerciseMood(this.label, this.emoji);
  
  final String label;
  final String emoji;
}

/// 헬스 운동 부위 열거형
enum GymFocus {
  upperBody('상체'),
  lowerBody('하체'),
  core('코어'),
  cardio('유산소'),
  fullBody('전신'),
  back('등'),
  chest('가슴'),
  arms('팔'),
  shoulders('어깨'),
  legs('다리');

  const GymFocus(this.label);
  
  final String label;
}

/// 배드민턴 코트 타입 열거형
enum BadmintonCourtType {
  indoor('실내'),
  outdoor('야외'),
  synthetic('합성코트'),
  wooden('목재코트');

  const BadmintonCourtType(this.label);
  
  final String label;
}

/// 게임 결과 열거형
enum GameResult {
  win('승리', '🏆', Color(0xFF22C55E)),
  lose('패배', '😞', Color(0xFFEF4444)),
  draw('무승부', '🤝', Color(0xFFEAB308));

  const GameResult(this.label, this.emoji, this.color);
  
  final String label;
  final String emoji;
  final Color color;
}

/// 운동 기록 유틸리티 클래스
class ExerciseRecordUtils {
  static String getExerciseEmoji(String exerciseType) {
    switch (exerciseType) {
      case '러닝': return '🏃';
      case '클라이밍': return '🧗';
      case '등산': return '🥾';
      case '헬스': return '🏋️';
      case '배드민턴': return '🏸';
      default: return '💪';
    }
  }

  static Color getExerciseColor(String exerciseType) {
    switch (exerciseType) {
      case '러닝': return const Color(0xFF10B981);
      case '클라이밍': return const Color(0xFF8B5CF6);
      case '등산': return const Color(0xFF059669);
      case '헬스': return const Color(0xFFEF4444);
      case '배드민턴': return const Color(0xFF3B82F6);
      default: return const Color(0xFFF97316);
    }
  }

  static List<Color> getExerciseGradient(String exerciseType) {
    switch (exerciseType) {
      case '러닝': return [const Color(0xFF10B981), const Color(0xFF047857)];
      case '클라이밍': return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      case '등산': return [const Color(0xFF059669), const Color(0xFF065F46)];
      case '헬스': return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case '배드민턴': return [const Color(0xFF3B82F6), const Color(0xFF1E40AF)];
      default: return [const Color(0xFFF97316), const Color(0xFFEA580C)];
    }
  }
}