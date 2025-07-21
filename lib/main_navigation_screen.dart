import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/climbing/presentation/screens/climbing_screen.dart'; // 분석 화면
import 'features/meetings/presentation/screens/meeting_tab_screen.dart'; // 모임 탭 화면
import 'features/profile/presentation/screens/profile_screen.dart';
import 'shared/widgets/sherpa_clean_app_bar.dart';
// 추가 imports for TabBarView screens
import 'features/quests/presentation/screens/quest_screen_v2.dart';
import 'features/daily_record/presentation/screens/enhanced_daily_record_screen.dart';
import 'features/meetings/presentation/screens/social_exploration_screen.dart';
import 'features/meetings/presentation/screens/challenge_index_screen.dart';
import 'features/quests/providers/quest_provider_v2.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;
  int? _pendingSubTabIndex; // 하위 탭 인덱스 전달을 위한 변수

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // arguments로 전달된 인덱스를 받아서 해당 탭으로 이동
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args >= 0 && args < 5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = args;
        });
      });
    } else if (args is Map<String, dynamic>) {
      // Map으로 전달된 경우 (탭 인덱스와 하위 탭 인덱스)
      final tabIndex = args['tabIndex'] as int?;
      final subTabIndex = args['subTabIndex'] as int?;
      
      if (tabIndex != null && tabIndex >= 0 && tabIndex < 5) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedIndex = tabIndex;
            // 하위 탭 인덱스도 전달해야 할 경우를 위해 저장
            if (subTabIndex != null) {
              _pendingSubTabIndex = subTabIndex;
            }
          });
        });
      }
    }
  }

  // 각 탭에 맞는 화면 위젯 반환
  Widget _getScreen(int index) {
    switch (index) {
      case 0: // 홈
        return HomeScreen();
      case 1: // 레벨업 (분석 탭만)
        return ClimbingScreen();
      case 2: // 퀘스트 (퀘스트/기록 탭)
        return QuestTabScreen(initialTabIndex: _pendingSubTabIndex);
      case 3: // 모임 (모임/챌린지 탭)
        return MeetingTabScreen();
      case 4: // 프로필
        return ProfileScreen();
      default:
        return HomeScreen();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // 탭 방문 기록 (퀘스트 추적용)
    final tabNames = ['홈', '레벨업', '퀘스트', '모임', '프로필'];
    if (index >= 0 && index < tabNames.length) {
      ref.read(questProviderV2.notifier).recordTabVisit(tabNames[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined), // 분석 아이콘
            activeIcon: Icon(Icons.analytics),
            label: '레벨업',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined), // 퀘스트 아이콘
            activeIcon: Icon(Icons.task_alt),
            label: '퀘스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined), // 모임 아이콘
            activeIcon: Icon(Icons.groups),
            label: '모임',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}

// 퀘스트 탭 화면 (퀘스트/기록)
class QuestTabScreen extends StatefulWidget {
  final int? initialTabIndex;
  
  const QuestTabScreen({Key? key, this.initialTabIndex}) : super(key: key);
  
  @override
  _QuestTabScreenState createState() => _QuestTabScreenState();
}

class _QuestTabScreenState extends State<QuestTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0, // 초기 탭 설정
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 46), // AppBar + TabBar 높이 조정
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SherpaCleanAppBar(title: '퀘스트'),
            Container(
              height: 46, // TabBar 높이 고정
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 0.5,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF4A90E2),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF4A90E2),
                indicatorWeight: 3,
                tabs: [
                  Tab(text: '퀘스트'),
                  Tab(text: '기록'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const QuestScreenV2(), // V2 퀘스트 화면
          EnhancedDailyRecordScreen(), // 기록 화면
        ],
      ),
    );
  }
}

// 모임 탭 화면 (모임/챌린지)
class MeetingTabScreen extends StatefulWidget {
  @override
  _MeetingTabScreenState createState() => _MeetingTabScreenState();
}

class _MeetingTabScreenState extends State<MeetingTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SherpaCleanAppBar(title: '모임'),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF4A90E2),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF4A90E2),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: '모임'),
                      Tab(text: '챌린지'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SocialExplorationScreen(), // 모임 화면
              ChallengeIndexScreen(), // 챌린지 화면
            ],
          ),
        ),
      ],
    );
  }
}
