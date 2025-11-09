import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/widgets/sherpa_card.dart';
import '../../models/goal_model.dart';
import 'goal_modal_widget.dart';

/// 목표 카드 위젯
///
/// 개별 목표를 표시하는 카드
class GoalCardWidget extends ConsumerWidget {
  final GoalModel goal;

  const GoalCardWidget({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SherpaCard(
      child: InkWell(
        onTap: () {
          _showGoalDetail(context, ref);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 + 날짜
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryChip(),
                  _buildDateChip(),
                ],
              ),
              const SizedBox(height: 12),

              // 목표 이름
              Text(
                goal.name,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // 목표값
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: _getCategoryColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '목표: ${goal.targetValue}',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(),
                    ),
                  ),
                ],
              ),

              // D-Day
              const SizedBox(height: 8),
              _buildDDayChip(),
            ],
          ),
        ),
      ),
    );
  }

  /// 카테고리 칩
  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getCategoryColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        goal.category,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getCategoryColor(),
        ),
      ),
    );
  }

  /// 날짜 칩
  Widget _buildDateChip() {
    final dateStr = DateFormat('yyyy.MM.dd').format(goal.date);
    return Text(
      dateStr,
      style: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: ModernColors.textSecondary,
      ),
    );
  }

  /// D-Day 칩
  Widget _buildDDayChip() {
    final now = DateTime.now();
    final diff = goal.date.difference(now).inDays;

    String dDayText;
    Color dDayColor;

    if (diff < 0) {
      dDayText = 'D+${(-diff)}';
      dDayColor = ModernColors.textSecondary;
    } else if (diff == 0) {
      dDayText = 'D-Day';
      dDayColor = ModernColors.error;
    } else {
      dDayText = 'D-$diff';
      dDayColor = _getCategoryColor();
    }

    return Text(
      dDayText,
      style: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: dDayColor,
      ),
    );
  }

  /// 카테고리별 색상
  Color _getCategoryColor() {
    switch (goal.category) {
      case '운동':
        return ModernColors.exercise;
      case '학습':
        return ModernColors.reading;
      case '대회':
        return ModernColors.quest;
      case '자격증':
        return ModernColors.focus;
      default:
        return ModernColors.quest;
    }
  }

  /// 목표 상세 모달 표시
  void _showGoalDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalModalWidget(goal: goal),
    );
  }
}
