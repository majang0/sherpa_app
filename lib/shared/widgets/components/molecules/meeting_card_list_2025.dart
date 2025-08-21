// lib/shared/widgets/components/molecules/meeting_card_list_2025.dart

import 'package:flutter/material.dart';
import '../../../../features/meetings/models/available_meeting_model.dart';
import 'participant_avatars_2025.dart';

/// 2025 트렌드 리스트형 모임 카드 - 미니멀리스트 디자인
class MeetingCardList2025 extends StatefulWidget {
  final AvailableMeeting meeting;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;
  final String? imageAsset;
  final bool showDivider;
  
  const MeetingCardList2025({
    super.key,
    required this.meeting,
    this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
    this.imageAsset,
    this.showDivider = true,
  });

  @override
  State<MeetingCardList2025> createState() => _MeetingCardList2025State();
}

class _MeetingCardList2025State extends State<MeetingCardList2025> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _backgroundAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
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

  void _handleHoverEnter() {
    setState(() => _isHovered = true);
    _animationController.forward();
  }

  void _handleHoverExit() {
    setState(() => _isHovered = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _handleHoverEnter(),
          onExit: (_) => _handleHoverExit(),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                  ? Color.lerp(
                      Colors.transparent,
                      Colors.white.withOpacity(0.03),
                      _backgroundAnimation.value,
                    )
                  : Color.lerp(
                      Colors.transparent,
                      Colors.black.withOpacity(0.02),
                      _backgroundAnimation.value,
                    ),
                border: widget.showDivider 
                  ? Border(
                      bottom: BorderSide(
                        color: isDark 
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08),
                        width: 0.5,
                      ),
                    )
                  : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    _buildImageSection(isDark),
                    
                    const SizedBox(width: 16),
                    
                    // Content Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.meeting.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                        height: 1.2,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _buildCategoryDot(),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.meeting.category.displayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: widget.meeting.category.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (widget.onBookmark != null)
                                _buildBookmarkButton(isDark),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Description
                          if (widget.meeting.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                widget.meeting.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          
                          // Info Row
                          Row(
                            children: [
                              _buildInfoItem(
                                icon: Icons.schedule_outlined,
                                text: widget.meeting.formattedDate,
                                isDark: isDark,
                              ),
                              _buildDivider(isDark),
                              _buildInfoItem(
                                icon: Icons.location_on_outlined,
                                text: widget.meeting.location,
                                isDark: isDark,
                                flex: true,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Bottom Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ParticipantAvatars2025(
                                    currentParticipants: widget.meeting.currentParticipants,
                                    maxParticipants: widget.meeting.maxParticipants,
                                    size: 24,
                                    overlapFactor: 0.6,
                                    maxVisible: 2,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildPriceChip(isDark),
                                ],
                              ),
                              _buildStatusChip(isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          widget.imageAsset ?? 'assets/images/meeting/4.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.meeting.category.color.withOpacity(0.8),
                    widget.meeting.category.color.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.meeting.category.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: widget.meeting.category.color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildBookmarkButton(bool isDark) {
    return GestureDetector(
      onTap: widget.onBookmark,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _isHovered
            ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
            : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: 18,
          color: widget.isBookmarked
            ? widget.meeting.category.color
            : (isDark ? Colors.white60 : Colors.black45),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    required bool isDark,
    bool flex = false,
  }) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return flex 
      ? Expanded(child: child)
      : child;
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.black26,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildParticipantChip(bool isDark) {
    final progress = widget.meeting.participationRate;
    final isNearFull = progress > 0.8;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isNearFull
          ? Colors.orange.withOpacity(0.1)
          : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNearFull
            ? Colors.orange.withOpacity(0.3)
            : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 12,
            color: isNearFull 
              ? Colors.orange 
              : (isDark ? Colors.white60 : Colors.black54),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.meeting.currentParticipants}/${widget.meeting.maxParticipants}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isNearFull 
                ? Colors.orange 
                : (isDark ? Colors.white60 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChip(bool isDark) {
    final isLowFee = widget.meeting.participationFee <= 1000;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLowFee 
          ? Colors.green.withOpacity(0.1)
          : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowFee 
            ? Colors.green.withOpacity(0.3)
            : Colors.orange.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        widget.meeting.type == MeetingType.free 
          ? '무료' 
          : '${widget.meeting.participationFee.toInt()}P',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isLowFee ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.meeting.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.meeting.statusColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.meeting.statusColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            widget.meeting.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.meeting.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}