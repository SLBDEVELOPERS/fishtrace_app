import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/processor_entities.dart';
import '../../domain/repositories/processor_repository.dart';
import '../dtos/processor_dtos.dart';

class DioProcessorRepository implements ProcessorRepository {
  DioProcessorRepository(this._api);
  final ApiClient _api;

  @override
  Future<IncomingBatch?> findIncomingBatch(String scannedValue) async {
    try {
      final response = await _api.get(
        ApiEndpoints.processorResolveBatch,
        query: {'code': scannedValue},
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
    final response = await _api.get(ApiEndpoints.processorReferenceData);
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
    final response = await _api.get(ApiEndpoints.processorIncomingBatches);
    return ApiData.list(
      response,
    ).map((json) => IncomingBatchDto.fromJson(json).toDomain()).toList();
  }

  @override
  Future<List<ProcessingJob>> getProcessingHistory() async {
    final response = await _api.get(ApiEndpoints.processorHistory);
    return ApiData.list(
      response,
    ).map((json) => ProcessingJobDto.fromJson(json).toDomain()).toList();
  }

  @override
  Future<List<GeneratedChildBatch>> getChildBatches(
    String parentBatchId,
  ) async {
    final response = await _api.get(ApiEndpoints.batchChildren(parentBatchId));
    return ApiData.list(response)
        .map((json) => GeneratedChildBatchDto(json).toDomain())
        .toList(growable: false);
  }
}
