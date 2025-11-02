import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';
import 'package:sherpa_app/features/sherpi/emotion/providers/emotion_analysis_provider.dart';
import 'package:sherpa_app/features/sherpi/relationship/providers/relationship_provider.dart';
import 'package:sherpa_app/shared/providers/level_3_ai/global_sherpi_provider.dart';

class SherpiInsights {
  final SherpiPersonalityType personalityType;
  final String sherpiNickname;
  final String userPreferredName;
  final int intimacyLevel;
  final double emotionalSyncScore;
  final SherpiEmotion? recentSherpiEmotion;
  final SherpiContext? recentSherpiContext;
  final String lastSherpiMessage;

  const SherpiInsights({
    required this.personalityType,
    required this.sherpiNickname,
    required this.userPreferredName,
    required this.intimacyLevel,
    required this.emotionalSyncScore,
    required this.recentSherpiEmotion,
    required this.recentSherpiContext,
    required this.lastSherpiMessage,
  });
}

class SherpiInsightRepository {
  SherpiInsightRepository(this._ref);

  final Ref _ref;

  SherpiInsights collectInsights() {
    final relationship = _ref.read(relationshipProvider);
    final emotionState = _ref.read(emotionAnalysisProvider);
    final sherpiState = _ref.read(sherpiProvider);

    final personalization = relationship.personalizationSettings;
    final recentEmotion = emotionState.recentSherpiResponses.isNotEmpty
        ? emotionState.recentSherpiResponses.first
        : null;

    return SherpiInsights(
      personalityType: personalization.personalityType,
      sherpiNickname: personalization.nickname,
      userPreferredName: personalization.userPreferredName,
      intimacyLevel: relationship.intimacyLevel,
      emotionalSyncScore: emotionState.emotionalSyncScore,
      recentSherpiEmotion: recentEmotion,
      recentSherpiContext: sherpiState.currentContext,
      lastSherpiMessage: sherpiState.dialogue,
    );
  }
}

final sherpiInsightRepositoryProvider =
    Provider<SherpiInsightRepository>((ref) {
  return SherpiInsightRepository(ref);
});
