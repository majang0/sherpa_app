# AI/Sherpi System Code Review (Rev.1 / 2025-09-20)

최근 Stage A 및 Sprint 0 작업 이후 AI·셰르피 시스템의 구현 상태를 다시 점검한 결과입니다. 구조/동작/운영 세 측면에서 주요 관찰과 개선 제안, 알파 작업의 분리 수준을 정리했습니다.

---

## 1. 구조 및 책임 분리 상태

### 1.1 Core AI 폴더 구조
```
lib/core/ai/
├── cache/                    (AiMessageCache 등 캐시 유틸)
├── managers/
│   ├── legacy/               (SmartSherpiManager*)
│   ├── openai_sherpi_manager.dart
│   ├── static_sherpi_manager.dart
│   └── sherpi_message_manager.dart
├── services/                 (ActivityAnalysisService 등)
└── sources/                  (OpenAIDialogueSource 등)
```
- Gemini 관련 파일은 제거되었고, OpenAI 기반 구조만 남아 있습니다.
- `OpenAISherpiManager`와 `StaticSherpiManager`가 분리되어 있으며, 플로팅 경로는 `StaticSherpiManager`만 사용합니다.
- `legacy/`에 SmartSherpiManager가 남아 있으며, 채팅/테스트 등 일부 경로에서 아직 참조합니다 (향후 Stage에서 정리 필요).

### 1.2 분석/추천 모듈
- `AiMessageCache`, `MeetingRecommendationAI`, `RecommendationPromptBuilder`, `global_ai_recommendation_provider`는 Phase 3에서 손본 구조가 반영되어 사용자별 캐시 키/TTL 및 SherpiInsights 전달이 동작합니다.
- AI 분석 루프는 `ActivityAnalysisService` 및 `AiInsightGenerator`에 포함되어 있으며, 포인트 차감 로직이 적용되었습니다.

### 1.3 플로팅 메시지
- `global_sherpi_provider.dart` 내 `SherpiNotifier`가 `StaticSherpiManager`만 주입받고, `debugForceAI` 등 AI 강제 옵션은 제거되었습니다.
- Stage A 결과로 플로팅 메시지는 100% `sherpi_dialogues.dart` 기반 정적 경로로 확정되었습니다.

---

## 2. 품질 상태 및 개선 사항

### 2.1 긴급 이슈 해결 여부
- `AiInsightGenerator`의 포인트 확인/차감/환불 로직이 실제 메서드에 적용되어 now 분석 실행 시 30P가 차감됩니다.
- `OpenAISherpiManager`의 불필요한 `PersonalizationSettings` import는 제거되었습니다.

### 2.2 남은 리스크 / TODO
1. **테스트·분석 미실행**: WSL 환경에서 Windows 실행 파일이 차단되어 `flutter analyze`/`flutter test` 재실행을 하지 못했습니다. PowerShell/CI 환경에서 회귀 확인 필요.
2. **OpenAISherpiManager Legacy Usage**: 채팅 프로바이더 등에서 `OpenAISherpiManager`/`SmartSherpiManager`가 남아 있으므로 Stage B 이후 계획에 따라 정적/AI 분리 여부를 재검토해야 합니다.
3. **분석 UI 포인트 안내**: 포인트 차감이 서비스 레벨에는 반영됐지만, UI 다이얼로그 메시지/경고가 Stage B 정책(Feature Flag)과 일치하는지 추가 확인 필요.
4. **Logger 도입**: 아직 `print` 기반 로그가 다수 남아 있으며 Stage B에서 logger 교체가 예정되어 있습니다.

### 2.3 문서 및 로드맵 반영
- `codex/AI_SHERPI_CONSOLIDATED_PLAN_20250920.md`는 Stage A~E 체계로 갱신되었습니다.
- `codex/ai_sherpi_structure_journal.md` 업데이트 완료(포인트 로직 반영 기록 등).
- Stage B 이후 진행을 위한 `PHASE4_REVISED_PLAN.md`, `AI_SHERPI_CODE_QUALITY_IMPROVEMENT_PLAN_20250920.md`도 참고 가능합니다.

---

## 3. 테스트 및 검증 상태
- 포인트 차감 로직은 Unit Test가 존재하지 않음 → Stage B 혹은 Sprint 1에서 작성 권장.
- `flutter analyze` / `flutter test` 실행이 sandbox 제약으로 실패 → 다른 환경에서 실행 필요(로그 기록됨).

---

## 4. 단계별 작업 계획 (현 시점부터)

### Stage B (분석 AI Feature Flag + Logger 도입)
1. `analysis_ai_config.dart` 및 Provider 뼈대 구현.
2. 분석 UI/Service가 Feature Flag를 참조하도록 리팩터링.
3. logger 패키지 도입, 주요 print 교체.

### Stage C (분석 캐시 & 사용량 제한)
1. 분석 결과 캐시 구조 설계(사용자+날짜+타입).
2. `AnalysisUsageTracker` 추가해 호출 횟수/비용 추적.
3. 캐시/사용량 이벤트 로깅.

### Stage D (UI 통합 & 폴백)
1. 분석 다이얼로그에서 캐시 히트 여부 표시, 포인트 부족/할당량 초과 안내.
2. AI 호출 실패 시 정적(규칙 기반) 결과로 폴백 UX 구현.

### Stage E (테스트·문서·관측성)
1. Feature Flag/캐시/포인트 흐름 테스트 케이스 작성.
2. 문서 업데이트 (`docs/sherpi_system.md`, 진행 현황 문서 등).
3. `flutter analyze`/`flutter test` 자동화 및 커버리지 측정.

---

## 5. 권장 우선순위 요약
| 우선순위 | 항목 | 설명 |
|---------|------|------|
| 🔴 즉시 | PowerShell/CI에서 analyze/test | Stage A/Sprint 0 변경에 대한 회귀 검증 |
| 🟠 단기 | Stage B 실행 | Feature Flag + logger 도입, 포인트 안내 UX 확인 |
| 🟠 단기 | Unit Test 추가 | AiInsightGenerator 포인트 차감 흐름 검증 |
| 🟢 중기 | Stage C 이후 | 캐시/할당량/문서화 순차 진행 |

---

## 6. 결론
- Stage A/Sprint 0 변경으로 플로팅 메시지 정적화 및 포인트 정책 적용이 완료되었습니다.
- Stage B~E는 분석 다이얼로그 품질 향상과 사용량 통제, 관측성 확보에 초점을 맞춰 진행하면 됩니다.
- 분석 관련 포인트/Feature Flag 작업에 앞서, 테스트/분석이 가능한 환경에서 회귀 확인을 먼저 수행하시길 권장합니다.
