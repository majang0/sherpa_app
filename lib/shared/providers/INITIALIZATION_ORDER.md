# Provider Initialization Order

**⚠️ CRITICAL**: This initialization order MUST be maintained to prevent app crashes.

## Overview

Sherpa App uses **9 critical providers** that must be initialized in a specific order due to dependencies. This order is enforced in `lib/main.dart` in the `_initializeGlobalProviders()` method.

---

## Initialization Sequence

### Level 0: Foundation (1 provider)

**Purpose**: Core game system data that other providers depend on

| Provider | Location | Dependencies | Description |
|----------|----------|--------------|-------------|
| `globalGameProvider` | `level_0_foundation/` | None | Game constants, mountain data, badge definitions |

---

### Level 1: User Data (3 providers)

**Purpose**: User-specific data and state

| Provider | Location | Dependencies | Description |
|----------|----------|--------------|-------------|
| `globalUserProvider` | `level_1_user_data/` | `globalGameProvider` | User profile, stats, achievements |
| `globalPointProvider` | `level_1_user_data/` | `globalUserProvider` | Point system, transactions |
| `globalUserTitleProvider` | `level_1_user_data/` | `globalUserProvider` | User titles and badges |

---

### Level 2: Feature Systems (2 providers)

**Purpose**: Core feature functionality

| Provider | Location | Dependencies | Description |
|----------|----------|--------------|-------------|
| `questProviderV2` | `features/quests/providers/` | `globalUserProvider`, `globalPointProvider` | Quest system (daily, weekly, premium) |
| `globalMeetingProvider` | `level_2_features/` | `globalUserProvider` | Meeting system (available, applications, logs) |

**⚠️ NOTE**: `questProviderV2` is in the quests feature directory but is initialized globally. **NEVER** use the legacy `questProvider`.

---

### Level 3: AI & Advanced Systems (3 providers)

**Purpose**: AI-powered features and relationship systems

| Provider | Location | Dependencies | Description |
|----------|----------|--------------|-------------|
| `sherpiProvider` | `level_3_ai/` | All above | Sherpi AI companion (static messages) |
| `relationshipProvider` | `features/sherpi/relationship/providers/` | `sherpiProvider` | User-Sherpi relationship tracking |
| `emotionAnalysisProvider` | `features/sherpi/emotion/providers/` | `sherpiProvider`, `relationshipProvider` | Emotion analysis and adaptive responses |

---

## Lazy-Loaded Providers

These providers are **NOT** part of the critical initialization sequence. They are loaded on-demand when accessed:

| Provider | Location | Used By |
|----------|----------|---------|
| `globalAiRecommendationProvider` | `lazy_loaded/` | Meeting recommendations |
| `globalBadgeProvider` | `lazy_loaded/` | Badge management UI |
| `globalChallengeProvider` | `lazy_loaded/` | Challenge system |
| `globalCommunityProvider` | `lazy_loaded/` | Community features |
| `globalClimbingProvider` | `lazy_loaded/` | Climbing/leveling system |
| `notificationProvider` | `lazy_loaded/` | Notification system |
| `peerReviewProvider` | `lazy_loaded/` | Peer review features |
| `achievementProvider` | `lazy_loaded/` | Achievement tracking |

---

## Dependency Graph

```
Level 0: globalGameProvider
           ↓
Level 1: globalUserProvider → globalPointProvider
                            → globalUserTitleProvider
           ↓                  ↓
Level 2: questProviderV2, globalMeetingProvider
           ↓
Level 3: sherpiProvider → relationshipProvider → emotionAnalysisProvider
```

---

## Critical Rules

### ❌ DO NOT:
1. **Change the initialization order** in `main.dart` (app will crash)
2. **Use `questProvider`** (legacy, always use `questProviderV2`)
3. **Add new initialized providers** without updating this document
4. **Create circular dependencies** between providers

### ✅ DO:
1. **Add new providers as lazy-loaded** if they don't need early initialization
2. **Update this document** when adding to initialization sequence
3. **Run state-management-guard Agent** after provider changes
4. **Test initialization** after any provider reorganization

---

## Validation

After ANY changes to provider structure or initialization:

```bash
# 1. Run flutter analyze
flutter analyze

# 2. Check state-management-guard (auto-runs on file save)
# Look for warnings about initialization order

# 3. Test app launch
flutter run
# Verify no crashes on startup
```

---

## Migration History

- **2025-11-02**: Reorganized providers into Level-based directories
  - Level 0-3 for initialized providers
  - lazy_loaded/ for on-demand providers
  - Created this documentation

---

## References

- **CLAUDE.md** (lines 63-87): Provider initialization section
- **lib/main.dart** (lines 207-240): `_initializeGlobalProviders()` method
- **state-management-guard Agent**: Automatic validation of initialization order

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-02
**Maintainer**: Architecture Team
