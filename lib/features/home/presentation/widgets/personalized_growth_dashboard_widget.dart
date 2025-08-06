// lib/features/home/presentation/widgets/personalized_growth_dashboard_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

// Shared Providers
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_game_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';

// Shared Widgets
import '../../../../shared/widgets/sherpa_card.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

// Features
import '../../../quests/providers/quest_provider_v2.dart';

// Shared Models
import '../../../../shared/models/global_user_model.dart';

class PersonalizedGrowthDashboardWidget extends ConsumerStatefulWidget {
  const PersonalizedGrowthDashboardWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<PersonalizedGrowthDashboardWidget> createState() =>
      _PersonalizedGrowthDashboardWidgetState();
}

class _PersonalizedGrowthDashboardWidgetState
    extends ConsumerState<PersonalizedGrowthDashboardWidget>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _sherpiController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sherpiAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _sherpiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _sherpiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sherpiController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _sherpiController.dispose();
    super.dispose();
  }

  // 수정된 탭 이동 메서드
  void _navigateToTab(int tabIndex) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
          (route) => false,
      arguments: tabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final dailyGoals = user.dailyRecords.dailyGoals;

    // 실시간 데이터 변경 감지 및 자동 동기화
    ref.listen(globalUserProvider, (previous, next) {
      if (previous != null && next != previous) {
        // 데이터 변경 시 퀘스트와 동기화
        // V2에서는 자동 동기화되므로 수동 동기화 불필요
        // ref.read(questProviderV2.notifier).onGlobalActivityUpdate('sync', {});

        // 일일 목표 상태 자동 업데이트
        final currentGoals = next.dailyRecords.dailyGoals;
        for (final goal in currentGoals) {
          if (!goal.isCompleted && _checkGoalCompletion(goal.id, next.dailyRecords)) {
            // 목표가 실제로 완료되었다면 자동 업데이트
            ref.read(globalUserProvider.notifier).completeDailyGoal(goal.id);
          }
        }
      }
    });

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEnhancedHeader(user),
              _buildTodayProgress(dailyGoals),
              const SizedBox(height: 20),
              _buildQuickStats(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(GlobalUser user) {
    final currentTitle = ref.watch(globalUserTitleProvider);
    final nextTitle = ref.watch(nextTitleProvider);
    final levelProgress = ref.watch(userLevelProgressProvider);
    final totalPoints = ref.watch(globalTotalPointsProvider);

    return Container(
      decoration: BoxDecoration(
        // 연한 그라데이션 배경
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primaryLight.withOpacity(0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // 미세한 패턴 배경
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 사용자 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 레벨 & 이름 행
                      Row(
                        children: [
                          // 레벨 뱃지
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Lv',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary.withOpacity(0.8),
                                            height: 1,
                                          ),
                                        ),
                                        Text(
                                          '${user.level}',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          // 사용자 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currentTitle.icon,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        currentTitle.title,
                                        style: GoogleFonts.notoSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 경험치 바
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '다음 레벨까지',
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${levelProgress.currentLevelExp}/${levelProgress.requiredExpForNextLevel} XP',
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeInOut,
                                height: 8,
                                width: MediaQuery.of(context).size.width * levelProgress.progress * 0.5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 하단 스탯
                      Row(
                        children: [
                          Flexible(
                            child: _buildHeaderStat(
                              icon: Icons.local_fire_department,
                              label: '연속',
                              value: '${user.dailyRecords.consecutiveDays}일',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildHeaderStat(
                              icon: Icons.monetization_on,
                              label: '포인트',
                              value: '$totalPoints P',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildHeaderStat(
                              icon: Icons.emoji_events,
                              label: '뱃지',
                              value: '${user.ownedBadgeIds.length}개',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 오른쪽: 셰르피
                _buildSherpiSection(levelProgress.progress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSherpiSection(double progress) {
    return AnimatedBuilder(
      animation: _sherpiAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            ref.read(sherpiProvider.notifier).showMessage(
              context: SherpiContext.encouragement,
              emotion: SherpiEmotion.cheering,
            );
            HapticFeedbackManager.lightImpact();
          },
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, math.sin(_sherpiAnimation.value * math.pi * 2) * 2),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.05),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Transform.scale(
                        scale: 2.2,
                        child: Image.asset(
                          'assets/images/sherpi/sherpi_cheering.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getSherpiMessage(progress),
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getSherpiMessage(double progress) {
    if (progress < 0.25) {
      return "천천히\n올라가요!";
    } else if (progress < 0.5) {
      return "좋은\n속도예요!";
    } else if (progress < 0.75) {
      return "멋진\n성장이에요!";
    } else if (progress < 0.9) {
      return "거의\n다 왔어요!";
    } else {
      return "곧 레벨업!";
    }
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primary.withOpacity(0.8),
            size: 14,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(List<DailyGoal> dailyGoals) {
    // 실제 데이터 기반으로 완료된 목표 수 계산 (daily_quest_widget.dart 방식)
    final user = ref.watch(globalUserProvider);
    final records = user.dailyRecords;
    final today = DateTime.now();
    
    int actualCompletedCount = 0;
    for (final goal in dailyGoals) {
      if (_checkGoalCompletion(goal.id, records)) {
        actualCompletedCount++;
      }
    }
    
    final completedCount = actualCompletedCount;
    final totalCount = dailyGoals.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    
    // 디버깅용 로그 (성장 대시보드 상태 - 완료: $actualCompletedCount/$totalCount)

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 목표',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$completedCount / $totalCount',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/',
                        (route) => false,
                        arguments: {
                          'tabIndex': 2,    // 퀘스트 탭
                          'subTabIndex': 1, // 기록 서브탭
                        },
                      );
                    },
                    icon: Icon(
                      Icons.edit_note,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      '기록하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          
          // 보상 정보 표시 (항상 표시)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  completedCount == totalCount 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.08),
                  completedCount == totalCount 
                    ? AppColors.success.withOpacity(0.05)
                    : AppColors.primary.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: completedCount == totalCount 
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  completedCount == totalCount ? Icons.celebration : Icons.emoji_events,
                  color: completedCount == totalCount ? AppColors.success : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completedCount == totalCount ? '🎉 모든 목표 달성!' : '전체 완료 시 보상',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: completedCount == totalCount ? AppColors.success : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '✨ 200XP + 💰 50P + 🔥 +0.1 의지력',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 일일 목표 리스트
          ...dailyGoals.map((goal) => _buildGoalItem(goal)).toList(),

          // 전체 완료 보상 버튼 - 깔끔한 UI로 개선
          if (completedCount == totalCount && !user.dailyRecords.isAllGoalsRewardClaimed)
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(globalUserProvider.notifier).claimAllGoalsReward();
                  HapticFeedbackManager.heavyImpact();
                  
                  // 성공 피드백 스낵바 추가
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🎉 보상을 받았습니다! ✨200XP + 💰50P + 🔥+0.1',
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.redeem, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '전체 완료 보상 받기',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '✨ 200XP + 💰 50P + 🔥 +0.1',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (completedCount == totalCount && user.dailyRecords.isAllGoalsRewardClaimed)
            // 이미 보상을 받은 경우 표시 - 깔끔한 디자인
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '오늘의 보상을 모두 받았습니다',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(DailyGoal goal) {
    // 실제 데이터 기반 완료 상태 확인 (daily_quest_widget.dart 방식 적용)
    final user = ref.watch(globalUserProvider);
    final records = user.dailyRecords;
    bool isActuallyCompleted = _checkGoalCompletion(goal.id, records);
    
    // 실제 데이터 기반으로 표시 (더 정확함)
    final shouldShowAsCompleted = isActuallyCompleted;

    // 진행률 계산
    double progress = 0.0;
    String progressText = '';
    bool showProgressBar = false;

    switch (goal.id) {
      case 'steps':
        progress = records.todaySteps / 6000;
        progressText = '${records.todaySteps}/6000';
        showProgressBar = !shouldShowAsCompleted;
        break;
      case 'focus':
        progress = records.todayFocusMinutes / 30;
        progressText = '${records.todayFocusMinutes}/30분';
        showProgressBar = !shouldShowAsCompleted;
        break;
      case 'reading':
        if (records.todayReadingPages > 0) {
          progressText = '${records.todayReadingPages}페이지';
        }
        break;
      case 'exercise':
        final todayExercise = records.exerciseLogs
            .where((log) => _isSameDay(log.date, DateTime.now()))
            .toList();
        if (todayExercise.isNotEmpty) {
          final totalMinutes = todayExercise.fold(0,
                  (sum, log) => sum + log.durationMinutes);
          progressText = '${totalMinutes}분';
        }
        break;
      case 'diary':
      // 일기는 진행률 표시 없음
        break;
    }

    // 목표 완료 상태는 실제 데이터가 아닌 goal.isCompleted를 우선적으로 사용
    // 자동 동기화는 제거하여 정확한 완료 상태 표시

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!shouldShowAsCompleted) {
            // 기록 화면으로 이동
            _navigateToRecordScreen(goal.id);
          }
          HapticFeedbackManager.lightImpact();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: shouldShowAsCompleted
                ? AppColors.success.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: shouldShowAsCompleted
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // 아이콘
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: shouldShowAsCompleted
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        goal.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 내용
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                goal.title,
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: shouldShowAsCompleted
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (!shouldShowAsCompleted && progressText.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  progressText,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          _getGoalStatusText(goal.id, records),
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: shouldShowAsCompleted
                                ? AppColors.success.withOpacity(0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 체크 아이콘
                  Icon(
                    shouldShowAsCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: shouldShowAsCompleted
                        ? AppColors.success
                        : AppColors.textLight,
                    size: 24,
                  ),
                ],
              ),
              // 진행률 바
              if (showProgressBar) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(GlobalUser user) {
    final todayRecords = user.dailyRecords;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 활동',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.directions_walk,
                  label: '걸음수',
                  value: todayRecords.todaySteps > 9999
                      ? '${(todayRecords.todaySteps / 1000).toStringAsFixed(1)}K'
                      : '${todayRecords.todaySteps}',
                  unit: '걸음',
                  color: AppColors.exercise,
                  progress: todayRecords.todaySteps / 6000,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  label: '집중시간',
                  value: '${todayRecords.todayFocusMinutes}',
                  unit: '분',
                  color: AppColors.focus,
                  progress: todayRecords.todayFocusMinutes / 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.menu_book,
                  label: '독서',
                  value: '${todayRecords.todayReadingPages}',
                  unit: '페이지',
                  color: AppColors.reading,
                  progress: todayRecords.todayReadingPages / 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // 목표 완료 조건 체크 메서드 (daily_quest_widget.dart와 동일한 로직)
  bool _checkGoalCompletion(String goalId, DailyRecordData records) {
    final today = DateTime.now();
    
    switch (goalId) {
      case 'steps':
        return records.todaySteps >= 6000;
      case 'focus':
        return records.todayFocusMinutes >= 30;
      case 'reading':
        return records.readingLogs.any((log) => 
          _isSameDay(log.date, today) && log.pages >= 1);
      case 'exercise':
        return records.exerciseLogs.any((log) =>
            _isSameDay(log.date, today));
      case 'diary':
        return records.diaryLogs.any((log) =>
            _isSameDay(log.date, today));
      default:
        return false;
    }
  }

  // 날짜 비교 헬퍼 메서드
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 목표별 상태 텍스트 반환
  String _getGoalStatusText(String goalId, DailyRecordData records) {
    switch (goalId) {
      case 'steps':
        if (records.todaySteps >= 6000) {
          return '완료! ${records.todaySteps}걸음';
        }
        return '${records.todaySteps}/6000 걸음';

      case 'focus':
        if (records.todayFocusMinutes >= 30) {
          return '완료! ${records.todayFocusMinutes}분 집중';
        }
        return '${records.todayFocusMinutes}/30분';

      case 'reading':
        if (records.todayReadingPages > 0) {
          return '완료! ${records.todayReadingPages}페이지 읽음';
        }
        return '오늘의 독서를 기록하세요';

      case 'exercise':
        final todayExercise = records.exerciseLogs
            .where((log) => _isSameDay(log.date, DateTime.now()))
            .toList();
        if (todayExercise.isNotEmpty) {
          final totalMinutes = todayExercise.fold(0,
                  (sum, log) => sum + log.durationMinutes);
          return '완료! ${totalMinutes}분 운동';
        }
        return '운동을 기록하세요';

      case 'diary':
        final todayDiary = records.diaryLogs
            .where((log) => _isSameDay(log.date, DateTime.now()))
            .toList();
        if (todayDiary.isNotEmpty) {
          return '완료! 일기 작성함';
        }
        return '오늘의 일기를 작성하세요';

      default:
        return '시작하세요';
    }
  }

  // 목표별 기록 화면으로 이동
  void _navigateToRecordScreen(String goalId) {
    switch (goalId) {
      case 'steps':
      case 'focus':
      case 'reading':
      case 'exercise':
      case 'diary':
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
          arguments: {
            'tabIndex': 2,    // 퀘스트 탭
            'subTabIndex': 1, // 기록 서브탭
          },
        );
        break;
      default:
        _navigateToTab(1); // 레벨업 탭으로
    }
  }
}