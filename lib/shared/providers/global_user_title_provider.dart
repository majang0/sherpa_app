import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'global_user_provider.dart';

// 칭호 데이터 모델
class UserTitle {
  final String title;
  final String description;
  final int levelRequirement;
  final double bonus;
  final String icon;

  const UserTitle({
    required this.title,
    required this.description,
    required this.levelRequirement,
    required this.bonus,
    required this.icon,
  });

  // JSON 직렬화 (백엔드 연동 준비)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'levelRequirement': levelRequirement,
      'bonus': bonus,
      'icon': icon,
    };
  }

  factory UserTitle.fromJson(Map<String, dynamic> json) {
    return UserTitle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      levelRequirement: json['levelRequirement'] ?? 0,
      bonus: (json['bonus'] ?? 0).toDouble(),
      icon: json['icon'] ?? '🏔️',
    );
  }
}

// 칭호 목록 (레벨별 자동 승급)
final List<UserTitle> userTitles = [
  UserTitle(
    title: '초보 등반가',
    description: '등반의 첫 걸음을 내딛은 용감한 도전자',
    levelRequirement: 0,
    bonus: 0,
    icon: '🥾',
  ),
  UserTitle(
    title: '신참 등반가',
    description: '기초를 다진 든든한 등반가',
    levelRequirement: 10,
    bonus: 50,
    icon: '⛰️',
  ),
  UserTitle(
    title: '숙련된 등반가',
    description: '경험과 실력을 겸비한 등반 전문가',
    levelRequirement: 20,
    bonus: 120,
    icon: '🏔️',
  ),
  UserTitle(
    title: '등반의 달인',
    description: '모든 산을 정복한 전설적인 등반가',
    levelRequirement: 30,
    bonus: 250,
    icon: '👑',
  ),
  UserTitle(
    title: '산의 정령',
    description: '산과 하나가 된 초월적 존재',
    levelRequirement: 50,
    bonus: 500,
    icon: '✨',
  ),
];

// 현재 사용자 레벨에 따른 칭호를 반환하는 Provider
final globalUserTitleProvider = Provider<UserTitle>((ref) {
  final user = ref.watch(globalUserProvider);
  final level = user.level;

  // 레벨에 맞는 가장 높은 칭호를 찾음
  UserTitle currentTitle = userTitles.first;
  for (final title in userTitles) {
    if (level >= title.levelRequirement) {
      currentTitle = title;
    } else {
      break;
    }
  }

  return currentTitle;
});

// 다음 칭호까지 필요한 레벨을 반환하는 Provider
final nextTitleProvider = Provider<UserTitle?>((ref) {
  final user = ref.watch(globalUserProvider);
  final currentTitle = ref.watch(globalUserTitleProvider);
  final level = user.level;

  // 현재 칭호보다 높은 칭호 중 가장 낮은 것을 찾음
  for (final title in userTitles) {
    if (title.levelRequirement > level) {
      return title;
    }
  }

  return null; // 최고 칭호에 도달한 경우
});

// 다음 칭호까지 필요한 레벨 수를 반환하는 Provider
final levelsToNextTitleProvider = Provider<int?>((ref) {
  final user = ref.watch(globalUserProvider);
  final nextTitle = ref.watch(nextTitleProvider);

  if (nextTitle == null) return null; // 최고 칭호

  return nextTitle.levelRequirement - user.level;
});

// 칭호 보너스만 반환하는 Provider (등반력 계산용)
final titleBonusProvider = Provider<double>((ref) {
  final currentTitle = ref.watch(globalUserTitleProvider);
  return currentTitle.bonus;
});

// 모든 칭호 목록을 반환하는 Provider (칭호 도감용)
final allTitlesProvider = Provider<List<UserTitle>>((ref) {
  return userTitles;
});

// 달성한 칭호들만 반환하는 Provider
final achievedTitlesProvider = Provider<List<UserTitle>>((ref) {
  final user = ref.watch(globalUserProvider);
  final level = user.level;

  return userTitles.where((title) => level >= title.levelRequirement).toList();
});

// 미달성 칭호들만 반환하는 Provider
final unachievedTitlesProvider = Provider<List<UserTitle>>((ref) {
  final user = ref.watch(globalUserProvider);
  final level = user.level;

  return userTitles.where((title) => level < title.levelRequirement).toList();
});

// 칭호 진행률을 반환하는 Provider (0.0 ~ 1.0)
final titleProgressProvider = Provider<double>((ref) {
  final achievedCount = ref.watch(achievedTitlesProvider).length;
  final totalCount = userTitles.length;

  return achievedCount / totalCount;
});
