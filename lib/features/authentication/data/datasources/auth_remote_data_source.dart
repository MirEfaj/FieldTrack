import 'package:field_track/core/network/api_client.dart';
import 'package:field_track/features/authentication/data/models/user_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/v1/auth/register',
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data!;
  }

  Future<void> logout() async {
    await _apiClient.post<void>('/api/v1/auth/logout');
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/api/v1/me');
    return UserModel.fromJson(response.data!);
  }
}
