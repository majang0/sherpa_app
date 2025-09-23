import 'package:flutter_test/flutter_test.dart';
import 'package:sherpa_app/core/ai/managers/unified_sherpi_manager.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/features/sherpi/domain/models/sherpi_response.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UnifiedSherpiManager', () {
    late UnifiedSherpiManager manager;

    setUp(() {
      manager = UnifiedSherpiManager();
    });

    group('Personalization', () {
      test('applies user preferred name in messages', () async {
        manager.setPersonalizationSettings(
          const PersonalizationSettings(
            userPreferredName: '테스터',
            nickname: '셰르피',
            personalityType: SherpiPersonalityType.energetic,
          ),
        );

        final response = await manager.getMessage(
          SherpiContext.dailyGreeting,
          null,
          {'userPreferredName': '테스터'},
        );

        expect(response.message.contains('테스터'), isTrue);
        expect(response.source, MessageSource.static);
      });

      test('removes emojis when disabled', () async {
        manager.setPersonalizationSettings(
          const PersonalizationSettings(
            userPreferredName: '사용자',
            useEmojisInMessages: false,
          ),
        );

        final response = await manager.getMessage(
          SherpiContext.questComplete,
          null,
          {'userPreferredName': '사용자'},
        );

        // Check for common emoji ranges
        final emojiRegex = RegExp(
          r'[\u{1F300}-\u{1FAFF}]|[\u{2600}-\u{27FF}]',
          unicode: true,
        );
        expect(emojiRegex.hasMatch(response.message), isFalse);
      });
    });

    group('Message Generation', () {
      test('generates context-appropriate messages', () async {
        final contexts = [
          SherpiContext.dailyGreeting,
          SherpiContext.questComplete,
          SherpiContext.levelUp,
          SherpiContext.encouragement,
        ];

        for (final context in contexts) {
          final response = await manager.getMessage(context, null, null);

          expect(response.message.isNotEmpty, isTrue);
          expect(response.source, MessageSource.static);
          expect(response.responseTime, isNotNull);
        }
      });

      test('includes game context in messages', () async {
        final response = await manager.getMessage(
          SherpiContext.meetingCreated,
          {
            'meetingTitle': '아침 요가 클래스',
            'category': 'wellness',
          },
          {
            'userLevel': 10,
            'userName': '요가인',
          },
        );

        expect(response.message.contains('아침 요가 클래스'), isTrue);
      });
    });

    group('System Status', () {
      test('reports correct system configuration', () async {
        final status = await manager.getSystemStatus();

        expect(status['mode'], 'static_only');
        expect(status['ai_enabled'], false);
        expect(status['personalization'], isNotNull);
        expect(status['last_update'], isNotNull);
        // supports_realtime not part of status response
      });

      test('supportsRealtimeAI returns false for static mode', () {
        expect(manager.supportsRealtimeAI, false);
      });
    });

    group('AI Methods', () {
      test('enableAIForNextMessage is no-op in static mode', () {
        // Should not throw
        expect(() => manager.enableAIForNextMessage(), returnsNormally);
      });

      test('getMessageWithAI returns static message', () async {
        final response = await manager.getMessageWithAI(
          SherpiContext.general,
          null,
          null,
        );

        expect(response.source, MessageSource.static);
        expect(response.message.isNotEmpty, isTrue);
      });
    });
  });
}