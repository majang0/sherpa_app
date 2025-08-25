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
/// - available_meeting_detail_screen.dart, meeting_log_detail_screen.dart
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

  /// 🆕 Missing 카테고리들 추가 (available_meeting_model.dart 호환성)
  static const Map<String, MeetingCategoryData> _additionalCategories = {
    '전체': MeetingCategoryData(
      name: '전체',
      emoji: '🌟',
      color: Color(0xFF6366F1),
      gradient: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      englishName: 'all',
    ),
    '문화': MeetingCategoryData(
      name: '문화',
      emoji: '🎭',
      color: Color(0xFFEC4899),
      gradient: [Color(0xFFEC4899), Color(0xFFDB2777)],
      englishName: 'culture',
    ),
    '아웃도어': MeetingCategoryData(
      name: '아웃도어',
      emoji: '🏔️',
      color: Color(0xFF06B6D4),
      gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      englishName: 'outdoor',
    ),
  };

  /// 📝 모든 카테고리 목록 (통합)
  static List<String> get allCategories => [
    ..._categoryMap.keys.toList(),
    ..._additionalCategories.keys.toList(),
  ];

  /// 🎨 카테고리별 이모지 가져오기 (확장 지원)
  static String getEmoji(String category) {
    return _categoryMap[category]?.emoji ?? 
           _additionalCategories[category]?.emoji ?? '📋';
  }

  /// 🌈 카테고리별 색상 가져오기 (확장 지원)
  static Color getColor(String category) {
    return _categoryMap[category]?.color ?? 
           _additionalCategories[category]?.color ?? 
           const Color(0xFF6B7280);
  }

  /// 🎨 카테고리별 그라데이션 가져오기 (확장 지원)
  static List<Color> getGradient(String category) {
    return _categoryMap[category]?.gradient ?? 
           _additionalCategories[category]?.gradient ??
           [const Color(0xFF6B7280), const Color(0xFF4B5563)];
  }

  /// 🔤 카테고리별 영문명 가져오기 (확장 지원)
  static String getEnglishName(String category) {
    return _categoryMap[category]?.englishName ?? 
           _additionalCategories[category]?.englishName ?? 
           'general';
  }

  /// 📊 카테고리별 완전한 데이터 가져오기 (확장 지원)
  static MeetingCategoryData? getCategoryData(String category) {
    return _categoryMap[category] ?? _additionalCategories[category];
  }

  /// ✅ 유효한 카테고리인지 확인 (확장 지원)
  static bool isValidCategory(String category) {
    return _categoryMap.containsKey(category) || 
           _additionalCategories.containsKey(category);
  }

  /// 🔄 레거시 호환성을 위한 Map 형태 데이터 (확장 지원)
  static Map<String, Map<String, dynamic>> get legacyFormat {
    final combined = <String, Map<String, dynamic>>{};
    
    // 기본 카테고리 추가
    _categoryMap.forEach((key, value) {
      combined[key] = {
        'emoji': value.emoji,
        'color': value.color,
        'gradient': value.gradient,
        'english': value.englishName,
      };
    });
    
    // 확장 카테고리 추가
    _additionalCategories.forEach((key, value) {
      combined[key] = {
        'emoji': value.emoji,
        'color': value.color,
        'gradient': value.gradient,
        'english': value.englishName,
      };
    });
    
    return combined;
  }

  /// 🎯 AI 프롬프트용 포맷 (확장 지원)
  static String getPromptFormat(String category) {
    final data = _categoryMap[category] ?? _additionalCategories[category];
    if (data == null) return category;
    return '${data.name} ${data.emoji}';
  }

  /// 🔗 Enum 매핑 헬퍼 (available_meeting_model.dart용)
  static String enumToDisplayName(String enumName) {
    switch (enumName) {
      case 'all': return '전체';
      case 'exercise': return '운동';
      case 'study': return '스터디';
      case 'reading': return '독서';
      case 'networking': return '네트워킹';
      case 'culture': return '문화';
      case 'outdoor': return '아웃도어';
      default: return enumName;
    }
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
    'color': color.toARGB32(),
    'gradient': gradient.map((c) => c.toARGB32()).toList(),
    'englishName': englishName,
  };
}