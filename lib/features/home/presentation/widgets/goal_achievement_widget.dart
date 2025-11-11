import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Core
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/animation/micro_interactions.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

// Shared Widgets
import '../../../../shared/widgets/section_header.dart';

// Shared Providers
import 'package:sherpa_app/shared/providers/level_1_user_data/global_point_provider.dart';
import 'package:sherpa_app/shared/providers/level_3_ai/global_sherpi_provider.dart';

// Shared Utils
import '../../../../shared/utils/haptic_feedback_manager.dart';

// Feature Providers (Goals)
import '../../../goals/providers/goal_provider.dart';
import '../../../goals/providers/routine_provider.dart';
import '../../../goals/models/goal_model.dart';
import '../../../goals/models/routine_model.dart';
import '../../../goals/utils/category_helpers.dart';

/// 목표 달성하기 홈 위젯 (2025 Modern Redesign)
///
/// 홈 화면에 표시되는 목표 달성 기능
/// - 다가오는 목표 3개 미리보기
/// - 오늘의 루틴 체크리스트 (홈에서 바로 체크)
/// - Glassmorphism + ModernColors 디자인
class GoalAchievementWidget extends ConsumerStatefulWidget {
  const GoalAchievementWidget({super.key});

  @override
  ConsumerState<GoalAchievementWidget> createState() =>
      _GoalAchievementWidgetState();
}

class _GoalAchievementWidgetState extends ConsumerState<GoalAchievementWidget> {
  /// 셰르피 감정 결정 (루틴 완료율 기반)
  SherpiEmotion _getSherpiEmotion(double completionRate) {
    if (completionRate >= 1.0) {
      return SherpiEmotion.special; // 모든 루틴 완료
    } else if (completionRate >= 0.7) {
      return SherpiEmotion.cheering; // 거의 완료 (70% 이상)
    } else {
      return SherpiEmotion.thinking; // 진행 중
    }
  }

  /// D-day 계산
  String _calculateDDay(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final difference = target.difference(today).inDays;

    if (difference < 0) {
      return 'D+${-difference}';
    } else if (difference == 0) {
      return 'D-Day';
    } else {
      return 'D-$difference';
    }
  }

  /// 루틴 체크 토글
  Future<void> _toggleRoutineCheck(RoutineModel routine) async {
    HapticFeedbackManager.mediumImpact();
    final isChecked = routine.isCheckedToday();

    if (isChecked) {
      await ref.read(routineProvider.notifier).uncheckRoutine(routine.id);
    } else {
      await ref.read(routineProvider.notifier).checkRoutine(routine.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider 데이터
    final goals = ref.watch(goalProvider);
    final todayRoutines = ref.watch(todayRoutinesProvider);
    final completionRate = ref.watch(todayCompletionRateProvider);
    final totalPoints = ref.watch(globalTotalPointsProvider);

    // 다가오는 목표 2개 (대표 목표 우선 + 날짜가 가까운 순)
    final upcomingGoals = goals.where((g) => !g.isAchieved).toList();

    // 대표 목표와 일반 목표 분리
    final representativeGoal = upcomingGoals.where((g) => g.isRepresentative).toList();
    final otherGoals = upcomingGoals.where((g) => !g.isRepresentative).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // 대표 목표(1개) + 나머지 최신 목표(1개)
    final topGoals = <GoalModel>[
      ...representativeGoal.take(1),
      ...otherGoals.take(representativeGoal.isEmpty ? 2 : 1),
    ];

    // 셰르피 감정
    final sherpiEmotion = _getSherpiEmotion(completionRate);
    final canAnalyze = totalPoints >= 30;

    return Container(
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow:
            ModernColors.softShadow(primaryColor: ModernColors.modernPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더 (그라디언트 블루 + 셰르피)
          _buildHeader(sherpiEmotion),

          // 2. 다가오는 목표 섹션
          if (topGoals.isNotEmpty) _buildUpcomingGoalsSection(topGoals),

          // 3. 오늘의 루틴 체크리스트 섹션
          if (todayRoutines.isNotEmpty)
            _buildTodayRoutinesSection(todayRoutines, completionRate),

          // 4. Empty State (목표도 루틴도 없는 경우)
          if (topGoals.isEmpty && todayRoutines.isEmpty) _buildEmptyState(),

          // 5. 셰르피 분석 버튼
          _buildAnalysisButton(canAnalyze, totalPoints),
        ],
      ),
    );
  }

  /// 1. 헤더 섹션 (그라디언트 블루 + 셰르피 캐릭터)
  Widget _buildHeader(SherpiEmotion emotion) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.modernPrimary,
            ModernColors.primaryLight,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: ModernColors.premiumShadow(
          primaryColor: ModernColors.modernPrimary,
          lightColor: ModernColors.primaryLight,
        ),
      ),
      child: Row(
        children: [
          // 셰르피 캐릭터
          Semantics(
            label: '셰르피 캐릭터 탭하여 격려 메시지 보기',
            button: true,
            child: MicroInteractions.tapResponse(
              onTap: () {
                ref.read(sherpiProvider.notifier).showMessage(
                      context: SherpiContext.encouragement,
                      emotion: emotion,
                    );
              },
              scaleDownTo: 0.95,
              enableHaptic: true,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primaryLight.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: ModernColors.modernPrimary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: 1.32,
                    child: Image.asset(
                      emotion.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '목표 달성하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '셰르피와 함께 목표를 달성해요!',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 0.5),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. 다가오는 목표 섹션
  Widget _buildUpcomingGoalsSection(List<GoalModel> topGoals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        SectionHeader(
          title: '다가오는 목표',
          primaryColor: ModernColors.climbing,
          secondaryColor: ModernColors.success,
          titleFontSize: 18,
          horizontalPadding: 20,
          topPadding: 20,
          bottomPadding: 12,
          trailing: Semantics(
            label: '목표 전체 보기',
            button: true,
            child: MicroInteractions.tapResponse(
              onTap: () => Navigator.pushNamed(context, '/goals'),
              scaleDownTo: 0.95,
              enableHaptic: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체 보기',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.modernPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: ModernColors.modernPrimary,
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .slideX(begin: -0.05, end: 0, delay: 50.ms),

        // 목표 카드들
        ...topGoals.asMap().entries.map((entry) {
          final index = entry.key;
          final goal = entry.value;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _buildGoalPreviewCard(goal, index),
          );
        }),

        const SizedBox(height: 8),
      ],
    );
  }

  /// 개별 목표 미리보기 카드
  Widget _buildGoalPreviewCard(GoalModel goal, int index) {
    final dDay = _calculateDDay(goal.date);
    final categoryIcon = GoalCategoryHelpers.getIcon(goal.category);
    final categoryColor = GoalCategoryHelpers.getColor(goal.category);

    return Semantics(
      label: '${goal.category} 목표: ${goal.name}',
      button: true,
      child: MicroInteractions.tapResponse(
        onTap: () => Navigator.pushNamed(context, '/goals'),
        scaleDownTo: 0.98,
        enableHaptic: true,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 카테고리 아이콘
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor,
                      categoryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  categoryIcon,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),

              // 목표 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 목표 이름 (대표 목표 별 표시)
                    Row(
                      children: [
                        // 대표 목표 별 아이콘
                        if (goal.isRepresentative)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber,
                                    Colors.amber.withValues(alpha: 0.85),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            goal.name,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ModernColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // D-day + 날짜
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dDay,
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.calendar_today,
                          size: 11,
                          color:
                              ModernColors.textSecondary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${goal.date.month}/${goal.date.day}',
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // 목표값
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          size: 11,
                          color:
                              ModernColors.textSecondary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '목표: ${goal.targetValue}',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: ModernColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: (150 + (index * 80)).ms,
            duration: 500.ms,
            curve: Curves.easeOutCubic)
        .slideX(
            begin: 0.05,
            end: 0,
            delay: (100 + (index * 60)).ms,
            curve: Curves.easeOutQuart)
        .scale(
            begin: const Offset(0.97, 0.97),
            end: const Offset(1.0, 1.0),
            delay: (100 + (index * 60)).ms);
  }

  /// 3. 오늘의 루틴 체크리스트 섹션
  Widget _buildTodayRoutinesSection(
    List<RoutineModel> routines,
    double completionRate,
  ) {
    final completedCount = routines.where((r) => r.isCheckedToday()).length;
    final displayRate = (completionRate * 100).round();
    final displayRoutines = routines.take(3).toList(); // 최대 3개만 표시

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        SectionHeader(
          title: '오늘의 루틴',
          primaryColor: ModernColors.success,
          secondaryColor: ModernColors.climbing,
          titleFontSize: 18,
          horizontalPadding: 20,
          topPadding: 12,
          bottomPadding: 12,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 완료율 칩
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ModernColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/${routines.length} · $displayRate%',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.success,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 전체 보기 링크
              Semantics(
                label: '루틴 전체 보기',
                button: true,
                child: MicroInteractions.tapResponse(
                  onTap: () => Navigator.pushNamed(context, '/routines'),
                  scaleDownTo: 0.95,
                  enableHaptic: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체 보기',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.success,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: ModernColors.success,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 150.ms, duration: 400.ms)
            .slideX(begin: -0.05, end: 0, delay: 100.ms),

        // 루틴 체크리스트
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.success.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: displayRoutines.asMap().entries.map((entry) {
                final index = entry.key;
                final routine = entry.value;
                return Column(
                  children: [
                    if (index > 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: ModernColors.borderLight,
                      ),
                    _buildRoutineCheckItem(routine, index),
                  ],
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(
              begin: const Offset(0.98, 0.98),
              end: const Offset(1.0, 1.0),
              duration: 400.ms,
              curve: Curves.easeOutBack),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  /// 개별 루틴 체크 아이템
  Widget _buildRoutineCheckItem(RoutineModel routine, int index) {
    final isChecked = routine.isCheckedToday();
    final categoryIcon = RoutineCategoryHelpers.getIcon(routine.category);

    return Semantics(
      label: '${routine.name} ${isChecked ? "완료됨" : "미완료"}',
      button: true,
      checked: isChecked,
      child: MicroInteractions.tapResponse(
        onTap: () => _toggleRoutineCheck(routine),
        scaleDownTo: 0.98,
        enableHaptic: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              // 카테고리 아이콘
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: ModernColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  categoryIcon,
                  size: 14,
                  color: ModernColors.success,
                ),
              ),
              const SizedBox(width: 10),

              // 체크박스
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: isChecked
                      ? const LinearGradient(
                          colors: [
                            ModernColors.success,
                            ModernColors.climbing,
                          ],
                        )
                      : null,
                  color: isChecked ? null : Colors.transparent,
                  border: isChecked
                      ? null
                      : Border.all(
                          color:
                              ModernColors.textSecondary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              )
                  .animate(
                    target: isChecked ? 1 : 0,
                  )
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.15, 1.15),
                    duration: 150.ms,
                    curve: Curves.easeOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.15, 1.15),
                    end: const Offset(1.0, 1.0),
                    duration: 150.ms,
                    curve: Curves.easeIn,
                  ),

              const SizedBox(width: 12),

              // 루틴 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.name,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isChecked
                            ? ModernColors.textSecondary
                            : ModernColors.textPrimary,
                        decoration:
                            isChecked ? TextDecoration.lineThrough : null,
                        decorationColor: ModernColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      routine.frequency,
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color:
                            ModernColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // 완료 표시
              if (isChecked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ModernColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '완료',
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.success,
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 200.ms,
                      curve: Curves.easeOutBack,
                    ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: (200 + (index * 40)).ms,
            duration: 400.ms,
            curve: Curves.easeOut)
        .slideX(begin: 0.03, end: 0, delay: (180 + (index * 30)).ms);
  }

  /// Empty State
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: ModernColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '목표와 루틴을 추가해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '셰르피가 목표 달성을 도와드려요!',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 4. 셰르피 분석 버튼
  Widget _buildAnalysisButton(bool canAnalyze, int totalPoints) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: MicroInteractions.tapResponse(
        onTap: canAnalyze
            ? () {
                Navigator.pushNamed(context, '/ai_analysis');
                HapticFeedbackManager.lightImpact();
              }
            : () {
                HapticFeedbackManager.lightImpact();
                _showPointInsufficientDialog(totalPoints);
              },
        scaleDownTo: 0.97,
        enableHaptic: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: canAnalyze
                ? const LinearGradient(
                    colors: [
                      ModernColors.modernPrimary,
                      ModernColors.primaryLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: canAnalyze ? null : ModernColors.modernTextSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: canAnalyze
                ? ModernColors.premiumShadow(
                    primaryColor: ModernColors.modernPrimary,
                    lightColor: ModernColors.primaryLight,
                  )
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                canAnalyze ? '셰르피가 목표를 분석해요' : '포인트가 부족해요',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '30P',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 250.ms, duration: 400.ms)
          .slideY(begin: 0.05, end: 0, delay: 200.ms),
    );
  }

  /// 포인트 부족 다이얼로그
  void _showPointInsufficientDialog(int totalPoints) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: ModernColors.warning,
            ),
            const SizedBox(width: 8),
            Text(
              '포인트가 부족해요',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          '셰르피 분석에 30포인트가 필요합니다.\n\n현재 포인트: ${totalPoints}P\n필요 포인트: 30P',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: ModernColors.modernTextSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.modernPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
