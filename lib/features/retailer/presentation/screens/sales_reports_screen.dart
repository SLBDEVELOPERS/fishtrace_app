import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/retailer_entities.dart';
import '../controllers/retail_reports_controller.dart';
import '../controllers/retailer_controller.dart';

class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({super.key});
  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final retailer = Get.find<RetailerController>();
    final reports = Get.find<RetailReportsController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(title: 'Reports'),
      bottomNavigation: RoleBottomBar(
        role: UserRole.retailer,
        selectedIndex: 0,
        alertBadge: retailer.alerts.length,
      ),
      body: Obx(() {
        final summary = reports.summary.value;
        if (reports.loading.value && summary == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (reports.error.value != null && summary == null) {
          return ErrorState(
            title: 'Reports unavailable',
            message: reports.error.value!.message,
            onRetry: reports.load,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FishTraceCard(
              child: Row(
                children: [
                  const Icon(Icons.date_range, color: FishTraceColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_rangeLabel(reports.selectedRange.value)),
                  ),
                  TextButton(
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        initialDateRange: reports.selectedRange.value,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (range != null) await reports.load(range: range);
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Overview')),
                ButtonSegment(value: 1, label: Text('Stock')),
                ButtonSegment(value: 2, label: Text('Sales')),
              ],
              selected: {_tab},
              showSelectedIcon: false,
              onSelectionChanged: (value) => setState(() => _tab = value.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Total Sales',
                    value: summary == null
                        ? '--'
                        : '₹${summary.salesTotal.toStringAsFixed(0)}',
                    icon: Icons.currency_rupee,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricCard(
                    label: 'In Stock',
                    value: summary == null
                        ? '--'
                        : '${summary.availableInventoryPackages} pkgs',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricCard(
                    label: 'Batches',
                    value: summary?.batchCount.toString() ?? '--',
                    icon: Icons.layers_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ChartCard(
              title: _chartTitle,
              values: _chartValues(reports),
              unit: _tab == 1 ? ' pkgs' : '',
              height: 145,
            ),
            const SizedBox(height: 16),
            if (_tab == 1) ...[
              const SectionHeader(title: 'Inventory'),
              if (reports.inventory.isEmpty)
                const EmptyState(
                  title: 'No inventory records',
                  message: 'No inventory matches the selected date range.',
                  icon: Icons.inventory_2_outlined,
                )
              else
                for (final item in reports.inventory) _InventoryRow(item: item),
            ] else ...[
              const SectionHeader(title: 'Sales records'),
              if (reports.sales.isEmpty)
                const EmptyState(
                  title: 'No sales records',
                  message: 'No sales match the selected date range.',
                  icon: Icons.receipt_long_outlined,
                )
              else
                for (final sale in reports.sales) _SalesRow(sale: sale),
            ],
            if (reports.loading.value) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        );
      }),
    );
  }

  String get _chartTitle => switch (_tab) {
    0 => 'Sales totals',
    1 => 'Available packages',
    _ => 'Sales totals',
  };

  List<double> _chartValues(RetailReportsController reports) => switch (_tab) {
    1 =>
      reports.inventory
          .map((item) => item.availablePackages.toDouble())
          .toList(growable: false),
    _ => reports.sales.map((sale) => sale.total).toList(growable: false),
  };

  String _rangeLabel(DateTimeRange? range) {
    if (range == null) return 'All available records';
    final format = DateFormat('MMM d, y');
    return '${format.format(range.start)} – ${format.format(range.end)}';
  }
}

class _SalesRow extends StatelessWidget {
  const _SalesRow({required this.sale});
  final RetailSalesReportRow sale;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: FishTraceCard(
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: FishTraceColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.receiptNumber,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  sale.location,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  DateFormat(
                    'MMM d, y • hh:mm a',
                  ).format(FishTraceTime.inSriLanka(sale.soldAt)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text('₹${sale.total.toStringAsFixed(0)}'),
          const SizedBox(width: 8),
          StatusChip(label: sale.status),
        ],
      ),
    ),
  );
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.item});
  final RetailInventoryReportRow item;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: FishTraceCard(
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: FishTraceColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.labelCode,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  '${item.batchCode} • ${item.location}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${item.availablePackages} of ${item.totalPackages} packages',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusChip(label: item.status),
        ],
      ),
    ),
  );
}
