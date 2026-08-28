import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/fisher_entities.dart';
import '../controllers/fisher_controller.dart';

class CatchHistoryScreen extends StatelessWidget {
  const CatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FisherController>();
    return FishTraceScaffold(
      appBar: FishTraceAppBar(
        title: 'Catch History',
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: 'Catch filters',
            onPressed: () => _showFilter(context, controller),
            icon: const Icon(Icons.filter_alt_outlined),
          ),
        ],
      ),
      bottomNavigation: const RoleBottomBar(role: UserRole.fisher),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: FishTraceSearchField(
              hint: 'Search by species',
              onChanged: (value) => controller.catchSearch.value = value,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => SegmentedButton<CatchFilter>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: CatchFilter.all, label: Text('All')),
                  ButtonSegment(
                    value: CatchFilter.verified,
                    label: Text('Verified'),
                  ),
                  ButtonSegment(
                    value: CatchFilter.unverified,
                    label: Text('Unverified'),
                  ),
                ],
                selected: {controller.catchFilter.value},
                onSelectionChanged: (selection) =>
                    controller.catchFilter.value = selection.first,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final catches = controller.filteredCatches;
              if (catches.isEmpty) {
                return const EmptyState(
                  title: 'No catches found',
                  message: 'Try another search or filter.',
                  icon: Icons.set_meal_outlined,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                itemCount: catches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final catchRecord = catches[index];
                  return CatchCard(
                    species: catchRecord.species,
                    weight: '${catchRecord.weightKg.toStringAsFixed(1)} kg',
                    metadata: DateFormat(
                      'MMM d • hh:mm a',
                    ).format(FishTraceTime.inSriLanka(catchRecord.caughtAt)),
                    status: catchRecord.verified ? 'Verified' : 'Unverified',
                    onTap: () => _showDetails(context, catchRecord),
                  );
                },
              );
            }),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total Catch (Today)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  Text(
                    '${controller.totalCatchKg.toStringAsFixed(1)} kg',
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilter(BuildContext context, FisherController controller) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => FilterBottomSheet(
          title: 'Catch Status',
          onReset: () => controller.catchFilter.value = CatchFilter.all,
          onApply: () => Navigator.pop(sheetContext),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final filter in CatchFilter.values)
                  RadioListTile<CatchFilter>(
                    value: filter,
                    groupValue: controller.catchFilter.value,
                    title: Text(switch (filter) {
                      CatchFilter.all => 'All catches',
                      CatchFilter.verified => 'Verified',
                      CatchFilter.unverified => 'Unverified',
                    }),
                    onChanged: (value) {
                      if (value != null) controller.catchFilter.value = value;
                    },
                  ),
              ],
            ),
          ),
        ),
      );

  Future<void> _showDetails(
    BuildContext context,
    FisherCatch catchRecord,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .82,
      maxChildSize: .94,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  catchRecord.species,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              StatusChip(
                label: catchRecord.verified ? 'Verified' : 'Unverified',
                color: catchRecord.verified
                    ? FishTraceColors.success
                    : FishTraceColors.error,
              ),
            ],
          ),
          Text(
            catchRecord.scientificName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          MapPreviewCard(
            center: LatLng(catchRecord.latitude, catchRecord.longitude),
          ),
          const SectionHeader(title: 'Catch Photos'),
          _CatchPhotoGallery(photoPaths: catchRecord.photoPaths),
          const SectionHeader(title: 'Catch Details'),
          FishTraceCard(
            child: Column(
              children: [
                _DetailRow(
                  label: 'Weight',
                  value: '${catchRecord.weightKg.toStringAsFixed(1)} kg',
                ),
                _DetailRow(label: 'Quantity', value: '${catchRecord.quantity}'),
                _DetailRow(label: 'Fishing gear', value: catchRecord.gear),
                _DetailRow(label: 'Condition', value: catchRecord.condition),
                _DetailRow(
                  label: 'Captured',
                  value: DateFormat(
                    'MMM d, yyyy · hh:mm a',
                  ).format(FishTraceTime.inSriLanka(catchRecord.caughtAt)),
                ),
                _DetailRow(
                  label: 'Linked batch',
                  value: catchRecord.linkedBatchLabel ?? 'Not linked',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (!catchRecord.verified)
            FishTraceSecondaryButton(
              label: 'Edit Catch',
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.pop(sheetContext);
                FishTraceFeedback.info(
                  context,
                  'Only locally pending fields can be edited.',
                );
              },
            ),
          const SizedBox(height: 8),
          FishTracePrimaryButton(
            label: catchRecord.availableWeightKg > .001
                ? 'Link Catch to Batch'
                : 'Fully Allocated',
            onPressed: catchRecord.availableWeightKg > .001
                ? () {
                    Navigator.pop(sheetContext);
                    context.go('/fisher/create-batch');
                  }
                : null,
          ),
        ],
      ),
    ),
  );
}

class _CatchPhotoGallery extends StatelessWidget {
  const _CatchPhotoGallery({required this.photoPaths});

  final List<String> photoPaths;

  @override
  Widget build(BuildContext context) {
    if (photoPaths.isEmpty) {
      return const FishTraceCard(
        child: Row(
          children: [
            Icon(Icons.image_not_supported_outlined),
            SizedBox(width: 10),
            Expanded(child: Text('No catch photos were attached.')),
          ],
        ),
      );
    }
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoPaths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final source = photoPaths[index];
          return Semantics(
            label: 'Catch photo ${index + 1}',
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => Dialog(
                  backgroundColor: Colors.black,
                  insetPadding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        height: MediaQuery.sizeOf(dialogContext).height * .72,
                        child: InteractiveViewer(
                          child: _AuthenticatedCatchImage(
                            source: source,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton.filled(
                          tooltip: 'Close photo',
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 148,
                  child: _AuthenticatedCatchImage(source: source),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AuthenticatedCatchImage extends StatefulWidget {
  const _AuthenticatedCatchImage({
    required this.source,
    this.fit = BoxFit.cover,
  });

  final String source;
  final BoxFit fit;

  @override
  State<_AuthenticatedCatchImage> createState() =>
      _AuthenticatedCatchImageState();
}

class _AuthenticatedCatchImageState extends State<_AuthenticatedCatchImage> {
  Future<Uint8List>? _remoteBytes;

  bool get _remote {
    final scheme = Uri.tryParse(widget.source)?.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
  }

  @override
  void initState() {
    super.initState();
    if (_remote) _remoteBytes = _loadRemote();
  }

  Future<Uint8List> _loadRemote() async {
    final response = await Get.find<Dio>().get<List<int>>(
      widget.source,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const []);
  }

  @override
  Widget build(BuildContext context) {
    if (!_remote) {
      return Image.file(
        File(widget.source),
        fit: widget.fit,
        errorBuilder: (_, __, ___) => const _PhotoLoadError(),
      );
    }
    return FutureBuilder<Uint8List>(
      future: _remoteBytes,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Image.memory(snapshot.data!, fit: widget.fit);
        }
        if (snapshot.hasError) return const _PhotoLoadError();
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _PhotoLoadError extends StatelessWidget {
  const _PhotoLoadError();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Center(child: Icon(Icons.broken_image_outlined)),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    ),
  );
}
