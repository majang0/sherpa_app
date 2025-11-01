# Agent System Upgrade Strategy - Sherpa App
## Claude Code 개발 수준 향상을 위한 전략적 방향성

**Document Version**: 1.0.0  
**Created**: 2025-11-01  
**Analysis Method**: Sequential Thinking (8-phase deep analysis)  
**Core Philosophy**: 품질 우선 (Quality over Speed)

---

## 📋 Executive Summary

### Current State (As of 2025-11-01)

**Skill System**: 6개 역할 기반 수동 오케스트레이션
- Role 1: Architect Orchestrator (중앙 조율자)
- Role 2: Game Logic Specialist (게임 밸런스)
- Role 3: UI/UX Guardian (디자인 시스템)
- Role 4: State Management Expert (Provider 관리)
- Role 5: Fullstack Implementer (구현 전담)
- Role 6: QA Documentation (품질 및 문서화)

**Agent System**: 5개 자동 검증 에이전트 (모두 Sonnet 4.5 기반)
- agent-creator (메타 에이전트)
- ui-design-validator (UI 자동 검증)
- state-management-guard (Provider 크래시 방지)
- code-quality-validator (코드 품질 5개 도메인)
- documentation-specialist (자연어 문서화)

### Key Findings

1. ✅ **강점**: 명확한 역할 분리, 품질 우선 철학, Sherpa 앱 특화
2. ⚠️ **약점**: Skills-Agents 중복 영역 존재, 통합 문서 부재
3. 🎯 **기회**: CI/CD 통합, 점진적 에이전트 추가, 지식 베이스 통합
4. 🚨 **위협**: 복잡도 증가 위험, 성능 오버헤드 가능성

### Strategic Direction

**핵심 원칙**: Skills + Agents = **Compound Intelligence System**
- **Skills (수동)**: 전략적 사고, 복잡한 창작, 다단계 오케스트레이션
- **Agents (자동)**: 실시간 검증, 패턴 강제, 품질 게이트

**완성도**: 현재 70% → 목표 95% (3개월 로드맵)

---

## 🔍 Current System Analysis

### 1. Skill System (6 Roles)

#### Role 1: Architect Orchestrator
- **Purpose**: 중앙 조율자, 복잡한 작업 분해 및 위임
- **Pattern**: Phase → Task → Todo 계층 구조
- **Tools**: Read, Grep, Glob, TodoWrite, Task
- **Critical**: Provider 초기화 순서 Level 0→1→2→3 강제
- **Specialization**: 읽기 전용, Task tool로 다른 role에 위임

#### Role 2: Game Logic Specialist
- **Purpose**: 게임 밸런스 검증 및 시뮬레이션
- **Pattern**: Python 스크립트 기반 수학적 검증
- **Critical Formula**:
  ```dart
  // Climbing power (3 stats only!)
  statsBonus = stamina + knowledge + technique
  finalPower = basePower * (1 + statsBonus/100) * (1 + badgeBonus/100)
  
  // XP curve
  Required XP = (level ^ 1.5) × 40 + (level × 20)
  ```
- **Tools**: Read, Bash (Python), Glob
- **Script**: `.claude/skills/role2-game-logic-specialist/scripts/balance_simulator.py`

#### Role 3: UI/UX Guardian
- **Purpose**: 디자인 시스템 일관성 강제
- **Critical Rules**:
  - ✅ ModernColors만 사용
  - ❌ AppColors/RecordColors 금지 (레거시)
  - Sherpi 감정-컨텍스트 매트릭스 검증
- **Tools**: Read, Grep, Glob
- **Overlap**: ui-design-validator Agent와 중복

#### Role 4: State Management Expert
- **Purpose**: Provider 의존성 관리 (크래시 방지)
- **Critical Pattern**:
  ```dart
  // lib/main.dart _initializeProviders()
  ref.read(globalGameProvider);      // Level 0
  ref.read(globalUserProvider);      // Level 1
  ref.read(questProviderV2);         // Level 2 (NOT questProvider!)
  ref.read(sherpiProvider);          // Level 3
  ```
- **Tools**: Read, Grep, Glob
- **Overlap**: state-management-guard Agent와 중복

#### Role 5: Fullstack Implementer
- **Purpose**: 실제 코드 구현 (유일한 Write 권한 보유)
- **Pattern**: Feature-First 아키텍처
  ```
  lib/features/[feature_name]/
  ├── domain/
  ├── providers/
  └── presentation/
      ├── screens/
      └── widgets/
  ```
- **Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob
- **2025 Standards**: Riverpod 2.4.9, Flutter 3.27.0, Null-safety

#### Role 6: QA Documentation
- **Purpose**: 품질 게이트 및 문서화
- **Critical**: `flutter analyze` → 0 errors, 0 warnings 필수
- **Test Pattern**: Given-When-Then 형식
- **CHANGELOG**: Keep a Changelog 형식
- **Tools**: Read, Bash, Write, Edit
- **Overlap**: code-quality-validator, documentation-specialist Agent와 중복

---

### 2. Agent System (5 Agents)

#### agent-creator (Meta Agent)
- **Version**: 2.0.0 (Sonnet 4.5 Optimized)
- **Model**: sonnet
- **Purpose**: 새 에이전트 생성 템플릿
- **Key Change**: Haiku → Sonnet 4.5 (사용자 피드백 반영: "속도보다 품질")

#### ui-design-validator
- **Model**: sonnet
- **Triggers**: `lib/features/**/presentation/**/*.dart` 파일 변경
- **Validates**:
  1. ModernColors 사용 (AppColors/RecordColors 금지)
  2. Sherpi 감정-컨텍스트 호환성
  3. Material Design 3 원칙 (spacing, typography, shadows)
  4. 접근성 (WCAG 2.1 AA - 4.5:1 대비)
  5. 반응형 디자인 패턴
- **Overlap**: Role 3 (UI/UX Guardian)와 중복
- **Differentiation**: 파일 저장 시 자동 검증 vs 수동 호출

#### state-management-guard
- **Model**: sonnet
- **Triggers**: `lib/shared/providers/*.dart`, `lib/main.dart` 변경
- **Validates**:
  1. Provider 초기화 순서 Level 0→1→2→3
  2. questProviderV2 사용 (questProvider 금지)
  3. 순환 의존성 방지
  4. 파일 구조 규칙
- **Overlap**: Role 4 (State Management Expert)와 중복
- **Differentiation**: 크래시 방지 사전 검증 vs 분석 및 설계

#### code-quality-validator
- **Model**: sonnet
- **5 Domains**:
  1. Dead Code (사용되지 않는 코드)
  2. Correctness (논리 오류)
  3. Code Smells (안티패턴)
  4. Duplication (중복 코드)
  5. Quality (복잡도, 가독성)
- **Overlap**: Role 6 (QA Documentation)와 부분 중복
- **Differentiation**: 정적 분석 자동화 vs 테스트 및 문서화

#### documentation-specialist
- **Model**: sonnet
- **Style**: 자연어 우선, 코드 예시 30% 이하
- **Triggers**: 문서화 요청, CLAUDE.md 업데이트
- **Overlap**: Role 6 (QA Documentation)와 부분 중복
- **Differentiation**: 자연어 문서 생성 vs 테스트 및 CHANGELOG

---

## 🔄 Skills vs Agents Comparison

### Design Philosophy Differences

| Aspect | Skills (Manual) | Agents (Auto) |
|--------|----------------|---------------|
| **Activation** | 사용자 명시 호출 (`"role1로 분석해줘"`) | 파일 변경 시 자동 트리거 |
| **Scope** | 광범위한 창작적 작업 | 특정 패턴 검증 |
| **Timing** | 사전 계획, 설계, 구현 | 사후 검증, 실시간 가드 |
| **Depth** | 깊은 전략적 사고 (Extended Thinking) | 빠른 패턴 매칭 (Precise Validation) |
| **Output** | 계획, 분석, 구현 코드 | 검증 보고서, 오류 목록 |
| **Tools** | Task 도구로 위임 | Read, Grep, Glob 위주 |
| **Interaction** | 다단계 대화형 | 단일 검증 결과 반환 |

### Integration Patterns (현재 동작 방식)

**Pattern 1: Sequential Validation** (순차 검증)
```
사용자 요청 → Role 5 구현 → 파일 저장 
  → ui-design-validator 자동 실행 (UI 검증)
  → state-management-guard 자동 실행 (Provider 검증)
  → 사용자에게 결과 보고
```

**Pattern 2: Agent-Assisted Skills** (에이전트 보조 스킬)
```
사용자: "role3로 디자인 검토해줘"
  → Role 3 수동 분석 시작
  → (내부) ui-design-validator 결과 참조
  → 종합 분석 보고서 생성
```

**Pattern 3: Complementary Specialization** (상호 보완)
- **Agents**: 반복적인 오류 패턴 차단 (Provider 순서, 레거시 색상)
- **Skills**: 복잡한 창작 작업 (아키텍처 설계, 기능 구현)

---

## 📊 Gap Analysis

### 1. Skills-Agents Overlap (중복 영역)

| Skill | Overlapping Agent | Severity | Resolution |
|-------|-------------------|----------|------------|
| Role 3 (UI/UX) | ui-design-validator | Medium | Agent는 실시간 검증, Skill은 전략적 디자인 결정 |
| Role 4 (State) | state-management-guard | High | Agent는 크래시 방지, Skill은 의존성 설계 |
| Role 6 (QA) | code-quality-validator, documentation-specialist | Medium | Agent는 자동 검사, Skill은 테스트 전략 및 문서 작성 |

**해결 방안**:
- **단기**: INTEGRATION_GUIDE.md 작성 (역할 명확화)
- **중기**: 각 Agent 설명에 "complements [Role X]" 추가
- **장기**: 통합 지식 베이스 구축

### 2. Missing Agents (잠재적 추가 에이전트)

| Proposed Agent | Rationale | Priority | ROI |
|----------------|-----------|----------|-----|
| game-balance-validator | Role 2 Python 시뮬레이션 자동 실행 | Medium | Medium (수동으로도 가능) |
| test-coverage-guard | 80%+ 커버리지 강제 (Role 6 보조) | High | High (품질 게이트 강화) |
| dependency-update-monitor | pubspec.yaml 변경 시 취약점 검사 | Low | Medium (보안 강화) |
| performance-regression-detector | 성능 저하 감지 (빌드 시간, 앱 크기) | Low | Low (수동 모니터링으로 충분) |

**권장 사항**: test-coverage-guard만 추가 (Priority High, ROI High)

### 3. Documentation Gaps (문서화 부재)

| Missing Document | Impact | Priority |
|------------------|--------|----------|
| INTEGRATION_GUIDE.md | High (혼란 방지) | P0 (즉시) |
| knowledge_base/ 폴더 | High (중복 지식 통합) | P0 (1주) |
| CI/CD 통합 가이드 | Medium (자동화 지연) | P2 (1개월) |
| 성능 모니터링 대시보드 | Low (선택 사항) | P3 (3개월) |

---

## 💪 SWOT Analysis

### Strengths (강점)

1. **명확한 역할 분리**: 6개 Skills + 5개 Agents, 중복 최소화
2. **품질 우선 철학**: 모든 Agent가 Sonnet 4.5 기반
3. **Sherpa 앱 특화**: Provider 초기화, ModernColors, 게임 밸런스 등 도메인 지식 내재화
4. **Extended Thinking**: 3-Phase 검증 패턴 (Pre-Analysis → Validation → Synthesis)
5. **실전 검증됨**: 이전 세션에서 실제 크래시 방지 성공 (questProvider → questProviderV2 마이그레이션)

### Weaknesses (약점)

1. **Skills-Agents 중복**: Role 3/4/6과 해당 Agent 간 역할 모호성
2. **통합 문서 부재**: 언제 Skill 쓰고 언제 Agent 쓸지 가이드 없음
3. **지식 중복**: Provider 규칙, ModernColors 규칙이 여러 파일에 흩어짐
4. **CI/CD 미통합**: Agent 검증이 수동 (파일 저장 시에만 실행)
5. **성능 미측정**: Agent 활성화 빈도, False Positive 비율 모름

### Opportunities (기회)

1. **CI/CD 통합**: GitHub Actions로 PR 자동 검증 (머지 차단)
2. **점진적 Agent 추가**: test-coverage-guard 등 ROI 높은 것만 선택
3. **지식 베이스 통합**: `knowledge_base/` 폴더로 단일 진실 공급원 구축
4. **외부 도구 연동**: SonarQube, CodeClimate 등과 통합
5. **메트릭 기반 개선**: 데이터 기반 Agent 민감도 조정

### Threats (위협)

1. **복잡도 증가**: Agent 무분별 추가 시 유지보수 부담
2. **성능 오버헤드**: 파일 저장마다 5개 Agent 실행 시 지연
3. **False Positive**: 과도한 검증으로 개발 흐름 방해
4. **지식 부채**: 규칙 업데이트 시 Skills + Agents 모두 수정 필요
5. **학습 곡선**: 새 팀원이 6 Skills + 5 Agents 이해하는데 시간 소요

---

## 🗺️ Upgrade Roadmap

### Priority 1: Integration Clarity (1-2주, 즉시 시작)

**Goal**: Skills와 Agents 역할 명확화, 중복 제거

**Deliverables**:
1. **`C:\sherpa_app\.claude\INTEGRATION_GUIDE.md`** 작성
   - 의사결정 트리: 언제 Skill? 언제 Agent? 언제 둘 다?
   - 시나리오별 예시:
     ```markdown
     # Scenario 1: UI 화면 신규 개발
     1. Role 1로 전체 계획 수립
     2. Role 3로 디자인 시스템 확인
     3. Role 5로 구현
     4. 파일 저장 → ui-design-validator 자동 검증
     
     # Scenario 2: Provider 추가
     1. Role 4로 의존성 분석 및 Level 결정
     2. Role 5로 구현
     3. main.dart 수정 → state-management-guard 자동 검증
     ```
   - Handoff 패턴: Agent가 이슈 발견 시 해당 Role 추천

2. **모든 Agent 설명 업데이트** (5개 파일)
   - 각 Agent의 description에 다음 추가:
     ```yaml
     description: "... Complements Role X by providing automated validation, 
                   while Role X focuses on strategic design decisions."
     ```
   - 예: ui-design-validator → "Complements Role 3 (UI/UX Guardian)"

**Success Criteria**:
- ✅ INTEGRATION_GUIDE.md 작성 완료
- ✅ 5개 Agent 설명 업데이트
- ✅ 새 개발자가 30분 내 이해 가능한 수준

---

### Priority 2: Knowledge Base Unification (1주, Priority 1 완료 후)

**Goal**: 중복된 규칙을 단일 진실 공급원으로 통합

**Deliverables**:
1. **`C:\sherpa_app\.claude\knowledge_base\`** 폴더 생성
   
2. **핵심 규칙 파일 작성** (4개):
   - `provider_rules.md`: Provider 초기화 순서, Level 정의, questProviderV2 강제
   - `design_system_rules.md`: ModernColors 규칙, Sherpi 감정-컨텍스트 매트릭스
   - `game_balance_formulas.md`: Climbing power, XP curve, 포인트 계산식
   - `code_quality_standards.md`: flutter analyze 0/0 규칙, test coverage 80%+

3. **Skills + Agents 참조 업데이트**:
   ```markdown
   # Before (Role 4)
   - Provider 초기화 순서: Level 0 → 1 → 2 → 3
   - Level 0: globalGameProvider
   - ...
   
   # After (Role 4)
   - Provider 초기화 순서: @knowledge_base/provider_rules.md 참조
   ```

**Benefits**:
- 규칙 변경 시 1곳만 수정
- Skills와 Agents가 항상 동일한 규칙 사용
- 지식 부채 감소

**Success Criteria**:
- ✅ knowledge_base/ 폴더 + 4개 규칙 파일 완성
- ✅ 6 Skills + 5 Agents 모두 참조 업데이트
- ✅ CLAUDE.md에 "Knowledge Base" 섹션 추가

---

### Priority 3: Optional Agent Additions (2-4주, Priority 2 완료 후)

**Goal**: ROI 높은 에이전트만 선택적 추가

**Recommended**: test-coverage-guard (Priority High, ROI High)

**Spec**:
```yaml
---
name: test-coverage-guard
description: Ensures 80%+ unit test coverage for new features. Proactively validates test files when feature code changes. Complements Role 6 (QA Documentation) by automating coverage checks.
tools: Read, Bash, Grep, Glob
model: sonnet
---

# Test Coverage Guard

**Auto-Activation Triggers**:
- Feature file changes: lib/features/**/domain/*.dart, lib/features/**/providers/*.dart
- Test file creation: test/**/*_test.dart

**Validation**:
1. Run `flutter test --coverage`
2. Parse coverage/lcov.info
3. Calculate coverage % for changed files
4. If < 80%: Report missing test cases

**Integration with Role 6**:
- Agent: Automated coverage check
- Role 6: Test strategy, Given-When-Then patterns, edge case identification
```

**Not Recommended** (낮은 ROI):
- game-balance-validator: Role 2 수동 실행으로 충분 (빈도 낮음)
- dependency-update-monitor: Dependabot으로 대체 가능
- performance-regression-detector: 수동 모니터링으로 충분 (복잡도 높음)

**Success Criteria**:
- ✅ test-coverage-guard 구현 및 테스트
- ✅ 80% 미만 커버리지 감지 시 경고 발생
- ✅ agent-creator.md 사용하여 일관성 유지

---

### Priority 4: CI/CD Integration (1-3개월, Optional)

**Goal**: PR 자동 검증으로 머지 전 품질 보장

**Deliverables**:
1. **`.github/workflows/agent-validation.yml`** 작성
   ```yaml
   name: Agent Validation
   on: [pull_request]
   jobs:
     validate:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Run state-management-guard
           # Check Provider initialization order
         - name: Run ui-design-validator
           # Check ModernColors usage
         - name: Run code-quality-validator
           # Check dead code, smells
         - name: Run test-coverage-guard
           # Check 80%+ coverage
         - name: Block merge if critical issues
   ```

2. **Pre-commit hooks** (로컬 개발):
   ```bash
   # .husky/pre-commit
   flutter analyze
   dart format --set-exit-if-changed lib/
   # Run critical agents locally
   ```

3. **Performance Monitoring**:
   - Agent 활성화 빈도 로깅
   - False Positive 비율 추적
   - 민감도 임계값 조정

**Benefits**:
- PR 머지 전 자동 검증 (사람 리뷰 부담 감소)
- 빌드 브레이크 사전 방지
- 팀 전체 품질 표준 강제

**Success Criteria**:
- ✅ GitHub Actions 워크플로우 작동
- ✅ Critical 이슈 발견 시 머지 차단
- ✅ 30-50% 수동 리뷰 시간 감소

---

## 🎯 Actionable Implementation Plan

### Phase 1: Immediate Actions (Week 1-2)

**Week 1**:
1. ✅ **Day 1-2**: INTEGRATION_GUIDE.md 작성
   - Decision tree 다이어그램
   - 5가지 시나리오 예시 (UI 개발, Provider 추가, 버그 수정, 문서화, 게임 밸런스)
   - Handoff 패턴 정의

2. ✅ **Day 3-5**: Agent 설명 업데이트 (5개 파일)
   - description에 "Complements Role X" 추가
   - 각 Agent에 명확한 차별화 포인트 명시
   - 예시 시나리오 추가

**Week 2**:
3. ✅ **Day 1-3**: knowledge_base/ 폴더 + 4개 규칙 파일 작성
   - provider_rules.md (가장 중요!)
   - design_system_rules.md
   - game_balance_formulas.md
   - code_quality_standards.md

4. ✅ **Day 4-5**: Skills + Agents 참조 업데이트
   - 6 Skills 모두 지식 베이스 참조로 변경
   - 5 Agents 모두 지식 베이스 참조로 변경
   - CLAUDE.md에 "Knowledge Base" 섹션 추가

**Deliverables**:
- INTEGRATION_GUIDE.md
- knowledge_base/ 폴더 (4개 파일)
- 11개 파일 업데이트 (6 Skills + 5 Agents)

---

### Phase 2: Short-term Enhancements (Month 1)

**Week 3**:
5. ✅ **평가**: test-coverage-guard 추가 필요성 검토
   - 현재 테스트 커버리지 측정
   - 낮은 커버리지로 인한 버그 빈도 분석
   - ROI 계산 (구현 시간 vs 버그 감소)

6. ✅ **(조건부) 구현**: test-coverage-guard
   - agent-creator.md 사용하여 생성
   - Sonnet 4.5 기반 (품질 우선)
   - flutter test --coverage 통합

**Week 4**:
7. ✅ **검증**: 전체 시스템 통합 테스트
   - 5가지 시나리오 실제 실행
   - Agent 활성화 빈도 측정
   - False Positive 비율 확인

**Deliverables**:
- test-coverage-guard.md (조건부)
- 통합 테스트 보고서
- 성능 벤치마크 데이터

---

### Phase 3: Long-term Strategy (Month 2-3)

**Month 2**:
8. ✅ **CI/CD 설계**: GitHub Actions 워크플로우 작성
   - agent-validation.yml
   - 병렬 실행 최적화 (속도 vs 비용)
   - Critical vs Warning 분리

9. ✅ **Pre-commit Hooks**: 로컬 개발 환경 통합
   - Husky 설정
   - 빠른 Agent만 로컬 실행 (state-management-guard, ui-design-validator)
   - 느린 Agent는 CI에서만 실행 (code-quality-validator)

**Month 3**:
10. ✅ **Performance Monitoring**: 메트릭 수집 및 대시보드
    - Agent 활성화 로그
    - False Positive 추적
    - 민감도 임계값 자동 조정

11. ✅ **Documentation**: 최종 통합 문서
    - CI/CD 통합 가이드
    - 성능 최적화 가이드
    - 트러블슈팅 가이드

**Deliverables**:
- .github/workflows/agent-validation.yml
- .husky/pre-commit
- Performance dashboard
- CI/CD 통합 가이드

---

## 📈 Success Metrics

### Technical Metrics

1. **Provider 초기화 크래시**: 0건 (state-management-guard)
2. **레거시 색상 사용**: 신규 코드에서 0건 (ui-design-validator)
3. **테스트 커버리지**: 신규 기능 80%+ (test-coverage-guard, 조건부)
4. **Code Quality Score**: flutter analyze 0 errors, 0 warnings (code-quality-validator)
5. **False Positive 비율**: <10% (과도한 경고 방지)

### Process Metrics

1. **수동 코드 리뷰 시간**: 30-50% 감소 (Agent 자동 검증)
2. **버그 발견 단계**: 개발 중 80% vs 운영 중 20% (조기 발견)
3. **문서화 완성도**: 90%+ (documentation-specialist)
4. **CI/CD 통합**: PR당 평균 검증 시간 <5분

### Qualitative Metrics

1. **개발자 만족도**: "Agent가 도움이 된다" 80%+
2. **학습 곡선**: 새 개발자가 시스템 이해 <1일
3. **지식 부채**: 규칙 업데이트 1곳만 수정으로 완료
4. **팀 신뢰도**: "Agent 검증 통과 = 머지 안전" 인식 확립

---

## 💡 Key Insights

### 1. Skills와 Agents는 대체재가 아닌 보완재

**잘못된 접근**:
- Skills를 Agent로 1:1 변환
- Agent를 무한정 추가 (복잡도 증가)

**올바른 접근**:
- Skills: 전략적 사고, 복잡한 창작
- Agents: 반복적 오류 패턴 차단
- 상호 보완을 통한 Compound Intelligence

### 2. 품질 우선 철학 유지 (사용자 핵심 가치)

**사용자 피드백**: "속도보다 품질이 더 중요해"

**시스템 반영**:
- 모든 Agent를 Sonnet 4.5 기반으로 구축
- Extended Thinking 3-Phase 검증 패턴
- False Positive 최소화 (정밀한 패턴 매칭)

### 3. 점진적 개선 > 빅뱅 업그레이드

**추천하지 않음**:
- 한 번에 10개 Agent 추가
- 모든 Skill을 Agent로 전환

**추천**:
- Priority 1-4 단계적 로드맵
- ROI 높은 것만 선택적 추가 (test-coverage-guard)
- 지속적 측정 및 조정

### 4. 단일 진실 공급원 (knowledge_base/)

**문제**: Provider 규칙이 6 Skills + 5 Agents에 중복
**해결**: knowledge_base/ 폴더로 통합
**효과**: 규칙 변경 시 1곳만 수정, 일관성 보장

---

## 🚀 Next Steps (Immediate Action)

### This Week (Week 1)

1. **Monday-Tuesday**: INTEGRATION_GUIDE.md 작성
2. **Wednesday-Friday**: Agent 설명 업데이트 (5개 파일)

### Next Week (Week 2)

3. **Monday-Wednesday**: knowledge_base/ 폴더 + 4개 규칙 파일
4. **Thursday-Friday**: Skills + Agents 참조 업데이트

### Review Point (Week 2 End)

5. **전체 시스템 검증**:
   - INTEGRATION_GUIDE 명확성 테스트 (새 개발자에게 30분 설명)
   - knowledge_base 참조 정확성 확인
   - 5가지 시나리오 실제 실행

### Decision Point (Week 3)

6. **test-coverage-guard 추가 여부 결정**:
   - 현재 커버리지 데이터 분석
   - ROI 계산
   - Go/No-Go 결정

---

## 📚 References

### Key Documents

- **CLAUDE.md**: Sherpa App 전체 가이드
- **.claude/skills/**: 6개 Skill 정의
- **.claude/agents/**: 5개 Agent 정의
- **project/**: 프로젝트 문서 및 보고서

### Critical Rules (Quick Reference)

1. **Provider 초기화**: Level 0 → 1 → 2 → 3 (변경 금지)
2. **Quest Provider**: questProviderV2만 사용 (questProvider 금지)
3. **Design System**: ModernColors만 사용 (AppColors/RecordColors 금지)
4. **Sherpi 감정**: 컨텍스트-감정 매트릭스 준수
5. **Code Quality**: flutter analyze 0 errors, 0 warnings

### External Resources

- [Riverpod 2.4.9 Docs](https://riverpod.dev/)
- [Flutter 3.27.0 Docs](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [WCAG 2.1 AA](https://www.w3.org/WAI/WCAG21/quickref/)

---

## 🔄 Document Maintenance

**Review Cycle**: 월 1회 (매월 1일)
**Update Triggers**:
- 새 Agent 추가 시
- 새 Skill 추가 시
- 시스템 아키텍처 변경 시
- 성능 메트릭 목표 변경 시

**Version History**:
- v1.0.0 (2025-11-01): Initial strategy document

**Maintained by**: Claude Code + Sherpa App Development Team

---

**Document Status**: ✅ Complete - Ready for Implementation  
**Confidence Level**: High (Sequential Thinking 8-phase analysis)  
**Estimated Impact**: 현재 70% → 95% 시스템 완성도 (3개월)
