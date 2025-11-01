# Agent Usage Guide

Sherpa 앱 에이전트 시스템 사용 가이드

**Last Updated**: 2025-11-01
**Target Audience**: Developers, AI Assistants, Contributors

---

## 🎯 Quick Start

### 에이전트란?

Sherpa 앱의 **Agent (에이전트)**는 특정 도메인에 전문화된 자동 검증 도구입니다:

- ✅ **자동 실행**: 파일 변경 시 관련 에이전트가 자동으로 검증
- ✅ **깊이 있는 분석**: 3-5초 내 Extended Thinking 기반 검증 결과
- ✅ **품질 최우선**: Sonnet 4.5로 100% agentic coding 성능 (맥락 이해, 의존성 그래프 분석)
- ✅ **오류 제로 목표**: 사람이 놓칠 수 있는 미묘한 오류까지 사전 차단

---

## 📋 When to Use Which Agent

### 🚨 모든 요청 시 (최우선)

**Agent**: routing-orchestrator

**Use Cases**:
- **모든 사용자 요청** (예외 없음)
- 복잡도 분석 필요 시
- Skill vs Agent 결정 필요 시
- 실행 전략 수립 필요 시

**자동 트리거**:
```
모든 사용자 요청 → 자동 분석 시작
복잡도, 도메인, 파일 범위 평가
```

**수동 실행**:
```
"routing-orchestrator로 이 작업 분석해줘"
"복잡도 분석 먼저 해줘"
```

**분석 항목**:
1. ✅ 복잡도 점수 계산 (0.0-1.0: Low/Medium/High)
2. ✅ 도메인 분류 (UI/State/Game/Quality/Documentation/Architecture)
3. ✅ Skills vs Agents 결정
4. ✅ 실행 전략 수립 (순차/병렬/단일/다중)
5. ✅ Knowledge Base 자동 참조

**출력 예시**:
```markdown
## 🎯 작업 분석 결과

### 요청 분석
- 원문: "새 Provider 추가해줘"
- 복잡도: 0.8 (High)
- 도메인: State Management

### 라우팅 결정
- 선택: Role 1 (Architect) → Role 4 → Role 5
- 이유: Provider는 크래시 위험, 의존성 분석 필수
- 실행 전략: 순차 (의존성 있음)

### 실행 계획
1. Role 1: 전체 계획 (5분)
2. Role 4: 의존성 분석 (10분)
3. Role 5: 구현 (15분)
4. state-management-guard: 검증 (3초)
```

**⚠️ CRITICAL**: 모든 요청은 routing-orchestrator 분석을 거쳐야 함. 예외 없음!

---

### UI/UX 작업 시

**Agent**: ui-design-validator

**Use Cases**:
- 새 화면 구현
- 위젯 수정
- 색상 시스템 적용
- Sherpi 인터랙션 추가

**자동 트리거**:
```
lib/**/*screen*.dart 변경 → 자동 실행
lib/**/widgets/*.dart 변경 → 자동 실행
```

**수동 실행**:
```
"ui-design-validator로 디자인 시스템 검증해줘"
"Meeting 화면 디자인 체크"
```

**검증 항목**:
1. ✅ ModernColors 사용 (AppColors/RecordColors 금지)
2. ✅ Sherpi 감정-맥락 일치성
3. ✅ Material Design 3 원칙 (spacing, typography, shadows)
4. ✅ 색상 대비 비율 (WCAG 2.1 AA - 4.5:1)
5. ✅ 일관된 위젯 사용 (SherpaCleanAppBar, SherpaButton)

---

### State Management 작업 시

**Agent**: state-management-guard

**Use Cases**:
- 새 Provider 추가
- Provider 초기화 코드 수정
- 의존성 구조 변경
- questProvider 관련 작업

**자동 트리거**:
```
lib/shared/providers/*.dart 변경 → 자동 실행
lib/main.dart 변경 (Provider 초기화 부분) → 자동 실행
questProvider 감지 → 즉시 경고!
```

**수동 실행**:
```
"state-management-guard로 Provider 순서 검증"
"새 shopProvider Level 확인"
```

**검증 항목**:
1. ✅ Provider 초기화 순서 (Level 0 → 1 → 2 → 3)
2. ✅ questProviderV2 강제 (questProvider 절대 금지!)
3. ✅ 순환 의존성 차단
4. ✅ Provider Level 정확성

**⚠️ CRITICAL**: Provider 오류는 앱 크래시를 유발하므로 최우선 수정 필요!

---

### 코드 품질 개선 작업 시

**Agent**: code-quality-validator

**Use Cases**:
- 레거시 코드 정리 (dead code 제거)
- 리팩토링 전 분석
- 코드 리뷰 준비
- 중복 코드 통합
- 전체 품질 평가

**자동 트리거**:
```
lib/**/*.dart 변경 → 자동 실행 (모든 Dart 파일)
```

**수동 실행**:
```
"code-quality-validator로 코드 품질 검증해줘"
"코드 정리 필요한 부분 찾아줘"
"중복 코드 탐지해줘"
"dead code 찾아줘"
```

**검증 항목**:
1. ✅ Dead Code Detection (unused imports, functions, classes, unreachable code)
2. ✅ Code Correctness (null safety violations, type errors, resource leaks, error handling)
3. ✅ Code Smells (long methods >50 lines, large classes >500 lines, deep nesting >4 levels, magic numbers)
4. ✅ Code Duplication (exact duplicates, structural duplicates, similar patterns)
5. ✅ Code Quality (missing documentation, poor naming, formatting issues, high complexity, test coverage gaps)

**Sonnet 4.5 Benefits**:
- 코드베이스 전체 맥락 이해 후 dead code 판단 (의도적 플레이스홀더 vs 실제 dead code 구분)
- Multi-file 코드 사용 추적 (import부터 실제 호출까지 Long-horizon Context)
- 교차 파일 중복 패턴 종합 탐지 (Agentic Search)
- 복잡한 코드 패턴 분석 (Extended Thinking)

---

### 문서 작성/업데이트 작업 시

**Agent**: documentation-specialist

**Use Cases**:
- 작업 단계 정리 (Step-by-Step Guide)
- 작업 완료 후 문서 업데이트
- 변경사항 요약 (Summary & Changelog)
- 기술 문서 작성 (API, Architecture, Design docs)
- 사용자 가이드 작성 (Tutorials, FAQ, Troubleshooting)
- 릴리스 문서 (Release notes, Migration guides)

**수동 실행** (자동 트리거 없음):
```
"이번 작업 정리해줘"
"CLAUDE.md 업데이트 필요해"
"작업 완료 요약 작성해줘"
"changelog 추가해줘"
"Agent 사용 가이드 업데이트"
```

**문서 작성 원칙**:
1. ✅ 자연어 우선 (코드 예시 최소화 - 30% 이하)
2. ✅ 깔끔한 구조 (계층적 헤딩, 목록, 표)
3. ✅ 명확한 설명 (전문 용어는 설명과 함께)
4. ✅ 시각적 구성 (이모지, 구분선, 박스)
5. ✅ 실용적 내용 (실제 사용 가능한 정보)

---

### 새 에이전트 필요 시

**Agent**: agent-creator

**Use Cases**:
- 새로운 도메인 검증 에이전트 생성
- 기존 에이전트 패턴 분석
- 에이전트 시스템 확장

**수동 실행** (자동 트리거 없음):
```
"접근성 검증 에이전트 만들어줘"
"성능 최적화 validator 추가"
"게임 밸런스 검증 에이전트 생성"
```

**생성 프로세스**:
1. 요구사항 분석 (목적, 대상, 트리거, 출력)
2. 중복 확인 (기존 에이전트와 겹치지 않는지)
3. 설계 (Name, Description, Tools, Model)
4. 생성 (Agent Template 기반)
5. 지식베이스 업데이트 (Registry, Usage Guide)
6. 검증 (품질 기준 통과 확인)

---

## 🚀 Agent 사용 패턴

### Pattern 1: 자동 검증 (PROACTIVE)

**흐름**:
```
1. 코드 작성
2. 파일 저장 (Ctrl+S)
3. Claude Code가 관련 Agent 자동 실행
4. 검증 결과 확인
5. 오류 발견 시 수정
6. 재저장 → 재검증
```

**예시**:
```
파일: lib/features/meeting/screens/meeting_detail_screen.dart

코드 변경:
Container(color: AppColors.primaryBlue)  // ← 레거시 색상!

저장 →
ui-design-validator 자동 실행 →
🚨 오류 발견: AppColors 사용 금지!

수정:
Container(color: ModernColors.primary)  // ✅

재저장 →
ui-design-validator 재실행 →
✅ 검증 통과!
```

---

### Pattern 2: 수동 검증 (Manual)

**흐름**:
```
1. 특정 영역 검증 필요
2. 에이전트에게 명시적 요청
3. 검증 결과 확인
4. 필요시 수정
```

**예시**:
```
사용자: "ui-design-validator로 Meeting 화면 전체 검증해줘"

Agent 실행:
1. lib/features/meeting/screens/*.dart 스캔
2. ModernColors 사용 확인
3. Sherpi 감정 일치성 확인
4. Material Design 3 원칙 확인
5. 리포트 생성

결과:
✅ 5개 화면 검증 완료
⚠️ meeting_detail_screen.dart:120 - 낮은 색상 대비 발견
→ 수정 가이드 제공
```

---

### Pattern 3: 문서 작성 (Manual Documentation)

**흐름**:
```
1. 작업 완료 후 문서화 필요 인식
2. documentation-specialist에게 명시적 요청
3. 문서 초안 받기
4. 리뷰 및 피드백
5. 최종 문서 확정
```

**예시**:
```
사용자: "이번에 documentation-specialist 에이전트 만들었는데, 작업 정리해줘"

documentation-specialist 실행:
1. Phase 1 (Pre-Analysis):
   - 작업 내용 분석 (documentation-specialist.md 파일 생성)
   - 관련 문서 확인 (agent_registry.md, agent_usage_guide.md)
   - 문서 구조 전략 수립

2. Phase 2 (Structure Design):
   - 작업 완료 요약 템플릿 선택
   - 섹션 구성 (목표, 완료 작업, 성과, 관련 문서)

3. Phase 3 (Content Creation):
   - 자연어 위주 작성 (코드 예시 최소)
   - 명확한 표현으로 변경사항 설명
   - 이모지와 구분선으로 가독성 향상

결과:
✅ 작업 완료 요약 문서 생성
✅ agent_registry.md 업데이트
✅ agent_usage_guide.md 업데이트
```

---

### Pattern 4: Multi-Agent 협업

**흐름**:
```
1. 복잡한 작업 (여러 도메인 관련)
2. 여러 Agent가 순차/병렬 실행
3. 종합 결과 확인
```

**예시 1: 새 기능 추가**
```
작업: "새로운 Meeting 참여 기능 추가"

Agent 협업:
1. state-management-guard: Provider 의존성 분석
   → meetingParticipationProvider Level 2 결정

2. (구현 완료 후)

3. ui-design-validator: UI 디자인 검증
   → ModernColors 사용 확인
   → Sherpi 감정 적절성 확인

4. code-quality-validator: 코드 품질 검증
   → Dead code 확인
   → Code smells 식별
   → Duplication 탐지

5. state-management-guard: 최종 Provider 검증
   → 초기화 순서 확인
   → 순환 의존성 검사

6. documentation-specialist: 작업 문서화
   → 작업 완료 요약 작성
   → CLAUDE.md 업데이트 (새 기능 설명)
   → changelog 추가

결과:
✅ 모든 Agent 검증 통과 → 배포 가능
✅ 문서 업데이트 완료 → 팀 공유 가능
```

**예시 2: 대규모 리팩토링**
```
작업: "Quest 시스템 리팩토링 (God class 분리)"

Agent 협업:
1. code-quality-validator: 현재 상태 분석
   → quest_provider_v2.dart (850 lines, God class)
   → 중복 코드 7건 발견
   → Long methods 3건 발견

2. (리팩토링 진행: QuestGenerator, QuestValidator, QuestRewardService 분리)

3. code-quality-validator: 리팩토링 후 검증
   → 파일 크기 감소 확인 (850 → 200 lines)
   → 중복 제거 확인
   → Long methods 해소 확인

4. state-management-guard: Provider 구조 검증
   → 새 Provider 의존성 확인
   → Level 정확성 검증

5. ui-design-validator: UI 영향 확인
   → UI 일관성 유지 확인

6. documentation-specialist: 리팩토링 문서화
   → Before/After 비교 문서
   → Migration guide 작성
   → 아키텍처 문서 업데이트

결과:
✅ 코드 품질 향상, 유지보수성 개선 → 배포 가능
✅ 리팩토링 내용 문서화 완료 → 지식 공유
```

---

## 📊 Agent 출력 이해하기

### Success Output (정상)

```markdown
## 🎨 UI Design Validator - 검증 완료

### ✅ ModernColors 사용
- 레거시 색상 시스템 사용 없음 (0건)
- ModernColors import 정상

### ✅ Sherpi 감정-맥락 일치성
- 모든 Sherpi 인터랙션의 감정-맥락 호환 (10건 검증)
- 부적절한 감정 사용 없음

### ✅ UI 일관성
- SherpaCleanAppBar 사용 (5건)
- SherpaButton 사용 권장 준수

### ✅ 접근성
- WCAG 2.1 AA 색상 대비 기준 준수

**결론**: UI/UX 디자인 규칙 모두 준수 ✅
```

**해석**: 모든 검증 통과, 추가 작업 불필요

---

### Error Output (오류 발견)

```markdown
## 🚨 UI Design Validator - 오류 발견!

### ❌ 발견된 문제

**Priority 1 - CRITICAL (디자인 시스템 위반)**
- [ ] `lib/features/meeting/screens/meeting_detail_screen.dart:45` - 레거시 AppColors 사용
  ```dart
  import 'package:sherpa_app/core/theme/app_colors.dart';  // ❌
  Container(color: AppColors.primaryBlue)                  // ❌

  // ✅ 수정:
  import 'package:sherpa_app/core/theme/modern_colors.dart';
  Container(color: ModernColors.primary)
  ```

**Priority 2 - HIGH (감정-맥락 불일치)**
- [ ] `lib/features/meeting/screens/meeting_create_screen.dart:120` - 부적절한 Sherpi 감정
  ```dart
  showInstantMessage(
    context: SherpiContext.levelUp,       // 레벨업 맥락
    emotion: SherpiEmotion.sad,           // ❌ 슬픈 감정 부적절!
  );

  // ✅ 수정:
  showInstantMessage(
    context: SherpiContext.levelUp,
    emotion: SherpiEmotion.cheering,      // ✅ 환호하는 감정
  );
  ```

### 🔧 권장 수정 사항

1. **즉시 수정 (Priority 1)**:
   - `AppColors`, `RecordColors` → `ModernColors` 변경
   - Import 문도 함께 수정

2. **감정 조정 (Priority 2)**:
   - 감정-맥락 호환성 매트릭스 참조
   - 적절한 Sherpi 감정으로 변경

**⚠️ 주의**: Priority 1, 2는 디자인 일관성에 치명적이므로 즉시 수정 필요!
```

**해석**:
1. Priority 순서대로 수정 (CRITICAL → HIGH → MEDIUM → LOW)
2. 각 항목의 "✅ 수정" 부분 참조하여 코드 수정
3. 수정 후 재검증 (파일 저장 → 자동 실행)

---

## 🎓 Best Practices

### DO ✅

#### 1. PROACTIVE Agent 신뢰
```
파일 저장 후 자동 검증 결과 확인
→ 문제 조기 발견으로 디버깅 시간 절감
```

#### 2. Priority 순서 준수
```
CRITICAL: 앱 크래시, 디자인 시스템 위반 → 즉시 수정
HIGH: 주요 규칙 위반 → 빠른 시일 내 수정
MEDIUM: 일관성 부족 → 가능한 빨리 수정
LOW: 개선 사항 → 여유 있을 때 수정
```

#### 3. 정기적 전체 검증
```
주 1회: 모든 validator 수동 실행
→ "ui-design-validator로 전체 검증"
→ "state-management-guard로 Provider 전체 검증"
```

#### 4. 새 기능 전 검증
```
기능 구현 완료 → 관련 validator 실행 → 검증 통과 → 커밋
```

---

### DON'T ❌

#### 1. Agent 경고 무시
```
❌ "나중에 수정하지 뭐"
✅ 즉시 수정 (특히 CRITICAL/HIGH)
```

#### 2. Agent 비활성화
```
❌ Agent 자동 실행 끄기
✅ Agent가 거슬린다면 규칙 개선 요청
```

#### 3. 수동 검증만 의존
```
❌ "필요할 때만 Agent 실행"
✅ 자동 검증 + 정기 수동 검증 병행
```

#### 4. 검증 없이 커밋
```
❌ git add . && git commit (검증 없이)
✅ Agent 검증 통과 → git add . && git commit
```

---

## 🔧 Troubleshooting

### Q1: Agent가 자동 실행되지 않아요

**확인 사항**:
1. 파일 경로가 트리거 패턴과 일치하는가?
   - 예: `lib/features/meeting/screens/meeting_detail_screen.dart` (✅ 자동 실행)
   - 예: `docs/README.md` (❌ 트리거 패턴 불일치)

2. 파일을 실제로 저장했는가?
   - `Ctrl+S` 또는 `File → Save`

3. Claude Code가 파일 변경을 감지했는가?
   - 터미널에서 "File saved" 메시지 확인

**해결**:
- 수동 실행: "[agent-name]로 [파일/영역] 검증해줘"

---

### Q2: 검증 결과가 이해가 안 돼요

**확인 사항**:
1. Priority 레벨 확인
   - CRITICAL/HIGH는 즉시 수정 필요
   - MEDIUM/LOW는 여유 있을 때

2. "✅ 수정" 부분 참조
   - 각 오류마다 수정 방법 제공

3. 관련 문서 확인
   - `.claude/agents/[agent-name].md` - Agent 상세 가이드
   - `.claude/knowledge_base/` - 도메인별 규칙

**해결**:
- "이 오류가 무슨 뜻이야?" 질문
- Agent 상세 문서 읽기

---

### Q3: Agent가 너무 엄격해요

**이해**:
- Agent는 Sherpa 앱의 품질 기준을 지키기 위해 설계됨
- "엄격함"은 일관성과 안정성을 위한 것

**대응**:
1. **규칙이 잘못되었다면**: 규칙 개선 제안
2. **예외가 필요하다면**: 명시적으로 문서화
3. **Agent 자체 문제**: agent-creator에게 개선 요청

**잘못된 대응**:
- ❌ Agent 무시하고 진행
- ❌ 검증 기준 낮추기

---

### Q4: 새 Agent가 필요해요

**절차**:
1. agent-creator에게 요청
   ```
   "[도메인] 검증 에이전트 만들어줘"
   예: "접근성 검증 에이전트 만들어줘"
   ```

2. 요구사항 명확히 설명
   - 목적: 무엇을 검증하는가?
   - 대상: 어떤 파일들을 다루는가?
   - 트리거: 자동 실행 vs 수동만?

3. 생성된 Agent 테스트
   - 실제 코드에 적용
   - 검증 결과 확인

4. 피드백 제공
   - 너무 엄격/느슨하면 agent-creator에게 조정 요청

---

## 📚 Advanced Topics

### Agent 성능 최적화

**Sonnet 4.5 품질 최우선 전략**:
- **100% Agentic Coding 성능**: 코딩 작업에서 최고 품질
- **Extended Thinking**: 생각할 시간을 주면 더 정확한 판단 (3-phase validation)
- **Long-horizon Context**: Multi-file 컨텍스트 유지 (Provider 의존성 그래프, UI 일관성)
- **Agentic Search**: 교차 파일 패턴 분석 탁월 (레거시 코드 탐지, 순환 의존성)
- **Precise Instruction**: 명확한 지시를 정확히 따름 (Level 0→1→2→3 순서)

**성능 특성**:
- **속도**: ~3-5초 (Extended Thinking 포함, 충분한 분석 시간)
- **비용**: $0.006 per validation (품질 대비 합리적)
- **정확도**: 99-100% (맥락 이해 기반, 오류 허용 0%)

**왜 모든 Agent가 Sonnet 4.5를 사용하는가?**:
- ✅ **ui-design-validator**: Sherpi 감정-맥락 호환성은 단순 패턴 매칭으로 불가능
- ✅ **state-management-guard**: 순환 의존성 탐지는 Provider 관계 그래프 이해 필수
- ✅ **agent-creator**: 고품질 에이전트 생성은 복잡한 추론 필요

**사용자의 요구사항**: "나는 속도보다 품질이 더 중요해" → Sonnet 4.5 전면 채택

---

### Agent 커스터마이징

**Agent 설정 수정 (고급)**:
1. `.claude/agents/[agent-name].md` 읽기
2. 수정할 부분 식별
3. agent-creator에게 수정 요청
   ```
   "ui-design-validator의 색상 대비 기준을 3:1로 낮춰줘"
   ```
4. 변경 사항 리뷰
5. 승인 후 적용

**주의**: 직접 수정은 피하고 agent-creator를 통해 수정 권장

---

### Multi-Agent Workflow 설계

**복잡한 작업 예시**: "대규모 리팩토링"

```
Phase 1: 분석
→ state-management-guard: Provider 의존성 확인
→ ui-design-validator: 현재 UI 패턴 분석

Phase 2: 계획
→ agent-creator: 필요한 새 Agent 생성 (예: refactoring-validator)

Phase 3: 실행
→ (리팩토링 진행)

Phase 4: 검증
→ state-management-guard: Provider 순서 재확인
→ ui-design-validator: UI 일관성 재확인
→ refactoring-validator: 리팩토링 품질 확인

Phase 5: 완료
→ 모든 Agent 검증 통과 → 배포
```

---

## 📞 Support & Feedback

### Agent 관련 문의
- **기술 문의**: `.claude/agents/[agent-name].md` 참조
- **버그 리포트**: agent-creator에게 개선 요청
- **기능 제안**: 새 Agent 생성 요청

### 피드백 제공
```
"ui-design-validator가 [상황]에서 [문제] 발생"
"[새 도메인] 검증 Agent 추가 제안"
"Agent 검증 속도가 너무 느림 ([agent-name])"
```

### 업데이트 확인
- **Agent Registry**: `.claude/knowledge_base/agent_registry.md`
- **Usage Guide**: 이 문서
- **개별 Agent**: `.claude/agents/[agent-name].md`

---

## 🎯 Next Steps

### 초보자
1. ✅ 이 가이드 읽기 (완료!)
2. ✅ 파일 저장 시 Agent 자동 실행 경험
3. ✅ 검증 결과 읽고 이해하기
4. ✅ Priority 1, 2 오류 수정 연습

### 중급자
1. ✅ 수동으로 Agent 호출 연습
2. ✅ 정기적 전체 검증 습관화
3. ✅ Agent Registry 및 개별 Agent 문서 읽기
4. ✅ Multi-Agent 협업 이해

### 고급자
1. ✅ 새 Agent 생성 (agent-creator 활용)
2. ✅ Agent 커스터마이징
3. ✅ Multi-Agent Workflow 설계
4. ✅ Agent 성능 모니터링 및 최적화

---

**Usage Guide Version**: 1.0.0
**Last Updated**: 2025-11-01
**Next Review**: 2025-12-01
**Maintained by**: agent-creator
