# Meeting System Review (2025-09-18)

## 1. 전체 구조 개요
- **데이터 모델**: `AvailableMeeting`(모임 메타데이터), `MeetingLog`(후기 기록)로 분리되어 있으며, 사용자 일지(`DailyRecordData`)에 그대로 누적되는 구조.
- **상태 관리**: `globalMeetingProvider`가 단일 진입점으로 초기 데이터 로드, 참여 로직, 리뷰 후속처리, 추천 계산을 모두 담당.
- **UI 계층**: 단일 사용 위젯을 각 스크린 내부로 인라인하여 `meeting_review`, `meeting_success`, `available_meeting_detail`, `new_meeting_discovery`, `sherpi_personalized_meeting` 화면이 자체적으로 컴포넌트를 관리.
- **네비게이션**: `main.dart` 라우트가 ID/객체 인자를 모두 처리하고, 모임 미발견 시 안전 화면(`MeetingNotFoundScreen`)을 표시.
- **자동화 테스트**: 모델/프로바이더/통합 테스트가 핵심 플로우를 커버하며, `flutter test` 기준으로 회귀 검증이 가능.
- **문서화**: `docs/meetings_overview.md`가 최신 구조와 사용 예제를 포함하고 있어 온보딩 자료로 활용 가능.

## 2. 잘 구현된 요소
| 영역 | 강점 |
| --- | --- |
| 데이터/상태 | `AvailableMeeting` 계산 프로퍼티(`participationFee`, `experienceReward`, `statRewards`)가 비즈니스 규칙을 캡슐화. `MeetingLog` 헬퍼(`shortName`, `satisfactionColor`, `moodIcon`)가 UI 표현을 단순화. |
| 상태 연동 | `globalMeetingProvider.joinMeeting`이 포인트, 경험치, 능력치, 알림, 셰르피 메시지까지 한 번에 처리하여 일관성 있는 후속 작업 보장. |
| UI 구조 | 인라인 위젯 덕분에 동일 파일 내에서 컴포넌트를 추적할 수 있고, 불필요한 import 및 파일 난립 문제 해결. |
| 네비게이션 | ID 기반 인자가 없어도 `AvailableMeeting`을 직접 전달할 수 있으며, 누락 시 graceful fallback. |
| 테스트 | 모델/프로바이더/통합 테스트로 핵심 시나리오(생성→참여→리뷰)를 자동 검증. `ProviderContainer` 활용으로 전역 상태 주입을 안정적으로 재현. |
| 문서 | 흐름 다이어그램, API Reference, 코드 예제가 문서에 포함되어 실제 구현과 맞춰지도록 유지 관리됨. |

## 3. 발견된 보완점 및 제안
| 우선순위 | 개선 항목 | 상세 내용 |
| --- | --- | --- |
| 🔴 | **AI 추천 로직 일원화** | `SherpiPersonalizedMeetingWidget` 내부에 `_aiRecommendationProvider`가 존재하고, `MeetingRecommendationAI`를 별도로 초기화함. 추천 데이터 계산을 `globalMeetingProvider` 또는 독립 도메인 provider로 승격하여 홈 위젯/다른 화면들이 동일 로직을 재사용하도록 개선 필요. |
| 🟠 | **Analyzer 경고 해소** | `lib/core/ai/activity_analysis_service.dart`, `lib/shared/widgets/sherpi_widget.dart` 등 기존 파일에서 5천여 경고가 출력됨. 모임 도메인과 직접적 연관은 없지만 전체 리포지터리 품질 저하로 이어지므로, 향후 정리 계획 수립 필요. |
| 🟠 | **대형 스크린 분할** | `new_meeting_discovery_screen.dart` (4천+ 라인)와 `available_meeting_detail_screen.dart` (1.4천+ 라인)는 인라인 이후 가독성이 떨어짐. 스크린 내부의 프라이빗 파트를 섹션별 클래스로 분할하거나 `part` 파일을 도입하는 것을 고려. |
| 🟠 | **MeetingLog mood 입력 일치** | `completeMeetingReview`가 `mood` 문자열을 `moodIcon`과 약간 다른 키(`'happy'`, `'excited'` 등)를 사용함. UI에서 선택하는 키 리스트와 `MeetingLog.moodIcon` 스위치 문이 완벽히 일치하는지 재검증 필요. |
| 🟡 | **샘플 데이터/테스트 모드 분리** | `globalMeetingProvider`가 앱 실행 시 샘플 데이터를 즉시 로드하도록 되어 있음. 운영 환경에서는 원격 데이터 소스로 전환하거나, `kDebugMode` 조건으로 샘플 주입 여부를 구분하는 로직 추가가 필요. |
| 🟡 | **라우트 에러 UX** | `MeetingNotFoundScreen`이 간단한 안내만 제공. 홈으로 이동하는 CTA, 문제 신고 경로 등의 UX 보완 가능. |

## 4. 유지관리 체크리스트 (향후 작업 시)
1. **AI 추천 통합 계획 수립**: compact 버튼 로직을 provider 계층으로 승격하고, 다른 화면에서도 동일 추천을 노출할 수 있도록 설계.
2. **Analyzer 경고 줄이기**: 사용하지 않는 import, deprecated API(`withOpacity`) 교체, `print` 제거 등 전역 품질 개선.
3. **UI 파일 분리 전략**: 프라이빗 메서드/클래스를 기능 단위로 모듈화해 스크롤 부담 완화.
4. **MeetingLog 입력 검증**: mood/카테고리 문자열이 중앙 상수와 불일치하지 않도록 unit test 또는 enum 래핑 고려.
5. **샘플 데이터 토글**: 개발/운영 환경을 분기하는 설정 추가.

## 5. 결론
모임 시스템은 현재 다음 면에서 "정리 완료" 상태입니다.
- 단일 사용 위젯 제거 및 화면 내부 관리 구조 정비
- 라우트 인자 안정화 및 예외 처리 강화
- 모델/프로바이더/플로우 테스트 완비
- 최신 문서/백로그 반영

향후에는 AI 추천 로직 통합, analyzer 경고 정리, 초대형 스크린 구조 개선 등을 중점 과제로 삼으면 전체 품질이 한 단계 더 상승할 것입니다.
