import 'package:flutter/foundation.dart';
import '../../core/constants/sherpi_dialogues.dart';
import '../../core/constants/sherpi_emotions.dart';

/// 🚀 빠른 응답 옵션 모델
/// 
/// 사용자가 셰르피에게 빠르게 응답할 수 있는 선택지를 정의합니다.
@immutable
class QuickResponseOption {
  final String id;              // 고유 식별자
  final String text;            // 사용자에게 표시되는 텍스트
  final String? icon;           // 선택적 이모지 아이콘
  final String responseText;    // 실제 응답 텍스트
  final SherpiContext? triggerContext;  // 선택 시 발생할 새로운 컨텍스트
  final Map<String, dynamic>? metadata; // 추가 메타데이터
  final QuickResponseType type; // 응답 타입 (긍정, 부정, 질문 등)
  final bool isPersonalized;   // AI 개인화 응답인지 여부

  const QuickResponseOption({
    required this.id,
    required this.text,
    this.icon,
    required this.responseText,
    this.triggerContext,
    this.metadata,
    this.type = QuickResponseType.general,
    this.isPersonalized = false,
  });

  QuickResponseOption copyWith({
    String? id,
    String? text,
    String? icon,
    String? responseText,
    SherpiContext? triggerContext,
    Map<String, dynamic>? metadata,
    QuickResponseType? type,
    bool? isPersonalized,
  }) {
    return QuickResponseOption(
      id: id ?? this.id,
      text: text ?? this.text,
      icon: icon ?? this.icon,
      responseText: responseText ?? this.responseText,
      triggerContext: triggerContext ?? this.triggerContext,
      metadata: metadata ?? this.metadata,
      type: type ?? this.type,
      isPersonalized: isPersonalized ?? this.isPersonalized,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'icon': icon,
      'responseText': responseText,
      'triggerContext': triggerContext?.name,
      'metadata': metadata ?? {},
      'type': type.name,
      'isPersonalized': isPersonalized,
    };
  }

  factory QuickResponseOption.fromJson(Map<String, dynamic> json) {
    return QuickResponseOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      icon: json['icon'],
      responseText: json['responseText'] ?? '',
      triggerContext: json['triggerContext'] != null
          ? SherpiContext.values.firstWhere(
              (c) => c.name == json['triggerContext'],
              orElse: () => SherpiContext.general,
            )
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      type: QuickResponseType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => QuickResponseType.general,
      ),
      isPersonalized: json['isPersonalized'] ?? false,
    );
  }
}

/// 🎭 빠른 응답 타입 (UI 스타일링과 그룹화를 위한 분류)
enum QuickResponseType {
  /// 긍정적 응답 (고마워, 좋아, 최고야 등)
  positive('긍정', '💚'),
  
  /// 부정적/어려움 표현 (힘들어, 싫어, 어려워 등)
  negative('부정', '😔'),
  
  /// 질문/요청 (더 알려줘, 뭐해야해, 어떻게 등)
  inquiry('질문', '❓'),
  
  /// 감사/칭찬 응답 (고마워, 대단해, 멋져 등)
  appreciation('감사', '🙏'),
  
  /// 동기부여/격려 요청 (응원해줘, 힘내자, 더 해보자 등)
  motivation('격려', '💪'),
  
  /// 일반적 응답
  general('일반', '💬'),

  /// Phase 2: 추가된 개인화 응답 타입들
  
  /// 행동 지향적 응답 (더 하자, 계속하자, 시작하자 등)
  action('행동', '🚀'),
  
  /// 인정/확인 응답 (맞아, 그래, 동의해 등)
  acknowledgment('인정', '✅'),
  
  /// 성찰적 응답 (생각해볼게, 돌아보자, 깊이 생각 등)
  reflective('성찰', '🤔'),
  
  /// 감정적 응답 (기쁘다, 슬프다, 설렌다 등)
  emotional('감정', '❤️'),
  
  /// 사회적 응답 (나누자, 함께하자, 소통하자 등)
  social('소통', '👥'),
  
  /// 학습 지향적 응답 (배우자, 알아보자, 연구하자 등)
  learning('학습', '📚'),
  
  /// 호기심 응답 (궁금해, 더 알고 싶어, 탐구하자 등)
  curiosity('궁금', '🔍'),
  
  /// 축하/기념 응답 (축하해, 기념하자, 파티하자 등)
  celebratory('축하', '🎉'),
  
  /// 야심찬 응답 (도전하자, 더 높이, 최고가 되자 등)
  ambitious('야심', '🔥'),
  
  /// 자랑스러운 응답 (뿌듯해, 자랑스러워, 대단해 등)
  proud('자랑', '😊'),
  
  /// 전설적 응답 (레전드, 전설, 역사적 등)
  legendary('전설', '⭐');

  const QuickResponseType(this.displayName, this.emoji);
  
  final String displayName;
  final String emoji;
}

/// 📋 빠른 응답 템플릿
/// 
/// 각 SherpiContext에 대응하는 빠른 응답 옵션들의 템플릿을 정의합니다.
@immutable
class QuickResponseTemplate {
  final SherpiContext context;
  final List<QuickResponseOption> staticOptions;  // 정적 응답 옵션들
  final bool enableAIOptions;                    // AI 제안 옵션 활성화 여부
  final int maxOptions;                          // 최대 표시할 옵션 수
  final Duration showDuration;                   // 빠른 응답 표시 지속 시간

  const QuickResponseTemplate({
    required this.context,
    required this.staticOptions,
    this.enableAIOptions = true,
    this.maxOptions = 4,
    this.showDuration = const Duration(seconds: 8),
  });

  Map<String, dynamic> toJson() {
    return {
      'context': context.name,
      'staticOptions': staticOptions.map((o) => o.toJson()).toList(),
      'enableAIOptions': enableAIOptions,
      'maxOptions': maxOptions,
      'showDuration': showDuration.inMilliseconds,
    };
  }

  factory QuickResponseTemplate.fromJson(Map<String, dynamic> json) {
    return QuickResponseTemplate(
      context: SherpiContext.values.firstWhere(
        (c) => c.name == json['context'],
        orElse: () => SherpiContext.general,
      ),
      staticOptions: (json['staticOptions'] as List? ?? [])
          .map((o) => QuickResponseOption.fromJson(o))
          .toList(),
      enableAIOptions: json['enableAIOptions'] ?? true,
      maxOptions: json['maxOptions'] ?? 4,
      showDuration: Duration(milliseconds: json['showDuration'] ?? 8000),
    );
  }
}

/// 🎯 빠른 응답 템플릿 데이터베이스
/// 
/// 각 상황별로 미리 정의된 빠른 응답 옵션들을 제공합니다.
class QuickResponseTemplates {
  
  /// 모든 컨텍스트별 빠른 응답 템플릿들
  static final Map<SherpiContext, QuickResponseTemplate> _templates = {
    
    // 기본 상호작용
    SherpiContext.welcome: QuickResponseTemplate(
      context: SherpiContext.welcome,
      staticOptions: [
        QuickResponseOption(
          id: 'welcome_excited',
          text: '와! 신나!',
          icon: '🎉',
          responseText: '셰르피야 반가워! 정말 신나!',
          type: QuickResponseType.positive,
        ),
        QuickResponseOption(
          id: 'welcome_thanks',
          text: '고마워',
          icon: '🙏',
          responseText: '만나서 반가워, 고마워!',
          type: QuickResponseType.appreciation,
        ),
        QuickResponseOption(
          id: 'welcome_help',
          text: '뭘 도와줄 수 있어?',
          icon: '❓',
          responseText: '셰르피가 뭘 도와줄 수 있는지 알려줘',
          triggerContext: SherpiContext.guidance,
          type: QuickResponseType.inquiry,
        ),
        QuickResponseOption(
          id: 'welcome_start',
          text: '시작해보자!',
          icon: '🚀',
          responseText: '바로 시작해보자!',
          triggerContext: SherpiContext.guidance,
          type: QuickResponseType.motivation,
        ),
      ],
    ),
    
    // 운동 완료
    SherpiContext.exerciseComplete: QuickResponseTemplate(
      context: SherpiContext.exerciseComplete,
      staticOptions: [
        QuickResponseOption(
          id: 'exercise_thanks',
          text: '고마워!',
          icon: '🙏',
          responseText: '셰르피야 응원해줘서 고마워!',
          type: QuickResponseType.appreciation,
        ),
        QuickResponseOption(
          id: 'exercise_proud',
          text: '뿌듯해!',
          icon: '💪',
          responseText: '정말 뿌듯해! 운동이 이렇게 기분 좋을 줄 몰랐어',
          type: QuickResponseType.positive,
        ),
        QuickResponseOption(
          id: 'exercise_more',
          text: '더 열심히 할게!',
          icon: '🔥',
          responseText: '앞으로 더 열심히 운동할게!',
          triggerContext: SherpiContext.encouragement,
          type: QuickResponseType.motivation,
        ),
        QuickResponseOption(
          id: 'exercise_next',
          text: '다음 목표는?',
          icon: '🎯',
          responseText: '다음엔 어떤 운동 목표를 세우면 좋을까?',
          triggerContext: SherpiContext.guidance,
          type: QuickResponseType.inquiry,
        ),
      ],
    ),
    
    // 레벨업
    SherpiContext.levelUp: QuickResponseTemplate(
      context: SherpiContext.levelUp,
      staticOptions: [
        QuickResponseOption(
          id: 'levelup_awesome',
          text: '와 대박!',
          icon: '🎊',
          responseText: '레벨업이라니! 정말 대박이야!',
          type: QuickResponseType.positive,
        ),
        QuickResponseOption(
          id: 'levelup_share',
          text: '자랑하고 싶어!',
          icon: '📢',
          responseText: '친구들한테 자랑하고 싶어!',
          type: QuickResponseType.positive,
        ),
        QuickResponseOption(
          id: 'levelup_reward',
          text: '보상이 뭐야?',
          icon: '🎁',
          responseText: '레벨업 보상이 뭔지 궁금해!',
          triggerContext: SherpiContext.guidance,
          type: QuickResponseType.inquiry,
        ),
        QuickResponseOption(
          id: 'levelup_next',
          text: '다음 레벨 언제?',
          icon: '⬆️',
          responseText: '다음 레벨은 언제 오를 수 있을까?',
          triggerContext: SherpiContext.guidance,
          type: QuickResponseType.inquiry,
        ),
      ],
    ),
    
    // 격려 상황
    SherpiContext.encouragement: QuickResponseTemplate(
      context: SherpiContext.encouragement,
      staticOptions: [
        QuickResponseOption(
          id: 'encourage_thanks',
          text: '힘이 나네!',
          icon: '💝',
          responseText: '셰르피 말 들으니 정말 힘이 나!',
          type: QuickResponseType.positive,
        ),
        QuickResponseOption(
          id: 'encourage_try',
          text: '다시 해볼게!',
          icon: '💪',
          responseText: '그래, 다시 한 번 해보자!',
          type: QuickResponseType.motivation,
        ),
        QuickResponseOption(
          id: 'encourage_difficult',
          text: '그래도 힘들어',
          icon: '😔',
          responseText: '응원해줘서 고맙지만 여전히 힘들어',
          triggerContext: SherpiContext.encouragement,
          type: QuickResponseType.negative,
        ),
        QuickResponseOption(
          id: 'encourage_more',
          text: '더 응원해줘',
          icon: '🙏',
          responseText: '조금 더 응원해줄 수 있어?',
          triggerContext: SherpiContext.encouragement,
          type: QuickResponseType.motivation,
        ),
      ],
    ),
    
    // 공부 완료
    SherpiContext.studyComplete: QuickResponseTemplate(
      context: SherpiContext.studyComplete,
      staticOptions: [
        QuickResponseOption(
          id: 'study_learned',
          text: '많이 배웠어!',
          icon: '🧠',
          responseText: '오늘 정말 많이 배운 것 같아!',
          type: QuickResponseType.positive,
        ),
        QuickResponseOption(
          id: 'study_difficult',
          text: '어려웠어',
          icon: '😅',
          responseText: '생각보다 어려웠지만 해냈어',
          type: QuickResponseType.negative,
        ),
        QuickResponseOption(
          id: 'study_continue',
          text: '계속 공부할게!',
          icon: '📚',
          responseText: '이 기세로 계속 공부해볼게!',
          type: QuickResponseType.motivation,
        ),
        QuickResponseOption(
          id: 'study_next',
          text: '다음엔 뭘 공부해?',
          icon: '🤔',
          responseText: '다음엔 어떤 걸 공부하면 좋을까?',
          triggerContext: SherpiContext.guidance,
          type: QuickResponseType.inquiry,
        ),
      ],
    ),
    
    // 일반 상황
    SherpiContext.general: QuickResponseTemplate(
      context: SherpiContext.general,
      staticOptions: [
        QuickResponseOption(
          id: 'general_thanks',
          text: '고마워',
          icon: '😊',
          responseText: '셰르피야 고마워',
          type: QuickResponseType.appreciation,
        ),
        QuickResponseOption(
          id: 'general_help',
          text: '도와줘',
          icon: '🤝',
          responseText: '좀 도와줄 수 있어?',
          triggerContext: SherpiContext.guidance,
          type: QuickResponseType.inquiry,
        ),
        QuickResponseOption(
          id: 'general_cheer',
          text: '응원해줘',
          icon: '📣',
          responseText: '셰르피가 응원해주면 힘날 것 같아',
          triggerContext: SherpiContext.encouragement,
          type: QuickResponseType.motivation,
        ),
        QuickResponseOption(
          id: 'general_chat',
          text: '이야기해',
          icon: '💬',
          responseText: '셰르피와 재미있는 이야기를 해보고 싶어',
          type: QuickResponseType.general,
        ),
      ],
    ),
    
  };
  
  /// 특정 컨텍스트의 빠른 응답 템플릿 가져오기
  static QuickResponseTemplate? getTemplate(SherpiContext context) {
    return _templates[context];
  }
  
  /// 모든 템플릿 가져오기
  static Map<SherpiContext, QuickResponseTemplate> getAllTemplates() {
    return Map.unmodifiable(_templates);
  }
  
  /// 빠른 응답이 지원되는 컨텍스트인지 확인
  static bool isQuickResponseSupported(SherpiContext context) {
    return _templates.containsKey(context);
  }
  
  /// 개인화 설정을 반영한 빠른 응답 옵션들 생성
  static List<QuickResponseOption> getPersonalizedOptions(
    SherpiContext context,
    String userPreferredName,
    String sherpiNickname,
  ) {
    final template = getTemplate(context);
    if (template == null) return [];
    
    // 사용자 이름과 셰르피 별명을 반영한 개인화 응답 생성
    return template.staticOptions.map((option) {
      String personalizedText = option.text;
      String personalizedResponse = option.responseText;
      
      // 셰르피 별명으로 치환
      personalizedResponse = personalizedResponse.replaceAll('셰르피', sherpiNickname);
      
      return option.copyWith(
        responseText: personalizedResponse,
        isPersonalized: true,
      );
    }).toList();
  }
}