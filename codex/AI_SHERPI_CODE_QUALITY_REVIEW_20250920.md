# AI/Sherpi System Code Quality Review (2025-09-20)

본 리뷰는 기능 추가가 아닌 **코드 품질, 중복 제거, 일관성, 전역 상태 관리** 관점에서 현 상태를 평가합니다.

---

## 1. 구조적 관찰

### 1.1 매니저 계층 중복
- `lib/core/ai/managers/openai_sherpi_manager.dart`와 `lib/core/ai/managers/legacy/smart_sherpi_manager*.dart`가 유사 책임을 가집니다.
- 채팅/테스트 경로에서 legacy 매니저가 여전히 사용되어, 정적/AI 경로가 혼재합니다.
- 동일한 정적 메시지/개인화 로직이 파일마다 반복됩니다.

### 1.2 AI 분석 서비스 중복 로직
- `AiInsightGenerator`와 `ActivityAnalysisService`가 OpenAI 호출, 프롬프트 구성, 예외 처리 등을 중복 구현합니다.
- 캐싱/포인트 처리/에러 핸들링이 각 서비스에 흩어져 있어 일관성 유지가 어렵습니다.

### 1.3 전역 상태 접근 방식 불균형
- `global_sherpi_provider`는 DI 기반으로 정리됐으나, `AiInsightGenerator`, `ActivityAnalysisService`, `RealDataConnector`는 여전히 직접 provider를 읽거나 null 체크로 의존성을 관리합니다.
- 분석/추천 경로에서 user context를 구성하는 코드가 여러 파일에서 반복됩니다.

### 1.4 문자열/템플릿 중복
- `sherpi_dialogues.dart` 내부에 유사한 문자열 패턴이 복제되어 있고, 메시지 필터링/에러 처리 로직이 매니저마다 따로 존재합니다.
- 분석 프롬프트 템플릿이 여러 서비스/빌더에 분산되어 유지보수 부담이 큽니다.

---

## 2. 품질 이슈 요약

| 분류 | 항목 | 영향 |
|------|------|------|
| 로그 | 다수의 `print` 사용, 일관된 로거 부재 | 로그 관리 어려움, 프로덕션 노출 위험 |
| 예외 | 포인트 차감 적용됐으나 UI/서비스 간 예외 흐름 미정돈 | 사용자 경험 혼선, 롤백 불확실 |
| 테스트 | 포인트/분석 경로 단위 테스트 없음 | 회귀 방지 불가 |
| 캐시 | 분석/추천 캐시 구조가 파일마다 상이 | 불필요한 만료/갱신 발생 |
| 문서 | Stage A 내용만 부분 반영, 다른 문서(예: 진행 현황)와 불일치 | 혼동 가능성 |

---

## 3. 상세 지적 사항

1. **Legacy 매니저 유지**: `lib/features/sherpi/chat/providers/*`에서 `SmartSherpiManager`를 직접 생성하여 사용. 신규 구조와 이중 관리됨.
2. **분석 서비스 분산**: 프롬프트 생성, OpenAI 호출, 캐시 관리, 포인트 처리 등이 `AiInsightGenerator`, `ActivityAnalysisService`, `RecommendationPromptBuilder` 등에 중복되어 있다.
3. **전역 상태 관리**: `RealDataConnector`, `AiInsightGenerator` 등에서 `Ref?` 패턴을 사용하여 null 체크를 반복, 초기화 시점 제어가 어렵다.
4. **포인트/환불 로직**: 환불은 `AiInsightGenerator`에서만 적용되어 있고, 다른 서비스(`ActivityAnalysisService`)는 동일 정책을 따르지 않는다.
5. **print 사용**: 주요 서비스 파일에 `print`, `debugPrint`가 혼재하며, 로그 레벨·형식이 정의되어 있지 않다.
6. **문서 불일치**: 일부 문서에 AI 강제 사용 옵션/Legacy 구조가 남아 있어 현재 코드와 맞지 않는다.

---

## 4. 테스트 상태
- `flutter analyze`/`flutter test`는 WSL sandbox 제약으로 실행하지 못함 → 별도 환경에서 필요.
- 포인트 차감 로직에 대한 단위 테스트 없음 → 도입 필요.

---

## 5. 결론
현 구조는 Stage A/Sprint 0 이후 안정화는 되었으나, **중복 제거와 일관성 확보**가 다음 단계의 최우선 과제입니다. 기능 추가 없이도 **Legacy 코드 정리, 공통 유틸화, 전역 상태 주입 방식 통일, 로깅/테스트 개선**을 통해 품질을 크게 향상시킬 수 있습니다.

이후 계획은 `AI_SHERPI_REFACTORING_ROADMAP_20250920.md`를 참고하세요.
