import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';

enum SherpaCardVariant {
  elevated,    // 그림자가 있는 카드
  outlined,    // 테두리가 있는 카드  
  filled,      // 배경색이 있는 카드
  glass,       // 글래스모피즘 카드 (기존)
  // 2025 스타일 variants
  glass2025,   // 2025 글래스모피즘
  neu,         // 뉴모피즘
  glassNeu,    // 글래스 + 뉴모피즘 하이브리드
  floating,    // 플로팅 글래스
  soft,        // 소프트 뉴모피즘
}

enum SherpaCardSize {
  small,       // 높이 80px
  medium,      // 높이 120px  
  large,       // 높이 160px
  auto,        // 내용에 따라 자동
}

class SherpaCard extends StatelessWidget {
  final Widget child;
  final SherpaCardVariant variant;
  final SherpaCardSize size;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool isEnabled;
  final Widget? leading;
  final Widget? trailing;
  final String? category;  // 카테고리별 색상 적용용

  const SherpaCard({
    Key? key,
    required this.child,
    this.variant = SherpaCardVariant.elevated,
    this.size = SherpaCardSize.auto,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isEnabled = true,
    this.leading,
    this.trailing,
    this.category,
  }) : super(key: key);

  // 팩토리 생성자들 - 편리한 사용을 위해
  factory SherpaCard.elevated({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    String? category,
  }) {
    return SherpaCard(
      key: key,
      child: child,
      variant: SherpaCardVariant.elevated,
      onTap: onTap,
      padding: padding,
      category: category,
    );
  }

  factory SherpaCard.outlined({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    Color? borderColor,
    String? category,
  }) {
    return SherpaCard(
      key: key,
      child: child,
      variant: SherpaCardVariant.outlined,
      onTap: onTap,
      padding: padding,
      borderColor: borderColor,
      category: category,
    );
  }

  factory SherpaCard.filled({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    String? category,
  }) {
    return SherpaCard(
      key: key,
      child: child,
      variant: SherpaCardVariant.filled,
      onTap: onTap,
      padding: padding,
      backgroundColor: backgroundColor,
      category: category,
    );
  }

  factory SherpaCard.glass({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) {
    return SherpaCard(
      key: key,
      child: child,
      variant: SherpaCardVariant.glass,
      onTap: onTap,
      padding: padding,
    );
  }

  // ==================== 2025 스타일 팩토리 생성자들 ====================

  /// 2025 글래스모피즘 카드
  factory SherpaCard.glass2025({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    String? category,
    GlassNeuElevation elevation = GlassNeuElevation.medium,
  }) {
    return SherpaCard(
      key: key,
      child: child,
      variant: SherpaCardVariant.glass2025,
      onTap: onTap,
      padding: padding,
      category: category,
    );
  }

  /// 뉴모피즘 카드
  factory SherpaCard.neu({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    String? category,
    GlassNeuElevation elevation = GlassNeuElevation.medium,
    bool isPressed = false,
  }) {
    return SherpaCard(
      key: key,
      child: child,
      variant: SherpaCardVariant.neu,
      onTap: onTap,
      padding: padding,
      category: category,
    );
  }

  /// 글래스 + 뉴모피즘 하이브리드 카드
  factory SherpaCard.glassNeu({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    String? category,
    GlassNeuElevation elevation = GlassNeuElevation.medium,
  }) {
    return SherpaCard(
      key: key,
      child: child,
      variant: SherpaCardVariant.glassNeu,
      onTap: onTap,
      padding: padding,
      category: category,
    );
  }

  /// 플로팅 글래스 카드
  factory SherpaCard.floating({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    String? category,
  }) {
    return SherpaCard(
      key: key,
      child: child,
      variant: SherpaCardVariant.floating,
      onTap: onTap,
      padding: padding,
      category: category,
    );
  }

  /// 소프트 뉴모피즘 카드
  factory SherpaCard.soft({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    String? category,
  }) {
    return SherpaCard(
      key: key,
      child: child,
      variant: SherpaCardVariant.soft,
      onTap: onTap,
      padding: padding,
      category: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool interactive = onTap != null && isEnabled;
    
    return Container(
      width: width,
      height: _getHeight(),
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          onTap: interactive ? () {
            HapticFeedback.lightImpact();
            onTap!();
          } : null,
          child: Container(
            decoration: _getDecoration(),
            padding: padding ?? const EdgeInsets.all(AppSizes.paddingM),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  double? _getHeight() {
    if (height != null) return height;
    
    switch (size) {
      case SherpaCardSize.small:
        return 80;
      case SherpaCardSize.medium:
        return 120;
      case SherpaCardSize.large:
        return 160;
      case SherpaCardSize.auto:
        return null;
    }
  }

  BoxDecoration _getDecoration() {
    // 기존 스타일들을 위한 변수들
    Color cardColor;
    BoxBorder? border;
    List<BoxShadow>? shadows;
    
    // 카테고리별 색상 적용 (기존 + 2025)
    Color categoryColor = category != null 
        ? AppColors.getCategoryColor(category!) 
        : AppColors.primary;
    Color categoryColor2025 = category != null 
        ? AppColors2025.getCategoryColor2025(category!) 
        : AppColors2025.primary;
    Color categoryBgColor = category != null 
        ? AppColors.getCategoryBackgroundColor(category!) 
        : AppColors.infoBackground;

    switch (variant) {
      case SherpaCardVariant.elevated:
        cardColor = backgroundColor ?? AppColors.surface;
        shadows = [
          BoxShadow(
            color: categoryColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
        break;
        
      case SherpaCardVariant.outlined:
        cardColor = backgroundColor ?? AppColors.surface;
        border = Border.all(
          color: borderColor ?? categoryColor.withOpacity(0.2),
          width: 1.5,
        );
        break;
        
      case SherpaCardVariant.filled:
        cardColor = backgroundColor ?? categoryBgColor;
        break;
        
      case SherpaCardVariant.glass:
        cardColor = AppColors.surface.withOpacity(0.7);
        border = Border.all(
          color: AppColors.textPrimary.withOpacity(0.1),
          width: 1,
        );
        shadows = [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];
        break;

      // ==================== 2025 스타일 variants ====================
      
      case SherpaCardVariant.glass2025:
        return category != null 
            ? GlassNeuStyle.glassByCategory(
                category!,
                elevation: GlassNeuElevation.medium,
                borderRadius: AppSizes.radiusM,
              )
            : GlassNeuStyle.glassMorphism(
                elevation: GlassNeuElevation.medium,
                color: categoryColor2025,
                borderRadius: AppSizes.radiusM,
              );
        
      case SherpaCardVariant.neu:
        return GlassNeuStyle.neumorphism(
          elevation: GlassNeuElevation.medium,
          baseColor: backgroundColor ?? AppColors2025.neuBase,
          borderRadius: AppSizes.radiusM,
        );
        
      case SherpaCardVariant.glassNeu:
        return GlassNeuStyle.hybrid(
          elevation: GlassNeuElevation.medium,
          color: categoryColor2025,
          borderRadius: AppSizes.radiusM,
          glassOpacity: 0.15,
        );
        
      case SherpaCardVariant.floating:
        return GlassNeuStyle.floatingGlass(
          color: categoryColor2025,
          borderRadius: AppSizes.radiusM,
          elevation: 12,
        );
        
      case SherpaCardVariant.soft:
        return GlassNeuStyle.softNeumorphism(
          baseColor: backgroundColor ?? AppColors2025.neuBaseSoft,
          borderRadius: AppSizes.radiusM,
          intensity: 0.05,
        );
    }

    return BoxDecoration(
      color: gradient == null ? cardColor : null,
      gradient: gradient,
      border: border,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      boxShadow: isEnabled ? shadows : null,
    );
  }

  Widget _buildContent() {
    if (leading == null && trailing == null) {
      return child;
    }

    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSizes.paddingM),
        ],
        Expanded(child: child),
        if (trailing != null) ...[
          const SizedBox(width: AppSizes.paddingM),
          trailing!,
        ],
      ],
    );
  }
}

// 특수한 목적의 카드들
class SherpaInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Color? color;
  final VoidCallback? onTap;

  const SherpaInfoCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;
    
    return SherpaCard.elevated(
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: icon,
            ),
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
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textLight,
            ),
        ],
      ),
    );
  }
}

class SherpaStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget? icon;
  final Color? color;
  final String? trend;  // 증감 표시용

  const SherpaStatsCard({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.trend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;
    
    return SherpaCard.filled(
      backgroundColor: cardColor.withOpacity(0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: icon,
            ),
            const SizedBox(height: AppSizes.paddingS),
          ],
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: cardColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Text(
              trend!,
              style: GoogleFonts.notoSans(
                fontSize: 10,
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}