import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../../../../core/network/offline_api_cache.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/processor_entities.dart';
import '../../domain/repositories/processor_repository.dart';
import '../dtos/processor_dtos.dart';

class DioProcessorRepository implements ProcessorRepository {
  DioProcessorRepository(this._api, {OfflineApiCache? cache}) : _cache = cache;
  final ApiClient _api;
  final OfflineApiCache? _cache;

  Future<Object?> _get(
    String path, {
    Map<String, Object?>? query,
    String? cacheKey,
  }) {
    Future<Object?> remote() => _api.get(path, query: query);
    final cache = _cache;
    return cache == null
        ? remote()
        : cache.readThrough(cacheKey ?? path, remote);
  }

  @override
  Future<IncomingBatch?> findIncomingBatch(String scannedValue) async {
    try {
      final response = await _get(
        ApiEndpoints.processorResolveBatch,
        query: {'code': scannedValue},
        cacheKey: 'processor:resolve:$scannedValue',
      );
      final envelope = ApiData.map(response);
      return IncomingBatchDto.fromJson(
        ApiData.map(envelope['data'] ?? envelope),
      ).toDomain();
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<ProcessorReferenceData> getReferenceData() async {
    final response = await _get(
      ApiEndpoints.processorReferenceData,
      cacheKey: 'processor:reference-data',
    );
    final envelope = ApiData.map(response);
    final data = envelope['data'] is Map
        ? ApiData.map(envelope['data'])
        : envelope;
    return ProcessorReferenceData(
      qualityGrades: ApiData.listValue(data, 'qualityGrades')
          .map(ApiData.map)
          .map(
            (item) => ProcessorQualityGrade(
              id: ApiData.string(item, 'id'),
              code: ApiData.string(item, 'code'),
              name: ApiData.string(item, 'name'),
            ),
          )
          .where((item) => item.id.isNotEmpty && item.code.isNotEmpty)
          .toList(growable: false),
      processingTypes: ApiData.listValue(data, 'processingTypes')
          .map(ApiData.map)
          .map((item) => ApiData.string(item, 'name'))
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    );
  }

  @override
  Future<List<IncomingBatch>> getIncomingBatches() async {
    final response = await _get(
      ApiEndpoints.processorIncomingBatches,
      cacheKey: 'processor:incoming',
    );
    return ApiData.list(
      response,
    ).map((json) => IncomingBatchDto.fromJson(json).toDomain()).toList();
  }

  @override
  Future<List<ProcessingJob>> getProcessingHistory() async {
    final response = await _get(
      ApiEndpoints.processorHistory,
      cacheKey: 'processor:history',
    );
    return ApiData.list(
      response,
    ).map((json) => ProcessingJobDto.fromJson(json).toDomain()).toList();
  }

  @override
  Future<List<GeneratedChildBatch>> getChildBatches(
    String parentBatchId,
  ) async {
    final response = await _get(
      ApiEndpoints.batchChildren(parentBatchId),
      cacheKey: 'processor:children:$parentBatchId',
    );
    return ApiData.list(response)
        .map((json) => GeneratedChildBatchDto(json).toDomain())
        .toList(growable: false);
  }
}
