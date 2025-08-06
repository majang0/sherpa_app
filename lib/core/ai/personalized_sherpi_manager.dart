import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/ai_message_cache.dart';
import 'package:sherpa_app/core/ai/gemini_dialogue_source.dart';
import 'package:sherpa_app/core/ai/smart_sherpi_manager.dart';
import 'package:sherpa_app/core/ai/user_profile_analyzer.dart';
import 'package:sherpa_app/core/ai/context_synthesizer.dart';
import 'package:sherpa_app/core/ai/user_memory_service.dart';
import 'package:sherpa_app/core/ai/response_quality_optimizer.dart';
import 'package:sherpa_app/core/ai/behavior_pattern_analyzer.dart';
import 'package:sherpa_app/core/ai/proactive_support_engine.dart';
import 'package:sherpa_app/core/ai/response_learning_system.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';
import 'package:sherpa_app/features/sherpi_emotion/models/emotion_analysis_model.dart';

// Add unawaited function for background operations
void unawaited(Future<void> future) {
  // Deliberately not awaiting the future to allow background execution
}

/// 🧠 개인화된 스마트 셰르피 매니저
/// 
/// SmartSherpiManager를 확장하여 고급 개인화 기능을 제공합니다.
/// 사용자의 행동 패턴, 감정 반응, 관계 진화를 학습하여 맞춤형 응답을 생성합니다.
class PersonalizedSherpiManager extends SmartSherpiManager {
  final SharedPreferences _prefs;
  final UserProfileAnalyzer _profileAnalyzer;
  final ContextSynthesizer _contextSynthesizer;
  final UserMemoryService _memoryService;
  final ResponseQualityOptimizer _qualityOptimizer;
  final BehaviorPatternAnalyzer _behaviorAnalyzer;
  final ProactiveSupportEngine _supportEngine;
  final ResponseLearningSystem _learningSystem;
  
  // 개인화 데이터 캐시
  UserPersonalizationProfile? _currentProfile;
  DateTime? _lastProfileUpdate;
  
  // 학습 데이터 저장소
  static const String _personalizationKey = 'sherpi_personalization_data';
  static const String _userPreferencesKey = 'sherpi_user_preferences';
  static const String _interactionHistoryKey = 'sherpi_interaction_history';
  
  PersonalizedSherpiManager(this._prefs) 
      : _profileAnalyzer = UserProfileAnalyzer(_prefs),
        _contextSynthesizer = ContextSynthesizer(_prefs),
        _memoryService = UserMemoryService(_prefs),
        _qualityOptimizer = ResponseQualityOptimizer(_prefs, UserMemoryService(_prefs)),
        _behaviorAnalyzer = BehaviorPatternAnalyzer(_prefs),
        _supportEngine = ProactiveSupportEngine(_prefs),
        _learningSystem = ResponseLearningSystem(_prefs),
        super() {
    _loadPersonalizationData();
  }
  
  /// 개인화 데이터 로드
  Future<void> _loadPersonalizationData() async {
    try {
      final profileJson = _prefs.getString(_personalizationKey);
      if (profileJson != null) {
        final profileData = jsonDecode(profileJson);
        _currentProfile = UserPersonalizationProfile.fromJson(profileData);
        _lastProfileUpdate = DateTime.parse(profileData['lastUpdate'] ?? DateTime.now().toIso8601String());
      }
    } catch (e) {
      print('🧠 개인화 데이터 로드 실패: $e');
      _currentProfile = UserPersonalizationProfile.createDefault();
    }
  }
  
  /// 개인화 데이터 저장
  Future<void> _savePersonalizationData() async {
    try {
      if (_currentProfile != null) {
        final profileData = _currentProfile!.toJson();
        profileData['lastUpdate'] = DateTime.now().toIso8601String();
        await _prefs.setString(_personalizationKey, jsonEncode(profileData));
      }
    } catch (e) {
      print('🧠 개인화 데이터 저장 실패: $e');
    }
  }
  
  /// 🎯 고급 개인화 메시지 가져오기
  @override
  Future<SherpiResponse> getMessage(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    // 사용자 프로필 업데이트 (24시간마다)
    await _updateProfileIfNeeded(userContext, gameContext);
    
    // 개인화 컨텍스트 강화
    final enhancedUserContext = await _enhanceUserContext(userContext, context);
    final enhancedGameContext = await _enhanceGameContext(gameContext, context);
    
    // 개인화 수준 결정 (품질 최적화 적용)
    final personalizationLevel = await _calculatePersonalizationLevel(context);
    
    if (personalizationLevel >= 0.7) {
      // 고도 개인화 응답
      return await _getHighlyPersonalizedResponse(
        context, 
        enhancedUserContext, 
        enhancedGameContext
      );
    } else if (personalizationLevel >= 0.4) {
      // 중간 개인화 응답
      return await _getModeratelyPersonalizedResponse(
        context, 
        enhancedUserContext, 
        enhancedGameContext
      );
    } else {
      // 기본 SmartSherpiManager 로직 사용
      return await super.getMessage(context, enhancedUserContext, enhancedGameContext);
    }
  }
  
  /// 사용자 프로필 업데이트 (필요시)
  Future<void> _updateProfileIfNeeded(
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    final now = DateTime.now();
    
    // 24시간마다 또는 처음 실행시 프로필 업데이트
    if (_lastProfileUpdate == null || 
        now.difference(_lastProfileUpdate!).inHours >= 24) {
      
      try {
        _currentProfile = await _profileAnalyzer.analyzeUserProfile(
          userContext: userContext ?? {},
          gameContext: gameContext ?? {},
          previousProfile: _currentProfile,
        );
        
        _lastProfileUpdate = now;
        await _savePersonalizationData();
        
        print('🧠 사용자 프로필 업데이트 완료: ${_currentProfile?.primaryPersonalityType}');
      } catch (e) {
        print('🧠 프로필 업데이트 실패: $e');
      }
    }
  }
  
  /// 사용자 컨텍스트 강화
  Future<Map<String, dynamic>> _enhanceUserContext(
    Map<String, dynamic>? originalContext,
    SherpiContext context,
  ) async {
    final enhanced = Map<String, dynamic>.from(originalContext ?? {});
    
    if (_currentProfile != null) {
      // 개인화 정보 추가
      enhanced.addAll({
        'personalityType': _currentProfile!.primaryPersonalityType,
        'communicationStyle': _currentProfile!.preferredCommunicationStyle,
        'motivationTriggers': _currentProfile!.motivationTriggers,
        'activityPatterns': _currentProfile!.activityPatterns,
        'emotionalTendency': _currentProfile!.emotionalTendency,
        'relationshipLevel': _currentProfile!.relationshipInsights,
      });
    }
    
    return enhanced;
  }
  
  /// 게임 컨텍스트 강화
  Future<Map<String, dynamic>> _enhanceGameContext(
    Map<String, dynamic>? originalContext,
    SherpiContext context,
  ) async {
    final enhanced = Map<String, dynamic>.from(originalContext ?? {});
    
    if (_currentProfile != null) {
      // 개인화된 게임 인사이트 추가
      enhanced.addAll({
        'preferredChallengeLevel': _currentProfile!.preferredChallengeLevel,
        'successPatterns': _currentProfile!.successPatterns,
        'strugglingAreas': _currentProfile!.strugglingAreas,
        'peakActivityTimes': _currentProfile!.peakActivityTimes,
      });
    }
    
    return enhanced;
  }
  
  /// 개인화 수준 계산 - 품질 최적화 통합
  Future<double> _calculatePersonalizationLevel(SherpiContext context) async {
    if (_currentProfile == null) return 0.0;
    
    // 🎯 품질 최적화를 통한 동적 개인화 수준 결정
    try {
      final optimizedLevel = await _qualityOptimizer.optimizePersonalizationLevel(
        context: context,
        userContext: {
          'personalityType': _currentProfile!.primaryPersonalityType,
          'communicationStyle': _currentProfile!.preferredCommunicationStyle,
          'dataRichness': _currentProfile!.dataRichness,
        },
        gameContext: {
          'intimacyLevel': _currentProfile!.relationshipInsights['intimacyLevel'],
        },
        personalityType: _currentProfile!.primaryPersonalityType,
      );
      
      // PersonalizationLevel enum을 double로 변환
      double optimizedScore;
      switch (optimizedLevel) {
        case PersonalizationLevel.high:
          optimizedScore = 0.8;
          break;
        case PersonalizationLevel.medium:
          optimizedScore = 0.5;
          break;
        case PersonalizationLevel.low:
          optimizedScore = 0.2;
          break;
      }
      
      // 🔍 행동 패턴 분석을 통한 추가 조정
      try {
        final behaviorAnalysis = await _behaviorAnalyzer.analyzeBehaviorPatterns();
        
        // 신뢰도가 높은 경우 개인화 수준 미세 조정
        if (behaviorAnalysis.confidenceScore > 0.6) {
          final confidenceBonus = (behaviorAnalysis.confidenceScore - 0.6) * 0.3;
          optimizedScore = (optimizedScore + confidenceBonus).clamp(0.0, 1.0);
          
          print('🔍 행동 패턴 분석 신뢰도 보너스: +${(confidenceBonus * 100).toInt()}%');
        }
      } catch (e) {
        print('🔍 행동 패턴 분석 실패, 기본 개인화 수준 유지: $e');
      }
      
      print('🎯 최적화된 개인화 수준: ${context.name} → $optimizedLevel (${optimizedScore.toStringAsFixed(2)})');
      return optimizedScore;
      
    } catch (e) {
      print('🎯 개인화 수준 최적화 실패, 기본 로직 사용: $e');
      
      // 폴백: 기존 로직 사용
      double baseLevel = _getBasePersonalizationLevel(context);
      double dataRichness = _currentProfile!.dataRichness;
      double intimacyBonus = _currentProfile!.relationshipInsights['intimacyLevel'] / 10.0;
      double finalLevel = (baseLevel * 0.5) + (dataRichness * 0.3) + (intimacyBonus * 0.2);
      
      return finalLevel.clamp(0.0, 1.0);
    }
  }
  
  /// 컨텍스트별 기본 개인화 수준
  double _getBasePersonalizationLevel(SherpiContext context) {
    switch (context) {
      case SherpiContext.welcome:
      case SherpiContext.longTimeNoSee:
        return 0.9; // 특별한 순간 - 높은 개인화
      case SherpiContext.levelUp:
      case SherpiContext.achievement:
        return 0.8; // 성취 순간 - 높은 개인화
      case SherpiContext.encouragement:
      case SherpiContext.climbingFailure:
        return 0.7; // 격려 필요 - 중간 높은 개인화
      case SherpiContext.exerciseComplete:
      case SherpiContext.studyComplete:
        return 0.6; // 활동 완료 - 중간 개인화
      default:
        return 0.4; // 일반적 상황 - 기본 개인화
    }
  }
  
  /// 고도 개인화 응답 생성
  Future<SherpiResponse> _getHighlyPersonalizedResponse(
    SherpiContext context,
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
  ) async {
    try {
      // 개인화된 프롬프트 생성
      final personalizedPrompt = await _contextSynthesizer.createPersonalizedPrompt(
        context: context,
        userContext: userContext,
        gameContext: gameContext,
        personalizationProfile: _currentProfile!,
        personalizationLevel: PersonalizationLevel.high,
      );
      
      // Gemini API 호출
      final geminiSource = GeminiDialogueSource();
      final aiMessage = await geminiSource.getDialogue(
        context,
        personalizedPrompt['userContext'],
        personalizedPrompt['gameContext'],
      );
      
      // 응답 생성 시간 측정
      final responseEndTime = DateTime.now();
      final responseTime = responseEndTime.difference(DateTime.now().subtract(const Duration(milliseconds: 2000))); // 임시 측정
      
      final response = SherpiResponse(
        message: aiMessage,
        source: MessageSource.aiRealtime,
        responseTime: responseEndTime,
        generationDuration: responseTime,
        metadata: {
          'personalizationLevel': 'high',
          'personalityType': _currentProfile!.primaryPersonalityType,
          'communicationStyle': _currentProfile!.preferredCommunicationStyle,
        },
      );
      
      // 📊 응답 품질 추적 (백그라운드)
      unawaited(_trackResponseQuality(
        messageId: response.responseTime.millisecondsSinceEpoch.toString(),
        context: context,
        messageContent: aiMessage,
        messageSource: 'ai_personalized_high',
        responseTime: responseTime,
        personalizationData: {
          'level': 'high',
          'personalityType': _currentProfile!.primaryPersonalityType,
          'communicationStyle': _currentProfile!.preferredCommunicationStyle,
          'contextualRelevance': 0.9, // 고도 개인화이므로 높은 관련성
        },
        userContext: userContext,
        gameContext: gameContext,
      ));
      
      // 상호작용 학습 데이터 기록 (메모리 서비스 활용)
      unawaited(_recordAdvancedInteractionLearning(context, aiMessage, userContext, gameContext));
      unawaited(_recordInteractionForLearning(context, aiMessage, userContext));
      
      return response;
    } catch (e) {
      print('🧠 고도 개인화 응답 생성 실패: $e');
      // 폴백: 중간 개인화 시도
      return await _getModeratelyPersonalizedResponse(context, userContext, gameContext);
    }
  }
  
  /// 중간 개인화 응답 생성
  Future<SherpiResponse> _getModeratelyPersonalizedResponse(
    SherpiContext context,
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
  ) async {
    try {
      // 중간 수준 개인화 프롬프트 생성
      final personalizedPrompt = await _contextSynthesizer.createPersonalizedPrompt(
        context: context,
        userContext: userContext,
        gameContext: gameContext,
        personalizationProfile: _currentProfile!,
        personalizationLevel: PersonalizationLevel.medium,
      );
      
      // 캐시된 개인화 응답 확인
      final cachedResponse = await _getCachedPersonalizedResponse(context, userContext);
      if (cachedResponse != null) {
        return cachedResponse;
      }
      
      // 새로운 개인화 응답 생성
      final geminiSource = GeminiDialogueSource();
      final aiMessage = await geminiSource.getDialogue(
        context,
        personalizedPrompt['userContext'],
        personalizedPrompt['gameContext'],
      );
      
      // 응답 생성 시간 측정
      final responseEndTime = DateTime.now();
      final responseTime = responseEndTime.difference(DateTime.now().subtract(const Duration(milliseconds: 1500))); // 임시 측정
      
      final response = SherpiResponse(
        message: aiMessage,
        source: MessageSource.aiRealtime,
        responseTime: responseEndTime,
        generationDuration: responseTime,
        metadata: {
          'personalizationLevel': 'medium',
          'personalityType': _currentProfile!.primaryPersonalityType,
        },
      );
      
      // 📊 응답 품질 추적 (백그라운드)
      unawaited(_trackResponseQuality(
        messageId: response.responseTime.millisecondsSinceEpoch.toString(),
        context: context,
        messageContent: aiMessage,
        messageSource: 'ai_personalized_medium',
        responseTime: responseTime,
        personalizationData: {
          'level': 'medium',
          'personalityType': _currentProfile!.primaryPersonalityType,
          'contextualRelevance': 0.7, // 중간 개인화
        },
        userContext: userContext,
        gameContext: gameContext,
      ));
      
      // 상호작용 학습 데이터 기록 (메모리 서비스 활용)
      unawaited(_recordAdvancedInteractionLearning(context, aiMessage, userContext, gameContext));
      unawaited(_recordInteractionForLearning(context, aiMessage, userContext));
      
      return response;
    } catch (e) {
      print('🧠 중간 개인화 응답 생성 실패: $e');
      // 폴백: 기본 SmartSherpiManager 로직
      return await super.getMessage(context, userContext, gameContext);
    }
  }
  
  /// 캐시된 개인화 응답 확인
  Future<SherpiResponse?> _getCachedPersonalizedResponse(
    SherpiContext context,
    Map<String, dynamic> userContext,
  ) async {
    // 개인화 캐시 키 생성
    final cacheKey = _generatePersonalizedCacheKey(context, userContext);
    
    try {
      final cachedData = _prefs.getString('personalized_cache_$cacheKey');
      if (cachedData != null) {
        final cacheInfo = jsonDecode(cachedData);
        final cacheTime = DateTime.parse(cacheInfo['timestamp']);
        
        // 6시간 이내 캐시만 사용
        if (DateTime.now().difference(cacheTime).inHours < 6) {
          return SherpiResponse(
            message: cacheInfo['message'],
            source: MessageSource.aiCached,
            responseTime: DateTime.now(),
            generationDuration: Duration.zero,
            metadata: cacheInfo['metadata'] ?? {},
          );
        }
      }
    } catch (e) {
      print('🧠 개인화 캐시 확인 실패: $e');
    }
    
    return null;
  }
  
  /// 개인화 캐시 키 생성
  String _generatePersonalizedCacheKey(
    SherpiContext context,
    Map<String, dynamic> userContext,
  ) {
    final keyComponents = [
      context.name,
      _currentProfile?.primaryPersonalityType ?? 'default',
      _currentProfile?.preferredCommunicationStyle ?? 'default',
      userContext['activityType'] ?? 'general',
    ];
    
    return keyComponents.join('_').hashCode.toString();
  }
  
  /// 상호작용 학습 데이터 기록
  Future<void> _recordInteractionForLearning(
    SherpiContext context,
    String message,
    Map<String, dynamic> userContext,
  ) async {
    try {
      final interactionData = {
        'timestamp': DateTime.now().toIso8601String(),
        'context': context.name,
        'message': message,
        'userContext': userContext,
        'personalityType': _currentProfile?.primaryPersonalityType,
        'personalizationLevel': _calculatePersonalizationLevel(context),
      };
      
      // 최근 상호작용 기록에 추가
      final historyKey = _interactionHistoryKey;
      final existingHistory = _prefs.getStringList(historyKey) ?? [];
      
      existingHistory.insert(0, jsonEncode(interactionData));
      
      // 최근 100개 상호작용만 보관
      if (existingHistory.length > 100) {
        existingHistory.removeRange(100, existingHistory.length);
      }
      
      await _prefs.setStringList(historyKey, existingHistory);
    } catch (e) {
      print('🧠 상호작용 학습 데이터 기록 실패: $e');
    }
  }
  
  /// 🎓 고급 상호작용 학습 (메모리 서비스 활용)
  Future<void> _recordAdvancedInteractionLearning(
    SherpiContext context,
    String message,
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
  ) async {
    try {
      // 메모리 서비스를 통한 상호작용 기록
      await _memoryService.recordInteraction(
        context: context,
        messageContent: message,
        messageSource: 'ai_personalized',
        responseTime: Duration(milliseconds: 500), // 추정 응답 시간
        contextData: {
          'userContext': userContext,
          'gameContext': gameContext,
          'personalityType': _currentProfile?.primaryPersonalityType,
        },
      );
      
      // 성공 패턴 학습 (활동 완료 시)
      if (_isActivityContext(context)) {
        final activityType = _extractActivityType(context);
        final wasSuccessful = userContext['isSuccess'] as bool? ?? true;
        
        await _memoryService.recordSuccessPattern(
          context: context,
          activityType: activityType,
          conditions: {
            'timeOfDay': DateTime.now().hour,
            'userLevel': gameContext['userLevel'] ?? 1,
            'consecutiveDays': userContext['consecutiveDays'] ?? 0,
            'emotionalState': userContext['currentEmotion'] ?? 'neutral',
          },
          wasSuccessful: wasSuccessful,
          userResponse: userContext,
          messageContent: message,
        );
      }
      
      print('🎓 고급 상호작용 학습 완료: ${context.name}');
    } catch (e) {
      print('🎓 고급 상호작용 학습 실패: $e');
    }
  }
  
  /// 📊 응답 품질 추적
  Future<void> _trackResponseQuality({
    required String messageId,
    required SherpiContext context,
    required String messageContent,
    required String messageSource,
    required Duration responseTime,
    required Map<String, dynamic> personalizationData,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  }) async {
    try {
      // 품질 추적 실행 (피드백은 추후 업데이트됨)
      await _qualityOptimizer.trackMessageQuality(
        messageId: messageId,
        context: context,
        messageContent: messageContent,
        messageSource: messageSource,
        feedback: null, // 초기에는 null, 나중에 피드백으로 업데이트
        responseTime: responseTime,
        personalizationData: personalizationData,
        additionalMetrics: {
          'userContext': userContext,
          'gameContext': gameContext,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      print('📊 응답 품질 추적 완료: $messageId');
    } catch (e) {
      print('📊 응답 품질 추적 실패: $e');
    }
  }
  
  /// 사용자 피드백 기록 (향후 학습용) - 메모리 서비스 및 품질 최적화 통합
  Future<void> recordUserFeedback(
    String messageId,
    UserFeedbackType feedbackType,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      // 기존 방식 유지
      final feedbackData = {
        'messageId': messageId,
        'feedbackType': feedbackType.name,
        'timestamp': DateTime.now().toIso8601String(),
        'additionalData': additionalData ?? {},
        'personalityType': _currentProfile?.primaryPersonalityType,
      };
      
      final feedbackKey = 'sherpi_user_feedback';
      final existingFeedback = _prefs.getStringList(feedbackKey) ?? [];
      
      existingFeedback.insert(0, jsonEncode(feedbackData));
      
      // 최근 50개 피드백만 보관
      if (existingFeedback.length > 50) {
        existingFeedback.removeRange(50, existingFeedback.length);
      }
      
      await _prefs.setStringList(feedbackKey, existingFeedback);
      
      // 🧠 메모리 서비스를 통한 고급 피드백 학습
      final context = additionalData?['context'] as SherpiContext?;
      final messageContent = additionalData?['messageContent'] as String?;
      
      if (context != null && messageContent != null) {
        // 메시지 효과성 기록
        await _memoryService.recordMessageEffectiveness(
          messageId: messageId,
          context: context,
          messageContent: messageContent,
          messageSource: 'ai_personalized',
          feedback: feedbackType,
          responseTime: additionalData?['responseTime'] ?? Duration(milliseconds: 500),
          personalizationData: {
            'level': additionalData?['personalizationLevel'] ?? 'medium',
            'personalityType': _currentProfile?.primaryPersonalityType,
            'contextualRelevance': _calculateContextualRelevance(context, additionalData),
          },
        );
        
        // 사용자 선호도 학습
        await _recordUserPreferences(context, messageContent, feedbackType, additionalData);
      }
      
      // 즉시 프로필 업데이트 트리거 (중요한 피드백인 경우)
      if (feedbackType == UserFeedbackType.loved || feedbackType == UserFeedbackType.disliked) {
        _lastProfileUpdate = null; // 강제로 다음에 업데이트하도록
      }
    } catch (e) {
      print('🧠 사용자 피드백 기록 실패: $e');
    }
  }
  
  /// 💡 사용자 선호도 세부 학습
  Future<void> _recordUserPreferences(
    SherpiContext context,
    String messageContent,
    UserFeedbackType feedback,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      // 메시지 톤 분석 및 학습
      final tone = _analyzeMessageTone(messageContent);
      await _memoryService.recordUserPreference(
        preferenceType: 'tone',
        value: tone,
        context: context,
        feedback: feedback,
        additionalData: additionalData,
      );
      
      // 메시지 길이 선호도 학습
      final length = _classifyMessageLength(messageContent);
      await _memoryService.recordUserPreference(
        preferenceType: 'length',
        value: length,
        context: context,
        feedback: feedback,
        additionalData: additionalData,
      );
      
      // 이모지 사용 선호도 학습
      final emojiUsage = _analyzeEmojiUsage(messageContent);
      await _memoryService.recordUserPreference(
        preferenceType: 'emoji_usage',
        value: emojiUsage,
        context: context,
        feedback: feedback,
        additionalData: additionalData,
      );
      
      // 시간대별 선호도 학습
      final timingContext = _analyzeTimingContext();
      await _memoryService.recordUserPreference(
        preferenceType: 'timing',
        value: timingContext,
        context: context,
        feedback: feedback,
        additionalData: additionalData,
      );
      
    } catch (e) {
      print('💡 사용자 선호도 학습 실패: $e');
    }
  }
  
  /// 🔮 최적 조건 예측 및 적용
  Future<Map<String, dynamic>> getOptimalConditions(
    SherpiContext context,
    String activityType,
    Map<String, dynamic> currentConditions,
  ) async {
    try {
      return await _memoryService.predictOptimalConditions(
        context: context,
        activityType: activityType,
        currentConditions: currentConditions,
      );
    } catch (e) {
      print('🔮 최적 조건 예측 실패: $e');
      return {'confidence': 0.0, 'recommendations': <String>[]};
    }
  }
  
  /// 📊 학습 통계 조회
  Future<Map<String, dynamic>> getLearningStatistics() async {
    try {
      return await _memoryService.getLearningStatistics();
    } catch (e) {
      print('📊 학습 통계 조회 실패: $e');
      return {};
    }
  }
  
  /// 💎 개인화 인사이트 생성
  Future<Map<String, dynamic>> generatePersonalizationInsights() async {
    try {
      return await _memoryService.generatePersonalizationInsights();
    } catch (e) {
      print('💎 개인화 인사이트 생성 실패: $e');
      return {};
    }
  }
  
  /// 📈 종합 성과 분석 (품질 최적화 통합)
  Future<Map<String, dynamic>> generatePerformanceReport() async {
    try {
      // 기본 통계
      final learningStats = await getLearningStatistics();
      
      // 개인화 인사이트
      final personalizationInsights = await generatePersonalizationInsights();
      
      // 품질 최적화 성과 분석
      final qualityInsights = await _qualityOptimizer.generatePerformanceInsights();
      
      // 종합 보고서 생성
      return {
        'summary': {
          'systemStatus': 'active',
          'personalizedManagerActive': true,
          'qualityOptimizationActive': true,
          'memoryServiceActive': true,
          'reportGeneratedAt': DateTime.now().toIso8601String(),
        },
        'learning': learningStats,
        'personalization': personalizationInsights,
        'quality': qualityInsights,
        'recommendations': await _generateComprehensiveRecommendations(
          learningStats, personalizationInsights, qualityInsights,
        ),
      };
    } catch (e) {
      print('📈 종합 성과 분석 실패: $e');
      return {'error': e.toString()};
    }
  }
  
  /// 🎛️ 시스템 최적화 설정 조정
  Future<void> updateSystemOptimizationSettings({
    double? qualityThreshold,
    int? minSampleSize,
    Duration? optimizationInterval,
    bool? enableABTesting,
    double? personalizationAggressiveness,
  }) async {
    try {
      await _qualityOptimizer.updateOptimizationSettings(
        qualityThreshold: qualityThreshold,
        minSampleSize: minSampleSize,
        optimizationInterval: optimizationInterval,
        enableABTesting: enableABTesting,
        personalizationAggressiveness: personalizationAggressiveness,
      );
      
      print('🎛️ 시스템 최적화 설정 업데이트 완료');
    } catch (e) {
      print('🎛️ 시스템 최적화 설정 업데이트 실패: $e');
    }
  }
  
  /// 🧹 시스템 정리 및 최적화
  Future<void> performSystemMaintenance() async {
    try {
      // 품질 최적화 시스템 정리
      await _qualityOptimizer.cleanupAndOptimize();
      
      // 메모리 서비스 정리 (필요시)
      // await _memoryService.performMaintenance(); // 구현되면 활성화
      
      print('🧹 시스템 정리 및 최적화 완료');
    } catch (e) {
      print('🧹 시스템 정리 실패: $e');
    }
  }
  
  /// 📊 종합 권장사항 생성
  Future<List<String>> _generateComprehensiveRecommendations(
    Map<String, dynamic> learningStats,
    Map<String, dynamic> personalizationInsights,
    Map<String, dynamic> qualityInsights,
  ) async {
    final recommendations = <String>[];
    
    try {
      // 학습 통계 기반 권장사항
      final totalInteractions = learningStats['totalInteractions'] as int? ?? 0;
      if (totalInteractions < 50) {
        recommendations.add('더 많은 사용자 상호작용이 필요합니다 (현재: $totalInteractions개)');
      }
      
      final averageEffectiveness = learningStats['averageEffectiveness'] as double? ?? 0.0;
      if (averageEffectiveness < 0.6) {
        recommendations.add('메시지 효과성을 개선해야 합니다 (현재: ${(averageEffectiveness * 100).toInt()}%)');
      }
      
      // 개인화 인사이트 기반 권장사항
      final personalityConfidence = personalizationInsights['personalityConfidence'] as double? ?? 0.0;
      if (personalityConfidence < 0.7) {
        recommendations.add('사용자 성격 분석의 신뢰도를 높이기 위해 더 많은 데이터가 필요합니다');
      }
      
      // 품질 최적화 기반 권장사항
      final qualityRecommendations = qualityInsights['recommendations'] as List<String>? ?? [];
      recommendations.addAll(qualityRecommendations);
      
      // 기본 권장사항
      if (recommendations.isEmpty) {
        recommendations.addAll([
          '시스템이 정상적으로 작동하고 있습니다',
          '지속적인 사용자 피드백 수집을 권장합니다',
          '정기적인 성과 분석을 통해 개선점을 파악해보세요',
        ]);
      }
      
    } catch (e) {
      recommendations.add('권장사항 생성 중 오류가 발생했습니다');
      print('📊 권장사항 생성 실패: $e');
    }
    
    return recommendations;
  }
  
  /// 개인화 시스템 상태 조회 - 메모리 서비스 및 품질 최적화 통합
  Future<Map<String, dynamic>> getPersonalizationStatus() async {
    final learningStats = await getLearningStatistics();
    final personalityInsights = await generatePersonalizationInsights();
    final qualityInsights = await _qualityOptimizer.generatePerformanceInsights();
    
    return {
      'isProfileLoaded': _currentProfile != null,
      'lastProfileUpdate': _lastProfileUpdate?.toIso8601String(),
      'personalityType': _currentProfile?.primaryPersonalityType ?? 'unknown',
      'dataRichness': _currentProfile?.dataRichness ?? 0.0,
      'communicationStyle': _currentProfile?.preferredCommunicationStyle ?? 'default',
      'totalInteractions': await _getTotalInteractionCount(),
      'systemStatus': 'active',
      'components': {
        'memoryService': {
          'active': true,
          'learningStatistics': learningStats,
          'personalityInsights': personalityInsights,
        },
        'qualityOptimizer': {
          'active': true,
          'performanceInsights': qualityInsights,
        },
        'profileAnalyzer': {
          'active': true,
          'lastAnalysis': _lastProfileUpdate?.toIso8601String(),
        },
        'contextSynthesizer': {
          'active': true,
        },
        'behaviorAnalyzer': {
          'active': true,
          'analysisAvailable': true,
          'features': [
            'timing_patterns',
            'success_prediction',
            'motivation_timing',
            'risk_detection',
            'optimization_strategies'
          ],
        },
        'proactiveSupportEngine': {
          'active': true,
          'supportPlanAvailable': true,
          'features': [
            'risk_mitigation',
            'opportunity_enhancement',
            'personalized_advice',
            'proactive_interventions',
            'effectiveness_tracking'
          ],
        },
      },
      'systemMetrics': {
        'phase2Completed': true,
        'advancedPersonalizationActive': true,
        'qualityOptimizationActive': true,
        'memoryLearningActive': true,
      },
    };
  }
  
  /// 총 상호작용 수 조회
  Future<int> _getTotalInteractionCount() async {
    try {
      final history = _prefs.getStringList(_interactionHistoryKey) ?? [];
      final memoryHistory = await _memoryService.getInteractionHistory();
      return history.length + memoryHistory.length;
    } catch (e) {
      return 0;
    }
  }
  
  // ==================== 헬퍼 메서드들 ====================
  
  /// 활동 컨텍스트 여부 확인
  bool _isActivityContext(SherpiContext context) {
    const activityContexts = [
      SherpiContext.exerciseComplete,
      SherpiContext.studyComplete,
      SherpiContext.questComplete,
      SherpiContext.climbingSuccess,
      SherpiContext.climbingFailure,
      SherpiContext.levelUp,
      SherpiContext.badgeEarned,
      SherpiContext.achievement,
    ];
    return activityContexts.contains(context);
  }
  
  /// 활동 타입 추출
  String _extractActivityType(SherpiContext context) {
    switch (context) {
      case SherpiContext.exerciseComplete:
        return 'exercise';
      case SherpiContext.studyComplete:
        return 'study';
      case SherpiContext.questComplete:
        return 'quest';
      case SherpiContext.climbingSuccess:
      case SherpiContext.climbingFailure:
        return 'climbing';
      case SherpiContext.levelUp:
        return 'level_up';
      case SherpiContext.badgeEarned:
        return 'badge';
      case SherpiContext.achievement:
        return 'achievement';
      default:
        return 'general';
    }
  }
  
  /// 컨텍스트 관련성 계산
  double _calculateContextualRelevance(SherpiContext context, Map<String, dynamic>? additionalData) {
    // 기본 관련성 점수
    double baseRelevance = 0.5;
    
    // 개인화 수준에 따른 관련성 증가
    final personalizationLevel = additionalData?['personalizationLevel'] as String?;
    if (personalizationLevel == 'high') {
      baseRelevance += 0.3;
    } else if (personalizationLevel == 'medium') {
      baseRelevance += 0.2;
    }
    
    // 성격 타입 매칭에 따른 관련성 증가
    if (_currentProfile != null && additionalData?['personalityType'] == _currentProfile!.primaryPersonalityType) {
      baseRelevance += 0.2;
    }
    
    return baseRelevance.clamp(0.0, 1.0);
  }
  
  /// 메시지 톤 분석
  String _analyzeMessageTone(String messageContent) {
    if (messageContent.contains('축하') || messageContent.contains('🎉')) {
      return 'celebratory';
    } else if (messageContent.contains('격려') || messageContent.contains('💪')) {
      return 'encouraging';
    } else if (messageContent.contains('따뜻') || messageContent.contains('❤️')) {
      return 'warm';
    } else if (messageContent.contains('재미') || messageContent.contains('😄')) {
      return 'playful';
    } else if (messageContent.contains('진지') || messageContent.contains('🤔')) {
      return 'serious';
    } else {
      return 'friendly';
    }
  }
  
  /// 메시지 길이 분류
  String _classifyMessageLength(String messageContent) {
    final length = messageContent.length;
    if (length <= 30) {
      return 'short';
    } else if (length <= 80) {
      return 'medium';
    } else {
      return 'long';
    }
  }
  
  /// 이모지 사용 분석
  String _analyzeEmojiUsage(String messageContent) {
    final emojiCount = RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}]', unicode: true)
        .allMatches(messageContent).length;
    
    if (emojiCount == 0) {
      return 'none';
    } else if (emojiCount <= 2) {
      return 'moderate';
    } else {
      return 'high';
    }
  }
  
  /// 시간대 컨텍스트 분석
  String _analyzeTimingContext() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 9) {
      return 'early_morning';
    } else if (hour >= 9 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 14) {
      return 'lunch';
    } else if (hour >= 14 && hour < 18) {
      return 'afternoon';
    } else if (hour >= 18 && hour < 22) {
      return 'evening';
    } else {
      return 'night';
    }
  }
  
  // ==================== 행동 패턴 분석 통합 기능들 ====================
  
  /// 🔍 오늘의 최적 활동 시간 예측
  Future<List<OptimalTime>> predictTodayOptimalTimes() async {
    try {
      return await _behaviorAnalyzer.predictTodayOptimalTimes();
    } catch (e) {
      print('🔍 오늘의 최적 시간 예측 실패: $e');
      return [];
    }
  }
  
  /// 🎯 동기 부여 필요 시점 예측
  Future<List<MotivationNeed>> predictMotivationNeeds() async {
    try {
      return await _behaviorAnalyzer.predictMotivationNeeds();
    } catch (e) {
      print('🎯 동기 부여 필요 시점 예측 실패: $e');
      return [];
    }
  }
  
  /// ⚠️ 위험 시간대 예측
  Future<List<RiskPeriod>> predictRiskPeriods() async {
    try {
      return await _behaviorAnalyzer.predictRiskPeriods();
    } catch (e) {
      print('⚠️ 위험 시간대 예측 실패: $e');
      return [];
    }
  }
  
  /// 📊 행동 패턴 분석 결과 조회
  Future<BehaviorAnalysisResult?> getBehaviorAnalysis() async {
    try {
      return await _behaviorAnalyzer.analyzeBehaviorPatterns();
    } catch (e) {
      print('📊 행동 패턴 분석 조회 실패: $e');
      return null;
    }
  }
  
  /// 🔄 실시간 행동 패턴 업데이트
  Future<void> updateBehaviorPattern({
    required String activityType,
    required DateTime timestamp,
    required bool success,
    required double intensity,
    required int duration,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final activityRecord = ActivityRecord(
        type: activityType,
        timestamp: timestamp,
        success: success,
        intensity: intensity,
        duration: duration,
        metadata: metadata ?? {},
      );
      
      await _behaviorAnalyzer.updateBehaviorPattern(activityRecord);
      print('🔄 실시간 행동 패턴 업데이트 완료: $activityType');
    } catch (e) {
      print('🔄 실시간 행동 패턴 업데이트 실패: $e');
    }
  }
  
  /// 🎯 상황별 최적 메시지 타이밍 결정
  Future<Map<String, dynamic>> getOptimalMessageTiming(SherpiContext context) async {
    try {
      final behaviorAnalysis = await _behaviorAnalyzer.analyzeBehaviorPatterns();
      
      // 현재 시간이 최적 시간대인지 확인
      final currentHour = DateTime.now().hour;
      final isOptimalTime = behaviorAnalysis.timingPatterns.successfulHours.contains(currentHour);
      
      // 동기 부여 필요 예측
      final motivationNeeds = await _behaviorAnalyzer.predictMotivationNeeds();
      final urgentMotivation = motivationNeeds.where((need) => 
        need.priority <= 2 && 
        DateTime.now().difference(need.timePoint).inHours.abs() <= 1
      ).toList();
      
      // 위험 시간대 확인
      final riskPeriods = await _behaviorAnalyzer.predictRiskPeriods();
      final currentRisk = riskPeriods.where((risk) =>
        DateTime.now().isAfter(risk.startTime) && 
        DateTime.now().isBefore(risk.endTime)
      ).toList();
      
      return {
        'isOptimalTiming': isOptimalTime,
        'currentHourSuccessRate': behaviorAnalysis.successPatterns.hourlySuccessRates[currentHour] ?? 0.5,
        'recommendedDelay': isOptimalTime ? 0 : 30, // 분 단위
        'motivationUrgency': urgentMotivation.isNotEmpty ? urgentMotivation.first.intensity : 'normal',
        'riskLevel': currentRisk.isNotEmpty ? currentRisk.first.riskLevel : 'low',
        'behaviorConfidence': behaviorAnalysis.confidenceScore,
        'recommendations': _generateTimingRecommendations(
          isOptimalTime, 
          urgentMotivation, 
          currentRisk,
          behaviorAnalysis
        ),
      };
    } catch (e) {
      print('🎯 최적 메시지 타이밍 결정 실패: $e');
      return {
        'isOptimalTiming': true,
        'recommendedDelay': 0,
        'motivationUrgency': 'normal',
        'riskLevel': 'low',
        'behaviorConfidence': 0.3,
        'recommendations': ['현재 상황에서 메시지 전송 가능'],
      };
    }
  }
  
  /// 📈 행동 패턴 기반 개인화 강화
  Future<Map<String, dynamic>> enhanceContextWithBehaviorPatterns(
    SherpiContext context,
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
  ) async {
    try {
      final behaviorAnalysis = await _behaviorAnalyzer.analyzeBehaviorPatterns();
      
      // 기존 컨텍스트 복사
      final enhancedUserContext = Map<String, dynamic>.from(userContext);
      final enhancedGameContext = Map<String, dynamic>.from(gameContext);
      
      // 행동 패턴 인사이트 추가
      enhancedUserContext.addAll({
        'behaviorPatterns': {
          'peakActivityHours': behaviorAnalysis.timingPatterns.peakActivityHours,
          'successfulHours': behaviorAnalysis.timingPatterns.successfulHours,
          'consistencyScore': behaviorAnalysis.timingPatterns.consistencyScore,
          'activityRhythm': behaviorAnalysis.timingPatterns.activityRhythm.pattern,
        },
        'successInsights': {
          'overallSuccessRate': behaviorAnalysis.successPatterns.overallSuccessRate,
          'optimalConditions': behaviorAnalysis.successPatterns.optimalConditions,
          'successTriggers': behaviorAnalysis.successPatterns.successTriggers,
        },
        'motivationProfile': {
          'effectiveTriggers': behaviorAnalysis.motivationTriggers
              .where((t) => t.effectiveness > 0.7)
              .map((t) => t.type)
              .toList(),
          'preferredTiming': behaviorAnalysis.motivationTriggers
              .map((t) => t.suggestedTiming)
              .where((timing) => timing != 'context_dependent')
              .toList(),
        },
      });
      
      // 게임 컨텍스트에 예측 정보 추가
      enhancedGameContext.addAll({
        'behaviorPredictions': {
          'todayOptimalTimes': (await _behaviorAnalyzer.predictTodayOptimalTimes())
              .map((time) => time.startTime.hour)
              .toList(),
          'weeklySuccessPrediction': behaviorAnalysis.predictions.weeklySuccessPrediction,
          'riskFactors': behaviorAnalysis.riskFactors.map((risk) => {
            'type': risk.type,
            'severity': risk.severity,
            'description': risk.description,
          }).toList(),
        },
        'engagementInsights': {
          'burnoutRisk': behaviorAnalysis.engagementCycles.burnoutRiskLevel,
          'optimalRestPeriods': behaviorAnalysis.engagementCycles.optimalRestPeriods,
          'weeklyPattern': behaviorAnalysis.engagementCycles.weeklyEngagementPattern,
        },
      });
      
      return {
        'userContext': enhancedUserContext,
        'gameContext': enhancedGameContext,
        'behaviorConfidence': behaviorAnalysis.confidenceScore,
        'dataQuality': behaviorAnalysis.dataQuality,
      };
      
    } catch (e) {
      print('📈 행동 패턴 기반 컨텍스트 강화 실패: $e');
      return {
        'userContext': userContext,
        'gameContext': gameContext,
        'behaviorConfidence': 0.0,
        'dataQuality': 0.0,
      };
    }
  }
  
  /// 🧹 행동 패턴 분석 데이터 정리
  Future<void> cleanupBehaviorAnalysisData() async {
    try {
      await _behaviorAnalyzer.cleanupAnalysisData();
      print('🧹 행동 패턴 분석 데이터 정리 완료');
    } catch (e) {
      print('🧹 행동 패턴 분석 데이터 정리 실패: $e');
    }
  }
  
  /// 📋 타이밍 권장사항 생성
  List<String> _generateTimingRecommendations(
    bool isOptimalTime,
    List<MotivationNeed> urgentMotivation,
    List<RiskPeriod> currentRisk,
    BehaviorAnalysisResult behaviorAnalysis,
  ) {
    final recommendations = <String>[];
    
    if (isOptimalTime) {
      recommendations.add('현재는 사용자의 최적 활동 시간대입니다');
    } else {
      final nextOptimalHour = behaviorAnalysis.timingPatterns.successfulHours
          .where((hour) => hour > DateTime.now().hour)
          .isNotEmpty 
          ? behaviorAnalysis.timingPatterns.successfulHours
              .where((hour) => hour > DateTime.now().hour)
              .first
          : behaviorAnalysis.timingPatterns.successfulHours.first;
      
      recommendations.add('다음 최적 시간대: ${nextOptimalHour}시');
    }
    
    if (urgentMotivation.isNotEmpty) {
      recommendations.add('긴급 동기 부여 필요: ${urgentMotivation.first.message}');
    }
    
    if (currentRisk.isNotEmpty) {
      recommendations.add('주의: ${currentRisk.first.description}');
      recommendations.add('권장 전략: ${currentRisk.first.preventionStrategy}');
    }
    
    if (behaviorAnalysis.confidenceScore < 0.5) {
      recommendations.add('더 많은 데이터가 필요합니다. 지속적인 사용을 권장합니다.');
    }
    
    return recommendations;
  }
  
  // ==================== 선제적 지원 엔진 통합 기능들 ====================
  
  /// 🎯 선제적 지원 계획 생성
  Future<ProactiveSupportPlan> generateProactiveSupportPlan() async {
    try {
      return await _supportEngine.generateSupportPlan();
    } catch (e) {
      print('🎯 선제적 지원 계획 생성 실패: $e');
      rethrow;
    }
  }
  
  /// 🚀 선제적 지원 실행
  Future<void> executeProactiveSupport() async {
    try {
      await _supportEngine.executeProactiveSupport();
      print('🚀 선제적 지원 실행 완료');
    } catch (e) {
      print('🚀 선제적 지원 실행 실패: $e');
    }
  }
  
  /// 💡 맞춤형 조언 생성
  Future<List<PersonalizedAdvice>> generatePersonalizedAdvice({
    required SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  }) async {
    try {
      return await _supportEngine.generatePersonalizedAdvice(
        context: context,
        userContext: userContext,
        gameContext: gameContext,
      );
    } catch (e) {
      print('💡 맞춤형 조언 생성 실패: $e');
      return [];
    }
  }
  
  /// 📊 지원 효과성 분석
  Future<SupportEffectivenessReport> analyzeSupportEffectiveness() async {
    try {
      return await _supportEngine.analyzeSupportEffectiveness();
    } catch (e) {
      print('📊 지원 효과성 분석 실패: $e');
      rethrow;
    }
  }
  
  /// 🔄 지원 계획 적응
  Future<void> adaptSupportPlan({
    required String actionId,
    required double effectivenessScore,
    Map<String, dynamic>? userFeedback,
  }) async {
    try {
      await _supportEngine.adaptSupportPlan(
        actionId: actionId,
        effectivenessScore: effectivenessScore,
        userFeedback: userFeedback,
      );
      print('🔄 지원 계획 적응 완료');
    } catch (e) {
      print('🔄 지원 계획 적응 실패: $e');
    }
  }
  
  /// 🎯 상황별 선제적 조언 제공 (메시지 생성 시 통합)
  Future<SherpiResponse> getMessageWithProactiveSupport(
    SherpiContext context,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  ) async {
    try {
      // 기본 개인화 메시지 생성
      final baseResponse = await getMessage(context, userContext, gameContext);
      
      // 선제적 조언 생성
      final personalizedAdvice = await generatePersonalizedAdvice(
        context: context,
        userContext: userContext,
        gameContext: gameContext,
      );
      
      // 고우선순위 조언이 있는 경우 메시지에 통합
      if (personalizedAdvice.isNotEmpty) {
        final highPriorityAdvice = personalizedAdvice
            .where((advice) => advice.priority <= 2)
            .toList();
        
        if (highPriorityAdvice.isNotEmpty) {
          final advice = highPriorityAdvice.first;
          final enhancedMessage = '${baseResponse.message}\n\n💡 ${advice.content}';
          
          return SherpiResponse(
            message: enhancedMessage,
            source: baseResponse.source,
            responseTime: baseResponse.responseTime,
            generationDuration: baseResponse.generationDuration,
            metadata: {
              ...baseResponse.metadata,
              'proactive_support': {
                'advice_included': true,
                'advice_category': advice.category,
                'advice_priority': advice.priority,
                'advice_confidence': advice.confidence,
              },
            },
          );
        }
      }
      
      return baseResponse;
      
    } catch (e) {
      print('🎯 선제적 지원 통합 메시지 생성 실패: $e');
      return await getMessage(context, userContext, gameContext);
    }
  }
  
  /// 📈 종합 AI 시스템 상태 (선제적 지원 포함)
  Future<Map<String, dynamic>> getComprehensiveSystemStatus() async {
    try {
      // 기본 개인화 상태
      final personalizationStatus = await getPersonalizationStatus();
      
      // 선제적 지원 효과성 분석
      final supportEffectiveness = await analyzeSupportEffectiveness();
      
      // 행동 패턴 분석 결과
      final behaviorAnalysis = await getBehaviorAnalysis();
      
      return {
        ...personalizationStatus,
        'proactiveSupportEngine': {
          'active': true,
          'totalActionsExecuted': supportEffectiveness.totalActionsExecuted,
          'averageEffectiveness': supportEffectiveness.averageEffectiveness,
          'categoryBreakdown': supportEffectiveness.categoryBreakdown,
          'lastEffectivenessCheck': supportEffectiveness.generatedAt.toIso8601String(),
          'insights': supportEffectiveness.insights,
          'recommendations': supportEffectiveness.recommendations,
        },
        'behaviorPatternAnalysis': behaviorAnalysis != null ? {
          'available': true,
          'confidenceScore': behaviorAnalysis.confidenceScore,
          'dataQuality': behaviorAnalysis.dataQuality,
          'lastAnalysis': behaviorAnalysis.analysisTimestamp.toIso8601String(),
          'predictionsAvailable': true,
        } : {
          'available': false,
        },
        'responseLearningSystem': {
          'active': true,
          'learningInsights': await _getLearningSystemStatus(),
        },
        'systemIntegration': {
          'phase3_active': true,
          'proactive_support_enabled': true,
          'behavior_analysis_enabled': true,
          'adaptive_learning_enabled': true,
          'comprehensive_personalization': true,
        },
        'capabilities': [
          'behavior_pattern_analysis',
          'proactive_support',
          'personalized_advice',
          'optimal_timing_prediction',
          'risk_factor_detection',
          'opportunity_identification',
          'adaptive_learning',
          'effectiveness_tracking',
          'response_learning',
          'automatic_adjustment',
          'ab_testing_analysis',
          'performance_reporting',
        ],
      };
      
    } catch (e) {
      print('📈 종합 시스템 상태 조회 실패: $e');
      return await getPersonalizationStatus();
    }
  }
  
  /// 🧹 종합 시스템 정리 (선제적 지원 포함)
  Future<void> performComprehensiveSystemMaintenance() async {
    try {
      // 기본 시스템 정리
      await performSystemMaintenance();
      
      // 행동 패턴 분석 데이터 정리
      await cleanupBehaviorAnalysisData();
      
      // 선제적 지원 엔진 정리
      await _supportEngine.cleanup();
      
      // 응답 학습 시스템 자동 조정 수행
      await performAutomaticLearningAdjustment();
      
      print('🧹 종합 시스템 정리 완료 (학습 시스템 포함)');
    } catch (e) {
      print('🧹 종합 시스템 정리 실패: $e');
    }
  }
  
  // === ResponseLearningSystem 통합 메서드들 ===
  
  /// 🧠 응답 학습 진행 상황 분석
  Future<LearningInsights> analyzeLearningProgress() async {
    try {
      return await _learningSystem.analyzeLearningProgress();
    } catch (e) {
      print('🧠 응답 학습 분석 실패: $e');
      return LearningInsights(
        totalResponses: 0,
        averageEffectiveness: 0.0,
        preferredResponseTypes: [],
        optimalContexts: [],
        learningConfidence: 0.0,
        adaptationRecommendations: ['학습 데이터 수집 필요'],
      );
    }
  }
  
  /// 📝 사용자 반응 기록 및 자동 학습
  Future<void> recordUserResponseAndLearn({
    required String messageId,
    required UserResponseType responseType,
    required SherpiContext context,
    required String messageContent,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final profile = await _getOrCreateCurrentProfile();
      
      await _learningSystem.recordUserResponse(
        messageId: messageId,
        responseType: responseType,
        context: context,
        messageContent: messageContent,
        personalityType: profile.primaryPersonalityType,
        personalizationLevel: await _calculateCurrentPersonalizationLevel(),
        additionalMetadata: additionalMetadata,
      );
      
      // 자동 학습 및 조정 수행 (백그라운드)
      unawaited(_performAutomaticLearningAdjustment());
      
      print('📝 사용자 반응 학습 완료: ${responseType.name}');
    } catch (e) {
      print('📝 사용자 반응 기록 실패: $e');
    }
  }
  
  /// 🔄 개인화 수준 동적 조정
  Future<PersonalizationAdjustment> getPersonalizationAdjustment({
    required SherpiContext context,
  }) async {
    try {
      final profile = await _getOrCreateCurrentProfile();
      final currentLevel = await _calculateCurrentPersonalizationLevel();
      
      return await _learningSystem.getPersonalizationAdjustment(
        personalityType: profile.primaryPersonalityType,
        context: context,
        currentLevel: currentLevel,
      );
    } catch (e) {
      print('🔄 개인화 조정 실패: $e');
      return PersonalizationAdjustment(
        recommendedLevel: 0.7,
        adjustmentReason: 'fallback_default',
        confidence: 0.0,
      );
    }
  }
  
  /// 🎨 응답 스타일 최적화
  Future<ResponseStyleOptimization> optimizeResponseStyle({
    required SherpiContext context,
  }) async {
    try {
      final profile = await _getOrCreateCurrentProfile();
      
      return await _learningSystem.optimizeResponseStyle(
        context: context,
        personalityType: profile.primaryPersonalityType,
      );
    } catch (e) {
      print('🎨 응답 스타일 최적화 실패: $e');
      return ResponseStyleOptimization(
        preferredTone: 'warm_encouraging',
        optimalLength: 50,
        effectiveKeywords: ['축하', '함께', '성취'],
        emotionalApproach: 'balanced_empathy',
        timingRecommendation: 'immediate_response',
        confidence: 0.0,
      );
    }
  }
  
  /// 📋 맞춤형 응답 가이드라인 생성
  Future<ResponseGuidelines> generateResponseGuidelines({
    required SherpiContext context,
    required Map<String, dynamic> userContext,
  }) async {
    try {
      final profile = await _getOrCreateCurrentProfile();
      
      return await _learningSystem.generateResponseGuidelines(
        personalityType: profile.primaryPersonalityType,
        context: context,
        userContext: userContext,
      );
    } catch (e) {
      print('📋 응답 가이드라인 생성 실패: $e');
      return ResponseGuidelines(
        personalizationLevel: 0.7,
        responseStyle: await optimizeResponseStyle(context: context),
        avoidPatterns: [],
        emphasizePatterns: ['개인화', '공감', '격려'],
        tonalAdjustments: ['따뜻한 톤 유지'],
        structuralPreferences: {
          'preferredLength': 50,
          'keywordDensity': 'moderate',
          'emotionalIntensity': 'balanced',
        },
      );
    }
  }
  
  /// 🧪 A/B 테스트 결과 분석
  Future<ABTestResults> analyzeABTestResults({
    required String testId,
    required List<String> variantAMessages,
    required List<String> variantBMessages,
  }) async {
    try {
      return await _learningSystem.analyzeABTestResults(
        testId: testId,
        variantAMessages: variantAMessages,
        variantBMessages: variantBMessages,
      );
    } catch (e) {
      print('🧪 A/B 테스트 분석 실패: $e');
      return ABTestResults(
        testId: testId,
        variantAEffectiveness: 0.5,
        variantBEffectiveness: 0.5,
        significanceLevel: 0.0,
        winningVariant: 'A',
        recommendation: 'insufficient_data',
        sampleSizes: {'variantA': 0, 'variantB': 0},
      );
    }
  }
  
  /// 📊 학습 성능 리포트 생성
  Future<LearningPerformanceReport> generateLearningPerformanceReport() async {
    try {
      return await _learningSystem.generatePerformanceReport();
    } catch (e) {
      print('📊 학습 성능 리포트 생성 실패: $e');
      return LearningPerformanceReport(
        totalLearningDataPoints: 0,
        overallEffectiveness: 0.0,
        learningProgress: 0.0,
        weeklyTrend: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        monthlyTrend: [0.0, 0.0, 0.0, 0.0],
        contextPerformance: {},
        personalizationEffectiveness: {},
        topPerformingPatterns: [],
        improvementOpportunities: ['학습 데이터 수집 시작'],
      );
    }
  }
  
  /// 🔄 자동 성능 기반 조정 실행
  Future<void> performAutomaticLearningAdjustment() async {
    try {
      await _learningSystem.performAutomaticAdjustment();
      print('🔄 자동 학습 조정 완료');
    } catch (e) {
      print('🔄 자동 학습 조정 실패: $e');
    }
  }
  
  // Private helper methods for learning system
  
  Future<void> _performAutomaticLearningAdjustment() async {
    // 백그라운드에서 자동 조정 수행
    try {
      await performAutomaticLearningAdjustment();
    } catch (e) {
      print('🔄 백그라운드 자동 조정 실패: $e');
    }
  }
  
  Future<double> _calculateCurrentPersonalizationLevel() async {
    try {
      final profile = await _getOrCreateCurrentProfile();
      
      // 데이터 풍부도와 관계 친밀도를 기반으로 개인화 수준 계산
      final dataRichness = profile.dataRichness;
      final intimacyLevel = profile.relationshipInsights['intimacyLevel'] as int? ?? 1;
      
      // 기본 점수 계산 (0.0 ~ 1.0)
      double baseScore = (dataRichness * 0.6) + ((intimacyLevel / 10.0) * 0.4);
      
      // 행동 패턴 분석 신뢰도로 보정
      try {
        final behaviorAnalysis = await _behaviorAnalyzer.analyzeBehaviorPatterns();
        if (behaviorAnalysis.confidenceScore > 0.6) {
          final confidenceBonus = (behaviorAnalysis.confidenceScore - 0.6) * 0.3;
          baseScore = (baseScore + confidenceBonus).clamp(0.0, 1.0);
        }
      } catch (e) {
        // 행동 분석 실패 시 기본 점수 유지
      }
      
      return baseScore.clamp(0.3, 0.95); // 최소 0.3, 최대 0.95
    } catch (e) {
      print('개인화 수준 계산 실패: $e');
      return 0.7; // 기본값
    }
  }
  
  /// 현재 개인화 프로필을 가져오거나 생성
  Future<UserPersonalizationProfile> _getOrCreateCurrentProfile() async {
    try {
      // 캐시된 프로필이 있고 최근 것이면 사용
      if (_currentProfile != null && _lastProfileUpdate != null) {
        final hoursSinceUpdate = DateTime.now().difference(_lastProfileUpdate!).inHours;
        if (hoursSinceUpdate < 6) { // 6시간 이내면 캐시 사용
          return _currentProfile!;
        }
      }
      
      // 새로운 프로필 분석 수행
      _currentProfile = await _profileAnalyzer.analyzeUserProfile(
        userContext: {},
        gameContext: {},
        previousProfile: _currentProfile,
      );
      _lastProfileUpdate = DateTime.now();
      
      return _currentProfile!;
    } catch (e) {
      print('개인화 프로필 생성 실패: $e');
      // 기본 프로필 반환
      return _currentProfile ?? UserPersonalizationProfile.createDefault();
    }
  }
  
  Future<Map<String, dynamic>> _getLearningSystemStatus() async {
    try {
      final insights = await analyzeLearningProgress();
      
      return {
        'totalLearningDataPoints': insights.totalResponses,
        'averageEffectiveness': insights.averageEffectiveness,
        'learningConfidence': insights.learningConfidence,
        'preferredResponseTypes': insights.preferredResponseTypes,
        'topContextEffectiveness': insights.optimalContexts.take(3).map((c) => {
          'context': c.contextKey,
          'effectiveness': c.effectiveness,
          'sampleSize': c.sampleSize,
        }).toList(),
        'adaptationRecommendations': insights.adaptationRecommendations,
        'systemReadiness': insights.learningConfidence > 0.5 ? 'ready' : 'learning',
      };
    } catch (e) {
      print('학습 시스템 상태 조회 실패: $e');
      return {
        'totalLearningDataPoints': 0,
        'averageEffectiveness': 0.0,
        'learningConfidence': 0.0,
        'systemReadiness': 'initializing',
      };
    }
  }
}

/// 🎯 개인화 수준 열거형
enum PersonalizationLevel {
  low,
  medium,
  high,
}

/// 👤 사용자 피드백 타입
enum UserFeedbackType {
  loved,      // 매우 좋음
  liked,      // 좋음
  neutral,    // 보통
  disliked,   // 별로
  irrelevant, // 관련없음
}

