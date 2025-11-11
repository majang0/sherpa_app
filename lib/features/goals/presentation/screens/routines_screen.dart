import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/animation/micro_interactions.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/features/goals/providers/routine_provider.dart';
import 'package:sherpa_app/features/goals/models/routine_model.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/routine_card_widget.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/routine_modal_widget.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/previous_routines_widget.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/user_info_modal_widget.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8F5), // Soft peach (routine theme)
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60), // Safe area top

                  // Glassmorphic Header
                  _buildGlassmorphicHeader(context, ref, user),

                  const SizedBox(height: 24),

                  // Today's Completion Header (Enhanced)
                  _buildCompletionHeader(
                      completedRoutines, todayRoutines.length, completionRate),

                  const SizedBox(height: 16),

                // Section Header with Gradient Bar
                if (todayRoutines.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                ModernColors.success,
                                ModernColors.climbing,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '오늘의 루틴',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ModernColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms, curve: Curves.easeOutCubic)
                      .slideX(begin: -0.05, end: 0, delay: 350.ms, curve: Curves.easeOutQuart),

                const SizedBox(height: 16),

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
      ),
      floatingActionButton: _buildEnhancedFAB(context, ref),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Glassmorphic Header - 뒤로가기 + 사용자 정보 + 이전 기록
  Widget _buildGlassmorphicHeader(
      BuildContext context, WidgetRef ref, GlobalUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 뒤로가기 버튼
          _buildHeaderButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          // 사용자 정보 버튼
          _buildHeaderButton(
            icon: Icons.person_outline,
            onTap: () => _showUserInfoModal(context, user),
          ),
          const SizedBox(width: 8),
          // 이전 기록 버튼
          _buildHeaderButton(
            icon: Icons.history,
            onTap: () => _showPreviousRoutines(context, ref),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  /// Header Button - Glassmorphism style
  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return MicroInteractions.tapResponse(
      onTap: onTap,
      scaleDownTo: 0.95,
      enableHaptic: true,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ModernColors.success.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: ModernColors.success.withValues(alpha: 0.8),
        ),
      ),
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
            ModernColors.success,
            ModernColors.success.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ModernColors.success.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: ModernColors.success.withValues(alpha: 0.2),
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

  /// Enhanced FAB with Success Gradient and Shimmer
  Widget _buildEnhancedFAB(BuildContext context, WidgetRef ref) {
    return MicroInteractions.tapResponse(
      onTap: () => _showAddRoutineModal(context, ref),
      scaleDownTo: 0.97,
      enableHaptic: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernColors.success,
              ModernColors.success.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ModernColors.success.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              '루틴 추가',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 2000.ms,
          color: Colors.white.withValues(alpha: 0.3),
        );
  }

  /// Empty State with Glassmorphism
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ModernColors.success.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.success.withValues(alpha: 0.15),
                    ModernColors.success.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ModernColors.success.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.repeat_outlined,
                size: 64,
                color: ModernColors.success,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '오늘 할 루틴이 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '첫 루틴을 추가해보세요!',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                color: ModernColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// Routine List with Staggered Animations
  Widget _buildRoutineList(BuildContext context, List<RoutineModel> routines) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...routines.asMap().entries.map((entry) {
            final index = entry.key;
            final routine = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RoutineCardWidget(routine: routine)
                  .animate()
                  .fadeIn(
                    delay: (200 + (index * 100)).ms,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideX(
                    begin: 0.05,
                    end: 0,
                    delay: (150 + (index * 80)).ms,
                    curve: Curves.easeOutQuart,
                  )
                  .scale(
                    begin: const Offset(0.96, 0.96),
                    end: const Offset(1.0, 1.0),
                    delay: (150 + (index * 80)).ms,
                  ),
            );
          }),
        ],
      ),
    );
  }

  /// Show User Info Modal
  void _showUserInfoModal(BuildContext context, GlobalUser user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => UserInfoDialogWidget(user: user),
    );
  }

  /// Show Previous Routines
  void _showPreviousRoutines(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const PreviousRoutinesDialog(),
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
