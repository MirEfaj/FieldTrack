import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/todos/domain/entities/todo_entity.dart';
import 'package:field_track/features/todos/domain/usecases/todo_usecases.dart';
import 'package:intl/intl.dart';

enum TodoListStatus { initial, loading, success, failure, updating }

class TodoListState extends Equatable {
  const TodoListState({
    this.status = TodoListStatus.initial,
    this.todos = const [],
    this.filter = TodoFilter.all,
    this.errorMessage,
  });

  final TodoListStatus status;
  final List<TodoEntity> todos;
  final TodoFilter filter;
  final String? errorMessage;

  List<TodoEntity> get filteredTodos {
    return switch (filter) {
      TodoFilter.all => todos,
      TodoFilter.pending => todos.where((t) => !t.isCompleted).toList(),
      TodoFilter.completed => todos.where((t) => t.isCompleted).toList(),
    };
  }

  int get completedCount => todos.where((t) => t.isCompleted).length;
  int get totalCount => todos.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  String get progressLabel => '$completedCount of $totalCount done';

  String get dateLabel {
    final now = DateTime.now();
    return DateFormat('EEEE, MMM d').format(now);
  }

  TodoListState copyWith({
    TodoListStatus? status,
    List<TodoEntity>? todos,
    TodoFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodoListState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, todos, filter, errorMessage];
}

sealed class TodoListEvent extends Equatable {
  const TodoListEvent();
  @override
  List<Object?> get props => [];
}

final class TodosLoadRequested extends TodoListEvent {
  const TodosLoadRequested();
}

final class TodoFilterChanged extends TodoListEvent {
  const TodoFilterChanged(this.filter);
  final TodoFilter filter;
  @override
  List<Object?> get props => [filter];
}

final class TodoToggleRequested extends TodoListEvent {
  const TodoToggleRequested({required this.todoId, required this.isCompleted});
  final String todoId;
  final bool isCompleted;
  @override
  List<Object?> get props => [todoId, isCompleted];
}

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  TodoListBloc({
    required this._getTodosUseCase,
    required this._toggleTodoUseCase,
  }) : super(const TodoListState()) {
    on<TodosLoadRequested>(_onLoad);
    on<TodoFilterChanged>(_onFilterChanged);
    on<TodoToggleRequested>(_onToggle);
  }

  final GetTodosUseCase _getTodosUseCase;
  final ToggleTodoUseCase _toggleTodoUseCase;

  Future<void> _onLoad(TodosLoadRequested event, Emitter<TodoListState> emit) async {
    emit(state.copyWith(status: TodoListStatus.loading, clearError: true));
    final result = await _getTodosUseCase();
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(status: TodoListStatus.success, todos: data));
      case Error(:final failure):
        emit(state.copyWith(
          status: TodoListStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  void _onFilterChanged(TodoFilterChanged event, Emitter<TodoListState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onToggle(
    TodoToggleRequested event,
    Emitter<TodoListState> emit,
  ) async {
    final optimistic = state.todos.map((todo) {
      if (todo.id != event.todoId) return todo;
      return todo.copyWith(
        isCompleted: event.isCompleted,
        syncStatus: TodoSyncStatus.pending,
        updatedAt: DateTime.now(),
        completedAt: event.isCompleted ? DateTime.now() : null,
      );
    }).toList();

    emit(state.copyWith(todos: optimistic, status: TodoListStatus.updating));

    final result = await _toggleTodoUseCase(event.todoId, event.isCompleted);
    switch (result) {
      case Success(:final data):
        final updated = state.todos.map((todo) {
          return todo.id == data.id ? data : todo;
        }).toList();
        emit(state.copyWith(todos: updated, status: TodoListStatus.success));
      case Error(:final failure):
        emit(state.copyWith(
          status: TodoListStatus.failure,
          errorMessage: failure.message,
        ));
        add(const TodosLoadRequested());
    }
  }
}
