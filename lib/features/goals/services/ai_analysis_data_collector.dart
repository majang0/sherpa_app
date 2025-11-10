import 'package:sherpa_app/features/goals/models/goal_model.dart';
import 'package:sherpa_app/features/goals/models/routine_model.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/features/activities_exercise/models/detailed_exercise_models.dart';
import 'package:sherpa_app/features/activities_exercise/utils/running_record_helper.dart';

/// AI 분석을 위한 사용자 데이터 수집 클래스
///
/// 각 카테고리별로 필요한 데이터를 수집하고 검증하는 책임을 가집니다.
/// 현재 운동 카테고리만 지원하며, 추후 대회/학습/자격증 카테고리가 추가될 예정입니다.
///
/// **주요 기능**:
/// - 사용자 기본 정보 수집 (나이, 키, 몸무게, 체지방률, 골격근량)
/// - 카테고리별 목표 필터링
/// - 최근 2개월 운동 기록 필터링
/// - 데이터 유효성 검증
///
/// 예시:
/// ```dart
/// final user = ref.read(globalUserProvider);
/// final goals = ref.read(goalProvider);
/// final routines = ref.read(routineProvider);
///
/// final data = AIAnalysisDataCollector.collectExerciseData(
///   user,
///   goals,
///   routines,
/// );
///
/// if (AIAnalysisDataCollector.validateExerciseData(data)) {
///   // AI 분석 진행
/// } else {
///   // 데이터 불완전 안내
/// }
/// ```
class AIAnalysisDataCollector {
  /// 운동 카테고리 데이터를 수집합니다.
  ///
  /// **수집 데이터**:
  /// - `userInfo`: 나이, 키, 몸무게, 체지방률, 골격근량
  /// - `goals`: '운동' 카테고리 목표만 필터링
  /// - `routines`: 전체 루틴 (카테고리 필터링 없음)
  /// - `recentExerciseLogs`: 최근 2개월 운동 기록
  ///
  /// **반환값**:
  /// ```dart
  /// {
  ///   'userInfo': {
  ///     'age': int,
  ///     'height': int,
  ///     'weight': double,
  ///     'bodyFatRate': double,
  ///     'muscleMass': double,
  ///   },
  ///   'goals': List<GoalModel>,
  ///   'routines': List<RoutineModel>,
  ///   'recentExerciseLogs': List<ExerciseLog>,
  /// }
  /// ```
  ///
  /// **Null 처리**:
  /// - 모든 nullable 필드는 기본값 0으로 대체됩니다.
  /// - 나이 계산 실패 시 0을 반환합니다.
  static Map<String, dynamic> collectExerciseData(
    GlobalUser user,
    List<GoalModel> goals,
    List<RoutineModel> routines,
  ) {
    return {
      'userInfo': {
        'age': _calculateAge(user.birthYear),
        'height': user.height ?? 0,
        'weight': user.weight ?? 0.0,
        'bodyFatRate': user.bodyFatRate ?? 0.0,
        'muscleMass': user.muscleMass ?? 0.0,
      },
      'goals': goals.where((g) => g.category == '운동').toList(),
      'routines': routines, // 전체 루틴 (필터링 없음)
      'recentExerciseLogs': _filterRecentExerciseLogs(user),
    };
  }

  /// 🏃 러닝 전문 데이터를 수집합니다.
  ///
  /// **수집 데이터**:
  /// - `userInfo`: 나이, 키, 몸무게, 체지방률
  /// - `goals`: '운동' 카테고리 중 러닝 관련 목표만
  /// - `routines`: 러닝 관련 루틴만
  /// - `runningLogs`: 최근 2개월 러닝 기록만
  /// - `statistics`: 러닝 전용 통계 (총 거리, 평균 페이스 등)
  ///
  /// **반환값**:
  /// ```dart
  /// {
  ///   'userInfo': {
  ///     'age': int,
  ///     'height': int,
  ///     'weight': double,
  ///     'bodyFatRate': double,
  ///   },
  ///   'goals': List<GoalModel>,  // 러닝 관련 목표만
  ///   'routines': List<RoutineModel>,  // 러닝 관련 루틴만
  ///   'runningLogs': List<RunningRecord>,  // 러닝 기록만
  ///   'statistics': {
  ///     'totalDays': int,  // 총 러닝 일수
  ///     'totalDistance': double,  // 총 거리 (km)
  ///     'totalDuration': int,  // 총 시간 (분)
  ///     'avgDistance': double,  // 평균 거리 (km)
  ///     'avgPace': double,  // 평균 페이스 (분/km)
  ///     'avgDuration': int,  // 평균 시간 (분)
  ///     'totalCalories': int,  // 총 칼로리
  ///     'maxDistance': double,  // 최대 거리 (km)
  ///     'recentTrend': String,  // 최근 트렌드 (증가/유지/감소)
  ///   },
  /// }
  /// ```
  ///
  /// **Null 처리**:
  /// - 모든 nullable 필드는 기본값으로 대체
  /// - 러닝 기록이 없으면 빈 통계 반환
  static Future<Map<String, dynamic>> collectRunningData(
    GlobalUser user,
    List<GoalModel> goals,
    List<RoutineModel> routines,
  ) async {
    // 1. 최근 2개월 러닝 기록만 필터링 (RunningRecord 사용)
    final runningLogs = await _filterRecentRunningLogs();

    // 2. 러닝 통계 계산 (실제 거리, 페이스 데이터 사용)
    final statistics = _calculateRunningStatistics(runningLogs);

    // 3. 러닝 관련 목표 필터링 (운동 카테고리 중 러닝 관련 키워드 포함)
    final runningGoals = goals.where((g) {
      if (g.category != '운동') return false;
      final goalText = '${g.name} ${g.targetValue}'.toLowerCase();
      return _containsRunningKeyword(goalText);
    }).toList();

    // 4. 러닝 관련 루틴 필터링
    final runningRoutines = routines.where((r) {
      final routineText = '${r.name} ${r.category}'.toLowerCase();
      return _containsRunningKeyword(routineText);
    }).toList();

    return {
      'userInfo': {
        'age': _calculateAge(user.birthYear),
        'height': user.height ?? 0,
        'weight': user.weight ?? 0.0,
        'bodyFatRate': user.bodyFatRate ?? 0.0,
      },
      'goals': runningGoals,
      'routines': runningRoutines,
      'runningLogs': runningLogs,
      'statistics': statistics,
    };
  }

  /// 대회 카테고리 데이터를 수집합니다. (추후 구현)
  ///
  /// **수집 데이터**:
  /// - `userInfo`: 나이, 대회 수상 경력
  /// - `goals`: '대회' 카테고리 목표만 필터링
  /// - `routines`: 전체 루틴
  ///
  /// **현재 상태**: 준비 중 (미구현)
  static Map<String, dynamic> collectCompetitionData(
    GlobalUser user,
    List<GoalModel> goals,
    List<RoutineModel> routines,
  ) {
    // TODO: 대회 카테고리 데이터 수집 로직 구현
    throw UnimplementedError('대회 카테고리는 준비 중입니다');
  }

  /// 학습 카테고리 데이터를 수집합니다. (추후 구현)
  ///
  /// **수집 데이터**:
  /// - `userInfo`: 나이, 학업 성적
  /// - `goals`: '학습' 카테고리 목표만 필터링
  /// - `routines`: 전체 루틴
  ///
  /// **현재 상태**: 준비 중 (미구현)
  static Map<String, dynamic> collectStudyData(
    GlobalUser user,
    List<GoalModel> goals,
    List<RoutineModel> routines,
  ) {
    // TODO: 학습 카테고리 데이터 수집 로직 구현
    throw UnimplementedError('학습 카테고리는 준비 중입니다');
  }

  /// 자격증 카테고리 데이터를 수집합니다. (추후 구현)
  ///
  /// **수집 데이터**:
  /// - `userInfo`: 나이, 자격증
  /// - `goals`: '자격증' 카테고리 목표만 필터링
  /// - `routines`: 전체 루틴
  ///
  /// **현재 상태**: 준비 중 (미구현)
  static Map<String, dynamic> collectCertificationData(
    GlobalUser user,
    List<GoalModel> goals,
    List<RoutineModel> routines,
  ) {
    // TODO: 자격증 카테고리 데이터 수집 로직 구현
    throw UnimplementedError('자격증 카테고리는 준비 중입니다');
  }

  /// 최근 2개월(60일) 운동 기록을 필터링합니다.
  ///
  /// **필터링 기준**:
  /// - `log.date > DateTime.now() - 60일`
  ///
  /// **반환값**:
  /// - 최근 60일 이내의 운동 기록 리스트 (날짜 내림차순)
  /// - 기록이 없으면 빈 리스트 반환
  ///
  /// **예시**:
  /// ```dart
  /// final logs = _filterRecentExerciseLogs(user);
  /// print('최근 2개월 운동 일수: ${logs.length}');
  /// ```
  static List<ExerciseLog> _filterRecentExerciseLogs(GlobalUser user) {
    final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));

    return user.dailyRecords.exerciseLogs
        .where((log) => log.date.isAfter(twoMonthsAgo))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // 날짜 내림차순 정렬
  }

  /// 🏃 최근 2개월(60일) 러닝 기록만 필터링합니다.
  ///
  /// **필터링 기준**:
  /// - `log.date > DateTime.now() - 60일`
  /// - `log.exerciseType`이 러닝 관련 키워드 포함
  ///
  /// **러닝 키워드**:
  /// - '러닝', '조깅', '달리기', 'run', 'jog', 'running', 'jogging'
  ///
  /// **반환값**:
  /// - 최근 60일 이내의 러닝 기록 리스트 (날짜 내림차순)
  /// - 기록이 없으면 빈 리스트 반환
  /// 🏃 최근 2개월 러닝 기록을 불러옵니다 (RunningRecord 사용).
  ///
  /// **반환값**: List<RunningRecord> (날짜 내림차순 정렬)
  static Future<List<RunningRecord>> _filterRecentRunningLogs() async {
    final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));

    // RunningRecordHelper를 사용하여 모든 러닝 기록 로드
    final allRunningRecords = await RunningRecordHelper.loadAll();

    // 최근 2개월 기록만 필터링
    return allRunningRecords
        .where((record) => record.date.isAfter(twoMonthsAgo))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // 날짜 내림차순 정렬
  }

  /// 텍스트에 러닝 관련 키워드가 포함되어 있는지 확인합니다.
  ///
  /// **러닝 키워드**: '러닝', '조깅', '달리기', 'run', 'jog', 'running', 'jogging', '마라톤', 'marathon'
  ///
  /// **대소문자 구분 없음**
  static bool _containsRunningKeyword(String text) {
    final lowerText = text.toLowerCase();
    return lowerText.contains('러닝') ||
        lowerText.contains('조깅') ||
        lowerText.contains('달리기') ||
        lowerText.contains('run') ||
        lowerText.contains('jog') ||
        lowerText.contains('마라톤') ||
        lowerText.contains('marathon');
  }

  /// 🏃 러닝 통계를 계산합니다 (RunningRecord 사용).
  ///
  /// **계산 항목**:
  /// - `totalDays`: 총 러닝 일수
  /// - `totalDistance`: 총 거리 (km) - record.distanceKm
  /// - `totalDuration`: 총 시간 (분)
  /// - `avgDistance`: 평균 거리 (km)
  /// - `avgPace`: 평균 페이스 (분/km) - record.averagePace
  /// - `avgDuration`: 평균 시간 (분)
  /// - `maxDistance`: 최대 거리 (km)
  /// - `recentTrend`: 최근 트렌드 (증가/유지/감소)
  ///
  /// **반환값**:
  /// ```dart
  /// {
  ///   'totalDays': 15,
  ///   'totalDistance': 75.5,
  ///   'totalDuration': 450,
  ///   'avgDistance': 5.03,
  ///   'avgPace': 5.96,
  ///   'avgDuration': 30,
  ///   'maxDistance': 10.0,
  ///   'recentTrend': '증가',
  /// }
  /// ```
  static Map<String, dynamic> _calculateRunningStatistics(
      List<RunningRecord> runningRecords) {
    if (runningRecords.isEmpty) {
      return {
        'totalDays': 0,
        'totalDistance': 0.0,
        'totalDuration': 0,
        'avgDistance': 0.0,
        'avgPace': 0.0,
        'avgDuration': 0,
        'totalCalories': 0, // ✅ RunningRecord에는 calories 필드 없음 (0으로 설정)
        'maxDistance': 0.0,
        'recentTrend': '데이터 없음',
      };
    }

    // 1. 기본 통계 (RunningRecord 필드 사용)
    final totalDays = runningRecords.length;
    final totalDistance = runningRecords.fold<double>(
      0.0,
      (sum, record) => sum + record.distanceKm,
    );
    final totalDuration = runningRecords.fold<int>(
      0,
      (sum, record) => sum + record.durationMinutes,
    );

    // 2. 평균 및 최대 거리
    final avgDistance = totalDistance / totalDays;
    final maxDistance = runningRecords
        .map((r) => r.distanceKm)
        .reduce((a, b) => a > b ? a : b);
    final avgDuration = totalDuration ~/ totalDays;

    // 3. 평균 페이스 (각 기록의 페이스 평균)
    final avgPace = runningRecords.fold<double>(
          0.0,
          (sum, record) => sum + record.averagePace,
        ) /
        totalDays;

    // 4. 최근 트렌드 분석 (최근 7일 vs 이전 7일)
    final recentTrend = _analyzeRecentTrendForRunning(runningRecords);

    return {
      'totalDays': totalDays,
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'avgDistance': avgDistance,
      'avgPace': avgPace,
      'avgDuration': avgDuration,
      'totalCalories': 0, // ✅ RunningRecord에는 calories 필드 없음 (0으로 설정)
      'maxDistance': maxDistance,
      'recentTrend': recentTrend,
    };
  }

  /// 🏃 러닝 기록의 최근 트렌드를 분석합니다 (RunningRecord 사용).
  ///
  /// **분석 방법**:
  /// - 최근 7개 기록 평균 거리 vs 이전 7개 기록 평균 거리
  /// - 증가: 최근 > 이전 * 1.1
  /// - 감소: 최근 < 이전 * 0.9
  /// - 유지: 그 외
  ///
  /// **반환값**: '증가', '유지', '감소', '데이터 부족'
  static String _analyzeRecentTrendForRunning(List<RunningRecord> records) {
    if (records.length < 7) {
      return '데이터 부족';
    }

    // 최근 7개 기록과 이전 7개 기록으로 분리
    final recentRecords = records.take(7).toList();
    final previousRecords = records.skip(7).take(7).toList();

    if (previousRecords.isEmpty) {
      return '데이터 부족';
    }

    // 평균 거리 계산
    final recentAvg = recentRecords.fold<double>(
            0.0, (sum, r) => sum + r.distanceKm) /
        recentRecords.length;
    final previousAvg = previousRecords.fold<double>(
            0.0, (sum, r) => sum + r.distanceKm) /
        previousRecords.length;

    // 트렌드 판정
    if (recentAvg > previousAvg * 1.1) {
      return '증가';
    } else if (recentAvg < previousAvg * 0.9) {
      return '감소';
    } else {
      return '유지';
    }
  }

  /// 생년(birthYear)으로부터 나이를 계산합니다.
  ///
  /// **계산 공식**:
  /// - `age = 현재 연도 - birthYear`
  ///
  /// **유효성 검증**:
  /// - `birthYear == null` → 0 반환
  /// - `birthYear < 1900` → 0 반환 (비정상 값)
  /// - `birthYear > 현재 연도` → 0 반환 (미래 값)
  ///
  /// **반환값**:
  /// - 유효한 나이 (0 이상의 정수)
  /// - 유효하지 않은 경우 0 반환
  ///
  /// **예시**:
  /// ```dart
  /// final age = _calculateAge(1990); // 2025 - 1990 = 35
  /// final invalidAge = _calculateAge(null); // 0
  /// final futureAge = _calculateAge(2030); // 0 (미래 값)
  /// ```
  static int _calculateAge(int? birthYear) {
    if (birthYear == null) return 0;

    final currentYear = DateTime.now().year;

    // 비정상 값 검증
    if (birthYear < 1900 || birthYear > currentYear) {
      return 0;
    }

    return currentYear - birthYear;
  }

  /// 운동 카테고리 데이터의 유효성을 검증합니다.
  ///
  /// **검증 항목**:
  /// 1. **필수 정보 체크**:
  ///    - 나이 > 0
  ///    - 키 > 0
  ///    - 몸무게 > 0
  ///
  /// 2. **최소 운동 기록 체크**:
  ///    - 최근 2개월 운동 기록 >= 5개
  ///
  /// **반환값**:
  /// - `true`: 모든 검증 통과 (AI 분석 가능)
  /// - `false`: 하나 이상의 검증 실패 (데이터 불완전)
  ///
  /// **사용 시나리오**:
  /// ```dart
  /// final data = AIAnalysisDataCollector.collectExerciseData(...);
  ///
  /// if (!AIAnalysisDataCollector.validateExerciseData(data)) {
  ///   // 사용자에게 "정보 입력 필요" 다이얼로그 표시
  ///   showDataIncompleteDialog();
  ///   return;
  /// }
  ///
  /// // AI 분석 진행
  /// final prompt = AIPromptBuilder.buildExercisePrompt(data);
  /// ```
  static bool validateExerciseData(Map<String, dynamic> data) {
    final userInfo = data['userInfo'] as Map<String, dynamic>;
    final logs = data['recentExerciseLogs'] as List<ExerciseLog>;

    // 1. 필수 정보 체크
    final age = userInfo['age'] as int;
    final height = userInfo['height'] as int;
    final weight = userInfo['weight'] as double;

    if (age == 0 || height == 0 || weight == 0.0) {
      return false; // 필수 정보 누락
    }

    // 2. 최소 운동 기록 체크 (5개 이상)
    if (logs.length < 5) {
      return false; // 기록 부족
    }

    return true; // 모든 검증 통과
  }

  /// 데이터 검증 실패 이유를 반환합니다.
  ///
  /// **반환값**:
  /// - 빈 리스트: 모든 검증 통과
  /// - 실패 이유 리스트: ['필수 정보 누락', '운동 기록 부족'] 등
  ///
  /// **사용 시나리오**:
  /// ```dart
  /// final data = AIAnalysisDataCollector.collectExerciseData(...);
  /// final reasons = AIAnalysisDataCollector.getValidationFailureReasons(data);
  ///
  /// if (reasons.isNotEmpty) {
  ///   showDialog(
  ///     context: context,
  ///     builder: (context) => AlertDialog(
  ///       title: Text('정보 입력 필요'),
  ///       content: Text(reasons.join('\n')),
  ///     ),
  ///   );
  /// }
  /// ```
  static List<String> getValidationFailureReasons(Map<String, dynamic> data) {
    final reasons = <String>[];
    final userInfo = data['userInfo'] as Map<String, dynamic>;
    final logs = data['recentExerciseLogs'] as List<ExerciseLog>;

    // 필수 정보 체크
    final age = userInfo['age'] as int;
    final height = userInfo['height'] as int;
    final weight = userInfo['weight'] as double;

    if (age == 0) {
      reasons.add('생년월일 정보가 필요합니다');
    }

    if (height == 0) {
      reasons.add('키 정보가 필요합니다');
    }

    if (weight == 0.0) {
      reasons.add('몸무게 정보가 필요합니다');
    }

    // 최소 운동 기록 체크
    if (logs.length < 5) {
      reasons.add('최근 2개월 운동 기록이 ${logs.length}개입니다 (최소 5개 필요)');
    }

    return reasons;
  }

  /// 🏃 러닝 데이터의 유효성을 검증합니다.
  ///
  /// **검증 항목**:
  /// 1. **필수 정보 체크**:
  ///    - 나이 > 0
  ///    - 키 > 0
  ///    - 몸무게 > 0
  ///
  /// 2. **최소 러닝 기록 체크**:
  ///    - 최근 2개월 러닝 기록 >= 3개
  ///
  /// **반환값**:
  /// - `true`: 모든 검증 통과 (AI 분석 가능)
  /// - `false`: 하나 이상의 검증 실패 (데이터 불완전)
  ///
  /// **사용 시나리오**:
  /// ```dart
  /// final data = AIAnalysisDataCollector.collectRunningData(...);
  ///
  /// if (!AIAnalysisDataCollector.validateRunningData(data)) {
  ///   // 사용자에게 "정보 입력 필요" 다이얼로그 표시
  ///   showDataIncompleteDialog();
  ///   return;
  /// }
  ///
  /// // AI 분석 진행
  /// final prompt = AIPromptBuilder.buildRunningPrompt(data);
  /// ```
  /// 🏃 러닝 데이터 유효성 검증 (RunningRecord 기준).
  ///
  /// **검증 항목**:
  /// 1. 필수 사용자 정보: 나이, 키, 몸무게
  /// 2. 최소 러닝 기록: 3개 이상
  static bool validateRunningData(Map<String, dynamic> data) {
    final userInfo = data['userInfo'] as Map<String, dynamic>;
    final logs = data['runningLogs'] as List; // RunningRecord 리스트

    // 1. 필수 정보 체크
    final age = userInfo['age'] as int;
    final height = userInfo['height'] as int;
    final weight = userInfo['weight'] as double;

    if (age == 0 || height == 0 || weight == 0.0) {
      return false; // 필수 정보 누락
    }

    // 2. 최소 러닝 기록 체크 (3개 이상)
    if (logs.length < 3) {
      return false; // 기록 부족
    }

    return true; // 모든 검증 통과
  }

  /// 🏃 러닝 데이터 검증 실패 이유를 반환합니다.
  ///
  /// **반환값**:
  /// - 빈 리스트: 모든 검증 통과
  /// - 실패 이유 리스트: ['필수 정보 누락', '러닝 기록 부족'] 등
  ///
  /// **사용 시나리오**:
  /// ```dart
  /// final data = AIAnalysisDataCollector.collectRunningData(...);
  /// final reasons = AIAnalysisDataCollector.getRunningValidationFailureReasons(data);
  ///
  /// if (reasons.isNotEmpty) {
  ///   showDialog(
  ///     context: context,
  ///     builder: (context) => AlertDialog(
  ///       title: Text('정보 입력 필요'),
  ///       content: Text(reasons.join('\n')),
  ///     ),
  ///   );
  /// }
  /// ```
  static List<String> getRunningValidationFailureReasons(
      Map<String, dynamic> data) {
    final reasons = <String>[];
    final userInfo = data['userInfo'] as Map<String, dynamic>;
    final logs = data['runningLogs'] as List; // RunningRecord 리스트

    // 필수 정보 체크
    final age = userInfo['age'] as int;
    final height = userInfo['height'] as int;
    final weight = userInfo['weight'] as double;

    if (age == 0) {
      reasons.add('생년월일 정보가 필요합니다');
    }

    if (height == 0) {
      reasons.add('키 정보가 필요합니다');
    }

    if (weight == 0.0) {
      reasons.add('몸무게 정보가 필요합니다');
    }

    // 최소 러닝 기록 체크
    if (logs.length < 3) {
      reasons.add('최근 2개월 러닝 기록이 ${logs.length}개입니다 (최소 3개 필요)');
    }

    return reasons;
  }
}
