import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/constants/sherpi_dialogues.dart';
import '../../core/ai/smart_sherpi_manager.dart';

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
  Timer? _hideTimer;

  SherpiNotifier({SherpiDialogueSource? dialogueSource})
      : _dialogueSource = dialogueSource ?? StaticDialogueSource(),
        super(const SherpiState()); // ✅ 기본값으로 cheering 상태 시작

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
      final selectedEmotion = emotion ?? SherpiDialogueUtils.getRecommendedEmotion(context);
      
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
}

// ✅ 초기화 기능이 추가된 Provider
final sherpiProvider = StateNotifierProvider<SherpiNotifier, SherpiState>((ref) {
  final notifier = SherpiNotifier();
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
