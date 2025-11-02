# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 📱 Overview

Sherpa App (셰르파) is a Flutter-based mobile application that gamifies personal growth through a mountain climbing metaphor. Users achieve daily goals, connect with others, and track progress through an RPG-style system.

- **Platform**: iOS/Android
- **Framework**: Flutter 3.27.0+
- **State Management**: Riverpod 2.4.9
- **Architecture**: Feature-First
- **Design Philosophy**: Clean · Modern · Emotional

---

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

---

## 🏗️ Architecture

### Directory Structure

```
lib/
├── core/           # Constants, theme, utilities
├── features/       # Feature modules (self-contained)
│   ├── activities_diary/       # Diary activity (6 files: 2 screens, 1 model, 3 widgets)
│   ├── activities_exercise/    # Exercise activity (13 files: 5 screens, 1 model, 5 widgets + 2 shared utils)
│   ├── activities_focus/       # Focus timer (3 files: 1 screen, 1 model, 1 widget)
│   ├── activities_meeting_logs/# Meeting logs (3 files: 2 screens, 1 widget)
│   ├── activities_movie/       # Movie activity (5 files: 3 screens, 2 widgets)
│   ├── activities_reading/     # Reading activity (6 files: 2 screens, 3 widgets, 1 util)
│   ├── daily_record/           # Daily record navigation hub (imports all activity widgets)
│   ├── meetings/               # Meeting discovery & management
│   ├── quests/                 # Quest system
│   ├── sherpi/                 # AI companion
│   └── ...                     # Other features
├── shared/         # Shared components, providers, models
├── main.dart       # Entry point, provider init, routes
└── main_navigation_screen.dart  # Bottom navigation
```

**Feature Architecture** (Phase 3 Refactoring - 2025-11-02):
- **Activity Features**: 6 self-contained modules extracted from `daily_record`
  - Each feature follows consistent structure: `models/`, `presentation/screens/`, `presentation/widgets/`, `utils/` (optional)
  - Total: 36 files (34 migrated + 2 shared utils) with preserved git history
- **Navigation Hub**: `daily_record/` serves as central navigation importing activity widgets
- **Import Pattern**: All use absolute `package:sherpa_app/` paths (98% compliance per CLAUDE.md standards)

### State Management (Riverpod 2.4.9)

**⚠️ CRITICAL: Provider Initialization Order (1 → 9)**

```dart
// lib/main.dart - _initializeGlobalProviders()
// Initialize in this EXACT order to prevent dependency crashes

// 1. Game System (foundation data)
ref.read(globalGameProvider);

// 2-4. User Data
ref.read(globalUserProvider);
ref.read(globalPointProvider);
ref.read(globalUserTitleProvider);

// 5-6. Feature Systems
ref.read(questProviderV2);           // ⚠️ IMPORTANT: V2, not questProvider
ref.read(globalMeetingProvider);

// 7-9. AI & Relationships
ref.read(sherpiProvider);
ref.read(relationshipProvider);
ref.read(emotionAnalysisProvider);
```

**Provider Initialization Groups**:

| Group | Providers | Purpose |
|-------|-----------|---------|
| **1** | globalGameProvider | Foundation data |
| **2-4** | globalUserProvider, globalPointProvider, globalUserTitleProvider | User state |
| **5-6** | questProviderV2, globalMeetingProvider | Features |
| **7-9** | sherpiProvider, relationshipProvider, emotionAnalysisProvider | AI & Advanced |

**⚠️ Note on Dependencies**:
- Some providers have circular dependencies (e.g., `globalUserProvider` ↔ `questProviderV2`)
- This is safe due to Riverpod's lazy loading - dependencies are resolved at runtime only when accessed
- The initialization order ensures all providers are registered before any cross-references occur

**Rules**:
- ❌ **NEVER** change initialization order
- ❌ **NEVER** use legacy `questProvider` (always `questProviderV2`)
- ✅ **ALWAYS** initialize in sequence 1→9

**See**: `.claude/agents/state-management-guard.md` for automatic validation

---

### Navigation

**Bottom Navigation**: 5 tabs managed by `MainNavigationScreen`
- Home (index 0)
- Level Up (index 1)
- Quest (index 2) - Has sub-tabs
- Meeting (index 3) - Has sub-tabs
- Profile (index 4)

**Safe Navigation Pattern** (ID-based arguments):

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

**Main Routes** (verified 2025-11-02):

| Route | Arguments Schema | Example |
|-------|-----------------|---------|
| `/` | `int` or `Map` | `2` or `{'tabIndex': 3, 'subTabIndex': 1}` |
| `/meeting_detail` | `{'meetingId': String}` | `{'meetingId': 'abc123'}` |
| `/daily_record` | (none) | - |

---

## 💡 Core Features

### Meeting System

**Three Model Architecture**:
1. **AvailableMeeting**: Core meeting entity (6 categories)
2. **AIRecommendedMeeting**: AI-powered suggestions with GPS
3. **MeetingLog**: Completed activity records

**Meeting Flow**:
Browse → Detail → Apply → Process → Success → Participate → Review → Rewards

**⚠️ Important**: Always use correct model for context (enums differ)

---

### Quest System

**Quest Types**:
- Daily quests: Auto-generated based on activity patterns
- Weekly challenges: Long-term objectives
- Premium quests: Enhanced content

**🚨 CRITICAL PRODUCTION WARNING**:

Quest data currently resets on **every app start** (development convenience):

```dart
// lib/features/quests/providers/quest_provider_v2.dart (Line 54-69)
// 🗑️ TODO: Add kDebugMode guard before production deployment
await prefs.remove('saved_quests_v2');
await prefs.remove('premium_quest_active_v2');
await prefs.remove('last_daily_generated_v2');
await prefs.remove('last_weekly_generated_v2');
```

**ACTION REQUIRED**: Wrap with `if (kDebugMode) { ... }` before release

---

### Gamification

- **Mountain Climbing**: Progress visualization with success probability
- **Character Stats**: 5 attributes affecting climb success
- **Badge System**: Equipment slots with stat bonuses
- **Point Economy**: Currency for enhancements and rewards

---

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

**Activity Types & Timing**:
- `'meeting_review'`: After review submission
- `'meeting_host'`: When host completes meeting
- `'meeting_participant'`: When participant completes meeting
- `'exercise'`, `'reading'`, `'diary'`: After completion

---

## 🎨 UI/UX Patterns

### Design Philosophy (2025 Material Design 3)

**Core Principles**:
- **Exaggerated Minimalism**: Generous spacing (16-24px)
- **Glass Morphism**: Translucent backgrounds with blur
- **Bottom Navigation**: Ergonomic 5-tab pattern
- **Emotional Connection**: Sherpi AI companion with 13 emotions

---

### Color System

**✅ USE: ModernColors (for ALL new development)**

```dart
import 'package:sherpa_app/core/theme/modern_colors.dart';

// Functional colors: diary, exercise, reading, focus, meeting, climbing, quest
// Emotion colors: joy, calm, thought, courage (4 levels: pastel, light, medium, bright)
// Premium shadows: premiumShadow(primaryColor, lightColor)

// See: lib/core/theme/modern_colors.dart for complete color palette
```

**❌ LEGACY (REMOVED - DO NOT USE)**:
- `AppColors.*` - ❌ **Deleted** (Wave 5, 2025-11-02)
- `RecordColors.*` - ❌ **Deleted** (Wave 5, 2025-11-02)

**✅ Migration Complete** (2025-11-02):
- **All 423 legacy color instances** migrated to ModernColors
- **Files deleted**:
  - `lib/core/constants/app_colors.dart` ❌
  - `lib/features/daily_record/constants/record_colors.dart` ❌
- **Status**: Codebase now uses ModernColors exclusively (100%)
- **Commits**: a4c76bc, 8b366ef, 62d3c39

**Automated Validation**: ui-design-validator Agent (auto-activates on UI file changes)

---

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
  style: SherpaButtonStyle.primary,  // or secondary, outline, text
)

// Card with premium shadows
SherpaCard(
  child: /* content */,
)
```

**Widget Locations**:
- `lib/shared/widgets/sherpa_clean_app_bar.dart`
- `lib/shared/widgets/sherpa_button.dart`
- `lib/shared/widgets/sherpa_card.dart`

---

### Sherpi AI Companion

> 최신 Sherpi 시스템 레퍼런스: `docs/sherpi_system.md`

**Overview**: Dual-system AI companion with static messages for floating notifications and AI-powered analysis for user-initiated insights

**System Architecture**:

1. **Static Message System** (Floating Messages)
   - Used for: All floating notifications (level up, quest completion, encouragement, etc.)
   - Source: Pre-written dialogues from `sherpi_dialogues.dart`
   - Manager: `UnifiedSherpiManager` (AI disabled by default)
   - Performance: Instant display, no API calls
   - Cost: Free

2. **AI Analysis System** (User-Initiated Only)
   - Used for: Deep analysis when user explicitly requests insights
   - Source: OpenAI GPT-5 API (`gpt-5-chat-latest`)
   - Features: AI insights, recommendations, growth plans
   - Cost: 30 points per analysis
   - Fallback: Returns basic analysis if AI unavailable
   - **See**: AI Analysis System section below for details

**Key Files** (updated 2025-11-01):
- `core/ai/managers/unified_sherpi_manager.dart` - Static message orchestration
- `core/ai/managers/sherpi_message_manager.dart` - Message interface
- `features/sherpi/analysis/services/ai_insight_generator.dart` - AI-powered analysis
- `core/ai/sources/openai_dialogue_source.dart` - OpenAI GPT-5 integration
- `shared/providers/global_sherpi_provider.dart` - State management
- `core/constants/sherpi_emotions.dart` - 13 emotion definitions

**13 Sherpi Emotions**: defaults, happy, sad, surprised, thinking, guiding, cheering, warning, sleeping, special, smile, talking, confidence

**See**: `lib/core/constants/sherpi_emotions.dart` for definitions

**Emotion-Context Compatibility Matrix**:

| Context | Recommended Emotions | Avoid |
|---------|---------------------|-------|
| levelUp, badgeEarned, questComplete | cheering, happy, confidence | sad, warning |
| climbingFailure, setback | sad (empathy), smile (comfort) | cheering, happy |
| encouragement, support | smile, guiding | sad, warning |
| warning, caution | warning, thinking | cheering, happy |
| rest, nighttime | sleeping | cheering |

**Static Message APIs**:

```dart
// Display pre-written floating message (no AI)
ref.read(sherpiProvider.notifier).showInstantMessage(
  context: SherpiContext.levelUp,
  customDialogue: 'Congratulations!',
  emotion: SherpiEmotion.cheering,
  duration: const Duration(seconds: 3),
);

// Context-aware static message
showMessage(context, userContext, gameContext)

// Game-specific static messages
showGameMessage(context, gameData)

// Hide current message
hideMessage()

// Change emotion state
changeEmotion(SherpiEmotion emotion)
```

**⚠️ Important**:
- Floating messages = Always static (no AI API calls)
- AI analysis = User-initiated only (costs 30 points)
- Always match emotion to context (validated by ui-design-validator Agent)

---

## 🧠 AI Analysis System

Sherpa App integrates **OpenAI GPT-5** for deep user analysis when explicitly requested by the user.

### OpenAI GPT-5 Integration

**Model**: `gpt-5-chat-latest`
**Package**: openai_dart ^0.5.4
**API Key**: Set via `OPENAI_API_KEY` environment variable

**When AI is Used**:
- ✅ User initiates "Today's Analysis" or similar analysis features
- ✅ User requests personalized insights
- ✅ User requests growth plan generation
- ❌ NOT used for floating messages (always static)
- ❌ NOT used automatically in background

### AI Features

**1. AI Insights** (`generateAIInsights`)
- Analyzes user activity patterns, mood, performance metrics
- Generates personalized insights using GPT-5
- Combines AI insights with basic statistical analysis
- Returns top 8 insights sorted by importance
- Cost: 30 points

**2. AI Recommendations** (`generateAIRecommendations`)
- Creates personalized growth recommendations
- Identifies weak areas and suggests improvements
- Leverages user's strengths for motivation
- Returns top 6 recommendations sorted by priority
- Cost: 30 points

**3. Smart Growth Plan** (`generateSmartGrowthPlan`)
- Generates 4-week personalized growth roadmap
- Adapts to user's current level and patterns
- Includes weekly milestones and action items
- Cost: 30 points

### Fallback Mechanism

**If AI fails** (API error, invalid key, network issues):
- Automatically falls back to basic analysis
- Returns statistical insights without AI enhancement
- Refunds points if AI generation fails
- User experience remains functional

### Key Files

- `features/sherpi/analysis/services/ai_insight_generator.dart` - Main AI analysis engine
- `core/ai/sources/openai_dialogue_source.dart` - OpenAI GPT-5 API wrapper
- `core/config/api_config.dart` - API key configuration
- `features/sherpi/analysis/services/user_data_analyzer.dart` - Statistical analysis (non-AI)

### Usage Example

```dart
// User initiates analysis (costs 30 points)
final generator = AiInsightGenerator(ref: ref);

// Generate AI-powered insights
final insights = await generator.generateAIInsights(
  user,
  analysisResult,
);

// Generate AI recommendations
final recommendations = await generator.generateAIRecommendations(
  user,
  analysisResult,
);

// Generate growth plan
final growthPlan = await generator.generateSmartGrowthPlan(
  user,
  analysisResult,
);
```

**⚠️ Important**:
- Requires valid `OPENAI_API_KEY` in environment
- Each analysis costs 30 points (deducted before API call)
- Points refunded automatically if AI generation fails
- Fallback to basic analysis ensures functionality

---

## 🤖 Automated Validation (Agents)

Sherpa App은 파일 저장 시 **자동 검증 Agent**를 실행합니다.

### Active Agents (6개)

**Meta-Agents** (최우선):
- **routing-orchestrator**: 🎯 모든 요청 자동 분석 → 최적 Skill/Agent 라우팅 (복잡도, 도메인 분석)

**Validators** (파일 저장 시 자동):
- **ui-design-validator**: UI 파일 저장 시 → 디자인 시스템, Sherpi 감정, 접근성 검증
- **state-management-guard**: Provider 파일 저장 시 → 초기화 순서, questProviderV2, 순환 의존성 검증
- **code-quality-validator**: 코드 파일 변경 시 → 아키텍처, dead code, code smells 검증

**Utilities** (수동 호출):
- **documentation-specialist**: 문서 생성 및 자연어 처리
- **agent-creator**: 새 Agent 생성 (`"[도메인] 검증 에이전트 만들어줘"`)

### ⚠️ Important

**🚨 필수 호출 규칙** (최우선):
- **모든 사용자 요청** → routing-orchestrator에게 먼저 의견 물어야 함
- routing-orchestrator가 복잡도 분석 후 최적 Skill/Agent 추천
- 추천 결과에 따라 작업 진행 (Role 1~6 또는 다른 Agent)
- **예외 없음**: 단순 요청도 routing-orchestrator 분석 거쳐야 함

**파일 저장 습관화**:
- 구현 후 반드시 파일 저장 → Agent 자동 검증 트리거

**Agent 경고 즉시 대응**:
- ⚠️ **Provider 관련**: 앱 크래시 위험 (Level 0→1→2→3 순서, questProviderV2 only)
- ⚠️ **색상 관련**: 디자인 일관성 (ModernColors only, 레거시 AppColors/RecordColors 금지)
- ⚠️ **Sherpi 감정**: 맥락-감정 불일치 (예: climbingFailure에 cheering 사용)

### 📚 References

- **Agent 상세**: `.claude/agents/` 디렉토리 (각 Agent의 검증 규칙)
- **사용 가이드**: `.claude/INTEGRATION_GUIDE.md` (Skills vs Agents 결정 트리)
- **Usage 예시**: `.claude/knowledge_base/agent_usage_guide.md`

---

## 🎓 SKILL System (Manual Deep Analysis)

For complex analysis beyond automated Agents, use **SKILL system** (Sonnet-based):

```bash
# Example usage
"role6로 [화면명] 디자인 검토해줘"
"role4로 새 Provider 추가 시 Level 분석해줘"
```

**Available SKILLS**:
- **Role 4**: State Management Expert (Provider architecture, dependencies)
- **Role 6**: UI/UX Design Expert (design systems, accessibility, user flow)

**See**: `.claude/skills/` directory for SKILL definitions

---

## ⚠️ Important Notes

### General Issues

1. **Nullable Values**: Always provide defaults
   ```dart
   rating?.round() ?? 0
   ```

2. **Korean Localization**: Text hardcoded in Korean throughout

3. **Sample Data**: 14 days of sample history generated on first launch

4. **Provider Dependencies**: Initialize in exact order (see State Management section)

---

### Meeting-Specific Issues

- Use correct model for context (AvailableMeeting vs AIRecommendedMeeting vs MeetingLog)
- Category enums differ between models
- Meeting tab (index 3) has sub-tabs - use `subTabIndex`

---

### Implementation Discrepancies

| Dependency | Status | Note |
|------------|--------|------|
| go_router | Present but unused | App uses MaterialApp routing |
| hive | Configured but unused | SharedPreferences used instead |
| build_runner | Available | Use for code generation when needed |
| Firebase | Dependencies present | Local storage only, needs config files |

---

## 📦 Key Dependencies

**State & Storage**: riverpod, shared_preferences (NOT Hive)
**UI & Animation**: flutter_animate, lottie, confetti, fl_chart
**Hardware & Permissions**: pedometer, geolocator, camera, permission_handler
**AI Integration**: openai_dart (GPT-5), google_generative_ai (Gemini), flutter_dotenv (environment variables)
**Maps**: google_maps_flutter, geocoding

**⚠️ IMPORTANT**: Always handle permissions properly when using hardware features

**See**: `pubspec.yaml` for complete dependency list and versions

---

## 🔧 Development Workflow

### Adding New Features

1. Create feature module in `features/[feature_name]/`
2. Follow existing patterns for models, providers, presentation
3. **If adding global provider**: Update initialization order in `main.dart` (maintain Level hierarchy)
4. Use `ModernColors` for styling
5. Test navigation with ID-based arguments
6. **Run Agents**: Save file to trigger automatic validation

---

### Common Tasks

**Update app package name**:
```bash
flutter pub run change_app_package_name:main com.new.package.name
```

**Generate code with freezed/json_serializable**:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

### Testing Checklist

- [ ] Provider initialization order maintained (Level 0→1→2→3)
- [ ] Navigation uses IDs, not objects
- [ ] ModernColors used for new UI (no AppColors/RecordColors)
- [ ] Sherpi emotion matches context
- [ ] Activity completion triggers proper flow
- [ ] Quest progress updates correctly
- [ ] Debug-only code wrapped in `kDebugMode`
- [ ] Agents validation passed (check console)

---

## 🚫 Things NOT to Do

**NEVER**:
- ❌ Change Provider initialization order
- ❌ Use legacy `questProvider` (always `questProviderV2`)
- ❌ Use legacy colors (AppColors, RecordColors)
- ❌ Pass complex objects in Navigator arguments
- ❌ Create circular Provider dependencies
- ❌ Commit API keys to git
- ❌ Deploy with Quest reset code active

---

## 🔒 Protected Areas

**DO NOT MODIFY** without team approval:
- `lib/main.dart` - Provider initialization order
- `lib/core/theme/modern_colors.dart` - Design system foundation
- `lib/shared/providers/global_*_provider.dart` - Core state management
- `.claude/agents/*.md` - Agent configurations

---

## 🔗 Additional Resources

**Documentation**: See `docs/` directory (sherpi_system.md, MCP_SETUP.md, AI_SYSTEM.md)
**Project Reports**: See `project/` directory (validation reports, integration guides, REVISED_AGENT_INTEGRATION_STRATEGY.md)
**Agent Configs**: See `.claude/agents/` directory (5 agents: agent-creator, ui-design-validator, state-management-guard, code-quality-validator, documentation-specialist)
**Knowledge Base**: See `.claude/knowledge_base/` directory (7 files: domain rules, agent registry, usage guide)
**Integration Guide**: See `.claude/INTEGRATION_GUIDE.md` (Skills vs Agents decision tree, 5 scenarios, best practices)

### Quick References

- **Provider init**: `lib/main.dart:207-240` (_initializeGlobalProviders)
- **Routes**: `lib/main.dart:127-200` (routes Map)
- **Quest reset**: `lib/features/quests/providers/quest_provider_v2.dart:54-69`
- **Colors**: `lib/core/theme/modern_colors.dart`
- **Sherpi emotions**: `lib/core/constants/sherpi_emotions.dart`
- **Sherpi provider**: `lib/shared/providers/global_sherpi_provider.dart`
- **Integration Guide**: `.claude/INTEGRATION_GUIDE.md` (Skills vs Agents decision tree)

### Environment Setup

**AI API Keys Configuration**:

Sherpa App requires API keys for AI features. Configure them via `.env` file or build-time arguments.

**Option 1: .env File** (Recommended for development):

```bash
# 1. Create .env file in project root
# C:\sherpa_app\.env

OPENAI_API_KEY=your_openai_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
```

```bash
# 2. Run app (flutter_dotenv loads .env automatically)
flutter run
```

**Option 2: Build-time Arguments** (For production):

```bash
# Development
flutter run --dart-define=OPENAI_API_KEY=your_key --dart-define=GEMINI_API_KEY=your_key

# Production (use secrets manager, never commit keys)
flutter build apk --dart-define=OPENAI_API_KEY=@secret@ --dart-define=GEMINI_API_KEY=@secret@
```

**API Key Priority** (highest to lowest):
1. Build-time `--dart-define`
2. `.env` file (loaded by flutter_dotenv)
3. Placeholder (app will use fallback features)

**⚠️ CRITICAL**:
- ❌ **NEVER** commit `.env` file to git
- ❌ **NEVER** hardcode API keys in source code
- ✅ Add `.env` to `.gitignore` (already configured)
- ✅ Use placeholder values for testing without API keys

**See**: `core/config/api_config.dart` for API key loading logic

---

## 📊 Document Metadata

**Document Version**: 3.4.0
**Last Updated**: 2025-11-02
**Maintained for**: Claude Code (claude.ai/code)
**Review Cycle**: Monthly (recommended)

**Last Verified**: 2025-11-02
**Verification Status**: ✅ Simplified for practical code work guidance
**AI System**: ✅ Verified dual-system architecture (static + GPT-5)
**Color System**: ✅ ModernColors migration complete (Wave 5)
**Feature Architecture**: ✅ Phase 3 refactoring complete - 6 activity features extracted (36 files)
**Accuracy**: 96% (core architecture + AI integration + color system + feature refactoring documented)
