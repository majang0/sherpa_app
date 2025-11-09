import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/providers/level_1_user_data/global_user_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../providers/goal_provider.dart';
import '../../providers/routine_provider.dart';
import '../../models/goal_model.dart';
import '../widgets/goal_card_widget.dart';
import '../widgets/goal_modal_widget.dart';
import '../widgets/previous_goals_widget.dart';
import '../widgets/user_info_modal_widget.dart';
import '../widgets/hero_header_widget.dart';
import '../widgets/action_buttons_section_widget.dart';
import '../widgets/statistics_overview_widget.dart';
import '../widgets/ai_analysis_modal_widget.dart';

/// 목표 화면 (2025 Material Design 3 Redesign)
///
/// 사용자가 설정한 목표를 관리합니다.
/// 2025 트렌드: Glass morphism, generous spacing, hero sections, statistics visualization
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    final goals = ref.watch(goalProvider);
    final todayRoutines = ref.watch(todayRoutinesProvider);
    final completedRoutines = ref.watch(todayCompletedCountProvider);
    final completionRate = ref.watch(todayCompletionRateProvider);

    // Calculate goal statistics
    final now = DateTime.now();
    final achievedGoals =
        goals.where((g) => g.completedAt != null && (g.isAchieved ?? false)).length;
    final inProgressGoals = goals
        .where((g) => g.completedAt == null && g.date.isAfter(now))
        .length;
    final upcomingGoals =
        goals.where((g) => g.completedAt == null && g.date.isAfter(now)).length;

    return Scaffold(
      backgroundColor: ModernColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: ModernColors.background,
            elevation: 0,
            title: Text(
              '목표',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
            centerTitle: false,
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header Section
                HeroHeaderWidget(
                  user: user,
                  activeGoalsCount: goals.length,
                  completedRoutines: completedRoutines,
                  totalRoutines: todayRoutines.length,
                  completionRate: completionRate,
                ),

                const SizedBox(height: 16),

                // Action Buttons Section
                ActionButtonsSectionWidget(
                  onUserInfoTap: () => _showUserInfoModal(context, user),
                  onHistoryTap: () => _showPreviousGoals(context, ref),
                  onAIAnalysisTap: () => _showAIAnalysis(context, ref),
                ),

                const SizedBox(height: 4),

                // Statistics Overview
                if (goals.isNotEmpty)
                  StatisticsOverviewWidget(
                    achievedCount: achievedGoals,
                    inProgressCount: inProgressGoals,
                    upcomingCount: upcomingGoals,
                    totalCount: goals.length,
                  ),

                // Goals List or Empty State
                goals.isEmpty
                    ? _buildEmptyState(context)
                    : _buildGoalList(context, goals),

                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildEnhancedFAB(context, ref),
    );
  }

  /// Enhanced FAB with Gradient
  Widget _buildEnhancedFAB(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddGoalModal(context, ref),
      backgroundColor: Colors.transparent,
      elevation: 0,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernColors.quest,
              ModernColors.questLight.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: ModernColors.quest.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: ModernColors.questLight.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              '목표 추가',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ModernColors.quest.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag_outlined,
                size: 60,
                color: ModernColors.quest.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '아직 설정된 목표가 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 목표를 추가해보세요!',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Goal List
  Widget _buildGoalList(BuildContext context, List<GoalModel> goals) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...goals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoalCardWidget(goal: goal),
              )),
        ],
      ),
    );
  }

  /// Show User Info Modal
  void _showUserInfoModal(BuildContext context, GlobalUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserInfoModalWidget(user: user),
    );
  }

  /// Show Previous Goals
  void _showPreviousGoals(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PreviousGoalsWidget(),
      ),
    );
  }

  /// Show AI Analysis Modal
  void _showAIAnalysis(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIAnalysisModalWidget(isGoalsScreen: true),
    );
  }

  /// Show Add Goal Modal
  void _showAddGoalModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoalModalWidget(),
    );
  }
}
