import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../meetings/models/available_meeting_model.dart';
import '../../providers/meeting_recommendation_provider.dart';
import '../../../meetings/presentation/screens/available_meeting_detail_screen.dart';

/// 🎯 프리미엄 모임 추천 위젯 - 2025 모던 디자인
/// 블루-화이트 컬러 대비를 활용한 고급스러운 디자인
/// 테두리 없이 색상과 그림자로 구분하는 현대적인 UI
class PremiumMeetingRecommendationWidget extends ConsumerStatefulWidget {
  const PremiumMeetingRecommendationWidget({super.key});

  @override
  ConsumerState<PremiumMeetingRecommendationWidget> createState() =>
      _PremiumMeetingRecommendationWidgetState();
}

class _PremiumMeetingRecommendationWidgetState
    extends ConsumerState<PremiumMeetingRecommendationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedCategory = 'all';
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _cardScrollController = ScrollController();

  // 카테고리 정의
  final Map<String, CategoryInfo> _categories = {
    'all': CategoryInfo('전체', Icons.apps_rounded, ModernColors.primary),
    'study': CategoryInfo('스터디', Icons.school_rounded, ModernColors.accent),
    'exercise': CategoryInfo('운동', Icons.fitness_center_rounded, ModernColors.exercise),
    'outdoor': CategoryInfo('야외', Icons.nature_people_rounded, ModernColors.success),
    'culture': CategoryInfo('문화', Icons.theater_comedy_rounded, ModernColors.meeting),
    'networking': CategoryInfo('네트워킹', Icons.people_rounded, ModernColors.secondary),
    'reading': CategoryInfo('독서', Icons.menu_book_rounded, ModernColors.diary),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _categoryScrollController.dispose();
    _cardScrollController.dispose();
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
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: ModernColors.getElevationShadow(2),
      ),
      child: Column(
        children: [
          // 헤더 섹션
          _buildHeader(),
          
          // 카테고리 필터 칩
          _buildCategoryChips(),
          
          // 모임 카드 리스트
          if (state.isLoading)
            _buildLoadingState()
          else if (meetings.isEmpty)
            _buildEmptyState()
          else
            _buildMeetingCards(meetings),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.02, end: 0);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.primary.withValues(alpha: 0.05),
            ModernColors.surface,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // 아이콘과 타이틀
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: ModernColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.recommend_rounded,
              color: Colors.white,
              size: 22,
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 2.seconds,
            curve: Curves.easeInOutSine,
          ),
          
          const SizedBox(width: 14),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추천 모임',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ModernColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '당신을 위한 맞춤형 성장 기회',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          
          // 전체보기 버튼
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _navigateToMeetingsTab,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '전체보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: ModernColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories.keys.elementAt(index);
          final info = _categories[category]!;
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: EdgeInsets.only(
              right: index < _categories.length - 1 ? 10 : 0,
            ),
            child: _buildCategoryChip(
              category: category,
              info: info,
              isSelected: isSelected,
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildCategoryChip({
    required String category,
    required CategoryInfo info,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onCategoryTap(category),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
              ? info.color.withValues(alpha: 0.1)
              : ModernColors.gray50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                info.icon,
                size: 18,
                color: isSelected ? info.color : ModernColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                info.name,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? info.color : ModernColors.textSecondary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingCards(List<AvailableMeeting> meetings) {
    // 최대 3개의 모임만 표시
    final displayMeetings = meetings.take(3).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: displayMeetings.asMap().entries.map((entry) {
          final index = entry.key;
          final meeting = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(bottom: index < displayMeetings.length - 1 ? 16 : 0),
            child: _buildMeetingCard(meeting, index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMeetingCard(AvailableMeeting meeting, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onMeetingTap(meeting),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ModernColors.surface,
                meeting.category.color.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: meeting.category.color.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: ModernColors.shadowBase.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 섹션: 카테고리와 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: meeting.category.color.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 아이콘
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ModernColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: meeting.category.color.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          meeting.category.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // 타이틀과 설명
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 카테고리 배지
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: meeting.category.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              meeting.category.displayName,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 타이틀
                          Text(
                            meeting.title,
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: ModernColors.textPrimary,
                              letterSpacing: -0.3,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 하단 섹션: 상세 정보
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 시간 정보
                    _buildInfoRow(
                      icon: Icons.schedule_rounded,
                      text: meeting.formattedDate,
                      color: ModernColors.primary,
                    ),
                    const SizedBox(height: 10),
                    
                    // 위치 정보
                    _buildInfoRow(
                      icon: Icons.location_on_rounded,
                      text: meeting.location,
                      color: ModernColors.secondary,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 하단 액션 영역
                    Row(
                      children: [
                        // 참가자 아바타
                        _buildParticipantsAvatars(meeting),
                        
                        const SizedBox(width: 8),
                        
                        // 참가자 수
                        Text(
                          '${meeting.currentParticipants}/${meeting.maxParticipants}',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // 보상 표시
                        _buildRewardBadge(meeting),
                        
                        const SizedBox(width: 12),
                        
                        // 참여 버튼
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                meeting.category.color,
                                meeting.category.color.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: meeting.category.color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_circle_outline_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '참여',
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
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
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 200 + (index * 100)))
      .fadeIn(duration: 400.ms)
      .slideX(begin: 0.02, end: 0);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsAvatars(AvailableMeeting meeting) {
    final avatars = ['👤', '👩', '👨'];
    final participantCount = meeting.currentParticipants.clamp(0, 3);
    
    if (participantCount == 0) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: ModernColors.gray100,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          size: 16,
          color: ModernColors.textTertiary,
        ),
      );
    }
    
    return SizedBox(
      width: 20.0 + (participantCount - 1) * 16.0 + 8,
      height: 28,
      child: Stack(
        children: List.generate(participantCount, (index) {
          return Positioned(
            left: index * 16.0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ModernColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ModernColors.surface,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  avatars[index % avatars.length],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRewardBadge(AvailableMeeting meeting) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.rewardGradient1.withValues(alpha: 0.1),
            ModernColors.rewardGradient2.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14,
            color: ModernColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            '+${meeting.experienceReward.toInt()} XP',
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ModernColors.warning,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ModernColors.primary),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              '최적의 모임을 찾고 있어요...',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: ModernColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.explore_outlined,
                size: 32,
                color: ModernColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '현재 추천할 모임이 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '곧 새로운 모임이 추가될 예정이에요',
              style: GoogleFonts.notoSans(
                fontSize: 13,
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
    
    // 카테고리 매핑
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

/// 카테고리 정보 모델
class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;

  CategoryInfo(this.name, this.icon, this.color);
}