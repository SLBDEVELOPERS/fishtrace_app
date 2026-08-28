import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/fisher_entities.dart';
import '../controllers/fisher_controller.dart';

class BoatManagementScreen extends StatelessWidget {
  const BoatManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FisherController>();
    return FishTraceScaffold(
      appBar: FishTraceAppBar(
        title: 'Boat Management',
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: 'Add boat',
            onPressed: () => _showBoatEditor(context, controller),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      bottomNavigation: const RoleBottomBar(role: UserRole.fisher),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: FishTraceSearchField(
              hint: 'Search boats',
              onChanged: (value) => controller.boatSearch.value = value,
              onFilter: () => _showFilters(context, controller),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => SegmentedButton<BoatFilter>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: BoatFilter.all,
                    label: Text('All Boats'),
                  ),
                  ButtonSegment(
                    value: BoatFilter.active,
                    label: Text('Active'),
                  ),
                  ButtonSegment(
                    value: BoatFilter.inactive,
                    label: Text('Inactive'),
                  ),
                ],
                selected: {controller.boatFilter.value},
                onSelectionChanged: (selection) =>
                    controller.boatFilter.value = selection.first,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final boats = controller.filteredBoats;
              if (boats.isEmpty) {
                return EmptyState(
                  title: 'No boats found',
                  message: 'Adjust the search or register a new boat.',
                  icon: Icons.directions_boat_outlined,
                  actionLabel: 'Add Boat',
                  onAction: () => _showBoatEditor(context, controller),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                itemCount: boats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final boat = boats[index];
                  return _BoatCard(
                    boat: boat,
                    onTap: () => _showBoatEditor(context, controller, boat),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    FisherController controller,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Boat Status', style: Theme.of(context).textTheme.titleMedium),
          for (final filter in BoatFilter.values)
            RadioListTile<BoatFilter>(
              value: filter,
              groupValue: controller.boatFilter.value,
              title: Text(switch (filter) {
                BoatFilter.all => 'All Boats',
                BoatFilter.active => 'Active',
                BoatFilter.inactive => 'Inactive',
              }),
              onChanged: (value) {
                if (value != null) controller.boatFilter.value = value;
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );

  Future<void> _showBoatEditor(
    BuildContext context,
    FisherController controller, [
    FisherBoat? existing,
  ]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          _BoatEditorSheet(controller: controller, existing: existing),
    );
  }
}

class _BoatEditorSheet extends StatefulWidget {
  const _BoatEditorSheet({required this.controller, this.existing});

  final FisherController controller;
  final FisherBoat? existing;

  @override
  State<_BoatEditorSheet> createState() => _BoatEditorSheetState();
}

class _BoatEditorSheetState extends State<_BoatEditorSheet> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _registration;
  late final TextEditingController _length;
  late final TextEditingController _engine;
  late final TextEditingController _homePort;
  late String _type;
  late bool _active;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name);
    _registration = TextEditingController(text: widget.existing?.registration);
    _length = TextEditingController(
      text: widget.existing?.lengthMetres.toStringAsFixed(1),
    );
    _engine = TextEditingController(text: widget.existing?.engineDetails);
    _homePort = TextEditingController(text: widget.existing?.homePort);
    _type = widget.existing?.type ?? 'LONG_LINER';
    _active = widget.existing?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _registration.dispose();
    _length.dispose();
    _engine.dispose();
    _homePort.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'Register Boat' : 'Edit Boat',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              FishTraceTextField(
                label: 'Boat name',
                controller: _name,
                required: true,
                validator: _required,
              ),
              const SizedBox(height: 12),
              FishTraceTextField(
                label: 'Registration number',
                controller: _registration,
                required: true,
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 5) {
                    return 'Enter a valid registration number';
                  }
                  final duplicate = widget.controller.boats.any(
                    (boat) =>
                        boat.id != widget.existing?.id &&
                        boat.registration.toLowerCase() ==
                            value!.trim().toLowerCase(),
                  );
                  return duplicate
                      ? 'Registration number already exists'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FishTraceTextField(
                      label: 'Length (m)',
                      controller: _length,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      required: true,
                      validator: (value) =>
                          (double.tryParse(value ?? '') ?? 0) <= 0
                          ? 'Enter length'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FishTraceDropdown<String>(
                      label: 'Boat type',
                      value: _type,
                      items: const ['LONG_LINER', 'GILLNETTER', 'DAY_BOAT'],
                      itemLabel: (value) => switch (value) {
                        'LONG_LINER' => 'Longliner',
                        'GILLNETTER' => 'Gillnetter',
                        'DAY_BOAT' => 'Day boat',
                        _ => value,
                      },
                      onChanged: (value) => setState(() => _type = value!),
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FishTraceTextField(
                label: 'Engine details',
                controller: _engine,
                required: true,
                validator: _required,
              ),
              const SizedBox(height: 12),
              FishTraceTextField(
                label: 'Home port',
                controller: _homePort,
                required: true,
                validator: _required,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Boat is active'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
              const SizedBox(height: 8),
              FishTracePrimaryButton(
                label: widget.existing == null ? 'Add Boat' : 'Save Changes',
                loading: _saving,
                onPressed: () async {
                  if (!_key.currentState!.validate()) return;
                  setState(() => _saving = true);
                  try {
                    await widget.controller.saveBoat(
                      FisherBoat(
                        id:
                            widget.existing?.id ??
                            widget.controller.nextLocalId('LOCAL-BOAT'),
                        name: _name.text.trim(),
                        registration: _registration.text.trim(),
                        lengthMetres: double.parse(_length.text),
                        engineDetails: _engine.text.trim(),
                        type: _type,
                        homePort: _homePort.text.trim(),
                        active: _active,
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  } on AppException catch (error) {
                    if (context.mounted) {
                      FishTraceFeedback.error(context, error.message);
                      setState(() => _saving = false);
                    }
                  } catch (_) {
                    if (context.mounted) {
                      FishTraceFeedback.error(
                        context,
                        'The boat could not be saved. Please try again.',
                      );
                      setState(() => _saving = false);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoatCard extends StatelessWidget {
  const _BoatCard({required this.boat, required this.onTap});

  final FisherBoat boat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 62,
          height: 52,
          decoration: BoxDecoration(
            color: FishTraceColors.oceanLight,
            borderRadius: BorderRadius.circular(FishTraceRadii.control),
          ),
          child: const Icon(
            Icons.directions_boat,
            color: FishTraceColors.primary,
            size: 34,
          ),
        ),
        const SizedBox(width: FishTraceSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(boat.name, style: Theme.of(context).textTheme.titleSmall),
              Text(
                'Registration',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                boat.registration,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StatusChip(
              label: boat.active ? 'Active' : 'Inactive',
              color: boat.active
                  ? FishTraceColors.success
                  : FishTraceColors.textSecondary,
            ),
            const SizedBox(height: 7),
            Text(
              '${boat.lengthMetres.toStringAsFixed(1)} m',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ],
    ),
  );
}
