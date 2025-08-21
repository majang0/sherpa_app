import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

enum SherpaAvatarSize {
  extraSmall,  // 24px
  small,       // 32px
  medium,      // 48px
  large,       // 64px
  extraLarge,  // 96px
}

enum SherpaAvatarVariant {
  circle,      // 원형 아바타
  rounded,     // 둥근 모서리 사각형
  square,      // 사각형
}

class SherpaAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final SherpaAvatarSize size;
  final SherpaAvatarVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? child;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final bool showOnlineStatus;
  final bool isOnline;
  final Widget? badge;  // 레벨, 상태 등 배지 표시

  const SherpaAvatar({
    Key? key,
    this.imageUrl,
    this.name,
    this.size = SherpaAvatarSize.medium,
    this.variant = SherpaAvatarVariant.circle,
    this.backgroundColor,
    this.textColor,
    this.child,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.badge,
  }) : super(key: key);

  // 팩토리 생성자들
  factory SherpaAvatar.user({
    Key? key,
    String? imageUrl,
    required String name,
    SherpaAvatarSize size = SherpaAvatarSize.medium,
    VoidCallback? onTap,
    bool showOnlineStatus = false,
    bool isOnline = false,
  }) {
    return SherpaAvatar(
      key: key,
      imageUrl: imageUrl,
      name: name,
      size: size,
      onTap: onTap,
      showBorder: true,
      showOnlineStatus: showOnlineStatus,
      isOnline: isOnline,
    );
  }

  factory SherpaAvatar.initials({
    Key? key,
    required String name,
    SherpaAvatarSize size = SherpaAvatarSize.medium,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return SherpaAvatar(
      key: key,
      name: name,
      size: size,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onTap: onTap,
    );
  }

  factory SherpaAvatar.icon({
    Key? key,
    required IconData icon,
    SherpaAvatarSize size = SherpaAvatarSize.medium,
    Color? backgroundColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return SherpaAvatar(
      key: key,
      size: size,
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Icon(
        icon,
        color: iconColor ?? Colors.white,
        size: _getIconSize(size),
      ),
    );
  }

  factory SherpaAvatar.sherpi({
    Key? key,
    SherpaAvatarSize size = SherpaAvatarSize.medium,
    VoidCallback? onTap,
    Widget? badge,
  }) {
    return SherpaAvatar(
      key: key,
      size: size,
      backgroundColor: AppColors.sherpiBackground,
      onTap: onTap,
      badge: badge,
      child: Text(
        '셰',
        style: GoogleFonts.notoSans(
          fontSize: _getInitialsSize(size),
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = _getSize();
    final bool interactive = onTap != null;

    return GestureDetector(
      onTap: interactive ? () {
        HapticFeedback.lightImpact();
        onTap!();
      } : null,
      child: Stack(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: _getBorderRadius(),
              border: showBorder ? Border.all(
                color: borderColor ?? AppColors.border,
                width: 2,
              ) : null,
              boxShadow: interactive ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: ClipRRect(
              borderRadius: _getBorderRadius(),
              child: _buildContent(),
            ),
          ),
          
          // 온라인 상태 표시
          if (showOnlineStatus)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: _getStatusSize(),
                height: _getStatusSize(),
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.textLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            
          // 배지 표시
          if (badge != null)
            Positioned(
              right: -4,
              top: -4,
              child: badge!,
            ),
        ],
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case SherpaAvatarSize.extraSmall:
        return 24;
      case SherpaAvatarSize.small:
        return 32;
      case SherpaAvatarSize.medium:
        return 48;
      case SherpaAvatarSize.large:
        return 64;
      case SherpaAvatarSize.extraLarge:
        return 96;
    }
  }

  double _getStatusSize() {
    switch (size) {
      case SherpaAvatarSize.extraSmall:
        return 6;
      case SherpaAvatarSize.small:
        return 8;
      case SherpaAvatarSize.medium:
        return 12;
      case SherpaAvatarSize.large:
        return 16;
      case SherpaAvatarSize.extraLarge:
        return 20;
    }
  }

  static double _getIconSize(SherpaAvatarSize size) {
    switch (size) {
      case SherpaAvatarSize.extraSmall:
        return 12;
      case SherpaAvatarSize.small:
        return 16;
      case SherpaAvatarSize.medium:
        return 24;
      case SherpaAvatarSize.large:
        return 32;
      case SherpaAvatarSize.extraLarge:
        return 48;
    }
  }

  static double _getInitialsSize(SherpaAvatarSize size) {
    switch (size) {
      case SherpaAvatarSize.extraSmall:
        return 10;
      case SherpaAvatarSize.small:
        return 12;
      case SherpaAvatarSize.medium:
        return 18;
      case SherpaAvatarSize.large:
        return 24;
      case SherpaAvatarSize.extraLarge:
        return 36;
    }
  }

  BorderRadius _getBorderRadius() {
    switch (variant) {
      case SherpaAvatarVariant.circle:
        return BorderRadius.circular(_getSize() / 2);
      case SherpaAvatarVariant.rounded:
        return BorderRadius.circular(AppSizes.radiusS);
      case SherpaAvatarVariant.square:
        return BorderRadius.zero;
    }
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;
    if (imageUrl != null) return Colors.grey[200]!;
    
    // 이름 기반 색상 생성
    if (name != null) {
      final colors = [
        AppColors.primary,
        AppColors.secondary,
        AppColors.success,
        AppColors.warning,
        AppColors.info,
        AppColors.reading,
        AppColors.meeting,
        AppColors.exercise,
      ];
      final index = name!.hashCode.abs() % colors.length;
      return colors[index];
    }
    
    return AppColors.primary;
  }

  Widget _buildContent() {
    // 커스텀 child가 있으면 우선 사용
    if (child != null) {
      return Center(child: child!);
    }

    // 이미지 URL이 있으면 이미지 표시
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitials();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        },
      );
    }

    // 이름이 있으면 이니셜 표시
    if (name != null && name!.isNotEmpty) {
      return _buildInitials();
    }

    // 기본 아이콘
    return Icon(
      Icons.person,
      color: textColor ?? Colors.white,
      size: _getIconSize(size),
    );
  }

  Widget _buildInitials() {
    if (name == null || name!.isEmpty) return Container();
    
    String initials = '';
    List<String> nameParts = name!.trim().split(' ');
    
    if (nameParts.isNotEmpty) {
      initials = nameParts[0][0].toUpperCase();
      if (nameParts.length > 1) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    return Center(
      child: Text(
        initials,
        style: GoogleFonts.notoSans(
          fontSize: _getInitialsSize(size),
          fontWeight: FontWeight.w700,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}

// 그룹 아바타 (여러 사용자)
class SherpaGroupAvatar extends StatelessWidget {
  final List<String> names;
  final List<String>? imageUrls;
  final SherpaAvatarSize size;
  final int maxDisplay;
  final VoidCallback? onTap;

  const SherpaGroupAvatar({
    Key? key,
    required this.names,
    this.imageUrls,
    this.size = SherpaAvatarSize.medium,
    this.maxDisplay = 3,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getAvatarSize();
    final displayCount = names.length > maxDisplay ? maxDisplay : names.length;
    final remainingCount = names.length - maxDisplay;

    return GestureDetector(
      onTap: onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap!();
      } : null,
      child: SizedBox(
        width: avatarSize + (displayCount - 1) * avatarSize * 0.7,
        height: avatarSize,
        child: Stack(
          children: [
            // 개별 아바타들
            for (int i = 0; i < displayCount; i++)
              Positioned(
                left: i * avatarSize * 0.7,
                child: SherpaAvatar(
                  name: names[i],
                  imageUrl: imageUrls != null && i < imageUrls!.length 
                      ? imageUrls![i] 
                      : null,
                  size: size,
                  showBorder: true,
                  borderColor: Colors.white,
                ),
              ),
            
            // 남은 인원수 표시
            if (remainingCount > 0)
              Positioned(
                left: displayCount * avatarSize * 0.7,
                child: SherpaAvatar(
                  size: size,
                  backgroundColor: AppColors.textLight,
                  child: Text(
                    '+$remainingCount',
                    style: GoogleFonts.notoSans(
                      fontSize: _getTextSize(),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getAvatarSize() {
    switch (size) {
      case SherpaAvatarSize.extraSmall:
        return 24;
      case SherpaAvatarSize.small:
        return 32;
      case SherpaAvatarSize.medium:
        return 48;
      case SherpaAvatarSize.large:
        return 64;
      case SherpaAvatarSize.extraLarge:
        return 96;
    }
  }

  double _getTextSize() {
    switch (size) {
      case SherpaAvatarSize.extraSmall:
        return 8;
      case SherpaAvatarSize.small:
        return 10;
      case SherpaAvatarSize.medium:
        return 12;
      case SherpaAvatarSize.large:
        return 14;
      case SherpaAvatarSize.extraLarge:
        return 18;
    }
  }
}