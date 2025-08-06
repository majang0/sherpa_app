import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/ai/user_profile_analyzer.dart';
import 'package:sherpa_app/core/ai/personalized_sherpi_manager.dart';

/// 🎯 컨텍스트 합성기
/// 
/// 모든 사용자 데이터와 상황 정보를 종합하여 
/// 개인화된 AI 프롬프트를 생성합니다.
class ContextSynthesizer {
  final SharedPreferences _prefs;
  
  ContextSynthesizer(this._prefs);
  
  /// 🎭 개인화된 프롬프트 생성
  Future<Map<String, dynamic>> createPersonalizedPrompt({
    required SherpiContext context,
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
    required UserPersonalizationProfile personalizationProfile,
    required PersonalizationLevel personalizationLevel,
  }) async {
    // 기본 컨텍스트 확장
    final enhancedUserContext = await _enhanceUserContext(
      userContext, 
      personalizationProfile, 
      context
    );
    
    final enhancedGameContext = await _enhanceGameContext(
      gameContext, 
      personalizationProfile, 
      context
    );
    
    // 개인화 수준에 따른 프롬프트 생성
    switch (personalizationLevel) {
      case PersonalizationLevel.high:
        return await _createHighPersonalizationPrompt(
          context, enhancedUserContext, enhancedGameContext, personalizationProfile
        );
      case PersonalizationLevel.medium:
        return await _createMediumPersonalizationPrompt(
          context, enhancedUserContext, enhancedGameContext, personalizationProfile
        );
      case PersonalizationLevel.low:
        return await _createLowPersonalizationPrompt(
          context, enhancedUserContext, enhancedGameContext, personalizationProfile
        );
    }
  }
  
  /// 🔥 고도 개인화 프롬프트 생성
  Future<Map<String, dynamic>> _createHighPersonalizationPrompt(
    SherpiContext context,
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
    UserPersonalizationProfile profile,
  ) async {
    // 성격 유형별 맞춤 프롬프트 베이스
    final personalityPrompt = _getPersonalitySpecificPrompt(profile.primaryPersonalityType);
    
    // 감정 상태 기반 톤 조정
    final emotionalTone = _getEmotionalTone(userContext, gameContext);
    
    // 관계 친밀도 기반 언어 스타일
    final communicationStyle = _getCommunicationStyle(profile);
    
    // 개인 성공 패턴 참조
    final successPatterns = _buildSuccessPatternContext(profile);
    
    // 시간대/상황별 맞춤 요소
    final contextualElements = _getContextualElements(context, userContext);
    
    // 고도 개인화 사용자 컨텍스트
    final personalizedUserContext = Map<String, dynamic>.from(userContext);
    personalizedUserContext.addAll({
      'personalityPrompt': personalityPrompt,
      'emotionalTone': emotionalTone,
      'communicationStyle': communicationStyle,
      'recentSuccessPattern': successPatterns,
      'personalizedTiming': contextualElements,
      'intimacyLevel': profile.relationshipInsights['intimacyLevel'],
      'preferredMotivation': profile.motivationTriggers.join(', '),
      'currentStruggle': profile.strugglingAreas.isNotEmpty ? profile.strugglingAreas.first : null,
      'peakEnergyTime': _getCurrentEnergyLevel(profile),
    });
    
    // 고도 개인화 게임 컨텍스트  
    final personalizedGameContext = Map<String, dynamic>.from(gameContext);
    personalizedGameContext.addAll({
      'personalizedChallengeLevel': profile.preferredChallengeLevel,
      'successPrediction': _predictSuccessLikelihood(profile, context),
      'recommendedApproach': _getRecommendedApproach(profile, context),
      'emotionalSupport': _getEmotionalSupportStrategy(profile, userContext),
    });
    
    return {
      'userContext': personalizedUserContext,
      'gameContext': personalizedGameContext,
      'personalizationMetadata': {
        'level': 'high',
        'personalityType': profile.primaryPersonalityType,
        'dataRichness': profile.dataRichness,
        'generatedAt': DateTime.now().toIso8601String(),
      }
    };
  }
  
  /// 🎯 중간 개인화 프롬프트 생성  
  Future<Map<String, dynamic>> _createMediumPersonalizationPrompt(
    SherpiContext context,
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
    UserPersonalizationProfile profile,
  ) async {
    // 핵심 개인화 요소만 적용
    final personalizedUserContext = Map<String, dynamic>.from(userContext);
    personalizedUserContext.addAll({
      'personalityType': profile.primaryPersonalityType,
      'communicationPreference': profile.preferredCommunicationStyle,
      'motivationTriggers': profile.motivationTriggers.take(2).join(', '),
      'recentActivityTrend': _getRecentActivityTrend(profile),
    });
    
    final personalizedGameContext = Map<String, dynamic>.from(gameContext);
    personalizedGameContext.addAll({
      'preferredChallengeLevel': profile.preferredChallengeLevel,
      'relationshipLevel': profile.relationshipInsights['intimacyLevel'],
    });
    
    return {
      'userContext': personalizedUserContext,
      'gameContext': personalizedGameContext,
      'personalizationMetadata': {
        'level': 'medium',
        'personalityType': profile.primaryPersonalityType,
        'generatedAt': DateTime.now().toIso8601String(),
      }
    };
  }
  
  /// 🟢 기본 개인화 프롬프트 생성
  Future<Map<String, dynamic>> _createLowPersonalizationPrompt(
    SherpiContext context,
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
    UserPersonalizationProfile profile,
  ) async {
    // 최소한의 개인화 요소만 적용
    final personalizedUserContext = Map<String, dynamic>.from(userContext);
    personalizedUserContext.addAll({
      'personalityType': profile.primaryPersonalityType,
      'basicPreference': profile.preferredCommunicationStyle,
    });
    
    return {
      'userContext': personalizedUserContext,
      'gameContext': gameContext,
      'personalizationMetadata': {
        'level': 'low',
        'personalityType': profile.primaryPersonalityType,
        'generatedAt': DateTime.now().toIso8601String(),
      }
    };
  }
  
  /// 🧠 성격 유형별 특화 프롬프트
  String _getPersonalitySpecificPrompt(String personalityType) {
    switch (personalityType) {
      case '성취형':
        return '''
당신은 성취 지향적인 사용자와 대화하고 있습니다.
- 구체적인 성과와 진전사항을 강조하세요
- 목표 달성에 대한 성취감을 부각하세요  
- 다음 단계의 명확한 목표를 제시하세요
- "우리가 이룬 성과", "목표 달성까지 한 걸음 더" 같은 표현 사용
''';
        
      case '탐험형':
        return '''
당신은 새로운 경험을 좋아하는 모험가와 대화하고 있습니다.
- 새로운 도전과 탐험 요소를 강조하세요
- 호기심을 자극하는 표현을 사용하세요
- 다양성과 변화를 긍정적으로 언급하세요
- "새로운 발견", "다음 모험", "또 다른 도전" 같은 표현 사용
''';
        
      case '지식형':
        return '''
당신은 학습과 성장을 중시하는 사용자와 대화하고 있습니다.
- 학습된 내용과 인사이트를 강조하세요
- 지식 습득과 이해의 깊이를 인정하세요
- 분석적이고 사려깊은 접근을 보여주세요
- "새로운 이해", "깊어진 통찰", "배움의 즐거움" 같은 표현 사용
''';
        
      case '사교형':
        return '''
당신은 관계와 소통을 중시하는 사용자와 대화하고 있습니다.
- 함께하는 느낌과 동반자적 관계를 강조하세요
- 따뜻하고 친근한 톤을 사용하세요
- 공감과 격려를 풍부하게 표현하세요
- "우리 함께", "서로의 마음", "따뜻한 동행" 같은 표현 사용
''';
        
      case '균형형':
        return '''
당신은 균형감 있는 접근을 선호하는 사용자와 대화하고 있습니다.  
- 안정감 있고 신뢰할 수 있는 톤을 사용하세요
- 다양한 측면을 고려한 조언을 제공하세요
- 꾸준함과 지속성을 강조하세요
- "차근차근", "꾸준한 발걸음", "안정적인 성장" 같은 표현 사용
''';
        
      default:
        return '따뜻하고 개인적인 톤으로 대화하세요.';
    }
  }
  
  /// 😊 감정 상태 기반 톤 분석
  String _getEmotionalTone(Map<String, dynamic> userContext, Map<String, dynamic> gameContext) {
    final emotion = userContext['currentEmotion'] as String?;
    final isSuccess = gameContext['isSuccess'] as bool? ?? true;
    
    if (emotion != null) {
      switch (emotion) {
        case 'excited':
          return isSuccess ? '함께 기쁨을 나누는 신나는 톤' : '기대감을 유지하면서도 위로하는 톤';
        case 'tired':
          return '부드럽고 격려하는 에너지를 주는 톤';
        case 'stressed':
          return '안정감을 주고 차분하게 달래는 톤';
        case 'motivated':
          return '열정을 함께 나누는 역동적인 톤';
        default:
          return '따뜻하고 균형 잡힌 친근한 톤';
      }
    }
    
    return isSuccess ? '축하하고 기뻐하는 따뜻한 톤' : '위로하고 격려하는 부드러운 톤';
  }
  
  /// 💬 관계 친밀도 기반 의사소통 스타일
  String _getCommunicationStyle(UserPersonalizationProfile profile) {
    final intimacyLevel = profile.relationshipInsights['intimacyLevel'] as int? ?? 1;
    
    if (intimacyLevel >= 8) {
      return '가족같은 친밀함으로 진심을 나누는 스타일';
    } else if (intimacyLevel >= 6) {
      return '깊은 신뢰를 바탕으로 솔직하게 소통하는 스타일';
    } else if (intimacyLevel >= 4) {
      return '편안하고 친근하게 대화하는 스타일';
    } else if (intimacyLevel >= 2) {
      return '정중하면서도 따뜻하게 접근하는 스타일';
    } else {
      return '예의 바르고 부담스럽지 않게 소개하는 스타일';
    }
  }
  
  /// 🏆 성공 패턴 기반 컨텍스트 구축
  String _buildSuccessPatternContext(UserPersonalizationProfile profile) {
    final successPatterns = profile.successPatterns;
    
    if (successPatterns.isEmpty) {
      return '새로운 시작에 대한 기대감을 표현';
    }
    
    final patterns = <String>[];
    
    if (successPatterns['morningSuccess'] == true) {
      patterns.add('아침 시간대의 높은 성취율');
    }
    if (successPatterns['consistentActivity'] == true) {
      patterns.add('꾸준한 활동 패턴');
    }
    if (successPatterns['socialMotivation'] == true) {
      patterns.add('사회적 동기부여 효과');
    }
    
    return patterns.isNotEmpty 
        ? '과거 성공 패턴: ${patterns.join(', ')}'
        : '개인적인 성장 경험을 바탕으로';
  }
  
  /// ⏰ 컨텍스트별 맞춤 요소
  String _getContextualElements(SherpiContext context, Map<String, dynamic> userContext) {
    final currentHour = DateTime.now().hour;
    final timeContext = _getTimeBasedContext(currentHour);
    
    switch (context) {
      case SherpiContext.welcome:
        return '$timeContext 새로운 시작에 적합한 환영 인사';
      case SherpiContext.levelUp:
        return '$timeContext 성취를 축하하기에 완벽한 순간';
      case SherpiContext.encouragement:
        return '$timeContext 격려가 필요한 때 적절한 지원';
      default:
        return '$timeContext 자연스러운 대화 분위기';
    }
  }
  
  /// 🌅 시간대별 컨텍스트
  String _getTimeBasedContext(int hour) {
    if (hour >= 6 && hour < 9) {
      return '상쾌한 아침 시간,';
    } else if (hour >= 9 && hour < 12) {
      return '활기찬 오전 시간,';
    } else if (hour >= 12 && hour < 14) {
      return '바쁜 점심 시간,';
    } else if (hour >= 14 && hour < 18) {
      return '집중적인 오후 시간,';
    } else if (hour >= 18 && hour < 22) {
      return '편안한 저녁 시간,';
    } else {
      return '조용한 늦은 시간,';
    }
  }
  
  /// ⚡ 현재 에너지 레벨 분석
  String _getCurrentEnergyLevel(UserPersonalizationProfile profile) {
    final currentHour = DateTime.now().hour;
    final peakTimes = profile.peakActivityTimes;
    
    if (peakTimes.contains(currentHour)) {
      return '최고 에너지 시간대';
    } else if (peakTimes.any((time) => (time - currentHour).abs() <= 1)) {
      return '높은 에너지 시간대';
    } else {
      return '보통 에너지 시간대';
    }
  }
  
  /// 📈 성공 가능성 예측
  String _predictSuccessLikelihood(UserPersonalizationProfile profile, SherpiContext context) {
    final currentHour = DateTime.now().hour;
    final isProductiveTime = profile.peakActivityTimes.contains(currentHour);
    final hasRelevantSuccess = profile.successPatterns.isNotEmpty;
    
    if (isProductiveTime && hasRelevantSuccess) {
      return '높은 성공 가능성 - 최적의 조건';
    } else if (isProductiveTime || hasRelevantSuccess) {
      return '좋은 성공 가능성 - 유리한 조건';
    } else {
      return '도전적이지만 달성 가능한 목표';
    }
  }
  
  /// 🎯 추천 접근 방식
  String _getRecommendedApproach(UserPersonalizationProfile profile, SherpiContext context) {
    final personalityType = profile.primaryPersonalityType;
    
    switch (personalityType) {
      case '성취형':
        return '구체적인 목표 설정과 단계별 진행';
      case '탐험형':
        return '새로운 시도와 다양한 접근 방식';
      case '지식형':
        return '체계적인 학습과 점진적 이해';
      case '사교형':
        return '함께하는 활동과 소통 중심 접근';
      case '균형형':
        return '안정적이고 지속 가능한 방식';
      default:
        return '개인에게 맞는 유연한 접근';
    }
  }
  
  /// 💝 감정 지원 전략
  String _getEmotionalSupportStrategy(UserPersonalizationProfile profile, Map<String, dynamic> userContext) {
    final recentEmotion = userContext['emotionalTendency'] as String? ?? profile.emotionalTendency;
    final intimacyLevel = profile.relationshipInsights['intimacyLevel'] as int? ?? 1;
    
    if (intimacyLevel >= 7) {
      return '진심어린 공감과 깊은 이해로 마음 따뜻하게';
    } else if (intimacyLevel >= 4) {
      return '친근한 격려와 실질적인 조언으로 든든하게';
    } else {
      return '정중한 지지와 희망적인 메시지로 용기 북돋아';
    }
  }
  
  /// 📊 최근 활동 트렌드 분석
  String _getRecentActivityTrend(UserPersonalizationProfile profile) {
    final patterns = profile.activityPatterns;
    
    if (patterns['increasingTrend'] == true) {
      return '상승세를 보이는 활발한 활동';
    } else if (patterns['consistentPattern'] == true) {
      return '꾸준하고 안정적인 활동';
    } else if (patterns['irregularPattern'] == true) {
      return '변화가 있는 유동적인 활동';
    } else {
      return '새로운 패턴을 만들어가는 중';
    }
  }
  
  /// 사용자 컨텍스트 강화
  Future<Map<String, dynamic>> _enhanceUserContext(
    Map<String, dynamic> originalContext,
    UserPersonalizationProfile profile,
    SherpiContext context,
  ) async {
    final enhanced = Map<String, dynamic>.from(originalContext);
    
    // 개인화 정보 추가
    enhanced.addAll({
      'personalityType': profile.primaryPersonalityType,
      'communicationStyle': profile.preferredCommunicationStyle,
      'motivationTriggers': profile.motivationTriggers,
      'activityPatterns': profile.activityPatterns,
      'emotionalTendency': profile.emotionalTendency,
      'relationshipLevel': profile.relationshipInsights,
      'dataRichness': profile.dataRichness,
    });
    
    return enhanced;
  }
  
  /// 게임 컨텍스트 강화
  Future<Map<String, dynamic>> _enhanceGameContext(
    Map<String, dynamic> originalContext,
    UserPersonalizationProfile profile,
    SherpiContext context,
  ) async {
    final enhanced = Map<String, dynamic>.from(originalContext);
    
    // 개인화된 게임 인사이트 추가
    enhanced.addAll({
      'preferredChallengeLevel': profile.preferredChallengeLevel,
      'successPatterns': profile.successPatterns,
      'strugglingAreas': profile.strugglingAreas,
      'peakActivityTimes': profile.peakActivityTimes,
    });
    
    return enhanced;
  }
}

