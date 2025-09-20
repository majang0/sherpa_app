// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';
import '../theme/modern_colors.dart';

/// 🎨 셰르파 앱 현대적 색상 시스템
/// ModernColors 기반의 깔끔하고 단순화된 블루-화이트 팔레트
@Deprecated(
    'Use ModernColors instead. This will be removed in future versions.')
class AppColors {
  // ==================== 🔵 브랜드 색상 (ModernColors 기반) ====================

  /// 기본 배경색
  static const Color background = ModernColors.background;
  static const Color surfaceBackground = ModernColors.surface;

  /// 주요 브랜드 색상
  static const Color primary = ModernColors.primary;
  static const Color primarySoft = ModernColors.primaryLight;
  static const Color primaryLight = ModernColors.primaryLighter;
  static const Color primaryDark = ModernColors.primaryHover;

  /// 보조 브랜드 색상
  static const Color secondary = ModernColors.secondary;
  static const Color secondaryLight = ModernColors.secondaryLight;
  @Deprecated('Use ModernColors.secondaryLight instead')
  static const Color secondaryPale = ModernColors.secondaryLight;

  /// 액센트 색상
  static const Color accent = ModernColors.accent;
  static const Color accentSoft = ModernColors.accent;
  static const Color accentDark = ModernColors.accentHover;

  /// Surface 색상
  static const Color surface = ModernColors.surface;
  static const Color surfaceElevated = ModernColors.surfaceElevated;

  // ==================== ✅ 상태 색상 (ModernColors 기반) ====================

  /// 성공
  static const Color success = ModernColors.success;
  static const Color successLight = ModernColors.success;
  static const Color successBackground = ModernColors.successLight;

  /// 경고
  static const Color warning = ModernColors.warning;
  static const Color warningLight = ModernColors.warning;
  static const Color warningBackground = ModernColors.warningLight;

  /// 오류
  static const Color error = ModernColors.error;
  static const Color errorLight = ModernColors.error;
  static const Color errorBackground = ModernColors.errorLight;

  /// 정보
  static const Color info = ModernColors.info;
  static const Color infoLight = ModernColors.info;
  static const Color infoBackground = ModernColors.infoLight;

  // ==================== 📝 텍스트 색상 (ModernColors 기반) ====================

  /// 텍스트 계층
  static const Color textPrimary = ModernColors.textPrimary;
  static const Color textSecondary = ModernColors.textSecondary;
  static const Color textLight = ModernColors.textTertiary;
  @Deprecated('Use ModernColors.textPlaceholder instead')
  static const Color textFaint = ModernColors.textPlaceholder;
  static const Color textWhite = ModernColors.textOnPrimary;
  static const Color textBlue = ModernColors.primary;

  // ==================== 🎨 UI 요소 색상 (ModernColors 기반) ====================

  /// 카드 배경
  static const Color cardBackground = ModernColors.surface;
  static const Color cardBackgroundSoft = ModernColors.surfaceElevated;

  /// 구분선
  static const Color divider = ModernColors.border;
  static const Color dividerLight = ModernColors.borderLight;

  /// 테두리
  static const Color border = ModernColors.border;
  static const Color borderLight = ModernColors.borderLight;
  static const Color borderFocus = ModernColors.borderFocus;

  /// 오버레이
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  /// 투명
  static const Color transparent = Colors.transparent;

  // ==================== 🚀 기능별 색상 (ModernColors 기반, 블루톤 조화) ====================

  /// 등반 🏔️
  static const Color climbing = ModernColors.climbing;
  static const Color climbingLight = ModernColors.climbing;
  static const Color climbingBackground = ModernColors.climbingLight;

  /// 독서 📚
  static const Color reading = ModernColors.reading;
  static const Color readingLight = ModernColors.reading;
  static const Color readingBackground = ModernColors.readingLight;

  /// 모임 👥
  static const Color meeting = ModernColors.meeting;
  static const Color meetingLight = ModernColors.meeting;
  static const Color meetingBackground = ModernColors.meetingLight;

  /// 운동 💪
  static const Color exercise = ModernColors.exercise;
  static const Color exerciseLight = ModernColors.exercise;
  static const Color exerciseBackground = ModernColors.exerciseLight;

  /// 집중 🎯
  static const Color focus = ModernColors.focus;
  static const Color focusLight = ModernColors.focus;
  static const Color focusBackground = ModernColors.focusLight;

  /// 일기 📝
  static const Color diary = ModernColors.diary;
  static const Color diaryLight = ModernColors.diary;
  static const Color diaryBackground = ModernColors.diaryLight;

  /// 퀘스트 🎯
  static const Color quest = ModernColors.quest;
  static const Color questLight = ModernColors.quest;
  static const Color questBackground = ModernColors.questLight;

  /// 포인트 💰
  static const Color point = ModernColors.success;
  static const Color pointLight = ModernColors.success;
  static const Color pointBackground = ModernColors.successLight;

  // ==================== 🎖️ 레벨 시스템 색상 (블루톤 통일) ====================

  /// 레벨별 색상 (블루 그라데이션)
  static const Color levelBeginner = ModernColors.primaryLighter; // Lv. 1-9
  static const Color levelIntermediate = ModernColors.primaryLight; // Lv. 10-19
  static const Color levelAdvanced = ModernColors.primary; // Lv. 20-29
  static const Color levelExpert = ModernColors.primaryHover; // Lv. 30+

  @Deprecated('Use level colors directly instead')
  static const Color levelBeginnerBackground = ModernColors.infoLight;
  @Deprecated('Use level colors directly instead')
  static const Color levelIntermediateBackground = ModernColors.infoLight;
  @Deprecated('Use level colors directly instead')
  static const Color levelAdvancedBackground = ModernColors.infoLight;
  @Deprecated('Use level colors directly instead')
  static const Color levelExpertBackground = ModernColors.infoLight;

  // ==================== 🤖 셰르피 캐릭터 색상 ====================

  /// 셰르피 관련 색상 (블루톤 통일)
  static const Color sherpiBackground = ModernColors.infoLight;
  static const Color sherpiSpeech = ModernColors.surface;
  static const Color sherpiSpeechBorder = ModernColors.primary;

  /// 셰르피 감정 색상 (단순화)
  static const Color sherpiHappy = ModernColors.success; // 기쁨
  static const Color sherpiEncouraging = ModernColors.primary; // 격려
  static const Color sherpiCelebrating = ModernColors.warning; // 축하
  static const Color sherpiThinking = ModernColors.accent; // 생각

  // ==================== 🎨 단순화된 그라데이션 시스템 (ModernColors 기반) ====================

  /// 메인 그라데이션
  static const LinearGradient primaryGradient = ModernColors.primaryGradient;

  /// 보조 그라데이션
  static const LinearGradient secondaryGradient =
      ModernColors.secondaryGradient;

  /// 부드러운 배경 그라데이션
  static const LinearGradient softGradient = ModernColors.softGradient;

  // 아래는 기존 코드 호환성을 위한 별칭들
  @Deprecated('Use primaryGradient instead')
  static const LinearGradient successGradient = primaryGradient;

  @Deprecated('Use softGradient instead')
  static const LinearGradient softBlueGradient = ModernColors.softGradient;

  @Deprecated('Use primaryGradient instead')
  static const LinearGradient pointGradient = primaryGradient;

  @Deprecated('Use primaryGradient instead')
  static const LinearGradient climbingPowerGradient = primaryGradient;

  @Deprecated('Use secondaryGradient for celebrations')
  static const LinearGradient levelUpGradient = secondaryGradient;

  @Deprecated('Use primaryGradient instead')
  static const LinearGradient accentGradient = primaryGradient;

  @Deprecated('Complex gradients removed for modern design')
  static const LinearGradient rainbowGradient = primaryGradient;

  // ==================== 유틸리티 메서드 ====================

  /// 카테고리별 색상 반환 (ModernColors 위임)
  static Color getCategoryColor(String category) {
    return ModernColors.getFunctionColor(category);
  }

  /// 카테고리별 배경 색상 반환 (ModernColors 위임)
  static Color getCategoryBackgroundColor(String category) {
    return ModernColors.getFunctionBackgroundColor(category);
  }

  /// 레벨별 색상 반환 (단순화)
  static Color getLevelColor(int level) {
    if (level < 10) return levelBeginner;
    if (level < 20) return levelIntermediate;
    if (level < 30) return levelAdvanced;
    return levelExpert;
  }

  /// 레벨별 배경 색상 반환 (단순화)
  @Deprecated('Use primary background colors instead')
  static Color getLevelBackgroundColor(int level) {
    return ModernColors.infoLight; // 통일된 배경색
  }

  /// 밝기에 따른 적응형 색상
  static Color adaptiveColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.light
        ? lightColor
        : darkColor;
  }

  /// 색상의 투명도 버전 반환 (ModernColors 위임)
  static Color withOpacity(Color color, double opacity) {
    return ModernColors.withOpacity(color, opacity);
  }

  @Deprecated('Use predefined color shades instead of runtime calculations')
  static Color adjustBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + factor).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // ==================== 🌓 테마별 색상 세트 (단순화) ====================

  /// 라이트 테마 색상
  static const Map<String, Color> lightTheme = {
    'primary': ModernColors.primary,
    'background': ModernColors.background,
    'surface': ModernColors.surface,
    'text': ModernColors.textPrimary,
    'textSecondary': ModernColors.textSecondary,
  };

  @Deprecated('Dark theme not implemented yet')
  static const Map<String, Color> darkTheme = {
    'primary': ModernColors.primaryLight,
    'background': Color(0xFF0F172A),
    'surface': Color(0xFF1E293B),
    'text': Color(0xFFFFFFFF),
    'textSecondary': Color(0xFFCBD5E1),
  };
}

/// 🔄 기존 코드와의 호환성을 위한 별칭들
@Deprecated(
    'Use ModernColors instead. AppColors will be removed in future versions.')
typedef RecordColors = AppColors;

/// ✅ 새로운 색상 시스템 사용을 권장합니다
///
/// 마이그레이션 가이드:
/// - AppColors.primary → ModernColors.primary
/// - AppColors.diary → ModernColors.diary
/// - AppColors.primaryGradient → ModernColors.primaryGradient
///
/// 자세한 내용은 ModernColors 클래스를 참조하세요.
