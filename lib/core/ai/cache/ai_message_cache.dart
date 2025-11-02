import 'dart:collection';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 📦 캐시된 메시지 데이터 구조 (LRU 지원)
class CachedMessage {
  final String message;
  final DateTime generatedAt;
  final Map<String, dynamic> userContext;
  final Duration ttl;
  DateTime lastAccessTime; // LRU를 위한 마지막 접근 시간

  CachedMessage({
    required this.message,
    required this.generatedAt,
    required this.userContext,
    required this.ttl,
    DateTime? lastAccessTime,
  }) : lastAccessTime = lastAccessTime ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'generatedAt': generatedAt.toIso8601String(),
      'userContext': userContext,
      'lastAccessTime': lastAccessTime.toIso8601String(),
      'ttlMs': ttl.inMilliseconds,
    };
  }

  /// 캐시 만료 여부 확인
  bool get isExpired => DateTime.now().isAfter(generatedAt.add(ttl));

  /// 접근 시간 업데이트 (LRU용)
  void updateAccessTime() {
    lastAccessTime = DateTime.now();
  }
}

/// 🧠 AI-Agnostic 메시지 캐시 시스템
///
/// OpenAI 등 모든 AI 제공자의 응답을 캐싱합니다.
/// Feature-agnostic: 모든 feature에서 재사용 가능 (sherpi, meetings, analysis, etc.)
class AiMessageCache {
  static const String _cacheKey = 'ai_message_cache_v3'; // v3: AI-agnostic
  static const int _cacheVersion = 3;
  static const Duration _fallbackTTL = Duration(hours: 12);
  static const int _maxCacheSize = 50;

  /// Context별 TTL 설정 (feature에서 주입 가능)
  final Map<String, Duration> _contextTTL;

  static Map<String, dynamic>? _lastMeta;

  /// 생성자: TTL 설정을 주입받거나 기본값 사용
  AiMessageCache({Map<String, Duration>? contextTTL})
      : _contextTTL = contextTTL ?? {};

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

    if (expiredKeys.isNotEmpty) {
      await _saveCache(cache);
    }
  }

  /// ⚡ 캐시된 AI 메시지 즉시 반환
  ///
  /// [context]: AI 컨텍스트 (예: 'dailyGreeting', 'questComplete', 'meeting_suggestion')
  /// [userId]: 사용자 ID
  /// [userContext]: 사용자 컨텍스트 (레벨, 활동 등)
  /// [customTTL]: 커스텀 TTL (선택적, 없으면 contextTTL 또는 fallback 사용)
  Future<String?> getCachedMessage({
    required String userId,
    required String context,
    required Map<String, dynamic> userContext,
    String? meetingSetId,
    Duration? customTTL,
  }) async {
    final cache = await _loadCache();
    await _cleanupExpired(cache);

    final key = _buildCacheKey(
      userId: userId,
      context: context,
      userContext: userContext,
      meetingSetId: meetingSetId,
    );
    final cached = cache[key];
    if (cached == null) {
      return null;
    }

    if (cached.isExpired) {
      cache.remove(key);
      await _saveCache(cache);
      return null;
    }

    cached.updateAccessTime();
    await _saveCache(cache);
    return cached.message;
  }

  /// 💾 AI 메시지 캐시에 저장
  ///
  /// [context]: AI 컨텍스트 (예: 'dailyGreeting', 'questComplete', 'meeting_suggestion')
  /// [userId]: 사용자 ID
  /// [message]: 캐시할 AI 응답 메시지
  /// [userContext]: 사용자 컨텍스트 (레벨, 활동 등)
  /// [customTTL]: 커스텀 TTL (선택적, 없으면 contextTTL 또는 fallback 사용)
  Future<void> storeMessage({
    required String userId,
    required String context,
    required Map<String, dynamic> userContext,
    required String message,
    String? meetingSetId,
    Duration? customTTL,
  }) async {
    final cache = await _loadCache();
    await _cleanupExpired(cache);

    final key = _buildCacheKey(
      userId: userId,
      context: context,
      userContext: userContext,
      meetingSetId: meetingSetId,
    );

    // TTL 우선순위: customTTL > contextTTL map > fallback
    final ttl = customTTL ?? _contextTTL[context] ?? _fallbackTTL;

    cache[key] = CachedMessage(
      message: message,
      generatedAt: DateTime.now(),
      userContext: userContext,
      ttl: ttl,
    );

    if (cache.length > _maxCacheSize) {
      cache.remove(_findLeastRecentlyUsedKey(cache));
    }

    await _saveCache(cache);
  }

  /// 💾 캐시 로드
  Future<Map<String, CachedMessage>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    // Legacy 키 제거 (v1)
    await prefs.remove('ai_message_cache');

    final cacheData = prefs.getString(_cacheKey);
    if (cacheData == null) {
      _lastMeta = null;
      return {};
    }

    try {
      final raw = jsonDecode(cacheData) as Map<String, dynamic>;
      final meta = raw['_meta'] as Map<String, dynamic>? ?? {'version': 1};
      final version = meta['version'] as int? ?? 1;

      if (version != _cacheVersion) {
        await prefs.remove(_cacheKey);
        _lastMeta = null;
        return {};
      }

      _lastMeta = meta;

      final entries = raw.entries
          .where((entry) => entry.key != '_meta')
          .where((entry) => entry.value is Map<String, dynamic>);

      final result = <String, CachedMessage>{};
      for (final entry in entries) {
        final mapValue = entry.value as Map<String, dynamic>;
        final ttlMs = mapValue['ttlMs'] as int?;
        final ttl =
            ttlMs != null ? Duration(milliseconds: ttlMs) : _fallbackTTL;
        result[entry.key] = CachedMessage(
          message: mapValue['message'] as String? ?? '',
          generatedAt: DateTime.parse(
            mapValue['generatedAt'] as String? ??
                DateTime.now().toIso8601String(),
          ),
          userContext:
              (mapValue['userContext'] as Map<String, dynamic>?) ?? const {},
          ttl: ttl,
          lastAccessTime: mapValue['lastAccessTime'] != null
              ? DateTime.parse(mapValue['lastAccessTime'] as String)
              : DateTime.now(),
        );
      }

      return result;
    } catch (e) {
      await prefs.remove(_cacheKey);
      _lastMeta = null;
      return {};
    }
  }

  /// 💾 캐시 저장
  Future<void> _saveCache(Map<String, CachedMessage> cache) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = <String, dynamic>{
      '_meta': {
        'version': _cacheVersion,
        'savedAt': DateTime.now().toIso8601String(),
        'entryCount': cache.length,
      },
    };

    cacheJson.addAll(
      cache.map((key, value) => MapEntry(key, value.toJson())),
    );

    _lastMeta = cacheJson['_meta'] as Map<String, dynamic>;
    await prefs.setString(_cacheKey, jsonEncode(cacheJson));
  }

  String _buildCacheKey({
    required String userId,
    required String context,
    required Map<String, dynamic> userContext,
    String? meetingSetId,
  }) {
    final buffer = StringBuffer()
      ..write('user:$userId')
      ..write(':ctx:$context'); // Generic context string

    if (meetingSetId != null && meetingSetId.isNotEmpty) {
      buffer.write(':meet:$meetingSetId');
    }

    if (userContext.isNotEmpty) {
      buffer.write(':hash:${_generateStableHash(userContext)}');
    }

    return buffer.toString();
  }

  String _findLeastRecentlyUsedKey(
    Map<String, CachedMessage> cache,
  ) {
    String lruKey = cache.keys.first;
    DateTime oldest = cache[lruKey]!.lastAccessTime;

    cache.forEach((key, value) {
      if (value.lastAccessTime.isBefore(oldest)) {
        oldest = value.lastAccessTime;
        lruKey = key;
      }
    });

    return lruKey;
  }

  /// 📊 캐시 상태 정보
  Future<Map<String, dynamic>> getCacheStatus() async {
    final cache = await _loadCache();
    final total = cache.length;
    final valid = cache.values.where((entry) => !entry.isExpired).length;
    final expired = total - valid;

    return {
      'total': total,
      'valid': valid,
      'expired': expired,
      'cache_enabled': total > 0,
      'version': _lastMeta?['version'] ?? _cacheVersion,
      'last_saved_at': _lastMeta?['savedAt'],
    };
  }

  String _generateStableHash(Map<String, dynamic> value) {
    final normalized = _normalizeJson(value);
    final encoded = jsonEncode(normalized);
    return base64Url.encode(utf8.encode(encoded));
  }

  dynamic _normalizeJson(dynamic value) {
    if (value is Map) {
      final sorted = SplayTreeMap<String, dynamic>();
      value.forEach((key, innerValue) {
        sorted[key] = _normalizeJson(innerValue);
      });
      return sorted;
    }

    if (value is List) {
      return value.map(_normalizeJson).toList();
    }

    return value;
  }
}
