import 'package:field_track/core/error/result.dart';
import 'package:field_track/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> logout();

  Future<Result<UserEntity>> getCurrentUser();

  Future<bool> hasSession();

  Future<Result<void>> restoreSession();
}
