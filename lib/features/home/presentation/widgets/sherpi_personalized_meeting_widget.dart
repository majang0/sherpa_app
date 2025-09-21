import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/constants/sherpi_emotions.dart';

// Features - Meetings
import '../../../meetings/models/available_meeting_model.dart';
import '../../../meetings/utils/meeting_image_utils.dart';

// Shared Providers
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_ai_recommendation_provider.dart';

// Shared Widgets
import '../../../../shared/widgets/components/molecules/participant_avatars_2025.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

// AI Recommendation Widgets
import '../../../meetings/ai/models/ai_recommended_meeting.dart';
import '../../../meetings/presentation/widgets/ai/ai_analysis_loading_widget.dart';
import '../../../meetings/presentation/widgets/ai/ai_recommendation_result_cards.dart';

/// 🎯 셰르피가 추천하는 맞춤 모임 위젯
/// 사용자의 활동 데이터를 분석해 개인화된 모임을 추천하는 위젯
class SherpiPersonalizedMeetingWidget extends ConsumerStatefulWidget {
  const SherpiPersonalizedMeetingWidget({super.key});

  @override
  ConsumerState<SherpiPersonalizedMeetingWidget> createState() =>
      _SherpiPersonalizedMeetingWidgetState();
}

class _SherpiPersonalizedMeetingWidgetState
    extends ConsumerState<SherpiPersonalizedMeetingWidget>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // 초기 애니메이션
    _fadeController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  // 사용자 활동 분석 및 인사이트 생성 (종합적 패턴 분석)
  Map<String, dynamic> _analyzeUserActivity() {
    final user = ref.read(globalUserProvider);
    final now = DateTime.now();
    final lastTwoWeeks = now.subtract(const Duration(days: 14));

    // 최근 2주간 활동 분석 (더 많은 데이터로 패턴 파악)
    final recentReadings = user.dailyRecords.readingLogs
        .where((log) => log.date.isAfter(lastTwoWeeks))
        .toList();

    final recentExercises = user.dailyRecords.exerciseLogs
        .where((log) => log.date.isAfter(lastTwoWeeks))
        .toList();

    final recentMeetings = user.dailyRecords.meetingLogs
        .where((log) => log.date.isAfter(lastTwoWeeks))
        .toList();

    // 카테고리별 점수 계산
    Map<MeetingCategory, double> categoryScores = {
      MeetingCategory.reading: 0,
      MeetingCategory.exercise: 0,
      MeetingCategory.study: 0,
      MeetingCategory.networking: 0,
      MeetingCategory.culture: 0,
      MeetingCategory.outdoor: 0,
    };

    // 1. 모임 참여 이력 분석 (가중치: 40%)
    for (var meeting in recentMeetings) {
      final category = _mapStringToCategory(meeting.category);
      if (category != MeetingCategory.all) {
        // 만족도를 가중치로 사용 (1-5점)
        categoryScores[category] =
            (categoryScores[category] ?? 0) + (meeting.satisfaction * 0.4);
      }
    }

    // 2. 독서 패턴 분석 (가중치: 30%)
    Map<String, int> readingCategories = {};
    for (var reading in recentReadings) {
      readingCategories[reading.category] =
          (readingCategories[reading.category] ?? 0) + 1;
    }

    // 독서 카테고리를 모임 카테고리로 매핑
    readingCategories.forEach((bookCategory, count) {
      final mappedCategories = _mapReadingToMeetingCategories(bookCategory);
      for (var category in mappedCategories) {
        categoryScores[category] =
            (categoryScores[category] ?? 0) + (count * 0.3);
      }
    });

    // 3. 운동 패턴 분석 (가중치: 30%)
    Map<String, int> exerciseTypes = {};
    for (var exercise in recentExercises) {
      exerciseTypes[exercise.exerciseType] =
          (exerciseTypes[exercise.exerciseType] ?? 0) + 1;
    }

    // 운동 타입을 모임 카테고리로 매핑
    exerciseTypes.forEach((exerciseType, count) {
      final mappedCategories = _mapExerciseToMeetingCategories(exerciseType);
      for (var category in mappedCategories) {
        categoryScores[category] =
            (categoryScores[category] ?? 0) + (count * 0.3);
      }
    });

    // 🎯 상위 3개 카테고리 선택 (다양성 증진)
    List<MapEntry<MeetingCategory, double>> sortedCategories =
        categoryScores.entries
            .where((e) => e.value > 0) // 점수가 0보다 큰 카테고리만
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value)); // 점수 높은 순으로 정렬

    // 상위 3개 카테고리 추출 (없으면 있는 만큼만)
    List<MeetingCategory> topCategories =
        sortedCategories.take(3).map((e) => e.key).toList();

    // 카테고리가 없으면 기본값
    if (topCategories.isEmpty) {
      topCategories = [MeetingCategory.all];
    }

    // 🎲 상위 3개 중 랜덤으로 하나 선택 (다양성 보장)
    final random = Random();
    MeetingCategory recommendedCategory;

    // 점수 차이가 작으면 완전 랜덤, 크면 가중치 적용
    if (sortedCategories.length >= 2 &&
        sortedCategories[0].value - sortedCategories.last.value < 0.2) {
      // 점수 차이가 작으면 상위 3개 중 완전 랜덤
      recommendedCategory = topCategories[random.nextInt(topCategories.length)];
    } else {
      // 점수 차이가 크면 가중치 기반 랜덤 (첫번째가 더 높은 확률)
      final weights = [0.5, 0.3, 0.2]; // 50%, 30%, 20% 확률
      final rand = random.nextDouble();

      if (rand < weights[0]) {
        recommendedCategory = topCategories[0];
      } else if (topCategories.length > 1 && rand < weights[0] + weights[1]) {
        recommendedCategory = topCategories[1];
      } else if (topCategories.length > 2) {
        recommendedCategory = topCategories[2];
      } else {
        recommendedCategory = topCategories[0];
      }
    }

    // 인사이트 메시지 생성 (더 구체적이고 개인화된 메시지)
    String insight = _generatePersonalizedInsight(
      recentReadings,
      recentExercises,
      recentMeetings,
      recommendedCategory,
      categoryScores,
    );

    // 감정 선택 (활동 수준에 따라)
    SherpiEmotion emotion = _selectEmotion(
      recentReadings.length,
      recentExercises.length,
      recentMeetings.length,
      recommendedCategory,
    );

    return {
      'primaryActivity':
          _getPrimaryActivity(recentReadings, recentExercises, recentMeetings),
      'insight': insight,
      'recommendedCategory': recommendedCategory,
      'topCategories': topCategories, // 상위 3개 카테고리 모두 전달
      'emotion': emotion,
      'categoryScores': categoryScores,
      'readingCount': recentReadings.length,
      'exerciseCount': recentExercises.length,
      'meetingCount': recentMeetings.length,
      'totalActivities': recentReadings.length +
          recentExercises.length +
          recentMeetings.length,
    };
  }

  // 문자열을 MeetingCategory 열거형으로 매핑
  MeetingCategory _mapStringToCategory(String category) {
    switch (category.toLowerCase()) {
      case '운동':
      case 'exercise':
        return MeetingCategory.exercise;
      case '스터디':
      case 'study':
        return MeetingCategory.study;
      case '독서':
      case 'reading':
        return MeetingCategory.reading;
      case '네트워킹':
      case 'networking':
        return MeetingCategory.networking;
      case '문화':
      case 'culture':
        return MeetingCategory.culture;
      case '아웃도어':
      case 'outdoor':
        return MeetingCategory.outdoor;
      default:
        return MeetingCategory.all;
    }
  }

  // 독서 카테고리를 모임 카테고리로 매핑
  List<MeetingCategory> _mapReadingToMeetingCategories(String bookCategory) {
    switch (bookCategory) {
      case '자기계발':
      case '경영':
      case '비즈니스':
        return [MeetingCategory.study, MeetingCategory.networking];
      case '소설':
      case '에세이':
        return [MeetingCategory.reading, MeetingCategory.culture];
      case 'IT':
      case '과학':
        return [MeetingCategory.study];
      case '예술':
      case '철학':
      case '역사':
        return [MeetingCategory.culture, MeetingCategory.reading];
      case '여행':
        return [MeetingCategory.outdoor, MeetingCategory.culture];
      default:
        return [MeetingCategory.reading];
    }
  }

  // 운동 타입을 모임 카테고리로 매핑
  List<MeetingCategory> _mapExerciseToMeetingCategories(String exerciseType) {
    final lowerType = exerciseType.toLowerCase();

    if (lowerType.contains('러닝') ||
        lowerType.contains('달리기') ||
        lowerType.contains('조깅') ||
        lowerType.contains('마라톤')) {
      return [MeetingCategory.exercise, MeetingCategory.outdoor];
    } else if (lowerType.contains('등산') ||
        lowerType.contains('하이킹') ||
        lowerType.contains('트레킹')) {
      return [MeetingCategory.outdoor, MeetingCategory.exercise];
    } else if (lowerType.contains('요가') || lowerType.contains('필라테스')) {
      return [MeetingCategory.exercise, MeetingCategory.culture];
    } else if (lowerType.contains('헬스') ||
        lowerType.contains('웨이트') ||
        lowerType.contains('근력')) {
      return [MeetingCategory.exercise];
    } else if (lowerType.contains('수영') || lowerType.contains('서핑')) {
      return [MeetingCategory.exercise, MeetingCategory.outdoor];
    } else if (lowerType.contains('자전거') || lowerType.contains('사이클')) {
      return [MeetingCategory.outdoor, MeetingCategory.exercise];
    } else {
      return [MeetingCategory.exercise];
    }
  }

  // 개인화된 인사이트 메시지 생성 (활동과 추천을 자연스럽게 연결)
  String _generatePersonalizedInsight(
    List<dynamic> readings,
    List<dynamic> exercises,
    List<dynamic> meetings,
    MeetingCategory recommendedCategory,
    Map<MeetingCategory, double> scores,
  ) {
    final totalActivities =
        readings.length + exercises.length + meetings.length;

    if (totalActivities == 0) {
      return '✨ 이번 주는 새로운 도전을 시작해보는 건 어때요?';
    }

    // 🎯 주요 활동과 추천 카테고리를 자연스럽게 연결하는 메시지 생성
    String primaryActivity = '';
    String connectionMessage = '';

    // 가장 활발한 활동 파악
    if (exercises.length >= readings.length &&
        exercises.length >= meetings.length) {
      // 운동이 주요 활동인 경우
      primaryActivity = '💪 최근 2주간 운동을 열심히 하셨네요!';

      switch (recommendedCategory) {
        case MeetingCategory.exercise:
          connectionMessage = '새로운 운동 모임에서 더 다양한 운동을 경험해보세요!';
          break;
        case MeetingCategory.networking:
          connectionMessage = '네트워킹 모임에서 운동 파트너를 찾아보는 건 어때요?';
          break;
        case MeetingCategory.outdoor:
          connectionMessage = '아웃도어 모임으로 야외 운동의 매력을 느껴보세요!';
          break;
        case MeetingCategory.culture:
          connectionMessage = '문화 모임에서 운동 후 재충전의 시간을 가져보세요!';
          break;
        case MeetingCategory.study:
          connectionMessage = '스터디 모임에서 운동과 학습의 균형을 맞춰보세요!';
          break;
        case MeetingCategory.reading:
          connectionMessage = '독서 모임에서 운동과 독서의 조화를 이뤄보세요!';
          break;
        default:
          connectionMessage = '다양한 모임으로 새로운 경험을 더해보세요!';
      }
    } else if (readings.length >= exercises.length &&
        readings.length >= meetings.length) {
      // 독서가 주요 활동인 경우
      final bookCategories = readings.map((r) => r.category).toSet();
      primaryActivity = '📚 ${bookCategories.join(", ")} 분야 독서를 즐기시네요!';

      switch (recommendedCategory) {
        case MeetingCategory.reading:
          connectionMessage = '독서 모임에서 책에 대한 깊은 대화를 나눠보세요!';
          break;
        case MeetingCategory.study:
          connectionMessage = '스터디 모임에서 독서를 통한 지식을 공유해보세요!';
          break;
        case MeetingCategory.networking:
          connectionMessage = '네트워킹 모임에서 같은 책을 읽는 분들을 만나보세요!';
          break;
        case MeetingCategory.culture:
          connectionMessage = '문화 모임에서 독서와 예술의 연결점을 찾아보세요!';
          break;
        case MeetingCategory.exercise:
          connectionMessage = '운동 모임으로 독서와 운동의 균형을 맞춰보세요!';
          break;
        case MeetingCategory.outdoor:
          connectionMessage = '아웃도어 모임에서 자연 속 독서의 즐거움을 느껴보세요!';
          break;
        default:
          connectionMessage = '새로운 모임으로 독서 경험을 확장해보세요!';
      }
    } else {
      // 모임 참여가 주요 활동인 경우
      final meetingCategories = meetings.map((m) => m.category).toSet();
      primaryActivity = '🤝 ${meetingCategories.join(", ")} 모임에 활발히 참여 중이시네요!';

      switch (recommendedCategory) {
        case MeetingCategory.networking:
          connectionMessage = '네트워킹 모임으로 인맥을 더욱 확장해보세요!';
          break;
        case MeetingCategory.culture:
          connectionMessage = '문화 모임에서 새로운 취향을 발견해보세요!';
          break;
        case MeetingCategory.exercise:
          connectionMessage = '운동 모임으로 건강한 네트워크를 만들어보세요!';
          break;
        case MeetingCategory.study:
          connectionMessage = '스터디 모임에서 함께 성장하는 기쁨을 느껴보세요!';
          break;
        case MeetingCategory.reading:
          connectionMessage = '독서 모임으로 지적 호기심을 채워보세요!';
          break;
        case MeetingCategory.outdoor:
          connectionMessage = '아웃도어 모임에서 자연과 함께하는 시간을 가져보세요!';
          break;
        default:
          connectionMessage = '더 다양한 모임으로 경험을 넓혀보세요!';
      }
    }

    return '$primaryActivity $connectionMessage';
  }

  // 활동 수준에 따른 감정 선택
  SherpiEmotion _selectEmotion(
    int readingCount,
    int exerciseCount,
    int meetingCount,
    MeetingCategory category,
  ) {
    final totalActivities = readingCount + exerciseCount + meetingCount;

    if (totalActivities >= 15) {
      return SherpiEmotion.special; // 매우 활발한 활동
    } else if (totalActivities >= 10) {
      return SherpiEmotion.cheering; // 활발한 활동
    } else if (totalActivities >= 5) {
      return SherpiEmotion.happy; // 적당한 활동
    } else if (totalActivities > 0) {
      return SherpiEmotion.thinking; // 약간의 활동
    } else {
      return SherpiEmotion.guiding; // 활동이 없음
    }
  }

  // 주요 활동 결정
  String _getPrimaryActivity(
    List<dynamic> readings,
    List<dynamic> exercises,
    List<dynamic> meetings,
  ) {
    if (readings.length >= exercises.length &&
        readings.length >= meetings.length) {
      return '독서';
    } else if (exercises.length >= readings.length &&
        exercises.length >= meetings.length) {
      return '운동';
    } else if (meetings.isNotEmpty) {
      return '모임';
    } else {
      return '성장';
    }
  }

  // 🎯 가중치 기반 추천 모임 선택 (메시지와 일치하는 카테고리 우선)
  AvailableMeeting? _selectRecommendedMeeting(Map<String, dynamic> analysis) {
    final meetingState = ref.watch(globalMeetingProvider);
    final meetings = meetingState.availableMeetings;

    if (meetings.isEmpty) return null;

    // 추천된 카테고리와 점수 가져오기
    final recommendedCategory =
        analysis['recommendedCategory'] as MeetingCategory;
    final categoryScores =
        analysis['categoryScores'] as Map<MeetingCategory, double>;

    // 참여 가능한 모임만 필터링
    final availableMeetings = meetings
        .where((m) => m.currentParticipants < m.maxParticipants)
        .toList();

    if (availableMeetings.isEmpty) return null;

    // 🎯 추천 카테고리의 모임을 우선적으로 필터링
    final recommendedCategoryMeetings = availableMeetings
        .where((m) => m.category == recommendedCategory)
        .toList();

    // 🎯 추천 카테고리의 모임이 있으면 그 중에서 선택
    if (recommendedCategoryMeetings.isNotEmpty) {
      // 추천 카테고리 내에서 점수 계산
      final scoredRecommendedMeetings =
          recommendedCategoryMeetings.map((meeting) {
        double score = 1.0; // 기본 점수

        final totalActivities = (analysis['totalActivities'] as int? ?? 0);

        // 인기도 보너스 (50% 이상 참여율)
        final participationRate =
            meeting.currentParticipants / meeting.maxParticipants;
        if (participationRate >= 0.5 && participationRate < 0.9) {
          score += 0.2; // 적당히 인기 있는 모임 선호
        }

        // 활동 빈도에 따른 난이도 선호
        if (totalActivities > 10) {
          // 활발한 사용자는 다양한 모임 선호
          score += 0.1;
        }

        return MapEntry(meeting, score);
      }).toList();

      // 점수 기준으로 정렬
      scoredRecommendedMeetings.sort((a, b) => b.value.compareTo(a.value));

      // 상위 3개 중 랜덤 선택 (다양성 유지)
      final topMeetings = scoredRecommendedMeetings.take(3).toList();
      if (topMeetings.isNotEmpty) {
        final random = Random();
        return topMeetings[random.nextInt(topMeetings.length)].key;
      }
    }

    // 🔄 추천 카테고리에 모임이 없으면 전체에서 선택
    // 각 모임에 대한 호환성 점수 계산
    final scoredMeetings = availableMeetings.map((meeting) {
      double score = categoryScores[meeting.category] ?? 0.0;

      // 추가 점수 부여 로직
      final totalActivities = (analysis['totalActivities'] as int? ?? 0);

      // 활동 빈도 기반 점수 보정
      if (totalActivities > 10) {
        if (meeting.category == MeetingCategory.networking ||
            meeting.category == MeetingCategory.culture) {
          score += 0.05;
        }
      }

      // 인기도 보너스
      final participationRate =
          meeting.currentParticipants / meeting.maxParticipants;
      if (participationRate >= 0.5 && participationRate < 0.9) {
        score += 0.05;
      }

      return MapEntry(meeting, score);
    }).toList();

    // 점수 기준으로 정렬
    scoredMeetings.sort((a, b) => b.value.compareTo(a.value));

    // 점수가 0보다 큰 모임 중 상위 5개 선택
    final validMeetings =
        scoredMeetings.where((e) => e.value > 0).take(5).toList();

    if (validMeetings.isNotEmpty) {
      // 가중치 기반 랜덤 선택
      final random = Random();
      final totalScore = validMeetings.fold(0.0, (sum, e) => sum + e.value);
      var randomValue = random.nextDouble() * totalScore;

      for (var meeting in validMeetings) {
        randomValue -= meeting.value;
        if (randomValue <= 0) {
          return meeting.key;
        }
      }

      return validMeetings.first.key;
    }

    // 모든 점수가 0이면 전체에서 랜덤 선택
    if (availableMeetings.isNotEmpty) {
      final random = Random();
      return availableMeetings[random.nextInt(availableMeetings.length)];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final analysis = _analyzeUserActivity();
    final recommendedMeeting = _selectRecommendedMeeting(analysis);

    if (recommendedMeeting == null) {
      return const SizedBox.shrink(); // 추천할 모임이 없으면 위젯 숨기기
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            // 🎨 통일된 디자인: ModernColors.surface 사용
            color: ModernColors.surface,
            borderRadius: BorderRadius.circular(24),
            // 🎨 다른 위젯들과 동일한 그림자 효과
            boxShadow: ModernColors.softShadow(
              primaryColor: ModernColors.primary,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 프리미엄 헤더 섹션 (다른 위젯들과 통일)
              _buildPremiumHeader(
                  context, analysis['emotion'] as SherpiEmotion),

              // 📝 셰르피 인사이트 메시지
              _buildInsightSection(
                user.name,
                analysis['insight'] as String,
              ),

              const SizedBox(height: 12),

              // 🤖 AI 추천 버튼
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _CompactAIRecommendationButton(),
              ),

              const SizedBox(height: 16),

              // 📋 추천 모임 카드
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _buildMeetingCard(recommendedMeeting),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 프리미엄 헤더 디자인 (다른 위젯들과 통일된 스타일)
  Widget _buildPremiumHeader(BuildContext context, SherpiEmotion emotion) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
      child: Row(
        children: [
          // 아이콘 + 타이틀 영역
          Expanded(
            child: Row(
              children: [
                // 🎯 셰르피 아이콘
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Transform.scale(
                      scale: 1.7,
                      child: Image.asset(
                        'assets/images/sherpi/sherpi_smile.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2), // 7 - 5 = 2픽셀로 더 줄여서 텍스트를 좌측으로 추가 이동

                // 📝 타이틀 + 서브타이틀
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '셰르피가 추천하는 모임',
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '활동 패턴 기반 AI 맞춤 추천',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔗 "모든 모임 보기" 링크 (compact_quest_widget 스타일)
          GestureDetector(
            onTap: () {
              HapticFeedbackManager.lightImpact();
              Navigator.pushNamed(context, '/', arguments: 3);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ModernColors.modernPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📝 인사이트 섹션 (셰르피의 분석 메시지)
  Widget _buildInsightSection(String userName, String insight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // 🎨 부드러운 배경색으로 구분
        color: ModernColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 셰르피 라벨
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: ModernColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '셰르피 AI 분석',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 인사이트 메시지
          RichText(
            text: TextSpan(
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textPrimary,
                height: 1.5,
              ),
              children: [
                if (insight.contains('💪 최근 2주간 운동을 열심히 하셨네요!')) ...[
                  TextSpan(
                    text: '💪 최근 2주간 운동을 열심히 하셨네요! ',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: insight.substring('💪 최근 2주간 운동을 열심히 하셨네요! '.length),
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ModernColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ] else if (insight.contains('📚')) ...[
                  TextSpan(
                    text: '${insight.split('!')[0]}! ',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  if (insight.split('!').length > 1)
                    TextSpan(
                      text: insight.split('!').sublist(1).join('!'),
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ModernColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                ] else if (insight.contains('🤝')) ...[
                  TextSpan(
                    text: '${insight.split('!')[0]}! ',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  if (insight.split('!').length > 1)
                    TextSpan(
                      text: insight.split('!').sublist(1).join('!'),
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ModernColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                ] else ...[
                  TextSpan(
                    text: insight,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ModernColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 모임 카드 (사진 배경)
  Widget _buildMeetingCard(AvailableMeeting meeting) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        Navigator.pushNamed(
          context,
          '/meeting_detail',
          arguments: {'meetingId': meeting.id},
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 📸 배경 이미지
              Positioned.fill(
                child: _buildImageWidget(meeting),
              ),

              // 🌫️ 그라데이션 오버레이
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // 📝 콘텐츠 오버레이
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: meeting.category.color.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  meeting.category.color.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              meeting.category.emoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              meeting.category.displayName,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // 제목
                      Text(
                        meeting.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // 위치 & 시간
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${meeting.location} · ${meeting.formattedDate}',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 참가자 & 가격
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 참가자 아바타
                          ParticipantAvatars2025(
                            currentParticipants: meeting.currentParticipants,
                            maxParticipants: meeting.maxParticipants,
                            size: 24,
                            overlapFactor: 0.65,
                          ),

                          // 가격 배지
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: meeting.type == MeetingType.free
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: meeting.type == MeetingType.free
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.orange.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              meeting.type == MeetingType.free
                                  ? '무료'
                                  : '${meeting.participationFee.toInt()}P',
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: meeting.type == MeetingType.free
                                    ? Colors.green[100]
                                    : Colors.orange[100],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📸 이미지 위젯
  Widget _buildImageWidget(AvailableMeeting meeting) {
    if (meeting.hasImages && meeting.imageFileNames.isNotEmpty) {
      final firstImage = meeting.imageFileNames.first;

      if (firstImage.startsWith('asset:')) {
        final assetPath = 'assets/images/meeting/${firstImage.substring(6)}';
        return Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(meeting),
        );
      }

      return FutureBuilder<File?>(
        future: MeetingImageUtils.getMeetingImageFile(firstImage),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(meeting),
            );
          }
          return _buildImagePlaceholder(meeting);
        },
      );
    }

    return _buildImagePlaceholder(meeting);
  }

  // 🎨 이미지 플레이스홀더 (부드러운 그라데이션)
  Widget _buildImagePlaceholder(AvailableMeeting meeting) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            meeting.category.color.withValues(alpha: 0.8),
            meeting.category.color.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              meeting.category.emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactAIRecommendationButton extends ConsumerWidget {
  const _CompactAIRecommendationButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(globalAIRecommendationProvider);

    return GestureDetector(
      onTap: aiState.isLoading
          ? null
          : () async {
              HapticFeedbackManager.lightImpact();

              final user = ref.read(globalUserProvider);
              final meetingState = ref.read(globalMeetingProvider);

              if (meetingState.availableMeetings.isEmpty) {
                _showError(context, '현재 참여 가능한 모임이 없습니다');
                return;
              }

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AIAnalysisLoadingWidget(),
              );

              await ref
                  .read(globalAIRecommendationProvider.notifier)
                  .generateRecommendations(
                    user: user,
                    availableMeetings: meetingState.availableMeetings,
                  );

              if (context.mounted) {
                Navigator.of(context).pop();
              }

              final updatedState = ref.read(globalAIRecommendationProvider);

              if (updatedState.error != null && context.mounted) {
                _showError(context, updatedState.error!);
                return;
              }

              if (updatedState.recommendations.isNotEmpty && context.mounted) {
                _showRecommendationResults(
                  context,
                  updatedState.recommendations,
                );
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ModernColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ModernColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 14,
              color: ModernColors.primary,
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .shimmer(
                  duration: const Duration(seconds: 2),
                  color: ModernColors.primary.withValues(alpha: 0.5),
                ),
            const SizedBox(width: 4),
            Text(
              'AI 추천',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ModernColors.primary,
              ),
            ),
            if (aiState.isLoading) ...[
              const SizedBox(width: 4),
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ModernColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.notoSans(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: ModernColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showRecommendationResults(
    BuildContext context,
    List<AIRecommendedMeeting> recommendations,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIRecommendationResultCards(
        recommendations: recommendations,
      ),
    );
  }
}
