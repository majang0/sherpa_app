# 셰르파 앱 멀티 에이전트 아키텍처 설계

## 📋 문서 개요

**목적**: 셰르파 앱의 고유한 특성에 최적화된 다중 에이전트 시스템 설계
**작성일**: 2025-10-30
**기반 모델**: Claude Sonnet 4.5
**총 에이전트 수**: 11개

---

## 🎯 설계 철학

셰르파 앱의 **4중 동기부여 엔진**을 효과적으로 지원하기 위한 전문화된 에이전트 팀:

1. **게임화 시스템** → Game Logic Analyst
2. **AI 성장 코치 (Sherpi)** → Sherpi AI Specialist
3. **소셜 모임** → Flutter/Firebase Specialist
4. **포인트 경제** → Point Economy Analyst

---

## 📊 기존 구조 평가

### 제안된 7개 에이전트 구조 분석

| 에이전트 | 평가 | 비고 |
|---------|------|------|
| Orchestrator | ✅ 적합 | 중앙 조율 역할 명확 |
| Architect | ✅ 적합 | 시스템 아키텍처 관리 |
| Game Logic Analyst | ✅ 매우 중요 | 셰르파 핵심 게임 로직 전담 |
| Flutter Specialist | ⚠️ 역할 과다 | UI 구현 + 디자인 시스템 관리는 과부하 |
| Firebase Specialist | ✅ 적합 | 백엔드 전담 |
| QA Engineer | ✅ 적합 | 품질 보증 |
| Documentation Specialist | ✅ 적합 | 문서화 |

### 🚨 중대한 누락 사항

1. **디자인 시스템 전문가 부재**
   - 문제: ModernColors 강제 규칙 준수 담당자 없음
   - 영향: 레거시 색상 시스템(AppColors/RecordColors) 사용 위험
   - 결과: 4중 동기부여 엔진의 시각적 일관성 저하

2. **Sherpi AI 전문가 부재**
   - 문제: AI 동반자는 셰르파의 핵심 차별화 요소
   - 영향: OpenAI/Gemini 통합, 감정 상태 관리가 분산됨
   - 결과: Sherpi 경험의 품질 저하

3. **State Management 전문가 부재**
   - 문제: 9개 글로벌 Provider의 엄격한 초기화 순서 관리 필요
   - 영향: Provider 의존성 그래프 오류 발생 위험
   - 결과: 앱 크래시 및 상태 동기화 문제

4. **Point Economy 전문가 부재**
   - 문제: 포인트 경제는 게임 로직과 별도의 비즈니스 로직
   - 영향: 출금, 수수료 정책 등 민감한 영역이 분산됨
   - 결과: 비즈니스 모델 영향 분석 어려움

---

## 🏗️ 최종 멀티 에이전트 구조 설계

### 계층 구조 (4 Tier)

```
Tier 1: 오케스트레이션 (1개)
  └─ Orchestrator

Tier 2: 도메인 전문가 (6개)
  ├─ Architect
  ├─ Design System Guardian ⭐ [신규]
  ├─ Game Logic Analyst
  ├─ Point Economy Analyst ⭐ [신규]
  ├─ Sherpi AI Specialist ⭐ [신규]
  └─ State Management Specialist ⭐ [신규]

Tier 3: 기술 구현자 (2개)
  ├─ Flutter Specialist [역할 조정]
  └─ Firebase Specialist

Tier 4: 품질 및 문서 (2개)
  ├─ QA Engineer
  └─ Documentation Specialist
```

---

## 📖 에이전트 상세 명세

### Tier 1: 오케스트레이션

#### 1. **Orchestrator** (팀 리더)

**역할**: 중앙 조율 및 워크플로우 관리

**핵심 책임**:
- 인간 개발자의 고수준 요청을 실행 계획으로 분해
- 각 하위 작업을 전문 에이전트에게 할당
- 작업 진행 상태 추적 및 관리
- 전문 에이전트들의 결과물 통합
- 최종 풀 리퀘스트 생성 및 인간에게 제출

**주요 Skills**:
- `ProjectPlanner`: 자연어 요구사항을 구조화된 작업 목록으로 변환
- `GitManager`: 브랜치 생성, 커밋, 풀 리퀘스트 생성 등 Git 워크플로우 자동화
- `WorkflowStateManager`: 작업 상태 추적 및 우선순위 관리

**Claude 기능**:
- 확장된 단계별 사고 (Extended Step-by-Step Thinking)
- 다중 도구 사용 오케스트레이션

**협업 패턴**:
- 모든 에이전트의 상위 관리자
- 에이전트 간 통신 중재
- 인간 승인 게이트 관리

---

### Tier 2: 도메인 전문가

#### 2. **Architect** (시스템 설계자)

**역할**: 시스템 아키텍처 설계 및 코드 품질 관리

**핵심 책임**:
- 요구사항 분석 및 시스템 아키텍처 설계
- 코드베이스 전체의 일관성 유지
- 프로젝트 지식 베이스(RAG) 관리 및 업데이트
- 기술 부채 식별 및 개선 계획 수립
- Feature-First 아키텍처 준수 감독

**주요 Skills**:
- `CodebaseAnalyzer`: 전체 코드베이스 분석, 의존성 맵 및 복잡도 리포트 생성
- `SchemaValidator`: Firebase 스키마 및 보안 규칙 유효성 검증
- `TechDebtDetector`: 기술 부채 식별 및 우선순위 분석
- `ArchitectureGuardian`: Feature-First 구조 준수 검증

**Claude 기능**:
- Claude Code (파일 읽기/분석)
- RAG (지식 베이스 검색)

**협업 패턴**:
- 모든 신규 기능 개발 전 아키텍처 검토
- Design System Guardian과 디자인 시스템 아키텍처 협의
- State Management Specialist와 Provider 구조 설계

**셰르파 특화 책임**:
- Feature-First 디렉토리 구조 유지 (`lib/features/`, `lib/shared/`, `lib/core/`)
- 9개 글로벌 Provider 아키텍처 감독

---

#### 3. **Design System Guardian** (디자인 시스템 수호자) ⭐ [신규]

**역할**: 셰르파 앱의 시각적 일관성 및 디자인 시스템 관리

**핵심 책임**:
- **ModernColors 강제 적용** (AppColors/RecordColors 사용 절대 금지)
- 4중 동기부여 엔진의 시각적 통합성 유지
- 디자인 토큰 관리 (색상, 타이포그래피, 스페이싱, 그림자)
- Flutter Widget 디자인 가이드라인 검증
- 애니메이션 일관성 관리 (Lottie, Confetti, flutter_animate)
- SherpaCleanAppBar, SherpaButton 등 표준 위젯 사용 강제

**주요 Skills**:
- `DesignTokenValidator`: ModernColors 사용 검증 및 강제
- `ColorUsageScanner`: 레거시 색상 시스템(AppColors/RecordColors) 사용 감지 및 경고
- `WidgetDesignGuide`: 표준 위젯 패턴 제공 (SherpaCleanAppBar, SherpaButton)
- `AnimationConsistencyChecker`: 애니메이션 스타일 일관성 검증
- `DesignSystemReporter`: 디자인 시스템 준수율 리포트 생성

**Claude 기능**:
- Image Input (디자인 시안 분석)
- Claude Code (색상 코드 검증 및 자동 수정)

**협업 패턴**:
- Flutter Specialist가 UI 구현 전 **디자인 승인 필수**
- Architect와 협업하여 디자인 시스템 아키텍처 유지
- QA Engineer에게 시각적 회귀 테스트 요청

**셰르파 특화 책임**:
- `lib/core/theme/modern_colors.dart` 강제 사용
- 게임화 UI (등반 화면, 레벨업 애니메이션) 일관성
- Sherpi 말풍선 디자인 표준화
- 소셜 모임 카드 디자인 통일
- 포인트 관련 UI (출금, 충전) 시각적 신뢰성 유지

**금지 사항**:
- ❌ `AppColors` 사용
- ❌ `RecordColors` 사용
- ❌ 하드코딩된 색상 값 (예: `Color(0xFF...)`)
- ❌ 비표준 위젯 (SherpaButton 대신 일반 Button 등)

---

#### 4. **Game Logic Analyst** (게임 기획 분석가)

**역할**: 셰르파의 게임화 시스템 전담 전문가

**핵심 책임**:
- **등반력 공식** 설계 및 최적화
- **5대 능력치 시스템** (체력, 집중력, 의지, 유연성, 균형) 밸런스
- **레벨업 경험치 곡선** 설계 및 시뮬레이션
- **뱃지 시스템** (장비 슬롯, 능력치 보너스) 관리
- 게임 밸런스 변경 시 사용자 성장 영향 분석
- 등반 성공 확률 시뮬레이션

**주요 Skills**:
- `SherpaGameLogic`: 등반력, 필요 경험치 등 핵심 공식 계산 (결정론적 라이브러리)
- `ClimbPowerSimulator`: 등반력 변경이 성공 확률에 미치는 영향 시뮬레이션
- `XpCurveOptimizer`: 레벨업 경험치 곡선 최적화
- `BadgeBalanceAnalyzer`: 뱃지 조합별 능력치 보너스 분석
- `UserGrowthPredictor`: 게임 로직 변경 시 사용자 성장 속도 예측

**Claude 기능**:
- Agent SDK (맞춤형 Skill 호출)
- 데이터 분석 및 시각화

**협업 패턴**:
- Point Economy Analyst와 게임 보상 밸런스 협의
- Architect에게 게임 로직 변경의 시스템 영향 검토 요청
- QA Engineer에게 밸런스 테스트 시나리오 제공

**셰르파 특화 책임**:
- `lib/shared/models/game_logic_model.dart` 관리
- 등반력 공식: `climbing_power = base_power + sum(stat_bonuses) + sum(badge_effects)`
- 레벨업 필요 XP 계산
- 일일/주간/프리미엄 퀘스트 난이도 설계

**Point Economy Analyst와의 차이점**:
- Game Logic: 게임 메커니즘 (XP, 레벨, 능력치, 등반 성공률)
- Point Economy: 비즈니스 로직 (포인트 획득/소모, 출금, 수수료)

---

#### 5. **Point Economy Analyst** (포인트 경제 분석가) ⭐ [신규]

**역할**: 셰르파의 포인트 경제 시스템 및 비즈니스 모델 관리

**핵심 책임**:
- 포인트 획득/소모 밸런스 분석 및 최적화
- **출금 정책** 관리 (최소 10,000p, 수수료 10%)
- **가입 보너스** (3,000p) 및 각종 보상 정책 검증
- **모임 수수료** 관리 (무료 모임 1,000p, 유료 모임 5%)
- 포인트 경제 시뮬레이션 (사용자 행동 시나리오)
- 비즈니스 모델 영향 분석 (수익/지출 예측)

**주요 Skills**:
- `PointBalanceSimulator`: 포인트 경제 전체 시뮬레이션 (유입/유출 분석)
- `WithdrawalPolicyValidator`: 출금 정책 준수 검증 (최소 금액, 수수료 계산)
- `EconomyHealthChecker`: 포인트 경제 건강도 분석 (인플레이션/디플레이션 감지)
- `BusinessImpactAnalyzer`: 정책 변경 시 비즈니스 영향 분석
- `RewardOptimizer`: 보상 정책 최적화 (사용자 참여 vs 비용)

**Claude 기능**:
- Agent SDK (맞춤형 Skill 호출)
- 데이터 분석 및 재무 시뮬레이션

**협업 패턴**:
- Game Logic Analyst와 게임 보상 밸런스 협의
- Firebase Specialist와 포인트 트랜잭션 스키마 설계
- Architect에게 포인트 정책 변경의 시스템 영향 검토 요청

**셰르파 특화 책임**:
- `lib/shared/models/point_system_model.dart` 관리
- PointSource별 획득 포인트 정의 (퀘스트, 모임, 레벨업 등)
- PointSpendType별 소모 포인트 정의 (모임 참여, 챌린지, 부스트 등)
- 포인트-원 환율 관리 (1p = 1원)
- 출금 수수료 정책 (10%) 및 최소 출금액 (10,000p) 검증

**Game Logic Analyst와의 차이점**:
| 구분 | Game Logic Analyst | Point Economy Analyst |
|------|-------------------|----------------------|
| 영역 | 게임 메커니즘 | 비즈니스 로직 |
| 주요 관심사 | XP, 레벨, 능력치, 등반 성공률 | 포인트, 출금, 수수료, 보상 정책 |
| 목표 | 게임 재미 및 밸런스 | 비즈니스 지속 가능성 |
| 예시 | "레벨 10까지 필요한 XP는?" | "월간 출금액이 수익을 초과하는가?" |

---

#### 6. **Sherpi AI Specialist** (Sherpi AI 전문가) ⭐ [신규]

**역할**: 셰르파의 핵심 AI 동반자 'Sherpi' 관리 전문가

**핵심 책임**:
- Sherpi AI 동반자의 **맥락 기반 메시지 생성**
- **감정 상태(SherpiEmotion)** 관리 및 전환 로직
- OpenAI/Gemini API 통합 및 **프롬프트 최적화**
- **Static vs AI 메시지 하이브리드 전략** 관리
- **사용자 맥락(SherpiContext)** 분석 및 적절한 메시지 선택
- Sherpi 성격 일관성 유지 (친근하고 격려하는 성장 코치)

**주요 Skills**:
- `SherpiMessageGenerator`: 맥락 기반 메시지 생성 (OpenAI/Gemini API 호출)
- `EmotionTransitionLogic`: 감정 상태 전환 규칙 (normal → cheering → proud 등)
- `PromptOptimizer`: AI API 프롬프트 최적화 (토큰 효율성, 응답 품질)
- `ContextAnalyzer`: 사용자 행동 패턴 분석 (레벨업, 퀘스트 완료, 등반 성공 등)
- `SherpiPersonalityGuardian`: Sherpi 성격 일관성 검증

**Claude 기능**:
- Agent SDK (AI API 통합)
- 자연어 생성 및 프롬프트 엔지니어링

**협업 패턴**:
- Design System Guardian과 Sherpi 말풍선 디자인 협의
- State Management Specialist와 감정 상태 관리 최적화
- QA Engineer에게 다양한 맥락 테스트 요청

**셰르파 특화 책임**:
- `lib/core/ai/managers/openai_sherpi_manager.dart` 관리
- `lib/core/ai/managers/static_sherpi_manager.dart` 관리 (Static 메시지 fallback)
- `lib/shared/providers/global_sherpi_provider.dart` 최적화
- SherpiEmotion 종류: normal, cheering, proud, thinking, surprised, concerned
- SherpiContext 종류: levelUp, questComplete, climbSuccess, meeting, dailyGoal 등

**API 관리**:
```dart
// Static 메시지 (즉시 표시, AI 호출 없음)
showInstantMessage(context, customDialogue, emotion, duration)

// 맥락 기반 메시지 (Static 또는 AI, 내부 로직에 따라)
showMessage(context, userContext, gameContext)

// 게임 특화 메시지
showGameMessage(context, gameData)

// 메시지 숨기기
hideMessage()

// 감정 상태 변경
changeEmotion(SherpiEmotion emotion)
```

**성격 가이드라인**:
- ✅ 긍정적이고 격려하는 톤
- ✅ 사용자의 성장을 축하
- ✅ 구체적인 피드백 제공
- ❌ 비판적이거나 부정적인 표현 금지
- ❌ 과도한 칭찬 (신뢰성 저하)

---

#### 7. **State Management Specialist** (상태 관리 전문가) ⭐ [신규]

**역할**: Riverpod 기반 상태 관리 및 Provider 의존성 관리

**핵심 책임**:
- **9개 글로벌 Provider 초기화 순서** 관리 및 검증
- **Provider 의존성 그래프** 검증 (순환 참조 방지)
- Riverpod 2.4.9 **베스트 프랙티스** 적용
- 상태 동기화 문제 해결 (여러 Provider 간 데이터 일관성)
- `main.dart`의 Provider 초기화 코드 최적화
- Provider 성능 모니터링 (불필요한 재빌드 방지)

**주요 Skills**:
- `ProviderDependencyValidator`: Provider 초기화 순서 검증
- `RiverpodPatternEnforcer`: Riverpod 패턴 강제 (StateNotifier, FutureProvider 등)
- `StateConflictDetector`: 상태 충돌 감지 (동시 수정, 데이터 불일치)
- `ProviderPerformanceAnalyzer`: Provider 재빌드 분석 및 최적화
- `DependencyGraphVisualizer`: Provider 의존성 그래프 시각화

**Claude 기능**:
- Claude Code (코드 분석 및 수정)
- 데이터 흐름 분석

**협업 패턴**:
- Architect와 Provider 구조 설계 협의
- Flutter Specialist에게 Provider 사용 패턴 가이드 제공
- QA Engineer에게 상태 관리 테스트 시나리오 제공

**셰르파 특화 책임**:
- `lib/main.dart`의 Provider 초기화 순서 엄격 관리:

```dart
// 반드시 이 순서대로 초기화해야 함
ref.read(globalGameProvider);           // Level 0
ref.read(globalUserProvider);           // Level 1
ref.read(globalPointProvider);          // Level 2
ref.read(globalUserTitleProvider);      // Level 2
ref.read(questProviderV2);              // Level 2 (주의: questProvider 아님!)
ref.read(globalMeetingProvider);        // Level 2
ref.read(sherpiProvider);               // Level 3
ref.read(relationshipProvider);         // Level 3
ref.read(emotionAnalysisProvider);      // Level 3
```

**Provider 의존성 그래프**:
```
Level 0: globalGameProvider
         ↓
Level 1: globalUserProvider
         ↓
Level 2: globalPointProvider, questProviderV2, globalMeetingProvider, globalUserTitleProvider
         ↓
Level 3: sherpiProvider, relationshipProvider, emotionAnalysisProvider
```

**검증 규칙**:
- ✅ 상위 레벨 Provider는 하위 레벨 Provider를 참조할 수 있음
- ❌ 하위 레벨 Provider는 상위 레벨 Provider를 참조할 수 없음
- ❌ 같은 레벨 내에서 순환 참조 금지
- ✅ `questProviderV2` 사용 (레거시 `questProvider` 사용 금지)

---

### Tier 3: 기술 구현자

#### 8. **Flutter Specialist** (프론트엔드 개발자) [역할 조정]

**역할**: Flutter 기반 UI 구현 전문가 (디자인 시스템 관리는 Design System Guardian에게 위임)

**핵심 책임**:
- Flutter Widget 및 Dart 코드 생성, 리팩토링, 디버깅
- **Design System Guardian의 승인을 받은 디자인 구현**
- 상태 관리 패턴 적용 (Riverpod 2.4.9)
- 반응형 레이아웃 구현 (모바일 중심)
- 애니메이션 구현 (flutter_animate, Lottie, Confetti)

**주요 Skills**:
- `WidgetGenerator`: Design System Guardian이 제공한 표준 위젯 템플릿 기반 생성
- `StateManagementHelper`: Riverpod 상태 관리 패턴 적용
- `ResponsiveLayoutBuilder`: 반응형 레이아웃 구현
- `AnimationImplementor`: 애니메이션 효과 구현

**Claude 기능**:
- Claude Code (코드 생성/수정)
- Image Input (디자인 시안 분석) - Design System Guardian과 공유

**협업 패턴**:
- **Design System Guardian에게 UI 구현 전 디자인 승인 필수**
- State Management Specialist로부터 Provider 사용 패턴 가이드 수신
- Firebase Specialist와 API 연동
- QA Engineer에게 위젯 테스트 요청

**셰르파 특화 책임**:
- Feature-First 구조 준수 (`lib/features/[feature_name]/presentation/`)
- ModernColors 사용 (Design System Guardian 검증 통과)
- 표준 위젯 사용 (SherpaCleanAppBar, SherpaButton)
- Riverpod Provider 사용 (State Management Specialist 가이드 준수)

**기존 역할과의 차이점**:
- **이전**: UI 구현 + 디자인 시스템 관리 (과부하)
- **조정 후**: UI 구현만 집중 (디자인 시스템은 Design System Guardian)

---

#### 9. **Firebase Specialist** (백엔드 개발자)

**역할**: Firebase 기반 백엔드 개발 및 인프라 관리

**핵심 책임**:
- Firebase Functions 작성 및 배포 (TypeScript/JavaScript)
- Firestore 데이터베이스 스키마 설계 및 관리
- Firebase 보안 규칙 구성 (Authentication, Firestore, Storage)
- Cloud Functions 배포 자동화
- 백엔드 API 엔드포인트 설계 및 구현

**주요 Skills**:
- `FunctionDeployer`: Firebase Functions 배포 자동화
- `FirestoreSchemaManager`: Firestore 스키마 마이그레이션 및 관리
- `SecurityRuleValidator`: Firebase 보안 규칙 유효성 검증
- `BackendAPIDesigner`: RESTful API 설계 및 문서화

**Claude 기능**:
- Claude Code (서버사이드 코드 작성)
- 터미널 도구 사용 (Firebase CLI)

**협업 패턴**:
- Architect에게 데이터베이스 스키마 설계 검토 요청
- Flutter Specialist에게 API 명세 제공
- Point Economy Analyst와 포인트 트랜잭션 스키마 설계
- QA Engineer에게 API 테스트 요청

**셰르파 특화 책임**:
- Firestore 컬렉션 관리: users, meetings, quests, points, badges 등
- Firebase Authentication 설정
- Cloud Functions 배포 (`functions/` 디렉토리)
- 보안 규칙 엄격 관리 (최소 권한 원칙)

---

### Tier 4: 품질 및 문서

#### 10. **QA Engineer** (품질 보증 엔지니어)

**역할**: 테스트 자동화 및 품질 보증

**핵심 책임**:
- 단위 테스트, 위젯 테스트, 통합 테스트 코드 생성
- E2E 테스트 시나리오 작성 및 실행
- 버그 리포트 생성 및 재현 테스트 자동화
- 테스트 커버리지 관리 (80% 이상 목표)
- 회귀 테스트 자동화

**주요 Skills**:
- `TestGenerator`: 코드 또는 명세 기반 테스트 케이스 자동 생성
- `MockDataFactory`: 테스트용 모의 데이터 생성
- `E2EScenarioBuilder`: E2E 테스트 시나리오 작성
- `BugReproducer`: 버그 리포트 기반 재현 테스트 자동 생성

**Claude 기능**:
- Claude Code (테스트 코드 작성)
- Claude Desktop (GUI 테스트 실행)

**협업 패턴**:
- 모든 에이전트로부터 테스트 요청 수신
- Architect에게 테스트 결과 및 품질 리포트 제출
- Design System Guardian에게 시각적 회귀 테스트 결과 제공

**셰르파 특화 책임**:
- Provider 초기화 순서 테스트
- 게임 밸런스 테스트 (등반력, XP, 레벨업)
- Sherpi AI 메시지 맥락 테스트
- 포인트 경제 시뮬레이션 테스트
- 4중 동기부여 엔진 통합 테스트

**테스트 우선순위**:
1. 🔴 High: Provider 초기화, 포인트 트랜잭션, 출금 로직
2. 🟡 Medium: 게임 밸런스, Sherpi AI, 소셜 모임
3. 🟢 Low: UI 애니메이션, 디자인 일관성

---

#### 11. **Documentation Specialist** (문서화 담당자)

**역할**: 기술 문서 자동 생성 및 유지보수

**핵심 책임**:
- 개발 프로세스 관찰 및 README, API 문서, 코드 주석 자동 생성
- 변경 로그(CHANGELOG) 자동 업데이트
- API 문서 생성 (OpenAPI/Swagger)
- 코드 내 Docstring 주석 생성
- 프로젝트 Wiki 관리

**주요 Skills**:
- `DocstringWriter`: 함수 시그니처 분석 후 표준 형식 주석 생성
- `ChangelogUpdater`: 커밋 메시지 분석 후 변경 로그 자동 업데이트
- `APIDocGenerator`: API 명세 기반 문서 자동 생성
- `READMEMaintainer`: README 섹션 자동 업데이트

**Claude 기능**:
- Claude Code (파일 읽기/쓰기)
- 자연어 생성

**협업 패턴**:
- 모든 에이전트의 결과물 관찰 및 문서화
- Architect에게 아키텍처 문서 검토 요청
- Design System Guardian에게 디자인 가이드 문서 작성

**셰르파 특화 책임**:
- `CLAUDE.md` 업데이트 (Claude Code를 위한 프로젝트 가이드)
- `README.md` 유지보수
- API 엔드포인트 문서화
- 포인트 경제 정책 문서화
- 게임 밸런스 공식 문서화

---

## 🔄 에이전트 협업 패턴

### Pattern 1: 신규 기능 개발 (예: 길드 시스템)

```
1. Orchestrator
   └─ 사용자 요청 분석 및 작업 계획 수립

2. Architect
   └─ 시스템 아키텍처 설계
   └─ RAG로 기존 소셜 모임 문서 검색
   └─ 기술 명세서, DB 스키마, API 계약서 작성

3. Design System Guardian
   └─ 길드 관련 UI 디자인 승인
   └─ 길드 카드, 뱃지 디자인 표준 제공
   └─ ModernColors 사용 가이드

4. State Management Specialist
   └─ 길드 관련 Provider 설계
   └─ 기존 Provider와 의존성 관계 정의

5. 병렬 작업
   ├─ Flutter Specialist: 길드 UI 구현
   ├─ Firebase Specialist: 길드 백엔드 구현
   └─ QA Engineer: 테스트 케이스 생성

6. QA Engineer
   └─ 통합 테스트 및 E2E 테스트

7. Documentation Specialist
   └─ 길드 시스템 문서화

8. Orchestrator
   └─ 최종 통합 및 풀 리퀘스트 생성
```

---

### Pattern 2: 게임 밸런스 조정 (예: 등반력 공식 변경)

```
1. Orchestrator
   └─ 게임 밸런스 조정 요청 분석

2. Game Logic Analyst
   └─ 등반력 공식 수정 제안
   └─ 등반 성공 확률 시뮬레이션
   └─ 사용자 성장 속도 예측

3. Point Economy Analyst
   └─ 포인트 보상 영향 분석
   └─ 경제 건강도 체크

4. Architect
   └─ 시스템 전체 영향 검토
   └─ 의존성 분석

5. QA Engineer
   └─ 밸런스 테스트 (다양한 레벨, 능력치 조합)

6. Flutter Specialist
   └─ 등반 성공 확률 UI 업데이트

7. Documentation Specialist
   └─ 등반력 공식 문서 업데이트

8. Orchestrator
   └─ 최종 통합 및 인간 승인 요청
```

---

### Pattern 3: Sherpi AI 개선 (예: 맥락 인식 향상)

```
1. Orchestrator
   └─ Sherpi AI 개선 요청 분석

2. Sherpi AI Specialist
   └─ 프롬프트 최적화
   └─ 맥락 분석 로직 개선
   └─ 감정 전환 규칙 업데이트

3. Design System Guardian
   └─ Sherpi 말풍선 디자인 검증
   └─ 감정별 이모티콘 일관성 체크

4. State Management Specialist
   └─ Sherpi 감정 상태 Provider 최적화
   └─ 불필요한 재빌드 방지

5. QA Engineer
   └─ 다양한 맥락 테스트 (레벨업, 퀘스트 완료, 등반 실패 등)
   └─ 감정 전환 테스트

6. Flutter Specialist
   └─ Sherpi 메시지 표시 UI 개선

7. Documentation Specialist
   └─ Sherpi API 문서 업데이트

8. Orchestrator
   └─ 최종 통합 및 풀 리퀘스트 생성
```

---

### Pattern 4: 디자인 시스템 위반 감지 및 수정

```
1. Design System Guardian
   └─ 정기적 코드 스캔 (ColorUsageScanner 실행)
   └─ 레거시 색상 사용 감지 (AppColors/RecordColors)

2. Design System Guardian → Orchestrator
   └─ 위반 사항 리포트 제출

3. Orchestrator → Flutter Specialist
   └─ 수정 작업 할당

4. Flutter Specialist
   └─ ModernColors로 변경

5. Design System Guardian
   └─ 수정 사항 재검증

6. QA Engineer
   └─ 시각적 회귀 테스트

7. Orchestrator
   └─ 최종 승인 및 커밋
```

---

## 📊 기존 vs 최종 구조 비교

| 항목 | 기존 구조 (7개) | 최종 구조 (11개) |
|------|----------------|-----------------|
| **에이전트 수** | 7개 | 11개 (+4개) |
| **디자인 시스템 관리** | ❌ 없음 | ✅ Design System Guardian |
| **Sherpi AI 전담** | ❌ 없음 | ✅ Sherpi AI Specialist |
| **State Management 전담** | ❌ 없음 | ✅ State Management Specialist |
| **포인트 경제 분석** | ❌ 없음 | ✅ Point Economy Analyst |
| **Flutter Specialist 부담** | 🔴 과다 | 🟢 적정 (UI 구현만) |
| **ModernColors 강제** | ⚠️ 불확실 | ✅ 자동 검증 |
| **Provider 초기화 검증** | ⚠️ 수동 | ✅ 자동 검증 |
| **4중 동기부여 엔진 커버** | ⚠️ 부분적 | ✅ 완전 커버 |

---

## 🎯 셰르파 특화 장점

### 1. **4중 동기부여 엔진 완전 커버**

| 동기부여 엔진 | 전담 에이전트 | 역할 |
|-------------|-------------|------|
| 🎮 게임화 시스템 | Game Logic Analyst | 등반력, XP, 레벨, 뱃지 |
| 🤖 AI 성장 코치 (Sherpi) | Sherpi AI Specialist | 맥락 기반 메시지, 감정 관리 |
| 👥 소셜 모임 | Flutter/Firebase Specialist | 모임 생성, 참여, 호스팅 |
| 💰 포인트 경제 | Point Economy Analyst | 포인트, 출금, 수수료, 보상 |

### 2. **기술 스택 완벽 정렬**

- **Flutter 3.27.0+**: Flutter Specialist (UI 구현)
- **Riverpod 2.4.9**: State Management Specialist (Provider 관리)
- **Firebase**: Firebase Specialist (백엔드)
- **ModernColors**: Design System Guardian (디자인 시스템)
- **OpenAI/Gemini**: Sherpi AI Specialist (AI 통합)

### 3. **안전성 강화**

- **Provider 초기화 순서**: State Management Specialist가 자동 검증
- **디자인 일관성**: Design System Guardian이 레거시 색상 사용 자동 감지
- **포인트 경제 건강도**: Point Economy Analyst가 비즈니스 리스크 분석
- **게임 밸런스**: Game Logic Analyst가 사용자 성장 시뮬레이션

---

## 🚀 구현 로드맵

### Phase 1: 코어 에이전트 구축 (0-2개월)

**우선순위**: Orchestrator, Architect, Design System Guardian, State Management Specialist

**목표**: 안전한 기반 구축

**작업**:
1. Orchestrator 구현 (중앙 조율)
2. Architect 구현 (아키텍처 관리)
3. **Design System Guardian 구현** (ModernColors 강제)
4. **State Management Specialist 구현** (Provider 초기화 검증)

**검증 기준**:
- ✅ Provider 초기화 순서 자동 검증 동작
- ✅ 레거시 색상 사용 자동 감지 동작
- ✅ 기존 코드베이스 스캔 성공

---

### Phase 2: 도메인 전문가 확장 (2-4개월)

**우선순위**: Game Logic Analyst, Point Economy Analyst, Sherpi AI Specialist

**목표**: 셰르파 핵심 기능 커버

**작업**:
1. **Game Logic Analyst 구현** (등반력, XP, 레벨 관리)
2. **Point Economy Analyst 구현** (포인트 경제 분석)
3. **Sherpi AI Specialist 구현** (AI 메시지 최적화)

**검증 기준**:
- ✅ 게임 밸런스 시뮬레이션 동작
- ✅ 포인트 경제 건강도 분석 동작
- ✅ Sherpi 맥락 기반 메시지 생성 개선

---

### Phase 3: 기술 구현자 통합 (4-6개월)

**우선순위**: Flutter Specialist, Firebase Specialist

**목표**: 신규 기능 자동 개발 파이프라인 구축

**작업**:
1. Flutter Specialist 구현 (UI 구현 자동화)
2. Firebase Specialist 구현 (백엔드 자동화)
3. 에이전트 간 협업 패턴 최적화

**검증 기준**:
- ✅ 신규 UI 기능 자동 개발 성공
- ✅ Firebase Functions 자동 배포 성공
- ✅ Design System Guardian 승인 프로세스 동작

---

### Phase 4: 품질 및 문서 완성 (6-8개월)

**우선순위**: QA Engineer, Documentation Specialist

**목표**: 완전 자동화된 개발 파이프라인

**작업**:
1. QA Engineer 구현 (테스트 자동 생성)
2. Documentation Specialist 구현 (문서 자동화)
3. 전체 워크플로우 통합

**검증 기준**:
- ✅ 테스트 커버리지 80% 이상
- ✅ API 문서 자동 생성 동작
- ✅ E2E 테스트 자동 실행 성공

---

## ✅ 구조 검증 체크리스트

### 셰르파 앱 핵심 요구사항 충족도

- [x] **4중 동기부여 엔진** 모두 전담 에이전트 보유
- [x] **ModernColors 강제** 자동 검증 시스템 구축
- [x] **Provider 초기화 순서** 자동 관리
- [x] **Sherpi AI** 전담 전문가 배치
- [x] **포인트 경제** 비즈니스 로직 분리
- [x] **게임 밸런스** 시뮬레이션 가능
- [x] **Feature-First 아키텍처** 감독 체계
- [x] **디자인 일관성** 자동 검증
- [x] **상태 관리** 전문가 배치
- [x] **테스트 자동화** 체계 구축

### 에이전트 역할 명확성

- [x] 각 에이전트의 책임 범위 명확 정의
- [x] 에이전트 간 협업 패턴 명시
- [x] 역할 중복 최소화
- [x] 전문화 수준 적정

### 확장성

- [x] 신규 기능 추가 시 에이전트 추가 가능
- [x] 에이전트 간 느슨한 결합 (Loose Coupling)
- [x] 모듈식 설계 (Modular Design)

---

## 📝 결론

### 최종 평가: ⭐⭐⭐⭐⭐ (5/5)

**기존 7개 구조 대비 개선 사항**:

1. ✅ **디자인 시스템 관리 자동화** (Design System Guardian 추가)
2. ✅ **Sherpi AI 품질 향상** (Sherpi AI Specialist 추가)
3. ✅ **상태 관리 안정성 강화** (State Management Specialist 추가)
4. ✅ **비즈니스 로직 분리** (Point Economy Analyst 추가)
5. ✅ **Flutter Specialist 부담 감소** (역할 조정)

**셰르파 앱 특성 반영**:
- 4중 동기부여 엔진 완전 커버
- ModernColors 강제 자동 검증
- Provider 초기화 순서 자동 관리
- 게임 밸런스와 포인트 경제 분리

**권장 사항**:
- Phase 1부터 순차적으로 구현 시작
- Design System Guardian과 State Management Specialist를 최우선 구축
- 에이전트 간 협업 패턴을 실제 워크플로우로 검증

---

## 📚 참고 문서

- `셰르파 앱 개발 에이전트 시스템 설계.pdf` (기반 문서)
- `CLAUDE.md` (셰르파 앱 프로젝트 가이드)
- `claude-code-multi-agent-guide.md` (멀티 에이전트 기술 가이드)
- `멀티에이전트_환경_구축_가이드.md` (한국어 구축 가이드)

---

**문서 버전**: 1.0.0
**작성일**: 2025-10-30
**작성자**: Claude Sonnet 4.5
**상태**: 최종 승인 대기
