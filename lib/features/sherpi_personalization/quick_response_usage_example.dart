import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/global_sherpi_provider.dart';
import '../../shared/models/sherpi_relationship_model.dart';
import '../../shared/widgets/sherpi_quick_response_widget.dart';
import '../../core/constants/sherpi_dialogues.dart';
import '../../core/constants/sherpi_emotions.dart';
import '../../features/sherpi_relationship/providers/relationship_provider.dart';

/// Week 2: 빠른 응답 시스템 사용 예시
/// 
/// 이 파일은 빠른 응답 시스템의 모든 기능을 테스트하고
/// 데모할 수 있는 예시 화면입니다.
class QuickResponseUsageExample extends ConsumerStatefulWidget {
  const QuickResponseUsageExample({super.key});

  @override
  ConsumerState<QuickResponseUsageExample> createState() => _QuickResponseUsageExampleState();
}

class _QuickResponseUsageExampleState extends ConsumerState<QuickResponseUsageExample> {
  String _lastSelectedResponse = '';
  String _sherpiReaction = '';
  
  @override
  Widget build(BuildContext context) {
    final sherpiState = ref.watch(sherpiProvider);
    final relationshipSettings = ref.watch(relationshipProvider);
    final personalization = relationshipSettings.personalizationSettings;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Week 2: 빠른 응답 시스템'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 현재 설정 표시
                _buildSettingsCard(personalization),
                const SizedBox(height: 20),
                
                // 시나리오 테스트 섹션
                _buildScenarioSection(),
                const SizedBox(height: 20),
                
                // 현재 상태 표시
                _buildStatusCard(sherpiState),
                const SizedBox(height: 20),
                
                // 마지막 상호작용 표시
                if (_lastSelectedResponse.isNotEmpty)
                  _buildInteractionCard(),
                
                const SizedBox(height: 100), // 빠른 응답 위젯 공간
              ],
            ),
          ),
          
          // 빠른 응답 위젯 (화면 하단)
          if (sherpiState.showQuickResponseOptions)
            const Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: SherpiQuickResponseWidget(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsCard(PersonalizationSettings personalization) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '현재 개인화 설정',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow('사용자 호칭', personalization.userNickname),
            _buildInfoRow('셰르피 호칭', personalization.sherpiNickname),
            _buildInfoRow('성격 유형', personalization.personalityType.koreanName),
            _buildInfoRow('메시지 빈도', personalization.messageFrequency.displayName),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScenarioSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.play_circle_outline, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  '시나리오 테스트',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            const Text(
              '다양한 상황에서 빠른 응답 시스템을 테스트해보세요.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildScenarioButton(
                  '환영 메시지',
                  SherpiContext.welcome,
                  Colors.blue,
                  '안녕하세요! 오늘도 함께 성장해요! 🌟',
                ),
                _buildScenarioButton(
                  '운동 완료',
                  SherpiContext.exerciseComplete,
                  Colors.orange,
                  '운동 완료! 정말 대단해요! 💪',
                ),
                _buildScenarioButton(
                  '레벨업',
                  SherpiContext.levelUp,
                  Colors.purple,
                  '축하해요! 레벨업 했어요! 🎉',
                ),
                _buildScenarioButton(
                  '격려',
                  SherpiContext.encouragement,
                  Colors.pink,
                  '조금만 더 힘내세요! 할 수 있어요! 💖',
                ),
                _buildScenarioButton(
                  '학습 완료',
                  SherpiContext.studyComplete,
                  Colors.green,
                  '학습 완료! 지식이 늘었어요! 📚',
                ),
                _buildScenarioButton(
                  '일반 대화',
                  SherpiContext.general,
                  Colors.grey,
                  '오늘 하루는 어떠셨나요? 😊',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScenarioButton(
    String label,
    SherpiContext context,
    Color color,
    String message,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _triggerScenario(context, message),
      icon: Icon(Icons.message, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }
  
  void _triggerScenario(SherpiContext context, String message) {
    // 셰르피 메시지 표시
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: context,
      customDialogue: message,
      emotion: _getEmotionForContext(context),
    );
    
    // 상태 초기화
    setState(() {
      _lastSelectedResponse = '';
      _sherpiReaction = '';
    });
  }
  
  SherpiEmotion _getEmotionForContext(SherpiContext context) {
    switch (context) {
      case SherpiContext.welcome:
        return SherpiEmotion.happy;
      case SherpiContext.exerciseComplete:
        return SherpiEmotion.cheering;
      case SherpiContext.levelUp:
        return SherpiEmotion.special;
      case SherpiContext.encouragement:
        return SherpiEmotion.cheering;
      case SherpiContext.studyComplete:
        return SherpiEmotion.happy;
      default:
        return SherpiEmotion.defaults;
    }
  }
  
  Widget _buildStatusCard(SherpiState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: state.showQuickResponseOptions ? Colors.green.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: state.showQuickResponseOptions ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                const Text(
                  '시스템 상태',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow(
              '빠른 응답 표시',
              state.showQuickResponseOptions ? '활성화 ✅' : '비활성화 ❌',
            ),
            if (state.showQuickResponseOptions)
              _buildInfoRow(
                '응답 옵션 수',
                '${state.quickResponseOptions.length}개',
              ),
            _buildInfoRow(
              '현재 메시지',
              state.dialogue.length > 30 
                ? '${state.dialogue.substring(0, 30)}...'
                : state.dialogue,
            ),
            _buildInfoRow(
              '현재 감정',
              state.emotion.name,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInteractionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  '마지막 상호작용',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow('선택한 응답', _lastSelectedResponse),
            if (_sherpiReaction.isNotEmpty)
              _buildInfoRow('셰르피 반응', _sherpiReaction),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    
    // 빠른 응답 선택 리스너 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(sherpiProvider, (previous, next) {
        // 빠른 응답이 선택되었을 때의 처리
        if (previous?.quickResponseOptions.isNotEmpty == true &&
            next.quickResponseOptions.isEmpty &&
            !next.showQuickResponseOptions) {
          // 마지막 선택한 응답 추적 (실제 구현에서는 선택 이벤트를 통해 처리)
          setState(() {
            _lastSelectedResponse = '(빠른 응답이 선택되었습니다)';
            _sherpiReaction = next.dialogue;
          });
        }
      });
    });
  }
}

// 사용 예시를 위한 메인 화면
class QuickResponseDemoScreen extends StatelessWidget {
  const QuickResponseDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 2 - Week 2 Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuickResponseUsageExample(),
              ),
            );
          },
          child: const Text('빠른 응답 시스템 테스트'),
        ),
      ),
    );
  }
}