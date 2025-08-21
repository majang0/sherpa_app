// lib/shared/widgets/components/molecules/sherpa_meeting_stats_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 모임 통계 대시보드 컴포넌트
/// 개인 모임 통계를 시각적으로 표시하는 모던한 대시보드
class SherpaMeetingStats2025 extends StatefulWidget {
  final List<SherpaStatsItem2025> statsItems;
  final String? title;
  final String? subtitle;
  final IconData? titleIcon;
  final SherpaMeetingStatsVariant2025 variant;
  final SherpaMeetingStatsLayout layout;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final String? category;
  final Color? customColor;
  final bool showProgressBars;
  final bool showTrends;
  final GlassNeuElevation elevation;

  const SherpaMeetingStats2025({
    Key? key,
    required this.statsItems,
    this.title,
    this.subtitle,
    this.titleIcon,
    this.variant = SherpaMeetingStatsVariant2025.glass,
    this.layout = SherpaMeetingStatsLayout.horizontal,
    this.onTap,
    this.padding,
    this.margin,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.category,
    this.customColor,
    this.showProgressBars = false,
    this.showTrends = true,
    this.elevation = GlassNeuElevation.medium,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 모임 통계 (3개 항목)
  factory SherpaMeetingStats2025.meeting({
    Key? key,
    required int joinedMeetings,
    required int thisMonthCount,
    required int socialityLevel,
    String? userName,
    VoidCallback? onTap,
    String? category,
  }) {
    return SherpaMeetingStats2025(
      key: key,
      title: '나의 모임 통계',
      subtitle: userName != null ? '$userName님의 활동' : null,
      onTap: onTap,
      category: category,
      statsItems: [
        SherpaStatsItem2025(
          key: 'joined',
          label: '참여 모임',
          value: '$joinedMeetings',
          icon: Icons.groups_rounded,
          color: AppColors2025.primary,
          trend: joinedMeetings > 0 ? StatsTrend.up : StatsTrend.neutral,
        ),
        SherpaStatsItem2025(
          key: 'monthly',
          label: '이번 달',
          value: '${thisMonthCount}회',
          icon: Icons.calendar_month_rounded,
          color: AppColors2025.secondary,
          trend: thisMonthCount > 0 ? StatsTrend.up : StatsTrend.neutral,
        ),
        SherpaStatsItem2025(
          key: 'sociality',
          label: '사교성',
          value: 'Lv.$socialityLevel',
          icon: Icons.emoji_people_rounded,
          color: AppColors2025.success,
          trend: socialityLevel > 5 ? StatsTrend.up : StatsTrend.neutral,
          maxValue: 10,
          currentValue: socialityLevel.toDouble(),
        ),
      ],
      variant: SherpaMeetingStatsVariant2025.glass,
      layout: SherpaMeetingStatsLayout.horizontal,
      showTrends: true,
    );
  }

  /// 상세 모임 통계 (더 많은 정보)
  factory SherpaMeetingStats2025.detailed({
    Key? key,
    required List<SherpaStatsItem2025> statsItems,
    String? title,
    String? subtitle,
    VoidCallback? onTap,
    String? category,
  }) {
    return SherpaMeetingStats2025(
      key: key,
      statsItems: statsItems,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      category: category,
      variant: SherpaMeetingStatsVariant2025.hybrid,
      layout: SherpaMeetingStatsLayout.grid,
      showProgressBars: true,
      showTrends: true,
    );
  }

  /// 컴팩트 통계 (공간 절약형)
  factory SherpaMeetingStats2025.compact({
    Key? key,
    required List<SherpaStatsItem2025> statsItems,
    String? category,
  }) {
    return SherpaMeetingStats2025(
      key: key,
      statsItems: statsItems,
      category: category,
      variant: SherpaMeetingStatsVariant2025.neu,
      layout: SherpaMeetingStatsLayout.vertical,
      showTrends: false,
      showProgressBars: false,
    );
  }

  @override
  State<SherpaMeetingStats2025> createState() => _SherpaMeetingStats2025State();
}

class _SherpaMeetingStats2025State extends State<SherpaMeetingStats2025>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late List<AnimationController> _itemAnimationControllers;
  late List<Animation<double>> _itemAnimations;
  late List<Animation<double>> _progressAnimations;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: MicroInteractions.medium,
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: MicroInteractions.slow,
      vsync: this,
    );
    
    _itemAnimationControllers = List.generate(
      widget.statsItems.length,
      (index) => AnimationController(
        duration: MicroInteractions.fast,
        vsync: this,
      ),
    );
    
    _itemAnimations = _itemAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: MicroInteractions.easeOutQuart,
      ));
    }).toList();
    
    _progressAnimations = widget.statsItems.map((item) {
      final progress = item.maxValue != null && item.currentValue != null
          ? (item.currentValue! / item.maxValue!).clamp(0.0, 1.0)
          : 0.0;
      
      return Tween<double>(
        begin: 0,
        end: progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: MicroInteractions.easeOutQuart,
      ));
    }).toList();
    
    _animationController.forward();
    _progressController.forward();
    
    // 순차적으로 아이템 애니메이션 실행
    for (int i = 0; i < _itemAnimationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _itemAnimationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    for (final controller in _itemAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTap() {
    widget.onTap?.call();
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableMicroInteractions) return;
    setState(() => _isHovered = isHovered);
  }

  @override
  Widget build(BuildContext context) {
    final config = _getStatsConfiguration();
    
    Widget stats = MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap != null ? _handleTap : null,
        child: AnimatedContainer(
          duration: MicroInteractions.fast,
          padding: widget.padding ?? EdgeInsets.all(config.containerPadding),
          margin: widget.margin ?? EdgeInsets.only(bottom: AppSizes.paddingM),
          decoration: _getContainerDecoration(config),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null || widget.subtitle != null)
                _buildHeader(config),
              
              if (widget.title != null || widget.subtitle != null)
                SizedBox(height: config.spacing),
              
              _buildStatsLayout(config),
            ],
          ),
        ),
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      stats = MicroInteractions.slideInFade(
        child: stats,
        direction: SlideDirection.bottom,
      );
    }

    return stats;
  }

  Widget _buildHeader(MeetingStatsConfiguration config) {
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
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
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
        
        if (widget.onTap != null)
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors2025.textTertiary,
          ),
      ],
    );
  }

  Widget _buildStatsLayout(MeetingStatsConfiguration config) {
    switch (widget.layout) {
      case SherpaMeetingStatsLayout.horizontal:
        return _buildHorizontalLayout(config);
      case SherpaMeetingStatsLayout.vertical:
        return _buildVerticalLayout(config);
      case SherpaMeetingStatsLayout.grid:
        return _buildGridLayout(config);
    }
  }

  Widget _buildHorizontalLayout(MeetingStatsConfiguration config) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widget.statsItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return Expanded(
          child: AnimatedBuilder(
            animation: _itemAnimations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - _itemAnimations[index].value)),
                child: Opacity(
                  opacity: _itemAnimations[index].value,
                  child: _buildStatsItem(item, config, index),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVerticalLayout(MeetingStatsConfiguration config) {
    return Column(
      children: widget.statsItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(bottom: config.spacing),
          child: AnimatedBuilder(
            animation: _itemAnimations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(20 * (1 - _itemAnimations[index].value), 0),
                child: Opacity(
                  opacity: _itemAnimations[index].value,
                  child: _buildStatsItem(item, config, index),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridLayout(MeetingStatsConfiguration config) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: config.spacing,
        mainAxisSpacing: config.spacing,
      ),
      itemCount: widget.statsItems.length,
      itemBuilder: (context, index) {
        final item = widget.statsItems[index];
        
        return AnimatedBuilder(
          animation: _itemAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _itemAnimations[index].value,
              child: Opacity(
                opacity: _itemAnimations[index].value,
                child: _buildStatsItem(item, config, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsItem(
    SherpaStatsItem2025 item, 
    MeetingStatsConfiguration config, 
    int index,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 아이콘 + 트렌드
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: item.color ?? AppColors2025.primary,
              size: config.iconSize,
            ),
            
            if (widget.showTrends && item.trend != StatsTrend.neutral) ...[
              SizedBox(width: config.spacing * 0.25),
              _buildTrendIndicator(item.trend, config),
            ],
          ],
        ),
        
        SizedBox(height: config.spacing * 0.5),
        
        // 값
        Text(
          item.value,
          style: GoogleFonts.notoSans(
            fontSize: config.valueSize,
            fontWeight: FontWeight.w700,
            color: AppColors2025.textPrimary,
          ),
        ),
        
        SizedBox(height: config.spacing * 0.25),
        
        // 라벨
        Text(
          item.label,
          style: GoogleFonts.notoSans(
            fontSize: config.labelSize,
            color: AppColors2025.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        // 진행률 바 (선택사항)
        if (widget.showProgressBars && 
            item.maxValue != null && 
            item.currentValue != null) ...[
          SizedBox(height: config.spacing * 0.5),
          _buildProgressBar(item, config, index),
        ],
      ],
    );
  }

  Widget _buildTrendIndicator(StatsTrend trend, MeetingStatsConfiguration config) {
    IconData iconData;
    Color color;
    
    switch (trend) {
      case StatsTrend.up:
        iconData = Icons.trending_up_rounded;
        color = AppColors2025.success;
        break;
      case StatsTrend.down:
        iconData = Icons.trending_down_rounded;
        color = AppColors2025.error;
        break;
      case StatsTrend.neutral:
        iconData = Icons.trending_flat_rounded;
        color = AppColors2025.textTertiary;
        break;
    }
    
    return Icon(
      iconData,
      size: config.trendIconSize,
      color: color,
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      duration: 1500.ms,
      begin: const Offset(1, 1),
      end: const Offset(1.1, 1.1),
    );
  }

  Widget _buildProgressBar(
    SherpaStatsItem2025 item, 
    MeetingStatsConfiguration config, 
    int index,
  ) {
    return Container(
      width: config.progressBarWidth,
      height: config.progressBarHeight,
      decoration: BoxDecoration(
        color: AppColors2025.surface,
        borderRadius: BorderRadius.circular(config.progressBarHeight / 2),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimations[index],
        builder: (context, child) {
          return FractionallySizedBox(
            widthFactor: _progressAnimations[index].value,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.color ?? AppColors2025.primary,
                    (item.color ?? AppColors2025.primary).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(config.progressBarHeight / 2),
              ),
            ),
          );
        },
      ),
    );
  }

  MeetingStatsConfiguration _getStatsConfiguration() {
    switch (widget.layout) {
      case SherpaMeetingStatsLayout.horizontal:
        return MeetingStatsConfiguration(
          containerPadding: 16,
          spacing: 8,
          titleSize: 16,
          titleIconSize: 18,
          subtitleSize: 12,
          iconSize: 24,
          valueSize: 16,
          labelSize: 12,
          trendIconSize: 16,
          progressBarWidth: 40,
          progressBarHeight: 4,
        );
      case SherpaMeetingStatsLayout.vertical:
        return MeetingStatsConfiguration(
          containerPadding: 18,
          spacing: 12,
          titleSize: 18,
          titleIconSize: 20,
          subtitleSize: 14,
          iconSize: 28,
          valueSize: 18,
          labelSize: 13,
          trendIconSize: 18,
          progressBarWidth: 60,
          progressBarHeight: 6,
        );
      case SherpaMeetingStatsLayout.grid:
        return MeetingStatsConfiguration(
          containerPadding: 20,
          spacing: 10,
          titleSize: 17,
          titleIconSize: 19,
          subtitleSize: 13,
          iconSize: 26,
          valueSize: 17,
          labelSize: 12,
          trendIconSize: 17,
          progressBarWidth: 50,
          progressBarHeight: 5,
        );
    }
  }

  BoxDecoration _getContainerDecoration(MeetingStatsConfiguration config) {
    final baseColor = widget.customColor ?? 
        (widget.category != null 
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.surface);
    
    final scale = _isHovered ? 1.02 : 1.0;
    
    switch (widget.variant) {
      case SherpaMeetingStatsVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: widget.elevation,
          color: baseColor,
          borderRadius: AppSizes.radiusL,
          opacity: 0.95,
        ).copyWith(
          boxShadow: _isHovered ? [
            BoxShadow(
              color: AppColors2025.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : null,
        );

      case SherpaMeetingStatsVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: _isHovered ? GlassNeuElevation.high : widget.elevation,
          baseColor: baseColor,
          borderRadius: AppSizes.radiusL,
        );

      case SherpaMeetingStatsVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: baseColor,
          borderRadius: AppSizes.radiusL,
          glassOpacity: _isHovered ? 0.25 : 0.15,
        );

      case SherpaMeetingStatsVariant2025.minimal:
        return BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: _isHovered ? AppColors2025.primary : AppColors2025.border,
            width: _isHovered ? 2 : 1,
          ),
        );
    }
  }
}

// ==================== 모델 클래스들 ====================

class SherpaStatsItem2025 {
  final String key;
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final StatsTrend trend;
  final double? currentValue;
  final double? maxValue;
  final String? description;

  const SherpaStatsItem2025({
    required this.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.trend = StatsTrend.neutral,
    this.currentValue,
    this.maxValue,
    this.description,
  });

  SherpaStatsItem2025 copyWith({
    String? key,
    String? label,
    String? value,
    IconData? icon,
    Color? color,
    StatsTrend? trend,
    double? currentValue,
    double? maxValue,
    String? description,
  }) {
    return SherpaStatsItem2025(
      key: key ?? this.key,
      label: label ?? this.label,
      value: value ?? this.value,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      trend: trend ?? this.trend,
      currentValue: currentValue ?? this.currentValue,
      maxValue: maxValue ?? this.maxValue,
      description: description ?? this.description,
    );
  }
}

// ==================== 열거형 정의 ====================

enum SherpaMeetingStatsVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  minimal,     // 미니멀 (기본 테두리)
}

enum SherpaMeetingStatsLayout {
  horizontal,  // 가로 배치 (기본)
  vertical,    // 세로 배치
  grid,        // 그리드 배치
}

enum StatsTrend {
  up,          // 상승 트렌드
  down,        // 하락 트렌드
  neutral,     // 중립 (변화 없음)
}

// ==================== 도우미 클래스들 ====================

class MeetingStatsConfiguration {
  final double containerPadding;
  final double spacing;
  final double titleSize;
  final double titleIconSize;
  final double subtitleSize;
  final double iconSize;
  final double valueSize;
  final double labelSize;
  final double trendIconSize;
  final double progressBarWidth;
  final double progressBarHeight;

  const MeetingStatsConfiguration({
    required this.containerPadding,
    required this.spacing,
    required this.titleSize,
    required this.titleIconSize,
    required this.subtitleSize,
    required this.iconSize,
    required this.valueSize,
    required this.labelSize,
    required this.trendIconSize,
    required this.progressBarWidth,
    required this.progressBarHeight,
  });
}