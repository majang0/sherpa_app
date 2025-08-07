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

/// 🧠 AI 메시지 캐싱 및 사전 생성 시스템
/// 
/// 단순화된 캐시 시스템으로 성능과 메모리 사용량을 최적화합니다.
class AiMessageCache {
  static const String _cacheKey = 'ai_message_cache';
  static const Duration _cacheExpiry = Duration(days: 3); // 3일 후 만료
  static const int _maxCacheSize = 100; // 최대 캐시 크기
  
  final EnhancedGeminiDialogueSource _geminiSource = EnhancedGeminiDialogueSource();
  
  
  /// 🚀 선택적 백그라운드 메시지 생성 (최적화됨)
  Future<void> pregenerateImportantMessages({
    required Map<String, dynamic> currentUserContext,
    required Map<String, dynamic> currentGameContext,
  }) async {
    print('🤖 AI 메시지 선택적 생성 시작...');
    
    final cache = await _loadCache();
    
    // 사용자별 맞춤 컨텍스트 선별
    final personalizedContexts = _getPersonalizedContexts(currentUserContext);
    
    for (final context in personalizedContexts) {
      final cacheKey = '${context.name}_${_getUserHash(currentUserContext)}';
      
      // 캐시 확인 및 스마트 갱신 판단
      if (cache.containsKey(cacheKey)) {
        final cached = cache[cacheKey]!;
        if (!cached.isExpired && !_shouldRefreshCache(cached, currentUserContext)) {
          continue; // 유효한 캐시가 있고 갱신 불필요
        }
      }
      
      // 캐시 크기 제한 확인
      if (cache.length >= _maxCacheSize) {
        await _cleanupLRU(cache);
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
        
        // API 부하 방지를 위한 딜레이 (줄임)
        await Future.delayed(const Duration(milliseconds: 1500));
        
      } catch (e) {
        print('❌ ${context.name} 메시지 생성 실패: $e');
      }
    }
    
    print('🎉 AI 메시지 선택적 생성 완료! (캐시 크기: ${cache.length})');
  }
  
  /// 🎯 사용자별 맞춤 컨텍스트 선별
  List<SherpiContext> _getPersonalizedContexts(Map<String, dynamic> userContext) {
    final contexts = <SherpiContext>[SherpiContext.welcome]; // 항상 포함
    
    final level = int.tryParse(userContext['레벨']?.toString() ?? '1') ?? 1;
    final lastLoginDays = userContext['last_login_days_ago'] as int? ?? 0;
    
    // 조건부 추가
    if (level > 0 && level % 5 == 0) contexts.add(SherpiContext.levelUp);
    if (lastLoginDays > 3) contexts.add(SherpiContext.longTimeNoSee);
    if (level >= 10) contexts.add(SherpiContext.milestone);
    
    return contexts;
  }
  
  /// ⚡ 캐시된 AI 메시지 즉시 반환 (LRU 업데이트)
  Future<String?> getCachedMessage(
    SherpiContext context,
    Map<String, dynamic> userContext,
  ) async {
    final cache = await _loadCache();
    final cacheKey = '${context.name}_${_getUserHash(userContext)}';
    
    final cachedMessage = cache[cacheKey];
    if (cachedMessage != null && !cachedMessage.isExpired) {
      // LRU: 접근 시간 업데이트
      cachedMessage.updateAccessTime();
      await _saveCache(cache);
      
      print('⚡ 캐시된 AI 메시지 사용: ${context.name}');
      return cachedMessage.message;
    }
    
    return null; // 캐시 없음, 실시간 생성 필요
  }

  /// 💾 개별 메시지 캐싱 (크기 제한 적용)
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
      
      // 캐시 크기 제한 확인
      if (cache.length >= _maxCacheSize) {
        await _cleanupLRU(cache);
      }
      
      cache[cacheKey] = CachedMessage(
        message: message,
        generatedAt: DateTime.now(),
        userContext: userContext,
      );
      
      await _saveCache(cache);
      print('💾 메시지 캐싱 완료: $cacheKey (캐시 크기: ${cache.length})');
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
  
  /// 🔄 LRU 정책으로 캐시 정리
  Future<void> _cleanupLRU(Map<String, CachedMessage> cache) async {
    // 최대 크기의 20%만큼 제거 (20개)
    final removeCount = (_maxCacheSize * 0.2).ceil();
    
    // 마지막 접근 시간 기준으로 정렬 (오래된 것부터)
    final sortedEntries = cache.entries.toList()
      ..sort((a, b) => a.value.lastAccessTime.compareTo(b.value.lastAccessTime));
    
    // 가장 오래된 항목부터 제거
    final toRemove = sortedEntries.take(removeCount);
    for (final entry in toRemove) {
      cache.remove(entry.key);
    }
    
    print('🔄 LRU 정리: ${removeCount}개 제거, 남은 캐시: ${cache.length}개');
  }
  
  /// 📊 스마트 캐시 갱신 (사용자 레벨 변경 감지)
  bool _shouldRefreshCache(CachedMessage cached, Map<String, dynamic> currentContext) {
    final cachedLevel = cached.userContext['레벨']?.toString() ?? '1';
    final currentLevel = currentContext['레벨']?.toString() ?? '1';
    return cachedLevel != currentLevel;
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