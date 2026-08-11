import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/transporter_entities.dart';
import '../controllers/transporter_controller.dart';

class TransportTripFormScreen extends StatefulWidget {
  const TransportTripFormScreen({super.key, this.editing = false});
  final bool editing;

  @override
  State<TransportTripFormScreen> createState() =>
      _TransportTripFormScreenState();
}

class _TransportTripFormScreenState extends State<TransportTripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driver = TextEditingController();
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  final _distance = TextEditingController();
  TransportVehicleView? _vehicle;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<TransporterController>();
    final editing = widget.editing ? controller.editableSelectedTrip : null;
    _vehicle = editing == null
        ? controller.vehicles.where((item) => item.active).firstOrNull
        : controller.vehicles.firstWhereOrNull(
            (item) => item.id == editing.vehicleId,
          );
    if (editing != null) {
      _driver.text = editing.driver;
      _origin.text = editing.origin;
      _destination.text = editing.destination;
      _distance.text = editing.distanceKm.toStringAsFixed(1);
    } else if (_vehicle != null) {
      _driver.text = _vehicle!.driver;
    }
  }

  @override
  void dispose() {
    _driver.dispose();
    _origin.dispose();
    _destination.dispose();
    _distance.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _vehicle == null) return;
    setState(() => _saving = true);
    try {
      final controller = Get.find<TransporterController>();
      final result = await controller.saveTrip(
        editing: widget.editing,
        vehicleId: _vehicle!.id,
        driver: _driver.text.trim(),
        origin: _origin.text.trim(),
        destination: _destination.text.trim(),
        distanceKm: double.tryParse(_distance.text.trim()),
      );
      if (!mounted) return;
      if (result.status != SyncStatus.synced) {
        throw StateError(
          result.lastError ?? 'The transport trip could not be synchronized.',
        );
      }
      await controller.load(selectCreatedOrUpdatedId: result.serverId);
      if (mounted) context.go('/transporter/trip-details');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing;
    return FishTraceScaffold(
      appBar: FishTraceAppBar(
        title: editing ? 'Edit Transport Trip' : 'Create Transport Trip',
        leading: const BackButton(),
      ),
      bottomNavigation: const RoleBottomBar(role: UserRole.transporter),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<TransportVehicleView>(
              value: _vehicle,
              decoration: const InputDecoration(labelText: 'Vehicle'),
              items: Get.find<TransporterController>().vehicles
                  .where((item) => item.active)
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.registration),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                _vehicle = value;
                if (_driver.text.trim().isEmpty && value != null) {
                  _driver.text = value.driver;
                }
              }),
              validator: (value) => value == null ? 'Select a vehicle' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _driver,
              decoration: const InputDecoration(labelText: 'Driver name'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _origin,
              decoration: const InputDecoration(labelText: 'Origin'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destination,
              decoration: const InputDecoration(labelText: 'Destination'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _distance,
              decoration: const InputDecoration(
                labelText: 'Estimated distance (km)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return null;
                final parsed = double.tryParse(value!.trim());
                return parsed == null || parsed <= 0
                    ? 'Enter a valid distance'
                    : null;
              },
            ),
            const SizedBox(height: 24),
            FishTracePrimaryButton(
              label: editing ? 'Save Changes' : 'Create Trip',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value?.trim().isEmpty ?? true ? 'This field is required' : null;
}
