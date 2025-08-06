// lib/shared/utils/calorie_calculator.dart

/// Scientifically accurate calorie calculation utility using MET (Metabolic Equivalent of Task) values
/// Based on research from Harvard Health, fitness studies, and exercise physiology
class CalorieCalculator {
  // Default body weight for average Korean adult (can be customized in future)
  static const double _defaultBodyWeightKg = 70.0;

  /// Calculate calories burned using MET formula: MET × Weight(kg) × Duration(hours)
  /// 
  /// [exerciseType] - Type of exercise in Korean
  /// [durationMinutes] - Duration in minutes
  /// [intensity] - Exercise intensity (low, medium, high, very_high)
  /// [bodyWeightKg] - User's body weight in kg (optional, defaults to 70kg)
  static int calculateCalories({
    required String exerciseType,
    required int durationMinutes,
    required String intensity,
    double? bodyWeightKg,
  }) {
    final weight = bodyWeightKg ?? _defaultBodyWeightKg;
    final durationHours = durationMinutes / 60.0;
    final baseMET = _getBaseMETValue(exerciseType);
    final intensityMultiplier = _getIntensityMultiplier(intensity);
    
    final totalMET = baseMET * intensityMultiplier;
    final calories = totalMET * weight * durationHours;
    
    return calories.round();
  }

  /// Get base MET values for different exercise types
  /// Based on research data and accounting for real-world factors like rest periods
  static double _getBaseMETValue(String exerciseType) {
    switch (exerciseType) {
      // 유산소 운동 (Cardio Exercises)
      case '러닝':
        return 8.0; // 6 mph pace, realistic for most people
      case '수영':
        return 8.5; // General swimming (freestyle moderate pace)
      case '자전거':
        return 7.5; // 12-14 mph casual cycling
      case '걷기':
        return 3.5; // Brisk walking

      // 근력/체조 운동 (Strength/Fitness)
      case '헬스':
        return 3.5; // Weight training with rest periods (realistic)
      case '요가':
        return 2.5; // Hatha yoga
      case '필라테스':
        return 3.0; // Pilates general

      // 등반/아웃도어 (Climbing/Outdoor)
      case '클라이밍':
        return 3.5; // Rock climbing (realistic with belaying, rest, route reading)
      case '등산':
        return 3.5; // Hiking with rest breaks, photo stops, casual pace

      // 라켓 스포츠 (Racket Sports)
      case '배드민턴':
        return 5.5; // Social singles/doubles play
      case '테니스':
        return 7.0; // Singles tennis
      case '골프':
        return 4.5; // Walking course (carrying/pulling clubs)

      // 팀 스포츠 (Team Sports)
      case '농구':
        return 6.5; // Basketball casual game
      case '축구':
        return 7.0; // Soccer casual game
      case '배구':
        return 3.0; // Volleyball casual

      // 기타 운동 (Other Activities)
      default:
        return 4.0; // Default moderate activity
    }
  }

  /// Get intensity multipliers based on perceived exertion
  /// More realistic than previous system (less extreme)
  static double _getIntensityMultiplier(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '낮음':
      case 'light':
        return 0.8; // Light effort
      case 'medium':
      case '보통':
      case 'moderate':
        return 1.0; // Moderate effort (baseline)
      case 'high':
      case '높음':
      case 'vigorous':
        return 1.2; // Vigorous effort
      case 'very_high':
      case '매우높음':
      case 'extreme':
        return 1.4; // Very vigorous effort
      default:
        return 1.0; // Default to moderate
    }
  }

  /// Convert difficulty level enum to intensity string for backward compatibility
  static String difficultyToIntensity(dynamic difficulty) {
    if (difficulty == null) return 'medium';
    
    final difficultyStr = difficulty.toString();
    if (difficultyStr.contains('easy')) return 'low';
    if (difficultyStr.contains('moderate')) return 'medium';
    if (difficultyStr.contains('hard')) return 'high';
    if (difficultyStr.contains('veryHard')) return 'very_high';
    
    return 'medium'; // Default
  }

  /// Get estimated calories per hour for display purposes
  static int getCaloriesPerHour({
    required String exerciseType,
    required String intensity,
    double? bodyWeightKg,
  }) {
    return calculateCalories(
      exerciseType: exerciseType,
      durationMinutes: 60,
      intensity: intensity,
      bodyWeightKg: bodyWeightKg,
    );
  }

  /// Get exercise-specific notes about calorie calculation accuracy
  static String getExerciseNote(String exerciseType) {
    switch (exerciseType) {
      case '클라이밍':
        return '휴식, 확보, 루트 분석 시간을 포함한 현실적인 계산입니다.';
      case '등산':
        return '휴식, 사진 촬영, 간식 시간을 포함한 여유로운 등산 기준입니다.';
      case '헬스':
        return '세트 간 휴식 시간이 고려된 현실적인 계산입니다.';
      case '골프':
        return '코스를 걸어서 플레이하는 것을 기준으로 계산됩니다.';
      default:
        return '과학적 연구 데이터를 바탕으로 계산된 추정치입니다.';
    }
  }

  /// Validate if calorie calculation seems reasonable
  static bool isCalorieCountRealistic(int calories, int durationMinutes) {
    final caloriesPerHour = (calories / durationMinutes) * 60;
    
    // Sanity check: Most people burn 200-1000 calories per hour during exercise
    return caloriesPerHour >= 150 && caloriesPerHour <= 1200;
  }
}