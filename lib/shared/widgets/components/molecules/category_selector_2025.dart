// lib/shared/widgets/components/molecules/category_selector_2025.dart

import 'package:flutter/material.dart';
import '../../../../features/meetings/models/available_meeting_model.dart';
import '../../../../core/constants/app_colors_2025.dart';

/// 2025 트렌드 카테고리 선택기 - 현대적 디자인과 매끄러운 애니메이션
class CategorySelector2025 extends StatefulWidget {
  final List<MeetingCategory> categories;
  final MeetingCategory selectedCategory;
  final Function(MeetingCategory) onCategorySelected;
  final bool isScrollable;
  final EdgeInsets padding;
  
  const CategorySelector2025({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isScrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  State<CategorySelector2025> createState() => _CategorySelector2025State();
}

class _CategorySelector2025State extends State<CategorySelector2025> 
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;
  
  ScrollController? _scrollController;
  
  @override
  void initState() {
    super.initState();
    
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOutCubic,
    );
    
    if (widget.isScrollable) {
      _scrollController = ScrollController();
    }
    
    // 초기 애니메이션
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectionController.forward();
    });
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void _handleCategoryTap(MeetingCategory category) {
    if (category != widget.selectedCategory) {
      // 선택 변경 애니메이션
      _selectionController.reset();
      _selectionController.forward();
      
      widget.onCategorySelected(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 50,
      padding: widget.padding,
      child: widget.isScrollable
        ? _buildScrollableCategories(isDark)
        : _buildFixedCategories(isDark),
    );
  }

  Widget _buildScrollableCategories(bool isDark) {
    return ListView.separated(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.categories.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        return _buildCategoryChip(category, isDark);
      },
    );
  }

  Widget _buildFixedCategories(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.categories.map((category) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCategoryChip(category, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChip(MeetingCategory category, bool isDark) {
    final isSelected = category == widget.selectedCategory;
    
    return AnimatedBuilder(
      animation: _selectionAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _handleCategoryTap(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      category.color,
                      category.color.withOpacity(0.8),
                    ],
                  )
                : null,
              color: isSelected
                ? null
                : isDark
                  ? AppColors2025.glassWhite10
                  : AppColors2025.neuBase.withOpacity(0.5),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                  ? category.color.withOpacity(0.3)
                  : isDark
                    ? AppColors2025.glassBorderSoft
                    : AppColors2025.borderLight,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: category.color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: category.color.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors2025.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji with scale animation
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                
                const SizedBox(width: 6),
                
                // Category name with color transition
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                      ? Colors.white
                      : isDark
                        ? AppColors2025.textOnDark
                        : AppColors2025.textPrimary,
                    letterSpacing: isSelected ? 0.3 : 0,
                  ),
                  child: Text(category.displayName),
                ),
                
                // Selection indicator
                if (isSelected)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors2025.neuHighlight.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 카테고리 필터 칩 - 더 간단한 버전
class CategoryFilterChip2025 extends StatelessWidget {
  final MeetingCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showCount;
  final int? count;
  
  const CategoryFilterChip2025({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.showCount = false,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
            ? category.color.withOpacity(0.9)
            : isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
              ? category.color.withOpacity(0.3)
              : isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: category.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                  ? Colors.white
                  : isDark
                    ? Colors.white.withOpacity(0.8)
                    : Colors.black.withOpacity(0.7),
              ),
            ),
            if (showCount && count != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                      ? Colors.white
                      : category.color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}