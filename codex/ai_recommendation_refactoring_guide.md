# AI 추천 로직 전역화 리팩토링 가이드

## 📋 작업 개요

### 현재 문제점
- AI 추천 로직이 `sherpi_personalized_meeting_widget.dart` 내부에 격리됨
- 다른 화면에서 재사용 불가능
- 테스트 어려움 (private provider)
- 전역 상태 관리 부재

### 목표
- AI 추천 로직을 전역 프로바이더로 추출
- 모든 화면에서 접근 가능하도록 개선
- 테스트 가능한 구조로 변경
- 기존 기능 100% 유지

## 🎯 Phase 1: 새 전역 프로바이더 생성

### Step 1.1: 전역 프로바이더 파일 생성
**파일 생성**: `lib/shared/providers/global_ai_recommendation_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/meetings/ai/meeting_recommendation_ai.dart';
import '../../features/meetings/ai/models/ai_recommended_meeting.dart';
import '../../features/meetings/models/available_meeting_model.dart';
import '../models/global_user_model.dart';

// 1. State 클래스 (기존 _AIRecommendationState를 public으로)
class AIRecommendationState {
  final bool isLoading;
  final List<AIRecommendedMeeting> recommendations;
  final String? error;
  final DateTime? lastUpdated;  // 캐시 관리용 추가

  const AIRecommendationState({
    this.isLoading = false,
    this.recommendations = const [],
    this.error,
    this.lastUpdated,
  });

  AIRecommendationState copyWith({
    bool? isLoading,
    List<AIRecommendedMeeting>? recommendations,
    String? error,
    DateTime? lastUpdated,
  }) {
    return AIRecommendationState(
      isLoading: isLoading ?? this.isLoading,
      recommendations: recommendations ?? this.recommendations,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // 캐시 유효성 검사 (30분)
  bool get isCacheValid {
    if (lastUpdated == null) return false;
    return DateTime.now().difference(lastUpdated!).inMinutes < 30;
  }
}

// 2. Notifier 클래스
class GlobalAIRecommendationNotifier extends StateNotifier<AIRecommendationState> {
  final MeetingRecommendationAI _aiEngine = MeetingRecommendationAI();
  final Ref ref;

  GlobalAIRecommendationNotifier(this.ref) : super(const AIRecommendationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _aiEngine.initialize();
  }

  // 기존 generateRecommendations 메서드 그대로 가져오기
  Future<void> generateRecommendations({
    required GlobalUser user,
    required List<AvailableMeeting> availableMeetings,
    bool forceRefresh = false,  // 캐시 무시 옵션 추가
  }) async {
    // 캐시가 유효하고 강제 새로고침이 아니면 기존 데이터 사용
    if (!forceRefresh && state.isCacheValid && state.recommendations.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (availableMeetings.isEmpty) {
        throw Exception('참여 가능한 모임이 없습니다');
      }

      final recommendations = await _aiEngine.getAIRecommendations(
        user: user,
        availableMeetings: availableMeetings,
        useCache: !forceRefresh,
      );

      if (recommendations.isEmpty) {
        throw Exception('추천할 모임을 찾을 수 없습니다');
      }

      state = state.copyWith(
        isLoading: false,
        recommendations: recommendations,
        lastUpdated: DateTime.now(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 특정 카테고리에 대한 추천 필터링
  List<AIRecommendedMeeting> getRecommendationsByCategory(MeetingCategory category) {
    if (category == MeetingCategory.all) {
      return state.recommendations;
    }
    return state.recommendations
        .where((r) => r.meeting.category == category)
        .toList();
  }

  // 상위 N개 추천 가져오기
  List<AIRecommendedMeeting> getTopRecommendations(int count) {
    return state.recommendations.take(count).toList();
  }

  void reset() {
    state = const AIRecommendationState();
  }
}

// 3. 전역 프로바이더 정의
final globalAIRecommendationProvider =
    StateNotifierProvider<GlobalAIRecommendationNotifier, AIRecommendationState>(
  (ref) => GlobalAIRecommendationNotifier(ref),
);

// 4. 편의 프로바이더들
final globalAIRecommendationsProvider = Provider<List<AIRecommendedMeeting>>((ref) {
  return ref.watch(globalAIRecommendationProvider).recommendations;
});

final globalAIRecommendationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(globalAIRecommendationProvider).isLoading;
});

final globalAIRecommendationErrorProvider = Provider<String?>((ref) {
  return ref.watch(globalAIRecommendationProvider).error;
});
```

### Step 1.2: main.dart 초기화 추가
**파일 수정**: `lib/main.dart`

providers 초기화 섹션에 추가:
```dart
// 기존 프로바이더 초기화 코드 아래에 추가
ref.read(globalAIRecommendationProvider);
```

## 🔄 Phase 2: 홈 위젯 마이그레이션

### Step 2.1: 홈 위젯 수정
**파일 수정**: `lib/features/home/presentation/widgets/sherpi_personalized_meeting_widget.dart`

1. import 추가:
```dart
import '../../../../shared/providers/global_ai_recommendation_provider.dart';
```

2. 기존 private 클래스들 제거:
- `_AIRecommendationState` 클래스 제거
- `_AIRecommendationNotifier` 클래스 제거
- `_aiRecommendationProvider` 정의 제거

3. `_CompactAIRecommendationButton` 수정:
```dart
class _CompactAIRecommendationButton extends ConsumerWidget {
  const _CompactAIRecommendationButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 기존: final aiState = ref.watch(_aiRecommendationProvider);
    final aiState = ref.watch(globalAIRecommendationProvider);  // 변경

    return GestureDetector(
      onTap: aiState.isLoading
          ? null
          : () async {
              HapticFeedbackManager.lightImpact();
              final user = ref.read(globalUserProvider);
              final meetingState = ref.read(globalMeetingProvider);

              if (meetingState.availableMeetings.isEmpty) {
                _showError(context, '현재 참여 가능한 모임이 없습니다');
                return;
              }

              // 기존: ref.read(_aiRecommendationProvider.notifier)
              await ref.read(globalAIRecommendationProvider.notifier)  // 변경
                  .generateRecommendations(
                    user: user,
                    availableMeetings: meetingState.availableMeetings,
                  );

              // ... 나머지 코드 동일
            },
      // ... 나머지 코드 동일
    );
  }
}
```

4. 다이얼로그에서 AI 추천 결과 사용 부분 수정:
```dart
// 기존: final updatedState = ref.read(_aiRecommendationProvider);
final updatedState = ref.read(globalAIRecommendationProvider);  // 변경
```

## 🚀 Phase 3: 다른 화면에서 AI 추천 사용

### Step 3.1: 새 모임 발견 화면에 AI 추천 추가
**파일 수정**: `lib/features/meetings/presentation/screens/new_meeting_discovery_screen.dart`

```dart
// 1. import 추가
import '../../../../shared/providers/global_ai_recommendation_provider.dart';

// 2. AI 추천 섹션 추가 (build 메서드 내)
Widget _buildAIRecommendationSection(WidgetRef ref) {
  final aiRecommendations = ref.watch(globalAIRecommendationsProvider);
  final isLoading = ref.watch(globalAIRecommendationLoadingProvider);

  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (aiRecommendations.isEmpty) {
    return const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '🤖 AI 추천 모임',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: aiRecommendations.take(5).length,
          itemBuilder: (context, index) {
            final recommendation = aiRecommendations[index];
            return _buildRecommendationCard(recommendation);
          },
        ),
      ),
    ],
  );
}

// 3. 초기화 시 AI 추천 생성
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final user = ref.read(globalUserProvider);
    final meetings = ref.read(globalMeetingProvider).availableMeetings;

    ref.read(globalAIRecommendationProvider.notifier)
        .generateRecommendations(
          user: user,
          availableMeetings: meetings,
        );
  });
}
```

### Step 3.2: 향상된 추천 위젯 통합 (옵션)
**파일**: `lib/features/home/presentation/widgets/enhanced_meeting_recommendation_widget.dart`
- 동일한 패턴으로 `globalAIRecommendationProvider` 사용

## 🧪 Phase 4: 테스트 작성

### Step 4.1: 프로바이더 테스트 생성
**파일 생성**: `test/shared/providers/global_ai_recommendation_provider_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sherpa_app/shared/providers/global_ai_recommendation_provider.dart';
import 'package:sherpa_app/shared/providers/global_user_provider.dart';
import 'package:sherpa_app/shared/providers/global_meeting_provider.dart';

void main() {
  group('GlobalAIRecommendationProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 상태는 비어있음', () {
      final state = container.read(globalAIRecommendationProvider);

      expect(state.isLoading, false);
      expect(state.recommendations, isEmpty);
      expect(state.error, isNull);
    });

    test('generateRecommendations 호출 시 로딩 상태 변경', () async {
      final notifier = container.read(globalAIRecommendationProvider.notifier);
      final user = container.read(globalUserProvider);
      final meetings = container.read(globalMeetingProvider).availableMeetings;

      // 추천 생성 시작
      final future = notifier.generateRecommendations(
        user: user,
        availableMeetings: meetings,
      );

      // 로딩 상태 확인
      expect(container.read(globalAIRecommendationProvider).isLoading, true);

      await future;

      // 로딩 완료 확인
      expect(container.read(globalAIRecommendationProvider).isLoading, false);
    });

    test('캐시 유효성 검사 동작', () {
      final state1 = AIRecommendationState(
        lastUpdated: DateTime.now(),
      );
      expect(state1.isCacheValid, true);

      final state2 = AIRecommendationState(
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(state2.isCacheValid, false);
    });

    test('카테고리별 필터링 동작', () async {
      final notifier = container.read(globalAIRecommendationProvider.notifier);
      // ... 테스트 구현
    });
  });
}
```

## ✅ Phase 5: 검증 체크리스트

### 기능 검증
- [ ] 홈 위젯의 AI 추천 버튼이 정상 작동
- [ ] AI 추천 결과가 올바르게 표시됨
- [ ] 에러 처리가 정상 작동
- [ ] 로딩 상태가 올바르게 표시됨

### 통합 검증
- [ ] 새 모임 발견 화면에서 AI 추천 표시
- [ ] 여러 화면에서 동시에 AI 추천 접근 가능
- [ ] 캐싱이 올바르게 동작

### 테스트 검증
```bash
flutter test test/shared/providers/global_ai_recommendation_provider_test.dart
flutter test  # 전체 테스트 실행
```

### 코드 품질
```bash
flutter analyze
```

## 📝 추가 고려사항

### 성능 최적화
- 캐시 시간을 30분으로 설정 (조정 가능)
- 강제 새로고침 옵션 제공
- 백그라운드 갱신 고려

### 에러 처리
- 네트워크 에러 시 기존 캐시 데이터 사용
- 사용자에게 명확한 에러 메시지 제공

### 향후 개선
- WebSocket을 통한 실시간 업데이트
- 사용자 선호도 학습
- A/B 테스팅 지원

## 🎯 예상 결과

### Before
```
홈 위젯 ─── _aiRecommendationProvider (격리됨)
              └── MeetingRecommendationAI

다른 화면들 ─── (접근 불가)
```

### After
```
globalAIRecommendationProvider (전역)
     ├── 홈 위젯
     ├── 새 모임 발견 화면
     ├── 향상된 추천 위젯
     └── 기타 화면들 (필요시 추가 가능)
```

## 🚨 주의사항

1. **기존 기능 유지**: 모든 변경사항은 기존 기능을 유지하면서 진행
2. **점진적 마이그레이션**: 한 번에 모든 화면을 수정하지 말고 단계별로 진행
3. **테스트 우선**: 각 단계마다 테스트를 실행하여 회귀 방지
4. **커밋 단위**: 각 Phase별로 별도 커밋 생성

---

**작성일**: 2025-09-18
**작성자**: Claude Code
**대상**: Codex AI