// lib/shared/widgets/components/molecules/sherpa_meeting_card_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';
import '../../../../features/meetings/models/available_meeting_model.dart';

/// 2025 디자인 트렌드를 반영한 현대적 모임 카드 컴포넌트
/// 글래스모피즘, 뉴모피즘, 마이크로 인터랙션을 적용한 프리미엄 카드 디자인
class SherpaMeetingCard2025 extends StatefulWidget {
  final AvailableMeeting meeting;
  final VoidCallback onTap;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final bool isLiked;
  final bool isBookmarked;
  final bool isRecommended;
  final SherpaMeetingCardVariant2025 variant;
  final SherpaMeetingCardSize size;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final GlassNeuElevation elevation;
  final String? category;
  final Color? customColor;

  const SherpaMeetingCard2025({
    Key? key,
    required this.meeting,
    required this.onTap,
    this.onLike,
    this.onShare,
    this.onBookmark,
    this.isLiked = false,
    this.isBookmarked = false,
    this.isRecommended = false,
    this.variant = SherpaMeetingCardVariant2025.glass,
    this.size = SherpaMeetingCardSize.medium,
    this.width,
    this.height,
    this.margin,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.elevation = GlassNeuElevation.medium,
    this.category,
    this.customColor,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 모임 카드 (글래스 스타일)
  factory SherpaMeetingCard2025.standard({
    Key? key,
    required AvailableMeeting meeting,
    required VoidCallback onTap,
    VoidCallback? onLike,
    bool isLiked = false,
    String? category,
  }) {
    return SherpaMeetingCard2025(
      key: key,
      meeting: meeting,
      onTap: onTap,
      onLike: onLike,
      isLiked: isLiked,
      category: category,
      variant: SherpaMeetingCardVariant2025.glass,
      size: SherpaMeetingCardSize.medium,
    );
  }

  /// 추천 모임 카드 (하이브리드 스타일)
  factory SherpaMeetingCard2025.recommended({
    Key? key,
    required AvailableMeeting meeting,
    required VoidCallback onTap,
    VoidCallback? onLike,
    bool isLiked = false,
    String? category,
  }) {
    return SherpaMeetingCard2025(
      key: key,
      meeting: meeting,
      onTap: onTap,
      onLike: onLike,
      isLiked: isLiked,
      isRecommended: true,
      category: category,
      variant: SherpaMeetingCardVariant2025.hybrid,
      size: SherpaMeetingCardSize.large,
      elevation: GlassNeuElevation.high,
    );
  }

  /// 컴팩트 모임 카드 (작은 크기)
  factory SherpaMeetingCard2025.compact({
    Key? key,
    required AvailableMeeting meeting,
    required VoidCallback onTap,
    String? category,
  }) {
    return SherpaMeetingCard2025(
      key: key,
      meeting: meeting,
      onTap: onTap,
      category: category,
      variant: SherpaMeetingCardVariant2025.neu,
      size: SherpaMeetingCardSize.small,
    );
  }

  /// 플로팅 모임 카드 (독립적)
  factory SherpaMeetingCard2025.floating({
    Key? key,
    required AvailableMeeting meeting,
    required VoidCallback onTap,
    VoidCallback? onLike,
    VoidCallback? onShare,
    VoidCallback? onBookmark,
    bool isLiked = false,
    bool isBookmarked = false,
    String? category,
  }) {
    return SherpaMeetingCard2025(
      key: key,
      meeting: meeting,
      onTap: onTap,
      onLike: onLike,
      onShare: onShare,
      onBookmark: onBookmark,
      isLiked: isLiked,
      isBookmarked: isBookmarked,
      category: category,
      variant: SherpaMeetingCardVariant2025.floating,
      size: SherpaMeetingCardSize.large,
      elevation: GlassNeuElevation.extraHigh,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  State<SherpaMeetingCard2025> createState() => _SherpaMeetingCard2025State();
}

class _SherpaMeetingCard2025State extends State<SherpaMeetingCard2025>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _likeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _likeAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );
    
    _likeController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: MicroInteractions.easeOutQuart,
    ));
    
    _likeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _likeController,
      curve: MicroInteractions.bounceOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _likeController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleLike() {
    widget.onLike?.call();
    _likeController.forward().then((_) => _likeController.reverse());
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableMicroInteractions) return;
    
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getCardConfiguration();
    
    Widget card = MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width ?? config.width,
                height: widget.height ?? config.height,
                margin: widget.margin ?? EdgeInsets.only(bottom: AppSizes.paddingM),
                decoration: _getCardDecoration(config),
                child: _buildCardContent(config),
              ),
            );
          },
        ),
      ),
    );

    // AI 추천 표시
    if (widget.isRecommended) {
      card = Stack(
        children: [
          card,
          Positioned(
            top: 8,
            right: 8,
            child: _buildRecommendedBadge(config),
          ),
        ],
      );
    }

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      card = MicroInteractions.slideInFade(
        child: card,
        direction: SlideDirection.bottom,
      );
    }

    return card;
  }

  Widget _buildCardContent(MeetingCardConfiguration config) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(config.borderRadius),
      child: Row(
        children: [
          // 왼쪽 이미지/아이콘 섹션
          _buildImageSection(config),
          
          // 오른쪽 콘텐츠 섹션
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(config.contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 카테고리 + 액션 버튼들
                  _buildHeaderSection(config),
                  
                  SizedBox(height: config.spacing),
                  
                  // 중단: 제목
                  _buildTitleSection(config),
                  
                  SizedBox(height: config.spacing * 0.75),
                  
                  // 하단: 정보 섹션
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(config),
                        const Spacer(),
                        _buildBottomSection(config),
                      ],
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

  Widget _buildImageSection(MeetingCardConfiguration config) {
    final categoryColor = widget.customColor ?? 
        (widget.category != null 
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    return Container(
      width: config.imageWidth,
      height: config.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(config.borderRadius),
          bottomLeft: Radius.circular(config.borderRadius),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withOpacity(0.8),
            categoryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // 글래스 효과 오버레이
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(config.borderRadius),
                  bottomLeft: Radius.circular(config.borderRadius),
                ),
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.5),
                  radius: 1.5,
                  colors: [
                    AppColors2025.glassWhite20.withOpacity(0.3),
                    Colors.transparent,
                    categoryColor.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
          
          // 카테고리 이모티콘
          Center(
            child: Text(
              widget.meeting.category.emoji,
              style: TextStyle(fontSize: config.iconSize),
            ),
          ),
          
          // 타입 표시 (무료/유료)
          if (widget.meeting.type == MeetingType.free)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors2025.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '무료',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors2025.textOnPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(MeetingCardConfiguration config) {
    return Row(
      children: [
        Expanded(
          child: _buildCategoryTag(config),
        ),
        SizedBox(width: config.spacing),
        _buildActionButtons(config),
      ],
    );
  }

  Widget _buildCategoryTag(MeetingCardConfiguration config) {
    final categoryColor = widget.customColor ?? 
        (widget.category != null 
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: config.tagPadding,
        vertical: config.tagPadding * 0.5,
      ),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(config.tagRadius),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(widget.meeting.category),
            size: config.tagIconSize,
            color: categoryColor,
          ),
          SizedBox(width: config.spacing * 0.5),
          Flexible(
            child: Text(
              widget.meeting.category.displayName,
              style: GoogleFonts.notoSans(
                fontSize: config.tagTextSize,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MeetingCardConfiguration config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 좋아요 버튼
        if (widget.onLike != null)
          AnimatedBuilder(
            animation: _likeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _likeAnimation.value,
                child: GestureDetector(
                  onTap: _handleLike,
                  child: Container(
                    padding: EdgeInsets.all(config.actionButtonPadding),
                    decoration: BoxDecoration(
                      color: widget.isLiked 
                          ? AppColors2025.error.withOpacity(0.15)
                          : AppColors2025.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isLiked 
                            ? AppColors2025.error 
                            : AppColors2025.border,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: config.actionIconSize,
                      color: widget.isLiked 
                          ? AppColors2025.error 
                          : AppColors2025.textTertiary,
                    ),
                  ),
                ),
              );
            },
          ),
        
        // 북마크 버튼
        if (widget.onBookmark != null) ...[
          SizedBox(width: config.spacing * 0.5),
          GestureDetector(
            onTap: widget.onBookmark,
            child: Container(
              padding: EdgeInsets.all(config.actionButtonPadding),
              decoration: BoxDecoration(
                color: widget.isBookmarked 
                    ? AppColors2025.secondary.withOpacity(0.15)
                    : AppColors2025.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isBookmarked 
                      ? AppColors2025.secondary 
                      : AppColors2025.border,
                  width: 1,
                ),
              ),
              child: Icon(
                widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: config.actionIconSize,
                color: widget.isBookmarked 
                    ? AppColors2025.secondary 
                    : AppColors2025.textTertiary,
              ),
            ),
          ),
        ],
        
        // 공유 버튼
        if (widget.onShare != null) ...[
          SizedBox(width: config.spacing * 0.5),
          GestureDetector(
            onTap: widget.onShare,
            child: Container(
              padding: EdgeInsets.all(config.actionButtonPadding),
              decoration: BoxDecoration(
                color: AppColors2025.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors2025.border,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.share_outlined,
                size: config.actionIconSize,
                color: AppColors2025.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitleSection(MeetingCardConfiguration config) {
    return Text(
      widget.meeting.title,
      style: GoogleFonts.notoSans(
        fontSize: config.titleSize,
        fontWeight: FontWeight.w700,
        color: AppColors2025.textPrimary,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoSection(MeetingCardConfiguration config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 정보
        _buildInfoRow(
          Icons.schedule_outlined,
          _formatDateTime(widget.meeting.dateTime),
          config,
        ),
        
        SizedBox(height: config.spacing * 0.5),
        
        // 위치 정보
        _buildInfoRow(
          widget.meeting.location == '온라인' 
              ? Icons.videocam_outlined 
              : Icons.location_on_outlined,
          widget.meeting.location,
          config,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, MeetingCardConfiguration config) {
    return Row(
      children: [
        Icon(
          icon,
          size: config.infoIconSize,
          color: AppColors2025.textTertiary,
        ),
        SizedBox(width: config.spacing * 0.5),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: config.infoTextSize,
              color: AppColors2025.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(MeetingCardConfiguration config) {
    return Row(
      children: [
        // 참가자 정보
        _buildParticipantInfo(config),
        
        const Spacer(),
        
        // 가격 정보
        _buildPriceInfo(config),
      ],
    );
  }

  Widget _buildParticipantInfo(MeetingCardConfiguration config) {
    final participantRatio = widget.meeting.currentParticipants / widget.meeting.maxParticipants;
    final isAlmostFull = participantRatio >= 0.8;
    
    return Row(
      children: [
        Icon(
          Icons.group_outlined,
          size: config.infoIconSize,
          color: isAlmostFull ? AppColors2025.warning : AppColors2025.textTertiary,
        ),
        SizedBox(width: config.spacing * 0.5),
        Text(
          '${widget.meeting.currentParticipants}/${widget.meeting.maxParticipants}',
          style: GoogleFonts.notoSans(
            fontSize: config.infoTextSize,
            fontWeight: FontWeight.w600,
            color: isAlmostFull ? AppColors2025.warning : AppColors2025.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo(MeetingCardConfiguration config) {
    final isFree = widget.meeting.type == MeetingType.free || 
                   (widget.meeting.price ?? 0) == 0;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: config.pricePadding,
        vertical: config.pricePadding * 0.5,
      ),
      decoration: BoxDecoration(
        color: isFree 
            ? AppColors2025.success.withOpacity(0.15)
            : AppColors2025.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(config.priceRadius),
        border: Border.all(
          color: isFree 
              ? AppColors2025.success 
              : AppColors2025.primary,
          width: 1,
        ),
      ),
      child: Text(
        isFree ? '무료' : '${_formatPrice((widget.meeting.price ?? 0).toInt())}원',
        style: GoogleFonts.notoSans(
          fontSize: config.priceTextSize,
          fontWeight: FontWeight.w700,
          color: isFree 
              ? AppColors2025.success 
              : AppColors2025.primary,
        ),
      ),
    );
  }

  Widget _buildRecommendedBadge(MeetingCardConfiguration config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors2025.secondary,
            AppColors2025.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors2025.secondary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: AppColors2025.textOnPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            'AI 추천',
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors2025.textOnPrimary,
            ),
          ),
        ],
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).shimmer(
      duration: 2000.ms,
      color: AppColors2025.textOnPrimary.withOpacity(0.5),
    );
  }

  MeetingCardConfiguration _getCardConfiguration() {
    switch (widget.size) {
      case SherpaMeetingCardSize.small:
        return MeetingCardConfiguration(
          width: double.infinity,
          height: 100,
          imageWidth: 70,
          borderRadius: AppSizes.radiusM,
          contentPadding: 12,
          spacing: 6,
          titleSize: 14,
          tagTextSize: 10,
          tagIconSize: 12,
          tagPadding: 6,
          tagRadius: 8,
          infoTextSize: 11,
          infoIconSize: 14,
          priceTextSize: 10,
          pricePadding: 6,
          priceRadius: 8,
          actionIconSize: 16,
          actionButtonPadding: 6,
          iconSize: 24,
        );
      case SherpaMeetingCardSize.medium:
        return MeetingCardConfiguration(
          width: double.infinity,
          height: 120,
          imageWidth: 88,
          borderRadius: AppSizes.radiusL,
          contentPadding: 16,
          spacing: 8,
          titleSize: 16,
          tagTextSize: 12,
          tagIconSize: 14,
          tagPadding: 8,
          tagRadius: 10,
          infoTextSize: 12,
          infoIconSize: 16,
          priceTextSize: 12,
          pricePadding: 8,
          priceRadius: 10,
          actionIconSize: 18,
          actionButtonPadding: 8,
          iconSize: 32,
        );
      case SherpaMeetingCardSize.large:
        return MeetingCardConfiguration(
          width: double.infinity,
          height: 140,
          imageWidth: 100,
          borderRadius: AppSizes.radiusXL,
          contentPadding: 20,
          spacing: 10,
          titleSize: 18,
          tagTextSize: 13,
          tagIconSize: 16,
          tagPadding: 10,
          tagRadius: 12,
          infoTextSize: 13,
          infoIconSize: 18,
          priceTextSize: 13,
          pricePadding: 10,
          priceRadius: 12,
          actionIconSize: 20,
          actionButtonPadding: 10,
          iconSize: 36,
        );
    }
  }

  BoxDecoration _getCardDecoration(MeetingCardConfiguration config) {
    final baseColor = widget.customColor ?? AppColors2025.surface;
    
    switch (widget.variant) {
      case SherpaMeetingCardVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: widget.elevation,
          color: baseColor,
          borderRadius: config.borderRadius,
          opacity: 0.95,
        );

      case SherpaMeetingCardVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: widget.elevation,
          baseColor: baseColor,
          borderRadius: config.borderRadius,
        );

      case SherpaMeetingCardVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: baseColor,
          borderRadius: config.borderRadius,
          elevation: 20,
        );

      case SherpaMeetingCardVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.elevation,
          color: baseColor,
          borderRadius: config.borderRadius,
          glassOpacity: widget.isRecommended ? 0.25 : 0.15,
        );

      case SherpaMeetingCardVariant2025.minimal:
        return BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(config.borderRadius),
          border: Border.all(
            color: AppColors2025.border,
            width: 1,
          ),
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;
    
    if (difference == 0) {
      return '오늘 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return '내일 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference < 7) {
      final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return '${weekdays[dateTime.weekday - 1]} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatPrice(int price) {
    if (price >= 10000) {
      return '${(price / 10000).toStringAsFixed(price % 10000 == 0 ? 0 : 1)}만';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}천';
    }
    return price.toString();
  }

  IconData _getCategoryIcon(MeetingCategory category) {
    switch (category) {
      case MeetingCategory.all:
        return Icons.star;
      case MeetingCategory.exercise:
        return Icons.fitness_center;
      case MeetingCategory.study:
        return Icons.school;
      case MeetingCategory.reading:
        return Icons.menu_book;
      case MeetingCategory.networking:
        return Icons.people;
      case MeetingCategory.culture:
        return Icons.theater_comedy;
      case MeetingCategory.outdoor:
        return Icons.landscape;
    }
  }
}

// ==================== 모델 클래스들 ====================

enum SherpaMeetingCardVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  floating,    // 플로팅 글래스
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  minimal,     // 미니멀 (기본 테두리)
}

enum SherpaMeetingCardSize {
  small,       // 100px 높이
  medium,      // 120px 높이 (기본)
  large,       // 140px 높이
}

// ==================== 도우미 클래스들 ====================

class MeetingCardConfiguration {
  final double width;
  final double height;
  final double imageWidth;
  final double borderRadius;
  final double contentPadding;
  final double spacing;
  final double titleSize;
  final double tagTextSize;
  final double tagIconSize;
  final double tagPadding;
  final double tagRadius;
  final double infoTextSize;
  final double infoIconSize;
  final double priceTextSize;
  final double pricePadding;
  final double priceRadius;
  final double actionIconSize;
  final double actionButtonPadding;
  final double iconSize;

  const MeetingCardConfiguration({
    required this.width,
    required this.height,
    required this.imageWidth,
    required this.borderRadius,
    required this.contentPadding,
    required this.spacing,
    required this.titleSize,
    required this.tagTextSize,
    required this.tagIconSize,
    required this.tagPadding,
    required this.tagRadius,
    required this.infoTextSize,
    required this.infoIconSize,
    required this.priceTextSize,
    required this.pricePadding,
    required this.priceRadius,
    required this.actionIconSize,
    required this.actionButtonPadding,
    required this.iconSize,
  });
}