import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/authentication/domain/entities/user_entity.dart';
import 'package:field_track/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> call({
    required String fullName,
    required String email,
    required String password,
  }) =>
      _repository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
}

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
  }) =>
      _repository.login(email: email, password: password);
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> call() => _repository.getCurrentUser();
}

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.restoreSession();
}

class HasSessionUseCase {
  const HasSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.hasSession();
}
