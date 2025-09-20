# AI/Sherpi System Code Review (2025-09-20)

본 리뷰는 Phase 0~3, Stage A까지 완료된 셰르피/AI 재구성 결과를 대상으로 하며, 폴더 구조·코드 품질·운영 관점에서의 주요 관찰과 개선 제안으로 구성되어 있습니다.

---

## ✅ 긍정적인 관찰
- **디렉터리 구조 정돈**: `lib/core/ai/`가 `cache/`, `managers/`, `services/`, `sources/`로 정리되어 책임 경계가 명확합니다. 루트 중복 파일과 Gemini 관련 소스가 제거되어 의존성 추적이 쉬워졌습니다.
- **플로팅 메시지 정적화**: `SherpiNotifier`가 `StaticSherpiManager`만 주입받도록 고정되어 Stage A 목표(즉시 응답, 일관성 유지)가 달성되었습니다.
- **추천/캐시 백엔드 보완**: `AiMessageCache`의 사용자·컨텍스트 기반 키, TTL 매핑 개선과 `MeetingRecommendationAI`의 SherpiInsights 전달 로직은 재방문 시나리오 성능을 높여줄 것으로 기대됩니다.
- **문서/계획 갱신**: `AI_SHERPI_CONSOLIDATED_PLAN_20250920.md` Rev.2, `PHASE4_REVISED_PLAN.md` 등을 통해 향후 Stage B~E 작업 범위와 단계가 명확히 정의되어 있습니다.

---

## ⚠️ 주요 리스크 및 개선 사항

### 1. 분석 포인트 차감 로직 미적용 (`lib/features/sherpi/analysis/services/ai_insight_generator.dart`)
- `_hasEnoughPoints()`와 `_deductPoints()`가 정의되어 있으나 `generateAIInsights`, `generateAIRecommendations`, `generateSmartGrowthPlan` 내부에서 호출되지 않습니다.
- 현재 상태에서는 포인트가 부족해도 분석이 실행되며 비용 통제 목적이 달성되지 않습니다.

**제안**
```dart
Future<List<Insight>> generateAIInsights(...) async {
  if (_ref == null || !_hasEnoughPoints()) {
    throw InsufficientPointsException('포인트 부족');
  }
  if (!await _deductPoints()) {
    throw InsufficientPointsException('포인트 차감 실패');
  }
  ...
}
```
- 세 메서드 모두 동일한 방식으로 포인트 확인 → 차감 → AI 호출 순서를 적용하고, 실패 시 명시적 예외를 던져 UI에서 안내 다이얼로그를 띄우도록 합니다.

### 2. 포인트 부족 시 UI 차단 로직 불완전 (`lib/shared/widgets/dialogs/analysis_pages/comprehensive_analysis_page.dart`)
- 보고서에 따르면 포인트 부족 시 즉시 차단하도록 설계되었으나, 기존 리팩터링된 `AiInsightGenerator`에 차감 로직이 누락되어 실제로는 차단되지 않습니다.
- Stage B~C에서 UI와 서비스 양쪽에 동일한 정책이 반영되도록 통일이 필요합니다.

### 3. Legacy 매니저 활용 범위 명확화
- `lib/features/sherpi/chat/providers/*`에서 `legacy/smart_sherpi_manager(*).dart`가 계속 사용되고 있습니다.
- Stage 계획상 플로팅/채팅 메시지는 정적으로 유지하기로 했으므로, 채팅 경로 역시 정적 매니저 또는 향후 분석 다이얼로그에서만 AI를 호출하도록 정리가 필요합니다. (Legacy 매니저는 분석 다이얼로그로 이동하거나 테스트 자산으로 한정 권장)

### 4. 문서/코드 간 불일치
- `docs/sherpi_system.md` 등 일부 문서에 `enableAIForNextMessage()` 사용 안내가 남아 있습니다. Stage A 결과와 맞추어 정적 전용 구조로 문서 업데이트가 필요합니다.
- `codex/ai_sherpi_progress_status.md`에도 `debugForceAI` 토글 관련 언급이 남아 있으므로, Stage A 결과에 맞게 정리해야 합니다.

### 5. 테스트 공백
- Stage A 작업 후에는 테스트를 재실행하지 않았습니다. 주요 경로(플로팅 메시지, 제거된 AI 훅)에 대한 회귀 테스트 실행이 권장됩니다. (`flutter test` 전체 실행 또는 관련 테스트 subset)

### 6. 분석 AI Feature Flag 준비 부족
- Stage B에서 도입 예정인 `AnalysisAIConfig`/Provider가 아직 정의되지 않았으며, `AiInsightGenerator`는 기본값으로 OpenAI를 바로 호출합니다.
- Stage B 착수 시점에 설정 값을 주입할 수 있도록 constructor 또는 ref 기반 설정 주입 구조를 마련해야 합니다.

### 7. 캐시/사용량 관측성
- `AiMessageCache`와 분석 호출 횟수에 대한 메트릭 노출이 아직 없습니다. Stage C~E에서 로그/모니터링 지표를 정의하고, 최소한 debug 로그에 캐시 히트/미스/만료 정보를 남기는 것이 좋습니다.

---

## 📝 권장 액션 아이템 요약
| 우선순위 | 항목 | 설명 |
|---------|------|------|
| 🔴 높음 | 포인트 차감 적용 | `AiInsightGenerator` 3개 API에 포인트 확인/차감 로직 삽입, UI와 동기화 |
| 🔴 높음 | 테스트 재실행 | Stage A 변경 후 `flutter test` 전체 실행 및 회귀 확인 |
| 🟠 중간 | Legacy 매니저 정리 | 채팅 경로에서 AI 호출 여부 재검토, 필요한 경우 정적 매니저로 대체 |
| 🟠 중간 | 문서 정합성 | `docs/sherpi_system.md`, `ai_sherpi_progress_status.md` 등 Stage A 결과 반영 |
| 🟢 보통 | Feature Flag 준비 | Stage B 실행 전 `analysis_ai_config.dart` 설계 및 Provider 뼈대 추가 |
| 🟢 보통 | 관측성 강화 | 캐시/분석 호출 로그 및 간단한 메트릭 수집 포인트 마련 |

---

## 📚 참고 경로
- `lib/shared/providers/global_sherpi_provider.dart`
- `lib/features/sherpi/analysis/services/ai_insight_generator.dart`
- `lib/features/sherpi/chat/providers/*`
- `codex/AI_SHERPI_CONSOLIDATED_PLAN_20250920.md` (Rev.2)
- `codex/PHASE4_REVISED_PLAN.md`

---

## 결론
플로팅 메시지 정적화와 추천/캐시 백엔드 정비는 안정적인 기반을 마련했습니다. 다음 단계(Stage B~E)는 분석 다이얼로그 전용 AI 기능의 안정화·비용 통제·관측성 확보에 집중해야 합니다. 우선적으로 포인트 차감 로직 미적용 문제를 해결한 뒤, Feature Flag/캐시/테스트 체계를 순차적으로 도입하는 것을 권장합니다.
