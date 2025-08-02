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
        _recordTabVisit(_selectedIndex);
        HapticFeedback.lightImpact();
      }
    });
    
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
      _recordTabVisit(index);
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

  /// 🏆 프리미엄 모던 탭 셀렉터 - 최고급 디자인
  Widget _buildPremiumModernTabSelector() {
    return RepaintBoundary(
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            // 메인 그림자 (depth)
            BoxShadow(
              color: Color(0x14000000), // Colors.black.withValues(alpha: 0.08)
              offset: Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
            // 앰비언트 그림자 (soft glow)
            BoxShadow(
              color: Color(0x0A000000), // Colors.black.withValues(alpha: 0.04)
              offset: Offset(0, 1),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              return Expanded(
                child: _buildPremiumTabItem(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// 💎 프리미엄 탭 아이템 - 세련된 상호작용과 애니메이션
  Widget _buildPremiumTabItem(int index) {
    final tab = _tabs[index];
    final isSelected = index == _selectedIndex; // 🎯 직접 상태 확인
    
    return RepaintBoundary(
      child: _PremiumTabItemWidget(
        tab: tab,
        index: index,
        isSelected: isSelected,
        onTap: () => _selectTab(index),
      ),
    );
  }
}

/// 🚀 독립적인 프리미엄 탭 아이템 위젯 - 완벽한 상호작용
class _PremiumTabItemWidget extends StatefulWidget {
  final TabInfo tab;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumTabItemWidget({
    required this.tab,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PremiumTabItemWidget> createState() => _PremiumTabItemWidgetState();
}

class _PremiumTabItemWidgetState extends State<_PremiumTabItemWidget>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.tab.semanticLabel,
      hint: widget.isSelected ? '현재 선택됨' : '탭하여 선택',
      selected: widget.isSelected,
      button: true,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _isHovered = hasFocus);
          if (hasFocus) {
            _hoverController.forward();
          } else {
            _hoverController.reverse();
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            setState(() => _isHovered = true);
            _hoverController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _hoverController.reverse();
          },
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: AnimatedBuilder(
              animation: Listenable.merge([_scaleAnimation, _hoverAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value * _hoverAnimation.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: _buildTabDecoration(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🎨 아이콘 with 매끄러운 전환
                        ExcludeSemantics(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              widget.isSelected ? widget.tab.selectedIcon : widget.tab.icon,
                              key: ValueKey('icon_${widget.index}_${widget.isSelected}'),
                              size: widget.isSelected ? 24 : 22,
                              color: _getIconColor(),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // ✨ 라벨 with 프리미엄 타이포그래피
                        ExcludeSemantics(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: _getTextColor(),
                              letterSpacing: 0.2,
                              height: 1.2,
                            ),
                            child: Text(
                              widget.tab.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 동적 데코레이션 생성
  BoxDecoration _buildTabDecoration() {
    if (widget.isSelected) {
      // 선택된 상태: 그라데이션 + 그림자
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors2025.primary,
            AppColors2025.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x592563EB), // AppColors2025.primary.withValues(alpha: 0.35)
            offset: Offset(0, 3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          // 내부 하이라이트
          BoxShadow(
            color: Color(0x33FFFFFF), // Colors.white.withValues(alpha: 0.2)
            offset: Offset(0, -1),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      );
    } else if (_isHovered && !widget.isSelected) {
      // 호버 상태: 연한 블루 배경
      return BoxDecoration(
        color: const Color(0x142563EB), // AppColors2025.primary.withValues(alpha: 0.08)
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0x262563EB), // AppColors2025.primary.withValues(alpha: 0.15)
          width: 1,
        ),
      );
    } else {
      // 기본 상태: 투명
      return BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      );
    }
  }

  /// 🎨 동적 아이콘 색상
  Color _getIconColor() {
    if (widget.isSelected) return Colors.white;
    if (_isHovered) return AppColors2025.primary;
    return AppColors2025.textTertiary;
  }

  /// 🎨 동적 텍스트 색상
  Color _getTextColor() {
    if (widget.isSelected) return Colors.white;
    if (_isHovered) return AppColors2025.primary;
    return AppColors2025.textTertiary;
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