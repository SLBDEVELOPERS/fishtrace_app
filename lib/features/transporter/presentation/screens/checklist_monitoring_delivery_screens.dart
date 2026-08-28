import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/transporter_entities.dart';
import '../controllers/live_monitoring_controller.dart';
import '../controllers/transporter_controller.dart';

class PreTripChecklistScreen extends StatelessWidget {
  const PreTripChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransporterController>();
    const sections = {
      'Vehicle & Equipment': [
        'Vehicle safety inspection',
        'Refrigeration system',
        'IoT device online',
      ],
      'Cargo': ['Cargo and batch seals', 'Cargo doors sealed'],
    };
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(
        title: 'Pre-Trip Checklist',
        leading: BackButton(),
      ),
      bottomNavigation: const RoleBottomBar(role: UserRole.transporter),
      body: Obx(() {
        final trip = controller.selectedTrip.value;
        if (trip == null) {
          return EmptyState(
            title: 'No trip selected',
            message: 'Select an upcoming trip before completing a checklist.',
            icon: Icons.route_outlined,
            actionLabel: 'Select Trip',
            onAction: () => context.go('/transporter/trips'),
          );
        }
        if (trip.status != TripStatus.upcoming) {
          return EmptyState(
            title: 'Checklist unavailable',
            message:
                'The pre-trip checklist is only available before departure.',
            icon: Icons.lock_outline,
            actionLabel: 'View Trip',
            onAction: () => context.go('/transporter/trip-details'),
          );
        }
        final completed = controller.checklist.length;
        final total = TransporterController.mandatoryChecklist.length;
        final checklistComplete = controller.validateChecklist() == null;
        final checklistSaved = trip.completedChecklistItems.containsAll(
          TransporterController.mandatoryChecklist,
        );
        final hasAssignedDevice = trip.assignedDeviceId != null;
        final assignedDeviceOnline = controller.devices.any(
          (device) =>
              device.id == trip.assignedDeviceId &&
              device.status != DeviceStatus.offline,
        );
        final deviceReady = trip.deviceAssignmentSynced && assignedDeviceOnline;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ensure everything is ready before departure',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completed of $total Completed',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: completed / total,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                children: [
                  for (final section in sections.entries) ...[
                    SectionHeader(title: section.key),
                    FishTraceCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (final item in section.value)
                            CheckboxListTile(
                              value: controller.checklist.contains(item),
                              title: Text(
                                item,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              subtitle: Text(_checklistDescription(item)),
                              secondary: Icon(
                                _checklistIcon(item),
                                color: FishTraceColors.primary,
                                size: 20,
                              ),
                              onChanged: (selected) {
                                if (selected ?? false) {
                                  controller.checklist.add(item);
                                } else {
                                  controller.checklist.remove(item);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: FishTracePrimaryButton(
                label: checklistComplete && checklistSaved
                    ? deviceReady
                          ? 'Start Trip'
                          : !hasAssignedDevice
                          ? 'Assign IoT Device'
                          : !assignedDeviceOnline
                          ? 'Replace Offline Device'
                          : 'Device Sync Required'
                    : 'Complete Checklist',
                onPressed: () async {
                  final error = controller.validateChecklist();
                  if (error != null) {
                    FishTraceFeedback.warning(context, error);
                    return;
                  }
                  final trip = controller.selectedTrip.value;
                  if (trip == null) {
                    FishTraceFeedback.warning(
                      context,
                      'Select a transport trip first',
                    );
                    return;
                  }
                  try {
                    if (checklistSaved && !deviceReady) {
                      context.go('/transporter/devices');
                      return;
                    }
                    if (checklistSaved) {
                      final started = await controller.startSelectedTrip();
                      if (started.status != SyncStatus.synced) {
                        throw StateError(
                          started.status == SyncStatus.failed
                              ? started.lastError ??
                                    'Trip could not be started.'
                              : 'Trip start is queued. Continue after it syncs.',
                        );
                      }
                      if (context.mounted) {
                        context.go('/transporter/monitoring');
                      }
                      return;
                    }
                    final checklistUpdate = await controller.queue(
                      'Pre-trip checklist',
                      'checklist',
                      {
                        'tripId': trip.id,
                        'completed': controller.checklist.toList(),
                      },
                    );
                    if (checklistUpdate.status != SyncStatus.synced) {
                      throw StateError(
                        checklistUpdate.status == SyncStatus.failed
                            ? checklistUpdate.lastError ??
                                  'Checklist could not be saved.'
                            : 'Checklist is queued. Start the trip after it syncs.',
                      );
                    }
                    await controller.load();
                    if (context.mounted) {
                      final refreshedTrip = controller.selectedTrip.value;
                      final nextStep = refreshedTrip?.assignedDeviceId == null
                          ? 'Assign an IoT device before starting the trip.'
                          : 'You can now start the trip.';
                      FishTraceFeedback.success(
                        context,
                        'Checklist completed. $nextStep',
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      FishTraceFeedback.error(
                        context,
                        error.toString().replaceFirst('Bad state: ', ''),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  static String _checklistDescription(String item) => switch (item) {
    'Vehicle safety inspection' => 'Vehicle is safe and ready to depart',
    'Refrigeration system' => 'Refrigeration is operating correctly',
    'Cargo and batch seals' => 'Cargo is secured and seals are intact',
    'IoT device online' => 'Assigned device is powered and reporting',
    _ => 'Cargo doors are closed and sealed',
  };

  static IconData _checklistIcon(String item) => switch (item) {
    'Vehicle safety inspection' => Icons.local_shipping_outlined,
    'Refrigeration system' => Icons.ac_unit,
    'Cargo and batch seals' => Icons.inventory_2_outlined,
    'IoT device online' => Icons.sensors,
    _ => Icons.lock_outline,
  };
}

class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  late final TransporterController _controller;
  late final LiveMonitoringController _liveController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TransporterController>();
    _liveController = Get.find<LiveMonitoringController>();
    if (_controller.selectedTrip.value?.status == TripStatus.inProgress) {
      _controller.startMonitoring();
    }
  }

  @override
  void dispose() {
    _controller.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final trip = _controller.selectedTrip.value;
    if (trip == null || trip.status != TripStatus.inProgress) {
      return FishTraceScaffold(
        appBar: const FishTraceAppBar(
          title: 'Live Monitoring',
          leading: BackButton(),
        ),
        bottomNavigation: const RoleBottomBar(role: UserRole.transporter),
        body: EmptyState(
          title: 'No active trip',
          message: 'Live monitoring is available only after a trip departs.',
          icon: Icons.sensors_off_outlined,
          actionLabel: 'View Trips',
          onAction: () => context.go('/transporter/trips'),
        ),
      );
    }
    return DefaultTabController(
      length: 3,
      child: FishTraceScaffold(
        appBar: const FishTraceAppBar(
          title: 'Live Monitoring',
          leading: BackButton(),
        ),
        bottomNavigation: const RoleBottomBar(role: UserRole.transporter),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Route'),
                  Tab(text: 'Alerts'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MonitoringOverview(controller: _liveController),
                  _MonitoringRoute(
                    liveController: _liveController,
                    tripController: _controller,
                  ),
                  _MonitoringAlerts(controller: _controller),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FishTracePrimaryButton(
                label: trip.arrivedAt == null
                    ? 'Mark Arrived'
                    : trip.deliveryConfirmed
                    ? 'Complete Trip'
                    : 'Confirm Delivery',
                icon: trip.arrivedAt == null
                    ? Icons.location_on_outlined
                    : Icons.assignment_turned_in_outlined,
                onPressed: trip.arrivedAt == null
                    ? () async {
                        final result = await _controller
                            .markSelectedTripArrived();
                        if (result.status == SyncStatus.synced) {
                          await _controller.load();
                        }
                      }
                    : trip.deliveryConfirmed
                    ? () async {
                        final result = await _controller.completeSelectedTrip();
                        if (result.status == SyncStatus.synced) {
                          await _controller.load();
                          if (context.mounted) context.go('/transporter');
                        }
                      }
                    : () => context.go('/transporter/delivery'),
              ),
            ),
          ],
        ),
      ),
    );
  });
}

class _MonitoringOverview extends StatelessWidget {
  const _MonitoringOverview({required this.controller});
  final LiveMonitoringController controller;
  @override
  Widget build(BuildContext context) => Obx(() {
    final reading = controller.latestReading.value;
    final history = controller.chartReadings;
    final productTemperature = reading?.productTemp;
    final airTemperature = reading?.airTemp;
    final humidity = reading?.humidity;
    final battery = reading?.battery;
    final productStatus = _productTemperatureStatus(
      reading?.temperatureStatus,
      productTemperature,
    );
    final hasGps = reading?.latitude != null && reading?.longitude != null;
    return ListView(
      padding: const EdgeInsets.all(FishTraceSpacing.md),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                reading?.recordedAt == null
                    ? 'No telemetry timestamp'
                    : 'Updated ${_timeAgo(reading!.recordedAt!)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: FishTraceSpacing.sm),
            Text(
              controller.isConnected.value
                  ? '● Live'
                  : controller.isStale.value
                  ? '● Stale'
                  : '● Offline',
              style: TextStyle(
                color: controller.isConnected.value
                    ? FishTraceColors.success
                    : FishTraceColors.warning,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.05,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            SensorMetricCard(
              label: 'Product Temperature',
              value: _decimal(productTemperature, '°C'),
              icon: Icons.thermostat,
              status: productStatus,
              color: _productTemperatureColor(productStatus),
            ),
            SensorMetricCard(
              label: 'Air Temperature',
              value: _decimal(airTemperature, '°C'),
              icon: Icons.air,
            ),
            SensorMetricCard(
              label: 'Humidity',
              value: _whole(humidity, '%'),
              icon: Icons.water_drop_outlined,
            ),
            SensorMetricCard(
              label: 'Battery',
              value: _whole(battery, '%'),
              icon: Icons.battery_5_bar,
              color: battery != null && battery < 20
                  ? FishTraceColors.error
                  : FishTraceColors.success,
            ),
          ],
        ),
        const SizedBox(height: 8),
        FishTraceCard(
          child: Row(
            children: [
              Expanded(
                child: _StatusMetric(
                  icon: reading?.doorOpen ?? false
                      ? Icons.lock_open
                      : Icons.lock_outline,
                  label: 'Door Status',
                  value: reading == null
                      ? 'Unavailable'
                      : reading.doorOpen
                      ? 'Open'
                      : 'Closed',
                  color: reading?.doorOpen ?? false
                      ? FishTraceColors.error
                      : FishTraceColors.info,
                ),
              ),
              Expanded(
                child: _StatusMetric(
                  icon: Icons.network_cell,
                  label: 'GPS Signal',
                  value: hasGps ? 'Available' : 'Not reported',
                  color: hasGps
                      ? FishTraceColors.success
                      : FishTraceColors.info,
                ),
              ),
              Expanded(
                child: _StatusMetric(
                  icon: Icons.sensors,
                  label: 'Device',
                  value: controller.isConnected.value ? 'Connected' : 'Offline',
                  color: controller.isConnected.value
                      ? FishTraceColors.success
                      : FishTraceColors.warning,
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Temperature History'),
        ChartCard(
          title: 'Product temperature',
          values: history
              .map((item) => item.productTemp)
              .whereType<double>()
              .toList(growable: false),
          unit: '°C',
          height: 140,
        ),
        if (controller.error.value != null) ...[
          const SizedBox(height: 10),
          AlertCard(
            title: 'Live connection interrupted',
            message: controller.error.value!.message,
            severity: AlertCardSeverity.warning,
          ),
        ],
      ],
    );
  });

  static String _decimal(double? value, String unit) =>
      value == null ? 'Not reported' : '${value.toStringAsFixed(1)}$unit';

  static String _whole(double? value, String unit) =>
      value == null ? 'Not reported' : '${value.toStringAsFixed(0)}$unit';

  static String _productTemperatureStatus(
    String? reportedStatus,
    double? temperature,
  ) {
    final normalized = reportedStatus?.trim().toUpperCase();
    if (normalized != null &&
        const {
          'SAFE',
          'WARNING',
          'CRITICAL',
          'TOO_COLD',
          'UNKNOWN',
        }.contains(normalized)) {
      return normalized;
    }
    if (temperature == null) return 'UNKNOWN';
    if (temperature < 0) return 'TOO_COLD';
    if (temperature <= 4) return 'SAFE';
    if (temperature <= 8) return 'WARNING';
    return 'CRITICAL';
  }

  static Color _productTemperatureColor(String status) => switch (status) {
    'SAFE' => FishTraceColors.success,
    'WARNING' => FishTraceColors.warning,
    'CRITICAL' || 'TOO_COLD' => FishTraceColors.error,
    _ => FishTraceColors.info,
  };

  static String _timeAgo(DateTime value) {
    final age = DateTime.now().toUtc().difference(value.toUtc());
    if (age.inMinutes < 1) return 'just now';
    if (age.inHours < 1) return '${age.inMinutes}m ago';
    return '${age.inHours}h ago';
  }
}

class _MonitoringRoute extends StatelessWidget {
  const _MonitoringRoute({
    required this.liveController,
    required this.tripController,
  });

  final LiveMonitoringController liveController;
  final TransporterController tripController;

  @override
  Widget build(BuildContext context) => Obx(() {
    final reading = liveController.latestReading.value;
    final trip = tripController.selectedTrip.value;
    final hasGps = reading?.latitude != null && reading?.longitude != null;
    final route = liveController.chartReadings
        .where((item) => item.latitude != null && item.longitude != null)
        .map((item) => LatLng(item.latitude!, item.longitude!))
        .toList(growable: false);
    final origin = trip?.originLatitude != null && trip?.originLongitude != null
        ? LatLng(trip!.originLatitude!, trip.originLongitude!)
        : route.firstOrNull;
    final destination =
        trip?.destinationLatitude != null && trip?.destinationLongitude != null
        ? LatLng(trip!.destinationLatitude!, trip.destinationLongitude!)
        : null;
    return ListView(
      padding: const EdgeInsets.all(FishTraceSpacing.md),
      children: [
        if (hasGps)
          MapPreviewCard(
            center: LatLng(reading!.latitude!, reading.longitude!),
            route: route,
            height: 360,
            interactive: true,
            markerIcon: Icons.local_shipping,
            start: origin,
            destination: destination,
            caption: route.length > 1
                ? 'Live vehicle position · ${route.length} recorded locations'
                : 'Live vehicle position · waiting for route history',
          )
        else
          const EmptyState(
            title: 'Location not reported',
            message: 'The assigned sensor has not sent a GPS position yet.',
            icon: Icons.location_off_outlined,
          ),
        const SizedBox(height: 10),
        FishTraceCard(
          child: Row(
            children: [
              Expanded(
                child: _RouteMetric(
                  label: 'ETA',
                  value: trip == null ? 'Not scheduled' : _formatTime(trip.eta),
                ),
              ),
              Expanded(
                child: _RouteMetric(
                  label: 'Planned distance',
                  value: trip == null
                      ? 'Not reported'
                      : '${trip.distanceKm.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  });

  static String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
  }
}

class _MonitoringAlerts extends StatelessWidget {
  const _MonitoringAlerts({required this.controller});
  final TransporterController controller;
  @override
  Widget build(BuildContext context) => Obx(
    () => ListView(
      padding: const EdgeInsets.all(FishTraceSpacing.md),
      children: [
        if (controller.alerts.isEmpty)
          const EmptyState(
            title: 'No active alerts',
            message: 'There are no transport alerts for this trip.',
            icon: Icons.verified_outlined,
          ),
        for (final alert in controller.alerts)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AlertCard(
              title: _alertTitle(alert.type),
              message: _alertMessage(alert),
              severity: switch (alert.severity) {
                AlertSeverity.critical => AlertCardSeverity.critical,
                AlertSeverity.warning => AlertCardSeverity.warning,
                _ => AlertCardSeverity.info,
              },
              trailing: alert.status == 'OPEN'
                  ? TextButton(
                      onPressed: () async {
                        final queued = await controller.acknowledgeAlert(alert);
                        if (!context.mounted || queued == null) return;
                        if (queued.status != SyncStatus.synced) {
                          FishTraceFeedback.show(
                            context,
                            queued.status == SyncStatus.failed
                                ? queued.lastError ??
                                      'Alert acknowledgement failed.'
                                : 'Acknowledgement is queued and not applied yet.',
                            tone: queued.status == SyncStatus.failed
                                ? FishTraceFeedbackTone.error
                                : FishTraceFeedbackTone.warning,
                          );
                        }
                      },
                      child: const Text('Acknowledge'),
                    )
                  : StatusChip(label: _statusLabel(alert.status)),
            ),
          ),
        const SizedBox(height: 8),
        FishTraceSecondaryButton(
          label: 'Report Incident',
          icon: Icons.report_outlined,
          onPressed: () => _showIncidentDialog(context, controller),
        ),
      ],
    ),
  );

  static String _alertTitle(String type) => type
      .toLowerCase()
      .split('_')
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  static String _alertMessage(TransportAlertView alert) {
    if (alert.measuredValue == null || alert.thresholdValue == null) {
      return 'Detected ${_timeAgo(alert.lastDetectedAt)}.';
    }
    return 'Measured ${alert.measuredValue}; threshold ${alert.thresholdValue}. '
        'Detected ${_timeAgo(alert.lastDetectedAt)}.';
  }

  static String _statusLabel(String status) => status
      .toLowerCase()
      .split('_')
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  static String _timeAgo(DateTime value) {
    final age = DateTime.now().toUtc().difference(value.toUtc());
    if (age.inMinutes < 1) return 'just now';
    if (age.inHours < 1) return '${age.inMinutes}m ago';
    return '${age.inHours}h ago';
  }

  static Future<void> _showIncidentDialog(
    BuildContext context,
    TransporterController controller,
  ) async {
    final description = TextEditingController();
    var severity = 'WARNING';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Report transport incident'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'What happened?'),
              ),
              DropdownButtonFormField<String>(
                value: severity,
                decoration: const InputDecoration(labelText: 'Severity'),
                items: const [
                  DropdownMenuItem(value: 'INFO', child: Text('Info')),
                  DropdownMenuItem(value: 'WARNING', child: Text('Warning')),
                  DropdownMenuItem(value: 'CRITICAL', child: Text('Critical')),
                ],
                onChanged: (value) =>
                    setDialogState(() => severity = value ?? severity),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (description.text.trim().isEmpty) return;
                final queued = await controller.reportIncident(
                  type: 'DRIVER_REPORTED',
                  severity: severity,
                  description: description.text,
                );
                if (queued.status != SyncStatus.synced) {
                  if (dialogContext.mounted) {
                    FishTraceFeedback.show(
                      dialogContext,
                      queued.status == SyncStatus.failed
                          ? queued.lastError ?? 'Incident report failed.'
                          : 'Incident is queued and not submitted yet.',
                      tone: queued.status == SyncStatus.failed
                          ? FishTraceFeedbackTone.error
                          : FishTraceFeedbackTone.warning,
                    );
                  }
                  return;
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    description.dispose();
  }
}

class DeliveryConfirmationScreen extends StatefulWidget {
  const DeliveryConfirmationScreen({super.key});
  @override
  State<DeliveryConfirmationScreen> createState() =>
      _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState
    extends State<DeliveryConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiver = TextEditingController();
  final _notes = TextEditingController();
  final _picker = ImagePicker();
  final _signatureKey = GlobalKey<SignaturePadState>();
  final _photos = <XFile>[];
  bool _signed = false;
  bool _saving = false;

  @override
  void dispose() {
    _receiver.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_signed) {
      FishTraceFeedback.warning(context, 'Receiver signature is required');
      return;
    }
    if (_photos.isEmpty) {
      FishTraceFeedback.warning(context, 'Add at least one delivery photo');
      return;
    }
    final controller = Get.find<TransporterController>();
    setState(() => _saving = true);
    final signature = await _signatureKey.currentState?.exportImage();
    final bytes = await signature?.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      if (mounted) {
        setState(() => _saving = false);
        FishTraceFeedback.error(context, 'Unable to save receiver signature');
      }
      return;
    }
    final directory = await getTemporaryDirectory();
    final signatureFile = File(
      '${directory.path}${Platform.pathSeparator}delivery-signature-${DateTime.now().microsecondsSinceEpoch}.png',
    );
    await signatureFile.writeAsBytes(bytes.buffer.asUint8List());
    try {
      final confirmation = await controller
          .queue('Delivery confirmation', 'delivery', {
            'tripId': controller.selectedTrip.value?.id,
            'receiver': _receiver.text.trim(),
            'batchIds':
                controller.selectedTrip.value?.batches
                    .map((item) => item.id)
                    .toList() ??
                const [],
            'signatureCaptured': true,
            'signaturePath': signatureFile.path,
            'photos': _photos.map((photo) => photo.path).toList(),
            'notes': _notes.text,
            'completedAt': DateTime.now().toIso8601String(),
          });
      if (!mounted) return;
      if (confirmation.status != SyncStatus.synced) {
        throw StateError(
          confirmation.status == SyncStatus.failed
              ? confirmation.lastError ?? 'Delivery confirmation failed.'
              : 'Delivery confirmation is queued. Complete the trip after it syncs.',
        );
      }
      await controller.load();
      final completed = await controller.completeSelectedTrip();
      if (completed.status != SyncStatus.synced) {
        throw StateError(
          completed.status == SyncStatus.failed
              ? completed.lastError ?? 'Trip completion failed.'
              : 'Trip completion is queued and not completed yet.',
        );
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: FishTraceColors.success,
            size: 48,
          ),
          title: const Text('Delivery Completed'),
          content: const Text(
            'The signed handover and trip completion are synchronized.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) context.go('/transporter');
    } catch (error) {
      if (mounted) {
        FishTraceFeedback.error(context, error.toString());
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransporterController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(
        title: 'Delivery Confirmation',
        leading: BackButton(color: Colors.white),
        teal: true,
      ),
      bottomNavigation: const RoleBottomBar(role: UserRole.transporter),
      body: Obx(() {
        final trip = controller.selectedTrip.value;
        if (trip == null ||
            trip.status != TripStatus.inProgress ||
            trip.arrivedAt == null) {
          return EmptyState(
            title: 'No active delivery trip',
            message:
                'Mark an active trip as arrived before confirming delivery.',
            icon: Icons.local_shipping_outlined,
            actionLabel: 'View Trips',
            onAction: () => context.go('/transporter/trips'),
          );
        }
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(FishTraceSpacing.md),
            children: [
              FishTraceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.label,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text('${trip.origin}  →  ${trip.destination}'),
                  ],
                ),
              ),
              const SectionHeader(title: 'Receiver Details'),
              FishTraceTextField(
                label: 'Receiver',
                controller: _receiver,
                required: true,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Receiver name is required'
                    : null,
              ),
              const SectionHeader(title: 'Batch Handover'),
              FishTraceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final batch in trip.batches)
                      ListTile(
                        dense: true,
                        title: Text(batch.label),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${batch.weightKg.toStringAsFixed(1)} kg'),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              color: FishTraceColors.success,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Proof of Delivery'),
              SignaturePad(
                key: _signatureKey,
                onChanged: (value) => setState(() => _signed = value),
              ),
              const SizedBox(height: 12),
              ImageAttachmentPicker(
                images: _photos,
                onCamera: () async {
                  final image = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 72,
                    maxWidth: 1600,
                  );
                  if (image != null && mounted) {
                    setState(() => _photos.add(image));
                  }
                },
                onGallery: () async {
                  final images = await _picker.pickMultiImage(
                    imageQuality: 72,
                    maxWidth: 1600,
                  );
                  if (mounted) setState(() => _photos.addAll(images));
                },
                onRemove: (image) => setState(() => _photos.remove(image)),
              ),
              const SizedBox(height: 12),
              FishTraceTextField(
                label: 'Notes',
                controller: _notes,
                maxLines: 3,
              ),
              const SizedBox(height: 18),
              FishTracePrimaryButton(
                label: 'Confirm Delivery',
                loading: _saving,
                onPressed: _confirm,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(value, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}

class _RouteMetric extends StatelessWidget {
  const _RouteMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(value, style: Theme.of(context).textTheme.titleSmall),
    ],
  );
}
