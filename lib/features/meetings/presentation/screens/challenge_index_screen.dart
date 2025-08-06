import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/models/user_level_progress.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../shared/providers/global_challenge_provider.dart';
import '../../models/available_challenge_model.dart';

/// 🏆 챌린지 탐험 게시판 (Challenge Exploration Board)
/// 모임 탭과 통일된 디자인 언어로 설계된 챌린지 화면
class ChallengeIndexScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChallengeIndexScreen> createState() => _ChallengeIndexScreenState();
}

class _ChallengeIndexScreenState extends ConsumerState<ChallengeIndexScreen>
    with TickerProviderStateMixin {
  late TabController _scopeController; // 전체 vs 우리학교
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _willpowerPulseController;
  late AnimationController _floatController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _willpowerPulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _scopeController = TabController(length: 2, vsync: this);
    
    // 애니메이션 컨트롤러 초기화
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _willpowerPulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // 애니메이션 설정
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));
    
    _willpowerPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _willpowerPulseController,
      curve: Curves.easeInOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    // 애니메이션 시작
    _fadeController.forward();
    _slideController.forward();
    _willpowerPulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);

    // 🎯 챌린지 탭 진입 시 셰르피 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.welcome,
        emotion: SherpiEmotion.cheering,
        userContext: {
          'screen': 'challenge_exploration',
          'feature': 'challenge_board'
        },
      );
    });
  }

  @override
  void dispose() {
    _scopeController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _willpowerPulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final userTitle = ref.watch(globalUserTitleProvider);
    final levelProgress = ref.watch(userLevelProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // 📊 상단 헤더: 챌린지 특화 디자인
              SliverToBoxAdapter(
                child: _buildChallengeHeader(user, userTitle, levelProgress),
              ),

              // 🔍 범위 선택 탭: [전체 🌍] vs [우리 학교 🏫]
              SliverPersistentHeader(
                pinned: true,
                delegate: _ScopeSelectorDelegate(
                  controller: _scopeController,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _scopeController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 전체 공개 챌린지
              _buildChallengeList(isUniversityOnly: false),
              // 우리 학교 챌린지
              _buildChallengeList(isUniversityOnly: true),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏆 챌린지 특화 헤더 디자인
  Widget _buildChallengeHeader(GlobalUser user, dynamic userTitle, UserLevelProgress levelProgress) {
    final challengeStats = ref.watch(challengeStatsProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withOpacity(0.08), // 챌린지 - 주황색 액센트
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.textLight.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 상단 챌린지 액센트 - 트로피 패턴
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: CustomPaint(
                    painter: ChallengeTrophyPainter(
                      color: AppColors.warning.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
              // 메인 콘텐츠
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMainContent(user, userTitle, levelProgress, challengeStats),
                  _buildDivider(),
                  _buildChallengeStatsSection(user, challengeStats),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(GlobalUser user, dynamic userTitle, UserLevelProgress levelProgress, ChallengeStats challengeStats) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 레벨 & 진행 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 레벨 & 칭호 섹션
                Row(
                  children: [
                    // 레벨 원형 뱃지 - 챌린지 테마
                    AnimatedBuilder(
                      animation: _willpowerPulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _willpowerPulseAnimation.value,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.warning,
                                  AppColors.warningLight,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.warning.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 트로피 아이콘 배경
                                Icon(
                                  Icons.emoji_events,
                                  color: Colors.white.withOpacity(0.2),
                                  size: 28,
                                ),
                                // 레벨 숫자
                                Text(
                                  '${user.level}',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 칭호 태그 - 챌린지 테마
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.warning.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userTitle.icon ?? '🏆',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  userTitle.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
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
                const SizedBox(height: 20),
                // 경험치 진행바 섹션
                _buildExperienceProgress(levelProgress),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // 오른쪽: 챌린지 가이드 카드
          _buildChallengeGuideCard(user.stats.willpower),
        ],
      ),
    );
  }
  
  Widget _buildExperienceProgress(UserLevelProgress levelProgress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '다음 레벨까지',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              '${levelProgress.currentLevelExp} / ${levelProgress.requiredExpForNextLevel} XP',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 진행바
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: levelProgress.progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warningLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(levelProgress.progress * 100).toInt()}% 완료',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.warning,
              ),
            ),
            if (levelProgress.progress > 0.8)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warningLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🎯 레벨업 임박!',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildChallengeGuideCard(double willpower) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            ref.read(sherpiProvider.notifier).showInstantMessage(
              context: SherpiContext.welcome,
              customDialogue: '챌린지에 도전하여 의지력을 높여보세요! 🔥',
              emotion: SherpiEmotion.cheering,
            );
          },
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.warning.withOpacity(0.05),
                  AppColors.warningLight.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 챌린지 아이콘
                Transform.translate(
                  offset: Offset(0, math.sin(_floatAnimation.value * math.pi * 2) * 2),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '🔥',
                        style: TextStyle(
                          fontSize: 32,
                          shadows: [
                            Shadow(
                              color: AppColors.warning.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getChallengeMessage(willpower),
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: AppColors.warning,
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
  
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.divider.withOpacity(0),
            AppColors.divider,
            AppColors.divider.withOpacity(0),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChallengeStatsSection(GlobalUser user, ChallengeStats challengeStats) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                '챌린지 활동 현황',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 3가지 챌린지 지표
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildChallengeStatItem(
                icon: Icons.rocket_launch_rounded,
                value: '${challengeStats.totalParticipated}',
                label: '참가 챌린지',
                color: AppColors.warning,
                description: '누적 참여 횟수',
              ),
              _buildChallengeStatItem(
                icon: Icons.local_fire_department_rounded,
                value: '${user.stats.willpower.toStringAsFixed(1)}',
                label: '의지력',
                color: AppColors.error,
                description: '현재 능력치',
              ),
              _buildChallengeStatItem(
                icon: Icons.workspace_premium_rounded,
                value: '${challengeStats.completionRate}%',
                label: '완주율',
                color: AppColors.success,
                description: '챌린지 성공률',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengeStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required String description,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
  
  String _getChallengeMessage(double willpower) {
    if (willpower < 5) {
      return "도전\n시작하기!";
    } else if (willpower < 10) {
      return "의지력\n상승 중!";
    } else if (willpower < 15) {
      return "강한\n의지!";
    } else if (willpower < 20) {
      return "챌린지\n마스터!";
    } else {
      return "불굴의\n의지!";
    }
  }

  /// 📝 챌린지 목록 빌더
  Widget _buildChallengeList({required bool isUniversityOnly}) {
    return Consumer(
      builder: (context, ref, child) {
        final challenges = ref.watch(globalAvailableChallengesProvider);
        final filteredChallenges = isUniversityOnly 
            ? challenges.where((c) => c.scope == 'university').toList()
            : challenges.where((c) => c.scope != 'university').toList();

        if (filteredChallenges.isEmpty) {
          return _buildEmptyState(
            icon: '🎯',
            title: isUniversityOnly ? '우리 학교 챌린지가 없어요' : '챌린지가 없어요',
            subtitle: '새로운 도전이 곧 추가될 예정이에요!',
          );
        }

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          itemCount: filteredChallenges.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final challenge = filteredChallenges[index];
            return _buildChallengeCard(challenge, ref);
          },
        );
      },
    );
  }

  /// 🏆 챌린지 카드 위젯
  Widget _buildChallengeCard(AvailableChallenge challenge, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _handleChallengeTap(challenge, ref),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 카테고리 색상 액센트
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: challenge.category.color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
            ),
            // 카드 내용
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 정보 (카테고리, 난이도, 상태)
                  Row(
                    children: [
                      // 카테고리 태그
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: challenge.category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: challenge.category.color.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(challenge.category.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              challenge.category.displayName,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: challenge.category.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 난이도 표시
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.dividerLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(challenge.difficulty.emoji, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              challenge.difficulty.displayName,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // 상태 뱃지
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: challenge.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: challenge.statusColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          challenge.status,
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: challenge.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 제목
                  Text(
                    challenge.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 설명
                  Text(
                    challenge.description,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // 하단 정보
                  Row(
                    children: [
                      // 기간
                      _buildInfoChip(
                        icon: Icons.schedule,
                        text: challenge.durationText,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      // 참가자
                      _buildInfoChip(
                        icon: Icons.people,
                        text: '${challenge.currentParticipants}/${challenge.maxParticipants}명',
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      // 보상 포인트
                      _buildInfoChip(
                        icon: Icons.star,
                        text: '${challenge.completionReward.toInt()}P',
                        color: AppColors.warning,
                      ),
                      const Spacer(),
                      // 참여 버튼
                      if (challenge.canJoin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.warning,
                                AppColors.warningLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.warning.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '도전하기',
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.dividerLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '마감',
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // 참여율 진행바
                  if (challenge.participationRate > 0) ...[
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.dividerLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: challenge.participationRate,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  challenge.category.color,
                                  challenge.category.color.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// ❌ 빈 상태 UI
  Widget _buildEmptyState({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning,
                    AppColors.warningLight,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 챌린지 카드 탭 핸들러
  void _handleChallengeTap(AvailableChallenge challenge, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Text(challenge.category.emoji),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                challenge.title,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.description,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailItem('기간', challenge.formattedDateRange),
            _buildDetailItem('난이도', '${challenge.difficulty.emoji} ${challenge.difficulty.displayName}'),
            _buildDetailItem('참가 수수료', '${challenge.participationFee.toInt()}P'),
            _buildDetailItem('완주 보상', '${challenge.completionReward.toInt()}P'),
            _buildDetailItem('경험치 보상', '+${challenge.experienceReward.toInt()} XP'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.notoSans(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning, AppColors.warningLight],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: challenge.canJoin ? () async {
                  Navigator.pop(context);
                  final success = await ref.read(globalChallengeProvider.notifier).joinChallenge(challenge);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 ${challenge.title} 챌린지에 참여했습니다!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    '도전하기',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '${challenge.title} 챌린지에 관심이 있으시군요! 💪',
      emotion: SherpiEmotion.thinking,
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 범위 선택 탭 Delegate (모임 탭과 동일)
class _ScopeSelectorDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;

  _ScopeSelectorDelegate({required this.controller});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: controller,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning,
                  AppColors.warningLight,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public, size: 18),
                    const SizedBox(width: 6),
                    const Text('전체'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 18),
                    const SizedBox(width: 6),
                    const Text('우리 학교'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 72.0;

  @override
  double get minExtent => 72.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

// 챌린지 트로피 패인터
class ChallengeTrophyPainter extends CustomPainter {
  final Color color;

  ChallengeTrophyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 트로피 그리기
    // 왼쪽 트로피
    _drawTrophy(path, size.width * 0.2, size.height * 0.5, 20);
    
    // 가운데 큰 트로피
    _drawTrophy(path, size.width * 0.5, size.height * 0.4, 25);
    
    // 오른쪽 트로피
    _drawTrophy(path, size.width * 0.8, size.height * 0.45, 22);
    
    // 배경 물결
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.85, size.width * 0.5, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.95, size.width, size.height * 0.85);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawTrophy(Path path, double centerX, double centerY, double size) {
    // 트로피 컵 부분
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, centerY), width: size, height: size * 0.8),
      const Radius.circular(4),
    ));
    
    // 트로피 베이스
    path.addRect(Rect.fromCenter(
      center: Offset(centerX, centerY + size * 0.6),
      width: size * 0.6,
      height: size * 0.3,
    ));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ✅ 챌린지 통계 Provider
final challengeStatsProvider = Provider<ChallengeStats>((ref) {
  // 임시 샘플 데이터
  return ChallengeStats(
    totalParticipated: 8,
    totalCompleted: 6,
    completionRate: 75,
    averageDuration: 21,
  );
});

// ✅ 챌린지 통계 모델
class ChallengeStats {
  final int totalParticipated;
  final int totalCompleted;
  final int completionRate;
  final double averageDuration;

  ChallengeStats({
    required this.totalParticipated,
    required this.totalCompleted,
    required this.completionRate,
    required this.averageDuration,
  });

  String get satisfactionGrade {
    if (completionRate >= 90) return 'S';
    if (completionRate >= 80) return 'A';
    if (completionRate >= 70) return 'B';
    if (completionRate >= 60) return 'C';
    return 'D';
  }
}