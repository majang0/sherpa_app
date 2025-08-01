// lib/shared/widgets/components/molecules/sherpa_category_selector_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 카테고리 선택 컴포넌트
/// 스마트 카테고리 시스템으로 이모티콘과 개수를 표시하는 모던한 선택기
class SherpaCategorySelector2025 extends StatefulWidget {
  final List<SherpaCategoryItem2025> categories;
  final String? selectedCategoryKey;
  final ValueChanged<String>? onCategoryChanged;
  final SherpaCategorySelectorVariant2025 variant;
  final SherpaCategorySelectorLayout layout;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final bool showCounts;
  final bool showLabels;
  final ScrollPhysics? scrollPhysics;
  final String? category;
  final Color? customColor;
  final VoidCallback? onShowAll;
  final String? emptyStateMessage;

  const SherpaCategorySelector2025({
    Key? key,
    required this.categories,
    this.selectedCategoryKey,
    this.onCategoryChanged,
    this.variant = SherpaCategorySelectorVariant2025.glass,
    this.layout = SherpaCategorySelectorLayout.horizontal,
    this.height,
    this.padding,
    this.margin,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.showCounts = true,
    this.showLabels = true,
    this.scrollPhysics,
    this.category,
    this.customColor,
    this.onShowAll,
    this.emptyStateMessage,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 카테고리 선택기 (모임용)
  factory SherpaCategorySelector2025.meeting({
    Key? key,
    String? selectedCategoryKey,
    ValueChanged<String>? onCategoryChanged,
    Map<String, int>? categoryCounts,
    String? category,
  }) {
    return SherpaCategorySelector2025(
      key: key,
      categories: _getMeetingCategories(categoryCounts ?? {}),
      selectedCategoryKey: selectedCategoryKey,
      onCategoryChanged: onCategoryChanged,
      category: category,
      variant: SherpaCategorySelectorVariant2025.glass,
      layout: SherpaCategorySelectorLayout.horizontal,
      height: 120,
    );
  }

  /// 모던 카테고리 선택기 (커스터마이징 가능)
  factory SherpaCategorySelector2025.modern({
    Key? key,
    required List<SherpaCategoryItem2025> categories,
    String? selectedCategoryKey,
    ValueChanged<String>? onCategoryChanged,
    String? category,
    bool showCounts = true,
  }) {
    return SherpaCategorySelector2025(
      key: key,
      categories: categories,
      selectedCategoryKey: selectedCategoryKey,
      onCategoryChanged: onCategoryChanged,
      category: category,
      showCounts: showCounts,
      variant: SherpaCategorySelectorVariant2025.hybrid,
      layout: SherpaCategorySelectorLayout.wrap,
    );
  }

  /// 컴팩트 카테고리 선택기 (공간 절약형)
  factory SherpaCategorySelector2025.compact({
    Key? key,
    required List<SherpaCategoryItem2025> categories,
    String? selectedCategoryKey,
    ValueChanged<String>? onCategoryChanged,
    String? category,
  }) {
    return SherpaCategorySelector2025(
      key: key,
      categories: categories,
      selectedCategoryKey: selectedCategoryKey,
      onCategoryChanged: onCategoryChanged,
      category: category,
      variant: SherpaCategorySelectorVariant2025.neu,
      layout: SherpaCategorySelectorLayout.compact,
      height: 80,
      showLabels: false,
    );
  }

  /// 기본 모임 카테고리들
  static List<SherpaCategoryItem2025> _getMeetingCategories(Map<String, int> counts) {
    return [
      SherpaCategoryItem2025(
        key: 'all',
        label: '전체',
        emoji: '🌟',
        color: AppColors2025.primary,
        count: counts['all'] ?? 0,
        description: '모든 카테고리의 모임',
      ),
      SherpaCategoryItem2025(
        key: 'exercise',
        label: '운동',
        emoji: '💪',
        color: AppColors2025.success,
        count: counts['exercise'] ?? 0,
        description: '운동, 스포츠 관련 모임',
      ),
      SherpaCategoryItem2025(
        key: 'study',
        label: '공부',
        emoji: '📚',
        color: Colors.blue,
        count: counts['study'] ?? 0,
        description: '학습, 교육 관련 모임',
      ),
      SherpaCategoryItem2025(
        key: 'hobby',
        label: '취미',
        emoji: '🎨',
        color: Colors.orange,
        count: counts['hobby'] ?? 0,
        description: '취미, 여가활동 모임',
      ),
      SherpaCategoryItem2025(
        key: 'culture',
        label: '문화',
        emoji: '🎭',
        color: Colors.purple,
        count: counts['culture'] ?? 0,
        description: '문화, 예술 관련 모임',
      ),
      SherpaCategoryItem2025(
        key: 'networking',
        label: '네트워킹',
        emoji: '🤝',
        color: Colors.indigo,
        count: counts['networking'] ?? 0,
        description: '인맥, 비즈니스 모임',
      ),
      SherpaCategoryItem2025(
        key: 'reading',
        label: '독서',
        emoji: '📖',
        color: Colors.teal,
        count: counts['reading'] ?? 0,
        description: '독서, 토론 모임',
      ),
    ];
  }

  @override
  State<SherpaCategorySelector2025> createState() => _SherpaCategorySelector2025State();
}

class _SherpaCategorySelector2025State extends State<SherpaCategorySelector2025>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _itemAnimationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _glowAnimations;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: MicroInteractions.medium,
      vsync: this,
    );
    
    _itemAnimationControllers = List.generate(
      widget.categories.length,
      (index) => AnimationController(
        duration: MicroInteractions.fast,
        vsync: this,
      ),
    );
    
    _scaleAnimations = _itemAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.05,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: MicroInteractions.easeOutQuart,
      ));
    }).toList();
    
    _glowAnimations = _itemAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 0.3,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: MicroInteractions.easeOutQuart,
      ));
    }).toList();
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _itemAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleCategoryTap(String categoryKey) {
    final index = widget.categories.indexWhere((cat) => cat.key == categoryKey);
    
    if (index != -1) {
      _itemAnimationControllers[index].forward().then((_) {
        _itemAnimationControllers[index].reverse();
      });
    }
    
    widget.onCategoryChanged?.call(categoryKey);
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getCategorySelectorConfiguration();
    
    if (widget.categories.isEmpty) {
      return _buildEmptyState(config);
    }
    
    Widget selector = Container(
      height: widget.height ?? config.height,
      padding: widget.padding ?? EdgeInsets.symmetric(vertical: AppSizes.paddingM),
      margin: widget.margin,
      child: _buildCategoryLayout(config),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      selector = MicroInteractions.slideInFade(
        child: selector,
        direction: SlideDirection.left,
      );
    }

    return selector;
  }

  Widget _buildCategoryLayout(CategorySelectorConfiguration config) {
    switch (widget.layout) {
      case SherpaCategorySelectorLayout.horizontal:
        return _buildHorizontalLayout(config);
      case SherpaCategorySelectorLayout.wrap:
        return _buildWrapLayout(config);
      case SherpaCategorySelectorLayout.compact:
        return _buildCompactLayout(config);
      case SherpaCategorySelectorLayout.grid:
        return _buildGridLayout(config);
    }
  }

  Widget _buildHorizontalLayout(CategorySelectorConfiguration config) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: widget.scrollPhysics ?? const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        return Padding(
          padding: EdgeInsets.only(right: config.spacing),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimations[index],
              _glowAnimations[index],
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: _buildCategoryItem(category, config, index),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWrapLayout(CategorySelectorConfiguration config) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Wrap(
        spacing: config.spacing,
        runSpacing: config.spacing,
        children: widget.categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          
          return AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimations[index],
              _glowAnimations[index],
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: _buildCategoryItem(category, config, index),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactLayout(CategorySelectorConfiguration config) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: widget.scrollPhysics ?? const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        return Padding(
          padding: EdgeInsets.only(right: config.spacing * 0.5),
          child: AnimatedBuilder(
            animation: _scaleAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: _buildCompactCategoryItem(category, config, index),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGridLayout(CategorySelectorConfiguration config) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: config.spacing,
          mainAxisSpacing: config.spacing,
        ),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          return AnimatedBuilder(
            animation: _scaleAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: _buildCategoryItem(category, config, index),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    SherpaCategoryItem2025 category, 
    CategorySelectorConfiguration config, 
    int index,
  ) {
    final isSelected = widget.selectedCategoryKey == category.key;
    final categoryColor = category.color ?? AppColors2025.primary;
    
    return GestureDetector(
      onTap: category.enabled 
          ? () => _handleCategoryTap(category.key) 
          : null,
      child: Container(
        width: config.itemWidth,
        decoration: _getItemDecoration(config, isSelected, categoryColor, index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모티콘
            AnimatedContainer(
              duration: MicroInteractions.fast,
              child: Text(
                category.emoji,
                style: TextStyle(
                  fontSize: isSelected ? config.emojiSize * 1.1 : config.emojiSize,
                ),
              ),
            ),
            
            if (widget.showLabels) ...[
              SizedBox(height: config.spacing * 0.5),
              
              // 라벨
              Text(
                category.label,
                style: GoogleFonts.notoSans(
                  fontSize: config.labelSize,
                  fontWeight: FontWeight.w600,
                  color: isSelected 
                      ? AppColors2025.textOnPrimary 
                      : AppColors2025.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            if (widget.showCounts) ...[
              SizedBox(height: config.spacing * 0.25),
              
              // 개수 표시
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: config.countPadding,
                  vertical: config.countPadding * 0.5,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors2025.textOnPrimary.withOpacity(0.2)
                      : categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  '${category.count}개',
                  style: GoogleFonts.notoSans(
                    fontSize: config.countSize,
                    fontWeight: FontWeight.w700,
                    color: isSelected 
                        ? AppColors2025.textOnPrimary 
                        : categoryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ).animate(target: isSelected ? 1 : 0)
        .scale(
          duration: MicroInteractions.normal,
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
        ),
    );
  }

  Widget _buildCompactCategoryItem(
    SherpaCategoryItem2025 category, 
    CategorySelectorConfiguration config, 
    int index,
  ) {
    final isSelected = widget.selectedCategoryKey == category.key;
    final categoryColor = category.color ?? AppColors2025.primary;
    
    return GestureDetector(
      onTap: category.enabled 
          ? () => _handleCategoryTap(category.key) 
          : null,
      child: Container(
        width: config.compactWidth,
        height: config.compactHeight,
        decoration: _getItemDecoration(config, isSelected, categoryColor, index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모티콘
            Text(
              category.emoji,
              style: TextStyle(
                fontSize: config.compactEmojiSize,
              ),
            ),
            
            if (widget.showCounts) ...[
              const SizedBox(height: 2),
              
              // 개수 표시
              Text(
                '${category.count}',
                style: GoogleFonts.notoSans(
                  fontSize: config.compactCountSize,
                  fontWeight: FontWeight.w700,
                  color: isSelected 
                      ? AppColors2025.textOnPrimary 
                      : categoryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(CategorySelectorConfiguration config) {
    return Container(
      height: widget.height ?? config.height,
      padding: EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 48,
            color: AppColors2025.textTertiary,
          ),
          SizedBox(height: AppSizes.paddingM),
          Text(
            widget.emptyStateMessage ?? '카테고리가 없습니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors2025.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.onShowAll != null) ...[
            SizedBox(height: AppSizes.paddingM),
            GestureDetector(
              onTap: widget.onShowAll,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
                decoration: BoxDecoration(
                  color: AppColors2025.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(
                    color: AppColors2025.primary,
                    width: 1,
                  ),
                ),
                child: Text(
                  '모든 카테고리 보기',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors2025.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  CategorySelectorConfiguration _getCategorySelectorConfiguration() {
    switch (widget.layout) {
      case SherpaCategorySelectorLayout.horizontal:
        return CategorySelectorConfiguration(
          height: 120,
          itemWidth: 80,
          spacing: 12,
          emojiSize: 28,
          labelSize: 12,
          countSize: 10,
          countPadding: 8,
          compactWidth: 0,
          compactHeight: 0,
          compactEmojiSize: 0,
          compactCountSize: 0,
        );
      case SherpaCategorySelectorLayout.wrap:
        return CategorySelectorConfiguration(
          height: 160,
          itemWidth: 90,
          spacing: 14,
          emojiSize: 32,
          labelSize: 13,
          countSize: 11,
          countPadding: 10,
          compactWidth: 0,
          compactHeight: 0,
          compactEmojiSize: 0,
          compactCountSize: 0,
        );
      case SherpaCategorySelectorLayout.compact:
        return CategorySelectorConfiguration(
          height: 80,
          itemWidth: 0,
          spacing: 8,
          emojiSize: 0,
          labelSize: 0,
          countSize: 0,
          countPadding: 0,
          compactWidth: 50,
          compactHeight: 60,
          compactEmojiSize: 20,
          compactCountSize: 9,
        );
      case SherpaCategorySelectorLayout.grid:
        return CategorySelectorConfiguration(
          height: 240,
          itemWidth: 70,
          spacing: 10,
          emojiSize: 24,
          labelSize: 11,
          countSize: 9,
          countPadding: 6,
          compactWidth: 0,
          compactHeight: 0,
          compactEmojiSize: 0,
          compactCountSize: 0,
        );
    }
  }

  BoxDecoration _getItemDecoration(
    CategorySelectorConfiguration config, 
    bool isSelected, 
    Color categoryColor,
    int index,
  ) {
    final backgroundColor = isSelected ? categoryColor : AppColors2025.surface;
    final glowOpacity = _glowAnimations.isNotEmpty ? _glowAnimations[index].value : 0.0;
    
    switch (widget.variant) {
      case SherpaCategorySelectorVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: isSelected ? GlassNeuElevation.high : GlassNeuElevation.medium,
          color: backgroundColor,
          borderRadius: AppSizes.radiusXL,
          opacity: isSelected ? 1.0 : 0.95,
        ).copyWith(
          boxShadow: isSelected ? [
            BoxShadow(
              color: categoryColor.withOpacity(0.3 + glowOpacity),
              blurRadius: 12 + (glowOpacity * 8),
              offset: const Offset(0, 4),
            ),
          ] : null,
        );

      case SherpaCategorySelectorVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: isSelected ? GlassNeuElevation.high : GlassNeuElevation.medium,
          baseColor: backgroundColor,
          borderRadius: AppSizes.radiusXL,
        );

      case SherpaCategorySelectorVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: GlassNeuElevation.medium,
          color: backgroundColor,
          borderRadius: AppSizes.radiusXL,
          glassOpacity: isSelected ? 0.25 : 0.15,
        ).copyWith(
          boxShadow: isSelected ? [
            BoxShadow(
              color: categoryColor.withOpacity(0.2 + glowOpacity),
              blurRadius: 16 + (glowOpacity * 12),
              offset: const Offset(0, 6),
            ),
          ] : null,
        );

      case SherpaCategorySelectorVariant2025.minimal:
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(
            color: isSelected ? categoryColor : AppColors2025.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: categoryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        );
    }
  }
}

// ==================== 모델 클래스들 ====================

class SherpaCategoryItem2025 {
  final String key;
  final String label;
  final String emoji;
  final Color? color;
  final int count;
  final String? description;
  final bool enabled;

  const SherpaCategoryItem2025({
    required this.key,
    required this.label,
    required this.emoji,
    this.color,
    this.count = 0,
    this.description,
    this.enabled = true,
  });

  SherpaCategoryItem2025 copyWith({
    String? key,
    String? label,
    String? emoji,
    Color? color,
    int? count,
    String? description,
    bool? enabled,
  }) {
    return SherpaCategoryItem2025(
      key: key ?? this.key,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      count: count ?? this.count,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
    );
  }
}

// ==================== 열거형 정의 ====================

enum SherpaCategorySelectorVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  minimal,     // 미니멀 (기본 테두리)
}

enum SherpaCategorySelectorLayout {
  horizontal,  // 가로 스크롤 (기본)
  wrap,        // 랩 레이아웃
  compact,     // 컴팩트 (이모티콘만)
  grid,        // 그리드 레이아웃
}

// ==================== 도우미 클래스들 ====================

class CategorySelectorConfiguration {
  final double height;
  final double itemWidth;
  final double spacing;
  final double emojiSize;
  final double labelSize;
  final double countSize;
  final double countPadding;
  final double compactWidth;
  final double compactHeight;
  final double compactEmojiSize;
  final double compactCountSize;

  const CategorySelectorConfiguration({
    required this.height,
    required this.itemWidth,
    required this.spacing,
    required this.emojiSize,
    required this.labelSize,
    required this.countSize,
    required this.countPadding,
    required this.compactWidth,
    required this.compactHeight,
    required this.compactEmojiSize,
    required this.compactCountSize,
  });
}