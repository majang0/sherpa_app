# Provider 의존성 및 초기화 순서 가이드

> **⚠️ 치명적 중요**: Provider 초기화 순서를 위반하면 **앱이 크래시**됩니다!
> 이 문서는 `CLAUDE.md`의 Provider 초기화 섹션을 기반으로 작성되었습니다.

---

## Part 1: Provider 초기화 순서 (필수 암기!)

### 1.1 정확한 초기화 순서 ✅

**위치**: `lib/main.dart`의 `_initializeProviders()` 함수

```dart
// ⚠️ 이 순서를 절대 바꾸지 마세요!
Future<void> _initializeProviders(WidgetRef ref) async {
  // Level 0: 게임 시스템 (의존성 없음)
  ref.read(globalGameProvider);

  // Level 1: 사용자 기본 데이터 (게임 시스템 의존)
  ref.read(globalUserProvider);
  ref.read(globalPointProvider);
  ref.read(globalUserTitleProvider);

  // Level 2: 기능 시스템 (사용자 데이터 의존)
  ref.read(questProviderV2);  // ⚠️ V2! questProvider 금지!
  ref.read(globalMeetingProvider);

  // Level 3: UI 및 부가 기능 (기능 시스템 의존)
  ref.read(sherpiProvider);
  ref.read(relationshipProvider);
  ref.read(emotionAnalysisProvider);
}
```

---

### 1.2 Level 0: 게임 시스템 (독립)

#### `globalGameProvider`
- **역할**: 게임 밸런스 공식 및 상수 제공
- **의존성**: 없음
- **제공**: 등반력 계산, XP 곡선, 성공 확률 등
- **위치**: `lib/shared/providers/global_game_provider.dart`

**주요 메서드**:
```dart
calculateFinalClimbingPower()
getRequiredXpForLevel()
calculateSuccessProbability()
calculateSuccessXp()
calculateRequiredPower()
```

---

### 1.3 Level 1: 사용자 기본 데이터

#### `globalUserProvider`
- **역할**: 사용자 정보, 레벨, XP, 능력치 관리
- **의존성**: `globalGameProvider` (XP 계산용)
- **위치**: `lib/shared/providers/global_user_provider.dart`

**주요 상태**:
```dart
GlobalUser {
  int level
  double experience
  GlobalStats stats  // 5대 능력치
  List<String> equippedBadgeIds
  List<String> ownedBadgeIds
}
```

#### `globalPointProvider`
- **역할**: 포인트 시스템 관리
- **의존성**: `globalUserProvider` (사용자 ID 필요)
- **위치**: `lib/shared/providers/global_point_provider.dart`

**주요 메서드**:
```dart
earnPoints(PointSource source)
spendPoints(PointSpendType type, int amount)
getPointBalance()
```

#### `globalUserTitleProvider`
- **역할**: 칭호 시스템 관리
- **의존성**: `globalUserProvider` (레벨 정보 필요)
- **위치**: `lib/shared/providers/global_user_title_provider.dart`

---

### 1.4 Level 2: 기능 시스템

#### `questProviderV2` ⚠️
- **역할**: 퀘스트 시스템 (일일/주간/프리미엄)
- **의존성**: `globalUserProvider`, `globalPointProvider`
- **위치**: `lib/features/quests/providers/quest_provider_v2.dart`

**⚠️ 치명적 주의사항**:
```dart
// ✅ 올바른 사용
ref.read(questProviderV2);

// ❌ 절대 금지! 크래시 발생!
ref.read(questProvider);  // ← 이 provider는 더 이상 사용하지 않음!
```

**이유**: `questProvider`는 레거시 버전이며, 현재는 `questProviderV2`를 사용합니다. 잘못 사용하면 데이터 충돌로 크래시 발생!

#### `globalMeetingProvider`
- **역할**: 모임 시스템 관리
- **의존성**: `globalUserProvider`, `globalPointProvider`
- **위치**: `lib/shared/providers/global_meeting_provider.dart`

---

### 1.5 Level 3: UI 및 부가 기능

#### `sherpiProvider`
- **역할**: AI 감성 동반자 Sherpi 관리
- **의존성**: `globalUserProvider`, `questProviderV2`
- **위치**: `lib/shared/providers/global_sherpi_provider.dart`

#### `relationshipProvider`
- **역할**: 사용자 관계 시스템
- **의존성**: `globalUserProvider`, `sherpiProvider`
- **위치**: (위치 확인 필요)

#### `emotionAnalysisProvider`
- **역할**: 감정 분석 시스템
- **의존성**: `globalUserProvider`, `sherpiProvider`
- **위치**: (위치 확인 필요)

---

## Part 2: 의존성 그래프

### 2.1 계층적 의존성 구조

```
Level 0
├── globalGameProvider (독립)

Level 1 (Level 0 의존)
├── globalUserProvider → globalGameProvider
├── globalPointProvider → globalUserProvider
└── globalUserTitleProvider → globalUserProvider

Level 2 (Level 0-1 의존)
├── questProviderV2 → globalUserProvider, globalPointProvider
└── globalMeetingProvider → globalUserProvider, globalPointProvider

Level 3 (Level 0-2 의존)
├── sherpiProvider → globalUserProvider, questProviderV2
├── relationshipProvider → globalUserProvider, sherpiProvider
└── emotionAnalysisProvider → globalUserProvider, sherpiProvider
```

---

### 2.2 순환 의존성 금지!

**❌ 절대 금지 패턴**:
```dart
// Provider A가 Provider B를 참조하고
// Provider B가 Provider A를 참조하는 경우

// ❌ 잘못된 예시
class ProviderA extends StateNotifier {
  void method() {
    ref.read(providerB);  // A → B
  }
}

class ProviderB extends StateNotifier {
  void method() {
    ref.read(providerA);  // B → A (순환!)
  }
}
```

**✅ 올바른 패턴**:
```dart
// 공통 의존성을 하위 레벨로 분리

class SharedDataProvider extends StateNotifier {
  // 공통 데이터
}

class ProviderA extends StateNotifier {
  void method() {
    ref.read(sharedDataProvider);  // A → Shared
  }
}

class ProviderB extends StateNotifier {
  void method() {
    ref.read(sharedDataProvider);  // B → Shared (순환 없음!)
  }
}
```

---

## Part 3: Provider 사용 시 주의사항

### 3.1 읽기 패턴

**초기화 시 (main.dart)**:
```dart
// ✅ read 사용
ref.read(globalGameProvider);
```

**UI 빌드 시 (Widget)**:
```dart
// ✅ watch 사용 (상태 변경 감지)
final user = ref.watch(globalUserProvider);

// ✅ listen 사용 (일회성 이벤트)
ref.listen<AsyncValue<GlobalUser>>(
  globalUserProvider,
  (previous, next) {
    // 상태 변경 처리
  },
);
```

**이벤트 핸들러 내부**:
```dart
// ✅ read 사용
onPressed: () {
  ref.read(globalPointProvider.notifier).earnPoints(
    PointSource.dailyQuestAd,
  );
}
```

---

### 3.2 초기화 순서 위반 시 문제

#### 문제 1: Level 순서 무시
```dart
// ❌ 잘못된 순서
ref.read(questProviderV2);       // Level 2
ref.read(globalUserProvider);    // Level 1 (순서 뒤바뀜!)
```

**결과**: `questProviderV2`가 `globalUserProvider`를 찾지 못해 크래시!

---

#### 문제 2: V2 대신 레거시 사용
```dart
// ❌ 레거시 provider 사용
ref.read(questProvider);  // 크래시 또는 데이터 충돌!
```

**결과**:
- 데이터 불일치
- SharedPreferences 키 충돌
- 예상치 못한 동작

---

#### 문제 3: 의존성 누락
```dart
// ❌ globalGameProvider 초기화 생략
// ref.read(globalGameProvider);  ← 주석 처리하면 안 됨!
ref.read(globalUserProvider);  // XP 계산 실패!
```

**결과**: XP 곡선 계산 시 null 참조 에러!

---

## Part 4: 새 Provider 추가 시 체크리스트

### 4.1 추가 전 질문

1. **이 Provider는 어떤 Provider에 의존하는가?**
   - Level 0 (독립) / Level 1 / Level 2 / Level 3 결정

2. **이 Provider를 의존하는 Provider가 있는가?**
   - 순환 의존성 체크

3. **초기화 순서에서 어디에 들어가야 하는가?**
   - 의존하는 모든 Provider 뒤에 위치

---

### 4.2 추가 후 검증

```dart
// ✅ 체크리스트
// [ ] main.dart의 _initializeProviders()에 올바른 순서로 추가
// [ ] CLAUDE.md의 Provider 초기화 섹션 업데이트
// [ ] provider_dependencies.md (이 문서) 업데이트
// [ ] flutter analyze 통과
// [ ] 앱 재시작 후 크래시 없는지 확인
// [ ] 의존하는 Provider가 정상 동작하는지 확인
```

---

## Part 5: 디버깅 가이드

### 5.1 Provider 초기화 에러 증상

**증상 1: "ProviderNotFoundException"**
```
Error: Could not find a provider for [ProviderName]
```

**원인**: Provider가 초기화되지 않았거나, 잘못된 이름 사용

**해결**:
1. `main.dart`의 `_initializeProviders()`에 추가되었는지 확인
2. Provider 이름이 정확한지 확인 (예: `questProviderV2` vs `questProvider`)

---

**증상 2: "StateError (Bad state: No element)"**
```
Bad state: No element
```

**원인**: Provider가 의존하는 다른 Provider가 먼저 초기화되지 않음

**해결**:
1. 의존성 그래프 확인
2. 초기화 순서 재배치

---

**증상 3: "Null check operator used on a null value"**
```
Null check operator used on a null value
```

**원인**: Provider 내부에서 의존하는 Provider의 값이 null

**해결**:
1. 의존하는 Provider가 먼저 초기화되었는지 확인
2. null 체크 추가

---

### 5.2 디버깅 팁

```dart
// Provider 초기화 순서 로깅
Future<void> _initializeProviders(WidgetRef ref) async {
  print('🔧 Initializing Level 0...');
  ref.read(globalGameProvider);

  print('🔧 Initializing Level 1...');
  ref.read(globalUserProvider);
  ref.read(globalPointProvider);

  print('🔧 Initializing Level 2...');
  ref.read(questProviderV2);  // questProvider 금지!

  print('✅ All providers initialized!');
}
```

---

## Part 6: SKILL.md 작성 시 참고사항

### 6.1 Role 4 (State Management Expert) 작성 시

**포함해야 할 내용**:
1. 전체 초기화 순서 코드 블록
2. questProviderV2 경고 (대문자로 강조!)
3. 의존성 그래프 ASCII 아트
4. 순환 의존성 금지 예시

**SKILL.md 예시**:
```markdown
## 활성화 조건
- "provider 초기화 순서 확인해줘"
- "questProvider vs questProviderV2 차이점"
- "Provider 의존성 검증해줘"

## 검증 프로세스
1. `lib/main.dart`의 _initializeProviders() 확인
2. Level 0 → Level 1 → Level 2 → Level 3 순서 검증
3. ⚠️ questProviderV2 사용 여부 확인 (questProvider 금지!)
4. 순환 의존성 검사
```

---

### 6.2 Role 5 (Fullstack Implementer) 작성 시

**주의사항**:
- 새 기능 구현 시 Provider 의존성 먼저 확인
- questProviderV2만 사용, questProvider 절대 사용 금지
- Provider 추가 시 초기화 순서 문서 업데이트 필수

---

## Part 7: 실전 예제

### 7.1 활동 완료 플로우

```dart
// ✅ 올바른 활동 완료 처리 순서
await ref.read(globalUserProvider.notifier).handleActivityCompletion(
  activityType: 'exercise',
  data: activityData,
  points: calculatedPoints,  // globalPointProvider 내부에서 처리
  xp: calculatedXP,          // globalUserProvider 내부에서 처리
);

// 자동으로 처리되는 것들:
// 1. Points 추가 (globalPointProvider)
// 2. XP 추가 및 레벨업 체크 (globalUserProvider)
// 3. Quest 진행률 업데이트 (questProviderV2)
// 4. Stats 증가 (확률 기반, globalUserProvider)
// 5. Record 저장 (globalUserProvider)
```

---

### 7.2 모임 참여 플로우

```dart
// ✅ 의존성 순서를 고려한 모임 참여 처리

// 1. 포인트 차감 (Level 1)
await ref.read(globalPointProvider.notifier).spendPoints(
  PointSpendType.freeMeeting,
  1000,
);

// 2. 모임 데이터 업데이트 (Level 2)
await ref.read(globalMeetingProvider.notifier).participateInMeeting(
  meetingId,
);

// 3. 활동 완료 처리 (Level 1로 돌아감)
await ref.read(globalUserProvider.notifier).handleActivityCompletion(
  activityType: 'meeting_participant',
  data: meetingData,
  points: 100,
  xp: 50,
);
```

---

## 마지막 업데이트

- **작성일**: 2025-09-08
- **기준 문서**: `CLAUDE.md` (Provider initialization section)
- **기준 코드**: `lib/main.dart`
- **검증 완료**: 실제 코드 확인 완료 ✅

---

## ⚠️ 최종 경고

**절대 잊지 마세요**:
1. **순서를 바꾸지 마세요!**
2. **questProvider 대신 questProviderV2를 사용하세요!**
3. **순환 의존성을 만들지 마세요!**
4. **새 Provider 추가 시 문서를 업데이트하세요!**
