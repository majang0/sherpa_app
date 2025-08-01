// lib/features/meetings/presentation/widgets/modern_meeting_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/available_meeting_model.dart';

/// 🎨 모던 모임 카드 - 한국형 가로 레이아웃 (문토/소모임 스타일)
/// 왼쪽 이미지 + 오른쪽 콘텐츠 레이아웃으로 오버플로우 방지 및 가독성 향상
class ModernMeetingCard extends ConsumerWidget {
  final AvailableMeeting meeting;
  final VoidCallback onTap;
  final VoidCallback? onLike;
  final bool isLiked;
  final double? width;

  const ModernMeetingCard({
    super.key,
    required this.meeting,
    required this.onTap,
    this.onLike,
    this.isLiked = false,
    this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // 부모의 전체 너비 사용
        height: 120, // 고정 높이로 일관성 유지
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: IntrinsicWidth(
          child: Row(
            children: [
              // 📸 왼쪽 이미지 섹션 (정사각형)
              _buildLeftImageSection(),
              
              // 📝 오른쪽 콘텐츠 섹션
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단: 카테고리 태그 + 좋아요 버튼
                      Row(
                        children: [
                          Flexible(child: _buildCategoryTag()),
                          const SizedBox(width: 8),
                          if (onLike != null) _buildLikeButton(),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 중단: 제목
                      _buildTitleSection(),
                      
                      const SizedBox(height: 6),
                      
                      // 하단: 날짜/위치 정보 + 참가자/가격 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoSection(),
                            const Spacer(),
                            _buildBottomSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 200.ms),
    );
  }

  /// 📸 왼쪽 이미지 섹션 (가로형 레이아웃용)
  Widget _buildLeftImageSection() {
    return Container(
      width: 88, // 고정 너비
      height: 120, // 카드 전체 높이와 동일
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            meeting.category.color.withOpacity(0.8),
            meeting.category.color,
          ],
        ),
      ),
      child: Stack(
        children: [
          // 🌄 배경 패턴
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                gradient: RadialGradient(
                  center: const Alignment(0.3, -0.3),
                  radius: 1.2,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                    meeting.category.color.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          
          // 🏔️ 카테고리 아이콘 (중앙)
          Center(
            child: Text(
              meeting.category.emoji,
              style: const TextStyle(fontSize: 32),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.3)),
          ),
          
          // 📅 상태 표시 (하단)
          if (meeting.status == '임박')
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'D-${meeting.timeUntilStart.inDays}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: meeting.statusColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 📝 제목 섹션 (가로형용 간결 버전)
  Widget _buildTitleSection() {
    return Text(
      meeting.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.notoSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
    );
  }

  /// 📍 정보 섹션 (가로형용 간결 버전 + 분위기 태그) - 오버플로우 방지
  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 첫 번째 줄: 위치 + 날짜 (오버플로우 방지)
        Row(
          children: [
            // 📍 위치
            Icon(
              meeting.location == '온라인' 
                ? Icons.videocam_outlined 
                : Icons.location_on_outlined,
              size: 12,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Text(
                meeting.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // 📅 날짜 (Flexible로 감싸서 오버플로우 방지)
            Icon(
              Icons.schedule_rounded,
              size: 12,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 1,
              child: Text(
                meeting.formattedDate.split(' ')[0], // 날짜 부분만
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // 두 번째 줄: 분위기 태그들 (오버플로우 방지를 위한 Wrap 사용)
        Wrap(
          spacing: 6,
          runSpacing: 2,
          children: [
            _buildAtmosphereTag(),
            _buildDifficultyTag(),
          ],
        ),
      ],
    );
  }
  
  /// 🌊 분위기 태그 (부담 없는 / 활발한 / 진지한)
  Widget _buildAtmosphereTag() {
    final atmosphere = _getAtmosphereFromCategory();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: atmosphere['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        atmosphere['text'],
        style: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: atmosphere['color'],
        ),
      ),
    );
  }
  
  /// 🎯 난이도 태그 (초보환영 / 자유로운 / 전문적)  
  Widget _buildDifficultyTag() {
    final difficulty = _getDifficultyFromType();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: difficulty['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty['text'],
        style: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: difficulty['color'],
        ),
      ),
    );
  }
  
  /// 카테고리별 분위기 결정 (한국 모임 문화 특성 반영)
  Map<String, dynamic> _getAtmosphereFromCategory() {
    switch (meeting.category) {
      case MeetingCategory.exercise:
      case MeetingCategory.outdoor:
        return {'text': '활발한', 'color': Colors.orange};
      case MeetingCategory.study:
      case MeetingCategory.reading:
        return {'text': '진지한', 'color': Colors.blue};
      case MeetingCategory.culture:
        return {'text': '여유로운', 'color': Colors.purple};
      case MeetingCategory.networking:
        return {'text': '부담없는', 'color': Colors.green};
      default:
        return {'text': '편안한', 'color': Colors.grey};
    }
  }
  
  /// 모임 타입별 난이도 결정
  Map<String, dynamic> _getDifficultyFromType() {
    if (meeting.type == MeetingType.free) {
      return {'text': '초보환영', 'color': Colors.green};
    } else if (meeting.currentParticipants < meeting.maxParticipants / 2) {
      return {'text': '여유있음', 'color': Colors.blue};
    } else {
      return {'text': '인기모임', 'color': Colors.red};
    }
  }

  /// 💰 하단 섹션 (가로형용 간결 버전)
  Widget _buildBottomSection() {
    return Row(
      children: [
        // 참가자 현황 (간결) - Expanded로 유연하게 처리
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group_outlined,
                size: 14,
                color: meeting.canJoin ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${meeting.currentParticipants}/${meeting.maxParticipants}',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: meeting.canJoin ? AppColors.primary : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 8),
        
        // 가격 표시 (간결)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: meeting.type == MeetingType.free 
              ? AppColors.success.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            meeting.type == MeetingType.free 
              ? '무료'
              : '${(meeting.price ?? 0).toInt()}P',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: meeting.type == MeetingType.free 
                ? AppColors.success
                : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// ❤️ 좋아요 버튼 (가로형용 간결 버전)
  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: onLike,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : AppColors.textSecondary,
          size: 16,
        ),
      ).animate(target: isLiked ? 1 : 0)
        .scale(duration: 200.ms, curve: Curves.elasticOut),
    );
  }

  /// 🏷️ 카테고리 태그 (가로형용 간결 버전)
  Widget _buildCategoryTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: meeting.category.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              meeting.category.emoji,
              style: const TextStyle(fontSize: 10),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                meeting.category.displayName,
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: meeting.category.color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🎨 산 패턴 페인터
class MountainPatternPainter extends CustomPainter {
  final Color color;

  MountainPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 첫 번째 산
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.3,
      size.width * 0.5, size.height * 0.6,
    );
    
    // 두 번째 산
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.4,
      size.width, size.height * 0.7,
    );
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}