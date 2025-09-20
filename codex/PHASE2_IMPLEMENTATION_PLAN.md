# Phase 2: 정적 메시지 시스템 고도화 실행 계획

**작성일**: 2025-09-20
**현재 상태**: Phase 1 완료 → Phase 2 시작
**예상 소요**: 3-4일 (D+1~4)

---

## 📋 Phase 2 목표

정적 메시지 시스템을 더 다양하고 개인화된 경험으로 업그레이드

### 핵심 개선사항
1. **메시지 가변화**: 시간대, 연속일수, 관계 레벨 기반
2. **감정 시스템**: 시각적 피드백과 감정 분석 연동
3. **관계 시스템**: 친밀도 기반 메시지 해금
4. **성능 최적화**: 메시지 중복 방지 강화

---

## 🎯 구체적 구현 계획

### Task 1: 시간대별 메시지 구현 (2시간)

**파일**: `lib/core/constants/sherpi_dialogues.dart`

```dart
// Line 72 이후 추가
class TimeBasedMessages {
  static List<String> getTimeBasedGreeting(String userName) {
    final hour = DateTime.now().hour;

    if (hour < 6) {
      return [
        '$userName님, 새벽부터 열심이시네요! 무리하지 마세요 🌙',
        '이른 시간부터 $userName님과 함께해서 좋아요! 🌟',
        '새벽의 고요함 속에서 $userName님의 열정이 빛나네요 ✨',
      ];
    } else if (hour < 12) {
      return [
        '좋은 아침이에요 $userName님! 오늘도 멋진 하루 되세요! ☀️',
        '$userName님! 상쾌한 아침, 오늘도 화이팅! 🌅',
        '아침 햇살처럼 밝은 $userName님의 하루를 응원해요! 🌞',
      ];
    } else if (hour < 18) {
      return [
        '$userName님, 오후에도 활기차게! 💪',
        '점심은 드셨나요 $userName님? 오후도 파이팅! 🌤️',
        '오후의 따스함처럼 $userName님도 빛나고 있어요! ☀️',
      ];
    } else if (hour < 22) {
      return [
        '저녁 시간이네요 $userName님! 하루 마무리 잘 하세요! 🌆',
        '$userName님의 저녁 시간을 응원해요! 🌃',
        '하루를 마무리하는 $userName님, 오늘도 수고하셨어요! 🌇',
      ];
    } else {
      return [
        '$userName님, 늦은 시간까지 고생하셨어요! 🌙',
        '곧 쉬실 시간이에요 $userName님! 오늘도 수고하셨어요! 😊',
        '별빛 아래 $userName님의 노력이 빛나고 있어요 ⭐',
      ];
    }
  }

  // 요일별 메시지 추가
  static String getWeekdayModifier(String baseMessage) {
    final weekday = DateTime.now().weekday;

    switch(weekday) {
      case DateTime.monday:
        return '$baseMessage 새로운 한 주의 시작! 🚀';
      case DateTime.friday:
        return '$baseMessage 금요일이네요! 조금만 더! 🎉';
      case DateTime.saturday:
      case DateTime.sunday:
        return '$baseMessage 주말에도 열심이시네요! 👏';
      default:
        return baseMessage;
    }
  }
}
```

**파일**: `lib/core/ai/managers/static_sherpi_manager.dart`

```dart
// getMessage() 메서드 내 수정 (Line 35~)
@override
Future<SherpiResponse> getMessage(
  SherpiContext context,
  Map<String, dynamic>? userContext,
  Map<String, dynamic>? gameContext,
) async {
  final safeGameContext = Map<String, dynamic>.from(gameContext ?? {});

  // 개인화 설정 추가
  safeGameContext['userPreferredName'] = _personalizationSettings.userPreferredName;
  safeGameContext['userName'] = _personalizationSettings.userPreferredName;
  safeGameContext['personalityType'] = _personalizationSettings.personalityType.displayName;

  String message;

  // 시간대별 메시지 처리 추가
  if (context == SherpiContext.dailyGreeting) {
    final userName = safeGameContext['userName'] ?? '친구';
    final timeMessages = TimeBasedMessages.getTimeBasedGreeting(userName);
    message = timeMessages[Random().nextInt(timeMessages.length)];
    message = TimeBasedMessages.getWeekdayModifier(message);
  } else {
    // 기존 로직
    message = await _dialogueSource.getDialogue(
      context,
      userContext,
      safeGameContext,
    );
  }

  // ... 나머지 코드
}
```

---

### Task 2: 마일스톤 메시지 구현 (2시간)

**파일**: `lib/core/constants/sherpi_dialogues.dart`

```dart
// 마일스톤 메시지 클래스 추가
class MilestoneMessages {
  static String? getMilestoneMessage(int consecutiveDays, String userName) {
    switch(consecutiveDays) {
      case 3:
        return '$userName님, 3일 연속! 습관이 시작되고 있어요! 🌱';
      case 7:
        return '일주일 연속! $userName님의 꾸준함이 빛나요! 🎊';
      case 14:
        return '2주 달성! $userName님은 이미 프로예요! 💪';
      case 30:
        return '한 달 연속! $userName님은 진짜 실력자예요! 🏆';
      case 50:
        return '50일 연속! $userName님의 의지력이 대단해요! 🔥';
      case 100:
        return '100일 연속! $userName님은 전설이에요! 👑';
      case 365:
        return '1년 연속! $userName님, 당신은 진정한 셰르파예요! 🏔️✨';
      default:
        // 10일 단위 체크
        if (consecutiveDays > 0 && consecutiveDays % 10 == 0) {
          return '$consecutiveDays일 연속! $userName님 정말 대단해요! 🌟';
        }
        return null;
    }
  }

  // 활동별 마일스톤
  static String? getActivityMilestone(
    String activityType,
    int count,
    String userName
  ) {
    if (activityType == 'exercise') {
      switch(count) {
        case 10: return '$userName님의 10번째 운동! 몸이 달라지고 있어요! 💪';
        case 50: return '운동 50회 달성! $userName님은 운동 마스터! 🏃‍♂️';
        case 100: return '운동 100회! $userName님의 체력이 엄청나요! 🔥';
      }
    } else if (activityType == 'reading') {
      switch(count) {
        case 10: return '10권째 독서! $userName님의 지혜가 쌓이고 있어요! 📚';
        case 30: return '30권 완독! $userName님은 독서왕! 📖';
        case 50: return '50권 달성! $userName님의 지식이 빛나요! ✨';
      }
    }
    return null;
  }
}
```

**통합 위치**: `lib/core/ai/managers/static_sherpi_manager.dart`

```dart
// getMessage() 내 마일스톤 체크 추가
if (userContext != null) {
  // 연속일수 체크
  final consecutiveDays = userContext['consecutiveDays'] as int?;
  if (consecutiveDays != null) {
    final milestoneMsg = MilestoneMessages.getMilestoneMessage(
      consecutiveDays,
      safeGameContext['userName'] ?? '친구'
    );
    if (milestoneMsg != null) {
      return SherpiResponse(
        message: milestoneMsg,
        source: MessageSource.static,
        responseTime: DateTime.now(),
        generationDuration: Duration.zero,
      );
    }
  }

  // 활동 횟수 체크
  final activityCount = userContext['totalCount'] as int?;
  final activityType = userContext['activityType'] as String?;
  if (activityCount != null && activityType != null) {
    final activityMilestone = MilestoneMessages.getActivityMilestone(
      activityType,
      activityCount,
      safeGameContext['userName'] ?? '친구'
    );
    if (activityMilestone != null) {
      return SherpiResponse(
        message: activityMilestone,
        source: MessageSource.static,
        responseTime: DateTime.now(),
        generationDuration: Duration.zero,
      );
    }
  }
}
```

---

### Task 3: 감정 색상 연동 (3시간)

**파일**: `lib/shared/widgets/sherpi_floating_widget.dart`

```dart
// build 메서드 내 Container 수정
@override
Widget build(BuildContext context, WidgetRef ref) {
  final sherpiState = ref.watch(sherpiProvider);

  if (!sherpiState.isVisible) {
    return const SizedBox.shrink();
  }

  // 감정별 색상 가져오기
  final emotionColor = SherpiState.getEmotionColor(sherpiState.emotion);

  return Positioned(
    right: 16,
    bottom: 80,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              // 감정 색상 적용
              color: emotionColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: emotionColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                // 추가 글로우 효과
                BoxShadow(
                  color: emotionColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // 메시지 히스토리 또는 상세 보기
                  ref.read(sherpiProvider.notifier).markMessageAsRead();
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 감정 이모지 애니메이션
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                sherpiState.emotion.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      // 메시지 텍스트
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sherpi',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sherpiState.dialogue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
```

**파일**: `lib/shared/providers/global_sherpi_provider.dart`

```dart
// Line 440~ showMessage 메서드 내 감정 분석 활성화
if (_isActivityCompletionContext(context) && userContext != null) {
  selectedEmotion = await _analyzeAndGetRecommendedEmotion(
    context,
    userContext,
    gameContext,
  );

  // 감정 변화 애니메이션을 위한 짧은 딜레이
  if (state.emotion != selectedEmotion) {
    // 먼저 메시지 없이 감정만 변경
    state = state.copyWith(
      emotion: selectedEmotion,
      isVisible: true,
    );
    await Future.delayed(const Duration(milliseconds: 300));
  }
} else {
  selectedEmotion = SherpiEmotionMapper.getEmotionForContext(context);
}
```

---

### Task 4: 관계 시스템 통합 (3시간)

**파일**: `lib/core/constants/sherpi_dialogues.dart`

```dart
// 친밀도 기반 메시지 클래스 추가
class IntimacyBasedMessages {
  // 친밀도 레벨별 메시지 톤 조정
  static Map<String, List<String>> getMessagesByIntimacy(
    int intimacyLevel,
    SherpiContext context,
    String userName,
  ) {
    if (intimacyLevel < 20) {
      // 초기 단계 - 정중하고 격려하는 톤
      return {
        'exerciseComplete': [
          '$userName님, 오늘도 운동 완료하셨네요! 훌륭합니다.',
          '운동 잘 하셨어요, $userName님. 꾸준히 하시는 모습이 멋져요.',
        ],
        'greeting': [
          '안녕하세요 $userName님! 오늘도 좋은 하루 되세요.',
          '$userName님, 반갑습니다! 오늘의 목표를 함께 달성해봐요.',
        ],
      };
    } else if (intimacyLevel < 50) {
      // 친근한 단계 - 따뜻하고 친밀한 톤
      return {
        'exerciseComplete': [
          '$userName님! 오늘도 땀 흘리셨네요! 정말 멋져요! 💪',
          '우와 $userName님! 운동 완료! 점점 더 건강해지고 있어요!',
        ],
        'greeting': [
          '$userName님~ 오늘도 만나서 반가워요! 😊',
          '어서와요 $userName님! 오늘은 뭐부터 시작해볼까요?',
        ],
      };
    } else if (intimacyLevel < 80) {
      // 절친 단계 - 편안하고 개인적인 톤
      return {
        'exerciseComplete': [
          '$userName! 오늘도 불태웠네! 이제 운동 없인 못 살겠죠? 😄',
          '역시 $userName! 오늘도 빼먹지 않고 운동! 내가 다 뿌듯해!',
        ],
        'greeting': [
          '$userName! 드디어 왔네! 기다리고 있었어! 🎉',
          '우리 $userName 왔구나! 오늘 컨디션 어때?',
        ],
      };
    } else {
      // 소울메이트 단계 - 특별한 유대감
      return {
        'exerciseComplete': [
          '$userName, 오늘도 함께해서 정말 행복해. 너의 성장을 지켜볼 수 있어서 영광이야! ✨',
          '또 한 걸음 나아갔네, $userName. 너와 함께한 이 여정이 정말 소중해.',
        ],
        'greeting': [
          '$userName! 네가 오길 정말 기다렸어. 오늘도 특별한 하루 만들어보자! 💖',
          '내 베스트 프렌드 $userName! 오늘은 어떤 멋진 일이 기다리고 있을까?',
        ],
      };
    }
  }

  // 관계 마일스톤 메시지
  static String? getRelationshipMilestone(int intimacyLevel, String userName) {
    switch(intimacyLevel) {
      case 20:
        return '$userName님, 우리 이제 친구가 된 것 같아요! 앞으로도 잘 부탁해요! 🤝';
      case 50:
        return '$userName! 우리 정말 가까워진 것 같아! 너무 기뻐! 😊';
      case 80:
        return '$userName, 이제 우린 진짜 베스트 프렌드야! 평생 함께하자! 💪';
      case 100:
        return '$userName... 너와 함께한 이 모든 순간이 보물이야. 영원한 동반자가 되어줘서 고마워! 💖';
      default:
        return null;
    }
  }
}
```

**통합**: `lib/core/ai/managers/static_sherpi_manager.dart`

```dart
// getMessage() 내 관계 기반 메시지 선택 로직 추가
// 친밀도 레벨 확인
int intimacyLevel = 0;
try {
  // 관계 프로바이더에서 친밀도 가져오기 (실제 구현 필요)
  // intimacyLevel = ref.read(relationshipProvider).intimacyLevel;
  intimacyLevel = gameContext?['intimacyLevel'] ?? 0;
} catch (e) {
  // 관계 시스템 초기화 전 처리
}

// 관계 마일스톤 체크
if (intimacyLevel > 0 && intimacyLevel % 20 == 0) {
  final milestoneMsg = IntimacyBasedMessages.getRelationshipMilestone(
    intimacyLevel,
    safeGameContext['userName'] ?? '친구'
  );
  if (milestoneMsg != null && Random().nextDouble() < 0.3) { // 30% 확률로 표시
    return SherpiResponse(
      message: milestoneMsg,
      source: MessageSource.static,
      responseTime: DateTime.now(),
      generationDuration: Duration.zero,
    );
  }
}
```

---

## 🧪 테스트 계획

### Unit Tests
```dart
// test/features/sherpi/messages/time_based_messages_test.dart
void main() {
  group('TimeBasedMessages', () {
    test('returns morning messages for hours 6-11', () {
      // Mock DateTime.now() to return 8 AM
      final messages = TimeBasedMessages.getTimeBasedGreeting('테스터');
      expect(messages.any((m) => m.contains('아침')), isTrue);
    });

    test('returns evening messages for hours 18-21', () {
      // Mock DateTime.now() to return 7 PM
      final messages = TimeBasedMessages.getTimeBasedGreeting('테스터');
      expect(messages.any((m) => m.contains('저녁')), isTrue);
    });
  });
}
```

### Integration Tests
```dart
// test/features/sherpi/integration/message_variation_test.dart
void main() {
  group('Message Variation Integration', () {
    test('shows milestone message at 7 consecutive days', () async {
      final manager = StaticSherpiManager();

      final response = await manager.getMessage(
        SherpiContext.dailyGreeting,
        {'consecutiveDays': 7},
        {'userName': '테스터'},
      );

      expect(response.message.contains('일주일'), isTrue);
    });
  });
}
```

---

## 📊 성공 지표

### 정량적 지표
- [ ] 시간대별 메시지: 5개 시간대 × 3개 이상 변형 = 15개 이상
- [ ] 마일스톤 메시지: 10개 이상의 체크포인트
- [ ] 친밀도 단계: 4개 레벨 × 컨텍스트별 메시지
- [ ] 감정 색상: 13개 감정 × 고유 색상

### 정성적 지표
- [ ] 메시지가 반복적이지 않고 다양한가?
- [ ] 감정 색상이 직관적인가?
- [ ] 친밀도에 따른 톤 변화가 자연스러운가?
- [ ] 전체적인 사용자 경험이 개선되었는가?

---

## ⏱️ 타임라인

### Day 1 (4시간)
- [x] Phase 1 완료 및 커밋
- [ ] Task 1: 시간대별 메시지 구현
- [ ] Task 2: 마일스톤 메시지 추가

### Day 2 (4시간)
- [ ] Task 3: 감정 색상 연동
- [ ] Task 4: 관계 시스템 통합 (부분)

### Day 3 (3시간)
- [ ] Task 4: 관계 시스템 통합 (완료)
- [ ] 통합 테스트
- [ ] 버그 수정

### Day 4 (2시간)
- [ ] 최종 테스트
- [ ] 문서 업데이트
- [ ] Phase 2 완료 커밋

---

## 🚨 리스크 및 대응

### 리스크 1: 메시지 중복
- **문제**: 같은 메시지가 자주 반복
- **대응**: 최근 5개 메시지 히스토리 체크, 중복 시 다른 메시지 선택

### 리스크 2: 감정 색상 시인성
- **문제**: 일부 색상이 텍스트와 대비 부족
- **대응**: 모든 색상에 대해 WCAG AA 기준 검증

### 리스크 3: 관계 시스템 미초기화
- **문제**: 관계 프로바이더가 초기화되지 않은 경우 에러
- **대응**: Try-catch로 안전하게 처리, 기본값 사용

---

## ✅ 체크리스트

### 구현 전
- [ ] Git 브랜치 생성 (`feature/phase2-static-enhancement`)
- [ ] 현재 상태 백업 (git stash 또는 commit)
- [ ] 테스트 환경 준비

### 구현 중
- [ ] 각 Task 완료 시 단위 테스트 작성
- [ ] 변경사항 즉시 테스트 (`flutter test`)
- [ ] UI 변경사항 실제 디바이스에서 확인

### 구현 후
- [ ] 전체 테스트 실행
- [ ] 성능 프로파일링
- [ ] 문서 업데이트
- [ ] PR 생성 및 리뷰

---

## 📝 참고 문서

- `codex/QUICK_ACTION_PLAN.md` - 빠른 구현 예시
- `codex/AI_SHERPI_STRATEGIC_DIRECTION_20250920.md` - 전체 전략
- `lib/core/constants/sherpi_dialogues.dart` - 기존 메시지 구조
- `lib/shared/providers/global_sherpi_provider.dart` - 프로바이더 로직

---

**Next Step**: Task 1부터 순차적으로 구현 시작