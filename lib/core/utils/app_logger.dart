import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// 앱 전역에서 사용할 로거 인스턴스
class AppLogger {
  static Logger? _instance;

  /// 로거 인스턴스 반환
  static Logger get instance {
    _instance ??= _createLogger();
    return _instance!;
  }

  /// 환경별 로거 생성
  static Logger _createLogger() {
    return Logger(
      level: _getLogLevel(),
      printer: _getLogPrinter(),
      output: _getLogOutput(),
    );
  }

  /// 환경별 로그 레벨 설정
  static Level _getLogLevel() {
    if (kDebugMode) {
      return Level.debug;
    } else if (kProfileMode) {
      return Level.info;
    } else {
      // Release 모드에서는 warning 이상만 로그
      return Level.warning;
    }
  }

  /// 로그 프린터 설정
  static LogPrinter _getLogPrinter() {
    if (kDebugMode) {
      // 개발 환경에서는 상세한 로그
      return PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      );
    } else {
      // 프로덕션에서는 간단한 로그
      return SimplePrinter();
    }
  }

  /// 로그 출력 설정
  static LogOutput _getLogOutput() {
    if (kDebugMode) {
      return ConsoleOutput();
    } else {
      // 프로덕션에서는 파일 출력 또는 원격 로깅
      return ConsoleOutput(); // TODO: 프로덕션용 로그 수집 시스템 연동
    }
  }

  /// 편의 메서드들
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    instance.f(message, error: error, stackTrace: stackTrace);
  }

  /// 특정 기능별 로거 생성
  static Logger forFeature(String featureName) {
    return Logger(
      level: _getLogLevel(),
      printer: PrefixPrinter(
        PrettyPrinter(
          methodCount: 1,
          errorMethodCount: 5,
          lineLength: 120,
          colors: kDebugMode,
          printEmojis: kDebugMode,
          printTime: true,
        ),
        prefix: '[$featureName]',
      ),
      output: _getLogOutput(),
    );
  }
}

/// 기능별 로거 인스턴스들
class FeatureLoggers {
  static final climbing = AppLogger.forFeature('CLIMBING');
  static final quest = AppLogger.forFeature('QUEST');
  static final dailyRecord = AppLogger.forFeature('DAILY_RECORD');
  static final meeting = AppLogger.forFeature('MEETING');
  static final community = AppLogger.forFeature('COMMUNITY');
  static final profile = AppLogger.forFeature('PROFILE');
  static final shop = AppLogger.forFeature('SHOP');
  static final home = AppLogger.forFeature('HOME');
  static final auth = AppLogger.forFeature('AUTH');
  static final network = AppLogger.forFeature('NETWORK');
}

/// 로그 태그 상수들
class LogTags {
  static const user = 'USER';
  static const navigation = 'NAVIGATION';
  static const animation = 'ANIMATION';
  static const provider = 'PROVIDER';
  static const sherpi = 'SHERPI';
  static const gamification = 'GAMIFICATION';
  static const performance = 'PERFORMANCE';
  static const error = 'ERROR';
  static const security = 'SECURITY';
}