import 'package:equatable/equatable.dart';

enum TodoFilter { all, pending, completed }

enum TodoSyncStatus { synced, pending, syncing, failed }

class TodoEntity extends Equatable {
  const TodoEntity({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.description,
    this.dueTime,
    this.completedAt,
    this.updatedAt,
    this.syncStatus = TodoSyncStatus.synced,
  });

  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueTime;
  final DateTime? completedAt;
  final DateTime? updatedAt;
  final TodoSyncStatus syncStatus;

  TodoEntity copyWith({
    String? title,
    bool? isCompleted,
    String? description,
    DateTime? dueTime,
    DateTime? completedAt,
    DateTime? updatedAt,
    TodoSyncStatus? syncStatus,
  }) {
    return TodoEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueTime: dueTime ?? this.dueTime,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, isCompleted, dueTime, completedAt, updatedAt, syncStatus];
}

class PendingSyncChange extends Equatable {
  const PendingSyncChange({
    required this.todoId,
    required this.title,
    required this.isCompleted,
    required this.updatedAt,
    required this.actionLabel,
  });

  final String todoId;
  final String title;
  final bool isCompleted;
  final DateTime updatedAt;
  final String actionLabel;

  @override
  List<Object?> get props => [todoId, title, isCompleted, updatedAt, actionLabel];
}
