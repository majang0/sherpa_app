# Wave Mode 영향도 분석 보고서

**작성자**: role1-architect-orchestrator
**작성일**: 2025-11-01
**브랜치**: code-quality-improvement-waves
**복잡도**: 1.00/1.00 (최대치)

---

## 📊 Executive Summary

### 분석 결과
- **총 파일 수**: 240개 Dart 파일
- **총 이슈 수**: 289개
- **예상 작업 시간**: 95.5시간 (병렬화 시 28-57시간)
- **위험도**: HIGH (Provider 초기화, 755개 색상 변경)

### 주요 발견사항

#### ✅ 좋은 소식
1. **quest_screen_redesigned.dart**: Legacy Provider 사용 없음!
   - 변수명이 `questProvider`이지만 실제로는 `questProviderV2` 사용
   - CODE_QUALITY_ANALYSIS_REPORT.md의 오류 정정
   - **Phase 1 작업량 50% 감소** (2개 → 1개 파일)

2. **Provider 초기화 순서**: 이미 올바름!
   - main.dart:207-240에서 Level 0 → 1 → 2 → 3 순서 준수
   - questProviderV2는 Level 2에 올바르게 위치

#### ⚠️ 주의 사항
1. **Phase 1 (CRITICAL)**: 1개 파일만 수정 필요
   - quest_provider_v2.dart:54-69 - Quest 초기화 코드

2. **Phase 2 (HIGH)**: 레거시 색상 사용 확인
   - 공유 위젯 6개 (최우선)
   - Climbing 위젯 6개 (일부 God Class와 중복)

---

## 🔍 Phase별 상세 분석

### Phase 1: CRITICAL (Wave 2)

**작업 범위**: 1개 파일 (50% 감소!)
**예상 시간**: 30분 (45분 감소)
**위험도**: 🚨 HIGH

#### 수정 파일
| 파일 | 위치 | 문제 | 수정 방법 |
|------|------|------|----------|
| `quest_provider_v2.dart` | Lines 54-69 | 프로덕션 데이터 초기화 | `if (kDebugMode)` 가드 추가 |

#### 의존성 분석
```
quest_provider_v2.dart
├── 의존 Provider:
│   ├── globalUserProvider (Level 1) ✅
│   ├── globalPointProvider (Level 1) ✅
│   └── globalSherpiProvider (Level 3) ✅
└── 초기화 순서: Level 2 ✅ 올바름
```

#### 영향 범위
- **직접 영향**: 퀘스트 시스템 전체
- **간접 영향**: globalUserProvider, globalPointProvider 호출하는 모든 곳
- **사용자 영향**: 앱 재시작 시 퀘스트 진행 상황 보존

#### 리스크 평가
- **앱 크래시 가능성**: 5% (초기화 순서 이미 올바름)
- **데이터 손실**: 0% (kDebugMode 가드 추가만)
- **롤백 필요성**: 낮음

---

### Phase 2: HIGH (Wave 3)

**작업 범위**: 48개 파일, 755개 인스턴스
**예상 시간**: 22.5시간
**위험도**: ⚠️ MEDIUM

#### 우선순위별 파일

**P0: 공유 위젯 (6개) - 2.5시간**
1. `shared/widgets/sherpa_button.dart` - 전체 앱 버튼
2. `shared/widgets/sherpa_clean_app_bar.dart` - 전체 앱 앱바
3. `shared/widgets/sherpa_card.dart` - 전체 앱 카드
4. `shared/widgets/global_sherpi_widget.dart` - Sherpi UI
5. `shared/widgets/point_display_widget.dart` - 포인트 표시
6. `shared/widgets/sherpi_personalization_dialog.dart` - Sherpi 설정

**P1: Climbing (6개) - 5.5시간**
1. `climbing/widgets/ascent_dashboard_widget.dart` (1649 lines) ⚠️ God Class
2. `climbing/widgets/climbing_power_analysis_widget.dart` (1400 lines) ⚠️ God Class
3. `climbing/widgets/animated_rpg_level_card.dart`
4. `climbing/widgets/user_stats_summary_widget.dart`
5. `climbing/widgets/today_growth_widget.dart`
6. `climbing/widgets/badge_management_widget.dart`

**P2: Daily Record (15개) - 6.5시간**
- exercise_detail_screen.dart, exercise_dashboard_screen.dart, etc.

**P3: 기타 (21개) - 8시간**
- Profile, Home, Sherpi, Meetings, Community

#### 의존성 분석
```
ModernColors (core/theme/modern_colors.dart)
└── 영향받는 파일들:
    ├── shared/widgets/** (6개) → 전체 앱 영향
    ├── features/climbing/** (6개) → Climbing 기능
    ├── features/daily_record/** (15개) → Daily Record 기능
    └── features/** (21개) → 기타 기능들
```

#### 마이그레이션 패턴
```dart
// ❌ Before
import '../../core/constants/app_colors.dart';
color: AppColors.primary
background: RecordColors.exercisePastel

// ✅ After
import '../../core/theme/modern_colors.dart';
color: ModernColors.primaryBlue
background: ModernColors.exercisePastel
```

#### 리스크 평가
- **UI 불일치**: 60% (755개 변경)
- **빌드 실패**: 10% (import 경로 변경)
- **시각적 회귀**: 50% (색상 매핑 오류 가능성)
- **롤백 필요성**: 중간

#### 검증 전략
1. P0 (공유 위젯) 완료 후 즉시 `flutter run` → 시각적 확인
2. ui-design-validator Agent 자동 검증
3. 각 Priority 완료 시마다 검증

---

### Phase 3: MEDIUM (Wave 4)

**작업 범위**: 60개 God Class, 142개 중복 코드
**예상 시간**: 52시간
**위험도**: ⚠️ MEDIUM

#### God Class 리팩토링 (60개)

**TOP 5 우선순위**
| 순위 | 파일 | 줄 수 | 복잡도 | 예상 시간 |
|------|------|-------|--------|----------|
| 1 | `core/ai/services/activity_analysis_service.dart` | 1,884 | HIGH | 4h |
| 2 | `climbing/widgets/ascent_dashboard_widget.dart` | 1,649 | HIGH | 3.5h |
| 3 | `climbing/widgets/climbing_power_analysis_widget.dart` | 1,400 | HIGH | 3h |
| 4 | `core/constants/sherpi_dialogues.dart` | 1,086 | LOW | 2h |
| 5 | `meetings/screens/new_meeting_discovery_screen.dart` | 982 | MEDIUM | 2.5h |

#### 중복 코드 제거 (142개)

**패턴별 분류**
- 중복 버튼 스타일: 112개 → `SherpaButton` 확장
- 중복 애니메이션: 30개 → `CommonAnimations` 생성

#### 의존성 영향
```
God Class 리팩토링
├── 직접 영향: 리팩토링되는 파일 자체
├── 간접 영향: 해당 파일을 import하는 모든 파일
└── 테스트 영향: 관련 테스트 코드 수정 필요
```

#### 리스크 평가
- **로직 손상**: 40% (리팩토링 오류)
- **테스트 실패**: 50% (구조 변경)
- **Import 깨짐**: 30% (파일 이동 시)
- **롤백 필요성**: 중간

---

### Phase 4: LOW (Wave 5)

**작업 범위**: 141개 미사용 코드
**예상 시간**: 20시간
**위험도**: ✅ LOW

#### Dead Code 제거
- 미사용 변수: 94개
- 미사용 메서드: 47개
- 미사용 필드: 8개

#### Code Smells
- Long Parameter List: 15개
- Magic Numbers: 40개
- Deeply Nested Code: 22개

#### 리스크 평가
- **실수 제거**: 5% (실제 사용 중인 코드 제거)
- **롤백 필요성**: 매우 낮음

---

## 🎯 롤백 체크포인트 전략

### Git 브랜치 구조
```
optimize/meeting-tab-meet1 (현재 브랜치)
└── code-quality-improvement-waves (새 브랜치) ✅ 생성 완료
    ├── Checkpoint 0: 분석 리포트 커밋 ✅ 완료
    ├── Wave 1 완료: 영향도 분석 (예정)
    ├── Wave 2 완료: Phase 1 CRITICAL (예정)
    ├── Wave 3 완료: Phase 2 HIGH (예정)
    ├── Wave 4 완료: Phase 3 MEDIUM (예정)
    └── Wave 5 완료: Phase 4 LOW (예정)
```

### 롤백 명령어
```bash
# Wave 2 롤백 (Phase 1)
git reset --hard HEAD~1

# Wave 3 롤백 (Phase 2)
git reset --hard HEAD~2

# 전체 롤백 (Wave Mode 시작 전)
git reset --hard optimize/meeting-tab-meet1
git branch -D code-quality-improvement-waves
```

### 검증 게이트
| Wave | 검증 방법 | 통과 기준 |
|------|----------|----------|
| Wave 2 | `flutter run` + state-management-guard | 앱 부팅 성공, Provider 순서 OK |
| Wave 3 | `flutter run` + ui-design-validator | UI 시각적 확인, 레거시 색상 0개 |
| Wave 4 | `flutter analyze` + code-quality-validator | Errors 0, God Class 감소 |
| Wave 5 | `flutter analyze` + 최종 검증 | Warnings 0, Dead Code 0 |

---

## 📊 의존성 매트릭스

### Provider 의존성 그래프
```
Level 0: globalGameProvider
         └─ (의존성 없음)

Level 1: globalUserProvider, globalPointProvider, globalUserTitleProvider
         ├─ globalGameProvider 의존
         └─ 서로 독립

Level 2: questProviderV2 ✅, globalMeetingProvider
         ├─ globalUserProvider 의존
         └─ globalPointProvider 의존

Level 3: sherpiProvider, relationshipProvider, emotionAnalysisProvider
         ├─ questProviderV2 의존
         └─ globalUserProvider 의존
```

### Feature 의존성
```
Quest Feature
├── Providers: questProviderV2 (Level 2)
├── 의존 Provider: globalUserProvider, globalPointProvider
└── 영향 범위: Home, Profile, Sherpi

Meeting Feature
├── Providers: globalMeetingProvider (Level 2)
├── 의존 Provider: globalUserProvider, globalPointProvider
└── 영향 범위: Meeting 탭 전체

Climbing Feature
├── Providers: 없음 (globalUserProvider 직접 사용)
├── 의존 Provider: globalUserProvider, globalGameProvider
└── 영향 범위: Level Up 탭 전체

Daily Record Feature
├── Providers: 없음 (globalUserProvider 직접 사용)
├── 의존 Provider: globalUserProvider, globalPointProvider
└── 영향 범위: Home, Quest
```

---

## 🚨 위험 요소 및 대응 전략

### HIGH 리스크

#### 1. Provider 초기화 순서 변경
**발생 가능성**: 낮음 (Phase 1에서 순서 변경 없음)
**영향도**: 극도로 높음 (앱 크래시)
**대응**:
- state-management-guard Agent 필수 검증
- Wave 2 완료 후 즉시 `flutter run` 테스트
- 문제 발생 시 즉시 롤백

#### 2. 대규모 색상 변경 (755개)
**발생 가능성**: 중간 (수동 작업 오류)
**영향도**: 높음 (UI 전체 영향)
**대응**:
- P0 공유 위젯 먼저 수정 (전체 앱 즉시 영향)
- 각 Priority 완료 시마다 시각적 검증
- ui-design-validator Agent 자동 검증
- 색상 매핑 테이블 작성

### MEDIUM 리스크

#### 3. God Class 리팩토링 (60개)
**발생 가능성**: 중간 (복잡한 리팩토링)
**영향도**: 중간 (기능 손상 가능)
**대응**:
- TOP 10 우선 처리 (가장 복잡한 것부터)
- 각 파일 리팩토링 후 `flutter analyze`
- 점진적 리팩토링 (한 번에 1개씩)
- code-quality-validator Agent 검증

### LOW 리스크

#### 4. Dead Code 제거 (141개)
**발생 가능성**: 낮음 (명확한 미사용 코드)
**영향도**: 낮음 (사용 안 함)
**대응**:
- IDE "Find Usages" 재확인
- 1주일 모니터링 후 완전 제거
- 최종 검증 통과

---

## ⏱️ 예상 타임라인

### Wave별 소요 시간 (병렬화 적용)

| Wave | Phase | 예상 시간 | 실제 시간 (병렬) | 감소율 |
|------|-------|----------|-----------------|--------|
| Wave 1 | 준비 | 2h | 2h | 0% |
| Wave 2 | Phase 1 | 1h | 30min | 50% (파일 수 감소) |
| Wave 3 | Phase 2 | 22.5h | 6-9h | 60-70% (Sub-Agent) |
| Wave 4 | Phase 3 | 52h | 15-25h | 50-70% (병렬 리팩토링) |
| Wave 5 | Phase 4 | 20h | 10-15h | 25-50% (자동화) |
| **총계** | | **97.5h** | **33.5-51.5h** | **47-66%** |

### 실행 계획
```
Day 1:
  - Wave 1: 영향도 분석 (2h) ✅ 완료
  - Wave 2: Phase 1 (30min)
  - Wave 2 검증 (30min)

Day 2-3:
  - Wave 3: Phase 2 (6-9h)
    - P0 공유 위젯 (2.5h)
    - P1 Climbing (5.5h → 2h 병렬)
  - Wave 3 검증 (1h)

Day 4-6:
  - Wave 4: Phase 3 (15-25h)
    - God Class TOP 10 (26.5h → 10h 병렬)
    - 중복 코드 (17.5h → 7h 병렬)
  - Wave 4 검증 (2h)

Day 7-8:
  - Wave 5: Phase 4 (10-15h)
  - 최종 검증 (2h)
```

---

## ✅ Wave 1 완료 체크리스트

- [x] Git 브랜치 생성 (`code-quality-improvement-waves`)
- [x] 분석 리포트 커밋 (안전한 체크포인트)
- [x] Provider 초기화 순서 검증 (올바름)
- [x] Phase 1 파일 확인 (1개로 감소!)
- [x] Phase 2 공유 위젯 확인 (6개)
- [x] Phase 3 God Class 확인 (60개+)
- [x] 의존성 매트릭스 작성
- [x] 리스크 평가 완료
- [x] 롤백 전략 수립
- [x] 영향도 분석 보고서 작성

---

## 🎯 다음 단계: Wave 2 실행 준비

**Wave 2 목표**: Phase 1 CRITICAL 이슈 해결
**예상 시간**: 30분 (45분 감소!)
**수정 파일**: 1개 (quest_provider_v2.dart)

**Wave 2 실행 전 확인**:
- [ ] Wave 1 분석 리포트 승인
- [ ] role4 Skill 호출 준비
- [ ] state-management-guard Agent 대기
- [ ] `flutter run` 테스트 환경 준비

---

**문서 버전**: 1.0.0
**마지막 업데이트**: 2025-11-01
**다음 검토**: Wave 2 시작 전
**승인 상태**: ⏳ 사용자 승인 대기
