import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/error/result.dart';
import 'package:field_track/core/network/api_exception_handler.dart';
import 'package:field_track/core/storage/session_storage_service.dart';
import 'package:field_track/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:field_track/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:field_track/features/authentication/data/models/user_model.dart';
import 'package:field_track/features/authentication/domain/entities/user_entity.dart';
import 'package:field_track/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required SessionStorageService sessionStorageService,
    required ApiExceptionHandler exceptionHandler,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _sessionStorage = sessionStorageService,
        _handler = exceptionHandler;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final SessionStorageService _sessionStorage;
  final ApiExceptionHandler _handler;

  @override
  Future<Result<UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return _handler.guard(() async {
      final data = await _remote.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      await _saveAuthResponse(data);
      return _parseUser(data);
    });
  }

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    return _handler.guard(() async {
      final data = await _remote.login(email: email, password: password);
      await _saveAuthResponse(data);
      return _parseUser(data);
    });
  }

  @override
  Future<Result<void>> logout() async {
    return _handler.guard(() async {
      try {
        await _remote.logout();
      } catch (_) {
        // Clear local session even if remote logout fails.
      }
      await _local.clearTokens();
      await _local.clearUserCache();
      await _sessionStorage.clearUserSessionData();
    });
  }

  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    return _handler.guard(() async {
      try {
        final user = await _remote.getCurrentUser();
        await _local.cacheUser(user);
        return user.toEntity();
      } catch (e) {
        final cached = _local.getCachedUser();
        if (cached != null) return cached.toEntity();
        rethrow;
      }
    });
  }

  @override
  Future<bool> hasSession() => _local.hasTokens();

  @override
  Future<Result<void>> restoreSession() async {
    if (!await hasSession()) {
      return const Error(UnauthorizedFailure());
    }
    final result = await getCurrentUser();
    return switch (result) {
      Success<UserEntity>() => const Success(null),
      Error<UserEntity>(:final failure) => Error(failure),
    };
  }

  Future<void> _saveAuthResponse(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    if (accessToken == null || refreshToken == null) {
      throw const FormatException('Invalid auth response');
    }
    await _local.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson != null) {
      await _local.cacheUser(UserModel.fromJson(userJson));
    }
  }

  UserEntity _parseUser(Map<String, dynamic> data) {
    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson != null) {
      return UserModel.fromJson(userJson).toEntity();
    }
    final cached = _local.getCachedUser();
    if (cached != null) return cached.toEntity();
    throw const FormatException('User data missing from auth response');
  }
}
