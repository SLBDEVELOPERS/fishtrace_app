import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/fisher_entities.dart';
import '../controllers/fisher_controller.dart';

class BatchListScreen extends StatelessWidget {
  const BatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FisherController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(title: 'Batches', leading: BackButton()),
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
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.batches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final batch = controller.batches[index];
            return _BatchListCard(
              batch: batch,
              onTap: () =>
                  context.push(AppRoute.fisherBatchDetails, extra: batch.id),
            );
          },
        );
      }),
    );
  }
}

class _BatchListCard extends StatelessWidget {
  const _BatchListCard({required this.batch, required this.onTap});

  final FisherBatchSummary batch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FishTraceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FishTraceColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.set_meal_outlined,
              color: FishTraceColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(batch.id, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  '${batch.species} • ${batch.weightKg.toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const StatusChip(label: 'Completed'),
              const SizedBox(height: 4),
              Text(
                FishTraceTime.format(batch.createdAt, 'MMM d'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
