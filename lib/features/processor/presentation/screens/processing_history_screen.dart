import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/processor_entities.dart';
import '../controllers/processor_controller.dart';

class ProcessingHistoryScreen extends StatelessWidget {
  const ProcessingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProcessorController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(
        title: 'History / Reports',
        leading: BackButton(),
      ),
      bottomNavigation: const RoleBottomBar(
        role: UserRole.processor,
        selectedIndex: 2,
      ),
      body: Obx(() {
        final jobs = controller.filteredHistory;
        final yields = controller.history
            .where(
              (job) =>
                  job.status == BatchStatus.completed && job.inputWeightKg > 0,
            )
            .map((job) => job.outputWeightKg / job.inputWeightKg * 100)
            .toList(growable: false);
        return ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            FishTraceSearchField(
              hint: 'Search batch or species',
              onChanged: (value) => controller.search.value = value,
            ),
            const SizedBox(height: 10),
            SegmentedButton<ProcessingHistoryFilter>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ProcessingHistoryFilter.all,
                  label: Text('All'),
                ),
                ButtonSegment(
                  value: ProcessingHistoryFilter.completed,
                  label: Text('Completed'),
                ),
                ButtonSegment(
                  value: ProcessingHistoryFilter.inProgress,
                  label: Text('In Progress'),
                ),
                ButtonSegment(
                  value: ProcessingHistoryFilter.rejected,
                  label: Text('Rejected'),
                ),
              ],
              selected: {controller.historyFilter.value},
              onSelectionChanged: (value) =>
                  controller.historyFilter.value = value.first,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 94,
              child: Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Completed',
                      value:
                          '${controller.history.where((job) => job.status == BatchStatus.completed).length}',
                      icon: Icons.check_circle_outline,
                      delta: '+12%',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MetricCard(
                      label: 'In Progress',
                      value:
                          '${controller.history.where((job) => job.status == BatchStatus.inProgress).length}',
                      icon: Icons.schedule,
                      color: FishTraceColors.info,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MetricCard(
                      label: 'Quality Hold',
                      value:
                          '${controller.history.where((job) => job.status == BatchStatus.qualityHold).length}',
                      icon: Icons.pause_circle_outline,
                      color: FishTraceColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Yield Analytics'),
            ChartCard(
              title: 'Output yield (%)',
              values: yields,
              unit: '%',
              height: 120,
            ),
            const SectionHeader(title: 'Processing History'),
            if (jobs.isEmpty)
              const SizedBox(
                height: 210,
                child: EmptyState(
                  title: 'No processing records',
                  message: 'Adjust the current filter or search.',
                  icon: Icons.history,
                ),
              )
            else
              for (final job in jobs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _JobTile(job: job, controller: controller),
                ),
          ],
        );
      }),
    );
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({required this.job, required this.controller});

  final ProcessingJob job;
  final ProcessorController controller;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: () {
      if (job.status == BatchStatus.completed ||
          job.status == BatchStatus.rejected) {
        context.push('/processor/processed-details', extra: job.batchId);
        return;
      }
      controller.selectProcessingJob(job);
      if (job.status == BatchStatus.qualityHold) {
        context.go('/processor/inspection');
        return;
      }
      context.go('/processor/processing');
    },
    child: Row(
      children: [
        const Icon(Icons.set_meal, color: FishTraceColors.primary, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.batchId, style: Theme.of(context).textTheme.titleSmall),
              Text(
                '${job.species} · ${job.inputWeightKg.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                FishTraceTime.format(job.startedAt, 'MMM d, yyyy · hh:mm a'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        StatusChip(
          label: switch (job.status) {
            BatchStatus.completed => 'Completed',
            BatchStatus.inProgress => 'In Progress',
            BatchStatus.qualityHold => 'Quality Hold',
            BatchStatus.rejected => 'Rejected',
            _ => job.hasProcessingRecord ? 'New' : 'Accepted',
          },
          color: switch (job.status) {
            BatchStatus.completed => FishTraceColors.success,
            BatchStatus.inProgress => FishTraceColors.warning,
            BatchStatus.qualityHold => FishTraceColors.warning,
            BatchStatus.rejected => FishTraceColors.error,
            _ => FishTraceColors.info,
          },
        ),
      ],
    ),
  );
}
