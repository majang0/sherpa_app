# Sherpa App Multi-Agent 시스템 발전 방향

**작성일**: 2025-10-30
**버전**: 2.0.0
**목적**: SKILL 기반 시스템과 Agent 기반 시스템의 최적 하이브리드 구성

---

## 📋 Executive Summary

현재 6개 SKILL 시스템을 분석한 결과, **전면 Agent 전환이 아닌, 선택적 하이브리드 접근**이 최적입니다.

**핵심 전략**:
- ✅ **Agent 전환 (4개)**: 규칙 기반, 자동화 가능, 독립 실행 가능 → **병렬 처리로 2-3배 속도 향상**
- ✅ **SKILL 유지 (2개)**: 복잡한 판단, 순차 조율 필요, 신중한 실행 필요 → **품질과 안정성 보장**

**예상 효과**:
- ⚡ **성능**: 40-60% 빠른 검증 (4개 Agent 병렬 실행)
- 🎯 **품질**: 100% 유지 (핵심 Role은 SKILL 유지)
- 🔄 **유연성**: Agent 확장 가능, SKILL은 안정성 보장

---

## 1. 현재 SKILL 시스템 심층 분석

### 1.1 Role별 기능 매트릭스

| Role | 주요 기능 | 도구 권한 | 실행 특성 | Agent 적합성 |
|------|----------|----------|----------|-------------|
| **Role 1: Architect Orchestrator** | 작업 분해, 의존성 관리, 오케스트레이션 | Read, Grep, Glob, TodoWrite, Task | 순차 필수, 복잡한 판단 | ❌ 낮음 (20%) |
| **Role 2: Game Logic Specialist** | 등반력/XP/포인트 검증, Python 시뮬레이션 | Read, Bash, Glob | 독립 실행, 규칙 기반 | ✅ 높음 (85%) |
| **Role 3: UI/UX Guardian** | ModernColors 강제, Sherpi 검증, UI 일관성 | Read, Grep, Glob | 독립 실행, 패턴 매칭 | ✅ 높음 (90%) |
| **Role 4: State Management Expert** | Provider 순서, questProviderV2, 순환 의존성 | Read, Grep, Glob | 독립 실행, 명확한 규칙 | ✅✅ 매우 높음 (95%) |
| **Role 5: Fullstack Implementer** | 코드 작성/수정 (유일한 Write 권한) | Read, Write, Edit, MultiEdit, Bash | 순차 필수, 신중한 실행 | ❌ 낮음 (15%) |
| **Role 6: QA Documentation** | flutter analyze, 테스트 시나리오, CHANGELOG | Read, Bash, Write, Edit | 부분 자동화 가능 | ⚠️ 부분적 (60%) |

### 1.2 각 Role 상세 분석

#### Role 1: Architect Orchestrator (SKILL 유지 추천 ✅)

**핵심 기능**:
```yaml
작업_분해:
  - 복잡한 작업 → Phase → Task → Todo 계층 분해
  - 3단계 이상 깊이의 계획 수립
  - 예상 소요 시간 및 리스크 평가

의존성_관리:
  - Provider 초기화 순서 검증 (Level 0→1→2→3)
  - Feature 간 의존성 분석
  - 순환 의존성 탐지

Role_오케스트레이션:
  - Task tool로 다른 Role 호출
  - 병렬/순차 실행 전략 결정
  - 검증 결과 종합 및 판단

진행_상황_추적:
  - TodoWrite로 실시간 진행률 관리
  - Phase별 검증 포인트 설정
  - 리스크 대응 및 계획 수정
```

**Agent 전환이 부적합한 이유**:
1. **복잡한 판단 필요**: "어떤 Role을 언제 호출할까?"는 컨텍스트 기반 의사결정
2. **순차 조율 필수**: Role 6 → Role 4 → Role 3 → Role 5 순서를 동적으로 결정
3. **컨텍스트 공유 중요**: 이전 검증 결과를 바탕으로 다음 단계 계획
4. **메타 레벨 작업**: 다른 Role들을 관리하는 오케스트레이터 역할

**SKILL 유지 시 장점**:
- ✅ 복잡한 작업 분해를 유연하게 처리
- ✅ 동적인 Role 조율 가능
- ✅ 전체 컨텍스트를 바탕으로 최적 결정
- ✅ 예상치 못한 상황에 대응 가능

**Agent 전환 시 단점**:
- ❌ Agent는 독립 컨텍스트 → 전체 상황 파악 어려움
- ❌ 동적 조율이 어려움 (미리 정의된 패턴만 가능)
- ❌ 복잡한 판단을 자동화하기 어려움

---

#### Role 2: Game Logic Specialist (Agent 전환 추천 ✅)

**핵심 기능**:
```yaml
등반력_계산_검증:
  규칙: "basePower × (1 + statsBonus/100) × (1 + badgeBonus/100)"
  검증: statsBonus = stamina + knowledge + technique (3개만!)
  자동화: 공식 일치 여부 → 명확한 참/거짓

XP_곡선_검증:
  규칙: "(level ^ 1.5) × 40 + (level × 20)"
  검증: 주요 레벨 구간 계산 확인
  자동화: 공식 일치 여부 → 명확한 참/거짓

포인트_경제_검증:
  규칙: "일일 잉여 0~500, 30일 0~15,000"
  검증: Python 시뮬레이션 실행
  자동화: balance_simulator.py 실행 → 결과 분석

Python_시뮬레이션:
  3가지_모드:
    - climbing: 등반력 계산 & 성공 확률
    - levelup: XP 진행도 시뮬레이션
    - points: 포인트 경제 분석
  자동화: Bash tool로 스크립트 실행
```

**Agent 전환이 적합한 이유**:
1. **명확한 규칙 기반**: 등반력 공식, XP 곡선 공식 → 수식 일치 여부만 확인
2. **완전 자동화 가능**: Python 스크립트 실행 → 결과 파싱 → 리포트 생성
3. **독립적 실행**: 다른 Role과 의존성 없음 (게임 로직만 검증)
4. **병렬 실행 가능**: UI 검증, Provider 검증과 동시에 실행 가능

**Agent 설정 예시**:
```markdown
---
name: game-balance-validator
description: Use proactively when game balance changes are detected (climbing power, XP curve, points economy)
tools: Read, Bash, Grep, Glob
model: sonnet
---

You are the Game Balance Validator for Sherpa App.

## Critical Rules

### 1. Climbing Power Formula
```
climbingPower = basePower × (1 + statsBonus/100) × (1 + badgeBonus/100)

⚠️ CRITICAL: statsBonus = stamina + knowledge + technique (3 ONLY!)
❌ NEVER include sociality or willpower in climbing power!
```

### 2. Verification Steps
1. Search for `calculateFinalClimbingPower` or `calculateClimbingPower`
2. Extract statsBonus calculation
3. Verify ONLY 3 stats: stamina, knowledge, technique
4. If sociality/willpower found → IMMEDIATE WARNING

### 3. Python Simulation
```bash
python .claude/skills/role2-game-logic-specialist/scripts/balance_simulator.py \
  --mode climbing --level 15 --stamina 15 --knowledge 10 --technique 5
```

## Auto-Activation Triggers
- File changes in: `lib/shared/providers/global_game_provider.dart`
- Keywords: climbing, power, XP, level, point, balance
- Function changes: `calculateFinalClimbingPower`, `getRequiredXpForLevel`

## Output Format
```markdown
## ⚖️ Game Balance Validation

### Climbing Power
- ✅ Formula correct: basePower × (1 + statsBonus/100) × (1 + badgeBonus/100)
- ✅ Stats bonus: stamina + knowledge + technique (3 only)
- ✅ Sociality/Willpower excluded

### XP Curve
- ✅ Formula correct: (level ^ 1.5) × 40 + (level × 20)

### Points Economy
- ✅ Daily surplus: +120 points (within 0-500 target)

---
**Validator**: game-balance-validator
**Status**: ✅ APPROVED
```
```

**병렬 실행 시나리오**:
```
사용자: "Meeting 참여 기능 추가 (100 포인트 획득)"

Main Claude: 작업 분해
  ↓
병렬 실행 (동시에 3개 Agent):
  ├─ game-balance-validator (15초)
  │  ✓ 포인트 경제 시뮬레이션
  │  ✓ 일일 밸런스 영향 분석
  │
  ├─ ui-design-validator (10초)
  │  ✓ ModernColors 사용 확인
  │
  └─ state-management-guard (12초)
     ✓ Provider 의존성 확인

가장 긴 작업: 15초
순차 실행 시: 15 + 10 + 12 = 37초

성능 향상: 59% (37초 → 15초)
```

---

#### Role 3: UI/UX Guardian (Agent 전환 추천 ✅)

**핵심 기능**:
```yaml
ModernColors_강제:
  검증_대상:
    - AppColors 사용 검색 (절대 금지)
    - RecordColors 사용 검색 (절대 금지)
    - 하드코딩 색상 검색 (Color(0x 패턴)
  자동화: grep 패턴 매칭 → 발견 즉시 경고

Sherpi_감정_컨텍스트_검증:
  매트릭스:
    levelUp: [cheering, proud] ✅ / [concerned] ❌
    questComplete: [cheering, proud] ✅ / [concerned] ❌
    climbSuccess: [cheering, proud] ✅ / [surprised] ❌
  자동화: showInstantMessage 호출 추출 → 매트릭스 비교

접근성_검증:
  규칙:
    - 색상 대비 4.5:1 이상
    - Semantics 위젯 사용
    - 터치 영역 최소 48x48
  자동화: 패턴 검색 → 규칙 확인
```

**Agent 전환이 적합한 이유**:
1. **명확한 패턴 매칭**: AppColors 사용 여부 → grep으로 즉시 확인
2. **규칙 기반 검증**: 감정-컨텍스트 매트릭스 → 테이블 비교만
3. **독립적 실행**: UI 검증은 다른 Role과 무관
4. **빠른 실행**: grep 패턴 매칭으로 수 초 내 완료

**Agent 설정 예시**:
```markdown
---
name: ui-design-validator
description: Use proactively when UI code changes are detected (ModernColors, Sherpi, design system)
tools: Read, Grep, Glob
model: sonnet
---

You are the UI/UX Guardian for Sherpa App.

## Critical Rules

### 1. ModernColors ONLY (Legacy Colors FORBIDDEN)
```bash
# Search for legacy colors (MUST be 0 results!)
grep -r "AppColors" lib/ --include="*.dart"
grep -r "RecordColors" lib/ --include="*.dart"
grep -r "Color(0x" lib/ --include="*.dart"

# If found → IMMEDIATE WARNING
```

### 2. Sherpi Emotion-Context Matrix
| Context | ✅ Appropriate | ❌ Inappropriate |
|---------|---------------|-----------------|
| levelUp | cheering, proud | concerned, surprised |
| questComplete | cheering, proud, normal | concerned |
| climbSuccess | cheering, proud | concerned, surprised |

### 3. Auto-Activation Triggers
- File changes in: `lib/features/**/presentation/**/*.dart`
- Keywords: color, theme, UI, Sherpi, emotion, context
- Pattern: `AppColors`, `RecordColors`, `showInstantMessage`

## Verification Process
1. Search for legacy colors
2. Extract Sherpi message calls
3. Verify emotion-context combinations
4. Report findings

## Output Format
```markdown
## 🎨 UI Design Validation

### Color System
- ✅ ModernColors usage: 24 files
- ❌ Legacy colors found: 2 instances

#### Legacy Color Issues
1. `lib/features/meeting/screens/meeting_tab.dart:45`
   - Current: `AppColors.primaryBlue`
   - Fix: `ModernColors.primary`

### Sherpi AI
- ✅ Appropriate combinations: 12 instances
- ❌ Inappropriate found: 1 instance

#### Sherpi Issues
1. `lib/features/quest/providers/quest_provider_v2.dart:234`
   - Current: `context: questComplete, emotion: concerned`
   - Fix: `emotion: proud` or `cheering`

---
**Validator**: ui-design-validator
**Status**: ⚠️ FIXES REQUIRED
```
```

---

#### Role 4: State Management Expert (Agent 전환 최우선 ✅✅)

**핵심 기능**:
```yaml
Provider_초기화_순서_검증:
  규칙: "Level 0 → 1 → 2 → 3 (절대 순서!)"
  치명도: CRITICAL (순서 틀리면 앱 크래시!)
  자동화: main.dart 읽기 → 순서 확인 → 통과/실패

questProviderV2_강제:
  규칙: "questProvider 절대 금지! questProviderV2만 사용"
  치명도: CRITICAL (questProvider 사용 시 앱 크래시!)
  자동화: grep "questProvider[^V]" → 발견 시 즉시 경고

순환_의존성_차단:
  규칙: "Provider A → B, B → A 패턴 금지"
  자동화: 의존성 그래프 생성 → DFS로 순환 탐지

새_Provider_의존성_분석:
  자동화: ref.read/watch 호출 추출 → Level 계산
```

**Agent 전환이 최우선인 이유**:
1. **치명적 에러 방지**: Provider 순서 오류, questProvider 사용 → 앱 크래시!
2. **명확한 규칙**: Level 0→1→2→3, questProviderV2만 사용 → 명확한 참/거짓
3. **완전 자동화 가능**: grep + 패턴 매칭 → 수 초 내 검증 완료
4. **독립적 실행**: Provider 검증은 다른 검증과 독립적
5. **가장 중요한 검증**: 다른 검증보다 우선순위 높음

**Agent 설정 예시**:
```markdown
---
name: state-management-guard
description: Use proactively when Provider initialization order or questProvider usage needs verification
tools: Read, Grep, Glob
model: sonnet
---

You are the State Management Guard for Sherpa App.

## CRITICAL RULES (App Crash Prevention!)

### 1. Provider Initialization Order: Level 0 → 1 → 2 → 3
```dart
// lib/main.dart - _initializeProviders()

// ✅ CORRECT ORDER (NEVER CHANGE!)
ref.read(globalGameProvider);        // Level 0
ref.read(globalUserProvider);        // Level 1
ref.read(globalPointProvider);       // Level 1
ref.read(globalUserTitleProvider);   // Level 1
ref.read(questProviderV2);           // Level 2
ref.read(globalMeetingProvider);     // Level 2
ref.read(sherpiProvider);            // Level 3

// ❌ WRONG ORDER (APP CRASH!)
ref.read(questProviderV2);           // Level 2 first
ref.read(globalUserProvider);        // Level 1 later → CRASH!
```

### 2. questProviderV2 ONLY (questProvider FORBIDDEN!)
```bash
# Search for questProvider (MUST be 0 results!)
grep -r "questProvider[^V]" lib/ --include="*.dart"
grep -r "import.*quest_provider.dart" lib/ --include="*.dart"

# If found → 🚨 CRITICAL ERROR!
```

### 3. Circular Dependency Detection
- Build dependency graph
- Run DFS to detect cycles
- Report any circular paths

## Auto-Activation Triggers
- File changes in: `lib/shared/providers/*.dart`
- File changes in: `lib/main.dart` (initializeProviders)
- Keywords: provider, state, riverpod, initialization
- New Provider creation detected

## Verification Steps
1. Read `lib/main.dart` → Extract initialization order
2. Verify Level 0 → 1 → 2 → 3 sequence
3. Search for `questProvider` usage (MUST be 0!)
4. Check circular dependencies
5. Report findings with severity

## Output Format
```markdown
## 🔧 State Management Validation

### Provider Initialization Order
- ✅ Level 0: globalGameProvider
- ✅ Level 1: globalUserProvider, globalPointProvider, globalUserTitleProvider
- ✅ Level 2: questProviderV2, globalMeetingProvider
- ✅ Level 3: sherpiProvider, relationshipProvider, emotionAnalysisProvider

### questProvider Check (CRITICAL!)
- ✅ questProvider usage: 0 instances
- ✅ questProviderV2 usage: 18 instances

### Circular Dependencies
- ✅ No circular paths detected

---
**Validator**: state-management-guard
**Status**: ✅ APPROVED
```
```

**왜 최우선 Agent인가?**:
```yaml
치명도:
  - Provider 순서 오류: 앱 크래시 (100% 치명적)
  - questProvider 사용: 데이터 충돌, 앱 크래시
  - 순환 의존성: 무한 루프, 메모리 누수

자동화_용이성:
  - grep으로 즉시 확인 가능
  - 명확한 규칙 (Level 0→1→2→3)
  - 패턴 매칭만으로 검증 가능

독립성:
  - Provider 검증은 UI, 게임 로직과 무관
  - 다른 Agent와 병렬 실행 가능

빈도:
  - 새 Provider 추가 시마다 필요
  - 가장 자주 실행되는 검증
```

---

#### Role 5: Fullstack Implementer (SKILL 유지 추천 ✅)

**핵심 기능**:
```yaml
코드_작성:
  - 새로운 기능 구현 (Feature-First 구조)
  - Domain → Provider → Presentation 순서
  - 2025년 Flutter/Dart/Riverpod 최신 패턴

코드_수정:
  - 버그 수정, 리팩토링, 최적화
  - MultiEdit로 여러 파일 동시 수정
  - 지식베이스 규칙 100% 준수

유일한_Write_Edit_권한:
  - 다른 Role은 Read-only
  - Role 5만 코드 수정 가능
  - 모든 검증 통과 후에만 실행
```

**Agent 전환이 부적합한 이유**:
1. **복잡한 판단 필요**: "어떻게 구현할까?"는 창의적 의사결정
2. **순차 실행 필수**: 검증 → 구현 → 재검증 순서 절대 준수
3. **신중한 실행 필요**: Write 권한으로 잘못 쓰면 코드 망가짐
4. **컨텍스트 중요**: 전체 코드베이스 이해 필요
5. **창의적 작업**: 단순 규칙이 아닌 설계 및 구현

**SKILL 유지 시 장점**:
- ✅ 유연한 구현 결정 (여러 대안 중 최적 선택)
- ✅ 전체 컨텍스트 기반 코드 작성
- ✅ 예상치 못한 상황 대응 가능
- ✅ 창의적 문제 해결

**Agent 전환 시 단점**:
- ❌ Agent는 미리 정의된 패턴만 가능 → 창의성 제한
- ❌ 복잡한 구현 결정을 자동화하기 어려움
- ❌ Write 권한을 Agent에게 주는 것은 리스크 큼

---

#### Role 6: QA Documentation (부분 Agent 전환 추천 ⚠️)

**핵심 기능**:
```yaml
flutter_analyze:
  자동화: ✅ 가능 (Bash tool로 실행 → 결과 파싱)
  독립성: ✅ 높음 (다른 검증과 무관)
  Agent_적합: ✅ 매우 높음

테스트_시나리오_작성:
  자동화: ❌ 어려움 (Given-When-Then 작성은 판단 필요)
  독립성: ⚠️ 중간 (기능 이해 필요)
  Agent_적합: ❌ 낮음

CHANGELOG_업데이트:
  자동화: ❌ 어려움 (변경 사항 분류 및 설명 필요)
  독립성: ⚠️ 중간
  Agent_적합: ❌ 낮음

API_문서_작성:
  자동화: ❌ 어려움 (Dart doc comment 작성은 판단 필요)
  독립성: ⚠️ 중간
  Agent_적합: ❌ 낮음
```

**부분 Agent 전환 전략**:
```yaml
Agent로_전환: "qa-code-analyzer"
  - flutter analyze 실행
  - dart format 실행
  - 테스트 실행 (flutter test)
  - 결과 리포트 자동 생성

SKILL로_유지: "qa-documentation"
  - 테스트 시나리오 작성 (Given-When-Then)
  - CHANGELOG 업데이트 (Keep a Changelog)
  - API 문서 작성 (Dart doc comment)
```

**Agent 설정 예시** (flutter analyze 부분):
```markdown
---
name: qa-code-analyzer
description: Use proactively when code changes are detected (run flutter analyze, tests)
tools: Read, Bash, Grep
model: haiku  # 빠른 모델 사용 (단순 작업)
---

You are the Code Quality Analyzer for Sherpa App.

## Responsibilities

### 1. Flutter Analyze
```bash
flutter analyze
```
- MUST be: 0 errors, 0 warnings
- If errors/warnings found → Report to main Claude

### 2. Dart Format Check
```bash
dart format lib/ --output none --set-exit-if-changed
```
- Check if code is properly formatted

### 3. Test Execution (Optional)
```bash
flutter test
```
- Run unit tests if requested

## Auto-Activation Triggers
- Any `.dart` file changes in `lib/`
- Explicit request: "flutter analyze", "코드 품질 확인"

## Output Format
```markdown
## 📊 Code Quality Report

### Flutter Analyze
- ✅ Errors: 0
- ✅ Warnings: 0
- 📅 Executed: 2025-10-30 15:30

### Dart Format
- ✅ All files properly formatted

### Tests
- ✅ All tests passed (24/24)

---
**Analyzer**: qa-code-analyzer
**Status**: ✅ APPROVED
```
```

---

## 2. Agent 전환 우선순위 및 구현 계획

### 2.1 전환 우선순위 (1단계 → 4단계)

```yaml
Phase_1_최우선:
  - Role 4 (State Management Expert) → state-management-guard
  이유:
    - 치명적 에러 방지 (앱 크래시)
    - 자동화 용이성 95%
    - 독립적 실행 가능
    - 가장 자주 사용됨
  예상_효과: "Provider 관련 에러 100% 사전 차단"

Phase_2_고우선:
  - Role 6 (QA) flutter analyze 부분 → qa-code-analyzer
  이유:
    - flutter analyze는 완전 자동화 가능
    - 모든 구현 후 필수 실행
    - 병렬 실행으로 시간 절약
  예상_효과: "품질 검증 자동화, 0 errors 보장"

Phase_3_중우선:
  - Role 3 (UI/UX Guardian) → ui-design-validator
  이유:
    - ModernColors 검증은 패턴 매칭
    - UI 변경 시마다 필요
    - 독립적 실행 가능
  예상_효과: "레거시 색상 사용 100% 차단"

Phase_4_일반:
  - Role 2 (Game Logic Specialist) → game-balance-validator
  이유:
    - 게임 밸런스 변경 시만 필요 (빈도 낮음)
    - Python 시뮬레이션 자동화
    - 독립적 실행 가능
  예상_효과: "게임 밸런스 검증 자동화"
```

### 2.2 단계별 구현 계획

#### Phase 1: state-management-guard Agent 구현 (Week 1-2)

**목표**: Provider 관련 에러 100% 사전 차단

**구현 단계**:
```yaml
Step_1: Agent 파일 생성 (Day 1)
  - 파일: .claude/agents/state-management-guard.md
  - 내용: Provider 초기화 순서, questProviderV2 강제, 순환 의존성

Step_2: 기능 테스트 (Day 2-3)
  - 테스트 케이스 10개 준비
  - SKILL Role 4와 병행 실행
  - 정확도 비교 (목표: 100% 일치)

Step_3: 성능 측정 (Day 4-5)
  - 검증 시간 측정
  - SKILL: ~30초 vs Agent: ~10초 예상
  - 병렬 실행 가능 여부 확인

Step_4: 평가 및 결정 (Day 6-7)
  - 정확도 ≥ 100% → Agent 활성화
  - 성능 개선 ≥ 50% → Agent 우선 사용
  - SKILL Role 4는 fallback으로 유지
```

**테스트 케이스**:
```yaml
TC1: Provider 초기화 순서 정상
  - 입력: Level 0→1→2→3 올바른 순서
  - 기대: ✅ APPROVED

TC2: Provider 초기화 순서 오류
  - 입력: Level 2 먼저, Level 1 나중
  - 기대: 🚨 CRITICAL ERROR

TC3: questProvider 사용
  - 입력: ref.read(questProvider)
  - 기대: 🚨 CRITICAL ERROR (questProviderV2 사용 필수)

TC4: 새 Provider 추가 (Level 2 적합)
  - 입력: shopProvider (globalUserProvider 의존)
  - 기대: ✅ Level 2 추천

TC5: 순환 의존성 발견
  - 입력: ProviderA → ProviderB → ProviderA
  - 기대: 🚨 CIRCULAR DEPENDENCY

... (총 10개 테스트 케이스)
```

**성공 기준**:
```yaml
정확도: 10/10 (100%)
성능: SKILL 대비 50% 이상 빠름
안정성: 2주간 오탐/미탐 없음
사용성: 자동 활성화 정상 작동
```

---

#### Phase 2: qa-code-analyzer Agent 구현 (Week 3-4)

**목표**: flutter analyze 자동화, 0 errors 보장

**구현 단계**:
```yaml
Step_1: Agent 파일 생성 (Day 1)
  - 파일: .claude/agents/qa-code-analyzer.md
  - 내용: flutter analyze, dart format, flutter test

Step_2: 기능 테스트 (Day 2-3)
  - flutter analyze 실행 자동화
  - 결과 파싱 및 리포트 생성
  - SKILL Role 6과 비교

Step_3: 병렬 실행 테스트 (Day 4-5)
  - state-management-guard + qa-code-analyzer 동시 실행
  - 성능 측정 (병렬 vs 순차)

Step_4: 평가 및 통합 (Day 6-7)
  - SKILL Role 6은 문서 작성만 담당
  - Agent는 코드 품질 검증 담당
  - 하이브리드 운영 확립
```

---

#### Phase 3: ui-design-validator Agent 구현 (Week 5-6)

**목표**: 레거시 색상 사용 100% 차단, Sherpi 검증 자동화

**구현 단계**:
```yaml
Step_1: Agent 파일 생성 (Day 1)
  - 파일: .claude/agents/ui-design-validator.md
  - 내용: ModernColors 강제, Sherpi 감정-컨텍스트 검증

Step_2: 기능 테스트 (Day 2-3)
  - AppColors/RecordColors 검색 자동화
  - Sherpi 감정-컨텍스트 매트릭스 검증

Step_3: 병렬 실행 테스트 (Day 4-5)
  - 3개 Agent 동시 실행 (state, qa, ui)
  - 성능 측정

Step_4: 평가 및 통합 (Day 6-7)
  - Agent 활성화
  - SKILL Role 3는 제거 (Agent로 완전 대체)
```

---

#### Phase 4: game-balance-validator Agent 구현 (Week 7-8)

**목표**: 게임 밸런스 검증 자동화, Python 시뮬레이션 통합

**구현 단계**:
```yaml
Step_1: Agent 파일 생성 (Day 1)
  - 파일: .claude/agents/game-balance-validator.md
  - 내용: 등반력/XP/포인트 검증, Python 시뮬레이션

Step_2: Python 연동 테스트 (Day 2-3)
  - balance_simulator.py 자동 실행
  - 결과 파싱 및 분석

Step_3: 병렬 실행 테스트 (Day 4-5)
  - 4개 Agent 동시 실행
  - 전체 성능 측정

Step_4: 최종 평가 (Day 6-7)
  - Agent 활성화
  - SKILL Role 2는 제거 (Agent로 완전 대체)
```

---

### 2.3 최종 하이브리드 시스템 구성

**8주 후 최종 구성**:

```yaml
Agent_시스템_4개:
  state-management-guard:
    - Provider 초기화 순서 검증
    - questProviderV2 강제
    - 순환 의존성 차단
    - 자동 활성화: Provider 파일 변경 시

  qa-code-analyzer:
    - flutter analyze 실행
    - dart format 검증
    - flutter test 실행
    - 자동 활성화: 모든 .dart 파일 변경 시

  ui-design-validator:
    - ModernColors 강제, 레거시 색상 차단
    - Sherpi 감정-컨텍스트 검증
    - UI 일관성 유지
    - 자동 활성화: presentation/ 파일 변경 시

  game-balance-validator:
    - 등반력/XP/포인트 검증
    - Python 시뮬레이션 자동 실행
    - 자동 활성화: 게임 로직 파일 변경 시

SKILL_시스템_2개:
  Role_1_Architect_Orchestrator:
    - 작업 분해 (Phase/Task/Todo)
    - 의존성 관리
    - Agent 조율 (Task tool)
    - 진행 상황 추적

  Role_5_Fullstack_Implementer:
    - 코드 작성/수정 (유일한 Write 권한)
    - 모든 검증 통과 후 실행
    - 2025년 최신 패턴 준수

SKILL_제거_4개:
  - Role 2 (Game Logic Specialist) → game-balance-validator Agent로 완전 대체
  - Role 3 (UI/UX Guardian) → ui-design-validator Agent로 완전 대체
  - Role 4 (State Management Expert) → state-management-guard Agent로 완전 대체
  - Role 6 (QA Documentation) 분할:
    - flutter analyze → qa-code-analyzer Agent
    - 문서 작성 → Role 1 또는 Role 5가 필요 시 직접 수행
```

---

## 3. 성능 비교 및 예상 효과

### 3.1 성능 시뮬레이션

#### 시나리오 1: 단일 Provider 검증 (현재 vs 최종)

**현재 (SKILL 시스템)**:
```
사용자: "shopProvider 추가해줘"

순차 실행:
1. Role 1 (Architect): 작업 분해 (10초)
2. Role 4 (State): Provider Level 결정 (20초)
3. Role 6 (QA): flutter analyze (10초)
4. Role 5 (Fullstack): 구현 (60초)
5. Role 6 (QA): 재검증 (10초)

총 소요 시간: 110초
```

**최종 (하이브리드 시스템)**:
```
사용자: "shopProvider 추가해줘"

1. Role 1 (Architect): 작업 분해 (10초)

2. 병렬 실행 (동시):
   ├─ state-management-guard (8초)
   ├─ qa-code-analyzer (10초)
   └─ ui-design-validator (6초)
   가장 긴 작업: 10초

3. Role 5 (Fullstack): 구현 (60초)

4. 병렬 재검증 (동시):
   ├─ state-management-guard (8초)
   ├─ qa-code-analyzer (10초)
   └─ ui-design-validator (6초)
   가장 긴 작업: 10초

총 소요 시간: 10 + 10 + 60 + 10 = 90초

성능 향상: 18% (110초 → 90초)
```

---

#### 시나리오 2: 복잡한 Feature 구현 (4개 파일, 게임 밸런스 영향)

**현재 (SKILL 시스템)**:
```
사용자: "Meeting 참여 기능 추가 (포인트 100 획득, 등반력 영향 없음)"

순차 실행:
1. Role 1: 작업 분해 (30초)
2. Role 6: 현재 품질 확인 (10초)
3. Role 4: Provider 검증 (20초)
4. Role 2: 게임 밸런스 검증 (30초)
5. Role 3: UI 검증 (15초)
6. Role 5: 구현 (120초)
7. Role 6: 재검증 (20초)

총 소요 시간: 245초 (약 4분)
```

**최종 (하이브리드 시스템)**:
```
사용자: "Meeting 참여 기능 추가 (포인트 100 획득, 등반력 영향 없음)"

1. Role 1: 작업 분해 (30초)

2. 병렬 검증 (동시):
   ├─ qa-code-analyzer (10초)
   ├─ state-management-guard (12초)
   ├─ ui-design-validator (10초)
   └─ game-balance-validator (25초)
   가장 긴 작업: 25초

3. Role 5: 구현 (120초)

4. 병렬 재검증 (동시):
   ├─ qa-code-analyzer (15초)
   ├─ state-management-guard (12초)
   ├─ ui-design-validator (10초)
   └─ game-balance-validator (20초)
   가장 긴 작업: 20초

총 소요 시간: 30 + 25 + 120 + 20 = 195초 (약 3.3분)

성능 향상: 20% (245초 → 195초)
```

---

### 3.2 성능 향상 요약

| 시나리오 | 현재 (SKILL) | 최종 (하이브리드) | 성능 향상 |
|---------|-------------|----------------|----------|
| 단일 Provider 검증 | 110초 | 90초 | 18% |
| 복잡한 Feature (4파일) | 245초 | 195초 | 20% |
| UI 변경 (3파일) | 180초 | 135초 | 25% |
| 게임 밸런스 변경 | 160초 | 115초 | 28% |
| **평균** | **174초** | **134초** | **23%** |

**핵심 요약**:
- ⚡ **평균 23% 빠름** (174초 → 134초)
- 🎯 **품질 100% 유지** (모든 검증 동일하게 수행)
- 🔄 **병렬 실행 효과** (검증 4개 동시 실행)

---

## 4. 구현 가이드

### 4.1 Agent 파일 생성 템플릿

**위치**: `.claude/agents/[agent-name].md`

**기본 구조**:
```markdown
---
name: agent-name
description: Use proactively when [trigger condition]
tools: [Read, Grep, Glob, Bash]  # 필요한 도구만
model: sonnet  # 또는 haiku (단순 작업), opus (복잡한 작업)
---

# [Agent Name]

You are the [Role Description] for Sherpa App.

## Critical Rules

### 1. [Rule 1 Name]
```[code/command]
[Example]
```
[Explanation]

### 2. [Rule 2 Name]
...

## Auto-Activation Triggers
- File changes in: [path]
- Keywords: [keyword1, keyword2]
- Pattern: [regex pattern]

## Verification Steps
1. [Step 1]
2. [Step 2]
...

## Output Format
```markdown
## [Icon] [Title]

### [Section 1]
- [Item 1]

---
**Validator**: [agent-name]
**Status**: [✅ APPROVED | ⚠️ FIXES REQUIRED | 🚨 CRITICAL ERROR]
```

## Error Handling
- [Error Type 1]: [Response]
- [Error Type 2]: [Response]
```

---

### 4.2 Phase 1 구현: state-management-guard

**파일**: `.claude/agents/state-management-guard.md`

```markdown
---
name: state-management-guard
description: Use proactively when Provider initialization order or questProvider usage needs verification
tools: Read, Grep, Glob
model: sonnet
---

# State Management Guard

You are the State Management Guard for Sherpa App, ensuring Provider system stability and preventing app crashes.

## CRITICAL RULES (App Crash Prevention!)

### 1. Provider Initialization Order: Level 0 → 1 → 2 → 3

**Location**: `lib/main.dart` function `_initializeProviders()`

**Correct Order** (NEVER CHANGE!):
```dart
// Level 0: Game Core (No dependencies)
ref.read(globalGameProvider);

// Level 1: User Foundation
ref.read(globalUserProvider);      // depends on: globalGameProvider
ref.read(globalPointProvider);     // depends on: globalUserProvider
ref.read(globalUserTitleProvider); // depends on: globalUserProvider

// Level 2: Feature Systems
ref.read(questProviderV2);         // ⚠️ V2! questProvider FORBIDDEN!
ref.read(globalMeetingProvider);   // depends on: globalUserProvider, globalPointProvider

// Level 3: UI & Additional Features
ref.read(sherpiProvider);          // depends on: globalUserProvider, questProviderV2
ref.read(relationshipProvider);
ref.read(emotionAnalysisProvider);
```

**Wrong Order Example** (APP CRASH!):
```dart
ref.read(questProviderV2);       // Level 2 FIRST → dependencies missing → CRASH!
ref.read(globalUserProvider);    // Level 1 LATER
```

**Verification Command**:
```bash
grep -A 20 "_initializeProviders" lib/main.dart
```

---

### 2. questProviderV2 ONLY (questProvider FORBIDDEN!)

**Critical**: `questProvider` is legacy and causes app crashes!

**Search Commands** (MUST be 0 results!):
```bash
# Search for legacy questProvider
grep -r "questProvider[^V]" lib/ --include="*.dart"
grep -r "import.*quest_provider.dart" lib/ --include="*.dart"

# If found → 🚨 CRITICAL ERROR!
```

**Correct Usage**:
```dart
// ✅ CORRECT
import 'package:sherpa_app/features/quests/providers/quest_provider_v2.dart';
ref.read(questProviderV2);
ref.watch(questProviderV2);

// ❌ FORBIDDEN (APP CRASH!)
import 'package:sherpa_app/features/quests/providers/quest_provider.dart';
ref.read(questProvider);  // ← CRASH!
```

---

### 3. Circular Dependency Detection

**Forbidden Pattern**:
```
ProviderA → ProviderB → ProviderA (CIRCULAR!)
```

**Verification Steps**:
1. Extract all `ref.read()` and `ref.watch()` calls from each Provider
2. Build dependency graph
3. Run DFS (Depth-First Search) to detect cycles
4. Report any circular paths

**Correct Pattern** (Shared Dependency):
```dart
// ✅ CORRECT
SharedDataProvider (common data)
  ↑         ↑
ProviderA  ProviderB  (both depend on Shared, no circular)
```

---

### 4. New Provider Level Determination

**Decision Tree**:
```
New Provider: shopProvider

Step 1: Identify dependencies
- Depends on: globalUserProvider (Level 1)
- Depends on: globalPointProvider (Level 1)

Step 2: Find highest dependency Level
- globalUserProvider: Level 1
- globalPointProvider: Level 1
→ Highest Level: 1

Step 3: Determine new Provider Level
- New Level = Highest Dependency Level + 1
- shopProvider Level = 1 + 1 = 2

Conclusion: shopProvider is Level 2
Position: After questProviderV2, globalMeetingProvider (same Level)
```

---

## Auto-Activation Triggers

- **File changes in**: `lib/shared/providers/*.dart`, `lib/main.dart`
- **Keywords**: provider, state, riverpod, initialization, questProvider, Level
- **New Provider creation** detected
- **Explicit request**: "Provider 검증", "초기화 순서 확인"

---

## Verification Process

### Phase 1: Read main.dart
```bash
read lib/main.dart
```
Extract `_initializeProviders()` function

### Phase 2: Verify Initialization Order
```python
expected_order = [
    # Level 0
    'globalGameProvider',

    # Level 1
    'globalUserProvider',
    'globalPointProvider',
    'globalUserTitleProvider',

    # Level 2
    'questProviderV2',
    'globalMeetingProvider',

    # Level 3
    'sherpiProvider',
    'relationshipProvider',
    'emotionAnalysisProvider',
]

actual_order = extract_from_code()

if actual_order != expected_order:
    report_error("Provider initialization order is WRONG!")
```

### Phase 3: Check questProvider Usage
```bash
grep -r "questProvider[^V]" lib/ --include="*.dart"
```
**Expected**: 0 results
**If found**: 🚨 CRITICAL ERROR

### Phase 4: Circular Dependency Check
1. Build dependency graph
2. For each Provider, run DFS
3. Detect cycles
4. Report circular paths

---

## Output Format

```markdown
## 🔧 State Management Validation

### Provider Initialization Order
- ✅ Level 0: globalGameProvider
- ✅ Level 1: globalUserProvider, globalPointProvider, globalUserTitleProvider
- ✅ Level 2: questProviderV2, globalMeetingProvider
- ✅ Level 3: sherpiProvider, relationshipProvider, emotionAnalysisProvider

**Verification**: ✅ Correct order (Level 0 → 1 → 2 → 3)

### questProvider Check (CRITICAL!)
- ✅ questProvider usage: 0 instances
- ✅ questProviderV2 usage: 18 instances

**Verification**: ✅ No legacy questProvider found

### Circular Dependencies
- ✅ Dependency graph built
- ✅ DFS cycle detection completed
- ✅ No circular paths detected

**Verification**: ✅ No circular dependencies

### New Provider Analysis (if applicable)
**Provider**: shopProvider
**Dependencies**: globalUserProvider (L1), globalPointProvider (L1)
**Recommended Level**: Level 2
**Position**: After questProviderV2, globalMeetingProvider

---
**Validator**: state-management-guard
**Executed**: 2025-10-30 15:45
**Status**: ✅ APPROVED
```

---

## Error Handling

### Error 1: Wrong Initialization Order
```markdown
🚨 CRITICAL ERROR: Provider Initialization Order

**Found**:
```dart
ref.read(questProviderV2);       // Level 2
ref.read(globalUserProvider);    // Level 1  ← WRONG ORDER!
```

**Expected**:
```dart
ref.read(globalUserProvider);    // Level 1 FIRST
ref.read(questProviderV2);       // Level 2 AFTER
```

**Impact**: APP CRASH (questProviderV2 depends on globalUserProvider)
**Priority**: CRITICAL (Fix immediately!)
**Fix**: Reorder initialization in lib/main.dart:_initializeProviders()
```

### Error 2: questProvider Usage Found
```markdown
🚨 CRITICAL ERROR: Legacy questProvider Usage

**File**: lib/features/profile/providers/user_stats_provider.dart:45
**Current Code**:
```dart
ref.read(questProvider)
```

**Fix**:
```dart
ref.read(questProviderV2)
```

**Reason**: questProvider is legacy and causes data conflicts → APP CRASH
**Priority**: CRITICAL (Fix immediately!)
```

### Error 3: Circular Dependency Detected
```markdown
🚨 ERROR: Circular Dependency

**Circular Path**:
ProviderA → ProviderB → ProviderC → ProviderA

**Impact**: Infinite loop, memory leak
**Priority**: HIGH

**Recommended Fix**: Extract shared dependencies
```dart
// Create SharedDataProvider
SharedDataProvider (common data)
  ↑         ↑         ↑
ProviderA  ProviderB  ProviderC
```
```

---

## Reference Documents

- `.claude/knowledge_base/provider_dependencies.md` (Provider Level definitions)
- `lib/main.dart` (Actual initialization code)
- `CLAUDE.md` (Provider initialization section)

---

**Agent Version**: 1.0.0
**Last Updated**: 2025-10-30
**Author**: state-management-guard specification
```

---

### 4.3 Agent 테스트 계획

**테스트 케이스 10개**:

```yaml
TC1_정상_초기화_순서:
  입력: Level 0→1→2→3 올바른 순서
  기대_출력: "✅ APPROVED"
  우선순위: P0 (필수)

TC2_잘못된_초기화_순서:
  입력: |
    ref.read(questProviderV2);       // Level 2
    ref.read(globalUserProvider);    // Level 1
  기대_출력: "🚨 CRITICAL ERROR: Provider Initialization Order"
  우선순위: P0 (필수)

TC3_questProvider_사용:
  입력: "ref.read(questProvider)"
  기대_출력: "🚨 CRITICAL ERROR: Legacy questProvider Usage"
  우선순위: P0 (필수)

TC4_questProviderV2_정상_사용:
  입력: "ref.read(questProviderV2)"
  기대_출력: "✅ questProviderV2 usage: 18 instances"
  우선순위: P0 (필수)

TC5_새_Provider_Level_2_적합:
  입력: |
    shopProvider depends on:
    - globalUserProvider (Level 1)
    - globalPointProvider (Level 1)
  기대_출력: "Recommended Level: Level 2"
  우선순위: P0 (필수)

TC6_새_Provider_Level_3_적합:
  입력: |
    notificationProvider depends on:
    - globalUserProvider (Level 1)
    - questProviderV2 (Level 2)
  기대_출력: "Recommended Level: Level 3"
  우선순위: P1 (중요)

TC7_순환_의존성_발견:
  입력: |
    ProviderA → ProviderB
    ProviderB → ProviderA
  기대_출력: "🚨 ERROR: Circular Dependency"
  우선순위: P1 (중요)

TC8_순환_의존성_없음:
  입력: 올바른 의존성 그래프
  기대_출력: "✅ No circular dependencies"
  우선순위: P1 (중요)

TC9_Import_문_확인:
  입력: |
    import 'package:sherpa_app/features/quests/providers/quest_provider.dart';
  기대_출력: "🚨 CRITICAL ERROR: Legacy questProvider import"
  우선순위: P1 (중요)

TC10_복합_에러:
  입력: |
    - 초기화 순서 오류
    - questProvider 사용
    - 순환 의존성
  기대_출력: 3개 에러 모두 리포트
  우선순위: P2 (참고)
```

**테스트 실행 방법**:
```bash
# 1. Agent 파일 생성
# .claude/agents/state-management-guard.md

# 2. 테스트 케이스 준비
# test_cases/provider_test_cases.yaml

# 3. Agent 실행 테스트
# 각 테스트 케이스마다 Agent 호출

# 4. 결과 비교
# Agent 결과 vs SKILL Role 4 결과

# 5. 성능 측정
# 실행 시간, 정확도, 오탐/미탐률
```

---

## 5. 최종 권장사항

### 5.1 8주 후 최종 시스템 구성

```yaml
최종_하이브리드_시스템:
  Agent_4개:
    - state-management-guard (Provider 검증)
    - qa-code-analyzer (flutter analyze)
    - ui-design-validator (ModernColors, Sherpi)
    - game-balance-validator (게임 밸런스)

  SKILL_2개:
    - Role 1: Architect Orchestrator (작업 조율)
    - Role 5: Fullstack Implementer (코드 작성)

  제거된_SKILL_4개:
    - Role 2 → game-balance-validator Agent
    - Role 3 → ui-design-validator Agent
    - Role 4 → state-management-guard Agent
    - Role 6 → qa-code-analyzer Agent (분할)

성능_개선:
  - 평균 23% 빠름 (174초 → 134초)
  - 병렬 실행으로 검증 시간 40-60% 단축
  - 품질 100% 유지

품질_보장:
  - 치명적 에러 100% 사전 차단 (Provider, questProvider)
  - flutter analyze 0 errors 강제
  - 레거시 패턴 자동 차단 (AppColors, RecordColors)

유연성:
  - Agent 추가/수정 용이 (~50줄 설정)
  - SKILL은 복잡한 작업 담당 (안정성)
  - 하이브리드로 최적 조합
```

---

### 5.2 구현 로드맵

```
Week 1-2: Phase 1 - state-management-guard
  - Agent 파일 생성
  - 10개 테스트 케이스 검증
  - SKILL Role 4와 병행 운영
  - 성능/정확도 평가

Week 3-4: Phase 2 - qa-code-analyzer
  - Agent 파일 생성
  - flutter analyze 자동화
  - 병렬 실행 테스트 (state + qa)
  - SKILL Role 6 분할 (Agent + SKILL)

Week 5-6: Phase 3 - ui-design-validator
  - Agent 파일 생성
  - ModernColors, Sherpi 검증 자동화
  - 병렬 실행 테스트 (state + qa + ui)
  - SKILL Role 3 제거 (Agent로 완전 대체)

Week 7-8: Phase 4 - game-balance-validator
  - Agent 파일 생성
  - Python 시뮬레이션 연동
  - 4개 Agent 병렬 실행 테스트
  - SKILL Role 2 제거 (Agent로 완전 대체)

Week 9: 최종 검증 및 문서화
  - 전체 시스템 성능 측정
  - SKILL 2개 + Agent 4개 하이브리드 확립
  - 문서 업데이트 (CLAUDE.md, 지식베이스)

Week 10: 안정화 및 모니터링
  - 2주간 운영 모니터링
  - 오탐/미탐 체크
  - 성능 최적화
```

---

### 5.3 성공 기준

```yaml
Phase_1_성공_기준: state-management-guard
  정확도: 100% (10/10 테스트 케이스 통과)
  성능: SKILL 대비 50% 이상 빠름
  안정성: 2주간 오탐/미탐 없음
  사용성: 자동 활성화 100% 작동

Phase_2_성공_기준: qa-code-analyzer
  정확도: 100% (flutter analyze 결과 동일)
  성능: SKILL 대비 30% 이상 빠름
  병렬: state + qa 동시 실행 가능

Phase_3_성공_기준: ui-design-validator
  정확도: 100% (ModernColors 검증 완벽)
  성능: SKILL 대비 40% 이상 빠름
  병렬: state + qa + ui 동시 실행

Phase_4_성공_기준: game-balance-validator
  정확도: 100% (Python 시뮬레이션 정상)
  성능: SKILL 대비 35% 이상 빠름
  병렬: 4개 Agent 동시 실행

최종_성공_기준: 하이브리드 시스템
  전체_성능: 평균 20% 이상 빠름
  품질_유지: 100% (모든 검증 동일)
  안정성: 4주간 문제 없음
  사용자_만족도: 개발 속도 체감 향상
```

---

### 5.4 리스크 관리

```yaml
리스크_1: Agent 정확도 미달
  확률: 낮음 (명확한 규칙 기반)
  영향: 높음 (오탐/미탐)
  대응: SKILL fallback 유지, 2주 병행 운영

리스크_2: Agent 성능 개선 미미
  확률: 중간
  영향: 중간 (성능 향상 미미)
  대응: 병렬 실행 최적화, 모델 변경 (haiku)

리스크_3: 복잡한 케이스 처리 실패
  확률: 중간
  영향: 중간
  대응: SKILL로 fallback, 점진적 개선

리스크_4: Agent 간 충돌
  확률: 낮음
  영향: 낮음
  대응: 독립 컨텍스트 격리, 명확한 역할 분담
```

---

## 6. 결론

### 6.1 핵심 요약

**Agent 전환 추천** (4개):
1. ✅✅ **state-management-guard** (최우선) - Provider 검증, 앱 크래시 방지
2. ✅ **qa-code-analyzer** (고우선) - flutter analyze 자동화
3. ✅ **ui-design-validator** (중우선) - ModernColors, Sherpi 검증
4. ✅ **game-balance-validator** (일반) - 게임 밸런스 자동화

**SKILL 유지** (2개):
1. ✅ **Role 1: Architect Orchestrator** - 복잡한 조율, 메타 레벨 작업
2. ✅ **Role 5: Fullstack Implementer** - 신중한 코드 작성, 창의적 구현

**예상 효과**:
- ⚡ **23% 빠른 검증** (병렬 실행)
- 🎯 **100% 품질 유지** (모든 검증 동일)
- 🔄 **유연한 확장** (Agent 추가 용이)
- 🛡️ **치명적 에러 차단** (Provider, questProvider)

---

### 6.2 실행 계획

```
1단계 (Week 1-2): state-management-guard 구현 및 검증
  → 가장 중요한 검증 자동화, 앱 크래시 방지

2단계 (Week 3-4): qa-code-analyzer 추가
  → 품질 검증 자동화, 2개 Agent 병렬 실행

3단계 (Week 5-6): ui-design-validator 추가
  → UI 검증 자동화, 3개 Agent 병렬 실행

4단계 (Week 7-8): game-balance-validator 추가
  → 게임 밸런스 자동화, 4개 Agent 병렬 실행

최종 (Week 9-10): 안정화 및 모니터링
  → 하이브리드 시스템 확립, 성능 최적화
```

---

### 6.3 최종 의견

**"선택적 하이브리드 접근이 최적입니다."**

**이유**:
1. **Agent 전환 적합 (4개)**: 명확한 규칙 기반, 완전 자동화 가능, 병렬 실행으로 성능 향상
2. **SKILL 유지 적합 (2개)**: 복잡한 판단 필요, 순차 조율 필수, 신중한 실행 필요
3. **점진적 전환**: 8주에 걸쳐 단계별 검증, 리스크 최소화
4. **성능과 품질 모두 확보**: 23% 빠르면서 100% 품질 유지

**"전면 Agent 전환이 아닌, 각 Role의 특성에 맞는 최적 선택입니다."**

---

**문서 버전**: 2.0.0
**작성일**: 2025-10-30
**작성자**: Claude Code (Sonnet 4.5)
**검토 필요**: Sherpa App Development Team
**다음 단계**: Phase 1 (state-management-guard) 구현 시작
