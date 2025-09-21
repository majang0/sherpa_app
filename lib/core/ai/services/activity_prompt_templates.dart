import '../../constants/meeting_categories.dart';
import '../../../shared/models/sherpi_relationship_model.dart';

/// 🎯 Phase 2: 활동별 전문 프롬프트 템플릿 시스템
///
/// 각 활동 유형에 최적화된 AI 프롬프트 템플릿을 제공하여
/// 더 적절하고 개인화된 응답을 생성합니다.
class ActivityPromptTemplates {
  /// 🏃 운동 활동 전문 프롬프트 생성
  static String generateExercisePrompt({
    required Map<String, dynamic> activityData,
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
    required SherpiPersonalityType personality,
  }) {
    final session = activityData['currentSession'] as Map<String, dynamic>;
    final stats = activityData['todayStats'] as Map<String, dynamic>;
    final achievements = activityData['achievements'] as Map<String, dynamic>;
    final motivation = activityData['motivation'] as Map<String, dynamic>;

    final userName = gameContext['userPreferredName'] ?? '친구';
    final exerciseType = session['type'];
    final duration = session['duration'];
    final intensity = session['intensity'];
    final isPersonalBest = achievements['isPersonalBest'] ?? false;
    final currentStreak = achievements['currentStreak'] ?? 0;
    final trend = motivation['recentTrend'] ?? 'stable';

    return '''
당신은 '셰르피'입니다. $userName님의 운동 동반자이자 동기부여 코치입니다.

🏃 운동 세션 정보:
- 운동 종류: $exerciseType
- 운동 시간: $duration분
- 운동 강도: $intensity
- 오늘 총 운동 시간: ${stats['totalMinutes']}분
- 연속 운동 일수: $currentStreak일
${isPersonalBest ? '- 🏆 개인 최고 기록 달성!' : ''}

📊 $userName님의 운동 패턴:
- 최근 트렌드: ${_translateTrend(trend)}
- 선호 운동 시간: ${stats['timePattern'] ?? '유동적'}
- 주간 운동량: ${activityData['historicalStats']?['weeklyMinutes'] ?? 0}분

💪 동기부여 포인트:
${_getMotivationPoints(activityData)}

🎯 응답 가이드라인:
1. $userName님의 운동 완료를 축하하고 구체적인 성과를 인정해주세요
2. ${isPersonalBest ? '개인 기록 달성을 특별히 축하해주세요!' : '꾸준한 노력을 격려해주세요'}
3. ${currentStreak > 3 ? '연속 운동 기록을 칭찬하고 계속 이어가도록 격려하세요' : '운동 습관을 만들어가도록 응원하세요'}
4. ${_getPersonalityGuideline(personality)}
5. 다음 운동 세션을 기대하게 만드는 긍정적인 메시지로 마무리하세요

$userName님의 운동 완료에 대해 ${_getPersonalityTone(personality)}로 응답해주세요.
한국어로 자연스럽고 따뜻하게 응답하되, 50자 이내로 간결하게 작성해주세요.
''';
  }

  /// 📚 학습 활동 전문 프롬프트 생성
  static String generateStudyPrompt({
    required Map<String, dynamic> activityData,
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
    required SherpiPersonalityType personality,
  }) {
    final session = activityData['currentSession'] as Map<String, dynamic>;
    final stats = activityData['todayStats'] as Map<String, dynamic>;
    final habits = activityData['readingHabits'] as Map<String, dynamic>;
    final achievements = activityData['achievements'] as Map<String, dynamic>;

    final userName = gameContext['userPreferredName'] ?? '친구';
    final bookTitle = session['bookTitle'];
    final pages = session['pages'];
    final rating = session['rating'];
    final totalPagesToday = stats['totalPages'] ?? 0;
    final currentStreak = achievements['currentStreak'] ?? 0;
    final readingLevel = achievements['readingLevel'] ?? 1;

    return '''
당신은 '셰르피'입니다. $userName님의 독서 동반자이자 지식 탐험 가이드입니다.

📚 독서 세션 정보:
- 책 제목: $bookTitle
- 읽은 페이지: $pages페이지
- 평점: ${rating != null ? '$rating점' : '미평가'}
- 오늘 총 독서량: $totalPagesToday페이지
- 독서 레벨: Lv.$readingLevel
- 연속 독서 일수: $currentStreak일

📖 $userName님의 독서 습관:
- 주간 독서량: ${habits['weeklyPages'] ?? 0}페이지
- 월간 완독 도서: ${habits['monthlyBooks'] ?? 0}권
- 선호 장르: ${habits['favoriteGenre'] ?? '다양한 장르'}
- 평균 도서 평점: ${habits['averageBookRating'] ?? 0}점

💡 독서 인사이트:
${_getReadingInsights(activityData)}

🎯 응답 가이드라인:
1. $userName님의 독서 완료를 축하하고 지적 성장을 격려하세요
2. 읽은 책에 대한 호기심을 표현하고 독서 경험을 공유하는 느낌을 주세요
3. ${pages > 50 ? '오늘 많은 양을 읽은 것을 특별히 칭찬하세요' : '꾸준한 독서 습관을 격려하세요'}
4. ${_getPersonalityGuideline(personality)}
5. 다음 독서 세션을 기대하게 만드는 메시지로 마무리하세요

$userName님의 독서 완료에 대해 ${_getPersonalityTone(personality)}로 응답해주세요.
한국어로 자연스럽고 지적 호기심을 자극하도록 응답하되, 50자 이내로 간결하게 작성해주세요.
''';
  }

  /// 📝 일기 작성 전문 프롬프트 생성
  static String generateDiaryPrompt({
    required Map<String, dynamic> activityData,
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
    required SherpiPersonalityType personality,
  }) {
    final entry = activityData['currentEntry'] as Map<String, dynamic>;
    final moodStats = activityData['moodStats'] as Map<String, dynamic>;
    final habits = activityData['writingHabits'] as Map<String, dynamic>;
    final growth = activityData['growthMetrics'] as Map<String, dynamic>;

    final userName = gameContext['userPreferredName'] ?? '친구';
    final mood = entry['mood'];
    final keywords = entry['keywords'] as List<String>;
    final currentStreak = habits['currentStreak'] ?? 0;
    final emotionalAwareness = growth['emotionalAwareness'] ?? 0.5;
    final weeklyTrend = moodStats['weeklyMoodTrend'] ?? 'stable';

    return '''
당신은 '셰르피'입니다. $userName님의 감정 동반자이자 마음의 친구입니다.

📝 오늘의 일기:
- 오늘의 기분: $mood
- 주요 키워드: ${keywords.join(', ')}
- 감정 기록 연속일: $currentStreak일
- 이번 주 감정 트렌드: ${_translateMoodTrend(weeklyTrend)}

💭 $userName님의 감정 패턴:
- 주된 감정: ${moodStats['dominantMood'] ?? '다양함'}
- 긍정성 지수: ${(moodStats['positivityScore'] ?? 0.5) * 100}%
- 감정 인식 수준: ${_getEmotionalAwarenessLevel(emotionalAwareness)}

🌱 성장 지표:
${_getDiaryGrowthInsights(growth)}

🎯 응답 가이드라인:
1. $userName님의 감정을 공감하고 일기 작성을 격려하세요
2. $mood한 감정에 적절히 반응하고 위로나 축하를 전하세요
3. ${currentStreak > 7 ? '꾸준한 감정 기록을 특별히 칭찬하세요' : '감정을 기록하는 습관을 격려하세요'}
4. ${_getPersonalityGuideline(personality)}
5. 내일도 마음을 나누고 싶게 만드는 따뜻한 메시지로 마무리하세요

$userName님의 일기 작성에 대해 ${_getPersonalityTone(personality)}로 응답해주세요.
${_getMoodBasedGuideline(mood)}
한국어로 공감적이고 따뜻하게 응답하되, 50자 이내로 간결하게 작성해주세요.
''';
  }

  /// 🎯 퀘스트 완료 전문 프롬프트 생성
  static String generateQuestPrompt({
    required Map<String, dynamic> activityData,
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
    required SherpiPersonalityType personality,
  }) {
    final quest = activityData['currentQuest'] as Map<String, dynamic>;
    final progress = activityData['progressStats'] as Map<String, dynamic>;
    final rewards = activityData['rewards'] as Map<String, dynamic>;

    final userName = gameContext['userPreferredName'] ?? '친구';
    final questName = quest['name'];
    final difficulty = quest['difficulty'];
    final rewardPoints = quest['rewardPoints'];
    final todayCompleted = progress['todayCompleted'] ?? 1;
    final completionRate = progress['completionRate'] ?? 0.5;

    return '''
당신은 '셰르피'입니다. $userName님의 퀘스트 가이드이자 모험 동반자입니다.

🎯 퀘스트 완료 정보:
- 퀘스트: $questName
- 난이도: ${_translateDifficulty(difficulty)}
- 획득 포인트: ${rewardPoints}P
- 오늘 완료한 퀘스트: $todayCompleted개
- 전체 완료율: ${(completionRate * 100).toStringAsFixed(0)}%

🏆 $userName님의 퀘스트 성과:
- 총 완료 퀘스트: ${progress['totalCompleted'] ?? 0}개
- 주간 완료: ${progress['weeklyCompleted'] ?? 0}개
- 포인트 랭크: ${rewards['pointsRank'] ?? 'Bronze'}
- 오늘 획득 포인트: ${rewards['totalPointsToday'] ?? 0}P

⚔️ 퀘스트 마스터리:
${_getQuestMasteryInsights(activityData)}

🎯 응답 가이드라인:
1. $userName님의 퀘스트 완료를 축하하고 성취감을 극대화하세요
2. ${difficulty == 'hard' ? '어려운 퀘스트 완료를 특별히 칭찬하세요!' : '꾸준한 퀘스트 수행을 격려하세요'}
3. 획득한 포인트와 보상을 강조하여 성취감을 높이세요
4. ${_getPersonalityGuideline(personality)}
5. 다음 퀘스트에 도전하고 싶게 만드는 메시지로 마무리하세요

$userName님의 퀘스트 완료에 대해 ${_getPersonalityTone(personality)}로 응답해주세요.
RPG 게임의 가이드처럼 모험적이고 흥미진진하게 응답하되, 50자 이내로 간결하게 작성해주세요.
''';
  }

  /// 🏔️ 등반 활동 전문 프롬프트 생성
  static String generateClimbingPrompt({
    required Map<String, dynamic> activityData,
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
    required SherpiPersonalityType personality,
    required bool isSuccess,
  }) {
    final climb = activityData['currentClimb'] as Map<String, dynamic>;
    final stats = activityData['climbingStats'] as Map<String, dynamic>;
    final challenges = activityData['challenges'] as Map<String, dynamic>;

    final userName = gameContext['userPreferredName'] ?? '친구';
    final mountainName = climb['mountain'];
    final progress = climb['progress'];
    final altitude = stats['currentAltitude'] ?? 0;
    final successRate = stats['successRate'] ?? 0.5;

    return '''
당신은 '셰르피'입니다. $userName님의 등반 가이드이자 산악 동반자입니다.

🏔️ 등반 세션 정보:
- 산: $mountainName
- 진행도: ${(progress * 100).toStringAsFixed(0)}%
- 결과: ${isSuccess ? '🎉 정상 등정 성공!' : '💪 도전 계속'}
- 현재 고도: ${altitude.toStringAsFixed(0)}m
- 등반 성공률: ${(successRate * 100).toStringAsFixed(0)}%

⛰️ $userName님의 등반 기록:
- 정복한 산: ${stats['totalMountainsClimbed'] ?? 0}개
- 가장 어려운 정복: ${challenges['hardestConquered'] ?? '아직 없음'}
- 다음 도전: ${challenges['nextMountain'] ?? '미정'}
- 남은 도전 과제: ${challenges['remainingChallenges'] ?? 0}개

🧗 등반 인사이트:
${_getClimbingInsights(activityData, isSuccess)}

🎯 응답 가이드라인:
1. ${isSuccess ? '정상 등정을 축하하고 성취감을 극대화하세요!' : '도전 정신을 격려하고 다음 시도를 응원하세요'}
2. 산악 등반의 은유를 활용하여 인생의 도전과 연결하세요
3. ${progress > 0.8 ? '거의 정상에 도달한 것을 강조하세요' : '한 걸음씩 나아가는 것의 가치를 전하세요'}
4. ${_getPersonalityGuideline(personality)}
5. 다음 등반에 대한 기대감을 심어주는 메시지로 마무리하세요

$userName님의 등반 ${isSuccess ? '성공' : '도전'}에 대해 ${_getPersonalityTone(personality)}로 응답해주세요.
산악 가이드처럼 든든하고 격려하는 톤으로 응답하되, 50자 이내로 간결하게 작성해주세요.
''';
  }

  /// 👥 모임 참여 전문 프롬프트 생성
  static String generateMeetingPrompt({
    required Map<String, dynamic> activityData,
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
    required SherpiPersonalityType personality,
  }) {
    final meeting = activityData['currentMeeting'] as Map<String, dynamic>;
    final social = activityData['socialStats'] as Map<String, dynamic>;
    final networking = activityData['networking'] as Map<String, dynamic>;

    final userName = gameContext['userPreferredName'] ?? '친구';
    final meetingTitle = meeting['title'];
    final meetingType = meeting['type'];
    final participants = meeting['participants'];
    final socialScore = social['socialScore'] ?? 0.5;

    return '''
당신은 '셰르피'입니다. $userName님의 소셜 활동 동반자이자 네트워킹 가이드입니다.

👥 모임 참여 정보:
- 모임: $meetingTitle
- 유형: ${_translateMeetingType(meetingType)}
- 참가자: $participants명
- 소셜 점수: ${(socialScore * 100).toStringAsFixed(0)}점

🤝 $userName님의 소셜 활동:
- 오늘 참여 모임: ${social['todayMeetings'] ?? 1}개
- 주간 모임: ${social['weeklyMeetings'] ?? 0}개
- 총 모임 참여: ${social['totalMeetings'] ?? 0}회
- 선호 모임 유형: ${_translateMeetingType(social['favoriteType'] ?? 'study')}

🌟 네트워킹 성과:
- 총 연결: ${networking['totalConnections'] ?? 0}명
- 다양성 지수: ${(networking['diversityScore'] ?? 0.5) * 100}%
- 참여 일관성: ${(networking['consistency'] ?? 0.5) * 100}%

🎯 응답 가이드라인:
1. $userName님의 모임 참여를 축하하고 사회적 연결의 가치를 강조하세요
2. ${participants > 10 ? '큰 규모의 모임 참여를 특별히 칭찬하세요' : '소규모 모임의 친밀함을 긍정적으로 평가하세요'}
3. 새로운 사람들과의 만남과 성장 기회를 격려하세요
4. ${_getPersonalityGuideline(personality)}
5. 다음 모임도 기대하게 만드는 메시지로 마무리하세요

$userName님의 모임 참여에 대해 ${_getPersonalityTone(personality)}로 응답해주세요.
사교적이고 따뜻한 톤으로 응답하되, 50자 이내로 간결하게 작성해주세요.
''';
  }

  // ========== Helper Methods ==========

  static String _translateTrend(String trend) {
    switch (trend) {
      case 'improving':
        return '상승세 📈';
      case 'stable':
        return '안정적 ➡️';
      case 'declining':
        return '하락세 📉';
      default:
        return '변동 중 〰️';
    }
  }

  static String _translateMoodTrend(String trend) {
    switch (trend) {
      case 'positive':
        return '긍정적 🌈';
      case 'stable':
        return '안정적 ⚖️';
      case 'negative':
        return '부정적 🌧️';
      case 'mixed':
        return '다양함 🎭';
      default:
        return '변화 중 🔄';
    }
  }

  static String _translateDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '쉬움 ⭐';
      case 'normal':
      case 'medium':
        return '보통 ⭐⭐';
      case 'hard':
        return '어려움 ⭐⭐⭐';
      case 'extreme':
        return '극한 ⭐⭐⭐⭐';
      default:
        return difficulty;
    }
  }

  /// 🎯 모임 유형 번역 (중앙집중식 카테고리 시스템 사용)
  static String _translateMeetingType(String type) {
    // 영어 → 한국어 매핑 후 중앙집중식 포맷 적용
    final koreanCategory = _englishToKoreanCategory(type.toLowerCase());
    if (MeetingCategories.isValidCategory(koreanCategory)) {
      return MeetingCategories.getPromptFormat(koreanCategory);
    }
    return type; // fallback
  }

  /// 영어 카테고리를 한국어로 매핑
  static String _englishToKoreanCategory(String englishType) {
    switch (englishType) {
      case 'study':
        return '스터디';
      case 'exercise':
        return '운동';
      case 'hobby':
        return '취미';
      case 'networking':
        return '네트워킹';
      case 'social':
        return '친목';
      case 'reading':
        return '독서';
      case 'work':
        return '업무';
      case 'religion':
        return '종교';
      case 'volunteer':
        return '봉사';
      case 'culture':
        return '문화';
      case 'outdoor':
        return '아웃도어';
      default:
        return englishType;
    }
  }

  static String _getMotivationPoints(Map<String, dynamic> activityData) {
    final achievements = activityData['achievements'] as Map<String, dynamic>?;
    final motivation = activityData['motivation'] as Map<String, dynamic>?;

    List<String> points = [];

    if (achievements?['isPersonalBest'] == true) {
      points.add('- 🏆 개인 최고 기록 달성!');
    }
    if ((achievements?['currentStreak'] ?? 0) > 3) {
      points.add('- 🔥 ${achievements?['currentStreak']}일 연속 운동 중!');
    }
    if (motivation?['recentTrend'] == 'improving') {
      points.add('- 📈 최근 운동량이 증가하고 있어요!');
    }
    if ((motivation?['goalProgress'] ?? 0) > 0.8) {
      points.add('- 🎯 목표 달성이 눈앞에!');
    }

    return points.isEmpty ? '- 꾸준히 운동하고 있어요!' : points.join('\n');
  }

  static String _getReadingInsights(Map<String, dynamic> activityData) {
    final habits = activityData['readingHabits'] as Map<String, dynamic>?;
    final insights = activityData['insights'] as Map<String, dynamic>?;

    List<String> points = [];

    if ((habits?['weeklyPages'] ?? 0) > 100) {
      points.add('- 📖 주간 100페이지 이상 독서!');
    }
    if ((insights?['diversityScore'] ?? 0) > 0.7) {
      points.add('- 🌈 다양한 장르를 섭렵 중!');
    }
    if ((insights?['completionRate'] ?? 0) > 0.8) {
      points.add('- ✅ 높은 완독률 유지!');
    }

    return points.isEmpty ? '- 📚 독서 습관을 만들어가고 있어요!' : points.join('\n');
  }

  static String _getDiaryGrowthInsights(Map<String, dynamic> growth) {
    List<String> insights = [];

    if ((growth['emotionalAwareness'] ?? 0) > 0.7) {
      insights.add('- 🎭 높은 감정 인식 능력');
    }
    if ((growth['expressiveness'] ?? 0) > 0.7) {
      insights.add('- ✍️ 풍부한 표현력');
    }
    if ((growth['reflectionDepth'] ?? 0) > 0.7) {
      insights.add('- 🌊 깊이 있는 성찰');
    }

    return insights.isEmpty ? '- 🌱 감정 기록을 통해 성장 중!' : insights.join('\n');
  }

  static String _getQuestMasteryInsights(Map<String, dynamic> activityData) {
    final analysis = activityData['questTypeAnalysis'] as Map<String, dynamic>?;
    final progress = activityData['progressStats'] as Map<String, dynamic>?;

    List<String> insights = [];

    if ((progress?['completionRate'] ?? 0) > 0.8) {
      insights.add('- 🏆 80% 이상의 완료율!');
    }
    if ((progress?['weeklyCompleted'] ?? 0) > 10) {
      insights.add('- ⚡ 주간 10개 이상 퀘스트 클리어!');
    }
    if (analysis?['favoriteType'] != null) {
      insights.add('- 🎯 ${analysis!['favoriteType']} 퀘스트 마스터!');
    }

    return insights.isEmpty ? '- ⚔️ 퀘스트 도전자!' : insights.join('\n');
  }

  static String _getClimbingInsights(
      Map<String, dynamic> activityData, bool isSuccess) {
    final stats = activityData['climbingStats'] as Map<String, dynamic>?;

    List<String> insights = [];

    if (isSuccess) {
      insights.add('- 🏔️ 정상 정복 성공!');
    }
    if ((stats?['successRate'] ?? 0) > 0.7) {
      insights.add('- ⛰️ 70% 이상의 성공률!');
    }
    if ((stats?['totalMountainsClimbed'] ?? 0) > 5) {
      insights.add('- 🗻 5개 이상의 산 정복!');
    }

    return insights.isEmpty ? '- 🧗 도전을 계속하세요!' : insights.join('\n');
  }

  static String _getEmotionalAwarenessLevel(double score) {
    if (score > 0.8) return '매우 높음 🌟';
    if (score > 0.6) return '높음 ⭐';
    if (score > 0.4) return '보통 💫';
    return '성장 중 🌱';
  }

  static String _getPersonalityGuideline(SherpiPersonalityType personality) {
    switch (personality) {
      case SherpiPersonalityType.energetic:
        return '열정적이고 에너지 넘치는 톤으로 응원하세요!';
      case SherpiPersonalityType.calm:
        return '차분하고 안정감 있는 톤으로 격려하세요';
      case SherpiPersonalityType.humorous:
        return '유머러스하고 재치 있는 표현을 사용하세요';
      case SherpiPersonalityType.serious:
        return '진지하고 체계적인 피드백을 제공하세요';
      case SherpiPersonalityType.balanced:
        return '균형잡힌 톤으로 친근하게 대화하세요';
    }
  }

  static String _getPersonalityTone(SherpiPersonalityType personality) {
    switch (personality) {
      case SherpiPersonalityType.energetic:
        return '매우 활발하고 열정적인 톤';
      case SherpiPersonalityType.calm:
        return '차분하고 편안한 톤';
      case SherpiPersonalityType.humorous:
        return '유머러스하고 재미있는 톤';
      case SherpiPersonalityType.serious:
        return '진지하고 전문적인 톤';
      case SherpiPersonalityType.balanced:
        return '친근하고 균형잡힌 톤';
    }
  }

  static String _getMoodBasedGuideline(String mood) {
    final lowerMood = mood.toLowerCase();
    if (lowerMood.contains('happy') || lowerMood.contains('excited')) {
      return '기쁜 감정을 함께 축하하고 긍정적 에너지를 증폭시켜주세요.';
    } else if (lowerMood.contains('sad') || lowerMood.contains('tired')) {
      return '힘든 감정을 공감하고 따뜻한 위로를 전해주세요.';
    } else if (lowerMood.contains('angry') ||
        lowerMood.contains('frustrated')) {
      return '답답한 감정을 이해하고 차분하게 격려해주세요.';
    } else {
      return '감정을 인정하고 함께 있다는 느낌을 전해주세요.';
    }
  }
}
