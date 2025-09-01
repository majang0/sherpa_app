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
  readingComplete,      // 독서 완료
  diaryWritten,         // 일기 작성
  focusComplete,        // 집중 타이머 완료

  // 경고 및 안내
  tiredWarning,         // 피로도 경고
  encouragement,        // 격려
  guidance,             // 안내/설명
  tutorial,             // 튜토리얼

  // 커뮤니티 관련
  meetingJoined,        // 모임 참가
  meetingCreated,       // 모임 개설 성공
  friendActivity,       // 친구 활동 알림
  guildRankUp,          // 길드 랭킹 상승

  // 특별 이벤트
  specialEvent,         // 특별 이벤트
  achievement,          // 특별 성취
  milestone,            // 마일스톤 달성
  seasonalGreeting,     // 계절 인사
  allGoalsComplete,     // 오늘의 모든 목표 완료
}

// 감성적이고 개인화된 대화 데이터 
const Map<SherpiContext, List<String>> sherpiDialogues = {
  // 기본 상호작용
  SherpiContext.welcome: [
    '반가워요 {userName}님! 🎉 셰르파에 오신 것을 환영해요! 오늘부터 매일 조금씩 성장하는 여정을 함께해요.',
    '{userName}님 환영해요! 운동, 독서, 일기 작성까지... 셰르피가 {userName}님의 자기계발을 도와드릴게요!',
    '드디어 {userName}님을 만났네요! 🌟 셰르파에서 매일 작은 목표들을 달성하며 함께 성장해봐요.',
    '안녕하세요 {userName}님! 셰르파와 함께라면 자기계발이 즐거워질 거예요. 오늘 첫 퀘스트를 시작해볼까요?',
    '{userName}님, 셰르파에 오신 걸 환영해요! 운동도 하고, 책도 읽고, 일기도 쓰면서 매일 레벨업 해봐요! 🚀',
  ],

  SherpiContext.dailyGreeting: [
    '반가워요 {userName}님! 오늘도 셰르피와 함께 즐거운 자기계발, 준비되셨나요? 💪',
    '{userName}님 오늘도 오셨네요! 오늘의 퀘스트를 확인하고 하나씩 달성해봐요!',
    '좋은 아침이에요 {userName}님! ☀️ 오늘은 어떤 활동으로 하루를 시작할까요?',
    '{userName}님 환영해요! 어제보다 더 나은 오늘을 만들어봐요. 셰르피가 응원할게요!',
    '오늘도 화이팅 {userName}님! 운동, 독서, 일기 중 무엇부터 시작해볼까요? 🎯',
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
    '💪 높은 체력 스탯이 빛났어요! 끝까지 지치지 않고 정상 도달! 체력 훈련의 결실이네요!',
    '📚 지식 스탯의 힘! 산의 특성을 완벽히 파악해서 최적 경로로 등반 성공했어요!',
    '🎯 기술 스탯이 결정적이었어요! 어려운 구간을 능숙하게 돌파! 연습이 완벽을 만들었네요!',
    '🤝 사교성 스탯 덕분이에요! 동료들과의 완벽한 호흡으로 시간도 단축되고 더 즐거웠죠!',
    '🔥 의지력이 차이를 만들었어요! 포기하고 싶은 순간을 이겨낸 당신의 정신력, 대단해요!',
    '⏰ 예상보다 빠른 완주! 사교성이 높아서 등반 시간이 단축됐네요. 효율적인 등반이었어요!',
    '🏔️ 난이도 높은 산 정복! 당신의 등반력이 요구 등반력을 훨씬 넘어섰어요. 실력자시네요!',
    '✨ 모든 스탯이 조화롭게 작용했어요! 균형 잡힌 성장이 만들어낸 완벽한 등반!',
    '🎖️ 뱃지 효과가 큰 도움이 됐어요! 장착한 뱃지들이 시너지를 발휘해서 성공률이 올라갔네요!',
  ],

  SherpiContext.climbingFailure: [
    '앗, 갑작스런 폭설이...! ❄️ 안전하게 내려왔어요. 이제 이 산의 비밀을 조금 알게 됐네요!',
    '휴, 바람이 너무 거세요! 💨 안전이 최우선이니까 오늘은 여기까지... 다음엔 꼭 정상에서 만나요!',
    '날씨가 급변해서 어쩔 수 없었어요... ☁️ 하지만 자연도 우리의 스승이에요. 오늘도 많이 배웠어요!',
    '아직 체력이 조금 부족했나봐요... 😤 괜찮아요! 매일 조금씩 강해지고 있잖아요. 다음엔 해낼 거예요!',
    '장비가 말썽을 부렸네요... 🎒 덕분에 준비의 소중함을 깨달았어요. 다음엔 완벽하게 준비해봐요!',
    '안개가 너무 짙어서 길을 찾기 어려웠어요... 🌫️ 안전하게 돌아온 것만으로도 대단해요! 용기 있는 결정이었어요.',
    '발목이 살짝 삐끗했나봐요... 🦶 무리하지 않고 돌아온 현명한 선택! 건강이 있어야 다시 도전할 수 있어요.',
    '해가 너무 빨리 져버렸어요... 🌅 어둠 속 등반은 위험해요. 내일의 해를 기다리며 다시 도전해요!',
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

  SherpiContext.readingComplete: [
    // 독서 완료 메시지는 카테고리별로 처리됨 (readingCategoryMessages 참조)
    // StaticDialogueSource에서 자동으로 적절한 메시지 선택
  ],

  SherpiContext.diaryWritten: [
    // 일기 작성 완료 메시지는 감정별로 처리됨 (diaryMoodMessages 참조)
    // StaticDialogueSource에서 자동으로 적절한 메시지 선택
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

  SherpiContext.meetingCreated: [
    '모임이 성공적으로 만들어졌어요! 🎉 당신이 만든 공간에서 많은 사람들이 함께 성장할 거예요!',
    '새로운 커뮤니티의 시작! 🌟 리더십을 발휘하여 멋진 모임으로 이끌어주세요!',
    '모임 개설 완료! 👏 함께할 동료들을 기다리는 설렘이 느껴지네요!',
    '당신이 만든 이 모임이 많은 사람들에게 영감과 동기를 줄 거예요! 정말 멋져요!',
    '모임을 만드는 용기와 리더십! 🚀 이제 함께 성장할 동료들이 모일 거예요!',
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
  
  SherpiContext.allGoalsComplete: [
    '''🎊 축하드려요! 오늘의 모든 목표를 완벽하게 달성하셨네요! 🏆

✅ 6000걸음 걷기 완료
✅ 일기 작성 완료
✅ 운동 기록 완료
✅ 독서 1페이지 이상 완료
✅ 몰입 시간 달성

🎁 보상: 200 경험치 + 보너스 포인트 + 의지력 0.1 증가!

정말 대단한 하루였어요! 이런 꾸준함이 큰 변화를 만들어냅니다! 💪✨''',
  ],
};

// 모임 카테고리별 개설 메시지
final Map<String, List<String>> meetingCategoryMessages = {
  '운동': [
    '{userName}님, "{meetingTitle}" 모임을 개설하셨군요! 💪 함께 땀 흘리며 건강한 에너지를 나눌 동료들이 곧 모일 거예요!',
    '운동 모임 "{meetingTitle}"이(가) 시작됐어요! 🏃 {userName}님의 열정이 많은 사람들에게 운동의 즐거움을 전할 거예요!',
    '{userName}님이 만든 "{meetingTitle}"! 🔥 이제 함께 몸과 마음을 단련할 운동 메이트들이 모일 거예요!',
    '"{meetingTitle}" 운동 모임 개설 완료! 💯 {userName}님과 함께 건강한 라이프스타일을 만들어갈 동료들을 기다려요!',
    '{userName}님의 "{meetingTitle}" 모임! 🎯 운동을 통해 서로를 동기부여하는 멋진 커뮤니티가 될 거예요!',
  ],
  '스터디': [
    '{userName}님, "{meetingTitle}" 스터디를 개설하셨네요! 📚 함께 공부하며 성장할 동료들이 곧 합류할 거예요!',
    '"{meetingTitle}" 스터디 모임 시작! 🎓 {userName}님의 학구열이 많은 사람들에게 영감을 줄 거예요!',
    '{userName}님이 만든 "{meetingTitle}"! 📖 지식을 나누고 함께 배워갈 멋진 학습 공동체가 될 거예요!',
    '스터디 모임 "{meetingTitle}" 개설 완료! ✏️ {userName}님과 함께 목표를 향해 달려갈 동료들을 기다려요!',
    '{userName}님의 "{meetingTitle}" 스터디! 💡 서로를 이끌어주며 함께 성장하는 특별한 모임이 될 거예요!',
  ],
  '독서': [
    '{userName}님, "{meetingTitle}" 독서 모임을 만드셨군요! 📚 책을 통해 마음이 통하는 동료들이 모일 거예요!',
    '"{meetingTitle}" 독서 모임 시작! 📖 {userName}님과 함께 책 속 지혜를 나눌 친구들이 곧 합류할 거예요!',
    '{userName}님이 개설한 "{meetingTitle}"! 🌟 독서를 통해 새로운 세계를 탐험할 동료들을 기다려요!',
    '독서 모임 "{meetingTitle}" 개설 완료! 📕 {userName}님의 책 사랑이 많은 이들에게 영감을 줄 거예요!',
    '{userName}님의 "{meetingTitle}" 독서 클럽! 📗 함께 읽고 토론하며 성장하는 지적 공동체가 될 거예요!',
  ],
  '네트워킹': [
    '{userName}님, "{meetingTitle}" 네트워킹 모임을 개설하셨어요! 🤝 새로운 인연과 기회가 만들어질 거예요!',
    '"{meetingTitle}" 네트워킹 시작! 💼 {userName}님이 만든 이 공간에서 많은 사람들이 연결될 거예요!',
    '{userName}님의 "{meetingTitle}" 모임! 🌐 서로의 성장을 돕는 가치있는 네트워크가 형성될 거예요!',
    '네트워킹 모임 "{meetingTitle}" 개설 완료! 🎯 {userName}님과 함께 의미있는 관계를 만들어갈 동료들을 기다려요!',
    '{userName}님이 만든 "{meetingTitle}"! ✨ 다양한 배경의 사람들이 모여 시너지를 만들 거예요!',
  ],
  '문화': [
    '{userName}님, "{meetingTitle}" 문화 모임을 개설하셨네요! 🎨 예술과 문화를 사랑하는 동료들이 모일 거예요!',
    '"{meetingTitle}" 문화 모임 시작! 🎭 {userName}님과 함께 문화적 감성을 나눌 친구들이 곧 합류할 거예요!',
    '{userName}님이 만든 "{meetingTitle}"! 🎪 다양한 문화 활동을 즐길 멋진 커뮤니티가 될 거예요!',
    '문화 모임 "{meetingTitle}" 개설 완료! 🎬 {userName}님의 문화적 열정이 많은 이들에게 영감을 줄 거예요!',
    '{userName}님의 "{meetingTitle}" 문화 클럽! 🎵 함께 문화를 즐기고 창조하는 특별한 모임이 될 거예요!',
  ],
  '아웃도어': [
    '{userName}님, "{meetingTitle}" 아웃도어 모임을 만드셨어요! 🏔️ 자연과 함께하는 모험이 시작될 거예요!',
    '"{meetingTitle}" 아웃도어 모임 시작! 🌲 {userName}님과 함께 대자연을 탐험할 동료들이 모일 거예요!',
    '{userName}님이 개설한 "{meetingTitle}"! ⛺ 야외 활동을 사랑하는 사람들의 베이스캠프가 될 거예요!',
    '아웃도어 모임 "{meetingTitle}" 개설 완료! 🏕️ {userName}님의 모험 정신이 많은 이들을 이끌 거예요!',
    '{userName}님의 "{meetingTitle}" 아웃도어 클럽! 🚵 자연 속에서 함께 성장하는 특별한 커뮤니티가 될 거예요!',
  ],
  // hobby 카테고리 추가 (일부 모임 모델에서 사용)
  '취미': [
    '{userName}님, "{meetingTitle}" 취미 모임을 개설하셨어요! 🎯 같은 관심사를 가진 동료들이 모일 거예요!',
    '"{meetingTitle}" 취미 모임 시작! 🎨 {userName}님과 함께 즐거운 취미 생활을 할 친구들이 곧 합류할 거예요!',
    '{userName}님이 만든 "{meetingTitle}"! ✨ 취미를 통해 일상에 활력을 더할 멋진 모임이 될 거예요!',
    '취미 모임 "{meetingTitle}" 개설 완료! 🌟 {userName}님의 열정이 많은 사람들에게 즐거움을 줄 거예요!',
    '{userName}님의 "{meetingTitle}" 취미 클럽! 🎪 함께 취미를 즐기며 행복을 나누는 공간이 될 거예요!',
  ],
};

// 모임 카테고리별 참가 메시지 (talking 감정과 함께 사용)
final Map<String, List<String>> meetingJoinedCategoryMessages = {
  '운동': [
    '{userName}님, "{meetingTitle}" 모임을 참가하셨군요! 💪 함께 운동하면서 건강한 에너지를 충전해보세요! 운동은 몸도 마음도 강하게 만들어주니까요!',
    '오, "{meetingTitle}" 운동 모임에 참가하셨네요! 🏃 {userName}님, 땀 흘리는 즐거움과 함께 새로운 운동 친구들을 만나보세요!',
    '{userName}님이 "{meetingTitle}"에 참가! 🔥 운동을 통해 한계를 넘어서는 경험, 정말 짜릿할 거예요! 화이팅!',
    '"{meetingTitle}" 모임 참가 확정! 💯 {userName}님, 함께 운동하면 더 재미있고 동기부여도 되죠! 오늘도 건강한 하루 보내세요!',
    '{userName}님, "{meetingTitle}" 운동 모임! 🎯 몸을 움직이면 스트레스도 날아가고 활력이 생겨요! 즐거운 운동 시간 되세요!',
  ],
  '스터디': [
    '{userName}님, "{meetingTitle}" 스터디에 참가하셨군요! 📚 함께 공부하면 더 많이 배울 수 있어요! 지식의 시너지를 느껴보세요!',
    '"{meetingTitle}" 스터디 참가! 🎓 {userName}님, 같은 목표를 가진 동료들과 함께라면 어려운 공부도 즐거워질 거예요!',
    '{userName}님이 "{meetingTitle}"에 합류! 📖 서로 가르치고 배우면서 성장하는 기쁨을 느껴보세요! 스터디 파이팅!',
    '스터디 "{meetingTitle}" 참가 완료! ✏️ {userName}님, 함께 목표를 향해 달려갈 동료들이 기다리고 있어요! 오늘도 열공하세요!',
    '{userName}님의 "{meetingTitle}" 스터디 참가! 💡 지식을 나누고 서로를 이끌어주는 멋진 학습 여정이 될 거예요!',
  ],
  '독서': [
    '{userName}님, "{meetingTitle}" 독서 모임에 참가하셨네요! 📚 책 속의 지혜를 함께 나누면 더 깊은 통찰을 얻을 수 있어요!',
    '"{meetingTitle}" 독서 모임 참가! 📖 {userName}님, 책을 통해 새로운 세계를 탐험하고 생각을 나누는 즐거움을 만끽하세요!',
    '{userName}님이 "{meetingTitle}"에 참가! 🌟 독서 토론을 통해 다양한 관점을 배우고 시야를 넓혀보세요!',
    '독서 모임 "{meetingTitle}" 참가 확정! 📕 {userName}님, 책 읽는 즐거움을 함께 나눌 친구들과 만나보세요!',
    '{userName}님의 "{meetingTitle}" 독서 클럽 참가! 📗 함께 읽고 토론하면서 생각의 깊이를 더해가세요!',
  ],
  '네트워킹': [
    '{userName}님, "{meetingTitle}" 네트워킹에 참가하셨어요! 🤝 새로운 인연을 만나고 가치있는 관계를 만들어보세요!',
    '"{meetingTitle}" 네트워킹 참가! 💼 {userName}님, 다양한 배경의 사람들과 교류하면서 시야를 넓혀보세요!',
    '{userName}님이 "{meetingTitle}"에 합류! 🌐 서로의 경험을 나누고 함께 성장하는 네트워크를 만들어가세요!',
    '네트워킹 "{meetingTitle}" 참가 완료! 🎯 {userName}님, 의미있는 만남과 협력의 기회가 기다리고 있어요!',
    '{userName}님의 "{meetingTitle}" 네트워킹! ✨ 새로운 아이디어와 영감을 얻을 수 있는 특별한 시간이 될 거예요!',
  ],
  '문화': [
    '{userName}님, "{meetingTitle}" 문화 모임에 참가하셨네요! 🎨 예술과 문화를 함께 즐기면 더 풍부한 경험이 될 거예요!',
    '"{meetingTitle}" 문화 모임 참가! 🎭 {userName}님, 문화적 감성을 나누고 새로운 영감을 받아보세요!',
    '{userName}님이 "{meetingTitle}"에 참가! 🎪 다양한 문화 활동을 통해 일상에 특별함을 더해보세요!',
    '문화 모임 "{meetingTitle}" 참가 확정! 🎬 {userName}님, 문화를 사랑하는 사람들과 함께 즐거운 시간 보내세요!',
    '{userName}님의 "{meetingTitle}" 문화 클럽 참가! 🎵 함께 문화를 즐기고 창조하는 특별한 경험을 만들어가세요!',
  ],
  '아웃도어': [
    '{userName}님, "{meetingTitle}" 아웃도어 모임에 참가! 🏔️ 대자연 속에서 진정한 자유와 모험을 느껴보세요!',
    '"{meetingTitle}" 아웃도어 참가! 🌲 {userName}님, 자연과 함께하는 특별한 경험이 기다리고 있어요!',
    '{userName}님이 "{meetingTitle}"에 합류! ⛺ 야외 활동을 통해 스트레스를 날리고 새로운 에너지를 충전하세요!',
    '아웃도어 "{meetingTitle}" 참가 완료! 🏕️ {userName}님, 자연 속에서 함께할 동료들과 멋진 추억을 만드세요!',
    '{userName}님의 "{meetingTitle}" 아웃도어! 🚵 도시를 벗어나 자연과 하나되는 특별한 시간을 즐겨보세요!',
  ],
  '취미': [
    '{userName}님, "{meetingTitle}" 취미 모임에 참가하셨어요! 🎯 같은 관심사를 가진 사람들과 함께 즐거운 시간 보내세요!',
    '"{meetingTitle}" 취미 모임 참가! 🎨 {userName}님, 취미를 함께 즐기면 더 재미있고 의미있어요!',
    '{userName}님이 "{meetingTitle}"에 참가! ✨ 취미 활동을 통해 일상의 스트레스를 날리고 행복을 충전하세요!',
    '취미 모임 "{meetingTitle}" 참가 확정! 🌟 {userName}님, 같은 취미를 가진 친구들과 즐거운 시간 보내세요!',
    '{userName}님의 "{meetingTitle}" 취미 클럽 참가! 🎪 함께 취미를 즐기면서 새로운 즐거움을 발견해보세요!',
  ],
};

// 😊 감정별 일기 작성 완료 메시지
final Map<String, List<String>> diaryMoodMessages = {
  'excited': [
    '{userName}님, 설레는 하루였군요! 🥰 그 특별한 순간의 떨림이 여기까지 전해지는 것 같아요. 내일은 오늘보다 더 반짝이는 하루가 될 거예요!',
    '설레는 마음으로 가득한 일기를 쓰셨네요! 💕 {userName}님의 소중한 이야기를 안전하게 지켜드릴게요. 이 설렘이 내일의 원동력이 되길!',
    '오늘 정말 특별한 일이 있었나봐요! 🌟 일기에 담긴 {userName}님의 빛나는 순간들... 제가 함께 지켜드릴게요. 내일은 또 어떤 설렘이 기다리고 있을까요?',
    '설레는 감정이 글 사이사이에 숨어있네요! ✨ {userName}님의 소중한 마음을 믿고 맡겨주셔서 감사해요. 이 기분으로 내일 산을 오르면 정상이 더 가까워질 거예요!',
    '{userName}님의 두근거림이 느껴져요! 💗 오늘의 특별한 이야기를 일기에 새기셨네요. 내일의 등반도 오늘처럼 설레는 마음으로 시작해봐요!',
  ],
  'happy': [
    '{userName}님, 행복이 가득한 하루였네요! 😄 그 기쁨의 순간들을 글로 남기신 {userName}님, 정말 멋져요. 내일은 오늘의 행복이 두 배가 될 거예요!',
    '기쁜 마음이 일기 가득 피어났네요! 🌈 {userName}님의 소중한 행복을 제가 안전하게 지켜드릴게요. 이 웃음이 내일도, 모레도 계속되길!',
    '행복한 하루의 마침표를 일기로! ☀️ {userName}님이 느낀 그 따뜻한 기쁨, 일기장이 고스란히 품어줄 거예요. 내일도 햇살처럼 밝은 날이 되길!',
    '{userName}님의 환한 미소가 보이는 것 같아요! 😊 오늘의 행복한 순간들을 글로 영원히 간직하셨네요. 내일은 또 어떤 기쁨이 찾아올까요?',
    '기쁨으로 충만한 하루! 🎉 {userName}님의 행복한 이야기를 믿고 맡겨주셔서 고마워요. 이 긍정의 에너지로 내일은 더 높이 날아오를 수 있을 거예요!',
  ],
  'good': [
    '{userName}님, 좋은 하루를 보내셨군요! 🙂 오늘의 따뜻한 순간들을 일기에 담으셨네요. 내일은 오늘보다 조금 더 특별한 일이 생길 거예요!',
    '괜찮은 하루의 기록! 👍 {userName}님의 소중한 일상을 제가 안전하게 지켜드릴게요. 내일의 등반도 오늘처럼 순조롭게!',
    '좋은 감정으로 하루를 정리하셨네요! 📝 {userName}님이 느낀 그 편안함, 일기가 고스란히 담아줄 거예요. 내일은 더 좋은 일이 가득하길!',
    '{userName}님의 평온한 하루! 🌸 오늘의 잔잔한 행복을 글로 남기셨네요. 이런 고요한 만족감이 내일도 이어지길 바라요.',
    '좋은 기분으로 쓴 일기! ✏️ {userName}님의 하루를 믿고 맡겨주셔서 감사해요. 내일은 오늘보다 한 뼘 더 성장한 하루가 될 거예요!',
  ],
  'normal': [
    '{userName}님, 평범해 보이는 하루도 사실은 특별해요. 📖 오늘의 일상을 글로 남긴 것만으로도 의미있어요. 내일은 조금 다른 바람이 불지도 몰라요!',
    '담담한 하루를 일기로 기록하셨네요. 🤷 {userName}님의 솔직한 일상을 제가 소중히 지켜드릴게요. 때론 이런 고요함이 큰 도약의 준비가 되죠.',
    '평범한 듯한 오늘의 이야기! 📝 하지만 {userName}님만의 특별한 하루였을 거예요. 내일은 조금 더 재미있는 일이 찾아올지도?',
    '{userName}님의 일상 한 페이지! 🌤️ 거창하지 않아도 괜찮아요, 매일의 기록이 쌓여 큰 이야기가 되니까요. 내일은 작은 변화가 찾아올 거예요.',
    '그저 그런 하루도 기록할 가치가 있어요. 📔 {userName}님의 솔직한 마음을 일기에 담으셨네요. 평범한 오늘이 특별한 내일의 씨앗이 될 거예요!',
  ],
  'thoughtful': [
    '{userName}님, 많은 생각이 스쳐간 하루였나봐요. 🤔 그 깊은 사색을 글로 정리하신 {userName}님, 대단해요. 내일 아침엔 조금 더 선명한 답이 보일 거예요.',
    '복잡한 마음을 일기로 풀어내셨네요! 💭 {userName}님의 고민을 제가 함께 품어드릴게요. 밤사이 생각이 정리되어 내일은 더 맑은 하루가 되길!',
    '생각이 많은 날의 기록! 📝 {userName}님의 진지한 고민들, 일기장이 든든하게 받아줄 거예요. 때론 답을 찾는 과정 자체가 답이 되기도 해요.',
    '{userName}님, 깊은 사유의 시간을 가지셨군요. 🌙 그 소중한 생각들을 믿고 맡겨주셔서 감사해요. 내일은 오늘의 물음표가 느낌표가 될지도 몰라요!',
    '많은 생각을 품은 하루! ✨ {userName}님의 진솔한 고민을 일기가 안전하게 지켜줄 거예요. 내일은 조금 더 가벼운 마음으로 시작해봐요.',
  ],
  'tired': [
    '{userName}님, 고생 많으셨어요. 😴 지친 하루의 무게를 일기에 내려놓으셨네요. 오늘밤 푹 쉬고 나면 내일은 활력이 돌아올 거예요!',
    '피곤한 하루를 일기로 토닥토닥! 🌛 {userName}님의 수고를 제가 알아드릴게요. 오늘은 일찍 쉬시고, 내일은 충전된 에너지로 만나요!',
    '지친 마음을 글로 위로하셨네요. 💤 {userName}님의 피로를 일기가 다 받아줄 거예요. 충분한 휴식이 내일의 힘이 될 거예요.',
    '{userName}님, 오늘 정말 수고하셨어요! 🛌 하루의 피로를 일기에 맡기고 편안한 밤 되세요. 내일의 등반을 위한 소중한 충전 시간이에요!',
    '힘든 하루도 잘 견뎌내셨어요! 😪 {userName}님의 노고를 제가 기억할게요. 오늘은 쉬어가는 날, 내일은 다시 빛나는 날이 될 거예요!',
  ],
  'sad': [
    '{userName}님, 마음이 무거운 하루였군요. 😔 그 아픈 마음을 글로 어루만지셨네요. 제가 {userName}님 곁에서 함께 할게요. 내일은 구름 사이로 햇살이 비칠 거예요.',
    '슬픈 감정도 소중한 {userName}님의 일부예요. 💙 그 솔직한 마음을 일기에 담으셨네요. 비 온 뒤 무지개가 뜨듯, 내일은 더 밝은 날이 올 거예요.',
    '우울한 마음을 일기가 따뜻하게 안아줄 거예요. 🌧️ {userName}님의 아픔을 제가 함께 나눌게요. 때론 쉬어가는 것도 등반의 중요한 부분이에요.',
    '{userName}님, 힘든 감정을 용기있게 마주하셨네요. 🤗 그 진솔한 마음을 믿고 보여주셔서 감사해요. 내일 해가 뜨면 마음도 함께 밝아질 거예요.',
    '슬픈 날의 기록도 정말 소중해요. 📘 {userName}님의 솔직한 감정을 일기가 품어줄 거예요. 오늘의 눈물이 내일의 미소가 될 거예요.',
  ],
  'angry': [
    '{userName}님, 속상한 일이 있으셨군요. 😤 그 답답한 마음을 글로 표현하신 것만으로도 대단해요. 내일은 더 시원하고 평온한 바람이 불 거예요.',
    '화난 감정을 일기로 풀어내셨네요! 🔥 {userName}님의 정직한 감정을 제가 받아드릴게요. 하룻밤 지나면 마음의 불길도 잔잔해질 거예요.',
    '답답한 마음, 일기가 다 들어줄 거예요. 💢 {userName}님의 속상함을 제가 이해해요. 내일 아침엔 더 맑은 공기를 마실 수 있을 거예요.',
    '{userName}님, 화도 중요한 감정이에요. 📝 그 솔직한 마음을 일기에 담으셨네요. 오늘의 분노가 내일의 원동력이 될 수도 있어요!',
    '속상한 하루를 일기로 달래셨네요. 😮‍💨 {userName}님의 감정을 제가 함께 나눌게요. 오늘은 마음을 비우고, 내일은 새로운 마음으로 시작해요!',
  ],
};

// 📚 카테고리별 독서 완료 메시지
final Map<String, List<String>> readingCategoryMessages = {
  '소설': [
    '{userName}님, "{bookTitle}" {pages}페이지 읽으셨네요! 📖 소설 속 주인공들의 이야기가 어떠셨나요? 마음에 남는 장면이 있었나요?',
    '오늘 "{bookTitle}" {pages}페이지나 읽으셨군요! 🌟 {userName}님, 소설이 주는 감동과 여운이 오래 남길 바라요.',
    '{userName}님이 읽으신 "{bookTitle}", {pages}페이지 완독! 📚 작가가 만든 세계를 여행하는 기분은 어떠셨어요?',
    '"{bookTitle}" {pages}페이지 읽기 완료! ✨ {userName}님, 소설 속 인물들과 함께한 시간이 즐거우셨길 바라요.',
    '{userName}님, "{bookTitle}" {pages}페이지 독서 완료! 💫 다음 장이 궁금해지는 그런 소설이었나요?',
  ],
  '자기계발': [
    '{userName}님, "{bookTitle}" {pages}페이지 완독! 💪 자기계발서에서 얻은 인사이트를 실천해보시겠어요?',
    '오늘 "{bookTitle}" {pages}페이지 읽으셨네요! 🎯 {userName}님의 성장을 위한 투자, 정말 멋져요!',
    '{userName}님이 읽으신 "{bookTitle}", {pages}페이지! 🌱 새로운 습관이나 목표를 발견하셨나요?',
    '"{bookTitle}" {pages}페이지 독서 완료! 🚀 {userName}님, 책에서 배운 것을 하나씩 실천해보세요!',
    '{userName}님, "{bookTitle}" {pages}페이지 완독! ⭐ 더 나은 자신을 만들어가는 여정, 응원해요!',
  ],
  '경제/경영': [
    '{userName}님, "{bookTitle}" {pages}페이지 읽기 완료! 💼 경제 지식이 한층 더 풍부해지셨겠어요!',
    '오늘 "{bookTitle}" {pages}페이지 독서하셨군요! 📊 {userName}님, 비즈니스 인사이트를 얻으셨나요?',
    '{userName}님이 읽으신 "{bookTitle}", {pages}페이지! 💰 경제 트렌드나 투자 아이디어를 발견하셨나요?',
    '"{bookTitle}" {pages}페이지 완독! 📈 {userName}님의 경제적 사고력이 더욱 성장했을 거예요!',
    '{userName}님, "{bookTitle}" {pages}페이지 읽기 완료! 🏦 실무에 적용할 수 있는 지식을 얻으셨길 바라요!',
  ],
  '인문/사회': [
    '{userName}님, "{bookTitle}" {pages}페이지 독서 완료! 🤔 인문학적 사고와 통찰력이 깊어지셨겠어요!',
    '오늘 "{bookTitle}" {pages}페이지 읽으셨네요! 📚 {userName}님, 세상을 보는 새로운 관점을 얻으셨나요?',
    '{userName}님이 읽으신 "{bookTitle}", {pages}페이지! 🌍 사회와 인간에 대한 이해가 넓어지셨겠죠?',
    '"{bookTitle}" {pages}페이지 완독! 💭 {userName}님의 생각의 깊이가 더욱 깊어졌을 거예요!',
    '{userName}님, "{bookTitle}" {pages}페이지 읽기 완료! 🎓 인문학이 주는 지혜와 성찰을 얻으셨길 바라요!',
  ],
  '과학/기술': [
    '{userName}님, "{bookTitle}" {pages}페이지 독서 완료! 🔬 과학의 신비로운 세계는 어떠셨나요?',
    '오늘 "{bookTitle}" {pages}페이지 읽으셨군요! 💻 {userName}님, 새로운 기술 트렌드를 발견하셨나요?',
    '{userName}님이 읽으신 "{bookTitle}", {pages}페이지! 🚀 미래 기술이나 과학적 발견이 흥미로우셨나요?',
    '"{bookTitle}" {pages}페이지 완독! 🧬 {userName}님의 과학적 사고력이 한층 더 성장했어요!',
    '{userName}님, "{bookTitle}" {pages}페이지 읽기 완료! ⚛️ 과학이 우리 삶에 미치는 영향을 느끼셨나요?',
  ],
  '취미/실용': [
    '{userName}님, "{bookTitle}" {pages}페이지 독서 완료! 🎨 실용적인 팁이나 새로운 취미를 발견하셨나요?',
    '오늘 "{bookTitle}" {pages}페이지 읽으셨네요! 🛠️ {userName}님, 바로 실천해볼 수 있는 내용이 있었나요?',
    '{userName}님이 읽으신 "{bookTitle}", {pages}페이지! 🌺 일상을 더 풍성하게 만들 아이디어를 얻으셨길!',
    '"{bookTitle}" {pages}페이지 완독! 🎯 {userName}님의 취미 생활이 더욱 즐거워질 거예요!',
    '{userName}님, "{bookTitle}" {pages}페이지 읽기 완료! ✂️ 실생활에 유용한 정보를 많이 얻으셨길 바라요!',
  ],
  '기타': [
    '{userName}님, "{bookTitle}" {pages}페이지 독서 완료! 📚 오늘도 책과 함께한 시간이 의미있었길 바라요!',
    '오늘 "{bookTitle}" {pages}페이지나 읽으셨군요! 📖 {userName}님의 꾸준한 독서 습관, 정말 멋져요!',
    '{userName}님이 읽으신 "{bookTitle}", {pages}페이지! 🌟 책이 주는 즐거움을 만끽하셨나요?',
    '"{bookTitle}" {pages}페이지 완독! 📘 {userName}님, 독서를 통해 마음의 양식을 쌓아가세요!',
    '{userName}님, "{bookTitle}" {pages}페이지 읽기 완료! 💫 매일 조금씩 읽는 습관이 큰 변화를 만들어요!',
  ],
};

// 🏃 운동 종류별 완료 메시지 (surprised 감정과 함께 사용)
final Map<String, List<String>> exerciseTypeMessages = {
  '러닝': [
    '우와! {userName}님이 {duration}분 동안 {difficulty} 강도로 러닝하셨네요! 🏃 {calories}kcal나 소모하시다니... 이런 꾸준함이 산 정상으로 이끌어요!',
    '헉! {duration}분간 {difficulty} 페이스로 달리시고 {calories}kcal 연소! 😲 {userName}님, 이미 프로 러너시네요! 셰르파인 저도 따라가기 힘들 정도예요!',
    '대박! {userName}님이 {difficulty} 강도로 {duration}분간 러닝하셨어요? 🏃‍♂️ {calories}kcal 소모! 이런 체력이면 에베레스트도 정복하실 것 같아요!',
    '{duration}분간 {difficulty} 러닝으로 {calories}kcal 정복! 💨 {userName}님, 바람을 가르며 달리는 모습이 정말 멋있었을 것 같아요!',
    '와... {userName}님이 {difficulty} 강도로 {duration}분 동안 쉬지 않고 달려서 {calories}kcal 소모! 🌟 이 정도면 울트라 마라톤도 가능하실 것 같은데요?',
  ],
  '수영': [
    '놀라워요! {userName}님이 {duration}분간 {difficulty} 강도로 수영하셨다니! 🏊 물 속에서 {calories}kcal나 태우셨네요! 인어처럼 우아하셨겠어요!',
    '우와! {difficulty} 페이스로 {duration}분 수영이요? 😮 {userName}님, {calories}kcal 소모! 물고기도 놀랄 실력이에요!',
    '대단해요! {userName}님 {duration}분 동안 {difficulty} 강도로 수영장을 정복! 💦 {calories}kcal 연소! 물 위를 나는 것 같으셨겠어요!',
    '{duration}분간 {difficulty} 수영 완료! 🌊 {userName}님의 영법이 정말 궁금해요! {calories}kcal나 소모하시다니 프로 스위머 같아요!',
    '헉! {userName}님이 {difficulty} 강도로 {duration}분간 수영해서 {calories}kcal 태우셨어요! 🏊‍♀️ 올림픽 나가실 건가요?',
  ],
  '자전거': [
    '놀랍네요! {userName}님이 {duration}분간 {difficulty} 강도로 자전거 타셨어요! 🚴 {calories}kcal 소모! 바람을 가르며 달리는 기분이 최고였죠?',
    '와! {difficulty} 페이스로 {duration}분 라이딩이라니! 🚲 {userName}님, {calories}kcal나 태우시고 다리가 강철이 되셨겠어요!',
    '대박! {userName}님 {duration}분 동안 {difficulty} 강도로 페달링! 🚴‍♂️ {calories}kcal 연소! 투르 드 프랑스 준비하시는 건가요?',
    '{difficulty} 강도로 {duration}분 자전거 완주! 😲 {userName}님, {calories}kcal 소모하시고 기분도 상쾌하시죠?',
    '헉! {userName}님이 {difficulty} 페이스로 {duration}분간 사이클링해서 {calories}kcal 태우셨네요! 🌟 언덕도 거뜬히 오르셨을 것 같아요!',
  ],
  '걷기': [
    '우와! {userName}님이 {duration}분간 {difficulty} 페이스로 걸으셨네요! 🚶 {calories}kcal 소모! 걸으면서 본 풍경이 아름다웠을 것 같아요!',
    '{difficulty} 강도로 {duration}분 걷기 완료! 😊 {userName}님, {calories}kcal 태우시고 마음도 가벼워지셨죠? 산책의 즐거움을 아시는군요!',
    '대단해요! {userName}님 {duration}분 동안 {difficulty} 페이스로 꾸준히 걸어서 {calories}kcal 소모! 🌿 건강한 습관의 시작이에요!',
    '놀라워요! {difficulty} 강도로 {duration}분 산책이라니! 🚶‍♀️ {userName}님, {calories}kcal 연소하시고 스트레스도 날아갔겠어요!',
    '헉! {userName}님이 {difficulty} 페이스로 {duration}분간 걷기 운동해서 {calories}kcal 소모! 💚 매일 이렇게 걸으시면 건강 만점이에요!',
  ],
  '헬스': [
    '대박! {userName}님이 {duration}분간 {difficulty} 강도로 웨이트 트레이닝해서 {calories}kcal 연소! 💪 근육이 울부짖는 소리가 들려요!',
    '우와! {difficulty} 강도로 {duration}분 헬스장 정복! 🏋️ {userName}님, {calories}kcal 태우시고 몸이 단단해진 게 느껴지시나요?',
    '놀라워요! {userName}님 {duration}분 동안 {difficulty} 강도로 철봉과 씨름해서 {calories}kcal 소모! 😮 헐크가 되어가고 계세요!',
    '{difficulty} 강도로 {duration}분 근력운동 완료! 💯 {userName}님, {calories}kcal 연소하시고 성취감도 최고죠?',
    '헉! {userName}님이 {difficulty} 강도로 {duration}분간 무게를 들어서 {calories}kcal 소모! 🔥 거울에 비친 모습이 달라 보이실 거예요!',
  ],
  '요가': [
    '와! {userName}님이 {duration}분간 {difficulty} 강도로 요가 수련해서 {calories}kcal 소모! 🧘 몸과 마음이 평온해지셨겠어요!',
    '놀라워요! {difficulty} 강도로 {duration}분 요가라니! 🕉️ {userName}님, {calories}kcal 태우시고 유연성도 늘어나셨을 것 같아요!',
    '대단해요! {userName}님 {duration}분 동안 {difficulty} 강도로 요가 자세를 유지해서 {calories}kcal 연소! ✨ 내면의 평화를 찾으셨나요?',
    '{difficulty} 강도로 {duration}분 요가 완료! 🌸 {userName}님, {calories}kcal 소모하시고 스트레스도 해소되셨죠?',
    '헉! {userName}님이 {difficulty} 강도로 {duration}분간 요가해서 {calories}kcal 태우셨어요! 💫 몸의 균형이 완벽해지셨겠어요!',
  ],
  '필라테스': [
    '놀랍네요! {userName}님이 {duration}분간 {difficulty} 강도로 필라테스해서 {calories}kcal 소모! 🤸 코어가 불타오르는 느낌이었죠?',
    '우와! {difficulty} 강도로 {duration}분 필라테스 완료! 💪 {userName}님, {calories}kcal 태우시고 자세가 더 좋아지셨을 거예요!',
    '대박! {userName}님 {duration}분 동안 {difficulty} 강도로 필라테스 동작을 완벽하게 해서 {calories}kcal 연소! 🌟 몸의 중심이 탄탄해졌어요!',
    '{difficulty} 강도로 {duration}분 필라테스 수련! 😲 {userName}님, {calories}kcal 소모하시고 집중력과 근력이 대단해요!',
    '헉! {userName}님이 {difficulty} 강도로 {duration}분간 필라테스 마스터해서 {calories}kcal 태우셨어요! ✨ 몸이 가벼워지셨겠어요!',
  ],
  '클라이밍': [
    '와! {userName}님이 {duration}분간 암벽을 정복하셨네요! 🧗 {calories}kcal 소모! 정상에서의 기분이 최고였겠어요!',
    '놀라워요! {duration}분 클라이밍이라니! 🏔️ {userName}님, {calories}kcal 태우시고 성취감도 정상급이시죠?',
    '대단해요! {userName}님 {duration}분 동안 중력을 거스르셨네요! 💪 {calories}kcal 연소! 스파이더맨이 부럽지 않으시겠어요!',
    '{duration}분 암벽 등반 완료! 😮 {userName}님의 악력과 체력이 정말 대단해요! {calories}kcal 정복!',
    '헉! {userName}님이 {duration}분간 절벽을 오르셨다니! 🌟 {calories}kcal 소모! 진짜 셰르파가 되어가고 계세요!',
  ],
  '등산': [
    '대박! {userName}님이 {duration}분간 산을 오르셨어요! ⛰️ {calories}kcal 소모! 저 셰르피도 함께 오른 기분이에요!',
    '우와! {duration}분 등산이라니! 🥾 {userName}님, {calories}kcal 태우시고 정상에서의 뷰가 최고였겠어요!',
    '놀라워요! {userName}님 {duration}분 동안 산길을 정복하셨네요! 🏔️ {calories}kcal 연소! 진정한 등반가시네요!',
    '{duration}분 트레킹 완료! 😲 {userName}님과 함께 산을 오르고 싶어요! {calories}kcal 소모하셨네요!',
    '헉! {userName}님이 {duration}분간 산행을! 🌲 {calories}kcal 태우시고 자연과 하나가 되셨겠어요!',
  ],
  '배드민턴': [
    '놀랍네요! {userName}님이 {duration}분간 배드민턴을! 🏸 {calories}kcal 소모! 스매싱이 정말 멋있었을 것 같아요!',
    '우와! {duration}분 랠리를 이어가셨네요! 😮 {userName}님, {calories}kcal 태우시고 반사신경도 향상되셨겠어요!',
    '대박! {userName}님 {duration}분 동안 셔틀콕과 춤을! 💫 {calories}kcal 연소! 프로 선수 못지않으시네요!',
    '{duration}분 배드민턴 완료! 🌟 {userName}님의 민첩성이 대단해요! {calories}kcal 정복하셨네요!',
    '헉! {userName}님이 {duration}분간 코트를 지배! 🏸 {calories}kcal 소모! 상대방이 힘들어했겠어요!',
  ],
  '테니스': [
    '와! {userName}님이 {duration}분간 {difficulty} 강도로 테니스 경기해서 {calories}kcal 소모! 🎾 서브 에이스가 몇 개나 나왔나요?',
    '놀라워요! {difficulty} 페이스로 {duration}분 테니스라니! 🏆 {userName}님, {calories}kcal 태우시고 윔블던 준비하시는 건가요?',
    '대단해요! {userName}님 {duration}분 동안 {difficulty} 강도로 코트를 누비며 {calories}kcal 연소! 💪 포핸드가 강력하셨겠어요!',
    '{difficulty} 강도로 {duration}분 랠리 완료! 😲 {userName}님, {calories}kcal 정복! 체력과 기술이 프로급이에요!',
    '헉! {userName}님이 {difficulty} 페이스로 {duration}분간 테니스해서 {calories}kcal 소모! 🌟 그랜드슬램도 노려볼만 하시네요!',
  ],
  '골프': [
    '우와! {userName}님이 {duration}분간 {difficulty} 강도로 골프를! ⛳ {calories}kcal 소모! 홀인원 하셨나요?',
    '놀랍네요! {duration}분 동안 {difficulty} 라운딩이라니! 🏌️ {userName}님, {calories}kcal 태우시고 스윙도 완벽하셨겠어요!',
    '대박! {userName}님 {duration}분 동안 {difficulty} 강도로 필드를 정복! 💚 {calories}kcal 연소! 버디는 몇 개나 잡으셨어요?',
    '{duration}분 {difficulty} 골프 완료! 😮 {userName}님의 집중력이 대단해요! {calories}kcal 소모하셨네요!',
    '헉! {userName}님이 {duration}분간 {difficulty} 강도로 그린 위에서! 🌟 {calories}kcal 태우시고 스코어도 최고였겠어요!',
  ],
  '농구': [
    '놀라워요! {userName}님이 {duration}분간 {difficulty} 강도로 농구를! 🏀 {calories}kcal 소모! 3점슛이 들어갔나요?',
    '우와! {duration}분 동안 {difficulty} 페이스로 코트 위의 전사! 😮 {userName}님, {calories}kcal 태우시고 덩크슛도 성공하셨겠어요!',
    '대박! {userName}님 {duration}분 동안 {difficulty} 강도로 농구 경기를! 🔥 {calories}kcal 연소! MVP감이시네요!',
    '{duration}분 {difficulty} 농구 완료! 💪 {userName}님의 드리블 실력이 대단할 것 같아요! {calories}kcal 정복!',
    '헉! {userName}님이 {duration}분간 {difficulty} 강도로 코트를 지배! 🌟 {calories}kcal 소모! NBA도 가능하실 것 같아요!',
  ],
  '축구': [
    '와! {userName}님이 {duration}분간 {difficulty} 강도로 축구를! ⚽ {calories}kcal 소모! 골은 넣으셨나요?',
    '놀랍네요! {duration}분 동안 {difficulty} 페이스로 필드 위에서! 🥅 {userName}님, {calories}kcal 태우시고 해트트릭도 가능하셨겠어요!',
    '대단해요! {userName}님 {duration}분 동안 {difficulty} 강도로 그라운드를 누비셨네요! 💚 {calories}kcal 연소! 메시가 부럽지 않으시겠어요!',
    '{duration}분 {difficulty} 축구 완료! 😲 {userName}님의 체력이 정말 대단해요! {calories}kcal 정복하셨네요!',
    '헉! {userName}님이 {duration}분간 {difficulty} 강도로 공을 차셨다니! 🌟 {calories}kcal 소모! 월드컵 준비하시는 건가요?',
  ],
  '배구': [
    '놀라워요! {userName}님이 {duration}분간 {difficulty} 강도로 배구를! 🏐 {calories}kcal 소모! 스파이크가 멋있었겠어요!',
    '우와! {duration}분 동안 {difficulty} 페이스로 네트 앞에서! 😮 {userName}님, {calories}kcal 태우시고 블로킹도 완벽하셨겠죠?',
    '대박! {userName}님 {duration}분 동안 {difficulty} 강도로 배구 경기를! 💪 {calories}kcal 연소! 서브 에이스 몇 개나 넣으셨어요?',
    '{duration}분 {difficulty} 배구 완료! 🌟 {userName}님의 팀워크가 빛났겠어요! {calories}kcal 정복!',
    '헉! {userName}님이 {duration}분간 {difficulty} 강도로 코트에서! 🔥 {calories}kcal 소모! 리베로도 놀랄 실력이시네요!',
  ],
};

// 카테고리별 모임 메시지 선택 함수
String getCategorySpecificMeetingMessage({
  required String category,
  required String userName,
  required String meetingTitle,
}) {
  // 카테고리 매핑 (영어 -> 한글)
  final categoryMap = {
    'exercise': '운동',
    'study': '스터디',
    'reading': '독서',
    'networking': '네트워킹',
    'culture': '문화',
    'outdoor': '아웃도어',
    'hobby': '취미',
  };
  
  // 영어 카테고리를 한글로 변환 (이미 한글인 경우 그대로 사용)
  final koreanCategory = categoryMap[category.toLowerCase()] ?? category;
  
  // 디버그: 카테고리 확인
  print('[DEBUG] Meeting Category - Original: "$category", Korean: "$koreanCategory"');
  print('[DEBUG] User: "$userName", Title: "$meetingTitle"');
  
  // 해당 카테고리의 메시지 리스트 가져오기
  final messages = meetingCategoryMessages[koreanCategory];
  
  if (messages == null || messages.isEmpty) {
    // 카테고리를 찾을 수 없는 경우 기본 메시지 반환
    print('[DEBUG] No messages found for category: "$koreanCategory"');
    return '$userName님, "$meetingTitle" 모임을 개설하셨어요! 🎉 함께 성장할 동료들이 곧 모일 거예요!';
  }
  
  // 랜덤으로 메시지 선택
  final randomIndex = Random().nextInt(messages.length);
  var message = messages[randomIndex];
  
  // 플레이스홀더 치환
  message = message.replaceAll('{userName}', userName);
  message = message.replaceAll('{meetingTitle}', meetingTitle);
  
  print('[DEBUG] Selected message: "$message"');
  
  return message;
}

// 카테고리별 모임 참가 메시지 선택 함수
String getCategorySpecificMeetingJoinedMessage({
  required String category,
  required String userName,
  required String meetingTitle,
}) {
  // 카테고리 매핑 (영어 -> 한글)
  final categoryMap = {
    'exercise': '운동',
    'study': '스터디',
    'reading': '독서',
    'networking': '네트워킹',
    'culture': '문화',
    'outdoor': '아웃도어',
    'hobby': '취미',
  };
  
  // 영어 카테고리를 한글로 변환 (이미 한글인 경우 그대로 사용)
  final koreanCategory = categoryMap[category.toLowerCase()] ?? category;
  
  // 디버그: 카테고리 확인
  print('[DEBUG] Meeting Joined Category - Original: "$category", Korean: "$koreanCategory"');
  print('[DEBUG] User: "$userName", Title: "$meetingTitle"');
  
  // 해당 카테고리의 메시지 리스트 가져오기
  final messages = meetingJoinedCategoryMessages[koreanCategory];
  
  if (messages == null || messages.isEmpty) {
    // 카테고리를 찾을 수 없는 경우 기본 메시지 반환
    print('[DEBUG] No joined messages found for category: "$koreanCategory"');
    return '$userName님, "$meetingTitle" 모임에 참가하셨어요! 🎉 함께 성장하는 즐거움을 느껴보세요!';
  }
  
  // 랜덤으로 메시지 선택
  final randomIndex = Random().nextInt(messages.length);
  var message = messages[randomIndex];
  
  // 플레이스홀더 치환
  message = message.replaceAll('{userName}', userName);
  message = message.replaceAll('{meetingTitle}', meetingTitle);
  
  print('[DEBUG] Selected joined message: "$message"');
  
  return message;
}

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
  SherpiContext.exerciseComplete: SherpiEmotion.surprised,
  SherpiContext.readingComplete: SherpiEmotion.thinking,
  SherpiContext.diaryWritten: SherpiEmotion.guiding,
  SherpiContext.focusComplete: SherpiEmotion.thinking,

  // 경고 및 안내
  SherpiContext.tiredWarning: SherpiEmotion.warning,
  SherpiContext.encouragement: SherpiEmotion.smile,  // cheering -> smile 변경: 격려는 웃으며
  SherpiContext.guidance: SherpiEmotion.guiding,
  SherpiContext.tutorial: SherpiEmotion.guiding,

  // 커뮤니티 관련
  SherpiContext.meetingJoined: SherpiEmotion.talking,  // happy -> talking 변경 (카테고리별 메시지와 함께)
  SherpiContext.meetingCreated: SherpiEmotion.special,  // cheering -> special 변경 (모임 개설은 특별한 순간)
  SherpiContext.friendActivity: SherpiEmotion.defaults,
  SherpiContext.guildRankUp: SherpiEmotion.cheering,

  // 특별 이벤트
  SherpiContext.specialEvent: SherpiEmotion.special,
  SherpiContext.achievement: SherpiEmotion.cheering,
  SherpiContext.milestone: SherpiEmotion.special,
  SherpiContext.seasonalGreeting: SherpiEmotion.defaults,
  SherpiContext.allGoalsComplete: SherpiEmotion.special,
};

// 백엔드 연동을 위한 대화 소스 인터페이스
abstract class SherpiDialogueSource {
  Future<String> getDialogue(
      SherpiContext context,
      Map<String, dynamic>? userContext,
      Map<String, dynamic>? gameContext,
      );
}

// 😊 감정별 일기 작성 완료 메시지 선택 함수
String getDiaryCompletionMessage({
  required String mood,
  required String userName,
}) {
  // 디버그: 감정 확인
  print('[DEBUG] Diary Completion - Mood: "$mood", User: "$userName"');
  
  // 해당 감정의 메시지 리스트 가져오기
  final messages = diaryMoodMessages[mood];
  
  if (messages == null || messages.isEmpty) {
    // 감정을 찾을 수 없는 경우 기본 메시지 반환
    print('[DEBUG] No diary messages found for mood: "$mood", using default');
    return '$userName님, 오늘의 이야기를 일기에 담으셨네요! 📝 일기 내용은 비밀로 할게요. 내일은 더 좋은 하루가 되길!';
  }
  
  // 랜덤으로 메시지 선택
  final randomIndex = Random().nextInt(messages.length);
  var selectedMessage = messages[randomIndex];
  
  // 플레이스홀더 치환
  selectedMessage = selectedMessage.replaceAll('{userName}', userName);
  
  print('[DEBUG] Selected diary message: "$selectedMessage"');
  return selectedMessage;
}

// 📚 카테고리별 독서 완료 메시지 선택 함수
String getReadingCompletionMessage({
  required String category,
  required String userName,
  required String bookTitle,
  required int pages,
}) {
  // 디버그: 독서 정보 확인
  print('[DEBUG] Reading Completion - Category: "$category", Book: "$bookTitle", Pages: $pages');
  print('[DEBUG] User: "$userName"');
  
  // 해당 카테고리의 메시지 리스트 가져오기
  final messages = readingCategoryMessages[category];
  
  if (messages == null || messages.isEmpty) {
    // 카테고리를 찾을 수 없는 경우 기본 메시지 반환
    print('[DEBUG] No reading messages found for category: "$category", using default');
    return '$userName님, "$bookTitle" $pages페이지 독서 완료! 📚 오늘도 책과 함께한 시간이 의미있었길 바라요!';
  }
  
  // 랜덤으로 메시지 선택
  final randomIndex = Random().nextInt(messages.length);
  var selectedMessage = messages[randomIndex];
  
  // 플레이스홀더 치환
  selectedMessage = selectedMessage
      .replaceAll('{userName}', userName)
      .replaceAll('{bookTitle}', bookTitle)
      .replaceAll('{pages}', pages.toString());
  
  print('[DEBUG] Selected reading message: "$selectedMessage"');
  return selectedMessage;
}

// 현재 정적 데이터 소스 (백엔드 API 준비 전까지 사용)
class StaticDialogueSource implements SherpiDialogueSource {
  @override
  Future<String> getDialogue(
      SherpiContext context,
      Map<String, dynamic>? userContext,
      Map<String, dynamic>? gameContext,
      ) async {
    // 사용자 이름 가져오기 (공통)
    final userName = gameContext?['userPreferredName'] ?? 
                     gameContext?['userName'] ?? 
                     '친구';
    
    // welcome과 dailyGreeting 메시지 처리 (사용자 이름 치환)
    if (context == SherpiContext.welcome || context == SherpiContext.dailyGreeting) {
      final dialogues = sherpiDialogues[context] ?? ['안녕하세요!'];
      final randomIndex = Random().nextInt(dialogues.length);
      String message = dialogues[randomIndex];
      
      // {userName} 플레이스홀더를 실제 이름으로 치환
      message = message.replaceAll('{userName}', userName);
      return message;
    }
    
    // 일기 작성 완료 시 감정별 메시지 처리
    if (context == SherpiContext.diaryWritten && userContext != null) {
      // 감정 정보가 있으면 감정별 메시지 생성
      final mood = userContext['mood'] as String?;
      if (mood != null && mood.isNotEmpty) {
        print('[DEBUG StaticDialogueSource] Diary completion detected');
        print('[DEBUG StaticDialogueSource] userContext: $userContext');
        print('[DEBUG StaticDialogueSource] gameContext: $gameContext');
        
        print('[DEBUG StaticDialogueSource] Extracted - userName: "$userName", mood: "$mood"');
        
        // 감정별 메시지 생성
        return getDiaryCompletionMessage(
          mood: mood,
          userName: userName,
        );
      }
    }
    
    // 독서 완료 시 카테고리별 메시지 처리
    if (context == SherpiContext.readingComplete && userContext != null) {
      // 독서 활동인지 확인 (additionalData에서 bookTitle이 있으면 독서)
      final bookTitle = userContext['bookTitle'] as String?;
      if (bookTitle != null) {
        print('[DEBUG StaticDialogueSource] Reading completion detected');
        print('[DEBUG StaticDialogueSource] userContext: $userContext');
        print('[DEBUG StaticDialogueSource] gameContext: $gameContext');
        
        // 독서 정보 가져오기
        final pages = userContext['pages'] as int? ?? 0;
        final category = userContext['category'] as String? ?? '기타';
        
        print('[DEBUG StaticDialogueSource] Extracted - userName: "$userName", bookTitle: "$bookTitle", pages: $pages, category: "$category"');
        
        // 카테고리별 메시지 생성
        return getReadingCompletionMessage(
          category: category,
          userName: userName,
          bookTitle: bookTitle,
          pages: pages,
        );
      }
    }
    
    // 운동 완료 시 메시지 처리
    if (context == SherpiContext.exerciseComplete && userContext != null) {
      print('[DEBUG StaticDialogueSource] Exercise completion detected');
      print('[DEBUG StaticDialogueSource] userContext: $userContext');
      print('[DEBUG StaticDialogueSource] gameContext: $gameContext');
      
      // 운동 정보 가져오기
      final exerciseType = userContext['exerciseType'] as String? ?? '운동';
      final duration = userContext['duration'] as int? ?? 0;
      final difficulty = userContext['difficulty'] as String? ?? 'moderate';
      final calories = userContext['calories'] as int? ?? 0;
      
      print('[DEBUG StaticDialogueSource] Extracted - userName: "$userName", exerciseType: "$exerciseType", duration: $duration, difficulty: "$difficulty", calories: $calories');
      
      // 난이도를 한국어로 변환 (DifficultyLevel.name 형식과 intensity 형식 모두 지원)
      String difficultyKr;
      switch (difficulty) {
        case 'easy':
        case 'low':
          difficultyKr = '편안한';
          break;
        case 'moderate':
        case 'medium':
          difficultyKr = '적당한';
          break;
        case 'hard':
        case 'high':
          difficultyKr = '힘든';
          break;
        case 'veryHard':
        case 'very_high':
          difficultyKr = '매우 힘든';
          break;
        default:
          difficultyKr = '적당한';
      }
      
      // 운동 종류별 메시지 선택 (모든 데이터 포함)
      final messages = exerciseTypeMessages[exerciseType] ?? exerciseTypeMessages['기타'] ?? [];
      
      String selectedMessage;
      if (messages.isEmpty) {
        selectedMessage = '$userName님, $duration분 동안 $difficultyKr 강도로 운동하셔서 ${calories}kcal 소모! 🏃 정말 대단해요!';
      } else {
        final random = Random();
        selectedMessage = messages[random.nextInt(messages.length)];
      }
      
      // 플레이스홀더 치환
      selectedMessage = selectedMessage
          .replaceAll('{userName}', userName)
          .replaceAll('{duration}', duration.toString())
          .replaceAll('{difficulty}', difficultyKr)
          .replaceAll('{calories}', calories.toString())
          .replaceAll('{exerciseType}', exerciseType);
      
      print('[DEBUG StaticDialogueSource] Selected exercise message: "$selectedMessage"');
      return selectedMessage;
    }
    
    // 모임 개설 시 카테고리별 메시지 처리
    if (context == SherpiContext.meetingCreated && userContext != null) {
      print('[DEBUG StaticDialogueSource] meetingCreated context detected');
      print('[DEBUG StaticDialogueSource] userContext: $userContext');
      print('[DEBUG StaticDialogueSource] gameContext: $gameContext');
      
      // 모임 정보 가져오기
      final meetingTitle = userContext['meetingTitle'] ?? '새로운 모임';
      final category = userContext['category'] ?? '';
      
      print('[DEBUG StaticDialogueSource] Extracted - userName: "$userName", title: "$meetingTitle", category: "$category"');
      
      // 카테고리별 메시지 생성
      return getCategorySpecificMeetingMessage(
        category: category,
        userName: userName,
        meetingTitle: meetingTitle,
      );
    }
    
    // 모임 참가 시 카테고리별 메시지 처리
    if (context == SherpiContext.meetingJoined && userContext != null) {
      print('[DEBUG StaticDialogueSource] meetingJoined context detected');
      print('[DEBUG StaticDialogueSource] userContext: $userContext');
      print('[DEBUG StaticDialogueSource] gameContext: $gameContext');
      
      // 모임 정보 가져오기
      final meetingTitle = userContext['meeting_title'] ?? 
                          userContext['meetingTitle'] ?? 
                          '새로운 모임';
      final category = userContext['category'] ?? '';
      
      print('[DEBUG StaticDialogueSource] Extracted - userName: "$userName", title: "$meetingTitle", category: "$category"');
      
      // 카테고리별 메시지 생성
      return getCategorySpecificMeetingJoinedMessage(
        category: category,
        userName: userName,
        meetingTitle: meetingTitle,
      );
    }
    
    // 일반 메시지 처리
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
