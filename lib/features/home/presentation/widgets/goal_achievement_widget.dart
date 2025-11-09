import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

// Shared Providers
import 'package:sherpa_app/shared/providers/level_1_user_data/global_point_provider.dart';
import 'package:sherpa_app/shared/providers/level_3_ai/global_sherpi_provider.dart';

// Shared Widgets
import '../../../../shared/widgets/sherpa_button.dart';

// Shared Utils
import '../../../../shared/utils/haptic_feedback_manager.dart';

// Feature Providers (Goals)
import '../../../goals/providers/goal_provider.dart';
import '../../../goals/providers/routine_provider.dart';

/// 목표 달성하기 홈 위젯 (완전 리뉴얼)
///
/// 홈 화면에 표시되는 목표 달성 기능의 진입점
/// - 블루/화이트톤 깔끔한 디자인
/// - 그라디언트 헤더 + 화이트 카드
/// - ModernColors 전용 (레거시 색상 금지)
class GoalAchievementWidget extends ConsumerStatefulWidget {
  const GoalAchievementWidget({super.key});

  @override
  ConsumerState<GoalAchievementWidget> createState() =>
      _GoalAchievementWidgetState();
}

class _GoalAchievementWidgetState
    extends ConsumerState<GoalAchievementWidget> {
  /// 셰르피 감정 결정 (목표 완료율 기반)
  ///
  /// Dynamic emotion based on progress for nuanced encouragement:
  /// - thinking: Thoughtful guidance for low progress (0-69%)
  /// - cheering: Energetic motivation for high progress (70-99%)
  /// - special: Celebration for completion (100%)
  SherpiEmotion _getSherpiEmotion(int completedGoals, int totalGoals) {
    if (totalGoals == 0) {
      return SherpiEmotion.thinking; // 목표 없음
    }

    final completionRate = completedGoals / totalGoals;

    if (completionRate >= 1.0) {
      return SherpiEmotion.special; // 모든 목표 완료
    } else if (completionRate >= 0.7) {
      return SherpiEmotion.cheering; // 거의 완료 (70% 이상)
    } else {
      return SherpiEmotion.thinking; // 진행 중
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider 데이터
    final goals = ref.watch(goalProvider);
    final todayRoutines = ref.watch(todayRoutinesProvider);
    final completionRate = ref.watch(todayCompletionRateProvider);
    final completedCount = ref.watch(todayCompletedCountProvider);
    final totalPoints = ref.watch(globalTotalPointsProvider);

    // 계산
    final completedGoals = goals.where((g) => g.isAchieved).length;
    final totalGoals = goals.length;
    final canAnalyze = totalPoints >= 30;
    final sherpiEmotion = _getSherpiEmotion(completedGoals, totalGoals);

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
          // 1. 헤더 (그라디언트 블루)
          _buildHeader(sherpiEmotion),

          // 2. 목표 요약 카드
          _buildGoalSummaryCard(completedGoals, totalGoals),

          // 3. 루틴 요약 카드
          _buildRoutineSummaryCard(
            completedCount,
            todayRoutines.length,
            completionRate,
          ),

          // 4. 셰르피 분석 버튼
          _buildAnalysisButton(canAnalyze, totalPoints),
        ],
      ),
    );
  }

  /// 1. 헤더 섹션 (그라디언트 블루 + 셰르피 캐릭터)
  Widget _buildHeader(SherpiEmotion emotion) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
            child: GestureDetector(
              onTap: () {
                ref.read(sherpiProvider.notifier).showMessage(
                      context: SherpiContext.encouragement,
                      emotion: emotion,
                    );
                HapticFeedbackManager.lightImpact();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primaryLight.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: ModernColors.modernPrimary.withValues(alpha: 0.2),
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: 2.2,
                    child: Image.asset(
                      emotion.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '목표 달성하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
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
                const SizedBox(height: 4),
                Text(
                  '셰르피와 함께 목표를 달성해요!',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
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

  /// 2. 목표 요약 카드
  Widget _buildGoalSummaryCard(int completedGoals, int totalGoals) {
    final progressValue =
        totalGoals > 0 ? (completedGoals / totalGoals).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withValues(alpha: 0.08),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ModernColors.quest.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: ModernColors.quest,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '목표',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.modernText,
                ),
              ),
              const Spacer(),
              // 완료 개수 칩
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ModernColors.quest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedGoals/$totalGoals 완료',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.quest,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 진행률 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: ModernColors.borderLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(ModernColors.quest),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 12),

          // 화면 이동 버튼
          Semantics(
            label: '목표 화면으로 이동',
            button: true,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/goals');
                HapticFeedbackManager.lightImpact();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '자세히 보기',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.quest,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: ModernColors.quest,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. 루틴 요약 카드
  Widget _buildRoutineSummaryCard(
    int completedCount,
    int totalCount,
    double completionRate,
  ) {
    final displayRate = (completionRate * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withValues(alpha: 0.08),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ModernColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: ModernColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '오늘의 루틴',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.modernText,
                ),
              ),
              const Spacer(),
              // 완료율 칩
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ModernColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$displayRate%',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 원형 진행률 + 완료 개수
          Row(
            children: [
              // 원형 진행률 (작은 버전)
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: completionRate.clamp(0.0, 1.0),
                      backgroundColor: ModernColors.borderLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          ModernColors.success),
                      strokeWidth: 5,
                    ),
                    Center(
                      child: Text(
                        totalCount > 0 ? '$completedCount/$totalCount' : '0',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.modernText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalCount > 0
                          ? '오늘 $totalCount개 중 $completedCount개 완료'
                          : '오늘 할 루틴이 없어요',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.modernText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalCount > 0
                          ? (completionRate >= 1.0
                              ? '완벽해요! 🎉'
                              : (completionRate >= 0.7
                                  ? '조금만 더 힘내세요! 💪'
                                  : '화이팅! 🔥'))
                          : '루틴을 추가해보세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.modernTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 화면 이동 버튼
          Semantics(
            label: '루틴 화면으로 이동',
            button: true,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/routines');
                HapticFeedbackManager.lightImpact();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '전체 루틴 보기',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.success,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: ModernColors.success,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. 셰르피 분석 버튼
  Widget _buildAnalysisButton(bool canAnalyze, int totalPoints) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: SherpaButton(
        text: canAnalyze
            ? '🤖 셰르피가 목표를 분석해요 (30P)'
            : '⚠️ 포인트가 부족해요 (30P 필요)',
        onPressed: canAnalyze
            ? () {
                Navigator.pushNamed(context, '/ai_analysis');
                HapticFeedbackManager.lightImpact();
              }
            : () {
                HapticFeedbackManager.lightImpact();
                // 포인트 부족 다이얼로그
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
              },
        backgroundColor: canAnalyze
            ? ModernColors.modernPrimary
            : ModernColors.modernTextSecondary,
        textColor: Colors.white,
        gradient: canAnalyze
            ? const LinearGradient(
                colors: [
                  ModernColors.modernPrimary,
                  ModernColors.primaryLight,
                ],
              )
            : null,
      ),
    );
  }
}
