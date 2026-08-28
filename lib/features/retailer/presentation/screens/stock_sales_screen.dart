import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../../common/presentation/formatters/currency_formatter.dart';
import '../../domain/entities/retailer_entities.dart';
import '../controllers/retailer_controller.dart';

class StockSalesScreen extends StatefulWidget {
  const StockSalesScreen({super.key});
  @override
  State<StockSalesScreen> createState() => _StockSalesScreenState();
}

class _StockSalesScreenState extends State<StockSalesScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _unitPrice = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  late final TabController _tabs;
  late final RetailerController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _controller = Get.find<RetailerController>();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _quantity.dispose();
    _unitPrice.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    appBar: FishTraceAppBar(
      title: 'Sales / Stock Update',
      bottom: TabBar(
        controller: _tabs,
        tabs: const [
          Tab(text: 'Record Sale'),
          Tab(text: 'Add Stock'),
        ],
      ),
    ),
    bottomNavigation: RoleBottomBar(
      role: UserRole.retailer,
      selectedIndex: 1,
      alertBadge: _controller.alerts.length,
    ),
    body: Obx(() {
      if (_controller.loading.value) {
        return const LoadingState(message: 'Checking inventory...');
      }
      final available = _controller.inventory.where(
        (product) => !product.quarantined,
      );
      if (available.isEmpty) {
        return EmptyState(
          title: 'No inventory available',
          message: 'Receive a package before recording sales or stock updates.',
          icon: Icons.inventory_2_outlined,
          actionLabel: 'Receive Batch',
          onAction: () => context.go('/retailer/receive'),
        );
      }
      return Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabs,
          children: [_buildForm(isSale: true), _buildForm(isSale: false)],
        ),
      );
    }),
  );

  Widget _buildForm({required bool isSale}) => Obx(() {
    final product = _controller.selectedProduct.value;
    final quantity = double.tryParse(_quantity.text) ?? 0;
    final price = double.tryParse(_unitPrice.text) ?? product?.unitPrice ?? 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FishTraceDropdown<RetailProduct>(
          label: 'Select Product',
          required: true,
          value: product,
          items: _controller.inventory.where((p) => !p.quarantined).toList(),
          itemLabel: (item) => '${item.name} • ${item.stockKg} kg',
          onChanged: (value) {
            _controller.selectedProduct.value = value;
            _unitPrice.text = value?.unitPrice?.toStringAsFixed(2) ?? '';
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        if (product != null)
          FishTraceCard(
            child: Row(
              children: [
                const Icon(Icons.water),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${product.name}\nAvailable: ${product.stockKg.toStringAsFixed(1)} kg',
                  ),
                ),
                StatusChip(
                  label: product.lowStock ? 'Low Stock' : 'Available',
                  color: product.lowStock
                      ? FishTraceColors.warning
                      : FishTraceColors.success,
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        FishTraceTextField(
          label: isSale ? 'Packages to Sell' : 'Packages to Add',
          required: true,
          controller: _quantity,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          validator: (value) {
            final parsed = int.tryParse(value ?? '');
            if (parsed == null || parsed <= 0) return 'Enter a valid quantity.';
            if (isSale) return _controller.validateSale(parsed);
            return null;
          },
        ),
        const SizedBox(height: 12),
        if (isSale) ...[
          FishTraceTextField(
            label: 'Unit Price (per kg)',
            required: true,
            controller: _unitPrice,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              return parsed == null || parsed <= 0
                  ? 'Enter a valid unit price.'
                  : null;
            },
          ),
          const SizedBox(height: 12),
          FishTraceCard(
            child: Row(
              children: [
                const Expanded(child: Text('Total Amount')),
                const Spacer(),
                Flexible(
                  child: Text(
                    CurrencyFormatter.lkr(quantity * price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FishTraceTextField(
            label: 'Customer Reference',
            controller: _reference,
            hint: 'Optional invoice or customer ID',
          ),
          const SizedBox(height: 12),
        ],
        FishTraceTextField(
          label: 'Notes',
          controller: _notes,
          hint: 'Optional notes',
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        FishTracePrimaryButton(
          label: _saving
              ? 'Saving…'
              : isSale
              ? 'Record Sale'
              : 'Add Stock',
          onPressed: _saving ? null : () => _submit(isSale),
        ),
      ],
    );
  });

  Future<void> _submit(bool isSale) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final quantity = int.parse(_quantity.text);
    try {
      if (isSale) {
        await _controller.recordSale(
          quantity,
          double.parse(_unitPrice.text),
          _reference.text.trim(),
        );
      } else {
        await _controller.adjustStock(quantity);
      }
      if (!mounted) return;
      _quantity.clear();
      await SuccessDialog.show(
        context: context,
        title: isSale ? 'Sale recorded' : 'Stock updated',
        message: isSale
            ? 'The sale is saved locally and queued for sync.'
            : 'The stock adjustment is saved and queued for sync.',
      );
    } on ArgumentError catch (error) {
      if (mounted) {
        FishTraceFeedback.warning(context, '${error.message}');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
