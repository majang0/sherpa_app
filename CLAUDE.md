# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Repository**: https://github.com/majang0/sherpa_app

## Overview

Sherpa App (셰르파) is a sophisticated Flutter-based mobile application that gamifies personal growth through a mountain climbing metaphor. The app encourages users to achieve daily goals, connect with others, and track their progress through an advanced RPG-style system with complex cross-feature integrations and real-time data synchronization.

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

### Core Architecture Pattern: Feature-First with Complex Integration

The app follows a sophisticated feature-first architecture where each feature is self-contained but integrates through global providers and shared systems:

```
lib/
├── core/           # App-wide constants, theme, utilities
│   ├── constants/  # app_colors.dart, game_constants.dart, mountain_data.dart, sherpi_dialogues.dart
│   ├── theme/      # app_theme.dart (Material 3 implementation)
│   └── utils/      # Utility functions and helpers
├── features/       # Feature modules with varying complexity levels
│   ├── climbing/   # Basic: models, presentation, providers
│   ├── daily_record/ # Complex: constants, models, presentation, providers, services, utils, widgets
│   ├── home/       # Basic: models, presentation, providers  
│   ├── meetings/   # Basic: models, presentation, providers
│   ├── quests/     # Complex: constants, data, models, presentation, providers, services, utils
│   ├── shop/       # Minimal: presentation only
│   └── [others]/   # Varying complexity based on feature requirements
├── shared/         # Cross-feature shared components and systems
│   ├── constants/  # global_badge_data.dart
│   ├── models/     # Cross-feature data models (8 core models)
│   ├── providers/  # Global state management (11 core providers)
│   ├── utils/      # Shared utility functions
│   └── widgets/    # Reusable UI components (12 shared widgets)
├── main.dart       # Entry point with global provider initialization and routes
└── main_navigation_screen.dart  # Bottom navigation and tab management
```

### Feature Implementation Patterns

**Complex Features** (daily_record, quests):
- 7 directories: constants, models, presentation, providers, services, utils, widgets/data
- Feature-specific color constants
- Dedicated service layers
- Comprehensive widget libraries

**Standard Features** (climbing, home, meetings):
- 3 directories: models, presentation, providers
- Standard provider-based state management
- Presentation layer with screens and widgets

**Minimal Features** (shop):
- 1 directory: presentation only
- Lightweight implementation
- Dependent on shared systems

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

### Global Data Integration Patterns

The app implements sophisticated cross-provider communication and real-time synchronization:

#### Global Provider Architecture (11 Core Providers)
- **globalGameProvider**: Core game mechanics and calculations
- **globalUserProvider**: Central user data and activity completion handling
- **globalPointProvider**: Currency system with PointSource categorization
- **globalUserTitleProvider**: Achievements and progression titles
- **globalBadgeProvider**: Equipment system with stat bonuses
- **globalClimbingProvider**: Mountain climbing mechanics
- **globalCommunityProvider**: Social features and interactions
- **globalMeetingProvider**: Meetup coordination and management
- **globalChallengeProvider**: Challenge system
- **questProviderV2**: Quest management with auto-sync
- **sherpiProvider**: AI companion with context-aware dialogue

#### Unified Activity Completion Flow
All activities follow a standardized completion pattern through `GlobalUserNotifier.handleActivityCompletion()`:

```dart
await ref.read(globalUserProvider.notifier).handleActivityCompletion(
  activityType: 'exercise',  // Standard activity types: exercise, reading, diary, meeting, climbing, quest
  xp: calculatedXP,          // Experience points for leveling
  points: calculatedPoints,  // Currency for shop purchases
  statIncreases: {           // Character stat modifications
    'stamina': 0.2,
    'knowledge': 0.1,
  },
  message: 'Activity completed!',
  additionalData: {          // Activity-specific metadata
    'duration': 30,
    'category': 'fitness',
  },
);
```

**This triggers cascade effects**:
1. **XP & Leveling**: addExperience() → potential levelUp() → levelUp rewards via globalPointProvider
2. **Points**: PointSource-categorized point attribution via globalPointProvider
3. **Stats**: increaseStats() with stat caps (max 100.0)
4. **Quest Sync**: _notifyQuestSystem() for real-time quest progress
5. **Sherpi Feedback**: Context-aware companion messages
6. **Daily Goals**: Real-time goal completion checking via _updateGoalStatusBasedOnActivity()

#### Data Storage Strategy
- **Primary**: SharedPreferences for all persistent data
- **Configuration**: Hive configured but unused in current implementation
- **Development Behavior**: App clears SharedPreferences on startup for testing
- **Sample Data**: 14-day activity history generated on first launch

### Key Features and Their Responsibilities

- **climbing**: Core gamification engine (mountains, badges, stats)
- **daily_record**: Activity tracking (exercise, reading, diary, focus timer)
- **meetings**: Social meetup coordination
- **quests**: Daily challenges and objectives
- **community**: Social features and interactions
- **home**: Main dashboard aggregating all features
- **profile**: User profile and growth tracking
- **shop**: Point spending and rewards
- **wallet**: Financial transactions and payment features

### Navigation

Uses standard MaterialApp routing with a route table in `main.dart`:

**Main Navigation Structure**:
- Bottom navigation with 5 tabs: Home, Level Up, Quest, Meeting, Profile
- Quest and Meeting tabs have nested sub-tabs
- Tab navigation managed by `MainNavigationScreen`

**Key Routes**:
- `/`: Main navigation screen with bottom tabs
- `/daily_record`, `/diary_record`, `/exercise_record`, `/reading_record`: Activity tracking
- `/meeting_detail`, `/meeting_application`, `/meeting_success`, `/meeting_review`: Meeting flow
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

### Firebase Integration

The app is configured for Firebase services but currently uses local storage:
- Dependencies: `firebase_auth`, `cloud_firestore`, `firebase_storage`
- **Current storage**: SharedPreferences and Hive for local data persistence
- Firebase configuration files need to be added for each platform before Firebase features will work
- **Note**: App currently clears all data on startup (development behavior)

### UI/UX Patterns & Design System

#### Theme Architecture
- **Theme System**: Material 3 with custom theming in `core/theme/app_theme.dart`
- **Design Language**: Mountain climbing metaphor with blue-based color palette
- **Typography**: NotoSans font family for Korean localization
- **Border Radius**: Consistent 12px/16px pattern throughout
- **Animations**: Heavy use of Lottie, flutter_animate, and confetti for gamification

#### Color System Architecture
The app implements a comprehensive dual-layer color system:

**Primary Layer: AppColors** (`core/constants/app_colors.dart`)
- **Brand Colors**: Deep blue primary (#2563EB), sky blue secondary (#0EA5E9)
- **Activity Categories**: Each activity type has dedicated colors
  - Climbing: Blue (#2563EB) - main brand alignment
  - Reading: Purple (#8B5CF6) - knowledge association
  - Meeting: Cyan (#06B6D4) - social connection
  - Exercise: Red (#EF4444) - energy and intensity
  - Focus: Purple (#8B5CF6) - concentration
  - Diary: Pink (#EC4899) - personal reflection
- **State Colors**: Success (green), warning (orange), error (red), info (blue)
- **Level System**: Color progression for user levels (beginner → expert)
- **Gradients**: 8 predefined gradients for visual effects
- **Utility Methods**: `getCategoryColor()`, `getLevelColor()`, adaptive color support

**Secondary Layer: RecordColors** (`features/daily_record/constants/record_colors.dart`)
- Subset of AppColors focused on daily record features
- Alias system: `typedef RecordColors = AppColors;`
- Feature-specific color constants for backward compatibility

#### Shared Widget Library (12 Core Components)
- **SherpaCleanAppBar**: Standard app bar (no titleStyle parameter)
- **SherpaButton**: Animated button with haptic feedback
- **SherpaCard**: Consistent card styling with elevation
- **SherpaCharacterWidget**: AI companion display component
- **PointDisplayWidget**: Currency display with animations
- **AnimatedProgressWidget**: Progress indicators with smooth transitions
- **DailyMotivationWidget**: Motivational content display
- **RotatingIconWidget**: Animated icon components
- **[Others]**: Specialized components for specific use cases

#### Character System: Sherpi AI Companion
- **Multiple Emotional States**: Happy, encouraging, celebrating, thinking
- **Context-Aware Dialogue**: Responds to user progress and activities
- **Visual Integration**: Character widget with emotional expressions
- **State Management**: Managed by `sherpiProvider` with cross-feature synchronization

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

### Advanced Gamification System

The app implements a sophisticated RPG-style progression system with complex mathematical formulas and real-time calculations:

#### Core Mechanics & Calculations

**Character Stats System** (5 core attributes, 0-100 range):
- **Stamina**: Physical endurance, affects climbing power
- **Knowledge**: Mental acuity, affects climbing power and reading benefits
- **Technique**: Skill mastery, affects climbing power and exercise efficiency
- **Sociality**: Social skills, affects meeting benefits and climbing time reduction (up to 10% faster)
- **Willpower**: Mental strength, affects success probability (+10% max bonus)

**Climbing Power Formula** (`core/constants/game_constants.dart`):
```
Final Power = Base Power × (1 + Stats Bonus) × (1 + Badge Bonus)
Where:
- Base Power = (Level × 10) + Title Bonus
- Stats Bonus = (Stamina + Knowledge + Technique) / 100
- Badge Bonus = Sum of equipped badge effects / 100
```

**Success Probability Calculation**:
- Power ratio-based probability with exponential curves
- Willpower bonus: (Willpower / 100) × 0.1
- Badge bonuses for success rate improvements
- Capped at 5% minimum, 95% maximum for balance

#### Level & Experience System

**Experience Formula**: `(Level^1.5 × 40) + (Level × 20)` per level
**Title Progression**:
- Lv 1-9: "초보 등반가" (Novice Climber) - 0 bonus
- Lv 10-19: "숙련된 등반가" (Adept Climber) - 50 bonus
- Lv 20-29: "전문 산악인" (Expert Mountaineer) - 120 bonus
- Lv 30-39: "셰르파" (Sherpa) - 250 bonus
- Lv 40-49: "마스터 셰르파" (Master Sherpa) - 400 bonus
- Lv 50+: "전설의 셰르파" (Legendary Sherpa) - 600 bonus

#### Badge System & Equipment
- **Equipment Slots**: 1-4 based on level (increases every 10 levels)
- **Badge Categories**: Power multipliers, success rate bonuses, time reduction, special effects
- **Real-time Effect Application**: All calculations use actual equipped badge data
- **Badge Acquisition**: Level milestones, mountain conquests, special achievements

#### Mountain System & Regions

**Regional Difficulty Scaling**:
- **초심자의 언덕** (Novice Hills, Lv 1-9): Linear scaling
- **한국의 명산** (Korean Mountains, Lv 10-49): Progressive scaling
- **아시아의 지붕** (Roof of Asia, Lv 50-99): Exponential scaling
- **세계의 정상** (World Peaks, Lv 100-199): Advanced exponential
- **신들의 산맥** (Divine Peaks, Lv 200+): Ultimate challenge

**Reward System**:
- **Success Rewards**: XP (exponential decay formula), Points, Stat increases
- **Failure Rewards**: 25% of success XP for learning
- **Hidden Treasures**: 5-20% chance for bonus rewards based on difficulty + level + badges
- **Special Mountain Rewards**: Legendary badges for conquering iconic peaks

#### Quest System V2

**Auto-Generation**: Real-time quest creation based on user activity patterns
**Difficulty Scaling**: Easy/Medium/Hard with proportional rewards
**Real-time Sync**: Automatic progress tracking via `_notifyQuestSystem()`
**Reward Categories**: XP, points, stat increases, badge unlocks

#### Economy & Point System

**PointSource Categories**:
- Meeting attendance/hosting, daily goal completion, quest rewards
- Ad watching, streak bonuses, special achievements
- Categorized point attribution for analytics and balance

**AI Companion (Sherpi) Integration**:
- **Context-Aware Dialogue**: 200+ dialogue variations in `sherpi_dialogues.dart`
- **Emotional State Management**: Happy, encouraging, celebrating, thinking states
- **Activity Response**: Real-time feedback on user actions and achievements
- **Cross-Feature Presence**: Available throughout app with state synchronization

### Critical Implementation Notes

#### Korean Localization & Cultural Adaptation
- **Target Market**: Korean users with Korean-first design principles
- **Text Hardcoding**: All Korean text is hardcoded throughout the codebase (no i18n system)
- **Cultural Context**: Mountain climbing metaphor resonates with Korean hiking culture
- **Font System**: NotoSans family specifically chosen for Korean character support
- **Dialogue System**: Sherpi uses casual/friendly Korean (반말/존댓말 mix)

#### Development & Data Management
- **Development Mode**: App clears SharedPreferences on startup for testing
- **Sample Data Generation**: 14-day activity history created on first launch
- **Provider Dependencies**: Strict initialization order required (6 global providers)
- **Real-time Sync**: All activities trigger immediate cross-provider updates
- **Null Safety**: Comprehensive null safety with defensive programming patterns

#### Performance & Architecture Considerations
- **State Management**: Riverpod StateNotifierProvider pattern for complex state
- **Memory Management**: Efficient provider lifecycle management
- **Animation Performance**: Heavy use of Lottie and flutter_animate (monitor performance)
- **Cross-Feature Communication**: Complex provider interdependencies require careful management

#### Technology Stack Discrepancies
- **Navigation**: Standard MaterialApp routing despite go_router dependency
- **Storage**: SharedPreferences primary storage despite Hive configuration
- **Code Generation**: build_runner/freezed configured but unused
- **Firebase**: All dependencies present but local storage only
- **Testing**: Test dependencies configured but no active tests

#### Widget & Color Usage Patterns
- **SherpaCleanAppBar**: No titleStyle parameter (common mistake)
- **Color Constants**: Use AppColors for general features, RecordColors for daily_record
- **Route Navigation**: Use arguments for tab navigation, not query parameters
- **Nullable Properties**: Always check nullability (e.g., `rating?.round() ?? 0`)

### Common Issues and Solutions

1. **MeetingLog mood property**: Use `moodIcon` instead of `moodText`
2. **String interpolation**: Use proper syntax (`$variable` not `$14`)
3. **Nullable values**: Always check or provide defaults for nullable properties
4. **Colors**: Ensure all referenced colors exist in the appropriate constants file
5. **Route navigation**: Use arguments for tab/sub-tab navigation, not query parameters
6. **Provider dependencies**: Global providers have interdependencies - initialize in correct order

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