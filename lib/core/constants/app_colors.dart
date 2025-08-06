// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// 셰르파 앱 전체 글로벌 색상 시스템
/// RecordColors를 기반으로 확장된 통합 색상 팔레트
class AppColors {
  // ==================== 기본 색상 (RecordColors 기반) ====================

  /// 기본 배경색
  static const Color background = Color(0xFFF8FAFC);
  static const Color surfaceBackground = Color(0xFFFFFFFF);

  /// 주요 브랜드 색상 - 딥 블루 (메인 브랜드)
  static const Color primary = Color(0xFF2563EB);
  static const Color primarySoft = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// 스카이 블루 계열 (보조 브랜드)
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryLight = Color(0xFF38BDF8);
  static const Color secondaryPale = Color(0xFF7DD3FC);

  /// 액센트 색상 (강조용)
  static const Color accent = Color(0xFF1D4ED8);
  static const Color accentSoft = Color(0xFF3B82F6);
  static const Color accentDark = Color(0xFF1E40AF);

  /// Surface 색상 (카드, 모달 등)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFBFBFB);

  // ==================== 상태 색상 ====================

  /// 성공 (초록) - 목표 달성, 성공적 완료
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successBackground = Color(0xFFECFDF5);

  /// 경고 (주황) - 주의 필요, 중간 상태
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningBackground = Color(0xFFFEF3C7);

  /// 오류 (빨강) - 실패, 문제 상황
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorBackground = Color(0xFFFEF2F2);

  /// 정보 (블루) - 안내, 팁
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);
  static const Color infoBackground = Color(0xFFEFF6FF);

  // ==================== 텍스트 색상 ====================

  /// 주요 텍스트 (제목, 중요 내용)
  static const Color textPrimary = Color(0xFF1E293B);

  /// 보조 텍스트 (부제목, 설명)
  static const Color textSecondary = Color(0xFF475569);

  /// 연한 텍스트 (라벨, 메타정보)
  static const Color textLight = Color(0xFF94A3B8);

  /// 매우 연한 텍스트 (비활성, 플레이스홀더)
  static const Color textFaint = Color(0xFFCBD5E1);

  /// 흰색 텍스트 (다크 배경용)
  static const Color textWhite = Color(0xFFFFFFFF);

  /// 블루 텍스트 (링크, 액션)
  static const Color textBlue = Color(0xFF2563EB);

  // ==================== UI 요소 색상 ====================

  /// 카드 배경
  static const Color cardBackground = Colors.white;
  static const Color cardBackgroundSoft = Color(0xFFFBFBFB);

  /// 구분선
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFF1F5F9);

  /// 테두리
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderFocus = Color(0xFF3B82F6);

  /// 오버레이
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  /// 투명
  static const Color transparent = Colors.transparent;

  // ==================== 기능별 색상 (활동 카테고리) ====================

  /// 등반 관련 색상 🏔️
  static const Color climbing = Color(0xFF2563EB);
  static const Color climbingLight = Color(0xFF60A5FA);
  static const Color climbingBackground = Color(0xFFEFF6FF);

  /// 독서 관련 색상 📚
  static const Color reading = Color(0xFF8B5CF6);
  static const Color readingLight = Color(0xFFA78BFA);
  static const Color readingBackground = Color(0xFFF3E8FF);

  /// 모임 관련 색상 👥
  static const Color meeting = Color(0xFF06B6D4);
  static const Color meetingLight = Color(0xFF22D3EE);
  static const Color meetingBackground = Color(0xFFECFEFF);

  /// 운동 관련 색상 💪
  static const Color exercise = Color(0xFFEF4444);
  static const Color exerciseLight = Color(0xFFF87171);
  static const Color exerciseBackground = Color(0xFFFEF2F2);

  /// 집중 관련 색상 🎯
  static const Color focus = Color(0xFF8B5CF6);
  static const Color focusLight = Color(0xFFA78BFA);
  static const Color focusBackground = Color(0xFFF3E8FF);

  /// 일기 관련 색상 📝
  static const Color diary = Color(0xFFEC4899);
  static const Color diaryLight = Color(0xFFF472B6);
  static const Color diaryBackground = Color(0xFFFDF2F8);

  /// 퀘스트 관련 색상 🎯
  static const Color quest = Color(0xFFF59E0B);
  static const Color questLight = Color(0xFFFBBF24);
  static const Color questBackground = Color(0xFFFEF3C7);

  /// 포인트 관련 색상 💰
  static const Color point = Color(0xFF10B981);
  static const Color pointLight = Color(0xFF34D399);
  static const Color pointBackground = Color(0xFFECFDF5);

  // ==================== 레벨 시스템 색상 ====================

  /// 초급자 (Lv. 1-9)
  static const Color levelBeginner = Color(0xFF93C5FD);
  static const Color levelBeginnerBackground = Color(0xFFEFF6FF);

  /// 중급자 (Lv. 10-19)
  static const Color levelIntermediate = Color(0xFF3B82F6);
  static const Color levelIntermediateBackground = Color(0xFFDBEAFE);

  /// 고급자 (Lv. 20-29)
  static const Color levelAdvanced = Color(0xFF1D4ED8);
  static const Color levelAdvancedBackground = Color(0xFFBFDBFE);

  /// 전문가 (Lv. 30+)
  static const Color levelExpert = Color(0xFF1E40AF);
  static const Color levelExpertBackground = Color(0xFF93C5FD);

  // ==================== 셰르피 캐릭터 색상 ====================

  /// 셰르피 배경 (하늘 느낌)
  static const Color sherpiBackground = Color(0xFFF0F7FF);

  /// 셰르피 말풍선
  static const Color sherpiSpeech = Color(0xFFFFFFFF);
  static const Color sherpiSpeechBorder = Color(0xFF3B82F6);

  /// 셰르피 감정별 색상
  static const Color sherpiHappy = Color(0xFF10B981);     // 기쁨 - 초록
  static const Color sherpiEncouraging = Color(0xFF3B82F6); // 격려 - 블루
  static const Color sherpiCelebrating = Color(0xFFF59E0B); // 축하 - 골드
  static const Color sherpiThinking = Color(0xFF8B5CF6);    // 생각 - 보라

  // ==================== 그라데이션 시스템 ====================

  /// 주요 블루 그라데이션 (메인 브랜드)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
    ],
  );

  /// 스카이 그라데이션 (보조 브랜드)
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0EA5E9),
      Color(0xFF3B82F6),
    ],
  );

  /// 성공 그라데이션 (성취감)
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  /// 부드러운 블루 그라데이션 (배경용)
  static const LinearGradient softBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFDBEAFE),
      Color(0xFFBFDBFE),
    ],
  );

  static const LinearGradient pointGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  /// 등반력 진행률 그라데이션
  static const LinearGradient climbingPowerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF93C5FD),  // 시작 (연한 블루)
      Color(0xFF3B82F6),  // 중간 (메인 블루)
      Color(0xFF1D4ED8),  // 끝 (진한 블루)
    ],
  );

  /// 레벨업 축하 그라데이션
  static const LinearGradient levelUpGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B),  // 골드
      Color(0xFFEAB308),  // 밝은 골드
      Color(0xFF10B981),  // 성공 그린
    ],
  );

  /// 액센트 그라데이션
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D4ED8),
      Color(0xFF1E40AF),
    ],
  );

  /// 무지개 그라데이션 (특별 이벤트용)
  static const LinearGradient rainbowGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFEF4444), // 빨강
      Color(0xFFF59E0B), // 주황
      Color(0xFFEAB308), // 노랑
      Color(0xFF10B981), // 초록
      Color(0xFF3B82F6), // 파랑
      Color(0xFF8B5CF6), // 보라
      Color(0xFFEC4899), // 핑크
    ],
  );

  // ==================== 유틸리티 메서드 ====================

  /// 카테고리별 색상 반환
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case '등반':
      case 'climbing':
        return climbing;
      case '독서':
      case 'reading':
        return reading;
      case '모임':
      case 'meeting':
        return meeting;
      case '운동':
      case 'exercise':
        return exercise;
      case '집중':
      case 'focus':
        return focus;
      case '일기':
      case 'diary':
        return diary;
      case '퀘스트':
      case 'quest':
        return quest;
      case '포인트':
      case 'point':
        return point;
      default:
        return primary;
    }
  }

  /// 카테고리별 배경 색상 반환
  static Color getCategoryBackgroundColor(String category) {
    switch (category.toLowerCase()) {
      case '등반':
      case 'climbing':
        return climbingBackground;
      case '독서':
      case 'reading':
        return readingBackground;
      case '모임':
      case 'meeting':
        return meetingBackground;
      case '운동':
      case 'exercise':
        return exerciseBackground;
      case '집중':
      case 'focus':
        return focusBackground;
      case '일기':
      case 'diary':
        return diaryBackground;
      case '퀘스트':
      case 'quest':
        return questBackground;
      case '포인트':
      case 'point':
        return pointBackground;
      default:
        return infoBackground;
    }
  }

  /// 레벨별 색상 반환
  static Color getLevelColor(int level) {
    if (level < 10) return levelBeginner;
    if (level < 20) return levelIntermediate;
    if (level < 30) return levelAdvanced;
    return levelExpert;
  }

  /// 레벨별 배경 색상 반환
  static Color getLevelBackgroundColor(int level) {
    if (level < 10) return levelBeginnerBackground;
    if (level < 20) return levelIntermediateBackground;
    if (level < 30) return levelAdvancedBackground;
    return levelExpertBackground;
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

  /// 색상의 투명도 버전 반환
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// 색상 밝기 조절 (더 밝게/어둡게)
  static Color adjustBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + factor).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // ==================== 테마별 색상 세트 ====================

  /// 라이트 테마 색상
  static const Map<String, Color> lightTheme = {
    'primary': primary,
    'background': background,
    'surface': surfaceBackground,
    'text': textPrimary,
    'textSecondary': textSecondary,
  };

  /// 다크 테마 색상 (향후 구현용)
  static const Map<String, Color> darkTheme = {
    'primary': primaryLight,
    'background': Color(0xFF0F172A),
    'surface': Color(0xFF1E293B),
    'text': Color(0xFFFFFFFF),
    'textSecondary': Color(0xFFCBD5E1),
  };
}

/// 기존 RecordColors와의 호환성을 위한 별칭
typedef RecordColors = AppColors;