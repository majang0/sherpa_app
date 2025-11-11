import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/animation/micro_interactions.dart';
import 'package:sherpa_app/features/goals/models/goal_model.dart';
import 'package:sherpa_app/features/goals/providers/goal_provider.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/goal_modal_widget.dart';

/// 목표 카드 위젯 (2025 Complete Redesign)
///
/// Glassmorphism + 그라데이션 아이콘 배경 + 이중 그림자
/// global_sherpi_widget의 디자인 철학 적용
class GoalCardWidget extends ConsumerWidget {
  final GoalModel goal;

  const GoalCardWidget({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MicroInteractions.tapResponse(
      onTap: () => _showGoalDetail(context, ref),
      scaleDownTo: 0.98,
      enableHaptic: true,
      child: Stack(
        children: [
          // 기존 카드 콘텐츠
          _buildCardContent(context),

          // 대표 목표 배지 (우측 상단)
          Positioned(
            top: 12,
            right: 12,
            child: _buildRepresentativeBadge(ref),
          ),
        ],
      ),
    );
  }

  /// 카드 콘텐츠
  Widget _buildCardContent(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          // Glassmorphism
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: goal.isRepresentative
                ? Colors.amber
                : Colors.white.withValues(alpha: 0.3),
            width: goal.isRepresentative ? 2 : 1,
          ),
          boxShadow: goal.isRepresentative
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.15),
                    blurRadius: 50,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 60,
                    offset: const Offset(0, 25),
                  ),
                ]
              : [
                  BoxShadow(
                    color: _getCategoryColor().withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
        ),
      child: Column(
        children: [
          // 상단: 카테고리 아이콘 + 목표명 + 진행률
          Row(
            children: [
              // 카테고리 아이콘 (그라데이션 배경!)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _getCategoryGradient(),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _getCategoryColor().withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 목표명
                    Text(
                      goal.name,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // D-Day
                    Text(
                      _getDDayText(),
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _getDDayColor(),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 하단: 진행률 바
          _buildProgressBar(),
        ],
      ),
    );
  }

  /// 진행률 바
  Widget _buildProgressBar() {
    final progress = goal.isAchieved ? 1.0 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '목표: ${goal.targetValue}',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
                letterSpacing: -0.1,
              ),
            ),
            // 카테고리 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryLightColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                goal.category,
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getCategoryColor(),
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                // 배경
                Container(
                  color: Colors.black.withValues(alpha: 0.06),
                ),
                // 진행률 (그라데이션)
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCategoryColor(),
                          _getCategoryColor().withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat('yyyy.MM.dd').format(goal.date),
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary.withValues(alpha: 0.7),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  /// D-Day 텍스트
  String _getDDayText() {
    final now = DateTime.now();
    final diff = goal.date.difference(now).inDays;

    if (diff < 0) {
      return 'D+${(-diff)}';
    } else if (diff == 0) {
      return 'D-Day';
    } else {
      return 'D-$diff';
    }
  }

  /// D-Day 색상
  Color _getDDayColor() {
    final now = DateTime.now();
    final diff = goal.date.difference(now).inDays;

    if (diff < 0) {
      return ModernColors.textSecondary;
    } else if (diff == 0) {
      return const Color(0xFFE57373);
    } else if (diff <= 7) {
      return const Color(0xFFFF9800);
    } else {
      return _getCategoryColor();
    }
  }

  /// 카테고리 아이콘
  IconData _getCategoryIcon() {
    switch (goal.category) {
      case '운동':
        return Icons.fitness_center;
      case '학습':
        return Icons.menu_book;
      case '대회':
        return Icons.emoji_events;
      case '자격증':
        return Icons.workspace_premium;
      default:
        return Icons.flag;
    }
  }

  /// 카테고리 그라데이션
  LinearGradient _getCategoryGradient() {
    final color = _getCategoryColor();
    return LinearGradient(
      colors: [
        color,
        color.withValues(alpha: 0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Category Color - Solid colors from ModernColors
  Color _getCategoryColor() {
    switch (goal.category) {
      case '운동':
        return ModernColors.exercise;
      case '학습':
        return ModernColors.reading;
      case '대회':
        return ModernColors.climbing;
      case '자격증':
        return ModernColors.focus;
      default:
        return ModernColors.climbing;
    }
  }

  /// Category Light Color - Solid light variants
  Color _getCategoryLightColor() {
    switch (goal.category) {
      case '운동':
        return const Color(0xFFE8F5E9); // Light green
      case '학습':
        return const Color(0xFFFFF3E0); // Light orange
      case '대회':
        return const Color(0xFFE3F2FD); // Light blue
      case '자격증':
        return const Color(0xFFF3E5F5); // Light purple
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  /// Show Goal Detail Modal
  void _showGoalDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalModalWidget(goal: goal),
    );
  }

  /// 대표 목표 배지
  Widget _buildRepresentativeBadge(WidgetRef ref) {
    if (goal.isRepresentative) {
      // 선택된 상태: 노란색 원형 배경 + 흰색 별
      return MicroInteractions.tapResponse(
        onTap: () => _toggleRepresentative(ref),
        scaleDownTo: 0.95,
        enableHaptic: true,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber,
                Colors.amber.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.star,
            size: 24,
            color: Colors.white,
          ),
        ),
      );
    } else {
      // 미선택 상태: 회색 별
      return Semantics(
        label: '대표 목표로 설정',
        button: true,
        child: IconButton(
          icon: Icon(
            Icons.star_border,
            size: 28,
            color: ModernColors.textSecondary.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          splashColor: Colors.amber.withValues(alpha: 0.1),
          highlightColor: Colors.amber.withValues(alpha: 0.05),
          onPressed: () => _toggleRepresentative(ref),
        ),
      );
    }
  }

  /// 대표 목표 토글
  void _toggleRepresentative(WidgetRef ref) {
    // Haptic Feedback
    HapticFeedback.mediumImpact();

    // Toggle logic
    if (goal.isRepresentative) {
      // 이미 대표 목표 → 해제
      ref.read(goalProvider.notifier).setRepresentativeGoal(null);
    } else {
      // 미선택 → 대표 목표로 설정 (기존 대표 목표 자동 해제)
      ref.read(goalProvider.notifier).setRepresentativeGoal(goal.id);
    }
  }
}
