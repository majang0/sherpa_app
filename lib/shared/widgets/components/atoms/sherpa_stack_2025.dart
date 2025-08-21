// lib/shared/widgets/components/atoms/sherpa_stack_2025.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 스택 컴포넌트
/// 레이어 관리, 깊이 표현, 인터랙티브 요소 배치를 지원
class SherpaStack2025 extends StatefulWidget {
  final List<Widget> children;
  final SherpaStackVariant2025 variant;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit fit;
  final Clip clipBehavior;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? category;
  final Color? customColor;
  final bool enableMicroInteractions;
  final bool enableParallax;
  final bool enableDepthEffect;
  final GlassNeuElevation elevation;
  final List<SherpaStackLayer>? layers;
  final bool interactive;
  final VoidCallback? onTap;
  final bool enableHapticFeedback;

  const SherpaStack2025({
    Key? key,
    required this.children,
    this.variant = SherpaStackVariant2025.standard,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.category,
    this.customColor,
    this.enableMicroInteractions = true,
    this.enableParallax = false,
    this.enableDepthEffect = false,
    this.elevation = GlassNeuElevation.medium,
    this.layers,
    this.interactive = false,
    this.onTap,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 스택 (표준 레이어링)
  factory SherpaStack2025.basic({
    Key? key,
    required List<Widget> children,
    AlignmentGeometry alignment = Alignment.center,
    String? category,
  }) {
    return SherpaStack2025(
      key: key,
      children: children,
      alignment: alignment,
      category: category,
      variant: SherpaStackVariant2025.standard,
    );
  }

  /// 카드 스택 (깊이 효과)
  factory SherpaStack2025.cards({
    Key? key,
    required List<Widget> children,
    AlignmentGeometry alignment = Alignment.center,
    String? category,
    bool enableDepthEffect = true,
  }) {
    return SherpaStack2025(
      key: key,
      children: children,
      alignment: alignment,
      category: category,
      variant: SherpaStackVariant2025.cards,
      enableDepthEffect: enableDepthEffect,
      elevation: GlassNeuElevation.high,
    );
  }

  /// 레이어드 스택 (다중 레이어)
  factory SherpaStack2025.layered({
    Key? key,
    required List<SherpaStackLayer> layers,
    String? category,
    bool enableParallax = true,
  }) {
    return SherpaStack2025(
      key: key,
      children: layers.map((layer) => layer.child).toList(),
      layers: layers,
      category: category,
      variant: SherpaStackVariant2025.layered,
      enableParallax: enableParallax,
      enableDepthEffect: true,
    );
  }

  /// 플로팅 스택 (부유 효과)
  factory SherpaStack2025.floating({
    Key? key,
    required List<Widget> children,
    AlignmentGeometry alignment = Alignment.center,
    String? category,
    EdgeInsetsGeometry? padding,
  }) {
    return SherpaStack2025(
      key: key,
      children: children,
      alignment: alignment,
      category: category,
      padding: padding ?? const EdgeInsets.all(20),
      variant: SherpaStackVariant2025.floating,
      elevation: GlassNeuElevation.extraHigh,
      enableDepthEffect: true,
    );
  }

  /// 인터랙티브 스택 (터치 반응)
  factory SherpaStack2025.interactive({
    Key? key,
    required List<Widget> children,
    required VoidCallback onTap,
    AlignmentGeometry alignment = Alignment.center,
    String? category,
  }) {
    return SherpaStack2025(
      key: key,
      children: children,
      alignment: alignment,
      category: category,
      onTap: onTap,
      variant: SherpaStackVariant2025.interactive,
      interactive: true,
      enableDepthEffect: true,
    );
  }

  /// 오버레이 스택 (배경 + 오버레이)
  factory SherpaStack2025.overlay({
    Key? key,
    required Widget background,
    required Widget overlay,
    AlignmentGeometry overlayAlignment = Alignment.center,
    String? category,
  }) {
    return SherpaStack2025(
      key: key,
      children: [background, overlay],
      alignment: overlayAlignment,
      category: category,
      variant: SherpaStackVariant2025.overlay,
      fit: StackFit.expand,
    );
  }

  /// 글래스 스택 (글래스모피즘 레이어)
  factory SherpaStack2025.glass({
    Key? key,
    required List<Widget> children,
    AlignmentGeometry alignment = Alignment.center,
    String? category,
    EdgeInsetsGeometry? padding,
  }) {
    return SherpaStack2025(
      key: key,
      children: children,
      alignment: alignment,
      category: category,
      padding: padding ?? const EdgeInsets.all(16),
      variant: SherpaStackVariant2025.glass,
      elevation: GlassNeuElevation.medium,
    );
  }

  @override
  State<SherpaStack2025> createState() => _SherpaStack2025State();
}

class _SherpaStack2025State extends State<SherpaStack2025>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _parallaxController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;
  Offset _pointerPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );
    
    _parallaxController = AnimationController(
      duration: MicroInteractions.slow,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: MicroInteractions.easeOutQuart,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: MicroInteractions.easeOutQuart,
    ));
  }

  void _handlePointerMove(PointerEvent details) {
    if (!widget.enableParallax) return;
    
    setState(() {
      _pointerPosition = details.localPosition;
    });
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.interactive) return;
    
    setState(() => _isPressed = true);
    _hoverController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.interactive) return;
    
    setState(() => _isPressed = false);
    _hoverController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!widget.interactive) return;
    
    setState(() => _isPressed = false);
    _hoverController.reverse();
  }

  void _handleHoverEnter() {
    setState(() => _isHovered = true);
    if (widget.enableMicroInteractions) {
      _hoverController.forward();
    }
  }

  void _handleHoverExit() {
    setState(() => _isHovered = false);
    if (widget.enableMicroInteractions) {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getStackConfiguration();
    
    Widget stack = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding,
      decoration: _getDecoration(config),
      child: _buildStackContent(config),
    );

    // 인터랙티브 래퍼 추가
    if (widget.interactive || widget.enableMicroInteractions) {
      stack = MouseRegion(
        onEnter: (_) => _handleHoverEnter(),
        onExit: (_) => _handleHoverExit(),
        child: GestureDetector(
          onTapDown: widget.interactive ? _handleTapDown : null,
          onTapUp: widget.interactive ? _handleTapUp : null,
          onTapCancel: widget.interactive ? _handleTapCancel : null,
          child: stack,
        ),
      );
    }

    // 패럴랙스 효과 추가
    if (widget.enableParallax) {
      stack = Listener(
        onPointerMove: _handlePointerMove,
        child: stack,
      );
    }

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      stack = AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: widget.enableDepthEffect
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors2025.shadowLight,
                          blurRadius: 4 + _elevationAnimation.value,
                          offset: Offset(0, 2 + _elevationAnimation.value / 2),
                        ),
                      ],
                    )
                  : null,
              child: child,
            ),
          );
        },
        child: stack,
      );
    }

    return ClipRect(
      clipBehavior: widget.clipBehavior,
      child: stack,
    );
  }

  Widget _buildStackContent(StackConfiguration config) {
    if (widget.layers != null) {
      return _buildLayeredStack(config);
    }

    return Stack(
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      fit: widget.fit,
      clipBehavior: widget.clipBehavior,
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return _wrapChild(child, index, config);
      }).toList(),
    );
  }

  Widget _buildLayeredStack(StackConfiguration config) {
    return Stack(
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      fit: widget.fit,
      clipBehavior: widget.clipBehavior,
      children: widget.layers!.asMap().entries.map((entry) {
        final index = entry.key;
        final layer = entry.value;
        return _buildLayerChild(layer, index, config);
      }).toList(),
    );
  }

  Widget _buildLayerChild(SherpaStackLayer layer, int index, StackConfiguration config) {
    Widget child = layer.child;

    // 패럴랙스 효과 적용
    if (widget.enableParallax && layer.parallaxStrength > 0) {
      final parallaxOffset = Offset(
        (_pointerPosition.dx - 150) * layer.parallaxStrength * 0.01,
        (_pointerPosition.dy - 150) * layer.parallaxStrength * 0.01,
      );
      
      child = Transform.translate(
        offset: parallaxOffset,
        child: child,
      );
    }

    // 깊이 효과 적용
    if (widget.enableDepthEffect && layer.elevation > 0) {
      child = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors2025.shadowLight,
              blurRadius: layer.elevation,
              offset: Offset(0, layer.elevation / 2),
            ),
          ],
        ),
        child: child,
      );
    }

    // 레이어 위치 설정
    if (layer.positioned != null) {
      return Positioned(
        top: layer.positioned!.top,
        right: layer.positioned!.right,
        bottom: layer.positioned!.bottom,
        left: layer.positioned!.left,
        width: layer.positioned!.width,
        height: layer.positioned!.height,
        child: child,
      );
    }

    return child;
  }

  Widget _wrapChild(Widget child, int index, StackConfiguration config) {
    if (widget.variant == SherpaStackVariant2025.cards) {
      // 카드 스타일링 적용
      final offset = index * 2.0;
      return Transform.translate(
        offset: Offset(offset, offset),
        child: Container(
          decoration: GlassNeuStyle.glassMorphism(
            elevation: widget.elevation,
            color: config.color,
            borderRadius: AppSizes.radiusM,
            opacity: 0.15 - (index * 0.02),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: child,
          ),
        ),
      );
    }

    if (widget.variant == SherpaStackVariant2025.floating && index > 0) {
      // 플로팅 효과 적용
      return Container(
        decoration: GlassNeuStyle.floatingGlass(
          color: config.color,
          borderRadius: AppSizes.radiusL,
          elevation: 12 + (index * 4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: child,
        ),
      );
    }

    return child;
  }

  StackConfiguration _getStackConfiguration() {
    final color = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    return StackConfiguration(
      color: color,
    );
  }

  BoxDecoration? _getDecoration(StackConfiguration config) {
    switch (widget.variant) {
      case SherpaStackVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: widget.elevation,
          color: config.color,
          borderRadius: AppSizes.radiusM,
          opacity: 0.15,
        );

      case SherpaStackVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.color,
          borderRadius: AppSizes.radiusL,
          elevation: 16,
        );

      case SherpaStackVariant2025.layered:
        return widget.enableDepthEffect
            ? BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors2025.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null;

      case SherpaStackVariant2025.interactive:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: config.color,
          borderRadius: AppSizes.radiusM,
          glassOpacity: _isPressed ? 0.25 : 0.15,
          isPressed: _isPressed,
        );

      case SherpaStackVariant2025.overlay:
        return BoxDecoration(
          color: AppColors2025.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        );

      default:
        return null;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }
}

// ==================== 모델 클래스들 ====================

class SherpaStackLayer {
  final Widget child;
  final SherpaStackLayerPosition? positioned;
  final double elevation;
  final double parallaxStrength;
  final String? id;

  const SherpaStackLayer({
    required this.child,
    this.positioned,
    this.elevation = 0,
    this.parallaxStrength = 0,
    this.id,
  });

  factory SherpaStackLayer.positioned({
    required Widget child,
    double? top,
    double? right,
    double? bottom,
    double? left,
    double? width,
    double? height,
    double elevation = 0,
    double parallaxStrength = 0,
    String? id,
  }) {
    return SherpaStackLayer(
      child: child,
      positioned: SherpaStackLayerPosition(
        top: top,
        right: right,
        bottom: bottom,
        left: left,
        width: width,
        height: height,
      ),
      elevation: elevation,
      parallaxStrength: parallaxStrength,
      id: id,
    );
  }

  factory SherpaStackLayer.background({
    required Widget child,
    String? id,
  }) {
    return SherpaStackLayer(
      child: child,
      elevation: 0,
      parallaxStrength: 0,
      id: id ?? 'background',
    );
  }

  factory SherpaStackLayer.foreground({
    required Widget child,
    double elevation = 8,
    double parallaxStrength = 5,
    String? id,
  }) {
    return SherpaStackLayer(
      child: child,
      elevation: elevation,
      parallaxStrength: parallaxStrength,
      id: id ?? 'foreground',
    );
  }

  factory SherpaStackLayer.floating({
    required Widget child,
    double? top,
    double? right,
    double? bottom,
    double? left,
    double elevation = 12,
    double parallaxStrength = 8,
    String? id,
  }) {
    return SherpaStackLayer(
      child: child,
      positioned: SherpaStackLayerPosition(
        top: top,
        right: right,
        bottom: bottom,
        left: left,
      ),
      elevation: elevation,
      parallaxStrength: parallaxStrength,
      id: id ?? 'floating',
    );
  }
}

class SherpaStackLayerPosition {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double? width;
  final double? height;

  const SherpaStackLayerPosition({
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.width,
    this.height,
  });
}

// ==================== 열거형 정의 ====================

enum SherpaStackVariant2025 {
  standard,     // 표준 스택
  cards,        // 카드형 스택 (깊이 효과)
  layered,      // 레이어드 스택 (다중 레이어)
  floating,     // 플로팅 스택 (부유 효과)
  interactive,  // 인터랙티브 스택 (터치 반응)
  overlay,      // 오버레이 스택 (배경 + 오버레이)
  glass,        // 글래스 스택 (글래스모피즘)
}

// ==================== 도우미 클래스들 ====================

class StackConfiguration {
  final Color color;

  const StackConfiguration({
    required this.color,
  });
}