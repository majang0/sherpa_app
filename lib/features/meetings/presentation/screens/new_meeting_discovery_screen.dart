// lib/features/meetings/presentation/screens/new_meeting_discovery_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// 🎨 디자인 시스템
import '../../../../core/constants/app_colors_2025.dart';

// 📦 모델 및 프로바이더
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../models/available_meeting_model.dart';
import '../../../../shared/utils/meeting_image_manager.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_2025.dart';
import '../../../../shared/widgets/components/molecules/meeting_card_list_2025.dart';

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
  bool _showFilters = false;
  
  // 필터 상태
  final Set<String> _activeFilters = {};
  bool _showOnlineOnly = false;
  
  // 북마크 상태
  final Set<String> _bookmarkedMeetings = {};
  
  // 성능 최적화
  Timer? _searchDebouncer;
  
  // 필터링된 모임 리스트
  List<AvailableMeeting> _filteredMeetings = [];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 초기 애니메이션
    _animationController.forward();
    
    // 검색 컨트롤러 리스너 추가
    _searchController.addListener(_onSearchChanged);
    
    // 환영 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.welcome,
        emotion: SherpiEmotion.cheering,
        userContext: {
          'screen': 'new_meeting_discovery',
          'feature': 'meeting_tab_redesign',
        },
      );
      
      // 초기 필터링 실행
      _updateFilteredMeetings();
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
      backgroundColor: AppColors2025.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 🔍 검색바와 필터 (기존 유지)
            SliverToBoxAdapter(
              child: _buildSearchSection(),
            ),
            
            // 🔥 인기 모임 (실제 메소드)
            SliverToBoxAdapter(
              child: _buildPopularMeetingsSection(),
            ),
            
            // 💎 나에게 딱 맞는 모임 섹션
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _buildPerfectMatchMeetingsSection(user),
              ),
            ),
            
            // 📂 카테고리별 모임 탐색
            SliverToBoxAdapter(
              child: _buildCategoryAndSearchSection(),
            ),
            
            // 📋 전체 모임 섹션
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
  
  /// 🔍 검색바와 필터 섹션 (개선된 검색 결과 포함)
  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 검색바
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
              decoration: InputDecoration(
                hintText: '관심있는 모임을 검색해보세요',
                hintStyle: GoogleFonts.notoSans(
                  color: AppColors2025.textTertiary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors2025.textTertiary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors2025.textTertiary,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          
          // 검색 결과 표시
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSearchResults(),
          ],
          
          // 활성화된 필터 표시
          if (_activeFilters.isNotEmpty || _selectedCategory != MeetingCategory.all) ...[
            const SizedBox(height: 16),
            _buildActiveFilters(),
          ],
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
              color: AppColors2025.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              '검색 결과가 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors2025.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '다른 키워드로 검색해보세요',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors2025.textTertiary,
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
                    color: AppColors2025.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors2025.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteredMeetings.length}개',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors2025.primary,
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
                      color: AppColors2025.primary,
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
              color: AppColors2025.textSecondary,
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
                  color: AppColors2025.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors2025.primary.withOpacity(0.3),
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
                        color: AppColors2025.primary,
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
                        color: AppColors2025.primary,
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
                  AppColors2025.primary,
                  AppColors2025.primary.withOpacity(0.8),
                ],
              )
            : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors2025.primary : AppColors2025.glassBorder,
            width: 1,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: AppColors2025.primary.withOpacity(0.3),
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
            color: isActive ? Colors.white : AppColors2025.textPrimary,
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
          color: isActive ? AppColors2025.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors2025.primary : AppColors2025.glassBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : AppColors2025.textPrimary,
          ),
        ),
      ),
    );
  }
  
  /// 🔥 인기 모임 섹션 (기존 유지)
  Widget _buildPopularMeetingsSection() {
    final popularMeetings = ref.watch(globalPopularMeetingsProvider);
    
    if (popularMeetings.isEmpty) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🔥 지금 인기있는 모임',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors2025.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/meeting_list_all',
                      arguments: {
                        'sectionTitle': '인기 모임',
                        'category': null,
                      },
                    );
                  },
                  child: Text(
                    '전체보기',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors2025.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 인기 모임 리스트
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: math.min(popularMeetings.length, 5),
              itemBuilder: (context, index) {
                final meeting = popularMeetings[index];
                return _buildPopularMeetingCard(meeting, index);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }
  
  /// 인기 모임 카드 (기존 유지)
  Widget _buildPopularMeetingCard(AvailableMeeting meeting, int index) {
    return GestureDetector(
      onTap: () => _handleMeetingTap(meeting),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(_getMeetingImage(index + 5)),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
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
  
  /// 🎯 나에게 딱 맞는 모임 섹션 (MeetingCard2025 컴포넌트 사용)
  Widget _buildPerfectMatchMeetingsSection(GlobalUser user) {
    final recommendedMeetings = ref.watch(globalRecommendedMeetingsProvider);
    final imageManager = MeetingImageManager();
    
    if (recommendedMeetings.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎯 나에게 딱 맞는 모임',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/meeting_list_all',
                    arguments: {
                      'sectionTitle': '나에게 딱 맞는 모임',
                      'category': null,
                    },
                  );
                },
                child: Text(
                  '전체보기',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors2025.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // MeetingCard2025 컴포넌트 사용 (최대 2개까지 표시)
        ...List.generate(
          math.min(recommendedMeetings.length, 2),
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MeetingCard2025(
              meeting: recommendedMeetings[index],
              imageAsset: imageManager.getImageForMeeting(recommendedMeetings[index]),
              onTap: () => _handleMeetingTap(recommendedMeetings[index]),
              onBookmark: () => _handleBookmarkTap(recommendedMeetings[index]),
              isBookmarked: _isBookmarked(recommendedMeetings[index]),
            ),
          ),
        ),
      ],
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
  
  /// 🏷️ 카테고리 선택, 검색, 필터 섹션 (이미지2 기준 - 모임2탭 디자인으로 완전 재구현)
  Widget _buildCategoryAndSearchSection() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ 카테고리 선택 영역 (좌우 스크롤)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '카테고리',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors2025.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 카테고리 버튼들 (정사각형 + 좌우 스크롤, 20% 크기 증가)
          SizedBox(
            height: 90, // 75 * 1.2 = 90
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
                    width: 78, // 65 * 1.2 = 78
                    height: 78,
                    margin: const EdgeInsets.only(right: 14, top: 6, bottom: 6), // 간격도 비례 증가
                    decoration: BoxDecoration(
                      gradient: isSelected 
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [category.color, category.color.withOpacity(0.8)]
                          )
                        : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(17), // 14 * 1.2 ≈ 17
                      border: Border.all(
                        color: isSelected ? category.color : AppColors2025.glassBorder,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected 
                            ? category.color.withOpacity(0.25) 
                            : Colors.black.withOpacity(0.04),
                          blurRadius: isSelected ? 12 : 8, // 버튼 크기에 맞게 그림자도 증가
                          offset: const Offset(0, 3), // 그림자 오프셋도 약간 증가
                          spreadRadius: isSelected ? 0.5 : 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 이모지 (버튼 크기에 비례해서 증가)
                        Text(
                          category.emoji,
                          style: const TextStyle(fontSize: 22), // 18 * 1.2 ≈ 22
                        ),
                        const SizedBox(height: 8), // 6 * 1.3 ≈ 8
                        // 카테고리 이름
                        Text(
                          category.displayName,
                          style: GoogleFonts.notoSans(
                            fontSize: 11, // 9 * 1.2 ≈ 11
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors2025.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
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
          
          // 🔍 검색 및 필터 영역 (모임2탭 스타일)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // 검색바와 필터 버튼
                Row(
                  children: [
                    // 메인 검색바
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: AppColors2025.glassBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            Icon(
                              Icons.search_rounded,
                              color: AppColors2025.textTertiary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() => _searchQuery = value);
                                },
                                decoration: InputDecoration(
                                  hintText: '카테고리 내에서 검색',
                                  hintStyle: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    color: AppColors2025.textTertiary,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: AppColors2025.textTertiary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // 필터 토글 버튼
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _showFilters ? AppColors2025.primary : Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: _showFilters ? AppColors2025.primary : AppColors2025.glassBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _showFilters 
                              ? AppColors2025.primary.withOpacity(0.3)
                              : Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: _showFilters ? Colors.white : AppColors2025.textSecondary,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() => _showFilters = !_showFilters);
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ),
                  ],
                ),
                
                // 스마트 필터 태그들 (가로 스크롤)
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSmartFilterTag('🌟 최신순', 'recent'),
                      const SizedBox(width: 8),
                      _buildSmartFilterTag('🔥 인기순', 'popular'),
                      const SizedBox(width: 8),
                      _buildSmartFilterTag('💎 프리미엄', 'premium'),
                      const SizedBox(width: 8),
                      _buildSmartFilterTag('🆓 무료만', 'free_only'),
                      const SizedBox(width: 8),
                      _buildSmartFilterTag('📍 온라인', 'online'),
                      const SizedBox(width: 8),
                      _buildSmartFilterTag('👥 소규모', 'small'),
                      const SizedBox(width: 8),
                      _buildSmartFilterTag('🔰 초보환영', 'beginner'),
                    ],
                  ),
                ),
                
                // 확장 필터 (필터 버튼이 활성화된 경우만 표시)
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
  
  // 스마트 필터 태그
  Widget _buildSmartFilterTag(String label, String key) {
    final isActive = _activeFilters.contains(key);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isActive) {
            _activeFilters.remove(key);
          } else {
            _activeFilters.add(key);
          }
          _updateFilteredMeetings();
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors2025.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors2025.primary : AppColors2025.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors2025.primary : AppColors2025.textSecondary,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors2025.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 확장 필터 섹션
  Widget _buildExpandedFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors2025.glassBorder,
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
              color: AppColors2025.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // 참가자 수 필터
          Text(
            '참가자 수',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors2025.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('1-5명', 'participants_1_5'),
              _buildFilterChip('6-10명', 'participants_6_10'),
              _buildFilterChip('11-20명', 'participants_11_20'),
              _buildFilterChip('20명 이상', 'participants_20_plus'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 참가비 필터
          Text(
            '참가비',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors2025.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('무료', 'price_free'),
              _buildFilterChip('1만원 이하', 'price_under_10k'),
              _buildFilterChip('1-3만원', 'price_10k_30k'),
              _buildFilterChip('3만원 이상', 'price_over_30k'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 시간대 필터
          Text(
            '시간대',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors2025.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('오전', 'time_morning'),
              _buildFilterChip('오후', 'time_afternoon'),
              _buildFilterChip('저녁', 'time_evening'),
              _buildFilterChip('주말', 'time_weekend'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 필터 초기화 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _activeFilters.clear();
                      _selectedCategory = MeetingCategory.all;
                      _updateFilteredMeetings();
                    });
                    HapticFeedback.lightImpact();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors2025.glassBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '필터 초기화',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors2025.textSecondary,
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
                    backgroundColor: AppColors2025.primary,
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
  
  /// 📋 전체 모임 섹션 (컴포넌트창 가상모임탭 디자인) - 반응형 최적화
  Widget _buildMustSeeMeetingsSection() {
    final allMeetings = ref.watch(globalAvailableMeetingsProvider);
    final imageManager = MeetingImageManager();
    
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
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '📋 전체 모임',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16), // 최소 간격 보장
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/meeting_list_all',
                      arguments: {
                        'sectionTitle': '전체 모임',
                        'category': _selectedCategory == MeetingCategory.all ? null : _selectedCategory,
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '전체보기',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors2025.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // MeetingCardList2025 컴포넌트들을 세로로 나열
          ...List.generate(
            displayMeetings.length,
            (index) {
              final meeting = displayMeetings[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: MeetingCardList2025(
                  meeting: meeting,
                  imageAsset: imageManager.getImageForMeeting(meeting),
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
            color: AppColors2025.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            '조건에 맞는 모임이 없습니다',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors2025.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🎯 모임 생성 FAB - 반응형 위치
  Widget _buildCreateMeetingFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(context, '/meeting_create');
      },
      backgroundColor: AppColors2025.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: Text(
        '모임 만들기',
        style: GoogleFonts.notoSans(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  // ==================== 유틸리티 메서드들 ====================
  
  String _getMeetingImage(int index) {
    final imageNumber = (index % 23) + 1;
    return 'assets/images/meeting/$imageNumber.jpg';
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
    
    // 액티브 필터들 적용
    for (final filter in _activeFilters) {
      switch (filter) {
        case 'recent':
          // 최신순 정렬 (날짜가 가까운 순)
          filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          break;
        case 'popular':
          // 인기순 정렬 (참가자 많은 순)
          filtered.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
          break;
        case 'premium':
          // 프리미엄 모임 (참가비가 있는 모임)
          filtered = filtered.where((m) => m.type == MeetingType.paid).toList();
          break;
        case 'free_only':
          // 무료 모임만
          filtered = filtered.where((m) => m.type == MeetingType.free).toList();
          break;
        case 'online':
          // 온라인 모임 (위치에 "온라인"이 포함된 모임)
          filtered = filtered.where((m) => 
            m.location.toLowerCase().contains('온라인') ||
            m.location.toLowerCase().contains('online') ||
            m.location.toLowerCase().contains('줌') ||
            m.location.toLowerCase().contains('zoom')
          ).toList();
          break;
        case 'nearby':
          // TODO: GPS 기반 위치 필터링 구현 예정
          break;
        case 'beginner':
          // 초보자 환영 모임
          filtered = filtered.where((m) => 
            m.tags.any((tag) => 
              tag.contains('초보') || 
              tag.contains('환영') ||
              tag.contains('입문')
            )
          ).toList();
          break;
        case 'small':
          // 소규모 모임 (10명 이하)
          filtered = filtered.where((m) => m.maxParticipants <= 10).toList();
          break;
        
        // 확장 필터들
        case 'participants_1_5':
          filtered = filtered.where((m) => m.maxParticipants <= 5).toList();
          break;
        case 'participants_6_10':
          filtered = filtered.where((m) => m.maxParticipants >= 6 && m.maxParticipants <= 10).toList();
          break;
        case 'participants_11_20':
          filtered = filtered.where((m) => m.maxParticipants >= 11 && m.maxParticipants <= 20).toList();
          break;
        case 'participants_20_plus':
          filtered = filtered.where((m) => m.maxParticipants > 20).toList();
          break;
          
        case 'price_free':
          filtered = filtered.where((m) => m.type == MeetingType.free).toList();
          break;
        case 'price_under_10k':
          filtered = filtered.where((m) => m.participationFee < 10000).toList();
          break;
        case 'price_10k_30k':
          filtered = filtered.where((m) => m.participationFee >= 10000 && m.participationFee <= 30000).toList();
          break;
        case 'price_over_30k':
          filtered = filtered.where((m) => m.participationFee > 30000).toList();
          break;
          
        case 'time_morning':
          filtered = filtered.where((m) => m.dateTime.hour < 12).toList();
          break;
        case 'time_afternoon':
          filtered = filtered.where((m) => m.dateTime.hour >= 12 && m.dateTime.hour < 18).toList();
          break;
        case 'time_evening':
          filtered = filtered.where((m) => m.dateTime.hour >= 18).toList();
          break;
        case 'time_weekend':
          filtered = filtered.where((m) => m.dateTime.weekday == DateTime.saturday || m.dateTime.weekday == DateTime.sunday).toList();
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