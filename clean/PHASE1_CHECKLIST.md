# Phase 1: 즉시 실행 가능한 최적화 체크리스트

> ⏱️ 예상 소요 시간: 3-5일  
> 🎯 목표: 불필요한 코드 15,000줄 제거  
> ⚠️ 위험도: 낮음 (대부분 개발용 코드)

## ✅ Day 1: 개발용 코드 제거 (4-6시간)

### 1. Component Viewer 제거
```bash
# 백업 생성
git checkout -b optimization/phase1
git add .
git commit -m "백업: Phase 1 최적화 시작 전 상태"

# 파일 제거
rm lib/shared/presentation/screens/component_viewer_screen.dart
```

**영향받는 파일 수정:**
- [ ] `lib/main.dart` - import 및 라우트 제거
  ```dart
  // 제거할 라인
  // import 'shared/presentation/screens/component_viewer_screen.dart';
  
  // 라우트에서 제거
  // '/component_viewer': (context) => ComponentViewerScreen(),
  ```

- [ ] `lib/shared/widgets/sherpa_clean_app_bar.dart` - 개발 메뉴 제거
  ```dart
  // 개발용 액션 버튼 제거 또는 조건부 처리
  if (kDebugMode) {
    // 개발 모드에서만 표시
  }
  ```

### 2. 예제 파일 제거
```bash
# 사용되지 않는 예제 파일 제거
rm lib/features/sherpi_personalization/personalization_usage_example.dart
rm lib/features/sherpi_personalization/relationship_growth_usage_example.dart
```

### 3. 벤치마크 파일 제거
```bash
rm lib/core/utils/phase1_performance_benchmark.dart
```

**예상 코드 감소:** ~4,000줄

---

## ✅ Day 2: SharedPreferences 초기화 코드 정리 (2-3시간)

### 1. GlobalUserProvider 수정
```dart
// lib/shared/providers/global_user_provider.dart

// BEFORE (31-42줄)
Future<void> _initializeAndClearData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // 🔴 제거 필요
    await _saveUserData();
  } catch (e) {
    // 에러 처리
  }
}

// AFTER
Future<void> _initializeData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // 데이터 clear 제거, 필요시 로드만 수행
    await _loadUserData();
  } catch (e) {
    // 에러 처리
  }
}
```

### 2. 샘플 데이터 생성 조건부 처리
```dart
// lib/shared/providers/global_user_provider.dart

// 개발 모드 플래그 추가
static const bool _USE_SAMPLE_DATA = false; // 프로덕션: false

static GlobalUser _createInitialUser() {
  if (_USE_SAMPLE_DATA && kDebugMode) {
    // 개발 모드에서만 샘플 데이터 사용
    return _createSampleUser();
  } else {
    // 프로덕션: 빈 사용자 데이터
    return GlobalUser.empty();
  }
}
```

**영향 분석:**
- [ ] 앱 첫 실행 시 데이터 유지 확인
- [ ] 로그인/로그아웃 플로우 테스트
- [ ] 데이터 마이그레이션 로직 확인

---

## ✅ Day 3: TODO/FIXME 해결 (3-4시간)

### 발견된 TODO 목록
| 파일 | 라인 | 내용 | 해결 방법 |
|------|------|------|-----------|
| `global_community_provider.dart` | 375, 415 | 실제 사용자 정보 연동 | 임시 처리 또는 제거 |
| `global_point_provider.dart` | 538 | 셰르피 연동 추가 예정 | 주석 업데이트 |
| `withdrawal_screen.dart` | 371 | 실제 출금 로직 구현 | 미구현 명시 |

### TODO 처리 스크립트
```bash
# TODO 검색 및 리스트 생성
grep -r "TODO\|FIXME" lib/ > clean/todo_list.txt

# 각 TODO를 티켓으로 변환
# Jira/GitHub Issues 생성 권장
```

---

## ✅ Day 4: Deprecated 코드 제거 (2-3시간)

### 1. Deprecated 메서드 제거
```dart
// lib/shared/providers/global_user_provider.dart (1433줄)

// 제거할 메서드
/// DEPRECATED: 이중 호출 방지를 위해 제거됨
// void _handleActivityCompletion(...) {
//   // 제거
// }

// 대체 메서드 사용 권장
// handleActivityCompletion을 직접 사용
```

### 2. 호출 위치 변경
```bash
# Deprecated 메서드 호출 위치 찾기
grep -r "_handleActivityCompletion" lib/

# 각 호출을 handleActivityCompletion으로 변경
```

---

## ✅ Day 5: 테스트 및 검증 (4-6시간)

### 1. 제거된 코드 영향 분석
```bash
# 제거된 파일 참조 확인
grep -r "component_viewer" lib/
grep -r "usage_example" lib/
grep -r "performance_benchmark" lib/

# 남은 참조가 있다면 제거
```

### 2. 빌드 및 실행 테스트
```bash
# 클린 빌드
flutter clean
flutter pub get

# 빌드 테스트
flutter build apk --debug
flutter build apk --release

# 앱 크기 비교
ls -lh build/app/outputs/flutter-apk/
```

### 3. 성능 측정
```dart
// lib/main.dart에 추가
void main() async {
  final startTime = DateTime.now();
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // 초기화 코드...
  
  final initTime = DateTime.now().difference(startTime);
  print('🚀 App initialized in: ${initTime.inMilliseconds}ms');
  
  runApp(MyApp());
}
```

### 4. 메모리 프로파일링
```bash
# Flutter DevTools 실행
flutter pub global activate devtools
flutter pub global run devtools

# 메모리 사용량 체크
# 1. 앱 실행
# 2. DevTools > Memory 탭
# 3. Snapshot 캡처 및 비교
```

---

## 📊 Phase 1 완료 기준

### 성공 지표
- [ ] 코드 라인 수 15,000줄 이상 감소
- [ ] APK 크기 5% 이상 감소
- [ ] 빌드 시간 10% 이상 단축
- [ ] 앱 시작 시간 측정 가능한 개선

### 체크포인트
- [ ] 모든 테스트 통과
- [ ] 개발팀 코드 리뷰 완료
- [ ] QA 팀 기능 테스트 완료
- [ ] 성능 벤치마크 문서화

---

## 🚨 롤백 계획

문제 발생 시:
```bash
# 이전 상태로 롤백
git checkout main
git branch -D optimization/phase1

# 또는 특정 커밋으로 롤백
git reset --hard [commit-hash]
```

---

## 📝 Phase 1 완료 보고서 템플릿

```markdown
## Phase 1 최적화 완료 보고

### 수행 기간
- 시작: 2025-01-XX
- 완료: 2025-01-XX

### 제거된 코드
- 총 제거 라인: X,XXX줄
- 제거된 파일: X개
- 수정된 파일: X개

### 성능 개선
- APK 크기: XXmb → XXmb (X% 감소)
- 빌드 시간: XX초 → XX초 (X% 단축)
- 시작 시간: XX초 → XX초 (X% 단축)

### 이슈 및 해결
- 이슈 1: ...
- 해결: ...

### 다음 단계
- Phase 2 시작 예정일: 2025-01-XX
```

---

## 💡 팁과 주의사항

### DO ✅
- 각 변경사항마다 커밋
- 의미 있는 커밋 메시지 작성
- 팀원과 진행 상황 공유
- 백업 브랜치 유지

### DON'T ❌
- 여러 변경을 한 번에 커밋
- 테스트 없이 머지
- 프로덕션 코드와 개발 코드 혼재
- 문서화 없이 진행

---

> 📌 이 체크리스트는 실제 작업 시 참조용입니다. 각 항목을 완료할 때마다 체크하고, 문제가 발생하면 즉시 문서화하세요.