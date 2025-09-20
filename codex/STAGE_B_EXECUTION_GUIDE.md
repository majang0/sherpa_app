# Stage B 실행 가이드 - 분석 AI Feature Flag 도입

**작성일**: 2025-09-20
**대상**: Codex
**목적**: 분석 다이얼로그 전용 AI Feature Flag 시스템 구축

---

## ✅ Stage A 완료 확인

**완료된 작업**:
- ✅ global_sherpi_provider에서 AI 훅 제거 (`debugForceAI`, `enableAIForNextMessage`)
- ✅ StaticSherpiManager만 사용하도록 고정
- ✅ 레거시 DI 파일 정리 (sherpi_manager_provider.dart.bak 삭제)
- ✅ 플로팅 메시지 정적 경로 QA 완료

**결과**: 플로팅 메시지가 100% 정적 메시지로 작동 확인

---

## 🎯 Stage B 목표

분석 다이얼로그에서만 AI를 선택적으로 사용할 수 있는 Feature Flag 시스템 구축

---

## 📋 Stage B 작업 목록

### Task 1: Analysis AI Config 생성 (30분)

**파일**: `lib/core/config/analysis_ai_config.dart` (신규)

```dart
/// 분석 다이얼로그 전용 AI 설정
class AnalysisAIConfig {
  // AI 모드 설정
  static const String AI_MODE_KEY = 'analysis_ai_mode';

  // 사용 가능한 모드
  static const String MODE_DISABLED = 'disabled';    // AI 완전 비활성화
  static const String MODE_MOCK = 'mock';           // Mock AI (테스트용)
  static const String MODE_GEMINI = 'gemini';       // Gemini AI 사용
  static const String MODE_OPENAI = 'openai';       // OpenAI GPT 사용

  // 사용량 제한
  static const String MAX_DAILY_ANALYSES_KEY = 'max_daily_analyses';
  static const String CACHE_DURATION_HOURS_KEY = 'analysis_cache_hours';

  // 기본값
  static const String DEFAULT_MODE = MODE_DISABLED;
  static const int DEFAULT_MAX_DAILY_ANALYSES = 10;
  static const int DEFAULT_CACHE_HOURS = 12;

  // 성능 설정
  static const String ANALYSIS_TIMEOUT_MS_KEY = 'analysis_timeout_ms';
  static const int DEFAULT_TIMEOUT_MS = 10000; // 10초
}
```

---

### Task 2: Analysis Config Provider 생성 (45분)

**파일**: `lib/shared/providers/analysis_config_provider.dart` (신규)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/analysis_ai_config.dart';

/// 분석 AI 설정 상태
class AnalysisConfigState {
  final String aiMode;
  final int maxDailyAnalyses;
  final int cacheHours;
  final int timeoutMs;

  const AnalysisConfigState({
    required this.aiMode,
    required this.maxDailyAnalyses,
    required this.cacheHours,
    required this.timeoutMs,
  });

  // 편의 메서드
  bool get isAIEnabled => aiMode != AnalysisAIConfig.MODE_DISABLED;
  bool get isMockMode => aiMode == AnalysisAIConfig.MODE_MOCK;
  bool get isGeminiMode => aiMode == AnalysisAIConfig.MODE_GEMINI;
  bool get isOpenAIMode => aiMode == AnalysisAIConfig.MODE_OPENAI;

  AnalysisConfigState copyWith({
    String? aiMode,
    int? maxDailyAnalyses,
    int? cacheHours,
    int? timeoutMs,
  }) {
    return AnalysisConfigState(
      aiMode: aiMode ?? this.aiMode,
      maxDailyAnalyses: maxDailyAnalyses ?? this.maxDailyAnalyses,
      cacheHours: cacheHours ?? this.cacheHours,
      timeoutMs: timeoutMs ?? this.timeoutMs,
    );
  }
}

/// 분석 AI 설정 관리자
class AnalysisConfigNotifier extends StateNotifier<AnalysisConfigState> {
  final SharedPreferences _prefs;

  AnalysisConfigNotifier(this._prefs)
    : super(AnalysisConfigState(
        aiMode: _prefs.getString(AnalysisAIConfig.AI_MODE_KEY)
            ?? AnalysisAIConfig.DEFAULT_MODE,
        maxDailyAnalyses: _prefs.getInt(AnalysisAIConfig.MAX_DAILY_ANALYSES_KEY)
            ?? AnalysisAIConfig.DEFAULT_MAX_DAILY_ANALYSES,
        cacheHours: _prefs.getInt(AnalysisAIConfig.CACHE_DURATION_HOURS_KEY)
            ?? AnalysisAIConfig.DEFAULT_CACHE_HOURS,
        timeoutMs: _prefs.getInt(AnalysisAIConfig.ANALYSIS_TIMEOUT_MS_KEY)
            ?? AnalysisAIConfig.DEFAULT_TIMEOUT_MS,
      ));

  /// AI 모드 변경
  Future<void> setAIMode(String mode) async {
    await _prefs.setString(AnalysisAIConfig.AI_MODE_KEY, mode);
    state = state.copyWith(aiMode: mode);
    print('📊 분석 AI 모드 변경: $mode');
  }

  /// 일일 분석 한도 설정
  Future<void> setMaxDailyAnalyses(int limit) async {
    await _prefs.setInt(AnalysisAIConfig.MAX_DAILY_ANALYSES_KEY, limit);
    state = state.copyWith(maxDailyAnalyses: limit);
  }

  /// 캐시 지속 시간 설정
  Future<void> setCacheHours(int hours) async {
    await _prefs.setInt(AnalysisAIConfig.CACHE_DURATION_HOURS_KEY, hours);
    state = state.copyWith(cacheHours: hours);
  }
}

/// Provider 정의
final analysisConfigProvider = StateNotifierProvider<AnalysisConfigNotifier, AnalysisConfigState>((ref) {
  throw UnimplementedError('SharedPreferences를 main.dart에서 override 필요');
});
```

---

### Task 3: Mock AI Source 구현 (30분)

**파일**: `lib/core/ai/sources/mock_analysis_ai_source.dart` (신규)

```dart
import 'dart:async';
import 'dart:math';
import '../../../core/constants/sherpi_dialogues.dart';

/// 테스트용 Mock AI 소스
class MockAnalysisAISource implements SherpiDialogueSource {
  final Random _random = Random();

  // 미리 정의된 분석 템플릿
  static const Map<String, List<String>> _mockTemplates = {
    'exercise': [
      '오늘 운동을 {duration}분 하셨네요! 꾸준함이 인상적입니다.',
      '{exerciseType} 운동을 {duration}분 완료! 목표 달성까지 {remaining}% 남았습니다.',
      '운동 강도가 적절했습니다. 내일은 5분 더 도전해보세요!',
    ],
    'reading': [
      '{bookTitle}을(를) 읽으셨군요! {pages}페이지는 훌륭한 성과입니다.',
      '독서 습관이 점점 좋아지고 있어요. 이번 주 목표의 {progress}% 달성!',
      '{category} 분야 독서는 지식 확장에 도움이 됩니다.',
    ],
    'diary': [
      '오늘의 감정: {mood}. 기록하는 습관이 마음 건강에 도움이 됩니다.',
      '일기를 {consecutiveDays}일 연속 작성하셨네요! 대단합니다.',
      '감정을 기록하는 것은 자기 이해의 첫걸음입니다.',
    ],
    'comprehensive': [
      '오늘 하루 {completedActivities}개 활동을 완료하셨습니다!',
      '전체 목표의 {overallProgress}%를 달성했습니다. 계속 힘내세요!',
      '균형 잡힌 하루였습니다. 운동, 독서, 일기 모두 완료!',
    ],
  };

  @override
  Future<String> getDialogue(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 응답 지연 시뮬레이션 (0.5~1.5초)
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    // Mock 분석 생성
    final analysisType = userContext?['analysisType'] ?? 'comprehensive';
    final templates = _mockTemplates[analysisType] ?? _mockTemplates['comprehensive']!;
    final template = templates[_random.nextInt(templates.length)];

    // 플레이스홀더 치환
    String result = template;
    userContext?.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });

    // 남은 플레이스홀더를 기본값으로 치환
    result = result.replaceAll(RegExp(r'\{[^}]+\}'), '정보 없음');

    return '🤖 [Mock AI] $result';
  }
}
```

---

### Task 4: AiInsightGenerator 수정 (1시간)

**파일**: `lib/features/sherpi/analysis/services/ai_insight_generator.dart` (수정)

**변경 내용**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/analysis_config_provider.dart';
import '../../../../core/ai/sources/mock_analysis_ai_source.dart';

class AiInsightGenerator {
  final AnalysisConfigState _config;
  SherpiDialogueSource? _aiSource;

  AiInsightGenerator(this._config) {
    _initializeAISource();
  }

  void _initializeAISource() {
    switch (_config.aiMode) {
      case AnalysisAIConfig.MODE_GEMINI:
        try {
          _aiSource = EnhancedGeminiDialogueSource();
          print('✅ Gemini AI 소스 초기화 완료');
        } catch (e) {
          print('❌ Gemini 초기화 실패: $e');
          _aiSource = null;
        }
        break;

      case AnalysisAIConfig.MODE_OPENAI:
        // OpenAI 소스는 나중에 구현
        print('⚠️ OpenAI 모드는 아직 미구현');
        _aiSource = null;
        break;

      case AnalysisAIConfig.MODE_MOCK:
        _aiSource = MockAnalysisAISource();
        print('🎭 Mock AI 소스 사용');
        break;

      case AnalysisAIConfig.MODE_DISABLED:
      default:
        _aiSource = null;
        print('🚫 AI 비활성화 - 규칙 기반 분석만 사용');
    }
  }

  Future<List<Insight>> generateAIInsights(
    GlobalUser user,
    AnalysisResult analysisResult,
  ) async {
    // AI 비활성화 또는 소스 없음
    if (!_config.isAIEnabled || _aiSource == null) {
      return _generateRuleBasedInsights(user, analysisResult);
    }

    try {
      // 타임아웃 적용
      final aiResponse = await _aiSource!
        .getDialogue(
          SherpiContext.general,
          {
            'analysisType': analysisResult.type,
            'user_summary': _buildUserDataSummary(user, analysisResult),
          },
          {
            'analysis_type': 'deep_insights',
            'generate_recommendations': true,
          },
        )
        .timeout(Duration(milliseconds: _config.timeoutMs));

      // AI 응답 파싱
      return _parseAIResponse(aiResponse);

    } catch (e) {
      print('❌ AI 인사이트 생성 실패, 규칙 기반 폴백: $e');
      return _generateRuleBasedInsights(user, analysisResult);
    }
  }

  // 규칙 기반 인사이트 (폴백용)
  List<Insight> _generateRuleBasedInsights(
    GlobalUser user,
    AnalysisResult analysisResult,
  ) {
    print('📏 규칙 기반 인사이트 생성');
    // 기존 정적 분석 로직
    return [
      Insight(
        type: InsightType.observation,
        title: '오늘의 활동',
        description: '${analysisResult.completedActivities}개 활동 완료',
        icon: '📊',
      ),
      // ... 추가 규칙 기반 인사이트
    ];
  }
}
```

---

### Task 5: Provider Override 설정 (30분)

**파일**: `lib/main.dart` (수정)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences 초기화
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // 기존 overrides...

        // 분석 AI 설정 Provider 추가
        analysisConfigProvider.overrideWith((ref) {
          return AnalysisConfigNotifier(prefs);
        }),
      ],
      child: const SherpaApp(),
    ),
  );
}
```

---

## 🧪 테스트 방법

### 1. Mock 모드 테스트

```dart
// 테스트 코드 또는 디버그 콘솔에서 실행
final config = ref.read(analysisConfigProvider.notifier);
await config.setAIMode(AnalysisAIConfig.MODE_MOCK);

// 분석 다이얼로그 열기
// Mock AI 응답이 "[Mock AI]" 태그와 함께 표시되는지 확인
```

### 2. 모드 전환 테스트

```dart
// Disabled → Mock → Gemini 순으로 전환
await config.setAIMode(AnalysisAIConfig.MODE_DISABLED); // 규칙 기반만
await config.setAIMode(AnalysisAIConfig.MODE_MOCK);     // Mock AI
await config.setAIMode(AnalysisAIConfig.MODE_GEMINI);   // 실제 AI (API 키 필요)
```

### 3. 단위 테스트

**파일**: `test/providers/analysis_config_provider_test.dart` (신규)

```dart
void main() {
  group('AnalysisConfigProvider', () {
    test('기본 모드는 disabled', () {
      final state = AnalysisConfigState(
        aiMode: AnalysisAIConfig.DEFAULT_MODE,
        maxDailyAnalyses: 10,
        cacheHours: 12,
        timeoutMs: 10000,
      );

      expect(state.isAIEnabled, false);
      expect(state.aiMode, AnalysisAIConfig.MODE_DISABLED);
    });

    test('Mock 모드 전환', () {
      final state = AnalysisConfigState(
        aiMode: AnalysisAIConfig.MODE_MOCK,
        maxDailyAnalyses: 10,
        cacheHours: 12,
        timeoutMs: 10000,
      );

      expect(state.isAIEnabled, true);
      expect(state.isMockMode, true);
    });
  });
}
```

---

## ✅ 체크리스트

### 필수 완료 항목
- [ ] analysis_ai_config.dart 생성
- [ ] analysis_config_provider.dart 생성
- [ ] mock_analysis_ai_source.dart 구현
- [ ] AiInsightGenerator 수정
- [ ] main.dart Provider override 추가

### 검증 항목
- [ ] Mock 모드에서 분석 다이얼로그 정상 작동
- [ ] 모드 전환 시 적절한 소스 사용
- [ ] Disabled 모드에서 규칙 기반 폴백
- [ ] 타임아웃 동작 확인

---

## 🚨 주의사항

1. **플로팅 메시지와 독립성 유지**
   - 이 설정은 분석 다이얼로그에만 영향
   - global_sherpi_provider는 건드리지 않음

2. **기본 모드는 DISABLED**
   - 안전을 위해 기본은 AI 비활성화
   - 명시적으로 활성화해야 AI 사용

3. **Mock 모드 우선 테스트**
   - 실제 AI API 없이도 테스트 가능
   - Mock 응답에 [Mock AI] 태그 표시

4. **에러 처리**
   - AI 실패 시 항상 규칙 기반으로 폴백
   - 사용자에게 중단 없는 경험 제공

---

## 📊 예상 결과

Stage B 완료 후:
- 분석 다이얼로그에서 AI 모드 선택 가능
- Mock 모드로 API 없이 테스트 가능
- 규칙 기반 폴백으로 안정성 확보
- Feature Flag로 런타임 제어 가능

---

## 🎯 다음 단계 (Stage C)

Stage B 완료 확인 후 진행:
1. 분석 결과 캐시 구현
2. 일일 사용량 추적
3. 비용 모니터링

---

**Stage B 시작 준비 완료!** Mock 모드부터 구현하여 안전하게 테스트하세요. 🚀