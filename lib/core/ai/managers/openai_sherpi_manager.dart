import 'package:sherpa_app/core/ai/cache/ai_message_cache.dart';
import 'package:sherpa_app/core/ai/managers/sherpi_message_manager.dart';
import 'package:sherpa_app/core/ai/managers/static_sherpi_manager.dart';
import 'package:sherpa_app/core/ai/sources/openai_dialogue_source.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/features/sherpi/domain/models/sherpi_response.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';
import 'package:sherpa_app/shared/providers/global_sherpi_provider.dart'
    show PersonalizationSettings;

/// 🧠 OpenAI 셰르피 매니저 (OpenAI GPT-5 버전)
///
/// OpenAI GPT-5와 정적 메시지를 혼합하여 사용하는 하이브리드 시스템
class OpenAISherpiManager implements SherpiMessageManager {
  // 개인화 설정
  PersonalizationSettings _personalizationSettings =
      const PersonalizationSettings();

  // AI 소스
  SherpiDialogueSource? _openaiSource;

  // 캐시 시스템
  late final AiMessageCache _cache;

  // 수동 AI 사용 플래그 (사용자가 명시적으로 요청할 때만 true)
  bool _useAIManually = false;

  // 정적 매니저 (폴백용)
  final StaticSherpiManager _staticManager;

  /// 생성자
  OpenAISherpiManager({
    StaticSherpiManager? staticManager,
    SherpiDialogueSource? dialogueSource,
    AiMessageCache? cache,
  }) : _staticManager = staticManager ?? StaticSherpiManager() {
    _openaiSource = dialogueSource;
    if (dialogueSource == null) {
      _initializeAI();
    }
    _cache = cache ?? AiMessageCache();
  }

  /// AI 시스템 초기화
  void _initializeAI() {
    try {
      if (ApiConfig.isOpenAIApiKeyValid) {
        _openaiSource = OpenAIDialogueSource();
        print('✅ OpenAI GPT-5 시스템 초기화 성공');
      } else {
        print('⚠️ OpenAI API 키가 설정되지 않음 - 정적 메시지만 사용');
      }
    } catch (e) {
      print('❌ OpenAI 초기화 실패: $e');
      _openaiSource = null;
    }
  }

  @override
  PersonalizationSettings get personalizationSettings =>
      _personalizationSettings;

  @override
  bool get supportsRealtimeAI => true;

  /// 개인화 설정 업데이트
  @override
  void setPersonalizationSettings(PersonalizationSettings settings) {
    _personalizationSettings = settings;
  }

  /// 🎮 메인 메시지 가져오기 함수
  ///
  /// AI 사용 여부를 결정하고 적절한 메시지를 반환합니다.
  @override
  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 게임 컨텍스트에 개인화 설정 추가
    if (gameContext != null) {
      gameContext['personalityType'] =
          _personalizationSettings.personalityType.displayName;
      gameContext['userPreferredName'] =
          _personalizationSettings.userPreferredName;
    }

    // 1. 캐시 확인
    final cachedMessage =
        await _cache.getCachedMessage(context, userContext ?? {});
    if (cachedMessage != null) {
      print('💾 캐시에서 메시지 반환');
      return SherpiResponse(
        message: cachedMessage,
        source: MessageSource.aiCached,
        responseTime: DateTime.now(),
        generationDuration: Duration.zero,
      );
    }

    // 2. AI 사용 여부 결정
    if (_shouldUseAI(context, userContext, gameContext)) {
      try {
        print('🤖 OpenAI GPT-5 메시지 생성 시작');
        final stopwatch = Stopwatch()..start();

        final aiMessage = await _openaiSource!.getDialogue(
          context,
          userContext,
          gameContext,
        );

        stopwatch.stop();

        // 캐시에 저장 (현재 캐시 시스템이 비활성화되어 있으므로 생략)
        // TODO: 캐시 시스템 재활성화 시 구현 필요

        // 이모지 사용 설정에 따른 조정
        String finalMessage = aiMessage;
        if (!_personalizationSettings.useEmojisInMessages) {
          finalMessage = _removeEmojis(finalMessage);
        }

        print('✅ OpenAI 메시지 생성 완료 (${stopwatch.elapsedMilliseconds}ms)');

        return SherpiResponse(
          message: finalMessage,
          source: MessageSource.aiRealtime,
          responseTime: DateTime.now(),
          generationDuration: stopwatch.elapsed,
        );
      } catch (e) {
        print('❌ OpenAI 메시지 생성 실패, 정적 메시지로 전환: $e');
      }
    }

    // 3. 정적 메시지 반환
    return _getStaticMessageSync(context, userContext, gameContext);
  }

  /// AI 사용 여부 결정 로직
  /// 이제는 수동으로 활성화된 경우에만 AI를 사용합니다.
  bool _shouldUseAI(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    // OpenAI가 초기화되지 않았으면 사용 불가
    if (_openaiSource == null) {
      return false;
    }

    // 수동으로 AI 사용이 활성화된 경우에만 사용
    if (_useAIManually) {
      print('🎯 수동 AI 사용 활성화됨 - OpenAI GPT-5 사용');
      // 한 번 사용 후 자동으로 비활성화
      _useAIManually = false;
      return true;
    }

    // 기본적으로 항상 정적 메시지 사용 (100%)
    return false;
  }

  /// 다음 메시지에 대해 AI 사용을 수동으로 활성화
  /// 사용자가 명시적으로 AI 응답을 원할 때 호출
  @override
  void enableAIForNextMessage() {
    if (_openaiSource != null) {
      _useAIManually = true;
      print('✅ 다음 메시지에 AI 사용이 활성화되었습니다.');
    } else {
      print('❌ OpenAI가 초기화되지 않아 AI를 사용할 수 없습니다.');
    }
  }

  /// AI 사용 강제 활성화 (특정 컨텍스트에 대해)
  @override
  Future<SherpiResponse> getMessageWithAI(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 일시적으로 AI 사용 활성화
    _useAIManually = true;
    return await getMessage(context, userContext, gameContext);
  }

  /// ⚡ 동기식 정적 메시지 (0ms - 즉시 응답)
  SherpiResponse _getStaticMessageSync(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    String message;

    // 모임 개설 시 카테고리별 메시지 사용
    if (context == SherpiContext.meetingCreated && userContext != null) {
      // 사용자 이름 가져오기
      final userName = gameContext?['userPreferredName'] ??
          _personalizationSettings.userPreferredName ??
          '친구';

      // 모임 정보 가져오기
      final meetingTitle = userContext['meetingTitle'] ?? '새로운 모임';
      final category = userContext['category'] ?? '';

      // 카테고리별 메시지 생성
      message = getCategorySpecificMeetingMessage(
        category: category,
        userName: userName,
        meetingTitle: meetingTitle,
      );
    } else {
      // 일반적인 메시지 처리
      final baseMessages = _getPersonalizedStaticMessages(context);
      message = baseMessages[context] ?? '멋진 하루 보내세요!';

      // 사용자 이름으로 개인화
      if (_personalizationSettings.userPreferredName != '친구') {
        message = message.replaceAll(
            '친구', _personalizationSettings.userPreferredName);
      }
    }

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

  /// 성격 유형별 정적 메시지 생성
  Map<SherpiContext, String> _getPersonalizedStaticMessages(
      SherpiContext context) {
    switch (_personalizationSettings.personalityType) {
      case SherpiPersonalityType.energetic:
        return {
          SherpiContext.welcome:
              '와! ${_personalizationSettings.userPreferredName}님! 셰르파에 오신 걸 환영해요!! 🎉✨',
          SherpiContext.dailyGreeting:
              '${_personalizationSettings.userPreferredName}님! 오늘도 에너지 넘치게 파이팅!! 💪🔥',
          SherpiContext.encouragement: '우와! 정말 잘하고 있어요! 계속 달려봐요!! ✨🚀',
          SherpiContext.levelUp: '와아! 레벨업이에요!! 너무 멋져요!! 🎊🏆',
          SherpiContext.exerciseComplete: '운동 완료!! 최고예요!! 💪⚡',
          SherpiContext.readingComplete:
              '독서 완료!! ${_personalizationSettings.userPreferredName}님 대단해요!! 📚🌟',
          SherpiContext.questComplete: '퀘스트 클리어!! 완전 프로 실력이에요!! 🎯🎉',
          SherpiContext.climbingSuccess: '등반 성공!! 정상에서 보는 뷰가 최고죠!! 🏔️✨',
          SherpiContext.badgeEarned:
              '뱃지 획득!! ${_personalizationSettings.userPreferredName}님 컬렉션이 늘어나고 있어요!! 🏅✨',
          SherpiContext.statIncrease: '스탯 업!! 더 강해지고 있어요!! 💪📈',
          SherpiContext.diaryWritten: '일기 작성 완료!! 오늘의 감정이 소중해요!! 📝💝',
          SherpiContext.longTimeNoSee:
              '${_personalizationSettings.userPreferredName}님!! 정말 오랜만이에요!! 너무 보고 싶었어요!! 🤗💕',
          SherpiContext.achievement: '대박! 엄청난 성취예요!! 🏆✨',
          SherpiContext.allGoalsComplete: '모든 목표 완료!! 완벽한 하루였어요!! 🎊💯',
        };
      case SherpiPersonalityType.calm:
        return {
          SherpiContext.welcome:
              '안녕하세요 ${_personalizationSettings.userPreferredName}님. 셰르파에 오신 것을 환영합니다. 🌱',
          SherpiContext.dailyGreeting:
              '${_personalizationSettings.userPreferredName}님, 오늘도 차근차근 해보아요. ☺️',
          SherpiContext.encouragement:
              '${_personalizationSettings.userPreferredName}님은 이미 충분히 잘하고 계세요. 🌸',
          SherpiContext.levelUp: '레벨업을 축하드립니다. 꾸준한 노력의 결과네요. 🌟',
          SherpiContext.exerciseComplete: '운동을 완료하셨네요. 몸과 마음이 건강해지고 있어요. 💚',
          SherpiContext.readingComplete:
              '독서를 마치셨네요. ${_personalizationSettings.userPreferredName}님의 지식이 깊어지고 있습니다. 📖',
          SherpiContext.questComplete: '퀘스트를 완료하셨습니다. 한 걸음 한 걸음이 모두 의미 있어요. 🎯',
          SherpiContext.climbingSuccess: '정상에 도달하셨네요. 여유를 가지고 경치를 즐겨보세요. 🏔️',
          SherpiContext.badgeEarned:
              '새로운 뱃지를 획득하셨습니다. ${_personalizationSettings.userPreferredName}님의 성장이 보입니다. 🏅',
          SherpiContext.statIncrease: '능력치가 향상되었습니다. 내면의 성장이 느껴지네요. 📊',
          SherpiContext.diaryWritten: '오늘의 기록을 남기셨네요. 소중한 하루였길 바랍니다. 📝',
          SherpiContext.longTimeNoSee:
              '${_personalizationSettings.userPreferredName}님, 오랜만입니다. 편안한 마음으로 돌아오셨길 바라요. 🌿',
          SherpiContext.achievement: '의미있는 성취를 이루셨네요. 🎯',
          SherpiContext.allGoalsComplete: '오늘의 모든 목표를 달성하셨습니다. 균형잡힌 하루였네요. 🌟',
        };
      case SherpiPersonalityType.humorous:
        return {
          SherpiContext.welcome:
              '어머! ${_personalizationSettings.userPreferredName}님이 오셨네요! 셰르파가 더 즐거워졌어요! 🎭',
          SherpiContext.dailyGreeting:
              '${_personalizationSettings.userPreferredName}님! 오늘 기분은 어때요? 저는 1일 1깡 할 기분이에요! 😄',
          SherpiContext.encouragement:
              '${_personalizationSettings.userPreferredName}님! 이 정도면 셰르피보다 더 능력자인걸요? 😉',
          SherpiContext.levelUp: '레벨업! 축하해요! 이제 저랑 수평선상에서 만나는 건가요? 😂🎉',
          SherpiContext.exerciseComplete: '운동 완료! 땀 한 방울 한 방울이 다 보석이에요! ✨💎',
          SherpiContext.readingComplete:
              '독서 끝! ${_personalizationSettings.userPreferredName}님 마음이 풍요로워지고 있어요! 📚✨',
          SherpiContext.questComplete:
              '퀘스트 깨기! 이제 ${_personalizationSettings.userPreferredName}님은 퀘스트 브레이커! 🎮😎',
          SherpiContext.climbingSuccess:
              '정상 도착! 이제 산이 ${_personalizationSettings.userPreferredName}님을 올려다보고 있을걸요? 🏔️😂',
          SherpiContext.badgeEarned: '뱃지 겟! 이러다 뱃지 부자 되겠어요! 💰🏅',
          SherpiContext.statIncrease:
              '스탯 상승! 파워가 9000을 넘어가려 하네요! 💪9️⃣0️⃣0️⃣0️⃣',
          SherpiContext.diaryWritten:
              '일기 완성! 오늘의 ${_personalizationSettings.userPreferredName}님 스토리, 베스트셀러감이에요! 📚😊',
          SherpiContext.longTimeNoSee:
              '${_personalizationSettings.userPreferredName}님! 어디 계셨어요? 셰르피가 기다리다가 돌이 될 뻔했어요! 🗿😅',
          SherpiContext.achievement: '와! 이건 진짜 대박이에요! 상 받아야 할 수준! 🏆😎',
          SherpiContext.allGoalsComplete:
              '전부 클리어! 오늘 ${_personalizationSettings.userPreferredName}님은 신이에요! 🎊🙌',
        };
      case SherpiPersonalityType.serious:
        return {
          SherpiContext.welcome:
              '${_personalizationSettings.userPreferredName}님, 셰르파 시스템에 접속하신 것을 환영합니다. 📋',
          SherpiContext.dailyGreeting:
              '${_personalizationSettings.userPreferredName}님, 오늘의 목표를 달성해보세요. 🎯',
          SherpiContext.encouragement:
              '${_personalizationSettings.userPreferredName}님의 현재 진행상황은 양호합니다. 계속 진행하시기 바랍니다. 📊',
          SherpiContext.levelUp: '레벨 상승을 확인했습니다. 체계적인 성장을 보이고 계십니다. 📈',
          SherpiContext.exerciseComplete:
              '운동 세션이 완료되었습니다. 규칙적인 운동이 건강 유지의 핵심입니다. ✅',
          SherpiContext.readingComplete:
              '독서 목표를 달성하셨습니다. ${_personalizationSettings.userPreferredName}님의 지식 습득률이 향상되고 있습니다. 📚',
          SherpiContext.questComplete: '퀘스트가 완료되었습니다. 목표 달성률이 상승했습니다. ✓',
          SherpiContext.climbingSuccess:
              '등반이 성공적으로 완료되었습니다. 계획적인 접근이 좋은 결과를 가져왔습니다. 🏔️',
          SherpiContext.badgeEarned:
              '새로운 뱃지를 획득하셨습니다. ${_personalizationSettings.userPreferredName}님의 성과가 인정받았습니다. 🏅',
          SherpiContext.statIncrease: '능력치가 상향 조정되었습니다. 지속적인 개선이 확인됩니다. 📊',
          SherpiContext.diaryWritten: '일일 기록이 저장되었습니다. 꾸준한 기록이 성장의 지표가 됩니다. 📝',
          SherpiContext.longTimeNoSee:
              '${_personalizationSettings.userPreferredName}님, 재접속을 환영합니다. 그동안의 데이터가 보존되어 있습니다. 📂',
          SherpiContext.achievement: '목표한 성취를 달성하셨습니다. 📊',
          SherpiContext.allGoalsComplete: '일일 목표 100% 달성. 완벽한 수행입니다. ✅',
        };
      default: // balanced
        return {
          SherpiContext.welcome:
              '안녕하세요 ${_personalizationSettings.userPreferredName}님! 셰르파에 오신 것을 환영해요! 🎉',
          SherpiContext.dailyGreeting:
              '${_personalizationSettings.userPreferredName}님, 오늘도 화이팅! 💪',
          SherpiContext.encouragement:
              '${_personalizationSettings.userPreferredName}님, 잘하고 있어요! 계속해봐요! ✨',
          SherpiContext.levelUp: '레벨업 축하드려요! 🚀',
          SherpiContext.exerciseComplete: '운동 완료! 수고하셨어요! 💪',
          SherpiContext.readingComplete:
              '독서 완료! ${_personalizationSettings.userPreferredName}님 정말 열심히 하셨네요! 📚',
          SherpiContext.questComplete: '퀘스트 완료! 오늘도 목표를 달성하셨네요! 🎯',
          SherpiContext.climbingSuccess: '등반 성공! 정상에서의 기분이 어떠신가요? 🏔️',
          SherpiContext.badgeEarned:
              '뱃지 획득! ${_personalizationSettings.userPreferredName}님의 또 다른 성취예요! 🏅',
          SherpiContext.statIncrease: '스탯이 올랐어요! 점점 더 강해지고 있네요! 💪',
          SherpiContext.diaryWritten: '일기 작성 완료! 오늘 하루도 의미있었길 바라요. 📝',
          SherpiContext.longTimeNoSee:
              '${_personalizationSettings.userPreferredName}님, 오랜만이에요! 다시 만나서 반가워요! 😊',
          SherpiContext.achievement: '멋진 성취를 이루셨네요! 🎯✨',
          SherpiContext.allGoalsComplete: '오늘의 모든 목표를 완료했어요! 완벽한 하루! 🎊',
          SherpiContext.meetingJoined: '모임에 참여하셨네요! 즐거운 시간 되세요! 🤝',
          SherpiContext.milestone: '중요한 이정표를 달성하셨어요! 🏆',
          SherpiContext.specialEvent: '특별한 이벤트예요! 즐겨보세요! 🎈',
          SherpiContext.general:
              '${_personalizationSettings.userPreferredName}님과 함께해서 즐거워요! 😊',
          SherpiContext.guidance: '제가 도와드릴게요! 함께 해봐요! 🤝',
        };
    }
  }

  /// 이모지 제거 유틸리티 함수
  String _removeEmojis(String text) {
    return text
        .replaceAll(
            RegExp(
                r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
                unicode: true),
            '')
        .trim();
  }

  /// 시스템 상태 확인
  @override
  Future<Map<String, dynamic>> getSystemStatus() async {
    final cacheStatus = await _cache.getCacheStatus();

    return {
      'mode': _openaiSource != null ? 'hybrid_openai' : 'static_only',
      'ai_enabled': _openaiSource != null,
      'ai_provider': 'OpenAI GPT-5',
      'personalization': _personalizationSettings.personalityType.displayName,
      'cache_status': cacheStatus,
      'last_update': DateTime.now().toIso8601String(),
    };
  }

  /// 리소스 정리
  void dispose() {
    if (_openaiSource is OpenAIDialogueSource) {
      (_openaiSource as OpenAIDialogueSource).dispose();
    }
    print('🔄 Smart Sherpi Manager 정리 완료');
  }
}
