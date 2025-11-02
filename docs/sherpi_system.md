# Sherpi System Reference Hub

작성일: 2025-09-20  
작성자: Codex (GPT-5)

---

## 1. 개요
- **역할**: Sherpi는 셰르파 앱 전역에 걸친 동반자 AI/캐릭터 시스템으로, 사용자 활동에 맞춘 메시지·감정·추천을 노출한다.
- **현재 모드**: 기본은 정적 메시지, 필요 시 OpenAI GPT-5 기반 하이브리드 응답 (수동 트리거).
- **구성 원칙**
  1. **DI 기반 매니저 구조**: `SherpiMessageManager` → `StaticSherpiManager` / `OpenAISherpiManager`.
  2. **도메인 모델 단일화**: 모든 Sherpi 모델은 `lib/features/sherpi/domain/`에서 관리.
  3. **플랫폼 연동 분리**: AI 연결 로직은 `lib/core/ai/sources/`, 프롬프트/데이터 수집은 `lib/core/ai/services/`.

---

## 2. 디렉터리 구조 (2025-09-20)
```
lib/
├── core/
│   └── ai/
│       ├── cache/
│       │   └── ai_message_cache.dart
│       ├── managers/
│       │   ├── sherpi_message_manager.dart
│       │   ├── static_sherpi_manager.dart
│       │   └── openai_sherpi_manager.dart
│       ├── services/
│       │   ├── activity_analysis_service.dart (향후 재활성화 예정)
│       │   ├── activity_prompt_templates.dart
│       │   └── real_data_connector.dart
│       └── sources/
│           └── openai_dialogue_source.dart
├── features/
│   └── sherpi/
│       ├── domain/
│       │   └── models/
│       │       ├── sherpi_message_history.dart
│       │       ├── sherpi_relationship_model.dart
│       │       └── sherpi_response.dart
│       ├── presentation/
│       │   └── providers/
│       │       └── sherpi_manager_provider.dart
│       └── relationship/… (관계 상태/서비스)
└── shared/
    ├── providers/
    │   └── global_sherpi_provider.dart
    └── widgets/
        ├── global_sherpi_widget.dart
        ├── sherpi_message_card.dart
        ├── sherpi_personalization_dialog.dart
        └── sherpi_relationship_growth_widget.dart
```

---

## 3. 데이터 & 흐름
1. **메시지 요청**: 위젯/Provider → `global_sherpi_provider` → `SherpiMessageManager`.
2. **정적 우선 전략**: 항상 `StaticSherpiManager` 우선, 분석 다이얼로그에서만 AI 사용 (30포인트 차감).
3. **AI 호출**: `OpenAISherpiManager` → `OpenAIDialogueSource` → OpenAI GPT-5.
4. **캐시**: `AiMessageCache`(SharedPreferences 기반, 현재 비활성화) — 재활성화 시 TTL 24시간.
5. **감정/관계 업데이트**: 메시지 표시 후 `relationshipProvider`, `emotionAnalysisProvider` 통해 동기화.
6. **추천 연계**: `sherpiInsightRepositoryProvider`가 관계·감정 상태를 수집해 `global_ai_recommendation_provider`에 전달, 모임 추천 시 Sherpi 성향/감정 데이터를 함께 반영.

---

## 4. 주요 컴포넌트 설명
| 영역 | 파일 | 설명 |
| --- | --- | --- |
| Manager Interface | `sherpi_message_manager.dart` | 구현체 교체를 위한 추상화. |
| Static Manager | `static_sherpi_manager.dart` | 정적 메시지 전용. 성격/개인화 반영. |
| OpenAI Manager | `openai_sherpi_manager.dart` | 캐시·AI 하이브리드. 수동 트리거 + fallback. |
| Dialogue Source | `openai_dialogue_source.dart` | GPT-5 연동. 프롬프트 빌더 사용. |
| Prompt Templates | `activity_prompt_templates.dart` | 활동별 프롬프트. 회귀 시 참고. |
| Data Collector | `real_data_connector.dart` | 사용자/게임 컨텍스트 조합. (현재 일부 경로에서 주석 처리) |
| Domain Models | `sherpi_response.dart` 등 | Sherpi 메시지/관계/히스토리 일원화. |
| Provider | `global_sherpi_provider.dart` | 메시지 노출 상태 관리, 히스토리 저장. |
| Recommendation Provider | `global_ai_recommendation_provider.dart` | 모임 AI 추천 전역 상태/캐시 관리. |

---

## 5. 테스트 & 검증
- **단위 테스트 (실행 준비)**
  - `test/features/sherpi/managers/sherpi_managers_test.dart`
    - Static manager 개인화 반영 검증.
    - OpenAI manager fallback & 수동 AI 테스트 (Fake dialogue source).
- **향후 계획**
  1. Emotion → Provider → Widget 플로우 테스트 추가.
  2. AI 추천 캐시(모임 추천) TTL 검증.
  3. 감정 분석 위젯/다이얼로그 스냅샷 테스트.
- **실행 환경 제약**: WSL에서 `flutter` 명령 실행 시 CRLF 이슈 → Windows PowerShell 사용 권장.

---

## 6. 남은 TODO (요약)
1. **품질 검증**: `flutter analyze`, `dart format .`, `flutter test` 실행 및 결과 기록.
2. **문서 연동**: 다른 Sherpi 문서에 “Refer to docs/sherpi_system.md” 배너 삽입.
3. **AI 추천 전역화**: `global_ai_recommendation_provider` 구현 (가이드 Phase 4).
4. **캐시 정책 결정**: `AiMessageCache` 재활성화 여부, UI 토글 정의.
5. **자동 트리거 설계**: 컨텍스트별 AI 자동 호출 정책 확정.
6. **리스크 추적**: Provider 초기화 자동화, analyzer legacy 경고 해소 계획 수립.

---

## 7. 참고 문서
- 가이드: `codex/ai_sherpi_structure_guide.md`
- 통합 피드백: `structure/AI_SHERPI_UNIFIED_FEEDBACK.md`
- 작업 로그: `codex/ai_sherpi_structure_journal.md`
- 진행 현황: `codex/ai_sherpi_progress_status.md`
