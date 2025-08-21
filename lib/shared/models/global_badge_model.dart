// lib/shared/models/global_badge_model.dart

import 'package:flutter/material.dart';

enum GlobalBadgeTier {
  common,
  rare,
  epic,
  legendary;

  String get displayName {
    switch (this) {
      case GlobalBadgeTier.common:
        return '일반';
      case GlobalBadgeTier.rare:
        return '희귀';
      case GlobalBadgeTier.epic:
        return '영웅';
      case GlobalBadgeTier.legendary:
        return '전설';
    }
  }

  Color get color {
    switch (this) {
      case GlobalBadgeTier.common:
        return const Color(0xFF9E9E9E);
      case GlobalBadgeTier.rare:
        return const Color(0xFF4A90E2);
      case GlobalBadgeTier.epic:
        return const Color(0xFF9C27B0);
      case GlobalBadgeTier.legendary:
        return const Color(0xFFFF9800);
    }
  }

  Color get glowColor {
    switch (this) {
      case GlobalBadgeTier.common:
        return const Color(0xFF9E9E9E).withOpacity(0.3);
      case GlobalBadgeTier.rare:
        return const Color(0xFF4A90E2).withOpacity(0.4);
      case GlobalBadgeTier.epic:
        return const Color(0xFF9C27B0).withOpacity(0.5);
      case GlobalBadgeTier.legendary:
        return const Color(0xFFFF9800).withOpacity(0.6);
    }
  }
}

class GlobalBadge {
  final String id;
  final String name;
  final String description;
  final GlobalBadgeTier tier;
  final String effectType;
  final double effectValue;
  final String iconEmoji;
  final int iconCodePoint;
  final String? iconFontFamily;

  const GlobalBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.effectType,
    required this.effectValue,
    required this.iconEmoji,
    required this.iconCodePoint,
    this.iconFontFamily,
  });

  IconData get iconData => IconData(iconCodePoint, fontFamily: iconFontFamily);

  GlobalBadge copyWith({
    String? id,
    String? name,
    String? description,
    GlobalBadgeTier? tier,
    String? effectType,
    double? effectValue,
    String? iconEmoji,
    int? iconCodePoint,
    String? iconFontFamily,
  }) {
    return GlobalBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tier: tier ?? this.tier,
      effectType: effectType ?? this.effectType,
      effectValue: effectValue ?? this.effectValue,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tier': tier.name,
      'effectType': effectType,
      'effectValue': effectValue,
      'iconEmoji': iconEmoji,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
    };
  }

  factory GlobalBadge.fromJson(Map<String, dynamic> json) {
    return GlobalBadge(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tier: GlobalBadgeTier.values.firstWhere(
            (e) => e.name == json['tier'],
        orElse: () => GlobalBadgeTier.common,
      ),
      effectType: json['effectType'] ?? '',
      effectValue: (json['effectValue'] ?? 0).toDouble(),
      iconEmoji: json['iconEmoji'] ?? '🏆',
      iconCodePoint: json['iconCodePoint'] ?? 0xe7e9,
      iconFontFamily: json['iconFontFamily'],
    );
  }
}
