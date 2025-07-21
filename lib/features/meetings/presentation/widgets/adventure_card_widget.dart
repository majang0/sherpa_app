import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/available_meeting_model.dart';

/// 🎴 어드벤처 카드 위젯 - RPG 퀘스트 카드 스타일
/// 각 모임을 하나의 '모험'으로 표현하는 게임화된 카드 UI
class AdventureCardWidget extends StatefulWidget {
  final AvailableMeeting meeting;
  final VoidCallback onTap;

  const AdventureCardWidget({
    super.key,
    required this.meeting,
    required this.onTap,
  });

  @override
  State<AdventureCardWidget> createState() => _AdventureCardWidgetState();
}

class _AdventureCardWidgetState extends State<AdventureCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) {
              _animationController.reverse();
              widget.onTap();
            },
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                  if (_glowAnimation.value > 0)
                    BoxShadow(
                      color: widget.meeting.category.color.withValues(alpha: 0.3 * _glowAnimation.value),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🏷️ 상단: 카테고리 & 스코프 태그 영역
                    _buildTagSection(),
                    
                    // 📝 중앙: 메인 컨텐츠 영역
                    _buildMainContent(),
                    
                    // 📊 하단: 정보 표시 영역
                    _buildInfoSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🏷️ 태그 섹션 (카테고리 + 스코프)
  Widget _buildTagSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // 카테고리 태그
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: widget.meeting.category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.meeting.category.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.meeting.category.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.meeting.category.displayName,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.meeting.category.color,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 학교 태그 (대학 모임인 경우)
          if (widget.meeting.scope == MeetingScope.university && 
              widget.meeting.universityName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏫', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    widget.meeting.universityName!,
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const Spacer(),
          
          // 상태 표시
          _buildStatusBadge(),
        ],
      ),
    );
  }

  /// 📝 메인 컨텐츠 (제목 + 설명)
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 (가장 크게)
          Text(
            widget.meeting.title,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // 설명 (요약)
          Text(
            widget.meeting.description,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 📊 정보 섹션 (위치, 시간, 참가자)
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 첫 번째 줄: 위치, 시간
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.location_on_rounded,
                  text: widget.meeting.location,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.schedule_rounded,
                  text: widget.meeting.formattedDate,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 두 번째 줄: 참가자 수, 호스트
          Row(
            children: [
              Expanded(
                child: _buildParticipantInfo(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.person_rounded,
                  text: widget.meeting.hostName,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 액션 버튼
          _buildActionButton(),
        ],
      ),
    );
  }

  /// 📍 개별 정보 아이템
  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 👥 참가자 정보 (특별 스타일)
  Widget _buildParticipantInfo() {
    final ratio = widget.meeting.participationRate;
    
    return Row(
      children: [
        Icon(
          Icons.people_rounded,
          size: 16,
          color: ratio >= 0.8 ? AppColors.warning : AppColors.success,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.meeting.currentParticipants}/${widget.meeting.maxParticipants}명',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ratio >= 0.8 ? AppColors.warning : AppColors.success,
                ),
              ),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ratio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ratio >= 0.8 ? AppColors.warning : AppColors.success,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🏷️ 상태 배지
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.meeting.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.meeting.statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.meeting.status,
        style: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: widget.meeting.statusColor,
        ),
      ),
    );
  }

  /// 🎯 액션 버튼
  Widget _buildActionButton() {
    final canJoin = widget.meeting.canJoin;
    final fee = widget.meeting.participationFee;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canJoin ? widget.onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canJoin 
              ? widget.meeting.category.color 
              : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canJoin) ...[
              const Icon(Icons.add_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                fee > 0 ? '참여하기 (${fee.toStringAsFixed(0)}P)' : '참여하기',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else ...[
              const Icon(Icons.block_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.meeting.status,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
