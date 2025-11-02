// 🎯 자동 추억 생성 서비스
//
// 사용자의 활동과 상호작용을 기반으로 자동으로 추억을 생성하는 서비스

import 'package:sherpa_app/features/sherpi/relationship/models/shared_memory_model.dart';
import 'memory_management_service.dart';
import 'package:sherpa_app/features/sherpi/emotion/models/emotion_state_model.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';

/// 🎯 자동 추억 생성 서비스
class MemoryCreationService {
  /// 🏆 성취 활동에서 추억 생성
  static Future<SharedMemory?> createMemoryFromAchievement({
    required String activityType,
    required Map<String, dynamic> achievementData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) async {
    try {
      final memory = _generateAchievementMemory(
        activityType: activityType,
        achievementData: achievementData,
        userName: userName,
        currentEmotion: currentEmotion,
      );

      if (memory != null) {
        await MemoryManagementService.saveMemory(memory);
        return memory;
      }

      return null;
    } catch (e) {
      LoggerService.instance.d('성취 추억 생성 오류: $e');
      return null;
    }
  }

  /// 🎉 기념일 활동에서 추억 생성
  static Future<SharedMemory?> createMemoryFromCelebration({
    required String celebrationType,
    required Map<String, dynamic> celebrationData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) async {
    try {
      final memory = _generateCelebrationMemory(
        celebrationType: celebrationType,
        celebrationData: celebrationData,
        userName: userName,
        currentEmotion: currentEmotion,
      );

      if (memory != null) {
        await MemoryManagementService.saveMemory(memory);
        return memory;
      }

      return null;
    } catch (e) {
      LoggerService.instance.d('기념 추억 생성 오류: $e');
      return null;
    }
  }

  /// 💪 도전 극복에서 추억 생성
  static Future<SharedMemory?> createMemoryFromChallenge({
    required String challengeType,
    required Map<String, dynamic> challengeData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) async {
    try {
      final memory = _generateChallengeMemory(
        challengeType: challengeType,
        challengeData: challengeData,
        userName: userName,
        currentEmotion: currentEmotion,
      );

      if (memory != null) {
        await MemoryManagementService.saveMemory(memory);
        return memory;
      }

      return null;
    } catch (e) {
      LoggerService.instance.d('도전 추억 생성 오류: $e');
      return null;
    }
  }

  /// 💖 감정적 순간에서 추억 생성
  static Future<SharedMemory?> createMemoryFromEmotionalMoment({
    required EmotionSnapshot emotion,
    required Map<String, dynamic> contextData,
    String? userName,
    String? trigger,
  }) async {
    // 강한 감정이거나 특별한 감정일 때만 추억 생성
    if (emotion.intensity.level < 3 || !_isSignificantEmotion(emotion)) {
      return null;
    }

    try {
      final memory = _generateEmotionalMemory(
        emotion: emotion,
        contextData: contextData,
        userName: userName,
        trigger: trigger,
      );

      if (memory != null) {
        await MemoryManagementService.saveMemory(memory);
        return memory;
      }

      return null;
    } catch (e) {
      LoggerService.instance.d('감정 추억 생성 오류: $e');
      return null;
    }
  }

  /// 📚 학습 활동에서 추억 생성
  static Future<SharedMemory?> createMemoryFromLearning({
    required String learningType,
    required Map<String, dynamic> learningData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) async {
    try {
      final memory = _generateLearningMemory(
        learningType: learningType,
        learningData: learningData,
        userName: userName,
        currentEmotion: currentEmotion,
      );

      if (memory != null) {
        await MemoryManagementService.saveMemory(memory);
        return memory;
      }

      return null;
    } catch (e) {
      LoggerService.instance.d('학습 추억 생성 오류: $e');
      return null;
    }
  }

  /// 🌟 마일스톤에서 추억 생성
  static Future<SharedMemory?> createMemoryFromMilestone({
    required String milestoneType,
    required Map<String, dynamic> milestoneData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) async {
    try {
      final memory = _generateMilestoneMemory(
        milestoneType: milestoneType,
        milestoneData: milestoneData,
        userName: userName,
        currentEmotion: currentEmotion,
      );

      if (memory != null) {
        await MemoryManagementService.saveMemory(memory);
        return memory;
      }

      return null;
    } catch (e) {
      LoggerService.instance.d('마일스톤 추억 생성 오류: $e');
      return null;
    }
  }

  /// ☀️ 일상 활동에서 추억 생성 (선별적)
  static Future<SharedMemory?> createMemoryFromDaily({
    required String activityType,
    required Map<String, dynamic> activityData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) async {
    // 일상 활동은 특별한 조건일 때만 추억으로 저장
    if (!_shouldCreateDailyMemory(activityType, activityData, currentEmotion)) {
      return null;
    }

    try {
      final memory = _generateDailyMemory(
        activityType: activityType,
        activityData: activityData,
        userName: userName,
        currentEmotion: currentEmotion,
      );

      if (memory != null) {
        await MemoryManagementService.saveMemory(memory);
        return memory;
      }

      return null;
    } catch (e) {
      LoggerService.instance.d('일상 추억 생성 오류: $e');
      return null;
    }
  }

  /// 🏆 성취 추억 생성 로직
  static SharedMemory? _generateAchievementMemory({
    required String activityType,
    required Map<String, dynamic> achievementData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) {
    final String title;
    final String content;
    final List<String> tags;
    final MemoryImportance importance;

    switch (activityType) {
      case 'exercise':
        final duration = achievementData['duration'] as int? ?? 0;
        final type = achievementData['type'] as String? ?? '운동';
        title = '운동 목표 달성!';
        content = '오늘 $type을(를) $duration분간 완료했어요! 건강한 하루를 보냈네요. 💪';
        tags = ['exercise', 'health', 'achievement'];
        importance = duration >= 60
            ? MemoryImportance.meaningful
            : MemoryImportance.normal;
        break;

      case 'reading':
        final pages = achievementData['pages'] as int? ?? 0;
        final bookTitle = achievementData['bookTitle'] as String? ?? '책';
        title = '독서 완료!';
        content = '$bookTitle을(를) $pages페이지 읽었어요! 지식이 한층 더 쌓였네요. 📚';
        tags = ['reading', 'learning', 'achievement'];
        importance =
            pages >= 50 ? MemoryImportance.meaningful : MemoryImportance.normal;
        break;

      case 'diary':
        title = '일기 작성 완료!';
        content = '오늘 하루를 정리하며 소중한 일기를 작성했어요. 마음이 한결 가벼워졌죠? ✨';
        tags = ['diary', 'reflection', 'achievement'];
        importance = MemoryImportance.meaningful;
        break;

      case 'quest':
        final questName = achievementData['questName'] as String? ?? '퀘스트';
        title = '퀘스트 완료!';
        content = '$questName을(를) 성공적으로 완료했어요! 한 걸음씩 성장하고 있어요. 🌟';
        tags = ['quest', 'achievement', 'growth'];
        importance = MemoryImportance.important;
        break;

      default:
        return null;
    }

    return SharedMemory(
      id: 'memory_achievement_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: MemoryCategory.achievement,
      importance: importance,
      createdAt: DateTime.now(),
      context: {
        'activity_type': activityType,
        'user_name': userName,
        ...achievementData,
      },
      tags: tags,
      emotionalContext: currentEmotion != null
          ? {
              'emotion': currentEmotion.type.id,
              'intensity': currentEmotion.intensity.level,
              'confidence': currentEmotion.confidence.level,
            }
          : {},
    );
  }

  /// 🎉 기념 추억 생성 로직
  static SharedMemory? _generateCelebrationMemory({
    required String celebrationType,
    required Map<String, dynamic> celebrationData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) {
    final String title;
    final String content;
    final List<String> tags;

    switch (celebrationType) {
      case 'level_up':
        final level = celebrationData['level'] as int? ?? 1;
        title = '레벨 업 달성!';
        content = '축하해요! 레벨 $level에 도달했어요! 꾸준한 노력의 결과네요. 🎉';
        tags = ['level_up', 'celebration', 'progress'];
        break;

      case 'streak':
        final days = celebrationData['days'] as int? ?? 1;
        title = '연속 달성 기록!';
        content = '와! $days일 연속으로 목표를 달성했어요! 정말 대단해요. 🔥';
        tags = ['streak', 'consistency', 'celebration'];
        break;

      case 'milestone':
        final milestoneName = celebrationData['milestone'] as String? ?? '목표';
        title = '마일스톤 달성!';
        content = '$milestoneName 마일스톤을 달성했어요! 이 순간이 정말 소중해요. ✨';
        tags = ['milestone', 'celebration', 'special'];
        break;

      default:
        return null;
    }

    return SharedMemory(
      id: 'memory_celebration_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: MemoryCategory.celebration,
      importance: MemoryImportance.important,
      createdAt: DateTime.now(),
      context: {
        'celebration_type': celebrationType,
        'user_name': userName,
        ...celebrationData,
      },
      tags: tags,
      emotionalContext: currentEmotion != null
          ? {
              'emotion': currentEmotion.type.id,
              'intensity': currentEmotion.intensity.level,
              'confidence': currentEmotion.confidence.level,
            }
          : {'emotion': 'joy', 'intensity': 4},
    );
  }

  /// 💪 도전 추억 생성 로직
  static SharedMemory? _generateChallengeMemory({
    required String challengeType,
    required Map<String, dynamic> challengeData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) {
    final String title;
    final String content;
    final List<String> tags;

    switch (challengeType) {
      case 'difficult_exercise':
        final exerciseType = challengeData['type'] as String? ?? '운동';
        title = '힘든 운동 극복!';
        content =
            '오늘 $exerciseType이 정말 힘들었지만 끝까지 해냈어요! 포기하지 않는 마음이 정말 대단해요. 💪';
        tags = ['challenge', 'exercise', 'perseverance'];
        break;

      case 'motivation_low':
        title = '의욕 저하 극복!';
        content = '의욕이 없었지만 그래도 무언가를 해냈어요. 작은 시작이 큰 변화를 만들어요. 🌱';
        tags = ['challenge', 'motivation', 'overcome'];
        break;

      case 'time_management':
        title = '시간 관리 도전!';
        content = '바쁜 하루였지만 계획한 일들을 해냈어요! 시간을 잘 활용했네요. ⏰';
        tags = ['challenge', 'time_management', 'productivity'];
        break;

      default:
        return null;
    }

    return SharedMemory(
      id: 'memory_challenge_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: MemoryCategory.challenge,
      importance: MemoryImportance.meaningful,
      createdAt: DateTime.now(),
      context: {
        'challenge_type': challengeType,
        'user_name': userName,
        ...challengeData,
      },
      tags: tags,
      emotionalContext: currentEmotion != null
          ? {
              'emotion': currentEmotion.type.id,
              'intensity': currentEmotion.intensity.level,
              'confidence': currentEmotion.confidence.level,
            }
          : {'emotion': 'pride', 'intensity': 3},
    );
  }

  /// 💖 감정 추억 생성 로직
  static SharedMemory? _generateEmotionalMemory({
    required EmotionSnapshot emotion,
    required Map<String, dynamic> contextData,
    String? userName,
    String? trigger,
  }) {
    final String title;
    final String content;
    final List<String> tags;
    final MemoryImportance importance;

    switch (emotion.type.category) {
      case EmotionCategory.positive:
        title = '행복한 순간';
        content =
            '오늘 정말 ${emotion.type.displayName}한 순간을 보냈어요! 이런 기분 좋은 날이 더 많았으면 좋겠어요. 😊';
        tags = ['emotion', 'positive', emotion.type.id];
        importance = emotion.intensity.level >= 4
            ? MemoryImportance.unforgettable
            : MemoryImportance.meaningful;
        break;

      case EmotionCategory.negative:
        title = '어려운 순간을 함께';
        content =
            '오늘은 ${emotion.type.displayName}한 기분이었지만, 그래도 함께 이겨내고 있어요. 괜찮아요, 이런 날도 있는 거예요. 🤗';
        tags = ['emotion', 'support', emotion.type.id];
        importance = MemoryImportance.meaningful;
        break;

      case EmotionCategory.mixed:
        title = '복잡한 감정의 순간';
        content = '오늘은 여러 감정이 섞인 복잡한 하루였어요. 이런 날도 우리의 소중한 기억이 될 거예요. 🤔';
        tags = ['emotion', 'mixed', emotion.type.id];
        importance = MemoryImportance.meaningful;
        break;

      case EmotionCategory.neutral:
        // 중성적 감정은 추억으로 만들지 않음
        return null;

      case EmotionCategory.unknown:
        // 불분명한 감정은 추억으로 만들지 않음
        return null;
    }

    return SharedMemory(
      id: 'memory_emotion_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: MemoryCategory.emotion,
      importance: importance,
      createdAt: DateTime.now(),
      context: {
        'trigger': trigger,
        'user_name': userName,
        'emotion_source': emotion.source.name,
        ...contextData,
      },
      tags: tags,
      emotionalContext: {
        'emotion': emotion.type.id,
        'intensity': emotion.intensity.level,
        'confidence': emotion.confidence.level,
        'category': emotion.type.category.name,
      },
    );
  }

  /// 📚 학습 추억 생성 로직
  static SharedMemory? _generateLearningMemory({
    required String learningType,
    required Map<String, dynamic> learningData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) {
    final String title;
    final String content;
    final List<String> tags;

    switch (learningType) {
      case 'new_skill':
        final skill = learningData['skill'] as String? ?? '새로운 기술';
        title = '새로운 것을 배웠어요!';
        content = '오늘 $skill에 대해 배웠어요! 새로운 지식을 얻는 것은 언제나 즐거워요. 🧠';
        tags = ['learning', 'skill', 'growth'];
        break;

      case 'insight':
        final insight = learningData['insight'] as String? ?? '깨달음';
        title = '새로운 깨달음!';
        content = '오늘 $insight에 대한 새로운 깨달음을 얻었어요! 생각이 한층 더 깊어졌네요. 💡';
        tags = ['learning', 'insight', 'wisdom'];
        break;

      default:
        return null;
    }

    return SharedMemory(
      id: 'memory_learning_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: MemoryCategory.learning,
      importance: MemoryImportance.meaningful,
      createdAt: DateTime.now(),
      context: {
        'learning_type': learningType,
        'user_name': userName,
        ...learningData,
      },
      tags: tags,
      emotionalContext: currentEmotion != null
          ? {
              'emotion': currentEmotion.type.id,
              'intensity': currentEmotion.intensity.level,
              'confidence': currentEmotion.confidence.level,
            }
          : {'emotion': 'curious', 'intensity': 3},
    );
  }

  /// 🌟 마일스톤 추억 생성 로직
  static SharedMemory? _generateMilestoneMemory({
    required String milestoneType,
    required Map<String, dynamic> milestoneData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) {
    final String title;
    final String content;
    final List<String> tags;

    switch (milestoneType) {
      case 'first_week':
        title = '첫 일주일 함께!';
        content = '셰르피와 함께한 지 일주일이 되었어요! 벌써 친구가 된 기분이에요. 🎉';
        tags = ['milestone', 'friendship', 'week'];
        break;

      case 'first_month':
        title = '한 달 기념!';
        content = '와! 셰르피와 함께한 지 한 달이 되었어요! 정말 많은 추억을 만들었네요. 🌟';
        tags = ['milestone', 'friendship', 'month'];
        break;

      case 'relationship_stage':
        final stage = milestoneData['stage'] as String? ?? '새로운 단계';
        title = '관계 발전!';
        content = '우리 관계가 $stage 단계로 발전했어요! 더 가까워진 것 같아서 기뻐요. 💖';
        tags = ['milestone', 'relationship', 'growth'];
        break;

      default:
        return null;
    }

    return SharedMemory(
      id: 'memory_milestone_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: MemoryCategory.milestone,
      importance: MemoryImportance.important,
      createdAt: DateTime.now(),
      context: {
        'milestone_type': milestoneType,
        'user_name': userName,
        ...milestoneData,
      },
      tags: tags,
      emotionalContext: currentEmotion != null
          ? {
              'emotion': currentEmotion.type.id,
              'intensity': currentEmotion.intensity.level,
              'confidence': currentEmotion.confidence.level,
            }
          : {'emotion': 'joy', 'intensity': 4},
    );
  }

  /// ☀️ 일상 추억 생성 로직
  static SharedMemory? _generateDailyMemory({
    required String activityType,
    required Map<String, dynamic> activityData,
    String? userName,
    EmotionSnapshot? currentEmotion,
  }) {
    final String title;
    final String content;
    final List<String> tags;

    switch (activityType) {
      case 'perfect_day':
        title = '완벽한 하루!';
        content = '오늘은 모든 활동을 완벽하게 해냈어요! 이런 날이 더 많았으면 좋겠어요. ✨';
        tags = ['daily', 'perfect', 'achievement'];
        break;

      case 'first_time':
        final activity = activityData['activity'] as String? ?? '새로운 활동';
        title = '처음 해보는 일!';
        content = '오늘 처음으로 $activity을(를) 해봤어요! 새로운 경험이 언제나 즐거워요. 🆕';
        tags = ['daily', 'first_time', 'experience'];
        break;

      case 'weather_perfect':
        title = '날씨 좋은 날!';
        content = '오늘은 날씨가 정말 좋았어요! 이런 날에는 기분도 더 좋아지는 것 같아요. ☀️';
        tags = ['daily', 'weather', 'mood'];
        break;

      default:
        return null;
    }

    return SharedMemory(
      id: 'memory_daily_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: MemoryCategory.daily,
      importance: MemoryImportance.normal,
      createdAt: DateTime.now(),
      context: {
        'activity_type': activityType,
        'user_name': userName,
        ...activityData,
      },
      tags: tags,
      emotionalContext: currentEmotion != null
          ? {
              'emotion': currentEmotion.type.id,
              'intensity': currentEmotion.intensity.level,
              'confidence': currentEmotion.confidence.level,
            }
          : {'emotion': 'content', 'intensity': 3},
    );
  }

  /// 🎭 중요한 감정인지 확인
  static bool _isSignificantEmotion(EmotionSnapshot emotion) {
    // 강한 감정이거나 특별한 감정 타입일 때
    return emotion.intensity.level >= 3 ||
        emotion.type.category != EmotionCategory.neutral;
  }

  /// ☀️ 일상 추억을 만들어야 하는지 확인
  static bool _shouldCreateDailyMemory(
    String activityType,
    Map<String, dynamic> activityData,
    EmotionSnapshot? currentEmotion,
  ) {
    // 특별한 조건들
    final isFirstTime = activityData['is_first_time'] == true;
    final isPerfectScore = activityData['score'] == 100;
    final isLongStreak = (activityData['streak'] as int? ?? 0) >= 7;
    final hasStrongEmotion = (currentEmotion?.intensity.level ?? 0) >= 4;
    final isWeekend = DateTime.now().weekday >= 6;
    final isSpecialDay = activityData['is_special_day'] == true;

    return isFirstTime ||
        isPerfectScore ||
        isLongStreak ||
        hasStrongEmotion ||
        (isWeekend && hasStrongEmotion) ||
        isSpecialDay;
  }
}
