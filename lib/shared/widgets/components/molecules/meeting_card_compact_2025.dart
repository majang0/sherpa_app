// lib/shared/widgets/components/molecules/meeting_card_compact_2025.dart

import 'package:flutter/material.dart';
import '../../../../features/meetings/models/available_meeting_model.dart';
import 'participant_avatars_2025.dart';

/// 2025 트렌드 컴팩트 모임 카드 - Neumorphism 효과 적용
class MeetingCardCompact2025 extends StatefulWidget {
  final AvailableMeeting meeting;
  final VoidCallback? onTap;
  final VoidCallback? onQuickJoin;
  final String? imageAsset;
  final bool showQuickJoin;
  
  const MeetingCardCompact2025({
    super.key,
    required this.meeting,
    this.onTap,
    this.onQuickJoin,
    this.imageAsset,
    this.showQuickJoin = true,
  });

  @override
  State<MeetingCardCompact2025> createState() => _MeetingCardCompact2025State();
}

class _MeetingCardCompact2025State extends State<MeetingCardCompact2025> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pressAnimation;
  late Animation<Color?> _shadowAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _shadowAnimation = ColorTween(
      begin: Colors.black.withOpacity(0.1),
      end: Colors.black.withOpacity(0.05),
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

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF0F0F3);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pressAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: Container(
              width: double.infinity,
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isPressed
                  ? [
                      // Inset shadow effect when pressed (simulated)
                      BoxShadow(
                        color: isDark 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                      BoxShadow(
                        color: isDark 
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(-2, -2),
                      ),
                    ]
                  : [
                      // Raised shadow effect
                      BoxShadow(
                        color: isDark 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(5, 5),
                      ),
                      BoxShadow(
                        color: isDark 
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.9),
                        blurRadius: 15,
                        offset: const Offset(-5, -5),
                      ),
                    ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    // Image Section
                    _buildImageSection(baseColor, isDark),
                    
                    // Content Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category & Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCategoryChip(isDark),
                                _buildStatusDot(),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Title
                            Expanded(
                              child: Text(
                                widget.meeting.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Time & Location
                            _buildInfoRow(isDark),
                            
                            const SizedBox(height: 12),
                            
                            // Bottom Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParticipantCount2025(
                                  currentParticipants: widget.meeting.currentParticipants,
                                  maxParticipants: widget.meeting.maxParticipants,
                                  fontSize: 11,
                                ),
                                if (widget.showQuickJoin && widget.onQuickJoin != null)
                                  _buildQuickJoinButton(isDark),
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
          ),
        );
      },
    );
  }

  Widget _buildImageSection(Color baseColor, bool isDark) {
    return Container(
      width: 120,
      height: double.infinity,
      decoration: BoxDecoration(
        color: baseColor,
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(3, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                widget.imageAsset ?? 'assets/images/meeting/3.jpg',
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
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.meeting.category.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.image_outlined,
                            size: 24,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Price overlay
            Positioned(
              top: 8,
              right: 8,
              child: _buildPriceTag(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.meeting.category.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.meeting.category.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.meeting.category.emoji,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            widget.meeting.category.displayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: widget.meeting.category.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: widget.meeting.statusColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: widget.meeting.statusColor.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.meeting.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.meeting.location,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantCount(bool isDark) {
    final isFull = widget.meeting.currentParticipants >= widget.meeting.maxParticipants;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFull ? Icons.people : Icons.people_outline,
            size: 12,
            color: isFull 
              ? Colors.orange 
              : (isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.meeting.currentParticipants}/${widget.meeting.maxParticipants}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isFull 
                ? Colors.orange 
                : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickJoinButton(bool isDark) {
    return GestureDetector(
      onTap: widget.onQuickJoin,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.meeting.category.color,
              widget.meeting.category.color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.meeting.category.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            // Neumorphic inner highlight
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: const Text(
          '빠른참여',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTag() {
    final isLowFee = widget.meeting.participationFee <= 1000;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isLowFee 
          ? Colors.green.withOpacity(0.9)
          : Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        widget.meeting.type == MeetingType.free 
          ? '무료' 
          : '${widget.meeting.participationFee.toInt()}P',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}