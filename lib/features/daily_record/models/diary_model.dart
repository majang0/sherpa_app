import 'package:flutter/material.dart';

enum MoodType {
  veryHappy, // 😄 매우 기쁨
  happy, // 😊 기쁨
  neutral, // 😐 보통
  sad, // 😢 슬픔
  angry, // 😠 화남
  tired, // 😴 피곤
  excited, // 🤩 신남
  anxious, // 😰 불안
  grateful, // 🥰 감사
  confused, // 😵 혼란
}

class DiaryRecord {
  final String id;
  final String title;
  final String content;
  final MoodType mood;
  final List<String> tags;
  final String? imageUrl;
  final String? musicUrl;
  final String? videoUrl;
  final bool isPublic;
  final DateTime createdAt;
  final int xpEarned;

  const DiaryRecord({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.tags,
    this.imageUrl,
    this.musicUrl,
    this.videoUrl,
    required this.isPublic,
    required this.createdAt,
    required this.xpEarned,
  });

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood.name,
      'tags': tags,
      'imageUrl': imageUrl,
      'musicUrl': musicUrl,
      'videoUrl': videoUrl,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'xpEarned': xpEarned,
    };
  }

  factory DiaryRecord.fromJson(Map<String, dynamic> json) {
    return DiaryRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: MoodType.values.firstWhere(
        (e) => e.name == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'] as String?,
      musicUrl: json['musicUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      xpEarned: json['xpEarned'] as int,
    );
  }

  DiaryRecord copyWith({
    String? id,
    String? title,
    String? content,
    MoodType? mood,
    List<String>? tags,
    String? imageUrl,
    String? musicUrl,
    String? videoUrl,
    bool? isPublic,
    DateTime? createdAt,
    int? xpEarned,
  }) {
    return DiaryRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      musicUrl: musicUrl ?? this.musicUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }
}

class MoodData {
  final MoodType type;
  final String emoji;
  final String label;
  final String description;
  final Color color;

  const MoodData({
    required this.type,
    required this.emoji,
    required this.label,
    required this.description,
    required this.color,
  });

  static List<MoodData> get allMoods => [
        MoodData(
          type: MoodType.veryHappy,
          emoji: '😄',
          label: '매우 기쁨',
          description: '정말 행복한 하루!',
          color: Color(0xFFFFD700),
        ),
        MoodData(
          type: MoodType.happy,
          emoji: '😊',
          label: '기쁨',
          description: '기분 좋은 하루',
          color: Color(0xFF10B981),
        ),
        MoodData(
          type: MoodType.excited,
          emoji: '🤩',
          label: '신남',
          description: '에너지 넘치는 하루!',
          color: Color(0xFFED8936),
        ),
        MoodData(
          type: MoodType.grateful,
          emoji: '🥰',
          label: '감사',
          description: '감사한 마음이 드는 하루',
          color: Color(0xFFEC4899),
        ),
        MoodData(
          type: MoodType.neutral,
          emoji: '😐',
          label: '보통',
          description: '평범한 하루',
          color: Color(0xFF6B7280),
        ),
        MoodData(
          type: MoodType.tired,
          emoji: '😴',
          label: '피곤',
          description: '좀 피곤한 하루',
          color: Color(0xFF8B5CF6),
        ),
        MoodData(
          type: MoodType.confused,
          emoji: '😵',
          label: '혼란',
          description: '복잡한 하루',
          color: Color(0xFF06B6D4),
        ),
        MoodData(
          type: MoodType.anxious,
          emoji: '😰',
          label: '불안',
          description: '걱정이 많은 하루',
          color: Color(0xFFF59E0B),
        ),
        MoodData(
          type: MoodType.sad,
          emoji: '😢',
          label: '슬픔',
          description: '조금 슬픈 하루',
          color: Color(0xFF3B82F6),
        ),
        MoodData(
          type: MoodType.angry,
          emoji: '😠',
          label: '화남',
          description: '화가 나는 하루',
          color: Color(0xFFEF4444),
        ),
      ];

  static MoodData getMoodData(MoodType type) {
    return allMoods.firstWhere((mood) => mood.type == type);
  }
}
