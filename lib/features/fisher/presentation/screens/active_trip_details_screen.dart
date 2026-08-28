import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../../common/presentation/controllers/mobile_settings_controller.dart';
import '../../../common/presentation/formatters/measurement_formatter.dart';
import '../controllers/fisher_controller.dart';
import '../widgets/marine_weather_card.dart';

class ActiveTripDetailsScreen extends StatelessWidget {
  const ActiveTripDetailsScreen({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FisherController>();
    final mobileSettings = Get.find<MobileSettingsController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(
        title: 'Active Trip',
        leading: BackButton(),
      ),
      bottomNavigation: const RoleBottomBar(
        role: UserRole.fisher,
        selectedIndex: 1,
      ),
      body: Obx(() {
        final trip = controller.activeTrip.value;
        if (trip == null) {
          return EmptyState(
            title: 'No active trip',
            message: 'Start a fishing trip to capture catches and batches.',
            icon: Icons.route_outlined,
            actionLabel: 'Start Trip',
            onAction: () => context.go('/fisher/start-trip'),
          );
        }
        final duration = now().difference(trip.startedAt);
        return ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const StatusChip(label: 'In Progress'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.directions_boat_outlined,
                  size: 18,
                  color: FishTraceColors.primary,
                ),
                const SizedBox(width: 6),
                Text(trip.boatName),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Started ${FishTraceTime.format(trip.startedAt, 'hh:mm a')}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FishTraceSpacing.md),
            SizedBox(
              height: 96,
              child: Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Catch (kg)',
                      value: MeasurementFormatter.weight(
                        trip.catchKg,
                        mobileSettings.settings.value,
                      ),
                      icon: Icons.set_meal_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MetricCard(
                      label: 'Batches',
                      value: '${trip.batchCount}',
                      icon: Icons.layers_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MetricCard(
                      label: 'Avg. Catch / hr',
                      value: duration.inMinutes < 1
                          ? '${MeasurementFormatter.weight(trip.catchKg, mobileSettings.settings.value)}/hr'
                          : '${MeasurementFormatter.weight(trip.catchKg / (duration.inMinutes / 60), mobileSettings.settings.value)}/hr',
                      icon: Icons.speed,
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Fishing Area'),
            if (trip.latitude != null && trip.longitude != null)
              MapPreviewCard(
                center: LatLng(trip.latitude!, trip.longitude!),
                caption: trip.fishingArea,
              )
            else
              FishTraceCard(
                child: Text(
                  trip.fishingArea.isEmpty
                      ? 'No fishing-area coordinates were recorded.'
                      : trip.fishingArea,
                ),
              ),
            const SectionHeader(title: 'Weather Summary'),
            MarineWeatherCard(controller: controller),
            const SizedBox(height: FishTraceSpacing.md),
            Text(
              'Trip Duration',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              '${duration.inHours.toString().padLeft(2, '0')}h '
              '${(duration.inMinutes % 60).toString().padLeft(2, '0')}m',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: FishTraceSpacing.md),
            FishTracePrimaryButton(
              label: 'Add Catch',
              onPressed: () => context.go('/fisher/add-catch'),
            ),
            const SizedBox(height: 8),
            FishTraceSecondaryButton(
              label: 'End Trip',
              onPressed: () => _endTrip(context, controller),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _endTrip(
    BuildContext context,
    FisherController controller,
  ) async {
    final confirmed = await ConfirmationBottomSheet.show(
      context: context,
      title: 'End this trip?',
      message: 'Confirm all catches have been recorded before ending the trip.',
      confirmLabel: 'End Trip',
      icon: Icons.stop_circle_outlined,
      destructive: true,
    );
    if (!confirmed) return;
    await controller.queueOperation('End fishing trip', 'trip', {
      'tripId': controller.activeTrip.value!.id,
      'completedAt': now().toIso8601String(),
    });
    await controller.completeActiveTrip();
    if (context.mounted) {
      FishTraceFeedback.warning(context, 'Trip completion queued for sync');
      context.go('/fisher');
    }
  }
}
