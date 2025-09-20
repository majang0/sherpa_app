# Appendix B: AI System Details

> **참고**: 최신 Sherpi 구조 및 아키텍처는 `docs/sherpi_system.md`에서 관리됩니다. 본 문서는 역사적 레퍼런스로 유지됩니다.

## Sherpi AI Companion System - Complete Documentation

### System Architecture

```
lib/
├── core/
│   ├── ai/
│   │   ├── cache/
│   │   │   └── ai_message_cache.dart            # Performance caching system
│   │   ├── managers/
│   │   │   ├── sherpi_message_manager.dart      # Base DI contract
│   │   │   ├── static_sherpi_manager.dart       # Static-only implementation
│   │   │   └── openai_sherpi_manager.dart       # Hybrid message management
│   │   ├── sources/
│   │   │   ├── openai_dialogue_source.dart      # OpenAI GPT-5 integration
│   │   │   └── enhanced_gemini_dialogue_source.dart # Gemini API (fallback)
│   │   ├── services/
│   │   │   ├── activity_prompt_templates.dart   # Prompt builders
│   │   │   └── real_data_connector.dart         # Context builders
│   │   └── AI_MESSAGE_DECISION_CRITERIA.md  # AI usage criteria
│   ├── config/
│   │   └── api_config.dart                  # API key configuration
│   └── constants/
│       ├── sherpi_emotions.dart             # 13-emotion system
│       └── sherpi_dialogues.dart            # Static dialogues
├── shared/
│   ├── providers/
│   │   └── global_sherpi_provider.dart      # Global state management
│   └── widgets/
│       ├── global_sherpi_widget.dart        # Persistent companion widget
│       └── sherpi_message_card.dart         # Message display component
└── sherpi/                                  # Documentation & roadmap
```

### AI Integration Status (2025.08.30)

**Current Mode**: Manual AI activation only

- **Default**: 100% static messages from `sherpi_dialogues.dart`
- **AI Calls**: Only when explicitly requested by user
- **Primary AI**: OpenAI GPT-5 (`gpt-5-chat-latest`)
- **Fallback AI**: Gemini 2.5 Flash
- **Pricing**: Input $1.25/1M tokens, Output $10/1M tokens

### 13-Emotion System

```dart
enum SherpiEmotion {
  defaults,    // Default expression
  happy,       // Happy
  sad,         // Sad
  surprised,   // Surprised
  thinking,    // Thinking
  guiding,     // Guiding
  cheering,    // Cheering
  warning,     // Warning
  sleeping,    // Sleeping
  special,     // Special
  smile,       // Smile (calm satisfaction)
  talking,     // Talking (humorous)
  confidence,  // Confidence (assured)
}
```

Each emotion maps to: `assets/images/sherpi/sherpi_[emotion].png`

### API Configuration

#### Environment Variables Setup

**Method 1: .env file (Recommended)**
```bash
# .env file
GEMINI_API_KEY=AIzaSyB...actualkey
OPENAI_API_KEY=sk-...actualkey
```

**Method 2: Runtime arguments**
```bash
flutter run --dart-define=GEMINI_API_KEY=your_key
flutter run --dart-define=OPENAI_API_KEY=your_key
```

### Manual AI Activation

```dart
// Method 1: Enable for next message only
void enableAIForNextMessage() {
  _useAIManually = true;
}

// Method 2: Force AI for specific message
Future<SherpiResponse> getMessageWithAI(
  context, 
  userContext, 
  gameContext
) {
  // Direct AI call
}
```

### Message Priority System

1. Check cache first (<50ms)
2. Use static if no cache (<5ms)
3. Generate AI if manually activated (2-5s)
4. Always show something immediately (never block UI)

### Widget Configuration

**GlobalSherpiWidget**:
- Position: Bottom-right (right: 20, bottom: 100)
- Base size: 60x60
- Expanded size: 80x80 on interaction
- Animations: Pulse, bounce, shake

**SherpiMessageCard**:
- Display duration: 3-5 seconds
- Animation: Slide-up entrance, fade-out exit
- Metadata: Source indicator (⚡🚀🤖)

### Automatic Reactions

```dart
// In GlobalUserNotifier.handleActivityCompletion
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

### Context-to-Emotion Mapping

- Quest completion → `cheering`
- Exercise complete → `happy`
- Level up → `special`
- Tired warning → `warning`
- Tutorial → `guiding`

### Performance Optimizations

- **Code reduction**: 600+ lines → 120 lines (80% reduction)
- **Cache optimization**: 24-hour validity, 50 item max
- **Prompt simplification**: Focus on core features only
- **Background generation**: Never blocks UI
- **Automatic fallback**: Always falls back to static on error

### Known Issues & Solutions

#### Gemini SDK Compatibility
- **Issue**: FormatException with Gemini 2.5 Flash
- **Solution**: Background caching disabled
- **Status**: Awaiting Firebase AI Logic SDK migration

#### API Key Security
- Never hardcode keys in source
- Use environment variables or .env files
- .env files are gitignored by default

### Testing Sherpi

**Test Card**: `lib/features/home/presentation/widgets/sherpi_ai_test_card.dart`

```dart
// Add to any screen for testing
SherpiAITestCard()
```

**Verification Steps**:
1. Launch app - Sherpi appears bottom-right
2. Complete activity - Message card slides up
3. Tap Sherpi - Bounces and shows dialog
4. Emotions change based on context

### Future Expansion Ready

- **Voice Integration**: TTS/STT architecture prepared
- **Pattern Analysis**: User behavior tracking ready
- **Personalization**: Context system expandable
- **Social Features**: Shareable Sherpi states
- **Custom Animations**: Lottie integration points

### Important Notes

- **DO NOT** re-enable background caching until SDK migration
- **DO NOT** use deprecated emotion enums (SherpaEmotion)
- **ALWAYS** check for null API responses
- **ALWAYS** provide static fallback messages

---

**Related**: Return to [CLAUDE.md](../CLAUDE.md)
