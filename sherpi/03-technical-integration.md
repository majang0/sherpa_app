# Gemini API 기술 구현 가이드

## 🎯 개요

이 문서는 Gemini 2.5 Pro API를 활용하여 기존 셰르피 시스템에 AI 기능을 통합하는 구체적인 기술 구현 방법을 제시합니다. 현재 앱의 `DialogueSource` 인터페이스를 확장하여 seamless한 통합을 목표로 합니다.

## 🔧 1. 프로젝트 설정

### Dependencies 추가
```yaml
# pubspec.yaml
dependencies:
  google_generative_ai: ^0.2.2  # Gemini API SDK
  http: ^1.1.0
  dio: ^5.3.2  # 네트워킹 (선택사항)
  
dev_dependencies:
  json_annotation: ^4.8.1
  build_runner: ^2.4.7
```

### API Key 관리
```dart
// lib/core/config/api_config.dart
class ApiConfig {
  static const String _geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'your-api-key-here',
  );
  
  static String get geminiApiKey {
    if (_geminiApiKey == 'your-api-key-here') {
      throw Exception('GEMINI_API_KEY environment variable not set');
    }
    return _geminiApiKey;
  }
}
```

### 환경 변수 설정
```bash
# .env (development)
GEMINI_API_KEY=your_actual_gemini_api_key_here

# build command with env variable
flutter run --dart-define=GEMINI_API_KEY=your_actual_key
```

## 🧠 2. 시스템 프롬프트 템플릿

### 기본 페르소나 프롬프트
```dart
// lib/core/ai/sherpi_prompts.dart
class SherpiPrompts {
  static const String BASE_PERSONA = """
당신은 '셰르피'입니다. 사용자의 성장을 함께하는 따뜻한 동반자로서 다음 원칙을 지켜주세요:

🎭 핵심 정체성:
- 성장을 함께하는 든든한 페이스메이커
- 때로는 재치 있는 농담으로 웃음을 주는 친구
- 사용자의 모든 여정을 이해하고 응원하는 동반자

💬 대화 원칙:
- 항상 "우리" 언어를 사용하여 팀워크를 강조하세요 ("우리가 함께 해냈네요!")
- 사용자를 절대 평가하거나 비난하지 마세요
- 작은 성취도 크게 축하하고, 좌절에는 따뜻한 위로와 격려를 주세요
- 한국어로 친근하고 따뜻하게 대화하세요
- 응답은 2-3문장으로 간결하게 작성하세요

🚫 절대 금지사항:
- 평가나 비난 ("당신은 게을러요", "노력이 부족해요")
- 부정적 예측 ("실패할 거예요", "어려울 것 같아요")
- 개인정보 요구 (비밀번호, 사생활 등)

🎨 이모지 사용:
- 메시지당 1-2개 정도 적절히 사용
- 감정과 상황에 맞는 이모지 선택 (😊🎉💪🌟🤗🔥✨등)
""";

  static String getContextualPrompt(SherpiContext context) {
    switch (context) {
      case SherpiContext.welcome:
        return BASE_PERSONA + """
        
🎯 현재 상황: 새로운 사용자를 환영하는 상황입니다.
- 따뜻하고 친근하지만 부담스럽지 않게 인사하세요
- 앞으로의 여정에 대한 기대감을 표현하세요
- "우리 함께" 라는 동반자적 관계를 강조하세요
""";
        
      case SherpiContext.levelUp:
        return BASE_PERSONA + """
        
🎯 현재 상황: 사용자가 레벨업을 달성했습니다.
- 진심으로 축하하며 성취의 의미를 부여하세요
- 구체적인 노력 과정을 인정해주세요
- 다음 단계에 대한 기대를 표현하세요
""";
        
      case SherpiContext.encouragement:
        return BASE_PERSONA + """
        
🎯 현재 상황: 사용자에게 격려가 필요한 상황입니다.
- 따뜻한 위로와 함께 희망적인 메시지를 전하세요
- 과거의 성공 경험을 상기시켜 자신감을 회복시키세요
- "우리라면 할 수 있다"는 동반자적 지지를 표현하세요
""";
        
      default:
        return BASE_PERSONA;
    }
  }
}
```

### 상황별 프롬프트 매핑
```dart
class ContextPromptManager {
  static final Map<SherpiContext, String> _contextPrompts = {
    SherpiContext.welcome: "새로운 사용자 환영",
    SherpiContext.levelUp: "레벨업 축하",
    SherpiContext.questComplete: "퀘스트 완료 축하",
    SherpiContext.encouragement: "격려 및 동기부여",
    SherpiContext.climbingSuccess: "등반 성공 축하",
    SherpiContext.exerciseComplete: "운동 완료 격려",
    // ... 47가지 컨텍스트 모두 정의
  };
  
  static String getPromptForContext(SherpiContext context) {
    return SherpiPrompts.getContextualPrompt(context);
  }
}
```

## 📊 3. 컨텍스트 데이터 구조

### 사용자 컨텍스트 데이터
```dart
// lib/core/ai/context_data.dart
class SherpiContextData {
  final UserContextData user;
  final ActivityContextData activity;
  final ProgressContextData progress;
  final EmotionalContextData emotion;
  
  const SherpiContextData({
    required this.user,
    required this.activity,
    required this.progress,
    required this.emotion,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'activity': activity.toJson(),
      'progress': progress.toJson(),
      'emotion': emotion.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class UserContextData {
  final String name;
  final int level;
  final double experience;
  final GlobalStats stats;
  final int consecutiveDays;
  final String currentTitle;
  
  const UserContextData({
    required this.name,
    required this.level,
    required this.experience,
    required this.stats,
    required this.consecutiveDays,
    required this.currentTitle,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'level': level,
    'experience': experience,
    'stats': {
      'stamina': stats.stamina,
      'knowledge': stats.knowledge,
      'technique': stats.technique,
      'sociality': stats.sociality,
      'willpower': stats.willpower,
    },
    'consecutive_days': consecutiveDays,
    'current_title': currentTitle,
  };
}

class ActivityContextData {
  final List<String> recentActivities;
  final Map<String, int> activityCounts;
  final double todayCompletionRate;
  final String mostFrequentActivity;
  final DateTime lastActivityTime;
  
  const ActivityContextData({
    required this.recentActivities,
    required this.activityCounts,
    required this.todayCompletionRate,
    required this.mostFrequentActivity,
    required this.lastActivityTime,
  });
  
  Map<String, dynamic> toJson() => {
    'recent_activities': recentActivities,
    'activity_counts': activityCounts,
    'today_completion_rate': todayCompletionRate,
    'most_frequent_activity': mostFrequentActivity,
    'last_activity_time': lastActivityTime.toIso8601String(),
  };
}

class ProgressContextData {
  final double weeklyGrowthRate;
  final List<String> recentAchievements;
  final int currentStreak;
  final Map<String, dynamic> personalBests;
  final String growthTrend; // "increasing", "stable", "declining"
  
  const ProgressContextData({
    required this.weeklyGrowthRate,
    required this.recentAchievements,
    required this.currentStreak,
    required this.personalBests,
    required this.growthTrend,
  });
  
  Map<String, dynamic> toJson() => {
    'weekly_growth_rate': weeklyGrowthRate,
    'recent_achievements': recentAchievements,
    'current_streak': currentStreak,
    'personal_bests': personalBests,
    'growth_trend': growthTrend,
  };
}

class EmotionalContextData {
  final String recentMood; // from diary logs
  final double satisfactionLevel; // average from recent activities
  final List<String> stressFactors;
  final String motivationLevel; // "high", "medium", "low"
  
  const EmotionalContextData({
    required this.recentMood,
    required this.satisfactionLevel,
    required this.stressFactors,
    required this.motivationLevel,
  });
  
  Map<String, dynamic> toJson() => {
    'recent_mood': recentMood,
    'satisfaction_level': satisfactionLevel,
    'stress_factors': stressFactors,
    'motivation_level': motivationLevel,
  };
}
```

### 컨텍스트 데이터 수집기
```dart
// lib/core/ai/context_collector.dart
class SherpiContextCollector {
  final Ref ref;
  
  SherpiContextCollector(this.ref);
  
  Future<SherpiContextData> collectContextData() async {
    final globalUser = ref.read(globalUserProvider);
    final dailyRecords = globalUser.dailyRecords;
    
    return SherpiContextData(
      user: _buildUserContext(globalUser),
      activity: _buildActivityContext(dailyRecords),
      progress: _buildProgressContext(globalUser, dailyRecords),
      emotion: _buildEmotionalContext(dailyRecords),
    );
  }
  
  UserContextData _buildUserContext(GlobalUser user) {
    return UserContextData(
      name: user.name,
      level: user.level,
      experience: user.experience,
      stats: user.stats,
      consecutiveDays: user.dailyRecords.consecutiveDays,
      currentTitle: user.title,
    );
  }
  
  ActivityContextData _buildActivityContext(DailyRecordData records) {
    final recentActivities = _getRecentActivities(records);
    final activityCounts = _countActivities(records);
    
    return ActivityContextData(
      recentActivities: recentActivities,
      activityCounts: activityCounts,
      todayCompletionRate: records.todayCompletionRate,
      mostFrequentActivity: _getMostFrequentActivity(activityCounts),
      lastActivityTime: records.lastActiveDate,
    );
  }
  
  // ... 기타 빌더 메서드들
}
```

## 🤖 4. GeminiDialogueSource 구현

### 기본 구현
```dart
// lib/core/ai/gemini_dialogue_source.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiDialogueSource implements SherpiDialogueSource {
  late final GenerativeModel _model;
  final SherpiContextCollector _contextCollector;
  
  GeminiDialogueSource(Ref ref) : _contextCollector = SherpiContextCollector(ref) {
    _model = GenerativeModel(
      model: 'gemini-2.5-pro-latest',
      apiKey: ApiConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.9,
        maxOutputTokens: 200, // 간결한 응답을 위해
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ],
    );
  }
  
  @override
  Future<String> getDialogue(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    try {
      // 1. 컨텍스트 데이터 수집
      final contextData = await _contextCollector.collectContextData();
      
      // 2. 프롬프트 구성
      final systemPrompt = SherpiPrompts.getContextualPrompt(context);
      final userPrompt = _buildUserPrompt(context, contextData, userContext, gameContext);
      
      // 3. AI 응답 생성
      final content = [Content.text('$systemPrompt\n\n$userPrompt')];
      final response = await _model.generateContent(content);
      
      // 4. 응답 검증 및 후처리
      final dialogue = _processResponse(response.text, context);
      
      // 5. 로깅 (선택사항)
      _logInteraction(context, dialogue, contextData);
      
      return dialogue;
      
    } catch (e) {
      // 6. 에러 처리 및 폴백
      return _getFallbackDialogue(context, e);
    }
  }
  
  String _buildUserPrompt(
    SherpiContext context,
    SherpiContextData contextData,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    final buffer = StringBuffer();
    
    // 기본 상황 설명
    buffer.writeln('📍 현재 상황: ${context.name}');
    
    // 사용자 정보
    buffer.writeln('👤 사용자 정보:');
    buffer.writeln('- 이름: ${contextData.user.name}');
    buffer.writeln('- 레벨: ${contextData.user.level}');
    buffer.writeln('- 연속 접속일: ${contextData.user.consecutiveDays}일');
    buffer.writeln('- 현재 칭호: ${contextData.user.currentTitle}');
    
    // 최근 활동
    if (contextData.activity.recentActivities.isNotEmpty) {
      buffer.writeln('📊 최근 활동:');
      for (final activity in contextData.activity.recentActivities.take(3)) {
        buffer.writeln('- $activity');
      }
    }
    
    // 성장 현황
    buffer.writeln('📈 성장 현황:');
    buffer.writeln('- 오늘 목표 달성률: ${(contextData.activity.todayCompletionRate * 100).toInt()}%');
    buffer.writeln('- 성장 트렌드: ${contextData.progress.growthTrend}');
    buffer.writeln('- 현재 연속 기록: ${contextData.progress.currentStreak}');
    
    // 감정 상태
    buffer.writeln('💭 감정 상태:');
    buffer.writeln('- 최근 기분: ${contextData.emotion.recentMood}');
    buffer.writeln('- 동기 수준: ${contextData.emotion.motivationLevel}');
    
    // 추가 컨텍스트
    if (userContext != null && userContext.isNotEmpty) {
      buffer.writeln('🎯 특별 상황:');
      userContext.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }
    
    buffer.writeln('\n위 정보를 바탕으로 셰르피의 페르소나에 맞는 따뜻하고 개인화된 메시지를 작성해주세요.');
    
    return buffer.toString();
  }
  
  String _processResponse(String? rawResponse, SherpiContext context) {
    if (rawResponse == null || rawResponse.isEmpty) {
      return _getFallbackDialogue(context, Exception('Empty response'));
    }
    
    String processed = rawResponse.trim();
    
    // 길이 제한 (최대 150자)
    if (processed.length > 150) {
      processed = processed.substring(0, 147) + '...';
    }
    
    // 부적절한 표현 필터링
    processed = _filterInappropriateContent(processed);
    
    // 이모지 정리 (너무 많으면 줄이기)
    processed = _normalizeEmojis(processed);
    
    return processed;
  }
  
  String _filterInappropriateContent(String text) {
    // 금지된 표현들 필터링
    final prohibitedPhrases = [
      '당신은 게을러',
      '노력이 부족',
      '실패할 거',
      '어려울 것 같',
      '포기하',
    ];
    
    String filtered = text;
    for (final phrase in prohibitedPhrases) {
      if (filtered.contains(phrase)) {
        // 부적절한 표현 발견 시 폴백 사용
        return _getFallbackDialogue(SherpiContext.general, 
          Exception('Inappropriate content detected: $phrase'));
      }
    }
    
    return filtered;
  }
  
  String _normalizeEmojis(String text) {
    // 이모지가 3개 이상이면 줄이기
    final emojiRegex = RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]', unicode: true);
    final emojis = emojiRegex.allMatches(text);
    
    if (emojis.length > 3) {
      // 처음 2개 이모지만 유지
      String normalized = text;
      final matches = emojis.toList();
      for (int i = 2; i < matches.length; i++) {
        normalized = normalized.replaceFirst(matches[i].group(0)!, '');
      }
      return normalized.trim();
    }
    
    return text;
  }
  
  String _getFallbackDialogue(SherpiContext context, dynamic error) {
    // 로그 기록
    print('Gemini API Error for context ${context.name}: $error');
    
    // 기존 정적 대화로 폴백
    final staticSource = StaticDialogueSource();
    return staticSource.getDialogue(context, null, null);
  }
  
  void _logInteraction(SherpiContext context, String dialogue, SherpiContextData contextData) {
    // 상호작용 로깅 (분석 및 개선용)
    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'context': context.name,
      'dialogue': dialogue,
      'user_level': contextData.user.level,
      'consecutive_days': contextData.user.consecutiveDays,
    };
    
    // Firebase Analytics, 로컬 저장소 등에 기록
    print('Sherpi Interaction: $logData');
  }
}
```

### 캐싱 및 성능 최적화
```dart
// lib/core/ai/dialogue_cache.dart
class DialogueCache {
  static final Map<String, CachedDialogue> _cache = {};
  static const Duration cacheExpiry = Duration(hours: 1);
  
  static String? getCachedDialogue(String cacheKey) {
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.dialogue;
    }
    return null;
  }
  
  static void cacheDialogue(String cacheKey, String dialogue) {
    _cache[cacheKey] = CachedDialogue(
      dialogue: dialogue,
      timestamp: DateTime.now(),
    );
  }
  
  static String generateCacheKey(SherpiContext context, Map<String, dynamic> contextData) {
    // 사용자 상태와 컨텍스트 기반으로 캐시 키 생성
    final userLevel = contextData['user']?['level'] ?? 0;
    final consecutiveDays = contextData['user']?['consecutive_days'] ?? 0;
    final todayRate = contextData['activity']?['today_completion_rate'] ?? 0.0;
    
    return '${context.name}_${userLevel}_${consecutiveDays}_${(todayRate * 10).round()}';
  }
}

class CachedDialogue {
  final String dialogue;
  final DateTime timestamp;
  
  CachedDialogue({required this.dialogue, required this.timestamp});
  
  bool get isExpired => DateTime.now().difference(timestamp) > DialogueCache.cacheExpiry;
}
```

## ⚙️ 5. Provider 통합

### 기존 Provider 확장
```dart
// lib/shared/providers/global_sherpi_provider.dart 수정
class SherpiNotifier extends StateNotifier<SherpiState> {
  final SherpiDialogueSource _dialogueSource;
  final SherpiContextCollector _contextCollector;
  Timer? _hideTimer;

  SherpiNotifier({
    SherpiDialogueSource? dialogueSource,
    required Ref ref,
  }) : _dialogueSource = dialogueSource ?? GeminiDialogueSource(ref),
       _contextCollector = SherpiContextCollector(ref),
       super(const SherpiState());

  // 기존 메서드들 유지하되, AI 기능 강화
  
  Future<void> showAIMessage({
    required SherpiContext context,
    Map<String, dynamic>? additionalContext,
    Duration duration = const Duration(seconds: 4),
    bool forceRefresh = false,
  }) async {
    try {
      _hideTimer?.cancel();
      
      // 캐싱 확인
      if (!forceRefresh) {
        final contextData = await _contextCollector.collectContextData();
        final cacheKey = DialogueCache.generateCacheKey(context, contextData.toJson());
        final cachedDialogue = DialogueCache.getCachedDialogue(cacheKey);
        
        if (cachedDialogue != null) {
          _showCachedMessage(context, cachedDialogue, duration);
          return;
        }
      }
      
      // AI 대화 생성
      final dialogue = await _dialogueSource.getDialogue(
        context,
        additionalContext,
        null,
      );
      
      // 캐싱
      if (!forceRefresh) {
        final contextData = await _contextCollector.collectContextData();
        final cacheKey = DialogueCache.generateCacheKey(context, contextData.toJson());
        DialogueCache.cacheDialogue(cacheKey, dialogue);
      }
      
      final selectedEmotion = SherpiDialogueUtils.getRecommendedEmotion(context);
      state = state.copyWith(
        emotion: selectedEmotion,
        dialogue: dialogue,
        isVisible: true,
        lastShownTime: DateTime.now(),
        currentContext: context,
      );
      
      _hideTimer = Timer(duration, hideMessage);
      
    } catch (e) {
      // 폴백으로 기존 showMessage 사용
      await showMessage(context: context, duration: duration);
    }
  }
  
  void _showCachedMessage(SherpiContext context, String dialogue, Duration duration) {
    final selectedEmotion = SherpiDialogueUtils.getRecommendedEmotion(context);
    state = state.copyWith(
      emotion: selectedEmotion,
      dialogue: dialogue,
      isVisible: true,
      lastShownTime: DateTime.now(),
      currentContext: context,
    );
    
    _hideTimer = Timer(duration, hideMessage);
  }
}
```

### Provider Extension 추가
```dart
extension SherpiAIProviderExtension on WidgetRef {
  Future<void> showAISherpi(
    SherpiContext context, {
    Map<String, dynamic>? additionalContext,
    Duration? duration,
    bool forceRefresh = false,
  }) async {
    await read(sherpiProvider.notifier).showAIMessage(
      context: context,
      additionalContext: additionalContext,
      duration: duration ?? const Duration(seconds: 4),
      forceRefresh: forceRefresh,
    );
  }
}
```

## 🔒 6. 안전 장치 및 에러 처리

### 응답 검증 시스템
```dart
class ResponseValidator {
  static bool isAppropriate(String response) {
    // 길이 체크
    if (response.isEmpty || response.length > 200) return false;
    
    // 금지 표현 체크
    final prohibitedPatterns = [
      RegExp(r'당신은.*게을러', caseSensitive: false),
      RegExp(r'노력.*부족', caseSensitive: false),
      RegExp(r'실패.*할.*거', caseSensitive: false),
    ];
    
    for (final pattern in prohibitedPatterns) {
      if (pattern.hasMatch(response)) return false;
    }
    
    // 긍정적 톤 체크
    if (!_hasPositiveTone(response)) return false;
    
    return true;
  }
  
  static bool _hasPositiveTone(String response) {
    final positiveKeywords = ['우리', '함께', '대단', '좋', '성장', '축하'];
    return positiveKeywords.any((keyword) => response.contains(keyword));
  }
}
```

### 에러 처리 전략
```dart
enum SherpiErrorType {
  networkError,
  apiLimitExceeded,
  inappropriateContent,
  emptyResponse,
  parseError,
}

class SherpiErrorHandler {
  static String handleError(SherpiErrorType errorType, SherpiContext context) {
    switch (errorType) {
      case SherpiErrorType.networkError:
        return _getNetworkErrorFallback(context);
      case SherpiErrorType.apiLimitExceeded:
        return _getApiLimitFallback(context);
      case SherpiErrorType.inappropriateContent:
        return _getContentFilterFallback(context);
      default:
        return _getGenericFallback(context);
    }
  }
  
  static String _getNetworkErrorFallback(SherpiContext context) {
    const networkFallbacks = {
      SherpiContext.welcome: '안녕하세요! 함께 성장해봐요! 😊',
      SherpiContext.levelUp: '레벨업 축하해요! 🎉',
      SherpiContext.encouragement: '우리 함께 힘내봐요! 💪',
    };
    return networkFallbacks[context] ?? '우리 함께 해봐요! 😊';
  }
}
```

## 📈 7. 사용법 예시

### 기본 사용법
```dart
// 컨트롤러나 위젯에서 사용
class ExampleWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // AI 기반 메시지 표시
        await ref.showAISherpi(
          SherpiContext.encouragement,
          additionalContext: {
            'specific_challenge': '운동 목표 달성',
            'current_mood': 'tired',
          },
        );
      },
      child: Text('셰르피와 대화하기'),
    );
  }
}
```

### 퀘스트 완료 시 AI 반응
```dart
// 퀘스트 완료 처리에서
Future<void> onQuestCompleted(Quest quest) async {
  // 기존 로직...
  
  // AI 기반 축하 메시지
  await ref.showAISherpi(
    SherpiContext.questComplete,
    additionalContext: {
      'quest_type': quest.type,
      'difficulty': quest.difficulty,
      'completion_time': quest.completionTime.inMinutes,
    },
    forceRefresh: true, // 퀘스트마다 새로운 메시지
  );
}
```

### 패턴 분석 기반 조언
```dart
// 주간 분석 후 조언 제공
Future<void> showWeeklyInsights() async {
  final analysisData = await analyzeWeeklyPatterns();
  
  await ref.showAISherpi(
    SherpiContext.guidance,
    additionalContext: {
      'analysis_type': 'weekly_pattern',
      'best_performance_day': analysisData.bestDay,
      'success_rate': analysisData.successRate,
      'recommended_action': analysisData.recommendation,
    },
    duration: Duration(seconds: 8), // 더 긴 시간 표시
  );
}
```

## 🎛️ 8. 설정 및 커스터마이징

### 사용자 설정
```dart
class SherpiAISettings {
  final bool aiEnabled;
  final double creativityLevel; // 0.0 - 1.0
  final bool cacheEnabled;
  final Duration defaultDisplayTime;
  
  const SherpiAISettings({
    this.aiEnabled = true,
    this.creativityLevel = 0.7,
    this.cacheEnabled = true,
    this.defaultDisplayTime = const Duration(seconds: 4),
  });
}
```

### A/B 테스트 지원
```dart
class SherpiExperimentManager {
  static bool shouldUseAI(String userId) {
    // A/B 테스트 로직
    return userId.hashCode % 2 == 0;
  }
  
  static SherpiDialogueSource getDialogueSource(String userId, Ref ref) {
    if (shouldUseAI(userId)) {
      return GeminiDialogueSource(ref);
    } else {
      return StaticDialogueSource();
    }
  }
}
```

---

**이 기술 구현 가이드를 통해 Gemini AI가 기존 셰르피 시스템과 seamless하게 통합되어, 사용자에게 개인화되고 지능적인 동반자 경험을 제공할 수 있습니다.**