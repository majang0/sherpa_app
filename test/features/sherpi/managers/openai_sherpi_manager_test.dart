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
  });
}
