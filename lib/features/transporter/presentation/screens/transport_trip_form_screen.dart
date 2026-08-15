import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

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
  final _originLatitude = TextEditingController();
  final _originLongitude = TextEditingController();
  final _destinationLatitude = TextEditingController();
  final _destinationLongitude = TextEditingController();
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
      _setCoordinate(_originLatitude, editing.originLatitude);
      _setCoordinate(_originLongitude, editing.originLongitude);
      _setCoordinate(_destinationLatitude, editing.destinationLatitude);
      _setCoordinate(_destinationLongitude, editing.destinationLongitude);
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
    _originLatitude.dispose();
    _originLongitude.dispose();
    _destinationLatitude.dispose();
    _destinationLongitude.dispose();
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
        originLatitude: _coordinate(_originLatitude),
        originLongitude: _coordinate(_originLongitude),
        destinationLatitude: _coordinate(_destinationLatitude),
        destinationLongitude: _coordinate(_destinationLongitude),
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

  LatLng? get _originPosition => _position(_originLatitude, _originLongitude);

  LatLng? get _destinationPosition =>
      _position(_destinationLatitude, _destinationLongitude);

  Future<void> _pickLocation({required bool origin}) async {
    final selected = await showDialog<LatLng>(
      context: context,
      builder: (context) => _RouteLocationPicker(
        title: origin ? 'Select origin' : 'Select destination',
        initialPosition: origin
            ? _originPosition ?? _destinationPosition
            : _destinationPosition ?? _originPosition,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _setCoordinate(
        origin ? _originLatitude : _destinationLatitude,
        selected.latitude,
      );
      _setCoordinate(
        origin ? _originLongitude : _destinationLongitude,
        selected.longitude,
      );
    });
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
            Text(
              'Route locations (optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _LocationSelectionCard(
              label: 'Origin location',
              position: _originPosition,
              icon: Icons.trip_origin,
              onSelect: () => _pickLocation(origin: true),
              onClear: _originPosition == null
                  ? null
                  : () => setState(() {
                      _originLatitude.clear();
                      _originLongitude.clear();
                    }),
            ),
            const SizedBox(height: 12),
            _LocationSelectionCard(
              label: 'Destination location',
              position: _destinationPosition,
              icon: Icons.location_on_outlined,
              onSelect: () => _pickLocation(origin: false),
              onClear: _destinationPosition == null
                  ? null
                  : () => setState(() {
                      _destinationLatitude.clear();
                      _destinationLongitude.clear();
                    }),
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

  static void _setCoordinate(TextEditingController controller, double? value) {
    if (value != null) controller.text = value.toStringAsFixed(6);
  }

  static double? _coordinate(TextEditingController controller) =>
      double.tryParse(controller.text.trim());

  static LatLng? _position(
    TextEditingController latitude,
    TextEditingController longitude,
  ) {
    final lat = _coordinate(latitude);
    final lng = _coordinate(longitude);
    return lat == null || lng == null ? null : LatLng(lat, lng);
  }
}

class _LocationSelectionCard extends StatelessWidget {
  const _LocationSelectionCard({
    required this.label,
    required this.position,
    required this.icon,
    required this.onSelect,
    required this.onClear,
  });

  final String label;
  final LatLng? position;
  final IconData icon;
  final VoidCallback onSelect;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        position == null
            ? 'Tap to select on the map'
            : '${position!.latitude.toStringAsFixed(6)}, '
                  '${position!.longitude.toStringAsFixed(6)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onClear != null)
            IconButton(
              tooltip: 'Clear location',
              onPressed: onClear,
              icon: const Icon(Icons.close),
            ),
          const Icon(Icons.map_outlined),
        ],
      ),
      onTap: onSelect,
    ),
  );
}

class _RouteLocationPicker extends StatefulWidget {
  const _RouteLocationPicker({required this.title, this.initialPosition});

  final String title;
  final LatLng? initialPosition;

  @override
  State<_RouteLocationPicker> createState() => _RouteLocationPickerState();
}

class _RouteLocationPickerState extends State<_RouteLocationPicker> {
  static const _sriLankaCenter = LatLng(7.8731, 80.7718);
  final _mapController = MapController();
  LatLng? _selected;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPosition;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Turn on location services and try again.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Location permission is required.');
      }
      final current = await Geolocator.getCurrentPosition();
      final position = LatLng(current.latitude, current.longitude);
      if (!mounted) return;
      setState(() => _selected = position);
      _mapController.move(position, 15);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: const CloseButton(),
        actions: [
          TextButton(
            onPressed: _selected == null
                ? null
                : () => Navigator.of(context).pop(_selected),
            child: const Text('USE LOCATION'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialPosition ?? _sriLankaCenter,
              initialZoom: widget.initialPosition == null ? 7 : 14,
              onTap: (_, point) => setState(() => _selected = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fishtrace.app',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_pin,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _selected == null
                      ? 'Tap the map to place the marker.'
                      : 'Tap elsewhere to adjust the marker.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _locating ? null : _useCurrentLocation,
        icon: _locating
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
        label: Text(_locating ? 'Locating…' : 'My location'),
      ),
    ),
  );
}
