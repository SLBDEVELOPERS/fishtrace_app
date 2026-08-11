import 'package:dio/dio.dart';

import 'error_mapper.dart';

class ApiClient {
  const ApiClient(this._dio, this._errors);
  final Dio _dio;
  final ErrorMapper _errors;

  Future<Object?> get(
    String path, {
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.get<Object?>(
      path,
      queryParameters: query,
      cancelToken: cancelToken,
    ),
  );

  Future<Object?> post(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) => _request(
    () => _dio.post<Object?>(
      path,
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    ),
  );

  Future<Object?> put(String path, {Object? data, CancelToken? cancelToken}) =>
      _request(
        () => _dio.put<Object?>(path, data: data, cancelToken: cancelToken),
      );

  Future<Object?> delete(
    String path, {
    Object? data,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.delete<Object?>(path, data: data, cancelToken: cancelToken),
  );

  Future<Object?> _request(Future<Response<Object?>> Function() request) async {
    try {
      return (await request()).data;
    } catch (error) {
      throw _errors.map(error);
    }
  }

  Never mapAndThrow(Object error) => throw _errors.map(error);
}
