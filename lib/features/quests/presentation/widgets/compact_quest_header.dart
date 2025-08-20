import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../providers/quest_provider_v2.dart';
import '../../models/quest_instance_model.dart';

/// 🎮 컴팩트 셰르피 퀘스트 헤더 - 미니멀 게이미피케이션 디자인
/// 
/// 기존 280px → 130px로 축소하여 퀘스트 카드들이 첫 화면에 보이도록 최적화
/// 셰르피 중심의 수평 배치 디자인으로 공간 효율성 극대화
class CompactQuestHeader extends ConsumerWidget {
  const CompactQuestHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalUser = ref.watch(globalUserProvider);
    final totalPoints = ref.watch(globalTotalPointsProvider);
    final questsAsync = ref.watch(questProviderV2);
    
    return questsAsync.when(
      data: (quests) {
        // 퀘스트 상태별 카운트 계산
        final inProgressCount = quests.where((q) => q.status == QuestStatus.inProgress).length;
        final claimableCount = quests.where((q) => q.status == QuestStatus.completed).length;
        final claimedCount = quests.where((q) => q.status == QuestStatus.claimed).length;
        
        // 전체 진행률 계산
        final overallProgress = quests.isNotEmpty ? claimedCount / quests.length : 0.0;
        
        return Container(
          height: 140, // 130px → 140px (오버플로우 해결)
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ModernColors.modernPrimary.withValues(alpha: 0.9),
                ModernColors.modernPrimary.withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // 12 → 8로 축소
              child: Column(
                children: [
                  // 🎯 상단 바: 셰르피 + 인사말 + 완성도
                  _buildTopBar(context, globalUser.name, totalPoints, overallProgress),
                  
                  const SizedBox(height: 12), // 16 → 12로 축소
                  
                  // 📊 하단 바: 퀘스트 상태 + 진행률
                  _buildStatusBar(
                    context,
                    inProgressCount,
                    claimableCount, 
                    claimedCount,
                    overallProgress,
                  ),
                ],
              ),
            ),
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: -0.1, end: 0);
      },
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(),
    );
  }
  
  /// 🎪 상단 바: 셰르피와 퀘스트 완성도가 있는 메인 영역
  Widget _buildTopBar(BuildContext context, String userName, int totalPoints, double overallProgress) {
    return Container(
      height: 64,
      child: Row(
        children: [
          // 🐾 컴팩트 셰르피 아바타 (70px → 44px)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/sherpi/sherpi_happy.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF5B7FFF), Color(0xFF4A6FE7)],
                      ),
                    ),
                    child: const Icon(
                      Icons.face_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ).animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3)),
          
          const SizedBox(width: 12),
          
          // 💬 간단한 인사말
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '안녕하세요, ${userName}님!',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '오늘의 퀘스트를 확인해보세요 🎯',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // 🎯 퀘스트 완성도 서클
          Container(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 서클
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: overallProgress,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
                // 가운데 퍼센트 텍스트
                Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 📈 하단 바: 퀘스트 상태와 진행률
  Widget _buildStatusBar(
    BuildContext context,
    int inProgressCount,
    int claimableCount, 
    int claimedCount,
    double overallProgress,
  ) {
    return Container(
      height: 42,
      child: Row(
        children: [
          // 🎮 상태 칩들 (수평 배치)
          _buildStatusChip(
            icon: Icons.play_circle_outline_rounded,
            count: inProgressCount,
            color: ModernColors.modernPrimary,
            label: '진행중',
          ),
          const SizedBox(width: 8),
          
          _buildStatusChip(
            icon: Icons.card_giftcard_rounded,
            count: claimableCount,
            color: ModernColors.reward,
            label: '대기',
            hasGlow: claimableCount > 0,
          ),
          const SizedBox(width: 8),
          
          _buildStatusChip(
            icon: Icons.check_circle_rounded,
            count: claimedCount,
            color: ModernColors.modernSuccess,
            label: '완료',
          ),
          
          const SizedBox(width: 16),
          
          // 📊 컴팩트 진행률 바
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 진행률 숫자
                Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // 진행률 바
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🏷️ 상태 칩 (작은 크기)
  Widget _buildStatusChip({
    required IconData icon,
    required int count,
    required Color color,
    required String label,
    bool hasGlow = false,
  }) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
    
    if (hasGlow && count > 0) {
      return chip.animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(seconds: 2),
          color: Colors.white.withValues(alpha: 0.5),
        );
    }
    
    return chip;
  }
  
  /// 🔄 로딩 상태 (컴팩트)
  Widget _buildLoadingState() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.modernPrimary.withValues(alpha: 0.7),
            ModernColors.modernPrimary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
  
  /// ❌ 에러 상태 (컴팩트)  
  Widget _buildErrorState() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.modernPrimary.withValues(alpha: 0.7),
            ModernColors.modernPrimary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '퀘스트 로딩 실패',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}