import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/shared/providers/global_sherpi_provider.dart';
import 'package:sherpa_app/shared/providers/global_user_provider.dart';
import 'package:sherpa_app/shared/providers/global_point_provider.dart';
import 'package:sherpa_app/features/quests/providers/quest_provider_v2.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/constants/sherpi_emotions.dart';

/// 🧪 AI 개선 테스트 위젯
class AITestWidget extends ConsumerStatefulWidget {
  const AITestWidget({super.key});

  @override
  ConsumerState<AITestWidget> createState() => _AITestWidgetState();
}

class _AITestWidgetState extends ConsumerState<AITestWidget> {
  String _testLog = '';
  bool _isPersonalizedMode = true;
  
  void _addLog(String message) {
    setState(() {
      _testLog = '${DateTime.now().toIso8601String()}: $message\n$_testLog';
    });
  }
  
  /// Phase 1-3 기능 테스트 (실제 데이터 사용)
  Future<void> _testPhase3Features() async {
    _addLog('🧪 Phase 3 기능 테스트 시작... (실제 사용자 데이터 사용)');
    
    // 운동 완료 시나리오 - 실제 데이터는 자동으로 연결됨
    _addLog('📱 운동 완료 시나리오 테스트');
    await ref.read(sherpiProvider.notifier).showMessage(
      context: SherpiContext.exerciseComplete,
      userContext: {
        'exerciseType': '런닝',
        'duration': 30,
        'caloriesBurned': 250,
        // 실제 사용자의 연속 기록, 레벨, XP 등이 자동으로 추가됨
      },
      // gameContext는 자동으로 실제 게임 데이터가 사용됨
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    // 퀘스트 완료 시나리오
    _addLog('🎯 퀘스트 완료 시나리오 테스트');
    await ref.read(sherpiProvider.notifier).showMessage(
      context: SherpiContext.questComplete,
      userContext: {
        'questName': '일주일 운동 챌린지',
        'rewardPoints': 500,
        'questDifficulty': 'hard',
        // 실제 사용자의 퀘스트 완료 기록이 자동으로 추가됨
      },
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    // 레벨업 시나리오
    _addLog('⬆️ 레벨업 시나리오 테스트');
    await ref.read(sherpiProvider.notifier).showMessage(
      context: SherpiContext.levelUp,
      // 실제 사용자의 레벨과 XP가 자동으로 사용됨
    );
    
    _addLog('✅ Phase 3 기능 테스트 완료!');
  }
  
  /// 행동 패턴 분석 테스트
  Future<void> _testBehaviorAnalysis() async {
    _addLog('🔍 행동 패턴 분석 테스트 시작...');
    
    // 아침 활동 패턴
    _addLog('🌅 아침 활동 패턴 시뮬레이션');
    final morningHour = 7;
    await ref.read(sherpiProvider.notifier).showMessage(
      context: SherpiContext.encouragement,
      userContext: {
        'currentHour': morningHour,
        'recentActivityTimes': [7, 7, 8, 7, 6],
        'successRate': 0.85,
      },
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    // 저녁 피로 패턴
    _addLog('🌙 저녁 피로 패턴 시뮬레이션');
    await ref.read(sherpiProvider.notifier).showMessage(
      context: SherpiContext.tiredWarning,
      userContext: {
        'currentHour': 22,
        'todayActivityCount': 3,
        'energyLevel': 'low',
        'stressLevel': 'high',
      },
    );
    
    _addLog('✅ 행동 패턴 분석 테스트 완료!');
  }
  
  /// 응답 학습 시스템 테스트
  Future<void> _testResponseLearning() async {
    _addLog('🧠 응답 학습 시스템 테스트 시작...');
    
    // 다양한 반응 시뮬레이션
    final contexts = [
      SherpiContext.welcome,
      SherpiContext.exerciseComplete,
      SherpiContext.questComplete,
    ];
    
    for (final context in contexts) {
      _addLog('📝 ${context.name} 컨텍스트 테스트');
      
      // 메시지 표시
      await ref.read(sherpiProvider.notifier).showMessage(
        context: context,
        userContext: {
          'testMode': true,
          'iteration': contexts.indexOf(context),
        },
      );
      
      // 피드백 시뮬레이션 (실제로는 사용자 반응에 따라)
      // 여기서는 자동으로 긍정적 피드백 가정
      _addLog('👍 긍정적 피드백 기록');
      
      await Future.delayed(const Duration(seconds: 1));
    }
    
    _addLog('✅ 응답 학습 시스템 테스트 완료!');
  }
  
  @override
  Widget build(BuildContext context) {
    // 실제 사용자 데이터 가져오기
    final user = ref.watch(globalUserProvider);
    final points = ref.watch(globalPointProvider);
    final quests = ref.watch(questProviderV2);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'AI 개선 테스트 패널',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _isPersonalizedMode,
                  onChanged: (value) {
                    setState(() {
                      _isPersonalizedMode = value;
                    });
                    _addLog(value ? '🧠 개인화 모드 ON' : '📱 기본 모드 ON');
                  },
                ),
              ],
            ),
            const Divider(),
            
            // 테스트 버튼들
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _testPhase3Features,
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Phase 3 테스트'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _testBehaviorAnalysis,
                  icon: const Icon(Icons.analytics),
                  label: const Text('행동 분석'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _testResponseLearning,
                  icon: const Icon(Icons.school),
                  label: const Text('학습 시스템'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                // 개별 컨텍스트 테스트
                PopupMenuButton<SherpiContext>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu, color: Colors.white, size: 20),
                        SizedBox(width: 4),
                        Text('컨텍스트 테스트', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => SherpiContext.values.map((context) {
                    return PopupMenuItem(
                      value: context,
                      child: Text(context.name),
                    );
                  }).toList(),
                  onSelected: (context) async {
                    _addLog('🎯 ${context.name} 테스트');
                    await ref.read(sherpiProvider.notifier).showMessage(
                      context: context,
                      userContext: {
                        'testMode': true,
                        'timestamp': DateTime.now().toIso8601String(),
                      },
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 로그 표시
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _testLog.isEmpty ? '테스트 로그가 여기에 표시됩니다...' : _testLog,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 실제 사용자 데이터 표시
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 실제 사용자 데이터',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '레벨: ${user.level} | XP: ${user.experience.toInt()} | 포인트: ${points.totalPoints}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '연속 ${user.dailyRecords.consecutiveDays}일 | 운동 ${user.dailyRecords.exerciseLogs.length}회 | 독서 ${user.dailyRecords.readingLogs.length}권',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '퀘스트 데이터 로딩 중...',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 상태 표시
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isPersonalizedMode ? Colors.purple : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isPersonalizedMode ? '개인화 AI 활성' : '기본 AI',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '실제 데이터 연결됨',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _testLog = '';
                    });
                  },
                  child: const Text('로그 지우기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}