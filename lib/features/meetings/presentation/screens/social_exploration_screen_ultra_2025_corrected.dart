import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// 🚀 Enhanced 2025 디자인 시스템 임포트 (API 수정됨)
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../shared/widgets/components/atoms/sherpa_search_bar_2025.dart';
import '../../../../shared/widgets/components/molecules/sherpa_quick_filter_2025.dart';
import '../../../../shared/widgets/components/molecules/sherpa_smart_filter_2025.dart';
import '../../../../shared/widgets/components/atoms/sherpa_container_2025.dart';
import '../../../../shared/widgets/components/atoms/sherpa_grid_2025.dart';
import '../../../../shared/widgets/components/molecules/sherpa_meeting_card_2025.dart';
import '../../../../shared/widgets/components/molecules/sherpa_ai_recommendation_2025.dart';
import '../../../../shared/widgets/components/molecules/sherpa_create_meeting_fab_2025.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_hero_2025.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_compact_2025.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_2025.dart';
import '../../../../shared/widgets/components/molecules/participant_avatars_2025.dart';
import '../../../../shared/widgets/components/molecules/category_selector_2025.dart';

// 기존 시스템 임포트
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../models/available_meeting_model.dart';

/// 🌟 Ultra 2025 소셜 탐험 화면 - 완전한 한국형 모임 발견 플랫폼
/// 
/// 🎯 핵심 개선사항 (API 호환성 수정):
/// - 완전한 2025 디자인 시스템 통합 (검증된 API 사용)
/// - 한국 UX 패턴 강화 (자연스럽고 부담 없는 플로우)
/// - 고급 AI 개인화 시스템
/// - 오버플로우 완전 방지 및 반응형 최적화
/// - 마이크로 인터랙션 및 햅틱 피드백
/// - 소셜 증명 및 커뮤니티 요소 강화
class SocialExplorationScreenUltra2025Corrected extends ConsumerStatefulWidget {
  const SocialExplorationScreenUltra2025Corrected({super.key});
  
  @override
  ConsumerState<SocialExplorationScreenUltra2025Corrected> createState() => 
      _SocialExplorationScreenUltra2025CorrectedState();
}

class _SocialExplorationScreenUltra2025CorrectedState 
    extends ConsumerState<SocialExplorationScreenUltra2025Corrected>
    with TickerProviderStateMixin {
  
  // ==================== 컨트롤러들 ====================
  late TabController _categoryController;
  late AnimationController _heroController;
  late AnimationController _scrollController;
  late AnimationController _microInteractionController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _mainScrollController = ScrollController();
  
  // ==================== 상태 변수들 ====================
  final List<MeetingCategory> categories = MeetingCategory.values;
  String _searchQuery = '';
  bool _showFilters = false;
  bool _isScrolled = false;
  int _currentHeroIndex = 0;
  bool _isLoading = false;
  bool _showOnlineOnly = false;
  
  // 필터 상태 (향상된 필터링 시스템)
  MeetingScope? _selectedScope;
  String? _selectedLocation;
  MeetingCategory? _selectedFilterCategory;
  DateTimeRange? _selectedDateRange;
  RangeValues? _selectedPriceRange;
  final List<String> _selectedTags = [];
  final Set<String> _quickFilters = {}; // 빠른 필터
  
  // 성능 최적화
  Timer? _searchDebouncer;
  Timer? _heroTimer;
  Timer? _socialFeedTimer;

  @override
  void initState() {
    super.initState();
    
    // 컨트롤러 초기화
    _categoryController = TabController(length: categories.length, vsync: this);
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _microInteractionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // 스크롤 리스너 설정
    _mainScrollController.addListener(_onScroll);
    
    // 히어로 카드 자동 전환 타이머 (더 부드러운 전환)
    _startEnhancedHeroTimer();
    
    // 소셜 피드 실시간 업데이트
    _startSocialFeedTimer();
    
    // 초기 애니메이션
    _heroController.forward();
    
    // 향상된 셰르피 환영 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.welcome,
        emotion: SherpiEmotion.cheering,
        userContext: {
          'screen': 'social_exploration_ultra_2025_corrected',
          'feature': 'meeting_discovery_premium',
          'personalization_level': 'ultra'
        },
      );
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _heroController.dispose();
    _scrollController.dispose();
    _microInteractionController.dispose();
    _mainScrollController.dispose();
    _searchController.dispose();
    _searchDebouncer?.cancel();
    _heroTimer?.cancel();
    _socialFeedTimer?.cancel();
    super.dispose();
  }

  // ==================== 이벤트 핸들러들 ====================
  
  void _onScroll() {
    final scrolled = _mainScrollController.offset > 100;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
      _scrollController.animateTo(scrolled ? 1.0 : 0.0);
    }
  }

  void _startEnhancedHeroTimer() {
    _heroTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          final meetings = ref.read(globalAvailableMeetingsProvider);
          if (meetings.isNotEmpty) {
            _currentHeroIndex = (_currentHeroIndex + 1) % math.min(meetings.length, 3);
          }
        });
      }
    });
  }

  void _startSocialFeedTimer() {
    _socialFeedTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        // 실시간 소셜 피드 업데이트 로직
        setState(() {});
      }
    });
  }

  // ==================== 메인 빌드 메서드 ====================

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final availableMeetings = ref.watch(globalAvailableMeetingsProvider);
    
    return Scaffold(
      backgroundColor: AppColors2025.background,
      extendBodyBehindAppBar: true,
      
      // 🌟 Ultra 2025 플로팅 액션 버튼
      floatingActionButton: _buildUltraCreateMeetingFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      body: NestedScrollView(
        controller: _mainScrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 🎯 Ultra 2025 앱바
            _buildUltraAppBar2025(user, innerBoxIsScrolled),
            
            // 🌟 향상된 히어로 섹션
            if (availableMeetings.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildUltraHeroSection2025(availableMeetings),
              ),
            
            // 🤖 Ultra AI 개인화 추천
            SliverToBoxAdapter(
              child: _buildUltraAIRecommendation2025(user),
            ),
            
            // 👥 소셜 증명 섹션 (한국 패턴)
            SliverToBoxAdapter(
              child: _buildSocialProofSection2025(),
            ),
            
            // 🔍 Ultra 스마트 검색 시스템
            SliverToBoxAdapter(
              child: _buildUltraSmartSearchSection2025(),
            ),
            
            // 🏷️ Ultra 카테고리 선택기
            SliverPersistentHeader(
              pinned: true,
              delegate: _UltraCategorySelectorDelegate2025(
                controller: _categoryController,
                categories: categories,
                isScrolled: _isScrolled,
              ),
            ),
          ];
        },
        
        // 📋 Ultra 모임 리스트
        body: TabBarView(
          controller: _categoryController,
          physics: const BouncingScrollPhysics(),
          children: categories.map((category) => 
            _buildUltraMeetingList2025(category: category)
          ).toList(),
        ),
      ),
    );
  }

  // ==================== UI 컴포넌트들 ====================

  /// 🎯 Ultra 2025 앱바
  Widget _buildUltraAppBar2025(GlobalUser user, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      elevation: 0,
      backgroundColor: _isScrolled 
        ? AppColors2025.glassWhite30
        : Colors.transparent,
      flexibleSpace: _isScrolled 
        ? ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors2025.glassGradient,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors2025.glassBorder,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          )
        : null,
      title: AnimatedBuilder(
        animation: _scrollController,
        builder: (context, child) {
          return Opacity(
            opacity: _scrollController.value,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors2025.primaryGradient2025,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '모임 탐험',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors2025.textPrimary,
                      ),
                    ),
                    Text(
                      '${user.name}님을 위한 추천',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors2025.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors2025.glassWhite20,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors2025.glassBorder,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors2025.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
            // 알림 페이지로 이동
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 🌟 Ultra 히어로 섹션
  Widget _buildUltraHeroSection2025(List<AvailableMeeting> meetings) {
    final heroMeetings = meetings.take(3).toList();
    
    return SherpaContainer2025(
      variant: SherpaContainerVariant2025.glass,
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: SizedBox(
        height: 380,
        child: PageView.builder(
          itemCount: heroMeetings.length,
          onPageChanged: (index) {
            setState(() => _currentHeroIndex = index);
          },
          itemBuilder: (context, index) {
            final meeting = heroMeetings[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: MeetingCardHero2025(
                meeting: meeting,
                onTap: () => _handleMeetingTap(meeting),
                onShare: () => _handleShareMeeting(meeting),
                onBookmark: () => _handleBookmarkMeeting(meeting),
                imageAsset: _getMeetingImage(meeting, index),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🤖 Ultra AI 개인화 추천 (수정된 API)
  Widget _buildUltraAIRecommendation2025(GlobalUser user) {
    final recommendedMeetings = ref.watch(globalRecommendedMeetingsProvider);
    
    // 추천 항목 생성
    final recommendations = recommendedMeetings.map((meeting) => 
      SherpaAIRecommendationItem2025(
        id: meeting.id,
        title: meeting.title,
        subtitle: meeting.category.displayName,
        description: meeting.description,
        imageUrl: _getMeetingImage(meeting, 0),
        confidenceScore: _calculateConfidenceScore(meeting, user),
        category: meeting.category.name,
        metadata: {
          'location': meeting.location,
          'date': meeting.formattedDate,
          'participants': '${meeting.currentParticipants}/${meeting.maxParticipants}',
          'price': meeting.type == MeetingType.free ? '무료' : '${meeting.price?.toInt()}원',
        },
      )
    ).toList();

    return SherpaContainer2025(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      variant: SherpaContainerVariant2025.neu,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 추천 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors2025.primaryGradient2025,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.name}님을 위한 AI 추천',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors2025.textPrimary,
                      ),
                    ),
                    Text(
                      '당신의 취향에 맞는 모임을 찾았어요',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: AppColors2025.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: AppColors2025.textSecondary,
                  ),
                  onPressed: () => _refreshRecommendations(),
                ),
              ],
            ),
          ),
          
          // 추천 모임 리스트
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recommendations.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                final meeting = recommendedMeetings[index];
                return _buildAIRecommendationCard(recommendation, meeting);
              },
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// AI 추천 카드
  Widget _buildAIRecommendationCard(SherpaAIRecommendationItem2025 recommendation, AvailableMeeting meeting) {
    return GestureDetector(
      onTap: () => _handleMeetingTap(meeting),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          gradient: AppColors2025.glassGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors2025.glassBorder,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 섹션
              Container(
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(recommendation.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      meeting.category.color,
                      meeting.category.color.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // 신뢰도 배지
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.yellow[300],
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(recommendation.confidenceScore * 100).toInt()}%',
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 정보 섹션
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors2025.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation.subtitle,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: AppColors2025.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors2025.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              recommendation.metadata['location'] ?? '',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: AppColors2025.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: AppColors2025.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendation.metadata['date'] ?? '',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: AppColors2025.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 👥 소셜 증명 섹션
  Widget _buildSocialProofSection2025() {
    return SherpaContainer2025(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      variant: SherpaContainerVariant2025.glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors2025.primaryGradient2025,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '지금 인기있는 모임',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors2025.textPrimary,
                      ),
                    ),
                    Text(
                      '실시간으로 많은 사람들이 참여하고 있어요',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: AppColors2025.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 인기 모임 리스트
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final popularMeetings = ref.watch(globalPopularMeetingsProvider);
                if (index >= popularMeetings.length) return const SizedBox();
                
                final meeting = popularMeetings[index];
                return _buildPopularMeetingCard2025(meeting, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 인기 모임 카드
  Widget _buildPopularMeetingCard2025(AvailableMeeting meeting, int index) {
    return GestureDetector(
      onTap: () => _handleMeetingTap(meeting),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          gradient: AppColors2025.glassGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors2025.glassBorder,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 배경 이미지
              Positioned.fill(
                child: Image.asset(
                  _getMeetingImage(meeting, index),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            meeting.category.color,
                            meeting.category.color.withOpacity(0.7),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // 그라데이션 오버레이
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 인기 뱃지
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'HOT',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 정보
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.title,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meeting.currentParticipants}/${meeting.maxParticipants}',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
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
  }

  /// 🔍 Ultra 스마트 검색 시스템 (수정된 API)
  Widget _buildUltraSmartSearchSection2025() {
    return SherpaContainer2025(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      variant: SherpaContainerVariant2025.glass,
      child: Column(
        children: [
          // 스마트 검색바 (수정된 API 사용)
          SherpaSearchBar2025(
            hint: '어떤 모임을 찾고 계신가요?',
            controller: _searchController,
            onChanged: (value) {
              _searchDebouncer?.cancel();
              _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() => _searchQuery = value);
                }
              });
            },
            onFilterTap: () {
              setState(() => _showFilters = !_showFilters);
            },
            showFilter: true,
            variant: SherpaSearchVariant2025.glass,
            enableMicroInteractions: true,
          ),
          
          const SizedBox(height: 16),
          
          // 빠른 필터 (수정된 API 사용)
          SherpaQuickFilter2025(
            items: [
              SherpaQuickFilterItem2025(key: 'free', label: '무료', icon: Icons.money_off_rounded),
              SherpaQuickFilterItem2025(key: 'today', label: '오늘', icon: Icons.today_rounded),
              SherpaQuickFilterItem2025(key: 'weekend', label: '주말', icon: Icons.weekend_rounded),
              SherpaQuickFilterItem2025(key: 'online', label: '온라인', icon: Icons.videocam_rounded),
              SherpaQuickFilterItem2025(key: 'beginner', label: '초보환영', icon: Icons.star_rounded),
              SherpaQuickFilterItem2025(key: 'small', label: '소규모', icon: Icons.group_rounded),
            ],
            activeFilters: _quickFilters,
            onFiltersChanged: (filters) {
              setState(() {
                _quickFilters.clear();
                _quickFilters.addAll(filters);
              });
            },
            variant: SherpaQuickFilterVariant2025.glass,
            enableMicroInteractions: true,
          ),
          
          // 고급 필터 (펼쳐질 때)
          if (_showFilters) ...[
            const SizedBox(height: 16),
            SherpaSmartFilter2025(
              searchQuery: _searchQuery,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
              },
              showOnlineOnly: _showOnlineOnly,
              onOnlineToggle: (value) {
                setState(() => _showOnlineOnly = value);
              },
              showDetailedFilters: _showFilters,
              onDetailedFiltersToggle: (value) {
                setState(() => _showFilters = value);
              },
              activeFilterCount: _getActiveFilterCount(),
              onClearFilters: () {
                setState(() {
                  _quickFilters.clear();
                  _searchQuery = '';
                  _showOnlineOnly = false;
                  _selectedScope = null;
                  _selectedLocation = null;
                  _selectedFilterCategory = null;
                  _selectedDateRange = null;
                  _selectedPriceRange = null;
                  _selectedTags.clear();
                });
                _searchController.clear();
              },
              variant: SherpaSmartFilterVariant2025.glass,
              enableAI: true,
            ),
          ],
        ],
      ),
    );
  }

  /// 📋 Ultra 모임 리스트 (수정된 API)
  Widget _buildUltraMeetingList2025({required MeetingCategory category}) {
    return Consumer(
      builder: (context, ref, child) {
        var filteredMeetings = ref.watch(globalMeetingsByCategoryProvider(category));
        filteredMeetings = _applyAdvancedFilters(filteredMeetings);
        
        if (filteredMeetings.isEmpty) {
          return _buildUltraEmptyState2025(category);
        }
        
        return SherpaGrid2025(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          variant: SherpaGridVariant2025.standard,
          children: List.generate(filteredMeetings.length, (index) {
            final meeting = filteredMeetings[index];
            return _buildUltraMeetingCard2025(meeting, index);
          }),
        );
      },
    );
  }

  /// Ultra 모임 카드
  Widget _buildUltraMeetingCard2025(AvailableMeeting meeting, int index) {
    // 카드 타입 다양성 제공
    if (index == 0 && _searchQuery.isEmpty) {
      // 첫 번째는 히어로 스타일
      return MeetingCardHero2025(
        meeting: meeting,
        onTap: () => _handleMeetingTap(meeting),
        onShare: () => _handleShareMeeting(meeting),
        onBookmark: () => _handleBookmarkMeeting(meeting),
        imageAsset: _getMeetingImage(meeting, index),
      );
    } else if (index % 4 == 0) {
      // 4개마다 풀 카드
      return SherpaMeetingCard2025(
        meeting: meeting,
        onTap: () => _handleMeetingTap(meeting),
        variant: SherpaMeetingCardVariant2025.glass,
        size: SherpaMeetingCardSize.large,
        enableMicroInteractions: true,
        enableHapticFeedback: true,
      );
    } else {
      // 나머지는 컴팩트 카드
      return MeetingCardCompact2025(
        meeting: meeting,
        onTap: () => _handleMeetingTap(meeting),
        onQuickJoin: () => _handleQuickJoinMeeting(meeting),
        imageAsset: _getMeetingImage(meeting, index),
      );
    }
  }

  /// 🌟 Ultra 플로팅 액션 버튼 (fallback 구현)
  Widget _buildUltraCreateMeetingFAB() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppColors2025.primaryGradient2025,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors2025.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {
            Navigator.pushNamed(context, '/meeting_create');
          },
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildUltraEmptyState2025(MeetingCategory category) {
    return SherpaContainer2025(
      margin: const EdgeInsets.all(20),
      variant: SherpaContainerVariant2025.neu,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors2025.primaryGradient2025,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${category.displayName} 모임이 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors2025.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새로운 모임을 만들어보세요!',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors2025.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/meeting_create');
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('모임 만들기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors2025.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 유틸리티 메서드들 ====================
  
  String _getMeetingImage(AvailableMeeting meeting, int index) {
    final imageNumber = (index % 5) + 1;
    return 'assets/images/meeting/$imageNumber.jpg';
  }
  
  double _calculateConfidenceScore(AvailableMeeting meeting, GlobalUser user) {
    double score = 0.5; // 기본 점수
    
    // 사용자 능력치 기반 점수 계산
    final stats = user.stats;
    switch (meeting.category) {
      case MeetingCategory.exercise:
        score += (stats.stamina / 10) * 0.3;
        break;
      case MeetingCategory.study:
        score += (stats.knowledge / 10) * 0.3;
        break;
      case MeetingCategory.networking:
        score += (stats.sociality / 10) * 0.3;
        break;
      default:
        score += 0.1;
    }
    
    // 참여율 기반 점수
    score += meeting.participationRate * 0.2;
    
    return math.min(score, 1.0);
  }
  
  int _getActiveFilterCount() {
    int count = 0;
    if (_quickFilters.isNotEmpty) count += _quickFilters.length;
    if (_showOnlineOnly) count++;
    if (_selectedScope != null) count++;
    if (_selectedLocation != null) count++;
    if (_selectedFilterCategory != null) count++;
    if (_selectedDateRange != null) count++;
    if (_selectedPriceRange != null) count++;
    if (_selectedTags.isNotEmpty) count += _selectedTags.length;
    return count;
  }
  
  List<AvailableMeeting> _applyAdvancedFilters(List<AvailableMeeting> meetings) {
    var filtered = meetings;
    
    // 검색 쿼리 필터
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((meeting) =>
        meeting.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        meeting.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        meeting.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // 빠른 필터 적용
    for (final filter in _quickFilters) {
      switch (filter) {
        case 'free':
          filtered = filtered.where((m) => m.type == MeetingType.free).toList();
          break;
        case 'today':
          final today = DateTime.now();
          filtered = filtered.where((m) => 
            m.dateTime.day == today.day &&
            m.dateTime.month == today.month &&
            m.dateTime.year == today.year
          ).toList();
          break;
        case 'weekend':
          filtered = filtered.where((m) => 
            m.dateTime.weekday == DateTime.saturday ||
            m.dateTime.weekday == DateTime.sunday
          ).toList();
          break;
        case 'online':
          filtered = filtered.where((m) => 
            m.location.toLowerCase().contains('온라인') ||
            m.location.toLowerCase().contains('zoom')
          ).toList();
          break;
        case 'beginner':
          filtered = filtered.where((m) => 
            m.tags.any((tag) => tag.contains('초보') || tag.contains('환영'))
          ).toList();
          break;
        case 'small':
          filtered = filtered.where((m) => m.maxParticipants <= 10).toList();
          break;
      }
    }
    
    // 온라인 전용 필터
    if (_showOnlineOnly) {
      filtered = filtered.where((m) => 
        m.location.toLowerCase().contains('온라인') ||
        m.location.toLowerCase().contains('zoom')
      ).toList();
    }
    
    return filtered;
  }

  // ==================== 이벤트 핸들러들 ====================
  
  void _handleMeetingTap(AvailableMeeting meeting) {
    Navigator.pushNamed(
      context,
      '/meeting_detail',
      arguments: meeting,
    );
  }
  
  void _handleShareMeeting(AvailableMeeting meeting) {
    // 모임 공유 로직
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '모임 정보를 공유했어요! 🎉',
      emotion: SherpiEmotion.cheering,
    );
  }
  
  void _handleBookmarkMeeting(AvailableMeeting meeting) {
    // 북마크 로직
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.levelUp,
      customDialogue: '관심 모임에 추가했어요! ⭐',
      emotion: SherpiEmotion.cheering,
    );
  }
  
  void _handleQuickJoinMeeting(AvailableMeeting meeting) async {
    final success = await ref.read(globalMeetingProvider.notifier).joinMeeting(meeting);
    if (success) {
      _microInteractionController.forward().then((_) {
        _microInteractionController.reverse();
      });
    }
  }
  
  void _refreshRecommendations() {
    setState(() => _isLoading = true);
    
    // 추천 새로고침 로직
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }
}

// ==================== 커스텀 Delegate ====================

class _UltraCategorySelectorDelegate2025 extends SliverPersistentHeaderDelegate {
  final TabController controller;
  final List<MeetingCategory> categories;
  final bool isScrolled;

  _UltraCategorySelectorDelegate2025({
    required this.controller,
    required this.categories,
    required this.isScrolled,
  });

  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: isScrolled ? AppColors2025.glassGradient : null,
        border: Border(
          bottom: BorderSide(
            color: AppColors2025.glassBorder,
            width: 0.5,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: CategorySelector2025(
            categories: categories,
            selectedCategory: categories.first,
            onCategorySelected: (category) {
              // Handle category selection
            },
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

// ==================== 모델 클래스들 ====================

/// AI 추천 아이템 모델 (수정된 API)
class SherpaAIRecommendationItem2025 {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final double confidenceScore;
  final String category;
  final Map<String, dynamic> metadata;

  const SherpaAIRecommendationItem2025({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.confidenceScore,
    required this.category,
    required this.metadata,
  });
}

