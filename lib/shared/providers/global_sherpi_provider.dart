import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/constants/sherpi_dialogues.dart';
import '../../core/constants/sherpi_emotions.dart';
import 'package:sherpa_app/core/ai/managers/sherpi_message_manager.dart';
import 'package:sherpa_app/core/ai/managers/static_sherpi_manager.dart';
import 'package:sherpa_app/core/ai/services/real_data_connector.dart';
import '../../features/sherpi/relationship/providers/relationship_provider.dart';
import '../../features/sherpi/emotion/providers/emotion_analysis_provider.dart';
import '../../features/sherpi/domain/models/sherpi_response.dart';
import '../models/sherpi_message_history.dart';
import '../models/sherpi_relationship_model.dart';
import 'global_user_provider.dart'; // Phase 1: 실제 사용자 이름을 가져오기 위해 추가

enum SherpiDisplayMode {
  floating, // 우하단 플로팅 (기본)
  notification, // 상단 알림바
  inline, // 인라인 (특정 위젯 내부)
  hidden, // 숨김
}

@immutable
class SherpiState {
  final SherpiEmotion emotion;
  final String dialogue;
  final bool isVisible;
  final SherpiDisplayMode displayMode;
  final DateTime? lastShownTime;
  final SherpiContext? currentContext;
  final Map<String, dynamic>? metadata;

  const SherpiState({
    this.emotion = SherpiEmotion.defaults, // 기본 감정으로 변경
    this.dialogue = '', // 빈 메시지로 시작
    this.isVisible = false, // 초기에는 숨김 상태
    this.displayMode = SherpiDisplayMode.floating,
    this.lastShownTime,
    this.currentContext, // 기본값 없음
    this.metadata,
  });

  SherpiState copyWith({
    SherpiEmotion? emotion,
    String? dialogue,
    bool? isVisible,
    SherpiDisplayMode? displayMode,
    DateTime? lastShownTime,
    SherpiContext? currentContext,
    Map<String, dynamic>? metadata,
  }) {
    return SherpiState(
      emotion: emotion ?? this.emotion,
      dialogue: dialogue ?? this.dialogue,
      isVisible: isVisible ?? this.isVisible,
      displayMode: displayMode ?? this.displayMode,
      lastShownTime: lastShownTime ?? this.lastShownTime,
      currentContext: currentContext ?? this.currentContext,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters for compatibility with old SherpaCharacter
  String get emoji {
    switch (emotion) {
      case SherpiEmotion.defaults:
        return '🐻'; // 기본 셰르피
      case SherpiEmotion.happy:
        return '😊'; // 기쁜 셰르피
      case SherpiEmotion.sad:
        return '😔'; // 슬픈 셰르피
      case SherpiEmotion.surprised:
        return '😲'; // 놀란 셰르피
      case SherpiEmotion.thinking:
        return '🤔'; // 생각하는 셰르피
      case SherpiEmotion.guiding:
        return '👨‍🏫'; // 안내하는 셰르피
      case SherpiEmotion.cheering:
        return '🎉'; // 응원하는 셰르피
      case SherpiEmotion.warning:
        return '⚠️'; // 경고하는 셰르피
      case SherpiEmotion.sleeping:
        return '😴'; // 잠자는 셰르피
      case SherpiEmotion.special:
        return '✨'; // 특별한 셰르피
      case SherpiEmotion.smile:
        return '😁'; // 미소 짓는 셰르피
      case SherpiEmotion.talking:
        return '💬'; // 대화하는 셰르피
      case SherpiEmotion.confidence:
        return '😎'; // 자신감 있는 셰르피
    }
  }

  String get message => dialogue;

  // 감정별 색상 반환 (호환성을 위해 static 메서드 추가)
  static Color getEmotionColor(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.defaults:
        return const Color(0xFF4299E1); // 파란색
      case SherpiEmotion.happy:
        return const Color(0xFF10B981); // 초록색
      case SherpiEmotion.sad:
        return const Color(0xFF6B7280); // 회색
      case SherpiEmotion.surprised:
        return const Color(0xFFED8936); // 주황색
      case SherpiEmotion.thinking:
        return const Color(0xFF8B5CF6); // 보라색
      case SherpiEmotion.guiding:
        return const Color(0xFF4299E1); // 파란색
      case SherpiEmotion.cheering:
        return const Color(0xFFED8936); // 주황색
      case SherpiEmotion.warning:
        return const Color(0xFFF59E0B); // 노란색
      case SherpiEmotion.sleeping:
        return const Color(0xFF6B7280); // 회색
      case SherpiEmotion.special:
        return const Color(0xFF8B5CF6); // 보라색
      case SherpiEmotion.smile:
        return const Color(0xFF06B6D4); // 청록색
      case SherpiEmotion.talking:
        return const Color(0xFFEC4899); // 분홍색
      case SherpiEmotion.confidence:
        return const Color(0xFFDC2626); // 빨간색
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion.name,
      'dialogue': dialogue,
      'isVisible': isVisible,
      'lastShownTime': lastShownTime?.toIso8601String(),
      'currentContext': currentContext?.name,
      'metadata': metadata ?? {},
    };
  }

  factory SherpiState.fromJson(Map<String, dynamic> json) {
    return SherpiState(
      emotion: SherpiEmotion.values.firstWhere(
        (e) => e.name == json['emotion'],
        orElse: () => SherpiEmotion.defaults,
      ),
      dialogue: json['dialogue'] ?? '',
      isVisible: json['isVisible'] ?? false,
      lastShownTime: json['lastShownTime'] != null
          ? DateTime.parse(json['lastShownTime'])
          : null,
      currentContext: json['currentContext'] != null
          ? SherpiContext.values.firstWhere(
              (c) => c.name == json['currentContext'],
              orElse: () => SherpiContext.general,
            )
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

class SherpiNotifier extends StateNotifier<SherpiState> {
  final SherpiMessageManager _messageManager;
  late final RealDataConnector _dataConnector;
  final Ref _ref;
  Timer? _hideTimer;

  // 메시지 히스토리 저장 (최대 50개)
  final List<SherpiMessageHistory> _messageHistory = [];
  static const int _maxHistorySize = 50;

  // 중복 메시지 방지를 위한 최근 메시지 추적
  DateTime? _lastMessageTime;
  SherpiContext? _lastContext;
  String? _lastDialogue;

  // 🚨 전역 메시지 표시 락 - 동시 메시지 호출 방지
  bool _isShowingMessage = false;

  SherpiMessageManager get messageManager => _messageManager;

  SherpiNotifier(
    this._ref, {
    SherpiMessageManager? messageManager,
  })  : _messageManager = messageManager ?? StaticSherpiManager(),
        _dataConnector = RealDataConnector(_ref),
        super(const SherpiState()) {
    // 친밀도 레벨 초기화
    _updateIntimacyLevel();

    // 🎯 메시지 매니저에 데이터 초기화가 필요한 경우 여기에서 수행 가능
  }

  /// 개인화 설정을 메시지 매니저에 업데이트
  void _updateIntimacyLevel() {
    try {
      final relationship = _ref.read(relationshipProvider);
      // 🎯 Phase 1 개선: 실제 사용자 이름을 PersonalizationSettings에 반영
      final user = _ref.read(globalUserProvider);
      final userName = user.name.isNotEmpty ? user.name : '친구';

      // Phase 2: 개인화 설정도 함께 업데이트 (사용자 이름 포함)
      final updatedSettings = relationship.personalizationSettings.copyWith(
        userPreferredName: userName, // 실제 사용자 이름으로 업데이트
      );
      _messageManager.setPersonalizationSettings(updatedSettings);
    } catch (e) {
      // 관계 프로바이더가 아직 초기화되지 않은 경우
    }
  }

  /// 상호작용 기록 및 친밀도 업데이트
  void _recordInteraction(SherpiContext context,
      Map<String, dynamic>? userContext, Map<String, dynamic>? gameContext) {
    try {
      final notifier = _ref.read(relationshipProvider.notifier);

      // 상호작용 타입 결정
      String interactionType;
      switch (context) {
        case SherpiContext.exerciseComplete:
          interactionType = 'exercise_complete';
          break;
        case SherpiContext.readingComplete:
          interactionType = 'study_complete';
          break;
        case SherpiContext.questComplete:
          interactionType = 'quest_complete';
          break;
        case SherpiContext.levelUp:
          interactionType = 'level_up';
          break;
        case SherpiContext.climbingSuccess:
          interactionType = 'climbing_success';
          break;
        case SherpiContext.dailyGreeting:
          interactionType = 'daily_greeting';
          break;
        default:
          interactionType = 'general';
      }

      // 상호작용 기록
      notifier.recordInteraction(
        interactionType: interactionType,
        context: {
          'sherpiContext': context.name,
          'userContext': userContext,
          'gameContext': gameContext,
        },
      );

      // 친밀도 레벨 업데이트
      _updateIntimacyLevel();
    } catch (e) {
      // 에러 무시 - 중요하지 않은 작업
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  // ✅ 초기화 메서드 추가
  /*
void initializeSherpi() {
  if (!state.isVisible) {
    state = state.copyWith(
      emotion: SherpiEmotion.cheering,
      dialogue: '셰르파에 오신 것을 환영해요! 🎉',
      isVisible: true,
      currentContext: SherpiContext.welcome,
      lastShownTime: DateTime.now(),
    );
  }
}
*/

  Future<void> showMessage({
    required SherpiContext context,
    SherpiEmotion? emotion,
    Duration duration = const Duration(seconds: 4),
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
    bool forceShow = false,
  }) async {
    try {
      // 🚨 전역 락: 이미 메시지를 표시 중이면 무시 (동시 호출 방지)
      if (_isShowingMessage && !forceShow) {
        return;
      }

      _isShowingMessage = true; // 락 설정

      // 🚨 중복 메시지 방지: 강제 표시가 아닌 경우에만 중복 검사
      if (!forceShow && _isDuplicateMessage(context, null)) {
        _isShowingMessage = false; // 락 해제
        return;
      }

      _hideTimer?.cancel();

      // 🎭 감정 분석 및 추천 감정 가져오기
      SherpiEmotion selectedEmotion;
      if (emotion != null) {
        selectedEmotion = emotion;
      } else {
        // 활동 완료 시 감정 분석 수행
        if (_isActivityCompletionContext(context) && userContext != null) {
          selectedEmotion = await _analyzeAndGetRecommendedEmotion(
              context, userContext, gameContext);
        } else {
          selectedEmotion = SherpiEmotionMapper.getEmotionForContext(context);
        }
      }

      // 🎯 Phase 1: 메시지 표시 전 최신 사용자 정보로 설정 업데이트
      _updateIntimacyLevel();

      // 🔌 실제 사용자 데이터 연결
      final realUserContext = _dataConnector.buildRealUserContext(
        context: context,
        additionalData: userContext,
      );
      final realGameContext = _dataConnector.buildRealGameContext();

      final sherpiResponse = await _messageManager.getMessage(
        context,
        realUserContext,
        realGameContext,
      );

      final metadata = {
        'context': context.name,
        'timestamp': DateTime.now().toIso8601String(),
        'user': userContext ?? {},
        'game': gameContext ?? {},
        'recommendedEmotion': selectedEmotion.name,
      };

      // 응답 소스 정보를 메타데이터에 추가
      final enhancedMetadata = {
        ...sherpiResponse.metadata,
        ...metadata,
        'response_source': sherpiResponse.source.name,
        'response_time': sherpiResponse.responseTime.toIso8601String(),
        'is_fast_response': sherpiResponse.isFastResponse,
        if (sherpiResponse.generationDuration != null)
          'generation_duration_ms':
              sherpiResponse.generationDuration!.inMilliseconds,
        'emotion_analyzed': _isActivityCompletionContext(context),
      };

      // 이전 메시지와 다르거나 강제 표시일 때만 알림 표시
      final isNewMessage = state.dialogue != sherpiResponse.message;
      final shouldShowNotification = forceShow || isNewMessage;

      state = state.copyWith(
        emotion: selectedEmotion,
        dialogue: sherpiResponse.message,
        isVisible: shouldShowNotification, // 새로운 메시지이거나 강제 표시일 때만 알림
        lastShownTime: DateTime.now(),
        currentContext: context,
        metadata: enhancedMetadata,
      );

      // 디버그 로그
      if (shouldShowNotification) {
      } else {}

      _logInteraction(
          context, selectedEmotion, sherpiResponse.message, enhancedMetadata);

      // 메시지 히스토리에 추가
      _addToHistory(
        emotion: selectedEmotion,
        message: sherpiResponse.message,
        context: context,
        metadata: enhancedMetadata,
      );

      // 🤝 상호작용 기록 및 친밀도 업데이트
      _recordInteraction(context, realUserContext, realGameContext);

      // 💖 Sherpi 응답 기록 (감정 동기화를 위해)
      _recordSherpiResponse(selectedEmotion);

      // 💕 감정 동기화 점수를 관계 시스템에 업데이트
      if (_isActivityCompletionContext(context)) {
        _updateRelationshipEmotionalSync();
      }

      if (!forceShow) {
        _hideTimer = Timer(duration, () {
          if (state.currentContext == context && state.isVisible) {
            hideMessage();
          }
        });
      }

      // 🚨 락 해제: 메시지 표시 완료 후
      _isShowingMessage = false;
    } catch (e) {
      _isShowingMessage = false; // 🚨 예외 발생 시에도 락 해제
      _showFallbackMessage(context, emotion);
    }
  }

  Future<void> showInstantMessage({
    required SherpiContext context,
    required String customDialogue,
    SherpiEmotion? emotion,
    Duration duration = const Duration(seconds: 4),
    bool forceShow = false, // 🚨 중복 방지 제어 매개변수 추가
    Map<String, dynamic>? userContext, // 🎯 Phase 2: AI 사용을 위한 컨텍스트 추가
  }) async {
    // 🚨 전역 락: 이미 메시지를 표시 중이면 무시 (동시 호출 방지)
    if (_isShowingMessage && !forceShow) {
      return;
    }

    _isShowingMessage = true; // 락 설정

    // 🚨 강화된 중복 메시지 방지: forceShow가 false면 중복 검사 적용
    if (!forceShow && _isDuplicateMessage(context, customDialogue)) {
      _isShowingMessage = false; // 락 해제
      return;
    }

    _hideTimer?.cancel();
    final selectedEmotion =
        emotion ?? SherpiEmotionMapper.getEmotionForContext(context);

    // 💬 customDialogue를 그대로 사용 (정적 메시지 모드)
    // AI나 조건부 메시지 선택 없이 전달받은 customDialogue를 그대로 사용
    String finalMessage = customDialogue;
    String responseSource = 'instant';

    // 메시지 표시 (중복 방지 통과한 경우만)
    final isNewMessage = state.dialogue != finalMessage;

    // 메타데이터 생성
    final metadata = {
      'context': context.name,
      'timestamp': DateTime.now().toIso8601String(),
      'response_source': responseSource,
      'is_fast_response': true,
      'original_message': customDialogue, // 원본 메시지 보존
    };

    state = state.copyWith(
      emotion: selectedEmotion,
      dialogue: finalMessage,
      isVisible: true, // 항상 메시지 표시
      lastShownTime: DateTime.now(),
      currentContext: context,
      metadata: metadata,
    );

    // 디버그 로그
    if (isNewMessage) {
      // 🔔 메시지 히스토리에 추가 (새 메시지일 때만)
      _addToHistory(
        emotion: selectedEmotion,
        message: finalMessage,
        context: context,
        metadata: metadata,
      );
    } else {}

    _hideTimer = Timer(duration, hideMessage);

    // 🚨 락 해제: 즉시 메시지 표시 완료 후
    _isShowingMessage = false;
  }

  void hideMessage() {
    _hideTimer?.cancel();
    state = state.copyWith(isVisible: false);
  }

  /// 📖 메시지를 읽음으로 표시 (알림 배지 숨김)
  void markMessageAsRead() {
    _hideTimer?.cancel();
    state = state.copyWith(isVisible: false);

    // 현재 메시지를 히스토리에 읽음 상태로 기록
    if (state.dialogue.isNotEmpty) {
      _addToHistory(
        emotion: state.emotion,
        message: state.dialogue,
        context: state.currentContext ?? SherpiContext.general,
        metadata: {
          ...state.metadata ?? {},
          'isRead': true, // 메타데이터로 읽음 상태 저장
          'read_timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  void changeEmotion(SherpiEmotion emotion) {
    if (state.isVisible) {
      state = state.copyWith(emotion: emotion);
    }
  }

  void changeDialogue(String dialogue) {
    if (state.isVisible) {
      state = state.copyWith(dialogue: dialogue);
    }
  }

  Future<void> showContextualMessage({
    required SherpiContext context,
    required Map<String, dynamic> userContext,
    Duration duration = const Duration(seconds: 4),
  }) async {
    await showMessage(
      context: context,
      duration: duration,
      userContext: userContext,
    );
  }

  Future<void> showGameMessage({
    required SherpiContext context,
    required Map<String, dynamic> gameContext,
    Duration duration = const Duration(seconds: 4),
  }) async {
    await showMessage(
      context: context,
      duration: duration,
      gameContext: gameContext,
    );
  }

  Map<String, dynamic> exportState() {
    return state.toJson();
  }

  void importState(Map<String, dynamic> stateData) {
    state = SherpiState.fromJson(stateData);
  }

  void _showFallbackMessage(SherpiContext context, SherpiEmotion? emotion) {
    final fallbackDialogues = {
      SherpiContext.welcome: '안녕하세요! 😊',
      SherpiContext.levelUp: '축하해요! 🎉',
      SherpiContext.encouragement: '힘내세요! 💪',
    };

    final dialogue = fallbackDialogues[context] ?? '안녕하세요!';
    final selectedEmotion =
        emotion ?? SherpiEmotion.cheering; // ✅ 기본값을 cheering으로

    state = state.copyWith(
      emotion: selectedEmotion,
      dialogue: dialogue,
      isVisible: true,
      lastShownTime: DateTime.now(),
      currentContext: context,
    );

    _hideTimer = Timer(const Duration(seconds: 3), hideMessage);
  }

  /// 🚀 백그라운드 캐시 초기화 (앱 시작 시 한 번 실행) - AI 시스템 비활성화
  /*
  Future<void> initializeBackgroundCaching({
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  }) async {
    // AI 시스템 비활성화 - 더 이상 백그라운드 캐싱 사용하지 않음
  }
  */

  /// 📊 시스템 상태 조회 - 정적 메시지 시스템
  Future<Map<String, dynamic>> getSystemStatus() async {
    // 정적 메시지 시스템 상태 반환
    return {
      'message_source': 'static_only',
      'cache_enabled': false,
      'ai_enabled': false,
      'static_messages_count': 50, // 예상 정적 메시지 수
    };
  }

  void _logInteraction(
    SherpiContext context,
    SherpiEmotion emotion,
    String dialogue,
    Map<String, dynamic> metadata,
  ) {}

  /// 🎭 활동 완료 컨텍스트인지 확인
  bool _isActivityCompletionContext(SherpiContext context) {
    const activityContexts = [
      SherpiContext.exerciseComplete,
      SherpiContext.readingComplete,
      SherpiContext.questComplete,
      SherpiContext.climbingSuccess,
      SherpiContext.levelUp,
      SherpiContext.badgeEarned,
      SherpiContext.achievement,
    ];
    return activityContexts.contains(context);
  }

  /// 🎭 감정 분석 후 추천 감정 반환
  Future<SherpiEmotion> _analyzeAndGetRecommendedEmotion(
    SherpiContext context,
    Map<String, dynamic> userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    try {
      final emotionNotifier = _ref.read(emotionAnalysisProvider.notifier);

      // 활동 타입 결정
      String activityType;
      bool isSuccess = true; // 기본값은 성공

      switch (context) {
        case SherpiContext.exerciseComplete:
          activityType = 'exercise';
          break;
        case SherpiContext.readingComplete:
          activityType = 'study';
          break;
        case SherpiContext.questComplete:
          activityType = 'quest';
          break;
        case SherpiContext.climbingSuccess:
          activityType = 'climbing';
          break;
        case SherpiContext.levelUp:
          activityType = 'level_up';
          break;
        case SherpiContext.badgeEarned:
          activityType = 'badge';
          break;
        case SherpiContext.achievement:
          activityType = 'achievement';
          break;
        default:
          activityType = 'general';
      }

      // 실패 여부 확인 (userContext에서)
      isSuccess = userContext['isSuccess'] as bool? ?? true;

      // 연속 일수 추출
      int consecutiveDays = 0;
      switch (activityType) {
        case 'exercise':
          consecutiveDays = userContext['연속_운동일'] as int? ?? 0;
          break;
        case 'study':
          consecutiveDays = userContext['연속_독서일'] as int? ?? 0;
          break;
        default:
          consecutiveDays = userContext['연속_접속일'] as int? ?? 0;
      }

      // 감정 분석 실행
      final analysisResult = await emotionNotifier.analyzeUserEmotion(
        activityType: activityType,
        isSuccess: isSuccess,
        consecutiveDays: consecutiveDays,
        performanceData: userContext,
      );

      // 추천 감정 반환
      final recommendedEmotion = emotionNotifier.getRecommendedSherpiEmotion();

      return recommendedEmotion;
    } catch (e) {
      // 실패 시 기본 감정 반환
      return SherpiEmotionMapper.getEmotionForContext(context);
    }
  }

  /// 💖 Sherpi 응답 기록 (감정 동기화를 위해)
  void _recordSherpiResponse(SherpiEmotion emotion) {
    try {
      final emotionNotifier = _ref.read(emotionAnalysisProvider.notifier);
      emotionNotifier.recordSherpiResponse(emotion);
    } catch (e) {
      // 에러 무시 - 중요하지 않은 작업
    }
  }

  /// 💕 관계 시스템에 감정 동기화 점수 업데이트
  void _updateRelationshipEmotionalSync() {
    try {
      final emotionState = _ref.read(emotionAnalysisProvider);
      final relationshipNotifier = _ref.read(relationshipProvider.notifier);

      // 감정 분석 시스템에서 계산된 동기화 점수를 관계 시스템에 적용
      final syncScore = emotionState.emotionalSyncScore;

      if (syncScore > 0) {
        relationshipNotifier.updateEmotionalSync(syncScore);
      }
    } catch (e) {
      // 에러 무시 - 중요하지 않은 작업
    }
  }

  /// 📝 메시지 히스토리에 추가
  void _addToHistory({
    required SherpiEmotion emotion,
    required String message,
    required SherpiContext context,
    required Map<String, dynamic> metadata,
  }) {
    final history = SherpiMessageHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emotion: emotion,
      message: message,
      context: context,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _messageHistory.insert(0, history); // 최신 메시지를 앞에 추가

    // 최대 개수 유지
    if (_messageHistory.length > _maxHistorySize) {
      _messageHistory.removeLast();
    }
  }

  /// 📚 메시지 히스토리 가져오기
  List<SherpiMessageHistory> getMessageHistory() {
    return List.unmodifiable(_messageHistory);
  }

  /// 🧹 메시지 히스토리 초기화
  void clearMessageHistory() {
    _messageHistory.clear();
  }

  /// 🎨 Phase 2: 개인화 설정 업데이트
  /// 사용자가 설정을 변경했을 때 호출되는 메서드
  void updatePersonalizationSettings(PersonalizationSettings newSettings) {
    try {
      // 관계 프로바이더에 새로운 개인화 설정 적용
      final relationshipNotifier = _ref.read(relationshipProvider.notifier);
      final currentRelationship = _ref.read(relationshipProvider);

      final updatedRelationship = currentRelationship.copyWith(
        personalizationSettings: newSettings,
      );

      // 직접 상태 업데이트 (관계 프로바이더에 업데이트 메서드가 있다면 그것을 사용)
      relationshipNotifier.updateRelationship(updatedRelationship);

      // _smartManager.setPersonalizationSettings(newSettings); // DISABLED

      // 설정 변경을 알리는 메시지 표시 (선택사항)
      showInstantMessage(
        context: SherpiContext.general,
        customDialogue:
            '${newSettings.nickname}가 ${newSettings.personalityType.displayName} 성격으로 변경되었어요! ✨',
        emotion: SherpiEmotion.cheering,
        forceShow: true,
      );
    } catch (e) {
      // 에러 무시 - 중요하지 않은 작업
    }
  }

  /// 🚨 중복 메시지 감지 (3초 이내 같은 컨텍스트/메시지는 중복으로 간주)
  bool _isDuplicateMessage(SherpiContext context, String? dialogue) {
    final now = DateTime.now();

    // 첫 번째 메시지인 경우
    if (_lastMessageTime == null) {
      _updateLastMessage(now, context, dialogue);
      return false;
    }

    // 3초 이내에 같은 컨텍스트의 메시지가 온 경우 (탭 전환 시 중복 방지를 위해 시간 증가)
    final timeDiff = now.difference(_lastMessageTime!);
    if (timeDiff.inSeconds < 3 && _lastContext == context) {
      // 같은 메시지 내용인 경우 중복으로 간주
      if (dialogue != null && _lastDialogue == dialogue) {
        return true;
      }
      // 메시지 내용이 null인 경우 (showMessage 호출) 컨텍스트만으로 중복 판단
      if (dialogue == null) {
        return true;
      }
    }

    // 중복이 아닌 경우 최근 메시지 정보 업데이트
    _updateLastMessage(now, context, dialogue);
    return false;
  }

  /// 최근 메시지 정보 업데이트
  void _updateLastMessage(
      DateTime time, SherpiContext context, String? dialogue) {
    _lastMessageTime = time;
    _lastContext = context;
    _lastDialogue = dialogue;
  }
}

// ✅ 초기화 기능이 추가된 Provider
final sherpiMessageManagerProvider = Provider<SherpiMessageManager>((ref) {
  return StaticSherpiManager();
});

final sherpiProvider =
    StateNotifierProvider<SherpiNotifier, SherpiState>((ref) {
  final messageManager = ref.watch(sherpiMessageManagerProvider);
  final notifier = SherpiNotifier(
    ref,
    messageManager: messageManager,
  );

  return notifier;
});

final sherpiImageProvider = Provider<String>((ref) {
  final emotion = ref.watch(sherpiProvider.select((state) => state.emotion));
  return emotion.imagePath;
});

final sherpiVisibilityProvider = Provider<bool>((ref) {
  return ref.watch(sherpiProvider.select((state) => state.isVisible));
});

final sherpiDialogueProvider = Provider<String>((ref) {
  return ref.watch(sherpiProvider.select((state) => state.dialogue));
});

final sherpiEmotionProvider = Provider<SherpiEmotion>((ref) {
  return ref.watch(sherpiProvider.select((state) => state.emotion));
});

final sherpiContextProvider = Provider<SherpiContext?>((ref) {
  return ref.watch(sherpiProvider.select((state) => state.currentContext));
});

extension SherpiProviderExtension on WidgetRef {
  Future<void> showSherpi(
    SherpiContext context, {
    SherpiEmotion? emotion,
    Duration? duration,
  }) async {
    await read(sherpiProvider.notifier).showMessage(
      context: context,
      emotion: emotion,
      duration: duration ?? const Duration(seconds: 4),
      forceShow: false, // 기본적으로 중복 방지 적용
    );
  }

  Future<void> showSherpiWithContext(
    SherpiContext context,
    Map<String, dynamic> userContext, {
    SherpiEmotion? emotion,
    Duration? duration,
  }) async {
    await read(sherpiProvider.notifier).showMessage(
      context: context,
      emotion: emotion,
      duration: duration ?? const Duration(seconds: 4),
      userContext: userContext,
      forceShow: false, // 기본적으로 중복 방지 적용
    );
  }

  Future<void> showSherpiWithGame(
    SherpiContext context,
    Map<String, dynamic> gameContext, {
    SherpiEmotion? emotion,
    Duration? duration,
  }) async {
    await read(sherpiProvider.notifier).showMessage(
      context: context,
      emotion: emotion,
      duration: duration ?? const Duration(seconds: 4),
      gameContext: gameContext,
      forceShow: false, // 기본적으로 중복 방지 적용
    );
  }

  void showCustomSherpi(
    SherpiContext context,
    String dialogue, {
    SherpiEmotion? emotion,
    Duration? duration,
  }) {
    read(sherpiProvider.notifier).showInstantMessage(
      context: context,
      customDialogue: dialogue,
      emotion: emotion,
      duration: duration ?? const Duration(seconds: 4),
      forceShow: false, // 기본적으로 중복 방지 적용
    );
  }

  void hideSherpi() {
    read(sherpiProvider.notifier).hideMessage();
  }

  void changeSherpiEmotion(SherpiEmotion emotion) {
    read(sherpiProvider.notifier).changeEmotion(emotion);
  }

  /// 🎨 Phase 2: 개인화 설정 업데이트 확장 메서드
  void updateSherpiPersonalization(PersonalizationSettings settings) {
    read(sherpiProvider.notifier).updatePersonalizationSettings(settings);
  }

  /// 🎨 현재 개인화 설정 가져오기
  PersonalizationSettings getSherpiPersonalizationSettings() {
    try {
      final relationship = read(relationshipProvider);
      return relationship.personalizationSettings;
    } catch (e) {
      return const PersonalizationSettings(); // 기본값 반환
    }
  }
}
