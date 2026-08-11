sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.fieldErrors = const {}});

  final String message;
  final String? code;
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() => message;
}

class ApiException extends AppException {
  const ApiException(super.message, {super.code, super.fieldErrors});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Check your connection and retry.']);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.fieldErrors});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Your session has expired.']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'You do not have permission.']);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested record was not found.',
  ]);
}

class ConflictException extends AppException {
  const ConflictException(super.message, {super.code});
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'The server could not complete the request.',
  ]);
}
