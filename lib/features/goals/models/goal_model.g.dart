// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalModelImpl _$$GoalModelImplFromJson(Map<String, dynamic> json) =>
    _$GoalModelImpl(
      id: json['id'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      name: json['name'] as String,
      targetValue: json['targetValue'] as String,
      isAchieved: json['isAchieved'] as bool? ?? false,
      achievementRate: (json['achievementRate'] as num?)?.toDouble() ?? 0.0,
      achievementDetails: json['achievementDetails'] as String?,
      reasonForResult: json['reasonForResult'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      isRepresentative: json['isRepresentative'] as bool? ?? false,
    );

Map<String, dynamic> _$$GoalModelImplToJson(_$GoalModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'date': instance.date.toIso8601String(),
      'name': instance.name,
      'targetValue': instance.targetValue,
      'isAchieved': instance.isAchieved,
      'achievementRate': instance.achievementRate,
      'achievementDetails': instance.achievementDetails,
      'reasonForResult': instance.reasonForResult,
      'createdAt': instance.createdAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'isRepresentative': instance.isRepresentative,
    };
