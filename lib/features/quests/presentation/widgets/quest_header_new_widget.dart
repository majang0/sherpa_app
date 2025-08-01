import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../constants/quest_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../providers/quest_provider_v2.dart';
import '../../models/quest_instance_model.dart';

/// 새로운 퀘스트 헤더 위젯 - 2024-2025 모던 디자인 트렌드 적용
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
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E40AF), // Deep Ocean Blue
                const Color(0xFF3B82F6), // Sky Blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '퀘스트',
                              style: GoogleFonts.notoSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${globalUser.name}님의 도전 과제',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 포인트 표시 (글라스모피즘 스타일)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20, 
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBBF24).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.monetization_on_rounded,
                                    color: const Color(0xFFFBBF24),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '포인트',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '$totalPoints P',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideX(begin: 0.3, end: 0),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 퀘스트 상태 카드들 (플로팅 스타일)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assessment_rounded,
                              color: const Color(0xFF1E40AF),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '퀘스트 현황',
                              style: GoogleFonts.notoSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernStatusCard(
                                icon: Icons.play_arrow_rounded,
                                label: '진행 중',
                                count: inProgressCount,
                                color: const Color(0xFF3B82F6),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF3B82F6),
                                    const Color(0xFF60A5FA),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                index: 0,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernStatusCard(
                                icon: Icons.card_giftcard_rounded,
                                label: '보상 대기',
                                count: claimableCount,
                                color: const Color(0xFFFBBF24),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFBBF24),
                                    const Color(0xFFFCD34D),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                hasAnimation: claimableCount > 0,
                                index: 1,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernStatusCard(
                                icon: Icons.check_circle_rounded,
                                label: '완료',
                                count: claimedCount,
                                color: const Color(0xFF0EA5E9),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF0EA5E9),
                                    const Color(0xFF38BDF8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                index: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // 오늘의 진행 상황 (모던 디자인)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF7C3AED),
                                        const Color(0xFF8B5CF6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.today_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '오늘의 성과',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF0EA5E9),
                                    const Color(0xFF38BDF8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                '$todayClaimedCount개 완료',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // 진행률 바 (그라데이션 스타일)
                        Column(
                          children: [
                            Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: overallProgress,
                                  minHeight: 12,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            // 커스텀 프로그레스 바 오버레이
                            Container(
                              height: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 12,
                                      color: const Color(0xFFF1F5F9),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: overallProgress,
                                      child: Container(
                                        height: 12,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF1E40AF),
                                              const Color(0xFF3B82F6),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '전체 진행률',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(overallProgress * 100).toInt()}%',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E40AF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 1000.ms, delay: 600.ms)
                    .slideY(begin: 0.3, end: 0),
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
  
  Widget _buildModernStatusCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required LinearGradient gradient,
    bool hasAnimation = false,
    required int index,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: GoogleFonts.notoSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: (800 + index * 100).ms)
      .slideY(begin: 0.3, end: 0)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
    
    if (hasAnimation) {
      return card.animate(
        onPlay: (controller) => controller.repeat(),
      ).shimmer(
        duration: const Duration(seconds: 2),
        color: Colors.white.withOpacity(0.3),
      ).then()
        .scale(
          duration: 1500.ms,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
        )
        .then()
        .scale(
          duration: 1500.ms,
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
        );
    }
    
    return card;
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E40AF),
            const Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '퀘스트 정보를 불러오는 중...',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E40AF),
            const Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '퀘스트를 불러올 수 없습니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '잠시 후 다시 시도해주세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}