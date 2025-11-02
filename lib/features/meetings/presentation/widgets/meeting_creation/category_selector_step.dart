// lib/features/meetings/presentation/widgets/meeting_creation/category_selector_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/modern_colors.dart';
import '../../../models/available_meeting_model.dart';

/// 🎯 카테고리 선택 화면 - Step 1
/// 모임의 종류를 선택하는 화면 (6개 카테고리 그리드)
class QuickCategorySelector extends StatelessWidget {
  final MeetingCategory? selectedCategory;
  final Function(MeetingCategory) onCategorySelected;

  const QuickCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // 전체 카테고리 제외하고 표시
    final categories = MeetingCategory.values
        .where((cat) => cat != MeetingCategory.all)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설명 텍스트
          Text(
            '모임의 종류를 선택해주세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // 카테고리 그리드
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return GestureDetector(
                  onTap: () => onCategorySelected(category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? category.color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? category.color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: category.color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 이모지
                        Text(
                          category.emoji,
                          style: TextStyle(
                            fontSize: isSelected ? 48 : 40,
                          ),
                        ).animate(target: isSelected ? 1 : 0).scale(
                              duration: 200.ms,
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                            ),

                        const SizedBox(height: 12),

                        // 카테고리 이름
                        Text(
                          category.displayName,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : ModernColors.textPrimary,
                          ),
                        ),

                        // 선택 체크 마크
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 100 * index),
                        duration: 300.ms,
                      )
                      .scale(
                        delay: Duration(milliseconds: 100 * index),
                        duration: 200.ms,
                      ),
                );
              },
            ),
          ),

          // 팁 텍스트
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: ModernColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '카테고리에 맞는 사람들이 모임을 발견하기 쉬워져요',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: ModernColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
