import 'package:flutter/material.dart';
import 'package:sherpa_app/core/constants/meeting_categories.dart';

/// 모임 기록 모델
class MeetingLog {
  final String id;
  final DateTime date;
  final String meetingName;
  final String category;
  final double satisfaction;
  final String mood;
  final String? note;
  final bool isShared;

  const MeetingLog({
    required this.id,
    required this.date,
    required this.meetingName,
    required this.category,
    required this.satisfaction,
    required this.mood,
    this.note,
    this.isShared = false,
  });

  /// 모임 이름을 짧게 축약해 표시한다.
  String get shortName {
    if (meetingName.length <= 6) return meetingName;
    return '${meetingName.substring(0, 6)}...';
  }

  /// 만족도에 따라 시각화에 사용할 대표 색상을 반환한다.
  Color get satisfactionColor {
    if (satisfaction >= 4.0) return const Color(0xFF10B981); // 초록
    if (satisfaction >= 3.0) return const Color(0xFFF59E0B); // 노랑
    return const Color(0xFFEF4444); // 빨강
  }

  /// 중앙 집중식 카테고리 시스템의 이모지를 반환한다.
  String get categoryIcon => MeetingCategories.getEmoji(category);

  /// 기록된 기분 상태에 맞는 이모지를 반환한다.
  String get moodIcon {
    switch (mood) {
      case 'very_happy':
      case 'excited':
        return '😄';
      case 'happy':
        return '😊';
      case 'good':
        return '🙂';
      case 'normal':
        return '😐';
      case 'thoughtful':
        return '🤔';
      case 'tired':
        return '😴';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'stressed':
        return '😰';
      default:
        return '😊';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'meetingName': meetingName,
      'category': category,
      'satisfaction': satisfaction,
      'mood': mood,
      'note': note,
      'isShared': isShared,
    };
  }

  factory MeetingLog.fromJson(Map<String, dynamic> json) {
    return MeetingLog(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      meetingName: json['meetingName'] ?? '',
      category: json['category'] ?? '',
      satisfaction: (json['satisfaction'] ?? 0).toDouble(),
      mood: json['mood'] ?? 'happy',
      note: json['note'],
      isShared: json['isShared'] ?? false,
    );
  }
}
