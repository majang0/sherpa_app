# Repository Guidelines

## Project Structure & Modules
- `lib/` is the app source:
  - `lib/core/` foundational utilities, config, theme, constants (e.g., `core/constants/app_colors.dart`).
  - `lib/features/` feature-first folders (e.g., `features/meetings/...`, `features/sherpi_chat/...`).
  - `lib/shared/` cross-feature models, providers, widgets.
  - Entrypoints: `lib/main.dart`, navigation in `lib/main_navigation_screen.dart`.
- `assets/` static assets referenced by `pubspec.yaml`.
- Platforms: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`.
- Config: `.env` (local), `.env.example` (template), `firebase.json`, `lib/firebase_options.dart` (generated).

## Build, Test, and Development Commands
- Install deps: `flutter pub get`.
- Run (choose device): `flutter run -d chrome` | `-d android` | `-d ios`.
- Analyze lints: `flutter analyze`.
- Format code: `dart format .` (CI expects formatted code).
- Unit/widget tests: `flutter test` (add tests under `test/`).
- Production builds: `flutter build apk --release`, `flutter build ios --release`, `flutter build web`.
 - Codegen: `flutter pub run build_runner build --delete-conflicting-outputs` (or `watch`).
 - Icons/package utils: `flutter pub run flutter_launcher_icons`, `flutter pub run change_app_package_name:main <new.id>`.

## Coding Style & Naming
- Dart style with 2-space indent; keep lines readable (~100 cols).
- Files/folders: lower_snake_case (e.g., `meeting_recommendation_ai.dart`).
- Classes/types: PascalCase; methods/fields: lowerCamelCase.
- Constants: prefer `const` with lowerCamelCase; module-level immutable config may use UPPER_SNAKE_CASE where appropriate.
- Imports ordered: `dart:` → `package:` → relative; use trailing commas for stable diffs.
- Follow repo lints in `analysis_options.yaml`; fix with `flutter analyze` + `dart fix --apply`.

## Testing Guidelines
- Framework: `flutter_test` with `*_test.dart` files.
- Mirror `lib/` structure in `test/` (e.g., `test/features/meetings/...`).
- Write fast, deterministic tests; avoid network/file I/O. Aim for meaningful coverage on core logic and providers.

## Commit & Pull Requests
- Commit convention (match history): `Checkpoint: <tag> - <concise summary>` (emoji optional). Example: `Checkpoint: sherpi22 - reading analysis UI polish`.
- Keep commits scoped and descriptive; English or Korean acceptable.
- PRs: clear description, link related issues, note scope and risk, include screenshots for UI changes, and list test/verification steps.
- Required before merge: `flutter analyze` clean, formatted code, and green tests.

## Security & Config
- Do not commit secrets. Use `.env.example` as the template; keep `.env` local.
- Firebase options are generated in `lib/firebase_options.dart`; avoid manual edits. Platform-specific configs should follow FlutterFire docs.

## Agent-Specific Notes
- Flutter/Dart versions: Flutter >=3.27, Dart >=3.0 (match `pubspec.yaml`). Avoid older APIs.
- Global providers init order (keep consistent, edit in `lib/main.dart` only if needed): `globalGame` → `globalUser` → `globalPoint` → `globalUserTitle` → `questProviderV2` → `globalMeeting` → `sherpi` → `relationship` → `emotionAnalysis`.
- Navigation: uses `MaterialApp.routes` + `MainNavigationScreen` (5 tabs). Some routes expect typed `arguments` (e.g., `AvailableMeeting`, `ExerciseLog`, or `{tabIndex, subTabIndex}`). Validate types before use.
- Color system: prefer `core/theme/modern_colors.dart` (ModernColors). `AppColors` kept for compatibility; avoid in new code. Use `SherpaCleanAppBar` for app bars.
- Sherpi usage: show messages via `sherpiProvider` APIs (avoid ad‑hoc overlays). Respect duplicate/lock behavior; if adding new triggers, supply `SherpiContext` and optional `userContext`/`gameContext`.
- Sherpi AI: default is 100% static messages; manual AI only. Gemini background caching is intentionally disabled—do not re‑enable. Always fallback to static on failure; never block UI on AI calls.
- AI deps: keep `google_generative_ai` at ^0.4.7 per repo; Gemini SDKs are in flux. Avoid enabling background cache paths until Firebase AI Logic SDK migration.
- Quests: `questProviderV2` manages generation/progress. Some dev-only resets in `_loadQuests()` clear SharedPreferences; wrap changes with debug flags to avoid data loss.
- Storage: primary persistence is `SharedPreferences`; Hive deps exist but are lightly used. Keep writes small and async-safe.
- Meetings: 3-model pattern (AvailableMeeting, RecommendedMeeting, MeetingLog). When adding routes, prefer passing IDs (web/deeplink safe) rather than whole objects.
- Security: do not bundle secrets in release. Prefer `--dart-define` for keys; `.env` is for local dev only.
- API keys: configure via `core/config/api_config.dart` and env. Do not call `ApiConfig.debugApiKeyStatus()` in release builds.
- Localization: default locale is `ko_KR`; keep user-facing strings Korean unless i18n is introduced.
- Tests: repository has minimal tests; when adding, mirror `lib/` under `test/` and prefer fast, deterministic provider/widget tests. Use `flutter test --coverage` as needed.

## Latest Meeting-System Update (2025-09-18)
- Removed redundant artifacts per `모임시스템_최종_최적화계획.md`: `codex/meeting_system_cleanup_plan.md`, `codex/meeting_system_asset_review.md`, `codex/widget_integration_report.md`, `structure/모임시스템_최종분석보고서.md`.
- Inlined `meeting_creation_provider.dart` into `lib/features/meetings/presentation/screens/new_meeting_discovery_screen.dart` via `_MeetingCreationNotifier`/`_meetingCreationProvider`; deleted the standalone provider directory.
- Reflected changes across documentation: updated `structure/모임시스템_최종_최적화계획.md`, `codex/meeting_system_review.md`, and `lib/OPTIMIZATION_REPORT.md` to describe the new state and remaining action items (AI recommendation unification, analyzer debt, large-screen partitioning).
- Analyzer/tests were not rerun: Windows-distributed Flutter scripts currently use CRLF (`#!/usr/bin/env bash\r`), causing WSL execution failures. Before running `dart format`/`flutter analyze`, convert `/mnt/c/flutter/bin/dart` (and peers) to LF or execute from Windows PowerShell.

### Follow-up Priorities
1. Implement global AI recommendation provider per `codex/ai_recommendation_refactoring_guide.md` and add coverage in `test/features/meetings/ai/`.
2. Address legacy analyzer warnings concentrated under `lib/core/ai/` and `lib/shared/widgets/sherpi_widget.dart`.
3. Break down `new_meeting_discovery_screen.dart` / `available_meeting_detail_screen.dart` into smaller parts for maintainability.
4. Restore lint/test automation once Flutter tool scripts are runnable in the current environment.
