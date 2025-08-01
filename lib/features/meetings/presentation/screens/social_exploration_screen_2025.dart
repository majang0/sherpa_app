import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// 2025 디자인 시스템 임포트
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_2025.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_compact_2025.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_hero_2025.dart';
import '../../../../shared/widgets/components/molecules/category_selector_2025.dart';

// 기존 시스템 임포트
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../models/available_meeting_model.dart';

/// 🚀 2025 소셜 탐험 화면 - 한국형 모임 발견 플랫폼
/// 
/// 주요 개선사항:
/// - 2025 디자인 시스템 적용 (글래스모피즘, 뉴모피즘)
/// - 한국 UX 패턴 강화 (카드 중심, 소셜 피드, 개인화)
/// - 자연스럽고 부담스럽지 않은 플로우 구성
/// - 오버플로우 방지 및 반응형 최적화
class SocialExplorationScreen2025 extends ConsumerStatefulWidget {
  const SocialExplorationScreen2025({super.key});
  
  @override
  ConsumerState<SocialExplorationScreen2025> createState() => 
      _SocialExplorationScreen2025State();
}

class _SocialExplorationScreen2025State 
    extends ConsumerState<SocialExplorationScreen2025>
    with TickerProviderStateMixin {
  
  // 컨트롤러들
  late TabController _categoryController;
  late AnimationController _heroController;
  late AnimationController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _mainScrollController = ScrollController();
  
  // 상태 변수들
  final List<MeetingCategory> categories = MeetingCategory.values;
  String _searchQuery = '';
  bool _showFilters = false;
  bool _isScrolled = false;
  int _currentHeroIndex = 0;
  
  // 필터 상태
  MeetingScope? _selectedScope;
  String? _selectedLocation;
  MeetingCategory? _selectedFilterCategory;
  DateTimeRange? _selectedDateRange;
  RangeValues? _selectedPriceRange;
  final List<String> _selectedTags = [];
  
  // 성능 최적화
  Timer? _searchDebouncer;
  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();
    
    // 컨트롤러 초기화
    _categoryController = TabController(length: categories.length, vsync: this);
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 스크롤 리스너 설정
    _mainScrollController.addListener(_onScroll);
    
    // 히어로 카드 자동 전환 타이머
    _startHeroTimer();
    
    // 셰르피 환영 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.welcome,
        emotion: SherpiEmotion.cheering,
        userContext: {
          'screen': 'social_exploration_2025',
          'feature': 'meeting_discovery_enhanced'
        },
      );
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _heroController.dispose();
    _scrollController.dispose();
    _mainScrollController.dispose();
    _searchController.dispose();
    _searchDebouncer?.cancel();
    _heroTimer?.cancel();
    super.dispose();
  }
  
  void _onScroll() {
    final isScrolled = _mainScrollController.offset > 100;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
      if (isScrolled) {
        _scrollController.forward();
      } else {
        _scrollController.reverse();
      }
    }
  }
  
  void _startHeroTimer() {
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final availableMeetings = ref.read(globalAvailableMeetingsProvider);
        final heroMeetings = availableMeetings.take(3).toList();
        
        if (heroMeetings.isNotEmpty) {
          setState(() {
            _currentHeroIndex = (_currentHeroIndex + 1) % heroMeetings.length;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final availableMeetings = ref.watch(globalAvailableMeetingsProvider);
    
    return Scaffold(
      backgroundColor: AppColors2025.background,
      extendBodyBehindAppBar: true,
      
      // 🌟 2025 트렌드: 플로팅 액션 버튼 (모임 개설)
      floatingActionButton: _buildEnhancedCreateMeetingFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      body: NestedScrollView(
        controller: _mainScrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 🎯 동적 앱바 (스크롤에 따른 변화)
            _buildDynamicAppBar(user, innerBoxIsScrolled),
            
            // 🌟 히어로 섹션 (주목할 만한 모임들)
            if (availableMeetings.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildHeroSection(availableMeetings),
              ),
            
            // 🤖 AI 개인화 추천 (2025 스타일)
            SliverToBoxAdapter(
              child: _buildAIRecommendationSection2025(user),
            ),
            
            // 📱 실시간 소셜 피드 (한국 패턴 강화)
            SliverToBoxAdapter(
              child: _buildEnhancedSocialFeedSection(),
            ),
            
            // 🔍 스마트 검색 & 필터 시스템
            SliverToBoxAdapter(
              child: _buildSmartSearchSection(),
            ),
            
            // 🏷️ 2025 카테고리 선택기 (고정 헤더)
            SliverPersistentHeader(
              pinned: true,
              delegate: _Category2025SelectorDelegate(
                controller: _categoryController,
                categories: categories,
                isScrolled: _isScrolled,
              ),
            ),
          ];
        },
        
        // 📋 모임 리스트 (카테고리별)
        body: TabBarView(
          controller: _categoryController,
          physics: const NeverScrollableScrollPhysics(),
          children: categories.map((category) => 
            _buildEnhancedMeetingList(category: category)
          ).toList(),
        ),
      ),
    );
  }

  /// 🎯 동적 앱바 - 스크롤에 따른 글래스모피즘 효과
  Widget _buildDynamicAppBar(GlobalUser user, bool innerBoxIsScrolled) {
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
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors2025.glassGradient,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors2025.glassBorderSoft,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          )
        : null,
      title: AnimatedOpacity(
        opacity: _isScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          '모임 탐험',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors2025.textPrimary,
          ),
        ),
      ),
      actions: [
        if (_isScrolled) ...[
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors2025.textPrimary,
            ),
            onPressed: _handleNotificationTap,
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  /// 🌟 히어로 섹션 - 주목할 만한 모임들 (자동 전환)
  Widget _buildHeroSection(List<AvailableMeeting> meetings) {
    final heroMeetings = meetings.take(3).toList();
    if (heroMeetings.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 380,
      margin: const EdgeInsets.only(bottom: 24),
      child: PageView.builder(
        itemCount: heroMeetings.length,
        onPageChanged: (index) {
          setState(() => _currentHeroIndex = index);
        },
        itemBuilder: (context, index) {
          final meeting = heroMeetings[index];
          return MeetingCardHero2025(
            meeting: meeting,
            onTap: () => _handleMeetingTap(meeting),
            onShare: () => _handleShareMeeting(meeting),
            onBookmark: () => _handleBookmarkMeeting(meeting),
            imageAsset: _getMeetingImage(meeting, index),
          );
        },
      ),
    );
  }

  /// 🤖 AI 개인화 추천 (2025 스타일)
  Widget _buildAIRecommendationSection2025(GlobalUser user) {
    final recommendedCategory = _getRecommendedCategory(user.stats);
    final recommendedMeetings = _getRecommendedMeetings(user);
    
    if (recommendedMeetings.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors2025.getCategoryGlassColor(recommendedCategory.displayName),
                  AppColors2025.glassWhite10,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors2025.glassBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors2025.getCategoryColor2025(recommendedCategory.displayName)
                      .withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAIRecommendationHeader2025(user, recommendedCategory),
                const SizedBox(height: 20),
                _buildRecommendationReason2025(user.stats, recommendedCategory),
                const SizedBox(height: 20),
                _buildRecommendedMeetingsList2025(recommendedMeetings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🤖 AI 추천 헤더 (2025 스타일)
  Widget _buildAIRecommendationHeader2025(GlobalUser user, MeetingCategory category) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors2025.getCategoryColor2025(category.displayName),
                AppColors2025.getCategoryColor2025(category.displayName).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors2025.getCategoryColor2025(category.displayName)
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.name}님을 위한 추천',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors2025.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors2025.getCategoryColor2025(category.displayName),
                      AppColors2025.getCategoryColor2025(category.displayName).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${category.displayName} 모임',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📊 추천 이유 (2025 스타일)
  Widget _buildRecommendationReason2025(GlobalStats stats, MeetingCategory category) {
    final dominantStat = _getDominantStat(stats);
    final (reason, icon) = _getRecommendationDetails(dominantStat, category);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors2025.neuBase.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors2025.glassBorderSoft,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors2025.getCategoryColor2025(category.displayName)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors2025.getCategoryColor2025(category.displayName),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reason,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors2025.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 추천 모임 리스트 (2025 스타일)
  Widget _buildRecommendedMeetingsList2025(List<AvailableMeeting> meetings) {
    return SizedBox(
      height: 220,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 반응형 카드 크기 계산
          final cardWidth = (constraints.maxWidth * 0.85).clamp(280.0, 320.0);
          
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: meetings.length.clamp(0, 5),
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              return SizedBox(
                width: cardWidth,
                child: MeetingCard2025(
                  meeting: meeting,
                  compact: true,
                  onTap: () => _handleMeetingTap(meeting),
                  onBookmark: () => _handleBookmarkMeeting(meeting),
                  imageAsset: _getMeetingImage(meeting, index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 📱 향상된 소셜 피드 섹션
  Widget _buildEnhancedSocialFeedSection() {
    final socialActivities = _generateSocialFeedData();
    if (socialActivities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSocialFeedHeader2025(),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 반응형 소셜 카드 크기 계산
                final cardWidth = (constraints.maxWidth * 0.8).clamp(280.0, 340.0);
                
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: socialActivities.length.clamp(0, 8),
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final activity = socialActivities[index];
                    return SizedBox(
                      width: cardWidth,
                      child: _buildSocialFeedCard2025(activity),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 📱 소셜 피드 헤더 (2025 스타일)
  Widget _buildSocialFeedHeader2025() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors2025.primaryGradient2025,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors2025.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.feed_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '실시간 모임 소식',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors2025.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '지금 뜨고 있는 모임들을 확인해보세요',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: AppColors2025.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors2025.error,
                AppColors2025.error.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors2025.error.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📱 소셜 피드 카드 (2025 스타일)
  Widget _buildSocialFeedCard2025(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    final isHot = activity['isHot'] as bool? ?? false;
    final (primaryColor, icon, actionText) = _getSocialActivityDetails(type);
    
    return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors2025.glassWhite30,
                  AppColors2025.glassWhite20,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isHot 
                  ? AppColors2025.error.withOpacity(0.3)
                  : AppColors2025.glassBorder,
                width: isHot ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHot 
                    ? AppColors2025.error.withOpacity(0.1)
                    : AppColors2025.shadowMedium,
                  blurRadius: isHot ? 20 : 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSocialFeedCardImage2025(activity, primaryColor),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSocialFeedCardHeader2025(actionText, primaryColor, isHot, activity),
                      const SizedBox(height: 8),
                      _buildSocialFeedCardContent2025(activity),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  // ... 계속해서 나머지 메서드들 구현
  
  /// 🔍 스마트 검색 섹션
  Widget _buildSmartSearchSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          _buildSmartSearchBar2025(),
          if (_showFilters) ..._buildAdvancedFilters2025(),
        ],
      ),
    );
  }

  /// 🔍 스마트 검색바 (2025 스타일)
  Widget _buildSmartSearchBar2025() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors2025.glassGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors2025.glassBorder,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              _searchDebouncer?.cancel();
              _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() => _searchQuery = value);
                }
              });
            },
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: AppColors2025.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '어떤 모임을 찾고 계신가요?',
              hintStyle: GoogleFonts.notoSans(
                fontSize: 16,
                color: AppColors2025.textTertiary,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors2025.primaryGradient2025,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors2025.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                  _buildFilterToggleButton2025(),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎛️ 필터 토글 버튼 (2025 스타일)
  Widget _buildFilterToggleButton2025() {
    final activeFilterCount = _getActiveFilterCount();
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _showFilters || activeFilterCount > 0
                  ? AppColors2025.primary
                  : AppColors2025.neuBase,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors2025.glassBorderSoft,
                  width: 1,
                ),
                boxShadow: [
                  if (_showFilters || activeFilterCount > 0)
                    BoxShadow(
                      color: AppColors2025.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Icon(
                _showFilters 
                  ? Icons.filter_list_off_rounded 
                  : Icons.filter_list_rounded,
                color: _showFilters || activeFilterCount > 0
                  ? Colors.white
                  : AppColors2025.textSecondary,
                size: 20,
              ),
            ),
          ),
          if (activeFilterCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors2025.error,
                      AppColors2025.error.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    activeFilterCount.toString(),
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🎛️ 고급 필터들 (2025 스타일)
  List<Widget> _buildAdvancedFilters2025() {
    return [
      const SizedBox(height: 16),
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors2025.glassWhite20,
                  AppColors2025.glassWhite10,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors2025.glassBorderSoft,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSectionHeader2025(),
                const SizedBox(height: 16),
                _buildQuickFilters2025(),
                const SizedBox(height: 16),
                _buildDetailedFilters2025(),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  /// 🔍 향상된 모임 리스트
  Widget _buildEnhancedMeetingList({required MeetingCategory category}) {
    return Consumer(
      builder: (context, ref, child) {
        var filteredMeetings = ref.watch(globalMeetingsByCategoryProvider(category));
        filteredMeetings = _applyFilters(filteredMeetings);
        
        if (filteredMeetings.isEmpty) {
          return _buildEmptyState2025(category);
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: filteredMeetings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final meeting = filteredMeetings[index];
            
            // 카드 타입 결정 (다양성 제공)
            if (index == 0 && _searchQuery.isEmpty) {
              // 첫 번째는 히어로 카드
              return MeetingCardHero2025(
                meeting: meeting,
                onTap: () => _handleMeetingTap(meeting),
                onShare: () => _handleShareMeeting(meeting),
                onBookmark: () => _handleBookmarkMeeting(meeting),
                imageAsset: _getMeetingImage(meeting, index),
              );
            } else if (index % 3 == 0) {
              // 3개마다 일반 카드
              return MeetingCard2025(
                meeting: meeting,
                onTap: () => _handleMeetingTap(meeting),
                onBookmark: () => _handleBookmarkMeeting(meeting),
                imageAsset: _getMeetingImage(meeting, index),
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
          },
        );
      },
    );
  }

  // ============================================================================
  // 유틸리티 메서드들
  // ============================================================================
  
  String _getMeetingImage(AvailableMeeting meeting, int index) {
    final imageNumber = (index % 5) + 1;
    return 'assets/images/meeting/$imageNumber.jpg';
  }
  
  MeetingCategory _getRecommendedCategory(GlobalStats stats) {
    // 기존 로직 유지
    final dominantStat = _getDominantStat(stats);
    switch (dominantStat) {
      case 'stamina': return MeetingCategory.exercise;
      case 'knowledge': return MeetingCategory.study;
      case 'sociality': return MeetingCategory.networking;
      default: return MeetingCategory.all;
    }
  }
  
  String _getDominantStat(GlobalStats stats) {
    final statMap = {
      'stamina': stats.stamina,
      'knowledge': stats.knowledge,
      'technique': stats.technique,
      'sociality': stats.sociality,
      'willpower': stats.willpower,
    };
    
    return statMap.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  (String, IconData) _getRecommendationDetails(String dominantStat, MeetingCategory category) {
    switch (dominantStat) {
      case 'stamina':
        return category == MeetingCategory.exercise 
          ? ('높은 체력으로 운동 활동을 즐기실 수 있어요', Icons.fitness_center_rounded)
          : ('체력을 더 기를 수 있는 활동을 추천해요', Icons.fitness_center_rounded);
      case 'knowledge':
        return category == MeetingCategory.study 
          ? ('풍부한 지식으로 스터디 모임에서 활약하실 수 있어요', Icons.school_rounded)
          : ('지식을 더 늘릴 수 있는 모임을 추천해요', Icons.school_rounded);
      case 'sociality':
        return category == MeetingCategory.networking 
          ? ('뛰어난 사교성으로 네트워킹 모임에서 빛나실 수 있어요', Icons.groups_rounded)
          : ('사교성을 기를 수 있는 모임을 추천해요', Icons.groups_rounded);
      case 'technique':
        return ('기술력을 활용하거나 발전시킬 수 있는 모임이에요', Icons.build_rounded);
      case 'willpower':
        return ('의지력을 키우고 목표를 달성할 수 있는 모임이에요', Icons.psychology_rounded);
      default:
        return ('균형 잡힌 성장을 위한 모임을 추천해요', Icons.balance_rounded);
    }
  }
  
  (Color, IconData, String) _getSocialActivityDetails(String type) {
    switch (type) {
      case 'new_meeting':
        return (AppColors2025.success, Icons.add_circle_outline_rounded, '새 모임');
      case 'join_meeting':
        return (AppColors2025.primary, Icons.group_add_rounded, '참여 확정');
      case 'meeting_full':
        return (AppColors2025.warning, Icons.people_rounded, '모집 완료');
      case 'review_posted':
        return (AppColors2025.meeting2025, Icons.rate_review_rounded, '후기 작성');
      default:
        return (AppColors2025.secondary, Icons.notifications_rounded, '활동');
    }
  }
  
  // 실제 구현된 메서드들
  List<AvailableMeeting> _getRecommendedMeetings(GlobalUser user) {
    final allMeetings = ref.read(globalAvailableMeetingsProvider);
    final recommendedCategory = _getRecommendedCategory(user.stats);
    
    // 추천 카테고리의 모임들을 우선적으로 반환
    final categoryMeetings = allMeetings
        .where((meeting) => meeting.category == recommendedCategory)
        .take(3)
        .toList();
    
    // 부족하면 다른 카테고리 모임들로 채움
    if (categoryMeetings.length < 5) {
      final otherMeetings = allMeetings
          .where((meeting) => meeting.category != recommendedCategory)
          .take(5 - categoryMeetings.length)
          .toList();
      categoryMeetings.addAll(otherMeetings);
    }
    
    return categoryMeetings;
  }
  
  List<Map<String, dynamic>> _generateSocialFeedData() {
    final random = math.Random();
    final activities = <Map<String, dynamic>>[];
    
    // 샘플 소셜 활동 데이터 생성
    final activityTypes = ['new_meeting', 'join_meeting', 'meeting_full', 'review_posted'];
    final sampleTitles = [
      '주말 등산 모임',
      '독서 토론회',
      '요리 클래스',
      '영어 회화 스터디',
      '보드게임 모임',
      '사진 촬영 워크샵',
    ];
    
    for (int i = 0; i < 8; i++) {
      activities.add({
        'type': activityTypes[random.nextInt(activityTypes.length)],
        'meetingTitle': sampleTitles[random.nextInt(sampleTitles.length)],
        'timeAgo': '${random.nextInt(60) + 1}분 전',
        'isHot': random.nextBool() && i < 3, // 처음 3개만 HOT 가능
        'categoryColor': AppColors2025.primary,
      });
    }
    
    return activities;
  }
  
  List<AvailableMeeting> _applyFilters(List<AvailableMeeting> meetings) {
    var filteredMeetings = List<AvailableMeeting>.from(meetings);
    
    // 날짜순 정렬 (가까운 날짜부터)
    filteredMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredMeetings = filteredMeetings.where((meeting) {
        return meeting.title.toLowerCase().contains(query) ||
               meeting.description.toLowerCase().contains(query) ||
               meeting.location.toLowerCase().contains(query) ||
               meeting.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }
    
    // 범위 필터링
    if (_selectedScope != null) {
      filteredMeetings = filteredMeetings
          .where((meeting) => meeting.scope == _selectedScope)
          .toList();
    }
    
    // 카테고리 필터링
    if (_selectedFilterCategory != null) {
      filteredMeetings = filteredMeetings
          .where((meeting) => meeting.category == _selectedFilterCategory)
          .toList();
    }
    
    // 지역 필터링
    if (_selectedLocation != null) {
      filteredMeetings = filteredMeetings
          .where((meeting) => meeting.location.contains(_selectedLocation!))
          .toList();
    }
    
    // 날짜 필터링
    if (_selectedDateRange != null) {
      filteredMeetings = filteredMeetings.where((meeting) {
        final meetingDate = DateTime(
          meeting.dateTime.year,
          meeting.dateTime.month,
          meeting.dateTime.day
        );
        final startDate = DateTime(
          _selectedDateRange!.start.year,
          _selectedDateRange!.start.month,
          _selectedDateRange!.start.day
        );
        final endDate = DateTime(
          _selectedDateRange!.end.year,
          _selectedDateRange!.end.month,
          _selectedDateRange!.end.day
        );
        return !meetingDate.isBefore(startDate) && !meetingDate.isAfter(endDate);
      }).toList();
    }
    
    // 가격 필터링
    if (_selectedPriceRange != null) {
      filteredMeetings = filteredMeetings.where((meeting) {
        final price = meeting.participationFee;
        return price >= _selectedPriceRange!.start && 
               price <= _selectedPriceRange!.end;
      }).toList();
    }
    
    return filteredMeetings;
  }
  
  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedScope != null) count++;
    if (_selectedLocation != null) count++;
    if (_selectedFilterCategory != null) count++;
    if (_selectedDateRange != null) count++;
    if (_selectedPriceRange != null) count++;
    if (_selectedTags.isNotEmpty) count++;
    return count;
  }
  
  // 실제 구현된 위젯들
  Widget _buildSocialFeedCardImage2025(Map<String, dynamic> activity, Color primaryColor) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.3),
            primaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, -0.5),
                  radius: 1.2,
                  colors: [
                    Colors.white24,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.groups_rounded,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSocialFeedCardHeader2025(String actionText, Color primaryColor, bool isHot, Map<String, dynamic> activity) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            actionText,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ),
        const Spacer(),
        if (isHot) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors2025.error,
                  AppColors2025.error.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'HOT',
              style: GoogleFonts.notoSans(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          activity['timeAgo'] as String,
          style: GoogleFonts.notoSans(
            fontSize: 11,
            color: AppColors2025.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSocialFeedCardContent2025(Map<String, dynamic> activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activity['meetingTitle'] as String,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors2025.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 14,
              color: AppColors2025.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '${math.Random().nextInt(8) + 2}명 참여',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors2025.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildFilterSectionHeader2025() {
    return Row(
      children: [
        Icon(
          Icons.tune_rounded,
          color: AppColors2025.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '상세 필터',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors2025.textPrimary,
          ),
        ),
        const Spacer(),
        if (_getActiveFilterCount() > 0)
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              '전체 초기화',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors2025.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildQuickFilters2025() {
    final quickFilters = [
      {'label': '오늘', 'value': 'today'},
      {'label': '무료', 'value': 'free'},
      {'label': '소그룹', 'value': 'small'},
      {'label': '온라인', 'value': 'online'},
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickFilters.map((filter) {
        final isSelected = _selectedTags.contains(filter['value']);
        return GestureDetector(
          onTap: () => _toggleQuickFilter(filter['value'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors2025.primary.withOpacity(0.15)
                  : AppColors2025.neuBase.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors2025.primary
                    : AppColors2025.borderLight,
                width: 1,
              ),
            ),
            child: Text(
              filter['label'] as String,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors2025.primary
                    : AppColors2025.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildDetailedFilters2025() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // 카테고리 필터
        _buildCategoryFilter2025(),
        const SizedBox(height: 16),
        // 지역 필터
        _buildLocationFilter2025(),
        const SizedBox(height: 16),
        // 날짜 범위 필터
        _buildDateRangeFilter2025(),
      ],
    );
  }
  
  Widget _buildEmptyState2025(MeetingCategory category) {
    final hasActiveFilters = _getActiveFilterCount() > 0;
    final hasSearchQuery = _searchQuery.isNotEmpty;
    
    String icon, title, subtitle;
    
    if (hasSearchQuery && hasActiveFilters) {
      icon = '🔍';
      title = '검색 조건에 맞는 모임이 없어요';
      subtitle = '검색어나 필터를 조정해보세요';
    } else if (hasSearchQuery) {
      icon = '🔍';
      title = '검색 결과가 없어요';
      subtitle = '다른 키워드로 검색해보세요';
    } else if (hasActiveFilters) {
      icon = '🎛️';
      title = '필터 조건에 맞는 모임이 없어요';
      subtitle = '필터를 조정하거나 초기화해보세요';
    } else {
      icon = category.emoji;
      title = '${category.displayName} 모임이 없어요';
      subtitle = '새로운 모임이 곧 추가될 예정이에요!';
    }
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors2025.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors2025.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilters || hasSearchQuery) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _showFilters = false;
                  });
                  _clearAllFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors2025.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '검색 및 필터 초기화',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildEnhancedCreateMeetingFAB() {
    return FloatingActionButton.extended(
      onPressed: _handleCreateMeeting,
      backgroundColor: AppColors2025.primary,
      label: Text('모임 만들기'),
      icon: Icon(Icons.add),
    );
  }
  
  // 추가 필터 위젯들
  Widget _buildCategoryFilter2025() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors2025.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MeetingCategory.values.map((category) {
            final isSelected = _selectedFilterCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterCategory = isSelected ? null : category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors2025.getCategoryColor2025(category.displayName).withOpacity(0.15)
                      : AppColors2025.neuBase.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors2025.getCategoryColor2025(category.displayName)
                        : AppColors2025.borderLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category.displayName,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors2025.getCategoryColor2025(category.displayName)
                            : AppColors2025.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildLocationFilter2025() {
    final locations = ['서울', '경기', '부산', '대구', '인천', '광주', '대전', '울산'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지역',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors2025.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: locations.map((location) {
            final isSelected = _selectedLocation == location;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLocation = isSelected ? null : location;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors2025.primary.withOpacity(0.15)
                      : AppColors2025.neuBase.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors2025.primary
                        : AppColors2025.borderLight,
                    width: 1,
                  ),
                ),
                child: Text(
                  location,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors2025.primary
                        : AppColors2025.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildDateRangeFilter2025() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜 범위',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors2025.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showDateRangePicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors2025.neuBase.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedDateRange != null
                    ? AppColors2025.primary
                    : AppColors2025.borderLight,
                width: 1,
              ),
            ),
            child: Text(
              _selectedDateRange != null
                  ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                  : '날짜 범위를 선택하세요',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: _selectedDateRange != null
                    ? AppColors2025.primary
                    : AppColors2025.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // 유틸리티 메서드들
  void _toggleQuickFilter(String value) {
    setState(() {
      if (_selectedTags.contains(value)) {
        _selectedTags.remove(value);
      } else {
        _selectedTags.add(value);
      }
    });
  }
  
  void _clearAllFilters() {
    setState(() {
      _selectedScope = null;
      _selectedLocation = null;
      _selectedFilterCategory = null;
      _selectedDateRange = null;
      _selectedPriceRange = null;
      _selectedTags.clear();
    });
  }
  
  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors2025.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors2025.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
  
  // 이벤트 핸들러들
  void _handleMeetingTap(AvailableMeeting meeting) {
    Navigator.pushNamed(context, '/meeting_detail', arguments: meeting);
  }
  
  void _handleBookmarkMeeting(AvailableMeeting meeting) {
    // TODO: 북마크 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meeting.title}이(가) 북마크에 추가되었습니다'),
        backgroundColor: AppColors2025.success,
      ),
    );
  }
  
  void _handleShareMeeting(AvailableMeeting meeting) {
    // TODO: 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meeting.title} 모임이 공유되었습니다'),
        backgroundColor: AppColors2025.primary,
      ),
    );
  }
  
  void _handleQuickJoinMeeting(AvailableMeeting meeting) {
    // TODO: 빠른 참여 기능 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('빠른 참여'),
        content: Text('${meeting.title}에 바로 참여하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${meeting.title}에 참여 신청이 완료되었습니다'),
                  backgroundColor: AppColors2025.success,
                ),
              );
            },
            child: Text('참여'),
          ),
        ],
      ),
    );
  }
  
  void _handleCreateMeeting() {
    Navigator.pushNamed(context, '/meeting_create');
  }
  
  void _handleNotificationTap() {
    // TODO: 알림 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('알림 기능을 준비 중입니다')),
    );
  }
  
  void _handleSocialFeedTap(Map<String, dynamic> activity) {
    // TODO: 소셜 피드 상세 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${activity['meetingTitle']} 활동을 확인합니다'),
      ),
    );
  }
}

/// 2025 카테고리 선택기 델리게이트
class _Category2025SelectorDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;
  final List<MeetingCategory> categories;
  final bool isScrolled;
  
  _Category2025SelectorDelegate({
    required this.controller,
    required this.categories,
    required this.isScrolled,
  });
  
  @override
  double get minExtent => 70;
  
  @override
  double get maxExtent => 70;
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors2025.glassGradient,
            border: Border(
              bottom: BorderSide(
                color: AppColors2025.glassBorderSoft,
                width: 1,
              ),
            ),
          ),
          child: CategorySelector2025(
            categories: categories,
            selectedCategory: categories[controller.index],
            onCategorySelected: (category) {
              final index = categories.indexOf(category);
              controller.animateTo(index);
            },
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ),
    );
  }
}