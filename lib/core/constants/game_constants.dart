import 'dart:math' as math;

// GlobalBadge 사용을 위한 import 추가
import '../../shared/models/global_badge_model.dart';

/// 셰르파 앱의 모든 게임 시스템 상수 및 공식
/// 전체 앱에서 공유되는 핵심 게임 로직
class GameConstants {
  // ==================== 등반력 공식 ====================

  /// 기본 등반력 계산: (레벨 × 10) + 칭호 보너스
  static double calculateBasePower(int level, double titleBonus) {
    return (level * 10.0) + titleBonus;
  }

  /// 능력치 보너스 계산: 체력% + 지식% + 기술%
  static double calculateStatsBonus(double stamina, double knowledge, double technique) {
    return stamina + knowledge + technique;
  }

  /// 뱃지 보너스 계산: 모든 장착 뱃지의 보너스 % 합산
  static double calculateBadgeBonus(List<GlobalBadge> equippedBadges) {
    double bonus = 0.0;
    for (final badge in equippedBadges) {
      final effectType = badge.effectType.toLowerCase();
      if (effectType == 'climbing_power_multiply' || 
          effectType == 'power_boost' || 
          effectType == 'stamina_boost' ||
          effectType.contains('power') ||
          effectType.contains('climbing')) {
        bonus += badge.effectValue;
      }
    }
    return bonus;
  }

  /// 최종 등반력 계산
  /// 공식: 기본 등반력 × (1 + 능력치 보너스 총합) × (1 + 뱃지 보너스 총합)
  static double calculateFinalClimbingPower({
    required int level,
    required double titleBonus,
    required double stamina,
    required double knowledge,
    required double technique,
    required List<GlobalBadge> equippedBadges,
  }) {
    final basePower = calculateBasePower(level, titleBonus);
    final statsBonus = calculateStatsBonus(stamina, knowledge, technique);
    final badgeBonus = calculateBadgeBonus(equippedBadges);

    return basePower * (1 + statsBonus / 100) * (1 + badgeBonus / 100);
  }

  // ==================== 레벨 및 경험치 시스템 ====================

  /// 레벨별 칭호 보너스
  static const Map<int, double> titleBonuses = {
    1: 0,     // 초보 등반가 (Novice)
    10: 50,   // 숙련된 등반가 (Adept)
    20: 120,  // 전문 산악인 (Expert)
    30: 250,  // 셰르파 (Sherpa)
    40: 400,  // 마스터 셰르파 (Master Sherpa)
    50: 600,  // 전설의 셰르파 (Legendary Sherpa)
  };

  /// 레벨별 칭호 이름
  static const Map<int, String> titleNames = {
    1: "초보 등반가",
    10: "숙련된 등반가",
    20: "전문 산악인",
    30: "셰르파",
    40: "마스터 셰르파",
    50: "전설의 셰르파",
  };

  /// 레벨에 따른 칭호 보너스 계산
  static double getTitleBonus(int level) {
    // 수정: .reversed 대신 .toList().reversed 사용
    for (final entry in titleBonuses.entries.toList().reversed) {
      if (level >= entry.key) {
        return entry.value;
      }
    }
    return 0;
  }

  /// 레벨에 따른 칭호 이름 계산
  static String getTitleName(int level) {
    // 수정: .reversed 대신 .toList().reversed 사용
    for (final entry in titleNames.entries.toList().reversed) {
      if (level >= entry.key) {
        return entry.value;
      }
    }
    return "초보 등반가";
  }

  /// 필요 경험치 계산: (현재 레벨 ^ 1.5) × 40 + (현재 레벨 × 20)
  static double getRequiredXpForLevel(int level) {
    return (math.pow(level, 1.5) * 40) + (level * 20);
  }

  /// 특정 레벨까지의 총 경험치 계산
  static double getTotalXpForLevel(int targetLevel) {
    if (targetLevel <= 0) return 0;
    double total = 0;
    for (int i = 1; i <= targetLevel; i++) {
      total += getRequiredXpForLevel(i);
    }
    return total;
  }

  /// 레벨별 최대 뱃지 슬롯
  static int getMaxBadgeSlots(int level) {
    if (level < 10) return 1;
    if (level < 20) return 2;
    if (level < 30) return 3;
    return 4;
  }

  /// 승급 퀘스트 발동 레벨 확인
  static bool isPromotionLevel(int level) {
    return [9, 19, 29, 39, 49].contains(level);
  }

  // ==================== 성공 확률 계산 ====================

  /// 등반력 비율에 따른 기본 성공 확률
  static double getBaseProbability(double powerRatio) {
    if (powerRatio < 1) {
      // 등반력 부족 시: 급격한 확률 감소 (3제곱 함수)
      return 0.05 + 0.45 * math.pow(powerRatio, 3);
    } else {
      // 등반력 초과 시: 완만한 확률 증가 (지수 함수의 역함수)
      final prob = 0.5 + 0.45 * (1 - math.exp(-0.5 * (powerRatio - 1)));
      return math.min(prob, 0.95); // 최대 95%로 제한
    }
  }

  /// 최종 성공 확률 계산
  /// 공식: 기본 성공 확률 + 의지 보정치 + 뱃지 보너스
  static double calculateSuccessProbability({
    required double userPower,
    required double mountainPower,
    required double willpower,
    required List<GlobalBadge> equippedBadges,
  }) {
    final powerRatio = mountainPower > 0 ? userPower / mountainPower : 1.0;
    final baseProbability = getBaseProbability(powerRatio);

    // 의지 보정치: (의지 % × 0.1)
    final willpowerBonus = (willpower / 100) * 0.1;

    // 뱃지 보너스 계산 (다양한 effectType 지원)
    double badgeBonus = 0.0;
    for (final badge in equippedBadges) {
      final effectType = badge.effectType.toLowerCase();
      if (effectType == 'success_rate' || 
          effectType == 'climbing_success' || 
          effectType == 'luck_boost' ||
          effectType.contains('success')) {
        badgeBonus += badge.effectValue / 100;
      }
    }

    final finalProbability = baseProbability + willpowerBonus + badgeBonus;
    return math.max(0.05, math.min(finalProbability, 0.95));
  }

  // ==================== 보상 시스템 ====================

  /// 성공 시 경험치 계산: (산 난이도 × 소요 시간 × 0.5) ±10%
  /// ✅ 초반 완화 + 중급 가속을 적용한 성공 시 경험치 계산
  /// 공식: 지수 감쇠 곡선 + 초반 페널티 + 중급 가속 보너스
  static double calculateSuccessXp(int difficulty, double durationHours, {int playerLevel = 1}) {
    final k = 0.12; // 감쇠 상수 (곡선의 가파름 조절)

    // 🎯 마스터 배수 조정: 65.0 → 32.5 (정확히 절반으로 하향)
    final maxReward = durationHours * 32.5;

    // 기본 지수 감쇠 곡선 적용
    final difficultyFactor = 1.0 - math.exp(-k * difficulty);

    // 중급산 이상 가속 보정 (난이도 15 이상에서만 적용)
    final accelerationBonus = difficulty >= 15 ?
    1.0 + ((difficulty - 15) * 0.015) : 1.0;

    // 초반 부분 추가 하향 조정 (난이도 20 미만)
    final earlyGamePenalty = difficulty < 20 ?
    0.8 + (difficulty * 0.01) : 1.0;

    final baseXp = maxReward * difficultyFactor * (difficulty / 80.0 + 0.4) * accelerationBonus * earlyGamePenalty;

    final randomFactor = 0.9 + (math.Random().nextDouble() * 0.2); // ±10%
    return baseXp * randomFactor;
  }

  /// ✅ 포인트 계산 공식은 그대로 유지 (int 반환으로 변경)
  static double calculateSuccessPoints(int difficulty, double durationHours, {int playerLevel = 1}) {
    final k = 0.09;
    final maxReward = durationHours * 30.0;

    final difficultyFactor = 1.0 - math.exp(-k * difficulty);

    final accelerationBonus = difficulty >= 15 ?
    1.0 + ((difficulty - 15) * 0.012) : 1.0;

    final earlyGamePenalty = difficulty < 20 ?
    0.85 + (difficulty * 0.0075) : 1.0;

    final basePoints = maxReward * difficultyFactor * (difficulty / 80.0 + 0.3) * accelerationBonus * earlyGamePenalty;

    final randomFactor = 0.8 + (math.Random().nextDouble() * 0.4); // ±20%
    return basePoints * randomFactor;
  }

  /// ✅ 실패 시 경험치 계산 (성공 시의 25% 수준)
  static double calculateFailureXp(int difficulty, double durationHours, {int playerLevel = 1}) {
    // 자동으로 조정된 calculateSuccessXp를 기반으로 계산됩니다.
    return calculateSuccessXp(difficulty, durationHours, playerLevel: playerLevel) * 0.25;
  }

  static double calculateDisplayXp(int difficulty, double durationHours, {int playerLevel = 1}) {
    final k = 0.12;
    final maxReward = durationHours * 32.5;

    final difficultyFactor = 1.0 - math.exp(-k * difficulty);

    final accelerationBonus = difficulty >= 15 ?
    1.0 + ((difficulty - 15) * 0.015) : 1.0;

    final earlyGamePenalty = difficulty < 20 ?
    0.8 + (difficulty * 0.01) : 1.0;

    final baseXp = maxReward * difficultyFactor * (difficulty / 80.0 + 0.4) * accelerationBonus * earlyGamePenalty;

    // ✅ 랜덤 요소 대신 중간값(1.0) 사용
    return baseXp * 1.0;
  }

  /// ✅ UI 표시용 중간값 포인트 계산 (랜덤 요소 완전 제거, int 반환)
  static int calculateDisplayPoints(int difficulty, double durationHours, {int playerLevel = 1}) {
    final k = 0.09;
    final maxReward = durationHours * 30.0;

    final difficultyFactor = 1.0 - math.exp(-k * difficulty);

    final accelerationBonus = difficulty >= 15 ?
    1.0 + ((difficulty - 15) * 0.012) : 1.0;

    final earlyGamePenalty = difficulty < 20 ?
    0.85 + (difficulty * 0.0075) : 1.0;

    final basePoints = maxReward * difficultyFactor * (difficulty / 80.0 + 0.3) * accelerationBonus * earlyGamePenalty;

    // ✅ 랜덤 요소 대신 중간값(1.0) 사용, int로 반환
    return (basePoints * 1.0).round();
  }

  // ==================== 능력치 시스템 ====================

  /// 능력치 등급 계산
  static String getStatGrade(double statValue) {
    if (statValue >= 100) return '전문가 (Master)';
    if (statValue >= 50) return '고급 (Expert)';
    if (statValue >= 20) return '중급 (Adept)';
    return '초급 (Novice)';
  }

  /// 퀘스트 난이도별 능력치 증가 확률 및 수치
  static Map<String, dynamic> getStatIncreaseChance(String questType) {
    switch (questType) {
      case 'daily_easy':
        return {'chance': 0.3, 'increase': 0.1};
      case 'weekly_medium':
        return {'chance': 0.8, 'increase': 0.3};
      case 'challenge_hard':
        return {'chance': 1.0, 'increase': 1.0};
      default:
        return {'chance': 0.1, 'increase': 0.05};
    }
  }

  // ==================== 산 목록 및 지역 시스템 ====================

  /// 지역별 요구 등반력 계산
  static double calculateRequiredPower(int difficulty) {
    if (difficulty <= 9) {
      // 초심자의 언덕 (Lv. 1-9): 난이도 × 40
      return difficulty * 40.0;
    } else if (difficulty <= 49) {
      // 한국의 명산 (Lv. 10-49): 360 + (난이도 - 9) × 80
      return 360 + (difficulty - 9) * 80.0;
    } else if (difficulty <= 99) {
      // 아시아의 지붕 (Lv. 50-99): 3,560 + (난이도 - 49)^1.5 × 15
      return 3560 + math.pow(difficulty - 49, 1.5) * 15;
    } else {
      // 세계의 정상, 신들의 산맥 (Lv. 100+): 21,000 + (난이도 - 99)^1.8 × 30
      return 21000 + math.pow(difficulty - 99, 1.8) * 30;
    }
  }

  /// 지역 이름 계산
  static String getRegionName(int difficulty) {
    if (difficulty <= 9) return '초심자의 언덕';
    if (difficulty <= 49) return '한국의 명산';
    if (difficulty <= 99) return '아시아의 지붕';
    if (difficulty <= 199) return '세계의 정상';
    return '신들의 산맥';
  }

  /// 관문 산 여부 확인
  static bool isGatewayMountain(int difficulty) {
    return [10, 20, 30, 50, 75, 100, 150, 200].contains(difficulty);
  }

  // ==================== 사교성 및 특수 보상 시스템 ====================

  /// 사교성에 따른 등반 시간 단축 계산
  /// 사교성 능력치에 따라 등반 시간을 단축 (정보 공유 컨셉)
  /// 공식: 원래 시간 × (1 - (사교성 × 0.002)) (최대 50% 단축)
  static double calculateAdjustedClimbingTime(double originalTimeHours, double socialityLevel) {
    // 사교성 1마다 등반 시간 1% 단축, 최대 10% 단축
    final reductionRate = math.min(socialityLevel * 0.002, 0.10);
    final adjustedTime = originalTimeHours * (1.0 - reductionRate);
    
    // 최소 시간은 원래 시간의 50%로 제한
    return math.max(adjustedTime, originalTimeHours * 0.5);
  }

  /// 숨겨진 보물 발견 확률 계산
  /// 등반 성공 시 추가 보상을 발견할 확률
  /// 공식: 기본 확률 + 난이도 보너스 + 레벨 보너스 + 뱃지 보너스
  static double calculateHiddenTreasureChance(
    int difficulty,
    int userLevel,
    List<GlobalBadge> equippedBadges,
  ) {
    // 기본 확률: 5%
    double baseChance = 0.05;

    // 난이도 보너스: 높은 난이도일수록 보물 발견 확률 증가
    double difficultyBonus = (difficulty / 100.0) * 0.05; // 최대 5% 추가

    // 레벨 보너스: 높은 레벨일수록 보물을 찾는 경험이 풍부
    double levelBonus = (userLevel / 100.0) * 0.03; // 최대 3% 추가

    // 뱃지 보너스 계산
    double badgeBonus = 0.0;
    for (final badge in equippedBadges) {
      if (badge.effectType == 'HIDDEN_TREASURE_CHANCE') {
        badgeBonus += badge.effectValue / 100.0;
      }
    }

    final totalChance = baseChance + difficultyBonus + levelBonus + badgeBonus;
    
    // 최대 20%로 제한
    return math.min(totalChance, 0.20);
  }

  // ==================== 뱃지 시스템 ====================

  /// 레벨업 보상 뱃지 ID 계산
  static String? getLevelUpBadgeId(int level) {
    switch (level) {
      case 10: return 'level_10_adept';
      case 20: return 'level_20_expert';
      case 30: return 'level_30_sherpa';
      case 40: return 'level_40_master';
      case 50: return 'level_50_legend';
      default: return null;
    }
  }

  // ==================== 실패 메시지 ====================

  /// 실패 시 표시할 메시지 목록
  static const List<String> failureMessages = [
    "예상치 못한 폭설로 인해 아쉽게 발걸음을 돌렸습니다. 다음 도전을 위해 지형을 파악했습니다.",
    "강한 바람으로 인해 안전을 위해 하산했습니다. 경험이 쌓였습니다.",
    "날씨 변화로 인해 등반을 중단했습니다. 자연의 힘을 배웠습니다.",
    "체력 부족으로 목표에 도달하지 못했습니다. 더 강해져서 돌아오겠습니다.",
    "장비 문제로 인해 등반을 포기했습니다. 준비의 중요성을 깨달았습니다.",
  ];

  /// 랜덤 실패 메시지 반환
  static String getRandomFailureMessage() {
    final random = math.Random();
    return failureMessages[random.nextInt(failureMessages.length)];
  }

  // ==================== 성공 메시지 ====================

  /// 성공 시 표시할 메시지 목록
  static const List<String> successMessages = [
    "훌륭한 등반이었습니다! 정상에서 바라본 경치가 모든 고생을 보상해줍니다.",
    "완벽한 등반 기술로 정상 정복에 성공했습니다!",
    "끈질긴 노력 끝에 목표를 달성했습니다. 성장이 느껴집니다.",
    "날씨와 지형을 완벽히 파악한 전략적 등반이었습니다!",
    "팀워크와 개인 실력이 조화를 이룬 멋진 등반이었습니다.",
  ];

  /// 랜덤 성공 메시지 반환
  static String getRandomSuccessMessage() {
    final random = math.Random();
    return successMessages[random.nextInt(successMessages.length)];
  }
}