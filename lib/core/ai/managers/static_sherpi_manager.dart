import 'package:sherpa_app/core/ai/managers/sherpi_message_manager.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/features/sherpi/domain/models/sherpi_response.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';

/// 🧠 정적 셰르피 매니저 (정적 메시지 전용 버전)
///
/// AI 시스템이 비활성화되고 정적 메시지만 사용하는 간소화된 버전입니다.
/// StaticDialogueSource를 통해 sherpi_dialogues.dart의 풍부한 메시지를 사용합니다.
class StaticSherpiManager implements SherpiMessageManager {
  // 개인화 설정
  PersonalizationSettings _personalizationSettings = const PersonalizationSettings();

  // StaticDialogueSource 인스턴스 - 풍부한 메시지를 제공
  final StaticDialogueSource _dialogueSource = StaticDialogueSource();

  /// 생성자
  StaticSherpiManager();

  /// 개인화 설정 업데이트
  @override
  void setPersonalizationSettings(PersonalizationSettings settings) {
    _personalizationSettings = settings;
  }

  /// 🎮 메인 메시지 가져오기 함수 (정적 메시지만 반환)
  ///
  /// StaticDialogueSource를 통해 sherpi_dialogues.dart의 풍부한 메시지를 반환합니다.
  @override
  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // gameContext가 null인 경우 빈 맵으로 초기화
    final safeGameContext = Map<String, dynamic>.from(gameContext ?? {});

    // 개인화 설정을 gameContext에 추가
    safeGameContext['userPreferredName'] = _personalizationSettings.userPreferredName;
    safeGameContext['userName'] = _personalizationSettings.userPreferredName;
    safeGameContext['personalityType'] = _personalizationSettings.personalityType.displayName;

    // StaticDialogueSource를 사용하여 풍부한 메시지 가져오기
    String message = await _dialogueSource.getDialogue(
      context,
      userContext,
      safeGameContext,
    );

    // 이모지 사용 설정에 따른 조정
    if (!_personalizationSettings.useEmojisInMessages) {
      message = _removeEmojis(message);
    }

    return SherpiResponse(
      message: message,
      source: MessageSource.static,
      responseTime: DateTime.now(),
      generationDuration: Duration.zero,
    );
  }

  @override
  PersonalizationSettings get personalizationSettings => _personalizationSettings;

  @override
  bool get supportsRealtimeAI => false;

  /// 시스템 상태 확인 (간소화된 버전)
  @override
  Future<Map<String, dynamic>> getSystemStatus() async {
    return {
      'mode': 'static_only',
      'ai_enabled': false,
      'personalization': _personalizationSettings.personalityType.displayName,
      'last_update': DateTime.now().toIso8601String(),
      'supports_realtime': false,
    };
  }

  @override
  void enableAIForNextMessage() {
    // No-op for static manager
  }

  @override
  Future<SherpiResponse> getMessageWithAI(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    // Static manager always returns static messages
    return getMessage(context, userContext, gameContext);
  }

  /// 이모지 제거 유틸리티 함수
  String _removeEmojis(String text) {
    return text.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]', unicode: true), '').trim();
  }
}