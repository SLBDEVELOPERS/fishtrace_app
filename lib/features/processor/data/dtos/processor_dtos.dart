import '../../../../core/models/models.dart';
import '../../../../core/network/api_support.dart';
import '../../domain/entities/processor_entities.dart';

class GeneratedChildBatchDto {
  const GeneratedChildBatchDto(this.json);

  final Map<String, Object?> json;

  GeneratedChildBatch toDomain() {
    final qrCode = ApiData.map(ApiData.value(json, 'qrCode') ?? const {});
    return GeneratedChildBatch(
      id: ApiData.string(json, 'id'),
      batchCode: ApiData.string(json, 'batchCode'),
      weightKg: ApiData.number(json, 'totalWeightKg'),
      traceUrl: ApiData.string(qrCode, 'traceUrl'),
    );
  }
}

class IncomingBatchDto {
  const IncomingBatchDto(this.json);
  final Map<String, Object?> json;
  factory IncomingBatchDto.fromJson(Map<String, Object?> json) =>
      IncomingBatchDto(json);

  IncomingBatch toDomain() {
    final batch = _map(json['batch']);
    final source = batch.isEmpty ? json : batch;
    final species = _map(source['species']);
    final qrCode = _map(ApiData.value(source, 'qrCode'));
    final trip = _map(source['trip']);
    final boat = _map(trip['boat']);
    final organization = _map(source['organization']);
    return IncomingBatch(
      id: ApiData.string(source, 'id'),
      species: ApiData.string(species, 'commonName'),
      weightKg: ApiData.number(source, 'totalWeightKg'),
      origin: ApiData.string(
        source,
        'landingSiteName',
        ApiData.string(trip, 'generalCatchArea', 'Not recorded'),
      ),
      vessel: ApiData.string(boat, 'name', 'Not recorded'),
      supplier: ApiData.string(organization, 'name', 'Not recorded'),
      catchDate: ApiData.date(source, 'createdFromCatchAt'),
      receivedAt: ApiData.date(source, 'createdAt'),
      temperature: ApiData.number(source, 'storageTemperatureCelsius'),
      status: _enum(
        BatchStatus.values,
        ApiData.string(json, 'status'),
        BatchStatus.newBatch,
      ),
      notes: ApiData.string(json, 'notes'),
      batchCode: ApiData.string(source, 'batchCode'),
      traceUrl: ApiData.string(qrCode, 'traceUrl'),
      documents: ApiData.listValue(source, 'documents')
          .map(_map)
          .map(
            (item) => IncomingBatchDocument(
              name: ApiData.string(item, 'originalName', 'Batch document'),
              downloadUrl: ApiData.string(item, 'downloadUrl'),
              mimeType: ApiData.string(item, 'mimeType'),
            ),
          )
          .where((item) => item.downloadUrl.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class ProcessingJobDto {
  const ProcessingJobDto(this.json);
  final Map<String, Object?> json;
  factory ProcessingJobDto.fromJson(Map<String, Object?> json) =>
      ProcessingJobDto(json);

  ProcessingJob toDomain() {
    final batch = _map(json['batch']);
    final species = _map(batch['species']);
    final processing = _map(json['processing_record']);
    final steps = ApiData.listValue(processing, 'steps');
    final hasProcessingRecord = processing.isNotEmpty;
    final allStepsCompleted =
        steps.isNotEmpty &&
        steps.every(
          (step) =>
              ApiData.string(_map(step), 'status').toUpperCase() == 'COMPLETED',
        );
    final currentStep = steps.isEmpty
        ? const <String, Object?>{}
        : _map(
            steps.firstWhere(
              (step) =>
                  ApiData.string(_map(step), 'status').toUpperCase() !=
                  'COMPLETED',
              orElse: () => steps.last,
            ),
          );
    final measurements = _map(currentStep['measurements']);
    return ProcessingJob(
      id: ApiData.string(json, 'id'),
      batchId: ApiData.string(json, 'fishBatchId'),
      species: ApiData.string(species, 'commonName'),
      inputWeightKg: ApiData.number(
        processing,
        'inputWeightKg',
        ApiData.number(batch, 'totalWeightKg'),
      ),
      outputWeightKg: ApiData.number(processing, 'outputWeightKg'),
      packageCount: ApiData.integer(measurements, 'packageCount'),
      status: _enum(
        BatchStatus.values,
        hasProcessingRecord
            ? ApiData.string(processing, 'status')
            : ApiData.string(json, 'status') == 'REJECTED'
            ? 'REJECTED'
            : 'NEW_BATCH',
        BatchStatus.inProgress,
      ),
      currentStep: _enum(
        ProcessingStep.values,
        ApiData.string(currentStep, 'type'),
        ProcessingStep.cleaning,
      ),
      currentStepActive:
          ApiData.string(currentStep, 'status').toUpperCase() == 'ACTIVE',
      allStepsCompleted: allStepsCompleted,
      hasProcessingRecord: hasProcessingRecord,
      startedAt: ApiData.date(
        processing,
        'startedAt',
        ApiData.date(json, 'receivedAt'),
      ),
    );
  }
}

Map<String, Object?> _map(Object? value) =>
    value is Map ? value.cast<String, Object?>() : const {};

T _enum<T extends Enum>(List<T> values, String raw, T fallback) {
  String normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
  final normalized = normalize(raw);
  return values.firstWhere(
    (value) => normalize(value.name) == normalized,
    orElse: () => fallback,
  );
}
