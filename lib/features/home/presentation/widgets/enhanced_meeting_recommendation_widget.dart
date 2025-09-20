import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

// Core
import '../../../../core/theme/modern_colors.dart';

// Features - Meetings
import '../../../meetings/models/available_meeting_model.dart';
import '../../../meetings/utils/meeting_image_utils.dart';

// Shared Providers
import '../../../../shared/providers/global_meeting_provider.dart';

// Shared Widgets
import '../../../../shared/widgets/components/molecules/participant_avatars_2025.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

/// 🎯 향상된 모임 추천 위젯
/// 7개 카테고리 필터와 프리미엄 헤더 디자인이 적용된 모임 추천 위젯
/// 홈 화면의 표준 스타일을 따르며 사진 배경 카드로 모임을 표시
class EnhancedMeetingRecommendationWidget extends ConsumerStatefulWidget {
  const EnhancedMeetingRecommendationWidget({super.key});

  @override
  ConsumerState<EnhancedMeetingRecommendationWidget> createState() =>
      _EnhancedMeetingRecommendationWidgetState();
}

class _EnhancedMeetingRecommendationWidgetState
    extends ConsumerState<EnhancedMeetingRecommendationWidget>
    with TickerProviderStateMixin {
  // 선택된 카테고리 (기본값: 추천)
  MeetingCategory _selectedCategory = MeetingCategory.all;

  // 애니메이션 컨트롤러
  late AnimationController _fadeController;
  late ScrollController _categoryScrollController;

  // 카테고리 맵핑 (UI 표시용)
  final Map<MeetingCategory, String> _categoryNames = {
    MeetingCategory.all: '추천',
    MeetingCategory.exercise: '운동',
    MeetingCategory.study: '스터디',
    MeetingCategory.reading: '독서',
    MeetingCategory.networking: '네트워킹',
    MeetingCategory.culture: '문화',
    MeetingCategory.outdoor: '아웃도어',
  };

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _categoryScrollController = ScrollController();

    // 초기 애니메이션
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  // 카테고리 선택 핸들러
  void _selectCategory(MeetingCategory category) {
    if (category != _selectedCategory) {
      HapticFeedbackManager.lightImpact();

      // 페이드 아웃
      _fadeController.reverse().then((_) {
        setState(() {
          _selectedCategory = category;
        });
        // 페이드 인
        _fadeController.forward();
      });
    }
  }

  // 필터링된 모임 가져오기
  List<AvailableMeeting> _getFilteredMeetings(
      List<AvailableMeeting> allMeetings) {
    if (_selectedCategory == MeetingCategory.all) {
      // 추천 카테고리: AI 추천 또는 인기 모임 표시
      return allMeetings.take(3).toList();
    } else {
      // 특정 카테고리 필터링
      return allMeetings
          .where((meeting) => meeting.category == _selectedCategory)
          .take(3)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final meetingState = ref.watch(globalMeetingProvider);
    final meetings = meetingState.availableMeetings;
    final filteredMeetings = _getFilteredMeetings(meetings);

    return Container(
      // 🎨 홈 화면 위젯 표준 스타일 적용
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: ModernColors.softShadow(
          primaryColor: ModernColors.primary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎯 프리미엄 헤더 섹션
          _buildPremiumHeader(context),

          // 🏷️ 카테고리 필터 칩
          _buildCategoryFilter(),

          // 📋 콘텐츠 영역
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _buildContent(filteredMeetings),
          ),
        ],
      ),
    );
  }

  // 🎨 프리미엄 헤더 디자인
  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
      child: Row(
        children: [
          // 아이콘 + 타이틀 영역
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 4), // 아이콘을 우측으로 4픽셀 이동
                // 🎯 섹션 아이콘 - 배경 없이 아이콘만
                Icon(
                  Icons.explore_rounded, // 탐험/발견을 의미하는 아이콘
                  color: ModernColors.modernPrimary,
                  size: 40,
                ),
                const SizedBox(width: 12),

                // 📝 타이틀 + 서브타이틀
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이런 모임은 어떠신가요?',
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '요즘 이런 게 유행하고 있어요!',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔗 "모든 모임 보기" 링크 (compact_quest_widget 스타일)
          GestureDetector(
            onTap: () {
              HapticFeedbackManager.lightImpact();
              // 모임 탭으로 이동
              Navigator.pushNamed(context, '/', arguments: 3);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ModernColors.modernPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🏷️ 카테고리 필터 칩
  Widget _buildCategoryFilter() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categoryNames.length,
        itemBuilder: (context, index) {
          final category = _categoryNames.keys.elementAt(index);
          final isSelected = _selectedCategory == category;
          final categoryName = _categoryNames[category]!;

          return Padding(
            padding: EdgeInsets.only(
              right: index < _categoryNames.length - 1 ? 8 : 0,
            ),
            child: _buildCategoryChip(
              category: category,
              name: categoryName,
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }

  // 🎯 개별 카테고리 칩 - 깔끔한 미니멀 디자인
  Widget _buildCategoryChip({
    required MeetingCategory category,
    required String name,
    required bool isSelected,
  }) {
    // 카테고리별 이모지
    final emoji = category == MeetingCategory.all ? '✨' : category.emoji;

    // 카테고리별 색상
    final color = category == MeetingCategory.all
        ? ModernColors.modernPrimary
        : category.color;

    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          // 🎨 깔끔하게 색상 변화만으로 구분
          color: isSelected
              ? ModernColors.modernPrimary // 선택 시: 모든 카테고리 통일된 프라이머리 색상
              : Colors.grey.shade100, // 미선택 시: 연한 회색
          borderRadius: BorderRadius.circular(18),
          // 그림자 효과 완전 제거
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎯 이모지
            Text(
              emoji,
              style: TextStyle(
                fontSize: isSelected ? 16 : 15,
              ),
            ),
            const SizedBox(width: 6),
            // 📝 텍스트 스타일
            Text(
              name,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white // 선택 시: 흰색 텍스트
                    : ModernColors.textPrimary, // 미선택 시: 기본 텍스트 색상
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📋 콘텐츠 영역
  Widget _buildContent(List<AvailableMeeting> filteredMeetings) {
    if (filteredMeetings.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          key: ValueKey(_selectedCategory),
          children: filteredMeetings.map((meeting) {
            final index = filteredMeetings.indexOf(meeting);
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < filteredMeetings.length - 1 ? 12 : 0,
              ),
              child: _buildMeetingCard(meeting),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 🎨 모임 카드 (사진 배경)
  Widget _buildMeetingCard(AvailableMeeting meeting) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        Navigator.pushNamed(
          context,
          '/meeting_detail',
          arguments: meeting,
        );
      },
      child: Container(
        height: 200, // 홈 화면용 컴팩트 높이
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 📸 배경 이미지
              Positioned.fill(
                child: _buildImageWidget(meeting),
              ),

              // 🌫️ 그라데이션 오버레이
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // 📝 콘텐츠 오버레이
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리 배지
                      _buildCompactCategoryBadge(meeting),

                      const Spacer(),

                      // 제목
                      Text(
                        meeting.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // 위치 & 시간
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${meeting.location} · ${meeting.formattedDate}',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 참가자 & 가격
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 참가자 아바타
                          ParticipantAvatars2025(
                            currentParticipants: meeting.currentParticipants,
                            maxParticipants: meeting.maxParticipants,
                            size: 24,
                            overlapFactor: 0.65,
                          ),

                          // 가격 배지
                          _buildCompactPriceBadge(meeting),
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

  // 🏷️ 컴팩트 카테고리 배지
  Widget _buildCompactCategoryBadge(AvailableMeeting meeting) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: meeting.category.color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: meeting.category.color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            meeting.category.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            meeting.category.displayName,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 💰 컴팩트 가격 배지
  Widget _buildCompactPriceBadge(AvailableMeeting meeting) {
    final isLowFee = meeting.participationFee <= 1000;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLowFee
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLowFee
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        meeting.type == MeetingType.free
            ? '무료'
            : '${meeting.participationFee.toInt()}P',
        style: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isLowFee ? Colors.green[100] : Colors.orange[100],
        ),
      ),
    );
  }

  // 📸 이미지 위젯
  Widget _buildImageWidget(AvailableMeeting meeting) {
    if (meeting.hasImages && meeting.imageFileNames.isNotEmpty) {
      final firstImage = meeting.imageFileNames.first;

      if (firstImage.startsWith('asset:')) {
        final assetPath = 'assets/images/meeting/${firstImage.substring(6)}';
        return Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(meeting),
        );
      }

      return FutureBuilder<File?>(
        future: MeetingImageUtils.getMeetingImageFile(firstImage),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(meeting),
            );
          }
          return _buildImagePlaceholder(meeting);
        },
      );
    }

    return _buildImagePlaceholder(meeting);
  }

  // 🎨 이미지 플레이스홀더
  Widget _buildImagePlaceholder(AvailableMeeting meeting) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: meeting.category.gradient,
        ),
      ),
      child: Center(
        child: Text(
          meeting.category.emoji,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  // 🚫 빈 상태
  Widget _buildEmptyState() {
    final categoryName = _categoryNames[_selectedCategory]!;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: ModernColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              '$categoryName 카테고리에\n모임이 없습니다',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                HapticFeedbackManager.lightImpact();
                Navigator.pushNamed(context, '/', arguments: 3);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '모임 둘러보기',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
