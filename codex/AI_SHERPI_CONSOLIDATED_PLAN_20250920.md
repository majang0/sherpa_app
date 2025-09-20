# AI/Sherpi Consolidated Execution Plan (2025-09-20 Rev.2)

본 계획서는 Phase 0~3 완료 결과와 `PHASE4_REVISED_PLAN.md`에서 제안된 AI 범위 재정의를 반영하여
향후 실행 단계를 재정립한 문서입니다. 플로팅 메시지는 전면 정적, 분석/계획 다이얼로그는 선택적 AI라는
명확한 경계 아래, 유지·분석·관측 관점에서의 우선순위를 정리합니다.

---

## 1. 상황 요약
- **플로팅 메시지**: 정적 메시지로 충분하며, 응답 속도와 일관성을 최우선으로 유지한다.
- **AI 활용**: 오늘의 분석·감정/계획 다이얼로그 등 심층 인사이트 기능에서만 AI를 사용한다.
- **백엔드 상태**: Phase 3까지 완료되어 추천/캐시 구조는 정비됨. 분석 파이프라인과 비용 관리가 다음 핵심 과제다.
- **기술 부채**: Analyzer 경고 정리, 분석 캐시/사용량 추적, 문서 싱크 등 운영 기반 정비가 필요하다.

---

## 2. 새로운 단계 체계 (Phase 2 폐지, Stage 기반 재구성)

| Stage | 목표 | 주요 산출물 | 예상 기간 |
|-------|------|-------------|-----------|
| **Stage A** | 플로팅 메시지 정적화 확정 | SherpiNotifier 정적 매니저 고정, 불필요한 AI 훅 제거 | D+0 |
| **Stage B** | 분석 AI Feature Flag 도입 | `AnalysisAIConfig`, Provider, UI 연동 | D+1~2 |
| **Stage C** | 분석 캐시/사용량 제한 | 분석 결과 캐시, `AnalysisUsageTracker` | D+3~4 |
| **Stage D** | 분석 UI 통합·폴백 강화 | 분석 화면 캐시/폴백, 모드 표시 UX | D+5~6 |
| **Stage E** | 테스트·관측성·문서화 | 테스트 확대, 로그/모니터링, 문서 갱신 | D+7~8 |

> *완료된 작업*: Stage A 일부(정적 매니저 DI), Stage C 캐시 개편(전역 추천). 향후 작업은 Stage A~E를 순차 실행한다.

---

## 3. Stage별 세부 계획

### Stage A – 플로팅 메시지 정적화 확정
1. `global_sherpi_provider.dart`에서 `SherpiMessageManager`를 반드시 `StaticSherpiManager`로 주입.
2. `enableAIForNextMessage`, `debugForceAI` 등 AI 관련 레거시 훅 제거.
3. Legacy OpenAI 매니저는 분석 다이얼로그 전용으로 `legacy/` 위치에 한정, 플로팅 경로에서 import 금지.
4. 정적 메시지 품질 점검 로깅(선택): 중복/빈 문자열 감지용 디버그 로그.

### Stage B – 분석 AI Feature Flag 도입
1. `lib/core/config/analysis_ai_config.dart`와 `analysisConfigProvider` 추가.
2. 모드: `disabled` / `mock` / `gemini` / `openai` + 호출 한도/캐시 지속시간 매개변수 정의.
3. 분석 UI 및 서비스(ActivityAnalysisService, AiInsightGenerator)가 Provider를 통해 모드를 확인하도록 수정.
4. QA: Mock 모드에서 deterministic 응답 제공, 테스트용 JSON 준비.

### Stage C – 분석 캐시 및 사용량 제한
1. 분석 결과 캐시(사용자+날짜+분석타입 Key). TTL은 Config 값 사용.
2. `AnalysisUsageTracker`: 일일 호출 횟수, 토큰 사용량, 추정 비용, 한도 초과 시 예외 처리.
3. 캐시 데이터는 SharedPreferences 또는 로컬 DB 사용. 메타 정보(저장 시각/모드) 기록.
4. 비용 리포트: 일별 사용량을 `codex/reports/analysis_usage/`에 요약 저장(선택).

### Stage D – 분석 UI 통합 및 폴백 강화
1. `enhanced_today_analysis_dialog.dart`, `comprehensive_analysis_page.dart` 등에서 캐시 확인 후 AI 호출.
2. 캐시 Hit, Mock, 실시간 결과 각각에 대한 UI 라벨 표시.
3. AI 호출 실패 시 규칙 기반(정적) 분석 레포트로 폴백하고 사용자 안내 문구 제공.
4. 긴 분석 시 로딩 체감 개선(프로그레스/힌트 메시지).

### Stage E – 테스트·관측성·문서화
1. 테스트: Feature Flag 상태별, 캐시 만료, 할당량 초과, 폴백 흐름 등.
2. 관측성: 로그 레벨 정의, 이벤트 태그(캐시 히트, AI 호출, 폴백 등) 추가.
3. 문서: `docs/sherpi_system.md`, `codex/PHASE4_REVISED_PLAN.md`, `codex/ai_sherpi_progress_status.md` 업데이트.
4. 릴리즈 체크리스트 갱신: Stage별 완료 조건, 테스트 목록, 롤백 절차 반영.

---

## 4. Stage 간 의존 및 주의사항
- Stage A는 Stage B~E의 기반. 플로팅/분석 경로가 섞이지 않도록 방어 로직 점검.
- Stage B에서 Feature Flag를 도입하면 Stage C~D 작업 시 모든 경로에서 모드를 참조해야 한다.
- Stage C 캐시 도입 시 기존 추천 캐시와 충돌하지 않도록 별도 키 네임스페이스 사용.
- Stage D에서 사용자 경험 단절을 방지하기 위해 폴백 메시지를 충분히 준비.
- Stage E 테스트는 기존 테스트와 중복되지 않도록 새 파일/그룹으로 구성.

---

## 5. 즉시 다음 조치 (Stage A)
1. `global_sherpi_provider` 코드에서 정적 매니저만 참조하도록 검증.
2. 삭제된 AI 훅(Enable/Force) 관련 테스트/문서 업데이트.
3. 플로팅 메시지 생성 경로에 대한 간단한 QA: 정적 메시지 정상 출력 확인.

---

## 6. 추적 및 보고
- **진행 로그**: `codex/ai_sherpi_structure_journal.md`
- **상태 표**: `codex/ai_sherpi_progress_status.md`
- **레이어 문서**: `docs/sherpi_system.md`
- **AI 전략 문서**: `codex/PHASE4_REVISED_PLAN.md`

---

## 7. 성공 지표 업데이트
- 플로팅 메시지 응답 시간 p95 < 100ms
- 분석 AI 월간 비용 < $20, 일일 호출 < 50회
- 분석 캐시 히트율 > 60%, 폴백 발생률 < 10%
- 사용자 피드백: 플로팅 메시지 만족도 유지, 분석 다이어로그 만족도 상승

---

_작성자: Codex (2025-09-20, Rev.2)_
