import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/data/repositories.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/models/models.dart';
import '../../domain/repositories/sensor_repositories.dart';

class LiveMonitoringController extends GetxController {
  LiveMonitoringController({
    required LiveSensorRepository liveSensorRepository,
    required SensorRepository sensorRepository,
    required AppController session,
  }) : _live = liveSensorRepository,
       _history = sensorRepository,
       _session = session;

  final LiveSensorRepository _live;
  final SensorRepository _history;
  final AppController _session;

  final latestReading = Rxn<SensorReading>();
  final chartReadings = <SensorReading>[].obs;
  final isConnected = false.obs;
  final isLoading = false.obs;
  final isStale = false.obs;
  final error = Rxn<AppException>();

  StreamSubscription<SensorReading>? _subscription;
  Timer? _staleTimer;
  String? _tripId;

  Future<void> start(String tripId) async {
    _tripId = tripId;
    isLoading.value = true;
    error.value = null;
    await _subscription?.cancel();
    try {
      final history = await _history.history(tripId);
      chartReadings.assignAll(
        history.length > 100 ? history.sublist(history.length - 100) : history,
      );
      latestReading.value = history.firstOrNull;
      _updateStale();
    } catch (_) {
      // Live monitoring can still start when history is temporarily unavailable.
    }
    _subscription = _live
        .watchTrip(tripId)
        .listen(_handleReading, onError: _handleError);
    _staleTimer?.cancel();
    _staleTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _updateStale(),
    );
    isLoading.value = false;
  }

  void _handleReading(SensorReading reading) {
    latestReading.value = reading;
    isConnected.value = true;
    error.value = null;
    chartReadings.add(reading);
    if (chartReadings.length > 100) chartReadings.removeAt(0);
    _session.sensor.value = reading;
    _session.sensorHistory.assignAll(chartReadings.takeLast(30));
    _updateStale();
  }

  Future<void> _handleError(Object failure) async {
    isConnected.value = false;
    final liveError = failure is AppException
        ? failure
        : ApiException('Live sensor connection was interrupted.');
    error.value = liveError;
    final tripId = _tripId;
    if (tripId == null) return;
    try {
      final fallback = await _history.latest(tripId);
      if (fallback != null) _handleReading(fallback);
      // A REST fallback supplies recent data but does not restore the Firebase
      // listener, so the connection and error state must remain truthful.
      isConnected.value = false;
      error.value = liveError;
    } catch (_) {
      // The observable error remains available to the existing error UI.
    }
  }

  void _updateStale() {
    final recordedAt = latestReading.value?.recordedAt;
    isStale.value =
        recordedAt == null ||
        DateTime.now().toUtc().difference(recordedAt.toUtc()) >
            const Duration(minutes: 2);
  }

  Future<void> stop() async {
    _staleTimer?.cancel();
    _staleTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _live.dispose();
    isConnected.value = false;
  }

  @override
  void onClose() {
    unawaited(stop());
    super.onClose();
  }
}

extension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final values = toList(growable: false);
    return values.skip(values.length > count ? values.length - count : 0);
  }
}
