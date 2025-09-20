# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📱 Overview

Sherpa App (셰르파) is a Flutter-based mobile application that gamifies personal growth through a mountain climbing metaphor. Users achieve daily goals, connect with others, and track progress through an RPG-style system.

- **Platform**: iOS/Android
- **Framework**: Flutter 3.27.0+
- **State Management**: Riverpod 2.4.9
- **Architecture**: Feature-First

## 🚀 Quick Start

### Essential Commands
```bash
# Development
flutter pub get              # Install dependencies
flutter run                  # Run app
flutter analyze              # Check code issues
dart format lib              # Format code

# Build
flutter build apk            # Android APK
flutter build ios            # iOS (macOS required)

# Code Generation
flutter pub run build_runner build --delete-conflicting-outputs  # Generate code
flutter pub run flutter_launcher_icons                          # Generate icons

# Testing
flutter test                 # Run all tests
flutter test --coverage      # With coverage
```

## 🏗️ Architecture

### Directory Structure
```
lib/
├── core/           # Constants, theme, utilities
├── features/       # Feature modules (self-contained)
├── shared/         # Shared components, providers, models
├── main.dart       # Entry point, provider init, routes
└── main_navigation_screen.dart  # Bottom navigation
```

### State Management (Riverpod)

**Provider Initialization Order**:
```dart
// Initialize in this exact order to prevent dependencies issues
ref.read(globalGameProvider);
ref.read(globalUserProvider);
ref.read(globalPointProvider);
ref.read(globalUserTitleProvider);
ref.read(questProviderV2);           // Note: V2, not questProvider
ref.read(globalMeetingProvider);
ref.read(sherpiProvider);
ref.read(relationshipProvider);
ref.read(emotionAnalysisProvider);
```

### Navigation

**Bottom Navigation**: 5 tabs managed by `MainNavigationScreen`
- Home (index 0)
- Level Up (index 1)
- Quest (index 2) - Has sub-tabs
- Meeting (index 3) - Has sub-tabs
- Profile (index 4)

**Safe Navigation Pattern**:
```dart
// ✅ CORRECT: Pass only serializable data (IDs)
Navigator.pushNamed(context, '/meeting_detail', 
  arguments: {'meetingId': meeting.id});

// ❌ AVOID: Complex objects (breaks web/deeplinks)
Navigator.pushNamed(context, '/meeting_detail', 
  arguments: meetingModel);  // Don't do this

// In target screen, fetch data by ID
final args = ModalRoute.of(context)!.settings.arguments as Map;
final meetingId = args['meetingId'];
```

**Tab Navigation with Sub-tabs**:
```dart
// Navigate to specific sub-tab
Navigator.pushNamed(context, '/', arguments: {
  'tabIndex': 3,        // Meeting tab
  'subTabIndex': 1,     // Applications sub-tab
});
```

**Main Route Arguments**:
| Route | Arguments Schema | Example |
|-------|-----------------|---------|
| `/` | `int` or `Map` | `2` or `{'tabIndex': 3, 'subTabIndex': 1}` |
| `/meeting_detail` | `{'meetingId': String}` | `{'meetingId': 'abc123'}` |
| `/daily_record` | `{'date': String?}` | `{'date': '2025-09-08'}` |
| `/levelup` | None | - |

## 💡 Core Features

### Meeting System

**Three Model Architecture**:
1. **AvailableMeeting**: Core meeting entity (6 categories)
2. **RecommendedMeeting**: AI-powered suggestions with GPS
3. **MeetingLog**: Completed activity records

**Meeting Flow**:
Browse → Detail → Apply → Process → Success → Participate → Review → Rewards

### Quest System

**Quest Types**:
- Daily quests: Auto-generated based on activity patterns
- Weekly challenges: Long-term objectives
- Premium quests: Enhanced content

**⚠️ Important**: Quest data currently resets on every app start (development convenience):
```dart
// lib/features/quests/providers/quest_provider_v2.dart
// TODO: Add kDebugMode guard before production deployment
await prefs.remove('saved_quests_v2');
await prefs.remove('premium_quest_active_v2');
await prefs.remove('last_daily_generated_v2');
await prefs.remove('last_weekly_generated_v2');
```
**Production Note**: Wrap with `if (kDebugMode) { ... }` before release

### Gamification

- **Mountain Climbing**: Progress visualization with success probability
- **Character Stats**: 5 attributes affecting climb success
- **Badge System**: Equipment slots with stat bonuses
- **Point Economy**: Currency for enhancements and rewards

### Activity Completion Flow

All activities use unified completion:
```dart
await ref.read(globalUserProvider.notifier).handleActivityCompletion(
  activityType: 'exercise',  // or 'reading', 'diary', 'meeting'
  data: activityData,
  points: calculatedPoints,
  xp: calculatedXP,
);
// Automatically triggers: points, quest progress, stats update, records save
```

## 🎨 UI/UX Patterns

### Color System

**Use ModernColors for all new development**:
```dart
import 'package:sherpa_app/core/theme/modern_colors.dart';

ModernColors.primary      // Main brand blue
ModernColors.success      // Success green
ModernColors.background   // Background color
```
**Legacy** (compatibility only): `AppColors`, `RecordColors` - do not use in new code

### Common Widgets

```dart
// Standard app bar
SherpaCleanAppBar(
  title: 'Page Title',
  backgroundColor: ModernColors.background,
  actions: [...],
)

// Animated button with haptic feedback
SherpaButton(
  text: 'Continue',
  onPressed: () {},
)
```

### Sherpi AI Companion

> 최신 Sherpi 시스템 레퍼런스: `docs/sherpi_system.md`

**Overview**: Static message-based AI companion (manual AI mode by default)

**Key Files**:
- `core/ai/managers/openai_sherpi_manager.dart` - Hybrid message management
- `core/ai/managers/static_sherpi_manager.dart` - Static fallback implementation
- `shared/providers/global_sherpi_provider.dart` - State management

**Available APIs**:
```dart
// Static message display (instant, no AI)
showInstantMessage(context, customDialogue, emotion, duration)

// Context-aware message (uses static or AI based on internal logic)
showMessage(context, userContext, gameContext)

// Game-specific messages
showGameMessage(context, gameData)

// Hide current message
hideMessage()

// Change emotion state
changeEmotion(SherpiEmotion emotion)
```

**Common Usage**:
```dart
ref.read(sherpiProvider.notifier).showInstantMessage(
  context: SherpiContext.levelUp,
  customDialogue: 'Congratulations!',
  emotion: SherpiEmotion.cheering,
);
```

**Note**: Background caching disabled due to Gemini SDK compatibility issues

## ⚠️ Important Notes

### General Issues

1. **Nullable Values**: Always provide defaults
   ```dart
   rating?.round() ?? 0
   ```

2. **Korean Localization**: Text hardcoded in Korean throughout

3. **Sample Data**: 14 days of sample history generated on first launch

4. **Provider Dependencies**: Initialize in exact order (see State Management section)

### Meeting-Specific Issues

- Use correct model for context (AvailableMeeting vs RecommendedMeeting vs MeetingLog)
- Category enums differ between models
- Meeting tab (index 3) has sub-tabs - use `subTabIndex`

**Activity Completion Timing**:
- `'meeting_review'`: After review submission
- `'meeting_host'`: When host completes meeting
- `'meeting_participant'`: When participant completes meeting

### Implementation Discrepancies

| Dependency | Status | Note |
|------------|--------|------|
| go_router | Present but unused | App uses MaterialApp routing |
| hive | Configured but unused | SharedPreferences used instead |
| build_runner | Available | Use for code generation when needed |
| Firebase | Dependencies present | Local storage only, needs config files |

## 📦 Key Dependencies

### State & Storage
- **riverpod**: ^2.4.9 - State management
- **shared_preferences**: ^2.2.2 - Primary storage (NOT Hive)

### UI & Animation
- **flutter_animate**: ^4.2.0 - Animations
- **lottie**: ^3.1.0 - Complex animations
- **confetti**: ^0.7.0 - Celebrations
- **fl_chart**: ^0.65.0 - Data visualization

### Hardware & Permissions
- **pedometer**: ^4.0.1 - Step counting
- **geolocator**: ^10.1.0 - Location
- **camera**: ^0.10.5+5 - Media capture
- **permission_handler**: ^11.1.0 - Permissions

Always handle permissions properly when using hardware features.

## 🔧 Development Workflow

### Adding New Features

1. Create feature module in `features/[feature_name]/`
2. Follow existing patterns for models, providers, presentation
3. Update provider initialization if adding global provider
4. Use `ModernColors` for styling
5. Test navigation with ID-based arguments

### Common Tasks

**Update app package name**:
```bash
flutter pub run change_app_package_name:main com.new.package.name
```

**Generate code with freezed/json_serializable**:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing Checklist

- [ ] Provider initialization order maintained
- [ ] Navigation uses IDs, not objects
- [ ] ModernColors used for new UI
- [ ] Activity completion triggers proper flow
- [ ] Quest progress updates correctly
- [ ] Debug-only code wrapped in `kDebugMode`

## 🔗 Additional Resources

### Appendices

For detailed information on specific topics:

- **Appendix A**: MCP Server Setup Guide → See `docs/MCP_SETUP.md`
- **Appendix B**: AI System Details → See `docs/AI_SYSTEM.md`
- **Appendix C**: Collective Intelligence with Codex → Use `codex exec` for cross-validation

### Quick References

- **Provider init**: `lib/main.dart` (initialization section)
- **Routes**: `lib/main.dart` (routes Map)
- **Quest reset**: `lib/features/quests/providers/quest_provider_v2.dart`
- **Colors**: `lib/core/theme/modern_colors.dart`
- **Sherpi**: `lib/shared/providers/global_sherpi_provider.dart`

### Environment Setup

For API keys and environment variables:
```bash
# Development
flutter run --dart-define=GEMINI_API_KEY=your_key

# Production (never commit keys)
flutter build apk --dart-define=OPENAI_API_KEY=@secret@
```

---

**Document Version**: 2.0.0  
**Last Updated**: 2025-09-08  
**Maintained for**: Claude Code (claude.ai/code)
