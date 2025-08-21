import 'package:flutter/services.dart';

/// 햅틱 피드백 관리 유틸리티
class HapticFeedbackManager {
  /// 가벼운 햅틱 피드백
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// 중간 햅틱 피드백
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// 강한 햅틱 피드백
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// 선택 햅틱 피드백
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// 진동 피드백
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
