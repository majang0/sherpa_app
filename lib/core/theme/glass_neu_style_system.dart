// lib/core/theme/glass_neu_style_system.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../constants/app_colors_2025.dart';

/// 글래스모피즘과 뉴모피즘을 결합한 2025 스타일 시스템
/// 
/// 사용법:
/// ```dart
/// Container(
///   decoration: GlassNeuStyle.glassMorphism(
///     elevation: GlassNeuElevation.medium,
///     color: AppColors2025.primary,
///   ),
///   child: YourWidget(),
/// )
/// ```
class GlassNeuStyle {
  
  // ==================== 엘리베이션 레벨 ====================
  
  /// 엘리베이션 레벨 정의
  static const Map<GlassNeuElevation, double> _elevationValues = {
    GlassNeuElevation.none: 0,
    GlassNeuElevation.subtle: 2,
    GlassNeuElevation.low: 4,
    GlassNeuElevation.medium: 8,
    GlassNeuElevation.high: 16,
    GlassNeuElevation.extraHigh: 24,
  };

  // ==================== 글래스모피즘 스타일 ====================
  
  /// 기본 글래스모피즘 데코레이션
  static BoxDecoration glassMorphism({
    GlassNeuElevation elevation = GlassNeuElevation.medium,
    Color? color,
    double borderRadius = 16,
    double opacity = 0.15,
    Color? borderColor,
    double borderWidth = 1,
    bool enableBlur = true,
  }) {
    final elevationValue = _elevationValues[elevation] ?? 8;
    
    return BoxDecoration(
      color: (color ?? AppColors2025.glassWhite20).withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null 
          ? Border.all(
              color: borderColor.withOpacity(0.3),
              width: borderWidth,
            )
          : Border.all(
              color: AppColors2025.glassBorder,
              width: borderWidth,
            ),
      boxShadow: [
        // 메인 그림자
        BoxShadow(
          color: AppColors2025.shadowLight,
          blurRadius: elevationValue * 1.5,
          offset: Offset(0, elevationValue * 0.5),
          spreadRadius: 0,
        ),
        // 상단 하이라이트
        BoxShadow(
          color: AppColors2025.glassWhite10,
          blurRadius: elevationValue * 0.5,
          offset: Offset(0, -elevationValue * 0.2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// 블루 글래스모피즘 (브랜드 컬러)
  static BoxDecoration glassBlue({
    GlassNeuElevation elevation = GlassNeuElevation.medium,
    double borderRadius = 16,
    double opacity = 0.2,
  }) {
    return glassMorphism(
      elevation: elevation,
      color: AppColors2025.glassBlue20,
      borderRadius: borderRadius,
      opacity: opacity,
      borderColor: AppColors2025.glassBorderBlue,
    );
  }

  /// 카테고리별 글래스모피즘
  static BoxDecoration glassByCategory(
    String category, {
    GlassNeuElevation elevation = GlassNeuElevation.medium,
    double borderRadius = 16,
    double opacity = 0.15,
  }) {
    final categoryColor = AppColors2025.getCategoryGlassColor(category);
    final baseColor = AppColors2025.getCategoryColor2025(category);
    
    return glassMorphism(
      elevation: elevation,
      color: categoryColor,
      borderRadius: borderRadius,
      opacity: opacity,
      borderColor: baseColor,
    );
  }

  // ==================== 뉴모피즘 스타일 ====================
  
  /// 기본 뉴모피즘 데코레이션 (볼록한 효과)
  static BoxDecoration neumorphism({
    GlassNeuElevation elevation = GlassNeuElevation.medium,
    Color? baseColor,
    double borderRadius = 16,
    bool isPressed = false,
    bool isInverted = false,
  }) {
    final elevationValue = _elevationValues[elevation] ?? 8;
    final base = baseColor ?? AppColors2025.neuBase;
    
    // 눌렸을 때는 오목한 효과
    if (isPressed) {
      return _createInsetNeumorphism(base, elevationValue, borderRadius);
    }
    
    // 반전 모드 (오목한 효과)
    if (isInverted) {
      return _createInsetNeumorphism(base, elevationValue, borderRadius);
    }
    
    // 기본 볼록한 효과
    return _createRaisedNeumorphism(base, elevationValue, borderRadius);
  }

  /// 볼록한 뉴모피즘 생성
  static BoxDecoration _createRaisedNeumorphism(
    Color baseColor, 
    double elevation, 
    double borderRadius,
  ) {
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        // 어두운 그림자 (오른쪽 아래)
        BoxShadow(
          color: AppColors2025.createNeuShadow(baseColor, 0.1),
          blurRadius: elevation,
          offset: Offset(elevation * 0.5, elevation * 0.5),
          spreadRadius: 0,
        ),
        // 밝은 하이라이트 (왼쪽 위)
        BoxShadow(
          color: AppColors2025.createNeuHighlight(baseColor, 0.1),
          blurRadius: elevation * 0.5,
          offset: Offset(-elevation * 0.2, -elevation * 0.2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// 오목한 뉴모피즘 생성
  static BoxDecoration _createInsetNeumorphism(
    Color baseColor, 
    double elevation, 
    double borderRadius,
  ) {
    return BoxDecoration(
      color: AppColors2025.createNeuShadow(baseColor, 0.02),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        // 내부 어두운 그림자
        BoxShadow(
          color: AppColors2025.createNeuShadow(baseColor, 0.15),
          blurRadius: elevation * 0.8,
          offset: Offset(elevation * 0.3, elevation * 0.3),
          spreadRadius: -elevation * 0.3,
        ),
        // 내부 밝은 하이라이트
        BoxShadow(
          color: AppColors2025.createNeuHighlight(baseColor, 0.05),
          blurRadius: elevation * 0.5,
          offset: Offset(-elevation * 0.2, -elevation * 0.2),
          spreadRadius: -elevation * 0.2,
        ),
      ],
    );
  }

  /// 블루 뉴모피즘 (브랜드 컬러)
  static BoxDecoration neuBlue({
    GlassNeuElevation elevation = GlassNeuElevation.medium,
    double borderRadius = 16,
    bool isPressed = false,
  }) {
    return neumorphism(
      elevation: elevation,
      baseColor: AppColors2025.neuBaseBlue,
      borderRadius: borderRadius,
      isPressed: isPressed,
    );
  }

  // ==================== 하이브리드 스타일 (글래스 + 뉴모피즘) ====================
  
  /// 글래스모피즘과 뉴모피즘을 결합한 하이브리드 스타일
  static BoxDecoration hybrid({
    GlassNeuElevation elevation = GlassNeuElevation.medium,
    Color? color,
    double borderRadius = 16,
    double glassOpacity = 0.1,
    bool isPressed = false,
  }) {
    final elevationValue = _elevationValues[elevation] ?? 8;
    final baseColor = color ?? AppColors2025.primary;
    
    if (isPressed) {
      return _createPressedHybrid(baseColor, elevationValue, borderRadius, glassOpacity);
    }
    
    return _createRaisedHybrid(baseColor, elevationValue, borderRadius, glassOpacity);
  }

  /// 볼록한 하이브리드 스타일
  static BoxDecoration _createRaisedHybrid(
    Color baseColor,
    double elevation,
    double borderRadius,
    double glassOpacity,
  ) {
    return BoxDecoration(
      // 글래스 효과를 위한 반투명 색상
      color: baseColor.withOpacity(glassOpacity),
      borderRadius: BorderRadius.circular(borderRadius),
      // 글래스 테두리
      border: Border.all(
        color: baseColor.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        // 뉴모피즘 어두운 그림자
        BoxShadow(
          color: AppColors2025.createNeuShadow(AppColors2025.neuBase, 0.1),
          blurRadius: elevation,
          offset: Offset(elevation * 0.5, elevation * 0.5),
          spreadRadius: 0,
        ),
        // 뉴모피즘 밝은 하이라이트
        BoxShadow(
          color: AppColors2025.neuHighlight,
          blurRadius: elevation * 0.5,
          offset: Offset(-elevation * 0.2, -elevation * 0.2),
          spreadRadius: 0,
        ),
        // 글래스 하이라이트
        BoxShadow(
          color: AppColors2025.glassWhite10,
          blurRadius: elevation * 0.3,
          offset: Offset(0, -elevation * 0.1),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// 눌린 상태 하이브리드 스타일
  static BoxDecoration _createPressedHybrid(
    Color baseColor,
    double elevation,
    double borderRadius,
    double glassOpacity,
  ) {
    return BoxDecoration(
      color: AppColors2025.createNeuShadow(AppColors2025.neuBase, 0.02),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: baseColor.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: [
        // 내부 그림자 (눌린 효과)
        BoxShadow(
          color: AppColors2025.createNeuShadow(AppColors2025.neuBase, 0.15),
          blurRadius: elevation * 0.6,
          offset: Offset(elevation * 0.2, elevation * 0.2),
          spreadRadius: -elevation * 0.2,
        ),
        // 글래스 효과 유지
        BoxShadow(
          color: baseColor.withOpacity(glassOpacity * 0.5),
          blurRadius: elevation * 0.3,
          offset: Offset(0, 0),
          spreadRadius: 0,
        ),
      ],
    );
  }

  // ==================== 특수 효과 ====================
  
  /// 플로팅 글래스 효과 (강한 블러와 그림자)
  static BoxDecoration floatingGlass({
    Color? color,
    double borderRadius = 20,
    double elevation = 12,
  }) {
    return BoxDecoration(
      color: (color ?? AppColors2025.glassWhite20).withOpacity(0.25),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors2025.glassBorder,
        width: 1,
      ),
      boxShadow: [
        // 메인 플로팅 그림자
        BoxShadow(
          color: AppColors2025.shadowMedium,
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
          spreadRadius: 0,
        ),
        // 글래스 하이라이트
        BoxShadow(
          color: AppColors2025.glassWhite30,
          blurRadius: elevation * 0.5,
          offset: Offset(0, -elevation * 0.3),
          spreadRadius: 0,
        ),
        // 컬러 글로우
        if (color != null)
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: elevation * 1.5,
            offset: Offset(0, elevation * 0.5),
            spreadRadius: elevation * 0.2,
          ),
      ],
    );
  }

  /// 소프트 뉴모피즘 (매우 부드러운 효과)
  static BoxDecoration softNeumorphism({
    Color? baseColor,
    double borderRadius = 16,
    double intensity = 0.05,
  }) {
    final base = baseColor ?? AppColors2025.neuBase;
    
    return BoxDecoration(
      color: base,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        // 매우 부드러운 어두운 그림자
        BoxShadow(
          color: AppColors2025.createNeuShadow(base, intensity),
          blurRadius: 6,
          offset: const Offset(3, 3),
          spreadRadius: 0,
        ),
        // 매우 부드러운 밝은 하이라이트
        BoxShadow(
          color: AppColors2025.createNeuHighlight(base, intensity),
          blurRadius: 4,
          offset: const Offset(-2, -2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  // ==================== 인터랙티브 효과 ====================
  
  /// 호버 효과를 위한 스타일 전환
  static BoxDecoration getHoverStyle(BoxDecoration baseDecoration) {
    // 기존 그림자들을 더 강하게 만들기
    final newShadows = baseDecoration.boxShadow?.map((shadow) {
      return BoxShadow(
        color: shadow.color,
        blurRadius: shadow.blurRadius * 1.2,
        offset: shadow.offset * 1.1,
        spreadRadius: shadow.spreadRadius,
      );
    }).toList() ?? [];

    return baseDecoration.copyWith(
      boxShadow: newShadows,
    );
  }

  /// 탭 애니메이션을 위한 스타일
  static BoxDecoration getTapStyle(BoxDecoration baseDecoration) {
    // 그림자를 줄여서 눌린 효과 연출
    final newShadows = baseDecoration.boxShadow?.map((shadow) {
      return BoxShadow(
        color: shadow.color,
        blurRadius: shadow.blurRadius * 0.5,
        offset: shadow.offset * 0.3,
        spreadRadius: shadow.spreadRadius,
      );
    }).toList() ?? [];

    return baseDecoration.copyWith(
      boxShadow: newShadows,
    );
  }

  // ==================== 유틸리티 메서드 ====================
  
  /// BackdropFilter를 사용한 블러 효과
  static Widget createBlurEffect({
    required Widget child,
    double sigmaX = 10,
    double sigmaY = 10,
  }) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }

  /// 햅틱 피드백이 포함된 탭 핸들러
  static VoidCallback createHapticTap(VoidCallback? onTap) {
    return () {
      HapticFeedback.lightImpact();
      onTap?.call();
    };
  }

  /// 그라데이션과 글래스 효과를 결합
  static BoxDecoration gradientGlass({
    required Gradient gradient,
    double borderRadius = 16,
    double opacity = 0.8,
    GlassNeuElevation elevation = GlassNeuElevation.medium,
  }) {
    final elevationValue = _elevationValues[elevation] ?? 8;
    final linearGradient = gradient as LinearGradient;
    
    return BoxDecoration(
      gradient: LinearGradient(
        begin: linearGradient.begin,
        end: linearGradient.end,
        colors: linearGradient.colors.map(
          (color) => color.withOpacity(opacity),
        ).toList(),
        stops: linearGradient.stops,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors2025.glassBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors2025.shadowLight,
          blurRadius: elevationValue * 1.5,
          offset: Offset(0, elevationValue * 0.5),
          spreadRadius: 0,
        ),
      ],
    );
  }
}

/// 엘리베이션 레벨 열거형
enum GlassNeuElevation {
  none,        // 0px
  subtle,      // 2px
  low,         // 4px  
  medium,      // 8px
  high,        // 16px
  extraHigh,   // 24px
}

/// 스타일 타입 열거형
enum GlassNeuStyleType {
  glass,       // 순수 글래스모피즘
  neu,         // 순수 뉴모피즘
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  floating,    // 플로팅 글래스
  soft,        // 소프트 뉴모피즘
}

/// 2025 스타일 확장 클래스 (더 쉬운 사용을 위한)
extension GlassNeuStyleExtension on BoxDecoration {
  /// 호버 효과 추가
  BoxDecoration withHover() => GlassNeuStyle.getHoverStyle(this);
  
  /// 탭 효과 추가
  BoxDecoration withTap() => GlassNeuStyle.getTapStyle(this);
}