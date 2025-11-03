# 📋 계획하기 시스템 아키텍처 문서 (Planning System Architecture)

> **Sherpa App Planning System Technical Documentation**
>
> 산 등반 메타포를 활용한 목표 관리 시스템의 완전한 기술 문서

---

## Document Metadata

- **Version**: 1.0.0
- **Last Updated**: 2025-11-03
- **Status**: Complete Analysis
- **Author**: Documentation Specialist
- **Related Systems**: User Data, Points, Sherpi AI
- **Feature Location**: `lib/features/sherpi/planning/`

---

## Table of Contents

1. [시스템 개요](#1-시스템-개요-system-overview)
2. [아키텍처 설계](#2-아키텍처-설계-architecture-design)
3. [파일 구조 및 역할](#3-파일-구조-및-역할-file-structure)
4. [데이터 모델](#4-데이터-모델-data-models)
5. [핵심 컴포넌트](#5-핵심-컴포넌트-core-components)
6. [데이터 플로우](#6-데이터-플로우-data-flow)
7. [Provider 통합](#7-provider-통합-provider-integration)
8. [UI/UX 사양](#8-uiux-사양-uiux-specifications)
9. [중요 주의사항](#9-중요-주의사항-important-notes)
10. [확장 포인트](#10-확장-포인트-extension-points)

---

## 1. 시스템 개요 (System Overview)

### 1.1 핵심 컨셉

**산 등반 메타포 (Mountain Climbing Metaphor)**
```
사용자의 목표 = 정복해야 할 산봉우리
진행 상황 = 등반 경로
체크포인트 완료 = 중간 지점 도달
목표 달성 = 정상 정복
```

### 1.2 주요 기능

| 기능 | 설명 | 사용자 가치 |
|------|------|------------|
| **빠른 목표 생성** | 30초 내 목표 설정 | 진입 장벽 최소화 |
| **시각적 진행 추적** | 산 경로 비주얼 | 직관적 진행 상황 파악 |
| **일일 체크포인트** | 오늘 할 일 관리 | 실천 가능한 단계 제공 |
| **AI 힌트** | 활동 패턴 기반 제안 | 개인화된 목표 추천 |
| **카테고리 시스템** | 4개 분야 분류 | 균형잡힌 성장 지원 |
| **보상 시스템** | 포인트 + 경험치 | 지속적 동기 부여 |

### 1.3 시스템 범위

**포함 사항**:
- ✅ 목표 CRUD (생성, 조회, 수정, 삭제)
- ✅ 진행률 자동 계산
- ✅ 일일 체크포인트 생성
- ✅ 카테고리별 분류 (건강, 학습, 습관, 소셜)
- ✅ Sherpi AI 연동
- ✅ 포인트/경험치 보상

**제외 사항**:
- ❌ 목표 공유 기능 (향후 구현)
- ❌ 목표 상세 편집 (향후 구현)
- ❌ 되돌리기 기능 (향후 구현)
- ❌ 알림 시스템 (향후 구현)

---

## 2. 아키텍처 설계 (Architecture Design)

### 2.1 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                  SimplePlannerScreen                    │
│  (Main UI Container - 목표 관리 메인 화면)                │
└──────────────┬──────────────────────────┬───────────────┘
               │                          │
       ┌───────▼────────┐        ┌────────▼────────┐
       │ MountainPath   │        │  Checkpoints    │
       │    Widget      │        │     Section     │
       │ (산 경로 비주얼)  │        │ (오늘의 체크포인트) │
       └───────┬────────┘        └────────┬────────┘
               │                          │
               │                  ┌───────▼─────────┐
               │                  │ CheckpointTile  │
               │                  │     Widget      │
               │                  └─────────────────┘
               │
       ┌───────▼────────┐
       │ QuickGoalInput │
       │     Widget     │
       │ (빠른 목표 입력)  │
       └───────┬────────┘
               │
       ┌───────▼────────────────────────────────┐
       │         GlobalUserProvider             │
       │  (상태 관리 - 목표 데이터 저장/조회)         │
       └───────┬────────────────────────────────┘
               │
       ┌───────▼────────────────────────────────┐
       │      SharedPreferences (JSON)          │
       │  (영구 저장소 - 목표 데이터 영속화)          │
       └────────────────────────────────────────┘
```

### 2.2 컴포넌트 계층 구조

```
SimplePlannerScreen (Root)
├── SherpaCleanAppBar (헤더)
│   └── Progress Badge (전체 진행률 표시)
├── MountainPathWidget (산 경로 비주얼)
│   ├── CustomPaint (MountainPathPainter)
│   │   ├── Background Mountains (배경 산 실루엣)
│   │   ├── Path Line (등반 경로 선)
│   │   └── Base Camp (시작점)
│   ├── Climber Position (현재 위치 - Sherpi)
│   └── Peak Markers (목표 산봉우리들)
│       └── Goal Cards (목표 정보 카드)
├── Checkpoints Section (체크포인트 영역)
│   ├── Header (제목 + 완료 카운트)
│   └── CheckpointTileWidget List (체크포인트 리스트)
│       ├── Checkbox (완료 상태)
│       ├── Title (체크포인트 제목)
│       ├── Mountain Icon (카테고리 아이콘)
│       └── Status Badge (완료/오늘)
└── FloatingActionButton (목표 추가 버튼)
    └── QuickGoalInputWidget (모달)
        ├── Title Input (목표 제목 입력)
        ├── AI Hint (스마트 힌트)
        ├── Category Chips (카테고리 선택)
        ├── Duration Chips (기간 선택)
        └── Create Button (생성 버튼)
```

### 2.3 데이터 흐름 다이어그램

```
[사용자 입력]
     │
     ▼
[QuickGoalInputWidget]
     │ (목표 데이터 수집)
     ▼
[SimplePlannerScreen._createGoal()]
     │ (데이터 변환 + 검증)
     ▼
[GlobalUserProvider.saveGoals()]
     │ (상태 업데이트 + 저장)
     ├─► [SharedPreferences] (영구 저장)
     ├─► [GlobalPointProvider] (포인트 지급)
     └─► [GlobalSherpiProvider] (AI 메시지)
     │
     ▼
[UI 자동 갱신] (Consumer 감지)
     │
     ▼
[MountainPathWidget + Checkpoints 재렌더링]
```

---

## 3. 파일 구조 및 역할 (File Structure)

### 3.1 디렉토리 구조

```
lib/features/sherpi/planning/
├── presentation/
│   ├── screens/
│   │   └── simple_planner_screen.dart       # 메인 화면
│   └── widgets/
│       ├── mountain_path_widget.dart        # 산 경로 비주얼
│       ├── quick_goal_input_widget.dart     # 목표 입력 폼
│       └── checkpoint_tile_widget.dart      # 체크포인트 아이템
```

### 3.2 파일별 상세 역할

| 파일 | 라인 수 | 주요 역할 | 핵심 기능 |
|------|---------|----------|----------|
| `simple_planner_screen.dart` | 829 | 메인 컨테이너 | 전체 UI 조합, 이벤트 핸들링, 상태 관리 |
| `mountain_path_widget.dart` | 478 | 산 경로 비주얼 | CustomPainter로 등반 경로 그리기, 목표 마커 배치 |
| `quick_goal_input_widget.dart` | 440 | 목표 입력 폼 | 빠른 목표 생성, AI 힌트, 카테고리/기간 선택 |
| `checkpoint_tile_widget.dart` | 265 | 체크포인트 아이템 | 개별 체크포인트 UI, 완료 토글, 애니메이션 |

### 3.3 외부 의존성

**Models** (데이터 모델):
- `lib/shared/models/global_user_model.dart`
  - `UserPlanningData` (line 1688-1773)
  - `UserGoal` (line 1775-1882)

**Providers** (상태 관리):
- `lib/shared/providers/level_1_user_data/global_user_provider.dart`
  - `saveGoals()` (line 2346)
  - `updateGoalProgress()` (line 2399)
  - `deleteGoal()` (line 2470)
- `lib/shared/providers/level_1_user_data/global_point_provider.dart`
  - `earnPoints()` (포인트 지급)
- `lib/shared/providers/level_3_ai/global_sherpi_provider.dart`
  - `showInstantMessage()` (AI 메시지)

**Utilities**:
- `lib/shared/utils/haptic_feedback_manager.dart` (햅틱 피드백)
- `lib/shared/widgets/sherpa_clean_app_bar.dart` (공통 앱바)

---

## 4. 데이터 모델 (Data Models)

### 4.1 UserPlanningData

**위치**: `lib/shared/models/global_user_model.dart` (line 1688-1773)

**목적**: 사용자의 전체 계획 데이터를 관리하는 최상위 컨테이너

**구조**:
```dart
class UserPlanningData {
  final List<UserGoal> goals;              // 활성 목표 리스트
  final List<UserGoal> completedGoals;     // 완료된 목표 리스트
  final DateTime? lastPlanningDate;        // 마지막 계획 수정일
  final int totalGoalsCreated;             // 총 생성된 목표 수
  final int totalGoalsCompleted;           // 총 완료된 목표 수
  final Map<String, int> categoryStats;    // 카테고리별 통계
}
```

**주요 계산 필드**:
```dart
// 활성 목표 수
int get activeGoalsCount => goals.where((g) => g.isActive).length;

// 전체 달성률 (%)
double get overallCompletionRate {
  if (totalGoalsCreated == 0) return 0.0;
  return (totalGoalsCompleted / totalGoalsCreated) * 100;
}
```

**JSON 저장 구조**:
```json
{
  "goals": [
    { "id": "...", "title": "...", ... },
    { "id": "...", "title": "...", ... }
  ],
  "completedGoals": [...],
  "lastPlanningDate": "2025-11-03T10:30:00.000Z",
  "totalGoalsCreated": 15,
  "totalGoalsCompleted": 8,
  "categoryStats": {
    "health": 5,
    "study": 3,
    "habit": 4,
    "social": 3
  }
}
```

### 4.2 UserGoal

**위치**: `lib/shared/models/global_user_model.dart` (line 1775-1882)

**목적**: 개별 목표의 상세 정보 관리

**구조**:
```dart
class UserGoal {
  final String id;                         // 고유 ID (timestamp 기반)
  final String title;                      // 목표 제목
  final String? description;               // 목표 설명 (선택)
  final String category;                   // 카테고리 (health/study/habit/social)
  final int duration;                      // 목표 기간 (일 단위)
  final String? schedule;                  // 일정 정보 (선택)
  final DateTime createdAt;                // 생성 시각
  final DateTime? completedAt;             // 완료 시각 (선택)
  final double progress;                   // 진행률 (0.0 ~ 100.0)
  final bool isActive;                     // 활성 상태
  final Map<String, dynamic>? metadata;    // 추가 메타데이터
}
```

**주요 계산 필드**:
```dart
// 남은 일수 계산
int get daysRemaining {
  if (!isActive) return 0;
  final elapsed = DateTime.now().difference(createdAt).inDays;
  final remaining = duration - elapsed;
  return remaining > 0 ? remaining : 0;
}

// 시간 기반 진행률 (0.0 ~ 100.0)
double get timeBasedProgress {
  if (!isActive) return 0.0;
  final elapsed = DateTime.now().difference(createdAt).inDays;
  if (elapsed >= duration) return 100.0;
  return (elapsed / duration) * 100;
}
```

**JSON 저장 구조**:
```json
{
  "id": "1730606400000",
  "title": "매일 30분 운동하기",
  "description": "",
  "category": "health",
  "duration": 7,
  "schedule": null,
  "createdAt": "2025-11-03T00:00:00.000Z",
  "completedAt": null,
  "progress": 42.5,
  "isActive": true,
  "metadata": null
}
```

### 4.3 카테고리 시스템

**지원 카테고리**: 4개

| 카테고리 | 키 | 산 이름 | 아이콘 | 색상 | 기본 포인트 |
|---------|-------|---------|--------|------|------------|
| 건강 | `health` | 건강봉 🏔️ | `Icons.favorite` | `Colors.red` | 50 |
| 학습 | `study` | 지식봉 ⛰️ | `Icons.book` | `Colors.blue` | 30 |
| 습관 | `habit` | 성찰봉 🗻 | `Icons.repeat` | `Colors.green` | 20 |
| 소셜 | `social` | 우정봉 🏔️ | `Icons.people` | `Colors.orange` | 40 |

**카테고리별 Sherpi 이미지 매핑**:
```dart
// mountain_path_widget.dart (line 319-337)
String _getCategorySherpiImage(String category, bool isCompleted) {
  if (isCompleted) {
    return 'assets/images/sherpi/sherpi_special.png';  // 완료 시
  }

  switch (category) {
    case 'health':  return 'assets/images/sherpi/sherpi_cheering.png';
    case 'study':   return 'assets/images/sherpi/sherpi_thinking.png';
    case 'habit':   return 'assets/images/sherpi/sherpi_guiding.png';
    case 'social':  return 'assets/images/sherpi/sherpi_happy.png';
    default:        return 'assets/images/sherpi/sherpi_default.png';
  }
}
```

---

## 5. 핵심 컴포넌트 (Core Components)

### 5.1 SimplePlannerScreen

**위치**: `lib/features/sherpi/planning/presentation/screens/simple_planner_screen.dart`

**책임**:
- 전체 UI 레이아웃 조합
- 사용자 이벤트 핸들링
- Provider와의 데이터 동기화
- 체크포인트 상태 관리

**주요 메서드**:

#### (1) 초기화 및 라이프사이클
```dart
// line 43-54: 초기화
void initState() {
  _animationController = AnimationController(...);

  // 진입 시 셰르피 환영 메시지
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _showWelcomeMessage();
  });
}
```

#### (2) 목표 관련 메서드

**목표 생성** (line 698-734):
```dart
void _createGoal(Map<String, dynamic> goalData) {
  // 1. 목표 데이터 준비
  final goalMap = {
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'title': goalData['title'],
    'description': goalData['description'] ?? '',
    'category': goalData['category'],
    'duration': goalData['duration'],
    'createdAt': DateTime.now(),
    'progress': 0.0,
    'isActive': true,
  };

  // 2. GlobalUserProvider에 저장
  ref.read(globalUserProvider.notifier).saveGoals([goalMap]);

  // 3. 보상 지급 (10 포인트)
  ref.read(globalPointProvider.notifier).earnPoints(
    10, PointSource.goalCompletion, '새로운 목표 설정',
  );

  // 4. Sherpi 축하 메시지
  ref.read(sherpiProvider.notifier).showInstantMessage(
    context: SherpiContext.general,
    customDialogue: '좋아요! "${goalData['title']}" 목표를 향해 함께 올라가봐요! 🚀',
    emotion: SherpiEmotion.cheering,
  );
}
```

**목표 삭제** (line 392-405):
```dart
onDismissed: (direction) {
  // GlobalUserProvider에서 삭제
  ref.read(globalUserProvider.notifier).deleteGoal(goal.id);

  // 스낵바로 피드백
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${goal.title} 목표가 삭제되었어요'),
      action: SnackBarAction(
        label: '되돌리기',
        onPressed: () { /* 향후 구현 */ },
      ),
    ),
  );
}
```

#### (3) 체크포인트 관련 메서드

**오늘의 체크포인트 생성** (line 603-630):
```dart
List<Map<String, dynamic>> _getTodayCheckpoints(GlobalUser user) {
  final checkpoints = <Map<String, dynamic>>[];
  final now = DateTime.now();

  // 활성 목표에서 오늘의 체크포인트 추출
  if (user.planningData != null) {
    for (final goal in user.planningData!.goals) {
      if (goal.isActive) {
        final checkpointId = '${goal.id}_${now.day}';  // 고유 ID
        checkpoints.add({
          'id': checkpointId,
          'goalId': goal.id,
          'title': goal.title,
          'mountain': _getCategoryMountain(goal.category),
          'points': _getCategoryPoints(goal.category),
          'completed': _checkpointCompletions[checkpointId] ?? false,
          'category': goal.category,
        });
      }
    }
  }

  return checkpoints;
}
```

**체크포인트 완료 토글** (line 736-795):
```dart
void _toggleCheckpoint(Map<String, dynamic> checkpoint) {
  HapticFeedbackManager.lightImpact();  // 햅틱 피드백

  final checkpointId = checkpoint['id'] as String;
  final newCompletedState = !checkpoint['completed'];

  setState(() {
    checkpoint['completed'] = newCompletedState;
    _checkpointCompletions[checkpointId] = newCompletedState;
  });

  if (newCompletedState) {
    // 1. 포인트 지급 (카테고리별 차등)
    ref.read(globalPointProvider.notifier).earnPoints(
      checkpoint['points'],
      PointSource.goalCompletion,
      '체크포인트 완료: ${checkpoint['title']}',
    );

    // 2. 경험치 추가 (포인트의 절반)
    ref.read(globalUserProvider.notifier)
       .addExperience(checkpoint['points'] ~/ 2);

    // 3. 목표 진행률 업데이트 (+10%)
    if (checkpoint['goalId'] != null) {
      final goal = /* 목표 찾기 */;
      if (goal != null && goal.id.isNotEmpty) {
        final newProgress = (goal.progress + 10).clamp(0.0, 100.0);
        ref.read(globalUserProvider.notifier)
           .updateGoalProgress(checkpoint['goalId'], newProgress);
      }
    }

    // 4. Sherpi 축하 메시지
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.general,
      customDialogue: '체크포인트 도달! 조금만 더 올라가면 정상이에요! ⛰️',
      emotion: SherpiEmotion.happy,
    );
  }
}
```

#### (4) 진행률 계산

**전체 진행률** (line 664-679):
```dart
double _calculateOverallProgress(List<UserGoal> goals) {
  if (goals.isEmpty) return 0;

  double totalProgress = 0;
  int activeGoals = 0;

  for (final goal in goals) {
    if (goal.isActive) {
      totalProgress += goal.progress;
      activeGoals++;
    }
  }

  return activeGoals > 0 ? totalProgress / activeGoals : 0;
}
```

### 5.2 MountainPathWidget

**위치**: `lib/features/sherpi/planning/presentation/widgets/mountain_path_widget.dart`

**책임**:
- 산 경로 비주얼 렌더링
- 목표를 산봉우리로 시각화
- 진행 상황을 등반 경로로 표현

**주요 구성 요소**:

#### (1) 배경 요소 (line 35-71)
```dart
// 구름 애니메이션
Positioned(
  top: 20, right: 30,
  child: Icon(Icons.cloud, size: 40, color: Colors.white.withAlpha(0.6))
    .animate(onPlay: (controller) => controller.repeat())
    .moveX(begin: 0, end: 20, duration: 3.seconds, curve: Curves.easeInOut)
    .then()
    .moveX(begin: 20, end: 0, duration: 3.seconds, curve: Curves.easeInOut),
)

// 태양 회전 애니메이션
Positioned(
  top: 20, left: 30,
  child: Icon(Icons.wb_sunny, size: 36, color: Colors.orange[300])
    .animate(onPlay: (controller) => controller.repeat())
    .rotate(duration: 10.seconds),
)
```

#### (2) CustomPainter (MountainPathPainter)

**산 경로 그리기** (line 346-435):
```dart
class MountainPathPainter extends CustomPainter {
  void paint(Canvas canvas, Size size) {
    // 1. 배경 산 실루엣 (line 348-364)
    final backgroundPath = Path();
    backgroundPath.moveTo(0, size.height);
    backgroundPath.lineTo(0, size.height * 0.5);
    backgroundPath.quadraticBezierTo(
      size.width * 0.25, size.height * 0.3,
      size.width * 0.5,  size.height * 0.4
    );
    // ... 산봉우리 그리기

    // 2. 점선 경로 (line 414-415)
    _drawDashedPath(canvas, path, dottedPaint);

    // 3. 완료된 부분 실선 (line 417-435)
    final averageProgress = /* 평균 진행률 계산 */;
    if (averageProgress > 0) {
      final metrics = path.computeMetrics().first;
      final extractPath =
        metrics.extractPath(0, metrics.length * averageProgress);
      canvas.drawPath(extractPath, pathPaint);
    }

    // 4. 베이스 캠프 (line 437-457)
    canvas.drawCircle(Offset(0, 8), 8, baseCampPaint);
    // "START" 텍스트 그리기
  }
}
```

**점선 그리기 알고리즘** (line 460-473):
```dart
void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
  const dashWidth = 5.0;
  const dashSpace = 5.0;
  double distance = 0.0;

  for (final metric in path.computeMetrics()) {
    while (distance < metric.length) {
      final extractPath = metric.extractPath(
        distance, distance + dashWidth
      );
      canvas.drawPath(extractPath, paint);
      distance += dashWidth + dashSpace;
    }
    distance = 0.0;
  }
}
```

#### (3) 등반자 위치 표시 (line 94-149)

**진행률 기반 위치 계산**:
```dart
Widget _buildClimberPosition() {
  // 전체 진행률 계산
  double totalProgress = 0;
  int activeGoals = 0;

  for (final goal in goals) {
    if (goal.isActive) {
      totalProgress += goal.progress;
      activeGoals++;
    }
  }

  final averageProgress = activeGoals > 0
    ? (totalProgress / activeGoals) / 100  // 0~1 범위 정규화
    : 0;

  return Positioned(
    left: 30 + (averageProgress * 200),    // X축 이동
    bottom: 40 + (averageProgress * 100),  // Y축 상승
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withAlpha(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/sherpi/sherpi_confidence.png',
          width: 40, height: 40, fit: BoxFit.contain,
        ),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .scale(  // 호흡하는 효과
      begin: Offset(1, 1),
      end: Offset(1.1, 1.1),
      duration: 1.seconds,
    )
    .then()
    .scale(
      begin: Offset(1.1, 1.1),
      end: Offset(1, 1),
      duration: 1.seconds,
    ),
  );
}
```

#### (4) 산봉우리 마커 (line 152-286)

**목표별 위치 계산**:
```dart
Widget _buildPeakMarker(BuildContext context, UserGoal goal, int index) {
  final totalGoals = goals.length;
  final screenWidth = MediaQuery.of(context).size.width - 32;

  // X 위치: 화면 너비를 균등 분할
  final double xPosition =
    30 + ((screenWidth - 60) / (totalGoals + 1)) * (index + 1);

  // Y 위치: 지그재그 패턴 (짝수/홀수 인덱스)
  final double yPosition = 60 + (index % 2 == 0 ? 0 : 30);

  return Positioned(
    left: xPosition,
    top: yPosition,
    child: GestureDetector(
      onTap: () => onGoalTap(goal.id),
      child: Column(
        children: [
          // 카테고리별 Sherpi 이미지 (line 172-196)
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isCompleted
                ? Colors.green.withAlpha(0.2)
                : _getCategoryColor(goal.category).withAlpha(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                _getCategorySherpiImage(goal.category, isCompleted),
                width: 40, height: 40, fit: BoxFit.contain,
              ),
            ),
          ),

          // 진행률 바 + D-Day (line 200-270)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [...],
            ),
            child: Column(
              children: [
                Text(goal.title.length > 8 ? '...' : goal.title),
                // 진행률 바 (line 227-245)
                Container(
                  width: 40, height: 3,
                  child: FractionallySizedBox(
                    widthFactor: progress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : ModernColors.primary,
                      ),
                    ),
                  ),
                ),
                // "42% D-5" 표시
                Row(
                  children: [
                    Text('${progress.toInt()}%'),
                    Text('D-${goal.daysRemaining}'),
                  ],
                ),
              ],
            ),
          ),

          // 산 이름 (line 273-281)
          Text(_getCategoryMountain(goal.category)),
        ],
      ),
    ),
  );
}
```

### 5.3 QuickGoalInputWidget

**위치**: `lib/features/sherpi/planning/presentation/widgets/quick_goal_input_widget.dart`

**책임**:
- 빠른 목표 입력 UI 제공
- 사용자 활동 패턴 기반 AI 힌트 표시
- 카테고리 및 기간 선택 인터페이스

**주요 기능**:

#### (1) AI 힌트 시스템 (line 44-56, 375-416)

**힌트 표시 조건 분석**:
```dart
void _checkAndShowAIHint() {
  final user = ref.read(globalUserProvider);

  // 활동 패턴 기반 힌트 표시
  if (user.dailyRecords.exerciseLogs.isEmpty &&
      _selectedCategory == 'health') {
    setState(() => _showAIHint = true);
  } else if (user.dailyRecords.readingLogs.isEmpty &&
             _selectedCategory == 'study') {
    setState(() => _showAIHint = true);
  }
}
```

**카테고리별 스마트 힌트 생성**:
```dart
String? _getAIHint(GlobalUser user) {
  switch (_selectedCategory) {
    case 'health':
      if (user.dailyRecords.exerciseLogs.isEmpty) {
        return "운동을 시작해보세요! '주 3회 30분 운동' 어떠세요?";
      } else if (user.dailyRecords.exerciseLogs.length > 10) {
        return "꾸준히 운동 중이시네요! '운동 강도 높이기' 도전!";
      }
      break;

    case 'study':
      if (user.dailyRecords.readingLogs.isEmpty) {
        return "독서 습관을 만들어보세요. '매일 10페이지 읽기' 추천!";
      } else if (user.dailyRecords.readingLogs.length > 5) {
        return "독서가 익숙해지셨네요! '월 2권 완독' 도전!";
      }
      break;

    case 'habit':
      if (user.dailyRecords.diaryLogs.isEmpty) {
        return "일기 쓰기로 하루를 정리해보세요.";
      }
      break;

    case 'social':
      if (user.dailyRecords.meetingLogs.isEmpty) {
        return "모임에 참여해 새로운 사람들을 만나보세요!";
      }
      break;
  }

  // 연속 기록 기반 힌트
  final streak = user.dailyRecords.consecutiveDays;
  if (streak > 7) {
    return "연속 $streak일째! 더 높은 목표에 도전해보세요!";
  }

  return null;  // 힌트 없음
}
```

#### (2) 카테고리 선택 UI (line 195-227)

**카테고리 칩 컴포넌트**:
```dart
Widget _buildCategoryChip(
  String label, String value, IconData icon, Color color
) {
  final isSelected = _selectedCategory == value;

  return GestureDetector(
    onTap: () {
      HapticFeedbackManager.lightImpact();
      setState(() {
        _selectedCategory = value;
        _checkAndShowAIHint();  // 카테고리 변경 시 힌트 재계산
      });
    },
    child: AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
          ? color.withAlpha(0.15)    // 선택 시 색상 배경
          : Colors.grey[100],         // 미선택 시 회색
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
            ? color.withAlpha(0.3)    // 선택 시 테두리
            : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16,
               color: isSelected ? color : Colors.grey[600]),
          SizedBox(width: 6),
          Text(label, style: GoogleFonts.notoSans(
            fontSize: 13,
            color: isSelected ? color : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )),
        ],
      ),
    ),
  );
}
```

**지원 카테고리**:
- 건강 (`health`) - 빨강 - `Icons.favorite`
- 학습 (`study`) - 파랑 - `Icons.book`
- 습관 (`habit`) - 초록 - `Icons.repeat`
- 소셜 (`social`) - 주황 - `Icons.people`

#### (3) 기간 선택 UI (line 231-262)

**기간 옵션**:
- 1주 (7일)
- 2주 (14일)
- 1달 (30일)
- 2달 (60일)
- 3달 (90일)

#### (4) 목표 생성 (line 418-431)

```dart
void _createGoal() {
  if (_controller.text.isEmpty) return;

  HapticFeedbackManager.mediumImpact();

  final goalData = {
    'title': _controller.text.trim(),
    'description': '',
    'category': _selectedCategory,
    'duration': _duration,
  };

  // 콜백으로 부모에게 전달
  widget.onGoalCreated(goalData);
}
```

### 5.4 CheckpointTileWidget

**위치**: `lib/features/sherpi/planning/presentation/widgets/checkpoint_tile_widget.dart`

**책임**:
- 개별 체크포인트 UI 렌더링
- 완료/미완료 상태 시각화
- 토글 애니메이션 처리

**주요 기능**:

#### (1) 터치 애니메이션 (line 24-43)

```dart
class _CheckpointTileWidgetState extends State<CheckpointTileWidget>
  with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,  // 5% 축소
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
}
```

#### (2) 터치 이벤트 처리 (line 53-67)

```dart
GestureDetector(
  onTapDown: (_) {
    setState(() => _isPressed = true);
    _controller.forward();  // 축소 애니메이션 시작
  },
  onTapUp: (_) {
    setState(() => _isPressed = false);
    _controller.reverse();  // 원래 크기로 복원
    HapticFeedbackManager.lightImpact();
    widget.onToggle();      // 완료 상태 토글
  },
  onTapCancel: () {
    setState(() => _isPressed = false);
    _controller.reverse();
  },
  child: AnimatedBuilder(
    animation: _scaleAnimation,
    builder: (context, child) {
      return Transform.scale(
        scale: _scaleAnimation.value,
        child: /* 체크포인트 UI */,
      );
    },
  ),
)
```

#### (3) 완료 상태 UI (line 73-96)

**컨테이너 스타일**:
```dart
Container(
  decoration: BoxDecoration(
    color: isCompleted
      ? Colors.green.withAlpha(0.1)    // 완료: 연한 초록 배경
      : Colors.white,                   // 미완료: 하얀 배경
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isCompleted
        ? Colors.green.withAlpha(0.3)   // 완료: 초록 테두리
        : Colors.grey[200]!,             // 미완료: 회색 테두리
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: isCompleted
          ? Colors.green.withAlpha(0.1)  // 완료: 초록 그림자
          : Colors.black.withAlpha(0.03), // 미완료: 검은 그림자
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  ),
)
```

#### (4) 체크박스 애니메이션 (line 99-121)

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  width: 28, height: 28,
  decoration: BoxDecoration(
    color: isCompleted ? Colors.green : Colors.transparent,
    shape: BoxShape.circle,
    border: Border.all(
      color: isCompleted ? Colors.green : Colors.grey[400]!,
      width: 2,
    ),
  ),
  child: isCompleted
    ? Icon(Icons.check, size: 18, color: Colors.white)
        .animate()
        .scale(
          duration: 200.ms,
          curve: Curves.elasticOut,  // 튕기는 효과
        )
    : null,
)
```

#### (5) 카테고리 아이콘/색상 (line 229-257)

```dart
Color _getCategoryColor(String category) {
  switch (category) {
    case 'health':  return Colors.red[400]!;
    case 'study':   return Colors.blue[400]!;
    case 'habit':   return Colors.green[400]!;
    case 'social':  return Colors.orange[400]!;
    default:        return ModernColors.primary;
  }
}

IconData _getCategoryIcon(String category) {
  switch (category) {
    case 'health':  return Icons.favorite;
    case 'study':   return Icons.book;
    case 'habit':   return Icons.repeat;
    case 'social':  return Icons.people;
    default:        return Icons.flag;
  }
}
```

---

## 6. 데이터 플로우 (Data Flow)

### 6.1 목표 생성 플로우

```
[사용자] "매일 30분 운동하기" 입력
    │
    ▼
[QuickGoalInputWidget]
    │ - TextField에 입력 수집
    │ - 카테고리 선택: health
    │ - 기간 선택: 7일
    │
    ▼
[_createGoal() 콜백] (line 418-431)
    │ - goalData Map 생성:
    │   {
    │     'title': '매일 30분 운동하기',
    │     'category': 'health',
    │     'duration': 7
    │   }
    │
    ▼
[SimplePlannerScreen._createGoal()] (line 698-734)
    │ - 고유 ID 생성 (timestamp)
    │ - 초기 progress: 0.0
    │ - isActive: true
    │
    ├─► [GlobalUserProvider.saveGoals()] (line 2346)
    │   │ - UserGoal 객체 생성
    │   │ - planningData.goals 리스트에 추가
    │   │ - totalGoalsCreated += 1
    │   │ - SharedPreferences에 JSON 저장
    │   └─► [UI 자동 갱신] (Consumer 감지)
    │
    ├─► [GlobalPointProvider.earnPoints()]
    │   └─► 10 포인트 지급
    │
    └─► [GlobalSherpiProvider.showInstantMessage()]
        └─► "좋아요! 목표를 향해 함께 올라가봐요! 🚀"
```

### 6.2 체크포인트 완료 플로우

```
[사용자] 체크포인트 탭
    │
    ▼
[CheckpointTileWidget.onToggle] (line 61-62)
    │ - HapticFeedbackManager.lightImpact()
    │
    ▼
[SimplePlannerScreen._toggleCheckpoint()] (line 736-795)
    │ - checkpointId: "goal_id_3" (목표ID + 날짜)
    │ - newCompletedState: true
    │
    ├─► [setState()]
    │   │ - checkpoint['completed'] = true
    │   │ - _checkpointCompletions[checkpointId] = true
    │   └─► [UI 즉시 갱신]
    │
    ├─► [GlobalPointProvider.earnPoints()]
    │   └─► 50 포인트 지급 (health 카테고리)
    │
    ├─► [GlobalUserProvider.addExperience()]
    │   └─► 25 XP 추가 (포인트의 절반)
    │
    ├─► [GlobalUserProvider.updateGoalProgress()]
    │   │ - goalId로 목표 찾기
    │   │ - newProgress = (currentProgress + 10).clamp(0, 100)
    │   │ - goal.progress 업데이트
    │   └─► [SharedPreferences 자동 저장]
    │
    └─► [GlobalSherpiProvider.showInstantMessage()]
        └─► "체크포인트 도달! 조금만 더 올라가면 정상이에요! ⛰️"
```

### 6.3 목표 삭제 플로우

```
[사용자] 목표 카드를 왼쪽으로 스와이프
    │
    ▼
[Dismissible 확인 다이얼로그] (line 370-390)
    │ - "목표를 삭제하시겠어요?"
    │ - 취소 / 삭제 버튼
    │
    ▼ (삭제 선택 시)
[onDismissed] (line 392-405)
    │
    ├─► [GlobalUserProvider.deleteGoal()] (line 2470)
    │   │ - goals 리스트에서 제거
    │   │ - completedGoals에 추가 (isActive = false)
    │   │ - SharedPreferences에 저장
    │   └─► [UI 자동 갱신]
    │
    └─► [ScaffoldMessenger.showSnackBar()]
        │ - "목표가 삭제되었어요"
        └─► "되돌리기" 버튼 (향후 구현)
```

### 6.4 진행률 계산 플로우

```
[UI 렌더링 시점]
    │
    ▼
[SimplePlannerScreen._calculateOverallProgress()] (line 664-679)
    │ - 활성 목표들의 progress 합계
    │ - 활성 목표 개수로 나누기
    │ - 평균 진행률 반환 (0.0 ~ 1.0)
    │
    ▼
[MountainPathWidget]
    ├─► [_buildClimberPosition()] (line 94-149)
    │   │ - 평균 진행률 기반 X/Y 좌표 계산
    │   │ - left: 30 + (progress * 200)
    │   │ - bottom: 40 + (progress * 100)
    │   └─► Sherpi 이미지 배치
    │
    └─► [MountainPathPainter.paint()] (line 346-435)
        │ - 점선 경로 전체 그리기
        │ - 완료 부분만 실선 추출
        │ - extractPath(0, length * progress)
        └─► Canvas에 렌더링
```

### 6.5 AI 힌트 생성 플로우

```
[QuickGoalInputWidget 초기화]
    │
    ▼
[_checkAndShowAIHint()] (line 44-56)
    │ - GlobalUserProvider에서 사용자 데이터 조회
    │ - 선택된 카테고리 확인
    │
    ▼
[활동 패턴 분석]
    │
    ├─► health 카테고리 선택
    │   └─► exerciseLogs.isEmpty?
    │       └─► _showAIHint = true
    │
    ├─► study 카테고리 선택
    │   └─► readingLogs.isEmpty?
    │       └─► _showAIHint = true
    │
    └─► [기타 카테고리]
        └─► 해당 활동 기록 확인
    │
    ▼
[_getAIHint()] (line 375-416)
    │ - 카테고리별 스마트 힌트 생성
    │ - 활동 기록 개수에 따라 메시지 차등화
    │
    └─► [UI에 힌트 표시]
        - "운동을 시작해보세요! '주 3회 30분 운동' 어떠세요?"
        - "독서가 익숙해지셨네요! '월 2권 완독' 도전!"
        - "연속 14일째! 더 높은 목표에 도전해보세요!"
```

---

## 7. Provider 통합 (Provider Integration)

### 7.1 GlobalUserProvider 메서드

**위치**: `lib/shared/providers/level_1_user_data/global_user_provider.dart`

#### (1) saveGoals() - 목표 저장

**위치**: line 2346

**시그니처**:
```dart
void saveGoals(List<Map<String, dynamic>> rawGoals)
```

**동작**:
```dart
void saveGoals(List<Map<String, dynamic>> rawGoals) {
  // 1. Map을 UserGoal 객체로 변환
  final List<UserGoal> newGoals = rawGoals.map((raw) {
    return UserGoal(
      id: raw['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: raw['title'] ?? '',
      description: raw['description'],
      category: raw['category'] ?? 'growth',
      duration: raw['duration'] ?? 7,
      schedule: raw['schedule'],
      createdAt: raw['createdAt'] ?? DateTime.now(),
      completedAt: raw['completedAt'],
      progress: raw['progress'] ?? 0.0,
      isActive: raw['isActive'] ?? true,
      metadata: raw['metadata'],
    );
  }).toList();

  // 2. 현재 planningData 가져오기
  final currentPlanning = state.planningData ?? UserPlanningData.empty();

  // 3. 기존 목표와 새 목표 병합
  final updatedGoals = [...currentPlanning.goals, ...newGoals];

  // 4. planningData 업데이트
  final updatedPlanning = currentPlanning.copyWith(
    goals: updatedGoals,
    lastPlanningDate: DateTime.now(),
    totalGoalsCreated: currentPlanning.totalGoalsCreated + newGoals.length,
  );

  // 5. GlobalUser 상태 업데이트
  state = state.copyWith(planningData: updatedPlanning);

  // 6. SharedPreferences에 저장
  _saveUser();
}
```

**호출 위치**:
- `SimplePlannerScreen._createGoal()` (line 713)

#### (2) updateGoalProgress() - 진행률 업데이트

**위치**: line 2399

**시그니처**:
```dart
void updateGoalProgress(String goalId, double progress)
```

**동작**:
```dart
void updateGoalProgress(String goalId, double progress) {
  final currentPlanning = state.planningData;
  if (currentPlanning == null) return;

  // 1. 목표 찾기
  final goalIndex = currentPlanning.goals.indexWhere(
    (g) => g.id == goalId
  );

  if (goalIndex == -1) return;

  // 2. 진행률 업데이트
  final updatedGoal = currentPlanning.goals[goalIndex].copyWith(
    progress: progress.clamp(0.0, 100.0),
  );

  // 3. 100% 달성 시 완료 처리
  if (progress >= 100.0) {
    updatedGoal = updatedGoal.copyWith(
      isActive: false,
      completedAt: DateTime.now(),
    );

    // completedGoals 리스트로 이동
    final updatedCompleted = [
      ...currentPlanning.completedGoals,
      updatedGoal,
    ];

    // goals 리스트에서 제거
    final updatedGoals = currentPlanning.goals
      .where((g) => g.id != goalId)
      .toList();

    final updatedPlanning = currentPlanning.copyWith(
      goals: updatedGoals,
      completedGoals: updatedCompleted,
      totalGoalsCompleted: currentPlanning.totalGoalsCompleted + 1,
    );

    state = state.copyWith(planningData: updatedPlanning);
  } else {
    // 진행 중인 상태로 유지
    final updatedGoals = List<UserGoal>.from(currentPlanning.goals);
    updatedGoals[goalIndex] = updatedGoal;

    final updatedPlanning = currentPlanning.copyWith(
      goals: updatedGoals,
    );

    state = state.copyWith(planningData: updatedPlanning);
  }

  // 4. SharedPreferences에 저장
  _saveUser();
}
```

**호출 위치**:
- `SimplePlannerScreen._toggleCheckpoint()` (line 781)

#### (3) deleteGoal() - 목표 삭제

**위치**: line 2470

**시그니처**:
```dart
void deleteGoal(String goalId)
```

**동작**:
```dart
void deleteGoal(String goalId) {
  final currentPlanning = state.planningData;
  if (currentPlanning == null) return;

  // 1. 목표 찾기
  final goalToDelete = currentPlanning.goals.firstWhere(
    (g) => g.id == goalId,
    orElse: () => /* 빈 목표 */,
  );

  if (goalToDelete.id.isEmpty) return;

  // 2. goals 리스트에서 제거
  final updatedGoals = currentPlanning.goals
    .where((g) => g.id != goalId)
    .toList();

  // 3. completedGoals에 추가 (삭제된 목표로 표시)
  final deletedGoal = goalToDelete.copyWith(
    isActive: false,
    completedAt: DateTime.now(),
  );

  final updatedCompleted = [
    ...currentPlanning.completedGoals,
    deletedGoal,
  ];

  // 4. planningData 업데이트
  final updatedPlanning = currentPlanning.copyWith(
    goals: updatedGoals,
    completedGoals: updatedCompleted,
  );

  state = state.copyWith(planningData: updatedPlanning);

  // 5. SharedPreferences에 저장
  _saveUser();
}
```

**호출 위치**:
- `SimplePlannerScreen.onDismissed()` (line 393)

### 7.2 GlobalPointProvider 통합

**메서드**: `earnPoints(int points, PointSource source, String description)`

**호출 시나리오**:

| 시나리오 | 포인트 | Source | 호출 위치 |
|---------|--------|--------|----------|
| 새 목표 생성 | 10 | `PointSource.goalCompletion` | `_createGoal()` line 716 |
| 체크포인트 완료 | 카테고리별 차등 | `PointSource.goalCompletion` | `_toggleCheckpoint()` line 750 |

**카테고리별 포인트** (line 648-662):
- health: 50 포인트
- study: 30 포인트
- habit: 20 포인트
- social: 40 포인트

### 7.3 GlobalSherpiProvider 통합

**메서드**: `showInstantMessage()`

**호출 시나리오**:

| 시나리오 | Dialogue | Emotion | 위치 |
|---------|----------|---------|------|
| 진입 시 환영 | "함께 목표를 달성해봐요! 어떤 산을 정복하고 싶으신가요? 🏔️" | `SherpiEmotion.happy` | line 57 |
| 목표 생성 | "좋아요! [목표] 목표를 향해 함께 올라가봐요! 🚀" | `SherpiEmotion.cheering` | line 723 |
| 체크포인트 완료 | "체크포인트 도달! 조금만 더 올라가면 정상이에요! ⛰️" | `SherpiEmotion.happy` | line 788 |
| 목표 탭 | "[목표] - 진행률: [진행률]%" | `SherpiEmotion.guiding` | line 814 |

### 7.4 Provider 초기화 순서 준수

⚠️ **CRITICAL**: 계획 시스템은 다음 Provider들에 의존합니다.

**초기화 순서** (`lib/main.dart:207-240`):
```dart
// Level 1 (User Data) - REQUIRED
ref.read(globalUserProvider);       // ✅ UserPlanningData 포함
ref.read(globalPointProvider);      // ✅ 포인트 보상

// Level 3 (AI) - OPTIONAL
ref.read(sherpiProvider);           // ✅ AI 메시지
```

**의존성 체인**:
```
SimplePlannerScreen
  ├─► globalUserProvider (필수)
  │   └─► planningData 읽기/쓰기
  ├─► globalPointProvider (필수)
  │   └─► 포인트 지급
  └─► sherpiProvider (선택)
      └─► AI 메시지 표시
```

⚠️ **주의사항**:
- `globalUserProvider` 없이 화면 진입 시 → null 참조 에러
- Provider 초기화 순서 변경 금지
- Level 0 → 1 → 2 → 3 순서 준수 필수

---

## 8. UI/UX 사양 (UI/UX Specifications)

### 8.1 디자인 시스템

**Color Palette**:
```dart
// ModernColors (lib/core/theme/modern_colors.dart)
primary:      Color(0xFF6366F1)  // 인디고 (주요 액션)
background:   Color(0xFFF5F7FA)  // 연한 회색 (배경)
textPrimary:  Color(0xFF2D3142)  // 진한 회색 (텍스트)

// 카테고리별 색상
health:   Colors.red[400]      // 건강 (빨강)
study:    Colors.blue[400]     // 학습 (파랑)
habit:    Colors.green[400]    // 습관 (초록)
social:   Colors.orange[400]   // 소셜 (주황)
```

**Typography** (Google Fonts - Noto Sans):
```dart
// 헤더
GoogleFonts.notoSans(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Color(0xFF2D3142),
)

// 본문
GoogleFonts.notoSans(
  fontSize: 16,
  fontWeight: FontWeight.normal,
)

// 캡션
GoogleFonts.notoSans(
  fontSize: 12,
  color: Colors.grey[600],
)
```

**Spacing System**:
- XS: 4px
- S: 8px
- M: 12px
- L: 16px
- XL: 20px
- XXL: 24px

**Border Radius**:
- Small: 10px (칩, 버튼)
- Medium: 12-15px (카드, 입력 필드)
- Large: 16-20px (모달, 패널)
- Extra: 25-30px (바텀 시트)

### 8.2 산 경로 메타포 시각화

**배경 요소**:
```dart
// 그라디언트 배경
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF87CEEB).withAlpha(0.3),  // 하늘색 (상단)
    Color(0xFF90EE90).withAlpha(0.2),  // 연한 초록 (하단)
  ],
)

// 구름 애니메이션: 좌우 3초 왕복 (line 44-57)
// 태양 회전: 10초 1회전 (line 64-70)
```

**산 경로 렌더링**:
```dart
// MountainPathPainter (line 341-477)

// 1. 배경 산 실루엣
- 색상: ModernColors.primary.withAlpha(0.03)
- 패스: 이차 베지어 곡선으로 산봉우리 표현

// 2. 등반 경로
- 미완료 부분: 점선 (dashWidth: 5px, dashSpace: 5px)
- 완료 부분: 실선 (strokeWidth: 3px)
- 색상: ModernColors.primary.withAlpha(0.5)

// 3. 베이스 캠프
- 위치: Offset(0, 8)
- 크기: 반지름 8px
- 색상: ModernColors.primary
- 텍스트: "START"
```

**등반자 (Sherpi) 위치**:
```dart
// 진행률에 따른 동적 배치 (line 110-148)
left: 30 + (averageProgress * 200)     // 우측으로 이동
bottom: 40 + (averageProgress * 100)   // 위로 상승

// 호흡 애니메이션
scale: 1.0 ↔ 1.1 (1초 주기로 반복)
```

**산봉우리 마커**:
```dart
// 위치 계산 (line 159-163)
xPosition = 30 + ((screenWidth - 60) / (totalGoals + 1)) * (index + 1)
yPosition = 60 + (index % 2 == 0 ? 0 : 30)  // 지그재그 패턴

// 크기
- Sherpi 이미지: 50x50px
- 정보 카드: 가변 너비, 자동 높이
```

### 8.3 애니메이션 사양

**진입 애니메이션** (flutter_animate):

```dart
// MountainPathWidget (line 121)
.animate().fadeIn(duration: 600.ms)

// Peak Markers (line 195)
.animate()
  .scale(delay: (100 * index).ms, duration: 300.ms)
  .fadeIn()

// Checkpoint Tiles (line 224-226)
.animate()
  .fadeIn(delay: (100 * index).ms)
  .slideX(begin: -0.1, end: 0)
```

**터치 애니메이션**:

```dart
// CheckpointTileWidget (line 36-42)
Tween<double>(begin: 1.0, end: 0.95)
  .animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ))

// 체크 아이콘 (line 118-119)
.animate().scale(
  duration: 200.ms,
  curve: Curves.elasticOut,  // 튕기는 효과
)
```

**호흡 애니메이션** (등반자):

```dart
// line 136-147
.animate(onPlay: (controller) => controller.repeat())
  .scale(
    begin: Offset(1, 1),
    end: Offset(1.1, 1.1),
    duration: 1.seconds,
  )
  .then()
  .scale(
    begin: Offset(1.1, 1.1),
    end: Offset(1, 1),
    duration: 1.seconds,
  )
```

### 8.4 햅틱 피드백 패턴

**사용 시나리오**:

| 이벤트 | 피드백 강도 | 위치 |
|--------|------------|------|
| 목표 생성 버튼 탭 | `lightImpact` | `_showQuickGoalInput()` line 683 |
| 카테고리 선택 | `lightImpact` | `_buildCategoryChip()` line 300 |
| 기간 선택 | `lightImpact` | `_buildDurationChip()` line 345 |
| 목표 생성 완료 | `mediumImpact` | `_createGoal()` line 421 |
| 체크포인트 토글 | `lightImpact` | `_toggleCheckpoint()` line 738 |
| 목표 탭 | `lightImpact` | `_onGoalTapped()` line 800 |

**구현**:
```dart
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';

HapticFeedbackManager.lightImpact();   // 가벼운 터치
HapticFeedbackManager.mediumImpact();  // 중간 강도
```

### 8.5 반응형 레이아웃

**화면 비율**:
```dart
// SimplePlannerScreen (line 111-234)
Column(
  children: [
    Expanded(
      flex: 2,  // 40% - 산 경로 비주얼
      child: MountainPathWidget(...),
    ),
    Expanded(
      flex: 3,  // 60% - 체크포인트 리스트
      child: CheckpointsSection(...),
    ),
  ],
)
```

**목표 마커 배치**:
```dart
// 화면 너비에 따른 동적 배치 (line 160-162)
final screenWidth = MediaQuery.of(context).size.width - 32;
final xPosition = 30 + ((screenWidth - 60) / (totalGoals + 1)) * (index + 1);

// 목표가 많을수록 간격이 좁아짐
// 목표가 적을수록 간격이 넓어짐
```

### 8.6 접근성 (Accessibility)

**시맨틱 레이블**:
```dart
// 체크포인트 완료 상태
Semantics(
  label: isCompleted
    ? '${title} 완료됨'
    : '${title} 미완료',
  child: CheckpointTileWidget(...),
)
```

**색상 대비**:
- 텍스트: 최소 4.5:1 대비율 (WCAG AA 준수)
- 아이콘: 최소 3:1 대비율

**터치 타겟**:
- 최소 크기: 44x44px (iOS/Android 가이드라인)
- 체크박스: 28x28px + 16px 패딩 = 44x44px 터치 영역

---

## 9. 중요 주의사항 (Important Notes)

### 9.1 Provider 초기화 순서

⚠️ **CRITICAL**: 절대 변경 금지

```dart
// lib/main.dart:207-240
// Level 1: User Data (필수)
ref.read(globalUserProvider);   // ✅ planningData 포함
ref.read(globalPointProvider);  // ✅ 포인트 시스템

// Level 3: AI (선택)
ref.read(sherpiProvider);       // ✅ AI 메시지
```

**의존성**:
- `SimplePlannerScreen` → `globalUserProvider` (필수)
- `SimplePlannerScreen` → `globalPointProvider` (필수)
- `SimplePlannerScreen` → `sherpiProvider` (선택)

**위반 시 결과**:
```
❌ "Provider not found" 에러
❌ 앱 크래시 (시작 시점)
```

### 9.2 체크포인트 상태 관리

**로컬 상태** (`_checkpointCompletions`):
- 위치: `SimplePlannerScreen` (line 40)
- 타입: `Map<String, bool>`
- 키: `"${goalId}_${day}"` (예: `"1730606400000_3"`)
- 값: `true` (완료) / `false` (미완료)

**영속성**:
```
❌ SharedPreferences에 저장되지 않음
❌ 앱 재시작 시 초기화됨
```

**이유**:
- 체크포인트는 "오늘의 할 일" 개념
- 매일 새로운 체크포인트 생성
- 과거 체크포인트는 목표 진행률에만 반영

### 9.3 진행률 업데이트 로직

**체크포인트 완료 시**:
```dart
// line 779-784
final newProgress = (goal.progress + 10).clamp(0.0, 100.0);
ref.read(globalUserProvider.notifier)
   .updateGoalProgress(checkpoint['goalId'], newProgress);
```

**특징**:
- 체크포인트 1개 완료 = +10% 진행률
- 10개 체크포인트 완료 = 100% (목표 달성)
- `clamp(0.0, 100.0)`로 범위 보장

**100% 달성 시 자동 처리**:
```dart
// globalUserProvider.updateGoalProgress() (line 2399)
if (progress >= 100.0) {
  // 1. goals에서 completedGoals로 이동
  // 2. isActive = false
  // 3. completedAt = DateTime.now()
  // 4. totalGoalsCompleted += 1
}
```

### 9.4 JSON 직렬화 이슈

**DateTime 필드**:
```dart
// 저장 시
'createdAt': createdAt.toIso8601String()

// 로드 시
createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()
```

**Map 필드** (metadata, categoryStats):
```dart
// 저장 시
'metadata': metadata

// 로드 시
metadata: json['metadata'] as Map<String, dynamic>?
```

⚠️ **주의**: `Map<String, dynamic>` 타입 명시 필수

### 9.5 AI 힌트 표시 조건

**자동 표시**:
```dart
// line 44-56
if (user.dailyRecords.exerciseLogs.isEmpty &&
    _selectedCategory == 'health') {
  _showAIHint = true;  // 운동 기록 없고 건강 카테고리 선택 시
}
```

**수동 숨김**:
```dart
// line 179-187
GestureDetector(
  onTap: () => setState(() => _showAIHint = false),
  child: Icon(Icons.close, size: 14),
)
```

**재표시 조건**:
- 카테고리 변경 시 (`_checkAndShowAIHint()` 재호출)
- 모달 재진입 시 (initState에서 초기화)

### 9.6 목표 ID 생성

**타임스탬프 기반**:
```dart
// line 702
'id': DateTime.now().millisecondsSinceEpoch.toString()
```

**예시**:
```
1730606400000  // 2025-11-03 00:00:00 UTC
```

**특징**:
- 고유성 보장 (밀리초 단위)
- 정렬 가능 (생성 순서)
- 문자열 타입 (JSON 호환)

**충돌 가능성**:
```
❌ 동일 밀리초에 2개 생성 시 중복 가능
✅ 실제로는 거의 불가능 (UI 반응 속도 < 1ms)
```

### 9.7 Dismissible 패턴

**삭제 확인 다이얼로그**:
```dart
// line 370-390
confirmDismiss: (direction) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(...),
  );
}
```

**주의사항**:
- `confirmDismiss`에서 `false` 반환 시 스와이프 취소
- `true` 반환 시 `onDismissed` 실행
- 다이얼로그 없이 즉시 삭제하려면 `confirmDismiss` 제거

### 9.8 성능 고려사항

**리스트 렌더링**:
```dart
// line 214-228
ListView.builder(
  itemCount: todayCheckpoints.length,
  itemBuilder: (context, index) {
    return CheckpointTileWidget(...)
      .animate()
      .fadeIn(delay: (100 * index).ms);
  },
)
```

**최적화**:
- `ListView.builder` 사용 (지연 로딩)
- 애니메이션 지연 시간 최소화 (100ms 간격)
- 최대 체크포인트 수 제한 없음 (활성 목표 수에 비례)

**권장 제한**:
- 활성 목표: 10개 이하
- 체크포인트: 10개 이하 (활성 목표당 1개)

---

## 10. 확장 포인트 (Extension Points)

### 10.1 목표 상세 편집

**현재 상태**: 목표 생성 후 수정 불가

**구현 방향**:
```dart
// 1. _onGoalTapped() 수정 (line 798-821)
void _onGoalTapped(String goalId) {
  // 현재: Sherpi 메시지만 표시
  // 변경: 목표 상세 화면으로 이동
  Navigator.pushNamed(
    context,
    '/goal_detail',
    arguments: {'goalId': goalId},
  );
}

// 2. GoalDetailScreen 생성
class GoalDetailScreen extends ConsumerWidget {
  // - 목표 제목 수정
  // - 목표 설명 수정
  // - 카테고리 변경
  // - 기간 연장
  // - 삭제
}

// 3. GlobalUserProvider에 메서드 추가
void updateGoal(String goalId, Map<String, dynamic> updates) {
  // UserGoal.copyWith() 활용
  // SharedPreferences 저장
}
```

### 10.2 되돌리기 기능

**현재 상태**: "되돌리기" 버튼은 UI만 존재 (line 399-402)

**구현 방향**:
```dart
// 1. 삭제된 목표 임시 저장
class _SimplePlannerScreenState extends ConsumerState<SimplePlannerScreen> {
  UserGoal? _lastDeletedGoal;

  void _deleteGoal(UserGoal goal) {
    _lastDeletedGoal = goal;  // 백업
    ref.read(globalUserProvider.notifier).deleteGoal(goal.id);
  }
}

// 2. 되돌리기 구현
void _undoDelete() {
  if (_lastDeletedGoal != null) {
    final goalMap = {
      'id': _lastDeletedGoal!.id,
      'title': _lastDeletedGoal!.title,
      // ... 모든 필드 복원
    };
    ref.read(globalUserProvider.notifier).saveGoals([goalMap]);
    _lastDeletedGoal = null;
  }
}

// 3. SnackBar 액션 연결 (line 399)
SnackBarAction(
  label: '되돌리기',
  onPressed: _undoDelete,  // 구현된 메서드 연결
)
```

### 10.3 알림 시스템

**목적**: 목표 기한 임박 알림

**구현 요소**:
```dart
// 1. Flutter Local Notifications 패키지 추가
dependencies:
  flutter_local_notifications: ^17.0.0

// 2. 알림 스케줄링
void _scheduleGoalReminder(UserGoal goal) {
  final daysLeft = goal.daysRemaining;

  if (daysLeft == 3) {
    // D-3 알림
    _scheduleNotification(
      id: goal.id.hashCode,
      title: '목표 마감 3일 전',
      body: '${goal.title} 목표를 확인하세요!',
    );
  }
}

// 3. 목표 생성 시 알림 스케줄링
void _createGoal(Map<String, dynamic> goalData) {
  // ... 기존 코드
  _scheduleGoalReminder(createdGoal);
}
```

### 10.4 목표 공유 기능

**목적**: 목표를 친구와 공유하여 동기 부여

**구현 요소**:
```dart
// 1. 공유 버튼 추가 (목표 카드에)
IconButton(
  icon: Icon(Icons.share),
  onPressed: () => _shareGoal(goal),
)

// 2. share_plus 패키지 사용
import 'package:share_plus/share_plus.dart';

void _shareGoal(UserGoal goal) {
  final message = '''
    ${goal.title}
    카테고리: ${_getCategoryName(goal.category)}
    기간: ${goal.duration}일
    진행률: ${goal.progress.toInt()}%

    Sherpa 앱에서 함께 목표를 달성해요!
  ''';

  Share.share(message);
}
```

### 10.5 목표 템플릿

**목적**: 자주 사용하는 목표를 템플릿으로 저장

**구현 요소**:
```dart
// 1. GoalTemplate 모델 추가
class GoalTemplate {
  final String id;
  final String title;
  final String category;
  final int duration;
  final bool isDefault;  // 기본 템플릿 여부
}

// 2. 기본 템플릿 제공
final defaultTemplates = [
  GoalTemplate(
    id: 'health_exercise',
    title: '주 3회 30분 운동하기',
    category: 'health',
    duration: 30,
    isDefault: true,
  ),
  GoalTemplate(
    id: 'study_reading',
    title: '매일 10페이지 독서',
    category: 'study',
    duration: 30,
    isDefault: true,
  ),
  // ...
];

// 3. QuickGoalInputWidget에 템플릿 섹션 추가
Widget _buildTemplateSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('추천 목표', style: ...),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: defaultTemplates.map((template) {
            return _buildTemplateChip(template);
          }).toList(),
        ),
      ),
    ],
  );
}
```

### 10.6 진행률 시각화 개선

**목적**: 목표 달성 과정을 더 풍부하게 시각화

**구현 아이디어**:

#### (1) 일별 진행 그래프
```dart
// fl_chart 패키지 사용
import 'package:fl_chart/fl_chart.dart';

class GoalProgressChart extends StatelessWidget {
  final UserGoal goal;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        // 일별 진행률 데이터
        // X축: 날짜
        // Y축: 진행률 (0-100)
      ),
    );
  }
}
```

#### (2) 마일스톤 시스템
```dart
class GoalMilestone {
  final double progress;  // 25%, 50%, 75%, 100%
  final String message;   // "1/4 완료!", "절반 도달!", ...
  final String reward;    // "50 포인트", "특별 뱃지"
  final bool isAchieved;
}

// 마일스톤 달성 시 축하 애니메이션
void _checkMilestones(double newProgress) {
  final milestones = [25.0, 50.0, 75.0, 100.0];

  for (final milestone in milestones) {
    if (newProgress >= milestone && !_isMilestoneAchieved(milestone)) {
      _celebrateMilestone(milestone);
    }
  }
}
```

### 10.7 통계 대시보드

**목적**: 목표 달성 통계 및 인사이트 제공

**구현 요소**:
```dart
class GoalStatistics {
  // 전체 통계
  final int totalGoalsCreated;
  final int totalGoalsCompleted;
  final double overallCompletionRate;

  // 카테고리별 통계
  final Map<String, int> goalsByCategory;
  final Map<String, double> completionRateByCategory;

  // 시계열 통계
  final Map<String, int> goalsCreatedByMonth;
  final Map<String, int> goalsCompletedByMonth;

  // 연속 기록
  final int currentStreak;      // 연속 목표 달성 일수
  final int longestStreak;      // 최장 연속 기록
}

class StatisticsDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = _calculateStatistics(ref);

    return Scaffold(
      appBar: SherpaCleanAppBar(title: '나의 성장 통계'),
      body: Column(
        children: [
          _buildOverallStats(stats),
          _buildCategoryBreakdown(stats),
          _buildMonthlyChart(stats),
          _buildStreakDisplay(stats),
        ],
      ),
    );
  }
}
```

### 10.8 소셜 기능

**목적**: 친구와 목표를 공유하고 응원하기

**구현 요소**:
```dart
// 1. 목표 공개/비공개 설정
class UserGoal {
  // ... 기존 필드
  final bool isPublic;        // 공개 여부
  final List<String> sharedWith;  // 공유된 사용자 ID
}

// 2. 친구 응원 시스템
class GoalCheer {
  final String id;
  final String goalId;
  final String userId;        // 응원한 사용자
  final String message;       // "화이팅!", "멋져요!", ...
  final DateTime createdAt;
}

// 3. 응원 UI
Widget _buildCheerButton(UserGoal goal) {
  return IconButton(
    icon: Icon(Icons.thumb_up),
    onPressed: () => _cheerGoal(goal.id),
  );
}
```

---

## Appendix

### A. 트러블슈팅 가이드

**문제 1**: 체크포인트가 표시되지 않음

**원인**:
- `user.planningData`가 `null`
- 활성 목표가 없음 (`goal.isActive == false`)

**해결**:
```dart
// _getTodayCheckpoints() 디버깅
print('planningData: ${user.planningData}');
print('goals: ${user.planningData?.goals}');
print('active goals: ${user.planningData?.goals.where((g) => g.isActive)}');
```

**문제 2**: 진행률이 업데이트되지 않음

**원인**:
- `updateGoalProgress()` 호출 누락
- `goalId` 불일치

**해결**:
```dart
// _toggleCheckpoint() 디버깅
print('checkpoint goalId: ${checkpoint['goalId']}');
print('found goal: $goal');
print('new progress: $newProgress');
```

**문제 3**: Provider 초기화 에러

**원인**:
- Provider 초기화 순서 위반
- `globalUserProvider`가 Level 1이 아님

**해결**:
```dart
// main.dart 확인
// ✅ Level 1에 globalUserProvider 있는지 확인
// ✅ 순서: Level 0 → 1 → 2 → 3
```

**문제 4**: JSON 파싱 에러

**원인**:
- `DateTime` 필드 직렬화 실패
- `Map` 타입 불일치

**해결**:
```dart
// UserGoal.fromJson() 디버깅
print('json: $json');
print('createdAt: ${json['createdAt']}');

// 안전한 파싱
createdAt: json['createdAt'] != null
  ? DateTime.parse(json['createdAt'])
  : DateTime.now(),
```

### B. 공통 이슈

**이슈 1**: 앱 재시작 시 체크포인트 초기화

**원인**: 로컬 상태 (`_checkpointCompletions`) 사용

**해결**:
- ✅ 의도된 동작 (오늘의 할 일 개념)
- ❌ 영속화 필요 시 → `UserGoal`에 `dailyCheckpoints` 필드 추가

**이슈 2**: 목표가 많을 때 산 경로 겹침

**원인**: 고정된 X/Y 좌표 계산식

**해결**:
```dart
// mountain_path_widget.dart 수정 (line 159-163)
// 동적 간격 조정 또는 스크롤 가능한 캔버스 구현
```

**이슈 3**: AI 힌트가 너무 자주 표시됨

**원인**: 카테고리 변경 시마다 `_checkAndShowAIHint()` 호출

**해결**:
```dart
// QuickGoalInputWidget에 상태 추가
bool _hintDismissed = false;

void _checkAndShowAIHint() {
  if (_hintDismissed) return;  // 사용자가 닫았으면 표시 안 함
  // ... 기존 로직
}
```

### C. 개발 워크플로우

**1. 새 목표 기능 추가**:
```bash
1. UserGoal 모델에 필드 추가
   └─► lib/shared/models/global_user_model.dart

2. toJson()/fromJson() 업데이트
   └─► JSON 직렬화 호환성 유지

3. QuickGoalInputWidget에 UI 추가
   └─► 입력 필드 또는 선택 옵션

4. _createGoal()에서 필드 처리
   └─► goalMap에 필드 추가

5. UI에 필드 표시
   └─► MountainPathWidget 또는 CheckpointTileWidget
```

**2. 새 카테고리 추가**:
```bash
1. 카테고리 상수 정의
   └─► 'creativity', 'finance', 'relationship' 등

2. _getCategoryColor() 수정 (3개 파일)
   └─► simple_planner_screen.dart (line 526)
   └─► mountain_path_widget.dart (line 304)
   └─► checkpoint_tile_widget.dart (line 229)

3. _getCategoryIcon() 수정 (3개 파일)
   └─► simple_planner_screen.dart (line 542)
   └─► mountain_path_widget.dart (N/A)
   └─► checkpoint_tile_widget.dart (line 244)

4. _getCategoryMountain() 수정 (2개 파일)
   └─► simple_planner_screen.dart (line 632)
   └─► mountain_path_widget.dart (line 288)

5. _getCategorySherpiImage() 수정
   └─► mountain_path_widget.dart (line 319)

6. _getCategoryPoints() 수정
   └─► simple_planner_screen.dart (line 648)

7. QuickGoalInputWidget에 카테고리 칩 추가
   └─► _buildCategoryChip() 호출 (line 212-222)

8. AI 힌트 로직 추가
   └─► _getAIHint() switch 문 (line 375-416)
```

**3. 테스트 체크리스트**:
```
□ 목표 생성 동작
□ 체크포인트 완료/취소 동작
□ 진행률 계산 정확도
□ 목표 삭제 동작
□ Provider 상태 동기화
□ SharedPreferences 영속성
□ 애니메이션 부드러움
□ 햅틱 피드백 정상 작동
□ Sherpi 메시지 표시
□ 포인트/경험치 지급
```

---

## 마무리

이 문서는 Sherpa App의 계획하기 시스템에 대한 완전한 기술 문서입니다.

**주요 특징**:
- ✅ 산 등반 메타포로 목표를 직관적으로 시각화
- ✅ 30초 내 목표 생성 가능한 빠른 UX
- ✅ AI 기반 스마트 힌트로 개인화된 추천
- ✅ 일일 체크포인트로 실천 가능한 단계 제공
- ✅ 포인트/경험치 보상으로 지속적 동기 부여

**기술 스택**:
- Flutter 3.27.0+
- Riverpod 2.4.9 (상태 관리)
- flutter_animate (애니메이션)
- SharedPreferences (영구 저장)
- CustomPainter (산 경로 렌더링)

**확장 가능성**:
- 목표 상세 편집
- 되돌리기 기능
- 알림 시스템
- 목표 공유
- 템플릿 시스템
- 통계 대시보드

**문의**:
- 기술 문의: `.claude/knowledge_base/` 참조
- 버그 리포트: GitHub Issues
- 기능 제안: Product Team

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-03
**Maintained by**: Documentation Specialist
**Next Review**: 2025-12-03
