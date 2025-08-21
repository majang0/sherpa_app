# 🚨 Sherpi 중복 메시지 문제 해결 보고서

## 문제 상황
- 자동 환영 메시지가 2번씩 표시됨
- 테스트 카드 버튼을 누를 때마다 메시지가 중복으로 표시됨
- 사용자가 동일한 액션을 짧은 시간 내에 반복할 때 메시지 스팸 발생

## 근본 원인 분석

### 1. 아키텍처 문제
- **MainNavigationScreen**의 Stack에 두 개의 메시지 표시 위젯이 존재:
  - `SherpiMessageCard`: 슬라이딩 메시지 카드 표시
  - `GlobalSherpiWidget`: 다이얼로그 메시지 표시
- 두 위젯 모두 동일한 `sherpiProvider` 상태를 감시하여 메시지 표시

### 2. 중복 호출 패턴
- **자동 환영 메시지**: 홈 스크린 초기화 시 자동 호출
- **테스트 버튼**: 각 버튼 클릭 시 `showMessage()` 호출
- **새로고침 액션**: Pull-to-refresh 시 격려 메시지 자동 표시
- **다이얼로그 액션**: GlobalSherpiWidget 내 격려 버튼 클릭

### 3. 상태 관리 문제
- 동일한 컨텍스트나 메시지에 대한 중복 방지 로직 부재
- 짧은 시간 내 반복 호출에 대한 디바운싱 없음

## 해결 방안

### 1. 중복 메시지 감지 시스템 구현

#### A. 중복 감지 메커니즘
```dart
// 최근 2초 이내 같은 컨텍스트/메시지는 중복으로 간주
bool _isDuplicateMessage(SherpiContext context, String? dialogue) {
  final now = DateTime.now();
  
  if (_lastMessageTime == null) {
    _updateLastMessage(now, context, dialogue);
    return false;
  }
  
  final timeDiff = now.difference(_lastMessageTime!);
  if (timeDiff.inSeconds < 2 && _lastContext == context) {
    // 같은 메시지 내용이거나 컨텍스트가 같은 경우 중복
    return true;
  }
  
  _updateLastMessage(now, context, dialogue);
  return false;
}
```

#### B. 상태 추적 변수 추가
```dart
// 중복 메시지 방지를 위한 최근 메시지 추적
DateTime? _lastMessageTime;
SherpiContext? _lastContext;
String? _lastDialogue;
```

### 2. forceShow 매개변수 활용

#### A. 기본 메시지 (중복 방지 적용)
```dart
ref.read(sherpiProvider.notifier).showMessage(
  context: context,
  forceShow: false, // 중복 방지 활성화
);
```

#### B. 테스트/강제 메시지 (중복 방지 무시)
```dart
await ref.read(sherpiProvider.notifier).showMessage(
  context: sherpiContext,
  forceShow: true, // 테스트 버튼은 강제 표시
);
```

### 3. 주요 수정 사항

#### A. SherpiNotifier 개선
1. **showMessage()**: 중복 감지 로직 추가
2. **showInstantMessage()**: 중복 감지 로직 추가
3. **_isDuplicateMessage()**: 새로운 중복 감지 메서드
4. **디버그 로깅**: 메시지 표시/숨김 상태 추적

#### B. HomeScreen 수정
1. **_showWelcomeSherpi()**: forceShow: false 설정
2. **onRefresh**: forceShow: false 설정으로 중복 방지

#### C. GlobalSherpiWidget 수정
1. **_showEncouragement()**: forceShow: false 설정

#### D. SherpiAiTestCard 수정
1. **테스트 버튼**: forceShow: true로 설정하여 테스트 의도 유지

#### E. Extension Methods 업데이트
1. 모든 `SherpiProviderExtension` 메서드에 forceShow: false 기본값 적용

## 기술적 세부사항

### 중복 방지 알고리즘
- **시간 기반**: 최근 2초 이내 중복 호출 감지
- **컨텍스트 기반**: 같은 SherpiContext 반복 감지
- **메시지 기반**: 동일한 메시지 내용 반복 감지

### 예외 처리
- **테스트 모드**: forceShow: true로 개발자 의도 유지
- **긴급 메시지**: forceShow: true로 중요한 알림 보장
- **첫 번째 메시지**: 항상 표시 (중복 체크 제외)

### 디버그 지원
```dart
// 메시지 표시 상태 로깅
print('📢 Sherpi 메시지 표시: ${context.name}');
print('🔇 Sherpi 메시지 중복/숨김: ${context.name}');
print('🚨 중복 메시지 무시: ${context.name}');
```

## 검증 방법

### 1. 자동 환영 메시지
- 홈 스크린 진입 시 1회만 표시되는지 확인
- 탭 전환 후 재진입 시 중복 방지 작동 확인

### 2. 테스트 카드 버튼
- 각 버튼 클릭 시 강제 표시 작동 확인 (forceShow: true)
- 연속 클릭 시에도 정상 작동 확인

### 3. 일반 사용자 액션
- Pull-to-refresh 연속 사용 시 중복 방지 확인
- 다이얼로그 격려 버튼 연속 클릭 시 중복 방지 확인

## 기대 효과

### 사용자 경험 개선
- ✅ 메시지 중복으로 인한 혼란 제거
- ✅ 자연스러운 Sherpi 상호작용
- ✅ 개발자 도구 기능 유지

### 시스템 성능
- ✅ 불필요한 메시지 처리 리소스 절약
- ✅ 메모리 사용량 최적화
- ✅ 디버깅 가능성 향상

### 유지보수성
- ✅ 명확한 중복 방지 로직
- ✅ 개발/프로덕션 모드 구분
- ✅ 확장 가능한 아키텍처

## 향후 고려사항

### 고급 중복 방지
- 메시지 내용 유사도 검사
- 사용자별 메시지 빈도 제한
- 컨텍스트별 쿨다운 시간 설정

### 사용자 설정
- 메시지 표시 빈도 사용자 설정
- Sherpi 반응성 레벨 조정
- Do Not Disturb 모드 구현

### 분석 및 모니터링
- 메시지 표시 패턴 분석
- 중복 방지 효과 측정
- 사용자 만족도 추적