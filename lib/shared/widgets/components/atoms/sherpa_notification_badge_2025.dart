// lib/shared/widgets/components/atoms/sherpa_notification_badge_2025.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 뱃지 컴포넌트
/// 알림, 상태, 카운트 등을 표시하는 다양한 스타일의 뱃지
class SherpaNotificationBadge2025 extends StatefulWidget {
  final String? text;
  final int? count;
  final Widget? child;
  final SherpaNotificationBadgeVariant2025 variant;
  final SherpaNotificationBadgeSize2025 size;
  final SherpaNotificationBadgeType type;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showBadge;
  final String? category;
  final Color? customColor;
  final bool enableMicroInteractions;
  final bool enableAnimation;
  final SherpaNotificationBadgePosition position;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool enableHapticFeedback;
  final double? maxWidth;
  final bool showShadow;
  final Gradient? gradient;

  const SherpaNotificationBadge2025({
    Key? key,
    this.text,
    this.count,
    this.child,
    this.variant = SherpaNotificationBadgeVariant2025.dot,
    this.size = SherpaNotificationBadgeSize2025.medium,
    this.type = SherpaNotificationBadgeType.notification,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.margin,
    this.showBadge = true,
    this.category,
    this.customColor,
    this.enableMicroInteractions = true,
    this.enableAnimation = true,
    this.position = SherpaNotificationBadgePosition.topRight,
    this.icon,
    this.onTap,
    this.enableHapticFeedback = true,
    this.maxWidth,
    this.showShadow = false,
    this.gradient,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 알림 뱃지 (빨간 점)
  factory SherpaNotificationBadge2025.notification({
    Key? key,
    required Widget child,
    bool showBadge = true,
    SherpaNotificationBadgePosition position = SherpaNotificationBadgePosition.topRight,
  }) {
    return SherpaNotificationBadge2025(
      key: key,
      child: child,
      showBadge: showBadge,
      position: position,
      variant: SherpaNotificationBadgeVariant2025.dot,
      type: SherpaNotificationBadgeType.notification,
      backgroundColor: AppColors2025.error,
    );
  }

  /// 카운트 뱃지 (숫자 표시)
  factory SherpaNotificationBadge2025.count({
    Key? key,
    required Widget child,
    required int count,
    int maxCount = 99,
    SherpaNotificationBadgePosition position = SherpaNotificationBadgePosition.topRight,
    String? category,
  }) {
    return SherpaNotificationBadge2025(
      key: key,
      child: child,
      count: count > maxCount ? maxCount : count,
      text: count > maxCount ? '$maxCount+' : count.toString(),
      showBadge: count > 0,
      position: position,
      category: category,
      variant: SherpaNotificationBadgeVariant2025.count,
      type: SherpaNotificationBadgeType.notification,
    );
  }

  /// 상태 뱃지 (텍스트 표시)
  factory SherpaNotificationBadge2025.status({
    Key? key,
    required String text,
    SherpaNotificationBadgeType type = SherpaNotificationBadgeType.success,
    String? category,
    Widget? icon,
    VoidCallback? onTap,
  }) {
    return SherpaNotificationBadge2025(
      key: key,
      text: text,
      type: type,
      category: category,
      icon: icon,
      onTap: onTap,
      variant: SherpaNotificationBadgeVariant2025.pill,
      size: SherpaNotificationBadgeSize2025.small,
    );
  }

  /// 태그 뱃지 (칩 형태)
  factory SherpaNotificationBadge2025.tag({
    Key? key,
    required String text,
    String? category,
    Widget? icon,
    VoidCallback? onTap,
    bool showShadow = true,
  }) {
    return SherpaNotificationBadge2025(
      key: key,
      text: text,
      category: category,
      icon: icon,
      onTap: onTap,
      showShadow: showShadow,
      variant: SherpaNotificationBadgeVariant2025.chip,
      type: SherpaNotificationBadgeType.info,
    );
  }

  /// 레벨 뱃지 (게임 레벨)
  factory SherpaNotificationBadge2025.level({
    Key? key,
    required int level,
    String? category,
    Gradient? gradient,
  }) {
    return SherpaNotificationBadge2025(
      key: key,
      text: 'Lv.$level',
      category: category,
      gradient: gradient,
      variant: SherpaNotificationBadgeVariant2025.diamond,
      type: SherpaNotificationBadgeType.special,
      showShadow: true,
    );
  }

  /// 새 항목 뱃지
  factory SherpaNotificationBadge2025.newItem({
    Key? key,
    required Widget child,
    SherpaNotificationBadgePosition position = SherpaNotificationBadgePosition.topRight,
  }) {
    return SherpaNotificationBadge2025(
      key: key,
      child: child,
      text: 'NEW',
      position: position,
      variant: SherpaNotificationBadgeVariant2025.pill,
      type: SherpaNotificationBadgeType.special,
      size: SherpaNotificationBadgeSize2025.small,
      backgroundColor: AppColors2025.success,
    );
  }

  /// 온라인 상태 뱃지
  factory SherpaNotificationBadge2025.online({
    Key? key,
    required Widget child,
    bool isOnline = true,
    SherpaNotificationBadgePosition position = SherpaNotificationBadgePosition.bottomRight,
  }) {
    return SherpaNotificationBadge2025(
      key: key,
      child: child,
      showBadge: true,
      position: position,
      variant: SherpaNotificationBadgeVariant2025.dot,
      type: SherpaNotificationBadgeType.status,
      backgroundColor: isOnline ? AppColors2025.success : AppColors2025.textQuaternary,
      size: SherpaNotificationBadgeSize2025.small,
    );
  }

  @override
  State<SherpaNotificationBadge2025> createState() => _SherpaNotificationBadge2025State();
}

class _SherpaNotificationBadge2025State extends State<SherpaNotificationBadge2025>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: MicroInteractions.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableAnimation && widget.showBadge) {
      _scaleController.forward();
    }

    if (widget.type == SherpaNotificationBadgeType.notification && widget.enableAnimation) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SherpaNotificationBadge2025 oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.showBadge != widget.showBadge) {
      if (widget.showBadge && widget.enableAnimation) {
        _scaleController.forward();
        if (widget.type == SherpaNotificationBadgeType.notification) {
          _pulseController.repeat(reverse: true);
        }
      } else {
        _scaleController.reverse();
        _pulseController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return _buildBadgeWithChild();
    } else {
      return _buildStandaloneBadge();
    }
  }

  Widget _buildBadgeWithChild() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child!,
        if (widget.showBadge) _buildPositionedBadge(),
      ],
    );
  }

  Widget _buildPositionedBadge() {
    final config = _getBadgeConfiguration();
    final badge = _buildBadgeContent(config);

    return Positioned(
      top: _getPositionTop(config),
      right: _getPositionRight(config),
      bottom: _getPositionBottom(config),
      left: _getPositionLeft(config),
      child: badge,
    );
  }

  Widget _buildStandaloneBadge() {
    final config = _getBadgeConfiguration();
    return Container(
      margin: widget.margin,
      child: _buildBadgeContent(config),
    );
  }

  Widget _buildBadgeContent(BadgeConfiguration config) {
    Widget badge = Container(
      constraints: BoxConstraints(
        minWidth: config.minSize,
        minHeight: config.minSize,
        maxWidth: widget.maxWidth ?? double.infinity,
      ),
      padding: widget.padding ?? config.padding,
      decoration: _getDecoration(config),
      child: _buildBadgeChild(config),
    );

    // 애니메이션 적용
    if (widget.enableAnimation) {
      badge = AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * 
                   (widget.type == SherpaNotificationBadgeType.notification 
                       ? _pulseAnimation.value 
                       : 1.0),
            child: child,
          );
        },
        child: badge,
      );
    }

    // 인터랙티브 래퍼 추가
    if (widget.onTap != null) {
      badge = GestureDetector(
        onTap: widget.onTap,
        child: badge,
      );
    }

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions && widget.onTap != null) {
      badge = MicroInteractions.tapResponse(
        onTap: widget.onTap,
        enableHaptic: widget.enableHapticFeedback,
        child: badge,
      );
    }

    return badge;
  }

  Widget _buildBadgeChild(BadgeConfiguration config) {
    switch (widget.variant) {
      case SherpaNotificationBadgeVariant2025.dot:
        return const SizedBox.shrink();
        
      case SherpaNotificationBadgeVariant2025.count:
      case SherpaNotificationBadgeVariant2025.pill:
      case SherpaNotificationBadgeVariant2025.chip:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[ 
              IconTheme(
                data: IconThemeData(
                  color: config.textColor,
                  size: config.iconSize,
                ),
                child: widget.icon!,
              ),
              if (widget.text != null && widget.text!.isNotEmpty)
                SizedBox(width: config.spacing),
            ],
            if (widget.text != null && widget.text!.isNotEmpty)
              Flexible(
                child: Text(
                  widget.text!,
                  style: GoogleFonts.notoSans(
                    fontSize: config.fontSize,
                    fontWeight: FontWeight.w700,
                    color: config.textColor,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
        
      case SherpaNotificationBadgeVariant2025.diamond:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            widget.text ?? '',
            style: GoogleFonts.notoSans(
              fontSize: config.fontSize,
              fontWeight: FontWeight.w800,
              color: config.textColor,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
    }
  }

  double? _getPositionTop(BadgeConfiguration config) {
    switch (widget.position) {
      case SherpaNotificationBadgePosition.topLeft:
      case SherpaNotificationBadgePosition.topRight:
        return -config.positionOffset;
      case SherpaNotificationBadgePosition.bottomLeft:
      case SherpaNotificationBadgePosition.bottomRight:
        return null;
    }
  }

  double? _getPositionRight(BadgeConfiguration config) {
    switch (widget.position) {
      case SherpaNotificationBadgePosition.topRight:
      case SherpaNotificationBadgePosition.bottomRight:
        return -config.positionOffset;
      case SherpaNotificationBadgePosition.topLeft:
      case SherpaNotificationBadgePosition.bottomLeft:
        return null;
    }
  }

  double? _getPositionBottom(BadgeConfiguration config) {
    switch (widget.position) {
      case SherpaNotificationBadgePosition.bottomLeft:
      case SherpaNotificationBadgePosition.bottomRight:
        return -config.positionOffset;
      case SherpaNotificationBadgePosition.topLeft:
      case SherpaNotificationBadgePosition.topRight:
        return null;
    }
  }

  double? _getPositionLeft(BadgeConfiguration config) {
    switch (widget.position) {
      case SherpaNotificationBadgePosition.topLeft:
      case SherpaNotificationBadgePosition.bottomLeft:
        return -config.positionOffset;
      case SherpaNotificationBadgePosition.topRight:
      case SherpaNotificationBadgePosition.bottomRight:
        return null;
    }
  }

  BadgeConfiguration _getBadgeConfiguration() {
    final color = widget.customColor ??
        widget.backgroundColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : _getTypeColor());

    final textColor = widget.textColor ?? _getTextColor(color);

    switch (widget.size) {
      case SherpaNotificationBadgeSize2025.small:
        return BadgeConfiguration(
          minSize: widget.variant == SherpaNotificationBadgeVariant2025.dot ? 8 : 16,
          fontSize: 10,
          iconSize: 12,
          borderRadius: _getBorderRadius(),
          padding: _getPadding(),
          positionOffset: 4,
          spacing: 2,
          backgroundColor: color,
          textColor: textColor,
        );
      case SherpaNotificationBadgeSize2025.medium:
        return BadgeConfiguration(
          minSize: widget.variant == SherpaNotificationBadgeVariant2025.dot ? 12 : 20,
          fontSize: 12,
          iconSize: 14,
          borderRadius: _getBorderRadius(),
          padding: _getPadding(),
          positionOffset: 6,
          spacing: 4,
          backgroundColor: color,
          textColor: textColor,
        );
      case SherpaNotificationBadgeSize2025.large:
        return BadgeConfiguration(
          minSize: widget.variant == SherpaNotificationBadgeVariant2025.dot ? 16 : 24,
          fontSize: 14,
          iconSize: 16,
          borderRadius: _getBorderRadius(),
          padding: _getPadding(),
          positionOffset: 8,
          spacing: 6,
          backgroundColor: color,
          textColor: textColor,
        );
    }
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case SherpaNotificationBadgeType.notification:
        return AppColors2025.error;
      case SherpaNotificationBadgeType.success:
        return AppColors2025.success;
      case SherpaNotificationBadgeType.warning:
        return AppColors2025.warning;
      case SherpaNotificationBadgeType.error:
        return AppColors2025.error;
      case SherpaNotificationBadgeType.info:
        return AppColors2025.info;
      case SherpaNotificationBadgeType.status:
        return AppColors2025.primary;
      case SherpaNotificationBadgeType.special:
        return AppColors2025.primaryDark;
    }
  }

  Color _getTextColor(Color backgroundColor) {
    // 배경색의 밝기에 따라 텍스트 색상 결정
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors2025.textPrimary : AppColors2025.textOnPrimary;
  }

  double _getBorderRadius() {
    switch (widget.variant) {
      case SherpaNotificationBadgeVariant2025.dot:
        return 50; // 완전한 원
      case SherpaNotificationBadgeVariant2025.count:
        return 12;
      case SherpaNotificationBadgeVariant2025.pill:
        return 50; // 완전한 둥근 모서리
      case SherpaNotificationBadgeVariant2025.chip:
        return AppSizes.radiusM;
      case SherpaNotificationBadgeVariant2025.diamond:
        return AppSizes.radiusS;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.variant) {
      case SherpaNotificationBadgeVariant2025.dot:
        return EdgeInsets.zero;
      case SherpaNotificationBadgeVariant2025.count:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case SherpaNotificationBadgeVariant2025.pill:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case SherpaNotificationBadgeVariant2025.chip:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case SherpaNotificationBadgeVariant2025.diamond:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    }
  }

  BoxDecoration _getDecoration(BadgeConfiguration config) {
    BoxDecoration decoration;

    if (widget.gradient != null) {
      decoration = BoxDecoration(
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(config.borderRadius),
      );
    } else {
      switch (widget.variant) {
        case SherpaNotificationBadgeVariant2025.dot:
        case SherpaNotificationBadgeVariant2025.count:
          decoration = BoxDecoration(
            color: config.backgroundColor,
            borderRadius: BorderRadius.circular(config.borderRadius),
            border: Border.all(
              color: AppColors2025.surface,
              width: 1.5,
            ),
          );
          break;
        case SherpaNotificationBadgeVariant2025.pill:
          decoration = GlassNeuStyle.glassMorphism(
            elevation: GlassNeuElevation.medium,
            color: config.backgroundColor,
            borderRadius: config.borderRadius,
            opacity: 0.9,
          );
          break;
        case SherpaNotificationBadgeVariant2025.chip:
          decoration = GlassNeuStyle.softNeumorphism(
            baseColor: config.backgroundColor,
            borderRadius: config.borderRadius,
            intensity: 0.05,
          );
          break;
        case SherpaNotificationBadgeVariant2025.diamond:
          decoration = GlassNeuStyle.hybrid(
            elevation: GlassNeuElevation.high,
            color: config.backgroundColor,
            borderRadius: config.borderRadius,
            glassOpacity: 0.2,
          );
          break;
      }
    }

    // 그림자 추가
    if (widget.showShadow) {
      decoration = decoration.copyWith(
        boxShadow: [
          BoxShadow(
            color: config.backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    return decoration;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

// ==================== 열거형 정의 ====================

enum SherpaNotificationBadgeVariant2025 {
  dot,          // 작은 점 (알림 표시)
  count,        // 카운트 뱃지 (숫자)
  pill,         // 알약 형태 (텍스트)
  chip,         // 칩 형태 (아이콘 + 텍스트)
  diamond,      // 다이아몬드 형태 (특별한 뱃지)
}

enum SherpaNotificationBadgeSize2025 {
  small,        // 작은 크기
  medium,       // 중간 크기
  large,        // 큰 크기
}

enum SherpaNotificationBadgeType {
  notification, // 알림 (빨간색)
  success,      // 성공 (초록색)
  warning,      // 경고 (노란색)
  error,        // 오류 (빨간색)
  info,         // 정보 (파란색)
  status,       // 상태 (기본색)
  special,      // 특별 (보라색)
}

enum SherpaNotificationBadgePosition {
  topLeft,      // 왼쪽 위
  topRight,     // 오른쪽 위
  bottomLeft,   // 왼쪽 아래
  bottomRight,  // 오른쪽 아래
}

// ==================== 도우미 클래스들 ====================

class BadgeConfiguration {
  final double minSize;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double positionOffset;
  final double spacing;
  final Color backgroundColor;
  final Color textColor;

  const BadgeConfiguration({
    required this.minSize,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
    required this.padding,
    required this.positionOffset,
    required this.spacing,
    required this.backgroundColor,
    required this.textColor,
  });
}