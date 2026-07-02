import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/todos/domain/entities/todo_entity.dart';
import 'package:field_track/features/todos/domain/repositories/todo_repository.dart';

class GetTodosUseCase {
  const GetTodosUseCase(this._repository);
  final TodoRepository _repository;
  Future<Result<List<TodoEntity>>> call() => _repository.getTodos();
}

class ToggleTodoUseCase {
  const ToggleTodoUseCase(this._repository);
  final TodoRepository _repository;

  Future<Result<TodoEntity>> call(String todoId, bool isCompleted) =>
      _repository.toggleTodo(todoId, isCompleted);
}

class SyncTodosUseCase {
  const SyncTodosUseCase(this._repository);
  final TodoRepository _repository;

  Future<Result<void>> call({bool force = false}) =>
      _repository.syncPendingChanges(force: force);
}

class GetPendingSyncChangesUseCase {
  const GetPendingSyncChangesUseCase(this._repository);
  final TodoRepository _repository;
  List<PendingSyncChange> call() => _repository.getPendingChanges();
}

class GetPendingSyncCountUseCase {
  const GetPendingSyncCountUseCase(this._repository);
  final TodoRepository _repository;
  int call() => _repository.pendingCount;
}
