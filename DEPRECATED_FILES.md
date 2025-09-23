# 제거 예정 파일 목록

## Phase 1 (즉시 제거 가능)
다음 파일들은 UnifiedSherpiManager로 대체되어 안전하게 제거 가능합니다:

### Message Managers (통합 완료)
- [ ] `lib/core/ai/managers/openai_sherpi_manager.dart` - UnifiedSherpiManager로 대체
- [ ] `lib/core/ai/managers/static_sherpi_manager.dart` - UnifiedSherpiManager로 대체

## Phase 2 (의존성 수정 후 제거)
다음 파일들은 다른 파일의 의존성을 수정한 후 제거 가능합니다:

### AI 관련 서비스 (현재 미사용)
- [ ] `lib/core/ai/cache/ai_message_cache.dart` - 캐시 시스템 비활성화
- [ ] `lib/core/ai/sources/openai_dialogue_source.dart` - AI 통합 비활성화

### 의존 파일들 (수정 필요)
이들 파일은 위 서비스를 사용하므로 수정이 필요합니다:
- `lib/core/utils/phase1_performance_benchmark.dart` - AiMessageCache 사용
- `lib/core/utils/sherpi_system_checker.dart` - AiMessageCache 사용
- `lib/features/meetings/ai/meeting_recommendation_ai.dart` - OpenAIDialogueSource 사용
- `lib/features/sherpi/analysis/services/ai_insight_generator.dart` - OpenAIDialogueSource 사용

## Phase 3 (장기 계획)
### Chat Providers 통합
- [ ] `lib/features/sherpi/chat/providers/chat_conversation_provider.dart` (430줄)
- [ ] `lib/features/sherpi/chat/providers/enhanced_chat_conversation_provider.dart` (713줄)
→ 단일 UnifiedChatProvider로 통합 예정

## 제거 전 체크리스트
1. ✅ UnifiedSherpiManager 생성 완료
2. ✅ global_sherpi_provider 수정 완료
3. ✅ SherpiTextUtils 생성 완료
4. ⬜ 의존 파일들 수정
5. ⬜ 테스트 실행 및 검증
6. ⬜ 파일 제거

## 주의사항
- 제거 전 반드시 `flutter analyze` 실행
- 제거 전 반드시 `flutter test` 실행
- Git 브랜치에서 작업하여 롤백 가능하도록 유지

---
*작성일: 2025-09-22*
*최종 제거 예정일: Phase별 진행*