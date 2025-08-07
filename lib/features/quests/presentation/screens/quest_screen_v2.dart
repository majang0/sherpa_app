import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../constants/quest_colors.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../models/quest_instance_model.dart';
import '../../models/quest_template_model.dart';
import '../../providers/quest_provider_v2.dart';
import '../widgets/quest_header_new_widget.dart';
import '../widgets/quest_card_v2_widget.dart';
import '../widgets/quest_completion_animation_widget.dart';

/// 새로운 퀘스트 화면 (V2) - quest.md 기반
class QuestScreenV2 extends ConsumerStatefulWidget {
  const QuestScreenV2({Key? key}) : super(key: key);

  @override
  ConsumerState<QuestScreenV2> createState() => _QuestScreenV2State();
}

class _QuestScreenV2State extends ConsumerState<QuestScreenV2>
    with TickerProviderStateMixin {
  
  // 애니메이션 컨트롤러들
  late AnimationController _fadeInController;
  late AnimationController _celebrationController;
  late Animation<double> _fadeInAnimation;
  
  // 현재 선택된 카테고리
  QuestTypeV2 _selectedCategory = QuestTypeV2.daily;
  
  // 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();
  
  // 완료 애니메이션 상태
  final GlobalKey<QuestCompletionAnimationState> _completionAnimationKey = 
      GlobalKey<QuestCompletionAnimationState>();

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // 애니메이션 설정
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOutCubic),
    );
    
    // 초기 애니메이션 시작
    _fadeInController.forward();
    
    // 🎯 탭 방문 기록 (퀘스트 추적용) - 셰르피 메시지는 보상 수령 시에만
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questProviderV2.notifier).recordTabVisit('퀘스트');
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _celebrationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 카테고리 변경 처리
  void _onCategoryChanged(QuestTypeV2 category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      
      // 부드러운 스크롤 애니메이션
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      
      HapticFeedbackManager.lightImpact();
    }
  }

  /// 퀘스트 완료 애니메이션 트리거
  void _onQuestCompleted(QuestInstance quest) {
    _completionAnimationKey.currentState?.showCompletionAnimation(quest);
    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });
    
    // 상태 새로고침으로 UI 업데이트
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onAllClearRewardClaimed() {
    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });
  }

  /// 프리미엄 구매 확인 다이얼로그
  void _showPremiumPurchaseDialog() {
    final currentPoints = ref.read(globalPointProvider).totalPoints;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  QuestColors.legendaryGold.withOpacity(0.1),
                  QuestColors.epicPurple.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 프리미엄 아이콘
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [QuestColors.legendaryGold, QuestColors.epicPurple],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: QuestColors.legendaryGold.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 제목
                Text(
                  '⭐ 프리미엄 퀘스트팩',
                  style: GoogleFonts.notoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: QuestColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 설명
                Text(
                  '특별한 전설급 퀘스트 3개를 잠금 해제하여\n더욱 큰 보상과 도전을 경험해보세요!',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: QuestColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // 포인트 정보
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentPoints >= 2000 
                        ? QuestColors.accentGreen.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentPoints >= 2000 
                          ? QuestColors.accentGreen.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '필요 포인트',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: QuestColors.textSecondary,
                            ),
                          ),
                          Text(
                            '2,000 P',
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: QuestColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '보유 포인트',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: QuestColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${currentPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} P',
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: currentPoints >= 2000 
                                  ? QuestColors.accentGreen
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (currentPoints < 2000) ...[
                  const SizedBox(height: 12),
                  Text(
                    '포인트가 부족합니다. 퀘스트를 완료하여 포인트를 획득하세요!',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: QuestColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentPoints >= 2000 ? () {
                          Navigator.of(context).pop();
                          HapticFeedbackManager.heavyImpact();
                          ref.read(questProviderV2.notifier).activatePremium();
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPoints >= 2000 
                              ? QuestColors.legendaryGold
                              : QuestColors.inactive,
                          foregroundColor: currentPoints >= 2000 
                              ? QuestColors.textPrimary
                              : QuestColors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: currentPoints >= 2000 ? 2 : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stars,
                              size: 18,
                              color: currentPoints >= 2000 
                                  ? QuestColors.textPrimary
                                  : QuestColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '구매하기',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(questProviderV2);
    
    return Scaffold(
      backgroundColor: QuestColors.backgroundWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              QuestColors.lightSkyBlue.withOpacity(0.1),
              QuestColors.backgroundWhite,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Stack(
            children: [
              // 배경 장식
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        QuestColors.skyBlue.withOpacity(0.1),
                        QuestColors.skyBlue.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 메인 컨텐츠
              questsAsync.when(
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error.toString()),
                data: (quests) => _buildMainContent(quests),
              ),
              
              // 완료 애니메이션 오버레이
              QuestCompletionAnimationWidget(
                key: _completionAnimationKey,
                animationController: _celebrationController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(List<QuestInstance> allQuests) {
    // 카테고리별 퀘스트 분류
    final dailyQuests = allQuests.where((q) => q.type == QuestTypeV2.daily).toList();
    final weeklyQuests = allQuests.where((q) => q.type == QuestTypeV2.weekly).toList();
    final premiumQuests = allQuests.where((q) => q.type == QuestTypeV2.premium).toList();
    
    // 상태별 개수 계산
    final statusCounts = <QuestTypeV2, Map<String, int>>{
      QuestTypeV2.daily: _calculateStatusCounts(dailyQuests),
      QuestTypeV2.weekly: _calculateStatusCounts(weeklyQuests),
      QuestTypeV2.premium: _calculateStatusCounts(premiumQuests),
    };
    
    // 선택된 카테고리에 따른 퀘스트 필터링
    final filteredQuests = allQuests
        .where((quest) => quest.type == _selectedCategory)
        .toList();
    
    // 퀘스트 정렬
    _sortQuests(filteredQuests);
    
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedbackManager.lightImpact();
        await ref.read(questProviderV2.notifier).refresh();
      },
      backgroundColor: QuestColors.pureWhite,
      color: QuestColors.primaryBlue,
      strokeWidth: 3,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 헤더 영역
          const SliverToBoxAdapter(
            child: QuestHeaderNewWidget(),
          ),
          
          // 카테고리 탭
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _buildCategoryTabs(statusCounts),
            ),
          ),
          
          // 상태별 퀘스트 현황
          SliverToBoxAdapter(
            child: _buildStatusSummary(statusCounts[_selectedCategory] ?? {}),
          ),
          
          
          // 전체 클리어 보너스 섹션
          if (filteredQuests.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildCompletionBonus(_selectedCategory, allQuests),
            ),
          
          // 빈 상태 또는 퀘스트 목록
          if (filteredQuests.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyStateContent(),
            )
          else
            // 퀘스트 목록
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 100,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final quest = filteredQuests[index];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: QuestCardV2Widget(
                        quest: quest,
                        onQuestCompleted: (updatedQuest) => _onQuestCompleted(updatedQuest),
                      ),
                    ).animate()
                      .fadeIn(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOutCubic,
                      );
                  },
                  childCount: filteredQuests.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 상태별 개수 계산
  Map<String, int> _calculateStatusCounts(List<QuestInstance> quests) {
    return {
      'inProgress': quests.where((q) => q.isInProgress && !q.canComplete && !q.canClaim).length,
      'claimable': quests.where((q) => q.canClaim).length,
      'completed': quests.where((q) => q.status == QuestStatus.claimed).length,
    };
  }

  /// 새로운 카테고리 탭 빌더
  Widget _buildCategoryTabs(
    Map<QuestTypeV2, Map<String, int>> statusCounts,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: QuestColors.pureWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: QuestColors.softShadow,
      ),
      child: Row(
        children: QuestTypeV2.values.map((type) {
          final isSelected = _selectedCategory == type;
          final counts = statusCounts[type] ?? {};
          final total = (counts['inProgress'] ?? 0) + (counts['claimable'] ?? 0) + (counts['completed'] ?? 0);
          final claimable = counts['claimable'] ?? 0;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _onCategoryChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? type.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            size: 16,
                            color: isSelected ? Colors.white : type.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            type.displayName,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : type.color,
                            ),
                          ),
                          if (claimable > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : QuestColors.accentGold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$claimable',
                                style: GoogleFonts.notoSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? type.color : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 상태별 퀘스트 현황
  Widget _buildStatusSummary(Map<String, int> counts) {
    final inProgress = counts['inProgress'] ?? 0;
    final claimable = counts['claimable'] ?? 0;
    final completed = counts['completed'] ?? 0;
    
    if (inProgress == 0 && claimable == 0 && completed == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuestColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: QuestColors.softShadow,
      ),
      child: Row(
        children: [
          if (inProgress > 0) ...[
            Expanded(
              child: _buildStatusItem(
                '진행 중',
                '$inProgress개',
                QuestColors.skyBlue,
                Icons.play_circle_outline,
              ),
            ),
          ],
          if (claimable > 0) ...[
            if (inProgress > 0) 
              Container(
                width: 1,
                height: 40,
                color: QuestColors.inactive,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
            Expanded(
              child: _buildStatusItem(
                '보상 대기',
                '$claimable개',
                QuestColors.accentGold,
                Icons.card_giftcard,
              ),
            ),
          ],
          if (completed > 0) ...[
            if (inProgress > 0 || claimable > 0)
              Container(
                width: 1,
                height: 40,
                color: QuestColors.inactive,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
            Expanded(
              child: _buildStatusItem(
                '완료',
                '$completed개',
                QuestColors.completed,
                Icons.check_circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: QuestColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 완료 보너스 정보 (셰르파 앱 테마 적용)
  Widget _buildCompletionBonus(QuestTypeV2 type, List<QuestInstance> allQuests) {
    if (type == QuestTypeV2.premium) return const SizedBox.shrink();
    
    final questProvider = ref.read(questProviderV2.notifier);
    final isAllCompleted = type == QuestTypeV2.daily 
        ? questProvider.isDailyAllCompleted
        : questProvider.isWeeklyAllCompleted;
    
    final bonus = type == QuestTypeV2.daily 
        ? QuestCompletionBonus.dailyBonus
        : QuestCompletionBonus.weeklyBonus;
    
    // 진행률 계산
    final typeQuests = allQuests.where((q) => q.type == type).toList();
    final completedCount = typeQuests.where((q) => 
        q.status == QuestStatus.completed || q.status == QuestStatus.claimed).length;
    final totalCount = typeQuests.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final progressPercent = (progress * 100).round();
    
    // 보너스가 이미 수령되었는지 확인
    final bonusKey = type == QuestTypeV2.daily ? 'daily_bonus_v2_today' : 'weekly_bonus_v2_today';
    final alreadyClaimed = questProvider.isBonusAlreadyClaimed(bonusKey);
    
    final canClaim = isAllCompleted && !alreadyClaimed;
    final showCompleted = isAllCompleted && alreadyClaimed;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: QuestColors.pureWhite,
          border: Border.all(
            color: canClaim 
                ? QuestColors.accentGold
                : showCompleted
                  ? QuestColors.completed
                  : QuestColors.skyBlue,
            width: 2,
          ),
          boxShadow: canClaim ? [
            BoxShadow(
              color: QuestColors.accentGold.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : QuestColors.softShadow,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: canClaim 
              ? QuestColors.accentGold.withOpacity(0.05)
              : showCompleted 
                ? QuestColors.completed.withOpacity(0.05)
                : QuestColors.skyBlue.withOpacity(0.02),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 상단 헤더 섹션
                Row(
                  children: [
                    // 보상 상자 아이콘
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: canClaim 
                            ? QuestColors.accentGold.withOpacity(0.1)
                            : showCompleted
                              ? QuestColors.completed.withOpacity(0.1)
                              : QuestColors.skyBlue.withOpacity(0.1),
                        border: Border.all(
                          color: canClaim 
                              ? QuestColors.accentGold.withOpacity(0.3)
                              : showCompleted
                                ? QuestColors.completed.withOpacity(0.3)
                                : QuestColors.skyBlue.withOpacity(0.3),
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        canClaim 
                            ? Icons.card_giftcard_rounded
                            : showCompleted
                              ? Icons.check_circle_rounded
                              : Icons.lock_rounded,
                        color: canClaim 
                            ? QuestColors.accentGold
                            : showCompleted
                              ? QuestColors.completed
                              : QuestColors.skyBlue,
                        size: 28,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // 제목과 설명
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            canClaim 
                                ? '🎉 보상 상자 준비 완료!'
                                : showCompleted
                                  ? '✅ 보상 수령 완료'
                                  : '🔒 보상 상자 (잠김)',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: QuestColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type == QuestTypeV2.daily ? '일일 퀘스트 마스터' : '주간 퀘스트 레전드',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: QuestColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 진행률 표시
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 5,
                              backgroundColor: QuestColors.inactive.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                canClaim 
                                    ? QuestColors.accentGold
                                    : showCompleted
                                      ? QuestColors.completed
                                      : QuestColors.skyBlue,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '$progressPercent%',
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: canClaim 
                                    ? QuestColors.accentGold
                                    : showCompleted
                                      ? QuestColors.completed
                                      : QuestColors.skyBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 보상 아이템들
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: QuestColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: QuestColors.inactive.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // XP 보상
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 20,
                              color: QuestColors.skyBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+${bonus.experienceBonus.toInt()}',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: QuestColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'XP',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: QuestColors.skyBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 구분선
                      Container(
                        width: 1,
                        height: 24,
                        color: QuestColors.inactive.withOpacity(0.5),
                      ),
                      
                      // 포인트 보상
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 20,
                              color: QuestColors.accentGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+${bonus.pointsBonus.toInt()}',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: QuestColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'P',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: QuestColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 액션 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: canClaim
                      ? ElevatedButton(
                          onPressed: () async {
                            HapticFeedbackManager.heavyImpact();
                            await _claimCompletionBonus(type);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: QuestColors.accentGold,
                            foregroundColor: QuestColors.pureWhite,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.card_giftcard_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text('보상 상자 열기!'),
                            ],
                          ),
                        ).animate(
                          onPlay: (controller) => controller.repeat(reverse: true),
                        ).scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.02, 1.02),
                          duration: const Duration(milliseconds: 1500),
                        )
                      : showCompleted
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: QuestColors.completed.withOpacity(0.1),
                                border: Border.all(
                                  color: QuestColors.completed,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: QuestColors.completed,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '보상 수령 완료',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: QuestColors.completed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: QuestColors.inactive.withOpacity(0.1),
                                border: Border.all(
                                  color: QuestColors.inactive,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      color: QuestColors.inactive,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${completedCount}/${totalCount} 퀘스트 완료 필요',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: QuestColors.inactive,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 완료 보너스 수령
  Future<void> _claimCompletionBonus(QuestTypeV2 type) async {
    try {
      final questProvider = ref.read(questProviderV2.notifier);
      final userNotifier = ref.read(globalUserProvider.notifier);
      final pointNotifier = ref.read(globalPointProvider.notifier);
      
      final bonus = type == QuestTypeV2.daily 
          ? QuestCompletionBonus.dailyBonus
          : QuestCompletionBonus.weeklyBonus;
      
      final bonusKey = type == QuestTypeV2.daily ? 'daily_bonus_v2_today' : 'weekly_bonus_v2_today';
      
      // 보상 지급
      userNotifier.addExperience(bonus.experienceBonus);
      pointNotifier.addPoints(
        bonus.pointsBonus.toInt(),
        bonus.description,
      );
      
      // 보너스 수령 표시
      await questProvider.markBonusAsClaimed(bonusKey);
      
      // 셰르피 메시지
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.achievement,
        emotion: SherpiEmotion.cheering,
        userContext: {
          'achievement': bonus.description,
          'experience': bonus.experienceBonus.toInt(),
          'points': bonus.pointsBonus.toInt(),
        },
      );
      
      // 완료 애니메이션 트리거
      _onAllClearRewardClaimed();
      
    } catch (e) {
      // 에러 처리
    }
  }

  /// 퀘스트 정렬 로직
  void _sortQuests(List<QuestInstance> quests) {
    quests.sort((a, b) {
      // 1. 보상 수령 가능한 퀘스트를 맨 위로
      if (a.canClaim && !b.canClaim) return -1;
      if (!a.canClaim && b.canClaim) return 1;

      // 2. 완료 가능한 퀘스트를 그 다음으로
      if (a.canComplete && !b.canComplete) return -1;
      if (!a.canComplete && b.canComplete) return 1;

      // 3. 진행 중인 퀘스트를 그 다음으로
      if (a.isInProgress && !b.isInProgress) return -1;
      if (!a.isInProgress && b.isInProgress) return 1;

      // 4. 완료된 퀘스트는 맨 아래로
      if (a.status == QuestStatus.claimed && b.status != QuestStatus.claimed) return 1;
      if (a.status != QuestStatus.claimed && b.status == QuestStatus.claimed) return -1;

      // 5. 퀘스트 ID 기준 정렬 (템플릿 순서 유지)
      return a.id.compareTo(b.id);
    });
  }

  /// 🔄 로딩 상태
  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: QuestColors.pureWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: QuestColors.softShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: QuestColors.skyGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: QuestColors.pureWhite,
                    size: 40,
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(),
                ).rotate(
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  '✨ 새로운 모험 준비 중...',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: QuestColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'quest.md 기반의 새로운 퀘스트가 곧 펼쳐집니다!',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: QuestColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                LinearProgressIndicator(
                  backgroundColor: QuestColors.inactive,
                  valueColor: const AlwaysStoppedAnimation<Color>(QuestColors.skyBlue),
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ 에러 상태
  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: QuestColors.pureWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: QuestColors.softShadow,
          border: Border.all(
            color: Colors.red.shade100,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '퀘스트를 불러올 수 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: QuestColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '잠시 후 다시 시도해주세요',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: QuestColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedbackManager.mediumImpact();
                ref.read(questProviderV2.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                '다시 시도',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: QuestColors.primaryBlue,
                foregroundColor: QuestColors.pureWhite,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 빈 상태 컨텐츠
  Widget _buildEmptyStateContent() {
    String emoji;
    String title;
    String subtitle;
    
    switch (_selectedCategory) {
      case QuestTypeV2.daily:
        emoji = '📅';
        title = '오늘의 모험이 준비되고 있어요';
        subtitle = '매일 새로운 도전이 기다립니다!';
        break;
      case QuestTypeV2.weekly:
        emoji = '📆';
        title = '주간 대모험을 준비하는 중이에요';
        subtitle = '더 큰 목표를 향한 여정이 곧 시작됩니다!';
        break;
      case QuestTypeV2.premium:
        emoji = '⭐';
        title = '프리미엄 전설 퀘스트';
        subtitle = '특별한 모험을 원하시나요?';
        break;
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: QuestColors.pureWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: QuestColors.softShadow,
          border: Border.all(
            color: QuestColors.skyBlue.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 애니메이션 이모지
            Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ).animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            ).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: QuestColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              subtitle,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: QuestColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (_selectedCategory == QuestTypeV2.premium) ...[
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedbackManager.lightImpact();
                    _showPremiumPurchaseDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuestColors.legendaryGold,
                    foregroundColor: QuestColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '프리미엄 퀘스트 잠금 해제 (2000P)',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
    );
  }
}