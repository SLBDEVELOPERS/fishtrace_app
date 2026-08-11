import '../../../../core/models/models.dart';
import '../../domain/entities/retailer_entities.dart';
import '../../domain/repositories/retailer_repository.dart';

class MockRetailerRepository implements RetailerRepository {
  @override
  Future<ReceivedRetailBatch?> findIncomingBatch(String scannedValue) async {
    final batches = await getReceivedBatches();
    for (final batch in batches) {
      if (batch.matchesScan(scannedValue)) return batch;
    }
    return null;
  }

  @override
  Future<List<RetailProduct>> getInventory() async => [
    RetailProduct(
      id: 'PRODUCT-001',
      name: 'Yellowfin Tuna',
      scientificName: 'Thunnus albacares',
      category: 'Fish',
      stockKg: 125.4,
      availablePackages: 1254,
      packageWeightKg: .1,
      expiry: DateTime(2024, 5, 28),
      batchId: 'FTB-2024-05-21',
      unitPrice: 18.50,
      lowStockThreshold: 30,
    ),
    RetailProduct(
      id: 'PRODUCT-002',
      name: 'Norwegian Salmon',
      scientificName: 'Salmo salar',
      category: 'Fish',
      stockKg: 82,
      availablePackages: 820,
      packageWeightKg: .1,
      expiry: DateTime(2024, 5, 30),
      batchId: 'FTB-2024-05-20',
      unitPrice: 21,
      lowStockThreshold: 25,
    ),
    RetailProduct(
      id: 'PRODUCT-003',
      name: 'Vannamei Prawn',
      scientificName: 'Litopenaeus vannamei',
      category: 'Shellfish',
      stockKg: 45.6,
      availablePackages: 456,
      packageWeightKg: .1,
      expiry: DateTime(2024, 5, 27),
      batchId: 'FTB-2024-05-19',
      unitPrice: 24.75,
      lowStockThreshold: 20,
    ),
    RetailProduct(
      id: 'PRODUCT-004',
      name: 'Red Snapper',
      scientificName: 'Lutjanus campechanus',
      category: 'Fish',
      stockKg: 38.7,
      availablePackages: 387,
      packageWeightKg: .1,
      expiry: DateTime(2024, 5, 25),
      batchId: 'FTB-2024-05-18',
      unitPrice: 16.25,
      lowStockThreshold: 40,
    ),
    RetailProduct(
      id: 'PRODUCT-005',
      name: 'Indian Mackerel',
      scientificName: 'Rastrelliger kanagurta',
      category: 'Fish',
      stockKg: 25.3,
      availablePackages: 253,
      packageWeightKg: .1,
      expiry: DateTime(2024, 5, 26),
      batchId: 'FTB-2024-05-17',
      unitPrice: 12.40,
      lowStockThreshold: 20,
    ),
  ];

  @override
  Future<List<RetailAlertView>> getAlerts() async => const [
    RetailAlertView(
      id: 'ALERT-RECALL',
      title: 'Recall Alert',
      message: 'Indian Mackerel · Batch #FTB-2024-05-12',
      type: AlertType.recall,
      severity: AlertSeverity.critical,
      timeLabel: '10m ago',
      batchId: 'FTB-2024-05-12',
    ),
    RetailAlertView(
      id: 'ALERT-EXPIRY',
      title: 'Expiry Alert',
      message: 'Yellowfin Tuna expires on May 28, 2024',
      type: AlertType.expiry,
      severity: AlertSeverity.warning,
      timeLabel: '25m ago',
    ),
    RetailAlertView(
      id: 'ALERT-STOCK',
      title: 'Low Stock Alert',
      message: 'Red Snapper current stock 38.7 kg',
      type: AlertType.stock,
      severity: AlertSeverity.warning,
      timeLabel: '1h ago',
    ),
    RetailAlertView(
      id: 'ALERT-TEMP',
      title: 'Temperature Alert',
      message: 'Hold temperature above 4°C · Oceanic Fisheries',
      type: AlertType.temperature,
      severity: AlertSeverity.critical,
      timeLabel: '2h ago',
    ),
    RetailAlertView(
      id: 'ALERT-SYSTEM',
      title: 'System Update',
      message: 'New features are available',
      type: AlertType.system,
      severity: AlertSeverity.info,
      timeLabel: '3h ago',
    ),
  ];

  @override
  Future<List<RetailSaleView>> getSales() async => [
    RetailSaleView(
      id: 'INV-2024-05-21-015',
      product: 'Yellowfin Tuna',
      quantityKg: 32.5,
      total: 7840,
      createdAt: DateTime(2024, 5, 21, 18, 30),
    ),
    RetailSaleView(
      id: 'INV-2024-05-21-014',
      product: 'Norwegian Salmon',
      quantityKg: 18.7,
      total: 4210,
      createdAt: DateTime(2024, 5, 21, 17, 15),
    ),
  ];

  @override
  Future<List<ReceivedRetailBatch>> getReceivedBatches() async => [
    ReceivedRetailBatch(
      id: 'FTB-2024-05-21',
      supplier: 'Ocean Fresh Market',
      product: 'Yellowfin Tuna',
      netWeightKg: 125.4,
      expiry: DateTime(2024, 5, 28),
      quality: 'Excellent',
      temperatureHistory: const [1.9, 2.0, 1.8, 2.1, 2.0, 2.1],
      receivedAt: DateTime(2024, 5, 21, 10, 30),
    ),
  ];

  @override
  Future<RetailReportSummary> getReportSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final inventory = await getInventoryReport(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    final sales = await getSalesReport(dateFrom: dateFrom, dateTo: dateTo);
    return RetailReportSummary(
      catchWeightKg: 0,
      batchCount: inventory.map((row) => row.batchCode).toSet().length,
      processingRecordCount: 0,
      transportTripCount: 0,
      openColdChainAlertCount: 1,
      availableInventoryPackages: inventory.fold(
        0,
        (total, row) => total + row.availablePackages,
      ),
      salesTotal: sales.fold<double>(0, (total, row) => total + row.total),
      generatedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<List<RetailSalesReportRow>> getSalesReport({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final sales = await getSales();
    return sales
        .where(
          (sale) =>
              _withinRange(sale, dateFrom, dateTo, (value) => value.createdAt),
        )
        .map(
          (sale) => RetailSalesReportRow(
            receiptNumber: sale.id,
            location: 'Mock retail location',
            status: 'COMPLETED',
            total: sale.total,
            soldAt: sale.createdAt.toUtc(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<RetailInventoryReportRow>> getInventoryReport({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final products = await getInventory();
    final reportCreatedAt = DateTime(2024, 5, 21);
    return products
        .where(
          (_) =>
              _withinRange(reportCreatedAt, dateFrom, dateTo, (value) => value),
        )
        .map(
          (product) => RetailInventoryReportRow(
            labelCode: product.id,
            batchCode: product.batchId,
            location: 'Mock retail location',
            status: product.quarantined ? 'RECALLED' : 'IN_STOCK',
            totalPackages: product.availablePackages,
            availablePackages: product.availablePackages,
            reservedPackages: 0,
            soldPackages: 0,
            expiresAt: product.expiry!.toUtc(),
          ),
        )
        .toList(growable: false);
  }

  bool _withinRange<T>(
    T value,
    DateTime? dateFrom,
    DateTime? dateTo,
    DateTime Function(T value) dateOf,
  ) {
    final source = dateOf(value).toLocal();
    final date = DateTime(source.year, source.month, source.day);
    final start = dateFrom == null
        ? null
        : DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
    final end = dateTo == null
        ? null
        : DateTime(dateTo.year, dateTo.month, dateTo.day);
    return (start == null || !date.isBefore(start)) &&
        (end == null || !date.isAfter(end));
  }
}
