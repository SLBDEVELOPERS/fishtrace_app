import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/core/validation/business_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('child batches cannot exceed parent weight', () {
    expect(
      BusinessValidators.childBatchWeights(
        parentWeightKg: 100,
        childWeightsKg: const [60, 45],
      ),
      isNotNull,
    );
    expect(
      BusinessValidators.childBatchWeights(
        parentWeightKg: 100,
        childWeightsKg: const [55, 45],
      ),
      isNull,
    );
  });

  test('sale cannot exceed available stock', () {
    expect(
      BusinessValidators.saleQuantity(availableKg: 10, requestedKg: 12),
      isNotNull,
    );
    expect(
      BusinessValidators.saleQuantity(availableKg: 10, requestedKg: 5),
      isNull,
    );
  });

  test('assigned device cannot be reused by an active trip', () {
    const device = IoTDevice(
      id: 'FT-TH-10023',
      status: DeviceStatus.assigned,
      battery: 98,
      signal: 91,
      assignedTripId: 'trip-a',
    );
    expect(BusinessValidators.assignDevice(device, 'trip-b'), isNotNull);
    expect(BusinessValidators.assignDevice(device, 'trip-a'), isNull);
  });
}
