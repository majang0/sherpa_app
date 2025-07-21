import 'package:flutter/material.dart';

/// 퀘스트 기능 전용 색상 상수
class QuestColors {
  // 메인 컬러 팔레트 (블루/스카이/화이트)
  static const Color primaryBlue = Color(0xFF2563EB);      // 진한 블루
  static const Color skyBlue = Color(0xFF60A5FA);          // 스카이 블루
  static const Color lightSkyBlue = Color(0xFFDDD6FE);     // 연한 스카이 블루
  static const Color backgroundWhite = Color(0xFFF8FAFC);  // 배경 화이트
  static const Color pureWhite = Color(0xFFFFFFFF);        // 순수 화이트
  
  // 강조 색상
  static const Color accentOrange = Color(0xFFF97316);     // 주황색 (강조)
  static const Color accentGold = Color(0xFFFBBF24);       // 황금색 (보상)
  static const Color accentGreen = Color(0xFF10B981);      // 초록색 (완료)
  
  // 난이도 색상
  static const Color easyGreen = Color(0xFF34D399);        // 쉬움
  static const Color mediumSky = Color(0xFF60A5FA);        // 보통
  static const Color hardBlue = Color(0xFF3B82F6);         // 어려움
  
  // 희귀도 색상 (프리미엄)
  static const Color rareBlue = Color(0xFF3B82F6);         // 레어
  static const Color epicPurple = Color(0xFF8B5CF6);       // 에픽
  static const Color legendaryGold = Color(0xFFFFB800);    // 전설
  
  // 상태 색상
  static const Color inactive = Color(0xFFE5E7EB);         // 비활성
  static const Color active = Color(0xFF60A5FA);           // 활성
  static const Color completed = Color(0xFF10B981);        // 완료
  static const Color locked = Color(0xFF9CA3AF);           // 잠김
  
  // 텍스트 색상
  static const Color textPrimary = Color(0xFF1F2937);      // 주 텍스트
  static const Color textSecondary = Color(0xFF6B7280);    // 보조 텍스트
  static const Color textLight = Color(0xFF9CA3AF);        // 연한 텍스트
  static const Color textWhite = Color(0xFFFFFFFF);        // 흰색 텍스트
  
  // 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, skyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient skyGradient = LinearGradient(
    colors: [skyBlue, lightSkyBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [accentGold, Color(0xFFFCD34D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [epicPurple, legendaryGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 그림자
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primaryBlue.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}