import 'package:dio/dio.dart';

import '../errors/app_exceptions.dart';
import 'api_models.dart';

class ErrorMapper {
  const ErrorMapper();

  AppException map(Object error) {
    if (error is AppException) return error;
    if (error is! DioException) {
      return ApiException('The request could not be completed.');
    }
    if (error.error is AppException) return error.error! as AppException;
    final response = error.response;
    final body = response?.data;
    final dto = body is Map
        ? ApiErrorDto.fromJson(body.cast<String, Object?>())
        : const ApiErrorDto(
            message: 'The request could not be completed.',
            code: null,
          );
    final backendUnauthenticated =
        dto.code?.toUpperCase() == 'UNAUTHENTICATED' ||
        dto.message.trim().toLowerCase() == 'unauthenticated.';
    if (backendUnauthenticated) {
      return UnauthorizedException('Your session has expired.');
    }
    final validationMessage = dto.fieldErrors.values
        .expand((messages) => messages)
        .firstOrNull;
    final message = response?.statusCode == 422 && validationMessage != null
        ? validationMessage
        : _safeMessage(dto.message, response?.statusCode);
    return switch (response?.statusCode) {
      401 => UnauthorizedException(message),
      403 => ForbiddenException(message),
      404 => NotFoundException(message),
      409 => ConflictException(message, code: dto.code),
      422 => ValidationException(
        message,
        code: dto.code,
        fieldErrors: dto.fieldErrors,
      ),
      int status when status >= 500 => ServerException(message),
      _
          when error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout =>
        NetworkException(),
      _ => ApiException(message, code: dto.code, fieldErrors: dto.fieldErrors),
    };
  }

  String _safeMessage(String message, int? statusCode) {
    final normalized = message.trim();
    final exposesInternals =
        normalized.contains('No query results for model') ||
        normalized.contains('Stack trace:') ||
        normalized.contains(r'App\Models\') ||
        normalized.contains('.php:');
    if (exposesInternals || normalized.isEmpty) {
      return switch (statusCode) {
        401 => 'Your session has expired.',
        403 => 'You do not have permission to perform this action.',
        404 => 'The requested record was not found.',
        int status when status >= 500 =>
          'The server could not complete the request. Please try again.',
        _ => 'The request could not be completed.',
      };
    }
    return normalized;
  }
}
