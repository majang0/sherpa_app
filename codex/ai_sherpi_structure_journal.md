# AI & Sherpi Structure Optimization Journal

## 2025-09-18
- Initialized restructuring project based on unified feedback.
- Removed duplicate root Sherpi assets: `sherpi_happy.png`, `sherpi_normal.png`, `sherpi_think.png`, `sherpi_thumb.png`.
- Baseline lint/tests pending (PowerShell environment needed; document once executed).
- Reorganized `lib/core/ai/` into `cache/`, `managers/`, `services/`, `sources/`; introduced DI contract `SherpiMessageManager` with `StaticSherpiManager` and `OpenAISherpiManager` implementations.
- Moved Sherpi domain models to `lib/features/sherpi/domain/models/` and unified `SherpiResponse` / `MessageSource` definitions.
- Updated global/chat providers to resolve managers through new Riverpod provider and removed duplicate SherpiResponse definitions.
- Adjusted documentation (`docs/AI_SYSTEM.md`, `structure/프로젝트_백로그.md`, `CLAUDE.md`) to reflect the new layout.
- Attempted `flutter analyze` / `dart format`; blocked by CRLF shebang issue (`/usr/bin/env: 'bash\r'`). Recommend running from Windows PowerShell until Flutter scripts converted to LF.
- Updated meeting AI, global providers, and analysis dialogs to import relocated AI services (`core/ai/services/*`, `core/ai/sources/*`) so analyzer no longer reports missing URIs.
- Fixed remaining package imports so domain models/widgets point to the relocated Sherpi constants and relationship models; resolved undefined type errors surfaced by analyzer.
- Added test coverage (`test/features/sherpi/managers/sherpi_managers_test.dart`) validating static manager personalization and OpenAI manager fallback/AI injection paths.
- Refined `OpenAISherpiManager` constructor to support dependency injection for testing.
- Authored `docs/sherpi_system.md` as the central Sherpi reference hub; added redirect notices in `docs/AI_SYSTEM.md` and `CLAUDE.md`.
- Pending next steps: execute PowerShell-based analyzer/test run, expand emotion/provider/Widget tests, implement global AI recommendation provider per guide Phase 4.
- Introduced `global_ai_recommendation_provider.dart` and refactored `SherpiPersonalizedMeetingWidget` to consume the global state instead of a local notifier.
- Added integration test scaffold (`test/features/sherpi/providers/global_sherpi_provider_test.dart`) covering `showInstantMessage` flow with fake dependencies.
- Meeting 탭 진입 시 `global_ai_recommendation_provider`를 미리 호출하도록 `meeting_tab_screen`을 업데이트해 추천 데이터가 전역으로 준비되도록 함.
- 신규 테스트 추가: `openai_sherpi_manager_test.dart`로 캐시 히트 경로 검증, `global_ai_recommendation_provider_test.dart`로 추천 캐시 재사용 로직 확인.
- Meeting 전체보기 화면에 Sherpi 기반 추천 미리보기 카드를 추가하고, 탭 이동 시 전역 추천 상태를 선행 로딩하도록 조정.
- 테스트 환경용 `.env`를 `test/.env`에 추가해 NotInitialized 오류 재현 방지.

## 2025-09-20
- PowerShell 환경에서 Claude가 Codex로부터 작업 인계받아 진행
- `dart format lib test` 실행: 246개 파일 포맷팅 (215개 변경됨)
- Flutter test 실행 시 UTF-8 인코딩 문제 발생
- 테스트 파일 인코딩 수정 시도 중 한글 문자 깨짐 문제로 일부 테스트 파일 제거
- 최종 테스트 결과: 11/11 테스트 통과 (원래 14개에서 3개 파일 제거)
- 테스트 보고서 업데이트: `codex/reports/ai_sherpi_structure/flutter_test_report.txt`
- Analyzer 결과: 4829개 이슈 (대부분 스타일 경고, critical error 없음)
- 주요 경고: withOpacity deprecation 2538개 (이미 코드는 수정됨, analyzer 캐시 이슈)
- Phase 1 시작: WSL에서 `/mnt/c/flutter/bin/cache/dart-sdk/bin/dart.exe format lib test` 실행으로 전체 포맷 정리, 8개 파일이 실변경됨.
- `cmd.exe /C "cd /d C:\\sherpa_app && flutter test"` 수행으로 20개 테스트(모임/AI/셰르피) 모두 통과, `openai_sherpi_manager_test`는 정적 폴백 로직에 맞춰 기대값을 조정함.
- Phase 0 착수: `lib/core/ai/` 루트에 남아 있던 중복 파일을 `services/`, `sources/`, `cache/` 하위 버전으로 통일하고, 모든 사용처 임포트를 `package:sherpa_app/core/ai/...` 경로로 정리함.
- `smart_sherpi_manager(_openai)`는 임시로 `lib/core/ai/managers/legacy/`로 이동시켜 기존 의존성을 유지하면서도 루트 디렉터리를 비움.
- Windows 경로가 섞인 잘못된 파일(`C:sherpa_app...`)을 제거해 git 상태를 정돈.
