import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:field_track/features/authentication/presentation/bloc/auth_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._loginUseCase,
    required this._registerUseCase,
    required this._logoutUseCase,
    required this._restoreSessionUseCase,
    required this._hasSessionUseCase,
    required this._getCurrentUserUseCase,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;
  final HasSessionUseCase _hasSessionUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    if (!await _hasSessionUseCase()) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      ));
      return;
    }

    final restoreResult = await _restoreSessionUseCase();
    switch (restoreResult) {
      case Success<void>():
        final userResult = await _getCurrentUserUseCase();
        switch (userResult) {
          case Success(:final data):
            emit(state.copyWith(
              status: AuthStatus.authenticated,
              user: data,
              clearError: true,
            ));
          case Error(:final failure):
            emit(state.copyWith(
              status: AuthStatus.unauthenticated,
              errorMessage: failure.message,
              clearUser: true,
            ));
        }
      case Error(:final failure):
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
          clearUser: true,
        ));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: data,
          clearError: true,
        ));
      case Error(:final failure):
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _registerUseCase(
      fullName: event.fullName,
      email: event.email,
      password: event.password,
    );
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: data,
          clearError: true,
        ));
      case Error(:final failure):
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await _logoutUseCase();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      clearError: true,
    ));
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      errorMessage: 'Session expired. Please sign in again.',
    ));
  }
}
