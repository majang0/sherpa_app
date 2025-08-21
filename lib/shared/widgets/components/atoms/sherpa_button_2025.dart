// lib/shared/widgets/components/atoms/sherpa_button_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 버튼 컴포넌트
/// 글래스모피즘, 뉴모피즘, 마이크로 인터랙션을 통합
class SherpaButton2025 extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? trailingIcon;
  final SherpaButtonVariant2025 variant;
  final SherpaButtonSize2025 size;
  final String? category;
  final Color? customColor;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool enableHaptic;
  final bool enableMicroInteractions;
  final GlassNeuElevation elevation;

  const SherpaButton2025({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = SherpaButtonVariant2025.primary,
    this.size = SherpaButtonSize2025.medium,
    this.category,
    this.customColor,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.borderRadius,
    this.padding,
    this.enableHaptic = true,
    this.enableMicroInteractions = true,
    this.elevation = GlassNeuElevation.medium,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 주요 액션 버튼 (글래스모피즘)
  factory SherpaButton2025.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    SherpaButtonSize2025 size = SherpaButtonSize2025.medium,
    String? category,
    bool isLoading = false,
    double? width,
  }) {
    return SherpaButton2025(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      variant: SherpaButtonVariant2025.primary,
      size: size,
      category: category,
      isLoading: isLoading,
      width: width,
    );
  }

  /// 보조 액션 버튼 (뉴모피즘)
  factory SherpaButton2025.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    SherpaButtonSize2025 size = SherpaButtonSize2025.medium,
    String? category,
    bool isLoading = false,
    double? width,
  }) {
    return SherpaButton2025(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      variant: SherpaButtonVariant2025.secondary,
      size: size,
      category: category,
      isLoading: isLoading,
      width: width,
    );
  }

  /// 아웃라인 버튼 (테두리만)
  factory SherpaButton2025.outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    SherpaButtonSize2025 size = SherpaButtonSize2025.medium,
    String? category,
    bool isLoading = false,
    double? width,
  }) {
    return SherpaButton2025(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      variant: SherpaButtonVariant2025.outlined,
      size: size,
      category: category,
      isLoading: isLoading,
      width: width,
    );
  }

  /// 텍스트 버튼 (배경 없음)
  factory SherpaButton2025.text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    SherpaButtonSize2025 size = SherpaButtonSize2025.medium,
    String? category,
    bool isLoading = false,
    double? width,
  }) {
    return SherpaButton2025(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      variant: SherpaButtonVariant2025.text,
      size: size,
      category: category,
      isLoading: isLoading,
      width: width,
    );
  }

  /// 플로팅 버튼 (강한 그림자)
  factory SherpaButton2025.floating({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    SherpaButtonSize2025 size = SherpaButtonSize2025.medium,
    String? category,
    bool isLoading = false,
    double? width,
  }) {
    return SherpaButton2025(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      variant: SherpaButtonVariant2025.floating,
      size: size,
      category: category,
      isLoading: isLoading,
      width: width,
      elevation: GlassNeuElevation.high,
    );
  }

  /// 하이브리드 버튼 (글래스 + 뉴모피즘)
  factory SherpaButton2025.hybrid({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    SherpaButtonSize2025 size = SherpaButtonSize2025.medium,
    String? category,
    bool isLoading = false,
    double? width,
  }) {
    return SherpaButton2025(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      variant: SherpaButtonVariant2025.hybrid,
      size: size,
      category: category,
      isLoading: isLoading,
      width: width,
    );
  }

  /// 그라데이션 버튼
  factory SherpaButton2025.gradient({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    SherpaButtonSize2025 size = SherpaButtonSize2025.medium,
    String? category,
    bool isLoading = false,
    double? width,
  }) {
    return SherpaButton2025(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      variant: SherpaButtonVariant2025.gradient,
      size: size,
      category: category,
      isLoading: isLoading,
      width: width,
    );
  }

  @override
  State<SherpaButton2025> createState() => _SherpaButton2025State();
}

class _SherpaButton2025State extends State<SherpaButton2025>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.isEnabled && !widget.isLoading && widget.onPressed != null;
    final buttonConfig = _getButtonConfiguration();
    
    Widget button = Container(
      width: widget.width,
      height: buttonConfig.height,
      decoration: _getDecoration(buttonConfig, isInteractive),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? buttonConfig.borderRadius),
          onTap: isInteractive ? _handleTap : null,
          onTapDown: isInteractive ? _handleTapDown : null,
          onTapUp: isInteractive ? _handleTapUp : null,
          onTapCancel: isInteractive ? _handleTapCancel : null,
          child: Padding(
            padding: widget.padding ?? buttonConfig.padding,
            child: _buildContent(buttonConfig, isInteractive),
          ),
        ),
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions && isInteractive) {
      switch (widget.variant) {
        case SherpaButtonVariant2025.primary:
        case SherpaButtonVariant2025.secondary:
        case SherpaButtonVariant2025.hybrid:
          button = MicroInteractions.buttonPress(
            onPressed: widget.onPressed,
            glowColor: buttonConfig.color,
            isPressed: _isPressed,
            child: button,
          );
          break;
        case SherpaButtonVariant2025.floating:
          button = MicroInteractions.hoverEffect(
            scaleUpTo: 1.02,
            elevationIncrease: 4,
            child: MicroInteractions.tapResponse(
              onTap: widget.onPressed,
              scaleDownTo: 0.98,
              enableHaptic: widget.enableHaptic,
              child: button,
            ),
          );
          break;
        default:
          button = MicroInteractions.tapResponse(
            onTap: widget.onPressed,
            enableHaptic: widget.enableHaptic,
            child: button,
          );
      }
    }

    return button;
  }

  ButtonConfiguration _getButtonConfiguration() {
    final color = widget.customColor ?? 
        (widget.category != null 
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    switch (widget.size) {
      case SherpaButtonSize2025.small:
        return ButtonConfiguration(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          fontSize: 14,
          iconSize: 16,
          borderRadius: AppSizes.radiusM,
          color: color,
        );
      case SherpaButtonSize2025.medium:
        return ButtonConfiguration(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          fontSize: 16,
          iconSize: 20,
          borderRadius: AppSizes.radiusM,
          color: color,
        );
      case SherpaButtonSize2025.large:
        return ButtonConfiguration(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          fontSize: 18,
          iconSize: 24,
          borderRadius: AppSizes.radiusL,
          color: color,
        );
      case SherpaButtonSize2025.extraLarge:
        return ButtonConfiguration(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          fontSize: 20,
          iconSize: 28,
          borderRadius: AppSizes.radiusL,
          color: color,
        );
    }
  }

  BoxDecoration _getDecoration(ButtonConfiguration config, bool isInteractive) {
    if (!isInteractive) {
      return BoxDecoration(
        color: AppColors2025.neuShadowLight,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? config.borderRadius),
      );
    }

    switch (widget.variant) {
      case SherpaButtonVariant2025.primary:
        return widget.category != null 
            ? GlassNeuStyle.glassByCategory(
                widget.category!,
                elevation: widget.elevation,
                borderRadius: widget.borderRadius ?? config.borderRadius,
              )
            : GlassNeuStyle.glassMorphism(
                elevation: widget.elevation,
                color: config.color,
                borderRadius: widget.borderRadius ?? config.borderRadius,
                opacity: 0.2,
              );

      case SherpaButtonVariant2025.secondary:
        return GlassNeuStyle.neumorphism(
          elevation: widget.elevation,
          baseColor: AppColors2025.neuBase,
          borderRadius: widget.borderRadius ?? config.borderRadius,
          isPressed: _isPressed,
        );

      case SherpaButtonVariant2025.outlined:
        return BoxDecoration(
          border: Border.all(
            color: config.color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? config.borderRadius),
          color: Colors.transparent,
        );

      case SherpaButtonVariant2025.text:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? config.borderRadius),
        );

      case SherpaButtonVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.color,
          borderRadius: widget.borderRadius ?? config.borderRadius,
          elevation: 16,
        );

      case SherpaButtonVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: config.color,
          borderRadius: widget.borderRadius ?? config.borderRadius,
          glassOpacity: 0.15,
          isPressed: _isPressed,
        );

      case SherpaButtonVariant2025.gradient:
        return GlassNeuStyle.gradientGlass(
          gradient: widget.category != null 
              ? _getCategoryGradient(widget.category!)
              : AppColors2025.primaryGradient2025,
          borderRadius: widget.borderRadius ?? config.borderRadius,
          elevation: widget.elevation,
        );
    }
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'exercise':
      case '운동':
        return const LinearGradient(
          colors: [AppColors2025.exercise2025, AppColors2025.exerciseAccent],
        );
      case 'reading':
      case '독서':
        return const LinearGradient(
          colors: [AppColors2025.reading2025, AppColors2025.readingAccent],
        );
      case 'meeting':
      case '모임':
        return const LinearGradient(
          colors: [AppColors2025.meeting2025, AppColors2025.meetingAccent],
        );
      case 'diary':
      case '일기':
        return const LinearGradient(
          colors: [AppColors2025.diary2025, AppColors2025.diaryAccent],
        );
      case 'focus':
      case '집중':
        return const LinearGradient(
          colors: [AppColors2025.focus2025, AppColors2025.focusAccent],
        );
      default:
        return AppColors2025.primaryGradient2025;
    }
  }

  Widget _buildContent(ButtonConfiguration config, bool isInteractive) {
    final textColor = _getTextColor(config, isInteractive);
    
    if (widget.isLoading) {
      return SizedBox(
        width: config.iconSize,
        height: config.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(textColor),
        ),
      );
    }

    final List<Widget> children = [];

    // 아이콘
    if (widget.icon != null) {
      children.add(
        IconTheme(
          data: IconThemeData(
            color: textColor,
            size: config.iconSize,
          ),
          child: widget.icon!,
        ),
      );
      children.add(const SizedBox(width: 8));
    }

    // 텍스트
    children.add(
      Flexible(
        child: Text(
          widget.text,
          style: GoogleFonts.notoSans(
            fontSize: config.fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    // 뒤에 오는 아이콘
    if (widget.trailingIcon != null) {
      children.add(const SizedBox(width: 8));
      children.add(
        IconTheme(
          data: IconThemeData(
            color: textColor,
            size: config.iconSize,
          ),
          child: widget.trailingIcon!,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Color _getTextColor(ButtonConfiguration config, bool isInteractive) {
    if (!isInteractive) {
      return AppColors2025.textDisabled;
    }

    switch (widget.variant) {
      case SherpaButtonVariant2025.primary:
      case SherpaButtonVariant2025.floating:
      case SherpaButtonVariant2025.gradient:
        return AppColors2025.textOnPrimary;
      case SherpaButtonVariant2025.secondary:
      case SherpaButtonVariant2025.hybrid:
        return config.color;
      case SherpaButtonVariant2025.outlined:
      case SherpaButtonVariant2025.text:
        return config.color;
    }
  }

  void _handleTap() {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ==================== 열거형 정의 ====================

enum SherpaButtonVariant2025 {
  primary,     // 글래스모피즘 메인 버튼
  secondary,   // 뉴모피즘 보조 버튼
  outlined,    // 아웃라인 버튼
  text,        // 텍스트 버튼
  floating,    // 플로팅 버튼
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  gradient,    // 그라데이션 버튼
}

enum SherpaButtonSize2025 {
  small,       // 40px 높이
  medium,      // 48px 높이
  large,       // 56px 높이
  extraLarge,  // 64px 높이
}

// ==================== 도우미 클래스들 ====================

class ButtonConfiguration {
  final double height;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final Color color;

  const ButtonConfiguration({
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
    required this.color,
  });
}