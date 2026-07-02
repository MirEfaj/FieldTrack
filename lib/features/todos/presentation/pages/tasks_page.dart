import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:field_track/core/theme/app_colors.dart';
import 'package:field_track/core/theme/app_spacing.dart';
import 'package:field_track/core/theme/app_theme_extension.dart';
import 'package:field_track/core/theme/app_typography.dart';
import 'package:field_track/features/todos/domain/entities/todo_entity.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_list_bloc.dart';
import 'package:field_track/shared/widgets/app_widgets.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  void initState() {
    super.initState();
    context.read<TodoListBloc>().add(const TodosLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TodoListBloc, TodoListState>(
          builder: (context, state) {
            if (state.status == TodoListStatus.loading && state.todos.isEmpty) {
              return const AppLoading();
            }
            if (state.status == TodoListStatus.failure && state.todos.isEmpty) {
              return AppErrorView(
                message: state.errorMessage ?? 'Failed to load tasks',
                onRetry: () =>
                    context.read<TodoListBloc>().add(const TodosLoadRequested()),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TodoListBloc>().add(const TodosLoadRequested());
              },
              child: ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  Text(
                    'My tasks',
                    style: AppTypography.displayLarge(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    state.dateLabel,
                    style: AppTypography.bodyMedium(context.appTheme.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  AppProgressCard(
                    title: "Today's progress",
                    progressText: state.progressLabel,
                    progress: state.progress,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _FilterChips(
                    selected: state.filter,
                    onChanged: (filter) => context
                        .read<TodoListBloc>()
                        .add(TodoFilterChanged(filter)),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  if (state.filteredTodos.isEmpty)
                    const AppEmptyView(message: 'No tasks found')
                  else
                    ...state.filteredTodos.map(
                      (todo) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: _TaskCard(todo: todo),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final TodoFilter selected;
  final ValueChanged<TodoFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TodoFilter.values.map((filter) {
        final isSelected = filter == selected;
        return Padding(
          padding: EdgeInsets.only(right: AppSpacing.sm),
          child: FilterChip(
            label: Text(_label(filter)),
            selected: isSelected,
            onSelected: (_) => onChanged(filter),
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            labelStyle: AppTypography.bodyMedium(
              isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(TodoFilter filter) => switch (filter) {
        TodoFilter.all => 'All',
        TodoFilter.pending => 'Pending',
        TodoFilter.completed => 'Completed',
      };
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.todo});

  final TodoEntity todo;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.read<TodoListBloc>().add(
                  TodoToggleRequested(
                    todoId: todo.id,
                    isCompleted: !todo.isCompleted,
                  ),
                ),
            child: Icon(
              todo.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: todo.isCompleted ? AppColors.success : theme.textSecondary,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: AppTypography.titleMedium(onSurface).copyWith(
                    decoration:
                        todo.isCompleted ? TextDecoration.lineThrough : null,
                    color: todo.isCompleted ? theme.textSecondary : onSurface,
                  ),
                ),
                if (todo.description != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    todo.description!,
                    style: AppTypography.bodySmall(theme.textSecondary),
                  ),
                ],
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: theme.textSecondary),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      _timeLabel(todo),
                      style: AppTypography.bodySmall(theme.textSecondary),
                    ),
                    const Spacer(),
                    AppBadge(
                      label: todo.isCompleted ? 'Completed' : 'Pending',
                      backgroundColor: todo.isCompleted
                          ? theme.badgeCompletedBg
                          : theme.badgePendingBg,
                      textColor: todo.isCompleted
                          ? theme.badgeCompletedText
                          : theme.badgePendingText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(TodoEntity todo) {
    if (todo.isCompleted && todo.completedAt != null) {
      return 'Done ${DateFormat.jm().format(todo.completedAt!.toLocal())}';
    }
    if (todo.dueTime != null) {
      return 'Due ${DateFormat.jm().format(todo.dueTime!.toLocal())}';
    }
    return 'No due time';
  }
}
