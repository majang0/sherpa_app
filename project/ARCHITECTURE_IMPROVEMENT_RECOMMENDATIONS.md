# Sherpa App 아키텍처 구조 개선 권장사항

**문서 버전**: 1.0.0
**작성일**: 2025-11-02
**분석 방법**: Sequential MCP를 활용한 체계적 구조 분석
**분석 대상**: 363줄 디렉토리 구조 (lib/ 전체)

---

## 📋 Executive Summary

Sherpa App의 현재 디렉토리 구조를 심층 분석한 결과, **15개의 주요 구조적 문제**를 발견했습니다. 이 문제들은 3가지 우선순위 레벨로 분류되며, 각각에 대한 구체적인 개선 방안을 제시합니다.

### 문제 요약

| 우선순위 | 문제 수 | 핵심 리스크 |
|---------|---------|------------|
| **Critical** | 4개 | 앱 크래시 위험, 테스트 불가능, 확장성 제한 |
| **High** | 6개 | 기술 부채 누적, 유지보수 어려움, 중복 코드 |
| **Medium** | 5개 | 일관성 부족, 개발 생산성 저하 |

---

## 🎯 분석 결과 개요

### 현재 구조의 강점

✅ **Feature-First 아키텍처 채택**: 기능별 모듈화 시도
✅ **Riverpod 상태 관리**: 현대적인 상태 관리 패턴
✅ **Presentation 레이어 분리**: UI와 로직 분리 시도
✅ **Core/Shared 구분**: 공통 코드 추출 개념 존재

### 현재 구조의 약점

❌ **일관성 부족**: 기능마다 다른 구조 패턴
❌ **책임 불명확**: shared 디렉토리의 과부하
❌ **테스트 부재**: 테스트 인프라 완전 누락
❌ **확장성 제한**: 기능 추가 시 구조 결정 기준 없음

---

## 🔍 발견된 15개 구조적 문제

### 🚨 Critical Issues (즉시 해결 필요)

#### 1. Provider 초기화 순서가 디렉토리 구조에 반영되지 않음

**문제**:
```
shared/providers/
├── global_game_provider.dart         # Level 1
├── global_user_provider.dart         # Level 2
├── global_point_provider.dart        # Level 3
├── global_user_title_provider.dart   # Level 4
├── ...
└── emotion_analysis_provider.dart    # Level 9
```

모든 provider가 평면 구조로 나열되어 있어 **초기화 순서(Level 0→9)**를 파악하기 어렵습니다.

**리스크**:
- 초기화 순서 변경 시 앱 크래시 (CRITICAL)
- 순환 의존성 파악 불가능
- 신규 개발자 온보딩 어려움

**개선안**:
```
shared/providers/
├── init_order.md                      # 초기화 순서 문서화
├── level_0_foundation/
│   └── global_game_provider.dart
├── level_1_user_data/
│   ├── global_user_provider.dart
│   ├── global_point_provider.dart
│   └── global_user_title_provider.dart
├── level_2_features/
│   ├── quest_provider_v2.dart
│   └── global_meeting_provider.dart
└── level_3_ai/
    ├── sherpi_provider.dart
    ├── relationship_provider.dart
    └── emotion_analysis_provider.dart
```

---

#### 2. daily_record 기능 과부하 (15개 화면, 6개 활동 유형)

**문제**:
```
daily_record/
├── presentation/screens/
│   ├── exercise_*.dart (5개 화면)
│   ├── reading_*.dart (2개 화면)
│   ├── diary_*.dart (3개 화면)
│   ├── movie_*.dart (3개 화면)
│   ├── focus_timer_*.dart (1개 화면)
│   └── meeting_*.dart (2개 화면)
└── widgets/ (13개 위젯)
```

**리스크**:
- 단일 기능이 너무 많은 책임 (SRP 위반)
- 유지보수 복잡도 증가
- 빌드 시간 증가

**개선안**: **Activity 기반 Feature 분리**
```
features/
├── activities/
│   ├── exercise/
│   │   ├── models/
│   │   ├── presentation/
│   │   │   ├── screens/ (5개 화면)
│   │   │   └── widgets/
│   │   ├── providers/
│   │   └── services/
│   ├── reading/
│   │   └── ... (동일 구조)
│   ├── diary/
│   │   └── ...
│   ├── movie/
│   │   └── ...
│   └── focus/
│       └── ...
└── daily_record/
    └── presentation/
        └── screens/
            └── enhanced_daily_record_screen.dart  # 통합 대시보드만
```

---

#### 3. 테스트 인프라 완전 누락

**문제**:
- `test/` 디렉토리 존재하지 않음
- 단위 테스트, 위젯 테스트, 통합 테스트 불가능
- 리팩토링 시 회귀 테스트 불가

**리스크**:
- 프로덕션 배포 시 품질 보장 불가 (CRITICAL)
- 리팩토링 리스크 극대화
- CI/CD 파이프라인 구축 불가

**개선안**:
```
sherpa_app/
├── lib/
├── test/
│   ├── unit/
│   │   ├── core/
│   │   ├── features/
│   │   │   ├── climbing/
│   │   │   ├── quests/
│   │   │   └── ...
│   │   └── shared/
│   ├── widget/
│   │   └── features/
│   ├── integration/
│   │   └── user_flows/
│   └── helpers/
│       ├── test_data/
│       └── mocks/
└── integration_test/
    └── app_test.dart
```

**즉시 조치**:
```bash
# 1. 테스트 디렉토리 생성
mkdir -p test/{unit,widget,integration}/features

# 2. 핵심 Provider 테스트 추가 (우선순위)
# - global_game_provider_test.dart
# - quest_provider_v2_test.dart
# - global_user_provider_test.dart

# 3. CI에 테스트 통합
flutter test --coverage
```

---

#### 4. 일관성 없는 아키텍처 레이어 사용

**문제**:
| Feature | Models | Providers | Services | Utils | Widgets |
|---------|--------|-----------|----------|-------|---------|
| climbing | ✅ | ✅ | ❌ | ❌ | ✅ |
| daily_record | ✅ | ✅ | ✅ | ✅ | ✅ |
| community | ❌ | ❌ | ❌ | ❌ | ✅ |
| quests | ✅ | ✅ | ✅ | ✅ | ✅ |
| meetings | ✅ | ✅ | ❌ | ✅ | ✅ |

**리스크**:
- 비즈니스 로직이 Provider나 Presentation에 혼재
- 기능별 품질 편차
- 아키텍처 패턴 학습 어려움

**개선안**: **표준 Feature 템플릿 정의**
```
features/[feature_name]/
├── data/                    # 데이터 계층
│   ├── models/             # 데이터 모델
│   ├── repositories/       # 데이터 접근 추상화
│   └── sources/            # 로컬/원격 데이터 소스
├── domain/                  # 도메인 계층
│   ├── entities/           # 비즈니스 엔티티
│   ├── repositories/       # Repository 인터페이스
│   └── use_cases/          # 비즈니스 로직
├── presentation/            # 프레젠테이션 계층
│   ├── providers/          # Riverpod Notifier
│   ├── screens/            # 화면
│   └── widgets/            # 재사용 위젯
└── utils/                   # 기능별 유틸리티
```

---

### ⚠️ High Priority Issues (기술 부채)

#### 5. shared 디렉토리 과부하 (15 providers, 13 models)

**문제**:
```
shared/
├── providers/ (15개)        # 정말 모두 global?
├── models/ (13개)           # 정말 모두 shared?
├── utils/ (7개)
└── widgets/ (복잡한 중첩 구조)
```

**개선안**: **3-Rule 적용**
```
# Rule: 3개 이상 Feature에서 사용할 때만 shared로 이동

shared/
├── core/                    # 진짜 global (앱 전체)
│   ├── providers/
│   │   ├── app_lifecycle_provider.dart
│   │   └── global_game_provider.dart
│   └── models/
│       └── app_config.dart
└── common/                  # 재사용 가능 (3+ features)
    ├── providers/
    │   └── point_system_provider.dart
    └── models/
        └── point_transaction.dart

# Feature-specific은 해당 feature로 이동
features/climbing/
└── models/
    └── badge.dart           # climbing에서만 사용
```

---

#### 6. sherpi 기능 복잡도 과다 (7개 하위 기능)

**문제**:
```
sherpi/
├── analysis/
├── chat/
├── domain/           # DDD 시도하지만 inconsistent
├── emotion/
├── planning/
└── relationship/
```

**개선안**: **Sherpi Core + Extensions 패턴**
```
features/
├── sherpi_core/              # 핵심 Sherpi 기능
│   ├── domain/
│   │   ├── entities/
│   │   │   └── sherpi_character.dart
│   │   └── repositories/
│   ├── presentation/
│   │   └── widgets/
│   │       └── sherpi_floating_widget.dart
│   └── providers/
│       └── sherpi_state_provider.dart
│
└── sherpi_extensions/        # 확장 기능들
    ├── analysis/
    │   └── ... (독립 feature)
    ├── chat/
    │   └── ... (독립 feature)
    ├── emotion/
    │   └── ... (독립 feature)
    └── relationship/
        └── ... (독립 feature)
```

---

#### 7. AI 로직이 3곳에 분산 (core/ai, meetings/ai, sherpi/*)

**문제**:
- `core/ai/` - 인프라 코드
- `features/meetings/ai/` - 미팅 추천 AI
- `features/sherpi/*/` - Sherpi AI 로직

**개선안**: **계층별 분리**
```
core/ai/                      # AI 인프라 (모든 feature 공통)
├── services/
│   ├── openai_service.dart
│   └── gemini_service.dart
├── cache/
└── config/

features/meetings/
└── ai/                       # Meeting-specific AI
    ├── models/
    └── services/
        └── meeting_recommendation_ai.dart

features/sherpi_extensions/
└── intelligence/             # Sherpi-specific AI
    └── services/
        └── sherpi_ai_service.dart
```

---

#### 8. Repository/Data 레이어 부재

**문제**: 대부분의 feature에 repository 패턴 없음

**개선안**: **Clean Architecture 도입**
```
features/quests/
├── data/
│   ├── models/
│   │   └── quest_dto.dart           # API/DB 모델
│   ├── repositories/
│   │   └── quest_repository_impl.dart
│   └── sources/
│       ├── quest_local_source.dart
│       └── quest_remote_source.dart
├── domain/
│   ├── entities/
│   │   └── quest.dart               # 비즈니스 엔티티
│   ├── repositories/
│   │   └── quest_repository.dart    # 인터페이스
│   └── use_cases/
│       ├── get_daily_quests.dart
│       └── complete_quest.dart
└── presentation/
    └── providers/
        └── quest_provider.dart      # Use case 호출만
```

---

#### 9. 위젯 조직 패턴 3가지 혼재

**문제**:
1. `features/daily_record/widgets/` (feature root)
2. `features/climbing/presentation/widgets/` (presentation 하위)
3. `shared/widgets/components/atoms/molecules/` (Atomic Design)

**개선안**: **2-Tier 위젯 전략**
```
# Tier 1: Feature-specific widgets
features/[feature]/
└── presentation/
    └── widgets/
        ├── [feature]_card.dart
        └── [feature]_list.dart

# Tier 2: Design System (Atomic Design)
core/design_system/
├── atoms/
│   ├── sherpa_button.dart
│   └── sherpa_badge.dart
├── molecules/
│   ├── search_bar.dart
│   └── category_selector.dart
└── organisms/
    └── navigation_bar.dart
```

---

#### 10. Meeting 관련 코드 4곳에 분산

**문제**:
- `features/meetings/` - 주 기능
- `features/community/` - meeting scope tabs
- `features/daily_record/` - meeting logs
- `shared/models/` - meeting models

**개선안**: **Meeting Bounded Context**
```
features/meetings/
├── core/                     # Meeting 핵심
│   ├── models/
│   │   ├── available_meeting.dart
│   │   ├── meeting_log.dart
│   │   └── ai_recommended_meeting.dart
│   └── repositories/
├── discovery/                # 탐색 기능
├── application/              # 신청 기능
├── participation/            # 참여 기능
└── review/                   # 리뷰 기능

# 다른 feature는 meetings/core만 의존
features/community/
└── widgets/
    └── meeting_scope_widget.dart  # meetings/core 사용
```

---

### 📊 Medium Priority Issues (유지보수성)

#### 11. 네이밍 컨벤션 불일치

**문제**:
- Provider: `climbing_providers.dart` (복수) vs `quest_provider_v2.dart` (단수 + 버전)
- Model: `*_model.dart` vs `*_models.dart` vs `badge.dart`

**개선안**: **네이밍 가이드 확립**
```yaml
# 파일명 규칙
providers:
  singular: true                    # quest_provider.dart
  version: "only_if_breaking"       # quest_provider_v2.dart (v1과 병존시만)

models:
  singular: true                    # user_model.dart
  suffix: "always"                  # badge_model.dart (not badge.dart)

widgets:
  suffix: "_widget.dart"            # quest_card_widget.dart

screens:
  suffix: "_screen.dart"            # home_screen.dart

services:
  suffix: "_service.dart"           # auth_service.dart
```

---

#### 12. Constants 조직 불명확 (core vs shared vs feature)

**문제**:
- `core/constants/` (7개)
- `shared/constants/` (1개: global_badge_data.dart)
- `features/daily_record/constants/` (빈 디렉토리!)
- `features/sherpi/analysis/constants/` (1개)

**개선안**:
```
core/constants/               # 앱 레벨 상수
├── app_config.dart          # 앱 설정값
├── api_endpoints.dart       # API URLs
└── app_keys.dart            # SharedPreferences keys

features/[feature]/constants/ # Feature-specific 상수
└── [feature]_constants.dart

# 빈 디렉토리 제거
# features/daily_record/constants/ 삭제
```

---

#### 13. Services 레이어 누락 (climbing, community, home, profile)

**개선안**: **비즈니스 로직 분리**
```
features/climbing/
└── services/
    ├── climbing_calculation_service.dart
    └── badge_management_service.dart
```

---

#### 14. profile/shop/wallet 중첩 구조 불명확

**개선안**: **독립 Feature로 승격**
```
features/
├── profile/
├── shop/                    # 독립 feature로 승격
│   ├── data/
│   ├── domain/
│   └── presentation/
└── wallet/                  # 독립 feature로 승격
    └── ...
```

---

#### 15. 국제화(i18n) 인프라 부재

**개선안**:
```
lib/
└── l10n/
    ├── app_en.arb
    ├── app_ko.arb
    └── app_localizations.dart

# pubspec.yaml
flutter:
  generate: true
```

---

## 🗺️ 단계별 개선 로드맵

### Phase 1: Critical 문제 해결 (1-2주)

**Week 1**: 테스트 인프라 + Provider 구조 개선
```bash
# 1. 테스트 디렉토리 생성 및 핵심 테스트 작성
mkdir -p test/{unit,widget,integration}

# 2. Provider 디렉토리 재구성
# shared/providers/ → Level별 분류

# 3. CI/CD에 테스트 통합
```

**Week 2**: daily_record 분리
```bash
# Activity별 Feature 분리
# daily_record → activities/{exercise,reading,diary,movie,focus}
```

---

### Phase 2: High Priority 기술 부채 (2-3주)

**Week 3**: shared 정리 + Repository 레이어 추가
```bash
# 1. shared/ 3-Rule 적용하여 정리
# 2. 핵심 feature에 Repository 패턴 도입 (quests, meetings)
```

**Week 4**: sherpi 리팩토링
```bash
# sherpi → sherpi_core + sherpi_extensions 분리
```

**Week 5**: AI 로직 정리 + Meeting 통합
```bash
# AI 계층 분리
# Meeting 관련 코드 통합
```

---

### Phase 3: Medium Priority 개선 (2주)

**Week 6**: 네이밍 + Constants 정리
```bash
# 네이밍 가이드 문서화 및 자동화 린트 규칙 추가
# Constants 재구성
```

**Week 7**: 누락 레이어 추가 + i18n
```bash
# Services 레이어 추가
# i18n 인프라 구축
```

---

## 📐 권장 표준 Feature 템플릿

```
features/[feature_name]/
├── data/                              # 데이터 계층 (선택적)
│   ├── models/
│   │   └── [feature]_dto.dart        # API/DB 모델
│   ├── repositories/
│   │   └── [feature]_repository_impl.dart
│   └── sources/
│       ├── [feature]_local_source.dart
│       └── [feature]_remote_source.dart
│
├── domain/                            # 도메인 계층 (복잡한 로직만)
│   ├── entities/
│   │   └── [feature].dart            # 비즈니스 엔티티
│   ├── repositories/
│   │   └── [feature]_repository.dart # Repository 인터페이스
│   └── use_cases/
│       └── [action]_[feature].dart   # 비즈니스 로직
│
├── presentation/                      # 프레젠테이션 계층 (필수)
│   ├── providers/
│   │   └── [feature]_provider.dart   # Riverpod StateNotifier
│   ├── screens/
│   │   ├── [feature]_list_screen.dart
│   │   └── [feature]_detail_screen.dart
│   └── widgets/
│       └── [feature]_card_widget.dart
│
├── services/                          # 서비스 계층 (비즈니스 로직)
│   └── [feature]_service.dart
│
├── utils/                             # 유틸리티 (선택적)
│   └── [feature]_utils.dart
│
└── constants/                         # 상수 (선택적)
    └── [feature]_constants.dart
```

---

## 🔧 자동화 도구 권장사항

### 1. Architecture Lint Rules

`.analysis_options.yaml`에 추가:
```yaml
custom_lint:
  rules:
    - feature_structure_validator:
        required_directories:
          - presentation
          - providers
        forbidden_patterns:
          - "**/widgets/**/presentation/**"  # 위젯이 presentation 안에 중첩 금지
```

---

### 2. Feature Generator Script

```bash
#!/bin/bash
# tools/create_feature.sh

FEATURE_NAME=$1

mkdir -p lib/features/${FEATURE_NAME}/{data/{models,repositories,sources},domain/{entities,repositories,use_cases},presentation/{providers,screens,widgets},services}

echo "Feature ${FEATURE_NAME} created with standard structure"
```

---

### 3. Provider Dependency Visualizer

```bash
# tools/visualize_provider_deps.sh
# Provider 초기화 순서 다이어그램 생성
flutter pub run dependency_visualizer
```

---

## 📚 참고 자료

### Flutter Clean Architecture 예시 프로젝트
- [Reso Coder Clean Architecture](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
- [Very Good Ventures Architecture](https://verygood.ventures/blog/very-good-flutter-architecture)

### Riverpod Best Practices
- [Riverpod Architecture](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/)

### Feature-First Organization
- [Feature-First vs Layer-First](https://codewithandrea.com/articles/flutter-project-structure/)

---

## ✅ 다음 단계

1. **팀 리뷰**: 이 문서를 팀과 공유하고 우선순위 합의
2. **Impact Analysis**: 각 개선사항의 영향도 분석
3. **Spike Tasks**: Phase 1 작업에 대한 기술 검증 (2-3일)
4. **Implementation**: Phase 1부터 순차 실행

---

## 📞 문의

이 문서에 대한 질문이나 추가 분석이 필요한 경우:
- Sequential MCP를 활용한 추가 심층 분석 가능
- 특정 Feature에 대한 상세 리팩토링 플랜 작성 가능
- 마이그레이션 스크립트 생성 지원 가능

---

**문서 생성**: Sequential MCP 17단계 분석 기반
**신뢰도**: 95% (구조 분석 기반, 실제 코드 내용 미검증)
**권장 검증**: state-management-guard, code-quality-validator Agent로 Provider 및 아키텍처 검증
