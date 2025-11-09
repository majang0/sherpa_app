import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/widgets/sherpa_card.dart';
import '../../models/routine_model.dart';
import '../../providers/routine_provider.dart';

/// 완료한 루틴 화면
///
/// 완료되거나 종료된 루틴을 표시하는 전체 화면
class PreviousRoutinesWidget extends ConsumerStatefulWidget {
  const PreviousRoutinesWidget({super.key});

  @override
  ConsumerState<PreviousRoutinesWidget> createState() =>
      _PreviousRoutinesWidgetState();
}

class _PreviousRoutinesWidgetState
    extends ConsumerState<PreviousRoutinesWidget> {
  List<RoutineModel> _previousRoutines = [];
  List<RoutineModel> _filteredRoutines = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String? _selectedStatus; // 'completed', 'unfinished', null (all)
  String _sortBy = 'date'; // 'date', 'completion'

  @override
  void initState() {
    super.initState();
    _loadPreviousRoutines();
  }

  Future<void> _loadPreviousRoutines() async {
    setState(() => _isLoading = true);
    final routines =
        await ref.read(routineProvider.notifier).loadPreviousRoutines();
    setState(() {
      _previousRoutines = routines;
      _filteredRoutines = routines;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRoutines = _previousRoutines.where((routine) {
        // Category filter
        if (_selectedCategory != null &&
            routine.category != _selectedCategory) {
          return false;
        }
        // Status filter
        if (_selectedStatus == 'completed' && !routine.isCompleted) {
          return false;
        }
        if (_selectedStatus == 'unfinished' && routine.isCompleted) {
          return false;
        }
        return true;
      }).toList();

      // Sort
      if (_sortBy == 'date') {
        _filteredRoutines.sort((a, b) =>
            (b.finishedAt ?? DateTime.now())
                .compareTo(a.finishedAt ?? DateTime.now()));
      } else if (_sortBy == 'completion') {
        _filteredRoutines
            .sort((a, b) => b.completionRate.compareTo(a.completionRate));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: SherpaCleanAppBar(
        title: '완료한 루틴',
        backgroundColor: ModernColors.background,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _previousRoutines.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildStatisticsCard(),
                    _buildFiltersRow(),
                    Expanded(child: _buildRoutineList()),
                  ],
                ),
    );
  }

  /// 통계 카드
  Widget _buildStatisticsCard() {
    final totalRoutines = _previousRoutines.length;
    final completedRoutines = _previousRoutines.where((r) => r.isCompleted).length;
    final completedPercentage =
        totalRoutines > 0 ? (completedRoutines / totalRoutines * 100) : 0.0;
    final avgCompletionRate = totalRoutines > 0
        ? _previousRoutines
                .map((r) => r.completionRate)
                .reduce((a, b) => a + b) /
            totalRoutines
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.exercise.withValues(alpha: 0.15),
            ModernColors.focus.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernColors.exercise.withValues(alpha: 0.3),
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
                  color: ModernColors.exercise.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_graph_outlined,
                  color: ModernColors.exercise,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '루틴 성과 분석',
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
                  '총 루틴',
                  totalRoutines.toString(),
                  Icons.repeat,
                  ModernColors.exercise,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '완주율',
                  '${completedPercentage.toStringAsFixed(0)}%',
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
                  '완주',
                  completedRoutines.toString(),
                  Icons.emoji_events_outlined,
                  ModernColors.joyBright,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '평균 달성률',
                  '${(avgCompletionRate * 100).toStringAsFixed(0)}%',
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
  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
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
                ...RoutineCategory.all.map((category) {
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
                        label: '완주',
                        isSelected: _selectedStatus == 'completed',
                        color: ModernColors.joyBright,
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'completed';
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: '미완주',
                        isSelected: _selectedStatus == 'unfinished',
                        color: ModernColors.error,
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'unfinished';
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
                    value: 'completion',
                    child: Text('달성률순'),
                  ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ModernColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ModernColors.exercise.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sort,
                        size: 16,
                        color: ModernColors.exercise,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _sortBy == 'date' ? '날짜순' : '달성률순',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.exercise,
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
    final chipColor = color ?? ModernColors.exercise;
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
        valueColor: AlwaysStoppedAnimation<Color>(ModernColors.exercise),
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
            '아직 완료한 루틴이 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '루틴을 완료하면 여기에 기록돼요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 루틴 리스트
  Widget _buildRoutineList() {
    if (_filteredRoutines.isEmpty) {
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
                '필터 조건에 맞는 루틴이 없어요',
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
      itemCount: _filteredRoutines.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildRoutineCard(_filteredRoutines[index]),
        );
      },
    );
  }

  /// 개별 루틴 카드
  Widget _buildRoutineCard(RoutineModel routine) {
    final categoryColor = _getCategoryColor(routine.category);
    final completedDays = routine.checkHistory.length;
    final endDate = routine.finishedAt ?? DateTime.now();
    final startDate = routine.createdAt ?? DateTime.now();
    final totalDays = endDate.difference(startDate).inDays + 1;

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
              // 헤더: 카테고리 + 완주 상태
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryChip(routine),
                  _buildCompletedBadge(routine),
                ],
              ),
              const SizedBox(height: 16),

              // 루틴 이름
              Text(
                routine.name,
                style: GoogleFonts.notoSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ModernColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // 빈도 & 시간대
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.repeat,
                      routine.frequency,
                      categoryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.schedule,
                routine.timePreference ?? '시간 미정',
                ModernColors.textSecondary,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                '${routine.createdAt != null ? DateFormat('yyyy.MM.dd').format(routine.createdAt!) : '시작일 미상'} ~ ${routine.finishedAt != null ? DateFormat('yyyy.MM.dd').format(routine.finishedAt!) : '진행중'}',
                ModernColors.textSecondary,
              ),
              const SizedBox(height: 16),

              // 달성률 프로그레스
              _buildCompletionProgress(routine),

              const SizedBox(height: 16),

              // 통계 카드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withValues(alpha: 0.05),
                      categoryColor.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatsColumn(
                      icon: Icons.check_circle_outline,
                      label: '완료',
                      value: '$completedDays일',
                      color: ModernColors.joyBright,
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: categoryColor.withValues(alpha: 0.2),
                    ),
                    _buildStatsColumn(
                      icon: Icons.calendar_month,
                      label: '총 일수',
                      value: '$totalDays일',
                      color: ModernColors.textSecondary,
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: categoryColor.withValues(alpha: 0.2),
                    ),
                    _buildStatsColumn(
                      icon: Icons.local_fire_department,
                      label: '연속',
                      value: _calculateStreak(routine),
                      color: ModernColors.climbing,
                    ),
                  ],
                ),
              ),
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
  Widget _buildCompletionProgress(RoutineModel routine) {
    final percentage = routine.completionRate * 100;
    final categoryColor = _getCategoryColor(routine.category);

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
                color: _getCompletionRateColor(routine.completionRate),
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
                widthFactor: routine.completionRate,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCompletionRateColor(routine.completionRate),
                        _getCompletionRateColor(routine.completionRate)
                            .withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _getCompletionRateColor(routine.completionRate)
                            .withValues(alpha: 0.3),
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

  /// 통계 컬럼
  Widget _buildStatsColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 연속 일수 계산
  String _calculateStreak(RoutineModel routine) {
    if (routine.checkHistory.isEmpty) return '0일';

    // Sort check history dates
    final sortedDates = routine.checkHistory.map((dateStr) {
      return DateTime.parse(dateStr);
    }).toList()
      ..sort();

    // Calculate longest streak
    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return '$longestStreak일';
  }

  /// 카테고리 칩
  Widget _buildCategoryChip(RoutineModel routine) {
    final categoryColor = _getCategoryColor(routine.category);
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
        routine.category,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: categoryColor,
        ),
      ),
    );
  }

  /// 완주 뱃지
  Widget _buildCompletedBadge(RoutineModel routine) {
    final isCompleted = routine.isCompleted;
    final badgeColor = isCompleted
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
            isCompleted ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted ? '완주' : '미완주',
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
      case '문화':
        return ModernColors.quest;
      case '학습':
        return ModernColors.reading;
      case '건강':
        return ModernColors.focus;
      case '기타':
        return ModernColors.meeting;
      default:
        return ModernColors.exercise;
    }
  }

  /// 완료율에 따른 색상
  Color _getCompletionRateColor(double rate) {
    if (rate >= 0.8) return ModernColors.joyBright;
    if (rate >= 0.5) return ModernColors.exercise;
    return ModernColors.error;
  }
}
