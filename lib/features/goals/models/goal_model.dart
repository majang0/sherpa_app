import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

/// 목표 모델
///
/// 사용자가 설정한 목표를 관리합니다.
/// 카테고리: 운동, 학습, 대회, 자격증
@freezed
class GoalModel with _$GoalModel {
  const factory GoalModel({
    /// 고유 ID (UUID)
    required String id,

    /// 카테고리 (운동, 학습, 대회, 자격증)
    required String category,

    /// 목표 날짜
    required DateTime date,

    /// 목표 이름 (예: "전국 AI활용 아이디어 경진대회 대상")
    required String name,

    /// 목표값 (예: "1시간 40분", "대상", "90점 이상")
    required String targetValue,

    /// 달성 여부
    @Default(false) bool isAchieved,

    /// 달성률 (0.0 ~ 1.0)
    @Default(0.0) double achievementRate,

    /// 달성/미달성 상세 내용
    String? achievementDetails,

    /// 성공/실패 이유
    String? reasonForResult,

    /// 생성 일시
    @Default(null) DateTime? createdAt,

    /// 완료 일시 (달성 또는 미달성 처리된 시점)
    @Default(null) DateTime? completedAt,
  }) = _GoalModel;

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);
}

/// 목표 카테고리 상수
class GoalCategory {
  static const String exercise = '운동';
  static const String study = '학습';
  static const String competition = '대회';
  static const String certification = '자격증';

  static const List<String> all = [
    exercise,
    study,
    competition,
    certification,
  ];
}
