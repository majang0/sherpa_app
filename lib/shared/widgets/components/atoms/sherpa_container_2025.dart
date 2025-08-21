// lib/shared/widgets/components/atoms/sherpa_container_2025.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 컨테이너 컴포넌트
/// 글래스모피즘, 뉴모피즘, 반응형 디자인을 지원하는 범용 컨테이너
class SherpaContainer2025 extends StatefulWidget {
  final Widget child;
  final SherpaContainerVariant2025 variant;
  final SherpaContainerSize2025 size;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool enabled;
  final String? category;
  final Color? customColor;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final GlassNeuElevation elevation;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;
  final bool clipBehavior;
  final BoxConstraints? constraints;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;

  const SherpaContainer2025({
    Key? key,
    required this.child,
    this.variant = SherpaContainerVariant2025.glass,
    this.size = SherpaContainerSize2025.medium,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.onTap,
    this.enabled = true,
    this.category,
    this.customColor,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.elevation = GlassNeuElevation.medium,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.alignment,
    this.clipBehavior = true,
    this.constraints,
    this.transform,
    this.transformAlignment,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 컨테이너 (글래스 스타일)
  factory SherpaContainer2025.basic({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    String? category,
  }) {
    return SherpaContainer2025(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      onTap: onTap,
      category: category,
      variant: SherpaContainerVariant2025.glass,
      size: SherpaContainerSize2025.medium,
    );
  }

  /// 카드 형태 컨테이너
  factory SherpaContainer2025.card({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    String? category,
    SherpaContainerSize2025 size = SherpaContainerSize2025.medium,
  }) {
    return SherpaContainer2025(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.all(8),
      onTap: onTap,
      category: category,
      variant: SherpaContainerVariant2025.glass,
      size: size,
      elevation: GlassNeuElevation.medium,
    );
  }

  /// 플로팅 컨테이너 (강한 그림자)
  factory SherpaContainer2025.floating({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    String? category,
  }) {
    return SherpaContainer2025(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin ?? const EdgeInsets.all(12),
      onTap: onTap,
      category: category,
      variant: SherpaContainerVariant2025.floating,
      elevation: GlassNeuElevation.high,
    );
  }

  /// 뉴모피즘 컨테이너
  factory SherpaContainer2025.neu({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return SherpaContainer2025(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.all(8),
      onTap: onTap,
      backgroundColor: backgroundColor,
      variant: SherpaContainerVariant2025.neu,
      elevation: GlassNeuElevation.medium,
    );
  }

  /// 하이브리드 컨테이너 (글래스 + 뉴모피즘)
  factory SherpaContainer2025.hybrid({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    String? category,
  }) {
    return SherpaContainer2025(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(18),
      margin: margin ?? const EdgeInsets.all(10),
      onTap: onTap,
      category: category,
      variant: SherpaContainerVariant2025.hybrid,
      elevation: GlassNeuElevation.medium,
    );
  }

  /// 그라데이션 컨테이너
  factory SherpaContainer2025.gradient({
    Key? key,
    required Widget child,
    required Gradient gradient,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return SherpaContainer2025(
      key: key,
      child: child,
      gradient: gradient,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.all(8),
      onTap: onTap,
      variant: SherpaContainerVariant2025.gradient,
    );
  }

  /// 소프트 컨테이너 (부드러운 뉴모피즘)
  factory SherpaContainer2025.soft({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return SherpaContainer2025(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.all(8),
      onTap: onTap,
      backgroundColor: backgroundColor,
      variant: SherpaContainerVariant2025.soft,
      elevation: GlassNeuElevation.low,
    );
  }

  /// 투명 컨테이너 (배경 없음)
  factory SherpaContainer2025.transparent({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Border? border,
  }) {
    return SherpaContainer2025(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      onTap: onTap,
      border: border,
      variant: SherpaContainerVariant2025.transparent,
    );
  }

  /// 아웃라인 컨테이너 (테두리만)
  factory SherpaContainer2025.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color? borderColor,
    String? category,
  }) {
    return SherpaContainer2025(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.all(8),
      onTap: onTap,
      borderColor: borderColor,
      category: category,
      variant: SherpaContainerVariant2025.outlined,
    );
  }

  @override
  State<SherpaContainer2025> createState() => _SherpaContainer2025State();
}

class _SherpaContainer2025State extends State<SherpaContainer2025>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.onTap == null) return;
    
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.onTap == null) return;
    
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled || widget.onTap == null) return;
    
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getContainerConfiguration();
    
    Widget container = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      alignment: widget.alignment,
      constraints: widget.constraints,
      transform: widget.transform,
      transformAlignment: widget.transformAlignment,
      decoration: _getDecoration(config),
      clipBehavior: widget.clipBehavior ? Clip.antiAlias : Clip.none,
      child: Padding(
        padding: widget.padding ?? config.defaultPadding,
        child: widget.child,
      ),
    );

    // 인터랙티브 래퍼 추가
    if (widget.onTap != null && widget.enabled) {
      container = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: container,
      );

      // 마이크로 인터랙션 적용
      if (widget.enableMicroInteractions) {
        switch (widget.variant) {
          case SherpaContainerVariant2025.floating:
            container = MicroInteractions.hoverEffect(
              scaleUpTo: 1.02,
              elevationIncrease: 4,
              child: container,
            );
            break;
          case SherpaContainerVariant2025.glass:
          case SherpaContainerVariant2025.hybrid:
            container = MicroInteractions.buttonPress(
              onPressed: widget.onTap,
              glowColor: config.color,
              isPressed: _isPressed,
              child: container,
            );
            break;
          default:
            container = MicroInteractions.tapResponse(
              onTap: widget.onTap,
              enableHaptic: widget.enableHapticFeedback,
              child: container,
            );
        }
      }
    }

    return container;
  }

  ContainerConfiguration _getContainerConfiguration() {
    final color = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    switch (widget.size) {
      case SherpaContainerSize2025.small:
        return ContainerConfiguration(
          defaultPadding: const EdgeInsets.all(12),
          borderRadius: AppSizes.radiusS,
          color: color,
        );
      case SherpaContainerSize2025.medium:
        return ContainerConfiguration(
          defaultPadding: const EdgeInsets.all(16),
          borderRadius: AppSizes.radiusM,
          color: color,
        );
      case SherpaContainerSize2025.large:
        return ContainerConfiguration(
          defaultPadding: const EdgeInsets.all(20),
          borderRadius: AppSizes.radiusL,
          color: color,
        );
      case SherpaContainerSize2025.extraLarge:
        return ContainerConfiguration(
          defaultPadding: const EdgeInsets.all(24),
          borderRadius: AppSizes.radiusXL,
          color: color,
        );
    }
  }

  BoxDecoration _getDecoration(ContainerConfiguration config) {
    final borderRadius = widget.borderRadius ?? config.borderRadius;

    // 커스텀 데코레이션이 있는 경우
    if (widget.boxShadow != null || widget.border != null) {
      return BoxDecoration(
        color: widget.backgroundColor ?? AppColors2025.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: widget.border,
        boxShadow: widget.boxShadow,
        gradient: widget.gradient,
      );
    }

    switch (widget.variant) {
      case SherpaContainerVariant2025.glass:
        return widget.category != null
            ? GlassNeuStyle.glassByCategory(
                widget.category!,
                elevation: widget.elevation,
                borderRadius: borderRadius,
              )
            : GlassNeuStyle.glassMorphism(
                elevation: widget.elevation,
                color: config.color,
                borderRadius: borderRadius,
                opacity: 0.15,
              );

      case SherpaContainerVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: widget.elevation,
          baseColor: widget.backgroundColor ?? AppColors2025.neuBase,
          borderRadius: borderRadius,
          isPressed: _isPressed,
        );

      case SherpaContainerVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.color,
          borderRadius: borderRadius,
          elevation: 16,
        );

      case SherpaContainerVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: config.color,
          borderRadius: borderRadius,
          glassOpacity: 0.15,
          isPressed: _isPressed,
        );

      case SherpaContainerVariant2025.soft:
        return GlassNeuStyle.softNeumorphism(
          baseColor: widget.backgroundColor ?? AppColors2025.neuBaseSoft,
          borderRadius: borderRadius,
          intensity: 0.05,
        );

      case SherpaContainerVariant2025.gradient:
        return widget.gradient != null
            ? GlassNeuStyle.gradientGlass(
                gradient: widget.gradient!,
                borderRadius: borderRadius,
                elevation: widget.elevation,
              )
            : BoxDecoration(
                gradient: AppColors2025.primaryGradient2025,
                borderRadius: BorderRadius.circular(borderRadius),
              );

      case SherpaContainerVariant2025.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: widget.borderColor ?? config.color,
            width: 2,
          ),
        );

      case SherpaContainerVariant2025.solid:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors2025.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors2025.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case SherpaContainerVariant2025.transparent:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: widget.border,
        );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// ==================== 열거형 정의 ====================

enum SherpaContainerVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  floating,    // 플로팅 글래스
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  soft,        // 소프트 뉴모피즘
  gradient,    // 그라데이션
  outlined,    // 아웃라인 (테두리만)
  solid,       // 솔리드 (전통적)
  transparent, // 투명
}

enum SherpaContainerSize2025 {
  small,       // 작은 패딩/반지름
  medium,      // 중간 패딩/반지름
  large,       // 큰 패딩/반지름
  extraLarge,  // 매우 큰 패딩/반지름
}

// ==================== 도우미 클래스들 ====================

class ContainerConfiguration {
  final EdgeInsetsGeometry defaultPadding;
  final double borderRadius;
  final Color color;

  const ContainerConfiguration({
    required this.defaultPadding,
    required this.borderRadius,
    required this.color,
  });
}