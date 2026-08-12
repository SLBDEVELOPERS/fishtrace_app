import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/fisher_entities.dart';
import '../controllers/fisher_controller.dart';

class StartFishingTripScreen extends StatefulWidget {
  const StartFishingTripScreen({super.key});

  @override
  State<StartFishingTripScreen> createState() => _StartFishingTripScreenState();
}

class _StartFishingTripScreenState extends State<StartFishingTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tripCode;
  final _duration = TextEditingController();
  final _notes = TextEditingController();
  final _crewInput = TextEditingController();
  late final TextEditingController _departureText;
  late final FisherController _controller;
  FisherBoat? _boat;
  DateTime _departure = DateTime.now();
  final _crew = <String>{};
  double? _latitude;
  double? _longitude;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _tripCode = TextEditingController(
      text: 'TRIP-${DateFormat('yyyyMMdd-HHmm').format(_departure)}',
    );
    _controller = Get.find<FisherController>();
    _boat = _controller.boats.where((boat) => boat.active).firstOrNull;
    _departureText = TextEditingController(
      text: DateFormat('MMM d, yyyy · hh:mm a').format(_departure),
    );
    _captureLocation();
  }

  @override
  void dispose() {
    _tripCode.dispose();
    _duration.dispose();
    _notes.dispose();
    _crewInput.dispose();
    _departureText.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard trip setup?'),
            content: const Text('Your unsaved trip information will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: FishTraceColors.error,
                ),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _pickDeparture() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDate: _departure,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departure),
    );
    if (time == null) return;
    setState(() {
      _departure = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _departureText.text = DateFormat(
        'MMM d, yyyy · hh:mm a',
      ).format(_departure);
      _dirty = true;
    });
  }

  Future<void> _startTrip() async {
    if (!_formKey.currentState!.validate() || _boat == null) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current fishing location is required')),
      );
      await _captureLocation();
      return;
    }
    if (_crew.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one crew member')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start fishing trip?'),
        content: Text(
          '${_boat!.name} will depart on '
          '${DateFormat('MMM d, yyyy · hh:mm a').format(_departure)} with '
          '${_crew.length} crew members.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start Trip'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    await _controller.queueOperation('Start fishing trip', 'trip', {
      'localId': _tripCode.text.trim(),
      'tripCode': _tripCode.text.trim(),
      'boatId': _boat!.id,
      'departure': _departure.toUtc().toIso8601String(),
      'expectedHours': double.parse(_duration.text),
      'crew': _crew.toList(),
      'notes': _notes.text.trim(),
      'fishingArea': {'latitude': _latitude, 'longitude': _longitude},
    });
    await _controller.startTrip(
      ActiveFishingTrip(
        id: _tripCode.text.trim(),
        boatId: _boat!.id,
        boatName: _boat!.name,
        startedAt: _departure,
        fishingArea:
            '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
        crew: _crew.toList(),
        catchKg: 0,
        batchCount: 0,
        status: TripStatus.inProgress,
        latitude: _latitude,
        longitude: _longitude,
      ),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _dirty = false;
    });
    context.go('/fisher/active-trip');
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    if (_controller.loading.value) {
      return const FishTraceScaffold(
        appBar: FishTraceAppBar(title: 'Start Trip', leading: BackButton()),
        body: LoadingState(message: 'Checking active trip...'),
      );
    }
    if (_controller.activeTrip.value != null) {
      return FishTraceScaffold(
        appBar: const FishTraceAppBar(
          title: 'Start Trip',
          leading: BackButton(),
        ),
        bottomNavigation: const RoleBottomBar(
          role: UserRole.fisher,
          selectedIndex: 1,
        ),
        body: EmptyState(
          title: 'Trip already active',
          message: 'Complete the current trip before starting another one.',
          icon: Icons.route_outlined,
          actionLabel: 'View Active Trip',
          onAction: () => context.go('/fisher/active-trip'),
        ),
      );
    }
    if (_controller.boats.where((boat) => boat.active).isEmpty) {
      return FishTraceScaffold(
        appBar: const FishTraceAppBar(
          title: 'Start Trip',
          leading: BackButton(),
        ),
        bottomNavigation: const RoleBottomBar(
          role: UserRole.fisher,
          selectedIndex: 1,
        ),
        body: EmptyState(
          title: 'No active boat',
          message: 'Add or activate a boat before starting a fishing trip.',
          icon: Icons.directions_boat_outlined,
          actionLabel: 'Manage Boats',
          onAction: () => context.go('/fisher/boats'),
        ),
      );
    }
    return _buildTripForm(context);
  });

  Widget _buildTripForm(BuildContext context) => PopScope(
    canPop: !_dirty,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      if (await _confirmDiscard() && context.mounted) context.pop();
    },
    child: FishTraceScaffold(
      appBar: const FishTraceAppBar(title: 'Start Trip', leading: BackButton()),
      bottomNavigation: const RoleBottomBar(
        role: UserRole.fisher,
        selectedIndex: 1,
      ),
      body: Form(
        key: _formKey,
        onChanged: () => _dirty = true,
        child: ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            FishTraceDropdown<FisherBoat>(
              label: 'Select Boat',
              value: _boat,
              items: _controller.boats.where((boat) => boat.active).toList(),
              itemLabel: (boat) =>
                  '${boat.name} · ${boat.lengthMetres.toStringAsFixed(1)} m',
              onChanged: (value) => setState(() {
                _boat = value;
                _dirty = true;
              }),
              required: true,
              validator: (value) => value == null ? 'Select a boat' : null,
            ),
            const SectionHeader(title: 'Trip Information'),
            FishTraceTextField(
              label: 'Trip Code',
              controller: _tripCode,
              required: true,
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'Trip code is required'
                  : null,
            ),
            const SizedBox(height: FishTraceSpacing.sm),
            FishTraceTextField(
              label: 'Departure Date & Time',
              controller: _departureText,
              readOnly: true,
              onTap: _pickDeparture,
              suffixIcon: const Icon(Icons.calendar_month_outlined),
            ),
            const SizedBox(height: FishTraceSpacing.sm),
            FishTraceTextField(
              label: 'Expected Duration (hours)',
              controller: _duration,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              required: true,
              validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                  ? 'Enter a valid duration'
                  : null,
            ),
            const SectionHeader(title: 'Fishing Area'),
            if (_latitude != null && _longitude != null)
              MapPreviewCard(
                center: LatLng(_latitude!, _longitude!),
                caption:
                    '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
              )
            else
              FishTraceSecondaryButton(
                label: 'Capture Current Location',
                icon: Icons.my_location,
                onPressed: _captureLocation,
              ),
            const SectionHeader(title: 'Crew Members'),
            FishTraceTextField(
              label: 'Crew member name',
              controller: _crewInput,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final name = _crewInput.text.trim();
                  if (name.isEmpty) return;
                  setState(() {
                    _crew.add(name);
                    _crewInput.clear();
                    _dirty = true;
                  });
                },
              ),
            ),
            Wrap(
              spacing: 8,
              children: _crew
                  .map(
                    (member) => InputChip(
                      label: Text(member),
                      onDeleted: () => setState(() => _crew.remove(member)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: FishTraceSpacing.md),
            FishTraceTextField(
              label: 'Notes',
              controller: _notes,
              maxLines: 3,
              hint: 'Optional trip notes',
            ),
            const SizedBox(height: FishTraceSpacing.xl),
            FishTracePrimaryButton(
              label: 'Start Trip',
              loading: _saving,
              onPressed: _startTrip,
            ),
          ],
        ),
      ),
    ),
  );
}
