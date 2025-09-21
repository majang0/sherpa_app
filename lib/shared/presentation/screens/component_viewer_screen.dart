import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/components/components.dart';
import '../../widgets/components/molecules/sherpa_smart_filter_2025.dart';
import '../../widgets/components/molecules/sherpa_quick_filter_2025.dart';
import '../../widgets/components/molecules/meeting_card_2025.dart';
import '../../widgets/components/molecules/meeting_card_list_2025.dart';
import '../../widgets/components/molecules/participant_avatars_2025.dart';
import '../../widgets/components/molecules/search_bar_2025.dart';
import '../../widgets/components/molecules/category_selector_2025.dart';
import '../../../../features/meetings/models/available_meeting_model.dart';

class ComponentViewerScreen extends StatefulWidget {
  const ComponentViewerScreen({super.key});

  @override
  State<ComponentViewerScreen> createState() => _ComponentViewerScreenState();
}

class _ComponentViewerScreenState extends State<ComponentViewerScreen> {
  int selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> categories = [
    // ==================== 현재 사용 가능한 컴포넌트 ====================
    {'name': '알림 배지', 'icon': Icons.notifications, 'color': ModernColors.error},
    {'name': '토스트', 'icon': Icons.message, 'color': ModernColors.success},
    {
      'name': '모임 필터',
      'icon': Icons.filter_list,
      'color': ModernColors.secondary
    },
    {'name': '모임 카드', 'icon': Icons.group, 'color': ModernColors.primary},
    {'name': '검색/카테고리', 'icon': Icons.search, 'color': ModernColors.info},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: const SherpaCleanAppBar(
        title: '셰르파 디자인 시스템',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // 헤더 설명
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ModernColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ModernColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '셰르파 컴포넌트 라이브러리',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '현재 사용 가능한 2025 디자인 시스템 컴포넌트',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 탭
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategoryIndex == index;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                category['color'],
                                category['color'].withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : ModernColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? category['color']
                            : ModernColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: category['color'].withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          color: isSelected ? Colors.white : category['color'],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['name'],
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : ModernColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 컴포넌트 리스트
          Expanded(
            child: _buildComponentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentList() {
    switch (selectedCategoryIndex) {
      case 0: // 알림 배지
        return _buildNotificationBadgeTab();
      case 1: // 토스트
        return _buildToastTab();
      case 2: // 모임 필터
        return _buildMeetingFiltersTab();
      case 3: // 모임 카드
        return _buildMeetingCardsTab();
      case 4: // 검색/카테고리
        return _buildSearchCategoryTab();
      default:
        return _buildNotificationBadgeTab();
    }
  }

  Widget _buildComponentSection(String title, String subtitle, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  // 알림 배지 탭
  Widget _buildNotificationBadgeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaNotificationBadge2025',
          '알림 배지 컴포넌트',
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SherpaNotificationBadge2025.count(
                    count: 5,
                    child: const Icon(Icons.notifications, size: 30),
                  ),
                  SherpaNotificationBadge2025.notification(
                    child: const Icon(Icons.message, size: 30),
                  ),
                  const SherpaNotificationBadge2025(
                    text: 'NEW',
                    variant: SherpaNotificationBadgeVariant2025.pill,
                    child: Icon(Icons.star, size: 30),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SherpaNotificationBadge2025.count(
                    count: 99,
                    child: const Icon(Icons.email, size: 30),
                  ),
                  const SherpaNotificationBadge2025(
                    text: 'HOT',
                    variant: SherpaNotificationBadgeVariant2025.pill,
                    child: Icon(Icons.local_fire_department, size: 30),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 토스트 탭 - 현재 사용 가능한 토스트 컴포넌트가 없음
  Widget _buildToastTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: ModernColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              '토스트 컴포넌트 없음',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ModernColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '현재 사용 가능한 토스트 컴포넌트가 없습니다.\n필요시 새로운 토스트 컴포넌트를 추가해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 모임 필터 탭
  Widget _buildMeetingFiltersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaSmartFilter2025',
          '스마트 검색 및 필터링 시스템',
          Column(
            children: [
              SherpaSmartFilter2025.standard(
                searchQuery: '',
                onSearchChanged: (query) => _showToast('검색: $query'),
                onOnlineToggle: (value) => _showToast('온라인 필터: $value'),
                onDetailedFiltersToggle: (value) => _showToast('상세 필터: $value'),
                category: 'exercise',
              ),
              const SizedBox(height: 20),
              SherpaSmartFilter2025.modern(
                searchQuery: '',
                onSearchChanged: (query) => _showToast('모던 검색: $query'),
                onVoiceSearch: () => _showToast('음성 검색 시작!'),
                category: 'networking',
              ),
              const SizedBox(height: 20),
              SherpaSmartFilter2025.compact(
                searchQuery: '',
                onSearchChanged: (query) => _showToast('컴팩트 검색: $query'),
                onOnlineToggle: (value) => _showToast('온라인 토글: $value'),
                category: 'study',
              ),
            ],
          ),
        ),
        _buildComponentSection(
          'SherpaQuickFilter2025',
          '빠른 필터링 시스템',
          Column(
            children: [
              SherpaQuickFilter2025.korean(
                activeFilters: const {'weekend', 'free'},
                onFiltersChanged: (filters) =>
                    _showToast('필터 변경: ${filters.join(', ')}'),
                onFilterToggle: (filter) => _showToast('필터 토글: $filter'),
                category: 'all',
              ),
              const SizedBox(height: 20),
              SherpaQuickFilter2025.modern(
                items: const [
                  SherpaQuickFilterItem2025(
                    key: 'beginner',
                    label: '초보자',
                    icon: Icons.star_border,
                    color: Colors.blue,
                  ),
                  SherpaQuickFilterItem2025(
                    key: 'advanced',
                    label: '고수',
                    icon: Icons.star,
                    color: Colors.orange,
                  ),
                  SherpaQuickFilterItem2025(
                    key: 'premium',
                    label: '프리미엄',
                    icon: Icons.diamond,
                    color: Colors.purple,
                  ),
                ],
                activeFilters: const {'beginner'},
                onFiltersChanged: (filters) =>
                    _showToast('모던 필터: ${filters.join(', ')}'),
                category: 'exercise',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 모임 카드 탭
  Widget _buildMeetingCardsTab() {
    // 샘플 데이터 - AvailableMeeting 객체 생성
    final sampleMeeting = AvailableMeeting(
      id: 'sample_1',
      title: '아침 러닝 모임',
      category: MeetingCategory.exercise,
      description: '상쾌한 아침 공기를 마시며 함께 달려요',
      type: MeetingType.free,
      scope: MeetingScope.public,
      dateTime: DateTime.now().add(const Duration(days: 2)),
      location: '한강공원',
      detailedLocation: '한강공원 중앙 광장',
      currentParticipants: 8,
      maxParticipants: 12,
      hostName: '김철수',
      hostId: 'host_001',
      price: null,
      tags: ['운동', '러닝', '아침'],
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'MeetingCard2025',
          '모임 카드 컴포넌트',
          Column(
            children: [
              MeetingCard2025(
                meeting: sampleMeeting,
                onTap: () => _showToast('모임 카드 클릭!'),
                onBookmark: () => _showToast('북마크 추가!'),
              ),
              const SizedBox(height: 16),
              MeetingCard2025(
                meeting: sampleMeeting,
                compact: true,
                onTap: () => _showToast('컴팩트 카드 클릭!'),
              ),
            ],
          ),
        ),
        _buildComponentSection(
          'MeetingCardList2025',
          '모임 카드 리스트',
          SizedBox(
            height: 250,
            child: MeetingCardList2025(
              meeting: sampleMeeting,
            ),
          ),
        ),
        _buildComponentSection(
          'ParticipantAvatars2025',
          '참가자 아바타 표시',
          const ParticipantAvatars2025(
            currentParticipants: 5,
            maxParticipants: 10,
            participantNames: ['김철수', '이영희', '박민수', '정수진', '최영수'],
            size: 40,
          ),
        ),
      ],
    );
  }

  // 검색/카테고리 탭
  Widget _buildSearchCategoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SearchBar2025',
          '검색 바 컴포넌트',
          Column(
            children: [
              SearchBar2025(
                hintText: '모임을 검색하세요',
                onChanged: (value) => _showToast('검색: $value'),
                onSubmitted: (value) => _showToast('검색 제출: $value'),
              ),
              const SizedBox(height: 16),
              SearchBar2025(
                hintText: '음성 검색 가능',
                onChanged: (value) => _showToast('검색: $value'),
              ),
            ],
          ),
        ),
        _buildComponentSection(
          'CategorySelector2025',
          '카테고리 선택기',
          CategorySelector2025(
            selectedCategory: MeetingCategory.all,
            onCategorySelected: (category) =>
                _showToast('카테고리: ${category.name}'),
            categories: MeetingCategory.values,
          ),
        ),
      ],
    );
  }

  void _showToast(String message) {
    // Toast functionality removed - no toast component available
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
