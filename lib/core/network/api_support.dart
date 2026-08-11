import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../errors/app_exceptions.dart';
import '../storage/secure_token_store.dart';

abstract final class ApiData {
  static Map<String, Object?> snakeCaseMap(Map<String, Object?> source) => {
    for (final entry in source.entries)
      entry.key.replaceAllMapped(
        RegExp('[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      ): _snakeCaseValue(
        entry.value,
      ),
  };

  static Object? _snakeCaseValue(Object? value) {
    if (value is Map<String, Object?>) return snakeCaseMap(value);
    if (value is Map) {
      return snakeCaseMap(value.cast<String, Object?>());
    }
    if (value is List) return value.map(_snakeCaseValue).toList();
    return value;
  }

  static Object? value(Map<String, Object?> json, String key) {
    if (json.containsKey(key)) return json[key];
    final snake = key.replaceAllMapped(
      RegExp('[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
    return json[snake];
  }

  static Map<String, Object?> map(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) return value.cast<String, Object?>();
    throw const ApiException(
      'Expected an object response.',
      code: 'invalid_response',
    );
  }

  static List<Map<String, Object?>> list(Object? value) {
    Object? payload = value;
    for (var depth = 0; depth < 3 && payload is Map; depth++) {
      final nested = payload['data'] ?? payload['items'];
      if (identical(nested, payload) || nested == null) break;
      payload = nested;
    }
    if (payload is! List) {
      throw const ApiException(
        'Expected a list response.',
        code: 'invalid_response',
      );
    }
    return payload.map(map).toList(growable: false);
  }

  static String string(
    Map<String, Object?> json,
    String key, [
    String fallback = '',
  ]) => value(json, key)?.toString() ?? fallback;
  static double number(
    Map<String, Object?> json,
    String key, [
    double fallback = 0,
  ]) {
    final raw = value(json, key);
    if (raw is num) return raw.toDouble();
    return double.tryParse('$raw') ?? fallback;
  }

  static int integer(
    Map<String, Object?> json,
    String key, [
    int fallback = 0,
  ]) {
    final raw = value(json, key);
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw') ?? double.tryParse('$raw')?.toInt() ?? fallback;
  }

  static bool boolean(
    Map<String, Object?> json,
    String key, [
    bool fallback = false,
  ]) {
    final raw = value(json, key);
    if (raw is bool) return raw;
    if (raw == 1 || raw == '1' || raw == 'true') return true;
    if (raw == 0 || raw == '0' || raw == 'false') return false;
    return fallback;
  }

  static DateTime date(
    Map<String, Object?> json,
    String key, [
    DateTime? fallback,
  ]) =>
      DateTime.tryParse('${value(json, key)}')?.toUtc() ??
      fallback ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  static List<String> strings(Map<String, Object?> json, String key) =>
      (value(json, key) as List?)?.map((item) => item.toString()).toList() ??
      const [];
  static List<Object?> listValue(Map<String, Object?> json, String key) =>
      (value(json, key) as List?)?.cast<Object?>() ?? const [];
}

class ApiInterceptor extends QueuedInterceptor {
  ApiInterceptor({required TokenStorage tokenStore}) : _tokenStore = tokenStore;

  final TokenStorage _tokenStore;
  final _uuid = const Uuid();
  Future<void> Function()? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStore.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Client-Platform'] = 'flutter';
    options.headers['X-Request-ID'] ??= _uuid.v4();
    if (kDebugMode) {
      developer.log(
        '${options.method} ${options.uri.path}',
        name: 'FishTrace.API',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        'RESPONSE [${response.statusCode}] ${response.requestOptions.uri.path} => ${response.data}',
        name: 'FishTrace.API',
      );
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      developer.log(
        'ERROR [${err.response?.statusCode}] ${err.requestOptions.uri.path} => ${err.response?.data ?? err.message}',
        name: 'FishTrace.API',
      );
    }
    final error = err;
    if (_isUnauthorized(error)) {
      await _tokenStore.clear();
      await onUnauthorized?.call();
    }
    // Keep the original Laravel response intact so ErrorMapper can preserve
    // nested 422 field errors and map the complete HTTP status taxonomy.
    handler.next(error);
  }

  static bool _isUnauthorized(DioException error) {
    if (error.response?.statusCode == 401) return true;
    final body = error.response?.data;
    if (body is! Map) return false;
    final raw = body['error'];
    final details = raw is Map ? raw : body;
    final code = details['code']?.toString().toUpperCase();
    final message = details['message']?.toString().trim().toLowerCase();
    return code == 'UNAUTHENTICATED' || message == 'unauthenticated.';
  }
}
