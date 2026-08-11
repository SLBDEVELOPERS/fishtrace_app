import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../controllers/retailer_controller.dart';

class ReceiveBatchScreen extends StatefulWidget {
  const ReceiveBatchScreen({super.key});
  @override
  State<ReceiveBatchScreen> createState() => _ReceiveBatchScreenState();
}

class _ReceiveBatchScreenState extends State<ReceiveBatchScreen> {
  final _manual = TextEditingController();
  late final RetailerController _controller;
  bool _manualMode = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<RetailerController>();
  }

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  Future<void> _find(String raw) async {
    final code = raw.trim();
    final batch = await _controller.resolveIncomingBatch(code);
    if (!mounted) return;
    if (batch == null) {
      _error(
        'Package not found',
        'No incoming package matches this label or identifier.',
      );
      return;
    }
    _controller.selectedBatch.value = batch;
    setState(() {});
  }

  Future<void> _scan() async {
    final scanner = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    var handled = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: FishTraceColors.navy,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan Batch QR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: scanner.toggleTorch,
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QRScannerFrame(
                    child: MobileScanner(
                      controller: scanner,
                      errorBuilder: (_, error, __) => Center(
                        child: Text(
                          error.errorDetails?.message ??
                              'Camera permission is required.',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      onDetect: (capture) {
                        if (handled) return;
                        final value = capture.barcodes.firstOrNull?.rawValue;
                        if (value == null) return;
                        handled = true;
                        Navigator.pop(dialogContext);
                        _find(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await scanner.dispose();
  }

  Future<void> _complete() async {
    final batch = _controller.selectedBatch.value;
    if (batch == null) return;
    setState(() => _saving = true);
    await _controller.queue('Complete retail receipt', 'receipt', {
      'packageLabelId': batch.id,
      'receivedPackageCount': batch.packageCount,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    context.go('/retailer/received-details');
  }

  @override
  Widget build(BuildContext context) {
    final batch = _controller.selectedBatch.value;
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(
        title: 'Receive Batch',
        leading: BackButton(color: Colors.white),
        teal: true,
      ),
      bottomNavigation: const RoleBottomBar(role: UserRole.retailer),
      body: ListView(
        padding: const EdgeInsets.all(FishTraceSpacing.md),
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: false, label: Text('Scan QR Code')),
              ButtonSegment(value: true, label: Text('Manual Entry')),
            ],
            selected: {_manualMode},
            onSelectionChanged: (value) =>
                setState(() => _manualMode = value.first),
          ),
          const SizedBox(height: 12),
          if (!_manualMode) ...[
            SizedBox(
              height: 260,
              child: QRScannerFrame(
                child: Container(
                  color: FishTraceColors.navy,
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_2,
                      color: Colors.white,
                      size: 125,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FishTraceSecondaryButton(label: 'Live Scanner', onPressed: _scan),
          ] else
            FishTraceTextField(
              label: 'Batch ID',
              controller: _manual,
              hint: 'Enter batch ID',
              suffixIcon: IconButton(
                onPressed: () => _find(_manual.text),
                icon: const Icon(Icons.search),
              ),
            ),
          if (batch != null) ...[
            const SectionHeader(title: 'Batch Information'),
            FishTraceCard(
              child: Column(
                children: [
                  _DataRow(label: 'Batch ID', value: batch.id),
                  _DataRow(label: 'Supplier', value: batch.supplier),
                  _DataRow(label: 'Product', value: batch.product),
                  _DataRow(
                    label: 'Total Quantity',
                    value: '${batch.netWeightKg.toStringAsFixed(1)} kg',
                  ),
                  _DataRow(label: 'Items', value: '${batch.packageCount}'),
                  _DataRow(
                    label: 'Received Date',
                    value: DateFormat(
                      'MMM d, yyyy · hh:mm a',
                    ).format(FishTraceTime.inSriLanka(batch.receivedAt)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FishTracePrimaryButton(
              label: 'Complete Receipt',
              loading: _saving,
              onPressed: _complete,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _error(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Try Again'),
        ),
      ],
    ),
  );
}

class ReceivedBatchDetailsScreen extends StatelessWidget {
  const ReceivedBatchDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RetailerController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(
        title: 'Batch Details',
        leading: BackButton(color: Colors.white),
        teal: true,
      ),
      bottomNavigation: const RoleBottomBar(role: UserRole.retailer),
      body: Obx(() {
        final batch = controller.selectedBatch.value;
        if (batch == null) {
          return const EmptyState(
            title: 'No received batch',
            message: 'Scan a delivered batch first.',
            icon: Icons.inventory_2_outlined,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Batch #${batch.id}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const StatusChip(label: 'Received'),
              ],
            ),
            Text(
              'Received ${FishTraceTime.format(batch.receivedAt, 'MMM d, yyyy · hh:mm a')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Supplier: ${batch.supplier}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SectionHeader(title: 'Items in this Batch'),
            FishBatchCard(
              batchId: batch.id,
              species: batch.product,
              subtitle: '${batch.packageCount} package(s)',
              weight: '${batch.netWeightKg.toStringAsFixed(1)} kg',
              status: 'Received',
            ),
            const SizedBox(height: 10),
            FishTraceCard(
              child: Row(
                children: [
                  Expanded(
                    child: _DataColumn(
                      label: 'Expiry Date',
                      value: batch.expiry == null
                          ? 'Not available'
                          : DateFormat(
                              'MMM d, yyyy',
                            ).format(FishTraceTime.inSriLanka(batch.expiry!)),
                    ),
                  ),
                  Expanded(
                    child: _DataColumn(
                      label: 'Quality',
                      value: batch.quality,
                      color: FishTraceColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Temperature History (°C)'),
            if (batch.temperatureHistory.isEmpty)
              const FishTraceCard(
                child: Text('No cold-chain telemetry is available.'),
              )
            else ...[
              TemperatureCard(
                label: 'Current cold-chain temperature',
                current: batch.temperatureHistory.last,
                minimum: batch.temperatureHistory.reduce(
                  (a, b) => a < b ? a : b,
                ),
                maximum: batch.temperatureHistory.reduce(
                  (a, b) => a > b ? a : b,
                ),
              ),
              const SizedBox(height: 8),
              ChartCard(
                title: 'Cold-chain temperature',
                values: batch.temperatureHistory,
                unit: '°C',
                height: 140,
              ),
            ],
            const SizedBox(height: 14),
          ],
        );
      }),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
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

class _DataColumn extends StatelessWidget {
  const _DataColumn({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 3),
      Text(
        value,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
      ),
    ],
  );
}
