// lib/features/meetings/presentation/screens/modern_meeting_discovery_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../models/available_meeting_model.dart';
import '../../models/smart_category_model.dart';
import '../widgets/modern_meeting_card.dart';
import '../widgets/meeting_creation_dialog.dart';
import '../widgets/sherpi_recommendation_section.dart';
import '../widgets/notification_widget.dart';

/// 🎯 모던 모임 탐색 화면 - 한국형 프리미엄 모임 플랫폼
/// 문토의 세련미 + 소모임의 친근함 + 셰르파의 게이미피케이션
class ModernMeetingDiscoveryScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ModernMeetingDiscoveryScreen> createState() => 
      _ModernMeetingDiscoveryScreenState();
}

class _ModernMeetingDiscoveryScreenState 
    extends ConsumerState<ModernMeetingDiscoveryScreen> 
    with TickerProviderStateMixin {
  
  // 🎯 스마트 카테고리 시스템
  SmartCategory _selectedCategory = SmartCategory.all;
  
  // 🔍 검색 & 필터
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlineOnly = false;
  bool _showFilters = false;
  
  // 📋 상세 필터 상태
  MeetingScope? _selectedScope;
  String? _selectedLocation;
  MeetingCategory? _selectedFilterCategory;
  DateTimeRange? _selectedDateRange;
  RangeValues? _selectedPriceRange;
  final List<String> _selectedTags = [];
  
  // 📍 좋아요 관리
  final Set<String> _likedMeetings = {};
  
  // ⚡ 빠른 필터 상태 (한국형 UX)
  final Set<String> _activeQuickFilters = {};
  
  // 🎨 애니메이션
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  
  // 📜 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingHeader = false;

  @override
  void initState() {
    super.initState();
    
    // FAB 애니메이션 설정
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    );
    _fabAnimationController.forward();
    
    // 스크롤 리스너
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showFloatingHeader) {
        setState(() => _showFloatingHeader = shouldShow);
      }
    });
    
    // 🎯 셰르피 환영 인사
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.welcome,
        customDialogue: '오늘은 어떤 모임에 참여해볼까요? 제가 추천해드릴게요! 🎯',
        emotion: SherpiEmotion.happy,
      );
      
      // 사용자 능력치 기반 카테고리 추천
      final userStats = ref.read(globalUserProvider).stats;
      final recommendedCategory = SmartCategoryFilter.getRecommendedCategory({
        'stamina': userStats.stamina,
        'knowledge': userStats.knowledge,
        'technique': userStats.technique,
        'sociality': userStats.sociality,
        'willpower': userStats.willpower,
      });
      
      if (recommendedCategory != SmartCategory.all) {
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(sherpiProvider.notifier).showInstantMessage(
            context: SherpiContext.encouragement,
            customDialogue: recommendedCategory.aiRecommendationMessage,
            emotion: SherpiEmotion.guiding,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final meetingState = ref.watch(globalMeetingProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 🎨 메인 콘텐츠
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 📱 상단 헤더
              SliverToBoxAdapter(
                child: _buildHeader(user),
              ),
              
              // 🤖 셰르피 AI 추천 섹션
              SliverToBoxAdapter(
                child: SherpiRecommendationSection(
                  userStats: {
                    'stamina': user.stats.stamina,
                    'knowledge': user.stats.knowledge,
                    'technique': user.stats.technique,
                    'sociality': user.stats.sociality,
                    'willpower': user.stats.willpower,
                  },
                  onMeetingTap: (meeting) => _navigateToDetail(meeting),
                ),
              ),
              
              
              // 🏷️ 스마트 카테고리 선택
              SliverToBoxAdapter(
                child: _buildSmartCategories(),
              ),
              
              // 🔍 검색 & 필터
              SliverToBoxAdapter(
                child: _buildSearchFilter(),
              ),
              
              // ⚡ 빠른 필터 (한국형 UX)
              SliverToBoxAdapter(
                child: _buildQuickFilters(),
              ),
              
              // 📋 모임 리스트
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _buildMeetingGrid(meetingState),
              ),
              
              // 하단 여백
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          
          // 🎯 플로팅 헤더 (스크롤 시 나타남)
          if (_showFloatingHeader)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildFloatingHeader(),
            ),
          
          // ✨ 모임 만들기 FAB
          Positioned(
            bottom: 24,
            right: 16,
            child: _buildCreateMeetingFAB(),
          ),
        ],
      ),
    );
  }

  /// 📱 헤더 섹션
  Widget _buildHeader(GlobalUser user) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 타이틀 & 알림
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '모임 탐색',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.name}님을 위한 추천 모임',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // 알림 아이콘
              Stack(
                children: [
                  IconButton(
                    onPressed: () => _showNotificationPanel(),
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 📊 나의 모임 통계
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '참여 모임',
                  '${ref.watch(globalMyJoinedMeetingsProvider).length}',
                  Icons.groups_rounded,
                ),
                _buildStatItem(
                  '이번 달',
                  '${ref.watch(globalThisMonthMeetingCountProvider)}회',
                  Icons.calendar_month_rounded,
                ),
                _buildStatItem(
                  '사교성',
                  'Lv.${user.stats.sociality.toInt()}',
                  Icons.emoji_people_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: -0.2, end: 0, duration: 300.ms);
  }

  /// 📊 통계 아이템
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 🏷️ 스마트 카테고리 선택
  Widget _buildSmartCategories() {
    final meetingCounts = SmartCategoryFilter.countMeetingsByCategory(
      ref.watch(globalMeetingProvider).availableMeetings,
    );
    
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: SmartCategory.values.length,
        itemBuilder: (context, index) {
          final category = SmartCategory.values[index];
          final isSelected = _selectedCategory == category;
          final count = meetingCounts[category] ?? 0;
          
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
              HapticFeedback.lightImpact();
              
              // 카테고리 변경 시 셰르피 메시지
              if (category != SmartCategory.all) {
                ref.read(sherpiProvider.notifier).showInstantMessage(
                  context: SherpiContext.encouragement,
                  customDialogue: category.aiRecommendationMessage,
                  emotion: SherpiEmotion.guiding,
                );
              }
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? category.color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                    ? category.color 
                    : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: category.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.emoji,
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.displayName,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, 
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Colors.white.withOpacity(0.2)
                        : category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count개',
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected 
                          ? Colors.white 
                          : category.color,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(target: isSelected ? 1 : 0)
              .scale(
                duration: 200.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
              ),
          );
        },
      ),
    );
  }

  /// 🔍 검색 & 필터
  Widget _buildSearchFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              // 검색바
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: GoogleFonts.notoSans(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '모임 이름, 지역, 키워드로 검색',
                      hintStyle: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 온라인 필터
              GestureDetector(
                onTap: () {
                  setState(() => _showOnlineOnly = !_showOnlineOnly);
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _showOnlineOnly ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _showOnlineOnly 
                        ? AppColors.primary 
                        : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_showOnlineOnly 
                          ? AppColors.primary 
                          : Colors.black
                        ).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        color: _showOnlineOnly ? Colors.white : AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '온라인',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _showOnlineOnly 
                            ? Colors.white 
                            : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 필터 토글 버튼
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _showFilters = !_showFilters);
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: _showFilters || _activeFilterCount > 0 
                          ? AppColors.primary 
                          : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _showFilters || _activeFilterCount > 0
                            ? AppColors.primary 
                            : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_showFilters || _activeFilterCount > 0
                              ? AppColors.primary 
                              : Colors.black
                            ).withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _showFilters ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
                        color: _showFilters || _activeFilterCount > 0 
                          ? Colors.white 
                          : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  // 활성 필터 개수 표시
                  if (_activeFilterCount > 0 && !_showFilters)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '$_activeFilterCount',
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          // 상세 필터 옵션들 (접을 수 있음)
          if (_showFilters) ..._buildDetailedFilterOptions(),
        ],
      ),
    );
  }

  /// 🎛️ 상세 필터 옵션들
  List<Widget> _buildDetailedFilterOptions() {
    return [
      const SizedBox(height: 16),
      
      // 필터 헤더 (모임1탭 스타일 적용)
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              '상세 필터',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // 활성 필터 개수 표시
            if (_activeFilterCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_activeFilterCount개 적용',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // 필터 초기화 버튼 (새로운 디자인)
            InkWell(
              onTap: _clearAllFilters,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '초기화',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
      
      const SizedBox(height: 16),
      
      // 필터 옵션들 (모임1탭 스타일 적용)
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 범위 필터 (전체/우리학교)
                _buildScopeFilter(),
                const SizedBox(height: 20),
                
                // 카테고리 필터
                _buildCategoryFilter(),
                const SizedBox(height: 20),
                
                // 지역 필터
                _buildLocationFilter(),
                const SizedBox(height: 20),
                
                // 날짜 필터
                _buildDateFilter(),
                const SizedBox(height: 20),
                
                // 가격 필터
                _buildPriceFilter(),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  /// 📍 범위 필터
  Widget _buildScopeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 범위',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: MeetingScope.values.map((scope) {
            final isSelected = _selectedScope == scope;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedScope = isSelected ? null : scope;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          if (isSelected) const SizedBox(width: 6),
                          Text(
                            scope.displayName,
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 🏷️ 카테고리 필터
  /// 카테고리 필터 (SmartCategory 기반으로 개선)
  Widget _buildCategoryFilter() {
    // SmartCategory에서 all을 제외한 4개 카테고리 사용
    final smartCategories = SmartCategory.values.where((cat) => cat != SmartCategory.all).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 카테고리',
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: smartCategories.map((smartCategory) {
            // SmartCategory를 기준으로 매칭되는 MeetingCategory 찾기
            final isSelected = smartCategory.subCategories.contains(_selectedFilterCategory);
            
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFilterCategory = null;
                    } else {
                      // SmartCategory의 첫 번째 subCategory를 선택
                      _selectedFilterCategory = smartCategory.subCategories.first;
                    }
                  });
                  HapticFeedback.lightImpact();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                      ? LinearGradient(
                          colors: [
                            smartCategory.color.withOpacity(0.8),
                            smartCategory.color,
                          ],
                        )
                      : null,
                    color: isSelected ? null : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                        ? smartCategory.color 
                        : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected 
                      ? [
                          BoxShadow(
                            color: smartCategory.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        smartCategory.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        smartCategory.displayName,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                            ? Colors.white 
                            : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        // 선택된 카테고리에 대한 설명 추가
        if (_selectedFilterCategory != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
            child: Text(
              _getSmartCategoryForMeetingCategory(_selectedFilterCategory!)?.description ?? '',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 📍 지역 필터
  Widget _buildLocationFilter() {
    final locations = ['온라인', '서울', '경기', '인천', '대전', '광주', '대구', '제주', '부산'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지역',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: locations.map((location) {
            final isSelected = _selectedLocation == location;
            final isOnline = location == '온라인';
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedLocation = isSelected ? null : location;
                  });
                  HapticFeedback.lightImpact();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            colors: [
                              isOnline ? AppColors.secondary : AppColors.accent,
                              (isOnline ? AppColors.secondary : AppColors.accent).withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? (isOnline ? AppColors.secondary : AppColors.accent)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: (isOnline ? AppColors.secondary : AppColors.accent).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOnline) ...[
                        Icon(
                          Icons.wifi_rounded,
                          size: 14,
                          color: isSelected ? Colors.white : AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                      ] else ...[
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: isSelected ? Colors.white : AppColors.accent,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        location,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 📅 날짜 필터
  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜 범위',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: _selectedDateRange,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    primaryColor: AppColors.primary,
                    colorScheme: ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedDateRange = picked;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: _selectedDateRange != null 
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    )
                  : null,
              color: _selectedDateRange != null ? null : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedDateRange != null 
                    ? AppColors.primary 
                    : Colors.grey.shade300,
                width: _selectedDateRange != null ? 2 : 1,
              ),
              boxShadow: _selectedDateRange != null ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedDateRange != null 
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: _selectedDateRange != null 
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateRange == null 
                        ? '날짜 범위를 선택해주세요'
                        : '${_selectedDateRange!.start.month}월 ${_selectedDateRange!.start.day}일 ~ ${_selectedDateRange!.end.month}월 ${_selectedDateRange!.end.day}일',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: _selectedDateRange == null ? AppColors.textSecondary : AppColors.primary,
                      fontWeight: _selectedDateRange == null ? FontWeight.w500 : FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedDateRange != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ] else ...[
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 💰 가격 필터
  Widget _buildPriceFilter() {
    final priceOptions = [
      {'label': '무료', 'icon': Icons.star_rounded, 'range': const RangeValues(0, 0), 'color': AppColors.success},
      {'label': '1만원 이하', 'icon': Icons.payments_rounded, 'range': const RangeValues(1, 10000), 'color': AppColors.warning},
      {'label': '1-3만원', 'icon': Icons.attach_money_rounded, 'range': const RangeValues(10000, 30000), 'color': AppColors.accent},
      {'label': '3만원 이상', 'icon': Icons.diamond_rounded, 'range': const RangeValues(30000, 100000), 'color': AppColors.error},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '가격 범위',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: priceOptions.map((option) {
            final range = option['range'] as RangeValues;
            final isSelected = _selectedPriceRange != null && 
              _selectedPriceRange!.start == range.start && 
              _selectedPriceRange!.end == range.end;
            final color = option['color'] as Color;
            
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPriceRange = isSelected ? null : range;
                  });
                  HapticFeedback.lightImpact();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            colors: [
                              color,
                              color.withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        option['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        option['label'] as String,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 📋 모임 그리드
  Widget _buildMeetingGrid(GlobalMeetingState meetingState) {
    // 필터링 & 정렬
    var meetings = SmartCategoryFilter.filterMeetings(
      meetingState.availableMeetings,
      _selectedCategory,
    );
    
    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      meetings = meetings.where((meeting) =>
        meeting.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        meeting.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        meeting.tags.any((tag) => 
          tag.toLowerCase().contains(_searchQuery.toLowerCase())
        )
      ).toList();
    }
    
    // 온라인 필터
    if (_showOnlineOnly) {
      meetings = meetings.where((m) => m.location == '온라인').toList();
    }
    
    // 📋 상세 필터 적용
    
    // 범위 필터링
    if (_selectedScope != null) {
      meetings = meetings.where((meeting) => 
          meeting.scope == _selectedScope).toList();
    }
    
    // 카테고리 필터링
    if (_selectedFilterCategory != null) {
      meetings = meetings.where((meeting) => 
          meeting.category == _selectedFilterCategory).toList();
    }
    
    // 지역 필터링
    if (_selectedLocation != null) {
      meetings = meetings.where((meeting) => 
          meeting.location.contains(_selectedLocation!)).toList();
    }
    
    // 날짜 필터링
    if (_selectedDateRange != null) {
      meetings = meetings.where((meeting) {
        final meetingDate = DateTime(meeting.dateTime.year, meeting.dateTime.month, meeting.dateTime.day);
        final startDate = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final endDate = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day);
        return meetingDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
               meetingDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }
    
    // 가격 필터링
    if (_selectedPriceRange != null) {
      meetings = meetings.where((meeting) {
        final price = meeting.price ?? 0;
        return price >= _selectedPriceRange!.start && price <= _selectedPriceRange!.end;
      }).toList();
    }
    
    // ⚡ 빠른 필터 적용 (한국형 UX)
    for (final filterKey in _activeQuickFilters) {
      switch (filterKey) {
        case 'weekend':
          // 이번 주말 (토요일, 일요일)
          meetings = meetings.where((meeting) {
            final weekday = meeting.dateTime.weekday;
            return weekday == DateTime.saturday || weekday == DateTime.sunday;
          }).toList();
          break;
          
        case 'free':
          // 무료 모임
          meetings = meetings.where((meeting) => 
            meeting.type == MeetingType.free || (meeting.price ?? 0) == 0
          ).toList();
          break;
          
        case 'beginner':
          // 초보 환영 (무료 모임 또는 참여자가 절반 이하)
          meetings = meetings.where((meeting) => 
            meeting.type == MeetingType.free || 
            meeting.currentParticipants < meeting.maxParticipants / 2
          ).toList();
          break;
          
        case 'online':
          // 온라인 모임
          meetings = meetings.where((meeting) => 
            meeting.location == '온라인'
          ).toList();
          break;
          
        case 'small':
          // 소수정예 (5명 이하)
          meetings = meetings.where((meeting) => 
            meeting.maxParticipants <= 5
          ).toList();
          break;
          
        case 'casual':
          // 부담없는 (네트워킹 카테고리)
          meetings = meetings.where((meeting) => 
            meeting.category == MeetingCategory.networking
          ).toList();
          break;
          
        case 'nearby':
          // 내 주변 (온라인이 아닌 모임들)
          meetings = meetings.where((meeting) => 
            meeting.location != '온라인'
          ).toList();
          break;
      }
    }
    
    // AI 추천 정렬
    final user = ref.watch(globalUserProvider);
    meetings = SmartCategoryFilter.sortByRecommendation(
      meetings,
      _selectedCategory,
      {
        'stamina': user.stats.stamina,
        'knowledge': user.stats.knowledge,
        'technique': user.stats.technique,
        'sociality': user.stats.sociality,
        'willpower': user.stats.willpower,
      },
    );
    
    if (meetings.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/sherpi/sherpi_thinking.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedCategory.emptyStateMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // 가로형 카드에 맞는 리스트 레이아웃으로 변경
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final meeting = meetings[index];
            final isLiked = _likedMeetings.contains(meeting.id);
            
            return ModernMeetingCard(
              meeting: meeting,
              isLiked: isLiked,
              onTap: () => _navigateToDetail(meeting),
              onLike: () {
                setState(() {
                  if (isLiked) {
                    _likedMeetings.remove(meeting.id);
                  } else {
                    _likedMeetings.add(meeting.id);
                  }
                });
                HapticFeedback.lightImpact();
              },
            );
          },
          childCount: meetings.length,
        ),
      ),
    );
  }

  /// 🎯 플로팅 헤더
  Widget _buildFloatingHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: SmartCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
              HapticFeedback.lightImpact();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? category.color : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Text(
                      category.displayName,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ).animate()
      .fadeIn(duration: 200.ms)
      .slideY(begin: -1, end: 0, duration: 200.ms);
  }

  /// 📊 활성 필터 개수 계산
  int get _activeFilterCount {
    int count = 0;
    if (_selectedScope != null) count++;
    if (_selectedLocation != null) count++;
    if (_selectedFilterCategory != null) count++;
    if (_selectedDateRange != null) count++;
    if (_selectedPriceRange != null) count++;
    if (_selectedTags.isNotEmpty) count++;
    count += _activeQuickFilters.length; // 빠른 필터 개수 추가
    return count;
  }

  /// 🧹 모든 필터 초기화
  void _clearAllFilters() {
    setState(() {
      _selectedScope = null;
      _selectedLocation = null;
      _selectedFilterCategory = null;
      _selectedDateRange = null;
      _selectedPriceRange = null;
      _selectedTags.clear();
      _activeQuickFilters.clear(); // 빠른 필터 초기화 추가
    });
  }

  /// ✨ 모임 만들기 FAB
  Widget _buildCreateMeetingFAB() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showCreateMeetingDialog,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ⚡ 빠른 필터 섹션 (한국형 UX)
  Widget _buildQuickFilters() {
    final quickFilters = [
      {'key': 'weekend', 'label': '이번 주말', 'icon': Icons.weekend_rounded, 'color': Colors.orange},
      {'key': 'free', 'label': '무료', 'icon': Icons.money_off_rounded, 'color': Colors.green},
      {'key': 'beginner', 'label': '초보환영', 'icon': Icons.waving_hand_rounded, 'color': Colors.blue},
      {'key': 'online', 'label': '온라인', 'icon': Icons.videocam_rounded, 'color': Colors.purple},
      {'key': 'small', 'label': '소수정예', 'icon': Icons.group_rounded, 'color': Colors.pink},
      {'key': 'casual', 'label': '부담없는', 'icon': Icons.sentiment_satisfied_rounded, 'color': Colors.cyan},
      {'key': 'nearby', 'label': '내 주변', 'icon': Icons.near_me_rounded, 'color': Colors.indigo},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '쉽게 찾기',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quickFilters.length,
              itemBuilder: (context, index) {
                final filter = quickFilters[index];
                final filterKey = filter['key'] as String;
                final isActive = _activeQuickFilters.contains(filterKey);
                final color = filter['color'] as Color;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isActive) {
                          _activeQuickFilters.remove(filterKey);
                        } else {
                          _activeQuickFilters.add(filterKey);
                        }
                      });
                      HapticFeedback.lightImpact();
                      
                      // 셰르피 반응
                      if (!isActive) {
                        ref.read(sherpiProvider.notifier).showInstantMessage(
                          context: SherpiContext.encouragement,
                          customDialogue: '${filter['label']} 모임을 찾아드릴게요! 🎯',
                          emotion: SherpiEmotion.happy,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? color : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isActive ? color : Colors.grey.shade300,
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: isActive ? [
                          BoxShadow(
                            color: color.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filter['icon'] as IconData,
                            size: 16,
                            color: isActive ? Colors.white : color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            filter['label'] as String,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ).animate(target: isActive ? 1 : 0)
                      .scale(
                        duration: 150.ms,
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                      ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🔧 헬퍼 함수들
  
  /// MeetingCategory에 해당하는 SmartCategory 찾기
  SmartCategory? _getSmartCategoryForMeetingCategory(MeetingCategory category) {
    for (final smartCategory in SmartCategory.values) {
      if (smartCategory.subCategories.contains(category)) {
        return smartCategory;
      }
    }
    return null;
  }

  /// 🚀 네비게이션 함수들
  void _navigateToDetail(AvailableMeeting meeting) {
    Navigator.pushNamed(
      context,
      '/meeting_detail',
      arguments: meeting,
    );
  }

  void _showCreateMeetingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MeetingCreationDialog(),
    );
  }

  void _showNotificationPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // 핸들바
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '알림 센터',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 알림 위젯
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: NotificationWidget(
                  isExpanded: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



}