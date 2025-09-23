import 'package:sherpa_app/core/ai/managers/sherpi_message_manager.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/features/sherpi/domain/models/sherpi_response.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';
import 'package:sherpa_app/shared/utils/sherpi_text_utils.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';

/// 🎯 통합 셰르피 매니저
///
/// OpenAISherpiManager와 StaticSherpiManager를 통합한 단일 매니저.
/// 현재는 정적 메시지만 사용하지만, 향후 AI 기능 재활성화를 위한 구조를 유지합니다.
class UnifiedSherpiManager implements SherpiMessageManager {
  // 개인화 설정
  PersonalizationSettings _personalizationSettings =
      const PersonalizationSettings();

  // 정적 메시지 소스
  final StaticDialogueSource _staticSource = StaticDialogueSource();

  // AI 활성화 플래그 (향후 사용)
  final bool _aiEnabled = false;

  // 수동 AI 활성화 플래그 (한 번만 사용)
  bool _useAIForNextMessage = false;

  /// 생성자
  UnifiedSherpiManager();

  @override
  PersonalizationSettings get personalizationSettings =>
      _personalizationSettings;

  @override
  bool get supportsRealtimeAI => _aiEnabled;

  @override
  void setPersonalizationSettings(PersonalizationSettings settings) {
    _personalizationSettings = settings;
    LoggerService.instance
        .d('📝 개인화 설정 업데이트: ${settings.personalityType.displayName}');
  }

  /// 🎮 메인 메시지 가져오기
  ///
  /// AI 활성화 여부에 따라 적절한 메시지를 반환합니다.
  /// 현재는 항상 정적 메시지를 반환하지만, 향후 AI 재활성화 가능합니다.
  @override
  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 개인화 정보를 gameContext에 추가
    final enrichedGameContext = _enrichGameContext(gameContext);

    // AI 사용 여부 결정 (향후 활성화 가능)
    if (_shouldUseAI()) {
      // TODO: 향후 AI 재활성화 시 여기에 AI 로직 추가
      // return await _getAIMessage(context, userContext, enrichedGameContext);
    }

    // 정적 메시지 반환 (현재 100% 사용)
    return await _getStaticMessage(context, userContext, enrichedGameContext);
  }

  /// AI 사용 여부 결정
  bool _shouldUseAI() {
    // AI가 활성화되어 있고 수동 요청이 있을 때
    if (_aiEnabled && _useAIForNextMessage) {
      _useAIForNextMessage = false; // 사용 후 리셋
      return true;
    }

    // 현재는 항상 false (정적 메시지만 사용)
    return false;
  }

  /// 정적 메시지 가져오기
  Future<SherpiResponse> _getStaticMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    try {
      // StaticDialogueSource에서 메시지 가져오기
      String message = await _staticSource.getDialogue(
        context,
        userContext,
        gameContext,
      );

      // 텍스트 포맷팅 (이모지, 사용자 이름)
      message = SherpiTextUtils.formatMessage(
        text: message,
        userName: _personalizationSettings.userPreferredName,
        useEmojis: _personalizationSettings.useEmojisInMessages,
      );

      return SherpiResponse(
        message: message,
        source: MessageSource.static,
        responseTime: DateTime.now(),
        generationDuration: Duration.zero,
        metadata: {
          'personalityType':
              _personalizationSettings.personalityType.displayName,
          'context': context.name,
        },
      );
    } catch (e) {
      LoggerService.instance.e('❌ 정적 메시지 가져오기 실패', error: e);
      return _getFallbackMessage(context);
    }
  }

  /// Fallback 메시지 반환
  SherpiResponse _getFallbackMessage(SherpiContext context) {
    final fallbackMessages = {
      SherpiContext.welcome: '안녕하세요! 😊',
      SherpiContext.levelUp: '축하해요! 🎉',
      SherpiContext.encouragement: '힘내세요! 💪',
      SherpiContext.general: '좋은 하루 되세요! ✨',
    };

    String message = fallbackMessages[context] ?? '안녕하세요!';

    // 텍스트 포맷팅
    message = SherpiTextUtils.formatMessage(
      text: message,
      userName: _personalizationSettings.userPreferredName,
      useEmojis: _personalizationSettings.useEmojisInMessages,
    );

    return SherpiResponse(
      message: message,
      source: MessageSource.static,
      responseTime: DateTime.now(),
      generationDuration: Duration.zero,
      metadata: {
        'isFallback': true,
      },
    );
  }

  /// GameContext에 개인화 정보 추가
  Map<String, dynamic> _enrichGameContext(Map<String, dynamic>? gameContext) {
    final context = Map<String, dynamic>.from(gameContext ?? {});

    // 개인화 정보 추가
    context['userPreferredName'] = _personalizationSettings.userPreferredName;
    context['userName'] = _personalizationSettings.userPreferredName;
    context['personalityType'] =
        _personalizationSettings.personalityType.displayName;
    context['nickname'] = _personalizationSettings.nickname;

    return context;
  }

  /// 다음 메시지에 AI 사용 활성화 (향후 사용)
  @override
  void enableAIForNextMessage() {
    if (_aiEnabled) {
      _useAIForNextMessage = true;
      LoggerService.instance.i('🤖 다음 메시지에 AI 사용 활성화');
    } else {
      LoggerService.instance.w('⚠️ AI가 비활성화되어 있어 AI를 사용할 수 없습니다');
    }
  }

  /// AI 강제 사용 (향후 사용)
  @override
  Future<SherpiResponse> getMessageWithAI(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    if (_aiEnabled) {
      _useAIForNextMessage = true;
      return await getMessage(context, userContext, gameContext);
    }

    // AI 비활성화 시 정적 메시지 반환
    LoggerService.instance.w('⚠️ AI 비활성화 - 정적 메시지 반환');
    return await getMessage(context, userContext, gameContext);
  }

  /// 시스템 상태 확인
  @override
  Future<Map<String, dynamic>> getSystemStatus() async {
    return {
      'manager_type': 'unified',
      'mode': _aiEnabled ? 'hybrid' : 'static_only',
      'ai_enabled': _aiEnabled,
      'ai_ready': false, // 향후 AI API 키 확인 로직 추가
      'personalization': {
        'personality': _personalizationSettings.personalityType.displayName,
        'user_name': _personalizationSettings.userPreferredName,
        'use_emojis': _personalizationSettings.useEmojisInMessages,
      },
      'last_update': DateTime.now().toIso8601String(),
      'version': '2.0.0', // 통합 버전
    };
  }

  /// 리소스 정리
  void dispose() {
    LoggerService.instance.d('🧹 Unified Sherpi Manager 정리 완료');
  }
}
