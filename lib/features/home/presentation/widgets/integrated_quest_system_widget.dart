import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Core
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

// Shared Providers
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';

// Shared Widgets
import '../../../../shared/widgets/sherpa_card.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

// Features
import '../../../quests/providers/quest_provider_v2.dart';
import '../../../quests/models/quest_instance_model.dart';
import '../../../quests/models/quest_template_model.dart';

class IntegratedQuestSystemWidget extends ConsumerStatefulWidget {
  const IntegratedQuestSystemWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<IntegratedQuestSystemWidget> createState() =>
      _IntegratedQuestSystemWidgetState();
}

class _IntegratedQuestSystemWidgetState
    extends ConsumerState<IntegratedQuestSystemWidget>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rewardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rewardScaleAnimation;

  int _selectedTabIndex = 0; // 0: Daily, 1: Weekly, 2: Premium
  String? _recentlyClaimedQuestId;
  Map<String, dynamic>? _lastRewardData;

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

    _rewardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

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

    _rewardScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rewardController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  void _navigateToTab(int tabIndex) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
          (route) => false,
      arguments: tabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(questProviderV2);
    final questProgress = ref.watch(questProgressProviderV2);

    // 퀘스트 데이터가 비어있으면 리프레시
    if (questsAsync.hasValue && questsAsync.value!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(questProviderV2.notifier).refresh();
      });
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ModernColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(questProgress),
              _buildTabBar(questsAsync, questProgress),
              const SizedBox(height: 16),
              _buildQuestContent(questsAsync),
              _buildCompletionBonus(questProgress),
              if (_lastRewardData != null)
                _buildRewardFeedback(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(QuestProgressV2 progress) {
    return Container(
      decoration: BoxDecoration(
        color: ModernColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(19),
          topRight: Radius.circular(19),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 퀘스트 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '🎯',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '성장 퀘스트',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '매일 새로운 도전으로 성장하세요',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // 보상 수령 가능 표시
            if (progress.claimableQuests > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color: ModernColors.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${progress.claimableQuests}개',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(AsyncValue<List<QuestInstance>> questsAsync, QuestProgressV2 progress) {
    // 완료/전체 계산
    final dailyQuests = questsAsync.value?.where((q) => q.type == QuestTypeV2.daily).toList() ?? [];
    final weeklyQuests = questsAsync.value?.where((q) => q.type == QuestTypeV2.weekly).toList() ?? [];
    final premiumQuests = questsAsync.value?.where((q) => q.type == QuestTypeV2.premium).toList() ?? [];

    final dailyCompleted = dailyQuests.where((q) => q.status == QuestStatus.completed || q.status == QuestStatus.claimed).length;
    final weeklyCompleted = weeklyQuests.where((q) => q.status == QuestStatus.completed || q.status == QuestStatus.claimed).length;
    final premiumCompleted = premiumQuests.where((q) => q.status == QuestStatus.completed || q.status == QuestStatus.claimed).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _buildTabButton(
            '일일',
            0,
            Icons.today,
            dailyQuests.length,
            dailyCompleted,
            dailyQuests.length,
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            '주간',
            1,
            Icons.date_range,
            weeklyQuests.length,
            weeklyCompleted,
            weeklyQuests.length,
          ),
          // 프리미엄 퀘스트가 있을 때만 표시
          if (premiumQuests.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildTabButton(
              '프리미엄',
              2,
              Icons.star,
              premiumQuests.length,
              premiumCompleted,
              premiumQuests.length,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon, int count, int completed, int total) {
    final bool isSelected = _selectedTabIndex == index;
    final bool isAllCompleted = total > 0 && completed == total;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedbackManager.lightImpact();
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? ModernColors.primary.withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ModernColors.primary
                  : ModernColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? ModernColors.primary : ModernColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? ModernColors.primary : ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (total > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$completed/$total',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isAllCompleted
                            ? ModernColors.success
                            : (isSelected ? ModernColors.primary : ModernColors.textSecondary),
                      ),
                    ),
                    if (isAllCompleted) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: ModernColors.success,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestContent(AsyncValue<List<QuestInstance>> questsAsync) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: questsAsync.when(
        data: (quests) {
          if (quests.isEmpty) {
            return _buildEmptyState();
          }

          // 탭에 따라 퀘스트 필터링
          final filteredQuests = quests.where((quest) {
            switch (_selectedTabIndex) {
              case 0:
                return quest.type == QuestTypeV2.daily;
              case 1:
                return quest.type == QuestTypeV2.weekly;
              case 2:
                return quest.type == QuestTypeV2.premium;
              default:
                return false;
            }
          }).toList();

          // 상태별 정렬: 보상수령가능 > 진행중 > 완료 > 수령완료
          filteredQuests.sort((a, b) {
            final statusOrder = {
              QuestStatus.completed: 0,
              QuestStatus.inProgress: 1,
              QuestStatus.notStarted: 2,
              QuestStatus.claimed: 3,
            };
            return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
          });

          return Column(
            children: [
              ...filteredQuests.take(3).map((quest) {
                return _buildQuestCard(quest);
              }).toList(),
              if (filteredQuests.length > 3)
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  child: TextButton.icon(
                    onPressed: () => _navigateToTab(2), // 퀘스트 탭으로
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: ModernColors.primary,
                    ),
                    label: Text(
                      '더 많은 퀘스트 보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(),
      ),
    );
  }

  Widget _buildQuestCard(QuestInstance quest) {
    final progress = quest.progressRatio;
    final isCompleted = quest.status == QuestStatus.completed;
    final isClaimed = quest.status == QuestStatus.claimed;
    final canClaim = quest.canClaim;

    // V2에서는 template의 difficultyColor 사용
    Color getDifficultyColor() {
      return quest.difficultyColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: canClaim ? () => _claimQuestReward(quest) : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: ModernColors.primary.withOpacity(0.1),
          highlightColor: ModernColors.primary.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isClaimed
                  ? ModernColors.background
                  : canClaim
                  ? ModernColors.accent.withOpacity(0.03)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isClaimed
                    ? ModernColors.border.withOpacity(0.3)
                    : canClaim
                    ? ModernColors.accent
                    : getDifficultyColor().withOpacity(0.3),
                width: canClaim ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // 퀘스트 아이콘
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isClaimed
                            ? ModernColors.textTertiary.withOpacity(0.1)
                            : getDifficultyColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          quest.category.emoji,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 퀘스트 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  quest.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isClaimed
                                        ? ModernColors.textTertiary
                                        : ModernColors.textPrimary,
                                    decoration: isClaimed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              // 난이도 표시
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: getDifficultyColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  quest.difficultyName,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: getDifficultyColor(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  quest.description,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    color: isClaimed
                                        ? ModernColors.textTertiary
                                        : ModernColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (quest.targetProgress > 1 && !isCompleted && !isClaimed)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ModernColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${quest.currentProgress}/${quest.targetProgress}',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ModernColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 상태 아이콘 또는 보상 버튼
                    if (canClaim)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ModernColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '보상',
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Icon(
                        isClaimed
                            ? Icons.check_circle
                            : isCompleted
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                        color: isClaimed
                            ? ModernColors.textTertiary
                            : isCompleted
                            ? ModernColors.success
                            : ModernColors.border,
                        size: 24,
                      ),
                  ],
                ),
                if (!isClaimed) ...[
                  const SizedBox(height: 12),
                  // 진행률 바
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: ModernColors.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? ModernColors.success : getDifficultyColor(),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 보상 정보
                  Row(
                    children: [
                      // XP 보상
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ModernColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: ModernColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${quest.rewards.experience.toInt()} XP',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: ModernColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 포인트 보상
                      if (quest.rewards.points > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ModernColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: ModernColors.accent,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${quest.rewards.points} P',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: ModernColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // 능력치 보상
                      if (quest.rewards.statChance > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ModernColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getStatEmoji(quest.rewards.statType),
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(quest.rewards.statChance * 100).toInt()}%',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: ModernColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      // 프리미엄 레어리티
                      if (quest.type == QuestTypeV2.premium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                quest.rarityColor.withOpacity(0.1),
                                quest.rarityColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: quest.rarityColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            quest.rarityName,
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: quest.rarityColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBonus(QuestProgressV2 progress) {
    // V2에서는 보너스 시스템이 아직 구현되지 않았으므로 빈 위젯 반환
    return const SizedBox.shrink();
  }

  Widget _buildBonusItem(String title, String buttonText, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.celebration,
                color: ModernColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 20),
              label: Text(
                buttonText,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _claimQuestReward(QuestInstance quest) async {
    HapticFeedbackManager.mediumImpact();

    setState(() {
      _recentlyClaimedQuestId = quest.id;
    });

    try {
      await ref.read(questProviderV2.notifier).claimReward(quest.id);

      // 보상 피드백 데이터 설정
      setState(() {
        _lastRewardData = {
          'questTitle': quest.title,
          'xp': quest.rewards.experience,
          'points': quest.rewards.points,
          'statType': quest.rewards.statType,
          'statChance': quest.rewards.statChance,
        };
      });

      _showRewardAnimation();

      // 셰르피 반응
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.questComplete,
        emotion: SherpiEmotion.cheering,
      );

    } catch (e) {
      // 보상 수령 실패
    }
  }

  void _showRewardAnimation() {
    _rewardController.forward(from: 0);

    // 3초 후 자동으로 숨기기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _lastRewardData = null;
        });
      }
    });
  }

  Widget _buildRewardFeedback() {
    if (_lastRewardData == null) return const SizedBox.shrink();

    return ScaleTransition(
      scale: _rewardScaleAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ModernColors.success.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ModernColors.success.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ModernColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard,
                color: ModernColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lastRewardData!['title'] ?? _lastRewardData!['questTitle'] ?? '보상 획득!',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    children: [
                      if (_lastRewardData!['xp'] != null && _lastRewardData!['xp'] > 0)
                        Text(
                          '+${_lastRewardData!['xp'].toInt()} XP',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: ModernColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (_lastRewardData!['points'] != null && _lastRewardData!['points'] > 0)
                        Text(
                          '+${_lastRewardData!['points']} P',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: ModernColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (_lastRewardData!['statType'] != null && _lastRewardData!['statChance'] != null)
                        Text(
                          '${_getStatEmoji(_lastRewardData!['statType'])} ${_getStatName(_lastRewardData!['statType'])} 0.1% 증가!',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: ModernColors.primary,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: ModernColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 32,
              color: ModernColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '모든 퀘스트를 완료했어요!',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '내일 새로운 퀘스트가 기다리고 있어요',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ModernColors.primary),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: ModernColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 32,
              color: ModernColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '퀘스트를 불러올 수 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              ref.invalidate(questProviderV2);
            },
            child: Text(
              '다시 시도',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatEmoji(String statType) {
    switch (statType) {
      case 'stamina':
        return '💪';
      case 'knowledge':
        return '🧠';
      case 'technique':
        return '🛠️';
      case 'sociality':
        return '🤝';
      case 'willpower':
        return '🔥';
      default:
        return '📊';
    }
  }

  String _getStatName(String statType) {
    switch (statType) {
      case 'stamina':
        return '체력';
      case 'knowledge':
        return '지식';
      case 'technique':
        return '기술';
      case 'sociality':
        return '사교성';
      case 'willpower':
        return '의지';
      default:
        return '능력치';
    }
  }
}