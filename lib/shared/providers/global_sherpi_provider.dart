import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/constants/sherpi_dialogues.dart';
import '../../core/ai/smart_sherpi_manager.dart';
import '../../features/sherpi_relationship/providers/relationship_provider.dart';
import '../../features/sherpi_emotion/providers/emotion_analysis_provider.dart';
import '../../features/sherpi_emotion/models/emotion_analysis_model.dart';

enum SherpiDisplayMode {
  floating,      // 우하단 플로팅 (기본)
  notification,  // 상단 알림바
  inline,        // 인라인 (특정 위젯 내부)
  hidden,        // 숨김
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
    this.emotion = SherpiEmotion.cheering, // ✅ 기본값을 cheering으로 변경
    this.dialogue = '셰르파에 오신 것을 환영해요! 🎉', // ✅ 기본 대사 추가
    this.isVisible = true, // ✅ 기본적으로 보이도록 설정
    this.displayMode = SherpiDisplayMode.floating,
    this.lastShownTime,
    this.currentContext = SherpiContext.welcome, // ✅ 기본 컨텍스트 설정
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
        orElse: () => SherpiEmotion.cheering, // ✅ 기본값을 cheering으로
      ),
      dialogue: json['dialogue'] ?? '셰르파에 오신 것을 환영해요! 🎉',
      isVisible: json['isVisible'] ?? true, // ✅ 기본적으로 보이도록
      lastShownTime: json['lastShownTime'] != null
          ? DateTime.parse(json['lastShownTime'])
          : null,
      currentContext: json['currentContext'] != null
          ? SherpiContext.values.firstWhere(
            (c) => c.name == json['currentContext'],
        orElse: () => SherpiContext.welcome,
      )
          : SherpiContext.welcome, // ✅ 기본 컨텍스트
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

class SherpiNotifier extends StateNotifier<SherpiState> {
  final SherpiDialogueSource _dialogueSource;
  final SmartSherpiManager _smartManager = SmartSherpiManager();
  final Ref _ref;
  Timer? _hideTimer;

  SherpiNotifier(this._ref, {SherpiDialogueSource? dialogueSource})
      : _dialogueSource = dialogueSource ?? StaticDialogueSource(),
        super(const SherpiState()) {
    // 친밀도 레벨 초기화
    _updateIntimacyLevel();
  }

  /// 친밀도 레벨을 SmartSherpiManager에 업데이트
  void _updateIntimacyLevel() {
    try {
      final relationship = _ref.read(sherpiRelationshipProvider);
      _smartManager.setIntimacyLevel(relationship.intimacyLevel);
    } catch (e) {
      // 관계 프로바이더가 아직 초기화되지 않은 경우
      print('🤝 관계 정보 로드 실패: $e');
    }
  }
  
  /// 상호작용 기록 및 친밀도 업데이트
  void _recordInteraction(
    SherpiContext context, 
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext
  ) {
    try {
      final notifier = _ref.read(sherpiRelationshipProvider.notifier);
      
      // 상호작용 타입 결정
      String interactionType;
      switch (context) {
        case SherpiContext.exerciseComplete:
          interactionType = 'exercise_complete';
          break;
        case SherpiContext.studyComplete:
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
      print('🤝 상호작용 기록 실패: $e');
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
      _hideTimer?.cancel();
      
      // 🎭 감정 분석 및 추천 감정 가져오기
      SherpiEmotion selectedEmotion;
      if (emotion != null) {
        selectedEmotion = emotion;
      } else {
        // 활동 완료 시 감정 분석 수행
        if (_isActivityCompletionContext(context) && userContext != null) {
          selectedEmotion = await _analyzeAndGetRecommendedEmotion(
            context, userContext, gameContext
          );
        } else {
          selectedEmotion = SherpiDialogueUtils.getRecommendedEmotion(context);
        }
      }
      
      // 🚀 스마트 매니저를 통한 지능적 메시지 선택
      final sherpiResponse = await _smartManager.getMessage(
        context,
        userContext,
        gameContext,
      );
      
      final metadata = SherpiDialogueUtils.createContextData(
        context: context,
        userData: userContext,
        gameData: gameContext,
      );
      
      // 응답 소스 정보를 메타데이터에 추가
      final enhancedMetadata = {
        ...metadata,
        'response_source': sherpiResponse.source.name,
        'response_time': sherpiResponse.responseTime.toIso8601String(),
        'is_fast_response': sherpiResponse.isFastResponse,
        if (sherpiResponse.generationDuration != null)
          'generation_duration_ms': sherpiResponse.generationDuration!.inMilliseconds,
        'emotion_analyzed': _isActivityCompletionContext(context),
      };
      
      state = state.copyWith(
        emotion: selectedEmotion,
        dialogue: sherpiResponse.message,
        isVisible: true,
        lastShownTime: DateTime.now(),
        currentContext: context,
        metadata: enhancedMetadata,
      );
      
      _logInteraction(context, selectedEmotion, sherpiResponse.message, enhancedMetadata);
      
      // 🤝 상호작용 기록 및 친밀도 업데이트
      _recordInteraction(context, userContext, gameContext);
      
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
    } catch (e) {
      _showFallbackMessage(context, emotion);
    }
  }

  void showInstantMessage({
    required SherpiContext context,
    required String customDialogue,
    SherpiEmotion? emotion,
    Duration duration = const Duration(seconds: 4),
  }) {


    _hideTimer?.cancel();
    final selectedEmotion = emotion ?? SherpiDialogueUtils.getRecommendedEmotion(context);
    state = state.copyWith(
      emotion: selectedEmotion,
      dialogue: customDialogue,
      isVisible: true,
      lastShownTime: DateTime.now(),
      currentContext: context,
    );
    _hideTimer = Timer(duration, hideMessage);
  }

  void hideMessage() {
    _hideTimer?.cancel();
    state = state.copyWith(isVisible: false);
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

  void switchDialogueSource(SherpiDialogueSource newSource) {

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
    final selectedEmotion = emotion ?? SherpiEmotion.cheering; // ✅ 기본값을 cheering으로

    state = state.copyWith(
      emotion: selectedEmotion,
      dialogue: dialogue,
      isVisible: true,
      lastShownTime: DateTime.now(),
      currentContext: context,
    );

    _hideTimer = Timer(const Duration(seconds: 3), hideMessage);
  }

  /// 🚀 백그라운드 캐시 초기화 (앱 시작 시 한 번 실행)
  Future<void> initializeBackgroundCaching({
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  }) async {
    final defaultUserContext = userContext ?? {
      '사용자명': '사용자',
      '레벨': '1',
      '연속 접속일': '1',
    };
    
    final defaultGameContext = gameContext ?? {
      '현재 산': '한라산',
      '등반 성공률': '50%',
      '최근 활동': '앱 사용 중',
    };

    // 백그라운드에서 중요한 메시지들 사전 생성 시작
    await _smartManager.startBackgroundCaching(
      defaultUserContext,
      defaultGameContext,
    );
  }

  /// 📊 시스템 상태 조회
  Future<Map<String, dynamic>> getSystemStatus() async {
    return await _smartManager.getSystemStatus();
  }

  void _logInteraction(
      SherpiContext context,
      SherpiEmotion emotion,
      String dialogue,
      Map<String, dynamic> metadata,
      ) {

  }

  /// 🎭 활동 완료 컨텍스트인지 확인
  bool _isActivityCompletionContext(SherpiContext context) {
    const activityContexts = [
      SherpiContext.exerciseComplete,
      SherpiContext.studyComplete,
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
        case SherpiContext.studyComplete:
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
      
      print('🎭 감정 분석 완료: ${analysisResult.primaryEmotion.name} → ${recommendedEmotion.name}');
      
      return recommendedEmotion;
      
    } catch (e) {
      print('🎭 감정 분석 실패: $e');
      // 실패 시 기본 감정 반환
      return SherpiDialogueUtils.getRecommendedEmotion(context);
    }
  }

  /// 💖 Sherpi 응답 기록 (감정 동기화를 위해)
  void _recordSherpiResponse(SherpiEmotion emotion) {
    try {
      final emotionNotifier = _ref.read(emotionAnalysisProvider.notifier);
      emotionNotifier.recordSherpiResponse(emotion);
    } catch (e) {
      print('💖 Sherpi 응답 기록 실패: $e');
    }
  }

  /// 💕 관계 시스템에 감정 동기화 점수 업데이트
  void _updateRelationshipEmotionalSync() {
    try {
      final emotionState = _ref.read(emotionAnalysisProvider);
      final relationshipNotifier = _ref.read(sherpiRelationshipProvider.notifier);
      
      // 감정 분석 시스템에서 계산된 동기화 점수를 관계 시스템에 적용
      final syncScore = emotionState.emotionalSyncScore;
      
      if (syncScore > 0) {
        relationshipNotifier.updateEmotionalSync(syncScore);
        print('💕 감정 동기화 점수 업데이트: ${(syncScore * 100).toInt()}%');
      }
    } catch (e) {
      print('💕 감정 동기화 점수 업데이트 실패: $e');
    }
  }
}

// ✅ 초기화 기능이 추가된 Provider
final sherpiProvider = StateNotifierProvider<SherpiNotifier, SherpiState>((ref) {
  final notifier = SherpiNotifier(ref);
  // 앱 시작 시 자동으로 cheering 상태로 초기화
  /*
  Future.microtask(() => notifier.initializeSherpi());
  */

  return notifier;
});

final sherpiImageProvider = Provider<String>((ref) {
  final emotion = ref.watch(sherpiProvider.select((state) => state.emotion));
  return SherpiDialogueUtils.getImagePath(emotion);
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
    );
  }

  void hideSherpi() {
    read(sherpiProvider.notifier).hideMessage();
  }

  void changeSherpiEmotion(SherpiEmotion emotion) {
    read(sherpiProvider.notifier).changeEmotion(emotion);
  }
}
