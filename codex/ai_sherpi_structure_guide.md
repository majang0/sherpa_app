# AI & 셰르피 구조 정비 가이드

작성일: 2025-09-18  
작성자: Codex (GPT-5)  
참고 문서: `structure/AI_SHERPI_OPTIMIZATION_PLAN.md`, `structure/프로젝트_백로그.md`, `codex/ai_recommendation_refactoring_guide.md`, `docs/AI_SYSTEM.md`

---

## 0. 목적 및 범위
- AI · 셰르피 관련 소스, 자산, 문서를 일관된 구조로 재정비하기 위한 선행 가이드입니다.
- 실제 코드 수정 전에 **삭제·이동·통합 작업의 우선순위, 산출물, 검증 절차**를 명확히 하여 혼선 없이 진행하는 것을 목표로 합니다.
- 본 가이드는 2025-09-18 기준 리포지토리 상태를 반영합니다. 이후 변경이 발생하면 본 문서를 우선 업데이트한 뒤 작업을 진행하세요.

---

## 1. 현재 구조 스냅샷
| 영역 | 주요 경로 | 내용 요약 | 특이사항 |
| --- | --- | --- | --- |
| Core AI | `lib/core/ai/` | GPT-5/Gemini 소스, 캐시, 활동 프롬프트, SmartSherpiManager 2종 | `smart_sherpi_manager.dart`(정적)와 `_openai.dart`(하이브리드)가 공존. `gemini_dialogue_source.dart` 대신 `enhanced_gemini_dialogue_source.dart` 존재 |
| Sherpi Feature | `lib/features/sherpi/**` | 분석·대화·감정·관계 도메인 모듈 35개 파일 | 디렉터리 뼈대(`core/`, `data/`)는 비어 있음. 모델/서비스가 흩어져 있음 |
| Meetings AI | `lib/features/meetings/ai/**` | 모임 추천 AI 엔진, 모델, 프롬프트 | 글로벌 재사용 전제 없음. `codex/ai_recommendation_refactoring_guide.md` 대기 |
| Shared Layer | `lib/shared/` | `global_sherpi_provider.dart`, 메시지/관계 모델, 위젯 모음 | `SherpiResponse` 정의가 Core/Shared에 중복. 위젯들이 감정 ENUM 경로에 직접 의존 |
| Constants | `lib/core/constants/` | `sherpi_dialogues.dart`, `sherpi_emotions.dart` | Emotion ↔ Asset 매핑 산발적 사용 |
| Utils & Scripts | `lib/core/utils/sherpi_system_checker.dart`, `analyze_sherpi_structure.sh` | 시스템 점검/분석 스크립트 | AI 비활성화 주석 다수, 실행 결과 공유 경로 없음 |
| Assets | `assets/images/sherpi/`, 루트 `assets/images/sherpi_*.png` | 14종 감정 이미지 + 루트 4종 중복 | `pubspec.yaml` 자산 정리 필요 |
| 문서 | `docs/AI_SYSTEM.md`, `structure/AI_SHERPI_OPTIMIZATION_PLAN.md`, `sherpi/*.md`, `CLAUDE.md` | 동일 주제 문서 다수, 정보 중복/상충 | 신규 허브 `docs/sherpi_system.md` 미작성 |

---

## 2. 핵심 문제 진단
1. **관리 포인트 분산**: 동일 개념(예: SherpiResponse, 감정 ENUM, 자산 경로)이 Core/Shared/Feature에 중복 정의.
2. **폴더 구조 과포화**: `lib/features/sherpi/` 하위에 목적이 불분명한 빈 폴더(`core/`, `data/`)와 실제 사용 중인 개별 서비스 폴더 혼재.
3. **AI 매니저 이원화**: 정적 버전과 OpenAI 버전이 다른 파일명에서 동일 클래스를 정의(SmartSherpiManager). 주입 구조 없이 전역 Provider가 클래스를 직접 인스턴스화.
4. **문서/스크립트 불일치**: 최적화 계획과 실제 코드가 상충(`gemini_dialogue_source.dart` 언급, 실제는 `enhanced_gemini_dialogue_source.dart`). 운영 절차 문서가 여러 곳에 흩어져 최신 여부 확인 어려움.
5. **테스트/검증 공백**: AI 관련 테스트 디렉토리 부재. `flutter analyze`/`flutter test` 실행이 WSL 라인엔딩 문제로 중단된 상태.
6. **자산 관리 부재**: 루트와 하위 폴더에 중복 이미지가 공존하고, `pubspec.yaml` 자산 정의가 정비되지 않음.

---

## 3. 목표 구조 (제안)
```
lib/
├── core/
│   └── ai/
│       ├── managers/
│       │   └── smart_sherpi_manager.dart        # interface + 구현체 DI
│       ├── sources/
│       │   ├── openai_dialogue_source.dart
│       │   └── gemini_dialogue_source.dart
│       ├── services/
│       │   ├── activity_prompt_templates.dart
│       │   └── real_data_connector.dart
│       └── cache/
│           └── ai_message_cache.dart
├── features/
│   └── sherpi/
│       ├── domain/
│       │   ├── models/ (message, relationship, emotion state)
│       │   └── services/ (emotion, relationship, insight)
│       ├── data/
│       │   └── repositories/ (AI↔데이터 브리지)
│       └── presentation/
│           ├── providers/ (전역/지역 provider 래퍼)
│           └── widgets/
├── shared/
│   ├── providers/
│   │   └── global_sherpi_provider.dart          # feature provider 래퍼만 유지
│   └── widgets/
│       └── sherpi_*.dart                        # 프레젠테이션 컴포넌트
└── docs/
    └── sherpi_system.md (최신 단일 레퍼런스)
```

- `SherpiResponse`, `SherpiContext` 등 핵심 타입은 `lib/features/sherpi/domain/models/` 에 단일 정의로 이동.
- `features/meetings/ai` 는 글로벌 AI 추천 Provider 작업(`codex/ai_recommendation_refactoring_guide.md`)과 함께 `lib/features/ai_recommendations/` 등 공통 모듈로 승격하는 것을 목표로 합니다(Phase 4 참조).
- 자산은 `assets/images/sherpi/*` 만 유지하고, ENUM ↔ 파일 매핑은 `sherpi_emotions.dart` 내 `ModernSherpiAssetMap` 으로 일원화합니다.

---

## 4. 단계별 실행 계획

### Phase 0. 사전 준비 (0.5일)
- 리포지토리 상태 스냅샷: `git status`, `git branch`, 미리보기 스크린샷 확보.
- WSL 실행 이슈 해결: `/mnt/c/flutter/bin/*.bat` CRLF → LF 변환 또는 PowerShell에서 `flutter analyze` 실행.
- 기준선 기록: `flutter analyze`, `flutter test`, `dart format --set-exit-if-changed .` 결과를 `codex/ai_sherpi_structure_journal.md` 등으로 남깁니다.
- `analyze_sherpi_structure.sh` 실행 후 결과를 `codex/logs/`에 보관.

### Phase 1. 문서 및 용어 정리 (0.5일)
1. `docs/AI_SYSTEM.md`, `structure/AI_SHERPI_OPTIMIZATION_PLAN.md`, `sherpi/*.md` 내용을 비교.
2. `docs/sherpi_system.md` 작성: 최신 흐름, API, 자산 매핑, Provider 순서를 포함.
3. 기존 문서에는 헤더에 "(Deprecated, refer to docs/sherpi_system.md)" 배너 추가.
4. `structure/프로젝트_백로그.md` 2. AI & 셰르피 섹션을 본 계획으로 업데이트.

### Phase 2. 자산 및 스크립트 정리 (0.5일)
1. 중복 이미지 삭제 계획 수립: `assets/images/sherpi_*.png` (루트) → 사용 여부 `rg "sherpi_thumb.png"` 등으로 확인 후 제거.
2. `pubspec.yaml` `assets:` 섹션에서 삭제된 항목 정리.
3. `analyze_sherpi_structure.sh` 업데이트: 결과 리포트를 `codex/reports/` 로 내보내도록 수정.
4. 자산 변경 후 `flutter pub get` → `flutter run -d chrome` 간단 확인.

### Phase 3. 코드 구조 개편 (2~3일)
- **Step 3.1 SmartSherpiManager 통합**
  - `lib/core/ai/managers/` 생성, 인터페이스(`abstract class SherpiMessageManager`) 정의.
  - 정적/하이브리드 구현을 `smart_sherpi_manager_static.dart`, `smart_sherpi_manager_openai.dart` 로 분리.
  - `global_sherpi_provider.dart`는 DI(예: Provider override)로 구현체 선택.
  - `SherpiResponse`/`MessageSource` 단일화: `lib/features/sherpi/domain/models/sherpi_response.dart`.
- **Step 3.2 Sherpi 도메인 재배치**
  - `lib/shared/models/sherpi_*` → `lib/features/sherpi/domain/models/` 로 이동 후 export.
  - Emotion/Relationship 서비스 묶음을 `lib/features/sherpi/domain/services/` 로 통합, 중복 메서드 병합.
  - 빈 디렉터리(`core/`, `data/`) 정리 또는 실사용 코드 이동.
- **Step 3.3 Provider 계층 정리**
  - `global_sherpi_provider.dart`는 thin wrapper 로 유지, 실제 로직은 `features/sherpi/presentation/providers/` 로 이전.
  - `SherpiSystemChecker` 등 유틸은 `tools/diagnostics/` 등 명확한 위치로 이동.
  - `lib/features/sherpi/chat/providers` 와 중복 로직이 있는지 점검 후 통합/삭제.
- **Step 3.4 Naming/Import 정비**
  - 모든 임포트 `dart:` → `package:` → relative 순으로 정렬.
  - `SmartSherpiManager` 로그 `print` → `debugPrint` 또는 로거 통일.

### Phase 4. AI 추천 로직 전역화 연계 (1~1.5일)
- `codex/ai_recommendation_refactoring_guide.md` 에 따라 `lib/shared/providers/global_ai_recommendation_provider.dart` 생성.
- Sherpi 구조 개편 후, AI 추천 Provider가 Sherpi 통계/감정 데이터를 참조할 수 있도록 인터페이스 정의(`SherpiInsightRepository`).
- 모듈 간 순환 의존성 점검: `globalMeetingProvider` ↔ `sherpiProvider` 의존성 문서화.

### Phase 5. 테스트 & 검증 (0.5일)
- `test/features/sherpi/` 디렉터리 신설.
- 최소 3종 테스트 권장:
  1. SmartSherpiManager (정적/AI) fallback 동작.
  2. Emotion 서비스 → Provider → Widget 렌더링 흐름.
  3. 글로벌 추천 Provider 캐시 만료 로직.
- `flutter test`, `flutter analyze`, `dart format .` 결과를 문서화.

### Phase 6. 인수 & 배포 준비 (0.5일)
- 변경 요약을 `codex/meeting_system_review.md` 와 동일 포맷으로 작성.
- 필요 시 QA 스크립트(테스트 계정, 시뮬레이터) 공유.
- 최종 산출물 및 검증 로그를 `codex/reports/ai_sherpi_structure/` 디렉터리에 정리.

---

## 5. 삭제·통합 후보 체크리스트
- [ ] `lib/core/ai/smart_sherpi_manager.dart` (정적 버전) → 디렉토리 재배치 및 클래스명 중복 해소.
- [ ] `lib/core/ai/smart_sherpi_manager_openai.dart` → 인터페이스 기반 구조로 이동.
- [ ] `lib/shared/providers/global_sherpi_provider.dart` 내 `SherpiResponse`/`MessageSource` 중복 정의 제거.
- [ ] `lib/core/utils/sherpi_system_checker.dart` → Phase 1 기준에 맞춘 로그/리포트화.
- [ ] `assets/images/sherpi_thumb.png`, `assets/images/sherpi_normal.png`, `assets/images/sherpi_think.png` 등 루트 중복 자산 삭제.
- [ ] `docs/AI_SYSTEM.md` → 업데이트 또는 `Deprecated` 안내 추가.
- [ ] 미사용 Provider/Service (`lib/features/sherpi/relationship/providers/memory_provider.dart` 등) 사용 여부 확인 후 통합.
- [ ] 빈 디렉터리(`lib/features/sherpi/core/managers`) 정리.

---

## 6. 검증 절차
1. **정적 분석**: `flutter analyze` (PowerShell 실행 권장). 경고 목록을 Phase 5 리포트에 첨부.
2. **포맷팅**: `dart format .` → Git diff 확인.
3. **테스트**: `flutter test --coverage` (커버리지 XML을 `coverage/lcov.info` 로 유지).
4. **런타임 확인**: `flutter run -d chrome` 으로 Sherpi 플로팅 위젯/메시지 카드 동작 확인.
5. **문서 리뷰**: PR 템플릿에 본 가이드의 단계별 완료 여부 체크박스 추가.

---

## 7. 후속 백로그 & 리스크 관리
- `structure/프로젝트_백로그.md` 2. AI & 셰르피 시스템 섹션을 본 가이드의 Phase 구조로 갱신.
- `AI_SHERPI_OPTIMIZATION_PLAN.md` 의 Phase 2~4 항목과 이 가이드를 매핑하여 일정 재산정.
- 위험 요인(Provider 초기화 순서, AI 비용 상승, UI 회귀)은 단계별 회고에서 재점검.
- 셰르피 관련 로직이 Meeting, Quest, Daily Record 등 다른 도메인과 연결되는 지점은 **ID 기반 데이터 전달** 원칙을 문서화.
- AI 자동 트리거/캐시 재도입 시 본 가이드의 구조(Managers/Sources/Services 분리)를 준수해 확장합니다.

---

## 8. 산출물 요약
- `docs/sherpi_system.md` (최신 참조 허브)
- `codex/ai_sherpi_structure_journal.md` (실행 로그)
- `codex/reports/ai_sherpi_structure/` (스크립트 출력, 테스트, 분석 결과)
- 정리된 자산 목록 + `pubspec.yaml` 반영
- 단계별 PR/커밋: `Checkpoint: sherpi23 - AI structure phase X`

---

이 가이드를 기반으로 삭제·통합·재배치 작업을 순차적으로 진행하면, Sherpi AI 시스템을 재활성화하거나 글로벌 추천 로직과 연동하더라도 유지보수 부담 없이 확장할 수 있습니다.
