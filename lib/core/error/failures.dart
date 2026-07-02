import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired. Please sign in again']);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
