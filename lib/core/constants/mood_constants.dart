// lib/core/constants/mood_constants.dart

import 'package:flutter/material.dart';
import '../theme/modern_colors.dart';

/// 🎭 일기 감정 시스템 중앙 관리 클래스
/// 모든 감정 관련 데이터를 통합하여 코드 중복을 방지하고 일관성을 보장합니다.
class MoodConstants {
  
  /// 📋 표준 8개 감정 키 목록
  static const List<String> standardMoods = [
    'excited',
    'happy', 
    'good',
    'normal',
    'thoughtful',
    'tired',
    'sad',
    'angry',
  ];

  /// 🎨 감정별 기본 데이터 매핑
  static Map<String, Map<String, dynamic>> get moodData => {
    'excited': {
      'emoji': '🥰', 
      'label': '설레요', 
      'color': ModernColors.getMoodLightColor('excited'),
      'selectedColor': ModernColors.getMoodMediumColor('excited'),
      'backgroundColor': ModernColors.getMoodPastelColor('excited'),
    },
    'happy': {
      'emoji': '😄', 
      'label': '기뻐요', 
      'color': ModernColors.getMoodLightColor('happy'),
      'selectedColor': ModernColors.getMoodMediumColor('happy'),
      'backgroundColor': ModernColors.getMoodPastelColor('happy'),
    },
    'good': {
      'emoji': '😊', 
      'label': '좋아요', 
      'color': ModernColors.getMoodLightColor('good'),
      'selectedColor': ModernColors.getMoodMediumColor('good'),
      'backgroundColor': ModernColors.getMoodPastelColor('good'),
    },
    'normal': {
      'emoji': '😐', 
      'label': '보통이에요', 
      'color': ModernColors.getMoodLightColor('normal'),
      'selectedColor': ModernColors.getMoodMediumColor('normal'),
      'backgroundColor': ModernColors.getMoodPastelColor('normal'),
    },
    'thoughtful': {
      'emoji': '🤔', 
      'label': '생각이 많아요', 
      'color': ModernColors.getMoodLightColor('thoughtful'),
      'selectedColor': ModernColors.getMoodMediumColor('thoughtful'),
      'backgroundColor': ModernColors.getMoodPastelColor('thoughtful'),
    },
    'tired': {
      'emoji': '😴', 
      'label': '피곤해요', 
      'color': ModernColors.getMoodLightColor('tired'),
      'selectedColor': ModernColors.getMoodMediumColor('tired'),
      'backgroundColor': ModernColors.getMoodPastelColor('tired'),
    },
    'sad': {
      'emoji': '😢', 
      'label': '슬퍼요', 
      'color': ModernColors.getMoodLightColor('sad'),
      'selectedColor': ModernColors.getMoodMediumColor('sad'),
      'backgroundColor': ModernColors.getMoodPastelColor('sad'),
    },
    'angry': {
      'emoji': '😠', 
      'label': '화나요', 
      'color': ModernColors.getMoodLightColor('angry'),
      'selectedColor': ModernColors.getMoodMediumColor('angry'),
      'backgroundColor': ModernColors.getMoodPastelColor('angry'),
    },
  };

  /// 🎯 특정 감정의 데이터 조회
  static Map<String, dynamic>? getMoodInfo(String moodKey) {
    return moodData[moodKey];
  }

  /// 😊 특정 감정의 이모지 조회
  static String getMoodEmoji(String moodKey) {
    return moodData[moodKey]?['emoji'] ?? '😐';
  }

  /// 📝 특정 감정의 라벨 조회
  static String getMoodLabel(String moodKey) {
    return moodData[moodKey]?['label'] ?? '보통이에요';
  }

  /// 🎨 특정 감정의 선택된 색상 조회
  static Color getMoodSelectedColor(String moodKey) {
    return moodData[moodKey]?['selectedColor'] ?? ModernColors.primary;
  }

  /// 🌈 특정 감정의 배경 색상 조회
  static Color getMoodBackgroundColor(String moodKey) {
    return moodData[moodKey]?['backgroundColor'] ?? ModernColors.backgroundElevated;
  }

  /// 🔍 감정 키 유효성 검사
  static bool isValidMoodKey(String moodKey) {
    return standardMoods.contains(moodKey);
  }

  /// 📊 모든 감정을 List<Map> 형태로 반환 (UI에서 사용)
  static List<Map<String, dynamic>> get moodList {
    return standardMoods.map((key) => {
      'id': key,
      ...moodData[key]!,
    }).toList();
  }

  /// 🎲 랜덤 감정 키 반환 (샘플 데이터용)
  static String getRandomMoodKey() {
    final random = DateTime.now().millisecondsSinceEpoch % standardMoods.length;
    return standardMoods[random];
  }
}