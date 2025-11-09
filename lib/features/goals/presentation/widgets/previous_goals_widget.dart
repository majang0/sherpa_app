import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/widgets/sherpa_clean_app_bar.dart';
import 'package:sherpa_app/shared/widgets/sherpa_card.dart';
import 'package:sherpa_app/features/goals/models/goal_model.dart';
import 'package:sherpa_app/features/goals/providers/goal_provider.dart';

/// 이전 목표 화면
///
/// 완료되거나 보관된 목표를 표시하는 전체 화면
class PreviousGoalsWidget extends ConsumerStatefulWidget {
  const PreviousGoalsWidget({super.key});

  @override
  ConsumerState<PreviousGoalsWidget> createState() =>
      _PreviousGoalsWidgetState();
}

class _PreviousGoalsWidgetState extends ConsumerState<PreviousGoalsWidget> {
  List<GoalModel> _previousGoals = [];
  List<GoalModel> _filteredGoals = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String? _selectedStatus; // 'achieved', 'unachieved', null (all)
  String _sortBy = 'date'; // 'date', 'achievement'

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
        // Category filter
        if (_selectedCategory != null && goal.category != _selectedCategory) {
          return false;
        }
        // Status filter
        if (_selectedStatus == 'achieved' && !goal.isAchieved) {
          return false;
        }
        if (_selectedStatus == 'unachieved' && goal.isAchieved) {
          return false;
        }
        return true;
      }).toList();

      // Sort
      if (_sortBy == 'date') {
        _filteredGoals.sort((a, b) => (b.completedAt ?? DateTime.now())
            .compareTo(a.completedAt ?? DateTime.now()));
      } else if (_sortBy == 'achievement') {
        _filteredGoals.sort((a, b) => b.achievementRate.compareTo(a.achievementRate));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: const SherpaCleanAppBar(
        title: '이전 목표',
        backgroundColor: ModernColors.background,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _previousGoals.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildStatisticsCard(),
                    _buildFiltersRow(),
                    Expanded(child: _buildGoalList()),
                  ],
                ),
    );
  }

  /// 통계 카드
  Widget _buildStatisticsCard() {
    final totalGoals = _previousGoals.length;
    final achievedGoals = _previousGoals.where((g) => g.isAchieved).length;
    final achievedPercentage = totalGoals > 0 ? (achievedGoals / totalGoals * 100) : 0.0;
    final avgAchievementRate = totalGoals > 0
        ? _previousGoals.map((g) => g.achievementRate).reduce((a, b) => a + b) / totalGoals
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.quest.withValues(alpha: 0.15),
            ModernColors.climbing.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernColors.quest.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ModernColors.quest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: ModernColors.quest,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '목표 성과 분석',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '총 목표',
                  totalGoals.toString(),
                  Icons.flag_outlined,
                  ModernColors.quest,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '달성률',
                  '${achievedPercentage.toStringAsFixed(0)}%',
                  Icons.check_circle_outline,
                  ModernColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '달성',
                  achievedGoals.toString(),
                  Icons.emoji_events_outlined,
                  ModernColors.joyBright,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '평균 달성률',
                  '${(avgAchievementRate * 100).toStringAsFixed(0)}%',
                  Icons.trending_up,
                  ModernColors.climbing,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 및 정렬 행
  Widget _buildFiltersRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 카테고리 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
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
                    child: _buildFilterChip(
                      label: category,
                      isSelected: _selectedCategory == category,
                      color: _getCategoryColor(category),
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
          const SizedBox(height: 8),
          // 상태 및 정렬 필터
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: '모두',
                        isSelected: _selectedStatus == null,
                        onTap: () {
                          setState(() {
                            _selectedStatus = null;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: '달성',
                        isSelected: _selectedStatus == 'achieved',
                        color: ModernColors.joyBright,
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'achieved';
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: '미달성',
                        isSelected: _selectedStatus == 'unachieved',
                        color: ModernColors.error,
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'unachieved';
                            _applyFilters();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                    _applyFilters();
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'date',
                    child: Text('날짜순'),
                  ),
                  const PopupMenuItem(
                    value: 'achievement',
                    child: Text('달성률순'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ModernColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ModernColors.quest.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sort,
                        size: 16,
                        color: ModernColors.quest,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _sortBy == 'date' ? '날짜순' : '달성률순',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.quest,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 필터 칩
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? ModernColors.quest;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : ModernColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? chipColor
                : ModernColors.textSecondary.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? chipColor : ModernColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 로딩 상태
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ModernColors.quest),
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
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
          ),
        ],
      ),
    );
  }

  /// 목표 리스트
  Widget _buildGoalList() {
    if (_filteredGoals.isEmpty) {
      return Center(
        child: Padding(
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
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredGoals.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildGoalCard(_filteredGoals[index]),
        );
      },
    );
  }

  /// 개별 목표 카드
  Widget _buildGoalCard(GoalModel goal) {
    final categoryColor = _getCategoryColor(goal.category);

    return SherpaCard(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernColors.surface,
              categoryColor.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 카테고리 + 달성 상태
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryChip(goal),
                  _buildAchievementBadge(goal),
                ],
              ),
              const SizedBox(height: 16),

              // 목표 이름
              Text(
                goal.name,
                style: GoogleFonts.notoSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ModernColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // 목표값 & 날짜
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.flag_outlined,
                      '목표: ${goal.targetValue}',
                      categoryColor,
                    ),
                  ),
                ],
              ),
              if (goal.completedAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  DateFormat('yyyy.MM.dd').format(goal.completedAt!),
                  ModernColors.textSecondary,
                ),
              ],
              const SizedBox(height: 16),

              // 달성률 프로그레스 바
              _buildAchievementProgress(goal),

              // 달성 상세 정보
              if (goal.achievementDetails != null &&
                  goal.achievementDetails!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '달성 내용',
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal.achievementDetails!,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 결과 사유
              if (goal.reasonForResult != null &&
                  goal.reasonForResult!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: goal.isAchieved
                        ? ModernColors.joyPastel.withValues(alpha: 0.3)
                        : ModernColors.error.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: goal.isAchieved
                          ? ModernColors.joyLight
                          : ModernColors.error.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            goal.isAchieved
                                ? Icons.lightbulb_outline
                                : Icons.error_outline,
                            size: 16,
                            color: goal.isAchieved
                                ? ModernColors.joyBright
                                : ModernColors.error,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            goal.isAchieved ? '성공 이유' : '미달성 이유',
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: goal.isAchieved
                                  ? ModernColors.joyBright
                                  : ModernColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal.reasonForResult!,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// 달성률 프로그레스
  Widget _buildAchievementProgress(GoalModel goal) {
    final percentage = goal.achievementRate * 100;
    final categoryColor = _getCategoryColor(goal.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '달성률',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ModernColors.textSecondary,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: categoryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: goal.achievementRate,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 카테고리 칩
  Widget _buildCategoryChip(GoalModel goal) {
    final categoryColor = _getCategoryColor(goal.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.15),
            categoryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        goal.category,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: categoryColor,
        ),
      ),
    );
  }

  /// 달성 뱃지
  Widget _buildAchievementBadge(GoalModel goal) {
    final isAchieved = goal.isAchieved;
    final badgeColor = isAchieved
        ? ModernColors.joyBright
        : ModernColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withValues(alpha: 0.15),
            badgeColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAchieved ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            isAchieved ? '달성' : '미달성',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리별 색상
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
        return ModernColors.quest;
    }
  }
}
