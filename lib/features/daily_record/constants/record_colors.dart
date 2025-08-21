// lib/features/daily_record/constants/record_colors.dart

import 'package:flutter/material.dart';
import '../../../core/theme/modern_colors.dart';

/// 📝 기록 탭 전용 색상 팔레트
/// ModernColors를 기반으로 한 깔끔하고 일관된 블루-화이트 디자인
@Deprecated('Use ModernColors instead. This will be removed in future versions.')
class RecordColors {
  // ==================== 🔵 메인 색상 (ModernColors 기반) ====================
  
  /// 기본 배경색
  static const Color background = ModernColors.background;
  
  /// 주요 브랜드 색상
  static const Color primary = ModernColors.primary;
  static const Color primarySoft = ModernColors.primaryLight;
  static const Color primaryLight = ModernColors.primaryLighter;
  
  /// 보조 색상
  static const Color secondary = ModernColors.textTertiary;
  
  /// 스카이 블루 계열
  static const Color sky = ModernColors.secondary;
  static const Color skyLight = ModernColors.secondaryLight;
  @Deprecated('Use ModernColors.secondaryLight instead')
  static const Color skyPale = ModernColors.secondaryLight;

  /// 일기 관련 색상
  static const Color diary = ModernColors.diary;
  static const Color diaryLight = ModernColors.diaryLight;
  static const Color progressBackground = ModernColors.borderLight;
  
  /// 액센트 색상
  static const Color accent = ModernColors.accent;
  static const Color accentSoft = ModernColors.accent;
  
  // ==================== ✅ 상태 색상 (ModernColors 기반) ====================
  
  /// 성공
  static const Color success = ModernColors.success;
  static const Color successLight = ModernColors.success;
  
  /// 경고
  static const Color warning = ModernColors.warning;
  static const Color warningLight = ModernColors.warning;
  
  /// 오류
  static const Color error = ModernColors.error;
  static const Color errorLight = ModernColors.error;
  
  /// 정보
  static const Color info = ModernColors.info;
  static const Color infoLight = ModernColors.info;
  
  /// 커뮤니티 (단순화)
  static const Color community = ModernColors.accent;
  static const Color communityLight = ModernColors.accent;
  
  // ==================== 📝 텍스트 색상 (ModernColors 기반) ====================
  
  /// 텍스트 계층
  static const Color textPrimary = ModernColors.textPrimary;
  static const Color textSecondary = ModernColors.textSecondary;
  static const Color textLight = ModernColors.textTertiary;
  @Deprecated('Use ModernColors.textPlaceholder instead')
  static const Color textFaint = ModernColors.textPlaceholder;
  
  // ==================== 🎨 단순화된 그라데이션 (ModernColors 기반) ====================
  
  /// 주요 그라데이션
  static const LinearGradient primaryGradient = ModernColors.primaryGradient;
  
  /// 스카이 그라데이션
  static const LinearGradient skyGradient = ModernColors.secondaryGradient;
  
  /// 부드러운 그라데이션
  static const LinearGradient softBlueGradient = ModernColors.softGradient;
  
  // 기존 코드 호환성을 위한 별칭
  @Deprecated('Use primaryGradient instead')
  static const LinearGradient successGradient = ModernColors.primaryGradient;
  
  // ==================== 🎨 특수 색상 (ModernColors 기반) ====================
  
  /// 카드 배경
  static const Color cardBackground = ModernColors.surface;
  
  /// 구분선
  static const Color divider = ModernColors.border;
  
  /// 오버레이
  static const Color overlay = Color(0x80000000);
  
  /// 투명 배경
  static const Color transparent = Colors.transparent;
  
  // ==================== 🚀 기능별 색상 (ModernColors 기반) ====================
  
  /// 독서 관련 색상
  static const Color reading = ModernColors.reading;
  static const Color readingLight = ModernColors.readingLight;
  
  /// 모임 관련 색상  
  static const Color meeting = ModernColors.meeting;
  static const Color meetingLight = ModernColors.meetingLight;
  
  /// 운동 관련 색상
  static const Color exercise = ModernColors.exercise;
  static const Color exerciseLight = ModernColors.exerciseLight;
  
  /// 집중 관련 색상
  static const Color focus = ModernColors.focus;
  static const Color focusLight = ModernColors.focusLight;
  
  // ==================== ⚙️ 유틸리티 메서드 (ModernColors 위임) ====================
  
  /// 카테고리별 색상 반환 (ModernColors 위임)
  static Color getCategoryColor(String category) {
    return ModernColors.getFunctionColor(category);
  }
  
  /// 밝기에 따른 적응형 색상
  static Color adaptiveColor(BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.light
        ? lightColor
        : darkColor;
  }
}
