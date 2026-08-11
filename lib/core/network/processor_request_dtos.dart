class CreateProcessingRecordRequestDto {
  const CreateProcessingRecordRequestDto({
    required this.fishBatchId,
    required this.inputWeightKg,
    required this.operatorName,
    required this.processingArea,
    this.notes,
  });

  final String fishBatchId;
  final double inputWeightKg;
  final String operatorName;
  final String processingArea;
  final String? notes;

  Map<String, Object?> toJson() => {
    'fish_batch_id': fishBatchId,
    'input_weight_kg': inputWeightKg,
    'operator_name': operatorName,
    'processing_area': processingArea,
    if (notes?.isNotEmpty ?? false) 'notes': notes,
  };
}

class CompleteProcessingStepRequestDto {
  const CompleteProcessingStepRequestDto({
    required this.measurements,
    this.notes,
  });

  final Map<String, Object?> measurements;
  final String? notes;

  Map<String, Object?> toJson() => {
    'measurements': measurements,
    if (notes?.isNotEmpty ?? false) 'notes': notes,
  };
}
