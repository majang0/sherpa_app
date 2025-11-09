import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/features/goals/providers/routine_provider.dart';
import 'package:sherpa_app/features/goals/models/routine_model.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/routine_card_widget.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/routine_modal_widget.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/previous_routines_widget.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/user_info_modal_widget.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/action_buttons_section_widget.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/gamification_section_widget.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/ai_analysis_modal_widget.dart';

/// 루틴 화면 (2025 Material Design 3 Redesign)
///
/// 사용자가 설정한 루틴을 관리합니다.
/// 2025 트렌드: Glass morphism, gamification, generous spacing, streak visualization
class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    final todayRoutines = ref.watch(todayRoutinesProvider);
    final completedRoutines = ref.watch(todayCompletedCountProvider);
    final completionRate = ref.watch(todayCompletionRateProvider);

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
              '루틴',
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
                const SizedBox(height: 16),

                // Action Buttons Section
                ActionButtonsSectionWidget(
                  onUserInfoTap: () => _showUserInfoModal(context, user),
                  onHistoryTap: () => _showPreviousRoutines(context, ref),
                  onAIAnalysisTap: () => _showAIAnalysis(context, ref),
                ),

                const SizedBox(height: 4),

                // Today's Completion Header (Enhanced)
                _buildCompletionHeader(
                    completedRoutines, todayRoutines.length, completionRate),

                // Gamification Section (NEW!)
                const GamificationSectionWidget(
                  currentStreak: 7, // TODO: Calculate from routine data
                  longestStreak: 21,
                  averageStreak: 14,
                  progressToNextLevel: 0.7,
                  daysToNextLevel: 3,
                ),

                const SizedBox(height: 8),

                // Section Title
                if (todayRoutines.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '오늘의 루틴',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Routine List or Empty State
                todayRoutines.isEmpty
                    ? _buildEmptyState(context)
                    : _buildRoutineList(context, todayRoutines),

                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildEnhancedFAB(context, ref),
    );
  }

  /// Completion Header (Enhanced)
  Widget _buildCompletionHeader(
      int completedCount, int totalCount, double completionRate) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.meeting,
            ModernColors.meeting.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ModernColors.meeting.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: ModernColors.meeting.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 루틴 달성률',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/$totalCount 완료',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${(completionRate * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.notoSans(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced FAB with Gradient
  Widget _buildEnhancedFAB(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddRoutineModal(context, ref),
      backgroundColor: Colors.transparent,
      elevation: 0,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernColors.meeting,
              ModernColors.meeting.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: ModernColors.meeting.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: ModernColors.meeting.withValues(alpha: 0.3),
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
              '루틴 추가',
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
                color: ModernColors.meeting.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.repeat_outlined,
                size: 60,
                color: ModernColors.meeting.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '오늘 할 루틴이 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 루틴을 추가해보세요!',
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

  /// Routine List
  Widget _buildRoutineList(BuildContext context, List<RoutineModel> routines) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...routines.map((routine) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RoutineCardWidget(routine: routine),
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

  /// Show Previous Routines
  void _showPreviousRoutines(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PreviousRoutinesWidget(),
      ),
    );
  }

  /// Show AI Analysis Modal
  void _showAIAnalysis(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIAnalysisModalWidget(isGoalsScreen: false),
    );
  }

  /// Show Add Routine Modal
  void _showAddRoutineModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RoutineModalWidget(),
    );
  }
}
