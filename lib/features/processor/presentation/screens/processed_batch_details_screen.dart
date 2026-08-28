import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../controllers/processor_controller.dart';

class ProcessedBatchDetailsScreen extends StatelessWidget {
  const ProcessedBatchDetailsScreen({super.key, this.batchId});

  final String? batchId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProcessorController>();
    return Obx(() {
      final matches = batchId == null
          ? controller.history
          : controller.history.where((job) => job.batchId == batchId);
      if (matches.isEmpty) {
        return FishTraceScaffold(
          appBar: const FishTraceAppBar(
            title: 'Processed Batch Details',
            leading: BackButton(),
          ),
          bottomNavigation: const RoleBottomBar(
            role: UserRole.processor,
            selectedIndex: 1,
          ),
          body: const EmptyState(
            title: 'Processed batch not found',
            message: 'No matching processing history is available.',
            icon: Icons.inventory_2_outlined,
          ),
        );
      }
      final job = matches.first;
      return FishTraceScaffold(
        appBar: const FishTraceAppBar(
          title: 'Processed Batch Details',
          leading: BackButton(),
        ),
        bottomNavigation: const RoleBottomBar(
          role: UserRole.processor,
          selectedIndex: 1,
        ),
        body: ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            Row(
              children: [
                StatusChip(label: job.status.name),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.batchLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Total Output',
                      value: '${job.outputWeightKg.toStringAsFixed(1)} kg',
                      icon: Icons.scale_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MetricCard(
                      label: 'Packages',
                      value: '${job.packageCount}',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MetricCard(
                      label: 'Yield',
                      value:
                          '${(job.outputWeightKg / job.inputWeightKg * 100).toStringAsFixed(1)}%',
                      icon: Icons.trending_up,
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Processing Timeline'),
            FishTraceCard(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index <= ProcessingStep.values.indexOf(job.currentStep);
                    index++
                  )
                    _TimelineRow(
                      label:
                          ProcessingStep.values[index].name[0].toUpperCase() +
                          ProcessingStep.values[index].name.substring(1),
                      time: index == 0
                          ? FishTraceTime.format(
                              job.startedAt,
                              'MMM d · hh:mm a',
                            )
                          : 'Recorded',
                      last:
                          index ==
                          ProcessingStep.values.indexOf(job.currentStep),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.time,
    required this.last,
  });

  final String label;
  final String time;
  final bool last;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: FishTraceColors.success,
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Text(time, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
