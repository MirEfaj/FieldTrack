import 'package:dio/dio.dart';
import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/error/result.dart';

class ApiExceptionHandler {
  Failure mapException(Object error) {
    if (error is DioException) {
      return _mapDioException(error);
    }
    if (error is FormatException) {
      return ValidationFailure(error.message);
    }
    return UnknownFailure(error.toString());
  }

  Failure _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response);
      case DioExceptionType.cancel:
        return const UnknownFailure('Request cancelled');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownFailure(error.message ?? 'Unknown network error');
    }
  }

  Failure _mapStatusCode(Response<dynamic>? response) {
    final statusCode = response?.statusCode ?? 0;
    final message = _extractMessage(response?.data);

    return switch (statusCode) {
      400 || 422 => ValidationFailure(message),
      401 => UnauthorizedFailure(message),
      409 => ValidationFailure(
          message == 'Request failed'
              ? 'An account with this email already exists'
              : message,
        ),
      >= 500 => ServerFailure(message),
      _ => ServerFailure(message),
    };
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'] ?? data['error'];
      if (message is String) return message;
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
    }
    return 'Request failed';
  }

  Future<Result<T>> guard<T>(Future<T> Function() call) async {
    try {
      final data = await call();
      return Success(data);
    } catch (e) {
      return Error(mapException(e));
    }
  }
}
