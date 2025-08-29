// lib/features/meetings/presentation/screens/new_meeting_discovery_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// 🎨 디자인 시스템
import '../../../../core/theme/modern_colors.dart';

// 🖼️ 이미지 캐싱
import '../../../../shared/widgets/cached_meeting_image.dart';
import '../../../../shared/utils/meeting_image_cache_manager.dart';

// 📦 모델 및 프로바이더
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../models/available_meeting_model.dart';
import '../../utils/meeting_image_utils.dart';
import '../../../../shared/utils/meeting_image_manager.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_2025.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_list_2025.dart';
import '../widgets/meeting_creation_dialog.dart';

/// 🌟 새로운 모임 탐색 화면
/// 사용자가 모임에 최대한 집중할 수 있도록 자연스럽고 부담 없는 흐름으로 구성
class NewMeetingDiscoveryScreen extends ConsumerStatefulWidget {
  const NewMeetingDiscoveryScreen({super.key});
  
  @override
  ConsumerState<NewMeetingDiscoveryScreen> createState() => 
      _NewMeetingDiscoveryScreenState();
}

class _NewMeetingDiscoveryScreenState 
    extends ConsumerState<NewMeetingDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  
  // ==================== 컨트롤러들 ====================
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _mainScrollController = ScrollController();
  late AnimationController _animationController;
  
  // ==================== 상태 변수들 ====================
  String _searchQuery = '';
  MeetingCategory _selectedCategory = MeetingCategory.all;
  
  // 필터 상태
  final Set<String> _activeFilters = {};
  bool _showOnlineOnly = false;
  bool _showFilters = false;
  
  // 빠른 필터 상태 (한국형 UX)
  final Set<String> _activeQuickFilters = {};
  
  // 상세 필터 상태
  String _selectedScope = 'all'; // 전체공개, 우리학교
  String? _selectedLocation; // 온라인, 서울, 경기 등
  DateTimeRange? _selectedDateRange;
  String? _selectedPriceRange; // 무료, 1만원이하, 1~4만원, 4만원이상
  
  // 북마크 상태
  final Set<String> _bookmarkedMeetings = {};
  
  // 성능 최적화
  Timer? _searchDebouncer;
  final Map<String, String?> _imagePathCache = {}; // 이미지 경로 캐시
  
  // 필터링된 모임 리스트
  List<AvailableMeeting> _filteredMeetings = [];
  
  // 이미지 매니저 제거됨

  // 활성 필터 개수 계산
  int get _activeFilterCount {
    int count = 0;
    if (_activeFilters.isNotEmpty) count += _activeFilters.length;
    if (_activeQuickFilters.isNotEmpty) count += _activeQuickFilters.length;
    if (_selectedCategory != MeetingCategory.all) count += 1;
    if (_showOnlineOnly) count += 1;
    if (_selectedScope != 'all') count += 1;
    if (_selectedLocation != null) count += 1;
    if (_selectedDateRange != null) count += 1;
    if (_selectedPriceRange != null) count += 1;
    return count;
  }

  @override
  void initState() {
    super.initState();
    
    // 이미지 매니저 제거됨
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 초기 애니메이션
    _animationController.forward();
    
    // 검색 컨트롤러 리스너 추가
    _searchController.addListener(_onSearchChanged);
    
    // 초기 필터링 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilteredMeetings();
      _preloadPopularMeetingImages();
    });
  }
  
  void _onSearchChanged() {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim();
          _updateFilteredMeetings();
        });
      }
    });
  }
  
  void _updateFilteredMeetings() {
    final allMeetings = ref.read(globalAvailableMeetingsProvider);
    setState(() {
      _filteredMeetings = _applyFilters(allMeetings);
    });
  }
  
  /// 인기있는 모임의 이미지를 미리 로드하여 캐싱
  Future<void> _preloadPopularMeetingImages() async {
    try {
      final allMeetings = ref.read(globalAvailableMeetingsProvider);
      final popularMeetings = allMeetings
          .where((meeting) => meeting.participationRate >= 0.5)
          .take(10) // 상위 10개만 프리로드
          .toList();
      
      final imagePaths = <String>[];
      final imageManager = MeetingImageManager();
      
      for (final meeting in popularMeetings) {
        final imagePath = imageManager.getImageForMeeting(meeting);
        if (imagePath != null) {
          imagePaths.add(imagePath);
        }
      }
      
      if (imagePaths.isNotEmpty) {
        final cacheManager = MeetingImageCacheManager();
        await cacheManager.preloadImages(imagePaths);
        debugPrint('Preloaded ${imagePaths.length} popular meeting images');
      }
    } catch (e) {
      debugPrint('Failed to preload images: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _mainScrollController.dispose();
    _searchDebouncer?.cancel();
    super.dispose();
  }

  // ==================== 메인 빌드 메서드 ====================
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: ModernColors.background,
      floatingActionButton: _buildCreateMeetingFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 인기 모임
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _buildPopularMeetingsSection(),
              ),
            ),
            
            // 나에게 딱 맞는 모임 섹션
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _buildPerfectMatchMeetingsSection(user),
              ),
            ),
            
            // 카테고리별 모임 탐색
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _buildCategoryAndSearchSection(),
              ),
            ),
            
            // 전체 모임 섹션
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _buildMustSeeMeetingsSection(),
              ),
            ),
            
            // 하단 여백
            SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
  
  // ==================== UI 컴포넌트들 ====================
  
  /// 섹션 헤더 공통 위젯 - 모던하고 깔끔한 디자인
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
    bool showViewAll = true,
    String? subtitle,
    IconData? leadingIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 제목 영역
          Expanded(
            child: Row(
              children: [
                // 선택적 리딩 아이콘 또는 장식 요소
                if (leadingIcon != null) ...[
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ModernColors.primary,
                          ModernColors.primary.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                
                // 제목과 부제목
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.notoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ModernColors.textPrimary,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                      ).animate()
                        .fadeIn(duration: const Duration(milliseconds: 300))
                        .slideX(begin: -0.05, end: 0, duration: const Duration(milliseconds: 300)),
                      
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                            letterSpacing: -0.1,
                          ),
                        ).animate()
                          .fadeIn(
                            duration: const Duration(milliseconds: 300),
                            delay: const Duration(milliseconds: 100),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 전체보기 버튼 - 명확한 색상 대비와 그림자
          if (showViewAll)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onViewAll();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: ModernColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primary.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '전체보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: const Duration(milliseconds: 400))
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
            ),
        ],
      ),
    );
  }
  
  /// 검색 결과 위젯
  Widget _buildSearchResults() {
    if (_filteredMeetings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: ModernColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              '검색 결과가 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '다른 키워드로 검색해보세요',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색 결과 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Text(
                  '검색 결과',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ModernColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteredMeetings.length}개',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 검색 결과 리스트
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: math.min(_filteredMeetings.length, 5), // 최대 5개만 표시
              itemBuilder: (context, index) {
                final meeting = _filteredMeetings[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MeetingCardList2025(
                    meeting: meeting,
                    onTap: () => _handleMeetingTap(meeting),
                    onBookmark: () => _handleBookmarkTap(meeting),
                    isBookmarked: _isBookmarked(meeting),
                    showDivider: index < math.min(_filteredMeetings.length, 5) - 1,
                  ),
                );
              },
            ),
          ),
          
          // 더 보기 버튼
          if (_filteredMeetings.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/meeting_list_all',
                      arguments: {
                        'sectionTitle': '검색 결과: "$_searchQuery"',
                        'category': null,
                        'searchQuery': _searchQuery,
                        'filteredMeetings': _filteredMeetings,
                      },
                    );
                  },
                  child: Text(
                    '${_filteredMeetings.length - 5}개 더 보기',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: ModernColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// 활성화된 필터 표시
  Widget _buildActiveFilters() {
    final activeFilterLabels = <String>[];
    
    if (_selectedCategory != MeetingCategory.all) {
      activeFilterLabels.add(_selectedCategory.displayName);
    }
    
    for (final filter in _activeFilters) {
      switch (filter) {
        case 'recent':
          activeFilterLabels.add('최신순');
          break;
        case 'popular':
          activeFilterLabels.add('인기순');
          break;
        case 'premium':
          activeFilterLabels.add('프리미엄');
          break;
        case 'free_only':
          activeFilterLabels.add('무료만');
          break;
        case 'online':
          activeFilterLabels.add('온라인');
          break;
      }
    }
    
    if (activeFilterLabels.isEmpty) return const SizedBox.shrink();
    
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '적용된 필터',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: activeFilterLabels.map((label) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ModernColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        if (label == _selectedCategory.displayName) {
                          setState(() {
                            _selectedCategory = MeetingCategory.all;
                            _updateFilteredMeetings();
                          });
                        } else {
                          // 필터 제거 로직
                          final filterKey = _getFilterKeyFromLabel(label);
                          if (filterKey != null) {
                            setState(() {
                              _activeFilters.remove(filterKey);
                              _updateFilteredMeetings();
                            });
                          }
                        }
                      },
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: ModernColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  String? _getFilterKeyFromLabel(String label) {
    switch (label) {
      case '최신순': return 'recent';
      case '인기순': return 'popular';
      case '프리미엄': return 'premium';
      case '무료만': return 'free_only';
      case '온라인': return 'online';
      default: return null;
    }
  }
  
  // 스마트 필터 칩 빌더
  Widget _buildSmartFilterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive 
            ? LinearGradient(
                colors: [
                  ModernColors.primary,
                  ModernColors.primary.withOpacity(0.8),
                ],
              )
            : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? ModernColors.primary : ModernColors.border,
            width: 1,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: ModernColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : ModernColors.textPrimary,
          ),
        ),
      ),
    );
  }
  
  /// 필터 칩
  Widget _buildFilterChip(String label, String key) {
    final isActive = _activeFilters.contains(key);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isActive) {
            _activeFilters.remove(key);
          } else {
            _activeFilters.add(key);
          }
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ModernColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? ModernColors.primary : ModernColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : ModernColors.textPrimary,
          ),
        ),
      ),
    );
  }
  
  /// 인기 모임 섹션
  Widget _buildPopularMeetingsSection() {
    final popularMeetings = ref.watch(globalPopularMeetingsProvider);
    
    if (popularMeetings.isEmpty) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildSectionHeader(
            title: '🔥 지금 인기있는 모임',
            subtitle: '실시간으로 많은 관심을 받고 있어요',
            leadingIcon: Icons.local_fire_department,
            onViewAll: () {
              Navigator.pushNamed(
                context,
                '/meeting_list_all',
                arguments: {
                  'sectionTitle': '인기 모임',
                  'category': null,
                },
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // 인기 모임 리스트 (캐시된 이미지 사용)
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: math.min(popularMeetings.length, 5),
              itemBuilder: (context, index) {
                final meeting = popularMeetings[index];
                return _buildOptimizedPopularCardWithCache(meeting, index);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }
  
  /// 캐시된 이미지를 사용하는 최적화된 인기 모임 카드
  Widget _buildOptimizedPopularCardWithCache(AvailableMeeting meeting, int index) {
    return GestureDetector(
      onTap: () => _handleMeetingTap(meeting),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // 배경 이미지 - 캐시된 이미지 사용
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedMeetingImage(
                  meeting: meeting,
                  fit: BoxFit.cover,
                  showShimmer: true,
                ),
              ),
            ),
            
            // 그라데이션 오버레이
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
            // 콘텐츠
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meeting.location,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 카테고리 뱃지
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: meeting.category.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meeting.category.displayName,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 최적화된 인기 모임 카드 (이전 버전 - 호환성을 위해 유지)
  Widget _buildOptimizedPopularCard(AvailableMeeting meeting, String? imagePath, int index) {
    return GestureDetector(
      onTap: () => _handleMeetingTap(meeting),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // 배경 이미지 - 실제 모임 이미지 또는 이모지
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imagePath != null
                  ? _buildRealImageWidget(imagePath)
                  : _buildEmojiPlaceholderWidget(meeting),
              ),
            ),
            
            // 그라데이션 오버레이
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
            // 콘텐츠
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meeting.location,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 카테고리 뱃지
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: meeting.category.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meeting.category.displayName,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 나에게 딱 맞는 모임 섹션 (MeetingCard2025 컴포넌트 사용)
  Widget _buildPerfectMatchMeetingsSection(GlobalUser user) {
    final recommendedMeetings = ref.watch(globalRecommendedMeetingsProvider);
    
    if (recommendedMeetings.isEmpty) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.only(top: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildSectionHeader(
            title: '✨ 나에게 딱 맞는 모임',
            subtitle: 'AI가 분석한 맞춤 추천',
            leadingIcon: Icons.auto_awesome,
            onViewAll: () {
              Navigator.pushNamed(
                context,
                '/meeting_list_all',
                arguments: {
                  'sectionTitle': '나에게 딱 맞는 모임',
                  'category': null,
                },
              );
            },
          ),
          const SizedBox(height: 20),
          
          // MeetingCard2025 컴포넌트 사용 (최대 2개까지 표시)
          ...List.generate(
            math.min(recommendedMeetings.length, 2),
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MeetingCard2025(
                meeting: recommendedMeetings[index],
                // imageAsset 제거 - MeetingCard가 직접 이미지를 로드함
                onTap: () => _handleMeetingTap(recommendedMeetings[index]),
                onBookmark: () => _handleBookmarkTap(recommendedMeetings[index]),
                isBookmarked: _isBookmarked(recommendedMeetings[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 매치 이유 생성
  String _getMatchReason(AvailableMeeting meeting, GlobalUser user) {
    final stats = user.stats;
    
    switch (meeting.category) {
      case MeetingCategory.exercise:
        return stats.stamina >= 3 ? '체력 레벨이 높아요!' : '체력 향상에 도움될 거예요';
      case MeetingCategory.study:
        return stats.knowledge >= 3 ? '지식 수준이 비슷해요!' : '새로운 지식을 얻을 수 있어요';
      case MeetingCategory.networking:
        return stats.sociality >= 3 ? '사교성이 뛰어나세요!' : '인맥 확장 기회예요';
      case MeetingCategory.reading:
        return '독서 습관에 도움될 거예요';
      case MeetingCategory.culture:
        return '문화 생활을 즐기실 것 같아요';
      case MeetingCategory.outdoor:
        return '야외 활동을 좋아하실 것 같아요';
      default:
        return '새로운 경험이 될 거예요';
    }
  }
  
  /// 카테고리 선택, 검색, 필터 섹션
  Widget _buildCategoryAndSearchSection() {
    return Container(
      margin: const EdgeInsets.only(top: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 선택 영역 (좌우 스크롤)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '카테고리별 탐색',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 카테고리 버튼들 (정사각형 + 좌우 스크롤)
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: MeetingCategory.values.length,
              itemBuilder: (context, index) {
                final category = MeetingCategory.values[index];
                final isSelected = _selectedCategory == category;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _updateFilteredMeetings();
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? category.color.withOpacity(0.1) : ModernColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? category.color : ModernColors.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 이모지
                        Text(
                          category.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        // 카테고리 이름
                        Text(
                          category.displayName,
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? category.color : ModernColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 검색 및 필터 영역
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // 검색바, 온라인 필터, 필터 버튼 (가로 배치)
                Row(
                  children: [
                    // 메인 검색바
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
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                            _updateFilteredMeetings();
                          },
                          style: GoogleFonts.notoSans(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '모임 이름, 지역, 키워드로 검색',
                            hintStyle: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: ModernColors.textSecondary,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: ModernColors.textSecondary,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: ModernColors.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    _updateFilteredMeetings();
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
                    
                    // 온라인 필터 토글
                    GestureDetector(
                      onTap: () {
                        setState(() => _showOnlineOnly = !_showOnlineOnly);
                        HapticFeedback.lightImpact();
                        _updateFilteredMeetings();
                      },
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _showOnlineOnly ? ModernColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _showOnlineOnly 
                              ? ModernColors.primary 
                              : Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_showOnlineOnly 
                                ? ModernColors.primary 
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
                              color: _showOnlineOnly ? Colors.white : ModernColors.textSecondary,
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
                                  : ModernColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // 필터 토글 버튼 (뱃지 포함)
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
                                ? ModernColors.primary 
                                : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _showFilters || _activeFilterCount > 0
                                  ? ModernColors.primary 
                                  : Colors.grey.shade300,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_showFilters || _activeFilterCount > 0
                                    ? ModernColors.primary 
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
                                : ModernColors.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                        // 활성 필터 개수 뱃지
                        if (_activeFilterCount > 0 && !_showFilters)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: ModernColors.error,
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
                
                // 쉽게 찾기 (빠른 필터)
                const SizedBox(height: 16),
                _buildQuickFiltersSection(),
                
                // 확장 필터 섹션
                if (_showFilters) ...[
                  const SizedBox(height: 16),
                  _buildExpandedFilters(),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 400), delay: const Duration(milliseconds: 200));
  }
  
  
  /// 단순화된 빠른 필터
  Widget _buildSimplifiedQuickFilters() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildQuickFilterChip('이번 주말', 'weekend', Icons.weekend_rounded),
          const SizedBox(width: 8),
          _buildQuickFilterChip('무료', 'free', Icons.money_off_rounded),
          const SizedBox(width: 8),
          _buildQuickFilterChip('온라인', 'online', Icons.videocam_rounded),
          const SizedBox(width: 8),
          _buildQuickFilterChip('내 주변', 'nearby', Icons.near_me_rounded),
        ],
      ),
    );
  }
  
  Widget _buildQuickFilterChip(String label, String key, IconData icon) {
    final isActive = _activeQuickFilters.contains(key) || 
                     (key == 'online' && _showOnlineOnly);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (key == 'online') {
            _showOnlineOnly = !_showOnlineOnly;
          } else {
            if (isActive) {
              _activeQuickFilters.remove(key);
            } else {
              _activeQuickFilters.add(key);
            }
          }
        });
        HapticFeedback.lightImpact();
        _updateFilteredMeetings();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive 
            ? ModernColors.primary.withOpacity(0.1)
            : ModernColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive 
              ? ModernColors.primary 
              : ModernColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive 
                ? ModernColors.primary
                : ModernColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive 
                  ? ModernColors.primary
                  : ModernColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 쉽게 찾기 (빠른 필터) - 기존 메서드 유지
  Widget _buildQuickFiltersSection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 쉽게 찾기 타이틀
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: 16,
                color: ModernColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '쉽게 찾기',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 빠른 필터 칩들
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final quickFilters = [
                  {'key': 'weekend', 'label': '이번 주말', 'icon': Icons.weekend_rounded, 'color': Colors.orange},
                  {'key': 'free', 'label': '무료', 'icon': Icons.money_off_rounded, 'color': Colors.green},
                  {'key': 'today', 'label': '오늘', 'icon': Icons.today_rounded, 'color': Colors.blue},
                  {'key': 'nearby', 'label': '내 주변', 'icon': Icons.near_me_rounded, 'color': Colors.indigo},
                ];
                
                final filter = quickFilters[index];
                final isActive = _activeQuickFilters.contains(filter['key']);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isActive) {
                        _activeQuickFilters.remove(filter['key']);
                      } else {
                        _activeQuickFilters.add(filter['key'] as String);
                      }
                    });
                    HapticFeedback.lightImpact();
                    _updateFilteredMeetings();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive 
                        ? (filter['color'] as Color).withOpacity(0.1)
                        : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isActive 
                          ? (filter['color'] as Color)
                          : Colors.grey.shade300,
                        width: isActive ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter['icon'] as IconData,
                          size: 16,
                          color: isActive 
                            ? (filter['color'] as Color)
                            : ModernColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filter['label'] as String,
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive 
                              ? (filter['color'] as Color)
                              : ModernColors.textSecondary,
                          ),
                        ),
                      ],
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
  
  /// 단순화된 확장 필터
  Widget _buildSimplifiedExpandedFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지역 필터
          Text(
            '지역',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSimpleFilterChip('서울', 'seoul'),
              _buildSimpleFilterChip('경기', 'gyeonggi'),
              _buildSimpleFilterChip('인천', 'incheon'),
              _buildSimpleFilterChip('부산', 'busan'),
              _buildSimpleFilterChip('대구', 'daegu'),
              _buildSimpleFilterChip('광주', 'gwangju'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 가격 필터
          Text(
            '가격',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSimpleFilterChip('무료', 'free'),
              _buildSimpleFilterChip('1만원 이하', 'under_10k'),
              _buildSimpleFilterChip('1-4만원', '10k_40k'),
              _buildSimpleFilterChip('4만원 이상', 'over_40k'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 필터 초기화 버튼
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _activeFilters.clear();
                  _activeQuickFilters.clear();
                  _selectedCategory = MeetingCategory.all;
                  _selectedLocation = null;
                  _selectedPriceRange = null;
                  _showFilters = false;
                  _updateFilteredMeetings();
                });
                HapticFeedback.lightImpact();
              },
              child: Text(
                '필터 초기화',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSimpleFilterChip(String label, String key) {
    final isActive = _selectedLocation == key || _selectedPriceRange == key;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (key.contains('k') || key == 'free') {
            // 가격 필터
            _selectedPriceRange = isActive ? null : key;
          } else {
            // 지역 필터
            _selectedLocation = isActive ? null : key;
          }
          _updateFilteredMeetings();
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
            ? ModernColors.primary.withOpacity(0.1)
            : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive 
              ? ModernColors.primary 
              : ModernColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive 
              ? ModernColors.primary 
              : ModernColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 확장 필터 섹션 (상세 필터)
  Widget _buildExpandedFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 필터',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // 1. 전체 공개 / 우리 학교
          _buildFilterSection(
            '공개 범위',
            [
              {'key': 'all', 'label': '전체 공개'},
              {'key': 'school', 'label': '우리 학교'},
            ],
            _selectedScope,
            (value) => setState(() => _selectedScope = value),
          ),
          
          const SizedBox(height: 16),
          
          // 2. 모임 카테고리
          _buildFilterSection(
            '모임 카테고리',
            [
              {'key': 'exercise', 'label': '운동/스포츠'},
              {'key': 'outdoor', 'label': '아웃도어/여행'},
              {'key': 'networking', 'label': '사교/네트워킹'},
              {'key': 'study', 'label': '스터디'},
              {'key': 'reading', 'label': '책/독서'},
              {'key': 'culture', 'label': '문화/영화'},
            ],
            _selectedCategory.name,
            (value) => setState(() {
              _selectedCategory = MeetingCategory.values.firstWhere(
                (cat) => cat.name == value,
                orElse: () => MeetingCategory.all,
              );
              _updateFilteredMeetings();
            }),
          ),
          
          const SizedBox(height: 16),
          
          // 3. 지역
          _buildFilterSection(
            '지역',
            [
              {'key': 'online', 'label': '온라인'},
              {'key': 'seoul', 'label': '서울'},
              {'key': 'gyeonggi', 'label': '경기'},
              {'key': 'incheon', 'label': '인천'},
              {'key': 'daejeon', 'label': '대전'},
              {'key': 'gwangju', 'label': '광주'},
              {'key': 'daegu', 'label': '대구'},
              {'key': 'jeju', 'label': '제주'},
              {'key': 'busan', 'label': '부산'},
            ],
            _selectedLocation,
            (value) => setState(() {
              _selectedLocation = value;
              _updateFilteredMeetings();
            }),
          ),
          
          const SizedBox(height: 16),
          
          // 4. 날짜 범위
          _buildDateRangeSection(),
          
          const SizedBox(height: 16),
          
          // 5. 가격
          _buildFilterSection(
            '가격',
            [
              {'key': 'free', 'label': '무료'},
              {'key': 'under_10k', 'label': '1만원 이하'},
              {'key': '10k_40k', 'label': '1~4만원'},
              {'key': 'over_40k', 'label': '4만원 이상'},
            ],
            _selectedPriceRange,
            (value) => setState(() {
              _selectedPriceRange = value;
              _updateFilteredMeetings();
            }),
          ),
          
          const SizedBox(height: 20),
          
          // 필터 초기화 및 적용 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _activeFilters.clear();
                      _activeQuickFilters.clear();
                      _selectedCategory = MeetingCategory.all;
                      _selectedScope = 'all';
                      _selectedLocation = null;
                      _selectedDateRange = null;
                      _selectedPriceRange = null;
                      _updateFilteredMeetings();
                    });
                    HapticFeedback.lightImpact();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: ModernColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '필터 초기화',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = false;
                    });
                    HapticFeedback.lightImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '적용하기',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 필터 섹션 빌더
  Widget _buildFilterSection(
    String title,
    List<Map<String, String>> options,
    String? selectedValue,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option['key'];
            return GestureDetector(
              onTap: () {
                onChanged(option['key']!);
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? ModernColors.primary.withOpacity(0.1)
                    : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                      ? ModernColors.primary 
                      : ModernColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  option['label']!,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                      ? ModernColors.primary 
                      : ModernColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  /// 날짜 범위 선택 섹션
  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜 범위',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: _selectedDateRange,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: ModernColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedDateRange = picked;
                _updateFilteredMeetings();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _selectedDateRange != null 
                ? ModernColors.primary.withOpacity(0.1)
                : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedDateRange != null
                  ? ModernColors.primary
                  : ModernColors.border,
                width: _selectedDateRange != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: _selectedDateRange != null
                    ? ModernColors.primary
                    : ModernColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedDateRange != null
                    ? '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} - ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}'
                    : '날짜를 선택하세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _selectedDateRange != null
                      ? ModernColors.primary
                      : ModernColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (_selectedDateRange != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDateRange = null;
                        _updateFilteredMeetings();
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      size: 16,
                      color: ModernColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 전체 모임 섹션
  Widget _buildMustSeeMeetingsSection() {
    final allMeetings = ref.watch(globalAvailableMeetingsProvider);
    
    // 검색이나 필터가 활성화된 경우 숨김
    if (_searchQuery.isNotEmpty) {
      return const SizedBox.shrink();
    }
    
    // 카테고리나 필터가 적용된 경우 필터링된 결과 사용
    List<AvailableMeeting> displayMeetings;
    if (_selectedCategory != MeetingCategory.all || _activeFilters.isNotEmpty) {
      displayMeetings = _filteredMeetings.take(8).toList();
      if (displayMeetings.isEmpty) {
        return _buildEmptyState();
      }
    } else {
      displayMeetings = allMeetings.take(8).toList();
    }
    
    if (displayMeetings.isEmpty) {
      return _buildEmptyState();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildSectionHeader(
            title: '전체 모임',
            onViewAll: () {
              Navigator.pushNamed(
                context,
                '/meeting_list_all',
                arguments: {
                  'sectionTitle': '전체 모임',
                  'category': _selectedCategory == MeetingCategory.all ? null : _selectedCategory,
                },
              );
            },
          ),
          const SizedBox(height: 20),
          
          // MeetingCardList2025 컴포넌트들을 세로로 나열
          ...List.generate(
            displayMeetings.length,
            (index) {
              final meeting = displayMeetings[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: MeetingCardList2025(
                  meeting: meeting,
                  // imageAsset 제거 - MeetingCardList가 직접 이미지를 로드함
                  onTap: () => _handleMeetingTap(meeting),
                  onBookmark: () => _handleBookmarkTap(meeting),
                  isBookmarked: _isBookmarked(meeting),
                  showDivider: index < displayMeetings.length - 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // 빈 상태 화면
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: ModernColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            '조건에 맞는 모임이 없습니다',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 모임 개설 FAB  
  Widget _buildCreateMeetingFAB() {
    return Container(
      decoration: BoxDecoration(
        color: ModernColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCreateMeeting,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '모임 만들기',
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 🎯 모임 개설 핸들러
  void _handleCreateMeeting() {
    HapticFeedback.mediumImpact();
    
    // Sherpi 격려 메시지 제거 - 최종 완료 시에만 표시
    
    // 모달 띄우기
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const MeetingCreationDialog(),
    );
  }
  
  // ==================== 유틸리티 메서드들 ====================
  
  /// 실제 모임 데이터에서 이미지 경로 가져오기 (비동기)
  Future<String?> _getImagePathForMeeting(AvailableMeeting meeting) async {
    // 캐시에서 먼저 확인
    final cacheKey = meeting.id;
    if (_imagePathCache.containsKey(cacheKey)) {
      return _imagePathCache[cacheKey];
    }
    
    String? imagePath;
    
    // 실제 이미지가 있으면 해당 이미지 사용
    if (meeting.hasImages && meeting.imageFileNames.isNotEmpty) {
      final firstImage = meeting.imageFileNames.first;
      
      // asset: 플래그로 시작하면 assets 폴더 경로 반환
      if (firstImage.startsWith('asset:')) {
        imagePath = 'assets/images/meeting/${firstImage.substring(6)}';
      } else {
        // 일반 이미지 파일은 MeetingImageUtils를 사용하여 전체 경로 가져오기
        final imageFile = await MeetingImageUtils.getMeetingImageFile(firstImage);
        imagePath = imageFile?.path;
      }
    }
    
    // 캐시에 저장
    _imagePathCache[cacheKey] = imagePath;
    return imagePath;
  }
  
  /// 실제 이미지 위젯 생성 (캐시 사용)
  Widget _buildRealImageWidget(String imagePath) {
    final cacheManager = MeetingImageCacheManager();
    return cacheManager.getCachedImage(
      imagePath,
      fit: BoxFit.cover,
      errorWidget: _buildEmojiPlaceholderWidget(null),
    );
  }
  
  /// 동적 이미지 경로인지 확인
  bool _isDynamicImagePath(String path) {
    return !path.startsWith('assets/') && (path.contains('/') || path.endsWith('.jpg') || path.endsWith('.png'));
  }
  
  /// 이모지 플레이스홀더 위젯
  Widget _buildEmojiPlaceholderWidget(AvailableMeeting? meeting) {
    // meeting이 null이면 기본 캬러 사용
    final categoryColor = meeting?.category.color ?? ModernColors.primary;
    final categoryEmoji = meeting?.category.emoji ?? '👥';
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withOpacity(0.8),
            categoryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          categoryEmoji,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }
  
  List<AvailableMeeting> _applyFilters(List<AvailableMeeting> meetings) {
    var filtered = meetings;
    
    // 검색어 필터 (제목, 설명, 위치, 태그 검색)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((m) =>
        m.title.toLowerCase().contains(query) ||
        m.description.toLowerCase().contains(query) ||
        m.location.toLowerCase().contains(query) ||
        m.category.displayName.toLowerCase().contains(query) ||
        m.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }
    
    // 카테고리 필터
    if (_selectedCategory != MeetingCategory.all) {
      filtered = filtered.where((m) => m.category == _selectedCategory).toList();
    }
    
    // 온라인 전용 필터
    if (_showOnlineOnly) {
      filtered = filtered.where((m) => 
        m.location.toLowerCase().contains('온라인') ||
        m.location.toLowerCase().contains('online') ||
        m.location.toLowerCase().contains('줌') ||
        m.location.toLowerCase().contains('zoom')
      ).toList();
    }
    
    // 지역 필터
    if (_selectedLocation != null) {
      switch (_selectedLocation) {
        case 'online':
          filtered = filtered.where((m) => 
            m.location.toLowerCase().contains('온라인') ||
            m.location.toLowerCase().contains('online')
          ).toList();
          break;
        case 'seoul':
          filtered = filtered.where((m) => m.location.contains('서울')).toList();
          break;
        case 'gyeonggi':
          filtered = filtered.where((m) => m.location.contains('경기')).toList();
          break;
        case 'incheon':
          filtered = filtered.where((m) => m.location.contains('인천')).toList();
          break;
        case 'daejeon':
          filtered = filtered.where((m) => m.location.contains('대전')).toList();
          break;
        case 'gwangju':
          filtered = filtered.where((m) => m.location.contains('광주')).toList();
          break;
        case 'daegu':
          filtered = filtered.where((m) => m.location.contains('대구')).toList();
          break;
        case 'jeju':
          filtered = filtered.where((m) => m.location.contains('제주')).toList();
          break;
        case 'busan':
          filtered = filtered.where((m) => m.location.contains('부산')).toList();
          break;
      }
    }
    
    // 가격 범위 필터
    if (_selectedPriceRange != null) {
      switch (_selectedPriceRange) {
        case 'free':
          filtered = filtered.where((m) => m.type == MeetingType.free).toList();
          break;
        case 'under_10k':
          filtered = filtered.where((m) => m.participationFee < 10000).toList();
          break;
        case '10k_40k':
          filtered = filtered.where((m) => m.participationFee >= 10000 && m.participationFee <= 40000).toList();
          break;
        case 'over_40k':
          filtered = filtered.where((m) => m.participationFee > 40000).toList();
          break;
      }
    }
    
    // 날짜 범위 필터
    if (_selectedDateRange != null) {
      filtered = filtered.where((m) => 
        m.dateTime.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
        m.dateTime.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))
      ).toList();
    }
    
    // 빠른 필터들 적용
    for (final filter in _activeQuickFilters) {
      switch (filter) {
        case 'weekend':
          // 이번 주말 (토요일, 일요일)
          final now = DateTime.now();
          final thisWeekend = now.add(Duration(days: (6 - now.weekday) % 7));
          final nextSunday = thisWeekend.add(const Duration(days: 1));
          filtered = filtered.where((m) => 
            (m.dateTime.weekday == DateTime.saturday || m.dateTime.weekday == DateTime.sunday) &&
            m.dateTime.isAfter(thisWeekend.subtract(const Duration(days: 1))) &&
            m.dateTime.isBefore(nextSunday.add(const Duration(days: 1)))
          ).toList();
          break;
        case 'free':
          filtered = filtered.where((m) => m.type == MeetingType.free).toList();
          break;
        case 'today':
          final today = DateTime.now();
          filtered = filtered.where((m) => 
            m.dateTime.year == today.year &&
            m.dateTime.month == today.month &&
            m.dateTime.day == today.day
          ).toList();
          break;
        case 'nearby':
          // TODO: GPS 기반 위치 필터링 구현 예정
          break;
      }
    }
    
    // 기타 레거시 필터들 (향후 제거 예정)
    for (final filter in _activeFilters) {
      switch (filter) {
        case 'recent':
          filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          break;
        case 'popular':
          filtered.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
          break;
      }
    }
    
    return filtered;
  }
  
  void _refreshRecommendations() {
    setState(() {});
    HapticFeedback.lightImpact();
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '새로운 추천 모임을 불러왔어요! ✨',
      emotion: SherpiEmotion.cheering,
    );
  }
  
  void _handleMeetingTap(AvailableMeeting meeting) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/meeting_detail',
      arguments: meeting,
    );
  }
  
  void _handleBookmarkTap(AvailableMeeting meeting) {
    setState(() {
      if (_bookmarkedMeetings.contains(meeting.id)) {
        _bookmarkedMeetings.remove(meeting.id);
      } else {
        _bookmarkedMeetings.add(meeting.id);
      }
    });
    HapticFeedback.lightImpact();
  }
  
  bool _isBookmarked(AvailableMeeting meeting) {
    return _bookmarkedMeetings.contains(meeting.id);
  }
  
}