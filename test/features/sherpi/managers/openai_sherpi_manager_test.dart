import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sherpa_app/core/ai/cache/ai_message_cache.dart';
import 'package:sherpa_app/core/ai/managers/openai_sherpi_manager.dart';
import 'package:sherpa_app/core/ai/managers/static_sherpi_manager.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/features/sherpi/domain/models/sherpi_response.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';
import 'package:sherpa_app/shared/providers/global_sherpi_provider.dart';

class _FakeDialogueSource implements SherpiDialogueSource {
  _FakeDialogueSource(this._response, {this.shouldThrow = false});

  final String _response;
  final bool shouldThrow;
  int callCount = 0;

  @override
  Future<String> getDialogue(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('AI request failed');
    }
    return _response;
  }
}

class _StubStaticManager extends StaticSherpiManager {
  _StubStaticManager(this._message);

  final String _message;

  @override
  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    return SherpiResponse(
      message: _message,
      source: MessageSource.static,
      responseTime: DateTime.now(),
      generationDuration: Duration.zero,
    );
  }
}

class _InMemoryAiMessageCache extends AiMessageCache {
  final Map<String, CachedMessage> _store = {};

  void preload({
    required String userId,
    required SherpiContext context,
    required Map<String, dynamic> userContext,
    required String message,
    String? meetingSetId,
  }) {
    final key = _key(
      userId: userId,
      context: context,
      userContext: userContext,
      meetingSetId: meetingSetId,
    );

    _store[key] = CachedMessage(
      message: message,
      generatedAt: DateTime.now(),
      userContext: Map.from(userContext),
      ttl: const Duration(hours: 12),
    );
  }

  @override
  Future<String?> getCachedMessage({
    required String userId,
    required SherpiContext context,
    required Map<String, dynamic> userContext,
    String? meetingSetId,
  }) async {
    final key = _key(
      userId: userId,
      context: context,
      userContext: userContext,
      meetingSetId: meetingSetId,
    );
    final cached = _store[key];
    if (cached == null) {
      return null;
    }
    if (cached.isExpired) {
      _store.remove(key);
      return null;
    }
    return cached.message;
  }

  @override
  Future<void> storeMessage({
    required String userId,
    required SherpiContext context,
    required Map<String, dynamic> userContext,
    required String message,
    String? meetingSetId,
  }) async {
    final key = _key(
      userId: userId,
      context: context,
      userContext: userContext,
      meetingSetId: meetingSetId,
    );
    _store[key] = CachedMessage(
      message: message,
      generatedAt: DateTime.now(),
      userContext: Map.from(userContext),
      ttl: const Duration(hours: 12),
    );
  }

  String _key({
    required String userId,
    required SherpiContext context,
    required Map<String, dynamic> userContext,
    String? meetingSetId,
  }) {
    final sortedEntries = userContext.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final normalizedContext = Map.fromEntries(sortedEntries);
    final buffer = StringBuffer()
      ..write('user:$userId')
      ..write(':ctx:${context.name}')
      ..write(':hash:${jsonEncode(normalizedContext)}');

    if (meetingSetId != null) {
      buffer.write(':meet:$meetingSetId');
    }

    return buffer.toString();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OpenAISherpiManager', () {
    test('uses cached message when cache hit', () async {
      final cache = _InMemoryAiMessageCache();
      final dialogueSource = _FakeDialogueSource('AI response ✨');
      final manager = OpenAISherpiManager(
        dialogueSource: dialogueSource,
        cache: cache,
      );

      final userContext = {'userId': 'user-test', '레벨': 7, '연속 접속일': 3};
      cache.preload(
        userId: 'user-test',
        context: SherpiContext.general,
        userContext: userContext,
        message: 'cache first',
      );

      final response = await manager.getMessage(
        SherpiContext.general,
        userContext,
        {'personalityType': '균형형'},
      );

      expect(response.message, 'cache first');
      expect(response.source, MessageSource.aiCached);
      expect(dialogueSource.callCount, 0);
    });

    test('falls back to static manager when AI throws', () async {
      final dialogueSource = _FakeDialogueSource('no-op', shouldThrow: true);
      final manager = OpenAISherpiManager(
        dialogueSource: dialogueSource,
        cache: _InMemoryAiMessageCache(),
      );

      manager.enableAIForNextMessage();
      final response = await manager.getMessage(
        SherpiContext.general,
        {'userId': 'user-test', '사용자': '연우'},
        {'personalityType': '균형형'},
      );

      expect(response.source, MessageSource.static);
      expect(response.message.isNotEmpty, isTrue);
      expect(dialogueSource.callCount, 1);
    });

    test('removes emojis when personalization disables them', () async {
      final dialogueSource = _FakeDialogueSource('안녕! 😊🌟 함께해요.');
      final manager = OpenAISherpiManager(
        dialogueSource: dialogueSource,
        cache: _InMemoryAiMessageCache(),
      );

      manager.setPersonalizationSettings(
        const PersonalizationSettings(
          userPreferredName: '연우',
          useEmojisInMessages: false,
        ),
      );

      manager.enableAIForNextMessage();
      final response = await manager.getMessage(
        SherpiContext.general,
        {},
        {},
      );

      expect(response.source, MessageSource.aiRealtime);
      expect(response.message.contains('😊'), isFalse);
      expect(response.message.contains('🌟'), isFalse);
      expect(dialogueSource.callCount, 1);
    });

    test('enableAIForNextMessage activates AI for one message only', () async {
      final dialogueSource = _FakeDialogueSource('AI message');
      final manager = OpenAISherpiManager(
        dialogueSource: dialogueSource,
        cache: _InMemoryAiMessageCache(),
      );

      // First call without AI enabled - should use static
      final firstResponse = await manager.getMessage(
        SherpiContext.general,
        {'userId': 'test-user'},
        {},
      );
      expect(firstResponse.source, MessageSource.static);
      expect(dialogueSource.callCount, 0);

      // Enable AI for next message
      manager.enableAIForNextMessage();

      // Second call - should use AI
      final secondResponse = await manager.getMessage(
        SherpiContext.general,
        {'userId': 'test-user'},
        {},
      );
      expect(secondResponse.source, MessageSource.aiRealtime);
      expect(dialogueSource.callCount, 1);

      // Third call - should be back to static
      final thirdResponse = await manager.getMessage(
        SherpiContext.general,
        {'userId': 'test-user'},
        {},
      );
      expect(thirdResponse.source, MessageSource.static);
      expect(dialogueSource.callCount, 1); // No additional AI calls
    });

    test('stores generated AI messages in cache', () async {
      final cache = _InMemoryAiMessageCache();
      final dialogueSource = _FakeDialogueSource('Generated AI message');
      final manager = OpenAISherpiManager(
        dialogueSource: dialogueSource,
        cache: cache,
      );

      final userContext = {'userId': 'cache-test', '레벨': 10};

      // Enable AI and generate message
      manager.enableAIForNextMessage();
      final response = await manager.getMessage(
        SherpiContext.levelUp,
        userContext,
        {},
      );

      expect(response.message, 'Generated AI message');
      expect(response.source, MessageSource.aiRealtime);

      // Check if message was stored in cache
      final cachedMessage = await cache.getCachedMessage(
        userId: 'cache-test',
        context: SherpiContext.levelUp,
        userContext: userContext,
      );

      expect(cachedMessage, 'Generated AI message');
    });

    test('handles different SherpiContext types correctly', () async {
      final dialogueSource = _FakeDialogueSource('Context-specific response');
      final manager = OpenAISherpiManager(
        dialogueSource: dialogueSource,
        cache: _InMemoryAiMessageCache(),
      );

      final contexts = [
        SherpiContext.general,
        SherpiContext.levelUp,
        SherpiContext.exerciseComplete,
        SherpiContext.questComplete,
        SherpiContext.dailyGreeting,
        SherpiContext.achievement,
      ];

      for (final context in contexts) {
        manager.enableAIForNextMessage();
        final response = await manager.getMessage(
          context,
          {'userId': 'context-test'},
          {},
        );

        expect(response.source, MessageSource.aiRealtime);
        expect(response.message, 'Context-specific response');
      }

      expect(dialogueSource.callCount, contexts.length);
    });

    test('tracks response time correctly', () async {
      final dialogueSource = _FakeDialogueSource('Timed response');
      final manager = OpenAISherpiManager(
        dialogueSource: dialogueSource,
        cache: _InMemoryAiMessageCache(),
      );

      manager.enableAIForNextMessage();
      final startTime = DateTime.now();
      final response = await manager.getMessage(
        SherpiContext.general,
        {'userId': 'time-test'},
        {},
      );

      expect(response.responseTime.isAfter(startTime), isTrue);
      expect(response.responseTime.isBefore(DateTime.now()), isTrue);
      expect(response.generationDuration?.inMilliseconds ?? 0, greaterThanOrEqualTo(0));
    });

    test('applies personalization settings correctly', () async {
      final dialogueSource = _FakeDialogueSource('Hello {userName}! 🎉 Your level: {userLevel}');
      final manager = OpenAISherpiManager(
        dialogueSource: dialogueSource,
        cache: _InMemoryAiMessageCache(),
      );

      // Set personalization with custom name
      manager.setPersonalizationSettings(
        const PersonalizationSettings(
          userPreferredName: '테스터',
          useEmojisInMessages: true,
        ),
      );

      manager.enableAIForNextMessage();
      final response = await manager.getMessage(
        SherpiContext.general,
        {'userId': 'personal-test', '레벨': 15},
        {},
      );

      expect(response.message, contains('테스터'));
      expect(response.message, contains('🎉')); // Emoji should remain
    });

    test('returns static message when AI not initialized', () async {
      // Create manager without dialogue source
      final manager = OpenAISherpiManager(
        cache: _InMemoryAiMessageCache(),
      );

      final response = await manager.getMessage(
        SherpiContext.general,
        {'userId': 'no-ai-test'},
        {},
      );

      expect(response.source, MessageSource.static);
      expect(response.message.isNotEmpty, isTrue);
    });

    test('disposes resources correctly', () async {
      final dialogueSource = _FakeDialogueSource('Disposal test');
      final manager = OpenAISherpiManager(
        dialogueSource: dialogueSource,
        cache: _InMemoryAiMessageCache(),
      );

      // Use the manager
      manager.enableAIForNextMessage();
      await manager.getMessage(
        SherpiContext.general,
        {'userId': 'dispose-test'},
        {},
      );

      // Dispose should complete without errors
      manager.dispose();
      // After disposal, manager should still work but return static messages
      final postDisposeResponse = await manager.getMessage(
        SherpiContext.general,
        {'userId': 'dispose-test-2'},
        {},
      );

      expect(postDisposeResponse.source, MessageSource.static);
    });
  });
}
