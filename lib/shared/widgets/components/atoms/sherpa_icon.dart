import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

enum SherpaIconSize {
  small,   // 16px
  medium,  // 24px
  large,   // 32px
  extraLarge, // 48px
}

class SherpaIcon extends StatelessWidget {
  final IconData icon;
  final SherpaIconSize size;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool showBackground;
  final double? borderRadius;

  const SherpaIcon({
    Key? key,
    required this.icon,
    this.size = SherpaIconSize.medium,
    this.color,
    this.backgroundColor,
    this.onTap,
    this.padding,
    this.showBackground = false,
    this.borderRadius,
  }) : super(key: key);

  // 팩토리 생성자들
  factory SherpaIcon.button({
    Key? key,
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
    Color? backgroundColor,
    SherpaIconSize size = SherpaIconSize.medium,
  }) {
    return SherpaIcon(
      key: key,
      icon: icon,
      onTap: onTap,
      color: color,
      backgroundColor: backgroundColor,
      size: size,
      showBackground: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = _getIconSize();
    final double containerSize = iconSize + (showBackground ? 16 : 0);

    Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: color ?? AppColors.textPrimary,
    );

    if (showBackground) {
      iconWidget = Container(
        width: containerSize,
        height: containerSize,
        padding: padding ?? EdgeInsets.all(_getPadding()),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(
            borderRadius ?? _getBorderRadius(),
          ),
        ),
        child: iconWidget,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  double _getIconSize() {
    switch (size) {
      case SherpaIconSize.small:
        return 16;
      case SherpaIconSize.medium:
        return 24;
      case SherpaIconSize.large:
        return 32;
      case SherpaIconSize.extraLarge:
        return 48;
    }
  }

  double _getPadding() {
    switch (size) {
      case SherpaIconSize.small:
        return 4;
      case SherpaIconSize.medium:
        return 8;
      case SherpaIconSize.large:
        return 12;
      case SherpaIconSize.extraLarge:
        return 16;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case SherpaIconSize.small:
        return AppSizes.radiusS;
      case SherpaIconSize.medium:
        return AppSizes.radiusM;
      case SherpaIconSize.large:
        return AppSizes.radiusL;
      case SherpaIconSize.extraLarge:
        return AppSizes.radiusXL;
    }
  }
}