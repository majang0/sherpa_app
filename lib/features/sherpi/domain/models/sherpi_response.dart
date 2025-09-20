/// Source that produced a Sherpi message.
enum MessageSource {
  static,
  aiCached,
  aiRealtime,
}

/// Normalized response object shared by all Sherpi manager implementations.
class SherpiResponse {
  final String message;
  final MessageSource source;
  final DateTime responseTime;
  final Duration? generationDuration;
  final Map<String, dynamic> metadata;

  const SherpiResponse({
    required this.message,
    required this.source,
    required this.responseTime,
    this.generationDuration,
    this.metadata = const {},
  });

  bool get isFastResponse =>
      source == MessageSource.static ||
      generationDuration == null ||
      generationDuration! <= const Duration(milliseconds: 150);

  bool get isCacheHit => source == MessageSource.aiCached;
}
