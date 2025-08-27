import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/notification_provider.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../models/quest_instance_model.dart';
import '../../models/quest_template_model.dart';
import '../../providers/quest_provider_v2.dart';
import '../widgets/compact_quest_header.dart';
import '../widgets/quest_card_v2_widget.dart';
import '../widgets/quest_completion_animation_widget.dart';

/// 🎮 셰르피 중심의 게이미피케이션 퀘스트 화면 (완전 재설계)
/// 
/// ✨ 주요 특징:
/// - 진행 중/보상 대기/완료 상태는 헤더로 이동 (중복 제거)
/// - 일일/주간/고급 탭만 유지
/// - ModernColors 디자인 시스템 적용
/// - 셰르피 중심의 인터랙티브 게이미피케이션 
class QuestScreenRedesigned extends ConsumerStatefulWidget {
  const QuestScreenRedesigned({super.key});

  @override
  ConsumerState<QuestScreenRedesigned> createState() => _QuestScreenRedesignedState();
}

class _QuestScreenRedesignedState extends ConsumerState<QuestScreenRedesigned>
    with SingleTickerProviderStateMixin {
  
  // 필수 애니메이션 컨트롤러만 유지
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;
  
  // Confetti 컨트롤러 - 보상 상자 효과용
  late ConfettiController _confettiController;
  
  // 현재 선택된 카테고리
  QuestTypeV2 _selectedCategory = QuestTypeV2.daily;
  
  // 완료 애니메이션 상태 (단순화됨)
  final GlobalKey<QuestCompletionAnimationState> _completionAnimationKey = 
      GlobalKey<QuestCompletionAnimationState>();

  @override
  void initState() {
    super.initState();
    
    // 필수 애니메이션만 초기화
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800), // 단축
      vsync: this,
    );
    
    // Confetti 컨트롤러 초기화
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2), // 단축
    );
    
    // 애니메이션 설정
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut),
    );
    
    // 초기 애니메이션 시작
    _fadeInController.forward();
    
    // 🎯 탭 방문 기록 (퀘스트 추적용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questProviderV2.notifier).recordTabVisit('퀘스트');
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// 카테고리 변경 처리
  void _onCategoryChanged(QuestTypeV2 category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      
      HapticFeedbackManager.lightImpact();
    }
  }

  // 셰르피 카테고리 변경 리액션 제거됨 (불필요한 UX 방해 요소)

  /// 퀘스트 완료 처리 (애니메이션 단순화)
  void _onQuestCompleted(QuestInstance quest) {
    _completionAnimationKey.currentState?.showCompletionAnimation(quest);
    
    // 상태 새로고침으로 UI 업데이트
    if (mounted) {
      setState(() {});
    }
  }

  void _onAllClearRewardClaimed() {
    // 단순한 완료 처리
    if (mounted) {
      setState(() {});
    }
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
                  ModernColors.reward.withOpacity(0.1),
                  ModernColors.modernAccent.withOpacity(0.1),
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
                    gradient: ModernColors.rewardGradient,
                    shape: BoxShape.circle,
                    boxShadow: ModernColors.rewardShadow(),
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
                    color: ModernColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 설명
                Text(
                  '특별한 전설급 퀘스트 3개를 잠금 해제하여\n더욱 큰 보상과 도전을 경험해보세요!',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textSecondary,
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
                        ? ModernColors.modernSuccess.withOpacity(0.1)
                        : ModernColors.modernError.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentPoints >= 2000 
                          ? ModernColors.modernSuccess.withOpacity(0.3)
                          : ModernColors.modernError.withOpacity(0.3),
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
                              color: ModernColors.textSecondary,
                            ),
                          ),
                          Text(
                            '2,000 P',
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ModernColors.textPrimary,
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
                              color: ModernColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${currentPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} P',
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: currentPoints >= 2000 
                                  ? ModernColors.modernSuccess
                                  : ModernColors.modernError,
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
                      color: ModernColors.modernError,
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
                            color: ModernColors.textSecondary,
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
                              ? ModernColors.reward
                              : ModernColors.inactive,
                          foregroundColor: currentPoints >= 2000 
                              ? Colors.white
                              : ModernColors.inactiveText,
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
                                  ? Colors.white
                                  : ModernColors.inactiveText,
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
      backgroundColor: ModernColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernColors.modernPrimary.withOpacity(0.05),
              ModernColors.background,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Stack(
            children: [
              // 🎨 동적 배경 장식 - 선택된 카테고리에 따라 변화
              _buildDynamicBackground(),
              
              // 메인 컨텐츠
              questsAsync.when(
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error.toString()),
                data: (quests) => _buildMainContent(quests),
              ),
              
              // 완료 애니메이션 오버레이 (내부 컨트롤러 사용)
              QuestCompletionAnimationWidget(
                key: _completionAnimationKey,
                // animationController 제거 - 내부 _internalController만 사용
              ),
              
              // 🎉 Confetti 위젯 - 보상 상자 클릭 시 효과
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: [
                    ModernColors.reward,
                    ModernColors.modernPrimary,
                    ModernColors.modernSuccess,
                    ModernColors.modernAccent,
                    ModernColors.quest,
                    Colors.pink,
                    Colors.orange,
                  ],
                  createParticlePath: (size) {
                    final path = Path();
                    path.addOval(Rect.fromCircle(
                      center: Offset(size.width / 2, size.height / 2),
                      radius: size.width / 2,
                    ));
                    return path;
                  },
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.2,
                  minBlastForce: 20,
                  maxBlastForce: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎨 단순한 정적 배경 - 선택된 카테고리에 따라 변화
  Widget _buildDynamicBackground() {
    Color primaryColor;
    
    switch (_selectedCategory) {
      case QuestTypeV2.daily:
        primaryColor = ModernColors.modernPrimary;
        break;
      case QuestTypeV2.weekly:
        primaryColor = ModernColors.modernAccent;
        break;
      case QuestTypeV2.premium:
        primaryColor = ModernColors.reward;
        break;
    }
    
    return Positioned(
      top: -100,
      right: -50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildMainContent(List<QuestInstance> allQuests) {
    // 카테고리별 퀘스트 분류
    final dailyQuests = allQuests.where((q) => q.type == QuestTypeV2.daily).toList();
    final weeklyQuests = allQuests.where((q) => q.type == QuestTypeV2.weekly).toList();
    final premiumQuests = allQuests.where((q) => q.type == QuestTypeV2.premium).toList();
    
    // 상태별 개수 계산 (헤더용)
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
      backgroundColor: ModernColors.surface,
      color: ModernColors.modernPrimary,
      strokeWidth: 3,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 헤더 영역 - 기존 CompactQuestHeader 사용
          const SliverToBoxAdapter(
            child: CompactQuestHeader(),
          ),
          
          // 🎮 새로운 게이미피케이션 카테고리 탭 
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: _buildGamifiedCategoryTabs(statusCounts),
            ),
          ),
          
          // 🎯 완료 보너스 섹션 (ModernColors 적용)
          if (filteredQuests.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildModernCompletionBonus(_selectedCategory, allQuests),
            ),
          
          // 빈 상태 또는 퀘스트 목록
          if (filteredQuests.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyStateContent(),
            )
          else
            // 퀘스트 목록 - 셰르피 요소 추가
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
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildGamifiedQuestCard(quest, index),
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

  /// 🎮 게이미피케이션이 적용된 카테고리 탭
  Widget _buildGamifiedCategoryTabs(
    Map<QuestTypeV2, Map<String, int>> statusCounts,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernColors.softShadow(primaryColor: ModernColors.modernPrimary),
      ),
      child: Row(
        children: QuestTypeV2.values.map((type) {
          final isSelected = _selectedCategory == type;
          final counts = statusCounts[type] ?? {};
          final total = (counts['inProgress'] ?? 0) + (counts['claimable'] ?? 0) + (counts['completed'] ?? 0);
          final claimable = counts['claimable'] ?? 0;
          final completed = counts['completed'] ?? 0;
          final progress = total > 0 ? completed / total : 0.0;
          
          // ModernColors 매핑
          Color categoryColor;
          switch (type) {
            case QuestTypeV2.daily:
              categoryColor = ModernColors.modernPrimary;
              break;
            case QuestTypeV2.weekly:
              categoryColor = ModernColors.modernAccent;
              break;
            case QuestTypeV2.premium:
              categoryColor = ModernColors.reward;
              break;
          }
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _onCategoryChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: isSelected ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [categoryColor, categoryColor.withOpacity(0.8)],
                  ) : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected 
                      ? ModernColors.softShadow(primaryColor: categoryColor)
                      : null,
                ),
                child: Stack(
                  children: [
                    // 백그라운드 진행률 표시
                    if (!isSelected && progress > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: [0, progress, progress, 1],
                              colors: [
                                categoryColor.withOpacity(0.1),
                                categoryColor.withOpacity(0.1),
                                Colors.transparent,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    
                    // 메인 컨텐츠
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type.icon,
                                size: 18,
                                color: isSelected ? Colors.white : categoryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                type.displayName,
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : categoryColor,
                                ),
                              ),
                              if (claimable > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : ModernColors.reward,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$claimable',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? categoryColor : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
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
        }).toList(),
      ),
    );
  }

  /// 🎁 ModernColors 기반 완료 보너스 (기존 _buildCompletionBonus 개선)
  Widget _buildModernCompletionBonus(QuestTypeV2 type, List<QuestInstance> allQuests) {
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
    
    // ModernColors 적용
    Color primaryColor = type == QuestTypeV2.daily 
        ? ModernColors.modernPrimary 
        : ModernColors.modernAccent;
    Color rewardColor = canClaim 
        ? ModernColors.reward
        : showCompleted
          ? ModernColors.modernSuccess
          : primaryColor;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ModernColors.surface,
          border: Border.all(
            color: rewardColor.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            // Outer glow for card
            BoxShadow(
              color: rewardColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            // Subtle elevation
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                rewardColor.withOpacity(0.03),
                rewardColor.withOpacity(0.08),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 상단 헤더 섹션 (ModernColors 적용)
                Row(
                  children: [
                    // 보상 상자 아이콘
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: canClaim 
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [ModernColors.reward, ModernColors.rewardGradient2],
                              )
                              : !showCompleted
                              ? LinearGradient(
                                  colors: [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.1)],
                                )
                              : null,
                        color: showCompleted ? ModernColors.modernSuccess : null,
                        shape: BoxShape.circle,
                        boxShadow: canClaim 
                            ? ModernColors.softShadow(primaryColor: rewardColor)
                            : showCompleted
                              ? [
                                  BoxShadow(
                                    color: ModernColors.modernSuccess.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: ModernColors.successLight.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                      ),
                      child: Icon(
                        canClaim 
                            ? Icons.card_giftcard_rounded
                            : showCompleted
                              ? Icons.verified_rounded
                              : Icons.lock_rounded,
                        color: canClaim || showCompleted ? Colors.white : primaryColor,
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
                                  ? '✨ 성취를 완료했어요!'
                                  : '🔒 보상 상자 (잠김)',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: showCompleted 
                                  ? ModernColors.modernSuccess 
                                  : ModernColors.textPrimary,
                              letterSpacing: showCompleted ? -0.3 : 0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            showCompleted 
                                ? (type == QuestTypeV2.daily ? '🏆 일일 퀘스트 마스터 달성' : '👑 주간 퀘스트 레전드 달성')
                                : (type == QuestTypeV2.daily ? '일일 퀘스트 마스터' : '주간 퀘스트 레전드'),
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: showCompleted ? FontWeight.w700 : FontWeight.w600,
                              color: showCompleted 
                                  ? ModernColors.modernSuccess.withValues(alpha: 0.8)
                                  : ModernColors.textSecondary,
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
                              backgroundColor: ModernColors.inactive.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(rewardColor),
                            ),
                          ),
                          Center(
                            child: Text(
                              '$progressPercent%',
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: rewardColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 보상 아이템들 (ModernColors 적용)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ModernColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ModernColors.border,
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
                              color: ModernColors.modernPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+${bonus.experienceBonus.toInt()}',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: ModernColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'XP',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ModernColors.modernPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 구분선
                      Container(
                        width: 1,
                        height: 24,
                        color: ModernColors.border,
                      ),
                      
                      // 포인트 보상
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 20,
                              color: ModernColors.reward,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+${bonus.pointsBonus.toInt()}',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: ModernColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'P',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ModernColors.reward,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 액션 버튼 (ModernColors 적용)
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
                            backgroundColor: ModernColors.reward,
                            foregroundColor: Colors.white,
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
                        )
                      : showCompleted
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ModernColors.modernSuccess.withOpacity(0.08),
                                border: Border.all(
                                  color: ModernColors.modernSuccess.withOpacity(0.6),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  // Inner glow effect for completed state
                                  BoxShadow(
                                    color: ModernColors.modernSuccess.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 0),
                                    spreadRadius: -2,
                                  ),
                                  // Premium outer shadow
                                  BoxShadow(
                                    color: ModernColors.modernSuccess.withOpacity(0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: ModernColors.modernSuccess,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '보상 수령 완료',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: ModernColors.modernSuccess,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ModernColors.inactive.withOpacity(0.1),
                                border: Border.all(
                                  color: ModernColors.inactive,
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
                                      color: ModernColors.inactive,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '$completedCount/$totalCount 퀘스트 완료 필요',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: ModernColors.inactive,
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

  /// 🎮 단순한 퀘스트 카드 (과도한 애니메이션 제거)
  Widget _buildGamifiedQuestCard(QuestInstance quest, int index) {
    return QuestCardV2Widget(
      quest: quest,
      onQuestCompleted: (updatedQuest) => _onQuestCompleted(updatedQuest),
    );
  }

  /// 카테고리별 색상 반환
  Color _getCategoryColor(QuestTypeV2 category) {
    switch (category) {
      case QuestTypeV2.daily:
        return ModernColors.modernPrimary;
      case QuestTypeV2.weekly:
        return ModernColors.modernAccent;
      case QuestTypeV2.premium:
        return ModernColors.reward;
    }
  }

  /// 완료 보너스 수령 (ModernColors 적용)
  Future<void> _claimCompletionBonus(QuestTypeV2 type) async {
    try {
      final questProvider = ref.read(questProviderV2.notifier);
      final userNotifier = ref.read(globalUserProvider.notifier);
      final pointNotifier = ref.read(globalPointProvider.notifier);
      
      final bonus = type == QuestTypeV2.daily 
          ? QuestCompletionBonus.dailyBonus
          : QuestCompletionBonus.weeklyBonus;
      
      final bonusKey = type == QuestTypeV2.daily ? 'daily_bonus_v2_today' : 'weekly_bonus_v2_today';
      
      // 🎉 간단한 축하 효과
      _confettiController.play();
      
      // 보상 지급
      userNotifier.addExperience(bonus.experienceBonus);
      pointNotifier.addPoints(
        bonus.pointsBonus.toInt(),
        bonus.description,
      );
      
      // 보너스 수령 표시
      await questProvider.markBonusAsClaimed(bonusKey);
      
      // 🎁 리워드 창 표시
      final bonusTitle = type == QuestTypeV2.daily 
          ? '일일 퀘스트 마스터 달성!' 
          : '주간 퀘스트 레전드 달성!';
      
      _completionAnimationKey.currentState?.showBonusAnimation(bonus, bonusTitle);
      
      // 알림 생성 (경험치와 포인트 구분)
      if (type == QuestTypeV2.daily) {
        ref.read(notificationProvider.notifier).notifyDailyQuestReward(
          '일일 퀘스트 마스터',
          xp: bonus.experienceBonus.toInt(),
          points: bonus.pointsBonus.toInt(),
        );
      } else if (type == QuestTypeV2.weekly) {
        ref.read(notificationProvider.notifier).notifyWeeklyQuestReward(
          '주간 퀘스트 레전드',
          xp: bonus.experienceBonus.toInt(),
          points: bonus.pointsBonus.toInt(),
        );
      }
      
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
      
      // 완료 처리
      _onAllClearRewardClaimed();
      
      // 화면 새로고침
      setState(() {});
      
    } catch (e) {
      // 에러 처리 - 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '보상 수령 중 오류가 발생했습니다',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: ModernColors.modernError,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 퀘스트 정렬 로직 (기존과 동일)
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

  /// 🔄 로딩 상태 (ModernColors 적용)
  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: ModernColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: ModernColors.softShadow(primaryColor: ModernColors.modernPrimary),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: ModernColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  '✨ 새로운 모험 준비 중...',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '셰르피가 특별한 퀘스트를 준비하고 있어요!',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: ModernColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                const SizedBox(
                  width: double.infinity,
                  child: LinearProgressIndicator(
                    backgroundColor: ModernColors.inactive,
                    valueColor: AlwaysStoppedAnimation<Color>(ModernColors.modernPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ 에러 상태 (ModernColors 적용)
  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: ModernColors.softShadow(primaryColor: ModernColors.modernError),
          border: Border.all(
            color: ModernColors.modernError.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ModernColors.modernError.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: ModernColors.modernError,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '퀘스트를 불러올 수 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '잠시 후 다시 시도해주세요',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: ModernColors.textSecondary,
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
                backgroundColor: ModernColors.modernPrimary,
                foregroundColor: Colors.white,
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

  /// 📭 빈 상태 컨텐츠 (ModernColors 적용)
  Widget _buildEmptyStateContent() {
    String emoji;
    String title;
    String subtitle;
    Color categoryColor = _getCategoryColor(_selectedCategory);
    
    switch (_selectedCategory) {
      case QuestTypeV2.daily:
        emoji = '📅';
        title = '오늘의 모험이 준비되고 있어요';
        subtitle = '셰르피와 함께 매일 새로운 도전을 만나보세요!';
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
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: ModernColors.softShadow(primaryColor: categoryColor),
          border: Border.all(
            color: categoryColor.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 단순한 이모지
            Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              subtitle,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: ModernColors.textSecondary,
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
                    backgroundColor: ModernColors.reward,
                    foregroundColor: Colors.white,
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