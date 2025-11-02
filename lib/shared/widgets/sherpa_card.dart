import 'package:flutter/material.dart';
import '../../core/theme/modern_colors.dart';

class SherpaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;

  const SherpaCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ModernColors.gray200.withValues(
                  alpha: elevation != null
                      ? (elevation! / 20)
                      : 0.08), // ✅ elevation에 따른 그림자 조절
              blurRadius: elevation ?? 8,
              offset: Offset(0, (elevation ?? 8) / 4), // ✅ elevation에 따른 오프셋 조절
            ),
            if ((elevation ?? 8) > 10) // ✅ 높은 elevation일 때 추가 그림자
              BoxShadow(
                color: ModernColors.primary.withValues(alpha: 0.05),
                blurRadius: (elevation ?? 8) * 1.5,
                offset: Offset(0, (elevation ?? 8) / 2),
              ),
          ],
          border: Border.all(
            color: ModernColors.border.withValues(alpha: 0.05), // ✅ 미세한 테두리 추가
            width: 0.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
