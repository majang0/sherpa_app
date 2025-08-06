import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';
import 'package:sherpa_app/features/sherpi_emotion/models/emotion_analysis_model.dart';

/// 🎯 사용자 개인화 프로파일 인터페이스
abstract class UserPersonalizationProfile {
  String get primaryPersonalityType;
  String get preferredCommunicationStyle;
  List<String> get motivationTriggers;
  Map<String, dynamic> get activityPatterns;
  String get emotionalTendency;
  Map<String, dynamic> get relationshipInsights;
  String get preferredChallengeLevel;
  Map<String, dynamic> get successPatterns;
  List<String> get strugglingAreas;
  List<int> get peakActivityTimes;
  double get dataRichness;
  
  Map<String, dynamic> toJson();
  
  static UserPersonalizationProfile fromJson(Map<String, dynamic> json) {
    return UserPersonalizationProfileImpl.fromJson(json);
  }
  
  static UserPersonalizationProfile createDefault() {
    return UserPersonalizationProfileImpl.createDefault();
  }
}

/// 🧠 사용자 프로파일 분석기
/// 
/// 사용자의 활동 패턴, 감정 응답, 관계 데이터를 종합 분석하여
/// 개인화된 셰르피 경험을 위한 프로파일을 생성합니다.
class UserProfileAnalyzer {
  final SharedPreferences _prefs;
  
  // 분석 데이터 캐시
  Map<String, dynamic>? _cachedAnalysis;
  DateTime? _lastAnalysisTime;
  
  // 저장 키들
  static const String _profileAnalysisKey = 'user_profile_analysis';
  static const String _activityPatternsKey = 'user_activity_patterns';
  static const String _emotionPatternsKey = 'user_emotion_patterns';
  
  UserProfileAnalyzer(this._prefs);
  
  /// 🎯 사용자 프로파일 종합 분석
  Future<UserPersonalizationProfile> analyzeUserProfile({
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
    UserPersonalizationProfile? previousProfile,
  }) async {
    try {
      print('🧠 사용자 프로파일 분석 시작...');
      
      // 기존 분석 데이터 로드
      await _loadCachedAnalysis();
      
      // 1. 활동 패턴 분석
      final activityPatterns = await _analyzeActivityPatterns(userContext, gameContext);
      
      // 2. 감정 패턴 분석
      final emotionPatterns = await _analyzeEmotionPatterns();
      
      // 3. 관계 데이터 분석
      final relationshipInsights = await _analyzeRelationshipData();
      
      // 4. 성격 유형 분석
      final personalityAnalysis = await _analyzePersonalityType(
        activityPatterns, 
        emotionPatterns, 
        relationshipInsights
      );
      
      // 5. 커뮤니케이션 스타일 결정
      final communicationStyle = _determineCommunicationStyle(
        personalityAnalysis, 
        relationshipInsights
      );
      
      // 6. 동기 부여 트리거 식별
      final motivationTriggers = _identifyMotivationTriggers(
        activityPatterns, 
        emotionPatterns
      );
      
      // 7. 도전 수준 선호도 분석
      final challengePreference = _analyzeChallengeLevelPreference(
        userContext, 
        gameContext, 
        activityPatterns
      );
      
      // 8. 데이터 풍부도 계산
      final dataRichness = _calculateDataRichness(
        activityPatterns, 
        emotionPatterns, 
        relationshipInsights
      );
      
      // 프로파일 생성
      final profile = UserPersonalizationProfileImpl(
        primaryPersonalityType: personalityAnalysis['primaryType'],
        preferredCommunicationStyle: communicationStyle,
        motivationTriggers: motivationTriggers,
        activityPatterns: activityPatterns,
        emotionalTendency: emotionPatterns['dominantEmotion'] ?? 'positive',
        relationshipInsights: relationshipInsights,
        preferredChallengeLevel: challengePreference,
        successPatterns: activityPatterns['successPatterns'] ?? {},
        strugglingAreas: _identifyStruggleAreas(activityPatterns),
        peakActivityTimes: activityPatterns['peakTimes'] ?? [],
        dataRichness: dataRichness,
        profileVersion: '1.0',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );
      
      // 분석 결과 저장
      await _saveAnalysisResults(profile);
      
      print('🧠 프로파일 분석 완료: ${profile.primaryPersonalityType}');
      return profile;
      
    } catch (e) {
      print('🧠 프로파일 분석 실패: $e');
      
      // 실패시 기본 프로파일 반환
      return previousProfile ?? UserPersonalizationProfileImpl.createDefault();
    }
  }
  
  /// 캐시된 분석 데이터 로드
  Future<void> _loadCachedAnalysis() async {
    try {
      final analysisJson = _prefs.getString(_profileAnalysisKey);
      if (analysisJson != null) {
        _cachedAnalysis = jsonDecode(analysisJson);
        _lastAnalysisTime = DateTime.parse(_cachedAnalysis!['timestamp']);
      }
    } catch (e) {
      print('🧠 캐시된 분석 데이터 로드 실패: $e');
    }
  }
  
  /// 📊 활동 패턴 분석
  Future<Map<String, dynamic>> _analyzeActivityPatterns(
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
  ) async {
    try {
      // 사용자 데이터에서 활동 기록 추출
      final level = userContext['level'] ?? 1;
      final consecutiveDays = userContext['consecutiveDays'] ?? 0;
      final totalExperience = userContext['experience'] ?? 0.0;
      
      // 활동 패턴 분석
      final activityFrequency = await _calculateActivityFrequency();
      final timePreferences = await _analyzeTimePreferences();
      final successRates = await _calculateSuccessRates(userContext);
      final consistencyScore = _calculateConsistencyScore(consecutiveDays);
      
      // 선호 활동 유형 분석
      final preferredActivities = await _identifyPreferredActivities();
      
      return {
        'level': level,
        'consecutiveDays': consecutiveDays,
        'totalExperience': totalExperience,
        'activityFrequency': activityFrequency,
        'timePreferences': timePreferences,
        'successRates': successRates,
        'consistencyScore': consistencyScore,
        'preferredActivities': preferredActivities,
        'peakTimes': timePreferences['peakHours'] ?? [9, 14, 20],
        'successPatterns': successRates,
        'analysisDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('🧠 활동 패턴 분석 실패: $e');
      return _getDefaultActivityPatterns();
    }
  }
  
  /// 활동 빈도 계산
  Future<Map<String, double>> _calculateActivityFrequency() async {
    try {
      // SharedPreferences에서 활동 기록 조회
      final exerciseCount = await _getActivityCount('exercise');
      final readingCount = await _getActivityCount('reading');
      final diaryCount = await _getActivityCount('diary');
      final climbingCount = await _getActivityCount('climbing');
      
      final totalDays = 30; // 최근 30일 기준
      
      return {
        'exercise': exerciseCount / totalDays,
        'reading': readingCount / totalDays,
        'diary': diaryCount / totalDays,
        'climbing': climbingCount / totalDays,
        'overall': (exerciseCount + readingCount + diaryCount) / (totalDays * 3),
      };
    } catch (e) {
      return {'exercise': 0.5, 'reading': 0.3, 'diary': 0.4, 'overall': 0.4};
    }
  }
  
  /// 특정 활동의 최근 30일 개수 조회
  Future<int> _getActivityCount(String activityType) async {
    try {
      final globalUserJson = _prefs.getString('global_user_data');
      if (globalUserJson == null) return 0;
      
      final userData = jsonDecode(globalUserJson);
      final dailyRecords = userData['dailyRecords'];
      
      switch (activityType) {
        case 'exercise':
          return (dailyRecords['exerciseLogs'] as List?)?.length ?? 0;
        case 'reading':
          return (dailyRecords['readingLogs'] as List?)?.length ?? 0;
        case 'diary':
          return (dailyRecords['diaryLogs'] as List?)?.length ?? 0;
        case 'climbing':
          return (dailyRecords['climbingLogs'] as List?)?.length ?? 0;
        default:
          return 0;
      }
    } catch (e) {
      return 0;
    }
  }
  
  /// 시간 선호도 분석
  Future<Map<String, dynamic>> _analyzeTimePreferences() async {
    try {
      // 활동 완료 시간 패턴 분석 (시뮬레이션)
      final morningScore = math.Random().nextDouble() * 0.6 + 0.2; // 0.2-0.8
      final afternoonScore = math.Random().nextDouble() * 0.8 + 0.1; // 0.1-0.9
      final eveningScore = math.Random().nextDouble() * 0.7 + 0.2; // 0.2-0.9
      
      // 최고 점수 시간대 결정
      final scores = [
        {'period': 'morning', 'hours': [6, 7, 8, 9, 10], 'score': morningScore},
        {'period': 'afternoon', 'hours': [12, 13, 14, 15, 16], 'score': afternoonScore},
        {'period': 'evening', 'hours': [18, 19, 20, 21, 22], 'score': eveningScore},
      ];
      
      scores.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
      final bestPeriod = scores.first;
      
      return {
        'preferredPeriod': bestPeriod['period'],
        'peakHours': bestPeriod['hours'],
        'morningScore': morningScore,
        'afternoonScore': afternoonScore,
        'eveningScore': eveningScore,
        'optimalTimes': [9, 14, 20], // 기본 최적 시간
      };
    } catch (e) {
      return {
        'preferredPeriod': 'evening',
        'peakHours': [19, 20, 21],
        'morningScore': 0.4,
        'afternoonScore': 0.6,
        'eveningScore': 0.8,
        'optimalTimes': [9, 14, 20],
      };
    }
  }
  
  /// 성공률 계산
  Future<Map<String, double>> _calculateSuccessRates(Map<String, dynamic> userContext) async {
    try {
      final level = userContext['level'] ?? 1;
      final experience = userContext['experience'] ?? 0.0;
      
      // 레벨과 경험치 기반 성공률 추정
      final baseSuccessRate = math.min<double>(0.9, (level / 20.0) + 0.3);
      
      return {
        'overall': baseSuccessRate,
        'exercise': baseSuccessRate + (math.Random().nextDouble() * 0.2 - 0.1),
        'reading': baseSuccessRate + (math.Random().nextDouble() * 0.2 - 0.1),
        'climbing': baseSuccessRate * 0.8, // 등반은 더 어려움
        'quests': baseSuccessRate + 0.1,
      };
    } catch (e) {
      return {'overall': 0.7, 'exercise': 0.75, 'reading': 0.8, 'climbing': 0.6, 'quests': 0.85};
    }
  }
  
  /// 일관성 점수 계산
  double _calculateConsistencyScore(int consecutiveDays) {
    if (consecutiveDays >= 30) return 1.0;
    if (consecutiveDays >= 14) return 0.8;
    if (consecutiveDays >= 7) return 0.6;
    if (consecutiveDays >= 3) return 0.4;
    return 0.2;
  }
  
  /// 선호 활동 식별
  Future<List<String>> _identifyPreferredActivities() async {
    try {
      final activityFreq = await _calculateActivityFrequency();
      final sortedActivities = activityFreq.entries
          .where((entry) => entry.key != 'overall')
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return sortedActivities.take(2).map((e) => e.key).toList();
    } catch (e) {
      return ['exercise', 'reading'];
    }
  }
  
  /// 😭 감정 패턴 분석
  Future<Map<String, dynamic>> _analyzeEmotionPatterns() async {
    try {
      // SharedPreferences에서 감정 분석 데이터 조회
      final emotionJson = _prefs.getString('recent_emotion_analyses');
      if (emotionJson == null) {
        return _getDefaultEmotionPatterns();
      }
      
      final emotionData = jsonDecode(emotionJson) as List;
      if (emotionData.isEmpty) {
        return _getDefaultEmotionPatterns();
      }
      
      // 감정 분포 계산
      final emotionCounts = <String, int>{};
      double totalConfidence = 0.0;
      
      for (final analysis in emotionData) {
        final emotion = analysis['primaryEmotion'] ?? 'neutral';
        final confidence = analysis['confidence'] ?? 0.5;
        
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
        totalConfidence += confidence;
      }
      
      // 지배적 감정 찾기
      final dominantEmotion = emotionCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      // 감정 안정성 계산
      final emotionalStability = totalConfidence / emotionData.length;
      
      return {
        'dominantEmotion': dominantEmotion,
        'emotionalStability': emotionalStability,
        'emotionDistribution': emotionCounts,
        'averageConfidence': emotionalStability,
        'totalAnalyses': emotionData.length,
        'recentTrend': _calculateEmotionTrend(emotionData),
      };
    } catch (e) {
      print('🧠 감정 패턴 분석 실패: $e');
      return _getDefaultEmotionPatterns();
    }
  }
  
  /// 감정 트렌드 계산
  String _calculateEmotionTrend(List<dynamic> emotionData) {
    if (emotionData.length < 5) return 'stable';
    
    final recent = emotionData.take(5).toList();
    final older = emotionData.skip(5).take(5).toList();
    
    if (recent.isEmpty || older.isEmpty) return 'stable';
    
    final recentPositive = recent.where((e) => 
        ['positive', 'excited', 'motivated'].contains(e['primaryEmotion'])).length;
    final olderPositive = older.where((e) => 
        ['positive', 'excited', 'motivated'].contains(e['primaryEmotion'])).length;
    
    if (recentPositive > olderPositive) return 'improving';
    if (recentPositive < olderPositive) return 'declining';
    return 'stable';
  }
  
  /// 🤝 관계 데이터 분석
  Future<Map<String, dynamic>> _analyzeRelationshipData() async {
    try {
      // SharedPreferences에서 관계 데이터 조회
      final relationshipJson = _prefs.getString('sherpi_relationship');
      if (relationshipJson == null) {
        return _getDefaultRelationshipInsights();
      }
      
      final relationshipData = jsonDecode(relationshipJson);
      
      return {
        'intimacyLevel': relationshipData['intimacyLevel'] ?? 1,
        'totalInteractions': relationshipData['totalInteractions'] ?? 0,
        'consecutiveDays': relationshipData['consecutiveDays'] ?? 0,
        'emotionalSync': relationshipData['emotionalSync'] ?? 0.0,
        'relationshipTitle': _getRelationshipTitle(relationshipData['intimacyLevel'] ?? 1),
        'interactionTypes': relationshipData['interactionTypes'] ?? {},
        'specialMomentsCount': (relationshipData['specialMoments'] as List?)?.length ?? 0,
        'personalityInsights': relationshipData['personalityInsights'] ?? {},
      };
    } catch (e) {
      print('🧠 관계 데이터 분석 실패: $e');
      return _getDefaultRelationshipInsights();
    }
  }
  
  /// 관계 레벨별 호칭 반환
  String _getRelationshipTitle(int intimacyLevel) {
    switch (intimacyLevel) {
      case 1: return "새로운 친구";
      case 2: return "등산 동료";
      case 3: return "믿음직한 파트너";
      case 4: return "든든한 동반자";
      case 5: return "특별한 친구";
      case 6: return "소중한 동료";
      case 7: return "베스트 파트너";
      case 8: return "영혼의 동반자";
      case 9: return "평생 친구";
      case 10: return "운명의 셰르파";
      default: return "친구";
    }
  }
  
  /// 🎭 성격 유형 분석
  Future<Map<String, dynamic>> _analyzePersonalityType(
    Map<String, dynamic> activityPatterns,
    Map<String, dynamic> emotionPatterns,
    Map<String, dynamic> relationshipInsights,
  ) async {
    try {
      // 활동 패턴 기반 성격 지표 계산
      final consistencyScore = activityPatterns['consistencyScore'] ?? 0.5;
      final exerciseFreq = activityPatterns['activityFrequency']['exercise'] ?? 0.5;
      final readingFreq = activityPatterns['activityFrequency']['reading'] ?? 0.5;
      
      // 감정 패턴 기반 성격 지표
      final emotionalStability = emotionPatterns['emotionalStability'] ?? 0.5;
      final dominantEmotion = emotionPatterns['dominantEmotion'] ?? 'positive';
      
      // 관계 패턴 기반 성격 지표
      final intimacyLevel = relationshipInsights['intimacyLevel'] ?? 1;
      final emotionalSync = relationshipInsights['emotionalSync'] ?? 0.0;
      
      // 성격 차원 계산 (0.0 ~ 1.0)
      final dimensions = {
        'discipline': consistencyScore, // 규율성
        'activity': (exerciseFreq * 0.7 + (1 - readingFreq) * 0.3).clamp(0.0, 1.0), // 활동성
        'intellect': (readingFreq * 0.8 + emotionalStability * 0.2).clamp(0.0, 1.0), // 지성
        'sociability': (intimacyLevel / 10.0 * 0.6 + emotionalSync * 0.4).clamp(0.0, 1.0), // 사교성
        'stability': emotionalStability, // 안정성 
      };
      
      // 주요 성격 유형 결정
      String primaryType = _determinePrimaryPersonalityType(dimensions.cast<String, double>());
      
      return {
        'primaryType': primaryType,
        'dimensions': dimensions,
        'confidence': _calculatePersonalityConfidence(dimensions.cast<String, double>()),
        'description': _getPersonalityDescription(primaryType),
      };
    } catch (e) {
      print('🧠 성격 유형 분석 실패: $e');
      return {
        'primaryType': '균형형',
        'dimensions': {
          'discipline': 0.5,
          'activity': 0.5,
          'intellect': 0.5,
          'sociability': 0.5,
          'stability': 0.5,
        },
        'confidence': 0.6,
        'description': '균형 잡힌 성격으로 다양한 활동을 즐깁니다.',
      };
    }
  }
  
  /// 주요 성격 유형 결정
  String _determinePrimaryPersonalityType(Map<String, double> dimensions) {
    final discipline = dimensions['discipline']!;
    final activity = dimensions['activity']!;
    final intellect = dimensions['intellect']!;
    final sociability = dimensions['sociability']!;
    final stability = dimensions['stability']!;
    
    // 성격 유형별 점수 계산
    final scores = {
      '성취형': discipline * 0.4 + activity * 0.3 + stability * 0.3,
      '탐험형': activity * 0.5 + sociability * 0.3 + (1 - discipline) * 0.2,
      '지식형': intellect * 0.5 + discipline * 0.3 + stability * 0.2,
      '사교형': sociability * 0.6 + activity * 0.2 + stability * 0.2,
      '균형형': (discipline + activity + intellect + sociability + stability) / 5,
    };
    
    // 최고 점수 유형 반환
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
  /// 성격 분석 신뢰도 계산
  double _calculatePersonalityConfidence(Map<String, double> dimensions) {
    // 차원 간 분산이 클수록 신뢰도 높음
    final values = dimensions.values.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - mean, 2).toDouble()).reduce((a, b) => a + b) / values.length;
    
    return (variance * 2).clamp(0.3, 0.9); // 0.3 ~ 0.9 범위
  }
  
  /// 성격 유형 설명
  String _getPersonalityDescription(String personalityType) {
    switch (personalityType) {
      case '성취형':
        return '목표 달성을 중시하며 체계적이고 계획적입니다.';
      case '탐험형':
        return '새로운 도전을 즐기며 활동적이고 모험적입니다.';
      case '지식형':
        return '학습과 성장을 중시하며 사색적이고 신중합니다.';
      case '사교형':
        return '관계를 중시하며 외향적이고 협력적입니다.';
      case '균형형':
        return '균형 잡힌 성격으로 다양한 활동을 즐깁니다.';
      default:
        return '독특한 성격으로 자신만의 방식이 있습니다.';
    }
  }
  
  /// 커뮤니케이션 스타일 결정
  String _determineCommunicationStyle(
    Map<String, dynamic> personalityAnalysis,
    Map<String, dynamic> relationshipInsights,
  ) {
    final personalityType = personalityAnalysis['primaryType'];
    final intimacyLevel = relationshipInsights['intimacyLevel'] ?? 1;
    final emotionalSync = relationshipInsights['emotionalSync'] ?? 0.0;
    
    // 친밀도와 감정 동기화 수준 고려
    if (intimacyLevel >= 7 && emotionalSync >= 0.6) {
      return '친밀한'; // 가장 개인적이고 따뜻한 톤
    } else if (intimacyLevel >= 4 && emotionalSync >= 0.4) {
      return '친근한'; // 친근하고 격려적인 톤
    } else {
      return '정중한'; // 정중하고 예의바른 톤
    }
  }
  
  /// 동기 부여 트리거 식별
  List<String> _identifyMotivationTriggers(
    Map<String, dynamic> activityPatterns,
    Map<String, dynamic> emotionPatterns,
  ) {
    final triggers = <String>[];
    
    // 활동 패턴 기반 트리거
    final successRates = activityPatterns['successRates'] ?? {};
    final preferredActivities = activityPatterns['preferredActivities'] ?? [];
    
    if (successRates['overall'] != null && successRates['overall'] > 0.8) {
      triggers.add('성취감');
    }
    
    if (preferredActivities.contains('exercise')) {
      triggers.add('신체활동');
    }
    
    if (preferredActivities.contains('reading')) {
      triggers.add('지식습득');
    }
    
    // 감정 패턴 기반 트리거
    final dominantEmotion = emotionPatterns['dominantEmotion'];
    switch (dominantEmotion) {
      case 'excited':
        triggers.add('도전정신');
        break;
      case 'positive':
        triggers.add('긍정적피드백');
        break;
      case 'motivated':
        triggers.add('목표설정');
        break;
    }
    
    // 최소 2개, 최대 4개의 트리거 반환
    triggers.addAll(['격려', '인정']);
    return triggers.take(4).toList();
  }
  
  /// 도전 수준 선호도 분석
  String _analyzeChallengeLevelPreference(
    Map<String, dynamic> userContext,
    Map<String, dynamic> gameContext,
    Map<String, dynamic> activityPatterns,
  ) {
    final level = userContext['level'] ?? 1;
    final successRate = activityPatterns['successRates']['overall'] ?? 0.7;
    final consistencyScore = activityPatterns['consistencyScore'] ?? 0.5;
    
    // 레벨과 성공률 기반 선호도 결정
    if (level >= 15 && successRate >= 0.8) {
      return 'high'; // 높은 도전 선호
    } else if (level >= 8 && successRate >= 0.6) {
      return 'medium'; // 중간 도전 선호
    } else {
      return 'low'; // 낮은 도전 선호 (안정적)
    }
  }
  
  /// 어려움을 겪는 영역 식별
  List<String> _identifyStruggleAreas(Map<String, dynamic> activityPatterns) {
    final struggles = <String>[];
    final successRates = activityPatterns['successRates'] ?? {};
    final consistencyScore = activityPatterns['consistencyScore'] ?? 0.5;
    
    // 성공률이 낮은 활동 식별
    successRates.forEach((activity, rate) {
      if (activity != 'overall' && rate < 0.6) {
        struggles.add(activity);
      }
    });
    
    // 일관성이 낮으면 '꾸준함' 추가
    if (consistencyScore < 0.5) {
      struggles.add('consistency');
    }
    
    return struggles.take(3).toList();
  }
  
  /// 데이터 풍부도 계산
  double _calculateDataRichness(
    Map<String, dynamic> activityPatterns,
    Map<String, dynamic> emotionPatterns,
    Map<String, dynamic> relationshipInsights,
  ) {
    double richness = 0.0;
    
    // 활동 데이터 풍부도 (40%)
    final totalInteractions = relationshipInsights['totalInteractions'] ?? 0;
    final activityRichness = math.min<double>(1.0, totalInteractions / 100.0);
    richness += activityRichness * 0.4;
    
    // 감정 데이터 풍부도 (30%)
    final emotionAnalyses = emotionPatterns['totalAnalyses'] ?? 0;
    final emotionRichness = math.min<double>(1.0, emotionAnalyses / 50.0);
    richness += emotionRichness * 0.3;
    
    // 관계 데이터 풍부도 (30%)
    final intimacyLevel = relationshipInsights['intimacyLevel'] ?? 1;
    final relationshipRichness = intimacyLevel / 10.0;
    richness += relationshipRichness * 0.3;
    
    return richness.clamp(0.0, 1.0);
  }
  
  /// 분석 결과 저장
  Future<void> _saveAnalysisResults(UserPersonalizationProfile profile) async {
    try {
      final analysisData = {
        'profile': profile.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      
      await _prefs.setString(_profileAnalysisKey, jsonEncode(analysisData));
      print('🧠 프로파일 분석 결과 저장 완료');
    } catch (e) {
      print('🧠 분석 결과 저장 실패: $e');
    }
  }
  
  /// 기본 활동 패턴 반환
  Map<String, dynamic> _getDefaultActivityPatterns() {
    return {
      'level': 1,
      'consecutiveDays': 0,
      'totalExperience': 0.0,
      'activityFrequency': {
        'exercise': 0.4,
        'reading': 0.3,
        'diary': 0.2,
        'overall': 0.3,
      },
      'timePreferences': {
        'preferredPeriod': 'evening',
        'peakHours': [19, 20, 21],
        'optimalTimes': [9, 14, 20],
      },
      'successRates': {
        'overall': 0.7,
        'exercise': 0.75,
        'reading': 0.8,
        'climbing': 0.6,
      },
      'consistencyScore': 0.3,
      'preferredActivities': ['exercise', 'reading'],
      'peakTimes': [9, 14, 20],
      'successPatterns': {},
    };
  }
  
  /// 기본 감정 패턴 반환
  Map<String, dynamic> _getDefaultEmotionPatterns() {
    return {
      'dominantEmotion': 'positive',
      'emotionalStability': 0.6,
      'emotionDistribution': {
        'positive': 5,
        'neutral': 3,
        'motivated': 2,
      },
      'averageConfidence': 0.6,
      'totalAnalyses': 10,
      'recentTrend': 'stable',
    };
  }
  
  /// 기본 관계 인사이트 반환
  Map<String, dynamic> _getDefaultRelationshipInsights() {
    return {
      'intimacyLevel': 1,
      'totalInteractions': 0,
      'consecutiveDays': 0,
      'emotionalSync': 0.0,
      'relationshipTitle': '새로운 친구',
      'interactionTypes': {},
      'specialMomentsCount': 0,
      'personalityInsights': {},
    };
  }
}

/// 🎯 사용자 개인화 프로파일 구현체
class UserPersonalizationProfileImpl implements UserPersonalizationProfile {
  @override
  final String primaryPersonalityType;
  
  @override
  final String preferredCommunicationStyle;
  
  @override
  final List<String> motivationTriggers;
  
  @override
  final Map<String, dynamic> activityPatterns;
  
  @override
  final String emotionalTendency;
  
  @override
  final Map<String, dynamic> relationshipInsights;
  
  @override
  final String preferredChallengeLevel;
  
  @override
  final Map<String, dynamic> successPatterns;
  
  @override
  final List<String> strugglingAreas;
  
  @override
  final List<int> peakActivityTimes;
  
  @override
  final double dataRichness;
  
  final String profileVersion;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  
  const UserPersonalizationProfileImpl({
    required this.primaryPersonalityType,
    required this.preferredCommunicationStyle,
    required this.motivationTriggers,
    required this.activityPatterns,
    required this.emotionalTendency,
    required this.relationshipInsights,
    required this.preferredChallengeLevel,
    required this.successPatterns,
    required this.strugglingAreas,
    required this.peakActivityTimes,
    required this.dataRichness,
    required this.profileVersion,
    required this.createdAt,
    required this.lastUpdatedAt,
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'primaryPersonalityType': primaryPersonalityType,
      'preferredCommunicationStyle': preferredCommunicationStyle,
      'motivationTriggers': motivationTriggers,
      'activityPatterns': activityPatterns,
      'emotionalTendency': emotionalTendency,
      'relationshipInsights': relationshipInsights,
      'preferredChallengeLevel': preferredChallengeLevel,
      'successPatterns': successPatterns,
      'strugglingAreas': strugglingAreas,
      'peakActivityTimes': peakActivityTimes,
      'dataRichness': dataRichness,
      'profileVersion': profileVersion,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }
  
  static UserPersonalizationProfile fromJson(Map<String, dynamic> json) {
    return UserPersonalizationProfileImpl(
      primaryPersonalityType: json['primaryPersonalityType'] ?? '균형형',
      preferredCommunicationStyle: json['preferredCommunicationStyle'] ?? '정중한',
      motivationTriggers: List<String>.from(json['motivationTriggers'] ?? ['격려', '인정']),
      activityPatterns: Map<String, dynamic>.from(json['activityPatterns'] ?? {}),
      emotionalTendency: json['emotionalTendency'] ?? 'positive',
      relationshipInsights: Map<String, dynamic>.from(json['relationshipInsights'] ?? {}),
      preferredChallengeLevel: json['preferredChallengeLevel'] ?? 'medium',
      successPatterns: Map<String, dynamic>.from(json['successPatterns'] ?? {}),
      strugglingAreas: List<String>.from(json['strugglingAreas'] ?? []),
      peakActivityTimes: List<int>.from(json['peakActivityTimes'] ?? [9, 14, 20]),
      dataRichness: (json['dataRichness'] ?? 0.3).toDouble(),
      profileVersion: json['profileVersion'] ?? '1.0',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  static UserPersonalizationProfile createDefault() {
    return UserPersonalizationProfileImpl(
      primaryPersonalityType: '균형형',
      preferredCommunicationStyle: '정중한',
      motivationTriggers: ['격려', '인정', '성취감'],
      activityPatterns: {
        'level': 1,
        'activityFrequency': {'overall': 0.3},
        'timePreferences': {'preferredPeriod': 'evening'},
        'successRates': {'overall': 0.7},
      },
      emotionalTendency: 'positive',
      relationshipInsights: {
        'intimacyLevel': 1,
        'totalInteractions': 0,
        'emotionalSync': 0.0,
      },
      preferredChallengeLevel: 'medium',
      successPatterns: {},
      strugglingAreas: [],
      peakActivityTimes: [9, 14, 20],
      dataRichness: 0.3,
      profileVersion: '1.0',
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );
  }
}