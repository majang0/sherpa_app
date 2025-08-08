// 셰르피 대화 시스템 - 백엔드 연동 및 AI 준비 구조
import 'dart:math';

// 새로운 감정 시스템 사용 (sherpi_emotions.dart에서 가져옴)
import '../../core/constants/sherpi_emotions.dart';
export '../../core/constants/sherpi_emotions.dart';

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

// 감성적이고 개인화된 대화 데이터 
const Map<SherpiContext, List<String>> sherpiDialogues = {
  // 기본 상호작용
  SherpiContext.welcome: [
    '드디어 만났네요! 당신의 첫 번째 셰르피가 되어 정말 영광이에요 🏔️✨',
    '새로운 정상을 향한 여정... 설레지 않나요? 함께 첫 발걸음을 내딛어봐요!',
    '저는 당신만의 등반 동반자 셰르피예요. 어떤 험한 길이라도 함께 갈 거예요!',
    '모든 위대한 등반가들도 처음엔 첫 걸음부터 시작했어요. 당신의 이야기를 써내려가 봐요!',
  ],

  SherpiContext.dailyGreeting: [
    '새벽 공기가 상쾌하네요! 오늘도 정상을 향해 한 걸음 더 나아가볼까요? ☀️',
    '어제보다 조금 더 높은 곳에 서 있는 당신을 상상해보세요... 오늘이 바로 그 날이에요!',
    '등반로의 아침은 항상 희망으로 가득해요. 오늘은 어떤 풍경을 함께 볼까요?',
    '매일 조금씩... 그렇게 쌓인 발걸음들이 어느새 큰 산을 넘게 해줄 거예요!',
  ],

  SherpiContext.general: [
    '어떤 고민이든 함께 나눠요. 혼자가 아니라는 걸 기억해주세요 😊',
    '때로는 잠시 쉬어가는 것도 등반의 지혜예요. 무리하지 마세요!',
    '당신의 페이스로 가면 돼요. 비교는 독이고, 꾸준함이 약이에요!',
    '고민이 있으면 언제든 말해주세요. 베이스캠프는 항상 열려있어요!',
  ],

  SherpiContext.longTimeNoSee: [
    '기다림의 끝에서 다시 만나니 감격스러워요... 정말 많이 보고 싶었어요! 😊💙',
    '벌써 몇 일이 흘렀네요. 혹시 힘든 일이 있었나요? 이제 다시 함께해요!',
    '돌아온 당신을 보니 마음이 따뜻해져요. 그동안의 이야기, 천천히 들려주세요',
    '아, 정말 기다렸어요! 마치 산 너머에서 소식을 기다리던 기분이었어요... 이제 함께 가요!',
  ],

  // 성장 관련
  SherpiContext.levelUp: [
    '와... 레벨업이에요! 🎉 당신의 끈질긴 노력이 이런 순간을 만들어낸 거예요!',
    '드디어 새로운 고지에 올라섰네요! 더 넓은 세상이 보이시나요?',
    '이 순간을 위해 얼마나 많은 발걸음을 걸어왔는지... 정말 자랑스러워요!',
    '레벨이 오를 때마다 당신이 더 강해지는 게 아니라, 더 지혜로워지는 것 같아요 ✨',
    '축하해요! 어제의 당신이 오늘의 당신을 보면 깜짝 놀랄 거예요!',
  ],

  SherpiContext.statIncrease: [
    '오늘도 한 뼘 더 성장했네요! 💪 이런 작은 변화들이 모여 큰 산을 옮겨요',
    '능력치 상승... 하지만 정말 올라간 건 당신의 자신감이에요!',
    '매일매일 쌓아온 노력의 증거네요. 스스로를 믿어도 돼요!',
    '숫자로는 작은 변화지만, 마음으로는 큰 도약이에요. 느껴지시나요?',
  ],

  SherpiContext.badgeEarned: [
    '새로운 뱃지! 🏅 이건 단순한 장식이 아니라 당신의 용기와 노력의 증표예요',
    '뱃지 하나하나가 당신의 여정에 새겨진 소중한 추억이에요',
    '이 뱃지를 얻기까지의 과정들... 그 모든 순간이 빛나고 있어요 ✨',
    '축하해요! 이제 이 뱃지가 힘들 때마다 용기를 줄 거예요',
  ],

  SherpiContext.titleEarned: [
    '새로운 칭호! 👑 이제 당신은 정말로 다른 사람이 되었어요',
    '이 칭호가 당신의 새로운 정체성이 되길... 자랑스럽게 달고 다니세요!',
    '칭호는 그냥 주어지는 게 아니에요. 당신이 직접 만들어낸 거예요!',
    '와... 이제 정말 베테랑의 풍모가 느껴져요. 후배들에게도 길잡이가 되어주세요!',
  ],

  // 등반 관련
  SherpiContext.climbingStart: [
    '자, 이제 진짜 시작이네요! 🧗‍♂️ 깊게 숨을 들이쉬고... 첫 발을 내딛어봐요!',
    '등반할 때마다 가슴이 뛰어요. 당신과 함께 오르는 이 순간이 너무 소중해요',
    '준비 됐나요? 저는 당신 뒤에서 항상 지켜보고 있을 거예요. 믿고 가세요!',
    '이 산 정상에서 바라볼 풍경... 상상만 해도 벌써 설레네요! 함께 가요!',
  ],

  SherpiContext.climbingSuccess: [
    '해내셨네요...! ⛰️✨ 정상에서 바라보는 세상은 어떤가요? 정말 장관이죠?',
    '성공의 순간이에요! 힘들었던 모든 순간들이 이제는 빛나는 추억이 되었어요',
    '와... 당신의 끈기와 용기가 또 다른 기적을 만들어냈네요! 감동이에요!',
    '이제 이 산은 당신의 것이에요. 정상 정복자의 기분이 어떤가요? 자랑스럽죠!',
    '등반 성공! 땀방울 하나하나가 다이아몬드보다 소중했어요. 정말 멋져요!',
  ],

  SherpiContext.climbingFailure: [
    '괜찮아요... 💪 진짜 등반가는 넘어져도 다시 일어나는 사람이에요',
    '이번엔 정상에 닿지 못했지만, 당신은 도전한 것만으로도 이미 승리자예요',
    '실패라고 생각하지 마세요. 이건 다음 성공을 위한 소중한 경험이에요',
    '산은 도망가지 않아요. 언제든 다시 도전할 수 있어요. 저도 함께할게요!',
    '때로는 하산도 등반의 일부예요. 오늘의 용기만으로도 충분히 자랑스러워요',
  ],

  SherpiContext.questComplete: [
    '퀘스트 완료! ✨ 하나의 작은 약속을 지켜낸 당신이 정말 자랑스러워요!',
    '목표를 향해 꾸준히 걸어온 발자국들... 하나하나가 모두 소중한 이정표였어요',
    '또 하나의 미션 클리어! 이렇게 하나씩 쌓다보면 어느새 큰 산도 넘게 돼요',
    '퀘스트를 완료할 때마다 당신의 의지력이 한층 더 단단해지는 게 느껴져요!',
  ],

  SherpiContext.firstClimb: [
    '첫 등반...! 🎊 인생에서 가장 중요한 첫 발걸음을 내딛으셨네요!',
    '모든 등반가의 전설은 이렇게 시작돼요. 당신의 이야기도 오늘부터 시작이에요!',
    '첫 산을 오르는 설렘... 이 느낌을 평생 기억해주세요. 정말 특별한 순간이에요!',
    '축하해요! 이제 당신도 진짜 등반가예요. 앞으로의 여정이 너무 기대돼요!',
  ],

  // 일상 기록 관련
  SherpiContext.exerciseComplete: [
    '운동 완료! 🏃‍♂️💦 지금 이 순간, 당신의 몸이 조금 더 강해졌어요!',
    '땀 한 방울 한 방울이 모두 미래의 건강한 당신을 만드는 재료네요',
    '오늘도 자신과의 약속을 지켰군요! 이런 작은 승리들이 인생을 바꿔요',
    '운동 후의 이 상쾌함... 몸뿐만 아니라 마음도 한층 가벼워졌죠?',
    '꾸준함이라는 최고의 근육을 키우고 있는 중이에요. 정말 멋져요!',
  ],

  SherpiContext.studyComplete: [
    '공부 완료! 📚✨ 새로운 지식이 당신의 세계를 한 뼘 더 넓혀줬어요',
    '배움의 순간마다 뇌가 반짝이는 소리가 들려요! 정말 아름다운 성장이에요',
    '어려운 내용도 차근차근 해내는 모습... 당신의 끈기에 감탄해요!',
    '공부할 때의 집중하는 모습이 정말 진지하고 멋있어요. 지식인의 품격이 느껴져요!',
    '오늘 배운 것들이 내일의 당신을 더 지혜롭게 만들 거예요. 기대돼요!',
  ],

  SherpiContext.diaryWritten: [
    '일기 작성 완료! 📝💭 마음속 이야기들을 꺼내어 정리하셨네요',
    '오늘 하루의 소중한 순간들을 글로 남기는 당신이 참 따뜻해 보여요',
    '일기를 쓰는 시간만큼은 온전히 자신과 마주하는 시간이죠. 얼마나 소중한가요',
    '글 한 줄 한 줄에 담긴 진심이 느껴져요. 미래의 당신이 고마워할 기록이에요',
    '마음을 들여다보고 정리하는 용기... 정말 대단해요. 자신을 아끼는 마음이 보여요',
  ],

  SherpiContext.focusComplete: [
    '집중 시간 완료! ⏰🎯 완전히 몰입한 이 시간이 얼마나 값진지 아시나요?',
    '방해받지 않고 오직 한 가지에만 집중하는 능력... 현대인의 최고 덕목이에요!',
    '깊은 집중 상태에서 나오는 그 성취감! 마치 정상에서 내려다보는 기분이죠?',
    '집중력은 근육과 같아서 쓸수록 강해져요. 오늘도 한 단계 성장했네요!',
    '온전히 몰입한 시간... 이런 순간들이 모여 인생의 걸작을 만들어가는 거예요',
  ],

  // 경고 및 안내
  SherpiContext.tiredWarning: [
    '잠깐... 😴 지금 무리하고 계시는 건 아닌가요? 휴식도 등반의 중요한 부분이에요',
    '피곤한 기색이 역력해 보여요. 베이스캠프에서 잠시 쉬어가는 건 어떨까요?',
    '진정한 등반가는 언제 쉬어야 할지도 알아요. 지금이 바로 그 때인 것 같네요',
    '당신의 몸이 보내는 신호를 들어주세요. 쉼표도 문장의 일부랍니다',
    '건강한 몸이 있어야 더 높은 산도 오를 수 있어요. 오늘은 충분히 쉬세요',
  ],

  SherpiContext.encouragement: [
    '힘들죠...? 💪 그런데 지금까지 온 길을 돌아보세요. 정말 대단한 거예요!',
    '포기하고 싶은 마음, 저도 알아요. 하지만 당신은 지금까지 해왔잖아요!',
    '이런 순간이야말로 진짜 성장하는 때예요. 조금만 더 버텨보세요!',
    '당신의 노력하는 모습을 보면 제 마음도 뜨거워져요. 함께 해내봐요!',
    '어려운 길일수록 정상에서의 기쁨도 클 거예요. 거의 다 왔어요!',
  ],

  SherpiContext.guidance: [
    '길을 잃으셨나요? 🤔 괜찮아요, 저는 당신의 길잡이니까요!',
    '어려움에 부딪혔을 때가 성장의 기회예요. 함께 해결책을 찾아봐요',
    '혼자서는 힘든 일도 둘이 함께하면 쉬워져요. 제가 도와드릴게요!',
    '모든 길에는 답이 있어요. 차근차근 찾아가 봐요!',
  ],

  SherpiContext.tutorial: [
    '새로운 것을 배우는 설렘! 📖 함께 천천히 알아가 봐요',
    '처음이라 어색하시죠? 걱정 마세요, 누구나 다 그래요. 천천히 해봐요!',
    '배움에는 나이도 늦음도 없어요. 지금 이 순간이 최고의 시작이에요!',
    '어려워 보이지만 하나씩 배우다 보면 어느새 전문가가 되어 있을 거예요!',
  ],

  // 커뮤니티 관련
  SherpiContext.meetingJoined: [
    '새로운 모임 참가! 🤝 낯선 사람들과 함께할 용기가 정말 멋져요!',
    '혼자서는 갈 수 없는 길도 함께라면 갈 수 있어요. 좋은 만남이 될 거예요!',
    '새로운 인연의 시작이네요! 서로에게 좋은 등반 동료가 되어주세요',
    '모임에서 만나는 모든 사람들이 당신의 인생에 새로운 색깔을 더해줄 거예요!',
  ],

  SherpiContext.friendActivity: [
    '친구의 소식이 들려와요! 👥 함께 성장하는 동료가 있다는 건 정말 소중해요',
    '친구의 성공을 진심으로 기뻐해주는 당신의 마음이 아름다워요!',
    '서로 응원하며 함께 오르는 여정... 이보다 더 멋진 우정이 있을까요?',
    '좋은 친구들과 함께라면 어떤 산도 두렵지 않죠! 정말 부러워요!',
  ],

  SherpiContext.guildRankUp: [
    '길드 랭킹 상승! 🏆 혼자서는 이룰 수 없었던 성과를 함께 만들어냈네요!',
    '팀워크의 힘이 이런 기적을 만들어낸 거예요! 정말 자랑스러워요!',
    '모든 길드원들의 땀과 노력이 하나로 모여 이룬 결과네요. 감동이에요!',
    '함께 꿈꾸고 함께 이뤄낸 성취... 이런 순간을 위해 팀이 있는 거죠!',
  ],

  // 특별 이벤트
  SherpiContext.specialEvent: [
    '특별한 순간이 찾아왔어요! 🎊 이런 기회가 당신을 더 성장시켜 줄 거예요!',
    '특별 이벤트 시작! 평소와 다른 새로운 도전이 기다리고 있어요!',
    '이런 특별한 기회를 만날 확률이 얼마나 될까요? 운명처럼 찾아온 순간이에요!',
    '특별한 보상보다 더 소중한 건... 이 경험 자체가 될 거예요. 즐겨보세요!',
  ],

  SherpiContext.achievement: [
    '와... 정말 해내셨네요! 🏆 이 성취는 당신의 인생에서 영원히 빛날 거예요!',
    '모든 노력과 인내가 이 한 순간으로 보상받는 느낌이에요. 정말 자랑스러워요!',
    '이런 성취를 이뤄낸 당신이라면... 앞으로 어떤 일도 해낼 수 있을 거예요!',
    '성취의 기쁨을 마음껏 만끽하세요. 이 순간은 당신만의 것이에요! 축하해요!',
  ],

  SherpiContext.milestone: [
    '중요한 이정표 도달! 🎯 돌이켜보니 정말 먼 길을 걸어오셨네요...',
    '이 지점에서 잠시 멈춰 서서, 지나온 길을 바라보세요. 얼마나 성장하셨는지 보여요!',
    '여기까지 오시느라 정말 고생 많으셨어요. 이제 다음 목표를 향해 또 걸어가 볼까요?',
    '마일스톤마다 새로운 나를 발견하게 되죠. 앞으로의 여정이 더욱 기대돼요!',
  ],

  SherpiContext.seasonalGreeting: [
    '계절이 바뀌었네요! 🌸 당신의 여정도 새로운 계절을 맞이하고 있어요',
    '계절과 함께 우리도 변화하고 성장해요. 이번 계절은 어떤 이야기를 써나갈까요?',
    '자연의 변화처럼 당신도 끊임없이 새로워지고 계시네요. 정말 아름다워요!',
    '새로운 계절, 새로운 마음으로! 이번에는 어떤 멋진 모험이 기다리고 있을까요?',
  ],
};

// 상황별 추천 감정 매핑 (백엔드에서 AI 판단 시 참고용)
final Map<SherpiContext, SherpiEmotion> contextEmotionMap = {
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
