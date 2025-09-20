# 🎯 AI & 셰르피 시스템 최적화 - Phase 5-6 작업 지시서

**작성일**: 2025-09-20 16:15
**작성자**: Claude (PowerShell 환경)
**대상**: Codex (WSL 환경)
**목표**: Phase 5-6 완료를 통한 프로젝트 100% 마무리

---

## 📊 현재 상황 요약

### ✅ 완료된 작업 (Claude - PowerShell)
1. **analyzer 캐시 정리 완료**
   - `dart pub cache clean` 실행
   - `flutter clean` 실행
   - `flutter pub get` 의존성 재설치

2. **품질 재검증 완료**
   - `dart format`: 245개 파일 처리 (7개 파일 UTF-8 인코딩 문제 발견)
   - `flutter test`: 11/11 통과 유지
   - 테스트 리포트 업데이트 완료

### ⚠️ 발견된 문제
- **UTF-8 인코딩 문제 파일들** (Windows 환경):
  - `lib/core/ai/managers/openai_sherpi_manager.dart`
  - `lib/core/ai/managers/static_sherpi_manager.dart`
  - `lib/core/ai/services/activity_analysis_service.dart`
  - `lib/core/ai/services/activity_prompt_templates.dart`
  - `lib/core/ai/sources/enhanced_gemini_dialogue_source.dart`
  - `lib/core/ai/sources/openai_dialogue_source.dart`
  - `lib/features/sherpi/domain/models/sherpi_relationship_model.dart`

---

## 🔴 우선순위 1: 테스트 파일 복구 (WSL 환경 필수)

### 작업 내용
삭제된 3개의 테스트 파일을 WSL 환경에서 UTF-8 without BOM으로 재생성

### 복구해야 할 파일들
1. `test/features/sherpi/managers/openai_sherpi_manager_test.dart`
2. `test/features/sherpi/managers/sherpi_managers_test.dart`
3. `test/features/sherpi/providers/global_ai_recommendation_provider_test.dart`

### 실행 명령어 (WSL)
```bash
# 1. 디렉토리 생성
mkdir -p test/features/sherpi/managers
mkdir -p test/features/sherpi/providers

# 2. Git 히스토리에서 파일 복구
git show HEAD~5:test/features/sherpi/managers/openai_sherpi_manager_test.dart > test/features/sherpi/managers/openai_sherpi_manager_test.dart
git show HEAD~5:test/features/sherpi/managers/sherpi_managers_test.dart > test/features/sherpi/managers/sherpi_managers_test.dart
git show HEAD~5:test/features/sherpi/providers/global_ai_recommendation_provider_test.dart > test/features/sherpi/providers/global_ai_recommendation_provider_test.dart

# 3. UTF-8 without BOM 변환
for file in test/features/sherpi/**/*.dart; do
  if [ -f "$file" ]; then
    # BOM 제거 및 UTF-8 변환
    sed -i '1s/^\xEF\xBB\xBF//' "$file"
    iconv -f UTF-8 -t UTF-8 -c "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  fi
done

# 4. 테스트 실행 확인
flutter test
```

### 예상 결과
- 테스트 14/14 통과 달성
- 모든 테스트 파일 UTF-8 without BOM 인코딩

---

## 🟡 우선순위 2: lib 폴더 인코딩 문제 해결 (WSL 환경)

### 작업 내용
lib 폴더의 7개 파일 인코딩 문제 해결

### 실행 명령어 (WSL)
```bash
# 문제 파일 목록
files=(
  "lib/core/ai/managers/openai_sherpi_manager.dart"
  "lib/core/ai/managers/static_sherpi_manager.dart"
  "lib/core/ai/services/activity_analysis_service.dart"
  "lib/core/ai/services/activity_prompt_templates.dart"
  "lib/core/ai/sources/enhanced_gemini_dialogue_source.dart"
  "lib/core/ai/sources/openai_dialogue_source.dart"
  "lib/features/sherpi/domain/models/sherpi_relationship_model.dart"
)

# UTF-8 without BOM 변환
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "Processing: $file"
    # BOM 제거
    sed -i '1s/^\xEF\xBB\xBF//' "$file"
    # UTF-8 재인코딩
    iconv -f UTF-8 -t UTF-8 -c "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  Fixed: $file"
  fi
done

# 포맷터 재실행
dart format lib test

# analyzer 실행
dart analyze
```

---

## 🟢 우선순위 3: AI 추천 UX 확장

### 3.1 모임 상세 화면 연동
**파일**: `lib/features/meetings/presentation/screens/meeting_detail_screen.dart`

```dart
// 1. import 추가
import '../../../../shared/providers/global_ai_recommendation_provider.dart';

// 2. build 메서드에서 AI 추천 상태 활용
final aiRecommendations = ref.watch(globalAIRecommendationProvider);

// 3. Sherpi 인사이트 표시 위젯 추가
if (aiRecommendations.recommendations.any((r) => r.meeting.id == meeting.id))
  _buildSherpiInsightCard(
    aiRecommendations.recommendations
      .firstWhere((r) => r.meeting.id == meeting.id)
      .sherpiInsights
  ),
```

### 3.2 추천 사유 문구 개선
**파일**: `lib/features/meetings/ai/models/ai_recommended_meeting.dart`

```dart
// Sherpi 인사이트 문구 개선
static const Map<String, String> insightTemplates = {
  'high_stamina_exercise': '💪 체력이 충만한 지금이 운동하기 딱 좋은 타이밍이에요!',
  'knowledge_boost': '📚 지적 호기심이 왕성한 시기! 새로운 배움에 도전해보세요.',
  'social_energy': '🤝 사회적 에너지가 넘치는 오늘, 사람들과 교류해보세요.',
  'willpower_peak': '🎯 의지력이 최고조! 도전적인 활동에 참여해보세요.',
  // ... 추가 템플릿
};
```

---

## 🔵 우선순위 4: 캐시/토글 정책 구현

### 4.1 캐시 정책 구현
**파일**: `lib/core/ai/cache/ai_message_cache.dart`

```dart
class AiMessageCache {
  static const Duration defaultTTL = Duration(hours: 1);
  static const int maxCacheSize = 100;

  // LRU 캐시 구현
  final LinkedHashMap<String, CacheEntry> _cache = LinkedHashMap();

  // 배치 프리패치
  Future<void> prefetchBatch(List<String> keys) async {
    // 구현
  }

  // TTL 기반 자동 삭제
  void _cleanExpiredEntries() {
    // 구현
  }
}
```

### 4.2 설정 화면 통합
**파일**: `lib/features/settings/presentation/screens/settings_screen.dart`

```dart
// AI 설정 섹션 추가
ListTile(
  title: Text('AI 기능'),
  subtitle: Text('Sherpi AI 설정'),
  trailing: Switch(
    value: ref.watch(aiSettingsProvider).forceAI,
    onChanged: (value) {
      ref.read(aiSettingsProvider.notifier).setForceAI(value);
    },
  ),
),
```

---

## 🟣 우선순위 5: 문서 및 자동화

### 5.1 CI/CD 스크립트 작성
**파일**: `.github/workflows/quality_check.yml`

```yaml
name: Quality Check
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart format --set-exit-if-changed lib test
      - run: dart analyze --fatal-errors
      - run: flutter test
```

### 5.2 최종 문서 정리
1. `codex/ai_sherpi_structure_journal.md` - 최종 결과 추가
2. `codex/ai_sherpi_progress_status.md` - 100% 완료 상태 업데이트
3. `docs/sherpi_system.md` - 최종 아키텍처 다이어그램 추가

---

## 📋 체크리스트

### Phase 5 (테스트 및 품질 보증)
- [ ] 테스트 파일 복구 (14/14 달성)
- [ ] 인코딩 문제 완전 해결
- [ ] Analyzer 0 errors 달성
- [ ] 성능 테스트 실행

### Phase 6 (배포 준비)
- [ ] AI 추천 UX 전체 화면 연동
- [ ] 캐시 정책 구현 및 테스트
- [ ] CI/CD 파이프라인 구축
- [ ] 최종 문서화 완료

---

## 🚀 예상 완료 시점

| 작업 | 예상 시간 | 담당 |
|------|----------|------|
| 테스트 복구 | 1시간 | Codex (WSL) |
| 인코딩 해결 | 30분 | Codex (WSL) |
| AI UX 확장 | 2시간 | Codex |
| 캐시 정책 | 1.5시간 | Codex |
| 문서화 | 1시간 | Codex + Claude |

**총 예상 시간**: 6시간
**목표 완료**: 2025-09-20 22:00

---

## 💡 중요 참고사항

1. **인코딩 문제는 WSL에서만 해결 가능**
   - Windows PowerShell에서는 UTF-8 BOM 문제 지속
   - WSL의 iconv, sed 명령어 활용 필수

2. **테스트 복구 우선**
   - 14/14 테스트 통과가 최우선 목표
   - 복구 후 즉시 커밋 권장

3. **점진적 커밋**
   - 각 작업 완료 시 즉시 커밋
   - 롤백 가능하도록 작은 단위로 진행

4. **협업 필요 시**
   - PowerShell 작업 필요하면 Claude 호출
   - 문서화는 함께 진행

---

**작업 시작하시면 진행 상황을 `codex/ai_sherpi_structure_journal.md`에 기록 부탁드립니다.**

화이팅! 💪