import 'package:field_track/core/network/api_client.dart';
import 'package:field_track/features/todos/data/models/todo_model.dart';

class TodoRemoteDataSource {
  const TodoRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<TodoModel>> getTodos() async {
    final response = await _apiClient.get<dynamic>('/api/v1/todos');
    final data = response.data;
    final list = data is List ? data : (data as Map)['data'] as List? ?? [];
    return list
        .map((e) => TodoModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<TodoModel> patchTodo(
    String todoId, {
    required bool isCompleted,
    required DateTime updatedAt,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/api/v1/todos/$todoId',
      data: {
        'is_completed': isCompleted,
        'updated_at': updatedAt.toUtc().toIso8601String(),
      },
    );
    final data = response.data!;
    if (data.containsKey('id')) return TodoModel.fromJson(data);
    return TodoModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> syncTodos(List<Map<String, dynamic>> changes) async {
    await _apiClient.post<void>(
      '/api/v1/todos/sync',
      data: {'changes': changes},
    );
  }
}
