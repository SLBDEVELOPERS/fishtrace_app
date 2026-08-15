import 'package:get/get.dart';

import '../../../../core/data/repositories.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/validation/business_validators.dart';
import '../../domain/entities/transporter_entities.dart';
import '../../domain/repositories/transporter_repository.dart';
import 'live_monitoring_controller.dart';

enum TripFilter { all, inProgress, upcoming, completed }

enum DeviceFilter { all, online, offline }

class TransporterController extends GetxController {
  TransporterController({
    required TransporterRepository repository,
    required AppController session,
  }) : _repository = repository,
       _session = session;

  final TransporterRepository _repository;
  final AppController _session;

  final trips = <TransporterTripView>[].obs;
  final vehicles = <TransportVehicleView>[].obs;
  final devices = <TransportDeviceView>[].obs;
  final handoverBatches = <HandoverBatch>[].obs;
  final alerts = <TransportAlertView>[].obs;
  final selectedTrip = Rxn<TransporterTripView>();
  final selectedVehicle = Rxn<TransportVehicleView>();
  final selectedDevice = Rxn<TransportDeviceView>();
  final tripFilter = TripFilter.all.obs;
  final deviceFilter = DeviceFilter.all.obs;
  final search = ''.obs;
  final checklist = <String>{}.obs;
  final loading = false.obs;
  final error = Rxn<AppException>();

  static const mandatoryChecklist = {
    'Vehicle safety inspection',
    'Refrigeration system',
    'Cargo and batch seals',
    'IoT device online',
    'Cargo doors sealed',
  };

  List<TransporterTripView> get filteredTrips => trips.where((trip) {
    final query = search.value.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        trip.tripCode.toLowerCase().contains(query) ||
        trip.id.toLowerCase().contains(query) ||
        trip.origin.toLowerCase().contains(query) ||
        trip.destination.toLowerCase().contains(query);
    final matchesFilter = switch (tripFilter.value) {
      TripFilter.all => true,
      TripFilter.inProgress => trip.status == TripStatus.inProgress,
      TripFilter.upcoming => trip.status == TripStatus.upcoming,
      TripFilter.completed => trip.status == TripStatus.completed,
    };
    return matchesQuery && matchesFilter;
  }).toList();

  List<TransportDeviceView> get filteredDevices => devices.where((device) {
    final query = search.value.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        device.displayName.toLowerCase().contains(query) ||
        device.deviceCode.toLowerCase().contains(query) ||
        device.id.toLowerCase().contains(query);
    final matchesFilter = switch (deviceFilter.value) {
      DeviceFilter.all => true,
      DeviceFilter.online => device.status != DeviceStatus.offline,
      DeviceFilter.offline => device.status == DeviceStatus.offline,
    };
    return matchesQuery && matchesFilter;
  }).toList();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({String? selectCreatedOrUpdatedId}) async {
    final previousSelection = selectedTrip.value;
    final selectedTripId =
        selectCreatedOrUpdatedId ??
        ((previousSelection?.status == TripStatus.inProgress ||
                previousSelection?.status == TripStatus.upcoming)
            ? previousSelection?.id
            : null);
    loading.value = true;
    error.value = null;
    try {
      final result = await Future.wait([
        _repository.getTrips(),
        _repository.getVehicles(),
        _repository.getDevices(),
        _repository.getHandoverBatches(),
      ]);
      trips.assignAll(result[0] as List<TransporterTripView>);
      vehicles.assignAll(result[1] as List<TransportVehicleView>);
      devices.assignAll(result[2] as List<TransportDeviceView>);
      handoverBatches.assignAll(result[3] as List<HandoverBatch>);
      selectedTrip.value = selectedTripId == null
          ? trips.firstWhereOrNull(
                  (trip) => trip.status == TripStatus.inProgress,
                ) ??
                trips.firstWhereOrNull(
                  (trip) => trip.status == TripStatus.upcoming,
                ) ??
                trips.firstOrNull
          : trips.firstWhereOrNull((trip) => trip.id == selectedTripId) ??
                trips.firstWhereOrNull(
                  (trip) => trip.status == TripStatus.inProgress,
                ) ??
                trips.firstWhereOrNull(
                  (trip) => trip.status == TripStatus.upcoming,
                ) ??
                trips.firstOrNull;
      selectedVehicle.value = vehicles.firstOrNull;
      _restoreTripState();
      await loadAlerts();
    } on AppException catch (failure) {
      error.value = failure;
    } finally {
      loading.value = false;
    }
  }

  TransporterTripView? get editableSelectedTrip {
    final trip = selectedTrip.value;
    return trip?.status == TripStatus.upcoming ? trip : null;
  }

  Future<SyncQueueItem> saveTrip({
    required bool editing,
    required String vehicleId,
    required String driver,
    required String origin,
    required String destination,
    double? distanceKm,
    double? originLatitude,
    double? originLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
  }) {
    final trip = editing ? editableSelectedTrip : null;
    if (editing && trip == null) {
      throw StateError('Only an upcoming trip can be edited.');
    }
    return queue('Save transport trip', 'transport-trip', {
      if (trip != null) 'tripId': trip.id,
      'vehicleId': vehicleId,
      'driver': driver,
      'origin': origin,
      'destination': destination,
      'distanceKm': distanceKm,
      'originLatitude': originLatitude,
      'originLongitude': originLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
    });
  }

  Future<SyncQueueItem> cancelSelectedTrip(String reason) {
    final trip = editableSelectedTrip;
    if (trip == null) throw StateError('Select an upcoming trip first.');
    return queue('Cancel transport trip', 'transport-cancel', {
      'tripId': trip.id,
      'reason': reason.trim(),
    });
  }

  Future<SyncQueueItem> removeBatch(HandoverBatch batch) {
    final trip = editableSelectedTrip;
    if (trip == null) throw StateError('Select an upcoming trip first.');
    return queue('Remove batch from transport trip', 'transport-remove-batch', {
      'tripId': trip.id,
      'batchId': batch.id,
    });
  }

  Future<SyncQueueItem> removeAssignedDevice() {
    final trip = editableSelectedTrip;
    if (trip == null) throw StateError('Select an upcoming trip first.');
    return queue('Remove IoT device', 'transport-remove-device', {
      'tripId': trip.id,
    });
  }

  void selectTrip(TransporterTripView trip) {
    selectedTrip.value = trip;
    _restoreTripState();
    loadAlerts();
  }

  void _restoreTripState() {
    final trip = selectedTrip.value;
    checklist.assignAll(trip?.completedChecklistItems ?? const {});
    selectedDevice.value = trip?.assignedDeviceId == null
        ? null
        : devices.firstWhereOrNull(
            (device) => device.id == trip!.assignedDeviceId,
          );
  }

  Future<HandoverBatch?> resolveHandoverBatch(String scannedValue) async {
    final cached = handoverBatches.firstWhereOrNull(
      (item) => item.matchesScan(scannedValue),
    );
    if (cached != null) return cached;
    final resolved = await _repository.findHandoverBatch(scannedValue);
    if (resolved != null &&
        handoverBatches.every((item) => item.id != resolved.id)) {
      handoverBatches.insert(0, resolved);
    }
    return resolved;
  }

  String? selectDevice(TransportDeviceView device) {
    final trip = selectedTrip.value;
    if (trip == null) return 'Select a transport trip first.';
    final model = IoTDevice(
      id: device.id,
      status: device.status,
      battery: device.battery,
      signal: device.signal,
      assignedTripId: device.assignedTripId,
    );
    final error = BusinessValidators.assignDevice(model, trip.id);
    if (error == null) selectedDevice.value = device;
    return error;
  }

  String? validateChecklist() => BusinessValidators.requiredChecklist(
    completed: checklist,
    mandatory: mandatoryChecklist,
  );

  Future<SyncQueueItem> queue(
    String label,
    String type,
    Map<String, Object?> payload,
  ) => _session.queue(label, recordType: type, payload: payload);

  Future<SyncQueueItem> startSelectedTrip() async {
    final selectedId = selectedTrip.value?.id;
    if (selectedId != null) {
      await load(selectCreatedOrUpdatedId: selectedId);
    }
    final trip = selectedTrip.value;
    if (trip == null) throw StateError('Select a transport trip first.');
    final checklistError = validateChecklist();
    if (checklistError != null) throw StateError(checklistError);
    if (trip.batchCount < 1) {
      throw StateError('Assign at least one batch before starting the trip.');
    }
    final assignedDevice = devices.firstWhereOrNull(
      (device) => device.id == trip.assignedDeviceId,
    );

    if (assignedDevice == null ||
        assignedDevice.status == DeviceStatus.offline ||
        !trip.deviceAssignmentSynced) {
      throw StateError('Assign an online synchronized IoT device first.');
    }
    final queued = await queue('Start transport trip', 'transport-start', {
      'tripId': trip.id,
    });
    if (queued.status == SyncStatus.synced) {
      _replaceTrip(trip.copyWith(status: TripStatus.inProgress));
    }
    return queued;
  }

  Future<SyncQueueItem> completeSelectedTrip() async {
    final trip = selectedTrip.value;
    if (trip == null) throw StateError('Select a transport trip first.');
    if (!trip.deliveryConfirmed) {
      throw StateError('Record delivery confirmation before completion.');
    }
    final queued = await queue(
      'Complete transport trip',
      'transport-complete',
      {'tripId': trip.id},
    );
    if (queued.status == SyncStatus.synced) {
      _replaceTrip(trip.copyWith(status: TripStatus.completed));
    }
    return queued;
  }

  Future<SyncQueueItem> markSelectedTripArrived() async {
    final trip = selectedTrip.value;
    if (trip == null || trip.status != TripStatus.inProgress) {
      throw StateError('Select an active transport trip first.');
    }
    final queued = await queue('Mark transport arrival', 'transport-arrival', {
      'tripId': trip.id,
    });
    if (queued.status == SyncStatus.synced) {
      _replaceTrip(trip.copyWith(arrivedAt: DateTime.now()));
    }
    return queued;
  }

  void _replaceTrip(TransporterTripView updated) {
    final index = trips.indexWhere((trip) => trip.id == updated.id);
    if (index >= 0) trips[index] = updated;
    selectedTrip.value = updated;
  }

  Future<void> loadAlerts() async {
    final tripId = selectedTrip.value?.id;
    if (tripId == null) {
      alerts.clear();
      return;
    }
    try {
      alerts.assignAll(await _repository.getAlerts(tripId));
    } on AppException catch (failure) {
      error.value = failure;
    }
  }

  Future<SyncQueueItem?> acknowledgeAlert(
    TransportAlertView alert, {
    String? note,
  }) async {
    if (alert.status != 'OPEN') return null;
    final queued = await _session.queue(
      'Acknowledge transport alert',
      recordType: 'alert-acknowledgement',
      payload: {
        'alertId': alert.id,
        if (note?.trim().isNotEmpty ?? false) 'note': note!.trim(),
      },
    );
    if (queued.status == SyncStatus.synced) {
      final index = alerts.indexWhere((item) => item.id == alert.id);
      if (index >= 0) {
        alerts[index] = alert.copyWith(status: 'ACKNOWLEDGED');
      }
    }
    return queued;
  }

  Future<SyncQueueItem> reportIncident({
    required String type,
    required String severity,
    required String description,
    DateTime? occurredAt,
  }) async {
    final tripId = selectedTrip.value?.id;
    if (tripId == null) throw StateError('Select a transport trip first.');
    return _session.queue(
      'Report transport incident',
      recordType: 'incident',
      payload: {
        'tripId': tripId,
        'type': type,
        'severity': severity,
        'description': description.trim(),
        'occurredAt': (occurredAt ?? DateTime.now()).toUtc().toIso8601String(),
      },
    );
  }

  void startMonitoring() {
    if (Get.isRegistered<LiveMonitoringController>()) {
      final tripId = selectedTrip.value?.id;
      if (tripId != null) {
        Get.find<LiveMonitoringController>().start(tripId);
        return;
      }
    }
    _session.startSensorStream();
  }

  void stopMonitoring() {
    if (Get.isRegistered<LiveMonitoringController>()) {
      Get.find<LiveMonitoringController>().stop();
    }
    _session.stopSensorStream();
  }

  AppController get session => _session;

  @override
  void onClose() {
    stopMonitoring();
    super.onClose();
  }
}
