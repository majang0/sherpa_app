import 'dart:async';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/ai_message_cache.dart';
import 'package:sherpa_app/core/ai/gemini_dialogue_source.dart';

// Add unawaited function for background operations
void unawaited(Future<void> future) {
  // Deliberately not awaiting the future to allow background execution
}

/// 🧠 스마트 셰르피 매니저
/// 
/// AI와 정적 메시지를 지능적으로 조합하여 최적의 사용자 경험을 제공합니다.
class SmartSherpiManager {
  final AiMessageCache _cache = AiMessageCache();
  final GeminiDialogueSource _geminiSource = GeminiDialogueSource();
  final StaticDialogueSource _staticSource = StaticDialogueSource();
  
  /// 🎯 AI 사용 기준 정의 (명확한 우선순위와 조건)
  static const Map<SherpiContext, AiUsageLevel> _aiUsageLevels = {
    // 🔥 항상 AI 사용 (100% AI, 캐시 우선 → 실시간)
    // - 첫 설치, 재복귀, 특별한 순간들
    // - 감정적 연결이 가장 중요한 순간
    SherpiContext.welcome: AiUsageLevel.always,           // 첫 만남, 재복귀
    SherpiContext.longTimeNoSee: AiUsageLevel.always,     // 7일+ 미접속 후 복귀
    SherpiContext.milestone: AiUsageLevel.always,         // 100일, 365일 등 기념일
    SherpiContext.specialEvent: AiUsageLevel.always,      // 생일, 기념일
    
    // ⭐ 중요할 때만 AI 사용 (조건부 AI, 캐시 우선)
    // - 특별한 성취나 중요한 레벨업만
    // - 조건 미달 시 정적 메시지 사용
    SherpiContext.levelUp: AiUsageLevel.important,        // 10, 20, 50, 100레벨만
    SherpiContext.badgeEarned: AiUsageLevel.important,    // 첫 3개 뱃지만
    SherpiContext.climbingSuccess: AiUsageLevel.important,// 첫 성공, 어려운 산
    SherpiContext.achievement: AiUsageLevel.important,    // 특별 성취만
    
    // 📱 가끔 AI 사용 (특별 조건만, 캐시 필수)
    // - 연속 달성이나 milestone 활동만
    // - 캐시 없으면 정적 메시지 사용
    SherpiContext.exerciseComplete: AiUsageLevel.occasional, // 7일, 30일 연속만
    SherpiContext.studyComplete: AiUsageLevel.occasional,    // 100회, 500회 달성만
    SherpiContext.questComplete: AiUsageLevel.occasional,    // 특별 퀘스트만
    
    // 💬 기본적으로 정적 메시지 (99% 정적, 1% 깜짝 AI)
    // - 일상적인 상호작용
    // - 빠른 응답이 우선
    SherpiContext.general: AiUsageLevel.rarely,          // 일반 상호작용
    SherpiContext.guidance: AiUsageLevel.rarely,         // 안내 메시지
    SherpiContext.dailyGreeting: AiUsageLevel.rarely,    // 일상 인사
    SherpiContext.encouragement: AiUsageLevel.rarely,    // 일반 격려
  };
  
  /// 🎮 메인 메시지 가져오기 함수 (최적화된 버전)
  /// 
  /// 성능 최우선: 90%+ 즉시 응답을 보장합니다.
  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    final aiLevel = _aiUsageLevels[context] ?? AiUsageLevel.rarely;
    
    // 🚀 빠른 경로: rarely 레벨은 즉시 정적 메시지 (90% 케이스)
    if (aiLevel == AiUsageLevel.rarely) {
      // 1% 확률로만 AI 사용
      if (DateTime.now().millisecond % 100 == 0) {
        return await _getAIMessage(context, userContext, gameContext);
      } else {
        return _getStaticMessageSync(context, userContext, gameContext);
      }
    }
    
    // ⚡ 빠른 AI 결정 (복잡한 로직 최소화)
    final shouldUseAI = _shouldUseAIFast(context, aiLevel, userContext);
    
    if (shouldUseAI) {
      // occasional은 캐시만, 나머지는 전체 AI
      if (aiLevel == AiUsageLevel.occasional) {
        return await _getCachedAIOnly(context, userContext, gameContext);
      } else {
        return await _getAIMessage(context, userContext, gameContext);
      }
    } else {
      return _getStaticMessageSync(context, userContext, gameContext);
    }
  }

  /// ⚡ 빠른 AI 결정 (복잡한 async 제거)
  bool _shouldUseAIFast(
    SherpiContext context,
    AiUsageLevel level,
    Map<String, dynamic>? userContext,
  ) {
    switch (level) {
      case AiUsageLevel.always:
        return true;
        
      case AiUsageLevel.important:
        return _isImportantMomentFast(context, userContext);
        
      case AiUsageLevel.occasional:
        return _isSpecialConditionFast(context, userContext);
        
      case AiUsageLevel.rarely:
        return false; // 이미 위에서 처리됨
    }
  }

  /// ⚡ 빠른 중요 순간 판단
  bool _isImportantMomentFast(SherpiContext context, Map<String, dynamic>? userContext) {
    switch (context) {
      case SherpiContext.levelUp:
        final level = int.tryParse(userContext?['레벨']?.toString() ?? '1') ?? 1;
        return level == 1 || level == 5 || level % 10 == 0;
        
      case SherpiContext.badgeEarned:
        final totalBadges = userContext?['총_뱃지_수'] ?? 0;
        return totalBadges <= 3;
        
      case SherpiContext.climbingSuccess:
        final totalClimbs = userContext?['총_등반_수'] ?? 0;
        return totalClimbs <= 3;
        
      case SherpiContext.achievement:
        final totalAchievements = userContext?['총_성취_수'] ?? 0;
        return totalAchievements <= 5;
        
      default:
        return false;
    }
  }

  /// ⚡ 빠른 특별 조건 판단
  bool _isSpecialConditionFast(SherpiContext context, Map<String, dynamic>? userContext) {
    switch (context) {
      case SherpiContext.exerciseComplete:
        final consecutiveDays = userContext?['연속_운동일'] ?? 0;
        final totalExercise = userContext?['총_운동_수'] ?? 0;
        return consecutiveDays == 7 || consecutiveDays == 30 || 
               totalExercise == 100 || totalExercise == 500;
               
      case SherpiContext.studyComplete:
        final consecutiveDays = userContext?['연속_독서일'] ?? 0;
        final totalBooks = userContext?['총_독서_수'] ?? 0;
        return consecutiveDays == 7 || consecutiveDays == 30 ||
               totalBooks == 50 || totalBooks == 100;
               
      case SherpiContext.questComplete:
        final questType = userContext?['퀘스트_타입'] ?? '';
        return questType == 'special' || questType == 'premium';
               
      default:
        final consecutiveDays = userContext?['연속_접속일'] ?? 0;
        return consecutiveDays == 7 || consecutiveDays == 30;
    }
  }
  
  /// 📱 캐시된 AI만 가져오기 (occasional 전용 - 실시간 AI 제외)
  Future<SherpiResponse> _getCachedAIOnly(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 캐시된 메시지만 확인, 없으면 바로 정적 메시지 사용
    final cachedMessage = await _cache.getCachedMessage(
      context, 
      userContext ?? {}
    );
    
    if (cachedMessage != null) {
      return SherpiResponse(
        message: cachedMessage,
        source: MessageSource.aiCached,
        responseTime: DateTime.now(),
        generationDuration: Duration.zero,
      );
    } else {
      return _getStaticMessageSync(context, userContext, gameContext);
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
      return _getStaticMessageSync(context, userContext, gameContext);
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

  /// 💬 정적 메시지 가져오기 (async 버전 - 필요시에만 사용)
  Future<SherpiResponse> _getStaticMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    final staticMessage = await _staticSource.getDialogue(
      context, 
      userContext, 
      gameContext
    );
    
    return SherpiResponse(
      message: staticMessage,
      source: MessageSource.static,
      responseTime: DateTime.now(),
      generationDuration: Duration.zero,
    );
  }
  
  /// 🎯 AI 사용 여부 결정 로직 (명확한 기준)
  Future<bool> _shouldUseAI(
    SherpiContext context,
    AiUsageLevel level,
    Map<String, dynamic>? userContext,
  ) async {
    print('🤔 AI 사용 결정: ${context.name} (${level.name})');
    
    switch (level) {
      case AiUsageLevel.always:
        // 🔥 항상 AI 사용: 특별한 순간들
        print('✅ 항상 AI 사용 - 특별한 순간');
        return true;
        
      case AiUsageLevel.important:
        // ⭐ 조건부 AI 사용: 중요한 성취만
        final shouldUse = _isImportantMoment(context, userContext);
        print('${shouldUse ? '✅' : '❌'} 중요한 순간 ${shouldUse ? '맞음' : '아님'} - AI ${shouldUse ? '사용' : '미사용'}');
        return shouldUse;
        
      case AiUsageLevel.occasional:
        // 📱 특별 조건부 AI: milestone 달성만
        final shouldUse = _isSpecialCondition(context, userContext);
        print('${shouldUse ? '✅' : '❌'} 특별 조건 ${shouldUse ? '충족' : '미충족'} - AI ${shouldUse ? '사용' : '미사용'}');
        return shouldUse;
        
      case AiUsageLevel.rarely:
        // 💬 거의 정적: 1% 확률로만 AI
        final isLucky = DateTime.now().millisecond % 100 == 0;
        print('${isLucky ? '🎰' : '⚡'} 깜짝 AI ${isLucky ? '당첨!' : '정적 메시지 사용'}');
        return isLucky;
    }
  }

  /// ⭐ 중요한 순간인지 판단
  bool _isImportantMoment(SherpiContext context, Map<String, dynamic>? userContext) {
    switch (context) {
      case SherpiContext.levelUp:
        // 특별한 레벨만: 1, 5, 10, 20, 30, 50, 100...
        final level = int.tryParse(userContext?['레벨']?.toString() ?? '1') ?? 1;
        return level == 1 || level == 5 || level % 10 == 0;
        
      case SherpiContext.badgeEarned:
        // 첫 3개 뱃지만 AI로 축하
        final totalBadges = userContext?['총_뱃지_수'] ?? 0;
        return totalBadges <= 3;
        
      case SherpiContext.climbingSuccess:
        // 첫 성공이거나 어려운 산(성공률 30% 이하)
        final totalClimbs = userContext?['총_등반_수'] ?? 0;
        final successRate = double.tryParse(userContext?['등반_성공률']?.toString() ?? '50') ?? 50;
        return totalClimbs <= 3 || successRate <= 30;
        
      case SherpiContext.achievement:
        // 첫 5개 성취만
        final totalAchievements = userContext?['총_성취_수'] ?? 0;
        return totalAchievements <= 5;
        
      default:
        return false;
    }
  }
  
  
  /// ✨ 특별한 조건인지 확인 (milestone 달성)
  bool _isSpecialCondition(SherpiContext context, Map<String, dynamic>? userContext) {
    switch (context) {
      case SherpiContext.exerciseComplete:
        // 운동: 연속 7일, 30일, 100일 또는 총 100회, 500회 달성
        final consecutiveExercise = userContext?['연속_운동일'] ?? 0;
        final totalExercise = userContext?['총_운동_수'] ?? 0;
        return consecutiveExercise == 7 || 
               consecutiveExercise == 30 || 
               consecutiveExercise == 100 ||
               totalExercise == 100 || 
               totalExercise == 500;
               
      case SherpiContext.studyComplete:
        // 독서: 연속 7일, 30일 또는 총 50권, 100권 달성
        final consecutiveReading = userContext?['연속_독서일'] ?? 0;
        final totalBooks = userContext?['총_독서_수'] ?? 0;
        return consecutiveReading == 7 || 
               consecutiveReading == 30 ||
               totalBooks == 50 || 
               totalBooks == 100;
               
      case SherpiContext.questComplete:
        // 퀘스트: 연속 완료 7일, 30일 또는 특별 퀘스트 완료
        final consecutiveQuests = userContext?['연속_퀘스트일'] ?? 0;
        final questType = userContext?['퀘스트_타입'] ?? '';
        return consecutiveQuests == 7 || 
               consecutiveQuests == 30 ||
               questType == 'special' || 
               questType == 'premium';
               
      default:
        // 일반적인 milestone: 연속 접속 7일, 30일, 100일
        final consecutiveDays = userContext?['연속_접속일'] ?? 0;
        return consecutiveDays == 7 || 
               consecutiveDays == 30 || 
               consecutiveDays == 100;
    }
  }
  
  /// 🔄 백그라운드 캐시 생성 시작
  Future<void> startBackgroundCaching(
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
  ) async {
    // 비동기로 백그라운드에서 실행 (UI 블로킹 없음)
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
      'last_update': DateTime.now().toIso8601String(),
    };
  }
}

/// 🎯 AI 사용 레벨 정의 (명확한 기준)
enum AiUsageLevel {
  /// 🔥 항상 AI (100% AI 사용)
  /// - 캐시 우선 → 실시간 AI → 정적 폴백
  /// - 첫 만남, 재복귀, 기념일 등 특별한 순간
  always,
  
  /// ⭐ 중요할 때만 AI (조건부 AI)
  /// - 조건 충족: 캐시 우선 → 실시간 AI
  /// - 조건 미충족: 정적 메시지
  /// - 특별 레벨업, 첫 성취 등
  important,
  
  /// 📱 가끔 AI (특별 조건만)
  /// - 특별 조건: 캐시된 AI만 (실시간 X)
  /// - 조건 미충족: 정적 메시지
  /// - milestone 달성 (연속 7일, 100회 등)
  occasional,
  
  /// 💬 거의 정적 (99% 정적)
  /// - 99%: 정적 메시지 (즉시)
  /// - 1%: 깜짝 AI (무작위)
  /// - 일상적 상호작용
  rarely,
}

/// 📨 셰르피 응답 데이터
class SherpiResponse {
  final String message;
  final MessageSource source;
  final DateTime responseTime;
  final Duration? generationDuration;
  
  SherpiResponse({
    required this.message,
    required this.source,
    required this.responseTime,
    this.generationDuration,
  });
  
  /// ⚡ 빠른 응답인지 확인 (1초 이내)
  bool get isFastResponse {
    return generationDuration == null || 
           generationDuration!.inMilliseconds < 1000;
  }
}

/// 📝 메시지 소스 타입
enum MessageSource {
  static,      // 정적 메시지 (즉시)
  aiCached,    // AI 캐시 (즉시)
  aiRealtime,  // AI 실시간 (2-4초)
}