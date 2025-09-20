import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 📝 중앙 로깅 서비스
///
/// 앱 전체에서 사용되는 로깅 시스템을 관리합니다.
/// 개발/프로덕션 환경에 따라 로그 레벨을 자동 조정합니다.
class LoggerService {
  static LoggerService? _instance;
  late final Logger _logger;

  // 싱글톤 패턴
  static LoggerService get instance {
    _instance ??= LoggerService._internal();
    return _instance!;
  }

  LoggerService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: kDebugMode ? 2 : 0, // 디버그 모드에서만 스택 트레이스 표시
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: kDebugMode ? Level.debug : Level.warning, // 프로덕션에서는 warning 이상만
      filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
      output: ConsoleOutput(),
    );
  }

  /// 디버그 레벨 로그
  void d(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 정보 레벨 로그
  void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 경고 레벨 로그
  void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 에러 레벨 로그
  void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 치명적 에러 레벨 로그
  void f(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 추적 레벨 로그 (상세 디버깅용)
  void t(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// 로거 레벨 동적 변경
  void setLogLevel(Level level) {
    Logger.level = level;
  }

  /// 로거 인스턴스 직접 접근 (필요시)
  Logger get logger => _logger;
}

/// 전역 로거 인스턴스 (편의성을 위해)
final logger = LoggerService.instance;

/// 컨텍스트별 로거 생성 함수
///
/// 특정 클래스나 모듈용 로거를 생성할 때 사용합니다.
/// 예: final _logger = createLogger('OpenAISherpiManager');
Logger createLogger(String name) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: kDebugMode ? 2 : 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      noBoxingByDefault: false,
    ),
    level: kDebugMode ? Level.debug : Level.warning,
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
    output: ConsoleOutput(),
  );
}

/// AI 시스템 전용 로거
final aiLogger = createLogger('AI_System');

/// 분석 시스템 전용 로거
final analysisLogger = createLogger('Analysis_System');

/// 네트워크 전용 로거
final networkLogger = createLogger('Network');