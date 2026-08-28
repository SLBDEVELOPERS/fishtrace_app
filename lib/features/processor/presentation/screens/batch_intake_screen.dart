import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/processor_entities.dart';
import '../controllers/processor_controller.dart';

class BatchIntakeScreen extends StatelessWidget {
  const BatchIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProcessorController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(
        title: 'Batch Intake Details',
        leading: BackButton(),
      ),
      bottomNavigation: const RoleBottomBar(
        role: UserRole.processor,
        selectedIndex: 1,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const LoadingState(message: 'Checking batch intake status…');
        }
        final batch = controller.selectedBatch.value;
        if (batch == null) {
          return EmptyState(
            title: 'No batch selected',
            message: 'Scan or choose an incoming batch first.',
            icon: Icons.inventory_2_outlined,
            actionLabel: 'Scan Batch',
            onAction: () => context.go('/processor/scan-batch'),
          );
        }
        if (controller.acceptedBatchIds.contains(batch.id) ||
            controller.processingFor(batch.id) != null) {
          return EmptyState(
            title: 'Batch already accepted',
            message:
                'This batch has left the intake queue and cannot be accepted or rejected again.',
            icon: Icons.verified_outlined,
            actionLabel: 'Scan Another Batch',
            onAction: () => context.go('/processor/scan-batch'),
          );
        }
        return _IntakeBody(batch: batch, controller: controller);
      }),
    );
  }
}

class _IntakeBody extends StatelessWidget {
  const _IntakeBody({required this.batch, required this.controller});

  final IncomingBatch batch;
  final ProcessorController controller;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(label: 'New Intake'),
            ),
            const SizedBox(height: 8),
            Text('Batch code', style: Theme.of(context).textTheme.bodySmall),
            Row(
              children: [
                Expanded(
                  child: Text(
                    batch.label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy batch code',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: batch.label));
                    if (context.mounted) {
                      FishTraceFeedback.success(context, 'Batch code copied');
                    }
                  },
                  icon: const Icon(Icons.copy_outlined, size: 18),
                ),
              ],
            ),
            const SectionHeader(title: 'Catch Information'),
            FishTraceCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Species',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              batch.species,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.set_meal,
                        size: 55,
                        color: FishTraceColors.primary,
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _DetailRow(
                    label: 'Net Weight',
                    value: '${batch.weightKg.toStringAsFixed(1)} kg',
                  ),
                  _DetailRow(label: 'Catch Origin', value: batch.origin),
                  _DetailRow(label: 'Vessel', value: batch.vessel),
                  _DetailRow(label: 'Supplier', value: batch.supplier),
                  _DetailRow(
                    label: 'Catch Date',
                    value: FishTraceTime.format(
                      batch.catchDate,
                      'MMM d, yyyy · hh:mm a',
                    ),
                  ),
                  _DetailRow(
                    label: 'Temperature',
                    value: '${batch.temperature.toStringAsFixed(1)}°C · Good',
                    valueColor: FishTraceColors.success,
                  ),
                  _DetailRow(
                    label: 'Received At',
                    value: FishTraceTime.format(
                      batch.receivedAt,
                      'MMM d, yyyy · hh:mm a',
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Documents'),
            FishTraceCard(
              padding: EdgeInsets.zero,
              child: batch.documents.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No batch documents were uploaded.'),
                    )
                  : Column(
                      children: [
                        for (
                          var index = 0;
                          index < batch.documents.length;
                          index++
                        ) ...[
                          _DocumentTile(
                            title: batch.documents[index].name,
                            subtitle: batch.documents[index].mimeType,
                            onTap: () => _downloadDocument(
                              context,
                              batch.documents[index],
                            ),
                          ),
                          if (index < batch.documents.length - 1)
                            const Divider(),
                        ],
                      ],
                    ),
            ),
            if (batch.notes.isNotEmpty) ...[
              const SectionHeader(title: 'Notes'),
              FishTraceCard(child: Text(batch.notes)),
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
        child: Row(
          children: [
            Expanded(
              child: FishTraceDestructiveButton(
                label: 'Reject Batch',
                icon: Icons.close,
                onPressed: () => _reject(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FishTracePrimaryButton(
                label: 'Accept Batch',
                onPressed: () => _accept(context),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _accept(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.inventory_2_outlined,
          color: FishTraceColors.primary,
        ),
        title: const Text('Accept this batch?'),
        content: Text(
          '${batch.label} will enter the processing queue at ${batch.weightKg} kg.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept Batch'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final queued = await controller.acceptSelected();
    if (!context.mounted || queued == null) return;
    if (queued.status == SyncStatus.failed) {
      _message(
        context,
        queued.lastError ?? 'The batch could not be accepted.',
        tone: FishTraceFeedbackTone.error,
      );
      return;
    }
    if (queued.status != SyncStatus.synced) {
      _message(
        context,
        'Acceptance is queued. Processing can start after it syncs.',
        tone: FishTraceFeedbackTone.warning,
      );
      return;
    }
    context.go('/processor/processing');
  }

  Future<void> _downloadDocument(
    BuildContext context,
    IncomingBatchDocument document,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final safeName = document.name.replaceAll(
        RegExp(r'[^A-Za-z0-9._-]'),
        '_',
      );
      final path = '${directory.path}${Platform.pathSeparator}$safeName';
      await Get.find<Dio>().download(document.downloadUrl, path);
      if (context.mounted) {
        _message(
          context,
          'Document downloaded to $path',
          tone: FishTraceFeedbackTone.success,
        );
      }
    } catch (_) {
      if (context.mounted) {
        _message(
          context,
          'The document could not be downloaded.',
          tone: FishTraceFeedbackTone.error,
        );
      }
    }
  }

  Future<void> _reject(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final notes = TextEditingController();
    var reason = 'Temperature out of range';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Padding(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reject Batch',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                FishTraceDropdown<String>(
                  label: 'Rejection Reason',
                  value: reason,
                  items: const [
                    'Temperature out of range',
                    'Damaged packaging',
                    'Documentation mismatch',
                    'Quality not acceptable',
                  ],
                  itemLabel: (value) => value,
                  onChanged: (value) => setState(() => reason = value!),
                  required: true,
                ),
                const SizedBox(height: 12),
                FishTraceTextField(
                  label: 'Notes',
                  controller: notes,
                  maxLines: 3,
                  hint: 'Add rejection evidence',
                ),
                const SizedBox(height: 16),
                FishTraceDestructiveButton(
                  label: 'Confirm Rejection',
                  onPressed: () async {
                    final queued = await controller.rejectSelected(
                      reason,
                      notes.text,
                    );
                    if (!context.mounted || queued == null) return;
                    if (queued.status == SyncStatus.failed) {
                      _message(
                        context,
                        queued.lastError ?? 'The batch could not be rejected.',
                        tone: FishTraceFeedbackTone.error,
                      );
                      return;
                    }
                    if (queued.status != SyncStatus.synced) {
                      _message(
                        context,
                        'Rejection is queued and will finish when online.',
                        tone: FishTraceFeedbackTone.warning,
                      );
                      return;
                    }
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                    if (context.mounted) context.go('/processor');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    notes.dispose();
  }

  void _message(
    BuildContext context,
    String message, {
    FishTraceFeedbackTone tone = FishTraceFeedbackTone.info,
  }) => FishTraceFeedback.show(context, message, tone: tone);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
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
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: valueColor),
          ),
        ),
      ],
    ),
  );
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(
      Icons.description_outlined,
      color: FishTraceColors.info,
    ),
    title: Text(title, style: Theme.of(context).textTheme.titleSmall),
    subtitle: Text(subtitle.isEmpty ? 'Batch document' : subtitle),
    trailing: const Icon(Icons.download_outlined),
    onTap: onTap,
  );
}
