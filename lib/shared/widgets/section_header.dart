import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';

/// 섹션 헤더 위젯 (공통 UI 패턴)
///
/// 사용처:
/// - goals_screen.dart (Line 180-227)
/// - ai_analysis_screen.dart (Line 428-461, 978-1008)
/// - routines_screen.dart (Line 66-101)
/// - goal_achievement_widget.dart (Line 256-317, 566-646)
///
/// 디자인:
/// - 4px 그라디언트 바 + 타이틀 + 선택적 trailing
/// - 2025 Material Design 3 스타일
class SectionHeader extends StatelessWidget {
  /// 섹션 제목
  final String title;

  /// 카운트 텍스트 (예: "총 3개")
  final String? countText;

  /// 그라디언트 시작 색상
  final Color primaryColor;

  /// 그라디언트 끝 색상
  final Color secondaryColor;

  /// 우측에 표시될 위젯 (예: "전체 보기" 링크)
  final Widget? trailing;

  /// 타이틀 폰트 크기 (기본: 18)
  final double titleFontSize;

  /// 수평 패딩 (기본: 16)
  final double horizontalPadding;

  /// 상단 패딩 (기본: 0)
  final double topPadding;

  /// 하단 패딩 (기본: 12)
  final double bottomPadding;

  const SectionHeader({
    super.key,
    required this.title,
    this.countText,
    this.primaryColor = ModernColors.primary,
    this.secondaryColor = ModernColors.secondary,
    this.trailing,
    this.titleFontSize = 18,
    this.horizontalPadding = 20,
    this.topPadding = 0,
    this.bottomPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
      ),
      child: Row(
        children: [
          // 그라디언트 바
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // 타이틀
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),

          // 카운트 텍스트
          if (countText != null) ...[
            Text(
              countText!,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.textSecondary.withValues(alpha: 0.7),
                letterSpacing: -0.1,
              ),
            ),
          ],

          // Trailing 위젯
          if (trailing != null) ...[
            if (countText == null) const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}
