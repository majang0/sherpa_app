// lib/core/constants/app_colors_2025.dart

import 'package:flutter/material.dart';

/// 셰르파 앱 2024-2025 트렌드 기반 디자인 시스템
/// 글래스모피즘, 뉴모피즘, 마이크로 인터랙션을 위한 확장된 색상 팔레트
class AppColors2025 {
  
  // ==================== 2025 메인 컬러 시스템 ====================
  
  /// 메인 블루 팔레트 (산맥에서 하늘까지의 그라데이션)
  static const Color deepMountainBlue = Color(0xFF1B365D);     // 깊은 산맥
  static const Color mountainBlue = Color(0xFF2563EB);          // 산 중턱  
  static const Color skyBlue = Color(0xFF3B82F6);              // 맑은 하늘
  static const Color lightSkyBlue = Color(0xFF60A5FA);         // 밝은 하늘
  static const Color cloudWhite = Color(0xFFF8FAFC);           // 구름 흰색
  
  /// 프라이머리 색상 (기존 대비 더 부드럽고 현대적)
  static const Color primary = Color(0xFF2563EB);
  static const Color primarySoft = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryUltraLight = Color(0xFF93C5FD);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryDeep = Color(0xFF1E40AF);
  
  /// 세컨더리 색상
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF0891B2);
  
  /// 배경 색상 (글래스모피즘과 뉴모피즘 최적화)
  static const Color background = Color(0xFFF8FAFC);           // 메인 배경
  static const Color backgroundSoft = Color(0xFFF1F5F9);       // 부드러운 배경
  static const Color surface = Color(0xFFFFFFFF);              // 카드/서피스
  static const Color surfaceElevated = Color(0xFFFBFBFB);      // 올라온 서피스
  static const Color surfaceBlur = Color(0xFFF8FAFC);          // 블러 효과용
  
  // ==================== 자연에서 영감받은 액센트 컬러 ====================
  
  /// 숲과 식물 (성장, 성취, 자연)
  static const Color forestGreen = Color(0xFF059669);
  static const Color mountainGreen = Color(0xFF065F46);
  static const Color leafGreen = Color(0xFF10B981);
  static const Color mossGreen = Color(0xFF6EE7B7);
  
  /// 일출과 일몰 (에너지, 동기부여, 열정)
  static const Color sunriseOrange = Color(0xFFF59E0B);
  static const Color sunsetPeach = Color(0xFFFBBF24);
  static const Color dawnPink = Color(0xFFF472B6);
  static const Color twilightPurple = Color(0xFF8B5CF6);
  
  /// 바위와 대지 (안정, 신뢰, 기반)
  static const Color rockGray = Color(0xFF6B7280);
  static const Color stoneGray = Color(0xFF9CA3AF);
  static const Color pebbleGray = Color(0xFFD1D5DB);
  static const Color sandBeige = Color(0xFFF3F4F6);
  
  /// 하늘과 날씨 (자유, 영감, 변화)
  static const Color stormBlue = Color(0xFF1E40AF);
  static const Color rainBlue = Color(0xFF3730A3);
  static const Color mistBlue = Color(0xFF6366F1);
  static const Color clearSky = Color(0xFF60A5FA);
  
  // ==================== 글래스모피즘 전용 색상 ====================
  
  /// 반투명 레이어들
  static const Color glassWhite10 = Color(0x1AFFFFFF);         // 10% 흰색
  static const Color glassWhite20 = Color(0x33FFFFFF);         // 20% 흰색
  static const Color glassWhite30 = Color(0x4DFFFFFF);         // 30% 흰색
  static const Color glassBlue10 = Color(0x1A2563EB);          // 10% 블루
  static const Color glassBlue20 = Color(0x332563EB);          // 20% 블루
  static const Color glassBlue30 = Color(0x4D2563EB);          // 30% 블루
  
  /// 유리 효과 테두리
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderBlue = Color(0x4D3B82F6);
  static const Color glassBorderSoft = Color(0x1AFFFFFF);
  
  /// 블러 배경들
  static const Color blurBackground = Color(0xFFFCFCFC);
  static const Color blurBackgroundDark = Color(0xFFF5F5F7);
  static const Color blurOverlay = Color(0x80F8FAFC);
  
  // ==================== 뉴모피즘 전용 색상 ====================
  
  /// 하이라이트 (볼록한 효과)
  static const Color neuHighlight = Color(0xFFFFFFFF);
  static const Color neuHighlightSoft = Color(0xFFFCFCFC);
  static const Color neuHighlightBlue = Color(0xFFF0F7FF);
  
  /// 그림자 (오목한 효과)  
  static const Color neuShadowLight = Color(0xFFE5E7EB);
  static const Color neuShadowMedium = Color(0xFFD1D5DB);
  static const Color neuShadowDark = Color(0xFFAFB2BF);
  static const Color neuShadowBlue = Color(0xFFDEE9FC);
  
  /// 뉴모피즘 베이스 색상
  static const Color neuBase = Color(0xFFF8FAFC);
  static const Color neuBaseSoft = Color(0xFFF1F5F9);
  static const Color neuBaseBlue = Color(0xFFF0F7FF);
  
  // ==================== 마이크로 인터랙션 색상 ====================
  
  /// 호버 상태
  static const Color hoverPrimary = Color(0xFF1D4ED8);
  static const Color hoverSecondary = Color(0xFF0EA5E9);
  static const Color hoverSuccess = Color(0xFF059669);
  static const Color hoverWarning = Color(0xFFD97706);
  static const Color hoverError = Color(0xFFDC2626);
  
  /// 액티브 상태
  static const Color activePrimary = Color(0xFF1E40AF);
  static const Color activeSecondary = Color(0xFF0284C7);
  static const Color activeSuccess = Color(0xFF047857);
  static const Color activeWarning = Color(0xFFB45309);
  static const Color activeError = Color(0xFFB91C1C);
  
  /// 포커스 상태
  static const Color focusPrimary = Color(0xFF3B82F6);
  static const Color focusSecondary = Color(0xFF06B6D4);
  static const Color focusRing = Color(0x4D3B82F6);           // 포커스 링
  
  // ==================== 상태 및 피드백 색상 ====================
  
  /// 성공 (산 정상 도달, 목표 달성)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successBackground = Color(0xFFECFDF5);
  static const Color successGlass = Color(0x1A10B981);
  
  /// 경고 (주의 필요, 도전적)  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningBackground = Color(0xFFFEF3C7);
  static const Color warningGlass = Color(0x1AF59E0B);
  
  /// 오류 (위험, 실패)
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorBackground = Color(0xFFFEF2F2);
  static const Color errorGlass = Color(0x1AEF4444);
  
  /// 정보 (팁, 안내)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);
  static const Color infoDark = Color(0xFF1D4ED8);
  static const Color infoBackground = Color(0xFFEFF6FF);
  static const Color infoGlass = Color(0x1A3B82F6);
  
  // ==================== 텍스트 색상 (접근성 최적화) ====================
  
  /// 메인 텍스트
  static const Color textPrimary = Color(0xFF0F172A);          // 최고 대비
  static const Color textSecondary = Color(0xFF334155);        // 중간 대비
  static const Color textTertiary = Color(0xFF64748B);         // 보조 텍스트
  static const Color textQuaternary = Color(0xFF94A3B8);       // 라벨, 캡션
  
  /// 특수 텍스트
  static const Color textOnPrimary = Color(0xFFFFFFFF);        // 블루 배경 위
  static const Color textOnDark = Color(0xFFFFFFFF);           // 어두운 배경 위
  static const Color textOnLight = Color(0xFF0F172A);          // 밝은 배경 위
  static const Color textDisabled = Color(0xFFCBD5E1);         // 비활성화
  static const Color textLink = Color(0xFF2563EB);             // 링크
  static const Color textLinkHover = Color(0xFF1D4ED8);        // 호버 링크
  
  // ==================== 테두리 및 구분선 ====================
  
  /// 일반 테두리
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF94A3B8);
  
  /// 포커스 테두리
  static const Color borderFocus = Color(0xFF3B82F6);
  static const Color borderFocusRing = Color(0x4D3B82F6);
  
  /// 에러 테두리  
  static const Color borderError = Color(0xFFEF4444);
  static const Color borderSuccess = Color(0xFF10B981);
  static const Color borderWarning = Color(0xFFF59E0B);
  
  // ==================== 쉐도우 시스템 ====================
  
  /// 엘리베이션 그림자들 (Material Design 3 기반)
  static const Color shadow = Color(0xFF000000);
  static const Color shadowLight = Color(0x0A000000);          // 2% 불투명도
  static const Color shadowMedium = Color(0x14000000);         // 8% 불투명도
  static const Color shadowDark = Color(0x1F000000);           // 12% 불투명도
  static const Color shadowHeavy = Color(0x29000000);          // 16% 불투명도
  
  /// 컬러 그림자들 (브랜드 컬러 기반)
  static const Color shadowBlue = Color(0x1A2563EB);
  static const Color shadowGreen = Color(0x1A10B981);
  static const Color shadowOrange = Color(0x1AF59E0B);
  static const Color shadowRed = Color(0x1AEF4444);
  
  // ==================== 2025 특별 그라데이션 ====================
  
  /// 메인 브랜드 그라데이션들
  static const LinearGradient primaryGradient2025 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF2563EB),
    ],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF60A5FA),
      Color(0xFF3B82F6),
      Color(0xFF2563EB),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient mountainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1B365D),
      Color(0xFF2563EB),
      Color(0xFF3B82F6),
    ],
    stops: [0.0, 0.7, 1.0],
  );
  
  /// 자연 영감 그라데이션들
  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFBBF24),
      Color(0xFFF59E0B),
      Color(0xFFD97706),
    ],
    stops: [0.0, 0.6, 1.0],
  );
  
  static const LinearGradient forestGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF6EE7B7),
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// 글래스모피즘 그라데이션들
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x1AFFFFFF),
    ],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient glassBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x4D3B82F6),
      Color(0x1A2563EB),
    ],
    stops: [0.0, 1.0],
  );
  
  // ==================== 활동별 테마 색상 (2025 업데이트) ====================
  
  /// 등반/산악 색상
  static const Color climbing2025 = Color(0xFF2563EB);
  static const Color climbingAccent = Color(0xFF1B365D);
  static const Color climbingLight = Color(0xFF60A5FA);
  static const Color climbingGlass = Color(0x332563EB);
  
  /// 운동 색상 (에너지와 열정)
  static const Color exercise2025 = Color(0xFFEF4444);
  static const Color exerciseAccent = Color(0xFFDC2626);
  static const Color exerciseLight = Color(0xFFF87171);
  static const Color exerciseGlass = Color(0x33EF4444);
  
  /// 독서 색상 (지혜와 성장)
  static const Color reading2025 = Color(0xFF8B5CF6);
  static const Color readingAccent = Color(0xFF7C3AED);
  static const Color readingLight = Color(0xFFA78BFA);
  static const Color readingGlass = Color(0x338B5CF6);
  
  /// 모임 색상 (소통과 연결)
  static const Color meeting2025 = Color(0xFF06B6D4);
  static const Color meetingAccent = Color(0xFF0891B2);
  static const Color meetingLight = Color(0xFF22D3EE);
  static const Color meetingGlass = Color(0x3306B6D4);
  
  /// 일기 색상 (감정과 성찰)
  static const Color diary2025 = Color(0xFFEC4899);
  static const Color diaryAccent = Color(0xFFDB2777);
  static const Color diaryLight = Color(0xFFF472B6);
  static const Color diaryGlass = Color(0x33EC4899);
  
  /// 집중 색상 (명상과 집중력)
  static const Color focus2025 = Color(0xFF8B5CF6);
  static const Color focusAccent = Color(0xFF7C3AED);
  static const Color focusLight = Color(0xFFA78BFA);
  static const Color focusGlass = Color(0x338B5CF6);
  
  // ==================== 유틸리티 메서드들 ====================
  
  /// 색상의 투명도 변경
  static Color withAlpha(Color color, int alpha) {
    return color.withAlpha(alpha);
  }
  
  /// 색상의 밝기 조절
  static Color adjustBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + factor).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// 글래스 효과 색상 생성
  static Color createGlassColor(Color baseColor, double opacity) {
    return baseColor.withOpacity(opacity);
  }
  
  /// 뉴모피즘 그림자 색상 생성
  static Color createNeuShadow(Color baseColor, double darkness) {
    return HSLColor.fromColor(baseColor)
        .withLightness((HSLColor.fromColor(baseColor).lightness - darkness).clamp(0.0, 1.0))
        .toColor();
  }
  
  /// 뉴모피즘 하이라이트 색상 생성
  static Color createNeuHighlight(Color baseColor, double lightness) {
    return HSLColor.fromColor(baseColor)
        .withLightness((HSLColor.fromColor(baseColor).lightness + lightness).clamp(0.0, 1.0))
        .toColor();
  }
  
  /// 카테고리별 색상 반환 (2025 업데이트)
  static Color getCategoryColor2025(String category) {
    switch (category.toLowerCase()) {
      case '등반':
      case 'climbing':
        return climbing2025;
      case '운동':
      case 'exercise':
        return exercise2025;
      case '독서':
      case 'reading':
        return reading2025;
      case '모임':
      case 'meeting':
        return meeting2025;
      case '일기':
      case 'diary':
        return diary2025;
      case '집중':
      case 'focus':
        return focus2025;
      default:
        return primary;
    }
  }
  
  /// 카테고리별 글래스 색상 반환
  static Color getCategoryGlassColor(String category) {
    switch (category.toLowerCase()) {
      case '등반':
      case 'climbing':
        return climbingGlass;
      case '운동':
      case 'exercise':
        return exerciseGlass;
      case '독서':
      case 'reading':
        return readingGlass;
      case '모임':
      case 'meeting':
        return meetingGlass;
      case '일기':
      case 'diary':
        return diaryGlass;
      case '집중':
      case 'focus':
        return focusGlass;
      default:
        return glassBlue20;
    }
  }
  
  // ==================== 테마 색상 세트 ====================
  
  /// 라이트 테마 2025
  static const Map<String, Color> lightTheme2025 = {
    'primary': primary,
    'background': background,
    'surface': surface,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'border': border,
  };
  
  /// 다크 테마 2025 (향후 구현용)
  static const Map<String, Color> darkTheme2025 = {
    'primary': primaryLight,
    'background': Color(0xFF0F172A),
    'surface': Color(0xFF1E293B),
    'textPrimary': Color(0xFFFFFFFF),
    'textSecondary': Color(0xFFCBD5E1),
    'border': Color(0xFF334155),
  };
  
  // ==================== 추가 탭 전용 그라데이션 ====================
  
  /// 블루 그라데이션 (모임 탭용)
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightSkyBlue, skyBlue, mountainBlue],
  );
  
  /// 오렌지 그라데이션 (탐색 탭용)
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sunsetPeach, sunriseOrange, Color(0xFFDC2626)],
  );
  
  /// 그린 그라데이션 (챌린지 탭용)
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mossGreen, leafGreen, forestGreen],
  );
}