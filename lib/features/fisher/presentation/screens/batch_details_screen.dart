import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/fisher_entities.dart';
import '../controllers/fisher_controller.dart';

class BatchDetailsScreen extends StatefulWidget {
  const BatchDetailsScreen({super.key, this.batchId});

  final String? batchId;

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  late final FisherController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<FisherController>();
    if (widget.batchId != null) controller.loadBatchDetails(widget.batchId!);
  }

  @override
  Widget build(BuildContext context) {
    return FishTraceScaffold(
      backgroundColor: FishTraceColors.navy,
      appBar: const FishTraceAppBar(
        title: 'Batch Details',
        leading: BackButton(color: Colors.white),
        teal: true,
      ),
      bottomNavigation: const RoleBottomBar(
        role: UserRole.fisher,
        selectedIndex: 2,
      ),
      body: Obx(() {
        if (controller.batches.isEmpty) {
          return const EmptyState(
            title: 'No batches',
            message: 'Create a batch from verified catches.',
            icon: Icons.layers_outlined,
          );
        }
        final batch = widget.batchId != null
            ? controller.batches.firstWhereOrNull((b) => b.id == widget.batchId)
            : controller.batches.first;
        if (batch == null) {
          return const EmptyState(
            title: 'Batch not found',
            message: 'Refresh the batch list and try again.',
            icon: Icons.error_outline,
          );
        }
        if (controller.batchDetailsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return _BatchCertificate(
          batch: controller.batchDetails.value?.summary ?? batch,
          details: controller.batchDetails.value,
        );
      }),
    );
  }
}

class _BatchCertificate extends StatelessWidget {
  const _BatchCertificate({required this.batch, required this.details});

  final FisherBatchSummary batch;
  final FisherBatchDetails? details;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(FishTraceSpacing.md),
    children: [
      Row(
        children: [
          const Icon(Icons.set_meal, color: Colors.white, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details?.batchCode.isNotEmpty == true
                      ? details!.batchCode
                      : batch.id,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                Text(
                  batch.species,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          StatusChip(label: details?.statusLabel ?? batch.status.name),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'Created ${FishTraceTime.format(batch.createdAt, 'MMM d, yyyy · hh:mm a')}',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
      const SizedBox(height: 16),
      FishTraceCard(
        color: Colors.white.withValues(alpha: .06),
        borderColor: Colors.white.withValues(alpha: .18),
        child: Row(
          children: [
            Expanded(
              child: _CertificateMetric(
                label: 'Total Catch',
                value: '${batch.weightKg.toStringAsFixed(1)} kg',
              ),
            ),
            Expanded(
              child: _CertificateMetric(
                label: 'No. of Fish',
                value: '${batch.fishCount}',
              ),
            ),
            Expanded(
              child: _CertificateMetric(
                label: 'Grade',
                value: batch.grade.name.toUpperCase(),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      QRCodeCard(
        data: details?.traceUrl.isNotEmpty == true
            ? details!.traceUrl
            : 'fishtrace://batch/${batch.id}',
        caption: details?.traceUrl.isNotEmpty == true
            ? 'Scan to verify batch details'
            : 'Public QR available after sync',
        size: 210,
        dark: true,
        onFullscreen: () => _showFullQr(context, batch),
      ),
      const SizedBox(height: 12),
      FishTraceCard(
        color: Colors.white.withValues(alpha: .06),
        borderColor: Colors.white.withValues(alpha: .18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Linked Trip',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 3),
            Text(
              details?.tripCode.isNotEmpty == true
                  ? details!.tripCode
                  : batch.tripId,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: Colors.white),
            ),
            Text(
              details?.boatName.isNotEmpty == true
                  ? details!.boatName
                  : 'Boat details unavailable',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _TraceabilityTimeline(details: details),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: details?.traceUrl.isNotEmpty == true
                  ? () => _copyTraceLink(context)
                  : null,
              icon: const Icon(Icons.copy_outlined, color: Colors.white),
              label: const Text(
                'Copy link',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: TextButton.icon(
              onPressed: () => _showFullQr(context, batch),
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              label: const Text(
                'Show QR',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Future<void> _showFullQr(BuildContext context, FisherBatchSummary batch) =>
      showDialog<void>(
        context: context,
        builder: (context) => Dialog.fullscreen(
          backgroundColor: FishTraceColors.navy,
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close QR code',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(26),
                  child: QRCodeCard(
                    data: details?.traceUrl.isNotEmpty == true
                        ? details!.traceUrl
                        : 'fishtrace://batch/${batch.id}',
                    caption: batch.id,
                    size: 280,
                    dark: true,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );

  Future<void> _copyTraceLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: details!.traceUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Public trace link copied')));
    }
  }
}

class _CertificateMetric extends StatelessWidget {
  const _CertificateMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
      const SizedBox(height: 3),
      FittedBox(
        child: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.white),
        ),
      ),
    ],
  );
}

class _TraceabilityTimeline extends StatelessWidget {
  const _TraceabilityTimeline({required this.details});

  final FisherBatchDetails? details;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    color: Colors.white.withValues(alpha: .06),
    borderColor: Colors.white.withValues(alpha: .18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Traceability Timeline',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        if (details == null || details!.events.isEmpty)
          const Text(
            'No traceability events recorded yet.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        for (final event in details?.events ?? const <BatchTimelineEvent>[])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: FishTraceColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Text(
                  DateFormat(
                    'MMM d · hh:mm a',
                  ).format(FishTraceTime.inSriLanka(event.occurredAt)),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        if (details?.documents.isNotEmpty == true) ...[
          const Divider(color: Colors.white24),
          for (final document in details!.documents)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.description_outlined,
                color: FishTraceColors.aqua,
                size: 18,
              ),
              title: Text(
                document.name,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ],
    ),
  );
}
