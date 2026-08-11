import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/retailer_entities.dart';
import '../controllers/retailer_controller.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RetailerController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(title: 'Inventory'),
      bottomNavigation: RoleBottomBar(
        role: UserRole.retailer,
        selectedIndex: 1,
        alertBadge: controller.alerts.length,
      ),
      body: Obx(
        () => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: FishTraceSearchField(
                hint: 'Search products or batch ID',
                onChanged: (value) => controller.search.value = value,
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  for (final category in InventoryCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_categoryLabel(category)),
                        selected:
                            controller.inventoryCategory.value == category,
                        onSelected: (_) =>
                            controller.inventoryCategory.value = category,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${controller.filteredInventory.length} products',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),
                  const Icon(Icons.tune, size: 18),
                  const SizedBox(width: 4),
                  const Text('Filter'),
                ],
              ),
            ),
            Expanded(
              child: controller.filteredInventory.isEmpty
                  ? const EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products found',
                      message: 'Try another search or category.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                      itemCount: controller.filteredInventory.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = controller.filteredInventory[index];
                        return InventoryProductCard(
                          onTap: () =>
                              _showDetails(context, product, controller),
                          name: product.name,
                          scientificName: product.scientificName,
                          stock: '${product.stockKg.toStringAsFixed(1)} kg',
                          expiry: product.expiry == null
                              ? 'Not available'
                              : DateFormat('MMM d, y').format(product.expiry!),
                          status: product.quarantined
                              ? 'Quarantined'
                              : product.lowStock
                              ? 'Low Stock'
                              : 'In Stock',
                          category: product.category,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(InventoryCategory value) => switch (value) {
    InventoryCategory.all => 'All',
    InventoryCategory.fish => 'Fish',
    InventoryCategory.shellfish => 'Shellfish',
    InventoryCategory.other => 'Other',
  };

  Future<void> _showDetails(
    BuildContext context,
    RetailProduct product,
    RetailerController controller,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.water,
                  size: 42,
                  color: FishTraceColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(product.scientificName),
                    ],
                  ),
                ),
                StatusChip(
                  label: product.quarantined ? 'Quarantined' : 'Traceable',
                  color: product.quarantined
                      ? FishTraceColors.error
                      : FishTraceColors.success,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FishTraceCard(
              child: Column(
                children: [
                  _Detail('Batch ID', product.batchId),
                  _Detail('Available stock', '${product.stockKg} kg'),
                  _Detail(
                    'Unit price',
                    product.unitPrice == null
                        ? 'Price not set'
                        : '₹ ${product.unitPrice!.toStringAsFixed(2)} / kg',
                  ),
                  _Detail(
                    'Expiry',
                    product.expiry == null
                        ? 'Not available'
                        : DateFormat('MMM d, y').format(product.expiry!),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Traceability & documents'),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.route, color: FishTraceColors.primary),
              title: Text('Catch-to-store timeline'),
              subtitle: Text('Fisher → Processor → Transporter → Retailer'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.verified_user_outlined,
                color: FishTraceColors.primary,
              ),
              title: Text('Health certificate'),
              subtitle: Text('Verified document • PDF'),
            ),
            FishTracePrimaryButton(
              label: 'View full traceability',
              icon: Icons.qr_code,
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Traceability loaded for ${product.batchId}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    ),
  );
}
