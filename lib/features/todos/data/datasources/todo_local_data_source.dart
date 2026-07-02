import 'package:field_track/core/storage/hive_service.dart';
import 'package:field_track/features/todos/data/models/todo_model.dart';
import 'package:field_track/features/todos/domain/entities/todo_entity.dart';

class TodoLocalDataSource {
  TodoLocalDataSource(this._hiveService);

  final HiveService _hiveService;
  static const String lastSyncedKey = '__meta_last_synced__';

  Future<void> cacheTodos(List<TodoModel> todos) async {
    final box = _hiveService.todos;
    await box.clear();
    for (final todo in todos) {
      await box.put(todo.id, {
        ...todo.toJson(),
        'sync_status': TodoSyncStatus.synced.name,
      });
    }
  }

  List<TodoModel> getCachedTodos() {
    return _hiveService.todos.values.map((raw) {
      final map = Map<String, dynamic>.from(raw);
      map.remove('sync_status');
      return TodoModel.fromJson(map);
    }).toList();
  }

  Map<String, dynamic>? getTodoRaw(String id) {
    final data = _hiveService.todos.get(id);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  TodoSyncStatus getSyncStatus(String id) {
    final raw = getTodoRaw(id);
    final status = raw?['sync_status'] as String?;
    return TodoSyncStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => TodoSyncStatus.synced,
    );
  }

  Future<void> updateTodoLocally(
    TodoModel todo, {
    required TodoSyncStatus syncStatus,
  }) async {
    await _hiveService.todos.put(todo.id, {
      ...todo.toJson(),
      'sync_status': syncStatus.name,
    });
  }

  Future<void> enqueueSync({
    required String todoId,
    required String title,
    required bool isCompleted,
    required DateTime updatedAt,
  }) async {
    await _hiveService.syncQueue.put(todoId, {
      'todo_id': todoId,
      'title': title,
      'is_completed': isCompleted,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    });
  }

  List<Map<String, dynamic>> getPendingSyncItems() {
    return _hiveService.syncQueue.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  int get pendingCount => _hiveService.syncQueue.keys
      .where((key) => key != lastSyncedKey)
      .length;

  Future<void> clearSyncItem(String todoId) async {
    await _hiveService.syncQueue.delete(todoId);
  }

  Future<void> clearAllSyncItems() async {
    await _hiveService.syncQueue.clear();
  }

  Future<void> setLastSyncedAt(DateTime time) async {
    await _hiveService.syncQueue.put(
      lastSyncedKey,
      {'value': time.toUtc().toIso8601String()},
    );
  }

  DateTime? getLastSyncedAt() {
    final data = _hiveService.syncQueue.get(lastSyncedKey);
    if (data == null) return null;
    final value = data['value'] as String?;
    if (value == null) return null;
    return DateTime.tryParse(value);
  }
}
