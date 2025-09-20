# Stage B 실행 가이드 (개정판) - OpenAI 중심 Feature Flag

**작성일**: 2025-09-20
**대상**: Codex
**목적**: 분석 다이얼로그 전용 AI Feature Flag 시스템 구축 (Gemini 제외)

---

## 🎯 변경사항

**이전**: disabled / mock / gemini / openai (4가지)
**현재**: disabled / mock / openai (3가지) ← Gemini 제거

---

## 📋 Stage B 작업 목록 (Gemini 제외 버전)

### Task 1: Analysis AI Config 생성 (30분)

**파일**: `lib/core/config/analysis_ai_config.dart` (신규)

```dart
/// 분석 다이얼로그 전용 AI 설정 (OpenAI 중심)
class AnalysisAIConfig {
  // AI 모드 설정
  static const String AI_MODE_KEY = 'analysis_ai_mode';

  // 사용 가능한 모드 (3가지로 단순화)
  static const String MODE_DISABLED = 'disabled';    // AI 완전 비활성화
  static const String MODE_MOCK = 'mock';           // Mock AI (테스트용)
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

  // OpenAI 전용 설정
  static const String OPENAI_MODEL_KEY = 'openai_model';
  static const String DEFAULT_OPENAI_MODEL = 'gpt-4-turbo-preview';
  static const String OPENAI_MAX_TOKENS_KEY = 'openai_max_tokens';
  static const int DEFAULT_MAX_TOKENS = 1000;
}
```

---

### Task 2: Analysis Config Provider 생성 (45분)

**파일**: `lib/shared/providers/analysis_config_provider.dart` (신규)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/analysis_ai_config.dart';

/// 분석 AI 설정 상태 (OpenAI 중심)
class AnalysisConfigState {
  final String aiMode;
  final int maxDailyAnalyses;
  final int cacheHours;
  final int timeoutMs;
  final String openaiModel;
  final int openaiMaxTokens;

  const AnalysisConfigState({
    required this.aiMode,
    required this.maxDailyAnalyses,
    required this.cacheHours,
    required this.timeoutMs,
    required this.openaiModel,
    required this.openaiMaxTokens,
  });

  // 편의 메서드
  bool get isAIEnabled => aiMode != AnalysisAIConfig.MODE_DISABLED;
  bool get isMockMode => aiMode == AnalysisAIConfig.MODE_MOCK;
  bool get isOpenAIMode => aiMode == AnalysisAIConfig.MODE_OPENAI;

  AnalysisConfigState copyWith({
    String? aiMode,
    int? maxDailyAnalyses,
    int? cacheHours,
    int? timeoutMs,
    String? openaiModel,
    int? openaiMaxTokens,
  }) {
    return AnalysisConfigState(
      aiMode: aiMode ?? this.aiMode,
      maxDailyAnalyses: maxDailyAnalyses ?? this.maxDailyAnalyses,
      cacheHours: cacheHours ?? this.cacheHours,
      timeoutMs: timeoutMs ?? this.timeoutMs,
      openaiModel: openaiModel ?? this.openaiModel,
      openaiMaxTokens: openaiMaxTokens ?? this.openaiMaxTokens,
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
        openaiModel: _prefs.getString(AnalysisAIConfig.OPENAI_MODEL_KEY)
            ?? AnalysisAIConfig.DEFAULT_OPENAI_MODEL,
        openaiMaxTokens: _prefs.getInt(AnalysisAIConfig.OPENAI_MAX_TOKENS_KEY)
            ?? AnalysisAIConfig.DEFAULT_MAX_TOKENS,
      ));

  /// AI 모드 변경
  Future<void> setAIMode(String mode) async {
    if (mode != AnalysisAIConfig.MODE_DISABLED &&
        mode != AnalysisAIConfig.MODE_MOCK &&
        mode != AnalysisAIConfig.MODE_OPENAI) {
      print('⚠️ 잘못된 AI 모드: $mode');
      return;
    }

    await _prefs.setString(AnalysisAIConfig.AI_MODE_KEY, mode);
    state = state.copyWith(aiMode: mode);
    print('📊 분석 AI 모드 변경: $mode');
  }

  /// OpenAI 모델 변경
  Future<void> setOpenAIModel(String model) async {
    await _prefs.setString(AnalysisAIConfig.OPENAI_MODEL_KEY, model);
    state = state.copyWith(openaiModel: model);
  }

  /// 일일 분석 한도 설정
  Future<void> setMaxDailyAnalyses(int limit) async {
    await _prefs.setInt(AnalysisAIConfig.MAX_DAILY_ANALYSES_KEY, limit);
    state = state.copyWith(maxDailyAnalyses: limit);
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
import '../../../../core/ai/sources/openai_dialogue_source.dart';

// Gemini import 제거
// import 'package:sherpa_app/core/ai/sources/enhanced_gemini_dialogue_source.dart';

class AiInsightGenerator {
  final AnalysisConfigState _config;
  SherpiDialogueSource? _aiSource;

  AiInsightGenerator(this._config) {
    _initializeAISource();
  }

  void _initializeAISource() {
    switch (_config.aiMode) {
      case AnalysisAIConfig.MODE_OPENAI:
        try {
          _aiSource = OpenAIDialogueSource();
          print('✅ OpenAI AI 소스 초기화 완료');
          print('📝 모델: ${_config.openaiModel}');
          print('🔢 최대 토큰: ${_config.openaiMaxTokens}');
        } catch (e) {
          print('❌ OpenAI 초기화 실패: $e');
          _aiSource = null;
        }
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
            'model': _config.openaiModel,  // OpenAI 모델 명시
            'max_tokens': _config.openaiMaxTokens,  // 토큰 제한
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
      Insight(
        type: InsightType.recommendation,
        title: '내일의 목표',
        description: '운동 시간을 5분 늘려보세요',
        icon: '🎯',
      ),
      Insight(
        type: InsightType.achievement,
        title: '연속 기록',
        description: '${analysisResult.streak}일 연속 달성!',
        icon: '🏆',
      ),
    ];
  }
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

### 2. 모드 전환 테스트 (3가지만)

```dart
// Disabled → Mock → OpenAI 순으로 전환
await config.setAIMode(AnalysisAIConfig.MODE_DISABLED); // 규칙 기반만
await config.setAIMode(AnalysisAIConfig.MODE_MOCK);     // Mock AI
await config.setAIMode(AnalysisAIConfig.MODE_OPENAI);   // OpenAI (API 키 필요)
```

### 3. OpenAI 설정 테스트

```dart
// OpenAI 모델 변경
await config.setOpenAIModel('gpt-4');  // 또는 'gpt-3.5-turbo'

// 토큰 제한 변경
await config.setOpenAIMaxTokens(500);  // 500 토큰으로 제한
```

---

## ✅ 체크리스트

### 필수 완료 항목
- [ ] Gemini 관련 파일/코드 제거
- [ ] analysis_ai_config.dart 생성 (3가지 모드)
- [ ] analysis_config_provider.dart 생성
- [ ] mock_analysis_ai_source.dart 구현
- [ ] AiInsightGenerator 수정 (OpenAI 중심)
- [ ] main.dart Provider override 추가

### 검증 항목
- [ ] Mock 모드에서 분석 다이얼로그 정상 작동
- [ ] OpenAI 모드 전환 시 적절한 소스 사용
- [ ] Disabled 모드에서 규칙 기반 폴백
- [ ] 타임아웃 동작 확인
- [ ] Gemini 관련 코드 완전 제거 확인

---

## 🚨 주의사항

1. **Gemini 완전 제거**
   - enhanced_gemini_dialogue_source.dart 삭제
   - 모든 Gemini 관련 import 제거
   - Google AI SDK 의존성 제거

2. **OpenAI API 키 필수**
   - OpenAI 모드 사용 시 API 키 필요
   - .env 파일에 OPENAI_API_KEY 설정

3. **기본 모드는 여전히 DISABLED**
   - 안전을 위해 기본은 AI 비활성화
   - 명시적으로 활성화해야 AI 사용

4. **3가지 모드만 지원**
   - disabled: AI 없음
   - mock: 테스트용
   - openai: 실제 AI

---

## 📊 예상 결과

Stage B 완료 후:
- Gemini 코드 완전 제거
- 3가지 모드로 단순화
- OpenAI 중심의 일관된 AI 시스템
- Mock 모드로 API 없이도 테스트 가능

---

## 🎯 다음 단계 (Stage C)

Stage B 완료 확인 후 진행:
1. 분석 결과 캐시 구현
2. 일일 사용량 추적 (OpenAI 토큰 기준)
3. 비용 모니터링 (OpenAI 가격 정책)

---

**Stage B 준비 완료!** Gemini 제거 후 OpenAI 중심으로 진행하세요. 🚀