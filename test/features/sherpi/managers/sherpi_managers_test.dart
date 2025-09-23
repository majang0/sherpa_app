import 'package:flutter_test/flutter_test.dart';
import 'package:sherpa_app/core/ai/managers/unified_sherpi_manager.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/features/sherpi/domain/models/sherpi_response.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UnifiedSherpiManager', () {
    test('personalized meetingCreated message reflects meeting data', () async {
      final manager = UnifiedSherpiManager();
      manager.setPersonalizationSettings(
        const PersonalizationSettings(
          userPreferredName: '연우',
          nickname: '셰르피',
        ),
      );

      final response = await manager.getMessage(
        SherpiContext.meetingCreated,
        {
          'meetingTitle': '새벽 러닝 챌린지',
          'category': 'exercise',
        },
        {
          'userPreferredName': '연우',
        },
      );

      expect(response.source, MessageSource.static);
      expect(response.message.contains('새벽 러닝 챌린지'), isTrue);
      expect(response.message.contains('연우'), isTrue);
    });

    test('disables emojis when useEmojisInMessages is false', () async {
      final manager = UnifiedSherpiManager();
      manager.setPersonalizationSettings(
        const PersonalizationSettings(
          userPreferredName: '연우',
          useEmojisInMessages: false,
        ),
      );

      final response = await manager.getMessage(
        SherpiContext.dailyGreeting,
        null,
        {'userPreferredName': '연우'},
      );

      final emojiRegex = RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true);
      expect(emojiRegex.hasMatch(response.message), isFalse);
    });

    test('system status reports static-only configuration', () async {
      final manager = UnifiedSherpiManager();
      final status = await manager.getSystemStatus();

      expect(status['mode'], 'static_only');
      expect(status['ai_enabled'], isFalse);
      expect(manager.supportsRealtimeAI, isFalse);
    });
  });
}
