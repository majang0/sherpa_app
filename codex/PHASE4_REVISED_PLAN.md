# Phase 4 개정안 - AI 시스템 범위 재정의

**작성일**: 2025-09-20
**작성자**: Claude
**목적**: AI 사용 범위를 명확히 하고 효율적인 시스템 구축

---

## 🎯 핵심 변경사항

### AI 시스템 이원화 전략

| 기능 | AI 사용 | 구현 방식 | 이유 |
|------|---------|-----------|------|
| **플로팅 메시지** | ❌ 사용 안 함 | 정적 메시지만 | 빠른 응답, 일관성 |
| **분석 다이얼로그** | ✅ AI 사용 | Gemini/OpenAI | 깊이 있는 인사이트 |

---

## 📊 현재 시스템 구조

### 1. 플로팅 메시지 시스템 (정적)
```
global_sherpi_provider.dart
    ↓
StaticSherpiManager (고정)
    ↓
sherpi_dialogues.dart (정적 메시지)
```

**특징**:
- 즉각적인 응답 (<100ms)
- 일관된 메시지 품질
- 비용 없음
- 오프라인 작동

### 2. 분석 다이얼로그 시스템 (AI 가능)
```
enhanced_today_analysis_dialog.dart
    ↓
ActivityAnalysisService
    ↓
AiInsightGenerator
    ↓
Gemini AI / OpenAI (선택적)
```

**특징**:
- 깊이 있는 분석 (1-3초)
- 개인화된 인사이트
- 사용자 행동 기반 추천
- 온디맨드 실행

---

## 🔧 Phase 4 수정된 작업 내용

### Task 1: 플로팅 메시지 정적 고정 (1일)

**목표**: SherpiProvider가 항상 정적 메시지만 사용하도록 고정

**구현**:
```dart
// lib/shared/providers/global_sherpi_provider.dart
class GlobalSherpiProvider extends StateNotifier<SherpiState> {
  // AI Manager 제거, Static만 사용
  final SherpiMessageManager _messageManager = StaticSherpiManager();

  // debugForceAI 플래그 제거 또는 무시
  // enableAIForNextMessage() 메서드 제거

  GlobalSherpiProvider({required Ref ref})
    : super(SherpiState.initial()) {
    // 정적 메시지만 사용
    print('✅ Sherpi: 정적 메시지 모드로 초기화');
  }
}
```

**정리 작업**:
- `OpenAISherpiManager` 사용 코드 제거
- `enableAIForNextMessage()` 호출 제거
- `debugForceAI` 플래그 제거
- DI 구조 단순화

---

### Task 2: 분석 다이얼로그 AI Feature Flag (2일)

**목표**: 분석 기능에서만 AI 사용 여부를 제어

**Feature Flag 구현**:
```dart
// lib/core/config/analysis_ai_config.dart (신규)
class AnalysisAIConfig {
  // 분석 AI 모드
  static const String ANALYSIS_AI_MODE = 'analysis_ai_mode';

  // 가능한 값
  static const String MODE_DISABLED = 'disabled';     // AI 완전 비활성화
  static const String MODE_MOCK = 'mock';            // Mock AI (테스트용)
  static const String MODE_GEMINI = 'gemini';        // Gemini AI
  static const String MODE_OPENAI = 'openai';        // OpenAI GPT

  // 비용 제한 (분석 전용)
  static const String MAX_ANALYSIS_PER_DAY = 'max_analysis_per_day';
  static const String ANALYSIS_CACHE_HOURS = 'analysis_cache_hours';
}

// lib/shared/providers/analysis_config_provider.dart (신규)
final analysisConfigProvider = StateNotifierProvider<AnalysisConfigNotifier, AnalysisConfigState>((ref) {
  return AnalysisConfigNotifier();
});

class AnalysisConfigState {
  final String aiMode;
  final int maxAnalysisPerDay;
  final int cacheHours;

  bool get isAIEnabled => aiMode != AnalysisAIConfig.MODE_DISABLED;
  bool get isGeminiEnabled => aiMode == AnalysisAIConfig.MODE_GEMINI;
  bool get isOpenAIEnabled => aiMode == AnalysisAIConfig.MODE_OPENAI;
}
```

---

### Task 3: AiInsightGenerator 리팩토링 (1일)

**목표**: Feature Flag에 따라 다른 AI 소스 사용

**구현**:
```dart
// lib/features/sherpi/analysis/services/ai_insight_generator.dart
class AiInsightGenerator {
  final AnalysisConfigState _config;
  SherpiDialogueSource? _aiSource;

  AiInsightGenerator(this._config) {
    _initializeAISource();
  }

  void _initializeAISource() {
    switch (_config.aiMode) {
      case AnalysisAIConfig.MODE_GEMINI:
        _aiSource = EnhancedGeminiDialogueSource();
        break;
      case AnalysisAIConfig.MODE_OPENAI:
        _aiSource = OpenAIDialogueSource();
        break;
      case AnalysisAIConfig.MODE_MOCK:
        _aiSource = MockAnalysisAISource();
        break;
      default:
        _aiSource = null; // Fallback to rule-based
    }
  }

  Future<List<Insight>> generateInsights(
    GlobalUser user,
    AnalysisResult analysisResult,
  ) async {
    // AI 사용 가능 여부 체크
    if (!_config.isAIEnabled || _aiSource == null) {
      return _generateRuleBasedInsights(user, analysisResult);
    }

    // 일일 한도 체크
    if (await _isQuotaExceeded()) {
      return _generateRuleBasedInsights(user, analysisResult);
    }

    try {
      // AI 인사이트 생성
      return await _generateAIInsights(user, analysisResult);
    } catch (e) {
      // 에러 시 규칙 기반 폴백
      print('❌ AI 인사이트 실패, 규칙 기반 사용: $e');
      return _generateRuleBasedInsights(user, analysisResult);
    }
  }
}
```

---

### Task 4: 분석 캐시 시스템 (1일)

**목표**: 분석 결과를 캐싱하여 AI 호출 최소화

**구현**:
```dart
// lib/core/ai/cache/analysis_cache.dart (신규)
class AnalysisCache {
  static const String _cacheKey = 'analysis_cache';

  // 분석 결과 캐시
  Future<AnalysisResult?> getCachedAnalysis({
    required String userId,
    required String analysisType,
    required DateTime date,
  }) async {
    final key = _buildKey(userId, analysisType, date);
    final cached = await _storage.get(key);

    if (cached != null) {
      final age = DateTime.now().difference(cached.timestamp);
      if (age.inHours < _config.cacheHours) {
        return cached.result;
      }
    }

    return null;
  }

  // 캐시 저장
  Future<void> cacheAnalysis({
    required String userId,
    required String analysisType,
    required DateTime date,
    required AnalysisResult result,
  }) async {
    final key = _buildKey(userId, analysisType, date);
    await _storage.set(key, CachedAnalysis(
      result: result,
      timestamp: DateTime.now(),
    ));
  }
}
```

---

### Task 5: 사용량 추적 (분석 전용) (1일)

**목표**: 분석 AI 사용량만 추적

**구현**:
```dart
// lib/core/ai/monitoring/analysis_usage_tracker.dart (신규)
class AnalysisUsageTracker {
  // 분석 사용량 기록
  Future<void> recordAnalysis({
    required String userId,
    required String analysisType,
    required int tokensUsed,
    required double cost,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final stats = await _loadDailyStats(today);

    stats.analysisCount++;
    stats.totalTokens += tokensUsed;
    stats.totalCost += cost;

    await _saveDailyStats(today, stats);

    // 한도 체크
    if (stats.analysisCount > _config.maxAnalysisPerDay) {
      throw AnalysisQuotaExceededException('일일 분석 한도 초과');
    }
  }

  // 할당량 확인
  Future<bool> isQuotaAvailable() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final stats = await _loadDailyStats(today);
    return stats.analysisCount < _config.maxAnalysisPerDay;
  }
}
```

---

## 📊 예상 효과

### 비용 절감
| 항목 | 이전 (전체 AI) | 현재 (분석만 AI) | 절감률 |
|------|---------------|-----------------|--------|
| 일일 API 호출 | ~1000회 | ~50회 | 95% |
| 월간 비용 | $150-300 | $10-20 | 93% |
| 응답 시간 | 1-3초 (모든 메시지) | <100ms (플로팅) | - |

### 성능 개선
- **플로팅 메시지**: 항상 즉각 응답
- **분석 다이얼로그**: 필요시에만 AI 사용
- **캐시 활용**: 동일 날짜 재분석 방지

### 사용자 경험
- 메시지 일관성 향상
- 응답 속도 개선
- 오프라인 지원 (플로팅 메시지)
- 깊이 있는 분석은 유지

---

## 🚀 구현 순서

### Week 1
1. **Day 1**: 플로팅 메시지 정적 고정
2. **Day 2-3**: 분석 AI Feature Flag 구현
3. **Day 4**: AiInsightGenerator 리팩토링
4. **Day 5**: 분석 캐시 시스템

### Week 2 (선택)
1. **Day 1**: 사용량 추적 시스템
2. **Day 2**: Mock AI 테스트 환경
3. **Day 3**: 통합 테스트
4. **Day 4**: 문서화

---

## ⚠️ 주의사항

### 1. 플로팅 메시지
- **절대 AI 사용 안 함**
- Phase 2의 정적 메시지 개선은 여전히 유효
- 시간대별, 마일스톤별 메시지 다양화 가능

### 2. 분석 다이얼로그
- **선택적 AI 사용**
- 항상 규칙 기반 폴백 준비
- 캐시 우선 정책

### 3. 마이그레이션
- 기존 OpenAISherpiManager 코드 정리
- 불필요한 DI 구조 제거
- 테스트 코드 업데이트

---

## 🎯 성공 지표

- [ ] 플로팅 메시지 응답 시간 <100ms
- [ ] 분석 AI 일일 사용량 <50회
- [ ] 월간 AI 비용 <$20
- [ ] 캐시 히트율 >60% (분석)
- [ ] 사용자 만족도 유지

---

## 📝 Phase 2와의 관계

Phase 2 (정적 메시지 개선)는 여전히 유효합니다:
- 플로팅 메시지가 정적으로 고정되므로
- 메시지 다양성이 더욱 중요해짐
- 시간대별, 마일스톤별 메시지 구현 권장

---

## 💡 장점

1. **명확한 책임 분리**
   - 플로팅: 빠른 피드백
   - 분석: 깊은 인사이트

2. **비용 효율성**
   - 95% API 호출 감소
   - 93% 비용 절감

3. **성능 최적화**
   - 플로팅 메시지 항상 빠름
   - 분석은 캐시 활용

4. **개발 단순화**
   - DI 복잡도 감소
   - 테스트 용이성 향상

---

**준비 완료!** 새로운 Phase 4 전략으로 효율적인 AI 시스템을 구축하세요. 🚀