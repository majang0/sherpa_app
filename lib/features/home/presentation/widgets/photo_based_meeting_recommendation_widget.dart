import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../meetings/models/available_meeting_model.dart';
import '../../../meetings/utils/meeting_image_utils.dart';
import '../../providers/meeting_recommendation_provider.dart';
import '../../../meetings/presentation/screens/available_meeting_detail_screen.dart';
import '../../../../shared/widgets/components/molecules/participant_avatars_2025.dart';

/// 🎨 포토 기반 모임 추천 위젯 - 2025 리디자인
/// 사진 배경 위에 정보를 오버레이하는 모던한 디자인
class PhotoBasedMeetingRecommendationWidget extends ConsumerStatefulWidget {
  const PhotoBasedMeetingRecommendationWidget({super.key});

  @override
  ConsumerState<PhotoBasedMeetingRecommendationWidget> createState() =>
      _PhotoBasedMeetingRecommendationWidgetState();
}

class _PhotoBasedMeetingRecommendationWidgetState
    extends ConsumerState<PhotoBasedMeetingRecommendationWidget>
    with TickerProviderStateMixin {
  
  // 애니메이션 컨트롤러
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  // 필터링 상태
  String _selectedCategory = 'all';
  final ScrollController _categoryScrollController = ScrollController();
  
  // 카테고리 정의
  final Map<String, CategoryData> _categories = {
    'all': CategoryData('전체', Icons.apps_rounded, ModernColors.primary),
    'study': CategoryData('스터디', Icons.school_rounded, ModernColors.accent),
    'exercise': CategoryData('운동', Icons.fitness_center_rounded, ModernColors.exercise),
    'outdoor': CategoryData('야외', Icons.nature_people_rounded, ModernColors.success),
    'culture': CategoryData('문화', Icons.theater_comedy_rounded, ModernColors.meeting),
    'networking': CategoryData('네트워킹', Icons.people_rounded, ModernColors.secondary),
    'reading': CategoryData('독서', Icons.menu_book_rounded, ModernColors.diary),
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 애니메이션 시작
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _navigateToMeetingsTab() {
    HapticFeedbackManager.lightImpact();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
      arguments: 3,
    );
  }

  void _onCategoryTap(String category) {
    HapticFeedbackManager.selection();
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onMeetingTap(AvailableMeeting meeting) {
    HapticFeedbackManager.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailableMeetingDetailScreen(meeting: meeting),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meetingRecommendationProvider);
    final meetings = _getFilteredMeetings(state.allMeetings);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          _buildHeader(),
          
          const SizedBox(height: 16),
          
          // 카테고리 필터
          _buildCategoryFilter(),
          
          const SizedBox(height: 20),
          
          // 모임 카드들
          if (state.isLoading)
            _buildLoadingState()
          else if (meetings.isEmpty)
            _buildEmptyState()
          else
            _buildMeetingCards(meetings),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 타이틀
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '추천 모임',
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: ModernColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.1, end: 0),
              
              const SizedBox(height: 4),
              
              Text(
                '당신을 위한 특별한 모임',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textSecondary,
                  letterSpacing: -0.3,
                ),
              ).animate()
                .fadeIn(duration: 500.ms, delay: 100.ms)
                .slideX(begin: -0.1, end: 0),
            ],
          ),
          
          // 전체보기 버튼
          GestureDetector(
            onTap: _navigateToMeetingsTab,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: ModernColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ModernColors.borderLight,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체보기',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: ModernColors.primary,
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories.keys.elementAt(index);
          final data = _categories[category]!;
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () => _onCategoryTap(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(right: index < _categories.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected 
                  ? data.color
                  : ModernColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                    ? data.color
                    : ModernColors.borderLight,
                  width: 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    data.icon,
                    size: 16,
                    color: isSelected ? Colors.white : ModernColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.name,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : ModernColors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * index))
              .slideY(begin: 0.2, end: 0),
          );
        },
      ),
    );
  }

  Widget _buildMeetingCards(List<AvailableMeeting> meetings) {
    // 최대 3개만 표시
    final displayMeetings = meetings.take(3).toList();
    
    return Column(
      children: displayMeetings.asMap().entries.map((entry) {
        final index = entry.key;
        final meeting = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPhotoCard(meeting, index),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoCard(AvailableMeeting meeting, int index) {
    return GestureDetector(
      onTap: () => _onMeetingTap(meeting),
      child: Container(
        height: 240,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 배경 이미지
              Positioned.fill(
                child: _buildBackgroundImage(meeting),
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
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.2, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              
              // 글래스모피즘 효과
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              
              // 컨텐츠
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단: 카테고리와 가격
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 카테고리 배지
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: meeting.category.color,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: meeting.category.color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  meeting.category.emoji,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  meeting.category.displayName,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 가격 정보
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              meeting.type == MeetingType.free 
                                ? '무료' 
                                : '${meeting.participationFee.toInt()}P',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // 제목
                      Text(
                        meeting.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 시간과 장소
                      Row(
                        children: [
                          // 장소
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    meeting.location,
                                    style: GoogleFonts.notoSans(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 시간
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meeting.formattedDate,
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 참가자와 참여 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 참가자 아바타
                          ParticipantAvatars2025(
                            currentParticipants: meeting.currentParticipants,
                            maxParticipants: meeting.maxParticipants,
                            size: 32,
                            overlapFactor: 0.65,
                          ),
                          
                          // 참여 버튼
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                  color: meeting.category.color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '참여하기',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: meeting.category.color,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
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
      ).animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildBackgroundImage(AvailableMeeting meeting) {
    // 모임에 실제 이미지가 있는 경우
    if (meeting.hasImages && meeting.imageFileNames.isNotEmpty) {
      final firstImage = meeting.imageFileNames.first;
      
      // asset: 플래그로 시작하면 assets 폴더에서 로드
      if (firstImage.startsWith('asset:')) {
        final assetPath = 'assets/images/meeting/${firstImage.substring(6)}';
        return Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildGradientBackground(meeting),
        );
      }
      
      // 일반 이미지 파일
      return FutureBuilder<File?>(
        future: MeetingImageUtils.getMeetingImageFile(firstImage),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildGradientBackground(meeting),
            );
          }
          return _buildGradientBackground(meeting);
        },
      );
    }
    
    // 이미지가 없으면 그라데이션 배경
    return _buildGradientBackground(meeting);
  }

  Widget _buildGradientBackground(AvailableMeeting meeting) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            meeting.category.color.withValues(alpha: 0.8),
            meeting.category.color.withValues(alpha: 0.6),
            meeting.category.color.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Center(
        child: Text(
          meeting.category.emoji,
          style: TextStyle(
            fontSize: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ModernColors.gray50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ModernColors.primary),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ModernColors.gray50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 48,
              color: ModernColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              '현재 추천할 모임이 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AvailableMeeting> _getFilteredMeetings(List<AvailableMeeting> meetings) {
    if (_selectedCategory == 'all') {
      return meetings;
    }
    
    final categoryMapping = {
      'study': MeetingCategory.study,
      'exercise': MeetingCategory.exercise,
      'outdoor': MeetingCategory.outdoor,
      'culture': MeetingCategory.culture,
      'networking': MeetingCategory.networking,
      'reading': MeetingCategory.reading,
    };
    
    final mappedCategory = categoryMapping[_selectedCategory];
    if (mappedCategory == null) return meetings;
    
    return meetings.where((meeting) => meeting.category == mappedCategory).toList();
  }
}

/// 카테고리 데이터 모델
class CategoryData {
  final String name;
  final IconData icon;
  final Color color;

  CategoryData(this.name, this.icon, this.color);
}