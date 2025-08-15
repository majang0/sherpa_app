// lib/core/theme/modern_colors.dart

import 'package:flutter/material.dart';

/// 🎨 현대적이고 깔끔한 블루-화이트 기반 색상 시스템
/// Tailwind CSS OKLCH 색상 체계를 기반으로 한 통합 디자인 시스템
class ModernColors {
  // ==================== 브랜드 색상 ====================
  
  /// 🔵 Primary - 메인 브랜드 색상 (Blue-600)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF60A5FA);
  
  // ==================== 현대적 중성 색상 (2024 트렌드) ====================
  
  /// 🎨 Modern Neutrals - 채도가 낮은 현대적 색상
  static const Color modernPrimary = Color(0xFF5B7FFF);     // 부드러운 파란색
  static const Color modernSurface = Color(0xFFFCFCFC);     // 거의 흰색
  static const Color modernBackground = Color(0xFFF7F8FA);  // 매우 연한 회색
  static const Color modernText = Color(0xFF0A0D14);        // 거의 검은색
  static const Color modernTextSecondary = Color(0xFF6B7280); // 중간 회색
  static const Color modernTextTertiary = Color(0xFF9CA3AF);  // 연한 회색
  static const Color modernAccent = Color(0xFF8B5CF6);      // 보라빛 악센트
  static const Color modernSuccess = Color(0xFF10B981);     // 민트 그린
  static const Color modernWarning = Color(0xFFF59E0B);     // 따뜻한 오렌지
  static const Color modernError = Color(0xFFEF4444);       // 부드러운 레드
  
  /// 🌫️ Neutral Grays - 세련된 회색 팔레트
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  /// 🌟 Secondary - 보조 브랜드 색상 (Sky-500)
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryHover = Color(0xFF0284C7);
  static const Color secondaryLight = Color(0xFF38BDF8);
  
  /// ✨ Accent - 강조 색상 (Indigo-600)
  static const Color accent = Color(0xFF4F46E5);
  static const Color accentHover = Color(0xFF4338CA);

  // ==================== 베이스 색상 ====================
  
  /// 🤍 배경 및 서피스
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF8FAFC);
  
  /// 🔳 보더 및 구분선
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderFocus = primary;

  // ==================== 텍스트 색상 ====================
  
  /// 📝 텍스트 계층
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textPlaceholder = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ==================== 상태 색상 ====================
  
  /// ✅ 성공 (Emerald-500)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);
  
  /// ⚠️ 경고 (Amber-500)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);
  
  /// ❌ 오류 (Rose-500)
  static const Color error = Color(0xFFF43F5E);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFE11D48);
  
  /// ℹ️ 정보 (Blue-500)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1D4ED8);

  // ==================== 기능별 색상 (블루톤 조화) ====================
  
  /// 📔 일기 - 부드러운 블루 (Refined for 2024)
  static const Color diary = Color(0xFF60A5FA);
  static const Color diaryLight = Color(0xFFEFF6FF);
  static const Color diaryAccent = Color(0xFF93C5FD);  // Sky-300
  static const Color diarySoft = Color(0xFFDBEAFE);    // Blue-100
  static const Color diaryMuted = Color(0xFFBFDBFE);   // Blue-200
  
  // ==================== 감정 색상 시스템 (3단계 깊이) ====================
  
  /// 🌈 기쁨 계열 (따뜻한 오렌지-골드 스펙트럼)
  static const Color joyPastel = Color(0xFFFFF4E6);      // 매우 연한 피치 (배경용)
  static const Color joyLight = Color(0xFFFFE0B2);       // 연한 오렌지 (버튼 기본)
  static const Color joyMedium = Color(0xFFFFB74D);      // 중간 오렌지 (선택 상태)
  static const Color joyBright = Color(0xFFFF9800);      // 밝은 오렌지 (강조)
  
  /// 🌊 차분 계열 (블루 스펙트럼)
  static const Color calmPastel = Color(0xFFE8F4FD);     // 매우 연한 하늘 (배경용)
  static const Color calmLight = Color(0xFFBBDEFB);      // 연한 하늘색 (버튼 기본)
  static const Color calmMedium = Color(0xFF90CAF9);     // 중간 하늘색 (선택 상태)
  static const Color calmBright = Color(0xFF42A5F5);     // 밝은 하늘색 (강조)
  
  /// 🌸 생각 계열 (핑크 스펙트럼)
  static const Color thoughtPastel = Color(0xFFFCE4EC);  // 매우 연한 분홍 (배경용)
  static const Color thoughtLight = Color(0xFFF8BBD9);   // 연한 분홍색 (버튼 기본)
  static const Color thoughtMedium = Color(0xFFEC407A);  // 중간 분홍색 (선택 상태)
  static const Color thoughtBright = Color(0xFFE91E63);  // 밝은 분홍색 (강조)
  
  /// 🎨 레거시 파스텔 색상 (하위 호환성)
  static const Color pastelYellow = Color(0xFFFFF59D);   // 더 진한 노란색 (기쁨)
  static const Color pastelBlue = Color(0xFFE3F2FD);     // 연한 하늘색 (보통)  
  static const Color pastelPink = Color(0xFFFCE4EC);     // 연한 분홍색 (생각)
  static const Color pastelMint = Color(0xFFE0F2F1);     // 연한 민트 - 차분
  static const Color pastelPurple = Color(0xFFF3E5F5);   // 연한 보라 - 설렘
  static const Color pastelOrange = Color(0xFFFFF3E0);   // 연한 주황 - 활력
  
  /// 📅 오늘 날짜 표시용 파스텔 블루
  static const Color todayPastel = Color(0xFF64B5F6);    // 밝은 파란색
  
  // ==================== Borderless Design 시스템 ====================
  
  /// 🎨 레이어드 배경 색상 - 테두리 없는 구분을 위한 배경 계층
  static const Color backgroundElevated = Color(0xFFFBFCFE);  // surface보다 한단계 위
  static const Color backgroundFloating = Color(0xFFFFFFFF);  // 플로팅 카드용
  static const Color backgroundSubtle = Color(0xFFF8FAFF);   // 매우 연한 accent 배경
  
  /// 🌟 Glass Morphism 색상
  static const Color diaryGlass = Color(0x1560A5FA);         // 반투명 파란색 (8% opacity)
  static const Color glassOverlay = Color(0x0A60A5FA);       // 더 연한 glass 효과 (4% opacity)
  
  /// 🎯 Interactive 상태 색상
  static const Color hoverOverlay = Color(0x0860A5FA);       // hover 효과용 (3% opacity)
  static const Color pressOverlay = Color(0x1560A5FA);       // press 효과용 (8% opacity)
  
  /// 💪 운동 - 활기찬 스카이 블루
  static const Color exercise = Color(0xFF0284C7);
  static const Color exerciseLight = Color(0xFFE0F2FE);
  
  /// 📚 독서 - 지적인 인디고
  static const Color reading = Color(0xFF6366F1);
  static const Color readingLight = Color(0xFFEEF2FF);
  
  /// 🎯 집중 - 진중한 슬레이트
  static const Color focus = Color(0xFF475569);
  static const Color focusLight = Color(0xFFF1F5F9);
  
  /// 👥 모임 - 사회적인 시안
  static const Color meeting = Color(0xFF06B6D4);
  static const Color meetingLight = Color(0xFFCCFBF1);
  
  /// 🏔️ 등반 - 메인 브랜드
  static const Color climbing = primary;
  static const Color climbingLight = Color(0xFFEFF6FF);
  
  /// 🎯 퀘스트 - 성취감 있는 앰버
  static const Color quest = Color(0xFFF59E0B);
  static const Color questLight = Color(0xFFFEF3C7);

  // ==================== 그림자 및 깊이 시스템 ====================
  
  /// 🌑 그림자 베이스 색상
  static const Color shadowBase = Color(0xFF1E293B);  // Slate-800
  static const Color shadowSubtle = Color(0xFF0F172A); // Slate-900
  static const Color shadowWarm = Color(0xFF374151);  // Gray-700

  /// 🔍 그림자 투명도 레벨
  static const double shadowSubtleOpacity = 0.04;  // Level 1: 은은한 분리
  static const double shadowLightOpacity = 0.06;   // Level 2: 상호작용 요소
  static const double shadowMediumOpacity = 0.10;  // Level 3: 강조 요소
  static const double shadowStrongOpacity = 0.16;  // Level 4: 플로팅 요소

  /// 📐 입체감 레벨별 그림자 반환
  static List<BoxShadow> getElevationShadow(int level) {
    switch (level) {
      case 0:
        return []; // Flat - 그림자 없음
      case 1:
        return [
          BoxShadow(
            color: shadowBase.withOpacity(shadowSubtleOpacity),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ];
      case 2:
        return [
          BoxShadow(
            color: shadowBase.withOpacity(shadowLightOpacity),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ];
      case 3:
        return [
          BoxShadow(
            color: shadowBase.withOpacity(shadowMediumOpacity),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];
      case 4:
        return [
          BoxShadow(
            color: shadowBase.withOpacity(shadowStrongOpacity),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ];
      default:
        return getElevationShadow(1); // 기본값으로 Level 1 반환
    }
  }

  /// 🎨 컨텍스트별 그림자 (기능별 색상 활용)
  static List<BoxShadow> getContextShadow(String context, {int level = 1}) {
    final contextColor = getFunctionColor(context);
    final opacity = getElevationShadow(level).first.color.opacity * 0.7; // 약간 더 subtle하게
    
    switch (level) {
      case 1:
        return [
          BoxShadow(
            color: contextColor.withOpacity(opacity),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case 2:
        return [
          BoxShadow(
            color: contextColor.withOpacity(opacity),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ];
      case 3:
        return [
          BoxShadow(
            color: contextColor.withOpacity(opacity),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ];
      case 4:
        return [
          BoxShadow(
            color: contextColor.withOpacity(opacity),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ];
      default:
        return getContextShadow(context, level: 1);
    }
  }

  // ==================== 단순화된 그라데이션 시스템 ====================
  
  /// 🔵 메인 그라데이션 (Primary)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryHover],
  );
  
  /// 🌟 보조 그라데이션 (Secondary)  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryHover],
  );
  
  /// ✨ 부드러운 배경 그라데이션
  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFAFA), Color(0xFFF8FAFC)],
  );

  // ==================== 유틸리티 메서드 ====================
  
  /// 기능별 색상 반환
  static Color getFunctionColor(String function) {
    switch (function.toLowerCase()) {
      case 'diary':
      case '일기':
        return diary;
      case 'exercise':
      case '운동':
        return exercise;
      case 'reading':
      case '독서':
        return reading;
      case 'focus':
      case '집중':
        return focus;
      case 'meeting':
      case '모임':
        return meeting;
      case 'climbing':
      case '등반':
        return climbing;
      case 'quest':
      case '퀘스트':
        return quest;
      default:
        return primary;
    }
  }
  
  /// 기능별 배경 색상 반환
  static Color getFunctionBackgroundColor(String function) {
    switch (function.toLowerCase()) {
      case 'diary':
      case '일기':
        return diaryLight;
      case 'exercise':
      case '운동':
        return exerciseLight;
      case 'reading':
      case '독서':
        return readingLight;
      case 'focus':
      case '집중':
        return focusLight;
      case 'meeting':
      case '모임':
        return meetingLight;
      case 'climbing':
      case '등반':
        return climbingLight;
      case 'quest':
      case '퀘스트':
        return questLight;
      default:
        return infoLight;
    }
  }
  
  /// 색상에 투명도 적용
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// 상태별 색상 반환
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case '성공':
        return success;
      case 'warning':
      case '경고':
        return warning;
      case 'error':
      case '오류':
        return error;
      case 'info':
      case '정보':
        return info;
      default:
        return textSecondary;
    }
  }
  
  /// 감정별 파스텔 색상 반환 (배경용 - 가장 연한 색상)
  static Color getMoodPastelColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'excited':
      case 'happy': 
      case 'good':
        return pastelYellow;  // #FFF4E6 연한 노란색 (기쁨)
      case 'normal':
      case 'thoughtful':
        return pastelBlue;    // #E3F2FD 연한 하늘색 (보통)
      case 'tired':
      case 'sad':
      case 'angry':
        return pastelPink;    // #FCE4EC 연한 분홍색 (생각)
      default:
        return pastelBlue;
    }
  }
  
  /// 감정별 기본 색상 반환 (버튼 기본 상태)
  static Color getMoodLightColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'excited':
      case 'happy': 
      case 'good':
        return joyLight;      // 연한 노란색 (기쁨)
      case 'normal':
      case 'thoughtful':
        return calmLight;     // 연한 하늘색 (차분)
      case 'tired':
      case 'sad':
      case 'angry':
        return thoughtLight;  // 연한 분홍색 (생각)
      default:
        return calmLight;
    }
  }
  
  /// 감정별 선택 색상 반환 (버튼 선택 상태)
  static Color getMoodMediumColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'excited':
      case 'happy': 
      case 'good':
        return joyMedium;     // 중간 노란색 (기쁨)
      case 'normal':
      case 'thoughtful':
        return calmMedium;    // 중간 하늘색 (차분)
      case 'tired':
      case 'sad':
      case 'angry':
        return thoughtMedium; // 중간 분홍색 (생각)
      default:
        return calmMedium;
    }
  }
  
  /// 감정별 강조 색상 반환 (버튼 강조 상태)
  static Color getMoodBrightColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'excited':
      case 'happy': 
      case 'good':
        return joyBright;     // 밝은 노란색 (기쁨)
      case 'normal':
      case 'thoughtful':
        return calmBright;    // 밝은 하늘색 (차분)
      case 'tired':
      case 'sad':
      case 'angry':
        return thoughtBright; // 밝은 분홍색 (생각)
      default:
        return calmBright;
    }
  }
  
  /// 감정별 그라데이션 반환
  static LinearGradient getMoodGradient(String mood) {
    switch (mood.toLowerCase()) {
      case 'excited':
      case 'happy': 
      case 'good':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [joyLight, joyMedium],
        );
      case 'normal':
      case 'thoughtful':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [calmLight, calmMedium],
        );
      case 'tired':
      case 'sad':
      case 'angry':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [thoughtLight, thoughtMedium],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [calmLight, calmMedium],
        );
    }
  }
}

/// 기존 코드와의 호환성을 위한 별칭
typedef SherpaColors = ModernColors;
typedef ThemeColors = ModernColors;