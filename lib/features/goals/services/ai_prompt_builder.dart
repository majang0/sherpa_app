import 'package:sherpa_app/features/goals/models/goal_model.dart';
import 'package:sherpa_app/features/goals/models/routine_model.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/features/activities_exercise/models/detailed_exercise_models.dart';

/// AI 분석용 프롬프트를 생성하는 클래스
///
/// [AIAnalysisDataCollector]에서 수집한 데이터를 받아
/// AI가 이해할 수 있는 구조화된 텍스트 프롬프트로 변환합니다.
///
/// **주요 기능**:
/// - 사용자 데이터를 읽기 쉬운 텍스트로 포맷팅
/// - 운동 기록을 통계로 요약
/// - AI 응답 형식 명시
///
/// **프롬프트 구조**:
/// 1. 시스템 역할 정의 (전문 피트니스 코치)
/// 2. 사용자 정보 섹션
/// 3. 현재 목표 섹션
/// 4. 현재 루틴 섹션
/// 5. 최근 2개월 운동 기록 요약 섹션
/// 6. 응답 형식 가이드
///
/// 예시:
/// ```dart
/// final data = AIAnalysisDataCollector.collectExerciseData(...);
/// final prompt = AIPromptBuilder.buildExercisePrompt(data);
///
/// // 프롬프트를 OpenAI API로 전송 (추후 구현)
/// // final response = await OpenAIService.generateResponse(prompt);
/// ```
class AIPromptBuilder {
  /// 운동 카테고리 AI 분석용 프롬프트를 생성합니다.
  ///
  /// **입력 데이터 구조**:
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
  /// **프롬프트 섹션**:
  /// - **시스템 역할**: "당신은 전문 피트니스 코치입니다"
  /// - **사용자 정보**: 나이, 키, 몸무게, 체지방률, 골격근량
  /// - **현재 목표**: 운동 카테고리 목표 리스트
  /// - **현재 루틴**: 전체 루틴 리스트 (모든 카테고리)
  /// - **운동 기록 요약**: 총 일수, 평균 시간, 칼로리, 주요 운동
  /// - **응답 형식**: 현재 상태 평가, 강점, 개선점, 실천 계획
  ///
  /// **반환값**:
  /// - AI API로 전송 가능한 완성된 프롬프트 문자열
  /// - 한국어로 작성된 자연스러운 텍스트
  ///
  /// **주의사항**:
  /// - 입력 데이터는 [AIAnalysisDataCollector.validateExerciseData]로
  ///   검증 완료된 데이터여야 합니다.
  /// - 프롬프트는 실제 AI 연결 전까지 콘솔/화면에 출력하여 확인합니다.
  static String buildExercisePrompt(Map<String, dynamic> data) {
    final userInfo = data['userInfo'] as Map<String, dynamic>;
    final goals = data['goals'] as List<GoalModel>;
    final routines = data['routines'] as List<RoutineModel>;
    final logs = data['recentExerciseLogs'] as List<ExerciseLog>;

    return '''
당신은 전문 피트니스 코치입니다. 다음 사용자 데이터를 분석하여 개인화된 운동 분석 및 조언을 제공해주세요.

## 사용자 정보
- 나이: ${userInfo['age']}세
- 키: ${userInfo['height']}cm
- 몸무게: ${userInfo['weight']}kg
- 체지방률: ${userInfo['bodyFatRate']}%
- 골격근량: ${userInfo['muscleMass']}kg

## 현재 목표
${_formatGoals(goals)}

## 현재 루틴
${_formatRoutines(routines)}

## 최근 2개월 운동 기록 요약
${_formatExerciseLogs(logs)}

다음 형식으로 분석 결과를 제공해주세요:

1. **현재 상태 평가** (3-4줄)
   - 사용자의 신체 데이터와 운동 기록을 바탕으로 전반적인 상태를 평가해주세요.
   - 체지방률, 골격근량 등 구체적인 수치를 언급하며 설명해주세요.

2. **강점** (2-3개)
   - 잘하고 있는 부분을 구체적인 수치와 함께 칭찬해주세요.
   - 예: "평균 주 4회 운동으로 꾸준한 루틴을 유지하고 계십니다"

3. **개선점** (2-3개)
   - 보완이 필요한 부분을 구체적으로 제안해주세요.
   - 예: "하체 운동 빈도를 늘려 균형잡힌 발달을 도모하세요"

4. **이번 주 실천 계획** (3-4개)
   - 구체적이고 실행 가능한 주간 계획을 제시해주세요.
   - 예: "화/목/토 오후 7시에 30분 조깅하기"
''';
  }

  /// 목표 리스트를 읽기 쉬운 텍스트로 변환합니다.
  ///
  /// **포맷**:
  /// ```
  /// - [목표명] (목표: [목표값], 상태: [진행 중/달성])
  /// ```
  ///
  /// **예시**:
  /// ```
  /// - 10km 달리기 완주 (목표: 60분 이내, 상태: ⏳ 진행 중)
  /// - 벤치프레스 100kg (목표: 100kg, 상태: ✅ 달성)
  /// ```
  ///
  /// **빈 리스트 처리**:
  /// - 목표가 없으면 "- 설정된 목표가 없습니다." 반환
  static String _formatGoals(List<GoalModel> goals) {
    if (goals.isEmpty) {
      return '- 설정된 목표가 없습니다.';
    }

    return goals.map((goal) {
      final status = goal.isAchieved ? '✅ 달성' : '⏳ 진행 중';
      return '- ${goal.name} (목표: ${goal.targetValue}, 상태: $status)';
    }).join('\n');
  }

  /// 루틴 리스트를 읽기 쉬운 텍스트로 변환합니다.
  ///
  /// **포맷**:
  /// ```
  /// - [카테고리] [루틴명] ([빈도])
  /// ```
  ///
  /// **예시**:
  /// ```
  /// - [운동] 아침 조깅 (주 3회)
  /// - [건강] 스트레칭 (매일)
  /// - [학습] 영어 공부 (주 5회)
  /// ```
  ///
  /// **빈 리스트 처리**:
  /// - 루틴이 없으면 "- 설정된 루틴이 없습니다." 반환
  static String _formatRoutines(List<RoutineModel> routines) {
    if (routines.isEmpty) {
      return '- 설정된 루틴이 없습니다.';
    }

    return routines.map((routine) {
      final category = routine.category;
      final frequency = routine.frequency;
      return '- [$category] ${routine.name} ($frequency)';
    }).join('\n');
  }

  /// 운동 기록을 통계로 요약하여 텍스트로 변환합니다.
  ///
  /// **통계 항목**:
  /// 1. 총 운동 일수
  /// 2. 평균 운동 시간 (분)
  /// 3. 총 소모 칼로리
  /// 4. 주요 운동 (빈도 상위 3개)
  ///
  /// **포맷**:
  /// ```
  /// - 총 운동 일수: X일
  /// - 평균 운동 시간: X분
  /// - 총 소모 칼로리: Xkcal
  /// - 주요 운동: 조깅(12회), 웨이트(8회), 수영(5회)
  /// ```
  ///
  /// **빈 리스트 처리**:
  /// - 기록이 없으면 "- 최근 운동 기록이 없습니다." 반환
  ///
  /// **예시**:
  /// ```dart
  /// final logs = [
  ///   ExerciseLog(date: ..., exerciseType: '조깅', durationMinutes: 30, ...),
  ///   ExerciseLog(date: ..., exerciseType: '웨이트', durationMinutes: 45, ...),
  /// ];
  /// final summary = _formatExerciseLogs(logs);
  /// // 출력:
  /// // - 총 운동 일수: 2일
  /// // - 평균 운동 시간: 38분
  /// // - 총 소모 칼로리: 500kcal
  /// // - 주요 운동: 조깅(1회), 웨이트(1회)
  /// ```
  static String _formatExerciseLogs(List<ExerciseLog> logs) {
    if (logs.isEmpty) {
      return '- 최근 운동 기록이 없습니다.';
    }

    // 통계 계산
    final totalDays = logs.length;
    final totalDuration = logs.fold<int>(
      0,
      (sum, log) => sum + log.durationMinutes,
    );
    final avgDuration = totalDuration ~/ totalDays;

    final totalCalories = logs.fold<int>(
      0,
      (sum, log) => sum + (log.calories ?? 0),
    );

    // 운동 타입별 빈도 계산
    final typeFrequency = <String, int>{};
    for (var log in logs) {
      typeFrequency[log.exerciseType] =
          (typeFrequency[log.exerciseType] ?? 0) + 1;
    }

    // 빈도 상위 3개 운동
    final topExercises = typeFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topExercisesText = topExercises
        .take(3)
        .map((e) => '${e.key}(${e.value}회)')
        .join(', ');

    return '''
- 총 운동 일수: $totalDays일
- 평균 운동 시간: $avgDuration분
- 총 소모 칼로리: ${totalCalories}kcal
- 주요 운동: $topExercisesText''';
  }

  /// 🏃 러닝 전문 AI 분석용 프롬프트를 생성합니다.
  ///
  /// **입력 데이터 구조**:
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
  ///   'runningLogs': List<ExerciseLog>,  // 러닝 기록만
  ///   'statistics': Map<String, dynamic>,  // 러닝 통계
  /// }
  /// ```
  ///
  /// **System Prompt**: 15년 경력 프로 러닝 코치 역할
  ///
  /// **User Prompt 구조**:
  /// 1. 사용자 기본 정보
  /// 2. 러닝 목표
  /// 3. 러닝 루틴
  /// 4. 최근 2개월 러닝 기록 (상세 통계)
  /// 5. 10개 섹션 분석 요청 (패턴 평가, 강점, 개선점, 페이스 트렌드, 부상 방지, 목표 달성 로드맵, 추천 루틴, 영양/회복, 스트레칭, 실천 계획)
  ///
  /// **반환값**:
  /// - OpenAI API로 전송 가능한 완성된 프롬프트 문자열 (systemPrompt + userPrompt)
  /// - 전문적이고 상세한 분석을 위한 구조화된 형식
  ///
  /// **주의사항**:
  /// - 입력 데이터는 [AIAnalysisDataCollector.validateRunningData]로 검증 완료된 데이터여야 합니다.
  static String buildRunningPrompt(Map<String, dynamic> data) {
    final userInfo = data['userInfo'] as Map<String, dynamic>;
    final goals = data['goals'] as List<GoalModel>;
    final routines = data['routines'] as List<RoutineModel>;
    final logs = data['runningLogs'] as List; // ✅ RunningRecord 리스트 (타입 제거)
    final statistics = data['statistics'] as Map<String, dynamic>;

    return '''
당신은 15년 경력의 프로 러닝 코치입니다.

**경력**:
- 마라톤 완주자 1,000명 이상 지도
- RRCA(Road Runners Club of America) 인증 코치
- 스포츠 과학 석사 학위
- 부상 예방 및 재활 전문가
- 올림픽 대표 선수단 트레이닝 경험

**전문 분야**:
- 초보자부터 엘리트 러너까지 맞춤형 훈련 계획
- 페이스 관리 및 심폐 지구력 향상
- 러닝 폼 교정 및 부상 예방 전략
- 영양, 회복, 멘탈 트레이닝
- 목표 기반 단계별 러닝 프로그램 설계

---

다음 러너의 데이터를 분석하여 전문적이고 상세한 러닝 분석 및 조언을 제공해주세요.

## 러너 정보
- 나이: ${userInfo['age']}세
- 키: ${userInfo['height']}cm
- 몸무게: ${userInfo['weight']}kg
- 체지방률: ${userInfo['bodyFatRate']}%

## 러닝 목표
${_formatGoals(goals)}

## 현재 러닝 루틴
${_formatRoutines(routines)}

## 최근 2개월 러닝 기록 분석
${_formatRunningStatistics(statistics)}

## 최근 러닝 기록 상세
${_formatRunningLogs(logs)}

---

다음 형식으로 전문적이고 상세한 분석을 제공해주세요:

### 1. 🏃 현재 러닝 패턴 종합 평가 (5-7줄)
- 러너의 전반적인 러닝 패턴, 일관성, 진행 상황을 평가해주세요.
- 신체 데이터(체지방률, 몸무게)를 고려한 러닝 능력 분석
- 최근 2개월 동안의 발전 또는 정체 상태 평가

### 2. 💪 강점 분석 (3-4개)
- 잘하고 있는 부분을 구체적인 수치와 함께 칭찬해주세요.
- 예: "평균 주 3회 러닝으로 일관성을 유지하고 있습니다"
- 예: "최근 7일간 평균 페이스가 10% 향상되었습니다"

### 3. 🎯 개선이 필요한 영역 (3-4개)
- 보완이 필요한 부분을 구체적인 근거와 함께 제시해주세요.
- 예: "현재 주 2회 러닝은 심폐 지구력 향상에 부족합니다. 최소 주 3-4회를 권장합니다"

### 4. 📊 페이스 및 거리 트렌드 분석 (3-4줄)
- 최근 페이스 변화, 거리 변화, 일관성 평가
- 트렌드가 목표 달성에 긍정적인지 부정적인지 판단

### 5. 🛡️ 부상 방지 조언 (4-5개, 구체적)
- 현재 러닝 패턴에서 부상 위험 요소 파악
- 예방을 위한 구체적인 조언
- 예: "급격한 거리 증가는 무릎 부상 위험을 높입니다. 주당 10% 이내로 증가하세요"
- 워밍업, 쿨다운, 휴식일의 중요성

### 6. 🗺️ 목표 달성 로드맵 (4주 계획)
- 목표를 향한 단계별 4주 계획 제시
- 각 주차별 거리, 페이스, 빈도 목표
- 예:
  - 1주차: 주 3회, 평균 5km, 페이스 6:30/km
  - 2주차: 주 3회, 평균 5.5km, 페이스 6:20/km
  - 3주차: 주 4회, 평균 6km, 페이스 6:15/km
  - 4주차: 주 4회, 평균 6.5km, 페이스 6:10/km

### 7. 🏃‍♂️ 추천 러닝 루틴 (다양한 훈련 방법)
- **LSD (Long Slow Distance)**: 장거리 저강도 러닝
  - 목적, 거리, 페이스, 빈도 제시
- **인터벌 트레이닝**: 고강도 구간 반복
  - 예: 400m x 5회, 휴식 2분
- **템포런**: 중강도 지속 러닝
  - 목적, 거리, 페이스 제시
- **회복 러닝**: 가벼운 러닝
  - 목적, 거리, 페이스 제시

### 8. 🥗 영양 및 회복 전략 (4-5개)
- 러닝 전/중/후 영양 섭취 조언
- 수분 보충 전략
- 탄수화물, 단백질 섭취 타이밍
- 회복을 위한 수면, 휴식일 관리
- 보충제 추천 (필요 시)

### 9. 🧘 스트레칭 및 근력 운동 (3-4개)
- 러닝 전/후 필수 스트레칭 (부위별)
- 러닝 퍼포먼스 향상을 위한 근력 운동
- 예: 코어 운동, 스쿼트, 런지 등
- 빈도 및 세트 수 제시

### 10. ✅ 다음 주 실천 계획 (우선순위별 5개)
- 구체적이고 실행 가능한 주간 계획을 우선순위별로 제시해주세요.
- 예:
  1. **최우선**: 월/수/금 오후 7시에 5km 러닝 (페이스 6:30/km)
  2. **중요**: 화/목 오후 8시에 30분 근력 운동 (코어, 스쿼트)
  3. **권장**: 러닝 후 10분 스트레칭 (햄스트링, 종아리)
  4. **도전**: 토요일 아침 7km LSD 러닝 (페이스 7:00/km)
  5. **회복**: 일요일 완전 휴식 또는 30분 가벼운 워킹

---

**중요**: 모든 조언은 러너의 현재 수준, 신체 조건, 목표를 고려하여 맞춤화해주세요. 전문적이면서도 친절하고 격려하는 톤을 유지하며, 구체적인 수치와 예시를 포함해주세요.
''';
  }

  /// 대회 카테고리 프롬프트를 생성합니다. (추후 구현)
  ///
  /// **현재 상태**: 준비 중 (미구현)
  static String buildCompetitionPrompt(Map<String, dynamic> data) {
    // TODO: 대회 카테고리 프롬프트 구현
    throw UnimplementedError('대회 카테고리는 준비 중입니다');
  }

  /// 학습 카테고리 프롬프트를 생성합니다. (추후 구현)
  ///
  /// **현재 상태**: 준비 중 (미구현)
  static String buildStudyPrompt(Map<String, dynamic> data) {
    // TODO: 학습 카테고리 프롬프트 구현
    throw UnimplementedError('학습 카테고리는 준비 중입니다');
  }

  /// 자격증 카테고리 프롬프트를 생성합니다. (추후 구현)
  ///
  /// **현재 상태**: 준비 중 (미구현)
  static String buildCertificationPrompt(Map<String, dynamic> data) {
    // TODO: 자격증 카테고리 프롬프트 구현
    throw UnimplementedError('자격증 카테고리는 준비 중입니다');
  }

  /// 🏃 러닝 통계를 읽기 쉬운 텍스트로 변환합니다.
  ///
  /// **포맷**:
  /// ```
  /// - 총 러닝 일수: X일
  /// - 총 누적 거리: X.Xkm
  /// - 평균 거리: X.Xkm
  /// - 평균 페이스: X:XX/km
  /// - 평균 시간: X분
  /// - 총 소모 칼로리: Xkcal
  /// - 최대 거리: X.Xkm
  /// - 최근 트렌드: 증가/유지/감소
  /// ```
  static String _formatRunningStatistics(Map<String, dynamic> statistics) {
    final totalDays = statistics['totalDays'] as int;
    final totalDistance = statistics['totalDistance'] as double;
    final avgDistance = statistics['avgDistance'] as double;
    final avgPace = statistics['avgPace'] as double;
    final avgDuration = statistics['avgDuration'] as int;
    final totalCalories = statistics['totalCalories'] as int;
    final maxDistance = statistics['maxDistance'] as double;
    final recentTrend = statistics['recentTrend'] as String;

    // 페이스를 분:초 형식으로 변환
    final paceMinutes = avgPace.floor();
    final paceSeconds = ((avgPace - paceMinutes) * 60).round();
    final paceText = avgPace > 0
        ? '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}/km'
        : '데이터 없음';

    return '''
- 총 러닝 일수: $totalDays일
- 총 누적 거리: ${totalDistance.toStringAsFixed(1)}km
- 평균 거리: ${avgDistance.toStringAsFixed(1)}km
- 평균 페이스: $paceText
- 평균 시간: $avgDuration분
- 총 소모 칼로리: ${totalCalories}kcal
- 최대 거리: ${maxDistance.toStringAsFixed(1)}km
- 최근 트렌드: $recentTrend''';
  }

  /// 🏃 러닝 기록 리스트를 상세 텍스트로 변환합니다.
  ///
  /// **포맷**:
  /// ```
  /// - 2025-01-15: 5.2km, 30분 (페이스 5:46/km, 300kcal)
  /// - 2025-01-13: 3.5km, 22분 (페이스 6:17/km, 210kcal)
  /// ...
  /// ```
  ///
  /// **최대 10개 기록만 표시** (최신순)
  /// 🏃 러닝 기록 리스트를 상세 텍스트로 변환합니다 (RunningRecord 사용).
  ///
  /// **입력**: List<RunningRecord>
  /// **출력**: 최근 10개 러닝 기록을 읽기 쉬운 텍스트로 변환
  ///
  /// **예시**:
  /// ```
  /// - 2025-01-05: 5.2km, 30분 (페이스 5:46/km, 장소: 한강공원)
  /// - 2025-01-03: 8.0km, 50분 (페이스 6:15/km, 장소: 올림픽공원)
  /// ```
  static String _formatRunningLogs(List logs) {
    // RunningRecord 리스트로 캐스팅 (List<dynamic> → List<RunningRecord>)
    final runningRecords = logs.cast<RunningRecord>();

    if (runningRecords.isEmpty) {
      return '- 최근 러닝 기록이 없습니다.';
    }

    // 최신 10개만 표시
    final recentRecords = runningRecords.take(10).toList();

    return recentRecords.map((record) {
      final date = record.date.toString().substring(0, 10); // YYYY-MM-DD
      final distance = record.distanceKm.toStringAsFixed(1); // 5.2
      final duration = record.durationMinutes;

      // 페이스를 분:초 형식으로 변환
      final pace = record.averagePace;
      final paceMinutes = pace.floor();
      final paceSeconds = ((pace - paceMinutes) * 60).round();
      final paceText =
          '페이스 $paceMinutes:${paceSeconds.toString().padLeft(2, '0')}/km';

      // 장소 정보 (선택 사항)
      final location = record.location.isNotEmpty ? ', 장소: ${record.location}' : '';

      return '- $date: ${distance}km, $duration분 ($paceText$location)';
    }).join('\n');
  }
}
