// lib/features/sherpi/chat/services/sherpi_chat_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:sherpa_app/core/ai/services/openai_service.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:sherpa_app/features/sherpi/chat/models/chat_message.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/features/quests/providers/quest_provider_v2.dart';
import 'package:sherpa_app/features/sherpi/relationship/providers/relationship_provider.dart';

/// 🤖 셰르피 채팅 서비스
///
/// OpenAI GPT-5를 활용한 실시간 대화 생성 서비스
/// Sherpa App 전체 맥락을 이해하고 자연스러운 대화를 제공합니다.
class SherpiChatService {
  final OpenAIService _openAIService = OpenAIService.instance;
  final Ref _ref;

  SherpiChatService(this._ref);

  /// 🎯 채팅 응답 생성 (GPT-5 활용)
  ///
  /// [conversationHistory] - 전체 대화 기록
  /// [userContext] - 사용자 입력 맥락
  /// [gameContext] - 게임 상태 정보
  ///
  /// Returns: AI 응답 텍스트 또는 null (실패 시)
  Future<String?> generateChatResponse({
    required List<ChatMessage> conversationHistory,
    required Map<String, dynamic> userContext,
    required Map<String, dynamic> gameContext,
  }) async {
    try {
      // 1. Sherpa App 맥락 수집
      final sherpaAppContext = await _buildSherpaAppContext();

      // 2. 시스템 프롬프트 생성
      final systemPrompt = _buildSystemPrompt(sherpaAppContext, gameContext);

      // 3. 대화 히스토리를 OpenAI 메시지 형식으로 변환
      final messages =
          _convertToOpenAIMessages(systemPrompt, conversationHistory);

      // 4. GPT-5 API 호출
      final response = await _openAIService.createConversation(
        messages: messages,
        temperature: 0.8,
        maxTokens: 500,
        topP: 0.95,
      );

      // 5. 응답 후처리
      if (response != null && response.isNotEmpty) {
        return _processResponse(response);
      }

      return null;
    } catch (e) {
      aiLogger.e('GPT-5 채팅 응답 생성 실패', error: e);
      return null;
    }
  }

  /// 📊 Sherpa App 맥락 수집
  ///
  /// 사용자 데이터, 퀘스트, 친밀도 등 앱 전반의 정보를 수집합니다.
  Future<Map<String, dynamic>> _buildSherpaAppContext() async {
    try {
      // Level 1: 사용자 기본 정보
      final user = _ref.read(globalUserProvider);

      // Level 2: 퀘스트 정보
      final questStateAsync = _ref.read(questProviderV2);
      final allQuests = questStateAsync.value ?? [];

      // Level 3: 셰르피 관계 정보
      final relationship = _ref.read(relationshipProvider);

      // 오늘 완료한 활동 수집
      final todayActivities = <String>[];
      final today = DateTime.now();

      // 운동 기록
      final todayExercise = user.dailyRecords.exerciseLogs.where((log) {
        return log.date.year == today.year &&
            log.date.month == today.month &&
            log.date.day == today.day;
      }).length;
      if (todayExercise > 0) {
        todayActivities.add('운동 $todayExercise회');
      }

      // 독서 기록
      final todayReading = user.dailyRecords.readingLogs.where((log) {
        return log.date.year == today.year &&
            log.date.month == today.month &&
            log.date.day == today.day;
      }).length;
      if (todayReading > 0) {
        todayActivities.add('독서 $todayReading회');
      }

      // 일기 기록
      final todayDiary = user.dailyRecords.diaryLogs.where((log) {
        return log.date.year == today.year &&
            log.date.month == today.month &&
            log.date.day == today.day;
      }).length;
      if (todayDiary > 0) {
        todayActivities.add('일기 $todayDiary회');
      }

      // 진행 중인 퀘스트 (데일리 + 위클리)
      final activeQuests = <String>[];
      for (final quest in allQuests) {
        if (!quest.isCompleted) {
          activeQuests.add(
              '${quest.title} (${quest.currentProgress}/${quest.targetProgress})');
        }
      }

      return {
        'userName': user.name,
        'currentLevel': user.level,
        'totalXP': user.experience,
        'todayActivities':
            todayActivities.isEmpty ? '없음' : todayActivities.join(', '),
        'activeQuests':
            activeQuests.isEmpty ? '없음' : activeQuests.take(3).join(', '),
        'intimacyLevel': relationship.intimacyLevel,
        'badgeCount':
            user.equippedBadgeIds.length + user.ownedBadgeIds.length,
      };
    } catch (e) {
      aiLogger.e('Sherpa App 맥락 수집 실패', error: e);
      // 최소한의 맥락 반환
      return {
        'userName': '친구',
        'currentLevel': 1,
        'todayActivities': '정보 없음',
        'activeQuests': '정보 없음',
        'intimacyLevel': 1,
      };
    }
  }

  /// 📝 시스템 프롬프트 생성
  ///
  /// 셰르피의 역할과 Sherpa App 맥락을 정의합니다.
  String _buildSystemPrompt(
    Map<String, dynamic> sherpaAppContext,
    Map<String, dynamic> gameContext,
  ) {
    final userName = sherpaAppContext['userName'] ?? '친구';
    final level = sherpaAppContext['currentLevel'] ?? 1;
    final todayActivities = sherpaAppContext['todayActivities'] ?? '없음';
    final activeQuests = sherpaAppContext['activeQuests'] ?? '없음';
    final intimacyLevel = sherpaAppContext['intimacyLevel'] ?? 1;

    return '''당신은 '셰르피'입니다. Sherpa App에서 $userName님의 성장을 함께하는 AI 동반자입니다.

🎯 당신의 역할:
1. $userName님의 일상, 활동, 목표에 대한 대화 상대
2. Sherpa App의 기능 안내자 (등반하기, 퀘스트, 활동 기록)
3. 따뜻하고 공감적이며 격려하는 친구

🏔️ Sherpa App 핵심 개념:
Sherpa App은 "산 등반"을 통해 개인 성장을 시각화하는 RPG 게임이에요.
- 일상 활동 → 능력치 증가 → 등반력 상승 → 더 높은 산 정복
- 6가지 활동: 운동, 독서, 일기, 집중, 영화, 모임
- 5가지 능력치: 체력, 지식, 기술, 의지, 사교성
- 등반력 = (레벨 × 10 + 칭호 보너스) × (1 + 능력치%) × (1 + 뱃지%)

📊 등반하기 시스템:
- $userName님은 현재 "등반력"으로 산을 정복해요
- 각 산은 난이도(레벨 1~150)와 요구 등반력이 있어요
- 등반 성공 확률 = 사용자 등반력 vs 산 요구 등반력
- 등반은 실시간으로 진행되며 몇 시간이 걸려요
- 성공 시: 포인트, XP, 뱃지 획득 / 실패 시: 재도전 가능

🎮 능력치 시스템 (RPG 스탯):
1. **체력** - 운동으로 증가, 신체적 강인함
2. **지식** - 독서로 증가, 정신적 깊이
3. **기술** - 운동/집중으로 증가, 실행력
4. **의지** - 모든 활동으로 증가, 목표 달성력
5. **사교성** - 모임으로 증가, 인간관계 능력
→ 능력치가 높을수록 등반력이 증가해요!

🏅 뱃지 시스템:
- $userName님은 뱃지를 장착해 등반력을 강화할 수 있어요
- 각 뱃지는 특정 능력치 보너스(%)를 제공해요
- 장착 슬롯은 제한되어 있어 전략적 선택이 필요해요

🎯 퀘스트 시스템:
- **데일리 퀘스트**: 매일 자동 생성되는 목표 (활동 패턴 기반)
- **위클리 퀘스트**: 일주일 단위의 도전적인 목표
- **프리미엄 퀘스트**: 향상된 보상의 특별 목표
- 퀘스트 완료 시: 포인트, XP, 뱃지 등 보상 획득

💎 포인트 경제:
- 포인트로 뱃지 구매, 능력치 강화, 프리미엄 기능 사용
- 활동 완료, 퀘스트 달성, 등반 성공으로 포인트 획득

📊 $userName님의 현재 상태:
- 레벨: $level
- 오늘 활동: $todayActivities
- 진행 중인 퀘스트: $activeQuests
- 셰르피와의 친밀도: 레벨 $intimacyLevel

💬 대화 원칙:
1. **말투**: 반드시 친구처럼 편한 존댓말 사용 ("~요", "~세요" 형태)
   - ✅ 좋은 예: "반가워요!", "오늘 어떠셨어요?", "함께해봐요!", "응원할게요!"
   - ❌ 나쁜 예: "반가워!", "오늘 어땠어?", "함께해봐!", "응원할게!" (반말 금지)
2. $userName님을 이름으로 친근하게 부르세요
3. 2-4문장으로 간결하게 답변하세요
4. 이모지는 1-2개만 사용하세요
5. $userName님의 현재 상태를 고려한 맞춤형 대화를 하세요
6. 궁금한 것에는 명확히 답하고, 일상 대화도 자연스럽게 나누세요
7. **등반하기 시스템 질문 시**: 위의 "등반하기 시스템" 정보를 바탕으로 설명하세요

🚫 금지사항:
- 반말 사용 (무조건 존댓말)
- 과도하게 격식 차린 표현 ("~입니다", "~하십시오" 등)
- 부정적이거나 비판적인 표현
- 지나치게 긴 설명
- 민감한 개인정보 요구
- Sherpa App 핵심 개념을 잘못 설명하는 것''';
  }

  /// 🔄 대화 히스토리를 OpenAI 메시지 형식으로 변환
  ///
  /// 최근 20개 메시지만 유지하여 토큰 비용 최적화
  List<ChatCompletionMessage> _convertToOpenAIMessages(
    String systemPrompt,
    List<ChatMessage> conversationHistory,
  ) {
    final messages = <ChatCompletionMessage>[
      // 시스템 프롬프트
      ChatCompletionMessage.system(content: systemPrompt),
    ];

    // 최근 20개 메시지만 선택
    final recentMessages = conversationHistory.length > 20
        ? conversationHistory.sublist(conversationHistory.length - 20)
        : conversationHistory;

    // 사용자/셰르피 메시지만 포함
    for (final message in recentMessages) {
      if (message.sender == MessageSender.user) {
        messages.add(ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(message.content),
        ));
      } else if (message.sender == MessageSender.sherpi) {
        messages.add(ChatCompletionMessage.assistant(
          content: message.content,
        ));
      }
    }

    return messages;
  }

  /// ✨ 응답 후처리
  ///
  /// 부적절한 표현 필터링, 길이 제한, 이모지 정규화
  String _processResponse(String response) {
    String processed = response.trim();

    // 1. 길이 제한 (200자)
    if (processed.length > 200) {
      processed = processed.substring(0, 197) + '...';
    }

    // 2. 부적절한 표현 필터링
    final inappropriatePatterns = [
      '죽',
      '자살',
      '욕설',
      '혐오',
    ];
    for (final pattern in inappropriatePatterns) {
      if (processed.contains(pattern)) {
        aiLogger.w('부적절한 표현 감지: $pattern');
        return '죄송해요, 더 나은 답변을 드리지 못했네요. 다시 질문해주시겠어요?';
      }
    }

    // 3. 이모지 정규화 (최대 3개)
    final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
        unicode: true);
    final emojiMatches = emojiRegex.allMatches(processed);
    if (emojiMatches.length > 3) {
      // 앞에서 3개만 유지
      int count = 0;
      processed = processed.replaceAllMapped(emojiRegex, (match) {
        count++;
        return count <= 3 ? match.group(0)! : '';
      });
    }

    return processed;
  }
}
