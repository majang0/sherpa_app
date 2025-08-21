# 셰르피 AI 시스템 종합 개선 계획서

## 🎯 비전 및 목표

### 비전
**"사용자가 진정으로 셰르피와 함께 성장한다고 느끼는 AI 동반자 시스템 구축"**

### 핵심 목표
1. **AI 응답 비율**: 10% → 40-50%로 증가
2. **개인화 수준**: 0% → 80% 이상 달성
3. **메시지 다양성**: 무한 변형 가능한 동적 시스템
4. **감정적 연결**: 사용자와 진정한 유대감 형성

## 🏗️ 개선 아키텍처

### 1. AI 활용도 극대화 전략

#### 1.1 Smart AI Decision Engine 재설계

**현재 → 개선안**
```dart
// 개선된 AI 사용 결정 로직
class ImprovedAIDecisionEngine {
  static bool shouldUseAI(
    SherpiContext context,
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
  ) {
    // 기본 AI 사용률 40%
    double aiProbability = 0.4;
    
    // 컨텍스트별 가중치
    if (context.isActivityCompletion) aiProbability += 0.2;
    if (context.isEmotionalMoment) aiProbability += 0.15;
    if (userContext.containsKey('achievement')) aiProbability += 0.1;
    
    // 반복 방지: 최근 5분 내 같은 컨텍스트면 확률 감소
    if (recentlyUsedContext(context)) aiProbability -= 0.2;
    
    // 신규 사용자도 AI 경험 (첫 7일은 보너스)
    if (userDays < 7) aiProbability += 0.15;
    
    // 성격 타입별 AI 선호도
    if (personalityType == 'humorous') aiProbability += 0.1;
    
    return Random().nextDouble() < aiProbability;
  }
}
```

#### 1.2 컨텍스트 확장

**새로운 AI 트리거 포인트**:
- ✅ 모든 활동 완료 시 (운동, 독서, 일기, 집중)
- ✅ 연속 활동 달성 (3일, 7일, 30일)
- ✅ 목표 근접/달성 시
- ✅ 특정 시간대 활동 (아침 운동, 밤 독서)
- ✅ 기분 변화 감지 시
- ✅ 활동 패턴 변화 시

### 2. 활동별 전문 응답 시스템

#### 2.1 데이터 수집 레이어

```dart
class ActivityDataCollector {
  // 운동 데이터 수집
  static Map<String, dynamic> collectExerciseData(ExerciseSession session) {
    return {
      'userName': user.nickname ?? user.name,
      'exerciseType': session.type,
      'duration': session.durationMinutes,
      'intensity': session.intensity,
      'calories': session.calories,
      'heartRate': session.avgHeartRate,
      'weeklyCount': user.weeklyExerciseCount,
      'monthlyProgress': user.monthlyExerciseProgress,
      'personalBest': session.isPersonalBest,
      'timeOfDay': _getTimeOfDay(),
      'weather': _getCurrentWeather(),
      'streakDays': user.exerciseStreak,
      'previousIntensity': _getPreviousIntensity(),
      'goalProgress': _calculateGoalProgress(),
    };
  }
  
  // 독서 데이터 수집
  static Map<String, dynamic> collectReadingData(ReadingSession session) {
    return {
      'userName': user.nickname ?? user.name,
      'bookTitle': session.bookTitle,
      'author': session.author,
      'genre': session.genre,
      'pagesRead': session.pagesRead,
      'totalPages': session.totalPages,
      'readingSpeed': session.pagesPerMinute,
      'progress': session.progressPercent,
      'rating': session.userRating,
      'notes': session.highlights.length,
      'readingTime': session.durationMinutes,
      'preferredGenres': user.preferredGenres,
      'monthlyBooks': user.monthlyBookCount,
      'readingGoal': user.yearlyBookGoal,
    };
  }
}
```

#### 2.2 프롬프트 템플릿 엔진

```dart
class PromptTemplateEngine {
  static String generateActivityPrompt(
    SherpiContext context,
    Map<String, dynamic> activityData,
    String personalityType,
  ) {
    final template = _getTemplateForContext(context);
    return template.format(
      data: activityData,
      personality: personalityType,
      guidelines: _getPersonalityGuidelines(personalityType),
      contextRules: _getContextRules(context),
    );
  }
}
```

### 3. 성격 시스템 실체화

#### 3.1 성격별 언어 변환 엔진

```dart
class PersonalityLanguageEngine {
  // 성격별 말투 변환 규칙
  static final Map<String, LanguageRules> personalityRules = {
    'energetic': LanguageRules(
      sentenceEndings: ['~네요!', '~어요!', '~죠!'],
      exclamations: ['와!', '대박!', '짱이에요!', '최고예요!'],
      emojis: ['🎉', '✨', '💪', '🔥', '⚡'],
      energyLevel: 0.9,
      formalityLevel: 0.3,
    ),
    'calm': LanguageRules(
      sentenceEndings: ['~네요', '~습니다', '~는군요'],
      exclamations: ['참 좋네요', '훌륭합니다', '의미있네요'],
      emojis: ['🌱', '☺️'],  // 최소 사용
      energyLevel: 0.3,
      formalityLevel: 0.7,
    ),
    'humorous': LanguageRules(
      sentenceEndings: ['~요 ㅎㅎ', '~네요 ㅋㅋ', '~죠?'],
      exclamations: ['앗!', '오호!', '헉!'],
      emojis: ['😄', '😆', '🤣', '😉'],
      energyLevel: 0.7,
      formalityLevel: 0.4,
      useWordPlay: true,
      useMetaphors: true,
    ),
    'serious': LanguageRules(
      sentenceEndings: ['~입니다', '~했습니다', '~하십시오'],
      exclamations: [], // 감탄사 최소화
      emojis: [], // 이모티콘 사용 안함
      energyLevel: 0.4,
      formalityLevel: 0.9,
      useNumbers: true,
      useAnalysis: true,
    ),
    'balanced': LanguageRules(
      sentenceEndings: ['~어요', '~네요', '~습니다'],
      exclamations: ['좋아요', '잘했어요'],
      emojis: ['😊', '👍'],
      energyLevel: 0.5,
      formalityLevel: 0.5,
    ),
  };
}
```

#### 3.2 일관성 유지 시스템

```dart
class PersonalityConsistencyManager {
  // 성격 일관성 점수 계산
  static double calculateConsistency(
    String message,
    String personalityType,
  ) {
    final rules = PersonalityLanguageEngine.personalityRules[personalityType];
    double score = 0.0;
    
    // 문장 종결 패턴 검사
    score += _checkSentenceEndings(message, rules) * 0.3;
    
    // 에너지 레벨 검사
    score += _checkEnergyLevel(message, rules) * 0.3;
    
    // 격식 레벨 검사
    score += _checkFormalityLevel(message, rules) * 0.2;
    
    // 이모티콘 사용 검사
    score += _checkEmojiUsage(message, rules) * 0.2;
    
    return score;
  }
}
```

### 4. 사용자 중심 개인화

#### 4.1 이름 호출 시스템

```dart
class UserNameSystem {
  static String getUserCallName(GlobalUser user) {
    // 우선순위: 닉네임 > 이름 > 기본값
    if (user.nickname != null && user.nickname!.isNotEmpty) {
      return user.nickname!;
    }
    if (user.name != null && user.name!.isNotEmpty) {
      return user.name!;
    }
    return user.id.substring(0, 4); // ID 일부 사용
  }
  
  static String formatMessageWithName(String message, String userName) {
    // {userName} 플레이스홀더를 실제 이름으로 치환
    message = message.replaceAll('{userName}', userName);
    
    // "우리" 표현 자동 삽입
    if (!message.contains('우리')) {
      message = _insertWeExpression(message);
    }
    
    return message;
  }
}
```

#### 4.2 활동 이력 참조 시스템

```dart
class ActivityHistoryContext {
  static Map<String, dynamic> getHistoricalContext(
    String activityType,
    GlobalUser user,
  ) {
    return {
      'lastActivity': _getLastActivity(activityType, user),
      'bestRecord': _getBestRecord(activityType, user),
      'weeklyPattern': _getWeeklyPattern(activityType, user),
      'improvement': _calculateImprovement(activityType, user),
      'consistency': _getConsistencyScore(activityType, user),
      'preferences': _getUserPreferences(activityType, user),
    };
  }
}
```

### 5. 기술적 개선

#### 5.1 캐시 시스템 재설계

```dart
class ImprovedCacheSystem {
  // 안전한 캐시 구조
  static final cache = <String, CachedMessage>{};
  
  // FormatException 방지
  static Future<String?> getCachedOrGenerate(
    String key,
    Future<String> Function() generator,
  ) async {
    try {
      // 캐시 확인
      if (cache.containsKey(key)) {
        final cached = cache[key]!;
        if (!cached.isExpired) return cached.message;
      }
      
      // 새로 생성 (에러 처리 포함)
      final message = await generator().timeout(
        Duration(seconds: 3),
        onTimeout: () => null,
      );
      
      if (message != null) {
        cache[key] = CachedMessage(
          message: message,
          timestamp: DateTime.now(),
        );
      }
      
      return message;
    } catch (e) {
      // 에러 시 null 반환 (fallback으로 정적 메시지 사용)
      return null;
    }
  }
}
```

#### 5.2 응답 속도 최적화

```dart
class ResponseOptimizer {
  // 즉시 응답 + 백그라운드 개선
  static Future<void> showOptimizedResponse(
    BuildContext context,
    SherpiContext sherpiContext,
    Map<String, dynamic> data,
  ) async {
    // 1단계: 즉시 정적 메시지 표시 (0ms)
    final quickMessage = _getQuickStaticMessage(sherpiContext);
    _showMessage(quickMessage);
    
    // 2단계: 백그라운드에서 AI 메시지 생성
    if (shouldUseAI(sherpiContext, data)) {
      final aiMessage = await _generateAIMessage(sherpiContext, data);
      if (aiMessage != null) {
        // 3단계: AI 메시지로 교체 (부드러운 전환)
        _updateMessage(aiMessage);
      }
    }
  }
}
```

## 📈 성공 지표 (KPIs)

### 정량적 지표

| 지표 | 현재 | 1주차 목표 | 2주차 목표 | 최종 목표 |
|------|------|-----------|-----------|-----------|
| AI 응답 비율 | <10% | 25% | 35% | 40-50% |
| 메시지 중복률 | 80% | 50% | 30% | <10% |
| 개인화 점수 | 0/10 | 4/10 | 6/10 | 8/10 |
| 응답 시간 | 2-5초 | 1-2초 | <1초 | <500ms |
| 사용자 만족도 | - | 60% | 75% | 90%+ |

### 정성적 지표

1. **사용자 피드백**
   - "셰르피가 나를 알아본다"
   - "대화가 자연스럽다"
   - "함께 성장하는 느낌이다"

2. **행동 변화**
   - 셰르피 탭 빈도 증가
   - 대화 시간 증가
   - 앱 재방문율 증가

## 🚀 구현 우선순위

### Phase 1: Quick Wins (즉시)
1. ✅ 사용자 이름 호출 시스템
2. ✅ AI 사용 빈도 25%로 증가
3. ✅ 정적 메시지 10개로 확대

### Phase 2: Core Improvements (1주)
1. ✅ 활동별 데이터 수집 시스템
2. ✅ 기본 프롬프트 템플릿
3. ✅ 캐시 시스템 안정화

### Phase 3: Personality System (2주)
1. ✅ 성격별 언어 엔진
2. ✅ 일관성 유지 시스템
3. ✅ 성격-감정 연계

### Phase 4: Advanced Features (3-4주)
1. ✅ 활동 이력 참조
2. ✅ 학습 기반 개인화
3. ✅ 대화 연속성

## 💡 리스크 관리

### 기술적 리스크
- **FormatException**: Try-catch로 모든 API 호출 보호
- **응답 지연**: 즉시 정적 + 백그라운드 AI 패턴
- **토큰 제한**: 프롬프트 길이 최적화

### UX 리스크
- **과도한 AI**: 적절한 빈도 조절
- **일관성 부족**: 성격 일관성 점수 모니터링
- **개인정보**: 민감 정보 필터링

## 📌 다음 단계

1. **PROMPTS_DESIGN.md** 읽고 활동별 프롬프트 구현
2. **PERSONALITY_SYSTEM.md** 읽고 성격 시스템 구현
3. **IMPLEMENTATION_ROADMAP.md** 따라 단계별 개발

이 계획을 통해 셰르피는 진정한 **"AI 성장 동반자"**로 거듭날 것입니다.