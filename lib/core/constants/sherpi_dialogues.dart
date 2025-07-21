// 셰르피 대화 시스템 - 백엔드 연동 및 AI 준비 구조
import 'dart:math';

// 셰르피가 등장하는 상황 정의
enum SherpiContext {
  // 기본 상호작용
  welcome,              // 앱 첫 실행 환영
  dailyGreeting,        // 일일 첫 접속
  longTimeNoSee,        // 오랜만에 접속 (7일 이상)
  general,              // 일반적인 상황

  // 성장 관련
  levelUp,              // 레벨업 축하
  statIncrease,         // 능력치 상승
  badgeEarned,          // 뱃지 획득
  titleEarned,          // 칭호 획득

  // 등반 관련
  climbingStart,        // 등반 시작
  climbingSuccess,      // 등반 성공
  climbingFailure,      // 등반 실패
  questComplete,        // 퀘스트 완료
  firstClimb,           // 첫 등반

  // 일상 기록 관련
  exerciseComplete,     // 운동 완료
  studyComplete,        // 공부 완료
  diaryWritten,         // 일기 작성
  focusComplete,        // 집중 타이머 완료

  // 경고 및 안내
  tiredWarning,         // 피로도 경고
  encouragement,        // 격려
  guidance,             // 안내/설명
  tutorial,             // 튜토리얼

  // 커뮤니티 관련
  meetingJoined,        // 모임 참가
  friendActivity,       // 친구 활동 알림
  guildRankUp,          // 길드 랭킹 상승

  // 특별 이벤트
  specialEvent,         // 특별 이벤트
  achievement,          // 특별 성취
  milestone,            // 마일스톤 달성
  seasonalGreeting,     // 계절 인사
}

// 셰르피의 감정 상태 (이미지 파일명과 일치)
enum SherpiEmotion {
  defaults,     // sherpi_default.png
  happy,        // sherpi_happy.png
  sad,          // sherpi_sad.png
  surprised,    // sherpi_surprised.png
  thinking,     // sherpi_thinking.png
  guiding,      // sherpi_guiding.png
  cheering,     // sherpi_cheering.png
  warning,      // sherpi_warning.png
  sleeping,     // sherpi_sleeping.png
  special,      // sherpi_special.png
  meditating,   // sherpi_meditating.png
  celebrating,  // sherpi_celebrating.png
  calm,         // sherpi_calm.png
  worried,      // sherpi_worried.png
  encouraging,  // sherpi_encouraging.png
}

// 정적 대화 데이터 (추후 백엔드 API로 대체 가능)
const Map<SherpiContext, List<String>> sherpiDialogues = {
  // 기본 상호작용
  SherpiContext.welcome: [
    '셰르파에 오신 것을 환영해요! 🏔️',
    '새로운 등반 여정이 시작되네요!',
    '함께 멋진 성장을 만들어가요!',
    '당신의 모험을 응원할게요!',
  ],

  SherpiContext.dailyGreeting: [
    '오늘도 좋은 하루 보내세요! ☀️',
    '새로운 하루, 새로운 도전이에요!',
    '오늘은 어떤 모험을 떠나볼까요?',
    '활기찬 하루가 되길 바라요!',
  ],

  SherpiContext.general: [
    '무엇을 도와드릴까요? 😊',
    '함께 해봐요!',
    '좋은 생각이에요!',
    '그렇게 해보세요!',
  ],

  SherpiContext.longTimeNoSee: [
    '오랜만이에요! 많이 보고 싶었어요 😊',
    '돌아와 주셔서 감사해요!',
    '그동안 어떻게 지내셨나요?',
    '기다리고 있었어요! 다시 만나서 반가워요!',
  ],

  // 성장 관련
  SherpiContext.levelUp: [
    '레벨 업! 정말 대단해요! 🎉',
    '점점 더 강해지고 있군요!',
    '멋진 성장이에요! 축하드려요!',
    '새로운 레벨에서도 화이팅!',
    '꾸준한 노력의 결과네요!',
  ],

  SherpiContext.statIncrease: [
    '능력치가 상승했어요! 💪',
    '꾸준한 노력의 결과네요!',
    '더욱 강해지고 있어요!',
    '이런 성장이 보기 좋아요!',
  ],

  SherpiContext.badgeEarned: [
    '새로운 뱃지를 획득하셨네요! 🏅',
    '정말 멋진 성취예요!',
    '이 뱃지가 더 큰 힘이 될 거예요!',
    '특별한 순간이네요!',
  ],

  SherpiContext.titleEarned: [
    '새로운 칭호를 얻으셨네요! 👑',
    '정말 자랑스러운 성취예요!',
    '이 칭호가 잘 어울려요!',
    '대단한 실력이에요!',
  ],

  // 등반 관련
  SherpiContext.climbingStart: [
    '등반을 시작하시는군요! 화이팅! 🧗‍♂️',
    '안전하게 다녀오세요!',
    '좋은 결과가 있을 거예요!',
    '최선을 다하시길 바라요!',
  ],

  SherpiContext.climbingSuccess: [
    '등반 성공! 정말 멋져요! ⛰️',
    '완벽한 등반이었어요!',
    '다음 도전도 기대돼요!',
    '실력이 늘고 있어요!',
  ],

  SherpiContext.climbingFailure: [
    '괜찮아요, 다음에 더 잘할 수 있어요 💪',
    '실패도 성장의 과정이에요!',
    '포기하지 마세요, 응원할게요!',
    '다시 도전해봐요!',
  ],

  SherpiContext.questComplete: [
    '퀘스트 완료! 훌륭해요! ✨',
    '목표를 달성하셨네요!',
    '다음 퀘스트도 기대돼요!',
    '정말 성실하시네요!',
  ],

  SherpiContext.firstClimb: [
    '첫 등반을 축하드려요! 🎊',
    '새로운 시작이네요!',
    '앞으로가 더 기대돼요!',
    '좋은 출발이에요!',
  ],

  // 일상 기록 관련
  SherpiContext.exerciseComplete: [
    '운동 완료! 건강해지고 있어요! 🏃‍♂️',
    '꾸준한 운동이 힘이 되고 있어요!',
    '체력이 늘고 있는 게 느껴져요!',
    '건강한 습관이 좋아요!',
  ],

  SherpiContext.studyComplete: [
    '공부 완료! 지식이 늘어나고 있어요! 📚',
    '배움의 즐거움을 느끼고 계시네요!',
    '더 똑똑해지고 있어요!',
    '꾸준한 학습이 대단해요!',
  ],

  SherpiContext.diaryWritten: [
    '일기 작성 완료! 소중한 기록이에요 📝',
    '하루를 돌아보는 시간이 중요해요!',
    '마음도 정리되셨을 거예요!',
    '좋은 습관이에요!',
  ],

  SherpiContext.focusComplete: [
    '집중 시간 완료! 정말 대단해요! ⏰',
    '집중력이 늘고 있어요!',
    '효율적인 시간 관리네요!',
    '몰입의 힘을 느끼셨나요?',
  ],

  // 경고 및 안내
  SherpiContext.tiredWarning: [
    '조금 피곤해 보이시네요. 휴식이 필요해요 😴',
    '무리하지 마시고 충분히 쉬세요!',
    '건강이 가장 중요해요!',
    '잠시 쉬어가는 것도 좋아요!',
  ],

  SherpiContext.encouragement: [
    '힘내세요! 당신은 할 수 있어요! 💪',
    '포기하지 마세요, 거의 다 왔어요!',
    '당신의 노력을 믿어요!',
    '조금만 더 힘내봐요!',
  ],

  SherpiContext.guidance: [
    '이렇게 해보시는 건 어떨까요? 🤔',
    '제가 도와드릴게요!',
    '함께 해결해봐요!',
    '차근차근 알려드릴게요!',
  ],

  SherpiContext.tutorial: [
    '튜토리얼을 시작해볼까요? 📖',
    '차근차근 알려드릴게요!',
    '어렵지 않으니 걱정 마세요!',
    '함께 배워봐요!',
  ],

  // 커뮤니티 관련
  SherpiContext.meetingJoined: [
    '새로운 모임에 참가하셨네요! 🤝',
    '좋은 인연이 생길 거예요!',
    '함께하는 즐거움을 느껴보세요!',
    '새로운 친구들과 즐거운 시간 되세요!',
  ],

  SherpiContext.friendActivity: [
    '친구가 새로운 활동을 했어요! 👥',
    '함께 성장하는 모습이 보기 좋아요!',
    '서로 응원하며 발전해나가세요!',
    '좋은 친구들이 있으시네요!',
  ],

  SherpiContext.guildRankUp: [
    '길드 랭킹이 올라갔어요! 🏆',
    '팀워크가 훌륭하네요!',
    '함께 이룬 성과예요!',
    '길드원들과 축하해보세요!',
  ],

  // 특별 이벤트
  SherpiContext.specialEvent: [
    '특별한 이벤트가 시작됐어요! 🎊',
    '놓치지 마시고 참여해보세요!',
    '특별한 보상이 기다리고 있어요!',
    '이런 기회는 흔하지 않아요!',
  ],

  SherpiContext.achievement: [
    '대단한 성취를 이루셨네요! 🏆',
    '정말 자랑스러워요!',
    '이런 순간이 소중해요!',
    '모든 노력이 결실을 맺었네요!',
  ],

  SherpiContext.milestone: [
    '중요한 이정표에 도달하셨네요! 🎯',
    '의미 있는 순간이에요!',
    '여기까지 오시느라 고생하셨어요!',
    '다음 목표도 기대돼요!',
  ],

  SherpiContext.seasonalGreeting: [
    '계절이 바뀌었네요! 🌸',
    '새로운 계절을 맞이해요!',
    '계절의 변화가 느껴져요!',
    '이번 계절도 건강하게 보내세요!',
  ],
};

// 상황별 추천 감정 매핑 (백엔드에서 AI 판단 시 참고용)
const Map<SherpiContext, SherpiEmotion> contextEmotionMap = {
  // 기본 상호작용
  SherpiContext.welcome: SherpiEmotion.happy,
  SherpiContext.dailyGreeting: SherpiEmotion.defaults,
  SherpiContext.longTimeNoSee: SherpiEmotion.happy,
  SherpiContext.general: SherpiEmotion.defaults,

  // 성장 관련
  SherpiContext.levelUp: SherpiEmotion.cheering,
  SherpiContext.statIncrease: SherpiEmotion.happy,
  SherpiContext.badgeEarned: SherpiEmotion.cheering,
  SherpiContext.titleEarned: SherpiEmotion.special,

  // 등반 관련
  SherpiContext.climbingStart: SherpiEmotion.cheering,
  SherpiContext.climbingSuccess: SherpiEmotion.happy,
  SherpiContext.climbingFailure: SherpiEmotion.sad,
  SherpiContext.questComplete: SherpiEmotion.cheering,
  SherpiContext.firstClimb: SherpiEmotion.special,

  // 일상 기록 관련
  SherpiContext.exerciseComplete: SherpiEmotion.happy,
  SherpiContext.studyComplete: SherpiEmotion.thinking,
  SherpiContext.diaryWritten: SherpiEmotion.defaults,
  SherpiContext.focusComplete: SherpiEmotion.thinking,

  // 경고 및 안내
  SherpiContext.tiredWarning: SherpiEmotion.warning,
  SherpiContext.encouragement: SherpiEmotion.cheering,
  SherpiContext.guidance: SherpiEmotion.guiding,
  SherpiContext.tutorial: SherpiEmotion.guiding,

  // 커뮤니티 관련
  SherpiContext.meetingJoined: SherpiEmotion.happy,
  SherpiContext.friendActivity: SherpiEmotion.defaults,
  SherpiContext.guildRankUp: SherpiEmotion.cheering,

  // 특별 이벤트
  SherpiContext.specialEvent: SherpiEmotion.special,
  SherpiContext.achievement: SherpiEmotion.cheering,
  SherpiContext.milestone: SherpiEmotion.special,
  SherpiContext.seasonalGreeting: SherpiEmotion.defaults,
};

// 백엔드 연동을 위한 대화 소스 인터페이스
abstract class SherpiDialogueSource {
  Future<String> getDialogue(
      SherpiContext context,
      Map<String, dynamic>? userContext,
      Map<String, dynamic>? gameContext,
      );
}

// 현재 정적 데이터 소스 (백엔드 API 준비 전까지 사용)
class StaticDialogueSource implements SherpiDialogueSource {
  @override
  Future<String> getDialogue(
      SherpiContext context,
      Map<String, dynamic>? userContext,
      Map<String, dynamic>? gameContext,
      ) async {
    final dialogues = sherpiDialogues[context] ?? ['안녕하세요!'];
    final randomIndex = Random().nextInt(dialogues.length);
    return dialogues[randomIndex];
  }
}

// 백엔드 API 기반 대화 소스 (추후 구현)
class BackendDialogueSource implements SherpiDialogueSource {
  final String baseUrl;

  BackendDialogueSource({required this.baseUrl});

  @override
  Future<String> getDialogue(
      SherpiContext context,
      Map<String, dynamic>? userContext,
      Map<String, dynamic>? gameContext,
      ) async {
    // TODO: 백엔드 API 호출
    // POST /api/sherpi/dialogue
    // Body: { context, userContext, gameContext }
    // Response: { dialogue, emotion, metadata }
    throw UnimplementedError('백엔드 API 연동 준비 중입니다.');
  }
}

// AI 기반 대화 소스 (최종 목표)
class AIDialogueSource implements SherpiDialogueSource {
  final String apiKey;
  final String model;

  AIDialogueSource({required this.apiKey, this.model = 'gpt-4'});

  @override
  Future<String> getDialogue(
      SherpiContext context,
      Map<String, dynamic>? userContext,
      Map<String, dynamic>? gameContext,
      ) async {
    // TODO: OpenAI API 호출
    // 사용자 컨텍스트와 게임 상황을 고려한 개인화된 대사 생성
    throw UnimplementedError('AI 대화 시스템은 추후 구현 예정입니다.');
  }
}

// 유틸리티 함수들
class SherpiDialogueUtils {
  // 감정에 따른 이미지 경로 반환
  static String getImagePath(SherpiEmotion emotion) {
    return 'assets/images/sherpi/sherpi_${emotion.name}.png';
  }

  // 상황에 따른 추천 감정 반환
  static SherpiEmotion getRecommendedEmotion(SherpiContext context) {
    return contextEmotionMap[context] ?? SherpiEmotion.defaults;
  }

  // 백엔드 API용 컨텍스트 데이터 생성
  static Map<String, dynamic> createContextData({
    required SherpiContext context,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? gameData,
  }) {
    return {
      'context': context.name,
      'timestamp': DateTime.now().toIso8601String(),
      'user': userData ?? {},
      'game': gameData ?? {},
      'recommendedEmotion': getRecommendedEmotion(context).name,
    };
  }
}
