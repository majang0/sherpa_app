import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

// Shared Providers
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../quests/providers/quest_provider_v2.dart';

// Shared Widgets
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';

// Local Widgets
import '../widgets/enhanced_consecutive_days_reward_widget.dart';
import '../widgets/integrated_quest_system_widget.dart';
import '../widgets/smart_meeting_recommendation_widget.dart';
import '../widgets/enhanced_social_feed_widget.dart';
import '../widgets/personalized_growth_dashboard_widget.dart';
import '../widgets/university_guild_widget.dart';
import '../widgets/growth_insights_widget.dart';
import '../widgets/sherpi_ai_test_card.dart';
// AI 테스트 위젯 import 제거됨 - 프로덕션 최적화

// Models
import '../../../../shared/models/global_user_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isDailyRewardAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // 간단한 애니메이션 설정
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _initialize();
  }

  Future<void> _initialize() async {
    // 애니메이션 시작
    _fadeController.forward();
    _scaleController.forward();
    
    // 일일 보상 확인
    await _checkDailyReward();
    
    // 퀘스트 데이터 초기화 및 동기화 (V2)
    // 퀘스트 Provider 초기화 트리거
    ref.read(questProviderV2);
    
    // 짧은 디레이 후 퀘스트 동기화 실행
    await Future.delayed(const Duration(milliseconds: 300));
    
    // V2에서는 자동 동기화되므로 수동 동기화 불필요
    // ref.read(questProviderV2.notifier).onGlobalActivityUpdate('sync', {});
    
    // 퀘스트 데이터 강제 리프레시
    ref.read(questProviderV2.notifier).refresh();
    
    // 로딩 완료
    if (mounted) {
      setState(() => _isLoading = false);
    }
    
    // 환영 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeSherpi();
    });
  }


  Future<void> _checkDailyReward() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final todayRewardClaimed = prefs.getBool('today_reward_claimed_$todayString') ?? false;

      if (!todayRewardClaimed && mounted) {
        setState(() {
          _isDailyRewardAvailable = true;
        });
      }
    } catch (e) {
      // 일일 보상 확인 중 오류 발생
    }
  }

  void _showWelcomeSherpi() {
    final hour = DateTime.now().hour;
    SherpiContext context;

    if (hour < 12) {
      context = SherpiContext.dailyGreeting;
    } else if (hour < 18) {
      context = SherpiContext.welcome;
    } else {
      context = SherpiContext.dailyGreeting;
    }

    ref.showSherpi(context, emotion: SherpiEmotion.happy);
  }


  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final totalPoints = ref.watch(globalTotalPointsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SherpaCleanAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildMainContent(user, totalPoints),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 셰르파 로고 이미지
          Image.asset(
            'assets/images/sherpa_logo.png',
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              // 이미지 로드 실패 시 대체 아이콘
              return Icon(
                Icons.terrain_outlined,
                size: 64,
                color: AppColors.primary.withOpacity(0.3),
              );
            },
          ),
          const SizedBox(height: 20),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 12),
          Text(
            '로딩 중...',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(GlobalUser user, int totalPoints) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(globalUserProvider.notifier).refresh();
          ref.showSherpi(SherpiContext.encouragement, emotion: SherpiEmotion.cheering);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 일일 보상과 레벨 카드를 AnimatedSwitcher로 감싸서 부드러운 전환
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    ),
                  );
                },
                child: _isDailyRewardAvailable
                    ? Padding(
                        key: const ValueKey('daily_reward'),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          children: [
                            EnhancedConsecutiveDaysRewardWidget(
                              onClaimReward: () {
                                if (mounted) {
                                  setState(() => _isDailyRewardAvailable = false);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey('empty_space'),
                        height: 0,
                      ),
              ),
            ),

            // 사용자 레벨 카드 (항상 표시)


            // 개인 성장 영역 (RPG 스타일)
            SliverToBoxAdapter(
              child: _buildPersonalGrowthSection(user),
            ),

            // 구분선
            SliverToBoxAdapter(
              child: Container(
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            
            // 소셜 영역 (클린 스타일)
            SliverToBoxAdapter(
              child: _buildSocialSection(),
            ),
            
            // 하단 여백
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }




  Widget _buildPersonalGrowthSection(GlobalUser user) {
    return Container(

      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            // 🤖 셰르피 AI 테스트 카드 (개발/테스트용)
            const SherpiAiTestCard(),
            const SizedBox(height: 20),

            // 통합 성장 대시보드
            PersonalizedGrowthDashboardWidget(),
            const SizedBox(height: 20),
            
            // 성장 인사이트 위젯 (새로운 시각적 위젯)
            GrowthInsightsWidget(),
            const SizedBox(height: 20),
            
            // AI 테스트 위젯 제거됨 - 프로덕션 모드 최적화
            
            // 퀘스트 시스템 (V2)
            IntegratedQuestSystemWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // 모임 추천
          SmartMeetingRecommendationWidget(),
          const SizedBox(height: 16),

          // 소셜 피드
          EnhancedSocialFeedWidget(),
          const SizedBox(height: 16),
          
          // 대학 길드
          UniversityGuildWidget(),
        ],
      ),
    );
  }





}
