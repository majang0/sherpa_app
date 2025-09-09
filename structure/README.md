# 셰르파 앱 구조 개요 (Korean Architecture Overview)

## 1) 전체 개요
- Flutter + Dart 기반의 멀티플랫폼 앱(안드로이드/IOS/웹/데스크톱).
- 상태관리: Riverpod(핵심 전역 Provider 다수), 라우팅: `MaterialApp.routes` + 탭 네비게이션.
- 데이터: `SharedPreferences`(경량 로컬 저장), 일부 Hive 준비, Firebase(Core/Auth/Firestore/Storage) 연동 가능.
- AI: Gemini, OpenAI(GPT‑5) 클라이언트 의존성 보유. 현재 셰르피 메시지는 정적 로직 중심이며, 추후 `ApiConfig`로 제공자 전환.
- 지역화: 기본 한국어(`ko_KR`) + 영어 폴백. 폰트: NotoSans, Pretendard 번들.

## 2) 디렉터리 구조 핵심
- `lib/core/` 공통 인프라: 상수(`constants/`), 테마(`theme/`), 설정(`config/api_config.dart`), 유틸(`utils/`), AI 보일러(`ai/`).
- `lib/features/` 기능별 폴더: 
  - `daily_record/`(운동/독서/다이어리/집중타이머), `meetings/`(모임/챌린지), `quests/`(퀘스트 V2), 
  - `sherpi_*`(감정/관계/챗/개인화/플래닝), `home/`, `profile/`, `climbing/`, `community/` 등.
- `lib/shared/` 공용 모델/프로바이더/위젯: 
  - 전역 프로바이더(`global_user/point/sherpi/meeting/...`), 공용 위젯(`widgets/`), 상수 및 유틸.
- 엔트리: `lib/main.dart`(앱 부트스트랩) + `lib/main_navigation_screen.dart`(하단 탭 5개).
- 정적 리소스: `assets/`(이미지/폰트/.env 등), 플랫폼 폴더: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`.

## 3) 앱 시작·네비게이션
- `main.dart`
  - `.env` 로드 → `ProviderScope`로 전역 의존성 오버라이드(SharedPreferences, 관계/감정 분석 등).
  - 글로벌 초기화: `globalGameProvider → globalUser → globalPoint → globalUserTitle → questProviderV2 → globalMeeting → sherpi → relationship → emotionAnalysis` 순.
  - `MaterialApp` 설정: 한국어 로케일, `AppColors` 테마, 명시적 `routes` 매핑(모임·기록·분석·컴포넌트뷰·셰르피 히스토리 등).
- `main_navigation_screen.dart`
  - 하단 탭 5개: 홈/레벨업(분석)/퀘스트/모임/프로필.
  - 탭 전환 시 `questProviderV2.recordTabVisit()`로 퀘스트 트래킹.
  - 상시 플로팅 `GlobalSherpiWidget` + 메시지 시 `SherpiMessageCard` 노출.
  - `go_router` 의존성은 존재하며, 명시적 라우트 사용과 혼용/전환 가능 구조.

- 주요 라우트 예시
  - `/` → `MainNavigationScreen`
  - `/meeting_detail|application|success|review|list_all`
  - `/daily_record|diary_record|exercise_record|exercise_selection|exercise_dashboard|exercise_detail|exercise_edit`
  - `/reading_record|focus_timer|focus_timer_record|diary_analysis|component_viewer|sherpi_message_history`
  - 일부 라우트는 `arguments` 요구(예: `AvailableMeeting`, `ExerciseLog`, 날짜/타입 등).

## 4) 상태관리·데이터 흐름
- Riverpod StateNotifier로 전역 도메인 관리:
  - 유저(`globalUserProvider`): 레벨·경험치·능력치·목표·일일기록(샘플 생성기) 관리.
  - 포인트(`globalPointProvider`): 적립/사용 트랜잭션 및 합산 통계.
  - 퀘스트 V2(`questProviderV2`): 일일/주간/프리미엄 자동 생성, 진행률 동기화, 보상/보너스, 탭 방문 조건.
  - 셰르피(`sherpiProvider`): 감정/대사/표시모드/중복 방지/히스토리, 활동 완료 컨텍스트에 맞춘 알림.
  - 관계/감정 분석: 상호작용 기록 → 친밀도/감정 동기화 지표 업데이트.
- 영속화: `SharedPreferences` 사용(퀘스트/보너스/방문기록 등 키 기반 저장). Hive 의존성 있음(필요 시 확장).

## 5) 셰르피 시스템 요약
- `shared/providers/global_sherpi_provider.dart`
  - 정적 대사 소스 기반 빠른 피드백, 메시지 중복/동시 표시 방지 락, 자동 숨김 타이머.
  - 컨텍스트(`SherpiContext`)별 추천 감정 매핑, 상호작용 기록 → 관계/감정 동기화로 반영.
  - `RealDataConnector`로 사용자/게임 맥락 수집(메타데이터 포함).
  - 향후 AI 전환 시 `ApiConfig.currentAIProvider`에 따라 Gemini/OpenAI로 확장 가능.

## 6) 퀘스트 시스템 V2
- 생성: 일일/주간/프리미엄 템플릿 기반 자동 생성, 주차 계산(월요일 기준) 반영.
- 진행률: 전역 유저/포인트/탭 방문 등 트래킹 데이터를 규칙 엔진으로 업데이트.
- 보상: 경험치/포인트/능력치 확률 증가, 전체 완료 보너스(일일/주간) 및 셰르피 축하 메시지.
 - 개발 모드: 초기 로드 시 저장된 일부 퀘스트 키를 제거하여 재생성(테스트 편의용).

## 7) 기능 하이라이트
- `daily_record`: 운동 기록(선택/상세/수정/대시보드), 독서·집중타이머·일기 작성/분석.
- 샘플 데이터: `features/daily_record/services/sample_data_generator.dart`로 최근 기간의 풍부한 기록 생성.
- `meetings`: 전체 목록/상세/신청/성공/리뷰, 챌린지 인덱스.
- `sherpi_chat`: 셰르피 메시지 히스토리 뷰.
- `component_viewer`: 공용 컴포넌트 미리보기.

## 8) 설정·외부 연동
- `core/config/api_config.dart`: 
  - `.env`/컴파일타임 키 로딩, 유효성 검사, 현재 AI 제공자 선택.
  - 모델: `gemini-2.5-flash`, `gpt-5-chat-latest`(플레이스홀더 포함).
- 위치/지도/센서: `geolocator`, `geocoding`, `google_maps_flutter`, `pedometer`, `camera`.
- 네트워킹: `dio`, `http`. 환경변수: `flutter_dotenv`.
 - Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` 사용. `lib/firebase_options.dart`(자동 생성) 기반 초기화 권장.

## 9) 빌드·테스트·품질
- 의존성: `flutter pub get`
- 실행: `flutter run -d chrome|android|ios`
- 린트: `flutter analyze` → 자동수정 `dart fix --apply`
- 포맷: `dart format .`
- 테스트: `flutter test`(구조는 `test/`에서 `lib/` 미러), 빠르고 결정적 테스트 권장.
 - 코드 생성: `dart run build_runner build -d`(Freezed/JSON/Hive 모델 갱신 시).

## 10) 리소스·아이콘·보안
- `pubspec.yaml`에 `assets/`와 폰트(NotoSans, Pretendard) 등록, 런처 아이콘(`flutter_launcher_icons`) 설정 포함.
- 에셋 경로 예시: `assets/images/`, `assets/images/sherpi/`, `assets/images/meeting/`, `assets/fonts/`, `.env`.
- `.env`는 개발용 예시로 번들되어 있으나 민감정보는 커밋 금지. 실제 운영 키는 안전하게 관리하고 `lib/firebase_options.dart`는 FlutterFire 생성 파일을 사용.

## 11) 디자인 시스템 참고
- 색상: `core/constants/app_colors.dart` 중심 사용.
- 앱바: `shared/widgets/sherpa_clean_app_bar.dart`.
- 애니메이션/피드백: `flutter_animate`, `lottie`, `confetti`, `shimmer`, `animated_text_kit`.

## 12) 의존성 요약(발췌)
- 상태/네비: `flutter_riverpod`, `riverpod`, `go_router`
- 네트워킹/환경: `dio`, `http`, `flutter_dotenv`
- 저장: `shared_preferences`, `hive`, `hive_flutter`
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- 위치·센서·미디어: `geolocator`, `geocoding`, `google_maps_flutter`, `pedometer`, `camera`, `image_picker`, `permission_handler`
- UI/그래프: `google_fonts`, `cached_network_image`, `fl_chart`
- AI: `google_generative_ai`, `openai_dart`
- 코드생성: `freezed`, `json_serializable`, `build_runner`, `hive_generator`
