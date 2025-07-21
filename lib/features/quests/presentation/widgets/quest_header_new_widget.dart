import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/quest_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../providers/quest_provider_v2.dart';
import '../../models/quest_instance_model.dart';

/// 새로운 퀘스트 헤더 위젯 - 모던하고 깔끔한 디자인
class QuestHeaderNewWidget extends ConsumerWidget {
  const QuestHeaderNewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalUser = ref.watch(globalUserProvider);
    final totalPoints = ref.watch(globalTotalPointsProvider);
    final questsAsync = ref.watch(questProviderV2);
    
    return questsAsync.when(
      data: (quests) {
        // 정확한 상태별 카운트 계산
        // 진행 중: inProgress 상태만 (notStarted 포함하지 않음)
        final inProgressCount = quests.where((q) => 
          q.status == QuestStatus.inProgress
        ).length;
        
        // 보상 대기: completed 상태
        final claimableCount = quests.where((q) => 
          q.status == QuestStatus.completed
        ).length;
        
        // 완료: claimed 상태
        final claimedCount = quests.where((q) => 
          q.status == QuestStatus.claimed
        ).length;
        
        // 오늘 완료한 퀘스트 수
        final today = DateTime.now();
        final todayClaimedCount = quests.where((q) => 
          q.status == QuestStatus.claimed && 
          q.claimedAt != null &&
          q.claimedAt!.year == today.year &&
          q.claimedAt!.month == today.month &&
          q.claimedAt!.day == today.day
        ).length;
        
        // 전체 진행률 계산 (claimed 기준)
        final overallProgress = quests.isNotEmpty 
          ? claimedCount / quests.length 
          : 0.0;
        
        return Container(
          decoration: BoxDecoration(
            color: QuestColors.backgroundWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 상단 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '퀘스트',
                            style: GoogleFonts.notoSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: QuestColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${globalUser.name}님의 도전 과제',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: QuestColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      // 포인트 표시
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: QuestColors.accentGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: QuestColors.accentGold,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$totalPoints P',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: QuestColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 퀘스트 상태 카드들
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.play_arrow_rounded,
                          label: '진행 중',
                          count: inProgressCount,
                          color: QuestColors.primaryBlue,
                          isFirst: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.card_giftcard_rounded,
                          label: '보상 대기',
                          count: claimableCount,
                          color: QuestColors.accentGold,
                          hasAnimation: claimableCount > 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.check_circle_rounded,
                          label: '완료',
                          count: claimedCount,
                          color: QuestColors.accentGreen,
                          isLast: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 오늘의 진행 상황
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: QuestColors.inactive.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.today_rounded,
                                  size: 20,
                                  color: QuestColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '오늘의 성과',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: QuestColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: QuestColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$todayClaimedCount개 완료',
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: QuestColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 진행률 바
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: overallProgress,
                                minHeight: 8,
                                backgroundColor: QuestColors.inactive,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  QuestColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '전체 진행률',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    color: QuestColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${(overallProgress * 100).toInt()}%',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: QuestColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(),
    );
  }
  
  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
    bool hasAnimation = false,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: QuestColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: QuestColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
    
    if (hasAnimation) {
      return card.animate(
        onPlay: (controller) => controller.repeat(),
      ).shimmer(
        duration: const Duration(seconds: 2),
        color: color.withOpacity(0.3),
      );
    }
    
    return card;
  }
  
  Widget _buildLoadingState() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: QuestColors.backgroundWhite,
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: QuestColors.backgroundWhite,
      ),
      child: Center(
        child: Text(
          '퀘스트를 불러올 수 없습니다',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: QuestColors.textSecondary,
          ),
        ),
      ),
    );
  }
}