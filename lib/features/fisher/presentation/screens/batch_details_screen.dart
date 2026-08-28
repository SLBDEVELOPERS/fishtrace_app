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
      _BatchIdentityPanel(batch: batch, details: details),
      const SectionHeader(title: 'Verification QR'),
      QRCodeCard(
        data: details?.traceUrl.isNotEmpty == true
            ? details!.traceUrl
            : 'fishtrace://batch/${batch.id}',
        caption: details?.traceUrl.isNotEmpty == true
            ? 'Scan to verify batch details'
            : 'Public QR available after sync',
        size: 210,
        onFullscreen: () => _showFullQr(context, batch),
      ),
      const SectionHeader(title: 'Source information'),
      FishTraceCard(
        elevation: 0,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: FishTraceColors.primary.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(FishTraceRadii.input),
              ),
              child: const Icon(
                Icons.route_outlined,
                color: FishTraceColors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: FishTraceSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Linked trip',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details?.tripCode.isNotEmpty == true
                        ? details!.tripCode
                        : batch.tripLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    details?.boatName.isNotEmpty == true
                        ? details!.boatName
                        : 'Boat details unavailable',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SectionHeader(title: 'Traceability timeline'),
      _TraceabilityTimeline(details: details),
      const SizedBox(height: FishTraceSpacing.lg),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: details?.traceUrl.isNotEmpty == true
                  ? () => _copyTraceLink(context)
                  : null,
              icon: const Icon(Icons.copy_outlined, size: 18),
              label: const Text('Copy link'),
            ),
          ),
          const SizedBox(width: FishTraceSpacing.sm),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _showFullQr(context, batch),
              icon: const Icon(Icons.qr_code_2, size: 18),
              label: const Text('Show QR'),
            ),
          ),
        ],
      ),
      const SizedBox(height: FishTraceSpacing.md),
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
                    caption: batch.label,
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
      FishTraceFeedback.success(context, 'Public trace link copied');
    }
  }
}

class _BatchIdentityPanel extends StatelessWidget {
  const _BatchIdentityPanel({required this.batch, required this.details});

  final FisherBatchSummary batch;
  final FisherBatchDetails? details;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(FishTraceSpacing.md),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [FishTraceColors.navy, FishTraceColors.primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(FishTraceRadii.panel),
      boxShadow: [
        BoxShadow(
          color: FishTraceColors.navy.withValues(alpha: .18),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(FishTraceRadii.input),
              ),
              child: const Icon(Icons.set_meal, color: Colors.white, size: 26),
            ),
            const SizedBox(width: FishTraceSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details?.batchCode.isNotEmpty == true
                        ? details!.batchCode
                        : batch.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    batch.species,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: .76),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: FishTraceSpacing.xs),
            StatusChip(
              label: details?.statusLabel ?? batch.status.name,
              onDark: true,
            ),
          ],
        ),
        const SizedBox(height: FishTraceSpacing.sm),
        Text(
          'Created ${FishTraceTime.format(batch.createdAt, 'MMM d, yyyy · hh:mm a')}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: .72),
          ),
        ),
        const SizedBox(height: FishTraceSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FishTraceSpacing.xs,
            vertical: FishTraceSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(FishTraceRadii.card),
            border: Border.all(color: Colors.white.withValues(alpha: .12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _CertificateMetric(
                  label: 'Total catch',
                  value: '${batch.weightKg.toStringAsFixed(1)} kg',
                ),
              ),
              _MetricDivider(),
              Expanded(
                child: _CertificateMetric(
                  label: 'Fish count',
                  value: '${batch.fishCount}',
                ),
              ),
              _MetricDivider(),
              Expanded(
                child: _CertificateMetric(
                  label: 'Grade',
                  value: batch.grade.name.toUpperCase(),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34,
    color: Colors.white.withValues(alpha: .14),
  );
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
    elevation: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (details == null || details!.events.isEmpty)
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: FishTraceColors.primary.withValues(alpha: .09),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_toggle_off,
                  color: FishTraceColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: FishTraceSpacing.sm),
              Expanded(
                child: Text(
                  'No traceability events recorded yet.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        for (final event in details?.events ?? const <BatchTimelineEvent>[])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
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
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Text(
                  DateFormat(
                    'MMM d · hh:mm a',
                  ).format(FishTraceTime.inSriLanka(event.occurredAt)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        if (details?.documents.isNotEmpty == true) ...[
          const Divider(),
          for (final document in details!.documents)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.description_outlined,
                color: FishTraceColors.primary,
                size: 18,
              ),
              title: Text(
                document.name,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
        ],
      ],
    ),
  );
}
