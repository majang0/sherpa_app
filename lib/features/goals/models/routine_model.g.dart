// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoutineModelImpl _$$RoutineModelImplFromJson(Map<String, dynamic> json) =>
    _$RoutineModelImpl(
      id: json['id'] as String,
      category: json['category'] as String,
      frequency: json['frequency'] as String,
      name: json['name'] as String,
      timePreference: json['timePreference'] as String?,
      specificTime: json['specificTime'] == null
          ? null
          : DateTime.parse(json['specificTime'] as String),
      weekdays: (json['weekdays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      period: json['period'] as String?,
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      checkHistory: (json['checkHistory'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      finishedAt: json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
    );

Map<String, dynamic> _$$RoutineModelImplToJson(_$RoutineModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'frequency': instance.frequency,
      'name': instance.name,
      'timePreference': instance.timePreference,
      'specificTime': instance.specificTime?.toIso8601String(),
      'weekdays': instance.weekdays,
      'period': instance.period,
      'endDate': instance.endDate?.toIso8601String(),
      'checkHistory': instance.checkHistory,
      'completionRate': instance.completionRate,
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
    };
