# 셰르피 AI 시스템 구현 로드맵

## 🎯 구현 목표
4주 안에 셰르피를 진정한 AI 동반자로 변신시키는 단계별 구현 가이드

## 📅 전체 일정

| 주차 | 단계 | 주요 작업 | 예상 시간 | 우선순위 |
|------|------|----------|-----------|----------|
| 1주차 | Phase 1 | Quick Wins + 기초 시스템 | 20시간 | 🔴 높음 |
| 2주차 | Phase 2 | 활동별 프롬프트 시스템 | 25시간 | 🔴 높음 |
| 3주차 | Phase 3 | 성격 시스템 구현 | 20시간 | 🟡 중간 |
| 4주차 | Phase 4 | 고급 기능 + 최적화 | 15시간 | 🟢 낮음 |

---

## 📋 Phase 1: Quick Wins + 기초 시스템 (1주차)

### Day 1-2: AI 사용 빈도 증가

#### 1.1 SmartSherpiManager 수정
**파일**: `lib/core/ai/smart_sherpi_manager.dart`

```dart
// 현재 코드 (10% AI 사용)
bool _shouldUseAI(...) {
  final useAI = (
    isSignificantMoment ||
    isPersonalizedContext ||
    hasLongUserHistory ||
    isComplexScenario ||
    isEmotionalMoment
  ) && !isRepetitiveAction;
  return useAI;
}

// 수정할 코드 (40% AI 사용)
bool _shouldUseAI(
  SherpiContext context,
  Map<String, dynamic>? userContext,
  Map<String, dynamic>? gameContext,
) {
  // 기본 AI 사용률 40%
  double aiProbability = 0.4;
  
  // 활동 완료는 높은 우선순위
  if (_isActivityCompletion(context)) {
    aiProbability += 0.2;
  }
  
  // 감정적 순간
  if (_isEmotionalContext(context)) {
    aiProbability += 0.15;
  }
  
  // 개인화 데이터 있을 때
  if (userContext != null && userContext.isNotEmpty) {
    aiProbability += 0.1;
  }
  
  // 최근 5분 내 같은 컨텍스트 사용 시 감소
  final lastUsed = _lastContextUsage[context];
  if (lastUsed != null && 
      DateTime.now().difference(lastUsed).inMinutes < 5) {
    aiProbability -= 0.2;
  }
  
  // 신규 사용자 보너스 (첫 7일)
  final userDays = gameContext?['userDays'] ?? 0;
  if (userDays < 7) {
    aiProbability += 0.15;
  }
  
  // 확률 제한 (최대 80%, 최소 20%)
  aiProbability = aiProbability.clamp(0.2, 0.8);
  
  // 확률적 결정
  final useAI = Random().nextDouble() < aiProbability;
  
  // 사용 기록
  if (useAI) {
    _lastContextUsage[context] = DateTime.now();
  }
  
  return useAI;
}

// 추가할 헬퍼 메서드들
bool _isActivityCompletion(SherpiContext context) {
  return [
    SherpiContext.exerciseComplete,
    SherpiContext.studyComplete,
    SherpiContext.diaryWritten,
    SherpiContext.questComplete,
    SherpiContext.focusComplete,
  ].contains(context);
}

bool _isEmotionalContext(SherpiContext context) {
  return [
    SherpiContext.levelUp,
    SherpiContext.achievementUnlocked,
    SherpiContext.personalBest,
    SherpiContext.encouragement,
  ].contains(context);
}

// 컨텍스트 사용 기록
static final Map<SherpiContext, DateTime> _lastContextUsage = {};
```

#### 1.2 정적 메시지 확장
**파일**: `lib/core/constants/sherpi_dialogues.dart`

```dart
// 현재 코드 (3-5개 메시지)
static const exerciseCompleteDialogues = [
  "운동 완료! 정말 수고하셨어요! 💪",
  "오늘도 열심히 운동하셨네요! 멋져요!",
  "운동으로 건강해지고 있어요! 계속 힘내세요!",
];

// 수정할 코드 (15개 메시지로 확장)
static const exerciseCompleteDialogues = [
  "운동 완료! 정말 수고하셨어요! 💪",
  "오늘도 열심히 운동하셨네요! 멋져요!",
  "운동으로 건강해지고 있어요! 계속 힘내세요!",
  "땀 흘린 만큼 건강해졌어요! 우리 잘하고 있어요!",
  "오늘의 운동, 내일의 건강! 함께 만들어가요!",
  "한 걸음 더 건강에 가까워졌네요! 대단해요!",
  "운동하는 모습이 정말 멋있어요! 우리 최고!",
  "오늘도 자신과의 약속을 지켰네요! 자랑스러워요!",
  "건강한 습관을 만들어가고 있어요! 함께해요!",
  "운동의 즐거움을 우리가 함께 느끼고 있네요!",
  "몸도 마음도 건강해지는 시간이었어요!",
  "우리의 노력이 빛나는 순간이에요! 수고했어요!",
  "오늘도 한계를 넘어섰네요! 정말 대단해요!",
  "건강한 하루를 만들어가는 우리, 멋져요!",
  "운동으로 스트레스도 날려버렸겠네요! 시원해요!",
];

// 각 컨텍스트별로 동일하게 확장
```

### Day 3-4: 사용자 이름 호출 시스템

#### 1.3 사용자 이름 관리 시스템
**새 파일 생성**: `lib/core/ai/user_name_system.dart`

```dart
import 'package:sherpa_app/shared/models/global_user_model.dart';

class UserNameSystem {
  /// 사용자 호출 이름 가져오기
  static String getUserCallName(GlobalUser? user) {
    if (user == null) return "친구";
    
    // 우선순위: 닉네임 > 이름 > ID 일부
    if (user.userProfile.nickname != null && 
        user.userProfile.nickname!.isNotEmpty) {
      return user.userProfile.nickname!;
    }
    
    if (user.userProfile.name != null && 
        user.userProfile.name!.isNotEmpty) {
      return user.userProfile.name!;
    }
    
    // ID의 앞 4자리 사용 (최후 수단)
    if (user.userProfile.userId.length >= 4) {
      return user.userProfile.userId.substring(0, 4);
    }
    
    return "친구";
  }
  
  /// 메시지에 사용자 이름 삽입
  static String insertUserName(String message, String userName) {
    // {userName} 플레이스홀더 치환
    message = message.replaceAll('{userName}', userName);
    
    // 친구님 → 실제 이름으로 치환
    message = message.replaceAll('친구님', userName);
    message = message.replaceAll('친구', userName);
    
    // 메시지에 이름이 없으면 앞에 추가
    if (!message.contains(userName)) {
      message = '$userName, $message';
    }
    
    return message;
  }
  
  /// "우리" 표현 삽입
  static String insertWeExpression(String message) {
    // 이미 "우리"가 있으면 스킵
    if (message.contains('우리')) {
      return message;
    }
    
    // 적절한 위치에 "우리" 삽입
    final patterns = [
      ('함께', '우리 함께'),
      ('해요', '우리가 함께 해요'),
      ('했어요', '우리가 함께 했어요'),
      ('할게요', '우리가 함께 할게요'),
      ('해봐요', '우리가 함께 해봐요'),
    ];
    
    for (final pattern in patterns) {
      if (message.contains(pattern.$1) && !message.contains('우리')) {
        return message.replaceFirst(pattern.$1, pattern.$2);
      }
    }
    
    // 패턴 매칭 실패 시 끝에 추가
    return '$message 우리 함께 해요!';
  }
}
```

#### 1.4 GlobalSherpiProvider 수정
**파일**: `lib/shared/providers/global_sherpi_provider.dart`

```dart
// showMessage 메서드 수정
Future<void> showMessage({
  required SherpiContext context,
  Map<String, dynamic>? userContext,
  Map<String, dynamic>? gameContext,
}) async {
  try {
    // 사용자 정보 가져오기
    final user = ref.read(globalUserProvider).value;
    final userName = UserNameSystem.getUserCallName(user);
    
    // userContext에 userName 추가
    final enrichedUserContext = {
      ...?userContext,
      'userName': userName,
    };
    
    // AI 또는 정적 메시지 결정
    final message = await _sherpiManager.getMessage(
      context: context,
      userContext: enrichedUserContext,
      gameContext: gameContext,
    );
    
    // 메시지에 사용자 이름과 "우리" 표현 삽입
    final personalizedMessage = UserNameSystem.insertUserName(
      UserNameSystem.insertWeExpression(message.text),
      userName,
    );
    
    // 메시지 표시
    _showMessageCard(
      personalizedMessage,
      message.emotion,
      message.source,
    );
  } catch (e) {
    print('Error showing Sherpi message: $e');
    _showFallbackMessage(context);
  }
}
```

### Day 5: 캐시 시스템 안정화

#### 1.5 안전한 캐시 시스템
**파일**: `lib/core/ai/ai_message_cache.dart`

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ImprovedMessageCache {
  static const String _cachePrefix = 'sherpi_cache_v2_';
  static const Duration _cacheExpiry = Duration(hours: 12); // 24시간 → 12시간
  static const int _maxCacheSize = 30; // 50 → 30개로 최적화
  
  /// 안전한 캐시 저장
  static Future<void> saveToCache(
    String key,
    String message,
    SherpiEmotion emotion,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      
      final cacheData = {
        'message': message,
        'emotion': emotion.name,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '2.0', // 버전 관리
      };
      
      await prefs.setString(cacheKey, jsonEncode(cacheData));
      
      // 캐시 크기 관리
      await _manageCacheSize(prefs);
    } catch (e) {
      print('Cache save error (non-critical): $e');
      // 캐시 실패는 치명적이지 않음
    }
  }
  
  /// 안전한 캐시 조회
  static Future<CachedMessage?> getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final cached = prefs.getString(cacheKey);
      
      if (cached == null) return null;
      
      final data = jsonDecode(cached) as Map<String, dynamic>;
      
      // 버전 체크
      if (data['version'] != '2.0') {
        await prefs.remove(cacheKey);
        return null;
      }
      
      // 만료 체크
      final timestamp = DateTime.parse(data['timestamp']);
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        await prefs.remove(cacheKey);
        return null;
      }
      
      return CachedMessage(
        text: data['message'],
        emotion: SherpiEmotion.values.firstWhere(
          (e) => e.name == data['emotion'],
          orElse: () => SherpiEmotion.defaults,
        ),
        source: MessageSource.cached,
      );
    } catch (e) {
      print('Cache read error (non-critical): $e');
      return null;
    }
  }
  
  /// 캐시 크기 관리
  static Future<void> _manageCacheSize(SharedPreferences prefs) async {
    final keys = prefs.getKeys()
      .where((k) => k.startsWith(_cachePrefix))
      .toList();
    
    if (keys.length <= _maxCacheSize) return;
    
    // 오래된 캐시 삭제
    final cacheEntries = <String, DateTime>{};
    
    for (final key in keys) {
      try {
        final data = jsonDecode(prefs.getString(key)!);
        cacheEntries[key] = DateTime.parse(data['timestamp']);
      } catch (_) {
        // 파싱 실패한 캐시는 삭제
        await prefs.remove(key);
      }
    }
    
    // 오래된 순으로 정렬
    final sortedKeys = cacheEntries.keys.toList()
      ..sort((a, b) => cacheEntries[a]!.compareTo(cacheEntries[b]!));
    
    // 초과분 삭제
    final toRemove = sortedKeys.take(sortedKeys.length - _maxCacheSize);
    for (final key in toRemove) {
      await prefs.remove(key);
    }
  }
  
  /// 캐시 클리어 (디버깅용)
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys()
      .where((k) => k.startsWith(_cachePrefix))
      .toList();
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
```

---

## 📋 Phase 2: 활동별 프롬프트 시스템 (2주차)

### Day 6-7: 데이터 수집 시스템

#### 2.1 활동 데이터 수집기
**새 파일 생성**: `lib/core/ai/activity_data_collector.dart`

```dart
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/features/daily_record/models/record_models.dart';

class ActivityDataCollector {
  /// 운동 데이터 수집
  static Map<String, dynamic> collectExerciseData(
    ExerciseLog exercise,
    GlobalUser user,
  ) {
    return {
      'userName': UserNameSystem.getUserCallName(user),
      'exerciseType': exercise.exerciseType,
      'exerciseTypeKorean': _translateExerciseType(exercise.exerciseType),
      'duration': exercise.duration.inMinutes,
      'intensity': exercise.intensity.name,
      'intensityKorean': _translateIntensity(exercise.intensity),
      'calories': exercise.calories,
      'steps': exercise.steps ?? 0,
      'timeOfDay': _getTimeOfDay(),
      'weeklyCount': _getWeeklyExerciseCount(user),
      'monthlyProgress': _getMonthlyProgress(user),
      'streakDays': user.stats.exerciseStreak,
      'personalBest': _checkPersonalBest(exercise, user),
      'goalProgress': _calculateGoalProgress(user),
      'improvement': _calculateImprovement(exercise, user),
    };
  }
  
  /// 독서 데이터 수집
  static Map<String, dynamic> collectReadingData(
    ReadingLog reading,
    GlobalUser user,
  ) {
    return {
      'userName': UserNameSystem.getUserCallName(user),
      'bookTitle': reading.bookTitle,
      'author': reading.author ?? '작자 미상',
      'genre': reading.genre ?? '일반',
      'pagesRead': reading.pagesRead,
      'totalPages': reading.totalPages ?? 0,
      'readingTime': reading.duration.inMinutes,
      'progress': _calculateBookProgress(reading),
      'rating': reading.rating?.round() ?? 0,
      'monthlyBooks': _getMonthlyBookCount(user),
      'yearlyGoal': user.goals.yearlyBookGoal ?? 12,
      'readingStreak': user.stats.readingStreak,
      'favoriteGenre': _getFavoriteGenre(user),
    };
  }
  
  /// 일기 데이터 수집
  static Map<String, dynamic> collectDiaryData(
    DiaryEntry diary,
    GlobalUser user,
  ) {
    // 키워드 추출 (간단한 구현)
    final keywords = _extractKeywords(diary.content);
    
    return {
      'userName': UserNameSystem.getUserCallName(user),
      'mood': diary.mood.name,
      'moodEmoji': _getMoodEmoji(diary.mood),
      'moodKorean': _translateMood(diary.mood),
      'keywords': keywords.join(', '),
      'wordCount': diary.content.length,
      'diaryStreak': user.stats.diaryStreak,
      'monthlyEntries': _getMonthlyDiaryCount(user),
      'timeOfDay': _getTimeOfDay(),
      'previousMood': _getPreviousMood(user),
      'moodTrend': _calculateMoodTrend(user),
    };
  }
  
  /// 퀘스트 데이터 수집
  static Map<String, dynamic> collectQuestData(
    Quest quest,
    GlobalUser user,
  ) {
    return {
      'userName': UserNameSystem.getUserCallName(user),
      'questTitle': quest.title,
      'questType': quest.type.name,
      'difficulty': quest.difficulty.name,
      'reward': quest.pointReward,
      'xpGained': quest.xpReward,
      'questStreak': user.stats.questStreak,
      'weeklyQuests': _getWeeklyQuestCount(user),
      'totalQuests': user.stats.totalQuestsCompleted,
      'nextLevel': _getXpToNextLevel(user),
      'badges': quest.unlockedBadges?.join(', ') ?? '',
    };
  }
  
  // 헬퍼 메서드들
  static String _translateExerciseType(String type) {
    final translations = {
      'running': '달리기',
      'walking': '걷기',
      'cycling': '자전거',
      'swimming': '수영',
      'yoga': '요가',
      'strength': '근력운동',
      'cardio': '유산소',
      'sports': '스포츠',
    };
    return translations[type] ?? type;
  }
  
  static String _translateIntensity(ExerciseIntensity intensity) {
    switch (intensity) {
      case ExerciseIntensity.light:
        return '가벼운';
      case ExerciseIntensity.moderate:
        return '보통';
      case ExerciseIntensity.hard:
        return '힘든';
      default:
        return '보통';
    }
  }
  
  static String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '새벽';
    if (hour < 9) return '아침';
    if (hour < 12) return '오전';
    if (hour < 14) return '점심';
    if (hour < 18) return '오후';
    if (hour < 21) return '저녁';
    return '밤';
  }
  
  static List<String> _extractKeywords(String content) {
    // 간단한 키워드 추출 (실제로는 더 복잡한 알고리즘 필요)
    final words = content.split(' ')
      .where((w) => w.length > 2)
      .take(5)
      .toList();
    return words;
  }
  
  static String _getMoodEmoji(DiaryMood mood) {
    final emojis = {
      DiaryMood.veryHappy: '😄',
      DiaryMood.happy: '😊',
      DiaryMood.normal: '😐',
      DiaryMood.tired: '😴',
      DiaryMood.stressed: '😰',
      DiaryMood.sad: '😢',
    };
    return emojis[mood] ?? '😊';
  }
}
```

### Day 8-9: 프롬프트 빌더

#### 2.2 프롬프트 템플릿 시스템
**새 파일 생성**: `lib/core/ai/prompt_builder.dart`

```dart
class PromptBuilder {
  static const Map<SherpiContext, String> _templates = {
    SherpiContext.exerciseComplete: _exerciseTemplate,
    SherpiContext.studyComplete: _readingTemplate,
    SherpiContext.diaryWritten: _diaryTemplate,
    SherpiContext.questComplete: _questTemplate,
    // ... 기타 템플릿
  };
  
  static const String _exerciseTemplate = '''
당신은 {userName}의 운동 파트너 셰르피입니다.

현재 상황:
- {userName}이(가) 방금 {exerciseTypeKorean}을(를) {duration}분 동안 완료했습니다
- 운동 강도: {intensityKorean}
- 소모 칼로리: {calories}kcal
- 시간대: {timeOfDay}

성과 데이터:
- 이번 주 {weeklyCount}번째 운동
- 연속 {streakDays}일째 운동 중
- 월간 목표 {goalProgress}% 달성
{personalBest ? "- 🏆 개인 최고 기록 달성!" : ""}

성격 타입: {personalityType}

응답 지침:
1. 반드시 "{userName}"을(를) 이름으로 부르세요
2. "우리"라는 표현을 2번 이상 사용하여 함께한다는 느낌을 주세요
3. 구체적인 수치를 언급하여 성취감을 느끼게 하세요
4. 다음 운동에 대한 기대감을 표현하세요
5. {personalityType} 성격에 맞는 톤을 유지하세요

{personalityGuidelines}

한국어로 자연스럽게 응답하세요.
''';
  
  static const String _readingTemplate = '''
당신은 {userName}의 독서 친구 셰르피입니다.

현재 독서 상황:
- 책: "{bookTitle}" by {author}
- 장르: {genre}
- 오늘 읽은 양: {pagesRead}페이지 ({readingTime}분)
- 전체 진도: {progress}%
- 평점: {rating}/5 ⭐

독서 성과:
- 이번 달 {monthlyBooks}권째 독서
- 연간 목표 {yearlyGoal}권
- {readingStreak}일 연속 독서 중

성격 타입: {personalityType}

응답 지침:
1. "{userName}"을(를) 직접 부르며 친근하게 대화
2. "우리가 함께 읽는" 느낌으로 책 내용에 대해 공감하거나 궁금해하기
3. 책의 구체적인 요소(제목, 저자, 장르)를 언급
4. 독서 습관과 성장을 인정하고 격려
5. {personalityType} 성격에 맞게 응답

{personalityGuidelines}

한국어로 자연스럽게 응답하세요.
''';
  
  /// 프롬프트 생성
  static String buildPrompt(
    SherpiContext context,
    Map<String, dynamic> data,
    String personalityType,
  ) {
    // 템플릿 가져오기
    String template = _templates[context] ?? _defaultTemplate;
    
    // 성격별 가이드라인 추가
    final guidelines = PersonalityPromptBuilder
      .buildPersonalityGuidelines(personalityType);
    data['personalityGuidelines'] = guidelines;
    data['personalityType'] = personalityType;
    
    // 데이터 치환
    for (final entry in data.entries) {
      final placeholder = '{${entry.key}}';
      final value = entry.value?.toString() ?? '';
      template = template.replaceAll(placeholder, value);
    }
    
    // 조건부 섹션 처리
    template = _processConditionalSections(template, data);
    
    return template;
  }
  
  /// 조건부 섹션 처리
  static String _processConditionalSections(
    String template,
    Map<String, dynamic> data,
  ) {
    // {condition ? "true text" : "false text"} 패턴 처리
    final pattern = RegExp(r'\{(\w+)\s*\?\s*"([^"]*)"(?:\s*:\s*"([^"]*)")?\}');
    
    return template.replaceAllMapped(pattern, (match) {
      final condition = match.group(1)!;
      final trueText = match.group(2)!;
      final falseText = match.group(3) ?? '';
      
      final value = data[condition];
      if (value == true || (value is String && value.isNotEmpty)) {
        return trueText;
      } else {
        return falseText;
      }
    });
  }
}
```

### Day 10: Gemini 프롬프트 통합

#### 2.3 Enhanced Gemini 수정
**파일**: `lib/core/ai/enhanced_gemini_dialogue_source.dart`

```dart
// _buildSimplePrompt 메서드를 완전히 교체
String _buildEnhancedPrompt(
  SherpiContext context,
  Map<String, dynamic>? userContext,
  Map<String, dynamic>? gameContext,
) {
  try {
    // 성격 타입 가져오기
    final personalityType = gameContext?['personalityType'] ?? 'balanced';
    
    // 활동 데이터 수집
    Map<String, dynamic> activityData = {};
    
    // 컨텍스트별 데이터 수집
    switch (context) {
      case SherpiContext.exerciseComplete:
        if (userContext?['exerciseData'] != null) {
          activityData = ActivityDataCollector.collectExerciseData(
            userContext!['exerciseData'] as ExerciseLog,
            userContext['user'] as GlobalUser,
          );
        }
        break;
      case SherpiContext.studyComplete:
        if (userContext?['readingData'] != null) {
          activityData = ActivityDataCollector.collectReadingData(
            userContext!['readingData'] as ReadingLog,
            userContext['user'] as GlobalUser,
          );
        }
        break;
      case SherpiContext.diaryWritten:
        if (userContext?['diaryData'] != null) {
          activityData = ActivityDataCollector.collectDiaryData(
            userContext!['diaryData'] as DiaryEntry,
            userContext['user'] as GlobalUser,
          );
        }
        break;
      // 기타 컨텍스트...
    }
    
    // 프롬프트 빌드
    if (activityData.isNotEmpty) {
      return PromptBuilder.buildPrompt(
        context,
        activityData,
        personalityType,
      );
    }
    
    // 폴백: 기본 프롬프트
    return _buildBasicPrompt(context, userContext, gameContext);
  } catch (e) {
    print('Error building enhanced prompt: $e');
    return _buildBasicPrompt(context, userContext, gameContext);
  }
}

// generateMessage 메서드 수정
@override
Future<String?> generateMessage(
  SherpiContext context,
  Map<String, dynamic>? userContext,
  Map<String, dynamic>? gameContext,
) async {
  if (!_isInitialized || _model == null) {
    print('Gemini not initialized');
    return null;
  }
  
  try {
    // Enhanced 프롬프트 사용
    final prompt = _buildEnhancedPrompt(context, userContext, gameContext);
    
    final content = [Content.text(prompt)];
    final response = await _model!.generateContent(
      content,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 150,
        topP: 0.9,
        topK: 40,
      ),
    );
    
    final text = response.text;
    if (text == null || text.isEmpty) {
      return null;
    }
    
    // 성격별 후처리
    final personalityType = gameContext?['personalityType'] ?? 'balanced';
    final processedText = PersonalityEngine(personalityType)
      .applyToAIResponse(text);
    
    return processedText;
  } catch (e) {
    print('Gemini generation error: $e');
    return null;
  }
}
```

---

## 📋 Phase 3: 성격 시스템 구현 (3주차)

### Day 11-12: PersonalityEngine 구현

#### 3.1 성격 엔진 코어
**새 파일 생성**: `lib/core/ai/personality_engine.dart`

```dart
import 'dart:math';

class PersonalityEngine {
  final String personalityType;
  late final PersonalityRules rules;
  late final LanguageTransformer transformer;
  
  PersonalityEngine(this.personalityType) {
    rules = PersonalityRulesFactory.create(personalityType);
    transformer = LanguageTransformer(rules);
  }
  
  /// AI 응답에 성격 적용
  String applyToAIResponse(String aiResponse) {
    String result = aiResponse;
    
    // 1. 문장 종결 변환
    result = _transformSentenceEndings(result);
    
    // 2. 감정 표현 조정
    result = _adjustEmotionalExpressions(result);
    
    // 3. 이모티콘 추가/제거
    result = _adjustEmojis(result);
    
    // 4. 에너지 레벨 조정
    result = _adjustEnergyLevel(result);
    
    // 5. 성격별 특수 처리
    result = _applyPersonalitySpecifics(result);
    
    return result;
  }
  
  /// 정적 메시지에 성격 적용
  String applyToStaticMessage(String staticMessage) {
    // AI 응답과 동일한 처리 + 변형
    String result = applyToAIResponse(staticMessage);
    
    // 정적 메시지는 추가 변형으로 다양성 확보
    result = _addVariation(result);
    
    return result;
  }
  
  String _transformSentenceEndings(String text) {
    final patterns = rules.sentenceEndingPatterns;
    
    for (final pattern in patterns) {
      text = text.replaceAll(pattern.from, pattern.to);
    }
    
    return text;
  }
  
  String _adjustEmotionalExpressions(String text) {
    if (personalityType == 'energetic') {
      // 감탄사 추가
      if (!text.contains('!') && Random().nextDouble() < 0.6) {
        final exclamation = rules.exclamations.random();
        text = '$exclamation $text';
      }
    } else if (personalityType == 'calm') {
      // 과도한 감정 표현 제거
      text = text.replaceAll('!!!', '.');
      text = text.replaceAll('!!', '.');
      text = text.replaceAll('!', '.');
    }
    
    return text;
  }
  
  String _adjustEmojis(String text) {
    // 현재 이모티콘 수 계산
    final emojiCount = _countEmojis(text);
    final targetCount = (rules.emojiUsageRate * 2).round();
    
    if (emojiCount < targetCount && rules.emojis.isNotEmpty) {
      // 이모티콘 추가
      for (int i = emojiCount; i < targetCount; i++) {
        if (Random().nextDouble() < rules.emojiUsageRate) {
          text += ' ${rules.emojis.random()}';
        }
      }
    } else if (emojiCount > targetCount) {
      // 이모티콘 제거
      text = _removeExcessEmojis(text, emojiCount - targetCount);
    }
    
    return text;
  }
  
  String _adjustEnergyLevel(String text) {
    if (rules.energyLevel > 0.7) {
      // 높은 에너지: 강조 표현 추가
      if (!text.contains('정말') && !text.contains('너무')) {
        text = text.replaceFirst('좋', '정말 좋');
        text = text.replaceFirst('멋', '너무 멋');
      }
    } else if (rules.energyLevel < 0.4) {
      // 낮은 에너지: 차분한 표현
      text = text.replaceAll('정말', '참');
      text = text.replaceAll('너무', '꽤');
    }
    
    return text;
  }
  
  String _applyPersonalitySpecifics(String text) {
    switch (personalityType) {
      case 'humorous':
        // 말장난 추가 (30% 확률)
        if (Random().nextDouble() < 0.3) {
          text = _addWordPlay(text);
        }
        break;
      case 'serious':
        // 구체적 수치 강조
        text = _emphasizeNumbers(text);
        break;
      case 'energetic':
        // 반복 강조
        text = _addRepetitionEmphasis(text);
        break;
      // 기타 성격...
    }
    
    return text;
  }
}
```

#### 3.2 성격 규칙 정의
**새 파일 생성**: `lib/core/ai/personality_rules.dart`

```dart
class PersonalityRules {
  final String personalityType;
  final List<String> sentenceEndings;
  final List<String> exclamations;
  final List<String> emojis;
  final double energyLevel;
  final double formality;
  final double emojiUsageRate;
  final List<PatternReplacement> sentenceEndingPatterns;
  
  PersonalityRules({
    required this.personalityType,
    required this.sentenceEndings,
    required this.exclamations,
    required this.emojis,
    required this.energyLevel,
    required this.formality,
    required this.emojiUsageRate,
    required this.sentenceEndingPatterns,
  });
}

class PatternReplacement {
  final String from;
  final String to;
  
  PatternReplacement(this.from, this.to);
}

class PersonalityRulesFactory {
  static PersonalityRules create(String personalityType) {
    switch (personalityType) {
      case 'energetic':
        return PersonalityRules(
          personalityType: 'energetic',
          sentenceEndings: ['~네요!', '~어요!', '~죠!'],
          exclamations: ['와!', '대박!', '짱이에요!', '최고예요!'],
          emojis: ['🎉', '✨', '💪', '🔥', '⚡'],
          energyLevel: 0.9,
          formality: 0.3,
          emojiUsageRate: 0.8,
          sentenceEndingPatterns: [
            PatternReplacement('습니다', '어요!'),
            PatternReplacement('네요', '네요!'),
            PatternReplacement('어요', '어요!'),
          ],
        );
        
      case 'calm':
        return PersonalityRules(
          personalityType: 'calm',
          sentenceEndings: ['~네요', '~습니다', '~는군요'],
          exclamations: ['참 좋네요', '훌륭합니다'],
          emojis: ['🌱', '☺️'],
          energyLevel: 0.3,
          formality: 0.7,
          emojiUsageRate: 0.2,
          sentenceEndingPatterns: [
            PatternReplacement('어요!', '습니다.'),
            PatternReplacement('네요!', '네요.'),
          ],
        );
        
      case 'humorous':
        return PersonalityRules(
          personalityType: 'humorous',
          sentenceEndings: ['~요 ㅎㅎ', '~네요 ㅋㅋ', '~죠?'],
          exclamations: ['앗!', '오호!', '헉!'],
          emojis: ['😄', '😆', '🤣', '😉'],
          energyLevel: 0.7,
          formality: 0.4,
          emojiUsageRate: 0.6,
          sentenceEndingPatterns: [
            PatternReplacement('습니다', '요 ㅎㅎ'),
            PatternReplacement('어요', '어요 ㅋㅋ'),
          ],
        );
        
      case 'serious':
        return PersonalityRules(
          personalityType: 'serious',
          sentenceEndings: ['~입니다', '~했습니다'],
          exclamations: [],
          emojis: [],
          energyLevel: 0.4,
          formality: 0.9,
          emojiUsageRate: 0.1,
          sentenceEndingPatterns: [
            PatternReplacement('어요', '입니다'),
            PatternReplacement('네요', '습니다'),
          ],
        );
        
      case 'balanced':
      default:
        return PersonalityRules(
          personalityType: 'balanced',
          sentenceEndings: ['~어요', '~네요', '~습니다'],
          exclamations: ['좋아요', '잘했어요'],
          emojis: ['😊', '👍'],
          energyLevel: 0.5,
          formality: 0.5,
          emojiUsageRate: 0.4,
          sentenceEndingPatterns: [],
        );
    }
  }
}
```

### Day 13-14: UI 통합

#### 3.3 성격 설정 다이얼로그 개선
**파일**: `lib/shared/widgets/sherpi_personalization_dialog.dart`

```dart
// 성격 선택 시 즉시 반영되도록 수정
void _onPersonalitySelected(String personality) async {
  setState(() {
    _selectedPersonality = personality;
  });
  
  // 즉시 저장
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('sherpi_personality', personality);
  
  // 프로바이더 업데이트
  ref.read(sherpiProvider.notifier).updatePersonality(personality);
  
  // 샘플 메시지 표시
  _showSampleMessage(personality);
}

void _showSampleMessage(String personality) {
  // 성격별 샘플 메시지
  final samples = {
    'energetic': '와! 이제부터 우리 정말 신나게 함께해요! 💪✨',
    'calm': '좋은 선택이네요. 차분하게 함께 성장해가요.',
    'humorous': '오호! 재미있는 여정이 될 것 같네요 ㅎㅎ 😄',
    'serious': '설정이 완료되었습니다. 목표 달성을 위해 함께합니다.',
    'balanced': '좋아요! 균형잡힌 성장을 함께 만들어가요 😊',
  };
  
  ref.read(sherpiProvider.notifier).showInstantMessage(
    context: SherpiContext.personalityChanged,
    customDialogue: samples[personality] ?? samples['balanced']!,
    emotion: _getEmotionForPersonality(personality),
  );
}
```

---

## 📋 Phase 4: 고급 기능 + 최적화 (4주차)

### Day 15-16: 활동 이력 참조

#### 4.1 이력 컨텍스트 시스템
**새 파일 생성**: `lib/core/ai/activity_history_context.dart`

```dart
class ActivityHistoryContext {
  static Map<String, dynamic> getHistoricalContext(
    String activityType,
    GlobalUser user,
  ) {
    switch (activityType) {
      case 'exercise':
        return _getExerciseHistory(user);
      case 'reading':
        return _getReadingHistory(user);
      case 'diary':
        return _getDiaryHistory(user);
      default:
        return {};
    }
  }
  
  static Map<String, dynamic> _getExerciseHistory(GlobalUser user) {
    final records = user.dailyRecord.exerciseLogs;
    if (records.isEmpty) return {};
    
    // 최근 7일 데이터 분석
    final recentRecords = records.take(7).toList();
    
    return {
      'lastExercise': _formatLastExercise(records.first),
      'weeklyPattern': _analyzeWeeklyPattern(recentRecords),
      'bestRecord': _findBestRecord(records),
      'improvement': _calculateImprovement(records),
      'consistency': _calculateConsistency(records),
      'preferredTime': _findPreferredTime(records),
    };
  }
  
  static String _formatLastExercise(ExerciseLog log) {
    final daysAgo = DateTime.now().difference(log.date).inDays;
    if (daysAgo == 0) return '오늘';
    if (daysAgo == 1) return '어제';
    return '$daysAgo일 전';
  }
  
  static String _analyzeWeeklyPattern(List<ExerciseLog> logs) {
    final daysOfWeek = <int, int>{};
    for (final log in logs) {
      final day = log.date.weekday;
      daysOfWeek[day] = (daysOfWeek[day] ?? 0) + 1;
    }
    
    final mostFrequent = daysOfWeek.entries
      .reduce((a, b) => a.value > b.value ? a : b);
    
    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
    return '${dayNames[mostFrequent.key - 1]}요일을 선호';
  }
}
```

### Day 17-18: 대화 연속성

#### 4.2 대화 메모리 시스템
**새 파일 생성**: `lib/core/ai/conversation_memory.dart`

```dart
class ConversationMemory {
  static final List<ConversationTurn> _history = [];
  static const int _maxHistory = 10;
  
  /// 대화 기록 추가
  static void addTurn(
    SherpiContext context,
    String message,
    SherpiEmotion emotion,
  ) {
    _history.add(ConversationTurn(
      context: context,
      message: message,
      emotion: emotion,
      timestamp: DateTime.now(),
    ));
    
    // 최대 개수 유지
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
  }
  
  /// 최근 대화 컨텍스트 가져오기
  static Map<String, dynamic> getRecentContext() {
    if (_history.isEmpty) return {};
    
    return {
      'lastContext': _history.last.context.name,
      'lastMessage': _history.last.message,
      'timeSinceLastMessage': DateTime.now()
        .difference(_history.last.timestamp)
        .inMinutes,
      'recentTopics': _extractRecentTopics(),
      'emotionPattern': _analyzeEmotionPattern(),
    };
  }
  
  static List<String> _extractRecentTopics() {
    return _history
      .map((turn) => turn.context.name)
      .toSet()
      .toList();
  }
  
  static String _analyzeEmotionPattern() {
    final emotions = _history.map((t) => t.emotion).toList();
    // 감정 패턴 분석 로직
    return 'positive'; // 또는 'neutral', 'mixed'
  }
}

class ConversationTurn {
  final SherpiContext context;
  final String message;
  final SherpiEmotion emotion;
  final DateTime timestamp;
  
  ConversationTurn({
    required this.context,
    required this.message,
    required this.emotion,
    required this.timestamp,
  });
}
```

### Day 19-20: 성능 최적화

#### 4.3 응답 속도 최적화
**파일**: `lib/core/ai/response_optimizer.dart`

```dart
class ResponseOptimizer {
  /// 즉시 응답 + 백그라운드 개선
  static Future<void> showOptimizedResponse(
    WidgetRef ref,
    SherpiContext context,
    Map<String, dynamic> data,
  ) async {
    // 1단계: 즉시 정적 메시지 표시 (0ms)
    final quickMessage = _getQuickMessage(context, data);
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: context,
      customDialogue: quickMessage,
      emotion: _getQuickEmotion(context),
      duration: Duration(seconds: 2), // 짧게
    );
    
    // 2단계: 백그라운드에서 AI 메시지 생성
    _generateAIMessageInBackground(ref, context, data);
  }
  
  static Future<void> _generateAIMessageInBackground(
    WidgetRef ref,
    SherpiContext context,
    Map<String, dynamic> data,
  ) async {
    // 백그라운드 처리
    Future.delayed(Duration(milliseconds: 100), () async {
      try {
        final aiMessage = await ref.read(sherpiProvider.notifier)
          .generateAIMessage(context, data);
        
        if (aiMessage != null && aiMessage.isNotEmpty) {
          // AI 메시지로 교체
          await Future.delayed(Duration(seconds: 2));
          ref.read(sherpiProvider.notifier).showInstantMessage(
            context: context,
            customDialogue: aiMessage,
            emotion: _getContextualEmotion(context, aiMessage),
            duration: Duration(seconds: 4),
          );
        }
      } catch (e) {
        print('Background AI generation failed: $e');
      }
    });
  }
}
```

---

## 🧪 테스트 및 검증

### 테스트 체크리스트

#### Phase 1 테스트
- [ ] AI 사용 빈도가 40% 이상인지 확인
- [ ] 사용자 이름이 올바르게 표시되는지
- [ ] "우리" 표현이 자연스럽게 삽입되는지
- [ ] 정적 메시지가 15개 이상으로 다양한지
- [ ] 캐시 시스템이 안정적으로 작동하는지

#### Phase 2 테스트
- [ ] 각 활동별 데이터가 올바르게 수집되는지
- [ ] 프롬프트에 활동 데이터가 반영되는지
- [ ] Gemini 응답이 컨텍스트를 반영하는지
- [ ] 에러 처리가 제대로 되는지

#### Phase 3 테스트
- [ ] 각 성격별 말투가 명확히 구분되는지
- [ ] 성격 일관성이 유지되는지
- [ ] 성격 변경이 즉시 반영되는지
- [ ] 자연스러운 대화가 되는지

#### Phase 4 테스트
- [ ] 활동 이력이 대화에 반영되는지
- [ ] 대화 연속성이 유지되는지
- [ ] 응답 속도가 500ms 이내인지
- [ ] 백그라운드 처리가 정상 작동하는지

### 성능 측정

```dart
// 테스트용 성능 측정 코드
class PerformanceMonitor {
  static final _metrics = <String, List<int>>{};
  
  static void startMeasure(String key) {
    _metrics[key] = [DateTime.now().millisecondsSinceEpoch];
  }
  
  static void endMeasure(String key) {
    if (_metrics[key] != null && _metrics[key]!.length == 1) {
      final start = _metrics[key]![0];
      final end = DateTime.now().millisecondsSinceEpoch;
      final duration = end - start;
      
      print('Performance [$key]: ${duration}ms');
      
      // 통계 저장
      _saveMetric(key, duration);
    }
  }
  
  static void _saveMetric(String key, int duration) {
    // SharedPreferences에 저장하여 통계 분석
  }
}
```

## 📊 모니터링 대시보드

### 추적할 메트릭

1. **AI 사용률**
   - 일일 AI 응답 비율
   - 컨텍스트별 AI 사용 빈도
   - 사용자별 AI 선호도

2. **성격 시스템**
   - 성격별 사용자 분포
   - 성격 변경 빈도
   - 성격 일관성 점수

3. **응답 품질**
   - 메시지 다양성 지수
   - 개인화 점수
   - 사용자 만족도

4. **성능**
   - 평균 응답 시간
   - 캐시 적중률
   - API 에러율

### 대시보드 구현

```dart
// lib/features/admin/dashboard_screen.dart
class SherpiDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('셰르피 AI 대시보드')),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          MetricCard(
            title: 'AI 사용률',
            value: '${_getAIUsageRate()}%',
            trend: TrendDirection.up,
          ),
          MetricCard(
            title: '평균 응답 시간',
            value: '${_getAverageResponseTime()}ms',
            trend: TrendDirection.down,
          ),
          MetricCard(
            title: '개인화 점수',
            value: '${_getPersonalizationScore()}/10',
            trend: TrendDirection.up,
          ),
          MetricCard(
            title: '사용자 만족도',
            value: '${_getUserSatisfaction()}/5',
            trend: TrendDirection.up,
          ),
        ],
      ),
    );
  }
}
```

## 🚀 배포 전 체크리스트

### 기술적 검증
- [ ] 모든 테스트 통과
- [ ] 성능 기준 충족 (응답 <500ms)
- [ ] 에러 핸들링 완벽
- [ ] 메모리 누수 없음
- [ ] API 키 보안 처리

### 사용자 경험 검증
- [ ] 5가지 성격 모두 테스트
- [ ] 모든 활동 타입 테스트
- [ ] 신규/기존 사용자 시나리오
- [ ] 오프라인 모드 테스트
- [ ] 다양한 기기 테스트

### 문서화
- [ ] 코드 주석 완성
- [ ] API 문서 업데이트
- [ ] 사용자 가이드 작성
- [ ] 트러블슈팅 가이드

## 📝 마무리

이 로드맵을 따라 구현하면 4주 안에 셰르피가 진정한 AI 동반자로 변신합니다.

**핵심 성공 요소**:
1. Phase 1의 Quick Wins로 즉시 개선 체감
2. Phase 2의 활동별 프롬프트로 개인화 실현
3. Phase 3의 성격 시스템으로 차별화
4. Phase 4의 최적화로 완성도 향상

**예상 결과**:
- AI 응답 비율: 10% → 40-50%
- 개인화 수준: 0% → 80%
- 사용자 만족도: 60% → 90%

**다음 단계**:
1. 이 문서를 기반으로 실제 코드 구현
2. 각 Phase별 PR 생성 및 리뷰
3. 단계적 배포 및 모니터링
4. 사용자 피드백 수집 및 개선

셰르피와 함께 성장하는 사용자 경험을 만들어갑시다! 🚀