import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/providers/level_1_user_data/global_point_provider.dart';

/// AI Analysis Modal Widget
///
/// 30포인트 소모 AI 분석 기능
/// 2025 Material Design 3: Bottom sheet, category selection, premium feature
class AIAnalysisModalWidget extends ConsumerStatefulWidget {
  final bool isGoalsScreen; // true: goals, false: routines

  const AIAnalysisModalWidget({
    super.key,
    this.isGoalsScreen = true,
  });

  @override
  ConsumerState<AIAnalysisModalWidget> createState() =>
      _AIAnalysisModalWidgetState();
}

class _AIAnalysisModalWidgetState
    extends ConsumerState<AIAnalysisModalWidget> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ModernColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title with AI icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.diary,
                      ModernColors.diary.withValues(alpha: 0.8)
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isGoalsScreen ? 'AI 목표 분석' : 'AI 루틴 분석',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.stars,
                            size: 16, color: ModernColors.joyBright),
                        const SizedBox(width: 4),
                        Text(
                          '30 포인트 소모',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Category selection
          Text(
            '분석할 카테고리를 선택하세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Category buttons
          Expanded(
            child: SingleChildScrollView(
              child: widget.isGoalsScreen
                  ? _buildGoalsCategories()
                  : _buildRoutinesCategories(),
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '취소',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Confirm button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _selectedCategory != null
                      ? () => _confirmAnalysis()
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: ModernColors.diary,
                    disabledBackgroundColor:
                        ModernColors.gray300.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '분석 시작',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Goals categories
  Widget _buildGoalsCategories() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildCategoryChip(
            '운동', ModernColors.exercise, Icons.fitness_center),
        _buildCategoryChip('대회', ModernColors.quest, Icons.emoji_events),
        _buildCategoryChip('학습', ModernColors.focus, Icons.school),
        _buildCategoryChip(
            '자격증', ModernColors.reading, Icons.workspace_premium),
      ],
    );
  }

  /// Routines categories
  Widget _buildRoutinesCategories() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildCategoryChip(
            '운동', ModernColors.exercise, Icons.fitness_center),
        _buildCategoryChip('문화', ModernColors.quest, Icons.palette),
        _buildCategoryChip('학습', ModernColors.focus, Icons.school),
        _buildCategoryChip('건강', ModernColors.reading, Icons.favorite),
        _buildCategoryChip('기타', ModernColors.meeting, Icons.category),
      ],
    );
  }

  Widget _buildCategoryChip(String label, Color color, IconData icon) {
    final isSelected = _selectedCategory == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : color.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, color: color, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  /// Confirm AI analysis with point deduction
  void _confirmAnalysis() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ModernColors.diary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: ModernColors.diary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AI 분석 시작',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_selectedCategory 카테고리를 분석합니다.',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernColors.joyBright.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars,
                      color: ModernColors.joyBright, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '30 포인트가 소모됩니다',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Deduct points
              final currentPoints =
                  ref.read(globalPointProvider).totalPoints;
              if (currentPoints >= 30) {
                ref
                    .read(globalPointProvider.notifier)
                    .spendPoints(30, 'AI 분석');

                // Close both dialogs
                Navigator.pop(context); // Close confirmation
                Navigator.pop(context); // Close modal

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'AI 분석이 시작되었습니다 (데모 버전)',
                      style: GoogleFonts.notoSans(),
                    ),
                    backgroundColor: ModernColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                // Not enough points
                Navigator.pop(context); // Close confirmation
                Navigator.pop(context); // Close modal

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '포인트가 부족합니다 (현재: $currentPoints P)',
                      style: GoogleFonts.notoSans(),
                    ),
                    backgroundColor: ModernColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernColors.diary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '확인',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
