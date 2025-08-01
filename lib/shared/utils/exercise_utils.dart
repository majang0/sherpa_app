// lib/shared/utils/exercise_utils.dart

import 'package:flutter/material.dart';
import '../../features/daily_record/models/detailed_exercise_models.dart';
import '../models/global_user_model.dart';

/// Centralized utility class for exercise-related operations
/// Eliminates code duplication across exercise screens
class ExerciseUtils {
  /// Get difficulty multiplier for calculations (XP, points, stats)
  static double getDifficultyMultiplier(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 0.8;
      case DifficultyLevel.moderate:
        return 1.0;
      case DifficultyLevel.hard:
        return 1.3;
      case DifficultyLevel.veryHard:
        return 1.6;
    }
  }

  /// Get icon for difficulty level
  static IconData getDifficultyIcon(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Icons.spa;
      case DifficultyLevel.moderate:
        return Icons.directions_walk;
      case DifficultyLevel.hard:
        return Icons.directions_run;
      case DifficultyLevel.veryHard:
        return Icons.whatshot;
    }
  }

  /// Get color for difficulty level (uses enum property)
  static Color getDifficultyColor(DifficultyLevel difficulty) {
    return difficulty.color;
  }

  /// Get label for difficulty level (uses enum property)
  static String getDifficultyLabel(DifficultyLevel difficulty) {
    return difficulty.label;
  }

  /// Get description for difficulty level
  static String getDifficultyDescription(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return '편안하게 할 수 있는 강도';
      case DifficultyLevel.moderate:
        return '적당히 땀이 나는 강도';
      case DifficultyLevel.hard:
        return '숨이 차고 힘든 강도';
      case DifficultyLevel.veryHard:
        return '최대한 힘을 다하는 강도';
    }
  }

  /// Convert difficulty enum to intensity string for compatibility with ExerciseLog
  static String difficultyToIntensity(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'low';
      case DifficultyLevel.moderate:
        return 'medium';
      case DifficultyLevel.hard:
        return 'high';
      case DifficultyLevel.veryHard:
        return 'very_high';
    }
  }

  /// Convert intensity string to difficulty enum for compatibility with forms
  static DifficultyLevel intensityToDifficulty(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '낮음':
        return DifficultyLevel.easy;
      case 'medium':
      case '보통':
        return DifficultyLevel.moderate;
      case 'high':
      case '높음':
        return DifficultyLevel.hard;
      case 'very_high':
      case '매우높음':
        return DifficultyLevel.veryHard;
      default:
        return DifficultyLevel.moderate;
    }
  }

  /// Get exercise emoji (using existing utility from models)
  static String getExerciseEmoji(String exerciseType) {
    return ExerciseRecordUtils.getExerciseEmoji(exerciseType);
  }

  /// Get exercise color (using existing utility from models)
  static Color getExerciseColor(String exerciseType) {
    return ExerciseRecordUtils.getExerciseColor(exerciseType);
  }

  /// Get exercise gradient (using existing utility from models)
  static List<Color> getExerciseGradient(String exerciseType) {
    return ExerciseRecordUtils.getExerciseGradient(exerciseType);
  }
}

/// Model conversion utilities
class ExerciseModelConverter {
  /// Convert DetailedExerciseRecord to ExerciseLog for persistence
  static ExerciseLog detailedToSimple(DetailedExerciseRecord detailed) {
    return ExerciseLog(
      id: detailed.id,
      date: detailed.date,
      exerciseType: detailed.exerciseType,
      durationMinutes: detailed.durationMinutes,
      intensity: 'medium', // Default since DetailedExerciseRecord uses DifficultyLevel
      note: detailed.note,
      imageUrl: detailed.imageUrl,
      isShared: detailed.isShared,
    );
  }

  /// Convert ExerciseLog to simplified data for display
  static Map<String, dynamic> simpleToDisplayData(ExerciseLog exercise) {
    return {
      'id': exercise.id,
      'date': exercise.date,
      'exerciseType': exercise.exerciseType,
      'durationMinutes': exercise.durationMinutes,
      'intensity': exercise.intensity,
      'note': exercise.note,
      'imageUrl': exercise.imageUrl,
      'isShared': exercise.isShared,
      'hasPhoto': exercise.hasPhoto,
    };
  }
}