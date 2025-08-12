// lib/features/daily_record/widgets/enhanced_daily_quest_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/modern_colors.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import '../presentation/screens/diary_write_edit_screen.dart';

class EnhancedDailyQuestWidget extends ConsumerStatefulWidget {
  const EnhancedDailyQuestWidget({Key? key}) : super(key: key);
  
  @override
  ConsumerState<EnhancedDailyQuestWidget> createState() => _EnhancedDailyQuestWidgetState();
}

class _EnhancedDailyQuestWidgetState extends ConsumerState<EnhancedDailyQuestWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  final Map<String, AnimationController> _itemControllers = {};
  final Map<String, Animation<double>> _itemAnimations = {};

  @override
  void initState() {
    super.initState();
    
    // Main slide animation with smooth cubic easing
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Subtle pulse animation for emphasis
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    
    // Sync goals on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalUserProvider.notifier).syncDailyGoalsWithData();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    for (var controller in _itemControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _getItemController(String goalId) {
    if (!_itemControllers.containsKey(goalId)) {
      _itemControllers[goalId] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _itemAnimations[goalId] = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _itemControllers[goalId]!,
        curve: Curves.easeOutCubic,
      ));
    }
    return _itemControllers[goalId]!;
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: ModernColors.shadowBase.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: ModernColors.shadowBase.withOpacity(0.04),
              blurRadius: 48,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEnhancedHeader(),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    _buildQuestListSection(),
                    const SizedBox(height: 10),
                    _buildProgressSection(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    final user = ref.watch(globalUserProvider);
    final goals = user.dailyRecords.dailyGoals;
    int completedCount = goals.where((g) => _isGoalAchieved(g.id, user)).length;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.surface,
            ModernColors.gray50.withOpacity(0.5),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Elegant drag handle
          Container(
            width: 36,
            height: 3,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: ModernColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header content
          Row(
            children: [
              // Premium glassmorphism icon container
              Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow layer
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: ModernColors.primary.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  // Gradient background
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ModernColors.primary.withOpacity(0.9),
                          ModernColors.accent.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  // Glass effect overlay
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.center,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  // Icon
                  Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 목표',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${goals.length}개 중 $completedCount개 완료',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: ModernColors.gray100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: ModernColors.textTertiary,
                    size: 16,
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestListSection() {
    final user = ref.watch(globalUserProvider);
    final goals = user.dailyRecords.dailyGoals;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: goals.asMap().entries.map((entry) {
          final index = entry.key;
          final goal = entry.value;
          return _buildEnhancedQuestItem(goal, index);
        }).toList(),
      ),
    );
  }

  Widget _buildEnhancedQuestItem(DailyGoal goal, int index) {
    final user = ref.watch(globalUserProvider);
    final isAchieved = _isGoalAchieved(goal.id, user);
    final progress = _getGoalProgress(goal.id, user);
    final statusText = _getAchievementStatus(goal.id, user);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAchieved ? null : () => _handleGoalTap(goal.id),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAchieved 
                  ? ModernColors.success.withOpacity(0.05)
                  : ModernColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isAchieved
                      ? ModernColors.success.withOpacity(0.08)
                      : ModernColors.shadowBase.withOpacity(0.06),
                  blurRadius: isAchieved ? 16 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Modern icon with progress indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isAchieved) ...[
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2.5,
                          backgroundColor: ModernColors.gray200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getGoalColor(goal.id),
                          ),
                        ),
                      ),
                    ],
                    Container(
                      width: isAchieved ? 36 : 32,
                      height: isAchieved ? 36 : 32,
                      decoration: BoxDecoration(
                        color: isAchieved
                            ? ModernColors.success.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isAchieved ? null : [
                          BoxShadow(
                            color: ModernColors.shadowBase.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isAchieved
                            ? Icons.check_circle_outline
                            : _getGoalIcon(goal.id),
                        color: isAchieved
                            ? ModernColors.success
                            : _getGoalColor(goal.id),
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Goal details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isAchieved
                              ? ModernColors.textSecondary
                              : ModernColors.textPrimary,
                          letterSpacing: -0.3,
                          decoration: isAchieved
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: isAchieved
                              ? ModernColors.success
                              : ModernColors.textTertiary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action indicator
                if (!isAchieved)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ModernColors.gray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: ModernColors.textTertiary,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ).animate(delay: Duration(milliseconds: 100 * index))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final user = ref.watch(globalUserProvider);
    final goals = user.dailyRecords.dailyGoals;
    
    int completedCount = goals.where((g) => _isGoalAchieved(g.id, user)).length;
    final totalCount = goals.length;
    final allCompleted = completedCount == totalCount;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isRewardClaimed = user.dailyRecords.isAllGoalsRewardClaimed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Circular Progress Section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ModernColors.surface,
                  ModernColors.gray50.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.shadowBase.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Circular Progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor: ModernColors.gray200.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          allCompleted ? ModernColors.success : ModernColors.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: allCompleted
                                ? ModernColors.success
                                : ModernColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '$completedCount/$totalCount',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: ModernColors.textSecondary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Progress text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allCompleted ? '모든 목표 달성!' : '오늘의 진행 상황',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: allCompleted
                              ? ModernColors.success
                              : ModernColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        allCompleted 
                            ? '훌륭해요! 오늘의 모든 목표를 완료했어요.'
                            : '조금만 더 힘내요! ${totalCount - completedCount}개의 목표가 남았어요.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                          letterSpacing: -0.2,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Reward section - always visible for motivation
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: allCompleted
                    ? [
                        ModernColors.success.withOpacity(0.08),
                        ModernColors.success.withOpacity(0.04),
                      ]
                    : [
                        ModernColors.gray100.withOpacity(0.5),
                        ModernColors.gray50.withOpacity(0.3),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: !allCompleted
                  ? Border.all(
                      color: ModernColors.gray200.withOpacity(0.3),
                      width: 1,
                      style: BorderStyle.solid,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: allCompleted
                      ? ModernColors.success.withOpacity(0.1)
                      : ModernColors.shadowBase.withOpacity(0.03),
                  blurRadius: allCompleted ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Reward header
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: allCompleted
                            ? ModernColors.success.withOpacity(0.1)
                            : ModernColors.gray200.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.card_giftcard_outlined,
                        color: allCompleted
                            ? ModernColors.success
                            : ModernColors.textTertiary,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '완주 보상',
                          style: TextStyle(
                          fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: allCompleted
                                ? ModernColors.success
                                : ModernColors.textSecondary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (!allCompleted)
                          Text(
                            '모든 목표 완료 시 획득',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: ModernColors.textTertiary,
                              letterSpacing: -0.2,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    if (allCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRewardClaimed
                              ? ModernColors.success.withOpacity(0.2)
                              : ModernColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isRewardClaimed ? '수령 완료' : '수령 가능',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isRewardClaimed
                                ? ModernColors.success
                                : Colors.white,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ModernColors.gray200.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: ModernColors.textTertiary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Reward items
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: allCompleted ? 1.0 : 0.6,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: allCompleted
                          ? Colors.white.withOpacity(0.5)
                          : ModernColors.gray100.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRewardItem(
                          Icons.star_rounded,
                          '200',
                          'XP',
                          isActive: allCompleted,
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: allCompleted
                              ? ModernColors.gray200
                              : ModernColors.gray200.withOpacity(0.3),
                        ),
                        _buildRewardItem(
                          Icons.toll_rounded,
                          '50',
                          '포인트',
                          isActive: allCompleted,
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: allCompleted
                              ? ModernColors.gray200
                              : ModernColors.gray200.withOpacity(0.3),
                        ),
                        _buildRewardItem(
                          Icons.local_fire_department_rounded,
                          '+0.1',
                          '의지력',
                          isActive: allCompleted,
                        ),
                      ],
                    ),
                  ),
                ),
                if (allCompleted && !isRewardClaimed) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _claimReward(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.redeem_rounded, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '보상 받기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildRewardItem(IconData icon, String value, String label, {bool isActive = true}) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? ModernColors.success : ModernColors.textTertiary,
          size: 16,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? ModernColors.success : ModernColors.textSecondary,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: isActive ? ModernColors.textSecondary : ModernColors.textTertiary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  void _claimReward() {
    HapticFeedbackManager.heavyImpact();
    ref.read(globalUserProvider.notifier).claimAllGoalsReward();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.celebration, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '보상을 받았어요!',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ModernColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
    
    Navigator.pop(context);
  }

  // Helper methods (same functionality as original)
  bool _isGoalAchieved(String goalId, dynamic user) {
    final records = user.dailyRecords;
    final today = DateTime.now();
    
    switch (goalId) {
      case 'steps':
        return records.todaySteps >= 6000;
      case 'focus':
        return records.todayFocusMinutes >= 30;
      case 'reading':
        return records.readingLogs.any((log) => 
          _isToday(log.date, today) && log.pages >= 1);
      case 'diary':
        return records.diaryLogs.any((log) => 
          _isToday(log.date, today));
      case 'exercise':
        return records.exerciseLogs.any((log) => 
          _isToday(log.date, today));
      default:
        return false;
    }
  }
  
  bool _isToday(DateTime date, DateTime today) {
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }
  
  String _getAchievementStatus(String goalId, dynamic user) {
    final records = user.dailyRecords;
    final today = DateTime.now();
    
    switch (goalId) {
      case 'steps':
        return '${records.todaySteps.toStringAsFixed(0)} / 6,000걸음';
      case 'focus':
        return '${records.todayFocusMinutes}분 / 30분';
      case 'reading':
        final todayPages = records.readingLogs
          .where((log) => _isToday(log.date, today))
          .fold(0, (sum, log) => sum + log.pages);
        return '$todayPages페이지 / 1페이지';
      case 'diary':
        final hasDiary = records.diaryLogs.any((log) => _isToday(log.date, today));
        return hasDiary ? '완료' : '미작성';
      case 'exercise':
        final hasExercise = records.exerciseLogs.any((log) => _isToday(log.date, today));
        return hasExercise ? '완료' : '미기록';
      default:
        return '미완료';
    }
  }

  double _getGoalProgress(String goalId, dynamic user) {
    final records = user.dailyRecords;
    
    switch (goalId) {
      case 'steps':
        return (records.todaySteps / 6000).clamp(0.0, 1.0);
      case 'focus':
        return (records.todayFocusMinutes / 30).clamp(0.0, 1.0);
      case 'reading':
        final today = DateTime.now();
        final todayPages = records.readingLogs
          .where((log) => _isToday(log.date, today))
          .fold(0, (sum, log) => sum + log.pages);
        return (todayPages / 1).clamp(0.0, 1.0);
      case 'diary':
        final today = DateTime.now();
        return records.diaryLogs.any((log) => _isToday(log.date, today)) ? 1.0 : 0.0;
      case 'exercise':
        final today = DateTime.now();
        return records.exerciseLogs.any((log) => _isToday(log.date, today)) ? 1.0 : 0.0;
      default:
        return 0.0;
    }
  }

  void _handleGoalTap(String goalId) {
    HapticFeedbackManager.mediumImpact();
    
    switch (goalId) {
      case 'steps':
        _showModernInfoDialog(
          icon: Icons.directions_walk_outlined,
          title: '걸음수 목표',
          message: '오늘 6,000걸음을 걸어 건강을 지켜보세요.',
          color: ModernColors.primary,
        );
        break;
      case 'focus':
        _showModernInfoDialog(
          icon: Icons.timer_outlined,
          title: '집중 시간 목표',
          message: '중요한 일에 30분간 집중해보세요.',
          color: ModernColors.accent,
        );
        break;
      case 'diary':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryWriteEditScreen(),
          ),
        );
        break;
      case 'exercise':
        Navigator.pushNamed(context, '/exercise_record');
        break;
      case 'reading':
        Navigator.pushNamed(context, '/reading_record');
        break;
    }
  }

  void _showModernInfoDialog({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ModernColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ModernColors.textSecondary,
                  letterSpacing: -0.2,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: color.withOpacity(0.1),
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGoalIcon(String goalId) {
    switch (goalId) {
      case 'steps':
        return Icons.directions_walk_outlined;
      case 'focus':
        return Icons.timer_outlined;
      case 'reading':
        return Icons.auto_stories_outlined;
      case 'diary':
        return Icons.edit_note_outlined;
      case 'exercise':
        return Icons.fitness_center_outlined;
      default:
        return Icons.flag_outlined;
    }
  }

  Color _getGoalColor(String goalId) {
    switch (goalId) {
      case 'steps':
        return const Color(0xFF6366F1);
      case 'focus':
        return const Color(0xFF0EA5E9);
      case 'reading':
        return const Color(0xFF10B981);
      case 'diary':
        return const Color(0xFFF59E0B);
      case 'exercise':
        return const Color(0xFFEC4899);
      default:
        return ModernColors.primary;
    }
  }
}