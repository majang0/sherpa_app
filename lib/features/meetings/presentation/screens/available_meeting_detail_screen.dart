import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../models/available_meeting_model.dart';
import '../widgets/meeting_info_card_widget.dart';
import '../widgets/meeting_participants_widget.dart';
import '../widgets/meeting_requirements_widget.dart';
import '../widgets/meeting_image_gallery_widget.dart';
import '../../utils/meeting_animations.dart';

/// 🏔️ 모임 세부사항 화면
/// RPG 퀘스트 상세 정보 페이지 컨셉으로 설계
class AvailableMeetingDetailScreen extends ConsumerStatefulWidget {
  final AvailableMeeting meeting;

  const AvailableMeetingDetailScreen({
    super.key,
    required this.meeting,
  });

  @override
  ConsumerState<AvailableMeetingDetailScreen> createState() => _AvailableMeetingDetailScreenState();
}

class _AvailableMeetingDetailScreenState extends ConsumerState<AvailableMeetingDetailScreen>
    with TickerProviderStateMixin, MeetingAnimationMixin {
  
  // 🚀 성능 최적화된 애니메이션 지속시간 오버라이드
  @override
  Duration get animationDuration => MeetingAnimations.slowDuration;

  @override
  Widget build(BuildContext context) {
    final currentPoints = ref.watch(globalTotalPointsProvider);

    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: SherpaCleanAppBar(
        title: '모험 세부사항',
      ),
      body: AnimatedMeetingCard(
        fadeAnimation: fadeAnimation,
        slideAnimation: slideAnimation,
        child: CustomScrollView(
                slivers: [
                  // 🎨 메인 헤더 (그라데이션 배경)
                  _buildMainHeader(),
                  
                  // 📝 상세 정보 섹션들
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🖼️ 모임 이미지 갤러리 (이미지가 있는 경우만 표시)
                          if (widget.meeting.hasImages) ...[
                            MeetingImageGalleryWidget(
                              imageFileNames: widget.meeting.imageFileNames,
                              height: 220,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // 기본 정보 카드
                          MeetingInfoCardWidget(meeting: widget.meeting),
                          
                          const SizedBox(height: 20),
                          
                          // 호스트 및 참가자 정보
                          MeetingParticipantsWidget(meeting: widget.meeting),
                          
                          const SizedBox(height: 20),
                          
                          // 참여 조건 및 준비물
                          MeetingRequirementsWidget(meeting: widget.meeting),
                          
                          const SizedBox(height: 20),
                          
                          // 위치 및 교통 정보
                          _buildLocationInfo(),
                          
                          const SizedBox(height: 20),
                          
                          // 포인트 안내
                          _buildPointInfo(currentPoints),
                          
                          const SizedBox(height: 100), // 하단 버튼 공간
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      
      // 🎯 하단 고정 액션 버튼
      bottomNavigationBar: _buildBottomActionBar(currentPoints),
    );
  }

  /// 🎨 메인 헤더 (히어로 섹션)
  Widget _buildMainHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.meeting.category.color.withValues(alpha: 0.8),
                widget.meeting.category.color.withValues(alpha: 0.6),
                widget.meeting.category.color.withValues(alpha: 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 및 상태 태그
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.meeting.category.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            widget.meeting.category.displayName,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.meeting.statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.meeting.statusColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.meeting.status,
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 제목
                Text(
                  widget.meeting.title,
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 설명
                Text(
                  widget.meeting.description,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // 기본 정보 요약
                Row(
                  children: [
                    _buildQuickInfo(
                      icon: Icons.schedule_rounded,
                      text: widget.meeting.formattedDate,
                    ),
                    const SizedBox(width: 20),
                    _buildQuickInfo(
                      icon: Icons.people_rounded,
                      text: '${widget.meeting.currentParticipants}/${widget.meeting.maxParticipants}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📍 빠른 정보 아이템
  Widget _buildQuickInfo({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// 🗺️ 위치 정보 카드
  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: ModernColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '만날 장소',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            widget.meeting.location,
            style: GoogleFonts.notoSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.meeting.detailedLocation,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: ModernColors.textSecondary,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 길찾기 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: 지도 앱 연동
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('지도 앱으로 길찾기 (구현 예정)'),
                    backgroundColor: ModernColors.primary,
                  ),
                );
              },
              icon: const Icon(Icons.directions_rounded),
              label: Text(
                '길찾기',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: ModernColors.primary,
                side: BorderSide(color: ModernColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 💰 포인트 안내 카드
  Widget _buildPointInfo(int currentPoints) {
    final fee = widget.meeting.participationFee;
    final hasEnoughPoints = currentPoints >= fee;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasEnoughPoints 
              ? [ModernColors.success.withValues(alpha: 0.1), ModernColors.success.withValues(alpha: 0.05)]
              : [ModernColors.warning.withValues(alpha: 0.1), ModernColors.warning.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasEnoughPoints 
              ? ModernColors.success.withValues(alpha: 0.2)
              : ModernColors.warning.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: hasEnoughPoints ? ModernColors.success : ModernColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '참여 비용',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '참여 수수료',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${fee.toString()} P',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: hasEnoughPoints ? ModernColors.success : ModernColors.warning,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '보유 포인트',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${currentPoints.toString()} P',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (!hasEnoughPoints) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: ModernColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '포인트가 부족합니다. 퀘스트나 일일 목표를 완료해보세요!',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 🎯 하단 액션 바
  Widget _buildBottomActionBar(int currentPoints) {
    final canJoin = widget.meeting.canJoin;
    final hasEnoughPoints = currentPoints >= widget.meeting.participationFee;
    final shouldEnable = canJoin && hasEnoughPoints;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: shouldEnable ? _handleJoinMeeting : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: shouldEnable 
                  ? widget.meeting.category.color 
                  : Colors.grey.shade300,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (shouldEnable) ...[
                  const Icon(Icons.add_rounded, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '모험에 참여하기',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.block_rounded, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    !canJoin ? widget.meeting.status : '포인트 부족',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 모임 참여 처리
  void _handleJoinMeeting() {
    Navigator.pushNamed(
      context,
      '/meeting_application',
      arguments: widget.meeting,
    );
  }
}
