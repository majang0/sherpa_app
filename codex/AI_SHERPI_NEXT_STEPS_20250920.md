# AI/Sherpi Feedback System – Next Steps Plan (2025-09-20)

현재 진행 상황(Stage A 및 Sprint 0 완료)에 맞춰 앞으로 집중할 작업을 단계별로 정리했습니다. Stage B~E를 중심으로 진행하며, Sprint 1~4와 연동해도 무방합니다.

---

## 1. 현재 완료 상태 요약
- Stage A: 플로팅 메시지 정적화 (StaticSherpiManager 고정, AI 훅 제거) ✅
- Sprint 0 P0-1: `AiInsightGenerator` 실포인트 차감 적용 완수 ✅
- Sprint 0 P0-2: PersonalizationSettings import 정리 ✅
- Stage 3(추천/캐시 정비) 주요 항목 완료 (Phase 3 작업) ✅

미실행/보류: Stage B~E, Sprint 1 이후 작업, 회귀 테스트 재실행 (환경 제한으로 대기)

---

## 2. 다음 단계 (Stage B~E 우선순위)

### Stage B – 분석 AI Feature Flag + Logger (우선 실행)
1. `analysis_ai_config.dart` 및 `analysisConfigProvider` 구현
2. 분석 다이얼로그/서비스가 Flag를 참조하도록 수정 (disabled/mock/gemini/openai 등)
3. logger 패키지 도입, 기존 `print` 교체 (실행 경로별 로그 레벨 정의)

> Sprint 1에서 실행 권장. Feature Flag 단위 테스트 기본케이스 포함.

### Stage C – 분석 캐시 & 사용량 제한
1. 분석 결과 캐시 구조 설계(사용자+날짜+분석타입), TTL 옵션화
2. `AnalysisUsageTracker` (호출 횟수, 토큰, 비용, 한도 초과 처리)
3. 캐시/사용량 로깅 및 간단한 모니터링 지표 마련

### Stage D – UI 통합 & 폴백
1. 캐시/포인트 상태를 분석 UI에 표시 (캐시 Hit, 포인트 차감 성공/실패 등)
2. AI 호출 실패 시 정적 분석 결과로 폴백하는 UX 구현
3. 포인트 부족·할당량 초과 안내 다이얼로그 정교화

### Stage E – 테스트·문서·관측성 마감
1. Feature Flag, 캐시, 포인트 차감/환불 흐름에 대한 테스트 케이스 작성
2. `flutter analyze` / `flutter test` 자동화, 커버리지 측정
3. 문서 업데이트 (`docs/sherpi_system.md`, 진행 현황 문서 등)

---

## 3. Sprint 관점 권장 흐름
- **Sprint 1**: Stage B, Logger 도입, Print 제거, 기본 테스트 재실행
- **Sprint 2**: Stage C, 캐시/사용량 제한 및 모니터링 구축
- **Sprint 3**: Stage D, UI 폴백·UX 개선, 포인트 안내 강화
- **Sprint 4**: Stage E, 테스트 확대·문서화·프로덕션 점검

(필요 시 Sprint 0.5로 Stage B 일부 작업을 끌어당겨도 됩니다.)

---

## 4. 즉시 실행 권장 항목
1. Windows PowerShell/CI 환경에서 `flutter analyze`, `flutter test` 재실행 → Stage A/Sprint 0 회귀 확인
2. Stage B 설계 착수: Flag 구조 및 logger 도입 여부 사전 리뷰
3. `AiInsightGenerator` 포인트 흐름에 대한 단위 테스트 추가 계획 수립

---

## 5. 참고 문서
- `codex/AI_SHERPI_CONSOLIDATED_PLAN_20250920.md` (Rev.2)
- `codex/PHASE4_REVISED_PLAN.md`
- `codex/AI_SHERPI_CODE_QUALITY_IMPROVEMENT_PLAN_20250920.md`
- `codex/AI_SHERPI_CODE_REVIEW_20250920_rev1.md`

---

*작성자: Codex (2025-09-20)*
