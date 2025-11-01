# Routing Orchestrator 사용 가이드

**문서 버전**: 1.0.0
**작성일**: 2025-11-01
**목적**: Routing Orchestrator Agent의 역할, 사용법, 라우팅 결정 로직 설명

---

## 📋 개요

**Routing Orchestrator**는 Sherpa 앱의 마스터 오케스트레이터 에이전트로, 사용자 요청을 분석하여 최적의 **Skill (Role 1-6)** 또는 **Agent (validator)**로 지능적으로 라우팅합니다.

### 핵심 역할
1. **요청 분석**: 복잡도, 도메인, 파일 범위, 예상 단계 수 분석
2. **Skills vs Agents 결정**: `.claude/INTEGRATION_GUIDE.md` 결정 트리 적용
3. **실행 전략 수립**: 순차 vs 병렬, 단일 vs 다중 호출 결정
4. **Knowledge Base 참조**: 도메인별 규칙 자동 로드
5. **품질 보증**: 라우팅 결정의 정확성 검증 (95-100%)

---

## 🎯 언제 사용하는가?

### 자동 활성화 (모든 요청)

**Routing Orchestrator**는 모든 사용자 요청에 대해 자동으로 사전 분석을 실행합니다.

**역할**:
- 요청 복잡도 평가
- 적절한 Skill/Agent 추천
- 실행 전략 제시

**예시**:
```
사용자: "미팅 상세 화면 새로 만들어줘"
→ Routing Orchestrator 자동 분석 시작
→ 복잡도: Medium (0.5)
→ 도메인: UI/UX (Primary), State Management (Secondary)
→ 라우팅: Role 1 (Architect) → Role 3 (UI/UX) → Role 5 (Fullstack) → ui-design-validator
```

---

## 📊 분석 프로세스 (3-Phase Extended Thinking)

### Phase 1: 요청 깊이 이해 (Think First)

#### Step 1: 요청 분해
```markdown
**원문**: [사용자 요청 원문]

**핵심 의도 파악**:
- 진짜 목표는 무엇인가?
- 왜 이 요청을 했는가?
- 성공 기준은 무엇인가?
```

#### Step 2: 복잡도 점수 계산
```markdown
**복잡도 요소** (각 0-1점):

1. 파일 수 (0-0.3점):
   - 1-2 파일: 0.1
   - 3-7 파일: 0.2
   - 8+ 파일: 0.3

2. 단계 수 (0-0.3점):
   - 1-2 단계: 0.1
   - 3-5 단계: 0.2
   - 6+ 단계: 0.3

3. 도메인 수 (0-0.2점):
   - 단일 도메인: 0.1
   - 다중 도메인 (2개): 0.15
   - 복합 도메인 (3개+): 0.2

4. 의존성 복잡도 (0-0.2점):
   - Provider 의존성 없음: 0.05
   - Provider 관련: 0.15
   - 순환 의존성 가능성: 0.2

**총 복잡도 점수**: [0.0 - 1.0]

**분류**:
- Low (0.0-0.3): 단순 작업
- Medium (0.3-0.7): 중간 복잡도
- High (0.7-1.0): 복잡한 작업
```

#### Step 3: 도메인 분류
```markdown
**Primary Domain**: [UI/State/Game/Quality/Documentation/Architecture]

**Domain Indicators**:

1. UI/UX (ui-design-validator, Role 3):
   - Keywords: 화면, screen, widget, 디자인, 색상, Sherpi, 버튼

2. State Management (state-management-guard, Role 4):
   - Keywords: Provider, 초기화, 상태, ref.read, ref.watch

3. Game Logic (Role 2):
   - Keywords: 밸런스, XP, 포인트, 레벨, 공식, 시뮬레이션

4. Code Quality (code-quality-validator):
   - Keywords: 리팩토링, 품질, dead code, 중복, code smell

5. Documentation (documentation-specialist, Role 6):
   - Keywords: 문서, 정리, changelog, 가이드, 설명

6. Architecture (Role 1):
   - Keywords: 계획, 설계, 아키텍처, 구조, 전체, 시스템
```

---

### Phase 2: Skills vs Agents 결정 (Decision Tree)

```markdown
**복잡도 High (0.7-1.0)**:
→ ✅ Role 1 (Architect) 시작

**복잡도 Medium (0.3-0.7)**:
→ 도메인별 직접 라우팅

**복잡도 Low (0.0-0.3)**:
→ 단일 Skill/Agent 직접 실행

**검증만 필요**:
→ 파일 저장 → Agent 자동 실행
```

---

### Phase 3: 실행 전략 및 라우팅 결정

#### 실행 전략 선택

```markdown
**순차 실행** (Sequential):
- 의존성 있는 작업
- Provider 관련 (순서 중요)
- 단계별 검증 필요

**병렬 실행** (Parallel):
- 독립적인 작업
- 다중 Agent 동시 실행
- 시간 단축 필요

**단일 호출** (Single):
- 복잡도 Low
- 명확한 단일 도메인

**다중 호출** (Multiple):
- 복잡도 High
- 여러 도메인
- 종합 검증 필요
```

---

## 📝 출력 형식

### 라우팅 결정 완료

```markdown
## 🎯 작업 분석 결과

### 📝 요청 분석
- **원문**: [사용자 요청]
- **핵심 의도**: [진짜 목표]
- **성공 기준**: [달성 조건]

### 📊 복잡도 분석
- **복잡도 점수**: [0.0-1.0] ([Low/Medium/High])
- **파일 수**: [개수] (점수: [0.0-0.3])
- **단계 수**: [개수] (점수: [0.0-0.3])
- **도메인 수**: [개수] (점수: [0.0-0.2])
- **의존성**: [없음/있음/복잡] (점수: [0.0-0.2])

### 🎨 도메인 분류
- **Primary Domain**: [UI/State/Game/Quality/Documentation/Architecture]
- **Secondary Domain**: [도메인] (해당 시)

### 🎯 라우팅 결정
- **선택**: [Skill/Agent 이름]
- **이유**:
  1. [Reason 1]
  2. [Reason 2]
- **실행 전략**: [순차/병렬/단일/다중]
- **Knowledge Base**: [파일들]

### 📋 실행 계획
[Phase별 상세 계획]

### 💰 예상 비용
- **Sonnet 4.5 호출**: [횟수]회
- **총 비용**: ~$[amount]

### ⏱️ 예상 소요 시간
- **총 시간**: [분/시간]
```

---

## 🎓 라우팅 예시

### 예시 1: 복잡한 UI 기능 추가

**사용자 요청**: "미팅 상세 화면 새로 만들어줘"

**Phase 1: 분석**
- 핵심 의도: 새 UI 화면 개발
- 복잡도 점수: 0.5 (Medium)
- 도메인: UI/UX (Primary), State (Secondary)

**Phase 2: 결정**
- 복잡도 Medium → 도메인별 직접 라우팅
- UI/UX 도메인 → Role 3 → Role 5 → ui-design-validator

**Phase 3: 실행 계획**
- Role 1: 전체 계획 (5분)
- Role 3: 디자인 가이드 (10분)
- Role 5: 구현 (20분)
- ui-design-validator: 자동 검증 (3초)
- 예상 시간: 35분
- 예상 비용: ~$0.02

---

### 예시 2: Provider 버그 수정

**사용자 요청**: "로그인 후 포인트가 안 보여요"

**Phase 1: 분석**
- 핵심 의도: 버그 수정 (분석 → 근본 원인 → 수정)
- 복잡도 점수: 0.8 (High)
- 도메인: State Management (Primary)

**Phase 2: 결정**
- 복잡도 High → Role 1 (Architect) 시작
- 이유: Provider 관련은 크래시 위험, 근본 원인 분석 필요

**Phase 3: 실행 계획**
- Role 1: 문제 분석 및 계획 (5분)
- Role 4: 근본 원인 분석 (10분)
- Role 5: 수정 (15분)
- state-management-guard: 자동 검증 (3초)
- Role 6: 테스트 및 문서화 (10분)
- 예상 시간: 40분
- 예상 비용: ~$0.03

---

### 예시 3: 단순 문서화

**사용자 요청**: "이번 작업 정리해줘"

**Phase 1: 분석**
- 핵심 의도: 작업 요약 문서 생성
- 복잡도 점수: 0.2 (Low)
- 도메인: Documentation (Primary)

**Phase 2: 결정**
- 복잡도 Low → 단일 Agent 직접 실행
- 선택: documentation-specialist

**Phase 3: 실행 계획**
- documentation-specialist: 작업 요약 작성 (5분)
- 예상 시간: 5분
- 예상 비용: ~$0.006

---

## 🎯 주요 특징 (Sonnet 4.5 최적화)

### Extended Thinking (생각할 시간)
- 요청의 진정한 의도 깊이 이해
- 3-phase 분석으로 정확도 95-100%
- 충분한 분석 시간 (3-5초)

### Long-horizon Context (장기 컨텍스트)
- 프로젝트 전체 맥락 고려
- 이전 작업 패턴 기억
- 일관된 라우팅 결정

### Agentic Search (교차 탐색)
- 6개 Skills + 6개 Agents 중 최적 매칭
- Knowledge Base 7개 파일 자동 참조
- 도메인별 규칙 적용

### Precise Instruction (명확한 지시)
- 명확한 라우팅 결정
- 구체적 실행 계획
- 예상 시간/비용 제시

---

## 📚 참고 문서

### 필수 참조
1. **`.claude/agents/routing-orchestrator.md`** (이 에이전트의 상세 가이드)
2. **`.claude/INTEGRATION_GUIDE.md`** (Skills vs Agents 결정 트리)
3. **`.claude/knowledge_base/agent_registry.md`** (Agent 목록)
4. **`.claude/skills/role1-architect-orchestrator/SKILL.md`** (Role 1 패턴)

### 도메인별 참조
5. **`.claude/knowledge_base/design_system.md`** (UI)
6. **`.claude/knowledge_base/provider_dependencies.md`** (State)
7. **`.claude/knowledge_base/game_balance_formulas.md`** (Game)
8. **`.claude/knowledge_base/architecture_rules.md`** (Architecture)

---

## 💡 Best Practices

### DO ✅
1. ✅ Routing Orchestrator의 분석 결과 확인
2. ✅ 복잡도 점수 및 라우팅 결정 이해
3. ✅ 실행 계획대로 진행
4. ✅ 예상 시간/비용 참고

### DON'T ❌
1. ❌ 라우팅 결정 무시하고 임의 진행
2. ❌ 복잡도 High인데 단일 Skill만 사용
3. ❌ Skills vs Agents 결정 트리 무시
4. ❌ Knowledge Base 참조 생략

---

## 🚨 Edge Cases

### 모호한 요청
- Extended Thinking으로 맥락 파악 시도
- 구체화 질문 제시
- 답변 후 재분석 → 라우팅

### 여러 해석 가능
- 가능한 해석 모두 고려
- 가장 가능성 높은 해석 선택 (Confidence: 70%+)
- Confidence < 80% 시 사용자 확인 요청

### 긴급 버그
- 복잡도 무시 → 즉시 Role 1 시작
- 우선순위: 안정성 > 품질 > 시간
- 빠른 분석 → 근본 원인 → 수정

---

**Guide Version**: 1.0.0
**Last Updated**: 2025-11-01
**Model**: Sonnet 4.5 (품질 최우선)
**Maintained for**: Sherpa App Intelligent Routing System
