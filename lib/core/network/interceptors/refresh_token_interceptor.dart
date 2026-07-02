import 'dart:async';

import 'package:dio/dio.dart';
import 'package:field_track/config/env/app_config.dart';
import 'package:field_track/core/storage/secure_storage_service.dart';

class RefreshTokenInterceptor extends QueuedInterceptor {
  RefreshTokenInterceptor({
    required Dio dio,
    required SecureStorageService secureStorage,
    required void Function() onSessionExpired,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final SecureStorageService _secureStorage;
  final void Function() _onSessionExpired;

  bool _isRefreshing = false;
  final List<Completer<void>> _refreshQueue = [];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        _shouldSkipRefresh(err.requestOptions)) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshQueue.add(completer);
      await completer.future;
      try {
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;
    try {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        _onSessionExpired();
        handler.next(err);
        return;
      }

      for (final completer in _refreshQueue) {
        completer.complete();
      }
      _refreshQueue.clear();

      final response = await _retry(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      for (final completer in _refreshQueue) {
        completer.completeError(e);
      }
      _refreshQueue.clear();
      _onSessionExpired();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  bool _shouldSkipRefresh(RequestOptions options) {
    return options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh');
  }

  Future<bool> _refreshToken() async {
    final refreshToken =
        await _secureStorage.read(AppConfig.refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(extra: {'skipAuth': true}),
    );

    final data = response.data;
    if (data == null) return false;

    final accessToken = data['access_token'] as String?;
    final newRefresh = data['refresh_token'] as String?;

    if (accessToken == null) return false;

    await _secureStorage.write(AppConfig.accessTokenKey, accessToken);
    if (newRefresh != null) {
      await _secureStorage.write(AppConfig.refreshTokenKey, newRefresh);
    }
    return true;
  }

  Future<Response<dynamic>> _retry(RequestOptions options) {
    final headers = Map<String, dynamic>.from(options.headers);
    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: headers,
        extra: options.extra,
        responseType: options.responseType,
        contentType: options.contentType,
      ),
    );
  }
}
