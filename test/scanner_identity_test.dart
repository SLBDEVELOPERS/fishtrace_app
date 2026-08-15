import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/features/processor/domain/entities/processor_entities.dart';
import 'package:fishtrace/features/processor/data/dtos/processor_dtos.dart';
import 'package:fishtrace/features/retailer/domain/entities/retailer_entities.dart';
import 'package:fishtrace/features/transporter/domain/entities/transporter_entities.dart';
import 'package:fishtrace/features/transporter/data/dtos/transporter_dtos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const id = '019fec17-0406-70d4-afd7-d8ac2cf03114';
  const code = 'FT-20260810-YFZZRIFC';
  const traceUrl = 'http://localhost:8002/trace/public-token';

  test('processor scanner accepts backend UUID, code, URL, and token', () {
    final batch = IncomingBatch(
      id: id,
      batchCode: code,
      traceUrl: traceUrl,
      species: 'Yellowfin Tuna',
      weightKg: 20,
      origin: 'Mirissa',
      vessel: 'Test Boat',
      supplier: 'Test Fisher',
      catchDate: DateTime.utc(2026, 8, 10),
      receivedAt: DateTime.utc(2026, 8, 10),
      temperature: 5,
      status: BatchStatus.newBatch,
    );

    expect(batch.matchesScan(id), isTrue);
    expect(batch.matchesScan(code), isTrue);
    expect(batch.matchesScan(traceUrl), isTrue);
    expect(batch.matchesScan('public-token'), isTrue);
  });

  test('processor DTO reads the backend snake-case QR payload', () {
    final batch = IncomingBatchDto.fromJson({
      'id': id,
      'batch_code': code,
      'total_weight_kg': 20,
      'status': 'AVAILABLE_FOR_PROCESSING',
      'species': {'common_name': 'Yellowfin Tuna'},
      'qr_code': {'trace_url': traceUrl},
    }).toDomain();

    expect(batch.traceUrl, traceUrl);
    expect(batch.matchesScan(traceUrl), isTrue);
    expect(batch.matchesScan('public-token'), isTrue);
  });

  test('transporter scanner resolves a scan to the real batch UUID', () {
    const batch = HandoverBatch(
      id: id,
      batchCode: code,
      traceUrl: traceUrl,
      species: 'Yellowfin Tuna',
      weightKg: 20,
    );

    expect(batch.matchesScan(code), isTrue);
    expect(batch.matchesScan('public-token'), isTrue);
  });

  test('transporter device DTO uses backend display name and code', () {
    final device = IoTDeviceDto.fromJson({
      'id': '01a004ad-7735-73d1-af82-c89054e4b6ef',
      'device_code': 'IOT-003',
      'display_name': 'Testing Iot',
      'status': 'ACTIVE',
    }).toDomain();

    expect(device.displayName, 'Testing Iot');
    expect(device.deviceCode, 'IOT-003');
    expect(device.label, 'Testing Iot');
  });

  test('retailer scanner accepts package label identity and trace URL', () {
    final package = ReceivedRetailBatch(
      id: id,
      labelCode: 'LBL-ABC123',
      traceUrl: traceUrl,
      supplier: 'Processor',
      product: 'Tuna loin',
      netWeightKg: 20,
      expiry: DateTime.utc(2026, 8, 20),
      quality: 'Verified',
      temperatureHistory: const [],
      receivedAt: DateTime.utc(2026, 8, 10),
    );

    expect(package.matchesScan('LBL-ABC123'), isTrue);
    expect(package.matchesScan(traceUrl), isTrue);
    expect(package.matchesScan('public-token'), isTrue);
  });
}
