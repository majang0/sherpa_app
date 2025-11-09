// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementAnalysisModelImpl _$$AchievementAnalysisModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AchievementAnalysisModelImpl(
      id: json['id'] as String,
      category: json['category'] as String,
      analysisContent: json['analysisContent'] as String,
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 30,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      relatedGoalIds: (json['relatedGoalIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      relatedRoutineIds: (json['relatedRoutineIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AchievementAnalysisModelImplToJson(
        _$AchievementAnalysisModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'analysisContent': instance.analysisContent,
      'pointsCost': instance.pointsCost,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
      'relatedGoalIds': instance.relatedGoalIds,
      'relatedRoutineIds': instance.relatedRoutineIds,
    };
