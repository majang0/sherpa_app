import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

enum SherpaInputVariant {
  outlined,    // 테두리가 있는 입력필드
  filled,      // 배경색이 있는 입력필드
  underlined,  // 밑줄만 있는 입력필드
}

enum SherpaInputSize {
  small,       // 높이 40px
  medium,      // 높이 48px
  large,       // 높이 56px
}

class SherpaInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final SherpaInputVariant variant;
  final SherpaInputSize size;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final FocusNode? focusNode;
  final Color? focusColor;

  const SherpaInput({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.variant = SherpaInputVariant.outlined,
    this.size = SherpaInputSize.medium,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.initialValue,
    this.focusNode,
    this.focusColor,
  }) : super(key: key);

  // 팩토리 생성자들
  factory SherpaInput.text({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    Widget? prefixIcon,
    String? errorText,
  }) {
    return SherpaInput(
      key: key,
      label: label,
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      prefixIcon: prefixIcon,
      errorText: errorText,
    );
  }

  factory SherpaInput.password({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    return SherpaInput(
      key: key,
      label: label ?? '비밀번호',
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      obscureText: true,
      prefixIcon: Icon(Icons.lock_outline),
      errorText: errorText,
    );
  }

  factory SherpaInput.email({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    return SherpaInput(
      key: key,
      label: label ?? '이메일',
      hint: hint ?? 'example@email.com',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icon(Icons.email_outlined),
      errorText: errorText,
    );
  }

  factory SherpaInput.phone({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    return SherpaInput(
      key: key,
      label: label ?? '전화번호',
      hint: hint ?? '010-1234-5678',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      prefixIcon: Icon(Icons.phone_outlined),
      errorText: errorText,
    );
  }

  factory SherpaInput.search({
    Key? key,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    return SherpaInput(
      key: key,
      hint: hint ?? '검색어를 입력하세요',
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      variant: SherpaInputVariant.filled,
      prefixIcon: Icon(Icons.search),
      suffixIcon: Icon(Icons.mic_outlined),
    );
  }

  factory SherpaInput.multiline({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    int maxLines = 4,
    int? maxLength,
  }) {
    return SherpaInput(
      key: key,
      label: label,
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      variant: SherpaInputVariant.outlined,
    );
  }

  @override
  State<SherpaInput> createState() => _SherpaInputState();
}

class _SherpaInputState extends State<SherpaInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.errorText != null 
                  ? AppColors.error 
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: _getHeight(),
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
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: GoogleFonts.notoSans(
              fontSize: _getFontSize(),
              color: widget.enabled ? AppColors.textPrimary : AppColors.textLight,
            ),
            decoration: _getDecoration(),
          ),
        ),
        if (widget.helperText != null || widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText ?? widget.helperText!,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: widget.errorText != null 
                  ? AppColors.error 
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  double _getHeight() {
    if (widget.maxLines != null && widget.maxLines! > 1) {
      return widget.maxLines! * 24.0 + 24.0; // 라인당 24px + 패딩
    }
    
    switch (widget.size) {
      case SherpaInputSize.small:
        return 40;
      case SherpaInputSize.medium:
        return 48;
      case SherpaInputSize.large:
        return 56;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case SherpaInputSize.small:
        return 14;
      case SherpaInputSize.medium:
        return 15;
      case SherpaInputSize.large:
        return 16;
    }
  }

  InputDecoration _getDecoration() {
    Color focusColor = widget.focusColor ?? AppColors.primary;
    Color borderColor = widget.errorText != null 
        ? AppColors.error 
        : (_isFocused ? focusColor : AppColors.border);
    
    Widget? suffixIcon = widget.suffixIcon;
    
    // 비밀번호 필드인 경우 가시성 토글 추가
    if (widget.obscureText) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textLight,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    switch (widget.variant) {
      case SherpaInputVariant.outlined:
        return InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.notoSans(
            fontSize: _getFontSize(),
            color: AppColors.textLight,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          counterText: '', // 글자수 카운터 숨기기
        );

      case SherpaInputVariant.filled:
        return InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.notoSans(
            fontSize: _getFontSize(),
            color: AppColors.textLight,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: _isFocused 
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.dividerLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            borderSide: BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          counterText: '',
        );

      case SherpaInputVariant.underlined:
        return InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.notoSans(
            fontSize: _getFontSize(),
            color: AppColors.textLight,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: suffixIcon,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS,
            vertical: AppSizes.paddingS,
          ),
          counterText: '',
        );
    }
  }
}

// 드롭다운 컴포넌트
class SherpaDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Widget? prefixIcon;
  final String? errorText;
  final bool enabled;

  const SherpaDropdown({
    Key? key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.prefixIcon,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: errorText != null 
                  ? AppColors.error 
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: AppSizes.paddingS),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    hint: Text(
                      hint ?? '선택하세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        color: AppColors.textLight,
                      ),
                    ),
                    items: items,
                    onChanged: enabled ? onChanged : null,
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textLight,
                    ),
                    isExpanded: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}