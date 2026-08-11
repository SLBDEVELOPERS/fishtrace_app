import '../../../../core/network/api_support.dart';
import '../../domain/repositories/file_repository.dart';

class FileAssetDto {
  const FileAssetDto(this.json);

  final Map<String, Object?> json;

  factory FileAssetDto.fromJson(Map<String, Object?> json) =>
      FileAssetDto(json);

  UploadedFile toDomain() => UploadedFile(
    id: ApiData.string(json, 'id'),
    category: ApiData.string(json, 'category'),
    entityType: ApiData.string(json, 'entity_type'),
    entityId: ApiData.string(json, 'entity_id'),
    originalName: ApiData.string(json, 'original_name'),
    downloadUrl: ApiData.string(json, 'download_url'),
    mimeType: ApiData.string(json, 'mime_type'),
    extension: ApiData.string(json, 'extension'),
    sizeBytes: ApiData.integer(json, 'size_bytes'),
    sha256: ApiData.string(json, 'sha256'),
    createdAt: ApiData.date(json, 'created_at'),
  );
}
