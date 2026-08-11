import '../entities/processor_entities.dart';

abstract interface class IncomingBatchRepository {
  Future<List<IncomingBatch>> getIncomingBatches();
  Future<IncomingBatch?> findIncomingBatch(String scannedValue);
}

abstract interface class ProcessingRepository {
  Future<List<ProcessingJob>> getProcessingHistory();
  Future<List<GeneratedChildBatch>> getChildBatches(String parentBatchId);
}

abstract interface class QualityInspectionRepository {}

abstract interface class ProcessorReferenceRepository {
  Future<ProcessorReferenceData> getReferenceData();
}

abstract interface class ProcessorRepository
    implements
        IncomingBatchRepository,
        ProcessingRepository,
        QualityInspectionRepository,
        ProcessorReferenceRepository {}
