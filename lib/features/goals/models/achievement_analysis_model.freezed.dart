// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_analysis_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AchievementAnalysisModel _$AchievementAnalysisModelFromJson(
    Map<String, dynamic> json) {
  return _AchievementAnalysisModel.fromJson(json);
}

/// @nodoc
mixin _$AchievementAnalysisModel {
  /// 분석 ID
  String get id => throw _privateConstructorUsedError;

  /// 분석 카테고리 (목표 카테고리와 동일)
  String get category => throw _privateConstructorUsedError;

  /// 분석 내용 (AI 생성 텍스트 또는 데모 placeholder)
  String get analysisContent => throw _privateConstructorUsedError;

  /// 포인트 비용
  int get pointsCost => throw _privateConstructorUsedError;

  /// 분석 일시
  DateTime get analyzedAt => throw _privateConstructorUsedError;

  /// 관련 목표 ID 리스트
  List<String> get relatedGoalIds => throw _privateConstructorUsedError;

  /// 관련 루틴 ID 리스트
  List<String> get relatedRoutineIds => throw _privateConstructorUsedError;

  /// Serializes this AchievementAnalysisModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AchievementAnalysisModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementAnalysisModelCopyWith<AchievementAnalysisModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementAnalysisModelCopyWith<$Res> {
  factory $AchievementAnalysisModelCopyWith(AchievementAnalysisModel value,
          $Res Function(AchievementAnalysisModel) then) =
      _$AchievementAnalysisModelCopyWithImpl<$Res, AchievementAnalysisModel>;
  @useResult
  $Res call(
      {String id,
      String category,
      String analysisContent,
      int pointsCost,
      DateTime analyzedAt,
      List<String> relatedGoalIds,
      List<String> relatedRoutineIds});
}

/// @nodoc
class _$AchievementAnalysisModelCopyWithImpl<$Res,
        $Val extends AchievementAnalysisModel>
    implements $AchievementAnalysisModelCopyWith<$Res> {
  _$AchievementAnalysisModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AchievementAnalysisModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? analysisContent = null,
    Object? pointsCost = null,
    Object? analyzedAt = null,
    Object? relatedGoalIds = null,
    Object? relatedRoutineIds = null,
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
      analysisContent: null == analysisContent
          ? _value.analysisContent
          : analysisContent // ignore: cast_nullable_to_non_nullable
              as String,
      pointsCost: null == pointsCost
          ? _value.pointsCost
          : pointsCost // ignore: cast_nullable_to_non_nullable
              as int,
      analyzedAt: null == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      relatedGoalIds: null == relatedGoalIds
          ? _value.relatedGoalIds
          : relatedGoalIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedRoutineIds: null == relatedRoutineIds
          ? _value.relatedRoutineIds
          : relatedRoutineIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementAnalysisModelImplCopyWith<$Res>
    implements $AchievementAnalysisModelCopyWith<$Res> {
  factory _$$AchievementAnalysisModelImplCopyWith(
          _$AchievementAnalysisModelImpl value,
          $Res Function(_$AchievementAnalysisModelImpl) then) =
      __$$AchievementAnalysisModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String category,
      String analysisContent,
      int pointsCost,
      DateTime analyzedAt,
      List<String> relatedGoalIds,
      List<String> relatedRoutineIds});
}

/// @nodoc
class __$$AchievementAnalysisModelImplCopyWithImpl<$Res>
    extends _$AchievementAnalysisModelCopyWithImpl<$Res,
        _$AchievementAnalysisModelImpl>
    implements _$$AchievementAnalysisModelImplCopyWith<$Res> {
  __$$AchievementAnalysisModelImplCopyWithImpl(
      _$AchievementAnalysisModelImpl _value,
      $Res Function(_$AchievementAnalysisModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AchievementAnalysisModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? analysisContent = null,
    Object? pointsCost = null,
    Object? analyzedAt = null,
    Object? relatedGoalIds = null,
    Object? relatedRoutineIds = null,
  }) {
    return _then(_$AchievementAnalysisModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      analysisContent: null == analysisContent
          ? _value.analysisContent
          : analysisContent // ignore: cast_nullable_to_non_nullable
              as String,
      pointsCost: null == pointsCost
          ? _value.pointsCost
          : pointsCost // ignore: cast_nullable_to_non_nullable
              as int,
      analyzedAt: null == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      relatedGoalIds: null == relatedGoalIds
          ? _value._relatedGoalIds
          : relatedGoalIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedRoutineIds: null == relatedRoutineIds
          ? _value._relatedRoutineIds
          : relatedRoutineIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementAnalysisModelImpl implements _AchievementAnalysisModel {
  const _$AchievementAnalysisModelImpl(
      {required this.id,
      required this.category,
      required this.analysisContent,
      this.pointsCost = 30,
      required this.analyzedAt,
      final List<String> relatedGoalIds = const [],
      final List<String> relatedRoutineIds = const []})
      : _relatedGoalIds = relatedGoalIds,
        _relatedRoutineIds = relatedRoutineIds;

  factory _$AchievementAnalysisModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementAnalysisModelImplFromJson(json);

  /// 분석 ID
  @override
  final String id;

  /// 분석 카테고리 (목표 카테고리와 동일)
  @override
  final String category;

  /// 분석 내용 (AI 생성 텍스트 또는 데모 placeholder)
  @override
  final String analysisContent;

  /// 포인트 비용
  @override
  @JsonKey()
  final int pointsCost;

  /// 분석 일시
  @override
  final DateTime analyzedAt;

  /// 관련 목표 ID 리스트
  final List<String> _relatedGoalIds;

  /// 관련 목표 ID 리스트
  @override
  @JsonKey()
  List<String> get relatedGoalIds {
    if (_relatedGoalIds is EqualUnmodifiableListView) return _relatedGoalIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedGoalIds);
  }

  /// 관련 루틴 ID 리스트
  final List<String> _relatedRoutineIds;

  /// 관련 루틴 ID 리스트
  @override
  @JsonKey()
  List<String> get relatedRoutineIds {
    if (_relatedRoutineIds is EqualUnmodifiableListView)
      return _relatedRoutineIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedRoutineIds);
  }

  @override
  String toString() {
    return 'AchievementAnalysisModel(id: $id, category: $category, analysisContent: $analysisContent, pointsCost: $pointsCost, analyzedAt: $analyzedAt, relatedGoalIds: $relatedGoalIds, relatedRoutineIds: $relatedRoutineIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementAnalysisModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.analysisContent, analysisContent) ||
                other.analysisContent == analysisContent) &&
            (identical(other.pointsCost, pointsCost) ||
                other.pointsCost == pointsCost) &&
            (identical(other.analyzedAt, analyzedAt) ||
                other.analyzedAt == analyzedAt) &&
            const DeepCollectionEquality()
                .equals(other._relatedGoalIds, _relatedGoalIds) &&
            const DeepCollectionEquality()
                .equals(other._relatedRoutineIds, _relatedRoutineIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      category,
      analysisContent,
      pointsCost,
      analyzedAt,
      const DeepCollectionEquality().hash(_relatedGoalIds),
      const DeepCollectionEquality().hash(_relatedRoutineIds));

  /// Create a copy of AchievementAnalysisModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementAnalysisModelImplCopyWith<_$AchievementAnalysisModelImpl>
      get copyWith => __$$AchievementAnalysisModelImplCopyWithImpl<
          _$AchievementAnalysisModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementAnalysisModelImplToJson(
      this,
    );
  }
}

abstract class _AchievementAnalysisModel implements AchievementAnalysisModel {
  const factory _AchievementAnalysisModel(
      {required final String id,
      required final String category,
      required final String analysisContent,
      final int pointsCost,
      required final DateTime analyzedAt,
      final List<String> relatedGoalIds,
      final List<String> relatedRoutineIds}) = _$AchievementAnalysisModelImpl;

  factory _AchievementAnalysisModel.fromJson(Map<String, dynamic> json) =
      _$AchievementAnalysisModelImpl.fromJson;

  /// 분석 ID
  @override
  String get id;

  /// 분석 카테고리 (목표 카테고리와 동일)
  @override
  String get category;

  /// 분석 내용 (AI 생성 텍스트 또는 데모 placeholder)
  @override
  String get analysisContent;

  /// 포인트 비용
  @override
  int get pointsCost;

  /// 분석 일시
  @override
  DateTime get analyzedAt;

  /// 관련 목표 ID 리스트
  @override
  List<String> get relatedGoalIds;

  /// 관련 루틴 ID 리스트
  @override
  List<String> get relatedRoutineIds;

  /// Create a copy of AchievementAnalysisModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementAnalysisModelImplCopyWith<_$AchievementAnalysisModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
