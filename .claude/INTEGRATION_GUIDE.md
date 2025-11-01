# Integration Guide - Skills & Agents
## Sherpa App 개발을 위한 통합 가이드

**Document Version**: 1.0.0  
**Created**: 2025-11-01  
**Purpose**: Skills와 Agents를 언제, 어떻게 사용할지 명확한 가이드 제공

---

## 📋 Quick Reference

### Skills vs Agents 핵심 차이

| Aspect | Skills (수동) | Agents (자동) |
|--------|--------------|---------------|
| **호출 방법** | `"role1로 분석해줘"` 명시적 요청 | 파일 저장 시 자동 실행 |
| **목적** | 전략적 사고, 복잡한 창작 | 실시간 검증, 패턴 강제 |
| **타이밍** | 사전 계획 및 설계 | 사후 검증 및 가드 |
| **출력** | 계획서, 분석 보고서, 구현 코드 | 검증 보고서, 오류 목록 |
| **예시** | "아키텍처 설계해줘", "기능 구현해줘" | "Provider 초기화 순서 검증", "레거시 색상 감지" |

### 핵심 원칙

**✅ DO**:
- 복잡한 작업은 Skills로 시작 (특히 Role 1 Architect)
- 파일 저장 후 Agent 검증 결과 확인
- Agent 경고는 즉시 수정 (특히 Provider, 색상 관련)

**❌ DON'T**:
- Agent를 수동으로 호출하려고 시도 (자동 실행됨)
- Skills 없이 복잡한 기능 바로 구현
- Agent 경고 무시 (크래시 위험)

---

## 🌳 Decision Tree

```
사용자 요청
│
│ 🚨 필수: routing-orchestrator 자동 분석
│   - 복잡도 점수 계산 (0.0-1.0)
│   - 도메인 분류 (UI/State/Game/Quality/Documentation/Architecture)
│   - Skills vs Agents 결정
│   - 실행 전략 수립 (순차/병렬)
│
├─ routing-orchestrator 분석 결과
│
├─ 복잡도 High (0.7+)? → Role 1 (Architect Orchestrator)로 시작
│  │                          ↓
│  │                   Role 1이 다른 Role에 위임
│  │                          ↓
│  │                   Role 5가 구현
│  │                          ↓
│  │                   파일 저장 → Agent 자동 검증
│
├─ 복잡도 Medium (0.3-0.7)? → 도메인별 직접 라우팅
│  ├─ UI 도메인? → Role 3 (UI/UX Guardian)
│  ├─ State 도메인? → Role 4 (State Management Expert)
│  ├─ Game 도메인? → Role 2 (Game Logic Specialist)
│  ├─ Quality 도메인? → code-quality-validator
│  └─ Documentation 도메인? → Role 6 (QA Documentation)
│                          ↓
│                   Role 5가 구현
│                          ↓
│                   파일 저장 → Agent 자동 검증
│
└─ 복잡도 Low (0.0-0.3)? → 단순 작업
   ├─ 검증만? → Agent 자동 실행 (파일 저장 시)
   ├─ 문서화? → documentation-specialist
   └─ 바로 구현? → Role 5 (Fullstack Implementer)
                          ↓
                   파일 저장 → Agent 자동 검증
```

**⚠️ CRITICAL**: 모든 요청은 routing-orchestrator 분석을 먼저 거쳐야 함. 예외 없음!

---

## 📖 5가지 핵심 시나리오

### Scenario 1: UI 화면 신규 개발

**사용자 요청**: "미팅 상세 화면 새로 만들어줘"

**올바른 Flow**:

```
0️⃣ routing-orchestrator (자동) - 요청 분석
   자동 분석:
   - 복잡도: 0.5 (Medium)
   - 도메인: UI + State
   - 추천: Role 1 (Architect) → Role 3 → Role 4 → Role 5
   - 실행 전략: 순차 (의존성 있음)

1️⃣ Role 1 (Architect) - 전체 계획 수립
   "role1로 미팅 상세 화면 개발 계획 세워줘"

   출력:
   - Phase 1: UI/UX 분석 (Role 3 위임)
   - Phase 2: 상태 관리 설계 (Role 4 위임)
   - Phase 3: 구현 (Role 5 위임)
   - Phase 4: 테스트 및 문서화 (Role 6 위임)

2️⃣ Role 3 (UI/UX Guardian) - 디자인 시스템 확인
   "role3로 미팅 상세 화면 디자인 가이드 작성해줘"
   
   출력:
   - ModernColors 팔레트 (ModernColors.meeting.*)
   - Sherpi 감정 선택 (thoughtful, guiding 추천)
   - 레이아웃 패턴 (SherpaCard, SherpaButton)
   - 접근성 요구사항 (대비 4.5:1)

3️⃣ Role 5 (Fullstack Implementer) - 구현
   "role5로 미팅 상세 화면 구현해줘"
   
   작업:
   - lib/features/meetings/presentation/screens/meeting_detail_screen.dart 생성
   - ModernColors 사용
   - Sherpi 위젯 통합
   
   파일 저장 → 자동 검증 시작

4️⃣ ui-design-validator (Auto) - 실시간 검증
   자동 실행 내용:
   - ✅ ModernColors 사용 확인
   - ✅ Sherpi 감정-컨텍스트 호환성
   - ✅ Material Design 3 원칙 준수
   - ✅ 접근성 대비율 4.5:1 이상
   
   경고 발견 시: 즉시 수정

5️⃣ Role 6 (QA Documentation) - 테스트 및 문서
   "role6로 미팅 상세 화면 테스트 작성해줘"
   
   출력:
   - Given-When-Then 테스트 케이스
   - CHANGELOG 업데이트
```

**핵심 포인트**:
- Role 1으로 시작 → 다른 Role 위임 → Role 5 구현 → Agent 자동 검증
- Agent는 수동 호출 불필요 (파일 저장 시 자동)

---

### Scenario 2: Provider 추가

**사용자 요청**: "새로운 알림 Provider 추가해줘"

**올바른 Flow**:

```
0️⃣ routing-orchestrator (자동) - 요청 분석
   자동 분석:
   - 복잡도: 0.8 (High) ← Provider는 크래시 위험!
   - 도메인: State Management
   - 추천: Role 1 (Architect) → Role 4 → Role 5
   - 실행 전략: 순차 (의존성 분석 필수)

1️⃣ Role 4 (State Management Expert) - 의존성 분석
   "role4로 알림 Provider 추가 계획 세워줘"

   출력:
   - 의존성 분석: globalUserProvider (Level 1) 필요
   - Level 결정: Level 2 (사용자 데이터 의존)
   - 초기화 순서: questProviderV2 다음, sherpiProvider 이전
   - 파일 위치: lib/shared/providers/global_notification_provider.dart

2️⃣ Role 5 (Fullstack Implementer) - 구현
   "role5로 알림 Provider 구현해줘"
   
   작업:
   - global_notification_provider.dart 생성
   - Riverpod 2.4.9 @riverpod 어노테이션 사용
   - Level 1 Provider만 의존 (globalUserProvider)
   
   파일 저장 1 → global_notification_provider.dart
   
3️⃣ state-management-guard (Auto) - 첫 번째 검증
   자동 실행:
   - ✅ 파일 구조 확인
   - ✅ 순환 의존성 체크
   - ⚠️ main.dart 업데이트 필요 경고

4️⃣ main.dart 업데이트
   "_initializeProviders에 추가해줘"
   
   작업:
   ```dart
   // Level 2에 추가
   ref.read(questProviderV2);
   ref.read(globalMeetingProvider);
   ref.read(globalNotificationProvider);  // 새로 추가
   
   // Level 3
   ref.read(sherpiProvider);
   ```
   
   파일 저장 2 → main.dart

5️⃣ state-management-guard (Auto) - 두 번째 검증
   자동 실행:
   - ✅ Provider 초기화 순서 Level 0→1→2→3 확인
   - ✅ questProviderV2 사용 확인 (questProvider 아님)
   - ✅ 순환 의존성 없음
   - ✅ 모든 필수 Provider 초기화 포함
   
   결과: ✅ 검증 통과 → 안전
```

**핵심 포인트**:
- Role 4로 먼저 의존성 분석 (Level 결정)
- Role 5가 구현
- state-management-guard가 2번 실행 (Provider 파일, main.dart)
- 검증 통과 전까지 크래시 위험 존재

---

### Scenario 3: 버그 수정

**사용자 요청**: "로그인 후 포인트가 안 보여요"

**올바른 Flow**:

```
0️⃣ routing-orchestrator (자동) - 요청 분석
   자동 분석:
   - 복잡도: 0.7 (High) ← 버그 수정은 근본 원인 분석 필요
   - 도메인: State Management (추정)
   - 추천: Role 1 (Architect) → Role 4 → Role 5 → Role 6
   - 실행 전략: 순차 (원인 파악 → 수정 → 검증)

1️⃣ Role 1 (Architect) - 문제 분석 및 계획
   "role1로 포인트 표시 안 되는 문제 분석해줘"

   출력:
   - 문제 영역: 상태 관리 (Provider)
   - 분석 담당: Role 4 (State Management Expert)
   - 구현 담당: Role 5 (Fullstack Implementer)
   - 검증 담당: Role 6 (QA Documentation)

2️⃣ Role 4 (State Management Expert) - 근본 원인 분석
   "role4로 globalPointProvider 초기화 문제 분석해줘"
   
   분석:
   - main.dart _initializeProviders() 확인
   - globalPointProvider 초기화 순서 확인
   - 의존성 체인 추적
   
   발견:
   - ❌ globalPointProvider가 Level 1인데 Level 2 이후 초기화됨
   - 원인: 초기화 순서 잘못됨

3️⃣ Role 5 (Fullstack Implementer) - 수정
   "role5로 Provider 초기화 순서 수정해줘"
   
   작업:
   ```dart
   // Before (잘못됨)
   ref.read(globalUserProvider);
   ref.read(questProviderV2);
   ref.read(globalPointProvider);  // Level 2 위치에 있음 (잘못!)
   
   // After (올바름)
   ref.read(globalUserProvider);
   ref.read(globalPointProvider);  // Level 1 위치로 이동
   ref.read(questProviderV2);
   ```
   
   파일 저장 → main.dart

4️⃣ state-management-guard (Auto) - 자동 검증
   자동 실행:
   - ✅ Provider 초기화 순서 Level 0→1→2→3 확인
   - ✅ Level 1 (globalPointProvider)이 올바른 위치
   - ✅ 검증 통과
   
5️⃣ Role 6 (QA Documentation) - 테스트 및 문서화
   "role6로 테스트 케이스 작성하고 CHANGELOG 업데이트해줘"
   
   출력:
   - 테스트: 로그인 후 포인트 표시 확인
   - CHANGELOG: "Fixed: globalPointProvider initialization order"
```

**핵심 포인트**:
- 버그도 Role 1로 시작 (문제 분석)
- Role 4가 근본 원인 찾기
- Role 5가 수정
- Agent가 재발 방지 (순서 검증)

---

### Scenario 4: 문서화

**사용자 요청**: "새로운 미팅 시스템 사용법 문서 작성해줘"

**올바른 Flow**:

```
1️⃣ Role 6 (QA Documentation) - 문서 작성
   "role6로 미팅 시스템 사용법 문서 작성해줘"
   
   출력:
   - docs/meeting_system_guide.md 생성
   - 자연어 우선 (코드 예시 30% 이하)
   - 단계별 스크린샷 포함
   - FAQ 섹션
   
   파일 저장 → docs/meeting_system_guide.md

2️⃣ documentation-specialist (Auto) - 자동 검증
   자동 실행:
   - ✅ 자연어 비율 70% 이상 확인
   - ✅ 코드 예시 30% 이하 확인
   - ✅ 문서 구조 (제목, 섹션, 예시) 확인
   - ✅ 가독성 점수 계산
   
   제안:
   - 더 많은 시각 자료 추가 권장
   - 용어집 추가 권장

3️⃣ CLAUDE.md 업데이트 (필요 시)
   "CLAUDE.md에 미팅 시스템 섹션 추가해줘"
   
   작업:
   - CLAUDE.md에 Meeting System 섹션 추가
   - 핵심 참조 링크 추가
   
   파일 저장 → CLAUDE.md

4️⃣ documentation-specialist (Auto) - 두 번째 검증
   자동 실행:
   - ✅ CLAUDE.md 구조 일관성 확인
   - ✅ 내부 링크 유효성 확인
   - ✅ 코드 참조 정확성 확인
```

**핵심 포인트**:
- Role 6가 직접 문서 작성 (다른 Role 불필요)
- documentation-specialist가 품질 검증
- CLAUDE.md 업데이트도 자동 검증

---

### Scenario 5: 게임 밸런스 조정

**사용자 요청**: "레벨 10 이후 XP 획득이 너무 느려요. 조정해줘"

**올바른 Flow**:

```
1️⃣ Role 2 (Game Logic Specialist) - 밸런스 분석
   "role2로 레벨 10 이후 XP 밸런스 분석해줘"
   
   작업:
   - Python 시뮬레이터 실행
   ```bash
   cd .claude/skills/role2-game-logic-specialist/scripts
   python balance_simulator.py
   ```
   
   출력:
   - 현재 공식: Required XP = (level ^ 1.5) × 40 + (level × 20)
   - Level 10: 1,463 XP 필요
   - Level 20: 5,188 XP 필요
   - 문제: 지수 성장이 너무 가파름
   
   제안:
   - 공식 완화: Required XP = (level ^ 1.3) × 35 + (level × 15)
   - Level 10: 1,089 XP (25% 감소)
   - Level 20: 3,348 XP (35% 감소)

2️⃣ Role 5 (Fullstack Implementer) - 공식 수정
   "role5로 XP 공식 수정해줘"
   
   작업:
   ```dart
   // lib/shared/models/point_system_model.dart
   
   // Before
   static int calculateRequiredXp(int level) {
     return (pow(level, 1.5) * 40 + level * 20).round();
   }
   
   // After
   static int calculateRequiredXp(int level) {
     return (pow(level, 1.3) * 35 + level * 15).round();
   }
   ```
   
   파일 저장 → point_system_model.dart

3️⃣ code-quality-validator (Auto) - 자동 검증
   자동 실행:
   - ✅ Dead code 없음
   - ✅ 논리 오류 없음
   - ✅ Code smell 없음
   
4️⃣ Role 2 (Game Logic Specialist) - 재검증
   "role2로 수정된 공식 시뮬레이션해줘"
   
   작업:
   - Python 시뮬레이터 재실행
   - 1-50 레벨 성장 곡선 그래프 생성
   - 평균 플레이 시간 계산
   
   출력:
   - ✅ 성장 곡선 적절함
   - ✅ 레벨 20 도달 시간: 4주 → 2.6주 (35% 단축)
   - ✅ 밸런스 승인

5️⃣ Role 6 (QA Documentation) - 테스트 및 문서화
   "role6로 XP 공식 변경 테스트 작성해줘"
   
   출력:
   - 단위 테스트: calculateRequiredXp() 검증
   - CHANGELOG: "Adjusted: XP formula for smoother progression"
   - 시뮬레이션 결과 첨부
```

**핵심 포인트**:
- Role 2가 Python 시뮬레이터로 수학적 검증
- Role 5가 공식 수정
- Role 2가 재검증 (필수!)
- code-quality-validator가 코드 품질 검증

---

## 🔄 Handoff Patterns (Agent → Role 추천)

### Pattern 1: Agent가 이슈 발견 → Role 추천

**ui-design-validator 경고 예시**:
```
🚨 UI Design Validation Failed
- lib/features/home/presentation/screens/home_screen.dart:45
  ❌ Legacy color detected: AppColors.primaryBlue
  ✅ Recommended: ModernColors.primary

💡 Suggested Action: 
   "role3로 홈 화면 디자인 시스템 전환 계획 세워줘"
```

**Handoff Flow**:
1. Agent가 문제 발견 및 보고
2. 사용자가 해당 Role에게 계획 요청
3. Role이 전략적 솔루션 제시
4. Role 5가 구현
5. Agent가 재검증

---

### Pattern 2: Complex Issue → Role 1 Escalation

**state-management-guard 복잡한 경고 예시**:
```
🚨 Critical: Circular Dependency Detected
- globalUserProvider (Level 1) depends on questProviderV2 (Level 2)
- questProviderV2 (Level 2) depends on globalUserProvider (Level 1)

⚠️ This is a complex architectural issue.

💡 Suggested Action:
   "role1로 Provider 순환 의존성 해결 계획 세워줘"
```

**Handoff Flow**:
1. Agent가 복잡한 이슈 감지
2. Role 1 (Architect)에게 에스컬레이션 권장
3. Role 1이 전체 아키텍처 분석
4. Role 1이 다른 Role에 위임 (Role 4 → Role 5)
5. Agent가 최종 검증

---

### Pattern 3: Multiple Agents → Integrated Review

**여러 Agent 경고 동시 발생**:
```
파일 저장: lib/features/profile/presentation/screens/profile_screen.dart

🚨 ui-design-validator:
   - ❌ Legacy color: AppColors.background
   - ❌ Sherpi emotion mismatch: "cheering" for "warning" context

🚨 code-quality-validator:
   - ⚠️ Code smell: Function too long (150 lines)
   - ⚠️ Duplication: Similar code in settings_screen.dart

💡 Suggested Action:
   "role1로 프로필 화면 전체 리팩토링 계획 세워줘"
```

**Handoff Flow**:
1. 여러 Agent가 문제 발견
2. Role 1 (Architect)에게 통합 리뷰 요청
3. Role 1이 우선순위 결정 및 위임
4. Role 3 (디자인), Role 6 (품질) 순차 실행
5. Role 5가 통합 구현
6. 모든 Agent 재검증

---

## ❌ Common Anti-patterns

### Anti-pattern 1: Agent 수동 호출 시도

**잘못된 방법**:
```
"ui-design-validator로 홈 화면 검증해줘"
```

**문제**: Agent는 자동 실행 전용, 수동 호출 불가

**올바른 방법**:
```
1. 파일 수정
2. 파일 저장 → Agent 자동 실행
3. 검증 결과 확인
```

---

### Anti-pattern 2: Role 없이 복잡한 구현

**잘못된 방법**:
```
"새로운 챌린지 시스템 만들어줘" (바로 구현 요청)
```

**문제**: 계획 없이 구현하면 아키텍처 불일치, 테스트 누락

**올바른 방법**:
```
1. "role1로 챌린지 시스템 개발 계획 세워줘"
2. Role 1이 Phase → Task 분해
3. 각 Role에 위임 (Role 2, 3, 4, 5, 6)
4. Agent 자동 검증
```

---

### Anti-pattern 3: Agent 경고 무시

**잘못된 방법**:
```
state-management-guard: ❌ Provider 초기화 순서 잘못됨
사용자: "무시하고 계속 진행"
```

**문제**: 런타임 크래시 발생 (특히 Provider 관련)

**올바른 방법**:
```
1. Agent 경고 확인
2. 권장 Role에게 해결 요청
3. 문제 수정
4. Agent 재검증 통과 확인
```

---

### Anti-pattern 4: Skills만 사용 (Agent 미활용)

**잘못된 방법**:
```
1. "role5로 구현해줘"
2. 파일 저장하지 않고 계속 수정
3. Agent 검증 없이 커밋
```

**문제**: 레거시 색상, Provider 순서 오류 등 미발견

**올바른 방법**:
```
1. "role5로 구현해줘"
2. 파일 저장 → Agent 자동 검증
3. 경고 수정
4. 재검증 통과 후 커밋
```

---

### Anti-pattern 5: Agent만 사용 (Skills 미활용)

**잘못된 방법**:
```
복잡한 기능을 파일만 수정하고 저장
→ Agent 경고만 보고 수정 반복
```

**문제**: 전략 없이 반응적으로만 대응, 아키텍처 일관성 부족

**올바른 방법**:
```
1. Role 1/3/4로 먼저 계획 및 분석
2. Role 5로 계획대로 구현
3. Agent 검증으로 품질 보장
```

---

## 📊 Integration Effectiveness Metrics

### Success Indicators

**✅ Skills + Agents가 잘 통합된 경우**:
- Role 1으로 시작한 작업의 Agent 경고율 < 10%
- Agent 경고 후 즉시 수정 (재경고율 < 5%)
- 복잡한 작업의 계획 수립 비율 > 90%

**⚠️ 개선 필요한 경우**:
- Agent 경고 무시율 > 20%
- Skills 없이 바로 구현하는 비율 > 50%
- 반복적인 동일 경고 발생 (학습 부족)

### Quality Metrics

**목표**:
- Provider 크래시: 0건 (state-management-guard)
- 레거시 색상 사용: 0건 (ui-design-validator)
- Code smell 밀도: < 5% (code-quality-validator)
- 문서 커버리지: > 90% (documentation-specialist)

---

## 🔍 Troubleshooting

### Issue 1: "Agent가 실행 안 돼요"

**체크리스트**:
1. ✅ 파일을 실제로 저장했는지 확인
2. ✅ 해당 Agent의 트리거 경로에 맞는 파일인지 확인
   - ui-design-validator: `lib/features/**/presentation/**/*.dart`
   - state-management-guard: `lib/shared/providers/*.dart`, `lib/main.dart`
3. ✅ Agent 설명의 description 키워드와 일치하는지 확인

**해결**:
- 파일 경로가 트리거와 맞지 않으면 수동으로 해당 Role 호출

---

### Issue 2: "Agent 경고가 너무 많아요"

**원인**: Skills 없이 바로 구현했을 가능성 높음

**해결**:
1. 작업 중단
2. "role1로 [작업명] 계획 세워줘" 요청
3. 계획대로 다시 진행
4. Agent 경고 감소 확인

---

### Issue 3: "어떤 Role을 써야 할지 모르겠어요"

**해결**: 항상 Role 1 (Architect)로 시작

```
"role1로 [하고 싶은 작업] 계획 세워줘"
```

Role 1이 자동으로 적절한 Role에 위임합니다.

---

## 📚 Quick Command Reference

### Skills 호출 패턴

```
# 복잡한 작업 시작
"role1로 [작업명] 계획 세워줘"

# UI 분석/설계
"role3로 [화면명] 디자인 가이드 작성해줘"

# Provider 분석/설계
"role4로 [Provider명] 의존성 분석해줘"

# 게임 밸런스 검증
"role2로 [공식명] 밸런스 시뮬레이션해줘"

# 구현
"role5로 [기능명] 구현해줘"

# 테스트 및 문서화
"role6로 [기능명] 테스트 작성해줘"
```

### Agent 검증 확인

```
# 파일 저장 후
→ Agent 자동 실행 대기 (1-3초)
→ 검증 결과 확인
→ 경고 있으면 즉시 수정
→ 재검증 통과 확인
```

---

## 🎯 Best Practices Summary

### 1. 항상 계획부터 (Role 1)

복잡한 작업은 Role 1 (Architect)로 시작하여 전체 계획 수립

### 2. 파일 저장 습관화

구현 후 반드시 파일 저장 → Agent 자동 검증 활성화

### 3. Agent 경고 즉시 대응

특히 Provider, 색상 관련 경고는 크래시 위험 → 즉시 수정

### 4. 적절한 Role 선택

- 전략적 사고: Role 1, 3, 4
- 수학적 검증: Role 2
- 실제 구현: Role 5
- 품질 보증: Role 6

### 5. Skills + Agents = Compound Intelligence

둘 다 활용하여 최고의 결과 달성

### 6. Agent - Knowledge Base 연계 활용

**Pattern**: 모든 Agent는 `.claude/knowledge_base/` 디렉토리의 도메인 규칙을 자동 참조

**통합 현황** (2025-11-01 업데이트):
- ✅ **routing-orchestrator** → 모든 7개 knowledge_base 파일 (도메인별 자동 선택)
  - UI 요청 → `design_system.md`, `sherpi_ai_rules.md`
  - State 요청 → `provider_dependencies.md`, `architecture_rules.md`
  - Game 요청 → `game_balance_formulas.md`
  - 모든 요청 → `agent_registry.md`, `agent_usage_guide.md`
- ✅ **ui-design-validator** → `design_system.md`, `sherpi_ai_rules.md` (Extended Thinking Phase 1에서 자동 로드)
- ✅ **state-management-guard** → `provider_dependencies.md` (Level 0→1→2→3 순서 정의)
- ✅ **code-quality-validator** → `architecture_rules.md` (Feature-First 구조, 네이밍 규칙)
- ✅ **documentation-specialist** → 여러 knowledge_base 파일 참조
- ✅ **agent-creator** → 여러 knowledge_base 파일 참조

**Auto-Sync 동작 방식**:
1. Agent 실행 시 Extended Thinking Phase 1에서 knowledge_base 최신 내용 자동 로드
2. 검증 시 Single Source of Truth 원칙 준수 (규칙 중복 제거)
3. knowledge_base 업데이트 시 Agent 자동 반영 (수동 수정 불필요)

**이점**:
- **일관성**: Agent와 SKILL이 동일한 규칙 적용 (100% 일치)
- **유지보수**: knowledge_base만 수정하면 모든 Agent 자동 반영
- **확장성**: 새 규칙 추가 시 Agent 개별 수정 불필요

**예시**:
```markdown
# ui-design-validator 실행 시
Phase 1: Pre-Analysis
→ design_system.md 로드 (ModernColors 팔레트)
→ sherpi_ai_rules.md 로드 (6 감정 시스템)

Phase 2: Validation
→ 레거시 색상 감지 시 design_system.md의 ModernColors 매핑 적용
→ Sherpi 감정 검증 시 sherpi_ai_rules.md의 감정-컨텍스트 매트릭스 적용
```

---

**Document Status**: ✅ Complete  
**Last Updated**: 2025-11-01  
**Next Review**: 2025-12-01  
**Maintained by**: Sherpa App Development Team
