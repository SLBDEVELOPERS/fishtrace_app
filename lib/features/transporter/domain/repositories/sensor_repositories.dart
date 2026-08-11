import '../../../../core/models/models.dart';

abstract interface class SensorRepository {
  Future<SensorReading?> latest(String tripId);
  Future<List<SensorReading>> history(String tripId);
}

abstract interface class LiveSensorRepository {
  Stream<SensorReading> watchTrip(String tripId);
  Future<void> dispose();
}
