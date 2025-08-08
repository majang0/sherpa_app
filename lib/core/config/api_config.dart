import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 설정 관리 클래스
/// 
/// 이 파일은 Gemini API 키와 관련된 설정을 안전하게 관리합니다.
/// 실제 API 키는 .env 파일에서 가져옵니다.
class ApiConfig {
  // 🔑 개발용 플레이스홀더 API 키
  // 주의: 실제 운영 시에는 .env 파일에 유효한 API 키를 설정하세요!
  static const String _placeholderApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // 🎯 Gemini 모델 고정 (변경 금지)
  static const String geminiModel = 'gemini-2.5-flash';
  
  /// Gemini API 키를 반환합니다.
  /// 
  /// .env 파일에서 API 키를 가져옵니다. 환경 변수가 없으면 컴파일타임 환경변수를 확인합니다.
  static String get geminiApiKey {
    // 1순위: .env 파일에서 API 키 찾기
    String? envApiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (envApiKey != null && 
        envApiKey.isNotEmpty && 
        envApiKey != 'YOUR_ACTUAL_API_KEY_HERE' &&
        envApiKey.startsWith('AIza')) {
      return envApiKey;
    }
    
    // 2순위: 컴파일타임 환경 변수에서 API 키 찾기
    const compileTimeApiKey = String.fromEnvironment('GEMINI_API_KEY');
    
    if (compileTimeApiKey.isNotEmpty && 
        compileTimeApiKey != 'YOUR_GEMINI_API_KEY_HERE' &&
        compileTimeApiKey.startsWith('AIza')) {
      return compileTimeApiKey;
    }
    
    // 플레이스홀더 반환 (실제 운영 시에는 유효하지 않음)
    return _placeholderApiKey;
  }
  
  /// API 키가 유효한지 확인합니다.
  static bool get isApiKeyValid {
    final key = geminiApiKey;
    return key.isNotEmpty && 
           key != 'YOUR_GEMINI_API_KEY_HERE' && 
           key != 'YOUR_ACTUAL_API_KEY_HERE' &&
           key.startsWith('AIza');
  }
  
  /// API 키가 설정되어 있는지 확인합니다.
  static bool get isApiKeySet {
    return geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' && 
           geminiApiKey != 'YOUR_ACTUAL_API_KEY_HERE' && 
           geminiApiKey.isNotEmpty;
  }
  
  /// 최종 API 키를 반환합니다.
  static String get finalApiKey {
    return geminiApiKey;
  }
  
  /// 🧪 API 키 상태를 디버그용으로 출력합니다.
  static void debugApiKeyStatus() {
    print('🔐 [API Config Debug]');
    print('📁 .env 키: ${dotenv.env['GEMINI_API_KEY']?.substring(0, 10)}...');
    print('⚙️ 컴파일타임 키: ${const String.fromEnvironment('GEMINI_API_KEY').substring(0, 10)}...');
    print('🔑 최종 키: ${geminiApiKey.substring(0, 10)}...');
    print('✅ 유효성: ${isApiKeyValid ? "유효함" : "무효함"}');
    print('🎯 모델: $geminiModel');
  }
}