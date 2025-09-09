# CLAUDE.md 개정 제안서 (Claude Code 작업 지시서)

본 문서는 현재 CLAUDE.md를 실제 코드베이스와 일치하도록 정리·간소화하고, 개발에 바로 도움이 되는 형태로 개편하기 위한 제안서입니다. 이 계획에 따라 CLAUDE.md를 업데이트해 주세요.

## 1) 개정 목적
- 실제 레포 코드와 불일치/과장된 설명 제거
- 개발자에게 즉시 유용한, 실행 가능한 지침 위주로 재구성
- 장문 설명·외부 도구(Claude 실행환경, MCP 등) 안내는 부록으로 분리

## 2) 현재 문제 요약
- 범위 과다: MCP 서버 설치·제거, Windows 경로 이스케이프 등 “Claude 실행환경” 가이드를 본문에 장황히 포함 → 레포 개발 가이드와 분리 필요
- 불일치: 앱 시작 시 “전역 데이터 전체 초기화”처럼 읽히는 표현, 존재하지 않는 API(예: enableAIForNextMessage) 언급 등
- 실용성 저하: 집단 지성(Claude+Codex 협업) 철학 설명이 길고 행동 지침이 부족
- 위험한 예시: Navigator로 복잡 객체를 `arguments`로 전달(웹/딥링크 취약)

## 3) 의미 희박/범위 이탈 콘텐츠 처리 방안
- MCP 설치/제거, 경로/토큰 인자 세부: “부록(appendix)”으로 이동, 본문에는 한 줄 링크만 남김
- 집단 지성(Claude+Codex) 4단계 장문 설명: 3~5줄 요약 + 체크리스트로 축약
- ModernColors 긴 샘플 나열: “신규는 ModernColors 사용, AppColors는 호환용(지양)” 한 문장 + 파일 경로 링크로 대체

## 4) 불일치 항목 정정안
- “앱 시작 시 데이터 초기화”
  - 정정: 개발 모드에서 퀘스트 관련 SharedPreferences 키 일부를 초기화할 수 있음(`quest_provider_v2._loadQuests`). 프로덕션에서는 `kDebugMode` 가드 권장.
- “globalUserProvider 초기화 시 SharedPreferences clear”
  - 정정: 현재 자동 초기화 메서드 호출 안 됨(주석 처리). 해당 서술 삭제.
- “AI 즉시 활성 API 예시(enableAIForNextMessage 등)”
  - 정정: 현재는 100% 정적 메시지 + 수동 AI 전제. 백그라운드 캐싱/자동 호출 비활성. 실패 시 정적 폴백, UI 블로킹 금지.
- “코드 생성 미사용” 단정
  - 정정: freezed/json 의존성 구성됨. 필요 시 `build_runner` 실행.

## 5) 권장 최종 목차(행동 지향)
1. 개요(앱 목적/플랫폼)
2. 구조(Feature-first, 핵심 디렉터리·대표 파일 경로)
3. 상태관리(전역 Provider 초기화 순서 고정)
4. 내비게이션(5탭, 안전한 라우트 인자 규칙)
5. 데이터/저장(SharedPreferences 기본, Hive 확장 여지)
6. 퀘스트 주의사항(개발용 초기화는 디버그 한정)
7. 셰르피/AI 정책(정적 우선, 수동 AI, 캐싱 비활성)
8. 색상/디자인(ModernColors 권장, AppColors 호환용)
9. 명령어(빌드/테스트/포맷/코드생성)
10. 보안/환경(`--dart-define` 권장, 비밀 커밋 금지)
11. 부록: MCP/Claude 실행환경 링크 모음(필요 시)

## 6) 구체 수정 가이드(치환/추가 예시)
- 내비게이션 인자 전달(웹/딥링크 안전)
  - 기존(지양):
    ```dart
    Navigator.pushNamed(context, '/meeting_detail', arguments: meetingModel);
    ```
  - 수정(권장):
    ```dart
    Navigator.pushNamed(context, '/meeting_detail', arguments: {'meetingId': id});
    // 상세 화면에서 id로 데이터 조회
    ```
- 전역 Provider 초기화 순서(실코드 준수)
  ```dart
  // lib/main.dart
  ref.read(globalGameProvider);
  ref.read(globalUserProvider);
  ref.read(globalPointProvider);
  ref.read(globalUserTitleProvider);
  ref.read(questProviderV2);
  ref.read(globalMeetingProvider);
  ref.read(sherpiProvider);
  ref.read(relationshipProvider);
  ref.read(emotionAnalysisProvider);
  ```
- 퀘스트 초기화 코드 디버그 가드
  ```dart
  import 'package:flutter/foundation.dart';
  // _loadQuests 내부
  if (kDebugMode) {
    await prefs.remove('saved_quests_v2');
    await prefs.remove('premium_quest_active_v2');
    // 기타 개발용 초기화 키들…
  }
  ```
- AI 정책 간결 문구(치환용)
  > 기본 동작은 100% 정적 메시지입니다. AI 호출은 명시적으로 요청된 경우에만 수행하며, 백그라운드 캐싱/자동 호출은 비활성입니다. 실패 시 항상 정적 메시지로 폴백하고, 어떤 경우에도 UI를 블로킹하지 않습니다. Gemini SDK는 ^0.4.7로 고정하며, Firebase AI Logic SDK 마이그레이션 전까지 캐시 경로 재활성화를 금지합니다.
- ModernColors 문구(치환용)
  > 새로운 개발은 `core/theme/modern_colors.dart`의 ModernColors를 사용하세요. `AppColors`는 호환을 위해 유지되지만 신규 코드에서는 사용하지 않습니다.
- 코드 생성/유틸 명령어(추가)
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  flutter pub run build_runner watch --delete-conflicting-outputs
  flutter pub run flutter_launcher_icons
  flutter pub run change_app_package_name:main com.example.app
  ```
- 보안/환경(운영 빌드)
  ```bash
  flutter build apk \
    --dart-define=OPENAI_API_KEY=@secret@ \
    --dart-define=GEMINI_API_KEY=@secret@
  # 릴리스에서 ApiConfig.debugApiKeyStatus() 호출 금지
  ```

## 7) 최종 문구 샘플(섹션별 대체 텍스트)
- 상태관리
  > 전역 Provider는 다음 순서로 초기화됩니다: globalGame → globalUser → globalPoint → globalUserTitle → questProviderV2 → globalMeeting → sherpi → relationship → emotionAnalysis. 새 전역 의존 도입 시 이 순서를 고려해 사이드이펙트를 방지하세요.
- AI 정책
  > 셰르피 메시지는 기본적으로 정적 소스에서 제공합니다. 수동 AI 호출만 허용하며, 실패 시 정적으로 폴백합니다. 백그라운드 캐싱/자동 호출은 비활성입니다.
- 라우팅 규칙
  > 웹/딥링크 호환을 위해 라우트 `arguments`에는 직렬 가능한 최소 데이터(ID 등)만 담고, 화면에서 데이터를 조회하세요.

## 8) 실행 체크리스트
- [ ] MCP/경로/인자·토큰 등 설치 가이드는 부록으로 이동(본문 링크만 유지)
- [ ] 불일치 서술(초기화/AI API/코드생성) 정정
- [ ] 위험한 Navigator 예시를 ID 전달 패턴으로 교체
- [ ] Provider 초기화 순서/AI 정책/ModernColors 한 줄 가이드로 축약
- [ ] 빌드/테스트/코드 생성/아이콘 명령어 추가
- [ ] 보안/환경(`--dart-define`, debug 로그 가드) 명시

## 9) Definition of Done(완료 기준)
- 본문은 “행동 지향” 문장으로 구성되고, 모든 예시가 현재 코드베이스와 일치
- 장문 배경 설명은 요약/링크 처리, 불필요한 세부는 부록 이동
- 웹/딥링크를 고려한 내비 인자 규칙이 일관되게 반영
- AI 정책·퀘스트 초기화·보안 항목이 명확히 서술됨

---
문서 개정 후, AGENTS.md와 중복되는 내용은 AGENTS.md를 기준으로 축약·정렬해 일관성을 유지해 주세요.

