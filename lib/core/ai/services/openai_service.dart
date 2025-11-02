// lib/core/ai/services/openai_service.dart

import 'dart:async';
import 'dart:io';
import 'package:openai_dart/openai_dart.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';

/// 🧠 OpenAI GPT-5 범용 서비스
///
/// OpenAI API 클라이언트를 캡슐화한 범용 서비스
/// 모든 feature에서 재사용 가능한 인프라 레이어
class OpenAIService {
  late final OpenAIClient _client;
  static OpenAIService? _instance;

  /// Singleton 인스턴스 반환
  static OpenAIService get instance {
    _instance ??= OpenAIService._internal();
    return _instance!;
  }

  /// Private 생성자
  OpenAIService._internal() {
    try {
      final apiKey = ApiConfig.openAIApiKey;

      _client = OpenAIClient(
        apiKey: apiKey,
        baseUrl: 'https://api.openai.com/v1',
      );

      aiLogger.i('OpenAI GPT-5 서비스 초기화 성공');
    } catch (e) {
      aiLogger.e('OpenAI 서비스 초기화 실패', error: e);
      rethrow;
    }
  }

  /// API 키 유효성 검증
  bool get isApiKeyValid => ApiConfig.isOpenAIApiKeyValid;

  /// 현재 사용 모델
  String get currentModel => ApiConfig.openAIModel;

  /// 🎯 Chat Completion 생성 (범용)
  ///
  /// [systemPrompt] - 시스템 메시지 (AI 역할 정의)
  /// [userPrompt] - 사용자 메시지
  /// [temperature] - 응답 다양성 (0.0~2.0, 기본 0.8)
  /// [maxTokens] - 최대 토큰 수 (기본 150)
  /// [topP] - Nucleus sampling (기본 0.95)
  ///
  /// Returns: AI 응답 텍스트 또는 null (실패 시)
  Future<String?> createChatCompletion({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.8,
    int maxTokens = 150,
    double topP = 0.95,
    double frequencyPenalty = 0.0,
    double presencePenalty = 0.0,
  }) async {
    try {
      // API 키 유효성 검사
      if (!isApiKeyValid) {
        aiLogger.w('OpenAI API 키가 유효하지 않음');
        return null;
      }

      // Chat Completion 요청
      final chatCompletion = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(currentModel),
          messages: [
            ChatCompletionMessage.system(content: systemPrompt),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(userPrompt),
            ),
          ],
          temperature: temperature,
          maxTokens: maxTokens,
          topP: topP,
          frequencyPenalty: frequencyPenalty,
          presencePenalty: presencePenalty,
        ),
      );

      // 응답 추출
      final responseText = chatCompletion.choices.firstOrNull?.message.content;

      if (responseText != null && responseText.isNotEmpty) {
        aiLogger.i('OpenAI GPT-5 응답 생성 성공 (${responseText.length}자)');
        return responseText;
      } else {
        aiLogger.w('OpenAI 응답이 비어있음');
        return null;
      }
    } on HttpException catch (httpError) {
      aiLogger.e('OpenAI HTTP 오류', error: httpError);
      return null;
    } catch (e) {
      aiLogger.e('OpenAI API 호출 실패', error: e);
      return null;
    }
  }

  /// 🎯 대화형 Chat Completion (메시지 히스토리 지원)
  ///
  /// [messages] - 대화 메시지 리스트
  /// [temperature] - 응답 다양성 (0.0~2.0, 기본 0.8)
  /// [maxTokens] - 최대 토큰 수 (기본 500)
  ///
  /// Returns: AI 응답 텍스트 또는 null (실패 시)
  Future<String?> createConversation({
    required List<ChatCompletionMessage> messages,
    double temperature = 0.8,
    int maxTokens = 500,
    double topP = 0.95,
  }) async {
    try {
      // API 키 유효성 검사
      if (!isApiKeyValid) {
        aiLogger.w('OpenAI API 키가 유효하지 않음');
        return null;
      }

      // Chat Completion 요청
      final chatCompletion = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(currentModel),
          messages: messages,
          temperature: temperature,
          maxTokens: maxTokens,
          topP: topP,
        ),
      );

      // 응답 추출
      final responseText = chatCompletion.choices.firstOrNull?.message.content;

      if (responseText != null && responseText.isNotEmpty) {
        aiLogger.i('OpenAI 대화 응답 생성 성공 (${messages.length}개 메시지)');
        return responseText;
      } else {
        aiLogger.w('OpenAI 응답이 비어있음');
        return null;
      }
    } on HttpException catch (httpError) {
      aiLogger.e('OpenAI HTTP 오류', error: httpError);
      return null;
    } catch (e) {
      aiLogger.e('OpenAI 대화 생성 실패', error: e);
      return null;
    }
  }

  /// 리소스 정리
  void dispose() {
    // OpenAI 서비스 정리 완료
  }
}
