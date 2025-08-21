// lib/shared/widgets/components/molecules/sherpa_quick_filter_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 빠른 필터 컴포넌트
/// 한국형 UX 패턴을 적용한 원탭 필터링 시스템
class SherpaQuickFilter2025 extends StatefulWidget {
  final List<SherpaQuickFilterItem2025> items;
  final Set<String> activeFilters;
  final ValueChanged<Set<String>>? onFiltersChanged;
  final ValueChanged<String>? onFilterToggle;
  final String? title;
  final IconData? titleIcon;
  final SherpaQuickFilterVariant2025 variant;
  final SherpaQuickFilterLayout layout;
  final bool enableMultiSelect;
  final int? maxSelection;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final VoidCallback? onClearAll;
  final String? category;
  final Color? customColor;
  final bool showItemCount;
  final ScrollPhysics? scrollPhysics;

  const SherpaQuickFilter2025({
    Key? key,
    required this.items,
    this.activeFilters = const {},
    this.onFiltersChanged,
    this.onFilterToggle,
    this.title,
    this.titleIcon,
    this.variant = SherpaQuickFilterVariant2025.glass,
    this.layout = SherpaQuickFilterLayout.horizontal,
    this.enableMultiSelect = true,
    this.maxSelection,
    this.padding,
    this.margin,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.onClearAll,
    this.category,
    this.customColor,
    this.showItemCount = false,
    this.scrollPhysics,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 빠른 필터 (한국형 UX)
  factory SherpaQuickFilter2025.korean({
    Key? key,
    Set<String> activeFilters = const {},
    ValueChanged<Set<String>>? onFiltersChanged,
    ValueChanged<String>? onFilterToggle,
    String? category,
  }) {
    return SherpaQuickFilter2025(
      key: key,
      items: _getKoreanQuickFilters(),
      activeFilters: activeFilters,
      onFiltersChanged: onFiltersChanged,
      onFilterToggle: onFilterToggle,
      title: '쉽게 찾기',
      titleIcon: Icons.flash_on_rounded,
      category: category,
      variant: SherpaQuickFilterVariant2025.glass,
      layout: SherpaQuickFilterLayout.horizontal,
    );
  }

  /// 모던 빠른 필터 (커스터마이징 가능)
  factory SherpaQuickFilter2025.modern({
    Key? key,
    required List<SherpaQuickFilterItem2025> items,
    Set<String> activeFilters = const {},
    ValueChanged<Set<String>>? onFiltersChanged,
    String? title,
    String? category,
    bool enableMultiSelect = true,
  }) {
    return SherpaQuickFilter2025(
      key: key,
      items: items,
      activeFilters: activeFilters,
      onFiltersChanged: onFiltersChanged,
      title: title,
      category: category,
      enableMultiSelect: enableMultiSelect,
      variant: SherpaQuickFilterVariant2025.hybrid,
      layout: SherpaQuickFilterLayout.wrap,
      showItemCount: true,
    );
  }

  /// 컴팩트 빠른 필터 (공간 절약형)
  factory SherpaQuickFilter2025.compact({
    Key? key,
    required List<SherpaQuickFilterItem2025> items,
    Set<String> activeFilters = const {},
    ValueChanged<String>? onFilterToggle,
    String? category,
  }) {
    return SherpaQuickFilter2025(
      key: key,
      items: items,
      activeFilters: activeFilters,
      onFilterToggle: onFilterToggle,
      category: category,
      variant: SherpaQuickFilterVariant2025.neu,
      layout: SherpaQuickFilterLayout.grid,
      enableMultiSelect: false,
      title: null,
    );
  }

  /// 한국형 기본 필터 아이템들
  static List<SherpaQuickFilterItem2025> _getKoreanQuickFilters() {
    return [
      SherpaQuickFilterItem2025(
        key: 'weekend',
        label: '이번 주말',
        icon: Icons.weekend_rounded,
        color: Colors.orange,
        description: '이번 주 토요일, 일요일 모임',
      ),
      SherpaQuickFilterItem2025(
        key: 'free',
        label: '무료',
        icon: Icons.money_off_rounded,
        color: AppColors2025.success,
        description: '참가비가 없는 모임',
      ),
      SherpaQuickFilterItem2025(
        key: 'beginner',
        label: '초보환영',
        icon: Icons.waving_hand_rounded,
        color: Colors.blue,
        description: '처음 참여해도 부담없는 모임',
      ),
      SherpaQuickFilterItem2025(
        key: 'online',
        label: '온라인',
        icon: Icons.videocam_rounded,
        color: Colors.purple,
        description: '온라인으로 진행되는 모임',
      ),
      SherpaQuickFilterItem2025(
        key: 'small',
        label: '소수정예',
        icon: Icons.group_rounded,
        color: Colors.pink,
        description: '5명 이하의 작은 모임',
      ),
      SherpaQuickFilterItem2025(
        key: 'casual',
        label: '부담없는',
        icon: Icons.sentiment_satisfied_rounded,
        color: Colors.cyan,
        description: '편안한 분위기의 모임',
      ),
      SherpaQuickFilterItem2025(
        key: 'nearby',
        label: '내 주변',
        icon: Icons.near_me_rounded,
        color: Colors.indigo,
        description: '가까운 지역의 모임',
      ),
    ];
  }

  @override
  State<SherpaQuickFilter2025> createState() => _SherpaQuickFilter2025State();
}

class _SherpaQuickFilter2025State extends State<SherpaQuickFilter2025>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _itemAnimationControllers;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: MicroInteractions.medium,
      vsync: this,
    );
    
    _itemAnimationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: MicroInteractions.fast,
        vsync: this,
      ),
    );
    
    _itemAnimations = _itemAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: MicroInteractions.bounceOut,
      ));
    }).toList();
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _itemAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleFilterToggle(String filterKey) {
    final newActiveFilters = Set<String>.from(widget.activeFilters);
    final itemIndex = widget.items.indexWhere((item) => item.key == filterKey);
    
    if (itemIndex != -1) {
      _itemAnimationControllers[itemIndex].forward().then((_) {
        _itemAnimationControllers[itemIndex].reverse();
      });
    }
    
    if (newActiveFilters.contains(filterKey)) {
      newActiveFilters.remove(filterKey);
    } else {
      if (!widget.enableMultiSelect) {
        newActiveFilters.clear();
      }
      
      if (widget.maxSelection == null || 
          newActiveFilters.length < widget.maxSelection!) {
        newActiveFilters.add(filterKey);
      }
    }
    
    widget.onFiltersChanged?.call(newActiveFilters);
    widget.onFilterToggle?.call(filterKey);
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleClearAll() {
    widget.onFiltersChanged?.call({});
    widget.onClearAll?.call();
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getFilterConfiguration();
    
    Widget quickFilter = Container(
      padding: widget.padding ?? EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            _buildTitle(config),
          
          if (widget.title != null)
            SizedBox(height: config.spacing),
          
          _buildFilterItems(config),
        ],
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      quickFilter = MicroInteractions.slideInFade(
        child: quickFilter,
        direction: SlideDirection.bottom,
      );
    }

    return quickFilter;
  }

  Widget _buildTitle(QuickFilterConfiguration config) {
    return Row(
      children: [
        if (widget.titleIcon != null) ...[
          Icon(
            widget.titleIcon,
            size: config.titleIconSize,
            color: widget.customColor ?? 
                (widget.category != null 
                    ? AppColors2025.getCategoryColor2025(widget.category!)
                    : AppColors2025.primary),
          ),
          SizedBox(width: config.spacing * 0.5),
        ],
        
        Text(
          widget.title!,
          style: GoogleFonts.notoSans(
            fontSize: config.titleTextSize,
            fontWeight: FontWeight.w600,
            color: AppColors2025.textPrimary,
          ),
        ),
        
        const Spacer(),
        
        // 활성 필터 개수 표시
        if (widget.activeFilters.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: config.spacing,
              vertical: config.spacing * 0.5,
            ),
            decoration: BoxDecoration(
              color: AppColors2025.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text(
              '${widget.activeFilters.length}개 선택',
              style: GoogleFonts.notoSans(
                fontSize: config.badgeTextSize,
                fontWeight: FontWeight.w600,
                color: AppColors2025.primary,
              ),
            ),
          ),
          
          SizedBox(width: config.spacing * 0.5),
        ],
        
        // 전체 지우기 버튼
        if (widget.activeFilters.isNotEmpty && widget.onClearAll != null)
          GestureDetector(
            onTap: _handleClearAll,
            child: Container(
              padding: EdgeInsets.all(config.spacing * 0.5),
              decoration: BoxDecoration(
                color: AppColors2025.error.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.clear_all_rounded,
                size: config.titleIconSize,
                color: AppColors2025.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterItems(QuickFilterConfiguration config) {
    switch (widget.layout) {
      case SherpaQuickFilterLayout.horizontal:
        return _buildHorizontalLayout(config);
      case SherpaQuickFilterLayout.wrap:
        return _buildWrapLayout(config);
      case SherpaQuickFilterLayout.grid:
        return _buildGridLayout(config);
      case SherpaQuickFilterLayout.vertical:
        return _buildVerticalLayout(config);
    }
  }

  Widget _buildHorizontalLayout(QuickFilterConfiguration config) {
    return SizedBox(
      height: config.itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: widget.scrollPhysics ?? const BouncingScrollPhysics(),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: config.spacing),
            child: AnimatedBuilder(
              animation: _itemAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _itemAnimations[index].value,
                  child: _buildFilterItem(widget.items[index], config),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWrapLayout(QuickFilterConfiguration config) {
    return Wrap(
      spacing: config.spacing,
      runSpacing: config.spacing,
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return AnimatedBuilder(
          animation: _itemAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _itemAnimations[index].value,
              child: _buildFilterItem(item, config),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildGridLayout(QuickFilterConfiguration config) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: config.spacing,
        mainAxisSpacing: config.spacing,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _itemAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _itemAnimations[index].value,
              child: _buildFilterItem(widget.items[index], config),
            );
          },
        );
      },
    );
  }

  Widget _buildVerticalLayout(QuickFilterConfiguration config) {
    return Column(
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(bottom: config.spacing),
          child: AnimatedBuilder(
            animation: _itemAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _itemAnimations[index].value,
                child: _buildFilterItem(item, config),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterItem(SherpaQuickFilterItem2025 item, QuickFilterConfiguration config) {
    final isActive = widget.activeFilters.contains(item.key);
    final itemColor = item.color ?? AppColors2025.primary;
    
    return GestureDetector(
      onTap: () => _handleFilterToggle(item.key),
      child: Container(
        height: widget.layout == SherpaQuickFilterLayout.horizontal 
            ? config.itemHeight 
            : null,
        padding: EdgeInsets.symmetric(
          horizontal: config.itemPadding,
          vertical: config.itemPadding * 0.75,
        ),
        decoration: _getItemDecoration(config, isActive, itemColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Icon(
              item.icon,
              size: config.iconSize,
              color: isActive ? AppColors2025.textOnPrimary : itemColor,
            ),
            
            SizedBox(width: config.spacing * 0.5),
            
            // 라벨
            Flexible(
              child: Text(
                item.label,
                style: GoogleFonts.notoSans(
                  fontSize: config.textSize,
                  fontWeight: FontWeight.w600,
                  color: isActive 
                      ? AppColors2025.textOnPrimary 
                      : AppColors2025.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // 개수 표시 (선택사항)
            if (widget.showItemCount && item.count != null) ...[
              SizedBox(width: config.spacing * 0.5),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: config.spacing * 0.5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppColors2025.textOnPrimary.withOpacity(0.2)
                      : itemColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  '${item.count}',
                  style: GoogleFonts.notoSans(
                    fontSize: config.countTextSize,
                    fontWeight: FontWeight.w700,
                    color: isActive 
                        ? AppColors2025.textOnPrimary 
                        : itemColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ).animate(target: isActive ? 1 : 0)
        .scale(
          duration: MicroInteractions.fast,
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
        ),
    );
  }

  QuickFilterConfiguration _getFilterConfiguration() {
    switch (widget.layout) {
      case SherpaQuickFilterLayout.horizontal:
        return QuickFilterConfiguration(
          itemHeight: 36,
          itemPadding: 12,
          spacing: 8,
          textSize: 12,
          iconSize: 16,
          titleTextSize: 14,
          titleIconSize: 16,
          badgeTextSize: 11,
          countTextSize: 10,
        );
      case SherpaQuickFilterLayout.wrap:
        return QuickFilterConfiguration(
          itemHeight: 40,
          itemPadding: 14,
          spacing: 10,
          textSize: 13,
          iconSize: 18,
          titleTextSize: 15,
          titleIconSize: 18,
          badgeTextSize: 12,
          countTextSize: 11,
        );
      case SherpaQuickFilterLayout.grid:
        return QuickFilterConfiguration(
          itemHeight: 32,
          itemPadding: 10,
          spacing: 8,
          textSize: 11,
          iconSize: 14,
          titleTextSize: 13,
          titleIconSize: 14,
          badgeTextSize: 10,
          countTextSize: 9,
        );
      case SherpaQuickFilterLayout.vertical:
        return QuickFilterConfiguration(
          itemHeight: 44,
          itemPadding: 16,
          spacing: 12,
          textSize: 14,
          iconSize: 20,
          titleTextSize: 16,
          titleIconSize: 20,
          badgeTextSize: 13,
          countTextSize: 12,
        );
    }
  }

  BoxDecoration _getItemDecoration(
    QuickFilterConfiguration config, 
    bool isActive, 
    Color itemColor,
  ) {
    final backgroundColor = isActive ? itemColor : AppColors2025.surface;
    
    switch (widget.variant) {
      case SherpaQuickFilterVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: isActive ? GlassNeuElevation.medium : GlassNeuElevation.low,
          color: backgroundColor,
          borderRadius: AppSizes.radiusL,
          opacity: isActive ? 1.0 : 0.95,
        );

      case SherpaQuickFilterVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: isActive ? GlassNeuElevation.medium : GlassNeuElevation.low,
          baseColor: backgroundColor,
          borderRadius: AppSizes.radiusL,
        );

      case SherpaQuickFilterVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: GlassNeuElevation.medium,
          color: backgroundColor,
          borderRadius: AppSizes.radiusL,
          glassOpacity: isActive ? 0.25 : 0.15,
        );

      case SherpaQuickFilterVariant2025.minimal:
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isActive ? itemColor : AppColors2025.border,
            width: isActive ? 2 : 1,
          ),
        );
    }
  }
}

// ==================== 모델 클래스들 ====================

class SherpaQuickFilterItem2025 {
  final String key;
  final String label;
  final IconData icon;
  final Color? color;
  final String? description;
  final int? count;
  final bool enabled;

  const SherpaQuickFilterItem2025({
    required this.key,
    required this.label,
    required this.icon,
    this.color,
    this.description,
    this.count,
    this.enabled = true,
  });

  SherpaQuickFilterItem2025 copyWith({
    String? key,
    String? label,
    IconData? icon,
    Color? color,
    String? description,
    int? count,
    bool? enabled,
  }) {
    return SherpaQuickFilterItem2025(
      key: key ?? this.key,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      count: count ?? this.count,
      enabled: enabled ?? this.enabled,
    );
  }
}

// ==================== 열거형 정의 ====================

enum SherpaQuickFilterVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  minimal,     // 미니멀 (기본 테두리)
}

enum SherpaQuickFilterLayout {
  horizontal,  // 가로 스크롤 (기본)
  wrap,        // 랩 레이아웃
  grid,        // 그리드 레이아웃
  vertical,    // 세로 배치
}

// ==================== 도우미 클래스들 ====================

class QuickFilterConfiguration {
  final double itemHeight;
  final double itemPadding;
  final double spacing;
  final double textSize;
  final double iconSize;
  final double titleTextSize;
  final double titleIconSize;
  final double badgeTextSize;
  final double countTextSize;

  const QuickFilterConfiguration({
    required this.itemHeight,
    required this.itemPadding,
    required this.spacing,
    required this.textSize,
    required this.iconSize,
    required this.titleTextSize,
    required this.titleIconSize,
    required this.badgeTextSize,
    required this.countTextSize,
  });
}