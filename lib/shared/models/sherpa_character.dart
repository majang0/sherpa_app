import 'package:flutter/material.dart';

enum SherpaEmotion {
  calm,        // 차분한 표정
  happy,       // 기쁜 표정
  worried,     // 걱정하는 표정
  smart,       // 안경 쓴 표정
  celebrating, // 축하하는 표정
  reading,     // 책 읽는 표정
  listening,   // 음악 듣는 표정
  meditating,  // 명상하는 표정
}

class SherpaCharacter {
  final SherpaEmotion emotion;
  final String message;
  final String? actionText;

  const SherpaCharacter({
    required this.emotion,
    required this.message,
    this.actionText,
  });

  String get emoji {
    switch (emotion) {
      case SherpaEmotion.calm:
        return '🐻'; // 차분한 셰르피
      case SherpaEmotion.happy:
        return '🐻'; // 기쁜 셰르피
      case SherpaEmotion.worried:
        return '🐻'; // 걱정하는 셰르피
      case SherpaEmotion.smart:
        return '🐻'; // 안경 쓴 셰르피
      case SherpaEmotion.celebrating:
        return '🐻'; // 축하하는 셰르피
      case SherpaEmotion.reading:
        return '🐻'; // 책 읽는 셰르피
      case SherpaEmotion.listening:
        return '🐻'; // 음악 듣는 셰르피
      case SherpaEmotion.meditating:
        return '🐻'; // 명상하는 셰르피
    }
  }

  // 감정별 색상 반환
  static Color getEmotionColor(SherpaEmotion emotion) {
    switch (emotion) {
      case SherpaEmotion.calm:
        return const Color(0xFF4299E1); // 파란색
      case SherpaEmotion.happy:
        return const Color(0xFF10B981); // 초록색
      case SherpaEmotion.worried:
        return const Color(0xFFF59E0B); // 노란색
      case SherpaEmotion.smart:
        return const Color(0xFF4299E1); // 파란색
      case SherpaEmotion.celebrating:
        return const Color(0xFFED8936); // 주황색
      case SherpaEmotion.reading:
        return const Color(0xFF10B981); // 초록색
      case SherpaEmotion.listening:
        return const Color(0xFFF59E0B); // 노란색
      case SherpaEmotion.meditating:
        return const Color(0xFF4299E1); // 파란색
    }
  }
}
