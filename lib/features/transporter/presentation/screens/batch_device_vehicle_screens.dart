import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/transporter_entities.dart';
import '../controllers/transporter_controller.dart';

class TransportScanBatchScreen extends StatefulWidget {
  const TransportScanBatchScreen({super.key});

  @override
  State<TransportScanBatchScreen> createState() =>
      _TransportScanBatchScreenState();
}

class _TransportScanBatchScreenState extends State<TransportScanBatchScreen> {
  final _manual = TextEditingController();
  HandoverBatch? _batch;

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  bool get _valid => _batch != null;

  Future<void> _validate(String raw) async {
    final code = raw.trim();
    final controller = Get.find<TransporterController>();
    final batch = await controller.resolveHandoverBatch(code);
    if (!mounted) return;
    if (batch == null) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid batch'),
          content: const Text(
            'This batch is not available for transport assignment.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => _batch = batch);
  }

  Future<void> _scan() async {
    final scanner = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    var handled = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: FishTraceColors.navy,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan / Add Batch',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: scanner.toggleTorch,
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QRScannerFrame(
                    child: MobileScanner(
                      controller: scanner,
                      errorBuilder: (_, error, __) => Center(
                        child: Text(
                          error.errorDetails?.message ??
                              'Camera permission is required.',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      onDetect: (capture) {
                        if (handled) return;
                        final value = capture.barcodes.firstOrNull?.rawValue;
                        if (value == null) return;
                        handled = true;
                        Navigator.pop(dialogContext);
                        _validate(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await scanner.dispose();
  }

  Future<void> _add() async {
    if (!_valid) return;
    final controller = Get.find<TransporterController>();
    final trip = controller.selectedTrip.value;
    if (trip == null) {
      FishTraceFeedback.warning(context, 'Select a transport trip first');
      return;
    }
    if (trip.status != TripStatus.upcoming) {
      FishTraceFeedback.warning(
        context,
        'Batches can only be added before departure.',
      );
      return;
    }
    final queued = await controller.queue(
      'Add batch to transport trip',
      'trip-batch',
      {'tripId': trip.id, 'batchId': _batch!.id},
    );
    if (!mounted) return;
    if (queued.status != SyncStatus.synced) {
      FishTraceFeedback.show(
        context,
        queued.status == SyncStatus.failed
            ? queued.lastError ?? 'The batch could not be added.'
            : 'Batch assignment is queued. Continue after it syncs.',
        tone: queued.status == SyncStatus.failed
            ? FishTraceFeedbackTone.error
            : FishTraceFeedbackTone.warning,
      );
      return;
    }
    await controller.load();
    if (mounted) {
      FishTraceFeedback.success(context, 'Batch added to trip');
      context.go('/transporter/trip-details');
    }
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    appBar: const FishTraceAppBar(
      title: 'Scan / Add Batch',
      leading: BackButton(),
    ),
    bottomNavigation: const RoleBottomBar(role: UserRole.transporter),
    body: Obx(() {
      final trip = Get.find<TransporterController>().selectedTrip.value;
      if (trip == null) {
        return EmptyState(
          title: 'No trip selected',
          message: 'Select an upcoming transport trip before adding a batch.',
          icon: Icons.route_outlined,
          actionLabel: 'Select Trip',
          onAction: () => context.go('/transporter/create-trip'),
        );
      }
      if (trip.status != TripStatus.upcoming) {
        return EmptyState(
          title: 'Trip cannot be changed',
          message: 'Batches can only be added before the trip departs.',
          icon: Icons.lock_outline,
          actionLabel: 'View Trips',
          onAction: () => context.go('/transporter/trips'),
        );
      }
      return ListView(
        padding: const EdgeInsets.all(FishTraceSpacing.md),
        children: [
          SizedBox(
            height: 300,
            child: QRScannerFrame(
              child: Container(
                color: FishTraceColors.navy,
                child: const Center(
                  child: Icon(
                    Icons.qr_code_2,
                    color: Colors.white24,
                    size: 130,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FishTraceSecondaryButton(
            label: 'Live Scanner',
            icon: Icons.qr_code_scanner,
            onPressed: _scan,
          ),
          const SizedBox(height: 12),
          FishTraceTextField(
            label: 'Batch code or QR value',
            controller: _manual,
            hint: 'e.g. FTB-2026-001',
            suffixIcon: IconButton(
              tooltip: 'Validate batch code',
              onPressed: () => _validate(_manual.text),
              icon: const Icon(Icons.search),
            ),
          ),
          if (_valid) ...[
            const SectionHeader(title: 'Batch Details'),
            FishTraceCard(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: StatusChip(label: 'Valid'),
                  ),
                  _DataRow(label: 'Batch code', value: _batch!.label),
                  _DataRow(label: 'Species', value: _batch!.species),
                  _DataRow(
                    label: 'Weight',
                    value: '${_batch!.weightKg.toStringAsFixed(1)} kg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FishTracePrimaryButton(
              label: 'Accept Handover & Add to Trip',
              onPressed: _add,
            ),
          ],
        ],
      );
    }),
  );
}

class DeviceAssignmentScreen extends StatelessWidget {
  const DeviceAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransporterController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(
        title: 'Assign IoT Device',
        leading: BackButton(),
      ),
      bottomNavigation: const RoleBottomBar(role: UserRole.transporter),
      body: Obx(() {
        final trip = controller.selectedTrip.value;
        if (trip == null || trip.status != TripStatus.upcoming) {
          return EmptyState(
            title: 'No editable trip selected',
            message: 'A device can only be assigned before departure.',
            icon: Icons.sensors_off_outlined,
            actionLabel: 'Select Trip',
            onAction: () => context.go('/transporter/trips'),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: FishTraceSearchField(
                hint: 'Search device name or code',
                onChanged: (value) => controller.search.value = value,
                onFilter: () => _filter(context, controller),
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredDevices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final device = controller.filteredDevices[index];
                    final selected =
                        controller.selectedDevice.value?.id == device.id;
                    return DeviceCard(
                      onTap: () {
                        final error = controller.selectDevice(device);
                        if (error != null) {
                          FishTraceFeedback.warning(context, error);
                        }
                      },
                      deviceName: device.label,
                      deviceCode: device.deviceCode == device.label
                          ? null
                          : device.deviceCode,
                      deviceType:
                          '${device.capabilities.join(' & ')} • '
                          'Signal ${device.signal.toInt()}%',
                      status: device.status.name,
                      battery: device.battery.toInt(),
                      selected: selected,
                    );
                  },
                ),
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    if (trip.assignedDeviceId != null) ...[
                      Expanded(
                        child: FishTraceSecondaryButton(
                          label: 'Remove',
                          onPressed: () async {
                            final result = await controller
                                .removeAssignedDevice();
                            if (result.status == SyncStatus.synced) {
                              await controller.load();
                            }
                            if (context.mounted) {
                              context.go('/transporter/trip-details');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: FishTracePrimaryButton(
                        label: trip.assignedDeviceId == null
                            ? 'Assign Device'
                            : 'Replace Device',
                        onPressed: controller.selectedDevice.value == null
                            ? null
                            : () async {
                                final queued = await controller.queue(
                                  'Assign IoT device',
                                  'device-assignment',
                                  {
                                    'tripId': controller.selectedTrip.value?.id,
                                    'deviceId':
                                        controller.selectedDevice.value?.id,
                                  },
                                );
                                if (!context.mounted) return;
                                if (queued.status != SyncStatus.synced) {
                                  FishTraceFeedback.show(
                                    context,
                                    queued.status == SyncStatus.failed
                                        ? queued.lastError ??
                                              'The device could not be assigned.'
                                        : 'Device assignment is queued. Continue after it syncs.',
                                    tone: queued.status == SyncStatus.failed
                                        ? FishTraceFeedbackTone.error
                                        : FishTraceFeedbackTone.warning,
                                  );
                                  return;
                                }
                                final tripId =
                                    controller.selectedTrip.value?.id;
                                final deviceId =
                                    controller.selectedDevice.value?.id;
                                await controller.load(
                                  selectCreatedOrUpdatedId: tripId,
                                );
                                if (!context.mounted) return;
                                final refreshedTrip =
                                    controller.selectedTrip.value;
                                final assignmentReady =
                                    refreshedTrip?.assignedDeviceId ==
                                        deviceId &&
                                    refreshedTrip!.deviceAssignmentSynced;
                                if (assignmentReady) {
                                  context.go('/transporter/checklist');
                                  return;
                                }
                                FishTraceFeedback.warning(
                                  context,
                                  'The device was assigned, but Firebase synchronization did not complete. Check the device provisioning or Firebase connection and try again.',
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _filter(
    BuildContext context,
    TransporterController controller,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final filter in DeviceFilter.values)
            RadioListTile<DeviceFilter>(
              value: filter,
              groupValue: controller.deviceFilter.value,
              title: Text(
                filter.name[0].toUpperCase() + filter.name.substring(1),
              ),
              onChanged: (value) {
                if (value != null) controller.deviceFilter.value = value;
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );
}

class VehicleManagementScreen extends StatelessWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransporterController>();
    return FishTraceScaffold(
      appBar: FishTraceAppBar(
        title: 'Vehicle Management',
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: 'Add vehicle',
            onPressed: () => _editVehicle(context, controller),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      bottomNavigation: const RoleBottomBar(role: UserRole.transporter),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            FishTraceSearchField(
              hint: 'Search vehicles',
              onChanged: (value) => controller.search.value = value,
            ),
            const SizedBox(height: 12),
            for (final vehicle in controller.vehicles)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: VehicleCard(
                  onTap: () {
                    controller.selectedVehicle.value = vehicle;
                    _showVehicleDetails(context, controller, vehicle);
                  },
                  registration: vehicle.registration,
                  vehicleType:
                      '${vehicle.type} • ${vehicle.capacityTonnes} T • '
                      '${vehicle.driver}',
                  status: vehicle.active ? 'Active' : 'Inactive',
                  temperature:
                      '${vehicle.minTemperature.toInt()}°C to '
                      '${vehicle.maxTemperature.toInt()}°C',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showVehicleDetails(
    BuildContext context,
    TransporterController controller,
    TransportVehicleView vehicle,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_shipping,
            color: FishTraceColors.primary,
            size: 62,
          ),
          Text(
            vehicle.registration,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          FishTraceCard(
            child: Column(
              children: [
                _DataRow(label: 'Vehicle Type', value: vehicle.type),
                _DataRow(
                  label: 'Capacity',
                  value: '${vehicle.capacityTonnes} Ton',
                ),
                _DataRow(label: 'Reefer Unit', value: vehicle.reeferUnit),
                _DataRow(
                  label: 'Temperature Range',
                  value:
                      '${vehicle.minTemperature.toInt()}°C to '
                      '${vehicle.maxTemperature.toInt()}°C',
                ),
                _DataRow(label: 'Driver', value: vehicle.driver),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FishTracePrimaryButton(
            label: 'Edit Vehicle',
            onPressed: () {
              Navigator.pop(sheetContext);
              _editVehicle(context, controller, vehicle);
            },
          ),
        ],
      ),
    ),
  );

  Future<void> _editVehicle(
    BuildContext context,
    TransporterController controller, [
    TransportVehicleView? vehicle,
  ]) async {
    final registration = TextEditingController(text: vehicle?.registration);
    final capacity = TextEditingController(
      text: vehicle?.capacityTonnes.toString(),
    );
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FishTraceTextField(
                label: 'Registration Number',
                controller: registration,
                required: true,
                validator: (value) => (value?.trim().length ?? 0) < 5
                    ? 'Enter a valid registration'
                    : null,
              ),
              const SizedBox(height: 12),
              FishTraceTextField(
                label: 'Capacity (tonnes)',
                controller: capacity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                required: true,
                validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                    ? 'Enter capacity'
                    : null,
              ),
              const SizedBox(height: 16),
              FishTracePrimaryButton(
                label: vehicle == null ? 'Add Vehicle' : 'Save Vehicle',
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final queued = await controller
                      .queue('Save vehicle', 'vehicle', {
                        'id': vehicle?.id,
                        'registration': registration.text,
                        'name': registration.text,
                        'capacityTonnes': double.parse(capacity.text),
                      });
                  if (!sheetContext.mounted) return;
                  if (queued.status != SyncStatus.synced) {
                    FishTraceFeedback.show(
                      sheetContext,
                      queued.status == SyncStatus.failed
                          ? queued.lastError ?? 'Vehicle could not be saved.'
                          : 'Vehicle change is queued and not applied yet.',
                      tone: queued.status == SyncStatus.failed
                          ? FishTraceFeedbackTone.error
                          : FishTraceFeedbackTone.warning,
                    );
                    return;
                  }
                  await controller.load();
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
    registration.dispose();
    capacity.dispose();
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    ),
  );
}
