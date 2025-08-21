// lib/shared/presentation/screens/meeting_list_all_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors_2025.dart';
import '../../../features/meetings/models/available_meeting_model.dart';
import '../../../shared/utils/meeting_image_manager.dart';
import '../../../shared/widgets/components/molecules/meeting_card_2025.dart';
import '../../../shared/widgets/components/molecules/meeting_card_list_2025.dart';
import '../../../shared/widgets/components/molecules/search_bar_2025.dart';
import '../../../shared/widgets/components/molecules/category_selector_2025.dart';
import '../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../shared/providers/global_meeting_provider.dart';

/// 모임 전체보기 화면 - 한국 앱 UX 패턴 적용 (글로벌 데이터 연동)
class MeetingListAllScreen extends ConsumerStatefulWidget {
  final MeetingCategory? initialCategory;
  final String? sectionTitle;
  
  const MeetingListAllScreen({
    super.key,
    this.initialCategory,
    this.sectionTitle,
  });

  @override
  ConsumerState<MeetingListAllScreen> createState() => _MeetingListAllScreenState();
}

class _MeetingListAllScreenState extends ConsumerState<MeetingListAllScreen>
    with TickerProviderStateMixin {
  
  // 상태 관리
  late TabController _tabController;
  late MeetingImageManager imageManager;
  
  MeetingCategory _selectedCategory = MeetingCategory.all;
  MeetingType? _selectedType;
  String _searchQuery = '';
  bool _isGridView = false;
  String _sortBy = 'recent'; // recent, popular, deadline
  List<String> _bookmarkedIds = [];
  
  // 필터 상태
  bool _showFilterPanel = false;
  bool _onlyAvailable = true;
  bool _freeOnly = false;
  
  // 🎯 Korean UX: Quick Filter States
  String _activeQuickFilter = '';
  
  @override
  void initState() {
    super.initState();
    imageManager = MeetingImageManager();
    
    // 초기 카테고리 설정
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    
    _tabController = TabController(
      length: MeetingCategory.values.length,
      vsync: this,
      initialIndex: MeetingCategory.values.indexOf(_selectedCategory),
    );
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = MeetingCategory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 글로벌 모임 데이터 가져오기
  List<AvailableMeeting> get globalMeetings {
    return ref.watch(globalAvailableMeetingsProvider);
  }
  
  // 필터링된 모임 리스트
  List<AvailableMeeting> get filteredMeetings {
    var meetings = globalMeetings.where((meeting) {
      // 카테고리 필터
      if (_selectedCategory != MeetingCategory.all && meeting.category != _selectedCategory) {
        return false;
      }
      
      // 타입 필터
      if (_selectedType != null && meeting.type != _selectedType) {
        return false;
      }
      
      // 검색어 필터
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!meeting.title.toLowerCase().contains(query) &&
            !meeting.description.toLowerCase().contains(query) &&
            !meeting.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }
      
      // 모집중인 모임만
      if (_onlyAvailable && meeting.currentParticipants >= meeting.maxParticipants) {
        return false;
      }
      
      // 무료 모임만
      if (_freeOnly && (meeting.price ?? 0) > 0) {
        return false;
      }
      
      // 🎯 Korean UX: Quick Filter Logic
      if (_activeQuickFilter == '인기') {
        // 인기 모임: 참여자가 70% 이상인 모임
        if (meeting.currentParticipants < (meeting.maxParticipants * 0.7)) {
          return false;
        }
      } else if (_activeQuickFilter == '마감') {
        // 마감임박: 남은 자리가 3개 이하인 모임
        final remainingSpots = meeting.maxParticipants - meeting.currentParticipants;
        if (remainingSpots > 3) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // 정렬
    meetings.sort((a, b) {
      switch (_sortBy) {
        case 'popular':
          return b.currentParticipants.compareTo(a.currentParticipants);
        case 'deadline':
          return a.dateTime.compareTo(b.dateTime);
        case 'recent':
        default:
          return b.dateTime.compareTo(a.dateTime);
      }
    });
    
    return meetings;
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors2025.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  void _toggleBookmark(String meetingId) {
    setState(() {
      if (_bookmarkedIds.contains(meetingId)) {
        _bookmarkedIds.remove(meetingId);
        _showToast('북마크 해제됨');
      } else {
        _bookmarkedIds.add(meetingId);
        _showToast('북마크 추가됨');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SherpaCleanAppBar(
        title: widget.sectionTitle ?? '모든 모임',
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          // 보기 방식 토글
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors2025.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          // 필터 버튼
          IconButton(
            icon: Icon(
              Icons.tune,
              color: _showFilterPanel ? AppColors2025.primary : AppColors2025.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _showFilterPanel = !_showFilterPanel;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색바
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar2025(
              hintText: '모임 제목, 태그로 검색...',
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onSubmitted: (query) => _showToast('검색: $query'),
              showFilter: false,
              margin: EdgeInsets.zero,
            ),
          ),
          
          // 카테고리 탭바
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors2025.primary,
              labelColor: AppColors2025.primary,
              unselectedLabelColor: AppColors2025.textSecondary,
              labelStyle: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              tabs: MeetingCategory.values.map((category) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.emoji),
                      const SizedBox(width: 4),
                      Text(category.displayName),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // 필터 패널 (접힘/펼침)
          if (_showFilterPanel)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                  ? AppColors2025.glassWhite10
                  : AppColors2025.surface,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎯 Korean UX: Quick Filters Row
                  Row(
                    children: [
                      Text(
                        '빠른 필터',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors2025.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: [
                            _buildQuickFilter('지금 핫한', '인기'),
                            _buildQuickFilter('마감임박', '마감'),
                            _buildQuickFilter('무료', '무료'),
                            _buildQuickFilter('내 근처', '근처'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 정렬 옵션
                  Row(
                    children: [
                      Text(
                        '정렬',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors2025.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: [
                            _buildSortChip('recent', '최신순'),
                            _buildSortChip('popular', '인기순'),
                            _buildSortChip('deadline', '마감임박'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 필터 옵션
                  Row(
                    children: [
                      Text(
                        '필터',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors2025.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: [
                            _buildFilterChip(
                              '모집중만',
                              _onlyAvailable,
                              (value) => setState(() => _onlyAvailable = value),
                            ),
                            _buildFilterChip(
                              '무료만',
                              _freeOnly,
                              (value) => setState(() => _freeOnly = value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // 결과 개수 및 상태
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 ${filteredMeetings.length}개의 모임',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors2025.textSecondary,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _onlyAvailable || _freeOnly || _activeQuickFilter.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _onlyAvailable = true;
                        _freeOnly = false;
                        _selectedType = null;
                        _activeQuickFilter = ''; // Reset quick filter
                      });
                    },
                    child: Text(
                      '필터 초기화',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors2025.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // 모임 리스트
          Expanded(
            child: filteredMeetings.isEmpty
              ? _buildEmptyState()
              : _isGridView
                ? _buildGridView()
                : _buildListView(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: AppColors2025.primary.withOpacity(0.1),
      checkmarkColor: AppColors2025.primary,
      labelStyle: GoogleFonts.notoSans(
        fontSize: 12,
        color: isSelected ? AppColors2025.primary : AppColors2025.textSecondary,
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool value, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: AppColors2025.primary.withOpacity(0.1),
      checkmarkColor: AppColors2025.primary,
      labelStyle: GoogleFonts.notoSans(
        fontSize: 12,
        color: value ? AppColors2025.primary : AppColors2025.textSecondary,
      ),
    );
  }
  
  // 🎯 Korean UX Enhancement: Quick Filter Chips
  Widget _buildQuickFilter(String label, String filterType) {
    final isSelected = _activeQuickFilter == filterType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_activeQuickFilter == filterType) {
            _activeQuickFilter = '';
            // Reset filters
            _freeOnly = false;
            _sortBy = 'recent';
          } else {
            _activeQuickFilter = filterType;
            
            // Apply specific filter logic
            switch (filterType) {
              case '인기':
                _sortBy = 'popular';
                break;
              case '마감':
                _sortBy = 'deadline';
                break;
              case '무료':
                _freeOnly = true;
                break;
              case '근처':
                _showToast('위치 기반 필터링 개발 예정');
                break;
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors2025.primary 
            : AppColors2025.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? AppColors2025.primary 
              : AppColors2025.textTertiary,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors2025.primary.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected 
                  ? Colors.white 
                  : AppColors2025.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredMeetings.length,
      itemBuilder: (context, index) {
        final meeting = filteredMeetings[index];
        final isBookmarked = _bookmarkedIds.contains(meeting.id);
        
        return MeetingCardList2025(
          meeting: meeting,
          imageAsset: imageManager.getImageForMeeting(meeting),
          onTap: () => _showToast('${meeting.title} 상세보기'),
          onBookmark: () => _toggleBookmark(meeting.id),
          isBookmarked: isBookmarked,
          showDivider: index < filteredMeetings.length - 1,
        );
      },
    );
  }
  
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredMeetings.length,
      itemBuilder: (context, index) {
        final meeting = filteredMeetings[index];
        final isBookmarked = _bookmarkedIds.contains(meeting.id);
        
        return MeetingCard2025(
          meeting: meeting,
          imageAsset: imageManager.getImageForMeeting(meeting),
          onTap: () => _showToast('${meeting.title} 상세보기'),
          onBookmark: () => _toggleBookmark(meeting.id),
          isBookmarked: isBookmarked,
          compact: true,
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 8),
          Text(
            '검색 조건을 변경해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors2025.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _onlyAvailable = true;
                _freeOnly = false;
                _selectedType = null;
                _selectedCategory = MeetingCategory.all;
                _activeQuickFilter = ''; // Reset quick filter
                _tabController.animateTo(0);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors2025.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '전체 모임 보기',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}