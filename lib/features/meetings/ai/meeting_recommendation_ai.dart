/// AI 기반 모임 추천 엔진
/// OpenAI GPT-5를 활용하여 사용자 맞춤형 모임을 추천
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sherpa_app/core/ai/sources/openai_dialogue_source.dart';
import 'package:sherpa_app/features/sherpi/domain/services/sherpi_insight_repository.dart';

import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../shared/models/global_user_model.dart';
import '../models/available_meeting_model.dart';
import 'user_activity_analyzer.dart';
import 'recommendation_prompt_builder.dart';
import 'models/ai_recommended_meeting.dart';
import 'models/user_activity_pattern.dart';

/// AI 모임 추천 엔진
class MeetingRecommendationAI {
  final UserActivityAnalyzer _analyzer = UserActivityAnalyzer();
  final RecommendationPromptBuilder _promptBuilder =
      RecommendationPromptBuilder();

  // AI 소스 (OpenAI 또는 대체)
  OpenAIDialogueSource? _aiSource;

  // 캐시 키
  static const String _cacheKeyPrefix = 'ai_meeting_recommendation_';
  static const Duration _cacheDuration = Duration(hours: 24);

  // 🎯 운동 종류별 키워드 매핑 (제목 매칭용) - 영어/한글 모두 key로 사용 가능
  static const Map<String, List<String>> _exerciseKeywordMap = {
    '러닝': ['러닝', '달리기', '뛰기', '조깅', 'running', 'run', '마라톤', '새벽 러닝'],
    'running': ['러닝', '달리기', '뛰기', '조깅', 'running', 'run', '마라톤', '새벽 러닝'],
    '홈트': ['홈트', '홈트레이닝', '홈 트레이닝', '집에서', '온라인 운동', 'home training'],
    '요가': ['요가', 'yoga', '스트레칭', '필라테스', 'pilates', '힐링'],
    'yoga': ['요가', 'yoga', '스트레칭', '필라테스', 'pilates', '힐링'],
    '축구': ['축구', 'soccer', 'football', '풋살', '풋볼'],
    '농구': ['농구', 'basketball', '3대3', '바스켓볼'],
    '수영': ['수영', 'swimming', '수중', '물놀이', '아쿠아'],
    'swimming': ['수영', 'swimming', '수중', '물놀이', '아쿠아'],
    '자전거': ['자전거', '사이클', '라이딩', 'cycling', 'bike', '바이크'],
    'cycling': ['자전거', '사이클', '라이딩', 'cycling', 'bike', '바이크'],
    '등산': ['등산', '산행', '트래킹', 'hiking', '하이킹', '산책'],
    'hiking': ['등산', '산행', '트래킹', 'hiking', '하이킹', '산책'],
    '헬스': ['헬스', '웨이트', '근력', '무게', 'gym', 'fitness', '피트니스'],
    'gym': ['헬스', '웨이트', '근력', '무게', 'gym', 'fitness', '피트니스'],
    '걷기': ['걷기', '산책', '워킹', 'walking', '한강', '공원'],
    'walking': ['걷기', '산책', '워킹', 'walking', '한강', '공원'],
  };

  // 📚 독서 장르별 키워드 매핑
  static const Map<String, List<String>> _readingKeywordMap = {
    '자기계발': ['자기계발', '성장', '습관', '동기부여', '성공', '아토믹', '해빗'],
    '소설': ['소설', '문학', '장편', '단편', '픽션', '로맨스'],
    '경영': ['경영', '비즈니스', '경제', '창업', '리더십', '마케팅'],
    '과학': ['과학', '과학책', '사이언스', '우주', '물리', '생물'],
    '역사': ['역사', '역사책', '한국사', '세계사', '사피엔스'],
    '철학': ['철학', '사상', '인문학', '고전', '윤리'],
  };

  /// 초기화
  Future<void> initialize() async {
    try {
      _aiSource = OpenAIDialogueSource();
      // OpenAI doesn't need initialization
      // await _aiSource?.initialize();
      debugPrint('🤖 AI 모임 추천 엔진 초기화 완료');
    } catch (e) {
      debugPrint('⚠️ AI 초기화 실패, 폴백 모드로 동작: $e');
      _aiSource = null;
    }
  }

  /// AI 추천 가져오기
  Future<List<AIRecommendedMeeting>> getAIRecommendations({
    required GlobalUser user,
    required List<AvailableMeeting> availableMeetings,
    bool useCache = true,
    bool forceRefresh = false, // 캐시 강제 새로고침 옵션 추가
    SherpiInsights? sherpiInsights,
  }) async {
    try {
      // 1. 캐시 확인 (forceRefresh가 true면 캐시 무시)
      if (forceRefresh) {
        debugPrint('🔄 캐시 강제 새로고침 요청');
        await clearCache(user.id);
      }

      // 2. 사용자 활동 분석
      final userPattern = _analyzer.analyzeUserActivity(user);
      debugPrint('📊 사용자 활동 패턴 분석 완료');

      // 3. 참여 가능한 모임 필터링
      final availableMeetingsList = availableMeetings
          .where((m) => m.currentParticipants < m.maxParticipants)
          .toList();

      if (availableMeetingsList.isEmpty) {
        debugPrint('⚠️ 참여 가능한 모임이 없음');
        return [];
      }

      final meetingSetHash = _computeMeetingSetHash(availableMeetingsList);

      if (useCache && !forceRefresh) {
        final cached = await _getCachedRecommendations(
          user.id,
          availableMeetingsList,
          meetingSetHash,
        );
        if (cached != null && cached.isNotEmpty) {
          debugPrint('📦 캐시된 AI 추천 사용');
          return cached;
        }
      }

      // 4. AI 추천 생성
      List<AIRecommendedMeeting> recommendations;

      if (_aiSource != null) {
        // AI 사용 가능
        recommendations = await _getAIGeneratedRecommendations(
          userPattern,
          availableMeetingsList,
          sherpiInsights,
        );
      } else {
        // AI 사용 불가 - 규칙 기반 폴백
        recommendations = _getRuleBasedRecommendations(
          userPattern,
          availableMeetingsList,
        );
      }

      // 5. 결과 캐싱
      if (useCache && recommendations.isNotEmpty) {
        await _cacheRecommendations(
          user.id,
          meetingSetHash,
          recommendations,
        );
      }

      return recommendations;
    } catch (e, stackTrace) {
      debugPrint('❌ AI 추천 생성 실패: $e');
      debugPrint('Stack trace: $stackTrace');

      // 에러 시 규칙 기반 폴백
      return _getEmergencyFallback(availableMeetings);
    }
  }

  /// AI를 통한 추천 생성
  Future<List<AIRecommendedMeeting>> _getAIGeneratedRecommendations(
    UserActivityPattern userPattern,
    List<AvailableMeeting> meetings,
    SherpiInsights? sherpiInsights,
  ) async {
    try {
      // 프롬프트 생성
      final prompt = _promptBuilder.buildPrompt(
        userPattern: userPattern,
        availableMeetings: meetings,
        sherpiInsights: sherpiInsights,
      );

      debugPrint('🤖 AI에게 추천 요청 중... (${meetings.length}개 모임 중)');

      // OpenAI API 호출
      // Call OpenAI with the prompt directly
      final response = await _aiSource!.getDialogue(
        SherpiContext.guidance, // Using guidance context for AI recommendations
        {'prompt': prompt},
        {'meetingCount': meetings.length},
      );

      debugPrint(
          '✅ AI 응답 수신: ${response.substring(0, response.length > 100 ? 100 : response.length)}...');

      // 응답 파싱
      final parsedRecommendations = _promptBuilder.parseAIResponse(response);

      // AIRecommendedMeeting 객체로 변환
      final recommendations = <AIRecommendedMeeting>[];

      for (var rec in parsedRecommendations.take(3)) {
        // 최대 3개
        final meetingId = rec['meetingId'] as String?;
        if (meetingId == null) continue;

        // 해당 모임 찾기
        final meeting = meetings.firstWhere(
          (m) => m.id == meetingId,
          orElse: () => meetings.first, // 못 찾으면 첫 번째 모임 사용
        );

        recommendations.add(AIRecommendedMeeting.fromJson(rec, meeting));
      }

      // 추천이 부족하면 규칙 기반으로 보충
      if (recommendations.length < 3) {
        final ruleBased = _getRuleBasedRecommendations(userPattern, meetings);
        for (var rb in ruleBased) {
          if (recommendations.length >= 3) break;
          if (!recommendations.any((r) => r.meeting.id == rb.meeting.id)) {
            recommendations.add(rb);
          }
        }
      }

      return recommendations;
    } catch (e) {
      debugPrint('⚠️ AI 추천 생성 중 오류, 규칙 기반으로 전환: $e');
      return _getRuleBasedRecommendations(userPattern, meetings);
    }
  }

  /// 규칙 기반 추천 (AI 사용 불가 시)
  List<AIRecommendedMeeting> _getRuleBasedRecommendations(
    UserActivityPattern userPattern,
    List<AvailableMeeting> meetings,
  ) {
    debugPrint('📏 규칙 기반 추천 생성 중...');
    debugPrint('📊 사용자 활동 패턴:');
    debugPrint(
        '  - 운동: ${userPattern.exercisePattern.mainTypes.join(", ")} (주 ${userPattern.exercisePattern.frequency}회)');
    debugPrint(
        '  - 독서: ${userPattern.readingPattern.mainCategories.join(", ")} (주 ${userPattern.readingPattern.booksPerWeek.toStringAsFixed(1)}권)');
    debugPrint(
        '  - 모임: ${userPattern.meetingPattern.preferredCategories.join(", ")} (주 ${userPattern.meetingPattern.averagePerWeek.toStringAsFixed(1)}회)');
    debugPrint('📋 평가할 모임 ${meetings.length}개');

    // 각 모임에 대한 점수 계산
    final scoredMeetings = <MapEntry<AvailableMeeting, double>>[];

    for (var meeting in meetings) {
      double score = 0.0;
      final keyPoints = <String>[];

      // 카테고리 매칭 점수
      final categoryScore = _analyzer.calculateCategoryMatchScore(
        userPattern,
        meeting.category,
      );
      score += categoryScore * 0.3; // 제목 매칭에 가중치를 더 주기 위해 조정

      if (categoryScore > 0.5) {
        keyPoints.add('${meeting.category.displayName} 관심사 일치');
      }

      // 🎯 제목 기반 정밀 매칭 (핵심 개선)
      if (meeting.category == MeetingCategory.exercise &&
          userPattern.exercisePattern.mainTypes.isNotEmpty) {
        bool exactMatch = false;
        String matchedActivity = '';

        for (var userActivity in userPattern.exercisePattern.mainTypes) {
          debugPrint('  🔍 사용자 활동 확인: "$userActivity"');

          // 사용자 활동에 맞는 키워드 찾기 (대소문자 구분 없이)
          List<String> keywords = [];
          final userActivityLower = userActivity.toLowerCase();

          _exerciseKeywordMap.forEach((key, values) {
            if (key.toLowerCase() == userActivityLower ||
                values.any((v) => v.toLowerCase() == userActivityLower)) {
              keywords.addAll(values);
            }
          });

          // 기본 키워드가 없으면 사용자 활동 자체를 키워드로 사용
          if (keywords.isEmpty) {
            keywords = [userActivity];
            debugPrint('    ⚠️ 키워드 매핑 없음, 기본값 사용: $userActivity');
          } else {
            debugPrint('    ✅ 키워드 찾음: ${keywords.take(3).join(", ")}...');
          }

          // 모임 제목/설명에서 키워드 매칭
          final titleLower = meeting.title.toLowerCase();
          final descLower = meeting.description.toLowerCase();

          for (var keyword in keywords) {
            if (titleLower.contains(keyword.toLowerCase()) ||
                descLower.contains(keyword.toLowerCase())) {
              exactMatch = true;
              matchedActivity = userActivity;
              debugPrint('    🎯 매칭 성공! 키워드: "$keyword" in "${meeting.title}"');
              break;
            }
          }

          if (exactMatch) break;
        }

        if (exactMatch) {
          score += 0.35; // 정확한 활동 매칭 시 큰 보너스
          keyPoints.add('🎯 $matchedActivity 활동 정확 매칭');
          debugPrint('  ✅ ExactMatch=true, 보너스 +0.35');
        } else {
          // 같은 카테고리지만 다른 운동인 경우 작은 보너스 (페널티 제거)
          score += 0.05; // 같은 카테고리 보너스
          keyPoints.add('운동 카테고리 일치');
          debugPrint('  ℹ️ ExactMatch=false, 카테고리 보너스 +0.05');
        }
      }

      // 📚 독서 모임 제목 매칭
      if (meeting.category == MeetingCategory.reading &&
          userPattern.readingPattern.mainCategories.isNotEmpty) {
        bool genreMatch = false;
        String matchedGenre = '';

        for (var category in userPattern.readingPattern.mainCategories) {
          List<String> keywords = _readingKeywordMap[category] ?? [category];

          final titleLower = meeting.title.toLowerCase();
          final descLower = meeting.description.toLowerCase();

          for (var keyword in keywords) {
            if (titleLower.contains(keyword.toLowerCase()) ||
                descLower.contains(keyword.toLowerCase())) {
              genreMatch = true;
              matchedGenre = category;
              break;
            }
          }

          if (genreMatch) break;
        }

        if (genreMatch) {
          score += 0.25;
          keyPoints.add('📚 $matchedGenre 장르 매칭');
        }
      }

      // 시간대 매칭
      final meetingHour = meeting.dateTime.hour;
      String meetingPeriod = _getTimePeriod(meetingHour);

      bool timeConflict = false;
      userPattern.timePatterns.forEach((period, activities) {
        if (period == meetingPeriod && activities.isNotEmpty) {
          // 시간대 충돌
          score -= 0.2;
          timeConflict = true;
        }
      });

      if (!timeConflict) {
        score += 0.1;
        keyPoints.add('시간대 적합');
      }

      // 장소 매칭
      if (userPattern.preferredLocations.isNotEmpty) {
        for (var location in userPattern.preferredLocations) {
          if (meeting.location.contains(location)) {
            score += 0.2;
            keyPoints.add('선호 장소 근처');
            break;
          }
        }
      }

      // 인기도 보너스
      final participationRate =
          meeting.currentParticipants / meeting.maxParticipants;
      if (participationRate >= 0.3 && participationRate < 0.9) {
        score += 0.1;
        if (participationRate >= 0.5) {
          keyPoints.add('인기 모임');
        }
      }

      // 성장 지표 연계
      if (meeting.category == MeetingCategory.networking &&
          userPattern.growthStats.sociality > 50) {
        score += 0.1;
        keyPoints.add('사교성 향상');
      }
      if (meeting.category == MeetingCategory.study &&
          userPattern.growthStats.knowledge > 50) {
        score += 0.1;
        keyPoints.add('지식 확장');
      }

      // 디버깅용 로그 추가
      final finalScore = score;
      debugPrint(
          '📊 [모임] ${meeting.title}: ${finalScore.toStringAsFixed(2)}점 - ${keyPoints.join(", ")}');

      scoredMeetings.add(MapEntry(meeting, score));
    }

    // 점수순 정렬
    scoredMeetings.sort((a, b) => b.value.compareTo(a.value));

    // 다양성 보장: 같은 카테고리는 최대 2개까지만
    final recommendations = <AIRecommendedMeeting>[];
    final categoryCount = <MeetingCategory, int>{};

    for (var entry in scoredMeetings) {
      if (recommendations.length >= 3) break;

      final meeting = entry.key;
      final score = entry.value;

      // 다양성 체크: 같은 카테고리가 이미 2개 있으면 스킵
      final currentCategoryCount = categoryCount[meeting.category] ?? 0;
      if (currentCategoryCount >= 2) {
        debugPrint(
            '⚠️ [다양성] ${meeting.title} 스킵 - ${meeting.category.displayName} 카테고리 이미 2개');
        continue;
      }

      // 추천 이유 생성
      String reason = _generateRecommendationReason(
        userPattern,
        meeting,
        score,
      );

      // 키포인트 생성
      final keyPoints = _generateKeyPoints(userPattern, meeting);

      recommendations.add(AIRecommendedMeeting(
        meeting: meeting,
        matchScore: score.clamp(0.0, 1.0),
        reason: reason,
        keyPoints: keyPoints,
        priority: recommendations.length + 1,
        createdAt: DateTime.now(),
      ));

      // 카테고리 카운트 업데이트
      categoryCount[meeting.category] = currentCategoryCount + 1;
    }

    debugPrint('✅ 최종 추천 ${recommendations.length}개 생성 완료');

    return recommendations;
  }

  /// 추천 이유 생성 (구체적이고 납득 가능한 설명)
  String _generateRecommendationReason(
    UserActivityPattern pattern,
    AvailableMeeting meeting,
    double score,
  ) {
    final reasons = <String>[];

    // 운동 관련 - 매우 구체적이고 정확한 설명
    if (meeting.category == MeetingCategory.exercise &&
        pattern.exercisePattern.frequency > 0) {
      // 🎯 제목 기반 정확한 활동 매칭
      if (pattern.exercisePattern.mainTypes.isNotEmpty) {
        bool exactMatch = false;
        String matchedActivity = '';

        for (var userActivity in pattern.exercisePattern.mainTypes) {
          // 키워드 매핑 확인 (대소문자 구분 없이)
          List<String> keywords = [];
          final userActivityLower = userActivity.toLowerCase();

          _exerciseKeywordMap.forEach((key, values) {
            if (key.toLowerCase() == userActivityLower ||
                values.any((v) => v.toLowerCase() == userActivityLower)) {
              keywords.addAll(values);
            }
          });

          if (keywords.isEmpty) {
            keywords = [userActivity];
          }

          // 모임 제목/설명에서 매칭 확인
          final titleLower = meeting.title.toLowerCase();
          final descLower = meeting.description.toLowerCase();

          for (var keyword in keywords) {
            if (titleLower.contains(keyword.toLowerCase()) ||
                descLower.contains(keyword.toLowerCase())) {
              exactMatch = true;
              matchedActivity = userActivity;
              break;
            }
          }

          if (exactMatch) break;
        }

        if (exactMatch) {
          // 정확히 매칭되는 경우
          reasons.add(
              '평소 즐기시는 $matchedActivity를 "${meeting.title}"에서도 함께할 수 있어요! 완벽한 매칭이에요');
        } else if (pattern.exercisePattern.mainTypes.isNotEmpty) {
          // 같은 카테고리지만 제목이 다른 경우 - 더 적절한 메시지
          final mainType = pattern.exercisePattern.mainTypes.first;

          // 모임 제목에서 운동 종류 추출 시도
          String meetingActivity = meeting.title;
          if (meeting.title.contains('러닝')) {
            meetingActivity = '러닝';
          } else if (meeting.title.contains('홈트'))
            meetingActivity = '홈트레이닝';
          else if (meeting.title.contains('요가'))
            meetingActivity = '요가';
          else if (meeting.title.contains('헬스'))
            meetingActivity = '헬스';
          else if (meeting.title.contains('수영')) meetingActivity = '수영';

          if (meetingActivity != meeting.title) {
            reasons.add(
                '평소 $mainType을(를) 즐기시는데, $meetingActivity도 비슷한 효과를 낼 수 있어요');
          } else {
            reasons.add('평소 $mainType을(를) 즐기시는 분께 추천드리는 운동 모임이에요');
          }
        }
      }

      // 운동 빈도와 강도 매칭
      final intensityDesc =
          _getIntensityDescription(pattern.exercisePattern.averageIntensity);
      reasons.add(
          '주 ${pattern.exercisePattern.frequency}회, $intensityDesc 강도로 운동하시는 패턴과 잘 맞아요');

      // 시간대 매칭
      if (pattern.exercisePattern.preferredTimes.isNotEmpty) {
        final meetingHour = meeting.dateTime.hour;
        final meetingPeriod = _getTimePeriod(meetingHour);
        if (pattern.exercisePattern.preferredTimes.contains(meetingPeriod)) {
          reasons.add('평소 $meetingPeriod에 운동하시는데, 모임 시간이 $meetingHour시라 딱 맞아요');
        }
      }
    }

    // 독서 관련 - 더 구체적이고 정확한 설명
    if (meeting.category == MeetingCategory.reading &&
        pattern.readingPattern.booksPerWeek > 0) {
      // 🎯 제목 기반 장르 매칭
      if (pattern.readingPattern.mainCategories.isNotEmpty) {
        bool genreMatch = false;
        String matchedGenre = '';

        for (var category in pattern.readingPattern.mainCategories) {
          List<String> keywords = _readingKeywordMap[category] ?? [category];

          final titleLower = meeting.title.toLowerCase();
          final descLower = meeting.description.toLowerCase();

          for (var keyword in keywords) {
            if (titleLower.contains(keyword.toLowerCase()) ||
                descLower.contains(keyword.toLowerCase())) {
              genreMatch = true;
              matchedGenre = category;
              break;
            }
          }

          if (genreMatch) break;
        }

        if (genreMatch) {
          // 정확한 장르 매칭
          reasons.add(
              '평소 즐겨 읽으시는 $matchedGenre 분야를 "${meeting.title}"에서 함께 나눌 수 있어요!');
        } else {
          // 일반적인 독서 취향 언급
          final categories =
              pattern.readingPattern.mainCategories.take(2).join(', ');
          final avgRating =
              pattern.readingPattern.averageRating.toStringAsFixed(1);
          reasons.add('$categories 장르를 좋아하시고, 평균 $avgRating점을 주시는 취향과 잘 맞아요');
        }
      }

      // 최근 읽은 책과 연관 (모임 설명에 책 제목이 있는지 확인)
      if (pattern.readingPattern.recentBooks.isNotEmpty) {
        final recentBook = pattern.readingPattern.recentBooks.first;
        final descLower = meeting.description.toLowerCase();

        if (descLower.contains(recentBook.toLowerCase())) {
          reasons.add('최근 읽으신 "$recentBook"이 이 모임에서 다루는 책이네요! 완벽한 타이밍이에요');
        } else {
          final shortTitle = recentBook.length > 15
              ? '${recentBook.substring(0, 15)}...'
              : recentBook;
          reasons.add('최근 "$shortTitle"을(를) 읽으셨는데, 비슷한 깊이의 토론을 즐길 수 있을 거예요');
        }
      }

      // 독서량 언급
      final booksPerWeek =
          pattern.readingPattern.booksPerWeek.toStringAsFixed(1);
      reasons.add('주 $booksPerWeek권씩 읽으시는 독서 습관과 잘 어울리는 모임이에요');
    }

    // 모임 경험 기반 추천
    if (pattern.meetingPattern.averagePerWeek > 0) {
      // 과거 모임 참여 패턴 언급
      if (pattern.meetingPattern.preferredCategories
          .contains(meeting.category.displayName)) {
        final avgSatisfaction =
            pattern.meetingPattern.averageSatisfaction.toStringAsFixed(1);
        reasons.add(
            '평소 ${meeting.category.displayName} 모임을 선호하시고, 평균 만족도가 $avgSatisfaction점이신 분께 추천해요');
      }

      // 최근 참여 모임과의 연관성
      if (pattern.meetingPattern.recentMeetings.isNotEmpty) {
        reasons.add('최근 참여하신 모임들과 비슷한 분위기의 모임이에요');
      }
    }

    // 시간대 매칭 - 구체적인 설명
    final meetingHour = meeting.dateTime.hour;
    final meetingPeriod = _getTimePeriod(meetingHour);
    final meetingDay = _getDayOfWeek(meeting.dateTime.weekday);

    if (pattern.timePatterns.isNotEmpty &&
        pattern.timePatterns.containsKey(meetingPeriod)) {
      final activities = pattern.timePatterns[meetingPeriod]!;
      if (activities.isEmpty) {
        reasons.add(
            '$meetingDay $meetingPeriod $meetingHour시가 비어있어서 부담 없이 참여 가능해요');
      } else if (!activities.contains('운동') &&
          meeting.category == MeetingCategory.exercise) {
        reasons.add('$meetingPeriod에 운동을 추가하면 하루가 더 균형잡혀요');
      }
    }

    // 장소 기반 추천 - 구체적인 설명
    if (pattern.preferredLocations.isNotEmpty) {
      for (var location in pattern.preferredLocations) {
        if (meeting.location.contains(location)) {
          reasons
              .add('평소 자주 가시는 $location 근처라서 접근성이 좋아요 (${meeting.location})');
          break;
        }
      }
    }

    // 성장 지표 연계 - 구체적인 설명
    if (meeting.category == MeetingCategory.networking &&
        pattern.growthStats.sociality > 50) {
      reasons.add(
          '사교성이 ${pattern.growthStats.sociality}점이신데, 이 모임으로 더 향상시킬 수 있어요');
    }
    if (meeting.category == MeetingCategory.study &&
        pattern.growthStats.knowledge > 50) {
      reasons.add(
          '지식 지수가 ${pattern.growthStats.knowledge}점이신데, 이 모임이 학습에 도움이 될 거예요');
    }
    if (meeting.category == MeetingCategory.exercise &&
        pattern.growthStats.stamina > 50) {
      reasons
          .add('스태미나가 ${pattern.growthStats.stamina}점이신데, 이 활동으로 더 강해질 수 있어요');
    }

    // 영화 패턴과 문화 모임 연계
    if (meeting.category == MeetingCategory.culture &&
        pattern.moviePattern.moviesPerWeek > 0) {
      if (pattern.moviePattern.preferredGenres.isNotEmpty) {
        final genres = pattern.moviePattern.preferredGenres.take(2).join(', ');
        final avgRating = pattern.moviePattern.averageRating.toStringAsFixed(1);
        reasons.add('$genres 장르를 좋아하시고 평균 $avgRating점을 주시는 문화 취향과 잘 맞아요');
      }
    }

    // 참여율 기반 추천
    final participationRate =
        meeting.currentParticipants / meeting.maxParticipants;
    if (participationRate >= 0.5 && participationRate < 0.8) {
      reasons.add('현재 ${(participationRate * 100).toInt()}% 참여 중인 활발한 모임이에요');
    } else if (participationRate < 0.3) {
      reasons.add('소규모로 진행되어 친밀한 분위기에서 참여할 수 있어요');
    }

    // 점수 기반 추가 설명
    if (score > 0.8) {
      reasons.add('AI 분석 결과 ${(score * 100).toInt()}% 매칭률로 강력 추천드려요');
    }

    if (reasons.isEmpty) {
      // 기본 메시지도 더 구체적으로
      return '${pattern.userName}님의 최근 2주 활동을 분석했을 때, 이 모임이 가장 적합해 보여요!';
    }

    // 가장 중요한 2-3개 이유를 선택하여 자연스럽게 연결
    if (reasons.length == 1) {
      return reasons.first;
    } else if (reasons.length == 2) {
      return '${reasons[0]} ${reasons[1]}';
    } else {
      // 3개 이상일 때는 가장 중요한 3개만 선택
      return '${reasons[0]} ${reasons[1]} 게다가 ${reasons[2]}';
    }
  }

  /// 강도를 설명하는 문자열 반환
  String _getIntensityDescription(double intensity) {
    if (intensity < 1.5) return '가벼운';
    if (intensity < 2.5) return '적당한';
    if (intensity < 3.5) return '높은';
    return '매우 높은';
  }

  /// 요일 문자열 반환
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return '월요일';
      case 2:
        return '화요일';
      case 3:
        return '수요일';
      case 4:
        return '목요일';
      case 5:
        return '금요일';
      case 6:
        return '토요일';
      case 7:
        return '일요일';
      default:
        return '';
    }
  }

  /// 키포인트 생성 (더 구체적인 정보 제공)
  List<String> _generateKeyPoints(
    UserActivityPattern pattern,
    AvailableMeeting meeting,
  ) {
    final points = <String>[];

    // 카테고리와 매칭 정보
    if (pattern.exercisePattern.frequency > 0 &&
        meeting.category == MeetingCategory.exercise) {
      points.add('운동 패턴 ${pattern.exercisePattern.frequency}회/주 매칭');
    } else if (pattern.readingPattern.booksPerWeek > 0 &&
        meeting.category == MeetingCategory.reading) {
      points.add(
          '독서 습관 ${pattern.readingPattern.booksPerWeek.toStringAsFixed(1)}권/주 매칭');
    } else {
      points.add('${meeting.category.displayName} 활동');
    }

    // 구체적인 시간 정보
    final hour = meeting.dateTime.hour;
    final dayOfWeek = _getDayOfWeek(meeting.dateTime.weekday);
    final period = _getTimePeriod(hour);
    points.add('$dayOfWeek $period $hour시');

    // 장소 정보
    if (pattern.preferredLocations.isNotEmpty) {
      bool locationMatch = false;
      for (var location in pattern.preferredLocations) {
        if (meeting.location.contains(location)) {
          points.add('선호 지역 $location');
          locationMatch = true;
          break;
        }
      }
      if (!locationMatch) {
        points.add(meeting.location);
      }
    } else {
      points.add(meeting.location);
    }

    // 참가비 및 참여율 정보
    final participationRate =
        meeting.currentParticipants / meeting.maxParticipants;
    if (meeting.type == MeetingType.free) {
      points.add('무료 (1000P 참가비)');
    } else if (meeting.price != null) {
      points.add('${meeting.price!.toInt()}원');
    }

    // 참여율 정보
    if (participationRate >= 0.7) {
      points.add('인기 급상승 ${(participationRate * 100).toInt()}%');
    } else if (participationRate >= 0.5) {
      points.add('활발한 모임 ${(participationRate * 100).toInt()}%');
    } else if (participationRate < 0.3) {
      points.add(
          '소규모 ${meeting.currentParticipants}/${meeting.maxParticipants}명');
    }

    // 성장 지표 관련
    if (meeting.category == MeetingCategory.exercise &&
        pattern.growthStats.stamina > 60) {
      points.add('스태미나 +${(5 + pattern.growthStats.stamina / 20).toInt()}점 예상');
    } else if (meeting.category == MeetingCategory.study &&
        pattern.growthStats.knowledge > 60) {
      points.add('지식 +${(5 + pattern.growthStats.knowledge / 20).toInt()}점 예상');
    } else if (meeting.category == MeetingCategory.networking &&
        pattern.growthStats.sociality > 60) {
      points
          .add('사교성 +${(5 + pattern.growthStats.sociality / 20).toInt()}점 예상');
    }

    // 가장 중요한 4-5개만 선택
    return points.take(5).toList();
  }

  /// 시간대 구분
  String _getTimePeriod(int hour) {
    if (hour >= 0 && hour < 6) return '새벽';
    if (hour >= 6 && hour < 12) return '아침';
    if (hour >= 12 && hour < 18) return '오후';
    if (hour >= 18 && hour < 22) return '저녁';
    return '밤';
  }

  /// 긴급 폴백 (모든 것이 실패했을 때)
  List<AIRecommendedMeeting> _getEmergencyFallback(
    List<AvailableMeeting> meetings,
  ) {
    debugPrint('🚨 긴급 폴백 모드');

    final available = meetings
        .where((m) => m.currentParticipants < m.maxParticipants)
        .take(3)
        .toList();

    return available
        .map((meeting) => AIRecommendedMeeting(
              meeting: meeting,
              matchScore: 0.5,
              reason: '인기 있는 모임이에요! 함께 참여해보세요.',
              keyPoints: [
                meeting.category.displayName,
                meeting.location,
                '추천 모임',
              ],
              priority: available.indexOf(meeting) + 1,
              createdAt: DateTime.now(),
            ))
        .toList();
  }

  /// 캐시에서 추천 가져오기
  Future<List<AIRecommendedMeeting>?> _getCachedRecommendations(
    String userId,
    List<AvailableMeeting> availableMeetings,
    String meetingSetHash,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cacheKeyPrefix$userId';

      final cachedJson = prefs.getString(key);
      if (cachedJson == null) return null;

      final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
      final cachedTime = DateTime.parse(cachedData['timestamp'] as String);

      if (DateTime.now().difference(cachedTime) > _cacheDuration) {
        debugPrint('⏰ 캐시 만료됨');
        return null;
      }

      if (cachedData['meetingSetHash'] != meetingSetHash) {
        debugPrint('📦 모임 목록이 변경되어 캐시 무효화');
        return null;
      }

      final recommendationJson =
          cachedData['recommendations'] as List<dynamic>?;
      if (recommendationJson == null || recommendationJson.isEmpty) {
        return null;
      }

      final meetingsById = {
        for (final meeting in availableMeetings) meeting.id: meeting,
      };

      final restored = <AIRecommendedMeeting>[];
      for (final entry in recommendationJson) {
        if (entry is! Map<String, dynamic>) continue;
        final meetingId = entry['meetingId'] as String?;
        if (meetingId == null) continue;
        final meeting = meetingsById[meetingId];
        if (meeting == null) {
          debugPrint('⚠️ 캐시된 추천 모임($meetingId)을 현재 목록에서 찾을 수 없음');
          continue;
        }
        restored.add(AIRecommendedMeeting.fromJson(entry, meeting));
      }

      if (restored.isEmpty) {
        return null;
      }

      return restored;
    } catch (e) {
      debugPrint('캐시 읽기 실패: $e');
      return null;
    }
  }

  /// 추천 캐싱
  Future<void> _cacheRecommendations(
    String userId,
    String meetingSetHash,
    List<AIRecommendedMeeting> recommendations,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cacheKeyPrefix$userId';

      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'meetingSetHash': meetingSetHash,
        'recommendations':
            recommendations.map((r) => r.toJson()).toList(growable: false),
      };

      await prefs.setString(key, jsonEncode(cacheData));
      debugPrint('💾 AI 추천 캐시 저장 완료');
    } catch (e) {
      debugPrint('캐시 저장 실패: $e');
    }
  }

  /// 캐시 클리어
  Future<void> clearCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cacheKeyPrefix$userId';
      await prefs.remove(key);
      debugPrint('🗑️ AI 추천 캐시 삭제됨');
    } catch (e) {
      debugPrint('캐시 삭제 실패: $e');
    }
  }

  String _computeMeetingSetHash(List<AvailableMeeting> meetings) {
    if (meetings.isEmpty) {
      return 'empty';
    }

    final sortedIds = meetings.map((m) => m.id).toList()..sort();
    final payload = jsonEncode(sortedIds);
    return base64Url.encode(utf8.encode(payload));
  }
}
