import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/enhanced_gemini_dialogue_source.dart';

/// 📦 캐시된 메시지 데이터 구조
class CachedMessage {
  final String message;
  final DateTime generatedAt;
  final Map<String, dynamic> userContext;
  
  CachedMessage({
    required this.message,
    required this.generatedAt,
    required this.userContext,
  });
  
  factory CachedMessage.fromJson(Map<String, dynamic> json) {
    return CachedMessage(
      message: json['message'],
      generatedAt: DateTime.parse(json['generatedAt']),
      userContext: json['userContext'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'generatedAt': generatedAt.toIso8601String(),
      'userContext': userContext,
    };
  }
  
  /// 캐시 만료 여부 확인
  bool get isExpired {
    return DateTime.now().difference(generatedAt) > AiMessageCache._cacheExpiry;
  }
}

/// 🧠 AI 메시지 캐싱 및 사전 생성 시스템
/// 
/// 사용자 경험 향상을 위해 중요한 순간의 AI 메시지를 미리 생성하고 캐시합니다.
class AiMessageCache {
  static const String _cacheKey = 'ai_message_cache';
  static const Duration _cacheExpiry = Duration(days: 7); // 7일 후 만료
  
  final EnhancedGeminiDialogueSource _geminiSource = EnhancedGeminiDialogueSource();
  
  /// 🔥 중요한 이벤트들 - AI가 필요한 특별한 순간들
  static const List<SherpiContext> _premiumContexts = [
    SherpiContext.welcome,        // 첫 설치
    SherpiContext.levelUp,        // 중요 레벨업 (10, 20, 50)
    SherpiContext.longTimeNoSee,  // 재복귀
    SherpiContext.milestone,      // 특별 달성
    SherpiContext.specialEvent,   // 기념일
  ];
  
  /// 🚀 백그라운드에서 중요한 메시지들을 미리 생성
  Future<void> pregenerateImportantMessages({
    required Map<String, dynamic> currentUserContext,
    required Map<String, dynamic> currentGameContext,
  }) async {
    print('🤖 AI 메시지 사전 생성 시작...');
    
    final cache = await _loadCache();
    
    for (final context in _premiumContexts) {
      final cacheKey = '${context.name}_${_getUserHash(currentUserContext)}';
      
      // 이미 유효한 캐시가 있으면 스킵
      if (cache.containsKey(cacheKey) && !cache[cacheKey]!.isExpired) {
        continue;
      }
      
      try {
        // 백그라운드에서 AI 메시지 생성
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
        
        // 즉시 저장 (앱 종료 시 손실 방지)
        await _saveCache(cache);
        
        // API 부하 방지를 위한 딜레이
        await Future.delayed(const Duration(seconds: 2));
        
      } catch (e) {
        print('❌ ${context.name} 메시지 생성 실패: $e');
      }
    }
    
    print('🎉 AI 메시지 사전 생성 완료!');
  }
  
  /// ⚡ 캐시된 AI 메시지 즉시 반환
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
    
    return null; // 캐시 없음, 실시간 생성 필요
  }

  /// 💾 개별 메시지 캐싱 (개인화 시스템용)
  Future<void> cacheMessage(
    SherpiContext context,
    Map<String, dynamic> userContext,
    String message, {
    Duration? duration,
  }) async {
    try {
      final cache = await _loadCache();
      final cacheKey = userContext['cache_key'] as String? ?? 
                      '${context.name}_${_getUserHash(userContext)}';
      
      cache[cacheKey] = CachedMessage(
        message: message,
        generatedAt: DateTime.now(),
        userContext: userContext,
      );
      
      await _saveCache(cache);
      print('💾 개인화 메시지 캐싱 완료: $cacheKey');
    } catch (e) {
      print('❌ 메시지 캐싱 실패: $e');
    }
  }
  
  /// 🧹 만료된 캐시 정리
  Future<void> cleanExpiredCache() async {
    final cache = await _loadCache();
    final expiredKeys = cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      cache.remove(key);
    }
    
    await _saveCache(cache);
    print('🧹 만료된 캐시 ${expiredKeys.length}개 정리 완료');
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