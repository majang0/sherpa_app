import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/enhanced_gemini_dialogue_source.dart';

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

/// 🧠 단순화된 AI 메시지 캐시 시스템
/// 
/// 핵심 기능만 유지하여 성능과 메모리를 최적화합니다.
class AiMessageCache {
  static const String _cacheKey = 'ai_message_cache';
  static const Duration _cacheExpiry = Duration(hours: 24); // 24시간 후 만료 (더 짧게)
  static const int _maxCacheSize = 50; // 최대 캐시 크기 (더 작게)
  
  final EnhancedGeminiDialogueSource _geminiSource = EnhancedGeminiDialogueSource();
  
  
  /// 🚀 핵심 메시지만 백그라운드 생성 (단순화)
  Future<void> pregenerateImportantMessages({
    required Map<String, dynamic> currentUserContext,
    required Map<String, dynamic> currentGameContext,
  }) async {
    print('🤖 핵심 AI 메시지 생성 시작...');
    
    final cache = await _loadCache();
    
    // 핵심 컨텍스트만 선별 (3개로 제한)
    final coreContexts = [
      SherpiContext.welcome,
      SherpiContext.levelUp,
      SherpiContext.encouragement
    ];
    
    for (final context in coreContexts) {
      final cacheKey = '${context.name}_${_getUserHash(currentUserContext)}';
      
      // 캐시 확인
      if (cache.containsKey(cacheKey)) {
        final cached = cache[cacheKey]!;
        if (!cached.isExpired) {
          continue; // 유효한 캐시가 있음
        }
      }
      
      try {
        // AI 메시지 생성
        final message = await _geminiSource.getDialogue(
          context,
          currentUserContext,
          currentGameContext,
        );
        
        // 캐시에 저장
        cache[cacheKey] = CachedMessage(
          message: message,
          generatedAt: DateTime.now(),
          userContext: currentUserContext,
        );
        
        print('✅ ${context.name} 메시지 생성 완료');
        
        // API 부하 방지를 위한 딜레이
        await Future.delayed(const Duration(seconds: 2));
        
      } catch (e) {
        print('❌ ${context.name} 메시지 생성 실패: $e');
      }
    }
    
    // 캐시 정리 및 저장
    await _cleanupExpired(cache);
    await _saveCache(cache);
    
    print('🎉 핵심 AI 메시지 생성 완료! (캐시 크기: ${cache.length})');
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
    
    print('🧹 만료된 캐시 ${expiredKeys.length}개 정리');
  }
  
  /// ⚡ 캐시된 AI 메시지 즉시 반환 (단순화)
  Future<String?> getCachedMessage(
    SherpiContext context,
    Map<String, dynamic> userContext,
  ) async {
    final cache = await _loadCache();
    final cacheKey = '${context.name}_${_getUserHash(userContext)}';
    
    final cachedMessage = cache[cacheKey];
    if (cachedMessage != null && !cachedMessage.isExpired) {
      print('⚡ 캐시된 AI 메시지 사용: ${context.name}');
      return cachedMessage.message;
    }
    
    return null; // 캐시 없음
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
      print('❌ 캐시 로드 실패: $e');
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
  
  /// 📊 캐시 상태 정보
  Future<Map<String, dynamic>> getCacheStatus() async {
    final cache = await _loadCache();
    final validCount = cache.values.where((msg) => !msg.isExpired).length;
    final expiredCount = cache.values.where((msg) => msg.isExpired).length;
    
    return {
      'total': cache.length,
      'valid': validCount,
      'expired': expiredCount,
      'contexts': cache.keys.toList(),
    };
  }
}