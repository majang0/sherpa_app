# AI/Sherpi System Refactoring Roadmap (2025-09-20)

기능 확장 없이 **코드 품질·중복 제거·일관성 강화**에 초점을 맞춘 단계별 리팩터링 계획입니다. Stage A/Sprint 0 이후의 차기 작업들을 대상으로 합니다.

---

## Stage Q0 – 환경 정비 & 기본 검사 (즉시)
1. `flutter analyze`, `flutter test`를 PowerShell/CI 환경에서 재실행하여 Stage A/Sprint 0 변경의 회귀 여부 확인.
2. 기존 `print`/`debugPrint` 중 로그가 아닌 단순 메시지 제거, 일시적 `TODO` 표기.
3. 문서 정합성 확인: `ai_sherpi_progress_status.md`, `docs/sherpi_system.md` 등에서 Legacy 옵션 내용 삭제.

**산출물**: 테스트 로그, 문서 싱크 완료 보고.

---

## Stage Q1 – 매니저/Legacy 정리 (감소/단순화)
1. `lib/core/ai/managers/legacy/`의 `SmartSherpiManager*` 사용 경로 파악 → 필요 시 테스트 전용으로 이동하거나 `OpenAISherpiManager`/`StaticSherpiManager`와 통합.
2. 채팅/분석 경로에서 `OpenAISherpiManager`/`StaticSherpiManager`를 명확히 사용하도록 주입 구조 통일.
3. 정적 메시지 생성 로직(`_getPersonalizedStaticMessages`)을 단일 유틸 클래스로 분리하여 매니저 간 중복 제거.

**검증**: 관련 경로 단위 테스트 추가, Legacy 제거 후 빌드/분석 성공.

---

## Stage Q2 – 분석/추천 공통 유틸화
1. `ActivityAnalysisService`와 `AiInsightGenerator`에 흩어진 OpenAI 호출/프롬프트/에러 처리 로직을 공통 유틸(`OpenAIAnalysisExecutor` 가칭)로 통합.
2. 사용자/게임 컨텍스트 빌더(`RealDataConnector` 등)를 공유 유틸로 정리하여 반복 구문 제거.
3. 포인트 차감/환불 로직을 서비스 간 동일 인터페이스로 추출 (`PointConsumptionService` 등).

**검증**: 공통 유틸 단위 테스트 추가, 서비스 파일 200라인 이하 유지.

---

## Stage Q3 – 상태/DI 일관성 강화
1. `AiInsightGenerator`, `ActivityAnalysisService` 등에서 `Ref?` 패턴을 제거하고, Provider를 명시적으로 주입받도록 리팩터링.
2. 전역 상태 초기화 순서 문서화(`docs/sherpi_system.md`), 필요 시 ProviderScope override 패턴 통일.
3. 캐시/사용량 관련 상태(StateNotifier/Provider) 설계 검토, 단일 소스 유지.

**검증**: 주요 서비스에 대한 constructor/DI 단위 테스트, Provider override 케이스 테스트.

---

## Stage Q4 – 로그·테스트·문서 마감
1. Logger 도입 여부 결정: 최소한 `print` 전환 → `debugPrint` or 공통 Logger (`LoggerService`)로 교체.
2. 포인트/분석/추천 주요 경로에 단위 테스트 및 간단한 통합 테스트 작성.
3. 문서 최종 정리: 구조도 업데이트, 리팩터링 가이드(`AI_SHERPI_CODE_QUALITY_REVIEW_20250920_rev1.md`) 반영.

**성공 기준**: 테스트 커버리지 상승, Analyzer 경고 0, 문서/코드 일치.

---

## 참고 & 병행 작업
- Stage B~E (Feature Flag, 캐시 제한 등 기능 주도 작업)는 본 로드맵 이후 또는 병행 가능한 인력 확보 시 진행.
- 긴급 이슈 발생 시 Sprint 0 방식으로 우선 대응 후 로드맵 재조정.

---

*작성자: Codex (2025-09-20)*
