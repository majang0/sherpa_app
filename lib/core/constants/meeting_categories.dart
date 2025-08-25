// lib/core/constants/meeting_categories.dart

import 'package:flutter/material.dart';

/// 🎯 모임 카테고리 중앙집중식 관리 시스템
/// 
/// 기존 8개 파일에 중복되었던 카테고리 데이터를 통합 관리하여
/// 데이터 일관성과 유지보수성을 크게 향상시킵니다.
/// 
/// 통합 대상 파일들:
/// - global_user_model.dart
/// - meeting_full_view_widget.dart  
/// - meeting_edit_screen.dart
/// - meeting_detail_screen.dart
/// - enhanced_meeting_calendar_widget.dart
/// - activity_prompt_templates.dart
/// - record_models.dart
/// - available_meeting_model.dart
class MeetingCategories {
  
  /// 🎨 카테고리별 완전한 메타데이터
  static const Map<String, MeetingCategoryData> _categoryMap = {
    '스터디': MeetingCategoryData(
      name: '스터디',
      emoji: '📚',
      color: Color(0xFF3B82F6),
      gradient: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
      englishName: 'study',
    ),
    '운동': MeetingCategoryData(
      name: '운동',
      emoji: '🏃',
      color: Color(0xFF10B981),
      gradient: [Color(0xFF10B981), Color(0xFF047857)],
      englishName: 'exercise',
    ),
    '독서': MeetingCategoryData(
      name: '독서',
      emoji: '📖',
      color: Color(0xFF8B5CF6),
      gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      englishName: 'reading',
    ),
    '취미': MeetingCategoryData(
      name: '취미',
      emoji: '🎨',
      color: Color(0xFFF59E0B),
      gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
      englishName: 'hobby',
    ),
    '네트워킹': MeetingCategoryData(
      name: '네트워킹',
      emoji: '🤝',
      color: Color(0xFFEC4899),
      gradient: [Color(0xFFEC4899), Color(0xFFDB2777)],
      englishName: 'networking',
    ),
    '업무': MeetingCategoryData(
      name: '업무',
      emoji: '💼',
      color: Color(0xFF6B7280),
      gradient: [Color(0xFF6B7280), Color(0xFF4B5563)],
      englishName: 'work',
    ),
    '친목': MeetingCategoryData(
      name: '친목',
      emoji: '🍻',
      color: Color(0xFFEF4444),
      gradient: [Color(0xFFEF4444), Color(0xFFDC2626)],
      englishName: 'social',
    ),
    '종교': MeetingCategoryData(
      name: '종교',
      emoji: '🙏',
      color: Color(0xFF06B6D4),
      gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      englishName: 'religion',
    ),
    '봉사': MeetingCategoryData(
      name: '봉사',
      emoji: '❤️',
      color: Color(0xFF84CC16),
      gradient: [Color(0xFF84CC16), Color(0xFF65A30D)],
      englishName: 'volunteer',
    ),
  };

  /// 📝 모든 카테고리 목록
  static List<String> get allCategories => _categoryMap.keys.toList();

  /// 🎨 카테고리별 이모지 가져오기
  static String getEmoji(String category) {
    return _categoryMap[category]?.emoji ?? '📋';
  }

  /// 🌈 카테고리별 색상 가져오기
  static Color getColor(String category) {
    return _categoryMap[category]?.color ?? const Color(0xFF6B7280);
  }

  /// 🎨 카테고리별 그라데이션 가져오기
  static List<Color> getGradient(String category) {
    return _categoryMap[category]?.gradient ?? 
           [const Color(0xFF6B7280), const Color(0xFF4B5563)];
  }

  /// 🔤 카테고리별 영문명 가져오기
  static String getEnglishName(String category) {
    return _categoryMap[category]?.englishName ?? 'general';
  }

  /// 📊 카테고리별 완전한 데이터 가져오기
  static MeetingCategoryData? getCategoryData(String category) {
    return _categoryMap[category];
  }

  /// ✅ 유효한 카테고리인지 확인
  static bool isValidCategory(String category) {
    return _categoryMap.containsKey(category);
  }

  /// 🔄 레거시 호환성을 위한 Map 형태 데이터 (기존 코드 마이그레이션용)
  static Map<String, Map<String, dynamic>> get legacyFormat {
    return _categoryMap.map((key, value) => MapEntry(
      key,
      {
        'emoji': value.emoji,
        'color': value.color,
        'gradient': value.gradient,
        'english': value.englishName,
      },
    ));
  }

  /// 🎯 AI 프롬프트용 포맷 (activity_prompt_templates.dart 호환)
  static String getPromptFormat(String category) {
    final data = _categoryMap[category];
    if (data == null) return category;
    return '${data.name} ${data.emoji}';
  }
}

/// 📋 카테고리 메타데이터 클래스
class MeetingCategoryData {
  final String name;
  final String emoji;
  final Color color;
  final List<Color> gradient;
  final String englishName;

  const MeetingCategoryData({
    required this.name,
    required this.emoji,
    required this.color,
    required this.gradient,
    required this.englishName,
  });

  /// JSON 직렬화 지원
  Map<String, dynamic> toJson() => {
    'name': name,
    'emoji': emoji,
    'color': color.value,
    'gradient': gradient.map((c) => c.value).toList(),
    'englishName': englishName,
  };
}