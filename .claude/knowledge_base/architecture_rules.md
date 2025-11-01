# 셰르파 앱 아키텍처 규칙 가이드

> **⚠️ 중요**: 이 규칙들은 코드 품질과 유지보수성을 위한 **필수 준수 사항**입니다.
> 이 문서는 `CLAUDE.md`의 Architecture 섹션을 기반으로 작성되었습니다.

---

## Part 1: 디렉토리 구조

### 1.1 Feature-First 아키텍처 ✅

```
lib/
├── core/              # 앱 전역 설정 및 유틸리티
│   ├── constants/    # 상수 (game_constants.dart 등)
│   ├── theme/        # 테마 (modern_colors.dart 등)
│   └── utils/        # 유틸리티 함수
│
├── features/          # 기능별 독립 모듈 (Feature-First!)
│   ├── daily_record/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── utils/
│   │
│   ├── quests/
│   │   ├── models/
│   │   ├── providers/
│   │   └── presentation/
│   │
│   ├── climb/
│   ├── meeting/
│   └── profile/
│
├── shared/            # 공유 컴포넌트 및 모델
│   ├── models/       # 전역 모델 (global_user_model.dart 등)
│   ├── providers/    # 전역 Provider (global_*_provider.dart)
│   └── widgets/      # 공유 위젯 (sherpa_clean_app_bar.dart 등)
│
├── main.dart          # 앱 진입점, Provider 초기화, 라우트
└── main_navigation_screen.dart  # 하단 네비게이션
```

**핵심 원칙**:
- **Feature-First**: 기능별로 독립된 폴더 구조
- **Self-Contained**: 각 feature는 자체 models, providers, presentation 포함
- **Shared Resources**: 여러 feature에서 사용하는 것만 `shared/`에 위치

---

### 1.2 폴더 명명 규칙

#### Feature 폴더
```
features/
├── daily_record/    # snake_case, 명사형
├── quests/          # 복수형 (여러 퀘스트를 관리)
├── climb/           # 단수형 (등반 기능 하나)
└── meeting/         # 단수형 (모임 기능)
```

#### 하위 폴더
```
feature_name/
├── models/          # 복수형
├── providers/       # 복수형
├── presentation/    # 단수형
│   ├── screens/    # 복수형
│   └── widgets/    # 복수형
└── utils/           # 복수형
```

---

## Part 2: 파일 명명 규칙

### 2.1 Dart 파일 명명

**규칙**: `snake_case.dart`

```dart
// ✅ 올바른 예시
lib/features/daily_record/models/daily_record_model.dart
lib/shared/widgets/sherpa_clean_app_bar.dart
lib/core/constants/game_constants.dart

// ❌ 잘못된 예시
lib/features/dailyRecord/models/DailyRecordModel.dart  // camelCase 금지!
lib/shared/widgets/SherpaCleanAppBar.dart               // PascalCase 금지!
```

---

### 2.2 파일 접미사 규칙

| 파일 타입 | 접미사 | 예시 |
|-----------|--------|------|
| 모델 | `_model.dart` | `user_model.dart` |
| Provider | `_provider.dart` | `quest_provider_v2.dart` |
| Screen | `_screen.dart` | `climb_screen.dart` |
| Widget | `_widget.dart` | `stat_display_widget.dart` |
| 상수 | `_constants.dart` | `game_constants.dart` |
| 유틸 | `_utils.dart` | `date_utils.dart` |

---

## Part 3: Import 규칙

### 3.1 절대 경로 사용 (필수!) ⚠️

```dart
// ✅ 올바른 절대 경로
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/features/quests/providers/quest_provider_v2.dart';

// ❌ 상대 경로 금지!
import '../../../core/theme/modern_colors.dart';        // 절대 금지!
import '../../shared/models/global_user_model.dart';   // 절대 금지!
```

**이유**:
- 파일 이동 시 import 깨짐 방지
- 파일 구조 명확화
- IDE 자동 완성 지원 향상

---

### 3.2 Import 순서

```dart
// 1. Dart 코어 라이브러리
import 'dart:async';
import 'dart:math';

// 2. Flutter 패키지
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 외부 패키지 (알파벳 순)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

// 4. 프로젝트 내부 파일 (알파벳 순)
import 'package:sherpa_app/core/constants/game_constants.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/global_user_provider.dart';
```

---

## Part 4: 순환 의존성 금지

### 4.1 순환 의존성이란?

```dart
// ❌ 순환 의존성 예시 (절대 금지!)

// file_a.dart
import 'package:sherpa_app/features/example/file_b.dart';

class A {
  B b = B();  // A → B
}

// file_b.dart
import 'package:sherpa_app/features/example/file_a.dart';

class B {
  A a = A();  // B → A (순환!)
}
```

**결과**: 컴파일 에러 또는 런타임 크래시!

---

### 4.2 순환 의존성 해결 방법

#### 방법 1: 공통 인터페이스 분리

```dart
// ✅ 올바른 방법

// common_interface.dart (공통 인터페이스)
abstract class DataProvider {
  Future<Data> getData();
}

// file_a.dart
import 'package:sherpa_app/features/example/common_interface.dart';

class A implements DataProvider {
  @override
  Future<Data> getData() async {
    // A의 구현
  }
}

// file_b.dart
import 'package:sherpa_app/features/example/common_interface.dart';

class B {
  final DataProvider provider;  // 인터페이스에 의존

  B(this.provider);
}
```

---

#### 방법 2: 의존성 계층화

```dart
// ✅ 계층화된 의존성

// Level 0: 데이터 모델 (의존성 없음)
// global_user_model.dart
class GlobalUser {
  final String id;
  final int level;
}

// Level 1: Provider (모델 의존)
// global_user_provider.dart
import 'package:sherpa_app/shared/models/global_user_model.dart';

class GlobalUserProvider {
  GlobalUser? user;
}

// Level 2: UI (Provider 의존)
// user_screen.dart
import 'package:sherpa_app/shared/providers/global_user_provider.dart';

class UserScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    // UI 구현
  }
}
```

---

### 4.3 순환 의존성 검증 방법

```bash
# flutter analyze로 검증
flutter analyze

# 순환 의존성 에러 예시:
# Error: Cyclic dependency found:
# lib/features/example/file_a.dart → lib/features/example/file_b.dart
# lib/features/example/file_b.dart → lib/features/example/file_a.dart
```

---

## Part 5: 코드 조직 규칙

### 5.1 파일당 클래스 개수

**규칙**: 1개 파일 = 1개 주요 클래스 (예외: 관련 helper 클래스)

```dart
// ✅ 올바른 예시 (1 파일, 1 주요 클래스)
// user_model.dart
class GlobalUser {
  final String id;
  final String name;
  // ...
}

// ✅ 허용되는 예시 (주요 클래스 + helper)
// user_model.dart
class GlobalUser {
  // 주요 클래스
}

class _UserHelper {
  // private helper 클래스 (같은 파일 OK)
}

// ❌ 잘못된 예시 (여러 주요 클래스)
// models.dart
class GlobalUser {  // 주요 클래스 1
  // ...
}

class Quest {  // 주요 클래스 2 (별도 파일로 분리 필요!)
  // ...
}
```

---

### 5.2 클래스 멤버 순서

```dart
class ExampleClass {
  // 1. 상수
  static const String CONSTANT_VALUE = 'value';

  // 2. static 변수
  static int staticCounter = 0;

  // 3. 인스턴스 변수 (final 먼저, 일반 변수 나중)
  final String id;
  final String name;
  int age;

  // 4. 생성자
  ExampleClass({
    required this.id,
    required this.name,
    required this.age,
  });

  // 5. factory 생성자
  factory ExampleClass.fromJson(Map<String, dynamic> json) {
    // ...
  }

  // 6. getter/setter
  int get nextAge => age + 1;
  set nextAge(int value) => age = value - 1;

  // 7. public 메서드
  void publicMethod() {
    // ...
  }

  // 8. private 메서드
  void _privateMethod() {
    // ...
  }

  // 9. override 메서드
  @override
  String toString() {
    return 'ExampleClass(id: $id, name: $name, age: $age)';
  }
}
```

---

## Part 6: 네이밍 컨벤션

### 6.1 변수 및 함수 네이밍

```dart
// ✅ 변수: camelCase
String userName = 'John';
int userLevel = 10;
bool isClimbing = false;

// ✅ 함수: camelCase, 동사로 시작
void calculateClimbingPower() {}
Future<void> fetchUserData() async {}
bool isValidLevel(int level) => level > 0;

// ✅ 상수: UPPER_SNAKE_CASE
const int MAX_LEVEL = 200;
const String DEFAULT_TITLE = '초보 등반가';

// ✅ 클래스: PascalCase
class GlobalUser {}
class QuestProviderV2 {}

// ✅ enum: PascalCase
enum SherpiEmotion { normal, cheering, proud }

// ✅ private: _로 시작
String _privateVariable = 'secret';
void _privateMethod() {}
```

---

### 6.2 Provider 네이밍

```dart
// ✅ Provider: Provider 접미사
final globalUserProvider = StateNotifierProvider<GlobalUserNotifier, AsyncValue<GlobalUser>>(
  (ref) => GlobalUserNotifier(),
);

final questProviderV2 = StateNotifierProvider<QuestNotifierV2, QuestState>(
  (ref) => QuestNotifierV2(),
);

// ✅ StateNotifier: Notifier 접미사
class GlobalUserNotifier extends StateNotifier<AsyncValue<GlobalUser>> {
  // ...
}

class QuestNotifierV2 extends StateNotifier<QuestState> {
  // ...
}
```

---

## Part 7: 주석 및 문서화

### 7.1 주석 작성 규칙

```dart
// ✅ 함수 문서화: /// 사용 (dartdoc)
/// 사용자의 최종 등반력을 계산합니다.
///
/// [level]: 사용자 레벨
/// [titleBonus]: 칭호 보너스
/// [stats]: 능력치 정보
/// [equippedBadges]: 장착한 뱃지 목록
///
/// Returns: 계산된 등반력
double calculateFinalClimbingPower({
  required int level,
  required double titleBonus,
  required GlobalStats stats,
  required List<GlobalBadge> equippedBadges,
}) {
  // 구현
}

// ✅ 코드 설명: // 사용
// 능력치 보너스는 체력, 지식, 기술만 포함
final statsBonus = stats.stamina + stats.knowledge + stats.technique;

// ✅ TODO 주석
// TODO: 사교성에 따른 길드 보너스 구현 필요

// ✅ FIXME 주석
// FIXME: 등반 실패 시 포인트 차감 로직 수정 필요

// ❌ 불필요한 주석 (코드만으로 명확)
// 레벨을 1 증가시킴
level++;  // 주석 불필요
```

---

## Part 8: 에러 처리

### 8.1 에러 처리 패턴

```dart
// ✅ try-catch 사용
Future<void> loadUserData() async {
  try {
    final data = await api.fetchUser();
    state = AsyncValue.data(data);
  } on NetworkException catch (e) {
    // 네트워크 에러 처리
    state = AsyncValue.error(e, StackTrace.current);
  } on ParseException catch (e) {
    // 파싱 에러 처리
    state = AsyncValue.error(e, StackTrace.current);
  } catch (e, stack) {
    // 기타 에러 처리
    state = AsyncValue.error(e, stack);
  }
}

// ✅ null 체크
final user = ref.watch(globalUserProvider).value;
if (user == null) {
  return LoadingWidget();
}
// user가 null이 아님을 확인한 후 사용

// ✅ assert 사용 (개발 모드 검증)
assert(level >= 1, 'Level must be at least 1');
assert(experience >= 0, 'Experience cannot be negative');
```

---

## Part 9: 성능 최적화 규칙

### 9.1 불필요한 rebuild 방지

```dart
// ✅ 필요한 부분만 watch
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(globalUserProvider.select((state) => state.value));
  // 전체 state가 아닌 value만 watch

  return Text('Level: ${user?.level}');
}

// ✅ const 생성자 활용
const SizedBox(height: 16)  // 재사용되는 위젯

// ✅ ListView.builder 사용
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
)  // 화면에 보이는 것만 빌드
```

---

### 9.2 메모리 관리

```dart
// ✅ dispose 구현
class ExampleScreen extends StatefulWidget {
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();  // 메모리 해제 필수!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: [],
    );
  }
}
```

---

## Part 10: SKILL.md 작성 시 참고사항

### 10.1 Role 1 (Architect & Orchestrator) 작성 시

**검증 항목**:
```markdown
## Architecture 검증 체크리스트
- [ ] Feature-First 구조 준수
- [ ] 절대 경로 사용 (상대 경로 금지)
- [ ] 순환 의존성 없음
- [ ] 파일 명명 규칙 (snake_case)
- [ ] 1 파일 = 1 주요 클래스
- [ ] Provider 네이밍 규칙
- [ ] Import 순서 정렬
```

**SKILL.md 예시**:
```markdown
## 활성화 조건
- "아키텍처 검증해줘"
- "파일 구조 확인해줘"
- "순환 의존성 검사"

## 검증 프로세스
1. grep으로 상대 경로 import 검색 (../로 시작)
2. flutter analyze로 순환 의존성 체크
3. 파일 명명 규칙 검증 (snake_case)
4. Feature-First 구조 준수 여부 확인
```

---

### 10.2 Role 5 (Fullstack Implementer) 작성 시

**코드 작성 체크리스트**:
```dart
// ✅ 새 파일 생성 시 체크리스트
// [ ] snake_case 파일명
// [ ] 적절한 폴더 위치 (feature or shared)
// [ ] 절대 경로 import
// [ ] 순환 의존성 없음
// [ ] Provider 네이밍 규칙 (접미사)
// [ ] 주석 작성 (dartdoc)
// [ ] flutter analyze 통과
// [ ] dispose 구현 (필요 시)
```

---

## 마지막 업데이트

- **작성일**: 2025-09-08
- **기준 문서**: `CLAUDE.md` (Architecture 섹션)
- **검증 완료**: 실제 프로젝트 구조 확인 완료 ✅

---

## ⚠️ 최종 경고

**절대 잊지 마세요**:
1. **Feature-First 구조를 유지하세요!**
2. **절대 경로만 사용하세요! (상대 경로 금지!)**
3. **순환 의존성을 만들지 마세요!**
4. **파일명은 snake_case로!**
5. **Provider는 _provider.dart 접미사!**
6. **flutter analyze를 습관화하세요!**
