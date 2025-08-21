// lib/shared/widgets/components/atoms/sherpa_search_bar_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 검색바 컴포넌트
/// AI 검색, 음성 검색, 필터링을 지원하는 고급 검색 인터페이스
class SherpaSearchBar2025 extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final VoidCallback? onMicTap;
  final VoidCallback? onFilterTap;
  final List<String>? suggestions;
  final SherpaSearchVariant2025 variant;
  final SherpaSearchSize2025 size;
  final bool enabled;
  final bool readOnly;
  final bool showMic;
  final bool showFilter;
  final bool showClear;
  final bool autoFocus;
  final String? category;
  final Color? customColor;
  final Widget? leadingIcon;
  final Widget? customMicIcon;
  final Widget? customFilterIcon;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final GlassNeuElevation elevation;
  final int? maxSuggestions;
  final bool showSuggestions;

  const SherpaSearchBar2025({
    Key? key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onClear,
    this.onMicTap,
    this.onFilterTap,
    this.suggestions,
    this.variant = SherpaSearchVariant2025.glass,
    this.size = SherpaSearchSize2025.medium,
    this.enabled = true,
    this.readOnly = false,
    this.showMic = true,
    this.showFilter = false,
    this.showClear = true,
    this.autoFocus = false,
    this.category,
    this.customColor,
    this.leadingIcon,
    this.customMicIcon,
    this.customFilterIcon,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.elevation = GlassNeuElevation.medium,
    this.maxSuggestions = 5,
    this.showSuggestions = true,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 검색바 (글래스 스타일)
  factory SherpaSearchBar2025.basic({
    Key? key,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? category,
  }) {
    return SherpaSearchBar2025(
      key: key,
      hint: hint ?? '검색어를 입력하세요',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      category: category,
      variant: SherpaSearchVariant2025.glass,
    );
  }

  /// AI 검색바 (하이브리드 스타일)
  factory SherpaSearchBar2025.ai({
    Key? key,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onMicTap,
    List<String>? suggestions,
  }) {
    return SherpaSearchBar2025(
      key: key,
      hint: hint ?? 'AI가 도와드릴게요. 무엇을 찾고 계신가요?',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onMicTap: onMicTap,
      suggestions: suggestions,
      variant: SherpaSearchVariant2025.hybrid,
      size: SherpaSearchSize2025.large,
      leadingIcon: Icon(Icons.auto_awesome_outlined),
    );
  }

  /// 플로팅 검색바 (강조된 검색)
  factory SherpaSearchBar2025.floating({
    Key? key,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onFilterTap,
    String? category,
  }) {
    return SherpaSearchBar2025(
      key: key,
      hint: hint ?? '무엇을 찾고 계신가요?',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onFilterTap: onFilterTap,
      category: category,
      variant: SherpaSearchVariant2025.floating,
      showFilter: onFilterTap != null,
      elevation: GlassNeuElevation.high,
    );
  }

  /// 컴팩트 검색바 (작은 공간용)
  factory SherpaSearchBar2025.compact({
    Key? key,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    bool showMic = false,
  }) {
    return SherpaSearchBar2025(
      key: key,
      hint: hint ?? '검색',
      controller: controller,
      onChanged: onChanged,
      size: SherpaSearchSize2025.small,
      variant: SherpaSearchVariant2025.neu,
      showMic: showMic,
      showFilter: false,
    );
  }

  @override
  State<SherpaSearchBar2025> createState() => _SherpaSearchBar2025State();
}

class _SherpaSearchBar2025State extends State<SherpaSearchBar2025>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late AnimationController _suggestionController;
  
  bool _isFocused = false;
  bool _showSuggestions = false;
  bool _isListening = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    
    _animationController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );
    
    _suggestionController = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );

    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    
    if (_isFocused) {
      _animationController.forward();
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
      _updateSuggestions();
    } else {
      _animationController.reverse();
      _hideSuggestions();
    }
  }

  void _handleTextChange() {
    widget.onChanged?.call(_controller.text);
    _updateSuggestions();
  }

  void _updateSuggestions() {
    if (!widget.showSuggestions || widget.suggestions == null) return;

    final query = _controller.text.toLowerCase();
    if (query.isEmpty) {
      _hideSuggestions();
      return;
    }

    final filtered = widget.suggestions!
        .where((suggestion) => suggestion.toLowerCase().contains(query))
        .take(widget.maxSuggestions ?? 5)
        .toList();

    setState(() {
      _filteredSuggestions = filtered;
      _showSuggestions = filtered.isNotEmpty && _isFocused;
    });

    if (_showSuggestions) {
      _suggestionController.forward();
    } else {
      _suggestionController.reverse();
    }
  }

  void _hideSuggestions() {
    setState(() => _showSuggestions = false);
    _suggestionController.reverse();
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _hideSuggestions();
    _focusNode.unfocus();
    widget.onSubmitted?.call(suggestion);
  }

  void _handleClear() {
    _controller.clear();
    _hideSuggestions();
    widget.onClear?.call();
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleMicTap() {
    setState(() => _isListening = !_isListening);
    widget.onMicTap?.call();
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getSearchConfiguration();
    
    Widget searchBar = Container(
      height: config.height,
      decoration: _getDecoration(config),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onSubmitted: widget.onSubmitted,
        style: GoogleFonts.notoSans(
          fontSize: config.fontSize,
          fontWeight: FontWeight.w500,
          color: widget.enabled
              ? AppColors2025.textPrimary
              : AppColors2025.textDisabled,
          height: 1.2,
        ),
        decoration: _getInputDecoration(config),
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      searchBar = MicroInteractions.hoverEffect(
        scaleUpTo: 1.01,
        elevationIncrease: 2,
        child: searchBar,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        searchBar,
        if (_showSuggestions) _buildSuggestions(config),
      ],
    );
  }

  Widget _buildSuggestions(SearchConfiguration config) {
    return AnimatedBuilder(
      animation: _suggestionController,
      builder: (context, child) {
        return Transform.scale(
          scale: _suggestionController.value,
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: _suggestionController.value,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: GlassNeuStyle.glassMorphism(
                elevation: GlassNeuElevation.high,
                borderRadius: AppSizes.radiusM,
                opacity: 0.95,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _filteredSuggestions.map((suggestion) {
                    return MicroInteractions.tapResponse(
                      onTap: () => _selectSuggestion(suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 16,
                              color: AppColors2025.textTertiary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: AppColors2025.textSecondary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.north_west,
                              size: 14,
                              color: AppColors2025.textQuaternary,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  SearchConfiguration _getSearchConfiguration() {
    final color = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    switch (widget.size) {
      case SherpaSearchSize2025.small:
        return SearchConfiguration(
          height: 40,
          fontSize: 14,
          iconSize: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: AppSizes.radiusS,
          color: color,
        );
      case SherpaSearchSize2025.medium:
        return SearchConfiguration(
          height: 48,
          fontSize: 15,
          iconSize: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: AppSizes.radiusM,
          color: color,
        );
      case SherpaSearchSize2025.large:
        return SearchConfiguration(
          height: 56,
          fontSize: 16,
          iconSize: 22,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: AppSizes.radiusL,
          color: color,
        );
    }
  }

  BoxDecoration _getDecoration(SearchConfiguration config) {
    switch (widget.variant) {
      case SherpaSearchVariant2025.glass:
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

      case SherpaSearchVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: widget.elevation,
          baseColor: AppColors2025.neuBase,
          borderRadius: config.borderRadius,
          isPressed: _isFocused,
        );

      case SherpaSearchVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: config.color,
          borderRadius: config.borderRadius,
          glassOpacity: _isFocused ? 0.2 : 0.1,
          isPressed: _isFocused,
        );

      case SherpaSearchVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.color,
          borderRadius: config.borderRadius,
          elevation: 16,
        );

      case SherpaSearchVariant2025.soft:
        return GlassNeuStyle.softNeumorphism(
          baseColor: AppColors2025.neuBaseSoft,
          borderRadius: config.borderRadius,
          intensity: 0.06,
        );
    }
  }

  InputDecoration _getInputDecoration(SearchConfiguration config) {
    final List<Widget> suffixIcons = [];

    // 클리어 버튼
    if (widget.showClear && _controller.text.isNotEmpty) {
      suffixIcons.add(
        MicroInteractions.tapResponse(
          onTap: _handleClear,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.close,
              size: config.iconSize - 2,
              color: AppColors2025.textTertiary,
            ),
          ),
        ),
      );
    }

    // 마이크 버튼
    if (widget.showMic) {
      suffixIcons.add(
        MicroInteractions.tapResponse(
          onTap: _handleMicTap,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: AnimatedContainer(
              duration: MicroInteractions.fast,
              decoration: _isListening
                  ? BoxDecoration(
                      color: AppColors2025.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    )
                  : null,
              padding: const EdgeInsets.all(4),
              child: widget.customMicIcon ??
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none_outlined,
                    size: config.iconSize,
                    color: _isListening
                        ? AppColors2025.error
                        : AppColors2025.textTertiary,
                  ),
            ),
          ),
        ),
      );
    }

    // 필터 버튼
    if (widget.showFilter) {
      suffixIcons.add(
        MicroInteractions.tapResponse(
          onTap: () {
            widget.onFilterTap?.call();
            if (widget.enableHapticFeedback) {
              HapticFeedback.lightImpact();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            child: widget.customFilterIcon ??
                Icon(
                  Icons.tune,
                  size: config.iconSize,
                  color: AppColors2025.textTertiary,
                ),
          ),
        ),
      );
    }

    return InputDecoration(
      hintText: widget.hint ?? '검색어를 입력하세요',
      hintStyle: GoogleFonts.notoSans(
        fontSize: config.fontSize,
        color: AppColors2025.textQuaternary,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: widget.leadingIcon != null
          ? IconTheme(
              data: IconThemeData(
                color: _isFocused
                    ? config.color
                    : AppColors2025.textTertiary,
                size: config.iconSize,
              ),
              child: widget.leadingIcon!,
            )
          : Icon(
              Icons.search,
              size: config.iconSize,
              color: _isFocused
                  ? config.color
                  : AppColors2025.textTertiary,
            ),
      suffixIcon: suffixIcons.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: suffixIcons,
            )
          : null,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: config.padding,
      isDense: true,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }
}

// ==================== 열거형 정의 ====================

enum SherpaSearchVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  floating,    // 플로팅 글래스
  soft,        // 소프트 뉴모피즘
}

enum SherpaSearchSize2025 {
  small,       // 40px 높이
  medium,      // 48px 높이
  large,       // 56px 높이
}

// ==================== 도우미 클래스들 ====================

class SearchConfiguration {
  final double height;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color color;

  const SearchConfiguration({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.padding,
    required this.borderRadius,
    required this.color,
  });
}