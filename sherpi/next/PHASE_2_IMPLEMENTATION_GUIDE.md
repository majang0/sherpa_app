# Phase 2 구현 가이드

## 🏗️ 개요

이 가이드는 Phase 2 개발자를 위한 실무 중심의 구현 방법을 제시합니다. 기존 셰르파 앱의 아키텍처를 최대한 활용하여 효율적이고 안정적인 구현을 목표로 합니다.

---

## 📋 구현 우선순위 및 일정

### Week 1: 개인화 설정 & 분석 시스템 (2월 1-7일)
1. **SherpiSettingsProvider 구축** - 기존 SharedPreferences 패턴 확장
2. **사용자 분석 시스템** - 기존 데이터를 활용한 시각화
3. **셰르피 다이얼로그 액션 버튼** - 분석/설정 화면 연결

### Week 2: 상호작용 개선 (2월 8-14일)  
1. **빠른 응답 시스템** - 기존 SherpiContext 활용
2. **메시지 히스토리 확장** - 기존 SherpiMessageHistory 확장
3. **검색 및 필터링** - 새로운 검색 서비스 구축

### Week 3: 관계 & 보상 시스템 (2월 15-21일)
1. **친밀도 시각화** - 기존 SherpiRelationship 활용  
2. **보상 센터** - 새로운 보상 시스템 구축
3. **성취 추적** - 기존 활동 완료 흐름 연동

---

## 🎯 핵심 기능별 구현 전략

## 1. 개인화 설정 시스템

### 1.1 설정 모델 정의
```dart
// lib/features/sherpi_settings/models/sherpi_settings_model.dart
enum SherpiPersonality { energetic, calm, humorous, serious }
enum IntimacyDisplayMode { numeric, stars, hearts }
enum AILevel { minimal, balanced, maximum }

@freezed  
class SherpiSettings with _$SherpiSettings {
  const factory SherpiSettings({
    // 기본 설정
    @Default(SherpiPersonality.energetic) SherpiPersonality sherpiPersonality,
    @Default('친구') String userNickname,
    @Default(IntimacyDisplayMode.numeric) IntimacyDisplayMode intimacyDisplayMode,
    
    // 메시지 설정
    @Default(AILevel.balanced) AILevel aiLevel,
    @Default(1.0) double messageFrequency,
    @Default(2) int emojiLevel,
    
    // 알림 설정  
    @Default(true) bool morningGreeting,
    @Default(true) bool achievementNotification,
    @Default([22, 7]) List<int> quietHours,
    
    // 시스템 설정
    @Default(true) bool enableHapticFeedback,
    @Default(true) bool enableSoundEffects,
    @Default('ko') String preferredLanguage,
  }) = _SherpiSettings;
  
  factory SherpiSettings.fromJson(Map<String, dynamic> json) => _$SherpiSettingsFromJson(json);
}
```

### 1.2 설정 Provider 구현
```dart
// lib/features/sherpi_settings/providers/sherpi_settings_provider.dart
class SherpiSettingsNotifier extends StateNotifier<SherpiSettings> {
  final SharedPreferences _prefs;
  final Ref _ref;
  
  SherpiSettingsNotifier(this._ref, this._prefs) : super(SherpiSettings()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final json = _prefs.getString('sherpi_settings_v2');
    if (json != null) {
      try {
        final settings = SherpiSettings.fromJson(jsonDecode(json));
        state = settings;
        _applySherpiSettings(); // 기존 SherpiNotifier에 설정 적용
      } catch (e) {
        // 로딩 실패 시 기본값 유지
      }
    }
  }
  
  Future<void> updateSettings(SherpiSettings newSettings) async {
    state = newSettings;
    await _prefs.setString('sherpi_settings_v2', jsonEncode(state.toJson()));
    _applySherpiSettings();
  }
  
  void _applySherpiSettings() {
    // 🔗 기존 SherpiNotifier와 연동
    final sherpiNotifier = _ref.read(sherpiProvider.notifier);
    sherpiNotifier.applyUserSettings(state);
  }
}

final sherpiSettingsProvider = StateNotifierProvider<SherpiSettingsNotifier, SherpiSettings>((ref) {
  return SherpiSettingsNotifier(ref, ref.watch(sharedPreferencesProvider));
});
```

### 1.3 기존 SherpiNotifier 확장
```dart
// lib/shared/providers/global_sherpi_provider.dart에 추가
extension SherpiNotifierPhase2 on SherpiNotifier {
  void applyUserSettings(SherpiSettings settings) {
    // SmartSherpiManager에 개성 설정 적용
    if (_smartManager != null) {
      _smartManager!.updatePersonality(settings.sherpiPersonality);
      _smartManager!.setMessageFrequency(settings.messageFrequency);
      _smartManager!.setEmojiLevel(settings.emojiLevel);
    }
    
    // 메타데이터에 설정 정보 저장
    _currentMetadata['user_settings'] = {
      'personality': settings.sherpiPersonality.name,
      'nickname': settings.userNickname,
      'emoji_level': settings.emojiLevel,
    };
  }
}
```

## 2. 사용자 분석 시스템

### 2.1 분석 모델 정의
```dart
// lib/features/sherpi_analytics/models/user_analytics_model.dart
@freezed
class UserAnalytics with _$UserAnalytics {
  const factory UserAnalytics({
    // 기본 정보
    required String userName,
    required int totalDays,
    required int currentLevel,  
    required int totalXP,
    
    // 관계 정보 (🔗 기존 SherpiRelationship 활용)
    required int intimacyLevel,
    required String relationshipTitle,
    required int specialMomentsCount,
    required double emotionalSync,
    
    // 활동 분석 (🔗 기존 GlobalUser 데이터 활용)
    required ActivityDistribution activityDistribution,
    required List<GrowthDataPoint> growthTrend,
    required Map<int, double> activityPattern, // hour -> intensity
    
    // 인사이트
    required List<String> topAchievements,
    required List<Recommendation> personalizedRecommendations,
  }) = _UserAnalytics;
}
```

### 2.2 분석 Provider 구현
```dart
// lib/features/sherpi_analytics/providers/user_analytics_provider.dart  
class UserAnalyticsNotifier extends StateNotifier<UserAnalytics> {
  final Ref _ref;
  
  UserAnalyticsNotifier(this._ref) : super(_generateInitialAnalytics()) {
    _updateAnalytics();
  }
  
  void _updateAnalytics() {
    // 🔗 기존 프로바이더들에서 데이터 수집
    final user = _ref.read(globalUserProvider);
    final relationship = _ref.read(sherpiRelationshipProvider);
    
    state = UserAnalytics(
      // 기본 정보
      userName: user.name ?? '사용자',
      totalDays: user.dailyRecords.length,
      currentLevel: user.level,
      totalXP: user.totalExperience,
      
      // 관계 정보
      intimacyLevel: relationship.intimacyLevel,
      relationshipTitle: relationship.relationshipTitle,
      specialMomentsCount: relationship.specialMoments.length,
      emotionalSync: relationship.emotionalSync,
      
      // 활동 분석
      activityDistribution: _analyzeActivityDistribution(user.dailyRecords),
      growthTrend: _calculateGrowthTrend(user.dailyRecords),
      activityPattern: _analyzeActivityPattern(user.dailyRecords),
      
      // 인사이트 생성
      topAchievements: _extractTopAchievements(user),
      personalizedRecommendations: _generateRecommendations(user, relationship),
    );
  }
  
  String generateSherpiInsight(String section) {
    // 섹션별 셰르피 코멘트 생성
    switch (section) {
      case 'overview':
        return '${state.userName}님! 지금까지 ${state.totalDays}일 동안 정말 열심히 하셨네요! '
               '현재 ${state.currentLevel}레벨이시고, 저와의 친밀도는 ${state.intimacyLevel}단계예요! 🌟';
      case 'activity':
        final topActivity = _getTopActivity();
        return '${topActivity}를 가장 열심히 하고 계시네요! '
               '${state.emotionalSync > 0.7 ? '저와 정말 잘 맞는 것 같아요' : '조금 더 함께 해보아요'}! 😊';
      default:
        return '데이터를 분석하고 있어요...';
    }
  }
}
```

## 3. 빠른 응답 시스템

### 3.1 응답 모델 정의
```dart
// lib/features/quick_response/models/quick_response_model.dart
enum ResponseCategory { greeting, action, motivation, question, celebration }

@freezed
class QuickResponse with _$QuickResponse {
  const factory QuickResponse({
    required String id,
    required String text,
    required String emoji,
    required ResponseCategory category,
    required SherpiContext triggerContext,
    required SherpiEmotion recommendedEmotion,
    @Default(1.0) double priority,
    Map<String, dynamic>? metadata,
  }) = _QuickResponse;
}
```

### 3.2 응답 생성 Provider
```dart
// lib/features/quick_response/providers/quick_response_provider.dart
class QuickResponseNotifier extends StateNotifier<List<QuickResponse>> {
  final Ref _ref;
  
  QuickResponseNotifier(this._ref) : super([]);
  
  List<QuickResponse> getResponsesForContext(SherpiContext context) {
    final user = _ref.read(globalUserProvider);
    final settings = _ref.read(sherpiSettingsProvider);
    
    final baseResponses = _getBaseResponses(context);
    final personalizedResponses = _getPersonalizedResponses(context, user, settings);
    
    return [...baseResponses, ...personalizedResponses]
      ..sort((a, b) => b.priority.compareTo(a.priority))
      ..take(6).toList();
  }
  
  List<QuickResponse> _getBaseResponses(SherpiContext context) {
    // 🔗 기존 sherpiDialogues 데이터 활용
    final dialogues = sherpiDialogues[context] ?? [];
    
    return dialogues.take(3).map((dialogue) => QuickResponse(
      id: '${context.name}_${dialogue.hashCode}',
      text: dialogue,
      emoji: _getEmojiForContext(context),
      category: _getCategoryForContext(context),
      triggerContext: context,
      recommendedEmotion: SherpiDialogueUtils.getRecommendedEmotion(context),
    )).toList();
  }
  
  void handleQuickResponse(QuickResponse response) {
    // 🔗 기존 SherpiNotifier와 연동
    _ref.read(sherpiProvider.notifier).showInstantMessage(
      context: response.triggerContext,
      customDialogue: response.text,
      emotion: response.recommendedEmotion,
      forceShow: true,
    );
    
    // 사용 통계 기록
    _recordResponseUsage(response);
  }
}
```

## 4. 메시지 히스토리 확장

### 4.1 기존 모델 확장 (새 모델 생성 않음)
```dart
// lib/shared/models/sherpi_message_history.dart에 확장 추가
extension SherpiMessageHistoryPhase2 on SherpiMessageHistory {
  // 메타데이터 기반 새 속성들
  bool get isFavorite => metadata['isFavorite'] == true;
  bool get isMilestone => metadata['isMilestone'] == true;
  
  MessageCategory get category {
    // 🔗 기존 SherpiContext를 MessageCategory로 매핑
    switch (context) {
      case SherpiContext.levelUp:
      case SherpiContext.badgeEarned:
        return MessageCategory.achievement;
      case SherpiContext.exerciseComplete:
      case SherpiContext.studyComplete:
        return MessageCategory.activity;
      case SherpiContext.questComplete:
        return MessageCategory.quest;
      default:
        return MessageCategory.general;
    }
  }
  
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

### 4.2 메시지 검색 서비스
```dart
// lib/features/message_history/services/message_search_service.dart
class MessageSearchService {
  List<SherpiMessageHistory> searchMessages({
    required List<SherpiMessageHistory> messages,
    String? query,
    DateRange? dateRange,
    List<MessageCategory>? categories,
    bool? favoritesOnly,
  }) {
    var filtered = messages;
    
    // 텍스트 검색
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((message) {
        return message.message.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    
    // 날짜 필터
    if (dateRange != null) {
      filtered = filtered.where((message) {
        return message.timestamp.isAfter(dateRange.start) &&
               message.timestamp.isBefore(dateRange.end);
      }).toList();
    }
    
    // 카테고리 필터  
    if (categories != null && categories.isNotEmpty) {
      filtered = filtered.where((message) {
        return categories.contains(message.category);
      }).toList();
    }
    
    // 즐겨찾기 필터
    if (favoritesOnly == true) {
      filtered = filtered.where((m) => m.isFavorite).toList();
    }
    
    return filtered;
  }
}
```

## 5. 친밀도 시각화

### 5.1 기존 시스템 활용
```dart
// lib/features/intimacy/presentation/screens/intimacy_dashboard_screen.dart
class IntimacyDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔗 기존 SherpiRelationship 데이터 활용
    final relationship = ref.watch(sherpiRelationshipProvider);
    final settings = ref.watch(sherpiSettingsProvider);
    
    return Scaffold(
      body: Column(
        children: [
          _buildIntimacyHeader(relationship, settings.intimacyDisplayMode),
          _buildProgressSection(relationship),
          _buildSpecialMomentsCarousel(relationship.specialMoments),
          _buildRelationshipStats(relationship),
        ],
      ),
    );
  }
  
  Widget _buildIntimacyHeader(SherpiRelationship relationship, IntimacyDisplayMode displayMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 친밀도 레벨 표시 (설정에 따라)
          _buildIntimacyDisplay(relationship.intimacyLevel, displayMode),
          
          // 관계 타이틀
          Text(
            relationship.relationshipTitle,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // 진행률 바
          LinearProgressIndicator(
            value: relationship.progressToNextLevel,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(Colors.pink),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIntimacyDisplay(int level, IntimacyDisplayMode mode) {
    switch (mode) {
      case IntimacyDisplayMode.numeric:
        return Text('Lv.$level', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
      case IntimacyDisplayMode.stars:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(level, (index) => Icon(Icons.star, color: Colors.amber, size: 20)),
        );
      case IntimacyDisplayMode.hearts:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(level, (index) => Icon(Icons.favorite, color: Colors.red, size: 20)),
        );
    }
  }
}
```

## 6. 보상 센터

### 6.1 보상 모델 정의
```dart
// lib/features/rewards/models/reward_model.dart
enum RewardType { points, badge, title, sherpiEmotion, special }

@freezed
class Reward with _$Reward {
  const factory Reward({
    required String id,
    required String title,
    required String description,
    required RewardType type,
    required int value,
    required String iconPath,
    required DateTime earnedAt,
    required Map<String, dynamic> metadata,
  }) = _Reward;
}
```

### 6.2 보상 Provider 구현
```dart
// lib/features/rewards/providers/reward_provider.dart
class RewardNotifier extends StateNotifier<List<Reward>> {
  final Ref _ref;
  
  RewardNotifier(this._ref) : super([]) {
    _loadRewards();
  }
  
  void _loadRewards() {
    // 🔗 기존 활동 완료 데이터에서 보상 생성
    final user = _ref.read(globalUserProvider);
    final relationship = _ref.read(sherpiRelationshipProvider);
    
    final rewards = <Reward>[];
    
    // 레벨 달성 보상
    for (int level = 1; level <= user.level; level++) {
      rewards.add(Reward(
        id: 'level_$level',
        title: '레벨 $level 달성!',
        description: '$level 레벨에 도달했습니다',
        type: RewardType.badge,
        value: level * 100,
        iconPath: 'assets/images/badges/level_$level.png',
        earnedAt: _getLevelAchievementDate(level, user),
        metadata: {'level': level},
      ));
    }
    
    // 친밀도 보상
    for (int intimacy = 1; intimacy <= relationship.intimacyLevel; intimacy++) {
      rewards.add(Reward(
        id: 'intimacy_$intimacy',
        title: '셰르피와 친밀도 $intimacy단계!',
        description: '새로운 셰르피 표정이 해금되었습니다',
        type: RewardType.sherpiEmotion,
        value: intimacy * 50,
        iconPath: 'assets/images/sherpi/unlocked_${intimacy}.png',
        earnedAt: relationship.specialMoments.isEmpty 
          ? DateTime.now() 
          : relationship.specialMoments.last.timestamp,
        metadata: {'intimacy_level': intimacy},
      ));
    }
    
    state = rewards..sort((a, b) => b.earnedAt.compareTo(a.earnedAt));
  }
}
```

---

## 🔧 기존 시스템 통합 요점

### 1. SherpiNotifier 확장 메서드
기존 `global_sherpi_provider.dart`에 다음 확장 메서드들 추가:
- `applyUserSettings()` - 설정 적용
- `handleQuickResponse()` - 빠른 응답 처리  
- `toggleMessageFavorite()` - 메시지 즐겨찾기

### 2. GlobalUserNotifier 확장  
기존 `global_user_provider.dart`에 다음 확장 메서드 추가:
- `generateAnalytics()` - 분석 데이터 생성
- `recordRewardEarned()` - 보상 기록

### 3. 데이터 저장 패턴
- **설정**: `sherpi_settings_v2` 키로 SharedPreferences에 JSON 저장
- **즐겨찾기**: 기존 SherpiMessageHistory의 metadata 활용
- **보상**: `earned_rewards` 키로 List<Reward> JSON 저장

### 4. Provider 초기화
`main.dart`에서 다음 Provider들 추가:
```dart
// Phase 2 Provider들
ref.read(sherpiSettingsProvider);
ref.read(quickResponseProvider);
ref.read(userAnalyticsProvider);
ref.read(rewardProvider);
```

---

## 📊 구현 검증 체크리스트

### Week 1 검증
- [ ] 설정 변경이 즉시 셰르피 동작에 반영됨
- [ ] 분석 화면에서 실제 사용자 데이터 표시
- [ ] 다이얼로그에서 분석/설정 화면 정상 이동

### Week 2 검증  
- [ ] 빠른 응답이 컨텍스트에 맞게 생성됨
- [ ] 메시지 검색/필터링 정상 동작
- [ ] 즐겨찾기 토글 기능 동작

### Week 3 검증
- [ ] 친밀도 표시 모드가 설정에 따라 변경
- [ ] 보상이 실제 성취에 기반해 생성
- [ ] 모든 기능이 기존 앱 흐름과 조화

---

## 🚨 주의사항

### 성능 최적화
- 메시지 히스토리는 최대 1000개까지만 유지
- 분석 데이터는 백그라운드에서 계산
- 이미지 리소스는 필요할 때만 로드

### 안정성 보장
- 모든 새 Provider는 기존 Provider 초기화 후 실행
- SharedPreferences 키 충돌 방지를 위한 `phase2_` 접두사 사용
- 기존 데이터 마이그레이션 로직 포함

### 사용자 경험
- 모든 화면 전환은 부드러운 애니메이션 적용
- 로딩 상태 명확히 표시
- 오류 발생 시 사용자 친화적 메시지 표시

---

**💡 핵심 성공 요소**: 기존 시스템을 최대한 활용하여 70% 이상의 개발 효율성을 확보하면서도, 사용자에게는 완전히 새로운 경험을 제공하는 것입니다.

---

*문서 버전: v1.0*  
*최종 수정: 2025년 1월 27일*