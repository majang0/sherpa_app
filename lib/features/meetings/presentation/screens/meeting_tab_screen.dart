import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// 🎨 2025 디자인 시스템
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';

// 📱 화면들
import 'new_meeting_discovery_screen.dart';
import 'challenge_index_screen.dart';

// 🔧 프로바이더
import '../../../quests/providers/quest_provider_v2.dart';

/// 🎯 리디자인된 모임 탭 화면
/// 깔끔하고 모던한 블루/화이트 디자인
class MeetingTabScreen extends ConsumerStatefulWidget {
  final int? initialTabIndex;
  
  const MeetingTabScreen({
    super.key, 
    this.initialTabIndex,
  });
  
  @override
  ConsumerState<MeetingTabScreen> createState() => _MeetingTabScreenState();
}

class _MeetingTabScreenState extends ConsumerState<MeetingTabScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0; // 🎯 핵심 상태 변수 추가
  
  // 탭 정보
  static const List<TabInfo> _tabs = [
    TabInfo(
      icon: Icons.groups_rounded,
      selectedIcon: Icons.groups,
      label: '모임',
      color: AppColors2025.primary,
      semanticLabel: '모임 탭, 다른 사용자들과 만날 수 있는 모임을 찾아보세요',
    ),
    TabInfo(
      icon: Icons.emoji_events_outlined,
      selectedIcon: Icons.emoji_events,
      label: '챌린지',
      color: AppColors2025.primary,
      semanticLabel: '챌린지 탭, 재미있는 도전과 경쟁에 참여해보세요',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    
    _selectedIndex = _tabController.index; // 초기 인덱스 설정
    
    // 🔥 개선된 리스너 - setState로 확실한 UI 업데이트
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && 
          _tabController.index != _selectedIndex) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
        // 🎯 탭 방문 기록 (퀘스트 추적용) - 셰르피 메시지는 보상 수령 시에만
        _recordTabVisit(_selectedIndex);
        HapticFeedback.lightImpact();
      }
    });
    
    // 🎯 초기 탭 방문 기록 (퀘스트 추적용) - 셰르피 메시지는 보상 수령 시에만
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordTabVisit(_selectedIndex);
    });
  }
  
  /// 🎯 직접 탭 선택 핸들러
  void _selectTab(int index) {
    if (index != _selectedIndex && index >= 0 && index < _tabs.length) {
      HapticFeedback.lightImpact();
      _tabController.animateTo(index);
      setState(() {
        _selectedIndex = index;
      });
      // 🎯 탭 방문 기록 (퀘스트 추적용) - 셰르피 메시지는 보상 수령 시에만
      _recordTabVisit(index);
    }
  }
  
  /// 🎯 탭 방문 기록 (퀘스트 추적용) - 셰르피 메시지는 보상 수령 시에만
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
      backgroundColor: AppColors2025.background,
      
      // 🎯 SherpaCleanAppBar 사용
      appBar: const SherpaCleanAppBar(
        title: '모임',
        backgroundColor: AppColors2025.surface,
      ),
      
      // 🎨 클린 모던 탭바와 바디
      body: Column(
        children: [
          // 🏆 프리미엄 모던 탭 셀렉터
          Semantics(
            label: '모임 탭 선택기',
            hint: '좌우 스와이프 또는 탭을 눌러 다른 섹션으로 이동할 수 있습니다',
            child: _buildPremiumModernTabSelector(),
          ),
          
          // 탭 콘텐츠
          Expanded(
            child: Semantics(
              label: '${_tabs[_selectedIndex].label} 콘텐츠',
              liveRegion: true,
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  NewMeetingDiscoveryScreen(),
                  ChallengeIndexScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 심플하고 반응형인 탭 셀렉터
  Widget _buildPremiumModernTabSelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16, 
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            return Expanded(
              child: _buildSimpleTabItem(index),
            );
          }),
        ),
      ),
    );
  }

  /// 🎯 심플하고 깔끔한 탭 아이템
  Widget _buildSimpleTabItem(int index) {
    final tab = _tabs[index];
    final isSelected = index == _selectedIndex;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return GestureDetector(
      onTap: () => _selectTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 8 : 10,
          horizontal: 4,
        ),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors2025.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? tab.selectedIcon : tab.icon,
              size: isSmallScreen ? 18 : 20,
              color: isSelected ? Colors.white : AppColors2025.textTertiary,
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tab.label,
                style: GoogleFonts.notoSans(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors2025.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📊 탭 정보 모델
class TabInfo {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;
  final String semanticLabel;

  const TabInfo({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
    required this.semanticLabel,
  });
}