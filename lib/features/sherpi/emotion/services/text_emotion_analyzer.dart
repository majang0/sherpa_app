// 📝 텍스트 기반 감정 분석 엔진
// 
// 사용자의 텍스트 입력을 분석하여 감정 상태를 추론하는 시스템

import 'dart:math';
import '../models/emotion_state_model.dart';

/// 📊 감정 키워드 사전
class EmotionKeywordDictionary {
  /// 😊 긍정적 감정 키워드들
  static const Map<EmotionType, List<String>> positiveKeywords = {
    EmotionType.joy: [
      '기쁘', '즐거', '행복', '신나', '웃', '좋아', '사랑', '완벽', '최고', '축하',
      '성공', '달성', '이뤘', '만족', '뿌듯', '감동', '환상적', '멋져', '훌륭', '대단해',
      '야호', '와우', '우와', '헤헤', '히히', '하하', '크크', '꺄악', '예스', 'yes',
      '파이팅', '화이팅', '굿', 'good', '나이스', 'nice', '쩐다', '죽인다'
    ],
    
    EmotionType.excitement: [
      '흥분', '두근두근', '설레', '기대', '떨려', '신기', '와', '대박', '진짜',
      '장난', '미쳤', '완전', '개', '엄청', '초', '슈퍼', '울트라', '하이퍼',
      '짱', '킹', '레전드', '갓', '끝내주', '장관', '압도적', '환상', '무한', '극강'
    ],
    
    EmotionType.satisfaction: [
      '만족', '충분', '괜찮', '좋', '알맞', '적당', '편안', '안락', '평화', '고마워',
      '감사', 'ㄳ', '고맙', '다행', '천만다행', '휴', '숨통', '여유', '느긋', '차분',
      '순조', '원활', '매끄럽', '부드럽', '자연스럽', '조화', '균형', '안정', '확실', '믿음직'
    ],
    
    EmotionType.pride: [
      '자랑', '뿌듯', '자부심', '당당', '떳떳', '자신감', '확신', '자신', '내가', '우리가',
      '해냈', '성취', '승리', '이겼', '앞서', '최고', '일등', '뛰어나', '우수', '탁월',
      '재능', '능력', '실력', '역량', '잠재력', '가능성', '천재', '영재', '엘리트', '프로'
    ],
    
    EmotionType.gratitude: [
      '감사', '고마워', '고맙', 'ㄳ', '땡큐', 'thank', '은혜', '도움', '배려', '챙겨줘',
      '신경써줘', '아껴줘', '소중', '값진', '귀한', '의미있', '보람', '뜻깊', '영광',
      '축복', '운이 좋', '다행', '복받을', '천사', '구원', '도우미', '조력자', '든든', '믿음직'
    ],
    
    EmotionType.hope: [
      '희망', '기대', '바라', '원해', '되길', '하고 싶', '꿈꾸', '소망', '염원', '간절',
      '꼭', '반드시', '무조건', '절대', '분명', '틀림없', '확실히', '가능', '할 수 있',
      '이뤄질', '성공할', '잘 될', '좋아질', '나아질', '개선될', '발전할', '성장할', '향상될', '업그레이드'
    ],
    
    EmotionType.love: [
      '사랑', '좋아해', '아껴', '아끼', '소중', '귀여워', '예뻐', '멋져', '매력적',
      '설레', '반해', '홀린', '빠져', '중독', '미치겠', '죽겠', '녹아',
      '달콤', '포근', '따뜻', '부드러워', '상냥', '다정', '친근', '친밀', '애정', '애착',
      '연인', '사랑하는', '내 사람', '가족', '친구', '동료', '파트너', '동반자', '소울메이트', '운명'
    ]
  };
  
  /// 😢 부정적 감정 키워드들
  static const Map<EmotionType, List<String>> negativeKeywords = {
    EmotionType.sadness: [
      '슬퍼', '울어', '우울', '눈물', '흐흑', 'ㅠㅠ', 'ㅜㅜ', '엉엉', '서러워', '애달',
      '가슴 아파', '마음 아파', '쓸쓸', '적적', '허전', '공허', '막막', '암담', '절망',
      '힘들', '고단', '지쳐', '피곤', '괴로워', '답답', '막혀', '갑갑', '숨막혀', '질식'
    ],
    
    EmotionType.anger: [
      '화나', '짜증', '분노', '열 받', '빡쳐', '열불', '개빡', '미치겠', '죽겠',
      '싫어', '그만해', '제발', '아 진짜', '제대로', '정말', '완전', '개', '존나',
      '병신', '바보', '멍청', '짜증나', '신경쓰여', '거슬려', '못참겠', '한계', '폭발', '터져'
    ],
    
    EmotionType.frustration: [
      '답답해', '막막해', '안 돼', '왜', '도대체', '뭐야', '이상해', '말도 안', '황당',
      '어이없', '기가 막혀', '어처구니', '망했', '끝났', '안 풀려', '꼬여', '복잡',
      '문제', '고민', '걱정', '스트레스', '부담', '압박', '조급', '불안', '초조', '안절부절'
    ],
    
    EmotionType.anxiety: [
      '불안', '걱정', '두려워', '무서워', '떨려', '긴장', '조마조마', '초조', '조급',
      '안절부절', '가슴 졸여', '마음 졸여', '심장이', '떨림', '후들후들', '오들오들',
      '혹시', '만약에', '괜찮을까', '될까', '어떡하지', '어쩌지', '망하면', '실패하면', '잘못되면', '큰일'
    ],
    
    EmotionType.disappointment: [
      '실망', '아쉬워', '아깝', '허무', '헛수고', '소용없', '의미없', '가치없',
      '기대했는데', '믿었는데', '생각과 달라', '예상과 달라', '뻔해', '뻔한',
      '그냥 그래', '별로', '시시해', '재미없', '밋밋', '단조로워', '지루해', '똑같아', '변화없', '진전없'
    ],
    
    EmotionType.guilt: [
      '미안해', '죄송', '잘못했', '실수', '후회', '반성', '자책', '부끄러워', '죄책감',
      '내 탓', '내가 잘못', '내 때문', '폐 끼쳐', '민폐', '짐', '부담', '걱정 끼쳐',
      '용서해', '이해해', '너무했', '심했', '과했', '지나쳤', '넘었', '선 넘', '어겨', '위반'
    ],
    
    EmotionType.loneliness: [
      '외로워', '혼자', '쓸쓸', '적적', '고독', '허전', '빈', '텅 빈', '공허',
      '아무도', '없어', '떠나', '버려', '혼밥', '혼술', '혼영', '솔로', '혼자서',
      '같이', '함께', '누군가', '사람', '친구', '연인', '가족', '동료', '그리워', '보고 싶'
    ],
    
    EmotionType.stress: [
      '스트레스', '압박', '부담', '중압감', '짓눌려', '숨막혀', '터질 것 같', '한계',
      '못 견디겠', '참을 수 없', '견딜 수 없', '미치겠', '돌겠', '폭발할 것 같',
      '바빠', '급해', '서둘러', '촉박', '시간 없', '여유 없', '쫓겨', '밀려', '쌓여', '몰려'
    ]
  };
  
  /// 😐 중립적 감정 키워드들
  static const Map<EmotionType, List<String>> neutralKeywords = {
    EmotionType.calm: [
      '평온', '고요', '차분', '평화', '안정', '잔잔', '고른', '일정', '규칙적',
      '편안', '느긋', '여유', '천천히', '서두르지', '급하지', '괜찮아', '문제없어',
      '그럭저럭', '무난', '적당', '보통', '일반적', '평범', '자연스럽', '순조', '원활', '매끄럽'
    ],
    
    EmotionType.focused: [
      '집중', '몰입', '전념', '매진', '열중', '빠져', '푹 빠져', '깊이',
      '진지', '신중', '신경써', '정성스럽게', '꼼꼼히', '세심하게', '주의깊게',
      '목표', '계획', '체계적', '단계적', '순서대로', '차근차근', '하나씩', '착실히', '꾸준히', '지속적'
    ],
    
    EmotionType.tired: [
      '피곤', '지쳐', '힘들어', '녹초', '축 늘어져', '기운 없', '에너지 없', '무기력',
      '졸려', '잠와', '잠이', '휴식', '쉬고 싶', '쉬어야', '잠깐 쉬', '숨 고르',
      '컨디션', '몸이', '체력', '기력', '체중', '무겁', '둔해', '느려', '더뎌', '늦어'
    ],
    
    EmotionType.bored: [
      '지루해', '심심해', '재미없', '밋밋', '단조', '똑같', '반복', '매일',
      '뻔해', '예상', '새로움 없', '변화 없', '진전 없', '발전 없', '향상 없',
      '할 게 없', '딱히', '특별히', '굳이', '별로', '그냥', '어쩐지', '왠지', '그럴듯', '적당히'
    ],
    
    EmotionType.curious: [
      '궁금해', '호기심', '신기해', '관심', '흥미', '재미있어 보여', '알고 싶어',
      '왜', '어떻게', '뭐야', '뭔지', '어떤 건지', '무슨', '어디서', '언제', '누가',
      '탐구', '연구', '조사', '검토', '확인', '알아보', '찾아보', '검색', '질문', '문의'
    ]
  };
  
  /// 🤔 복합/혼재 감정 키워드들
  static const Map<EmotionType, List<String>> mixedKeywords = {
    EmotionType.bittersweet: [
      '씁쓸', '아이러니', '묘해', '복잡해', '미묘해', '애매해', '어정쩡',
      '좋기도 싫기도', '기쁘기도 슬프기도', '웃기면서도 서글퍼',
      '그리우면서도', '소중하지만', '감사하지만', '행복하지만', '다행이지만',
      '한편으로는', '다른 한편으로는', '그러면서도', '그럼에도', '하지만', '그런데'
    ],
    
    EmotionType.overwhelmed: [
      '압도', '벅차', '감당 안 돼', '너무 많아', '한꺼번에', '몰려와', '쏟아져',
      '어찌할 바', '갈피를', '정신 없', '멍해', '멘붕', '혼란', '복잡',
      '처리 못 하겠', '소화 못 하겠', '받아들이기', '이해하기', '적응하기', '따라가기'
    ],
    
    EmotionType.conflicted: [
      '갈등', '딜레마', '모순', '선택', '결정', '고민', '망설여', '주저',
      'A냐 B냐', '이거냐 저거냐', '해야 하나 말아야 하나',
      '맞는 건지', '틀렸나', '확신이', '확신 없', '불확실', '모호', '애매',
      '어떻게 해야', '뭘 해야', '무엇이 옳은지', '정답이', '해답이'
    ]
  };
  
  /// 🔍 모든 키워드 사전 통합
  static Map<EmotionType, List<String>> get allKeywords {
    final combined = <EmotionType, List<String>>{};
    
    for (final entry in positiveKeywords.entries) {
      combined[entry.key] = entry.value;
    }
    
    for (final entry in negativeKeywords.entries) {
      combined[entry.key] = entry.value;
    }
    
    for (final entry in neutralKeywords.entries) {
      combined[entry.key] = entry.value;
    }
    
    for (final entry in mixedKeywords.entries) {
      combined[entry.key] = entry.value;
    }
    
    return combined;
  }
}

/// 📝 텍스트 감정 분석기
class TextEmotionAnalyzer {
  static const double _minimumConfidence = 0.3;
  static const int _minimumTextLength = 3;
  
  /// 🎯 메인 분석 함수
  /// 
  /// 텍스트를 분석하여 가장 가능성 높은 감정 상태를 반환
  static EmotionSnapshot analyzeText(
    String text, {
    Map<String, dynamic> context = const {},
    String? trigger,
  }) {
    // 기본 검증
    if (text.trim().length < _minimumTextLength) {
      return EmotionSnapshot(
        type: EmotionType.neutral,
        intensity: EmotionIntensity.veryLow,
        confidence: EmotionConfidence.veryLow,
        source: EmotionSource.textAnalysis,
        timestamp: DateTime.now(),
        context: context,
        trigger: trigger,
        note: '텍스트가 너무 짧음',
      );
    }
    
    // 텍스트 전처리
    final processedText = _preprocessText(text);
    
    // 키워드 기반 감정 점수 계산
    final emotionScores = _calculateEmotionScores(processedText);
    
    // 텍스트 패턴 분석
    final patternAnalysis = _analyzeTextPatterns(processedText);
    
    // 감정 강도 분석
    final intensity = _calculateIntensity(processedText, emotionScores);
    
    // 최종 감정 결정
    final dominantEmotion = _selectDominantEmotion(emotionScores, patternAnalysis);
    
    // 신뢰도 계산
    final confidence = _calculateConfidence(
      emotionScores,
      patternAnalysis,
      processedText.length,
    );
    
    return EmotionSnapshot(
      type: dominantEmotion,
      intensity: intensity,
      confidence: confidence,
      source: EmotionSource.textAnalysis,
      timestamp: DateTime.now(),
      context: {
        ...context,
        'text_length': text.length,
        'processed_length': processedText.length,
        'emotion_scores': emotionScores.map((k, v) => MapEntry(k.id, v)),
        'pattern_analysis': patternAnalysis,
      },
      trigger: trigger,
      note: '텍스트 분석 기반 감정 추론',
    );
  }
  
  /// 🔤 텍스트 전처리
  static String _preprocessText(String text) {
    return text
        .toLowerCase() // 소문자로 변환
        .replaceAll(RegExp(r'[^\w\sㄱ-ㅎㅏ-ㅣ가-힣]'), '') // 특수문자 제거
        .replaceAll(RegExp(r'\s+'), ' ') // 여러 공백을 하나로
        .trim();
  }
  
  /// 📊 감정별 점수 계산
  static Map<EmotionType, double> _calculateEmotionScores(String text) {
    final scores = <EmotionType, double>{};
    
    // 모든 감정 타입에 대해 점수 초기화
    for (final emotionType in EmotionType.values) {
      scores[emotionType] = 0.0;
    }
    
    // 키워드 매칭으로 점수 계산
    for (final entry in EmotionKeywordDictionary.allKeywords.entries) {
      final emotionType = entry.key;
      final keywords = entry.value;
      
      double score = 0.0;
      for (final keyword in keywords) {
        final matches = RegExp(keyword).allMatches(text).length;
        if (matches > 0) {
          // 키워드 길이와 빈도에 따른 가중치
          final weight = (keyword.length / 10.0).clamp(0.1, 2.0);
          score += matches * weight;
        }
      }
      
      scores[emotionType] = score;
    }
    
    return scores;
  }
  
  /// 🔍 텍스트 패턴 분석
  static Map<String, dynamic> _analyzeTextPatterns(String text) {
    return {
      // 감탄사 분석
      'exclamations': RegExp(r'[!]{1,}').allMatches(text).length,
      'question_marks': RegExp(r'[?]{1,}').allMatches(text).length,
      
      // 이모지/이모티콘 분석 (간단한 패턴)
      'positive_emoticons': RegExp(r'[ㅎㅋㅠㅜ]{2,}|하하|헤헤|히히').allMatches(text).length,
      'negative_emoticons': RegExp(r'ㅠㅠ|ㅜㅜ|엉엉|흑흑').allMatches(text).length,
      
      // 강조 표현
      'emphasis': RegExp(r'진짜|정말|완전|엄청|너무|아주|매우|굉장히|정말로').allMatches(text).length,
      'repetition': RegExp(r'(.)\1{2,}').allMatches(text).length,
      
      // 부정 표현
      'negation': RegExp(r'안|못|없|아니|싫|반대|거부|거절|아닌').allMatches(text).length,
      
      // 문장 특성
      'sentence_length': text.split(' ').length,
      'avg_word_length': text.isNotEmpty 
          ? text.replaceAll(' ', '').length / text.split(' ').length 
          : 0.0,
    };
  }
  
  /// 💪 감정 강도 계산
  static EmotionIntensity _calculateIntensity(
    String text,
    Map<EmotionType, double> emotionScores,
  ) {
    // 최대 감정 점수
    final maxScore = emotionScores.values.fold(0.0, (a, b) => a > b ? a : b);
    
    // 강조 표현 분석
    final emphasisCount = RegExp(r'진짜|정말|완전|엄청|너무|아주|매우|굉장히|대박|미친').allMatches(text).length;
    final exclamationCount = RegExp(r'[!]{1,}').allMatches(text).length;
    final repetitionCount = RegExp(r'(.)\1{2,}').allMatches(text).length;
    
    // 강도 점수 계산
    double intensityScore = maxScore / 10.0; // 기본 점수 정규화
    intensityScore += emphasisCount * 0.1; // 강조 표현 가중치
    intensityScore += exclamationCount * 0.05; // 감탄사 가중치
    intensityScore += repetitionCount * 0.03; // 반복 표현 가중치
    
    // 강도 레벨 결정
    return EmotionIntensity.fromValue(intensityScore.clamp(0.0, 1.0));
  }
  
  /// 🎯 주요 감정 선택
  static EmotionType _selectDominantEmotion(
    Map<EmotionType, double> scores,
    Map<String, dynamic> patterns,
  ) {
    // 점수가 모두 낮으면 중립 감정
    final maxScore = scores.values.fold(0.0, (a, b) => a > b ? a : b);
    if (maxScore < 1.0) {
      return EmotionType.neutral;
    }
    
    // 최고 점수의 감정들 찾기
    final topEmotions = scores.entries
        .where((entry) => entry.value == maxScore)
        .map((entry) => entry.key)
        .toList();
    
    // 동점일 경우 패턴 분석으로 결정
    if (topEmotions.length > 1) {
      return _resolveEmotionTie(topEmotions, patterns);
    }
    
    return topEmotions.first;
  }
  
  /// ⚖️ 감정 동점 해결
  static EmotionType _resolveEmotionTie(
    List<EmotionType> emotions,
    Map<String, dynamic> patterns,
  ) {
    // 긍정적 패턴이 많으면 긍정 감정 우선
    if (patterns['positive_emoticons'] > patterns['negative_emoticons']) {
      final positiveEmotions = emotions.where((e) => e.isPositive).toList();
      if (positiveEmotions.isNotEmpty) return positiveEmotions.first;
    }
    
    // 부정적 패턴이 많으면 부정 감정 우선
    if (patterns['negative_emoticons'] > patterns['positive_emoticons']) {
      final negativeEmotions = emotions.where((e) => e.isNegative).toList();
      if (negativeEmotions.isNotEmpty) return negativeEmotions.first;
    }
    
    // 감탄사가 많으면 흥분/기쁨 우선
    if (patterns['exclamations'] > 2) {
      if (emotions.contains(EmotionType.excitement)) return EmotionType.excitement;
      if (emotions.contains(EmotionType.joy)) return EmotionType.joy;
    }
    
    // 질문이 많으면 호기심/불안 우선
    if (patterns['question_marks'] > 1) {
      if (emotions.contains(EmotionType.curious)) return EmotionType.curious;
      if (emotions.contains(EmotionType.anxiety)) return EmotionType.anxiety;
    }
    
    // 기본적으로 첫 번째 감정 선택
    return emotions.first;
  }
  
  /// 📈 신뢰도 계산
  static EmotionConfidence _calculateConfidence(
    Map<EmotionType, double> scores,
    Map<String, dynamic> patterns,
    int textLength,
  ) {
    final maxScore = scores.values.fold(0.0, (a, b) => a > b ? a : b);
    final totalScore = scores.values.fold(0.0, (a, b) => a + b);
    
    // 기본 신뢰도 (최대 점수 비율)
    double confidence = totalScore > 0 ? maxScore / totalScore : 0.0;
    
    // 텍스트 길이 보정 (긴 텍스트일수록 신뢰도 증가)
    final lengthBonus = (textLength / 100.0).clamp(0.0, 0.3);
    confidence += lengthBonus;
    
    // 패턴 다양성 보정 (여러 패턴이 일치할수록 신뢰도 증가)
    final patternCount = patterns.values
        .where((value) => value is int && value > 0)
        .length;
    final patternBonus = (patternCount / 10.0).clamp(0.0, 0.2);
    confidence += patternBonus;
    
    // 강한 감정 표현 보정
    if (patterns['emphasis'] > 0 || patterns['exclamations'] > 0) {
      confidence += 0.1;
    }
    
    return EmotionConfidence.fromValue(confidence.clamp(0.0, 1.0));
  }
  
  /// 📊 다중 감정 분석 (복합 감정 지원)
  /// 
  /// 하나의 텍스트에서 여러 감정을 동시에 감지
  static List<EmotionSnapshot> analyzeMultipleEmotions(
    String text, {
    int maxEmotions = 3,
    double minimumScore = 1.0,
    Map<String, dynamic> context = const {},
    String? trigger,
  }) {
    if (text.trim().length < _minimumTextLength) {
      return [];
    }
    
    final processedText = _preprocessText(text);
    final emotionScores = _calculateEmotionScores(processedText);
    final patternAnalysis = _analyzeTextPatterns(processedText);
    
    // 점수 순으로 정렬
    final sortedEmotions = emotionScores.entries
        .where((entry) => entry.value >= minimumScore)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final results = <EmotionSnapshot>[];
    
    // 상위 감정들을 스냅샷으로 변환
    for (int i = 0; i < min(maxEmotions, sortedEmotions.length); i++) {
      final emotionEntry = sortedEmotions[i];
      final emotionType = emotionEntry.key;
      final score = emotionEntry.value;
      
      // 순위에 따른 신뢰도 조정
      final rankPenalty = i * 0.1;
      final baseConfidence = _calculateConfidence(
        {emotionType: score},
        patternAnalysis,
        processedText.length,
      );
      
      final adjustedConfidence = EmotionConfidence.fromValue(
        (baseConfidence.value - rankPenalty).clamp(0.0, 1.0),
      );
      
      if (adjustedConfidence.value >= _minimumConfidence) {
        results.add(EmotionSnapshot(
          type: emotionType,
          intensity: _calculateIntensity(processedText, {emotionType: score}),
          confidence: adjustedConfidence,
          source: EmotionSource.textAnalysis,
          timestamp: DateTime.now(),
          context: {
            ...context,
            'emotion_rank': i + 1,
            'emotion_score': score,
            'total_emotions_detected': sortedEmotions.length,
          },
          trigger: trigger,
          note: '다중 감정 분석 결과 #${i + 1}',
        ));
      }
    }
    
    return results;
  }
  
  /// 🔍 감정 키워드 추출
  /// 
  /// 텍스트에서 감정을 유발한 구체적인 키워드들을 추출
  static Map<EmotionType, List<String>> extractEmotionKeywords(String text) {
    final processedText = _preprocessText(text);
    final result = <EmotionType, List<String>>{};
    
    for (final entry in EmotionKeywordDictionary.allKeywords.entries) {
      final emotionType = entry.key;
      final keywords = entry.value;
      final foundKeywords = <String>[];
      
      for (final keyword in keywords) {
        if (processedText.contains(keyword)) {
          foundKeywords.add(keyword);
        }
      }
      
      if (foundKeywords.isNotEmpty) {
        result[emotionType] = foundKeywords;
      }
    }
    
    return result;
  }
  
  /// ✨ 감정 분석 요약 정보
  static Map<String, dynamic> getAnalysisSummary(String text) {
    final snapshot = analyzeText(text);
    final keywords = extractEmotionKeywords(text);
    final multipleEmotions = analyzeMultipleEmotions(text);
    
    return {
      'primary_emotion': {
        'type': snapshot.type.id,
        'display_name': snapshot.type.displayName,
        'category': snapshot.type.category.id,
        'intensity': snapshot.intensity.id,
        'confidence': snapshot.confidence.id,
        'emoji': snapshot.type.emoji,
      },
      'emotion_score': snapshot.emotionScore,
      'detected_keywords': keywords.map(
        (k, v) => MapEntry(k.id, v),
      ),
      'multiple_emotions': multipleEmotions.map((e) => {
        'type': e.type.id,
        'intensity': e.intensity.id,
        'confidence': e.confidence.id,
      }).toList(),
      'analysis_metadata': snapshot.context,
      'timestamp': snapshot.timestamp.toIso8601String(),
    };
  }
}