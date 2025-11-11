import 'package:flutter/material.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';

/// 목표 및 루틴 카테고리 관련 헬퍼 유틸리티
///
/// 카테고리별 색상, 아이콘, 그라데이션을 중앙에서 관리하여
/// 6개 파일에 중복되어 있던 148줄의 코드를 통합합니다.
///
/// 사용 파일:
/// - goal_card_widget.dart
/// - goal_modal_widget.dart
/// - previous_goals_widget.dart
/// - goal_achievement_widget.dart
/// - routine_card_widget.dart (루틴용)
/// - previous_routines_widget.dart (루틴용)
class GoalCategoryHelpers {
  /// 카테고리별 메인 색상 반환
  ///
  /// 지원 카테고리: 운동, 학습, 대회, 자격증
  static Color getColor(String category) {
    switch (category) {
      case '운동':
        return ModernColors.exercise;
      case '학습':
        return ModernColors.reading;
      case '대회':
        return ModernColors.climbing;
      case '자격증':
        return ModernColors.focus;
      default:
        return ModernColors.climbing;
    }
  }

  /// 카테고리별 아이콘 반환
  ///
  /// Material Icons 사용
  static IconData getIcon(String category) {
    switch (category) {
      case '운동':
        return Icons.fitness_center;
      case '학습':
        return Icons.menu_book;
      case '대회':
        return Icons.emoji_events;
      case '자격증':
        return Icons.workspace_premium;
      default:
        return Icons.flag;
    }
  }

  /// 카테고리별 그라데이션 반환
  ///
  /// 아이콘 배경 등에 사용
  static LinearGradient getGradient(String category) {
    final color = getColor(category);
    return LinearGradient(
      colors: [
        color,
        color.withValues(alpha: 0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// 카테고리별 라이트 배경 색상 반환
  ///
  /// 뱃지, 칩 배경에 사용
  static Color getLightColor(String category) {
    switch (category) {
      case '운동':
        return const Color(0xFFE8F5E9); // Light green
      case '학습':
        return const Color(0xFFFFF3E0); // Light orange
      case '대회':
        return const Color(0xFFE3F2FD); // Light blue
      case '자격증':
        return const Color(0xFFF3E5F5); // Light purple
      default:
        return const Color(0xFFE3F2FD);
    }
  }
}

/// 루틴 카테고리 관련 헬퍼 유틸리티
///
/// 루틴은 목표와 다른 카테고리 체계를 사용합니다.
class RoutineCategoryHelpers {
  /// 루틴 카테고리별 아이콘 반환
  ///
  /// 지원 카테고리: 운동, 문화, 학습, 건강, 기타
  static IconData getIcon(String category) {
    switch (category) {
      case '운동':
        return Icons.fitness_center;
      case '문화':
        return Icons.palette;
      case '학습':
        return Icons.school;
      case '건강':
        return Icons.favorite;
      case '기타':
        return Icons.more_horiz;
      default:
        return Icons.circle;
    }
  }

  /// 루틴 카테고리별 색상 반환 (목표와 공유)
  static Color getColor(String category) {
    switch (category) {
      case '운동':
        return ModernColors.exercise;
      case '문화':
        return ModernColors.reading; // 문화 = 독서 색상
      case '학습':
        return ModernColors.reading;
      case '건강':
        return ModernColors.success;
      case '기타':
        return ModernColors.textSecondary;
      default:
        return ModernColors.textSecondary;
    }
  }
}
