/// 📝 격려 메시지 타입 (7가지)
///
/// 심리학 기반 (SDT, Positive Psychology) + 한국 문화 맥락 (정/jeong)
enum EncouragementMessageType {
  /// 공감 (Empathy) - "나도 이해해요"
  empathy('공감', 'Empathy', 'validates_feelings', '💙🌸☁️🤗💚'),

  /// 응원 (Cheering) - "할 수 있어요!"
  cheering('응원', 'Cheering', 'boosts_confidence', '🔥💪🚀⭐🎉'),

  /// 위로 (Comfort) - "괜찮아요"
  comfort('위로', 'Comfort', 'provides_reassurance', '💙🌸☁️🤗💚'),

  /// 인정 (Recognition) - "잘하고 있어요"
  recognition('인정', 'Recognition', 'acknowledges_progress', '✨🌟💫👏💎'),

  /// 동행 (Companionship) - "함께 가요"
  companionship('동행', 'Companionship', 'builds_connection', '🤝💚🌿👥🫂'),

  /// 성찰 (Reflection) - "배우고 있어요"
  reflection('성찰', 'Reflection', 'promotes_growth', '💡🌱📚🔍🧘'),

  /// 축하 (Celebration) - "대단해요!"
  celebration('축하', 'Celebration', 'amplifies_achievement', '🎉🎊🏆🥳⭐');

  const EncouragementMessageType(
    this.korean,
    this.english,
    this.id,
    this.emojis,
  );

  final String korean;
  final String english;
  final String id;
  final String emojis;

  /// 메시지 타입의 심리학적 목적
  String get purpose {
    switch (this) {
      case empathy:
        return '감정 공감과 유대감 형성';
      case cheering:
        return '자신감과 에너지 부여';
      case comfort:
        return '안정감과 허용 제공';
      case recognition:
        return '구체적 노력 인정과 동기 부여';
      case companionship:
        return '소속감과 동행 강조';
      case reflection:
        return '성장 마인드셋 형성';
      case celebration:
        return '성취 증폭과 긍정 강화';
    }
  }

  /// 메시지 톤 특성
  String get tone {
    switch (this) {
      case empathy:
        return '부드럽고 이해하는, 비판단적';
      case cheering:
        return '활기차고 에너지 넘치는, 행동 지향적';
      case comfort:
        return '따뜻하고 안심시키는, 허용적';
      case recognition:
        return '구체적이고 증거 기반의, 과정 중심적';
      case companionship:
        return '포용적이고 파트너십 느낌, 동행 강조';
      case reflection:
        return '사려 깊고 미래 지향적, 비판단적';
      case celebration:
        return '기쁘고 열정적인, 자부심 공유';
    }
  }

  /// 좋은 예시 (한국어)
  List<String> get examples {
    switch (this) {
      case empathy:
        return [
          '요즘 좀 힘드셨죠? 💙 그럴 때도 있어요',
          '피곤하실 텐데 여기까지 오신 게 대단해요 🌸',
          '완벽하지 않아도 괜찮아요. 함께 천천히 가요 ☁️',
          '힘든 마음 충분히 이해해요. 혼자가 아니에요 🤗',
          '지친 하루였죠? 오늘도 고생했어요 💙',
        ];

      case cheering:
        return [
          '오늘도 화이팅! 🔥 할 수 있어요!',
          '이 기세로 쭉 가봐요! 💪 응원할게요!',
          '벌써 여기까지 왔잖아요! 끝까지 가요! 🚀',
          '오늘 하루도 파이팅! ⭐ 함께 힘내요!',
          '지금처럼만 하면 돼요! 같이 가요! 🎉',
        ];

      case comfort:
        return [
          '괜찮아요. 천천히 가도 충분해요 💙',
          '실패해도 괜찮아요. 다시 시작하면 돼요 🌸',
          '쉬어가도 돼요. 무리하지 마세요 ☁️',
          '완벽하지 않아도 괜찮아요. 그대로 좋아요 🤗',
          '힘들 땐 잠시 쉬어요. 옆에 있을게요 💚',
        ];

      case recognition:
        return [
          '매일 조금씩 쌓아온 게 보여요 ✨ 대단해요!',
          '꾸준히 해온 게 이렇게 빛나고 있어요 🌟',
          '한 걸음 한 걸음이 모여 여기까지 왔네요 💫',
          '포기하지 않고 계속한 게 정말 멋져요 👏',
          '작은 노력들이 모여 큰 변화를 만들고 있어요 ✨',
        ];

      case companionship:
        return [
          '혼자가 아니에요. 함께 걸어가요 🤝',
          '저도 옆에 있어요. 같이 해봐요 💚',
          '우리 천천히 함께 가요. 서두르지 말아요 🌿',
          '힘들 때 옆에서 함께할게요. 기대도 돼요 🤗',
          '한 걸음씩 같이 가요. 옆에 있어요 👥',
        ];

      case reflection:
        return [
          '실패하면서 배우는 거예요. 성장하고 있어요 💡',
          '힘든 시간도 배움의 순간이에요. 함께 성장해요 🌱',
          '완벽하지 않아도 매번 배우고 있어요. 멋져요 📚',
          '쉬어가는 것도 배움이에요. 더 나은 길을 찾고 있어요 🔍',
          '천천히 가면서 나를 알아가는 거예요. 괜찮아요 💡',
        ];

      case celebration:
        return [
          '와! 정말 대단해요! 🎉 축하해요!',
          '해냈어요! 🏆 정말 자랑스러워요!',
          '멋진 성취예요! 🎊 함께 기뻐요!',
          '이렇게까지 오다니! 🥳 정말 대단해요!',
          '축하해요! ⭐ 이 순간을 함께 누려요!',
        ];
    }
  }

  /// 피해야 할 표현
  List<String> get avoid {
    switch (this) {
      case empathy:
        return [
          '왜 힘든지 이해 안 돼요 (감정 무효화)',
          '그냥 힘내세요! (성급한 응원)',
          '다들 그래요 (일축)',
        ];

      case cheering:
        return [
          '더 열심히 하세요! (압박)',
          '이 정도는 쉬운 거예요 (노력 폄하)',
          '실패하면 안 돼요 (공포 기반 동기)',
        ];

      case comfort:
        return [
          '쉬면 안 돼요, 계속해야죠 (통제적)',
          '이 정도로 힘들어하면 안 돼요 (감정 무효화)',
          '그냥 괜찮아요 (공허한 위로)',
        ];

      case recognition:
        return [
          '12레벨이에요! 의지 22점! (통계 나열)',
          '23회 완료! (숫자 외치기)',
          '좋네요 (막연한 인정)',
        ];

      case companionship:
        return [
          '혼자 하세요 (고립)',
          '다른 사람들은 다 하는데요 (비교)',
          '제가 도와드릴게요 (상하 관계)',
        ];

      case reflection:
        return [
          '실패에서 배우지 못하네요 (비난)',
          '이번엔 더 열심히 하세요 (지시적)',
          '이걸로 교훈을 얻으세요 (강의 톤)',
        ];

      case celebration:
        return [
          '축하해요. (끝) (무기력한 축하)',
          '다음엔 더 잘하세요 (축하 약화)',
          '12레벨 달성! (통계 공지)',
        ];
    }
  }

  /// 타입별 특화 가이드 (프롬프트용)
  String get specificGuidance {
    switch (this) {
      case empathy:
        return '''
**공감 메시지 특화**:
- 사용자의 감정을 먼저 인정하고 이해해주세요
- "~죠?", "~네요" 같은 확인과 공감의 어미 사용
- 판단하지 말고, 그저 함께 느끼기
- 예: "요즘 좀 힘드셨죠? 💙 그럴 때도 있어요"
''';

      case cheering:
        return '''
**응원 메시지 특화**:
- 에너지 넘치고 활기찬 톤으로
- "화이팅!", "할 수 있어요!", "함께 가요!" 같은 응원 표현
- 행동 지향적이고 긍정적인 메시지
- 예: "오늘도 화이팅! 🔥 함께 힘내요!"
''';

      case comfort:
        return '''
**위로 메시지 특화**:
- 따뜻하고 부드러운 톤으로
- "괜찮아요", "천천히", "쉬어도 돼요" 같은 허용과 안심
- 쉴 권리와 불완전함을 인정
- 예: "괜찮아요. 천천히 가도 충분해요 💙"
''';

      case recognition:
        return '''
**인정 메시지 특화**:
- 구체적인 노력과 과정을 인정
- "~하고 있어요", "~가 보여요" 같은 관찰과 인정
- 결과보다 과정에 초점
- 예: "매일 조금씩 쌓아온 게 보여요 ✨ 대단해요!"
''';

      case companionship:
        return '''
**동행 메시지 특화**:
- "함께", "같이", "우리" 같은 동행 표현
- 혼자가 아님을 강조
- 파트너십과 유대감 형성
- 예: "혼자가 아니에요. 함께 걸어가요 🤝"
''';

      case reflection:
        return '''
**성찰 메시지 특화**:
- 배움과 성장의 관점 제시
- "배우고 있어요", "성장", "변화" 같은 발전 표현
- 실패를 학습 기회로 재구성
- 예: "실패하면서 배우는 거예요. 성장하고 있어요 💡"
''';

      case celebration:
        return '''
**축하 메시지 특화**:
- 기쁨과 자부심을 함께 나누기
- "대단해요!", "축하해요!", "해냈어요!" 같은 축하 표현
- 에너지 넘치고 열정적인 톤
- 예: "와! 정말 대단해요! 🎉 축하해요!"
''';
    }
  }
}
