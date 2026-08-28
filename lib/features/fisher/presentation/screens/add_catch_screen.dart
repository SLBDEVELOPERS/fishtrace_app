import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/fisher_entities.dart';
import '../controllers/fisher_controller.dart';

class AddCatchScreen extends StatefulWidget {
  const AddCatchScreen({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<AddCatchScreen> createState() => _AddCatchScreenState();
}

class _AddCatchScreenState extends State<AddCatchScreen> {
  final _detailsKey = GlobalKey<FormState>();
  final _weight = TextEditingController();
  final _quantity = TextEditingController();
  final _notes = TextEditingController();
  final _picker = ImagePicker();
  final _images = <XFile>[];
  late final FisherController _controller;
  var _step = 0;
  String? _species;
  String? _gear;
  var _condition = 'Good';
  late DateTime _caughtAt;
  var _latitude = 17.6858;
  var _longitude = 83.2185;
  var _locationCaptured = false;
  var _saving = false;
  var _dirty = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<FisherController>();
    _caughtAt = widget.now();
  }

  @override
  void dispose() {
    _weight.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  double get _averageWeight {
    final weight = double.tryParse(_weight.text) ?? 0;
    final quantity = int.tryParse(_quantity.text) ?? 0;
    return quantity == 0 ? 0 : weight / quantity;
  }

  FisherSpeciesReference? get _selectedSpecies {
    final options = _controller.catchReferenceData.value.species;
    if (options.isEmpty) return null;
    return options.firstWhereOrNull((item) => item.commonName == _species) ??
        options.first;
  }

  String? get _selectedGear {
    final options = _controller.catchReferenceData.value.gearTypes;
    if (options.isEmpty) return null;
    return options.contains(_gear) ? _gear : options.first;
  }

  Future<void> _captureLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) _message('Enable location services to capture this catch.');
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        await _permissionDialog(
          title: 'Location permission required',
          message:
              'Enable precise location in system settings to record the catch position.',
          openSettings: Geolocator.openAppSettings,
        );
      }
      return;
    }
    if (permission == LocationPermission.denied) {
      if (mounted) _message('Location permission was denied.');
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationCaptured = true;
        _dirty = true;
      });
    } catch (_) {
      if (mounted) _message('Unable to capture GPS. Try again in open sky.');
    }
  }

  Future<void> _pickCamera() async {
    final status = await permissions.Permission.camera.request();
    if (status.isPermanentlyDenied) {
      if (mounted) {
        await _permissionDialog(
          title: 'Camera permission required',
          message: 'Enable camera access in settings to photograph this catch.',
          openSettings: permissions.openAppSettings,
        );
      }
      return;
    }
    if (!status.isGranted) {
      if (mounted) _message('Camera permission was denied.');
      return;
    }
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 72,
        maxWidth: 1600,
      );
      if (image != null && mounted) {
        setState(() {
          _images.add(image);
          _dirty = true;
        });
      }
    } catch (_) {
      if (mounted) _message('The camera could not be opened.');
    }
  }

  Future<void> _pickGallery() async {
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 72,
        maxWidth: 1600,
        limit: 6,
      );
      if (images.isNotEmpty && mounted) {
        setState(() {
          _images.addAll(images.take(6 - _images.length));
          _dirty = true;
        });
      }
    } catch (_) {
      if (mounted) _message('The photo library could not be opened.');
    }
  }

  Future<void> _pickCatchTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: widget.now().subtract(const Duration(days: 30)),
      lastDate: widget.now(),
      initialDate: _caughtAt,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_caughtAt),
    );
    if (time == null) return;
    setState(() {
      _caughtAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _dirty = true;
    });
  }

  void _next() {
    if (_step == 0 && !_detailsKey.currentState!.validate()) return;
    if (_step == 1 && !_locationCaptured) {
      _message('Capture the GPS location before continuing.');
      return;
    }
    setState(() => _step++);
  }

  Future<void> _save() async {
    if (!_detailsKey.currentState!.validate() || !_locationCaptured) return;
    if (_controller.activeTrip.value == null) {
      _message('You must start a fishing trip before adding a catch.');
      return;
    }
    final species = _selectedSpecies;
    final gear = _selectedGear;
    if (species == null || gear == null) {
      _message('Catch reference data is unavailable. Refresh and try again.');
      return;
    }
    setState(() => _saving = true);
    final id = _controller.nextLocalId('CATCH');
    final catchRecord = FisherCatch(
      id: id,
      tripId: _controller.activeTrip.value!.id,
      tripCode: _controller.activeTrip.value!.tripCode,
      species: species.commonName,
      scientificName: species.scientificName,
      weightKg: double.parse(_weight.text),
      quantity: int.parse(_quantity.text),
      caughtAt: _caughtAt,
      latitude: _latitude,
      longitude: _longitude,
      gear: gear,
      condition: _condition,
      verified: false,
      photoPaths: _images.map((image) => image.path).toList(),
    );
    await _controller.queueOperation('Catch · ${species.commonName}', 'catch', {
      'localId': id,
      'tripId': _controller.activeTrip.value?.id,
      'species': species.commonName,
      'weightKg': catchRecord.weightKg,
      'quantity': catchRecord.quantity,
      'averageWeightKg': _averageWeight,
      'gear': gear,
      'condition': _condition,
      'caughtAt': _caughtAt.toIso8601String(),
      'latitude': _latitude,
      'longitude': _longitude,
      'photos': catchRecord.photoPaths,
      'notes': _notes.text.trim(),
    });
    await _controller.addCatch(catchRecord);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _dirty = false;
    });
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: FishTraceColors.success,
          size: 44,
        ),
        title: const Text('Catch saved offline'),
        content: const Text(
          'The catch is secure on this device and will synchronize automatically.',
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
    if (mounted) context.go('/fisher/catch-history');
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    if (_controller.loading.value) {
      return const FishTraceScaffold(
        appBar: FishTraceAppBar(title: 'Add Catch', leading: BackButton()),
        body: LoadingState(message: 'Checking active trip...'),
      );
    }
    if (_controller.activeTrip.value == null) {
      return FishTraceScaffold(
        appBar: const FishTraceAppBar(
          title: 'Add Catch',
          leading: BackButton(),
        ),
        bottomNavigation: const RoleBottomBar(
          role: UserRole.fisher,
          selectedIndex: 0,
        ),
        body: EmptyState(
          title: 'No active trip',
          message: 'Start a fishing trip before adding a catch.',
          icon: Icons.route_outlined,
          actionLabel: 'Start Trip',
          onAction: () => context.go('/fisher/start-trip'),
        ),
      );
    }
    final references = _controller.catchReferenceData.value;
    if (references.species.isEmpty || references.gearTypes.isEmpty) {
      return FishTraceScaffold(
        appBar: const FishTraceAppBar(
          title: 'Add Catch',
          leading: BackButton(),
        ),
        bottomNavigation: const RoleBottomBar(
          role: UserRole.fisher,
          selectedIndex: 0,
        ),
        body: ErrorState(
          title: 'Catch options unavailable',
          message: 'Species and fishing gear could not be loaded.',
          onRetry: _controller.load,
        ),
      );
    }
    return _buildCatchForm(context);
  });

  Widget _buildCatchForm(BuildContext context) => PopScope(
    canPop: !_dirty,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      final discard = await _confirmDiscard();
      if (discard && context.mounted) context.pop();
    },
    child: FishTraceScaffold(
      appBar: const FishTraceAppBar(title: 'Add Catch', leading: BackButton()),
      bottomNavigation: const RoleBottomBar(
        role: UserRole.fisher,
        selectedIndex: 0,
      ),
      body: Column(
        children: [
          _StepHeader(current: _step),
          Expanded(
            child: IndexedStack(
              index: _step,
              children: [_detailsStep(), _locationStep(), _reviewStep()],
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
            child: Row(
              children: [
                if (_step > 0) ...[
                  Expanded(
                    child: FishTraceSecondaryButton(
                      label: 'Back',
                      onPressed: () => setState(() => _step--),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: 2,
                  child: FishTracePrimaryButton(
                    label: _step == 2 ? 'Save Catch' : 'Continue',
                    loading: _saving,
                    onPressed: _step == 2 ? _save : _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _detailsStep() => Form(
    key: _detailsKey,
    onChanged: () => setState(() => _dirty = true),
    child: ListView(
      padding: const EdgeInsets.all(FishTraceSpacing.md),
      children: [
        FishTraceDropdown<String>(
          label: 'Fish Species',
          value: _selectedSpecies?.commonName,
          items: _controller.catchReferenceData.value.species
              .map((item) => item.commonName)
              .toList(growable: false),
          itemLabel: (value) => value,
          onChanged: (value) => setState(() => _species = value!),
          required: true,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FishTraceTextField(
                label: 'Weight (kg)',
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                required: true,
                validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                    ? 'Enter weight'
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FishTraceTextField(
                label: 'Quantity',
                controller: _quantity,
                keyboardType: TextInputType.number,
                required: true,
                validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0
                    ? 'Enter quantity'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FishTraceCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Average Weight',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Text(
                '${_averageWeight.toStringAsFixed(2)} kg',
                maxLines: 1,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FishTraceDropdown<String>(
          label: 'Fishing Gear',
          value: _selectedGear,
          items: _controller.catchReferenceData.value.gearTypes,
          itemLabel: (value) => value,
          onChanged: (value) => setState(() => _gear = value!),
          required: true,
        ),
        const SizedBox(height: 12),
        FishTraceDropdown<String>(
          label: 'Condition',
          value: _condition,
          items: const ['Excellent', 'Good', 'Fair'],
          itemLabel: (value) => value,
          onChanged: (value) => setState(() => _condition = value!),
          required: true,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickCatchTime,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Catch Date & Time',
              suffixIcon: Icon(Icons.calendar_month_outlined),
            ),
            child: Text(DateFormat('MMM d, yyyy · hh:mm a').format(_caughtAt)),
          ),
        ),
        const SizedBox(height: 12),
        FishTraceTextField(
          label: 'Notes',
          controller: _notes,
          maxLines: 3,
          hint: 'Optional catch notes',
        ),
      ],
    ),
  );

  Widget _locationStep() => ListView(
    padding: const EdgeInsets.all(FishTraceSpacing.md),
    children: [
      Text('Capture Location', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 10),
      MapPreviewCard(
        center: LatLng(_latitude, _longitude),
        caption: _locationCaptured
            ? '${_latitude.toStringAsFixed(5)}° N, '
                  '${_longitude.toStringAsFixed(5)}° E'
            : 'GPS location has not been captured',
      ),
      const SizedBox(height: 10),
      FishTraceSecondaryButton(
        label: _locationCaptured
            ? 'Refresh Current Location'
            : 'Capture Current Location',
        icon: Icons.my_location,
        onPressed: _captureLocation,
      ),
      const SectionHeader(title: 'Catch Photos'),
      ImageAttachmentPicker(
        images: _images,
        onCamera: _images.length >= 6 ? null : _pickCamera,
        onGallery: _images.length >= 6 ? null : _pickGallery,
        onRemove: (image) => setState(() {
          _images.remove(image);
          _dirty = true;
        }),
      ),
      const SizedBox(height: 8),
      Text(
        'Add up to six compressed photos. Images remain available with the offline draft.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );

  Widget _reviewStep() => ListView(
    padding: const EdgeInsets.all(FishTraceSpacing.md),
    children: [
      Text('Review Catch', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: FishTraceSpacing.sm),
      FishTraceCard(
        child: Column(
          children: [
            _ReviewRow(
              label: 'Species',
              value: _selectedSpecies?.commonName ?? 'Not selected',
            ),
            _ReviewRow(label: 'Weight', value: '${_weight.text} kg'),
            _ReviewRow(label: 'Quantity', value: _quantity.text),
            _ReviewRow(
              label: 'Average weight',
              value: '${_averageWeight.toStringAsFixed(2)} kg',
            ),
            _ReviewRow(label: 'Gear', value: _selectedGear ?? 'Not selected'),
            _ReviewRow(label: 'Condition', value: _condition),
            _ReviewRow(
              label: 'Caught',
              value: DateFormat('MMM d · hh:mm a').format(_caughtAt),
            ),
            _ReviewRow(
              label: 'Location',
              value:
                  '${_latitude.toStringAsFixed(4)}, '
                  '${_longitude.toStringAsFixed(4)}',
            ),
            _ReviewRow(label: 'Photos', value: '${_images.length}'),
          ],
        ),
      ),
      const SizedBox(height: FishTraceSpacing.sm),
      const OfflineBanner(pendingCount: 1),
    ],
  );

  Future<bool> _confirmDiscard() async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard catch draft?'),
          content: const Text('Your unsaved catch information will be lost.'),
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

  Future<void> _permissionDialog({
    required String title,
    required String message,
    required Future<bool> Function() openSettings,
  }) async {
    final shouldOpen = await PermissionDialog.show(
      context: context,
      permissionName: title.replaceAll(' permission required', ''),
      message: message,
      permanentlyDenied: true,
    );
    if (shouldOpen) await openSettings();
  }

  void _message(String text) => FishTraceFeedback.warning(context, text);
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surface,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
    child: Row(
      children: [
        for (var index = 0; index < 3; index++) ...[
          if (index > 0)
            Expanded(
              child: Divider(
                color: index <= current
                    ? FishTraceColors.primary
                    : Theme.of(context).dividerColor,
              ),
            ),
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index <= current
                      ? FishTraceColors.primary
                      : Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: index <= current
                        ? FishTraceColors.primary
                        : FishTraceColors.disabled,
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index <= current
                        ? Colors.white
                        : FishTraceColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                const ['Details', 'Location', 'Review'][index],
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
