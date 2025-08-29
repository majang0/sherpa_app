import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';

/// 📦 캐시된 메시지 데이터 구조 (LRU 지원)
class CachedMessage {
  final String message;
  final DateTime generatedAt;
  final Map<String, dynamic> userContext;
  DateTime lastAccessTime; // LRU를 위한 마지막 접근 시간
  
  CachedMessage({
    required this.message,
    required this.generatedAt,
    required this.userContext,
    DateTime? lastAccessTime,
  }) : lastAccessTime = lastAccessTime ?? DateTime.now();
  
  factory CachedMessage.fromJson(Map<String, dynamic> json) {
    return CachedMessage(
      message: json['message'],
      generatedAt: DateTime.parse(json['generatedAt']),
      userContext: json['userContext'] ?? {},
      lastAccessTime: json['lastAccessTime'] != null 
        ? DateTime.parse(json['lastAccessTime'])
        : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'generatedAt': generatedAt.toIso8601String(),
      'userContext': userContext,
      'lastAccessTime': lastAccessTime.toIso8601String(),
    };
  }
  
  /// 캐시 만료 여부 확인
  bool get isExpired {
    return DateTime.now().difference(generatedAt) > AiMessageCache._cacheExpiry;
  }
  
  /// 접근 시간 업데이트 (LRU용)
  void updateAccessTime() {
    lastAccessTime = DateTime.now();
  }
}

/// 🧠 단순화된 AI 메시지 캐시 시스템 (비활성화됨)
/// 
/// AI 시스템이 비활성화되어 캐시 기능도 사용하지 않습니다.
class AiMessageCache {
  static const String _cacheKey = 'ai_message_cache';
  static const Duration _cacheExpiry = Duration(hours: 24); // 24시간 후 만료 (더 짧게)
  
  
  /// 🚀 핵심 메시지만 백그라운드 생성 (비활성화됨)
  Future<void> pregenerateImportantMessages({
    required Map<String, dynamic> currentUserContext,
    required Map<String, dynamic> currentGameContext,
  }) async {
    // AI 시스템 비활성화 - 아무 작업도 하지 않음
    return;
  }
  
  /// 🧹 만료된 캐시 정리 (단순화)
  Future<void> _cleanupExpired(Map<String, CachedMessage> cache) async {
    final expiredKeys = cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      cache.remove(key);
    }
    
  }
  
  /// ⚡ 캐시된 AI 메시지 즉시 반환 (비활성화됨)
  Future<String?> getCachedMessage(
    SherpiContext context,
    Map<String, dynamic> userContext,
  ) async {
    // AI 시스템 비활성화 - 항상 null 반환
    return null;
  }
  
  /// 💾 캐시 로드
  Future<Map<String, CachedMessage>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = prefs.getString(_cacheKey);
    
    if (cacheData == null) return {};
    
    try {
      final Map<String, dynamic> cacheJson = jsonDecode(cacheData);
      return cacheJson.map((key, value) => 
          MapEntry(key, CachedMessage.fromJson(value)));
    } catch (e) {
      return {};
    }
  }
  
  /// 💾 캐시 저장
  Future<void> _saveCache(Map<String, CachedMessage> cache) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = cache.map((key, value) => 
        MapEntry(key, value.toJson()));
    
    await prefs.setString(_cacheKey, jsonEncode(cacheJson));
  }
  
  /// 👤 사용자 고유 해시 생성 (개인화를 위한 키)
  String _getUserHash(Map<String, dynamic> userContext) {
    final level = userContext['레벨']?.toString() ?? '1';
    final days = userContext['연속 접속일']?.toString() ?? '1';
    return '${level}_$days'.hashCode.toString();
  }
  
  /// 📊 캐시 상태 정보 (비활성화됨)
  Future<Map<String, dynamic>> getCacheStatus() async {
    // AI 시스템 비활성화 - 빈 상태 반환
    return {
      'total': 0,
      'valid': 0,
      'expired': 0,
      'contexts': [],
      'cache_enabled': false,
    };
  }
}