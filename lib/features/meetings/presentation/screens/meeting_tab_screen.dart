import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'social_exploration_screen.dart';
import 'challenge_index_screen.dart';
import '../../../quests/providers/quest_provider_v2.dart';

/// 모임 탭 화면 - 모임과 챌린지를 탭으로 구분
class MeetingTabScreen extends ConsumerStatefulWidget {
  final int? initialTabIndex;
  
  const MeetingTabScreen({this.initialTabIndex});
  
  @override
  ConsumerState<MeetingTabScreen> createState() => _MeetingTabScreenState();
}

class _MeetingTabScreenState extends ConsumerState<MeetingTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    
    // 탭 변경 리스너 추가
    _tabController.addListener(_handleTabChange);
    
    // 초기 탭 방문 기록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordTabVisit(_tabController.index);
    });
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _recordTabVisit(_tabController.index);
    }
  }
  
  void _recordTabVisit(int index) {
    final tabNames = ['모임', '챌린지'];
    if (index >= 0 && index < tabNames.length) {
      ref.read(questProviderV2.notifier).recordTabVisit(tabNames[index]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모임'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.groups),
              text: '모임',
            ),
            Tab(
              icon: Icon(Icons.emoji_events),
              text: '챌린지',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SocialExplorationScreen(),
          ChallengeIndexScreen(),
        ],
      ),
    );
  }
}