/// 🛠️ Sherpi 텍스트 처리 유틸리티
///
/// 중복된 텍스트 처리 로직을 통합한 유틸리티 클래스
class SherpiTextUtils {
  /// 이모지 제거
  ///
  /// 텍스트에서 모든 이모지를 제거합니다.
  /// 개인화 설정에서 이모지 사용을 비활성화한 경우 사용됩니다.
  static String removeEmojis(String text) {
    return text
        .replaceAll(
            RegExp(
                r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
                unicode: true),
            '')
        .trim();
  }

  /// 사용자 이름 개인화
  ///
  /// 메시지의 {userName} 플레이스홀더를 실제 사용자 이름으로 대체합니다.
  /// 기본값 '친구'를 사용자가 설정한 이름으로 변경합니다.
  static String personalizeUserName(String text, String userName) {
    if (userName.isEmpty || userName == '친구') {
      return text;
    }

    // {userName} 플레이스홀더 대체
    text = text.replaceAll('{userName}', userName);

    // '친구'를 사용자 이름으로 대체 (기존 메시지 호환성)
    text = text.replaceAll('친구', userName);

    return text;
  }

  /// 메시지 포맷팅
  ///
  /// 이모지 설정과 사용자 이름을 한 번에 처리합니다.
  static String formatMessage({
    required String text,
    required String userName,
    required bool useEmojis,
  }) {
    String formatted = text;

    // 사용자 이름 개인화
    formatted = personalizeUserName(formatted, userName);

    // 이모지 제거 (필요한 경우)
    if (!useEmojis) {
      formatted = removeEmojis(formatted);
    }

    return formatted;
  }

  /// 세션 ID 생성
  ///
  /// 고유한 세션 ID를 생성합니다.
  static String generateSessionId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return '${timestamp}_$random';
  }

  /// 시간 기반 인사말 결정
  ///
  /// 현재 시간에 따라 적절한 인사말을 반환합니다.
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return '좋은 아침이에요';
    } else if (hour >= 12 && hour < 17) {
      return '좋은 오후예요';
    } else if (hour >= 17 && hour < 21) {
      return '좋은 저녁이에요';
    } else {
      return '안녕하세요';
    }
  }

  /// 연속 일수 계산
  ///
  /// 마지막 활동일과 현재 날짜를 비교하여 연속 일수를 계산합니다.
  static int calculateConsecutiveDays(DateTime lastDate, DateTime currentDate) {
    // 날짜만 비교 (시간 제외)
    final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final current =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    final daysDiff = current.difference(last).inDays;

    if (daysDiff == 0) {
      return 0; // 같은 날
    } else if (daysDiff == 1) {
      return 1; // 연속
    } else {
      return -1; // 연속 끊김
    }
  }

  /// 메시지 중복 체크
  ///
  /// 특정 시간 내에 같은 컨텍스트의 메시지인지 확인합니다.
  static bool isDuplicateMessage({
    required DateTime? lastMessageTime,
    required String? lastContext,
    required String? lastMessage,
    required DateTime currentTime,
    required String currentContext,
    required String? currentMessage,
    int thresholdSeconds = 3,
  }) {
    if (lastMessageTime == null) {
      return false;
    }

    final timeDiff = currentTime.difference(lastMessageTime);

    // 임계 시간 내에 같은 컨텍스트
    if (timeDiff.inSeconds < thresholdSeconds &&
        lastContext == currentContext) {
      // 메시지 내용도 같으면 중복
      if (currentMessage != null && lastMessage == currentMessage) {
        return true;
      }
      // 메시지가 null이면 컨텍스트만으로 중복 판단
      if (currentMessage == null) {
        return true;
      }
    }

    return false;
  }
}
