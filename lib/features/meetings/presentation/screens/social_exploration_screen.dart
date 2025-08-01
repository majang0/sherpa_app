import 'dart:async'; // Timer를 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../models/available_meeting_model.dart';
import '../widgets/meeting_card_widget.dart';

/// 🤝 소셜 탐험 게시판 (Social Exploration Board)
/// 한국형 모임 발견 플랫폼으로 설계된 모임 화면
class SocialExplorationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SocialExplorationScreen> createState() => _SocialExplorationScreenState();
}

class _SocialExplorationScreenState extends ConsumerState<SocialExplorationScreen>
    with TickerProviderStateMixin {
  late TabController _categoryController; // 카테고리별 탭
  final TextEditingController _searchController = TextEditingController();
  final List<MeetingCategory> categories = MeetingCategory.values; // const로 변경
  String _searchQuery = '';
  bool _showFilters = false;
  
  // 필터 상태
  MeetingScope? _selectedScope;
  String? _selectedLocation;
  MeetingCategory? _selectedFilterCategory; // 필터용 카테고리 추가
  DateTimeRange? _selectedDateRange;
  RangeValues? _selectedPriceRange;
  final List<String> _selectedTags = []; // const로 변경
  
  // 성능 최적화: 디바운스 막기
  Timer? _searchDebouncer;

  @override
  void initState() {
    super.initState();
    _categoryController = TabController(length: categories.length, vsync: this);

    // 🎯 앱 진입 시 셰르피 환영 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.welcome,
        emotion: SherpiEmotion.cheering,
        userContext: {
          'screen': 'social_exploration',
          'feature': 'meeting_discovery'
        },
      );
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _searchController.dispose();
    _searchDebouncer?.cancel(); // 디바운서 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // ✅ 모임 개설 FAB 추가
      floatingActionButton: _buildCreateMeetingFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: DefaultTabController(
        length: categories.length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // 📋 상단 헤더: 미니멀 디자인으로 모임 발견에 집중
              SliverToBoxAdapter(
                child: _buildMinimalHeader(user),
              ),

              // 🤖 AI 개인화 추천 섹션 (문토 앱 패턴)
              SliverToBoxAdapter(
                child: _buildAIRecommendationSection(user),
              ),

              // 📱 실시간 소셜 피드 (한국 모임앱 패턴)
              SliverToBoxAdapter(
                child: _buildSocialFeedSection(),
              ),

              // 🔍 검색바 및 필터
              SliverToBoxAdapter(
                child: _buildSearchAndFilterSection(),
              ),

              // 🏷️ 한국형 모임 앱 패턴: 전체 + 3개 카테고리 (총 4개)
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategorySelectorDelegate(
                  controller: _categoryController,
                  categories: categories,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _categoryController,
            physics: const NeverScrollableScrollPhysics(), // 탭뷰 자체 스크롤 비활성화
            children: categories.map((category) => 
              _buildMeetingList(category: category)
            ).toList(),
          ),
        ),
      ),
    );
  }


  /// 🤖 AI 개인화 추천 섹션 (문토 앱 스타일)
  Widget _buildAIRecommendationSection(GlobalUser user) {
    // 사용자의 최고 스탯을 기반으로 추천 카테고리 결정
    final recommendedCategory = _getRecommendedCategory(user.stats);
    final recommendedMeetings = _getRecommendedMeetings(user);
    
    if (recommendedMeetings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            recommendedCategory.color.withOpacity(0.1),
            recommendedCategory.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: recommendedCategory.color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: recommendedCategory.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🤖 AI 추천 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: recommendedCategory.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: recommendedCategory.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.name}님을 위한 추천',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${recommendedCategory.displayName} 모임',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: recommendedCategory.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: recommendedCategory.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recommendedCategory.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 📊 추천 이유 (스탯 기반)
          _buildRecommendationReason(user.stats, recommendedCategory),
          
          const SizedBox(height: 16),
          
          // 🎯 추천 모임 목록 (가로 스크롤)
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recommendedMeetings.length.clamp(0, 5), // 최대 5개
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final meeting = recommendedMeetings[index];
                return _buildRecommendedMeetingCard(meeting);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 추천 이유 표시
  Widget _buildRecommendationReason(GlobalStats stats, MeetingCategory category) {
    final dominantStat = _getDominantStat(stats);
    String reason;
    IconData icon;
    
    switch (dominantStat) {
      case 'stamina':
        reason = category == MeetingCategory.exercise 
          ? '높은 체력으로 운동 활동을 즐기실 수 있어요'
          : '체력을 더 기를 수 있는 활동을 추천해요';
        icon = Icons.fitness_center_rounded;
        break;
      case 'knowledge':
        reason = category == MeetingCategory.study 
          ? '풍부한 지식으로 스터디 모임에서 활약하실 수 있어요'
          : '지식을 더 늘릴 수 있는 모임을 추천해요';
        icon = Icons.school_rounded;
        break;
      case 'sociality':
        reason = category == MeetingCategory.networking 
          ? '뛰어난 사교성으로 네트워킹 모임에서 빛나실 수 있어요'
          : '사교성을 기를 수 있는 모임을 추천해요';
        icon = Icons.groups_rounded;
        break;
      case 'technique':
        reason = '기술력을 활용하거나 발전시킬 수 있는 모임이에요';
        icon = Icons.build_rounded;
        break;
      case 'willpower':
        reason = '의지력을 키우고 목표를 달성할 수 있는 모임이에요';
        icon = Icons.psychology_rounded;
        break;
      default:
        reason = '균형 잡힌 성장을 위한 모임을 추천해요';
        icon = Icons.balance_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: category.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reason,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 추천 모임 카드 (1:1 비율 이미지 포함)
  Widget _buildRecommendedMeetingCard(AvailableMeeting meeting) {
    return GestureDetector(
      onTap: () => _handleMeetingTap(meeting),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: meeting.category.color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ 상단: 1:1 비율 미니 썸네일
              _buildRecommendationImage(meeting),
              
              // 📝 하단: 콘텐츠 정보
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: meeting.category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${meeting.category.emoji} ${meeting.category.displayName}',
                        style: GoogleFonts.notoSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: meeting.category.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 제목
                    Text(
                      meeting.title,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 날짜 정보
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            meeting.formattedDate,
                            style: GoogleFonts.notoSans(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
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
    );
  }

  /// 🖼️ AI 추천 모임 이미지 (컴팩트한 1:1 비율)
  Widget _buildRecommendationImage(AvailableMeeting meeting) {
    return AspectRatio(
      aspectRatio: 1.0, // 정사각형 1:1 비율
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              meeting.category.color.withOpacity(0.7),
              meeting.category.color,
            ],
          ),
        ),
        child: Stack(
          children: [
            // 🎨 미니멀 패턴
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.8, -0.5),
                    radius: 1.2,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                      meeting.category.color.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),
            
            // 🎯 중앙 아이콘
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    meeting.category.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            
            // 🏷️ 우상단 상태 표시
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: meeting.statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  meeting.status,
                  style: GoogleFonts.notoSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
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

  /// 📱 실시간 소셜 피드 (한국 모임앱 패턴)
  Widget _buildSocialFeedSection() {
    final socialActivities = _generateSocialFeedData();
    
    if (socialActivities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📱 소셜 피드 헤더
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.feed_rounded,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '실시간 모임 소식',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LIVE',
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 📱 소셜 피드 카드들 (가로 스크롤)
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: socialActivities.length.clamp(0, 10), // 최대 10개
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final activity = socialActivities[index];
                return _buildSocialFeedCard(activity);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 📱 소셜 피드 카드 (1:1 비율 이미지 포함)
  Widget _buildSocialFeedCard(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    final isHot = activity['isHot'] as bool? ?? false;
    final categoryColor = activity['categoryColor'] as Color;
    
    Color primaryColor;
    IconData icon;
    String actionText;
    
    switch (type) {
      case 'new_meeting':
        primaryColor = AppColors.success;
        icon = Icons.add_circle_outline_rounded;
        actionText = '새 모임';
        break;
      case 'join_meeting':
        primaryColor = AppColors.primary;
        icon = Icons.group_add_rounded;
        actionText = '참여 확정';
        break;
      case 'meeting_full':
        primaryColor = AppColors.warning;
        icon = Icons.people_rounded;
        actionText = '모집 완료';
        break;
      case 'review_posted':
        primaryColor = AppColors.accent;
        icon = Icons.rate_review_rounded;
        actionText = '후기 작성';
        break;
      default:
        primaryColor = AppColors.secondary;
        icon = Icons.notifications_rounded;
        actionText = '활동';
    }

    return GestureDetector(
      onTap: () => _handleSocialFeedTap(activity),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isHot 
              ? Border.all(color: AppColors.error.withOpacity(0.3), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
            if (isHot) BoxShadow(
              color: AppColors.error.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ 상단: 1:1 비율 썸네일 이미지
              _buildSocialFeedImage(activity, primaryColor),
              
              // 📝 하단: 콘텐츠 정보
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 활동 유형과 시간
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            actionText,
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isHot) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
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
                          const SizedBox(width: 4),
                        ],
                        Text(
                          activity['timeAgo'] as String,
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 모임 제목
                    Text(
                      activity['meetingTitle'] as String,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // 사용자 정보와 참여자 수
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (activity['userName'] as String).substring(0, 1),
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            activity['userName'] as String,
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${activity['currentParticipants']}/${activity['maxParticipants']}',
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
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
    );
  }

  /// 🖼️ 소셜 피드 1:1 이미지 섹션
  Widget _buildSocialFeedImage(Map<String, dynamic> activity, Color primaryColor) {
    final categoryColor = activity['categoryColor'] as Color;
    final categoryEmoji = activity['categoryEmoji'] as String;
    final categoryName = activity['categoryName'] as String;
    final location = activity['location'] as String;

    return AspectRatio(
      aspectRatio: 16 / 9, // 소셜 피드는 16:9 비율 사용 (카드형태에 적합)
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              categoryColor.withOpacity(0.8),
              categoryColor,
              categoryColor.withOpacity(0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 🎨 배경 패턴
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, -0.3),
                    radius: 1.0,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.transparent,
                      categoryColor.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            
            // 🌈 그라데이션 오버레이
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
            
            // 🏷️ 상단 카테고리 태그
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$categoryEmoji $categoryName',
                  style: GoogleFonts.notoSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                  ),
                ),
              ),
            ),
            
            // 📍 하단 위치 정보
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      location,
                      style: GoogleFonts.notoSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 🎯 중앙 카테고리 아이콘
            Center(
              child: Container(
                width: 36,
                height: 36,
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
                child: Center(
                  child: Text(
                    categoryEmoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📱 소셜 피드 데이터 생성 (실제 앱에서는 API에서 가져옴)
  List<Map<String, dynamic>> _generateSocialFeedData() {
    final now = DateTime.now();
    final categories = [
      {'name': '운동/스포츠', 'emoji': '💪', 'color': AppColors.success},
      {'name': '스터디', 'emoji': '📚', 'color': AppColors.primary},
      {'name': '네트워킹', 'emoji': '🤝', 'color': AppColors.warning},
    ];
    
    final locations = ['강남구', '홍대', '이태원', '건대', '신촌', '온라인'];
    final activityTypes = ['new_meeting', 'join_meeting', 'meeting_full', 'review_posted'];
    final names = ['김셰르파', '박모험가', '이등반가', '최탐험가', '정클라이머', '오산악가'];
    
    final meetingTitles = [
      '주말 등반 모임 🏔️',
      '북한산 트레킹',
      '코딩 스터디 그룹',
      '영어 회화 모임',
      '요가 클래스',
      '런닝 크루',
      '사진 촬영 모임',
      '맛집 탐방',
      '보드게임 카페',
      '독서 토론회',
    ];
    
    return List.generate(15, (index) {
      final category = categories[index % categories.length];
      final activityType = activityTypes[index % activityTypes.length];
      final isHot = index < 3; // 처음 3개는 HOT
      
      final minutesAgo = index * 5 + 2;
      String timeAgo;
      if (minutesAgo < 60) {
        timeAgo = '${minutesAgo}분 전';
      } else {
        final hoursAgo = minutesAgo ~/ 60;
        timeAgo = '${hoursAgo}시간 전';
      }
      
      return {
        'type': activityType,
        'isHot': isHot,
        'meetingTitle': meetingTitles[index % meetingTitles.length],
        'categoryName': category['name'],
        'categoryEmoji': category['emoji'],
        'categoryColor': category['color'],
        'location': locations[index % locations.length],
        'userName': names[index % names.length],
        'timeAgo': timeAgo,
        'currentParticipants': (index % 8) + 2,
        'maxParticipants': ((index % 8) + 2) + (index % 5) + 1,
        'timestamp': now.subtract(Duration(minutes: minutesAgo)),
      };
    });
  }

  /// 📱 소셜 피드 카드 탭 핸들러
  void _handleSocialFeedTap(Map<String, dynamic> activity) {
    // 소셜 피드 활동 상세 보기 또는 관련 모임으로 이동
    final meetingTitle = activity['meetingTitle'] as String;
    
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '$meetingTitle 모임 소식을 확인해보세요! 🔥',
      emotion: SherpiEmotion.thinking,
    );
    
    // TODO: 실제 모임 상세 화면으로 이동하거나 소셜 활동 상세 보기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$meetingTitle 소식을 확인했습니다'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 📋 미니멀 헤더 (모임 발견에 집중)
  Widget _buildMinimalHeader(GlobalUser user) {
    final availableMeetings = ref.watch(globalAvailableMeetingsProvider);
    final todayMeetingCount = availableMeetings.where((meeting) => 
      meeting.dateTime.day == DateTime.now().day &&
      meeting.dateTime.month == DateTime.now().month
    ).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 왼쪽: 인사말
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요 ${user.name}님! 👋',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '새로운 모임을 찾아보세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 오른쪽: 오늘의 모임 수
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$todayMeetingCount',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '오늘 모임',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 검색 및 필터 섹션
  Widget _buildSearchAndFilterSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // 검색바
          _buildSearchBar(),
          
          // 필터 옵션 (접을 수 있음)
          if (_showFilters) ..._buildFilterOptions(),
        ],
      ),
    );
  }

  /// 🔍 검색바
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          // 성능 최적화: 디바운스로 검색 빈도 제한
          _searchDebouncer?.cancel();
          _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _searchQuery = value;
              });
            }
          });
        },
        decoration: InputDecoration(
          hintText: '모임 제목, 지역, 키워드로 검색해보세요',
          hintStyle: GoogleFonts.notoSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 검색어 지우기 버튼
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              // 필터 토글 버튼 (활성 필터 개수 표시)
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      _showFilters ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
                      color: _showFilters || _activeFilterCount > 0 ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                  if (_activeFilterCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_activeFilterCount',
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// 🎛️ 필터 옵션들
  List<Widget> _buildFilterOptions() {
    return [
      const SizedBox(height: 12),
      
      // 필터 칩들 (업그레이드된 디자인)
      Container(
        margin: const EdgeInsets.only(bottom: 8),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 필터 제목 (업그레이드된 헤더)
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
            
            // 범위 필터 (전체/우리학교)
            _buildScopeFilter(),
            
            const SizedBox(height: 16),
            
            // 카테고리 필터
            _buildCategoryFilter(),
            
            const SizedBox(height: 16),
            
            // 지역 필터
            _buildLocationFilter(),
            
            const SizedBox(height: 16),
            
            // 날짜 필터
            _buildDateFilter(),
            
            const SizedBox(height: 16),
            
            // 가격 필터
            _buildPriceFilter(),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  /// 카테고리 필터
  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
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
          children: MeetingCategory.values.where((cat) => cat != MeetingCategory.all).map((category) {
            final isSelected = _selectedFilterCategory == category;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilterCategory = isSelected ? null : category;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            colors: [
                              category.color,
                              category.color.withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? category.color 
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: category.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.emoji,
                        style: TextStyle(
                          fontSize: isSelected ? 14 : 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.displayName,
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

  /// 범위 필터
  Widget _buildScopeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 범위',
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: MeetingScope.values.map((scope) {
            final isSelected = _selectedScope == scope;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedScope = isSelected ? null : scope;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary 
                            : Colors.grey.shade300,
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
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 지역 필터
  Widget _buildLocationFilter() {
    final locations = ['온라인', '서울', '경기', '인천', '대전', '광주', '대구', '제주', '부산'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지역',
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

  /// 날짜 필터
  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜',
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(16),
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
        ),
      ],
    );
  }

  /// 가격 필터
  Widget _buildPriceFilter() {
    final priceOptions = [
      {'label': '무료', 'icon': Icons.star_rounded, 'range': const RangeValues(0, 0), 'color': AppColors.success},
      {'label': '1만원 이하', 'icon': Icons.payments_rounded, 'range': const RangeValues(1, 10000), 'color': AppColors.warning},
      {'label': '1만원 이상', 'icon': Icons.diamond_rounded, 'range': const RangeValues(10000, 999999), 'color': AppColors.error},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참여비',
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
          children: priceOptions.map((option) {
            final range = option['range'] as RangeValues;
            final isSelected = _selectedPriceRange?.start == range.start && _selectedPriceRange?.end == range.end;
            final color = option['color'] as Color;
            
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPriceRange = isSelected ? null : range;
                  });
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

  /// 날짜 범위 선택 (한국어 캘린더)
  Future<void> _selectDateRange() async {
    try {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)), // 1년으로 확장
        initialDateRange: _selectedDateRange,
        locale: const Locale('ko', 'KR'), // 한국어 로케일 적용
        helpText: '날짜 범위 선택',
        cancelText: '취소',
        confirmText: '확인',
        saveText: '저장',
        errorFormatText: '올바른 날짜를 입력해주세요',
        errorInvalidText: '유효하지 않은 날짜입니다',
        errorInvalidRangeText: '유효하지 않은 날짜 범위입니다',
        fieldStartHintText: '시작 날짜',
        fieldEndHintText: '종료 날짜',
        fieldStartLabelText: '시작 날짜',
        fieldEndLabelText: '종료 날짜',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.textPrimary,
              ),
              textTheme: Theme.of(context).textTheme.copyWith(
                headlineSmall: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                titleMedium: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                bodyLarge: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                labelLarge: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              dialogTheme: DialogTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (picked != null && mounted) {
        setState(() {
          _selectedDateRange = picked;
        });
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('날짜 선택 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 모든 필터 초기화
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

  /// 활성 필터 개수 계산
  int get _activeFilterCount {
    int count = 0;
    if (_selectedScope != null) count++;
    if (_selectedLocation != null) count++;
    if (_selectedFilterCategory != null) count++;
    if (_selectedDateRange != null) count++;
    if (_selectedPriceRange != null) count++;
    if (_selectedTags.isNotEmpty) count++;
    return count;
  }

  /// 📝 모임 목록 빌더 (카테고리별 + 검색/필터링 + 날짜순 정렬)
  Widget _buildMeetingList({required MeetingCategory category}) {
    return Consumer(
      builder: (context, ref, child) {
        var filteredMeetings = ref.watch(globalMeetingsByCategoryProvider(category));
        
        // 🕐 날짜순 정렬 (가까운 날짜부터)
        filteredMeetings = List.from(filteredMeetings)
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        
        // 검색어 필터링
        if (_searchQuery.isNotEmpty) {
          filteredMeetings = filteredMeetings.where((meeting) {
            final query = _searchQuery.toLowerCase();
            return meeting.title.toLowerCase().contains(query) ||
                   meeting.description.toLowerCase().contains(query) ||
                   meeting.location.toLowerCase().contains(query) ||
                   meeting.tags.any((tag) => tag.toLowerCase().contains(query));
          }).toList();
        }
        
        // 범위 필터링
        if (_selectedScope != null) {
          filteredMeetings = filteredMeetings.where((meeting) => 
              meeting.scope == _selectedScope).toList();
        }
        
        // 카테고리 필터링
        if (_selectedFilterCategory != null) {
          filteredMeetings = filteredMeetings.where((meeting) => 
              meeting.category == _selectedFilterCategory).toList();
        }
        
        // 지역 필터링
        if (_selectedLocation != null) {
          filteredMeetings = filteredMeetings.where((meeting) => 
              meeting.location.contains(_selectedLocation!)).toList();
        }
        
        // 날짜 필터링
        if (_selectedDateRange != null) {
          filteredMeetings = filteredMeetings.where((meeting) {
            final meetingDate = DateTime(meeting.dateTime.year, meeting.dateTime.month, meeting.dateTime.day);
            final startDate = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
            final endDate = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day);
            return !meetingDate.isBefore(startDate) && !meetingDate.isAfter(endDate);
          }).toList();
        }
        
        // 가격 필터링
        if (_selectedPriceRange != null) {
          filteredMeetings = filteredMeetings.where((meeting) {
            final price = meeting.price ?? 0;
            return price >= _selectedPriceRange!.start && price <= _selectedPriceRange!.end;
          }).toList();
        }

        if (filteredMeetings.isEmpty) {
          // 필터/검색 상태에 따른 빈 상태 메시지
          final hasActiveFilters = _activeFilterCount > 0;
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
          
          return _buildEmptyState(
            icon: icon,
            title: title,
            subtitle: subtitle,
          );
        }

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(), // 리스트뷰 자체 스크롤 비활성화
          shrinkWrap: true, // 내용에 맞게 크기 조정
          padding: const EdgeInsets.all(20),
          itemCount: filteredMeetings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final meeting = filteredMeetings[index];
            return MeetingCardWidget(
              key: ValueKey(meeting.id), // 성능 최적화: 안정적인 key 사용
              meeting: meeting,
              onTap: () => _handleMeetingTap(meeting),
            );
          },
        );
      },
    );
  }

  /// ❌ 빈 상태 UI
  Widget _buildEmptyState({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 모임 카드 탭 핸들러
  void _handleMeetingTap(AvailableMeeting meeting) {
    Navigator.pushNamed(
      context, 
      '/meeting_detail',
      arguments: meeting,
    );
    
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '${meeting.title} 모험에 관심이 있으시군요! 👀',
      emotion: SherpiEmotion.thinking,
    );
  }

  /// 🎯 모임 개설 FAB (한국형 모임앱 스타일)
  Widget _buildCreateMeetingFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCreateMeeting,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '모임 개설',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
    // TODO: 모임 개설 화면으로 이동
    Navigator.pushNamed(context, '/meeting_create');
    
    // Sherpi 격려 메시지
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '새로운 모임을 개설해보세요! 함께할 사람들이 기다리고 있어요 🎉',
      emotion: SherpiEmotion.cheering,
    );
  }

  // 🤖 AI 추천 시스템 헬퍼 메서드들

  /// 사용자 스탯 기반 추천 카테고리 결정
  MeetingCategory _getRecommendedCategory(GlobalStats stats) {
    final dominantStat = _getDominantStat(stats);
    
    switch (dominantStat) {
      case 'stamina':
      case 'willpower':
        return MeetingCategory.exercise; // 체력/의지력 → 운동
      case 'knowledge':
      case 'technique':
        return MeetingCategory.study; // 지식/기술 → 스터디
      case 'sociality':
        return MeetingCategory.networking; // 사교성 → 네트워킹
      default:
        // 균형잡힌 경우 레벨에 따라 결정
        final user = ref.read(globalUserProvider);
        if (user.level < 10) return MeetingCategory.networking; // 초보는 네트워킹부터
        if (user.level < 20) return MeetingCategory.study; // 중급은 스터디
        return MeetingCategory.exercise; // 고급은 운동
    }
  }

  /// 사용자의 가장 높은 스탯 찾기
  String _getDominantStat(GlobalStats stats) {
    final statMap = {
      'stamina': stats.stamina,
      'knowledge': stats.knowledge,
      'technique': stats.technique,
      'sociality': stats.sociality,
      'willpower': stats.willpower,
    };
    
    String dominantStat = 'sociality';
    double maxValue = 0.0;
    
    statMap.forEach((key, value) {
      if (value > maxValue) {
        maxValue = value;
        dominantStat = key;
      }
    });
    
    return dominantStat;
  }

  /// AI 기반 개인화 추천 모임 리스트 생성
  List<AvailableMeeting> _getRecommendedMeetings(GlobalUser user) {
    final allMeetings = ref.watch(globalAvailableMeetingsProvider);
    final recommendedCategory = _getRecommendedCategory(user.stats);
    
    // 1차: 추천 카테고리의 모임들
    var categoryMeetings = allMeetings
        .where((meeting) => meeting.category == recommendedCategory)
        .toList();
    
    // 2차: 스탯 기반 점수 계산 및 정렬
    categoryMeetings.sort((a, b) {
      final scoreA = _calculateRecommendationScore(a, user.stats);
      final scoreB = _calculateRecommendationScore(b, user.stats);
      return scoreB.compareTo(scoreA);
    });
    
    // 3차: 참여 가능한 모임만 필터링
    final availableMeetings = categoryMeetings
        .where((meeting) => meeting.canJoin)
        .take(8) // 최대 8개
        .toList();
    
    // 4차: 다른 카테고리에서도 고점수 모임 추가 (다양성 확보)
    if (availableMeetings.length < 5) {
      final otherMeetings = allMeetings
          .where((meeting) => 
              meeting.category != recommendedCategory && 
              meeting.canJoin)
          .toList();
      
      otherMeetings.sort((a, b) {
        final scoreA = _calculateRecommendationScore(a, user.stats);
        final scoreB = _calculateRecommendationScore(b, user.stats);
        return scoreB.compareTo(scoreA);
      });
      
      availableMeetings.addAll(
        otherMeetings.take(5 - availableMeetings.length)
      );
    }
    
    return availableMeetings;
  }

  /// 모임에 대한 개인화 추천 점수 계산
  double _calculateRecommendationScore(AvailableMeeting meeting, GlobalStats stats) {
    double score = 0.0;
    
    // 1. 카테고리별 기본 점수 (스탯 기반)
    switch (meeting.category) {
      case MeetingCategory.exercise:
      case MeetingCategory.outdoor:
        score += (stats.stamina * 0.4) + (stats.willpower * 0.3);
        break;
      case MeetingCategory.study:
      case MeetingCategory.reading:
        score += (stats.knowledge * 0.4) + (stats.technique * 0.3);
        break;
      case MeetingCategory.networking:
      case MeetingCategory.culture:
        score += (stats.sociality * 0.5) + (stats.willpower * 0.2);
        break;
      case MeetingCategory.all:
        // 전체는 평균 스탯 사용
        final avgStat = (stats.stamina + stats.knowledge + stats.technique + 
            stats.sociality + stats.willpower) / 5;
        score += avgStat * 0.3;
        break;
    }
    
    // 2. 시간대 보너스 (곧 시작하는 모임 우대)
    final hoursUntilStart = meeting.timeUntilStart.inHours;
    if (hoursUntilStart > 0 && hoursUntilStart <= 48) {
      score += (48 - hoursUntilStart) * 0.5; // 가까운 미래일수록 높은 점수
    }
    
    // 3. 참여율 보너스 (적당히 찬 모임 우대)
    final participationRate = meeting.participationRate;
    if (participationRate >= 0.3 && participationRate <= 0.7) {
      score += 10.0; // 30-70% 참여율이 이상적
    }
    
    // 4. 유료/무료 보너스 (레벨에 따라 차등)
    final user = ref.read(globalUserProvider);
    if (meeting.type == MeetingType.paid && user.level >= 15) {
      score += 5.0; // 고레벨 사용자는 유료 모임 선호
    } else if (meeting.type == MeetingType.free && user.level < 15) {
      score += 3.0; // 저레벨 사용자는 무료 모임 선호
    }
    
    // 5. 태그 매칭 보너스 (카테고리 관련 키워드 기반)
    final categoryKeywords = _getCategoryKeywords(meeting.category);
    final matchingTags = meeting.tags
        .where((tag) => categoryKeywords.any((keyword) => 
            tag.toLowerCase().contains(keyword.toLowerCase()) || 
            keyword.toLowerCase().contains(tag.toLowerCase())))
        .length;
    score += matchingTags * 2.0;
    
    return score;
  }

  /// 카테고리별 키워드 목록 반환
  List<String> _getCategoryKeywords(MeetingCategory category) {
    switch (category) {
      case MeetingCategory.exercise:
        return ['운동', '헬스', '요가', '필라테스', '스포츠', '피트니스', '축구', '농구', '배구'];
      case MeetingCategory.study:
        return ['공부', '스터디', '학습', '자격증', '시험', '토론', '세미나', '강의'];
      case MeetingCategory.reading:
        return ['독서', '책', '소설', '에세이', '북클럽', '작가', '문학', '도서'];
      case MeetingCategory.networking:
        return ['네트워킹', '모임', '친목', '파티', '만남', '사교', '커뮤니티', '교류'];
      case MeetingCategory.culture:
        return ['문화', '영화', '뮤지컬', '연극', '공연', '전시', '콘서트', '예술'];
      case MeetingCategory.outdoor:
        return ['야외', '등산', '캠핑', '산책', '하이킹', '트레킹', '여행', '자연'];
      case MeetingCategory.all:
        return ['모임', '활동', '체험', '참여'];
    }
  }
}

/// 카테고리 선택 탭 Delegate
class _CategorySelectorDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;
  final List<MeetingCategory> categories;

  _CategorySelectorDelegate({
    required this.controller,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: controller,
            isScrollable: true, // 7개 카테고리 - 가로 스크롤 필요
            tabAlignment: TabAlignment.start, // 왼쪽부터 배치
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            indicator: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: categories.map((category) => 
              Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          category.displayName,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).toList(),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 72.0;

  @override
  double get minExtent => 72.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

