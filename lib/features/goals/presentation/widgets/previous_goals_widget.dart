import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/animation/micro_interactions.dart';
import 'package:sherpa_app/features/goals/models/goal_model.dart';
import 'package:sherpa_app/features/goals/providers/goal_provider.dart';

/// 이전 목표 다이얼로그 (Professional Redesign - 2025-11-02)
///
/// 디자인 철학:
/// - goals_screen.dart의 clean & modern 스타일 계승
/// - 모달 크기 최적화: 7-8개 목표 표시 (vs 5-6개 이전)
/// - Climbing 색상 중심, 카테고리 컬러는 타임라인 라인만
/// - 3단계 정보 계층: Level 1 (달성 상태) → Level 2 (목표 내용) → Level 3 (상세)
class PreviousGoalsDialog extends ConsumerStatefulWidget {
  const PreviousGoalsDialog({super.key});

  @override
  ConsumerState<PreviousGoalsDialog> createState() =>
      _PreviousGoalsDialogState();
}

class _PreviousGoalsDialogState extends ConsumerState<PreviousGoalsDialog> {
  List<GoalModel> _previousGoals = [];
  List<GoalModel> _filteredGoals = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String _sortBy = 'date'; // 'date', 'achievement', 'category'

  // 확장 상태 관리
  final Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    _loadPreviousGoals();
  }

  Future<void> _loadPreviousGoals() async {
    setState(() => _isLoading = true);
    final goals = await ref.read(goalProvider.notifier).loadPreviousGoals();
    setState(() {
      _previousGoals = goals;
      _filteredGoals = goals;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredGoals = _previousGoals.where((goal) {
        if (_selectedCategory != null && goal.category != _selectedCategory) {
          return false;
        }
        return true;
      }).toList();

      // 정렬
      if (_sortBy == 'date') {
        _filteredGoals.sort((a, b) => (b.completedAt ?? DateTime.now())
            .compareTo(a.completedAt ?? DateTime.now()));
      } else if (_sortBy == 'achievement') {
        _filteredGoals.sort((a, b) => b.achievementRate.compareTo(a.achievementRate));
      } else if (_sortBy == 'category') {
        _filteredGoals.sort((a, b) => a.category.compareTo(b.category));
      }
    });
  }

  /// 목표 삭제
  Future<void> _deleteGoal(GoalModel goal) async {
    final confirmed = await _showDeleteConfirmation(goal);
    if (confirmed == true) {
      await ref.read(goalProvider.notifier).deleteGoal(goal.id);
      await _loadPreviousGoals();
      if (_selectedCategory != null) {
        _applyFilters();
      }
    }
  }

  /// 삭제 확인 다이얼로그
  Future<bool?> _showDeleteConfirmation(GoalModel goal) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ModernColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                size: 32,
                color: ModernColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '목표를 삭제하시겠어요?',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '삭제된 목표는 복구할 수 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDialogButton(
                    '취소',
                    onPressed: () => Navigator.pop(context, false),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDialogButton(
                    '삭제',
                    onPressed: () => Navigator.pop(context, true),
                    isPrimary: true,
                    color: ModernColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 다이얼로그 버튼
  Widget _buildDialogButton(
    String text, {
    required VoidCallback onPressed,
    required bool isPrimary,
    Color? color,
  }) {
    final buttonColor = color ?? ModernColors.climbing;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [buttonColor, buttonColor.withValues(alpha: 0.8)],
              )
            : null,
        color: isPrimary ? null : ModernColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? null
            : Border.all(
                color: ModernColors.textSecondary.withValues(alpha: 0.2),
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : ModernColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF5F9FF), // Light blue (goals_screen과 동일)
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.climbing.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: _isLoading
                ? _buildLoadingState()
                : _previousGoals.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          _buildHeader(),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: Column(
                                  children: [
                                    _buildCircularStatistics(),
                                    const SizedBox(height: 16),
                                    _buildIntegratedFilter(),
                                    const SizedBox(height: 16),
                                    _buildTimelineGoalList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.98, 0.98),
          curve: Curves.easeOut,
          duration: 200.ms,
        )
        .fade(
          curve: Curves.easeOut,
          duration: 150.ms,
        );
  }

  /// 헤더 (60px - 압축)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // 아이콘 (48x48로 축소)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ModernColors.climbing,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.climbing.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.history,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이전 목표',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ModernColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${_previousGoals.length}개의 목표',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary.withValues(alpha: 0.8),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          // 닫기 버튼
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: ModernColors.textSecondary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// 원형 통계 배지 (40px 높이 - 44px 절약!)
  Widget _buildCircularStatistics() {
    final totalGoals = _previousGoals.length;
    final achievedGoals = _previousGoals.where((g) => g.isAchieved).length;
    final achievedPercentage = totalGoals > 0 ? (achievedGoals / totalGoals * 100) : 0.0;
    final avgAchievementRate = totalGoals > 0
        ? _previousGoals.map((g) => g.achievementRate).reduce((a, b) => a + b) / totalGoals
        : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircularStatBadge(
          Icons.flag_outlined,
          totalGoals.toString(),
          '총 목표',
        ),
        _buildCircularStatBadge(
          Icons.check_circle_outline,
          '${achievedPercentage.toStringAsFixed(0)}%',
          '달성률',
        ),
        _buildCircularStatBadge(
          Icons.emoji_events_outlined,
          achievedGoals.toString(),
          '달성',
        ),
        _buildCircularStatBadge(
          Icons.trending_up,
          '${(avgAchievementRate * 100).toStringAsFixed(0)}%',
          '평균',
        ),
      ],
    );
  }

  /// 원형 통계 배지 (60x60)
  Widget _buildCircularStatBadge(IconData icon, String value, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: ModernColors.climbing,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ModernColors.climbing.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: ModernColors.climbing.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통합 필터 (36px 높이 - 단일 행)
  Widget _buildIntegratedFilter() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryFilterIcon(
                  icon: Icons.grid_view,
                  label: '전체',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...GoalCategory.all.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCategoryFilterIcon(
                      icon: _getCategoryIcon(category),
                      label: category,
                      isSelected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                          _applyFilters();
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 정렬 버튼 (48px)
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              _sortBy = value;
              _applyFilters();
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'date', child: Text('최신순')),
            const PopupMenuItem(value: 'achievement', child: Text('달성률순')),
            const PopupMenuItem(value: 'category', child: Text('카테고리순')),
          ],
          child: Container(
            width: 48,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ModernColors.climbing.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.climbing.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.sort,
              size: 18,
              color: ModernColors.climbing,
            ),
          ),
        ),
      ],
    );
  }

  /// 카테고리 필터 아이콘 (36px 높이)
  Widget _buildCategoryFilterIcon({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MicroInteractions.tapResponse(
      onTap: onTap,
      scaleDownTo: 0.95,
      duration: MicroInteractions.fast,
      enableHaptic: true,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ModernColors.climbing
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.3)
                : ModernColors.climbing.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ModernColors.climbing.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : ModernColors.climbing,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : ModernColors.climbing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 타임라인 스타일 목표 리스트
  Widget _buildTimelineGoalList() {
    if (_filteredGoals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: ModernColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '필터 조건에 맞는 목표가 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 필터를 선택해보세요',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_filteredGoals.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTimelineGoalCard(_filteredGoals[index], index),
        );
      }),
    );
  }

  /// 타임라인 스타일 목표 카드 (80px 접힌 상태 → 140px 펼친 상태)
  Widget _buildTimelineGoalCard(GoalModel goal, int index) {
    final isExpanded = _expandedStates[goal.id] ?? false;
    final categoryColor = _getCategoryColor(goal.category);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽 컬러 라인 (4px)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 4,
          height: isExpanded ? 140 : 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor,
                categoryColor.withValues(alpha: 0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        // 카드 내용
        Expanded(
          child: MicroInteractions.tapResponse(
            onTap: () {
              setState(() {
                _expandedStates[goal.id] = !isExpanded;
              });
            },
            scaleDownTo: 0.98,
            duration: MicroInteractions.fast,
            enableHaptic: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.climbing.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level 1: 달성 상태 + 이름 + 달성률 (항상 표시)
                  Row(
                    children: [
                      // 달성 아이콘
                      Icon(
                        goal.isAchieved ? Icons.check_circle : Icons.cancel,
                        size: 20,
                        color: goal.isAchieved ? ModernColors.success : ModernColors.error,
                      ),
                      const SizedBox(width: 8),
                      // 목표 이름
                      Expanded(
                        child: Text(
                          goal.name,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: ModernColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 달성률
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernColors.climbing.withValues(alpha: 0.15),
                              ModernColors.climbing.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(goal.achievementRate * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: ModernColors.climbing,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Level 2: 카테고리 + 목표 + 날짜 (항상 표시)
                  Row(
                    children: [
                      // 카테고리
                      Text(
                        '${goal.category} · ',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                      // 목표
                      Expanded(
                        child: Text(
                          '목표 ${goal.targetValue}',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 날짜
                      if (goal.completedAt != null)
                        Text(
                          DateFormat('M/d').format(goal.completedAt!),
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),

                  // Level 3: 상세 정보 (펼친 상태에만 표시)
                  if (isExpanded) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: ModernColors.climbing, thickness: 0.5),
                    const SizedBox(height: 12),

                    // 달성 내용
                    if (goal.achievementDetails != null && goal.achievementDetails!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.check_box_outlined,
                            size: 14,
                            color: ModernColors.climbing,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '달성 내용',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ModernColors.climbing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.achievementDetails!,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],

                    // 소감/이유
                    if (goal.reasonForResult != null && goal.reasonForResult!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 14,
                            color: ModernColors.climbing,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            goal.isAchieved ? '성공 이유' : '미달성 이유',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ModernColors.climbing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.reasonForResult!,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],

                    // 삭제 버튼
                    Align(
                      alignment: Alignment.centerRight,
                      child: MicroInteractions.tapResponse(
                        onTap: () => _deleteGoal(goal),
                        scaleDownTo: 0.95,
                        duration: MicroInteractions.fast,
                        enableHaptic: true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ModernColors.error.withValues(alpha: 0.15),
                                ModernColors.error.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ModernColors.error.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 14,
                                color: ModernColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '삭제',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: ModernColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
          delay: (150 + (index * 100)).ms,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        )
        .slideX(
          begin: 0.05,
          end: 0,
          delay: (100 + (index * 80)).ms,
          curve: Curves.easeOutQuart,
        );
  }

  /// 로딩 상태
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ModernColors.climbing),
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: ModernColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 완료된 목표가 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '목표를 완료하면 여기에 기록돼요',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 아이콘
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '운동':
        return Icons.directions_run;
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

  /// 카테고리별 색상 (타임라인 라인용)
  Color _getCategoryColor(String category) {
    switch (category) {
      case '운동':
        return ModernColors.exercise;
      case '학습':
        return ModernColors.reading;
      case '대회':
        return ModernColors.quest;
      case '자격증':
        return ModernColors.focus;
      default:
        return ModernColors.climbing;
    }
  }
}
