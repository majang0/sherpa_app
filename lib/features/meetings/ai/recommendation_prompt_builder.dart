/// AI 모임 추천을 위한 프롬프트 빌더
/// 사용자 활동 패턴과 모임 목록을 구조화된 프롬프트로 변환
library;

import 'dart:convert';
import 'package:sherpa_app/features/sherpi/domain/services/sherpi_insight_repository.dart';

import '../models/available_meeting_model.dart';
import 'models/user_activity_pattern.dart';

class RecommendationPromptBuilder {
  /// 시스템 프롬프트 (AI의 역할 정의)
  static const String _systemPrompt = '''
당신은 개인 성장 앱 '셰르파'의 AI 매칭 전문가입니다.
사용자의 실제 활동 데이터를 분석하여 가장 적합한 모임 3개를 추천해주세요.

추천 시 고려사항:
1. 사용자의 활동 시간대와 겹치지 않는 모임
2. 현재 관심사와 연관된 모임
3. 기존 활동과 시너지를 낼 수 있는 모임
4. 성장 지표와 연계된 모임
5. 지리적 접근성 (선호 장소 근처)

각 추천은 다음 형식의 JSON으로 응답해주세요:
{
  "recommendations": [
    {
      "meetingId": "모임ID",
      "matchScore": 0.95,
      "reason": "매일 저녁 7시 신천에서 러닝하시는 패턴을 보니, 같은 시간대 같은 장소의 러닝 크루가 딱 맞을 것 같아요!",
      "keyPoints": ["시간대 일치", "장소 일치", "운동 종류 일치"],
      "priority": 1
    }
  ]
}
''';

  /// 메인 프롬프트 생성
  String buildPrompt({
    required UserActivityPattern userPattern,
    required List<AvailableMeeting> availableMeetings,
    SherpiInsights? sherpiInsights,
  }) {
    final buffer = StringBuffer();

    // 사용자 프로필 섹션
    buffer.writeln('## 사용자 프로필');
    buffer.writeln('- 이름: ${userPattern.userName}');
    buffer.writeln('- 레벨: ${userPattern.userLevel}');
    buffer.writeln('- 주요 강점: ${userPattern.growthStats.mainStrength}');
    buffer.writeln('- 성장 지표: 스태미나 ${userPattern.growthStats.stamina}, '
        '지식 ${userPattern.growthStats.knowledge}, '
        '기술력 ${userPattern.growthStats.technique}, '
        '사교성 ${userPattern.growthStats.sociality}, '
        '의지력 ${userPattern.growthStats.willpower}');
    buffer.writeln();

    if (sherpiInsights != null) {
      buffer.writeln('## Sherpi Insights');
      buffer.writeln('- 셰르피 성격: ${sherpiInsights.personalityType.displayName}');
      buffer.writeln('- 셰르피 닉네임: ${sherpiInsights.sherpiNickname}');
      buffer.writeln('- 사용자 선호 호칭: ${sherpiInsights.userPreferredName}');
      buffer.writeln('- 친밀도 레벨: ${sherpiInsights.intimacyLevel}');
      buffer.writeln(
          '- 감정 동기화 점수: ${(sherpiInsights.emotionalSyncScore * 100).toStringAsFixed(0)}%');
      if (sherpiInsights.recentSherpiEmotion != null) {
        buffer.writeln(
            '- 최근 셰르피 감정: ${sherpiInsights.recentSherpiEmotion!.name}');
      }
      if (sherpiInsights.recentSherpiContext != null) {
        buffer.writeln('- 최근 대화 컨텍스트: '
            '${sherpiInsights.recentSherpiContext!.name}');
      }
      if (sherpiInsights.lastSherpiMessage.isNotEmpty) {
        buffer.writeln('- 마지막 셰르피 메시지: "${sherpiInsights.lastSherpiMessage}"');
      }
      buffer.writeln();
    }

    // 활동 패턴 섹션
    buffer.writeln('## 최근 ${userPattern.analysisPeriod.days}일 활동 패턴');

    // 운동 패턴
    if (userPattern.exercisePattern.frequency > 0) {
      buffer.writeln('### 운동 활동');
      buffer.writeln('- 패턴: ${userPattern.exercisePattern.description}');
      buffer.writeln(
          '- 주요 종류: ${userPattern.exercisePattern.mainTypes.join(", ")}');
      buffer.writeln(
          '- 선호 시간대: ${userPattern.exercisePattern.preferredTimes.join(", ")}');
      buffer.writeln(
          '- 평균 강도: ${userPattern.exercisePattern.averageIntensity.toStringAsFixed(1)}/5');
      if (userPattern.exercisePattern.locations.isNotEmpty) {
        buffer.writeln(
            '- 추정 장소: ${userPattern.exercisePattern.locations.join(", ")}');
      }
      buffer.writeln();
    }

    // 독서 패턴
    if (userPattern.readingPattern.booksPerWeek > 0) {
      buffer.writeln('### 독서 활동');
      buffer.writeln('- 패턴: ${userPattern.readingPattern.description}');
      buffer.writeln(
          '- 주요 카테고리: ${userPattern.readingPattern.mainCategories.join(", ")}');
      if (userPattern.readingPattern.preferredTimes.isNotEmpty) {
        buffer.writeln(
            '- 선호 시간대: ${userPattern.readingPattern.preferredTimes.join(", ")}');
      }
      buffer.writeln(
          '- 평균 평점: ${userPattern.readingPattern.averageRating.toStringAsFixed(1)}/5');
      if (userPattern.readingPattern.recentBooks.isNotEmpty) {
        buffer.writeln(
            '- 최근 책: ${userPattern.readingPattern.recentBooks.take(3).join(", ")}');
      }
      buffer.writeln();
    }

    // 모임 참여 패턴
    if (userPattern.meetingPattern.averagePerWeek > 0) {
      buffer.writeln('### 모임 참여');
      buffer.writeln('- 패턴: ${userPattern.meetingPattern.description}');
      buffer.writeln(
          '- 선호 카테고리: ${userPattern.meetingPattern.preferredCategories.join(", ")}');
      buffer.writeln(
          '- 평균 만족도: ${userPattern.meetingPattern.averageSatisfaction.toStringAsFixed(1)}/5');
      if (userPattern.meetingPattern.preferredTimes.isNotEmpty) {
        buffer.writeln(
            '- 선호 시간대: ${userPattern.meetingPattern.preferredTimes.join(", ")}');
      }
      buffer.writeln();
    }

    // 영화 시청 패턴
    if (userPattern.moviePattern.moviesPerWeek > 0) {
      buffer.writeln('### 영화 시청');
      buffer.writeln('- 패턴: ${userPattern.moviePattern.description}');
      buffer.writeln(
          '- 선호 장르: ${userPattern.moviePattern.preferredGenres.join(", ")}');
      buffer.writeln(
          '- 평균 평점: ${userPattern.moviePattern.averageRating.toStringAsFixed(1)}/5');
      buffer.writeln();
    }

    // 시간대별 활동
    if (userPattern.timePatterns.isNotEmpty) {
      buffer.writeln('## 시간대별 활동 패턴');
      userPattern.timePatterns.forEach((time, activities) {
        buffer.writeln('- $time: ${activities.join(", ")}');
      });
      buffer.writeln();
    }

    // 관심사
    if (userPattern.interests.isNotEmpty) {
      buffer.writeln('## 주요 관심사');
      buffer.writeln(userPattern.interests.join(', '));
      buffer.writeln();
    }

    // 선호 장소
    if (userPattern.preferredLocations.isNotEmpty) {
      buffer.writeln('## 선호 장소');
      buffer.writeln(userPattern.preferredLocations.join(', '));
      buffer.writeln();
    }

    // 추천 가능한 모임 목록
    buffer.writeln('## 추천 가능한 모임 목록');
    for (var meeting in availableMeetings) {
      buffer.writeln(_formatMeetingForPrompt(meeting));
    }
    buffer.writeln();

    // 추천 요청
    buffer.writeln('## 추천 요청');
    buffer.writeln('위 정보를 바탕으로 사용자에게 가장 적합한 모임 3개를 추천해주세요.');
    buffer.writeln('각 추천마다 구체적인 이유와 매칭 포인트를 포함해주세요.');
    buffer.writeln('사용자의 실제 활동 패턴과 어떻게 연결되는지 명확히 설명해주세요.');

    return buffer.toString();
  }

  /// 모임 정보를 프롬프트용으로 포맷팅
  String _formatMeetingForPrompt(AvailableMeeting meeting) {
    final buffer = StringBuffer();

    buffer.write('- ID: ${meeting.id} | ');
    buffer.write('[${meeting.category.displayName}] ');
    buffer.write('${meeting.title} | ');
    buffer.write('장소: ${meeting.location} | ');
    buffer.write('시간: ${meeting.formattedDate} | ');
    buffer.write(
        '참가자: ${meeting.currentParticipants}/${meeting.maxParticipants} | ');

    if (meeting.type == MeetingType.free) {
      buffer.write('무료');
    } else {
      buffer.write('${meeting.participationFee.toInt()}P');
    }

    // 설명 추가 (있는 경우)
    if (meeting.description.isNotEmpty) {
      buffer.write(
          ' | ${meeting.description.substring(0, meeting.description.length > 50 ? 50 : meeting.description.length)}...');
    }

    return buffer.toString();
  }

  /// AI 응답 파싱
  List<Map<String, dynamic>> parseAIResponse(String response) {
    try {
      // JSON 부분만 추출 (응답에 텍스트가 섞여있을 수 있음)
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        // JSON이 없으면 텍스트 파싱 시도
        return _parseTextResponse(response);
      }

      final jsonStr = response.substring(jsonStart, jsonEnd);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (json.containsKey('recommendations')) {
        final recommendations = json['recommendations'] as List<dynamic>;
        return recommendations.map((r) => r as Map<String, dynamic>).toList();
      }

      // recommendations 키가 없으면 전체를 하나의 추천으로 처리
      return [json];
    } catch (e) {
      // JSON 파싱 실패 시 텍스트 파싱
      return _parseTextResponse(response);
    }
  }

  /// 텍스트 응답 파싱 (JSON 파싱 실패 시 대체)
  List<Map<String, dynamic>> _parseTextResponse(String response) {
    final recommendations = <Map<String, dynamic>>[];

    // 간단한 텍스트 파싱 로직
    // "1. ", "2. ", "3. " 패턴 찾기
    final lines = response.split('\n');
    String? currentId;
    String currentReason = '';
    List<String> currentKeyPoints = [];

    for (var line in lines) {
      line = line.trim();

      // ID 패턴 찾기
      if (line.contains('ID:') || line.contains('모임ID:')) {
        if (currentId != null) {
          // 이전 추천 저장
          recommendations.add({
            'meetingId': currentId,
            'matchScore': 0.8,
            'reason': currentReason.trim(),
            'keyPoints': currentKeyPoints,
            'priority': recommendations.length + 1,
          });
        }

        // 새 추천 시작
        final idMatch = RegExp(r'ID:\s*(\S+)').firstMatch(line);
        currentId = idMatch?.group(1) ?? 'unknown';
        currentReason = '';
        currentKeyPoints = [];
      }

      // 이유 추출
      if (line.contains('이유:') || line.contains('추천 이유:')) {
        currentReason = line.substring(line.indexOf(':') + 1).trim();
      } else if (currentId != null &&
          line.isNotEmpty &&
          !line.startsWith('-')) {
        currentReason += ' $line';
      }

      // 키포인트 추출
      if (line.startsWith('-') ||
          line.startsWith('•') ||
          line.startsWith('*')) {
        currentKeyPoints.add(line.substring(1).trim());
      }
    }

    // 마지막 추천 저장
    if (currentId != null) {
      recommendations.add({
        'meetingId': currentId,
        'matchScore': 0.8,
        'reason': currentReason.trim(),
        'keyPoints': currentKeyPoints,
        'priority': recommendations.length + 1,
      });
    }

    // 추천이 없으면 더 구체적인 기본값 반환
    if (recommendations.isEmpty) {
      return [
        {
          'meetingId': 'fallback',
          'matchScore': 0.5,
          'reason':
              '최근 2주간의 활동 데이터를 분석한 결과, 새로운 경험을 시도해보시면 좋을 것 같아요. 평소와 다른 시간대나 활동을 추천드립니다.',
          'keyPoints': ['새로운 경험 추천', '활동 다양성 확대', '성장 기회'],
          'priority': 1,
        }
      ];
    }

    return recommendations;
  }

  /// 간단한 프롬프트 생성 (토큰 절약용)
  String buildSimplePrompt({
    required UserActivityPattern userPattern,
    required List<AvailableMeeting> availableMeetings,
  }) {
    final buffer = StringBuffer();

    buffer
        .writeln('사용자: ${userPattern.userName} (Lv.${userPattern.userLevel})');
    buffer.writeln('활동: ${userPattern.activitySummary}');

    if (userPattern.exercisePattern.frequency > 0) {
      buffer.writeln('운동: ${userPattern.exercisePattern.description}');
    }
    if (userPattern.readingPattern.booksPerWeek > 0) {
      buffer.writeln('독서: ${userPattern.readingPattern.description}');
    }

    buffer.writeln('\n모임 목록:');
    for (var meeting in availableMeetings.take(20)) {
      // 최대 20개만
      buffer.writeln(
          '${meeting.id}|${meeting.category.displayName}|${meeting.title}|${meeting.location}');
    }

    buffer.writeln('\n가장 적합한 모임 3개를 추천해주세요. (ID, 점수, 이유)');

    return buffer.toString();
  }
}
