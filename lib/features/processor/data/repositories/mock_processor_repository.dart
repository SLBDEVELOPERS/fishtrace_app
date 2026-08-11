import '../../../../core/models/models.dart';
import '../../domain/entities/processor_entities.dart';
import '../../domain/repositories/processor_repository.dart';

class MockProcessorRepository implements ProcessorRepository {
  @override
  Future<List<GeneratedChildBatch>> getChildBatches(
    String parentBatchId,
  ) async => [
    GeneratedChildBatch(
      id: '$parentBatchId-child-01',
      batchCode: '$parentBatchId-01',
      weightKg: 56.4,
      traceUrl: 'https://example.test/trace/$parentBatchId-child-01',
    ),
    GeneratedChildBatch(
      id: '$parentBatchId-child-02',
      batchCode: '$parentBatchId-02',
      weightKg: 56.4,
      traceUrl: 'https://example.test/trace/$parentBatchId-child-02',
    ),
  ];

  @override
  Future<IncomingBatch?> findIncomingBatch(String scannedValue) async {
    final batches = await getIncomingBatches();
    for (final batch in batches) {
      if (batch.matchesScan(scannedValue)) return batch;
    }
    return null;
  }

  @override
  Future<ProcessorReferenceData> getReferenceData() async =>
      const ProcessorReferenceData(
        qualityGrades: [
          ProcessorQualityGrade(id: 'grade-a', code: 'A', name: 'Grade A'),
          ProcessorQualityGrade(id: 'grade-b', code: 'B', name: 'Grade B'),
          ProcessorQualityGrade(id: 'grade-c', code: 'C', name: 'Grade C'),
        ],
        processingTypes: ['Chilled Whole Fish Processing'],
      );

  @override
  Future<List<IncomingBatch>> getIncomingBatches() async => [
    IncomingBatch(
      id: 'FT-TRP-2024-05-21',
      species: 'Yellowfin Tuna',
      weightKg: 125.4,
      origin: 'Indian Ocean · FAO 57',
      vessel: 'Ocean Star',
      supplier: 'Oceanic Fisheries',
      catchDate: DateTime(2024, 5, 20, 7, 15),
      receivedAt: DateTime(2024, 5, 21, 8, 40),
      temperature: 2.1,
      status: BatchStatus.newBatch,
      notes: 'Delivered in good condition.',
    ),
    IncomingBatch(
      id: 'FT-TRP-2024-05-20',
      species: 'Skipjack Tuna',
      weightKg: 98.7,
      origin: 'Arabian Sea · FAO 51',
      vessel: 'Sea Queen',
      supplier: 'Blue Ocean Cooperative',
      catchDate: DateTime(2024, 5, 19, 6, 50),
      receivedAt: DateTime(2024, 5, 20, 9, 10),
      temperature: 2.4,
      status: BatchStatus.inProgress,
    ),
  ];

  @override
  Future<List<ProcessingJob>> getProcessingHistory() async => [
    ProcessingJob(
      id: 'PROC-2024-0521',
      batchId: 'FT-TRP-2024-05-21',
      species: 'Yellowfin Tuna',
      inputWeightKg: 125.4,
      outputWeightKg: 112.8,
      packageCount: 13,
      status: BatchStatus.completed,
      currentStep: ProcessingStep.packaging,
      startedAt: DateTime(2024, 5, 21, 8, 45),
    ),
    ProcessingJob(
      id: 'PROC-2024-0520',
      batchId: 'FT-TRP-2024-05-20',
      species: 'Skipjack Tuna',
      inputWeightKg: 98.7,
      outputWeightKg: 88.2,
      packageCount: 10,
      status: BatchStatus.completed,
      currentStep: ProcessingStep.packaging,
      startedAt: DateTime(2024, 5, 20, 9, 10),
    ),
    ProcessingJob(
      id: 'PROC-2024-0519',
      batchId: 'FT-TRP-2024-05-19',
      species: 'Indian Mackerel',
      inputWeightKg: 96.4,
      outputWeightKg: 0,
      packageCount: 0,
      status: BatchStatus.inProgress,
      currentStep: ProcessingStep.freezing,
      startedAt: DateTime(2024, 5, 19, 10, 30),
    ),
  ];
}
