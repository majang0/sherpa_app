// lib/shared/widgets/components/atoms/sherpa_select_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 선택 컴포넌트
/// 단일 선택, 다중 선택, 태그 선택을 지원하는 고급 선택 인터페이스
class SherpaSelect2025<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final T? value;
  final List<T> values;
  final List<SherpaSelectItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<List<T>>? onMultiChanged;
  final SherpaSelectVariant2025 variant;
  final SherpaSelectSize2025 size;
  final SherpaSelectType type;
  final bool enabled;
  final bool searchable;
  final String? searchHint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? category;
  final Color? customColor;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final GlassNeuElevation elevation;
  final int? maxHeight;
  final bool allowClear;
  final String Function(T)? itemBuilder;
  final Widget Function(T)? customItemBuilder;
  final bool showCheckbox;

  const SherpaSelect2025({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.value,
    this.values = const [],
    required this.items,
    this.onChanged,
    this.onMultiChanged,
    this.variant = SherpaSelectVariant2025.glass,
    this.size = SherpaSelectSize2025.medium,
    this.type = SherpaSelectType.single,
    this.enabled = true,
    this.searchable = false,
    this.searchHint,
    this.prefixIcon,
    this.suffixIcon,
    this.category,
    this.customColor,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.elevation = GlassNeuElevation.medium,
    this.maxHeight,
    this.allowClear = true,
    this.itemBuilder,
    this.customItemBuilder,
    this.showCheckbox = true,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 단일 선택 드롭다운
  factory SherpaSelect2025.single({
    Key? key,
    String? label,
    String? hint,
    T? value,
    required List<SherpaSelectItem<T>> items,
    ValueChanged<T?>? onChanged,
    Widget? prefixIcon,
    String? category,
    SherpaSelectSize2025 size = SherpaSelectSize2025.medium,
  }) {
    return SherpaSelect2025(
      key: key,
      label: label,
      hint: hint,
      value: value,
      items: items,
      onChanged: onChanged,
      prefixIcon: prefixIcon,
      category: category,
      size: size,
      type: SherpaSelectType.single,
      variant: SherpaSelectVariant2025.glass,
    );
  }

  /// 다중 선택 드롭다운
  factory SherpaSelect2025.multi({
    Key? key,
    String? label,
    String? hint,
    List<T> values = const [],
    required List<SherpaSelectItem<T>> items,
    ValueChanged<List<T>>? onMultiChanged,
    Widget? prefixIcon,
    String? category,
    bool searchable = true,
    SherpaSelectSize2025 size = SherpaSelectSize2025.medium,
  }) {
    return SherpaSelect2025(
      key: key,
      label: label,
      hint: hint,
      values: values,
      items: items,
      onMultiChanged: onMultiChanged,
      prefixIcon: prefixIcon,
      category: category,
      size: size,
      type: SherpaSelectType.multi,
      variant: SherpaSelectVariant2025.hybrid,
      searchable: searchable,
    );
  }

  /// 태그 선택 (칩 형태)
  factory SherpaSelect2025.tags({
    Key? key,
    String? label,
    String? hint,
    List<T> values = const [],
    required List<SherpaSelectItem<T>> items,
    ValueChanged<List<T>>? onMultiChanged,
    String? category,
    bool searchable = true,
  }) {
    return SherpaSelect2025(
      key: key,
      label: label,
      hint: hint,
      values: values,
      items: items,
      onMultiChanged: onMultiChanged,
      category: category,
      type: SherpaSelectType.tags,
      variant: SherpaSelectVariant2025.soft,
      searchable: searchable,
      showCheckbox: false,
    );
  }

  /// 검색 가능한 선택
  factory SherpaSelect2025.searchable({
    Key? key,
    String? label,
    String? hint,
    T? value,
    required List<SherpaSelectItem<T>> items,
    ValueChanged<T?>? onChanged,
    String? searchHint,
    String? category,
  }) {
    return SherpaSelect2025(
      key: key,
      label: label,
      hint: hint,
      value: value,
      items: items,
      onChanged: onChanged,
      category: category,
      type: SherpaSelectType.single,
      variant: SherpaSelectVariant2025.floating,
      searchable: true,
      searchHint: searchHint,
    );
  }

  @override
  State<SherpaSelect2025<T>> createState() => _SherpaSelect2025State<T>();
}

class _SherpaSelect2025State<T> extends State<SherpaSelect2025<T>>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _dropdownController;
  late TextEditingController _searchController;
  
  bool _isOpen = false;
  bool _isFocused = false;
  List<SherpaSelectItem<T>> _filteredItems = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _selectKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );
    _dropdownController = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    
    _searchController.addListener(_handleSearchChange);
  }

  void _handleSearchChange() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return item.searchableText.toLowerCase().contains(query) ||
               item.label.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() {
      _isOpen = true;
      _isFocused = true;
    });
    
    _animationController.forward();
    _createOverlay();
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _closeDropdown() {
    setState(() {
      _isOpen = false;
      _isFocused = false;
    });
    
    _animationController.reverse();
    _removeOverlay();
    _searchController.clear();
    _filteredItems = widget.items;
  }

  void _createOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildDropdownOverlay(),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    _dropdownController.forward();
  }

  void _removeOverlay() {
    _dropdownController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Widget _buildDropdownOverlay() {
    return Positioned(
      width: _getDropdownWidth(),
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, _getSelectConfiguration().height + 4),
        child: AnimatedBuilder(
          animation: _dropdownController,
          builder: (context, child) {
            return Transform.scale(
              scale: _dropdownController.value,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: _dropdownController.value,
                child: Material(
                  color: Colors.transparent,
                  child: _buildDropdownContent(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdownContent() {
    final config = _getSelectConfiguration();
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight?.toDouble() ?? 300,
      ),
      decoration: GlassNeuStyle.floatingGlass(
        color: config.color,
        borderRadius: AppSizes.radiusM,
        elevation: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.searchable) _buildSearchField(config),
          Flexible(child: _buildItemsList(config)),
        ],
      ),
    );
  }

  Widget _buildSearchField(SelectConfiguration config) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: GlassNeuStyle.glassMorphism(
        elevation: GlassNeuElevation.low,
        borderRadius: AppSizes.radiusS,
        opacity: 0.3,
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.notoSans(
          fontSize: 14,
          color: AppColors2025.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.searchHint ?? '검색...',
          hintStyle: GoogleFonts.notoSans(
            fontSize: 14,
            color: AppColors2025.textQuaternary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: AppColors2025.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(SelectConfiguration config) {
    if (_filteredItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 32,
              color: AppColors2025.textQuaternary,
            ),
            const SizedBox(height: 8),
            Text(
              '검색 결과가 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors2025.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildSelectItem(item, config);
      },
    );
  }

  Widget _buildSelectItem(SherpaSelectItem<T> item, SelectConfiguration config) {
    final isSelected = widget.type == SherpaSelectType.single
        ? widget.value == item.value
        : widget.values.contains(item.value);

    return MicroInteractions.tapResponse(
      onTap: () => _selectItem(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (widget.showCheckbox && widget.type != SherpaSelectType.single) ...[
              AnimatedContainer(
                duration: MicroInteractions.fast,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? config.color : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? config.color : AppColors2025.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors2025.textOnPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
            ],
            if (item.icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: isSelected ? config.color : AppColors2025.textTertiary,
                  size: 20,
                ),
                child: item.icon!,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: widget.customItemBuilder != null
                  ? widget.customItemBuilder!(item.value)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.label,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? config.color
                                : AppColors2025.textPrimary,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: AppColors2025.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            if (isSelected && widget.type == SherpaSelectType.single)
              Icon(
                Icons.check,
                size: 20,
                color: config.color,
              ),
          ],
        ),
      ),
    );
  }

  void _selectItem(SherpaSelectItem<T> item) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }

    if (widget.type == SherpaSelectType.single) {
      widget.onChanged?.call(item.value);
      _closeDropdown();
    } else {
      final newValues = List<T>.from(widget.values);
      if (newValues.contains(item.value)) {
        newValues.remove(item.value);
      } else {
        newValues.add(item.value);
      }
      widget.onMultiChanged?.call(newValues);
    }
  }

  void _clearSelection() {
    if (widget.type == SherpaSelectType.single) {
      widget.onChanged?.call(null);
    } else {
      widget.onMultiChanged?.call([]);
    }
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  double _getDropdownWidth() {
    final RenderBox? renderBox = 
        _selectKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 200;
  }

  @override
  Widget build(BuildContext context) {
    final config = _getSelectConfiguration();
    final hasError = widget.errorText != null;

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
              color: hasError
                  ? AppColors2025.error
                  : (_isFocused
                      ? config.color
                      : AppColors2025.textSecondary),
            ),
          ),
          const SizedBox(height: 8),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: _selectKey,
            onTap: widget.enabled ? _toggleDropdown : null,
            child: _buildSelectField(config, hasError),
          ),
        ),
        if (widget.type == SherpaSelectType.tags && widget.values.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTagsDisplay(config),
        ],
        if (widget.helperText != null || widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText ?? widget.helperText!,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: widget.errorText != null
                  ? AppColors2025.error
                  : AppColors2025.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectField(SelectConfiguration config, bool hasError) {
    Widget selectField = Container(
      height: config.height,
      decoration: _getDecoration(config, hasError),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: IconTheme(
                data: IconThemeData(
                  color: _isFocused
                      ? config.color
                      : AppColors2025.textTertiary,
                  size: config.iconSize,
                ),
                child: widget.prefixIcon!,
              ),
            ),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDisplayContent(config),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.allowClear && _hasSelection()) ...[
                MicroInteractions.tapResponse(
                  onTap: _clearSelection,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors2025.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: MicroInteractions.fast,
                  child: widget.suffixIcon ??
                      Icon(
                        Icons.expand_more,
                        size: config.iconSize,
                        color: AppColors2025.textTertiary,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.enableMicroInteractions) {
      selectField = MicroInteractions.hoverEffect(
        scaleUpTo: 1.01,
        elevationIncrease: 2,
        child: selectField,
      );
    }

    return selectField;
  }

  Widget _buildDisplayContent(SelectConfiguration config) {
    if (widget.type == SherpaSelectType.single) {
      if (widget.value != null) {
        final selectedItem = widget.items.firstWhere(
          (item) => item.value == widget.value,
          orElse: () => SherpaSelectItem(value: widget.value as T, label: 'Unknown'),
        );
        return Text(
          selectedItem.label,
          style: GoogleFonts.notoSans(
            fontSize: config.fontSize,
            fontWeight: FontWeight.w500,
            color: AppColors2025.textPrimary,
          ),
        );
      }
    } else if (widget.values.isNotEmpty) {
      if (widget.type == SherpaSelectType.tags) {
        return Text(
          '${widget.values.length}개 선택됨',
          style: GoogleFonts.notoSans(
            fontSize: config.fontSize,
            fontWeight: FontWeight.w500,
            color: AppColors2025.textPrimary,
          ),
        );
      } else {
        return Text(
          widget.values.length == 1
              ? widget.items
                  .firstWhere((item) => item.value == widget.values.first)
                  .label
              : '${widget.values.length}개 선택됨',
          style: GoogleFonts.notoSans(
            fontSize: config.fontSize,
            fontWeight: FontWeight.w500,
            color: AppColors2025.textPrimary,
          ),
        );
      }
    }

    return Text(
      widget.hint ?? '선택하세요',
      style: GoogleFonts.notoSans(
        fontSize: config.fontSize,
        color: AppColors2025.textQuaternary,
      ),
    );
  }

  Widget _buildTagsDisplay(SelectConfiguration config) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.values.map((value) {
        final item = widget.items.firstWhere(
          (item) => item.value == value,
          orElse: () => SherpaSelectItem(value: value, label: 'Unknown'),
        );
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: GlassNeuStyle.glassMorphism(
            elevation: GlassNeuElevation.low,
            color: config.color,
            borderRadius: 16,
            opacity: 0.15,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: config.color,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  final newValues = List<T>.from(widget.values);
                  newValues.remove(value);
                  widget.onMultiChanged?.call(newValues);
                },
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: config.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _hasSelection() {
    return widget.type == SherpaSelectType.single
        ? widget.value != null
        : widget.values.isNotEmpty;
  }

  SelectConfiguration _getSelectConfiguration() {
    final color = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    switch (widget.size) {
      case SherpaSelectSize2025.small:
        return SelectConfiguration(
          height: 42,
          fontSize: 14,
          iconSize: 18,
          borderRadius: AppSizes.radiusS,
          color: color,
        );
      case SherpaSelectSize2025.medium:
        return SelectConfiguration(
          height: 50,
          fontSize: 15,
          iconSize: 20,
          borderRadius: AppSizes.radiusM,
          color: color,
        );
      case SherpaSelectSize2025.large:
        return SelectConfiguration(
          height: 58,
          fontSize: 16,
          iconSize: 22,
          borderRadius: AppSizes.radiusL,
          color: color,
        );
    }
  }

  BoxDecoration _getDecoration(SelectConfiguration config, bool hasError) {
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
      case SherpaSelectVariant2025.glass:
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

      case SherpaSelectVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: widget.elevation,
          baseColor: AppColors2025.neuBase,
          borderRadius: config.borderRadius,
          isPressed: _isFocused,
        );

      case SherpaSelectVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: config.color,
          borderRadius: config.borderRadius,
          glassOpacity: _isFocused ? 0.2 : 0.1,
          isPressed: _isFocused,
        );

      case SherpaSelectVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.color,
          borderRadius: config.borderRadius,
          elevation: 14,
        );

      case SherpaSelectVariant2025.soft:
        return GlassNeuStyle.softNeumorphism(
          baseColor: AppColors2025.neuBaseSoft,
          borderRadius: config.borderRadius,
          intensity: 0.06,
        );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChange);
    _searchController.dispose();
    _animationController.dispose();
    _dropdownController.dispose();
    _removeOverlay();
    super.dispose();
  }
}

// ==================== 모델 클래스들 ====================

class SherpaSelectItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final Widget? icon;
  final String searchableText;
  final bool enabled;

  const SherpaSelectItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    String? searchableText,
    this.enabled = true,
  }) : searchableText = searchableText ?? label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SherpaSelectItem<T> &&
      runtimeType == other.runtimeType &&
      value == other.value;

  @override
  int get hashCode => value.hashCode;
}

// ==================== 열거형 정의 ====================

enum SherpaSelectVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  floating,    // 플로팅 글래스
  soft,        // 소프트 뉴모피즘
}

enum SherpaSelectSize2025 {
  small,       // 42px 높이
  medium,      // 50px 높이
  large,       // 58px 높이
}

enum SherpaSelectType {
  single,      // 단일 선택
  multi,       // 다중 선택
  tags,        // 태그 선택 (칩 형태)
}

// ==================== 도우미 클래스들 ====================

class SelectConfiguration {
  final double height;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final Color color;

  const SelectConfiguration({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
    required this.color,
  });
}