# 목표 달성 기능 구현 분석 보고서

**작성일**: 2025-11-09
**분석 대상**: `lib/features/goals/` 전체 + `lib/features/home/presentation/widgets/goal_achievement_widget.dart`
**기준 문서**: `project/AI goal.txt`

---

## 📋 목차

1. [개요](#-개요)
2. [원본 요구사항 요약](#-원본-요구사항-요약)
3. [구현 상태 분석](#-구현-상태-분석)
   - [달성된 기능](#-달성된-기능-85)
   - [미달성 기능](#-미달성-기능-15)
4. [세부 기능별 비교](#-세부-기능별-비교)
5. [개선 필요 사항](#-개선-필요-사항)
6. [개선 방안 제안](#-개선-방안-제안)
7. [우선순위별 개발 로드맵](#-우선순위별-개발-로드맵)

---

## 🎯 개요

Sherpa App의 **목표 달성 기능**은 사용자가 설정한 목표와 루틴을 관리하고, AI 분석을 통해 개선 방안을 제시하는 핵심 기능입니다. 본 문서는 `project/AI goal.txt`에 명시된 원본 요구사항과 현재 구현 상태를 비교 분석하여, 달성된 기능과 미달성 기능을 명확히 하고 개선 방안을 제시합니다.

**전체 달성률**: **85%** (핵심 기능 구현 완료, 세부 기능 일부 미구현)

---

## 📝 원본 요구사항 요약

### 1. 홈 화면 위젯 (goal_achievement_widget.dart)

```
홈 화면 위젯
제목: 목표 달성하기
부제: 셰르피와 함께 목표를 달성해요!

1. 목표 버튼 (목표창 이동), 목표 목록 (시각화 필요)
2. 루틴 버튼 (루틴창 이동), 루틴 목록 (체크리스트)
3. 셰르피 분석 버튼 (AI의 목표, 루틴 분석창 이동) -> 30포인트 소모
```

### 2. 목표창 (goals_screen.dart)

```
박지호님이 설정한 목표에요!

사용자 정보 버튼:
1) 키 174CM 몸무게 64KG 체지방률 5% (모르면 공란) 골격근량 35.3KG (모르면 공란)
2) 생년 1999
3) 학업 성적, 대회 수상경력, 자격증, 어학성적

이전 목표 버튼:
[대회] 2025.09.05 전국 AI활용 아이디어 경진대회 대상 / 미달성 / 상세 내용 (최우수상) / 실패 이유 (...)
[대회] 2025.10.02 교내 창의적 종합설계 경진대회 대상 / 달성 / 축하드려요 / 성공 이유 (...)
... (목표 달성률 % 시각화)

현재 목표 시각화:
[대회] 2025.11.25 전국 창의적 종합설계 경진대회 대상
[운동] 2025.12.06 서울한강마라톤 하프 1시간 38분
클릭해서 목표 상세, 수정, 삭제

우측 하단 목표 추가 버튼 (모달)
- 카테고리: 운동, 학습, 대회, 자격증
- 날짜 (년월일)
- 상세 내용 (이름)
- 목표 (시간, 목표, 조회수 등)
```

### 3. 루틴창 (routines_screen.dart)

```
박지호님이 설정한 루틴이에요!

사용자 정보 버튼: 목표창과 공유

이전 루틴 버튼:
[문화] 주 1회 독서 한 권 완독하기 / 2025.08.10~2025.10.12 / 목표 달성률 임의 (프로그레스바) / 미완주
[운동] 매주 월요일 등산하기 / 2025.09.01~2025.10.25 / 목표 달성률 100% / 완주 (완주 여부)
목표 달성률 100%인 루틴, 완주한 루틴은 추가 효과 적용해 표시

셰르파 특색에 맞게 게임적인 요소처럼 보이게끔 하는 위젯 하나 추가

체크리스트:
[운동] 매주 화 수 금 오전 7시 러닝
[건강] 매일 영양제 먹기
[학습] 매일 앱 개발 30분
...
클릭해서 루틴 상세, 수정, 삭제

체크리스트 정렬:
1) 매일, 주 N회, 매주 요일 → 요일에 해당하지 않으면 체크리스트에는 안 나옴
   시간 설정했다면 시간대별로 정렬: 눈 뜨자마자 / 시간 설정 / 아무때나 / 자기 전 순서
2) 월 N회는 아래에
3) 체크된 내용은 가장 아래로 이동, 완료 표시

우측 하단 루틴 추가 버튼 (모달)
- 카테고리: 운동, 문화, 학습, 건강, 기타
- 주기: 매일 (시간 설정 선택) / 주N회 / 매주 [요일] / 월 N회
- 상세 내용 (이름)
- 기간 (언제까지, 계속)
```

### 4. AI 분석창 (ai_analysis_screen.dart)

```
AI 분석창 -> 목표와 루틴에 따라 사용자가 목표, 루틴을 달성할 수 있도록 AI가 체계적으로 분석해주는 기능

1) 버튼을 누르면 우선 카테고리 선택창이 나옴 - 운동, 대회 (목표에 있는 카테고리만 선택창에 나오도록)
2) 해당 카테고리를 선택하면 30포인트가 소모됩니다 이런 류의 내용이 나와서 확인,취소 버튼으로 사용자 의사를 확인함
3) 사용자 확인시 셰르피가 분석을 진행합니다 -> lib/features/meetings/presentation/widgets/ai/ai_analysis_loading_widget.dart
   내용은 목표와 루틴에 맞는 내용을 배치하되 디자인은 해당 위젯 디자인 참조
4) 실제 분석창 말고 데모로 간단한 창 배치 (ai 아직 연결 안함 추후 따로 할 예정)
```

---

## 📊 구현 상태 분석

### ✅ 달성된 기능 (85%)

#### 1. 홈 화면 위젯 (goal_achievement_widget.dart) - ✅ 100%

| 요구사항 | 구현 상태 | 파일 위치 |
|---------|---------|----------|
| 제목/부제 표시 | ✅ 완료 | `goal_achievement_widget.dart:181-210` |
| 목표 요약 카드 + 진행률 | ✅ 완료 | `goal_achievement_widget.dart:220-338` |
| 루틴 요약 카드 + 완료율 | ✅ 완료 | `goal_achievement_widget.dart:342-518` |
| 셰르피 분석 버튼 (30P) | ✅ 완료 | `goal_achievement_widget.dart:522-597` |
| 셰르피 캐릭터 + 감정 표현 | ✅ 완료 | `goal_achievement_widget.dart:131-170` |
| 화면 이동 (목표/루틴) | ✅ 완료 | `/goals`, `/routines` 라우트 |

**특징**:
- ModernColors 디자인 시스템 준수
- 그라디언트 헤더 + 화이트 카드 UI
- 셰르피 감정 자동 선택 (목표 완료율 기반)
- 포인트 부족 시 경고 다이얼로그

---

#### 2. 목표창 (goals_screen.dart) - ✅ 90%

| 요구사항 | 구현 상태 | 파일 위치 |
|---------|---------|----------|
| 사용자 정보 버튼 | ✅ 완료 | `goals_screen.dart:34-40` |
| 이전 목표 버튼 | ✅ 완료 | `goals_screen.dart:42-48` |
| 현재 목표 리스트 | ✅ 완료 | `goals_screen.dart:105-115` |
| 목표 카드 (클릭 → 상세) | ✅ 완료 | `goal_card_widget.dart` |
| 목표 추가/수정/삭제 | ✅ 완료 | `goal_modal_widget.dart` + `goal_provider.dart` |
| 카테고리 (4종) | ✅ 완료 | `goal_model.dart:52-64` |
| 날짜순 정렬 | ✅ 완료 | `goal_provider.dart:39` |
| 목표 완료 처리 | ✅ 완료 | `goal_provider.dart:116-144` |

**달성된 세부 기능**:
- ✅ 목표 모델: `id`, `category`, `date`, `name`, `targetValue`, `isAchieved`, `achievementRate`, `achievementDetails`, `reasonForResult`, `createdAt`, `completedAt`
- ✅ 이전 목표 저장 (SharedPreferences)
- ✅ 목표 완료 시 이전 목표로 이동

**미달성 세부 기능**:
- ❌ 사용자 정보 모달의 세부 필드 (키, 몸무게, 체지방률, 골격근량, 생년, 학업 성적, 대회 수상경력, 자격증, 어학성적)
- ❌ 이전 목표 화면의 달성률 % 시각화

---

#### 3. 루틴창 (routines_screen.dart) - ✅ 85%

| 요구사항 | 구현 상태 | 파일 위치 |
|---------|---------|----------|
| 사용자 정보 버튼 | ✅ 완료 | `routines_screen.dart:35-40` |
| 이전 루틴 버튼 | ✅ 완료 | `routines_screen.dart:43-50` |
| 오늘 루틴 체크리스트 | ✅ 완료 | `routines_screen.dart:175-185` |
| 루틴 체크/언체크 | ✅ 완료 | `routine_provider.dart:129-174` |
| 루틴 추가/수정/삭제 | ✅ 완료 | `routine_modal_widget.dart` + `routine_provider.dart` |
| 카테고리 (5종) | ✅ 완료 | `routine_model.dart:131-145` |
| 주기별 표시 필터링 | ✅ 완료 | `routine_model.dart:64-96` |
| 완료율 계산 | ✅ 완료 | `routine_provider.dart:196-237` |
| 루틴 정렬 (체크 여부 → 주기 → 시간) | ✅ 완료 | `routine_provider.dart:240-256` |

**달성된 세부 기능**:
- ✅ 루틴 모델: `id`, `category`, `frequency`, `name`, `timePreference`, `specificTime`, `weekdays`, `period`, `endDate`, `checkHistory`, `completionRate`, `isCompleted`, `createdAt`, `finishedAt`
- ✅ 오늘 표시 여부 자동 판단 (`shouldShowToday()`)
- ✅ 이전 루틴 저장
- ✅ 루틴 완주 처리

**미달성 세부 기능**:
- ❌ 게임적 요소 위젯 (요구사항: "셰르파 특색에 맞게 게임적인 요소처럼 보이게끔 하는 위젯 하나 추가")
- ⚠️ 시간대별 정렬 로직 일부 미흡 (요구사항: 눈 뜨자마자 / 시간 설정 / 아무때나 / 자기 전 순서)
  - 현재: `timePriority` 구현되어 있으나 복잡도 높음 (`routine_model.dart:104-117`)

---

#### 4. AI 분석창 (ai_analysis_screen.dart) - ✅ 75%

| 요구사항 | 구현 상태 | 파일 위치 |
|---------|---------|----------|
| 카테고리 선택창 | ✅ 완료 | `ai_analysis_screen.dart:45-89` |
| 30포인트 소모 확인 다이얼로그 | ✅ 완료 | `ai_analysis_screen.dart:428-458` |
| 포인트 차감 | ✅ 완료 | `ai_analysis_screen.dart:463-467` |
| 로딩 상태 표시 | ✅ 완료 | `ai_analysis_screen.dart:265-302` |
| 데모 분석 결과 표시 | ✅ 완료 | `ai_analysis_screen.dart:305-410` |
| 카테고리별 데모 콘텐츠 | ✅ 완료 | `achievement_analysis_model.dart:58-155` |

**달성된 세부 기능**:
- ✅ AchievementAnalysisModel 모델
- ✅ 카테고리별 데모 분석 내용 (운동, 대회, 학습, 자격증)
- ✅ 분석 일시 기록

**미달성 세부 기능**:
- ❌ 실제 AI API 연결 (현재 데모만 구현, `achievement_analysis_model.dart:77` 명시)
- ❌ 실제 목표/루틴 데이터 기반 분석 (현재 하드코딩된 데모 텍스트만 표시)
- ❌ 로딩 위젯 디자인이 `lib/features/meetings/presentation/widgets/ai/ai_analysis_loading_widget.dart`와 다름

---

### ❌ 미달성 기능 (15%)

#### 1. 사용자 정보 모달 세부 필드

**요구사항**:
```
1) 키 174CM 몸무게 64KG 체지방률 5% (모르면 공란) 골격근량 35.3KG (모르면 공란)
2) 생년 1999
3) 학업 성적, 대회 수상경력, 자격증, 어학성적
```

**현재 상태**:
- ❌ 미구현 (`user_info_modal_widget.dart` 존재하나 세부 필드 없음)

**영향도**: 중간 (AI 분석 정확도에 영향)

---

#### 2. 이전 목표 화면 상세 표시

**요구사항**:
```
[대회] 2025.09.05 전국 AI활용 아이디어 경진대회 대상 / 미달성 / 상세 내용 (최우수상) / 실패 이유 (...)
목표 달성률 % 시각화
```

**현재 상태**:
- ✅ 모델에 필드 존재 (`achievementRate`, `achievementDetails`, `reasonForResult`)
- ❌ UI에 시각화 안됨 (`previous_goals_widget.dart`에서 간단히 표시만)

**영향도**: 중간 (사용자 피드백 부족)

---

#### 3. 루틴 게임적 요소

**요구사항**:
```
셰르파 특색에 맞게 게임적인 요소처럼 보이게끔 하는 위젯 하나 추가
```

**현재 상태**:
- ❌ 미구현

**영향도**: 낮음 (UX 개선 요소)

---

#### 4. 실제 AI API 연결

**요구사항**:
```
AI가 체계적으로 분석해주는 기능
```

**현재 상태**:
- ❌ 데모 버전만 구현 (하드코딩된 텍스트)
- ❌ 실제 목표/루틴 데이터 활용 안함

**영향도**: 높음 (핵심 기능)

---

## 🔍 세부 기능별 비교

### 1. 홈 화면 위젯 (goal_achievement_widget.dart)

| 요구사항 | 구현 상태 | 구현 위치 | 비고 |
|---------|---------|----------|------|
| 제목: "목표 달성하기" | ✅ | Line 181 | - |
| 부제: "셰르피와 함께..." | ✅ | Line 197 | - |
| 셰르피 캐릭터 표시 | ✅ | Line 131-170 | 감정 자동 선택 |
| 목표 요약 (완료/총개수) | ✅ | Line 220-338 | 진행률 바 포함 |
| 루틴 요약 (완료율) | ✅ | Line 342-518 | 원형 진행률 + 텍스트 |
| 셰르피 분석 버튼 | ✅ | Line 522-597 | 30P 확인, 부족 시 경고 |
| 목표 화면 이동 | ✅ | Line 312 | `/goals` |
| 루틴 화면 이동 | ✅ | Line 492 | `/routines` |
| AI 분석 화면 이동 | ✅ | Line 531 | `/ai_analysis` |

**종합 평가**: **100%** 달성 ✅

---

### 2. 목표창 (goals_screen.dart + goal_provider.dart + goal_model.dart)

| 요구사항 | 구현 상태 | 구현 위치 | 비고 |
|---------|---------|----------|------|
| 사용자 정보 버튼 | ⚠️ | `goals_screen.dart:34-40` | 모달 있으나 세부 필드 없음 |
| 이전 목표 버튼 | ✅ | `goals_screen.dart:42-48` | - |
| 현재 목표 리스트 | ✅ | `goals_screen.dart:105-115` | 날짜순 정렬 |
| 목표 카드 | ✅ | `goal_card_widget.dart` | 클릭 → 상세/수정/삭제 |
| 목표 추가 모달 | ✅ | `goal_modal_widget.dart` | 카테고리, 날짜, 이름, 목표값 |
| 카테고리 (4종) | ✅ | `goal_model.dart:52-64` | 운동, 학습, 대회, 자격증 |
| 목표 완료 처리 | ✅ | `goal_provider.dart:116-144` | 달성/미달성, 상세, 이유 |
| 이전 목표 저장 | ✅ | `goal_provider.dart:61-71` | SharedPreferences |
| 이전 목표 상세 표시 | ❌ | - | 달성률 % 시각화 없음 |
| 사용자 정보 세부 필드 | ❌ | - | 키, 몸무게, 생년 등 없음 |

**종합 평가**: **90%** 달성 ✅ (세부 필드 미구현)

---

### 3. 루틴창 (routines_screen.dart + routine_provider.dart + routine_model.dart)

| 요구사항 | 구현 상태 | 구현 위치 | 비고 |
|---------|---------|----------|------|
| 사용자 정보 버튼 | ⚠️ | `routines_screen.dart:35-40` | 목표창과 동일 모달 |
| 이전 루틴 버튼 | ✅ | `routines_screen.dart:43-50` | - |
| 오늘 완료율 헤더 | ✅ | `routines_screen.dart:85-138` | % + 원형 그래프 |
| 체크리스트 | ✅ | `routines_screen.dart:175-185` | - |
| 루틴 체크/언체크 | ✅ | `routine_provider.dart:129-174` | - |
| 루틴 추가 모달 | ✅ | `routine_modal_widget.dart` | 카테고리, 주기, 시간, 기간 |
| 카테고리 (5종) | ✅ | `routine_model.dart:131-145` | 운동, 문화, 학습, 건강, 기타 |
| 주기별 필터링 | ✅ | `routine_model.dart:64-96` | `shouldShowToday()` |
| 완료율 계산 | ✅ | `routine_provider.dart:196-237` | - |
| 루틴 정렬 | ⚠️ | `routine_provider.dart:240-256` | 체크 여부 → 주기 → 시간 (복잡) |
| 게임적 요소 위젯 | ❌ | - | 미구현 |
| 이전 루틴 달성률 시각화 | ⚠️ | - | 프로그레스바 없음 |
| 완주 여부 표시 | ✅ | `routine_model.dart:49` | `isCompleted` |

**종합 평가**: **85%** 달성 ✅ (게임 요소, 시각화 미흡)

---

### 4. AI 분석창 (ai_analysis_screen.dart + achievement_analysis_model.dart)

| 요구사항 | 구현 상태 | 구현 위치 | 비고 |
|---------|---------|----------|------|
| 카테고리 선택창 | ✅ | `ai_analysis_screen.dart:45-89` | 목표 카테고리만 표시 |
| 30P 소모 확인 | ✅ | `ai_analysis_screen.dart:428-458` | 다이얼로그 |
| 포인트 차감 | ✅ | `ai_analysis_screen.dart:463-467` | GlobalPointProvider |
| 로딩 상태 | ✅ | `ai_analysis_screen.dart:265-302` | 셰르피 아이콘 + 메시지 |
| 데모 분석 결과 | ✅ | `ai_analysis_screen.dart:305-410` | 카테고리별 |
| 실제 AI 연결 | ❌ | - | 데모만 구현 |
| 목표/루틴 데이터 활용 | ❌ | - | 하드코딩 텍스트만 |
| 로딩 위젯 디자인 참조 | ❌ | - | 요구사항 참조 안함 |

**종합 평가**: **75%** 달성 ⚠️ (AI 연결 미구현)

---

## ⚠️ 개선 필요 사항

### 1. 사용자 정보 모달 세부 필드 추가

**현재 문제**:
- `user_info_modal_widget.dart`가 존재하지만 세부 필드가 없음
- `GlobalUser` 모델에 필요한 필드 없음

**필요 필드**:
```dart
// lib/shared/models/global_user_model.dart 에 추가 필요
int? height;           // 키 (cm)
double? weight;        // 몸무게 (kg)
double? bodyFatRate;   // 체지방률 (%)
double? muscleMass;    // 골격근량 (kg)
int? birthYear;        // 생년
List<String> academicAchievements;  // 학업 성적
List<String> competitionAwards;     // 대회 수상경력
List<String> certifications;        // 자격증
List<String> languageScores;        // 어학성적
```

**개선 방안**:
1. GlobalUser 모델 확장
2. UserInfoModalWidget에서 입력 폼 추가
3. SharedPreferences 저장/로드

---

### 2. 이전 목표/루틴 화면 시각화 개선

**현재 문제**:
- 이전 목표의 달성률 % 시각화 없음
- 이전 루틴의 프로그레스바 없음
- 성공/실패 이유가 리스트 카드에 표시 안됨

**개선 방안**:

#### 이전 목표 카드 UI:
```dart
// previous_goals_widget.dart 개선
Container(
  child: Column(
    children: [
      Row(
        children: [
          Icon(goal.isAchieved ? Icons.check_circle : Icons.cancel),
          Text(goal.isAchieved ? '달성' : '미달성'),
          Spacer(),
          Text('${(goal.achievementRate * 100).toInt()}%'), // % 표시
        ],
      ),
      LinearProgressIndicator(value: goal.achievementRate), // 진행률바
      if (goal.achievementDetails != null)
        Text('상세: ${goal.achievementDetails}'),
      if (goal.reasonForResult != null)
        Text('이유: ${goal.reasonForResult}'),
    ],
  ),
)
```

#### 이전 루틴 카드 UI:
```dart
// previous_routines_widget.dart 개선
Container(
  child: Column(
    children: [
      Row(
        children: [
          Icon(routine.isCompleted ? Icons.emoji_events : Icons.pending),
          Text(routine.isCompleted ? '완주' : '미완주'),
          Spacer(),
          Text('${(routine.completionRate * 100).toInt()}%'),
        ],
      ),
      LinearProgressIndicator(value: routine.completionRate),
      // 완주한 루틴은 특별 효과 (그림자, 색상 등)
      if (routine.isCompleted)
        Container(
          decoration: BoxDecoration(
            boxShadow: ModernColors.premiumShadow(...),
          ),
        ),
    ],
  ),
)
```

---

### 3. 루틴 게임적 요소 추가

**요구사항**:
> "셰르파 특색에 맞게 게임적인 요소처럼 보이게끔 하는 위젯 하나 추가"

**제안 아이디어**:

#### Option 1: 루틴 연속 달성 스트릭 (Streak) 위젯
```dart
// routines_screen.dart에 추가
_buildStreakWidget() {
  final streak = _calculateStreak(); // 연속 달성 일수
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(...),
    ),
    child: Row(
      children: [
        Icon(Icons.local_fire_department, size: 40, color: Colors.orange),
        SizedBox(width: 12),
        Column(
          children: [
            Text('$streak일 연속 달성!', style: ...),
            Text('계속해서 루틴을 지켜보세요!', style: ...),
          ],
        ),
      ],
    ),
  );
}
```

#### Option 2: 루틴 레벨 시스템
```dart
// 완료한 루틴 개수에 따라 레벨업
_buildRoutineLevelWidget() {
  final level = totalCompletedRoutines ~/ 10; // 10개당 레벨 1
  return Container(
    child: Row(
      children: [
        Icon(Icons.trending_up),
        Text('루틴 마스터 Lv.$level'),
        LinearProgressIndicator(
          value: (totalCompletedRoutines % 10) / 10,
        ),
      ],
    ),
  );
}
```

#### Option 3: 루틴 달성 배지
```dart
// 특정 조건 달성 시 배지 표시
_buildRoutineBadges() {
  List<Badge> earnedBadges = [
    if (streak >= 7) Badge('주간 챌린저'),
    if (streak >= 30) Badge('한 달 마라토너'),
    if (completionRate >= 0.9) Badge('완벽주의자'),
  ];
  return Wrap(
    children: earnedBadges.map((badge) => Chip(label: Text(badge.name))).toList(),
  );
}
```

---

### 4. AI 분석 실제 연결

**현재 문제**:
- `achievement_analysis_model.dart`에 하드코딩된 데모 텍스트만 표시
- 실제 목표/루틴 데이터를 전혀 활용하지 않음
- AI API 연결 없음

**개선 방안**:

#### Step 1: AI 프롬프트 생성기 추가
```dart
// lib/features/goals/services/ai_prompt_builder.dart 생성
class AiPromptBuilder {
  static String buildGoalAnalysisPrompt({
    required String category,
    required List<GoalModel> goals,
    required List<RoutineModel> routines,
    required GlobalUser user,
  }) {
    return '''
사용자 정보:
- 이름: ${user.name}
- 레벨: ${user.level}
${user.height != null ? '- 키: ${user.height}cm' : ''}
${user.weight != null ? '- 몸무게: ${user.weight}kg' : ''}

현재 목표 ($category 카테고리):
${goals.where((g) => g.category == category).map((g) => '- ${g.name} (목표: ${g.targetValue}, 날짜: ${g.date})').join('\n')}

이전 목표 결과:
${_getPreviousGoalsResult(category)}

관련 루틴:
${routines.where((r) => _isRelatedToGoal(r, category)).map((r) => '- ${r.name} (주기: ${r.frequency}, 완료율: ${(r.completionRate * 100).toInt()}%)').join('\n')}

위 정보를 바탕으로 다음 항목을 분석해주세요:
1. 강점 (현재 잘 하고 있는 부분)
2. 개선 필요 (부족한 부분)
3. 추천 전략 (3가지 이상)
''';
  }
}
```

#### Step 2: OpenAI 서비스 연결
```dart
// lib/features/goals/services/goal_ai_service.dart 생성
import 'package:sherpa_app/core/ai/services/openai_service.dart';

class GoalAiService {
  final OpenAIService _openAI = OpenAIService();

  Future<String> analyzeGoals({
    required String category,
    required List<GoalModel> goals,
    required List<RoutineModel> routines,
    required GlobalUser user,
  }) async {
    final prompt = AiPromptBuilder.buildGoalAnalysisPrompt(
      category: category,
      goals: goals,
      routines: routines,
      user: user,
    );

    try {
      final response = await _openAI.generateText(
        prompt: prompt,
        systemMessage: '당신은 목표 달성을 돕는 전문 코치입니다.',
      );
      return response;
    } catch (e) {
      // 실패 시 기본 분석 반환
      return AchievementAnalysisHelper._getDemoContent(category);
    }
  }
}
```

#### Step 3: ai_analysis_screen.dart 수정
```dart
// _performAnalysis() 메서드 수정
Future<void> _performAnalysis() async {
  // 포인트 차감
  ref.read(globalPointProvider.notifier).addPoints(-30, ...);

  setState(() => _isLoading = true);

  // 실제 데이터 수집
  final goals = ref.read(goalProvider);
  final routines = ref.read(routineProvider);
  final user = ref.read(globalUserProvider);

  // AI 분석 요청
  final aiService = GoalAiService();
  final analysisContent = await aiService.analyzeGoals(
    category: _selectedCategory!,
    goals: goals,
    routines: routines,
    user: user,
  );

  // 결과 표시
  if (mounted) {
    setState(() {
      _analysisResult = AchievementAnalysisModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory!,
        analysisContent: analysisContent, // AI 생성 텍스트
        analyzedAt: DateTime.now(),
        relatedGoalIds: goals.where((g) => g.category == _selectedCategory).map((g) => g.id).toList(),
        relatedRoutineIds: routines.map((r) => r.id).toList(),
      );
      _isLoading = false;
    });
  }
}
```

---

### 5. 루틴 정렬 로직 개선

**현재 문제**:
- `routine_provider.dart:240-256`의 `_compareRoutines` 함수가 복잡함
- `timePriority` 계산이 숫자 범위가 넓어서 이해하기 어려움

**현재 코드**:
```dart
int get timePriority {
  if (timePreference == '눈 뜨자마자') return 0;
  if (timePreference == '시간 설정') {
    if (specificTime != null) {
      return 1000 + specificTime!.hour * 60 + specificTime!.minute;
    }
    return 1000;
  }
  if (timePreference == '아무때나') return 10000;
  if (timePreference == '자기 전') return 20000;
  return 15000; // 기본값
}
```

**개선 방안**:
```dart
// routine_model.dart 수정
int get timePriority {
  switch (timePreference) {
    case '눈 뜨자마자':
      return 0;
    case '시간 설정':
      if (specificTime != null) {
        // 시간대별로 0~1439 범위 (24*60-1)
        return 1 + specificTime!.hour * 60 + specificTime!.minute;
      }
      return 1; // 시간 미설정
    case '아무때나':
      return 1440; // 24시간 후
    case '자기 전':
      return 1441; // 가장 마지막
    default:
      return 1442; // 알 수 없음
  }
}
```

**요구사항 재확인**:
> "시간 설정했다면 시간대별로 정렬: 눈 뜨자마자 / 시간 설정 / 아무때나 / 자기 전 순서"

**정렬 우선순위 명확화**:
1. 체크 여부 (체크 안 된 것이 위로)
2. 주기 (매일 → 주N회 → 매주[요일] → 월N회)
3. 시간대 (눈 뜨자마자 → 시간 설정(시간순) → 아무때나 → 자기 전)

**현재 구현 검증**: ✅ 로직은 정확하나 가독성 개선 필요

---

## 🚀 개선 방안 제안

### Phase 1: 긴급 (1주 이내)

#### 1.1. 이전 목표/루틴 시각화 개선 ⭐⭐⭐
- **파일**: `previous_goals_widget.dart`, `previous_routines_widget.dart`
- **작업**:
  - 달성률 % 표시 추가
  - 프로그레스바 추가
  - 성공/실패 이유 카드에 표시
  - 완주 루틴 특별 효과 적용
- **난이도**: 하
- **예상 시간**: 2-3시간

#### 1.2. 루틴 정렬 로직 리팩토링 ⭐⭐
- **파일**: `routine_model.dart`
- **작업**:
  - `timePriority` 계산식 개선 (0~1442 범위로 단순화)
  - 주석 추가
- **난이도**: 하
- **예상 시간**: 1시간

---

### Phase 2: 중요 (2주 이내)

#### 2.1. 사용자 정보 모달 세부 필드 추가 ⭐⭐⭐
- **파일**: `global_user_model.dart`, `user_info_modal_widget.dart`, `global_user_provider.dart`
- **작업**:
  1. GlobalUser 모델 확장 (height, weight, bodyFatRate, muscleMass, birthYear, 성적/수상/자격증/어학)
  2. UserInfoModalWidget에서 입력 폼 추가
  3. SharedPreferences 저장/로드
  4. 입력 검증 (숫자 범위, nullable 처리)
- **난이도**: 중
- **예상 시간**: 4-6시간

#### 2.2. 루틴 게임적 요소 추가 ⭐⭐
- **파일**: `routines_screen.dart`, 새 위젯 생성
- **작업**:
  - Option 1: 스트릭(Streak) 위젯 구현
  - 연속 달성 일수 계산 로직
  - 불꽃 아이콘 + 메시지 표시
  - 애니메이션 추가 (optional)
- **난이도**: 중
- **예상 시간**: 3-4시간

---

### Phase 3: 핵심 (3주 이내)

#### 3.1. AI 분석 실제 연결 ⭐⭐⭐⭐⭐
- **파일**:
  - `lib/features/goals/services/ai_prompt_builder.dart` (신규)
  - `lib/features/goals/services/goal_ai_service.dart` (신규)
  - `ai_analysis_screen.dart` (수정)
- **작업**:
  1. AiPromptBuilder 클래스 생성
  2. GoalAiService 클래스 생성 (OpenAI 연동)
  3. ai_analysis_screen.dart의 _performAnalysis() 수정
  4. 실제 목표/루틴/사용자 데이터 수집
  5. AI 프롬프트 생성 및 API 요청
  6. 에러 처리 (fallback to demo)
  7. 테스트 (다양한 카테고리, 데이터 조합)
- **난이도**: 고
- **예상 시간**: 8-12시간
- **의존성**: OpenAI API 키 필요

#### 3.2. AI 분석 결과 캐싱 ⭐⭐
- **파일**: `lib/features/goals/providers/analysis_cache_provider.dart` (신규)
- **작업**:
  - 분석 결과 SharedPreferences 저장
  - 동일 카테고리 재분석 시 캐시 활용
  - TTL 설정 (24시간)
- **난이도**: 중
- **예상 시간**: 2-3시간

---

### Phase 4: 최적화 (4주 이내)

#### 4.1. 목표/루틴 통계 대시보드 ⭐⭐
- **파일**: `lib/features/goals/presentation/screens/statistics_screen.dart` (신규)
- **작업**:
  - 월별 목표 달성률 차트
  - 카테고리별 루틴 완료율
  - 스트릭 히스토리
- **난이도**: 중~고
- **예상 시간**: 6-8시간

#### 4.2. 목표/루틴 알림 기능 ⭐⭐⭐
- **파일**: `lib/features/goals/services/goal_notification_service.dart` (신규)
- **작업**:
  - 목표 기한 임박 알림 (D-7, D-3, D-1)
  - 루틴 시간 알림 (시간 설정한 루틴)
  - flutter_local_notifications 연동
- **난이도**: 중~고
- **예상 시간**: 5-7시간

---

## 📅 우선순위별 개발 로드맵

### 🔴 High Priority (즉시 시작)

| 우선순위 | 항목 | 난이도 | 예상 시간 | 영향도 |
|---------|------|--------|----------|--------|
| 1 | AI 분석 실제 연결 | 고 | 8-12시간 | 매우 높음 (핵심 기능) |
| 2 | 사용자 정보 세부 필드 | 중 | 4-6시간 | 높음 (AI 분석 정확도) |
| 3 | 이전 목표/루틴 시각화 | 하 | 2-3시간 | 중간 (사용자 피드백) |

---

### 🟡 Medium Priority (2주 내)

| 우선순위 | 항목 | 난이도 | 예상 시간 | 영향도 |
|---------|------|--------|----------|--------|
| 4 | 루틴 게임적 요소 | 중 | 3-4시간 | 중간 (UX 향상) |
| 5 | AI 분석 캐싱 | 중 | 2-3시간 | 중간 (성능) |
| 6 | 루틴 정렬 로직 개선 | 하 | 1시간 | 낮음 (코드 품질) |

---

### 🟢 Low Priority (3주 이후)

| 우선순위 | 항목 | 난이도 | 예상 시간 | 영향도 |
|---------|------|--------|----------|--------|
| 7 | 통계 대시보드 | 중~고 | 6-8시간 | 낮음 (부가 기능) |
| 8 | 알림 기능 | 중~고 | 5-7시간 | 낮음 (부가 기능) |

---

## 📈 예상 개발 일정 (총 4주)

### Week 1
- ✅ Phase 1 완료 (시각화 + 정렬 로직)
- 🚧 Phase 3-1 시작 (AI 연결 준비)

### Week 2
- 🚧 Phase 3-1 완료 (AI 연결)
- ✅ Phase 2-1 완료 (사용자 정보)

### Week 3
- ✅ Phase 2-2 완료 (게임 요소)
- ✅ Phase 3-2 완료 (AI 캐싱)
- 🧪 테스트 및 버그 수정

### Week 4
- 🚧 Phase 4 (Optional)
- 📝 문서 업데이트
- 🚀 배포 준비

---

## 🎯 최종 권장 사항

### 즉시 시작해야 할 작업 (우선순위 순)

1. **AI 분석 실제 연결** ⭐⭐⭐⭐⭐
   - 핵심 기능이므로 최우선
   - OpenAI API 키 준비 필요
   - Phase 3-1 참조

2. **사용자 정보 세부 필드 추가** ⭐⭐⭐⭐
   - AI 분석 정확도 향상에 필수
   - Phase 2-1 참조

3. **이전 목표/루틴 시각화 개선** ⭐⭐⭐
   - 사용자 피드백 루프 완성
   - Phase 1-1 참조

### 이후 고려할 작업

4. 루틴 게임적 요소 (UX 향상)
5. AI 분석 캐싱 (성능 최적화)
6. 통계 대시보드 (추가 가치 제공)
7. 알림 기능 (사용자 참여 증대)

---

## 📊 구현 완성도 요약

| 영역 | 달성률 | 상태 |
|------|--------|------|
| 홈 위젯 | 100% | ✅ 완료 |
| 목표 화면 | 90% | ✅ 대부분 완료 |
| 루틴 화면 | 85% | ✅ 대부분 완료 |
| AI 분석 화면 | 75% | ⚠️ 데모만 구현 |
| **전체** | **85%** | ✅ 핵심 기능 완료 |

**결론**: 목표 달성 기능의 기본 구조와 핵심 기능은 **85% 완성**되었으며, 나머지 15%는 AI 연결, 세부 시각화, 부가 기능입니다. 우선순위에 따라 Phase 1~3을 순차적으로 진행하면 **완성도 100%** 달성 가능합니다.

---

**문서 작성자**: Claude Code
**최종 업데이트**: 2025-11-09
**버전**: 1.0.0
