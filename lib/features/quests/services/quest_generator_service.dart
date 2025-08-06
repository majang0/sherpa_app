import 'dart:math' as math;
import '../models/quest_template_model.dart';
import '../models/quest_instance_model.dart';
import '../data/quest_templates_data.dart';

/// 새로운 퀘스트 생성 서비스
/// quest.md의 로직에 따라 퀘스트를 생성합니다.
class QuestGeneratorService {
  static final _random = math.Random();

  /// 일일 퀘스트 생성 (매주 5개)
  /// 각 난이도별로 적절히 분배
  static List<QuestInstance> generateDailyQuests() {
    final selectedQuests = <QuestInstance>[];
    
    // quest.md에 따른 일일 퀘스트 분배
    // 쉬움 2개, 보통 2개, 어려움 1개 (총 5개)
    
    // 쉬움 난이도 2개 선택
    final easyTemplates = QuestTemplatesData.dailyEasyQuests;
    final selectedEasy = _selectRandomTemplates(easyTemplates, 2);
    selectedQuests.addAll(selectedEasy.map((t) => QuestInstance.fromTemplate(t)));
    
    // 보통 난이도 2개 선택
    final mediumTemplates = QuestTemplatesData.dailyMediumQuests;
    final selectedMedium = _selectRandomTemplates(mediumTemplates, 2);
    selectedQuests.addAll(selectedMedium.map((t) => QuestInstance.fromTemplate(t)));
    
    // 어려움 난이도 1개 선택
    final hardTemplates = QuestTemplatesData.dailyHardQuests;
    final selectedHard = _selectRandomTemplates(hardTemplates, 1);
    selectedQuests.addAll(selectedHard.map((t) => QuestInstance.fromTemplate(t)));
    
    return selectedQuests;
  }

  /// 주간 퀘스트 생성 (매주 5개)
  /// 각 난이도별로 적절히 분배
  static List<QuestInstance> generateWeeklyQuests() {
    final selectedQuests = <QuestInstance>[];
    
    // quest.md에 따른 주간 퀘스트 분배
    // 쉬움 1개, 보통 3개, 어려움 1개 (총 5개)
    
    // 쉬움 난이도 1개 선택
    final easyTemplates = QuestTemplatesData.weeklyEasyQuests;
    final selectedEasy = _selectRandomTemplates(easyTemplates, 1);
    selectedQuests.addAll(selectedEasy.map((t) => QuestInstance.fromTemplate(t)));
    
    // 보통 난이도 3개 선택
    final mediumTemplates = QuestTemplatesData.weeklyMediumQuests;
    final selectedMedium = _selectRandomTemplates(mediumTemplates, 3);
    selectedQuests.addAll(selectedMedium.map((t) => QuestInstance.fromTemplate(t)));
    
    // 어려움 난이도 1개 선택
    final hardTemplates = QuestTemplatesData.weeklyHardQuests;
    final selectedHard = _selectRandomTemplates(hardTemplates, 1);
    selectedQuests.addAll(selectedHard.map((t) => QuestInstance.fromTemplate(t)));
    
    return selectedQuests;
  }

  /// 고급 퀘스트 생성 (매주 3개, 유료)
  /// 희귀도별로 확률 기반 분배
  static List<QuestInstance> generatePremiumQuests() {
    final selectedQuests = <QuestInstance>[];
    
    // quest.md에 따른 고급 퀘스트 분배 (총 3개)
    // 확률 기반: 레어 60%, 에픽 30%, 전설 10%
    
    final allPremiumTemplates = QuestTemplatesData.getPremiumTemplates();
    final selectedTemplates = <QuestTemplate>[];
    
    // 정확히 3개를 보장하기 위해 최대 10번 시도
    int attempts = 0;
    while (selectedTemplates.length < 3 && attempts < 10) {
      final rarityRoll = _random.nextDouble();
      QuestRarityV2 targetRarity;
      
      if (rarityRoll < 0.10) {        // 10% 확률로 전설
        targetRarity = QuestRarityV2.legendary;
      } else if (rarityRoll < 0.40) { // 30% 확률로 에픽 (10% + 30% = 40%)
        targetRarity = QuestRarityV2.epic;
      } else {                        // 60% 확률로 레어
        targetRarity = QuestRarityV2.rare;
      }
      
      // 해당 희귀도의 템플릿 중에서 선택
      final rarityTemplates = allPremiumTemplates
          .where((t) => t.rarity == targetRarity)
          .toList();
      
      if (rarityTemplates.isNotEmpty) {
        final selected = rarityTemplates[_random.nextInt(rarityTemplates.length)];
        if (!selectedTemplates.any((t) => t.id == selected.id)) {
          selectedTemplates.add(selected);
        }
      }
      attempts++;
    }
    
    // 부족한 경우 남은 템플릿에서 무작위 선택
    if (selectedTemplates.length < 3) {
      final remainingTemplates = allPremiumTemplates
          .where((t) => !selectedTemplates.any((s) => s.id == t.id))
          .toList();
      
      while (selectedTemplates.length < 3 && remainingTemplates.isNotEmpty) {
        final randomIndex = _random.nextInt(remainingTemplates.length);
        selectedTemplates.add(remainingTemplates.removeAt(randomIndex));
      }
    }
    
    selectedQuests.addAll(selectedTemplates.map((t) => QuestInstance.fromTemplate(t)));
    
    return selectedQuests;
  }

  /// 템플릿 리스트에서 랜덤하게 count개 선택
  static List<QuestTemplate> _selectRandomTemplates(List<QuestTemplate> templates, int count) {
    if (templates.length <= count) {
      return List<QuestTemplate>.from(templates);
    }
    
    final shuffled = List<QuestTemplate>.from(templates);
    shuffled.shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// 특정 유형의 퀘스트 모두 완료 확인
  static bool areAllQuestsCompleted(List<QuestInstance> quests, QuestTypeV2 type) {
    final typeQuests = quests.where((q) => q.type == type).toList();
    if (typeQuests.isEmpty) return false;
    
    return typeQuests.every((q) => q.status == QuestStatus.claimed);
  }

  /// 일일 퀘스트 전체 완료 확인 (5개 모두)
  static bool areAllDailyQuestsCompleted(List<QuestInstance> quests) {
    final dailyQuests = quests.where((q) => q.type == QuestTypeV2.daily).toList();
    return dailyQuests.length == 5 && 
           dailyQuests.every((q) => q.status == QuestStatus.claimed);
  }

  /// 주간 퀘스트 전체 완료 확인 (5개 모두)
  static bool areAllWeeklyQuestsCompleted(List<QuestInstance> quests) {
    final weeklyQuests = quests.where((q) => q.type == QuestTypeV2.weekly).toList();
    return weeklyQuests.length == 5 && 
           weeklyQuests.every((q) => q.status == QuestStatus.claimed);
  }

  /// 카테고리별 퀘스트 분포 확인
  static Map<QuestCategoryV2, int> getCategoryDistribution(List<QuestInstance> quests) {
    final distribution = <QuestCategoryV2, int>{};
    
    for (final category in QuestCategoryV2.values) {
      distribution[category] = quests.where((q) => q.category == category).length;
    }
    
    return distribution;
  }

  /// 난이도별 퀘스트 분포 확인
  static Map<String, int> getDifficultyDistribution(List<QuestInstance> quests) {
    final distribution = <String, int>{};
    
    for (final quest in quests) {
      final difficulty = quest.difficultyName;
      distribution[difficulty] = (distribution[difficulty] ?? 0) + 1;
    }
    
    return distribution;
  }

  /// 퀘스트 생성 통계
  static QuestGenerationStats getGenerationStats(List<QuestInstance> quests) {
    final dailyQuests = quests.where((q) => q.type == QuestTypeV2.daily).length;
    final weeklyQuests = quests.where((q) => q.type == QuestTypeV2.weekly).length;
    final premiumQuests = quests.where((q) => q.type == QuestTypeV2.premium).length;
    
    return QuestGenerationStats(
      totalQuests: quests.length,
      dailyQuests: dailyQuests,
      weeklyQuests: weeklyQuests,
      premiumQuests: premiumQuests,
      categoryDistribution: getCategoryDistribution(quests),
      difficultyDistribution: getDifficultyDistribution(quests),
    );
  }

  /// 유효한 퀘스트 생성 확인
  static bool validateQuestGeneration(List<QuestInstance> quests) {
    final stats = getGenerationStats(quests);
    
    // 일일 퀘스트 5개, 주간 퀘스트 5개, 고급 퀘스트 3개 확인
    final dailyValid = stats.dailyQuests == 5;
    final weeklyValid = stats.weeklyQuests == 5;
    final premiumValid = stats.premiumQuests == 3;
    
    // 모든 카테고리가 적어도 1개씩 있는지 확인
    final categoryValid = stats.categoryDistribution.values.every((count) => count > 0);
    
    return dailyValid && weeklyValid && premiumValid && categoryValid;
  }

  /// 퀘스트 균형 재조정
  static List<QuestInstance> rebalanceQuests(List<QuestInstance> quests) {
    final stats = getGenerationStats(quests);
    
    // 카테고리 균형이 맞지 않으면 재생성
    if (!stats.categoryDistribution.values.every((count) => count > 0)) {
      return [
        ...generateDailyQuests(),
        ...generateWeeklyQuests(),
        ...generatePremiumQuests(),
      ];
    }
    
    return quests;
  }
}

/// 퀘스트 생성 통계
class QuestGenerationStats {
  final int totalQuests;
  final int dailyQuests;
  final int weeklyQuests;
  final int premiumQuests;
  final Map<QuestCategoryV2, int> categoryDistribution;
  final Map<String, int> difficultyDistribution;

  const QuestGenerationStats({
    required this.totalQuests,
    required this.dailyQuests,
    required this.weeklyQuests,
    required this.premiumQuests,
    required this.categoryDistribution,
    required this.difficultyDistribution,
  });

  @override
  String toString() {
    return '''
QuestGenerationStats {
  총 퀘스트: $totalQuests
  일일: $dailyQuests, 주간: $weeklyQuests, 고급: $premiumQuests
  카테고리별: $categoryDistribution
  난이도별: $difficultyDistribution
}''';
  }
}