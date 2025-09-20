import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/ai/cache/ai_message_cache.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AiMessageCache', () {
    test('returns cached message for same user and context', () async {
      final cache = AiMessageCache();

      await cache.storeMessage(
        userId: 'user-a',
        context: SherpiContext.dailyGreeting,
        userContext: {
          'userId': 'user-a',
          '레벨': 7,
          '연속 접속일': 4,
        },
        message: '안녕하세요!',
      );

      final result = await cache.getCachedMessage(
        userId: 'user-a',
        context: SherpiContext.dailyGreeting,
        userContext: {
          'userId': 'user-a',
          '레벨': 7,
          '연속 접속일': 4,
        },
      );

      expect(result, '안녕하세요!');
    });

    test('isolates cache entries by user id', () async {
      final cache = AiMessageCache();

      await cache.storeMessage(
        userId: 'user-a',
        context: SherpiContext.general,
        userContext: {'userId': 'user-a'},
        message: '사용자 A 메시지',
      );

      final otherUserMessage = await cache.getCachedMessage(
        userId: 'user-b',
        context: SherpiContext.general,
        userContext: {'userId': 'user-b'},
      );

      expect(otherUserMessage, isNull);
    });

    test('respects context specific TTL', () async {
      final cache = AiMessageCache();

      await cache.storeMessage(
        userId: 'user-a',
        context: SherpiContext.exerciseComplete,
        userContext: {'userId': 'user-a'},
        message: '운동 축하 메시지',
      );

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('ai_message_cache_v2');
      expect(raw, isNotNull);

      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final entryKey = decoded.keys.firstWhere((key) => key != '_meta');
        final entry = decoded[entryKey] as Map<String, dynamic>;
        entry['generatedAt'] = DateTime.now()
            .subtract(const Duration(hours: 12, minutes: 1))
            .toIso8601String();
        decoded[entryKey] = entry;
        await prefs.setString('ai_message_cache_v2', jsonEncode(decoded));
      }

      final expiredMessage = await cache.getCachedMessage(
        userId: 'user-a',
        context: SherpiContext.exerciseComplete,
        userContext: {'userId': 'user-a'},
      );

      expect(expiredMessage, isNull);
    });
  });
}
