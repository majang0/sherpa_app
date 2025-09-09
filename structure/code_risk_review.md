# 셰르파 앱 코드 안정성/보안 점검 보고서

본 문서는 현재 레포의 코드/설정에서 발견된 잠재적 위험 요소와 개선 제안을 정리한 것입니다. 우선순위별로 정리했으며, 즉시 조치가 필요한 항목을 맨 위에 배치했습니다.

## 1) 긴급 보안 이슈 (즉시 조치)
- 서비스 계정 키가 레포에 포함됨: `sherpa-app-production-firebase-adminsdk-fbsvc-778f28a3f1.json`
  - 이 파일에는 실제 `private_key`가 포함되어 있어 계정 탈취 위험이 매우 큽니다.
  - 조치:
    1) GCP IAM에서 해당 서비스 계정의 키 즉시 폐기/회전(Disable → Delete → 새 키 발급).
    2) 레포에서 파일 삭제 후, Git 이력에서도 완전 삭제(BFG Repo-Cleaner 또는 `git filter-repo`).
    3) CI에 비밀 스캔 도입(`gitleaks`, `trufflehog`) 및 pre-push 훅 추가.
- `.env`가 앱에 번들됨: `pubspec.yaml`의 `assets`에 `.env`가 포함되어 빌드 아티팩트에 API 키가 노출될 수 있습니다.
  - 조치:
    - 운영 빌드에서 `.env` 번들 금지. 개발 전용 플러터 러닝 환경에서만 사용.
    - 운영 키는 `--dart-define` 또는 서버/원격 설정(Firebase Remote Config 등)로 주입.

## 2) 환경/키 관리 개선
- `core/config/api_config.dart`는 키 유효성 검사와 제공자 선택을 지원하나, 운영 키를 클라이언트에 포함하면 위험합니다.
  - 권장: 운영은 `--dart-define`/CI 시크릿으로만 주입하고, 앱 내부에서 키를 보관하지 않기.
  - `debugApiKeyStatus()`는 키 값은 출력하지 않지만, 운영 빌드에서 호출되지 않도록 가드 필요.

## 3) 데이터 초기화 로직의 파괴적 동작
- `features/quests/providers/quest_provider_v2.dart` → `_loadQuests()` 초반에 `SharedPreferences`의 퀘스트 관련 키를 매번 제거(개발용 주석 있으나 항상 실행).
  - 영향: 앱 재시작 시마다 유저의 퀘스트 진행/보너스 상태가 사라질 수 있음.
  - 수정 제안:
    - `kDebugMode` 가드 적용 예시:
      ```dart
      if (kDebugMode) {
        await prefs.remove('saved_quests_v2');
        // 기타 초기화 키들…
      }
      ```
    - 또는 환경 플래그(예: `RESET_QUESTS_ON_BOOT`)를 `.env.development`에만 두고 분기.

## 4) 라우팅/딥링크 안정성
- `main.dart`에서 `routes`로 객체(예: `AvailableMeeting`)를 `arguments`로 직접 전달. 웹 딥링크/새로고침 상황에서 역직렬화 불가.
  - 권장: `go_router`로 통합하고, URL 파라미터/쿼리로 식별자(ID)만 전달 → 화면에서 데이터 로드.
  - 최소 수정안: `onGenerateRoute`로 타입 검증/에러 라우트 처리.

## 5) 상태/동시성 이슈(셰르피)
- `global_sherpi_provider.dart`는 메시지 동시 표시 방지를 위해 락/중복 검사를 둠. 빠르게 연속 호출 시 최근 요청이 드랍될 수 있음.
  - 개선: 간단한 큐(예: `List<PendingMessage>`)를 두어 현재 표시 중이면 대기열에 추가하고 종료 시 dequeue 처리.
- 타이머 관리: `_hideTimer`는 호출마다 취소/재설정하고 있어 누수는 낮으나, 장시간 화면 전환 간 메시지 유실 가능성 검토 필요.

## 6) 예외 처리/관측성
- 다수의 `try { ... } catch (e) {}` 빈 처리 존재 → 원인 추적 어려움.
  - 권장: `logger` 패키지로 에러 로깅 일원화.
    ```dart
    final _log = Logger();
    catch (e, stack) { _log.e('context message', e, stack); }
    ```
  - 사용자 영향 있는 실패는 UI 피드백(스낵바/셰르피 메시지) 고려.

## 7) 도메인 수치 일관성
- `global_user_provider.dart` 초기 상태: “능력치 0-10 범위” 주석과 달리 `willpower: 20`으로 설정.
  - 영향: UI 게이지/검증 로직이 0-10 가정 시 화면 깨짐/오류 가능.
  - 조치: 스케일 통일(0-10) 또는 클램핑/정규화 추가. 주석/도메인 모델 정의도 함께 정리.

## 8) SharedPreferences 사용 한계
- 퀘스트 전체 리스트를 JSON 문자열 리스트로 저장/로드. 데이터 커지면 I/O 지연 발생 가능.
  - 개선: 퀘스트/진행률은 Hive 박스 또는 경량 DB(sqlite)로 이전(인덱싱/부분 로드 지원).

## 9) Web/Back 버튼/깊이 있는 내비게이션
- 현재 `MaterialApp.routes` 정적 매핑은 웹 뒤로가기/새로고침에서 기대치 못 미침.
  - `go_router` 전환 시 브라우저 히스토리/딥링크/리다이렉트 정책을 일관되게 처리 가능.

## 10) 권한/플랫폼 설정 체크리스트
- 위치/카메라/사진 관련 패키지 사용(`geolocator`, `camera`, `image_picker`, `permission_handler`).
  - iOS `Info.plist`에 각 권한 용도 문자열(NSLocationWhenInUseUsageDescription 등) 확인 필요.
  - Android `AndroidManifest.xml` 퍼미션/SDK 타깃 레벨 검증.

## 11) 빌드/키 유출 방지 CI 가드
- CI 단계에 다음 추가 권장:
  - `flutter analyze` + `dart format .` + 테스트.
  - 비밀 스캔(`gitleaks`): `gitleaks detect --redact`.
  - `.env`/`*.json`(서비스 키) 커밋 차단 pre-commit 훅.

## 12) 제안 작업 우선순위 체크리스트
1) 서비스 계정 키 회수 및 Git 이력 정리(보안).
2) `.env` 번들 제거(운영), 빌드 타임 주입으로 전환.
3) 퀘스트 초기화 코드 `kDebugMode` 가드.
4) `go_router`로 라우팅 일원화 또는 `onGenerateRoute` 타입 검증 추가.
5) 예외 로깅 일원화 + 주요 경로 유저 피드백.
6) 능력치 스케일 통일 및 UI/로직 정합성 검증.
7) SharedPreferences → Hive/SQLite 단계적 이전(퀘스트/히스토리 등).
8) iOS/Android 권한 문구/퍼미션 재점검.

필요 시 각 항목에 대해 구체 코드 패치를 제안하거나, 향후 PR 템플릿/CI 설정까지 준비해 드리겠습니다.

