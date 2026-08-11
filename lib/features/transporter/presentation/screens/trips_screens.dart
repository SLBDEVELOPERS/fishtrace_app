import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/transporter_entities.dart';
import '../controllers/transporter_controller.dart';

class TripsListScreen extends StatelessWidget {
  const TripsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransporterController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(title: 'My Trips', leading: BackButton()),
      bottomNavigation: const RoleBottomBar(
        role: UserRole.transporter,
        selectedIndex: 1,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/transporter/create-trip'),
        icon: const Icon(Icons.add_road),
        label: const Text('New Trip'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: FishTraceSearchField(
              hint: 'Search trips or hubs',
              onChanged: (value) => controller.search.value = value,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => SegmentedButton<TripFilter>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: TripFilter.all, label: Text('All')),
                  ButtonSegment(
                    value: TripFilter.inProgress,
                    label: Text('In Progress'),
                  ),
                  ButtonSegment(
                    value: TripFilter.upcoming,
                    label: Text('Upcoming'),
                  ),
                  ButtonSegment(
                    value: TripFilter.completed,
                    label: Text('Completed'),
                  ),
                ],
                selected: {controller.tripFilter.value},
                onSelectionChanged: (value) =>
                    controller.tripFilter.value = value.first,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final trips = controller.filteredTrips;
              if (trips.isEmpty) {
                return const EmptyState(
                  title: 'No trips found',
                  message: 'Adjust the search or status filter.',
                  icon: Icons.route,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                itemCount: trips.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return TripCard(
                    tripId: trip.id,
                    origin: trip.origin,
                    destination: trip.destination,
                    status: switch (trip.status) {
                      TripStatus.inProgress => 'In Progress',
                      TripStatus.upcoming => 'Upcoming',
                      TripStatus.completed => 'Completed',
                      TripStatus.cancelled => 'Cancelled',
                    },
                    details: {
                      'Batches': '${trip.batchCount}',
                      'Distance': '${trip.distanceKm.toStringAsFixed(1)} km',
                      'ETA': FishTraceTime.format(trip.eta, 'hh:mm a'),
                    },
                    onTap: () {
                      controller.selectTrip(trip);
                      context.go('/transporter/trip-details');
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransporterController>();
    return FishTraceScaffold(
      appBar: FishTraceAppBar(
        title: 'Trip Details',
        leading: const BackButton(color: Colors.white),
        teal: true,
        actions: [
          Obx(() {
            final editable =
                controller.selectedTrip.value?.status == TripStatus.upcoming;
            return IconButton(
              tooltip: 'Edit trip',
              onPressed: editable
                  ? () => context.go('/transporter/edit-trip')
                  : null,
              icon: const Icon(Icons.edit_outlined),
            );
          }),
        ],
      ),
      bottomNavigation: const RoleBottomBar(
        role: UserRole.transporter,
        selectedIndex: 1,
      ),
      body: Obx(() {
        final trip = controller.selectedTrip.value;
        if (trip == null) {
          return const EmptyState(
            title: 'No trip selected',
            message: 'Choose a trip from the trips list.',
            icon: Icons.route,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.id,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                StatusChip(
                  label: trip.status == TripStatus.inProgress
                      ? 'In Progress'
                      : trip.status.name,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${trip.origin}  →  ${trip.destination}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Scheduled ${FishTraceTime.format(trip.eta, 'MMM d, yyyy · hh:mm a')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SectionHeader(title: 'Driver'),
            FishTraceCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: FishTraceColors.oceanLight,
                    child: Icon(Icons.person, color: FishTraceColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driver,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          trip.driver.isEmpty
                              ? 'Driver not assigned'
                              : 'Assigned driver',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Vehicle'),
            FishTraceCard(
              onTap: () => context.go('/transporter/vehicles'),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    color: FishTraceColors.primary,
                    size: 36,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.vehicleId,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          controller.vehicles
                                  .firstWhereOrNull(
                                    (vehicle) => vehicle.id == trip.vehicleId,
                                  )
                                  ?.type ??
                              'Vehicle details unavailable',
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SectionHeader(title: 'Route Summary'),
            FishTraceCard(child: Text('${trip.origin} → ${trip.destination}')),
            const SectionHeader(title: 'Linked Batches'),
            if (trip.batches.isEmpty)
              const FishTraceCard(
                child: Text('No batches are assigned to this trip.'),
              )
            else
              for (final batch in trip.batches)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: FishTraceCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            batch.id,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                        Text('${batch.weightKg.toStringAsFixed(1)} kg'),
                        const SizedBox(width: 12),
                        Text(
                          trip.productTemperature == null
                              ? 'Not reported'
                              : '${trip.productTemperature!.toStringAsFixed(1)}°C',
                        ),
                        if (trip.status == TripStatus.upcoming)
                          IconButton(
                            tooltip: 'Remove batch',
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () =>
                                _removeBatch(context, controller, batch),
                          ),
                      ],
                    ),
                  ),
                ),
            const SectionHeader(title: 'Trip Timeline'),
            FishTraceCard(
              child: Timeline(
                entries: [
                  TimelineEntry(
                    title: trip.origin,
                    subtitle: trip.status == TripStatus.upcoming
                        ? 'Scheduled departure'
                        : 'Trip departed',
                    trailing: FishTraceTime.format(trip.eta, 'hh:mm a'),
                  ),
                  TimelineEntry(
                    title: trip.destination,
                    subtitle: 'Delivery destination',
                    trailing:
                        'ETA ${FishTraceTime.format(trip.eta, 'hh:mm a')}',
                    completed: trip.status == TripStatus.completed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (trip.status == TripStatus.upcoming) ...[
              Row(
                children: [
                  Expanded(
                    child: FishTraceSecondaryButton(
                      label: 'Accept Batch',
                      icon: Icons.qr_code_scanner,
                      onPressed: () => context.go('/transporter/add-batch'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FishTraceSecondaryButton(
                      label: trip.assignedDeviceId == null
                          ? 'Assign Device'
                          : 'Change Device',
                      icon: Icons.sensors,
                      onPressed: () => context.go('/transporter/devices'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FishTracePrimaryButton(
                label: 'Start Trip',
                onPressed: () => context.go('/transporter/checklist'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _cancelTrip(context, controller),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Trip'),
              ),
            ] else if (trip.status == TripStatus.inProgress) ...[
              FishTracePrimaryButton(
                label: 'Live Monitoring',
                icon: Icons.sensors,
                onPressed: () => context.go('/transporter/monitoring'),
              ),
              const SizedBox(height: 8),
              FishTraceSecondaryButton(
                label: trip.deliveryConfirmed
                    ? 'Delivery Confirmed'
                    : 'Confirm Delivery',
                icon: Icons.assignment_turned_in_outlined,
                onPressed: trip.deliveryConfirmed
                    ? null
                    : () => context.go('/transporter/delivery'),
              ),
            ],
          ],
        );
      }),
    );
  }
}

Future<void> _removeBatch(
  BuildContext context,
  TransporterController controller,
  HandoverBatch batch,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Remove batch?'),
      content: const Text('This batch will return to the available handovers.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Keep'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final result = await controller.removeBatch(batch);
  if (result.status == SyncStatus.synced) await controller.load();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.status == SyncStatus.synced
              ? 'Batch removed'
              : result.lastError ?? 'Batch removal is queued.',
        ),
      ),
    );
  }
}

Future<void> _cancelTrip(
  BuildContext context,
  TransporterController controller,
) async {
  final reason = TextEditingController();
  final value = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Cancel transport trip'),
      content: TextField(
        controller: reason,
        maxLength: 500,
        decoration: const InputDecoration(labelText: 'Cancellation reason'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Back'),
        ),
        FilledButton(
          onPressed: () {
            final text = reason.text.trim();
            if (text.isNotEmpty) Navigator.pop(dialogContext, text);
          },
          child: const Text('Cancel Trip'),
        ),
      ],
    ),
  );
  reason.dispose();
  if (value == null || !context.mounted) return;
  final result = await controller.cancelSelectedTrip(value);
  if (result.status == SyncStatus.synced) await controller.load();
  if (context.mounted) context.go('/transporter/trips');
}
