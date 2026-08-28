import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/display_identifier.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/fisher_entities.dart';
import '../controllers/fisher_controller.dart';

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageTemperature = TextEditingController();
  final _iceAmount = TextEditingController();
  final _landingSite = TextEditingController();
  final _notes = TextEditingController();
  late final FisherController _controller;
  late final String _batchId;
  final _selected = <String>{};
  var _processingType = 'Whole';
  var _grade = QualityGrade.a;
  var _iceType = 'Flake ice';
  var _saving = false;
  var _refreshing = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<FisherController>();
    _batchId = _controller.nextLocalId('BATCH');
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshCatches());
  }

  Future<void> _refreshCatches() async {
    if (!mounted) return;
    await _controller.load();
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  void dispose() {
    _storageTemperature.dispose();
    _iceAmount.dispose();
    _landingSite.dispose();
    _notes.dispose();
    super.dispose();
  }

  List<FisherCatch> get _selectedCatches =>
      _controller.catches.where((item) => _selected.contains(item.id)).toList();

  List<FisherCatch> get _availableCatches => _controller.catches
      .where((item) => item.availableWeightKg > .001)
      .toList(growable: false);

  bool _isCompatible(FisherCatch candidate) {
    if (_selected.contains(candidate.id) || _selectedCatches.isEmpty) {
      return true;
    }
    final first = _selectedCatches.first;
    return candidate.tripId == first.tripId &&
        candidate.species == first.species;
  }

  double get _totalWeight =>
      _selectedCatches.fold(0, (total, item) => total + item.availableWeightKg);

  int get _fishCount =>
      _selectedCatches.fold(0, (total, item) => total + item.quantity);

  String get _species {
    final names = _selectedCatches.map((item) => item.species).toSet();
    if (names.isEmpty) return 'Not selected';
    return names.length == 1 ? names.first : 'Mixed species';
  }

  Future<void> _create() async {
    if (_saving || _refreshing) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await _controller.load();
    if (!mounted) return;
    if (_controller.error.value != null) {
      setState(() => _saving = false);
      _message('Could not verify catch availability. Please try again.');
      return;
    }
    final availableIds = _availableCatches.map((item) => item.id).toSet();
    final unavailable = _selected.difference(availableIds);
    if (unavailable.isNotEmpty) {
      setState(() {
        _selected.removeAll(unavailable);
        _saving = false;
      });
      _message(
        'Catch availability changed. Fully allocated catches were removed.',
      );
      return;
    }
    if (_selected.isEmpty) {
      setState(() => _saving = false);
      _message('Select at least one catch.');
      return;
    }
    final tripIds = _selectedCatches.map((item) => item.tripId).toSet();
    final species = _selectedCatches.map((item) => item.species).toSet();
    if (tripIds.length != 1 || species.length != 1) {
      setState(() => _saving = false);
      _message('Select catches from one fishing trip and one species only.');
      return;
    }
    final batch = FisherBatchSummary(
      id: _batchId,
      species: _species,
      weightKg: _totalWeight,
      fishCount: _fishCount,
      grade: _grade,
      status: BatchStatus.completed,
      tripId: tripIds.single,
      tripCode: _selectedCatches.first.tripCode,
      createdAt: widget.now(),
    );
    await _controller.queueOperation('Create batch', 'batch', {
      'localId': _batchId,
      'catchIds': _selected.toList(),
      'catches': [
        for (final catchRecord in _selectedCatches)
          {
            'catchId': catchRecord.id,
            'weightKg': catchRecord.availableWeightKg,
          },
      ],
      'species': _species,
      'totalWeightKg': _totalWeight,
      'fishCount': _fishCount,
      'processingType': _processingType,
      'qualityGrade': _grade.name,
      'storageTemperature': double.parse(_storageTemperature.text),
      'iceType': _iceType,
      'iceAmountKg': double.parse(_iceAmount.text),
      'landingSite': _landingSite.text.trim(),
      'notes': _notes.text.trim(),
    });
    await _controller.addBatch(batch);
    if (!mounted) return;
    setState(() => _saving = false);
    context.go('/fisher/batch-details', extra: _batchId);
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    appBar: const FishTraceAppBar(title: 'Create Batch', leading: BackButton()),
    bottomNavigation: const RoleBottomBar(
      role: UserRole.fisher,
      selectedIndex: 2,
    ),
    body: _refreshing
        ? const LoadingState(message: 'Checking available catches...')
        : _availableCatches.isEmpty
        ? EmptyState(
            title: 'No catches available',
            message:
                'Add a catch with available weight before creating a batch.',
            icon: Icons.phishing,
            actionLabel: _controller.activeTrip.value == null
                ? 'Start Trip'
                : 'Add Catch',
            onAction: () => context.go(
              _controller.activeTrip.value == null
                  ? '/fisher/start-trip'
                  : '/fisher/add-catch',
            ),
          )
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(FishTraceSpacing.md),
              children: [
                FishTraceCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Draft batch reference',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              DisplayIdentifier.resolve(
                                id: _batchId,
                                noun: 'Batch',
                              ),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.auto_awesome,
                        color: FishTraceColors.primary,
                      ),
                    ],
                  ),
                ),
                const SectionHeader(title: 'Select Catches'),
                if (_availableCatches.isEmpty)
                  const EmptyState(
                    title: 'No catches available',
                    message:
                        'Add an unallocated catch before creating a batch.',
                    icon: Icons.phishing,
                  )
                else
                  for (final catchRecord in _availableCatches)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: CheckboxListTile(
                        value: _selected.contains(catchRecord.id),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        tileColor: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(
                            FishTraceRadii.card,
                          ),
                        ),
                        title: Text(
                          catchRecord.species,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          '${catchRecord.availableWeightKg.toStringAsFixed(1)} kg available · '
                          '${catchRecord.quantity} fish · ${catchRecord.tripLabel}',
                        ),
                        onChanged: _isCompatible(catchRecord)
                            ? (selected) => setState(() {
                                if (selected ?? false) {
                                  _selected.add(catchRecord.id);
                                } else {
                                  _selected.remove(catchRecord.id);
                                }
                              })
                            : null,
                      ),
                    ),
                const SectionHeader(title: 'Batch Information'),
                FishTraceCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _Metric(label: 'Species', value: _species),
                      ),
                      Container(
                        width: 1,
                        height: 46,
                        color: Theme.of(context).dividerColor,
                      ),
                      Expanded(
                        child: _Metric(
                          label: 'Total Catch',
                          value: '${_totalWeight.toStringAsFixed(1)} kg',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 46,
                        color: Theme.of(context).dividerColor,
                      ),
                      Expanded(
                        child: _Metric(
                          label: 'No. of Fish',
                          value: '$_fishCount',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FishTraceDropdown<String>(
                  label: 'Processing / Product Type',
                  value: _processingType,
                  items: const ['Whole', 'Gutted', 'Fillet', 'Frozen whole'],
                  itemLabel: (value) => value,
                  onChanged: (value) =>
                      setState(() => _processingType = value!),
                  required: true,
                ),
                const SizedBox(height: 12),
                FishTraceDropdown<QualityGrade>(
                  label: 'Quality Grade',
                  value: _grade,
                  items: const [QualityGrade.a, QualityGrade.b, QualityGrade.c],
                  itemLabel: (value) => '${value.name.toUpperCase()} Grade',
                  onChanged: (value) => setState(() => _grade = value!),
                  required: true,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FishTraceTextField(
                        label: 'Storage Temp. (°C)',
                        controller: _storageTemperature,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        required: true,
                        validator: (value) {
                          final number = double.tryParse(value ?? '');
                          return number == null || number < -30 || number > 10
                              ? 'Use -30 to 10'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FishTraceDropdown<String>(
                        label: 'Ice Type',
                        value: _iceType,
                        items: const ['Flake ice', 'Slurry ice', 'Block ice'],
                        itemLabel: (value) => value,
                        onChanged: (value) => setState(() => _iceType = value!),
                        required: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FishTraceTextField(
                  label: 'Ice Amount (kg)',
                  controller: _iceAmount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  required: true,
                  validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                      ? 'Enter a positive amount'
                      : null,
                ),
                const SizedBox(height: 12),
                FishTraceTextField(
                  label: 'Landing Site',
                  controller: _landingSite,
                  required: true,
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Landing site is required'
                      : null,
                ),
                const SizedBox(height: 12),
                FishTraceTextField(
                  label: 'Notes',
                  controller: _notes,
                  maxLines: 3,
                  hint: 'Optional batch notes',
                ),
                const SizedBox(height: 22),
                FishTracePrimaryButton(
                  label: _refreshing ? 'Checking catches…' : 'Create Batch',
                  loading: _saving || _refreshing,
                  onPressed: _refreshing ? null : _create,
                ),
              ],
            ),
          ),
  );

  void _message(String text) => FishTraceFeedback.warning(context, text);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: Theme.of(context).textTheme.labelMedium),
        ),
      ],
    ),
  );
}
