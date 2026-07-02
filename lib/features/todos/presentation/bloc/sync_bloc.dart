import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_track/core/connectivity/connectivity_service.dart';
import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/todos/domain/entities/todo_entity.dart';
import 'package:field_track/features/todos/domain/repositories/todo_repository.dart';
import 'package:field_track/features/todos/domain/usecases/todo_usecases.dart';
import 'package:field_track/features/todos/presentation/utils/sync_formatters.dart';

enum SyncStatus {
  initial,
  loading,
  syncing,
  success,
  synced,
  failure,
  offline,
  empty,
  pending,
}

class SyncState extends Equatable {
  const SyncState({
    this.status = SyncStatus.initial,
    this.isOnline = true,
    this.pendingChanges = const [],
    this.pendingCount = 0,
    this.lastSyncedLabel = 'Not synced yet',
    this.errorMessage,
  });

  final SyncStatus status;
  final bool isOnline;
  final List<PendingSyncChange> pendingChanges;
  final int pendingCount;
  final String lastSyncedLabel;
  final String? errorMessage;

  bool get canSync => isOnline && pendingCount > 0 && !isSyncing;

  bool get isSyncing =>
      status == SyncStatus.loading || status == SyncStatus.syncing;

  SyncState copyWith({
    SyncStatus? status,
    bool? isOnline,
    List<PendingSyncChange>? pendingChanges,
    int? pendingCount,
    String? lastSyncedLabel,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncedLabel: lastSyncedLabel ?? this.lastSyncedLabel,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isOnline,
        pendingChanges,
        pendingCount,
        lastSyncedLabel,
        errorMessage,
      ];
}

sealed class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object?> get props => [];
}

final class SyncLoadRequested extends SyncEvent {
  const SyncLoadRequested();
}

final class SyncNowRequested extends SyncEvent {
  const SyncNowRequested({this.force = false});

  final bool force;

  @override
  List<Object?> get props => [force];
}

final class SyncConnectivityChanged extends SyncEvent {
  const SyncConnectivityChanged(this.isOnline);
  final bool isOnline;
  @override
  List<Object?> get props => [isOnline];
}

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required this._syncTodosUseCase,
    required this._getPendingChangesUseCase,
    required this._getPendingCountUseCase,
    required this._todoRepository,
    required this._connectivityService,
  }) : super(const SyncState()) {
    on<SyncLoadRequested>(_onLoad);
    on<SyncNowRequested>(_onSyncNow);
    on<SyncConnectivityChanged>(_onConnectivityChanged);

    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isOnline) {
      _connectivityDebounce?.cancel();
      _connectivityDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          add(SyncConnectivityChanged(isOnline));
        }
      });
    });

    Future.microtask(() {
      if (!isClosed) add(const SyncLoadRequested());
    });
  }

  final SyncTodosUseCase _syncTodosUseCase;
  final GetPendingSyncChangesUseCase _getPendingChangesUseCase;
  final GetPendingSyncCountUseCase _getPendingCountUseCase;
  final TodoRepository _todoRepository;
  final ConnectivityService _connectivityService;
  late final StreamSubscription<bool> _connectivitySubscription;
  Timer? _connectivityDebounce;

  Future<void> _onLoad(
    SyncLoadRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(state.copyWith(status: SyncStatus.loading));
    final isOnline = await _connectivityService.isConnected;
    emit(_buildState(isOnline: isOnline));

    if (isOnline && _getPendingCountUseCase() > 0) {
      add(const SyncNowRequested());
    }
  }

  Future<void> _onSyncNow(
    SyncNowRequested event,
    Emitter<SyncState> emit,
  ) async {
    if (_todoRepository.isSyncInProgress) return;

    final isOnline = await _connectivityService.isConnected;
    if (!isOnline) {
      emit(_buildState(isOnline: false, status: SyncStatus.offline));
      return;
    }

    if (_getPendingCountUseCase() == 0) {
      emit(_buildState(isOnline: true, status: SyncStatus.empty));
      return;
    }

    emit(state.copyWith(status: SyncStatus.syncing, clearError: true));
    final result = await _syncTodosUseCase(force: event.force);
    switch (result) {
      case Success<void>():
        emit(
          _buildState(
            isOnline: true,
            status: _getPendingCountUseCase() == 0
                ? SyncStatus.synced
                : SyncStatus.pending,
          ),
        );
      case Error(:final failure):
        emit(
          _buildState(isOnline: true, status: SyncStatus.failure).copyWith(
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onConnectivityChanged(
    SyncConnectivityChanged event,
    Emitter<SyncState> emit,
  ) async {
    emit(_buildState(
      isOnline: event.isOnline,
      status: event.isOnline ? SyncStatus.pending : SyncStatus.offline,
    ));

    if (event.isOnline && _getPendingCountUseCase() > 0) {
      add(const SyncNowRequested());
    }
  }

  SyncState _buildState({
    required bool isOnline,
    SyncStatus status = SyncStatus.initial,
  }) {
    final pendingChanges = _getPendingChangesUseCase();
    final pendingCount = _getPendingCountUseCase();
    final lastSyncedLabel =
        formatLastSyncedLabel(_todoRepository.lastSyncedAt);

    final resolvedStatus = switch (status) {
      SyncStatus.initial when !isOnline => SyncStatus.offline,
      SyncStatus.initial when pendingCount == 0 => SyncStatus.empty,
      SyncStatus.initial when pendingCount > 0 => SyncStatus.pending,
      SyncStatus.pending when pendingCount == 0 => SyncStatus.empty,
      SyncStatus.synced when pendingCount == 0 => SyncStatus.synced,
      SyncStatus.success when pendingCount == 0 => SyncStatus.synced,
      _ => status,
    };

    return SyncState(
      status: isOnline ? resolvedStatus : SyncStatus.offline,
      isOnline: isOnline,
      pendingChanges: pendingChanges,
      pendingCount: pendingCount,
      lastSyncedLabel: lastSyncedLabel,
    );
  }

  @override
  Future<void> close() {
    _connectivityDebounce?.cancel();
    _connectivitySubscription.cancel();
    return super.close();
  }
}
