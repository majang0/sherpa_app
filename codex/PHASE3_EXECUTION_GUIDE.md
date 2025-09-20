# Phase 3 실행 가이드 - 전역 추천 & 캐시 정비

**작성일**: 2025-09-20
**대상**: Codex
**목적**: Phase 2를 건너뛰고 Phase 3를 원활히 진행하기 위한 안내

---

## 🎯 핵심 메시지

**Phase 2(정적 메시지 고도화)를 건너뛰고 Phase 3를 진행해도 안전합니다.**

### Phase 2 건너뛰기 정당성

1. **독립적인 작업 범위**
   - Phase 2: 정적 메시지 다양성 (UI/UX 개선)
   - Phase 3: 추천 시스템과 캐시 (백엔드 로직)
   - 두 작업은 서로 의존하지 않음

2. **현재 시스템 안정성**
   - Analyzer: 0 에러
   - 테스트: 기본 테스트 통과
   - 정적 메시지: 현재도 정상 작동

3. **비즈니스 우선순위**
   - Phase 3의 캐시 개선이 성능에 즉각적인 영향
   - Phase 2는 사용자 만족도 개선 (나중에 가능)

---

## 📊 현재 상태 (Phase 3 시작 전)

### ✅ 완료된 작업
- Phase 0: 파일 구조 정리 완료
- Phase 1: 품질 검증 완료 (Analyzer 0 에러)
- 시스템: 안정적 작동 중

### 📁 관련 파일 현황
```
lib/
├── core/ai/
│   ├── cache/
│   │   └── ai_message_cache.dart (캐시 시스템 - 개선 필요)
│   └── managers/
│       ├── static_sherpi_manager.dart (현재 사용 중)
│       └── openai_sherpi_manager.dart (DI 준비됨)
├── shared/providers/
│   ├── global_ai_recommendation_provider.dart (전역 추천 - 개선 필요)
│   └── global_sherpi_provider.dart (메인 Provider)
└── features/meetings/ai/
    └── meeting_recommendation_ai.dart (추천 엔진 - 개선 필요)
```

---

## 🔧 Phase 3 상세 실행 계획

### Task 1: 캐시 키 구조 개선 (Day 1)

**목표**: 사용자별 캐시 분리 및 충돌 방지

**수정 파일**:
- `lib/core/ai/cache/ai_message_cache.dart`

**현재 코드** (라인 87-88):
```dart
final key = _buildCacheKey(context, userContext);
```

**개선 코드**:
```dart
// 1. 캐시 키 빌더 수정
String _buildCacheKey({
  required String userId,
  required SherpiContext context,
  required Map<String, dynamic> userContext,
  String? meetingSetId,
}) {
  final buffer = StringBuffer();
  buffer.write('user:$userId');
  buffer.write(':ctx:${context.name}');
  if (meetingSetId != null) {
    buffer.write(':meet:$meetingSetId');
  }
  buffer.write(':hash:${userContext.hashCode}');
  return buffer.toString();
}

// 2. TTL 정책 세분화
static const Map<SherpiContext, Duration> _contextTTL = {
  SherpiContext.dailyGreeting: Duration(hours: 12),
  SherpiContext.questComplete: Duration(hours: 24),
  SherpiContext.exerciseComplete: Duration(hours: 6),
  // ... 각 context별 설정
};
```

**테스트 방법**:
```bash
# 단위 테스트 실행
flutter test test/core/ai/cache/ai_message_cache_test.dart

# 캐시 충돌 테스트
flutter test --name="multiple users cache isolation"
```

**체크포인트**:
```bash
git add -A
git commit -m "🔧 Phase 3.1: 캐시 키 구조 개선 - 사용자별 분리"
```

---

### Task 2: SherpiInsights 파라미터 전달 (Day 2)

**목표**: AI 추천에 Sherpi 인사이트 활용

**수정 파일**:
1. `lib/features/meetings/ai/meeting_recommendation_ai.dart`
2. `lib/shared/providers/global_ai_recommendation_provider.dart`

**Step 1**: MeetingRecommendationAI 수정

```dart
// meeting_recommendation_ai.dart 라인 79 수정
Future<List<AIRecommendedMeeting>> getAIRecommendations({
  required GlobalUser user,
  required List<AvailableMeeting> availableMeetings,
  Map<String, dynamic>? sherpiInsights,  // 추가
  bool useCache = true,
  bool forceRefresh = false,
}) async {
  // ... 기존 코드

  // 라인 149 프롬프트 빌더에 insights 전달
  final prompt = _promptBuilder.buildPrompt(
    userPattern: userPattern,
    availableMeetings: meetings,
    sherpiInsights: sherpiInsights,  // 추가
  );
}
```

**Step 2**: GlobalAIRecommendationNotifier 수정

```dart
// global_ai_recommendation_provider.dart 라인 76-83 수정
final insights = _ref.read(sherpiInsightRepositoryProvider).collectInsights();

final recommendations = await _aiEngine.getAIRecommendations(
  user: user,
  availableMeetings: availableMeetings,
  sherpiInsights: insights,  // 추가
  useCache: !forceRefresh,
  forceRefresh: forceRefresh,
);
```

**테스트 방법**:
```bash
# 통합 테스트
flutter test test/features/meetings/ai/recommendation_integration_test.dart

# 디버그 실행으로 insights 전달 확인
flutter run --debug
```

**체크포인트**:
```bash
git add -A
git commit -m "✨ Phase 3.2: SherpiInsights 파라미터 연동 완료"
```

---

### Task 3: DI 패턴 적용 (Day 3)

**목표**: Provider에 의존성 주입 패턴 적용

**수정 파일**:
- `lib/shared/providers/global_sherpi_provider.dart`

**코드 개선**:
```dart
// 1. Provider 생성 시 Manager 주입 가능하도록 수정
final sherpiProvider = StateNotifierProvider<GlobalSherpiProvider, SherpiState>((ref) {
  // Feature flag 확인
  final useAI = ref.watch(featureFlagsProvider).enableAI;

  // Manager 선택
  final manager = useAI
    ? OpenAISherpiManager(cache: AiMessageCache())
    : StaticSherpiManager();

  return GlobalSherpiProvider(
    ref: ref,
    messageManager: manager,
  );
});

// 2. GlobalSherpiProvider 생성자 수정
class GlobalSherpiProvider extends StateNotifier<SherpiState> {
  final SherpiMessageManager _messageManager;

  GlobalSherpiProvider({
    required Ref ref,
    SherpiMessageManager? messageManager,
  }) : _messageManager = messageManager ?? StaticSherpiManager(),
       super(SherpiState.initial());
}
```

**테스트 방법**:
```dart
// test/shared/providers/global_sherpi_provider_test.dart
test('DI pattern allows manager injection', () {
  final mockManager = MockSherpiMessageManager();
  final provider = GlobalSherpiProvider(
    ref: mockRef,
    messageManager: mockManager,
  );

  expect(provider.messageManager, equals(mockManager));
});
```

**체크포인트**:
```bash
git add -A
git commit -m "♻️ Phase 3.3: DI 패턴 적용 - Provider 유연성 향상"
```

---

### Task 4: 통합 테스트 및 검증 (Day 4)

**목표**: 전체 시스템 안정성 확인

**테스트 시나리오**:
1. 캐시 격리 테스트 (다중 사용자)
2. SherpiInsights 전달 검증
3. Manager 교체 테스트
4. 성능 측정

**실행 스크립트**:
```bash
# 1. 전체 테스트 실행
flutter test

# 2. 성능 벤치마크
flutter test test/benchmarks/cache_performance_test.dart

# 3. 통합 테스트
flutter test integration_test/phase3_integration_test.dart
```

**최종 체크포인트**:
```bash
git add -A
git commit -m "✅ Phase 3 완료: 전역 추천 & 캐시 정비

- 사용자별 캐시 키 분리
- SherpiInsights 연동
- DI 패턴 적용
- 통합 테스트 통과

다음: Phase 4 또는 Phase 2 재검토"
git tag -a "phase3-complete" -m "Phase 3 completion"
```

---

## ⚠️ 주의사항 및 위험 관리

### 잠재적 위험
1. **캐시 마이그레이션**
   - 기존 캐시 데이터 호환성
   - 해결: 캐시 버전 관리 추가

2. **Provider 초기화 순서**
   - 의존성 주입 시 순환 참조 가능
   - 해결: main.dart에서 초기화 순서 확인

3. **성능 저하**
   - 캐시 키 복잡도 증가
   - 해결: 벤치마크 후 최적화

### 롤백 계획
```bash
# 문제 발생 시 롤백
git checkout phase1-complete
```

---

## 📝 Phase 2 나중 진행을 위한 메모

Phase 2는 다음 상황에서 진행하세요:
1. 사용자 피드백으로 메시지 단조로움 지적 시
2. AI 기능 재활성화 준비 완료 시
3. 감정/관계 시스템 본격 활용 시

Phase 2 작업 내용:
- 시간대별 인사 메시지
- 마일스톤 축하 메시지
- 감정 색상 시각화
- 친밀도별 메시지 변화

---

## 🎯 성공 지표

Phase 3 완료 기준:
- [ ] 캐시 히트율 50% 이상
- [ ] 다중 사용자 캐시 격리 확인
- [ ] SherpiInsights 활용 확인
- [ ] 모든 테스트 통과
- [ ] 성능 저하 없음

---

## 📞 지원 및 문의

문제 발생 시:
1. `codex/ai_sherpi_structure_journal.md`에 기록
2. Claude의 분석 문서 참조
   - `AI_SHERPI_COMPREHENSIVE_REVIEW_20250920.md`
   - `AI_SHERPI_STRATEGIC_DIRECTION_20250920.md`
3. git log로 체크포인트 확인

---

**준비 완료!** Phase 3를 시작하세요. 🚀