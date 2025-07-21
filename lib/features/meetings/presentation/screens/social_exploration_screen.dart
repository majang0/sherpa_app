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
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../models/available_meeting_model.dart';
import '../widgets/adventure_card_widget.dart';

/// 🎮 소셜 탐험 게시판 (Social Exploration Board)
/// RPG 게임의 '모험가 길드 게시판' 컨셉으로 설계된 모임 화면
class SocialExplorationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SocialExplorationScreen> createState() => _SocialExplorationScreenState();
}

class _SocialExplorationScreenState extends ConsumerState<SocialExplorationScreen>
    with TickerProviderStateMixin {
  late TabController _scopeController; // 전체 vs 우리학교
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _socialityPulseController;
  late AnimationController _floatController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _socialityPulseAnimation;
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
    
    _socialityPulseController = AnimationController(
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
    
    _socialityPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _socialityPulseController,
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
    _socialityPulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);

    // 🎯 앱 진입 시 셰르피 환영 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.welcome,
        emotion: SherpiEmotion.cheering,
        userContext: {
          'screen': 'social_exploration',
          'feature': 'guild_board'
        },
      );
    });
  }

  @override
  void dispose() {
    _scopeController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _socialityPulseController.dispose();
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
              // 📊 상단 헤더: 홈 화면 스타일로 새롭게 디자인
              SliverToBoxAdapter(
                child: _buildModernHeader(user, userTitle, levelProgress),
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
            physics: const NeverScrollableScrollPhysics(), // 탭뷰 자체 스크롤 비활성화
            children: [
              // 전체 공개 모임
              _buildMeetingList(isUniversityOnly: false),
              // 우리 학교 모임
              _buildMeetingList(isUniversityOnly: true),
            ],
          ),
        ),
      ),
    );
  }


  /// 🎯 RPG 스타일 헤더 (게임적 디자인)
  Widget _buildModernHeader(GlobalUser user, dynamic userTitle, UserLevelProgress levelProgress) {
    final meetingStats = ref.watch(globalMeetingStatsProvider);

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
                color: AppColors.primary.withOpacity(0.08),
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
              // 상단 소셜 액센트 - 사람들 실루엣
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
                    painter: SocialSilhouettePainter(
                      color: AppColors.primary.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
              // 메인 콘텐츠
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMainContent(user, userTitle, levelProgress, meetingStats),
                  _buildDivider(),
                  _buildSocialStatsSection(user, meetingStats),
                ],
              ),
            ],
          ),
        ), // ✅ Container의 닫는 괄호 추가
      ),
    );
  }


  Widget _buildMainContent(GlobalUser user, dynamic userTitle, UserLevelProgress levelProgress, GlobalMeetingStats meetingStats) {
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
                    // 레벨 원형 뱃지 - 소셜 테마
                    AnimatedBuilder(
                      animation: _socialityPulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _socialityPulseAnimation.value,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 사람 아이콘 배경
                                Icon(
                                  Icons.groups,
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
                          // 칭호 태그 - 소셜 테마
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userTitle.icon ?? '🤝',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  userTitle.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
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
          // 오른쪽: 소셜 가이드 카드
          _buildSocialGuideCard(user.stats.sociality),
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
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
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
                color: AppColors.primary,
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
  
  Widget _buildSocialGuideCard(double sociality) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            ref.read(sherpiProvider.notifier).showInstantMessage(
              context: SherpiContext.welcome,
              customDialogue: '모임에 참여하여 사교성을 높여보세요! 🤝',
              emotion: SherpiEmotion.encouraging,
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
                  AppColors.primary.withOpacity(0.05),
                  AppColors.primaryLight.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 소셜 아이콘
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
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '🤝',
                        style: TextStyle(
                          fontSize: 32,
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withOpacity(0.2),
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
                  _getSocialMessage(sociality),
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: AppColors.primary,
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
  
  Widget _buildSocialStatsSection(GlobalUser user, GlobalMeetingStats meetingStats) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Row(
            children: [
              Icon(
                Icons.groups,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '소셜 활동 현황',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 3가지 소셜 지표
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialStatItem(
                icon: Icons.people_rounded,
                value: '${meetingStats.totalParticipated}',
                label: '참가 모임',
                color: AppColors.primary,
                description: '누적 참여 횟수',
              ),
              _buildSocialStatItem(
                icon: Icons.handshake_rounded,
                value: '${user.stats.sociality.toStringAsFixed(1)}',
                label: '사교성',
                color: AppColors.accent,
                description: '현재 능력치',
              ),
              _buildSocialStatItem(
                icon: Icons.star_rounded,
                value: meetingStats.satisfactionGrade,
                label: '평균 만족도',
                color: AppColors.warning,
                description: '모임 평가',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSocialStatItem({
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
  
  String _getSocialMessage(double sociality) {
    if (sociality < 5) {
      return "모임에\n참여해요!";
    } else if (sociality < 10) {
      return "좋은\n시작이에요!";
    } else if (sociality < 15) {
      return "인기\n상승 중!";
    } else if (sociality < 20) {
      return "소셜\n전문가!";
    } else {
      return "인싸\n달성!";
    }
  }

  Widget _buildProfileAvatar(int level) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🤝', // 사교성 이모티콘
                style: TextStyle(
                  fontSize: 42,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -5,
          right: -5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              'Lv.$level',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceBar(UserLevelProgress progressData) {
    // 이 메서드는 더 이상 사용되지 않습니다.
    // _buildExperienceProgress로 대체되었습니다.
    return const SizedBox.shrink();
  }

  Widget _buildMeetingStats(GlobalUser user, GlobalMeetingStats meetingStats) {
    // 이 메서드는 더 이상 사용되지 않습니다.
    // _buildSocialStatsSection으로 대체되었습니다.
    return const SizedBox.shrink();
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color backgroundColor,
  }) {
    // 이 메서드는 더 이상 사용되지 않습니다.
    // _buildSocialStatItem으로 대체되었습니다.
    return const SizedBox.shrink();
  }

  /// 📝 모임 목록 빌더
  Widget _buildMeetingList({required bool isUniversityOnly}) {
    return Consumer(
      builder: (context, ref, child) {
        final meetings = ref.watch(globalAvailableMeetingsProvider);
        final filteredMeetings = isUniversityOnly 
            ? meetings.where((m) => m.scope == MeetingScope.university).toList()
            : meetings.where((m) => m.scope == MeetingScope.public).toList();

        if (filteredMeetings.isEmpty) {
          return _buildEmptyState(
            icon: '🕐',
            title: isUniversityOnly ? '우리 학교 모임이 없어요' : '모임이 없어요',
            subtitle: '새로운 모험이 곧 추가될 예정이에요!',
          );
        }

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(), // 리스트뷰 자체 스크롤 비활성화
          shrinkWrap: true, // 내용에 맞게 크기 조정
          padding: const EdgeInsets.all(20),
          itemCount: filteredMeetings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final meeting = filteredMeetings[index];
            return AdventureCardWidget(
              meeting: meeting,
              onTap: () => _handleMeetingTap(meeting),
            );
          },
        );
      },
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
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
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

  /// 🎯 모임 카드 탭 핸들러
  void _handleMeetingTap(AvailableMeeting meeting) {
    Navigator.pushNamed(
      context, 
      '/meeting_detail',
      arguments: meeting,
    );
    
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '${meeting.title} 모험에 관심이 있으시군요! 👀',
      emotion: SherpiEmotion.thinking,
    );
  }
}

/// 범위 선택 탭 Delegate
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
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
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

// 소셜 실루엣 페인터
class SocialSilhouettePainter extends CustomPainter {
  final Color color;

  SocialSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 사람들 실루엣 그리기
    // 왼쪽 사람
    path.addOval(Rect.fromCircle(center: Offset(size.width * 0.2, size.height * 0.5), radius: 15));
    path.addRect(Rect.fromLTWH(size.width * 0.15, size.height * 0.6, 30, 40));
    
    // 가운데 사람
    path.addOval(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.4), radius: 18));
    path.addRect(Rect.fromLTWH(size.width * 0.43, size.height * 0.5, 36, 50));
    
    // 오른쪽 사람
    path.addOval(Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.45), radius: 16));
    path.addRect(Rect.fromLTWH(size.width * 0.74, size.height * 0.55, 32, 45));
    
    // 배경 물결
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height * 0.85);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
