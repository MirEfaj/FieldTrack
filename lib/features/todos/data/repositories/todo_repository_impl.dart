import 'dart:math';

import 'package:field_track/core/connectivity/connectivity_service.dart';
import 'package:field_track/core/error/result.dart';
import 'package:field_track/core/network/api_exception_handler.dart';
import 'package:field_track/features/todos/data/datasources/todo_local_data_source.dart';
import 'package:field_track/features/todos/data/datasources/todo_remote_data_source.dart';
import 'package:field_track/features/todos/data/models/todo_model.dart';
import 'package:field_track/features/todos/domain/entities/todo_entity.dart';
import 'package:field_track/features/todos/domain/repositories/todo_repository.dart';
import 'package:intl/intl.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl({
    required TodoRemoteDataSource remoteDataSource,
    required TodoLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
    required ApiExceptionHandler exceptionHandler,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _connectivity = connectivityService,
        _handler = exceptionHandler;

  final TodoRemoteDataSource _remote;
  final TodoLocalDataSource _local;
  final ConnectivityService _connectivity;
  final ApiExceptionHandler _handler;

  bool _isSyncing = false;
  int _consecutiveFailures = 0;
  DateTime? _nextRetryAfter;

  @override
  bool get isSyncInProgress => _isSyncing;

  @override
  Future<Result<List<TodoEntity>>> getTodos() async {
    return _handler.guard(() async {
      final isOnline = await _connectivity.isConnected;
      if (isOnline) {
        try {
          final todos = await _remote.getTodos();
          await _local.cacheTodos(todos);
          return _mapLocalTodos();
        } catch (_) {
          return _mapLocalTodos();
        }
      }
      return _mapLocalTodos();
    });
  }

  @override
  Future<Result<TodoEntity>> toggleTodo(String todoId, bool isCompleted) async {
    return _handler.guard(() async {
      final now = DateTime.now().toUtc();
      final raw = _local.getTodoRaw(todoId);
      if (raw == null) throw const FormatException('Todo not found locally');

      raw.remove('sync_status');
      final current = TodoModel.fromJson(raw);
      final updated = current.copyWith(
        isCompleted: isCompleted,
        completedAt: isCompleted ? now : null,
        updatedAt: now,
      );

      final isOnline = await _connectivity.isConnected;
      if (isOnline) {
        try {
          final remote = await _remote.patchTodo(
            todoId,
            isCompleted: isCompleted,
            updatedAt: now,
          );
          await _local.updateTodoLocally(remote, syncStatus: TodoSyncStatus.synced);
          await _local.clearSyncItem(todoId);
          return remote.toEntity(syncStatus: TodoSyncStatus.synced);
        } catch (_) {
          await _queueChange(updated, now);
          return updated.toEntity(syncStatus: TodoSyncStatus.pending);
        }
      }

      await _queueChange(updated, now);
      return updated.toEntity(syncStatus: TodoSyncStatus.pending);
    });
  }

  @override
  Future<Result<void>> syncPendingChanges({bool force = false}) async {
    if (_isSyncing) {
      return const Success(null);
    }

    if (!force && _nextRetryAfter != null) {
      if (DateTime.now().isBefore(_nextRetryAfter!)) {
        return const Success(null);
      }
    }

    return _handler.guard(() async {
      _isSyncing = true;
      try {
        final isOnline = await _connectivity.isConnected;
        if (!isOnline) return;

        final pending = _local.getPendingSyncItems()
            .where((e) => e.containsKey('todo_id'))
            .toList();
        if (pending.isEmpty) return;

        final changes = pending
            .map(
              (e) => {
                'todo_id': e['todo_id'],
                'is_completed': e['is_completed'],
                'updated_at': e['updated_at'],
              },
            )
            .toList();

        await _remote.syncTodos(changes);

        for (final item in pending) {
          final todoId = item['todo_id'] as String;
          final raw = _local.getTodoRaw(todoId);
          if (raw != null) {
            raw.remove('sync_status');
            final model = TodoModel.fromJson(raw);
            await _local.updateTodoLocally(
              model,
              syncStatus: TodoSyncStatus.synced,
            );
          }
          await _local.clearSyncItem(todoId);
        }

        await _local.setLastSyncedAt(DateTime.now());
        _consecutiveFailures = 0;
        _nextRetryAfter = null;
      } catch (_) {
        _consecutiveFailures++;
        final backoffSeconds = min(
          30 * pow(2, _consecutiveFailures - 1).toInt(),
          300,
        );
        _nextRetryAfter = DateTime.now().add(Duration(seconds: backoffSeconds));
        rethrow;
      } finally {
        _isSyncing = false;
      }
    });
  }

  @override
  List<PendingSyncChange> getPendingChanges() {
    return _local
        .getPendingSyncItems()
        .where((e) => e.containsKey('todo_id'))
        .map((e) {
      final updatedAt = DateTime.parse(e['updated_at'] as String).toLocal();
      final isCompleted = e['is_completed'] as bool;
      return PendingSyncChange(
        todoId: e['todo_id'] as String,
        title: e['title'] as String? ?? 'Task',
        isCompleted: isCompleted,
        updatedAt: updatedAt,
        actionLabel:
            '${isCompleted ? 'Marked done' : 'Marked pending'} - ${DateFormat.jm().format(updatedAt)}',
      );
    }).toList();
  }

  @override
  int get pendingCount => _local.pendingCount;

  @override
  DateTime? get lastSyncedAt => _local.getLastSyncedAt();

  Future<void> _queueChange(TodoModel updated, DateTime now) async {
    await _local.updateTodoLocally(updated, syncStatus: TodoSyncStatus.pending);
    await _local.enqueueSync(
      todoId: updated.id,
      title: updated.title,
      isCompleted: updated.isCompleted,
      updatedAt: now,
    );
  }

  List<TodoEntity> _mapLocalTodos() {
    return _local.getCachedTodos().map((todo) {
      final status = _local.getSyncStatus(todo.id);
      return todo.toEntity(syncStatus: status);
    }).toList();
  }
}
