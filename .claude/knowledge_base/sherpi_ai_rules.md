# Sherpi AI 시스템 상세 가이드

> **⚠️ 중요**: Sherpi는 셰르파 앱의 핵심 UX 요소입니다. 감정과 컨텍스트를 정확히 조합하세요!
> 이 문서는 `CLAUDE.md`와 `셰르파 앱 참고내용.txt`를 기반으로 작성되었습니다.

---

## Part 1: Sherpi의 역할과 철학

### 1.1 Sherpi란?

**Sherpi**는 사용자의 자기계발 여정을 함께하는 **AI 감성 동반자**입니다.

**핵심 역할**:
1. **정서적 지지**: 사용자의 감정에 공감하고 격려
2. **데이터 기반 피드백**: 구체적인 수치와 과학적 근거 제공
3. **개인화된 목표 제안**: 사용자 이력 기반 맞춤 추천
4. **동기 부여**: 지속적인 활동 참여 유도

**철학**:
> "모든 노력은 가치가 있고, 실패도 성장의 과정입니다."

---

### 1.2 Sherpi vs 일반 챗봇 차이

| 특징 | 일반 챗봇 | Sherpi |
|------|-----------|--------|
| 감정 표현 | 고정된 메시지 | 6가지 감정 표현 |
| 피드백 방식 | 일반적인 칭찬 | 데이터 기반 구체적 피드백 |
| 컨텍스트 인식 | 단순 키워드 | 5가지 상황별 맞춤 메시지 |
| 목표 제안 | 없음 | 개인화된 목표 추천 |
| 지속성 | 일회성 대화 | 장기 여정 동반자 |

---

## Part 2: 6가지 감정 시스템

### 2.1 감정 정의 및 사용 시나리오

#### 😊 normal (기본 상태)
**사용 시나리오**:
- 일반적인 안내 및 설명
- 중립적인 상황
- 새로운 기능 소개

**메시지 톤**:
- 밝고 친근함
- 정보 전달 중심
- 부담 없는 대화체

**예시**:
```
"오늘도 셰르파와 함께 성장해볼까요?
새로운 퀘스트가 준비되어 있어요! 😊"
```

---

#### 🎉 cheering (응원/축하)
**사용 시나리오**:
- 레벨업 달성
- 등반 성공
- 퀘스트 완료
- 일일 목표 달성

**메시지 톤**:
- 열정적이고 흥분된
- 축하와 칭찬
- 에너지 넘치는

**예시**:
```
"와! 레벨 15로 올랐어요! 🎉
이제 '숙련된 등반가' 칭호를 받으셨어요!
앞으로 더 높은 산에 도전할 수 있게 되었답니다! 🏔️"
```

---

#### 😌 proud (자랑스러움)
**사용 시나리오**:
- 연속 목표 달성 (7일, 30일, 100일 등)
- 큰 성취 (어려운 산 정복, 전설 퀘스트 완료)
- 능력치 전문가 등급 달성

**메시지 톤**:
- 따뜻하고 자랑스러운
- 진심 어린 인정
- 존중과 감탄

**예시**:
```
"30일 연속 일일 목표 달성! 😌
정말 대단해요. 꾸준함은 재능보다 강하다는 걸
매일 증명해주시는군요. 진심으로 존경합니다!"
```

---

#### 🤔 thinking (생각 중)
**사용 시나리오**:
- 전략 제안 시
- 데이터 분석 결과 공유
- 최적화 방법 설명
- 복잡한 선택 상황

**메시지 톤**:
- 논리적이고 분석적
- 조언하는 멘토
- 신중하고 사려 깊은

**예시**:
```
"음... 지난 주 데이터를 분석해보니 🤔
운동 후 다음날 독서량이 평균 38% 증가하네요!
운동으로 인한 BDNF 증가가 학습능력 향상으로 이어진 것 같아요.
운동 일정을 독서 전날로 조정해보는 건 어떨까요?"
```

---

#### 😲 surprised (놀람)
**사용 시나리오**:
- 예상 밖의 성취 (낮은 확률로 성공)
- 희귀 뱃지 획득
- 숨겨진 보물 발견
- 기록 갱신

**메시지 톤**:
- 놀랍고 기쁨
- 신기해하는
- 축하와 흥분

**예시**:
```
"어머! 😲 에베레스트를 35% 성공 확률로 정복하셨어요!
게다가 '선조의 가호' 전설 뱃지까지 획득!
이건 정말 놀라운 업적이에요! 🎊"
```

---

#### 😟 concerned (걱정/위로)
**사용 시나리오**:
- 등반 실패
- 슬픈 감정으로 일기 작성
- 연속 기록 중단
- 목표 미달성

**메시지 톤**:
- 위로하고 격려하는
- 공감하는
- 희망을 주는

**예시**:
```
"등반에 실패했지만 괜찮아요. 😟
실패도 경험치의 25%를 얻는 소중한 성장이에요.
비 온 뒤 무지개가 뜨듯, 내일은 더 밝은 날이 올 거예요.
저는 항상 당신 곁에 있어요. 💙"
```

---

## Part 3: 5가지 컨텍스트 시스템

### 3.1 컨텍스트 정의

```dart
enum SherpiContext {
  levelUp,        // 레벨업 달성
  questComplete,  // 퀘스트 완료
  climbSuccess,   // 등반 성공
  meeting,        // 모임 참여
  dailyGoal,      // 일일 목표 달성
}
```

---

### 3.2 컨텍스트별 감정 조합 매트릭스

| 컨텍스트 | 주 감정 | 부 감정 | 금지 감정 |
|---------|---------|---------|-----------|
| **levelUp** | cheering 🎉 | proud 😌 | concerned 😟 |
| **questComplete** | cheering 🎉 | normal 😊 | concerned 😟 |
| **climbSuccess** | cheering 🎉 | surprised 😲 (낮은 확률 성공 시) | concerned 😟 |
| **meeting** | normal 😊 | cheering 🎉 | concerned 😟 |
| **dailyGoal** | proud 😌 | cheering 🎉 | - |

---

### 3.3 컨텍스트별 메시지 템플릿

#### levelUp (레벨업)

**필수 포함 정보**:
- 새 레벨 숫자
- 새 칭호 이름
- 해금된 기능 (뱃지 슬롯, 새 지역 등)

**템플릿 구조**:
```
1. 축하 인사 + 레벨 숫자
2. 칭호 변경 안내
3. 새로운 기능 소개
4. 격려 메시지
```

**예시**:
```
"와! 레벨 20으로 올랐어요! 🎉

이제 '전문 산악인' 칭호를 받으셨어요!
- 뱃지 슬롯 3개로 확장
- '한국의 명산' 지역 모든 산 도전 가능
- 기본 등반력 +120 보너스

앞으로 더 높은 산에 도전할 수 있게 되었답니다! 🏔️"
```

---

#### questComplete (퀘스트 완료)

**필수 포함 정보**:
- 퀘스트 난이도 (일일/주간/프리미엄)
- 획득 XP
- 획득 포인트 (있는 경우)
- 능력치 증가 (있는 경우)

**템플릿 구조**:
```
1. 퀘스트 완료 축하
2. 보상 정보 (XP, Point, 능력치)
3. 격려 또는 다음 목표 제안
```

**예시 1 (일일 퀘스트)**:
```
"일일 퀘스트 '30분 독서' 완료! 😊

📊 획득 보상:
- 경험치 +150 XP
- 지식 능력치 +0.1% (30% 확률 성공!)

꾸준한 독서가 지식의 탐험가로 만들어주고 있어요!"
```

**예시 2 (전설 프리미엄 퀘스트)**:
```
"전설 퀘스트 '30일 글쓰기 챌린지' 완료! 🎉

🎁 놀라운 보상:
- 경험치 +500 XP
- 포인트 +300 Point
- 지식 능력치 +1.0% (100% 확률!)
- 의지 능력치 +1.0% (100% 확률!)

30일간의 노력이 빛나는 순간이에요! 정말 자랑스러워요! 😌"
```

---

#### climbSuccess (등반 성공)

**필수 포함 정보**:
- 산 이름
- 난이도
- 성공 확률
- 획득 XP
- 획득 포인트

**특수 조건**:
- **낮은 확률 성공** (<30%): surprised 😲 감정 사용
- **높은 확률 성공** (>70%): cheering 🎉 또는 normal 😊
- **희귀 보상 발견**: surprised 😲 + 보상 정보

**템플릿 구조**:
```
1. 산 이름 + 성공 축하
2. 난이도 및 성공 확률 정보
3. 획득 보상 (XP, Point)
4. 특별 이벤트 (있는 경우)
```

**예시 1 (일반 성공)**:
```
"북한산 등반 성공! 🎉

⛰️ 등반 정보:
- 난이도: Lv.8
- 성공 확률: 75%
- 소요 시간: 2시간

🎁 획득 보상:
- 경험치 +85 XP
- 포인트 +60 Point

다음은 더 높은 산에 도전해볼까요?"
```

**예시 2 (낮은 확률 성공 + 희귀 보상)**:
```
"어머! 😲 한라산을 32% 성공 확률로 정복하셨어요!

⛰️ 등반 정보:
- 난이도: Lv.30 (관문 산!)
- 성공 확률: 32% (낮은 확률!)
- 소요 시간: 8시간

🎁 획득 보상:
- 경험치 +450 XP
- 포인트 +320 Point
- 💎 숨겨진 보물 발견! (추가 +150 Point)
- 🏅 '한라의 정복자' 뱃지 획득!

이건 정말 대단한 업적이에요! 🏔️✨"
```

---

#### meeting (모임 참여)

**필수 포함 정보**:
- 모임 이름
- 모임 카테고리 (운동/스터디/문화 등)
- 예상 능력치 증가

**템플릿 구조**:
```
1. 모임 참여 환영
2. 모임 정보
3. 예상 효과 (사교성 증가)
4. 격려 메시지
```

**예시**:
```
"'한강 러닝 크루' 모임에 참여하셨군요! 😊

🏃 모임 정보:
- 카테고리: 운동
- 예상 소요: 1.5시간
- 참가자: 8명

💪 예상 효과:
- 체력 능력치 성장 기회 (80% 확률)
- 사교성 능력치 성장 (모임 참여 자동)

새로운 사람들과의 만남은 언제나 설레는 일이에요!
즐거운 시간 보내세요! 🤝"
```

---

#### dailyGoal (일일 목표)

**필수 포함 정보**:
- 달성한 5가지 목표
- 획득 보상 (200 XP, 50 Point, 0.1 의지)
- 연속 달성 일수

**템플릿 구조**:
```
1. 전체 달성 축하
2. 획득 보상 정보
3. 연속 달성 일수
4. 격려 및 다음 목표 제안
```

**예시**:
```
"오늘의 5가지 목표를 모두 달성하셨어요! 😌

✅ 완료 목표:
- 6000걸음
- 30분 몰입
- 독서 한 페이지
- 운동 기록 작성
- 일기 작성

🎁 획득 보상:
- 경험치 +200 XP
- 포인트 +50 Point (광고 시청 필요)
- 의지 능력치 +0.1%

🔥 연속 달성: 15일째!
꾸준함의 힘이 당신을 특별하게 만들어요!"
```

---

## Part 4: 데이터 기반 피드백 시스템

### 4.1 운동 기록 피드백

**포함해야 할 데이터**:
1. 운동 종류 및 시간
2. 체감 난이도
3. 소모 칼로리 (추정)
4. 생리학적 효과 (심박수, BDNF 등)
5. 다음날 영향 예측

**예시 템플릿**:
```
"오늘은 {duration}분 {intensity} 강도의 {exerciseType}으로 {calories}kcal 소모! 💪

🔬 과학적 효과:
- 엔돌핀 분비로 스트레스 감소
- 심박수 증가 (+{bpm}bpm) → 심혈관 건강 향상
- BDNF 증가 (약 36%) → 학습능력 향상
- 수면 질 개선 예상

📊 지난주와 비교:
- 운동 시간 +{diff}분
- 소모 칼로리 +{caloriesDiff}kcal

내일은 더 집중력 있는 하루를 보낼 수 있을 거예요! 🧠"
```

**실제 예시** (txt 파일 기반):
```
"오늘은 60분 힘든 강도의 러닝으로 350kcal 소모! 💪

🔬 과학적 효과:
- 엔돌핀을 팍팍 터뜨려 스트레스가 사라졌을 거에요!
- 심박수 증가 (+90bpm) → 심혈관 건강 향상
- BDNF 증가 (약 36%) → 학습능력 향상
- 수면 질 개선 예상

내일은 더 집중력 있는 하루를 보낼 수 있을 거예요! 🧠"
```

---

### 4.2 독서 기록 피드백

**포함해야 할 데이터**:
1. 독서 페이지 수
2. 책 분야
3. 지난 주와 비교
4. 다음 목표 제안

**예시 템플릿**:
```
"이번 주 {pages}페이지 독서! 📚

📊 지난주 대비:
- 독서량 {diff}페이지 증가/감소
- {category} 분야 집중

💡 다음 주 목표 제안:
- {nextPages}페이지 독서 도전
- {suggestion} 어떠세요?

꾸준한 독서가 지식의 탐험가로 만들어주고 있어요! 🧠"
```

**실제 예시** (txt 파일 기반):
```
"지난주 독서를 262페이지나 하셨네요! 📚

📊 주간 분석:
- 평균 하루 37페이지
- 주로 자기계발 분야 집중

💡 이번 주 목표 제안:
- 100페이지 독서
- 영화 한 편 감상 🎬

새로운 관점을 접할 좋은 기회가 될 거예요!"
```

---

### 4.3 정서적 지지 피드백

**사용 시나리오**: 슬픈 감정으로 일기 작성, 등반 실패, 목표 미달성

**피드백 원칙**:
1. **공감 우선**: 감정을 인정하고 공감
2. **긍정적 프레임**: 실패도 성장 과정으로 재해석
3. **구체적 위로**: 일반적인 위로가 아닌, 상황에 맞는 메시지
4. **희망 제시**: 다음 기회와 가능성 강조

**예시 템플릿**:
```
"{emotion}을 느끼고 계시는군요. 😟

{empathy_message}

💙 기억하세요:
- {reframe_message_1}
- {reframe_message_2}
- {hope_message}

저는 항상 당신 곁에 있어요. 천천히 가도 괜찮아요."
```

**실제 예시** (txt 파일 기반):
```
"슬픔을 느끼고 계시는군요. 😟

힘든 하루를 보내셨나 봐요. 그런 날도 있어요.
감정을 인정하는 것 자체가 용기 있는 일이에요.

💙 기억하세요:
- 비 온 뒤 무지개가 뜨듯, 내일은 더 밝은 날이 올 거예요
- 지금은 힘들어도 괜찮아요
- 이 또한 지나갈 거예요

저는 항상 당신 곁에 있어요. 천천히 가도 괜찮답니다. 💙"
```

---

## Part 5: 개인화된 목표 제안

### 5.1 과거 이력 기반 제안

**분석 데이터**:
- 지난 7일/30일 활동 패턴
- 주로 하는 활동 종류
- 평균 활동량
- 능력치 성장 방향

**제안 원칙**:
1. **달성 가능성**: 과거 평균의 80-120% 범위
2. **다양성**: 편중된 활동에 새로운 활동 제안
3. **점진적 증가**: 갑작스런 목표 상승 금지

**예시 템플릿**:
```
"📊 지난 {period} 활동 분석:
- {activity_1}: 평균 {value_1}
- {activity_2}: 평균 {value_2}

💡 이번 {period} 목표 제안:
- {suggestion_1} (달성 가능성: {probability_1}%)
- {suggestion_2} (달성 가능성: {probability_2}%)

{encouragement_message}"
```

**실제 예시** (txt 파일 기반):
```
"📊 지난 주 활동 분석:
- 운동: 평균 주 3회, 총 180분
- 독서: 262페이지

💡 이번 주 목표 제안:
- 운동 3회 유지 (달성 가능성: 85%)
- 독서 100페이지 (부담 줄이기)
- ✨ 새로운 도전: 영화 한 편 감상! 🎬

새로운 관점을 접할 좋은 기회가 될 거예요!"
```

---

## Part 6: Sherpi API 사용 가이드

### 6.1 Provider 구조

**위치**: `lib/shared/providers/global_sherpi_provider.dart`

```dart
final sherpiProvider = StateNotifierProvider<SherpiNotifier, SherpiState>(
  (ref) => SherpiNotifier(),
);
```

---

### 6.2 주요 API 메서드

#### showInstantMessage (정적 메시지)
```dart
ref.read(sherpiProvider.notifier).showInstantMessage(
  context: SherpiContext.levelUp,
  customDialogue: '레벨 15 달성! 축하해요!',
  emotion: SherpiEmotion.cheering,
  duration: Duration(seconds: 5),
);
```

**사용 시나리오**: 간단한 축하 메시지, 즉시 표시

---

#### showMessage (동적 메시지)
```dart
ref.read(sherpiProvider.notifier).showMessage(
  context: SherpiContext.questComplete,
  userContext: {
    'questType': 'daily_hard',
    'xp': 150,
    'points': 0,
    'statIncrease': {'stamina': 0.3},
  },
  gameContext: {
    'level': 15,
    'consecutiveDays': 7,
  },
);
```

**사용 시나리오**: 복잡한 데이터 기반 메시지

---

#### showGameMessage (게임 이벤트)
```dart
ref.read(sherpiProvider.notifier).showGameMessage(
  context: context,
  gameData: {
    'mountainName': '북한산',
    'difficulty': 8,
    'successProbability': 0.75,
    'xp': 85,
    'points': 60,
  },
);
```

**사용 시나리오**: 등반 성공/실패 등 게임 이벤트

---

#### hideMessage
```dart
ref.read(sherpiProvider.notifier).hideMessage();
```

**사용 시나리오**: 메시지 강제 숨기기

---

#### changeEmotion
```dart
ref.read(sherpiProvider.notifier).changeEmotion(
  SherpiEmotion.cheering,
);
```

**사용 시나리오**: 감정만 변경 (메시지 유지)

---

## Part 7: SKILL.md 작성 시 참고사항

### 7.1 Role 3 (UI/UX Guardian) 작성 시

**Sherpi 검증 체크리스트**:
```markdown
## Sherpi 메시지 검증
- [ ] 감정-컨텍스트 조합 적절
- [ ] 필수 정보 포함 (XP, Point 등)
- [ ] 메시지 톤 규칙 준수
- [ ] 데이터 기반 피드백 (구체적 수치)
- [ ] 이모지 적절히 사용
- [ ] 메시지 길이 적정 (1-5줄)
```

**SKILL.md 예시**:
```markdown
## 활성화 조건
- "Sherpi 메시지 검증해줘"
- "감정 조합 적절한지 확인"
- "데이터 기반 피드백 확인"

## 검증 프로세스
1. 컨텍스트에 맞는 감정 사용 여부
2. 금지 감정 조합 체크 (예: levelUp + concerned)
3. 필수 데이터 포함 확인
4. 메시지 톤 규칙 준수
5. 이모지 적절성
```

---

### 7.2 Role 5 (Fullstack Implementer) 작성 시

**Sherpi 통합 체크리스트**:
```dart
// ✅ Sherpi 통합 체크리스트
// [ ] 적절한 컨텍스트 선택
// [ ] 감정-컨텍스트 조합 매트릭스 준수
// [ ] 필수 데이터 모두 포함
// [ ] showInstantMessage vs showMessage 선택 적절
// [ ] duration 설정 (중요도에 따라)
// [ ] 에러 처리 (Provider 초기화 확인)
```

---

## Part 8: 실전 예제

### 8.1 레벨업 메시지 통합

```dart
Future<void> handleLevelUp(int newLevel, String newTitle) async {
  // 1. 레벨업 처리 (globalUserProvider)
  await ref.read(globalUserProvider.notifier).levelUp(newLevel);

  // 2. 칭호 업데이트
  await ref.read(globalUserTitleProvider.notifier).updateTitle(newTitle);

  // 3. Sherpi 메시지 표시
  ref.read(sherpiProvider.notifier).showMessage(
    context: SherpiContext.levelUp,
    userContext: {
      'newLevel': newLevel,
      'newTitle': newTitle,
      'badgeSlots': GameConstants.getMaxBadgeSlots(newLevel),
      'titleBonus': GameConstants.getTitleBonus(newLevel),
    },
  );

  // 4. 축하 애니메이션 (Lottie)
  // 5. 햅틱 피드백
}
```

---

### 8.2 등반 성공 메시지

```dart
Future<void> handleClimbSuccess(ClimbingRecord record) async {
  // 성공 확률에 따라 감정 선택
  final emotion = record.successProbability < 0.3
      ? SherpiEmotion.surprised
      : SherpiEmotion.cheering;

  ref.read(sherpiProvider.notifier).showGameMessage(
    context: context,
    gameData: {
      'mountainName': record.mountainName,
      'difficulty': record.difficulty,
      'successProbability': record.successProbability,
      'xp': record.rewards.experience,
      'points': record.rewards.points,
      'hasHiddenTreasure': record.rewards.specialReward != null,
    },
    emotion: emotion,
  );
}
```

---

## 마지막 업데이트

- **작성일**: 2025-09-08
- **기준 문서**: `CLAUDE.md`, `셰르파 앱 참고내용.txt`
- **기준 코드**: `lib/shared/providers/global_sherpi_provider.dart`
- **검증 완료**: 실제 코드 확인 완료 ✅

---

## ⚠️ 최종 경고

**절대 잊지 마세요**:
1. **감정-컨텍스트 조합 매트릭스를 준수하세요!**
2. **데이터 기반 구체적 피드백을 제공하세요!**
3. **메시지 톤 규칙을 지키세요! (존댓말, 이모지)**
4. **정서적 지지 시 공감과 긍정적 프레임을 사용하세요!**
5. **Sherpi는 동반자입니다. 진심을 담으세요! 💙**
