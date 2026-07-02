import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/todos/domain/entities/todo_entity.dart';

abstract class TodoRepository {
  Future<Result<List<TodoEntity>>> getTodos();

  Future<Result<TodoEntity>> toggleTodo(String todoId, bool isCompleted);

  Future<Result<void>> syncPendingChanges({bool force = false});

  bool get isSyncInProgress;

  List<PendingSyncChange> getPendingChanges();

  int get pendingCount;

  DateTime? get lastSyncedAt;
}
