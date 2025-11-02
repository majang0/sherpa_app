import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';

/// API 설정 관리 클래스
///
/// 이 파일은 AI API 키와 관련된 설정을 안전하게 관리합니다.
/// 실제 API 키는 .env 파일에서 가져옵니다.
/// 지원하는 AI: OpenAI GPT-5
class ApiConfig {
  // 🔑 개발용 플레이스홀더 API 키
  // 주의: 실제 운영 시에는 .env 파일에 유효한 API 키를 설정하세요!
  static const String _placeholderOpenAIApiKey = 'YOUR_OPENAI_API_KEY_HERE';

  // 🧪 테스트용 API 키 (실제 API 호출은 하지 않지만 형식은 맞춤)
  static const String _testOpenAIApiKey = 'sk-test_OpenAIKey_ForTestingOnly';

  // 🎯 AI 모델 설정
  static const String openAIModel =
      'gpt-5-chat-latest'; // OpenAI GPT-5 Chat 모델 (2025년 8월 출시)

  /// DotEnv가 초기화되었는지 확인
  static bool get _isDotEnvLoaded {
    try {
      // DotEnv가 초기화되었는지 확인
      final _ = dotenv.env;
      return true;
    } catch (e) {
      // NotInitializedError가 발생하면 false 반환
      return false;
    }
  }

  /// OpenAI API 키를 반환합니다.
  ///
  /// .env 파일에서 API 키를 가져옵니다. 환경 변수가 없으면 컴파일타임 환경변수를 확인합니다.
  static String get openAIApiKey {
    // 테스트 환경에서는 테스트용 API 키 반환
    if (!_isDotEnvLoaded) {
      // 컴파일타임 환경 변수 확인
      const compileTimeApiKey = String.fromEnvironment('OPENAI_API_KEY');
      if (compileTimeApiKey.isNotEmpty &&
          compileTimeApiKey != 'YOUR_OPENAI_API_KEY_HERE' &&
          compileTimeApiKey.startsWith('sk-')) {
        return compileTimeApiKey;
      }
      // 테스트 환경에서는 테스트용 키 반환
      return _testOpenAIApiKey;
    }

    // 1순위: .env 파일에서 API 키 찾기
    String? envApiKey = dotenv.env['OPENAI_API_KEY'];

    if (envApiKey != null &&
        envApiKey.isNotEmpty &&
        envApiKey != 'YOUR_OPENAI_API_KEY_HERE' &&
        envApiKey.startsWith('sk-')) {
      return envApiKey;
    }

    // 2순위: 컴파일타임 환경 변수에서 API 키 찾기
    const compileTimeApiKey = String.fromEnvironment('OPENAI_API_KEY');

    if (compileTimeApiKey.isNotEmpty &&
        compileTimeApiKey != 'YOUR_OPENAI_API_KEY_HERE' &&
        compileTimeApiKey.startsWith('sk-')) {
      return compileTimeApiKey;
    }

    // 플레이스홀더 반환 (실제 운영 시에는 유효하지 않음)
    return _placeholderOpenAIApiKey;
  }

  /// OpenAI API 키가 유효한지 확인합니다.
  static bool get isOpenAIApiKeyValid {
    final key = openAIApiKey;
    return key.isNotEmpty &&
        key != 'YOUR_OPENAI_API_KEY_HERE' &&
        key.startsWith('sk-');
  }

  /// 사용할 AI 제공자를 선택합니다.
  static AIProvider get currentAIProvider {
    // OpenAI만 사용
    if (isOpenAIApiKeyValid) {
      return AIProvider.openai;
    }
    // 없으면 기본값
    return AIProvider.none;
  }

  /// 🧪 API 키 상태를 디버그용으로 출력합니다.
  static void debugApiKeyStatus() {
    LoggerService.instance.d('📊 AI API 키 상태:');
    LoggerService.instance
        .d('  - OpenAI: ${isOpenAIApiKeyValid ? '✅ 설정됨' : '❌ 미설정'}');
    LoggerService.instance.d('  - 현재 사용: ${currentAIProvider.name}');
  }
}

/// AI 제공자 열거형
enum AIProvider {
  openai,
  none,
}
