import '../entities/transporter_entities.dart';

abstract interface class TransportTripRepository {
  Future<List<TransporterTripView>> getTrips();
}

abstract interface class VehicleRepository {
  Future<List<TransportVehicleView>> getVehicles();
}

abstract interface class IoTDeviceRepository {
  Future<List<TransportDeviceView>> getDevices();
}

abstract interface class DeliveryRepository {
  Future<List<HandoverBatch>> getHandoverBatches();
  Future<HandoverBatch?> findHandoverBatch(String scannedValue);
}

abstract interface class TransportAlertRepository {
  Future<List<TransportAlertView>> getAlerts(String tripId);
}

abstract interface class TransporterRepository
    implements
        TransportTripRepository,
        VehicleRepository,
        IoTDeviceRepository,
        DeliveryRepository,
        TransportAlertRepository {}
