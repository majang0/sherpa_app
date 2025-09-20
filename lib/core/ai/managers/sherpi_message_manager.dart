import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';
import 'package:sherpa_app/features/sherpi/domain/models/sherpi_response.dart';

/// Base contract for Sherpi message managers so that different
/// implementations (static-only, OpenAI-backed, etc.) can be swapped
/// via dependency injection without touching presentation logic.
abstract class SherpiMessageManager {
  PersonalizationSettings get personalizationSettings;

  void setPersonalizationSettings(PersonalizationSettings settings);

  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  );

  /// Optional API for forcing a real-time AI generation.
  /// Static implementations simply defer to [getMessage].
  Future<SherpiResponse> getMessageWithAI(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    return getMessage(context, userContext, gameContext);
  }

  /// Enables the next call to go through a real-time AI path when supported.
  void enableAIForNextMessage() {}

  Future<Map<String, dynamic>> getSystemStatus();

  bool get supportsRealtimeAI;
}
