// 🎭 감정 기반 적응형 응답 시스템
//
// 사용자의 감정 상태에 따라 셰르피의 응답 스타일과 내용을 적응시키는 시스템

import 'dart:math';
import '../models/emotion_state_model.dart';
import '../../../../core/constants/sherpi_emotions.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

/// 🎭 응답 스타일 설정
enum ResponseStyle {
  /// 🤗 공감적 - 사용자의 감정에 깊이 공감하고 위로
  empathetic('empathetic', '공감적', '사용자의 감정에 깊이 공감하며 따뜻하게 반응'),

  /// 💪 격려적 - 긍정적이고 동기부여하는 메시지
  encouraging('encouraging', '격려적', '긍정적 에너지로 사용자를 격려하고 동기부여'),

  /// 🧘 차분한 - 안정적이고 평온한 톤
  calming('calming', '차분한', '평온하고 안정적인 톤으로 마음을 진정시킴'),

  /// 🎉 축하하는 - 기쁨과 성취를 함께 축하
  celebratory('celebratory', '축하하는', '기쁨과 성취를 함께 축하하며 즐거워함'),

  /// 🤔 사려깊은 - 신중하고 깊이 있는 조언
  thoughtful('thoughtful', '사려깊은', '신중하고 깊이 있는 조언과 통찰 제공'),

  /// 🚀 동기부여 - 목표 달성을 위한 에너지 제공
  motivational('motivational', '동기부여', '목표 달성을 위한 강한 동기와 에너지 제공'),

  /// 😌 지지적 - 무조건적 지지와 이해
  supportive('supportive', '지지적', '무조건적인 지지와 이해로 안전감 제공'),

  /// 💡 조언적 - 실용적이고 구체적인 도움
  advisory('advisory', '조언적', '실용적이고 구체적인 조언과 해결책 제시');

  const ResponseStyle(this.id, this.displayName, this.description);

  final String id;
  final String displayName;
  final String description;
}

/// 📝 응답 템플릿
class ResponseTemplate {
  final String templateId;
  final EmotionType targetEmotion;
  final ResponseStyle style;
  final List<String> messageTemplates;
  final SherpiEmotion sherpiEmotion;
  final Map<String, dynamic> contextRequirements;
  final double effectivenessScore; // 이 템플릿의 효과성 점수

  const ResponseTemplate({
    required this.templateId,
    required this.targetEmotion,
    required this.style,
    required this.messageTemplates,
    required this.sherpiEmotion,
    this.contextRequirements = const {},
    this.effectivenessScore = 0.7,
  });

  /// 컨텍스트와 사용자 정보로 메시지 개인화
  String generateMessage({
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> emotionContext,
    String? userName,
  }) {
    final random = Random();
    final template = messageTemplates[random.nextInt(messageTemplates.length)];

    String message = template;

    // 사용자 이름 치환
    if (userName != null && userName.isNotEmpty) {
      message = message.replaceAll('{user_name}', userName);
      message = message.replaceAll('{name}', userName);
    } else {
      // 이름이 없으면 친근한 호칭으로 대체
      message = message.replaceAll('{user_name}', '');
      message = message.replaceAll('{name}', '');
    }

    // 감정 컨텍스트 치환
    final emotionIntensity =
        emotionContext['intensity'] as String? ?? 'moderate';
    final emotionTrigger = emotionContext['trigger'] as String? ?? '';

    message = message.replaceAll(
        '{emotion_intensity}', _getIntensityWord(emotionIntensity));
    message = message.replaceAll('{trigger}', emotionTrigger);

    // 활동 컨텍스트 치환
    final recentActivity = userContext['recent_activity'] as String? ?? '';
    final achievement = userContext['recent_achievement'] as String? ?? '';

    message = message.replaceAll('{recent_activity}', recentActivity);
    message = message.replaceAll('{achievement}', achievement);

    return message.trim();
  }

  /// 강도를 표현하는 단어 변환
  String _getIntensityWord(String intensity) {
    switch (intensity) {
      case 'very_high':
        return '매우';
      case 'high':
        return '정말';
      case 'moderate':
        return '꽤';
      case 'low':
        return '조금';
      case 'very_low':
        return '살짝';
      default:
        return '';
    }
  }
}

/// 🎭 감정별 응답 템플릿 데이터베이스
class EmotionResponseTemplates {
  /// 😊 긍정적 감정 응답 템플릿들
  static const List<ResponseTemplate> positiveEmotionTemplates = [
    // 기쁨 (Joy)
    ResponseTemplate(
      templateId: 'joy_celebratory_1',
      targetEmotion: EmotionType.joy,
      style: ResponseStyle.celebratory,
      sherpiEmotion: SherpiEmotion.cheering,
      messageTemplates: [
        '와! {user_name} 정말 기쁘시군요! 🎉 저도 함께 기뻐요!',
        '{user_name}의 기쁨이 저에게도 전해져요! 정말 좋은 일이었나봐요! ✨',
        '이렇게 행복해하시는 모습을 보니 제 마음도 따뜻해져요! 🥰',
        '기쁨을 나눠주셔서 감사해요! 함께 축하해요! 🎊',
      ],
      effectivenessScore: 0.9,
    ),

    // 흥분 (Excitement)
    ResponseTemplate(
      templateId: 'excitement_motivational_1',
      targetEmotion: EmotionType.excitement,
      style: ResponseStyle.motivational,
      sherpiEmotion: SherpiEmotion.cheering,
      messageTemplates: [
        '우와! {user_name}의 설렘이 저에게도 전해져요! 🚀',
        '이 에너지 정말 좋아요! 뭔가 대단한 일이 일어날 것 같아요! ⚡',
        '{user_name}의 열정이 눈부셔요! 계속 이 기세로 가보자고요! 💪',
        '저도 덩달아 신나네요! 함께 달려봐요! 🏃‍♂️',
      ],
      effectivenessScore: 0.85,
    ),

    // 만족 (Satisfaction)
    ResponseTemplate(
      templateId: 'satisfaction_supportive_1',
      targetEmotion: EmotionType.satisfaction,
      style: ResponseStyle.supportive,
      sherpiEmotion: SherpiEmotion.happy,
      messageTemplates: [
        '{user_name}이 만족스러워하시니 정말 다행이에요! 😌',
        '뿌듯한 기분이시겠어요! {achievement} 정말 잘하셨어요!',
        '이런 성취감이야말로 진짜 보람이죠! 축하드려요! 🌟',
        '노력의 결실을 맛보는 기분이 어떠세요? 정말 기특해요!',
      ],
      effectivenessScore: 0.8,
    ),

    // 자부심 (Pride)
    ResponseTemplate(
      templateId: 'pride_celebratory_1',
      targetEmotion: EmotionType.pride,
      style: ResponseStyle.celebratory,
      sherpiEmotion: SherpiEmotion.special,
      messageTemplates: [
        '{user_name}의 성취를 자랑스럽게 생각해요! 👏',
        '이 자부심, 충분히 느껴도 돼요! 정말 대단하거든요!',
        '스스로를 뿌듯해하는 모습이 보기 좋아요! 🏆',
        '{achievement}은 정말 자랑할 만한 일이에요! 멋져요!',
      ],
      effectivenessScore: 0.85,
    ),
  ];

  /// 😢 부정적 감정 응답 템플릿들
  static const List<ResponseTemplate> negativeEmotionTemplates = [
    // 슬픔 (Sadness)
    ResponseTemplate(
      templateId: 'sadness_empathetic_1',
      targetEmotion: EmotionType.sadness,
      style: ResponseStyle.empathetic,
      sherpiEmotion: SherpiEmotion.sad,
      messageTemplates: [
        '{user_name}의 마음이 아프시는군요... 제가 옆에 있을게요 🤗',
        '많이 속상하셨을 것 같아요. 괜찮다고 말하지 않을게요, 슬플 때는 슬퍼도 돼요',
        '힘든 시간을 보내고 계시는군요. 혼자가 아니라는 걸 기억해주세요 💙',
        '울고 싶을 때는 우셔도 돼요. 저는 여기 있을게요',
      ],
      effectivenessScore: 0.9,
    ),

    // 분노 (Anger)
    ResponseTemplate(
      templateId: 'anger_calming_1',
      targetEmotion: EmotionType.anger,
      style: ResponseStyle.calming,
      sherpiEmotion: SherpiEmotion.guiding,
      messageTemplates: [
        '많이 화가 나셨군요. 깊게 숨을 한 번 쉬어보세요... 🌬️',
        '지금 감정이 격해지셨을 것 같아요. 잠시 멈춰서 마음을 정리해봐요',
        '화가 나는 건 당연해요. 하지만 일단 진정부터 해봐요 🧘‍♀️',
        '이런 기분일 때는 조금 쉬는 게 좋을 것 같아요. 괜찮아질 거예요',
      ],
      effectivenessScore: 0.75,
    ),

    // 좌절 (Frustration)
    ResponseTemplate(
      templateId: 'frustration_encouraging_1',
      targetEmotion: EmotionType.frustration,
      style: ResponseStyle.encouraging,
      sherpiEmotion: SherpiEmotion.guiding,
      messageTemplates: [
        '답답하고 막막하시겠지만, 이런 때일수록 한 걸음씩 가봐요 🚶‍♀️',
        '잘 안 풀릴 때가 있죠. 하지만 {user_name}이라면 분명 해결책을 찾을 거예요!',
        '이럴 때는 다른 방법을 생각해봐도 좋을 것 같아요. 길은 하나가 아니거든요 🛤️',
        '좌절감이 드시겠지만, 지금까지 잘 해오셨잖아요. 조금만 더 힘내봐요!',
      ],
      effectivenessScore: 0.8,
    ),

    // 불안 (Anxiety)
    ResponseTemplate(
      templateId: 'anxiety_calming_1',
      targetEmotion: EmotionType.anxiety,
      style: ResponseStyle.calming,
      sherpiEmotion: SherpiEmotion.guiding,
      messageTemplates: [
        '불안한 마음이 드시는군요. 천천히 호흡하며 현재에 집중해봐요 🌸',
        '걱정이 많으실 텐데, 지금 이 순간은 안전해요. 괜찮아요',
        '불안할 때는 작은 것부터 차근차근 해보는 게 도움이 돼요 🌱',
        '마음이 조급해지셨을 텐데, 모든 게 잘 될 거예요. 믿어봐요',
      ],
      effectivenessScore: 0.85,
    ),

    // 실망 (Disappointment)
    ResponseTemplate(
      templateId: 'disappointment_supportive_1',
      targetEmotion: EmotionType.disappointment,
      style: ResponseStyle.supportive,
      sherpiEmotion: SherpiEmotion.thinking,
      messageTemplates: [
        '기대했던 만큼 결과가 나오지 않아서 실망스러우시겠어요 😔',
        '아쉬운 마음 충분히 이해해요. 하지만 이것도 소중한 경험이에요',
        '실망스럽겠지만, {user_name}의 노력은 결코 헛되지 않았어요',
        '때로는 예상과 다른 결과가 나와도, 그 과정에서 얻은 게 많을 거예요',
      ],
      effectivenessScore: 0.8,
    ),
  ];

  /// 😐 중립적 감정 응답 템플릿들
  static const List<ResponseTemplate> neutralEmotionTemplates = [
    // 평온 (Calm)
    ResponseTemplate(
      templateId: 'calm_supportive_1',
      targetEmotion: EmotionType.calm,
      style: ResponseStyle.supportive,
      sherpiEmotion: SherpiEmotion.defaults,
      messageTemplates: [
        '마음의 평화를 찾으셨군요. 이런 고요한 순간이 참 소중해요 🌙',
        '차분한 {user_name}의 모습이 보기 좋아요. 이런 평온함을 유지해보세요',
        '평온한 마음 상태네요. 이럴 때 깊이 있는 생각을 해봐도 좋을 것 같아요',
        '고요한 마음, 참 아름다워요. 이 순간을 온전히 느껴보세요 ✨',
      ],
      effectivenessScore: 0.7,
    ),

    // 집중 (Focused)
    ResponseTemplate(
      templateId: 'focused_motivational_1',
      targetEmotion: EmotionType.focused,
      style: ResponseStyle.motivational,
      sherpiEmotion: SherpiEmotion.thinking,
      messageTemplates: [
        '집중력이 높아지셨네요! 이 몰입 상태를 잘 활용해보세요 🎯',
        '지금 이 집중력으로 무엇이든 해낼 수 있을 것 같아요!',
        '훌륭한 집중력이에요! {recent_activity}에 완전히 몰입하고 계시는군요',
        '이런 집중 상태일 때가 가장 많은 걸 얻을 수 있어요. 계속해보세요! 💪',
      ],
      effectivenessScore: 0.75,
    ),

    // 피곤 (Tired)
    ResponseTemplate(
      templateId: 'tired_calming_1',
      targetEmotion: EmotionType.tired,
      style: ResponseStyle.calming,
      sherpiEmotion: SherpiEmotion.thinking,
      messageTemplates: [
        '많이 피곤하시군요. 충분한 휴식을 취하는 것도 중요해요 😴',
        '몸과 마음이 쉬고 싶어하는 것 같아요. 무리하지 말고 쉬어보세요',
        '오늘 하루도 수고 많으셨어요. 이제 편히 쉬셔도 돼요 🛌',
        '피로할 때는 자신을 다독여주는 게 필요해요. 고생하셨어요',
      ],
      effectivenessScore: 0.8,
    ),

    // 지루함 (Bored)
    ResponseTemplate(
      templateId: 'bored_encouraging_1',
      targetEmotion: EmotionType.bored,
      style: ResponseStyle.encouraging,
      sherpiEmotion: SherpiEmotion.thinking,
      messageTemplates: [
        '좀 심심하신가봐요? 새로운 걸 시작해볼 좋은 기회일 수도 있어요! 🌟',
        '지루할 때는 평소에 못 해본 일에 도전해보는 건 어때요?',
        '이런 여유로운 시간에 자신을 위한 일을 해봐도 좋을 것 같아요',
        '단조로운 일상에 작은 변화를 주어보면 어떨까요? 💡',
      ],
      effectivenessScore: 0.7,
    ),

    // 호기심 (Curious)
    ResponseTemplate(
      templateId: 'curious_thoughtful_1',
      targetEmotion: EmotionType.curious,
      style: ResponseStyle.thoughtful,
      sherpiEmotion: SherpiEmotion.thinking,
      messageTemplates: [
        '뭔가 궁금한 게 생기셨나봐요? 호기심은 성장의 시작이에요! 🔍',
        '궁금해하는 마음이 참 좋아요! 알아가는 재미가 있을 거예요',
        '이런 탐구 정신이야말로 {user_name}의 장점이죠! ✨',
        '궁금증을 해결해나가는 과정에서 많은 걸 배우게 될 거예요',
      ],
      effectivenessScore: 0.75,
    ),
  ];

  /// 🤔 복합 감정 응답 템플릿들
  static const List<ResponseTemplate> mixedEmotionTemplates = [
    // 씁쓸함 (Bittersweet)
    ResponseTemplate(
      templateId: 'bittersweet_empathetic_1',
      targetEmotion: EmotionType.bittersweet,
      style: ResponseStyle.empathetic,
      sherpiEmotion: SherpiEmotion.thinking,
      messageTemplates: [
        '복잡한 감정이시군요. 기쁘면서도 아쉬운 마음... 이해해요 💫',
        '달콤하면서도 쓴 맛 같은 기분이시겠어요. 인생이 그런 거죠',
        '이런 묘한 감정도 삶의 깊이를 더해주는 것 같아요',
        '마음이 여러 갈래로 나뉘어 있으시군요. 천천히 정리해봐요',
      ],
      effectivenessScore: 0.75,
    ),

    // 압도됨 (Overwhelmed)
    ResponseTemplate(
      templateId: 'overwhelmed_calming_1',
      targetEmotion: EmotionType.overwhelmed,
      style: ResponseStyle.calming,
      sherpiEmotion: SherpiEmotion.guiding,
      messageTemplates: [
        '너무 많은 것들이 한번에 몰려와서 벅차시는군요. 천천히 해봐요 🌊',
        '감당하기 어려우실 텐데, 하나씩 차근차근 처리해보는 건 어때요?',
        '이럴 때는 가장 중요한 것 하나만 집중해보세요. 괜찮아요',
        '압도당하는 기분이시겠지만, 시간을 가지고 정리해봐요',
      ],
      effectivenessScore: 0.8,
    ),

    // 갈등 (Conflicted)
    ResponseTemplate(
      templateId: 'conflicted_thoughtful_1',
      targetEmotion: EmotionType.conflicted,
      style: ResponseStyle.thoughtful,
      sherpiEmotion: SherpiEmotion.thinking,
      messageTemplates: [
        '선택이 어려우시군요. 마음이 여러 방향으로 끌리시는 것 같아요 🤷‍♀️',
        '갈등할 때는 각각의 장단점을 적어보는 것도 도움이 돼요',
        '복잡한 상황이시네요. 시간을 가지고 천천히 생각해봐도 돼요',
        '어려운 결정이시겠지만, {user_name}이라면 현명한 선택을 하실 거예요',
      ],
      effectivenessScore: 0.75,
    ),
  ];

  /// 모든 템플릿 통합
  static List<ResponseTemplate> get allTemplates {
    return [
      ...positiveEmotionTemplates,
      ...negativeEmotionTemplates,
      ...neutralEmotionTemplates,
      ...mixedEmotionTemplates,
    ];
  }
}

/// 🎭 감정 적응형 응답 시스템
class EmotionAdaptiveResponseSystem {
  static const double _minimumTemplateScore = 0.6;
  static const int _maxResponseOptions = 3;

  /// 🎯 감정 상태에 맞는 응답 생성
  ///
  /// 사용자의 감정 상태를 분석하여 가장 적절한 응답을 생성
  static Map<String, dynamic> generateEmotionAdaptiveResponse(
    EmotionSnapshot emotionState, {
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> conversationContext,
    String? userName,
    String? customTrigger,
  }) {
    // 적합한 템플릿 찾기
    final suitableTemplates = _findSuitableTemplates(
      emotionState,
      userContext,
      conversationContext,
    );

    if (suitableTemplates.isEmpty) {
      return _generateFallbackResponse(emotionState, userContext, userName);
    }

    // 최적 템플릿 선택
    final selectedTemplate = _selectBestTemplate(
      suitableTemplates,
      emotionState,
      userContext,
    );

    // 응답 메시지 생성
    final responseMessage = selectedTemplate.generateMessage(
      userContext: userContext,
      emotionContext: {
        'intensity': emotionState.intensity.id,
        'confidence': emotionState.confidence.id,
        'trigger': customTrigger ?? emotionState.trigger ?? '',
      },
      userName: userName,
    );

    // 응답 메타데이터 구성
    return {
      'message': responseMessage,
      'sherpi/emotion': selectedTemplate.sherpiEmotion,
      'response_style': selectedTemplate.style.id,
      'template_id': selectedTemplate.templateId,
      'effectiveness_score': selectedTemplate.effectivenessScore,
      'emotion_alignment':
          _calculateEmotionAlignment(emotionState, selectedTemplate),
      'personalization_level': _calculatePersonalizationLevel(userContext),
      'adaptation_metadata': {
        'target_emotion': emotionState.type.id,
        'emotion_intensity': emotionState.intensity.id,
        'emotion_confidence': emotionState.confidence.id,
        'templates_considered': suitableTemplates.length,
        'user_context_richness': userContext.keys.length,
        'generation_timestamp': DateTime.now().toIso8601String(),
      },
    };
  }

  /// 🔍 적합한 템플릿 찾기
  static List<ResponseTemplate> _findSuitableTemplates(
    EmotionSnapshot emotionState,
    Map<String, dynamic> userContext,
    Map<String, dynamic> conversationContext,
  ) {
    final candidates = <ResponseTemplate>[];

    // 직접 매칭되는 템플릿들
    final directMatches = EmotionResponseTemplates.allTemplates
        .where((template) => template.targetEmotion == emotionState.type)
        .toList();

    candidates.addAll(directMatches);

    // 같은 카테고리의 템플릿들 (가중치 감소)
    if (candidates.length < _maxResponseOptions) {
      final categoryMatches = EmotionResponseTemplates.allTemplates
          .where((template) =>
              template.targetEmotion.category == emotionState.type.category &&
              template.targetEmotion != emotionState.type)
          .toList();

      candidates.addAll(categoryMatches);
    }

    // 효과성 점수로 필터링
    final filteredCandidates = candidates
        .where(
            (template) => template.effectivenessScore >= _minimumTemplateScore)
        .toList();

    return filteredCandidates;
  }

  /// 🎯 최적 템플릿 선택
  static ResponseTemplate _selectBestTemplate(
    List<ResponseTemplate> templates,
    EmotionSnapshot emotionState,
    Map<String, dynamic> userContext,
  ) {
    if (templates.length == 1) return templates.first;

    // 점수 계산
    final scoredTemplates = templates.map((template) {
      double score = template.effectivenessScore;

      // 감정 강도 일치도
      score += _calculateIntensityMatch(emotionState.intensity, template);

      // 사용자 선호도 (과거 피드백 기반)
      score += _calculateUserPreference(template, userContext);

      // 컨텍스트 적합성
      score += _calculateContextFit(template, userContext);

      return {'template': template, 'score': score};
    }).toList();

    // 점수 순으로 정렬
    scoredTemplates
        .sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return scoredTemplates.first['template'] as ResponseTemplate;
  }

  /// 💪 강도 일치도 계산
  static double _calculateIntensityMatch(
    EmotionIntensity intensity,
    ResponseTemplate template,
  ) {
    // 강한 감정에는 더 역동적인 스타일이 적합
    switch (intensity) {
      case EmotionIntensity.veryHigh:
      case EmotionIntensity.high:
        if (template.style == ResponseStyle.celebratory ||
            template.style == ResponseStyle.motivational ||
            template.style == ResponseStyle.empathetic) {
          return 0.2;
        }
        break;
      case EmotionIntensity.moderate:
        if (template.style == ResponseStyle.supportive ||
            template.style == ResponseStyle.encouraging ||
            template.style == ResponseStyle.thoughtful) {
          return 0.15;
        }
        break;
      case EmotionIntensity.low:
      case EmotionIntensity.veryLow:
        if (template.style == ResponseStyle.calming ||
            template.style == ResponseStyle.supportive) {
          return 0.1;
        }
        break;
    }

    return 0.0;
  }

  /// 👤 사용자 선호도 계산
  static double _calculateUserPreference(
    ResponseTemplate template,
    Map<String, dynamic> userContext,
  ) {
    // 과거 피드백 데이터가 있다면 활용
    final feedbackHistory =
        userContext['feedback_history'] as Map<String, dynamic>?;
    if (feedbackHistory == null) return 0.0;

    final stylePreferences =
        feedbackHistory[template.style.id] as Map<String, dynamic>?;
    if (stylePreferences == null) return 0.0;

    final averageRating = stylePreferences['average_rating'] as double? ?? 0.0;
    final feedbackCount = stylePreferences['count'] as int? ?? 0;

    // 피드백이 충분하고 평가가 좋다면 가중치 추가
    if (feedbackCount >= 3 && averageRating >= 4.0) {
      return 0.3;
    } else if (feedbackCount >= 1 && averageRating >= 3.5) {
      return 0.15;
    }

    return 0.0;
  }

  /// 🎯 컨텍스트 적합성 계산
  static double _calculateContextFit(
    ResponseTemplate template,
    Map<String, dynamic> userContext,
  ) {
    double score = 0.0;

    // 시간대별 적합성
    final currentHour = DateTime.now().hour;
    if (currentHour >= 22 || currentHour <= 6) {
      // 밤/새벽
      if (template.style == ResponseStyle.calming) score += 0.1;
    } else if (currentHour >= 6 && currentHour <= 10) {
      // 아침
      if (template.style == ResponseStyle.motivational ||
          template.style == ResponseStyle.encouraging) score += 0.1;
    }

    // 최근 활동 기반 적합성
    final recentActivity = userContext['recent_activity'] as String?;
    if (recentActivity != null) {
      switch (recentActivity) {
        case 'exercise':
          if (template.style == ResponseStyle.celebratory ||
              template.style == ResponseStyle.motivational) score += 0.15;
          break;
        case 'reading':
        case 'study':
          if (template.style == ResponseStyle.thoughtful ||
              template.style == ResponseStyle.supportive) score += 0.1;
          break;
        case 'meditation':
        case 'diary':
          if (template.style == ResponseStyle.calming ||
              template.style == ResponseStyle.empathetic) score += 0.1;
          break;
      }
    }

    return score;
  }

  /// 📊 감정 일치도 계산
  static double _calculateEmotionAlignment(
    EmotionSnapshot emotionState,
    ResponseTemplate template,
  ) {
    double alignment = 0.0;

    // 정확한 감정 매칭
    if (template.targetEmotion == emotionState.type) {
      alignment = 1.0;
    } else if (template.targetEmotion.category == emotionState.type.category) {
      alignment = 0.7;
    } else {
      alignment = 0.3;
    }

    // 신뢰도 보정
    alignment *= emotionState.confidence.value;

    return alignment.clamp(0.0, 1.0);
  }

  /// 🎯 개인화 수준 계산
  static double _calculatePersonalizationLevel(
      Map<String, dynamic> userContext) {
    double level = 0.0;

    // 사용자 이름이 있으면 기본 개인화
    if (userContext['user_name'] != null) level += 0.3;

    // 최근 활동 정보가 있으면 맞춤화 가능
    if (userContext['recent_activity'] != null) level += 0.2;
    if (userContext['recent_achievement'] != null) level += 0.2;

    // 피드백 히스토리가 있으면 고도화된 개인화
    if (userContext['feedback_history'] != null) level += 0.3;

    return level.clamp(0.0, 1.0);
  }

  /// 🔄 폴백 응답 생성
  static Map<String, dynamic> _generateFallbackResponse(
    EmotionSnapshot emotionState,
    Map<String, dynamic> userContext,
    String? userName,
  ) {
    // 기본 공감적 응답
    final fallbackMessages = [
      '지금 ${emotionState.type.displayName} 기분이시군요. 이해해요.',
      '${emotionState.type.emoji} 이런 감정을 느끼고 계시는군요.',
      '마음을 알아주는 사람이 있다는 걸 기억해주세요.',
      '어떤 감정이든 소중해요. 함께 이야기해봐요.',
    ];

    final random = Random();
    String message = fallbackMessages[random.nextInt(fallbackMessages.length)];

    if (userName != null && userName.isNotEmpty) {
      message = '$userName님, $message';
    }

    return {
      'message': message,
      'sherpi/emotion': SherpiEmotion.defaults,
      'response_style': ResponseStyle.empathetic.id,
      'template_id': 'fallback_empathetic',
      'effectiveness_score': 0.5,
      'emotion_alignment': 0.5,
      'personalization_level': userName != null ? 0.3 : 0.0,
      'adaptation_metadata': {
        'is_fallback': true,
        'target_emotion': emotionState.type.id,
        'generation_timestamp': DateTime.now().toIso8601String(),
      },
    };
  }

  /// 📊 다중 감정 대응 응답 생성
  ///
  /// 복합적인 감정 상태에 대한 통합적 응답
  static Map<String, dynamic> generateMultiEmotionResponse(
    List<EmotionSnapshot> emotionStates, {
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> conversationContext,
    String? userName,
  }) {
    if (emotionStates.isEmpty) {
      return _generateFallbackResponse(
        EmotionSnapshot(
          type: EmotionType.neutral,
          intensity: EmotionIntensity.moderate,
          confidence: EmotionConfidence.low,
          source: EmotionSource.textAnalysis,
          timestamp: DateTime.now(),
        ),
        userContext,
        userName,
      );
    }

    if (emotionStates.length == 1) {
      return generateEmotionAdaptiveResponse(
        emotionStates.first,
        userContext: userContext,
        conversationContext: conversationContext,
        userName: userName,
      );
    }

    // 주요 감정과 보조 감정 구분
    final primaryEmotion = emotionStates.first;
    final secondaryEmotions = emotionStates.skip(1).take(2).toList();

    // 복합 감정 인식 메시지
    final emotionNames =
        emotionStates.map((e) => e.type.displayName).take(3).join(', ');

    // 주요 감정 기반 응답 생성
    final primaryResponse = generateEmotionAdaptiveResponse(
      primaryEmotion,
      userContext: userContext,
      conversationContext: conversationContext,
      userName: userName,
    );

    // 복합 감정 대응 메시지로 보강
    String enhancedMessage = primaryResponse['message'] as String;

    if (secondaryEmotions.isNotEmpty) {
      enhancedMessage +=
          '\n\n복잡한 감정들($emotionNames)을 동시에 느끼고 계시는군요. 마음이 여러 갈래로 나뉘어 있으시는 것 같아요.';
    }

    return {
      ...primaryResponse,
      'message': enhancedMessage,
      'is_multi_emotion': true,
      'detected_emotions': emotionStates
          .map((e) => {
                'type': e.type.id,
                'intensity': e.intensity.id,
                'confidence': e.confidence.id,
              })
          .toList(),
      'emotion_complexity': emotionStates.length,
    };
  }

  /// 📈 응답 효과성 분석
  static Map<String, dynamic> analyzeResponseEffectiveness(
    Map<String, dynamic> response,
    EmotionSnapshot emotionState,
    Map<String, dynamic> userContext,
  ) {
    final emotionAlignment = response['emotion_alignment'] as double;
    final personalizationLevel = response['personalization_level'] as double;
    final effectivenessScore = response['effectiveness_score'] as double;

    // 전체 효과성 점수 계산
    final overallEffectiveness = (emotionAlignment * 0.4 +
        personalizationLevel * 0.3 +
        effectivenessScore * 0.3);

    // 개선 제안
    final improvements = <String>[];

    if (emotionAlignment < 0.7) {
      improvements.add('감정 매칭 정확도 향상 필요');
    }

    if (personalizationLevel < 0.5) {
      improvements.add('사용자 맞춤화 강화 필요');
    }

    if (effectivenessScore < 0.7) {
      improvements.add('템플릿 품질 개선 필요');
    }

    return {
      'overall_effectiveness': overallEffectiveness,
      'emotion_alignment': emotionAlignment,
      'personalization_level': personalizationLevel,
      'template_effectiveness': effectivenessScore,
      'improvement_suggestions': improvements,
      'quality_grade': _getQualityGrade(overallEffectiveness),
      'analysis_timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 🏆 품질 등급 계산
  static String _getQualityGrade(double effectiveness) {
    if (effectiveness >= 0.9) return 'A+';
    if (effectiveness >= 0.8) return 'A';
    if (effectiveness >= 0.7) return 'B+';
    if (effectiveness >= 0.6) return 'B';
    if (effectiveness >= 0.5) return 'C+';
    if (effectiveness >= 0.4) return 'C';
    return 'D';
  }
}
