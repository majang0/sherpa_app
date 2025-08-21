// lib/shared/widgets/components/molecules/sherpa_ai_recommendation_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';
import '../../../../features/meetings/models/available_meeting_model.dart';

/// 2025 디자인 트렌드를 반영한 AI 기반 모임 추천 컴포넌트
/// 개인화된 추천 시스템과 스마트 매칭을 제공하는 모던한 추천 위젯
class SherpaAIRecommendation2025 extends StatefulWidget {
  final List<SherpaAIRecommendationItem2025> recommendations;
  final String? title;
  final String? subtitle;
  final IconData? titleIcon;
  final SherpaAIRecommendationVariant2025 variant;
  final SherpaAIRecommendationLayout layout;
  final SherpaAIRecommendationType type;
  final bool enableAutoRotation;
  final Duration rotationDuration;
  final ValueChanged<SherpaAIRecommendationItem2025>? onRecommendationTap;
  final ValueChanged<SherpaAIRecommendationItem2025>? onLike;
  final ValueChanged<SherpaAIRecommendationItem2025>? onDislike;
  final VoidCallback? onRefresh;
  final VoidCallback? onSeeAll;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final bool showFeedbackButtons;
  final bool showConfidenceScore;
  final String? category;
  final Color? customColor;
  final bool isLoading;
  final Widget? emptyWidget;
  final int maxVisible;

  const SherpaAIRecommendation2025({
    Key? key,
    required this.recommendations,
    this.title,
    this.subtitle,
    this.titleIcon,
    this.variant = SherpaAIRecommendationVariant2025.glass,
    this.layout = SherpaAIRecommendationLayout.horizontal,
    this.type = SherpaAIRecommendationType.personalized,
    this.enableAutoRotation = true,
    this.rotationDuration = const Duration(seconds: 5),
    this.onRecommendationTap,
    this.onLike,
    this.onDislike,
    this.onRefresh,
    this.onSeeAll,
    this.padding,
    this.margin,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.showFeedbackButtons = true,
    this.showConfidenceScore = true,
    this.category,
    this.customColor,
    this.isLoading = false,
    this.emptyWidget,
    this.maxVisible = 5,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 개인화 추천 (AI 매칭)
  factory SherpaAIRecommendation2025.personalized({
    Key? key,
    required List<SherpaAIRecommendationItem2025> recommendations,
    ValueChanged<SherpaAIRecommendationItem2025>? onRecommendationTap,
    ValueChanged<SherpaAIRecommendationItem2025>? onLike,
    VoidCallback? onRefresh,
    String? category,
  }) {
    return SherpaAIRecommendation2025(
      key: key,
      recommendations: recommendations,
      title: '맞춤 추천',
      subtitle: 'AI가 추천하는 나만의 모임',
      titleIcon: Icons.auto_awesome_rounded,
      onRecommendationTap: onRecommendationTap,
      onLike: onLike,
      onRefresh: onRefresh,
      category: category,
      type: SherpaAIRecommendationType.personalized,
      variant: SherpaAIRecommendationVariant2025.glass,
      layout: SherpaAIRecommendationLayout.horizontal,
    );
  }

  /// 트렌딩 추천 (인기 모임)
  factory SherpaAIRecommendation2025.trending({
    Key? key,
    required List<SherpaAIRecommendationItem2025> recommendations,
    ValueChanged<SherpaAIRecommendationItem2025>? onRecommendationTap,
    VoidCallback? onSeeAll,
    String? category,
  }) {
    return SherpaAIRecommendation2025(
      key: key,
      recommendations: recommendations,
      title: '지금 뜨는 모임',
      subtitle: '많은 사람들이 참여하고 있어요',
      titleIcon: Icons.trending_up_rounded,
      onRecommendationTap: onRecommendationTap,
      onSeeAll: onSeeAll,
      category: category,
      type: SherpaAIRecommendationType.trending,
      variant: SherpaAIRecommendationVariant2025.hybrid,
      layout: SherpaAIRecommendationLayout.carousel,
      showFeedbackButtons: false,
      showConfidenceScore: false,
    );
  }

  /// 근처 추천 (위치 기반)
  factory SherpaAIRecommendation2025.nearby({
    Key? key,
    required List<SherpaAIRecommendationItem2025> recommendations,
    ValueChanged<SherpaAIRecommendationItem2025>? onRecommendationTap,
    String? category,
  }) {
    return SherpaAIRecommendation2025(
      key: key,
      recommendations: recommendations,
      title: '내 주변 모임',
      subtitle: '가까운 곳에서 만나요',
      titleIcon: Icons.near_me_rounded,
      onRecommendationTap: onRecommendationTap,
      category: category,
      type: SherpaAIRecommendationType.nearby,
      variant: SherpaAIRecommendationVariant2025.neu,
      layout: SherpaAIRecommendationLayout.list,
      enableAutoRotation: false,
    );
  }

  /// 유사 추천 (관심사 기반)
  factory SherpaAIRecommendation2025.similar({
    Key? key,
    required List<SherpaAIRecommendationItem2025> recommendations,
    ValueChanged<SherpaAIRecommendationItem2025>? onRecommendationTap,
    String? category,
  }) {
    return SherpaAIRecommendation2025(
      key: key,
      recommendations: recommendations,
      title: '비슷한 관심사',
      subtitle: '이런 모임은 어떠세요?',
      titleIcon: Icons.psychology_rounded,
      onRecommendationTap: onRecommendationTap,
      category: category,
      type: SherpaAIRecommendationType.similar,
      variant: SherpaAIRecommendationVariant2025.minimal,
      layout: SherpaAIRecommendationLayout.compact,
      maxVisible: 3,
    );
  }

  /// 로딩 상태 추천
  factory SherpaAIRecommendation2025.loading({
    Key? key,
    String? category,
  }) {
    return SherpaAIRecommendation2025(
      key: key,
      recommendations: const [],
      title: 'AI 추천 준비 중',
      subtitle: '잠시만 기다려주세요',
      titleIcon: Icons.auto_awesome_rounded,
      category: category,
      isLoading: true,
      variant: SherpaAIRecommendationVariant2025.glass,
      layout: SherpaAIRecommendationLayout.horizontal,
    );
  }

  @override
  State<SherpaAIRecommendation2025> createState() => _SherpaAIRecommendation2025State();
}

class _SherpaAIRecommendation2025State extends State<SherpaAIRecommendation2025>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  
  int _currentIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: widget.rotationDuration,
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: MicroInteractions.medium,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: MicroInteractions.slow,
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: MicroInteractions.easeInOutSine,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: MicroInteractions.easeInOutSine,
    ));
    
    if (widget.layout == SherpaAIRecommendationLayout.carousel) {
      _pageController = PageController();
    }
    
    // 자동 로테이션 시작
    if (widget.enableAutoRotation && !widget.isLoading) {
      _startAutoRotation();
    }
    
    // 로딩 애니메이션 시작
    if (widget.isLoading) {
      _shimmerController.repeat();
    }
    
    // AI 추천은 항상 약간의 펄스 효과
    if (widget.type == SherpaAIRecommendationType.personalized) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _startAutoRotation() {
    if (widget.recommendations.isEmpty) return;
    
    _rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.recommendations.length;
        });
        _rotationController.reset();
        _rotationController.forward();
      }
    });
    
    _rotationController.forward();
  }

  void _handleRecommendationTap(SherpaAIRecommendationItem2025 item) {
    widget.onRecommendationTap?.call(item);
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleLike(SherpaAIRecommendationItem2025 item) {
    widget.onLike?.call(item);
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  void _handleDislike(SherpaAIRecommendationItem2025 item) {
    widget.onDislike?.call(item);
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleRefresh() {
    widget.onRefresh?.call();
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getRecommendationConfiguration();
    
    Widget recommendation = Container(
      padding: widget.padding ?? EdgeInsets.all(AppSizes.paddingL),
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          if (widget.title != null)
            _buildHeader(config),
          
          if (widget.title != null)
            SizedBox(height: config.spacing),
          
          // 추천 콘텐츠
          if (widget.isLoading)
            _buildLoadingContent(config)
          else if (widget.recommendations.isEmpty)
            _buildEmptyContent(config)
          else
            _buildRecommendationContent(config),
        ],
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      recommendation = MicroInteractions.slideInFade(
        child: recommendation,
        direction: SlideDirection.left,
      );
    }

    return recommendation;
  }

  Widget _buildHeader(AIRecommendationConfiguration config) {
    final baseColor = widget.customColor ?? 
        (widget.category != null 
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    return Row(
      children: [
        // AI 아이콘과 제목
        if (widget.titleIcon != null)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(config.iconPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        baseColor,
                        baseColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(config.iconRadius),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.titleIcon,
                    size: config.iconSize,
                    color: AppColors2025.textOnPrimary,
                  ),
                ),
              );
            },
          ),
        
        if (widget.titleIcon != null)
          SizedBox(width: config.spacing),
        
        // 제목과 부제목
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title!,
                style: GoogleFonts.notoSans(
                  fontSize: config.titleSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors2025.textPrimary,
                ),
              ),
              if (widget.subtitle != null) ...[
                SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: GoogleFonts.notoSans(
                    fontSize: config.subtitleSize,
                    color: AppColors2025.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // 액션 버튼들
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 새로고침 버튼
            if (widget.onRefresh != null)
              GestureDetector(
                onTap: _handleRefresh,
                child: Container(
                  padding: EdgeInsets.all(config.actionButtonPadding),
                  decoration: BoxDecoration(
                    color: AppColors2025.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors2025.border,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: config.actionIconSize,
                    color: AppColors2025.textSecondary,
                  ),
                ),
              ),
            
            // 전체 보기 버튼
            if (widget.onSeeAll != null) ...[
              SizedBox(width: config.spacing * 0.5),
              GestureDetector(
                onTap: widget.onSeeAll,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: config.spacing,
                    vertical: config.actionButtonPadding,
                  ),
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: Border.all(
                      color: baseColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체',
                        style: GoogleFonts.notoSans(
                          fontSize: config.actionTextSize,
                          fontWeight: FontWeight.w600,
                          color: baseColor,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: config.actionIconSize,
                        color: baseColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingContent(AIRecommendationConfiguration config) {
    return SizedBox(
      height: config.itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: config.itemWidth,
            margin: EdgeInsets.only(right: config.spacing),
            child: _buildLoadingCard(config),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard(AIRecommendationConfiguration config) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: _getCardDecoration(config, false),
          child: Stack(
            children: [
              // 기본 콘텐츠 플레이스홀더
              Padding(
                padding: EdgeInsets.all(config.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors2025.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: config.spacing),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColors2025.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors2025.surface,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 시머 효과
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(config.borderRadius),
                    gradient: LinearGradient(
                      begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                      end: Alignment(-0.5 + _shimmerAnimation.value, 0.0),
                      colors: [
                        Colors.transparent,
                        AppColors2025.glassWhite20.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyContent(AIRecommendationConfiguration config) {
    return Container(
      height: config.itemHeight,
      child: widget.emptyWidget ?? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: AppColors2025.textTertiary,
            ),
            SizedBox(height: config.spacing),
            Text(
              'AI가 추천을 준비 중이에요',
              style: GoogleFonts.notoSans(
                fontSize: config.subtitleSize,
                color: AppColors2025.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationContent(AIRecommendationConfiguration config) {
    switch (widget.layout) {
      case SherpaAIRecommendationLayout.horizontal:
        return _buildHorizontalLayout(config);
      case SherpaAIRecommendationLayout.carousel:
        return _buildCarouselLayout(config);
      case SherpaAIRecommendationLayout.list:
        return _buildListLayout(config);
      case SherpaAIRecommendationLayout.compact:
        return _buildCompactLayout(config);
    }
  }

  Widget _buildHorizontalLayout(AIRecommendationConfiguration config) {
    final visibleItems = widget.recommendations.take(widget.maxVisible).toList();
    
    return SizedBox(
      height: config.itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: visibleItems.length,
        itemBuilder: (context, index) {
          return Container(
            width: config.itemWidth,
            margin: EdgeInsets.only(right: config.spacing),
            child: _buildRecommendationCard(visibleItems[index], config),
          );
        },
      ),
    );
  }

  Widget _buildCarouselLayout(AIRecommendationConfiguration config) {
    return SizedBox(
      height: config.itemHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.recommendations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: config.spacing),
            child: _buildRecommendationCard(widget.recommendations[index], config),
          );
        },
      ),
    );
  }

  Widget _buildListLayout(AIRecommendationConfiguration config) {
    final visibleItems = widget.recommendations.take(widget.maxVisible).toList();
    
    return Column(
      children: visibleItems.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: config.spacing),
          child: _buildRecommendationCard(item, config, isListItem: true),
        );
      }).toList(),
    );
  }

  Widget _buildCompactLayout(AIRecommendationConfiguration config) {
    final visibleItems = widget.recommendations.take(widget.maxVisible).toList();
    
    return Wrap(
      spacing: config.spacing,
      runSpacing: config.spacing,
      children: visibleItems.map((item) {
        return SizedBox(
          width: config.compactWidth,
          child: _buildRecommendationCard(item, config, isCompact: true),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendationCard(
    SherpaAIRecommendationItem2025 item, 
    AIRecommendationConfiguration config,
    {bool isListItem = false, bool isCompact = false}
  ) {
    return GestureDetector(
      onTap: () => _handleRecommendationTap(item),
      child: Container(
        height: isCompact ? config.compactHeight : (isListItem ? config.listItemHeight : config.itemHeight),
        width: isListItem ? double.infinity : null,
        decoration: _getCardDecoration(config, true),
        child: Padding(
          padding: EdgeInsets.all(config.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 제목과 신뢰도
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.meeting.title,
                      style: GoogleFonts.notoSans(
                        fontSize: config.cardTitleSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors2025.textPrimary,
                      ),
                      maxLines: isCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.showConfidenceScore && item.confidenceScore != null)
                    _buildConfidenceBadge(item.confidenceScore!, config),
                ],
              ),
              
              SizedBox(height: config.spacing * 0.5),
              
              // 중단: 추천 이유
              if (item.reason.isNotEmpty && !isCompact)
                Text(
                  item.reason,
                  style: GoogleFonts.notoSans(
                    fontSize: config.reasonSize,
                    color: AppColors2025.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              if (item.reason.isNotEmpty && !isCompact)
                SizedBox(height: config.spacing * 0.5),
              
              // 하단: 정보와 액션
              Expanded(
                child: Row(
                  children: [
                    // 카테고리와 시간
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                config._getCategoryIcon(item.meeting.category),
                                size: config.infoIconSize,
                                color: AppColors2025.textTertiary,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.meeting.category.displayName,
                                  style: GoogleFonts.notoSans(
                                    fontSize: config.infoSize,
                                    color: AppColors2025.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (!isCompact) ...[
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  size: config.infoIconSize,
                                  color: AppColors2025.textTertiary,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _formatDateTime(item.meeting.dateTime),
                                    style: GoogleFonts.notoSans(
                                      fontSize: config.infoSize,
                                      color: AppColors2025.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // 피드백 버튼들
                    if (widget.showFeedbackButtons && !isCompact)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _handleLike(item),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors2025.success.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.thumb_up_outlined,
                                size: config.feedbackIconSize,
                                color: AppColors2025.success,
                              ),
                            ),
                          ),
                          SizedBox(width: config.spacing * 0.5),
                          GestureDetector(
                            onTap: () => _handleDislike(item),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors2025.error.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.thumb_down_outlined,
                                size: config.feedbackIconSize,
                                color: AppColors2025.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence, AIRecommendationConfiguration config) {
    final percentage = (confidence * 100).round();
    final color = confidence >= 0.8 
        ? AppColors2025.success 
        : confidence >= 0.6 
            ? AppColors2025.warning 
            : AppColors2025.error;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: config.spacing * 0.5,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        '${percentage}%',
        style: GoogleFonts.notoSans(
          fontSize: config.badgeSize,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  AIRecommendationConfiguration _getRecommendationConfiguration() {
    switch (widget.layout) {
      case SherpaAIRecommendationLayout.horizontal:
        return AIRecommendationConfiguration(
          itemWidth: 200,
          itemHeight: 140,
          listItemHeight: 100,
          compactWidth: 120,
          compactHeight: 80,
          spacing: 12,
          cardPadding: 12,
          borderRadius: AppSizes.radiusL,
          titleSize: 16,
          subtitleSize: 12,
          cardTitleSize: 14,
          reasonSize: 11,
          infoSize: 10,
          badgeSize: 9,
          iconSize: 20,
          iconPadding: 8,
          iconRadius: 10,
          actionIconSize: 16,
          actionButtonPadding: 6,
          actionTextSize: 12,
          infoIconSize: 12,
          feedbackIconSize: 14,
        );
      case SherpaAIRecommendationLayout.carousel:
        return AIRecommendationConfiguration(
          itemWidth: double.infinity,
          itemHeight: 160,
          listItemHeight: 120,
          compactWidth: 140,
          compactHeight: 100,
          spacing: 16,
          cardPadding: 16,
          borderRadius: AppSizes.radiusXL,
          titleSize: 18,
          subtitleSize: 14,
          cardTitleSize: 16,
          reasonSize: 12,
          infoSize: 11,
          badgeSize: 10,
          iconSize: 24,
          iconPadding: 10,
          iconRadius: 12,
          actionIconSize: 18,
          actionButtonPadding: 8,
          actionTextSize: 13,
          infoIconSize: 14,
          feedbackIconSize: 16,
        );
      case SherpaAIRecommendationLayout.list:
        return AIRecommendationConfiguration(
          itemWidth: double.infinity,
          itemHeight: 120,
          listItemHeight: 80,
          compactWidth: 160,
          compactHeight: 120,
          spacing: 10,
          cardPadding: 14,
          borderRadius: AppSizes.radiusL,
          titleSize: 17,
          subtitleSize: 13,
          cardTitleSize: 15,
          reasonSize: 11,
          infoSize: 10,
          badgeSize: 9,
          iconSize: 22,
          iconPadding: 9,
          iconRadius: 11,
          actionIconSize: 17,
          actionButtonPadding: 7,
          actionTextSize: 12,
          infoIconSize: 13,
          feedbackIconSize: 15,
        );
      case SherpaAIRecommendationLayout.compact:
        return AIRecommendationConfiguration(
          itemWidth: 100,
          itemHeight: 80,
          listItemHeight: 60,
          compactWidth: 100,
          compactHeight: 60,
          spacing: 8,
          cardPadding: 8,
          borderRadius: AppSizes.radiusM,
          titleSize: 14,
          subtitleSize: 11,
          cardTitleSize: 12,
          reasonSize: 10,
          infoSize: 9,
          badgeSize: 8,
          iconSize: 18,
          iconPadding: 6,
          iconRadius: 9,
          actionIconSize: 14,
          actionButtonPadding: 4,
          actionTextSize: 10,
          infoIconSize: 10,
          feedbackIconSize: 12,
        );
    }
  }

  BoxDecoration _getCardDecoration(AIRecommendationConfiguration config, bool isRecommendationCard) {
    final baseColor = widget.customColor ?? AppColors2025.surface;
    
    switch (widget.variant) {
      case SherpaAIRecommendationVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.medium,
          color: baseColor,
          borderRadius: config.borderRadius,
          opacity: 0.95,
        );

      case SherpaAIRecommendationVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: GlassNeuElevation.medium,
          baseColor: baseColor,
          borderRadius: config.borderRadius,
        );

      case SherpaAIRecommendationVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: GlassNeuElevation.medium,
          color: baseColor,
          borderRadius: config.borderRadius,
          glassOpacity: 0.2,
        );

      case SherpaAIRecommendationVariant2025.minimal:
        return BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(config.borderRadius),
          border: Border.all(
            color: AppColors2025.border,
            width: 1,
          ),
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;
    
    if (difference == 0) {
      return '오늘 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return '내일 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference < 7) {
      final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return '${weekdays[dateTime.weekday - 1]}요일';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}

// ==================== 모델 클래스들 ====================

class SherpaAIRecommendationItem2025 {
  final String id;
  final AvailableMeeting meeting;
  final String reason;
  final double? confidenceScore;
  final SherpaAIRecommendationType type;
  final Map<String, dynamic>? metadata;

  const SherpaAIRecommendationItem2025({
    required this.id,
    required this.meeting,
    required this.reason,
    this.confidenceScore,
    required this.type,
    this.metadata,
  });

  SherpaAIRecommendationItem2025 copyWith({
    String? id,
    AvailableMeeting? meeting,
    String? reason,
    double? confidenceScore,
    SherpaAIRecommendationType? type,
    Map<String, dynamic>? metadata,
  }) {
    return SherpaAIRecommendationItem2025(
      id: id ?? this.id,
      meeting: meeting ?? this.meeting,
      reason: reason ?? this.reason,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }
}

// ==================== 열거형 정의 ====================

enum SherpaAIRecommendationVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  minimal,     // 미니멀 (기본 테두리)
}

enum SherpaAIRecommendationLayout {
  horizontal,  // 가로 스크롤
  carousel,    // 페이지뷰 캐러셀
  list,        // 세로 리스트
  compact,     // 컴팩트 그리드
}

enum SherpaAIRecommendationType {
  personalized, // 개인화 추천
  trending,     // 트렌딩 추천
  nearby,       // 근처 추천
  similar,      // 유사 추천
}

// ==================== 도우미 클래스들 ====================

class AIRecommendationConfiguration {
  final double itemWidth;
  final double itemHeight;
  final double listItemHeight;
  final double compactWidth;
  final double compactHeight;
  final double spacing;
  final double cardPadding;
  final double borderRadius;
  final double titleSize;
  final double subtitleSize;
  final double cardTitleSize;
  final double reasonSize;
  final double infoSize;
  final double badgeSize;
  final double iconSize;
  final double iconPadding;
  final double iconRadius;
  final double actionIconSize;
  final double actionButtonPadding;
  final double actionTextSize;
  final double infoIconSize;
  final double feedbackIconSize;

  const AIRecommendationConfiguration({
    required this.itemWidth,
    required this.itemHeight,
    required this.listItemHeight,
    required this.compactWidth,
    required this.compactHeight,
    required this.spacing,
    required this.cardPadding,
    required this.borderRadius,
    required this.titleSize,
    required this.subtitleSize,
    required this.cardTitleSize,
    required this.reasonSize,
    required this.infoSize,
    required this.badgeSize,
    required this.iconSize,
    required this.iconPadding,
    required this.iconRadius,
    required this.actionIconSize,
    required this.actionButtonPadding,
    required this.actionTextSize,
    required this.infoIconSize,
    required this.feedbackIconSize,
  });

  IconData _getCategoryIcon(MeetingCategory category) {
    switch (category) {
      case MeetingCategory.all:
        return Icons.star;
      case MeetingCategory.exercise:
        return Icons.fitness_center;
      case MeetingCategory.study:
        return Icons.school;
      case MeetingCategory.reading:
        return Icons.menu_book;
      case MeetingCategory.networking:
        return Icons.people;
      case MeetingCategory.culture:
        return Icons.theater_comedy;
      case MeetingCategory.outdoor:
        return Icons.landscape;
    }
  }
}