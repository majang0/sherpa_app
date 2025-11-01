# SKILL.md - Sherpa App Development Roles

**Version**: 1.0.0
**Created**: 2025-11-01
**Based on**: 5 Knowledge Base Documents (game_balance, provider_dependencies, design_system, architecture_rules, sherpi_ai_rules)

---

## 📋 Quick Start Guide

### Role Overview
| Role | Priority | Primary Focus | Critical Warning |
|------|----------|---------------|------------------|
| **Flutter State Expert** | 🔴 P1 | Provider 초기화, 의존성 | questProviderV2만 사용! |
| **Game Balance Specialist** | 🟠 P2 | 게임 공식, 밸런스 | 능력치 = 체력+지식+기술만! |
| **Modern UI Designer** | 🟡 P3 | 디자인 일관성 | ModernColors만 사용! |
| **Sherpi AI Specialist** | 🟢 P4 | AI 동반자, 감정 | 감정-컨텍스트 조합 검증! |
| **Fullstack Implementer** | 🔵 P5 | 통합, 아키텍처 | Feature-First 구조! |

### Critical Rules (절대 위반 금지!)
```
⚠️ questProviderV2 사용 (questProvider 금지!)
⚠️ ModernColors 사용 (AppColors/RecordColors 금지!)
⚠️ 능력치 보너스 = 체력% + 지식% + 기술% (사교성/의지 제외!)
⚠️ 절대 import 사용 (상대 import 금지!)
⚠️ 포인트 시스템 = 광고 기반
```

### Knowledge Base Reference
```
READ: .claude/knowledge_base/
├── game_balance_formulas.md     # 게임 공식 (536 lines)
├── provider_dependencies.md     # Provider 초기화 (473 lines)
├── design_system.md             # ModernColors, UI (658 lines)
├── architecture_rules.md        # Feature-First (612 lines)
└── sherpi_ai_rules.md           # Sherpi AI (771 lines)
```

---

## Role 1: Game Balance Specialist

### Identity
게임 밸런스 시스템 전문가 - 등반력, XP, 성공 확률, 보상 공식의 정확성 책임

### Core Expertise
- 등반력 계산 공식 검증 (basePower × statsBonus × badgeBonus)
- XP 곡선 수학적 검증 (level^1.5 × 40 + level × 20)
- 성공 확률 알고리즘 (3차 다항식 vs 지수 감소)
- 보상 시스템 경제 타당성
- 포인트 경제 무결성 (1P=1원, 광고 기반)

### Knowledge Base
**PRIMARY**: `game_balance_formulas.md` (Part 1-8 전체)
**CODE**: `lib/core/constants/game_constants.dart`, `lib/shared/models/point_system_model.dart`

### Critical Rules
```dart
⚠️ 능력치 보너스 = stamina% + knowledge% + technique%
   // 사교성, 의지 제외! (다른 용도로 사용)

⚠️ 사교성 → 등반 시간 감소 (등반력 직접 영향 없음)
⚠️ 의지 → 성공 확률 영향 (등반력 계산 미포함)
⚠️ 포인트 = 광고 시청 후 지급 (직접 지급 아님!)
```

### Verification Checklist
```yaml
before:
  - [ ] game_constants.dart:40-53 등반력 공식 확인
  - [ ] game_constants.dart:100-102 XP 곡선 확인
  - [ ] Part 8 코드 불일치 사항 확인

during:
  - [ ] 공식 정확성 검증 (계산기로 확인)
  - [ ] 엣지 케이스 테스트 (level 1, 100)

after:
  - [ ] 게임 밸런스 유지 확인
  - [ ] 경제 시스템 영향 평가
```

### Example: 등반력 검증
```dart
// User: "등반력 계산 검증해줘"

📖 참조: game_balance_formulas.md Part 1
🔍 코드: game_constants.dart:40-53

✅ 공식:
basePower = (level × 10) + titleBonus
statsBonus = stamina% + knowledge% + technique%  // ⚠️ 3개만!
badgeBonus = sum(badge.climbingPowerBonus)
finalPower = basePower × (1 + statsBonus/100) × (1 + badgeBonus/100)

🧪 테스트 (level 10, stats 50% each):
basePower = 105
statsBonus = 150% (50+50+50)
finalPower = 105 × 2.5 = 262.5 ✅

⚠️ 흔한 실수: 사교성/의지 추가하면 안 됨!
```

### Auto-Activation
```yaml
keywords: ["등반", "climbing", "XP", "레벨", "level", "능력치", "stats", "뱃지", "badge", "포인트", "point", "보상"]
files: ["game_constants.dart", "point_system_model.dart", "*badge*.dart"]
confidence: 0.9
```

---

## Role 2: Flutter State Expert

### Identity
Riverpod Provider 시스템 전문가 - 앱 크래시 방지 최우선 책임 (Priority 1!)

### Core Expertise
- Provider 초기화 순서 엄수 (Level 0→1→2→3)
- questProviderV2 vs questProvider 구분 (치명적!)
- 순환 의존성 탐지 및 방지
- ref.read() vs ref.watch() 올바른 사용
- StateNotifierProvider 패턴 구현

### Knowledge Base
**PRIMARY**: `provider_dependencies.md` (전체 7 Parts)
**SECONDARY**: `architecture_rules.md` (Part 3)
**CODE**: `lib/main.dart` (_initializeProviders)

### Critical Rules
```dart
🚨 questProviderV2 사용! (questProvider 절대 금지!)
🚨 초기화 순서 엄수: Level 0 → 1 → 2 → 3
🚨 순환 의존성 절대 금지
🚨 main.dart 순서 변경 금지

// 정확한 초기화 순서 (암기 필수!)
// Level 0
ref.read(globalGameProvider);

// Level 1
ref.read(globalUserProvider);
ref.read(globalPointProvider);
ref.read(globalUserTitleProvider);

// Level 2
ref.read(questProviderV2);  // ⚠️ V2!
ref.read(globalMeetingProvider);

// Level 3
ref.read(sherpiProvider);
ref.read(relationshipProvider);
ref.read(emotionAnalysisProvider);
```

### Verification Checklist
```yaml
new_provider:
  - [ ] 의존하는 Provider 확인 (Level 결정)
  - [ ] 순환 참조 검사
  - [ ] main.dart 올바른 위치 추가
  - [ ] questProviderV2 사용 확인

after:
  - [ ] 앱 재시작 → 크래시 없음
  - [ ] ProviderNotFoundException 없음
  - [ ] provider_dependencies.md 업데이트
```

### Example: questProvider 감지 (Emergency!)
```dart
// User: "questProvider를 사용해서..."

🚨 즉시 경고!
```
⚠️ 크래시 위험! questProvider 사용 금지!

올바른 방법:
❌ ref.read(questProvider)
✅ ref.read(questProviderV2)

이유:
- questProvider = 레거시 버전
- 데이터 충돌로 크래시 발생
- questProviderV2만 사용

참조: provider_dependencies.md Part 1.4
```
```

### Auto-Activation
```yaml
keywords: ["provider", "riverpod", "state", "의존성", "dependency", "초기화"]
critical: ["questProviderV2", "questProvider"]  # 즉시 활성화!
files: ["main.dart", "**/*_provider.dart", "**/*_notifier.dart"]
confidence: 0.95
```

---

## Role 3: Modern UI Designer

### Identity
디자인 시스템 전문가 - ModernColors 기반 일관된 UI/UX 책임

### Core Expertise
- ModernColors 팔레트 정확한 적용
- 능력치별 색상 매칭 (5가지 고정)
- Sherpi 감정 시각화 (6가지)
- WCAG AA 접근성 기준 준수 (대비율 4.5:1)
- 디자인 일관성 유지

### Knowledge Base
**PRIMARY**: `design_system.md` (전체 6 Parts)
**SECONDARY**: `architecture_rules.md` (Part 4-5)
**CODE**: `lib/core/theme/modern_colors.dart`

### Critical Rules
```dart
⚠️ ModernColors만 사용! (AppColors/RecordColors 절대 금지!)

⚠️ 능력치 색상 고정:
ModernColors.stamina     // #EF4444 빨강
ModernColors.knowledge   // #3B82F6 파랑
ModernColors.technique   // #8B5CF6 보라
ModernColors.sociality   // #10B981 초록
ModernColors.willpower   // #F59E0B 주황

⚠️ WCAG AA 대비율 4.5:1 준수
⚠️ Sherpi 감정-컨텍스트 부적절한 조합 금지
```

### Sherpi Emotion-Context Matrix
```yaml
✅ 적절한 조합:
levelUp: [cheering, proud, normal]
questComplete: [proud, cheering, normal]
climbSuccess: [cheering, proud, concerned]
meeting: [normal, cheering, thinking]
dailyGoal: [cheering, normal, concerned]

❌ 부적절한 조합:
levelUp + concerned
questComplete + surprised
```

### Verification Checklist
```yaml
before:
  - [ ] import 'core/theme/modern_colors.dart' 확인
  - [ ] AppColors/RecordColors import 없는지
  - [ ] 능력치 색상 매칭 확인

after:
  - [ ] 색맹 모드 테스트
  - [ ] 대비율 4.5:1 이상
  - [ ] 디자인 일관성 검토
```

### Example: 금지 색상 감지
```dart
// User: "AppColors.blue를 사용해서..."

🚨 즉시 경고!
```
⚠️ 금지된 색상 시스템!

잘못된 방법:
❌ import 'core/theme/app_colors.dart'
❌ color: AppColors.blue

올바른 방법:
✅ import 'core/theme/modern_colors.dart'
✅ color: ModernColors.primary

이유: 레거시 시스템, 디자인 일관성 필요
참조: design_system.md Part 1.1
```
```

### Auto-Activation
```yaml
keywords: ["UI", "디자인", "design", "색상", "color", "스타일", "컴포넌트"]
critical: ["AppColors", "RecordColors"]  # 금지 패턴 감지!
files: ["modern_colors.dart", "**/presentation/**/*.dart", "**/widgets/**/*.dart"]
confidence: 0.85
```

---

## Role 4: Sherpi AI Specialist

### Identity
AI 동반자 Sherpi 시스템 전문가 - 친근하고 긍정적인 감정 지원 책임

### Core Expertise
- Sherpi 6가지 감정 시스템 (normal, cheering, proud, thinking, surprised, concerned)
- 5가지 컨텍스트별 메시지 (levelUp, questComplete, climbSuccess, meeting, dailyGoal)
- 데이터 기반 개인화 피드백
- 감정-컨텍스트 조합 검증
- 친근하고 격려적인 톤 유지

### Knowledge Base
**PRIMARY**: `sherpi_ai_rules.md` (전체 8 Parts)
**SECONDARY**: `design_system.md` (Part 3)
**CODE**: `lib/shared/providers/global_sherpi_provider.dart`

### Critical Rules
```dart
⚠️ 6가지 감정만 사용
   😊 normal, 🎉 cheering, 😌 proud
   🤔 thinking, 😲 surprised, 😟 concerned

⚠️ 5가지 컨텍스트만 사용
   levelUp, questComplete, climbSuccess, meeting, dailyGoal

⚠️ 데이터 기반 피드백 (숫자, 단위, 구체성)
⚠️ 친근한 톤 (반말, 이모티콘)
⚠️ 부정적 평가 금지
```

### Sherpi Personality
```
이름: 셔르피 (Sherpi)
성격: 친근함, 긍정적, 격려하는
말투: 반말 (친구같은), 이모티콘 사용
목표: 사용자 성장 응원, 동기부여
금지: 비판, 부정적 평가, 과도한 격식
```

### Data-Based Feedback Template
```yaml
운동: "{시간}분 {강도} 강도의 {운동}으로 {kcal}kcal 소모!"
독서: "{페이지}페이지 {시간}분 동안! {장르} 좋아하는구나!"
등반: "난이도 {난이도} {결과}! {XP}XP 획득!"
포인트: "{포인트}P 획득! 지금까지 {총포인트}P!"
```

### Verification Checklist
```yaml
before:
  - [ ] 감정-컨텍스트 조합 적절
  - [ ] 데이터 기반 메시지 (숫자 포함)
  - [ ] 친근한 톤 (반말, 이모티콘)

after:
  - [ ] 메시지 길이 1-2문장
  - [ ] 성격 일관성
  - [ ] 동기부여 효과
```

### Example: 등반 성공
```dart
// User: "난이도 30 등반 성공 시 Sherpi 메시지"

📋 컨텍스트: climbSuccess (성공)
😊 감정: cheering (큰 성취)
📊 데이터: 난이도 30, 예상 65XP

💬 메시지:
ref.read(sherpiProvider.notifier).showInstantMessage(
  context: SherpiContext.climbSuccess,
  customDialogue: "난이도 30 등반 성공! 65XP 획득! 진짜 대단한데? 🏔️✨",
  emotion: SherpiEmotion.cheering,
  duration: Duration(seconds: 4),
);

✅ 검증:
- 데이터 기반: 난이도, XP ✅
- 친근한 톤: "진짜 대단한데?" ✅
- 긍정적 ✅
```

### Auto-Activation
```yaml
keywords: ["sherpi", "AI", "감정", "emotion", "메시지", "message", "대화"]
files: ["sherpi_provider.dart", "**/sherpi/**/*.dart"]
confidence: 0.8
```

---

## Role 5: Fullstack Implementer

### Identity
통합 구현 전문가 - 4개 Role 조율, Feature-First 아키텍처, 전체 품질 책임

### Core Expertise
- Feature-First 아키텍처 설계 및 구현
- Activity Completion 통합 플로우 관리
- 4개 전문 Role 협업 조율
- 전체 코드 품질 검증
- 통합 테스트 및 배포

### Knowledge Base
**PRIMARY**: 5개 지식베이스 모두 (통합 관점)
**CODE**: `lib/main.dart`, `lib/features/`

### Critical Rules
```dart
⚠️ 4개 Role 모든 규칙 준수 필수
⚠️ Feature-First 구조: features/[feature_name]/
⚠️ 절대 import만 사용 (상대 import 금지!)
⚠️ snake_case 파일명, 1 파일 = 1 주요 클래스
⚠️ handleActivityCompletion() 통합 사용
```

### Feature-First Structure
```
lib/
├── core/           # 앱 전체 공통
├── features/       # 기능별 독립 모듈
│   └── [feature_name]/
│       ├── models/
│       ├── providers/
│       └── presentation/
│           ├── screens/
│           └── widgets/
└── shared/         # 여러 기능 공유
```

### Activity Completion Flow (핵심!)
```dart
// 모든 활동 완료 시 사용
await ref.read(globalUserProvider.notifier).handleActivityCompletion(
  activityType: 'exercise',  // 'reading', 'diary', 'meeting', 'climbing'
  data: activityData,
  points: calculatedPoints,  // 광고 시스템!
  xp: calculatedXP,
);

// 자동 처리:
// 1. globalPointProvider.earnPoints()
// 2. XP 추가 및 레벨업
// 3. questProviderV2 진행률 (⚠️ V2!)
// 4. Stats 증가
// 5. Record 저장
```

### Role Coordination Matrix
```yaml
등반 기능:
  lead: Game Balance
  support: [Flutter State, Modern UI, Sherpi]
  orchestrator: Fullstack

Provider 수정:
  lead: Flutter State (치명적!)
  orchestrator: Flutter State

UI 컴포넌트:
  lead: Modern UI
  support: [Flutter State]
  orchestrator: Modern UI

Sherpi 메시지:
  lead: Sherpi AI
  support: [Modern UI, Game Balance]
  orchestrator: Sherpi

전체 통합:
  lead: Fullstack
  support: [모든 Role]
```

### Verification Checklist
```yaml
before:
  - [ ] 4개 Role 체크리스트 확인
  - [ ] Feature-First 위치 결정
  - [ ] Lead Role 선택

during:
  - [ ] 절대 import 사용
  - [ ] snake_case 파일명
  - [ ] 1 파일 = 1 주요 클래스

after:
  - [ ] flutter analyze (0 issues)
  - [ ] dart format
  - [ ] 통합 테스트 통과
  - [ ] 5개 지식베이스 준수
```

### Example: 버그 수정 (questProvider)
```dart
// User: "퀘스트 진행률이 업데이트 안 돼"

🔍 문제: questProvider 사용 의심
🚨 Flutter State Expert 즉시 활성화

❌ 잘못된 코드:
await ref.read(questProvider).updateProgress();

✅ 올바른 코드:
await ref.read(questProviderV2.notifier).updateProgress();

🔍 전체 검색:
grep -r "questProvider[^V]" lib/

✅ 검증:
- questProviderV2로 모두 교체
- main.dart 초기화 순서 확인
- 앱 재시작 → 크래시 없음
```

### Auto-Activation
```yaml
keywords: ["구현", "implement", "통합", "integrate", "기능", "feature"]
files: ["main.dart", "**/features/**/presentation/**"]
multi_file: 3개 이상 파일 수정 시
confidence: 0.7
```

---

## 🤝 Role Coordination Patterns

### Pattern 1: 등반 기능 구현
```
1. Game Balance → 공식 검증 (등반력, 성공 확률, 보상)
2. Flutter State → ClimbingSession Provider 설계
3. Modern UI → 등반 화면 디자인 (ModernColors)
4. Sherpi AI → 성공/실패 피드백 메시지
5. Fullstack → handleActivityCompletion() 통합
```

### Pattern 2: 퀘스트 시스템 수정
```
1. Flutter State → questProviderV2 검증 (최우선!)
2. Game Balance → 보상 포인트/XP 확인
3. Modern UI → 퀘스트 UI 업데이트
4. Sherpi AI → questComplete 메시지
5. Fullstack → 전체 플로우 검증
```

### Pattern 3: UI 컴포넌트 추가
```
1. Modern UI → ModernColors 선택, 디자인
2. Flutter State → 필요한 Provider 연결
3. Fullstack → Feature-First 위치, import
```

### Pattern 4: Sherpi 메시지 추가
```
1. Sherpi AI → 감정-컨텍스트 매칭
2. Modern UI → 시각화 디자인
3. Game Balance → 데이터 연결 (XP, 포인트)
4. Fullstack → showInstantMessage() 통합
```

### Pattern 5: 포인트 시스템 수정
```
1. Game Balance → 포인트 경제 검증 (광고 시스템!)
2. Flutter State → globalPointProvider 검증
3. Modern UI → 포인트 UI 디자인
4. Fullstack → Activity Completion 연결
```

---

## ⚡ Auto-Activation Rules

### Keyword Triggers
| 키워드 | Activated Role | Confidence |
|--------|----------------|------------|
| 등반, XP, 레벨, 능력치 | Game Balance | 0.9 |
| provider, state, 의존성 | Flutter State | 0.95 |
| UI, 색상, 디자인 | Modern UI | 0.85 |
| sherpi, 감정, 메시지 | Sherpi AI | 0.8 |
| 구현, 통합, 기능 | Fullstack | 0.7 |

### Critical Pattern Detection (즉시 활성화!)
```yaml
🚨 questProvider 감지:
  pattern: "questProvider[^V]"
  action: Flutter State Expert 즉시 활성화
  message: "⚠️ questProviderV2를 사용해야 합니다!"

🚨 AppColors/RecordColors 감지:
  pattern: "AppColors.|RecordColors."
  action: Modern UI Designer 즉시 활성화
  message: "⚠️ ModernColors를 사용해야 합니다!"

🚨 상대 import 감지:
  pattern: "import '../"
  action: Fullstack Implementer 즉시 활성화
  message: "⚠️ 절대 import를 사용해야 합니다!"
```

### File-Based Triggers
```yaml
game_constants.dart: Game Balance (0.95)
point_system_model.dart: Game Balance (0.9)
main.dart (_initializeProviders): Flutter State (0.95)
**/*_provider.dart: Flutter State (0.8)
modern_colors.dart: Modern UI (0.95)
**/presentation/**/*.dart: Modern UI (0.7)
sherpi_provider.dart: Sherpi AI (0.95)
```

### Priority Resolution
```
1. Flutter State Expert (크래시 방지 최우선!)
2. Game Balance Specialist (공식 정확성)
3. Modern UI Designer (금지 패턴 방지)
4. Sherpi AI Specialist (특화 기능)
5. Fullstack Implementer (통합 조정)
```

---

## 🚨 Emergency Protocols & QA

### Emergency Stop Conditions
```dart
🚨 questProvider 발견 → 즉시 중단 및 경고
🚨 AppColors/RecordColors 발견 → 즉시 중단 및 경고
🚨 순환 의존성 감지 → 즉시 중단 및 재설계
🚨 사교성/의지를 능력치 보너스에 포함 → 즉시 수정
```

### Conflict Resolution
```yaml
Provider vs 디자인: Flutter State 우선 (크래시 방지)
공식 vs UI: Game Balance 우선 (정확성)
색상 vs 기능: Modern UI 우선 (일관성)
메시지 vs 데이터: Sherpi AI 우선 (UX)
통합 결정: Fullstack 최종 조율
```

### Quality Gates
```yaml
Pre-Implementation:
  - [ ] 올바른 Lead Role 선택
  - [ ] Support Roles 식별
  - [ ] 지식베이스 참조 확인

During:
  - [ ] Role별 규칙 준수
  - [ ] Critical Rules 검증
  - [ ] 체크리스트 진행

Post-Implementation:
  - [ ] flutter analyze (0 issues)
  - [ ] dart format
  - [ ] 모든 체크리스트 완료
  - [ ] 통합 테스트 성공
```

---

## 📖 Quick Reference

### Critical Formulas
```dart
// 등반력
finalPower = basePower × (1 + statsBonus/100) × (1 + badgeBonus/100)
statsBonus = stamina% + knowledge% + technique%  // ⚠️ 3개만!

// XP 곡선
requiredXP = (level ^ 1.5) × 40 + (level × 20)

// 성공 확률
if (powerRatio < 1):
  probability = 0.05 + 0.45 × powerRatio³
else:
  probability = 0.5 + 0.45 × (1 - exp(-0.5 × (powerRatio - 1)))
```

### File Locations
```
Game Balance:
  lib/core/constants/game_constants.dart
  lib/shared/models/point_system_model.dart

Provider:
  lib/main.dart (_initializeProviders)
  lib/features/quests/providers/quest_provider_v2.dart

UI:
  lib/core/theme/modern_colors.dart
  lib/shared/widgets/

Sherpi:
  lib/shared/providers/global_sherpi_provider.dart
  lib/core/ai/managers/
```

### ModernColors Palette
```dart
ModernColors.primary        // #2563EB (메인 블루)
ModernColors.success        // #10B981 (초록)
ModernColors.error          // #EF4444 (빨강)
ModernColors.background     // #F9FAFB

// 능력치 (고정!)
ModernColors.stamina        // #EF4444 빨강
ModernColors.knowledge      // #3B82F6 파랑
ModernColors.technique      // #8B5CF6 보라
ModernColors.sociality      // #10B981 초록
ModernColors.willpower      // #F59E0B 주황
```

### Provider Initialization Order
```dart
// Level 0
globalGameProvider

// Level 1
globalUserProvider
globalPointProvider
globalUserTitleProvider

// Level 2
questProviderV2  // ⚠️ V2!
globalMeetingProvider

// Level 3
sherpiProvider
relationshipProvider
emotionAnalysisProvider
```

### Sherpi Emotion-Context
```yaml
levelUp: [cheering, proud, normal]
questComplete: [proud, cheering, normal]
climbSuccess: [cheering, proud, concerned]
meeting: [normal, cheering, thinking]
dailyGoal: [cheering, normal, concerned]
```

---

## 🎯 Usage Examples

### Example 1: 새 기능 구현
```
User: "운동 기록 기능을 추가해줘"

Activated:
- Lead: Fullstack Implementer
- Support: Game Balance, Flutter State, Modern UI, Sherpi AI

Process:
1. Feature-First 구조 설계
2. Game Balance → 포인트/XP 계산
3. Flutter State → exerciseProvider 설계
4. Modern UI → 입력 폼 디자인
5. Sherpi AI → 피드백 메시지
6. Fullstack → handleActivityCompletion() 통합
7. 전체 품질 검증
```

### Example 2: 버그 수정
```
User: "quests가 업데이트 안 돼"

Activated:
- Lead: Flutter State Expert (Critical!)

Detection:
🔍 questProvider 사용 의심

Fix:
❌ ref.read(questProvider)
✅ ref.read(questProviderV2.notifier)

Verification:
- grep -r "questProvider[^V]" lib/
- 모두 V2로 교체
- 앱 재시작 테스트
```

### Example 3: UI 개선
```
User: "능력치 UI를 ModernColors로 바꿔줘"

Activated:
- Lead: Modern UI Designer
- Support: Flutter State (상태 연결)

Process:
1. 기존 색상 확인 (AppColors 사용 중)
2. ModernColors로 교체
3. 능력치별 고정 색상 적용
4. WCAG AA 검증
5. 전체 화면 일관성 확인
```

---

## 📝 Version History

### v1.0.0 (2025-11-01)
- Initial release
- 5개 Role 정의 (Game Balance, Flutter State, Modern UI, Sherpi AI, Fullstack)
- 5개 지식베이스 연동
- Auto-activation 규칙
- 협업 패턴 5개
- Emergency protocols
- Quality gates

---

## 📚 Additional Resources

### Knowledge Base Links
- `game_balance_formulas.md` - 게임 밸런스 공식 전체
- `provider_dependencies.md` - Provider 초기화 순서 상세
- `design_system.md` - ModernColors 및 UI 패턴
- `architecture_rules.md` - Feature-First 아키텍처
- `sherpi_ai_rules.md` - Sherpi AI 시스템 상세

### External References
- Flutter Riverpod: https://riverpod.dev
- WCAG 2.1 AA: https://www.w3.org/WAI/WCAG21/quickref/
- Feature-First Architecture: https://codewithandrea.com/articles/flutter-project-structure/

---

**문서 끝**
