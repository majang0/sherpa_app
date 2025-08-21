import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../atoms/sherpa_card.dart';

class SherpaActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;
  final String? actionText;
  final Color? color;
  final bool showBorder;
  final bool showShadow;

  const SherpaActionCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.onSecondaryTap,
    this.actionText,
    this.color,
    this.showBorder = false,
    this.showShadow = true,
  }) : super(key: key);

  factory SherpaActionCard.notification({
    Key? key,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    bool isNew = false,
  }) {
    return SherpaActionCard(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Icon(Icons.notifications, color: AppColors.info, size: 20),
      ),
      trailing: isNew ? Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
      ) : null,
      onTap: onTap,
      onSecondaryTap: onDismiss,
    );
  }

  factory SherpaActionCard.achievement({
    Key? key,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? color,
  }) {
    return SherpaActionCard(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? AppColors.warning).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Icon(Icons.emoji_events, color: color ?? AppColors.warning, size: 20),
      ),
      onTap: onTap,
      color: color,
    );
  }

  factory SherpaActionCard.task({
    Key? key,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    VoidCallback? onTap,
    VoidCallback? onToggle,
  }) {
    return SherpaActionCard(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isCompleted 
              ? AppColors.success.withOpacity(0.1)
              : AppColors.textLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? AppColors.success : AppColors.textLight,
          size: 20,
        ),
      ),
      trailing: IconButton(
        onPressed: onToggle,
        icon: Icon(
          isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
          color: isCompleted ? AppColors.success : AppColors.textLight,
        ),
        iconSize: 20,
      ),
      onTap: onTap,
    );
  }

  factory SherpaActionCard.setting({
    Key? key,
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return SherpaActionCard(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      trailing: trailing ?? Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap!();
      } : null,
      onSecondaryTap: onSecondaryTap != null ? () {
        HapticFeedback.lightImpact();
        onSecondaryTap!();
      } : null,
      child: SherpaCard(
        variant: showBorder ? SherpaCardVariant.outlined : SherpaCardVariant.elevated,
        onTap: null, // GestureDetector에서 처리
        child: Row(
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: AppSizes.paddingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (actionText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      actionText!,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color ?? AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSizes.paddingS),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}