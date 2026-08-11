import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/transporter_entities.dart';
import '../../domain/repositories/transporter_repository.dart';
import '../dtos/transporter_dtos.dart';

class DioTransporterRepository implements TransporterRepository {
  DioTransporterRepository(this._api);
  final ApiClient _api;

  Future<List<T>> _list<T>(
    String path,
    T Function(Map<String, Object?>) parser,
  ) async => ApiData.list(await _api.get(path)).map(parser).toList();

  @override
  Future<List<TransporterTripView>> getTrips() => _list(
    ApiEndpoints.transportTrips,
    (json) => TransportTripDto.fromJson(json).toDomain(),
  );
  @override
  Future<List<TransportVehicleView>> getVehicles() => _list(
    ApiEndpoints.vehicles,
    (json) => VehicleDto.fromJson(json).toDomain(),
  );
  @override
  Future<List<TransportDeviceView>> getDevices() => _list(
    ApiEndpoints.iotDevices,
    (json) => IoTDeviceDto.fromJson(json).toDomain(),
  );
  @override
  Future<List<HandoverBatch>> getHandoverBatches() => _list(
    ApiEndpoints.handoverBatches,
    (json) => HandoverBatchDto.fromJson(json).toDomain(),
  );
  @override
  Future<HandoverBatch?> findHandoverBatch(String scannedValue) async {
    try {
      final response = await _api.get(
        ApiEndpoints.transporterResolveBatch,
        query: {'code': scannedValue},
      );
      final envelope = ApiData.map(response);
      return HandoverBatchDto.fromJson(
        ApiData.map(envelope['data'] ?? envelope),
      ).toDomain();
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<List<TransportAlertView>> getAlerts(String tripId) => _list(
    ApiEndpoints.transportAlerts(tripId),
    (json) => TransportAlertDto.fromJson(json).toDomain(),
  );
}
