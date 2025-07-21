class ExerciseRecord {
  final String id;
  final String exerciseType;
  final int intensity;
  final int durationMinutes;
  final String comment;
  final String? imageUrl;
  final bool isPublic;
  final DateTime createdAt;
  final int xpEarned;

  const ExerciseRecord({
    required this.id,
    required this.exerciseType,
    required this.intensity,
    required this.durationMinutes,
    required this.comment,
    this.imageUrl,
    required this.isPublic,
    required this.createdAt,
    required this.xpEarned,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseType': exerciseType,
      'intensity': intensity,
      'durationMinutes': durationMinutes,
      'comment': comment,
      'imageUrl': imageUrl,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'xpEarned': xpEarned,
    };
  }

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      id: json['id'] as String,
      exerciseType: json['exerciseType'] as String,
      intensity: json['intensity'] as int,
      durationMinutes: json['durationMinutes'] as int,
      comment: json['comment'] as String,
      imageUrl: json['imageUrl'] as String?,
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      xpEarned: json['xpEarned'] as int,
    );
  }
}

class ExerciseType {
  final String name;
  final String emoji;
  final String description;

  const ExerciseType({
    required this.name,
    required this.emoji,
    required this.description,
  });
}
