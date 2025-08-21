// lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 스마트 필터 컴포넌트
/// 검색바, 온라인 필터, 상세 필터 토글을 통합한 모던한 필터링 시스템
class SherpaSmartFilter2025 extends StatefulWidget {
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final bool showOnlineOnly;
  final ValueChanged<bool>? onOnlineToggle;
  final bool showDetailedFilters;
  final ValueChanged<bool>? onDetailedFiltersToggle;
  final int activeFilterCount;
  final VoidCallback? onClearFilters;
  final String? searchHint;
  final SherpaSmartFilterVariant2025 variant;
  final SherpaSmartFilterStyle style;
  final bool enableVoiceSearch;
  final bool enableAI;
  final VoidCallback? onVoiceSearch;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final String? category;
  final Color? customColor;

  const SherpaSmartFilter2025({
    Key? key,
    this.searchQuery,
    this.onSearchChanged,
    this.showOnlineOnly = false,
    this.onOnlineToggle,
    this.showDetailedFilters = false,
    this.onDetailedFiltersToggle,
    this.activeFilterCount = 0,
    this.onClearFilters,
    this.searchHint,
    this.variant = SherpaSmartFilterVariant2025.glass,
    this.style = SherpaSmartFilterStyle.horizontal,
    this.enableVoiceSearch = true,
    this.enableAI = true,
    this.onVoiceSearch,
    this.padding,
    this.margin,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.category,
    this.customColor,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 스마트 필터 (글래스 스타일)
  factory SherpaSmartFilter2025.standard({
    Key? key,
    String? searchQuery,
    ValueChanged<String>? onSearchChanged,
    bool showOnlineOnly = false,
    ValueChanged<bool>? onOnlineToggle,
    bool showDetailedFilters = false,
    ValueChanged<bool>? onDetailedFiltersToggle,
    int activeFilterCount = 0,
    String? category,
  }) {
    return SherpaSmartFilter2025(
      key: key,
      searchQuery: searchQuery,
      onSearchChanged: onSearchChanged,
      showOnlineOnly: showOnlineOnly,
      onOnlineToggle: onOnlineToggle,
      showDetailedFilters: showDetailedFilters,
      onDetailedFiltersToggle: onDetailedFiltersToggle,
      activeFilterCount: activeFilterCount,
      category: category,
      variant: SherpaSmartFilterVariant2025.glass,
      style: SherpaSmartFilterStyle.horizontal,
    );
  }

  /// 모던 검색 필터 (AI 기능 포함)
  factory SherpaSmartFilter2025.modern({
    Key? key,
    String? searchQuery,
    ValueChanged<String>? onSearchChanged,
    VoidCallback? onVoiceSearch,
    String? category,
  }) {
    return SherpaSmartFilter2025(
      key: key,
      searchQuery: searchQuery,
      onSearchChanged: onSearchChanged,
      onVoiceSearch: onVoiceSearch,
      category: category,
      variant: SherpaSmartFilterVariant2025.hybrid,
      style: SherpaSmartFilterStyle.modern,
      enableVoiceSearch: true,
      enableAI: true,
    );
  }

  /// 컴팩트 필터 (공간 절약형)
  factory SherpaSmartFilter2025.compact({
    Key? key,
    String? searchQuery,
    ValueChanged<String>? onSearchChanged,
    bool showOnlineOnly = false,
    ValueChanged<bool>? onOnlineToggle,
    String? category,
  }) {
    return SherpaSmartFilter2025(
      key: key,
      searchQuery: searchQuery,
      onSearchChanged: onSearchChanged,
      showOnlineOnly: showOnlineOnly,
      onOnlineToggle: onOnlineToggle,
      category: category,
      variant: SherpaSmartFilterVariant2025.neu,
      style: SherpaSmartFilterStyle.compact,
      enableVoiceSearch: false,
      enableAI: false,
    );
  }

  @override
  State<SherpaSmartFilter2025> createState() => _SherpaSmartFilter2025State();
}

class _SherpaSmartFilter2025State extends State<SherpaSmartFilter2025>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _filterAnimationController;
  late AnimationController _voiceAnimationController;
  late Animation<double> _filterAnimation;
  late Animation<double> _voiceAnimation;
  
  bool _isSearchFocused = false;
  bool _isVoiceRecording = false;

  @override
  void initState() {
    super.initState();
    
    _searchController = TextEditingController(text: widget.searchQuery);
    
    _filterAnimationController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );
    
    _voiceAnimationController = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );
    
    _filterAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: MicroInteractions.easeOutQuart,
    ));
    
    _voiceAnimation = Tween<double>(
      begin: 1,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _voiceAnimationController,
      curve: MicroInteractions.bounceOut,
    ));
    
    if (widget.showDetailedFilters) {
      _filterAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(SherpaSmartFilter2025 oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery ?? '';
    }
    
    if (oldWidget.showDetailedFilters != widget.showDetailedFilters) {
      if (widget.showDetailedFilters) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimationController.dispose();
    _voiceAnimationController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    widget.onSearchChanged?.call(value);
  }

  void _handleSearchFocus(bool focused) {
    setState(() => _isSearchFocused = focused);
  }

  void _handleOnlineToggle() {
    widget.onOnlineToggle?.call(!widget.showOnlineOnly);
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleFilterToggle() {
    widget.onDetailedFiltersToggle?.call(!widget.showDetailedFilters);
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleVoiceSearch() {
    setState(() => _isVoiceRecording = !_isVoiceRecording);
    _voiceAnimationController.forward().then((_) => _voiceAnimationController.reverse());
    widget.onVoiceSearch?.call();
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  void _handleClearSearch() {
    _searchController.clear();
    widget.onSearchChanged?.call('');
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getFilterConfiguration();
    
    Widget filter = Container(
      padding: widget.padding ?? EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      margin: widget.margin,
      child: Column(
        children: [
          _buildMainFilterRow(config),
          if (widget.showDetailedFilters && widget.style != SherpaSmartFilterStyle.compact)
            _buildDetailedFiltersIndicator(config),
        ],
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      filter = MicroInteractions.slideInFade(
        child: filter,
        direction: SlideDirection.top,
      );
    }

    return filter;
  }

  Widget _buildMainFilterRow(SmartFilterConfiguration config) {
    return Row(
      children: [
        // 검색바
        Expanded(
          child: _buildSearchBar(config),
        ),
        
        SizedBox(width: config.spacing),
        
        // 온라인 필터 버튼
        if (widget.onOnlineToggle != null)
          _buildOnlineFilterButton(config),
        
        if (widget.onOnlineToggle != null && widget.onDetailedFiltersToggle != null)
          SizedBox(width: config.spacing * 0.5),
        
        // 상세 필터 토글 버튼
        if (widget.onDetailedFiltersToggle != null)
          _buildDetailedFilterButton(config),
      ],
    );
  }

  Widget _buildSearchBar(SmartFilterConfiguration config) {
    final baseColor = widget.customColor ?? 
        (widget.category != null 
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    return Container(
      height: config.searchBarHeight,
      decoration: _getSearchBarDecoration(config, baseColor),
      child: Row(
        children: [
          // 검색 아이콘
          Padding(
            padding: EdgeInsets.only(left: config.searchPadding),
            child: Icon(
              Icons.search_rounded,
              color: _isSearchFocused 
                  ? baseColor 
                  : AppColors2025.textTertiary,
              size: config.iconSize,
            ),
          ),
          
          // 검색 입력 필드
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearchChanged,
              onTap: () => _handleSearchFocus(true),
              onEditingComplete: () => _handleSearchFocus(false),
              style: GoogleFonts.notoSans(
                fontSize: config.textSize,
                color: AppColors2025.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.searchHint ?? '모임 이름, 지역, 키워드로 검색',
                hintStyle: GoogleFonts.notoSans(
                  fontSize: config.textSize,
                  color: AppColors2025.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: config.searchPadding,
                  vertical: config.searchPadding * 0.75,
                ),
              ),
            ),
          ),
          
          // 오른쪽 액션 버튼들
          _buildSearchActions(config, baseColor),
        ],
      ),
    );
  }

  Widget _buildSearchActions(SmartFilterConfiguration config, Color baseColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AI 추천 버튼
        if (widget.enableAI && widget.style == SherpaSmartFilterStyle.modern)
          _buildActionButton(
            icon: Icons.auto_awesome_outlined,
            onTap: () {}, // AI 기능 구현 시 추가
            color: AppColors2025.secondary,
            config: config,
          ),
        
        // 음성 검색 버튼
        if (widget.enableVoiceSearch)
          AnimatedBuilder(
            animation: _voiceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _voiceAnimation.value,
                child: _buildActionButton(
                  icon: _isVoiceRecording 
                      ? Icons.mic 
                      : Icons.mic_outlined,
                  onTap: _handleVoiceSearch,
                  color: _isVoiceRecording 
                      ? AppColors2025.error 
                      : AppColors2025.textTertiary,
                  config: config,
                ),
              );
            },
          ),
        
        // 검색어 지우기 버튼
        if (_searchController.text.isNotEmpty)
          _buildActionButton(
            icon: Icons.clear_rounded,
            onTap: _handleClearSearch,
            color: AppColors2025.textTertiary,
            config: config,
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required SmartFilterConfiguration config,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(config.actionButtonPadding),
        margin: EdgeInsets.only(right: config.searchPadding * 0.5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: config.actionIconSize,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOnlineFilterButton(SmartFilterConfiguration config) {
    final isActive = widget.showOnlineOnly;
    final activeColor = widget.customColor ?? 
        (widget.category != null 
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    return GestureDetector(
      onTap: _handleOnlineToggle,
      child: Container(
        height: config.filterButtonHeight,
        padding: EdgeInsets.symmetric(horizontal: config.filterPadding),
        decoration: _getFilterButtonDecoration(
          config, 
          isActive, 
          isActive ? activeColor : AppColors2025.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_rounded,
              color: isActive 
                  ? AppColors2025.textOnPrimary 
                  : AppColors2025.textSecondary,
              size: config.filterIconSize,
            ),
            SizedBox(width: config.spacing * 0.5),
            Text(
              '온라인',
              style: GoogleFonts.notoSans(
                fontSize: config.filterTextSize,
                fontWeight: FontWeight.w600,
                color: isActive 
                    ? AppColors2025.textOnPrimary 
                    : AppColors2025.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedFilterButton(SmartFilterConfiguration config) {
    final isActive = widget.showDetailedFilters || widget.activeFilterCount > 0;
    final activeColor = widget.customColor ?? 
        (widget.category != null 
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    return Stack(
      children: [
        GestureDetector(
          onTap: _handleFilterToggle,
          child: Container(
            height: config.filterButtonHeight,
            width: config.filterButtonHeight,
            decoration: _getFilterButtonDecoration(
              config, 
              isActive, 
              isActive ? activeColor : AppColors2025.surface,
            ),
            child: Icon(
              widget.showDetailedFilters 
                  ? Icons.filter_list_off_rounded 
                  : Icons.filter_list_rounded,
              color: isActive 
                  ? AppColors2025.textOnPrimary 
                  : AppColors2025.textSecondary,
              size: config.filterIconSize,
            ),
          ),
        ),
        
        // 활성 필터 개수 표시
        if (widget.activeFilterCount > 0 && !widget.showDetailedFilters)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors2025.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  '${widget.activeFilterCount}',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors2025.textOnPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailedFiltersIndicator(SmartFilterConfiguration config) {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _filterAnimation,
          child: Container(
            margin: EdgeInsets.only(top: config.spacing),
            padding: EdgeInsets.all(config.spacing),
            decoration: BoxDecoration(
              color: AppColors2025.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors2025.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: config.indicatorIconSize,
                  color: AppColors2025.primary,
                ),
                SizedBox(width: config.spacing * 0.5),
                Text(
                  '상세 필터가 활성화되었습니다',
                  style: GoogleFonts.notoSans(
                    fontSize: config.indicatorTextSize,
                    color: AppColors2025.textSecondary,
                  ),
                ),
                const Spacer(),
                if (widget.activeFilterCount > 0) ...[
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
                      '${widget.activeFilterCount}개 적용',
                      style: GoogleFonts.notoSans(
                        fontSize: config.indicatorTextSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors2025.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: config.spacing * 0.5),
                ],
                if (widget.onClearFilters != null)
                  GestureDetector(
                    onTap: widget.onClearFilters,
                    child: Container(
                      padding: EdgeInsets.all(config.spacing * 0.5),
                      decoration: BoxDecoration(
                        color: AppColors2025.error.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.clear_rounded,
                        size: config.indicatorIconSize,
                        color: AppColors2025.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  SmartFilterConfiguration _getFilterConfiguration() {
    switch (widget.style) {
      case SherpaSmartFilterStyle.horizontal:
        return SmartFilterConfiguration(
          searchBarHeight: 48,
          filterButtonHeight: 48,
          searchPadding: 16,
          filterPadding: 12,
          spacing: 8,
          textSize: 14,
          iconSize: 20,
          filterIconSize: 18,
          filterTextSize: 13,
          actionIconSize: 18,
          actionButtonPadding: 6,
          indicatorIconSize: 16,
          indicatorTextSize: 12,
          borderRadius: AppSizes.radiusXL,
        );
      case SherpaSmartFilterStyle.modern:
        return SmartFilterConfiguration(
          searchBarHeight: 52,
          filterButtonHeight: 52,
          searchPadding: 18,
          filterPadding: 14,
          spacing: 10,
          textSize: 15,
          iconSize: 22,
          filterIconSize: 20,
          filterTextSize: 14,
          actionIconSize: 20,
          actionButtonPadding: 8,
          indicatorIconSize: 18,
          indicatorTextSize: 13,
          borderRadius: AppSizes.radiusXL,
        );
      case SherpaSmartFilterStyle.compact:
        return SmartFilterConfiguration(
          searchBarHeight: 44,
          filterButtonHeight: 44,
          searchPadding: 14,
          filterPadding: 10,
          spacing: 6,
          textSize: 13,
          iconSize: 18,
          filterIconSize: 16,
          filterTextSize: 12,
          actionIconSize: 16,
          actionButtonPadding: 5,
          indicatorIconSize: 14,
          indicatorTextSize: 11,
          borderRadius: AppSizes.radiusL,
        );
    }
  }

  BoxDecoration _getSearchBarDecoration(SmartFilterConfiguration config, Color baseColor) {
    final focusedColor = _isSearchFocused ? baseColor : AppColors2025.surface;
    
    switch (widget.variant) {
      case SherpaSmartFilterVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.low,
          color: focusedColor,
          borderRadius: config.borderRadius,
          opacity: 0.95,
        );

      case SherpaSmartFilterVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: GlassNeuElevation.low,
          baseColor: AppColors2025.surface,
          borderRadius: config.borderRadius,
        );

      case SherpaSmartFilterVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: GlassNeuElevation.medium,
          color: focusedColor,
          borderRadius: config.borderRadius,
          glassOpacity: _isSearchFocused ? 0.2 : 0.1,
        );

      case SherpaSmartFilterVariant2025.minimal:
        return BoxDecoration(
          color: AppColors2025.surface,
          borderRadius: BorderRadius.circular(config.borderRadius),
          border: Border.all(
            color: _isSearchFocused ? baseColor : AppColors2025.border,
            width: _isSearchFocused ? 2 : 1,
          ),
        );
    }
  }

  BoxDecoration _getFilterButtonDecoration(
    SmartFilterConfiguration config, 
    bool isActive, 
    Color color,
  ) {
    switch (widget.variant) {
      case SherpaSmartFilterVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: isActive ? GlassNeuElevation.medium : GlassNeuElevation.low,
          color: color,
          borderRadius: config.borderRadius,
          opacity: isActive ? 1.0 : 0.95,
        );

      case SherpaSmartFilterVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: isActive ? GlassNeuElevation.medium : GlassNeuElevation.low,
          baseColor: color,
          borderRadius: config.borderRadius,
        );

      case SherpaSmartFilterVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: GlassNeuElevation.medium,
          color: color,
          borderRadius: config.borderRadius,
          glassOpacity: isActive ? 0.2 : 0.1,
        );

      case SherpaSmartFilterVariant2025.minimal:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(config.borderRadius),
          border: Border.all(
            color: isActive ? color : AppColors2025.border,
            width: 1,
          ),
        );
    }
  }
}

// ==================== 열거형 정의 ====================

enum SherpaSmartFilterVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  minimal,     // 미니멀 (기본 테두리)
}

enum SherpaSmartFilterStyle {
  horizontal,  // 가로형 레이아웃 (기본)
  modern,      // 모던 스타일 (AI 기능 포함)
  compact,     // 컴팩트 스타일 (공간 절약)
}

// ==================== 도우미 클래스들 ====================

class SmartFilterConfiguration {
  final double searchBarHeight;
  final double filterButtonHeight;
  final double searchPadding;
  final double filterPadding;
  final double spacing;
  final double textSize;
  final double iconSize;
  final double filterIconSize;
  final double filterTextSize;
  final double actionIconSize;
  final double actionButtonPadding;
  final double indicatorIconSize;
  final double indicatorTextSize;
  final double borderRadius;

  const SmartFilterConfiguration({
    required this.searchBarHeight,
    required this.filterButtonHeight,
    required this.searchPadding,
    required this.filterPadding,
    required this.spacing,
    required this.textSize,
    required this.iconSize,
    required this.filterIconSize,
    required this.filterTextSize,
    required this.actionIconSize,
    required this.actionButtonPadding,
    required this.indicatorIconSize,
    required this.indicatorTextSize,
    required this.borderRadius,
  });
}