// lib/features/meetings/presentation/screens/new_meeting_discovery_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

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

/// 💡 Inlined meeting creation state (formerly meeting_creation_provider)
class MeetingCreationData {
  final MeetingCategory? selectedCategory;
  final MeetingScope scope;
  final bool isOnline;
  final LatLng? location;
  final String? locationName;
  final String? detailedAddress;
  final int minParticipants;
  final int maxParticipants;
  final MeetingType meetingType;
  final double? price;
  final bool isFirstComeFirstServed;
  final List<File> photos;
  final String title;
  final String description;
  final DateTime? dateTime;
  final List<String> tags;
  final List<String> requirements;
  final List<String> preparationItems;

  const MeetingCreationData({
    this.selectedCategory,
    this.scope = MeetingScope.public,
    this.isOnline = true,
    this.location,
    this.locationName,
    this.detailedAddress,
    this.minParticipants = 2,
    this.maxParticipants = 10,
    this.meetingType = MeetingType.free,
    this.price,
    this.isFirstComeFirstServed = true,
    this.photos = const [],
    this.title = '',
    this.description = '',
    this.dateTime,
    this.tags = const [],
    this.requirements = const [],
    this.preparationItems = const [],
  });

  MeetingCreationData copyWith({
    MeetingCategory? selectedCategory,
    MeetingScope? scope,
    bool? isOnline,
    LatLng? location,
    String? locationName,
    String? detailedAddress,
    int? minParticipants,
    int? maxParticipants,
    MeetingType? meetingType,
    double? price,
    bool? isFirstComeFirstServed,
    List<File>? photos,
    String? title,
    String? description,
    DateTime? dateTime,
    List<String>? tags,
    List<String>? requirements,
    List<String>? preparationItems,
  }) {
    return MeetingCreationData(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      scope: scope ?? this.scope,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      detailedAddress: detailedAddress ?? this.detailedAddress,
      minParticipants: minParticipants ?? this.minParticipants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      meetingType: meetingType ?? this.meetingType,
      price: price ?? this.price,
      isFirstComeFirstServed:
          isFirstComeFirstServed ?? this.isFirstComeFirstServed,
      photos: photos ?? this.photos,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      requirements: requirements ?? this.requirements,
      preparationItems: preparationItems ?? this.preparationItems,
    );
  }

  bool isStep1Valid() => selectedCategory != null;

  bool isStep2Valid() {
    if (isOnline) return true;
    return location != null && locationName?.isNotEmpty == true;
  }

  bool isStep3Valid() {
    if (meetingType == MeetingType.paid) {
      return price != null && price! >= 3000;
    }
    return minParticipants >= 2 &&
        maxParticipants >= minParticipants &&
        maxParticipants <= 50;
  }

  bool isStep4Valid() {
    return title.isNotEmpty &&
        title.length >= 5 &&
        description.isNotEmpty &&
        description.length >= 10 &&
        dateTime != null;
  }

  bool isAllDataValid() {
    return isStep1Valid() && isStep2Valid() && isStep3Valid() && isStep4Valid();
  }

  Future<AvailableMeeting> toAvailableMeeting({
    required String hostId,
    required String hostName,
  }) async {
    final meetingId = DateTime.now().millisecondsSinceEpoch.toString();

    final savedImageFileNames = await MeetingImageUtils.saveMeetingImages(
      tempFiles: photos,
      meetingId: meetingId,
    );

    return AvailableMeeting(
      id: meetingId,
      title: title,
      description: description,
      category: selectedCategory!,
      type: meetingType,
      scope: scope,
      dateTime: dateTime!,
      location: isOnline ? '온라인' : (locationName ?? ''),
      detailedLocation: detailedAddress ?? '',
      maxParticipants: maxParticipants,
      currentParticipants: 1,
      price: meetingType == MeetingType.paid ? price : null,
      hostName: hostName,
      hostId: hostId,
      tags: tags,
      requirements: requirements,
      preparationItems: preparationItems,
      imageFileNames: savedImageFileNames,
    );
  }
}

class _MeetingCreationNotifier extends StateNotifier<MeetingCreationData> {
  _MeetingCreationNotifier() : super(const MeetingCreationData());

  void selectCategory(MeetingCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setScope(MeetingScope scope) {
    state = state.copyWith(scope: scope);
  }

  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(
      isOnline: isOnline,
      location: isOnline ? null : state.location,
      locationName: isOnline ? null : state.locationName,
      detailedAddress: isOnline ? null : state.detailedAddress,
    );
  }

  void setLocation(
    LatLng location,
    String locationName, [
    String? detailedAddress,
  ]) {
    state = state.copyWith(
      location: location,
      locationName: locationName,
      detailedAddress: detailedAddress,
    );
  }

  void setParticipants(int min, int max) {
    state = state.copyWith(
      minParticipants: min,
      maxParticipants: max,
    );
  }

  void setMeetingType(MeetingType type, [double? price]) {
    state = state.copyWith(
      meetingType: type,
      price: type == MeetingType.paid ? (price ?? 3000) : null,
    );
  }

  void setRegistrationMethod(bool isFirstComeFirstServed) {
    state = state.copyWith(isFirstComeFirstServed: isFirstComeFirstServed);
  }

  void addPhoto(File photo) {
    final photos = List<File>.from(state.photos);
    if (photos.length < 5) {
      photos.add(photo);
      state = state.copyWith(photos: photos);
    }
  }

  void removePhoto(int index) {
    final photos = List<File>.from(state.photos);
    if (index >= 0 && index < photos.length) {
      photos.removeAt(index);
      state = state.copyWith(photos: photos);
    }
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setDateTime(DateTime dateTime) {
    state = state.copyWith(dateTime: dateTime);
  }

  void addTag(String tag) {
    final tags = List<String>.from(state.tags);
    if (!tags.contains(tag) && tags.length < 10) {
      tags.add(tag);
      state = state.copyWith(tags: tags);
    }
  }

  void removeTag(String tag) {
    final tags = List<String>.from(state.tags)..remove(tag);
    state = state.copyWith(tags: tags);
  }

  void addPreparationItem(String item) {
    final items = List<String>.from(state.preparationItems);
    if (!items.contains(item) && items.length < 10) {
      items.add(item);
      state = state.copyWith(preparationItems: items);
    }
  }

  void removePreparationItem(String item) {
    final items = List<String>.from(state.preparationItems)..remove(item);
    state = state.copyWith(preparationItems: items);
  }

  void reset() {
    state = const MeetingCreationData();
  }

  String? validateStep(int stepNumber) {
    switch (stepNumber) {
      case 1:
        if (!state.isStep1Valid()) {
          return '카테고리를 선택해주세요';
        }
        break;
      case 2:
        if (!state.isStep2Valid()) {
          return state.isOnline ? null : '모임 장소를 설정해주세요';
        }
        break;
      case 3:
        if (!state.isStep3Valid()) {
          if (state.meetingType == MeetingType.paid) {
            return '참가비는 3000P 이상 설정해주세요';
          }
          return '참가자 인원을 올바르게 설정해주세요';
        }
        break;
      case 4:
        if (!state.isStep4Valid()) {
          if (state.title.isEmpty || state.title.length < 5) {
            return '모임 제목은 5글자 이상 입력해주세요';
          }
          if (state.description.isEmpty || state.description.length < 10) {
            return '모임 설명은 10글자 이상 입력해주세요';
          }
          if (state.dateTime == null) {
            return '모임 날짜와 시간을 설정해주세요';
          }
        }
        break;
    }
    return null;
  }
}

final _meetingCreationProvider = StateNotifierProvider.autoDispose<
    _MeetingCreationNotifier, MeetingCreationData>(
  (ref) => _MeetingCreationNotifier(),
);

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
            const SliverToBoxAdapter(
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
                          ModernColors.primary.withValues(alpha: 0.6),
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
                      )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 300))
                          .slideX(
                              begin: -0.05,
                              end: 0,
                              duration: const Duration(milliseconds: 300)),
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
                        ).animate().fadeIn(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: ModernColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primary.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
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
            const Icon(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ModernColors.primary.withValues(alpha: 0.1),
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
                    showDivider:
                        index < math.min(_filteredMeetings.length, 5) - 1,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ModernColors.primary.withValues(alpha: 0.3),
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
                      child: const Icon(
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
      case '최신순':
        return 'recent';
      case '인기순':
        return 'popular';
      case '프리미엄':
        return 'premium';
      case '무료만':
        return 'free_only';
      case '온라인':
        return 'online';
      default:
        return null;
    }
  }

  // 스마트 필터 칩 빌더
  Widget _buildSmartFilterChip(
      String label, bool isActive, VoidCallback onTap) {
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
                    ModernColors.primary.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? ModernColors.primary : ModernColors.border,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: ModernColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
  Widget _buildOptimizedPopularCardWithCache(
      AvailableMeeting meeting, int index) {
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
                    Colors.black.withValues(alpha: 0.7),
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
                      color: Colors.white.withValues(alpha: 0.8),
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
  Widget _buildOptimizedPopularCard(
      AvailableMeeting meeting, String? imagePath, int index) {
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
                    Colors.black.withValues(alpha: 0.7),
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
                      color: Colors.white.withValues(alpha: 0.8),
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
                onBookmark: () =>
                    _handleBookmarkTap(recommendedMeetings[index]),
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
                      color: isSelected
                          ? category.color.withValues(alpha: 0.1)
                          : ModernColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? category.color
                            : ModernColors.borderLight,
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
                            color: isSelected
                                ? category.color
                                : ModernColors.textSecondary,
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
                              color: Colors.black.withValues(alpha: 0.05),
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
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: ModernColors.textSecondary,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
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
                          color: _showOnlineOnly
                              ? ModernColors.primary
                              : Colors.white,
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
                                      : Colors.black)
                                  .withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.videocam_rounded,
                              color: _showOnlineOnly
                                  ? Colors.white
                                  : ModernColors.textSecondary,
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
                                          : Colors.black)
                                      .withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _showFilters
                                  ? Icons.filter_list_off_rounded
                                  : Icons.filter_list_rounded,
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
                              decoration: const BoxDecoration(
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
    ).animate().fadeIn(
        duration: const Duration(milliseconds: 400),
        delay: const Duration(milliseconds: 200));
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
              ? ModernColors.primary.withValues(alpha: 0.1)
              : ModernColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? ModernColors.primary : ModernColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isActive ? ModernColors.primary : ModernColors.textSecondary,
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
              const Icon(
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
                  {
                    'key': 'weekend',
                    'label': '이번 주말',
                    'icon': Icons.weekend_rounded,
                    'color': Colors.orange
                  },
                  {
                    'key': 'free',
                    'label': '무료',
                    'icon': Icons.money_off_rounded,
                    'color': Colors.green
                  },
                  {
                    'key': 'today',
                    'label': '오늘',
                    'icon': Icons.today_rounded,
                    'color': Colors.blue
                  },
                  {
                    'key': 'nearby',
                    'label': '내 주변',
                    'icon': Icons.near_me_rounded,
                    'color': Colors.indigo
                  },
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (filter['color'] as Color).withValues(alpha: 0.1)
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
                          color: Colors.black.withValues(alpha: 0.05),
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
          color:
              isActive ? ModernColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? ModernColors.primary : ModernColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? ModernColors.primary : ModernColors.textSecondary,
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
                    side: const BorderSide(color: ModernColors.border),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ModernColors.primary.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected ? ModernColors.primary : ModernColors.border,
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
                    colorScheme: const ColorScheme.light(
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
                  ? ModernColors.primary.withValues(alpha: 0.1)
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
                    child: const Icon(
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
                  'category': _selectedCategory == MeetingCategory.all
                      ? null
                      : _selectedCategory,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          const Icon(
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
            color: ModernColors.primary.withValues(alpha: 0.25),
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
      builder: (context) => const _MeetingCreationSheet(),
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
        final imageFile =
            await MeetingImageUtils.getMeetingImageFile(firstImage);
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
    return !path.startsWith('assets/') &&
        (path.contains('/') || path.endsWith('.jpg') || path.endsWith('.png'));
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
            categoryColor.withValues(alpha: 0.8),
            categoryColor.withValues(alpha: 0.6),
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
      filtered = filtered
          .where((m) =>
              m.title.toLowerCase().contains(query) ||
              m.description.toLowerCase().contains(query) ||
              m.location.toLowerCase().contains(query) ||
              m.category.displayName.toLowerCase().contains(query) ||
              m.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }

    // 카테고리 필터
    if (_selectedCategory != MeetingCategory.all) {
      filtered =
          filtered.where((m) => m.category == _selectedCategory).toList();
    }

    // 온라인 전용 필터
    if (_showOnlineOnly) {
      filtered = filtered
          .where((m) =>
              m.location.toLowerCase().contains('온라인') ||
              m.location.toLowerCase().contains('online') ||
              m.location.toLowerCase().contains('줌') ||
              m.location.toLowerCase().contains('zoom'))
          .toList();
    }

    // 지역 필터
    if (_selectedLocation != null) {
      switch (_selectedLocation) {
        case 'online':
          filtered = filtered
              .where((m) =>
                  m.location.toLowerCase().contains('온라인') ||
                  m.location.toLowerCase().contains('online'))
              .toList();
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
          filtered = filtered
              .where((m) =>
                  m.participationFee >= 10000 && m.participationFee <= 40000)
              .toList();
          break;
        case 'over_40k':
          filtered = filtered.where((m) => m.participationFee > 40000).toList();
          break;
      }
    }

    // 날짜 범위 필터
    if (_selectedDateRange != null) {
      filtered = filtered
          .where((m) =>
              m.dateTime.isAfter(_selectedDateRange!.start
                  .subtract(const Duration(days: 1))) &&
              m.dateTime.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1))))
          .toList();
    }

    // 빠른 필터들 적용
    for (final filter in _activeQuickFilters) {
      switch (filter) {
        case 'weekend':
          // 이번 주말 (토요일, 일요일)
          final now = DateTime.now();
          final thisWeekend = now.add(Duration(days: (6 - now.weekday) % 7));
          final nextSunday = thisWeekend.add(const Duration(days: 1));
          filtered = filtered
              .where((m) =>
                  (m.dateTime.weekday == DateTime.saturday ||
                      m.dateTime.weekday == DateTime.sunday) &&
                  m.dateTime
                      .isAfter(thisWeekend.subtract(const Duration(days: 1))) &&
                  m.dateTime.isBefore(nextSunday.add(const Duration(days: 1))))
              .toList();
          break;
        case 'free':
          filtered = filtered.where((m) => m.type == MeetingType.free).toList();
          break;
        case 'today':
          final today = DateTime.now();
          filtered = filtered
              .where((m) =>
                  m.dateTime.year == today.year &&
                  m.dateTime.month == today.month &&
                  m.dateTime.day == today.day)
              .toList();
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
          filtered.sort(
              (a, b) => b.currentParticipants.compareTo(a.currentParticipants));
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
      arguments: {'meetingId': meeting.id},
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

// ===== Inlined meeting creation sheet =====
/// 📝 모임 생성 다이얼로그 - 간소화된 4단계 프로세스
/// 문토 스타일의 직관적이고 빠른 모임 생성 경험
class _MeetingCreationSheet extends ConsumerStatefulWidget {
  const _MeetingCreationSheet();

  @override
  ConsumerState<_MeetingCreationSheet> createState() =>
      _MeetingCreationSheetState();
}

class _MeetingCreationSheetState extends ConsumerState<_MeetingCreationSheet>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // 단계별 타이틀
  final List<String> _stepTitles = [
    '어떤 모임인가요?',
    '모임 정보를 알려주세요',
    '언제 만날까요?',
    '마지막 확인',
  ];

  // 단계별 아이콘
  final List<IconData> _stepIcons = [
    Icons.category_rounded,
    Icons.edit_rounded,
    Icons.calendar_today_rounded,
    Icons.check_circle_rounded,
  ];

  @override
  void initState() {
    super.initState();

    // 모임 생성 시작 시 셰르피 안내 제거 - 최종 완료 시에만 메시지 표시
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creationData = ref.watch(_meetingCreationProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // 🎯 핸들바
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 📊 진행률 표시
          _buildProgressIndicator(),

          // 📝 단계별 콘텐츠
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _QuickCategorySelector(
                  selectedCategory: creationData.selectedCategory,
                  onCategorySelected: (category) {
                    ref
                        .read(_meetingCreationProvider.notifier)
                        .selectCategory(category);
                    _goToNextStep();
                  },
                ),
                _QuickDetailsForm(
                  data: creationData,
                  onComplete: () => _goToNextStep(),
                ),
                _QuickDateTimePicker(
                  selectedDateTime: creationData.dateTime,
                  onDateTimeSelected: (dateTime) {
                    ref
                        .read(_meetingCreationProvider.notifier)
                        .setDateTime(dateTime);
                    _goToNextStep();
                  },
                ),
                _QuickFinalReview(
                  data: creationData,
                  onComplete: _createMeeting,
                ),
              ],
            ),
          ),

          // 🔄 네비게이션 버튼
          _buildNavigationButtons(creationData),
        ],
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  /// 📊 진행률 표시
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // 단계 표시
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    // 단계 아이콘
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive
                            ? ModernColors.primary
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : Text(
                                '${index + 1}',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? Colors.white
                                      : ModernColors.textSecondary,
                                ),
                              ),
                      ),
                    ),

                    // 연결선
                    if (index < 3)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? ModernColors.primary
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),

        // 현재 단계 제목
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _stepIcons[_currentStep],
                color: ModernColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _stepTitles[_currentStep],
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        Divider(
          color: Colors.grey.shade200,
          height: 1,
        ),
      ],
    );
  }

  /// 🔄 네비게이션 버튼
  Widget _buildNavigationButtons(MeetingCreationData data) {
    final canProceed = _canProceed(data);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          // 이전 버튼
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '이전',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 12),

          // 다음/완료 버튼
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: canProceed
                  ? (_currentStep == 3 ? _createMeeting : _goToNextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 3 ? '모임 만들기' : '다음',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 진행 가능 여부 확인
  bool _canProceed(MeetingCreationData data) {
    switch (_currentStep) {
      case 0:
        return data.selectedCategory != null;
      case 1:
        return data.title.isNotEmpty &&
            data.description.isNotEmpty &&
            data.title.length >= 5 &&
            data.description.length >= 10;
      case 2:
        return data.dateTime != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  /// ⏭️ 다음 단계로
  void _goToNextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // 햅틱 피드백
      HapticFeedback.lightImpact();

      // 단계별 셰르피 메시지
      _showStepMessage(_currentStep + 1);
    }
  }

  /// ⏮️ 이전 단계로
  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // 햅틱 피드백
      HapticFeedback.lightImpact();
    }
  }

  /// 💬 단계별 셰르피 메시지
  void _showStepMessage(int step) {
    String message;
    SherpiEmotion emotion;

    switch (step) {
      case 1:
        message = '좋아요! 이제 모임 정보를 입력해주세요 📝';
        emotion = SherpiEmotion.happy;
        break;
      case 2:
        message = '거의 다 왔어요! 날짜와 시간을 정해볼까요? 📅';
        emotion = SherpiEmotion.cheering;
        break;
      case 3:
        message = '마지막으로 한 번 확인해주세요! 완벽한 모임이 될 거예요 ✨';
        emotion = SherpiEmotion.guiding;
        break;
      default:
        return;
    }

    // 단계 전환 시 셰르피 메시지 제거 - 최종 완료 시에만 표시
  }

  /// ✅ 모임 생성
  void _createMeeting() async {
    try {
      final meetingData = ref.read(_meetingCreationProvider);
      final user = ref.read(globalUserProvider);

      // 데이터 유효성 검사
      if (!meetingData.isAllDataValid()) {
        _showError('모임 정보를 모두 입력해주세요.');
        return;
      }

      // AvailableMeeting으로 변환 (async 메서드)
      final newMeeting = await meetingData.toAvailableMeeting(
        hostId: user.id,
        hostName: user.name,
      );

      // GlobalMeetingProvider에 추가
      final success =
          await ref.read(globalMeetingProvider.notifier).addMeeting(newMeeting);

      if (success) {
        // 성공 피드백 - 모임 개설 전용 컨텍스트 사용
        ref.read(sherpiProvider.notifier).showMessage(
              context: SherpiContext.meetingCreated, // 모임 개설 전용 컨텍스트
              // emotion 파라미터 제거 - contextEmotionMap에서 자동으로 special 감정 사용
              userContext: {
                'meetingTitle': newMeeting.title,
                'category': newMeeting.category.displayName,
                'maxParticipants': newMeeting.maxParticipants,
              },
              duration: const Duration(seconds: 5),
            );

        // MeetingCreationData 초기화
        ref.read(_meetingCreationProvider.notifier).reset();

        // 다이얼로그 닫기
        if (mounted) Navigator.pop(context);

        // 생성된 모임 상세 화면으로 이동
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/meeting_detail',
            arguments: {'meetingId': newMeeting.id},
          );
        }
      } else {
        _showError('모임 생성에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      // Error creating meeting: $e
      _showError('모임 생성 중 오류가 발생했습니다.');
    }
  }

  /// 에러 메시지 표시
  void _showError(String message) {
    ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.tiredWarning,
          customDialogue: message,
          emotion: SherpiEmotion.warning,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// 🎯 빠른 카테고리 선택 - Step 1
/// 직관적인 그리드 레이아웃으로 카테고리 선택
class _QuickCategorySelector extends StatelessWidget {
  final MeetingCategory? selectedCategory;
  final Function(MeetingCategory) onCategorySelected;

  const _QuickCategorySelector({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // 전체 카테고리 제외하고 표시
    final categories = MeetingCategory.values
        .where((cat) => cat != MeetingCategory.all)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설명 텍스트
          Text(
            '모임의 종류를 선택해주세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // 카테고리 그리드
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return GestureDetector(
                  onTap: () => onCategorySelected(category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? category.color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? category.color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: category.color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 이모지
                        Text(
                          category.emoji,
                          style: TextStyle(
                            fontSize: isSelected ? 48 : 40,
                          ),
                        ).animate(target: isSelected ? 1 : 0).scale(
                              duration: 200.ms,
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                            ),

                        const SizedBox(height: 12),

                        // 카테고리 이름
                        Text(
                          category.displayName,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : ModernColors.textPrimary,
                          ),
                        ),

                        // 선택 체크 마크
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 100 * index),
                        duration: 300.ms,
                      )
                      .scale(
                        delay: Duration(milliseconds: 100 * index),
                        duration: 200.ms,
                      ),
                );
              },
            ),
          ),

          // 팁 텍스트
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: ModernColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '카테고리에 맞는 사람들이 모임을 발견하기 쉬워져요',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: ModernColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 📝 빠른 모임 정보 입력 - Step 2
/// 필수 정보만 간단하게 입력하는 심플한 폼
class _QuickDetailsForm extends ConsumerStatefulWidget {
  final MeetingCreationData data;
  final VoidCallback onComplete;

  const _QuickDetailsForm({
    required this.data,
    required this.onComplete,
  });

  @override
  ConsumerState<_QuickDetailsForm> createState() => _QuickDetailsFormState();
}

class _QuickDetailsFormState extends ConsumerState<_QuickDetailsForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isOnline = true;
  int _minParticipants = 2;
  int _maxParticipants = 10;
  MeetingType _meetingType = MeetingType.free;
  double _price = 5000;
  MeetingScope _selectedScope = MeetingScope.public;

  // 태그와 준비물
  final List<String> _tags = [];
  final List<String> _preparationItems = [];
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _preparationController = TextEditingController();

  // 이미지 선택
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // 기존 데이터 로드
    _titleController.text = widget.data.title;
    _descriptionController.text = widget.data.description;
    _locationController.text = widget.data.locationName ?? '';
    _isOnline = widget.data.isOnline;
    _minParticipants = widget.data.minParticipants;
    _maxParticipants = widget.data.maxParticipants;
    _meetingType = widget.data.meetingType;
    _price = widget.data.price ?? 5000;
    _selectedScope = widget.data.scope;
    _tags.addAll(widget.data.tags);
    _preparationItems.addAll(widget.data.preparationItems);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    _preparationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(_meetingCreationProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌍 공개범위 선택
          _buildScopeSection(notifier)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 20),

          // 📝 제목
          _buildTextField(
            label: '모임 제목',
            controller: _titleController,
            hint: '예: 주말 한강 러닝 모임',
            maxLength: 30,
            onChanged: (value) => notifier.setTitle(value),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 20),

          // 📄 설명
          _buildTextField(
            label: '모임 설명',
            controller: _descriptionController,
            hint: '모임에 대한 간단한 소개를 작성해주세요',
            maxLines: 3,
            maxLength: 200,
            onChanged: (value) => notifier.setDescription(value),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 24),

          // 📍 장소 선택
          _buildLocationSection(notifier)
              .animate()
              .fadeIn(delay: 200.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 24),

          // 👥 참가 인원
          _buildParticipantsSection(notifier)
              .animate()
              .fadeIn(delay: 300.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 24),

          // 💰 참가비
          _buildPriceSection(notifier)
              .animate()
              .fadeIn(delay: 400.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 24),

          // 🏷️ 태그 (선택)
          _buildTagsSection(notifier)
              .animate()
              .fadeIn(delay: 500.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 24),

          // 🎒 준비물 (선택)
          _buildPreparationSection(notifier)
              .animate()
              .fadeIn(delay: 600.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 24),

          // 📷 이미지 업로드 (선택)
          _buildImageUploadSection(notifier)
              .animate()
              .fadeIn(delay: 700.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),
        ],
      ),
    );
  }

  /// 📝 텍스트 필드
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: ModernColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ModernColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: GoogleFonts.notoSans(
              fontSize: 12,
              color: ModernColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 🌍 공개범위 섹션
  Widget _buildScopeSection(_MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '공개 범위',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // 전체공개/학교공개 선택
        Row(
          children: [
            _buildScopeOption(
              label: '전체 공개',
              description: '누구나 참여 가능',
              icon: Icons.public_rounded,
              isSelected: _selectedScope == MeetingScope.public,
              onTap: () {
                setState(() => _selectedScope = MeetingScope.public);
                notifier.setScope(MeetingScope.public);
              },
            ),
            const SizedBox(width: 12),
            _buildScopeOption(
              label: '학교 공개',
              description: '같은 학교만',
              icon: Icons.school_rounded,
              isSelected: _selectedScope == MeetingScope.university,
              onTap: () {
                setState(() => _selectedScope = MeetingScope.university);
                notifier.setScope(MeetingScope.university);
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 📍 장소 섹션
  Widget _buildLocationSection(_MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 장소',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // 온라인/오프라인 토글
        Row(
          children: [
            _buildToggleButton(
              label: '온라인',
              icon: Icons.videocam_rounded,
              isSelected: _isOnline,
              onTap: () {
                setState(() => _isOnline = true);
                notifier.setOnlineStatus(true);
              },
            ),
            const SizedBox(width: 12),
            _buildToggleButton(
              label: '오프라인',
              icon: Icons.location_on_rounded,
              isSelected: !_isOnline,
              onTap: () {
                setState(() => _isOnline = false);
                notifier.setOnlineStatus(false);
              },
            ),
          ],
        ),

        // 오프라인 장소 입력
        if (!_isOnline) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            onChanged: (value) {
              // 간단한 장소 입력만 받음
              notifier.setLocation(
                const LatLng(37.5665, 126.9780), // 서울 기본 좌표
                value,
              );
            },
            style: GoogleFonts.notoSans(fontSize: 14),
            decoration: InputDecoration(
              hintText: '예: 강남역 스타벅스',
              hintStyle: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ModernColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ],
    );
  }

  /// 👥 참가 인원 섹션
  Widget _buildParticipantsSection(_MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참가 인원 설정',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // 최소 참가 인원
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최소 참가 인원',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: ModernColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: ModernColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$_minParticipants명',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 최소 인원 슬라이더
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: ModernColors.primary,
            inactiveTrackColor: ModernColors.primary.withValues(alpha: 0.2),
            thumbColor: ModernColors.primary,
            overlayColor: ModernColors.primary.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
          ),
          child: Slider(
            value: _minParticipants.toDouble(),
            min: 2,
            max: _maxParticipants.toDouble() - 1,
            divisions: _maxParticipants - 3,
            onChanged: (value) {
              setState(() => _minParticipants = value.toInt());
              notifier.setParticipants(value.toInt(), _maxParticipants);
              HapticFeedback.lightImpact();
            },
          ),
        ),

        const SizedBox(height: 20),

        // 최대 참가 인원
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최대 참가 인원',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: ModernColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: ModernColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$_maxParticipants명',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 최대 인원 슬라이더
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: ModernColors.primary,
            inactiveTrackColor: ModernColors.primary.withValues(alpha: 0.2),
            thumbColor: ModernColors.primary,
            overlayColor: ModernColors.primary.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
          ),
          child: Slider(
            value: _maxParticipants.toDouble(),
            min: _minParticipants.toDouble() + 1,
            max: 50,
            divisions: 50 - _minParticipants - 1,
            onChanged: (value) {
              setState(() => _maxParticipants = value.toInt());
              notifier.setParticipants(_minParticipants, value.toInt());
              HapticFeedback.lightImpact();
            },
          ),
        ),

        // 인원 안내
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '최소 $_minParticipants명이 모이면 모임이 확정되고, 최대 $_maxParticipants명까지 참여할 수 있어요',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 💰 참가비 섹션
  Widget _buildPriceSection(_MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참가비',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // 무료/유료 선택
        Row(
          children: [
            _buildPriceOption(
              label: '무료',
              description: '참가 수수료 1,000P',
              isSelected: _meetingType == MeetingType.free,
              onTap: () {
                setState(() => _meetingType = MeetingType.free);
                notifier.setMeetingType(MeetingType.free);
              },
            ),
            const SizedBox(width: 12),
            _buildPriceOption(
              label: '유료',
              description: '직접 설정',
              isSelected: _meetingType == MeetingType.paid,
              onTap: () {
                setState(() => _meetingType = MeetingType.paid);
                notifier.setMeetingType(MeetingType.paid, _price);
              },
            ),
          ],
        ),

        // 유료 가격 설정
        if (_meetingType == MeetingType.paid) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '참가비 금액',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: ModernColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_price.toInt().toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )}P',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 가격 슬라이더
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ModernColors.primary,
              inactiveTrackColor: ModernColors.primary.withValues(alpha: 0.2),
              thumbColor: ModernColors.primary,
              overlayColor: ModernColors.primary.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
              ),
            ),
            child: Slider(
              value: _price,
              min: 3000,
              max: 50000,
              divisions: 47,
              onChanged: (value) {
                setState(() => _price = value);
                notifier.setMeetingType(MeetingType.paid, value);
                HapticFeedback.lightImpact();
              },
            ),
          ),

          // 가격 안내
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: ModernColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '참가자는 설정한 금액 전체를 결제합니다',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: ModernColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 🔘 토글 버튼
  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? ModernColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? ModernColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : ModernColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : ModernColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 💰 가격 옵션
  Widget _buildPriceOption({
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? ModernColors.primary.withValues(alpha: 0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? ModernColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? ModernColors.primary
                      : ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: isSelected
                      ? ModernColors.primary
                      : ModernColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🌍 공개범위 옵션
  Widget _buildScopeOption({
    required String label,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? ModernColors.primary.withValues(alpha: 0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? ModernColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? ModernColors.primary
                    : ModernColors.textSecondary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? ModernColors.primary
                      : ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: isSelected
                      ? ModernColors.primary
                      : ModernColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏷️ 태그 섹션
  Widget _buildTagsSection(_MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '태그 (선택)',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            Text(
              '${_tags.length}/10',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 태그 입력
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                onSubmitted: (value) => _addTag(value, notifier),
                style: GoogleFonts.notoSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '태그를 입력하세요 (예: 초보환영, 주말)',
                  hintStyle: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ModernColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addTag(_tagController.text, notifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                '추가',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // 태그 목록
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags
                .map((tag) => Chip(
                      label: Text(
                        tag,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: ModernColors.primary,
                        ),
                      ),
                      backgroundColor: ModernColors.primary.withValues(alpha: 0.1),
                      deleteIcon: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: ModernColors.primary,
                      ),
                      onDeleted: () => _removeTag(tag, notifier),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: ModernColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  /// 🎒 준비물 섹션
  Widget _buildPreparationSection(_MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '준비물 (선택)',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            Text(
              '${_preparationItems.length}/10',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 준비물 입력
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _preparationController,
                onSubmitted: (value) => _addPreparationItem(value, notifier),
                style: GoogleFonts.notoSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '준비물을 입력하세요 (예: 운동화, 물병)',
                  hintStyle: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ModernColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () =>
                  _addPreparationItem(_preparationController.text, notifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                '추가',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // 준비물 목록
        if (_preparationItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.backpack_outlined,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '참가자가 준비해야 할 것들',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _preparationItems
                      .map((item) => Chip(
                            label: Text(
                              item,
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            deleteIcon: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            onDeleted: () =>
                                _removePreparationItem(item, notifier),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Colors.orange.shade300,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 태그 추가
  void _addTag(String tag, _MeetingCreationNotifier notifier) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty &&
        _tags.length < 10 &&
        !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
      notifier.addTag(trimmedTag);
      HapticFeedback.lightImpact();
    }
  }

  // 태그 제거
  void _removeTag(String tag, _MeetingCreationNotifier notifier) {
    setState(() {
      _tags.remove(tag);
    });
    notifier.removeTag(tag);
    HapticFeedback.lightImpact();
  }

  // 준비물 추가
  void _addPreparationItem(String item, _MeetingCreationNotifier notifier) {
    final trimmedItem = item.trim();
    if (trimmedItem.isNotEmpty &&
        _preparationItems.length < 10 &&
        !_preparationItems.contains(trimmedItem)) {
      setState(() {
        _preparationItems.add(trimmedItem);
        _preparationController.clear();
      });
      notifier.addPreparationItem(trimmedItem);
      HapticFeedback.lightImpact();
    }
  }

  // 준비물 제거
  void _removePreparationItem(String item, _MeetingCreationNotifier notifier) {
    setState(() {
      _preparationItems.remove(item);
    });
    notifier.removePreparationItem(item);
    HapticFeedback.lightImpact();
  }

  /// 📷 이미지 업로드 섹션
  Widget _buildImageUploadSection(_MeetingCreationNotifier notifier) {
    final data = ref.watch(_meetingCreationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '이미지 업로드 (선택)',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            Text(
              '${data.photos.length}/5',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 이미지 그리드
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: data.photos.isEmpty
              ? _buildEmptyImageState(notifier)
              : _buildImageGrid(data.photos, notifier),
        ),

        // 이미지 안내
        if (data.photos.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 16,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '업로드된 이미지는 모임 상세 페이지에 표시됩니다',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 빈 이미지 상태
  Widget _buildEmptyImageState(_MeetingCreationNotifier notifier) {
    return InkWell(
      onTap: () => _pickImage(notifier),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              '이미지 추가',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '모임을 소개할 이미지를 추가해보세요',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 그리드
  Widget _buildImageGrid(List<File> photos, _MeetingCreationNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 이미지 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: photos.length + (photos.length < 5 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == photos.length) {
                // 추가 버튼
                return _buildAddImageButton(notifier);
              }

              // 이미지 아이템
              return _buildImageItem(photos[index], index, notifier);
            },
          ),
        ],
      ),
    );
  }

  /// 이미지 추가 버튼
  Widget _buildAddImageButton(_MeetingCreationNotifier notifier) {
    return InkWell(
      onTap: () => _pickImage(notifier),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 24,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              '추가',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 아이템
  Widget _buildImageItem(
      File image, int index, _MeetingCreationNotifier notifier) {
    return Stack(
      children: [
        // 이미지
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 삭제 버튼
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index, notifier),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        // 대표 이미지 표시
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ModernColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '대표',
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 이미지 선택
  Future<void> _pickImage(_MeetingCreationNotifier notifier) async {
    final data = ref.read(_meetingCreationProvider);

    if (data.photos.length >= 5) {
      _showSnackBar('이미지는 최대 5개까지 업로드할 수 있습니다');
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        notifier.addPhoto(File(image.path));
        HapticFeedback.lightImpact();
        _showSnackBar('이미지가 추가되었습니다');
      }
    } catch (e) {
      _showSnackBar('이미지를 불러올 수 없습니다');
    }
  }

  // 이미지 제거
  void _removeImage(int index, _MeetingCreationNotifier notifier) {
    notifier.removePhoto(index);
    HapticFeedback.lightImpact();
    _showSnackBar('이미지가 제거되었습니다');
  }

  // 스낵바 표시
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          backgroundColor: ModernColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

/// 📅 빠른 날짜/시간 선택 - Step 3
/// 직관적인 캘린더와 시간 선택 UI
class _QuickDateTimePicker extends StatefulWidget {
  final DateTime? selectedDateTime;
  final Function(DateTime) onDateTimeSelected;

  const _QuickDateTimePicker({
    required this.selectedDateTime,
    required this.onDateTimeSelected,
  });

  @override
  State<_QuickDateTimePicker> createState() => _QuickDateTimePickerState();
}

class _QuickDateTimePickerState extends State<_QuickDateTimePicker> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = const TimeOfDay(hour: 14, minute: 0);

  // 빠른 선택 옵션
  final List<Map<String, dynamic>> quickOptions = [
    {
      'label': '내일 오후 2시',
      'date': DateTime.now().add(const Duration(days: 1)),
      'time': const TimeOfDay(hour: 14, minute: 0),
    },
    {
      'label': '이번 주말 오전 10시',
      'date': DateTime.now().add(Duration(
        days: 6 - DateTime.now().weekday,
      )),
      'time': const TimeOfDay(hour: 10, minute: 0),
    },
    {
      'label': '다음 주 월요일 오후 7시',
      'date': DateTime.now().add(Duration(
        days: 8 - DateTime.now().weekday,
      )),
      'time': const TimeOfDay(hour: 19, minute: 0),
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedDateTime != null) {
      selectedDate = widget.selectedDateTime!;
      selectedTime = TimeOfDay.fromDateTime(widget.selectedDateTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설명 텍스트
          Text(
            '모임 날짜와 시간을 선택해주세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // 빠른 선택 옵션
          _buildQuickOptions()
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 32),

          // 구분선
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '또는 직접 선택',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),

          const SizedBox(height: 32),

          // 날짜 선택
          _buildDateSelector()
              .animate()
              .fadeIn(delay: 100.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 24),

          // 시간 선택
          _buildTimeSelector()
              .animate()
              .fadeIn(delay: 200.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),

          const SizedBox(height: 32),

          // 선택된 날짜/시간 미리보기
          _buildPreview()
              .animate()
              .fadeIn(delay: 300.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 200.ms),
        ],
      ),
    );
  }

  /// ⚡ 빠른 선택 옵션
  Widget _buildQuickOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 선택',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...quickOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final dateTime = DateTime(
                    option['date'].year,
                    option['date'].month,
                    option['date'].day,
                    option['time'].hour,
                    option['time'].minute,
                  );

                  setState(() {
                    selectedDate = option['date'];
                    selectedTime = option['time'];
                  });

                  widget.onDateTimeSelected(dateTime);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ModernColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          color: ModernColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option['label'],
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: ModernColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 100 * index),
                duration: 300.ms,
              )
              .slideX(
                begin: 0.1,
                end: 0,
                delay: Duration(milliseconds: 100 * index),
                duration: 200.ms,
              );
        }),
      ],
    );
  }

  /// 📅 날짜 선택
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showDatePicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: ModernColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(selectedDate),
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: ModernColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ⏰ 시간 선택
  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시간',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // 인기 시간대 버튼들
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTimeChip('오전 10:00', const TimeOfDay(hour: 10, minute: 0)),
              _buildTimeChip('오후 2:00', const TimeOfDay(hour: 14, minute: 0)),
              _buildTimeChip('오후 6:00', const TimeOfDay(hour: 18, minute: 0)),
              _buildTimeChip('오후 7:00', const TimeOfDay(hour: 19, minute: 0)),
              _buildTimeChip('직접 선택', null),
            ],
          ),
        ),
      ],
    );
  }

  /// ⏰ 시간 칩
  Widget _buildTimeChip(String label, TimeOfDay? time) {
    final isSelected = time != null &&
        selectedTime.hour == time.hour &&
        selectedTime.minute == time.minute;
    final isCustom = time == null;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isCustom) {
              _showTimePicker();
            } else {
              setState(() => selectedTime = time);
              _updateDateTime();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected || isCustom
                  ? ModernColors.primary
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected || isCustom
                    ? ModernColors.primary
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              isCustom ? label : label,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected || isCustom
                    ? Colors.white
                    : ModernColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 👀 미리보기
  Widget _buildPreview() {
    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.primary.withValues(alpha: 0.1),
            ModernColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: ModernColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_rounded,
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
                      '모임 일정',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${_formatDate(selectedDate)} ${_formatTime(selectedTime)}',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 확인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onDateTimeSelected(dateTime),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '이 시간으로 확정',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📅 날짜 선택 다이얼로그
  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: ModernColors.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => selectedDate = date);
      _updateDateTime();
    }
  }

  /// ⏰ 시간 선택 다이얼로그
  void _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: ModernColors.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => selectedTime = time);
      _updateDateTime();
    }
  }

  /// 📅 날짜 포맷
  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];

    final now = DateTime.now();
    final daysDiff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (daysDiff == 0) {
      return '오늘 ($weekday)';
    } else if (daysDiff == 1) {
      return '내일 ($weekday)';
    } else if (daysDiff == 2) {
      return '모레 ($weekday)';
    } else {
      return '${date.month}월 ${date.day}일 ($weekday)';
    }
  }

  /// ⏰ 시간 포맷
  String _formatTime(TimeOfDay time) {
    final period = time.hour < 12 ? '오전' : '오후';
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final hourStr = hour == 0 ? 12 : hour;
    final minuteStr = time.minute.toString().padLeft(2, '0');

    return '$period $hourStr:$minuteStr';
  }

  /// 🔄 날짜/시간 업데이트
  void _updateDateTime() {
    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // 자동으로 다음 단계로 넘어가지 않고 미리보기만 업데이트
    setState(() {});
  }
}

/// ✅ 최종 검토 화면 - Step 4
/// 생성할 모임의 모든 정보를 한눈에 확인하는 요약 화면
class _QuickFinalReview extends StatelessWidget {
  final MeetingCreationData data;
  final VoidCallback onComplete;

  const _QuickFinalReview({
    required this.data,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 셰르피 축하 메시지
          _buildSherpiMessage()
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),

          const SizedBox(height: 24),

          // 모임 미리보기 카드
          _buildMeetingPreviewCard()
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),

          const SizedBox(height: 24),

          // 세부 정보
          _buildDetailsList()
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),

          const SizedBox(height: 32),

          // 생성 완료 버튼
          _buildCompleteButton()
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .scale(delay: 300.ms, duration: 200.ms),
        ],
      ),
    );
  }

  /// 🤖 셰르피 축하 메시지
  Widget _buildSherpiMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.primary.withValues(alpha: 0.1),
            ModernColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // 셰르피 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                SherpiEmotion.cheering.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 메시지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '와! 거의 다 완성됐어요! 🎉',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '마지막으로 한 번 확인하고 모임을 만들어볼까요?',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 모임 미리보기 카드
  Widget _buildMeetingPreviewCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더 이미지
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.selectedCategory!.color.withValues(alpha: 0.8),
                  data.selectedCategory!.color,
                ],
              ),
            ),
            child: Stack(
              children: [
                // 카테고리 이모지
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Text(
                    data.selectedCategory!.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),

                // 카테고리 태그
                Positioned(
                  left: 20,
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.selectedCategory!.displayName,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: data.selectedCategory!.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  data.title,
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // 설명
                Text(
                  data.description,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // 간단한 정보
                Row(
                  children: [
                    // 날짜
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: ModernColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(data.dateTime!),
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: ModernColors.textSecondary,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 참가비
                    const Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: ModernColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.price == null || data.price == 0
                          ? '무료'
                          : '${data.price!.toInt()}P',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: data.price == null || data.price == 0
                            ? ModernColors.success
                            : ModernColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 세부 정보 리스트
  Widget _buildDetailsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.checklist_rounded,
                  color: ModernColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '모임 상세 정보',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade200, height: 1),

          // 정보 항목들
          _buildDetailItem(
            icon: Icons.category_outlined,
            label: '카테고리',
            value: data.selectedCategory!.displayName,
            color: data.selectedCategory!.color,
          ),

          _buildDetailItem(
            icon: data.isOnline
                ? Icons.videocam_outlined
                : Icons.location_on_outlined,
            label: '장소',
            value: data.isOnline ? '온라인 모임' : (data.locationName ?? '미정'),
            color: ModernColors.secondary,
          ),

          _buildDetailItem(
            icon: Icons.group_outlined,
            label: '최대 참가 인원',
            value: '${data.maxParticipants}명',
            color: ModernColors.success,
          ),

          _buildDetailItem(
            icon: Icons.account_balance_wallet_outlined,
            label: '참가비',
            value: data.price == null || data.price == 0
                ? '무료 (수수료 1,000P)'
                : '${data.price!.toInt()}P',
            color: data.price == null || data.price == 0
                ? ModernColors.success
                : ModernColors.warning,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 📋 세부 정보 항목
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 완료 버튼
  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              '모임 만들기 완료!',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📅 날짜/시간 포맷
  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dateTime.weekday - 1];

    final now = DateTime.now();
    final daysDiff = DateTime(dateTime.year, dateTime.month, dateTime.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    String dateStr;
    if (daysDiff == 0) {
      dateStr = '오늘';
    } else if (daysDiff == 1) {
      dateStr = '내일';
    } else if (daysDiff == 2) {
      dateStr = '모레';
    } else {
      dateStr = '${dateTime.month}월 ${dateTime.day}일';
    }

    final period = dateTime.hour < 12 ? '오전' : '오후';
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final hourStr = hour == 0 ? 12 : hour;
    final minuteStr = dateTime.minute.toString().padLeft(2, '0');

    return '$dateStr ($weekday) $period $hourStr:$minuteStr';
  }
}
