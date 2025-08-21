# 셰르파 앱 코드 최적화 계획서

> 작성일: 2025년 8월 11일  
> 분석 도구: Claude Code with Sequential Thinking & Ultra-Think  
> 프로젝트 규모: 156,319 lines of Dart code

## 📊 1. 현재 상태 분석

### 1.1 코드 규모 및 복잡도

| 항목 | 현재 상태 | 문제점 |
|------|-----------|---------|
| **총 코드 라인** | 156,319 lines | 관리 및 빌드 시간 증가 |
| **1000줄 이상 파일** | 30개 이상 | 유지보수 어려움 |
| **최대 파일 크기** | component_viewer_screen.dart (3,227줄) | 개발용 파일이 프로덕션에 포함 |
| **Feature 모듈** | 14개 | sherpi 기능이 6개로 분산 |
| **2025 버전 파일** | 35개 | 기존 버전과 중복 |

### 1.2 주요 문제점

#### 🔴 Critical Issues (즉시 수정 필요)
1. **개발용 코드가 프로덕션에 포함**
   - `component_viewer_screen.dart` (3,227줄)
   - `SharedPreferences.clear()` 호출 코드
   - 샘플 데이터 생성 로직

2. **God Object 안티패턴**
   - `global_user_provider.dart` (2,331줄) - 너무 많은 책임
   - 단일 파일에 과도한 로직 집중

3. **Provider 순환 참조 위험**
   - Global providers 간 복잡한 상호 의존성
   - 초기화 순서에 민감한 구조

#### 🟡 Major Issues (중기 개선 필요)
1. **컴포넌트 시스템 중복**
   - 기존 버전과 2025 버전 혼재 (35개 파일)
   - 일관성 없는 사용 패턴

2. **Feature 모듈 분산**
   - Sherpi 관련 기능이 6개 모듈로 분산
   - Meeting 모델이 3개로 분리

3. **대형 위젯 파일**
   - `exercise_summary_widget.dart` (2,164줄)
   - `new_meeting_discovery_screen.dart` (1,895줄)

#### 🟢 Minor Issues (장기 개선 사항)
1. **TODO/FIXME 코멘트** - 6개 발견
2. **Deprecated 메서드** - 2개 발견
3. **사용되지 않는 예제 파일** - 2개

## 🎯 2. 최적화 목표

### 2.1 단기 목표 (1-2주)
- [ ] 개발용 코드 제거 또는 조건부 컴파일
- [ ] 사용되지 않는 파일 및 코드 제거
- [ ] Critical 버그 수정
- [ ] **예상 코드 감소: 10-15% (약 15,000-23,000줄)**

### 2.2 중기 목표 (1-2개월)
- [ ] Provider 리팩토링 및 의존성 정리
- [ ] 컴포넌트 시스템 통합 (2025 버전으로 마이그레이션)
- [ ] 대형 파일 분할 (1000줄 이하로)
- [ ] **예상 코드 감소: 추가 10-15%**

### 2.3 장기 목표 (3-6개월)
- [ ] Feature 모듈 재구성 (Sherpi 통합)
- [ ] 아키텍처 패턴 개선 (Clean Architecture 적용)
- [ ] 성능 최적화 및 메모리 관리
- [ ] **최종 목표: 100,000줄 이하로 감소 (35% 감소)**

## 📋 3. 단계별 최적화 계획

### Phase 1: 즉시 제거 가능한 코드 정리 (3-5일)

#### 작업 내용
```dart
// 제거 대상 파일 목록
1. lib/shared/presentation/screens/component_viewer_screen.dart (3,227줄)
2. lib/features/sherpi_personalization/personalization_usage_example.dart
3. lib/features/sherpi_personalization/relationship_growth_usage_example.dart
4. lib/core/utils/phase1_performance_benchmark.dart
```

#### 조건부 컴파일 적용
```dart
// main.dart 수정
void _initializeGlobalProviders(WidgetRef ref) {
  // #ifdef DEBUG
  // ref.read(globalUserProvider.notifier)._initializeAndClearData();
  // #endif
  
  // 프로덕션 코드만 실행
  ref.read(globalGameProvider);
  ref.read(globalUserProvider);
  // ...
}
```

#### 예상 효과
- **코드 감소**: 약 5,000줄
- **빌드 시간**: 10-15% 단축
- **앱 크기**: 5-10% 감소

### Phase 2: Provider 리팩토링 (1-2주)

#### GlobalUserProvider 분할 계획
```
현재: global_user_provider.dart (2,331줄)

분할 후:
├── providers/
│   ├── user_core_provider.dart (300줄)
│   ├── user_stats_provider.dart (400줄)
│   ├── user_activity_provider.dart (500줄)
│   ├── user_achievement_provider.dart (400줄)
│   └── user_sample_data_provider.dart (300줄) // 개발용
```

#### Provider 의존성 개선
```dart
// Before: 순환 참조 위험
class GlobalUserNotifier {
  final Ref ref;
  void someMethod() {
    ref.read(globalPointProvider); // 직접 참조
    ref.read(sherpiProvider);      // 직접 참조
  }
}

// After: 이벤트 기반 통신
class GlobalUserNotifier {
  final EventBus _eventBus;
  void someMethod() {
    _eventBus.fire(PointsEarnedEvent(points));
    _eventBus.fire(SherpiReactionEvent(context));
  }
}
```

#### 예상 효과
- **유지보수성**: 크게 향상
- **테스트 용이성**: 개선
- **성능**: Provider 업데이트 최적화

### Phase 3: UI 컴포넌트 통합 (2주)

#### 2025 버전으로 마이그레이션
```dart
// migration_map.dart
const migrationMap = {
  'sherpa_button.dart': 'sherpa_button_2025.dart',
  'sherpa_card.dart': 'sherpa_card_2025.dart',
  // ... 35개 파일 매핑
};

// 자동 마이그레이션 스크립트 작성
// 1. 기존 import 자동 변경
// 2. API 차이점 자동 수정
// 3. 테스트 실행
```

#### 대형 위젯 파일 분할
```
exercise_summary_widget.dart (2,164줄)
분할 후:
├── exercise_summary/
│   ├── exercise_summary_widget.dart (200줄)
│   ├── components/
│   │   ├── exercise_chart.dart (300줄)
│   │   ├── exercise_stats.dart (250줄)
│   │   ├── exercise_history.dart (400줄)
│   │   └── exercise_insights.dart (300줄)
```

#### 예상 효과
- **코드 중복 제거**: 10,000줄 감소
- **일관성**: UI/UX 통일
- **번들 크기**: 15% 감소

### Phase 4: Feature 모듈 재구성 (2-3주)

#### Sherpi 기능 통합
```
현재 구조:
├── features/
│   ├── sherpi_analysis/
│   ├── sherpi_chat/
│   ├── sherpi_emotion/
│   ├── sherpi_personalization/
│   ├── sherpi_planning/
│   └── sherpi_relationship/

통합 후:
├── features/
│   └── sherpi/
│       ├── core/           # 공통 로직
│       ├── analysis/       # 분석 기능
│       ├── interaction/    # 채팅, 감정, 관계
│       └── planning/       # 계획 및 개인화
```

#### Meeting 모델 통합
```dart
// 현재: 3개 모델
class AvailableMeeting { }
class RecommendedMeeting { }
class MeetingLog { }

// 통합 후: 1개 기본 모델 + 확장
class Meeting {
  // 공통 필드
}

class AvailableMeeting extends Meeting {
  // 추가 필드
}

class MeetingRecommendation {
  final Meeting meeting;
  final double score;
}
```

#### 예상 효과
- **코드 구조**: 더 명확하고 찾기 쉬움
- **중복 제거**: 5,000줄 감소
- **유지보수**: 관련 기능 한 곳에서 관리

### Phase 5: 성능 최적화 (2-3주)

#### 빌드 최적화
```yaml
# pubspec.yaml
dependencies:
  # 사용하지 않는 의존성 제거
  # go_router: ^12.1.3  # 실제 사용 안 함
  # hive: ^2.2.3        # SharedPreferences 사용 중

dev_dependencies:
  # 개발 의존성 정리
  flutter_lints: ^3.0.1
  # build_runner와 code generation 설정 또는 제거
```

#### 런타임 최적화
```dart
// Lazy Loading 적용
class FeatureModule {
  static final _instances = <Type, dynamic>{};
  
  static T getInstance<T>() {
    return _instances.putIfAbsent(
      T,
      () => _createInstance<T>(),
    );
  }
}

// Widget 최적화
class OptimizedWidget extends StatelessWidget {
  const OptimizedWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(  // 리페인트 경계 추가
      child: CustomPaint(
        isComplex: true,  // 복잡한 위젯 표시
        willChange: false, // 변경 빈도 낮음
      ),
    );
  }
}
```

#### 예상 효과
- **앱 시작 시간**: 30% 단축
- **메모리 사용**: 20% 감소
- **프레임 드롭**: 50% 감소

## 🚨 4. 위험 관리

### 4.1 높은 위험도 작업
| 작업 | 위험도 | 대응 방안 |
|------|--------|-----------|
| Provider 리팩토링 | 🔴 높음 | 단계적 마이그레이션, 충분한 테스트 |
| 컴포넌트 통합 | 🟡 중간 | 하나씩 점진적 교체 |
| Feature 재구성 | 🟡 중간 | 기능별 독립적 진행 |

### 4.2 롤백 계획
1. **Git 브랜치 전략**
   ```bash
   main
   ├── optimization/phase1  # 각 Phase별 브랜치
   ├── optimization/phase2
   └── optimization/phase3
   ```

2. **기능 플래그 사용**
   ```dart
   if (FeatureFlags.useNewProvider) {
     // 새로운 Provider 사용
   } else {
     // 기존 Provider 사용
   }
   ```

## 📈 5. 측정 지표

### 5.1 성능 지표
- **빌드 시간**: 현재 대비 30% 단축 목표
- **앱 크기**: APK 20MB → 15MB
- **시작 시간**: Cold start 3초 → 2초

### 5.2 코드 품질 지표
- **평균 파일 크기**: 500줄 이하
- **순환 복잡도**: 10 이하
- **테스트 커버리지**: 70% 이상

### 5.3 진행 상황 추적
```markdown
## Phase 1 Progress (Day 1-5)
- [x] component_viewer_screen.dart 제거
- [ ] 샘플 데이터 조건부 컴파일
- [ ] 사용되지 않는 예제 파일 제거
- [ ] SharedPreferences.clear() 제거
Progress: 25% ████░░░░░░░░░░░░
```

## 🎯 6. 예상 최종 결과

### 6.1 코드 베이스
- **Before**: 156,319 lines
- **After**: ~100,000 lines (36% 감소)

### 6.2 파일 구조
- **Before**: 14 features, 혼재된 구조
- **After**: 10 features, 명확한 책임 분리

### 6.3 성능
- **빌드 시간**: 30% 단축
- **앱 크기**: 25% 감소
- **시작 시간**: 33% 단축

## 📝 7. 작업 우선순위 매트릭스

```
긴급도 높음 ↑
         │
    🔴   │   🟡
  Phase1 │ Phase2
         │
─────────┼─────────→ 중요도 높음
         │
    🟢   │   ⚪
  Phase4 │ Phase5
         │
긴급도 낮음 ↓
```

### 즉시 시작 가능한 작업 (Day 1)
1. ✅ `component_viewer_screen.dart` 제거
2. ✅ 예제 파일 제거
3. ✅ SharedPreferences.clear() 코드 제거
4. ✅ TODO/FIXME 해결

---

## 📌 다음 단계

1. **이 문서를 팀과 공유하고 피드백 수집**
2. **Phase 1 작업 즉시 시작**
3. **일일 진행 상황 업데이트**
4. **주간 코드 리뷰 및 성능 측정**

> 💡 **Note**: 이 계획은 living document로, 진행 상황에 따라 지속적으로 업데이트됩니다.