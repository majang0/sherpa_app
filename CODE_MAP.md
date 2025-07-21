
# 셰르파(Sherpa) 앱 코드맵

## 1. 🚀 프로젝트 개요 (High-Level Summary)

- **프로젝트명**: 셰르파 (sherpa_app)
- **핵심 컨셉**: "함께 오르는 즐거움". 등반 및 하이킹을 중심으로 한 **소셜 피트니스 앱**에 **게이미피케이션(Gamification)** 요소를 결합하여 사용자의 꾸준한 활동과 성장을 유도합니다.
- **타겟 플랫폼**: Flutter를 사용하여 Android, iOS, Web, Desktop 등 주요 플랫폼을 모두 지원하는 크로스플랫폼 애플리케이션입니다.

---

## 2. 🏛️ 아키텍처 및 기술 스택 (Architecture & Tech Stack)

이 프로젝트는 현대적인 Flutter 개발 트렌드를 따르는 견고하고 확장 가능한 구조를 가지고 있습니다.

- **아키텍처**: **피처 우선(Feature-Driven) 아키텍처**
  - `lib/features`: 앱의 각 주요 기능(등반, 커뮤니티, 퀘스트 등)이 독립적인 모듈로 구성되어 유지보수성과 확장성을 극대화합니다.
  - `lib/shared`: 여러 기능에서 공통으로 사용하는 위젯, 모델, 프로바이더 등을 분리하여 코드 재사용성을 높입니다.
  - `lib/core`: 앱 전반의 핵심 로직(테마, 상수, 라우팅)을 관리합니다.

- **상태 관리 (State Management)**: **Riverpod**
  - `Provider`, `StateNotifierProvider` 등을 활용하여 앱의 상태를 선언적이고 반응적으로 관리합니다.
  - 의존성 주입(DI)을 통해 각 컴포넌트가 필요한 데이터에 쉽게 접근할 수 있도록 합니다.

- **네비게이션 (Navigation)**: **GoRouter**
  - 복잡한 화면 흐름과 딥링킹(Deep Linking)을 효과적으로 관리하기 위해 사용됩니다.

- **백엔드 (Backend)**: **하이브리드 방식**
  - **Firebase**: 사용자 인증(Auth), 데이터베이스(Cloud Firestore), 파일 저장소(Storage) 등 핵심 백엔드 기능을 담당합니다.
  - **Dio**: Firebase 외의 별도 REST API 서버와 통신하기 위해 사용됩니다.

- **로컬 데이터베이스 (Local DB)**: **Hive** & **SharedPreferences**
  - `Hive`: 복잡한 객체(사용자 데이터, 설정 등)를 빠르고 효율적으로 로컬에 저장합니다.
  - `SharedPreferences`: 간단한 키-값 데이터를 저장합니다.

- **데이터 모델링 (Data Modeling)**: **Freezed** & **json_serializable**
  - 불변(Immutable) 데이터 클래스를 자동으로 생성하여 상태의 안정성과 예측 가능성을 높입니다.

- **UI/UX**: `flutter_animate`, `lottie`, `fl_chart` 등 다수의 라이브러리를 사용하여 동적이고 시각적으로 풍부한 사용자 경험을 제공하는 것을 목표로 합니다.

---

## 3. 🗺️ 디렉토리 구조 (Directory Structure)

```
C:/sherpa_app/
├── lib/
│   ├── core/               # 🎯 앱의 핵심 로직 (코어)
│   │   ├── constants/      # 색상, 사이즈, 게임 공식 등 앱 전역 상수
│   │   └── theme/          # 앱 전체 테마 (라이트/다크)
│   │
│   ├── features/           # ⭐️ 앱의 핵심 기능별 모듈
│   │   ├── climbing/       # 등반 및 성장(레벨, 스탯, 뱃지) 기능
│   │   ├── community/      # 커뮤니티, 소셜 피드 기능
│   │   ├── daily_record/   # 일일 활동(걸음, 독서, 운동, 일기) 기록
│   │   ├── home/           # 홈 화면
│   │   ├── meetings/       # 모임 및 챌린지 기능
│   │   ├── profile/        # 사용자 프로필
│   │   ├── quests/         # 퀘스트 시스템 (V2)
│   │   └── ...             # 기타 기능들 (상점, 지갑 등)
│   │
│   ├── shared/             # ♻️ 여러 기능에서 공유되는 코드
│   │   ├── models/         # 공통 데이터 모델 (GlobalUser, Badge 등)
│   │   ├── providers/      # 공통 상태 관리 프로바이더 (GlobalUserProvider 등)
│   │   ├── widgets/        # 공통 UI 위젯 (카드, 버튼, 앱바 등)
│   │   └── utils/          # 공통 유틸리티 (햅틱 피드백 등)
│   │
│   ├── main.dart           # 앱의 시작점 (Entry Point)
│   └── main_navigation_screen.dart # 메인 하단 네비게이션 바 및 화면 전환 관리
│
├── assets/                 # 🏞️ 이미지, 폰트, 애니메이션 등 정적 파일
│   └── images/sherpi/      # 셰르피 캐릭터 감정별 이미지
│
├── pubspec.yaml            # 📦 프로젝트 의존성 및 설정 파일
├── ARCHITECTURE_IMPROVEMENTS.md # 아키텍처 개선 관련 중요 문서
└── quest.md                # 퀘스트 시스템 설계 문서
```

---

## 4. 💧 데이터 흐름 (Data Flow)

이 앱의 데이터 흐름은 **Riverpod**를 중심으로 한 단방향 흐름을 따릅니다.

- **중앙 상태 관리**: `shared/providers/global_user_provider.dart`가 **단일 진실 공급원(Single Source of Truth)** 역할을 합니다. 사용자의 모든 정보(레벨, 경험치, 스탯, 모든 활동 기록)는 `GlobalUser` 모델에 통합되어 이 프로바이더를 통해 관리됩니다.

- **데이터 흐름 예시 (운동 기록)**:
  1.  **UI (View)**: 사용자가 `ExerciseRecordScreen`에서 운동 정보를 입력하고 '저장' 버튼을 누릅니다.
  2.  **프로바이더 호출**: 버튼의 `onPressed` 콜백은 `ref.read(globalUserProvider.notifier).addExerciseLog(log)`를 호출합니다.
  3.  **상태 업데이트 (Logic)**: `GlobalUserNotifier`는 전달받은 운동 기록(`ExerciseLog`)을 기존 상태(`state`)의 `dailyRecords.exerciseLogs` 리스트에 추가하고, `copyWith`를 통해 새로운 `GlobalUser` 상태를 생성합니다.
  4.  **UI 재구성 (Rebuild)**: `globalUserProvider`를 `watch`하고 있던 모든 위젯(예: `HomeScreen`, `ProfileScreen`)은 새로운 상태를 감지하고 자동으로 UI를 다시 그립니다.
  5.  **연쇄 반응 (Side Effect)**: `GlobalUserNotifier` 내부에서 `_handleActivityCompletion`과 `_notifyQuestSystem` 같은 메서드가 호출되어, 운동 기록에 따른 경험치/포인트 보상을 지급하고, 관련된 퀘스트의 진행 상태를 업데이트합니다.

---

## 5. ⚙️ 핵심 시스템 분석 (Core Systems Deep Dive)

### 1. 글로벌 상태 관리 시스템 (`global_user_provider.dart`)

- **역할**: 앱의 모든 사용자 관련 데이터를 통합 관리하는 가장 중요한 프로바이더입니다.
- **주요 관리 데이터**:
  - `GlobalUser`: 사용자 기본 정보, 레벨, 경험치, 5대 능력치(체력, 지식, 기술, 사교성, 의지).
  - `DailyRecordData`: 걸음수, 집중 시간, 독서/운동/일기/모임/영화 등 모든 활동 로그.
  - `ClimbingSession`: 현재 진행 중인 등반 세션 정보.
- **특징**:
  - **단일 진실 공급원**: 모든 데이터 변경은 이 프로바이더의 메서드를 통해서만 이루어지므로 데이터 흐름 추적이 용이하고 상태 불일치 문제를 방지합니다.
  - **자동 동기화**: `_updateGoalStatusBasedOnActivity`와 같은 내부 로직을 통해 사용자의 활동이 기록될 때마다 일일 목표 달성 여부를 자동으로 확인하고 상태를 업데이트합니다.
  - **퀘스트 연동**: `_notifyQuestSystem`을 통해 모든 활동이 퀘스트 시스템에 실시간으로 전달되어 진행률이 자동으로 업데이트됩니다.

### 2. 게이미피케이션 시스템 (`game_constants.dart`)

- **역할**: 앱의 핵심 게임 로직인 '등반력'과 보상 시스템의 모든 공식과 상수를 정의합니다.
- **주요 공식**:
  - **등반력 (Climbing Power)**: `(레벨 × 10 + 칭호 보너스) × (1 + 능력치 보너스) × (1 + 뱃지 보너스)` 공식을 통해 계산됩니다. 이는 사용자의 모든 성장 요소가 등반력에 종합적으로 반영됨을 의미합니다.
  - **성공 확률**: 사용자의 등반력과 도전할 산의 요구 등반력을 비교하여 성공 확률을 동적으로 계산합니다.
  - **보상 계산**: 등반 성공/실패 시 산의 난이도와 소요 시간을 기반으로 경험치(XP)와 포인트(P) 보상을 차등 지급합니다.

### 3. 퀘스트 시스템 (V2) (`features/quests/`)

- **역할**: `quest.md` 문서를 기반으로 설계된 정교한 퀘스트 시스템입니다.
- **구조**:
  - **템플릿 기반**: `quest_templates_data.dart`에 모든 퀘스트의 고정된 정보(제목, 설명, 보상 규칙)가 정의되어 있습니다.
  - **인스턴스 관리**: `QuestGeneratorService`가 템플릿을 바탕으로 사용자에게 실제 수행할 퀘스트 인스턴스(`QuestInstance`)를 생성하여 제공합니다. (일일/주간/고급 퀘스트)
  - **자동 추적**: `QuestTrackingService`가 `global_user_provider`의 데이터 변경을 감지하여, `QuestTrackingCondition`에 명시된 조건을 만족하는 퀘스트의 진행 상태를 자동으로 업데이트합니다.

### 4. UI 및 디자인 시스템

- **문서 기반**: `sherpa_design_system.md`에 디자인 철학, 컬러 시스템, 타이포그래피, 그림자, 애니메이션 원칙 등이 상세히 정의되어 있습니다.
- **핵심 컨셉**: "무해한 성장(Harmless Growth)". 사용자가 편안함을 느끼는 UI/UX를 지향합니다.
- **컬러 시스템**: `core/constants/app_colors.dart`에 기능별, 상태별, 감정별로 세분화된 컬러 팔레트가 정의되어 있어 앱 전체의 시각적 일관성을 유지합니다.
- **공통 위젯**: `shared/widgets/`에 `SherpaCard`, `SherpaButton` 등 재사용 가능한 커스텀 위젯이 많아 개발 효율성과 디자인 일관성을 높입니다.

---
*이 문서는 프로젝트의 핵심 구조와 로직을 이해하는 데 도움을 주기 위해 작성되었습니다. 최신 상태를 반영하기 위해 주기적인 업데이트가 필요합니다.*
