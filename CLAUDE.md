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
  - App-wide colors in `core/constants/app_colors.dart`
  - Feature-specific colors (e.g., `features/daily_record/constants/record_colors.dart`)
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
  backgroundColor: RecordColors.background,
  actions: [...],
)
```

2. **Color Constants**:
- Use `RecordColors` for daily record features
- Use `AppColors` for general app features
- `RecordColors.secondary` available for secondary UI elements

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
│   │   ├── gemini_dialogue_source.dart    # Gemini API integration
│   │   ├── smart_sherpi_manager.dart      # Hybrid message management
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

#### 2. Gemini AI Integration

**Setup Requirements**:
```dart
// lib/core/config/api_config.dart
class ApiConfig {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String geminiModel = 'gemini-2.0-flash-exp'; // Latest model
}
```

**API Key Setup**:
1. Get API key from https://makersuite.google.com/app/apikey
2. Replace `YOUR_GEMINI_API_KEY` in `api_config.dart`
3. The system will work with placeholder messages if API key is invalid

**Smart Hybrid System** (90% Static + 10% AI):
- **Static Messages (⚡)**: Instant responses for common scenarios
- **Cached AI (🚀)**: Pre-generated AI responses stored locally
- **Realtime AI (🤖)**: Live API calls for personalized experiences

**Performance Optimization**:
- Background message generation to avoid UI blocking
- 24-hour cache validity for AI responses
- Automatic fallback to static messages on API failure
- Context-based AI usage criteria (only for valuable scenarios)

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

#### 3. 10-Emotion System

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
  special      // 특별한 표정 (sherpi_special.png)
}
```

**Image Mapping**: Each emotion maps to `assets/images/sherpi/sherpi_[emotion].png`

**Context-to-Emotion Mapping**:
- Quest completion → `cheering`
- Exercise complete → `happy`
- Level up → `special`
- Tired warning → `warning`
- Tutorial → `guiding`

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

#### 8. Common Issues and Solutions

1. **Emotion Enum Conflicts & Deprecated Files**: 
   - Old: `SherpaEmotion` (deprecated in `sherpa_character.dart`)
   - New: `SherpiEmotion` (use this in all new code)
   - Migration: Replace `celebrating`→`cheering`, `encouraging`→`cheering`, `worried`→`warning`
   - **Deprecated Files** (kept for compatibility, do not use):
     - `lib/shared/models/sherpa_character.dart` - Old emotion enum
     - `lib/shared/widgets/sherpa_character_widget.dart` - Old widget system
     - `lib/shared/widgets/sherpa_app_bar.dart` - Old app bar with Sherpi

2. **Import Order Error**:
   - Always import `sherpi_emotions.dart` before any enum usage
   - File: `lib/core/constants/sherpi_dialogues.dart` has correct pattern

3. **Widget Not Showing**:
   - Check `MainNavigationScreen` includes `GlobalSherpiWidget` in Stack
   - Verify `sherpiProvider` is initialized in `main.dart`

4. **API Key Issues**:
   - System works without valid API key (falls back to static messages)
   - Check console for "Gemini API initialized successfully" message

5. **Performance**:
   - Messages are pre-cached in background
   - UI never blocks on API calls
   - Cache stored in `SharedPreferences` with 24-hour validity

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