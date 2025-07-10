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

**AI Companion (Sherpi)**:
- Context-aware dialogue system with multiple emotional states
- Responds to user progress and provides encouragement/guidance
- Managed by `sherpiProvider` with state synchronization across features

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