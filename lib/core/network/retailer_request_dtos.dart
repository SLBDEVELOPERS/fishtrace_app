class StoreRetailReceiptRequestDto {
  const StoreRetailReceiptRequestDto({
    required this.packageLabelId,
    required this.retailLocationId,
    required this.receivedPackageCount,
    this.conditionTemperature,
    this.notes,
  });

  final String packageLabelId;
  final String retailLocationId;
  final int receivedPackageCount;
  final double? conditionTemperature;
  final String? notes;

  Map<String, Object?> toJson() => {
    'package_label_id': packageLabelId,
    'retail_location_id': retailLocationId,
    'received_package_count': receivedPackageCount,
    if (conditionTemperature != null)
      'condition_temperature': conditionTemperature,
    if (notes?.isNotEmpty ?? false) 'notes': notes,
  };
}

class ResolveRetailAlertRequestDto {
  const ResolveRetailAlertRequestDto({required this.note});
  final String note;

  Map<String, Object?> toJson() => {'note': note.trim()};
}
