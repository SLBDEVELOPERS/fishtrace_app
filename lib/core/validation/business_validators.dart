import '../models/models.dart';

abstract final class BusinessValidators {
  static String? positiveNumber(double? value, String label) {
    if (value == null || value <= 0) return '$label must be greater than zero.';
    return null;
  }

  static String? childBatchWeights({
    required double parentWeightKg,
    required Iterable<double> childWeightsKg,
  }) {
    if (parentWeightKg <= 0) return 'Parent weight must be greater than zero.';
    if (childWeightsKg.any((weight) => weight <= 0)) {
      return 'Every child batch must have a positive weight.';
    }
    final output = childWeightsKg.fold<double>(0, (sum, value) => sum + value);
    if (output > parentWeightKg) {
      return 'Child-batch output cannot exceed the parent weight.';
    }
    return null;
  }

  static String? saleQuantity({
    required double availableKg,
    required double requestedKg,
  }) {
    if (requestedKg <= 0) return 'Sale quantity must be greater than zero.';
    if (requestedKg > availableKg) {
      return 'Sale quantity exceeds available stock.';
    }
    return null;
  }

  static String? assignDevice(IoTDevice device, String tripId) {
    if (device.status == DeviceStatus.offline) return 'Device is offline.';
    if (device.assignedTripId != null && device.assignedTripId != tripId) {
      return 'Device is assigned to another active trip.';
    }
    return null;
  }

  static String? requiredChecklist({
    required Set<String> completed,
    required Set<String> mandatory,
  }) {
    final missing = mandatory.difference(completed);
    if (missing.isNotEmpty) {
      return 'Complete all mandatory checklist items before starting.';
    }
    return null;
  }
}
