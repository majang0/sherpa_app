/// 🎭 셰르피 감정 상태 시스템
/// 
/// 10개의 감정 이미지를 활용한 상황별 감정 표현 시스템

import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';

/// 🎨 셰르피의 10가지 감정 상태
/// 기존 시스템과 호환성을 위해 naming convention 유지
enum SherpiEmotion {
  /// 😊 기본 상태 - 일반적인 안내, 평상시
  defaults('sherpi_default.png'),
  
  /// 😄 행복한 상태 - 성취 축하, 긍정적 피드백
  happy('sherpi_happy.png'),
  
  /// 😔 슬픈 상태 - 위로가 필요한 상황, 격려가 필요할 때
  sad('sherpi_sad.png'),
  
  /// 😲 놀란 상태 - 예상치 못한 성취, 놀라운 발견
  surprised('sherpi_surprised.png'),
  
  /// 🤔 생각하는 상태 - 분석 중, 조언 준비
  thinking('sherpi_thinking.png'),
  
  /// 👨‍🏫 안내하는 상태 - 가이드, 도움말 제공
  guiding('sherpi_guiding.png'),
  
  /// 🎉 환호하는 상태 - 레벨업, 큰 성취 축하
  cheering('sherpi_cheering.png'),
  
  /// ⚠️ 경고 상태 - 주의사항, 중요한 알림
  warning('sherpi_warning.png'),
  
  /// 😴 잠자는 상태 - 장기 미접속, 휴식 상태
  sleeping('sherpi_sleeping.png'),
  
  /// ✨ 특별한 상태 - 기념일, 마일스톤, 특별한 순간
  special('sherpi_special.png');

  const SherpiEmotion(this.fileName);
  
  /// 이미지 파일명
  final String fileName;
  
  /// 전체 이미지 경로 반환
  String get imagePath => 'assets/images/sherpi/$fileName';
}

/// 🎯 상황별 감정 상태 자동 선택 시스템
class SherpiEmotionMapper {
  /// 컨텍스트에 따른 최적의 감정 상태 반환
  static SherpiEmotion getEmotionForContext(SherpiContext context) {
    switch (context) {
      // 🎉 환호/축하 상황
      case SherpiContext.levelUp:
      case SherpiContext.badgeEarned:
      case SherpiContext.climbingSuccess:
      case SherpiContext.questComplete:
        return SherpiEmotion.cheering;
        
      // 😊 행복/긍정적 상황
      case SherpiContext.welcome:
      case SherpiContext.dailyGreeting:
      case SherpiContext.exerciseComplete:
      case SherpiContext.studyComplete:
      case SherpiContext.achievement:
        return SherpiEmotion.happy;
        
      // 🤔 분석/생각하는 상황
      case SherpiContext.guidance:
        return SherpiEmotion.thinking;
        
      // 👨‍🏫 안내/가이드 상황
      case SherpiContext.tutorial:
        return SherpiEmotion.guiding;
        
      // 😲 놀라운/예상치 못한 상황
      case SherpiContext.longTimeNoSee:
        return SherpiEmotion.surprised;
        
      // ✨ 특별한/기념할만한 상황
      case SherpiContext.milestone:
      case SherpiContext.specialEvent:
        return SherpiEmotion.special;
        
      // 😔 위로/격려가 필요한 상황
      case SherpiContext.encouragement:
      case SherpiContext.climbingFailure:
        return SherpiEmotion.sad;
        
      // ⚠️ 주의/경고 상황
      case SherpiContext.tiredWarning:
        return SherpiEmotion.warning;
        
      // 🎉 기본 상황 - 일반적인 상호작용
      case SherpiContext.general:
        return SherpiEmotion.happy;
        
      // 😊 기본 상황
      default:
        return SherpiEmotion.defaults;
    }
  }
  
  /// 감정 상태에 따른 UI 색상 테마 반환
  static EmotionTheme getThemeForEmotion(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.cheering:
        return EmotionTheme.celebration;
      case SherpiEmotion.happy:
      case SherpiEmotion.defaults:
        return EmotionTheme.positive;
      case SherpiEmotion.thinking:
        return EmotionTheme.analytical;
      case SherpiEmotion.guiding:
        return EmotionTheme.helpful;
      case SherpiEmotion.surprised:
        return EmotionTheme.surprise;
      case SherpiEmotion.special:
        return EmotionTheme.special;
      case SherpiEmotion.sad:
        return EmotionTheme.supportive;
      case SherpiEmotion.warning:
        return EmotionTheme.warning;
      case SherpiEmotion.sleeping:
        return EmotionTheme.calm;
    }
  }
  
  /// 감정 상태 변화에 적절한 애니메이션 타입 반환
  static SherpiAnimationType getAnimationForTransition(
    SherpiEmotion from, 
    SherpiEmotion to
  ) {
    // 축하 상황으로 전환
    if (to == SherpiEmotion.cheering) {
      return SherpiAnimationType.celebration;
    }
    
    // 놀라운 상황으로 전환
    if (to == SherpiEmotion.surprised) {
      return SherpiAnimationType.bounce;
    }
    
    // 특별한 상황으로 전환
    if (to == SherpiEmotion.special) {
      return SherpiAnimationType.sparkle;
    }
    
    // 위로가 필요한 상황으로 전환
    if (to == SherpiEmotion.sad) {
      return SherpiAnimationType.gentle;
    }
    
    // 일반적인 전환
    return SherpiAnimationType.fade;
  }
}

/// 🎨 감정별 UI 테마
enum EmotionTheme {
  celebration,    // 축하 - 오렌지/골드
  positive,       // 긍정 - 초록/파랑
  analytical,     // 분석 - 보라/인디고
  helpful,        // 도움 - 파랑/청록
  surprise,       // 놀람 - 핑크/마젠타
  special,        // 특별 - 무지개/그라데이션
  supportive,     // 지지 - 따뜻한 베이지/브라운
  warning,        // 경고 - 주황/빨강
  calm,          // 평온 - 회색/라벤더
}

/// 🎬 셰르피 애니메이션 타입
enum SherpiAnimationType {
  fade,           // 페이드 전환
  bounce,         // 바운스 효과
  celebration,    // 축하 애니메이션
  sparkle,        // 스파클 효과
  gentle,         // 부드러운 전환
  pulse,          // 맥동 효과
  shake,          // 흔들기 (주의 끌기)
}

/// 🎯 감정 상태별 메시지 톤 가이드
class SherpiEmotionTone {
  static String getToneDescription(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.cheering:
        return "열정적이고 축하하는 톤. 큰 성취를 진심으로 축하하며 자부심을 표현";
      case SherpiEmotion.happy:
        return "밝고 긍정적인 톤. 따뜻한 격려와 함께하는 기쁨을 표현";
      case SherpiEmotion.thinking:
        return "차분하고 분석적인 톤. 깊이 있는 통찰과 신중한 조언을 제공";
      case SherpiEmotion.guiding:
        return "친절하고 도움이 되는 톤. 명확한 안내와 단계별 설명을 제공";
      case SherpiEmotion.surprised:
        return "놀라움과 호기심을 담은 톤. 예상치 못한 발견에 대한 흥미 표현";
      case SherpiEmotion.special:
        return "특별하고 의미있는 톤. 기념할만한 순간의 소중함을 강조";
      case SherpiEmotion.sad:
        return "따뜻하고 위로하는 톤. 공감과 격려를 통한 정서적 지지 제공";
      case SherpiEmotion.warning:
        return "주의깊고 신중한 톤. 중요한 정보를 명확하고 우려스럽지 않게 전달";
      case SherpiEmotion.sleeping:
        return "부드럽고 평온한 톤. 휴식의 중요성과 다시 시작하는 것에 대한 격려";
      case SherpiEmotion.defaults:
        return "친근하고 균형잡힌 톤. 자연스럽고 편안한 일상적 대화";
    }
  }
  
  /// 감정에 맞는 이모지 제안
  static List<String> getSuggestedEmojis(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.cheering:
        return ['🎉', '🏆', '💪', '🚀', '⭐', '🔥'];
      case SherpiEmotion.happy:
        return ['😊', '😄', '✨', '💚', '🌟', '🎈'];
      case SherpiEmotion.thinking:
        return ['🤔', '💭', '📊', '🧠', '💡', '🔍'];
      case SherpiEmotion.guiding:
        return ['👨‍🏫', '📚', '🗺️', '🎯', '📝', '💼'];
      case SherpiEmotion.surprised:
        return ['😲', '😮', '🤩', '❗', '✨', '🎊'];
      case SherpiEmotion.special:
        return ['✨', '🌟', '💫', '🎊', '🎁', '👑'];
      case SherpiEmotion.sad:
        return ['🤗', '💙', '🌈', '☀️', '🌸', '💪'];
      case SherpiEmotion.warning:
        return ['⚠️', '📢', '🔔', '❗', '🚨', '📋'];
      case SherpiEmotion.sleeping:
        return ['😴', '🌙', '💤', '🌸', '☁️', '🕊️'];
      case SherpiEmotion.defaults:
        return ['😊', '👋', '💫', '🌟', '✨', '🤝'];
    }
  }
}