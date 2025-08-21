import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

enum SherpaChipVariant {
  filled,      // 배경색이 있는 칩
  outlined,    // 테두리만 있는 칩
  soft,        // 연한 배경의 칩
  gradient,    // 그라데이션 칩
}

enum SherpaChipSize {
  small,       // 높이 24px
  medium,      // 높이 32px
  large,       // 높이 40px
}

class SherpaChip extends StatelessWidget {
  final String label;
  final SherpaChipVariant variant;
  final SherpaChipSize size;
  final Color? color;
  final Color? backgroundColor;
  final Color? textColor;
  final Gradient? gradient;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool isEnabled;
  final String? category;  // 카테고리별 색상 자동 적용

  const SherpaChip({
    Key? key,
    required this.label,
    this.variant = SherpaChipVariant.filled,
    this.size = SherpaChipSize.medium,
    this.color,
    this.backgroundColor,
    this.textColor,
    this.gradient,
    this.leading,
    this.trailing,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
    this.isEnabled = true,
    this.category,
  }) : super(key: key);

  // 팩토리 생성자들
  factory SherpaChip.category({
    Key? key,
    required String label,
    required String category,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return SherpaChip(
      key: key,
      label: label,
      category: category,
      variant: SherpaChipVariant.soft,
      onTap: onTap,
      isSelected: isSelected,
    );
  }

  factory SherpaChip.status({
    Key? key,
    required String label,
    required Color color,
    Widget? leading,
  }) {
    return SherpaChip(
      key: key,
      label: label,
      color: color,
      variant: SherpaChipVariant.soft,
      size: SherpaChipSize.small,
      leading: leading,
    );
  }

  factory SherpaChip.filter({
    Key? key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onDelete,
    bool isSelected = false,
  }) {
    return SherpaChip(
      key: key,
      label: label,
      variant: SherpaChipVariant.outlined,
      onTap: onTap,
      onDelete: onDelete,
      isSelected: isSelected,
      trailing: onDelete != null ? Icon(Icons.close, size: 16) : null,
    );
  }

  factory SherpaChip.action({
    Key? key,
    required String label,
    Widget? leading,
    VoidCallback? onTap,
    Color? color,
  }) {
    return SherpaChip(
      key: key,
      label: label,
      variant: SherpaChipVariant.gradient,
      onTap: onTap,
      leading: leading,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool interactive = (onTap != null || onDelete != null) && isEnabled;
    
    return GestureDetector(
      onTap: interactive && onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap!();
      } : null,
      child: Container(
        height: _getHeight(),
        decoration: _getDecoration(),
        padding: _getPadding(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: _getTextStyle(),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete != null ? () {
                  HapticFeedback.lightImpact();
                  onDelete!();
                } : null,
                child: trailing!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case SherpaChipSize.small:
        return 24;
      case SherpaChipSize.medium:
        return 32;
      case SherpaChipSize.large:
        return 40;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case SherpaChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case SherpaChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case SherpaChipSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  BoxDecoration _getDecoration() {
    // 카테고리별 색상 결정
    Color chipColor = color ?? 
        (category != null ? AppColors.getCategoryColor(category!) : AppColors.primary);
    Color chipBgColor = backgroundColor ?? 
        (category != null ? AppColors.getCategoryBackgroundColor(category!) : AppColors.infoBackground);

    Color finalColor;
    Color finalBorderColor = Colors.transparent;
    Gradient? finalGradient;

    switch (variant) {
      case SherpaChipVariant.filled:
        finalColor = isSelected ? chipColor : chipBgColor;
        break;
        
      case SherpaChipVariant.outlined:
        finalColor = isSelected ? chipColor.withOpacity(0.1) : Colors.transparent;
        finalBorderColor = isSelected ? chipColor : AppColors.border;
        break;
        
      case SherpaChipVariant.soft:
        finalColor = isSelected ? chipColor.withOpacity(0.15) : chipBgColor;
        break;
        
      case SherpaChipVariant.gradient:
        finalColor = Colors.transparent;
        finalGradient = gradient ?? LinearGradient(
          colors: [chipColor, chipColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
    }

    return BoxDecoration(
      color: finalGradient == null ? finalColor : null,
      gradient: finalGradient,
      border: finalBorderColor != Colors.transparent 
          ? Border.all(color: finalBorderColor, width: 1) 
          : null,
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      boxShadow: isSelected && variant == SherpaChipVariant.filled ? [
        BoxShadow(
          color: chipColor.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ] : null,
    );
  }

  double _getBorderRadius() {
    switch (size) {
      case SherpaChipSize.small:
        return 12;
      case SherpaChipSize.medium:
        return 16;
      case SherpaChipSize.large:
        return 20;
    }
  }

  TextStyle _getTextStyle() {
    Color chipColor = color ?? 
        (category != null ? AppColors.getCategoryColor(category!) : AppColors.primary);

    Color finalTextColor;
    
    switch (variant) {
      case SherpaChipVariant.filled:
        finalTextColor = textColor ?? (isSelected ? Colors.white : chipColor);
        break;
      case SherpaChipVariant.outlined:
        finalTextColor = textColor ?? (isSelected ? chipColor : AppColors.textSecondary);
        break;
      case SherpaChipVariant.soft:
        finalTextColor = textColor ?? chipColor;
        break;
      case SherpaChipVariant.gradient:
        finalTextColor = textColor ?? Colors.white;
        break;
    }

    double fontSize;
    FontWeight fontWeight;
    
    switch (size) {
      case SherpaChipSize.small:
        fontSize = 11;
        fontWeight = FontWeight.w500;
        break;
      case SherpaChipSize.medium:
        fontSize = 12;
        fontWeight = FontWeight.w600;
        break;
      case SherpaChipSize.large:
        fontSize = 14;
        fontWeight = FontWeight.w600;
        break;
    }

    return GoogleFonts.notoSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: finalTextColor,
    );
  }
}

// 전용 칩 위젯들
class SherpaLevelChip extends StatelessWidget {
  final int level;
  final SherpaChipSize size;

  const SherpaLevelChip({
    Key? key,
    required this.level,
    this.size = SherpaChipSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SherpaChip(
      label: 'Lv.$level',
      variant: SherpaChipVariant.gradient,
      size: size,
      color: AppColors.getLevelColor(level),
      leading: Icon(
        Icons.star,
        size: size == SherpaChipSize.small ? 12 : 14,
        color: Colors.white,
      ),
    );
  }
}

class SherpaPointChip extends StatelessWidget {
  final int points;
  final SherpaChipSize size;

  const SherpaPointChip({
    Key? key,
    required this.points,
    this.size = SherpaChipSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SherpaChip(
      label: '${points}P',
      variant: SherpaChipVariant.gradient,
      size: size,
      gradient: AppColors.pointGradient,
      leading: Icon(
        Icons.monetization_on,
        size: size == SherpaChipSize.small ? 12 : 14,
        color: Colors.white,
      ),
    );
  }
}

class SherpaActivityChip extends StatelessWidget {
  final String activity;
  final bool isCompleted;
  final VoidCallback? onTap;

  const SherpaActivityChip({
    Key? key,
    required this.activity,
    this.isCompleted = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    
    switch (activity.toLowerCase()) {
      case '운동':
      case 'exercise':
        iconData = Icons.fitness_center;
        break;
      case '독서':
      case 'reading':
        iconData = Icons.book;
        break;
      case '모임':
      case 'meeting':
        iconData = Icons.group;
        break;
      case '일기':
      case 'diary':
        iconData = Icons.edit_note;
        break;
      case '집중':
      case 'focus':
        iconData = Icons.psychology;
        break;
      default:
        iconData = Icons.task_alt;
        break;
    }

    return SherpaChip(
      label: activity,
      category: activity,
      variant: isCompleted ? SherpaChipVariant.filled : SherpaChipVariant.soft,
      onTap: onTap,
      isSelected: isCompleted,
      leading: Icon(
        isCompleted ? Icons.check_circle : iconData,
        size: 14,
        color: isCompleted ? Colors.white : null,
      ),
    );
  }
}