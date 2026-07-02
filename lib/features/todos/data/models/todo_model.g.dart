// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoModel _$TodoModelFromJson(Map<String, dynamic> json) => TodoModel(
  id: json['id'] as String,
  title: json['title'] as String,
  isCompleted: json['is_completed'] as bool,
  description: json['description'] as String?,
  dueTime: json['due_time'] == null
      ? null
      : DateTime.parse(json['due_time'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TodoModelToJson(TodoModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'is_completed': instance.isCompleted,
  'due_time': instance.dueTime?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
