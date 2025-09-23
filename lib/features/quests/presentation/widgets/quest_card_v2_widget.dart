import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../models/quest_instance_model.dart';
import '../../models/quest_template_model.dart';
import '../../providers/quest_provider_v2.dart';
import '../../utils/quest_condition_formatter.dart';

/// 새로운 퀘스트 카드 위젯 (V2)
/// quest.md 기반의 새로운 시스템에 맞춰 설계
class QuestCardV2Widget extends ConsumerStatefulWidget {
  final QuestInstance quest;
  final Function(QuestInstance) onQuestCompleted;

  const QuestCardV2Widget({
    super.key,
    required this.quest,
    required this.onQuestCompleted,
  });

  @override
  ConsumerState<QuestCardV2Widget> createState() => _QuestCardV2WidgetState();
}

class _QuestCardV2WidgetState extends ConsumerState<QuestCardV2Widget> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final quest = widget.quest;
    final isCompleted = quest.status == QuestStatus.claimed;

    return Opacity(
      opacity: isCompleted ? 0.7 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBorderColor(quest),
            width: 2,
          ),
          boxShadow: quest.canClaim
              ? [
                  BoxShadow(
                    color: ModernColors.warning.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: quest.canClaim
                ? ModernColors.warning.withValues(alpha: 0.05)
                : quest.canComplete
                    ? ModernColors.success.withValues(alpha: 0.05)
                    : ModernColors.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 정보
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 이모티콘
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(quest).withValues(alpha: 0.1),
                        border: Border.all(
                          color:
                              _getCategoryColor(quest).withValues(alpha: 0.3),
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          quest.categoryEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 퀘스트 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 난이도/희귀도 태그 + 유형
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      quest.rarityColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: quest.rarityColor
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (quest.type == QuestTypeV2.premium)
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: quest.rarityColor,
                                      )
                                          .animate(
                                            onPlay: (controller) =>
                                                controller.repeat(),
                                          )
                                          .rotate(
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                    if (quest.type == QuestTypeV2.premium)
                                      const SizedBox(width: 4),
                                    Text(
                                      quest.rarityName,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: quest.rarityColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 퀘스트 유형 표시
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      quest.type.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  quest.type.displayName,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: quest.type.color,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // 퀘스트 제목
                          Text(
                            quest.title,
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ModernColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // 퀘스트 설명
                          Text(
                            quest.description,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: ModernColors.textSecondary,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 추적 조건 표시 (사용자 친화적)
                          _buildTrackingInfo(quest),

                          const SizedBox(height: 4),

                          // 상태 설명
                          _buildStatusDescription(quest),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 보상 정보
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ModernColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ModernColors.border,
                      width: 1,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // 경험치
                        _buildRewardItem(
                          icon: Icons.trending_up,
                          value: '+${quest.rewards.experience.toInt()} XP',
                          color: ModernColors.secondary,
                        ),

                        // 포인트 (있는 경우만)
                        if (quest.rewards.points > 0) ...[
                          Container(
                            width: 1,
                            color: ModernColors.border,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          _buildRewardItem(
                            icon: Icons.monetization_on,
                            value: '+${quest.rewards.points.toInt()} P',
                            color: ModernColors.warning,
                          ),
                        ],

                        // 능력치 (확률이 있는 경우만)
                        if (quest.rewards.statChance > 0) ...[
                          Container(
                            width: 1,
                            color: ModernColors.border,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          _buildStatRewardItem(
                            category: quest.category,
                            value:
                                '${(quest.rewards.statChance * 100).toInt()}%',
                            color: ModernColors.success,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 액션 버튼 또는 진행률
                if (quest.canClaim)
                  _buildClaimButton()
                else if (quest.status == QuestStatus.claimed)
                  _buildCompletedBadge()
                else
                  _buildProgressBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 추적 조건 정보 표시 (사용자 친화적)
  Widget _buildTrackingInfo(QuestInstance quest) {
    final trackingText = QuestConditionFormatter.formatTrackingCondition(
        quest.trackingCondition);
    IconData trackingIcon;

    // 등반 퀘스트 특별 처리
    final isClimbingQuest =
        quest.trackingCondition.type == QuestTrackingType.globalData &&
            quest.trackingCondition.parameters['path'] ==
                'ClimbingRecord.isSuccess';

    switch (quest.trackingCondition.type) {
      case QuestTrackingType.appLaunch:
        trackingIcon = Icons.login;
        break;
      case QuestTrackingType.steps:
        trackingIcon = Icons.directions_walk;
        break;
      case QuestTrackingType.tabVisit:
        trackingIcon = Icons.tab;
        break;
      case QuestTrackingType.globalData:
        trackingIcon = isClimbingQuest ? Icons.terrain : Icons.track_changes;
        break;
      case QuestTrackingType.weeklyAccumulation:
        trackingIcon = Icons.calendar_view_week;
        break;
      case QuestTrackingType.multipleConditions:
        trackingIcon = Icons.checklist;
        break;
      case QuestTrackingType.userAction:
        trackingIcon = Icons.touch_app;
        break;
      case QuestTrackingType.dailyCompletion:
        trackingIcon = Icons.today;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ModernColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trackingIcon,
            size: 14,
            color: ModernColors.secondary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              trackingText,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: ModernColors.secondary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 상태 설명 표시
  Widget _buildStatusDescription(QuestInstance quest) {
    final description = QuestConditionFormatter.getStatusDescription(quest);
    if (description.isEmpty) return const SizedBox.shrink();

    Color statusColor;
    IconData statusIcon;

    switch (quest.status) {
      case QuestStatus.notStarted:
        statusColor = ModernColors.textSecondary;
        statusIcon = Icons.info_outline;
        break;
      case QuestStatus.inProgress:
        if (quest.canComplete) {
          statusColor = ModernColors.success;
          statusIcon = Icons.check_circle_outline;
        } else {
          statusColor = ModernColors.secondary;
          statusIcon = Icons.play_circle_outline;
        }
        break;
      case QuestStatus.completed:
        statusColor = ModernColors.warning;
        statusIcon = Icons.card_giftcard;
        break;
      case QuestStatus.claimed:
        statusColor = ModernColors.success;
        statusIcon = Icons.check_circle;
        break;
    }

    return Row(
      children: [
        Icon(
          statusIcon,
          size: 12,
          color: statusColor,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            description,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getBorderColor(QuestInstance quest) {
    if (quest.canClaim) return ModernColors.warning;
    if (quest.canComplete) return ModernColors.success;
    if (quest.isInProgress) return ModernColors.secondary;
    if (quest.status == QuestStatus.claimed) return ModernColors.border;
    return ModernColors.border;
  }

  Color _getCategoryColor(QuestInstance quest) {
    switch (quest.category) {
      case QuestCategoryV2.stamina:
        return ModernColors.warning;
      case QuestCategoryV2.knowledge:
        return ModernColors.primary;
      case QuestCategoryV2.technique:
        return ModernColors.accent;
      case QuestCategoryV2.sociality:
        return ModernColors.success;
      case QuestCategoryV2.willpower:
        return ModernColors.primary;
    }
  }

  Widget _buildStatRewardItem({
    required QuestCategoryV2 category,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  category.displayName,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    color: ModernColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      color: ModernColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleClaimReward,
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernColors.warning,
          foregroundColor: ModernColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard, size: 20),
            const SizedBox(width: 8),
            Text(
              '보상 받기',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = widget.quest.progressRatio;
    final isCompleted = progress >= 1.0;

    // Check if this is a multiple conditions quest that needs split progress bars
    if (widget.quest.trackingCondition.type ==
        QuestTrackingType.multipleConditions) {
      return _buildMultipleConditionsProgress();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isCompleted ? '완료됨' : '진행률',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? ModernColors.success
                    : ModernColors.textSecondary,
              ),
            ),
            Text(
              QuestConditionFormatter.formatProgress(widget.quest),
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color:
                    isCompleted ? ModernColors.success : ModernColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: ModernColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? ModernColors.success : ModernColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 복수 조건 퀘스트용 분할 진행률 표시
  Widget _buildMultipleConditionsProgress() {
    final conditionsRaw = widget
        .quest.trackingCondition.parameters['conditions'] as List<dynamic>;
    final conditions = conditionsRaw.cast<String>();
    final conditionCount = conditions.length;
    final completedConditions = widget.quest.currentProgress;
    final allCompleted = completedConditions >= conditionCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 전체 진행률 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              allCompleted ? '완료됨' : '진행률',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: allCompleted
                    ? ModernColors.success
                    : ModernColors.textSecondary,
              ),
            ),
            Text(
              '$completedConditions / $conditionCount',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: allCompleted
                    ? ModernColors.success
                    : ModernColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 개별 조건들의 진행률
        ...conditions.asMap().entries.map((entry) {
          final index = entry.key;
          final condition = entry.value;
          return Padding(
            padding: EdgeInsets.only(
                bottom: index < conditions.length - 1 ? 12.0 : 0.0),
            child: _buildSingleConditionProgress(condition, index),
          );
        }),
      ],
    );
  }

  /// 개별 조건의 진행률 표시
  Widget _buildSingleConditionProgress(String condition, int index) {
    final parts = condition.split(':');
    if (parts.length != 2) return const SizedBox.shrink();

    final dataKey = parts[0];
    final targetValue = int.tryParse(parts[1]) ?? 0;

    // Get current value from quest tracking data
    final currentValue = widget.quest.trackingData[dataKey] as int? ?? 0;
    final progress =
        targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    final isCompleted = currentValue >= targetValue;

    String conditionName;
    String progressText;

    switch (dataKey) {
      case 'weekly_readingPages':
        conditionName = '독서 페이지';
        progressText = '$currentValue/$targetValue페이지';
        break;
      case 'weekly_movieLogs':
        conditionName = '영화 감상';
        progressText = '$currentValue/$targetValue편';
        break;
      case 'readingPages':
        conditionName = '독서 페이지';
        progressText = '$currentValue/$targetValue페이지';
        break;
      case 'movieLogs':
        conditionName = '영화 감상';
        progressText = '$currentValue/$targetValue편';
        break;
      default:
        conditionName = dataKey;
        progressText = '$currentValue/$targetValue';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              conditionName,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? ModernColors.success
                    : ModernColors.textSecondary,
              ),
            ),
            Text(
              progressText,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    isCompleted ? ModernColors.success : ModernColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: ModernColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? ModernColors.success : ModernColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: ModernColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: ModernColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '완료됨',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClaimReward() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    HapticFeedbackManager.heavyImpact();

    try {
      await ref
          .read(questProviderV2.notifier)
          .claimReward(widget.quest.instanceId);

      // 개별 퀘스트 완료 알림은 제거 (전체 완료 시에만 알림)

      // 업데이트된 퀘스트 데이터를 가져와서 전달
      final questsAsync = ref.read(questProviderV2);
      questsAsync.whenData((quests) {
        final updatedQuest = quests.firstWhere(
          (q) => q.instanceId == widget.quest.instanceId,
          orElse: () => widget.quest,
        );
        widget.onQuestCompleted(updatedQuest);
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
