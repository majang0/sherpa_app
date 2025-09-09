# ⚔️ 셰르파 앱 전투 & 장비 시스템 상세 설계서

## 🗡️ 전투 시스템 (Combat System)

### 전투 발생 조건
```dart
class CombatTrigger {
  // 등반 중 랜덤 인카운터
  bool checkRandomEncounter(int climbingDistance) {
    double encounterRate = 0.05 + (climbingDistance / 1000) * 0.01;
    return Random().nextDouble() < encounterRate;
  }
  
  // 특정 지점 보스전
  bool checkBossEncounter(Mountain mountain, int altitude) {
    return mountain.bossAltitudes.contains(altitude);
  }
  
  // 이벤트 전투
  bool checkEventCombat(DateTime currentTime) {
    return EventManager.hasActiveCombatEvent(currentTime);
  }
}
```

### 전투 메커니즘

#### 턴 순서 결정
```dart
class TurnOrder {
  List<Combatant> calculateTurnOrder(List<Combatant> participants) {
    return participants
      ..sort((a, b) => b.getInitiative().compareTo(a.getInitiative()));
  }
  
  int getInitiative(Character character) {
    return character.stats.technique + // 기술 스탯
           character.equipment.getSpeedBonus() + // 장비 보너스
           Random().nextInt(20); // 랜덤 요소
  }
}
```

#### 데미지 계산 공식
```dart
class DamageCalculator {
  int calculatePhysicalDamage(Attacker attacker, Defender defender) {
    int baseDamage = attacker.stats.stamina * 2;
    int weaponDamage = attacker.weapon?.attackPower ?? 0;
    int defense = defender.stats.stamina + defender.armor?.defense ?? 0;
    
    int damage = ((baseDamage + weaponDamage) * (100 / (100 + defense))).round();
    
    // 크리티컬 판정
    if (Random().nextDouble() < attacker.getCriticalRate()) {
      damage = (damage * 1.5).round();
      showCriticalEffect();
    }
    
    // 속성 상성
    damage = applyElementalModifier(damage, attacker.element, defender.element);
    
    return max(1, damage); // 최소 1 데미지 보장
  }
  
  double getCriticalRate(Character character) {
    double baseRate = 0.05; // 5% 기본 확률
    double techniqueBonus = character.stats.technique * 0.002; // 기술당 0.2%
    double equipmentBonus = character.equipment.getCritBonus();
    
    return min(0.5, baseRate + techniqueBonus + equipmentBonus); // 최대 50%
  }
}
```

### 전투 행동 시스템

#### 기본 행동
```dart
enum CombatAction {
  attack,     // 기본 공격
  defend,     // 방어 (데미지 50% 감소)
  useSkill,   // 스킬 사용
  useItem,    // 아이템 사용
  escape,     // 도망 (성공률 있음)
  sherpiAssist, // 셰르피 지원 요청 (1일 1회)
}

class CombatActionHandler {
  void executeAction(CombatAction action, Combatant actor, Combatant target) {
    switch(action) {
      case CombatAction.attack:
        int damage = calculateDamage(actor, target);
        target.takeDamage(damage);
        showAttackAnimation(actor, target);
        break;
        
      case CombatAction.defend:
        actor.setDefenseStance(true);
        actor.gainSP(10); // 방어 시 SP 회복
        break;
        
      case CombatAction.useSkill:
        if (actor.canUseSkill(selectedSkill)) {
          selectedSkill.execute(actor, target);
          actor.consumeSP(selectedSkill.cost);
        }
        break;
        
      case CombatAction.escape:
        double escapeChance = 0.3 + (actor.stats.technique / 100);
        if (Random().nextDouble() < escapeChance) {
          endCombat(CombatResult.escaped);
        }
        break;
    }
  }
}
```

### 스킬 시스템

#### 스킬 카테고리
```dart
class SkillCategory {
  static const Map<StatType, List<Skill>> skillTree = {
    StatType.stamina: [
      Skill('강타', cost: 20, damage: 150, description: '강력한 물리 공격'),
      Skill('철벽', cost: 30, effect: 'DEF +50% (3턴)', description: '방어력 대폭 상승'),
      Skill('불굴', cost: 50, effect: 'HP 30% 회복', description: '체력 회복'),
    ],
    
    StatType.knowledge: [
      Skill('약점 분석', cost: 15, effect: '크리티컬 +30%', description: '적의 약점 파악'),
      Skill('전략 수립', cost: 25, effect: '팀 전체 ATK +20%', description: '공격력 상승'),
      Skill('예측', cost: 40, effect: '회피율 +50% (2턴)', description: '적의 공격 예측'),
    ],
    
    StatType.technique: [
      Skill('정밀 타격', cost: 25, damage: 120, critBonus: 50, description: '높은 크리티컬'),
      Skill('연속 공격', cost: 35, hits: 3, damage: 60, description: '3회 연속 공격'),
      Skill('카운터', cost: 20, effect: '반격 준비', description: '다음 공격 반격'),
    ],
    
    StatType.sociality: [
      Skill('응원', cost: 15, effect: '팀 전체 SP +20', description: 'SP 회복'),
      Skill('협동 공격', cost: 30, damage: 100, sherpiBonus: true, description: '셰르피와 합동 공격'),
      Skill('리더십', cost: 40, effect: '팀 전체 스탯 +15%', description: '전체 능력치 상승'),
    ],
    
    StatType.willpower: [
      Skill('집중', cost: 10, effect: '다음 공격 데미지 x2', description: '다음 공격 강화'),
      Skill('각성', cost: 60, effect: '모든 스탯 +30% (3턴)', description: '일시적 각성'),
      Skill('극한 돌파', cost: 100, damage: 500, recoil: 0.3, description: '초강력 공격'),
    ],
  };
}
```

#### 스킬 레벨 시스템
```dart
class SkillLevel {
  int level = 1;
  int experience = 0;
  
  static const Map<int, SkillUpgrade> upgrades = {
    1: SkillUpgrade(damage: 100, cost: 20),
    2: SkillUpgrade(damage: 120, cost: 20),
    3: SkillUpgrade(damage: 140, cost: 19),
    4: SkillUpgrade(damage: 160, cost: 19),
    5: SkillUpgrade(damage: 200, cost: 18, additionalEffect: 'Stun 10%'),
  };
  
  void gainExperience(int amount) {
    experience += amount;
    if (experience >= getRequiredExp()) {
      levelUp();
    }
  }
  
  int getRequiredExp() => level * 100;
}
```

### 전투 UI/UX

#### 전투 화면 레이아웃
```
┌─────────────────────────────┐
│  적 정보                     │
│  [========] HP: 450/500     │
│  Lv.15 산악 곰              │
│                             │
│         🐻                  │
│                             │
│  ⚡ 효과: 분노 (ATK +20%)    │
├─────────────────────────────┤
│                             │
│         🧗                  │
│                             │
│  나의 정보                   │
│  [==========] HP: 280/300   │
│  [======] SP: 60/100        │
│  Lv.12 등반가                │
├─────────────────────────────┤
│ [⚔️공격] [🛡️방어] [💫스킬]  │
│ [🎒아이템] [🏃도망] [🆘도움] │
└─────────────────────────────┘
```

#### 전투 애니메이션
```dart
class CombatAnimations {
  // 기본 공격 애니메이션
  Future<void> playAttackAnimation(Widget attacker, Widget target) async {
    // 공격자 전진
    await attacker.animate()
      .moveX(duration: 200.ms, end: 50)
      .then()
      .shake(duration: 100.ms);
    
    // 타격 이펙트
    await target.animate()
      .shake(hz: 10, duration: 200.ms)
      .tint(color: Colors.red.withOpacity(0.3));
    
    // 데미지 숫자 표시
    showDamageNumber(target.position, damage);
    
    // 공격자 복귀
    await attacker.animate()
      .moveX(duration: 200.ms, end: 0);
  }
  
  // 스킬 이펙트
  Future<void> playSkillEffect(SkillType skill) async {
    switch(skill) {
      case SkillType.fireball:
        await showParticleEffect(FireParticles());
        break;
      case SkillType.heal:
        await showParticleEffect(HealingParticles());
        break;
    }
  }
}
```

## 🛡️ 장비 시스템 (Equipment System)

### 장비 구조
```dart
class Equipment {
  final String id;
  final String name;
  final EquipmentSlot slot;
  final EquipmentRarity rarity;
  final int level;
  final Map<StatType, int> baseStats;
  final List<EquipmentOption> options;
  final SetBonus? setBonus;
  
  int getStatBonus(StatType stat) {
    int base = baseStats[stat] ?? 0;
    int enhancement = level * 2;
    int optionBonus = options
      .where((opt) => opt.stat == stat)
      .fold(0, (sum, opt) => sum + opt.value);
    
    return base + enhancement + optionBonus;
  }
}
```

### 장비 등급과 옵션

#### 등급별 특성
```dart
enum EquipmentRarity {
  common(
    color: Colors.grey,
    maxOptions: 0,
    statMultiplier: 1.0,
    dropRate: 0.6,
  ),
  
  rare(
    color: Colors.blue,
    maxOptions: 1,
    statMultiplier: 1.2,
    dropRate: 0.25,
  ),
  
  epic(
    color: Colors.purple,
    maxOptions: 2,
    statMultiplier: 1.5,
    dropRate: 0.1,
  ),
  
  legendary(
    color: Colors.orange,
    maxOptions: 3,
    statMultiplier: 2.0,
    dropRate: 0.04,
    specialEffect: true,
  ),
  
  mythic(
    color: Colors.red,
    maxOptions: 4,
    statMultiplier: 3.0,
    dropRate: 0.01,
    specialEffect: true,
    setBonus: true,
  ),
}
```

#### 장비 옵션 풀
```dart
class EquipmentOptions {
  static const List<PossibleOption> optionPool = [
    // 기본 스탯
    PossibleOption('체력 증가', StatType.stamina, range: [5, 20]),
    PossibleOption('지식 증가', StatType.knowledge, range: [5, 20]),
    PossibleOption('기술 증가', StatType.technique, range: [5, 20]),
    PossibleOption('사회성 증가', StatType.sociality, range: [5, 20]),
    PossibleOption('의지력 증가', StatType.willpower, range: [5, 20]),
    
    // 특수 옵션
    PossibleOption('크리티컬 확률', SpecialStat.critRate, range: [2, 10], unit: '%'),
    PossibleOption('크리티컬 데미지', SpecialStat.critDamage, range: [10, 30], unit: '%'),
    PossibleOption('회피율', SpecialStat.evasion, range: [3, 15], unit: '%'),
    PossibleOption('경험치 획득량', SpecialStat.expBonus, range: [5, 20], unit: '%'),
    PossibleOption('아이템 드롭률', SpecialStat.dropRate, range: [5, 15], unit: '%'),
    PossibleOption('SP 재생', SpecialStat.spRegen, range: [1, 5], unit: '/턴'),
  ];
  
  static List<EquipmentOption> generateOptions(EquipmentRarity rarity) {
    int optionCount = Random().nextInt(rarity.maxOptions + 1);
    return List.generate(optionCount, (_) => getRandomOption());
  }
}
```

### 장비 강화 시스템

#### 강화 메커니즘
```dart
class EquipmentEnhancement {
  static const int maxLevel = 10;
  
  EnhancementResult enhance(Equipment equipment, List<Material> materials) {
    if (equipment.level >= maxLevel) {
      return EnhancementResult.maxLevel;
    }
    
    double successRate = calculateSuccessRate(equipment.level);
    int cost = calculateCost(equipment.level, equipment.rarity);
    
    if (!hasRequiredMaterials(materials, equipment.level)) {
      return EnhancementResult.insufficientMaterials;
    }
    
    if (Random().nextDouble() < successRate) {
      equipment.level++;
      applyEnhancementBonus(equipment);
      return EnhancementResult.success;
    } else {
      // 실패 시 처리
      if (equipment.level >= 7) {
        // 7강 이상은 실패 시 강화 수치 하락
        equipment.level--;
      }
      return EnhancementResult.failure;
    }
  }
  
  double calculateSuccessRate(int currentLevel) {
    // 레벨별 성공률
    const rates = [
      1.0,   // 0→1: 100%
      0.95,  // 1→2: 95%
      0.90,  // 2→3: 90%
      0.85,  // 3→4: 85%
      0.70,  // 4→5: 70%
      0.60,  // 5→6: 60%
      0.45,  // 6→7: 45%
      0.30,  // 7→8: 30%
      0.20,  // 8→9: 20%
      0.10,  // 9→10: 10%
    ];
    return rates[currentLevel];
  }
  
  Map<MaterialType, int> getRequiredMaterials(int level) {
    return {
      MaterialType.enhancementStone: level * 2,
      MaterialType.gold: level * 1000,
      if (level >= 5) MaterialType.rareMaterial: level - 4,
      if (level >= 8) MaterialType.epicMaterial: level - 7,
    };
  }
}
```

#### 각성 시스템 (10강 이후)
```dart
class EquipmentAwakening {
  static const int maxAwakeningLevel = 5;
  
  AwakeningResult awaken(Equipment equipment, List<AwakeningStone> stones) {
    if (equipment.level < 10) {
      return AwakeningResult.notMaxLevel;
    }
    
    if (equipment.awakeningLevel >= maxAwakeningLevel) {
      return AwakeningResult.maxAwakening;
    }
    
    // 각성은 100% 성공하지만 비용이 높음
    if (stones.length < getRequiredStones(equipment.awakeningLevel)) {
      return AwakeningResult.insufficientStones;
    }
    
    equipment.awakeningLevel++;
    applyAwakeningBonus(equipment);
    
    // 특정 각성 레벨에서 특별 능력 해금
    if (equipment.awakeningLevel == 3) {
      equipment.unlockSpecialAbility();
    }
    
    return AwakeningResult.success;
  }
  
  void applyAwakeningBonus(Equipment equipment) {
    // 각성당 모든 스탯 10% 증가
    equipment.statMultiplier += 0.1;
    
    // 특별 옵션 추가
    if (equipment.awakeningLevel % 2 == 0) {
      equipment.addRandomOption();
    }
  }
}
```

### 세트 장비 시스템

#### 세트 효과
```dart
class SetBonus {
  final String setName;
  final List<String> requiredPieces;
  final Map<int, SetEffect> effects;
  
  static const Map<String, SetBonus> sets = {
    '초보 등반가': SetBonus(
      requiredPieces: ['초보 등산화', '초보 배낭', '초보 장갑'],
      effects: {
        2: SetEffect('체력 +10', {StatType.stamina: 10}),
        3: SetEffect('체력 +20, HP재생 +5/턴', {
          StatType.stamina: 20,
          SpecialStat.hpRegen: 5,
        }),
      },
    ),
    
    '베테랑 산악인': SetBonus(
      requiredPieces: ['베테랑 등산화', '베테랑 배낭', '베테랑 등산복', '베테랑 장갑', '베테랑 모자'],
      effects: {
        2: SetEffect('모든 스탯 +5', allStats: 5),
        3: SetEffect('모든 스탯 +10, 크리티컬 +5%', allStats: 10, critRate: 0.05),
        4: SetEffect('모든 스탯 +15, 크리티컬 +10%, 회피 +10%', 
          allStats: 15, critRate: 0.1, evasion: 0.1),
        5: SetEffect('모든 스탯 +25, 특수 스킬 "산의 가호" 해금',
          allStats: 25, specialSkill: '산의 가호'),
      },
    ),
  };
  
  SetEffect? getActiveEffect(List<Equipment> equipped) {
    int setPieceCount = equipped
      .where((e) => requiredPieces.contains(e.name))
      .length;
    
    // 가장 높은 세트 효과 반환
    for (int i = setPieceCount; i > 0; i--) {
      if (effects.containsKey(i)) {
        return effects[i];
      }
    }
    return null;
  }
}
```

### 장비 제작 시스템

#### 제작 레시피
```dart
class CraftingRecipe {
  final String resultItemId;
  final Map<String, int> requiredMaterials;
  final int requiredLevel;
  final double successRate;
  
  static const List<CraftingRecipe> recipes = [
    CraftingRecipe(
      resultItemId: 'sturdy_boots',
      requiredMaterials: {
        'leather': 10,
        'iron_ore': 5,
        'thread': 3,
      },
      requiredLevel: 10,
      successRate: 0.8,
    ),
    
    CraftingRecipe(
      resultItemId: 'mystic_staff',
      requiredMaterials: {
        'magic_wood': 15,
        'mana_crystal': 5,
        'gold_ore': 3,
        'ancient_scroll': 1,
      },
      requiredLevel: 30,
      successRate: 0.5,
    ),
  ];
}

class CraftingSystem {
  CraftingResult craft(CraftingRecipe recipe, Character crafter) {
    if (crafter.level < recipe.requiredLevel) {
      return CraftingResult.levelTooLow;
    }
    
    if (!hasAllMaterials(recipe.requiredMaterials)) {
      return CraftingResult.insufficientMaterials;
    }
    
    consumeMaterials(recipe.requiredMaterials);
    
    // 제작 스킬에 따른 성공률 보너스
    double finalSuccessRate = recipe.successRate + 
      (crafter.stats.technique * 0.002); // 기술 스탯당 0.2% 추가
    
    if (Random().nextDouble() < finalSuccessRate) {
      Equipment crafted = generateEquipment(recipe.resultItemId);
      
      // 대성공 확률 (더 좋은 옵션)
      if (Random().nextDouble() < 0.1) {
        crafted.addBonusOption();
        return CraftingResult.greatSuccess;
      }
      
      return CraftingResult.success;
    } else {
      // 실패 시 일부 재료 반환
      returnPartialMaterials(recipe.requiredMaterials, 0.3);
      return CraftingResult.failure;
    }
  }
}
```

### 장비 UI/UX

#### 장비 인벤토리 화면
```
┌─────────────────────────────┐
│  🎒 장비 인벤토리            │
├─────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌─────┐   │
│ │ 모자 │ │     │ │     │   │
│ │ ⭐⭐ │ │     │ │     │   │
│ └─────┘ └─────┘ └─────┘   │
│                             │
│ ┌─────┐ ┌─────┐ ┌─────┐   │
│ │등산복│ │ 장갑 │ │     │   │
│ │ ⭐⭐⭐│ │ ⭐  │ │     │   │
│ └─────┘ └─────┘ └─────┘   │
│                             │
│ ┌─────┐ ┌─────┐ ┌─────┐   │
│ │ 배낭 │ │등산화│ │액세서리│ │
│ │ ⭐⭐⭐⭐│ │ ⭐⭐ │ │ ⭐⭐⭐│ │
│ └─────┘ └─────┘ └─────┘   │
├─────────────────────────────┤
│ 선택된 장비: 전설 등산화     │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│ 📊 스탯:                    │
│ • 체력 +25                  │
│ • 이동속도 +15%             │
│ • 크리티컬 확률 +8%         │
│                             │
│ 🔨 강화: +7                 │
│ 💎 세트: 베테랑 산악인 (2/5) │
│                             │
│ [강화] [각성] [분해] [잠금]  │
└─────────────────────────────┘
```

#### 장비 비교 UI
```dart
class EquipmentComparisonWidget extends StatelessWidget {
  final Equipment currentEquipment;
  final Equipment newEquipment;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            EquipmentCard(currentEquipment),
            Icon(Icons.arrow_forward),
            EquipmentCard(newEquipment),
          ],
        ),
        StatComparisonList(
          current: currentEquipment.getTotalStats(),
          new: newEquipment.getTotalStats(),
        ),
        if (wouldBreakSetBonus())
          WarningMessage('세트 효과가 해제됩니다!'),
      ],
    );
  }
}
```

## 🎮 전투-장비 연동 시스템

### 장비 기반 전투 스타일
```dart
class CombatStyle {
  static CombatModifiers getStyleModifiers(List<Equipment> equipped) {
    // 장비 조합에 따른 전투 스타일 결정
    if (hasHeavyArmor(equipped)) {
      return CombatModifiers(
        name: '탱커',
        defenseBonus: 0.3,
        speedPenalty: -0.2,
        specialSkills: ['철벽 방어', '도발'],
      );
    } else if (hasLightArmor(equipped) && hasAgilityItems(equipped)) {
      return CombatModifiers(
        name: '암살자',
        critBonus: 0.3,
        evasionBonus: 0.2,
        specialSkills: ['은신', '급소 공격'],
      );
    }
    // ... 더 많은 스타일
  }
}
```

### 장비 특수 효과 발동
```dart
class EquipmentSpecialEffects {
  void checkCombatTriggers(CombatEvent event, Equipment equipment) {
    switch(equipment.specialEffect) {
      case 'Thorns':
        // 피격 시 반사 데미지
        if (event.type == CombatEventType.damaged) {
          event.attacker.takeDamage(event.damage * 0.2);
        }
        break;
        
      case 'Lifesteal':
        // 공격 시 흡혈
        if (event.type == CombatEventType.dealDamage) {
          event.actor.heal(event.damage * 0.15);
        }
        break;
        
      case 'Berserker':
        // HP 30% 이하에서 공격력 증가
        if (event.actor.hpPercent < 0.3) {
          event.actor.tempStats.attack *= 1.5;
        }
        break;
    }
  }
}
```

---

*이 문서는 셰르파 앱의 전투 및 장비 시스템 상세 설계를 담고 있습니다. 깊이 있는 RPG 경험을 제공하면서도 모바일 환경에 최적화된 시스템을 목표로 합니다.*