import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../controllers/processor_controller.dart';

class ScanBatchScreen extends StatefulWidget {
  const ScanBatchScreen({super.key});

  @override
  State<ScanBatchScreen> createState() => _ScanBatchScreenState();
}

class _ScanBatchScreenState extends State<ScanBatchScreen> {
  final _manual = TextEditingController();
  late final ProcessorController _controller;
  bool _manualMode = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProcessorController>();
  }

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  Future<void> _acceptCode(String rawCode) async {
    final code = _scanValue(rawCode);
    if (code.isEmpty) {
      await _showFailure(
        'Invalid batch',
        'This QR code is not a valid FishTrace processor batch.',
      );
      return;
    }
    final found = await _controller.selectBatchByCode(code);
    if (!found) {
      await _showFailure(
        'Batch not found',
        'The batch is not available in the incoming queue.',
      );
      return;
    }
    if (mounted) context.go('/processor/intake');
  }

  String _scanValue(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri != null &&
        uri.scheme == 'fishtrace' &&
        uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return value;
  }

  Future<void> _openScanner() async {
    final scanner = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
    var handled = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FishTraceColors.navy,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .82,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Close scanner',
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan Batch',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Toggle flash',
                    onPressed: scanner.toggleTorch,
                    icon: const Icon(
                      Icons.flash_on_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QRScannerFrame(
                    child: MobileScanner(
                      controller: scanner,
                      errorBuilder: (_, error, __) => _ScannerPermissionState(
                        message: error.errorDetails?.message,
                      ),
                      onDetect: (capture) async {
                        if (handled) return;
                        final code = capture.barcodes.firstOrNull?.rawValue;
                        if (code == null) return;
                        handled = true;
                        Navigator.pop(sheetContext);
                        await _acceptCode(code);
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ensure the code is clear and well lit.',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await scanner.dispose();
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    backgroundColor: FishTraceColors.navy,
    appBar: const FishTraceAppBar(
      title: 'Scan Batch',
      leading: BackButton(color: Colors.white),
      teal: true,
    ),
    bottomNavigation: const RoleBottomBar(role: UserRole.processor),
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
          onSelectionChanged: (selection) =>
              setState(() => _manualMode = selection.first),
        ),
        const SizedBox(height: FishTraceSpacing.md),
        if (!_manualMode) ...[
          SizedBox(
            height: 430,
            child: QRScannerFrame(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF26383E), Color(0xFF09191F)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.set_meal, color: Colors.white24, size: 170),
                ),
              ),
            ),
          ),
          const SizedBox(height: FishTraceSpacing.md),
          FishTracePrimaryButton(
            label: 'Open Live Scanner',
            icon: Icons.qr_code_scanner,
            onPressed: _openScanner,
          ),
        ] else ...[
          FishTraceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Batch ID',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                FishTraceTextField(
                  label: 'Batch ID',
                  controller: _manual,
                  hint: 'Enter batch ID',
                  required: true,
                ),
                const SizedBox(height: 14),
                FishTracePrimaryButton(
                  label: 'Find Batch',
                  onPressed: () => _acceptCode(_manual.text),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );

  Future<void> _showFailure(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.qr_code_2, size: 42, color: FishTraceColors.error),
      title: Text(title),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Try Again'),
        ),
      ],
    ),
  );
}

class _ScannerPermissionState extends StatelessWidget {
  const _ScannerPermissionState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Container(
    color: FishTraceColors.navy,
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.no_photography_outlined,
          color: Colors.white,
          size: 48,
        ),
        const SizedBox(height: 12),
        const Text(
          'Camera unavailable',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          message ??
              'Allow camera access in system settings or use manual entry.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );
}
