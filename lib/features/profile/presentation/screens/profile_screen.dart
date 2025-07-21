import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// ✅ 글로벌 데이터 시스템 Import
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/models/user_level_progress.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';

// ✅ 챌린지 시스템 Import 추가
import '../../../../shared/providers/global_challenge_provider.dart';
import '../../../meetings/models/available_challenge_model.dart';

// 새로운 위젯들 Import
import '../widgets/liquid_glass_profile_header.dart';
import '../widgets/growth_summary_card.dart';
import '../widgets/representative_dashboard.dart';
import '../widgets/challenge_list_item.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 초기화
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // 애니메이션 시작
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    
    // 셰르피 환영 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.welcome,
        emotion: SherpiEmotion.cheering,
        duration: Duration(seconds: 3),
      );
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final pointData = ref.watch(globalPointProvider);
    final userTitle = ref.watch(globalUserTitleProvider);
    final userProgress = ref.watch(userLevelProgressProvider);
    
    // ✅ 실제 챌린지 데이터 가져오기
    final activeChallenges = ref.watch(globalMyJoinedChallengesProvider);
    final popularChallenges = ref.watch(globalPopularChallengesProvider);

    return Scaffold(
      backgroundColor: Color(0xFFFAFBFF), // Very Light Blue Background
      appBar: SherpaCleanAppBar(title: '프로필'),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // 1. 프로필 헤더 (SliverToBoxAdapter)
              SliverToBoxAdapter(
                child: LiquidGlassProfileHeader(),
              ),
              
              // 2. 성장 요약 카드 (SliverToBoxAdapter)
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 600),
                  child: GrowthSummaryCard(),
                ),
              ),
              
              // 3. 대표 기록 대시보드 (SliverToBoxAdapter)
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 800),
                  child: RepresentativeDashboard(),
                ),
              ),
              
              // 4. 참여 중인 챌린지 헤더 (SliverPersistentHeader)
              SliverPersistentHeader(
                pinned: false,
                delegate: _ChallengeSectionHeaderDelegate(
                  participatingCount: _getParticipatingChallengesCount(activeChallenges, popularChallenges),
                ),
              ),
              
              // 5. 참여 중인 챌린지 리스트 (SliverList)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ✅ 실제 챌린지 데이터 기반의 동적 챌린지
                    ..._buildRealChallenges(user, activeChallenges, popularChallenges),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ 참여 중인 챌린지 수 계산
  int _getParticipatingChallengesCount(List<AvailableChallenge> activeChallenges, List<AvailableChallenge> popularChallenges) {
    // 실제로는 사용자가 참여한 챌린지를 추적해야 하지만, 현재는 활성 챌린지 중 일부를 사용
    return (activeChallenges.length + popularChallenges.take(2).length).clamp(0, 5);
  }
}

// 챌린지 섹션 헤더 델리게이트 (개선된 버전)
class _ChallengeSectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int participatingCount;

  _ChallengeSectionHeaderDelegate({required this.participatingCount});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Color(0xFFFAFBFF),
      ),
      child: Row(
        children: [
          Text(
            '참여 중인 챌린지',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A8A),
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${participatingCount}개 진행 중',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

// ✅ 실제 챌린지 데이터에 기반한 동적 챌린지 리스트 생성
List<Widget> _buildRealChallenges(GlobalUser user, List<AvailableChallenge> activeChallenges, List<AvailableChallenge> popularChallenges) {
  final challenges = <Widget>[];
  
  // 1. 활성 챌린지 중에서 사용자가 "참여했을 법한" 챌린지들
  if (activeChallenges.isNotEmpty) {
    final userActiveChallenge = activeChallenges.first;
    
    // 사용자 데이터 기반으로 진행률 계산
    double progress = 0.0;
    int daysLeft = userActiveChallenge.durationDays;
    
    if (userActiveChallenge.categoryType == ChallengeCategory.fitness) {
      // 운동 챌린지는 오늘 걸음수 기반
      progress = (user.dailyRecords.todaySteps / 6000).clamp(0.0, 1.0);
      daysLeft = (userActiveChallenge.durationDays * (1.0 - progress)).round().clamp(1, userActiveChallenge.durationDays);
    } else if (userActiveChallenge.categoryType == ChallengeCategory.study) {
      // 공부 챌린지는 독서 기록 기반
      progress = (user.dailyRecords.readingLogs.length / 15).clamp(0.0, 1.0);
      daysLeft = (userActiveChallenge.durationDays * (1.0 - progress)).round().clamp(1, userActiveChallenge.durationDays);
    } else if (userActiveChallenge.categoryType == ChallengeCategory.habit) {
      // 습관 챌린지는 연속 접속일 기반
      progress = (user.dailyRecords.consecutiveDays / 21).clamp(0.0, 1.0);
      daysLeft = (21 - user.dailyRecords.consecutiveDays).clamp(1, 21);
    }

    challenges.add(ChallengeListItem(
      title: userActiveChallenge.title,
      category: userActiveChallenge.categoryType.displayName,
      daysLeft: daysLeft,
      progress: progress,
      color: userActiveChallenge.categoryType.color,
    ));
  }
  
  // 2. 인기 챌린지 중에서 2개 추가 (다른 카테고리로)
  final usedCategories = activeChallenges.map((c) => c.categoryType).toSet();
  final otherChallenges = popularChallenges
      .where((c) => !usedCategories.contains(c.categoryType))
      .take(2)
      .toList();
  
  for (final challenge in otherChallenges) {
    double progress = 0.0;
    int daysLeft = challenge.durationDays;
    
    // 각 챌린지별로 사용자 데이터에 맞는 진행률 시뮬레이션
    switch (challenge.categoryType) {
      case ChallengeCategory.fitness:
        progress = (user.dailyRecords.exerciseLogs.length / 10).clamp(0.0, 1.0);
        break;
      case ChallengeCategory.study:
        progress = (user.stats.knowledge / 50).clamp(0.0, 1.0);
        break;
      case ChallengeCategory.habit:
        progress = (user.dailyRecords.consecutiveDays / 30).clamp(0.0, 1.0);
        break;
      case ChallengeCategory.mindfulness:
        progress = (user.stats.willpower / 40).clamp(0.0, 1.0);
        break;
      default:
        progress = 0.3; // 기본 진행률
    }
    
    daysLeft = (challenge.durationDays * (1.0 - progress)).round().clamp(1, challenge.durationDays);

    challenges.add(ChallengeListItem(
      title: challenge.title,
      category: challenge.categoryType.displayName,
      daysLeft: daysLeft,
      progress: progress,
      color: challenge.categoryType.color,
    ));
  }
  
  // 3. 만약 챌린지가 부족하면 사용자 데이터 기반 기본 챌린지 추가
  if (challenges.length < 3) {
    // 걸음수 기반 챌린지
    challenges.add(ChallengeListItem(
      title: '매일 6000보 걷기',
      category: '건강',
      daysLeft: 7 - (user.dailyRecords.consecutiveDays % 7),
      progress: (user.dailyRecords.todaySteps / 6000).clamp(0.0, 1.0),
      color: Color(0xFF10B981),
    ));
  }
  
  if (challenges.length < 3 && user.dailyRecords.readingLogs.isNotEmpty) {
    // 독서 기반 챌린지  
    challenges.add(ChallengeListItem(
      title: '주 3회 독서 기록',
      category: '독서',
      daysLeft: 12,
      progress: (user.dailyRecords.readingLogs.length / 10).clamp(0.0, 1.0),
      color: Color(0xFF8B5CF6),
    ));
  }
  
  // 4. 하단 여백 추가
  challenges.add(SizedBox(height: 40));
  
  return challenges;
}
