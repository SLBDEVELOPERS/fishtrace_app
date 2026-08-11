import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../dtos/file_asset_dto.dart';
import '../../domain/repositories/file_repository.dart';

class MockFileRepository implements FileRepository {
  @override
  Future<UploadedFile> upload(
    String path, {
    required String category,
    required String entityType,
    required String entityId,
    required CancelToken cancelToken,
    required void Function(int sent, int total) onProgress,
  }) async {
    final length = await File(path).length();
    for (var sent = 0; sent < length; sent += (length ~/ 4).clamp(1, length)) {
      if (cancelToken.isCancelled) {
        throw const ApiException('Upload cancelled.');
      }
      onProgress(sent, length);
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    onProgress(length, length);
    final name = path.split(RegExp(r'[/\\]')).last;
    final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
    final hashChunk = name.hashCode
        .toUnsigned(32)
        .toRadixString(16)
        .padLeft(8, '0');
    return UploadedFile(
      id: 'mock-$name',
      category: category,
      entityType: entityType,
      entityId: entityId,
      originalName: name,
      downloadUrl: 'mock://uploads/$name',
      mimeType: mimeType,
      extension: name.contains('.') ? name.split('.').last.toLowerCase() : '',
      sizeBytes: length,
      sha256: List<String>.filled(8, hashChunk).join(),
      createdAt: DateTime.now().toUtc(),
    );
  }
}

class ApiFileRepository implements FileRepository {
  const ApiFileRepository(this._api);
  final ApiClient _api;

  @override
  Future<UploadedFile> upload(
    String path, {
    required String category,
    required String entityType,
    required String entityId,
    required CancelToken cancelToken,
    required void Function(int sent, int total) onProgress,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const NotFoundException('The selected file no longer exists.');
    }
    final size = await file.length();
    if (size > 10 * 1024 * 1024) {
      throw const ValidationException('Files must be 10 MB or smaller.');
    }
    final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
    const accepted = {
      'image/jpeg',
      'image/png',
      'image/webp',
      'application/pdf',
    };
    if (!accepted.contains(mimeType)) {
      throw const ValidationException('Use a JPEG, PNG, WebP, or PDF file.');
    }
    final data = FormData.fromMap({
      'category': category,
      'entity_type': entityType,
      'entity_id': entityId,
      'file': await MultipartFile.fromFile(
        path,
        filename: path.split(RegExp(r'[/\\]')).last,
        contentType: DioMediaType.parse(mimeType),
      ),
    });
    final response = ApiData.map(
      await _api.post(
        ApiEndpoints.files,
        data: data,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
        options: Options(contentType: 'multipart/form-data'),
      ),
    );
    final payload = response['data'] is Map
        ? ApiData.map(response['data'])
        : response;
    return FileAssetDto.fromJson(payload).toDomain();
  }
}
