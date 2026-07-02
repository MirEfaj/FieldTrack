import 'package:json_annotation/json_annotation.dart';
import 'package:field_track/features/todos/domain/entities/todo_entity.dart';

part 'todo_model.g.dart';

@JsonSerializable()
class TodoModel {
  const TodoModel({
    required this.id,
    required this.title,
    @JsonKey(name: 'is_completed') required this.isCompleted,
    this.description,
    @JsonKey(name: 'due_time') this.dueTime,
    @JsonKey(name: 'completed_at') this.completedAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @JsonKey(name: 'due_time')
  final DateTime? dueTime;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  TodoEntity toEntity({TodoSyncStatus syncStatus = TodoSyncStatus.synced}) =>
      TodoEntity(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted,
        dueTime: dueTime,
        completedAt: completedAt,
        updatedAt: updatedAt,
        syncStatus: syncStatus,
      );

  TodoModel copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) =>
      TodoModel(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted ?? this.isCompleted,
        dueTime: dueTime,
        completedAt: completedAt ?? this.completedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
