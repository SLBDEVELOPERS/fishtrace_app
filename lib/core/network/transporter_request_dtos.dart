class UpsertVehicleRequestDto {
  const UpsertVehicleRequestDto({
    required this.registrationNumber,
    required this.name,
    required this.capacityTonnes,
    this.isActive,
  });

  final String registrationNumber;
  final String name;
  final double capacityTonnes;
  final bool? isActive;

  Map<String, Object?> toJson() => {
    'registration_number': registrationNumber,
    'name': name,
    'capacity_tonnes': capacityTonnes,
    if (isActive != null) 'is_active': isActive,
  };
}

class UpdateTransportChecklistRequestDto {
  const UpdateTransportChecklistRequestDto({required this.completedLabels});

  static const labelsByKey = <String, String>{
    'vehicle_inspected': 'Vehicle safety inspection',
    'refrigeration_operational': 'Refrigeration system',
    'cargo_secured': 'Cargo and batch seals',
    'device_online': 'IoT device online',
    'doors_sealed': 'Cargo doors sealed',
  };

  final Set<String> completedLabels;

  Map<String, Object?> toJson() => {
    'items': labelsByKey.entries
        .map(
          (entry) => {
            'key': entry.key,
            'completed': completedLabels.contains(entry.value),
          },
        )
        .toList(growable: false),
  };
}

class StoreDeliveryConfirmationRequestDto {
  const StoreDeliveryConfirmationRequestDto({
    required this.receiverName,
    required this.deliveredAt,
    this.receiverContact,
    this.notes,
  });

  final String receiverName;
  final String? receiverContact;
  final String? notes;
  final DateTime deliveredAt;

  Map<String, Object?> toJson() => {
    'receiver_name': receiverName,
    if (receiverContact?.isNotEmpty ?? false)
      'receiver_contact': receiverContact,
    if (notes?.isNotEmpty ?? false) 'notes': notes,
    'delivered_at': deliveredAt.toUtc().toIso8601String(),
  };
}

class AcknowledgeTransportAlertRequestDto {
  const AcknowledgeTransportAlertRequestDto({this.note});
  final String? note;

  Map<String, Object?> toJson() => {
    if (note?.trim().isNotEmpty ?? false) 'note': note!.trim(),
  };
}

class StoreTransportIncidentRequestDto {
  const StoreTransportIncidentRequestDto({
    required this.type,
    required this.severity,
    required this.description,
    required this.occurredAt,
  });

  final String type;
  final String severity;
  final String description;
  final DateTime occurredAt;

  Map<String, Object?> toJson() => {
    'type': type,
    'severity': severity,
    'description': description,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
  };
}
