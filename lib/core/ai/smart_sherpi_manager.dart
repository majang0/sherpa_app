import 'dart:async';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/ai_message_cache.dart';
import 'package:sherpa_app/core/ai/enhanced_gemini_dialogue_source.dart';
// Personalized smart sherpi manager removed

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

  /// 생성자
  SmartSherpiManager();
  
  /// 친밀도 레벨 설정
  void setIntimacyLevel(int level) {
    _intimacyLevel = level.clamp(1, 10);
  }
  
  /// 친밀도 레벨에 따른 AI 사용 비율 계산
  double _getAIUsageRateByIntimacy() {
    // 친밀도 1: 10% → 친밀도 10: 40%
    return 0.1 + (_intimacyLevel - 1) * 0.033;
  }
  
  /// 🎯 AI 사용 기준 정의 (단순화된 3단계 시스템)
  static const Map<SherpiContext, AiUsageLevel> _aiUsageLevels = {
    // 🌟 프리미엄: 감정적 연결이 중요한 순간 (80% AI)
    SherpiContext.welcome: AiUsageLevel.premium,
    SherpiContext.longTimeNoSee: AiUsageLevel.premium,
    SherpiContext.levelUp: AiUsageLevel.premium,  // 모든 레벨업을 premium으로
    SherpiContext.milestone: AiUsageLevel.premium,
    SherpiContext.specialEvent: AiUsageLevel.premium,
    
    // ⭐ 스마트: 특별한 성취 순간 (15% AI)
    SherpiContext.badgeEarned: AiUsageLevel.smart,
    SherpiContext.climbingSuccess: AiUsageLevel.smart,
    SherpiContext.questComplete: AiUsageLevel.smart,
    SherpiContext.achievement: AiUsageLevel.smart,
    SherpiContext.exerciseComplete: AiUsageLevel.smart,
    SherpiContext.studyComplete: AiUsageLevel.smart,
    
    // 💬 기본: 일상적 상호작용 (5% AI)
    SherpiContext.general: AiUsageLevel.basic,
    SherpiContext.guidance: AiUsageLevel.basic,
    SherpiContext.dailyGreeting: AiUsageLevel.basic,
    SherpiContext.encouragement: AiUsageLevel.basic,
  };
  
  /// 🎮 메인 메시지 가져오기 함수 (단순화된 3단계)
  /// 
  /// 단순화된 3단계 AI 시스템으로 95%+ 즉시 응답을 보장합니다.
  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    final aiLevel = _aiUsageLevels[context] ?? AiUsageLevel.basic;
    
    // 🚀 빠른 경로: basic 레벨은 대부분 정적 메시지 (95% 케이스)
    if (aiLevel == AiUsageLevel.basic) {
      final aiUsageRate = _getAIUsageRateByIntimacy();
      final randomChance = DateTime.now().millisecond / 1000.0;
      
      if (randomChance < 0.05 + aiUsageRate * 0.05) { // 5% + 친밀도 보너스
        return await _getAIMessage(context, userContext, gameContext);
      } else {
        return Future.value(_getStaticMessageSync(context, userContext, gameContext));
      }
    }
    
    // ⚡ 단순화된 AI 결정
    final shouldUseAI = _shouldUseAI(context, aiLevel);
    
    if (shouldUseAI) {
      return await _getAIMessage(context, userContext, gameContext);
    } else {
      return Future.value(_getStaticMessageSync(context, userContext, gameContext));
    }
  }


  /// ⚡ 단순화된 AI 결정 (확률 기반)
  bool _shouldUseAI(SherpiContext context, AiUsageLevel level) {
    final randomValue = DateTime.now().millisecond / 1000.0;
    final intimacyBonus = _intimacyLevel * 0.05; // 레벨당 5% 보너스
    
    switch (level) {
      case AiUsageLevel.premium:
        return randomValue < (0.8 + intimacyBonus).clamp(0.0, 1.0); // 80% + 보너스
        
      case AiUsageLevel.smart:
        return randomValue < (0.15 + intimacyBonus * 0.5).clamp(0.0, 1.0); // 15% + 작은 보너스
        
      case AiUsageLevel.basic:
        return false; // 이미 위에서 처리됨
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
      
      // 2️⃣ 실시간 AI 생성 (2-4초 소요)
      final startTime = DateTime.now();
      
      final aiMessage = await _geminiSource.getDialogue(
        context, 
        userContext, 
        gameContext
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
  
  /// ⚡ 동기식 정적 메시지 (0ms - 진짜 즉시 응답)
  SherpiResponse _getStaticMessageSync(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) {
    // 간단한 정적 메시지 직접 반환 (async 제거)
    final quickMessages = {
      SherpiContext.welcome: '안녕하세요! 셰르파에 오신 것을 환영해요! 🎉',
      SherpiContext.dailyGreeting: '오늘도 화이팅! 💪',
      SherpiContext.encouragement: '잘하고 있어요! 계속해봐요! ✨',
      SherpiContext.general: '도움이 필요하면 언제든 말씀해주세요! 😊',
      SherpiContext.guidance: '단계별로 천천히 해보세요! 📚',
      SherpiContext.levelUp: '레벨업 축하드려요! 🚀',
      SherpiContext.exerciseComplete: '운동 완료! 수고하셨어요! 💪',
      SherpiContext.studyComplete: '독서 완료! 지식이 늘었어요! 📖',
      SherpiContext.questComplete: '퀘스트 완료! 멋져요! ⭐',
    };
    
    final message = quickMessages[context] ?? '멋진 하루 보내세요! 🌟';
    
    return SherpiResponse(
      message: message,
      source: MessageSource.static,
      responseTime: DateTime.now(),
      generationDuration: Duration.zero,
    );
  }


  
  /// 🔄 백그라운드 캐시 생성 시작 (개인화 지원)
  Future<void> startBackgroundCaching(
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
  ) async {
    // 기본 백그라운드 캐싱만 사용 (개인화 기능 제거됨)
    unawaited(_cache.pregenerateImportantMessages(
      currentUserContext: userContext,
      currentGameContext: gameContext,
    ));
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