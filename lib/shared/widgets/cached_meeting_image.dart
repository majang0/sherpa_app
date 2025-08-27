// lib/shared/widgets/cached_meeting_image.dart

import 'package:flutter/material.dart';
import '../../core/theme/modern_colors.dart';
import '../../features/meetings/models/available_meeting_model.dart';
import '../utils/meeting_image_cache_manager.dart';
import '../utils/meeting_image_manager.dart';

/// 캐시된 모임 이미지 위젯
/// 이미지 캐싱을 자동으로 처리하여 성능을 최적화합니다.
class CachedMeetingImage extends StatelessWidget {
  final AvailableMeeting? meeting;
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool showShimmer;
  
  const CachedMeetingImage({
    super.key,
    this.meeting,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showShimmer = true,
  }) : assert(
    meeting != null || imagePath != null,
    'Either meeting or imagePath must be provided',
  );
  
  @override
  Widget build(BuildContext context) {
    final imageManager = MeetingImageManager();
    final cacheManager = MeetingImageCacheManager();
    
    // 이미지 경로 결정
    String? finalImagePath;
    if (imagePath != null) {
      finalImagePath = imagePath;
    } else if (meeting != null) {
      finalImagePath = imageManager.getImageForMeeting(meeting!);
    }
    
    // 이미지가 없는 경우 이모지 플레이스홀더 표시
    if (finalImagePath == null) {
      return _buildEmojiPlaceholder(meeting);
    }
    
    // 캐시된 이미지 위젯
    Widget imageWidget = cacheManager.getCachedImage(
      finalImagePath,
      width: width,
      height: height,
      fit: fit,
      placeholder: showShimmer ? _buildShimmerPlaceholder() : _buildEmojiPlaceholder(meeting),
      errorWidget: _buildEmojiPlaceholder(meeting),
    );
    
    // BorderRadius 적용
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
  
  /// 이모지 플레이스홀더
  Widget _buildEmojiPlaceholder(AvailableMeeting? meeting) {
    final categoryColor = meeting?.category.color ?? ModernColors.primary;
    final categoryEmoji = meeting?.category.emoji ?? '👥';
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withValues(alpha: 0.8),
            categoryColor.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          categoryEmoji,
          style: TextStyle(
            fontSize: width != null && width! < 100 ? 24 : 48,
            height: 1.0,
          ),
        ),
      ),
    );
  }
  
  /// 쉬머 플레이스홀더
  Widget _buildShimmerPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: const _ShimmerAnimation(),
    );
  }
}

/// 쉬머 애니메이션 위젯
class _ShimmerAnimation extends StatefulWidget {
  const _ShimmerAnimation();
  
  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}