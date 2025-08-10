import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/ai_message_cache.dart';
import 'package:sherpa_app/core/ai/enhanced_gemini_dialogue_source.dart';
import 'package:sherpa_app/core/ai/activity_data_collector.dart'; // Phase 2: Activity data collector
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart'; // Phase 2: PersonalizationSettings import

// Add unawaited function for background operations
void unawaited(Future<void> future) {
  // Deliberately not awaiting the future to allow background execution
}

/// 🧠 스마트 셰르피 매니저
/// 
/// 단순화된 3단계 AI 시스템으로 최적의 사용자 경험을 제공합니다.
/// 친밀도 레벨에 따라 AI 사용 비율이 조정됩니다.
class SmartSherpiManager {
  final AiMessageCache _cache = AiMessageCache();
  final EnhancedGeminiDialogueSource _geminiSource = EnhancedGeminiDialogueSource();
  
  // 친밀도 레벨 (기본값 1)
  int _intimacyLevel = 1;
  
  // Phase 2: 개인화 설정 (Week 1)
  PersonalizationSettings _personalizationSettings = const PersonalizationSettings();
  
  // Phase 2: 활동별 데이터 수집기 (Ref 필요)
  ActivityDataCollector? _dataCollector;
  
  // 🐛 디버그 모드 - AI 응답 강제 사용
  static bool debugForceAI = false;

  /// 생성자
  SmartSherpiManager();
  
  /// Phase 2: Ref를 통한 데이터 수집기 초기화
  void initDataCollector(Ref ref) {
    _dataCollector = ActivityDataCollector(ref);
    print('📊 활동별 데이터 수집기 초기화 완료');
  }
  
  /// 친밀도 레벨 설정
  void setIntimacyLevel(int level) {
    _intimacyLevel = level.clamp(1, 10);
  }
  
  /// Phase 2: 개인화 설정 업데이트
  void setPersonalizationSettings(PersonalizationSettings settings) {
    _personalizationSettings = settings;
    // 설정 변경 시 캐시 갱신 필요성 확인
    print('🎨 셰르피 개인화 설정 업데이트: ${settings.personalityType.displayName}');
  }
  
  /// Phase 2: 친밀도 레벨 + 개인화 설정에 따른 AI 사용 비율 계산
  double _getAIUsageRateByIntimacy() {
    // 🎯 Phase 2 개선: AI 사용률 추가 증가 (30% → 50%)
    // 기본 친밀도 기반 비율: 친밀도 1: 50% → 친밀도 10: 80%
    double baseRate = 0.5 + (_intimacyLevel - 1) * 0.033;
    
    // 메시지 빈도 설정에 따른 조정
    double frequencyMultiplier = _personalizationSettings.messageFrequencyMultiplier;
    
    // 성격 유형에 따른 AI 사용률 조정
    double personalityBonus = 0.0;
    switch (_personalizationSettings.personalityType) {
      case SherpiPersonalityType.energetic:
        personalityBonus = 0.08; // 활발형은 더 많은 AI 사용 (5% → 8%)
      case SherpiPersonalityType.humorous:
        personalityBonus = 0.05; // 유머형은 약간 더 많은 AI 사용 (3% → 5%)
      case SherpiPersonalityType.serious:
        personalityBonus = -0.02; // 진지형은 약간 적은 AI 사용 (더 정확한 정보 우선)
      case SherpiPersonalityType.calm:
        personalityBonus = 0.02; // 차분형은 약간 더 신중한 AI 사용 (1% → 2%)
      case SherpiPersonalityType.balanced:
        personalityBonus = 0.0; // 균형형은 기본값 유지
    }
    
    // 최종 AI 사용률 계산 (빈도 배율 적용 후 0.15 ~ 1.0 범위로 제한)
    return (baseRate * frequencyMultiplier + personalityBonus).clamp(0.15, 1.0);
  }
  
  /// 🎯 AI 사용 기준 정의 (활동 완료 시 AI 우선)
  static const Map<SherpiContext, AiUsageLevel> _aiUsageLevels = {
    // 🌟 프리미엄: 감정적 연결이 중요한 순간 (100% AI)
    SherpiContext.welcome: AiUsageLevel.premium,
    SherpiContext.longTimeNoSee: AiUsageLevel.premium,
    SherpiContext.levelUp: AiUsageLevel.premium,
    SherpiContext.milestone: AiUsageLevel.premium,
    SherpiContext.specialEvent: AiUsageLevel.premium,
    
    // ⭐ 활동 완료 - 항상 AI 사용으로 개인화된 응답 제공 (100% AI)
    SherpiContext.exerciseComplete: AiUsageLevel.premium,  // 운동 완료 시 AI 100%
    SherpiContext.studyComplete: AiUsageLevel.premium,     // 독서 완료 시 AI 100%
    SherpiContext.diaryWritten: AiUsageLevel.premium,      // 일기 작성 시 AI 100%
    
    // ⭐ 스마트: 특별한 성취 순간 (80% AI)
    SherpiContext.badgeEarned: AiUsageLevel.smart,
    SherpiContext.climbingSuccess: AiUsageLevel.smart,
    SherpiContext.questComplete: AiUsageLevel.smart,
    SherpiContext.achievement: AiUsageLevel.smart,
    SherpiContext.meetingJoined: AiUsageLevel.smart,
    SherpiContext.statIncrease: AiUsageLevel.smart,
    
    // 💬 기본: 일상적 상호작용 (40% AI)
    SherpiContext.general: AiUsageLevel.basic,
    SherpiContext.guidance: AiUsageLevel.basic,
    SherpiContext.dailyGreeting: AiUsageLevel.basic,
    SherpiContext.encouragement: AiUsageLevel.basic,
  };
  
  /// 🎮 메인 메시지 가져오기 함수 (Phase 2: 활동별 데이터 수집 포함)
  /// 
  /// 단순화된 3단계 AI 시스템으로 95%+ 즉시 응답을 보장합니다.
  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 🎯 Phase 2: 활동별 데이터 수집 및 userContext 강화
    Map<String, dynamic>? enhancedUserContext = userContext;
    if (_dataCollector != null && userContext != null) {
      enhancedUserContext = _enhanceUserContextWithActivityData(context, userContext);
    }
    
    final aiLevel = _aiUsageLevels[context] ?? AiUsageLevel.basic;
    
    // 🚀 빠른 경로: basic 레벨은 대부분 정적 메시지 (95% 케이스)
    if (aiLevel == AiUsageLevel.basic) {
      final aiUsageRate = _getAIUsageRateByIntimacy();
      final frequencyMultiplier = _personalizationSettings.messageFrequencyMultiplier;
      final randomChance = DateTime.now().millisecond / 1000.0;
      
      // Phase 2: 메시지 빈도 설정이 최소일 때 AI 메시지 확률을 낮춤
      if (frequencyMultiplier <= 0.3 && randomChance < 0.7) {
        return Future.value(_getStaticMessageSync(context, userContext, gameContext));
      }
      
      // 🎯 Phase 2 개선: AI 사용률 증가 (15% → 40%)
      if (randomChance < 0.40 + aiUsageRate * 0.1) { // 40% + 친밀도 & 성격 보너스
        return await _getAIMessage(context, enhancedUserContext, gameContext);
      } else {
        return Future.value(_getStaticMessageSync(context, enhancedUserContext, gameContext));
      }
    }
    
    // ⚡ 단순화된 AI 결정
    final shouldUseAI = _shouldUseAI(context, aiLevel);
    
    if (shouldUseAI) {
      return await _getAIMessage(context, enhancedUserContext, gameContext);
    } else {
      return Future.value(_getStaticMessageSync(context, enhancedUserContext, gameContext));
    }
  }


  /// ⚡ Phase 2: 개인화 설정을 반영한 AI 결정 (확률 기반)
  bool _shouldUseAI(SherpiContext context, AiUsageLevel level) {
    // 🐛 디버그 모드일 때는 항상 AI 사용
    if (debugForceAI) {
      print('🐛 디버그 모드: AI 응답 강제 사용');
      return true;
    }
    
    final randomValue = DateTime.now().millisecond / 1000.0;
    final intimacyBonus = _intimacyLevel * 0.05; // 레벨당 5% 보너스
    final frequencyMultiplier = _personalizationSettings.messageFrequencyMultiplier;
    
    // 활동 완료 컨텍스트는 항상 AI 사용
    if (context == SherpiContext.exerciseComplete ||
        context == SherpiContext.studyComplete ||
        context == SherpiContext.diaryWritten) {
      return true; // 활동 완료 시 100% AI 사용
    }
    
    // 메시지 빈도가 최소일 때는 프리미엄 상황에서도 AI 사용률을 줄임
    final frequencyAdjustment = frequencyMultiplier < 0.5 ? -0.2 : 0.0;
    
    switch (level) {
      case AiUsageLevel.premium:
        return true; // 프리미엄 레벨은 항상 AI 사용 (100%)
        
      case AiUsageLevel.smart:
        // 🎯 스마트 AI 사용률 증가 (60% → 80%)
        final baseRate = 0.80 + intimacyBonus * 0.5 + (frequencyAdjustment * 0.5);
        return randomValue < baseRate.clamp(0.0, 1.0); // 80% + 보너스
        
      case AiUsageLevel.basic:
        return false; // 이미 위에서 처리됨 (40% 확률)
    }
  }


  /// 🤖 AI 메시지 가져오기 (캐시 → 실시간 → 정적 폴백)
  Future<SherpiResponse> _getAIMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    try {
      // 1️⃣ 캐시된 메시지 확인 (0ms - 즉시 응답)
      final cachedMessage = await _cache.getCachedMessage(
        context, 
        userContext ?? {}
      );
      
      if (cachedMessage != null) {
        return SherpiResponse(
          message: cachedMessage,
          source: MessageSource.aiCached,
          responseTime: DateTime.now(),
          generationDuration: Duration.zero, // 즉시 응답
        );
      }
      
      // 2️⃣ Phase 2: 개인화 설정을 포함한 실시간 AI 생성 (2-4초 소요)
      final startTime = DateTime.now();
      
      // 개인화 설정을 gameContext에 추가하여 AI에게 전달
      final enhancedGameContext = {
        ...gameContext ?? {},
        'personalityType': _personalizationSettings.personalityType.displayName,
        'personalityTone': _personalizationSettings.personalityToneGuide,
        'sherpiNickname': _personalizationSettings.nickname,
        'userPreferredName': _personalizationSettings.userPreferredName,
        'useEmojis': _personalizationSettings.useEmojisInMessages,
        'enablePersonalizedTone': _personalizationSettings.enablePersonalizedTone,
      };
      
      final aiMessage = await _geminiSource.getDialogue(
        context, 
        userContext, 
        enhancedGameContext
      );
      
      final responseTime = DateTime.now().difference(startTime);
      
      return SherpiResponse(
        message: aiMessage,
        source: MessageSource.aiRealtime,
        responseTime: startTime,
        generationDuration: responseTime,
      );
      
    } catch (e) {
      return Future.value(_getStaticMessageSync(context, userContext, gameContext));
    }
  }
  
  /// ⚡ Phase 2: 개인화 설정을 반영한 동기식 정적 메시지 (0ms - 진짜 즉시 응답)
  SherpiResponse _getStaticMessageSync(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    // 성격 유형별 기본 메시지 템플릿
    final baseMessages = _getPersonalizedStaticMessages(context);
    
    String message = baseMessages[context] ?? '멋진 하루 보내세요!';
    
    // 사용자 이름으로 개인화
    if (_personalizationSettings.userPreferredName != '친구') {
      message = message.replaceAll('${_personalizationSettings.userPreferredName}님', '${_personalizationSettings.userPreferredName}님');
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
  
  /// Phase 2: 성격 유형별 정적 메시지 생성
  Map<SherpiContext, String> _getPersonalizedStaticMessages(SherpiContext context) {
    switch (_personalizationSettings.personalityType) {
      case SherpiPersonalityType.energetic:
        return {
          // 🎯 Phase 1 개선: 컨텍스트별 메시지 10개 이상으로 확대
          SherpiContext.welcome: '와! ${_personalizationSettings.userPreferredName}님! 셰르파에 오신 걸 환영해요!! 🎉✨',
          SherpiContext.dailyGreeting: '${_personalizationSettings.userPreferredName}님! 오늘도 에너지 넘치게 파이팅!! 💪🔥',
          SherpiContext.encouragement: '우와! 정말 잘하고 있어요! 계속 달려봐요!! ✨🚀',
          SherpiContext.levelUp: '와아! 레벨업이에요!! 너무 멋져요!! 🎊🏆',
          SherpiContext.exerciseComplete: '운동 완료!! 최고예요!! 💪⚡',
          SherpiContext.studyComplete: '공부 완료!! ${_personalizationSettings.userPreferredName}님 대단해요!! 📚🌟',
          SherpiContext.questComplete: '퀘스트 클리어!! 완전 프로 실력이에요!! 🎯🎉',
          SherpiContext.climbingSuccess: '등반 성공!! 정상에서 보는 뷰가 최고죠!! 🏔️✨',
          SherpiContext.badgeEarned: '뱃지 획득!! ${_personalizationSettings.userPreferredName}님 컬렉션이 늘어나고 있어요!! 🏅✨',
          SherpiContext.statIncrease: '스탯 업!! 더 강해지고 있어요!! 💪📈',
          SherpiContext.diaryWritten: '일기 작성 완료!! 오늘의 감정이 소중해요!! 📝💝',
          SherpiContext.longTimeNoSee: '${_personalizationSettings.userPreferredName}님!! 정말 오랜만이에요!! 너무 보고 싶었어요!! 🤗💕',
        };
      case SherpiPersonalityType.calm:
        return {
          // 🎯 Phase 1 개선: 컨텍스트별 메시지 10개 이상으로 확대
          SherpiContext.welcome: '안녕하세요 ${_personalizationSettings.userPreferredName}님. 셰르파에 오신 것을 환영합니다. 🌱',
          SherpiContext.dailyGreeting: '${_personalizationSettings.userPreferredName}님, 오늘도 차근차근 해보아요. ☺️',
          SherpiContext.encouragement: '${_personalizationSettings.userPreferredName}님은 이미 충분히 잘하고 계세요. 🌸',
          SherpiContext.levelUp: '레벨업을 축하드립니다. 꾸준한 노력의 결과네요. 🌟',
          SherpiContext.exerciseComplete: '운동을 완료하셨네요. 몸과 마음이 건강해지고 있어요. 💚',
          SherpiContext.studyComplete: '학습을 마치셨네요. ${_personalizationSettings.userPreferredName}님의 지식이 깊어지고 있습니다. 📖',
          SherpiContext.questComplete: '퀘스트를 완료하셨습니다. 한 걸음 한 걸음이 모두 의미 있어요. 🎯',
          SherpiContext.climbingSuccess: '정상에 도달하셨네요. 여유를 가지고 경치를 즐겨보세요. 🏔️',
          SherpiContext.badgeEarned: '새로운 뱃지를 획득하셨습니다. ${_personalizationSettings.userPreferredName}님의 성장이 보입니다. 🏅',
          SherpiContext.statIncrease: '능력치가 향상되었습니다. 내면의 성장이 느껴지네요. 📊',
          SherpiContext.diaryWritten: '오늘의 기록을 남기셨네요. 소중한 하루였길 바랍니다. 📝',
          SherpiContext.longTimeNoSee: '${_personalizationSettings.userPreferredName}님, 오랜만입니다. 편안한 마음으로 돌아오셨길 바라요. 🌿',
        };
      case SherpiPersonalityType.humorous:
        return {
          // 🎯 Phase 1 개선: 컨텍스트별 메시지 10개 이상으로 확대
          SherpiContext.welcome: '어머! ${_personalizationSettings.userPreferredName}님이 오셨네요! 셰르파가 더 즐거워졌어요! 🎭',
          SherpiContext.dailyGreeting: '${_personalizationSettings.userPreferredName}님! 오늘 기분은 어때요? 저는 1일 1깡 할 기분이에요! 😄',
          SherpiContext.encouragement: '${_personalizationSettings.userPreferredName}님! 이 정도면 셰르피보다 더 능력자인걸요? 😉',
          SherpiContext.levelUp: '레벨업! 축하해요! 이제 저랑 수평선상에서 만나는 건가요? 😂🎉',
          SherpiContext.exerciseComplete: '운동 완료! 땀 한 방울 한 방울이 다 보석이에요! ✨💎',
          SherpiContext.studyComplete: '공부 끝! ${_personalizationSettings.userPreferredName}님 뇌가 빛나고 있어요! 번쩍번쩍! 🧠✨',
          SherpiContext.questComplete: '퀘스트 깨기! 이제 ${_personalizationSettings.userPreferredName}님은 퀘스트 브레이커! 🎮😎',
          SherpiContext.climbingSuccess: '정상 도착! 이제 산이 ${_personalizationSettings.userPreferredName}님을 올려다보고 있을걸요? 🏔️😂',
          SherpiContext.badgeEarned: '뱃지 겟! 이러다 뱃지 부자 되겠어요! 💰🏅',
          SherpiContext.statIncrease: '스탯 상승! 파워가 9000을 넘어가려 하네요! 💪9️⃣0️⃣0️⃣0️⃣',
          SherpiContext.diaryWritten: '일기 완성! 오늘의 ${_personalizationSettings.userPreferredName}님 스토리, 베스트셀러감이에요! 📚😊',
          SherpiContext.longTimeNoSee: '${_personalizationSettings.userPreferredName}님! 어디 계셨어요? 셰르피가 기다리다가 돌이 될 뻔했어요! 🗿😅',
        };
      case SherpiPersonalityType.serious:
        return {
          // 🎯 Phase 1 개선: 컨텍스트별 메시지 10개 이상으로 확대
          SherpiContext.welcome: '${_personalizationSettings.userPreferredName}님, 셰르파 시스템에 접속하신 것을 환영합니다. 📋',
          SherpiContext.dailyGreeting: '${_personalizationSettings.userPreferredName}님, 오늘의 목표를 달성해보세요. 🎯',
          SherpiContext.encouragement: '${_personalizationSettings.userPreferredName}님의 현재 진행상황은 양호합니다. 계속 진행하시기 바랍니다. 📊',
          SherpiContext.levelUp: '레벨 상승을 확인했습니다. 체계적인 성장을 보이고 계십니다. 📈',
          SherpiContext.exerciseComplete: '운동 세션이 완료되었습니다. 규칙적인 운동이 건강 유지의 핵심입니다. ✅',
          SherpiContext.studyComplete: '학습 목표를 달성하셨습니다. ${_personalizationSettings.userPreferredName}님의 지식 습득률이 향상되고 있습니다. 📚',
          SherpiContext.questComplete: '퀘스트가 완료되었습니다. 목표 달성률이 상승했습니다. ✓',
          SherpiContext.climbingSuccess: '등반이 성공적으로 완료되었습니다. 계획적인 접근이 좋은 결과를 가져왔습니다. 🏔️',
          SherpiContext.badgeEarned: '새로운 뱃지를 획득하셨습니다. ${_personalizationSettings.userPreferredName}님의 성과가 인정받았습니다. 🏅',
          SherpiContext.statIncrease: '능력치가 상향 조정되었습니다. 지속적인 개선이 확인됩니다. 📊',
          SherpiContext.diaryWritten: '일일 기록이 저장되었습니다. 꾸준한 기록이 성장의 지표가 됩니다. 📝',
          SherpiContext.longTimeNoSee: '${_personalizationSettings.userPreferredName}님, 재접속을 환영합니다. 그동안의 데이터가 보존되어 있습니다. 📂',
        };
      default: // balanced
        return {
          // 🎯 Phase 1 개선: 컨텍스트별 메시지 10개 이상으로 확대
          SherpiContext.welcome: '안녕하세요 ${_personalizationSettings.userPreferredName}님! 셰르파에 오신 것을 환영해요! 🎉',
          SherpiContext.dailyGreeting: '${_personalizationSettings.userPreferredName}님, 오늘도 화이팅! 💪',
          SherpiContext.encouragement: '${_personalizationSettings.userPreferredName}님, 잘하고 있어요! 계속해봐요! ✨',
          SherpiContext.levelUp: '레벨업 축하드려요! 🚀',
          SherpiContext.exerciseComplete: '운동 완료! 수고하셨어요! 💪',
          SherpiContext.studyComplete: '공부 완료! ${_personalizationSettings.userPreferredName}님 정말 열심히 하셨네요! 📚',
          SherpiContext.questComplete: '퀘스트 완료! 오늘도 목표를 달성하셨네요! 🎯',
          SherpiContext.climbingSuccess: '등반 성공! 정상에서의 기분이 어떠신가요? 🏔️',
          SherpiContext.badgeEarned: '뱃지 획득! ${_personalizationSettings.userPreferredName}님의 또 다른 성취예요! 🏅',
          SherpiContext.statIncrease: '스탯이 올랐어요! 점점 더 강해지고 있네요! 💪',
          SherpiContext.diaryWritten: '일기 작성 완료! 오늘 하루도 의미있었길 바라요. 📝',
          SherpiContext.longTimeNoSee: '${_personalizationSettings.userPreferredName}님, 오랜만이에요! 다시 만나서 반가워요! 😊',
        };
    }
  }
  
  /// 이모지 제거 유틸리티 함수
  String _removeEmojis(String text) {
    return text.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]', unicode: true), '').trim();
  }
  
  /// 🎯 Phase 2: 활동별 데이터로 UserContext 강화
  Map<String, dynamic> _enhanceUserContextWithActivityData(
    SherpiContext context,
    Map<String, dynamic> userContext,
  ) {
    if (_dataCollector == null) return userContext;
    
    // 기존 userContext 복사
    final enhanced = Map<String, dynamic>.from(userContext);
    
    // 컨텍스트별 활동 데이터 수집
    Map<String, dynamic>? activityData;
    
    switch (context) {
      case SherpiContext.exerciseComplete:
        // 운동 데이터가 userContext에 있다고 가정
        if (userContext['exerciseType'] != null) {
          activityData = _dataCollector!.collectExerciseData(
            exerciseType: userContext['exerciseType'] ?? 'general',
            durationMinutes: userContext['durationMinutes'] ?? 30,
            intensity: userContext['intensity'] ?? 'medium',
            additionalData: userContext,
          );
        }
        break;
        
      case SherpiContext.studyComplete:
        // 독서 데이터가 userContext에 있다고 가정
        if (userContext['bookTitle'] != null) {
          activityData = _dataCollector!.collectStudyData(
            bookTitle: userContext['bookTitle'] ?? 'Unknown Book',
            pages: userContext['pages'] ?? 10,
            rating: userContext['rating']?.toDouble(),
            genre: userContext['genre'],
            additionalData: userContext,
          );
        }
        break;
        
      case SherpiContext.diaryWritten:
        // 일기 데이터가 userContext에 있다고 가정
        if (userContext['mood'] != null) {
          activityData = _dataCollector!.collectDiaryData(
            mood: userContext['mood'] ?? 'normal',
            content: userContext['content'] ?? '',
            tags: userContext['tags'] as List<String>?,
            additionalData: userContext,
          );
        }
        break;
        
      case SherpiContext.questComplete:
        // 퀘스트 데이터가 userContext에 있다고 가정
        if (userContext['questName'] != null) {
          activityData = _dataCollector!.collectQuestData(
            questName: userContext['questName'] ?? 'Quest',
            questType: userContext['questType'] ?? 'daily',
            rewardPoints: userContext['rewardPoints'] ?? 100,
            difficulty: userContext['difficulty'] ?? 'normal',
            additionalData: userContext,
          );
        }
        break;
        
      case SherpiContext.climbingSuccess:
        // 등반 데이터가 userContext에 있다고 가정
        if (userContext['mountainName'] != null) {
          activityData = _dataCollector!.collectClimbingData(
            mountainName: userContext['mountainName'] ?? 'Unknown Mountain',
            progress: userContext['progress'] ?? 0.0,
            isSuccess: userContext['isSuccess'] ?? false,
            additionalData: userContext,
          );
        }
        break;
        
      case SherpiContext.meetingJoined:
        // 모임 데이터가 userContext에 있다고 가정
        if (userContext['meetingTitle'] != null) {
          activityData = _dataCollector!.collectMeetingData(
            meetingTitle: userContext['meetingTitle'] ?? 'Meeting',
            meetingType: userContext['meetingType'] ?? 'social',
            participants: userContext['participants'] ?? 5,
            additionalData: userContext,
          );
        }
        break;
        
      default:
        // 다른 컨텍스트는 활동 데이터가 필요 없음
        break;
    }
    
    // 활동 데이터가 수집되었으면 userContext에 추가
    if (activityData != null) {
      enhanced['activityData'] = activityData;
      print('📊 Phase 2: 활동별 데이터 수집 완료 - ${context.name}');
    }
    
    return enhanced;
  }


  
  /// 🔄 백그라운드 캐시 생성 시작 (개인화 지원)
  Future<void> startBackgroundCaching(
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
  ) async {
    // 임시로 백그라운드 캐싱 비활성화 - 테스트 중
    print('⚠️ 백그라운드 캐시 생성이 임시로 비활성화되었습니다.');
    
    // 기본 백그라운드 캐싱만 사용 (개인화 기능 제거됨)
    // unawaited(_cache.pregenerateImportantMessages(
    //   currentUserContext: userContext,
    //   currentGameContext: gameContext,
    // ));
  }
  
  /// 📊 시스템 상태 확인
  Future<Map<String, dynamic>> getSystemStatus() async {
    final cacheStatus = await _cache.getCacheStatus();
    
    return {
      'cache': cacheStatus,
      'ai_usage_levels': _aiUsageLevels.length,
      'intimacy_level': _intimacyLevel,
      'last_update': DateTime.now().toIso8601String(),
    };
  }
}

/// 🎯 AI 사용 레벨 정의 (단순화된 3단계)
enum AiUsageLevel {
  /// 🌟 프리미엄 AI (80% AI 사용)
  /// - 캐시 우선 → 실시간 AI → 정적 폴백
  /// - 중요한 순간들: 환영, 재복귀, 특별 성취
  premium,
  
  /// ⭐ 스마트 AI (15% AI 사용)
  /// - 캐시 우선 → 실시간 AI
  /// - 특별한 달성: 뱃지 획득, 퀘스트 완료, 등반 성공
  smart,
  
  /// 💬 기본 메시지 (5% AI 사용)
  /// - 95%: 정적 메시지 (즉시)
  /// - 5%: 무작위 AI (친밀도 반영)
  /// - 일상적 상호작용
  basic,
}

/// 📨 셰르피 응답 데이터
class SherpiResponse {
  final String message;
  final MessageSource source;
  final DateTime responseTime;
  final Duration? generationDuration;
  final Map<String, dynamic> metadata;
  
  SherpiResponse({
    required this.message,
    required this.source,
    required this.responseTime,
    this.generationDuration,
    this.metadata = const {},
  });
  
  /// ⚡ 빠른 응답인지 확인 (1초 이내)
  bool get isFastResponse {
    return generationDuration == null || 
           generationDuration!.inMilliseconds < 1000;
  }

  /// 💾 캐시 히트 여부
  bool get isCacheHit {
    return source == MessageSource.aiCached;
  }
}

/// 📝 메시지 소스 타입
enum MessageSource {
  static,      // 정적 메시지 (즉시)
  aiCached,    // AI 캐시 (즉시)
  aiRealtime,  // AI 실시간 (2-4초)
}