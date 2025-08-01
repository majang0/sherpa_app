// lib/features/daily_record/constants/record_colors.dart

import 'package:flutter/material.dart';

/// 기록 탭 전용 색상 팔레트 - 블루 계열로 통일
class RecordColors {
  // ==================== 메인 색상 ====================
  
  /// 기본 배경색
  static const Color background = Color(0xFFF8FAFC);
  
  /// 주요 브랜드 색상 - 딥 블루
  static const Color primary = Color(0xFF2563EB);
  static const Color primarySoft = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  
  /// 보조 색상
  static const Color secondary = Color(0xFF64748B);
  
  /// 스카이 블루 계열
  static const Color sky = Color(0xFF0EA5E9);
  static const Color skyLight = Color(0xFF38BDF8);
  static const Color skyPale = Color(0xFF7DD3FC);

  // ✅ 일기 관련 색상 추가
  static const Color diary = Color(0xFFEC4899);
  static const Color diaryLight = Color(0xFFFDF2F8);
  static const Color progressBackground = Color(0xFFE5E7EB);
  
  /// 액센트 색상
  static const Color accent = Color(0xFF1D4ED8);
  static const Color accentSoft = Color(0xFF3B82F6);
  
  // ==================== 상태 색상 ====================
  
  /// 성공 (초록)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  
  /// 경고 (주황)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  
  /// 오류 (빨강)
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  
  /// 정보 (파랑)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  
  /// 커뮤니티 (보라)
  static const Color community = Color(0xFF8B5CF6);
  static const Color communityLight = Color(0xFFA78BFA);
  
  // ==================== 텍스트 색상 ====================
  
  /// 주요 텍스트
  static const Color textPrimary = Color(0xFF1E293B);
  
  /// 보조 텍스트
  static const Color textSecondary = Color(0xFF475569);
  
  /// 연한 텍스트
  static const Color textLight = Color(0xFF94A3B8);
  
  /// 매우 연한 텍스트
  static const Color textFaint = Color(0xFFCBD5E1);
  
  // ==================== 그라데이션 ====================
  
  /// 주요 그라데이션 - 블루
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
    ],
  );
  
  /// 스카이 그라데이션
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0EA5E9),
      Color(0xFF3B82F6),
    ],
  );
  
  /// 성공 그라데이션
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );
  
  /// 부드러운 블루 그라데이션
  static const LinearGradient softBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFDBEAFE),
      Color(0xFFBFDBFE),
    ],
  );
  
  // ==================== 특수 색상 ====================
  
  /// 카드 배경
  static const Color cardBackground = Colors.white;
  
  /// 구분선
  static const Color divider = Color(0xFFE2E8F0);
  
  /// 오버레이
  static const Color overlay = Color(0x80000000);
  
  /// 투명 배경
  static const Color transparent = Colors.transparent;
  
  // ==================== 기능별 색상 ====================
  
  /// 독서 관련 색상
  static const Color reading = Color(0xFF8B5CF6);
  static const Color readingLight = Color(0xFFA78BFA);
  
  /// 모임 관련 색상  
  static const Color meeting = Color(0xFF06B6D4);
  static const Color meetingLight = Color(0xFF22D3EE);
  
  /// 운동 관련 색상
  static const Color exercise = Color(0xFFEF4444);
  static const Color exerciseLight = Color(0xFFF87171);
  
  /// 집중 관련 색상
  static const Color focus = Color(0xFF8B5CF6);
  static const Color focusLight = Color(0xFFA78BFA);
  
  // ==================== 유틸리티 메서드 ====================
  
  /// 카테고리별 색상 반환
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
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
      default:
        return primary;
    }
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
