// lib/shared/widgets/components/molecules/sherpa_tab_bar_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 탭바 컴포넌트
/// 글래스모피즘, 유연한 인터랙션, 다양한 스타일을 지원
class SherpaTabBar2025 extends StatefulWidget {
  final List<SherpaTabItem2025> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final SherpaTabBarVariant2025 variant;
  final SherpaTabBarPosition position;
  final bool showLabels;
  final bool showBadges;
  final Color? backgroundColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final GlassNeuElevation elevation;
  final String? category;
  final Color? customColor;
  final bool isScrollable;
  final TabController? controller;

  const SherpaTabBar2025({
    Key? key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.variant = SherpaTabBarVariant2025.glass,
    this.position = SherpaTabBarPosition.bottom,
    this.showLabels = true,
    this.showBadges = true,
    this.backgroundColor,
    this.height,
    this.padding,
    this.margin,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.elevation = GlassNeuElevation.medium,
    this.category,
    this.customColor,
    this.isScrollable = false,
    this.controller,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 하단 네비게이션 바 (기본)
  factory SherpaTabBar2025.bottomNavigation({
    Key? key,
    required List<SherpaTabItem2025> items,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    String? category,
    bool showLabels = true,
  }) {
    return SherpaTabBar2025(
      key: key,
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      category: category,
      variant: SherpaTabBarVariant2025.glass,
      position: SherpaTabBarPosition.bottom,
      showLabels: showLabels,
      height: 70,
    );
  }

  /// 상단 탭바 (스크롤 가능)
  factory SherpaTabBar2025.topTabs({
    Key? key,
    required List<SherpaTabItem2025> items,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    TabController? controller,
    String? category,
    bool isScrollable = true,
  }) {
    return SherpaTabBar2025(
      key: key,
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      controller: controller,
      category: category,
      variant: SherpaTabBarVariant2025.neu,
      position: SherpaTabBarPosition.top,
      showLabels: false,
      isScrollable: isScrollable,
      height: 48,
    );
  }

  /// 플로팅 탭바 (독립적)
  factory SherpaTabBar2025.floating({
    Key? key,
    required List<SherpaTabItem2025> items,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    String? category,
    double? height,
  }) {
    return SherpaTabBar2025(
      key: key,
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      category: category,
      variant: SherpaTabBarVariant2025.floating,
      position: SherpaTabBarPosition.floating,
      height: height ?? 60,
      elevation: GlassNeuElevation.high,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 세그먼트 컨트롤 스타일
  factory SherpaTabBar2025.segmented({
    Key? key,
    required List<SherpaTabItem2025> items,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    String? category,
  }) {
    return SherpaTabBar2025(
      key: key,
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      category: category,
      variant: SherpaTabBarVariant2025.segmented,
      position: SherpaTabBarPosition.inline,
      showLabels: false,
      height: 40,
    );
  }

  @override
  State<SherpaTabBar2025> createState() => _SherpaTabBar2025State();
}

class _SherpaTabBar2025State extends State<SherpaTabBar2025>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );
    
    _indicatorController = AnimationController(
      duration: MicroInteractions.medium,
      vsync: this,
    );
    
    _indicatorAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: MicroInteractions.easeOutQuart,
    ));
    
    _previousIndex = widget.currentIndex;
    _indicatorController.forward();
  }

  @override
  void didUpdateWidget(SherpaTabBar2025 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _indicatorController.reset();
      _indicatorController.forward();
    }
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;
    
    widget.onTap?.call(index);
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getTabBarConfiguration();
    
    Widget tabBar = Container(
      height: widget.height ?? config.height,
      margin: widget.margin,
      decoration: _getDecoration(config),
      child: _buildTabContent(config),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      tabBar = MicroInteractions.slideInFade(
        child: tabBar,
        direction: widget.position == SherpaTabBarPosition.bottom
            ? SlideDirection.bottom
            : SlideDirection.top,
      );
    }

    return tabBar;
  }

  Widget _buildTabContent(TabBarConfiguration config) {
    if (widget.isScrollable) {
      return _buildScrollableTabs(config);
    } else {
      return _buildFixedTabs(config);
    }
  }

  Widget _buildFixedTabs(TabBarConfiguration config) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: Row(
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Expanded(
            child: _buildTabItem(item, index, config),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScrollableTabs(TabBarConfiguration config) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: widget.padding ?? const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: Row(
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            constraints: const BoxConstraints(minWidth: 80),
            child: _buildTabItem(item, index, config),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabItem(SherpaTabItem2025 item, int index, TabBarConfiguration config) {
    final isSelected = index == widget.currentIndex;
    final isEnabled = item.enabled;
    
    Widget tabItem = GestureDetector(
      onTap: isEnabled ? () => _handleTap(index) : null,
      child: AnimatedContainer(
        duration: MicroInteractions.fast,
        decoration: _getTabItemDecoration(isSelected, config),
        padding: _getTabItemPadding(config),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabIcon(item, isSelected, config),
            if (widget.showLabels && item.label != null) ...[
              const SizedBox(height: 4),
              _buildTabLabel(item, isSelected, config),
            ],
            if (isSelected && widget.variant == SherpaTabBarVariant2025.segmented)
              _buildActiveIndicator(config),
          ],
        ),
      ),
    );

    // 뱃지 추가
    if (widget.showBadges && item.badge != null) {
      tabItem = Stack(
        children: [
          tabItem,
          Positioned(
            top: 4,
            right: widget.showLabels ? 8 : 12,
            child: _buildBadge(item.badge!, config),
          ),
        ],
      );
    }

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions && isEnabled) {
      tabItem = MicroInteractions.tapResponse(
        scaleDownTo: 0.95,
        child: tabItem,
      );
    }

    return tabItem;
  }

  Widget _buildTabIcon(SherpaTabItem2025 item, bool isSelected, TabBarConfiguration config) {
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;
    
    return AnimatedContainer(
      duration: MicroInteractions.fast,
      child: IconTheme(
        data: IconThemeData(
          color: isSelected
              ? config.activeColor
              : (item.enabled
                  ? config.inactiveColor
                  : AppColors2025.textDisabled),
          size: config.iconSize,
        ),
        child: icon,
      ),
    );
  }

  Widget _buildTabLabel(SherpaTabItem2025 item, bool isSelected, TabBarConfiguration config) {
    return AnimatedDefaultTextStyle(
      duration: MicroInteractions.fast,
      style: GoogleFonts.notoSans(
        fontSize: config.labelSize,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected
            ? config.activeColor
            : (item.enabled
                ? config.inactiveColor
                : AppColors2025.textDisabled),
        height: 1.0,
      ),
      child: Text(
        item.label!,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActiveIndicator(TabBarConfiguration config) {
    return AnimatedBuilder(
      animation: _indicatorAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(top: 4),
          height: 2,
          width: 20 * _indicatorAnimation.value,
          decoration: BoxDecoration(
            color: config.activeColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
    );
  }

  Widget _buildBadge(SherpaTabBadge2025 badge, TabBarConfiguration config) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badge.color ?? AppColors2025.error,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors2025.surface,
          width: 1,
        ),
      ),
      child: Text(
        badge.text,
        style: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors2025.textOnPrimary,
          height: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TabBarConfiguration _getTabBarConfiguration() {
    final color = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    switch (widget.position) {
      case SherpaTabBarPosition.bottom:
        return TabBarConfiguration(
          height: 70,
          iconSize: 24,
          labelSize: 12,
          activeColor: color,
          inactiveColor: AppColors2025.textTertiary,
          backgroundColor: AppColors2025.surface,
        );
      case SherpaTabBarPosition.top:
        return TabBarConfiguration(
          height: 48,
          iconSize: 20,
          labelSize: 14,
          activeColor: color,
          inactiveColor: AppColors2025.textSecondary,
          backgroundColor: AppColors2025.surface,
        );
      case SherpaTabBarPosition.floating:
        return TabBarConfiguration(
          height: 60,
          iconSize: 22,
          labelSize: 12,
          activeColor: color,
          inactiveColor: AppColors2025.textTertiary,
          backgroundColor: AppColors2025.surface,
        );
      case SherpaTabBarPosition.inline:
        return TabBarConfiguration(
          height: 40,
          iconSize: 18,
          labelSize: 13,
          activeColor: AppColors2025.textOnPrimary,
          inactiveColor: AppColors2025.textSecondary,
          backgroundColor: AppColors2025.surface,
        );
    }
  }

  BoxDecoration _getDecoration(TabBarConfiguration config) {
    switch (widget.variant) {
      case SherpaTabBarVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: widget.elevation,
          color: config.activeColor,
          borderRadius: _getBorderRadius(),
          opacity: 0.95,
        );

      case SherpaTabBarVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: widget.elevation,
          baseColor: widget.backgroundColor ?? config.backgroundColor,
          borderRadius: _getBorderRadius(),
        );

      case SherpaTabBarVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.activeColor,
          borderRadius: _getBorderRadius(),
          elevation: 16,
        );

      case SherpaTabBarVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: config.activeColor,
          borderRadius: _getBorderRadius(),
          glassOpacity: 0.15,
        );

      case SherpaTabBarVariant2025.segmented:
        return BoxDecoration(
          color: AppColors2025.neuBase,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color: AppColors2025.border,
            width: 1,
          ),
        );

      case SherpaTabBarVariant2025.minimal:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
        );
    }
  }

  BoxDecoration? _getTabItemDecoration(bool isSelected, TabBarConfiguration config) {
    if (widget.variant == SherpaTabBarVariant2025.segmented && isSelected) {
      return BoxDecoration(
        color: config.activeColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        boxShadow: [
          BoxShadow(
            color: AppColors2025.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
    return null;
  }

  EdgeInsetsGeometry _getTabItemPadding(TabBarConfiguration config) {
    switch (widget.position) {
      case SherpaTabBarPosition.bottom:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
      case SherpaTabBarPosition.top:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case SherpaTabBarPosition.floating:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case SherpaTabBarPosition.inline:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  double _getBorderRadius() {
    switch (widget.position) {
      case SherpaTabBarPosition.bottom:
        return AppSizes.radiusL;
      case SherpaTabBarPosition.top:
        return AppSizes.radiusM;
      case SherpaTabBarPosition.floating:
        return AppSizes.radiusXL;
      case SherpaTabBarPosition.inline:
        return AppSizes.radiusM;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }
}

// ==================== 모델 클래스들 ====================

class SherpaTabItem2025 {
  final Widget icon;
  final Widget? activeIcon;
  final String? label;
  final String? tooltip;
  final SherpaTabBadge2025? badge;
  final bool enabled;

  const SherpaTabItem2025({
    required this.icon,
    this.activeIcon,
    this.label,
    this.tooltip,
    this.badge,
    this.enabled = true,
  });
}

class SherpaTabBadge2025 {
  final String text;
  final Color? color;

  const SherpaTabBadge2025({
    required this.text,
    this.color,
  });

  factory SherpaTabBadge2025.count(int count, {Color? color}) {
    return SherpaTabBadge2025(
      text: count > 99 ? '99+' : count.toString(),
      color: color,
    );
  }

  factory SherpaTabBadge2025.dot({Color? color}) {
    return SherpaTabBadge2025(
      text: '',
      color: color,
    );
  }
}

// ==================== 열거형 정의 ====================

enum SherpaTabBarVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  floating,    // 플로팅 글래스
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  segmented,   // 세그먼트 컨트롤
  minimal,     // 미니멀 (투명)
}

enum SherpaTabBarPosition {
  bottom,      // 하단 네비게이션
  top,         // 상단 탭
  floating,    // 플로팅 (독립적)
  inline,      // 인라인 (컨텐츠 내부)
}

// ==================== 도우미 클래스들 ====================

class TabBarConfiguration {
  final double height;
  final double iconSize;
  final double labelSize;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;

  const TabBarConfiguration({
    required this.height,
    required this.iconSize,
    required this.labelSize,
    required this.activeColor,
    required this.inactiveColor,
    required this.backgroundColor,
  });
}