/// API 설정 관리 클래스
/// 
/// 이 파일은 Gemini API 키와 관련된 설정을 안전하게 관리합니다.
/// 실제 API 키는 환경 변수나 별도의 설정 파일에서 가져옵니다.
class ApiConfig {
  // 🔑 실제 Gemini API 키 (개발용)
  // 주의: 실제 배포 시에는 환경 변수를 사용하세요!
  static const String _developmentApiKey = 'AIzaSyBdTEXM2B7-gq0DTMd6rsSoWV7i1mL_RKw';
  
  /// Gemini API 키를 반환합니다.
  /// 
  /// 환경 변수에서 먼저 찾고, 없으면 개발용 키를 사용합니다.
  static String get geminiApiKey {
    // 환경 변수에서 API 키 찾기
    const envApiKey = String.fromEnvironment('GEMINI_API_KEY');
    
    if (envApiKey.isNotEmpty && envApiKey != 'YOUR_GEMINI_API_KEY_HERE') {
      return envApiKey;
    }
    
    // 개발용 키 사용
    return _developmentApiKey;
  }
  
  /// API 키가 유효한지 확인합니다.
  static bool get isApiKeyValid {
    final key = geminiApiKey;
    return key.isNotEmpty && 
           key != 'YOUR_GEMINI_API_KEY_HERE' && 
           key.startsWith('AIza');
  }
  
  /// API 키가 설정되어 있는지 확인합니다.
  static bool get isApiKeySet {
    return geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' && geminiApiKey.isNotEmpty;
  }
  
  /// 최종 API 키를 반환합니다.
  static String get finalApiKey {
    return geminiApiKey;
  }
}