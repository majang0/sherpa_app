import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_model.freezed.dart';
part 'routine_model.g.dart';

/// 루틴 모델
///
/// 사용자가 설정한 루틴을 관리합니다.
/// 카테고리: 운동, 문화, 학습, 건강, 기타
@freezed
class RoutineModel with _$RoutineModel {
  const factory RoutineModel({
    /// 고유 ID (UUID)
    required String id,

    /// 카테고리 (운동, 문화, 학습, 건강, 기타)
    required String category,

    /// 주기 (매일, 주N회, 매주[요일], 월N회)
    required String frequency,

    /// 루틴 이름 (예: "매주 화 수 금 오전 7시 러닝")
    required String name,

    /// 시간 선호 (눈 뜨자마자, 시간 설정, 아무때나, 자기 전)
    String? timePreference,

    /// 구체적인 시간 (시간 설정을 선택한 경우)
    @Default(null) DateTime? specificTime,

    /// 요일 리스트 (매주 [요일] 선택 시)
    /// 예: ['월', '화', '수']
    @Default([]) List<String> weekdays,

    /// 기간 (언제까지, 계속)
    String? period,

    /// 종료 날짜 (기간을 '언제까지'로 선택한 경우)
    @Default(null) DateTime? endDate,

    /// 체크 기록 (ISO 날짜 리스트)
    /// 예: ['2025-11-01', '2025-11-02']
    @Default([]) List<String> checkHistory,

    /// 완료율 (0.0 ~ 1.0)
    @Default(0.0) double completionRate,

    /// 완주 여부 (기간이 끝났고 목표 달성률 100%)
    @Default(false) bool isCompleted,

    /// 생성 일시
    @Default(null) DateTime? createdAt,

    /// 삭제/완료 일시
    @Default(null) DateTime? finishedAt,
  }) = _RoutineModel;

  factory RoutineModel.fromJson(Map<String, dynamic> json) =>
      _$RoutineModelFromJson(json);
}

/// RoutineModel 확장 메서드
extension RoutineModelX on RoutineModel {
  /// 오늘 체크리스트에 표시되어야 하는지 확인
  bool shouldShowToday() {
    final now = DateTime.now();
    final today = now.weekday; // 1(월) ~ 7(일)

    // 종료된 루틴은 표시 안함
    if (finishedAt != null) return false;

    // 기간이 끝난 루틴은 표시 안함
    if (endDate != null && now.isAfter(endDate!)) return false;

    // 주기별 확인
    if (frequency == '매일') return true;

    if (frequency.startsWith('주') && frequency.contains('회')) {
      // 주N회: 항상 표시 (사용자가 원하는 날짜에 체크)
      return true;
    }

    if (frequency.startsWith('매주')) {
      // 매주 [요일]: 해당 요일인지 확인
      final weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
      final todayName = weekdayNames[today - 1];
      return weekdays.contains(todayName);
    }

    if (frequency.startsWith('월') && frequency.contains('회')) {
      // 월N회: 항상 표시
      return true;
    }

    return false;
  }

  /// 오늘 체크했는지 확인
  bool isCheckedToday() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return checkHistory.contains(today);
  }

  /// 시간 우선순위 (정렬용)
  /// 0: 눈 뜨자마자, 1: 시간 설정 (이른 순), 2: 아무때나, 3: 자기 전
  int get timePriority {
    if (timePreference == '눈 뜨자마자') return 0;
    if (timePreference == '시간 설정') {
      if (specificTime != null) {
        return 1000 + specificTime!.hour * 60 + specificTime!.minute;
      }
      return 1000;
    }
    if (timePreference == '아무때나') return 10000;
    if (timePreference == '자기 전') return 20000;
    return 15000; // 기본값
  }

  /// 주기 우선순위 (정렬용)
  /// 1: 매일, 2: 주N회, 3: 매주 [요일], 4: 월N회
  int get frequencyPriority {
    if (frequency == '매일') return 1;
    if (frequency.startsWith('주') && frequency.contains('회')) return 2;
    if (frequency.startsWith('매주')) return 3;
    if (frequency.startsWith('월') && frequency.contains('회')) return 4;
    return 5;
  }
}

/// 루틴 카테고리 상수
class RoutineCategory {
  static const String exercise = '운동';
  static const String culture = '문화';
  static const String study = '학습';
  static const String health = '건강';
  static const String etc = '기타';

  static const List<String> all = [
    exercise,
    culture,
    study,
    health,
    etc,
  ];
}

/// 루틴 시간 선호 상수
class RoutineTimePreference {
  static const String wakeUp = '눈 뜨자마자';
  static const String specificTime = '시간 설정';
  static const String anytime = '아무때나';
  static const String beforeSleep = '자기 전';

  static const List<String> all = [
    wakeUp,
    specificTime,
    anytime,
    beforeSleep,
  ];
}

/// 루틴 기간 상수
class RoutinePeriod {
  static const String until = '언제까지';
  static const String forever = '계속';

  static const List<String> all = [
    until,
    forever,
  ];
}

/// 루틴 빈도 상수
class RoutineFrequency {
  static const String daily = '매일';
  static const String weekdays = '요일선택';
  static const String weekly2 = '주2회';
  static const String weekly3 = '주3회';
  static const String weekly4 = '주4회';
  static const String monthly2 = '월2회';
  static const String monthly4 = '월4회';

  static const List<String> all = [
    daily,
    weekdays,
    weekly2,
    weekly3,
    weekly4,
    monthly2,
    monthly4,
  ];
}
