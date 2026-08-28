import 'package:fishtrace/core/utils/display_identifier.dart';
import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/features/fisher/domain/entities/fisher_entities.dart';
import 'package:fishtrace/features/fisher/data/dtos/fisher_dtos.dart';
import 'package:fishtrace/features/processor/domain/entities/processor_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('business code is preferred over an internal UUID', () {
    expect(
      DisplayIdentifier.resolve(
        id: '550e8400-e29b-41d4-a716-446655440000',
        code: 'TRIP-2026-0042',
        noun: 'Trip',
      ),
      'TRIP-2026-0042',
    );
  });

  test('opaque IDs use a short typed fallback when no code exists', () {
    final label = DisplayIdentifier.resolve(
      id: '550e8400-e29b-41d4-a716-446655440000',
      noun: 'Batch',
    );

    expect(label, 'Batch 55440000');
    expect(label, isNot(contains('550e8400-e29b')));
  });

  test('domain labels consistently prefer user-facing codes', () {
    final trip = ActiveFishingTrip(
      id: '550e8400-e29b-41d4-a716-446655440000',
      tripCode: 'TRIP-2026-0042',
      boatId: 'boat-1',
      boatName: 'Sea Star',
      startedAt: DateTime.utc(2026, 8, 23),
      fishingArea: 'Negombo',
      crew: const [],
      catchKg: 0,
      batchCount: 0,
      status: TripStatus.inProgress,
    );
    final batch = IncomingBatch(
      id: '550e8400-e29b-41d4-a716-446655440001',
      batchCode: 'BATCH-2026-0188',
      species: 'Yellowfin Tuna',
      weightKg: 100,
      origin: 'Negombo',
      vessel: 'Sea Star',
      supplier: 'Ocean Foods',
      catchDate: DateTime.utc(2026, 8, 22),
      receivedAt: DateTime.utc(2026, 8, 23),
      temperature: 2,
      status: BatchStatus.newBatch,
    );

    expect(trip.label, 'TRIP-2026-0042');
    expect(batch.label, 'BATCH-2026-0188');
  });

  test('Fisher API DTO preserves batch and trip codes for presentation', () {
    final batch = FisherBatchDto.fromJson({
      'id': '550e8400-e29b-41d4-a716-446655440001',
      'batch_code': 'BATCH-2026-0188',
      'fishing_trip_id': '550e8400-e29b-41d4-a716-446655440000',
      'trip': {'trip_code': 'TRIP-2026-0042'},
    }).toDomain();

    expect(batch.label, 'BATCH-2026-0188');
    expect(batch.tripLabel, 'TRIP-2026-0042');
  });
}
