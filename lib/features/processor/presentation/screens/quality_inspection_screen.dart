import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/processor_entities.dart';
import '../controllers/processor_controller.dart';

class QualityInspectionScreen extends StatefulWidget {
  const QualityInspectionScreen({super.key});

  @override
  State<QualityInspectionScreen> createState() =>
      _QualityInspectionScreenState();
}

class _QualityInspectionScreenState extends State<QualityInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _temperature = TextEditingController();
  final _comments = TextEditingController();
  final _picker = ImagePicker();
  final _photos = <XFile>[];
  late final ProcessorController _controller;
  String? _grade;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProcessorController>();
  }

  @override
  void dispose() {
    _temperature.dispose();
    _comments.dispose();
    super.dispose();
  }

  Future<void> _save({required bool draft}) async {
    if (!draft && !_formKey.currentState!.validate()) return;
    if (_controller.selectedBatch.value == null) {
      FishTraceFeedback.warning(context, 'Select a batch before inspection');
      return;
    }
    final grades = _controller.referenceData.value.qualityGrades;
    final grade =
        grades.firstWhereOrNull((item) => item.code == _grade) ??
        grades.firstOrNull;
    if (grade == null) {
      FishTraceFeedback.error(context, 'Quality grades are not available');
      return;
    }
    setState(() => _saving = true);
    try {
      final queued = await _controller.queue(
        draft ? 'Inspection draft' : 'Quality inspection',
        'inspection',
        {
          'batchId': _controller.selectedBatch.value?.id,
          'criteria': {
            for (final item in _controller.inspection)
              item.name: item.result.name,
          },
          'temperature': double.tryParse(_temperature.text),
          'grade': grade.code,
          'comments': _comments.text,
          'photos': _photos.map((photo) => photo.path).toList(),
          'draft': draft,
        },
      );
      if (!mounted) return;
      if (draft) {
        FishTraceFeedback.success(context, 'Inspection draft saved');
        return;
      }
      if (queued.status != SyncStatus.synced) {
        FishTraceFeedback.show(
          context,
          queued.status == SyncStatus.failed
              ? queued.lastError ?? 'Inspection submission failed.'
              : 'Inspection is queued. Continue after it syncs.',
          tone: queued.status == SyncStatus.failed
              ? FishTraceFeedbackTone.error
              : FishTraceFeedbackTone.warning,
        );
        return;
      }
      await _controller.refreshHistory();
      if (!mounted) return;
      final passed = _controller.inspection.every(
        (criterion) => criterion.result == InspectionResult.pass,
      );
      context.go(passed ? '/processor/split-pack' : '/processor/history');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    appBar: const FishTraceAppBar(
      title: 'Quality Inspection',
      leading: BackButton(),
    ),
    bottomNavigation: const RoleBottomBar(
      role: UserRole.processor,
      selectedIndex: 1,
    ),
    body: Obx(() {
      if (_controller.selectedBatch.value == null) {
        return EmptyState(
          title: 'No batch selected',
          message: 'Complete processing before performing an inspection.',
          icon: Icons.fact_check_outlined,
          actionLabel: 'Processing',
          onAction: () => context.go('/processor/processing'),
        );
      }
      final processing = _controller.processingFor(
        _controller.selectedBatch.value!.id,
      );
      if (processing == null || !processing.allStepsCompleted) {
        return EmptyState(
          title: 'Inspection is not ready',
          message: 'Complete every processing step before quality inspection.',
          icon: Icons.lock_clock_outlined,
          actionLabel: 'Return to Processing',
          onAction: () => context.go('/processor/processing'),
        );
      }
      final grades = _controller.referenceData.value.qualityGrades;
      if (grades.isEmpty) {
        return ErrorState(
          title: 'Quality grades unavailable',
          message: 'Refresh the processor reference data before inspection.',
          onRetry: _controller.load,
        );
      }
      final selectedGrade =
          grades.firstWhereOrNull((item) => item.code == _grade) ??
          grades.first;
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
                        'Batch code',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _controller.selectedBatch.value?.label ??
                            'No batch selected',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Inspection',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(
              () => Column(
                children: [
                  for (
                    var index = 0;
                    index < _controller.inspection.length;
                    index++
                  )
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CriterionTile(
                        criterion: _controller.inspection[index],
                        onChanged: (result) {
                          _controller.updateInspection(index, result);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FishTraceTextField(
                    label: 'Temperature (°C)',
                    controller: _temperature,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    required: true,
                    validator: (value) {
                      final number = double.tryParse(value ?? '');
                      return number == null || number < -20 || number > 20
                          ? 'Use -20 to 20'
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FishTraceDropdown<String>(
                    label: 'Overall Grade',
                    value: selectedGrade.code,
                    items: grades.map((item) => item.code).toList(),
                    itemLabel: (value) =>
                        grades.firstWhere((item) => item.code == value).name,
                    onChanged: (value) => setState(() => _grade = value!),
                    required: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FishTraceTextField(
              label: 'Comments',
              controller: _comments,
              maxLines: 3,
              required: true,
              validator: (value) => (value?.trim().length ?? 0) < 5
                  ? 'Add inspection comments'
                  : null,
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
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FishTraceSecondaryButton(
                    label: 'Save Draft',
                    onPressed: _saving ? null : () => _save(draft: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FishTracePrimaryButton(
                    label: 'Submit Inspection',
                    loading: _saving,
                    onPressed: () => _save(draft: false),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }),
  );
}

class _CriterionTile extends StatelessWidget {
  const _CriterionTile({required this.criterion, required this.onChanged});

  final InspectionCriterion criterion;
  final ValueChanged<InspectionResult> onChanged;

  @override
  Widget build(BuildContext context) {
    final result = criterion.result;
    final color = switch (result) {
      InspectionResult.pass => FishTraceColors.success,
      InspectionResult.warning => FishTraceColors.warning,
      InspectionResult.fail => FishTraceColors.error,
    };
    return FishTraceCard(
      child: Row(
        children: [
          Icon(Icons.fact_check_outlined, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  criterion.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  criterion.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<InspectionResult>(
            initialValue: result,
            onSelected: onChanged,
            itemBuilder: (context) => [
              for (final value in InspectionResult.values)
                PopupMenuItem(
                  value: value,
                  child: Text(
                    value.name[0].toUpperCase() + value.name.substring(1),
                  ),
                ),
            ],
            child: StatusChip(
              label: result.name[0].toUpperCase() + result.name.substring(1),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
