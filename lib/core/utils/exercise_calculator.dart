import 'dart:math' as math;

/// 운동 효과 계산 유틸리티
/// 
/// 의학적 근거 기반 운동 효과 계산
/// 참고문헌: American College of Sports Medicine (ACSM) Guidelines
class ExerciseCalculator {
  
  /// 운동 칼로리 계산 (MET 기반)
  /// MET(Metabolic Equivalent of Task) 값 사용
  static int calculateCalories({
    required String exerciseType,
    required int durationMinutes,
    required String intensity,
    double weightKg = 65.0, // 한국 성인 평균 체중
  }) {
    // 운동별 MET 값 (ACSM 가이드라인 기준)
    final double met = _getMETValue(exerciseType, intensity);
    
    // 칼로리 = MET × 체중(kg) × 시간(시간)
    final calories = met * weightKg * (durationMinutes / 60.0);
    
    return calories.round();
  }
  
  /// 운동별 MET 값 (의학적 근거 기반)
  static double _getMETValue(String exerciseType, String intensity) {
    // 강도별 배수
    final intensityMultiplier = {
      '낮음': 0.8,
      '보통': 1.0,
      '높음': 1.3,
      '매우 높음': 1.5,
    }[intensity] ?? 1.0;
    
    // 운동별 기본 MET 값 (ACSM 기준)
    final baseMET = {
      '걷기': 3.5,
      '빠른 걷기': 4.5,
      '조깅': 6.0,
      '러닝': 8.0,
      '달리기': 10.0,
      '자전거': 6.0,
      '수영': 7.0,
      '요가': 2.5,
      '필라테스': 3.0,
      '웨이트': 4.0,
      '근력운동': 4.5,
      '에어로빅': 6.5,
      '댄스': 5.0,
      '등산': 7.0,
      '하이킹': 6.0,
      '테니스': 7.0,
      '배드민턴': 5.5,
      '농구': 6.5,
      '축구': 7.0,
      '야구': 4.0,
      '골프': 3.5,
      '볼링': 3.0,
      '크로스핏': 8.0,
      'HIIT': 9.0,
      '복싱': 8.0,
      '클라이밍': 8.0,
    }[exerciseType] ?? 5.0; // 기본값
    
    return baseMET * intensityMultiplier;
  }
  
  /// 심박수 증가 계산 (Karvonen Formula 기반)
  static Map<String, dynamic> calculateHeartRateEffect({
    required int durationMinutes,
    required String intensity,
    int restingHR = 70, // 평균 안정시 심박수
    int age = 30, // 평균 연령
  }) {
    // 최대 심박수 = 220 - 나이
    final maxHR = 220 - age;
    
    // 강도별 목표 심박수 비율 (ACSM 기준)
    final targetPercentage = {
      '낮음': 0.5,      // 50-60%
      '보통': 0.65,     // 60-70%
      '높음': 0.75,     // 70-85%
      '매우 높음': 0.85, // 85-95%
    }[intensity] ?? 0.65;
    
    // Karvonen Formula: 목표 심박수 = ((최대심박수 - 안정시심박수) × 강도%) + 안정시심박수
    final targetHR = ((maxHR - restingHR) * targetPercentage + restingHR).round();
    final hrIncrease = targetHR - restingHR;
    
    // 운동 후 회복 시간 (분)
    final recoveryTime = _getRecoveryTime(durationMinutes, intensity);
    
    return {
      'targetHR': targetHR,
      'increase': hrIncrease,
      'percentage': (hrIncrease / restingHR * 100).round(),
      'recoveryMinutes': recoveryTime,
    };
  }
  
  /// 회복 시간 계산
  static int _getRecoveryTime(int duration, String intensity) {
    final base = {
      '낮음': 5,
      '보통': 10,
      '높음': 20,
      '매우 높음': 30,
    }[intensity] ?? 10;
    
    // 운동 시간이 길수록 회복 시간 증가
    return base + (duration ~/ 30) * 5;
  }
  
  /// 혈압 감소 효과 (의학 연구 기반)
  /// 참고: Journal of Hypertension 2020 메타분석
  static Map<String, dynamic> getBloodPressureEffect({
    required int durationMinutes,
    required String intensity,
  }) {
    // 운동 강도별 수축기 혈압 감소 (mmHg)
    final systolicReduction = {
      '낮음': 2.0,
      '보통': 5.0,
      '높음': 7.0,
      '매우 높음': 8.0,
    }[intensity] ?? 5.0;
    
    // 운동 시간 보정 (30분 기준)
    final timeMultiplier = math.min(durationMinutes / 30.0, 2.0);
    
    final actualReduction = (systolicReduction * timeMultiplier).toStringAsFixed(1);
    final diastolicReduction = (systolicReduction * 0.7 * timeMultiplier).toStringAsFixed(1);
    
    return {
      'systolic': actualReduction,
      'diastolic': diastolicReduction,
      'duration': '24시간', // 운동 효과 지속 시간
      'longTermBenefit': durationMinutes >= 30 ? '심혈관 질환 위험 20% 감소' : '심혈관 건강 개선',
    };
  }
  
  /// 엔돌핀 분비 효과 (Runner's High)
  /// 참고: Sports Medicine 2021 연구
  static Map<String, dynamic> getEndorphinEffect({
    required int durationMinutes,
    required String intensity,
  }) {
    // 엔돌핀 분비 시작 시간 (분)
    final onsetTime = {
      '낮음': 30,
      '보통': 20,
      '높음': 15,
      '매우 높음': 10,
    }[intensity] ?? 20;
    
    // 엔돌핀 분비량 (상대적 수치)
    int endorphinLevel = 0;
    if (durationMinutes >= onsetTime) {
      endorphinLevel = math.min(
        ((durationMinutes - onsetTime) / 10 * 20).round(),
        100
      );
    }
    
    // 기분 개선 효과
    final moodImprovement = endorphinLevel >= 60 
        ? '매우 큰 행복감'
        : endorphinLevel >= 40
            ? '기분 전환 효과'
            : endorphinLevel >= 20
                ? '스트레스 감소'
                : '가벼운 상쾌함';
    
    return {
      'level': endorphinLevel,
      'onset': durationMinutes >= onsetTime,
      'moodEffect': moodImprovement,
      'duration': '${(endorphinLevel / 10).round()}시간', // 효과 지속 시간
    };
  }
  
  /// BDNF(뇌유래신경영양인자) 증가 효과
  /// 참고: Neuroscience Research 2022
  static Map<String, dynamic> getBrainEffect({
    required int durationMinutes,
    required String exerciseType,
    required String intensity,
  }) {
    // 유산소 운동이 BDNF 증가에 더 효과적
    final isAerobic = ['러닝', '달리기', '조깅', '수영', '자전거', '에어로빅'].contains(exerciseType);
    
    // BDNF 증가율 (%)
    double bdnfIncrease = 0;
    if (isAerobic) {
      bdnfIncrease = math.min(durationMinutes * 0.5, 30.0);
    } else {
      bdnfIncrease = math.min(durationMinutes * 0.3, 20.0);
    }
    
    // 강도 보정
    final intensityBonus = {
      '낮음': 0.8,
      '보통': 1.0,
      '높음': 1.2,
      '매우 높음': 1.3,
    }[intensity] ?? 1.0;
    
    bdnfIncrease *= intensityBonus;
    
    // 인지 기능 개선 효과
    final cognitiveEffect = bdnfIncrease >= 20
        ? '학습능력 향상'
        : bdnfIncrease >= 10
            ? '집중력 개선'
            : '뇌 활성화';
    
    return {
      'bdnfIncrease': bdnfIncrease.round(),
      'cognitiveEffect': cognitiveEffect,
      'neuroplasticity': bdnfIncrease >= 15 ? '신경 가소성 증가' : '뇌 건강 유지',
      'focusDuration': '${(bdnfIncrease / 5).round()}시간', // 집중력 지속 시간
    };
  }
  
  /// 근육 성장 효과 (운동 종류별)
  /// 참고: Journal of Strength and Conditioning Research
  static Map<String, dynamic> getMuscleGrowthEffect({
    required String exerciseType,
    required int durationMinutes,
    required String intensity,
  }) {
    // 운동 종류별 근육 자극 정도
    final muscleStimulation = {
      '웨이트': 1.0,
      '근력운동': 0.9,
      '크로스핏': 0.85,
      '클라이밍': 0.7,
      '수영': 0.6,
      '복싱': 0.5,
      '러닝': 0.3,
      '달리기': 0.3,
      '자전거': 0.4,
      '요가': 0.2,
      '필라테스': 0.35,
    }[exerciseType] ?? 0.25;
    
    // 강도별 보정
    final intensityMultiplier = {
      '낮음': 0.5,
      '보통': 0.75,
      '높음': 1.0,
      '매우 높음': 1.2,
    }[intensity] ?? 0.75;
    
    // 근육 성장률 (일일 최대 0.05%)
    final growthRate = math.min(
      muscleStimulation * intensityMultiplier * (durationMinutes / 60) * 0.05,
      0.05
    );
    
    // 단백질 합성 증가율
    final proteinSynthesis = (growthRate * 1000).round(); // %로 변환
    
    return {
      'growthRate': '${(growthRate * 100).toStringAsFixed(3)}%',
      'proteinSynthesis': '$proteinSynthesis%',
      'recoveryNeeded': muscleStimulation >= 0.7 ? '48시간' : '24시간',
      'muscleGroup': _getTargetMuscles(exerciseType),
    };
  }
  
  /// 운동별 주요 근육군
  static String _getTargetMuscles(String exerciseType) {
    final muscleMap = {
      '웨이트': '전신 근육',
      '근력운동': '대근육군',
      '러닝': '하체 & 코어',
      '달리기': '하체 & 코어',
      '수영': '전신 근육',
      '자전거': '하체 근육',
      '요가': '코어 & 유연성',
      '필라테스': '코어 근육',
      '크로스핏': '전신 복합',
      '클라이밍': '상체 & 코어',
      '복싱': '상체 & 코어',
    };
    
    return muscleMap[exerciseType] ?? '전신';
  }
  
  /// 기초대사율 증가 효과 (EPOC - Excess Post-exercise Oxygen Consumption)
  /// 참고: Medicine & Science in Sports & Exercise
  static Map<String, dynamic> getMetabolicEffect({
    required int calories,
    required String intensity,
    required int durationMinutes,
  }) {
    // EPOC 효과 (운동 후 추가 칼로리 소모)
    final epocPercentage = {
      '낮음': 0.05,      // 5%
      '보통': 0.10,      // 10%
      '높음': 0.15,      // 15%
      '매우 높음': 0.20, // 20%
    }[intensity] ?? 0.10;
    
    final epocCalories = (calories * epocPercentage).round();
    
    // 기초대사율 증가 지속 시간
    final epocDuration = {
      '낮음': 2,
      '보통': 6,
      '높음': 12,
      '매우 높음': 24,
    }[intensity] ?? 6;
    
    // 총 칼로리 소모
    final totalCalories = calories + epocCalories;
    
    return {
      'immediateCalories': calories,
      'epocCalories': epocCalories,
      'totalCalories': totalCalories,
      'epocDuration': epocDuration,
      'metabolicBoost': '${(epocPercentage * 100).round()}%',
    };
  }
  
  /// 면역력 강화 효과
  /// 참고: Exercise Immunology Review
  static Map<String, dynamic> getImmuneEffect({
    required int durationMinutes,
    required String intensity,
  }) {
    // J-Curve: 적당한 운동은 면역력 증가, 과도한 운동은 감소
    double immuneBoost = 0;
    
    if (intensity == '낮음' || intensity == '보통') {
      // 적당한 운동: 면역력 증가
      immuneBoost = math.min(durationMinutes * 0.5, 30.0);
    } else if (intensity == '높음') {
      // 높은 강도: 30분까지는 증가, 이후 감소
      if (durationMinutes <= 30) {
        immuneBoost = durationMinutes * 0.4;
      } else {
        immuneBoost = 12 - ((durationMinutes - 30) * 0.2);
      }
    } else {
      // 매우 높음: 20분까지만 긍정적
      if (durationMinutes <= 20) {
        immuneBoost = durationMinutes * 0.3;
      } else {
        immuneBoost = 6 - ((durationMinutes - 20) * 0.3);
      }
    }
    
    immuneBoost = math.max(immuneBoost, -10.0); // 최소값 제한
    
    final effect = immuneBoost >= 20 
        ? '면역력 크게 향상'
        : immuneBoost >= 10
            ? '감기 예방 효과'
            : immuneBoost >= 0
                ? '면역 체계 강화'
                : '일시적 면역 저하 (회복 필요)';
    
    return {
      'boost': immuneBoost.round(),
      'effect': effect,
      'whiteBloodCells': immuneBoost >= 0 ? '활성화' : '일시적 감소',
      'recommendation': immuneBoost < 0 ? '충분한 휴식과 영양 섭취 필요' : '규칙적 운동 유지',
    };
  }
  
  /// 수면 질 개선 효과
  /// 참고: Sleep Medicine Reviews
  static Map<String, dynamic> getSleepEffect({
    required int durationMinutes,
    required String intensity,
    required DateTime exerciseTime,
  }) {
    // 운동 시간대별 수면 효과
    final hour = exerciseTime.hour;
    double sleepQuality = 0;
    
    if (hour < 10) {
      // 아침 운동: 최고의 수면 효과
      sleepQuality = math.min(durationMinutes * 0.8, 40.0);
    } else if (hour < 17) {
      // 오후 운동: 좋은 수면 효과
      sleepQuality = math.min(durationMinutes * 0.6, 30.0);
    } else if (hour < 20) {
      // 저녁 운동: 적당한 효과
      sleepQuality = math.min(durationMinutes * 0.4, 20.0);
    } else {
      // 늦은 밤 운동: 수면 방해 가능
      sleepQuality = -math.min(durationMinutes * 0.3, 15.0);
    }
    
    // 강도 보정
    if (intensity == '매우 높음' && hour >= 18) {
      sleepQuality -= 10; // 저녁 고강도 운동은 수면 방해
    }
    
    final effect = sleepQuality >= 30
        ? '깊은 수면 증가'
        : sleepQuality >= 20
            ? '수면 질 개선'
            : sleepQuality >= 10
                ? '빠른 입면'
                : sleepQuality >= 0
                    ? '수면 패턴 안정'
                    : '수면 방해 가능';
    
    return {
      'qualityImprovement': '${sleepQuality.round()}%',
      'effect': effect,
      'deepSleep': sleepQuality >= 20 ? '${(sleepQuality / 10).round()}시간 증가' : '변화 없음',
      'recommendation': sleepQuality < 0 ? '운동 시간을 앞당기세요' : '최적 시간대',
    };
  }
}

/// 운동 타입 매핑 유틸리티
class ExerciseTypeMapper {
  static const Map<String, String> _englishToKorean = {
    'running': '러닝',
    'walking': '걷기',
    'cycling': '자전거',
    'swimming': '수영',
    'yoga': '요가',
    'pilates': '필라테스',
    'weight': '웨이트',
    'gym': '헬스',
    'hiking': '하이킹',
    'climbing': '클라이밍',
    'boxing': '복싱',
    'crossfit': '크로스핏',
    'dance': '댄스',
    'tennis': '테니스',
    'badminton': '배드민턴',
    'basketball': '농구',
    'soccer': '축구',
    'baseball': '야구',
    'golf': '골프',
    'bowling': '볼링',
  };
  
  static String toKorean(String exerciseType) {
    final lower = exerciseType.toLowerCase();
    return _englishToKorean[lower] ?? exerciseType;
  }
  
  static String toEnglish(String exerciseType) {
    final entry = _englishToKorean.entries.firstWhere(
      (e) => e.value == exerciseType,
      orElse: () => MapEntry(exerciseType, exerciseType),
    );
    return entry.key;
  }
}