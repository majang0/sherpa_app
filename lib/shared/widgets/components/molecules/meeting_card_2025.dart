// lib/shared/widgets/components/molecules/meeting_card_2025.dart

import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../features/meetings/models/available_meeting_model.dart';
import '../../../../features/meetings/utils/meeting_image_utils.dart';
import 'participant_avatars_2025.dart';

/// 2025 트렌드 모임 카드 - Glassmorphism 효과 적용
class MeetingCard2025 extends StatefulWidget {
  final AvailableMeeting meeting;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;
  final String? imageAsset;
  final bool compact;
  
  const MeetingCard2025({
    super.key,
    required this.meeting,
    this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
    this.imageAsset,
    this.compact = false, // 컴팩트 모드 추가
  });

  @override
  State<MeetingCard2025> createState() => _MeetingCard2025State();
}

class _MeetingCard2025State extends State<MeetingCard2025> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
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
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onTap,
              child: Container(
                width: double.infinity,
                height: widget.compact ? 200 : 280,
                margin: widget.compact 
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark 
                            ? [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ]
                            : [
                                Colors.white.withOpacity(0.7),
                                Colors.white.withOpacity(0.3),
                              ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background Image
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: _buildImageWidget(),
                            ),
                          ),
                          
                          // Gradient Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.3, 1.0],
                                ),
                              ),
                            ),
                          ),
                          
                          // Content
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.all(widget.compact ? 16 : 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row - Category & Bookmark
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildCategoryChip(),
                                      if (widget.onBookmark != null)
                                        _buildBookmarkButton(),
                                    ],
                                  ),
                                  
                                  const Spacer(),
                                  
                                  // Title
                                  Text(
                                    widget.meeting.title,
                                    style: TextStyle(
                                      fontSize: widget.compact ? 16 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                    maxLines: widget.compact ? 2 : 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  
                                  SizedBox(height: widget.compact ? 6 : 8),
                                  
                                  // Location & Time
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: widget.compact ? 14 : 16,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      SizedBox(width: widget.compact ? 3 : 4),
                                      Expanded(
                                        child: Text(
                                          widget.meeting.location,
                                          style: TextStyle(
                                            fontSize: widget.compact ? 12 : 14,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: widget.compact ? 3 : 4),
                                  
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_outlined,
                                        size: widget.compact ? 14 : 16,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      SizedBox(width: widget.compact ? 3 : 4),
                                      Expanded(
                                        child: Text(
                                          widget.meeting.formattedDate,
                                          style: TextStyle(
                                            fontSize: widget.compact ? 12 : 14,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: widget.compact ? 8 : 12),
                                  
                                  // Bottom Row - Participants & Price
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ParticipantAvatars2025(
                                        currentParticipants: widget.meeting.currentParticipants,
                                        maxParticipants: widget.meeting.maxParticipants,
                                        size: widget.compact ? 24 : 28,
                                        overlapFactor: 0.65,
                                      ),
                                      _buildPriceChip(),
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
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip() {
    final double padding = widget.compact ? 8 : 12;
    final double fontSize = widget.compact ? 10 : 12;
    final double emojiSize = widget.compact ? 10 : 12;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding, 
        vertical: widget.compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: widget.meeting.category.color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(widget.compact ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: widget.meeting.category.color.withOpacity(0.3),
            blurRadius: widget.compact ? 6 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.meeting.category.emoji,
            style: TextStyle(fontSize: emojiSize),
          ),
          SizedBox(width: widget.compact ? 3 : 4),
          Text(
            widget.meeting.category.displayName,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    final double size = widget.compact ? 32 : 36;
    final double iconSize = widget.compact ? 16 : 18;
    
    return GestureDetector(
      onTap: widget.onBookmark,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildParticipantInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 14,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.meeting.currentParticipants}/${widget.meeting.maxParticipants}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChip() {
    final isLowFee = widget.meeting.participationFee <= 1000;
    final double horizontalPadding = widget.compact ? 8 : 10;
    final double verticalPadding = widget.compact ? 4 : 6;
    final double fontSize = widget.compact ? 10 : 12;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding, 
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: isLowFee 
          ? Colors.green.withOpacity(0.2)
          : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(widget.compact ? 12 : 16),
        border: Border.all(
          color: isLowFee 
            ? Colors.green.withOpacity(0.3)
            : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.meeting.type == MeetingType.free 
          ? '무료' 
          : '${widget.meeting.participationFee.toInt()}P',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: isLowFee ? Colors.green[100] : Colors.orange[100],
        ),
      ),
    );
  }

  /// 이미지 위젯 생성 - 실제 모임 이미지 우선, 없으면 이모지 표시
  Widget _buildImageWidget() {
    // 모임에 이미지가 있으면 확인
    if (widget.meeting.hasImages && widget.meeting.imageFileNames.isNotEmpty) {
      final firstImage = widget.meeting.imageFileNames.first;
      
      // asset: 플래그로 시작하면 assets 폴더에서 로드
      if (firstImage.startsWith('asset:')) {
        final assetPath = 'assets/images/meeting/${firstImage.substring(6)}';
        return Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildEmojiPlaceholder(),
        );
      }
      
      // 일반 이미지 파일은 MeetingImageUtils를 사용하여 로드
      return FutureBuilder<File?>(
        future: MeetingImageUtils.getMeetingImageFile(firstImage),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildEmojiPlaceholder(),
            );
          }
          return _buildEmojiPlaceholder();
        },
      );
    }
    
    // imageAsset이 제공된 경우 (하위 호환성)
    if (widget.imageAsset != null) {
      final imagePath = widget.imageAsset!;
      // 동적 이미지인지 확인 (파일 경로 형태)
      if (_isDynamicImagePath(imagePath)) {
        return _buildDynamicImage(imagePath);
      } else {
        // 정적 애셋 이미지
        return _buildAssetImage(imagePath);
      }
    }
    
    // 이미지가 없으면 카테고리 이모지 표시
    return _buildEmojiPlaceholder();
  }

  /// 동적 이미지 경로인지 확인
  bool _isDynamicImagePath(String path) {
    return !path.startsWith('assets/') && (path.contains('/') || path.endsWith('.jpg') || path.endsWith('.png'));
  }

  /// 동적 이미지 위젯 생성 (파일 시스템)
  Widget _buildDynamicImage(String filePath) {
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildEmojiPlaceholder(),
    );
  }

  /// 정적 애셋 이미지 위젯 생성
  Widget _buildAssetImage(String assetPath) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildEmojiPlaceholder(),
    );
  }

  /// 이미지 로드 실패 시 이모지 플레이스홀더
  Widget _buildErrorPlaceholder() {
    return _buildEmojiPlaceholder();
  }
  
  /// 이모지 플레이스홀더 (이미지가 없거나 로드 실패시)
  Widget _buildEmojiPlaceholder() {
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
        child: Text(
          widget.meeting.category.emoji,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}