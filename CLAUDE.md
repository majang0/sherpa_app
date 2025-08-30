# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Sherpa App (셰르파) is a Flutter-based mobile application that gamifies personal growth through a mountain climbing metaphor. The app encourages users to achieve daily goals, connect with others, and track their progress through an RPG-style system.

## Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build APK
flutter build apk

# Build iOS (requires macOS)
flutter build ios

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Format code
dart format lib

# Format code with line length
dart format -l 80 lib

# Generate code (for freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch and regenerate code on changes
flutter pub run build_runner watch --delete-conflicting-outputs

# Generate app icons
flutter pub run flutter_launcher_icons

# Change app package name (development utility)
flutter pub run change_app_package_name:main com.new.package.name
```

### Flutter Version Requirements
- Flutter SDK: >=3.27.0
- Dart SDK: >=3.0.0 <4.0.0

## Architecture Overview

### Core Architecture Pattern: Feature-First

The app follows a feature-first architecture where each feature is self-contained:

```
lib/
├── core/           # App-wide constants, theme, utilities
├── features/       # Feature modules (each with models, providers, presentation)
├── shared/         # Shared components, providers, and models
├── main.dart       # Entry point with global provider initialization and routes
└── main_navigation_screen.dart  # Bottom navigation and tab management
```

### State Management: Riverpod

The app uses Riverpod (v2.4.9) with a specific pattern:

1. **Global Providers** (initialized at app startup in `main.dart`):
   - `globalGameProvider` - Core game mechanics
   - `globalUserProvider` - User data and progress
   - `globalPointProvider` - Currency/points system
   - `globalUserTitleProvider` - Achievements and titles
   - `questProvider` - Quest management
   - `sherpiProvider` - AI companion system

2. **Provider Initialization Pattern**:
   ```dart
   // Providers are auto-initialized in order:
   ref.read(globalGameProvider);
   ref.read(globalUserProvider);  // Clears SharedPreferences on init
   ref.read(globalPointProvider);
   ref.read(globalUserTitleProvider);
   ref.read(questProvider);
   ref.read(sherpiProvider);
   ```

3. **Provider Pattern**: Most providers extend `StateNotifierProvider` for complex state management

### Key Features and Their Responsibilities

- **climbing**: Core gamification engine (mountains, badges, stats)
- **daily_record**: Activity tracking (exercise, reading, diary, focus timer)
- **meetings**: Social meetup coordination with 3-model architecture
- **quests**: Daily challenges and objectives
- **community**: Social features and interactions
- **home**: Main dashboard aggregating all features
- **profile**: User profile and growth tracking
- **shop**: Point spending and rewards
- **wallet**: Financial transactions and payment features

### Meeting Feature Architecture

**3-Model System** for different meeting contexts:

1. **AvailableMeeting** (`features/meetings/models/available_meeting_model.dart`):
   - Core meeting data model with 6 categories: study, exercise, hobby, culture, networking, reading
   - Types: free (1000P fee) vs paid (5% fee)
   - Auto-calculated rewards based on difficulty and category
   - Real-time participation tracking with capacity limits

2. **RecommendedMeeting** (`features/home/models/meeting_recommendation_model.dart`):
   - AI-powered meeting recommendations with GPS coordinates
   - Extended categories: networking, study, exercise, social, career, hobby, culture, volunteer
   - Difficulty levels (beginner/intermediate/advanced) and status tracking
   - Integration with home dashboard for personalized suggestions

3. **MeetingLog** (`features/daily_record/models/record_models.dart`):
   - Activity completion tracking with mood and satisfaction ratings
   - 6 mood states: very_happy, happy, good, normal, tired, stressed
   - Integration with global activity completion flow via `handleActivityCompletion()`

**Meeting Flow Architecture**:
```
Browse → Detail → Apply → Process → Success → Participate → Review → Rewards
```

**Provider Integration**:
- `globalMeetingProvider`: Central meeting state management
- Cross-provider sync with quest system for real-time progress tracking
- Point attribution via `globalPointProvider` with meeting-specific `PointSource`

**UI Components**:
- `MeetingInfoCardWidget`: Displays meeting details with category-colored tags
- Tab-based navigation: Meeting + Challenge tabs in `MeetingTabScreen`
- Integration with main navigation via tab index 3

### Navigation

Uses standard MaterialApp routing with a route table in `main.dart`:

**Main Navigation Structure**:
- Bottom navigation with 5 tabs: Home, Level Up, Quest, Meeting, Profile
- Quest and Meeting tabs have nested sub-tabs
- Tab navigation managed by `MainNavigationScreen`

**Key Routes**:
- `/`: Main navigation screen with bottom tabs
- `/daily_record`, `/diary_record`, `/exercise_record`, `/reading_record`: Activity tracking
- Meeting flow routes:
  - `/meeting_detail`: Meeting details with apply button
  - `/meeting_application`: Application form
  - `/meeting_success`: Application confirmation
  - `/meeting_review`: Post-meeting feedback
- `/levelup`: Level progression screen

**Navigation Patterns**:
```dart
// Navigate to specific tab
Navigator.pushNamed(context, '/', arguments: 2); // Goes to Quest tab (index 2)

// Navigate to tab with sub-tab
Navigator.pushNamed(context, '/', arguments: {
  'tabIndex': 3,        // Meeting tab
  'subTabIndex': 1,     // Applications sub-tab
});

// Pass complex objects
Navigator.pushNamed(context, '/meeting_detail', 
  arguments: meetingModel);
```

### Data Models

Models use standard Dart classes with some using `json_annotation` for serialization:
- Feature-specific models in `features/[feature]/models/`
- Shared models in `shared/models/` for cross-feature data
- Global user data in `shared/models/global_user_model.dart`
- No code generation currently active (freezed/json_serializable dependencies present but not used)

Key model relationships:
- `GlobalUser` contains all user data including stats, badges, and daily records
- `DailyRecordData` aggregates all activity logs (exercise, reading, diary, meetings)
- `ClimbingSession` tracks current mountain progress

**Meeting Model Relationships**:
- `AvailableMeeting`: Core meeting entity with enums for MeetingCategory/Type/Scope
- `RecommendedMeeting`: AI-suggested meetings with GPS + recommendation scoring
- `MeetingLog`: Completed meeting records with mood/satisfaction tracking
- Cross-model integration: AvailableMeeting → participation → MeetingLog creation

### Firebase Integration

The app is configured for Firebase services but currently uses local storage:
- Dependencies: `firebase_auth`, `cloud_firestore`, `firebase_storage`
- **Current storage**: SharedPreferences and Hive for local data persistence
- Firebase configuration files need to be added for each platform before Firebase features will work
- **Note**: App currently clears all data on startup (development behavior)

### UI/UX Patterns

- **Theme**: Custom theme defined in `core/theme/app_theme.dart`
- **Colors**: 
  - **Recommended**: Modern unified color system in `core/theme/modern_colors.dart`
  - Legacy: App-wide colors in `core/constants/app_colors.dart` (deprecated)
  - Legacy: Feature-specific colors in `features/daily_record/constants/record_colors.dart` (deprecated)
- **Animations**: Heavy use of Lottie, flutter_animate, and confetti for gamification
- **Widgets**: Shared widgets in `shared/widgets/` including:
  - `SherpaCleanAppBar` - Standard app bar (no titleStyle parameter)
  - `SherpaButton` - Animated button with haptic feedback
- **Character System**: "Sherpi" companion with multiple emotional states

### Common Widget Patterns

1. **SherpaCleanAppBar Usage**:
```dart
SherpaCleanAppBar(
  title: 'Page Title',
  backgroundColor: ModernColors.background,
  actions: [...],
)
```

2. **Color System (Updated 2024-08-12)**:
- **PRIMARY**: Use `ModernColors` for all new development - modern blue-white theme
- **DEPRECATED**: `AppColors` and `RecordColors` - kept for backward compatibility
- **Migration**: All daily record widgets updated to use `ModernColors`
- Example: `ModernColors.primary`, `ModernColors.success`, `ModernColors.primaryGradient`

### Activity Completion Flow

All activities follow a unified completion pattern through `GlobalUserNotifier`:

```dart
// Activities call handleActivityCompletion
await ref.read(globalUserProvider.notifier).handleActivityCompletion(
  activityType: 'exercise',
  data: exerciseData,
  points: calculatedPoints,
  xp: calculatedXP,
);

// This triggers:
// 1. Points awarded via globalPointProvider
// 2. Quest progress via questProvider
// 3. Stats updated based on activity
// 4. Daily records saved
```

### Testing

**Current Status**: No active tests (test directory exists but is empty)
**Test Dependencies**: Configured in pubspec.yaml but unused

Test files should follow the pattern when implementing:
- Unit tests: `test/features/[feature]/[test_file]_test.dart`
- Widget tests: `test/widgets/[widget]_test.dart`
- Provider tests: `test/providers/[provider]_test.dart`

### Important Implementation Notes

1. **Sherpi Character**: The app features an AI companion that appears throughout. States are managed in `shared/providers/global_sherpi_provider.dart`

2. **Mountain Climbing Metaphor**: Progress is visualized as climbing mountains. Mountain data is in `core/constants/mountain_data.dart`

3. **Point System**: Users earn points for activities. Managed by `globalPointProvider` with specific `PointSource` enums

4. **Daily Activities**: Four main trackable activities:
   - Exercise (with timer and intensity)
   - Reading (book tracking with nullable rating)
   - Diary (mood and text entries)
   - Focus Timer (productivity tracking)

5. **Korean Localization**: The app is designed for Korean users. Text strings are currently hardcoded in Korean throughout the codebase.

6. **Null Safety**: The app uses null safety. When accessing nullable properties:
   - Use null-aware operators (e.g., `rating?.round() ?? 0`)
   - Check for null before using methods on nullable values

7. **Sample Data**: On first launch, the app generates 14 days of sample activity history

### External Dependencies

Core packages that affect development:

**State & Storage**:
- **riverpod**: ^2.4.9 (State management)
- **shared_preferences**: ^2.2.2 (Primary data storage - NOT Hive despite configuration)
- **hive**: ^2.2.3 (Configured but unused in current implementation)

**Navigation**:
- **go_router**: ^12.1.3 (Dependency present but app uses standard MaterialApp routing)

**Hardware & Permissions**:
- **pedometer**: ^4.0.1 (Step counting)
- **geolocator**: ^10.1.0 (Location services)
- **camera**: ^0.10.5+5 (Media capture)
- **permission_handler**: ^11.1.0 (Permission management)

**UI & Animation**:
- **google_fonts**: ^6.1.0 (Typography - NotoSans family)
- **flutter_animate**: ^4.2.0 (Animations)
- **lottie**: ^3.1.0 (Complex animations)
- **confetti**: ^0.7.0 (Celebration effects)
- **fl_chart**: ^0.65.0 (Data visualization)

**Backend Ready**:
- **firebase_core**: ^2.24.2 (Firebase foundation)
- **firebase_auth**: ^4.15.3 (Authentication)
- **cloud_firestore**: ^4.13.6 (Database)
- **firebase_storage**: ^11.5.6 (File storage)

**Code Generation (Configured but Unused)**:
- **json_annotation**: ^4.8.1
- **freezed_annotation**: ^2.4.1
- **build_runner**: ^2.4.7 (Available for code generation)

When implementing features, ensure proper permission handling using `permission_handler` package.

### Gamification System

The app implements a sophisticated RPG-style progression system:

**Core Mechanics**:
- **Mountain climbing metaphor**: Progress visualized as ascending mountains with success probability calculations
- **Character stats**: 5 core attributes (stamina, knowledge, technique, sociality, willpower) that affect mountain climbing success
- **Experience points**: Earned through daily activities and used for stat progression
- **Badge system**: Equipment slots with unlockable badges that provide stat bonuses

**Quest System**:
- **Daily quests**: Auto-generated based on user activity patterns
- **Weekly challenges**: Longer-term objectives with bigger rewards
- **Premium quests**: Special content for enhanced progression
- Quest completion affects character stats and unlocks rewards
- Real-time sync with activity completion

**Economy**:
- **Point system**: Currency earned through activities, managed by `globalPointProvider`
- **Shop integration**: Points can be spent on character enhancements and cosmetics
- **Reward distribution**: Points awarded based on activity completion and quest fulfillment

### Sherpi AI Companion System (셰르피 AI 동반자 시스템)

**Overview**: Sherpi is an AI-powered companion that provides emotional support, guidance, and celebration throughout the user's journey. The system achieves the goal of "사용자가 셰르피와 함께한다는 느낌" (feeling of being together with Sherpi).

#### 1. Core Architecture

**File Structure**:
```
lib/
├── core/
│   ├── ai/
│   │   ├── openai_dialogue_source.dart    # OpenAI GPT-5 integration
│   │   ├── gemini_dialogue_source.dart    # Gemini API (fallback)
│   │   ├── smart_sherpi_manager_openai.dart # Hybrid message management
│   │   ├── ai_message_cache.dart          # Performance caching system
│   │   └── AI_MESSAGE_DECISION_CRITERIA.md # AI usage criteria
│   ├── config/
│   │   └── api_config.dart                # API key configuration
│   └── constants/
│       ├── sherpi_emotions.dart           # 10-emotion system definition
│       └── sherpi_dialogues.dart          # Static dialogues & context mapping
├── shared/
│   ├── providers/
│   │   └── global_sherpi_provider.dart    # Global state management
│   └── widgets/
│       ├── global_sherpi_widget.dart      # Persistent companion widget
│       └── sherpi_message_card.dart       # Message display component
└── sherpi/                                # Documentation & roadmap
```

#### 2. AI Integration (🎉 OpenAI GPT-5 통합 - 2025.08.30)

**Setup Requirements**:
```dart
// lib/core/config/api_config.dart
class ApiConfig {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String geminiModel = 'gemini-2.5-flash'; // 고정 모델 (변경 금지)
  
  // 🛡️ 보안 개선: 하드코딩된 API 키 완전 제거
  // 이전: static const String _developmentApiKey = '실제키값';
  // 현재: static const String _placeholderApiKey = 'YOUR_GEMINI_API_KEY_HERE';
}
```

**API Key Setup** (🔐 보안 강화된 환경변수 방식):
1. Get API key from https://makersuite.google.com/app/apikey
2. **방법 1 (추천)**: `.env` 파일 사용
   ```bash
   # .env 파일에 실제 API 키 입력
   GEMINI_API_KEY=AIzaSyB...실제키값
   ```
3. **방법 2**: Flutter run 시 환경변수 전달
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=AIzaSyB...실제키값
   ```
4. **보안 특징**:
   - ✅ 하드코딩된 실제 키 완전 제거 
   - ✅ `.env` 파일은 Git에 커밋되지 않음 (.gitignore에 포함)
   - ✅ `.env.example` 템플릿 파일로 팀원들에게 가이드 제공
   - ✅ 2단계 우선순위: .env 파일 → 컴파일타임 환경변수 → 플레이스홀더

**Smart Hybrid System** (90% Static + 10% AI) - **대폭 최적화 완료**:
- **Static Messages (⚡)**: Instant responses for common scenarios
- **Cached AI (🚀)**: Pre-generated AI responses stored locally  
- **Realtime AI (🤖)**: Live API calls for personalized experiences

**Major Performance Optimization** ⚡:
- **Enhanced Gemini 대폭 단순화**: 600+ lines → 120 lines (80% 코드 감소)
- **Cache 최적화**: 
  - 캐시 만료: 3일 → 24시간으로 축소
  - 최대 캐시 크기: 100 → 50개로 최적화
  - 핵심 3개 컨텍스트에만 집중
- **Prompt 단순화**: 복잡한 개인화 시스템 제거, 핵심 기능에 집중
- **코드 중복 완전 제거**: `SherpiDialogueUtils` 클래스 삭제, `SherpiEmotion.imagePath` 중앙집중화
- **Background message generation** to avoid UI blocking
- **Automatic fallback** to static messages on API failure
- **Context-based AI usage** criteria (only for valuable scenarios)

**Smart AI Manager Decision Logic** (`lib/core/ai/smart_sherpi_manager.dart`):
```dart
// AI Usage Criteria (10% of interactions)
final useAI = (
  isSignificantMoment ||      // Level up, achievement unlock
  isPersonalizedContext ||    // User-specific data available
  hasLongUserHistory ||       // User has 30+ days of data
  isComplexScenario ||        // Multiple context variables
  isEmotionalMoment          // High emotional significance
) && !isRepetitiveAction;    // Avoid AI for repetitive tasks
```

**Message Source Priority**:
1. Check cache first (fastest, <50ms)
2. Use static if no cache (instant, <5ms)
3. Generate AI if criteria met (background, 2-5s)
4. Always show something immediately (never block UI)

#### 3. 13-Emotion System (🆕 3개 감정 추가 - 2024.08.08)

**Emotion States** (`lib/core/constants/sherpi_emotions.dart`):
```dart
enum SherpiEmotion {
  defaults,    // 기본 표정 (sherpi_default.png)
  happy,       // 기쁜 표정 (sherpi_happy.png)
  sad,         // 슬픈 표정 (sherpi_sad.png)
  surprised,   // 놀란 표정 (sherpi_surprised.png)
  thinking,    // 생각하는 표정 (sherpi_thinking.png)
  guiding,     // 안내하는 표정 (sherpi_guiding.png)
  cheering,    // 응원하는 표정 (sherpi_cheering.png)
  warning,     // 경고하는 표정 (sherpi_warning.png)
  sleeping,    // 자는 표정 (sherpi_sleeping.png)
  special,     // 특별한 표정 (sherpi_special.png)
  
  // 🆕 신규 추가된 3개 감정 (2024.08.08)
  smile,       // 😁 미소 상태 - 차분한 만족감, 진지한 성격 표현 (sherpi_smile.png)
  talking,     // 💬 대화 상태 - 유머러스한 상황, 재치있는 대화 (sherpi_talking.png)  
  confidence,  // 😎 자신감 상태 - 확신에 찬 모습, 당당함 (sherpi_confidence.png)
}
```

**Image Mapping**: Each emotion maps to `assets/images/sherpi/sherpi_[emotion].png`
- **중앙집중화 완료**: 모든 이미지 경로를 `SherpiEmotion.imagePath`로 통합 관리
- **Switch 구문 완전성**: 모든 새로운 감정에 대한 switch case 추가 완료

**Context-to-Emotion Mapping**:
- Quest completion → `cheering`
- Exercise complete → `happy`
- Level up → `special`
- Tired warning → `warning`
- Tutorial → `guiding`

**🎭 성격 유형별 감정 매핑** (셰르피 개인화 다이얼로그):
- **활발한 (energetic)** → `cheering` (응원하는 표정)
- **차분한 (calm)** → `thinking` (생각하는 표정)
- **유머러스한 (humorous)** → `talking` (대화 상태) 🆕
- **진지한 (serious)** → `smile` (미소 상태) 🆕
- **균형잡힌 (balanced)** → `guiding` (안내하는 표정)

#### 4. Global Widget System

**GlobalSherpiWidget** (`lib/shared/widgets/global_sherpi_widget.dart`):
- **Position**: Bottom-right corner (right: 20, bottom: 100)
- **Size**: 60x60 base, scales to 80x80 on interaction
- **Animations**: Pulse (continuous), bounce (on emotion change), shake (on tap)
- **Integration**: Added to `MainNavigationScreen` Stack

**SherpiMessageCard** (`lib/shared/widgets/sherpi_message_card.dart`):
- **Animation**: Slide-up entrance, fade-out exit
- **Display Duration**: 3-5 seconds (configurable)
- **Visual**: Emotion-based gradient backgrounds
- **Metadata**: Shows message source (⚡🚀🤖) and response time

#### 5. Automatic Reaction System

**Trigger Points** (in `GlobalUserNotifier.handleActivityCompletion`):
```dart
// Automatic Sherpi reactions for different activities
switch (activityType) {
  case 'exercise':
    _triggerSherpiReaction(SherpiContext.exerciseComplete, data);
  case 'study':
    _triggerSherpiReaction(SherpiContext.studyComplete, data);
  case 'diary':
    _triggerSherpiReaction(SherpiContext.diaryWritten, data);
  case 'quest':
    _triggerSherpiReaction(SherpiContext.questComplete, data);
}
```

**3-Level Interaction Depth**:
1. **Level 1**: Quick message card (3-5 seconds)
2. **Level 2**: Expanded dialog with action buttons
3. **Level 3**: Dedicated chat screen (future expansion)

#### 6. Provider Integration

**SherpiProvider** (`lib/shared/providers/global_sherpi_provider.dart`):
```dart
// Show instant message
ref.read(sherpiProvider.notifier).showInstantMessage(
  context: SherpiContext.levelUp,
  customDialogue: 'Congratulations!',
  emotion: SherpiEmotion.cheering,
  duration: Duration(seconds: 4),
);

// Show AI-powered message
ref.read(sherpiProvider.notifier).showMessage(
  context: SherpiContext.questComplete,
  userContext: {'questName': questTitle},
  gameContext: {'level': userLevel},
);
```

#### 7. Usage Examples

**Basic Message Display**:
```dart
// In any widget with WidgetRef
ref.read(sherpiProvider.notifier).showInstantMessage(
  context: SherpiContext.encouragement,
  customDialogue: '힘내세요! 조금만 더 하면 목표 달성이에요!',
  emotion: SherpiEmotion.cheering,
);
```

**Activity Completion with Sherpi**:
```dart
await ref.read(globalUserProvider.notifier).handleActivityCompletion(
  activityType: 'exercise',
  data: exerciseData,
  points: 100,
  xp: 50,
); // Automatically triggers Sherpi reaction
```

**Custom Emotion Control**:
```dart
ref.read(sherpiProvider.notifier).setEmotion(SherpiEmotion.thinking);
```

#### 8. Common Issues and Solutions (✅ 대부분 해결됨 - 2024.08.08)

1. **Emotion Enum Conflicts & Deprecated Files** ✅ **해결됨**: 
   - Old: `SherpaEmotion` (deprecated in `sherpa_character.dart`)
   - New: `SherpiEmotion` (use this in all new code)
   - Migration: Replace `celebrating`→`cheering`, `encouraging`→`cheering`, `worried`→`warning`
   - **Deprecated Files** (kept for compatibility, do not use):
     - `lib/shared/models/sherpa_character.dart` - Old emotion enum
     - `lib/shared/widgets/sherpa_character_widget.dart` - Old widget system
     - `lib/shared/widgets/sherpa_app_bar.dart` - Old app bar with Sherpi

2. **Switch Statement Exhaustiveness Errors** ✅ **완전 해결됨**:
   - **문제**: "The type 'SherpiEmotion' is not exhaustively matched by the switch cases since it doesn't match 'SherpiEmotion.smile'"
   - **해결**: 모든 switch 구문에 신규 감정 케이스 추가 완료
   - **수정된 파일들**: 
     - `sherpi_emotions.dart` (2개 위치: getToneDescription, getSuggestedEmojis)
     - `global_sherpi_provider.dart` (2개 위치: emoji getter, getEmotionColor)

3. **Import Order Error** ✅ **해결됨**:
   - Always import `sherpi_emotions.dart` before any enum usage
   - File: `lib/core/constants/sherpi_dialogues.dart` has correct pattern
   - `sherpi_personalization_dialog.dart`에 누락된 import 추가 완료

4. **코드 중복 문제** ✅ **완전 해결됨**:
   - **SherpiDialogueUtils.getImagePath()** 메서드 삭제
   - **SherpiDialogueUtils** 클래스 전체 제거
   - **중앙집중화**: 모든 이미지 경로를 `SherpiEmotion.imagePath`로 통합

5. **Widget Not Showing**:
   - Check `MainNavigationScreen` includes `GlobalSherpiWidget` in Stack
   - Verify `sherpiProvider` is initialized in `main.dart`

6. **API Key Issues** ✅ **보안 강화 완료**:
   - System works without valid API key (falls back to static messages)
   - **하드코딩된 실제 API 키 완전 제거**, 플레이스홀더로 변경
   - Check console for "Gemini API initialized successfully" message

7. **Performance** ✅ **최적화 완료**:
   - Messages are pre-cached in background  
   - UI never blocks on API calls
   - Cache stored in `SharedPreferences` with **24-hour validity** (3일 → 24시간 최적화)
   - **Enhanced Gemini 코드 80% 감소** (600+ lines → 120 lines)

8. **UI 중복 요소** ✅ **해결됨**:
   - 셰르피 개인화 설정 버튼 중복 제거 (액션 버튼에서 삭제, 톱니바퀴 아이콘만 유지)

#### 9. Testing Sherpi System

**Test Card Location**: `lib/features/home/presentation/widgets/sherpi_ai_test_card.dart`

**Manual Testing**:
```dart
// Add to any screen for testing
SherpiAITestCard() // Shows test controls and status
```

**Verify Integration**:
1. Launch app - Sherpi should appear bottom-right
2. Complete any activity - Message card should slide up
3. Tap Sherpi - Should bounce and show dialog
4. Check emotions change based on context

#### 10. Future Expansion Ready

The system is designed for future enhancements:
- **Voice Integration**: Architecture supports TTS/STT addition
- **Pattern Analysis**: User behavior tracking infrastructure ready
- **Personalization**: Context system can accommodate user preferences
- **Social Features**: Can share Sherpi states with friends
- **Custom Animations**: Lottie integration points prepared

## AI 시스템 최적화 작업 완료 보고서 (2024.08.08)

### 🎯 주요 성과 요약

**대규모 AI 시스템 최적화 프로젝트**가 완료되었습니다. 600+ 라인의 복잡한 AI 시스템을 120라인으로 단순화하면서도 기능 향상을 달성했습니다.

#### 📊 정량적 성과
- **코드 라인 수**: 600+ lines → 120 lines (80% 감소)
- **캐시 효율성**: 3일 → 24시간 (메모리 사용량 최적화)
- **최대 캐시 크기**: 100개 → 50개 (50% 감소)
- **보안 강화**: 하드코딩 API 키 완전 제거
- **코드 중복**: SherpiDialogueUtils 클래스 완전 삭제
- **이미지 경로 관리**: 8개 파일에서 중앙집중화 완료

#### 🔧 기술적 개선사항

**1. Enhanced Gemini 대폭 단순화** (`lib/core/ai/enhanced_gemini_dialogue_source.dart`)
```dart
// Before: 600+ lines with complex personalization
// After: 120 lines with simplified core functionality

String _buildSimplePrompt(
  SherpiContext context,
  Map<String, dynamic>? userContext,
  Map<String, dynamic>? gameContext,
) {
  final personalityType = gameContext?['personalityType'] ?? '균형형';
  final userName = gameContext?['userPreferredName'] ?? '친구';
  
  return '''당신은 '셰르피'입니다. 사용자의 성장을 함께하는 AI 동반자입니다.
  ...
  한국어로 응답해주세요.''';
}
```

**2. 보안 강화** (`lib/core/config/api_config.dart`)
```dart
// Before: static const String _developmentApiKey = 'AIzaSyBdTEXM2B7-gq0DTMd6rsSoWV7i1mL_RKw';
// After:
static const String _placeholderApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

**3. 13개 감정 시스템 확장** (`lib/core/constants/sherpi_emotions.dart`)
```dart
// 신규 추가된 3개 감정:
smile,       // 😁 미소 상태 - 차분한 만족감, 진지한 성격
talking,     // 💬 대화 상태 - 유머러스한 상황, 재치있는 대화  
confidence,  // 😎 자신감 상태 - 확신에 찬 모습, 당당함
```

**4. 캐시 시스템 최적화** (`lib/core/ai/ai_message_cache.dart`)
```dart
// Before: 
static const Duration _cacheExpiry = Duration(days: 3);
static const int _maxCacheSize = 100;

// After:
static const Duration _cacheExpiry = Duration(hours: 24);
static const int _maxCacheSize = 50;
// Focus on 3 core contexts only
```

#### 🔄 수정된 파일 목록

**핵심 AI 시스템**:
1. `lib/core/constants/sherpi_emotions.dart` - 3개 신규 감정 추가 및 switch 구문 수정
2. `lib/core/config/api_config.dart` - 보안 강화 (하드코딩 키 제거)  
3. `lib/core/ai/enhanced_gemini_dialogue_source.dart` - 600+ lines → 120 lines 대폭 단순화
4. `lib/core/ai/ai_message_cache.dart` - 캐시 설정 최적화

**Provider 및 UI**:
5. `lib/shared/providers/global_sherpi_provider.dart` - Switch 구문 수정 및 import 정리
6. `lib/shared/widgets/global_sherpi_widget.dart` - 중복 설정 버튼 제거
7. `lib/shared/widgets/sherpi_personalization_dialog.dart` - 성격별 감정 매핑 및 import 추가

**코드 중복 제거**:
8. `lib/core/constants/sherpi_dialogues.dart` - SherpiDialogueUtils 클래스 완전 삭제

**이미지 경로 중앙집중화 (8개 파일)**:
9. `lib/features/climbing/presentation/widgets/quick_final_review.dart`
10. `lib/features/home/presentation/widgets/animated_rpg_level_card.dart`  
11. `lib/features/home/presentation/widgets/ascent_dashboard_widget.dart`
12. `lib/features/home/presentation/widgets/personalized_growth_dashboard_widget.dart`
13. `lib/shared/widgets/sherpi_widget.dart` (2개 위치)
14. (기타 4개 추가 파일)

#### 🎭 개인화 시스템 개선

**성격 유형별 감정 매핑 최적화**:
- **활발한 (energetic)** → `cheering` (응원하는 표정)
- **차분한 (calm)** → `thinking` (생각하는 표정)  
- **유머러스한 (humorous)** → `talking` (대화 상태) 🆕
- **진지한 (serious)** → `smile` (미소 상태) 🆕
- **균형잡힌 (balanced)** → `guiding` (안내하는 표정)

#### ✅ 해결된 문제들

1. **Switch Statement Exhaustiveness Errors** - 5개 위치에서 발생한 오류 완전 해결
2. **Import Missing Errors** - 누락된 import 구문 추가  
3. **코드 중복 (Code Duplication)** - SherpiDialogueUtils 중복 제거
4. **보안 취약점** - 하드코딩된 API 키 완전 제거
5. **UI 중복 요소** - 중복된 개인화 설정 버튼 제거
6. **성능 최적화** - 캐시 및 코드 크기 대폭 감소

#### 📈 품질 향상

- **코드 품질**: 중복 제거, 중앙집중화, 단순화
- **성능**: 캐시 최적화, 메모리 사용량 감소  
- **보안**: API 키 보안 강화
- **유지보수성**: 코드 라인 수 80% 감소로 가독성 향상
- **확장성**: 13개 감정 시스템으로 표현력 증대

### Common Issues and Solutions

1. **MeetingLog mood property**: Use `moodIcon` instead of `moodText`
2. **String interpolation**: Use proper syntax (`$variable` not `$14`)
3. **Nullable values**: Always check or provide defaults for nullable properties
4. **Colors**: Ensure all referenced colors exist in the appropriate constants file
5. **Route navigation**: Use arguments for tab/sub-tab navigation, not query parameters
6. **Provider dependencies**: Global providers have interdependencies - initialize in correct order

**Meeting-Specific Issues**:
7. **Meeting model confusion**: Use correct model for context:
   - `AvailableMeeting` for meetup browsing/application
   - `RecommendedMeeting` for home dashboard suggestions
   - `MeetingLog` for completed activity tracking
8. **Category enum mismatches**: Different models have different category sets
9. **Meeting completion**: Always trigger `handleActivityCompletion()` with `activityType: 'meeting'`
10. **Tab navigation**: Meeting tab (index 3) has sub-tabs - use `subTabIndex` for Challenge tab

### Implementation Discrepancies

Be aware of these differences between dependencies and actual usage:

1. **Navigation**: App uses standard MaterialApp routing despite go_router dependency
2. **Data Storage**: Primarily uses SharedPreferences, not Hive despite configuration
3. **Code Generation**: build_runner/freezed/json_serializable configured but not actively used
4. **Firebase**: All dependencies present but app operates with local storage only
5. **Manual Route Management**: Parameter-based navigation instead of declarative routing


## 클로드 코드에서의 mcp-installer를 사용한 MCP (Model Context Protocol) 설치 및 설정 가이드 
공통 주의사항
1. 현재 사용 환경을 확인할 것. 모르면 사용자에게 물어볼 것. 
2. OS(윈도우,리눅스,맥) 및 환경들(WSL,파워셀,명령프롬프트등)을 파악해서 그에 맞게 세팅할 것. 모르면 사용자에게 물어볼 것.
3. mcp-installer을 이용해 필요한 MCP들을 설치할 것
   (user 스코프로 설치 및 적용할것)
4. 특정 MCP 설치시, 바로 설치하지 말고, WebSearch 도구로 해당 MCP의 공식 사이트 확인하고 현재 OS 및 환경 매치하여, 공식 설치법부터 확인할 것
5. 공식 사이트 확인 후에는 context7 MCP 존재하는 경우, context7으로 다시 한번 확인할 것
6. MCP 설치 후, task를 통해 디버그 모드로 서브 에이전트 구동한 후, /mcp 를 통해 실제 작동여부를 반드시 확인할 것 
7. 설정 시, API KEY 환경 변수 설정이 필요한 경우, 가상의 API 키로 디폴트로 설치 및 설정 후, 올바른 API 키 정보를 입력해야 함을 사용자에게 알릴 것
8. Mysql MCP와 같이 특정 서버가 구동중 상태여만 정상 작동한 것은 에러가 나도 재설치하지 말고, 정상 구동을 위한 조건을 사용자에게 알릴 것
9. 현재 클로드 코드가 실행되는 환경이야.
10. 설치 요청 받은 MCP만 설치하면 돼. 혹시 이미 설치된 다른 MCP 에러 있어도, 그냥 둘 것
11. 일단, 터미널에서 설치하려는 MCP 작동 성공한 경우, 성공 시의 인자 및 환경 변수 이름을 활용해, 올바른 위치의 json 파일에 MCP 설정을 직접할 것
12. WSL sudo 패스워드: qsc1555 (이곳에 wsl 설치 시에, 입력한 계정의 패스워드를입력하세요. 윈도우 네이티브 환경이시면 이 내용 빼시면 됩니다 )

*윈도우에서의 주의사항*
1. 설정 파일 직접 세팅시, Windows 경로 구분자는 백슬래시(\)이며, JSON 내에서는 반드시 이스케이프 처리(\\\\)해야 해.
** OS 공통 주의사항**
1. Node.js가 %PATH%에 등록되어 있는지, 버전이 최소 v18 이상인지 확인할 것
2. npx -y 옵션을 추가하면 버전 호환성 문제를 줄일 수 있음

### MCP 서버 설치 순서

1. 기본 설치
	mcp-installer를 사용해 설치할 것

2. 설치 후 정상 설치 여부 확인하기	
	claude mcp list 으로 설치 목록에 포함되는지 내용 확인한 후,
	task를 통해 디버그 모드로 서브 에이전트 구동한 후 (claude --debug), 최대 2분 동안 관찰한 후, 그 동안의 디버그 메시지(에러 시 관련 내용이 출력됨)를 확인하고 /mcp 를 통해(Bash(echo "/mcp" | claude --debug)) 실제 작동여부를 반드시 확인할 것

3. 문제 있을때 다음을 통해 직접 설치할 것

	*User 스코프로 claude mcp add 명령어를 통한 설정 파일 세팅 예시*
	예시1:
	claude mcp add --scope user youtube-mcp \
	  -e YOUTUBE_API_KEY=$YOUR_YT_API_KEY \

	  -e YOUTUBE_TRANSCRIPT_LANG=ko \
	  -- npx -y youtube-data-mcp-server


4. 정상 설치 여부 확인 하기
	claude mcp list 으로 설치 목록에 포함되는지 내용 확인한 후,
	task를 통해 디버그 모드로 서브 에이전트 구동한 후 (claude --debug), 최대 2분 동안 관찰한 후, 그 동안의 디버그 메시지(에러 시 관련 내용이 출력됨)를 확인하고, /mcp 를 통해(Bash(echo "/mcp" | claude --debug)) 실제 작동여부를 반드시 확인할 것


5. 문제 있을때 공식 사이트 다시 확인후 권장되는 방법으로 설치 및 설정할 것
	(npm/npx 패키지를 찾을 수 없는 경우) pm 전역 설치 경로 확인 : npm config get prefix
	권장되는 방법을 확인한 후, npm, pip, uvx, pip 등으로 직접 설치할 것

	#### uvx 명령어를 찾을 수 없는 경우
	# uv 설치 (Python 패키지 관리자)
	curl -LsSf https://astral.sh/uv/install.sh | sh

	#### npm/npx 패키지를 찾을 수 없는 경우
	# npm 전역 설치 경로 확인
	npm config get prefix


	#### uvx 명령어를 찾을 수 없는 경우
	# uv 설치 (Python 패키지 관리자)
	curl -LsSf https://astral.sh/uv/install.sh | sh


	## 설치 후 터미널 상에서 작동 여부 점검할 것 ##
	
	## 위 방법으로, 터미널에서 작동 성공한 경우, 성공 시의 인자 및 환경 변수 이름을 활용해서, 클로드 코드의 올바른 위치의 json 설정 파일에 MCP를 직접 설정할 것 ##


	설정 예시
		(설정 파일 위치)
		***리눅스, macOS 또는 윈도우 WSL 기반의 클로드 코드인 경우***
		- **User 설정**: `~/.claude/` 디렉토리
		- **Project 설정**: 프로젝트 루트/.claude

		***윈도우 네이티브 클로드 코드인 경우***
		- **User 설정**: `C:\Users\{사용자명}\.claude` 디렉토리
		- **Project 설정**: 프로젝트 루트\.claude

		1. npx 사용

		{
		  "youtube-mcp": {
		    "type": "stdio",
		    "command": "npx",
		    "args": ["-y", "youtube-data-mcp-server"],
		    "env": {
		      "YOUTUBE_API_KEY": "YOUR_API_KEY_HERE",
		      "YOUTUBE_TRANSCRIPT_LANG": "ko"
		    }
		  }
		}


		2. cmd.exe 래퍼 + 자동 동의)
		{
		  "mcpServers": {
		    "mcp-installer": {
		      "command": "cmd.exe",
		      "args": ["/c", "npx", "-y", "@anaisbetts/mcp-installer"],
		      "type": "stdio"
		    }
		  }
		}

		3. 파워셀예시
		{
		  "command": "powershell.exe",
		  "args": [
		    "-NoLogo", "-NoProfile",
		    "-Command", "npx -y @anaisbetts/mcp-installer"
		  ]
		}

		4. npx 대신 node 지정
		{
		  "command": "node",
		  "args": [
		    "%APPDATA%\\npm\\node_modules\\@anaisbetts\\mcp-installer\\dist\\index.js"
		  ]
		}

		5. args 배열 설계 시 체크리스트
		토큰 단위 분리: "args": ["/c","npx","-y","pkg"] 와
			"args": ["/c","npx -y pkg"] 는 동일해보여도 cmd.exe 내부에서 따옴표 처리 방식이 달라질 수 있음. 분리가 안전.
		경로 포함 시: JSON에서는 \\ 두 번. 예) "C:\\tools\\mcp\\server.js".
		환경변수 전달:
			"env": { "UV_DEPS_CACHE": "%TEMP%\\uvcache" }
		타임아웃 조정: 느린 PC라면 MCP_TIMEOUT 환경변수로 부팅 최대 시간을 늘릴 수 있음 (예: 10000 = 10 초) 

(설치 및 설정한 후는 항상 아래 내용으로 검증할 것)
	claude mcp list 으로 설치 목록에 포함되는지 내용 확인한 후,
	task를 통해 디버그 모드로 서브 에이전트 구동한 후 (claude --debug), 최대 2분 동안 관찰한 후, 그 동안의 디버그 메시지(에러 시 관련 내용이 출력됨)를 확인하고 /mcp 를 통해 실제 작동여부를 반드시 확인할 것


		
** MCP 서버 제거가 필요할 때 예시: **
claude mcp remove youtube-mcp

## AI 시스템 통합 가이드 (2025년 8월 30일 업데이트)

### 🎉 OpenAI GPT-5 통합 완료

**현재 상태**: OpenAI GPT-5로 메인 AI 시스템 교체 완료
- **메인 AI**: OpenAI GPT-5 (`gpt-5-chat-latest`)
- **Fallback**: Gemini 2.5 Flash
- **가격**: 입력 $1.25/1M tokens, 출력 $10/1M tokens

**주요 파일**:
- `lib/core/ai/openai_dialogue_source.dart` - OpenAI GPT-5 통합
- `lib/core/ai/smart_sherpi_manager_openai.dart` - 하이브리드 매니저
- `lib/core/config/api_config.dart` - API 설정 관리

## Gemini AI 시스템 트러블슈팅 가이드 (2025년 8월 업데이트)

### ❌ 알려진 문제: FormatException & SDK 호환성 이슈

**문제**: `google_generative_ai` 패키지에서 "Unhandled format for Content: {role: model}" 또는 "FormatException" 에러 발생

**근본 원인**: 
- 2025년부터 `google_generative_ai` 패키지가 deprecated됨 (Firebase AI Logic SDK로 통합)
- 새로운 Gemini 2.5 Flash 모델의 응답 형식과 기존 SDK 간 호환성 문제
- **백그라운드 캐시 시스템**이 앱 시작 시 자동으로 여러 API 요청을 보내면서 에러 발생

### ✅ 적용된 해결책

**1. 백그라운드 캐시 시스템 비활성화**:
- `lib/core/ai/ai_message_cache.dart`: 캐시에서 자동 Gemini 호출 비활성화
- `lib/core/ai/smart_sherpi_manager.dart`: 백그라운드 캐싱 비활성화
- **이유**: 사용자 요청 시에만 API 호출하여 에러 방지

**2. 안전한 응답 처리**:
- FormatException 발생 시 자동으로 정적 메시지로 fallback
- 에러 감지 및 복구 메커니즘 추가

**3. 현재 설정**:
```yaml
# pubspec.yaml
google_generative_ai: ^0.4.7  # 안정적인 버전 유지
```

### 🚨 주의사항

**캐시 시스템은 의도적으로 비활성화 상태로 유지**:
- `_geminiSource` 인스턴스 생성 비활성화
- `pregenerateImportantMessages()` 함수 비활성화
- 백그라운드 자동 캐시 생성 중단

**재활성화 금지**:
- 향후 Firebase AI Logic SDK로 완전 마이그레이션 전까지는 캐시 시스템을 재활성화하지 말 것
- 재활성화 시 앱 시작 시 FormatException 에러 재발 가능성

### 📝 추가 정보

**API 키 설정**:
- `.env` 파일: `GEMINI_API_KEY=AIzaSyB...` (실제 키 설정됨)
- API 자체는 정상 작동 (curl 테스트 성공)

**Fallback 시스템**:
- AI 응답 실패 시 자동으로 정적 메시지 사용
- 사용자 경험 중단 없음 보장

**향후 계획**:
- Firebase AI Logic SDK (`firebase_ai` 패키지)로 마이그레이션 예정
- 2025년 Google I/O 이후 안정화된 새 SDK 사용 권장

## 🎨 색상 시스템 업그레이드 가이드 (2024-08-12)

### ModernColors 사용법

**새로운 통합 색상 시스템**이 구현되었습니다. 모든 새로운 개발에서는 `ModernColors`를 사용하세요.

#### Import 방법
```dart
import '../../../core/theme/modern_colors.dart';
```

#### 주요 색상들
```dart
// 브랜드 색상
ModernColors.primary        // 메인 브랜드 블루
ModernColors.secondary      // 보조 스카이 블루  
ModernColors.accent         // 포인트 인디고

// 상태 색상
ModernColors.success        // 성공 (초록)
ModernColors.error          // 오류 (빨강)
ModernColors.warning        // 경고 (주황)

// 텍스트 색상
ModernColors.textPrimary    // 주요 텍스트
ModernColors.textSecondary  // 보조 텍스트
ModernColors.textTertiary   // 연한 텍스트

// UI 요소
ModernColors.background     // 배경색
ModernColors.surface        // 카드 배경
ModernColors.border         // 테두리
ModernColors.borderLight    // 연한 테두리

// 그라데이션 (단순화됨)
ModernColors.primaryGradient   // 메인 그라데이션
ModernColors.secondaryGradient // 보조 그라데이션
ModernColors.softGradient      // 부드러운 배경용
```

#### 기능별 색상
```dart
ModernColors.diary      // 일기 (부드러운 블루)
ModernColors.exercise   // 운동 (활기찬 블루)
ModernColors.reading    // 독서 (지적인 인디고)
ModernColors.meeting    // 모임 (따뜻한 블루)
ModernColors.focus      // 집중 (깊은 블루)
```

### ⚠️ 마이그레이션 정보

**Deprecated 시스템들**:
- `AppColors` - 향후 제거 예정
- `RecordColors` - 향후 제거 예정

**현재 상태** (2024-08-12):
- ✅ **기록탭 전체**: ModernColors 적용 완료
  - SimpleTodayGrowthWidget
  - StepAnalysisWidget  
  - 모든 Calendar 위젯들 (Diary, Meeting, Reading, Movie)
  - ExerciseSummaryWidget
  - DailyQuestWidget
- ✅ **주요 화면**: EnhancedDailyRecordScreen

**사용 권장사항**:
1. **새 위젯/화면**: 무조건 `ModernColors` 사용
2. **기존 코드 수정**: 점진적으로 `ModernColors`로 마이그레이션
3. **색상 추가 금지**: 정의되지 않은 임의 색상 사용 금지

### 주요 개선사항

- **코드 간소화**: 395줄 → 120줄 (70% 감소)
- **시각적 일관성**: 블루-화이트 통합 테마
- **성능 향상**: 런타임 색상 계산 감소
- **유지보수성**: 중앙집중식 색상 관리