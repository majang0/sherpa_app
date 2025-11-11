// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) {
  return _GoalModel.fromJson(json);
}

/// @nodoc
mixin _$GoalModel {
  /// 고유 ID (UUID)
  String get id => throw _privateConstructorUsedError;

  /// 카테고리 (운동, 학습, 대회, 자격증)
  String get category => throw _privateConstructorUsedError;

  /// 목표 날짜
  DateTime get date => throw _privateConstructorUsedError;

  /// 목표 이름 (예: "전국 AI활용 아이디어 경진대회 대상")
  String get name => throw _privateConstructorUsedError;

  /// 목표값 (예: "1시간 40분", "대상", "90점 이상")
  String get targetValue => throw _privateConstructorUsedError;

  /// 달성 여부
  bool get isAchieved => throw _privateConstructorUsedError;

  /// 달성률 (0.0 ~ 1.0)
  double get achievementRate => throw _privateConstructorUsedError;

  /// 달성/미달성 상세 내용
  String? get achievementDetails => throw _privateConstructorUsedError;

  /// 성공/실패 이유
  String? get reasonForResult => throw _privateConstructorUsedError;

  /// 생성 일시
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// 완료 일시 (달성 또는 미달성 처리된 시점)
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// 대표 목표 여부
  bool get isRepresentative => throw _privateConstructorUsedError;

  /// Serializes this GoalModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalModelCopyWith<GoalModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalModelCopyWith<$Res> {
  factory $GoalModelCopyWith(GoalModel value, $Res Function(GoalModel) then) =
      _$GoalModelCopyWithImpl<$Res, GoalModel>;
  @useResult
  $Res call(
      {String id,
      String category,
      DateTime date,
      String name,
      String targetValue,
      bool isAchieved,
      double achievementRate,
      String? achievementDetails,
      String? reasonForResult,
      DateTime? createdAt,
      DateTime? completedAt,
      bool isRepresentative});
}

/// @nodoc
class _$GoalModelCopyWithImpl<$Res, $Val extends GoalModel>
    implements $GoalModelCopyWith<$Res> {
  _$GoalModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? date = null,
    Object? name = null,
    Object? targetValue = null,
    Object? isAchieved = null,
    Object? achievementRate = null,
    Object? achievementDetails = freezed,
    Object? reasonForResult = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
    Object? isRepresentative = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as String,
      isAchieved: null == isAchieved
          ? _value.isAchieved
          : isAchieved // ignore: cast_nullable_to_non_nullable
              as bool,
      achievementRate: null == achievementRate
          ? _value.achievementRate
          : achievementRate // ignore: cast_nullable_to_non_nullable
              as double,
      achievementDetails: freezed == achievementDetails
          ? _value.achievementDetails
          : achievementDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      reasonForResult: freezed == reasonForResult
          ? _value.reasonForResult
          : reasonForResult // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isRepresentative: null == isRepresentative
          ? _value.isRepresentative
          : isRepresentative // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalModelImplCopyWith<$Res>
    implements $GoalModelCopyWith<$Res> {
  factory _$$GoalModelImplCopyWith(
          _$GoalModelImpl value, $Res Function(_$GoalModelImpl) then) =
      __$$GoalModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String category,
      DateTime date,
      String name,
      String targetValue,
      bool isAchieved,
      double achievementRate,
      String? achievementDetails,
      String? reasonForResult,
      DateTime? createdAt,
      DateTime? completedAt,
      bool isRepresentative});
}

/// @nodoc
class __$$GoalModelImplCopyWithImpl<$Res>
    extends _$GoalModelCopyWithImpl<$Res, _$GoalModelImpl>
    implements _$$GoalModelImplCopyWith<$Res> {
  __$$GoalModelImplCopyWithImpl(
      _$GoalModelImpl _value, $Res Function(_$GoalModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? date = null,
    Object? name = null,
    Object? targetValue = null,
    Object? isAchieved = null,
    Object? achievementRate = null,
    Object? achievementDetails = freezed,
    Object? reasonForResult = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
    Object? isRepresentative = null,
  }) {
    return _then(_$GoalModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as String,
      isAchieved: null == isAchieved
          ? _value.isAchieved
          : isAchieved // ignore: cast_nullable_to_non_nullable
              as bool,
      achievementRate: null == achievementRate
          ? _value.achievementRate
          : achievementRate // ignore: cast_nullable_to_non_nullable
              as double,
      achievementDetails: freezed == achievementDetails
          ? _value.achievementDetails
          : achievementDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      reasonForResult: freezed == reasonForResult
          ? _value.reasonForResult
          : reasonForResult // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isRepresentative: null == isRepresentative
          ? _value.isRepresentative
          : isRepresentative // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalModelImpl implements _GoalModel {
  const _$GoalModelImpl(
      {required this.id,
      required this.category,
      required this.date,
      required this.name,
      required this.targetValue,
      this.isAchieved = false,
      this.achievementRate = 0.0,
      this.achievementDetails,
      this.reasonForResult,
      this.createdAt = null,
      this.completedAt = null,
      this.isRepresentative = false});

  factory _$GoalModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalModelImplFromJson(json);

  /// 고유 ID (UUID)
  @override
  final String id;

  /// 카테고리 (운동, 학습, 대회, 자격증)
  @override
  final String category;

  /// 목표 날짜
  @override
  final DateTime date;

  /// 목표 이름 (예: "전국 AI활용 아이디어 경진대회 대상")
  @override
  final String name;

  /// 목표값 (예: "1시간 40분", "대상", "90점 이상")
  @override
  final String targetValue;

  /// 달성 여부
  @override
  @JsonKey()
  final bool isAchieved;

  /// 달성률 (0.0 ~ 1.0)
  @override
  @JsonKey()
  final double achievementRate;

  /// 달성/미달성 상세 내용
  @override
  final String? achievementDetails;

  /// 성공/실패 이유
  @override
  final String? reasonForResult;

  /// 생성 일시
  @override
  @JsonKey()
  final DateTime? createdAt;

  /// 완료 일시 (달성 또는 미달성 처리된 시점)
  @override
  @JsonKey()
  final DateTime? completedAt;

  /// 대표 목표 여부
  @override
  @JsonKey()
  final bool isRepresentative;

  @override
  String toString() {
    return 'GoalModel(id: $id, category: $category, date: $date, name: $name, targetValue: $targetValue, isAchieved: $isAchieved, achievementRate: $achievementRate, achievementDetails: $achievementDetails, reasonForResult: $reasonForResult, createdAt: $createdAt, completedAt: $completedAt, isRepresentative: $isRepresentative)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.isAchieved, isAchieved) ||
                other.isAchieved == isAchieved) &&
            (identical(other.achievementRate, achievementRate) ||
                other.achievementRate == achievementRate) &&
            (identical(other.achievementDetails, achievementDetails) ||
                other.achievementDetails == achievementDetails) &&
            (identical(other.reasonForResult, reasonForResult) ||
                other.reasonForResult == reasonForResult) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.isRepresentative, isRepresentative) ||
                other.isRepresentative == isRepresentative));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      category,
      date,
      name,
      targetValue,
      isAchieved,
      achievementRate,
      achievementDetails,
      reasonForResult,
      createdAt,
      completedAt,
      isRepresentative);

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalModelImplCopyWith<_$GoalModelImpl> get copyWith =>
      __$$GoalModelImplCopyWithImpl<_$GoalModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalModelImplToJson(
      this,
    );
  }
}

abstract class _GoalModel implements GoalModel {
  const factory _GoalModel(
      {required final String id,
      required final String category,
      required final DateTime date,
      required final String name,
      required final String targetValue,
      final bool isAchieved,
      final double achievementRate,
      final String? achievementDetails,
      final String? reasonForResult,
      final DateTime? createdAt,
      final DateTime? completedAt,
      final bool isRepresentative}) = _$GoalModelImpl;

  factory _GoalModel.fromJson(Map<String, dynamic> json) =
      _$GoalModelImpl.fromJson;

  /// 고유 ID (UUID)
  @override
  String get id;

  /// 카테고리 (운동, 학습, 대회, 자격증)
  @override
  String get category;

  /// 목표 날짜
  @override
  DateTime get date;

  /// 목표 이름 (예: "전국 AI활용 아이디어 경진대회 대상")
  @override
  String get name;

  /// 목표값 (예: "1시간 40분", "대상", "90점 이상")
  @override
  String get targetValue;

  /// 달성 여부
  @override
  bool get isAchieved;

  /// 달성률 (0.0 ~ 1.0)
  @override
  double get achievementRate;

  /// 달성/미달성 상세 내용
  @override
  String? get achievementDetails;

  /// 성공/실패 이유
  @override
  String? get reasonForResult;

  /// 생성 일시
  @override
  DateTime? get createdAt;

  /// 완료 일시 (달성 또는 미달성 처리된 시점)
  @override
  DateTime? get completedAt;

  /// 대표 목표 여부
  @override
  bool get isRepresentative;

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalModelImplCopyWith<_$GoalModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
