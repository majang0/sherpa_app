import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../models/global_badge_model.dart';
import '../constants/global_badge_data.dart';
import '../models/mountain.dart';
import '../../core/constants/game_constants.dart';
import '../../core/constants/mountain_data.dart';


/// 게임 시스템 데이터 관리 Provider
/// 게임 공식, 상수, 마스터 데이터 등 모든 사용자가 공유하는 게임 시스템
final globalGameProvider = Provider<GameSystem>((ref) {
  return GameSystem();
});

class GameSystem {
  // ==================== 등반력 공식 ====================

  /// 최종 등반력 계산
  double calculateFinalClimbingPower({
    required int level,
    required double titleBonus,
    required double stamina,
    required double knowledge,
    required double technique,
    required List<GlobalBadge> equippedBadges,
  }) {
    return GameConstants.calculateFinalClimbingPower(
      level: level,
      titleBonus: titleBonus,
      stamina: stamina,
      knowledge: knowledge,
      technique: technique,
      equippedBadges: equippedBadges,
    );
  }

  // ==================== 레벨 및 경험치 시스템 ====================

  /// 레벨별 필요 경험치 계산
  double getRequiredXpForLevel(int level) {
    return GameConstants.getRequiredXpForLevel(level);
  }

  /// 특정 레벨까지의 총 경험치 계산
  double getTotalXpForLevel(int targetLevel) {
    return GameConstants.getTotalXpForLevel(targetLevel);
  }

  /// 레벨별 칭호 보너스 계산
  double getTitleBonus(int level) {
    return GameConstants.getTitleBonus(level);
  }

  /// 레벨별 칭호 이름
  String getTitleName(int level) {
    return GameConstants.getTitleName(level);
  }

  /// 레벨별 최대 뱃지 슬롯
  int getMaxBadgeSlots(int level) {
    return GameConstants.getMaxBadgeSlots(level);
  }

  /// 승급 퀘스트 발동 레벨 확인
  bool isPromotionLevel(int level) {
    return GameConstants.isPromotionLevel(level);
  }

  // ==================== 성공 확률 계산 ====================

  /// 등반 성공 확률 계산
  double calculateSuccessProbability({
    required double userPower,
    required double mountainPower,
    required double willpower,
    required List<GlobalBadge> equippedBadges,
  }) {
    return GameConstants.calculateSuccessProbability(
      userPower: userPower,
      mountainPower: mountainPower,
      willpower: willpower,
      equippedBadges: equippedBadges,
    );
  }

  // ==================== 보상 시스템 ====================

  /// 성공 시 경험치 계산
  double calculateSuccessXp(int difficulty, double durationHours) {
    return GameConstants.calculateSuccessXp(difficulty, durationHours);
  }

  /// 성공 시 포인트 계산
  double calculateSuccessPoints(int difficulty, double durationHours) {
    return GameConstants.calculateSuccessPoints(difficulty, durationHours);
  }

  /// 실패 시 경험치 계산
  double calculateFailureXp(int difficulty, double durationHours) {
    return GameConstants.calculateFailureXp(difficulty, durationHours);
  }

  // ==================== 능력치 시스템 ====================

  /// 능력치 등급 계산
  String getStatGrade(double statValue) {
    return GameConstants.getStatGrade(statValue);
  }

  /// 퀘스트 완료 시 능력치 증가 계산 (확률 기반)
  double calculateStatIncrease(String questType, String statType) {
    final chanceData = GameConstants.getStatIncreaseChance(questType);
    final random = math.Random();

    if (random.nextDouble() < chanceData['chance']) {
      return chanceData['increase'] as double;
    }
    return 0.0;
  }

  // ==================== 뱃지 시스템 ====================

  /// 레벨업 보상 뱃지 반환
  GlobalBadge? getLevelUpRewardBadge(int level) {
    final badgeId = GameConstants.getLevelUpBadgeId(level);
    if (badgeId == null) return null;

    return GlobalBadgeData.getBadgeById(badgeId);
  }



  // ==================== 산 목록 및 지역 시스템 ====================

  /// 모든 산 목록
  List<Mountain> get allMountains => MountainData.allMountains;

  /// 레벨에 따른 추천 산 목록
  List<Mountain> getRecommendedMountains(int userLevel, double userPower) {
    return MountainData.getRecommendedMountains(userLevel, userPower);
  }

  /// ID로 산 찾기
  Mountain? getMountainById(int id) {
    return MountainData.getMountainById(id);
  }

  /// 관문 산 목록
  List<Mountain> get gatewayMountains => MountainData.getGatewayMountains();

  // ==================== 메시지 시스템 ====================

  /// 랜덤 성공 메시지
  String getRandomSuccessMessage() {
    return GameConstants.getRandomSuccessMessage();
  }

  /// 랜덤 실패 메시지
  String getRandomFailureMessage() {
    return GameConstants.getRandomFailureMessage();
  }

  // ==================== 뱃지 시스템 통합 ====================

  /// 모든 뱃지 마스터 데이터 (GlobalBadgeData에서 가져옴)
  List<GlobalBadge> get allBadges => GlobalBadgeData.getAllBadges();
}

/// 게임 시스템 관련 Provider들

final globalMountainListProvider = Provider<List<Mountain>>((ref) {
  final gameSystem = ref.watch(globalGameProvider);
  return gameSystem.allMountains;
});

final globalGatewayMountainsProvider = Provider<List<Mountain>>((ref) {
  final gameSystem = ref.watch(globalGameProvider);
  return gameSystem.gatewayMountains;
});

// ✅ 통합된 뱃지 Provider는 global_badge_provider.dart에서 제공됩니다.
// 중복 방지를 위해 이 Provider는 제거되었습니다.