import '../../shared/models/mountain.dart';
import 'game_constants.dart';

/// 전체 앱에서 공유되는 산 목록 데이터
class MountainData {
  /// 모든 산 목록 (메모리 기반 정확한 데이터)
  static final List<Mountain> allMountains = [
    // 초심자의 언덕 (Lv. 1-9)
    Mountain(
      id: 1,
      name: '동네 오르막길',
      region: '초심자의 언덕',
      difficultyLevel: 1,
      durationHours: 0.5,
      requiredPower: GameConstants.calculateRequiredPower(1),

    ),
    Mountain(
      id: 2,
      name: '작은 언덕',
      region: '초심자의 언덕',
      difficultyLevel: 2,
      durationHours: 0.8,
      requiredPower: GameConstants.calculateRequiredPower(2),
    ),
    Mountain(
      id: 3,
      name: '낮은 언덕',
      region: '초심자의 언덕',
      difficultyLevel: 3,
      durationHours: 1,
      requiredPower: GameConstants.calculateRequiredPower(3),
    ),
    Mountain(
      id: 5,
      name: '관악산',
      region: '초심자의 언덕',
      difficultyLevel: 5,
      durationHours: 1.5,
      requiredPower: GameConstants.calculateRequiredPower(5),
    ),
    Mountain(
      id: 8,
      name: '북한산',
      region: '초심자의 언덕',
      difficultyLevel: 8,
      durationHours: 2,
      requiredPower: GameConstants.calculateRequiredPower(8),
    ),

    // 한국의 명산 (Lv. 10-49)
    Mountain(
      id: 10,
      name: '지리산',
      region: '한국의 명산',
      difficultyLevel: 10,
      durationHours: 4,
      requiredPower: GameConstants.calculateRequiredPower(10),
      isGateway: true,
    ),
    Mountain(
      id: 12,
      name: '설악산',
      region: '한국의 명산',
      difficultyLevel: 12,
      durationHours: 5,
      requiredPower: GameConstants.calculateRequiredPower(12),
    ),
    Mountain(
      id: 15,
      name: '태백산',
      region: '한국의 명산',
      difficultyLevel: 15,
      durationHours: 5,
      requiredPower: GameConstants.calculateRequiredPower(15),
    ),
    Mountain(
      id: 20,
      name: '설악산',
      region: '한국의 명산',
      difficultyLevel: 20,
      durationHours: 6,
      requiredPower: GameConstants.calculateRequiredPower(20),
      isGateway: true,
    ),
    Mountain(
      id: 30,
      name: '한라산',
      region: '한국의 명산',
      difficultyLevel: 30,
      durationHours: 8,
      requiredPower: GameConstants.calculateRequiredPower(30),
      isGateway: true,
    ),
    Mountain(
      id: 40,
      name: '덕유산',
      region: '한국의 명산',
      difficultyLevel: 40,
      durationHours: 10,
      requiredPower: GameConstants.calculateRequiredPower(40),
    ),

    // 아시아의 지붕 (Lv. 50-99)
    Mountain(
      id: 50,
      name: '후지산',
      region: '아시아의 지붕',
      difficultyLevel: 50,
      durationHours: 12,
      requiredPower: GameConstants.calculateRequiredPower(50),
      isGateway: true,
    ),
    Mountain(
      id: 75,
      name: '키나발루산',
      region: '아시아의 지붕',
      difficultyLevel: 75,
      durationHours: 18,
      requiredPower: GameConstants.calculateRequiredPower(75),
      isGateway: true,
    ),

    // 세계의 정상 (Lv. 100-199)
    Mountain(
      id: 100,
      name: '몽블랑',
      region: '세계의 정상',
      difficultyLevel: 100,
      durationHours: 24,
      requiredPower: GameConstants.calculateRequiredPower(100),
      isGateway: true,
    ),
    Mountain(
      id: 150,
      name: '킬리만자로',
      region: '세계의 정상',
      difficultyLevel: 150,
      durationHours: 48,
      requiredPower: GameConstants.calculateRequiredPower(150),
      isGateway: true,
    ),

    // 신들의 산맥 (Lv. 200+)
    Mountain(
      id: 200,
      name: '에베레스트',
      region: '신들의 산맥',
      difficultyLevel: 200,
      durationHours: 72,
      requiredPower: GameConstants.calculateRequiredPower(200),
      isGateway: true,
    ),
  ];

  /// 레벨에 따른 추천 산 목록
  static List<Mountain> getRecommendedMountains(int userLevel, double userPower) {
    // 사용자 레벨 ±3 범위의 산들을 추천
    final levelRange = allMountains.where((mountain) {
      final levelDiff = (mountain.difficultyLevel - userLevel).abs();
      return levelDiff <= 3;
    }).toList();

    // 등반력 차이 기준으로 정렬
    levelRange.sort((a, b) {
      final aDiff = (userPower - a.requiredPower).abs();
      final bDiff = (userPower - b.requiredPower).abs();
      return aDiff.compareTo(bDiff);
    });

    return levelRange.take(5).toList();
  }

  /// ID로 산 찾기
  static Mountain? getMountainById(int id) {
    try {
      return allMountains.firstWhere((mountain) => mountain.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 지역별 산 목록
  static List<Mountain> getMountainsByRegion(String region) {
    return allMountains.where((mountain) => mountain.region == region).toList();
  }

  /// 관문 산 목록
  static List<Mountain> getGatewayMountains() {
    return allMountains.where((mountain) => mountain.isGateway == true).toList();
  }

  static List<Mountain> getRecommendedMountainsByPower(double userPower) {
    // 모든 산을 등반력 차이로 정렬
    final sortedMountains = List<Mountain>.from(allMountains);
    sortedMountains.sort((a, b) {
      final aDiff = (userPower - a.requiredPower).abs();
      final bDiff = (userPower - b.requiredPower).abs();
      return aDiff.compareTo(bDiff);
    });

    // 가장 비슷한 3개 반환
    return sortedMountains.take(3).toList();
  }
}


