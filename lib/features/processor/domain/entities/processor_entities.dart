import '../../../../core/models/models.dart';

class ProcessorQualityGrade {
  const ProcessorQualityGrade({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;
}

class ProcessorReferenceData {
  const ProcessorReferenceData({
    required this.qualityGrades,
    required this.processingTypes,
  });

  const ProcessorReferenceData.empty()
    : qualityGrades = const [],
      processingTypes = const [];

  final List<ProcessorQualityGrade> qualityGrades;
  final List<String> processingTypes;
}

class IncomingBatchDocument {
  const IncomingBatchDocument({
    required this.name,
    required this.downloadUrl,
    required this.mimeType,
  });

  final String name;
  final String downloadUrl;
  final String mimeType;
}

class GeneratedChildBatch {
  const GeneratedChildBatch({
    required this.id,
    required this.batchCode,
    required this.weightKg,
    required this.traceUrl,
  });

  final String id;
  final String batchCode;
  final double weightKg;
  final String traceUrl;
}

class IncomingBatch {
  const IncomingBatch({
    required this.id,
    required this.species,
    required this.weightKg,
    required this.origin,
    required this.vessel,
    required this.supplier,
    required this.catchDate,
    required this.receivedAt,
    required this.temperature,
    required this.status,
    this.notes = '',
    this.batchCode = '',
    this.traceUrl = '',
    this.documents = const [],
  });

  final String id;
  final String species;
  final double weightKg;
  final String origin;
  final String vessel;
  final String supplier;
  final DateTime catchDate;
  final DateTime receivedAt;
  final double temperature;
  final BatchStatus status;
  final String notes;
  final String batchCode;
  final String traceUrl;
  final List<IncomingBatchDocument> documents;

  bool matchesScan(String value) {
    final normalized = value.trim().toLowerCase();
    final scannedUri = Uri.tryParse(normalized);
    final scannedToken = scannedUri?.pathSegments.isNotEmpty == true
        ? scannedUri!.pathSegments.last
        : normalized;
    final traceUri = Uri.tryParse(traceUrl);
    final traceToken = traceUri?.pathSegments.isNotEmpty == true
        ? traceUri!.pathSegments.last.toLowerCase()
        : '';
    return id.toLowerCase() == normalized ||
        id.toLowerCase() == scannedToken ||
        batchCode.toLowerCase() == normalized ||
        traceUrl.toLowerCase() == normalized ||
        (traceToken.isNotEmpty && traceToken == scannedToken);
  }
}

class ProcessingJob {
  const ProcessingJob({
    required this.id,
    required this.batchId,
    this.batchCode = '',
    required this.species,
    required this.inputWeightKg,
    required this.outputWeightKg,
    required this.packageCount,
    required this.status,
    required this.currentStep,
    required this.startedAt,
    this.currentStepActive = false,
    this.allStepsCompleted = false,
    this.hasProcessingRecord = true,
  });

  final String id;
  final String batchId;
  final String batchCode;
  final String species;
  final double inputWeightKg;
  final double outputWeightKg;
  final int packageCount;
  final BatchStatus status;
  final ProcessingStep currentStep;
  final bool currentStepActive;
  final bool allStepsCompleted;
  final bool hasProcessingRecord;
  final DateTime startedAt;

  String get batchLabel => batchCode.isNotEmpty ? batchCode : batchId;
}

class InspectionCriterion {
  const InspectionCriterion({
    required this.name,
    required this.description,
    required this.result,
  });

  final String name;
  final String description;
  final InspectionResult result;

  InspectionCriterion copyWith({InspectionResult? result}) =>
      InspectionCriterion(
        name: name,
        description: description,
        result: result ?? this.result,
      );
}
