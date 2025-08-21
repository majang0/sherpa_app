// lib/shared/widgets/components/atoms/sherpa_input_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 입력 컴포넌트
/// 글래스모피즘, 뉴모피즘, 마이크로 인터랙션을 통합
class SherpaInput2025 extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final SherpaInputVariant2025 variant;
  final SherpaInputSize2025 size;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? category;
  final Color? customColor;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final GlassNeuElevation elevation;
  final bool autoValidate;
  final String? Function(String?)? validator;

  const SherpaInput2025({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.variant = SherpaInputVariant2025.glass,
    this.size = SherpaInputSize2025.medium,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.initialValue,
    this.focusNode,
    this.category,
    this.customColor,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.elevation = GlassNeuElevation.medium,
    this.autoValidate = false,
    this.validator,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 텍스트 입력 (글래스 스타일)
  factory SherpaInput2025.text({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    Widget? prefixIcon,
    String? errorText,
    String? category,
    SherpaInputSize2025 size = SherpaInputSize2025.medium,
  }) {
    return SherpaInput2025(
      key: key,
      label: label,
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      prefixIcon: prefixIcon,
      errorText: errorText,
      category: category,
      size: size,
      variant: SherpaInputVariant2025.glass,
    );
  }

  /// 비밀번호 입력 (뉴모피즘 스타일)
  factory SherpaInput2025.password({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? errorText,
    SherpaInputSize2025 size = SherpaInputSize2025.medium,
  }) {
    return SherpaInput2025(
      key: key,
      label: label ?? '비밀번호',
      hint: hint ?? '비밀번호를 입력하세요',
      controller: controller,
      onChanged: onChanged,
      obscureText: true,
      prefixIcon: Icon(Icons.lock_outline),
      errorText: errorText,
      size: size,
      variant: SherpaInputVariant2025.neu,
    );
  }

  /// 이메일 입력 (하이브리드 스타일)
  factory SherpaInput2025.email({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? errorText,
    SherpaInputSize2025 size = SherpaInputSize2025.medium,
  }) {
    return SherpaInput2025(
      key: key,
      label: label ?? '이메일',
      hint: hint ?? 'example@email.com',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icon(Icons.email_outlined),
      errorText: errorText,
      size: size,
      variant: SherpaInputVariant2025.hybrid,
    );
  }

  /// 전화번호 입력
  factory SherpaInput2025.phone({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? errorText,
    SherpaInputSize2025 size = SherpaInputSize2025.medium,
  }) {
    return SherpaInput2025(
      key: key,
      label: label ?? '전화번호',
      hint: hint ?? '010-1234-5678',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      prefixIcon: Icon(Icons.phone_outlined),
      errorText: errorText,
      size: size,
      variant: SherpaInputVariant2025.glass,
    );
  }

  /// 다중 라인 텍스트 (소프트 뉴모피즘)
  factory SherpaInput2025.multiline({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    int maxLines = 4,
    int? maxLength,
    String? category,
  }) {
    return SherpaInput2025(
      key: key,
      label: label,
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      category: category,
      variant: SherpaInputVariant2025.soft,
    );
  }

  /// 플로팅 스타일 입력
  factory SherpaInput2025.floating({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    Widget? prefixIcon,
    String? category,
    SherpaInputSize2025 size = SherpaInputSize2025.large,
  }) {
    return SherpaInput2025(
      key: key,
      label: label,
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      prefixIcon: prefixIcon,
      category: category,
      size: size,
      variant: SherpaInputVariant2025.floating,
      elevation: GlassNeuElevation.high,
    );
  }

  @override
  State<SherpaInput2025> createState() => _SherpaInput2025State();
}

class _SherpaInput2025State extends State<SherpaInput2025>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  bool _isFocused = false;
  bool _obscureText = false;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _currentError = widget.errorText;
    
    _animationController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );

    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    
    if (_isFocused) {
      _animationController.forward();
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    } else {
      _animationController.reverse();
      _validateInput();
    }
  }

  void _validateInput() {
    if (widget.autoValidate && widget.validator != null) {
      final error = widget.validator!(widget.controller?.text);
      if (error != _currentError) {
        setState(() => _currentError = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getInputConfiguration();
    final hasError = _currentError != null || widget.errorText != null;
    final errorText = widget.errorText ?? _currentError;

    Widget inputField = Container(
      height: config.height,
      decoration: _getDecoration(config, hasError),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        onTap: widget.onTap,
        onChanged: (value) {
          widget.onChanged?.call(value);
          if (widget.autoValidate) _validateInput();
        },
        onSubmitted: widget.onSubmitted,
        onEditingComplete: widget.onEditingComplete,
        style: GoogleFonts.notoSans(
          fontSize: config.fontSize,
          fontWeight: FontWeight.w500,
          color: widget.enabled
              ? (hasError ? AppColors2025.error : AppColors2025.textPrimary)
              : AppColors2025.textDisabled,
          height: 1.2,
        ),
        decoration: _getInputDecoration(config, hasError),
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      inputField = MicroInteractions.slideInFade(
        child: MicroInteractions.hoverEffect(
          scaleUpTo: 1.01,
          elevationIncrease: 2,
          child: inputField,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          AnimatedContainer(
            duration: MicroInteractions.fast,
            child: Text(
              widget.label!,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hasError
                    ? AppColors2025.error
                    : (_isFocused
                        ? (config.color ?? AppColors2025.primary)
                        : AppColors2025.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        inputField,
        if (widget.helperText != null || errorText != null) ...[
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: MicroInteractions.fast,
            child: Text(
              errorText ?? widget.helperText!,
              key: ValueKey(errorText ?? widget.helperText),
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: errorText != null ? FontWeight.w500 : FontWeight.w400,
                color: errorText != null
                    ? AppColors2025.error
                    : AppColors2025.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  InputConfiguration _getInputConfiguration() {
    final color = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    switch (widget.size) {
      case SherpaInputSize2025.small:
        return InputConfiguration(
          height: widget.maxLines! > 1 ? null : 42,
          fontSize: 14,
          iconSize: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: AppSizes.radiusS,
          color: color,
        );
      case SherpaInputSize2025.medium:
        return InputConfiguration(
          height: widget.maxLines! > 1 ? null : 50,
          fontSize: 15,
          iconSize: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: AppSizes.radiusM,
          color: color,
        );
      case SherpaInputSize2025.large:
        return InputConfiguration(
          height: widget.maxLines! > 1 ? null : 58,
          fontSize: 16,
          iconSize: 22,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: AppSizes.radiusL,
          color: color,
        );
    }
  }

  BoxDecoration _getDecoration(InputConfiguration config, bool hasError) {
    if (hasError) {
      return BoxDecoration(
        color: AppColors2025.errorBackground,
        borderRadius: BorderRadius.circular(config.borderRadius),
        border: Border.all(
          color: AppColors2025.error,
          width: 2,
        ),
      );
    }

    switch (widget.variant) {
      case SherpaInputVariant2025.glass:
        return widget.category != null
            ? GlassNeuStyle.glassByCategory(
                widget.category!,
                elevation: widget.elevation,
                borderRadius: config.borderRadius,
              )
            : GlassNeuStyle.glassMorphism(
                elevation: widget.elevation,
                color: config.color,
                borderRadius: config.borderRadius,
                opacity: _isFocused ? 0.25 : 0.15,
              );

      case SherpaInputVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: widget.elevation,
          baseColor: AppColors2025.neuBase,
          borderRadius: config.borderRadius,
          isPressed: _isFocused,
        );

      case SherpaInputVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: config.color,
          borderRadius: config.borderRadius,
          glassOpacity: _isFocused ? 0.2 : 0.1,
          isPressed: _isFocused,
        );

      case SherpaInputVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.color,
          borderRadius: config.borderRadius,
          elevation: 14,
        );

      case SherpaInputVariant2025.soft:
        return GlassNeuStyle.softNeumorphism(
          baseColor: AppColors2025.neuBaseSoft,
          borderRadius: config.borderRadius,
          intensity: 0.06,
        );

      case SherpaInputVariant2025.outlined:
        return BoxDecoration(
          color: AppColors2025.surface,
          borderRadius: BorderRadius.circular(config.borderRadius),
          border: Border.all(
            color: _isFocused ? config.color : AppColors2025.border,
            width: _isFocused ? 2 : 1,
          ),
        );
    }
  }

  InputDecoration _getInputDecoration(InputConfiguration config, bool hasError) {
    Widget? suffixIcon = widget.suffixIcon;

    // 비밀번호 필드인 경우 가시성 토글 추가
    if (widget.obscureText) {
      suffixIcon = GestureDetector(
        onTap: () {
          setState(() => _obscureText = !_obscureText);
          if (widget.enableHapticFeedback) {
            HapticFeedback.selectionClick();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors2025.textTertiary,
            size: config.iconSize,
          ),
        ),
      );
    }

    return InputDecoration(
      hintText: widget.hint,
      hintStyle: GoogleFonts.notoSans(
        fontSize: config.fontSize,
        color: AppColors2025.textQuaternary,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: widget.prefixIcon != null
          ? IconTheme(
              data: IconThemeData(
                color: _isFocused
                    ? config.color
                    : (hasError ? AppColors2025.error : AppColors2025.textTertiary),
                size: config.iconSize,
              ),
              child: widget.prefixIcon!,
            )
          : null,
      suffixIcon: suffixIcon != null
          ? IconTheme(
              data: IconThemeData(
                color: AppColors2025.textTertiary,
                size: config.iconSize,
              ),
              child: suffixIcon,
            )
          : null,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: config.padding,
      counterText: '',
      isDense: true,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }
}

// ==================== 열거형 정의 ====================

enum SherpaInputVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  floating,    // 플로팅 글래스
  soft,        // 소프트 뉴모피즘
  outlined,    // 전통적 아웃라인
}

enum SherpaInputSize2025 {
  small,       // 42px 높이
  medium,      // 50px 높이
  large,       // 58px 높이
}

// ==================== 도우미 클래스들 ====================

class InputConfiguration {
  final double? height;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color color;

  const InputConfiguration({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.padding,
    required this.borderRadius,
    required this.color,
  });
}