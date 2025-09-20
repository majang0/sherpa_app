# AI/Sherpi Consolidated Execution Plan (2025-09-20)

본 문서는 Codex 코드 리뷰 결과와 Claude가 제공한 세 문서
(`AI_SHERPI_COMPREHENSIVE_REVIEW_20250920.md`,
`AI_SHERPI_STRATEGIC_DIRECTION_20250920.md`,
`QUICK_ACTION_PLAN.md`)를 교차 검토한 뒤
향후 실행 단계를 통합 정리한 계획서입니다.

---

## 1. 공통 인식 요약
- **구조 상태**: DI 기반 구조는 양호하나 `lib/core/ai/` 루트에 옛 파일이 남아 중복·혼선 발생.
- **메시지 콘텐츠**: 풍부한 정적 대사 자산이 존재하며 즉시 활용 가치가 큼.
- **AI 연동**: OpenAI 경로와 하이브리드 매니저는 존재하지만 현재 비활성 상태.
- **기술 부채**: 중복 파일, 미완결 Provider, 캐시 설계 미비, 테스트 복구 필요 등.
- **전략**: “정리 → 강화 → 통합 → 혁신(Clean → Enhance → Integrate → Innovate)” 단계적 접근이 공통 제안.

---

## 2. 단계별 실행 계획

### Phase 0 — 안전판 정비 (D+0)
1. **중복/잔여 파일 삭제 확정**
   - 루트 `lib/core/ai/*.dart` 잔여본 및 `C:sherpa_app...` 오염 파일 제거.
   - 삭제 후 모든 임포트 경로를 `package:sherpa_app/core/ai/...` 하위 디렉터리로 통일.
2. **Git 상태 정리**
   - 복구된 테스트 3종 등 미추적 파일 `git add`.
   - `.bak` 등 임시 파일 처리 방침 수립 (필요 시 보관 디렉터리 분리).

### Phase 1 — WSL 품질 루프 복원 (D+0~1)
1. **Flutter/Dart 스크립트 LF 교정** (CRLF 문제 재발 방지).
2. **`dart format`, `dart analyze`, `flutter test` WSL 재실행**
   - Analyzer 경고/에러 최신화, 14/14 테스트 복구 확인.
3. **Sherpi 결과물 스냅샷 기록**
   - `codex/ai_sherpi_structure_journal.md` 업데이트.

### Phase 2 — 정적 시스템 고도화 (D+1~4)
1. **정적 메시지 개선**
   - 시간대·연속일수·관계 레벨 기반 메시지 가변화 (Quick Action Plan 반영).
   - 중복/누락 메시지 QA.
2. **감정/관계 연동 활성화**
   - `SherpiState` 색상 적용, Emotion Analyzer 기본 경로 연결.
   - Relationship milestone 메시지/보상 로직 점검.
3. **로깅 및 히스토리**
   - 최소한의 Debug/Info 로그 체계 구축 (필요 시 Feature Flag).

### Phase 3 — 전역 추천 & 캐시 정비 (D+4~7)
1. **`global_ai_recommendation_provider`·`MeetingRecommendationAI` 정렬**
   - SherpiInsights 파라미터 전달 설계 확정.
   - 캐시 키에 미팅 세트/유저 ID 포함.
2. **`AiMessageCache` 강화**
   - 사용자 ID 포함 키, TTL 정책 재검토, 캐시 상태 Metric 노출.
3. **DI 기반 Sherpi Manager Provider 복구**
   - `.bak` 파일 정식화, `global_sherpi_provider`에서 주입.

### Phase 4 — AI 재도입 준비 (D+7~14)
1. **Feature Flag/Toggle 설계**
   - Static/Hybrid/AI 엔진 전환을 위한 환경 변수 및 런타임 제어.
2. **비용/성능 가드레일**
   - 토큰 사용량 추적, 최소 캐싱 전략.
3. **사전 테스트 플로우**
   - Mock AI 응답, 네트워크 오류 Handling, 롤백 시나리오 작성.

### Phase 5 — 문서·거버넌스 정비 (상시)
1. **문서 싱크**
   - `docs/sherpi_system.md`, `codex/ai_sherpi_progress_status.md` 지속 업데이트.
2. **Metric/KPI 수립**
   - 메시지 지연, 캐시 Hit, 사용자 반응 지표 수집 파이프 설계.
3. **릴리즈 체크리스트 표준화**
   - Analyzer/테스트/메시지 QA/Feature Flag 확인 항목 명문화.

---

## 3. Codex vs. Claude 제안 차이 & 보완점
| 항목 | Claude 제안 | Codex 리뷰 | 통합 결론 |
| --- | --- | --- | --- |
| 파일 구조 | 루트 중복 파일 즉시 삭제 | 중복이 실 배포에 리스크 | **즉시 제거 후 임포트 통일** |
| 정적 메시지 | 시간·마일스톤 변주 추가 | 기존 자산 최대 활용 | **Phase 2에서 실행** |
| Emotion/Relationship | 활성화 권장 | Provider/DI 부재 문제 지적 | **DI 복구 후 단계적 연결** |
| 추천 AI | 캐시·Feature Flag 제안 | Insights 전달/캐시 키 부실 | **Phase 3에서 구조 정리 후 Flag 도입** |
| AI 재활성화 | 장기 로드맵 (비용 감시) | 초기부터 안전장치 필요 | **Flag+비용 모니터 함께 준비** |

---

## 4. 의존 작업 & 선행 조건
- PowerShell 측에서도 동일 파일 삭제/정리 적용 (충돌 방지).
- 테스트 복구가 완료됐으므로 추가 케이스 작성 시 구조 유지.
- Analyzer 경고가 실제 “경고/정보”인지 확인 후 우선순위 분류.
- 문서 업데이트는 Phase 종료 시마다 실행.

---

## 5. 즉시 다음 조치 (D+0)
1. 루트 `lib/core/ai/*.dart` 잔여 파일 및 `C:sherpa_app…` 파일 삭제.
2. Sherpi 테스트 3종 `git add` 및 기본 실행 확인.
3. Flutter 스크립트 CRLF→LF 변환 최종 점검 후 `dart format` 재시도.

---

## 6. 추적 및 보고
- **진행 로그**: `codex/ai_sherpi_structure_journal.md`
- **상태 표**: `codex/ai_sherpi_progress_status.md`
- **핵심 의사결정 기록**: `docs/sherpi_system.md` 및 새 회의 노트.

---

_작성자: Codex (2025-09-20)_
