// lib/features/daily_record/utils/reading_utils.dart

import 'package:flutter/material.dart';

class ReadingUtils {
  /// 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    final today = DateTime.now();
    return isSameDay(date, today);
  }

  /// 평점에 따른 색상 반환
  static Color getRatingColor(double rating) {
    if (rating >= 4.5) return const Color(0xFF10B981); // 초록 (매우 좋음)
    if (rating >= 3.5) return const Color(0xFFF59E0B); // 노랑 (좋음)
    if (rating >= 2.5) return const Color(0xFFF97316); // 주황 (보통)
    if (rating >= 1.0) return const Color(0xFFEF4444); // 빨강 (별로)
    return const Color(0xFF9CA3AF); // 회색 (평점 없음)
  }

  /// 특정 날짜의 독서 로그 필터링
  static List<T> getLogsForDate<T>(
    List<T> logs, 
    DateTime date, 
    DateTime Function(T) getDate,
  ) {
    return logs.where((log) => isSameDay(getDate(log), date)).toList();
  }

  /// 주어진 날짜들의 주차별 데이터 생성
  static List<DateTime> getWeekDays([DateTime? baseDate]) {
    final now = baseDate ?? DateTime.now();
    return List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
  }

  /// 이번 주 시작일 계산
  static DateTime getWeekStart([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    return targetDate.subtract(Duration(days: targetDate.weekday - 1));
  }
}