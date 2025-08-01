// lib/shared/widgets/components/molecules/sherpa_create_meeting_fab_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 모임 생성 플로팅 액션 버튼
/// 그라데이션, 마이크로 인터랙션, 접근성을 고려한 모던한 FAB 디자인
class SherpaCreateMeetingFAB2025 extends StatefulWidget {
  final VoidCallback onPressed;
  final String? label;
  final IconData icon;
  final SherpaCreateMeetingFABVariant2025 variant;
  final SherpaCreateMeetingFABStyle style;
  final SherpaCreateMeetingFABSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<Color>? gradientColors;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final bool showBadge;
  final int? badgeCount;
  final String? badgeText;
  final String? tooltip;
  final bool isExtended;
  final EdgeInsetsGeometry? margin;
  final String? category;
  final bool enableGlow;
  final bool enablePulse;
  final GlassNeuElevation elevation;

  const SherpaCreateMeetingFAB2025({
    Key? key,
    required this.onPressed,
    this.label,
    this.icon = Icons.add_rounded,
    this.variant = SherpaCreateMeetingFABVariant2025.gradient,
    this.style = SherpaCreateMeetingFABStyle.standard,
    this.size = SherpaCreateMeetingFABSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.gradientColors,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.showBadge = false,
    this.badgeCount,
    this.badgeText,
    this.tooltip,
    this.isExtended = false,
    this.margin,
    this.category,
    this.enableGlow = true,
    this.enablePulse = false,
    this.elevation = GlassNeuElevation.high,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 모임 생성 FAB (그라데이션)
  factory SherpaCreateMeetingFAB2025.standard({
    Key? key,
    required VoidCallback onPressed,
    String? category,
    bool enableGlow = true,
  }) {
    return SherpaCreateMeetingFAB2025(
      key: key,
      onPressed: onPressed,
      category: category,
      enableGlow: enableGlow,
      variant: SherpaCreateMeetingFABVariant2025.gradient,
      style: SherpaCreateMeetingFABStyle.standard,
      size: SherpaCreateMeetingFABSize.medium,
      tooltip: '새 모임 만들기',
    );
  }

  /// 확장형 모임 생성 FAB (텍스트 포함)
  factory SherpaCreateMeetingFAB2025.extended({
    Key? key,
    required VoidCallback onPressed,
    String label = '모임 만들기',
    String? category,
    bool enablePulse = false,
  }) {
    return SherpaCreateMeetingFAB2025(
      key: key,
      onPressed: onPressed,
      label: label,
      category: category,
      enablePulse: enablePulse,
      isExtended: true,
      variant: SherpaCreateMeetingFABVariant2025.gradient,
      style: SherpaCreateMeetingFABStyle.extended,
      size: SherpaCreateMeetingFABSize.large,
      tooltip: label,
    );
  }

  /// 미니 모임 생성 FAB (작은 크기)
  factory SherpaCreateMeetingFAB2025.mini({
    Key? key,
    required VoidCallback onPressed,
    IconData icon = Icons.add_rounded,
    String? category,
  }) {
    return SherpaCreateMeetingFAB2025(
      key: key,
      onPressed: onPressed,
      icon: icon,
      category: category,
      variant: SherpaCreateMeetingFABVariant2025.glass,
      style: SherpaCreateMeetingFABStyle.mini,
      size: SherpaCreateMeetingFABSize.small,
      enableGlow: false,
      tooltip: '빠른 생성',
    );
  }

  /// 배지 포함 모임 생성 FAB (알림 표시)
  factory SherpaCreateMeetingFAB2025.withBadge({
    Key? key,
    required VoidCallback onPressed,
    int? badgeCount,
    String? badgeText,
    String? category,
  }) {
    return SherpaCreateMeetingFAB2025(
      key: key,
      onPressed: onPressed,
      category: category,
      showBadge: true,
      badgeCount: badgeCount,
      badgeText: badgeText,
      variant: SherpaCreateMeetingFABVariant2025.hybrid,
      style: SherpaCreateMeetingFABStyle.standard,
      size: SherpaCreateMeetingFABSize.medium,
      tooltip: '새 모임 만들기',
    );
  }

  /// 글래스 스타일 모임 생성 FAB
  factory SherpaCreateMeetingFAB2025.glass({
    Key? key,
    required VoidCallback onPressed,
    bool isExtended = false,
    String? label,
    String? category,
  }) {
    return SherpaCreateMeetingFAB2025(
      key: key,
      onPressed: onPressed,
      label: label,
      category: category,
      isExtended: isExtended,
      variant: SherpaCreateMeetingFABVariant2025.glass,
      style: isExtended 
          ? SherpaCreateMeetingFABStyle.extended 
          : SherpaCreateMeetingFABStyle.standard,
      size: SherpaCreateMeetingFABSize.medium,
      enableGlow: false,
      tooltip: label ?? '새 모임 만들기',
    );
  }

  @override
  State<SherpaCreateMeetingFAB2025> createState() => _SherpaCreateMeetingFAB2025State();
}

class _SherpaCreateMeetingFAB2025State extends State<SherpaCreateMeetingFAB2025>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: MicroInteractions.slow,
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: MicroInteractions.medium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: MicroInteractions.easeOutQuart,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: MicroInteractions.easeInOutSine,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: MicroInteractions.easeOutQuart,
    ));
    
    // 펄스 애니메이션 시작 (활성화된 경우)
    if (widget.enablePulse) {
      _pulseController.repeat(reverse: true);
    }
    
    // 글로우 애니메이션 시작
    if (widget.enableGlow) {
      _glowController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enableMicroInteractions) return;
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enableMicroInteractions) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enableMicroInteractions) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTap() {
    widget.onPressed();
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getFABConfiguration();
    
    Widget fab = AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _pulseAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            child: Container(
              width: widget.isExtended ? null : config.size,
              height: config.size,
              margin: widget.margin ?? EdgeInsets.all(AppSizes.paddingL),
              decoration: _getFABDecoration(config),
              child: _buildFABContent(config),
            ),
          ),
        );
      },
    );

    // 배지 추가
    if (widget.showBadge) {
      fab = Stack(
        children: [
          fab,
          Positioned(
            top: widget.margin?.resolve(TextDirection.ltr).top ?? AppSizes.paddingL,
            right: widget.margin?.resolve(TextDirection.ltr).right ?? AppSizes.paddingL,
            child: _buildBadge(config),
          ),
        ],
      );
    }

    // 툴팁 추가
    if (widget.tooltip != null) {
      fab = Tooltip(
        message: widget.tooltip!,
        child: fab,
      );
    }

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      fab = MicroInteractions.slideInFade(
        child: fab,
        direction: SlideDirection.bottom,
      );
    }

    return fab;
  }

  Widget _buildFABContent(FABConfiguration config) {
    final foregroundColor = widget.foregroundColor ?? AppColors2025.textOnPrimary;
    
    if (widget.isExtended && widget.label != null) {
      // 확장형 FAB (아이콘 + 텍스트)
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: config.padding,
          vertical: config.padding * 0.75,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: config.iconSize,
              color: foregroundColor,
            ),
            SizedBox(width: config.spacing),
            Text(
              widget.label!,
              style: GoogleFonts.notoSans(
                fontSize: config.textSize,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      );
    } else {
      // 기본 FAB (아이콘만)
      return Center(
        child: Icon(
          widget.icon,
          size: config.iconSize,
          color: foregroundColor,
        ),
      );
    }
  }

  Widget _buildBadge(FABConfiguration config) {
    final badgeText = widget.badgeText ?? 
        (widget.badgeCount != null ? '${widget.badgeCount}' : '!');
    
    return Container(
      padding: EdgeInsets.all(config.badgePadding),
      decoration: BoxDecoration(
        color: AppColors2025.error,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors2025.surface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors2025.error.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(
        minWidth: config.badgeSize,
        minHeight: config.badgeSize,
      ),
      child: Center(
        child: Text(
          badgeText,
          style: GoogleFonts.notoSans(
            fontSize: config.badgeTextSize,
            fontWeight: FontWeight.w700,
            color: AppColors2025.textOnPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      duration: 1500.ms,
      begin: const Offset(1, 1),
      end: const Offset(1.1, 1.1),
    );
  }

  FABConfiguration _getFABConfiguration() {
    switch (widget.size) {
      case SherpaCreateMeetingFABSize.small:
        return FABConfiguration(
          size: 48,
          iconSize: 20,
          textSize: 12,
          padding: 12,
          spacing: 6,
          badgeSize: 16,
          badgePadding: 2,
          badgeTextSize: 9,
          elevation: 4,
        );
      case SherpaCreateMeetingFABSize.medium:
        return FABConfiguration(
          size: 56,
          iconSize: 24,
          textSize: 14,
          padding: 16,
          spacing: 8,
          badgeSize: 18,
          badgePadding: 3,
          badgeTextSize: 10,
          elevation: 6,
        );
      case SherpaCreateMeetingFABSize.large:
        return FABConfiguration(
          size: 64,
          iconSize: 28,
          textSize: 16,
          padding: 20,
          spacing: 10,
          badgeSize: 20,
          badgePadding: 4,
          badgeTextSize: 11,
          elevation: 8,
        );
    }
  }

  BoxDecoration _getFABDecoration(FABConfiguration config) {
    final gradientColors = widget.gradientColors ?? [
      widget.backgroundColor ?? 
          (widget.category != null 
              ? AppColors2025.getCategoryColor2025(widget.category!)
              : AppColors2025.primary),
      widget.backgroundColor?.withOpacity(0.8) ?? 
          (widget.category != null 
              ? AppColors2025.getCategoryColor2025(widget.category!).withOpacity(0.8)
              : AppColors2025.primary.withOpacity(0.8)),
    ];

    final glowIntensity = widget.enableGlow ? _glowAnimation.value : 0.0;
    
    switch (widget.variant) {
      case SherpaCreateMeetingFABVariant2025.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(widget.isExtended 
              ? AppSizes.radiusXL 
              : config.size / 2),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3 + (glowIntensity * 0.2)),
              blurRadius: config.elevation.toDouble() + (glowIntensity * 8),
              offset: Offset(0, config.elevation / 2),
              spreadRadius: glowIntensity * 2,
            ),
            if (widget.enableGlow)
              BoxShadow(
                color: gradientColors.first.withOpacity(0.1 + (glowIntensity * 0.1)),
                blurRadius: config.elevation.toDouble() * 2 + (glowIntensity * 12),
                offset: const Offset(0, 0),
                spreadRadius: glowIntensity * 4,
              ),
          ],
        );

      case SherpaCreateMeetingFABVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: widget.elevation,
          color: gradientColors.first,
          borderRadius: widget.isExtended 
              ? AppSizes.radiusXL 
              : config.size / 2,
          opacity: 0.9,
        ).copyWith(
          boxShadow: widget.enableGlow ? [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.2 + (glowIntensity * 0.1)),
              blurRadius: config.elevation.toDouble() + (glowIntensity * 6),
              offset: Offset(0, config.elevation / 2),
            ),
          ] : null,
        );

      case SherpaCreateMeetingFABVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: widget.elevation,
          baseColor: gradientColors.first,
          borderRadius: widget.isExtended 
              ? AppSizes.radiusXL 
              : config.size / 2,
        );

      case SherpaCreateMeetingFABVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: gradientColors.first,
          borderRadius: widget.isExtended 
              ? AppSizes.radiusXL 
              : config.size / 2,
          glassOpacity: 0.2,
        ).copyWith(
          boxShadow: widget.enableGlow ? [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3 + (glowIntensity * 0.15)),
              blurRadius: config.elevation.toDouble() + (glowIntensity * 8),
              offset: Offset(0, config.elevation / 2),
              spreadRadius: glowIntensity * 1.5,
            ),
          ] : null,
        );

      case SherpaCreateMeetingFABVariant2025.minimal:
        return BoxDecoration(
          color: gradientColors.first,
          borderRadius: BorderRadius.circular(widget.isExtended 
              ? AppSizes.radiusXL 
              : config.size / 2),
          border: Border.all(
            color: AppColors2025.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: config.elevation.toDouble(),
              offset: Offset(0, config.elevation / 2),
            ),
          ],
        );
    }
  }
}

// ==================== 열거형 정의 ====================

enum SherpaCreateMeetingFABVariant2025 {
  gradient,    // 그라데이션 (기본)
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  minimal,     // 미니멀 (기본 스타일)
}

enum SherpaCreateMeetingFABStyle {
  standard,    // 기본 원형
  extended,    // 확장형 (텍스트 포함)
  mini,        // 미니 크기
}

enum SherpaCreateMeetingFABSize {
  small,       // 48px
  medium,      // 56px (기본)
  large,       // 64px
}

// ==================== 도우미 클래스들 ====================

class FABConfiguration {
  final double size;
  final double iconSize;
  final double textSize;
  final double padding;
  final double spacing;
  final double badgeSize;
  final double badgePadding;
  final double badgeTextSize;
  final int elevation;

  const FABConfiguration({
    required this.size,
    required this.iconSize,
    required this.textSize,
    required this.padding,
    required this.spacing,
    required this.badgeSize,
    required this.badgePadding,
    required this.badgeTextSize,
    required this.elevation,
  });
}