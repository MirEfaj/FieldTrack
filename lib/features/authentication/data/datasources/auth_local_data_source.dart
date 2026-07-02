import 'package:field_track/config/env/app_config.dart';
import 'package:field_track/core/storage/hive_service.dart';
import 'package:field_track/core/storage/secure_storage_service.dart';
import 'package:field_track/features/authentication/data/models/user_model.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._secureStorage, this._hiveService);

  final SecureStorageService _secureStorage;
  final HiveService _hiveService;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(AppConfig.accessTokenKey, accessToken),
      _secureStorage.write(AppConfig.refreshTokenKey, refreshToken),
    ]);
  }

  Future<void> clearTokens() => _secureStorage.deleteAll();

  Future<String?> getAccessToken() =>
      _secureStorage.read(AppConfig.accessTokenKey);

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> cacheUser(UserModel user) async {
    await _hiveService.userCache.put('current', user.toJson());
  }

  UserModel? getCachedUser() {
    final data = _hiveService.userCache.get('current');
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> clearUserCache() async {
    await _hiveService.userCache.delete('current');
  }
}
