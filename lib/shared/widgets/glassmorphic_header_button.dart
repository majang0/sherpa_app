import 'package:flutter/material.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/animation/micro_interactions.dart';

/// Glassmorphic 스타일 헤더 버튼
///
/// 사용처:
/// - goals_screen.dart (Line 134-176)
/// - routines_screen.dart (Line 154-196)
///
/// 디자인:
/// - 반투명 배경 + 블러 효과
/// - 프리미엄 그림자
/// - MicroInteractions 통합
class GlassmorphicHeaderButton extends StatelessWidget {
  /// 버튼 아이콘
  final IconData icon;

  /// 탭 핸들러
  final VoidCallback onTap;

  /// 주요 색상 (그림자 및 아이콘 색상)
  final Color primaryColor;

  /// 버튼 크기 (기본: 44)
  final double size;

  /// 아이콘 크기 (기본: 20)
  final double iconSize;

  const GlassmorphicHeaderButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.primaryColor = ModernColors.primary,
    this.size = 44,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return MicroInteractions.tapResponse(
      onTap: onTap,
      scaleDownTo: 0.95,
      enableHaptic: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: primaryColor.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
