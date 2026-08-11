import 'package:get/get.dart';

import '../../../../core/data/repositories.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/validation/business_validators.dart';
import '../../domain/entities/processor_entities.dart';
import '../../domain/repositories/processor_repository.dart';

enum ProcessingHistoryFilter { all, completed, inProgress, rejected }

class ProcessorController extends GetxController {
  ProcessorController({
    required ProcessorRepository repository,
    required AppController session,
  }) : _repository = repository,
       _session = session;

  final ProcessorRepository _repository;
  final AppController _session;

  final incoming = <IncomingBatch>[].obs;
  final history = <ProcessingJob>[].obs;
  final generatedChildren = <GeneratedChildBatch>[].obs;
  final acceptedBatchIds = <String>{}.obs;
  final selectedBatch = Rxn<IncomingBatch>();
  final referenceData = const ProcessorReferenceData.empty().obs;
  final loading = false.obs;
  final currentProcessingStep = ProcessingStep.cleaning.obs;
  final historyFilter = ProcessingHistoryFilter.all.obs;
  final search = ''.obs;
  final error = Rxn<AppException>();
  final inspection = <InspectionCriterion>[
    const InspectionCriterion(
      name: 'Appearance',
      description: 'Bright, clean, natural shine',
      result: InspectionResult.pass,
    ),
    const InspectionCriterion(
      name: 'Odour',
      description: 'Fresh sea smell',
      result: InspectionResult.pass,
    ),
    const InspectionCriterion(
      name: 'Gills',
      description: 'Bright red / pink',
      result: InspectionResult.pass,
    ),
    const InspectionCriterion(
      name: 'Eyes',
      description: 'Clear and protruding',
      result: InspectionResult.pass,
    ),
    const InspectionCriterion(
      name: 'Texture',
      description: 'Firm to touch',
      result: InspectionResult.pass,
    ),
  ].obs;

  List<ProcessingJob> get filteredHistory => history.where((job) {
    final query = search.value.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        job.batchId.toLowerCase().contains(query) ||
        job.species.toLowerCase().contains(query);
    final matchesStatus = switch (historyFilter.value) {
      ProcessingHistoryFilter.all => true,
      ProcessingHistoryFilter.completed => job.status == BatchStatus.completed,
      ProcessingHistoryFilter.inProgress =>
        job.status == BatchStatus.inProgress,
      ProcessingHistoryFilter.rejected => job.status == BatchStatus.rejected,
    };
    return matchesQuery && matchesStatus;
  }).toList();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final selectedId = selectedBatch.value?.id;
    loading.value = true;
    error.value = null;
    try {
      final result = await Future.wait([
        _repository.getIncomingBatches(),
        _repository.getProcessingHistory(),
        _repository.getReferenceData(),
      ]);
      incoming.assignAll(result[0] as List<IncomingBatch>);
      history.assignAll(result[1] as List<ProcessingJob>);
      referenceData.value = result[2] as ProcessorReferenceData;
      // Intake is an explicit action. Do not silently select the first server
      // batch during startup/refresh, otherwise the Intake tab can briefly
      // expose Accept/Reject for a batch the user never scanned or selected.
      selectedBatch.value = selectedId == null
          ? null
          : incoming.firstWhereOrNull((batch) => batch.id == selectedId);
    } on AppException catch (failure) {
      error.value = failure;
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshHistory() async {
    history.assignAll(await _repository.getProcessingHistory());
  }

  Future<void> refreshChildBatches(String parentBatchId) async {
    generatedChildren.assignAll(
      await _repository.getChildBatches(parentBatchId),
    );
  }

  Future<bool> selectBatchByCode(String code) async {
    final cached = incoming.firstWhereOrNull((item) => item.matchesScan(code));
    if (cached != null) {
      selectedBatch.value = cached;
      return true;
    }
    final resolved = await _repository.findIncomingBatch(code);
    selectedBatch.value = resolved;
    if (resolved == null) return false;
    final index = incoming.indexWhere((item) => item.id == resolved.id);
    if (index < 0) {
      incoming.insert(0, resolved);
    } else {
      incoming[index] = resolved;
    }
    return true;
  }

  Future<SyncQueueItem?> acceptSelected() async {
    final batch = selectedBatch.value;
    if (batch == null) return null;
    final queued = await _session.queue(
      'Accept processor intake',
      recordType: 'intake',
      payload: {
        'batchId': batch.id,
        'decision': 'accepted',
        'receivedWeightKg': batch.weightKg,
        'notes': 'Accepted in good condition.',
        'acceptedAt': DateTime.now().toIso8601String(),
      },
    );
    if (queued.status == SyncStatus.synced) acceptedBatchIds.add(batch.id);
    return queued;
  }

  Future<SyncQueueItem?> rejectSelected(String reason, String notes) async {
    final batch = selectedBatch.value;
    if (batch == null || reason.trim().isEmpty) return null;
    final queued = await _session.queue(
      'Reject processor intake',
      recordType: 'intake',
      payload: {
        'batchId': batch.id,
        'decision': 'rejected',
        'receivedWeightKg': batch.weightKg,
        'reason': reason,
        'notes': notes,
        'rejectedAt': DateTime.now().toIso8601String(),
      },
    );
    if (queued.status == SyncStatus.synced) {
      incoming.removeWhere((item) => item.id == batch.id);
      selectedBatch.value = incoming.firstOrNull;
    }
    return queued;
  }

  void updateInspection(int index, InspectionResult result) {
    inspection[index] = inspection[index].copyWith(result: result);
  }

  String? validateOutput(double input, double output) =>
      BusinessValidators.childBatchWeights(
        parentWeightKg: input,
        childWeightsKg: [output],
      );

  ProcessingJob? processingFor(String batchId) =>
      history.firstWhereOrNull((job) => job.batchId == batchId);

  void selectProcessingJob(ProcessingJob job) {
    selectedBatch.value = IncomingBatch(
      id: job.batchId,
      species: job.species,
      weightKg: job.inputWeightKg,
      origin: 'Recorded intake',
      vessel: 'Not recorded',
      supplier: 'Recorded supplier',
      catchDate: job.startedAt,
      receivedAt: job.startedAt,
      temperature: 0,
      status: job.status,
    );
    if (!job.hasProcessingRecord) acceptedBatchIds.add(job.batchId);
  }

  Future<SyncQueueItem> queue(
    String label,
    String type,
    Map<String, Object?> payload,
  ) => _session.queue(label, recordType: type, payload: payload);
}
