// lib/features/meetings/presentation/widgets/sherpi_recommendation_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../models/available_meeting_model.dart';

/// 🤖 셰르피 AI 추천 섹션
/// 사용자 맞춤형 모임 추천과 셰르피의 친근한 안내를 결합
class SherpiRecommendationSection extends ConsumerStatefulWidget {
  final Map<String, double> userStats;
  final Function(AvailableMeeting) onMeetingTap;

  const SherpiRecommendationSection({
    super.key,
    required this.userStats,
    required this.onMeetingTap,
  });

  @override
  ConsumerState<SherpiRecommendationSection> createState() => 
      _SherpiRecommendationSectionState();
}

class _SherpiRecommendationSectionState 
    extends ConsumerState<SherpiRecommendationSection> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _sherpiAnimationController;
  late Animation<double> _sherpiAnimation;
  
  // 추천 타입
  int _currentRecommendationType = 0;
  final List<String> _recommendationTypes = [
    '나를 위한 맞춤 추천',
    '오늘의 인기 모임',
    '마감 임박 모임',
  ];

  @override
  void initState() {
    super.initState();
    
    // 셰르피 애니메이션
    _sherpiAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _sherpiAnimation = CurvedAnimation(
      parent: _sherpiAnimationController,
      curve: Curves.easeInOut,
    );
    _sherpiAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _sherpiAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meetings = ref.watch(globalMeetingProvider).availableMeetings;
    final recommendedMeetings = _getRecommendedMeetings(meetings);
    
    if (recommendedMeetings.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 🤖 셰르피 헤더
          _buildSherpiHeader(),
          
          // 📋 추천 모임 리스트
          Container(
            height: 200, // 조금 더 여유 있게 증가
            padding: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recommendedMeetings.length,
              itemBuilder: (context, index) {
                final meeting = recommendedMeetings[index];
                return _buildRecommendationCard(meeting, index);
              },
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  /// 🤖 셰르피 헤더
  Widget _buildSherpiHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 셰르피 아이콘
          AnimatedBuilder(
            animation: _sherpiAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _sherpiAnimation.value * 4 - 2),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/sherpi/sherpi_happy.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 12),
          
          // 추천 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '셰르피',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI 추천',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _changeRecommendationType,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _recommendationTypes[_currentRecommendationType],
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 전체보기 버튼
          TextButton(
            onPressed: () {
              // TODO: AI 추천 전체 화면으로 이동
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              '전체보기',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 추천 카드
  Widget _buildRecommendationCard(AvailableMeeting meeting, int index) {
    final matchScore = _calculateMatchScore(meeting);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () {
        widget.onMeetingTap(meeting);
        
        // 추천 모임 클릭 시 셰르피 반응
        ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.encouragement,
          customDialogue: '좋은 선택이에요! ${meeting.title}는 정말 재미있을 거예요! 🎯',
          emotion: SherpiEmotion.cheering,
        );
      },
      child: Container(
        width: screenWidth * 0.75, // 화면 너비의 75%로 반응형 적용
        constraints: BoxConstraints(
          minWidth: 250,
          maxWidth: 320,
        ),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 이미지 영역
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
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
                  // 카테고리 이모지
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Text(
                      meeting.category.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  
                  // 매칭 점수
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(matchScore * 100).toInt()}% 매칭',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 콘텐츠 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      meeting.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // 추천 이유
                    Text(
                      _getRecommendationReason(meeting),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // 하단 정보 - Flexible 사용으로 오버플로우 방지
                    Row(
                      children: [
                        // 날짜 & 시간 - Expanded로 유연하게 처리
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  meeting.formattedDate,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // 참가 버튼
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '참가하기',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms)
      .slideX(
        begin: 0.2, 
        end: 0, 
        delay: Duration(milliseconds: 100 * index),
        duration: 300.ms,
      );
  }

  /// 🎯 추천 모임 가져오기
  List<AvailableMeeting> _getRecommendedMeetings(List<AvailableMeeting> meetings) {
    switch (_currentRecommendationType) {
      case 0: // 맞춤 추천
        return _getPersonalizedRecommendations(meetings);
      case 1: // 인기 모임
        return _getPopularMeetings(meetings);
      case 2: // 마감 임박
        return _getUrgentMeetings(meetings);
      default:
        return [];
    }
  }

  /// 🎯 개인화 추천
  List<AvailableMeeting> _getPersonalizedRecommendations(
    List<AvailableMeeting> meetings,
  ) {
    final availableMeetings = meetings.where((m) => m.canJoin).toList();
    
    // 매칭 점수 계산
    final scoredMeetings = availableMeetings.map((meeting) {
      return MapEntry(meeting, _calculateMatchScore(meeting));
    }).toList();
    
    // 점수 순으로 정렬
    scoredMeetings.sort((a, b) => b.value.compareTo(a.value));
    
    // 상위 5개 반환
    return scoredMeetings
        .take(5)
        .map((entry) => entry.key)
        .toList();
  }

  /// 🔥 인기 모임
  List<AvailableMeeting> _getPopularMeetings(List<AvailableMeeting> meetings) {
    final availableMeetings = meetings.where((m) => m.canJoin).toList();
    
    // 참여율 순으로 정렬
    availableMeetings.sort((a, b) => 
      b.participationRate.compareTo(a.participationRate)
    );
    
    return availableMeetings.take(5).toList();
  }

  /// ⏰ 마감 임박 모임
  List<AvailableMeeting> _getUrgentMeetings(List<AvailableMeeting> meetings) {
    final now = DateTime.now();
    final urgentMeetings = meetings.where((meeting) {
      final hoursUntil = meeting.dateTime.difference(now).inHours;
      return meeting.canJoin && hoursUntil > 0 && hoursUntil <= 48;
    }).toList();
    
    // 시간 순으로 정렬
    urgentMeetings.sort((a, b) => 
      a.dateTime.compareTo(b.dateTime)
    );
    
    return urgentMeetings.take(5).toList();
  }

  /// 📊 매칭 점수 계산
  double _calculateMatchScore(AvailableMeeting meeting) {
    double score = 0.0;
    
    // 카테고리별 능력치 매칭
    switch (meeting.category) {
      case MeetingCategory.exercise:
      case MeetingCategory.outdoor:
        score += (widget.userStats['stamina'] ?? 0) * 0.3;
        score += (widget.userStats['willpower'] ?? 0) * 0.2;
        break;
      case MeetingCategory.study:
      case MeetingCategory.reading:
        score += (widget.userStats['knowledge'] ?? 0) * 0.3;
        score += (widget.userStats['technique'] ?? 0) * 0.2;
        break;
      case MeetingCategory.networking:
      case MeetingCategory.culture:
        score += (widget.userStats['sociality'] ?? 0) * 0.4;
        break;
      case MeetingCategory.all:
      default:
        score += 0.2;
    }
    
    // 시간 근접성 보너스
    final hoursUntil = meeting.dateTime.difference(DateTime.now()).inHours;
    if (hoursUntil > 24 && hoursUntil <= 72) {
      score += 0.2; // 1-3일 이내 보너스
    }
    
    // 참여 가능성 보너스
    if (meeting.currentParticipants < meeting.maxParticipants * 0.8) {
      score += 0.1; // 여유있는 모임 보너스
    }
    
    return (score / 0.8).clamp(0.0, 1.0); // 0-1 범위로 정규화
  }

  /// 💬 추천 이유 생성
  String _getRecommendationReason(AvailableMeeting meeting) {
    final score = _calculateMatchScore(meeting);
    
    if (score >= 0.8) {
      return '완벽한 매칭! 꼭 참여해보세요';
    } else if (score >= 0.6) {
      return '당신의 관심사와 잘 맞아요';
    } else if (meeting.participationRate >= 0.7) {
      return '많은 사람들이 참여 중이에요';
    } else if (meeting.timeUntilStart.inHours <= 48) {
      return '곧 시작해요! 서둘러 참여하세요';
    } else {
      return '새로운 경험을 해보세요';
    }
  }

  /// 🔄 추천 타입 변경
  void _changeRecommendationType() {
    setState(() {
      _currentRecommendationType = 
          (_currentRecommendationType + 1) % _recommendationTypes.length;
    });
    
    // 셰르피 메시지
    String message;
    SherpiEmotion emotion;
    
    switch (_currentRecommendationType) {
      case 0:
        message = '당신의 능력치와 관심사를 분석해서 추천해드릴게요! 🎯';
        emotion = SherpiEmotion.guiding;
        break;
      case 1:
        message = '지금 가장 인기 있는 모임들이에요! 🔥';
        emotion = SherpiEmotion.happy;
        break;
      case 2:
        message = '서둘러요! 곧 마감되는 모임들이에요! ⏰';
        emotion = SherpiEmotion.warning;
        break;
      default:
        message = '';
        emotion = SherpiEmotion.defaults;
    }
    
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: message,
      emotion: emotion,
    );
  }
}