import 'package:dio/dio.dart';

class UploadedFile {
  const UploadedFile({
    required this.id,
    required this.category,
    required this.entityType,
    required this.entityId,
    required this.originalName,
    required this.downloadUrl,
    required this.mimeType,
    required this.extension,
    required this.sizeBytes,
    required this.sha256,
    required this.createdAt,
  });
  final String id;
  final String category;
  final String entityType;
  final String entityId;
  final String originalName;
  final String downloadUrl;
  final String mimeType;
  final String extension;
  final int sizeBytes;
  final String sha256;
  final DateTime createdAt;
}

abstract interface class FileRepository {
  Future<UploadedFile> upload(
    String path, {
    required String category,
    required String entityType,
    required String entityId,
    required CancelToken cancelToken,
    required void Function(int sent, int total) onProgress,
  });
}
