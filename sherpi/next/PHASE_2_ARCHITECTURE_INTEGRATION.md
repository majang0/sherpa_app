# Phase 2 아키텍처 통합 가이드

## 🏗️ 개요

Phase 2 구현을 위한 기존 셰르파 앱 아키텍처와의 통합 전략을 제시합니다. 기존 시스템을 최대한 활용하여 안정성을 보장하면서도 새로운 기능을 효과적으로 통합하는 방법을 안내합니다.

---

## 🔍 기존 아키텍처 현황

### ✅ 완전히 구축된 핵심 시스템들

#### 1. **SherpiProvider 생태계** (`lib/shared/providers/global_sherpi_provider.dart`)
```dart
class SherpiNotifier extends StateNotifier<SherpiState> {
  // 이미 구현된 핵심 기능들:
  - 메시지 관리 및 히스토리 (최대 50개 자동 보관)
  - 감정 상태 및 컨텍스트 처리 
  - AI 통합 (SmartSherpiManager + RealDataConnector)
  - 중복 메시지 방지 (고도화된 전역 락 시스템)
  - 응답 소스 추적 (static, AI, cached)
  - 관계 시스템 연동 (친밀도, 상호작용 기록)
}
```

#### 2. **감정 및 컨텍스트 시스템**
```dart
// lib/core/constants/sherpi_emotions.dart
enum SherpiEmotion { 
  defaults, happy, sad, surprised, thinking, guiding, 
  cheering, warning, sleeping, special // 10가지 완비
}

// lib/core/constants/sherpi_dialogues.dart  
enum SherpiContext {
  welcome, levelUp, exerciseComplete, questComplete,
  // ... 총 27가지 상황 컨텍스트
}
```

#### 3. **관계 및 친밀도 시스템** (`lib/features/sherpi_relationship/`)
```dart
class SherpiRelationshipNotifier extends StateNotifier<SherpiRelationship> {
  // Phase 2에서 직접 활용 가능한 기능들:
  - intimacyLevel: 자동 계산되는 1-10 레벨
  - specialMoments: 특별한 순간들 자동 기록
  - emotionalSync: 감정 동기화 점수 (0.0-1.0)
  - interactionTypes: 상호작용 유형별 통계
  - relationshipStats: 관계 통계 데이터
}
```

#### 4. **데이터 흐름 시스템**
```dart
// 이미 완성된 활동 완료 흐름
GlobalUserNotifier.handleActivityCompletion()
  ↓ 자동 호출
SherpiNotifier.showMessage() 
  ↓ 자동 연동
SherpiRelationshipNotifier.recordInteraction()
  ↓ 감정 분석
EmotionAnalysisNotifier.analyzeUserEmotion()
```

---

## 🔗 Phase 2 통합 포인트

### 1. 개인화 설정 시스템 통합

#### 기존 시스템 확장
```dart
// ✅ 기존 SherpiState 메타데이터 활용
Map<String, dynamic> metadata = {
  'response_source': 'ai',        // 기존
  'emotion_analyzed': true,       // 기존
  'user_preferences': {           // 🆕 Phase 2 추가
    'personality': 'energetic',
    'nickname': '친구',
    'messageFrequency': 1.0,
    'emojiLevel': 2,
    'intimacyDisplayMode': 'hearts'
  }
};
```

#### 새로운 Settings Provider 구조
```dart
// lib/features/settings/providers/sherpi_settings_provider.dart
class SherpiSettingsNotifier extends StateNotifier<SherpiSettings> {
  final Ref _ref;
  final SharedPreferences _prefs;
  
  SherpiSettingsNotifier(this._ref, this._prefs) : super(...) {
    // 🔗 기존 SherpiNotifier와 연동
    addListener((settings) {
      _applySherpiSettings(settings);
    });
  }
  
  void _applySherpiSettings(SherpiSettings settings) {
    // 기존 SherpiNotifier에 설정 적용
    final sherpiNotifier = _ref.read(sherpiProvider.notifier);
    sherpiNotifier.updatePersonalitySettings(settings);
  }
}

// 🔗 기존 SherpiNotifier 확장 메서드 추가
extension SherpiSettingsIntegration on SherpiNotifier {
  void updatePersonalitySettings(SherpiSettings settings) {
    // 기존 showMessage 로직에 개인화 적용
    // SmartSherpiManager에 설정 전달
  }
}
```

### 2. 빠른 응답 시스템 통합

#### 기존 대화 시스템 활용
```dart
class QuickResponseNotifier extends StateNotifier<QuickResponseState> {
  List<QuickResponse> getResponsesForContext(SherpiContext context) {
    // 🔗 기존 sherpiDialogues 데이터 활용
    final baseDialogues = sherpiDialogues[context] ?? ['안녕하세요!'];
    
    return baseDialogues.map((dialogue) => QuickResponse(
      id: '${context.name}_${dialogue.hashCode}',
      text: dialogue,
      emotion: SherpiDialogueUtils.getRecommendedEmotion(context), // 기존 함수
      context: context,
      action: () => _ref.read(sherpiProvider.notifier).showInstantMessage(
        context: context,                    // 기존 메서드 활용
        customDialogue: dialogue,
        forceShow: true,
      ),
    )).take(5).toList();
  }
}
```

#### 컨텍스트 시스템 확장
```dart
// 기존 SherpiContext enum에 추가
enum SherpiContext {
  // ... 기존 27개 컨텍스트
  
  // 🆕 빠른 응답용 새 컨텍스트
  quickResponseMorning,     // 아침 빠른 응답
  quickResponseExercise,    // 운동 후 빠른 응답
  quickResponseEncouragement, // 격려 빠른 응답
}
```

### 3. 메시지 히스토리 확장

#### 기존 모델 확장 (새 모델 생성하지 않음)
```dart
// lib/shared/models/sherpi_message_history.dart 확장
extension SherpiMessageHistoryPhase2 on SherpiMessageHistory {
  // 🆕 메타데이터 기반 새 속성들
  bool get isFavorite => metadata['isFavorite'] == true;
  bool get isMilestone => metadata['isMilestone'] == true;
  
  MessageCategory get category {
    // 기존 SherpiContext를 MessageCategory로 매핑
    switch (context) {
      case SherpiContext.levelUp:
      case SherpiContext.badgeEarned:
        return MessageCategory.achievement;
      case SherpiContext.exerciseComplete:
      case SherpiContext.studyComplete:
        return MessageCategory.activity;
      default:
        return MessageCategory.general;
    }
  }
  
  // 🆕 즐겨찾기 토글 메서드
  SherpiMessageHistory toggleFavorite() {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata['isFavorite'] = !isFavorite;
    
    return SherpiMessageHistory(
      id: id,
      emotion: emotion,
      message: message,
      context: context,
      timestamp: timestamp,
      metadata: newMetadata,
    );
  }
}
```

### 4. 분석 시스템 통합

#### 기존 데이터 활용한 분석
```dart
class UserAnalyticsNotifier extends StateNotifier<UserAnalytics> {
  void _analyzeUserData() {
    // 🔗 기존 프로바이더들에서 데이터 수집
    final user = ref.read(globalUserProvider);
    final relationship = ref.read(sherpiRelationshipProvider);
    final relationshipStats = ref.read(relationshipStatsProvider);
    
    final analytics = UserAnalytics(
      // 🔗 기존 GlobalUser 데이터 활용
      userName: user.name ?? '사용자',
      totalDays: user.dailyRecords.length,
      currentLevel: user.level,
      totalXP: user.totalExperience,
      completedQuests: user.questsCompleted,
      
      // 🔗 기존 관계 시스템 데이터 활용  
      intimacyLevel: relationship.intimacyLevel,
      relationshipTitle: relationship.relationshipTitle,
      specialMomentsCount: relationship.specialMoments.length,
      emotionalSync: relationship.emotionalSync,
      consecutiveDays: relationship.consecutiveDays,
      
      // 🔗 기존 통계 시스템 활용
      favoriteInteraction: relationshipStats['favoriteInteraction'],
      averageInteractionsPerDay: relationshipStats['averageInteractionsPerDay'],
    );
    
    state = analytics;
  }
}
```

---

## 🔧 필수 통합 작업

### 1. SherpiNotifier 확장 메서드 추가
```dart
// lib/shared/providers/global_sherpi_provider.dart에 추가
extension SherpiNotifierPhase2 on SherpiNotifier {
  // 🆕 설정 적용 메서드
  void applyUserSettings(SherpiSettings settings) {
    // SmartSherpiManager에 설정 전달
    _smartManager.updatePersonality(settings.sherpiPersonality);
    _smartManager.setMessageFrequency(settings.messageFrequency);
  }
  
  // 🆕 빠른 응답 처리 메서드  
  void handleQuickResponse(QuickResponse response) {
    showInstantMessage(
      context: response.context,
      customDialogue: response.text,
      emotion: response.emotion,
      forceShow: true,
    );
    
    // 사용 통계 기록
    _recordQuickResponseUsage(response);
  }
  
  // 🆕 메시지 즐겨찾기 토글
  void toggleMessageFavorite(String messageId) {
    final historyIndex = _messageHistory.indexWhere((m) => m.id == messageId);
    if (historyIndex != -1) {
      _messageHistory[historyIndex] = _messageHistory[historyIndex].toggleFavorite();
    }
  }
}
```

### 2. GlobalUserNotifier 확장
```dart
// lib/shared/providers/global_user_provider.dart에 추가  
extension GlobalUserNotifierPhase2 on GlobalUserNotifier {
  // 🆕 분석 데이터 생성 메서드
  UserAnalytics generateAnalytics() {
    final relationship = _ref.read(sherpiRelationshipProvider);
    final relationshipStats = _ref.read(relationshipStatsProvider);
    
    return UserAnalytics(
      // 기존 데이터 + 관계 데이터 통합
      userData: _mapUserData(state),
      relationshipData: _mapRelationshipData(relationship, relationshipStats),
      activityData: _mapActivityData(state.dailyRecords),
    );
  }
}
```

### 3. 새로 생성할 Provider들
```dart
// 🆕 설정 전용 Provider
final sherpiSettingsProvider = StateNotifierProvider<SherpiSettingsNotifier, SherpiSettings>((ref) {
  return SherpiSettingsNotifier(ref, ref.watch(sharedPreferencesProvider));
});

// 🆕 빠른 응답 Provider  
final quickResponseProvider = StateNotifierProvider<QuickResponseNotifier, QuickResponseState>((ref) {
  return QuickResponseNotifier(ref);
});

// 🆕 분석 UI Provider
final userAnalyticsProvider = StateNotifierProvider<UserAnalyticsNotifier, UserAnalytics>((ref) {
  return UserAnalyticsNotifier(ref);
});

// 🆕 메시지 히스토리 확장 Provider
final enhancedMessageHistoryProvider = Provider<List<SherpiMessageHistory>>((ref) {
  return ref.watch(sherpiProvider.notifier).getMessageHistory();
});
```

---

## ⚠️ 주의사항 및 제약

### 1. 기존 시스템과의 충돌 방지
```dart
// ❌ 피해야 할 패턴들
class NewSherpiMessage { } // 기존 SherpiMessageHistory와 충돌
class IntimacyLevel { }     // 기존 SherpiRelationship.intimacyLevel과 충돌  
class SherpiEmotion { }     // 기존 enum과 충돌

// ✅ 권장 패턴들  
extension SherpiMessageHistoryExtension { } // 기존 모델 확장
// 기존 SherpiRelationship.intimacyLevel 활용
// 기존 SherpiEmotion enum 활용
```

### 2. 성능 고려사항
- **메모리 관리**: 기존 50개 메시지 히스토리 제한 유지
- **상태 동기화**: 불필요한 rebuild 방지를 위한 Provider 최적화
- **캐싱 전략**: 기존 SmartSherpiManager 캐싱 시스템 활용

### 3. 데이터 일관성
- **SharedPreferences 키 충돌 방지**: `phase2_` 접두사 사용
- **메타데이터 표준화**: 새로운 메타데이터 키 네이밍 규칙 준수
- **상태 동기화**: 여러 Provider 간 데이터 정합성 보장

---

## 🚀 구현 우선순위

### Phase A: 기존 시스템 확장 (1주)
1. **SherpiNotifier 확장 메서드 추가**
2. **SherpiMessageHistory 확장 속성 구현**  
3. **기본 설정 시스템 구축**

### Phase B: 새로운 UI 시스템 (1-2주)  
1. **설정 화면 구현**
2. **빠른 응답 UI 구현**
3. **향상된 메시지 히스토리 UI**

### Phase C: 고급 기능 (1주)
1. **사용자 분석 시스템**
2. **친밀도 대시보드**
3. **성능 최적화 및 테스트**

---

## 🔍 통합 검증 체크리스트

### 필수 확인 사항
- [ ] 기존 SherpiProvider 동작에 영향 없음
- [ ] SherpiRelationship 데이터 정합성 유지
- [ ] 메시지 히스토리 호환성 보장
- [ ] SharedPreferences 키 충돌 없음
- [ ] Provider 의존성 순환 참조 없음
- [ ] 메모리 누수 없음
- [ ] 기존 AI 시스템과 호환

### 성능 검증
- [ ] 앱 시작 시간 변화 없음
- [ ] 메시지 표시 지연 없음
- [ ] UI 반응성 유지
- [ ] 배터리 소모 증가 없음

---

## 💡 성공을 위한 핵심 원칙

1. **기존 우선**: 새로운 것보다 기존 시스템 활용 최우선
2. **점진적 확장**: 기존 코드를 단계적으로 확장
3. **하위 호환성**: 기존 기능에 영향을 주지 않는 개발
4. **데이터 일관성**: 단일 데이터 소스 원칙 준수
5. **성능 우선**: 새로운 기능이 성능에 악영향을 주지 않도록

이 가이드를 따르면 기존 시스템의 안정성을 유지하면서도 Phase 2의 혁신적인 기능들을 성공적으로 통합할 수 있습니다.

---

*다음 단계: [구현 가이드](PHASE_2_IMPLEMENTATION_GUIDE.md)에서 구체적인 코드 구현 방법을 확인하세요.*