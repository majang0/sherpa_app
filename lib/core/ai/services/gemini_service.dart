// lib/core/ai/services/gemini_service.dart

import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';

/// 🧠 Google Gemini 범용 서비스
///
/// Gemini API 클라이언트를 캡슐화한 범용 서비스
/// 모든 feature에서 재사용 가능한 인프라 레이어
class GeminiService {
  static GeminiService? _instance;

  /// Singleton 인스턴스 반환
  static GeminiService get instance {
    _instance ??= GeminiService._internal();
    return _instance!;
  }

  /// Private 생성자
  GeminiService._internal() {
    try {
      // API 키 유효성 검증만 수행 (모델은 각 메서드에서 생성)
      final apiKey = ApiConfig.geminiApiKey;
      if (apiKey.isEmpty || !apiKey.startsWith('AIza')) {
        throw Exception('Invalid Gemini API key');
      }

      aiLogger.i('Gemini 서비스 초기화 성공 (모델: ${ApiConfig.geminiModel})');
    } catch (e) {
      aiLogger.e('Gemini 서비스 초기화 실패', error: e);
      rethrow;
    }
  }

  /// API 키 유효성 검증
  bool get isApiKeyValid => ApiConfig.isApiKeyValid;

  /// 현재 사용 모델
  String get currentModel => ApiConfig.geminiModel;

  /// 🎯 Content 생성 (범용)
  ///
  /// [prompt] - 사용자 프롬프트
  /// [systemInstruction] - 시스템 명령 (선택적)
  /// [temperature] - 응답 다양성 (0.0~2.0, 기본 0.8)
  /// [maxOutputTokens] - 최대 출력 토큰 수 (기본 150)
  ///
  /// Returns: AI 응답 텍스트 또는 null (실패 시)
  Future<String?> generateContent({
    required String prompt,
    String? systemInstruction,
    double temperature = 0.8,
    int maxOutputTokens = 150,
  }) async {
    try {
      // API 키 유효성 검사
      if (!isApiKeyValid) {
        aiLogger.w('Gemini API 키가 유효하지 않음');
        return null;
      }

      // GenerationConfig 설정
      final generationConfig = GenerationConfig(
        temperature: temperature,
        maxOutputTokens: maxOutputTokens,
      );

      // 모델 생성 (systemInstruction 있으면 포함)
      final model = systemInstruction != null
          ? GenerativeModel(
              model: currentModel,
              apiKey: ApiConfig.geminiApiKey,
              generationConfig: generationConfig,
              systemInstruction: Content.system(systemInstruction),
            )
          : GenerativeModel(
              model: currentModel,
              apiKey: ApiConfig.geminiApiKey,
              generationConfig: generationConfig,
            );

      // Content 생성
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      // 응답 추출
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        aiLogger.i('Gemini 응답 생성 성공 (${responseText.length}자)');
        return responseText;
      } else {
        aiLogger.w('Gemini 응답이 비어있음');
        return null;
      }
    } on GenerativeAIException catch (aiError) {
      aiLogger.e('Gemini AI 오류', error: aiError);
      return null;
    } catch (e) {
      aiLogger.e('Gemini API 호출 실패', error: e);
      return null;
    }
  }

  /// 🎯 대화형 Chat (메시지 히스토리 지원)
  ///
  /// [history] - 대화 히스토리 (선택적)
  /// [message] - 현재 메시지
  /// [systemInstruction] - 시스템 명령 (선택적)
  /// [temperature] - 응답 다양성 (0.0~2.0, 기본 0.8)
  /// [maxOutputTokens] - 최대 출력 토큰 수 (기본 500)
  ///
  /// Returns: AI 응답 텍스트 또는 null (실패 시)
  Future<String?> chat({
    List<Content>? history,
    required String message,
    String? systemInstruction,
    double temperature = 0.8,
    int maxOutputTokens = 500,
  }) async {
    try {
      // API 키 유효성 검사
      if (!isApiKeyValid) {
        aiLogger.w('Gemini API 키가 유효하지 않음');
        return null;
      }

      // GenerationConfig 설정
      final generationConfig = GenerationConfig(
        temperature: temperature,
        maxOutputTokens: maxOutputTokens,
      );

      // 모델 생성
      final model = systemInstruction != null
          ? GenerativeModel(
              model: currentModel,
              apiKey: ApiConfig.geminiApiKey,
              generationConfig: generationConfig,
              systemInstruction: Content.system(systemInstruction),
            )
          : GenerativeModel(
              model: currentModel,
              apiKey: ApiConfig.geminiApiKey,
              generationConfig: generationConfig,
            );

      // Chat 세션 시작
      final chat = model.startChat(history: history ?? []);

      // 메시지 전송
      final response = await chat.sendMessage(Content.text(message));

      // 응답 추출
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        aiLogger.i(
            'Gemini 대화 응답 생성 성공 (히스토리: ${history?.length ?? 0}개)');
        return responseText;
      } else {
        aiLogger.w('Gemini 응답이 비어있음');
        return null;
      }
    } on GenerativeAIException catch (aiError) {
      aiLogger.e('Gemini 대화 생성 오류', error: aiError);
      return null;
    } catch (e) {
      aiLogger.e('Gemini 대화 생성 실패', error: e);
      return null;
    }
  }

  /// 리소스 정리
  void dispose() {
    aiLogger.d('Gemini 서비스 정리 완료');
  }
}
