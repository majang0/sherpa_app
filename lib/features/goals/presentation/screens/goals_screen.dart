import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/modern_colors.dart';
import '../../../../core/animation/micro_interactions.dart';
import '../../../../shared/providers/level_1_user_data/global_user_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../providers/goal_provider.dart';
import '../widgets/goal_card_widget.dart';
import '../widgets/goal_modal_widget.dart';
import '../widgets/previous_goals_widget.dart';
import '../widgets/user_info_modal_widget.dart';

/// 목표 화면 (Simple Clean Design)
///
/// 레이아웃:
/// 1. Header - 뒤로가기 + 사용자 정보 + 이전 기록 버튼
/// 2. Goal List - Glassmorphism Goal Cards
/// 3. Gradient FAB - 새 목표 추가
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    final goals = ref.watch(goalProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF5F9FF), // Light blue
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header - 뒤로가기 + 사용자 정보 + 이전 기록 버튼
            SliverToBoxAdapter(
              child: _buildSimpleHeader(context, user, ref),
            ),

            // Section Header
            if (goals.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildSectionHeader(goals.length)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideX(begin: -0.05, end: 0, delay: 150.ms),
              ),

            // Goals List or Empty State
            goals.isEmpty
                ? SliverToBoxAdapter(
                    child: _buildEmptyState(context, ref),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final goal = goals[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GoalCardWidget(goal: goal),
                          )
                              .animate()
                              .fadeIn(
                                  delay: (200 + (index * 100)).ms,
                                  duration: 600.ms,
                                  curve: Curves.easeOutCubic)
                              .slideX(
                                  begin: 0.05,
                                  end: 0,
                                  delay: (150 + (index * 80)).ms,
                                  curve: Curves.easeOutQuart)
                              .scale(
                                  begin: const Offset(0.96, 0.96),
                                  end: const Offset(1.0, 1.0),
                                  delay: (150 + (index * 80)).ms);
                        },
                        childCount: goals.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: _buildGradientFAB(context, ref),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Simple Header - 뒤로가기 버튼만
  Widget _buildSimpleHeader(BuildContext context, GlobalUser user, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
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
            onTap: () => _showPreviousGoals(context, ref),
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
              color: ModernColors.primary.withValues(alpha: 0.08),
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
          color: ModernColors.primary.withValues(alpha: 0.8),
        ),
      ),
    );
  }


  /// Section Header - "나의 목표"
  Widget _buildSectionHeader(int goalCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.climbing,
                      ModernColors.success,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '나의 목표',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Text(
            '총 $goalCount개',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary.withValues(alpha: 0.7),
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State - 목표가 없을 때
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 40, 24, 60),
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
      child: Column(
        children: [
          // 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  ModernColors.climbing.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_outlined,
              size: 64,
              color: ModernColors.climbing,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '첫 목표를 만들어보세요!',
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '셰르피와 함께 목표를 달성하고\n성장하는 여정을 시작하세요',
            style: GoogleFonts.notoSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary.withValues(alpha: 0.8),
              height: 1.5,
              letterSpacing: -0.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // CTA 버튼
          MicroInteractions.tapResponse(
            onTap: () => _showAddGoalModal(context, ref),
            scaleDownTo: 0.97,
            enableHaptic: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.climbing,
                    ModernColors.climbing.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.climbing.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '목표 만들기',
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
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .scale(
            begin: const Offset(0.95, 0.95),
            duration: 600.ms,
            curve: Curves.easeOutBack);
  }

  /// Gradient FAB - 새 목표 추가
  Widget _buildGradientFAB(BuildContext context, WidgetRef ref) {
    return MicroInteractions.tapResponse(
      onTap: () => _showAddGoalModal(context, ref),
      scaleDownTo: 0.97,
      enableHaptic: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernColors.climbing,
              ModernColors.climbing.withValues(alpha: 0.85),
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
              color: ModernColors.climbing.withValues(alpha: 0.4),
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
              '새 목표',
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
            duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3));
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
