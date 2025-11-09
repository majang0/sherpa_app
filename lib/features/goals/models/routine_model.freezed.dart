// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoutineModel _$RoutineModelFromJson(Map<String, dynamic> json) {
  return _RoutineModel.fromJson(json);
}

/// @nodoc
mixin _$RoutineModel {
  /// 고유 ID (UUID)
  String get id => throw _privateConstructorUsedError;

  /// 카테고리 (운동, 문화, 학습, 건강, 기타)
  String get category => throw _privateConstructorUsedError;

  /// 주기 (매일, 주N회, 매주[요일], 월N회)
  String get frequency => throw _privateConstructorUsedError;

  /// 루틴 이름 (예: "매주 화 수 금 오전 7시 러닝")
  String get name => throw _privateConstructorUsedError;

  /// 시간 선호 (눈 뜨자마자, 시간 설정, 아무때나, 자기 전)
  String? get timePreference => throw _privateConstructorUsedError;

  /// 구체적인 시간 (시간 설정을 선택한 경우)
  DateTime? get specificTime => throw _privateConstructorUsedError;

  /// 요일 리스트 (매주 [요일] 선택 시)
  /// 예: ['월', '화', '수']
  List<String> get weekdays => throw _privateConstructorUsedError;

  /// 기간 (언제까지, 계속)
  String? get period => throw _privateConstructorUsedError;

  /// 종료 날짜 (기간을 '언제까지'로 선택한 경우)
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// 체크 기록 (ISO 날짜 리스트)
  /// 예: ['2025-11-01', '2025-11-02']
  List<String> get checkHistory => throw _privateConstructorUsedError;

  /// 완료율 (0.0 ~ 1.0)
  double get completionRate => throw _privateConstructorUsedError;

  /// 완주 여부 (기간이 끝났고 목표 달성률 100%)
  bool get isCompleted => throw _privateConstructorUsedError;

  /// 생성 일시
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// 삭제/완료 일시
  DateTime? get finishedAt => throw _privateConstructorUsedError;

  /// Serializes this RoutineModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoutineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoutineModelCopyWith<RoutineModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutineModelCopyWith<$Res> {
  factory $RoutineModelCopyWith(
          RoutineModel value, $Res Function(RoutineModel) then) =
      _$RoutineModelCopyWithImpl<$Res, RoutineModel>;
  @useResult
  $Res call(
      {String id,
      String category,
      String frequency,
      String name,
      String? timePreference,
      DateTime? specificTime,
      List<String> weekdays,
      String? period,
      DateTime? endDate,
      List<String> checkHistory,
      double completionRate,
      bool isCompleted,
      DateTime? createdAt,
      DateTime? finishedAt});
}

/// @nodoc
class _$RoutineModelCopyWithImpl<$Res, $Val extends RoutineModel>
    implements $RoutineModelCopyWith<$Res> {
  _$RoutineModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoutineModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? frequency = null,
    Object? name = null,
    Object? timePreference = freezed,
    Object? specificTime = freezed,
    Object? weekdays = null,
    Object? period = freezed,
    Object? endDate = freezed,
    Object? checkHistory = null,
    Object? completionRate = null,
    Object? isCompleted = null,
    Object? createdAt = freezed,
    Object? finishedAt = freezed,
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
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      timePreference: freezed == timePreference
          ? _value.timePreference
          : timePreference // ignore: cast_nullable_to_non_nullable
              as String?,
      specificTime: freezed == specificTime
          ? _value.specificTime
          : specificTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weekdays: null == weekdays
          ? _value.weekdays
          : weekdays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      period: freezed == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkHistory: null == checkHistory
          ? _value.checkHistory
          : checkHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      finishedAt: freezed == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoutineModelImplCopyWith<$Res>
    implements $RoutineModelCopyWith<$Res> {
  factory _$$RoutineModelImplCopyWith(
          _$RoutineModelImpl value, $Res Function(_$RoutineModelImpl) then) =
      __$$RoutineModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String category,
      String frequency,
      String name,
      String? timePreference,
      DateTime? specificTime,
      List<String> weekdays,
      String? period,
      DateTime? endDate,
      List<String> checkHistory,
      double completionRate,
      bool isCompleted,
      DateTime? createdAt,
      DateTime? finishedAt});
}

/// @nodoc
class __$$RoutineModelImplCopyWithImpl<$Res>
    extends _$RoutineModelCopyWithImpl<$Res, _$RoutineModelImpl>
    implements _$$RoutineModelImplCopyWith<$Res> {
  __$$RoutineModelImplCopyWithImpl(
      _$RoutineModelImpl _value, $Res Function(_$RoutineModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoutineModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? frequency = null,
    Object? name = null,
    Object? timePreference = freezed,
    Object? specificTime = freezed,
    Object? weekdays = null,
    Object? period = freezed,
    Object? endDate = freezed,
    Object? checkHistory = null,
    Object? completionRate = null,
    Object? isCompleted = null,
    Object? createdAt = freezed,
    Object? finishedAt = freezed,
  }) {
    return _then(_$RoutineModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      timePreference: freezed == timePreference
          ? _value.timePreference
          : timePreference // ignore: cast_nullable_to_non_nullable
              as String?,
      specificTime: freezed == specificTime
          ? _value.specificTime
          : specificTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weekdays: null == weekdays
          ? _value._weekdays
          : weekdays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      period: freezed == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkHistory: null == checkHistory
          ? _value._checkHistory
          : checkHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      finishedAt: freezed == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutineModelImpl implements _RoutineModel {
  const _$RoutineModelImpl(
      {required this.id,
      required this.category,
      required this.frequency,
      required this.name,
      this.timePreference,
      this.specificTime = null,
      final List<String> weekdays = const [],
      this.period,
      this.endDate = null,
      final List<String> checkHistory = const [],
      this.completionRate = 0.0,
      this.isCompleted = false,
      this.createdAt = null,
      this.finishedAt = null})
      : _weekdays = weekdays,
        _checkHistory = checkHistory;

  factory _$RoutineModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutineModelImplFromJson(json);

  /// 고유 ID (UUID)
  @override
  final String id;

  /// 카테고리 (운동, 문화, 학습, 건강, 기타)
  @override
  final String category;

  /// 주기 (매일, 주N회, 매주[요일], 월N회)
  @override
  final String frequency;

  /// 루틴 이름 (예: "매주 화 수 금 오전 7시 러닝")
  @override
  final String name;

  /// 시간 선호 (눈 뜨자마자, 시간 설정, 아무때나, 자기 전)
  @override
  final String? timePreference;

  /// 구체적인 시간 (시간 설정을 선택한 경우)
  @override
  @JsonKey()
  final DateTime? specificTime;

  /// 요일 리스트 (매주 [요일] 선택 시)
  /// 예: ['월', '화', '수']
  final List<String> _weekdays;

  /// 요일 리스트 (매주 [요일] 선택 시)
  /// 예: ['월', '화', '수']
  @override
  @JsonKey()
  List<String> get weekdays {
    if (_weekdays is EqualUnmodifiableListView) return _weekdays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekdays);
  }

  /// 기간 (언제까지, 계속)
  @override
  final String? period;

  /// 종료 날짜 (기간을 '언제까지'로 선택한 경우)
  @override
  @JsonKey()
  final DateTime? endDate;

  /// 체크 기록 (ISO 날짜 리스트)
  /// 예: ['2025-11-01', '2025-11-02']
  final List<String> _checkHistory;

  /// 체크 기록 (ISO 날짜 리스트)
  /// 예: ['2025-11-01', '2025-11-02']
  @override
  @JsonKey()
  List<String> get checkHistory {
    if (_checkHistory is EqualUnmodifiableListView) return _checkHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_checkHistory);
  }

  /// 완료율 (0.0 ~ 1.0)
  @override
  @JsonKey()
  final double completionRate;

  /// 완주 여부 (기간이 끝났고 목표 달성률 100%)
  @override
  @JsonKey()
  final bool isCompleted;

  /// 생성 일시
  @override
  @JsonKey()
  final DateTime? createdAt;

  /// 삭제/완료 일시
  @override
  @JsonKey()
  final DateTime? finishedAt;

  @override
  String toString() {
    return 'RoutineModel(id: $id, category: $category, frequency: $frequency, name: $name, timePreference: $timePreference, specificTime: $specificTime, weekdays: $weekdays, period: $period, endDate: $endDate, checkHistory: $checkHistory, completionRate: $completionRate, isCompleted: $isCompleted, createdAt: $createdAt, finishedAt: $finishedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutineModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timePreference, timePreference) ||
                other.timePreference == timePreference) &&
            (identical(other.specificTime, specificTime) ||
                other.specificTime == specificTime) &&
            const DeepCollectionEquality().equals(other._weekdays, _weekdays) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality()
                .equals(other._checkHistory, _checkHistory) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      category,
      frequency,
      name,
      timePreference,
      specificTime,
      const DeepCollectionEquality().hash(_weekdays),
      period,
      endDate,
      const DeepCollectionEquality().hash(_checkHistory),
      completionRate,
      isCompleted,
      createdAt,
      finishedAt);

  /// Create a copy of RoutineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutineModelImplCopyWith<_$RoutineModelImpl> get copyWith =>
      __$$RoutineModelImplCopyWithImpl<_$RoutineModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutineModelImplToJson(
      this,
    );
  }
}

abstract class _RoutineModel implements RoutineModel {
  const factory _RoutineModel(
      {required final String id,
      required final String category,
      required final String frequency,
      required final String name,
      final String? timePreference,
      final DateTime? specificTime,
      final List<String> weekdays,
      final String? period,
      final DateTime? endDate,
      final List<String> checkHistory,
      final double completionRate,
      final bool isCompleted,
      final DateTime? createdAt,
      final DateTime? finishedAt}) = _$RoutineModelImpl;

  factory _RoutineModel.fromJson(Map<String, dynamic> json) =
      _$RoutineModelImpl.fromJson;

  /// 고유 ID (UUID)
  @override
  String get id;

  /// 카테고리 (운동, 문화, 학습, 건강, 기타)
  @override
  String get category;

  /// 주기 (매일, 주N회, 매주[요일], 월N회)
  @override
  String get frequency;

  /// 루틴 이름 (예: "매주 화 수 금 오전 7시 러닝")
  @override
  String get name;

  /// 시간 선호 (눈 뜨자마자, 시간 설정, 아무때나, 자기 전)
  @override
  String? get timePreference;

  /// 구체적인 시간 (시간 설정을 선택한 경우)
  @override
  DateTime? get specificTime;

  /// 요일 리스트 (매주 [요일] 선택 시)
  /// 예: ['월', '화', '수']
  @override
  List<String> get weekdays;

  /// 기간 (언제까지, 계속)
  @override
  String? get period;

  /// 종료 날짜 (기간을 '언제까지'로 선택한 경우)
  @override
  DateTime? get endDate;

  /// 체크 기록 (ISO 날짜 리스트)
  /// 예: ['2025-11-01', '2025-11-02']
  @override
  List<String> get checkHistory;

  /// 완료율 (0.0 ~ 1.0)
  @override
  double get completionRate;

  /// 완주 여부 (기간이 끝났고 목표 달성률 100%)
  @override
  bool get isCompleted;

  /// 생성 일시
  @override
  DateTime? get createdAt;

  /// 삭제/완료 일시
  @override
  DateTime? get finishedAt;

  /// Create a copy of RoutineModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoutineModelImplCopyWith<_$RoutineModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
