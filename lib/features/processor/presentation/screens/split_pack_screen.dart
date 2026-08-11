import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../controllers/processor_controller.dart';

class SplitPackScreen extends StatefulWidget {
  const SplitPackScreen({super.key});

  @override
  State<SplitPackScreen> createState() => _SplitPackScreenState();
}

class _SplitPackScreenState extends State<SplitPackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _packageSize = TextEditingController();
  late final ProcessorController _controller;
  var _packagingType = 'Vacuum Pack';
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProcessorController>();
    _controller.generatedChildren.clear();
    _loadExistingResults();
  }

  Future<void> _loadExistingResults() async {
    try {
      await _controller.refreshHistory();
      final parentId = _controller.selectedBatch.value?.id;
      if (_recordedPackageCount > 0) {
        _packageSize.text = _size.toStringAsFixed(3);
      }
      if (parentId != null) {
        await _controller.refreshChildBatches(parentId);
      }
      if (mounted) setState(() {});
    } catch (_) {
      // A new split can still be created when no previous result is available.
    }
  }

  @override
  void dispose() {
    _packageSize.dispose();
    super.dispose();
  }

  double get _inputWeight {
    final batch = _controller.selectedBatch.value;
    if (batch == null) return 0;
    final processed = _controller.processingFor(batch.id);
    return processed != null && processed.outputWeightKg > 0
        ? processed.outputWeightKg
        : batch.weightKg;
  }

  int get _recordedPackageCount {
    final batchId = _controller.selectedBatch.value?.id;
    return batchId == null
        ? 0
        : _controller.processingFor(batchId)?.packageCount ?? 0;
  }

  double get _size =>
      _recordedPackageCount <= 0 ? 0 : _inputWeight / _recordedPackageCount;

  int get _packageCount => _recordedPackageCount;

  List<double> get _weights {
    if (_recordedPackageCount <= 0 || _inputWeight <= 0) return const [];
    final packageWeight = _size;
    return [
      for (var index = 0; index < _recordedPackageCount; index++)
        index == _recordedPackageCount - 1
            ? _inputWeight - packageWeight * index
            : packageWeight,
    ];
  }

  Future<void> _generate() async {
    final parent = _controller.selectedBatch.value;
    if (parent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a parent batch first')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    await _controller.refreshHistory();
    if (!mounted) return;
    final output = _weights.fold(0.0, (total, value) => total + value);
    final validation = _controller.validateOutput(_inputWeight, output);
    if (validation != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validation)));
      return;
    }
    setState(() => _saving = true);
    try {
      final queued = await _controller.queue(
        'Generate child batch labels',
        'child-batches',
        {
          'parentBatchId': parent.id,
          'inputWeightKg': _inputWeight,
          'packageSizeKg': _size,
          'packagingType': _packagingType,
          'children': [
            for (var index = 0; index < _weights.length; index++)
              {
                'id': '${parent.id}-${String.fromCharCode(65 + index)}',
                'weightKg': _weights[index],
              },
          ],
        },
      );
      if (!mounted) return;
      if (queued.status == SyncStatus.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              queued.lastError ?? 'The child batches could not be generated.',
            ),
          ),
        );
        return;
      }
      if (queued.status != SyncStatus.synced) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Label generation is queued and will finish when the app is online.',
            ),
          ),
        );
        return;
      }
      await _controller.refreshChildBatches(parent.id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load generated labels: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    appBar: const FishTraceAppBar(
      title: 'Split / Pack Batch',
      leading: BackButton(),
    ),
    bottomNavigation: const RoleBottomBar(
      role: UserRole.processor,
      selectedIndex: 1,
    ),
    body: Obx(() {
      if (_controller.selectedBatch.value == null) {
        return EmptyState(
          title: 'No processed batch selected',
          message: 'Complete processing and inspection before splitting.',
          icon: Icons.call_split_outlined,
          actionLabel: 'Processing History',
          onAction: () => context.go('/processor/history'),
        );
      }
      final processing = _controller.processingFor(
        _controller.selectedBatch.value!.id,
      );
      if (processing == null || processing.status != BatchStatus.completed) {
        return EmptyState(
          title: 'Batch is not ready for packing',
          message:
              'Complete processing and pass quality inspection before generating labels.',
          icon: Icons.lock_outline,
          actionLabel: 'Processing History',
          onAction: () => context.go('/processor/history'),
        );
      }
      if (_controller.generatedChildren.isNotEmpty) {
        return ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: FishTraceColors.success,
            ),
            const SizedBox(height: 10),
            Text(
              'Labels generated successfully',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${_controller.generatedChildren.length} child batches are ready for transport.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SectionHeader(title: 'Generated Child Batches'),
            for (final child in _controller.generatedChildren)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FishTraceCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code_2,
                        color: FishTraceColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.batchCode,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${child.weightKg.toStringAsFixed(1)} kg',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy trace link',
                        onPressed: child.traceUrl.isEmpty
                            ? null
                            : () async {
                                await Clipboard.setData(
                                  ClipboardData(text: child.traceUrl),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Trace link copied'),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.copy_outlined),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FishTracePrimaryButton(
              label: 'View Processing History',
              onPressed: () => context.go('/processor/history'),
            ),
            const SizedBox(height: 8),
            FishTraceSecondaryButton(
              label: 'Scan Another Batch',
              onPressed: () => context.go('/processor/scan-batch'),
            ),
          ],
        );
      }
      return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parent Batch',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _controller.selectedBatch.value?.id ??
                            'No batch selected',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '${_inputWeight.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.set_meal,
                  color: FishTraceColors.primary,
                  size: 42,
                ),
              ],
            ),
            const SectionHeader(title: 'Package Configuration'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FishTraceTextField(
                    label: 'Package Size (kg)',
                    controller: _packageSize,
                    readOnly: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    required: true,
                    validator: (_) => _recordedPackageCount <= 0
                        ? 'Complete the packaging step first'
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FishTraceDropdown<String>(
                    label: 'Packaging Type',
                    value: _packagingType,
                    items: const [
                      'Vacuum Pack',
                      'Ice Box',
                      'Poly Bag',
                      'Carton',
                    ],
                    itemLabel: (value) => value,
                    onChanged: (value) =>
                        setState(() => _packagingType = value!),
                    required: true,
                  ),
                ),
              ],
            ),
            const SectionHeader(title: 'Child Batches'),
            if (_weights.isEmpty)
              const FishTraceCard(
                child: Text('Enter a valid package size to generate batches.'),
              )
            else
              FishTraceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var index = 0; index < _weights.length; index++) ...[
                      ListTile(
                        dense: true,
                        title: Text(
                          '${_controller.selectedBatch.value?.id ?? 'UNASSIGNED'}-${String.fromCharCode(65 + index)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        trailing: Text(
                          '${_weights[index].toStringAsFixed(1)} kg',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      if (index < _weights.length - 1) const Divider(),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 12),
            FishTraceCard(
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryMetric(
                      label: 'Total Packages',
                      value: '$_packageCount',
                    ),
                  ),
                  Expanded(
                    child: _SummaryMetric(
                      label: 'Total Weight',
                      value:
                          '${_weights.fold(0.0, (a, b) => a + b).toStringAsFixed(1)} kg',
                    ),
                  ),
                  Expanded(
                    child: _SummaryMetric(
                      label: 'Variance',
                      value:
                          '${(_inputWeight - _weights.fold(0.0, (a, b) => a + b)).toStringAsFixed(1)} kg',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FishTracePrimaryButton(
              label: 'Generate Labels',
              loading: _saving,
              onPressed: _weights.isEmpty ? null : _generate,
            ),
          ],
        ),
      );
    }),
  );
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 3),
      FittedBox(
        child: Text(value, style: Theme.of(context).textTheme.titleSmall),
      ),
    ],
  );
}
