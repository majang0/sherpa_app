# Phase 2: 사용자 경험 개선 (2025년 2월)

## 📋 Phase 2 개요

### 목표
사용자가 셰르피와의 상호작용을 더 직관적이고 즐겁게 느낄 수 있도록 UX를 개선합니다.

### 기간
2025년 2월 1일 - 2월 28일 (4주)

### 핵심 성과 지표
- 사용자 만족도: 4.0 → 4.5 이상
- 셰르피 상호작용률: 30% → 50% 증가
- 메시지 읽기율: 70% → 90% 향상
- 사용자 피드백 반영률: 100%

---

## 🎯 Week 1: 투명성 및 제어 기능 구현

### 1.1 AI 사용 표시기 개발
```dart
// lib/shared/widgets/ai_indicator_widget.dart
class AIIndicatorWidget extends StatelessWidget {
  final MessageSource source;
  final int responseTime;
  
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getIndicatorColor(source),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSourceIcon(source), size: 12),
          SizedBox(width: 4),
          Text(_getSourceLabel(source), style: TextStyle(fontSize: 10)),
          if (responseTime > 0) ...[
            SizedBox(width: 4),
            Text('${responseTime}ms', style: TextStyle(fontSize: 9)),
          ],
        ],
      ),
    );
  }
}
```

#### 구현 세부사항
- [ ] MessageSource enum 정의 (STATIC, CACHED_AI, REALTIME_AI)
- [ ] 각 소스별 아이콘 및 색상 정의
  - STATIC: ⚡ 파란색
  - CACHED_AI: 🚀 초록색
  - REALTIME_AI: 🤖 보라색
- [ ] 응답 시간 측정 및 표시
- [ ] 툴팁으로 상세 설명 제공

### 1.2 사용자 설정 패널 구현
```dart
// lib/features/settings/sherpi_settings_screen.dart
class SherpiSettingsScreen extends ConsumerStatefulWidget {
  @override
  _SherpiSettingsScreenState createState() => _SherpiSettingsScreenState();
}

class _SherpiSettingsScreenState extends ConsumerState<SherpiSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(sherpiSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('셰르피 설정')),
      body: ListView(
        children: [
          // AI 사용 레벨 설정
          ListTile(
            title: Text('AI 사용 수준'),
            subtitle: Text(_getAILevelDescription(settings.aiLevel)),
            trailing: DropdownButton<AILevel>(
              value: settings.aiLevel,
              onChanged: (value) => _updateAILevel(value!),
              items: AILevel.values.map((level) => 
                DropdownMenuItem(
                  value: level,
                  child: Text(_getAILevelLabel(level)),
                ),
              ).toList(),
            ),
          ),
          
          // 메시지 빈도 설정
          ListTile(
            title: Text('메시지 빈도'),
            subtitle: Slider(
              value: settings.messageFrequency,
              min: 0.1,
              max: 2.0,
              divisions: 19,
              label: '${(settings.messageFrequency * 100).round()}%',
              onChanged: (value) => _updateMessageFrequency(value),
            ),
          ),
          
          // 개인화 옵션
          SwitchListTile(
            title: Text('개인화된 메시지'),
            subtitle: Text('내 활동 패턴을 반영한 맞춤 메시지'),
            value: settings.enablePersonalization,
            onChanged: (value) => _updatePersonalization(value),
          ),
          
          // 이모지 사용 설정
          ListTile(
            title: Text('이모지 사용'),
            subtitle: Text('메시지에 포함될 이모지 개수'),
            trailing: SegmentedButton<int>(
              selected: {settings.emojiLevel},
              segments: [
                ButtonSegment(value: 0, label: Text('없음')),
                ButtonSegment(value: 1, label: Text('적게')),
                ButtonSegment(value: 2, label: Text('보통')),
                ButtonSegment(value: 3, label: Text('많이')),
              ],
              onSelectionChanged: (Set<int> selected) {
                _updateEmojiLevel(selected.first);
              },
            ),
          ),
          
          // 알림 설정
          ExpansionTile(
            title: Text('알림 설정'),
            children: [
              CheckboxListTile(
                title: Text('아침 인사'),
                value: settings.morningGreeting,
                onChanged: (value) => _updateNotification('morning', value!),
              ),
              CheckboxListTile(
                title: Text('운동 격려'),
                value: settings.exerciseReminder,
                onChanged: (value) => _updateNotification('exercise', value!),
              ),
              CheckboxListTile(
                title: Text('취침 인사'),
                value: settings.goodnightMessage,
                onChanged: (value) => _updateNotification('goodnight', value!),
              ),
            ],
          ),
          
          // 캐시 관리
          ListTile(
            title: Text('캐시 관리'),
            subtitle: Text('저장된 AI 메시지: ${settings.cachedMessageCount}개'),
            trailing: ElevatedButton(
              child: Text('캐시 정리'),
              onPressed: _clearCache,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 설정 항목 세부사항
- [ ] AI 사용 수준 (프리미엄/스마트/기본)
- [ ] 메시지 빈도 조절 (10% ~ 200%)
- [ ] 개인화 옵션 ON/OFF
- [ ] 이모지 사용 수준 (0~3)
- [ ] 알림 카테고리별 ON/OFF
- [ ] 캐시 수동 정리 기능

### 1.3 사용 통계 대시보드
```dart
// lib/features/settings/sherpi_stats_screen.dart
class SherpiStatsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(sherpiStatsProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('셰르피 통계')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 일별 상호작용 차트
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('일별 상호작용', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: stats.dailyInteractions.map((e) => 
                              FlSpot(e.day.toDouble(), e.count.toDouble())
                            ).toList(),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 메시지 소스 비율
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('메시지 유형 분포', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: stats.staticMessageCount.toDouble(),
                                title: '정적',
                                color: Colors.blue,
                              ),
                              PieChartSectionData(
                                value: stats.cachedAIMessageCount.toDouble(),
                                title: '캐시된 AI',
                                color: Colors.green,
                              ),
                              PieChartSectionData(
                                value: stats.realtimeAIMessageCount.toDouble(),
                                title: '실시간 AI',
                                color: Colors.purple,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 범례
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem('정적', Colors.blue, stats.staticMessageCount),
                          _buildLegendItem('캐시된 AI', Colors.green, stats.cachedAIMessageCount),
                          _buildLegendItem('실시간 AI', Colors.purple, stats.realtimeAIMessageCount),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 응답 시간 통계
          Card(
            child: ListTile(
              title: Text('평균 응답 시간'),
              subtitle: Text('정적: ${stats.avgStaticResponseTime}ms | AI: ${stats.avgAIResponseTime}ms'),
              trailing: Icon(Icons.speed),
            ),
          ),
          
          // 사용자 피드백
          Card(
            child: ListTile(
              title: Text('사용자 만족도'),
              subtitle: LinearProgressIndicator(
                value: stats.satisfactionRate,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  stats.satisfactionRate > 0.7 ? Colors.green : Colors.orange,
                ),
              ),
              trailing: Text('${(stats.satisfactionRate * 100).round()}%'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎨 Week 2: 상호작용 개선

### 2.1 빠른 응답 버튼 구현
```dart
// lib/shared/widgets/quick_response_buttons.dart
class QuickResponseButtons extends StatelessWidget {
  final List<QuickResponse> responses;
  final Function(String) onResponseSelected;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: responses.length,
        itemBuilder: (context, index) {
          final response = responses[index];
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(response.label),
              avatar: response.emoji != null ? Text(response.emoji!) : null,
              onPressed: () => onResponseSelected(response.action),
              backgroundColor: response.color,
            ),
          );
        },
      ),
    );
  }
}
```

#### 빠른 응답 시나리오
- [ ] 인사 응답: "안녕 셰르피!", "고마워!", "수고했어!"
- [ ] 감정 표현: "기뻐!", "힘들어", "화이팅!"
- [ ] 행동 요청: "조언 좀", "격려해줘", "같이 하자"

### 2.2 감정 표현 애니메이션 강화
```dart
// lib/shared/widgets/enhanced_sherpi_emotion.dart
class EnhancedSherpiEmotion extends StatefulWidget {
  final SherpiEmotion emotion;
  final bool isInteracting;
  
  @override
  _EnhancedSherpiEmotionState createState() => _EnhancedSherpiEmotionState();
}

class _EnhancedSherpiEmotionState extends State<EnhancedSherpiEmotion>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _blinkController;
  late AnimationController _interactionController;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    // 호흡 애니메이션 (계속 반복)
    _breathingController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // 눈 깜빡임 (랜덤 간격)
    _blinkController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _startRandomBlinking();
    
    // 상호작용 애니메이션
    _interactionController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }
  
  void _startRandomBlinking() {
    Future.delayed(Duration(seconds: Random().nextInt(5) + 2), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startRandomBlinking();
          });
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController,
        _blinkController,
        _interactionController,
      ]),
      builder: (context, child) {
        final breathingScale = 1.0 + (_breathingController.value * 0.05);
        final blinkScale = _blinkController.value > 0.5 ? 0.1 : 1.0;
        final interactionRotation = widget.isInteracting 
          ? sin(_interactionController.value * pi * 2) * 0.1 
          : 0.0;
        
        return Transform.scale(
          scale: breathingScale,
          child: Transform.rotate(
            angle: interactionRotation,
            child: Stack(
              children: [
                // 본체
                Image.asset(
                  'assets/images/sherpi/sherpi_${widget.emotion.name}.png',
                  width: 80,
                  height: 80,
                ),
                // 눈 깜빡임 오버레이
                if (widget.emotion != SherpiEmotion.sleeping)
                  Positioned(
                    top: 25,
                    left: 20,
                    right: 20,
                    child: Transform.scale(
                      scaleY: blinkScale,
                      child: Container(
                        height: 10,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                // 감정 파티클 효과
                if (widget.emotion == SherpiEmotion.happy)
                  _buildSparkleEffect(),
                if (widget.emotion == SherpiEmotion.cheering)
                  _buildConfettiEffect(),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### 2.3 대화 히스토리 뷰어
```dart
// lib/features/sherpi/chat_history_screen.dart
class ChatHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(sherpiChatHistoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('셰르피와의 대화'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, ref),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'export', child: Text('내보내기')),
              PopupMenuItem(value: 'clear', child: Text('전체 삭제')),
              PopupMenuItem(value: 'filter', child: Text('필터')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: history.messages.length,
        itemBuilder: (context, index) {
          final message = history.messages[index];
          final isUserMessage = message.sender == 'user';
          
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: isUserMessage 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
              children: [
                if (!isUserMessage) ...[
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/sherpi/avatar.png'),
                    radius: 20,
                  ),
                  SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUserMessage 
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            if (!isUserMessage && message.source != null) ...[
                              SizedBox(width: 8),
                              _buildSourceIndicator(message.source!),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isUserMessage) ...[
                  SizedBox(width: 8),
                  CircleAvatar(
                    child: Icon(Icons.person),
                    radius: 20,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## 🎮 Week 3: 게이미피케이션 강화

### 3.1 친밀도 시스템 시각화
```dart
// lib/features/sherpi/intimacy_level_widget.dart
class IntimacyLevelWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intimacy = ref.watch(sherpiIntimacyProvider);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  '셰르피와의 친밀도',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getLevelColor(intimacy.level),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Lv.${intimacy.level}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: intimacy.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(intimacy.level)),
              minHeight: 8,
            ),
            SizedBox(height: 8),
            Text(
              '${intimacy.currentExp} / ${intimacy.requiredExp} EXP',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              '해금된 기능',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: intimacy.unlockedFeatures.map((feature) =>
                Chip(
                  label: Text(feature.name),
                  avatar: Icon(feature.icon, size: 16),
                  backgroundColor: feature.unlocked 
                    ? Colors.green[100] 
                    : Colors.grey[200],
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3.2 보상 시스템
```dart
// lib/features/sherpi/reward_system.dart
class SherpiRewardSystem {
  static const Map<int, IntimacyReward> levelRewards = {
    2: IntimacyReward(
      level: 2,
      title: '친구가 되었어요!',
      description: '셰르피가 이름을 불러줍니다',
      feature: 'name_calling',
      bonusPoints: 100,
    ),
    3: IntimacyReward(
      level: 3,
      title: '든든한 동료',
      description: '개인화된 조언을 제공합니다',
      feature: 'personalized_advice',
      bonusPoints: 200,
    ),
    5: IntimacyReward(
      level: 5,
      title: '베스트 프렌드',
      description: '특별한 이모티콘과 애니메이션',
      feature: 'special_emotions',
      bonusPoints: 500,
    ),
    7: IntimacyReward(
      level: 7,
      title: '소울메이트',
      description: '숨겨진 대화 옵션 해금',
      feature: 'hidden_dialogues',
      bonusPoints: 1000,
    ),
    10: IntimacyReward(
      level: 10,
      title: '영원한 친구',
      description: '프리미엄 AI 기능 전체 해금',
      feature: 'premium_ai',
      bonusPoints: 2000,
    ),
  };
  
  static void checkLevelUp(int newLevel, WidgetRef ref) {
    if (levelRewards.containsKey(newLevel)) {
      final reward = levelRewards[newLevel]!;
      _showRewardDialog(reward, ref);
      _unlockFeature(reward.feature, ref);
      _awardBonusPoints(reward.bonusPoints, ref);
    }
  }
}
```

### 3.3 일일 미션 시스템
```dart
// lib/features/sherpi/daily_missions.dart
class SherpiDailyMissions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(sherpiMissionsProvider);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '오늘의 셰르피 미션',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Spacer(),
                Text(
                  '${missions.completedCount}/${missions.totalCount}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...missions.dailyMissions.map((mission) =>
              ListTile(
                leading: Checkbox(
                  value: mission.completed,
                  onChanged: null,
                  fillColor: MaterialStateProperty.all(
                    mission.completed ? Colors.green : Colors.grey,
                  ),
                ),
                title: Text(
                  mission.title,
                  style: TextStyle(
                    decoration: mission.completed 
                      ? TextDecoration.lineThrough 
                      : null,
                  ),
                ),
                subtitle: Text(mission.description),
                trailing: mission.completed 
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Text(
                      '+${mission.intimacyPoints} 친밀도',
                      style: TextStyle(color: Colors.orange),
                    ),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }
}
```

---

## 📱 Week 4: 통합 및 최적화

### 4.1 메인 화면 통합
```dart
// lib/features/home/presentation/widgets/sherpi_dashboard_card.dart
class SherpiDashboardCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sherpiState = ref.watch(sherpiProvider);
    final intimacy = ref.watch(sherpiIntimacyProvider);
    
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/sherpi_chat'),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // 셰르피 아바타
                  Hero(
                    tag: 'sherpi_avatar',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/sherpi/sherpi_${sherpiState.emotion.name}.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // 상태 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '셰르피',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Lv.${intimacy.level}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          sherpiState.lastMessage ?? '탭하여 대화하기',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 알림 뱃지
                  if (sherpiState.hasNewMessage)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              // 친밀도 바
              LinearProgressIndicator(
                value: intimacy.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 4.2 성능 모니터링
```dart
// lib/core/ai/performance_monitor.dart
class SherpiPerformanceMonitor {
  static final Map<String, List<int>> _responseTimes = {};
  static final Map<String, int> _errorCounts = {};
  
  static void recordResponseTime(String source, int milliseconds) {
    _responseTimes.putIfAbsent(source, () => []);
    _responseTimes[source]!.add(milliseconds);
    
    // 최대 100개만 유지
    if (_responseTimes[source]!.length > 100) {
      _responseTimes[source]!.removeAt(0);
    }
  }
  
  static void recordError(String source, String error) {
    _errorCounts[source] = (_errorCounts[source] ?? 0) + 1;
    
    // 에러 로깅
    debugPrint('Sherpi Error [$source]: $error');
  }
  
  static Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{};
    
    _responseTimes.forEach((source, times) {
      if (times.isNotEmpty) {
        stats['${source}_avg'] = times.reduce((a, b) => a + b) ~/ times.length;
        stats['${source}_min'] = times.reduce(min);
        stats['${source}_max'] = times.reduce(max);
      }
    });
    
    stats['error_counts'] = Map.from(_errorCounts);
    stats['cache_hit_rate'] = _calculateCacheHitRate();
    stats['ai_usage_rate'] = _calculateAIUsageRate();
    
    return stats;
  }
  
  static double _calculateCacheHitRate() {
    // 캐시 히트율 계산 로직
    return 0.85; // 예시 값
  }
  
  static double _calculateAIUsageRate() {
    // AI 사용률 계산 로직
    return 0.15; // 예시 값
  }
}
```

### 4.3 A/B 테스트 프레임워크
```dart
// lib/core/ai/ab_testing.dart
class SherpiABTesting {
  static const Map<String, ABTest> activeTests = {
    'emoji_level': ABTest(
      name: 'emoji_level',
      variants: ['none', 'minimal', 'moderate', 'rich'],
      weights: [0.25, 0.25, 0.25, 0.25],
    ),
    'ai_threshold': ABTest(
      name: 'ai_threshold',
      variants: ['conservative', 'balanced', 'aggressive'],
      weights: [0.33, 0.34, 0.33],
    ),
    'response_delay': ABTest(
      name: 'response_delay',
      variants: ['instant', '500ms', '1000ms'],
      weights: [0.33, 0.34, 0.33],
    ),
  };
  
  static String getVariant(String testName, String userId) {
    if (!activeTests.containsKey(testName)) {
      return 'control';
    }
    
    final test = activeTests[testName]!;
    final hash = userId.hashCode + testName.hashCode;
    final random = Random(hash);
    final roll = random.nextDouble();
    
    double cumulative = 0;
    for (int i = 0; i < test.variants.length; i++) {
      cumulative += test.weights[i];
      if (roll < cumulative) {
        return test.variants[i];
      }
    }
    
    return test.variants.last;
  }
  
  static void recordEvent(String testName, String variant, String event, [dynamic value]) {
    // 이벤트 기록 로직
    final eventData = {
      'test': testName,
      'variant': variant,
      'event': event,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // SharedPreferences나 Firebase Analytics로 전송
    _sendToAnalytics(eventData);
  }
}
```

---

## 📊 Phase 2 성공 지표

### 정량적 지표
| 지표 | 현재 | 목표 | 측정 방법 |
|------|------|------|-----------|
| 사용자 만족도 | 4.0 | 4.5+ | 인앱 평가 |
| 셰르피 상호작용률 | 30% | 50% | 일일 활성 사용자 중 셰르피와 상호작용한 비율 |
| 메시지 읽기율 | 70% | 90% | 표시된 메시지 중 3초 이상 화면에 머문 비율 |
| 평균 친밀도 레벨 | 2.5 | 4.0 | 전체 사용자 평균 |
| 설정 사용률 | - | 60% | 설정을 한 번 이상 변경한 사용자 비율 |

### 정성적 지표
- 사용자가 셰르피를 "친구"로 인식하는지 여부
- 셰르피 메시지가 도움이 되는지에 대한 피드백
- AI vs 정적 메시지 선호도 조사
- 개인화 수준에 대한 만족도

---

## 🚨 리스크 및 대응 방안

### 기술적 리스크
1. **UX 변경으로 인한 기존 사용자 혼란**
   - 대응: 단계적 롤아웃, 튜토리얼 제공
   
2. **성능 저하**
   - 대응: 프로파일링 도구 활용, 점진적 최적화

3. **A/B 테스트 복잡도 증가**
   - 대응: 명확한 테스트 프로토콜, 자동화된 분석

### 사용자 경험 리스크
1. **너무 많은 설정 옵션**
   - 대응: 기본값 최적화, 프리셋 제공
   
2. **친밀도 시스템 밸런싱**
   - 대응: 베타 테스트, 빠른 패치 체계

---

## ✅ Phase 2 체크리스트

### Week 1 완료 기준
- [ ] AI 사용 표시기 구현 및 배포
- [ ] 사용자 설정 패널 완성
- [ ] 사용 통계 대시보드 구현
- [ ] 설정 데이터 저장/로드 로직

### Week 2 완료 기준
- [ ] 빠른 응답 버튼 시스템
- [ ] 감정 애니메이션 10종 완성
- [ ] 대화 히스토리 뷰어 구현
- [ ] 검색 및 필터 기능

### Week 3 완료 기준
- [ ] 친밀도 시스템 UI 완성
- [ ] 레벨별 보상 구현
- [ ] 일일 미션 시스템 구현
- [ ] 게이미피케이션 밸런싱

### Week 4 완료 기준
- [ ] 메인 화면 통합 완료
- [ ] 성능 모니터링 대시보드
- [ ] A/B 테스트 실행
- [ ] Phase 2 전체 QA 완료

---

## 📅 다음 단계

Phase 2 완료 후 Phase 3 (고급 기능 구현)로 진행:
- 음성 인터랙션
- 프리미엄 구독 모델
- 소셜 기능 통합
- 장기 패턴 분석 및 예측