import 'package:flutter/foundation.dart';

@immutable
sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() {
    return 'AppException(message: $message, code: $code)';
  }
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

final class ApiException extends AppException {
  const ApiException(super.message, {super.code});
}

final class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

final class UnknownException extends AppException {
  const UnknownException(super.message, {super.code});
}
