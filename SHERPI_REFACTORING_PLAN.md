# 🏔️ Sherpi System Refactoring Plan

## 📋 Executive Summary
Complete restructuring of the Sherpi AI companion system to resolve circular dependencies, improve maintainability, and centralize all related code under a single feature module.

## 🎯 Goals
1. **Eliminate circular dependencies** between sherpi_emotions and sherpi_dialogues
2. **Centralize all Sherpi code** under `features/sherpi/`
3. **Maintain backward compatibility** during migration
4. **Improve code organization** with clear separation of concerns
5. **Ensure zero runtime errors** through comprehensive testing

## 🔍 Current Issues

### 1. Circular Dependency
```dart
// sherpi_emotions.dart imports:
import 'sherpi_dialogues.dart';  // ❌ Circular!

// sherpi_dialogues.dart imports:
import 'sherpi_emotions.dart';   // ❌ Circular!
```

### 2. Scattered Code Structure
```
lib/
├── core/constants/        ← sherpi_dialogues.dart, sherpi_emotions.dart
├── core/ai/              ← smart_sherpi_manager.dart, dialogue sources
├── features/sherpi/      ← Incomplete feature modules
├── shared/providers/     ← global_sherpi_provider.dart
└── shared/widgets/       ← Multiple sherpi widgets
```

### 3. High Coupling
- 60+ files depend on Sherpi system
- Mixed responsibilities (AI, UI, State, Constants)
- No clear API boundaries

## 🏗️ Target Architecture

```
lib/features/sherpi/
├── constants/                     # Pure data definitions
│   ├── contexts.dart             # SherpiContext enum (NEW)
│   ├── emotions.dart             # SherpiEmotion enum only
│   └── dialogues.dart            # Static dialogue data
│
├── core/                          # Business logic
│   ├── models/
│   │   ├── sherpi_state.dart    # State model
│   │   └── sherpi_config.dart   # Configuration
│   ├── mappers/
│   │   ├── emotion_mapper.dart  # Context → Emotion mapping
│   │   └── dialogue_mapper.dart # Context → Dialogue mapping
│   └── managers/
│       ├── sherpi_manager.dart  # Main orchestrator
│       └── ai_manager.dart      # AI integration
│
├── data/                          # Data layer
│   ├── sources/
│   │   ├── dialogue_source.dart # Abstract interface
│   │   ├── static_dialogue_source.dart
│   │   ├── openai_dialogue_source.dart
│   │   └── gemini_dialogue_source.dart
│   └── repositories/
│       └── sherpi_repository.dart
│
├── presentation/                  # UI layer
│   ├── providers/
│   │   └── sherpi_provider.dart # Riverpod provider
│   ├── widgets/
│   │   ├── sherpi_avatar.dart
│   │   ├── sherpi_dialog.dart
│   │   └── sherpi_floating.dart
│   └── screens/
│       └── sherpi_chat_screen.dart
│
├── features/                      # Sub-features
│   ├── chat/
│   ├── emotion/
│   ├── analysis/
│   └── relationship/
│
└── sherpi.dart                   # Public API barrel export
```

## 📝 Refactoring Steps

### Phase 1: Preparation (No Breaking Changes)
1. **Create backup branch**
   ```bash
   git checkout -b refactor/sherpi-centralization
   ```

2. **Document all current imports**
   ```bash
   grep -r "sherpi_" lib/ --include="*.dart" > sherpi_imports_backup.txt
   ```

3. **Create migration tracking**
   - List all 60+ files that import Sherpi
   - Map current imports to new locations

### Phase 2: Break Circular Dependencies
1. **Extract shared types**
   ```dart
   // NEW: lib/features/sherpi/constants/contexts.dart
   enum SherpiContext {
     welcome, dailyGreeting, levelUp, // etc...
   }
   ```

2. **Remove cross-imports**
   ```dart
   // emotions.dart - REMOVE import of dialogues
   // dialogues.dart - REMOVE import of emotions
   ```

3. **Create mapper layer**
   ```dart
   // NEW: lib/features/sherpi/core/mappers/emotion_mapper.dart
   class EmotionMapper {
     static SherpiEmotion fromContext(SherpiContext context) {
       // Mapping logic here
     }
   }
   ```

### Phase 3: Create New Structure
1. **Create directory structure**
   ```bash
   mkdir -p lib/features/sherpi/{constants,core,data,presentation}
   mkdir -p lib/features/sherpi/core/{models,mappers,managers}
   mkdir -p lib/features/sherpi/data/{sources,repositories}
   mkdir -p lib/features/sherpi/presentation/{providers,widgets,screens}
   ```

2. **Move and refactor files**
   - Split sherpi_emotions.dart → emotions.dart + emotion_mapper.dart
   - Split sherpi_dialogues.dart → contexts.dart + dialogues.dart + dialogue_mapper.dart
   - Move AI managers → core/managers/
   - Move providers → presentation/providers/
   - Move widgets → presentation/widgets/

### Phase 4: Migration with Compatibility
1. **Create compatibility exports**
   ```dart
   // TEMPORARY: lib/core/constants/sherpi_emotions.dart
   export '../../features/sherpi/sherpi.dart' 
     show SherpiEmotion, EmotionMapper;
   ```

2. **Update imports progressively**
   - Start with leaf components (widgets)
   - Move to providers
   - Finally update core dependencies

3. **Test after each batch**
   ```bash
   flutter analyze
   flutter test
   ```

### Phase 5: Validation & Cleanup
1. **Run comprehensive tests**
   ```bash
   flutter test --coverage
   flutter analyze --fatal-warnings
   ```

2. **Remove compatibility layers**
   - Delete old files in core/constants/
   - Remove temporary exports

3. **Update documentation**
   - Update README
   - Add migration guide
   - Document new API

## 🔄 Migration Order

### Priority 1: Break Dependencies (Critical)
1. Extract SherpiContext to separate file
2. Remove circular imports
3. Create mapper classes

### Priority 2: Core Migration (High)
1. Move emotion system
2. Move dialogue system
3. Move AI managers

### Priority 3: UI Migration (Medium)
1. Move widgets
2. Update providers
3. Update screens

### Priority 4: Cleanup (Low)
1. Remove old files
2. Update tests
3. Documentation

## ✅ Success Criteria
- [ ] No circular dependencies
- [ ] All Sherpi code under features/sherpi/
- [ ] Zero compilation errors
- [ ] All tests passing
- [ ] No runtime errors
- [ ] Clean architecture with clear layers

## 🚨 Risk Mitigation
1. **Backup Strategy**: Git branch + checkpoint commits
2. **Rollback Plan**: Each phase is reversible
3. **Testing Strategy**: Test after each file move
4. **Compatibility Layer**: Temporary exports during migration
5. **Progressive Migration**: Small batches with validation

## 📊 Validation Checklist
- [ ] `flutter analyze` - No errors
- [ ] `flutter test` - All tests pass
- [ ] App launches successfully
- [ ] Sherpi appears and responds
- [ ] No import errors
- [ ] No circular dependencies
- [ ] Performance unchanged

## 🎯 Expected Outcomes
1. **Clean Architecture**: Clear separation of concerns
2. **Maintainability**: Easier to understand and modify
3. **Testability**: Each layer can be tested independently
4. **Scalability**: Easy to add new Sherpi features
5. **Performance**: Reduced coupling, better tree-shaking

## 📅 Timeline
- Phase 1: 10 minutes (Preparation)
- Phase 2: 30 minutes (Break dependencies)
- Phase 3: 45 minutes (Create structure)
- Phase 4: 60 minutes (Migration)
- Phase 5: 30 minutes (Validation)
- **Total: ~3 hours**

## 🔧 Tools Required
- Flutter SDK
- Git
- Text editor with multi-file search/replace
- Terminal for running commands

---

**Ready to proceed with Phase 1: Preparation**