/// AI 추천 결과 카드 위젯
/// AI가 추천한 모임들을 카드 형태로 표시

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

import '../../../../../core/theme/modern_colors.dart';
import '../../../../../core/constants/sherpi_emotions.dart';
import '../../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../../shared/widgets/components/molecules/participant_avatars_2025.dart';
import '../../../ai/models/ai_recommended_meeting.dart';
import '../../../models/available_meeting_model.dart';
import '../../../utils/meeting_image_utils.dart';

/// AI 추천 결과 카드들
class AIRecommendationResultCards extends ConsumerStatefulWidget {
  final List<AIRecommendedMeeting> recommendations;

  const AIRecommendationResultCards({
    super.key,
    required this.recommendations,
  });

  @override
  ConsumerState<AIRecommendationResultCards> createState() =>
      _AIRecommendationResultCardsState();
}

class _AIRecommendationResultCardsState
    extends ConsumerState<AIRecommendationResultCards>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ModernColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          _buildHeader(),

          // 추천 카드들
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.recommendations.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildRecommendationCard(
                    widget.recommendations[index],
                    index,
                  ),
                );
              },
            ),
          ),

          // 페이지 인디케이터
          _buildPageIndicator(),

          const SizedBox(height: 20),
        ],
      ),
    ).animate().slideY(
          begin: 1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 타이틀
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 셰르피 아이콘
              SizedBox(
                width: 32,
                height: 32,
                child: Image.asset(
                  SherpiEmotion.special.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 맞춤 추천 완료!',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  Text(
                    '당신을 위한 ${widget.recommendations.length}개의 모임',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // AI 분석 요약
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ModernColors.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: ModernColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '활동 패턴을 분석하여 가장 적합한 모임을 선별했어요',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: ModernColors.textPrimary,
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

  Widget _buildRecommendationCard(
      AIRecommendedMeeting recommendation, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        Navigator.pushNamed(
          context,
          '/meeting_detail',
          arguments: recommendation.meeting,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 섹션
            _buildImageSection(recommendation.meeting),

            // 콘텐츠 섹션
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 우선순위 & 매칭 점수
                    _buildMatchScore(recommendation, index),

                    const SizedBox(height: 12),

                    // 모임 정보
                    _buildMeetingInfo(recommendation.meeting),

                    const SizedBox(height: 16),

                    // AI 추천 이유
                    _buildRecommendationReason(recommendation),

                    const SizedBox(height: 16),

                    // 핵심 포인트
                    _buildKeyPoints(recommendation),

                    const SizedBox(height: 20),

                    // 액션 버튼
                    _buildActionButton(recommendation.meeting),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 100 * index))
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildImageSection(AvailableMeeting meeting) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            meeting.category.color.withValues(alpha: 0.8),
            meeting.category.color.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 이미지 또는 아이콘
          if (meeting.hasImages && meeting.imageFileNames.isNotEmpty)
            _buildMeetingImage(meeting)
          else
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    meeting.category.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),

          // 카테고리 배지
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
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
                      fontWeight: FontWeight.w600,
                      color: meeting.category.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingImage(AvailableMeeting meeting) {
    final firstImage = meeting.imageFileNames.first;

    if (firstImage.startsWith('asset:')) {
      final assetPath = 'assets/images/meeting/${firstImage.substring(6)}';
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            color: meeting.category.color.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return FutureBuilder<File?>(
      future: MeetingImageUtils.getMeetingImageFile(firstImage),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          );
        }
        return Container(
          color: meeting.category.color.withValues(alpha: 0.3),
        );
      },
    );
  }

  Widget _buildMatchScore(AIRecommendedMeeting recommendation, int index) {
    return Row(
      children: [
        // 우선순위 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: index == 0
                  ? [Colors.amber, Colors.orange]
                  : [ModernColors.primary, ModernColors.secondary],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                index == 0 ? Icons.star : Icons.recommend,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                index == 0 ? '최고 추천' : '추천 ${index + 1}',
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // 매칭 점수
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: recommendation.matchScore,
                        backgroundColor: ModernColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          recommendation.matchScore >= 0.8
                              ? Colors.green
                              : recommendation.matchScore >= 0.6
                                  ? Colors.orange
                                  : ModernColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${recommendation.matchPercentage}%',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                recommendation.matchLevel,
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  color: ModernColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingInfo(AvailableMeeting meeting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Text(
          meeting.title,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 8),

        // 위치 & 시간
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: ModernColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              meeting.location,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.access_time,
              size: 14,
              color: ModernColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              meeting.formattedDate,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 참가자 & 가격
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 참가자
            ParticipantAvatars2025(
              currentParticipants: meeting.currentParticipants,
              maxParticipants: meeting.maxParticipants,
              size: 28,
              overlapFactor: 0.65,
            ),

            // 가격
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: meeting.type == MeetingType.free
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: meeting.type == MeetingType.free
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: meeting.type == MeetingType.free
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationReason(AIRecommendedMeeting recommendation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: ModernColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'AI 추천 이유',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.reason,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: ModernColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPoints(AIRecommendedMeeting recommendation) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: recommendation.keyPoints.map((point) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ModernColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ModernColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 14,
                color: ModernColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                point,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(AvailableMeeting meeting) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedbackManager.mediumImpact();
          Navigator.pushNamed(
            context,
            '/meeting_detail',
            arguments: meeting,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              '자세히 보기',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.recommendations.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? ModernColors.primary
                : ModernColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        )
            .animate(target: _currentPage == index ? 1 : 0)
            .scaleX(begin: 1, end: 3, duration: 200.ms),
      ),
    );
  }
}
