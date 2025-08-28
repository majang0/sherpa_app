# 셰르피 AI 시스템 완전 가이드

## 📌 개요
셰르피(Sherpi)는 사용자의 성장 여정을 함께하는 AI 동반자로, 13가지 감정 상태와 3단계 지능형 메시지 시스템을 통해 개인화된 경험을 제공합니다.

---

## 🎯 1. 셰르피가 말하는 순간 (트리거 포인트)

### 1.1 자동 트리거 시스템

셰르피는 다음과 같은 활동이 완료될 때 **자동으로** 반응합니다:

#### **활동 완료 트리거** 
```
handleActivityCompletion() 함수를 통해 자동 실행
```

| 활동 유형 | 트리거 시점 | 컨텍스트 | 기본 감정 |
|---------|-----------|---------|---------|
| **운동 완료** | 운동 기록 저장 시 | `SherpiContext.exerciseComplete` | happy |
| **독서 완료** | 독서 기록 저장 시 | `SherpiContext.studyComplete` | thinking |
| **일기 작성** | 일기 저장 시 | `SherpiContext.diaryWritten` | defaults |
| **등반 성공** | 산 정상 도달 시 | `SherpiContext.climbingSuccess` | cheering |
| **등반 실패** | 등반 실패 시 | `SherpiContext.climbingFailure` | sad |
| **퀘스트 완료** | 퀘스트 달성 시 | `SherpiContext.questComplete` | cheering |
| **레벨업** | 레벨 상승 시 | `SherpiContext.levelUp` | special |
| **뱃지 획득** | 새 뱃지 획득 시 | `SherpiContext.badgeEarned` | cheering |
| **모임 참가** | 모임 참가/완료 시 | `SherpiContext.meetingJoined` | happy |

#### **특별 이벤트 트리거**
| 이벤트 | 조건 | 컨텍스트 | 감정 |
|-------|------|---------|------|
| **모든 일일 목표 달성** | 6개 목표 모두 완료 | `SherpiContext.achievement` | special |
| **첫 접속** | 앱 첫 실행 | `SherpiContext.welcome` | happy |
| **재방문** | 7일 이상 미접속 후 | `SherpiContext.longTimeNoSee` | surprised |
| **연속 접속** | 매일 첫 접속 | `SherpiContext.dailyGreeting` | defaults |

### 1.2 수동 트리거 (UI 상호작용)

#### **GlobalSherpiWidget 탭**
- 위치: 화면 우하단 (bottom: 100, right: 20)
- 크기: 76x76 픽셀
- 동작: 탭 시 확장 다이얼로그 표시

#### **다이얼로그 액션 버튼**
- "자세한 대화하기" → 채팅 화면 이동
- "분석하기" → 패턴 분석 실행
- "계획하기" → 계획 수립 화면
- "격려 받기" → `SherpiContext.encouragement` 메시지

---

## 🤖 2. AI 메시지 결정 로직

### 2.1 3단계 AI 사용 레벨

#### **Premium Level (100% AI 사용)**
```
- 감정적 연결이 중요한 순간
- 활동 완료 시 (운동, 독서, 일기)
- 특별한 성취 (레벨업, 마일스톤)
```

#### **Smart Level (80% AI 사용)**
```
- 특별한 달성 순간
- 뱃지 획득, 퀘스트 완료
- 등반 성공, 스탯 증가
```

#### **Basic Level (40% AI 사용)**
```
- 일상적 상호작용
- 일반 안내, 격려
- 기본 인사말
```

### 2.2 AI 사용 결정 알고리즘

```javascript
AI 사용률 = 기본 비율 + 친밀도 보너스 + 성격 보정치

기본 비율:
- Premium: 100%
- Smart: 80% + (친밀도 레벨 * 5%)
- Basic: 40% + (친밀도 레벨 * 3.3%)

성격 보정치:
- 활발한: +8%
- 유머러스한: +5%
- 차분한: +2%
- 진지한: -2%
- 균형잡힌: 0%
```

### 2.3 메시지 소스 우선순위

1. **AI Cached (🚀)**: 캐시된 AI 메시지 (즉시 응답)
2. **AI Realtime (🤖)**: 실시간 AI 생성 (2-4초)
3. **Static (⚡)**: 정적 메시지 (즉시 응답)

---

## 💬 3. 프롬프트 구성

### 3.1 기본 프롬프트 구조

```
당신은 '셰르피'입니다. 사용자의 성장을 함께하는 AI 동반자입니다.

현재 상황: [컨텍스트]
사용자 정보: [이름, 레벨, 연속 접속일]
활동 데이터: [운동/독서/일기 세부사항]
성격 타입: [활발한/차분한/유머러스한/진지한/균형잡힌]

응답 가이드:
- 성격: [성격별 톤 가이드]
- 길이: 1-2문장
- 이모지: [사용 여부]
- 말투: 친근하고 격려적인

한국어로 응답해주세요.
```

### 3.2 활동별 특화 프롬프트

#### **운동 완료**
```
- 운동 종류, 시간, 강도
- 연속 운동일수
- 이전 운동 기록과 비교
- 개선점과 격려 메시지
```

#### **독서 완료**
```
- 책 제목, 페이지 수
- 독서 평점
- 연속 독서일수
- 지식 성장 격려
```

#### **일기 작성**
```
- 기분 상태 (6가지)
- 일기 내용 요약
- 감정 공감과 위로
```

---

## 🎨 4. 시각적 요소 선택

### 4.1 감정 이미지 (13가지)

| 감정 | 파일명 | 사용 상황 |
|-----|--------|---------|
| **defaults** | sherpi_default.png | 기본 상태, 일반 대화 |
| **happy** | sherpi_happy.png | 활동 완료, 긍정적 피드백 |
| **sad** | sherpi_sad.png | 실패, 위로 필요 시 |
| **surprised** | sherpi_surprised.png | 오랜만 접속, 놀라운 성취 |
| **thinking** | sherpi_thinking.png | 분석 중, 조언 준비 |
| **guiding** | sherpi_guiding.png | 튜토리얼, 안내 |
| **cheering** | sherpi_cheering.png | 레벨업, 퀘스트 완료 |
| **warning** | sherpi_warning.png | 피로 경고, 주의사항 |
| **sleeping** | sherpi_sleeping.png | 장기 미접속, 휴식 |
| **special** | sherpi_special.png | 특별한 성취, 마일스톤 |
| **smile** | sherpi_smile.png | 차분한 만족감 |
| **talking** | sherpi_talking.png | 유머러스한 대화 |
| **confidence** | sherpi_confidence.png | 확신에 찬 조언 |

### 4.2 메시지 카드 색상

#### **감정별 그라데이션 테마**

| 테마 | 색상 조합 | 적용 감정 |
|------|---------|---------|
| **celebration** | 오렌지 → 앰버 | cheering, confidence |
| **positive** | 초록 → 블루/청록 | happy, smile, talking |
| **analytical** | 보라 → 인디고 | thinking |
| **helpful** | 블루 → 청록 | guiding |
| **surprise** | 핑크 → 보라 | surprised |
| **special** | 무지개 그라데이션 | special |
| **supportive** | 브라운 → 오렌지 | sad |
| **warning** | 오렌지 → 빨강 | warning |
| **calm** | 회색 → 라벤더 | sleeping, defaults |

### 4.3 UI 위치와 애니메이션

#### **GlobalSherpiWidget**
- **위치**: `bottom: 100, right: 20`
- **크기**: 76x76 (아바타 60x60)
- **애니메이션**: 
  - Pulse (메시지 있을 때)
  - Bounce (탭 시)
  - Scale (0.1 ~ 0.15)

#### **SherpiMessageCard**
- **위치**: `bottom: 140, left: 20, right: 20`
- **애니메이션**:
  - SlideUp (600ms, easeOutBack)
  - FadeIn (300ms)
  - AutoHide (4초 후)

#### **친밀도 레벨 배지**
- **위치**: 아바타 우하단
- **크기**: 22x22
- **색상**: 레벨별 차등 (회색→보라)

---

## 📁 5. 파일 구조와 역할

### 5.1 핵심 Provider

#### **`global_sherpi_provider.dart`**
- **역할**: 셰르피 전체 상태 관리
- **주요 기능**:
  - `showMessage()`: AI/정적 메시지 표시
  - `showInstantMessage()`: 즉시 메시지 표시
  - 감정 상태 관리
  - 메시지 히스토리 관리
  - 중복 메시지 방지 (3초)

#### **`global_user_provider.dart`** 
- **역할**: 사용자 활동 처리 및 셰르피 트리거
- **주요 기능**:
  - `handleActivityCompletion()`: 활동 완료 처리
  - 셰르피 자동 반응 트리거
  - 보상 지급 및 퀘스트 연동

### 5.2 AI 시스템

#### **`smart_sherpi_manager.dart`**
- **역할**: AI 사용 결정 및 메시지 라우팅
- **주요 기능**:
  - AI 사용률 계산
  - 3단계 메시지 소스 선택
  - 친밀도/성격 반영
  - 캐시 관리

#### **`enhanced_gemini_dialogue_source.dart`**
- **역할**: Gemini AI API 통합
- **주요 기능**:
  - 프롬프트 생성
  - AI 응답 처리
  - 폴백 처리

### 5.3 UI 컴포넌트

#### **`global_sherpi_widget.dart`**
- **역할**: 플로팅 셰르피 아바타
- **주요 기능**:
  - 감정 이미지 표시
  - 알림 배지
  - 확장 다이얼로그

#### **`sherpi_message_card.dart`**
- **역할**: 메시지 카드 표시
- **주요 기능**:
  - 슬라이드업 애니메이션
  - 감정별 색상 테마
  - 메시지 소스 표시

### 5.4 감정/대화 정의

#### **`sherpi_emotions.dart`**
- **역할**: 13가지 감정 정의
- **내용**: 감정 enum, 이미지 경로, 테마 색상

#### **`sherpi_dialogues.dart`**
- **역할**: 컨텍스트와 정적 대화
- **내용**: 51개 컨텍스트, 상황별 메시지

---

## 🔄 6. 실행 플로우

### 6.1 활동 완료 시 플로우

```
1. 사용자 활동 완료 (운동/독서/일기)
   ↓
2. handleActivityCompletion() 호출
   ↓
3. 보상 지급 (XP, 포인트, 스탯)
   ↓
4. _triggerSherpiReaction() 실행
   ↓
5. SmartSherpiManager.getMessage() 호출
   ↓
6. AI 사용 결정 (레벨, 친밀도, 성격)
   ↓
7. 메시지 소스 선택:
   - 캐시 확인 → AI 생성 → 정적 메시지
   ↓
8. 감정 분석 및 선택
   ↓
9. SherpiMessageCard 표시
   ↓
10. 4초 후 자동 숨김
```

### 6.2 UI 탭 시 플로우

```
1. GlobalSherpiWidget 탭
   ↓
2. markMessageAsRead() (알림 제거)
   ↓
3. SherpiExpandedDialog 표시
   ↓
4. 현재 메시지 표시
   ↓
5. 액션 버튼 제공:
   - 채팅
   - 분석
   - 계획
   - 격려
```

---

## 🎮 7. 개인화 시스템

### 7.1 성격 타입별 특성

| 성격 | AI 사용률 | 메시지 톤 | 주요 감정 |
|-----|---------|----------|---------|
| **활발한** | +8% | 에너지 넘치는, !! 많음 | cheering |
| **차분한** | +2% | 조용하고 사려깊은 | thinking |
| **유머러스한** | +5% | 재치있고 유쾌한 | talking |
| **진지한** | -2% | 체계적이고 정확한 | smile |
| **균형잡힌** | 0% | 적절한 균형 | guiding |

### 7.2 친밀도 시스템

- **레벨 1-10**: 상호작용으로 증가
- **AI 사용률 증가**: 레벨당 3.3~5%
- **시각적 표시**: 아바타 하단 배지
- **색상 변화**: 회색 → 보라색

### 7.3 메시지 빈도 조절

- **최소 (0.3x)**: 중요한 순간만
- **보통 (1.0x)**: 기본 빈도
- **최대 (2.0x)**: 모든 활동 반응

---

## ⚡ 8. 성능 최적화

### 8.1 응답 시간

| 소스 | 응답 시간 | 표시 |
|------|----------|------|
| **Static** | 즉시 (<5ms) | ⚡ |
| **AI Cached** | 즉시 (<50ms) | 🚀 |
| **AI Realtime** | 2-4초 | 🤖 |

### 8.2 중복 방지

- **메시지 중복**: 3초 내 같은 컨텍스트 무시
- **카드 중복**: 5초 내 같은 메시지 무시
- **탭 전환**: 중복 트리거 방지

### 8.3 캐시 전략

- **유효 기간**: 24시간
- **최대 크기**: 50개 메시지
- **키 구성**: 컨텍스트 + 사용자 데이터

---

## 🐛 9. 디버그 정보

### 9.1 메시지 메타데이터

```json
{
  "context": "exerciseComplete",
  "timestamp": "2024-08-08T10:30:00",
  "response_source": "aiCached",
  "is_fast_response": true,
  "generation_duration_ms": 45,
  "emotion_analyzed": true,
  "intimacy_level": 5,
  "personality_type": "energetic"
}
```

### 9.2 주요 로그 포인트

- AI 초기화: "Gemini API initialized"
- 메시지 생성: "Sherpi message shown"
- 캐시 히트: "Cache hit for context"
- 중복 방지: "Duplicate message blocked"

---

## 📝 10. 요약

셰르피 AI 시스템은 **활동 완료 자동 감지**, **3단계 AI 결정 로직**, **13가지 감정 표현**, **개인화된 성격 시스템**을 통해 사용자에게 맞춤형 동반자 경험을 제공합니다.

**핵심 특징:**
- ✅ 100% AI 사용 (활동 완료 시)
- ✅ 40-80% AI 사용 (일반 상황)
- ✅ 친밀도 기반 AI 사용률 증가
- ✅ 5가지 성격 타입
- ✅ 13가지 감정 상태
- ✅ 51개 상황별 컨텍스트
- ✅ 실시간 캐싱 시스템
- ✅ 중복 메시지 방지
- ✅ 감정 기반 색상 테마
- ✅ 부드러운 애니메이션

이 시스템은 사용자가 셰르피와 함께한다는 느낌을 받으며, 개인화된 성장 여정을 경험할 수 있도록 설계되었습니다.