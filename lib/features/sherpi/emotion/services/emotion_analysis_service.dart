import 'dart:math';
import '../models/emotion_analysis_model.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

/// 🧠 사용자 감정 분석 서비스
/// 
/// 사용자의 활동 패턴, 성과, 시간대 등을 종합적으로 분석하여
/// 현재 감정 상태를 추정하고 Sherpi가 적절히 반응하도록 돕습니다.
class EmotionAnalysisService {
  
  /// 🎭 사용자 감정 분석 메인 함수
  /// 
  /// 다양한 컨텍스트 정보를 바탕으로 사용자의 현재 감정 상태를 분석합니다.
  EmotionAnalysisResult analyzeUserEmotion(EmotionAnalysisContext context) {
    final emotionScores = <UserEmotionState, double>{};
    
    // 모든 감정 상태에 대한 기본 점수 초기화
    for (final emotion in UserEmotionState.values) {
      emotionScores[emotion] = 0.0;
    }
    
    // 1. 활동 성공/실패 분석 (40% 가중치)
    _analyzeActivityOutcome(context, emotionScores);
    
    // 2. 연속 활동 패턴 분석 (25% 가중치)
    _analyzeConsistencyPattern(context, emotionScores);
    
    // 3. 시간대 분석 (15% 가중치)
    _analyzeTimeContext(context, emotionScores);
    
    // 4. 최근 활동 패턴 분석 (10% 가중치)
    _analyzeRecentActivityPattern(context, emotionScores);
    
    // 5. 성과 데이터 분석 (10% 가중치)
    _analyzePerformanceData(context, emotionScores);
    
    // 가장 높은 점수의 감정을 주요 감정으로 선택
    final primaryEmotion = emotionScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    final confidence = emotionScores[primaryEmotion]! / 100.0;
    
    return EmotionAnalysisResult(
      primaryEmotion: primaryEmotion,
      confidence: confidence.clamp(0.0, 1.0),
      emotionScores: emotionScores.map((key, value) => 
          MapEntry(key, (value / 100.0).clamp(0.0, 1.0))),
      analyzedAt: DateTime.now(),
      analysisContext: context.toJson(),
    );
  }
  
  /// 🎯 활동 성공/실패 분석 (40% 가중치)
  void _analyzeActivityOutcome(
    EmotionAnalysisContext context, 
    Map<UserEmotionState, double> scores
  ) {
    if (context.isSuccess) {
      // 성공 시 감정 분포
      switch (context.activityType) {
        case 'exercise':
          scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 35;
          scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 25;
          if (context.consecutiveDays >= 7) {
            scores[UserEmotionState.excited] = scores[UserEmotionState.excited]! + 15;
          }
          break;
          
        case 'study':
        case 'reading':
          scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 30;
          scores[UserEmotionState.contemplative] = scores[UserEmotionState.contemplative]! + 20;
          scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 10;
          break;
          
        case 'quest':
          scores[UserEmotionState.excited] = scores[UserEmotionState.excited]! + 25;
          scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 20;
          scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 15;
          break;
          
        case 'climbing':
          scores[UserEmotionState.excited] = scores[UserEmotionState.excited]! + 30;
          scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 25;
          break;
          
        default:
          scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 25;
          scores[UserEmotionState.neutral] = scores[UserEmotionState.neutral]! + 15;
      }
    } else {
      // 실패 시 감정 분포 (더 세밀한 분석)
      final failureContext = context.performanceData['failure_reason'] as String?;
      
      if (failureContext == 'time_constraint') {
        scores[UserEmotionState.stressed] = scores[UserEmotionState.stressed]! + 20;
        scores[UserEmotionState.tired] = scores[UserEmotionState.tired]! + 15;
      } else if (failureContext == 'difficulty') {
        scores[UserEmotionState.contemplative] = scores[UserEmotionState.contemplative]! + 20;
        scores[UserEmotionState.negative] = scores[UserEmotionState.negative]! + 10;
      } else {
        scores[UserEmotionState.negative] = scores[UserEmotionState.negative]! + 15;
        scores[UserEmotionState.neutral] = scores[UserEmotionState.neutral]! + 10;
      }
    }
  }
  
  /// 📈 연속 활동 패턴 분석 (25% 가중치)
  void _analyzeConsistencyPattern(
    EmotionAnalysisContext context, 
    Map<UserEmotionState, double> scores
  ) {
    if (context.consecutiveDays >= 30) {
      // 30일 이상 연속: 매우 높은 동기와 긍정
      scores[UserEmotionState.excited] = scores[UserEmotionState.excited]! + 20;
      scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 15;
      scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 10;
    } else if (context.consecutiveDays >= 14) {
      // 14일 이상 연속: 높은 동기
      scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 15;
      scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 10;
    } else if (context.consecutiveDays >= 7) {
      // 7일 이상 연속: 좋은 패턴
      scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 10;
      scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 8;
    } else if (context.consecutiveDays >= 3) {
      // 3일 이상 연속: 시작 단계
      scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 5;
      scores[UserEmotionState.neutral] = scores[UserEmotionState.neutral]! + 10;
    } else if (context.consecutiveDays == 0) {
      // 연속성 깨짐: 부정적 감정 증가
      scores[UserEmotionState.negative] = scores[UserEmotionState.negative]! + 10;
      scores[UserEmotionState.contemplative] = scores[UserEmotionState.contemplative]! + 8;
    }
  }
  
  /// ⏰ 시간대 분석 (15% 가중치)
  void _analyzeTimeContext(
    EmotionAnalysisContext context, 
    Map<UserEmotionState, double> scores
  ) {
    switch (context.timeOfDay) {
      case >= 6 && < 9:
        // 아침 시간대: 동기부여, 긍정적
        scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 10;
        scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 5;
        break;
        
      case >= 9 && < 12:
        // 오전 시간대: 집중, 생산적
        scores[UserEmotionState.contemplative] = scores[UserEmotionState.contemplative]! + 8;
        scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 7;
        break;
        
      case >= 12 && < 18:
        // 오후 시간대: 안정적
        scores[UserEmotionState.neutral] = scores[UserEmotionState.neutral]! + 10;
        scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 5;
        break;
        
      case >= 18 && < 22:
        // 저녁 시간대: 편안함
        scores[UserEmotionState.neutral] = scores[UserEmotionState.neutral]! + 8;
        scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 7;
        break;
        
      case >= 22 || < 6:
        // 늦은 밤/새벽: 피로감
        scores[UserEmotionState.tired] = scores[UserEmotionState.tired]! + 15;
        scores[UserEmotionState.contemplative] = scores[UserEmotionState.contemplative]! + 5;
        break;
    }
    
    // 주말 보너스
    if (context.dayOfWeek == 6 || context.dayOfWeek == 7) {
      scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 5;
    }
  }
  
  /// 📊 최근 활동 패턴 분석 (10% 가중치)
  void _analyzeRecentActivityPattern(
    EmotionAnalysisContext context, 
    Map<UserEmotionState, double> scores
  ) {
    final recentActivities = context.recentActivities;
    
    if (recentActivities.length >= 5) {
      // 활발한 활동: 동기부여 상승
      scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 8;
      scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 5;
    } else if (recentActivities.length <= 1) {
      // 활동 부족: 중립 또는 고민
      scores[UserEmotionState.neutral] = scores[UserEmotionState.neutral]! + 8;
      scores[UserEmotionState.contemplative] = scores[UserEmotionState.contemplative]! + 5;
    }
    
    // 다양성 분석
    final uniqueActivities = recentActivities.toSet().length;
    if (uniqueActivities >= 3) {
      scores[UserEmotionState.excited] = scores[UserEmotionState.excited]! + 5;
    }
  }
  
  /// 📈 성과 데이터 분석 (10% 가중치)
  void _analyzePerformanceData(
    EmotionAnalysisContext context, 
    Map<UserEmotionState, double> scores
  ) {
    final performanceData = context.performanceData;
    
    // 성과 추세 분석
    final trend = performanceData['trend'] as String?;
    switch (trend) {
      case 'improving':
        scores[UserEmotionState.motivated] = scores[UserEmotionState.motivated]! + 8;
        scores[UserEmotionState.positive] = scores[UserEmotionState.positive]! + 5;
        break;
      case 'declining':
        scores[UserEmotionState.negative] = scores[UserEmotionState.negative]! + 8;
        scores[UserEmotionState.contemplative] = scores[UserEmotionState.contemplative]! + 5;
        break;
      case 'stable':
        scores[UserEmotionState.neutral] = scores[UserEmotionState.neutral]! + 5;
        break;
    }
    
    // 목표 달성률 분석
    final achievementRate = performanceData['achievement_rate'] as double?;
    if (achievementRate != null) {
      if (achievementRate >= 0.8) {
        scores[UserEmotionState.excited] = scores[UserEmotionState.excited]! + 5;
      } else if (achievementRate <= 0.3) {
        scores[UserEmotionState.stressed] = scores[UserEmotionState.stressed]! + 5;
      }
    }
  }
  
  /// 🎭 감정에 맞는 Sherpi 감정 추천
  SherpiEmotion recommendSherpiEmotion(UserEmotionState userEmotion) {
    switch (userEmotion) {
      case UserEmotionState.positive:
        return SherpiEmotion.happy;
        
      case UserEmotionState.negative:
        return SherpiEmotion.guiding; // 위로하고 안내하는 모습
        
      case UserEmotionState.neutral:
        return SherpiEmotion.defaults;
        
      case UserEmotionState.motivated:
        return SherpiEmotion.cheering; // 응원하는 모습
        
      case UserEmotionState.tired:
        return SherpiEmotion.guiding; // 부드럽게 안내
        
      case UserEmotionState.excited:
        return SherpiEmotion.special; // 특별한 순간 함께 축하
        
      case UserEmotionState.stressed:
        return SherpiEmotion.guiding; // 차분하게 안내
        
      case UserEmotionState.contemplative:
        return SherpiEmotion.thinking; // 함께 생각하는 모습
    }
  }
  
  /// 📊 감정 동기화 수준 계산
  double calculateEmotionalSync(
    List<EmotionAnalysisResult> recentAnalyses,
    List<SherpiEmotion> sherpiResponses,
  ) {
    if (recentAnalyses.isEmpty || sherpiResponses.isEmpty) {
      return 0.0;
    }
    
    double syncScore = 0.0;
    int validComparisons = 0;
    
    final maxComparisons = min(recentAnalyses.length, sherpiResponses.length);
    
    for (int i = 0; i < maxComparisons; i++) {
      final userEmotion = recentAnalyses[i].primaryEmotion;
      final sherpiEmotion = sherpiResponses[i];
      final recommendedEmotion = recommendSherpiEmotion(userEmotion);
      
      // 권장 감정과 실제 감정의 일치도 계산
      if (sherpiEmotion == recommendedEmotion) {
        syncScore += 1.0;
      } else if (_isCompatibleEmotion(sherpiEmotion, recommendedEmotion)) {
        syncScore += 0.7; // 호환 가능한 감정
      } else if (_isNeutralMatch(sherpiEmotion, recommendedEmotion)) {
        syncScore += 0.3; // 중립적 매치
      }
      
      validComparisons++;
    }
    
    return validComparisons > 0 ? syncScore / validComparisons : 0.0;
  }
  
  /// 😊 호환 가능한 감정인지 확인
  bool _isCompatibleEmotion(SherpiEmotion actual, SherpiEmotion recommended) {
    final compatibilityMap = {
      SherpiEmotion.happy: [SherpiEmotion.cheering, SherpiEmotion.special],
      SherpiEmotion.cheering: [SherpiEmotion.happy, SherpiEmotion.special],
      SherpiEmotion.guiding: [SherpiEmotion.thinking, SherpiEmotion.defaults],
      SherpiEmotion.thinking: [SherpiEmotion.guiding, SherpiEmotion.defaults],
      SherpiEmotion.special: [SherpiEmotion.cheering, SherpiEmotion.happy],
    };
    
    return compatibilityMap[recommended]?.contains(actual) ?? false;
  }
  
  /// 😐 중립적 매치인지 확인
  bool _isNeutralMatch(SherpiEmotion actual, SherpiEmotion recommended) {
    // 중립적인 감정들
    final neutralEmotions = [
      SherpiEmotion.defaults,
      SherpiEmotion.sleeping,
    ];
    
    return neutralEmotions.contains(actual) || neutralEmotions.contains(recommended);
  }
  
  /// 🎯 감정 동기화 레벨 가져오기
  EmotionalSyncLevel getEmotionalSyncLevel(double syncValue) {
    return EmotionalSyncLevelExtension.fromValue(syncValue);
  }
}