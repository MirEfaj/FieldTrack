import 'package:dio/dio.dart';
import 'package:field_track/config/env/app_config.dart';
import 'package:field_track/core/network/api_exception_handler.dart';
import 'package:field_track/core/network/interceptors/auth_interceptor.dart';
import 'package:field_track/core/network/interceptors/logging_interceptor.dart';
import 'package:field_track/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:field_track/core/storage/secure_storage_service.dart';

class ApiClient {
  ApiClient({
    required SecureStorageService secureStorage,
    required void Function() onSessionExpired,
  }) : _exceptionHandler = ApiExceptionHandler() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(secureStorage),
      RefreshTokenInterceptor(
        dio: _dio,
        secureStorage: secureStorage,
        onSessionExpired: onSessionExpired,
      ),
    ]);
  }

  late final Dio _dio;
  final ApiExceptionHandler _exceptionHandler;

  Dio get dio => _dio;
  ApiExceptionHandler get exceptionHandler => _exceptionHandler;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
  }) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}
