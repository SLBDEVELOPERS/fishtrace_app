import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../controllers/processor_controller.dart';

class ProcessingWorkflowScreen extends StatefulWidget {
  const ProcessingWorkflowScreen({super.key});

  @override
  State<ProcessingWorkflowScreen> createState() =>
      _ProcessingWorkflowScreenState();
}

class _ProcessingWorkflowScreenState extends State<ProcessingWorkflowScreen> {
  final _notes = TextEditingController();
  final _cleanedWeight = TextEditingController();
  final _productTemperature = TextEditingController();
  final _outputWeight = TextEditingController();
  final _wasteWeight = TextEditingController();
  final _packageCount = TextEditingController();
  final _operator = TextEditingController();
  final _area = TextEditingController();
  final _picker = ImagePicker();
  final _photos = <XFile>[];
  late final ProcessorController _controller;
  var _saving = false;
  String? _grade;
  var _processingQueued = false;
  var _stepAlreadyStarted = false;
  var _resuming = true;
  var _readyForInspection = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProcessorController>();
    _resumeProcessing();
  }

  Future<void> _resumeProcessing() async {
    try {
      await _controller.refreshHistory();
      final batchId = _controller.selectedBatch.value?.id;
      final job = batchId == null ? null : _controller.processingFor(batchId);
      if (job != null && job.status == BatchStatus.inProgress) {
        _processingQueued = true;
        _stepAlreadyStarted = job.currentStepActive;
        _readyForInspection = job.allStepsCompleted;
        _controller.currentProcessingStep.value = job.currentStep;
      }
    } catch (_) {
      // The form remains usable; individual operations still report failures.
    } finally {
      if (mounted) setState(() => _resuming = false);
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    _cleanedWeight.dispose();
    _productTemperature.dispose();
    _outputWeight.dispose();
    _wasteWeight.dispose();
    _packageCount.dispose();
    _operator.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 72,
      maxWidth: 1600,
    );
    if (image != null && mounted) setState(() => _photos.add(image));
  }

  Future<void> _saveDraft() async {
    setState(() => _saving = true);
    await _controller.queue('Processing draft', 'processing', {
      'batchId': _controller.selectedBatch.value?.id,
      'inputWeightKg': _controller.selectedBatch.value?.weightKg,
      'step': _controller.currentProcessingStep.value.name,
      'operator': _operator.text.trim(),
      'area': _area.text.trim(),
      'notes': _notes.text,
      'photos': _photos.map((photo) => photo.path).toList(),
      'draft': true,
    });
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing draft saved offline')),
      );
    }
  }

  Future<void> _advance() async {
    final step = _controller.currentProcessingStep.value;
    final measurements = _measurementsFor(step);
    if (measurements == null) return;
    final batch = _controller.selectedBatch.value;
    if (batch == null) {
      _showError('Select a batch before starting processing.');
      return;
    }
    await _controller.refreshHistory();
    if (!mounted) return;
    if (_controller.processingFor(batch.id)?.hasProcessingRecord ?? false) {
      _processingQueued = true;
    }
    setState(() => _saving = true);
    try {
      if (!_processingQueued) {
        final queued = await _controller
            .queue('Start processing', 'processing', {
              'batchId': batch.id,
              'inputWeightKg': batch.weightKg,
              'operator': _operator.text.trim(),
              'area': _area.text.trim(),
              'notes': _notes.text,
              'photos': _photos.map((photo) => photo.path).toList(),
            });
        if (!_requireSynced(queued, 'Processing could not be started.')) {
          return;
        }
        _processingQueued = true;
      }
      final stepPayload = <String, Object?>{
        'batchId': batch.id,
        'step': step.name,
      };
      if (!_stepAlreadyStarted) {
        final started = await _controller.queue(
          'Start ${step.name}',
          'processing-step-start',
          stepPayload,
        );
        if (!_requireSynced(started, '${step.name} could not be started.')) {
          return;
        }
        _stepAlreadyStarted = true;
      }
      final completed = await _controller.queue(
        'Complete ${step.name}',
        'processing-step-complete',
        {...stepPayload, 'measurements': measurements, 'notes': _notes.text},
      );
      if (!_requireSynced(completed, '${step.name} could not be completed.')) {
        return;
      }
      _stepAlreadyStarted = false;
      if (!mounted) return;
      if (step.index < ProcessingStep.values.length - 1) {
        _controller.currentProcessingStep.value =
            ProcessingStep.values[step.index + 1];
      } else {
        await _controller.refreshHistory();
        if (!mounted) return;
        context.go('/processor/inspection');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _requireSynced(SyncQueueItem item, String fallback) {
    if (item.status == SyncStatus.synced) return true;
    _showError(
      item.status == SyncStatus.failed
          ? item.lastError ?? fallback
          : 'This step is queued. Continue after it syncs.',
    );
    return false;
  }

  Map<String, Object?>? _measurementsFor(ProcessingStep step) {
    switch (step) {
      case ProcessingStep.cleaning:
        final value = double.tryParse(_cleanedWeight.text);
        if (value == null || value <= 0) {
          _showError('Enter a cleaned weight greater than 0 kg.');
          return null;
        }
        return {'cleaned_weight_kg': value};
      case ProcessingStep.grading:
        final grades = _controller.referenceData.value.qualityGrades;
        final grade =
            grades.firstWhereOrNull((item) => item.code == _grade) ??
            grades.firstOrNull;
        if (grade == null) {
          _showError(
            'Quality grades are not available. Refresh and try again.',
          );
          return null;
        }
        return {'grade': grade.code};
      case ProcessingStep.freezing:
        final value = double.tryParse(_productTemperature.text);
        if (value == null || value < -40 || value > 4) {
          _showError('Enter a product temperature from -40°C to 4°C.');
          return null;
        }
        return {'product_temperature': value};
      case ProcessingStep.packaging:
        final output = double.tryParse(_outputWeight.text);
        final waste = double.tryParse(_wasteWeight.text);
        final packages = int.tryParse(_packageCount.text);
        if (output == null || output <= 0) {
          _showError('Enter an output weight greater than 0 kg.');
          return null;
        }
        if (waste == null || waste < 0) {
          _showError('Enter a waste weight of 0 kg or more.');
          return null;
        }
        if (packages == null || packages < 1) {
          _showError('Enter at least one package.');
          return null;
        }
        if (packages > 50) {
          _showError('A processing run supports up to 50 packages.');
          return null;
        }
        return {
          'output_weight_kg': output,
          'waste_weight_kg': waste,
          'package_count': packages,
        };
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    appBar: const FishTraceAppBar(
      title: 'Processing Workflow',
      leading: BackButton(),
    ),
    bottomNavigation: const RoleBottomBar(
      role: UserRole.processor,
      selectedIndex: 1,
    ),
    body: _resuming
        ? const LoadingState(message: 'Restoring processing progress…')
        : _readyForInspection
        ? EmptyState(
            title: 'Processing steps completed',
            message: 'Continue to the quality inspection for this batch.',
            icon: Icons.fact_check_outlined,
            actionLabel: 'Quality Inspection',
            onAction: () => context.go('/processor/inspection'),
          )
        : Obx(() {
            if (_controller.selectedBatch.value == null) {
              return EmptyState(
                title: 'No batch selected',
                message: 'Accept an incoming batch before starting processing.',
                icon: Icons.precision_manufacturing_outlined,
                actionLabel: 'Choose Intake',
                onAction: () => context.go('/processor/intake'),
              );
            }
            if (_controller.referenceData.value.qualityGrades.isEmpty) {
              return ErrorState(
                title: 'Processor reference data unavailable',
                message: 'Refresh before recording processing measurements.',
                onRetry: _controller.load,
              );
            }
            return ListView(
              padding: const EdgeInsets.all(FishTraceSpacing.md),
              children: [
                Text('Batch ID', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  _controller.selectedBatch.value?.id ?? 'No batch selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SectionHeader(title: 'Processing Steps'),
                for (final step in ProcessingStep.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ProcessingStepTile(
                      step: step,
                      current: _controller.currentProcessingStep.value,
                    ),
                  ),
                const SectionHeader(title: 'Step Measurements'),
                _measurementFields(_controller.currentProcessingStep.value),
                const SizedBox(height: 12),
                const SectionHeader(title: 'Assignment'),
                FishTraceTextField(
                  label: 'Processing Operator',
                  controller: _operator,
                  required: true,
                ),
                const SizedBox(height: 12),
                FishTraceTextField(
                  label: 'Processing Area',
                  controller: _area,
                  required: true,
                ),
                const SizedBox(height: 12),
                FishTraceTextField(
                  label: 'Notes',
                  controller: _notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ImageAttachmentPicker(
                  images: _photos,
                  multiple: true,
                  onCamera: _addPhoto,
                  onGallery: () async {
                    final images = await _picker.pickMultiImage(
                      imageQuality: 72,
                      maxWidth: 1600,
                    );
                    if (mounted) setState(() => _photos.addAll(images));
                  },
                  onRemove: (photo) => setState(() => _photos.remove(photo)),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FishTraceSecondaryButton(
                        label: 'Save Draft',
                        onPressed: _saving ? null : _saveDraft,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FishTracePrimaryButton(
                        label:
                            _controller.currentProcessingStep.value ==
                                ProcessingStep.packaging
                            ? 'Complete'
                            : 'Next Step',
                        loading: _saving,
                        onPressed: _advance,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
  );

  Widget _measurementFields(ProcessingStep step) => switch (step) {
    ProcessingStep.cleaning => FishTraceTextField(
      label: 'Cleaned Weight (kg)',
      controller: _cleanedWeight,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      required: true,
    ),
    ProcessingStep.grading => Builder(
      builder: (context) {
        final grades = _controller.referenceData.value.qualityGrades;
        final selected =
            grades.firstWhereOrNull((item) => item.code == _grade) ??
            grades.first;
        return FishTraceDropdown<String>(
          label: 'Grade',
          value: selected.code,
          items: grades.map((item) => item.code).toList(),
          itemLabel: (value) =>
              grades.firstWhere((item) => item.code == value).name,
          onChanged: (value) => setState(() => _grade = value!),
          required: true,
        );
      },
    ),
    ProcessingStep.freezing => FishTraceTextField(
      label: 'Product Temperature (°C)',
      controller: _productTemperature,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      required: true,
    ),
    ProcessingStep.packaging => Column(
      children: [
        FishTraceTextField(
          label: 'Output Weight (kg)',
          controller: _outputWeight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          required: true,
        ),
        const SizedBox(height: 12),
        FishTraceTextField(
          label: 'Waste Weight (kg)',
          controller: _wasteWeight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          required: true,
        ),
        const SizedBox(height: 12),
        FishTraceTextField(
          label: 'Package Count',
          controller: _packageCount,
          keyboardType: TextInputType.number,
          required: true,
        ),
      ],
    ),
  };
}

class _ProcessingStepTile extends StatelessWidget {
  const _ProcessingStepTile({required this.step, required this.current});

  final ProcessingStep step;
  final ProcessingStep current;

  @override
  Widget build(BuildContext context) {
    final complete = step.index < current.index;
    final active = step == current;
    final description = switch (step) {
      ProcessingStep.cleaning => 'Remove scales, gills & gut',
      ProcessingStep.grading => 'Grade by size & quality',
      ProcessingStep.freezing => 'Blast freeze to target temperature',
      ProcessingStep.packaging => 'Seal & label packages',
    };
    return FishTraceCard(
      borderColor: active ? FishTraceColors.primary : FishTraceColors.border,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: complete || active
                  ? FishTraceColors.primary
                  : FishTraceColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: complete
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${step.index + 1}',
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : FishTraceColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name[0].toUpperCase() + step.name.substring(1),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
