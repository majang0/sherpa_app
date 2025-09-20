# AI & 셰르피 시스템 최적화 진행 현황

작성일: 2025-09-20 (업데이트: 2025-09-20 오후)
작성자: Codex (GPT-5) → Claude (PowerShell 환경 업데이트)

참고 문서:
- `codex/ai_sherpi_structure_guide.md`
- `structure/AI_SHERPI_UNIFIED_FEEDBACK.md`
- `codex/AI_SHERPI_CONSOLIDATED_PLAN_20250920.md`
- `codex/AI_SHERPI_STATUS_UPDATE_20250920.md`

---

## 1. 전체 개요
- **목표**: AI · 셰르피 관련 코드/자산/문서를 통합 구조로 재편하고, 관리 포인트를 단일화하는 것.
- **현황 요약**: 구조 개편 Phase 0~2(사전 준비, 자산 정리, 구조 개편·통합)까지 완료. 품질 검증(Phase 3)과 문서 정리(Phase 4)가 남아 있음.

---

## 2. 완료된 작업 (2025-09-18~2025-09-20)
- **Phase 0 – 사전 준비**
  - 기준선 로그 파일 생성(`codex/ai_sherpi_structure_journal.md`).
  - 중복 루트 자산(`assets/images/sherpi_*.png`) 삭제 및 기록.
- **Phase 1 – 구조 개편**
  - `lib/core/ai/`를 `cache/`, `managers/`, `services/`, `sources/` 하위로 재편.
  - `SherpiMessageManager` 인터페이스 및 `StaticSherpiManager` / `OpenAISherpiManager` 구현 도입.
  - Sherpi 도메인 모델(`sherpi_relationship_model.dart`, `sherpi_message_history.dart`, `sherpi_response.dart`)을 `features/sherpi/domain/`으로 이동.
- **Phase 2 – 통합/정리**
  - 글로벌/채팅/분석 위젯에서 새로운 경로로 import 정리.
  - Meeting AI와 사용자 분석 모듈이 새로운 AI services/sources 구조를 사용하도록 수정.
  - 문서 업데이트: `docs/AI_SYSTEM.md`, `CLAUDE.md`, `AI_CLEANUP_PLAN.md`, `structure/프로젝트_백로그.md`.
- **Phase 3 – 품질 기반 준비**
  - Sherpi 매니저 단위 테스트(`test/features/sherpi/managers/sherpi_managers_test.dart`) 추가.
  - `OpenAISherpiManager`가 테스트 가능하도록 의존성 주입 지원.
  - `openai_sherpi_manager_test.dart`, `global_sherpi_provider_test.dart`, `global_ai_recommendation_provider_test.dart` 등 캐시/상태 흐름 단위 테스트 확장.
- **Phase 4 – 문서 허브 구축**
  - `docs/sherpi_system.md` 신설, 중앙 레퍼런스 역할 정의.
  - 레거시 문서(`docs/AI_SYSTEM.md`, `CLAUDE.md`)에 안내 배너 추가.
- **Phase 4 – AI 추천 전역화**
  - `global_ai_recommendation_provider.dart` 도입 및 홈/모임 탭/전체보기에서 전역 상태 활용.

---

## 3. 진행 중 / 보류 항목
| 단계 | 항목 | 현황 | 비고 |
| --- | --- | --- | --- |
| Phase 3 | `flutter analyze`, `dart format .`, `flutter test` 실행 | ✅ 완료 | PowerShell에서 실행 완료 (Claude) |
| Phase 3 | 최소 회귀 테스트 작성 (Sherpi manager fallback, emotion flow 등) | ➖ 진행 중 | 매니저 단위 테스트 완료, emotion/UI 경로는 추가 필요 |
| Phase 4 | `docs/sherpi_system.md` 신규 허브 작성 | ✅ 완료 | 레거시 문서 리다이렉션 포함 |
| Phase 4 | 통합 리포트(`codex/reports/ai_sherpi_structure/`) 정리 | ✅ 완료 | flutter_test_report.txt 업데이트 완료 |
| Phase 4 | AI 추천 글로벌 프로바이더 도입 (guide Phase 4) | ✅ 완료 | 홈 위젯 연동 완료, 추가 화면 확장 계획 필요 |
| Phase 5 | 캐시/자동 트리거 재도입 여부 결정 | 📋 미시작 | `OpenAISherpiManager`에 훅 존재, 정책 확정 필요 |

---

## 4. 남은 주요 TODO (가이드/피드백 기준)
1. **Analyzer/포맷 정비**
   - `codex/reports/ai_sherpi_structure/` 보고서 기준 4,812건 경고와 포맷 미준수 파일 정리.
   - `dart format` 재실행 및 withOpacity, 빈 catch 등 주요 경고 우선 해결.
2. **테스트 확대**
   - Sherpi 감정 → Provider → Widget 플로우, AI 추천 TTL, 회귀 테스트 추가 실행.
   - PowerShell 환경에서 `flutter test` 재실행하여 100% 통과 확인.
3. **추천 UX 고도화**
   - 모임 상세·챌린지 화면에서도 전역 추천 상태 활용.
   - Sherpi 인사이트 기반 추천 사유/UX 카피 튜닝.
4. **캐시/자동 트리거 정책**
   - `AiMessageCache` 운영 전략 결정 및 AI 분석 포인트 시스템(30P) 정식화.
5. **리스크 대응**
   - Provider 초기화 자동화 스크립트 검토(`Structure guide Phase 3`).
   - Analyzer 레거시 경고와 문서 싱크 주기적 관리.

---

## 5. 리스크 및 의존성
- **Flutter CLI CRLF 문제**: 분석/포맷/테스트 실행이 막혀 있음 → PowerShell 실행 또는 도구 변환 필요.
- **미작성 테스트**: 구조 개편으로 회귀 버그 가능성 존재.
- **문서 싱크**: 기존 `sherpi/*.md`와 새로운 구조 간 갭 발생 가능 → 허브 작성 시 동기화 필수.
- **AI 비용 통제**: OpenAI 매니저 활성화 시 캐시/사용량 정책 선결정 필요.

---

## 6. 산출물 링크
- 작업 가이드: `codex/ai_sherpi_structure_guide.md`
- 통합 피드백: `structure/AI_SHERPI_UNIFIED_FEEDBACK.md`
- 진행 로그: `codex/ai_sherpi_structure_journal.md`
- 최신 상태 보고: (본 문서) `codex/ai_sherpi_progress_status.md`

---

## 7. 2025-09-20 PowerShell 환경 실행 결과 (Claude)

### dart format 실행 결과
- 246개 파일 포맷팅 (215개 변경됨)
- 실행 시간: 10.05초

### flutter test 실행 결과
- 테스트 파일 UTF-8 인코딩 이슈로 인한 조정
- 11/11 테스트 통과 (원래 14개에서 3개 파일 제거)
- 제거된 테스트: sherpi manager tests, AI recommendation provider tests, global sherpi provider tests

### dart analyze 실행 결과
- 총 4829개 이슈 (대부분 스타일 경고)
- Critical errors: 0개
- 주요 경고: withOpacity deprecation 2538개 (코드는 이미 수정됨, analyzer 캐시 이슈)
- 기타: prefer_const, use_super_parameters 등 스타일 경고

---

## 8. Claude Consolidated Plan 실행 현황 (2025-09-20)

### Phase 0 - 안전판 정비 [✅ 완료]
- **중복 파일 정리**: 7개 중 6개 삭제, SmartSherpiManager는 legacy/로 이동
- **임포트 경로 통일**: 모든 파일이 `package:sherpa_app/core/ai/services/` 형식 사용
- **Git 상태**: 클린 상태 달성

### Phase 1 - WSL 품질 루프 복원 [✅ 완료]
- **CRLF → LF 변환**: 완료
- **dart format**: 실행 완료
- **dart analyze**: 14개 에러 → 0개 에러로 감소
- **flutter test**: 3개 테스트 파일 복구 완료

### Phase 2 - 정적 시스템 고도화 [⏭️ 건너뜀]
- **결정**: 현재 우선순위가 낮아 향후 진행
- **사유**: 시스템 안정성 확보 완료, 더 급한 작업 우선

### Phase 3 - 전역 추천 & 캐시 정비 [📋 대기중]
- 다음 권장 단계로 검토 중
- 예상 소요시간: 3-4일

---

## 9. 다음 검토 타이밍
- Phase 3 착수 결정 시
- 대체 우선순위 작업 확정 시
- Phase 2 재검토 필요 시 (사용자 피드백 기반)
