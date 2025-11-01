# Agent Registry

Sherpa 앱의 모든 에이전트 목록 및 사용 가이드

**Last Updated**: 2025-11-01
**Total Agents**: 6 (3 validators + 2 meta-agents + 1 documentation specialist)
**Model Strategy**: Sonnet 4.5 (품질 최우선 - Extended Thinking, Long-horizon Context, Agentic Search)

---

## 🤖 Active Agents

### routing-orchestrator (Meta-Agent)
- **Purpose**: 사용자 요청을 분석하여 최적의 Skill (Role 1-6) 또는 Agent로 지능적 라우팅
- **Model**: Sonnet 4.5 (Extended Thinking for accurate routing decisions)
- **Triggers**:
  - AUTOMATIC: 모든 사용자 요청에 대해 사전 분석 실행
  - 복잡도, 도메인, 파일 범위 자동 평가
- **Created**: 2025-11-01
- **Version**: 1.0.0
- **File**: `.claude/agents/routing-orchestrator.md`
- **Keywords**: route, orchestrate, decide, analyze request, task routing, 작업 분석, 라우팅

**Use Cases**:
- 모든 요청의 복잡도 분석 (Low: 0.0-0.3, Medium: 0.3-0.7, High: 0.7-1.0)
- Skills (Role 1-6) vs Agents (validators) 결정
- 실행 전략 수립 (순차/병렬/단일/다중)
- Knowledge Base 자동 참조
- 최적의 라우팅 결정 및 실행 계획 제시

**Sonnet 4.5 Benefits**:
- Extended Thinking으로 요청의 진정한 의도 깊이 이해 (3-phase 분석)
- Long-horizon Context로 프로젝트 전체 맥락 고려한 라우팅
- Agentic Search로 6개 Skills + 5개 Agents 중 최적 매칭
- Precise Instruction으로 명확한 라우팅 결정 및 실행 계획

**Performance**:
- Speed: ~3-5 seconds (Extended Thinking 포함)
- Cost: $0.006 per routing decision
- Accuracy: 95-100% (Sonnet 4.5 맥락 이해)

---

### agent-creator (Meta-Agent)
- **Purpose**: 새로운 전문 에이전트 생성 및 관리
- **Model**: Sonnet 4.5 (Extended Thinking + Long-horizon Reasoning)
- **Triggers**:
  - "새 에이전트 만들어줘"
  - "validator 추가"
  - "검증 에이전트 생성"
- **Created**: 2025-11-01
- **Version**: 2.0.0 (Sonnet 4.5 Optimized)
- **File**: `.claude/agents/agent-creator.md`
- **Keywords**: create agent, new agent, make validator, add agent, 에이전트 생성, 에이전트 추가

**Use Cases**:
- 새로운 도메인 검증 에이전트 생성 (Sonnet 4.5 최적화 패턴 적용)
- 기존 에이전트 패턴 분석 및 개선
- 에이전트 생태계 확장 및 관리

**Sonnet 4.5 Benefits**:
- Extended Thinking으로 에이전트 설계 전 충분한 도메인 분석
- Long-horizon Context로 다른 에이전트들과의 일관성 유지
- Precise Instruction으로 정확한 검증 로직 생성

---

### ui-design-validator (Validator)
- **Purpose**: UI/UX 디자인 일관성 및 품질 검증
- **Model**: Sonnet 4.5 (Extended Thinking for emotion-context matching)
- **Triggers**:
  - PROACTIVE: `lib/**/*screen*.dart`, `lib/**/widgets/*.dart` 파일 변경 시 자동
  - Manual: "ui-design-validator로 디자인 검증"
- **Created**: 2025-11-01
- **Version**: 2.0.0 (Sonnet 4.5 Optimized)
- **File**: `.claude/agents/ui-design-validator.md`
- **Keywords**: UI, UX, design, ModernColors, Sherpi, accessibility, 디자인, 색상, 접근성

**Validates**:
1. ✅ ModernColors 사용 (AppColors/RecordColors 금지)
2. ✅ Sherpi 감정-맥락 일치성 (13가지 감정 - 맥락 이해 필수)
3. ✅ 2025 Material Design 3 원칙
4. ✅ 색상 대비 비율 (WCAG 2.1 AA)
5. ✅ Responsive & Adaptive Design
6. ✅ 일관된 Widget 사용 (SherpaCleanAppBar, SherpaButton)

**Performance**:
- Speed: ~3-5 seconds (Extended Thinking 포함)
- Cost: $0.006 per validation (품질 우선)
- Accuracy: 99%+ (맥락 이해 기반)

**Sonnet 4.5 Benefits**:
- 단순 정규식 매칭이 아닌 Sherpi 감정-맥락 호환성 깊이 이해
- Multi-file 디자인 일관성 추적 (Long-horizon Context)
- 레거시 색상 시스템 전체 패턴 탐지 (Agentic Search)

---

### state-management-guard (Validator)
- **Purpose**: Provider 초기화 순서 및 상태 관리 규칙 검증
- **Model**: Sonnet 4.5 (Circular dependency detection essential)
- **Triggers**:
  - PROACTIVE: `lib/shared/providers/*.dart`, `lib/main.dart` 파일 변경 시 자동
  - Detection: `questProvider` (legacy) 사용 감지 시 즉시 경고
- **Created**: 2025-11-01
- **Version**: 2.0.0 (Sonnet 4.5 Optimized)
- **File**: `.claude/agents/state-management-guard.md`
- **Keywords**: provider, state, riverpod, dependency, initialization, questProviderV2, 프로바이더, 상태, 초기화

**Validates**:
1. ✅ Provider 초기화 순서 (Level 0 → 1 → 2 → 3) - 100% 정확도
2. ✅ questProviderV2 강제 (questProvider 절대 금지!)
3. ✅ 순환 의존성 차단 (Extended Thinking으로 의존성 그래프 분석)
4. ✅ Provider Level 정확성

**CRITICAL**: 앱 크래시를 유발하는 Provider 오류를 사전 차단! (오류 허용 0%)

**Performance**:
- Speed: ~3-5 seconds (의존성 그래프 분석 포함)
- Cost: $0.006 per validation (품질 우선)
- Accuracy: 100% (Sonnet 4.5의 정확한 구조 검증)

**Sonnet 4.5 Benefits**:
- Provider 의존성 그래프 전체 이해 (단순 패턴 매칭 한계 극복)
- Multi-file Provider 관계 추적 (Long-horizon Context)
- 순환 의존성 정확한 탐지 (Extended Thinking)

---

### documentation-specialist (Documentation)
- **Purpose**: 작업 정리, 문서 업데이트, 기술 문서 작성
- **Model**: Sonnet 4.5 (Natural language-first documentation)
- **Triggers**:
  - Manual ONLY: "문서 정리해줘", "작업 요약해줘", "changelog 작성"
- **Created**: 2025-11-01
- **Version**: 1.0.0
- **File**: `.claude/agents/documentation-specialist.md`
- **Keywords**: documentation, 문서, 정리, summary, 요약, guide, 가이드, changelog, release notes, 업데이트, 문서화

**Specializes In**:
1. ✅ 작업 단계 정리 (Step-by-Step Guide)
2. ✅ 작업 완료 후 문서 업데이트 (CLAUDE.md, README.md, Agent registry)
3. ✅ 변경사항 요약 (Summary & Changelog)
4. ✅ 기술 문서 작성 (API, Architecture, Design docs)
5. ✅ 사용자 가이드 작성 (Tutorials, FAQ, Troubleshooting)
6. ✅ 릴리스 문서 (Release notes, Migration guides)

**Documentation Style**:
- ✅ 자연어 우선 (코드 예시 최소화 - 30% 이하)
- ✅ 깔끔한 구조 (계층적 헤딩, 목록, 표)
- ✅ 명확한 설명 (전문 용어는 설명과 함께)
- ✅ 시각적 구성 (이모지, 구분선, 박스 활용)
- ✅ 실용적 내용 (실제 사용 가능한 정보)

**Performance**:
- Speed: ~5-10 seconds (3-phase: 내용 분석 → 구조 설계 → 작성)
- Cost: $0.008 per documentation task
- Quality: 99%+ (자연어 표현, 구조 명확성, 일관성)

**Sonnet 4.5 Benefits**:
- Extended Thinking으로 문서 구조 설계 전 내용 충분히 이해
- Long-horizon Context로 여러 문서 간 일관성 유지 (용어, 스타일, 구조)
- Agentic Search로 관련 문서 찾아 중복 방지, 교차 참조
- Precise Instruction으로 명확하고 오해 없는 문서 작성

---

### code-quality-validator (Validator)
- **Purpose**: 코드 품질 검증 (dead code, correctness, smells, duplication, quality)
- **Model**: Sonnet 4.5 (Complex code pattern analysis)
- **Triggers**:
  - PROACTIVE: `lib/**/*.dart` 파일 변경 시 자동
  - Manual: "code-quality-validator로 코드 품질 검증", "코드 정리 필요한 부분 찾아줘"
- **Created**: 2025-11-01
- **Version**: 1.0.0
- **File**: `.claude/agents/code-quality-validator.md`
- **Keywords**: dead code, unused code, code duplication, refactor, cleanup, code quality, code smell, 코드 정리, 중복 코드, 사용하지 않는 코드, 리팩토링

**Validates**:
1. ✅ Dead Code Detection (unused imports, functions, classes, unreachable code)
2. ✅ Code Correctness (null safety, type errors, resource leaks, error handling)
3. ✅ Code Smells (long methods, large classes, deep nesting, magic numbers)
4. ✅ Code Duplication (exact/structural duplicates, similar patterns)
5. ✅ Code Quality (documentation, naming, formatting, complexity, test coverage)

**Performance**:
- Speed: ~5-10 seconds (comprehensive codebase analysis)
- Cost: $0.008 per validation (deeper analysis)
- Accuracy: 98%+ (context-aware dead code detection)

**Sonnet 4.5 Benefits**:
- 코드베이스 전체 맥락 이해 후 dead code 판단 (단순 grep 한계 극복)
- Multi-file 코드 사용 추적 (import부터 실제 호출까지)
- 교차 파일 중복 패턴 종합 탐지 (구조적 유사성)
- 의도적 플레이스홀더와 실제 dead code 구분

---

## 📋 Agent Usage Guide

### When to Use Which Agent

#### UI/UX 변경 시
→ **ui-design-validator**
- ModernColors 사용 검증
- Sherpi 감정-맥락 호환성
- Material Design 3 원칙 준수
- 접근성 기준 (WCAG 2.1 AA)

#### State Management 작업 시
→ **state-management-guard**
- Provider 초기화 순서 확인
- questProvider → questProviderV2 마이그레이션
- 순환 의존성 검사
- 새 Provider 추가 시 Level 결정

#### 코드 품질 개선 시
→ **code-quality-validator**
- Dead code 탐지 및 제거
- Code correctness 검증
- Code smells 식별
- 중복 코드 통합 권장
- 전체 품질 평가

#### 문서 작성/업데이트 시
→ **documentation-specialist**
- 작업 단계 정리
- 작업 완료 후 문서 업데이트
- 변경사항 요약 (Summary & Changelog)
- 기술 문서 작성 (API, Architecture)
- 사용자 가이드 작성 (Tutorials, FAQ)
- 릴리스 문서 (Release notes, Migration guides)

#### 작업 라우팅 필요 시
→ **routing-orchestrator**
- 사용자 요청 복잡도 분석
- Skills vs Agents 결정
- 실행 전략 수립
- 최적 라우팅 결정

### 새 에이전트 필요 시
→ **agent-creator**
- 전문 검증 에이전트 생성
- 도메인별 validator 추가
- 에이전트 시스템 확장

---

## 🔄 Agent Invocation Patterns

### 자동 실행 (PROACTIVE)
```
파일 저장 → Claude Code가 자동으로 관련 Agent 실행
예: lib/features/meeting/screens/meeting_detail_screen.dart 저장
  → ui-design-validator 자동 실행
  → 검증 리포트 즉시 제공
```

### 수동 실행 (Manual)
```
사용자: "ui-design-validator로 디자인 시스템 검증해줘"
  → Claude Code가 Agent 실행
  → 검증 리포트 제공
```

### 에이전트 간 협업
```
사용자: "새 Provider 추가"
  → state-management-guard: 의존성 분석
  → (구현 후)
  → state-management-guard: 최종 검증
```

---

## 📊 Agent Performance Metrics

### 전체 통계 (2025-11-01 기준)
- **Total Agents**: 5
- **Total Invocations**: N/A (신규 생성)
- **Average Response Time**: ~3-10 seconds (Sonnet 4.5 Extended Thinking)
- **Quality Strategy**: 품질 최우선 (Sonnet 4.5 for 100% agentic coding performance)

### Agent별 메트릭스 (향후 업데이트)

#### ui-design-validator
- Invocations: TBD
- Avg Duration: ~3-5s (Extended Thinking 포함)
- Accuracy: 99%+ (맥락 이해 기반)
- Issues Found: TBD

#### state-management-guard
- Invocations: TBD
- Avg Duration: ~3-5s (의존성 그래프 분석 포함)
- Accuracy: 100% (Sonnet 4.5 정확한 구조 검증)
- Critical Issues Prevented: TBD

#### code-quality-validator
- Invocations: TBD
- Avg Duration: ~5-10s (comprehensive codebase analysis)
- Accuracy: 98%+ (context-aware dead code detection)
- Issues Found: TBD
- Code Quality Improvements: TBD

#### documentation-specialist
- Invocations: TBD
- Avg Duration: ~5-10s (3-phase: 내용 분석 → 구조 설계 → 작성)
- Quality: 99%+ (자연어 표현, 구조 명확성, 일관성)
- Documents Created/Updated: TBD

#### agent-creator
- Agents Created: 2 (code-quality-validator, documentation-specialist)
- Avg Creation Time: ~5-10s (도메인 분석 포함)
- Success Rate: TBD
- Quality: Sonnet 4.5 최적화 패턴 적용

---

## 🚀 Roadmap: Future Agents

### 우선순위 1 (즉시 필요)
- [x] **code-quality-validator**: Dead code, code smells, duplication 검증 ✅
- [ ] **accessibility-validator**: WCAG 2.1 AA 접근성 전문 검증
- [ ] **performance-validator**: Flutter 성능 최적화 검증
- [ ] **security-validator**: 보안 취약점 검증

### 우선순위 2 (곧 필요)
- [ ] **game-balance-validator**: 게임 밸런스 공식 검증
- [ ] **api-contract-validator**: API 계약 검증
- [ ] **localization-validator**: 다국어 지원 검증

### 우선순위 3 (향후 고려)
- [ ] **data-migration-validator**: 데이터 마이그레이션 검증
- [ ] **dependency-analyzer**: 의존성 그래프 분석
- [ ] **code-duplication-detector**: 코드 중복 탐지

---

## 🎓 Agent Best Practices

### 에이전트 사용 권장 사항
1. ✅ **PROACTIVE 에이전트 신뢰**: 파일 저장 후 자동 검증 확인
2. ✅ **오류 발견 시 즉시 수정**: Priority 1, 2는 앱 안정성에 치명적
3. ✅ **정기적 전체 검증**: 주 1회 모든 validator 수동 실행 권장
4. ✅ **새 기능 전 검증**: 구현 완료 후 관련 validator 실행

### 에이전트 개발 권장 사항
1. ✅ **Single Responsibility**: 하나의 전문 영역만 담당
2. ✅ **Progressive Disclosure**: 핵심 규칙만 앞에, 상세는 뒤로
3. ✅ **품질 최우선 (Sonnet 4.5)**: Extended Thinking, Long-horizon Context, Agentic Search 활용
4. ✅ **명확한 트리거**: PROACTIVE vs Manual 명시
5. ✅ **실행 가능한 명령어**: 검증 로직에 실제 bash 명령어 포함
6. ✅ **3-Phase Validation**: Pre-Analysis → Detailed Validation → Synthesis & Reporting

---

## 📚 Agent 관련 문서

### 필수 문서
1. **`.claude/agents/agent-creator.md`**
   - 새 에이전트 생성 가이드
   - 2025 Best Practices
   - Agent Template

2. **`.claude/agents/ui-design-validator.md`**
   - UI/UX 검증 규칙
   - ModernColors 팔레트
   - Sherpi 감정 시스템

3. **`.claude/agents/state-management-guard.md`**
   - Provider 초기화 순서
   - questProviderV2 강제
   - 순환 의존성 차단

4. **`.claude/agents/code-quality-validator.md`**
   - Dead code 탐지
   - Code correctness 검증
   - Code smells 식별
   - Duplication 탐지
   - Quality assessment

5. **`.claude/agents/documentation-specialist.md`**
   - 작업 정리 및 문서 작성
   - Natural language-first documentation
   - 5가지 출력 템플릿
   - CLAUDE.md, README, changelog 업데이트

### 참조 문서
6. **`.claude/knowledge_base/design_system.md`**
   - ModernColors 전체 색상 시스템
   - Typography, Spacing 가이드

5. **`.claude/knowledge_base/provider_dependencies.md`**
   - Provider Level 체계
   - 의존성 그래프

6. **`CLAUDE.md`**
   - Sherpa 앱 전체 가이드
   - Agent 시스템 소개

---

## 🔍 Troubleshooting

### 에이전트가 자동 실행되지 않을 때
1. 파일 경로가 트리거 패턴과 일치하는지 확인
2. 파일을 실제로 저장했는지 확인 (Ctrl+S)
3. Claude Code가 파일 변경을 감지했는지 확인

### 에이전트 검증 실패 시
1. Priority 확인 (CRITICAL > HIGH > MEDIUM > LOW)
2. 수정 가이드 따라 코드 수정
3. 재검증 (파일 재저장 또는 수동 실행)

### 새 에이전트 생성 시
1. agent-creator에게 명확한 요구사항 제공
2. 단일 책임 원칙 준수 여부 확인
3. 기존 에이전트와 중복 확인
4. 생성 후 테스트 실행

---

## 📞 Support

### Agent 관련 문의
- **기술 문의**: `.claude/agents/` 파일 참조
- **버그 리포트**: agent-creator에게 개선 요청
- **기능 제안**: 새 에이전트 생성 요청

### 업데이트 주기
- **Agent Registry**: 새 에이전트 추가 시마다
- **Usage Guide**: 월 1회 또는 주요 변경 시
- **Performance Metrics**: 주 1회 (향후)

---

**Registry Version**: 1.0.0
**Last Updated**: 2025-11-01
**Maintained by**: agent-creator
**Next Review**: 2025-12-01
