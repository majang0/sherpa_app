import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

// Shared Providers
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

// Features
import '../../../quests/providers/quest_provider_v2.dart';
import '../../../quests/models/quest_instance_model.dart';
import '../../../quests/models/quest_template_model.dart';

/// 간소화된 퀘스트 위젯
/// 미완료 퀘스트 최대 2개만 표시하는 컴팩트한 디자인
class CompactQuestWidget extends ConsumerStatefulWidget {
  const CompactQuestWidget({super.key});

  @override
  ConsumerState<CompactQuestWidget> createState() => _CompactQuestWidgetState();
}

class _CompactQuestWidgetState extends ConsumerState<CompactQuestWidget>
    with SingleTickerProviderStateMixin {
      
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// 미완료 퀘스트 필터링 및 정렬
  List<QuestInstance> _getUncompletedQuests(List<QuestInstance> allQuests) {
    return allQuests
        .where((quest) =>
            (quest.type == QuestTypeV2.daily || quest.type == QuestTypeV2.weekly) &&
            quest.status == QuestStatus.inProgress)
        .toList()
      ..sort((a, b) => b.progressRatio.compareTo(a.progressRatio)); // 진행률 높은 순
  }

  /// 상태별 셰르피 감정 결정
  SherpiEmotion _getSherpiEmotion(int uncompletedCount) {
    if (uncompletedCount == 0) {
      return SherpiEmotion.special; // 모든 퀘스트 완료
    } else if (uncompletedCount == 1) {
      return SherpiEmotion.guiding; // 1개 남음 - 안내
    } else {
      return SherpiEmotion.thinking; // 2개+ - 생각하는 표정
    }
  }

  /// 상태별 메시지
  String _getStatusMessage(int uncompletedCount) {
    if (uncompletedCount == 0) {
      return '모든 퀘스트를 완료했어요! 🎉';
    } else if (uncompletedCount == 1) {
      return '조금만 더 힘내면 완료예요!';
    } else {
      return '오늘의 퀘스트를 확인해보세요';
    }
  }

  /// 퀘스트 탭으로 이동
  void _navigateToQuestTab() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
      arguments: 2, // 퀘스트 탭 인덱스
    );
  }

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(questProviderV2);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: ModernColors.softShadow(primaryColor: ModernColors.modernPrimary),
        ),
        child: questsAsync.when(
          data: (quests) => _buildContent(quests),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(),
        ),
      ),
    );
  }

  Widget _buildContent(List<QuestInstance> allQuests) {
    final uncompletedQuests = _getUncompletedQuests(allQuests);
    final displayQuests = uncompletedQuests.take(2).toList();
    final sherpiEmotion = _getSherpiEmotion(uncompletedQuests.length);
    final statusMessage = _getStatusMessage(uncompletedQuests.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 헤더 섹션
        _buildHeader(sherpiEmotion, statusMessage),
        
        // 콘텐츠 섹션
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: uncompletedQuests.isEmpty
              ? _buildEmptyState()
              : _buildQuestList(displayQuests),
        ),
      ],
    );
  }

  Widget _buildHeader(SherpiEmotion emotion, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 셰르피 캐릭터
          GestureDetector(
            onTap: () {
              ref.read(sherpiProvider.notifier).showMessage(
                context: SherpiContext.questComplete,
                emotion: emotion,
              );
              HapticFeedbackManager.lightImpact();
            },
            child: Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.modernPrimary.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: ModernColors.modernPrimary.withOpacity(0.2),
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Transform.scale(
                  scale: 1.3,
                  child: Image.asset(
                    emotion.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 텍스트 섹션
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '퀘스트 알림',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // 더보기 버튼
          GestureDetector(
            onTap: () {
              _navigateToQuestTab();
              HapticFeedbackManager.lightImpact();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ModernColors.modernPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ModernColors.modernPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestList(List<QuestInstance> quests) {
    return Column(
      children: quests.asMap().entries.map((entry) {
        final index = entry.key;
        final quest = entry.value;
        return Column(
          children: [
            if (index > 0) const SizedBox(height: 8),
            _buildQuestCard(quest),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuestCard(QuestInstance quest) {
    final progress = quest.progressRatio;
    final progressPercent = (progress * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.border.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.modernPrimary.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 카테고리 이모지
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: quest.difficultyColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                quest.category.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 퀘스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${quest.currentProgress}/${quest.targetProgress}',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: quest.difficultyColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 진행률 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: ModernColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(quest.difficultyColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ModernColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 32,
                color: ModernColors.success,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '훌륭해요!',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '모든 퀘스트를 완료했습니다',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: ModernColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ModernColors.modernPrimary),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 32,
            color: ModernColors.error,
          ),
          const SizedBox(height: 8),
          Text(
            '퀘스트를 불러올 수 없습니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}