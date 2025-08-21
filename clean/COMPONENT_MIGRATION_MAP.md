# 2025 컴포넌트 마이그레이션 매핑

> 🎨 UI 컴포넌트 통합 계획  
> 📅 예상 소요 시간: 2주  
> 🎯 목표: 35개 2025 버전으로 통합, 중복 제거

## 📊 1. 컴포넌트 매핑 테이블

### 1.1 Atoms (기본 컴포넌트)

| 기존 컴포넌트 | 2025 버전 | 사용 위치 | 우선순위 | API 호환성 |
|---------------|-----------|-----------|----------|------------|
| sherpa_button.dart | sherpa_button_2025.dart | 전체 (120+ 위치) | 🔴 높음 | 70% |
| sherpa_card.dart | sherpa_card.dart (유지) | 50+ 위치 | 🟡 중간 | 100% |
| sherpa_input.dart | sherpa_input_2025.dart | 30+ 위치 | 🔴 높음 | 60% |
| - | sherpa_alert_2025.dart | 신규 | 🟢 낮음 | N/A |
| - | sherpa_chart_2025.dart | 신규 | 🟢 낮음 | N/A |
| - | sherpa_container_2025.dart | 신규 | 🟡 중간 | N/A |
| - | sherpa_grid_2025.dart | 10+ 위치 | 🟡 중간 | 신규 |
| - | sherpa_modal_2025.dart | 신규 | 🟢 낮음 | N/A |
| - | sherpa_notification_badge_2025.dart | 신규 | 🟢 낮음 | N/A |
| - | sherpa_progress_2025.dart | 15+ 위치 | 🟡 중간 | 80% |
| - | sherpa_search_bar_2025.dart | 5+ 위치 | 🟢 낮음 | 신규 |
| - | sherpa_select_2025.dart | 신규 | 🟢 낮음 | N/A |
| - | sherpa_stack_2025.dart | 신규 | 🟢 낮음 | N/A |
| - | sherpa_toast_2025.dart | 신규 | 🟢 낮음 | N/A |

### 1.2 Molecules (복합 컴포넌트)

| 기존 컴포넌트 | 2025 버전 | 주요 사용처 | 우선순위 |
|---------------|-----------|-------------|----------|
| meeting_card_widget.dart | meeting_card_2025.dart | Meeting Feature | 🔴 높음 |
| - | meeting_card_compact_2025.dart | Meeting List | 🟡 중간 |
| - | meeting_card_hero_2025.dart | Home Screen | 🟡 중간 |
| - | meeting_card_list_2025.dart | Discovery Screen | 🔴 높음 |
| category_selector.dart | category_selector_2025.dart | Multiple | 🟡 중간 |
| sherpa_app_bar.dart | sherpa_app_bar_2025.dart | 전체 | 🔴 높음 |
| - | sherpa_ai_recommendation_2025.dart | Home | 🟢 낮음 |
| - | sherpa_activity_card_2025.dart | Daily Record | 🟡 중간 |
| sherpa_mountain_card.dart | sherpa_mountain_card_2025.dart | Climbing | 🟡 중간 |
| - | sherpa_quest_card_2025.dart | Quest | 🟡 중간 |
| - | sherpa_tab_bar_2025.dart | Navigation | 🔴 높음 |

## 🔄 2. API 차이점 분석

### 2.1 SherpaButton 마이그레이션

#### 기존 API (sherpa_button.dart)
```dart
SherpaButton(
  text: '확인',
  onPressed: () {},
  color: AppColors.primary,
  textColor: Colors.white,
  isLoading: false,
  width: 200,
  height: 50,
)
```

#### 2025 API (sherpa_button_2025.dart)
```dart
SherpaButton2025(
  label: '확인',  // 'text' → 'label'로 변경
  onTap: () {},   // 'onPressed' → 'onTap'으로 변경
  variant: ButtonVariant.primary,  // color 대신 variant 사용
  size: ButtonSize.medium,  // width/height 대신 size enum
  loading: false,  // 'isLoading' → 'loading'
  fullWidth: false,  // 새로운 속성
  icon: Icons.check,  // 아이콘 지원 추가
)
```

#### 자동 마이그레이션 매핑
```dart
class ButtonMigration {
  static Map<String, dynamic> migrate(Map<String, dynamic> oldProps) {
    return {
      'label': oldProps['text'],
      'onTap': oldProps['onPressed'],
      'variant': _getVariant(oldProps['color']),
      'size': _getSize(oldProps['width'], oldProps['height']),
      'loading': oldProps['isLoading'],
    };
  }
  
  static ButtonVariant _getVariant(Color? color) {
    if (color == AppColors.primary) return ButtonVariant.primary;
    if (color == AppColors.secondary) return ButtonVariant.secondary;
    return ButtonVariant.outline;
  }
  
  static ButtonSize _getSize(double? width, double? height) {
    if (height != null && height > 55) return ButtonSize.large;
    if (height != null && height < 45) return ButtonSize.small;
    return ButtonSize.medium;
  }
}
```

### 2.2 Meeting Card 통합

#### 현재 구조 (분산됨)
```
features/meetings/presentation/widgets/
├── meeting_card_widget.dart        # 기본 카드
├── meeting_info_card_widget.dart   # 정보 카드
└── (다른 위치에 분산)
```

#### 2025 통합 구조
```
shared/widgets/components/molecules/
├── meeting_card_2025.dart          # 기본 카드 (통합)
├── meeting_card_compact_2025.dart  # 컴팩트 버전
├── meeting_card_hero_2025.dart     # 히어로 버전
└── meeting_card_list_2025.dart     # 리스트 버전
```

## 🛠️ 3. 자동 마이그레이션 스크립트

### 3.1 마이그레이션 실행 스크립트
```bash
#!/bin/bash
# migrate_components.sh

# Step 1: 백업 생성
echo "🔒 Creating backup..."
cp -r lib lib_backup_$(date +%Y%m%d_%H%M%S)

# Step 2: Import 자동 변경
echo "🔄 Updating imports..."
find lib -name "*.dart" -type f -exec sed -i \
  's/sherpa_button\.dart/sherpa_button_2025.dart/g' {} \;

# Step 3: API 변경
echo "🔧 Updating API calls..."
dart run tool/migrate_components.dart

# Step 4: 테스트 실행
echo "🧪 Running tests..."
flutter test

echo "✅ Migration complete!"
```

### 3.2 Dart 마이그레이션 도구
```dart
// tool/migrate_components.dart
import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

void main() async {
  final files = await getDataFiles('lib');
  
  for (final file in files) {
    await migrateFile(file);
  }
}

Future<void> migrateFile(File file) async {
  final content = await file.readAsString();
  var modified = content;
  
  // SherpaButton 마이그레이션
  modified = migrateSherpaButton(modified);
  
  // Meeting Card 마이그레이션
  modified = migrateMeetingCard(modified);
  
  // 다른 컴포넌트들...
  
  if (modified != content) {
    await file.writeAsString(modified);
    print('✅ Migrated: ${file.path}');
  }
}

String migrateSherpaButton(String content) {
  // 정규식을 사용한 패턴 매칭 및 교체
  final patterns = [
    RegexPattern(
      from: r'SherpaButton\(\s*text:\s*([^,]+),',
      to: r'SherpaButton2025(label: $1,',
    ),
    RegexPattern(
      from: r'onPressed:\s*([^,]+),',
      to: r'onTap: $1,',
    ),
    // ... 더 많은 패턴
  ];
  
  var result = content;
  for (final pattern in patterns) {
    result = result.replaceAllMapped(
      RegExp(pattern.from),
      (match) => pattern.to.replaceAll(r'$1', match.group(1)!),
    );
  }
  
  return result;
}
```

## 📅 4. 단계별 전환 계획

### Phase A: 준비 단계 (Day 1-2)
- [ ] 2025 컴포넌트 의존성 분석
- [ ] 테스트 커버리지 확보
- [ ] 마이그레이션 도구 개발
- [ ] 백업 및 롤백 계획 수립

### Phase B: Core 컴포넌트 (Day 3-5)
#### 우선순위 1 - 가장 많이 사용되는 컴포넌트
- [ ] SherpaButton → SherpaButton2025
  - 120+ 사용 위치
  - 예상 작업 시간: 1일
- [ ] SherpaAppBar → SherpaAppBar2025
  - 모든 화면에서 사용
  - 예상 작업 시간: 0.5일
- [ ] SherpaTabBar → SherpaTabBar2025
  - 네비게이션 핵심
  - 예상 작업 시간: 0.5일

### Phase C: Feature 컴포넌트 (Day 6-8)
#### Meeting 관련 컴포넌트 통합
- [ ] meeting_card_widget.dart → meeting_card_2025.dart
- [ ] 분산된 Meeting 카드들 통합
- [ ] CategorySelector 마이그레이션

### Phase D: 신규 컴포넌트 활용 (Day 9-10)
- [ ] SherpaAlert2025 적용 (기존 알림 대체)
- [ ] SherpaToast2025 적용 (스낵바 대체)
- [ ] SherpaModal2025 적용 (다이얼로그 개선)

### Phase E: 정리 및 최적화 (Day 11-14)
- [ ] 기존 컴포넌트 파일 제거
- [ ] Import 정리
- [ ] 문서 업데이트
- [ ] 성능 테스트

## 🧪 5. 테스트 전략

### 5.1 Visual Regression Testing
```dart
// test/visual/component_migration_test.dart
void main() {
  group('Component Migration Visual Tests', () {
    testWidgets('SherpaButton visual compatibility', (tester) async {
      // 기존 버전
      await tester.pumpWidget(
        MaterialApp(
          home: SherpaButton(text: 'Test', onPressed: () {}),
        ),
      );
      final oldScreenshot = await tester.takeScreenshot();
      
      // 2025 버전
      await tester.pumpWidget(
        MaterialApp(
          home: SherpaButton2025(label: 'Test', onTap: () {}),
        ),
      );
      final newScreenshot = await tester.takeScreenshot();
      
      // 시각적 차이 비교
      expect(compareImages(oldScreenshot, newScreenshot), lessThan(5.0));
    });
  });
}
```

### 5.2 기능 테스트
```dart
void main() {
  group('Component Functionality Tests', () {
    testWidgets('Button interaction works correctly', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: SherpaButton2025(
            label: 'Tap me',
            onTap: () => tapped = true,
          ),
        ),
      );
      
      await tester.tap(find.text('Tap me'));
      await tester.pump();
      
      expect(tapped, isTrue);
    });
  });
}
```

## 📊 6. 예상 결과

### Before
- 컴포넌트 파일: 70개
- 중복 코드: ~15,000줄
- 일관성: 낮음
- 유지보수성: 어려움

### After
- 컴포넌트 파일: 45개 (35% 감소)
- 중복 제거: 10,000줄 감소
- 일관성: 높음
- 유지보수성: 크게 개선

### 성능 개선
- 번들 크기: 15% 감소
- 렌더링 성능: 10% 향상
- 개발 속도: 30% 향상

## ⚠️ 7. 주의사항 및 위험 관리

### 위험 요소
1. **Breaking Changes**: API 변경으로 인한 런타임 에러
2. **Visual Regression**: UI 변경으로 인한 사용자 경험 저하
3. **성능 저하**: 새 컴포넌트의 성능 이슈

### 대응 방안
1. **Feature Flag 사용**
```dart
if (FeatureFlags.use2025Components) {
  return SherpaButton2025(...);
} else {
  return SherpaButton(...);
}
```

2. **점진적 롤아웃**
- 10% 사용자 → 50% → 100%

3. **A/B 테스팅**
- 성능 메트릭 비교
- 사용자 피드백 수집

---

> 📌 **Next Steps**: 
> 1. 마이그레이션 도구 개발 완료
> 2. Phase A 시작
> 3. 일일 진행 상황 보고